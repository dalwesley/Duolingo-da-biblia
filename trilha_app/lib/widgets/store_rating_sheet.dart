import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/store_rating_pace.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'ui_primitives.dart';

/// ID da App Store (apps.apple.com/br/app/stway/id6801332526).
const _appStoreId = '6801332526';

/// Abre a página do app na loja (Play ou App Store). Usada pela folha e
/// pela linha "Avaliar o STWAY" dos Ajustes.
///
/// Vai direto à página da loja, não ao pop-up nativo: depois de um toque
/// em botão, o pop-up pode não aparecer (as lojas limitam quantas vezes
/// ele surge) e o toque ficaria sem resposta.
Future<bool> openStoreRating() async {
  try {
    await InAppReview.instance.openStoreListing(appStoreId: _appStoreId);
    return true;
  } catch (_) {
    return false;
  }
}

/// Convite neutro da Anan para avaliar na loja. Não pergunta se a pessoa
/// gosta do app (a Play proíbe filtrar pela opinião). Ritmo em
/// [StoreRatingPace]; quem chama decide se mostra.
Future<void> showStoreRatingSheet(BuildContext context) async {
  await StoreRatingPace.markShown(DateTime.now());
  if (!context.mounted) return;
  final rated = await showAppSheet<bool>(
    context,
    builder: (_) => const _StoreRatingSheet(),
  );
  if (rated == true) {
    await StoreRatingPace.markRated();
  } else {
    await StoreRatingPace.markDeclined();
  }
}

class _StoreRatingSheet extends StatelessWidget {
  const _StoreRatingSheet();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;

    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            face: CloudFace.feliz,
            center: true,
            eyebrow: l10n.storeRatingEyebrow,
            title: l10n.storeRatingTitle,
            subtitle: l10n.storeRatingBody,
          ),
          const SizedBox(height: AppSpace.lg),
          CopperCta(
            label: l10n.storeRatingCta,
            leading: CinematicGlyph.star,
            trailing: null,
            onTap: () async {
              final ok = await openStoreRating();
              if (!context.mounted) return;
              if (!ok) {
                showAppToastFor(
                  context,
                  message: l10n.storeRatingOpenFailed,
                  glyph: CinematicGlyph.wrong,
                  tone: AppToastTone.warn,
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
          ),
          const SizedBox(height: AppSpace.xs),
          Center(
            child: TextCta(
              label: l10n.commonNotNow,
              color: a.textFaint,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      ),
    );
  }
}
