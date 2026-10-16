import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';
import '../screens/paywall_screen.dart';
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
  if (kind == PlusOfferKind.sevenScenes) ActHaptics.confirm();
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
    final sub = context.watch<SubscriptionService>();
    final annual = sub.annualPackage;
    final trial = annual == null ? null : SubscriptionService.trialDays(annual);
    final perMonth = annual?.storeProduct.pricePerMonthString;
    final celebrate = kind == PlusOfferKind.sevenScenes;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysLeft = promoUntil == null
        ? 0
        : promoUntil!.difference(today).inDays + 1;
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
      tint: AppRoles.reward,
      background: celebrate
          ? const ConfettiOverlay(active: true, cinematic: true)
          : null,
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
            leading: CloudMascot(
              face: celebrate ? CloudFace.sucesso : CloudFace.feliz,
              size: 104,
            ),
            eyebrow: l10n.paywallTitle,
            eyebrowColor: AppRoles.reward,
            title: title,
            center: true,
            celebration: true,
          ),
          const SizedBox(height: AppSpace.md),
          if (celebrate)
            const _SceneMarks(count: PlusOffers.scenesForOffer)
          else if (kind == PlusOfferKind.promoEndingSoon && daysLeft > 0)
            _Countdown(days: daysLeft),
          const SizedBox(height: AppSpace.md),
          Text(
            body,
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

/// Contagem até o fim da promoção.
class _Countdown extends StatelessWidget {
  final int days;

  const _Countdown({required this.days});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          color: AppMetrics.accentFill(alpha: 0.14),
          border: Border.all(color: AppMetrics.accentBorder(alpha: 0.7)),
        ),
        child: Text(
          context.l10n.plusOfferDaysLeft(days),
          style: AppTypography.display(size: 22, color: a.text),
        ),
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
