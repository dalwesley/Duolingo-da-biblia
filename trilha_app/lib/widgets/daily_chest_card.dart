import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/pilgrim_chest.dart';
import '../models/pilgrim_medal_models.dart' show tierLabel, PilgrimMedalTier;
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'confetti_overlay.dart';
import 'immersive_background.dart';
import 'medal_cinematic_widgets.dart';
import 'ui_primitives.dart';

/// Baú do Dia — recompensa cosmética variável, 1x/dia, ao completar a
/// missão de hoje. Nunca dá passos/XP: não compete com o Cofre de medalhas
/// (que fica intocado como conquista de longo prazo). A incerteza é só de
/// apresentação — a recompensa em si sempre vem (piso garantido por pity
/// em [PilgrimChestRoll]).
class DailyChestCard extends StatelessWidget {
  /// Dentro de Gestos de hoje — inset ouro, sem card próprio.
  final bool embedded;

  const DailyChestCard({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final available = progress.dailyChestAvailable;
    final openedToday = progress.dailyChestOpenedToday;
    final lastReward = progress.lastDailyChestReward;
    final showsTodayReward = openedToday && lastReward != null;

    final accent = showsTodayReward
        ? tierColor(lastReward.tier)
        : AppColors.medalGold;

    final row = Row(
      children: [
        _ChestGlyph(accent: accent, glowing: available),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Baú do Dia',
                style: AppTypography.title(
                  size: 14,
                  weight: FontWeight.w800,
                  color: a.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                showsTodayReward
                    ? lastReward.title
                    : (available
                        ? 'Toque para abrir'
                        : 'Complete a missão de hoje para abrir'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: accent.withValues(
                    alpha: showsTodayReward || available ? 0.95 : 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpace.md),
        if (showsTodayReward)
          const CinematicIcon(
            glyph: CinematicGlyph.check,
            size: 22,
            accent: AppColors.teal,
            framed: false,
          )
        else if (available)
          CountBadge('Abrir', filled: true, color: accent)
        else
          CinematicIcon(
            glyph: CinematicGlyph.lock,
            size: 20,
            accent: accent.withValues(alpha: 0.85),
            framed: false,
          ),
      ],
    );

    final body = embedded
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: available ? 0.16 : 0.1),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: accent.withValues(alpha: available ? 0.55 : 0.4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: row,
            ),
          )
        : GlassCard(
            padding: AppMetrics.cardPadding,
            tint: accent,
            child: row,
          );

    return GestureDetector(
      onTap: available ? () => _open(context) : null,
      child: body,
    );
  }

  void _open(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.82),
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => const _DailyChestSheet(),
    );
  }
}

class _ChestGlyph extends StatelessWidget {
  final Color accent;
  final bool glowing;

  const _ChestGlyph({required this.accent, required this.glowing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: glowing ? 0.22 : 0.14),
        border: Border.all(
          color: accent.withValues(alpha: glowing ? 0.75 : 0.55),
        ),
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: CinematicIcon(
          glyph: CinematicGlyph.gem,
          size: 22,
          accent: accent,
          framed: false,
        ),
      ),
    );
  }
}

class _DailyChestSheet extends StatefulWidget {
  const _DailyChestSheet();

  @override
  State<_DailyChestSheet> createState() => _DailyChestSheetState();
}

