import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'stage_plate.dart';
import 'stway_brand.dart';

/// Carta de palco: um toque gira e mostra a marca no verso.
class BrandFlipCard extends StatefulWidget {
  final Color accent;
  final Widget front;

  /// Resposta escolhida. Quando entra ou muda, o verso volta para a frente.
  final String? answer;

  const BrandFlipCard({
    super.key,
    required this.accent,
    required this.front,
    this.answer,
  });

  @override
  State<BrandFlipCard> createState() => _BrandFlipCardState();
}

class _BrandFlipCardState extends State<BrandFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip;
  bool _onBack = false;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..addListener(_onFlipTick);
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _onFlipTick() {
    final onBack = _flip.value >= 0.5;
    if (onBack == _onBack) return;
    _onBack = onBack;
    HapticFeedback.selectionClick();
  }

  @override
  void didUpdateWidget(covariant BrandFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final picked = widget.answer;
    if (picked != null && picked != oldWidget.answer) _showFront();
  }

  void _toggle() {
    if (_flip.isAnimating) return;
    HapticFeedback.lightImpact();
    if (_flip.value == 0) {
      _flip.forward();
    } else {
      _flip.reverse();
    }
  }

  void _showFront() {
    if (_flip.value == 0) return;
    _flip.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _flip,
        builder: (context, _) {
          final angle = Curves.easeInOutCubic.transform(_flip.value) * math.pi;
          final showFront = angle <= math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: Transform(
              alignment: Alignment.center,
              transform: showFront
                  ? Matrix4.identity()
                  : Matrix4.rotationY(math.pi),
              child: showFront
                  ? widget.front
                  : _BrandBack(accent: widget.accent),
            ),
          );
        },
      ),
    );
  }
}

class _BrandBack extends StatelessWidget {
  final Color accent;

  const _BrandBack({required this.accent});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(StagePlate.radius);
    return DecoratedBox(
      decoration: StagePlate.decoration(accent: accent),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const StwayPathBackdrop(alignment: Alignment.center),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: FittedBox(fit: BoxFit.scaleDown, child: _CardWordmark()),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardWordmark extends StatelessWidget {
  const _CardWordmark();

  static const _size = 40.0;
  static const _tracking = 5.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: StwayWordmark(
            fontSize: _size,
            letterSpacing: _tracking,
            letterColor: Colors.black.withValues(alpha: 0.72),
            aColor: Colors.black.withValues(alpha: 0.72),
          ),
        ),
        const StwayWordmark(fontSize: _size, letterSpacing: _tracking),
      ],
    );
  }
}
