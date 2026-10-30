import 'package:flutter/material.dart';
import '../data/trail_art.dart';
import '../l10n/app_language.dart';
import '../models/trail.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'path_preview_sheet.dart';
import 'ui_primitives.dart';

/// O que a pessoa escolheu na folha de uma trilha por vez.
enum OneTrailChoice { keepWalking, plus, leave }

/// Sem o Peregrino+, uma trilha por vez: [target] só começa quando
/// [walking] terminar ou a pessoa sair dela (o que apaga o progresso).
Future<OneTrailChoice?> showOneTrailSheet(
  BuildContext context, {
  required Trail walking,
  required Trail target,
}) {
  final l10n = context.l10n;
  return showAppSheet<OneTrailChoice>(
    context,
    builder: (sheet) => PathPreviewSheet(
      title: l10n.oneTrailTitle,
      description: l10n.oneTrailBody(
        walking.localizedTitle,
        target.localizedTitle,
      ),
      detail: l10n.oneTrailPlusLine,
      art: TrailArt.of(walking.slug),
      eyebrow: l10n.oneTrailEyebrow,
      glyph: CinematicGlyph.path,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CopperCta(
            label: l10n.oneTrailKeep(walking.localizedTitle),
            leading: CinematicGlyph.path,
            expanded: true,
            onTap: () => Navigator.of(sheet).pop(OneTrailChoice.keepWalking),
          ),
          Center(
            child: TextCta(
              label: l10n.plusLockedSheetCta,
              leading: CinematicGlyph.plus,
              onTap: () => Navigator.of(sheet).pop(OneTrailChoice.plus),
            ),
          ),
          Center(
            child: TextCta(
              label: l10n.oneTrailLeave(walking.localizedTitle),
              danger: true,
              onTap: () => Navigator.of(sheet).pop(OneTrailChoice.leave),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Para onde segue quem terminou a trilha do motivo.
enum EntryForkChoice { plus, free }

/// Fim da trilha do motivo, sem o Peregrino+: o destino dela ([plusTrail])
/// é do Plus. Oferece o Plus ou seguir de graça por [freeTrail].
Future<EntryForkChoice?> showEntryForkSheet(
  BuildContext context, {
  required Trail plusTrail,
  required Trail freeTrail,
}) {
  final l10n = context.l10n;
  return showAppSheet<EntryForkChoice>(
    context,
    builder: (sheet) => PathPreviewSheet(
      title: l10n.entryForkTitle,
      description: l10n.entryForkBody(
        plusTrail.localizedTitle,
        freeTrail.localizedTitle,
      ),
      art: TrailArt.of(plusTrail.slug),
      eyebrow: l10n.entryForkEyebrow,
      glyph: CinematicGlyph.path,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CopperCta(
            label: l10n.entryForkPlus(plusTrail.localizedTitle),
            leading: CinematicGlyph.plus,
            expanded: true,
            onTap: () => Navigator.of(sheet).pop(EntryForkChoice.plus),
          ),
          Center(
            child: TextCta(
              label: l10n.entryForkFree(freeTrail.localizedTitle),
              onTap: () => Navigator.of(sheet).pop(EntryForkChoice.free),
            ),
          ),
        ],
      ),
    ),
  );
}