class _DailyChestSheetState extends State<_DailyChestSheet>
    with TickerProviderStateMixin {
  late final AnimationController _anticipation;
  late final AnimationController _reveal;
  late final AnimationController _pulse;
  bool _opening = false;
  PilgrimChestReward? _reward;

  @override
  void initState() {
    super.initState();
    _anticipation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_open());
    });
  }

  @override
  void dispose() {
    _anticipation.dispose();
    _reveal.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_opening || _reward != null) return;
    setState(() => _opening = true);
    HapticFeedback.mediumImpact();
    unawaited(SoundService.instance.playStreak());
    await _anticipation.forward();
    if (!mounted) return;
    final progress = context.read<ProgressService>();
    final reward = await progress.openDailyChest();
    if (!mounted) return;
    final isTopTier = reward.tier == PilgrimMedalTier.gold ||
        reward.tier == PilgrimMedalTier.mirra;
    HapticFeedback.heavyImpact();
    if (isTopTier) unawaited(SoundService.instance.playComplete());
    setState(() {
      _reward = reward;
      _opening = false;
    });
    _reveal.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final media = MediaQuery.of(context);
    final bottom = media.viewPadding.bottom;
    final minHeight = media.size.height * 0.56;
    final reward = _reward;
    final accent = reward != null ? tierColor(reward.tier) : AppColors.medalGold;
    final glyph = reward?.glyph ?? CinematicGlyph.gem;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(
                color: accent.withValues(alpha: 0.8),
                width: 1.5,
              ),
              color: AppColors.night.withValues(alpha: 0.96),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: reward != null ? 0.4 : 0.22),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              child: Stack(
                children: [
                  if (reward != null)
                    const Positioned.fill(
                      child: ConfettiOverlay(active: true, cinematic: true),
                    ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: Listenable.merge(
                          [_pulse, _reveal, _anticipation],
                        ),
                        builder: (context, _) {
                          final breath =
                              (math.sin(_pulse.value * math.pi * 2) + 1) / 2;
                          final intensity = reward != null
                              ? Curves.easeOut.transform(_reveal.value)
                              : 0.45 + _anticipation.value * 0.35;
                          return CustomPaint(
                            painter: MedalSpotlightPainter(
                              accent: accent,
                              breath: breath,
                              intensity: intensity,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 20, 24, 28 + bottom),
                    child: SizedBox(
                      height: minHeight,
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.pill),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(height: 28),
                                Text(
                                  reward == null
                                      ? 'BAÚ DO DIA'
                                      : _headline(reward.tier),
                                  style: AppTypography.label(
                                    size: 11,
                                    letterSpacing: 2.0,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                AnimatedBuilder(
                                  animation: Listenable.merge(
                                    [_anticipation, _reveal, _pulse],
                                  ),
                                  builder: (context, _) {
                                    final wobble = _opening
                                        ? math.sin(
                                              _anticipation.value *
                                                  math.pi *
                                                  7,
                                            ) *
                                            (1 - _anticipation.value) *
                                            0.16
                                        : 0.0;
                                    final breath = (math.sin(
                                              _pulse.value * math.pi * 2,
                                            ) +
                                            1) /
                                        2;
                                    final revealScale = reward != null
                                        ? Curves.elasticOut
                                            .transform(_reveal.value)
                                        : 1.0;
                                    return Transform.rotate(
                                      angle: wobble,
                                      child: Transform.scale(
                                        scale: 0.86 + 0.14 * revealScale,
                                        child: MedalHeroEmblem(
                                          accent: accent,
                                          glyph: glyph,
                                          size: 72,
                                          breath: breath,
                                          glowing: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 22),
                                if (reward == null) ...[
                                  Text(
                                    'A constância de hoje guarda uma recompensa.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.title(
                                      size: 20,
                                      weight: FontWeight.w800,
                                      color: a.text,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _opening
                                        ? 'Abrindo…'
                                        : 'A revelação começa agora.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.body(
                                      size: 14,
                                      height: 1.45,
                                      color: a.textMuted(0.62),
                                    ),
                                  ),
                                  const Spacer(),
                                ] else ...[
                                  FadeTransition(
                                    opacity: _reveal,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: accent.withValues(
                                              alpha: 0.18,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppRadii.pill,
                                            ),
                                            border: Border.all(
                                              color: accent.withValues(
                                                alpha: 0.55,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            tierLabel(reward.tier)
                                                .toUpperCase(),
                                            style: AppTypography.label(
                                              size: 10,
                                              letterSpacing: 1.4,
                                              color: accent,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          reward.title,
                                          textAlign: TextAlign.center,
                                          style: AppTypography.display(
                                            size: 26,
                                            weight: FontWeight.w900,
                                            color: a.text,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          reward.message,
                                          textAlign: TextAlign.center,
                                          style: AppTypography.body(
                                            size: 14,
                                            height: 1.5,
                                            color: a.textMuted(0.65),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  FadeTransition(
                                    opacity: _reveal,
                                    child: CopperCta(
                                      label: 'Continuar a jornada',
                                      onTap: () => Navigator.pop(context),
                                      trailing: CinematicGlyph.path,
                                      dense: true,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _headline(PilgrimMedalTier tier) => tier == PilgrimMedalTier.mirra
      ? 'RARÍSSIMO'
      : '${tierLabel(tier).toUpperCase()} DE HOJE';
}
