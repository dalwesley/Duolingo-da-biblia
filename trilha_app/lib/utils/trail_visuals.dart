import 'package:flutter/material.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';

/// Glifos e gradientes por trilha — família oceano/açafrão/clay/slate.
class TrailVisuals {
  final CinematicGlyph glyph;
  final LinearGradient iconGradient;
  final LinearGradient cardGradient;
  final Color accent;
  final Color glow;

  const TrailVisuals({
    required this.glyph,
    required this.iconGradient,
    required this.cardGradient,
    required this.accent,
    required this.glow,
  });

  /// Compat — preferir [glyph] + [CinematicIcon].
  IconData get icon => Icons.menu_book_rounded;

  static TrailVisuals forTrail(Trail trail) {
    final specific = _bySlug[trail.slug];
    if (specific != null) return specific;
    return _byCategory(trail.categoryId, trail.color);
  }

  static TrailVisuals forSlug(String slug, {Color? fallbackAccent}) {
    return _bySlug[slug] ??
        _palette(
          CinematicGlyph.book,
          fallbackAccent ?? AppColors.primaryLight,
          fallbackAccent ?? AppColors.primary,
        );
  }

  static TrailVisuals _byCategory(String categoryId, String hexColor) {
    final accent = _parseColor(hexColor) ?? AppColors.primaryLight;
    return switch (categoryId) {
      'pentateuco' => _palette(CinematicGlyph.book, AppColors.primaryLight, AppColors.primary),
      'historicos-at' => _palette(CinematicGlyph.shield, AppColors.cedar, AppColors.cedarDeep),
      'poeticos' => _palette(CinematicGlyph.dove, AppColors.sand, AppColors.sandDeep),
      'profetas-maiores' => _palette(CinematicGlyph.spark, AppColors.slate, AppColors.slateDeep),
      'profetas-menores' => _palette(CinematicGlyph.star, AppColors.slate, AppColors.slateDeep),
      'intertestamentario' => _palette(CinematicGlyph.calendar, AppColors.slate, AppColors.slateDeep),
      'evangelhos' => _palette(CinematicGlyph.heart, AppColors.clay, AppColors.clayDeep),
      'historicos-nt' => _palette(CinematicGlyph.flame, AppColors.ember, AppColors.emberDeep),
      'epistolas' => _palette(CinematicGlyph.mail, AppColors.clay, AppColors.clayDeep),
      'apocalipse' => _palette(CinematicGlyph.crown, AppColors.ember, AppColors.emberDeep),
      'discipulado' => _palette(CinematicGlyph.seed, AppColors.teal, AppColors.cedarDeep),
      'oracao' => _palette(CinematicGlyph.dove, AppColors.sand, AppColors.primaryDark),
      'historia-igreja' => _palette(CinematicGlyph.tower, AppColors.sand, AppColors.sandDeep),
      'hermeneutica' => _palette(CinematicGlyph.search, AppColors.slate, AppColors.slateDeep),
      'linguas' => _palette(CinematicGlyph.scroll, AppColors.sand, AppColors.sandDeep),
      'sistematica' => _palette(CinematicGlyph.scroll, AppColors.slate, AppColors.slateDeep),
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
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(dark, Colors.black, 0.35)!,
          Color.lerp(dark, Colors.black, 0.7)!,
        ],
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
    'genesis-1-11': _palette(CinematicGlyph.book, AppColors.primaryLight, AppColors.primary),
    'exodo': _palette(CinematicGlyph.mountain, AppColors.primaryLight, AppColors.cedarDeep),
    'evangelhos': _palette(CinematicGlyph.heart, AppColors.clay, AppColors.clayDeep),
    'atos': _palette(CinematicGlyph.flame, AppColors.ember, AppColors.emberDeep),
    'apocalipse': _palette(CinematicGlyph.crown, AppColors.ember, AppColors.emberDeep),
    'hebraico': _palette(CinematicGlyph.scroll, AppColors.sand, AppColors.sandDeep),
    'grego': _palette(CinematicGlyph.scroll, AppColors.sand, AppColors.sandDeep),
    'romanos': _palette(CinematicGlyph.scales, AppColors.clay, AppColors.clayDeep),
    'cristologia': _palette(CinematicGlyph.heart, AppColors.clay, AppColors.clayDeep),
  };
}
