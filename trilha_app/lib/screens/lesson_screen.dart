import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../cinematic/cinematic_resolver.dart';
import '../data/mission_study.dart';
import '../data/pilot_trainings.dart';
import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/difficulty.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../models/question_report.dart';
import '../services/analytics_service.dart';
import '../services/content_catalog_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/genesis_theme.dart';
import '../utils/difficulty_trails.dart';
import '../utils/question_feedback.dart';
import '../utils/trail_progress.dart';
import '../widgets/cinematic_backdrop.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cinematic_lesson_panel.dart';
import '../widgets/exercise_panel.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/immersive_background.dart';
import '../widgets/question_report_sheet.dart';
import '../widgets/study_panel.dart';
import '../widgets/top_bar.dart';
import '../widgets/verse_fill_panel.dart';
import '../data/memory_verses.dart';
import '../screens/celebration_screen.dart';
import '../screens/bible_screen.dart';
import '../screens/difficulty_picker_screen.dart';

enum _Phase { intro, study, quiz, micro, reflection, insight }

class LessonScreen extends StatefulWidget {
  final String missionSlug;
  final bool practiceMode;
  final Mission? missionOverride;
  final List<String>? questionIdsOverride;

  const LessonScreen({
    super.key,
    required this.missionSlug,
    this.practiceMode = false,
    this.missionOverride,
    this.questionIdsOverride,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with TickerProviderStateMixin {
  final _repo = TrailRepository();
  Mission? _baseMission;
  Mission? _mission;
  String? _trailSlug;
  String? _moduleTitle;
  String? _realmId;
  List<String> _pickedIds = [];
  List<String?> _revealTags = [];
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
  int _correctCount = 0;
  bool _showFeedback = false;
  bool _busy = false;
  int _lamps = ProgressService.maxLamps;
  bool _hintUsed = false;
  Set<String> _eliminated = {};
  bool _outOfLamps = false;

  CreationWorldState _world = const CreationWorldState();
  CreationWorldState? _revealing;
  late final AnimationController _revealAnim;
  late final AnimationController _questionEnter;
  late final AnimationController _impactFlash;
  bool _impactPositive = true;

  @override
  void initState() {
    super.initState();
    _revealAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _questionEnter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _impactFlash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _load();
  }

  @override
  void dispose() {
    _revealAnim.dispose();
    _questionEnter.dispose();
    _impactFlash.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await ContentCatalogService.instance.ensureLoaded();
    if (widget.missionOverride != null) {
      final override = widget.missionOverride!;
      if (!mounted) return;
      final hasStudy =
          !widget.practiceMode &&
          MissionStudy.forSlug(widget.missionSlug) != null;
      setState(() {
        _baseMission = override;
        _trailSlug = 'genesis-1-11';
        _moduleTitle = 'A Criação';
        _realmId = 'antigo-testamento';
        _pickedIds = widget.questionIdsOverride ?? [];
        _revealTags = List.filled(override.questions.length, null);
        _exercises = List<Exercise>.from(
          override.hasExercises
              ? override.exercises.where((e) => e.hasPlayableContent)
              : PilotTrainings.forSlug(widget.missionSlug),
        );
        _mistakeInSession = false;
        _reviewInserted = false;
        _mission = override;
        _lamps = ProgressService.lampsForMission(isBoss: override.isBoss);
        if (hasStudy &&
            !(override.hasExercises ||
                PilotTrainings.forSlug(widget.missionSlug).isNotEmpty)) {
          _phase = _Phase.study;
        } else if (override.hasExercises ||
            PilotTrainings.forSlug(widget.missionSlug).isNotEmpty) {
          _phase = _Phase.intro;
        }
      });
      return;
    }

    final mission = await _repo.getMissionBySlug(widget.missionSlug);
    final trailSlug = await _repo.getTrailSlugForMission(widget.missionSlug);
    String? moduleTitle;
    String? realmId;
    if (trailSlug != null) {
      final trail = await _repo.getTrailBySlug(trailSlug);
      if (trail != null) {
        realmId = trail.realmId;
        for (final mod in trail.modules) {
          if (mod.missions.any((m) => m.slug == widget.missionSlug)) {
            moduleTitle = mod.title;
            break;
          }
        }
      }
    }

    if (!mounted) return;
    final progress = context.read<ProgressService>();

    // Deep link / rota direta: não deixa pular unlock de trilha ou passo.
    if (!widget.practiceMode &&
        widget.missionOverride == null &&
        mission != null &&
        trailSlug != null) {
      final trails = await _repo.getTrails();
      final trail = trails.where((t) => t.slug == trailSlug).firstOrNull;
      if (trail != null) {
        final unlockedTrail = TrailProgress.isTrailUnlocked(
          trail,
          trails,
          progress.completedMissions,
          clearedTrailModes: progress.clearedTrailModes,
        );
        final unlockedMission = TrailProgress.isMissionUnlocked(
          widget.missionSlug,
          trail.missionSlugs,
          progress.completedMissions,
        );
        final alreadyDone = progress.isMissionCompleted(widget.missionSlug);
        if (!unlockedTrail || (!unlockedMission && !alreadyDone)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Este passo ainda está bloqueado.',
                style: AppTypography.body(color: AppColors.textOnDark),
              ),
              backgroundColor: AppColors.nightElevated,
            ),
          );
          Navigator.of(context).pop();
          return;
        }
      }
    }

    if (!mounted) return;

    final usesBank =
        trailUsesDifficultyBank(trailSlug) &&
        QuestionBank.instance.hasBankForTrail(trailSlug);

    // Se abriu passo direto sem modo, garante um (auto Semente se for o único).
    if (usesBank &&
        trailSlug != null &&
        !progress.hasDifficultyForTrail(trailSlug)) {
      final ok = await DifficultyPickerScreen.ensureSelected(
        context,
        trailSlug: trailSlug,
      );
      if (!mounted) return;
      if (!ok) {
        Navigator.of(context).pop();
        return;
      }
    }

    var questions = mission?.questions ?? <Question>[];
    var ids = <String>[];
    var tags = <String?>[];
    DifficultyMeta? meta;

    final catalogExercises = (mission?.exercises ?? const <Exercise>[])
        .where((e) => e.hasPlayableContent)
        .toList(growable: false);
    final pilotExercises = PilotTrainings.forSlug(widget.missionSlug);
    // Piloto local vence catálogo remoto (evita Firestore stale durante o experimento).
    final resolvedExercises = pilotExercises.isNotEmpty
        ? pilotExercises
        : catalogExercises;
    final usesExercises = resolvedExercises.isNotEmpty && !widget.practiceMode;

    if (mission != null && usesBank && trailSlug != null && !usesExercises) {
      if (!mounted) return;
      final freshProgress = context.read<ProgressService>();
      final diffId =
          freshProgress.difficultyForTrail(trailSlug) ??
          TrailDifficulty.semente.id;
      final difficulty =
          TrailDifficulty.fromId(diffId) ?? TrailDifficulty.semente;
      meta = await QuestionBank.instance.metaFor(difficulty);
      final count = ProgressService.questionCountForMission(
        isBoss: mission.isBoss,
      );
      ids = await QuestionBank.instance.pickIdsForMission(
        difficulty: difficulty,
        moduleTitle: moduleTitle,
        section: mission.slug,
        count: count,
        usedIds: freshProgress.usedQuestionIds,
        trailSlug: trailSlug,
        isBoss: mission.isBoss,
      );
      final bankQs = <Question>[];
      for (final id in ids) {
        final bq = QuestionBank.instance.byId(id);
        if (bq != null) {
          bankQs.add(bq.toQuestion(shuffleOptions: true));
          tags.add(bq.reveal == 'null' ? null : bq.reveal);
        }
      }
      if (bankQs.isNotEmpty) questions = bankQs;
    } else if (usesExercises && usesBank && trailSlug != null) {
      // Ainda resolve meta de dificuldade para XP/label, sem puxar banco.
      if (!mounted) return;
      final freshProgress = context.read<ProgressService>();
      final diffId =
          freshProgress.difficultyForTrail(trailSlug) ??
          TrailDifficulty.caminhada.id;
      final difficulty =
          TrailDifficulty.fromId(diffId) ?? TrailDifficulty.caminhada;
      meta = await QuestionBank.instance.metaFor(difficulty);
    }

    if (!mounted) return;
    final hasStudy =
        !widget.practiceMode &&
        mission != null &&
        MissionStudy.forSlug(widget.missionSlug) != null;
    AnalyticsService.instance.logLessonStart(
      missionSlug: widget.missionSlug,
      trailSlug: trailSlug,
      difficulty: meta?.difficulty.id,
    );
    setState(() {
      _baseMission = mission;
      _trailSlug = trailSlug;
      _moduleTitle = moduleTitle;
      _realmId = realmId;
      _pickedIds = ids;
      _revealTags = tags;
      _exercises = usesExercises
          ? resolvedExercises
                .where((e) => e.type != ExerciseType.insight)
                .toList()
          : <Exercise>[];
      _closingInsight =
          resolvedExercises
              .where((e) => e.type == ExerciseType.insight)
              .map((e) => e.prompt.trim())
              .where((s) => s.isNotEmpty)
              .firstOrNull ??
          mission?.centralInsight ??
          (usesExercises && pilotExercises.isNotEmpty
              ? PilotTrainings.insightText
              : '');
      _celebrationForced = false;
      _mistakeInSession = false;
      _reviewInserted = false;
      _difficultyMeta = meta;
      _lamps = ProgressService.lampsForMission(
        isBoss: mission?.isBoss ?? false,
      );
      // Com estudo legado: preparo antes do quiz.
      // Com motor v2: não spoilar — o texto entra nos exercícios.
      if (hasStudy) _phase = _Phase.study;
      if (usesExercises) _phase = _Phase.intro;
      if (mission != null) {
        final insight =
            mission.centralInsight ??
            (usesExercises && pilotExercises.isNotEmpty
                ? PilotTrainings.insightText
                : null);
        final usePilotHook = usesExercises && pilotExercises.isNotEmpty;
        _mission = Mission(
          slug: mission.slug,
          title: mission.title,
          subtitle: usesExercises ? '~3 min' : mission.subtitle,
          intro: usePilotHook ? PilotTrainings.hookNote : mission.intro,
          type: mission.type,
          stepsReward: _scaledSteps(
            mission.stepsReward,
            meta?.stepsMultiplier ?? 1,
          ),
          questions: questions,
          exercises: usesExercises ? resolvedExercises : mission.exercises,
          objective: mission.objective,
          centralInsight: insight,
          hookRef: usePilotHook ? PilotTrainings.hookRef : mission.hookRef,
          hookVerse: usePilotHook
              ? PilotTrainings.hookVerse
              : mission.hookVerse,
          hookNote: usePilotHook ? PilotTrainings.hookNote : mission.hookNote,
          hookThread: usePilotHook
              ? PilotTrainings.hookThread
              : mission.hookThread,
        );
      }
    });
  }

