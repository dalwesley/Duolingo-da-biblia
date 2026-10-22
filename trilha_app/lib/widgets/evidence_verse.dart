import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'ui_primitives.dart';

/// Versículo com o trecho que prova a resposta aceso. Usado no painel do
/// acerto ou erro e nos fatos da placa Hoje.
class EvidenceVerse extends StatelessWidget {
  final String reference;
  final String verse;
  final Color accent;

  /// Trecho que prova a resposta — acende dentro do versículo.
  final String highlight;
  final Color? highlightColor;

  /// Corpo do versículo; o painel do acerto/erro usa maior, para ler fácil.
  final double verseSize;

  const EvidenceVerse({
    super.key,
    required this.reference,
    required this.verse,
    required this.accent,
    this.highlight = '',
    this.highlightColor,
    this.verseSize = 15,
  });

  /// Posição do trecho no versículo, ignorando caixa e pontuação nas bordas.
  (int, int)? _spanRange() {
    final needle = highlight
        .trim()
        .replaceAll(RegExp(r'^[^\p{L}]+|[^\p{L}]+$', unicode: true), '')
        .toLowerCase();
    if (needle.isEmpty) return null;
    final i = verse.toLowerCase().indexOf(needle);
    if (i < 0) return null;
    return (i, i + needle.length);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return InsetPanel(
      borderColor: accent.withValues(alpha: 0.22),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            if (reference.isNotEmpty)
              Text(
                reference,
                textAlign: TextAlign.center,
                style: AppTypography.label(
                  size: verseSize > 15 ? 13 : 11,
                  letterSpacing: 1.2,
                  color: accent,
                ),
              ),
            if (reference.isNotEmpty) const SizedBox(height: 8),
            () {
              final base = AppTypography.verse(
                size: verseSize,
                weight: FontWeight.w600,
                height: 1.4,
                color: a.textSecondary,
              );
              final range = _spanRange();
              if (range == null) {
                return Text(
                  verse,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: base,
                );
              }
              final (start, end) = range;
              final hot = highlightColor ?? accent;
              return Text.rich(
                TextSpan(
                  style: base,
                  children: [
                    TextSpan(text: verse.substring(0, start)),
                    TextSpan(
                      text: verse.substring(start, end),
                      style: base.copyWith(
                        color: a.text,
                        fontWeight: FontWeight.w800,
                        backgroundColor: hot.withValues(alpha: 0.22),
                      ),
                    ),
                    TextSpan(text: verse.substring(end)),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              );
            }(),
          ],
        ),
      ),
    );
  }
}
