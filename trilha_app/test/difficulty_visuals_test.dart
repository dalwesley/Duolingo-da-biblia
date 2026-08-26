import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/theme/app_colors.dart';
import 'package:trilha_app/utils/difficulty_visuals.dart';

void main() {
  test('modos usam acentos fora da família azul/teal do céu', () {
    expect(
      DifficultyVisuals.accentFor(TrailDifficulty.semente),
      AppColors.accent,
    );
    expect(
      DifficultyVisuals.accentFor(TrailDifficulty.caminhada),
      AppColors.coral,
    );
    expect(
      DifficultyVisuals.accentFor(TrailDifficulty.profundezas),
      AppColors.orchid,
    );

    expect(
      DifficultyVisuals.accentFor(TrailDifficulty.caminhada),
      isNot(AppColors.teal),
    );
    expect(
      DifficultyVisuals.accentFor(TrailDifficulty.profundezas),
      isNot(AppColors.primary),
    );
  });

  test('coral e orquídea puncionam no céu como o ouro', () {
    expect(AppColors.coral.computeLuminance(), greaterThan(0.35));
    expect(AppColors.orchid.computeLuminance(), greaterThan(0.35));
    expect(AppColors.isSolidChrome(AppColors.coral), isTrue);
    expect(AppColors.isSolidChrome(AppColors.orchid), isTrue);
    expect(DifficultyVisuals.onSky(AppColors.coral), AppColors.coral);
    expect(DifficultyVisuals.onSky(AppColors.orchid), AppColors.orchid);
  });
}
