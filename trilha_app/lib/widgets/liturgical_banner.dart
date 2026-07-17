import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/liturgical_calendar.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.calendar,
            size: 40,
            accent: accent,
            glowing: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moment.title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  moment.subtitle,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: a.text,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Leitura do tempo · ${moment.focusRef}',
                  style: TextStyle(fontSize: 11, color: a.textMuted(0.55)),
                ),
              ],
            ),
          ),
          Icon(Icons.menu_book_rounded, color: accent.withValues(alpha: 0.85), size: 22),
        ],
      ),
    );
  }
}
