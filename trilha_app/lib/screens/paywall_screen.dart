import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../l10n/app_language.dart';
import '../services/analytics_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/coming_soon_trails_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/plus_perks.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';

/// Paywall do Peregrino+. Abre por Ajustes, pelos recursos bloqueados e
/// pelas ofertas (no máx. 1 por semana, fora da cena) — nunca no meio de uma
/// cena, no onboarding ou no login.
///
/// Ordem: por que apoiar → o que vem → o que segue grátis → planos → como o
/// teste funciona. O botão de assinar fica fixo embaixo.
class PaywallScreen extends StatefulWidget {
  /// De onde o paywall foi aberto (analytics), ex.: `settings`.
  final String source;

  const PaywallScreen({super.key, this.source = 'settings'});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

/// EULA padrão da Apple — exigido junto dos termos em assinatura no iOS.
const _appleEulaUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

int _rank(PackageType t) => switch (t) {
  PackageType.annual => 0,
  PackageType.monthly => 1,
  PackageType.lifetime => 2,
  _ => 3,
};

class _PaywallScreenState extends State<PaywallScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    final sub = context.read<SubscriptionService>();
    final state = sub.isPeregrinoPlus
        ? 'paid'
        : sub.launchPromoActive
        ? 'promo'
        : sub.isConfigured
        ? 'offer'
        : 'unavailable';
    AnalyticsService.instance.logPaywallView(
      source: widget.source,
      state: state,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sub = context.watch<SubscriptionService>();
    final paid = sub.isPeregrinoPlus;
    final promoUntil = paid ? null : sub.launchFreeUntil;
    final promoDate = promoUntil == null
        ? null
        : DateFormat(
            'd MMM',
            l10n.localeName,
          ).format(promoUntil).replaceAll('.', '');
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final a = AppearanceStyle.resolve(mode);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    final packages = [...sub.availablePackages]
      ..sort((x, y) => _rank(x.packageType).compareTo(_rank(y.packageType)));
    final offer =
        !paid && promoDate == null && sub.isConfigured && packages.isNotEmpty;
    final selected = packages.isEmpty
        ? null
        : packages.firstWhere(
            (p) => p.identifier == _selectedId,
            orElse: () => packages.first,
          );
    final trial = selected == null
        ? null
        : SubscriptionService.trialDays(selected);
    final renews = selected?.packageType != PackageType.lifetime;

    return ImmersiveScaffold(
      mode: mode,
      style: a,
      frameBody: false,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpace.screen,
              MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
              AppSpace.screen,
              0,
            ),
            child: TopBar(
              inline: true,
              immersive: true,
              dark: true,
              title: l10n.paywallTitle,
              onBack: () => Navigator.pop(context),
              leadingGlyph: CinematicGlyph.crown,
            ),
          ),
          Expanded(
            child: ContentFrame(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  AppSpace.lg,
                  AppSpace.screen,
                  offer ? AppSpace.xl : AppSpace.xxl + bottom,
                ),
                children: [
                  Center(
                    child: CloudMascot(
                      face: paid ? CloudFace.sucesso : CloudFace.feliz,
                      size: 96,
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                  Text(
                    paid
                        ? l10n.paywallAlreadyPlus
                        : promoDate != null
                        ? l10n.paywallLaunchFreeTitle
                        : l10n.paywallHeadline,
                    textAlign: TextAlign.center,
                    style: AppTypography.display(size: 28, color: a.text),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    paid
                        ? l10n.paywallThanks
                        : promoDate != null
                        ? l10n.paywallLaunchFreeBody(promoDate)
                        : l10n.paywallPitch,
                    textAlign: TextAlign.center,
                    style: AppTypography.body(size: 14, color: a.textSecondary),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  const PlusPerkCard(detailed: true),
                  const SizedBox(height: AppSpace.md),
                  const _FreeForever(),
                  if (offer) ...[
                    const SizedBox(height: AppSpace.xl),
                    for (final p in packages) ...[
                      _PlanTile(
                        package: p,
                        monthly: packages
                            .where((x) => x.packageType == PackageType.monthly)
                            .firstOrNull,
                        selected: p.identifier == selected!.identifier,
                        trialDays: SubscriptionService.trialDays(p),
                        onTap: () => setState(() => _selectedId = p.identifier),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (trial != null) ...[
                      const SizedBox(height: AppSpace.md),
                      _TrialTimeline(
                        days: trial,
                        price: SubscriptionService.packageLabel(selected!),
                      ),
                    ],
                    const SizedBox(height: AppSpace.lg),
                    Text(
                      [
                        if (trial != null)
                          l10n.paywallTrialThen(
                            trial,
                            SubscriptionService.packageLabel(selected!),
                          ),
                        if (renews) l10n.paywallAutoRenew,
                      ].join(' '),
                      textAlign: TextAlign.center,
                      style: AppTypography.body(size: 11, color: a.textFaint),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    _LegalLinks(sub: sub),
                  ] else if (!paid && promoDate == null) ...[
                    const SizedBox(height: AppSpace.xl),
                    Text(
                      l10n.paywallUnavailable,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(size: 12, color: a.textFaint),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (offer)
            _BuyBar(
              label: trial != null
                  ? l10n.paywallStartTrial(trial)
                  : renews
                  ? l10n.paywallSubscribe
                  : l10n.paywallBuyOnce,
              note: renews ? l10n.paywallCancelAnytime : null,
              error: sub.lastError,
              onTap: sub.loading ? null : () => sub.purchase(selected!),
            ),
        ],
      ),
    );
  }
}

/// Lembra o que não é vendido — as linhas que o Stway não cruza.
class _FreeForever extends StatelessWidget {
  const _FreeForever();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CinematicIcon(
          glyph: CinematicGlyph.book,
          size: AppMetrics.iconMd,
          accent: a.textSecondary,
          framed: false,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            context.l10n.paywallFreeForever,
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  final Package package;

  /// Plano mensal, para calcular quanto o anual economiza.
  final Package? monthly;
  final bool selected;
  final int? trialDays;
  final VoidCallback onTap;

  const _PlanTile({
    required this.package,
    required this.monthly,
    required this.selected,
    required this.trialDays,
    required this.onTap,
  });

  /// Economia do anual sobre 12 mensais, em %. Null se < 10%.
  int? _savings() {
    final m = monthly?.storeProduct.price;
    if (package.packageType != PackageType.annual || m == null || m <= 0) {
      return null;
    }
    final pct = ((1 - package.storeProduct.price / (m * 12)) * 100).round();
    return pct >= 10 ? pct : null;
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final product = package.storeProduct;
    final type = package.packageType;
    final title = switch (type) {
      PackageType.annual => l10n.paywallPlanAnnual,
      PackageType.monthly => l10n.paywallPlanMonthly,
      PackageType.lifetime => l10n.paywallPlanLifetime,
      _ => product.title,
    };
    final savings = _savings();
    final perMonth = type == PackageType.annual
        ? product.pricePerMonthString
        : null;
    // Preço grande à direita: o anual fala em "por mês".
    final (bigPrice, smallPrice) = switch (type) {
      PackageType.annual when perMonth != null => (
        l10n.paywallPricePerMonthShort(perMonth),
        SubscriptionService.packageLabel(package),
      ),
      PackageType.monthly => (
        l10n.paywallPricePerMonthShort(product.priceString),
        null,
      ),
      _ => (product.priceString, SubscriptionService.packageLabel(package)),
    };
    final tone = selected ? AppRoles.reward : a.textFaint;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              color: selected
                  ? AppMetrics.accentFill(alpha: 0.12)
                  : a.insetFill,
              border: Border.all(
                width: selected ? 2 : 1,
                color: selected
                    ? AppMetrics.accentBorder(alpha: 0.8)
                    : a.insetBorder,
              ),
            ),
            child: Row(
              children: [
                // Rádio: escolher, não navegar.
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: tone, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: selected
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tone,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            title,
                            style: AppTypography.title(size: 16, color: a.text),
                          ),
                          if (type == PackageType.annual)
                            SoftBadge(
                              text: savings != null
                                  ? l10n.paywallSave(savings)
                                  : l10n.paywallBestValue,
                              accent: AppRoles.reward,
                            ),
                        ],
                      ),
                      if (trialDays != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.paywallTrialDays(trialDays!),
                          style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w700,
                            color: a.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bigPrice,
                      style: AppTypography.title(size: 17, color: a.text),
                    ),
                    if (smallPrice != null)
                      Text(
                        smallPrice,
                        style: AppTypography.body(size: 11, color: a.textFaint),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Como o teste funciona: hoje, o lembrete na véspera, a cobrança.
class _TrialTimeline extends StatelessWidget {
  final int days;
  final String price;

  const _TrialTimeline({required this.days, required this.price});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final steps = [
      (l10n.paywallTimelineToday, l10n.paywallTimelineTodayBody),
      (l10n.paywallTimelineDay(days - 1), l10n.paywallTimelineReminderBody),
      (l10n.paywallTimelineDay(days), l10n.paywallTimelineChargeBody(price)),
    ];
    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.paywallTimelineTitle,
            style: AppTypography.title(size: 15, color: a.text),
          ),
          const SizedBox(height: AppSpace.md),
          for (var i = 0; i < steps.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 22,
                    child: Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == 0 ? AppRoles.reward : a.insetFill,
                            border: Border.all(
                              color: i == 0 ? AppRoles.reward : a.textFaint,
                              width: 2,
                            ),
                          ),
                        ),
                        if (i < steps.length - 1)
                          Expanded(
                            child: Container(width: 2, color: a.insetBorder),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: i < steps.length - 1 ? AppSpace.md : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[i].$1,
                            style: AppTypography.body(
                              size: 13,
                              weight: FontWeight.w700,
                              color: a.text,
                            ),
                          ),
                          Text(
                            steps[i].$2,
                            style: AppTypography.body(
                              size: 12,
                              color: a.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LegalLinks extends StatelessWidget {
  final SubscriptionService sub;

  const _LegalLinks({required this.sub});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextCta(
          label: l10n.paywallRestore,
          onTap: sub.loading ? null : () => sub.restore(),
          color: a.textSecondary,
        ),
        TextCta(
          label: l10n.legalTerms,
          onTap: () => openSitePage(termsPageUrl),
          color: a.textSecondary,
        ),
        TextCta(
          label: l10n.legalPrivacy,
          onTap: () => openSitePage(privacyPageUrl),
          color: a.textSecondary,
        ),
        if (defaultTargetPlatform == TargetPlatform.iOS)
          TextCta(
            label: l10n.paywallAppleEula,
            onTap: () => openSitePage(_appleEulaUrl),
            color: a.textSecondary,
          ),
      ],
    );
  }
}

/// Botão de assinar fixo embaixo — sempre à vista, com a nota curta.
class _BuyBar extends StatelessWidget {
  final String label;
  final String? note;
  final String? error;
  final VoidCallback? onTap;

  const _BuyBar({
    required this.label,
    required this.onTap,
    this.note,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    return ContentFrame(
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
            if (error != null) ...[
              Text(
                error!,
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 12, color: a.textSecondary),
              ),
              const SizedBox(height: AppSpace.sm),
            ],
            CopperCta(label: label, expanded: true, onTap: onTap),
            if (note != null) ...[
              const SizedBox(height: 6),
              Text(
                note!,
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 12, color: a.textFaint),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
