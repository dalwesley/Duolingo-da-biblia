import 'package:flutter/material.dart';
import '../l10n/l10n_global.dart';
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
    TrailRealm.antigoTestamento => RealmVisuals(
      accent: AppRoles.areaOldTestament,
      glow: AppColors.sandDeep,
      glyph: CinematicGlyph.book,
      eyebrow: L10n.current.realmEyebrowAntigoTestamento,
      tagline: L10n.current.realmTaglineAntigoTestamento,
    ),
    TrailRealm.novoTestamento => RealmVisuals(
      accent: AppRoles.areaNewTestament,
      glow: AppColors.clayDeep,
      glyph: CinematicGlyph.heart,
      eyebrow: L10n.current.realmEyebrowNovoTestamento,
      tagline: L10n.current.realmTaglineNovoTestamento,
    ),
    TrailRealm.vidaCrista => RealmVisuals(
      accent: AppRoles.areaChristianLife,
      glow: AppColors.cedarDeep,
      glyph: CinematicGlyph.seed,
      eyebrow: L10n.current.realmEyebrowVidaCrista,
      tagline: L10n.current.realmTaglineVidaCrista,
    ),
    TrailRealm.teologia => RealmVisuals(
      accent: AppRoles.areaTheology,
      glow: AppColors.slateDeep,
      glyph: CinematicGlyph.scroll,
      eyebrow: L10n.current.realmEyebrowTeologia,
      tagline: L10n.current.realmTaglineTeologia,
    ),
  };
}
