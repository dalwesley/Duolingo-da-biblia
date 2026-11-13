import 'package:flutter/foundation.dart';

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

  static TrailRealm? tryFromId(String? id) {
    for (final r in TrailRealm.values) {
      if (r.id == id) return r;
    }
    return null;
  }
}

/// Linha da aba Explorar (uma "porta" com cards dentro).
///
/// [biblia] é grátis: Antigo e Novo Testamento, dois cards lado a lado.
/// [tematicos] e [vidaCrista] são carrosséis do Peregrino+.
/// [teologia] fica em cards; com as trilhas `comingSoon`, a tela diz "Em breve".
/// As linhas criadas no painel ([ExploreShelves]) vêm depois destas.
/// Igualdade por [name].
@immutable
class TrailShelf {
  const TrailShelf._(this.name) : extra = null;

  TrailShelf._extra(ExploreShelf this.extra) : name = extra.id;

  /// Id estável (`biblia`, `tematicos`… ou o id da linha do painel).
  final String name;

  /// Linha do painel; `null` nas fixas.
  final ExploreShelf? extra;

  bool get isExtra => extra != null;

  static const biblia = TrailShelf._('biblia');
  static const tematicos = TrailShelf._('tematicos');
  static const vidaCrista = TrailShelf._('vidaCrista');
  static const teologia = TrailShelf._('teologia');

  static const List<TrailShelf> builtIns = [
    biblia,
    tematicos,
    vidaCrista,
    teologia,
  ];

  /// Fixas + as do painel.
  static List<TrailShelf> get values => [
    ...builtIns,
    ...ExploreShelves.shelves,
  ];

  String get label {
    final e = extra;
    if (e != null) return e.localizedTitle;
    return switch (name) {
      'biblia' => L10n.current.trailsShelfBible,
      'tematicos' => L10n.current.trailsShelfThemes,
      'vidaCrista' => TrailRealm.vidaCrista.label,
      _ => TrailRealm.teologia.label,
    };
  }

  static TrailShelf? tryFromName(String? name) {
    if (name == null) return null;
    for (final s in values) {
      if (s.name == name) return s;
    }
    return null;
  }

  @override
  bool operator ==(Object other) => other is TrailShelf && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'TrailShelf($name)';
}

/// Textos por idioma (`pt`, `en`, `es`); falta de tradução cai no `pt`.
String _pickText(Map<String, String> texts) {
  final lang = L10n.current.localeName;
  final own = texts[lang]?.trim() ?? '';
  if (own.isNotEmpty) return own;
  return texts['pt']?.trim() ?? '';
}

Map<String, String> _readTexts(Object? raw) {
  if (raw is String) return {'pt': raw};
  if (raw is! Map) return const {};
  return {
    for (final e in raw.entries)
      if (e.value is String) '${e.key}': e.value as String,
  };
}

/// Linha criada no painel (`content_shelves/{id}`): uma porta nova na aba
/// Explorar, com os cards do painel que apontam para ela.
@immutable
class ExploreShelf {
  const ExploreShelf({
    required this.id,
    required this.title,
    this.subtitle = const {},
    this.intro = const {},
    this.sky = TrailRealm.vidaCrista,
    this.glyph = '',
    this.plus = true,
    this.order = 0,
  });

  final String id;
  final Map<String, String> title;

  /// Frase da porta na aba.
  final Map<String, String> subtitle;

  /// Apresentação no topo da porta, acima dos cards.
  final Map<String, String> intro;

  /// Área que dá o céu da porta.
  final TrailRealm sky;

  /// Nome de um [CinematicGlyph]; vazio usa o da área.
  final String glyph;
  final bool plus;
  final int order;

  String get localizedTitle => _pickText(title);
  String get localizedSubtitle => _pickText(subtitle);
  String get localizedIntro => _pickText(intro);

