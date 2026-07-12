import 'package:flutter/material.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/trail_visuals.dart';
import 'cinematic_icon.dart';

class HeroContinueCard extends StatefulWidget {
  final Mission? mission;
  final String trailTitle;
  final String trailSlug;
  final String trailColor;
  final VoidCallback? onTap;

  const HeroContinueCard({
    super.key,
    required this.mission,
    required this.trailTitle,
    this.trailSlug = 'genesis-1-11',
    this.trailColor = '#6C5CE7',
    this.onTap,
  });

  @override
  State<HeroContinueCard> createState() => _HeroContinueCardState();
}

class _HeroContinueCardState extends State<HeroContinueCard> with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mission == null) return _completedState();

    final mission = widget.mission!;
    final visuals = TrailVisuals.forSlug(widget.trailSlug);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (context, child) {
          final t = _shimmer.value;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: AppGradients.hero,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.12 + 0.08 * (0.5 + 0.5 * (t * 2 - 1).abs())),
                  blurRadius: 36,
                ),
              ],
            ),
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              Positioned(
                right: -36,
                top: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white.withValues(alpha: 0.16), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -50,
                bottom: -60,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppColors.accent.withValues(alpha: 0.18), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Opacity(
                  opacity: 0.55,
                  child: CinematicIcon.mission(
                    mission.title,
                    isBoss: mission.isBoss,
                    size: 88,
                    accent: visuals.accent,
                    glowing: false,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CinematicIcon(
                            glyph: CinematicGlyphResolver.forTrail(widget.trailSlug),
                            size: 22,
                            accent: Colors.white,
                            glowing: false,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.trailTitle,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.92),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      mission.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mission.isBoss ? 'Desafio especial · recompensa maior' : 'Próxima missão da sua jornada',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              gradient: AppGradients.gold,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentDark.withValues(alpha: 0.45),
                                  offset: const Offset(0, 5),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'CONTINUAR',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF3D2E00),
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Color(0xFF3D2E00), size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                          ),
                          child: Text(
                            '+${mission.xpReward}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _completedState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(colors: [AppColors.nightMid, AppColors.night]),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
        boxShadow: AppTheme.glow(AppColors.accent, blur: 20),
      ),
      child: const Column(
        children: [
          Icon(Icons.workspace_premium_rounded, size: 48, color: AppColors.accent),
          SizedBox(height: 12),
          Text('Trilha completa!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          SizedBox(height: 6),
          Text(
            'Sua fidelidade é inspiradora. Explore novas jornadas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMutedDark),
          ),
        ],
      ),
    );
  }
}
