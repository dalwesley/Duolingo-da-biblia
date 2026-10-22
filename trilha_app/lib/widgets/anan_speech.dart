import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cloud_mascot.dart';

/// O Anan falando: ele em cima, ao centro, e o recado num balão claro com a
/// ponta voltada para ele — o mesmo do onboarding, em todo o app.
///
/// Usado onde a tela abre com uma mensagem do Anan (porta de Trilhas,
/// Peregrino+, Em breve, aviso da promo, Apoie, Revisão da semana). O texto
/// dentro do balão usa as tintas de [AnanSpeechBubble] (o fundo é sempre
/// claro, em qualquer visual).
class AnanSpeech extends StatelessWidget {
  final CloudFace face;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double ananSize;

  const AnanSpeech({
    super.key,
    required this.face,
    required this.child,
    this.padding = AnanSpeechBubble.defaultPadding,
    this.ananSize = 88,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CloudMascot(face: face, size: ananSize),
        ),
        const SizedBox(height: AppSpace.sm),
        AnanSpeechBubble(padding: padding, child: child),
      ],
    );
  }
}

/// Balão de fala claro, com a ponta no topo, ao centro, para o Anan acima.
/// Sozinho quando a nuvem entra separada (onboarding).
class AnanSpeechBubble extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  const AnanSpeechBubble({
    super.key,
    required this.child,
    this.padding = defaultPadding,
    this.maxWidth = double.infinity,
  });

  static const defaultPadding = EdgeInsets.fromLTRB(22, 20, 22, 22);

  /// Papel do balão e as tintas sobre ele.
  static const fill = Color(0xFFFFFFFF); // o branco do corpo do Anan
  static const ink = AppColors.text;
  static const muted = AppColors.textMuted;
  static const line = Color(0xFF7E96AE);

  /// Rótulo de destaque (o dourado de [AppRoles.reward], escurecido para
  /// ler sobre o papel).
  static const mark = Color(0xFF8A5A00);

  /// Acabamento da nuvem: contorno e brilho no azul da borda do Anan.
  static const rim = AppRoles.presence;
  static const _rimWidth = 1.5;

  static const _tailWidth = 22.0;
  static const _tailHeight = 11.0;

  @override
  Widget build(BuildContext context) {
    final light = AppearanceStyle.resolve(AppearanceMode.morning);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: rim, width: _rimWidth),
              boxShadow: [
                BoxShadow(
                  color: rim.withValues(alpha: 0.38),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
            // O que lê o visual (rótulos, ícones) lê o papel claro.
            child: Appearance(
              style: light,
              mode: AppearanceMode.morning,
              child: child,
            ),
          ),
          // A base da ponta cobre o contorno do balão; só os dois lados de
          // cima levam o azul.
          const Positioned(
            top: -_tailHeight + _rimWidth,
            child: CustomPaint(
              size: Size(_tailWidth, _tailHeight + _rimWidth),
              painter: _TailPainter(
                fill: fill,
                rim: rim,
                rimWidth: _rimWidth,
                tipHeight: _tailHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ponta do balão: triângulo branco, contorno só nas duas arestas de cima.
class _TailPainter extends CustomPainter {
  final Color fill;
  final Color rim;
  final double rimWidth;
  final double tipHeight;

  const _TailPainter({
    required this.fill,
    required this.rim,
    required this.rimWidth,
    required this.tipHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tip = Offset(size.width / 2, rimWidth / 2);
    final left = Offset(0, tipHeight);
    final right = Offset(size.width, tipHeight);
    canvas.drawPath(
      Path()
        ..moveTo(left.dx, size.height)
        ..lineTo(left.dx, left.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(right.dx, right.dy)
        ..lineTo(right.dx, size.height)
        ..close(),
      Paint()..color = fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left.dx, left.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(right.dx, right.dy),
      Paint()
        ..color = rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = rimWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) =>
      old.fill != fill ||
      old.rim != rim ||
      old.rimWidth != rimWidth ||
      old.tipHeight != tipHeight;
}
