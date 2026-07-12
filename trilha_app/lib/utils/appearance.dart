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
        AppearanceMode.morning => 'Visual claro e luminoso',
        AppearanceMode.afternoon => 'Meio-termo equilibrado',
        AppearanceMode.night => 'Fundo e cards como após as 18h',
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

  /// Texto / ícones sobre cards claros (só manhã).
  bool get onDark => look != AppearanceLook.morning;

  /// Fundo imersivo (roxo) sempre pede texto claro — inclusive no tema manhã.
  Color get backdropText => Colors.white;
  Color get backdropMuted => Colors.white.withValues(alpha: 0.78);
  Color get sectionLabel => Colors.white.withValues(alpha: 0.72);

  Color get text => switch (look) {
        AppearanceLook.morning => AppColors.text,
        AppearanceLook.afternoon => Colors.white.withValues(alpha: 0.96),
        AppearanceLook.night => Colors.white,
      };

  /// Secundário legível — sem empilhar alpha em cima de cor já muted.
  Color textMuted([double alpha = 0.7]) => switch (look) {
        AppearanceLook.morning => Color.lerp(
              AppColors.text,
              AppColors.textMuted,
              0.35,
            )!
            .withValues(alpha: alpha.clamp(0.72, 1.0)),
        AppearanceLook.afternoon => Colors.white.withValues(alpha: alpha.clamp(0.72, 0.9)),
        AppearanceLook.night => Colors.white.withValues(alpha: alpha.clamp(0.55, 0.85)),
      };

  Color get cardFill => switch (look) {
        AppearanceLook.morning => Colors.white.withValues(alpha: 0.96),
        AppearanceLook.afternoon => Colors.white.withValues(alpha: 0.18),
        AppearanceLook.night => const Color(0xFF0E0C18).withValues(alpha: 0.88),
      };

  Color get cardFillSoft => switch (look) {
        AppearanceLook.morning => const Color(0xFFF3F0FA),
        AppearanceLook.afternoon => Colors.white.withValues(alpha: 0.12),
        AppearanceLook.night => const Color(0xFF08070F).withValues(alpha: 0.78),
      };

  Color get cardBorder => switch (look) {
        AppearanceLook.morning => Colors.black.withValues(alpha: 0.08),
        AppearanceLook.afternoon => Colors.white.withValues(alpha: 0.22),
        AppearanceLook.night => Colors.white.withValues(alpha: 0.08),
      };

  LinearGradient? get cardGradient => switch (look) {
        AppearanceLook.morning => null,
        AppearanceLook.afternoon => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.22),
              Colors.white.withValues(alpha: 0.10),
            ],
          ),
        AppearanceLook.night => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1530).withValues(alpha: 0.95),
              const Color(0xFF0A0912).withValues(alpha: 0.98),
            ],
          ),
      };

  Color get progressTrack => onDark ? Colors.white.withValues(alpha: 0.14) : Colors.black.withValues(alpha: 0.1);

  Color get navBarFill => onDark
      ? (look == AppearanceLook.night ? const Color(0xFF12101C).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.16))
      : Colors.white.withValues(alpha: 0.95);

  Color get navBarBorder => onDark ? Colors.white.withValues(alpha: look == AppearanceLook.night ? 0.1 : 0.22) : Colors.black.withValues(alpha: 0.06);

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
