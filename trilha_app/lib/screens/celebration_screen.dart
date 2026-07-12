import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/mascot_messages.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/mascot_bubble.dart';
import '../widgets/share_streak_button.dart';
import 'trail_map_screen.dart';

class CelebrationScreen extends StatefulWidget {
  final String missionSlug;
  final int xp;
  final int correct;
  final int total;
  final String trailSlug;
  final bool isBoss;
  final bool isReplay;
  final bool perfect;

  const CelebrationScreen({
    super.key,
    required this.missionSlug,
    required this.xp,
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

class _CelebrationScreenState extends State<CelebrationScreen> with SingleTickerProviderStateMixin {
  bool _saved = false;
  bool _showGoalBanner = false;
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _anim, curve: const Interval(0.2, 1, curve: Curves.easeOut));
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
            widget.xp,
            isReplay: widget.isReplay,
            correct: widget.correct,
            total: widget.total,
          )
          .then((_) {
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final pct = widget.total > 0 ? ((widget.correct / widget.total) * 100).round() : 100;
    final isBoss = widget.isBoss;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.night,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.cosmic)),
            const ConfettiOverlay(active: true),
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppColors.accent.withValues(alpha: 0.25), Colors.transparent]),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white),
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
                          gradient: widget.perfect ? AppGradients.gold : AppGradients.hero,
                          boxShadow: AppTheme.glow(widget.perfect ? AppColors.accent : AppColors.primary, blur: 28),
                        ),
                        child: Icon(
                          widget.perfect
                              ? Icons.workspace_premium_rounded
                              : isBoss
                                  ? Icons.military_tech_rounded
                                  : Icons.auto_awesome_rounded,
                          size: 52,
                          color: widget.perfect ? const Color(0xFF3D2E00) : Colors.white,
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
                                ? 'Missão perfeita!'
                                : widget.isReplay
                                    ? 'Revisão concluída'
                                    : isBoss
                                        ? 'Desafio vencido!'
                                        : 'Missão completa!',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          MascotBubble(
                            message: MascotMessages.celebration(isBoss: isBoss, pct: pct),
                          ),
                          if (_showGoalBanner) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: AppGradients.gold,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Text(
                                '✦ Meta diária alcançada! Sua sequência está viva.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF3D2E00)),
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.auto_awesome_rounded,
                                  value: '+${widget.xp}',
                                  label: 'XP',
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.local_fire_department_rounded,
                                  value: '${progress.streak}',
                                  label: 'Sequência',
                                  color: AppColors.streak,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.check_circle_rounded,
                                  value: '$pct%',
                                  label: 'Acertos',
                                  color: AppColors.teal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (progress.streak > 0) ...[
                      ShareStreakButton(
                        streak: progress.streak,
                        userName: progress.userName,
                        xp: progress.xp,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _GoldButton(
                      label: 'CONTINUAR TRILHA',
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => TrailMapScreen(slug: widget.trailSlug)),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                      child: Text(
                        'Voltar ao início',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w700),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.55))),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppGradients.gold,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.accentDark.withValues(alpha: 0.5), offset: const Offset(0, 4))],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF3D2E00), letterSpacing: 0.5),
        ),
      ),
    );
  }
}
