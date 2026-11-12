import '../models/trail.dart';
import '../services/content_catalog_service.dart';

/// Trilhas costuradas com cenas que já existem (A Promessa,
/// docs/CAMINHADA_PREMIUM_PROMESSA.md). Vêm do Firestore como as outras:
/// cada cena emprestada grava `bankTrailSlug` + `bankSection` da cena de
/// origem, usa o banco, o estudo e a pintura dela e, ao terminar, conta
/// também lá (`alsoComplete` na celebração). Aqui ficam só as regras.
class CuratedTrails {
  CuratedTrails._();

  static const promiseSlug = 'a-promessa';

  /// Travessia final de A Promessa: três pontes promessa → cumprimento,
  /// perguntas no banco da própria trilha (section = este slug).
  static const synthesisSlug = 'promessa-sintese';

  static List<Trail> _trails = const [];
  static Map<String, String>? _origins;

  /// O catálogo chama a cada carga (disco ou Firestore).
  static void attach(List<Trail> trails) {
    _trails = trails;
    _origins = null;
  }

  /// Cena emprestada → cena de origem, em qualquer trilha do catálogo.
  static Map<String, String> get origins => _origins ??= {
    for (final t in _trails)
      for (final mod in t.modules)
        for (final m in mod.missions)
          if (m.bankTrailSlug != null &&
              m.bankTrailSlug != t.slug &&
              m.bankSection != null &&
              m.bankSection != m.slug)
            m.slug: m.bankSection!,
  };

  static String? originOf(String sceneSlug) => origins[sceneSlug];

  static Trail? get _promise {
    for (final t in _trails) {
      if (t.slug == promiseSlug) return t;
    }
    return null;
  }

  /// Blocos da jornada (para o mapa): título e cenas com banco de origem
  /// (a síntese fica fora; o mapa a mostra à parte).
  static List<({String title, List<Mission> scenes})> get promiseBlocks => [
    for (final mod in _promise?.modules ?? const <TrailModule>[])
      (
        title: mod.localizedTitle,
        scenes: [
          for (final m in mod.missions)
            if (origins.containsKey(m.slug)) m,
        ],
      ),
  ];

  /// Erros ainda na revisão que vieram das cenas de origem [sections]
  /// (id `trilha-modo-secao-nn`, o formato do banco).
  static List<String> mistakesFor(
    Iterable<String> mistakes,
    Iterable<String> sections,
  ) => [
    for (final id in mistakes)
      if (sections.any((s) => id.contains('-$s-') || id.endsWith('-$s'))) id,
  ];

  /// Perguntas da travessia já carregadas do banco.
  static List<String> get synthesisQuestionIds => [
    for (final q
        in ContentCatalogService.instance.bankQuestionsCache ?? const <Never>[])
      if (q.trailSlug == promiseSlug && q.section == synthesisSlug) q.id,
  ];

  /// Ids que a travessia usa no lugar do sorteio por modo (todas as pontes,
  /// em qualquer modo). Null para as outras cenas.
  static Future<List<String>?> prepareQuestions(String missionSlug) async {
    if (missionSlug != synthesisSlug) return null;
    await ContentCatalogService.instance.ensureTrailBank(promiseSlug);
    final ids = synthesisQuestionIds;
    return ids.isEmpty ? null : ids;
  }

  /// Cenas que contam junto com [missionSlug]: a origem de uma cena
  /// curada, ou as cenas curadas que usam [missionSlug] como origem.
  static Set<String> linkedScenes(String missionSlug) {
    final origin = origins[missionSlug];
    if (origin != null) return {origin};
    return {
      for (final e in origins.entries)
        if (e.value == missionSlug) e.key,
    };
  }
}
