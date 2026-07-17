import 'package:flutter/material.dart';

/// Espaço inferior para conteúdo rolar acima do menu flutuante.
/// Nav = 64 + padding inferior (~16) + folga de toque (~24).
double scrollPaddingBelowNav(BuildContext context) {
  return 104 + MediaQuery.of(context).padding.bottom;
}
