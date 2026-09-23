import '../models/trail.dart';
import '../services/bible_service.dart';
import 'trail_progress.dart';

/// Loop aberto da próxima cena — o que a pessoa leva embora hoje.
class TomorrowHook {
  final String title;
  final String tease;
  /// Trailer da próxima cena — nota, não o versículo de entrada.
  final String pull;
  final String? missionSlug;
  final String? trailTitle;
  final String? trailSlug;
  final bool trailJustCompleted;
  /// Insight da missão que acabou — o corte HOJE / AMANHÃ.
  final String? todayInsight;
  final String? hookRef;
  /// Pergunta aberta da próxima missão — Eco (só se escrita à mão).
  final String? echoQuestion;

  const TomorrowHook({
    required this.title,
    required this.tease,
    this.pull = '',
    this.missionSlug,
    this.trailTitle,
    this.trailSlug,
    this.trailJustCompleted = false,
    this.todayInsight,
    this.hookRef,
    this.echoQuestion,
  });

  bool get hasEcho {
    final q = (echoQuestion ?? '').trim();
    final i = (todayInsight ?? '').trim();
    return q.isNotEmpty && i.isNotEmpty;
  }

  String get kicker => trailJustCompleted
      ? 'PRÓXIMA TRILHA'
      : hasEcho
      ? 'HOJE VOCÊ VIU'
      : 'AMANHÃ';

  /// Linha do cartão de celebração: a fome, não a porta.
  String get trailer {
    if (hasEcho) return echoQuestion!.trim();
    final p = pull.trim();
    if (p.isNotEmpty) return p;
    return tease.trim();
  }

  String get promiseLine => trailJustCompleted
      ? 'A próxima trilha já está no mapa.'
      : hasEcho
      ? 'Amanhã: $title'
      : 'A cena espera você.';

  String get cardLine => trailJustCompleted
      ? '${trailTitle ?? 'Amanhã'}: $title'
      : 'Amanhã: $title';

  static String? commitLine({required int streak, required int goal}) {
    if (streak <= 0 || goal <= 0 || streak > goal) return null;
    if (streak == goal && goal <= 7) return 'Sete dias. O hábito pegou.';
    return 'Dia $streak de $goal';
  }

  static String? yesterdayLine(String? insight) {
    final text = (insight ?? '').trim();
    if (text.isEmpty) return null;
    return 'Ontem: $text';
  }

  static String? echoDoorLine(String? echoQuestion) {
    final text = (echoQuestion ?? '').trim();
    return text.isEmpty ? null : text;
  }

  static bool promisedArrived({
    required String? promisedTitle,
    required String currentTitle,
  }) {
    final a = (promisedTitle ?? '').trim().toLowerCase();
    final b = currentTitle.trim().toLowerCase();
    return a.isNotEmpty && a == b;
  }

  static String? insightOf(List<Trail> trails, String slug) {
    for (final trail in trails) {
      for (final mission in trail.modules.expand((m) => m.missions)) {
        if (mission.slug == slug) {
          final text = (mission.centralInsight ?? '').trim();
          return text.isEmpty ? null : text;
        }
      }
    }
    return null;
  }

  /// Porta da próxima cena — verso vivo, se não for o título de novo.
  static String teaseOf(
    Mission mission, {
    int maxChars = 72,
    String? liveVerse,
  }) {
    for (final raw in [liveVerse, mission.hookVerse]) {
      final breath = firstBreath(raw, maxChars: maxChars);
      if (breath.isEmpty) continue;
      if (restatesTitle(mission.title, breath)) continue;
      return breath;
    }
    for (final raw in [
      mission.hookNote,
      mission.hookThread,
      mission.subtitle,
      mission.intro,
    ]) {
      final breath = firstBreath(raw, maxChars: maxChars);
      if (breath.isNotEmpty) return breath;
    }
    return 'A história continua no texto.';
  }

  /// Trailer da celebração — a nota puxa; o verso fica para a entrada.
  static String pullOf(Mission mission, {int maxChars = 88}) {
    for (final raw in [mission.hookNote, mission.hookThread]) {
      final breath = firstBreath(raw, maxChars: maxChars);
      if (breath.isNotEmpty) return breath;
    }
    final verse = firstBreath(mission.hookVerse, maxChars: maxChars);
    if (verse.isNotEmpty && !restatesTitle(mission.title, verse)) {
      return verse;
    }
    for (final raw in [mission.subtitle, mission.intro]) {
      final breath = firstBreath(raw, maxChars: maxChars);
      if (breath.isNotEmpty) return breath;
    }
    return teaseOf(mission, maxChars: maxChars);
  }

  /// O verso só repete o título (Salmo 23), sem cena nova.
  static bool restatesTitle(String title, String line) {
    final t = _fold(title);
    final v = _fold(line);
    if (t.length < 8 || v.length < 8) return false;
    if (v.startsWith(t) || t.startsWith(v)) return true;
    final clause = v.split(';').first.trim();
    if (clause.length < 8) return false;
    return clause == t || clause.startsWith(t) || t.startsWith(clause);
  }

  static String _fold(String raw) {
    var s = raw.toLowerCase().replaceAll('jeová', 'senhor').replaceAll(
          'jeova',
          'senhor',
        );
    const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const to = 'aaaaaeeeeiiiiooooouuuuc';
    final buf = StringBuffer();
    for (final ch in s.split('')) {
      final i = from.indexOf(ch);
      buf.write(i >= 0 ? to[i] : ch);
    }
    s = buf.toString().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s.replaceFirst(RegExp(r'^(o|a|os|as|um|uma)\s+'), '');
  }

