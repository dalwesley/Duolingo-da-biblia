import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/room_plan.dart';
import '../models/study_room.dart';
import '../services/bible_service.dart';
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

/// Cena de partida e a trilha dela.
typedef _SceneSource = ({String slug, String title, String? trail});

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

  bool _questionOn = true;
  bool _showDays = false;
  final Map<int, ({String? question, String? note})> _edits = {};

  RoomPlan? get _live {
    final c = widget.current;
    return c != null && c.phase() == PlanPhase.active ? c : null;
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
        _scene = (slug: s.missionSlug, title: s.title, trail: null);
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
      }
      final ss = g['ss'] as String?;
      if (ss != null) {
        _scenes = [
          for (final d in c.days)
            if (d.scene != null) d.scene!,
        ];
        _scene = (
          slug: ss,
          title: _scenes.isEmpty ? ss : _scenes.first.title,
          trail: g['st'] as String?,
        );
        _resolveScenes(ss);
      }
      _questionOn = g['q'] != false;
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
      await PlanQuestions.ensureScenes(list.map((s) => s.slug));
      if (!mounted || _scene?.slug != firstSlug) return;
      setState(() {
        _scenes = list;
        _scene = (
          slug: firstSlug,
          title: list.isEmpty ? _scene!.title : list.first.title,
          trail: t.localizedTitle,
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

  List<String> get _dates => RoomPlan.datesBetween(_start, _end, _rest);

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
    if (out.isEmpty && r != null) {
      for (var ch = r.from; ch <= r.to && out.isEmpty; ch++) {
        final slug = bank.sceneForChapter(r.bookName, ch);
        if (slug != null) addScene(slug);
      }
    }
    final ref = r?.label ?? s?.ref ?? s?.title;
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
      edits: {
        for (final e in _edits.entries)
          e.key: (
            question: _questionOn ? e.value.question : null,
            note: e.value.note,
          ),
      },
    );
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
    Navigator.pop(
      context,
      RoomPlan(
        id:
            _editing?.id ??
            DateTime.now().millisecondsSinceEpoch.toRadixString(36),
        title: title.length > RoomPlan.maxTitle
            ? title.substring(0, RoomPlan.maxTitle)
            : title,
        start: planYmd(_start),
        end: days.last.date,
        restDays: _rest,
        days: days,
        gen: {
          if (r != null) ...{
            'rb': r.abbrev,
            'rn': r.name,
            'rf': r.from,
            'rp': _perDay,
          },
          if (s != null) ...{'ss': s.slug, 'st': ?s.trail},
          'q': _questionOn,
        },
      ),
    );
  }

  Future<void> _pickReading() async {
    final first = _scenes.isEmpty ? null : _scenes.first;
    final r = _reading;
    final picked = await showRoomReadingPicker(
      context,
      startOnly: true,
      // "Mesmo texto da cena": a cena de partida escolhida aqui.
      study: first == null
          ? null
          : RoomStudy(
              missionSlug: first.slug,
              title: first.title,
              verseRef: first.ref,
              week: planYmd(_start),
            ),
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
    );
    if (study == null || !mounted) return;
    setState(() {
      _scene = (slug: study.missionSlug, title: study.title, trail: null);
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _start.isBefore(today) ? today : _start,
      firstDate: today,
      lastDate: today.add(const Duration(days: 120)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final weeks = _weeks == 0 ? 3 : _weeks;
      _start = picked;
      _end = _endForWeeks(weeks);
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
                  _SourceRow(
                    glyph: CinematicGlyph.path,
                    title: l10n.planSourceScene,
                    body: scene == null
                        ? l10n.planSourceSceneEmpty
                        : l10n.planSourceSceneFrom(
                            scene.trail ?? '',
                            scene.title,
                          ),
                    note: scene != null && days.isNotEmpty
                        ? l10n.planSourceSceneCount(sceneDays, days.length)
                        : null,
                    on: scene != null,
                    action: scene == null
                        ? l10n.planSourcePick
                        : l10n.roomReadingChange,
                    onAction: live == null ? _pickScene : null,
                    onRemove: scene == null || live != null
                        ? null
                        : () => setState(() {
                            _scene = null;
                            _scenes = const [];
                          }),
                  ),
                  _SourceRow(
                    glyph: CinematicGlyph.book,
                    title: l10n.planSourceReading,
                    body: reading == null
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
                    on: reading != null,
                    action: reading == null
                        ? l10n.planSourcePick
                        : l10n.roomReadingChange,
                    onAction: live == null ? _pickReading : null,
                    onRemove: reading == null || live != null
                        ? null
                        : () => setState(() => _reading = null),
                    extra: reading == null || live != null
                        ? null
                        : _PerDay(
                            value: _perDay,
                            onChanged: (v) => setState(() => _perDay = v),
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
                    // Os dias moram no card da pergunta: cada linha mostra a
                    // pergunta do dia e o lápis troca a pergunta ou o recado.
                    extra: days.isEmpty
                        ? null
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.sm,
                                ),
                                onTap: () =>
                                    setState(() => _showDays = !_showDays),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _showDays
                                              ? l10n.planEditorHideDays
                                              : l10n.planEditorShowDays(
                                                  days.length,
                                                ),
                                          style: AppTypography.title(
                                            size: 14,
                                            color: a.text,
                                          ),
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: _showDays ? 0.25 : 0,
                                        duration: AppMotion.quick,
                                        child: CinematicIcon(
                                          glyph: CinematicGlyph.chevron,
                                          size: 14,
                                          accent: a.textSecondary,
                                          framed: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_showDays)
                                for (final d in days)
                                  _DayRow(
                                    day: d,
                                    locked:
                                        live != null &&
                                        d.date.compareTo(today) <= 0,
                                    onTap: () => _editDay(d),
                                  ),
                            ],
                          ),
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
                                    l10n.planEditorDurationBody,
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
                        const SizedBox(height: AppSpace.md),
                        Row(
                          children: [
                            Expanded(
                              child: _DateTile(
                                label: l10n.planEditorStart,
                                value: planDateShort(context, planYmd(_start)),
                                onTap: live == null ? _pickStart : null,
                              ),
                            ),
                            const SizedBox(width: AppSpace.sm),
                            Expanded(
                              child: _DateTile(
                                label: l10n.planEditorEnd,
                                value: planDateShort(context, planYmd(_end)),
                              ),
                            ),
                          ],
                        ),
                        if (live == null) ...[
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
              onTap: count == 0 || !_readingReady || !_hasContent
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
  final VoidCallback? onAction;
  final VoidCallback? onRemove;
  final ValueChanged<bool>? toggle;
  final Widget? extra;

  const _SourceRow({
    required this.glyph,
    required this.title,
    required this.body,
    required this.on,
    this.note,
    this.action,
    this.onAction,
    this.onRemove,
    this.toggle,
    this.extra,
  });

  bool get hasActions =>
      (action != null && onAction != null) || onRemove != null;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: InsetPanel(
        // As ações (Trocar · Tirar) já têm área de toque alta: menos
        // respiro embaixo para o card não ficar vazio no pé.
        padding: EdgeInsets.fromLTRB(14, 14, 14, hasActions ? 2 : 14),
        borderColor: on ? a.place.withValues(alpha: 0.6) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            if (extra != null) ...[const SizedBox(height: AppSpace.lg), extra!],
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
                        leading: on
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
