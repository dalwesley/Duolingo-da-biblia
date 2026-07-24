import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/difficulty.dart';
import '../services/analytics_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
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
    with SingleTickerProviderStateMixin {
  bool _saved = false;
  bool _showGoalBanner = false;
  bool _trailComplete = false;
  int _awardedSteps = 0;
  TrailDifficulty? _currentMode;
  TrailDifficulty? _nextMode;
  DifficultyMeta? _nextMeta;
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.2, 1, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
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
        progress.difficultyForTrail(widget.trailSlug) ?? TrailDifficulty.semente.id;
    final current = TrailDifficulty.fromId(currentId) ?? TrailDifficulty.semente;
    final next = current.next;
    if (next == null) return;

    final trail = await TrailRepository().getTrailBySlug(widget.trailSlug);
    final complete = trail != null &&
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
          builder: (_) => LessonScreen(
            missionSlug: widget.missionSlug,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TrailMapScreen(slug: widget.trailSlug),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final pct =
        widget.total > 0 ? ((widget.correct / widget.total) * 100).round() : 100;
    final isBoss = widget.isBoss;
    final showModeUp = _nextMode != null && _nextMeta != null;
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

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
                const ConfettiOverlay(active: true),
                Positioned(
                  top: -80,
                  right: -60,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.xxl),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: appearance.cardFillSoft,
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: appearance.text,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: widget.perfect
                              ? AppGradients.gold
                              : AppGradients.hero,
                          boxShadow: AppTheme.glow(
                            widget.perfect
                                ? AppColors.accent
                                : AppColors.primary,
                            blur: 28,
                          ),
                        ),
                        child: Center(
                          child: CinematicIcon(
                            glyph: widget.perfect
                                ? CinematicGlyph.crown
                                : isBoss
                                    ? CinematicGlyph.podium
                                    : CinematicGlyph.spark,
                            size: 52,
                            accent: widget.perfect
                                ? AppColors.inkOnAccent
                                : Colors.white,
                            framed: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fade,
                      child: Column(
                        children: [
                          Text(
                            widget.perfect
                                ? '+1 passo · lição perfeita'
                                : widget.isReplay
                                    ? 'Você revisitou esta lição'
                                    : isBoss
                                        ? 'Desafio concluído'
                                        : 'Missão concluída',
                            style: AppTypography.display(size: 28),
                          ),
                          const SizedBox(height: AppSpace.md),
                          MascotBubble(
                            message: widget.isReplay
                                ? MascotMessages.celebration(
                                    isBoss: isBoss,
                                    pct: pct,
                                  )
                                : MascotMessages.celebration(
                                    isBoss: isBoss,
                                    pct: pct,
                                  ),
                          ),
                          if (_showGoalBanner) ...[
                            const SizedBox(height: AppSpace.section),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpace.section),
                              decoration: BoxDecoration(
                                gradient: AppGradients.gold,
                                borderRadius: BorderRadius.circular(AppRadii.md),
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
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  glyph: CinematicGlyph.path,
                                  value: '+$_awardedSteps',
                                  label: 'Passos',
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: AppSpace.sm),
                              Expanded(
                                child: _StatCard(
                                  glyph: CinematicGlyph.flame,
                                  value: '${progress.streak}',
                                  label: 'Dias',
                                  color: AppColors.streak,
                                ),
                              ),
                              const SizedBox(width: AppSpace.sm),
                              Expanded(
                                child: _StatCard(
                                  glyph: CinematicGlyph.check,
                                  value: '$pct%',
                                  label: 'Clareza',
                                  color: AppColors.teal,
                                ),
                              ),
                            ],
                          ),
                          if (showModeUp) ...[
                            const SizedBox(height: AppSpace.lg),
                            _ModeUpgradeCard(
                              trailComplete: _trailComplete,
                              currentLabel:
                                  _currentMode?.labelPt ?? 'Semente',
                              nextLabel: _nextMeta!.label,
                              nextSubtitle: _nextMeta!.subtitle,
                              onTryStep: () =>
                                  _acceptNextMode(replayThisStep: true),
                              onSwitchTrail: _trailComplete
                                  ? () => _acceptNextMode(replayThisStep: false)
                                  : null,
                            ),
                          ],
                          if (progress.showStreakRepairOffer) ...[
                            const SizedBox(height: AppSpace.lg),
                            const StreakRepairCelebrationCard(),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (progress.streak > 0) ...[
                      ShareStreakButton(
                        streak: progress.streak,
                        userName: progress.userName,
                        steps: progress.steps,
                      ),
                      const SizedBox(height: AppSpace.md),
                    ],
                    CopperCta(
                      label: 'CONTINUAR A CAMINHADA',
                      trailing: null,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) =>
                                TrailMapScreen(slug: widget.trailSlug),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpace.sm),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
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
      ),
    );
  }
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
      padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.section),
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

  const _StatCard({
    required this.glyph,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.section, horizontal: AppSpace.sm),
      radius: AppRadii.md,
      child: Column(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: 20,
            accent: color,
            framed: false,
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            value,
            style: AppTypography.title(size: 16, color: a.text),
          ),
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
    );
  }
}
