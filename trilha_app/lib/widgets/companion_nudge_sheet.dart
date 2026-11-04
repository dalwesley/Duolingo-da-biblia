import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_language.dart';
import '../models/walk_companion.dart';
import '../screens/paywall_screen.dart';
import '../services/companion_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/content_filter.dart';
import 'act_feel.dart';
import 'anan_speech.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'ui_primitives.dart';
import 'hero_card_atmosphere.dart';
import 'stway_brand.dart';

/// Abre o gesto de animar: aceno no app + WhatsApp opcional.
Future<void> showCompanionNudgeSheet(
  BuildContext context, {
  required WalkCompanion companion,
  required String myName,
}) {
  return showAppSheet<void>(
    context,
    builder: (_) => _CompanionNudgeSheet(companion: companion, myName: myName),
  );
}

class _CompanionNudgeSheet extends StatefulWidget {
  final WalkCompanion companion;
  final String myName;

  const _CompanionNudgeSheet({required this.companion, required this.myName});

  @override
  State<_CompanionNudgeSheet> createState() => _CompanionNudgeSheetState();
}

class _CompanionNudgeSheetState extends State<_CompanionNudgeSheet> {
  final _boundaryKey = GlobalKey();
  bool _sending = false;
  bool _sharing = false;
  late int _presetIndex;

  /// Aceno escrito (Peregrino+) no lugar dos prontos.
  bool _custom = false;
  final _text = TextEditingController();
  String? _textError;

  WalkCompanion _resolve({required bool watch}) {
    final list = watch
        ? context.watch<CompanionService>().companions
        : context.read<CompanionService>().companions;
    for (final c in list) {
      if (c.code == widget.companion.code) return c;
    }
    return widget.companion;
  }

