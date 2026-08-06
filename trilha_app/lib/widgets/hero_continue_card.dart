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
/// em risco = poeira + teia · gelo usado = congelado · em dia = vidro limpo.
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
    final walkedToday = progress.walkedToday;
    final mood = resolveHeroCardMood(
      atRisk: widget.atRisk,
      freezeUsedThisWeek: progress.streakFreezeUsedThisWeek,
    );
    final style = HeroCardMoodStyle.of(mood, trailAccent: trailAccent);

    // Em dia: não “Entrar” de novo — reconhece o passo já dado.
    final ctaLabel = switch (mood) {
      HeroCardMood.frozen => 'Retomar caminhada',
      HeroCardMood.dusty => 'Continuar caminhada',
      HeroCardMood.alive => widget.goalMet
          ? 'Avançar'
          : walkedToday
              ? 'Continuar'
              : 'Entrar',
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
      HeroCardMood.alive => widget.goalMet
          ? 'Além da meta'
          : walkedToday
              ? 'Em dia'
              : 'Missão pronta',
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
              blurRadius: switch (mood) {
                HeroCardMood.alive => 28,
                HeroCardMood.frozen => 26,
                HeroCardMood.dusty => 18,
              },
              offset: const Offset(0, 8),
              spreadRadius: switch (mood) {
                HeroCardMood.alive => 0,
                HeroCardMood.frozen => 2,
                HeroCardMood.dusty => 0,
              },
            ),
            if (mood == HeroCardMood.alive)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.08),
                blurRadius: 1,
                offset: const Offset(0, -1),
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
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
              // Camada de vidro — só em dia (frosted glass tint)
              if (mood == HeroCardMood.alive)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.07),
                          Colors.white.withValues(alpha: 0.02),
                          Colors.transparent,
                          AppColors.primaryLight.withValues(alpha: 0.04),
                        ],
                        stops: const [0.0, 0.2, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
              // Gelo / vivo: atmosfera atrás. Dusty sobe por cima do conteúdo.
              if (mood != HeroCardMood.dusty)
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
                          worn: mood == HeroCardMood.dusty,
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
                                  color: a.text.withValues(
                                    alpha: mood == HeroCardMood.dusty
                                        ? 0.68
                                        : 0.88,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _Chip(
                          tone: AppColors.accent,
                          worn: mood == HeroCardMood.dusty,
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
                                  color: a.text.withValues(
                                    alpha: mood == HeroCardMood.dusty
                                        ? 0.7
                                        : 0.9,
                                  ),
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
                        color: switch (mood) {
                          HeroCardMood.dusty =>
                            const Color(0xFFC8B498).withValues(alpha: 0.76),
                          HeroCardMood.frozen =>
                            const Color(0xFFE8F6FC).withValues(alpha: 0.95),
                          HeroCardMood.alive => a.text,
                        },
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
                            : widget.goalMet
                                ? '+${mission.stepsReward} passos · além da meta'
                                : walkedToday
                                    ? '+${mission.stepsReward} passos · fecha a meta'
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
              if (mood == HeroCardMood.dusty)
                Positioned.fill(
                  child: HeroCardAtmosphere(mood: mood),
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
          AppColors.iceDeep.withValues(alpha: 0.35),
          Color.lerp(Colors.black, AppColors.iceDeep, 0.35)!
              .withValues(alpha: 0.48),
          Color.lerp(cardFill, AppColors.iceDeep, 0.55)!
              .withValues(alpha: 0.92),
        ],
      HeroCardMood.dusty => [
          const Color(0xFF3A2410).withValues(alpha: 0.7),
          const Color(0xFF140C06).withValues(alpha: 0.76),
          Color.lerp(cardFill, const Color(0xFF0A0604), 0.82)!
              .withValues(alpha: 0.96),
        ],
      // Scrim mais leve no topo — deixa o vidro / reflexo aparecer
      HeroCardMood.alive => [
          Colors.black.withValues(alpha: 0.06),
          Colors.black.withValues(alpha: 0.28),
          Color.lerp(cardFill, Colors.black, 0.22)!.withValues(alpha: 0.82),
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
            Color(0xFFE0F6FC),
            Color(0xFFB8E8F5),
            AppColors.ice,
            Color(0xFF3A8AAA),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      HeroCardMood.dusty => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB89858),
            Color(0xFF8A6830),
            Color(0xFF5A4018),
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
        border: mood == HeroCardMood.alive
            ? Border.all(color: Colors.white.withValues(alpha: 0.35))
            : mood == HeroCardMood.frozen
                ? Border.all(color: Colors.white.withValues(alpha: 0.45))
                : Border.all(
                    color: const Color(0xFF4A3010).withValues(alpha: 0.65),
                  ),
        boxShadow: switch (mood) {
          HeroCardMood.frozen => [
              BoxShadow(
                color: AppColors.ice.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          HeroCardMood.alive => [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          HeroCardMood.dusty => [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
              BoxShadow(
                color: const Color(0xFF1A1008).withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
        },
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Specular no CTA — reforça leitura de vidro / gelo
          if (mood == HeroCardMood.alive || mood == HeroCardMood.frozen)
            Positioned(
              top: 0,
              left: 16,
              right: 16,
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(
                        alpha: mood == HeroCardMood.frozen ? 0.7 : 0.55,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          if (mood == HeroCardMood.dusty)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF3A2810).withValues(alpha: 0.25),
                      Colors.transparent,
                      const Color(0xFF1A1008).withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),
          Row(
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
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final Widget child;
  final Color? tone;
  final bool worn;

  const _Chip({required this.child, this.tone, this.worn = false});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = tone;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: worn
            ? const Color(0xFF1A1008).withValues(alpha: 0.55)
            : ink != null
                ? Colors.black.withValues(alpha: 0.35)
                : a.cardFill,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: worn
              ? const Color(0xFF6B4A28).withValues(alpha: 0.5)
              : ink != null
                  ? ink.withValues(alpha: 0.55)
                  : a.cardBorder,
        ),
      ),
      child: child,
    );
  }
}
