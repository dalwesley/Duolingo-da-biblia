import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

export 'app_colors.dart';
export 'app_light.dart';
export 'app_motion.dart';
export 'app_transitions.dart';

import 'app_colors.dart';
import 'app_light.dart';
import 'app_transitions.dart';
import '../utils/appearance.dart';

/// Tema STWAY — tipografia, raios, espaçamento e ThemeData.
/// Cores: ver [AppColors] em `app_colors.dart` (fonte única).
///
/// Voz de filme: Cormorant (títulos e versículo) + Nunito (interface).
class AppGradients {
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryDark, AppColors.primary, AppColors.primary],
  );

  /// CTA chapado — amarelo sólido, sem bevel nem topo brilhante.
  static const gold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.accent, AppColors.accent],
  );
}

/// Degraus da escala tipográfica — o app só usa estes tamanhos.
///
/// Qualquer tamanho pedido a [AppTypography] é encaixado no degrau mais
/// próximo (empate desce, para nunca estourar layout). Assim um `size: 15`
/// perdido vira 14 e a tela inteira fala a mesma língua.
class AppTypeScale {
  /// Títulos de tela e palco (Cormorant — a voz do filme).
  static const display = <double>[18, 20, 24, 28, 32, 40, 48];

  /// Títulos de card, linha e número de HUD.
  static const title = <double>[12, 14, 16, 18, 20, 24];

  /// Texto corrido, legenda e letra miúda.
  static const body = <double>[11, 12, 13, 14, 16];

  /// Rótulos em caixa alta, chips e selos.
  static const label = <double>[10, 11, 12, 13];

  /// Versículo e citação.
  static const verse = <double>[14, 16, 18, 21, 24, 28];

  /// Botões.
  static const cta = <double>[12, 14, 18];

  /// Encaixa [size] no degrau mais próximo de [steps].
  /// Use `exact: true` nos estilos só quando o tamanho é proporcional a
  /// um desenho (medalha, logo, grade) — nunca para “ficar mais bonito”.
  static double snap(double size, List<double> steps) {
    var best = steps.first;
    var bestDist = (size - best).abs();
    for (final s in steps.skip(1)) {
      final d = (size - s).abs();
      // Empate desce: `<` mantém o degrau menor já encontrado.
      if (d < bestDist) {
        best = s;
        bestDist = d;
      }
    }
    return best;
  }
}

/// Escala tipográfica unificada — HUD de jogo sem mudar copy.
/// Piso de legibilidade: texto de leitura (body/title) nunca abaixo de
/// 11pt; rótulos em caixa alta (label) nunca abaixo de 10pt.
/// Todo tamanho passa por [AppTypeScale.snap].
class AppTypography {
  /// Cada GoogleFonts.x() refaz variante, 2× copyWith e um Future de
  /// carga — e há centenas de chamadas por build. O estilo é imutável:
  /// guarda por argumentos. Teto só contra cores animadas (lerp por frame).
  static final Map<Record, TextStyle> _cache = {};

  static TextStyle _cached(Record key, TextStyle Function() make) {
    final hit = _cache[key];
    if (hit != null) return hit;
    if (_cache.length >= 1024) _cache.clear();
    return _cache[key] = make();
  }

  /// Serifa de filme: o olho pequeno da Cormorant pede ~12% a mais para
  /// ocupar o mesmo espaço visual do degrau pedido.
  static const _serifOptical = 1.12;

  /// Cormorant só tem até Bold (700): pesos maiores caem nele, sem baixar
  /// variante da rede.
  static FontWeight _serifWeight(FontWeight w) => w.value >= 700
      ? FontWeight.w700
      : (w.value >= 600 ? FontWeight.w600 : FontWeight.w500);

