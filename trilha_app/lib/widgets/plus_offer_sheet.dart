import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';
import '../screens/paywall_screen.dart';
import '../screens/plus_promo_notice_screen.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/plus_offers.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'confetti_overlay.dart';
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

/// Laboratório: esquece as ofertas vistas neste aparelho.
Future<void> resetPlusOfferState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_prefsShown);
  await prefs.remove(_prefsLastWeek);
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
  // Fim da promoção: aviso grande, em tela inteira.
  if (kind != PlusOfferKind.sevenScenes) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => PlusPromoNoticeScreen(
          kind: kind,
          promoUntil: promoUntil ?? DateTime.now(),
        ),
      ),
    );
    return;
  }
  ActHaptics.confirm();
  await showAppSheet<void>(context, builder: (_) => const _PlusOfferSheet());
}

/// Oferta das 7 cenas: comemoração + Peregrino+.
class _PlusOfferSheet extends StatelessWidget {
  const _PlusOfferSheet();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final sub = context.watch<SubscriptionService>();
    final annual = sub.annualPackage;
    final trial = annual == null ? null : SubscriptionService.trialDays(annual);
    final perMonth = annual?.storeProduct.pricePerMonthString;
    const kind = PlusOfferKind.sevenScenes;

    return AppSheetPanel(
      tint: AppRoles.reward,
      background: const ConfettiOverlay(active: true, cinematic: true),
      padding: const EdgeInsets.fromLTRB(
        AppSpace.xl,
        AppSpace.screen,
        AppSpace.xl,
        AppSpace.screen,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            leading: const CloudMascot(face: CloudFace.sucesso, size: 104),
            eyebrow: l10n.paywallTitle,
            eyebrowColor: AppRoles.reward,
            title: l10n.plusOfferScenesTitle(PlusOffers.scenesForOffer),
            center: true,
            celebration: true,
          ),
          const SizedBox(height: AppSpace.md),
          const _SceneMarks(count: PlusOffers.scenesForOffer),
          const SizedBox(height: AppSpace.md),
          Text(
            l10n.plusOfferScenesBody,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.45,
              color: a.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          const _PerkList(),
          const SizedBox(height: AppSpace.xl),
          CopperCta(
            label: trial != null
                ? l10n.plusOfferTryFree(trial)
                : l10n.weeklyReviewSeePlus,
            expanded: true,
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
          if (perMonth != null) ...[
            const SizedBox(height: 6),
            Text(
              l10n.plusOfferFromPrice(perMonth),
              textAlign: TextAlign.center,
              style: AppTypography.body(size: 12, color: a.textFaint),
            ),
          ],
          const SizedBox(height: AppSpace.sm),
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

/// "7 de 7": a conquista em marcas, não só no título.
class _SceneMarks extends StatelessWidget {
  final int count;

  const _SceneMarks({required this.count});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.plusOfferScenesTitle(count),
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppRoles.reward,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppRoles.onReward,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Os três benefícios do Plus, compactos.
class _PerkList extends StatelessWidget {
  const _PerkList();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final perks = [
      (CinematicGlyph.scroll, l10n.paywallPerkWeeklyTitle),
      (CinematicGlyph.path, l10n.paywallPerkStreakTitle),
      (CinematicGlyph.target, l10n.paywallPerkReinforceTitle),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        color: a.insetFill,
        border: Border.all(color: a.insetBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < perks.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              children: [
                CinematicIcon(
                  glyph: perks[i].$1,
                  size: AppMetrics.iconMd,
                  accent: AppRoles.reward,
                  framed: false,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    perks[i].$2,
                    style: AppTypography.title(size: 14, color: a.text),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
