import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/season_walk_catalog.dart';
import '../data/trail_art.dart';
import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/room_plan.dart';
import '../models/season_walk.dart';
import '../models/study_room.dart';
import '../services/bible_service.dart';
import '../services/content_catalog_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/content_filter.dart';
import '../utils/plan_questions.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'room_panels.dart';
import 'room_pilot_cards.dart';
import 'room_plan_cards.dart';
import 'ui_primitives.dart';

/// Perguntas gerais do propósito, com a referência do dia ("Gênesis 4").
List<String> planGeneralQuestions(BuildContext context, String ref) {
  final l = context.l10n;
  return [
    l.planQ1(ref),
    l.planQ2(ref),
    l.planQ3(ref),
    l.planQ4(ref),
    l.planQ5(ref),
    l.planQ6(ref),
    l.planQ7(ref),
    l.planQ8(ref),
    l.planQ9(ref),
    l.planQ10(ref),
  ];
}

/// Líder cria ou edita o propósito. O conteúdo vem do que o grupo já
/// segue: a trilha do estudo ([study], cenas em ordem a partir dela) e a
/// leitura ([reading], capítulos em sequência a partir dela). O líder só
/// escolhe o período. Em curso ([current] ativo): início e descanso fixos e
/// os dias que já abriram não mudam.
Future<RoomPlan?> showRoomPlanEditor(
  BuildContext context, {
  RoomPlan? current,
  RoomStudy? study,
  RoomReading? reading,
}) {
  return showAppSheet<RoomPlan>(
    context,
    builder: (_) =>
        _PlanEditor(current: current, study: study, reading: reading),
  );
}

/// Leitura do propósito: livro e capítulo de partida.
typedef _ReadingSource = ({String abbrev, String name, int from});

/// Cena de partida e a trilha dela ([trailSlug] alimenta a arte do card).
typedef _SceneSource = ({
  String slug,
  String title,
  String? trail,
  String? trailSlug,
});

class _PlanEditor extends StatefulWidget {
  final RoomPlan? current;
  final RoomStudy? study;
  final RoomReading? reading;

  const _PlanEditor({this.current, this.study, this.reading});

  @override
  State<_PlanEditor> createState() => _PlanEditorState();
}

class _PlanEditorState extends State<_PlanEditor> {
  /// Duração em semanas inteiras (o fim fecha a semana).
  static const _weekOptions = [1, 2, 3, 4];

  final _title = TextEditingController();
  final _titleFocus = FocusNode();
  late DateTime _start;
  late DateTime _end;
  Set<int> _rest = {};

  _ReadingSource? _reading;
  int _perDay = 1;
  int _bookChapters = 0;

  _SceneSource? _scene;
  List<PlanScene> _scenes = const [];

  /// Índice do dia em que cada fonte começa. Com o propósito em andamento,
  /// trocar a cena ou o capítulo vale do dia seguinte em diante.
  int _readingFrom = 0;
  int _sceneFrom = 0;

  /// Temporada (Advento) como fonte das cenas: cada dia do propósito pega
  /// a cena do dia da temporada na mesma data. Null = cenas da trilha.
  SeasonWalkCampaign? _season;

  static SeasonWalkCampaign? _campaignById(String id) {
    final now = DateTime.now();
    for (final c in [
      ...SeasonWalkCatalog.all(now),
      ?SeasonWalkCatalog.justEnded(now),
    ]) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _useSeason(SeasonWalkCampaign c) {
    _season = c;
    _scene = (
      slug: c.days.first.missionSlug,
      title: c.title,
      trail: c.title,
      trailSlug: null,
    );
    _scenes = const [];
    _sceneFrom = 0;
  }

  /// Sai da estação. Propósito novo volta a semanas inteiras (3), já que a
  /// duração da estação não fecha semana.
  void _leaveSeason() {
    if (_season != null && _live == null) _end = _endForWeeks(3);
    _season = null;
  }

  /// Pintura da trilha/estação escolhida — mesma arte do caminho.
  String? get _sceneArt {
    final season = _season;
    if (season != null) return SeasonWalkCatalog.artAsset(season.kind);
    final scene = _scene;
    final trailSlug = scene?.trailSlug;
    if (scene == null || trailSlug == null) return null;
    return TrailArt.ofScene(trailSlug, scene.slug) ?? TrailArt.of(trailSlug);
  }

  PlanScene? _seasonSceneOn(String date) {
    final c = _season;
    final d = parsePlanYmd(date);
    if (c == null || d == null) return null;
    final day = c.dayAt(c.dayIndexOn(d) ?? 0);
    return day == null
        ? null
        : PlanScene(slug: day.missionSlug, title: day.title);
  }

  bool _questionOn = true;

  /// Capítulo do dia segue as cenas: cada dia traz o capítulo da passagem
  /// da sua cena (trilha ou estação). O líder troca por um livro corrido.
  bool _readingFromScenes = false;

  /// Capítulo(s) da passagem de cada cena, por slug.
  final Map<String, PlanReading?> _sceneReadings = {};

  /// Fim escolhido à mão com a trilha: vence o "um dia por cena" (dias a
  /// mais ficam sem cena; a menos, cortam cenas). Null = segue as cenas.
  DateTime? _endOverride;
  final Map<int, ({String? question, String? note})> _edits = {};

  /// Trocou a trilha/estação com o propósito em andamento: ele recomeça do
  /// dia 1 (id novo), só com a escolha nova. Daí em diante o editor trata
  /// como propósito novo.
  bool _restart = false;

  /// Quantos dias o propósito tinha antes de trocar a trilha/estação (para
  /// dizer se a escolha nova é menor ou maior). Null = nada trocado.
  int? _before;

  /// Propósito que já começou (início antes de hoje). Começa hoje ainda
  /// conta como novo: o líder pode mexer no início e na trilha à vontade.
  RoomPlan? get _live {
    final c = widget.current;
    if (_restart || c == null || c.phase() != PlanPhase.active) return null;
    return c.start.compareTo(planYmd(DateTime.now())) < 0 ? c : null;
  }

  RoomPlan? get _editing {
    final c = widget.current;
    return c != null && c.phase() != PlanPhase.ended ? c : null;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final c = _editing;
    if (c == null) {
      _start = DateTime(now.year, now.month, now.day + 1);
      _end = _endForWeeks(3);
      final r = widget.reading;
      if (r != null) {
        _reading = (abbrev: r.bookAbbrev, name: r.bookName, from: r.from);
      }
      final s = widget.study;
      if (s != null) {
        _readingFromScenes = r == null;
        _scene = (
          slug: s.missionSlug,
          title: s.title,
          trail: null,
          trailSlug: null,
        );
        _resolveScenes(s.missionSlug);
      }
    } else {
      _title.text = c.title;
      _start = parsePlanYmd(c.start)!;
      _end = parsePlanYmd(c.end)!;
      _rest = {...c.restDays};
      final g = c.gen;
      final rb = g['rb'] as String?;
      if (rb != null) {
        _reading = (
          abbrev: rb,
          name:
              (g['rn'] as String?) ??
              c.days.firstWhere((d) => d.reading != null).reading!.bookName,
          from: (g['rf'] as num?)?.toInt() ?? 1,
        );
        _perDay = (g['rp'] as num?)?.toInt() ?? 1;
        _readingFrom = (g['ro'] as num?)?.toInt() ?? 0;
      }
      final sw = c.seasonId;
      final season = sw == null ? null : _campaignById(sw);
      final ss = g['ss'] as String?;
      if (season != null) {
        _useSeason(season);
        _loadSceneQuestions(_seasonScenes(season));
      } else if (ss != null) {
        _sceneFrom = (g['so'] as num?)?.toInt() ?? 0;
        _scenes = [
          for (final d in c.days)
            if (d.scene != null) d.scene!,
        ];
        _scene = (
          slug: ss,
          title: _scenes.isEmpty ? ss : _scenes.first.title,
          trail: g['st'] as String?,
          trailSlug: g['tsk'] as String?,
        );
        _resolveScenes(ss);
      }
      _questionOn = g['q'] != false;
      _readingFromScenes = g['rs'] == true;
      if (g['eo'] == true) _endOverride = _end;
      // Pergunta do líder e recado ficam como edição do dia.
      for (final d in c.days) {
        final q = d.customQuestion ? d.question : null;
        if (q != null || d.hasNote) {
          _edits[d.n] = (question: q, note: d.note);
        }
      }
    }
    _loadBookChapters();
  }

  bool _titleChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nome salvo que é o automático ("{trilha} em {n} dias"): volta a ser
    // sugestão, para acompanhar a trilha e a duração se elas mudarem.
    if (_titleChecked) return;
    _titleChecked = true;
    if (_isAutoTitle(_title.text)) _title.clear();
  }

