import 'package:flutter/material.dart';

/// Diz se a aba do [IndexedStack] está visível.
///
/// Abas inativas devem evitar `context.watch` (congelar o último frame) —
/// senão cada `notifyListeners` redesenha árvores off-screen e trava o gesto.
class ShellTabScope extends InheritedWidget {
  final bool active;

  const ShellTabScope({
    super.key,
    required this.active,
    required super.child,
  });

  static bool of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ShellTabScope>()
            ?.active ??
        true;
  }

  @override
  bool updateShouldNotify(ShellTabScope oldWidget) =>
      active != oldWidget.active;
}

/// Congela o último frame enquanto a aba está oculta (corta Provider rebuilds).
mixin ShellTabFreezeMixin<T extends StatefulWidget> on State<T> {
  Widget? _shellFrozenFrame;

  /// Se a aba está inativa e já há frame, devolve-o sem chamar [buildActive]
  /// (assim `watch` não se reinscreve). Na 1ª montagem (warm) ou quando ativa,
  /// chama [buildActive] e guarda o resultado.
  Widget freezeTab(Widget Function() buildActive) {
    final active = ShellTabScope.of(context);
    if (!active && _shellFrozenFrame != null) return _shellFrozenFrame!;
    final frame = buildActive();
    _shellFrozenFrame = frame;
    return frame;
  }

  /// `true` quando a aba deve escutar serviços (visível).
  bool get tabListens => ShellTabScope.of(context);
}
