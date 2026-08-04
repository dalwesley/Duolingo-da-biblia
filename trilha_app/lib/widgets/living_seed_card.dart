import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/spiritual_growth.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Marcos da sequência diária — deixa claro o que é e o próximo passo.
class LivingSeedCard extends StatelessWidget {
  /// Quando true, destaca brilho de missão perfeita (ex.: pós-celebração).
  final bool perfectRecent;
  final bool compact;

  const LivingSeedCard({
    super.key,
    this.perfectRecent = false,
    this.compact = false,
  });

  CinematicGlyph _glyph(GrowthStage stage) {
    return switch (stage) {
      GrowthStage.seed => CinematicGlyph.seed,
      GrowthStage.sprout => CinematicGlyph.flame,
      GrowthStage.sapling => CinematicGlyph.path,
      GrowthStage.olive => CinematicGlyph.tree,
      GrowthStage.lamp => CinematicGlyph.lamp,
    };
  }

  /// Acento de urgência sem vermelho de erro — terra / areia.
  static const _dustAccent = Color(0xFFC4A070);

  Color _accent(SpiritualGrowth growth) {
    return switch (growth.mood) {
      SeedMood.atRisk => _dustAccent,
      SeedMood.perfectGlow => AppColors.accent,
      SeedMood.frozen => AppColors.ice,
      SeedMood.thriving => AppColors.ember,
      SeedMood.calm => switch (growth.stage) {
          GrowthStage.seed => AppColors.cedar,
          GrowthStage.sprout => AppColors.ember,
          GrowthStage.sapling => AppColors.accent,
          GrowthStage.olive => AppColors.cedar,
          GrowthStage.lamp => AppColors.accent,
        },
    };
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final growth = SpiritualGrowth.fromSignals(
      streak: progress.streak,
      atRisk: progress.isStreakAtRisk,
      freezeAvailable: progress.streakFreezeAvailable,
      perfectRecent: perfectRecent,
    );
    if (compact) return _compact(context, progress, growth);
    return _profile(context, progress, growth);
  }

  Widget _compact(
    BuildContext context,
    ProgressService progress,
    SpiritualGrowth growth,
  ) {
    final a = Appearance.of(context);
    final accent = _accent(growth);
    return GlassCard(
      padding: AppMetrics.cardPaddingCompact,
      child: Row(
        children: [
          CinematicIcon(
            glyph: _glyph(growth.stage),
            size: 40,
            accent: accent,
            glowing: growth.glowing,
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
                    weight: FontWeight.w800,
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
                        ? _dustAccent.withValues(alpha: 0.95)
                        : a.textMuted(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (progress.streak > 0)
            Text(
              '${progress.streak}',
              style: AppTypography.display(
                size: 22,
                weight: FontWeight.w900,
                color: accent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _profile(
    BuildContext context,
    ProgressService progress,
    SpiritualGrowth growth,
  ) {
    final a = Appearance.of(context);
    final accent = _accent(growth);
    final next = growth.nextStage;
    final daysLeft = growth.daysToNext;

    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CinematicIcon(
                glyph: _glyph(growth.stage),
                size: 52,
                accent: accent,
                glowing: growth.glowing,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MARCOS DA SEQUÊNCIA',
                      style: AppTypography.label(
                        size: 10,
                        letterSpacing: 1.1,
                        color: a.textMuted(0.55),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      growth.title,
                      style: AppTypography.display(
                        size: 22,
                        weight: FontWeight.w900,
                        color: a.text,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cada dia seguido sobe um marco — '
                      'Semente → Broto → Muda → Oliveira → Lâmpada.',
                      style: AppTypography.body(
                        size: 12,
                        height: 1.35,
                        color: a.textMuted(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${progress.streak}',
                    style: AppTypography.display(
                      size: 26,
                      weight: FontWeight.w900,
                      color: accent,
                      height: 1,
                    ),
                  ),
                  Text(
                    progress.streak == 1 ? 'dia' : 'dias',
                    style: AppTypography.label(
                      size: 10,
                      color: a.textMuted(0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StageTrack(
            current: growth.stage,
            accent: accent,
            glyphFor: _glyph,
          ),
          const SizedBox(height: 14),
          if (growth.mood == SeedMood.atRisk)
            Text(
              growth.subtitle,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w700,
                color: _dustAccent,
              ),
            )
          else if (next != null) ...[
            Text(
              daysLeft == 0
                  ? 'Próximo marco: ${next.label}'
                  : 'Próximo: ${next.label} · faltam $daysLeft '
                      '${daysLeft == 1 ? 'dia' : 'dias'} seguidos',
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w800,
                color: a.text,
              ),
            ),
            const SizedBox(height: 8),
            AppProgressBar(value: growth.progressToNext, color: accent),
          ] else
            Text(
              growth.subtitle,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w700,
                color: accent,
              ),
            ),
        ],
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

    return Row(
      children: [
        for (var i = 0; i < stages.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: i <= currentIndex
                    ? accent.withValues(alpha: 0.7)
                    : a.cardBorder,
              ),
            ),
          _StageNode(
            stage: stages[i],
            glyph: glyphFor(stages[i]),
            reached: i <= currentIndex,
            current: i == currentIndex,
            accent: accent,
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

  const _StageNode({
    required this.stage,
    required this.glyph,
    required this.reached,
    required this.current,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = current
        ? accent
        : reached
            ? accent.withValues(alpha: 0.75)
            : a.textMuted(0.35);

    return Column(
      children: [
        Container(
          width: current ? 36 : 28,
          height: current ? 36 : 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: current
                ? accent.withValues(alpha: 0.2)
                : reached
                    ? accent.withValues(alpha: 0.1)
                    : a.cardFillSoft,
            border: Border.all(
              color: ink,
              width: current ? 2 : 1,
            ),
          ),
          child: Center(
            child: CinematicIcon(
              glyph: glyph,
              size: current ? 18 : 14,
              accent: ink,
              glowing: false,
              framed: false,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          stage.label,
          style: AppTypography.label(
            size: 8,
            letterSpacing: 0.2,
            weight: current ? FontWeight.w900 : FontWeight.w600,
            color: current ? a.text : a.textMuted(reached ? 0.55 : 0.35),
          ),
        ),
        Text(
          stage.shortHint,
          style: AppTypography.label(
            size: 7,
            color: a.textMuted(0.4),
          ),
        ),
      ],
    );
  }
}