  /// `null` quando o doc não vale (sem id/título, inativo ou id de linha fixa).
  static ExploreShelf? fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim() ?? '';
    final title = _readTexts(json['title']);
    if (id.isEmpty || (title['pt'] ?? '').trim().isEmpty) return null;
    if (json['active'] == false) return null;
    if (TrailShelf.builtIns.any((s) => s.name == id)) return null;
    return ExploreShelf(
      id: id,
      title: title,
      subtitle: _readTexts(json['subtitle']),
      intro: _readTexts(json['intro']),
      sky:
          TrailRealm.tryFromId(json['sky'] as String?) ?? TrailRealm.vidaCrista,
      glyph: (json['glyph'] as String?)?.trim() ?? '',
      plus: json['plus'] != false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'intro': intro,
    'sky': sky.id,
    'glyph': glyph,
    'plus': plus,
    'order': order,
  };
}

/// Linhas do painel em vigor. Carregar **antes** dos cards: o card aponta
/// para a linha pelo id.
class ExploreShelves {
  ExploreShelves._();

  static List<TrailShelf> _shelves = const [];

  static List<TrailShelf> get shelves => _shelves;

  static void set(Iterable<ExploreShelf> shelves) {
    final seen = <String>{};
    final list = [
      for (final s in shelves)
        if (seen.add(s.id)) s,
    ]..sort((a, b) => a.order.compareTo(b.order));
    _shelves = List.unmodifiable([for (final s in list) TrailShelf._extra(s)]);
  }
}

/// Card criado no painel (`content_cards/{id}`): uma categoria própria, com
/// um card só dela numa linha da aba Explorar. Os cards fixos moram no código;
/// estes chegam com o catálogo e não pedem versão nova do app.
@immutable
class ExploreCard {
  const ExploreCard({
    required this.id,
    required this.shelf,
    required this.realm,
    required this.title,
    this.blurb = const {},
    this.glyph = '',
    this.plus = true,
    this.order = 0,
  });

  /// Também é o `category` gravado nas trilhas do card.
  final String id;
  final TrailShelf shelf;

  /// Área que dá a cor do card e do caminho.
  final TrailRealm realm;

  /// Textos por idioma (`pt`, `en`, `es`); falta de tradução cai no `pt`.
  final Map<String, String> title;
  final Map<String, String> blurb;

  /// Nome de um [CinematicGlyph]; vazio usa o da área.
  final String glyph;
  final bool plus;
  final int order;

  String get localizedTitle => _pickText(title);
  String get localizedBlurb => _pickText(blurb);

  /// `null` quando o doc não vale (sem id/título, linha da Bíblia, inativo,
  /// ou id de um card fixo).
  static ExploreCard? fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim() ?? '';
    final shelf = TrailShelf.tryFromName(json['shelf'] as String?);
    final title = _readTexts(json['title']);
    if (id.isEmpty || shelf == null || shelf == TrailShelf.biblia) return null;
    if ((title['pt'] ?? '').trim().isEmpty) return null;
    if (json['active'] == false) return null;
    if (TrailCategory.builtIns.any((c) => c.id == id)) return null;
    return ExploreCard(
      id: id,
      shelf: shelf,
      realm:
          TrailRealm.tryFromId(json['realm'] as String?) ??
          shelf.extra?.sky ??
          (shelf == TrailShelf.teologia
              ? TrailRealm.teologia
              : shelf == TrailShelf.vidaCrista
              ? TrailRealm.vidaCrista
              : TrailRealm.antigoTestamento),
      title: title,
      blurb: _readTexts(json['blurb']),
      glyph: (json['glyph'] as String?)?.trim() ?? '',
      plus: json['plus'] != false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'shelf': shelf.name,
    'realm': realm.id,
    'title': title,
    'blurb': blurb,
    'glyph': glyph,
    'plus': plus,
    'order': order,
  };
}

/// Cards do painel em vigor. O [ContentCatalogService] troca a lista quando o
/// catálogo chega (cache ou Firestore).
class ExploreCards {
  ExploreCards._();

  static List<ExploreCard> _cards = const [];
  static List<TrailCategory> _categories = const [];
  static List<TrailJourney> _journeys = const [];

  static List<ExploreCard> get cards => _cards;
  static List<TrailCategory> get categories => _categories;
  static List<TrailJourney> get journeys => _journeys;

  static void set(Iterable<ExploreCard> cards) {
    final seen = <String>{};
    final list = [
      for (final c in cards)
        if (seen.add(c.id)) c,
    ]..sort((a, b) => a.order.compareTo(b.order));
    _cards = List.unmodifiable(list);
    _categories = List.unmodifiable([
      for (final c in list) TrailCategory._extra(c),
    ]);
    _journeys = List.unmodifiable([
      for (final cat in _categories) TrailJourney._extra(cat),
    ]);
  }