  /// Verso na tradução de leitura (Almeida se a ativa for TB / Jeová).
  static Future<String> readerTease(
    Mission mission, {
    int maxChars = 72,
  }) async {
    final ref = (mission.hookRef ?? '').trim();
    String? live;
    if (ref.isNotEmpty && BibleService.looksLikeReference(ref)) {
      try {
        live = await BibleService.instance.passageText(
          ref,
          translationId: BibleService.instance.readerTranslationId,
        );
      } catch (_) {}
    }
    return teaseOf(mission, maxChars: maxChars, liveVerse: live);
  }

  TomorrowHook withToday(String? insight) {
    final text = (insight ?? '').trim();
    if (text.isEmpty || text == todayInsight) return this;
    return TomorrowHook(
      title: title,
      tease: tease,
      pull: pull,
      missionSlug: missionSlug,
      trailTitle: trailTitle,
      trailSlug: trailSlug,
      trailJustCompleted: trailJustCompleted,
      todayInsight: text,
      hookRef: hookRef,
      echoQuestion: echoQuestion,
    );
  }

  Future<TomorrowHook> withReaderVerse() async {
    final ref = (hookRef ?? '').trim();
    if (ref.isEmpty || !BibleService.looksLikeReference(ref)) return this;
    try {
      final live = await BibleService.instance.passageText(
        ref,
        translationId: BibleService.instance.readerTranslationId,
      );
      final breath = firstBreath(live);
      if (breath.isEmpty || breath == tease) return this;
      if (restatesTitle(title, breath)) return this;
      return TomorrowHook(
        title: title,
        tease: breath,
        pull: pull,
        missionSlug: missionSlug,
        trailTitle: trailTitle,
        trailSlug: trailSlug,
        trailJustCompleted: trailJustCompleted,
        todayInsight: todayInsight,
        hookRef: hookRef,
        echoQuestion: echoQuestion,
      );
    } catch (_) {
      return this;
    }
  }

  /// Uma frase. Corta no “…” do catálogo e no primeiro ponto.
  static String firstBreath(String? raw, {int maxChars = 72}) {
    var text = (raw ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
    if (text.isEmpty) return '';
    text = text.split(RegExp(r'…|\.{3}')).first.trim();
    final sentence = RegExp(r'^(.+?[.!?])(?:\s|$)').firstMatch(text);
    if (sentence != null) {
      final s = sentence.group(1)!.trim();
      if (s.length <= maxChars) return s;
      text = s;
    }
    return clip(text, maxChars: maxChars);
  }

  static String clip(String? raw, {int maxChars = 72}) {
    final text = (raw ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
    if (text.isEmpty) return '';
    if (text.length <= maxChars) return text;
    final cut = text.substring(0, maxChars);
    final space = cut.lastIndexOf(' ');
    final keep = space >= 28 ? cut.substring(0, space) : cut;
    return '$keep…';
  }

  static TomorrowHook? fromMission({
    required Mission next,
    required String trailTitle,
    required String trailSlug,
    required bool trailJustCompleted,
    String? todayInsight,
  }) {
    final echo = (next.echoQuestion ?? '').trim();
    return TomorrowHook(
      title: next.title.trim(),
      tease: teaseOf(next),
      pull: pullOf(next),
      missionSlug: next.slug,
      trailTitle: trailTitle,
      trailSlug: trailSlug,
      trailJustCompleted: trailJustCompleted,
      todayInsight: todayInsight,
      hookRef: (next.hookRef ?? '').trim().isEmpty ? null : next.hookRef!.trim(),
      echoQuestion: echo.isEmpty ? null : echo,
    );
  }

  static TomorrowHook? resolve({
    required List<Trail> trails,
    required List<String> completed,
    Map<String, List<String>> clearedTrailModes = const {},
    String? justFinishedSlug,
  }) {
    if (trails.isEmpty) return null;
    final finished = (justFinishedSlug ?? '').trim();
    final todayInsight =
        finished.isEmpty ? null : insightOf(trails, finished);

    // Celebração: o amanhã é a próxima cena DA trilha que acabou —
    // não a primeira trilha "ativa" do catálogo (Ansiedade vinha antes).
    final homeTrail = finished.isEmpty
        ? null
        : trails.where((t) => t.missionSlugs.contains(finished)).firstOrNull;
    final active = homeTrail ??
        TrailProgress.findActiveTrail(
          trails,
          completed,
          clearedTrailModes: clearedTrailModes,
        );
    if (active == null) return null;

    final next = TrailProgress.getCurrentMission(active, completed);
    if (next != null) {
      return fromMission(
        next: next,
        trailTitle: active.title,
        trailSlug: active.slug,
        trailJustCompleted: false,
        todayInsight: todayInsight,
      );
    }

    final following = trails
        .where(
          (t) =>
              !t.comingSoon &&
              t.missionSlugs.isNotEmpty &&
              t.unlockAfter == active.slug,
        )
        .toList();
    Trail? successor = following.isEmpty ? null : following.first;
    successor ??= TrailProgress.findActiveTrail(
      trails.where((t) => t.slug != active.slug).toList(),
      completed,
      clearedTrailModes: clearedTrailModes,
    );
    if (successor == null) return null;
    final first = TrailProgress.getCurrentMission(successor, completed);
    if (first == null) return null;
    return fromMission(
      next: first,
      trailTitle: successor.title,
      trailSlug: successor.slug,
      trailJustCompleted: true,
      todayInsight: todayInsight,
    );
  }
}
