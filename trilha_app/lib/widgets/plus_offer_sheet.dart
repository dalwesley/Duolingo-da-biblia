import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';
import '../screens/paywall_screen.dart';
import '../utils/appearance.dart';
import '../utils/plus_offers.dart';
import 'app_sheet.dart';
import 'ui_primitives.dart';

const _prefsShown = 'plusOffersShown';
const _prefsLastWeek = 'plusOfferLastWeek';

/// Ofertas já vistas e a semana da última, neste aparelho.
Future<({Set<String> shown, String? lastWeek})> loadPlusOfferState() async {
  final prefs = await SharedPreferences.getInstance();
  return (
    shown: (prefs.getStringList(_prefsShown) ?? const <String>[]).toSet(),
    lastWeek: prefs.getString(_prefsLastWeek),
  );
}

Future<void> _markShown(PlusOfferKind kind, String week) async {
  final prefs = await SharedPreferences.getInstance();
  final shown = (prefs.getStringList(_prefsShown) ?? const <String>[]).toSet()
    ..add(kind.name);
  await prefs.setStringList(_prefsShown, shown.toList());
  await prefs.setString(_prefsLastWeek, week);
}

/// Folha de oferta do Peregrino+. Grava como vista ao abrir.
Future<void> showPlusOfferSheet(
  BuildContext context, {
  required PlusOfferKind kind,
  required String week,
  DateTime? promoUntil,
}) async {
  await _markShown(kind, week);
  if (!context.mounted) return;
  await showAppSheet<void>(
    context,
    builder: (_) => _PlusOfferSheet(kind: kind, promoUntil: promoUntil),
  );
}

class _PlusOfferSheet extends StatelessWidget {
  final PlusOfferKind kind;
  final DateTime? promoUntil;

  const _PlusOfferSheet({required this.kind, this.promoUntil});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final date = promoUntil == null
        ? ''
        : DateFormat(
            'd MMM',
            l10n.localeName,
          ).format(promoUntil!).replaceAll('.', '');
    final (title, body) = switch (kind) {
      PlusOfferKind.sevenScenes => (
        l10n.plusOfferScenesTitle(PlusOffers.scenesForOffer),
        l10n.plusOfferScenesBody,
      ),
      PlusOfferKind.promoEndingSoon => (
        l10n.plusOfferEndingTitle(date),
        l10n.plusOfferEndingBody,
      ),
      PlusOfferKind.promoEnded => (
        l10n.plusOfferEndedTitle,
        l10n.plusOfferEndedBody,
      ),
    };

    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(title: title, subtitle: body, center: true),
          const SizedBox(height: 20),
          CopperCta(
            label: l10n.weeklyReviewSeePlus,
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop();
              nav.push(
                MaterialPageRoute<void>(
                  builder: (_) => PaywallScreen(source: kind.source),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          TextCta(
            label: l10n.commonNotNow,
            color: a.textFaint,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
