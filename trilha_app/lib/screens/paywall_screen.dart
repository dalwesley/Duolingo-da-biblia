import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';

/// Tela única de assinatura — só acessível pelo menu de Configurações,
/// nunca como interrupção de sessão (onboarding, fim de missão, etc).
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final perks = [l10n.paywallPerkSeason, l10n.paywallPerkWeeklyReview];
    final subscription = context.watch<SubscriptionService>();
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final a = AppearanceStyle.resolve(mode);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return ImmersiveScaffold(
      mode: mode,
      style: a,
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
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpace.screen,
                AppSpace.lg,
                AppSpace.screen,
                AppSpace.xxl + bottom,
              ),
              children: [
                Center(
                  child: CinematicIcon(
                    glyph: CinematicGlyph.crown,
                    size: AppMetrics.iconHero,
                    accent: AppRoles.reward,
                    glowing: true,
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                Text(
                  subscription.isPeregrinoPlus
                      ? l10n.paywallAlreadyPlus
                      : l10n.paywallHeadline,
                  textAlign: TextAlign.center,
                  style: AppTypography.display(size: 28, color: a.text),
                ),
                const SizedBox(height: AppSpace.sm),
                Text(
                  subscription.isPeregrinoPlus
                      ? l10n.paywallThanks
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
                if (!subscription.isConfigured)
                  Text(
                    l10n.paywallUnavailable,
                    textAlign: TextAlign.center,
                    style: AppTypography.body(size: 12, color: a.textFaint),
                  )
                else if (!subscription.isPeregrinoPlus) ...[
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
                    style: AppTypography.body(size: 12, color: AppRoles.error),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
