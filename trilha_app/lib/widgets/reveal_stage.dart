import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'cinematic_icon.dart';

// Peças do palco das revelações (semana do grupo, retrospectiva do ano):
// fundo escuro com raios girando em volta do destaque, barras de etapa,
// entradas em subida e o anel de porcentagem.

/// Palco escuro: brilho no alto e raios de luz girando devagar.
class RevealStage extends StatelessWidget {
  final Animation<double> rays;
  final Color color;

  /// Centro dos raios, em fração da tela.
  final Offset focus;

  const RevealStage({
    super.key,
    required this.rays,
    required this.color,
    required this.focus,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: rays,
        builder: (_, _) => CustomPaint(
          painter: _RevealStagePainter(
            turn: rays.value,
            color: color,
            focus: focus,
          ),
        ),
      ),
    );
  }
}

class _RevealStagePainter extends CustomPainter {
  final double turn;
  final Color color;
  final Offset focus;

  _RevealStagePainter({
    required this.turn,
    required this.color,
    required this.focus,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * focus.dx, size.height * focus.dy);
    final reach = size.longestSide;
    // Brilho principal.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.34),
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: center, radius: reach * 0.6)),
    );
    // Raios: cunhas finas que somem para fora.
    const count = 14;
    final rayPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: reach * 0.75));
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(turn * 2 * math.pi);
    for (var i = 0; i < count; i++) {
      final a = i * 2 * math.pi / count;
      const half = math.pi / count * 0.38;
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(math.cos(a - half) * reach, math.sin(a - half) * reach)
        ..lineTo(math.cos(a + half) * reach, math.sin(a + half) * reach)
        ..close();
      canvas.drawPath(path, rayPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RevealStagePainter old) =>
      old.turn != turn || old.color != color || old.focus != focus;
}

/// Barrinhas de progresso das etapas (como stories) e o fechar.
class RevealTopBar extends StatelessWidget {
  final int count;
  final int index;
  final VoidCallback onClose;

  const RevealTopBar({
    super.key,
    required this.count,
    required this.index,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.textOnDark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.sm,
        AppSpace.sm,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < count; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: AnimatedContainer(
                      duration: AppMotion.standard,
                      height: 3,
                      decoration: BoxDecoration(
                        color: ink.withValues(alpha: i <= index ? 0.9 : 0.22),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: CinematicIcon(
              glyph: CinematicGlyph.close,
              size: 30,
              accent: ink.withValues(alpha: 0.85),
              glowing: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// Coluna centrada da etapa; [scroll] quando a lista pode crescer.
class RevealCentered extends StatelessWidget {
  final List<Widget> children;
  final bool scroll;

  const RevealCentered({
    super.key,
    required this.children,
    this.scroll = false,
  });

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: scroll ? MainAxisSize.min : MainAxisSize.max,
      children: children,
    );
    final padded = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.screen,
        vertical: AppSpace.lg,
      ),
      child: column,
    );
    if (!scroll) return padded;
    return LayoutBuilder(
      builder: (_, box) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: Center(child: padded),
        ),
      ),
    );
  }
}

/// Entra subindo e aparecendo, no ritmo de [anim].
class RevealRise extends StatelessWidget {
  final Animation<double> anim;
  final Widget child;
  final double distance;

  const RevealRise({
    super.key,
    required this.anim,
    required this.child,
    this.distance = 0.3,
  });

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: anim,
    child: SlideTransition(
      position: Tween(
        begin: Offset(0, distance),
        end: Offset.zero,
      ).animate(anim),
      child: child,
    ),
  );
}

/// Anel que enche até o acerto do grupo, com o número no meio.
class RevealRing extends StatelessWidget {
  final double value;
  final String label;

  /// 0..1: o brilho que acende quando o anel fecha.
  final double glow;

  /// Cor do começo e da ponta do arco.
  final Color from;
  final Color to;

  const RevealRing({
    super.key,
    required this.value,
    required this.label,
    required this.glow,
    this.from = AppRoles.presence,
    this.to = AppRoles.reward,
  });

  @override
  Widget build(BuildContext context) {
    const size = 230.0;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: from.withValues(alpha: 0.45 * glow),
                  blurRadius: 60,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size.square(size),
            painter: _RevealRingPainter(value: value, from: from, to: to),
          ),
          FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                label,
                style: AppTypography.display(
                  size: 72,
                  exact: true,
                  color: AppColors.textOnDark,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevealRingPainter extends CustomPainter {
  final double value;
  final Color from;
  final Color to;

  _RevealRingPainter({
    required this.value,
    required this.from,
    required this.to,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = (Offset.zero & size).deflate(stroke);
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.textOnDark.withValues(alpha: 0.12),
    );
    if (value <= 0) return;
    // O degradê anda junto com o arco (azul no começo, ouro na ponta) e
    // começa meia espessura antes, para a ponta redonda do início não
    // pegar a cor do fim.
    final radius = rect.width / 2;
    final cap = (stroke / 2) / radius;
    final sweep = 2 * math.pi * value.clamp(0.0, 1.0);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          endAngle: math.min(sweep + 2 * cap, 2 * math.pi),
          colors: [from, to],
          transform: GradientRotation(-math.pi / 2 - cap),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RevealRingPainter old) =>
      old.value != value || old.from != from || old.to != to;
}
