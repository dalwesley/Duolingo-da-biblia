import 'package:flutter/material.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';

/// Glifo e acento por trilha.
///
/// O acento é o **papel da área** da trilha ([AppRoles.areaOldTestament]…):
/// trilha herda a cor da sua área — nada de amarelo (ação/recompensa) nem
/// tons avulsos por trilha. Só o glifo muda de trilha para trilha.
class TrailVisuals {
  final CinematicGlyph glyph;
  final LinearGradient iconGradient;
  final Color accent;
  final Color glow;

  const TrailVisuals({
    required this.glyph,
    required this.iconGradient,
    required this.accent,
    required this.glow,
  });

  static TrailVisuals forTrail(Trail trail) {
    final slugRealm = _realmBySlug[trail.slug];
    final realm = slugRealm ?? TrailRealm.fromId(trail.realmId);
    return _palette(_glyphFor(trail.slug, trail.categoryId), realm);
  }

  /// Home hero / chrome sem o [Trail] completo. [color] fica por
  /// compatibilidade — a cor vem da área, não do hex do conteúdo.
  static TrailVisuals forSlug(
    String slug, {
    String categoryId = '',
    String color = '#1B3A5C',
  }) {
    final realm =
        _realmBySlug[slug] ?? TrailCategory.fromId(categoryId).realm;
    return _palette(_glyphFor(slug, categoryId), realm);
  }

  static CinematicGlyph _glyphFor(String slug, String categoryId) =>
      _glyphBySlug[slug] ??
      switch (categoryId) {
        'pentateuco' => CinematicGlyph.book,
        'historicos-at' => CinematicGlyph.shield,
        'poeticos' => CinematicGlyph.dove,
        'profetas-maiores' => CinematicGlyph.spark,
        'profetas-menores' => CinematicGlyph.star,
        'intertestamentario' => CinematicGlyph.calendar,
        'evangelhos' => CinematicGlyph.heart,
        'historicos-nt' => CinematicGlyph.flame,
        'epistolas' => CinematicGlyph.mail,
        'apocalipse' => CinematicGlyph.crown,
        'discipulado' => CinematicGlyph.seed,
        'oracao' => CinematicGlyph.dove,
        'historia-igreja' => CinematicGlyph.tower,
        'hermeneutica' => CinematicGlyph.search,
        'linguas' => CinematicGlyph.scroll,
        'sistematica' => CinematicGlyph.scroll,
        'cristologia' => CinematicGlyph.heart,
        _ => CinematicGlyph.book,
      };

  static TrailVisuals _palette(CinematicGlyph glyph, TrailRealm realm) {
    final (light, dark) = switch (realm) {
      TrailRealm.antigoTestamento => (
        AppRoles.areaOldTestament,
        AppColors.sandDeep,
      ),
      TrailRealm.novoTestamento => (
        AppRoles.areaNewTestament,
        AppColors.clayDeep,
      ),
      TrailRealm.vidaCrista => (
        AppRoles.areaChristianLife,
        AppColors.cedarDeep,
      ),
      TrailRealm.teologia => (AppRoles.areaTheology, AppColors.slateDeep),
    };
    return TrailVisuals(
      glyph: glyph,
      iconGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [light, dark],
      ),
      accent: light,
      glow: dark,
    );
  }

  static const Map<String, CinematicGlyph> _glyphBySlug = {
    'genesis-1-11': CinematicGlyph.book,
    'exodo': CinematicGlyph.mountain,
    'evangelhos': CinematicGlyph.heart,
    'atos': CinematicGlyph.flame,
    'apocalipse': CinematicGlyph.crown,
    'hebraico': CinematicGlyph.scroll,
    'grego': CinematicGlyph.scroll,
    'romanos': CinematicGlyph.scales,
  };

  /// Trilhas conhecidas sem o [Trail] em mãos (Home, onboarding).
  static const Map<String, TrailRealm> _realmBySlug = {
    'genesis-1-11': TrailRealm.antigoTestamento,
    'exodo': TrailRealm.antigoTestamento,
    'evangelhos': TrailRealm.novoTestamento,
    'atos': TrailRealm.novoTestamento,
    'apocalipse': TrailRealm.novoTestamento,
    'romanos': TrailRealm.novoTestamento,
    'hebraico': TrailRealm.teologia,
    'grego': TrailRealm.teologia,
  };
}
