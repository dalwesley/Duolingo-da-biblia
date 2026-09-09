import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  static const _perks = [
    'Companheiros de caminhada: até 6, em vez de 3',
    'Apoia diretamente a produção de novas trilhas',
  ];

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionService>();
    final a = Appearance.of(context);

    return Scaffold(
      body: ImmersiveBackground(
        child: SafeArea(
          child: Column(
            children: [
              TopBar(title: 'Peregrino+', onBack: () => Navigator.pop(context)),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpace.lg),
                  children: [
                    Center(
                      child: CinematicIcon(
                        glyph: CinematicGlyph.crown,
                        size: 56,
                        accent: AppColors.accent,
                        glowing: true,
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    Text(
                      subscription.isPeregrinoPlus
                          ? 'Você já é Peregrino+'
                          : 'Vá além na trilha',
                      textAlign: TextAlign.center,
                      style: AppTypography.display(size: 24, color: a.text),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      subscription.isPeregrinoPlus
                          ? 'Obrigado por apoiar o STWAY.'
                          : 'Um apoio direto ao projeto, com alguns extras.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 14,
                        color: a.textMuted(0.75),
                      ),
                    ),
                    const SizedBox(height: AppSpace.xl),
                    GlassCard(
                      padding: AppMetrics.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final perk in _perks) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CinematicIcon(
                                  glyph: CinematicGlyph.check,
                                  size: 22,
                                  accent: AppColors.accent,
                                  framed: false,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    perk,
                                    style: AppTypography.body(
                                      size: 13,
                                      color: a.textMuted(0.85),
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
                        'Assinatura ainda não disponível nesta versão.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          size: 12,
                          color: a.textMuted(0.55),
                        ),
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
                      TextButton(
                        onPressed:
                            subscription.loading ? null : () => subscription.restore(),
                        child: Text(
                          'Restaurar compra',
                          style: AppTypography.body(
                            weight: FontWeight.w700,
                            color: a.textMuted(0.6),
                          ),
                        ),
                      ),
                    ],
                    if (subscription.lastError != null) ...[
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        subscription.lastError!,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(size: 12, color: AppColors.error),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
