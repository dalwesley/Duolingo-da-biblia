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
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/coming_soon_trails_card.dart';
import '../widgets/ui_primitives.dart';

/// Paywall do Peregrino+. Abre por Ajustes, pelos recursos bloqueados e
/// pelas ofertas (no máx. 1 por semana, fora da cena) — nunca no meio de uma
/// cena, no onboarding ou no login.
class PaywallScreen extends StatefulWidget {
  /// De onde o paywall foi aberto (analytics), ex.: `settings`.
  final String source;

  const PaywallScreen({super.key, this.source = 'settings'});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
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
    final perks = [
      l10n.paywallPerkWeeklyReview,
      l10n.paywallPerkProfile,
      l10n.paywallPerkReinforce,
      l10n.paywallPerkBadge,
    ];
    final subscription = context.watch<SubscriptionService>();
    final paid = subscription.isPeregrinoPlus;
    final promoUntil = paid ? null : subscription.launchFreeUntil;
    final promoDate = promoUntil == null
        ? null
        : DateFormat(
            'd MMM',
            l10n.localeName,
          ).format(promoUntil).replaceAll('.', '');
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final a = AppearanceStyle.resolve(mode);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

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
                  AppSpace.xxl + bottom,
                ),
                children: [
                  Center(
                    child: CloudMascot(
                      face: paid ? CloudFace.sucesso : CloudFace.feliz,
                      size: 112,
                    ),
                  ),
                  const SizedBox(height: AppSpace.lg),
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
                  GlassCard(
                    padding: AppMetrics.cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final perk in perks) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CinematicIcon(
                                glyph: CinematicGlyph.check,
                                size: AppMetrics.iconMd,
                                accent: AppRoles.success,
                                framed: false,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  perk,
                                  style: AppTypography.body(
                                    size: 13,
                                    color: a.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  if (promoDate != null)
                    const SizedBox.shrink()
                  else if (!subscription.isConfigured)
                    Text(
                      l10n.paywallUnavailable,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(size: 12, color: a.textFaint),
                    )
                  else if (!paid)
                    _PlanPicker(subscription: subscription),
                  if (subscription.lastError != null) ...[
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      subscription.lastError!,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 12,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// EULA padrão da Apple — exigido junto dos termos em assinatura no iOS.
const _appleEulaUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

/// Planos da loja: anual primeiro e já escolhido; um botão só para assinar.
class _PlanPicker extends StatefulWidget {
  final SubscriptionService subscription;

  const _PlanPicker({required this.subscription});

  @override
  State<_PlanPicker> createState() => _PlanPickerState();
}

class _PlanPickerState extends State<_PlanPicker> {
  String? _selectedId;

  static int _rank(PackageType t) => switch (t) {
    PackageType.annual => 0,
    PackageType.monthly => 1,
    PackageType.lifetime => 2,
    _ => 3,
  };

  /// Dias do teste grátis do pacote, se houver.
  static int? _trialDays(Package p) {
    final intro = p.storeProduct.introductoryPrice;
    if (intro == null || intro.price > 0) return null;
    final n = intro.periodNumberOfUnits;
    return switch (intro.periodUnit) {
      PeriodUnit.day => n,
      PeriodUnit.week => n * 7,
      PeriodUnit.month => n * 30,
      PeriodUnit.year => n * 365,
      PeriodUnit.unknown => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final sub = widget.subscription;
    final packages = [...sub.availablePackages]
      ..sort((x, y) => _rank(x.packageType).compareTo(_rank(y.packageType)));
    if (packages.isEmpty) {
      return Text(
        l10n.paywallUnavailable,
        textAlign: TextAlign.center,
        style: AppTypography.body(size: 12, color: a.textFaint),
      );
    }
    final selected = packages.firstWhere(
      (p) => p.identifier == _selectedId,
      orElse: () => packages.first,
    );
    final trial = _trialDays(selected);
    final renews = selected.packageType != PackageType.lifetime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final p in packages) ...[
          _PlanTile(
            package: p,
            selected: p.identifier == selected.identifier,
            trialDays: _trialDays(p),
            onTap: () => setState(() => _selectedId = p.identifier),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: AppSpace.sm),
        CopperCta(
          label: trial != null
              ? l10n.paywallStartTrial(trial)
              : renews
              ? l10n.paywallSubscribe
              : l10n.paywallBuyOnce,
          expanded: true,
          onTap: sub.loading ? null : () => sub.purchase(selected),
        ),
        const SizedBox(height: AppSpace.md),
        Text(
          [
            if (trial != null)
              l10n.paywallTrialThen(
                trial,
                SubscriptionService.packageLabel(selected),
              ),
            if (renews) l10n.paywallAutoRenew,
          ].join(' '),
          textAlign: TextAlign.center,
          style: AppTypography.body(size: 11, color: a.textFaint),
        ),
        const SizedBox(height: AppSpace.sm),
        Wrap(
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
        ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  final Package package;
  final bool selected;
  final int? trialDays;
  final VoidCallback onTap;

  const _PlanTile({
    required this.package,
    required this.selected,
    required this.trialDays,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final product = package.storeProduct;
    final annual = package.packageType == PackageType.annual;
    final title = switch (package.packageType) {
      PackageType.annual => l10n.paywallPlanAnnual,
      PackageType.monthly => l10n.paywallPlanMonthly,
      PackageType.lifetime => l10n.paywallPlanLifetime,
      _ => product.title,
    };
    final perMonth = annual ? product.pricePerMonthString : null;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: AppTypography.title(size: 15, color: a.text),
                          ),
                          if (annual) ...[
                            const SizedBox(width: 8),
                            SoftBadge(
                              text: l10n.paywallBestValue,
                              accent: AppRoles.reward,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          SubscriptionService.packageLabel(package),
                          if (perMonth != null) l10n.paywallPerMonth(perMonth),
                          if (trialDays != null)
                            l10n.paywallTrialDays(trialDays!),
                        ].join(' · '),
                        style: AppTypography.body(
                          size: 12,
                          color: a.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                CinematicIcon(
                  glyph: selected
                      ? CinematicGlyph.check
                      : CinematicGlyph.chevron,
                  size: AppMetrics.iconMd,
                  accent: selected ? AppRoles.reward : a.textFaint,
                  framed: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