  /// Títulos de tela, palco e números grandes — a voz do filme (serifa).
  static TextStyle display({
    double size = 28,
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.textOnDark,
    double height = 1.1,
    FontStyle fontStyle = FontStyle.normal,
    bool exact = false,
  }) {
    final fontSize = exact
        ? size
        : AppTypeScale.snap(size, AppTypeScale.display);
    return _cached(
      (#display, fontSize, weight, color, height, fontStyle),
      () => GoogleFonts.cormorantGaramond(
        fontSize: fontSize * _serifOptical,
        fontWeight: _serifWeight(weight),
        color: color,
        height: height,
        fontStyle: fontStyle,
        letterSpacing: 0,
        decoration: TextDecoration.none,
      ),
    );
  }

  /// Versículo / passagem — só leitura bíblica e citação de estudo.
  static TextStyle verse({
    double size = 21,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textOnDark,
    double height = 1.5,
    FontStyle fontStyle = FontStyle.normal,
    bool exact = false,
  }) {
    final fontSize = exact ? size : AppTypeScale.snap(size, AppTypeScale.verse);
    return _cached(
      (#verse, fontSize, weight, color, height, fontStyle),
      () => GoogleFonts.cormorantGaramond(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: TextDecoration.none,
      ),
    );
  }

  /// Lema hebraico / grego — léxico Strong e palavras originais.
  static TextStyle original({
    required bool hebrew,
    double size = 28,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textOnDark,
    double height = 1.35,
  }) {
    return _cached(
      (#original, hebrew, size, weight, color, height),
      () => hebrew
          ? GoogleFonts.notoSerifHebrew(
              fontSize: size,
              fontWeight: weight,
              color: color,
              height: height,
            )
          : GoogleFonts.ebGaramond(
              fontSize: size,
              fontWeight: weight,
              color: color,
              height: height,
            ),
    );
  }

  static TextStyle title({
    double size = 18,
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.textOnDark,
    double height = 1.2,
    bool exact = false,
  }) {
    final fontSize = exact ? size : AppTypeScale.snap(size, AppTypeScale.title);
    return _cached(
      (#title, fontSize, weight, color, height),
      () => GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: -0.1,
        decoration: TextDecoration.none,
      ),
    );
  }

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textOnDark,
    double height = 1.4,
    bool exact = false,
  }) {
    final fontSize = exact ? size : AppTypeScale.snap(size, AppTypeScale.body);
    return _cached(
      (#body, fontSize, weight, color, height),
      () => GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        height: height,
        decoration: TextDecoration.none,
      ),
    );
  }

  static TextStyle label({
    double size = 11,
    FontWeight weight = FontWeight.w800,
    Color color = AppRoles.chrome,
    double letterSpacing = 1.6,
    bool exact = false,
  }) {
    final fontSize = exact ? size : AppTypeScale.snap(size, AppTypeScale.label);
    return _cached(
      (#label, fontSize, weight, color, letterSpacing),
      () => GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        decoration: TextDecoration.none,
      ),
    );
  }

  static TextStyle cta({
    double size = 14,
    Color color = AppColors.inkOnAccent,
    bool exact = false,
  }) {
    final fontSize = exact ? size : AppTypeScale.snap(size, AppTypeScale.cta);
    return _cached(
      (#cta, fontSize, color),
      () => GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 0.4,
        decoration: TextDecoration.none,
      ),
    );
  }
}

/// Raios padronizados — painéis de jogo (menos “blob”, mais HUD).
class AppRadii {
  /// Traços finos: alça de sheet, barras de 2–4px, divisórias.
  static const hair = 2.0;
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 999.0;

  /// Painel de sheet e diálogo.
  static const sheet = xl;
}

/// Espaçamento padronizado.
class AppSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const screen = 20.0;
  static const section = 16.0;
  static const afterTopBar = section;
}

class AppTheme {
  static ThemeData get dark =>
      forStyle(AppearanceStyle.resolve(AppearanceMode.night));

  static ThemeData get light =>
      forStyle(AppearanceStyle.resolve(AppearanceMode.morning));

