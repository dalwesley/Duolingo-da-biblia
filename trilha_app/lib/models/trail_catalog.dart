import '../l10n/l10n_global.dart';

/// Hierarquia do catálogo de trilhas — como a Bíblia e a formação cristã.
enum TrailRealm {
  antigoTestamento('antigo-testamento'),
  novoTestamento('novo-testamento'),
  vidaCrista('vida-crista'),
  teologia('teologia');

  const TrailRealm(this.id);
  final String id;

  /// Nome da área na interface (idioma atual).
  String get label => switch (this) {
    antigoTestamento => L10n.current.realmAntigoTestamento,
    novoTestamento => L10n.current.realmNovoTestamento,
    vidaCrista => L10n.current.realmVidaCrista,
    teologia => L10n.current.realmTeologia,
  };

  static TrailRealm fromId(String? id) {
    return TrailRealm.values.firstWhere(
      (r) => r.id == id,
      orElse: () => TrailRealm.antigoTestamento,
    );
  }
}

enum TrailCategory {
  // Motivos do onboarding — cards em Temas (trilha própria cada um).
  // "Criar uma sequência" não tem card: abre Gênesis no AT.
  pazNoDia('paz-no-dia', TrailRealm.vidaCrista, 1),
  conhecerADeus('conhecer-a-deus', TrailRealm.vidaCrista, 2),
  entenderABiblia('entender-a-biblia', TrailRealm.vidaCrista, 3),

  // Bíblia toda — atravessam os dois Testamentos; guardadas no AT.
  panorama('panorama', TrailRealm.antigoTestamento, 4),
  personagens('personagens', TrailRealm.antigoTestamento, 5),
  promessaCumprimento('promessa-cumprimento', TrailRealm.antigoTestamento, 6),
  temasBiblicos('temas-biblicos', TrailRealm.antigoTestamento, 7),
  parabolasMilagres('parabolas-milagres', TrailRealm.antigoTestamento, 8),

  // Antigo Testamento
  pentateuco('pentateuco', TrailRealm.antigoTestamento, 10),
  historicosAt('historicos-at', TrailRealm.antigoTestamento, 20),
  poeticos('poeticos', TrailRealm.antigoTestamento, 30),
  profetasMaiores('profetas-maiores', TrailRealm.antigoTestamento, 40),
  profetasMenores('profetas-menores', TrailRealm.antigoTestamento, 45),
  intertestamentario('intertestamentario', TrailRealm.antigoTestamento, 48),

  // Novo Testamento
  evangelhos('evangelhos', TrailRealm.novoTestamento, 50),
  historicosNt('historicos-nt', TrailRealm.novoTestamento, 60),
  epistolas('epistolas', TrailRealm.novoTestamento, 70),
  apocalipse('apocalipse', TrailRealm.novoTestamento, 80),

  // Vida Cristã
  discipulado('discipulado', TrailRealm.vidaCrista, 90),
  oracao('oracao', TrailRealm.vidaCrista, 100),
  historiaIgreja('historia-igreja', TrailRealm.vidaCrista, 110),

  // Teologia
  hermeneutica('hermeneutica', TrailRealm.teologia, 120),
  linguas('linguas', TrailRealm.teologia, 130),
  sistematica('sistematica', TrailRealm.teologia, 140),
  cristologia('cristologia', TrailRealm.teologia, 150);

  const TrailCategory(this.id, this.realm, this.order);
  final String id;
  final TrailRealm realm;
  final int order;

  /// Título da categoria (idioma atual).
  String get label => switch (this) {
    pazNoDia => L10n.current.categoryPazNoDiaTitle,
    conhecerADeus => L10n.current.categoryConhecerADeusTitle,
    entenderABiblia => L10n.current.categoryEntenderABibliaTitle,
    panorama => L10n.current.categoryPanoramaTitle,
    personagens => L10n.current.categoryPersonagensTitle,
    promessaCumprimento => L10n.current.categoryPromessaCumprimentoTitle,
    temasBiblicos => L10n.current.categoryTemasBiblicosTitle,
    parabolasMilagres => L10n.current.categoryParabolasMilagresTitle,
    pentateuco => L10n.current.categoryPentateucoTitle,
    historicosAt => L10n.current.categoryHistoricosAtTitle,
    poeticos => L10n.current.categoryPoeticosTitle,
    profetasMaiores => L10n.current.categoryProfetasMaioresTitle,
    profetasMenores => L10n.current.categoryProfetasMenoresTitle,
    intertestamentario => L10n.current.categoryIntertestamentarioTitle,
    evangelhos => L10n.current.categoryEvangelhosTitle,
    historicosNt => L10n.current.categoryHistoricosNtTitle,
    epistolas => L10n.current.categoryEpistolasTitle,
    apocalipse => L10n.current.categoryApocalipseTitle,
    discipulado => L10n.current.categoryDiscipuladoTitle,
    oracao => L10n.current.categoryOracaoTitle,
    historiaIgreja => L10n.current.categoryHistoriaIgrejaTitle,
    hermeneutica => L10n.current.categoryHermeneuticaTitle,
    linguas => L10n.current.categoryLinguasTitle,
    sistematica => L10n.current.categorySistematicaTitle,
    cristologia => L10n.current.categoryCristologiaTitle,
  };

