import 'package:flutter/material.dart';

import 'app_motion.dart';

/// Transição padrão entre telas — dissolve leve.
///
/// Antes: Opacity + Transform.scale em página inteira (saveLayer + escala
/// a cada frame no Android → abertura travada em mapa/lição/celebração).
/// Agora: só FadeTransition (composited), sem scale. Com "reduzir
/// movimento", dissolve imediato.
class CinematicPageTransitionsBuilder extends PageTransitionsBuilder {
  const CinematicPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduced = AppMotion.reduced(context);
    final inCurve = CurvedAnimation(
      parent: animation,
      curve: AppMotion.enter,
      reverseCurve: AppMotion.exit,
    );
    final outCurve = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.move,
    );

    // Isola a página: o fade não suja o painter das telas pesadas.
    final page = RepaintBoundary(child: child);

    if (reduced) {
      return FadeTransition(opacity: inCurve, child: page);
    }

    // Entrada acende; a de trás só escurece um pouco quando algo sobe.
    return FadeTransition(
      opacity: inCurve,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.92).animate(outCurve),
        child: page,
      ),
    );
  }
}
