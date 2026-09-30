import 'package:flutter/material.dart';

import 'app_motion.dart';

/// Transição padrão entre telas — aproximação de câmera (dolly-in).
///
/// A nova tela entra de leve, crescendo de 97% e acendendo; a de trás recua
/// um pouco e escurece. Sem slide lateral nem corte seco. Com "reduzir
/// movimento", vira só um dissolve.
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

    if (reduced) {
      return FadeTransition(opacity: inCurve, child: child);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([inCurve, outCurve]),
      child: child,
      builder: (context, child) {
        final t = inCurve.value;
        final back = outCurve.value;
        final scale = (0.97 + 0.03 * t) * (1 - 0.02 * back);
        return Opacity(
          opacity: (t.clamp(0.0, 1.0)) * (1 - 0.35 * back),
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}
