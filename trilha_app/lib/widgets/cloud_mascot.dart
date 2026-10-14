import 'package:flutter/material.dart';

/// A nuvem que acompanhou o povo no deserto — a companheira da trilha.
enum CloudFace {
  feliz,
  triste,
  sucesso,
  erro,
  carregando;

  String get asset => switch (this) {
    CloudFace.feliz => 'assets/mascot/cloud_feliz.png',
    CloudFace.triste => 'assets/mascot/cloud_triste.png',
    CloudFace.sucesso => 'assets/mascot/cloud_sucesso.png',
    CloudFace.erro => 'assets/mascot/cloud_erro.png',
    CloudFace.carregando => 'assets/mascot/cloud_carregando.png',
  };
}

class CloudMascot extends StatelessWidget {
  final CloudFace face;
  final double size;

  const CloudMascot({super.key, required this.face, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      face.asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    );
    if (face != CloudFace.carregando) return image;
    return _CloudFloat(child: image);
  }
}

/// Sobe e desce devagar — só a cara de espera.
class _CloudFloat extends StatefulWidget {
  final Widget child;

  const _CloudFloat({required this.child});

  @override
  State<_CloudFloat> createState() => _CloudFloatState();
}

class _CloudFloatState extends State<_CloudFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final dy = (_float.value - 0.5) * 6;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}
