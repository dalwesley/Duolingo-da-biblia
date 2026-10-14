import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Largura do miolo no tablet. Abaixo disso o layout é o do celular.
const contentMaxWidth = 560.0;

/// Palco da cena (versículo). No tablet não cresce até o fim da tela.
const stageMaxHeight = 460.0;

/// Folga de cada lado para o miolo caber em [contentMaxWidth].
/// Zero quando a largura já é a do celular.
double contentGutterOf(double width) {
  if (!width.isFinite || width <= contentMaxWidth) return 0;
  return (width - contentMaxWidth) / 2;
}

/// Centraliza o miolo quando a tela passa de [contentMaxWidth].
/// O céu fica de fora a fora; só o conteúdo entra na coluna.
class ContentFrame extends StatelessWidget {
  final Widget child;

  const ContentFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (!width.isFinite || width <= contentMaxWidth) return child;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (width - contentMaxWidth) / 2,
          ),
          child: child,
        );
      },
    );
  }
}

const _navBarHeight = 64.0;
const _navBottomExtra = 6.0;
const _contentGap = 8.0;

/// Espaço inferior para conteúdo rolar acima do menu flutuante.
/// Espelha [MainBottomNav]: 64 de altura + margem inferior + folga mínima.
double scrollPaddingBelowNav(BuildContext context) {
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  final navBottomMargin = bottomInset > 0
      ? bottomInset + _navBottomExtra
      : AppSpace.md;
  return _navBarHeight + navBottomMargin + _contentGap;
}
