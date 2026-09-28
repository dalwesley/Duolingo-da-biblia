import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/entry_trails.dart';
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
import '../widgets/coming_soon_trails_card.dart';
import '../widgets/commit_strip.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/immersive_background.dart';
import '../widgets/invite_qr_sheet.dart';
import '../widgets/mascot_bubble.dart';
import '../widgets/portrait_face.dart';
import '../widgets/share_seal_card.dart';
import '../widgets/share_streak_button.dart';
import '../widgets/streak_repair_banner.dart';
import '../widgets/ui_primitives.dart';
import 'lesson_screen.dart';
import 'trail_map_screen.dart';

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
  bool _firstLessonSession = false;
  bool _leaving = false;
  String? _medalLine;
  CharacterSeal? _newSeal;
  CornerChallenge? _closedCorner;
  final _sealShareKey = GlobalKey();
  TrailDifficulty? _currentMode;
  TrailDifficulty? _nextMode;
  DifficultyMeta? _nextMeta;
  TomorrowHook? _hook;
  bool _hookResolved = false;

  late final AnimationController _entrance;
  late final AnimationController _pulse;
  late final AnimationController _count;

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
    _count = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _heroScale = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );
    _heroGlow = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _titleOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.28, 0.58, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entrance,
            curve: const Interval(0.28, 0.62, curve: Curves.easeOutCubic),
          ),
        );
    _bodyOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.38, 0.68, curve: Curves.easeOut),
    );
    _bodySlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entrance,
            curve: const Interval(0.38, 0.72, curve: Curves.easeOutCubic),
          ),
        );
    _statsOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.48, 0.78, curve: Curves.easeOut),
    );
    _statsSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entrance,
            curve: const Interval(0.48, 0.82, curve: Curves.easeOutCubic),
          ),
        );
    _ctaOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.62, 1.0, curve: Curves.easeOut),
    );
    _ctaSlide = Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entrance,
            curve: const Interval(0.62, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _countProgress = CurvedAnimation(
      parent: _count,
      curve: Curves.easeOutCubic,
    );

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
    if (!_firstLessonSession ||
        progress.companionInviteOffered ||
        hasPartner ||
        companions.companions.isNotEmpty) {
      return;
    }
    final code = await showCompanionInvitePromptSheet(
      context,
      tomorrowTitle: _hook?.title,
    );
    if (!mounted) return;
    if (code == null || code.isEmpty) return;
    await showInviteQrSheet(
      context,
      code: code,
      title: 'Uma companhia na trilha',
      subtitle: 'Um companheiro. Sem ranking — só presença.',
      inviterName: progress.userName,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_saved) {
      _saved = true;
      final progress = context.read<ProgressService>();
      _firstLessonSession =
          progress.firstLessonDate == null || progress.firstLessonDate!.isEmpty;
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
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final campaign = SeasonWalkCatalog.current(today);
            for (final d in campaign.days) {
              if (d.missionSlug != widget.missionSlug) continue;
              final date = d.dateOn(campaign.start);
              if (date.isAfter(today)) continue;
              final ymd =
                  '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
              if (closed != null && mounted) {
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

  CinematicGlyph get _heroGlyph {
    if (widget.failed) return CinematicGlyph.lamp;
    final seal = _newSeal;
    if (seal != null) return seal.glyph;
    if (widget.perfect) return CinematicGlyph.crown;
    if (widget.isBoss) return CinematicGlyph.podium;
    return CinematicGlyph.check;
  }

  Color get _heroAccent {
    if (_newSeal != null) return AppColors.accent;
    if (widget.perfect) return AppColors.accent;
    if (widget.isBoss) return AppColors.primaryLight;
    return AppColors.primary;
  }

  String get _kicker {
    if (widget.failed) return CelebrationCopy.failedKicker;
    if (_newSeal != null) return 'Encontro';
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
    required ProgressService progress,
    required bool isBoss,
    required int pct,
  }) {
    if (widget.failed) {
      return const MascotBubble(
        glowing: true,
        message: CelebrationCopy.failedDetail,
      );
    }
    if (_hook != null) {
      return _TomorrowBeat(
        hook: _hook!,
        streak: progress.streak,
        goal: progress.settings.streakGoal,
      );
    }
    if (!_hookResolved) {
      return const _TomorrowBeatSkeleton();
    }
    return MascotBubble(
      glowing: true,
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
    final progress = context.watch<ProgressService>();
    final pct = widget.total > 0
        ? ((widget.correct / widget.total) * 100).round()
        : 100;
    final isBoss = widget.isBoss;
    final showModeUp = _nextMode != null && _nextMeta != null;
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);
    final heroAccent = _heroAccent;

    return Appearance(
      mode: mode,
      style: appearance,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
          body: ImmersiveBackground(
            appearance: appearance,
            child: Stack(
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
                            gold: AppColors.accent,
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
                ConfettiOverlay(active: !widget.failed, cinematic: true),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxHeight < 780;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          compact ? 8 : 12,
                          24,
                          12,
                        ),
                        child: Column(
                          children: [
                            FadeTransition(
                              opacity: _titleOpacity,
                              child: SlideTransition(
                                position: _titleSlide,
                                child: _newSeal != null
                                    ? ScaleTransition(
                                        scale: _heroScale,
                                        child: RepaintBoundary(
                                          key: _sealShareKey,
                                          child: ShareSealCard(seal: _newSeal!),
                                        ),
                                      )
                                    : _HeroBeat(
                                        glyph: _heroGlyph,
                                        accent: heroAccent,
                                        perfect: widget.perfect,
                                        isBoss: widget.isBoss,
                                        compact:
                                            compact ||
                                            (_hook?.hasEcho ?? false),
                                        pulse: _pulse,
                                        scale: _heroScale,
                                        kicker: _kicker,
                                        headline: _headline,
                                        insight: (_hook?.hasEcho ?? false)
                                            ? null
                                            : _todayLine,
                                        medalLine: _medalLine,
                                        count: _countProgress,
                                        awardedSteps: _awardedSteps,
                                        streak: progress.streak,
                                        streakFrom: _streakUp
                                            ? _streakBefore
                                            : null,
                                        streakUp: _streakUp,
                                        streakGoal:
                                            progress.settings.streakGoal,
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
                                      ),
                              ),
                            ),
                            Expanded(
                              child: FadeTransition(
                                opacity: _bodyOpacity,
                                child: SlideTransition(
                                  position: _bodySlide,
                                  child: Center(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: GlassCard(
                                        accent: true,
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
                                          progress: progress,
                                          isBoss: isBoss,
                                          pct: pct,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
                                          _currentMode?.labelPt ?? 'Observação',
                                      nextLabel: _nextMeta!.label,
                                      nextSubtitle: _nextMeta!.subtitle,
                                      onTryStep: () =>
                                          _acceptNextMode(replayThisStep: true),
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
                                        label: 'Tentar de novo',
                                        onTap: _retryScene,
                                      ),
                                      const SizedBox(height: 10),
                                      GhostCta(
                                        label: 'Voltar ao mapa',
                                        onTap: () =>
                                            _leaveCelebration(toTrailMap: true),
                                      ),
                                    ] else if (_hook != null &&
                                        progress.missionsToday <
                                            progress.settings.dailyGoal) ...[
                                      CopperCta(
                                        label: _hook!.trailJustCompleted
                                            ? 'Continuar no cânon'
                                            : 'Próxima cena',
                                        onTap: _openTomorrow,
                                      ),
                                      const SizedBox(height: 10),
                                      GhostCta(
                                        label: 'Até amanhã',
                                        onTap: () => _leaveCelebration(
                                          toTrailMap: false,
                                        ),
                                      ),
                                    ] else ...[
                                      CopperCta(
                                        label: !_hookResolved || _hook != null
                                            ? 'Até amanhã'
                                            : (EntryTrails.continuesTo
                                                      .containsKey(
                                                        widget.missionSlug,
                                                      )
                                                  ? 'Continuar no cânon'
                                                  : 'Continuar a trilha'),
                                        trailing: null,
                                        onTap: () => _leaveCelebration(
                                          toTrailMap:
                                              _hookResolved && _hook == null,
                                        ),
                                      ),
                                      if (_hook != null) ...[
                                        const SizedBox(height: 10),
                                        GhostCta(
                                          label: _hook!.trailJustCompleted
                                              ? 'Continuar no cânon'
                                              : 'Continuar a trilha',
                                          onTap: _openTomorrow,
                                        ),
                                      ],
                                    ],
                                    _CelebrationSecondaryRow(
                                      appearance: appearance,
                                      onShareSeal: _newSeal == null
                                          ? null
                                          : () => shareSealImage(
                                              boundaryKey: _sealShareKey,
                                              seal: _newSeal!,
                                            ),
                                      shareStreak:
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
                                      onHome: () =>
                                          _leaveCelebration(toTrailMap: false),
                                      hideHome: true,
                                    ),
                                    if (_trailComplete ||
                                        (_hook?.trailJustCompleted ??
                                            false)) ...[
                                      const SizedBox(height: 4),
                                      TextCta(
                                        label: 'Ajude a continuar',
                                        leading: CinematicGlyph.gift,
                                        color: appearance.textFaint,
                                        onTap: openDonatePage,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

/// Topo da celebração — emblema, vitória e os três cartões da primeira tela.
class _HeroBeat extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color accent;
  final bool perfect;
  final bool isBoss;
  final bool compact;
  final bool denseStats;
  final AnimationController pulse;
  final Animation<double> scale;
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
    this.streakFrom,
    this.streakUp = false,
    this.denseStats = false,
    this.insight,
    this.medalLine,
    this.mascot,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final emblemSize = compact ? 72.0 : 118.0;
    final iconSize = compact ? 28.0 : 44.0;
    final inCommit = streak > 0 && streak <= streakGoal;
    // Sem "SEM ERRO" — a headline já celebra a missão.
    final showKicker = !perfect && kicker.trim().isNotEmpty;
    return Column(
      children: [
        ScaleTransition(
          scale: scale,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, child) {
                final breath = (math.sin(pulse.value * math.pi * 2) + 1) / 2;
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
                  accent: perfect ? AppColors.inkOnAccent : Colors.white,
                  framed: false,
                ),
              ),
            ),
          ),
        ),
        if (showKicker) ...[
          SizedBox(height: compact ? 6 : 12),
          SectionLabel(kicker, color: AppColors.accent),
        ],
        SizedBox(height: showKicker ? 6 : (compact ? 8 : 12)),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: AppTypography.display(
            size: compact ? 20 : 28,
            height: 1.12,
            weight: FontWeight.w900,
          ),
        ),
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
          const _ComboChip(label: 'Travessia', color: AppColors.sand),
        ],
        if ((medalLine ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          _MedalProgressLine(text: medalLine!.trim()),
        ],
        SizedBox(height: compact || denseStats ? 10 : 16),
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
                    label: 'Passos',
                    color: AppColors.accent,
                    delay: 0,
                    pulse: pulse,
                    featured: !inCommit,
                    dense: denseStats || compact,
                  ),
                ),
                SizedBox(width: denseStats || compact ? 6 : AppSpace.sm),
                Expanded(
                  child: _StatCard(
                    glyph: CinematicGlyph.flame,
                    value: '$streakShown',
                    label: streakShown == 1 ? 'Dia' : 'Dias',
                    color: AppColors.streak,
                    delay: 0.08,
                    pulse: pulse,
                    featured: inCommit,
                    dense: denseStats || compact,
                  ),
                ),
                SizedBox(width: denseStats || compact ? 6 : AppSpace.sm),
                Expanded(
                  child: _StatCard(
                    glyph: CinematicGlyph.check,
                    value: '$pctShown%',
                    label: 'Clareza',
                    color: AppColors.teal,
                    delay: 0.16,
                    pulse: pulse,
                    dense: denseStats || compact,
                  ),
                ),
              ],
            );
          },
        ),
        if (streakUp) ...[
          SizedBox(height: compact ? 8 : 12),
          _StreakIgnite(streak: streak, goal: streakGoal),
        ],
        if ((mascot ?? '').trim().isNotEmpty) ...[
          SizedBox(height: compact ? 10 : 14),
          MascotBubble(glowing: true, message: mascot!.trim()),
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
    duration: const Duration(milliseconds: 900),
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
    if (widget.streak == 1) return 'Sua sequência começou hoje.';
    if (left == 0) return 'Compromisso de ${widget.goal} dias cumprido!';
    if (left > 0) {
      return left == 1
          ? 'Falta 1 dia para o seu compromisso.'
          : 'Faltam $left dias para o seu compromisso.';
    }
    return 'Além do compromisso de ${widget.goal} dias.';
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final pop = Curves.elasticOut.transform(t);
        final glow = math.sin(t * math.pi);
        return Opacity(
          opacity: Curves.easeOut.transform((t * 2).clamp(0.0, 1.0)),
          child: Transform.scale(
            scale: 0.7 + 0.3 * pop,
            child: GlassCard(
              padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
              radius: AppRadii.md,
              tint: AppColors.streak,
              glow: glow,
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1 + 0.35 * glow,
                    child: const CinematicIcon(
                      glyph: CinematicGlyph.flame,
                      size: 30,
                      accent: AppColors.streak,
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
                          widget.streak == 1
                              ? '+1 dia · sequência de 1 dia'
                              : '+1 dia · sequência de ${widget.streak} dias',
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
  final VoidCallback? onShareSeal;
  final Widget? shareStreak;
  final VoidCallback onHome;
  final bool hideHome;

  const _CelebrationSecondaryRow({
    required this.appearance,
    required this.onHome,
    this.onShareSeal,
    this.shareStreak,
    this.hideHome = false,
  });

  @override
  Widget build(BuildContext context) {
    final share = onShareSeal != null
        ? TextCta(
            label: 'Compartilhar',
            leading: CinematicGlyph.share,
            color: appearance.textSecondary,
            onTap: onShareSeal,
          )
        : shareStreak;

    final home = TextCta(
      label: 'Voltar ao início',
      color: appearance.textSecondary,
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
        const _TomorrowKicker(label: 'Amanhã'),
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
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.accent.withValues(alpha: 0.35),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: SectionLabel(label, color: AppColors.accent, size: 12),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.accent.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }
}

/// Spoiler da próxima cena — centro da mesma tela.
class _TomorrowBeat extends StatelessWidget {
  final TomorrowHook hook;
  final int streak;
  final int goal;

  const _TomorrowBeat({
    required this.hook,
    required this.streak,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    if (hook.hasEcho) {
      return _EchoBeat(hook: hook, streak: streak, goal: goal);
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
          SectionLabel(hook.trailTitle!.trim(), color: a.textFaint, size: 10),
        ] else if (ref.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            ref,
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 11,
              letterSpacing: 1.4,
              color: a.textFaint,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          hook.title,
          textAlign: TextAlign.center,
          style:
              AppTypography.display(
                size: 28,
                height: 1.08,
                weight: FontWeight.w900,
                color: a.text,
              ).copyWith(
                shadows: [
                  Shadow(
                    color: AppColors.accent.withValues(alpha: 0.28),
                    blurRadius: 28,
                  ),
                ],
              ),
        ),
        if (pull.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            pull,
            textAlign: TextAlign.center,
            style: AppTypography.verse(
              size: 18,
              height: 1.38,
              fontStyle: FontStyle.italic,
              color: a.text,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          hook.promiseLine,
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 14,
            weight: FontWeight.w800,
            color: AppColors.accent,
          ),
        ),
        if (CommitStrip.visible(streak: streak, goal: goal)) ...[
          const SizedBox(height: 18),
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

  const _EchoBeat({
    required this.hook,
    required this.streak,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final planted = (hook.todayInsight ?? '').trim();
    final question = (hook.echoQuestion ?? '').trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _TomorrowKicker(label: 'Hoje você viu'),
        const SizedBox(height: 18),
        Text(
          planted,
          textAlign: TextAlign.center,
          style:
              AppTypography.display(
                size: 28,
                height: 1.18,
                weight: FontWeight.w900,
                color: a.text,
              ).copyWith(
                shadows: [
                  Shadow(
                    color: AppColors.accent.withValues(alpha: 0.32),
                    blurRadius: 28,
                  ),
                ],
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
            color: a.text,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          hook.promiseLine,
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 16,
            weight: FontWeight.w800,
            color: AppColors.accent,
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
    final ringColor = perfect ? AppColors.accent : accent;
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
                  (perfect ? AppColors.accent : accent).withValues(
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
              gradient: perfect ? AppGradients.gold : AppGradients.hero,
              boxShadow: AppTheme.glow(
                perfect ? AppColors.accent : accent,
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
    return GlassCard(
      accent: true,
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
                ? 'Modo $currentLabel concluído'
                : 'Cena concluída em $currentLabel',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 16, color: a.text),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            trailComplete
                ? 'Que tal responder de novo em $nextLabel? $nextSubtitle'
                : 'Quer tentar as perguntas desta cena em $nextLabel?',
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
                ? 'Revisar uma cena em $nextLabel'
                : 'Tentar em $nextLabel',
            trailing: null,
            padding: const EdgeInsets.symmetric(vertical: 13),
            onTap: onTryStep,
          ),
          if (onSwitchTrail != null) ...[
            const SizedBox(height: AppSpace.sm),
            TextCta(
              label: 'Mudar a trilha para $nextLabel',
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
      tint: AppColors.accent,
      padding: AppMetrics.cardPaddingCompact,
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 36,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: PortraitFace(
                    name: mine,
                    seed: myUid ?? mine,
                    size: 36,
                    style: PortraitStyle.avatar,
                  ),
                ),
                Positioned(
                  left: 22,
                  child: PortraitFace(
                    name: theirs,
                    seed: theirs,
                    size: 36,
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
  final double delay;
  final AnimationController pulse;
  final bool featured;
  final bool dense;

  const _StatCard({
    required this.glyph,
    required this.value,
    required this.label,
    required this.color,
    required this.delay,
    required this.pulse,
    this.featured = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final phase = (pulse.value + delay) % 1.0;
        final breath = (math.sin(phase * math.pi * 2) + 1) / 2;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            boxShadow: [
              BoxShadow(
                color: color.withValues(
                  alpha: dense ? 0.04 : 0.08 + breath * 0.1,
                ),
                blurRadius: dense ? 6 : 10 + breath * 8,
              ),
            ],
          ),
          // Só a sombra respira; o cartão fica numa camada em cache.
          child: RepaintBoundary(child: child),
        );
      },
      child: GlassCard(
        padding: EdgeInsets.symmetric(
          vertical: dense ? 6 : AppSpace.section,
          horizontal: dense ? 4 : AppSpace.sm,
        ),
        radius: dense ? AppRadii.sm : AppRadii.md,
        accent: featured,
        tint: featured ? color : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CinematicIcon(
              glyph: glyph,
              size: dense ? 14 : 20,
              accent: color,
              framed: false,
              glowing: false,
            ),
            SizedBox(height: dense ? 2 : AppSpace.xs),
            Text(
              value,
              style: AppTypography.title(
                size: dense ? (featured ? 14 : 12) : (featured ? 18 : 16),
                color: featured ? color : a.text,
              ),
            ),
            Text(
              label,
              style: AppTypography.label(
                size: 10,
                weight: FontWeight.w600,
                letterSpacing: 0.3,
                color: a.textFaint,
              ),
            ),
          ],
        ),
      ),
    );
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
