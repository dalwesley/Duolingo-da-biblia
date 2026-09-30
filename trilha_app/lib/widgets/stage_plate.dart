import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ui_primitives.dart';

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

  static const radius = AppRadii.xl;

  static BoxDecoration decoration({required Color accent, bool lit = false}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: Color.lerp(AppColors.nightElevated, accent, lit ? 0.1 : 0.04),
      border: Border.all(
        color: lit
            ? accent.withValues(alpha: 0.72)
            : AppColors.textOnDark.withValues(alpha: 0.10),
        width: lit ? 1.6 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 0,
          offset: Offset(0, 5),
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
    final text = SectionLabel(label, color: accent);
    return switch (align) {
      TextAlign.center => Center(child: text),
      TextAlign.end => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: text,
      ),
      TextAlign.right => Align(alignment: Alignment.centerRight, child: text),
      _ => text,
    };
  }
}
