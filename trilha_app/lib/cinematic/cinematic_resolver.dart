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

  CreationWorldState copyWith({
    double? voidDepth,
    double? spirit,
    double? waters,
    double? light,
    double? land,
    double? plants,
    double? fish,
    double? birds,
    double? stars,
    double? humanity,
  }) {
    return CreationWorldState(
      voidDepth: voidDepth ?? this.voidDepth,
      spirit: spirit ?? this.spirit,
      waters: waters ?? this.waters,
      light: light ?? this.light,
      land: land ?? this.land,
      plants: plants ?? this.plants,
      fish: fish ?? this.fish,
      birds: birds ?? this.birds,
      stars: stars ?? this.stars,
      humanity: humanity ?? this.humanity,
    );
  }
}

/// Uma batida cinematográfica por pergunta.
class CinematicBeat {
  final String narrative;
  final CreationWorldState ambient;
  final CreationWorldState? revealOnCorrect;

  const CinematicBeat({
    required this.narrative,
    required this.ambient,
    this.revealOnCorrect,
  });
}

enum CinematicRevealKey { spirit, waters, light, land, plants, fish, birds, stars, humanity, cosmos }

CinematicRevealKey? revealKeyFromCorrectText(String correctText) {
  final t = correctText.toLowerCase();
  if (t.contains('luz')) return CinematicRevealKey.light;
  if (t.contains('peixe')) return CinematicRevealKey.fish;
  if (t.contains('ave') || t.contains('pássaro') || t.contains('passaro')) return CinematicRevealKey.birds;
  if (t.contains('vegetação') || t.contains('vegetacao') || t.contains('planta')) return CinematicRevealKey.plants;
  if (t.contains('terra seca') || t.contains('terra')) return CinematicRevealKey.land;
  if (t.contains('espírito') || t.contains('espirito')) return CinematicRevealKey.spirit;
  if (t.contains('sol') || t.contains('lua') || t.contains('estrela')) return CinematicRevealKey.stars;
  if (t.contains('homem') || t.contains('humano') || t.contains('imagem')) return CinematicRevealKey.humanity;
  if (t.contains('deus') && t.length < 10) return CinematicRevealKey.cosmos;
  return null;
}

CinematicRevealKey? revealKeyFromTag(String? tag) {
  return switch (tag) {
    'light' => CinematicRevealKey.light,
    'spirit' => CinematicRevealKey.spirit,
    'waters' => CinematicRevealKey.waters,
    'land' => CinematicRevealKey.land,
    'plants' => CinematicRevealKey.plants,
    'fish' => CinematicRevealKey.fish,
    'birds' => CinematicRevealKey.birds,
    'stars' => CinematicRevealKey.stars,
    'humanity' => CinematicRevealKey.humanity,
    'cosmos' => CinematicRevealKey.cosmos,
    'eden' => CinematicRevealKey.plants,
    'fall' => CinematicRevealKey.spirit,
    'flood' => CinematicRevealKey.waters,
    'babel' => CinematicRevealKey.stars,
    _ => null,
  };
}

CreationWorldState stateForReveal(CinematicRevealKey key, {double amount = 1}) {
  return switch (key) {
    CinematicRevealKey.spirit => CreationWorldState(spirit: amount, voidDepth: 1 - amount * 0.1, waters: amount * 0.4),
    CinematicRevealKey.waters => CreationWorldState(waters: amount, voidDepth: 0.85 - amount * 0.2),
    CinematicRevealKey.light => CreationWorldState(light: amount, voidDepth: 1 - amount * 0.95, waters: amount * 0.25),
    CinematicRevealKey.land => CreationWorldState(land: amount, waters: 0.5, light: 0.4),
    CinematicRevealKey.plants => CreationWorldState(plants: amount, land: 0.7, light: 0.5),
    CinematicRevealKey.fish => CreationWorldState(fish: amount, waters: 0.85, light: 0.45),
    CinematicRevealKey.birds => CreationWorldState(birds: amount, light: 0.55, plants: 0.3),
    CinematicRevealKey.stars => CreationWorldState(stars: amount, light: 0.35, voidDepth: 0.4),
    CinematicRevealKey.humanity => CreationWorldState(humanity: amount, land: 0.8, plants: 0.5, light: 0.6),
    CinematicRevealKey.cosmos => CreationWorldState(stars: amount * 0.6, light: amount * 0.3, voidDepth: 0.7 - amount * 0.2),
  };
}

class CinematicResolver {
  static bool isCinematicMission(String? trailSlug, String? moduleTitle) {
    // Toda a trilha de Gênesis 1–11 é cinematográfica.
    return trailSlug == 'genesis-1-11';
  }