  int get _maxLamps =>
      ProgressService.lampsForMission(isBoss: _mission?.isBoss ?? false);

  int _scaledSteps(int base, double multiplier) => (base * multiplier).round();

  Question get _question => _mission!.questions[_questionIndex];

  bool get _usesExercises => _exercises.isNotEmpty;

  int get _itemCount =>
      _usesExercises ? _exercises.length : (_mission?.questions.length ?? 0);

  int get _scoredItemCount {
    if (!_usesExercises) return _mission?.questions.length ?? 0;
    return _exercises.where((e) => !e.type.isRevealOnly).length;
  }

  Exercise get _exercise => _exercises[_questionIndex];

  bool get _cinematic =>
      !_usesExercises &&
      CinematicResolver.isCinematicMission(_trailSlug, _moduleTitle);

  GenesisModuleTheme get _theme => GenesisModuleTheme.forModule(
    _moduleTitle ?? '',
    realm: TrailRealm.fromId(_realmId),
    trailSlug: _trailSlug,
  );

  String get _correctOptionText {
    if (_usesExercises) {
      final ex = _exercise;
      final id = ex.resolvedCorrectAnswer;
      for (final o in ex.effectiveOptions) {
        if (o.id == id) return o.text;
      }
      return id;
    }
    final q = _question;
    return q.options.firstWhere((o) => o.id == q.correctOptionId).text;
  }

