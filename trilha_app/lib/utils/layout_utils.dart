import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

const _navBarHeight = 64.0;
const _navBottomExtra = 6.0;
const _contentGap = 8.0;

/// Espaço inferior para conteúdo rolar acima do menu flutuante.
/// Espelha [MainBottomNav]: 64 de altura + margem inferior + folga mínima.
double scrollPaddingBelowNav(BuildContext context) {
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  final navBottomMargin =
      bottomInset > 0 ? bottomInset + _navBottomExtra : AppSpace.md;
  return _navBarHeight + navBottomMargin + _contentGap;
}
