import 'package:flutter/material.dart';

/// Espaço inferior para conteúdo rolar acima do menu flutuante.
double scrollPaddingBelowNav(BuildContext context) {
  return 88 + MediaQuery.of(context).padding.bottom;
}
