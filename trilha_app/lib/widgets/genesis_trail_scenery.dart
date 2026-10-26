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

  /// Pintura da trilha, no card da etapa em curso.
  final String? art;

  /// Marca no canto do cartão da etapa (o selo de personagem dela).
  final Widget? badge;

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
    this.art,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final accent = modeAccent ?? AppRoles.chrome;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _ChapterTitleCard(
              title: moduleTitle,
              sectionIndex: sectionIndex,
              theme: theme,
              highlighted: isActiveChapter,
              missionsDone: missionsDone,
              missionsTotal: missionsTotal,
              accent: accent,
              art: art,
              badge: badge,
            ),
          ),
          SizedBox(height: isActiveChapter ? 28 : 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: child,
          ),
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
  final String? art;
  final Widget? badge;

  const _ChapterTitleCard({
    required this.title,
    required this.sectionIndex,
    required this.theme,
    required this.highlighted,
    this.missionsDone,
    this.missionsTotal,
    required this.accent,
    this.art,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final done = missionsDone ?? 0;
    final total = missionsTotal ?? 0;
    final pct = total > 0 ? done / total : 0.0;
    final onSky = DifficultyVisuals.onSky(accent);
    final a = Appearance.of(context);
    final morning = a.look == AppearanceLook.morning;
    final veil = morning ? const Color(0xFFF7FBFE) : a.cardFill;
    final veilAlphas = morning
        ? const [0.46, 0.20, 0.04]
        : const [0.72, 0.58, 0.46];
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
                ],
              ),
            ),
            if (badge != null) ...[const SizedBox(width: AppSpace.md), badge!],
          ],
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
            style: AppTypography.verse(size: 16, height: 1.4, color: a.text),
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
              color: onSky,
            ),
          ),
        ],
      ],
    );

    return AnimatedContainer(
      duration: AppMotion.gentle,
      curve: AppMotion.enter,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(StagePlate.radius),
        color: a.cardFill,
        border: Border.all(
          color: highlighted
              ? AppMetrics.accentBorder(color: accent, alpha: 0.55)
              : a.cardBorder,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(StagePlate.radius),
        child: Stack(
          children: [
            if (art != null) ...[
              Positioned.fill(
                child: Builder(
                  builder: (context) {
                    final dpr = MediaQuery.devicePixelRatioOf(context);
                    final cacheW = (MediaQuery.sizeOf(context).width * dpr)
                        .round();
                    return Image.asset(
                      art!,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      cacheWidth: cacheW,
                      cacheHeight: (120 * dpr).round(),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        veil.withValues(alpha: veilAlphas[0]),
                        veil.withValues(alpha: veilAlphas[1]),
                        veil.withValues(alpha: veilAlphas[2]),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                highlighted ? 20 : 16,
                22,
                highlighted ? 20 : 16,
              ),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  static String _roman(int n) {
    const map = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
    if (n >= 1 && n <= map.length) return map[n - 1];
    return '$n';
  }
}
