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
import 'ui_primitives.dart';

/// Baú do Dia — recompensa cosmética variável, 1x/dia, ao completar a
/// missão de hoje. Nunca dá passos/XP: não compete com o Cofre de medalhas
/// (que fica intocado como conquista de longo prazo). A incerteza é só de
/// apresentação — a recompensa em si sempre vem (piso garantido por pity
/// em [PilgrimChestRoll]).
class DailyChestCard extends StatelessWidget {
  const DailyChestCard({super.key});

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
        : (available ? AppColors.medalGold : a.textMuted(0.35));

    return GestureDetector(
      onTap: available ? () => _open(context) : null,
      child: GlassCard(
        padding: AppMetrics.cardPadding,
        child: Row(
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
                      color: showsTodayReward || available
                          ? accent
                          : a.textMuted(0.55),
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
                accent: a.textMuted(0.4),
                framed: false,
              ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      isScrollControlled: true,
      enableDrag: false,
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
        color: accent.withValues(alpha: glowing ? 0.18 : 0.08),
        border: Border.all(color: accent.withValues(alpha: glowing ? 0.7 : 0.3)),
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
  bool _opening = false;
  PilgrimChestReward? _reward;

  @override
  void initState() {
    super.initState();
    _anticipation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _anticipation.dispose();
    _reveal.dispose();
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
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final reward = _reward;
    final accent = reward != null ? tierColor(reward.tier) : AppColors.medalGold;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, bottom + 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: accent.withValues(alpha: 0.8), width: 1.5),
              color: AppColors.night.withValues(alpha: 0.94),
              boxShadow: reward != null
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              child: Stack(
                children: [
                  if (reward != null)
                    const Positioned.fill(
                      child: ConfettiOverlay(active: true, cinematic: true),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          reward == null ? 'BAÚ DO DIA' : _headline(reward.tier),
                          style: AppTypography.label(
                            size: 11,
                            letterSpacing: 2.0,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 22),
                        GestureDetector(
                          onTap: reward == null ? _open : null,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_anticipation, _reveal]),
                            builder: (context, _) {
                              final wobble = _opening
                                  ? math.sin(_anticipation.value * math.pi * 6) *
                                      (1 - _anticipation.value) *
                                      0.18
                                  : 0.0;
                              final scale = reward != null
                                  ? Curves.elasticOut.transform(_reveal.value)
                                  : 1.0;
                              return Transform.rotate(
                                angle: wobble,
                                child: Transform.scale(
                                  scale: 0.7 + 0.3 * scale,
                                  child: _ChestGlyph(
                                    accent: accent,
                                    glowing: reward != null || _opening,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (reward == null) ...[
                          Text(
                            _opening ? 'Abrindo…' : 'Toque no baú para abrir',
                            textAlign: TextAlign.center,
                            style: AppTypography.body(
                              size: 14,
                              color: a.textMuted(0.62),
                            ),
                          ),
                        ] else ...[
                          FadeTransition(
                            opacity: _reveal,
                            child: Column(
                              children: [
                                Text(
                                  reward.title,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.display(
                                    size: 24,
                                    weight: FontWeight.w900,
                                    color: a.text,
                                  ),
                                ),
                                const SizedBox(height: 10),
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
                          const SizedBox(height: 24),
                          CopperCta(
                            label: 'Continuar a jornada',
                            onTap: () => Navigator.pop(context),
                            trailing: CinematicGlyph.path,
                            dense: true,
                          ),
                        ],
                      ],
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
