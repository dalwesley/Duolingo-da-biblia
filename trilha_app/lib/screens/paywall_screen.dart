import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
import '../widgets/ui_primitives.dart';

/// Tela única de assinatura — só acessível pelo menu de Configurações,
/// nunca como interrupção de sessão (onboarding, fim de missão, etc).
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
      l10n.paywallPerkJourney,
      l10n.paywallPerkBadge,
    ];
    final subscription = context.watch<SubscriptionService>();
    final paid = subscription.isPeregrinoPlus;
    final promoUntil = paid ? null : subscription.launchFreeUntil;
    final promoDate = promoUntil == null
        ? null
        : DateFormat('d MMM', l10n.localeName)
              .format(promoUntil)
              .replaceAll('.', '');
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
                  else if (!paid) ...[
                    for (final package in subscription.availablePackages) ...[
                      CopperCta(
                        label: SubscriptionService.packageLabel(package),
                        expanded: true,
                        onTap: subscription.loading
                            ? null
                            : () => subscription.purchase(package),
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextCta(
                      label: l10n.paywallRestore,
                      onTap: subscription.loading
                          ? null
                          : () => subscription.restore(),
                      color: a.textSecondary,
                    ),
                  ],
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
