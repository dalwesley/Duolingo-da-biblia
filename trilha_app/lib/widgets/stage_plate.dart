import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'ui_primitives.dart';

/// Palco compartilhado — gestos, entrada da lição e cards da trilha.
class StagePlate extends StatelessWidget {
  final Color accent;
  final Widget child;
  final bool lit;
  final bool tint;
  final EdgeInsetsGeometry padding;

  const StagePlate({
    super.key,
    required this.accent,
    required this.child,
    this.lit = false,
    this.tint = false,
    this.padding = const EdgeInsets.fromLTRB(22, 20, 22, 22),
  });

  static const radius = AppRadii.xl;

  /// [tint]: luz do modo — o tom do modo desce de cima no palco e acende
  /// a borda (gestos da cena). Sem [tint], o palco fica neutro.
  static BoxDecoration decoration({
    required Color accent,
    bool lit = false,
    bool tint = false,
    AppearanceStyle? style,
  }) {
    final fill = style?.stageFill ?? AppColors.nightElevated;
    final onDark = style?.onDark ?? true;
    if (tint && !lit) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(fill, accent, onDark ? 0.14 : 0.08)!,
            Color.lerp(fill, accent, 0.03)!,
          ],
        ),
        border: Border.all(
          color: accent.withValues(alpha: onDark ? 0.42 : 0.32),
          width: 1.2,
        ),
        boxShadow: [
          ...AppLight.shadow(elevated: true),
          BoxShadow(
            color: accent.withValues(alpha: onDark ? 0.16 : 0.10),
            blurRadius: 28,
            spreadRadius: -6,
          ),
        ],
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: Color.lerp(fill, accent, lit ? 0.1 : 0.04),
      border: Border.all(
        color: lit
            ? accent.withValues(alpha: 0.72)
            : (onDark ? AppColors.textOnDark : AppColors.text).withValues(
                alpha: 0.10,
              ),
        width: lit ? 1.6 : 1,
      ),
      boxShadow: AppLight.shadow(elevated: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: decoration(
        accent: accent,
        lit: lit,
        tint: tint,
        style: Appearance.of(context),
      ),
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
