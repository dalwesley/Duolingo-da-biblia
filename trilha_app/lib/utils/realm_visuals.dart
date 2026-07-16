import 'package:flutter/material.dart';
import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';

/// Atmosfera visual de cada reino — alinhada à família olive/gold/clay/slate.
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
            sky: [Color(0xFF0B1A14), Color(0xFF1E3D32), Color(0xFF2A4A3A)],
            accent: AppColors.accent,
            glow: AppColors.primaryLight,
            glyph: CinematicGlyph.book,
            eyebrow: 'A PROMESSA',
            tagline: 'Da criação aos profetas — o caminho da aliança',
          ),
        TrailRealm.novoTestamento => const RealmVisuals(
            sky: [Color(0xFF1A100E), Color(0xFF3A2218), Color(0xFF4A2E20)],
            accent: AppColors.clay,
            glow: AppColors.clayDeep,
            glyph: CinematicGlyph.heart,
            eyebrow: 'O CUMPRIMENTO',
            tagline: 'Cristo, a Igreja e a esperança que não falha',
          ),
        TrailRealm.vidaCrista => const RealmVisuals(
            sky: [Color(0xFF0A1614), Color(0xFF12302A), Color(0xFF1A4038)],
            accent: AppColors.cedar,
            glow: AppColors.cedarDeep,
            glyph: CinematicGlyph.seed,
            eyebrow: 'O CAMINHAR',
            tagline: 'Discipulado, oração e a história da fé',
          ),
        TrailRealm.teologia => const RealmVisuals(
            sky: [Color(0xFF0C1218), Color(0xFF1A2430), Color(0xFF243040)],
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
