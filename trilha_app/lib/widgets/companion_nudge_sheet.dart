import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/walk_companion.dart';
import '../services/companion_service.dart';
import '../theme/app_theme.dart';
import '../utils/layout_utils.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import 'hero_card_atmosphere.dart';
import 'stway_brand.dart';

/// Abre o gesto de animar: aceno no app + WhatsApp opcional.
Future<void> showCompanionNudgeSheet(
  BuildContext context, {
  required WalkCompanion companion,
  required String myName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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

  String get _them => widget.companion.partnerFirstName;

  String _messageOf(WalkCompanion live) {
    final presets = live.nudgePresets;
    if (presets.isEmpty) return 'Tô te esperando na trilha';
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
    setState(() => _sending = true);
    HapticFeedback.mediumImpact();
    final ok = await companion.sendNudge(
      code: widget.companion.code,
      fromName: widget.myName,
      message: _messageOf(live),
    );
    if (!mounted) return;
    setState(() => _sending = false);
    final messenger = ScaffoldMessenger.of(context);
    final gap = scrollPaddingBelowNav(context);
    if (!ok) {
      showAppToast(
        messenger,
        message: companion.lastError ?? 'Não foi possível enviar o aceno.',
        glyph: CinematicGlyph.echo,
        tone: AppToastTone.warn,
        bottomGap: gap,
      );
      return;
    }
    Navigator.of(context).pop();
    showAppToast(
      messenger,
      message: 'Aceno enviado. $_them vê ao abrir o Stway.',
      glyph: CinematicGlyph.lamp,
      bottomGap: gap,
    );
  }

  Future<void> _shareWhatsApp() async {
    if (_sending || _sharing) return;
    setState(() => _sharing = true);
    HapticFeedback.lightImpact();
    final text = widget.companion.nudgeShareText();
    XFile? imageFile;
    try {
      imageFile = await _captureCard();
    } catch (e, st) {
      debugPrint('nudge share: falha ao capturar imagem: $e\n$st');
    }

    if (mounted) Navigator.of(context).pop();

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: imageFile == null ? null : [imageFile],
          text: text,
          subject: 'Vamos caminhar juntos?',
        ),
      );
    } catch (e, st) {
      debugPrint('nudge share: SharePlus falhou: $e\n$st');
      try {
        await SharePlus.instance.share(
          ShareParams(text: text, subject: 'Vamos caminhar juntos?'),
        );
      } catch (e2, st2) {
        debugPrint('nudge share: fallback texto falhou: $e2\n$st2');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final live = _resolve(watch: true);
    final presets = live.nudgePresets;
    final already = live.iNudgedToday;
    final canSendApp = context.watch<CompanionService>().backend.isActive;
    final busy = _sending || _sharing;

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
        Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpace.md,
            0,
            AppSpace.md,
            AppSpace.md,
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpace.lg,
            12,
            AppSpace.lg,
            14 + bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.night,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.55)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: CinematicIcon(
                  glyph: CinematicGlyph.lamp,
                  size: 44,
                  accent: AppColors.accent,
                  glowing: true,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Animar $_them',
                textAlign: TextAlign.center,
                style: AppTypography.display(
                  size: 22,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                already
                    ? 'Você já acenou hoje. Manda também no WhatsApp, se quiser.'
                    : canSendApp
                    ? 'Um aceno na trilha — $_them vê ao abrir o Stway.'
                    : 'Entre na conta para acenar no app, ou manda no WhatsApp.',
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  size: 13,
                  height: 1.35,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              if (!already) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var i = 0; i < presets.length; i++)
                      _NudgePresetChip(
                        label: presets[i],
                        selected: i == _presetIndex,
                        onTap: busy
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                setState(() => _presetIndex = i);
                              },
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              if (canSendApp && !already)
                CopperCta(
                  label: 'Enviar aceno',
                  onTap: busy ? null : _sendAceno,
                  leading: CinematicGlyph.lamp,
                  trailing: null,
                  dense: true,
                  busy: _sending,
                )
              else if (already)
                CopperCta(
                  label: 'Mandar no WhatsApp',
                  onTap: busy ? null : _shareWhatsApp,
                  leading: CinematicGlyph.share,
                  trailing: null,
                  dense: true,
                  busy: _sharing,
                )
              else
                CopperCta(
                  label: 'Mandar no WhatsApp',
                  onTap: busy ? null : _shareWhatsApp,
                  leading: CinematicGlyph.share,
                  trailing: null,
                  dense: true,
                  busy: _sharing,
                ),
              if (canSendApp && !already) ...[
                const SizedBox(height: 8),
                GhostCta(
                  label: 'Também no WhatsApp',
                  leading: CinematicGlyph.share,
                  expanded: true,
                  onTap: busy ? null : _shareWhatsApp,
                ),
              ],
            ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected
                  ? AppColors.accent.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w800,
              color: selected
                  ? AppColors.accent
                  : Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
      ),
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
    final me = myName.trim().isEmpty ? 'Você' : myName.trim().split(' ').first;
    final them = companion.displayName.trim().isEmpty
        ? 'Companheiro'
        : companion.displayName.trim().split(' ').first;
    final delay = companion.delayCopy;
    final headline = delay?.headline ?? 'A trilha empoeirou';
    final days = delay?.daysAway ?? companion.theyDaysAway ?? 0;
    final insight = delay?.insight ?? 'Tô te esperando na trilha';
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
                      const Color(0xFFC4A070).withValues(alpha: 0.22),
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
                        letterColor: Colors.white.withValues(alpha: 0.95),
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
                              color: const Color(
                                0xFFC4A070,
                              ).withValues(alpha: 0.45),
                            ),
                          ),
                          child: Text(
                            days == 1 ? '1 DIA FORA' : '$days DIAS FORA',
                            style: AppTypography.label(
                              size: 10,
                              letterSpacing: 0.8,
                              weight: FontWeight.w900,
                              color: const Color(0xFFE8C48A),
                            ),
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
                          color: const Color(
                            0xFFC4A070,
                          ).withValues(alpha: 0.55),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF3A2410,
                            ).withValues(alpha: 0.7),
                            blurRadius: 28,
                            spreadRadius: 4,
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
                                borderRadius: BorderRadius.circular(20),
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
                      size: compact ? 18 : 22,
                      weight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NA POEIRA',
                    style: AppTypography.label(
                      size: 11,
                      letterSpacing: 1.6,
                      weight: FontWeight.w900,
                      color: const Color(0xFFE8C48A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    headline,
                    textAlign: TextAlign.center,
                    style:
                        AppTypography.display(
                          size: compact ? 24 : 30,
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
                      size: compact ? 13 : 15,
                      weight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.72),
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
                        color: AppColors.accent.withValues(alpha: 0.55),
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
                                weight: FontWeight.w900,
                                color: AppColors.inkOnAccent,
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
                                '$me já caminhou',
                                style: AppTypography.body(
                                  size: 13,
                                  weight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Vem retomar comigo no Stway',
                                style: AppTypography.body(
                                  size: 12,
                                  color: AppColors.accent.withValues(
                                    alpha: 0.9,
                                  ),
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
                    color: const Color(0xFFC4A070).withValues(alpha: 0.5),
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
