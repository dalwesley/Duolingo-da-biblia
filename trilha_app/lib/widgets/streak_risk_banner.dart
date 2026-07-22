import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Banner — o peregrino ficou para trás da caravana até a meia-noite.
class StreakRiskBanner extends StatefulWidget {
  final VoidCallback? onContinue;

  const StreakRiskBanner({super.key, this.onContinue});

  @override
  State<StreakRiskBanner> createState() => _StreakRiskBannerState();
}

class _StreakRiskBannerState extends State<StreakRiskBanner> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    if (!progress.showStreakRiskBanner) return const SizedBox.shrink();

    final a = Appearance.of(context);
    final countdown = progress.streakRiskCountdown;
    final freeze = progress.hasStreakFreeze;

    return GlassCard(
      onTap: widget.onContinue,
      padding: AppMetrics.cardPadding,
      elevated: true,
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.flame,
            size: 44,
            accent: AppColors.streak,
            glowing: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você está ficando para trás',
                  style: AppTypography.title(
                    size: 14,
                    color: a.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  freeze
                      ? 'A caravana segue · faltam $countdown. Um passo alcança — ou o gelo cobre 1 dia.'
                      : 'A caravana segue sem você · faltam $countdown para alcançar o grupo.',
                  style: AppTypography.body(
                    size: 12,
                    height: 1.35,
                    weight: FontWeight.w600,
                    color: a.textMuted(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CinematicIcon(
            glyph: CinematicGlyph.path,
            size: 20,
            accent: AppColors.streak.withValues(alpha: 0.9),
            framed: false,
          ),
        ],
      ),
    );
  }
}

/// Chip do congelamento semanal.
class StreakFreezeChip extends StatelessWidget {
  const StreakFreezeChip({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final used = progress.streakFreezeUsedThisWeek;

    // Sem streak ainda: não polui a home.
    if (progress.streak <= 0 && !used) return const SizedBox.shrink();

    return SoftBadge(
      text: used ? 'Gelo salvou 1 dia' : 'Gelo pronto',
      glyph: CinematicGlyph.frost,
      accent: used ? AppColors.teal : const Color(0xFF7EC8E3),
      bordered: true,
    );
  }
}
