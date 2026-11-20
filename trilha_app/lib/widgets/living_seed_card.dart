import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/spiritual_growth.dart';
import 'cinematic_icon.dart';
import 'relic_panel.dart';
import 'ui_primitives.dart';
import '../l10n/app_language.dart';

/// Marcos da sequência diária — deixa claro o que é e o próximo passo.
class LivingSeedCard extends StatelessWidget {
  /// Quando true, destaca brilho de missão perfeita (ex.: pós-celebração).
  final bool perfectRecent;
  final bool compact;

  /// Se informado, usa este streak (perfil da caravana) em vez do progresso local.
  final int? streak;

  const LivingSeedCard({
    super.key,
    this.perfectRecent = false,
    this.compact = false,
    this.streak,
  });

  CinematicGlyph _glyph(GrowthStage stage) {
    return switch (stage) {
      GrowthStage.seed => CinematicGlyph.seed,
      GrowthStage.sprout => CinematicGlyph.sprout,
      GrowthStage.branch => CinematicGlyph.rise,
      GrowthStage.tree => CinematicGlyph.tree,
      GrowthStage.fruit => CinematicGlyph.gem,
    };
  }

  /// Card da sequência: cor da sequência; risco só quando pode cair hoje;
  /// gelo fica neutro (a geada é do orbe, não do card).
  Color _accent(SpiritualGrowth growth, AppearanceStyle a) {
    return switch (growth.mood) {
      SeedMood.atRisk => AppRoles.risk,
      SeedMood.frozen => a.chrome,
      SeedMood.perfectGlow ||
      SeedMood.thriving ||
      SeedMood.calm => AppRoles.streak,
    };
  }

  @override
  Widget build(BuildContext context) {
    final SpiritualGrowth growth;
    if (streak != null) {
      growth = SpiritualGrowth.fromStreak(streak!);
    } else {
      final progress = context.watch<ProgressService>();
      growth = SpiritualGrowth.fromSignals(
        streak: progress.streak,
        atRisk: progress.isStreakAtRisk,
        freezeAvailable: progress.streakFreezeAvailable,
        perfectRecent: perfectRecent,
      );
    }
    if (compact) return _compact(context, growth);
    return _profile(context, growth);
  }

  Widget _compact(BuildContext context, SpiritualGrowth growth) {
    final a = Appearance.of(context);
    final accent = _accent(growth, a);
    return RelicPanel(
      accent: accent,
      padding: AppMetrics.cardPaddingCompact,
      child: Row(
        children: [
          RelicDisc(
            glyph: _glyph(growth.stage),
            accent: accent,
            size: 48,
            lit: growth.glowing || growth.streak > 0,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  growth.title,
                  style: AppTypography.display(
                    size: 18,
                    color: a.text,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  growth.subtitle,
                  style: AppTypography.body(
                    size: 12,
                    color: growth.mood == SeedMood.atRisk
                        ? AppRoles.risk.withValues(alpha: 0.95)
                        : a.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (growth.streak > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${growth.streak}',
                  style: AppTypography.display(
                    size: 20,
                    weight: FontWeight.w900,
                    color: accent,
                    height: 1,
                  ).copyWith(fontFeatures: const [FontFeature.liningFigures()]),
                ),
                Text(
                  context.l10n.growthDayUnit(growth.streak).trim(),
                  style: AppTypography.label(size: 10, color: a.textFaint),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _profile(BuildContext context, SpiritualGrowth growth) {
    final a = Appearance.of(context);
    final accent = _accent(growth, a);
    final ink = a.ink(accent);
    final next = growth.nextStage;
    final daysLeft = growth.daysToNext;
    final lit = growth.streak > 0;
    final still = MediaQuery.disableAnimationsOf(context);

    String? footer;
    Color footerColor = a.text;
    if (growth.mood == SeedMood.atRisk) {
      footer = growth.subtitle;
      footerColor = AppRoles.risk;
    } else if (next != null) {
      footer = daysLeft == 0
          ? context.l10n.growthNextMilestone(next.label)
          : context.l10n.growthNextIn(next.label, daysLeft);
    }

    return RelicPanel(
      accent: accent,
      glow: lit ? 0.8 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _StageOrb(glyph: _glyph(growth.stage), accent: accent, lit: lit),
              const SizedBox(width: AppSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: still ? 1 : 0, end: 1),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, t, _) => Text(
                            '${(growth.streak * t).round()}',
                            style:
                                AppTypography.display(
                                  size: 46,
                                  weight: FontWeight.w900,
                                  color: ink,
                                  height: 1,
                                ).copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            context.l10n.growthDayUnit(growth.streak).trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(
                              size: 15,
                              weight: FontWeight.w800,
                              color: a.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.profileStatStreak,
                      style: AppTypography.label(
                        size: 11,
                        letterSpacing: 0.6,
                        color: a.textFaint,
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    _StagePill(text: growth.title, accent: ink),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          _StageTrack(current: growth.stage, accent: accent, glyphFor: _glyph),
          if (footer != null) ...[
            const SizedBox(height: AppSpace.md),
            Text(
              footer,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w800,
                color: footerColor,
              ),
            ),
            if (next != null && growth.mood != SeedMood.atRisk) ...[
              const SizedBox(height: 8),
              RelicProgress(value: growth.progressToNext, accent: accent),
            ],
          ],
        ],
      ),
    );
  }
}

/// Estágio atual grande, com brilho que respira.
class _StageOrb extends StatefulWidget {
  final CinematicGlyph glyph;
  final Color accent;
  final bool lit;

  const _StageOrb({
    required this.glyph,
    required this.accent,
    required this.lit,
  });

  @override
  State<_StageOrb> createState() => _StageOrbState();
}

class _StageOrbState extends State<_StageOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.lit || MediaQuery.disableAnimationsOf(context)) {
      _breath.stop();
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 88.0;
    final accent = widget.accent;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _breath,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_breath.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.lit)
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.35 + 0.2 * t),
                        accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              Transform.scale(scale: 1 + 0.04 * t, child: child),
            ],
          );
        },
        child: RelicDisc(
          glyph: widget.glyph,
          accent: accent,
          size: 64,
          lit: widget.lit,
        ),
      ),
    );
  }
}