  static CinematicBeat forQuestion({
    required String missionSlug,
    required int questionIndex,
    required String correctOptionText,
    required String questionText,
    String? revealTag,
    String? moduleTitle,
  }) {
    final revealKey = revealKeyFromTag(revealTag) ?? revealKeyFromCorrectText(correctOptionText);
    final reveal = revealKey != null ? stateForReveal(revealKey) : null;

    final explicit = _explicitBeats[missionSlug]?[questionIndex];
    if (explicit != null) {
      return CinematicBeat(
        narrative: explicit.narrative,
        ambient: _ambientForModule(moduleTitle).mergeMax(explicit.ambient),
        revealOnCorrect: explicit.revealOnCorrect ?? reveal,
      );
    }

    return CinematicBeat(
      narrative: _defaultNarrative(questionText, correctOptionText, moduleTitle),
      ambient: _ambientForModule(moduleTitle).mergeMax(_ambientForIndex(questionIndex, missionSlug)),
      revealOnCorrect: reveal,
    );
  }

  static CreationWorldState _ambientForModule(String? moduleTitle) {
    return switch (moduleTitle) {
      'A Criação' => const CreationWorldState(voidDepth: 0.95, waters: 0.15),
      'O Jardim' => const CreationWorldState(voidDepth: 0.15, light: 0.55, land: 0.7, plants: 0.65),
      'Depois do Éden' => const CreationWorldState(voidDepth: 0.35, light: 0.35, land: 0.5, waters: 0.3),
      _ => const CreationWorldState(voidDepth: 0.9, waters: 0.2),
    };
  }

  static String _defaultNarrative(String question, String correct, String? moduleTitle) {
    final key = revealKeyFromCorrectText(correct);
    final keyed = switch (key) {
      CinematicRevealKey.light => 'No princípio, tudo era trevas...\nE Deus disse: "Haja luz."',
      CinematicRevealKey.fish => 'Das águas, Deus fez surgir a vida...\nEncha os mares.',
      CinematicRevealKey.waters => 'O Espírito pairava sobre as águas...',
      CinematicRevealKey.spirit => 'A terra era sem forma e vazia...\nMas Deus estava ali.',
      CinematicRevealKey.land => 'As águas se ajuntaram...\ne apareceu a terra seca.',
      CinematicRevealKey.plants => 'A terra fez brotar vegetação...',
      CinematicRevealKey.humanity => 'E Deus criou o homem à Sua imagem...',
      CinematicRevealKey.stars => 'Deus fez os luminares...\no sol, a lua e as estrelas.',
      CinematicRevealKey.birds => 'As aves voaram sobre a terra...',
      CinematicRevealKey.cosmos => 'No princípio, Deus criou os céus e a terra.',
      _ => null,
    };
    if (keyed != null) return keyed;
    return switch (moduleTitle) {
      'O Jardim' => 'No jardim, a comunhão ainda é íntima...',
      'Depois do Éden' => 'A humanidade caminha — e Deus ainda fala.',
      'A Criação' => 'A Palavra molda o mundo...',
      _ => 'Leia com atenção — a resposta está no texto.',
    };
  }

  static CreationWorldState _ambientForIndex(int index, String slug) {
    if (slug == 'gen-02-dias' && index == 0) {
      return const CreationWorldState(voidDepth: 1);
    }
    if (slug == 'gen-01-criador' && index == 0) {
      return const CreationWorldState(voidDepth: 1, stars: 0.15);
    }
    return const CreationWorldState(voidDepth: 0.9, waters: 0.2);
  }

