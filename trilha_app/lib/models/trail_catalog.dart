/// Hierarquia do catálogo de trilhas — como a Bíblia e a formação cristã.
enum TrailRealm {
  antigoTestamento('antigo-testamento', 'Antigo Testamento'),
  novoTestamento('novo-testamento', 'Novo Testamento'),
  vidaCrista('vida-crista', 'Vida Cristã'),
  teologia('teologia', 'Teologia');

  const TrailRealm(this.id, this.label);
  final String id;
  final String label;

  static TrailRealm fromId(String? id) {
    return TrailRealm.values.firstWhere(
      (r) => r.id == id,
      orElse: () => TrailRealm.antigoTestamento,
    );
  }
}

enum TrailCategory {
  // Antigo Testamento
  pentateuco('pentateuco', 'Pentateuco', TrailRealm.antigoTestamento, 10),
  historicosAt('historicos-at', 'Livros Históricos', TrailRealm.antigoTestamento, 20),
  poeticos('poeticos', 'Poéticos e Sapienciais', TrailRealm.antigoTestamento, 30),
  profeticos('profeticos', 'Livros Proféticos', TrailRealm.antigoTestamento, 40),

  // Novo Testamento
  evangelhos('evangelhos', 'Evangelhos', TrailRealm.novoTestamento, 50),
  historicosNt('historicos-nt', 'Livros Históricos', TrailRealm.novoTestamento, 60),
  epistolas('epistolas', 'Epístolas', TrailRealm.novoTestamento, 70),
  apocalipse('apocalipse', 'Apocalipse', TrailRealm.novoTestamento, 80),

  // Vida Cristã
  discipulado('discipulado', 'Discipulado', TrailRealm.vidaCrista, 90),
  oracao('oracao', 'Oração', TrailRealm.vidaCrista, 100),
  historiaIgreja('historia-igreja', 'História da Igreja', TrailRealm.vidaCrista, 110),

  // Teologia
  hermeneutica('hermeneutica', 'Hermenêutica', TrailRealm.teologia, 120),
  linguas('linguas', 'Línguas Originais', TrailRealm.teologia, 130),
  sistematica('sistematica', 'Sistemática e Dogmática', TrailRealm.teologia, 140),
  cristologia('cristologia', 'Cristologia', TrailRealm.teologia, 150);

  const TrailCategory(this.id, this.label, this.realm, this.order);
  final String id;
  final String label;
  final TrailRealm realm;
  final int order;

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
