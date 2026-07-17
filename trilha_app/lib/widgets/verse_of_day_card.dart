import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/daily_scripture.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';

/// Versículo do dia — âncora silenciosa da caminhada.
class VerseOfDayCard extends StatelessWidget {
  final VoidCallback? onOpen;

  const VerseOfDayCard({super.key, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final (text, ref) = DailyScripture.today();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: GlassCard(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyph.lamp,
                    size: 22,
                    accent: AppColors.accent,
                    glowing: false,
                    framed: false,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PALAVRA DE HOJE',
                    style: AppTypography.label(
                      size: 10,
                      color: AppColors.accent.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '“$text”',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: a.text,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                ref,
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: a.textMuted(0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
