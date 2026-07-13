import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../cinematic/cinematic_resolver.dart';

/// Fundo atmosférico da Criação — camadas abstratas, sem figuras cartoon.
/// A ideia: o mundo se revela em luz e cor, sem competir com a pergunta.
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
    if (widget.revealing == null || widget.revealProgress <= 0) return widget.world;
    final t = Curves.easeOutCubic.transform(widget.revealProgress);
    final r = widget.revealing!;
    return CreationWorldState(
      voidDepth: _lerp(widget.world.voidDepth, r.voidDepth, t),
      spirit: _lerp(widget.world.spirit, math.max(widget.world.spirit, r.spirit), t),
      waters: _lerp(widget.world.waters, math.max(widget.world.waters, r.waters), t),
      light: _lerp(widget.world.light, math.max(widget.world.light, r.light), t),
      land: _lerp(widget.world.land, math.max(widget.world.land, r.land), t),
      plants: _lerp(widget.world.plants, math.max(widget.world.plants, r.plants), t),
      fish: _lerp(widget.world.fish, math.max(widget.world.fish, r.fish), t),
      birds: _lerp(widget.world.birds, math.max(widget.world.birds, r.birds), t),
      stars: _lerp(widget.world.stars, math.max(widget.world.stars, r.stars), t),
      humanity: _lerp(widget.world.humanity, math.max(widget.world.humanity, r.humanity), t),
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AtmospherePainter(state: _display, time: 0.25),
        size: Size.infinite,
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  final CreationWorldState state;
  final double time;

  _AtmospherePainter({required this.state, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final breath = (math.sin(time * math.pi * 2) + 1) / 2;

    // Base — noite profunda
    final night = Color.lerp(
      const Color(0xFF05040A),
      const Color(0xFF0C1020),
      (1 - state.voidDepth).clamp(0.0, 1.0),
    )!;
    canvas.drawRect(Offset.zero & size, Paint()..color = night);

    // Céu superior — responde à luz / espírito
    final skyTop = Color.lerp(
      const Color(0xFF0A0814),
      Color.lerp(const Color(0xFF1A2850), const Color(0xFF3A5A8A), state.light * 0.7)!,
      (state.light * 0.55 + state.spirit * 0.25).clamp(0.0, 1.0),
    )!;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            skyTop,
            night,
            const Color(0xFF030208),
          ],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Aura ambiente — evita fundo “morto” mesmo no vazio
    final auraCenter = Offset(size.width * 0.5, size.height * 0.32);
    canvas.drawCircle(
      auraCenter,
      size.width * (0.55 + 0.04 * breath),
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(const Color(0xFF3D2B69), const Color(0xFFE8B84B), state.light * 0.4)!
                .withValues(alpha: 0.1 + 0.08 * breath + state.spirit * 0.12),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: auraCenter, radius: size.width * 0.6)),
    );

    // Estrelas — só no terço superior, bem sutis
    final starStrength = math.max(state.stars, state.voidDepth * 0.25);
    if (starStrength > 0.05) {
      final rng = math.Random(42);
      final count = (28 + starStrength * 40).round();
      for (var i = 0; i < count; i++) {
        final x = rng.nextDouble() * size.width;
        final y = rng.nextDouble() * size.height * 0.38;
        final twinkle = 0.55 + 0.45 * ((math.sin(time * math.pi * 2 + i * 0.7) + 1) / 2);
        canvas.drawCircle(
          Offset(x, y),
          0.6 + rng.nextDouble() * 1.1,
          Paint()..color = Colors.white.withValues(alpha: starStrength * 0.22 * twinkle),
        );
      }
    }

    // Luz divina — glow suave no alto (sem raios)
    if (state.light > 0.04) {
      final center = Offset(size.width * 0.5, size.height * 0.12);
      final radius = size.width * (0.55 + state.light * 0.35 + breath * 0.03);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFF6D8).withValues(alpha: state.light * 0.28),
              const Color(0xFFE8B84B).withValues(alpha: state.light * 0.12),
              Colors.transparent,
            ],
            stops: const [0.0, 0.35, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    // Espírito — véu violeta bem suave
    if (state.spirit > 0.04) {
      final c = Offset(size.width * 0.5, size.height * 0.05);
      final r = size.width * 0.5 * state.spirit;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF7B6FD6).withValues(alpha: state.spirit * 0.18),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    // Horizonte / águas — banda inferior abstrata
    final horizon = (state.waters * 0.55 + state.land * 0.35 + state.fish * 0.15).clamp(0.0, 1.0);
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
              lifeTint.withValues(alpha: horizon * 0.35),
              lifeTint.withValues(alpha: horizon * 0.7),
              const Color(0xFF05080E).withValues(alpha: 0.95),
            ],
            stops: const [0.0, 0.35, 1.0],
          ).createShader(Rect.fromLTRB(0, bandTop, size.width, size.height)),
      );

      // Linha de horizonte suave
      canvas.drawRect(
        Rect.fromLTWH(0, bandTop, size.width, 1.5),
        Paint()..color = Colors.white.withValues(alpha: horizon * 0.08),
      );
    }

    // Humanidade / vida — só um brilho âmbar discreto no horizonte (sem silhueta)
    final lifeGlow = (state.humanity * 0.7 + state.plants * 0.25 + state.birds * 0.15).clamp(0.0, 1.0);
    if (lifeGlow > 0.05) {
      final c = Offset(size.width * 0.5, size.height * 0.52);
      final r = size.width * 0.28;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFE8B84B).withValues(alpha: lifeGlow * 0.12),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    // Escurece a zona das opções — legibilidade primeiro
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.15),
            Colors.black.withValues(alpha: 0.45),
            Colors.black.withValues(alpha: 0.72),
          ],
          stops: const [0.0, 0.38, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Vinheta lateral leve
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.15),
          radius: 1.15,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.4),
          ],
          stops: const [0.55, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter old) =>
      old.time != time || old.state != state;
}
