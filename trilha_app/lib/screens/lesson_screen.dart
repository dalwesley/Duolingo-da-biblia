import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/mission_study.dart';
import '../l10n/app_language.dart';
import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/difficulty.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../services/analytics_service.dart';
import '../services/bible_service.dart';
import '../services/content_catalog_service.dart';
import '../services/corner_service.dart';
import '../services/progress_service.dart';
import '../services/session_composer.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/genesis_theme.dart';
import '../utils/palco_verse.dart';
import '../utils/trail_progress.dart';
import '../widgets/act_feel.dart';
import '../widgets/app_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/exercise_feedback_dialog.dart';
import '../widgets/exercise_panel.dart';
import '../widgets/lamps_bar.dart';
import '../widgets/brand_flip_card.dart';
import '../widgets/stage_plate.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/verse_fill_panel.dart';
import '../widgets/mission_listen_button.dart';
import '../screens/celebration_screen.dart';
import '../services/tts_service.dart';
import '../widgets/relic_panel.dart';
import '../screens/difficulty_picker_screen.dart';

/// Sessão única: entrada → atos → (micro) → insight → saída.
/// Estudo longo pré-quiz removido ([docs/SESSAO_TREINO.md]).
enum _Phase { intro, quiz, micro, insight }

class LessonScreen extends StatefulWidget {
  final String missionSlug;
  final bool practiceMode;
  final bool skipTrailLock;
  final Mission? missionOverride;
  final List<String>? questionIdsOverride;

