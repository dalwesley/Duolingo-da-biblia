import 'dart:math' as math;

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

/// O Anan ao lado, falando: nuvem pequena à esquerda e o balão com a ponta
/// para ele. Mesmo cabeçalho na abertura da cena e em cada gesto. Dá um
/// pulinho quando [hop] muda para um valor não nulo (ex.: cada escolha).
///
/// Com [back], o balão tem verso: [flipped] o vira na vertical para mostrar
/// [back] (ex.: a dica) e [onTap] deixa a pessoa virar de volta.
///
/// Com [onAnanTap], o próprio Anan vira botão (ajuda da cena): leva um selo
/// "!" em cima. [beckon] o faz balançar de tempos em tempos e [caption]
/// escreve o convite embaixo dele ("Toque em mim", "Ajuda?").
class AnanSideSpeech extends StatefulWidget {
  final Widget child;
  final Object? hop;
  final CloudFace face;
  final Widget? back;
  final bool flipped;
  final VoidCallback? onTap;
  final VoidCallback? onAnanTap;
  final String? ananLabel;
  final bool beckon;
  final String? caption;

  const AnanSideSpeech({
    super.key,
    required this.child,
    this.hop,
    this.face = CloudFace.feliz,
    this.back,
    this.flipped = false,
    this.onTap,
    this.onAnanTap,
    this.ananLabel,
    this.beckon = false,
    this.caption,
  });

  static const ananSize = 52.0;
  static const padding = EdgeInsets.fromLTRB(16, 12, 16, 14);

  @override
  State<AnanSideSpeech> createState() => _AnanSideSpeechState();
}

