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

  /// Blurb da categoria (idioma atual). Vazio onde ainda não há texto.
  String get description => switch (this) {
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
    discipulado ||
    oracao ||
    historiaIgreja ||
    hermeneutica ||
    linguas ||
    sistematica ||
    cristologia => '',
  };

  static TrailCategory fromId(String? id) {
    return TrailCategory.values.firstWhere(
      (c) => c.id == id,
      orElse: () => TrailCategory.pentateuco,
    );
  }

  static List<TrailCategory> forRealm(TrailRealm realm) =>
      TrailCategory.values.where((c) => c.realm == realm).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
}
