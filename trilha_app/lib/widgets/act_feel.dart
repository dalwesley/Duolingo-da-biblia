import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Vocabulário háptico dos atos — um gesto, um toque.
class ActHaptics {
  static void tap() => HapticFeedback.selectionClick();
  static void confirm() => HapticFeedback.mediumImpact();
  static void success() => HapticFeedback.heavyImpact();
  static void error() => HapticFeedback.vibrate();
  static void tick() => HapticFeedback.selectionClick();
}

/// Press-down 3D: a face desce sobre o lip, como o CTA.
class ActPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double depth;

  const ActPress({
    super.key,
    required this.child,
    this.onTap,
    this.depth = 3,
  });

  @override
  State<ActPress> createState() => _ActPressState();
}

class _ActPressState extends State<ActPress> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          enabled && _down ? widget.depth : 0,
          0,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Shake horizontal no erro — 4 oscilações curtas.
class ActShake extends StatefulWidget {
  final bool active;
  final Widget child;

  const ActShake({super.key, required this.active, required this.child});

  @override
  State<ActShake> createState() => _ActShakeState();
}

class _ActShakeState extends State<ActShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    if (widget.active) _ctrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant ActShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value;
        final wave = math.sin(t * math.pi * 8) * 6 * (1 - t);
        return Transform.translate(offset: Offset(wave, 0), child: child);
      },
      child: widget.child,
    );
  }
}
