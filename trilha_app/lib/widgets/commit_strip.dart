import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/tomorrow_hook.dart';

/// Semana frágil do compromisso — 7 pontos, o de hoje respira.
class CommitStrip extends StatelessWidget {
  final int streak;
  final int goal;
  final bool showLabel;

  const CommitStrip({
    super.key,
    required this.streak,
    required this.goal,
    this.showLabel = true,
  });

  static bool visible({required int streak, required int goal}) =>
      TomorrowHook.commitLine(streak: streak, goal: goal) != null &&
      streak <= 7;

  @override
  Widget build(BuildContext context) {
    if (!visible(streak: streak, goal: goal)) {
      return const SizedBox.shrink();
    }
    final a = Appearance.of(context);
    final count = goal.clamp(1, 7);
    final label = TomorrowHook.commitLine(streak: streak, goal: goal);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= count; i++) ...[
              if (i > 1) const SizedBox(width: 8),
              _Dot(lit: i <= streak, today: i == streak),
            ],
          ],
        ),
        if (showLabel && label != null) ...[
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.label(
              size: 11,
              letterSpacing: 1.1,
              color: a.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final bool lit;
  final bool today;

  const _Dot({required this.lit, required this.today});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final fill = lit ? AppRoles.streak : a.divider;
    return AnimatedContainer(
      duration: AppMotion.standard,
      width: today ? 12 : 9,
      height: today ? 12 : 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(
          color: today
              ? AppRoles.streak
              : lit
              ? AppRoles.streak.withValues(alpha: 0.35)
              : a.cardBorder,
          width: today ? 2 : 1,
        ),
      ),
    );
  }
}
