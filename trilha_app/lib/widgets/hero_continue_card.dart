import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../cinematic/cinematic_resolver.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/dust_copy.dart';
import '../utils/trail_visuals.dart';
import 'cinematic_backdrop.dart';
import 'cinematic_icon.dart';
import 'hero_card_atmosphere.dart';
import 'ui_primitives.dart';

/// Próxima missão — CTA único. Três faces cinematográficas:
/// gelo à postos · atrasado/empoeirado · em dia.
class HeroContinueCard extends StatefulWidget {
  final Mission? mission;
  final String trailTitle;
  final String trailSlug;
  final String trailColor;
  final VoidCallback? onTap;
  final VoidCallback? onExploreTrails;
  final bool goalMet;
  final bool atRisk;
  final int lampsReady;

  const HeroContinueCard({
    super.key,
    required this.mission,
    required this.trailTitle,
    this.trailSlug = 'genesis-1-11',
    this.trailColor = '#1B3A5C',
    this.onTap,
    this.onExploreTrails,
    this.goalMet = false,
    this.atRisk = false,
    this.lampsReady = 5,
  });

  @override
  State<HeroContinueCard> createState() => _HeroContinueCardState();
}

class _HeroContinueCardState extends State<HeroContinueCard> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _syncTick(widget.atRisk);
  }

  @override
  void didUpdateWidget(covariant HeroContinueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.atRisk != widget.atRisk) {
      _syncTick(widget.atRisk);
    }
  }

  void _syncTick(bool atRisk) {
    _tick?.cancel();
    _tick = null;
    if (!atRisk) return;
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;
    if (mission == null) return _completedState(context);

    final a = Appearance.of(context);
    final visuals = TrailVisuals.forSlug(widget.trailSlug, color: widget.trailColor);
    final trailAccent = visuals.accent;
    final progress = context.watch<ProgressService>();
    final hasFreeze = progress.hasStreakFreeze;
    final mood = resolveHeroCardMood(
      atRisk: widget.atRisk,
      freezeUsedThisWeek: progress.streakFreezeUsedThisWeek,
    );
    final style = HeroCardMoodStyle.of(mood, trailAccent: trailAccent);

    final ctaLabel = switch (mood) {
      HeroCardMood.frozen => 'Retomar caminhada',
      HeroCardMood.dusty => 'Continuar caminhada',
      HeroCardMood.alive => widget.goalMet ? 'Seguir' : 'Entrar',
    };
    final rewardColor = mission.isBoss ? AppColors.sand : style.footer;
    final world = CinematicResolver.ambientForHome(
      trailSlug: widget.trailSlug,
      missionTitle: mission.title,
      missionSlug: mission.slug,
    );

    final countdown = progress.streakRiskCountdown;
    final riskLine = switch (mood) {
      HeroCardMood.frozen =>
        'O gelo cobriu 1 dia nesta semana · sequência preservada',
      HeroCardMood.dusty => DustCopy.heroRiskLine(
          countdown: countdown,
          hasFreeze: hasFreeze,
        ),
      HeroCardMood.alive => null,
    };

    final stepLabel = switch (mood) {
      HeroCardMood.frozen => style.stepLabel,
      HeroCardMood.dusty => style.stepLabel,
      HeroCardMood.alive =>
        widget.goalMet ? 'Mais uma missão' : 'Missão pronta',
    };

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
          border: Border.all(
            color: style.border,
            width: style.borderWidth,
          ),
          boxShadow: [
            ...AppMetrics.cardShadow(elevated: true),
            BoxShadow(
              color: style.glow,
              blurRadius: mood == HeroCardMood.alive ? 14 : 22,
              offset: const Offset(0, 6),
              spreadRadius: mood == HeroCardMood.frozen ? 1 : 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppMetrics.heroRadius - 0.5),
          child: Stack(
            children: [
              Positioned.fill(
                child: HeroCardColorGrade(
                  mood: mood,
                  child: CinematicBackdrop(world: world),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _scrimColors(mood, a.cardFill),
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: HeroCardAtmosphere(mood: mood),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Chip(
                          tone: trailAccent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CinematicIcon(
                                glyph: visuals.glyph,
                                size: 16,
                                accent: trailAccent,
                                glowing: false,
                                framed: false,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.trailTitle.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label(
                                  size: 10,
                                  letterSpacing: 1.1,
                                  color: a.text.withValues(alpha: 0.88),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _Chip(
                          tone: AppColors.accent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CinematicIcon(
                                glyph: CinematicGlyph.lamp,
                                size: 14,
                                accent: AppColors.accent,
                                glowing: false,
                                framed: false,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${widget.lampsReady} LÂMPADAS',
                                style: AppTypography.label(
                                  size: 9,
                                  letterSpacing: 0.9,
                                  color: a.text.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      stepLabel.toUpperCase(),
                      style: AppTypography.label(
                        size: 12,
                        letterSpacing: 1.6,
                        color: style.label,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mission.title,
                      style: AppTypography.display(
                        size: 32,
                        height: 1.1,
                        weight: FontWeight.w900,
                        color: mood == HeroCardMood.dusty
                            ? const Color(0xFFE8DCC8).withValues(alpha: 0.9)
                            : a.text,
                      ),
                    ),
                    if (riskLine != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        riskLine,
                        style: AppTypography.body(
                          size: 13,
                          weight: FontWeight.w700,
                          height: 1.35,
                          color: style.label.withValues(alpha: 0.92),
                        ),
                      ),
                    ] else if (mission.subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        mission.subtitle.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          size: 14,
                          weight: FontWeight.w600,
                          color: a.text.withValues(alpha: 0.72),
                        ),
                      ),
                    ] else if (mission.isBoss) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Boss · menos lâmpadas · mais passos',
                        style: AppTypography.body(
                          size: 14,
                          weight: FontWeight.w700,
                          color: AppColors.sand.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _CtaBar(label: ctaLabel, mood: mood),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        mood == HeroCardMood.dusty
                            ? '+${mission.stepsReward} passos · protege a sequência'
                            : '+${mission.stepsReward} passos · ~3 min',
                        style: AppTypography.body(
                          size: 13,
                          weight: FontWeight.w800,
                          color: rewardColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _scrimColors(HeroCardMood mood, Color cardFill) {
    return switch (mood) {
      HeroCardMood.frozen => [
          AppColors.iceDeep.withValues(alpha: 0.28),
          Colors.black.withValues(alpha: 0.38),
          Color.lerp(cardFill, AppColors.iceDeep, 0.45)!
              .withValues(alpha: 0.9),
        ],
      HeroCardMood.dusty => [
          const Color(0xFF4A3218).withValues(alpha: 0.5),
          const Color(0xFF1A1008).withValues(alpha: 0.55),
          Color.lerp(cardFill, const Color(0xFF120A06), 0.65)!
              .withValues(alpha: 0.94),
        ],
      HeroCardMood.alive => [
          Colors.black.withValues(alpha: 0.14),
          Colors.black.withValues(alpha: 0.36),
          Color.lerp(cardFill, Colors.black, 0.3)!.withValues(alpha: 0.86),
        ],
    };
  }

  Widget _completedState(BuildContext context) {
    final a = Appearance.of(context);
    return GestureDetector(
      onTap: widget.onExploreTrails,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          color: a.cardFill,
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
          boxShadow: AppMetrics.cardShadow(),
        ),
        child: Column(
          children: [
            const CinematicIcon(
              glyph: CinematicGlyph.crown,
              size: 56,
              accent: AppColors.accent,
              glowing: false,
            ),
            const SizedBox(height: 16),
            Text(
              'Trilha concluída',
              style: AppTypography.display(size: 28, color: a.text),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha a próxima e continue aprendendo.',
              textAlign: TextAlign.center,
              style: AppTypography.body(color: a.textMuted(0.6)),
            ),
            if (widget.onExploreTrails != null) ...[
              const SizedBox(height: 20),
              const CopperCta(
                label: 'Explorar trilhas',
                expanded: false,
                onTap: null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CtaBar extends StatelessWidget {
  final String label;
  final HeroCardMood mood;

  const _CtaBar({required this.label, required this.mood});

  @override
  Widget build(BuildContext context) {
    final gradient = switch (mood) {
      HeroCardMood.frozen => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB8E8F5),
            AppColors.ice,
            Color(0xFF3A8AAA),
          ],
        ),
      HeroCardMood.dusty => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8C888),
            Color(0xFFC4A050),
            Color(0xFF8A6830),
          ],
        ),
      HeroCardMood.alive => AppGradients.gold,
    };
    final ink = switch (mood) {
      HeroCardMood.frozen => AppColors.iceDeep,
      HeroCardMood.dusty => AppColors.inkOnAccent,
      HeroCardMood.alive => AppColors.inkOnAccent,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: mood == HeroCardMood.frozen
            ? [
                BoxShadow(
                  color: AppColors.ice.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.cta(size: 16).copyWith(color: ink),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.arrow_forward_rounded,
            size: 20,
            color: ink,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final Widget child;
  final Color? tone;

  const _Chip({required this.child, this.tone});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = tone;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: ink != null
            ? Colors.black.withValues(alpha: 0.35)
            : a.cardFill,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: ink != null
              ? ink.withValues(alpha: 0.55)
              : a.cardBorder,
        ),
      ),
      child: child,
    );
  }
}
