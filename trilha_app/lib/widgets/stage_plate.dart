import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Palco compartilhado — gestos, entrada da lição e cards da trilha.
class StagePlate extends StatelessWidget {
  final Color accent;
  final Widget child;
  final bool lit;
  final EdgeInsetsGeometry padding;

  const StagePlate({
    super.key,
    required this.accent,
    required this.child,
    this.lit = false,
    this.padding = const EdgeInsets.fromLTRB(22, 20, 22, 22),
  });

  static const radius = 20.0;

  static BoxDecoration decoration({
    required Color accent,
    bool lit = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(AppColors.nightElevated, accent, lit ? 0.18 : 0.07)!,
          AppColors.nightElevated.withValues(alpha: 0.92),
        ],
      ),
      border: Border.all(
        color: lit
            ? accent.withValues(alpha: 0.72)
            : Colors.white.withValues(alpha: 0.10),
        width: lit ? 1.6 : 1,
      ),
      boxShadow: [
        const BoxShadow(
          color: Color(0x80000000),
          blurRadius: 0,
          offset: Offset(0, 5),
        ),
        if (lit)
          BoxShadow(
            color: accent.withValues(alpha: 0.28),
            blurRadius: 28,
            spreadRadius: -6,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: decoration(accent: accent, lit: lit),
      child: child,
    );
  }
}

/// Rótulo de ouro do palco (`PERGUNTA`, `CENA I`, `BAÚS`).
class StageEyebrow extends StatelessWidget {
  final String label;
  final Color accent;
  final TextAlign align;

  const StageEyebrow({
    super.key,
    required this.label,
    required this.accent,
    this.align = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      textAlign: align,
      style: AppTypography.label(
        size: 11,
        letterSpacing: 1.8,
        color: accent,
      ),
    );
  }
}
