import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/entry_trails.dart';
import '../l10n/app_language.dart';
import '../data/question_bank.dart';
import '../data/season_walk_catalog.dart';
import '../data/trail_repository.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/difficulty.dart';
import '../models/pilgrim_medals.dart';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/companion_service.dart';
import '../services/corner_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/remote_config_service.dart';
import '../services/sound_service.dart';
import '../services/room_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/difficulty_trails.dart';
import '../utils/mascot_messages.dart';
import '../utils/trail_progress.dart';
import '../utils/tomorrow_hook.dart';
import '../models/corner_challenge.dart';
import '../widgets/act_feel.dart';
import '../widgets/companion_invite_prompt_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/commit_strip.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/immersive_background.dart';
import '../widgets/invite_qr_sheet.dart';
import '../widgets/mascot_bubble.dart';
import '../widgets/relic_panel.dart';
import '../widgets/reminder_prompt_sheet.dart';
import '../widgets/share_insight_card.dart';
import '../widgets/share_seal_card.dart';
import '../widgets/share_streak_button.dart';
import '../widgets/streak_repair_banner.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/set_piece.dart';
import '../widgets/user_avatar.dart';
import '../services/subscription_service.dart';
import 'lesson_screen.dart';
import 'trail_map_screen.dart';
import 'support_screen.dart';

class CelebrationScreen extends StatefulWidget {
  final String missionSlug;
  final int steps;
  final int correct;
  final int total;
  final String trailSlug;
  final bool isBoss;
  final bool isReplay;
  final bool perfect;

  /// Lâmpadas acabaram: tentativa — não fecha a cena nem conta na semana.
  final bool failed;
  final String? todayInsight;

