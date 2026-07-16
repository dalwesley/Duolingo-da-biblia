import 'package:flutter/material.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';

/// Ícones e gradientes por trilha — família olive/gold/clay/slate (sem arco-íris).
class TrailVisuals {
  final IconData icon;
  final LinearGradient iconGradient;
  final LinearGradient cardGradient;
  final Color accent;
  final Color glow;

  const TrailVisuals({
    required this.icon,
    required this.iconGradient,
    required this.cardGradient,
    required this.accent,
    required this.glow,
  });

  static TrailVisuals forTrail(Trail trail) {
    final specific = _bySlug[trail.slug];
    if (specific != null) return specific;
    return _byCategory(trail.categoryId, trail.color);
  }

  static TrailVisuals forSlug(String slug, {Color? fallbackAccent}) {
    return _bySlug[slug] ??
        _palette(
          Icons.menu_book_rounded,
          fallbackAccent ?? AppColors.primaryLight,
          fallbackAccent ?? AppColors.primary,
        );
  }

  static TrailVisuals _byCategory(String categoryId, String hexColor) {
    final accent = _parseColor(hexColor) ?? AppColors.primaryLight;
    return switch (categoryId) {
      'pentateuco' => _palette(Icons.auto_stories_rounded, AppColors.primaryLight, AppColors.primary),
      'historicos-at' => _palette(Icons.shield_rounded, AppColors.cedar, AppColors.cedarDeep),
      'poeticos' => _palette(Icons.music_note_rounded, AppColors.sand, AppColors.sandDeep),
      // Proféticos: azul-acinzentado frio ainda na família AT (não clay NT).
      'profeticos' => _palette(Icons.bolt_rounded, AppColors.slate, AppColors.slateDeep),
      'evangelhos' => _palette(Icons.favorite_rounded, AppColors.clay, AppColors.clayDeep),
      'historicos-nt' => _palette(Icons.local_fire_department_rounded, AppColors.ember, AppColors.emberDeep),
      // Epístolas: cedar era verde-AT; agora clay profundo = família NT.
      'epistolas' => _palette(Icons.mail_rounded, AppColors.clay, AppColors.clayDeep),
      'apocalipse' => _palette(Icons.workspace_premium_rounded, AppColors.ember, AppColors.emberDeep),
      'discipulado' => _palette(Icons.spa_rounded, AppColors.teal, AppColors.cedarDeep),
      'oracao' => _palette(Icons.self_improvement_rounded, AppColors.sand, AppColors.primaryDark),
      'historia-igreja' => _palette(Icons.account_balance_rounded, AppColors.sand, AppColors.sandDeep),
      'hermeneutica' => _palette(Icons.search_rounded, AppColors.slate, AppColors.slateDeep),
      'linguas' => _palette(Icons.translate_rounded, AppColors.sand, AppColors.sandDeep),
      'sistematica' => _palette(Icons.library_books_rounded, AppColors.slate, AppColors.slateDeep),
      'cristologia' => _palette(Icons.church_rounded, AppColors.clay, AppColors.clayDeep),
      _ => _palette(Icons.menu_book_rounded, accent, AppColors.primary),
    };
  }

  static TrailVisuals _palette(IconData icon, Color light, Color dark) {
    return TrailVisuals(
      icon: icon,
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
    'genesis-1-11': _palette(Icons.auto_stories_rounded, AppColors.primaryLight, AppColors.primary),
    'exodo': _palette(Icons.landscape_rounded, AppColors.primaryLight, AppColors.cedarDeep),
    'evangelhos': _palette(Icons.favorite_rounded, AppColors.clay, AppColors.clayDeep),
    'atos': _palette(Icons.local_fire_department_rounded, AppColors.ember, AppColors.emberDeep),
    'apocalipse': _palette(Icons.workspace_premium_rounded, AppColors.ember, AppColors.emberDeep),
    'hebraico': _palette(Icons.translate_rounded, AppColors.sand, AppColors.sandDeep),
    'grego': _palette(Icons.abc_rounded, AppColors.sand, AppColors.sandDeep),
    'romanos': _palette(Icons.balance_rounded, AppColors.clay, AppColors.clayDeep),
    'cristologia': _palette(Icons.church_rounded, AppColors.clay, AppColors.clayDeep),
  };
}
