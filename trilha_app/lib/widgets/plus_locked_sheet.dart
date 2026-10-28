import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../screens/paywall_screen.dart';
import 'cinematic_icon.dart';
import 'path_preview_sheet.dart';
import 'ui_primitives.dart';

/// Toque numa trilha ou cena que pede o Peregrino+ (fora da estação em
/// curso): a folha mostra o que é e oferece o Plus. Na estação em curso o
/// botão amarelo já leva direto à compra.
Future<void> showPlusLockedSheet(
  BuildContext context, {
  required String title,
  required String description,
  required String source,
  String? art,
  String? eyebrow,
  Color? accent,
  CinematicGlyph? glyph,
  List<String> chips = const [],
}) {
  final l10n = context.l10n;
  return showPathPreviewSheet(
    context,
    title: title,
    description: description,
    detail: l10n.plusLockedSheetBody,
    art: art,
    eyebrow: eyebrow,
    accent: accent,
    glyph: glyph,
    chips: chips,
    footer: Builder(
      builder: (sheet) => CopperCta(
        label: l10n.plusLockedSheetCta,
        leading: CinematicGlyph.plus,
        expanded: true,
        onTap: () {
          Navigator.of(sheet).pop();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PaywallScreen(source: source),
            ),
          );
        },
      ),
    ),
  );
}