  String? get _currentRevealTag =>
      _questionIndex < _revealTags.length ? _revealTags[_questionIndex] : null;

  CinematicBeat get _beat => CinematicResolver.forQuestion(
    missionSlug: widget.missionSlug,
    questionIndex: _questionIndex,
    correctOptionText: _correctOptionText,
    questionText: _question.question,
    revealTag: _currentRevealTag,
    moduleTitle: _moduleTitle,
  );

  CreationWorldState get _displayWorld {
    if (!_cinematic) return _world;
    return _world.mergeMax(_beat.ambient);
  }

  void _applyAmbientForQuestion() {
    if (!_cinematic) return;
    _world = _world.mergeMax(_beat.ambient);
  }

  Future<void> _select(String optionId) async {
    if (_usesExercises) {
      await _selectExercise(optionId);
      return;
    }
    if (_selected != null ||
        _phase != _Phase.quiz ||
        _showFeedback ||
        _busy ||
        _outOfLamps) {
      return;
    }
    if (_eliminated.contains(optionId)) return;
    _busy = true;
    final correct = optionId == _question.correctOptionId;
    final questionId = _questionIndex < _pickedIds.length
        ? _pickedIds[_questionIndex]
        : '${widget.missionSlug}_q$_questionIndex';
    AnalyticsService.instance.logQuestionAnswered(
      missionSlug: widget.missionSlug,
      trailSlug: _trailSlug,
      questionId: questionId,
      questionIndex: _questionIndex,
      correct: correct,
      hintUsed: _hintUsed,
      difficulty: _difficultyMeta?.difficulty.id,
      isBoss: _mission?.isBoss ?? false,
    );
    if (correct) {
      SoundService.instance.playCorrect();
      HapticFeedback.lightImpact();
      if (_questionIndex < _pickedIds.length) {
        await context.read<ProgressService>().clearMistake(
          _pickedIds[_questionIndex],
        );
      }
    } else {
      SoundService.instance.playWrong();
      HapticFeedback.mediumImpact();
      if (_questionIndex < _pickedIds.length) {
        await context.read<ProgressService>().recordMistake(
          _pickedIds[_questionIndex],
        );
      }
    }

    final shouldReveal = correct && _cinematic && _beat.revealOnCorrect != null;
    _impactPositive = correct;
    _impactFlash.forward(from: 0);
    setState(() {
      _selected = optionId;
      _isCorrect = correct;
      if (correct) {
        _correctCount++;
      } else {
        _lamps = (_lamps - 1).clamp(0, _maxLamps);
        if (_lamps == 0) _outOfLamps = true;
      }
      // Feedback sheet só após o beat visual
      _showFeedback = false;
    });

    if (shouldReveal) {
      _revealing = _beat.revealOnCorrect;
      Future.delayed(const Duration(milliseconds: 720), () {
        if (mounted && !_showFeedback) setState(() => _showFeedback = true);
      });
      await _revealAnim.forward(from: 0);
      if (mounted && !_showFeedback) setState(() => _showFeedback = true);
    } else {
      await Future.delayed(Duration(milliseconds: correct ? 520 : 480));
      if (mounted) setState(() => _showFeedback = true);
    }
    _busy = false;
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
      HapticFeedback.lightImpact();
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
    );
    if (correct) {
      SoundService.instance.playCorrect();
      HapticFeedback.lightImpact();
    } else {
      SoundService.instance.playWrong();
      HapticFeedback.mediumImpact();
      _mistakeInSession = true;
    }

