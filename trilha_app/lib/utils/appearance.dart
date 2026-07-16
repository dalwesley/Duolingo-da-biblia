import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'day_phase.dart';

/// Preferência do usuário para o visual do app.
enum AppearanceMode {
  morning,
  afternoon,
  night,
  automatic,
}

extension AppearanceModeX on AppearanceMode {
  String get storageKey => name;

  String get label => switch (this) {
        AppearanceMode.morning => 'Manhã',
        AppearanceMode.afternoon => 'Tarde',
        AppearanceMode.night => 'Noite',
        AppearanceMode.automatic => 'Automático',
      };

  String get description => switch (this) {
        AppearanceMode.morning => 'Luz suave de manhã',
        AppearanceMode.afternoon => 'Clareza do dia',
        AppearanceMode.night => 'Estudo à noite',
        AppearanceMode.automatic => 'Muda conforme o horário',
      };

  IconData get icon => switch (this) {
        AppearanceMode.morning => Icons.wb_sunny_rounded,
        AppearanceMode.afternoon => Icons.wb_twilight_rounded,
        AppearanceMode.night => Icons.nights_stay_rounded,
        AppearanceMode.automatic => Icons.schedule_rounded,
      };

  static AppearanceMode fromStorage(String? raw, {bool? legacyDarkMode}) {
    if (raw != null) {
      for (final mode in AppearanceMode.values) {
        if (mode.name == raw) return mode;
      }
    }
    if (legacyDarkMode == true) return AppearanceMode.night;
    return AppearanceMode.automatic;
  }
}

/// Estilo visual efetivo (após resolver automático × horário).
enum AppearanceLook { morning, afternoon, night }

class AppearanceStyle {
  final AppearanceLook look;
  final DayPhase phase;

  const AppearanceStyle({required this.look, required this.phase});

  bool get isDay =>
      look == AppearanceLook.morning || look == AppearanceLook.afternoon;

  bool get onDark => true;

  Color get backdropText => AppColors.textOnDark;
  Color get backdropMuted =>
      AppColors.textOnDark.withValues(alpha: isDay ? 0.88 : 0.78);
  Color get sectionLabel =>
      AppColors.textOnDark.withValues(alpha: isDay ? 0.85 : 0.72);

  Color get text => AppColors.textOnDark.withValues(alpha: 0.98);

  Color textMuted([double alpha = 0.7]) => AppColors.textOnDark.withValues(
        alpha: (isDay ? alpha.clamp(0.72, 0.95) : alpha.clamp(0.55, 0.9)),
      );

  Color get cardFill => switch (look) {
        AppearanceLook.morning => AppColors.nightMid.withValues(alpha: 0.92),
        AppearanceLook.afternoon => AppColors.nightMid.withValues(alpha: 0.9),
        AppearanceLook.night => AppColors.night.withValues(alpha: 0.78),
      };

  Color get cardFillSoft => switch (look) {
        AppearanceLook.morning => AppColors.nightLight.withValues(alpha: 0.82),
        AppearanceLook.afternoon => AppColors.nightLight.withValues(alpha: 0.78),
        AppearanceLook.night => AppColors.night.withValues(alpha: 0.65),
      };

  Color get cardBorder => switch (look) {
        AppearanceLook.morning => Colors.white.withValues(alpha: 0.2),
        AppearanceLook.afternoon => Colors.white.withValues(alpha: 0.16),
        AppearanceLook.night => Colors.white.withValues(alpha: 0.1),
      };

  LinearGradient? get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: look == AppearanceLook.night ? 0.1 : 0.08),
          Colors.white.withValues(alpha: look == AppearanceLook.night ? 0.04 : 0.03),
        ],
      );

  Color get progressTrack =>
      Colors.white.withValues(alpha: isDay ? 0.22 : 0.14);

  Color get navBarFill => look == AppearanceLook.night
      ? AppColors.nightMid.withValues(alpha: 0.94)
      : AppColors.primaryDark.withValues(alpha: 0.94);

  Color get navBarBorder =>
      Colors.white.withValues(alpha: look == AppearanceLook.night ? 0.1 : 0.18);

  static AppearanceStyle resolve(AppearanceMode mode, [DateTime? now]) {
    final clock = now ?? DateTime.now();
    final clockPhase = DayPhaseHelper.phaseAt(clock);

    final look = switch (mode) {
      AppearanceMode.morning => AppearanceLook.morning,
      AppearanceMode.afternoon => AppearanceLook.afternoon,
      AppearanceMode.night => AppearanceLook.night,
      AppearanceMode.automatic => switch (clockPhase) {
          DayPhase.morning => AppearanceLook.morning,
          DayPhase.afternoon => AppearanceLook.afternoon,
          DayPhase.evening || DayPhase.night => AppearanceLook.night,
        },
    };

    final phase = switch (mode) {
      AppearanceMode.morning => DayPhase.morning,
      AppearanceMode.afternoon => DayPhase.afternoon,
      AppearanceMode.night => DayPhase.evening,
      AppearanceMode.automatic => clockPhase,
    };

    return AppearanceStyle(look: look, phase: phase);
  }
}

class Appearance extends InheritedWidget {
  final AppearanceStyle style;
  final AppearanceMode mode;

  const Appearance({
    super.key,
    required this.style,
    required this.mode,
    required super.child,
  });

  static AppearanceStyle of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<Appearance>();
    return scope?.style ?? AppearanceStyle.resolve(AppearanceMode.automatic);
  }

  static AppearanceMode modeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<Appearance>();
    return scope?.mode ?? AppearanceMode.automatic;
  }

  @override
  bool updateShouldNotify(Appearance oldWidget) =>
      oldWidget.style.look != style.look ||
      oldWidget.style.phase != style.phase ||
      oldWidget.mode != mode;
}
