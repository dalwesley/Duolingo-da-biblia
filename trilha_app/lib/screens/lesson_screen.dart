import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/mission_study.dart';
import '../l10n/app_language.dart';
import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/difficulty.dart';
import '../models/corner_challenge.dart';
import '../models/study_room.dart';
import '../models/trail.dart';
import '../services/plus_log.dart';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/bible_service.dart';
import '../services/content_catalog_service.dart';
import '../services/corner_service.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../services/session_composer.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import 'coming_soon_screen.dart';
import 'paywall_screen.dart';
import '../theme/app_theme.dart';
import '../utils/plus_access.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/day_phase.dart';
import '../utils/layout_utils.dart';
import '../utils/palco_verse.dart';
import '../utils/trail_progress.dart';
import '../widgets/anan_speech.dart';
import '../widgets/act_feel.dart';
import '../widgets/app_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/exercise_feedback_dialog.dart';
import '../widgets/evidence_verse.dart';
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
import '../screens/main_shell.dart';
import '../services/tts_service.dart';
import '../widgets/set_piece.dart';
import '../widgets/relic_panel.dart';
import '../widgets/verse_study_sheet.dart';
import '../screens/difficulty_picker_screen.dart';

/// Sessão única: entrada → atos → (micro) → insight → saída.
/// Estudo longo pré-quiz removido ([docs/SESSAO_TREINO.md]).
enum _Phase { intro, quiz, micro, insight }

/// O Anan chamando: na primeira vez (ensina o toque) ou quando a pessoa
/// travou (erro, ou parada há um tempo).
enum _AnanCall { none, teach, stuck }

/// O que a pessoa escolheu na ajuda do Anan e precisa voltar para a cena.

class LessonScreen extends StatefulWidget {
  final String missionSlug;
  final bool practiceMode;
  final bool skipTrailLock;
  final Mission? missionOverride;
  final List<String>? questionIdsOverride;

  /// Lição que só o Peregrino+ abre (revisões, reforço). A checagem mora
  /// aqui também — não só no botão que empurra a rota.
  final bool requiresPlus;

  /// O fluxo que abriu a cena já decidiu o Peregrino+ (Caminhada: dias
  /// 1–3 grátis, 4+ conferido na tela da temporada; tentar de novo a cena
  /// que acabou de passar pela trava).
  final bool plusGateDone;

