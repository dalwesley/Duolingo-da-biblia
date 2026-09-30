import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/genesis_theme.dart';
import 'ui_primitives.dart';
import 'stage_plate.dart';

/// Capítulo da trilha — cartão de título sobre o céu contínuo da tela.
class GenesisModuleScenery extends StatelessWidget {
  final GenesisModuleTheme theme;
  final String moduleTitle;
  final int sectionIndex;
  final Widget child;
  final bool isActiveChapter;
  final int? missionsDone;
  final int? missionsTotal;
  final Color? modeAccent;

  const GenesisModuleScenery({
    super.key,
    required this.theme,
    required this.moduleTitle,
    required this.sectionIndex,
    required this.child,
    this.isActiveChapter = false,
    this.missionsDone,
    this.missionsTotal,
    this.modeAccent,
  });

  @override
  Widget build(BuildContext context) {
    final accent = modeAccent ?? AppRoles.chrome;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ChapterTitleCard(
            title: moduleTitle,
            sectionIndex: sectionIndex,
            theme: theme,
            highlighted: isActiveChapter,
            missionsDone: missionsDone,
            missionsTotal: missionsTotal,
            accent: accent,
          ),
          SizedBox(height: isActiveChapter ? 28 : 18),
          child,
        ],
      ),
    );
  }
}

/// Cartão de capítulo — mesma linguagem visual dos TrailCards que funcionam.
class _ChapterTitleCard extends StatelessWidget {
  final String title;
  final int sectionIndex;
  final GenesisModuleTheme theme;
  final bool highlighted;
  final int? missionsDone;
  final int? missionsTotal;
  final Color accent;

  const _ChapterTitleCard({
    required this.title,
    required this.sectionIndex,
    required this.theme,
    required this.highlighted,
    this.missionsDone,
    this.missionsTotal,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final done = missionsDone ?? 0;
    final total = missionsTotal ?? 0;
    final pct = total > 0 ? done / total : 0.0;
    final onSky = DifficultyVisuals.onSky(accent);
    final a = Appearance.of(context);

    return AnimatedContainer(
      duration: AppMotion.gentle,
      curve: AppMotion.enter,
      padding: EdgeInsets.fromLTRB(
        22,
        highlighted ? 20 : 16,
        22,
        highlighted ? 20 : 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(StagePlate.radius),
        // Painel do visual atual (não o noturno fixo), translúcido sobre o céu.
        color: a.cardFill.withValues(alpha: highlighted ? 0.78 : 0.55),
        border: Border.all(
          color: highlighted
              ? AppMetrics.accentBorder(color: accent, alpha: 0.55)
              : a.cardBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.trailsStage(_roman(sectionIndex)),
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w700,
              color: a.textFaint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.display(
              size: highlighted ? 24 : 20,
              weight: FontWeight.w600,
              height: 1.12,
              color: highlighted ? a.text : a.textSecondary,
            ),
          ),
          if (highlighted) ...[
            const SizedBox(height: 12),
            Text(
              theme.narrative,
              style: AppTypography.body(
                size: 14,
                height: 1.5,
                weight: FontWeight.w500,
                color: a.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              theme.verse,
              style: AppTypography.verse(
                size: 16,
                height: 1.4,
                color: a.text,
              ),
            ),
            if (total > 0) ...[
              const SizedBox(height: 16),
              AppProgressBar(
                value: pct,
                color: onSky,
                trackColor: a.progressTrack,
                height: 6,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.trailsScenesOf(done, total),
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w600,
                  color: a.textFaint,
                ),
              ),
            ],
          ] else if (total > 0) ...[
            const SizedBox(height: 8),
            Text(
              done >= total
                  ? context.l10n.trailsCleared
                  : context.l10n.trailsDoneOfTotal(done, total),
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w600,
                color: onSky.withValues(alpha: 0.55),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _roman(int n) {
    const map = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
    if (n >= 1 && n <= map.length) return map[n - 1];
    return '$n';
  }
}
