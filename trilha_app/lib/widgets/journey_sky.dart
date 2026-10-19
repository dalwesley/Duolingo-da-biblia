import 'package:flutter/material.dart';

import '../models/trail_catalog.dart';
import '../utils/appearance.dart';
import 'home_brand_backdrop.dart';
import 'immersive_background.dart';
import 'realm_world_atmosphere.dart';
import 'ui_primitives.dart';

/// Céu compartilhado entre o pôster da aba Trilhas, o topo da tela do
/// caminho e o topo do mapa da trilha. Mesma tag: o céu voa entre elas.
String journeySkyTag(TrailJourney journey) => 'journey-sky-${journey.name}';

/// Durante o voo o céu perde o canto arredondado do pôster aos poucos.
Widget journeySkyShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromContext,
  BuildContext toContext,
) {
  final hero =
      (direction == HeroFlightDirection.push ? toContext : fromContext).widget
          as Hero;
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) => ClipRRect(
      borderRadius: BorderRadius.circular(
        AppMetrics.heroRadius * (1 - animation.value),
      ),
      child: child,
    ),
    child: hero.child,
  );
}

/// Fundo das abas (arte STWAY do tema) com o céu da área no topo, que se
/// desfaz na arte. Parado: a lista rola por cima.
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
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black, Colors.transparent],
              stops: [0.0, 0.45, 1.0],
            ).createShader(rect),
            child: Hero(
              tag: journeySkyTag(journey),
              flightShuttleBuilder: journeySkyShuttle,
              child: RealmWorldAtmosphere(realm: journey.realm, featured: true),
            ),
          ),
        ),
      ],
    );
  }
}