  const LessonScreen({
    super.key,
    required this.missionSlug,
    this.practiceMode = false,
    this.skipTrailLock = false,
    this.missionOverride,
    this.questionIdsOverride,
    this.requiresPlus = false,
    this.plusGateDone = false,
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

  /// Uma lamparina por pergunta da cena (a revisão extra não acende outra).
  int _lampCount = ProgressService.maxLamps;
  bool _hintUsed = false;
  Set<String> _eliminated = {};

  _AnanCall _ananCall = _AnanCall.none;
  Timer? _ananIdle;
  static const _ananIdleAfter = Duration(seconds: 18);
  bool _outOfLamps = false;

  /// Índice da lâmpada que acabou de apagar — flash vermelho no HUD.
  int? _lampFlashOff;

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
    _impactFlash = AnimationController(vsync: this, duration: AppMotion.gentle);
    _load();
  }

  @override
  void dispose() {
    _impactFlash.dispose();
    _ananIdle?.cancel();
    TtsService.instance.stop();
    super.dispose();
  }

  /// A cena pode abrir pelo lado do Peregrino+? Sim com o Plus, na
  /// amostra (1ª cena da trilha) ou quando quem paga a liberou: o líder no
  /// estudo da semana do grupo, o par na Travessia. Uma cena por vez — a
  /// seguinte da trilha volta a pedir o Plus.
  Future<bool> _plusAllows(
    Trail trail, {
    CornerChallenge? corner,
    StudyRoom? roomStudy,
  }) async {
    if (!PlusAccess.trailIsPlus(trail)) return true;
    final slug = widget.missionSlug;
    if (!PlusAccess.missionNeedsPlus(trail, slug)) {
      PlusLog.log(
        'trava',
        'trilha temática ${trail.slug} · cena $slug: amostra grátis (1ª cena)',
      );
      return true;
    }
    if (context.read<SubscriptionService>().plusFeaturesOpen) {
      PlusLog.log(
        'trava',
        'trilha temática ${trail.slug} · cena $slug: Plus aberto, liberada',
      );
      return true;
    }
    final backend = context.read<BackendService>();
    final uid = backend.uid;
    final grantor = roomStudy != null
        ? (id: roomStudy.ownerId, name: roomStudy.ownerName)
        : corner != null && uid != null
        ? (id: corner.peerId(uid), name: corner.peerName(uid))
        : null;
    if (grantor == null || grantor.id.isEmpty || grantor.id == uid) {
      PlusLog.log(
        'trava',
        'trilha temática ${trail.slug} · cena $slug: sem Plus, paywall',
      );
      return false;
    }
    final granted = await backend.pilgrimHasPlus(grantor.id);
    PlusLog.log(
      'trava',
      'trilha temática ${trail.slug} · cena $slug: '
          '${roomStudy != null ? 'estudo do grupo' : 'Travessia'} de '
          '${PlusLog.shortUid(grantor.id)} — '
          '${granted ? 'tem Plus, liberada' : 'sem Plus, paywall'}',
    );
    if (granted && mounted) {
      unawaited(
        showAppToastFor(
          context,
          message: context.l10n.lessonPlusGrantedBy(grantor.name),
          glyph: CinematicGlyph.gift,
          tone: AppToastTone.accent,
        ),
      );
    }
    return granted;
  }

  Future<void> _load() async {
    if (widget.requiresPlus) {
      final open = context.read<SubscriptionService>().plusFeaturesOpen;
      PlusLog.log(
        'trava',
        'cena ${widget.missionSlug} exige Plus: ${open ? 'liberada' : 'paywall'}',
      );
    }
    if (widget.requiresPlus &&
        !context.read<SubscriptionService>().plusFeaturesOpen) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const PaywallScreen(source: 'lesson_gate'),
        ),
      );
      return;
    }
    await ContentCatalogService.instance.ensureLoaded();
    if (!mounted) return;
    final progress = context.read<ProgressService>();

    Mission? mission = widget.missionOverride;
    String? trailSlug;
    String? moduleTitle;

    if (mission != null) {
      trailSlug = 'genesis-1-11';
      moduleTitle = 'A Criação';
    } else {
      mission = await _repo.getMissionBySlug(widget.missionSlug);
      trailSlug = await _repo.getTrailSlugForMission(widget.missionSlug);
      if (trailSlug != null) {
        final trail = await _repo.getTrailBySlug(trailSlug);
        if (trail != null) {
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

    if (widget.skipTrailLock) {
      PlusLog.log(
        'trava',
        'cena ${widget.missionSlug} aberta por fluxo próprio '
            '(Caminhada, repetir): trava de trilha não se aplica',
      );
    }
    // Deep link / rota direta: não deixa pular unlock de trilha ou passo.
    // Caminhada, repetir, estudo do grupo e Travessia ativa já autorizaram
    // a cena — a trava de progresso não se aplica. A do Peregrino+ sim.
    final corner = widget.practiceMode
        ? null
        : context.read<CornerService>().challengeOpening(widget.missionSlug);
    final roomStudy = widget.practiceMode
        ? null
        : context.read<RoomService>().roomStudying(widget.missionSlug);
    if (!widget.practiceMode &&
        widget.missionOverride == null &&
        trailSlug != null) {
      final trails = await _repo.getTrails();
      if (!mounted) return;
      final trail = trails.where((t) => t.slug == trailSlug).firstOrNull;
      if (trail != null) {
        final visibleCompleted = progress.completedMissionsForTrail(
          trailSlug: trail.slug,
          missionSlugs: trail.missionSlugs,
        );
        final alreadyDone = visibleCompleted.contains(widget.missionSlug);
        if (!widget.skipTrailLock && corner == null && roomStudy == null) {
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
          if (!unlockedTrail || (!unlockedMission && !alreadyDone)) {
            await showAppToastFor(
              context,
              message: context.l10n.lessonLocked,
              glyph: CinematicGlyph.lock,
              tone: AppToastTone.warn,
            );
            if (!mounted) return;
            Navigator.of(context).pop();
            return;
          }
        }
        // Trilha temática: da 2ª cena em diante só com o Peregrino+, em
        // qualquer caminho (mapa, Home, deep link, grupo, Travessia). Fica
        // de fora o que o fluxo já decidiu (Caminhada, [requiresPlus]) e a
        // cena já feita, que sempre se pode repetir.
        if (!widget.plusGateDone &&
            !widget.requiresPlus &&
            !alreadyDone &&
            !await _plusAllows(trail, corner: corner, roomStudy: roomStudy)) {
          if (!mounted) return;
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const PaywallScreen(source: 'trail'),
            ),
          );
          return;
        }
        if (!mounted) return;
      }
    }

    final usesBank = QuestionBank.instance.hasBankForTrail(bankTrail);

    Trail? trailForMode;
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
      trailForMode = await _repo.getTrailBySlug(bankTrail);
      if (!mounted) return;
      await context.read<ProgressService>().advancePastClearedMode(
        bankTrail,
        missionSlugs: trailForMode?.missionSlugs ?? const [],
      );
    }

    if (!mounted) return;
    final freshProgress = context.read<ProgressService>();
    final slugs = trailForMode?.missionSlugs ?? const <String>[];
    var sceneIndex = slugs.indexOf(mission.slug);
    if (sceneIndex < 0) sceneIndex = slugs.indexOf(widget.missionSlug);
    final plan = await SessionComposer.compose(
      mission: mission,
      missionSlug: widget.missionSlug,
      trailSlug: bankTrail ?? trailSlug,
      moduleTitle: moduleTitle,
      usesBank: usesBank,
      progress: freshProgress,
      practiceMode: widget.practiceMode,
      questionIdsOverride: widget.questionIdsOverride,
      sceneIndex: sceneIndex,
    );

    if (!mounted) return;

    if (plan.isEmpty) {
      await _showLoadError();
      if (!mounted) return;
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
      _baseMission = mission!;
      _trailSlug = trailSlug;
      _pickedIds = plan.bankQuestionIds;
      _exercises = List<Exercise>.from(plan.acts);
      _closingInsight = plan.insight;
      _celebrationForced = false;
      _mistakeInSession = false;
      _reviewInserted = false;
      _difficultyMeta = plan.difficultyMeta;
      _lampCount = plan.acts
          .where((e) => !e.type.isRevealOnly)
          .length
          .clamp(1, 99);
      _lamps = _lampCount;
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
    if (mission.isBoss) unawaited(_openCrossing(mission));
  }

  /// Travessia: o primeiro passo em cada uma abre como um grande momento.
  /// Só marca como visto no Começar. Voltar fecha cena + mapa e vai à Hoje.
  Future<void> _openCrossing(Mission mission) async {
    final id = 'crossing:${mission.slug}';
    if (await SetPieceMemory.seen(id)) return;
    if (!mounted) return;
    final l10n = context.l10n;
    final confirmed = await showSetPiece(
      context,
      SetPiece(
        eyebrow: l10n.setPieceCrossingEyebrow,
        title: mission.localizedTitle,
        line: l10n.lessonIntroBossPulse(_exercises.length),
        glyph: CinematicGlyph.crown,
        light: AppRoles.presence,
        cta: l10n.commonStart,
      ),
    );
    if (!mounted) return;
    if (confirmed) {
      await SetPieceMemory.claim(id);
      return;
    }
    Navigator.of(context).popUntil((r) => r.isFirst);
    MainShell.goToday();
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

  int get _maxLamps => _lampCount;

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

  /// Chrome dos gestos: neutro. Ouro = CTA; glow = acerto.
  /// Cor do modo fica no mapa / seletor.
  Color get _gestureChrome => Appearance.of(context).chrome;

  /// Luz do modo nos gestos: lacuna, rótulo, palco e progresso. No papel
  /// claro vira o tom escuro (verde claro some no branco).
  Color get _modeLight {
    final d = _difficultyMeta?.difficulty;
    if (d == null) return _gestureChrome;
    final tone = DifficultyVisuals.accentFor(d);
    return Appearance.of(context).onDark
        ? tone
        : DifficultyVisuals.onLight(tone);
  }

  ({String reference, String text})? get _board {
    final hookT = (_mission?.hookVerse ?? '').trim();
    final hookR = (_mission?.hookRef ?? '').trim();
    if (hookT.length >= 12) return (reference: hookR, text: hookT);
    return _microVerse();
  }

  /// A dica existe neste gesto (some na Travessia).
  bool get _hintOffered =>
      !(_mission?.isBoss ?? false) && _exercise.supportsHint;

  /// A dica ainda pode ser pedida agora.
  bool get _hintOpen =>
      _hintOffered && !_hintUsed && _selected == null && !_showFeedback;

  /// O Anan abre o texto da cena. A dica mora no verso do balão.
  bool get _ananHelps => _board != null;

  /// Pergunta nova (ou de volta): o Anan convida até o primeiro toque e,
  /// se a pessoa ficar parada, oferece ajuda.
  void _armAnan({bool stuck = false}) {
    _ananIdle?.cancel();
    if (_phase != _Phase.quiz || !_ananHelps) {
      if (_ananCall != _AnanCall.none) {
        setState(() => _ananCall = _AnanCall.none);
      }
      return;
    }
    final found = context.read<ProgressService>().ananHelpFound;
    final call = !found
        ? _AnanCall.teach
        : (stuck ? _AnanCall.stuck : _AnanCall.none);
    if (call != _ananCall) setState(() => _ananCall = call);
    if (call != _AnanCall.none) return;
    _ananIdle = Timer(_ananIdleAfter, () {
      if (!mounted || _phase != _Phase.quiz) return;
      if (_selected != null || _showFeedback) return;
      setState(() => _ananCall = _AnanCall.stuck);
    });
  }

  /// Texto da cena no Anan: reler, ouvir e estudar — sem sair do fluxo.
  Future<void> _openHelp(String source) async {
    final board = _board;
    if (board == null) return;
    final from = switch (_ananCall) {
      _AnanCall.teach => 'teach',
      _AnanCall.stuck => 'nudge',
      _AnanCall.none => source,
    };
    context.read<ProgressService>().markAnanHelpFound();
    _ananIdle?.cancel();
    if (_ananCall != _AnanCall.none) {
      setState(() => _ananCall = _AnanCall.none);
    }
    unawaited(
      AnalyticsService.instance.logEvent('anan_help_open', {
        'mission_slug': widget.missionSlug,
        'index': _questionIndex,
        'source': from,
        'after_error': _isCorrect == false || _wrongsHere > 0 ? 1 : 0,
        'hint_open': _hintOpen ? 1 : 0,
      }),
    );
    await showAppSheet<void>(
      context,
      builder: (_) => _AnanHelpSheet(
        reference: board.reference,
        text: board.text,
        accent: _gestureChrome,
      ),
    );
    TtsService.instance.stop();
  }

  /// Primeiro verso do balão: marca a dica como usada (analytics + estado).
  void _revealHint() {
    if (!_hintOpen) return;
    unawaited(
      AnalyticsService.instance.logEvent('anan_hint_use', {
        'mission_slug': widget.missionSlug,
        'index': _questionIndex,
        'source': 'bubble',
      }),
    );
    _useHint();
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
    _ananIdle?.cancel();
    if (_ananCall == _AnanCall.stuck) _ananCall = _AnanCall.none;

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
    if (correct) {
      SoundService.instance.playCorrect();
      _combo++;
      if (_combo >= 2) ActHaptics.success();
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
      // Só o primeiro erro de cada pergunta apaga lâmpada.
      if (!correct && firstTry && !requeued) {
        final lost = _lamps - 1;
        _lamps = (_lamps - 1).clamp(0, _maxLamps);
        if (lost >= 0) _lampFlashOff = lost;
        if (_lamps == 0) _outOfLamps = true;
      }
      _showFeedback = false;
    });
    if (_lampFlashOff != null) {
      Future.delayed(const Duration(milliseconds: 520), () {
        if (!mounted) return;
        if (_lampFlashOff != null) setState(() => _lampFlashOff = null);
      });
    }

    final progress = context.read<ProgressService>();
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
        unawaited(
          progress.recordMistake(ex.id, answer: ex.labelForAnswer(optionId)),
        );
      } else if (firstTry && !requeued) {
        unawaited(progress.clearMistake(ex.id));
      }
    }
    final elapsed = _actStartedAt == null
        ? 0
        : DateTime.now().difference(_actStartedAt!).inMilliseconds;
    // Placar de acerto conta só a primeira tentativa da pergunta original.
    if (firstTry && !requeued) {
      final mode = _difficultyMeta?.difficulty.id;
      if (mode != null && !widget.practiceMode) {
        progress.recordAnswer(
          mode: mode,
          type: ex.type.wireId,
          correct: correct,
          trailSlug: _trailSlug,
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
    final ex = _exercise;
    // Banco V3: frase no verso do balão; nenhuma opção some.
    if (ex.textHint != null) {
      setState(() => _hintUsed = true);
      return;
    }
    // Banco antigo sem frase: remove um distrator.
    final correctId = ex.resolvedCorrectAnswer.trim();
    final wrong = ex.effectiveOptions
        .where((o) => o.id != correctId && !_eliminated.contains(o.id))
        .toList();
    if (wrong.isEmpty || correctId.isEmpty) return;
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

  /// Bônus fecha toda cena com versículo. Não é a lacuna do Completar: lá
  /// é uma palavra; aqui a pessoa monta a frase com várias.
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

  Future<void> _showLoadError() {
    return showAppDialog<void>(
      context,
      builder: (ctx) => AppDialog(
        leading: const CloudMascot(face: CloudFace.erro, size: 112),
        content: Text(ctx.l10n.lessonLoadError),
        actions: [
          CopperCta(
            label: ctx.l10n.commonGotIt,
            dense: true,
            trailing: null,
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _startQuiz() {
    TtsService.instance.stop();
    if (_exercises.isEmpty) {
      unawaited(_showLoadError());
      return;
    }
    setState(() {
      _phase = _Phase.quiz;
    });
    _logExerciseStart();
    _armAnan();
    unawaited(_maybeTeachStrong());
  }

  /// Uma vez: ensina Strong a partir da referência do palco.
  Future<void> _maybeTeachStrong() async {
    if (widget.practiceMode) return;
    final progress = context.read<ProgressService>();
    if (progress.strongTeachOffered) return;
    final ref = (_mission?.hookRef ?? '').trim();
    if (ref.isEmpty) return;
    await progress.markStrongTeachOffered();
    if (!mounted) return;
    final open = await showAppSheet<bool>(
      context,
      builder: (ctx) => AppSheetPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSheetHeader(
              eyebrow: ctx.l10n.verseStudyEyebrow,
              title: ctx.l10n.lessonStrongTeachTitle,
              subtitle: ctx.l10n.lessonStrongTeachBody,
              center: true,
            ),
            const SizedBox(height: 20),
            CopperCta(
              label: ctx.l10n.lessonStrongTeachCta,
              onTap: () => Navigator.pop(ctx, true),
              leading: CinematicGlyph.book,
            ),
            const SizedBox(height: 8),
            GhostCta(
              label: ctx.l10n.commonNotNow,
              expanded: true,
              onTap: () => Navigator.pop(ctx, false),
            ),
          ],
        ),
      ),
    );
    if (open == true && mounted) {
      await showVerseStudyFromReference(context, ref, source: 'lesson_teach');
    }
  }

  Future<void> _openStrongFromRef(String reference) async {
    final ref = reference.trim();
    if (ref.isEmpty) return;
    ActHaptics.tap();
    await showVerseStudyFromReference(context, ref, source: 'lesson_ref');
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
        _armAnan(stuck: true);
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
      _armAnan();
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
      // Por gesto visto: Toque com lacuna bloqueia o Completar também.
      usedTypes: _exercises.map(SessionComposer.exerciseSlot).toSet(),
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
    _armAnan();
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
    final accent = _gestureChrome;
    final modeLabel =
        _difficultyMeta?.label ??
        (mission.isBoss
            ? context.l10n.lessonBoss
            : context.l10n.lessonPractice);

    return Appearance(
      mode: mode,
      style: appearance,
      child: PopScope(
        canPop: !_guardExit,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmExit();
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: appearance.systemOverlay,
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
                          // Sombra de palco só no céu escuro; no Claro
                          // ela só sujava o azul.
                          colors: appearance.onDark
                              ? [
                                  Colors.black.withValues(alpha: 0.1),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.38),
                                ]
                              : [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.06),
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
                                _Phase.intro => modeLabel,
                                // O tipo do gesto; o passo já está na faixa.
                                _Phase.quiz => _exercise.taskPromptLabel,
                                _Phase.micro => context.l10n.lessonBonus,
                                _Phase.insight => context.l10n.commonToday,
                              },
                              subtitle: switch (_phase) {
                                _Phase.intro => null,
                                _Phase.quiz => null,
                                // O pedido já está no balão do Anan.
                                _Phase.micro => null,
                                _Phase.insight =>
                                  context.l10n.lessonInsightSubtitle,
                              },
                              onBack: _confirmExit,
                              leadingGlyph: CinematicGlyphResolver.forMission(
                                mission.title,
                                isBoss: mission.isBoss,
                              ),
                              chromeAccent: accent,
                              // O texto da cena e a dica moram no Anan.
                              trailing: _phase == _Phase.quiz
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: LampsBar(
                                        current: _lamps,
                                        max: _maxLamps,
                                        accent: AppRoles.presence,
                                        flame: AppRoles.lamp,
                                        compact: true,
                                        atRisk: _lamps <= 1 && !_outOfLamps,
                                        flashOffIndex: _lampFlashOff,
                                      ),
                                    )
                                  : null,
                              // Passos da cena dentro da barra, finos.
                              bottom: _phase == _Phase.quiz
                                  ? _ActProgress(
                                      total: total,
                                      index: _questionIndex,
                                      results: _results,
                                      accent: _modeLight,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ContentFrame(
                          child: switch (_phase) {
                            // Ato sai para a esquerda, o próximo entra pela direita.
                            // Tentar de novo não troca a chave: a pergunta fica e só o
                            // estado local reinicia (mantendo a ordem montada).
                            // Um filho só: empilhar o painel anterior (com pulse
                            // vivo) + o novo dobrava o custo de paint na troca.
                            _Phase.quiz => AnimatedSwitcher(
                              duration: AppMotion.standard,
                              switchInCurve: AppMotion.enter,
                              switchOutCurve: AppMotion.exit,
                              layoutBuilder: (current, _) =>
                                  current ?? const SizedBox.shrink(),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.08, 0),
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
                                  accent: _modeLight,
                                  hintText: _hintOffered || _hintUsed
                                      ? _exercise.textHint
                                      : null,
                                  onRevealHint: _hintOpen ? _revealHint : null,
                                  eliminatedIds: _eliminated,
                                  onAnan: _ananHelps
                                      ? () => _openHelp('tap')
                                      : null,
                                  ananBeckon: _ananCall != _AnanCall.none,
                                  ananCaption: switch (_ananCall) {
                                    _AnanCall.teach =>
                                      context.l10n.lessonAnanTeach,
                                    _AnanCall.stuck =>
                                      context.l10n.lessonAnanStuck,
                                    _AnanCall.none => null,
                                  },
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
                                accent: _modeLight,
                                onDone: _completeMicro,
                              );
                            }(),
                            _Phase.intro => _IntroPanel(
                              key: const ValueKey('intro'),
                              mission: mission,
                              accent: _modeLight,
                              onStart: _startQuiz,
                              onStudyRef: () {
                                final r = (mission.hookRef ?? '').trim();
                                if (r.isEmpty) return;
                                unawaited(_openStrongFromRef(r));
                              },
                            ),
                            _Phase.insight => _InsightPanel(
                              key: const ValueKey('insight'),
                              text: _closingInsight,
                              facts: _study?.localizedFacts ?? const [],
                              passageRef: _study?.passageRef ?? '',
                              passageText: _study?.passageText ?? '',
                              accent: accent,
                              onContinue: () {
                                _pushCelebration(forced: _celebrationForced);
                              },
                            ),
                          },
                        ),
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
                                  (_impactPositive
                                          ? AppRoles.action
                                          : AppRoles.error)
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
                      onReadPassage: _board == null
                          ? null
                          : () => _openHelp('feedback'),
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

/// Barra de atos: ouro se acertou de primeira, vermelho se errou,
/// o atual aceso na cor do modo; o trilho leva um eco dela.
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
    final a = Appearance.of(context);
    final track = Color.lerp(a.progressTrack, accent, 0.22)!;
    return Semantics(
      label: context.l10n.lessonQuestionProgress(index + 1, total),
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: AnimatedContainer(
                duration: AppMotion.gentle,
                curve: AppMotion.enter,
                height: i == index ? 2.5 : 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  color: switch (results[i]) {
                    true => AppRoles.action,
                    false => AppRoles.error.withValues(alpha: 0.75),
                    null => i == index ? accent : track,
                  },
                  boxShadow: results[i] == true
                      ? [
                          BoxShadow(
                            color: AppRoles.action.withValues(alpha: 0.45),
                            blurRadius: 4,
                          ),
                        ]
                      : (results[i] == null && i == index)
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.5),
                            blurRadius: 4,
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

/// Texto da cena no Anan: reler, ouvir e estudar — um CTA ouro volta à pergunta.
class _AnanHelpSheet extends StatelessWidget {
  final String reference;
  final String text;
  final Color accent;

  const _AnanHelpSheet({
    required this.reference,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = text.trim().isNotEmpty;
    final ref = reference.trim();
    final maxVerseH = MediaQuery.sizeOf(context).height * 0.28;

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
          if (!hasText)
            AppSheetHeader(
              center: true,
              title: context.l10n.lessonAnanHelpLabel,
            )
          else ...[
            AnanSpeech(
              face: CloudFace.feliz,
              ananSize: 64,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.lessonPassageTitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w800,
                      color: AnanSpeechBubble.mark,
                    ),
                  ),
                  if (ref.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      ref,
                      textAlign: TextAlign.center,
                      style: AppTypography.title(
                        size: 18,
                        color: AnanSpeechBubble.ink,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpace.sm),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxVerseH),
                    child: SingleChildScrollView(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: AppTypography.verse(
                          size: 18,
                          weight: FontWeight.w600,
                          height: 1.55,
                          color: AnanSpeechBubble.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Row(
              children: [
                Expanded(
                  child: MissionListenButton(verse: text, accent: accent),
                ),
                if (ref.isNotEmpty) ...[
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: GhostCta(
                      label: context.l10n.lessonStudyRefCta,
                      leading: CinematicGlyph.book,
                      expanded: true,
                      onTap: () async {
                        Navigator.pop(context);
                        await showVerseStudyFromReference(
                          context,
                          reference,
                          source: 'lesson_passage',
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            GhostCta(
              label: context.l10n.lessonExploreSoonCta,
              leading: CinematicGlyph.compass,
              expanded: true,
              onTap: () {
                Navigator.pop(context);
                openComingSoon(
                  context,
                  ComingSoonFeature.explore,
                  source: 'lesson_passage',
                );
              },
            ),
          ],
          const SizedBox(height: AppSpace.lg),
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
            face: CloudFace.triste,
            center: true,

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
  final Color accent;
  final VoidCallback onStart;
  final VoidCallback? onStudyRef;

  const _IntroPanel({
    super.key,
    required this.mission,
    required this.accent,
    required this.onStart,
    this.onStudyRef,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Abertura no mesmo cabeçalho dos gestos: o Anan apresenta a cena.
          AnanSideSpeech(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: AppTypography.title(
                    size: 18,
                    height: 1.15,
                    color: AnanSpeechBubble.ink,
                  ),
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    note,
                    style: AppTypography.body(
                      size: 14,
                      height: 1.4,
                      weight: FontWeight.w600,
                      color: AnanSpeechBubble.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (stageText.isNotEmpty)
                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: stageMaxHeight,
                        ),
                        child: SizedBox.expand(
                          child: _WitnessPlate(
                            accent: accent,
                            reference: ref,
                            brandBack: true,
                            onStudy: ref.isEmpty ? null : onStudyRef,
                            // Versículo como nos gestos: centrado, mesmo corpo.
                            child: Text(
                              stageText,
                              textAlign: TextAlign.center,
                              style: AppTypography.verse(
                                size: 24,
                                weight: FontWeight.w600,
                                height: 1.45,
                                color: a.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
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
          ),
        ],
      ),
    );
  }
}

/// Placa Hoje: o insight da cena e, quando o estudo traz, os fatos que a
/// pessoa leva. Tocar um fato acende no versículo o trecho que o prova.
class _InsightPanel extends StatefulWidget {
  final String text;
  final List<StudyFact> facts;
  final String passageRef;
  final String passageText;
  final Color accent;
  final VoidCallback onContinue;

  const _InsightPanel({
    super.key,
    required this.text,
    required this.accent,
    required this.onContinue,
    this.facts = const [],
    this.passageRef = '',
    this.passageText = '',
  });

  @override
  State<_InsightPanel> createState() => _InsightPanelState();
}

class _InsightPanelState extends State<_InsightPanel> {
  int? _active;

  Widget _insightPlate() {
    return _WitnessPlate(
      accent: widget.accent,
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: AppTypography.title(
          size: 20,
          height: 1.32,
          color: widget.accent,
        ),
      ),
    );
  }

  /// Sem fatos: a frase curta sozinha na placa alta. O Anan fala o que ficou.
  Widget _insightSpeech() {
    return AnanSpeech(
      face: CloudFace.sucesso,
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: AppTypography.title(
          size: 20,
          height: 1.32,
          color: AnanSpeechBubble.ink,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final facts = widget.facts;
    final cta = CopperCta(
      label: context.l10n.commonContinue,
      onTap: widget.onContinue,
      trailing: null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelicChapter(
            title: context.l10n.commonToday,
            accent: widget.accent,
            divided: false,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: facts.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Center(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: _insightSpeech(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      cta,
                      const SizedBox(height: AppSpace.sm),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _insightPlate(),
                              const SizedBox(height: AppSpace.lg),
                              SectionLabel(
                                context.l10n.lessonFactsLabel,
                                size: 12,
                              ),
                              const SizedBox(height: AppSpace.sm),
                              for (var i = 0; i < facts.length; i++)
                                _FactRow(
                                  text: facts[i].text,
                                  accent: widget.accent,
                                  active: _active == i,
                                  onTap:
                                      facts[i].evidenceSpan.trim().isEmpty ||
                                          widget.passageText.trim().isEmpty
                                      ? null
                                      : () {
                                          ActHaptics.tap();
                                          setState(
                                            () => _active = _active == i
                                                ? null
                                                : i,
                                          );
                                        },
                                ),
                              AnimatedSize(
                                duration: AppMotion.standard,
                                curve: AppMotion.enter,
                                alignment: Alignment.topCenter,
                                child: _evidence(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      cta,
                      const SizedBox(height: AppSpace.sm),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _evidence() {
    final i = _active;
    if (i == null || i >= widget.facts.length) return const SizedBox.shrink();
    final span = PalcoVerse.swapDivineName(widget.facts[i].evidenceSpan.trim());
    final verse = SessionComposer.clipFeedbackPassage(
      PalcoVerse.swapDivineName(widget.passageText.trim()),
      hint: span,
      maxWords: 32,
    );
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: EvidenceVerse(
        key: ValueKey('fact-$i'),
        reference: widget.passageRef.trim(),
        verse: verse,
        accent: AppRoles.presence,
        highlight: span,
        highlightColor: AppRoles.presence,
      ),
    );
  }
}

/// Um fato da placa Hoje. Aceso quando o seu trecho está no versículo.
class _FactRow extends StatelessWidget {
  final String text;
  final Color accent;
  final bool active;
  final VoidCallback? onTap;

  const _FactRow({
    required this.text,
    required this.accent,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7, right: 10),
              child: AnimatedContainer(
                duration: AppMotion.standard,
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppRoles.presence : accent,
                ),
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: AppTypography.body(
                  size: 15,
                  height: 1.35,
                  weight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? a.text : a.textSecondary,
                ),
              ),
            ),
          ],
        ),
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
  final VoidCallback? onStudy;

  const _WitnessPlate({
    required this.accent,
    required this.child,
    this.reference,
    this.brandBack = false,
    this.onStudy,
  });

  @override
  Widget build(BuildContext context) {
    final face = _face(context);
    if (!brandBack) return face;
    return BrandFlipCard(accent: accent, front: face);
  }

  Widget _face(BuildContext context) {
    final ref = (reference ?? '').trim();
    // Mesmo palco dos gestos: luz do modo, referência neutra.
    final meta = Appearance.of(context).sectionLabel;
    return StagePlate(
      accent: accent,
      tint: true,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ref.isNotEmpty) ...[
            onStudy == null
                ? Center(child: SectionLabel(ref, size: 13, color: meta))
                : Row(
                    children: [
                      Expanded(
                        child: SectionLabel(
                          ref,
                          size: 13,
                          color: meta,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onStudy,
                        behavior: HitTestBehavior.opaque,
                        child: SoftBadge(
                          text: context.l10n.lessonStudyRefCta,
                          glyph: CinematicGlyph.book,
                          accent: accent,
                        ),
                      ),
                    ],
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

/// Pinta fora da tela no intro para aquecer shaders do veredito.
class _ActWarmup extends StatelessWidget {
  const _ActWarmup();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CloudMascot(face: CloudFace.erro, size: 64),
        const CloudMascot(face: CloudFace.sucesso, size: 64),
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
            color: Appearance.of(context).stageFill,
            borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
            boxShadow: AppMetrics.cardShadow(elevated: true),
          ),
          child: const SizedBox(width: 120, height: 64),
        ),
      ],
    );
  }
}
