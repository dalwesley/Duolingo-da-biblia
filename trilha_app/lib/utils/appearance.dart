import 'package:flutter/material.dart';
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
        AppearanceMode.morning => 'Amanhecer cinematográfico',
        AppearanceMode.afternoon => 'Luz dourada do dia',
        AppearanceMode.night => 'Noite profunda e imersiva',
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
    // Migração do antigo toggle "Tema escuro".
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

  /// Texto / ícones — mundo cinematográfico sempre pede contraste claro.
  bool get onDark => true;

  /// Fundo imersivo (roxo) sempre pede texto claro — inclusive no tema manhã.
  Color get backdropText => Colors.white;
  Color get backdropMuted => Colors.white.withValues(alpha: 0.78);
  Color get sectionLabel => Colors.white.withValues(alpha: 0.72);

  Color get text => Colors.white.withValues(alpha: 0.96);

  /// Secundário legível — sem empilhar alpha em cima de cor já muted.
  Color textMuted([double alpha = 0.7]) =>
      Colors.white.withValues(alpha: alpha.clamp(0.55, 0.9));

  Color get cardFill => switch (look) {
        AppearanceLook.morning => Colors.white.withValues(alpha: 0.12),
        AppearanceLook.afternoon => Colors.white.withValues(alpha: 0.14),
        AppearanceLook.night => const Color(0xFF0E0C18).withValues(alpha: 0.72),
      };

  Color get cardFillSoft => switch (look) {
        AppearanceLook.morning => Colors.white.withValues(alpha: 0.08),
        AppearanceLook.afternoon => Colors.white.withValues(alpha: 0.1),
        AppearanceLook.night => const Color(0xFF08070F).withValues(alpha: 0.65),
      };

  Color get cardBorder => Colors.white.withValues(
        alpha: look == AppearanceLook.night ? 0.1 : 0.16,
      );

  LinearGradient? get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: look == AppearanceLook.night ? 0.1 : 0.16),
          Colors.white.withValues(alpha: look == AppearanceLook.night ? 0.04 : 0.06),
        ],
      );

  Color get progressTrack => Colors.white.withValues(alpha: 0.14);

  Color get navBarFill => look == AppearanceLook.night
      ? const Color(0xFF12101C).withValues(alpha: 0.94)
      : const Color(0xFF3A2F6E).withValues(alpha: 0.92);

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
      // Noite forçada = visual pós-18h (evening).
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
