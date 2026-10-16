import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../services/analytics_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/coming_soon_trails_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';

/// Abre o apoio: compra avulsa na loja quando configurada; senão, a página
/// de doação do site (como antes).
Future<void> openSupport(BuildContext context) async {
  if (context.read<SubscriptionService>().supportConfigured) {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SupportScreen()));
    return;
  }
  await openDonatePage();
}

/// "Apoiar o Stway": compra avulsa que não libera nada — só o selo de
/// apoiador e o agradecimento.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  bool _thanked = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logEvent('support_view');
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final sub = context.watch<SubscriptionService>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ImmersiveBackground(
        frameChild: false,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screen,
                ),
                child: TopBar(
                  title: l10n.supportTitle,
                  onBack: () => Navigator.pop(context),
                  leadingGlyph: CinematicGlyph.gift,
                ),
              ),
              Expanded(
                child: ContentFrame(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.screen,
                      AppSpace.lg,
                      AppSpace.screen,
                      AppSpace.xl,
                    ),
                    children: [
                      Center(
                        child: CloudMascot(
                          face: _thanked ? CloudFace.sucesso : CloudFace.feliz,
                          size: 104,
                        ),
                      ),
                      const SizedBox(height: AppSpace.lg),
                      Text(
                        _thanked
                            ? l10n.supportThanksTitle
                            : l10n.supportHeadline,
                        textAlign: TextAlign.center,
                        style: AppTypography.display(size: 26, color: a.text),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        _thanked ? l10n.supportThanksBody : l10n.supportBody,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          size: 14,
                          color: a.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpace.xl),
                      for (final package in sub.supportPackages) ...[
                        CopperCta(
                          label: l10n.supportAmount(
                            package.storeProduct.priceString,
                          ),
                          leading: CinematicGlyph.gift,
                          expanded: true,
                          onTap: sub.loading
                              ? null
                              : () async {
                                  final ok = await sub.purchaseSupport(package);
                                  if (ok && mounted) {
                                    setState(() => _thanked = true);
                                  }
                                },
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        l10n.supportFinePrint,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(size: 12, color: a.textFaint),
                      ),
                      if (sub.lastError != null) ...[
                        const SizedBox(height: AppSpace.sm),
                        Text(
                          sub.lastError!,
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
        ),
      ),
    );
  }
}
