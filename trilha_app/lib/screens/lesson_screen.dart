import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/mission_study.dart';
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
import '../utils/genesis_theme.dart';
import '../utils/palco_verse.dart';
import '../utils/trail_progress.dart';
import '../widgets/act_feel.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/exercise_feedback_dialog.dart';
import '../widgets/exercise_panel.dart';
import '../widgets/lamps_bar.dart';
import '../widgets/stage_plate.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/verse_fill_panel.dart';
import '../widgets/mission_listen_button.dart';
import '../screens/celebration_screen.dart';
import '../services/tts_service.dart';
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
  int _correctCount = 0;
  int _combo = 0;
  bool _showFeedback = false;
  bool _busy = false;
  int _lamps = ProgressService.maxLamps;
  bool _hintUsed = false;
  Set<String> _eliminated = {};
  bool _outOfLamps = false;
  int _attempt = 0;
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
              moduleTitle = mod.title;
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
    final cornerOpens = !widget.practiceMode &&
        context.read<CornerService>().opensMission(widget.missionSlug);
    if (!widget.practiceMode &&
        !widget.skipTrailLock &&
        !cornerOpens &&
        widget.missionOverride == null &&
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

    final usesBank = QuestionBank.instance.hasBankForTrail(bankTrail);

    if (usesBank &&
        bankTrail != null &&
        (mission.bankTrailSlug ?? '').isEmpty) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não encontramos atos para esta missão. Verifique a conexão e tente de novo.',
            style: AppTypography.body(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
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
        title: mission.title,
        subtitle: '~3 min',
        intro: mission.intro,
        type: mission.type,
        stepsReward: _scaledSteps(
          mission.stepsReward,
          plan.difficultyMeta?.stepsMultiplier ?? 1,
        ),
        questions: mission.questions,
        exercises: plan.acts,
        objective: mission.objective,
        centralInsight: plan.insight.isNotEmpty ? plan.insight : null,
        hookRef: hooks.ref,
        hookVerse: hooks.verse,
        hookNote: hooks.note,
        hookThread: hooks.thread,
        bankSection: mission.bankSection,
        bankTrailSlug: mission.bankTrailSlug,
      );
    });
  }

  /// Entrada bíblica: missão → estudo → atos. Leitura na tradução escolhida.
  Future<({String? ref, String? verse, String? note, String? thread})>
  _resolveHooks(Mission mission, {List<Exercise> acts = const []}) async {
    final study = _studyFor(mission);
    var entrance = SessionComposer.resolveEntrance(
      mission: mission,
      studyRef: study?.passageRef,
      studyVerse: study?.passageText,
      studyContext: study?.context,
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

  int get _scoredItemCount =>
      _exercises.where((e) => !e.type.isRevealOnly).length;

  Exercise get _exercise => _exercises[_questionIndex];

  GenesisModuleTheme get _theme => GenesisModuleTheme.forModule(
    _moduleTitle ?? '',
    realm: TrailRealm.fromId(_realmId),
    trailSlug: _trailSlug,
  );

  ({String reference, String text})? get _board {
    final hookT = (_mission?.hookVerse ?? '').trim();
    final hookR = (_mission?.hookRef ?? '').trim();
    if (hookT.length >= 12) return (reference: hookR, text: hookT);
    return _microVerse();
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
    if (correct) {
      SoundService.instance.playCorrect();
      _combo++;
      if (_combo >= 2) ActHaptics.success();
    } else {
      SoundService.instance.playWrong();
      _combo = 0;
      _mistakeInSession = true;
    }

    _impactPositive = correct;
    _impactFlash.forward(from: 0);
    if (!mounted) {
      _busy = false;
      return;
    }
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

    final progress = context.read<ProgressService>();
    final trackBankId =
        ex.id.isNotEmpty && (_pickedIds.contains(ex.id) || widget.practiceMode);
    if (trackBankId) {
      unawaited(
        correct ? progress.clearMistake(ex.id) : progress.recordMistake(ex.id),
      );
    }
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
    unawaited(
      AnalyticsService.instance.logExerciseComplete(
        missionSlug: widget.missionSlug,
        type: ex.type.wireId,
        skill: ex.skill,
        index: _questionIndex,
        correct: correct,
      ),
    );

    if (correct) {
      await Future.delayed(const Duration(milliseconds: 420));
      _busy = false;
      if (mounted) _continue();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 420));
    _busy = false;
    if (mounted) setState(() => _showFeedback = true);
  }

  void _useHint() {
    if (_mission?.isBoss == true) return;
    if (_hintUsed || _selected != null || _showFeedback) return;
    HapticFeedback.selectionClick();
    final ex = _exercise;
    final correctId = ex.resolvedCorrectAnswer.trim();
    final wrong = ex.effectiveOptions.where((o) => o.id != correctId).toList();
    // Sem distrator eliminável — não marca dica como usada.
    if (wrong.isEmpty || correctId.isEmpty) return;
    // Garante que a resposta certa existe nas opções (evita eliminar o acerto).
    final hasCorrect = ex.effectiveOptions.any((o) => o.id == correctId);
    if (!hasCorrect) return;
    wrong.shuffle();
    setState(() {
      _hintUsed = true;
      _eliminated = {wrong.first.id};
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
        reference: studyRef.isNotEmpty ? studyRef : 'Verso',
        text: studyText,
      );
    }

    final hookText = (_mission?.hookVerse ?? '').trim();
    final hookRef = (_mission?.hookRef ?? '').trim();
    if (hookText.length >= 20) {
      return (
        reference: hookRef.isNotEmpty ? hookRef : 'Verso',
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não encontramos atos para esta missão. Verifique a conexão e tente de novo.',
            style: AppTypography.body(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
      );
      return;
    }
    setState(() {
      _phase = _Phase.quiz;
      _attempt = 0;
    });
    _logExerciseStart();
  }

  void _continue() {
    if (_mission == null) return;
    _impactFlash
      ..stop()
      ..value = 0;

    if (_outOfLamps) {
      _finishLesson(forced: true);
      return;
    }

    // Erro → tenta de novo (exceto insight).
    if (_isCorrect == false && !_exercise.type.isRevealOnly) {
      setState(() {
        _showFeedback = false;
        _selected = null;
        _isCorrect = null;
        _hintUsed = false;
        _eliminated = {};
        _attempt++;
      });
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
        _attempt = 0;
      });
      _logExerciseStart();
    } else if (_mistakeInSession && !_reviewInserted) {
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
          context.read<ProgressService>().difficultyForTrail(
            _trailSlug ?? '',
          ),
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
      _attempt = 0;
    });
    _logExerciseStart();
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
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      );
    }

    final mission = _mission!;
    final total = _itemCount.clamp(1, 999);
    final accent = _theme.pathActive;

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
                              _Phase.micro => 'Bônus',
                              _Phase.insight => 'Hoje',
                            },
                            subtitle: switch (_phase) {
                              _Phase.intro =>
                                _difficultyMeta?.label ??
                                    (mission.isBoss ? 'Desafio' : 'Treino'),
                              _Phase.quiz => _difficultyMeta?.label,
                              _Phase.micro => 'Complete o verso',
                              _Phase.insight => 'O que ficou',
                            },
                            onBack: () => Navigator.pop(context),
                            leadingGlyph: CinematicGlyphResolver.forMission(
                              mission.title,
                              isBoss: mission.isBoss,
                            ),
                            chromeAccent: accent,
                            trailing: _phase == _Phase.quiz
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: LampsBar(
                                      current: _lamps,
                                      max: _maxLamps,
                                      accent: accent,
                                      compact: true,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    Expanded(
                      child: switch (_phase) {
                        _Phase.quiz => RepaintBoundary(
                          child: ExercisePanel(
                            key: ValueKey('${_exercise.id}-$_attempt'),
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
                            index: _questionIndex,
                            total: total,
                            insightFallback: mission.centralInsight,
                            boardText: _board?.text,
                            boardRef: _board?.reference,
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
                          theme: _theme,
                          itemCount: total,
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
                    child: Opacity(opacity: 0.02, child: _ActWarmup()),
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
                    outOfLamps: _outOfLamps,
                    onContinue: _continue,
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
    );
  }
}

class _IntroPanel extends StatelessWidget {
  final Mission mission;
  final GenesisModuleTheme theme;
  final int itemCount;
  final VoidCallback onStart;

  const _IntroPanel({
    super.key,
    required this.mission,
    required this.theme,
    required this.itemCount,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final verse = (mission.hookVerse ?? '').trim();
    final ref = (mission.hookRef ?? '').trim();
    final note = (mission.hookNote ?? '').trim();
    final fallbackIntro = mission.intro.trim();
    final accent = theme.pathActive;
    // Palco = verso. Intro narrativo só se nada mais restou.
    final stageText = verse.isNotEmpty
        ? verse
        : (note.isEmpty && fallbackIntro.isNotEmpty ? fallbackIntro : '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            mission.isBoss
                ? 'Desafio · $itemCount atos · +${mission.stepsReward} passos'
                : '~3 min · $itemCount atos · +${mission.stepsReward} passos',
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w600,
              color: AppColors.textOnDark.withValues(alpha: 0.5),
            ),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PlatePrompt(label: 'Contexto', text: note, accent: accent),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: stageText.isEmpty
                ? const SizedBox.shrink()
                : _WitnessPlate(
                    accent: accent,
                    reference: ref,
                    child: Text(
                      stageText,
                      textAlign: TextAlign.center,
                      style: AppTypography.verse(size: 22, height: 1.55),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          MissionListenButton(
            verse: stageText,
            insight: mission.centralInsight,
            accent: accent,
          ),
          const SizedBox(height: 10),
          CopperCta(label: 'Começar', onTap: onStart, trailing: null),
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
          Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.spark,
                size: 22,
                accent: accent,
                framed: false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'HOJE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(
                    size: 18,
                    color: AppColors.textOnDark,
                  ).copyWith(letterSpacing: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _WitnessPlate(
              accent: accent,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppTypography.title(
                  size: 22,
                  height: 1.32,
                  color: accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          CopperCta(label: 'Seguir', onTap: onContinue, trailing: null),
          const SizedBox(height: AppSpace.sm),
        ],
      ),
    );
  }
}

class _WitnessPlate extends StatelessWidget {
  final Color accent;
  final String? reference;
  final Widget child;

  const _WitnessPlate({
    required this.accent,
    required this.child,
    this.reference,
  });

  @override
  Widget build(BuildContext context) {
    final ref = (reference ?? '').trim();
    return StagePlate(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ref.isNotEmpty) ...[
            Text(
              ref.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTypography.label(
                size: 13,
                letterSpacing: 1.8,
                color: accent,
              ),
            ),
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

class _PlatePrompt extends StatelessWidget {
  final String label;
  final String text;
  final Color accent;

  const _PlatePrompt({
    required this.label,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
          ),
          child: Text(
            '${label.toUpperCase()}:',
            style: AppTypography.label(
              size: 10,
              letterSpacing: 1.6,
              color: accent,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.title(size: 16, height: 1.3, color: accent),
        ),
      ],
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
          child: CircularProgressIndicator(
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
