import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Linha de navegação dos quadros ([ProfileSection]): ícone no poço redondo
/// na cor da linha, título, subtítulo e seta — o mesmo desenho das linhas
/// de Ajustes.
class AppNavRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final CinematicGlyph glyph;
  final Color? accent;
  final VoidCallback? onTap;

  /// No lugar da seta (selo "Ativo", cadeado, valor).
  final Widget? trailing;

  /// No lugar do ícone (avatar, interruptor).
  final Widget? leading;

  /// Título em outra cor (ex.: ação de risco).
  final Color? titleColor;

  const AppNavRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.glyph,
    this.accent,
    this.onTap,
    this.trailing,
    this.leading,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Row(
              children: [
                leading ??
                    CinematicIcon(
                      glyph: glyph,
                      size: AppMetrics.leadingIcon,
                      accent: accent ?? a.place,
                      glowing: false,
                    ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.title(
                          size: 14,
                          color: titleColor ?? a.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.body(
                          size: 12,
                          color: a.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                trailing ??
                    (onTap == null
                        ? const SizedBox.shrink()
                        : ListChevron(color: a.textFaint)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Divisória curta entre [AppNavRow]s, como nos Ajustes.
class AppNavDivider extends StatelessWidget {
  const AppNavDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpace.xs),
      child: ListDivider(),
    );
  }
}
