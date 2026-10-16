import 'package:flutter/material.dart';

import '../utils/appearance.dart';
import 'brand_trail.dart';
import 'film_layers.dart';

/// A mesma trilha STWAY do ícone, da splash e do onboarding, no céu
/// escolhido — parada e apagada. Fundo de todas as abas do shell
/// (MainShell); cenário de tela cheia sem véu fica em splash, onboarding
/// e celebração.
///
/// Uma arte por papel: Claro usa a trilha clara pintada; Médio tinge a
/// trilha neutra (cinza) no azul da tarde; Escuro mantém a arte navy com
/// estrelas e véu de sombra.
///
/// Estático de propósito (pinta uma vez).
class HomeBrandBackdrop extends StatefulWidget {
  final AppearanceStyle style;

  const HomeBrandBackdrop({super.key, required this.style});

  static const lightAsset = 'assets/icon/trail_bg_light.jpg';
  static const neutralAsset = 'assets/icon/trail_bg_neutral.jpg';

  @override
  State<HomeBrandBackdrop> createState() => _HomeBrandBackdropState();
}

class _HomeBrandBackdropState extends State<HomeBrandBackdrop> {
  @override
  void initState() {
    super.initState();
    if (BrandTrail.image == null) {
      BrandTrail.ensureLoaded().then((_) {
        if (mounted) setState(() {});
      }, onError: (_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final look = widget.style.look;
    if (look != AppearanceLook.night) {
      return IgnorePointer(child: _PaperArt(look: look));
    }
    final shot = TrailShot.rest
        .copyWith(exposure: 0.8, glow: 0.7, lit: 0.6, lamps: 0.6, stars: 0.7)
        .withSky(widget.style);
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _BackdropPainter(
            shot: shot,
            loaded: BrandTrail.image != null,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Trilha pintada para papel claro/médio. O céu vazio da arte fica em cima
/// e o caminho embaixo, atrás do conteúdo.
class _PaperArt extends StatelessWidget {
  final AppearanceLook look;

  const _PaperArt({required this.look});

  /// Duotone da arte neutra: preto vira o vale da tarde, branco vira o céu.
  static ColorFilter _duotone(Color dark, Color light) {
    double ch(double d, double l) => (l - d) / 255;
    return ColorFilter.matrix([
      ch(dark.r * 255, light.r * 255), 0, 0, 0, dark.r * 255, //
      ch(dark.g * 255, light.g * 255), 0, 0, 0, dark.g * 255, //
      ch(dark.b * 255, light.b * 255), 0, 0, 0, dark.b * 255, //
      0, 0, 0, 1, 0,
    ]);
  }

  static final _afternoon = _duotone(
    const Color(0xFF0E2848),
    const Color(0xFF4A8CD2),
  );

  @override
  Widget build(BuildContext context) {
    final morning = look == AppearanceLook.morning;
    Widget art = Image.asset(
      morning ? HomeBrandBackdrop.lightAsset : HomeBrandBackdrop.neutralAsset,
      fit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
    );
    if (!morning) art = ColorFiltered(colorFilter: _afternoon, child: art);

    // Véu: a arte fica como cenário e os cards na frente leem bem. No Claro
    // é véu de luz; no Médio, uma sombra leve no pé da tela.
    final veil = morning
        ? [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.22),
          ]
        : [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.10),
            Colors.black.withValues(alpha: 0.24),
          ];

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          art,
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: veil,
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  final TrailShot shot;
  final bool loaded;

  _BackdropPainter({required this.shot, required this.loaded});

  @override
  void paint(Canvas canvas, Size size) {
    BrandTrail.paint(canvas, size, shot, loop: 0, calm: true);
    // Véu: a arte fica como cenário, os cards na frente leem bem.
    final full = Offset.zero & size;
    canvas.drawRect(
      full,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.25),
            Colors.black.withValues(alpha: 0.42),
            Colors.black.withValues(alpha: 0.62),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(full),
    );
    FilmLayers.vignette(canvas, size, strength: 0.45);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) => old.loaded != loaded;
}