class _AnanSideSpeechState extends State<AnanSideSpeech>
    with TickerProviderStateMixin {
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  // Criado já no initState: preguiçoso, nasceria no primeiro virar com o
  // valor final e o balão trocaria de lado sem girar.
  late final AnimationController _flip;

  /// Balanço de chamar: um ciclo a cada 2,4 s enquanto [beckon].
  late final AnimationController _beckon = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: widget.flipped ? 1 : 0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBeckon();
  }

  void _syncBeckon() {
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.beckon && !still) {
      if (!_beckon.isAnimating) _beckon.repeat();
    } else if (_beckon.isAnimating || _beckon.value != 0) {
      _beckon
        ..stop()
        ..value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant AnanSideSpeech oldWidget) {
    super.didUpdateWidget(oldWidget);
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!still && widget.hop != null && widget.hop != oldWidget.hop) {
      _hop.forward(from: 0);
    }
    if (widget.beckon != oldWidget.beckon) _syncBeckon();
    if (widget.flipped != oldWidget.flipped) {
      final target = widget.flipped ? 1.0 : 0.0;
      if (still) {
        _flip.value = target;
      } else {
        _flip.animateTo(target, curve: AppMotion.move);
      }
    }
  }

  @override
  void dispose() {
    _hop.dispose();
    _flip.dispose();
    _beckon.dispose();
    super.dispose();
  }

  /// Frente e verso no mesmo lugar: o balão fica com a altura do maior,
  /// e só o lado virado para a pessoa aparece.
  Widget _bubble() {
    final back = widget.back;
    if (back == null) {
      return AnanSpeechBubble(
        tail: AnanTail.left,
        padding: AnanSideSpeech.padding,
        child: widget.child,
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flip,
        builder: (context, _) {
          final t = _flip.value;
          final showBack = t >= 0.5;
          final angle = showBack ? (t - 1) * math.pi : t * math.pi;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateX(angle),
            child: AnanSpeechBubble(
              tail: AnanTail.left,
              padding: AnanSideSpeech.padding,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Visibility(
                    visible: !showBack,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: widget.child,
                  ),
                  Visibility(
                    visible: showBack,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: back,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _anan() {
    Widget anan = AnimatedBuilder(
      animation: _hop,
      builder: (context, child) {
        final t = math.sin(_hop.value * math.pi);
        return Transform.translate(
          offset: Offset(0, -6 * t),
          child: Transform.scale(scale: 1 + 0.06 * t, child: child),
        );
      },
      child: CloudMascot(
        face: widget.face,
        size: AnanSideSpeech.ananSize,
        react: false,
      ),
    );
    final tap = widget.onAnanTap;
    if (tap == null) return anan;

    anan = AnimatedBuilder(
      animation: _beckon,
      builder: (context, child) {
        // Balança no primeiro terço do ciclo e descansa no resto.
        final p = (_beckon.value / 0.34).clamp(0.0, 1.0);
        final w = p >= 1 ? 0.0 : math.sin(p * math.pi * 4) * (1 - p);
        return Transform.rotate(angle: 0.14 * w, child: child);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          anan,
          Positioned(
            top: -6,
            right: -6,
            child: _HelpSeal(pulse: _beckon, lit: widget.beckon),
          ),
        ],
      ),
    );
    final caption = widget.caption?.trim() ?? '';
    return Semantics(
      button: true,
      label: widget.ananLabel,
      // O rótulo já diz tudo; o "!" e o convite são só para o olho.
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tap,
        child: ConstrainedBox(
          // Alvo de toque confortável mesmo com a nuvem pequena.
          constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              anan,
              AnimatedSize(
                duration: AppMotion.standard,
                curve: AppMotion.enter,
                alignment: Alignment.topCenter,
                child: caption.isEmpty
                    ? const SizedBox(width: AnanSideSpeech.ananSize)
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _Caption(text: caption),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _anan(),
        const SizedBox(width: 14),
        Expanded(child: _bubble()),
      ],
    );
  }
}

/// Selo "!" em cima do Anan: diz que ele atende ao toque. Chamando, brilha.
class _HelpSeal extends StatelessWidget {
  final Animation<double> pulse;
  final bool lit;

  const _HelpSeal({required this.pulse, required this.lit});

  static const _size = 20.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final glow = lit ? 0.35 + 0.4 * math.sin(pulse.value * math.pi) : 0.0;
        return Container(
          width: _size,
          height: _size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AnanSpeechBubble.fill,
            border: Border.all(color: AnanSpeechBubble.rim, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppRoles.action.withValues(alpha: glow),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Text(
        '!',
        style: AppTypography.title(
          size: 13,
          height: 1,
          exact: true,
          color: AnanSpeechBubble.mark,
        ),
      ),
    );
  }
}

/// Convite curto embaixo do Anan, no mesmo papel do balão.
class _Caption extends StatelessWidget {
  final String text;

  const _Caption({required this.text});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 76),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AnanSpeechBubble.fill,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AnanSpeechBubble.rim, width: 1),
        ),
        child: Text(
          text,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body(
            size: 11,
            height: 1.15,
            exact: true,
            weight: FontWeight.w800,
            color: AnanSpeechBubble.mark,
          ),
        ),
      ),
    );
  }
}

/// De que lado está o Anan: a ponta do balão aponta para ele.
enum AnanTail {
  /// Anan acima, ao centro (padrão do onboarding).
  top,

  /// Anan à esquerda, no meio da altura (enunciado da cena).
  left,
}

/// Balão de fala claro, com a ponta no topo, ao centro, para o Anan acima.
/// Sozinho quando a nuvem entra separada (onboarding).
class AnanSpeechBubble extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;
  final AnanTail tail;

  const AnanSpeechBubble({
    super.key,
    required this.child,
    this.padding = defaultPadding,
    this.maxWidth = double.infinity,
    this.tail = AnanTail.top,
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

  static const _tailPaint = CustomPaint(
    size: Size(_tailWidth, _tailHeight + _rimWidth),
    painter: _TailPainter(
      fill: fill,
      rim: rim,
      rimWidth: _rimWidth,
      tipHeight: _tailHeight,
    ),
  );

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
          // fora levam o azul.
          if (tail == AnanTail.top)
            const Positioned(top: -_tailHeight + _rimWidth, child: _tailPaint)
          else
            const Positioned(
              left: -_tailHeight + _rimWidth,
              top: 0,
              bottom: 0,
              child: Center(
                child: RotatedBox(quarterTurns: 3, child: _tailPaint),
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
