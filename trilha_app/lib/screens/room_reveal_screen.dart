import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/room_week.dart';
import '../models/trail.dart';
import '../services/analytics_service.dart';
import '../services/app_update_service.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/layout_utils.dart';
import '../utils/plus_access.dart';
import '../widgets/act_feel.dart';
import '../widgets/anan_speech.dart';
import '../widgets/app_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/trail_gift.dart';
import '../widgets/reveal_stage.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/user_avatar.dart';

/// Revelação da semana do grupo: o líder fecha e mostra na reunião; os
/// membros veem ao abrir o grupo. Primeiro o grupo (meta coletiva), depois
/// os fiéis (selo) e os mais constantes. O líder com Plus pode dar um passe.
class RoomRevealScreen extends StatefulWidget {
  final RoomClosing closing;
  final String roomName;
  final bool isLeader;
  final String? myUid;

  const RoomRevealScreen({
    super.key,
    required this.closing,
    required this.roomName,
    required this.isLeader,
    this.myUid,
  });

  static Future<void> open(
    BuildContext context, {
    required RoomClosing closing,
    required String roomName,
    required bool isLeader,
    String? myUid,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => RoomRevealScreen(
          closing: closing,
          roomName: roomName,
          isLeader: isLeader,
          myUid: myUid,
        ),
      ),
    );
  }

  @override
  State<RoomRevealScreen> createState() => _RoomRevealScreenState();
}

/// Etapas da cerimônia, uma tela por vez (toque avança).
enum _Beat { open, group, faithful, highlights, finale }

