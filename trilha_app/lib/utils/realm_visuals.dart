import 'package:flutter/material.dart';
import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';

/// Identidade visual de cada reino — acento/glow/selo (céu vem da Home).
class RealmVisuals {
  final Color accent;
  final Color glow;
  final CinematicGlyph glyph;
  final String eyebrow;
  final String tagline;

  const RealmVisuals({
    required this.accent,
    required this.glow,
    required this.glyph,
    required this.eyebrow,
    required this.tagline,
  });

  static RealmVisuals of(TrailRealm realm) => switch (realm) {
        TrailRealm.antigoTestamento => const RealmVisuals(
            accent: AppColors.accent,
            glow: AppColors.primaryLight,
            glyph: CinematicGlyph.book,
            eyebrow: 'A PROMESSA',
            tagline: 'Da criação aos profetas — o caminho da aliança',
          ),
        TrailRealm.novoTestamento => const RealmVisuals(
            accent: AppColors.clay,
            glow: AppColors.clayDeep,
            glyph: CinematicGlyph.heart,
            eyebrow: 'O CUMPRIMENTO',
            tagline: 'Cristo, a Igreja e a esperança que não falha',
          ),
        TrailRealm.vidaCrista => const RealmVisuals(
            accent: AppColors.cedar,
            glow: AppColors.cedarDeep,
            glyph: CinematicGlyph.seed,
            eyebrow: 'O CAMINHAR',
            tagline: 'Discipulado, oração e a história da fé',
          ),
        TrailRealm.teologia => const RealmVisuals(
            accent: AppColors.slate,
            glow: AppColors.slateDeep,
            glyph: CinematicGlyph.scroll,
            eyebrow: 'O FUNDAMENTO',
            tagline: 'Hermenêutica, línguas e a doutrina da fé',
          ),
      };
}