  /// Glyph escolhido no painel para a categoria, se houver.
  static String? glyphFor(String categoryId) {
    for (final c in _cards) {
      if (c.id == categoryId && c.glyph.isNotEmpty) return c.glyph;
    }
    return null;
  }
}

/// Categoria de trilha. As fixas são constantes; as do painel vêm de
/// [ExploreCards]. Igualdade por [id].
@immutable
class TrailCategory {
  const TrailCategory._(this.id, this.realm, this.order) : card = null;

  TrailCategory._extra(ExploreCard this.card)
    : id = card.id,
      realm = card.realm,
      // Depois de todas as fixas, na ordem do painel.
      order = 1000 + card.order;

  final String id;
  final TrailRealm realm;
  final int order;

  /// Card do painel; `null` nas categorias fixas.
  final ExploreCard? card;

  bool get isExtra => card != null;

  // Motivos do onboarding — cards em Temas (trilha própria cada um).
  // "Criar uma sequência" não tem card: abre Gênesis no AT.
  static const pazNoDia = TrailCategory._(
    'paz-no-dia',
    TrailRealm.vidaCrista,
    1,
  );
  static const conhecerADeus = TrailCategory._(
    'conhecer-a-deus',
    TrailRealm.vidaCrista,
    2,
  );
  static const entenderABiblia = TrailCategory._(
    'entender-a-biblia',
    TrailRealm.vidaCrista,
    3,
  );

  // Bíblia toda — atravessam os dois Testamentos; guardadas no AT.
  static const panorama = TrailCategory._(
    'panorama',
    TrailRealm.antigoTestamento,
    4,
  );
  static const personagens = TrailCategory._(
    'personagens',
    TrailRealm.antigoTestamento,
    5,
  );
  static const promessaCumprimento = TrailCategory._(
    'promessa-cumprimento',
    TrailRealm.antigoTestamento,
    6,
  );
  static const temasBiblicos = TrailCategory._(
    'temas-biblicos',
    TrailRealm.antigoTestamento,
    7,
  );
  static const parabolasMilagres = TrailCategory._(
    'parabolas-milagres',
    TrailRealm.antigoTestamento,
    8,
  );

  // Antigo Testamento
  static const pentateuco = TrailCategory._(
    'pentateuco',
    TrailRealm.antigoTestamento,
    10,
  );
  static const historicosAt = TrailCategory._(
    'historicos-at',
    TrailRealm.antigoTestamento,
    20,
  );
  static const poeticos = TrailCategory._(
    'poeticos',
    TrailRealm.antigoTestamento,
    30,
  );
  static const profetasMaiores = TrailCategory._(
    'profetas-maiores',
    TrailRealm.antigoTestamento,
    40,
  );
  static const profetasMenores = TrailCategory._(
    'profetas-menores',
    TrailRealm.antigoTestamento,
    45,
  );
  static const intertestamentario = TrailCategory._(
    'intertestamentario',
    TrailRealm.antigoTestamento,
    48,
  );

  // Novo Testamento
  static const evangelhos = TrailCategory._(
    'evangelhos',
    TrailRealm.novoTestamento,
    50,
  );
  static const historicosNt = TrailCategory._(
    'historicos-nt',
    TrailRealm.novoTestamento,
    60,
  );
  static const epistolas = TrailCategory._(
    'epistolas',
    TrailRealm.novoTestamento,
    70,
  );
  static const apocalipse = TrailCategory._(
    'apocalipse',
    TrailRealm.novoTestamento,
    80,
  );

  // Vida Cristã
  static const discipulado = TrailCategory._(
    'discipulado',
    TrailRealm.vidaCrista,
    90,
  );
  static const oracao = TrailCategory._('oracao', TrailRealm.vidaCrista, 100);
  static const historiaIgreja = TrailCategory._(
    'historia-igreja',
    TrailRealm.vidaCrista,
    110,
  );

  // Teologia
  static const hermeneutica = TrailCategory._(
    'hermeneutica',
    TrailRealm.teologia,
    120,
  );
  static const linguas = TrailCategory._('linguas', TrailRealm.teologia, 130);
  static const sistematica = TrailCategory._(
    'sistematica',
    TrailRealm.teologia,
    140,
  );
  static const cristologia = TrailCategory._(
    'cristologia',
    TrailRealm.teologia,
    150,
  );