class _RoomRevealScreenState extends State<RoomRevealScreen>
    with TickerProviderStateMixin {
  /// Raios de luz do palco girando devagar (parado com movimento reduzido).
  late final AnimationController _rays = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 48),
  );

  /// Anima a etapa atual de 0 a 1; reinicia a cada etapa.
  late final AnimationController _beatCtrl = AnimationController(
    vsync: this,
    duration: _beatLength,
  );

  static const _beatLength = Duration(milliseconds: 2400);

  late final List<_Beat> _beats;
  int _index = 0;
  int _confettiShot = 0;
  final _timers = <Timer>[];

  /// O palco centra os raios no destaque da etapa (Anan, anel, escudo):
  /// cada etapa marca o seu com [_focusKey] e o centro é medido no layout.
  final _stackKey = GlobalKey();
  final _focusKeys = <int, GlobalKey>{};
  Offset _focus = const Offset(0.5, 0.34);

  GlobalKey get _focusKey => _focusKeys.putIfAbsent(_index, GlobalKey.new);

  void _measureFocus() {
    if (!mounted) return;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final hero =
        _focusKeys[_index]?.currentContext?.findRenderObject() as RenderBox?;
    if (stack == null || hero == null || !hero.attached) return;
    if (!stack.hasSize || !hero.hasSize || stack.size.isEmpty) return;
    final c = hero.localToGlobal(
      hero.size.center(Offset.zero),
      ancestor: stack,
    );
    final next = Offset(c.dx / stack.size.width, c.dy / stack.size.height);
    if ((next - _focus).distance > 0.002) setState(() => _focus = next);
  }

  _Beat get _beat => _beats[_index];

  bool get _iAmFaithful =>
      widget.myUid != null && widget.closing.faithful.contains(widget.myUid);

  @override
  void initState() {
    super.initState();
    final c = widget.closing;
    _beats = [
      _Beat.open,
      _Beat.group,
      _Beat.faithful,
      if (c.constant.isNotEmpty || c.grown.isNotEmpty) _Beat.highlights,
      _Beat.finale,
    ];
    final rooms = context.read<RoomService>();
    unawaited(rooms.markClosingSeen(widget.closing));
    if (_iAmFaithful) {
      unawaited(
        rooms.claimSeal(widget.closing, context.read<ProgressService>()),
      );
    }
    unawaited(
      AnalyticsService.instance.logEvent('room_reveal_open', {
        'leader': widget.isLeader ? 1 : 0,
        'group_pct': widget.closing.groupPct,
        'faithful': widget.closing.faithful.length,
        'members': widget.closing.members,
      }),
    );
    _beatCtrl.addListener(_measureFocus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!MediaQuery.disableAnimationsOf(context)) _rays.repeat();
      _enter();
    });
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _rays.dispose();
    _beatCtrl.dispose();
    super.dispose();
  }

  void _after(int ms, VoidCallback run) {
    final beat = _beat;
    _timers.add(
      Timer(Duration(milliseconds: ms), () {
        if (mounted && _beat == beat) run();
      }),
    );
  }

  /// Fração do relógio da etapa em que o fiel [i] de [n] entra.
  static double _medalStart(int i, int n) {
    final step = n <= 1 ? 0.0 : (0.5 / (n - 1)).clamp(0.0, 0.16);
    return 0.18 + i * step;
  }

  void _enter() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _beatCtrl.forward(from: 0);
    final ms = _beatLength.inMilliseconds;
    switch (_beat) {
      case _Beat.open:
        ActHaptics.light();
      case _Beat.group:
        // Quando o anel fecha: o grupo comemora junto.
        _after((ms * 0.72).round(), () {
          ActHaptics.success();
          SoundService.instance.playStreak();
        });
      case _Beat.faithful:
        final n = widget.closing.faithful.length;
        for (var i = 0; i < n; i++) {
          _after((ms * (_medalStart(i, n) + 0.08)).round(), ActHaptics.confirm);
        }
        if (n > 0) {
          _after((ms * (_medalStart(n - 1, n) + 0.2)).round(), () {
            setState(() => _confettiShot++);
            SoundService.instance.playComplete(boss: true);
          });
        }
      case _Beat.highlights:
        _after(350, ActHaptics.light);
      case _Beat.finale:
        if (_iAmFaithful) {
          _after(500, () {
            ActHaptics.success();
            setState(() => _confettiShot++);
          });
        }
    }
  }

  void _next() {
    if (_index >= _beats.length - 1) return;
    ActHaptics.tap();
    setState(() => _index++);
    _enter();
  }

  String _name(String uid) {
    if (uid == widget.myUid) return context.l10n.commonYou;
    final n = widget.closing.nameOf(uid);
    return n.isEmpty ? context.l10n.cornerSomeone : n;
  }

  /// Fatia [from]..[to] do relógio da etapa, com curva.
  Animation<double> _slice(
    double from,
    double to, [
    Curve curve = Curves.easeOutCubic,
  ]) => CurvedAnimation(
    parent: _beatCtrl,
    curve: Interval(from.clamp(0.0, 1.0), to.clamp(0.0, 1.0), curve: curve),
  );

  Color get _accent => switch (_beat) {
    _Beat.group || _Beat.highlights => AppRoles.presence,
    _ => AppRoles.reward,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final finale = _beat == _Beat.finale;
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureFocus());
    return Scaffold(
      backgroundColor: AppColors.night,
      body: Stack(
        key: _stackKey,
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: _accent),
              duration: AppMotion.scene,
              builder: (_, color, _) => TweenAnimationBuilder<Offset>(
                tween: Tween(end: _focus),
                duration: AppMotion.scene,
                curve: AppMotion.enter,
                builder: (_, focus, _) => RevealStage(
                  rays: _rays,
                  color: color ?? _accent,
                  focus: focus,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                RevealTopBar(
                  count: _beats.length,
                  index: _index,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: finale ? null : _next,
                    child: ContentFrame(
                      child: AnimatedSwitcher(
                        duration: AppMotion.standard,
                        switchInCurve: AppMotion.enter,
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: KeyedSubtree(
                          key: ValueKey(_index),
                          child: _buildBeat(context),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!finale)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.lg),
                    child: FadeTransition(
                      opacity: _slice(0.55, 0.85),
                      child: Text(
                        l10n.roomRevealTapHint,
                        style: AppTypography.label(
                          size: 12,
                          color: AppColors.textOnDark.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_confettiShot > 0)
            Positioned.fill(
              child: ConfettiOverlay(
                key: ValueKey(_confettiShot),
                active: true,
                cinematic: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBeat(BuildContext context) => switch (_beat) {
    _Beat.open => _buildOpen(context),
    _Beat.group => _buildGroup(context),
    _Beat.faithful => _buildFaithful(context),
    _Beat.highlights => _buildHighlights(context),
    _Beat.finale => _buildFinale(context),
  };

  Widget _buildOpen(BuildContext context) {
    final l10n = context.l10n;
    final c = widget.closing;
    final plan = c.isPlan;
    return RevealCentered(
      children: [
        KeyedSubtree(
          key: _focusKey,
          child: ScaleTransition(
            scale: _slice(0, 0.45, Curves.elasticOut),
            child: const CloudMascot(face: CloudFace.sucesso, size: 150),
          ),
        ),
        const SizedBox(height: AppSpace.xl),
        RevealRise(
          anim: _slice(0.25, 0.6),
          child: SectionLabel(
            plan
                ? l10n.planRevealEyebrow(widget.roomName)
                : l10n.roomRevealEyebrow(widget.roomName),
            textAlign: TextAlign.center,
            color: AppRoles.reward,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        RevealRise(
          anim: _slice(0.35, 0.75),
          child: Text(
            plan ? c.planTitle! : l10n.roomRevealTitle,
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 36,
              color: AppColors.textOnDark,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroup(BuildContext context) {
    final l10n = context.l10n;
    final c = widget.closing;
    final pct = c.groupPct;
    final headline = pct >= 85
        ? l10n.roomRevealGroupHigh
        : pct >= 40
        ? l10n.roomRevealGroupMid
        : l10n.roomRevealGroupLow;
    final assigned = [
      if (c.isPlan) l10n.planEditorDays(c.planDays ?? 0),
      if ((c.studyTitle ?? '').isNotEmpty) c.studyTitle!,
      if ((c.readingLabel ?? '').isNotEmpty) c.readingLabel!,
    ];
    final fill = _slice(0.08, 0.72);
    return RevealCentered(
      children: [
        KeyedSubtree(
          key: _focusKey,
          child: AnimatedBuilder(
            animation: fill,
            builder: (_, _) => RevealRing(
              value: pct / 100 * fill.value,
              label: '${(pct * fill.value).round()}%',
              glow: _slice(0.68, 0.9).value,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.xl),
        RevealRise(
          anim: _slice(0.62, 0.86),
          child: Text(
            headline,
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 34,
              color: AppColors.textOnDark,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        RevealRise(
          anim: _slice(0.68, 0.92),
          child: Text(
            c.isPlan
                ? l10n.planRevealGroupLine(pct)
                : l10n.roomRevealGroupLine(pct),
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 16,
              color: AppColors.textOnDark.withValues(alpha: 0.78),
              height: 1.4,
            ),
          ),
        ),
        if (assigned.isNotEmpty) ...[
          const SizedBox(height: AppSpace.lg),
          RevealRise(
            anim: _slice(0.76, 1),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                for (final a in assigned)
                  SoftBadge(text: a, accent: AppRoles.presence),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFaithful(BuildContext context) {
    final l10n = context.l10n;
    final c = widget.closing;
    final plan = c.isPlan;
    final n = c.faithful.length;
    final title = Text(
      plan ? l10n.planRevealFaithfulTitle : l10n.roomRevealFaithfulTitle,
      textAlign: TextAlign.center,
      style: AppTypography.display(
        size: 34,
        color: AppColors.textOnDark,
        height: 1.1,
      ),
    );
    final bodyStyle = AppTypography.body(
      size: 16,
      color: AppColors.textOnDark.withValues(alpha: 0.8),
      height: 1.4,
    );
    if (n == 0) {
      return RevealCentered(
        children: [
          KeyedSubtree(
            key: _focusKey,
            child: ScaleTransition(
              scale: _slice(0, 0.4, Curves.elasticOut),
              child: const CloudMascot(face: CloudFace.feliz, size: 130),
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          RevealRise(anim: _slice(0.2, 0.5), child: title),
          const SizedBox(height: AppSpace.sm),
          RevealRise(
            anim: _slice(0.3, 0.6),
            child: Text(
              plan ? l10n.planRevealFaithfulNone : l10n.roomRevealFaithfulNone,
              textAlign: TextAlign.center,
              style: bodyStyle,
            ),
          ),
        ],
      );
    }
    final lastLand = _medalStart(n - 1, n) + 0.22;
    return RevealCentered(
      scroll: true,
      children: [
        KeyedSubtree(
          key: _focusKey,
          child: ScaleTransition(
            scale: _slice(0, 0.35, Curves.elasticOut),
            child: _SealEmblem(count: n),
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        RevealRise(anim: _slice(0.08, 0.3), child: title),
        const SizedBox(height: AppSpace.sm),
        RevealRise(
          anim: _slice(0.12, 0.34),
          child: Text(
            plan
                ? l10n.planRevealFaithfulCount(n)
                : l10n.roomRevealFaithfulCount(n),
            textAlign: TextAlign.center,
            style: bodyStyle,
          ),
        ),
        const SizedBox(height: AppSpace.xl),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpace.lg,
          runSpacing: AppSpace.lg,
          children: [
            for (var i = 0; i < n; i++)
              _Medallion(
                anim: _slice(
                  _medalStart(i, n),
                  _medalStart(i, n) + 0.22,
                  Curves.elasticOut,
                ),
                name: _name(c.faithful[i]),
                seed: c.faithful[i],
                isMe: c.faithful[i] == widget.myUid,
              ),
          ],
        ),
        const SizedBox(height: AppSpace.xl),
        RevealRise(
          anim: _slice(lastLand, lastLand + 0.15),
          child: Text(
            l10n.roomRevealFaithfulSeal,
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 12,
              color: AppRoles.reward.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlights(BuildContext context) {
    final l10n = context.l10n;
    final c = widget.closing;
    final plan = c.isPlan;
    final cards = [
      if (c.constant.isNotEmpty)
        (
          CinematicGlyph.calendar,
          AppRoles.presence,
          l10n.roomRevealConstantTitle,
          plan ? l10n.planRevealConstantBody : l10n.roomRevealConstantBody,
          c.constant,
        ),
      if (c.grown.isNotEmpty)
        (
          CinematicGlyph.rise,
          AppRoles.success,
          l10n.roomRevealGrownTitle,
          l10n.roomRevealGrownBody,
          c.grown,
        ),
    ];
    return RevealCentered(
      scroll: true,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpace.lg),
          RevealRise(
            anim: _slice(0.05 + i * 0.25, 0.4 + i * 0.25),
            distance: 0.18,
            child: _Spotlight(
              glyph: cards[i].$1,
              accent: cards[i].$2,
              title: cards[i].$3,
              body: cards[i].$4,
              people: [for (final uid in cards[i].$5) (uid, _name(uid))],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFinale(BuildContext context) {
    final l10n = context.l10n;
    final c = widget.closing;
    final plan = c.isPlan;
    final canGift =
        widget.isLeader &&
        context.watch<SubscriptionService>().canShareTrailGift;
    final speech = _iAmFaithful
        ? l10n.roomRevealAnanSeal
        : c.groupPct >= 85
        ? l10n.roomRevealAnanHigh
        : c.groupPct >= 40
        ? l10n.roomRevealAnanMid
        : l10n.roomRevealAnanLow;
    return Column(
      children: [
        Expanded(
          child: RevealCentered(
            scroll: true,
            children: [
              KeyedSubtree(
                key: _focusKey,
                child: ScaleTransition(
                  scale: _slice(0, 0.4, Curves.elasticOut),
                  child: CloudMascot(face: CloudFace.sucesso, size: 170),
                ),
              ),
              const SizedBox(height: AppSpace.md),
              RevealRise(
                anim: _slice(0.2, 0.45),
                child: AnanSpeechBubble(
                  maxWidth: 340,
                  child: Text(
                    speech,
                    textAlign: TextAlign.center,
                    style: AppTypography.display(
                      size: 22,
                      color: AnanSpeechBubble.ink,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              RevealRise(
                anim: _slice(0.3, 0.55),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.sm,
                  children: [
                    SoftBadge(
                      text: '${c.groupPct}%',
                      accent: AppRoles.presence,
                    ),
                    if (c.faithful.isNotEmpty)
                      SoftBadge(
                        text:
                            '${plan ? l10n.planRevealFaithfulTitle : l10n.roomRevealFaithfulTitle}'
                            ' · ${c.faithful.length}',
                        accent: AppRoles.reward,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        RevealRise(
          anim: _slice(0.35, 0.6),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.screen,
              AppSpace.sm,
              AppSpace.screen,
              AppSpace.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.isLeader) ...[
                  GhostCta(
                    label: l10n.roomRevealShareCta,
                    leading: CinematicGlyph.share,
                    expanded: true,
                    onTap: _shareSummary,
                  ),
                  const SizedBox(height: AppSpace.sm),
                ],
                if (canGift) ...[
                  GhostCta(
                    label: l10n.roomRevealGiftCta,
                    leading: CinematicGlyph.gift,
                    expanded: true,
                    onTap: _giftPass,
                  ),
                  const SizedBox(height: AppSpace.sm),
                ],
                CopperCta(
                  label: l10n.roomRevealDone,
                  expanded: true,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Resumo em texto para o líder colar no grupo do WhatsApp da célula:
  /// nomes reais (sem "Você"), negrito no formato do WhatsApp.
  Future<void> _shareSummary() async {
    ActHaptics.tap();
    final l10n = context.l10n;
    final c = widget.closing;
    final plan = c.isPlan;
    String names(List<String> uids) => [
      for (final uid in uids)
        if (c.nameOf(uid).isNotEmpty) c.nameOf(uid),
    ].join(', ');
    final assigned = [
      if ((c.studyTitle ?? '').isNotEmpty) c.studyTitle!,
      if ((c.readingLabel ?? '').isNotEmpty) c.readingLabel!,
    ].join(' · ');
    final faithful = names(c.faithful);
    final constant = names(c.constant);
    final grown = names(c.grown);
    final text = [
      '*${widget.roomName} · ${plan ? c.planTitle! : l10n.roomRevealTitle}*',
      '${c.groupPct}% ${plan ? l10n.planRevealGroupPct : l10n.roomRevealGroupPct}',
      if (assigned.isNotEmpty) assigned,
      '',
      if (faithful.isNotEmpty)
        l10n.roomShareFaithful(faithful)
      else
        plan ? l10n.planRevealFaithfulNone : l10n.roomRevealFaithfulNone,
      if (constant.isNotEmpty) l10n.roomShareConstant(constant),
      if (grown.isNotEmpty) l10n.roomShareGrown(grown),
      '',
      l10n.roomShareFooter(AppUpdateService.androidStoreUrl),
    ].join('\n');
    unawaited(
      AnalyticsService.instance.logEvent('room_reveal_share', {
        'plan': plan ? 1 : 0,
        'group_pct': c.groupPct,
        'faithful': c.faithful.length,
      }),
    );
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Líder escolhe uma trilha do Plus e manda o passe do mês (o fluxo de
  /// sempre: link para quem ele quiser premiar).
  Future<void> _giftPass() async {
    ActHaptics.tap();
    final trails = (await TrailRepository().getTrails())
        .where((t) => !t.comingSoon && PlusAccess.trailInPlus(t))
        .toList();
    if (!mounted || trails.isEmpty) return;
    final picked = await showAppSheet<Trail>(
      context,
      builder: (sheet) => AppSheetPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              title: sheet.l10n.roomRevealGiftPickTitle,
              subtitle: sheet.l10n.roomRevealGiftPickBody,
              cloud: false,
            ),
            const SizedBox(height: AppSpace.md),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final t in trails)
                    ListTile(
                      title: Text(t.localizedTitle),
                      onTap: () => Navigator.of(sheet).pop(t),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    await showTrailGiftSheet(context, picked);
  }
}

/// Fiel que entra como medalha: retrato com aro de ouro e o selo no canto.
class _Medallion extends StatelessWidget {
  final Animation<double> anim;
  final String name;
  final String seed;
  final bool isMe;

  const _Medallion({
    required this.anim,
    required this.name,
    required this.seed,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    // A curva elástica passa de 1: a opacidade sai do valor cru, presa.
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Opacity(
        opacity: (anim.value / 0.3).clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.3 + 0.7 * anim.value, child: child),
      ),
      child: SizedBox(
        width: 88,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppRoles.reward.withValues(alpha: 0.5),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: UserAvatar(
                    name: name,
                    seed: seed,
                    radius: 32,
                    borderColor: AppRoles.reward,
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.night,
                    ),
                    child: CinematicIcon(
                      glyph: CinematicGlyph.shield,
                      size: 18,
                      accent: AppRoles.reward,
                      framed: false,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.title(
                size: 14,
                color: isMe ? AppRoles.reward : AppColors.textOnDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Destaque (mais constante, quem mais cresceu): retratos e o porquê.
class _Spotlight extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color accent;
  final String title;
  final String body;
  final List<(String, String)> people;

  const _Spotlight({
    required this.glyph,
    required this.accent,
    required this.title,
    required this.body,
    required this.people,
  });

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.textOnDark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        color: accent.withValues(alpha: 0.1),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.18), blurRadius: 30),
        ],
      ),
      child: Column(
        children: [
          CinematicIcon(glyph: glyph, size: 30, accent: accent),
          const SizedBox(height: AppSpace.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 26, color: ink),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              color: ink.withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpace.lg,
            runSpacing: AppSpace.md,
            children: [
              for (final (uid, name) in people)
                SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      UserAvatar(
                        name: name,
                        seed: uid,
                        radius: 26,
                        borderColor: accent,
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.title(size: 13, color: ink),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Emblema dos fiéis no centro dos raios: o selo e quantos o ganharam.
class _SealEmblem extends StatelessWidget {
  final int count;

  const _SealEmblem({required this.count});

  @override
  Widget build(BuildContext context) {
    const size = 150.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color.lerp(AppColors.night, AppRoles.reward, 0.28)!,
            AppColors.night,
          ],
        ),
        border: Border.all(
          color: AppRoles.reward.withValues(alpha: 0.85),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppRoles.reward.withValues(alpha: 0.45),
            blurRadius: 50,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.shield,
            size: 34,
            accent: AppRoles.reward,
            framed: false,
          ),
          Text(
            '$count',
            style: AppTypography.display(
              size: 58,
              exact: true,
              color: AppRoles.reward,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