  const LessonScreen({
    super.key,
    required this.missionSlug,
    this.practiceMode = false,
    this.skipTrailLock = false,
    this.missionOverride,
    this.questionIdsOverride,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  final _repo = TrailRepository();
  Mission? _baseMission;
  Mission? _mission;
  String? _trailSlug;
  String? _moduleTitle;
  String? _realmId;
  List<String> _pickedIds = [];
  List<Exercise> _exercises = [];
  String _closingInsight = '';
  bool _celebrationForced = false;
  bool _mistakeInSession = false;
  bool _reviewInserted = false;
  DifficultyMeta? _difficultyMeta;

  _Phase _phase = _Phase.intro;
  int _questionIndex = 0;
  String? _selected;
  bool? _isCorrect;
  int _combo = 0;

  /// Erros no ato atual: o 1º pede tentar de novo; o 2º oferece pular
  /// (a pergunta volta no fim da cena, sem revelar a resposta).
  int _wrongsHere = 0;

  /// O veredito atual oferece pular para o fim da cena.
  bool _skipNow = false;

  /// O veredito atual revela a resposta — só no erro da volta no fim.
  bool _revealNow = false;

  /// Atos que são a volta de uma pergunta pulada — não contam no placar.
  final Set<int> _requeuedSlots = {};

  DateTime? _actStartedAt;
  bool _showFeedback = false;
  bool _busy = false;
  int _lamps = ProgressService.maxLamps;
  bool _hintUsed = false;
  Set<String> _eliminated = {};
  bool _outOfLamps = false;

  /// Primeira tentativa de cada ato (true acertou, false errou) — pinta a
  /// barra de progresso segmentada.
  final Map<int, bool> _results = {};

  /// "Acertou!" em cena por um instante antes do próximo ato.
  final bool _insightOnConnect = false;

  late final AnimationController _impactFlash;
  bool _impactPositive = true;

  @override
  void initState() {
    super.initState();
    _impactFlash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _load();
  }

  @override
  void dispose() {
    _impactFlash.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _load() async {
    await ContentCatalogService.instance.ensureLoaded();
    if (!mounted) return;
    final progress = context.read<ProgressService>();

    Mission? mission = widget.missionOverride;
    String? trailSlug;
    String? moduleTitle;
    String? realmId;

    if (mission != null) {
      trailSlug = 'genesis-1-11';
      moduleTitle = 'A Criação';
      realmId = 'antigo-testamento';
    } else {
      mission = await _repo.getMissionBySlug(widget.missionSlug);
      trailSlug = await _repo.getTrailSlugForMission(widget.missionSlug);
      if (trailSlug != null) {
        final trail = await _repo.getTrailBySlug(trailSlug);
        if (trail != null) {
          realmId = trail.realmId;
          for (final mod in trail.modules) {
            if (mod.missions.any((m) => m.slug == widget.missionSlug)) {
              moduleTitle = mod.localizedTitle;
              break;
            }
          }
        }
      }
    }

    if (!mounted) return;
    if (mission == null) {
      Navigator.of(context).pop();
      return;
    }

    // Após seed, o pull completo de 8k pode demorar — baixa só a trilha (ou o banco emprestado).
    final bankTrail = (mission.bankTrailSlug ?? '').trim().isNotEmpty
        ? mission.bankTrailSlug
        : trailSlug;
    if (bankTrail != null && bankTrail.isNotEmpty) {
      await ContentCatalogService.instance.ensureTrailBank(bankTrail);
      if (!mounted) return;
    }

    // Deep link / rota direta: não deixa pular unlock de trilha ou passo.
    // Caminhada e Esquina ativa já autorizaram a cena.
    final cornerOpens =
        !widget.practiceMode &&
        context.read<CornerService>().opensMission(widget.missionSlug);
    if (!widget.practiceMode &&
        !widget.skipTrailLock &&
        !cornerOpens &&
        widget.missionOverride == null &&
        trailSlug != null) {
      final trails = await _repo.getTrails();
      final trail = trails.where((t) => t.slug == trailSlug).firstOrNull;
      if (trail != null) {
        final visibleCompleted = progress.completedMissionsForTrail(
          trailSlug: trail.slug,
          missionSlugs: trail.missionSlugs,
        );
        final unlockedTrail = TrailProgress.isTrailUnlocked(
          trail,
          trails,
          visibleCompleted,
          clearedTrailModes: progress.clearedTrailModes,
        );
        final unlockedMission = TrailProgress.isMissionUnlocked(
          widget.missionSlug,
          trail.missionSlugs,
          visibleCompleted,
        );
        final alreadyDone = visibleCompleted.contains(widget.missionSlug);
        if (!unlockedTrail || (!unlockedMission && !alreadyDone)) {
          if (!mounted) return;
          showAppToastFor(
            context,
            message: context.l10n.lessonLocked,
            glyph: CinematicGlyph.lock,
            tone: AppToastTone.warn,
          );
          Navigator.of(context).pop();
          return;
        }
      }
    }

    final usesBank = QuestionBank.instance.hasBankForTrail(bankTrail);

    if (usesBank && bankTrail != null) {
      if ((mission.bankTrailSlug ?? '').isEmpty) {
        if (!mounted) return;
        final ok = await DifficultyPickerScreen.ensureSelected(
          context,
          trailSlug: bankTrail,
        );
        if (!mounted) return;
        if (!ok) {
          Navigator.of(context).pop();
          return;
        }
      }
      final trailForMode = await _repo.getTrailBySlug(bankTrail);
      if (!mounted) return;
      await context.read<ProgressService>().advancePastClearedMode(
        bankTrail,
        missionSlugs: trailForMode?.missionSlugs ?? const [],
      );
    }

    if (!mounted) return;
    final freshProgress = context.read<ProgressService>();
    final plan = await SessionComposer.compose(
      mission: mission,
      missionSlug: widget.missionSlug,
      trailSlug: bankTrail ?? trailSlug,
      moduleTitle: moduleTitle,
      usesBank: usesBank,
      progress: freshProgress,
      practiceMode: widget.practiceMode,
      questionIdsOverride: widget.questionIdsOverride,
    );

    if (!mounted) return;

    if (plan.isEmpty) {
      showAppToastFor(
        context,
        message: context.l10n.lessonLoadError,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      Navigator.of(context).pop();
      return;
    }

    final hooks = await _resolveHooks(mission, acts: plan.acts);
    if (!mounted) return;
    AnalyticsService.instance.logLessonStart(
      missionSlug: widget.missionSlug,
      trailSlug: trailSlug,
      difficulty: plan.difficultyMeta?.difficulty.id,
    );

    setState(() {
      _baseMission = mission;
      _trailSlug = trailSlug;
      _moduleTitle = moduleTitle;
      _realmId = realmId;
      _pickedIds = plan.bankQuestionIds;
      _exercises = List<Exercise>.from(plan.acts);
      _closingInsight = plan.insight;
      _celebrationForced = false;
      _mistakeInSession = false;
      _reviewInserted = false;
      _difficultyMeta = plan.difficultyMeta;
      _lamps = ProgressService.lampsForMission(isBoss: mission!.isBoss);
      _phase = _Phase.intro;
      _mission = Mission(
        slug: mission.slug,
        title: mission.localizedTitle,
        subtitle: context.l10n.lessonDuration,
        intro: mission.localizedIntro,
        type: mission.type,
        stepsReward: _scaledSteps(
          mission.stepsReward,
          plan.difficultyMeta?.stepsMultiplier ?? 1,
        ),
        questions: mission.questions,
        exercises: plan.acts,
        objective: mission.localizedObjective,
        centralInsight: plan.insight.isNotEmpty ? plan.insight : null,
        hookRef: hooks.ref,
        hookVerse: hooks.verse,
        hookNote: hooks.note,
        echoQuestion: mission.localizedEchoQuestion,
        hookThread: hooks.thread,
        bankSection: mission.bankSection,
        bankTrailSlug: mission.bankTrailSlug,
      );
    });
    // Eco usa o título PT canônico (persistência), não o overlay.
    unawaited(freshProgress.clearEchoIfArrived(mission.title));
  }

  /// Entrada bíblica: missão → estudo → atos. Leitura na tradução escolhida.
  Future<({String? ref, String? verse, String? note, String? thread})>
  _resolveHooks(Mission mission, {List<Exercise> acts = const []}) async {
    final study = _studyFor(mission);
    var entrance = SessionComposer.resolveEntrance(
      mission: mission,
      studyRef: study?.passageRef,
      studyVerse: study?.passageText,
      studyContext: study?.localizedContext,
      acts: acts,
    );
    final ref = (entrance.ref ?? '').trim();
    var verse = (entrance.verse ?? '').trim();
    if (ref.isNotEmpty) {
      final full = await BibleService.instance.passageText(
        ref,
        translationId: BibleService.palcoTranslationId,
      );
      if (full != null && full.trim().isNotEmpty) {
        verse = SessionComposer.clipEntranceVerse(full.trim());
      }
    }
    if (verse.isNotEmpty) {
      verse = SessionComposer.clipEntranceVerse(verse);
    }
    return (
      ref: ref.isNotEmpty ? ref : null,
      verse: verse.isNotEmpty ? verse : null,
      note: entrance.note,
      thread: null,
    );
  }

  MissionStudy? _studyFor(Mission mission) {
    if (widget.practiceMode) return null;
    return MissionStudy.forSlug(widget.missionSlug) ??
        MissionStudy.forSlug(mission.resolvedBankSection);
  }

  int get _maxLamps =>
      ProgressService.lampsForMission(isBoss: _mission?.isBoss ?? false);

  int _scaledSteps(int base, double multiplier) => (base * multiplier).round();

  int get _itemCount => _exercises.length;

  int get _scoredItemCount => [
    for (var i = 0; i < _exercises.length; i++)
      if (!_exercises[i].type.isRevealOnly && !_requeuedSlots.contains(i)) i,
  ].length;

  /// Acertos de primeira — tentar de novo e a volta no fim não contam.
  int get _correctCount => _results.entries
      .where((e) => e.value && !_requeuedSlots.contains(e.key))
      .length;

  Exercise get _exercise => _exercises[_questionIndex];

  GenesisModuleTheme get _theme => GenesisModuleTheme.forModule(
    _moduleTitle ?? '',
    realm: TrailRealm.fromId(_realmId),
    trailSlug: _trailSlug,
  );

  Color get _sessionAccent {
    final d = _difficultyMeta?.difficulty;
    if (d != null) return DifficultyVisuals.accentFor(d);
    return _theme.pathActive;
  }

  ({String reference, String text})? get _board {
    final hookT = (_mission?.hookVerse ?? '').trim();
    final hookR = (_mission?.hookRef ?? '').trim();
    if (hookT.length >= 12) return (reference: hookR, text: hookT);
    return _microVerse();
  }

  /// Texto da cena por cima da pergunta — reler sem sair do fluxo.
  Future<void> _openPassage() async {
    final board = _board;
    if (board == null) return;
    unawaited(
      AnalyticsService.instance.logEvent('passage_open', {
        'mission_slug': widget.missionSlug,
        'index': _questionIndex,
        'after_error': _isCorrect == false ? 1 : 0,
      }),
    );
    await showAppSheet<void>(
      context,
      builder: (_) => _PassageSheet(
        reference: board.reference,
        text: board.text,
        accent: _sessionAccent,
      ),
    );
    TtsService.instance.stop();
  }

  Future<void> _select(String optionId) async {
    await _selectExercise(optionId);
  }

  Future<void> _selectExercise(String optionId) async {
    if (_selected != null || _phase != _Phase.quiz || _showFeedback || _busy) {
      return;
    }
    final ex = _exercise;
    if (!ex.type.isRevealOnly && _outOfLamps) return;
    if (_eliminated.contains(optionId)) return;
    _busy = true;

    if (ex.type.isRevealOnly) {
      SoundService.instance.playCorrect();
      setState(() {
        _selected = optionId;
        _isCorrect = true;
        _showFeedback = false;
      });
      _busy = false;
      _finishLesson();
      return;
    }

    final correct = ex.checkAnswer(optionId);
    final slot = _questionIndex;
    final requeued = _requeuedSlots.contains(slot);
    final firstTry = !_results.containsKey(slot);
    final attempt = _wrongsHere + 1;
    _results.putIfAbsent(slot, () => correct);
    var relit = false;
    if (correct) {
      SoundService.instance.playCorrect();
      _combo++;
      if (_combo >= 3) ActHaptics.success();
      // Cinco seguidas reacendem uma lâmpada.
      relit = _combo % 5 == 0 && !_outOfLamps && _lamps < _maxLamps;
    } else {
      SoundService.instance.playWrong();
      _combo = 0;
      _mistakeInSession = true;
      _wrongsHere++;
    }
    // A resposta só aparece quando a volta no fim também erra.
    final reveal = !correct && requeued;
    // V/F não tem segunda chance útil: o 1º erro já manda para o fim.
    final skip =
        !correct &&
        !requeued &&
        (_wrongsHere >= 2 || ex.type == ExerciseType.trueFalse);

    _impactPositive = correct;
    _impactFlash.forward(from: 0);
    if (!mounted) {
      _busy = false;
      return;
    }
    setState(() {
      _selected = optionId;
      _isCorrect = correct;
      _revealNow = reveal;
      _skipNow = skip;
      if (relit) _lamps = (_lamps + 1).clamp(0, _maxLamps);
      // Só o primeiro erro de cada pergunta apaga lâmpada.
      if (!correct && firstTry && !requeued) {
        _lamps = (_lamps - 1).clamp(0, _maxLamps);
        if (_lamps == 0) _outOfLamps = true;
      }
      _showFeedback = false;
    });

    final progress = context.read<ProgressService>();
    if (relit) {
      showAppToastFor(
        context,
        message: context.l10n.lessonLampRelit,
        glyph: CinematicGlyph.lamp,
      );
    }
    if (!correct && firstTry && !requeued && progress.takeLampsTeach()) {
      final left = _lamps;
      final msg = context.l10n.lessonLampsLeft(left <= 0 ? 0 : left);
      showAppToastFor(context, message: msg, glyph: CinematicGlyph.lamp);
    }
    final trackBankId =
        ex.id.isNotEmpty && (_pickedIds.contains(ex.id) || widget.practiceMode);
    if (trackBankId) {
      // Só o acerto de primeira tira a pergunta da revisão.
      if (!correct && firstTry && !requeued) {
        unawaited(progress.recordMistake(ex.id));
      } else if (firstTry && !requeued) {
        unawaited(progress.clearMistake(ex.id));
      }
    }
    final elapsed = _actStartedAt == null
        ? 0
        : DateTime.now().difference(_actStartedAt!).inMilliseconds;
    // Placar de acerto conta só a primeira tentativa da pergunta original.
    if (firstTry && !requeued) {
      unawaited(
        AnalyticsService.instance.logQuestionAnswered(
          missionSlug: widget.missionSlug,
          trailSlug: _trailSlug,
          questionId: ex.id.isNotEmpty
              ? ex.id
              : '${widget.missionSlug}_e$_questionIndex',
          questionIndex: _questionIndex,
          correct: correct,
          hintUsed: _hintUsed,
          difficulty: _difficultyMeta?.difficulty.id,
          isBoss: _mission?.isBoss ?? false,
        ),
      );
    }
    unawaited(
      AnalyticsService.instance.logExerciseComplete(
        missionSlug: widget.missionSlug,
        type: ex.type.wireId,
        skill: ex.skill,
        index: _questionIndex,
        correct: correct,
        attempt: attempt,
        requeued: requeued,
        revealed: reveal,
        elapsedMs: elapsed,
        difficulty: _difficultyMeta?.difficulty.id,
      ),
    );

    // Acerto e erro caem no mesmo painel: o acerto espera a faísca subir,
    // e mostra o porquê (feedbackCorrect) em vez de sumir sozinho.
    await Future.delayed(Duration(milliseconds: correct ? 520 : 420));
    _busy = false;
    if (mounted) setState(() => _showFeedback = true);
  }

  void _useHint() {
    if (_mission?.isBoss == true) return;
    if (_hintUsed || _selected != null || _showFeedback) return;
    // Toque já vibra no TextCta da dica.
    final ex = _exercise;
    final correctId = ex.resolvedCorrectAnswer.trim();
    final wrong = ex.effectiveOptions
        .where((o) => o.id != correctId && !_eliminated.contains(o.id))
        .toList();
    // Sem distrator eliminável — não marca dica como usada.
    if (wrong.isEmpty || correctId.isEmpty) return;
    // Garante que a resposta certa existe nas opções (evita eliminar o acerto).
    final hasCorrect = ex.effectiveOptions.any((o) => o.id == correctId);
    if (!hasCorrect) return;
    wrong.shuffle();
    setState(() {
      _hintUsed = true;
      _eliminated = {..._eliminated, wrong.first.id};
    });
  }

  MissionStudy? get _study => _mission == null ? null : _studyFor(_mission!);

  int get _answeredCount => _questionIndex + (_selected != null ? 1 : 0);

  void _goToCelebration({required bool forced}) {
    if (_mission == null) return;
    // Atos → (micro) → insight → saída. Insight é sempre o último bate.
    if (!forced &&
        _phase != _Phase.micro &&
        _phase != _Phase.insight &&
        !widget.practiceMode &&
        !_insightOnConnect &&
        _canOfferMicro()) {
      setState(() {
        _celebrationForced = forced;
        _showFeedback = false;
        _selected = null;
        _isCorrect = null;
        _phase = _Phase.micro;
      });
      return;
    }
    if (_closingInsight.trim().isNotEmpty &&
        _phase != _Phase.insight &&
        !_insightOnConnect) {
      setState(() {
        _celebrationForced = forced;
        _showFeedback = false;
        _selected = null;
        _isCorrect = null;
        _phase = _Phase.insight;
      });
      return;
    }
    _pushCelebration(forced: forced);
  }

  void _pushCelebration({required bool forced}) {
    if (_mission == null) return;
    final total = _scoredItemCount.clamp(1, 999);
    final progress = context.read<ProgressService>();
    if (!widget.practiceMode && _pickedIds.isNotEmpty) {
      progress.markQuestionsUsed(_pickedIds);
    }
    final isReplay =
        widget.practiceMode ||
        (_baseMission != null &&
            (progress.isSessionReplayMission(_baseMission!.slug) ||
                progress.isMissionCompleted(_baseMission!.slug)));
    final maxLamps = _maxLamps;
    final steps = ProgressService.computeLessonSteps(
      baseSteps: _mission!.stepsReward,
      correct: _correctCount,
      total: forced ? _answeredCount.clamp(1, total) : total,
      lampsLeft: _lamps,
      maxLamps: maxLamps,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CelebrationScreen(
          missionSlug: _mission!.slug,
          steps: steps,
          correct: _correctCount,
          total: forced ? _answeredCount.clamp(1, total) : total,
          trailSlug: _trailSlug ?? 'genesis-1-11',
          isBoss: _mission!.isBoss,
          isReplay: isReplay,
          perfect: !forced && _correctCount == total && _lamps == maxLamps,
          failed: _outOfLamps && !widget.practiceMode,
          todayInsight: _mission!.centralInsight,
        ),
      ),
    );
  }

  void _finishLesson({bool forced = false}) {
    // Atos → (micro) → insight → saída.
    _goToCelebration(forced: forced);
  }

  bool _canOfferMicro() => _microVerse() != null;

  /// Palco da missão — nunca um verso de outra trilha (ex.: Salmos no meio de Gênesis).
  ({String reference, String text})? _microVerse() {
    final study = _study;
    final studyText = study?.passageText.trim() ?? '';
    final studyRef = study?.passageRef.trim() ?? '';
    if (studyText.length >= 20) {
      return (
        reference: studyRef.isNotEmpty
            ? studyRef
            : context.l10n.lessonVerseFallback,
        text: studyText,
      );
    }

    final hookText = (_mission?.hookVerse ?? '').trim();
    final hookRef = (_mission?.hookRef ?? '').trim();
    if (hookText.length >= 20) {
      return (
        reference: hookRef.isNotEmpty
            ? hookRef
            : context.l10n.lessonVerseFallback,
        text: hookText,
      );
    }

    for (final ex in _exercises) {
      final t = (ex.passageText ?? '').trim();
      if (t.length >= 20) {
        final r = (ex.reference ?? '').trim();
        return (reference: r.isNotEmpty ? r : hookRef, text: t);
      }
    }
    return null;
  }

  Future<void> _completeMicro(bool correct) async {
    if (correct) {
      await context.read<ProgressService>().grantBonusSteps(2);
    }
    if (!mounted) return;
    // Micro antes do insight — insight fecha a sessão.
    if (_closingInsight.trim().isNotEmpty && !_insightOnConnect) {
      setState(() {
        _showFeedback = false;
        _selected = null;
        _isCorrect = null;
        _phase = _Phase.insight;
      });
      return;
    }
    _pushCelebration(forced: _celebrationForced || _outOfLamps);
  }

  void _logExerciseStart() {
    if (_exercises.isEmpty) return;
    _actStartedAt = DateTime.now();
    final ex = _exercise;
    AnalyticsService.instance.logExerciseStart(
      missionSlug: widget.missionSlug,
      type: ex.type.wireId,
      skill: ex.skill,
      index: _questionIndex,
    );
  }

  void _startQuiz() {
    TtsService.instance.stop();
    if (_exercises.isEmpty) {
      showAppToastFor(
        context,
        message: context.l10n.lessonLoadError,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    setState(() {
      _phase = _Phase.quiz;
    });
    _logExerciseStart();
  }

  /// [skip]: o aluno escolheu deixar a pergunta para o fim da cena.
  void _continue({bool skip = false}) {
    if (_mission == null) return;
    _impactFlash
      ..stop()
      ..value = 0;

    if (_outOfLamps) {
      _finishLesson(forced: true);
      return;
    }

    if (_isCorrect == false && !_exercise.type.isRevealOnly) {
      // Tentar de novo na hora; o versículo segue no palco.
      if (!_revealNow && !(skip && _skipNow)) {
        setState(() {
          _showFeedback = false;
          _selected = null;
          _isCorrect = null;
          _hintUsed = false;
          _eliminated = {};
        });
        return;
      }
      // Pular: a pergunta volta no fim da cena (uma vez só).
      if (skip && _skipNow) {
        final ex = _exercise;
        setState(() {
          _exercises = [..._exercises, ex];
          _requeuedSlots.add(_exercises.length - 1);
        });
        unawaited(
          AnalyticsService.instance.logEvent('exercise_skip', {
            'mission_slug': widget.missionSlug,
            'type': ex.type.wireId,
            'index': _questionIndex,
          }),
        );
      }
    }

    if (_questionIndex < _itemCount - 1) {
      final next = _questionIndex + 1;
      setState(() {
        _showFeedback = false;
        _questionIndex = next;
        _selected = null;
        _isCorrect = null;
        _hintUsed = false;
        _eliminated = {};
        _wrongsHere = 0;
        _skipNow = false;
        _revealNow = false;
      });
      _logExerciseStart();
    } else if (_mistakeInSession &&
        !_reviewInserted &&
        _requeuedSlots.isEmpty) {
      // A revisão extra só entra quando nenhuma pergunta já voltou no fim.
      unawaited(_insertReview());
    } else {
      _finishLesson();
    }
  }

  Future<void> _insertReview() async {
    if (_reviewInserted || _mission == null) return;
    _reviewInserted = true;
    final diffId =
        _difficultyMeta?.difficulty ??
        TrailDifficulty.fromId(
          context.read<ProgressService>().difficultyForTrail(_trailSlug ?? ''),
        ) ??
        TrailDifficulty.semente;
    final rev = SessionComposer.reviewFromBank(
      missionSlug: widget.missionSlug,
      difficulty: diffId,
      trailSlug: _trailSlug ?? 'genesis-1-11',
      usedInSession: _exercises.map((e) => e.id).toSet(),
      usedTypes: _exercises.map((e) => e.type).toSet(),
    );
    if (rev == null) {
      _reviewInserted = false;
      _finishLesson();
      return;
    }
    final hydrated = await PalcoVerse.hydrate(rev);
    if (!mounted) return;
    setState(() {
      _exercises = [..._exercises, hydrated];
      _showFeedback = false;
      _questionIndex = _exercises.length - 1;
      _selected = null;
      _isCorrect = null;
      _hintUsed = false;
      _eliminated = {};
      _wrongsHere = 0;
      _skipNow = false;
      _revealNow = false;
    });
    _logExerciseStart();
  }

  /// Sair no meio da missão perde o progresso de hoje — pergunta antes.
  bool get _guardExit => _phase != _Phase.intro;

  Future<void> _confirmExit() async {
    if (!_guardExit) {
      Navigator.pop(context);
      return;
    }
    ActHaptics.tap();
    final total = _itemCount.clamp(1, 999);
    final leave = await showAppSheet<bool>(
      context,
      builder: (context) =>
          _ExitSheet(act: (_questionIndex + 1).clamp(1, total), total: total),
    );
    if (leave != true || !mounted) return;
    unawaited(
      AnalyticsService.instance.logEvent('lesson_abandon', {
        'mission': widget.missionSlug,
        'index': _questionIndex,
        'phase': _phase.name,
      }),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.select(
      (ProgressService p) => p.settings.appearanceMode,
    );
    final appearance = AppearanceStyle.resolve(mode);

    if (_mission == null || _baseMission == null) {
      return Scaffold(
        backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
        body: ImmersiveBackground(
          appearance: appearance,
          child: const AppSpinner(),
        ),
      );
    }

    final mission = _mission!;
    final total = _itemCount.clamp(1, 999);
    final accent = _sessionAccent;

    return Appearance(
      mode: mode,
      style: appearance,
      child: PopScope(
        canPop: !_guardExit,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmExit();
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: DayPhaseHelper.scaffoldBackground(
              appearance.phase,
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: AmbientAtmosphere(phase: appearance.phase),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.38),
                          ],
                          stops: const [0, 0.4, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpace.screen,
                          AppSpace.sm,
                          AppSpace.screen,
                          0,
                        ),
                        child: Column(
                          children: [
                            TopBar(
                              inline: true,
                              immersive: true,
                              dark: true,
                              title: switch (_phase) {
                                _Phase.intro => mission.title,
                                _Phase.quiz =>
                                  _combo >= 2
                                      ? '${_questionIndex + 1}/$total · ×$_combo'
                                      : '${_questionIndex + 1}/$total',
                                _Phase.micro => context.l10n.lessonBonus,
                                _Phase.insight => context.l10n.commonToday,
                              },
                              subtitle: switch (_phase) {
                                _Phase.intro =>
                                  _difficultyMeta?.label ??
                                      (mission.isBoss
                                          ? context.l10n.lessonBoss
                                          : context.l10n.lessonPractice),
                                _Phase.quiz => _difficultyMeta?.label,
                                _Phase.micro =>
                                  context.l10n.lessonMicroSubtitle,
                                _Phase.insight =>
                                  context.l10n.lessonInsightSubtitle,
                              },
                              onBack: _confirmExit,
                              leadingGlyph: CinematicGlyphResolver.forMission(
                                mission.title,
                                isBoss: mission.isBoss,
                              ),
                              chromeAccent: accent,
                              trailing: _phase == _Phase.quiz
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_board != null)
                                            IconButton(
                                              tooltip:
                                                  context.l10n.lessonPassageTitle,
                                              onPressed: () {
                                                ActHaptics.tap();
                                                _openPassage();
                                              },
                                              visualDensity:
                                                  VisualDensity.compact,
                                              icon: CinematicIcon(
                                                glyph: CinematicGlyph.book,
                                                size: 20,
                                                accent: Colors.white.withValues(
                                                  alpha: 0.78,
                                                ),
                                                framed: false,
                                              ),
                                            ),
                                          LampsBar(
                                            current: _lamps,
                                            max: _maxLamps,
                                            accent: accent,
                                            compact: true,
                                          ),
                                        ],
                                      ),
                                    )
                                  : null,
                            ),
                            if (_phase == _Phase.quiz) ...[
                              const SizedBox(height: 10),
                              _ActProgress(
                                total: total,
                                index: _questionIndex,
                                results: _results,
                                accent: accent,
                              ),
                              const SizedBox(height: 4),
                            ] else
                              const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      Expanded(
                        child: switch (_phase) {
                          // Ato sai para a esquerda, o próximo entra pela direita.
                          // Tentar de novo não troca a chave: a pergunta fica e só o
                          // estado local reinicia (mantendo a ordem montada).
                          _Phase.quiz => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (current, previous) => Stack(
                              alignment: Alignment.topCenter,
                              children: [...previous, ?current],
                            ),
                            transitionBuilder: (child, animation) {
                              final incoming =
                                  child.key ==
                                  ValueKey(
                                    'act-${_exercise.id}-$_questionIndex',
                                  );
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(incoming ? 0.14 : -0.14, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: RepaintBoundary(
                              key: ValueKey(
                                'act-${_exercise.id}-$_questionIndex',
                              ),
                              child: ExercisePanel(
                                key: ValueKey(
                                  '${_exercise.id}-$_questionIndex',
                                ),
                                exercise: _exercise,
                                selected: _selected,
                                isCorrect: _isCorrect,
                                showFeedback: _showFeedback,
                                onSelect: _select,
                                accent: accent,
                                hintUsed: _hintUsed,
                                eliminatedIds: _eliminated,
                                onHint:
                                    mission.isBoss || !_exercise.supportsHint
                                    ? null
                                    : _useHint,
                                outOfLamps: _outOfLamps,
                                revealCorrect:
                                    _revealNow && _isCorrect == false,
                                index: _questionIndex,
                                total: total,
                                insightFallback: mission.centralInsight,
                                boardText: _board?.text,
                                boardRef: _board?.reference,
                              ),
                            ),
                          ),
                          _Phase.micro => () {
                            final v = _microVerse();
                            if (v == null) return const SizedBox.shrink();
                            final ref = v.reference;
                            final text = v.text;
                            return VerseFillPanel(
                              key: const ValueKey('micro'),
                              reference: ref,
                              verseText: text,
                              accent: accent,
                              onDone: _completeMicro,
                            );
                          }(),
                          _Phase.intro => _IntroPanel(
                            key: const ValueKey('intro'),
                            mission: mission,
                            itemCount: total,
                            accent: accent,
                            onStart: _startQuiz,
                          ),
                          _Phase.insight => _InsightPanel(
                            key: const ValueKey('insight'),
                            text: _closingInsight,
                            accent: accent,
                            onContinue: () {
                              _pushCelebration(forced: _celebrationForced);
                            },
                          ),
                        },
                      ),
                    ],
                  ),
                ),
                if (_phase == _Phase.intro)
                  const Positioned(
                    left: -140,
                    top: -140,
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: Opacity(opacity: 0.02, child: _ActWarmup()),
                      ),
                    ),
                  ),
                if (_phase == _Phase.quiz)
                  AnimatedBuilder(
                    animation: _impactFlash,
                    builder: (context, _) {
                      if (_impactFlash.value <= 0 || _impactFlash.value >= 1) {
                        return const SizedBox.shrink();
                      }
                      return Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: const Alignment(0, -0.2),
                                radius: 1.1,
                                colors: [
                                  (_impactPositive ? accent : AppColors.error)
                                      .withValues(
                                        alpha:
                                            (1 - _impactFlash.value) *
                                            (_impactPositive ? 0.28 : 0.22),
                                      ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                if (_phase == _Phase.quiz &&
                    _showFeedback &&
                    _selected != null &&
                    _isCorrect != null)
                  Positioned.fill(
                    child: ExerciseFeedbackDialog(
                      exercise: _exercise,
                      selected: _selected!,
                      isCorrect: _isCorrect!,
                      isLast:
                          _outOfLamps ||
                          (_isCorrect == true && _questionIndex >= total - 1),
                      accent: accent,
                      combo: _combo,
                      outOfLamps: _outOfLamps,
                      revealAnswer: _revealNow,
                      willRequeue: _skipNow,
                      onContinue: _continue,
                      onSkip: () => _continue(skip: true),
                      onReadPassage: _board == null ? null : _openPassage,
                      missionSlug: widget.missionSlug,
                      trailSlug: _trailSlug,
                      difficulty: _difficultyMeta?.difficulty.id,
                      practiceMode: widget.practiceMode,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra de atos: um segmento por pergunta — ouro se acertou de primeira,
/// vermelho discreto se errou, o atual pulsa em branco.
class _ActProgress extends StatelessWidget {
  final int total;
  final int index;
  final Map<int, bool> results;
  final Color accent;

  const _ActProgress({
    required this.total,
    required this.index,
    required this.results,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.lessonQuestionProgress(index + 1, total),
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                height: i == index ? 6 : 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  color: switch (results[i]) {
                    true => accent,
                    false => AppColors.error.withValues(alpha: 0.75),
                    null =>
                      i == index
                          ? Colors.white.withValues(alpha: 0.85)
                          : Colors.white.withValues(alpha: 0.16),
                  },
                  boxShadow: results[i] == true
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.45),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Texto da cena aberto por cima da pergunta.
class _PassageSheet extends StatelessWidget {
  final String reference;
  final String text;
  final Color accent;

  const _PassageSheet({
    required this.reference,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return AppSheetPanel(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.xl,
        AppSpace.md,
        AppSpace.xl,
        AppSpace.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(
            center: true,
            eyebrow: context.l10n.lessonPassageTitle,
            eyebrowColor: accent,
            title: reference.isNotEmpty
                ? reference
                : context.l10n.lessonPassageTitle,
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppTypography.verse(
                  size: 20,
                  height: 1.5,
                  color: a.text,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          MissionListenButton(verse: text, accent: accent),
          const SizedBox(height: 16),
          CopperCta(
            label: context.l10n.lessonBackToQuestion,
            trailing: null,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

/// Confirmação de saída no meio da missão.
class _ExitSheet extends StatelessWidget {
  final int act;
  final int total;

  const _ExitSheet({required this.act, required this.total});

  @override
  Widget build(BuildContext context) {
    return AppSheetPanel(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.xl,
        AppSpace.md,
        AppSpace.xl,
        AppSpace.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(
            center: true,
            leading: const CinematicIcon(
              glyph: CinematicGlyph.lamp,
              size: 44,
              accent: AppColors.accent,
            ),
            title: context.l10n.lessonExitTitle,
            subtitle: context.l10n.lessonExitBody(act, total),
          ),
          const SizedBox(height: 20),
          CopperCta(
            label: context.l10n.commonContinue,
            trailing: null,
            onTap: () => Navigator.pop(context, false),
          ),
          const SizedBox(height: 10),
          GhostCta(
            label: context.l10n.lessonExitAnyway,
            danger: true,
            expanded: true,
            onTap: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  final Mission mission;
  final int itemCount;
  final Color accent;
  final VoidCallback onStart;

  const _IntroPanel({
    super.key,
    required this.mission,
    required this.itemCount,
    required this.accent,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final verse = (mission.hookVerse ?? '').trim();
    final ref = (mission.hookRef ?? '').trim();
    final note = (mission.hookNote ?? '').trim();
    final fallbackIntro = mission.intro.trim();
    final stageText = verse.isNotEmpty
        ? verse
        : (note.isEmpty && fallbackIntro.isNotEmpty ? fallbackIntro : '');
    final a = Appearance.of(context);
    final pulse = mission.isBoss
        ? context.l10n.lessonIntroBossPulse(itemCount)
        : context.l10n.lessonIntroPulse(itemCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            pulse,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w700,
              color: a.textSecondary,
            ),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              note,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                height: 1.45,
                weight: FontWeight.w600,
                color: a.textSecondary,
              ),
            ),
          ],
          Expanded(
            child: stageText.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 10),
                    child: _WitnessPlate(
                      accent: accent,
                      reference: ref,
                      brandBack: true,
                      child: Text(
                        stageText,
                        textAlign: TextAlign.center,
                        style: AppTypography.verse(size: 24, height: 1.5),
                      ),
                    ),
                  ),
          ),
          MissionListenButton(
            verse: stageText,
            insight: mission.centralInsight,
            accent: accent,
          ),
          const SizedBox(height: 10),
          CopperCta(
            label: context.l10n.commonStart,
            onTap: onStart,
            trailing: null,
          ),
          const SizedBox(height: AppSpace.sm),
        ],
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  final String text;
  final Color accent;
  final VoidCallback onContinue;

  const _InsightPanel({
    super.key,
    required this.text,
    required this.accent,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelicChapter(
            title: context.l10n.commonToday,
            accent: accent,
            divided: false,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _WitnessPlate(
              accent: accent,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppTypography.title(
                  size: 20,
                  height: 1.32,
                  color: accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          CopperCta(
            label: context.l10n.commonContinue,
            onTap: onContinue,
            trailing: null,
          ),
          const SizedBox(height: AppSpace.sm),
        ],
      ),
    );
  }
}

/// Palco do versículo. Com [brandBack], um toque gira a carta e mostra a marca.
class _WitnessPlate extends StatelessWidget {
  final Color accent;
  final String? reference;
  final Widget child;
  final bool brandBack;

  const _WitnessPlate({
    required this.accent,
    required this.child,
    this.reference,
    this.brandBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final face = _face();
    if (!brandBack) return face;
    return BrandFlipCard(accent: accent, front: face);
  }

  Widget _face() {
    final ref = (reference ?? '').trim();
    return StagePlate(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ref.isNotEmpty) ...[
            Center(child: SectionLabel(ref, size: 13, color: accent)),
            const SizedBox(height: 14),
          ],
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(child: child),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinta fora da tela no intro para aquecer shaders do veredito.
class _ActWarmup extends StatelessWidget {
  const _ActWarmup();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CinematicIcon(
          glyph: CinematicGlyph.wrong,
          size: 78,
          accent: AppColors.error,
          glowing: true,
        ),
        const CinematicIcon(
          glyph: CinematicGlyph.check,
          size: 78,
          accent: AppColors.accent,
          glowing: true,
        ),
        const CinematicIcon(
          glyph: CinematicGlyph.refresh,
          size: 18,
          accent: AppColors.inkOnAccent,
          framed: false,
        ),
        Transform.translate(
          offset: const Offset(6, 0),
          child: const SizedBox(width: 48, height: 48),
        ),
        const SizedBox(
          width: 18,
          height: 18,
          // Determinado: aquece o shader do arco sem animar para sempre
          // (o indeterminado repintava a intro a cada frame).
          child: CircularProgressIndicator(
            value: 0.7,
            strokeWidth: 2,
            color: AppColors.inkOnAccent,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.nightElevated,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: AppTheme.cardShadow(elevated: true),
          ),
          child: const SizedBox(width: 120, height: 64),
        ),
      ],
    );
  }
}
