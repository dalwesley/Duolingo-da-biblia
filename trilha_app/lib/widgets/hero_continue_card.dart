import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/trail_visuals.dart';
import 'cinematic_icon.dart';

/// Portal da próxima cena — CTA dominante, linguagem de filme bíblico.
class HeroContinueCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final mission = this.mission;
    if (mission == null) return _completedState();

    final visuals = TrailVisuals.forSlug(trailSlug);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.42),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.16),
              blurRadius: 40,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Fundo de cena
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2A1F6B),
                        AppColors.primaryDark,
                        Color.lerp(visuals.accent, AppColors.night, 0.55)!,
                      ],
                    ),
                  ),
                ),
              ),
              // Luz superior
              Positioned(
                right: -40,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -40,
                bottom: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Vinheta
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.4, -0.2),
                      radius: 1.2,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ),
              // Glifo fantasma
              Positioned(
                right: 4,
                top: 12,
                child: Opacity(
                  opacity: 0.4,
                  child: CinematicIcon.mission(
                    mission.title,
                    isBoss: mission.isBoss,
                    size: 100,
                    accent: visuals.accent,
                    glowing: false,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CinematicIcon(
                                glyph: CinematicGlyphResolver.forTrail(trailSlug),
                                size: 20,
                                accent: AppColors.accent,
                                glowing: false,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                trailTitle.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (mission.isBoss) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: AppGradients.gold,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'BOSS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                color: Color(0xFF3D2E00),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'PRÓXIMA CENA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                        color: AppColors.accent.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mission.title,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mission.isBoss
                          ? 'Desafio especial · recompensa maior'
                          : 'Entre na passagem e continue a jornada',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.68),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppGradients.gold,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentDark.withValues(alpha: 0.5),
                                  offset: const Offset(0, 6),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ENTRAR NA CENA',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF3D2E00),
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color(0xFF3D2E00),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            '+${mission.xpReward}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1530), Color(0xFF0D0B1A)],
        ),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        boxShadow: AppTheme.glow(AppColors.accent, blur: 24),
      ),
      child: Column(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.crown,
            size: 64,
            accent: AppColors.accent,
            glowing: true,
          ),
          const SizedBox(height: 16),
          Text(
            'Trilha completa',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sua fidelidade é inspiradora.\nExplore novos mundos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
