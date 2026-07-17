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
  pentateuco(
    'pentateuco',
    'Pentateuco',
    'Os cinco primeiros livros da Bíblia — a Torá, o Livro da Lei, em ordem cronológica.',
    TrailRealm.antigoTestamento,
    10,
  ),
  historicosAt(
    'historicos-at',
    'Livros Históricos',
    'A história de Israel da conquista da Terra Prometida até o exílio babilônico.',
    TrailRealm.antigoTestamento,
    20,
  ),
  poeticos(
    'poeticos',
    'Livros Poéticos',
    'Poesia, sabedoria, provérbios e cânticos — organizados por relevância.',
    TrailRealm.antigoTestamento,
    30,
  ),
  profetasMaiores(
    'profetas-maiores',
    'Profetas Maiores',
    'Isaías a Daniel — obras mais extensas entre os registros proféticos.',
    TrailRealm.antigoTestamento,
    40,
  ),
  profetasMenores(
    'profetas-menores',
    'Profetas Menores',
    'Oséias a Malaquias — doze livros; o nome refere-se à extensão, não à importância.',
    TrailRealm.antigoTestamento,
    45,
  ),
  intertestamentario(
    'intertestamentario',
    'Período Intertestamentário',
    'Os cerca de 400 anos de silêncio entre o Antigo e o Novo Testamento.',
    TrailRealm.antigoTestamento,
    48,
  ),

  // Novo Testamento
  evangelhos(
    'evangelhos',
    'Evangelhos',
    'Nascimento, ministério, morte, ressurreição e ascensão de Jesus — Mateus a João.',
    TrailRealm.novoTestamento,
    50,
  ),
  historicosNt(
    'historicos-nt',
    'História da Igreja Primitiva',
    'Atos dos Apóstolos — o derramar do Espírito e a expansão do Evangelho.',
    TrailRealm.novoTestamento,
    60,
  ),
  epistolas(
    'epistolas',
    'Epístolas ou Cartas Apostólicas',
    'Vinte e uma cartas às primeiras igrejas — treze de Paulo e oito de outros autores.',
    TrailRealm.novoTestamento,
    70,
  ),
  apocalipse(
    'apocalipse',
    'Apocalipse ou Revelação',
    'O livro de Apocalipse, escrito por João Evangelista.',
    TrailRealm.novoTestamento,
    80,
  ),

  // Vida Cristã
  discipulado('discipulado', 'Discipulado', '', TrailRealm.vidaCrista, 90),
  oracao('oracao', 'Oração', '', TrailRealm.vidaCrista, 100),
  historiaIgreja(
    'historia-igreja',
    'História da Igreja',
    '',
    TrailRealm.vidaCrista,
    110,
  ),

  // Teologia
  hermeneutica('hermeneutica', 'Hermenêutica', '', TrailRealm.teologia, 120),
  linguas('linguas', 'Línguas Originais', '', TrailRealm.teologia, 130),
  sistematica(
    'sistematica',
    'Sistemática e Dogmática',
    '',
    TrailRealm.teologia,
    140,
  ),
  cristologia('cristologia', 'Cristologia', '', TrailRealm.teologia, 150);

  const TrailCategory(
    this.id,
    this.label,
    this.description,
    this.realm,
    this.order,
  );
  final String id;
  final String label;
  final String description;
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
