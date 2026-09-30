import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/theme/app_colors.dart';
import 'package:trilha_app/utils/difficulty_visuals.dart';

void main() {
  test('modos usam mint, coral soft e lilac — nunca ouro de ação', () {
    expect(
      DifficultyVisuals.accentFor(TrailDifficulty.semente),
      AppRoles.observation,
    );
    // Amarelo é ação e recompensa — nenhum modo usa.
    for (final d in TrailDifficulty.values) {
      expect(DifficultyVisuals.accentFor(d), isNot(AppRoles.action));
    }
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
      isNot(AppColors.glow),
    );
    expect(
      DifficultyVisuals.accentFor(TrailDifficulty.profundezas),
      isNot(AppColors.primary),
    );
  });

  test('mint, coral e lilac puncionam no céu como o ouro', () {
    expect(AppColors.sprout.computeLuminance(), greaterThan(0.35));
    expect(AppColors.isSolidChrome(AppColors.sprout), isTrue);
    expect(AppColors.coral.computeLuminance(), greaterThan(0.35));
    expect(AppColors.orchid.computeLuminance(), greaterThan(0.35));
    expect(AppColors.isSolidChrome(AppColors.coral), isTrue);
    expect(AppColors.isSolidChrome(AppColors.orchid), isTrue);
    expect(DifficultyVisuals.onSky(AppColors.coral), AppColors.coral);
    expect(DifficultyVisuals.onSky(AppColors.orchid), AppColors.orchid);
  });

  test('station card chrome follows the mode accent', () {
    final gold = DifficultyVisuals.stationCard(
      accent: AppColors.accent,
      baseFill: AppColors.nightElevated,
      lit: true,
    );
    final coral = DifficultyVisuals.stationCard(
      accent: AppColors.coral,
      baseFill: AppColors.nightElevated,
      lit: true,
    );
    final goldBorder = (gold.border as Border).top.color;
    final coralBorder = (coral.border as Border).top.color;
    expect(goldBorder, AppColors.accent.withValues(alpha: 0.70));
    expect(coralBorder, AppColors.coral.withValues(alpha: 0.70));
    expect(goldBorder, isNot(coralBorder));
  });
}
