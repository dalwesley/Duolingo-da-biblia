import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/liturgical_calendar.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Banner sazonal — só aparece nos tempos fortes.
class LiturgicalBanner extends StatelessWidget {
  final VoidCallback? onOpenBible;

  const LiturgicalBanner({super.key, this.onOpenBible});

  @override
  Widget build(BuildContext context) {
    final moment = LiturgicalCalendar.momentFor();
    if (moment.season == LiturgicalSeason.ordinary) {
      return const SizedBox.shrink();
    }

    final a = Appearance.of(context);
    final accent = AppTheme.parseHex(moment.accentHex);

    return GlassCard(
      onTap: onOpenBible,
      padding: AppMetrics.cardPadding,
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.calendar,
            size: 40,
            accent: accent,
            glowing: false,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(moment.title, color: accent),
                const SizedBox(height: 2),
                Text(
                  moment.subtitle,
                  style: AppTypography.display(
                    size: 18,
                    weight: FontWeight.w700,
                    color: a.text,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  'Leitura do tempo · ${moment.focusRef}',
                  style: AppTypography.body(
                    size: 11,
                    color: a.textMuted(0.55),
                  ),
                ),
              ],
            ),
          ),
          CinematicIcon(
            glyph: CinematicGlyph.book,
            size: 22,
            accent: accent.withValues(alpha: 0.85),
            framed: false,
          ),
        ],
      ),
    );
  }
}
