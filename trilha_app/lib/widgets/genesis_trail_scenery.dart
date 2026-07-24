import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/genesis_theme.dart';
import 'ui_primitives.dart';

/// Capítulo da trilha — cartão de título sobre o céu contínuo da tela.
class GenesisModuleScenery extends StatelessWidget {
  final GenesisModuleTheme theme;
  final String moduleTitle;
  final int sectionIndex;
  final Widget child;
  final bool isActiveChapter;
  final int? missionsDone;
  final int? missionsTotal;

  const GenesisModuleScenery({
    super.key,
    required this.theme,
    required this.moduleTitle,
    required this.sectionIndex,
    required this.child,
    this.isActiveChapter = false,
    this.missionsDone,
    this.missionsTotal,
  });

  @override
  Widget build(BuildContext context) {
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

  const _ChapterTitleCard({
    required this.title,
    required this.sectionIndex,
    required this.theme,
    required this.highlighted,
    this.missionsDone,
    this.missionsTotal,
  });

  @override
  Widget build(BuildContext context) {
    final done = missionsDone ?? 0;
    final total = missionsTotal ?? 0;
    final pct = total > 0 ? done / total : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(18, highlighted ? 18 : 14, 18, highlighted ? 18 : 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(theme.nodeCurrentBottom, Colors.black, 0.35)!
                .withValues(alpha: highlighted ? 0.72 : 0.55),
            Color.lerp(theme.nodeCurrentTop, theme.nodeCurrentBottom, 0.55)!
                .withValues(alpha: highlighted ? 0.55 : 0.38),
          ],
        ),
        border: Border.all(
          color: highlighted
              ? theme.decorColor.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.12),
          width: highlighted ? 1.4 : 1,
        ),
        boxShadow: [
          if (highlighted)
            BoxShadow(
              color: theme.decorColor.withValues(alpha: 0.22),
              blurRadius: 28,
              offset: const Offset(0, 12),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!highlighted)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CENA ${_roman(sectionIndex)}',
                        style: AppTypography.label(
                          size: 10,
                          weight: FontWeight.w700,
                          letterSpacing: 2.6,
                          color: theme.decorColor.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        title,
                        style: AppTypography.display(
                          size: 24,
                          weight: FontWeight.w600,
                          height: 1.1,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                if (total > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '$done · $total',
                      style: AppTypography.display(
                        size: 18,
                        weight: FontWeight.w500,
                        color: theme.decorColor.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
              ],
            ),
          if (highlighted) ...[
            Text(
              theme.narrative,
              style: AppTypography.body(
                size: 14,
                height: 1.5,
                weight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              theme.verse,
              style: AppTypography.label(
                size: 12,
                weight: FontWeight.w700,
                letterSpacing: 0.3,
                color: theme.decorColor.withValues(alpha: 0.88),
              ),
            ),
            if (total > 0) ...[
              const SizedBox(height: 16),
              AppProgressBar(
                value: pct,
                color: theme.pathActive,
                trackColor: Colors.white.withValues(alpha: 0.1),
              ),
            ],
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
