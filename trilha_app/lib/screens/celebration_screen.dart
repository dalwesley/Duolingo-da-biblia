import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/difficulty.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/difficulty_trails.dart';
import '../utils/mascot_messages.dart';
import '../utils/trail_progress.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/mascot_bubble.dart';
import '../widgets/share_streak_button.dart';
import '../widgets/streak_repair_banner.dart';
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
      final progress = context.read<ProgressService>();
      progress
          .completeMission(
            widget.missionSlug,
            widget.steps,
            isReplay: widget.isReplay,
            correct: widget.correct,
            total: widget.total,
          )
          .then((_) async {
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

    // Sugere próximo modo: ao concluir a trilha, ou após um passo com boa clareza.
    final pct =
        widget.total > 0 ? (widget.correct / widget.total) : 1.0;
    final shouldSuggest = complete || (!widget.isReplay && pct >= 0.6);
    if (!shouldSuggest) return;

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
    await progress.setTrailDifficulty(widget.trailSlug, next.id);
    if (!mounted) return;

    if (replayThisStep) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonScreen(
            missionSlug: widget.missionSlug,
            practiceMode: true,
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.night,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.cosmic),
            ),
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
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
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
                                ? '+1 passo · caminhada perfeita'
                                : widget.isReplay
                                    ? 'Você revisitou este trecho'
                                    : isBoss
                                        ? 'Você avançou no desafio'
                                        : '+1 passo',
                            style: AppTypography.display(size: 28),
                          ),
                          const SizedBox(height: AppSpace.md),
                          MascotBubble(
                            message: widget.isReplay
                                ? MascotMessages.celebration(
                                    isBoss: isBoss,
                                    pct: pct,
                                  )
                                : 'A Palavra iluminou mais um trecho da sua caminhada.\nContinue amanhã.',
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
                                '✦ Meta do dia alcançada. Sua caminhada segue firme.',
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
                                  value: '+${widget.steps}',
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
                    _GoldButton(
                      label: 'CONTINUAR A CAMINHADA',
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
                          color: Colors.white.withValues(alpha: 0.7),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.section),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            trailComplete
                ? 'Modo $currentLabel concluído'
                : 'Bom passo em $currentLabel',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 14, color: Colors.white),
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
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          GestureDetector(
            onTap: onTryStep,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                trailComplete
                    ? 'REVISAR UM PASSO EM ${nextLabel.toUpperCase()}'
                    : 'TENTAR EM ${nextLabel.toUpperCase()}',
                textAlign: TextAlign.center,
                style: AppTypography.cta(size: 12),
              ),
            ),
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
                  color: Colors.white.withValues(alpha: 0.75),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.section, horizontal: AppSpace.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
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
            style: AppTypography.title(size: 16, color: Colors.white),
          ),
          Text(
            label,
            style: AppTypography.label(
              size: 10,
              weight: FontWeight.w600,
              letterSpacing: 0.4,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
        decoration: BoxDecoration(
          gradient: AppGradients.gold,
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.cta(size: 14),
        ),
      ),
    );
  }
}
