import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../cinematic/cinematic_resolver.dart';
import '../theme/app_theme.dart';

/// Fundo atmosférico da Criação — flat/sóbrio, sem bloom nem ponto de luz.
class CinematicBackdrop extends StatefulWidget {
  final CreationWorldState world;
  final double revealProgress;
  final CreationWorldState? revealing;

  const CinematicBackdrop({
    super.key,
    required this.world,
    this.revealProgress = 0,
    this.revealing,
  });

  @override
  State<CinematicBackdrop> createState() => _CinematicBackdropState();
}

class _CinematicBackdropState extends State<CinematicBackdrop> {
  CreationWorldState get _display {
    if (widget.revealing == null || widget.revealProgress <= 0) {
      return widget.world;
    }
    final t = Curves.easeOutCubic.transform(widget.revealProgress);
    final r = widget.revealing!;
    return CreationWorldState(
      voidDepth: _lerp(widget.world.voidDepth, r.voidDepth, t),
      spirit: _lerp(
        widget.world.spirit,
        math.max(widget.world.spirit, r.spirit),
        t,
      ),
      waters: _lerp(
        widget.world.waters,
        math.max(widget.world.waters, r.waters),
        t,
      ),
      light: _lerp(
        widget.world.light,
        math.max(widget.world.light, r.light),
        t,
      ),
      land: _lerp(widget.world.land, math.max(widget.world.land, r.land), t),
      plants: _lerp(
        widget.world.plants,
        math.max(widget.world.plants, r.plants),
        t,
      ),
      fish: _lerp(widget.world.fish, math.max(widget.world.fish, r.fish), t),
      birds: _lerp(
        widget.world.birds,
        math.max(widget.world.birds, r.birds),
        t,
      ),
      stars: _lerp(
        widget.world.stars,
        math.max(widget.world.stars, r.stars),
        t,
      ),
      humanity: _lerp(
        widget.world.humanity,
        math.max(widget.world.humanity, r.humanity),
        t,
      ),
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AtmospherePainter(state: _display),
        size: Size.infinite,
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  final CreationWorldState state;

  _AtmospherePainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final night = Color.lerp(
      AppColors.night,
      const Color(0xFF0C1020),
      (1 - state.voidDepth).clamp(0.0, 1.0),
    )!;
    canvas.drawRect(Offset.zero & size, Paint()..color = night);

    final skyTop = Color.lerp(
      const Color(0xFF0A1010),
      Color.lerp(
        const Color(0xFF1A3040),
        const Color(0xFF2A4A50),
        state.light * 0.5,
      )!,
      (state.light * 0.4 + state.spirit * 0.15).clamp(0.0, 1.0),
    )!;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, night, const Color(0xFF030208)],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(Offset.zero & size),
    );

    final horizon =
        (state.waters * 0.55 + state.land * 0.35 + state.fish * 0.15).clamp(
          0.0,
          1.0,
        );
    if (horizon > 0.04) {
      final bandTop = size.height * (0.58 - state.land * 0.04);
      final waterColor = Color.lerp(
        const Color(0xFF0E1C30),
        const Color(0xFF163A58),
        state.waters,
      )!;
      final landTint = Color.lerp(
        waterColor,
        const Color(0xFF1A2E22),
        state.land * 0.7,
      )!;
      final lifeTint = Color.lerp(
        landTint,
        const Color(0xFF1E3A2A),
        (state.plants * 0.5 + state.fish * 0.2).clamp(0.0, 1.0),
      )!;

      canvas.drawRect(
        Rect.fromLTRB(0, bandTop, size.width, size.height),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lifeTint.withValues(alpha: horizon * 0.3),
              lifeTint.withValues(alpha: horizon * 0.6),
              AppColors.night.withValues(alpha: 0.95),
            ],
            stops: const [0.0, 0.35, 1.0],
          ).createShader(Rect.fromLTRB(0, bandTop, size.width, size.height)),
      );
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.12),
            Colors.black.withValues(alpha: 0.4),
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.38, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter old) => old.state != state;
}