  /// Material segue a aparência inteira (Claro, Médio, Escuro) — campos,
  /// foco, spinner e snackbar não ficam presos ao papel escuro no Médio.
  static ThemeData forStyle(AppearanceStyle style) =>
      _byLook[style.look] ??= _build(style);

  static final Map<AppearanceLook, ThemeData> _byLook = {};

  static ThemeData _build(AppearanceStyle style) {
    final light = !style.onDark;
    final ink = style.text;
    final surface = style.cardFill;
    final card = style.cardFill;
    final field = light ? style.insetFill : style.cardFillSoft;
    final hairline = light
        ? AppColors.text.withValues(alpha: 0.12)
        : Colors.white12;
    final base = ThemeData(
      useMaterial3: true,
      brightness: light ? Brightness.light : Brightness.dark,
      colorScheme: ColorScheme(
        brightness: light ? Brightness.light : Brightness.dark,
        primary: light ? AppColors.primary : AppColors.primaryLight,
        onPrimary: AppColors.textOnDark,
        secondary: AppColors.accent,
        onSecondary: AppColors.inkOnAccent,
        error: AppColors.error,
        onError: AppColors.textOnDark,
        surface: surface,
        onSurface: ink,
        tertiary: AppColors.teal,
        onTertiary: AppColors.textOnDark,
      ),
      scaffoldBackgroundColor: light
          ? const Color(0xFF6AABDE)
          : AppColors.night,
      cardColor: card,
      dividerColor: hairline,
      canvasColor: surface,
    );

    final bodyTheme = GoogleFonts.nunitoTextTheme(
      base.textTheme,
    ).apply(bodyColor: ink, displayColor: ink);

    return base.copyWith(
      // Toda tela empurrada entra como aproximação de câmera. iOS mantém a
      // transição do sistema para não perder o gesto de voltar deslizando.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CinematicPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CinematicPageTransitionsBuilder(),
          TargetPlatform.linux: CinematicPageTransitionsBuilder(),
          TargetPlatform.windows: CinematicPageTransitionsBuilder(),
        },
      ),
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: (light ? Colors.black : Colors.white).withValues(alpha: 0.04),
      iconTheme: IconThemeData(color: ink),
      textTheme: bodyTheme.copyWith(
        displayLarge: AppTypography.display(size: 34, color: ink),
        displayMedium: AppTypography.display(size: 28, color: ink),
        displaySmall: AppTypography.display(size: 24, color: ink),
        headlineMedium: AppTypography.display(
          size: 22,
          weight: FontWeight.w700,
          color: ink,
        ),
        titleLarge: AppTypography.title(size: 20, color: ink),
        titleMedium: AppTypography.title(size: 16, color: ink),
        bodyLarge: AppTypography.body(size: 15, color: ink),
        bodyMedium: AppTypography.body(size: 14, color: ink),
        labelLarge: AppTypography.label(size: 12, color: ink),
        labelSmall: AppTypography.label(color: ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: style.selected, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: hairline, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.inkOnAccent,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          overlayColor: Colors.black.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.inkOnAccent,
          elevation: 0,
          shadowColor: Colors.transparent,
          overlayColor: Colors.black.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(overlayColor: ink.withValues(alpha: 0.06)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: style.chrome,
        linearTrackColor: hairline,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: style.cardFillSoft,
        contentTextStyle: AppTypography.body(
          size: 14,
          weight: FontWeight.w800,
          color: ink,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(
            color: style.chrome.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        insetPadding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      ),
    );
  }

  static Color parseHex(String hex) {
    final value = hex.replaceAll('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  static List<BoxShadow> glow(Color color, {double blur = 12}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.28),
      blurRadius: blur.clamp(6, 14),
      offset: const Offset(0, 4),
    ),
  ];

  /// Sombra neutra — preferir [AppMetrics.cardShadow] quando houver accent/elevação.
  static List<BoxShadow> cardShadow({bool elevated = false}) =>
      AppLight.shadow(elevated: elevated);
}