  const CelebrationScreen({
    super.key,
    required this.missionSlug,
    required this.steps,
    required this.correct,
    required this.total,
    required this.trailSlug,
    this.isBoss = false,
    this.isReplay = false,
    this.perfect = false,
    this.failed = false,
    this.todayInsight,
  });

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen>
    with TickerProviderStateMixin {
  bool _saved = false;

  /// Sequência antes desta missão — o número anima de ontem para hoje.
  int? _streakBefore;

  /// A sequência subiu agora (primeira missão do dia): momento próprio.
  bool _streakUp = false;
  bool _trailComplete = false;
  int _awardedSteps = 0;
  bool _leaving = false;
  String? _medalLine;
  CharacterSeal? _newSeal;
  CornerChallenge? _closedCorner;
  final _sealShareKey = GlobalKey();
  final _insightShareKey = GlobalKey();
  final _stageKey = GlobalKey();
  final _cloudKey = GlobalKey();
  Offset? _rainSource;
  double _rainSpan = 0;
  bool _rainLocked = false;
  bool _rainCapturePending = false;
  TrailDifficulty? _currentMode;
  TrailDifficulty? _nextMode;
  DifficultyMeta? _nextMeta;
  TomorrowHook? _hook;
  bool _hookResolved = false;

  late final AnimationController _entrance;
  late final AnimationController _pulse;
  late final AnimationController _count;
  late final AnimationController _claimPop;

  late final Animation<double> _heroScale;
  late final Animation<double> _heroGlow;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _bodyOpacity;
  late final Animation<Offset> _bodySlide;
  late final Animation<double> _statsOpacity;
  late final Animation<Offset> _statsSlide;
  late final Animation<double> _ctaOpacity;
  late final Animation<Offset> _ctaSlide;
  late final Animation<double> _countProgress;
  late final Animation<double> _claimScale;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    // Após a entrada, congela o fôlego da atmosfera — loop infinito
    // competia com I/O de completeMission e com o restante da UI.
    Future<void>.delayed(const Duration(milliseconds: 4200), () {
      if (!mounted || !_pulse.isAnimating) return;
      _pulse.stop();
      _pulse.value = 0.5;
    });
    _count = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _claimPop = AnimationController(vsync: this, duration: AppMotion.slow);
    _claimScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.14,
        ).chain(CurveTween(curve: AppMotion.pop)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.14,
          end: 1.0,
        ).chain(CurveTween(curve: AppMotion.enter)),
        weight: 55,
      ),
    ]).animate(_claimPop);

    _heroScale = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.55, curve: AppMotion.spring),
    );
    _heroGlow = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.45, curve: AppMotion.enter),
    );
    _titleOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.28, 0.58, curve: AppMotion.enter),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entrance,
            curve: const Interval(0.28, 0.62, curve: AppMotion.enter),
          ),
        );
    _bodyOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.38, 0.68, curve: AppMotion.enter),
    );
    _bodySlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entrance,
            curve: const Interval(0.38, 0.72, curve: AppMotion.enter),
          ),
        );
    _statsOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.48, 0.78, curve: AppMotion.enter),
    );
    _statsSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entrance,
            curve: const Interval(0.48, 0.82, curve: AppMotion.enter),
          ),
        );
    _ctaOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.62, 1.0, curve: AppMotion.enter),
    );
    _ctaSlide = Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entrance,
            curve: const Interval(0.62, 1.0, curve: AppMotion.enter),
          ),
        );
    _countProgress = CurvedAnimation(parent: _count, curve: AppMotion.enter);

    _count.addStatusListener((status) {
      if (status != AnimationStatus.completed || !mounted) return;
      if (widget.failed || _awardedSteps <= 0) return;
      ActHaptics.confirm();
      _claimPop.forward(from: 0);
    });

    _entrance.forward();
    Future<void>.delayed(const Duration(milliseconds: 520), () {
      if (mounted) _count.forward();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    _count.dispose();
    _claimPop.dispose();
    super.dispose();
  }

  Future<void> _leaveCelebration({required bool toTrailMap}) async {
    if (_leaving) return;
    _leaving = true;
    try {
      await _offerRetentionPrompts();
    } catch (_) {}
    if (!mounted) return;
    if (toTrailMap) {
      final canon = EntryTrails.continuesTo[widget.missionSlug];
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TrailMapScreen(slug: canon ?? widget.trailSlug),
        ),
      );
    } else {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  Future<void> _openTomorrow() async {
    if (_leaving) return;
    final slug = (_hook?.missionSlug ?? '').trim();
    if (slug.isEmpty) {
      await _leaveCelebration(toTrailMap: true);
      return;
    }
    _leaving = true;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LessonScreen(missionSlug: slug)),
    );
  }

  /// Replay e tentativa sem lâmpadas: não gravam progresso da cena.
  bool get _noProgress => widget.isReplay || widget.failed;

  void _retryScene() {
    if (_leaving) return;
    _leaving = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            LessonScreen(missionSlug: widget.missionSlug, skipTrailLock: true),
      ),
    );
  }

  Future<void> _offerRetentionPrompts() async {
    if (_noProgress) return;
    final progress = context.read<ProgressService>();
    final companions = context.read<CompanionService>();
    final hasPartner = companions.companions.any((c) => !c.awaitingPartner);
    // Companhia no 2º dia seguido — Friend Streak, não na 1ª missão.
    if (RemoteConfigService.instance.companionEnabled &&
        progress.streak >= 2 &&
        !progress.companionInviteOffered &&
        !hasPartner &&
        companions.companions.isEmpty) {
      final code = await showCompanionInvitePromptSheet(
        context,
        tomorrowTitle: _hook?.title,
        dayTwo: true,
      );
      if (!mounted) return;
      if (code != null && code.isNotEmpty) {
        await showInviteQrSheet(
          context,
          code: code,
          title: context.l10n.celebrationInviteTitle,
          subtitle: context.l10n.celebrationInviteSubtitle,
          inviterName: progress.userName,
        );
      }
    }
    if (!mounted) return;
    // Lembrete “te vejo amanhã” — horário do compromisso.
    if (!progress.notificationsPrompted &&
        progress.firstLessonDate != null &&
        progress.firstLessonDate!.isNotEmpty) {
      await showReminderPromptSheet(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_saved) {
      _saved = true;
      final progress = context.read<ProgressService>();
      final firstSealEncounter =
          !widget.failed &&
          CharacterSeals.unlocksOn(
            widget.missionSlug,
            progress.completedMissions,
          );
      _awardedSteps = _noProgress
          ? (widget.steps * 0.35).round().clamp(5, widget.steps)
          : widget.steps;
      if (widget.failed) {
        _hookResolved = true;
      } else {
        unawaited(_resolveTomorrowHook(progress));
      }
      _streakBefore = progress.streak;
      final walkedBefore = progress.walkedToday;
      // Fanfarra junto da entrada do herói — não espera rede/salvamento.
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        if (widget.failed) return;
        if (widget.perfect) {
          SoundService.instance.playStreak();
        } else {
          SoundService.instance.playComplete(boss: widget.isBoss);
        }
      });
      progress
          .completeMission(
            widget.missionSlug,
            widget.steps,
            isReplay: _noProgress,
            correct: widget.correct,
            total: widget.total,
            alsoComplete: EntryTrails.linkedScenes(widget.missionSlug),
            mode: trailUsesDifficultyBank(widget.trailSlug)
                ? progress.difficultyForTrail(widget.trailSlug) ??
                      TrailDifficulty.semente.id
                : null,
          )
          .then((awarded) async {
            if (mounted && awarded > 0) {
              setState(() => _awardedSteps = awarded);
            }
            if (mounted &&
                !walkedBefore &&
                progress.streak > (_streakBefore ?? 0)) {
              setState(() => _streakUp = true);
            }
            if (mounted && !widget.failed && !_noProgress) {
              unawaited(_runSetPieces(progress));
            }
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final campaign = SeasonWalkCatalog.current(today);
            for (final d in campaign.days) {
              if (d.missionSlug != widget.missionSlug) continue;
              final date = d.dateOn(campaign.start);
              if (date.isAfter(today)) continue;
              final ymd =
                  '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              // A cena é grátis na trilha: quem fez, fez — o dia da
              // Caminhada é creditado mesmo sem Plus (a entrada pela
              // temporada e a revisão seguem do Peregrino+). Assinar
              // depois encontra a caminhada andando, não zerada.
              await progress.markWalkDate(campaign.id, ymd);
              break;
            }
            if (firstSealEncounter && mounted) {
              final seal = CharacterSeals.forMission(widget.missionSlug);
              if (seal != null) setState(() => _newSeal = seal);
            }
            // Grava na hora — o debounce de 2s perdia o dia ao reiniciar o app.
            if (mounted) {
              final backend = context.read<BackendService>();
              final league = context.read<LeagueService>();
              final room = context.read<RoomService>().activeCode;
              await backend.saveNow(
                progress,
                LeagueService.weekKey(),
                roomCode: room,
                league: league,
              );
              try {
                final catalog = await TrailRepository().getTrails();
                final profile = CaravanPilgrimProfile.fromProgress(
                  progress: progress,
                  uid: backend.uid ?? '',
                );
                final line = PilgrimMedals.celebrationLine(
                  profile: profile,
                  catalog: catalog,
                  trailSlug: widget.trailSlug,
                  perfect: widget.perfect,
                  ctx: PilgrimMedalEvalContext.fromProgress(progress),
                );
                if (mounted && line != null) {
                  setState(() {
                    _medalLine = line.isNearMiss
                        ? line.actionMessage
                        : line.monitorMessage;
                  });
                }
              } catch (_) {}
            }
            AnalyticsService.instance.logLessonComplete(
              missionSlug: widget.missionSlug,
              trailSlug: widget.trailSlug,
              correct: widget.correct,
              total: widget.total,
              steps: awarded > 0 ? awarded : _awardedSteps,
              isBoss: widget.isBoss,
              isReplay: widget.isReplay,
              perfect: widget.perfect,
            );
            if (!_noProgress && mounted) {
              final corners = context.read<CornerService>();
              await corners.reportMissionComplete(
                progress: progress,
                missionSlug: widget.missionSlug,
                correct: widget.correct,
                total: widget.total,
              );
              // Mostra a travessia desta cena assim que eu chego — fechada
              // ("Chegaram juntos") ou ainda esperando a outra pessoa.
              final uid = context.read<BackendService>().uid ?? '';
              CornerChallenge? closed;
              for (final c in corners.mine) {
                if (c.missionSlug == widget.missionSlug &&
                    c.isThisWeek &&
                    c.iDone(uid)) {
                  closed = c;
                  break;
                }
              }
              if (closed != null &&
                  mounted &&
                  RemoteConfigService.instance.challengeEnabled) {
                setState(() => _closedCorner = closed);
              }
            }
            if (widget.failed) return;
            final ttv = await progress.markFirstLessonIfNeeded(
              trailSlug: widget.trailSlug,
              missionSlug: widget.missionSlug,
            );
            if (ttv != null) {
              unawaited(
                AnalyticsService.instance.logFirstLessonComplete(
                  missionSlug: widget.missionSlug,
                  trailSlug: widget.trailSlug,
                  ttvSeconds: ttv,
                ),
              );
            }
            if (!mounted) return;
            if (progress.goalJustReached) {
              progress.clearGoalJustReached();
            }
            await _resolveModeSuggestion(progress);
          });
    }
  }

  Future<void> _resolveTomorrowHook(ProgressService progress) async {
    if (_hookResolved && _hook != null) return;
    try {
      final catalog = await TrailRepository().getTrails();
      final completed = [
        ...progress.completedMissions,
        if (!progress.completedMissions.contains(widget.missionSlug))
          widget.missionSlug,
      ];
      final hook = TomorrowHook.resolve(
        trails: catalog,
        completed: completed,
        clearedTrailModes: progress.clearedTrailModes,
        justFinishedSlug: widget.missionSlug,
      );
      if (hook == null) {
        if (mounted) setState(() => _hookResolved = true);
        return;
      }
      final hydrated = (await hook.withReaderVerse()).withToday(
        widget.todayInsight,
      );
      await progress.setNextScene(
        title: hydrated.title,
        tease: hydrated.trailer,
        todayInsight: hydrated.todayInsight,
        echoQuestion: hydrated.echoQuestion,
        saveInsight: true,
      );
      if (mounted) {
        setState(() {
          _hook = hydrated;
          _hookResolved = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _hookResolved = true);
    }
  }

  /// Grandes momentos depois que a celebração assenta: marco de sequência
  /// e fim de trilha. Cada um acontece uma vez só, em sequência.
  Future<void> _runSetPieces(ProgressService progress) async {
    final pieces = <SetPiece>[];
    final l10n = context.l10n;

    final streak = progress.streak;
    final goal = progress.settings.streakGoal;
    if (_streakUp &&
        SetPieceMemory.isStreakMilestone(streak, goal: goal) &&
        await SetPieceMemory.claim('streak:$streak')) {
      pieces.add(
        SetPiece(
          eyebrow: l10n.setPieceStreakEyebrow,
          title: l10n.setPieceStreakTitle(streak),
          line: streak == goal
              ? l10n.setPieceStreakGoalLine
              : l10n.setPieceStreakLine(streak),
          glyph: CinematicGlyph.flame,
          light: AppRoles.streak,
          cta: l10n.commonContinue,
          sound: SetPieceSound.streak,
        ),
      );
    }

    final trail = await TrailRepository().getTrailBySlug(widget.trailSlug);
    if (trail != null &&
        TrailProgress.isTrailCompleted(trail, progress.completedMissions)) {
      final banked = trailUsesDifficultyBank(widget.trailSlug);
      final modeId = banked
          ? (progress.difficultyForTrail(widget.trailSlug) ??
                TrailDifficulty.semente.id)
          : null;
      final mode = modeId == null ? null : TrailDifficulty.fromId(modeId);
      if (await SetPieceMemory.claim(
        'trailEnd:${widget.trailSlug}:${modeId ?? 'base'}',
      )) {
        pieces.add(
          SetPiece(
            eyebrow: l10n.setPieceTrailEyebrow,
            title: trail.localizedTitle,
            line: mode == null
                ? l10n.setPieceTrailLineBase
                : l10n.setPieceTrailLine(mode.labelPt),
            glyph: CinematicGlyph.flag,
            light: AppRoles.presence,
            cta: l10n.commonContinue,
            sound: SetPieceSound.crossing,
          ),
        );
      }
    }

    if (pieces.isEmpty) return;
    // Deixa a celebração contar os passos antes de chamar a cena grande.
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    for (final piece in pieces) {
      if (!mounted) return;
      await showSetPiece(context, piece);
    }
  }

  Future<void> _resolveModeSuggestion(ProgressService progress) async {
    if (!trailUsesDifficultyBank(widget.trailSlug)) return;
    await QuestionBank.instance.ensureLoaded();
    if (!QuestionBank.instance.hasBankForTrail(widget.trailSlug)) return;

    final currentId =
        progress.difficultyForTrail(widget.trailSlug) ??
        TrailDifficulty.semente.id;
    final current =
        TrailDifficulty.fromId(currentId) ?? TrailDifficulty.semente;

    final trail = await TrailRepository().getTrailBySlug(widget.trailSlug);
    final complete =
        trail != null &&
        TrailProgress.isTrailCompleted(trail, progress.completedMissions);

    if (complete) {
      await progress.markTrailModeCleared(widget.trailSlug, current.id);
      if (mounted) setState(() => _trailComplete = true);
    }

    // Sugere próximo modo só após concluir a trilha neste modo.
    final next = current.next;
    if (!complete || next == null) return;

    final meta = await QuestionBank.instance.metaFor(next);
    if (!mounted) return;
    setState(() {
      _currentMode = current;
      _nextMode = next;
      _nextMeta = meta;
    });
  }

  Future<void> _acceptNextMode({required bool replayThisStep}) async {
    final next = _nextMode;
    if (next == null) return;
    final progress = context.read<ProgressService>();
    final trail = await TrailRepository().getTrailBySlug(widget.trailSlug);
    if (!mounted) return;
    await progress.setTrailDifficulty(
      widget.trailSlug,
      next.id,
      missionSlugs: trail?.missionSlugs ?? const [],
    );
    if (!mounted) return;

    if (replayThisStep) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonScreen(missionSlug: widget.missionSlug),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TrailMapScreen(slug: widget.trailSlug)),
    );
  }

  String? get _todayLine {
    final fromHook = (_hook?.todayInsight ?? '').trim();
    if (fromHook.isNotEmpty) return fromHook;
    final fromLesson = (widget.todayInsight ?? '').trim();
    return fromLesson.isEmpty ? null : fromLesson;
  }

  /// Cena fechada: a nuvem de sucesso é a origem da chuva.
  /// Selo novo ocupa o topo no lugar dela.
  bool get _cloudRain => !widget.failed && _newSeal == null;

  void _scheduleRainSource() {
    if (_rainLocked || _rainCapturePending || !_cloudRain) return;
    _rainCapturePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rainCapturePending = false;
      if (!mounted || _rainLocked || !_cloudRain) return;
      // Espera a nuvem assentar — o slide de entrada muda a posição na tela.
      if (_entrance.value < 0.62) {
        _scheduleRainSource();
        return;
      }
      final cloud = _cloudKey.currentContext?.findRenderObject() as RenderBox?;
      final stage = _stageKey.currentContext?.findRenderObject() as RenderBox?;
      if (cloud == null || !cloud.hasSize || stage == null || !stage.hasSize) {
        _scheduleRainSource();
        return;
      }
      final y = cloud.size.height * 0.8;
      final left = cloud.localToGlobal(
        Offset(cloud.size.width * 0.04, y),
        ancestor: stage,
      );
      final right = cloud.localToGlobal(
        Offset(cloud.size.width * 0.96, y),
        ancestor: stage,
      );
      setState(() {
        _rainSource = Offset(
          ((left.dx + right.dx) / 2 / stage.size.width).clamp(0.0, 1.0),
          (left.dy / stage.size.height).clamp(0.0, 1.0),
        );
        _rainSpan = ((right.dx - left.dx) / stage.size.width).clamp(0.2, 1.0);
        _rainLocked = true;
      });
    });
  }

  CinematicGlyph get _heroGlyph {
    if (widget.failed) return CinematicGlyph.lamp;
    final seal = _newSeal;
    if (seal != null) return seal.glyph;
    if (widget.perfect) return CinematicGlyph.crown;
    if (widget.isBoss) return CinematicGlyph.podium;
    return CinematicGlyph.check;
  }

  /// Herói por papel: selo, sem erro e Travessia são recompensa; cena
  /// concluída é acerto; cena que não fechou fica neutra.
  Color get _heroAccent {
    if (widget.failed) return AppRoles.chrome;
    return AppRoles.presence;
  }

  String get _kicker {
    if (widget.failed) return CelebrationCopy.failedKicker;
    if (_newSeal != null) return context.l10n.celebrationSealKicker;
    return CelebrationCopy.kicker(
      perfect: widget.perfect,
      isReplay: widget.isReplay,
      isBoss: widget.isBoss,
    );
  }

  String get _headline {
    if (widget.failed) return CelebrationCopy.failedHeadline;
    if (_newSeal != null) return _newSeal!.name;
    return CelebrationCopy.headline(
      perfect: widget.perfect,
      isReplay: widget.isReplay,
      isBoss: widget.isBoss,
    );
  }

  Widget _centerBeat({
    required bool compact,
    required ProgressService progress,
    required bool isBoss,
    required int pct,
  }) {
    if (widget.failed) {
      return MascotBubble(
        face: CloudFace.erro,
        message: CelebrationCopy.failedDetail,
      );
    }
    if (_hook != null) {
      return _TomorrowBeat(
        hook: _hook!,
        compact: compact,
        streak: progress.streak,
        goal: progress.settings.streakGoal,
        reminderHour: progress.settings.reminderHour,
      );
    }
    if (!_hookResolved) {
      return const _TomorrowBeatSkeleton();
    }
    return MascotBubble(
      message: MascotMessages.celebration(
        isBoss: isBoss,
        pct: pct,
        perfect: widget.perfect,
        isReplay: widget.isReplay,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // A festa grava medalhas, missão e sequência em série (vários notify):
    // só reconstrói quando algo que ela mostra muda.
    context.select(
      (ProgressService p) => (
        streak: p.streak,
        streakGoal: p.settings.streakGoal,
        repair: p.showStreakRepairOffer,
        today: p.missionsToday,
        dailyGoal: p.settings.dailyGoal,
        userName: p.userName,
        steps: p.steps,
      ),
    );
    final progress = context.read<ProgressService>();
    final pct = widget.total > 0
        ? ((widget.correct / widget.total) * 100).round()
        : 100;
    final isBoss = widget.isBoss;
    final showModeUp = _nextMode != null && _nextMeta != null;
    final mode = context.select(
      (ProgressService p) => p.settings.appearanceMode,
    );
    final appearance = AppearanceStyle.resolve(mode);
    final heroAccent = _heroAccent;
    if (_cloudRain) _scheduleRainSource();

    return Appearance(
      mode: mode,
      style: appearance,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: appearance.systemOverlay,
        child: Scaffold(
          backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
          body: ImmersiveBackground(
            appearance: appearance,
            child: Stack(
              key: _stageKey,
              fit: StackFit.expand,
              children: [
                // Luz cinematográfica — bloom + raios suaves. Camada própria:
                // respirar a luz não repinta o conteúdo por cima.
                RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_pulse, _heroGlow]),
                    builder: (context, _) {
                      final breath =
                          (math.sin(_pulse.value * math.pi * 2) + 1) / 2;
                      final reveal = _heroGlow.value;
                      return IgnorePointer(
                        child: CustomPaint(
                          painter: _CelebrationAtmospherePainter(
                            accent: heroAccent,
                            gold: AppRoles.presence,
                            breath: breath,
                            reveal: reveal,
                            perfect: widget.perfect,
                            focusY: 0.22,
                          ),
                          size: Size.infinite,
                        ),
                      );
                    },
                  ),
                ),
                if ((_todayLine ?? '').trim().isNotEmpty && !widget.failed)
                  Positioned(
                    left: -4000,
                    top: 0,
                    child: SizedBox(
                      width: 320,
                      height: 320,
                      child: RepaintBoundary(
                        key: _insightShareKey,
                        child: ShareInsightCard(
                          insight: _todayLine!,
                          verseRef: _hook?.hookRef,
                        ),
                      ),
                    ),
                  ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxHeight < 820;
                      // A nuvem cede a altura que falta: em tela baixa,
                      // herói, números, Amanhã e botões cabem sem rolar.
                      final cloudSize = math
                          .min(
                            MediaQuery.sizeOf(context).width * 0.52,
                            constraints.maxHeight * (compact ? 0.2 : 0.24),
                          )
                          .clamp(compact ? 112.0 : 150.0, 228.0);
                      final hero = _HeroBeat(
                        cloudKey: _cloudRain ? _cloudKey : null,
                        cloudSize: cloudSize,
                        glyph: _heroGlyph,
                        accent: heroAccent,
                        perfect: widget.perfect,
                        isBoss: widget.isBoss,
                        compact: compact || (_hook?.hasEcho ?? false),
                        pulse: _pulse,
                        scale: _heroScale,
                        claimScale: _claimScale,
                        kicker: _kicker,
                        headline: _headline,
                        insight: (_hook?.hasEcho ?? false) ? null : _todayLine,
                        medalLine: _medalLine,
                        count: _countProgress,
                        awardedSteps: _awardedSteps,
                        streak: progress.streak,
                        streakFrom: _streakUp ? _streakBefore : null,
                        streakUp: _streakUp,
                        streakGoal: progress.settings.streakGoal,
                        pct: pct,
                        denseStats: true,
                        mascot:
                            widget.failed ||
                                compact ||
                                (_hook?.hasEcho ?? false)
                            ? null
                            : MascotMessages.celebration(
                                isBoss: isBoss,
                                pct: pct,
                                perfect: widget.perfect,
                                isReplay: widget.isReplay,
                              ),
                      );
                      Widget titled(Widget child) => FadeTransition(
                        opacity: _titleOpacity,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: child,
                        ),
                      );
                      final topBlocks = <Widget>[
                        if (_newSeal != null)
                          titled(
                            ScaleTransition(
                              scale: _heroScale,
                              child: RepaintBoundary(
                                key: _sealShareKey,
                                child: ShareSealCard(seal: _newSeal!),
                              ),
                            ),
                          )
                        else
                          for (final block in hero.blocks(context))
                            titled(block),
                        FadeTransition(
                          opacity: _bodyOpacity,
                          child: SlideTransition(
                            position: _bodySlide,
                            child: GlassCard(
                              color: _CelebrationPlate.fill,
                              tint: AppRoles.presence,
                              elevated: true,
                              padding: EdgeInsets.fromLTRB(
                                (_hook?.hasEcho ?? false) ? 22 : 20,
                                (_hook?.hasEcho ?? false)
                                    ? (compact ? 22 : 28)
                                    : (compact ? 16 : 20),
                                (_hook?.hasEcho ?? false) ? 22 : 20,
                                (_hook?.hasEcho ?? false)
                                    ? (compact ? 20 : 24)
                                    : (compact ? 14 : 18),
                              ),
                              child: _centerBeat(
                                compact: compact,
                                progress: progress,
                                isBoss: isBoss,
                                pct: pct,
                              ),
                            ),
                          ),
                        ),
                      ];
                      const pad = EdgeInsets.fromLTRB(24, 8, 24, 12);
                      // Itens espalhados por igual: o mesmo vão entre nuvem,
                      // números, sequência, Amanhã e botões. Se não couber,
                      // rola em vez de cortar.
                      return SingleChildScrollView(
                        padding: pad,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - pad.vertical,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (final block in topBlocks)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: block,
                                ),
                              if (showModeUp && _newSeal == null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: FadeTransition(
                                    opacity: _statsOpacity,
                                    child: SlideTransition(
                                      position: _statsSlide,
                                      child: _ModeUpgradeCard(
                                        trailComplete: _trailComplete,
                                        currentLabel:
                                            _currentMode?.labelPt ??
                                            TrailDifficulty.semente.labelPt,
                                        nextLabel: _nextMeta!.label,
                                        nextSubtitle: _nextMeta!.subtitle,
                                        onTryStep: () => _acceptNextMode(
                                          replayThisStep: true,
                                        ),
                                        onSwitchTrail: _trailComplete
                                            ? () => _acceptNextMode(
                                                replayThisStep: false,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_closedCorner != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _CornerClosedBeat(
                                    challenge: _closedCorner!,
                                    myUid: context.read<BackendService>().uid,
                                  ),
                                ),
                              FadeTransition(
                                opacity: _ctaOpacity,
                                child: SlideTransition(
                                  position: _ctaSlide,
                                  child: Column(
                                    children: [
                                      if (progress.showStreakRepairOffer) ...[
                                        const StreakRepairCelebrationCard(),
                                        const SizedBox(height: AppSpace.md),
                                      ],
                                      // Meta do dia ainda aberta (ritmo 2–3):
                                      // o principal é seguir; "até amanhã"
                                      // vira secundário.
                                      if (widget.failed) ...[
                                        CopperCta(
                                          label: context.l10n.commonTryAgain,
                                          onTap: _retryScene,
                                        ),
                                        const SizedBox(height: 10),
                                        GhostCta(
                                          label:
                                              context.l10n.celebrationBackToMap,
                                          onTap: () => _leaveCelebration(
                                            toTrailMap: true,
                                          ),
                                        ),
                                      ] else if (_hook != null &&
                                          progress.missionsToday <
                                              progress.settings.dailyGoal) ...[
                                        CopperCta(
                                          label: context.l10n.commonNextScene,
                                          onTap: _openTomorrow,
                                        ),
                                        const SizedBox(height: 10),
                                        GhostCta(
                                          label:
                                              context.l10n.celebrationBackHome,
                                          onTap: () => _leaveCelebration(
                                            toTrailMap: false,
                                          ),
                                        ),
                                      ] else ...[
                                        // "Te vejo amanhã" mora no cartão.
                                        CopperCta(
                                          label: !_hookResolved || _hook != null
                                              ? context.l10n.celebrationBackHome
                                              : (EntryTrails.continuesTo
                                                        .containsKey(
                                                          widget.missionSlug,
                                                        )
                                                    ? context
                                                          .l10n
                                                          .commonContinue
                                                    : context
                                                          .l10n
                                                          .celebrationBackToMap),
                                          trailing: null,
                                          onTap: () => _leaveCelebration(
                                            toTrailMap:
                                                _hookResolved && _hook == null,
                                          ),
                                        ),
                                        if (_hook != null) ...[
                                          const SizedBox(height: 10),
                                          GhostCta(
                                            label: context.l10n.commonNextScene,
                                            fill: _CelebrationPlate.fill,
                                            foreground: _CelebrationPlate.ink,
                                            borderColor: _CelebrationPlate.line
                                                .withValues(alpha: 0.55),
                                            onTap: _openTomorrow,
                                          ),
                                        ],
                                      ],
                                      _CelebrationSecondaryRow(
                                        appearance: appearance,
                                        onShareInsight:
                                            (_todayLine ?? '').trim().isEmpty ||
                                                widget.failed
                                            ? null
                                            : () => shareInsightImage(
                                                boundaryKey: _insightShareKey,
                                                insight: _todayLine!,
                                                verseRef: _hook?.hookRef,
                                              ),
                                        onShareSeal: _newSeal == null
                                            ? null
                                            : () => shareSealImage(
                                                boundaryKey: _sealShareKey,
                                                seal: _newSeal!,
                                              ),
                                        shareStreak:
                                            (_todayLine ?? '').trim().isEmpty &&
                                                _newSeal == null &&
                                                progress.streak > 0 &&
                                                !progress.showStreakRepairOffer
                                            ? ShareStreakButton(
                                                streak: progress.streak,
                                                userName: progress.userName,
                                                steps: progress.steps,
                                                asLink: true,
                                              )
                                            : null,
                                        onHome: () => _leaveCelebration(
                                          toTrailMap: false,
                                        ),
                                        hideHome: true,
                                      ),
                                      if ((_trailComplete ||
                                              (_hook?.trailJustCompleted ??
                                                  false)) &&
                                          context
                                              .watch<SubscriptionService>()
                                              .supportConfigured) ...[
                                        const SizedBox(height: 4),
                                        TextCta(
                                          label: context
                                              .l10n
                                              .celebrationHelpContinue,
                                          leading: CinematicGlyph.gift,
                                          color: appearance.textFaint,
                                          onTap: () => openSupport(context),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (!widget.failed && (!_cloudRain || _rainSource != null))
                  ConfettiOverlay(
                    active: true,
                    cinematic: true,
                    source: _cloudRain ? _rainSource : null,
                    sourceSpan: _cloudRain ? _rainSpan : 0,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Placa clara da festa. Acompanha a nuvem; o céu da tela continua escuro.
abstract final class _CelebrationPlate {
  static const fill = Color(0xFFF4F7FB);
  static const ink = AppColors.text;
  static const muted = AppColors.textMuted;
  static const line = Color(0xFF7E96AE);
}

/// Topo da celebração — emblema, vitória e os três cartões da primeira tela.
class _HeroBeat extends StatelessWidget {
  final Key? cloudKey;
  final double cloudSize;
  final CinematicGlyph glyph;
  final Color accent;
  final bool perfect;
  final bool isBoss;
  final bool compact;
  final bool denseStats;
  final AnimationController pulse;
  final Animation<double> scale;
  final Animation<double>? claimScale;
  final String kicker;
  final String headline;
  final String? insight;
  final String? medalLine;
  final Animation<double> count;
  final int awardedSteps;
  final int streak;

  /// Sequência de ontem — quando subiu hoje, o número parte dela.
  final int? streakFrom;
  final bool streakUp;
  final int streakGoal;
  final int pct;
  final String? mascot;

  const _HeroBeat({
    this.cloudKey,
    this.cloudSize = 200,
    required this.glyph,
    required this.accent,
    required this.perfect,
    required this.isBoss,
    required this.compact,
    required this.pulse,
    required this.scale,
    required this.kicker,
    required this.headline,
    required this.count,
    required this.awardedSteps,
    required this.streak,
    required this.streakGoal,
    required this.pct,
    this.claimScale,
    this.streakFrom,
    this.streakUp = false,
    this.denseStats = false,
    this.insight,
    this.medalLine,
    this.mascot,
  });

  /// Os blocos do herói, sem respiro entre eles: a tela de celebração os
  /// espalha por igual na altura (nuvem, números, sequência, recado).
  List<Widget> blocks(BuildContext context) {
    final a = Appearance.of(context);
    final emblemSize = compact ? 72.0 : 118.0;
    final iconSize = compact ? 28.0 : 44.0;
    // Cena fechada — limpa, bônus ou Travessia — é a nuvem. A lâmpada fica
    // só quando a cena não fechou. Título, "Cena limpa" e a linha da
    // medalha saem: a cara já diz o resultado.
    final successCloud = glyph != CinematicGlyph.lamp;
    final showKicker = !successCloud && !perfect && kicker.trim().isNotEmpty;
    return [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: scale,
            child: successCloud
                ? CloudMascot(
                    key: cloudKey,
                    face: CloudFace.sucesso,
                    size: cloudSize,
                  )
                : RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: pulse,
                      builder: (context, child) {
                        final breath =
                            (math.sin(pulse.value * math.pi * 2) + 1) / 2;
                        return _CelebrationEmblem(
                          accent: accent,
                          perfect: perfect,
                          breath: breath,
                          size: emblemSize,
                          child: child!,
                        );
                      },
                      child: RepaintBoundary(
                        child: CinematicIcon(
                          glyph: glyph,
                          size: iconSize,
                          accent: perfect
                              ? AppColors.inkOnAccent
                              : AppColors.night,
                          framed: false,
                        ),
                      ),
                    ),
                  ),
          ),
          if (showKicker) ...[
            SizedBox(height: compact ? 6 : 12),
            SectionLabel(kicker),
          ],
          if (!successCloud) ...[
            SizedBox(height: showKicker ? 6 : (compact ? 8 : 12)),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: AppTypography.display(
                size: compact ? 20 : 28,
                height: 1.12,
                weight: FontWeight.w900,
                color: a.text,
              ),
            ),
          ],
          if ((insight ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              insight!.trim(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w700,
                height: 1.35,
                color: a.textSecondary,
              ),
            ),
          ],
          if (isBoss) ...[
            const SizedBox(height: 10),
            _ComboChip(
              label: context.l10n.crossingChip,
              color: AppRoles.presence,
            ),
          ],
          if (!successCloud && (medalLine ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _MedalProgressLine(text: medalLine!.trim()),
          ],
        ],
      ),
      AnimatedBuilder(
        animation: count,
        builder: (context, _) {
          final t = count.value;
          final stepsShown = (awardedSteps * t).round();
          final from = streakFrom;
          final streakShown = from != null
              ? (from + (streak - from) * t).round()
              : (streak * t).round();
          final pctShown = (pct * t).round();
          return Row(
            children: [
              Expanded(
                child: _StatCard(
                  glyph: CinematicGlyph.path,
                  value: '+$stepsShown',
                  label: context.l10n.celebrationStatSteps,
                  color: AppRoles.reward,
                  dense: denseStats || compact,
                  claimScale: claimScale,
                ),
              ),
              SizedBox(width: denseStats || compact ? 6 : AppSpace.sm),
              Expanded(
                child: _StatCard(
                  glyph: CinematicGlyph.flame,
                  value: '$streakShown',
                  label: streakShown == 1
                      ? context.l10n.celebrationStatDay
                      : context.l10n.celebrationStatDays,
                  color: AppRoles.streak,
                  dense: denseStats || compact,
                ),
              ),
              SizedBox(width: denseStats || compact ? 6 : AppSpace.sm),
              Expanded(
                child: _StatCard(
                  glyph: CinematicGlyph.check,
                  value: '$pctShown%',
                  label: context.l10n.celebrationStatAccuracy,
                  color: AppRoles.success,
                  dense: denseStats || compact,
                ),
              ),
            ],
          );
        },
      ),
      if (streakUp) _StreakIgnite(streak: streak, goal: streakGoal),
      if ((mascot ?? '').trim().isNotEmpty)
        MascotBubble(message: mascot!.trim()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final parts = blocks(context);
    return Column(
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) SizedBox(height: compact ? 10 : 14),
          parts[i],
        ],
      ],
    );
  }
}

/// A chama acende: "+1 dia", a sequência nova e quanto falta para o
/// compromisso firmado no onboarding. Entra depois da contagem, com som.
class _StreakIgnite extends StatefulWidget {
  final int streak;
  final int goal;

  const _StreakIgnite({required this.streak, required this.goal});

  @override
  State<_StreakIgnite> createState() => _StreakIgniteState();
}

class _StreakIgniteState extends State<_StreakIgnite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.scene,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      ActHaptics.success();
      SoundService.instance.playStreak();
      _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String get _line {
    final left = widget.goal - widget.streak;
    final l10n = context.l10n;
    if (widget.streak == 1) return l10n.celebrationStreakStarted;
    if (left == 0) return l10n.celebrationCommitmentDone(widget.goal);
    if (left > 0) return l10n.celebrationCommitmentLeft(left);
    return l10n.celebrationCommitmentBeyond(widget.goal);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final pop = AppMotion.spring.transform(t);
        final glow = math.sin(t * math.pi);
        return Opacity(
          opacity: AppMotion.enter.transform((t * 2).clamp(0.0, 1.0)),
          child: Transform.scale(
            scale: 0.7 + 0.3 * pop,
            child: GlassCard(
              padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
              radius: AppRadii.md,
              tint: AppRoles.streak,
              glow: glow,
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1 + 0.35 * glow,
                    child: const CinematicIcon(
                      glyph: CinematicGlyph.flame,
                      size: AppMetrics.iconLg,
                      accent: AppRoles.streak,
                      framed: false,
                      glowing: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.celebrationStreakPlusDay(widget.streak),
                          style: AppTypography.body(
                            size: 16,
                            weight: FontWeight.w800,
                            color: a.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _line,
                          style: AppTypography.body(
                            size: 13,
                            weight: FontWeight.w600,
                            color: a.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CelebrationSecondaryRow extends StatelessWidget {
  final AppearanceStyle appearance;
  final VoidCallback? onShareInsight;
  final VoidCallback? onShareSeal;
  final Widget? shareStreak;
  final VoidCallback onHome;
  final bool hideHome;

  const _CelebrationSecondaryRow({
    required this.appearance,
    required this.onHome,
    this.onShareInsight,
    this.onShareSeal,
    this.shareStreak,
    this.hideHome = false,
  });

  @override
  Widget build(BuildContext context) {
    final share = onShareInsight != null
        ? TextCta(
            label: context.l10n.celebrationShareInsight,
            leading: CinematicGlyph.share,
            color: appearance.text,
            onTap: onShareInsight,
          )
        : onShareSeal != null
        ? TextCta(
            label: context.l10n.commonShare,
            leading: CinematicGlyph.share,
            color: appearance.text,
            onTap: onShareSeal,
          )
        : shareStreak;

    final home = TextCta(
      label: context.l10n.celebrationBackHome,
      color: appearance.text,
      onTap: onHome,
    );

    if (share == null) {
      if (hideHome) return const SizedBox.shrink();
      return home;
    }

    if (hideHome) return share;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        share,
        Text('·', style: AppTypography.body(color: appearance.textFaint)),
        home,
      ],
    );
  }
}

/// Estrutura do spoiler no primeiro frame — a tela não troca ao hidratar.
class _TomorrowBeatSkeleton extends StatelessWidget {
  const _TomorrowBeatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TomorrowKicker(label: context.l10n.celebrationTomorrowKicker),
        const SizedBox(height: 88),
      ],
    );
  }
}

class _TomorrowKicker extends StatelessWidget {
  final String label;

  const _TomorrowKicker({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: RelicHairline(accent: _CelebrationPlate.line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: SectionLabel(label, size: 12, color: _CelebrationPlate.muted),
        ),
        const Expanded(child: RelicHairline(accent: _CelebrationPlate.line)),
      ],
    );
  }
}

/// Spoiler da próxima cena — centro da mesma tela.
class _TomorrowBeat extends StatelessWidget {
  final TomorrowHook hook;

  /// Tela baixa: título e frase um passo menores, respiros mais curtos.
  final bool compact;
  final int streak;
  final int goal;
  final int reminderHour;

  const _TomorrowBeat({
    required this.hook,
    this.compact = false,
    required this.streak,
    required this.goal,
    required this.reminderHour,
  });

  @override
  Widget build(BuildContext context) {
    if (hook.hasEcho) {
      return _EchoBeat(
        hook: hook,
        streak: streak,
        goal: goal,
        reminderHour: reminderHour,
      );
    }
    final pull = hook.trailer;
    final ref = (hook.hookRef ?? '').trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TomorrowKicker(label: hook.kicker),
        if (hook.trailJustCompleted &&
            (hook.trailTitle ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          SectionLabel(
            hook.trailTitle!.trim(),
            color: _CelebrationPlate.muted,
            size: 10,
          ),
        ] else if (ref.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            ref,
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 11,
              letterSpacing: 1.4,
              color: _CelebrationPlate.muted,
            ),
          ),
        ],
        SizedBox(height: compact ? 10 : 16),
        Text(
          hook.title,
          textAlign: TextAlign.center,
          style: AppTypography.display(
            size: compact ? 24 : 28,
            height: 1.08,
            weight: FontWeight.w900,
            color: _CelebrationPlate.ink,
          ),
        ),
        if (pull.isNotEmpty) ...[
          SizedBox(height: compact ? 8 : 12),
          Text(
            pull,
            textAlign: TextAlign.center,
            style: AppTypography.verse(
              size: compact ? 16 : 18,
              height: compact ? 1.3 : 1.38,
              fontStyle: FontStyle.italic,
              color: _CelebrationPlate.ink,
            ),
          ),
        ],
        SizedBox(height: compact ? 10 : 16),
        Text(
          hook.promiseLine(reminderHour: reminderHour),
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 14,
            weight: FontWeight.w800,
            color: _CelebrationPlate.ink,
          ),
        ),
        if (CommitStrip.visible(streak: streak, goal: goal)) ...[
          SizedBox(height: compact ? 12 : 18),
          CommitStrip(streak: streak, goal: goal),
        ],
      ],
    );
  }
}

/// Cliffhanger bíblico — descoberta de hoje + pergunta aberta + título de amanhã.
class _EchoBeat extends StatelessWidget {
  final TomorrowHook hook;
  final int streak;
  final int goal;
  final int reminderHour;

  const _EchoBeat({
    required this.hook,
    required this.streak,
    required this.goal,
    required this.reminderHour,
  });

  @override
  Widget build(BuildContext context) {
    final planted = (hook.todayInsight ?? '').trim();
    final question = (hook.echoQuestion ?? '').trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TomorrowKicker(label: context.l10n.celebrationEchoKicker),
        const SizedBox(height: 18),
        Text(
          planted,
          textAlign: TextAlign.center,
          style: AppTypography.display(
            size: 28,
            height: 1.18,
            weight: FontWeight.w900,
            color: _CelebrationPlate.ink,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          question,
          textAlign: TextAlign.center,
          style: AppTypography.verse(
            size: 20,
            height: 1.42,
            fontStyle: FontStyle.italic,
            color: _CelebrationPlate.ink,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          hook.promiseLine(reminderHour: reminderHour),
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 16,
            weight: FontWeight.w800,
            color: _CelebrationPlate.ink,
          ),
        ),
        if (CommitStrip.visible(streak: streak, goal: goal)) ...[
          const SizedBox(height: 20),
          CommitStrip(streak: streak, goal: goal),
        ],
      ],
    );
  }
}

/// Emblema herói — anéis de pulso + glow respirando.
class _CelebrationEmblem extends StatelessWidget {
  final Color accent;
  final bool perfect;
  final double breath;
  final double size;
  final Widget child;

  const _CelebrationEmblem({
    required this.accent,
    required this.perfect,
    required this.breath,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = perfect ? AppRoles.reward : accent;
    final ring = size * 0.77;
    final glow = size * 0.70;
    final core = size * 0.67;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 3; i++)
            Transform.scale(
              scale: 0.72 + i * 0.22 + breath * 0.06 * (i + 1),
              child: Container(
                width: ring,
                height: ring,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringColor.withValues(
                      alpha: (0.28 - i * 0.08) * (0.55 + breath * 0.45),
                    ),
                    width: 1.4,
                  ),
                ),
              ),
            ),
          Container(
            width: glow,
            height: glow,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (perfect ? AppRoles.reward : accent).withValues(
                    alpha: 0.1 + breath * 0.04,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: core,
            height: core,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: perfect ? AppRoles.reward : accent,
              boxShadow: AppTheme.glow(
                perfect ? AppRoles.reward : accent,
                blur: 10,
              ),
            ),
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}

/// Atmosfera — bloom central, raios e poeira de luz.
class _CelebrationAtmospherePainter extends CustomPainter {
  final Color accent;
  final Color gold;
  final double breath;
  final double reveal;
  final bool perfect;
  final double focusY;

  _CelebrationAtmospherePainter({
    required this.accent,
    required this.gold,
    required this.breath,
    required this.reveal,
    required this.perfect,
    this.focusY = 0.28,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * focusY);
    final a = reveal.clamp(0.0, 1.0);

    // Bloom principal
    final bloomR = size.width * (0.55 + breath * 0.04);
    canvas.drawCircle(
      center,
      bloomR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            (perfect ? gold : accent).withValues(
              alpha: (0.08 + breath * 0.03) * a,
            ),
            (perfect ? gold : accent).withValues(alpha: 0.03 * a),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: bloomR)),
    );

    // Segundo glow (âmbar / teal)
    final secondary = Offset(size.width * 0.72, size.height * 0.18);
    final secR = size.width * 0.38;
    canvas.drawCircle(
      secondary,
      secR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            gold.withValues(alpha: (0.05 + breath * 0.02) * a),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: secondary, radius: secR)),
    );

    // Raios suaves do herói
    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * (math.pi * 2 / 10) + breath * 0.08;
      final len = size.width * (0.22 + (i.isEven ? 0.1 : 0.04));
      final inner = size.width * 0.09;
      final p1 =
          center + Offset(math.cos(angle) * inner, math.sin(angle) * inner);
      final p2 =
          center +
          Offset(
            math.cos(angle) * (inner + len),
            math.sin(angle) * (inner + len),
          );
      rayPaint.shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.05 * a * (0.5 + breath * 0.2)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromPoints(p1, p2));
      canvas.drawLine(p1, p2, rayPaint);
    }

    // Vinheta inferior — foco no herói
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.18 * a),
            Colors.black.withValues(alpha: 0.42 * a),
          ],
          stops: const [0.35, 0.7, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _CelebrationAtmospherePainter old) =>
      old.breath != breath ||
      old.reveal != reveal ||
      old.accent != accent ||
      old.perfect != perfect ||
      old.focusY != focusY;
}

