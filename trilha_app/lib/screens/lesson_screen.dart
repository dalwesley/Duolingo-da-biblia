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
import '../services/progress_service.dart';
import '../services/session_composer.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/genesis_theme.dart';
import '../utils/difficulty_trails.dart';
import '../utils/trail_progress.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/exercise_panel.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/verse_fill_panel.dart';
import '../data/memory_verses.dart';
import '../screens/celebration_screen.dart';
import '../screens/difficulty_picker_screen.dart';

/// Sessão única: entrada → atos → (micro) → insight → saída.
/// Estudo longo pré-quiz removido ([docs/SESSAO_TREINO.md]).
enum _Phase { intro, quiz, micro, insight }

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

  late final AnimationController _questionEnter;
  late final AnimationController _impactFlash;
  bool _impactPositive = true;

  @override
  void initState() {
    super.initState();
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
    _questionEnter.dispose();
    _impactFlash.dispose();
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

    // Deep link / rota direta: não deixa pular unlock de trilha ou passo.
    if (!widget.practiceMode &&
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

    final usesBank =
        trailUsesDifficultyBank(trailSlug) &&
        QuestionBank.instance.hasBankForTrail(trailSlug);

    if (usesBank &&
        trailSlug != null &&
        !progress.hasDifficultyForTrail(trailSlug)) {
      if (!mounted) return;
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

    if (!mounted) return;
    final freshProgress = context.read<ProgressService>();
    final plan = await SessionComposer.compose(
      mission: mission,
      missionSlug: widget.missionSlug,
      trailSlug: trailSlug,
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
            'Este treino ainda não tem atos.',
            style: AppTypography.body(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    final hooks = await _resolveHooks(mission);
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
        intro: (hooks.note ?? '').trim().isNotEmpty
            ? hooks.note!
            : mission.intro,
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
      );
    });
  }

  /// Entrada bíblica: missão (Firestore) → estudo curto (sem spoiler).
  /// Sempre prefere o texto completo da Bíblia pela referência.
  Future<({String? ref, String? verse, String? note, String? thread})>
      _resolveHooks(Mission mission) async {
    if (mission.hasBibleHook) {
      final ref = (mission.hookRef ?? '').trim();
      var verse = (mission.hookVerse ?? '').trim();
      if (ref.isNotEmpty) {
        final full = await BibleService.instance.passageText(ref);
        if (full != null && full.trim().isNotEmpty) {
          verse = SessionComposer.clipEntranceVerse(full.trim());
        }
      }
      if (verse.isNotEmpty) {
        verse = SessionComposer.clipEntranceVerse(verse);
      }
      final note = (mission.hookNote ?? '').trim();
      final thread = (mission.hookThread ?? '').trim();
      // Contrato: contexto OU conexão — um bloco.
      final side = note.isNotEmpty ? note : thread;
      return (
        ref: ref.isNotEmpty ? ref : mission.hookRef,
        verse: verse.isNotEmpty ? verse : null,
        note: side.isNotEmpty ? side : null,
        thread: null,
      );
    }
    final study = MissionStudy.forSlug(widget.missionSlug);
    if (study == null) {
      return (ref: null, verse: null, note: null, thread: null);
    }
    final ref =
        study.passageRef.trim().isNotEmpty ? study.passageRef.trim() : null;
    var verse = study.passageText.trim();
    if (ref != null) {
      final full = await BibleService.instance.passageText(ref);
      if (full != null && full.trim().isNotEmpty) {
        verse = SessionComposer.clipEntranceVerse(full.trim());
      }
    }
    if (verse.isNotEmpty) {
      verse = SessionComposer.clipEntranceVerse(verse);
    }
    final note = study.context.trim();
    return (
      ref: ref,
      verse: verse.isNotEmpty ? verse : null,
      note: note.isNotEmpty ? note : null,
      thread: null,
    );
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
    AnalyticsService.instance.logExerciseComplete(
      missionSlug: widget.missionSlug,
      type: ex.type.wireId,
      skill: ex.skill,
      index: _questionIndex,
      correct: correct,
    );
    final progress = context.read<ProgressService>();
    final trackBankId =
        ex.id.isNotEmpty &&
        (_pickedIds.contains(ex.id) || widget.practiceMode);
    if (correct) {
      SoundService.instance.playCorrect();
      HapticFeedback.lightImpact();
      if (trackBankId) {
        await progress.clearMistake(ex.id);
      }
    } else {
      SoundService.instance.playWrong();
      HapticFeedback.mediumImpact();
      _mistakeInSession = true;
      if (trackBankId) {
        await progress.recordMistake(ex.id);
      }
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

    await Future.delayed(Duration(milliseconds: correct ? 280 : 320));
    if (mounted) setState(() => _showFeedback = true);
    _busy = false;
  }

  void _useHint() {
    if (_mission?.isBoss == true) return;
    if (_hintUsed || _selected != null || _showFeedback) return;
    HapticFeedback.selectionClick();
    final ex = _exercise;
    final correctId = ex.resolvedCorrectAnswer.trim();
    final wrong = ex.effectiveOptions
        .where((o) => o.id != correctId)
        .toList();
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

  MissionStudy? get _study =>
      widget.practiceMode ? null : MissionStudy.forSlug(widget.missionSlug);

  int get _answeredCount => _questionIndex + (_selected != null ? 1 : 0);

  void _goToCelebration({required bool forced}) {
    if (_mission == null) return;
    // Atos → (micro) → insight → saída. Insight é sempre o último bate.
    if (!forced &&
        _phase != _Phase.micro &&
        _phase != _Phase.insight &&
        !widget.practiceMode &&
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
        ),
      ),
    );
  }

  void _finishLesson({bool forced = false}) {
    // Atos → (micro) → insight → saída.
    _goToCelebration(forced: forced);
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
    // Micro antes do insight — insight fecha a sessão.
    if (_closingInsight.trim().isNotEmpty) {
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
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Este treino ainda não tem atos.',
            style: AppTypography.body(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
      );
      return;
    }
    setState(() => _phase = _Phase.quiz);
    _questionEnter.forward(from: 0);
    _logExerciseStart();
  }

  void _continue() {
    if (_mission == null) return;

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
      _logExerciseStart();
    } else if (_mistakeInSession && !_reviewInserted) {
      final diffId = _difficultyMeta?.difficulty ??
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
        _logExerciseStart();
        return;
      }
      _finishLesson();
    } else {
      _finishLesson();
    }
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
                child: AmbientAtmosphere(
                  phase: appearance.phase,
                  accent: accent,
                  glow: _theme.pathActive,
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
                              _Phase.quiz => '${_questionIndex + 1}/$total',
                              _Phase.micro => 'Bônus',
                              _Phase.insight => 'Hoje',
                            },
                            subtitle: switch (_phase) {
                              _Phase.intro =>
                                _difficultyMeta?.label ??
                                    (mission.isBoss ? 'Desafio' : 'Treino'),
                              _Phase.quiz =>
                                _difficultyMeta?.label ??
                                    _exercise.instructionVerb,
                              _Phase.micro => 'Complete o verso',
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
                        _Phase.quiz => ExercisePanel(
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
                          insightFallback: mission.centralInsight,
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
                          itemCount: total,
                          onStart: _startQuiz,
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
                                onTap: () {
                                  _pushCelebration(
                                    forced: _celebrationForced,
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpace.sm),
                            ],
                          ),
                        ),
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
                _ExerciseFeedbackOverlay(
                  exercise: _exercise,
                  selected: _selected!,
                  isCorrect: _isCorrect!,
                  isLast:
                      _outOfLamps ||
                      (_isCorrect == true && _questionIndex >= total - 1),
                  accent: accent,
                  outOfLamps: _outOfLamps,
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
    final bibleFirst = verse.isNotEmpty || note.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
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
                    mission.isBoss
                        ? 'Desafio · $itemCount atos · +${mission.stepsReward} passos'
                        : '~3 min · $itemCount atos · +${mission.stepsReward} passos',
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
                              style: AppTypography.display(size: 20, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.md),
                      Text(
                        note,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          size: 18,
                          weight: FontWeight.w600,
                          height: 1.45,
                          color: AppColors.textOnDark.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ] else if (fallbackIntro.isNotEmpty)
                    Text(
                      fallbackIntro,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 15,
                        height: 1.4,
                        color: AppColors.textOnDark.withValues(alpha: 0.72),
                      ),
                    ),
                  const SizedBox(height: AppSpace.lg),
                ],
              ),
            ),
          ),
          CopperCta(label: 'Começar', onTap: onStart),
          const SizedBox(height: AppSpace.sm),
        ],
      ),
    );
  }
}
class _ExerciseFeedbackOverlay extends StatefulWidget {
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
  State<_ExerciseFeedbackOverlay> createState() =>
      _ExerciseFeedbackOverlayState();
}

