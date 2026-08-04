import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/dust_copy.dart';
import '../utils/spiritual_growth.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'share_streak_button.dart';
import 'ui_primitives.dart';

/// Card da sequência diária — dias seguidos, risco e próximo marco.
class SequenciaCard extends StatefulWidget {
  final VoidCallback? onTap;

  const SequenciaCard({super.key, this.onTap});

  @override
  State<SequenciaCard> createState() => _SequenciaCardState();
}

class _SequenciaCardState extends State<SequenciaCard> {
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
    final a = Appearance.of(context);
    final atRisk = progress.isStreakAtRisk;
    final frozen = progress.streakFreezeUsedThisWeek && !atRisk;
    final growth = SpiritualGrowth.fromSignals(
      streak: progress.streak,
      atRisk: atRisk,
      freezeAvailable: progress.streakFreezeAvailable,
    );

    final accent = atRisk
        ? AppColors.streak
        : frozen
            ? AppColors.ice
            : AppColors.streak;
    final daysLabel =
        progress.streak == 1 ? '1 dia seguido' : '${progress.streak} dias seguidos';
    final status = _statusLine(progress, atRisk: atRisk, frozen: frozen);
    final next = growth.nextStage;
    final daysLeft = growth.daysToNext;

    return GlassCard(
      onTap: widget.onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onTap!();
            },
      elevated: atRisk,
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CinematicIcon(
                glyph: atRisk
                    ? CinematicGlyph.fall
                    : frozen
                        ? CinematicGlyph.frost
                        : CinematicGlyph.flame,
                size: 44,
                accent: accent,
                glowing: atRisk || progress.streak >= 3,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEQUÊNCIA',
                      style: AppTypography.label(
                        size: 10,
                        letterSpacing: 1.4,
                        color: accent.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progress.streak > 0 ? daysLabel : 'Comece hoje',
                      style: AppTypography.display(
                        size: 22,
                        weight: FontWeight.w900,
                        height: 1.1,
                        color: a.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      style: AppTypography.body(
                        size: 13,
                        weight: FontWeight.w700,
                        height: 1.35,
                        color: atRisk
                            ? accent.withValues(alpha: 0.95)
                            : a.textMuted(0.72),
                      ),
                    ),
                  ],
                ),
              ),
              ShareStreakButton(
                streak: progress.streak,
                userName: progress.userName,
                steps: progress.steps,
                compact: true,
              ),
            ],
          ),
          if (next != null && !atRisk) ...[
            const SizedBox(height: 14),
            Text(
              daysLeft == 0
                  ? 'Próximo marco · ${next.label}'
                  : 'Próximo · ${next.label} · faltam $daysLeft '
                      '${daysLeft == 1 ? 'dia' : 'dias'}',
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w800,
                color: a.text.withValues(alpha: 0.88),
              ),
            ),
            const SizedBox(height: 8),
            AppProgressBar(
              value: growth.progressToNext,
              height: AppMetrics.progressHeight,
              color: accent,
              trackColor: accent.withValues(alpha: 0.14),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLine(
    ProgressService progress, {
    required bool atRisk,
    required bool frozen,
  }) {
    if (atRisk) {
      final countdown = progress.streakRiskCountdown;
      if (countdown.isNotEmpty) {
        return DustCopy.heroRiskLine(
          countdown: countdown,
          hasFreeze: progress.hasStreakFreeze,
        );
      }
      return DustCopy.uiRiskLine(hasFreeze: progress.hasStreakFreeze);
    }
    if (frozen) {
      return 'Gelo cobriu 1 dia nesta semana · sequência preservada';
    }
    if (progress.walkedToday) {
      return progress.streakFreezeAvailable
          ? 'Protegida hoje · gelo à postos'
          : 'Protegida hoje · gelo já usado nesta semana';
    }
    if (progress.streak <= 0) {
      return 'Uma missão inicia a sequência';
    }
    return progress.streakFreezeAvailable
        ? 'Em dia · gelo à postos se faltar'
        : 'Em dia · sem gelo nesta semana';
  }
}
