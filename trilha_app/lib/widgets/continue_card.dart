import 'package:flutter/material.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';

class ContinueCard extends StatelessWidget {
  final Mission? mission;
  final String trailTitle;
  final String trailIcon;
  final VoidCallback? onTap;

  const ContinueCard({
    super.key,
    required this.mission,
    required this.trailTitle,
    required this.trailIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (mission == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: const Column(
          children: [
            CinematicIcon(glyph: CinematicGlyph.crown, size: 64),
            SizedBox(height: 8),
            Text('Trilha completa!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text(
              'Explore outras trilhas ou aguarde novos conteúdos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Material(
      color: AppColors.success,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: AppColors.successDark, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              CinematicIcon.mission(
                mission!.title,
                isBoss: mission!.isBoss,
                size: 56,
                accent: Colors.white,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONTINUAR · $trailTitle',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      mission!.title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      '+${mission!.xpReward} XP',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
