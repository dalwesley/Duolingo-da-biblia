import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/plus_offers.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/immersive_background.dart';
import '../widgets/plus_perks.dart';
import '../widgets/ui_primitives.dart';
import 'paywall_screen.dart';

/// Aviso grande do fim da promoção de lançamento ("acabando" ou "acabou"):
/// deixa claro o que passa a ser do Peregrino+ e o que segue grátis.
class PlusPromoNoticeScreen extends StatelessWidget {
  final PlusOfferKind kind;
  final DateTime promoUntil;

  const PlusPromoNoticeScreen({
    super.key,
    required this.kind,
    required this.promoUntil,
  });

  bool get _ended => kind == PlusOfferKind.promoEnded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sub = context.watch<SubscriptionService>();
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final a = AppearanceStyle.resolve(mode);
    final top = MediaQuery.viewPaddingOf(context).top;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    final date = DateFormat(
      'd MMM',
      l10n.localeName,
    ).format(promoUntil).replaceAll('.', '');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysLeft = promoUntil.difference(today).inDays + 1;

    final annual = sub.annualPackage;
    final trial = annual == null ? null : SubscriptionService.trialDays(annual);
    final perMonth = annual?.storeProduct.pricePerMonthString;

    final free = [
      l10n.plusNoticeFreeBible,
      l10n.plusNoticeFreeScenes,
      l10n.plusNoticeFreeSocial,
      l10n.plusNoticeFreeStreak,
    ];

    return ImmersiveScaffold(
      mode: mode,
      style: a,
      frameBody: false,
      body: Column(
        children: [
          Expanded(
            child: ContentFrame(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  top + AppSpace.lg,
                  AppSpace.screen,
                  AppSpace.xl,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: l10n.commonNotNow,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: a.textSecondary),
                    ),
                  ),
                  Center(
                    child: CloudMascot(
                      face: _ended ? CloudFace.feliz : CloudFace.triste,
                      size: 112,
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                  Text(
                    l10n.paywallTitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w800,
                      color: AppRoles.reward,
                    ),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    _ended
                        ? l10n.plusNoticeEndedTitle
                        : l10n.plusNoticeEndingTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.display(size: 30, color: a.text),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    _ended
                        ? l10n.plusNoticeEndedBody(date)
                        : l10n.plusNoticeEndingBody(date),
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 14,
                      height: 1.45,
                      color: a.textSecondary,
                    ),
                  ),
                  if (!_ended && daysLeft > 0) ...[
                    const SizedBox(height: AppSpace.md),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          color: AppMetrics.accentFill(alpha: 0.14),
                          border: Border.all(
                            color: AppMetrics.accentBorder(alpha: 0.7),
                          ),
                        ),
                        child: Text(
                          l10n.plusOfferDaysLeft(daysLeft),
                          style: AppTypography.display(size: 22, color: a.text),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpace.xl),
                  _FreeBlock(title: l10n.plusNoticeFreeHeader, labels: free),
                  const SizedBox(height: AppSpace.md),
                  PlusPerkCard(
                    header: _ended
                        ? l10n.plusNoticeLockedHeader
                        : l10n.plusNoticeLockedHeaderSoon(date),
                    locked: true,
                  ),
                ],
              ),
            ),
          ),
          ContentFrame(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpace.screen,
                AppSpace.sm,
                AppSpace.screen,
                AppSpace.md + bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CopperCta(
                    label: trial != null
                        ? l10n.plusOfferTryFree(trial)
                        : l10n.plusNoticeContinue,
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
                  TextCta(
                    label: l10n.commonNotNow,
                    color: a.textFaint,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Continua grátis, sempre": mesmo formato do [PlusPerkCard], em neutro.
class _FreeBlock extends StatelessWidget {
  final String title;
  final List<String> labels;

  const _FreeBlock({required this.title, required this.labels});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        color: a.insetFill,
        border: Border.all(color: a.insetBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w800,
              color: a.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpace.md),
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.check,
                  size: AppMetrics.iconLg,
                  accent: a.textSecondary,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    labels[i],
                    style: AppTypography.title(size: 15, color: a.text),
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