  @override
  void initState() {
    super.initState();
    _presetIndex = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(const AssetImage('assets/icon/splash_bg.png'), context);
      precacheImage(const AssetImage('assets/icon/app_icon.png'), context);
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String get _them => widget.companion.partnerFirstName;

  /// "Escrever o meu": no Plus abre o campo; sem ele, o paywall.
  void _pickWrite() {
    ActHaptics.tap();
    if (!context.read<SubscriptionService>().plusFeaturesOpen) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const PaywallScreen(source: 'companion_nudge'),
        ),
      );
      return;
    }
    // Toque de novo no "Escrever o meu" volta aos prontos.
    if (_custom) FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _custom = !_custom;
      _textError = null;
    });
  }

  String _messageOf(WalkCompanion live) {
    if (_custom) return _text.text.trim();
    final presets = live.nudgePresets;
    if (presets.isEmpty) return context.l10n.nudgeDefaultMessage;
    return presets[_presetIndex.clamp(0, presets.length - 1)];
  }

  Future<XFile?> _captureCard() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      debugPrint('nudge share: RepaintBoundary ausente');
      return null;
    }
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return null;
    final file = File(
      '${Directory.systemTemp.path}/stway_animar_${widget.companion.code}.png',
    );
    await file.writeAsBytes(bytes.buffer.asUint8List());
    return XFile(file.path, mimeType: 'image/png');
  }

  Future<void> _sendAceno() async {
    final live = _resolve(watch: false);
    if (_sending || _sharing) return;
    final companion = context.read<CompanionService>();
    if (live.iNudgedToday) return;
    if (_custom) {
      final text = _text.text.trim();
      if (text.isEmpty) return;
      if (!ContentFilter.isAllowed(text)) {
        setState(() => _textError = context.l10n.contentTextNotAllowed);
        return;
      }
    }
    setState(() => _sending = true);
    final ok = await companion.sendNudge(
      code: widget.companion.code,
      fromName: widget.myName,
      message: _messageOf(live),
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (!ok) {
      await showAppToastFor(
        context,
        message: companion.lastError ?? context.l10n.nudgeSendFailed,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    final host = Navigator.of(context).overlay?.context;
    final sent = context.l10n.nudgeSent(_them);
    _closeSelf();
    if (host != null && host.mounted) {
      await showAppToastFor(host, message: sent, glyph: CinematicGlyph.heart);
    }
  }

  /// Fecha só esta folha — depois de um await ela pode já estar saindo
  /// (toque fora), e pop() fecharia a tela de baixo.
  void _closeSelf() {
    final route = ModalRoute.of(context);
    if (route == null || !route.isActive) return;
    if (route.isCurrent) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).removeRoute(route);
    }
  }

  Future<void> _shareWhatsApp() async {
    if (_sending || _sharing) return;
    setState(() => _sharing = true);
    final text = widget.companion.nudgeShareText();
    final subject = context.l10n.nudgeShareSubject;
    XFile? imageFile;
    try {
      imageFile = await _captureCard();
    } catch (e, st) {
      debugPrint('nudge share: falha ao capturar imagem: $e\n$st');
    }

    if (mounted) _closeSelf();

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: imageFile == null ? null : [imageFile],
          text: text,
          subject: subject,
        ),
      );
    } catch (e, st) {
      debugPrint('nudge share: SharePlus falhou: $e\n$st');
      try {
        await SharePlus.instance.share(
          ShareParams(text: text, subject: subject),
        );
      } catch (e2, st2) {
        debugPrint('nudge share: fallback texto falhou: $e2\n$st2');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final live = _resolve(watch: true);
    final presets = live.nudgePresets;
    final already = live.iNudgedToday;
    final canSendApp = context.watch<CompanionService>().backend.isActive;
    final busy = _sending || _sharing;
    final a = Appearance.of(context);
    final plusOpen = context.watch<SubscriptionService>().plusFeaturesOpen;
    // Escrito vazio não acena.
    final emptyCustom = _custom && _text.text.trim().isEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Transform.translate(
          offset: const Offset(-4000, 0),
          child: SizedBox(
            width: 360,
            child: RepaintBoundary(
              key: _boundaryKey,
              child: CompanionNudgeShareCard(
                companion: live,
                myName: widget.myName,
              ),
            ),
          ),
        ),
        AppSheetPanel(
          tint: a.chrome,
          padding: const EdgeInsets.fromLTRB(
            AppSpace.lg,
            AppSpace.md,
            AppSpace.lg,
            14,
          ),
          // Teclado aberto em tela baixa: rola em vez de estourar.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.sizeOf(context).height -
                  MediaQuery.viewInsetsOf(context).bottom -
                  MediaQuery.paddingOf(context).top -
                  96,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // O Anan fala: título e explicação no balão dele.
                  AnanSideSpeech(
                    face: CloudFace.feliz,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.nudgeTitle(_them),
                          style: AppTypography.display(
                            size: 22,
                            height: 1.1,
                            color: AnanSpeechBubble.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          already
                              ? context.l10n.nudgeAlreadySubtitle
                              : canSendApp
                              ? context.l10n.nudgeInAppSubtitle(_them)
                              : context.l10n.nudgeSignInSubtitle,
                          style: AppTypography.body(
                            size: 13,
                            height: 1.35,
                            color: AnanSpeechBubble.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!already) ...[
                    const SizedBox(height: AppSpace.lg),
                    // Cards de escolha — o mesmo do "Seu ritmo" do começo.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Escrevendo: os prontos recolhem e o teclado cabe.
                        if (!_custom)
                          for (var i = 0; i < presets.length; i++) ...[
                            if (i > 0) const SizedBox(height: AppSpace.sm),
                            _NudgePresetChip(
                              label: presets[i],
                              selected: !_custom && i == _presetIndex,
                              onTap: busy
                                  ? null
                                  : () {
                                      ActHaptics.tap();
                                      setState(() {
                                        _presetIndex = i;
                                        _custom = false;
                                        _textError = null;
                                      });
                                    },
                            ),
                          ],
                        if (canSendApp) ...[
                          const SizedBox(height: AppSpace.sm),
                          _NudgeWriteChip(
                            selected: _custom,
                            locked: !plusOpen,
                            onTap: busy ? null : _pickWrite,
                          ),
                        ],
                      ],
                    ),
                    if (_custom) ...[
                      const SizedBox(height: AppSpace.md),
                      TextField(
                        controller: _text,
                        autofocus: true,
                        maxLength: 120,
                        minLines: 1,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        style: AppTypography.body(size: 15, color: a.text),
                        decoration: InputDecoration(
                          hintText: context.l10n.nudgeWriteHint(_them),
                          errorText: _textError,
                        ),
                        onChanged: (_) => setState(() => _textError = null),
                      ),
                    ],
                  ],
                  const SizedBox(height: 18),
                  if (canSendApp && !already)
                    CopperCta(
                      label: context.l10n.waveCta,
                      onTap: busy || emptyCustom ? null : _sendAceno,
                      leading: CinematicGlyph.heart,
                      trailing: null,
                      dense: true,
                      busy: _sending,
                    )
                  else if (already)
                    CopperCta(
                      label: context.l10n.commonSendWhatsApp,
                      onTap: busy ? null : _shareWhatsApp,
                      leading: CinematicGlyph.share,
                      trailing: null,
                      dense: true,
                      busy: _sharing,
                    )
                  else
                    CopperCta(
                      label: context.l10n.commonSendWhatsApp,
                      onTap: busy ? null : _shareWhatsApp,
                      leading: CinematicGlyph.share,
                      trailing: null,
                      dense: true,
                      busy: _sharing,
                    ),
                  if (canSendApp && !already) ...[
                    const SizedBox(height: 8),
                    GhostCta(
                      label: context.l10n.commonSendWhatsApp,
                      leading: CinematicGlyph.share,
                      expanded: true,
                      onTap: busy ? null : _shareWhatsApp,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NudgePresetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NudgePresetChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Card de escolha do app (onboarding "Seu ritmo"): seleção = contorno
    // claro, não ouro.
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AppSelectChip(
        label: label,
        selected: selected,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// "Escrever o meu" — do Peregrino+. Fechado: apagado, com a marca do
/// Plus, e o toque abre o paywall.
class _NudgeWriteChip extends StatelessWidget {
  final bool selected;
  final bool locked;
  final VoidCallback? onTap;

  const _NudgeWriteChip({
    required this.selected,
    required this.locked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chip = _NudgePresetChip(
      label: context.l10n.nudgeWriteOwn,
      selected: selected,
      onTap: onTap,
    );
    // Escrevendo: o ✕ mostra que o toque volta aos prontos.
    if (!locked && selected) {
      return Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.centerRight,
        children: [
          chip,
          Positioned(
            top: 0,
            bottom: 0,
            right: 16,
            child: IgnorePointer(
              child: Center(
                child: CinematicIcon(
                  glyph: CinematicGlyph.close,
                  size: AppMetrics.iconSm,
                  accent: Appearance.of(context).textSecondary,
                  framed: false,
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (!locked) return chip;
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.centerRight,
      children: [
        Opacity(opacity: 0.45, child: chip),
        const Positioned(
          top: 0,
          bottom: 0,
          right: 14,
          child: IgnorePointer(
            child: Center(
              child: CinematicIcon(
                glyph: CinematicGlyph.plus,
                size: 22,
                accent: AppRoles.reward,
                framed: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Card visual do “animar” — story vertical, foco na pessoa empoeirada.
class CompanionNudgeShareCard extends StatelessWidget {
  final WalkCompanion companion;
  final String myName;
  final bool compact;

  const CompanionNudgeShareCard({
    super.key,
    required this.companion,
    required this.myName,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a = Appearance.of(context);
    final me = myName.trim().isEmpty
        ? l10n.commonYou
        : myName.trim().split(' ').first;
    final them = companion.displayName.trim().isEmpty
        ? l10n.nudgeCompanionFallback
        : companion.displayName.trim().split(' ').first;
    final delay = companion.delayCopy;
    final headline = delay?.headline ?? l10n.nudgeCardHeadline;
    final days = delay?.daysAway ?? companion.theyDaysAway ?? 0;
    final insight = delay?.insight ?? l10n.nudgeDefaultMessage;
    final w = compact ? 300.0 : 360.0;
    final h = compact ? 380.0 : 480.0;
    final themInitial = them.isEmpty ? '?' : them[0].toUpperCase();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFF120A06)),
            Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/icon/splash_bg.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.15),
                filterQuality: FilterQuality.high,
              ),
            ),
            // Scrim sépia forte (clima da home empoeirada).
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC3A2410),
                    Color(0x99140C06),
                    Color(0xF20A0604),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
            const Positioned.fill(
              child: CustomPaint(painter: _StaticDustPainter(heavy: true)),
            ),
            // Véu de poeira no centro (atrás do avatar).
            Center(
              child: Container(
                width: compact ? 160 : 200,
                height: compact ? 160 : 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.dust.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 18 : 24,
                compact ? 16 : 22,
                compact ? 18 : 24,
                compact ? 16 : 22,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      StwayLogo(size: compact ? 22 : 26),
                      SizedBox(width: compact ? 8 : 10),
                      StwayWordmark(
                        fontSize: compact ? 12 : 14,
                        letterSpacing: compact ? 1.8 : 2.2,
                        letterColor: a.text,
                        aColor: AppColors.accent,
                      ),
                      const Spacer(),
                      if (days > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                              color: AppColors.dust.withValues(alpha: 0.45),
                            ),
                          ),
                          child: SectionLabel(
                            l10n.nudgeCardDaysAway(days),
                            size: 10,
                            color: const Color(0xFFE8C48A),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(flex: 2),
                  // Avatar empoeirado — âncora visual.
                  HeroCardColorGrade(
                    mood: HeroCardMood.dusty,
                    child: Container(
                      width: compact ? 92 : 112,
                      height: compact ? 92 : 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2A1A0C),
                        border: Border.all(
                          color: AppColors.dust.withValues(alpha: 0.55),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(
                            child: Text(
                              themInitial,
                              style: AppTypography.display(
                                size: compact ? 40 : 48,
                                weight: FontWeight.w900,
                                color: const Color(
                                  0xFFE8C48A,
                                ).withValues(alpha: 0.72),
                              ),
                            ),
                          ),
                          const CustomPaint(
                            painter: _StaticDustPainter(heavy: true),
                          ),
                          // Mancha de pó no canto.
                          Align(
                            alignment: const Alignment(0.55, 0.65),
                            child: Container(
                              width: compact ? 36 : 44,
                              height: compact ? 28 : 34,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.xl,
                                ),
                                color: const Color(
                                  0xFF8B6914,
                                ).withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  Text(
                    them,
                    style: AppTypography.title(
                      size: compact ? 18 : 20,
                      color: a.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SectionLabel(
                    l10n.nudgeCardWaiting,
                    color: const Color(0xFFE8C48A),
                  ),
                  const Spacer(),
                  Text(
                    headline,
                    textAlign: TextAlign.center,
                    style:
                        AppTypography.display(
                          size: compact ? 24 : 28,
                          weight: FontWeight.w800,
                          color: Colors.white,
                        ).copyWith(
                          height: 1.15,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.55),
                              blurRadius: 14,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                  ),
                  SizedBox(height: compact ? 8 : 10),
                  Text(
                    insight,
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: compact ? 13 : 14,
                      weight: FontWeight.w600,
                      color: a.textSecondary,
                    ),
                  ),
                  SizedBox(height: compact ? 16 : 22),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: compact ? 12 : 14,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: AppRoles.action.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradients.gold,
                          ),
                          child: Center(
                            child: Text(
                              me.isEmpty ? '?' : me[0].toUpperCase(),
                              style: AppTypography.title(
                                size: 14,
                                color: AppRoles.onAction,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.nudgeCardWalked(me),
                                style: AppTypography.body(
                                  size: 13,
                                  weight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                l10n.nudgeCardCta,
                                style: AppTypography.body(
                                  size: 12,
                                  color: AppRoles.action.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(
                    color: AppColors.dust.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaticDustPainter extends CustomPainter {
  final bool heavy;

  const _StaticDustPainter({this.heavy = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final specs = <(double, double, double, double)>[
      (0.08, 0.12, 1.6, 0.22),
      (0.22, 0.31, 2.4, 0.28),
      (0.41, 0.18, 1.4, 0.25),
      (0.63, 0.27, 3.0, 0.22),
      (0.81, 0.14, 1.8, 0.2),
      (0.14, 0.48, 2.2, 0.2),
      (0.33, 0.56, 2.8, 0.24),
      (0.52, 0.44, 1.7, 0.17),
      (0.71, 0.58, 2.6, 0.2),
      (0.89, 0.49, 1.3, 0.21),
      (0.18, 0.72, 2.4, 0.18),
      (0.37, 0.81, 1.5, 0.18),
      (0.58, 0.74, 3.2, 0.2),
      (0.76, 0.86, 1.6, 0.2),
      (0.93, 0.68, 2.0, 0.18),
      (0.05, 0.91, 1.8, 0.12),
      (0.46, 0.08, 1.2, 0.23),
      (0.68, 0.39, 2.4, 0.22),
      (0.27, 0.63, 2.0, 0.14),
      (0.84, 0.33, 1.5, 0.19),
      (0.12, 0.22, 1.1, 0.16),
      (0.55, 0.66, 1.8, 0.15),
      (0.78, 0.12, 1.4, 0.14),
      (0.42, 0.92, 2.1, 0.17),
    ];
    final boost = heavy ? 1.35 : 1.0;
    for (final (x, y, r, a) in specs) {
      paint.color = const Color(
        0xFFE8C48A,
      ).withValues(alpha: (a * boost).clamp(0.0, 0.45));
      canvas.drawCircle(
        Offset(size.width * x, size.height * y),
        r * (heavy ? 1.25 : 1.0),
        paint,
      );
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = const Color(
          0xFF3A2410,
        ).withValues(alpha: heavy ? 0.28 : 0.18),
    );
  }

  @override
  bool shouldRepaint(covariant _StaticDustPainter oldDelegate) =>
      oldDelegate.heavy != heavy;
}
