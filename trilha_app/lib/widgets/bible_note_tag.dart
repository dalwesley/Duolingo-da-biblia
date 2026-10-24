import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../models/bible_note.dart';
import '../theme/app_theme.dart';

String bibleNoteTagLabel(BuildContext context, BibleNoteTag tag) {
  final l10n = context.l10n;
  return switch (tag) {
    BibleNoteTag.promessa => l10n.bibleNoteTagPromessa,
    BibleNoteTag.profecia => l10n.bibleNoteTagProfecia,
    BibleNoteTag.jesus => l10n.bibleNoteTagJesus,
    BibleNoteTag.deus => l10n.bibleNoteTagDeus,
    BibleNoteTag.familia => l10n.bibleNoteTagFamilia,
    BibleNoteTag.oracao => l10n.bibleNoteTagOracao,
    BibleNoteTag.mandamento => l10n.bibleNoteTagMandamento,
    BibleNoteTag.pessoal => l10n.bibleNoteTagPessoal,
  };
}

/// Pílula de tema: bolinha na cor + nome. Acesa = fundo e borda na cor.
class BibleNoteTagChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool selected;
  final Color ink;
  final Color idleFill;
  final Color idleBorder;
  final VoidCallback? onTap;

  const BibleNoteTagChip({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.ink,
    required this.idleFill,
    required this.idleBorder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? (c ?? ink).withValues(alpha: 0.18) : idleFill,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? (c ?? ink) : idleBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (c != null) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.label(
                  size: 12,
                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.3,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
