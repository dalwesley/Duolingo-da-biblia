import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/room_week.dart';
import '../models/trail.dart';
import '../services/analytics_service.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/plus_access.dart';
import '../widgets/act_feel.dart';
import '../widgets/app_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/immersive_background.dart';
import '../widgets/trail_gift.dart';
import '../widgets/ui_primitives.dart';

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

class _RoomRevealScreenState extends State<RoomRevealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stage = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  bool get _iAmFaithful =>
      widget.myUid != null && widget.closing.faithful.contains(widget.myUid);

  @override
  void initState() {
    super.initState();
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
    _stage.forward();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) ActHaptics.success();
    });
  }

  @override
  void dispose() {
    _stage.dispose();
    super.dispose();
  }

  /// Faixa de [from]..[to] (0..1) da animação: cada bloco entra na sua vez.
  Widget _beat(double from, double to, Widget child) {
    final curve = CurvedAnimation(
      parent: _stage,
      curve: Interval(from, to, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  String _name(String uid) {
    if (uid == widget.myUid) return context.l10n.commonYou;
    final n = widget.closing.nameOf(uid);
    return n.isEmpty ? context.l10n.cornerSomeone : n;
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final c = widget.closing;
    final canGift =
        widget.isLeader &&
        context.watch<SubscriptionService>().canShareTrailGift;
    final plan = c.isPlan;
    final assigned = [
      if (plan) l10n.planEditorDays(c.planDays ?? 0),
      if ((c.studyTitle ?? '').isNotEmpty) c.studyTitle!,
      if ((c.readingLabel ?? '').isNotEmpty) c.readingLabel!,
    ].join(' · ');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ImmersiveBackground(
        frameChild: false,
        child: SafeArea(
          child: ContentFrame(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.screen,
                AppSpace.lg,
                AppSpace.screen,
                AppSpace.xl,
              ),
              children: [
                _beat(
                  0,
                  0.3,
                  Column(
                    children: [
                      const CloudMascot(face: CloudFace.sucesso, size: 120),
                      const SizedBox(height: AppSpace.md),
                      SectionLabel(
                        plan
                            ? l10n.planRevealEyebrow(widget.roomName)
                            : l10n.roomRevealEyebrow(widget.roomName),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        plan ? c.planTitle! : l10n.roomRevealTitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.display(size: 28, color: a.text),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.xl),
                _beat(
                  0.2,
                  0.55,
                  GlassCard(
                    tint: AppRoles.presence,
                    glow: 0.6,
                    child: Column(
                      children: [
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: c.groupPct),
                          duration: const Duration(milliseconds: 1400),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, _) => Text(
                            '$v%',
                            style: AppTypography.display(
                              size: 56,
                              color: AppRoles.presence,
                            ),
                          ),
                        ),
                        Text(
                          plan
                              ? l10n.planRevealGroupPct
                              : l10n.roomRevealGroupPct,
                          textAlign: TextAlign.center,
                          style: AppTypography.body(
                            size: 14,
                            color: a.textSecondary,
                          ),
                        ),
                        if (assigned.isNotEmpty) ...[
                          const SizedBox(height: AppSpace.sm),
                          Text(
                            assigned,
                            textAlign: TextAlign.center,
                            style: AppTypography.label(
                              size: 12,
                              color: a.textFaint,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                _beat(
                  0.45,
                  0.75,
                  _AwardCard(
                    glyph: CinematicGlyph.shield,
                    accent: AppRoles.reward,
                    title: plan
                        ? l10n.planRevealFaithfulTitle
                        : l10n.roomRevealFaithfulTitle,
                    body: c.faithful.isEmpty
                        ? (plan
                              ? l10n.planRevealFaithfulNone
                              : l10n.roomRevealFaithfulNone)
                        : (plan
                              ? l10n.planRevealFaithfulBody
                              : l10n.roomRevealFaithfulBody),
                    names: [for (final uid in c.faithful) _name(uid)],
                  ),
                ),
                if (c.constant.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.md),
                  _beat(
                    0.6,
                    0.85,
                    _AwardCard(
                      glyph: CinematicGlyph.calendar,
                      accent: AppRoles.presence,
                      title: l10n.roomRevealConstantTitle,
                      body: plan
                          ? l10n.planRevealConstantBody
                          : l10n.roomRevealConstantBody,
                      names: [for (final uid in c.constant) _name(uid)],
                    ),
                  ),
                ],
                if (c.grown.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.md),
                  _beat(
                    0.68,
                    0.92,
                    _AwardCard(
                      glyph: CinematicGlyph.rise,
                      accent: AppRoles.success,
                      title: l10n.roomRevealGrownTitle,
                      body: l10n.roomRevealGrownBody,
                      names: [for (final uid in c.grown) _name(uid)],
                    ),
                  ),
                ],
                if (_iAmFaithful) ...[
                  const SizedBox(height: AppSpace.md),
                  _beat(
                    0.75,
                    1,
                    GlassCard(
                      tint: AppRoles.reward,
                      glow: 1,
                      child: Row(
                        children: [
                          CinematicIcon(
                            glyph: CinematicGlyph.shield,
                            size: AppMetrics.leadingIcon,
                            accent: AppRoles.reward,
                          ),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: Text(
                              plan
                                  ? l10n.planRevealYourSeal
                                  : l10n.roomRevealYourSeal,
                              style: AppTypography.title(
                                size: 15,
                                color: a.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpace.xl),
                _beat(
                  0.8,
                  1,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (canGift) ...[
                        GhostCta(
                          label: l10n.roomRevealGiftCta,
                          leading: CinematicGlyph.gift,
                          expanded: true,
                          onTap: _giftPass,
                        ),
                        const SizedBox(height: AppSpace.sm),
                        Text(
                          l10n.roomRevealGiftHint,
                          textAlign: TextAlign.center,
                          style: AppTypography.body(
                            size: 12,
                            color: a.textFaint,
                          ),
                        ),
                        const SizedBox(height: AppSpace.md),
                      ],
                      CopperCta(
                        label: l10n.roomRevealDone,
                        expanded: true,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

class _AwardCard extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color accent;
  final String title;
  final String body;
  final List<String> names;

  const _AwardCard({
    required this.glyph,
    required this.accent,
    required this.title,
    required this.body,
    required this.names,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      tint: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: glyph,
                size: AppMetrics.chipIcon,
                accent: accent,
                framed: false,
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.title(size: 16, color: a.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            body,
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
          if (names.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                for (final n in names) SoftBadge(text: n, accent: accent),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
