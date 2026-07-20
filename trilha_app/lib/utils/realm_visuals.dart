import 'package:flutter/material.dart';
import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';

/// Atmosfera visual de cada reino — cedro/cobre/clay/slate.
class RealmVisuals {
  final List<Color> sky;
  final Color accent;
  final Color glow;
  final CinematicGlyph glyph;
  final String eyebrow;
  final String tagline;

  const RealmVisuals({
    required this.sky,
    required this.accent,
    required this.glow,
    required this.glyph,
    required this.eyebrow,
    required this.tagline,
  });

  static RealmVisuals of(TrailRealm realm) => switch (realm) {
        TrailRealm.antigoTestamento => const RealmVisuals(
            sky: [Color(0xFF0A1612), Color(0xFF152820), Color(0xFF243F36)],
            accent: AppColors.accent,
            glow: AppColors.primaryLight,
            glyph: CinematicGlyph.book,
            eyebrow: 'A PROMESSA',
            tagline: 'Da criação aos profetas — o caminho da aliança',
          ),
        TrailRealm.novoTestamento => const RealmVisuals(
            sky: [Color(0xFF18100E), Color(0xFF342018), Color(0xFF443028)],
            accent: AppColors.clay,
            glow: AppColors.clayDeep,
            glyph: CinematicGlyph.heart,
            eyebrow: 'O CUMPRIMENTO',
            tagline: 'Cristo, a Igreja e a esperança que não falha',
          ),
        TrailRealm.vidaCrista => const RealmVisuals(
            sky: [Color(0xFF0A1412), Color(0xFF102820), Color(0xFF183830)],
            accent: AppColors.cedar,
            glow: AppColors.cedarDeep,
            glyph: CinematicGlyph.seed,
            eyebrow: 'O CAMINHAR',
            tagline: 'Discipulado, oração e a história da fé',
          ),
        TrailRealm.teologia => const RealmVisuals(
            sky: [Color(0xFF0C1016), Color(0xFF182028), Color(0xFF222C38)],
            accent: AppColors.slate,
            glow: AppColors.slateDeep,
            glyph: CinematicGlyph.scroll,
            eyebrow: 'O FUNDAMENTO',
            tagline: 'Hermenêutica, línguas e a doutrina da fé',
          ),
      };

  LinearGradient get skyGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: sky,
      );
}
