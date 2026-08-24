/// Estado cumulativo do mundo da Criação — cada camada vai de 0.0 a 1.0.
class CreationWorldState {
  final double voidDepth;
  final double spirit;
  final double waters;
  final double light;
  final double land;
  final double plants;
  final double fish;
  final double birds;
  final double stars;
  final double humanity;

  const CreationWorldState({
    this.voidDepth = 1,
    this.spirit = 0,
    this.waters = 0,
    this.light = 0,
    this.land = 0,
    this.plants = 0,
    this.fish = 0,
    this.birds = 0,
    this.stars = 0,
    this.humanity = 0,
  });

  CreationWorldState mergeMax(CreationWorldState other) {
    return CreationWorldState(
      voidDepth: voidDepth * (1 - other.light.clamp(0, 1)),
      spirit: spirit > other.spirit ? spirit : other.spirit,
      waters: waters > other.waters ? waters : other.waters,
      light: light > other.light ? light : other.light,
      land: land > other.land ? land : other.land,
      plants: plants > other.plants ? plants : other.plants,
      fish: fish > other.fish ? fish : other.fish,
      birds: birds > other.birds ? birds : other.birds,
      stars: stars > other.stars ? stars : other.stars,
      humanity: humanity > other.humanity ? humanity : other.humanity,
    );
  }
}

enum CinematicRevealKey {
  spirit,
  waters,
  light,
  land,
  plants,
  fish,
  birds,
  stars,
  humanity,
  cosmos,
}

CinematicRevealKey? revealKeyFromCorrectText(String correctText) {
  final t = correctText.toLowerCase();
  if (t.contains('luz')) return CinematicRevealKey.light;
  if (t.contains('peixe')) return CinematicRevealKey.fish;
  if (t.contains('ave') || t.contains('pássaro') || t.contains('passaro')) {
    return CinematicRevealKey.birds;
  }
  if (t.contains('vegetação') ||
      t.contains('vegetacao') ||
      t.contains('planta')) {
    return CinematicRevealKey.plants;
  }
  if (t.contains('terra seca') || t.contains('terra')) {
    return CinematicRevealKey.land;
  }
  if (t.contains('espírito') || t.contains('espirito')) {
    return CinematicRevealKey.spirit;
  }
  if (t.contains('sol') || t.contains('lua') || t.contains('estrela')) {
    return CinematicRevealKey.stars;
  }
  if (t.contains('homem') || t.contains('humano') || t.contains('imagem')) {
    return CinematicRevealKey.humanity;
  }
  if (t.contains('deus') && t.length < 10) return CinematicRevealKey.cosmos;
  return null;
}

CreationWorldState stateForReveal(CinematicRevealKey key, {double amount = 1}) {
  return switch (key) {
    CinematicRevealKey.spirit => CreationWorldState(
        spirit: amount,
        voidDepth: 1 - amount * 0.1,
        waters: amount * 0.4,
      ),
    CinematicRevealKey.waters => CreationWorldState(
        waters: amount,
        voidDepth: 0.85 - amount * 0.2,
      ),
    CinematicRevealKey.light => CreationWorldState(
        light: amount,
        voidDepth: 1 - amount * 0.95,
        waters: amount * 0.25,
      ),
    CinematicRevealKey.land =>
      CreationWorldState(land: amount, waters: 0.5, light: 0.4),
    CinematicRevealKey.plants =>
      CreationWorldState(plants: amount, land: 0.7, light: 0.5),
    CinematicRevealKey.fish =>
      CreationWorldState(fish: amount, waters: 0.85, light: 0.45),
    CinematicRevealKey.birds =>
      CreationWorldState(birds: amount, light: 0.55, plants: 0.3),
    CinematicRevealKey.stars =>
      CreationWorldState(stars: amount, light: 0.35, voidDepth: 0.4),
    CinematicRevealKey.humanity => CreationWorldState(
        humanity: amount,
        land: 0.8,
        plants: 0.5,
        light: 0.6,
      ),
    CinematicRevealKey.cosmos => CreationWorldState(
        stars: amount * 0.6,
        light: amount * 0.3,
        voidDepth: 0.7 - amount * 0.2,
      ),
  };
}

class CinematicResolver {
  static bool isCinematicMission(String? trailSlug, String? moduleTitle) {
    return trailSlug == 'genesis-1-11';
  }

  /// Atmosfera do hero na home — deriva do título da missão / trilha.
  static CreationWorldState ambientForHome({
    required String trailSlug,
    required String missionTitle,
    String? missionSlug,
  }) {
    final fromTitle = revealKeyFromCorrectText(missionTitle);
    if (fromTitle != null) {
      return stateForReveal(fromTitle, amount: 0.88);
    }
    if (missionSlug != null) {
      final fromSlug =
          revealKeyFromCorrectText(missionSlug.replaceAll('-', ' '));
      if (fromSlug != null) {
        return stateForReveal(fromSlug, amount: 0.8);
      }
    }
    if (isCinematicMission(trailSlug, null)) {
      return const CreationWorldState(
        voidDepth: 0.55,
        light: 0.42,
        waters: 0.32,
        land: 0.38,
        plants: 0.2,
      );
    }
    return const CreationWorldState(
      voidDepth: 0.72,
      light: 0.32,
      waters: 0.22,
      stars: 0.12,
    );
  }
}