  /// Blurb da categoria (idioma atual).
  String get description => switch (this) {
    pazNoDia => L10n.current.categoryPazNoDiaBlurb,
    conhecerADeus => L10n.current.categoryConhecerADeusBlurb,
    entenderABiblia => L10n.current.categoryEntenderABibliaBlurb,
    pentateuco => L10n.current.categoryPentateucoBlurb,
    historicosAt => L10n.current.categoryHistoricosAtBlurb,
    poeticos => L10n.current.categoryPoeticosBlurb,
    profetasMaiores => L10n.current.categoryProfetasMaioresBlurb,
    profetasMenores => L10n.current.categoryProfetasMenoresBlurb,
    intertestamentario => L10n.current.categoryIntertestamentarioBlurb,
    evangelhos => L10n.current.categoryEvangelhosBlurb,
    historicosNt => L10n.current.categoryHistoricosNtBlurb,
    epistolas => L10n.current.categoryEpistolasBlurb,
    apocalipse => L10n.current.categoryApocalipseBlurb,
    panorama => L10n.current.categoryPanoramaBlurb,
    personagens => L10n.current.categoryPersonagensBlurb,
    promessaCumprimento => L10n.current.categoryPromessaCumprimentoBlurb,
    temasBiblicos => L10n.current.categoryTemasBiblicosBlurb,
    parabolasMilagres => L10n.current.categoryParabolasMilagresBlurb,
    hermeneutica => L10n.current.categoryHermeneuticaBlurb,
    linguas => L10n.current.categoryLinguasBlurb,
    sistematica => L10n.current.categorySistematicaBlurb,
    cristologia => L10n.current.categoryCristologiaBlurb,
    discipulado => L10n.current.categoryDiscipuladoBlurb,
    oracao => L10n.current.categoryOracaoBlurb,
    historiaIgreja => L10n.current.categoryHistoriaIgrejaBlurb,
  };

  static TrailCategory fromId(String? id) {
    return TrailCategory.values.firstWhere(
      (c) => c.id == id,
      orElse: () => TrailCategory.pentateuco,
    );
  }

  static TrailCategory? tryFromId(String? id) {
    for (final c in TrailCategory.values) {
      if (c.id == id) return c;
    }
    return null;
  }

  static List<TrailCategory> forRealm(TrailRealm realm) =>
      TrailCategory.values.where((c) => c.realm == realm).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
}

/// Linha da aba Trilhas.
///
/// [biblia] é grátis: Antigo e Novo Testamento, dois cards lado a lado.
/// [tematicos] e [vidaCrista] são carrosséis do Peregrino+.
/// [teologia] fica em cards; com as trilhas `comingSoon`, a tela diz "Em breve".
enum TrailShelf {
  biblia,
  tematicos,
  vidaCrista,
  teologia;

  String get label => switch (this) {
    biblia => L10n.current.trailsShelfBible,
    tematicos => L10n.current.trailsShelfThemes,
    vidaCrista => TrailRealm.vidaCrista.label,
    teologia => TrailRealm.teologia.label,
  };
}

