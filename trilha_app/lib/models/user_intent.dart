import 'package:flutter/material.dart';

import '../l10n/l10n_global.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';

/// Resposta do onboarding "O que te traz aqui?" — escolhe a trilha de entrada.
enum UserIntent { know, habit, understand, peace }

extension UserIntentX on UserIntent {
  String get storageKey => name;

  String get title => switch (this) {
    UserIntent.know => L10n.current.onboardingIntentKnowTitle,
    UserIntent.habit => L10n.current.onboardingIntentHabitTitle,
    UserIntent.understand => L10n.current.onboardingIntentUnderstandTitle,
    UserIntent.peace => L10n.current.onboardingIntentPeaceTitle,
  };

  /// Tagline curta — o que o motivo promete em poucas palavras.
  String get tagline => switch (this) {
    UserIntent.know => L10n.current.onboardingIntentKnowCaption,
    UserIntent.habit => L10n.current.onboardingIntentHabitCaption,
    UserIntent.understand => L10n.current.onboardingIntentUnderstandCaption,
    UserIntent.peace => L10n.current.onboardingIntentPeaceCaption,
  };

  /// Descrição de uma linha no portal do carrossel.
  String get blurb => switch (this) {
    UserIntent.know => L10n.current.intentKnowBlurb,
    UserIntent.habit => L10n.current.intentHabitBlurb,
    UserIntent.understand => L10n.current.intentUnderstandBlurb,
    UserIntent.peace => L10n.current.intentPeaceBlurb,
  };

  /// Número do motivo na fila (I–IV).
  String get ordinal => switch (this) {
    UserIntent.know => 'I',
    UserIntent.habit => 'II',
    UserIntent.understand => 'III',
    UserIntent.peace => 'IV',
  };

  CinematicGlyph get glyph => switch (this) {
    UserIntent.know => CinematicGlyph.heart,
    UserIntent.habit => CinematicGlyph.flame,
    UserIntent.understand => CinematicGlyph.book,
    UserIntent.peace => CinematicGlyph.dove,
  };

  /// Acento do portal — cada motivo tem a própria luz no céu.
  Color get accent => switch (this) {
    UserIntent.know => AppRoles.heart,
    UserIntent.habit => AppRoles.streak,
    UserIntent.understand => AppRoles.interpretation,
    UserIntent.peace => AppRoles.presence,
  };

  /// Três verbos do que você busca neste motivo.
  List<String> get skills => switch (this) {
    UserIntent.know => [
      L10n.current.intentKnowSkill1,
      L10n.current.intentKnowSkill2,
      L10n.current.intentKnowSkill3,
    ],
    UserIntent.habit => [
      L10n.current.intentHabitSkill1,
      L10n.current.intentHabitSkill2,
      L10n.current.intentHabitSkill3,
    ],
    UserIntent.understand => [
      L10n.current.intentUnderstandSkill1,
      L10n.current.intentUnderstandSkill2,
      L10n.current.intentUnderstandSkill3,
    ],
    UserIntent.peace => [
      L10n.current.intentPeaceSkill1,
      L10n.current.intentPeaceSkill2,
      L10n.current.intentPeaceSkill3,
    ],
  };

  /// Trilha que a Home abre primeiro. "Criar uma sequência" não tem trilha
  /// própria: começa pelo começo.
  String get entryTrailSlug => switch (this) {
    UserIntent.know => 'conhecer-a-deus',
    UserIntent.habit => 'genesis-1-11',
    UserIntent.understand => 'entender-a-biblia',
    UserIntent.peace => 'ansiedade',
  };

  /// Nome curto da trilha de entrada (linha sob o progresso / nota).
  String get entryTrailLabel => switch (this) {
    UserIntent.know => L10n.current.entryTrailConhecerADeusTitle,
    UserIntent.habit => L10n.current.settingsGenesisTitle,
    UserIntent.understand => L10n.current.entryTrailEntenderABibliaTitle,
    UserIntent.peace => L10n.current.entryTrailAnsiedadeTitle,
  };

  static UserIntent? tryParse(String? raw) {
    for (final intent in UserIntent.values) {
      if (intent.name == raw) return intent;
    }
    return null;
  }
}