  static final Map<String, Map<int, CinematicBeat>> _explicitBeats = {
    'gen-01-criador': {
      0: CinematicBeat(
        narrative: 'Antes de tudo existir...\n só Deus.',
        ambient: const CreationWorldState(voidDepth: 1, stars: 0.1),
        revealOnCorrect: stateForReveal(CinematicRevealKey.cosmos),
      ),
      1: CinematicBeat(
        narrative: 'A terra era sem forma e vazia...\ntrevas sobre o abismo.',
        ambient: const CreationWorldState(voidDepth: 1, waters: 0.15),
        revealOnCorrect: const CreationWorldState(waters: 0.5, voidDepth: 0.85),
      ),
      2: CinematicBeat(
        narrative: 'Sobre as águas...\no Espírito de Deus pairava.',
        ambient: const CreationWorldState(voidDepth: 0.85, waters: 0.5),
        revealOnCorrect: stateForReveal(CinematicRevealKey.spirit),
      ),
    },
    'gen-02-dias': {
      0: CinematicBeat(
        narrative: 'No princípio, tudo era trevas...\nsobre a face do abismo.',
        ambient: const CreationWorldState(voidDepth: 1),
        revealOnCorrect: stateForReveal(CinematicRevealKey.light),
      ),
      1: CinematicBeat(
        narrative: 'Então Deus disse: Encham-se as águas\nde seres vivos...',
        ambient: const CreationWorldState(light: 0.65, waters: 0.5, voidDepth: 0.2),
        revealOnCorrect: stateForReveal(CinematicRevealKey.fish),
      ),
      2: CinematicBeat(
        narrative: 'No sexto dia, a criação se prepara\npara sua coroa...',
        ambient: const CreationWorldState(light: 0.7, land: 0.5, plants: 0.4, fish: 0.6, waters: 0.75, voidDepth: 0.1),
        revealOnCorrect: stateForReveal(CinematicRevealKey.humanity),
      ),
      3: CinematicBeat(
        narrative: 'Deus olhou para tudo que fizera...',
        ambient: const CreationWorldState(light: 0.75, land: 0.55, plants: 0.45, fish: 0.6, voidDepth: 0.08),
        revealOnCorrect: const CreationWorldState(light: 0.9, plants: 0.7),
      ),
      4: CinematicBeat(
        narrative: 'No terceiro dia, a terra surgiu\ndas águas...',
        ambient: const CreationWorldState(light: 0.55, waters: 0.7, voidDepth: 0.15),
        revealOnCorrect: stateForReveal(CinematicRevealKey.plants),
      ),
    },
    'gen-03-imagem': {
      0: CinematicBeat(
        narrative: 'Do pó da terra...\nDeus formou o homem.',
        ambient: const CreationWorldState(light: 0.6, land: 0.7, plants: 0.4),
        revealOnCorrect: stateForReveal(CinematicRevealKey.humanity),
      ),
    },
    'gen-05-eden': {
      0: CinematicBeat(
        narrative: 'Deus plantou um jardim...\ne ali pôs o homem.',
        ambient: const CreationWorldState(light: 0.6, land: 0.75, plants: 0.7, voidDepth: 0.1),
        revealOnCorrect: stateForReveal(CinematicRevealKey.plants),
      ),
      1: CinematicBeat(
        narrative: 'Cultivar e guardar...\nvocação desde o princípio.',
        ambient: const CreationWorldState(light: 0.55, land: 0.8, plants: 0.8),
        revealOnCorrect: const CreationWorldState(plants: 1, land: 0.9),
      ),
    },
    'gen-06-queda': {
      0: CinematicBeat(
        narrative: 'A serpente sussurrou...\n"Certamente não morrereis."',
        ambient: const CreationWorldState(light: 0.35, plants: 0.5, land: 0.6, voidDepth: 0.4),
        revealOnCorrect: const CreationWorldState(voidDepth: 0.55, spirit: 0.3),
      ),
      1: CinematicBeat(
        narrative: 'O fruto parecia bom...\ne o coração hesitou.',
        ambient: const CreationWorldState(light: 0.3, plants: 0.45, voidDepth: 0.5),
        revealOnCorrect: const CreationWorldState(voidDepth: 0.65),
      ),
    },
    'gen-07-consequencias': {
      0: CinematicBeat(
        narrative: 'Ainda no juízo...\nhá uma promessa.',
        ambient: const CreationWorldState(light: 0.25, voidDepth: 0.55, land: 0.4),
        revealOnCorrect: stateForReveal(CinematicRevealKey.spirit, amount: 0.6),
      ),
    },
    'gen-09-diluvio': {
      0: CinematicBeat(
        narrative: 'As águas subiram...\nmas Noé achou graça.',
        ambient: const CreationWorldState(waters: 0.9, voidDepth: 0.3, light: 0.25),
        revealOnCorrect: stateForReveal(CinematicRevealKey.waters),
      ),
      1: CinematicBeat(
        narrative: 'O arco nas nuvens...\nsinal da aliança.',
        ambient: const CreationWorldState(waters: 0.55, light: 0.5, stars: 0.2),
        revealOnCorrect: stateForReveal(CinematicRevealKey.light),
      ),
    },
    'gen-10-babel': {
      0: CinematicBeat(
        narrative: 'Façamos um nome...\nsem o Nome.',
        ambient: const CreationWorldState(land: 0.6, light: 0.3, voidDepth: 0.4, stars: 0.15),
        revealOnCorrect: stateForReveal(CinematicRevealKey.stars, amount: 0.5),
      ),
    },
    'gen-11-abraao': {
      0: CinematicBeat(
        narrative: 'Sai da tua terra...\neu te abençoarei.',
        ambient: const CreationWorldState(light: 0.55, land: 0.55, stars: 0.4, voidDepth: 0.25),
        revealOnCorrect: stateForReveal(CinematicRevealKey.stars),
      ),
    },
  };
}
