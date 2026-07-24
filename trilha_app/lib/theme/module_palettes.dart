import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Paletas de atmosfera por módulo — só para mapa/trilha ([GenesisModuleTheme]).
/// Não use em botões, nav ou chrome geral.
class ModuleSwatch {
  final Color nodeTop;
  final Color nodeBottom;
  final Color decor;

  const ModuleSwatch({
    required this.nodeTop,
    required this.nodeBottom,
    required this.decor,
  });
}

class ModulePalettes {
  ModulePalettes._();

  static const creation = ModuleSwatch(
    nodeTop: Color(0xFF5A8AB0),
    nodeBottom: Color(0xFF0E2438),
    decor: AppColors.accentBright,
  );

  static const garden = ModuleSwatch(
    nodeTop: Color(0xFF4AB8A8),
    nodeBottom: Color(0xFF0E3840),
    decor: Color(0xFF7AD0C0),
  );

  static const afterEden = ModuleSwatch(
    nodeTop: Color(0xFF8A9AB0),
    nodeBottom: Color(0xFF243040),
    decor: Color(0xFFC4B07A),
  );

  static const abraham = ModuleSwatch(
    nodeTop: Color(0xFF6A9AB8),
    nodeBottom: Color(0xFF1A3040),
    decor: AppColors.accentBright,
  );

  static const isaacJacob = ModuleSwatch(
    nodeTop: Color(0xFF5AB8A8),
    nodeBottom: Color(0xFF0E3840),
    decor: Color(0xFF7AD0C0),
  );

  static const joseph = ModuleSwatch(
    nodeTop: Color(0xFF8A9AB8),
    nodeBottom: Color(0xFF182030),
    decor: AppColors.accent,
  );

  static const oppression = ModuleSwatch(
    nodeTop: Color(0xFF6A8098),
    nodeBottom: Color(0xFF182030),
    decor: Color(0xFFB8A878),
  );

  static const liberation = ModuleSwatch(
    nodeTop: Color(0xFF4A98B8),
    nodeBottom: Color(0xFF0E3040),
    decor: AppColors.accentBright,
  );

  static const beginning = ModuleSwatch(
    nodeTop: Color(0xFFFFAB91),
    nodeBottom: Color(0xFF8B3A2A),
    decor: Color(0xFFFFAB91),
  );

  static const teaching = ModuleSwatch(
    nodeTop: Color(0xFFE8C4A8),
    nodeBottom: Color(0xFF5C3A2A),
    decor: AppColors.accentBright,
  );

  static const cross = ModuleSwatch(
    nodeTop: AppColors.accentBright,
    nodeBottom: Color(0xFF5C2A1A),
    decor: Color(0xFFFFD56A),
  );

  static const church = ModuleSwatch(
    nodeTop: Color(0xFFFFE082),
    nodeBottom: Color(0xFF8B6914),
    decor: Color(0xFFFFE082),
  );

  static const hope = ModuleSwatch(
    nodeTop: AppColors.ember,
    nodeBottom: Color(0xFF6B2E1A),
    decor: AppColors.accent,
  );

  static const atFallback = ModuleSwatch(
    nodeTop: AppColors.primaryLight,
    nodeBottom: AppColors.primaryDark,
    decor: AppColors.accent,
  );

  static const ntFallback = ModuleSwatch(
    nodeTop: AppColors.clay,
    nodeBottom: AppColors.clayDeep,
    decor: AppColors.accent,
  );
}