  static const List<TrailCategory> builtIns = [
    pazNoDia,
    conhecerADeus,
    entenderABiblia,
    panorama,
    personagens,
    promessaCumprimento,
    temasBiblicos,
    parabolasMilagres,
    pentateuco,
    historicosAt,
    poeticos,
    profetasMaiores,
    profetasMenores,
    intertestamentario,
    evangelhos,
    historicosNt,
    epistolas,
    apocalipse,
    discipulado,
    oracao,
    historiaIgreja,
    hermeneutica,
    linguas,
    sistematica,
    cristologia,
  ];

  /// Fixas + as do painel.
  static List<TrailCategory> get values => [
    ...builtIns,
    ...ExploreCards.categories,
  ];

  /// Título da categoria (idioma atual).
  String get label {
    final c = card;
    if (c != null) return c.localizedTitle;
    final l = L10n.current;
    return switch (id) {
      'paz-no-dia' => l.categoryPazNoDiaTitle,
      'conhecer-a-deus' => l.categoryConhecerADeusTitle,
      'entender-a-biblia' => l.categoryEntenderABibliaTitle,
      'panorama' => l.categoryPanoramaTitle,
      'personagens' => l.categoryPersonagensTitle,
      'promessa-cumprimento' => l.categoryPromessaCumprimentoTitle,
      'temas-biblicos' => l.categoryTemasBiblicosTitle,
      'parabolas-milagres' => l.categoryParabolasMilagresTitle,
      'pentateuco' => l.categoryPentateucoTitle,
      'historicos-at' => l.categoryHistoricosAtTitle,
      'poeticos' => l.categoryPoeticosTitle,
      'profetas-maiores' => l.categoryProfetasMaioresTitle,
      'profetas-menores' => l.categoryProfetasMenoresTitle,
      'intertestamentario' => l.categoryIntertestamentarioTitle,
      'evangelhos' => l.categoryEvangelhosTitle,
      'historicos-nt' => l.categoryHistoricosNtTitle,
      'epistolas' => l.categoryEpistolasTitle,
      'apocalipse' => l.categoryApocalipseTitle,
      'discipulado' => l.categoryDiscipuladoTitle,
      'oracao' => l.categoryOracaoTitle,
      'historia-igreja' => l.categoryHistoriaIgrejaTitle,
      'hermeneutica' => l.categoryHermeneuticaTitle,
      'linguas' => l.categoryLinguasTitle,
      'sistematica' => l.categorySistematicaTitle,
      'cristologia' => l.categoryCristologiaTitle,
      _ => id,
    };
  }

  /// Blurb da categoria (idioma atual).
  String get description {
    final c = card;
    if (c != null) return c.localizedBlurb;
    final l = L10n.current;
    return switch (id) {
      'paz-no-dia' => l.categoryPazNoDiaBlurb,
      'conhecer-a-deus' => l.categoryConhecerADeusBlurb,
      'entender-a-biblia' => l.categoryEntenderABibliaBlurb,
      'pentateuco' => l.categoryPentateucoBlurb,
      'historicos-at' => l.categoryHistoricosAtBlurb,
      'poeticos' => l.categoryPoeticosBlurb,
      'profetas-maiores' => l.categoryProfetasMaioresBlurb,
      'profetas-menores' => l.categoryProfetasMenoresBlurb,
      'intertestamentario' => l.categoryIntertestamentarioBlurb,
      'evangelhos' => l.categoryEvangelhosBlurb,
      'historicos-nt' => l.categoryHistoricosNtBlurb,
      'epistolas' => l.categoryEpistolasBlurb,
      'apocalipse' => l.categoryApocalipseBlurb,
      'panorama' => l.categoryPanoramaBlurb,
      'personagens' => l.categoryPersonagensBlurb,
      'promessa-cumprimento' => l.categoryPromessaCumprimentoBlurb,
      'temas-biblicos' => l.categoryTemasBiblicosBlurb,
      'parabolas-milagres' => l.categoryParabolasMilagresBlurb,
      'hermeneutica' => l.categoryHermeneuticaBlurb,
      'linguas' => l.categoryLinguasBlurb,
      'sistematica' => l.categorySistematicaBlurb,
      'cristologia' => l.categoryCristologiaBlurb,
      'discipulado' => l.categoryDiscipuladoBlurb,
      'oracao' => l.categoryOracaoBlurb,
      'historia-igreja' => l.categoryHistoriaIgrejaBlurb,
      _ => '',
    };
  }