/// Card da aba Trilhas: abre um caminho de trilhas. AT e NT juntam várias
/// categorias; nas outras linhas cada categoria é um card.
enum TrailJourney {
  antigoTestamento(TrailShelf.biblia, TrailRealm.antigoTestamento, [
    TrailCategory.pentateuco,
    TrailCategory.historicosAt,
    TrailCategory.poeticos,
    TrailCategory.profetasMaiores,
    TrailCategory.profetasMenores,
    TrailCategory.intertestamentario,
  ]),
  novoTestamento(TrailShelf.biblia, TrailRealm.novoTestamento, [
    TrailCategory.evangelhos,
    TrailCategory.historicosNt,
    TrailCategory.epistolas,
    TrailCategory.apocalipse,
  ]),
  // Motivos do onboarding — um card por trilha, grátis (ver [requiresPlus]).
  pazNoDia(TrailShelf.tematicos, TrailRealm.vidaCrista, [
    TrailCategory.pazNoDia,
  ]),
  conhecerADeus(TrailShelf.tematicos, TrailRealm.vidaCrista, [
    TrailCategory.conhecerADeus,
  ]),
  entenderABiblia(TrailShelf.tematicos, TrailRealm.vidaCrista, [
    TrailCategory.entenderABiblia,
  ]),
  panorama(TrailShelf.tematicos, TrailRealm.antigoTestamento, [
    TrailCategory.panorama,
  ]),
  personagens(TrailShelf.tematicos, TrailRealm.novoTestamento, [
    TrailCategory.personagens,
  ]),
  promessaCumprimento(TrailShelf.tematicos, TrailRealm.novoTestamento, [
    TrailCategory.promessaCumprimento,
  ]),
  temasBiblicos(TrailShelf.tematicos, TrailRealm.antigoTestamento, [
    TrailCategory.temasBiblicos,
  ]),
  parabolasMilagres(TrailShelf.tematicos, TrailRealm.novoTestamento, [
    TrailCategory.parabolasMilagres,
  ]),
  discipulado(TrailShelf.vidaCrista, TrailRealm.vidaCrista, [
    TrailCategory.discipulado,
  ]),
  oracao(TrailShelf.vidaCrista, TrailRealm.vidaCrista, [TrailCategory.oracao]),
  historiaIgreja(TrailShelf.vidaCrista, TrailRealm.vidaCrista, [
    TrailCategory.historiaIgreja,
  ]),
  hermeneutica(TrailShelf.teologia, TrailRealm.teologia, [
    TrailCategory.hermeneutica,
  ]),
  linguas(TrailShelf.teologia, TrailRealm.teologia, [TrailCategory.linguas]),
  sistematica(TrailShelf.teologia, TrailRealm.teologia, [
    TrailCategory.sistematica,
  ]),
  cristologia(TrailShelf.teologia, TrailRealm.teologia, [
    TrailCategory.cristologia,
  ]);

  const TrailJourney(this.shelf, this.realm, this.categories);
  final TrailShelf shelf;

  /// Área que dá a cor do card e do caminho.
  final TrailRealm realm;
  final List<TrailCategory> categories;

  String get label => switch (this) {
    _ => categories.length > 1 ? realm.label : categories.single.label,
  };

  /// O que há neste caminho — a frase do card e da folha "Em breve".
  String get description => switch (this) {
    antigoTestamento => L10n.current.journeyAntigoTestamentoBody,
    novoTestamento => L10n.current.journeyNovoTestamentoBody,
    _ => categories.single.description,
  };

  /// Bíblia (AT/NT) e os motivos do onboarding são grátis. Demais Temas,
  /// Vida Cristã e Teologia pedem Peregrino+.
  bool get requiresPlus {
    if (this == pazNoDia ||
        this == conhecerADeus ||
        this == entenderABiblia) {
      return false;
    }
    return shelf != TrailShelf.biblia;
  }

  /// Cards temáticos que atravessam os dois Testamentos: a trilha pode estar
  /// gravada no AT ou no NT.
  bool get spansCanon =>
      this == panorama ||
      this == personagens ||
      this == promessaCumprimento ||
      this == temasBiblicos ||
      this == parabolasMilagres;

  /// Card de uma trilha pelo `realm` + `category` gravados nela. Categoria
  /// que não bate com a área (dado antigo) cai no card principal da área.
  static TrailJourney forTrail({
    required String realmId,
    required String categoryId,
  }) {
    final realm = TrailRealm.fromId(realmId);
    final category = TrailCategory.tryFromId(categoryId);
    if (category != null) {
      final journey = values.firstWhere((j) => j.categories.contains(category));
      final fits =
          category.realm == realm ||
          (journey.spansCanon &&
              (realm == TrailRealm.antigoTestamento ||
                  realm == TrailRealm.novoTestamento));
      if (fits) return journey;
    }
    return switch (realm) {
      TrailRealm.antigoTestamento => antigoTestamento,
      TrailRealm.novoTestamento => novoTestamento,
      TrailRealm.vidaCrista => discipulado,
      TrailRealm.teologia => sistematica,
    };
  }

  static List<TrailJourney> forShelf(TrailShelf shelf) =>
      values.where((j) => j.shelf == shelf).toList();
}
