import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../cinematic/cinematic_resolver.dart';
import '../data/mission_study.dart';
import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/difficulty.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../services/content_catalog_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/genesis_theme.dart';
import '../utils/difficulty_trails.dart';
import '../widgets/cinematic_backdrop.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cinematic_lesson_panel.dart';
import '../widgets/study_panel.dart';
import '../widgets/top_bar.dart';
import '../screens/celebration_screen.dart';
import '../screens/bible_screen.dart';
import '../screens/difficulty_picker_screen.dart';

enum _Phase { intro, study, quiz, reflection }

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

class _LessonScreenState extends State<LessonScreen> with TickerProviderStateMixin {
  final _repo = TrailRepository();
  Mission? _baseMission;
  Mission? _mission;
  String? _trailSlug;
  String? _moduleTitle;
  String? _realmId;
  List<String> _pickedIds = [];
  List<String?> _revealTags = [];
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
    _revealAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    _questionEnter = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _impactFlash = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
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
      final hasStudy = !widget.practiceMode &&
          MissionStudy.forSlug(widget.missionSlug) != null;
      setState(() {
        _baseMission = override;
        _trailSlug = 'genesis-1-11';
        _moduleTitle = 'A Criação';
        _realmId = 'antigo-testamento';
        _pickedIds = widget.questionIdsOverride ?? [];
        _revealTags = List.filled(override.questions.length, null);
        _mission = override;
        if (hasStudy) _phase = _Phase.study;
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
    final usesBank = trailUsesDifficultyBank(trailSlug) &&
        QuestionBank.instance.hasBankForTrail(trailSlug);

    // Se abriu passo direto sem escolher profundidade, força o picker.
    if (usesBank && trailSlug != null && !progress.hasDifficultyForTrail(trailSlug)) {
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (_, _, _) => DifficultyPickerScreen(
            trailSlug: trailSlug,
            onSelected: () => Navigator.of(context).pop(),
          ),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
      if (!mounted) return;
      if (!context.read<ProgressService>().hasDifficultyForTrail(trailSlug)) {
        Navigator.of(context).pop();
        return;
      }
    }

    var questions = mission?.questions ?? <Question>[];
    var ids = <String>[];
    var tags = <String?>[];
    DifficultyMeta? meta;

    if (mission != null && usesBank && trailSlug != null) {
      if (!mounted) return;
      final freshProgress = context.read<ProgressService>();
      final diffId = freshProgress.difficultyForTrail(trailSlug) ?? TrailDifficulty.semente.id;
      final difficulty = TrailDifficulty.fromId(diffId) ?? TrailDifficulty.semente;
      meta = await QuestionBank.instance.metaFor(difficulty);
      // 5 perguntas por passo no modo escolhido (pool dedicado ao slug do passo).
      const count = 5;
      ids = await QuestionBank.instance.pickIdsForMission(
        difficulty: difficulty,
        moduleTitle: moduleTitle,
        section: mission.slug,
        count: count,
        usedIds: freshProgress.usedQuestionIds,
        trailSlug: trailSlug,
        isBoss: false,
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
      await freshProgress.markQuestionsUsed(ids);
    }

    if (!mounted) return;
    final hasStudy = !widget.practiceMode &&
        mission != null &&
        MissionStudy.forSlug(widget.missionSlug) != null;
    setState(() {
      _baseMission = mission;
      _trailSlug = trailSlug;
      _moduleTitle = moduleTitle;
      _realmId = realmId;
      _pickedIds = ids;
      _revealTags = tags;
      _difficultyMeta = meta;
      // Com estudo: um só preparo (título + passagem). Sem: intro clássica.
      if (hasStudy) _phase = _Phase.study;
      if (mission != null) {
        _mission = Mission(
          slug: mission.slug,
          title: mission.title,
          subtitle: mission.subtitle,
          intro: mission.intro,
          type: mission.type,
          stepsReward: _scaledSteps(mission.stepsReward, meta?.stepsMultiplier ?? 1),
          questions: questions,
        );
      }
    });
  }

  int _scaledSteps(int base, double multiplier) => (base * multiplier).round();

  Question get _question => _mission!.questions[_questionIndex];

  bool get _cinematic => CinematicResolver.isCinematicMission(_trailSlug, _moduleTitle);

  GenesisModuleTheme get _theme => GenesisModuleTheme.forModule(
        _moduleTitle ?? '',
        realm: TrailRealm.fromId(_realmId),
        trailSlug: _trailSlug,
      );

  String get _correctOptionText {
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
    if (_selected != null || _phase != _Phase.quiz || _showFeedback || _busy || _outOfLamps) return;
    if (_eliminated.contains(optionId)) return;
    _busy = true;
    final correct = optionId == _question.correctOptionId;
    if (correct) {
      SoundService.instance.playCorrect();
      HapticFeedback.lightImpact();
      if (_questionIndex < _pickedIds.length) {
        await context.read<ProgressService>().clearMistake(_pickedIds[_questionIndex]);
      }
    } else {
      SoundService.instance.playWrong();
      HapticFeedback.mediumImpact();
      if (_questionIndex < _pickedIds.length) {
        await context.read<ProgressService>().recordMistake(_pickedIds[_questionIndex]);
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
        _lamps = (_lamps - 1).clamp(0, ProgressService.maxLamps);
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

  void _useHint() {
    if (_hintUsed || _selected != null || _showFeedback) return;
    HapticFeedback.selectionClick();
    final wrong = _question.options.where((o) => o.id != _question.correctOptionId).toList();
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
    final total = _mission!.questions.length;
    final progress = context.read<ProgressService>();
    final isReplay = widget.practiceMode ||
        (_baseMission != null && progress.isMissionCompleted(_baseMission!.slug));
    final steps = ProgressService.computeLessonSteps(
      baseSteps: _mission!.stepsReward,
      correct: _correctCount,
      total: forced ? _answeredCount.clamp(1, total) : total,
      lampsLeft: _lamps,
      maxLamps: ProgressService.maxLamps,
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
          perfect: !forced && _correctCount == total && _lamps == ProgressService.maxLamps,
        ),
      ),
    );
  }

  void _finishLesson({bool forced = false}) {
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
    await context.read<ProgressService>().saveReflection(widget.missionSlug, text);
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

    if (_questionIndex < _mission!.questions.length - 1) {
      setState(() {
        _showFeedback = false;
        _questionIndex++;
        _selected = null;
        _isCorrect = null;
        _hintUsed = false;
        _eliminated = {};
      });
      _questionEnter.forward(from: 0);
      _applyAmbientForQuestion();
    } else {
      _finishLesson();
    }
  }

  void _startStudyOrQuiz() {
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
    if (_mission == null || _baseMission == null) {
      return const Scaffold(
        backgroundColor: AppColors.night,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    final mission = _mission!;
    final total = mission.questions.length;
    final progress = switch (_phase) {
      _Phase.intro => 0.0,
      _Phase.study => 0.08,
      _Phase.quiz => (_questionIndex + (_showFeedback ? 1 : 0)) / total,
      _Phase.reflection => 0.95,
    };
    final accent = _theme.decorColor;
    final study = _study;
    final priorReflection = context.read<ProgressService>().reflectionFor(widget.missionSlug);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_cinematic)
              AnimatedBuilder(
                animation: _revealAnim,
                builder: (context, _) => CinematicBackdrop(
                  world: _displayWorld,
                  revealing: _revealing,
                  revealProgress: _revealAnim.value,
                ),
              )
            else
              DecoratedBox(decoration: BoxDecoration(gradient: _theme.sky)),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _cinematic
                          ? [
                              Colors.black.withValues(alpha: 0.12),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.42),
                            ]
                          : [
                              _theme.nodeCurrentBottom.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.45),
                            ],
                      stops: const [0, 0.4, 1],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
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
                              _Phase.quiz => _difficultyMeta != null
                                  ? 'Pergunta ${_questionIndex + 1}/$total'
                                  : 'Pergunta ${_questionIndex + 1} de $total',
                              _Phase.reflection => 'Reflexão',
                            },
                            subtitle: switch (_phase) {
                              _Phase.intro => _difficultyMeta?.label ??
                                  (mission.isBoss ? 'Desafio' : 'No caminho'),
                              _Phase.study => _difficultyMeta?.label ?? 'Preparo',
                              _Phase.quiz =>
                                _difficultyMeta?.label ?? mission.title,
                              _Phase.reflection => mission.title,
                            },
                            onBack: () => Navigator.pop(context),
                            leadingGlyph: CinematicGlyphResolver.forMission(
                              mission.title,
                              isBoss: mission.isBoss,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: SizedBox(
                              height: 4,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ColoredBox(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                  FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: progress.clamp(0.0, 1.0),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color.lerp(
                                              accent,
                                              Colors.white,
                                              0.25,
                                            )!,
                                            accent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  if (_phase == _Phase.quiz)
                    SliverToBoxAdapter(
                      child: CinematicLessonPanel(
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
                        onHint: _useHint,
                        outOfLamps: _outOfLamps,
                        lamps: _lamps,
                        verseSnippet: () {
                          final v =
                              MissionStudy.verseText(_question.verseRef);
                          if (v == null) return null;
                          return v.length > 72
                              ? '${v.substring(0, 70)}…'
                              : v;
                        }(),
                      ),
                    )
                  else if (_phase == _Phase.study && study != null)
                    SliverToBoxAdapter(
                      child: StudyPanel(
                        key: const ValueKey('study'),
                        study: study,
                        accent: accent,
                        priorReflection: priorReflection,
                        missionIntro: mission.intro,
                        onContinue: _startQuiz,
                      ),
                    )
                  else if (_phase == _Phase.reflection && study != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ReflectionPanel(
                        key: const ValueKey('reflection'),
                        study: study,
                        accent: accent,
                        correct: _correctCount,
                        total: total,
                        onFinish: _completeReflection,
                      ),
                    )
                  else if (_phase == _Phase.intro)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _IntroPanel(
                        key: const ValueKey('intro'),
                        mission: mission,
                        theme: _theme,
                        difficultyMeta: _difficultyMeta,
                        hasStudy: _hasStudy,
                        onStart: _startStudyOrQuiz,
                      ),
                    )
                  else
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
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
                                alpha: (1 - _impactFlash.value) *
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
              _FeedbackOverlay(
                question: _question,
                selected: _selected!,
                isCorrect: _isCorrect!,
                isLast: _outOfLamps || _questionIndex >= total - 1,
                accent: accent,
                outOfLamps: _outOfLamps,
                verseText: MissionStudy.verseText(_question.verseRef),
                onContinue: _continue,
              ),
          ],
        ),
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  final Mission mission;
  final GenesisModuleTheme theme;
  final DifficultyMeta? difficultyMeta;
  final bool hasStudy;
  final VoidCallback onStart;

  const _IntroPanel({
    super.key,
    required this.mission,
    required this.theme,
    required this.difficultyMeta,
    required this.hasStudy,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: Column(
        children: [
          const Spacer(flex: 1),
          CinematicIcon.mission(
            mission.title,
            isBoss: mission.isBoss,
            size: 118,
            accent: theme.decorColor,
            animate: true,
          ),
          const SizedBox(height: 24),
          Text(
            mission.title,
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 28),
          ),
          if (mission.subtitle.isNotEmpty) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              mission.subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 15,
                height: 1.35,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: AppSpace.sm),
          Text(
            mission.isBoss
                ? 'Desafio · ${mission.questions.length} perguntas · +${mission.stepsReward} passos'
                : '${mission.questions.length} perguntas · +${mission.stepsReward} passos',
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
          if (difficultyMeta != null) ...[
            const SizedBox(height: AppSpace.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.decorColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: theme.decorColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyphResolver.forDifficulty(difficultyMeta!.difficulty.id),
                    size: 22,
                    accent: theme.decorColor,
                    glowing: false,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    difficultyMeta!.label,
                    style: AppTypography.title(size: 12, color: theme.decorColor),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpace.md),
          Text(
            hasStudy
                ? 'Estudo → perguntas → reflexão · 5 lâmpadas'
                : '5 lâmpadas · erro apaga uma · dica remove uma opção',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpace.section),
          Container(
            padding: const EdgeInsets.all(AppSpace.xl),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Text(
              mission.intro,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 15,
                height: 1.55,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
          const Spacer(flex: 2),
          _GoldButton(
            label: hasStudy
                ? 'CAMINHAR NO TEXTO'
                : (mission.isBoss ? 'ACEITAR DESAFIO' : 'ENTRAR NO CAMINHO'),
            onTap: onStart,
            accent: theme.decorColor,
          ),
          const SizedBox(height: AppSpace.xl),
        ],
      ),
    );
  }
}

class _FeedbackOverlay extends StatefulWidget {
  final Question question;
  final String selected;
  final bool isCorrect;
  final bool isLast;
  final Color accent;
  final bool outOfLamps;
  final String? verseText;
  final VoidCallback onContinue;

  const _FeedbackOverlay({
    required this.question,
    required this.selected,
    required this.isCorrect,
    required this.isLast,
    required this.accent,
    required this.onContinue,
    this.outOfLamps = false,
    this.verseText,
  });

  @override
  State<_FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<_FeedbackOverlay> {
  bool _reread = false;

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final isCorrect = widget.isCorrect;
    final outOfLamps = widget.outOfLamps;
    final accent = widget.accent;
    final feedback = isCorrect
        ? question.feedbackCorrect
        : question.feedbackWrong[widget.selected] ?? 'Volte ao versículo — o texto responde.';
    final color = isCorrect ? accent : AppColors.error;
    final bottom = MediaQuery.of(context).padding.bottom;
    final title = outOfLamps
        ? 'Lâmpadas apagadas'
        : isCorrect
            ? 'Correto!'
            : 'Você tropeçou';
    final needsReread = !isCorrect && !outOfLamps && (widget.verseText != null || question.verseRef != null);
    final canContinue = !needsReread || _reread;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        alignment: Alignment.bottomCenter,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: 0),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Transform.translate(offset: Offset(0, value * 100), child: child),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.section, AppSpace.screen, AppSpace.lg + bottom),
                decoration: BoxDecoration(
                  color: AppColors.night.withValues(alpha: 0.94),
                  border: Border(top: BorderSide(color: color.withValues(alpha: 0.7), width: 3)),
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
                              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 16),
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
                              accent: const Color(0xFF1A1200),
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
                          : isCorrect
                              ? feedback
                              : 'Levante-se.\nContinue caminhando.\n\n$feedback',
                      style: AppTypography.body(
                        size: 15,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                    if (!outOfLamps && (widget.verseText != null || question.verseRef != null)) ...[
                      const SizedBox(height: AppSpace.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpace.section),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          border: Border.all(color: color.withValues(alpha: 0.35)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (question.verseRef != null)
                              Text(
                                question.verseRef!,
                                style: AppTypography.label(size: 11, color: color, letterSpacing: 0.6),
                              ),
                            if (widget.verseText != null) ...[
                              const SizedBox(height: AppSpace.xs),
                              Text(
                                '"${widget.verseText}"',
                                style: AppTypography.body(
                                  size: 14,
                                  height: 1.45,
                                  color: Colors.white.withValues(alpha: 0.9),
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
                                      style: AppTypography.cta(size: 12, color: color),
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
                                border: Border.all(color: color.withValues(alpha: 0.8), width: 2),
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
                                  color: Colors.white.withValues(alpha: 0.85),
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
                        accent: isCorrect && !outOfLamps ? accent : AppColors.primaryLight,
                        darkText: isCorrect && !outOfLamps,
                      ),
                    ),
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
  final Color accent;
  final bool darkText;

  const _GoldButton({
    required this.label,
    required this.onTap,
    required this.accent,
    this.darkText = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: darkText
                ? [Color.lerp(accent, Colors.white, 0.25)!, accent, Color.lerp(accent, Colors.black, 0.15)!]
                : [accent, Color.lerp(accent, AppColors.primaryDark, 0.35)!],
          ),
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.45), offset: const Offset(0, 4), blurRadius: 12)],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.cta(
            size: 15,
            color: darkText ? AppColors.inkOnAccent : Colors.white,
          ),
        ),
      ),
    );
  }
}

