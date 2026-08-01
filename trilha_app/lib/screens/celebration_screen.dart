import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/difficulty.dart';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
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
import '../widgets/confetti_overlay.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/mascot_bubble.dart';
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
  });

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen>
    with TickerProviderStateMixin {
  bool _saved = false;
  bool _showGoalBanner = false;
  bool _trailComplete = false;
  int _awardedSteps = 0;
  TrailDifficulty? _currentMode;
  TrailDifficulty? _nextMode;
  DifficultyMeta? _nextMeta;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_saved) {
      _saved = true;
      _awardedSteps = widget.isReplay
          ? (widget.steps * 0.35).round().clamp(5, widget.steps)
          : widget.steps;
      final progress = context.read<ProgressService>();
      progress
          .completeMission(
            widget.missionSlug,
            widget.steps,
            isReplay: widget.isReplay,
            correct: widget.correct,
            total: widget.total,
          )
          .then((awarded) async {
            if (mounted && awarded > 0) {
              setState(() => _awardedSteps = awarded);
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
            if (!mounted) return;
            if (widget.perfect) {
              SoundService.instance.playStreak();
            } else {
              SoundService.instance.playComplete(boss: widget.isBoss);
            }
            if (progress.goalJustReached) {
              setState(() => _showGoalBanner = true);
              progress.clearGoalJustReached();
            }
            await _resolveModeSuggestion(progress);
          });
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
    final next = current.next;
    if (next == null) return;

    final trail = await TrailRepository().getTrailBySlug(widget.trailSlug);
    final complete =
        trail != null &&
        TrailProgress.isTrailCompleted(trail, progress.completedMissions);

    if (complete) {
      await progress.markTrailModeCleared(widget.trailSlug, current.id);
    }

    // Sugere próximo modo só após concluir a trilha neste modo.
    if (!complete) return;

    final meta = await QuestionBank.instance.metaFor(next);
    if (!mounted) return;
    setState(() {
      _trailComplete = complete;
      _currentMode = current;
      _nextMode = next;
      _nextMeta = meta;
    });
  }

  Future<void> _acceptNextMode({required bool replayThisStep}) async {
    final next = _nextMode;
    if (next == null) return;
    HapticFeedback.mediumImpact();
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

  CinematicGlyph get _heroGlyph {
    if (widget.perfect) return CinematicGlyph.crown;
    if (widget.isBoss) return CinematicGlyph.podium;
    return CinematicGlyph.check;
  }

  Color get _heroAccent {
    if (widget.perfect) return AppColors.accent;
    if (widget.isBoss) return AppColors.primaryLight;
    return AppColors.primary;
  }

  String get _headline {
    if (widget.perfect) return '+1 passo · lição perfeita';
    if (widget.isReplay) return 'Você revisitou esta lição';
    if (widget.isBoss) return 'Desafio concluído';
    return 'Missão concluída';
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
                // Luz cinematográfica — bloom + raios suaves
                AnimatedBuilder(
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
                        ),
                        size: Size.infinite,
                      ),
                    );
                  },
                ),
                const ConfettiOverlay(active: true, cinematic: true),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpace.xxl),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        ScaleTransition(
                          scale: _heroScale,
                          child: AnimatedBuilder(
                            animation: _pulse,
                            builder: (context, child) {
                              final breath =
                                  (math.sin(_pulse.value * math.pi * 2) + 1) /
                                  2;
                              return _HeroEmblem(
                                accent: heroAccent,
                                perfect: widget.perfect,
                                breath: breath,
                                child: child!,
                              );
                            },
                            child: CinematicIcon(
                              glyph: _heroGlyph,
                              size: 54,
                              accent: widget.perfect
                                  ? AppColors.inkOnAccent
                                  : Colors.white,
                              framed: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        FadeTransition(
                          opacity: _titleOpacity,
                          child: SlideTransition(
                            position: _titleSlide,
                            child: Text(
                              _headline,
                              textAlign: TextAlign.center,
                              style: AppTypography.display(
                                size: 30,
                                height: 1.05,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpace.md),
                        FadeTransition(
                          opacity: _bodyOpacity,
                          child: SlideTransition(
                            position: _bodySlide,
                            child: Column(
                              children: [
                                MascotBubble(
                                  message: MascotMessages.celebration(
                                    isBoss: isBoss,
                                    pct: pct,
                                  ),
                                ),
                                if (_showGoalBanner) ...[
                                  const SizedBox(height: AppSpace.section),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(
                                      AppSpace.section,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.gold,
                                      borderRadius: BorderRadius.circular(
                                        AppRadii.md,
                                      ),
                                      boxShadow: AppTheme.glow(
                                        AppColors.accent,
                                        blur: 22,
                                      ),
                                    ),
                                    child: Text(
                                      '✦ Meta do dia alcançada. Sequência protegida.',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.body(
                                        size: 13,
                                        weight: FontWeight.w900,
                                        color: AppColors.inkOnAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        FadeTransition(
                          opacity: _statsOpacity,
                          child: SlideTransition(
                            position: _statsSlide,
                            child: AnimatedBuilder(
                              animation: _countProgress,
                              builder: (context, _) {
                                final t = _countProgress.value;
                                final stepsShown = (_awardedSteps * t).round();
                                final streakShown = (progress.streak * t)
                                    .round();
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
                                        pulse: _pulse,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpace.sm),
                                    Expanded(
                                      child: _StatCard(
                                        glyph: CinematicGlyph.flame,
                                        value: '$streakShown',
                                        label: 'Dias',
                                        color: AppColors.streak,
                                        delay: 0.08,
                                        pulse: _pulse,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpace.sm),
                                    Expanded(
                                      child: _StatCard(
                                        glyph: CinematicGlyph.check,
                                        value: '$pctShown%',
                                        label: 'Clareza',
                                        color: AppColors.teal,
                                        delay: 0.16,
                                        pulse: _pulse,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        if (showModeUp) ...[
                          const SizedBox(height: AppSpace.lg),
                          FadeTransition(
                            opacity: _statsOpacity,
                            child: _ModeUpgradeCard(
                              trailComplete: _trailComplete,
                              currentLabel: _currentMode?.labelPt ?? 'Semente',
                              nextLabel: _nextMeta!.label,
                              nextSubtitle: _nextMeta!.subtitle,
                              onTryStep: () =>
                                  _acceptNextMode(replayThisStep: true),
                              onSwitchTrail: _trailComplete
                                  ? () => _acceptNextMode(replayThisStep: false)
                                  : null,
                            ),
                          ),
                        ],
                        if (progress.showStreakRepairOffer) ...[
                          const SizedBox(height: AppSpace.lg),
                          FadeTransition(
                            opacity: _statsOpacity,
                            child: const StreakRepairCelebrationCard(),
                          ),
                        ],
                        const Spacer(flex: 3),
                        FadeTransition(
                          opacity: _ctaOpacity,
                          child: SlideTransition(
                            position: _ctaSlide,
                            child: Column(
                              children: [
                                if (progress.streak > 0) ...[
                                  ShareStreakButton(
                                    streak: progress.streak,
                                    userName: progress.userName,
                                    steps: progress.steps,
                                  ),
                                  const SizedBox(height: AppSpace.md),
                                ],
                                AnimatedBuilder(
                                  animation: _pulse,
                                  builder: (context, child) {
                                    final breath =
                                        (math.sin(_pulse.value * math.pi * 2) +
                                            1) /
                                        2;
                                    return DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.lg,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.accent.withValues(
                                              alpha: 0.18 + breath * 0.14,
                                            ),
                                            blurRadius: 18 + breath * 10,
                                            spreadRadius: breath * 1.5,
                                          ),
                                        ],
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: CopperCta(
                                    label: 'CONTINUAR A CAMINHADA',
                                    trailing: null,
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => TrailMapScreen(
                                            slug: widget.trailSlug,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: AppSpace.sm),
                                TextButton(
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).popUntil((r) => r.isFirst),
                                  child: Text(
                                    'Voltar ao início',
                                    style: AppTypography.body(
                                      weight: FontWeight.w700,
                                      color: appearance.textMuted(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

/// Emblema herói — anéis de pulso + glow respirando.
class _HeroEmblem extends StatelessWidget {
  final Color accent;
  final bool perfect;
  final double breath;
  final Widget child;

  const _HeroEmblem({
    required this.accent,
    required this.perfect,
    required this.breath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = perfect ? AppColors.accent : accent;
    return SizedBox(
      width: 168,
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 3; i++)
            Transform.scale(
              scale: 0.72 + i * 0.22 + breath * 0.06 * (i + 1),
              child: Container(
                width: 130,
                height: 130,
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
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (perfect ? AppColors.accentBright : accent).withValues(
                    alpha: 0.22 + breath * 0.1,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: perfect ? AppGradients.gold : AppGradients.hero,
              boxShadow: [
                ...AppTheme.glow(
                  perfect ? AppColors.accent : accent,
                  blur: 32 + breath * 12,
                ),
                BoxShadow(
                  color: (perfect ? AppColors.accent : accent).withValues(
                    alpha: 0.35 + breath * 0.2,
                  ),
                  blurRadius: 28 + breath * 16,
                  spreadRadius: 2,
                ),
              ],
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

  _CelebrationAtmospherePainter({
    required this.accent,
    required this.gold,
    required this.breath,
    required this.reveal,
    required this.perfect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.28);
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
              alpha: (0.22 + breath * 0.08) * a,
            ),
            (perfect ? gold : accent).withValues(alpha: 0.06 * a),
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
            gold.withValues(alpha: (0.12 + breath * 0.05) * a),
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
          Colors.white.withValues(alpha: 0.18 * a * (0.6 + breath * 0.4)),
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
      old.perfect != perfect;
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
                : 'Bom passo em $currentLabel',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 14, color: a.text),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            trailComplete
                ? 'Que tal responder de novo em $nextLabel? $nextSubtitle'
                : 'Quer tentar as perguntas deste passo em $nextLabel?',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.35,
              color: a.textMuted(0.72),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          CopperCta(
            label: trailComplete
                ? 'REVISAR UM PASSO EM $nextLabel'
                : 'TENTAR EM $nextLabel',
            trailing: null,
            padding: const EdgeInsets.symmetric(vertical: 13),
            onTap: onTryStep,
          ),
          if (onSwitchTrail != null) ...[
            const SizedBox(height: AppSpace.sm),
            TextButton(
              onPressed: onSwitchTrail,
              child: Text(
                'Mudar a trilha para $nextLabel',
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: a.textMuted(0.75),
                ),
              ),
            ),
          ],
        ],
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

  const _StatCard({
    required this.glyph,
    required this.value,
    required this.label,
    required this.color,
    required this.delay,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final phase = ((pulse.value + delay) % 1.0);
        final breath = (math.sin(phase * math.pi * 2) + 1) / 2;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08 + breath * 0.1),
                blurRadius: 10 + breath * 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpace.section,
          horizontal: AppSpace.sm,
        ),
        radius: AppRadii.md,
        child: Column(
          children: [
            CinematicIcon(
              glyph: glyph,
              size: 20,
              accent: color,
              framed: false,
              glowing: false,
            ),
            const SizedBox(height: AppSpace.xs),
            Text(value, style: AppTypography.title(size: 16, color: a.text)),
            Text(
              label,
              style: AppTypography.label(
                size: 10,
                weight: FontWeight.w600,
                letterSpacing: 0.4,
                color: a.textMuted(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
