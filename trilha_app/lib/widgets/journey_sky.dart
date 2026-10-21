import 'package:flutter/material.dart';

import '../models/trail_catalog.dart';
import '../utils/appearance.dart';
import 'home_brand_backdrop.dart';
import 'immersive_background.dart';
import 'realm_world_atmosphere.dart';

/// Máscara do céu parado: o pé some na arte STWAY.
const LinearGradient _journeySkyMask = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Colors.black, Colors.black, Colors.transparent],
  stops: [0.0, 0.45, 1.0],
);

/// Fundo das abas (arte STWAY do tema) com o céu da área no topo, que se
/// desfaz na arte. Parado: a lista rola por cima. Sem voo — a imagem do
/// card mudando de tamanho até aqui travava.
class JourneySkyBackdrop extends StatelessWidget {
  final TrailJourney journey;
  final AppearanceStyle appearance;

  const JourneySkyBackdrop({
    super.key,
    required this.journey,
    required this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AmbientAtmosphere(phase: appearance.phase),
        HomeBrandBackdrop(style: appearance),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.sizeOf(context).height * 0.42,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => _journeySkyMask.createShader(rect),
            child: RealmWorldAtmosphere(
              realm: journey.realm,
              featured: true,
              // O céu parado não repinta dentro da máscara.
              animate: false,
            ),
          ),
        ),
      ],
    );
  }
}