    _impactPositive = correct;
    _impactFlash.forward(from: 0);
    setState(() {
      _selected = optionId;
      _isCorrect = correct;
      if (correct) {
        _correctCount++;
      } else {
        _lamps = (_lamps - 1).clamp(0, _maxLamps);
        if (_lamps == 0) _outOfLamps = true;
      }
      _showFeedback = false;
    });

    await Future.delayed(Duration(milliseconds: correct ? 280 : 320));
    if (mounted) setState(() => _showFeedback = true);
    _busy = false;
  }

  void _useHint() {
    if (_mission?.isBoss == true) return;
    if (_hintUsed || _selected != null || _showFeedback) return;
    HapticFeedback.selectionClick();
    if (_usesExercises) {
      final ex = _exercise;
      final wrong = ex.effectiveOptions
          .where((o) => o.id != ex.resolvedCorrectAnswer)
          .toList();
      if (wrong.isEmpty) return;
      wrong.shuffle();
      setState(() {
        _hintUsed = true;
        _eliminated = {wrong.first.id};
      });
      return;
    }
    final wrong = _question.options
        .where((o) => o.id != _question.correctOptionId)
        .toList();
    if (wrong.isEmpty) return;
    wrong.shuffle();
    setState(() {
      _hintUsed = true;
      _eliminated = {wrong.first.id};
    });
  }

  MissionStudy? get _study =>
      widget.practiceMode ? null : MissionStudy.forSlug(widget.missionSlug);

  bool get _hasStudy => _study != null;

  int get _answeredCount => _questionIndex + (_selected != null ? 1 : 0);

  void _goToCelebration({required bool forced}) {
    if (_mission == null) return;
    if (_closingInsight.trim().isNotEmpty && _phase != _Phase.insight) {
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
    final total = (_usesExercises ? _scoredItemCount : _itemCount).clamp(
      1,
      999,
    );
    final progress = context.read<ProgressService>();
    if (!widget.practiceMode && _pickedIds.isNotEmpty) {
      progress.markQuestionsUsed(_pickedIds);
    }
    final isReplay =
        widget.practiceMode ||
        (_baseMission != null &&
            progress.isMissionCompleted(_baseMission!.slug));
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
        ),
      ),
    );
  }

  void _finishLesson({bool forced = false}) {
    // Micro-modo de memória antes da reflexão / celebração (não em force fail).
    if (!forced && !widget.practiceMode && _canOfferMicro()) {
      setState(() {
        _showFeedback = false;
        _selected = null;
        _isCorrect = null;
        _phase = _Phase.micro;
      });
      return;
    }
    _afterMicro(forced: forced);
  }

  bool _canOfferMicro() {
    final study = _study;
    if (study != null && study.passageText.trim().length >= 20) return true;
    return MemoryVerseCatalog.curated.isNotEmpty;
  }

  ({String reference, String text}) _microVerse() {
    final study = _study;
    if (study != null && study.passageText.trim().length >= 20) {
      return (reference: study.passageRef, text: study.passageText.trim());
    }
    final v = MemoryVerseCatalog.curated.first;
    return (reference: v.reference, text: v.text);
  }

  Future<void> _completeMicro(bool correct) async {
    if (correct) {
      await context.read<ProgressService>().grantBonusSteps(2);
    }
    if (!mounted) return;
    _afterMicro(forced: _outOfLamps);
  }

  void _afterMicro({bool forced = false}) {
    if (_hasStudy && !widget.practiceMode) {
      setState(() {
        _showFeedback = false;
        _selected = null;
        _isCorrect = null;
        _phase = _Phase.reflection;
      });
      return;
    }
    _goToCelebration(forced: forced);
  }

  Future<void> _completeReflection(String text) async {
    final progress = context.read<ProgressService>();
    await progress.saveReflection(widget.missionSlug, text);
    await progress.grantBonusSteps(2);
    if (!mounted) return;
    _goToCelebration(forced: _outOfLamps);
  }

  void _continue() {
    if (_mission == null) return;

    if (_revealing != null) {
      _world = _world.mergeMax(_revealing!);
      _revealing = null;
      _revealAnim.reset();
    }

    if (_outOfLamps) {
      _finishLesson(forced: true);
      return;
    }

    // Erro → tenta de novo (exceto insight).
    if (_usesExercises && _isCorrect == false && !_exercise.type.isRevealOnly) {
      setState(() {
        _showFeedback = false;
        _selected = null;
        _isCorrect = null;
        _hintUsed = false;
        _eliminated = {};
      });
      _questionEnter.forward(from: 0);
      return;
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
      });
      _questionEnter.forward(from: 0);
      _applyAmbientForQuestion();
    } else if (_usesExercises && _mistakeInSession && !_reviewInserted) {
      final rev = PilotTrainings.reviewForSlug(widget.missionSlug);
      if (rev != null) {
        setState(() {
          _exercises = [..._exercises, rev];
          _reviewInserted = true;
          _showFeedback = false;
          _questionIndex = _exercises.length - 1;
          _selected = null;
          _isCorrect = null;
          _hintUsed = false;
          _eliminated = {};
        });
        _questionEnter.forward(from: 0);
        return;
      }
      _finishLesson();
    } else {
      _finishLesson();
    }
  }

  void _startStudyOrQuiz() {
    if (_usesExercises) {
      _startQuiz();
      return;
    }
    if (_hasStudy) {
      setState(() => _phase = _Phase.study);
      return;
    }
    _startQuiz();
  }

  void _startQuiz() {
    setState(() {
      _phase = _Phase.quiz;
      if (_cinematic) _world = const CreationWorldState(voidDepth: 1);
    });
    _questionEnter.forward(from: 0);
    _applyAmbientForQuestion();
  }

  @override
  Widget build(BuildContext context) {
    final progressSvc = context.watch<ProgressService>();
    final mode = progressSvc.settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

    if (_mission == null || _baseMission == null) {
      return Scaffold(
        backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
        body: ImmersiveBackground(
          appearance: appearance,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      );
    }

    final mission = _mission!;
    final total = _itemCount.clamp(1, 999);
    final accent = _theme.pathActive;
    final study = _study;
    final priorReflection = progressSvc.reflectionFor(widget.missionSlug);

    return Appearance(
      mode: mode,
      style: appearance,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Sempre o céu da aparência (Manhã/Tarde/Noite) — igual trilha/home.
              Positioned.fill(
                child: AmbientAtmosphere(
                  phase: appearance.phase,
                  accent: accent,
                  glow: _theme.pathActive,
                ),
              ),
              // Missões cinematográficas: véu sutil da cena, sem apagar o tema.
              if (_cinematic)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _revealAnim,
                      builder: (context, _) => Opacity(
                        opacity:
                            (0.18 +
                                    _displayWorld.voidDepth * 0.12 +
                                    _displayWorld.light * 0.08)
                                .clamp(0.12, 0.38),
                        child: CinematicBackdrop(
                          world: _displayWorld,
                          revealing: _revealing,
                          revealProgress: _revealAnim.value,
                        ),
                      ),
                    ),
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
                              _Phase.study => mission.title,
                              _Phase.quiz =>
                                _usesExercises
                                    ? '${_questionIndex + 1}/$total'
                                    : (_difficultyMeta != null
                                          ? 'Pergunta ${_questionIndex + 1}/$total'
                                          : 'Pergunta ${_questionIndex + 1} de $total'),
                              _Phase.micro => 'Bônus',
                              _Phase.reflection => 'Anotar',
                              _Phase.insight => 'Hoje',
                            },
                            subtitle: switch (_phase) {
                              _Phase.intro =>
                                _difficultyMeta?.label ??
                                    (mission.isBoss ? 'Desafio' : 'Lição'),
                              _Phase.study =>
                                _difficultyMeta?.label ?? 'Estudo',
                              _Phase.quiz =>
                                _difficultyMeta?.label ??
                                    (_usesExercises
                                        ? _exercise.type.labelPt
                                        : mission.title),
                              _Phase.micro => 'Complete o verso',
                              _Phase.reflection => mission.title,
                              _Phase.insight => 'O que ficou',
                            },
                            onBack: () => Navigator.pop(context),
                            leadingGlyph: CinematicGlyphResolver.forMission(
                              mission.title,
                              isBoss: mission.isBoss,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    Expanded(
                      child: switch (_phase) {
                        _Phase.quiz when _usesExercises => ExercisePanel(
                          key: ValueKey('ex-$_questionIndex-${_exercise.id}'),
                          exercise: _exercise,
                          selected: _selected,
                          isCorrect: _isCorrect,
                          showFeedback: _showFeedback,
                          onSelect: _select,
                          accent: accent,
                          hintUsed: _hintUsed,
                          eliminatedIds: _eliminated,
                          onHint: mission.isBoss || !_exercise.supportsHint
                              ? null
                              : _useHint,
                          outOfLamps: _outOfLamps,
                          lamps: _lamps,
                          index: _questionIndex,
                          total: total,
                          insightFallback:
                              mission.centralInsight ??
                              PilotTrainings.insightText,
                        ),
                        _Phase.quiz => CinematicLessonPanel(
                          key: ValueKey(
                            'q-$_questionIndex-${_pickedIds.length}',
                          ),
                          narrative: _beat.narrative,
                          question: _question,
                          selected: _selected,
                          isCorrect: _isCorrect,
                          showFeedback: _showFeedback,
                          onSelect: _select,
                          accent: accent,
                          encouragement: null,
                          hintUsed: _hintUsed,
                          eliminatedIds: _eliminated,
                          onHint: mission.isBoss ? null : _useHint,
                          outOfLamps: _outOfLamps,
                          lamps: _lamps,
                          verseSnippet: () {
                            final v = MissionStudy.verseText(
                              _question.verseRef,
                            );
                            if (v == null) return null;
                            return v.length > 72 ? '${v.substring(0, 70)}…' : v;
                          }(),
                        ),
                        _Phase.study when study != null =>
                          SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: StudyPanel(
                              key: const ValueKey('study'),
                              study: study,
                              accent: accent,
                              priorReflection: priorReflection,
                              missionIntro: mission.intro,
                              onContinue: _startQuiz,
                            ),
                          ),
                        _Phase.reflection when study != null => ReflectionPanel(
                          key: const ValueKey('reflection'),
                          study: study,
                          accent: accent,
                          correct: _correctCount,
                          total: total,
                          onFinish: _completeReflection,
                          onSkip: () => _goToCelebration(forced: _outOfLamps),
                        ),
                        _Phase.micro => () {
                          final v = _microVerse();
                          return VerseFillPanel(
                            key: const ValueKey('micro'),
                            reference: v.reference,
                            verseText: v.text,
                            accent: accent,
                            onDone: _completeMicro,
                          );
                        }(),
                        _Phase.intro => _IntroPanel(
                          key: const ValueKey('intro'),
                          mission: mission,
                          theme: _theme,
                          hasStudy: _hasStudy,
                          itemCount: total,
                          usesExercises: _usesExercises,
                          onStart: _startStudyOrQuiz,
                        ),
                        _Phase.insight => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.screen,
                          ),
                          child: Column(
                            children: [
                              const Spacer(flex: 2),
                              CinematicIcon(
                                glyph: CinematicGlyph.spark,
                                size: 36,
                                accent: accent,
                                framed: false,
                              ),
                              const SizedBox(height: AppSpace.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: accent.withValues(alpha: 0.4),
                                      height: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'HOJE',
                                      style: AppTypography.label(
                                        size: 12,
                                        letterSpacing: 2.2,
                                        color: accent,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: accent.withValues(alpha: 0.4),
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpace.lg),
                              Text(
                                _closingInsight,
                                textAlign: TextAlign.center,
                                style: AppTypography.display(
                                  size: 26,
                                  height: 1.32,
                                ),
                              ),
                              const Spacer(flex: 3),
                              CopperCta(
                                label: 'Seguir',
                                onTap: () => _pushCelebration(
                                  forced: _celebrationForced,
                                ),
                              ),
                              const SizedBox(height: AppSpace.sm),
                            ],
                          ),
                        ),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ],
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
              if (_showFeedback && _selected != null && _isCorrect != null)
                _usesExercises
                    ? _ExerciseFeedbackOverlay(
                        exercise: _exercise,
                        selected: _selected!,
                        isCorrect: _isCorrect!,
                        isLast:
                            _outOfLamps ||
                            (_isCorrect == true && _questionIndex >= total - 1),
                        accent: accent,
                        outOfLamps: _outOfLamps,
                        onContinue: _continue,
                      )
                    : _FeedbackOverlay(
                        question: _question,
                        questionId: _questionIndex < _pickedIds.length
                            ? _pickedIds[_questionIndex]
                            : '${widget.missionSlug}_q$_questionIndex',
                        selected: _selected!,
                        isCorrect: _isCorrect!,
                        isLast: _outOfLamps || _questionIndex >= total - 1,
                        accent: accent,
                        outOfLamps: _outOfLamps,
                        verseText: MissionStudy.verseText(_question.verseRef),
                        missionSlug: widget.missionSlug,
                        trailSlug: _trailSlug,
                        difficulty: _difficultyMeta?.difficulty.id,
                        practiceMode: widget.practiceMode,
                        onContinue: _continue,
                      ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  final Mission mission;
  final GenesisModuleTheme theme;
  final bool hasStudy;
  final int itemCount;
  final bool usesExercises;
  final VoidCallback onStart;

  const _IntroPanel({
    super.key,
    required this.mission,
    required this.theme,
    required this.hasStudy,
    required this.itemCount,
    required this.usesExercises,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final verse = (mission.hookVerse ?? '').trim();
    final ref = (mission.hookRef ?? '').trim();
    final note = (mission.hookNote ?? '').trim();
    final thread = (mission.hookThread ?? '').trim();
    final fallbackIntro = mission.intro.trim();
    final bibleFirst = verse.isNotEmpty || note.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: Column(
        children: [
          const Spacer(flex: 1),
          CinematicIcon.mission(
            mission.title,
            isBoss: mission.isBoss,
            size: 96,
            accent: theme.pathActive,
            animate: true,
          ),
          const SizedBox(height: 18),
          Text(
            mission.title,
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            usesExercises
                ? '~3 min'
                : (mission.isBoss
                      ? 'Desafio · $itemCount perguntas · +${mission.stepsReward} passos'
                      : '$itemCount perguntas · +${mission.stepsReward} passos'),
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w600,
              color: AppColors.textOnDark.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpace.section),
          if (bibleFirst) ...[
            if (verse.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColors.nightElevated.withValues(alpha: 0.78),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      offset: const Offset(0, 5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                        color: theme.pathActive,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    if (ref.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        ref,
                        textAlign: TextAlign.center,
                        style: AppTypography.label(
                          size: 11,
                          letterSpacing: 1.4,
                          color: theme.pathActive,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      verse,
                      textAlign: TextAlign.center,
                      style: AppTypography.verse(size: 22, height: 1.4),
                    ),
                  ],
                ),
              ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: AppSpace.md),
              _IntroFact(
                label: 'Contexto',
                text: note,
                accent: theme.pathActive,
              ),
            ],
            if (thread.isNotEmpty) ...[
              const SizedBox(height: AppSpace.sm),
              _IntroFact(
                label: 'Conexão',
                text: thread,
                accent: theme.pathActive,
              ),
            ],
          ] else if (fallbackIntro.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpace.xl),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: AppColors.textOnDark.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                fallbackIntro,
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  size: 15,
                  height: 1.5,
                  color: AppColors.textOnDark.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
          const Spacer(flex: 2),
          CopperCta(
            label: usesExercises
                ? 'Começar'
                : hasStudy
                ? 'Caminhar no texto'
                : (mission.isBoss ? 'Aceitar desafio' : 'Entrar no caminho'),
            onTap: onStart,
          ),
          const SizedBox(height: AppSpace.xl),
        ],
      ),
    );
  }
}

