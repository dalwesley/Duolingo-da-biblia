import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'ui_primitives.dart';

/// Novidades da versão: uma folha, uma vez, na primeira abertura depois de
/// atualizar. Quem acabou de instalar não vê (não há "novo" para essa
/// pessoa). A cada versão com novidades, troque [_release] e [_items].
class WhatsNew {
  WhatsNew._();

  static const _release = '1.0.48';
  static const _key = 'whats_new_seen';

  static List<(CinematicGlyph, String)> _items(AppLocalizations l) => [
    (CinematicGlyph.gift, l.whatsNew148Advent),
    (CinematicGlyph.people, l.whatsNew148Plan),
    (CinematicGlyph.book, l.whatsNew148Study),
    (CinematicGlyph.share, l.whatsNew148Share),
  ];

  /// Laboratório: abre a folha agora, sem mexer na marca.
  static Future<void> preview(BuildContext context) =>
      showAppSheet<void>(context, builder: (_) => const _WhatsNewSheet());

  /// Laboratório: apaga a marca (a folha volta na próxima abertura).
  static Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }

  /// Mostra se esta versão ainda não foi vista por quem já caminhava.
  static Future<void> maybeShow(BuildContext context) async {
    final SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      return;
    }
    final seen = prefs.getString(_key);
    if (seen == _release) return;
    if (!context.mounted) return;
    // O progresso local precisa estar lido para saber se a pessoa já
    // caminhava (senão quem atualiza passaria por quem acabou de instalar).
    final progress = context.read<ProgressService>();
    if (!progress.isLoaded) {
      final ready = Completer<void>();
      void once() {
        if (progress.isLoaded && !ready.isCompleted) ready.complete();
      }

      progress.addListener(once);
      await ready.future.timeout(const Duration(seconds: 10), onTimeout: () {});
      progress.removeListener(once);
      if (!progress.isLoaded || !context.mounted) return;
    }
    // Sem marca: vem de uma versão sem esta folha (mostra a quem já fez
    // alguma cena) ou acabou de instalar (só anota).
    final walked = progress.completedMissions.isNotEmpty;
    await prefs.setString(_key, _release);
    if (seen == null && !walked) return;
    if (!context.mounted) return;
    await showAppSheet<void>(context, builder: (_) => const _WhatsNewSheet());
  }
}

class _WhatsNewSheet extends StatelessWidget {
  const _WhatsNewSheet();

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
            eyebrow: l10n.whatsNewEyebrow,
            title: l10n.whatsNewTitle,
          ),
          const SizedBox(height: AppSpace.lg),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (glyph, text) in WhatsNew._items(l10n))
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CinematicIcon(
                            glyph: glyph,
                            size: AppMetrics.leadingIcon,
                            accent: a.place,
                          ),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: Text(
                              text,
                              style: AppTypography.body(
                                size: 14,
                                height: 1.35,
                                color: a.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          CopperCta(
            label: l10n.commonContinue,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