class _StagePill extends StatelessWidget {
  final String text;
  final Color accent;

  const _StagePill({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        color: accent.withValues(alpha: 0.16),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.title(
          size: 14,
          weight: FontWeight.w900,
          color: accent,
          height: 1.1,
        ),
      ),
    );
  }
}

class _StageTrack extends StatelessWidget {
  final GrowthStage current;
  final Color accent;
  final CinematicGlyph Function(GrowthStage) glyphFor;

  const _StageTrack({
    required this.current,
    required this.accent,
    required this.glyphFor,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final stages = GrowthStage.values;
    final currentIndex = stages.indexOf(current);

    const currentSize = 40.0;
    const restSize = 30.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < stages.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: currentSize / 2 - 2),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: i <= currentIndex ? null : a.cardBorder,
                    gradient: i <= currentIndex
                        ? LinearGradient(
                            colors: [accent.withValues(alpha: 0.55), accent],
                          )
                        : null,
                    boxShadow: i <= currentIndex
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.45),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          _StageNode(
            stage: stages[i],
            glyph: glyphFor(stages[i]),
            reached: i <= currentIndex,
            current: i == currentIndex,
            accent: accent,
            discSize: i == currentIndex ? currentSize : restSize,
            slotHeight: currentSize,
          ),
        ],
      ],
    );
  }
}

class _StageNode extends StatelessWidget {
  final GrowthStage stage;
  final CinematicGlyph glyph;
  final bool reached;
  final bool current;
  final Color accent;
  final double discSize;
  final double slotHeight;

  const _StageNode({
    required this.stage,
    required this.glyph,
    required this.reached,
    required this.current,
    required this.accent,
    required this.discSize,
    required this.slotHeight,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);

    return Column(
      children: [
        SizedBox(
          height: slotHeight,
          width: slotHeight,
          child: Center(
            child: RelicDisc(
              glyph: glyph,
              accent: accent,
              size: discSize,
              lit: reached,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          stage.label,
          style: AppTypography.label(
            size: 10,
            letterSpacing: 0.2,
            weight: current ? FontWeight.w900 : FontWeight.w600,
            color: current
                ? a.ink(accent)
                : reached
                ? a.textSecondary
                : a.textFaint,
          ),
        ),
      ],
    );
  }
}