class _IntroFact extends StatelessWidget {
  final String label;
  final String text;
  final Color accent;

  const _IntroFact({
    required this.label,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.textOnDark.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.textOnDark.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.label(size: 10, color: accent),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: AppTypography.body(
              size: 14,
              height: 1.4,
              color: AppColors.textOnDark.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackOverlay extends StatefulWidget {
  final Question question;
  final String questionId;
  final String selected;
  final bool isCorrect;
  final bool isLast;
  final Color accent;
  final bool outOfLamps;
  final String? verseText;
  final String missionSlug;
  final String? trailSlug;
  final String? difficulty;
  final bool practiceMode;
  final VoidCallback onContinue;

  const _FeedbackOverlay({
    required this.question,
    required this.questionId,
    required this.selected,
    required this.isCorrect,
    required this.isLast,
    required this.accent,
    required this.onContinue,
    required this.missionSlug,
    this.outOfLamps = false,
    this.verseText,
    this.trailSlug,
    this.difficulty,
    this.practiceMode = false,
  });

  @override
  State<_FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<_FeedbackOverlay> {
  bool _reread = false;
  bool _reported = false;

  Future<void> _openReport() async {
    if (_reported) return;
    HapticFeedback.selectionClick();
    final sent = await showQuestionReportSheet(
      context,
      buildDraft: (category, comment) => QuestionReportDraft(
        questionId: widget.questionId,
        questionText: widget.question.question,
        verseRef: widget.question.verseRef,
        selectedOptionId: widget.selected,
        selectedOptionText: QuestionFeedback.optionText(
          widget.question,
          widget.selected,
        ),
        correctOptionId: widget.question.correctOptionId,
        correctOptionText: QuestionFeedback.correctOptionText(widget.question),
        userWasCorrect: widget.isCorrect,
        missionSlug: widget.missionSlug,
        trailSlug: widget.trailSlug,
        difficulty: widget.difficulty,
        practiceMode: widget.practiceMode,
        category: category,
        comment: comment,
      ),
    );
    if (!mounted) return;
    if (sent) {
      setState(() => _reported = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Obrigado — vamos revisar com cuidado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final isCorrect = widget.isCorrect;
    final outOfLamps = widget.outOfLamps;
    final accent = widget.accent;
    final feedback = isCorrect
        ? question.feedbackCorrect
        : QuestionFeedback.wrongMessage(question, widget.selected);
    final selectedText = QuestionFeedback.optionText(question, widget.selected);
    final correctText = QuestionFeedback.correctOptionText(question);
    final color = isCorrect ? accent : AppColors.error;
    final bottom = MediaQuery.of(context).padding.bottom;
    final title = outOfLamps
        ? 'Sem lâmpadas'
        : isCorrect
        ? 'Acertou!'
        : 'Errou!';
    final needsReread =
        !isCorrect &&
        !outOfLamps &&
        (widget.verseText != null || question.verseRef != null);
    final canContinue = !needsReread || _reread;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        alignment: Alignment.bottomCenter,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: 0),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) =>
              Transform.translate(offset: Offset(0, value * 100), child: child),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.xl),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                AppSpace.screen,
                AppSpace.section,
                AppSpace.screen,
                AppSpace.lg + bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.night.withValues(alpha: 0.94),
                border: Border(
                  top: BorderSide(
                    color: color.withValues(alpha: 0.7),
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(color, Colors.white, 0.25)!,
                              color,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CinematicIcon(
                            glyph: outOfLamps
                                ? CinematicGlyph.frost
                                : isCorrect
                                ? CinematicGlyph.check
                                : CinematicGlyph.book,
                            size: 26,
                            accent: AppColors.inkOnAccent,
                            framed: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpace.section),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.display(size: 22, color: color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.section),
                  Text(
                    outOfLamps
                        ? 'Suas lâmpadas se apagaram. Revise os erros depois — ainda assim você leva passos parciais. Levante-se e continue caminhando.'
                        : feedback,
                    style: AppTypography.body(
                      size: 15,
                      height: 1.5,
                      color: AppColors.textOnDark.withValues(alpha: 0.92),
                    ),
                  ),
                  if (!outOfLamps &&
                      !isCorrect &&
                      selectedText != null &&
                      correctText != null) ...[
                    const SizedBox(height: AppSpace.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpace.section),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sua resposta: $selectedText',
                            style: AppTypography.body(
                              size: 13,
                              height: 1.4,
                              color: AppColors.textOnDark.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpace.xs),
                          Text(
                            'Resposta certa: $correctText',
                            style: AppTypography.body(
                              size: 14,
                              weight: FontWeight.w700,
                              height: 1.4,
                              color: accent.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!outOfLamps &&
                      (widget.verseText != null ||
                          question.verseRef != null)) ...[
                    const SizedBox(height: AppSpace.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpace.section),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        border: Border.all(
                          color: color.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (question.verseRef != null)
                            Text(
                              question.verseRef!,
                              style: AppTypography.label(
                                size: 11,
                                color: color,
                                letterSpacing: 0.6,
                              ),
                            ),
                          if (widget.verseText != null) ...[
                            const SizedBox(height: AppSpace.xs),
                            Text(
                              '"${widget.verseText}"',
                              style: AppTypography.body(
                                size: 14,
                                height: 1.45,
                                color: AppColors.textOnDark.withValues(
                                  alpha: 0.9,
                                ),
                              ).copyWith(fontStyle: FontStyle.italic),
                            ),
                          ],
                          if (question.verseRef != null) ...[
                            const SizedBox(height: AppSpace.sm),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BibleReaderScreen(
                                      reference: question.verseRef!,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CinematicIcon(
                                    glyph: CinematicGlyph.book,
                                    size: 16,
                                    accent: color,
                                    framed: false,
                                  ),
                                  const SizedBox(width: AppSpace.xs),
                                  Text(
                                    'Abrir na Bíblia',
                                    style: AppTypography.cta(
                                      size: 12,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (needsReread) ...[
                    const SizedBox(height: AppSpace.md),
                    GestureDetector(
                      onTap: () => setState(() => _reread = !_reread),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: _reread ? color : Colors.transparent,
                              border: Border.all(
                                color: color.withValues(alpha: 0.8),
                                width: 2,
                              ),
                            ),
                            child: _reread
                                ? Center(
                                    child: CinematicIcon(
                                      glyph: CinematicGlyph.check,
                                      size: 14,
                                      accent: Colors.white,
                                      framed: false,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpace.sm),
                          Expanded(
                            child: Text(
                              'Reli o versículo com atenção',
                              style: AppTypography.body(
                                size: 13,
                                weight: FontWeight.w700,
                                color: AppColors.textOnDark.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpace.lg),
                  Opacity(
                    opacity: canContinue ? 1 : 0.45,
                    child: _GoldButton(
                      label: canContinue
                          ? (outOfLamps
                                ? 'ENCERRAR COM PASSOS PARCIAIS'
                                : widget.isLast
                                ? 'SEGUIR'
                                : 'CONTINUAR')
                          : 'MARQUE QUE RELÊU',
                      onTap: canContinue ? widget.onContinue : () {},
                    ),
                  ),
                  if (!outOfLamps) ...[
                    const SizedBox(height: AppSpace.sm),
                    TextButton(
                      onPressed: _reported ? null : _openReport,
                      child: Text(
                        _reported
                            ? 'Relato enviado'
                            : 'Relatar problema nesta pergunta',
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w600,
                          color: AppColors.textOnDark.withValues(
                            alpha: _reported ? 0.35 : 0.55,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseFeedbackOverlay extends StatelessWidget {
  final Exercise exercise;
  final String selected;
  final bool isCorrect;
  final bool isLast;
  final Color accent;
  final bool outOfLamps;
  final VoidCallback onContinue;

  const _ExerciseFeedbackOverlay({
    required this.exercise,
    required this.selected,
    required this.isCorrect,
    required this.isLast,
    required this.accent,
    required this.onContinue,
    this.outOfLamps = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? accent : AppColors.error;
    final bottom = MediaQuery.of(context).padding.bottom;
    final feedback = exercise.feedbackFor(selected, correct: isCorrect);
    final title = outOfLamps
        ? 'Sem lâmpadas'
        : isCorrect
        ? 'Acertou!'
        : 'Quase';
    final cta = outOfLamps
        ? 'ENCERRAR COM PASSOS PARCIAIS'
        : isCorrect
        ? (isLast ? 'SEGUIR' : 'CONTINUAR')
        : 'TENTAR DE NOVO';

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.bottomCenter,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: 0),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          builder: (context, value, child) =>
              Transform.translate(offset: Offset(0, value * 120), child: child),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                AppSpace.screen,
                AppSpace.lg,
                AppSpace.screen,
                AppSpace.lg + bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.night,
                border: Border(top: BorderSide(color: color, width: 3.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                        child: Center(
                          child: CinematicIcon(
                            glyph: outOfLamps
                                ? CinematicGlyph.frost
                                : isCorrect
                                ? CinematicGlyph.check
                                : CinematicGlyph.book,
                            size: 26,
                            accent: AppColors.inkOnAccent,
                            framed: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.display(size: 28, color: color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.md),
                  Text(
                    feedback,
                    style: AppTypography.body(size: 16, height: 1.45),
                  ),
                  if (!isCorrect &&
                      !outOfLamps &&
                      (exercise.retryHint?.trim().isNotEmpty ?? false) &&
                      feedback != exercise.retryHint!.trim()) ...[
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      exercise.retryHint!,
                      style: AppTypography.body(
                        size: 13,
                        color: AppColors.textOnDark.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  if (exercise.reference != null &&
                      exercise.reference!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      exercise.reference!,
                      style: AppTypography.label(
                        size: 11,
                        letterSpacing: 1.2,
                        color: accent,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpace.lg),
                  CopperCta(label: cta, onTap: onContinue),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GoldButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CopperCta(label: label, onTap: onTap);
  }
}
