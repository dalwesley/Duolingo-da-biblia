import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Paletas de atmosfera por módulo — só para mapa/trilha ([GenesisModuleTheme]).
/// Não use em botões, nav ou chrome geral.
class ModuleSwatch {
  final List<Color> sky;
  final List<double> stops;
  final Color nodeTop;
  final Color nodeBottom;
  final Color decor;

  const ModuleSwatch({
    required this.sky,
    required this.stops,
    required this.nodeTop,
    required this.nodeBottom,
    required this.decor,
  });
}

class ModulePalettes {
  ModulePalettes._();

  static const creation = ModuleSwatch(
    sky: [
      Color(0xFF04080E),
      Color(0xFF0A1524),
      Color(0xFF163050),
      Color(0xFF2A5078),
      Color(0xFFE0A84A),
    ],
    stops: [0.0, 0.22, 0.48, 0.72, 1.0],
    nodeTop: Color(0xFF5A8AB0),
    nodeBottom: Color(0xFF0E2438),
    decor: AppColors.accentBright,
  );

  static const garden = ModuleSwatch(
    sky: [
      Color(0xFF061418),
      Color(0xFF0E3040),
      Color(0xFF1A5868),
      Color(0xFF2A7888),
      Color(0xFF5AB8A8),
    ],
    stops: [0.0, 0.2, 0.45, 0.72, 1.0],
    nodeTop: Color(0xFF4AB8A8),
    nodeBottom: Color(0xFF0E3840),
    decor: Color(0xFF7AD0C0),
  );

  static const afterEden = ModuleSwatch(
    sky: [
      Color(0xFF0E1218),
      Color(0xFF1A2430),
      Color(0xFF3A4558),
      AppColors.textMuted,
    ],
    stops: [0.0, 0.32, 0.68, 1.0],
    nodeTop: Color(0xFF8A9AB0),
    nodeBottom: Color(0xFF243040),
    decor: Color(0xFFC4B07A),
  );

  static const abraham = ModuleSwatch(
    sky: [
      Color(0xFF0A1018),
      Color(0xFF1A2838),
      Color(0xFF3A5068),
      Color(0xFFD4A84B),
    ],
    stops: [0.0, 0.3, 0.65, 1.0],
    nodeTop: Color(0xFF6A9AB8),
    nodeBottom: Color(0xFF1A3040),
    decor: AppColors.accentBright,
  );

  static const isaacJacob = ModuleSwatch(
    sky: [
      Color(0xFF081018),
      Color(0xFF142830),
      Color(0xFF2A5860),
      Color(0xFF5AB8A0),
    ],
    stops: [0.0, 0.3, 0.65, 1.0],
    nodeTop: Color(0xFF5AB8A8),
    nodeBottom: Color(0xFF0E3840),
    decor: Color(0xFF7AD0C0),
  );

  static const joseph = ModuleSwatch(
    sky: [
      Color(0xFF0A0E18),
      Color(0xFF1A2038),
      Color(0xFF3A4568),
      Color(0xFFE0A84A),
    ],
    stops: [0.0, 0.32, 0.68, 1.0],
    nodeTop: Color(0xFF8A9AB8),
    nodeBottom: Color(0xFF182030),
    decor: AppColors.accent,
  );

  static const oppression = ModuleSwatch(
    sky: [
      Color(0xFF0A1018),
      Color(0xFF141C28),
      Color(0xFF243040),
      Color(0xFF3A4858),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
    nodeTop: Color(0xFF6A8098),
    nodeBottom: Color(0xFF182030),
    decor: Color(0xFFB8A878),
  );

  static const liberation = ModuleSwatch(
    sky: [
      Color(0xFF061018),
      Color(0xFF0E3048),
      Color(0xFF1A5878),
      Color(0xFF2A7898),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
    nodeTop: Color(0xFF4A98B8),
    nodeBottom: Color(0xFF0E3040),
    decor: AppColors.accentBright,
  );

  static const beginning = ModuleSwatch(
    sky: [
      Color(0xFF1A0E10),
      Color(0xFF3A2018),
      Color(0xFF6A3A30),
      Color(0xFFE0A898),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
    nodeTop: Color(0xFFFFAB91),
    nodeBottom: Color(0xFF8B3A2A),
    decor: Color(0xFFFFAB91),
  );

  static const teaching = ModuleSwatch(
    sky: [
      Color(0xFF1A1010),
      Color(0xFF3A281E),
      Color(0xFF6B4A38),
      Color(0xFFD4A890),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
    nodeTop: Color(0xFFE8C4A8),
    nodeBottom: Color(0xFF5C3A2A),
    decor: AppColors.accentBright,
  );

  static const cross = ModuleSwatch(
    sky: [
      Color(0xFF12080C),
      Color(0xFF3A1520),
      Color(0xFF6A2A30),
      Color(0xFFE0A84A),
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
    nodeTop: AppColors.accentBright,
    nodeBottom: Color(0xFF5C2A1A),
    decor: Color(0xFFFFD56A),
  );

  static const church = ModuleSwatch(
    sky: [
      Color(0xFF1A100E),
      Color(0xFF3D2818),
      Color(0xFF6B4A28),
      AppColors.accentBright,
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
    nodeTop: Color(0xFFFFE082),
    nodeBottom: Color(0xFF8B6914),
    decor: Color(0xFFFFE082),
  );

  static const hope = ModuleSwatch(
    sky: [
      Color(0xFF140C08),
      Color(0xFF3A2018),
      Color(0xFF6B3A28),
      AppColors.ember,
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
    nodeTop: AppColors.ember,
    nodeBottom: Color(0xFF6B2E1A),
    decor: AppColors.accent,
  );

  static const atFallback = ModuleSwatch(
    sky: [AppColors.night, AppColors.primaryDark, AppColors.primary],
    stops: [0.0, 0.5, 1.0],
    nodeTop: AppColors.primaryLight,
    nodeBottom: AppColors.primaryDark,
    decor: AppColors.accent,
  );

  static const ntFallback = ModuleSwatch(
    sky: [Color(0xFF180E10), Color(0xFF3A2018), Color(0xFF5C3830)],
    stops: [0.0, 0.5, 1.0],
    nodeTop: AppColors.clay,
    nodeBottom: AppColors.clayDeep,
    decor: AppColors.accent,
  );
}