  /// O nome tem a forma do automático ("{trilha} em {n} dias" ou
  /// "Propósito de {n} dias"), com qualquer trilha e quantidade.
  bool _isAutoTitle(String text) {
    final t = text.trim();
    if (t.isEmpty) return false;
    const what = '\u0001';
    const count = 9090;
    final l10n = context.l10n;
    for (final sample in [
      l10n.planAutoTitle(what, count),
      l10n.planEditorNameDefault(count),
    ]) {
      final body = RegExp.escape(
        sample,
      ).replaceFirst(what, '.+').replaceFirst('$count', r'\d+');
      if (RegExp('^$body\$').hasMatch(t)) return true;
    }
    return false;
  }

  @override
  void dispose() {
    _title.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Future<void> _loadBookChapters() async {
    final r = _reading;
    if (r == null) return;
    final books = await BibleService.instance.books();
    final book = books.where((b) => b.abbrev == r.abbrev).firstOrNull;
    if (!mounted || book == null) return;
    setState(() => _bookChapters = book.chapters.length);
    // Índice capítulo → cena do livro: a pergunta do dia sai dele.
    await PlanQuestions.ensureBook(book.name);
    if (mounted) setState(() {});
  }

  /// Estudos das cenas ainda chegando: salvar agora gravaria perguntas que
  /// não são as da trilha (o botão espera).
  int _loadingQuestions = 0;

  static List<PlanScene> _seasonScenes(SeasonWalkCampaign c) => [
    for (final d in c.days) PlanScene(slug: d.missionSlug, title: d.title),
  ];

  /// Estudos das cenas (pergunta) e o capítulo da passagem de cada uma.
  Future<void> _loadSceneQuestions(List<PlanScene> scenes) async {
    // Sem setState aqui: pode vir do initState; quem chama já redesenha.
    _loadingQuestions++;
    try {
      await PlanQuestions.ensureScenes(scenes.map((s) => s.slug));
      final studies = ContentCatalogService.instance.studiesCache ?? const {};
      for (final sc in scenes) {
        if (_sceneReadings.containsKey(sc.slug)) continue;
        final passage = studies[sc.slug]?['passageRef'];
        final ref = passage is String && passage.trim().isNotEmpty
            ? passage.trim()
            : sc.ref;
        _sceneReadings[sc.slug] = ref == null ? null : await _readingOf(ref);
      }
    } finally {
      _loadingQuestions--;
      if (mounted) setState(() {});
    }
  }

  /// "Gênesis 1:1–2:3" → Gênesis 1–2 (até 3 capítulos).
  static Future<PlanReading?> _readingOf(String ref) async {
    final bible = BibleService.instance;
    final r = await bible.resolve(ref);
    if (r == null) return null;
    final books = await bible.books();
    if (r.bookIndex >= books.length) return null;
    final book = books[r.bookIndex];
    var to = r.chapter;
    final m = RegExp(r'[–—-]\s*(\d+)\s*:').firstMatch(ref);
    if (m != null) {
      final t = int.parse(m.group(1)!);
      if (t > to && t <= book.chapters.length && t - r.chapter < 3) to = t;
    }
    return PlanReading(
      bookAbbrev: book.abbrev,
      bookName: book.name,
      from: r.chapter,
      to: to,
    );
  }

  Future<void> _resolveScenes(String firstSlug) async {
    final trails = await TrailRepository().getTrails();
    for (final t in trails) {
      final i = t.missionSlugs.indexOf(firstSlug);
      if (i < 0) continue;
      final bySlug = {
        for (final mod in t.modules)
          for (final m in mod.missions) m.slug: m,
      };
      final list = <PlanScene>[
        for (final slug in t.missionSlugs.skip(i))
          if (bySlug[slug] != null)
            PlanScene(
              slug: slug,
              title: bySlug[slug]!.localizedTitle,
              ref: bySlug[slug]!.hookRef ?? bySlug[slug]!.subtitle,
            ),
      ];
      // Perguntas das cenas: os estudos vêm por trilha, sob demanda.
      await _loadSceneQuestions(list);
      if (!mounted || _scene?.slug != firstSlug) return;
      setState(() {
        _scenes = list;
        _scene = (
          slug: firstSlug,
          title: list.isEmpty ? _scene!.title : list.first.title,
          trail: t.localizedTitle,
          trailSlug: t.slug,
        );
      });
      return;
    }
  }

  /// Fim de [weeks] semanas inteiras a partir do início (7 dias cada).
  DateTime _endForWeeks(int weeks) =>
      DateTime(_start.year, _start.month, _start.day + 7 * weeks - 1);

  /// Semanas do período atual (0 se não fecha semanas inteiras).
  int get _weeks {
    final span = _end.difference(_start).inDays + 1;
    return span % 7 == 0 ? span ~/ 7 : 0;
  }

  /// Estação é diária: propósito novo com o Advento não tem descanso (senão
  /// o dia de descanso apagaria o dia do Advento). Em andamento, os dias já
  /// gravados mandam — mudar o descanso renumeraria as respostas.
  Set<int> get _restOn =>
      _season != null && _live == null ? const <int>{} : _rest;

  /// Todas as datas do período, sem olhar a fonte de cenas.
  List<String> get _periodDates => RoomPlan.datesBetween(_start, _end, _restOn);

  /// A duração segue as cenas: trilha = um dia por cena (pulando o
  /// descanso); estação = as datas dela. Sem cena, o período escolhido.
  /// Propósito em andamento que não trocou a trilha mantém os dias dele.
  bool get _sceneDriven =>
      _scene != null && (_season != null || _scenes.isNotEmpty);

  List<String> get _dates {
    if (!_sceneDriven || _live != null) return _periodDates;
    if (_season != null) {
      return [
        for (final d in _periodDates)
          if (_seasonSceneOn(d) != null) d,
      ];
    }
    final over = _endOverride;
    if (over != null) return RoomPlan.datesBetween(_start, over, _restOn);
    final n = math.min(_scenes.length, RoomPlan.maxDays);
    final far = DateTime(_start.year, _start.month, _start.day + n * 7 + 7);
    return RoomPlan.datesBetween(_start, far, _restOn).take(n).toList();
  }

  /// Dias que já passaram (hoje incluso) com o propósito em andamento: a
  /// fonte trocada agora começa depois deles. Fora do andamento, 0.
  int get _keptDays {
    if (_live == null) return 0;
    final today = planYmd(DateTime.now());
    return _periodDates.where((d) => d.compareTo(today) <= 0).length;
  }

  /// Vai trocar a trilha/estação. O início volta para hoje (a estação
  /// depois ajusta às datas dela). Em andamento, o propósito recomeça do
  /// dia 1 só com a escolha nova; a leitura segue do próximo
  /// capítulo ainda não aberto. Perguntas e recados à mão eram da escolha
  /// antiga e saem.
  void _beginSceneChange() {
    _before = _scene == null ? null : _dates.length;
    _edits.clear();
    // Trilha nova: perguntas voltam a sair das cenas dela e o fim volta a
    // seguir as cenas. O líder troca depois, se quiser.
    _questionOn = true;
    _endOverride = null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Nome automático segue a escolha nova; nome escrito pelo líder fica.
    if (_isAutoTitle(_title.text)) _title.clear();
    final live = _live;
    if (live == null) {
      _start = today;
      return;
    }
    final kept = _keptDays;
    final r = _reading;
    if (r != null) {
      PlanReading? last;
      for (final d in _buildDays().take(kept)) {
        if (d.reading != null) last = d.reading;
      }
      if (last != null) {
        final next = last.to + 1;
        _reading = _bookChapters > 0 && next > _bookChapters
            ? null
            : (abbrev: r.abbrev, name: r.name, from: next);
      }
    }
    _readingFrom = 0;
    _sceneFrom = 0;
    _restart = true;
    _start = today;
  }

  /// Trilha/estação escolhida: o capítulo do dia passa a ser o da cena
  /// (troca a leitura corrida que houvesse).
  void _followSceneReading() {
    _readingFromScenes = true;
    _reading = null;
    _readingFrom = 0;
  }

  /// Aviso depois de trocar a trilha/estação: se a escolha nova é menor
  /// ou maior que a anterior e que duração e perguntas seguem ela.
  String? _sceneChangeNote(List<PlanDay> days) {
    final scene = _scene;
    if (scene == null || days.isEmpty || (_before == null && !_restart)) {
      return null;
    }
    final l10n = context.l10n;
    final name = _season?.title ?? scene.trail ?? scene.title;
    final now = days.length;
    final before = _before;
    final size = before == null
        ? l10n.planSourceChangedFollows(name, now)
        : now < before
        ? l10n.planSourceChangedShorter(name, now, before)
        : now > before
        ? l10n.planSourceChangedLonger(name, now, before)
        : l10n.planSourceChangedSame(name, now);
    if (!_restart) return size;
    return '$size ${l10n.planSourceRestart(planDateShort(context, days.first.date))}';
  }

  bool get _readingReady => _reading == null || _bookChapters > 0;

  String _autoTitle(int days) {
    final l10n = context.l10n;
    final what = _scene?.trail ?? _reading?.name;
    return what == null
        ? l10n.planEditorNameDefault(days)
        : l10n.planAutoTitle(what, days);
  }

  /// Tem cena ou capítulo: sem nenhum dos dois não há o que fazer nem
  /// sobre o que perguntar.
  bool get _hasContent => _reading != null || _scene != null;

  /// Sugestões de pergunta para o dia: a da cena (vida, texto), a da cena
  /// que mora no capítulo e uma geral com a referência.
  List<({String label, String text})> _suggestions(
    int index,
    PlanReading? r,
    PlanScene? s,
  ) {
    final l10n = context.l10n;
    final bank = PlanQuestions.load();
    final out = <({String label, String text})>[];
    void addScene(String slug) {
      final q = bank.forScene(slug);
      if (q.life != null) out.add((label: l10n.planSuggestLife, text: q.life!));
      if (q.text != null) out.add((label: l10n.planSuggestText, text: q.text!));
    }

    if (s != null) addScene(s.slug);
    // Com trilha/estação escolhida, a pergunta é só a da cena do dia (sem
    // cena nesse dia, a geral). A cena que mora no capítulo é de outra
    // trilha: só serve ao propósito que é apenas capítulo.
    if (out.isEmpty && r != null && _scene == null) {
      for (var ch = r.from; ch <= r.to && out.isEmpty; ch++) {
        final slug = bank.sceneForChapter(r.bookName, ch);
        if (slug != null) addScene(slug);
      }
    }
    final ref = s != null ? (s.ref ?? s.title) : r?.label;
    if (ref != null && ref.trim().isNotEmpty) {
      final general = planGeneralQuestions(context, ref.trim());
      out.add((
        label: l10n.planSuggestGeneral,
        text: general[index % general.length],
      ));
    }
    return out;
  }

  /// Pergunta do dia: da cena; sem cena, da cena do capítulo; senão geral
  /// com a referência. Sem cena nem capítulo, nenhuma.
  String? _questionFor(int index, PlanReading? r, PlanScene? s) {
    if (!_questionOn) return null;
    final list = _suggestions(index, r, s);
    return list.isEmpty ? null : list.first.text;
  }

  List<PlanDay> _buildDays() {
    final r = _reading;
    var days = RoomPlan.buildDays(
      dates: _dates,
      reading: r != null && _bookChapters > 0
          ? (
              abbrev: r.abbrev,
              name: r.name,
              from: r.from,
              perDay: _perDay,
              bookChapters: _bookChapters,
            )
          : null,
      scenes: _scene == null ? const [] : _scenes,
      questionFor: _questionFor,
      readingFrom: _readingFrom,
      sceneFrom: _sceneFrom,
      sceneOn: _season == null ? null : _seasonSceneOn,
      edits: {
        for (final e in _edits.entries)
          e.key: (
            question: _questionOn ? e.value.question : null,
            note: e.value.note,
          ),
      },
    );
    if (_readingFromScenes) {
      days = [
        for (final d in days)
          d.scene == null
              ? d
              : PlanDay(
                  n: d.n,
                  date: d.date,
                  reading: _sceneReadings[d.scene!.slug],
                  scene: d.scene,
                  question: d.question,
                  note: d.note,
                  customQuestion: d.customQuestion,
                ),
      ];
    }
    final live = _live;
    if (live != null) {
      final today = planYmd(DateTime.now());
      days = [
        for (final d in days)
          if (d.date.compareTo(today) <= 0 && live.dayNumber(d.n) != null)
            live.dayNumber(d.n)!
          else
            d,
      ];
    }
    return days;
  }

  void _save() {
    final days = _buildDays();
    if (days.isEmpty) return;
    final typed = _title.text.trim();
    final title = typed.isEmpty ? _autoTitle(days.length) : typed;
    if (!ContentFilter.isAllowed(title)) return;
    final r = _reading;
    final s = _scene;
    // Propósito que começa hoje e troca a fonte: o dia 1 muda de conteúdo,
    // então ganha id novo (quem já fez o dia 1 antigo recomeça junto).
    final cur = _editing;
    final sourceChanged =
        cur != null &&
        cur.start == planYmd(DateTime.now()) &&
        (cur.gen['ss'] != (_season == null ? s?.slug : null) ||
            cur.seasonId != _season?.id ||
            cur.gen['rb'] != r?.abbrev ||
            (r != null && cur.gen['rf'] != r.from));
    final fresh = _restart || sourceChanged;
    Navigator.pop(
      context,
      RoomPlan(
        id:
            (fresh ? null : cur?.id) ??
            DateTime.now().millisecondsSinceEpoch.toRadixString(36),
        title: title.length > RoomPlan.maxTitle
            ? title.substring(0, RoomPlan.maxTitle)
            : title,
        start: days.first.date,
        end: days.last.date,
        restDays: _restOn,
        days: days,
        gen: {
          if (r != null) ...{
            'rb': r.abbrev,
            'rn': r.name,
            'rf': r.from,
            'rp': _perDay,
            if (_readingFrom > 0) 'ro': _readingFrom,
          },
          if (_season != null)
            'sw': _season!.id
          else if (s != null) ...{
            'ss': s.slug,
            'st': ?s.trail,
            'tsk': ?s.trailSlug,
            if (_sceneFrom > 0) 'so': _sceneFrom,
          },
          'q': _questionOn,
          if (_readingFromScenes && _scene != null) 'rs': true,
          if (_endOverride != null && _sceneDriven && _season == null)
            'eo': true,
          if (fresh && widget.current != null)
            'pv': [
              widget.current!.id,
              ...widget.current!.previousIds,
            ].take(5).toList(),
        },
      ),
    );
  }

  /// Estudo da leitura: cena da trilha ou 1ª cena da estação (com versículo).
  Future<RoomStudy?> _studyForReading() async {
    final week = planYmd(_start);
    if (_scenes.isNotEmpty) {
      final first = _scenes.first;
      return RoomStudy(
        missionSlug: first.slug,
        title: first.title,
        verseRef: first.ref,
        week: week,
      );
    }
    final season = _season;
    if (season == null || season.days.isEmpty) return null;
    // Primeiro dia do propósito que cai na estação; senão o 1º da campanha.
    String? slug;
    String? title;
    for (final d in _dates) {
      final scene = _seasonSceneOn(d);
      if (scene == null) continue;
      slug = scene.slug;
      title = scene.title;
      break;
    }
    final day = season.days.first;
    final missionSlug = slug ?? day.missionSlug;
    final missionTitle = title ?? day.title;
    final trails = await TrailRepository().getTrails();
    for (final t in trails) {
      for (final mod in t.modules) {
        for (final m in mod.missions) {
          if (m.slug != missionSlug) continue;
          final ref = (m.hookRef ?? m.subtitle).trim();
          if (ref.isEmpty) return null;
          return RoomStudy(
            missionSlug: m.slug,
            title: missionTitle,
            verseRef: ref,
            week: week,
          );
        }
      }
    }
    return null;
  }

  Future<void> _pickReading() async {
    final study = await _studyForReading();
    if (!mounted) return;
    final r = _reading;
    final picked = await showRoomReadingPicker(
      context,
      startOnly: true,
      // "Mesmo texto da cena": trilha ou 1ª cena da estação (Advento).
      study: study,
      current: r == null
          ? null
          : RoomReading(
              bookAbbrev: r.abbrev,
              bookName: r.name,
              from: r.from,
              to: r.from,
              week: planYmd(_start),
            ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _readingFromScenes = false;
      _readingFrom = _keptDays;
      _reading = (
        abbrev: picked.bookAbbrev,
        name: picked.bookName,
        from: picked.from,
      );
      _bookChapters = 0;
    });
    await _loadBookChapters();
  }

  Future<void> _pickScene() async {
    final study = await showRoomStudyPicker(
      context,
      title: context.l10n.planPickSceneTitle,
      skipNote: true,
      withSeason: true,
    );
    if (study == null || !mounted) return;
    final seasonId = study.seasonId;
    final season = seasonId == null ? null : _campaignById(seasonId);
    if (season != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      setState(() {
        _beginSceneChange();
        _useSeason(season);
        _followSceneReading();
        // A estação tem data fixa: o propósito segue a duração dela, do 1º
        // dia (ou de hoje, se já começou) ao último.
        if (!season.end.isBefore(today)) {
          _start = season.start.isBefore(today) ? today : season.start;
          _end = season.end;
        }
      });
      await _loadSceneQuestions(_seasonScenes(season));
      return;
    }
    setState(() {
      _beginSceneChange();
      _leaveSeason();
      _followSceneReading();
      _sceneFrom = _keptDays;
      _scene = (
        slug: study.missionSlug,
        title: study.title,
        trail: null,
        trailSlug: null,
      );
      _scenes = [
        PlanScene(
          slug: study.missionSlug,
          title: study.title,
          ref: study.verseRef,
        ),
      ];
    });
    await _resolveScenes(study.missionSlug);
  }

  /// Só o início é escolhido; o fim sai das semanas.
  Future<void> _pickStart() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Estação: o início fica dentro das datas dela (o fim é o dela).
    final season = _season;
    final last = season != null && !season.end.isBefore(today)
        ? season.end
        : today.add(const Duration(days: 120));
    var initial = _start.isBefore(today) ? today : _start;
    if (initial.isAfter(last)) initial = last;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: last,
    );
    if (picked == null || !mounted) return;
    setState(() {
      final weeks = _weeks == 0 ? 3 : _weeks;
      _start = picked;
      if (season == null) _end = _endForWeeks(weeks);
      _endOverride = null;
    });
  }

  /// Fim à mão. Trilha: troca o "um dia por cena". Estação: só encurta
  /// (depois do último dia dela não há cena). Em andamento: não antes de hoje.
  Future<void> _pickEnd(String current) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final first = _start.isBefore(today) ? today : _start;
    final season = _season;
    final last = season != null
        ? season.end
        : DateTime(
            _start.year,
            _start.month,
            _start.day + RoomPlan.maxDays - 1,
          );
    if (last.isBefore(first)) return;
    var initial = parsePlanYmd(current) ?? first;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (_sceneDriven && _season == null && _live == null) {
        _endOverride = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _editDay(PlanDay day) async {
    final result = await showAppSheet<({String? question, String? note})>(
      context,
      builder: (_) => _DayEditSheet(
        day: day,
        askQuestion: _questionOn,
        suggestions: _suggestions(day.n - 1, day.reading, day.scene),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _edits[day.n] = result);
  }

  /// Dias da pergunta — mesmo padrão da trilha e do capítulo (sheet próprio).
  Future<void> _pickQuestions() async {
    final live = _live;
    final today = planYmd(DateTime.now());
    await showAppSheet<void>(
      context,
      builder: (_) => _QuestionsDaysSheet(
        daysOf: _buildDays,
        isLocked: (d) => live != null && d.date.compareTo(today) <= 0,
        onEdit: _editDay,
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final screen = MediaQuery.sizeOf(context).height;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final top = MediaQuery.paddingOf(context).top;
    final height = (screen * 0.86)
        .clamp(0.0, screen - keyboard - top - 96)
        .toDouble();
    final live = _live;
    final count = _dates.length;
    final days = _readingReady ? _buildDays() : const <PlanDay>[];
    final today = planYmd(DateTime.now());
    final readingDays = days.where((d) => d.reading != null).toList();
    final sceneDays = days.where((d) => d.scene != null).length;

    final reading = _reading;
    final scene = _scene;
    final followScenes = _readingFromScenes && scene != null;

    return AppSheetPanel(
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SectionLabel(
                    _editing == null
                        ? l10n.planEditorTitleNew
                        : l10n.planEditorTitleEdit,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  // O título é o próprio campo: toca e escreve.
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _title,
                          focusNode: _titleFocus,
                          maxLength: RoomPlan.maxTitle,
                          maxLines: 2,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          style: AppTypography.title(size: 24, color: a.text),
                          decoration: InputDecoration.collapsed(
                            hintText: _autoTitle(count),
                            hintStyle: AppTypography.title(
                              size: 24,
                              color: a.text.withValues(alpha: 0.55),
                            ),
                          ).copyWith(counterText: ''),
                        ),
                      ),
                      // O lápis também abre a edição: traz o nome sugerido
                      // para o campo (se vazio) e põe o cursor no fim.
                      Semantics(
                        button: true,
                        label: l10n.planEditorRename,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            ActHaptics.tap();
                            if (_title.text.trim().isEmpty) {
                              _title.text = _autoTitle(count);
                            }
                            _title.selection = TextSelection.collapsed(
                              offset: _title.text.length,
                            );
                            _titleFocus.requestFocus();
                          },
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: CinematicIcon(
                                glyph: CinematicGlyph.pencil,
                                size: 16,
                                accent: a.textSecondary,
                                framed: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    count == 0
                        ? l10n.planEditorCount(0)
                        : l10n.planDateRange(
                            count,
                            planDateShort(context, planYmd(_start)),
                            planDateShort(context, planYmd(_end)),
                          ),
                    style: AppTypography.body(
                      size: 14,
                      color: count == 0 ? AppRoles.risk : a.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),

                  // ── O que o grupo faz ──
                  SectionLabel(l10n.planEditorWhatDaily),
                  const SizedBox(height: AppSpace.sm),
                  if (live != null) ...[
                    Text(
                      l10n.planSourceFromTomorrow,
                      style: AppTypography.body(
                        size: 13,
                        color: a.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                  ],
                  _SourceRow(
                    glyph: CinematicGlyph.path,
                    title: l10n.planSourceScene,
                    body: scene == null
                        ? l10n.planSourceSceneEmpty
                        : _season != null
                        ? l10n.planSourceSeason(_season!.title)
                        : l10n.planSourceSceneFrom(
                            scene.trail ?? '',
                            scene.title,
                          ),
                    note: scene != null && days.isNotEmpty
                        ? l10n.planSourceSceneCount(sceneDays, days.length)
                        : null,
                    art: _sceneArt,
                    on: scene != null,
                    action: scene == null
                        ? l10n.planSourcePick
                        : l10n.roomReadingChange,
                    onAction: _pickScene,
                    onRemove: scene == null
                        ? null
                        : () => setState(() {
                            _edits.removeWhere((n, _) => n > _keptDays);
                            _scene = null;
                            _readingFromScenes = false;
                            _scenes = const [];
                            _leaveSeason();
                          }),
                  ),
                  if (_sceneChangeNote(days) case final note?) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, AppSpace.md),
                      child: Text(
                        note,
                        style: AppTypography.body(
                          size: 13,
                          color: a.textSecondary,
                        ),
                      ),
                    ),
                  ],
                  _SourceRow(
                    glyph: CinematicGlyph.book,
                    title: l10n.planSourceReading,
                    body: followScenes
                        ? l10n.planSourceReadingScenes
                        : reading == null
                        ? l10n.planSourceReadingEmpty
                        : readingDays.isEmpty
                        ? l10n.planSourceReadingFrom(reading.name, reading.from)
                        : l10n.planEditorReadingPreview(
                            readingDays.first.reading!.label,
                            readingDays.last.reading!.label,
                          ),
                    note:
                        reading != null &&
                            readingDays.isNotEmpty &&
                            readingDays.length < days.length
                        ? l10n.planEditorReadingEnds(readingDays.last.n)
                        : null,
                    on: reading != null || followScenes,
                    action: reading == null && !followScenes
                        ? l10n.planSourcePick
                        : l10n.roomReadingChange,
                    onAction: _pickReading,
                    onRemove: followScenes
                        ? () => setState(() => _readingFromScenes = false)
                        : reading == null
                        ? null
                        : () => setState(() => _reading = null),
                    extra: reading == null
                        ? null
                        : _PerDay(
                            value: _perDay,
                            onChanged: (v) => setState(() {
                              // Em andamento: o ritmo novo segue do próximo
                              // capítulo ainda não lido, a partir de amanhã.
                              final kept = _keptDays;
                              if (live != null && kept > _readingFrom) {
                                final next = days
                                    .take(kept)
                                    .lastWhere(
                                      (d) => d.reading != null,
                                      orElse: () => days.first,
                                    )
                                    .reading;
                                if (next != null && _reading != null) {
                                  _reading = (
                                    abbrev: _reading!.abbrev,
                                    name: _reading!.name,
                                    from: next.to + 1,
                                  );
                                  _readingFrom = kept;
                                }
                              }
                              _perDay = v;
                            }),
                          ),
                  ),
                  _SourceRow(
                    glyph: CinematicGlyph.quote,
                    title: l10n.planEditorQuestion,
                    body: !_hasContent
                        ? l10n.planSourceQuestionNone
                        : _questionOn
                        ? l10n.planSourceQuestionBody
                        : l10n.planSourceQuestionOff,
                    on: _questionOn && _hasContent,
                    toggle: _hasContent
                        ? (v) => setState(() => _questionOn = v)
                        : null,
                    action: days.isEmpty
                        ? null
                        : l10n.planEditorShowDays(days.length),
                    actionIcon: false,
                    onAction: days.isEmpty ? null : _pickQuestions,
                  ),
                  const SizedBox(height: AppSpace.lg),

                  // ── Por quanto tempo ──
                  SectionLabel(l10n.planEditorHowLong),
                  const SizedBox(height: AppSpace.sm),
                  InsetPanel(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    borderColor: a.place.withValues(alpha: 0.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: CinematicIcon(
                                glyph: CinematicGlyph.calendar,
                                size: AppMetrics.iconMd,
                                accent: a.place,
                                framed: false,
                              ),
                            ),
                            const SizedBox(width: AppSpace.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.planEditorDuration,
                                    style: AppTypography.title(
                                      size: 15,
                                      color: a.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _season != null
                                        ? l10n.planEditorDurationSeason(
                                            _season!.title,
                                          )
                                        : _sceneDriven
                                        ? l10n.planEditorDurationTrail(
                                            _scene!.trail ?? _scene!.title,
                                          )
                                        : l10n.planEditorDurationBody,
                                    style: AppTypography.body(
                                      size: 13,
                                      color: a.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Cenas mandam na duração: sem escolher semanas.
                        if (!_sceneDriven) ...[
                          const SizedBox(height: AppSpace.lg),
                          Row(
                            children: [
                              for (final w in _weekOptions) ...[
                                if (w != _weekOptions.first)
                                  const SizedBox(width: 6),
                                Expanded(
                                  child: _Pill(
                                    label: l10n.planEditorWeeks(w),
                                    on: _weeks == w,
                                    dense: true,
                                    onTap: () {
                                      // Em curso: não encurta para antes de hoje.
                                      final end = _endForWeeks(w);
                                      if (live != null &&
                                          planYmd(end).compareTo(today) < 0) {
                                        return;
                                      }
                                      setState(() => _end = end);
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpace.md),
                        Row(
                          children: [
                            Expanded(
                              child: _DateTile(
                                label: l10n.planEditorStart,
                                value: planDateShort(
                                  context,
                                  days.isEmpty
                                      ? planYmd(_start)
                                      : days.first.date,
                                ),
                                // Só trava depois que o propósito começou.
                                onTap: live == null ? _pickStart : null,
                              ),
                            ),
                            const SizedBox(width: AppSpace.sm),
                            Expanded(
                              child: _DateTile(
                                label: l10n.planEditorEnd,
                                value: planDateShort(
                                  context,
                                  days.isEmpty ? planYmd(_end) : days.last.date,
                                ),
                                // Trava no último dia ou depois dele.
                                onTap:
                                    days.isNotEmpty &&
                                        days.last.date.compareTo(today) <= 0
                                    ? null
                                    : () => _pickEnd(
                                        days.isEmpty
                                            ? planYmd(_end)
                                            : days.last.date,
                                      ),
                              ),
                            ),
                          ],
                        ),
                        if (live == null && _season == null) ...[
                          const SizedBox(height: AppSpace.lg),
                          Text(
                            l10n.planEditorRestShort,
                            style: AppTypography.title(size: 14, color: a.text),
                          ),
                          const SizedBox(height: AppSpace.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (var w = 1; w <= 7; w++)
                                _WeekdayDot(
                                  // 2024-01-01 é segunda.
                                  letter: DateFormat.E(locale)
                                      .format(DateTime(2024, 1, w))
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  name: DateFormat.EEEE(
                                    locale,
                                  ).format(DateTime(2024, 1, w)),
                                  rest: _rest.contains(w),
                                  onTap: () => setState(() {
                                    _rest = {..._rest};
                                    if (!_rest.remove(w)) _rest.add(w);
                                    if (_rest.length >= 7) _rest.remove(w);
                                  }),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpace.sm),
                          Text(
                            l10n.planEditorRestHint,
                            textAlign: TextAlign.center,
                            style: AppTypography.body(
                              size: 12,
                              color: a.textFaint,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.lg),

                  const SizedBox(height: AppSpace.lg),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            if (!_hasContent) ...[
              Text(
                l10n.planEditorNeedContent,
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 13, color: a.textSecondary),
              ),
              const SizedBox(height: AppSpace.sm),
            ],
            CopperCta(
              label: _editing == null
                  ? l10n.planEditorSaveNew
                  : l10n.planEditorSave,
              expanded: true,
              onTap:
                  count == 0 ||
                      !_readingReady ||
                      !_hasContent ||
                      _loadingQuestions > 0
                  ? null
                  : _save,
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma fonte do dia (leitura, cena, pergunta): o que é, de onde vem e a
/// ação para trocar ou tirar.
class _SourceRow extends StatelessWidget {
  final CinematicGlyph glyph;
  final String title;
  final String body;
  final String? note;
  final bool on;
  final String? action;

  /// Ação que não troca nem escolhe (ex.: ver os dias) vai sem ícone.
  final bool actionIcon;
  final VoidCallback? onAction;
  final VoidCallback? onRemove;
  final ValueChanged<bool>? toggle;
  final Widget? extra;

  /// Pintura da trilha/estação (só na cena escolhida).
  final String? art;

  const _SourceRow({
    required this.glyph,
    required this.title,
    required this.body,
    required this.on,
    this.note,
    this.action,
    this.actionIcon = true,
    this.onAction,
    this.onRemove,
    this.toggle,
    this.extra,
    this.art,
  });

  bool get hasActions =>
      (action != null && onAction != null) || onRemove != null;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    // O card inteiro responde; botões, interruptor e "por dia" lá dentro
    // ganham o toque deles por estarem mais fundo.
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onAction == null
            ? null
            : () {
                ActHaptics.tap();
                onAction!();
              },
        child: InsetPanel(
          // As ações (Trocar · Tirar) já têm área de toque alta: menos
          // respiro embaixo para o card não ficar vazio no pé.
          padding: EdgeInsets.fromLTRB(14, 14, 14, hasActions ? 2 : 14),
          borderColor: on ? a.place.withValues(alpha: 0.6) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (art != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: AspectRatio(
                    aspectRatio: 2.35,
                    child: Image.asset(
                      art!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.md),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: CinematicIcon(
                      glyph: glyph,
                      size: AppMetrics.iconMd,
                      accent: on ? a.place : a.textFaint,
                      framed: false,
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.title(
                            size: 15,
                            color: on ? a.text : a.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: AppTypography.body(
                            size: 13,
                            color: a.textSecondary,
                          ),
                        ),
                        if (note != null)
                          Text(
                            note!,
                            style: AppTypography.body(
                              size: 12,
                              color: a.textFaint,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (toggle != null)
                    Switch.adaptive(value: on, onChanged: toggle),
                ],
              ),
              // Cada coisa na sua linha, na largura do card: ajuste (por dia)
              // e depois as ações centralizadas (Trocar · Tirar).
              if (extra != null) ...[
                const SizedBox(height: AppSpace.lg),
                extra!,
              ],
              if (hasActions) ...[
                SizedBox(height: extra != null ? AppSpace.sm : AppSpace.md),
                Padding(
                  padding: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (action != null && onAction != null)
                        TextCta(
                          label: action!,
                          leading: !actionIcon
                              ? null
                              : on
                              ? CinematicGlyph.refresh
                              : CinematicGlyph.forward,
                          onTap: onAction,
                        ),
                      if (onRemove != null) ...[
                        const SizedBox(width: AppSpace.sm),
                        TextCta(
                          label: context.l10n.planSourceRemove,
                          leading: CinematicGlyph.close,
                          color: a.textSecondary,
                          onTap: onRemove,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 1, 2 ou 3 capítulos por dia: três botões iguais, lado a lado.
class _PerDay extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _PerDay({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final n in const [1, 2, 3]) ...[
          if (n > 1) const SizedBox(width: 6),
          Expanded(
            child: _Pill(
              label: context.l10n.planPerDay(n),
              on: value == n,
              dense: true,
              onTap: () => onChanged(n),
            ),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool on;
  final bool dense;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.on,
    required this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Semantics(
      button: true,
      selected: on,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ActHaptics.tap();
          onTap();
        },
        child: AnimatedContainer(
          duration: AppMotion.quick,
          height: dense ? 30 : 40,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? a.place.withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: on ? a.place : a.cardBorder,
              width: on ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: AppTypography.body(
              size: dense ? 12 : 14,
              weight: FontWeight.w700,
              color: on ? a.text : a.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _DateTile({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return InsetPanel(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.body(
                        size: 12,
                        color: a.textSecondary,
                      ),
                    ),
                    Text(
                      value,
                      style: AppTypography.title(
                        size: 16,
                        color: onTap == null ? a.textSecondary : a.text,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                CinematicIcon(
                  glyph: CinematicGlyph.calendar,
                  size: 16,
                  accent: a.textSecondary,
                  framed: false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dia da semana: aceso = tem algo; apagado = descanso.
class _WeekdayDot extends StatelessWidget {
  final String letter;
  final String name;
  final bool rest;
  final VoidCallback onTap;

  const _WeekdayDot({
    required this.letter,
    required this.name,
    required this.rest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Semantics(
      button: true,
      toggled: !rest,
      label: name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ActHaptics.tap();
          onTap();
        },
        child: AnimatedContainer(
          duration: AppMotion.quick,
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rest ? Colors.transparent : a.place.withValues(alpha: 0.25),
            border: Border.all(color: rest ? a.cardBorder : a.place),
          ),
          child: Text(
            letter,
            style: AppTypography.body(
              size: 14,
              weight: FontWeight.w800,
              color: rest ? a.textFaint : a.text,
            ),
          ),
        ),
      ),
    );
  }
}

/// Lista dos dias da pergunta — sheet próprio, como trilha e capítulo.
class _QuestionsDaysSheet extends StatefulWidget {
  final List<PlanDay> Function() daysOf;
  final bool Function(PlanDay day) isLocked;
  final Future<void> Function(PlanDay day) onEdit;

  const _QuestionsDaysSheet({
    required this.daysOf,
    required this.isLocked,
    required this.onEdit,
  });

  @override
  State<_QuestionsDaysSheet> createState() => _QuestionsDaysSheetState();
}

class _QuestionsDaysSheetState extends State<_QuestionsDaysSheet> {
  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final days = widget.daysOf();
    final screen = MediaQuery.sizeOf(context).height;
    final top = MediaQuery.paddingOf(context).top;
    final height = (screen * 0.78).clamp(280.0, screen - top - 96).toDouble();

    return AppSheetPanel(
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              title: l10n.planEditorQuestion,
              subtitle: l10n.planSourceQuestionBody,
              cloud: false,
            ),
            const SizedBox(height: AppSpace.sm),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: AppSpace.lg),
                itemCount: days.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: a.cardBorder.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, i) {
                  final d = days[i];
                  return _DayRow(
                    day: d,
                    locked: widget.isLocked(d),
                    onTap: () async {
                      await widget.onEdit(d);
                      if (mounted) setState(() {});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final PlanDay day;
  final bool locked;
  final VoidCallback onTap;

  const _DayRow({required this.day, required this.locked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final what = [
      if (day.reading != null) day.reading!.label,
      if (day.scene != null) day.scene!.title,
    ].join(' · ');
    return InkWell(
      onTap: locked
          ? null
          : () {
              ActHaptics.tap();
              onTap();
            },
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.planDayDate(day.n, planDateShort(context, day.date)),
                    style: AppTypography.title(
                      size: 14,
                      color: locked ? a.textSecondary : a.text,
                    ),
                  ),
                  if (what.isNotEmpty)
                    Text(
                      what,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 12,
                        color: a.textSecondary,
                      ),
                    ),
                  if (what.isEmpty)
                    Text(
                      l10n.planDayEmpty,
                      style: AppTypography.body(size: 12, color: a.textFaint),
                    ),
                  // Rotulado: sem o "Pergunta:" a linha parecia um resumo
                  // do versículo.
                  if (day.hasQuestion)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        l10n.planDayQuestionLine(day.question!),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(size: 12, color: a.text),
                      ),
                    ),
                  if (day.hasNote)
                    Text(
                      l10n.planDayNoteLine(day.note!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(size: 12, color: a.place),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            if (locked)
              Text(
                l10n.planEditorDayOpen,
                style: AppTypography.body(size: 12, color: a.textFaint),
              )
            else
              CinematicIcon(
                glyph: CinematicGlyph.pencil,
                size: 14,
                accent: a.textSecondary,
                framed: false,
              ),
          ],
        ),
      ),
    );
  }
}

class _DayEditSheet extends StatefulWidget {
  final PlanDay day;
  final bool askQuestion;

  /// Perguntas prontas do dia (cena, texto, geral): um toque preenche.
  final List<({String label, String text})> suggestions;

  const _DayEditSheet({
    required this.day,
    required this.askQuestion,
    this.suggestions = const [],
  });

  @override
  State<_DayEditSheet> createState() => _DayEditSheetState();
}

class _DayEditSheetState extends State<_DayEditSheet> {
  late final _question = TextEditingController(text: widget.day.question);
  late final _note = TextEditingController(text: widget.day.note);
  String? _error;

  @override
  void dispose() {
    _question.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final q = _question.text.trim();
    final n = _note.text.trim();
    if (!ContentFilter.isAllowed(q) || !ContentFilter.isAllowed(n)) {
      setState(() => _error = context.l10n.contentTextNotAllowed);
      return;
    }
    // Pergunta igual à sugerida (não mexida) segue automática.
    final untouched = q == widget.day.question && !widget.day.customQuestion;
    Navigator.pop(context, (
      question: q.isEmpty || untouched ? null : q,
      note: n.isEmpty ? null : n,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final screen = MediaQuery.sizeOf(context).height;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final top = MediaQuery.paddingOf(context).top;
    final maxHeight = (screen - keyboard - top - 96).clamp(200.0, screen);
    return AppSheetPanel(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSheetHeader(
                title: l10n.planDayDate(
                  widget.day.n,
                  planDateShort(context, widget.day.date),
                ),
                cloud: false,
              ),
              const SizedBox(height: AppSpace.md),
              if (widget.askQuestion) ...[
                SectionLabel(l10n.planDayEditQuestion),
                const SizedBox(height: AppSpace.xs),
                TextField(
                  controller: _question,
                  maxLength: RoomPlan.maxQuestion,
                  minLines: 2,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTypography.body(size: 14, color: a.text),
                ),
                if (widget.suggestions.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    l10n.planSuggestTitle,
                    style: AppTypography.body(
                      size: 13,
                      weight: FontWeight.w700,
                      color: a.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  for (final sug in widget.suggestions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InsetPanel(
                        padding: EdgeInsets.zero,
                        borderColor: _question.text.trim() == sug.text
                            ? a.place
                            : null,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          onTap: () {
                            ActHaptics.tap();
                            setState(() {
                              _question.text = sug.text;
                              _question.selection = TextSelection.collapsed(
                                offset: sug.text.length,
                              );
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sug.label,
                                  style: AppTypography.body(
                                    size: 12,
                                    weight: FontWeight.w700,
                                    color: a.place,
                                  ),
                                ),
                                Text(
                                  sug.text,
                                  style: AppTypography.body(
                                    size: 13,
                                    color: a.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: AppSpace.sm),
              ],
              SectionLabel(l10n.planDayEditNote),
              const SizedBox(height: AppSpace.xs),
              TextField(
                controller: _note,
                maxLength: RoomPlan.maxNote,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: AppTypography.body(size: 14, color: a.text),
                decoration: InputDecoration(errorText: _error),
              ),
              const SizedBox(height: AppSpace.md),
              CopperCta(
                label: l10n.planEditorSave,
                expanded: true,
                onTap: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