  static TrailCategory fromId(String? id) => tryFromId(id) ?? pentateuco;

  static TrailCategory? tryFromId(String? id) {
    if (id == null) return null;
    for (final c in values) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  bool operator ==(Object other) => other is TrailCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TrailCategory($id)';
}

/// Card da aba Trilhas: abre um caminho de trilhas. AT e NT juntam várias
/// categorias; nas outras linhas cada categoria é um card. Os cards do painel
/// ([ExploreCards]) entram no fim da linha deles. Igualdade por [name].
@immutable
class TrailJourney {
  const TrailJourney._(this.name, this.shelf, this.realm, this.categories)
    : card = null;

  TrailJourney._extra(TrailCategory category)
    : name = category.id,
      shelf = category.card!.shelf,
      realm = category.realm,
      categories = [category],
      card = category.card;

  /// Id estável: nome da arte (`assets/art/journey_<name>.jpg`) nos fixos,
  /// id do card nos do painel.
  final String name;
  final TrailShelf shelf;

  /// Área que dá a cor do card e do caminho.
  final TrailRealm realm;
  final List<TrailCategory> categories;

  /// Card do painel; `null` nos fixos.
  final ExploreCard? card;

  bool get isExtra => card != null;

  static const antigoTestamento = TrailJourney._(
    'antigoTestamento',
    TrailShelf.biblia,
    TrailRealm.antigoTestamento,
    [
      TrailCategory.pentateuco,
      TrailCategory.historicosAt,
      TrailCategory.poeticos,
      TrailCategory.profetasMaiores,
      TrailCategory.profetasMenores,
      TrailCategory.intertestamentario,
    ],
  );
  static const novoTestamento = TrailJourney._(
    'novoTestamento',
    TrailShelf.biblia,
    TrailRealm.novoTestamento,
    [
      TrailCategory.evangelhos,
      TrailCategory.historicosNt,
      TrailCategory.epistolas,
      TrailCategory.apocalipse,
    ],
  );
  // Motivos do onboarding — um card por trilha, grátis (ver [requiresPlus]).
  static const pazNoDia = TrailJourney._(
    'pazNoDia',
    TrailShelf.tematicos,
    TrailRealm.vidaCrista,
    [TrailCategory.pazNoDia],
  );
  static const conhecerADeus = TrailJourney._(
    'conhecerADeus',
    TrailShelf.tematicos,
    TrailRealm.vidaCrista,
    [TrailCategory.conhecerADeus],
  );
  static const entenderABiblia = TrailJourney._(
    'entenderABiblia',
    TrailShelf.tematicos,
    TrailRealm.vidaCrista,
    [TrailCategory.entenderABiblia],
  );
  /// Pontos altos de cada livro (e as trilhas que passam por vários livros):
  /// coleção da Bíblia, ao lado de AT e NT. A trilha entra aqui pelo campo
  /// `collection: panorama`; o livro capítulo a capítulo fica em AT/NT.
  static const panorama = TrailJourney._(
    'panorama',
    TrailShelf.biblia,
    TrailRealm.antigoTestamento,
    [TrailCategory.panorama],
  );
  static const personagens = TrailJourney._(
    'personagens',
    TrailShelf.tematicos,
    TrailRealm.novoTestamento,
    [TrailCategory.personagens],
  );
  static const promessaCumprimento = TrailJourney._(
    'promessaCumprimento',
    TrailShelf.tematicos,
    TrailRealm.novoTestamento,
    [TrailCategory.promessaCumprimento],
  );
  static const temasBiblicos = TrailJourney._(
    'temasBiblicos',
    TrailShelf.tematicos,
    TrailRealm.antigoTestamento,
    [TrailCategory.temasBiblicos],
  );
  static const parabolasMilagres = TrailJourney._(
    'parabolasMilagres',
    TrailShelf.tematicos,
    TrailRealm.novoTestamento,
    [TrailCategory.parabolasMilagres],
  );
  static const discipulado = TrailJourney._(
    'discipulado',
    TrailShelf.vidaCrista,
    TrailRealm.vidaCrista,
    [TrailCategory.discipulado],
  );
  static const oracao = TrailJourney._(
    'oracao',
    TrailShelf.vidaCrista,
    TrailRealm.vidaCrista,
    [TrailCategory.oracao],
  );
  static const historiaIgreja = TrailJourney._(
    'historiaIgreja',
    TrailShelf.vidaCrista,
    TrailRealm.vidaCrista,
    [TrailCategory.historiaIgreja],
  );
  static const hermeneutica = TrailJourney._(
    'hermeneutica',
    TrailShelf.teologia,
    TrailRealm.teologia,
    [TrailCategory.hermeneutica],
  );
  static const linguas = TrailJourney._(
    'linguas',
    TrailShelf.teologia,
    TrailRealm.teologia,
    [TrailCategory.linguas],
  );
  static const sistematica = TrailJourney._(
    'sistematica',
    TrailShelf.teologia,
    TrailRealm.teologia,
    [TrailCategory.sistematica],
  );
  static const cristologia = TrailJourney._(
    'cristologia',
    TrailShelf.teologia,
    TrailRealm.teologia,
    [TrailCategory.cristologia],
  );

