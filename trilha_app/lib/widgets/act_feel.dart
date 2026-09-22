import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Vocabulário háptico dos atos — um gesto, um toque.
class ActHaptics {
  static void tap() => HapticFeedback.selectionClick();
  static void confirm() => HapticFeedback.mediumImpact();
  static void success() => HapticFeedback.heavyImpact();
  static void error() => HapticFeedback.heavyImpact();
  static void tick() => HapticFeedback.selectionClick();
}

/// Press-down 3D: a face desce sobre o lip, como o CTA.
class ActPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double depth;

  const ActPress({super.key, required this.child, this.onTap, this.depth = 3});

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
    if (widget.active) _queuePlay();
  }

  @override
  void didUpdateWidget(covariant ActShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _queuePlay();
    }
  }

  /// `forward()` no `initState`/`didUpdateWidget` cai no meio do rebuild:
  /// o ticker ainda não tiqueta, e o primeiro erro passa sem tremer.
  void _queuePlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.active) return;
      _ctrl.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = _ctrl.value;
          final wave = math.sin(t * math.pi * 8) * 6 * (1 - t);
          return Transform.translate(offset: Offset(wave, 0), child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// Faíscas curtas no acerto — o palco responde, não a tela de celebração.
class ActSparkBurst extends StatefulWidget {
  final bool active;
  final Color color;

  const ActSparkBurst({super.key, required this.active, required this.color});

  @override
  State<ActSparkBurst> createState() => _ActSparkBurstState();
}

class _ActSparkBurstState extends State<ActSparkBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late List<_Spark> _sparks;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _sparks = _spawn(42);
    if (widget.active) _ctrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant ActSparkBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _sparks = _spawn(DateTime.now().microsecondsSinceEpoch);
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<_Spark> _spawn(int seed) {
    final rng = math.Random(seed);
    return List.generate(14, (i) {
      final a = (i / 14) * math.pi * 2 + rng.nextDouble() * 0.4;
      return _Spark(
        angle: a,
        dist: 28 + rng.nextDouble() * 52,
        size: 2.4 + rng.nextDouble() * 3.2,
        delay: rng.nextDouble() * 0.18,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active && _ctrl.isDismissed) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _SparkPainter(
              progress: _ctrl.value,
              sparks: _sparks,
              color: widget.color,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Spark {
  final double angle;
  final double dist;
  final double size;
  final double delay;

  const _Spark({
    required this.angle,
    required this.dist,
    required this.size,
    required this.delay,
  });
}

class _SparkPainter extends CustomPainter {
  final double progress;
  final List<_Spark> sparks;
  final Color color;

  const _SparkPainter({
    required this.progress,
    required this.sparks,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.5, size.height * 0.38);
    for (final s in sparks) {
      final t = ((progress - s.delay) / (1 - s.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final ease = Curves.easeOutCubic.transform(t);
      final fade = (1 - t);
      final p =
          origin + Offset(math.cos(s.angle), math.sin(s.angle)) * s.dist * ease;
      canvas.drawCircle(
        p,
        s.size * (0.55 + fade * 0.45),
        Paint()..color = color.withValues(alpha: 0.85 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      old.progress != progress || old.color != color;
}

/// Peça de ordenar no ar — sobe, gira um fio, ganha sombra.
class ActDragProxy extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const ActDragProxy({super.key, required this.child, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(animation.value);
        return Transform.rotate(
          angle: 0.03 * t,
          child: Transform.scale(
            scale: 1.04 + 0.02 * t,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45 * t),
                    blurRadius: 22 * t,
                    offset: Offset(0, 10 * t),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// Poço da letra A/B/C/D — o gesto Escolher/Completar ganha identidade.
class ActLetterWell extends StatelessWidget {
  final String mark;
  final Color accent;
  final Color foreground;
  final bool hot;

  const ActLetterWell({
    super.key,
    required this.mark,
    required this.accent,
    required this.foreground,
    this.hot = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hot ? accent : Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: hot ? accent : Colors.white.withValues(alpha: 0.28),
          width: hot ? 0 : 1.4,
        ),
      ),
      child: Text(
        mark,
        style: AppTypography.title(
          size: 13,
          color: hot ? AppColors.inkOnAccent : foreground,
        ),
      ),
    );
  }
}
