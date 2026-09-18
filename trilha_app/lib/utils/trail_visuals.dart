import 'package:flutter/material.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';

/// Glifos e acentos por trilha — família oceano/açafrão/clay/slate.
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
    final specific = _bySlug[trail.slug];
    if (specific != null) return specific;
    return _byCategory(trail.categoryId, trail.color);
  }

  /// Home hero / chrome sem o [Trail] completo.
  static TrailVisuals forSlug(
    String slug, {
    String categoryId = '',
    String color = '#1B3A5C',
  }) {
    final specific = _bySlug[slug];
    if (specific != null) return specific;
    return _byCategory(categoryId, color);
  }

  static TrailVisuals _byCategory(String categoryId, String hexColor) {
    final accent = _parseColor(hexColor) ?? AppColors.primaryLight;
    return switch (categoryId) {
      'pentateuco' => _palette(CinematicGlyph.book, AppColors.sand, AppColors.sandDeep),
      'historicos-at' => _palette(CinematicGlyph.shield, AppColors.sand, AppColors.sandDeep),
      'poeticos' => _palette(CinematicGlyph.dove, AppColors.sand, AppColors.sandDeep),
      'profetas-maiores' => _palette(CinematicGlyph.spark, AppColors.ember, AppColors.emberDeep),
      'profetas-menores' => _palette(CinematicGlyph.star, AppColors.sand, AppColors.sandDeep),
      'intertestamentario' => _palette(CinematicGlyph.calendar, AppColors.sand, AppColors.sandDeep),
      'evangelhos' => _palette(CinematicGlyph.heart, AppColors.clay, AppColors.clayDeep),
      'historicos-nt' => _palette(CinematicGlyph.flame, AppColors.ember, AppColors.emberDeep),
      'epistolas' => _palette(CinematicGlyph.mail, AppColors.clay, AppColors.clayDeep),
      'apocalipse' => _palette(CinematicGlyph.crown, AppColors.ember, AppColors.emberDeep),
      'discipulado' => _palette(CinematicGlyph.seed, AppColors.accent, AppColors.accentDark),
      'oracao' => _palette(CinematicGlyph.dove, AppColors.sand, AppColors.sandDeep),
      'historia-igreja' => _palette(CinematicGlyph.tower, AppColors.sand, AppColors.sandDeep),
      'hermeneutica' => _palette(CinematicGlyph.search, AppColors.sand, AppColors.sandDeep),
      'linguas' => _palette(CinematicGlyph.scroll, AppColors.sand, AppColors.sandDeep),
      'sistematica' => _palette(CinematicGlyph.scroll, AppColors.sand, AppColors.sandDeep),
      'cristologia' => _palette(CinematicGlyph.heart, AppColors.clay, AppColors.clayDeep),
      _ => _palette(CinematicGlyph.book, accent, AppColors.primary),
    };
  }

  static TrailVisuals _palette(CinematicGlyph glyph, Color light, Color dark) {
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

  static Color? _parseColor(String hex) {
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    if (value.length != 8) return null;
    return Color(int.parse(value, radix: 16));
  }

  static final Map<String, TrailVisuals> _bySlug = {
    'genesis-1-11': _palette(CinematicGlyph.book, AppColors.accent, AppColors.accentDark),
    'exodo': _palette(CinematicGlyph.mountain, AppColors.sand, AppColors.sandDeep),
    'evangelhos': _palette(CinematicGlyph.heart, AppColors.clay, AppColors.clayDeep),
    'atos': _palette(CinematicGlyph.flame, AppColors.ember, AppColors.emberDeep),
    'apocalipse': _palette(CinematicGlyph.crown, AppColors.ember, AppColors.emberDeep),
    'hebraico': _palette(CinematicGlyph.scroll, AppColors.sand, AppColors.sandDeep),
    'grego': _palette(CinematicGlyph.scroll, AppColors.sand, AppColors.sandDeep),
    'romanos': _palette(CinematicGlyph.scales, AppColors.clay, AppColors.clayDeep),
  };
}