class _ExerciseFeedbackOverlayState extends State<_ExerciseFeedbackOverlay> {
  String? _verseText;

  @override
  void initState() {
    super.initState();
    _loadVerse();
  }

  Future<void> _loadVerse() async {
    final existing = (widget.exercise.passageText ?? '').trim();
    if (existing.isNotEmpty) {
      setState(() => _verseText = existing);
      return;
    }
    final ref = (widget.exercise.reference ?? '').trim();
    if (ref.isEmpty) return;
    final full = await BibleService.instance.passageText(ref);
    if (!mounted || full == null || full.trim().isEmpty) return;
    setState(() => _verseText = full.trim());
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final isCorrect = widget.isCorrect;
    final accent = widget.accent;
    final outOfLamps = widget.outOfLamps;
    final color = isCorrect ? accent : AppColors.error;
    final bottom = MediaQuery.of(context).padding.bottom;
    final feedback = exercise.feedbackFor(widget.selected, correct: isCorrect);
    final title = outOfLamps
        ? 'Sem lâmpadas'
        : isCorrect
        ? 'Acertou!'
        : 'Quase';
    final cta = outOfLamps
        ? 'ENCERRAR COM PASSOS PARCIAIS'
        : isCorrect
        ? (widget.isLast ? 'SEGUIR' : 'CONTINUAR')
        : 'TENTAR DE NOVO';
    final ref = (exercise.reference ?? '').trim();
    final verse = (_verseText ?? '').trim();

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.42),
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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.62,
              ),
              padding: EdgeInsets.fromLTRB(
                AppSpace.screen,
                AppSpace.lg,
                AppSpace.screen,
                AppSpace.lg + bottom,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(AppColors.nightElevated, color, 0.14)!,
                    Color.lerp(AppColors.nightLight, color, 0.06)!,
                  ],
                ),
                border: Border(top: BorderSide(color: color, width: 3.5)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.22),
                    blurRadius: 28,
                    offset: const Offset(0, -8),
                  ),
                ],
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
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
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
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.display(size: 28, color: color),
                        ),
                      ),
                    ],
                  ),
                  if (feedback.trim().isNotEmpty ||
                      ref.isNotEmpty ||
                      verse.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.md),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.34,
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (feedback.trim().isNotEmpty)
                              Text(
                                feedback,
                                style: AppTypography.body(
                                  size: 18,
                                  weight: FontWeight.w600,
                                  height: 1.45,
                                  color: AppColors.textOnDark
                                      .withValues(alpha: 0.95),
                                ),
                              ),
                            if (!isCorrect &&
                                !outOfLamps &&
                                (exercise.retryHint?.trim().isNotEmpty ??
                                    false) &&
                                feedback != exercise.retryHint!.trim()) ...[
                              const SizedBox(height: AppSpace.sm),
                              Text(
                                exercise.retryHint!,
                                style: AppTypography.body(
                                  size: 15,
                                  height: 1.4,
                                  color: AppColors.textOnDark
                                      .withValues(alpha: 0.78),
                                ),
                              ),
                            ],
                            if (ref.isNotEmpty || verse.isNotEmpty) ...[
                              SizedBox(
                                height: feedback.trim().isNotEmpty
                                    ? AppSpace.md
                                    : 0,
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white.withValues(alpha: 0.08),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.28),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (ref.isNotEmpty)
                                      Text(
                                        ref,
                                        style: AppTypography.label(
                                          size: 12,
                                          letterSpacing: 1.1,
                                          color: color,
                                        ),
                                      ),
                                    if (verse.isNotEmpty) ...[
                                      if (ref.isNotEmpty)
                                        const SizedBox(height: 8),
                                      Text(
                                        verse,
                                        style: AppTypography.verse(
                                          size: 16,
                                          weight: FontWeight.w600,
                                          height: 1.4,
                                          color: AppColors.textOnDark
                                              .withValues(alpha: 0.92),
                                        ),
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
                  ],
                  const SizedBox(height: AppSpace.lg),
                  CopperCta(label: cta, onTap: widget.onContinue),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