class _ModeUpgradeCard extends StatelessWidget {
  final bool trailComplete;
  final String currentLabel;
  final String nextLabel;
  final String nextSubtitle;
  final VoidCallback onTryStep;
  final VoidCallback? onSwitchTrail;

  const _ModeUpgradeCard({
    required this.trailComplete,
    required this.currentLabel,
    required this.nextLabel,
    required this.nextSubtitle,
    required this.onTryStep,
    this.onSwitchTrail,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        AppSpace.lg,
        AppSpace.lg,
        AppSpace.section,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            trailComplete
                ? l10n.celebrationModeDone(currentLabel)
                : l10n.celebrationSceneDoneIn(currentLabel),
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 16, color: a.text),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            trailComplete
                ? l10n.celebrationModeRetryPrompt(nextLabel, nextSubtitle)
                : l10n.celebrationModeTryPrompt(nextLabel),
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.35,
              color: a.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpace.md),
          CopperCta(
            label: trailComplete
                ? l10n.celebrationModeReviewCta(nextLabel)
                : l10n.celebrationModeTryCta(nextLabel),
            trailing: null,
            onTap: onTryStep,
          ),
          if (onSwitchTrail != null) ...[
            const SizedBox(height: AppSpace.sm),
            TextCta(
              label: l10n.celebrationModeSwitchCta(nextLabel),
              color: a.textSecondary,
              onTap: onSwitchTrail,
            ),
          ],
        ],
      ),
    );
  }
}

