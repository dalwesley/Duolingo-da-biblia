import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/spiritual_growth.dart';
import 'cinematic_icon.dart';
import 'relic_panel.dart';
import 'ui_primitives.dart';

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
          GrowthStage.branch => AppColors.accent,
          GrowthStage.tree => AppColors.cedar,
          GrowthStage.fruit => AppColors.accent,
        },
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

  Widget _compact(
    BuildContext context,
    SpiritualGrowth growth,
  ) {
    final a = Appearance.of(context);
    final accent = _accent(growth);
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
          if (growth.streak > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${growth.streak}',
                  style: AppTypography.display(
                    size: 22,
                    weight: FontWeight.w900,
                    color: accent,
                    height: 1,
                  ),
                ),
                Text(
                  growth.streak == 1 ? 'dia' : 'dias',
                  style: AppTypography.label(
                    size: 10,
                    color: a.textMuted(0.55),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _profile(
    BuildContext context,
    SpiritualGrowth growth,
  ) {
    final a = Appearance.of(context);
    final accent = _accent(growth);
    final next = growth.nextStage;
    final daysLeft = growth.daysToNext;

    return RelicPanel(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelicChapter(
            title: growth.title,
            whisper: 'Cada dia seguido sobe um marco — '
                'Semente → Broto → Ramo → Árvore → Fruto.',
            accent: accent,
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${growth.streak}',
                  style: AppTypography.display(
                    size: 26,
                    weight: FontWeight.w900,
                    color: accent,
                    height: 1,
                  ),
                ),
                Text(
                  growth.streak == 1 ? 'dia' : 'dias',
                  style: AppTypography.label(
                    size: 10,
                    color: a.textMuted(0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: RelicDisc(
              glyph: _glyph(growth.stage),
              accent: accent,
              size: 64,
              lit: growth.glowing || growth.streak > 0,
            ),
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
            RelicProgress(value: growth.progressToNext, accent: accent),
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

    return Column(
      children: [
        RelicDisc(
          glyph: glyph,
          accent: accent,
          size: current ? 36 : 28,
          lit: reached,
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