  static const List<TrailJourney> builtIns = [
    antigoTestamento,
    novoTestamento,
    pazNoDia,
    conhecerADeus,
    entenderABiblia,
    panorama,
    personagens,
    promessaCumprimento,
    temasBiblicos,
    parabolasMilagres,
    discipulado,
    oracao,
    historiaIgreja,
    hermeneutica,
    linguas,
    sistematica,
    cristologia,
  ];

  /// Fixos + os do painel.
  static List<TrailJourney> get values => [
    ...builtIns,
    ...ExploreCards.journeys,
  ];

  String get label =>
      categories.length > 1 ? realm.label : categories.single.label;

  /// O que há neste caminho — a frase do card e da folha "Em breve".
  String get description => switch (name) {
    'antigoTestamento' => L10n.current.journeyAntigoTestamentoBody,
    'novoTestamento' => L10n.current.journeyNovoTestamentoBody,
    _ => categories.single.description,
  };

  /// Arte do card; os do painel ainda não têm (o card usa céu + ícone).
  String? get art => isExtra ? null : 'assets/art/journey_$name.jpg';

  static const _freeThemes = {'pazNoDia', 'conhecerADeus', 'entenderABiblia'};

  /// Bíblia (AT/NT) e os motivos do onboarding são grátis. Demais Temas,
  /// Vida Cristã e Teologia pedem Peregrino+. Card do painel: o que ele disser.
  bool get requiresPlus {
    final c = card;
    if (c != null) return c.plus;
    if (_freeThemes.contains(name)) return false;
    return shelf != TrailShelf.biblia;
  }

  static const _spansCanon = {
    'panorama',
    'personagens',
    'promessaCumprimento',
    'temasBiblicos',
    'parabolasMilagres',
  };

  /// Cards temáticos que atravessam os dois Testamentos: a trilha pode estar
  /// gravada no AT ou no NT.
  bool get spansCanon => _spansCanon.contains(name);

  /// Card de uma trilha pelo `realm` + `category` gravados nela. Categoria
  /// que não bate com a área (dado antigo) cai no card principal da área.
  /// Categoria de card do painel vale qualquer que seja a área.
  static TrailJourney forTrail({
    required String realmId,
    required String categoryId,
    String? collectionId,
  }) {
    if (collectionId == panorama.name) return panorama;
    final realm = TrailRealm.fromId(realmId);
    final category = TrailCategory.tryFromId(categoryId);
    if (category != null) {
      final journey = values.firstWhere((j) => j.categories.contains(category));
      final fits =
          journey.isExtra ||
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

  /// Cards da linha: os fixos e, no fim, os do painel.
  static List<TrailJourney> forShelf(TrailShelf shelf) =>
      values.where((j) => j.shelf == shelf).toList();

  @override
  bool operator ==(Object other) => other is TrailJourney && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'TrailJourney($name)';
}