class _CornerClosedBeat extends StatelessWidget {
  final CornerChallenge challenge;
  final String? myUid;

  const _CornerClosedBeat({required this.challenge, this.myUid});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final mine = myUid == null || challenge.iAmChallenger(myUid!)
        ? challenge.challengerName
        : challenge.opponentName;
    final theirs = myUid == null || challenge.iAmChallenger(myUid!)
        ? challenge.opponentName
        : challenge.challengerName;
    return GlassCard(
      padding: AppMetrics.cardPaddingCompact,
      child: Row(
        children: [
          SizedBox(
            width: 22 + AppMetrics.avatarMd * 2,
            height: AppMetrics.avatarMd * 2,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: UserAvatar(
                    name: mine,
                    seed: myUid ?? mine,
                    radius: AppMetrics.avatarMd,
                    style: PortraitStyle.avatar,
                  ),
                ),
                Positioned(
                  left: 22,
                  child: UserAvatar(
                    name: theirs,
                    seed: theirs,
                    radius: AppMetrics.avatarMd,
                    style: PortraitStyle.avatar,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.headline(myUid ?? ''),
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  challenge.subline(myUid ?? ''),
                  style: AppTypography.body(size: 12, color: a.textSecondary),
                ),
                if (challenge.missionTitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    challenge.missionTitle,
                    style: AppTypography.body(size: 11, color: a.textFaint),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedalProgressLine extends StatelessWidget {
  final String text;

  const _MedalProgressLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.label(
        size: 12,
        letterSpacing: 0.35,
        color: AppColors.medalGold.withValues(alpha: 0.88),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final CinematicGlyph glyph;
  final String value;
  final String label;
  final Color color;
  final bool dense;
  final Animation<double>? claimScale;

  const _StatCard({
    required this.glyph,
    required this.value,
    required this.label,
    required this.color,
    this.dense = false,
    this.claimScale,
  });

  @override
  Widget build(BuildContext context) {
    final claim = claimScale;
    Widget card = GlassCard(
      color: _CelebrationPlate.fill,
      padding: EdgeInsets.symmetric(
        vertical: dense ? 8 : AppSpace.section,
        horizontal: dense ? 6 : AppSpace.sm,
      ),
      radius: dense ? AppRadii.sm : AppRadii.md,
      tint: _CelebrationPlate.line,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CinematicIcon(
            glyph: glyph,
            size: dense ? AppMetrics.chipIcon : AppMetrics.iconMd,
            accent: color,
            framed: false,
          ),
          SizedBox(height: dense ? 2 : AppSpace.xs),
          Text(
            value,
            style: AppTypography.title(
              size: dense ? 16 : 20,
              weight: FontWeight.w900,
              color: _CelebrationPlate.ink,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(
              size: 10,
              weight: FontWeight.w600,
              letterSpacing: 0.3,
              color: _CelebrationPlate.muted,
            ),
          ),
        ],
      ),
    );
    if (claim != null) {
      card = AnimatedBuilder(
        animation: claim,
        builder: (context, child) =>
            Transform.scale(scale: claim.value, child: child),
        child: card,
      );
    }
    return card;
  }
}

class _ComboChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ComboChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return SoftBadge(text: label, accent: color, textColor: color);
  }
}
