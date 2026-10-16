import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/l10n_global.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import 'day_phase.dart';

/// Preferência do usuário para o visual do app.
enum AppearanceMode { morning, afternoon, night, automatic }

extension AppearanceModeX on AppearanceMode {
  String get storageKey => name;

  String get label => switch (this) {
    AppearanceMode.morning => L10n.current.settingsThemeLight,
    AppearanceMode.afternoon => L10n.current.settingsThemeMedium,
    AppearanceMode.night => L10n.current.settingsThemeDark,
    AppearanceMode.automatic => L10n.current.settingsThemeAuto,
  };

  CinematicGlyph get glyph => switch (this) {
    AppearanceMode.morning => CinematicGlyph.sun,
    AppearanceMode.afternoon => CinematicGlyph.flame,
    AppearanceMode.night => CinematicGlyph.star,
    AppearanceMode.automatic => CinematicGlyph.calendar,
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

  // Tintas do papel claro, puxadas para o azul da trilha (não cinza).
  static const _inkSecondaryLight = Color(0xFF365474);
  static const _inkFaintLight = Color(0xFF64809E);

  bool get isDay =>
      look == AppearanceLook.morning || look == AppearanceLook.afternoon;

  /// Claro é papel claro. Médio e Escuro continuam com tinta clara.
  bool get onDark => look != AppearanceLook.morning;

  /// Ícones do chrome (nav, marca da barra) — da família da trilha de fundo:
  /// azul profundo no papel claro, gelo no Médio, aço no Escuro.
  Color get chrome => switch (look) {
    AppearanceLook.morning => const Color(0xFF2C5A8C),
    AppearanceLook.afternoon => const Color(0xFFCADDF2),
    AppearanceLook.night => AppRoles.chrome,
  };

  /// Seleção no chrome: contorno claro no escuro; azul da marca no papel.
  Color get selected => onDark ? AppRoles.selected : AppColors.primary;

  /// Tinta sobre um fill [selected].
  Color get onSelected => onDark ? AppColors.night : AppColors.textOnDark;

  /// Tinta de glifo/acento: no escuro sobe rumo ao branco
  /// ([AppColors.glyphInk]); no papel claro desce para ter contraste.
  Color ink(Color accent) =>
      onDark ? AppColors.glyphInk(accent) : AppColors.glyphInkOnLight(accent);

  Color get sectionLabel => onDark
      ? AppColors.textOnDark.withValues(alpha: isDay ? 0.85 : 0.72)
      : _inkSecondaryLight;

  Color get text =>
      onDark ? AppColors.textOnDark.withValues(alpha: 0.98) : AppColors.text;

  Color textMuted([double alpha = 0.7]) {
    if (!onDark) {
      final t = ((alpha - 0.45) / 0.55).clamp(0.0, 1.0);
      return Color.lerp(_inkFaintLight, _inkSecondaryLight, t)!;
    }
    return AppColors.textOnDark.withValues(
      alpha: (isDay ? alpha.clamp(0.72, 0.95) : alpha.clamp(0.55, 0.9)),
    );
  }

  // Três níveis de texto — use estes em vez de alphas soltos:
  // [text] (principal) › [textSecondary] (legenda, apoio) › [textFaint]
  // (dica, rodapé, dia futuro).
  Color get textSecondary => onDark ? textMuted(0.72) : _inkSecondaryLight;

  Color get textFaint => onDark
      ? AppColors.textOnDark.withValues(alpha: isDay ? 0.62 : 0.45)
      : _inkFaintLight;

  /// Linha divisória entre rows de um card.
  Color get divider => onDark
      ? AppColors.textOnDark.withValues(alpha: 0.07)
      : AppColors.text.withValues(alpha: 0.08);

  /// Poço dentro de um card ([InsetPanel]).
  Color get insetFill =>
      onDark ? Colors.black.withValues(alpha: 0.22) : const Color(0xFFE4EEF6);
  Color get insetBorder => onDark
      ? AppColors.textOnDark.withValues(alpha: 0.06)
      : AppColors.text.withValues(alpha: 0.08);

  Color get cardFill => switch (look) {
    AppearanceLook.morning => AppColors.cardMorning,
    AppearanceLook.afternoon => AppColors.cardAfternoon,
    AppearanceLook.night => AppColors.cardNight,
  };

  Color get cardFillSoft => switch (look) {
    AppearanceLook.morning => AppColors.cardMorningSoft,
    AppearanceLook.afternoon => AppColors.cardAfternoonSoft,
    AppearanceLook.night => AppColors.cardNightSoft,
  };

  /// Placa da cena (palco da lição, opções idle): papel branco no Claro,
  /// azul do card no Médio, poço elevado no Escuro.
  Color get stageFill => switch (look) {
    AppearanceLook.morning => AppColors.cardMorningSoft,
    AppearanceLook.afternoon => AppColors.cardAfternoon,
    AppearanceLook.night => AppColors.nightElevated,
  };

  /// Arte de cena escura fixa (hero, pôsteres, banner de modo) sobe para o
  /// azul do look, como a trilha do fundo: screen linear `c·(1−k) + k`.
  /// Escuro mantém a arte como foi pintada.
  ColorFilter? get artLift => switch (look) {
    AppearanceLook.morning => _screen(const Color(0xFF2A5C92)),
    AppearanceLook.afternoon => _screen(const Color(0xFF173F6C)),
    AppearanceLook.night => null,
  };

  static ColorFilter _screen(Color k) => ColorFilter.matrix([
    1 - k.r, 0, 0, 0, k.r * 255, //
    0, 1 - k.g, 0, 0, k.g * 255, //
    0, 0, 1 - k.b, 0, k.b * 255, //
    0, 0, 0, 1, 0,
  ]);

  /// Fundo do degradê de palco — não puxa o Claro para o void.
  Color get cardDepth => switch (look) {
    AppearanceLook.morning => const Color(0xFFD5E4F0),
    AppearanceLook.afternoon => const Color(0xFF1A4470),
    AppearanceLook.night => AppColors.night,
  };

  Color get cardBorder => switch (look) {
    AppearanceLook.morning => const Color(0x262C5A8C),
    AppearanceLook.afternoon => AppColors.textOnDark.withValues(alpha: 0.24),
    AppearanceLook.night => AppColors.textOnDark.withValues(alpha: 0.14),
  };

  Color get progressTrack => onDark
      ? AppColors.textOnDark.withValues(alpha: isDay ? 0.24 : 0.18)
      : AppColors.text.withValues(alpha: 0.12);

  Color get navBarFill => cardFill;

  Color get navBarBorder => cardBorder;

  /// Ícone/tab inativo — nunca `Colors.white` cru.
  Color get iconMuted => textOnDarkInactive;

  Color get textOnDarkInactive => onDark
      ? AppColors.textOnDark.withValues(alpha: isDay ? 0.58 : 0.5)
      : _inkFaintLight;

  /// Ícones da barra de status: claros no Médio e no Escuro, escuros no Claro.
  SystemUiOverlayStyle get systemOverlay =>
      onDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

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

    // Fase visual alinhada ao look: Noite e Automático (18h+) usam o mesmo
    // céu de noite — antes Noite forçava `evening` e Automático após 22h usava
    // `night`, deixando os dois diferentes no mesmo horário.
    final phase = switch (mode) {
      AppearanceMode.morning => DayPhase.morning,
      AppearanceMode.afternoon => DayPhase.afternoon,
      AppearanceMode.night => DayPhase.night,
      AppearanceMode.automatic => switch (clockPhase) {
        DayPhase.morning => DayPhase.morning,
        DayPhase.afternoon => DayPhase.afternoon,
        DayPhase.evening || DayPhase.night => DayPhase.night,
      },
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

  @override
  bool updateShouldNotify(Appearance oldWidget) =>
      oldWidget.style.look != style.look ||
      oldWidget.style.phase != style.phase ||
      oldWidget.mode != mode;
}

/// Envolve só o cenário de um card de arte escura (não o texto) com
/// [AppearanceStyle.artLift] do look da página.
class ArtLift extends StatelessWidget {
  /// Look da página — passe o de fora quando o card força `night` por dentro.
  final AppearanceStyle page;
  final Widget child;

  const ArtLift({super.key, required this.page, required this.child});

  @override
  Widget build(BuildContext context) {
    final lift = page.artLift;
    if (lift == null) return child;
    return ColorFiltered(colorFilter: lift, child: child);
  }
}
