import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Chuva de 👋 subindo — o aceno chegou em casa.
class WaveHandsOverlay extends StatefulWidget {
  final bool active;

  const WaveHandsOverlay({super.key, required this.active});

  @override
  State<WaveHandsOverlay> createState() => _WaveHandsOverlayState();
}

class _WaveHandsOverlayState extends State<WaveHandsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tick;
  late final List<_WaveHand> _hands;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(7);
    _hands = List.generate(10, (i) {
      return _WaveHand(
        x: 0.08 + rng.nextDouble() * 0.84,
        delay: rng.nextDouble() * 0.35,
        duration: 3.4 + rng.nextDouble() * 2.4,
        size: 22 + rng.nextDouble() * 18,
        spin: (rng.nextDouble() - 0.5) * 0.7,
        drift: (rng.nextDouble() - 0.5) * 0.16,
      );
    });
    _tick = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    if (widget.active) _tick.forward();
  }

  @override
  void didUpdateWidget(covariant WaveHandsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _tick.forward(from: 0);
    } else if (!widget.active && _tick.isAnimating) {
      _tick.stop();
      _tick.reset();
    }
  }

  @override
  void dispose() {
    _tick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _tick,
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                for (final hand in _hands)
                  _WaveHandView(hand: hand, t: _tick.value),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WaveHand {
  final double x;
  final double delay;
  final double duration;
  final double size;
  final double spin;
  final double drift;

  const _WaveHand({
    required this.x,
    required this.delay,
    required this.duration,
    required this.size,
    required this.spin,
    required this.drift,
  });
}

class _WaveHandView extends StatelessWidget {
  final _WaveHand hand;
  final double t;

  const _WaveHandView({required this.hand, required this.t});

  @override
  Widget build(BuildContext context) {
    // Uma subida só — delay espalha as mãos no burst.
    final local = ((t - hand.delay) / (1 - hand.delay).clamp(0.35, 1.0))
        .clamp(0.0, 1.0);
    final y = 1.08 - local * 1.22;
    final x = (hand.x + math.sin(local * math.pi * 2) * hand.drift).clamp(
      0.0,
      1.0,
    );
    final fade = local < 0.12
        ? local / 0.12
        : local > 0.82
        ? (1 - local) / 0.18
        : 1.0;
    final angle = math.sin(local * math.pi * 3) * hand.spin;

    return Align(
      alignment: Alignment(-1 + x * 2, -1 + y * 2),
      child: Opacity(
        opacity: fade.clamp(0.0, 0.95),
        child: Transform.rotate(
          angle: angle,
          child: Text('👋', style: TextStyle(fontSize: hand.size, height: 1)),
        ),
      ),
    );
  }
}
