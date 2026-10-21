import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';
import '../screens/paywall_screen.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Peregrino+ pedindo atenção na Home, em três momentos:
/// cobrança falhou (ainda dá tempo), venceu há pouco na graça do cache
/// (ainda há acesso) e acabou de verdade (primeira semana sem — depois
/// quem chama é o convite de retorno). Escondido no paywall, ninguém via.
class PlusBillingBanner extends StatefulWidget {
  const PlusBillingBanner({super.key});

  @override
  State<PlusBillingBanner> createState() => _PlusBillingBannerState();
}

class _PlusBillingBannerState extends State<PlusBillingBanner> {
  static const _dismissedKey = 'plusEndedBannerDismissedFor';
  static const _endedWindowDays = 7;

  String? _dismissedFor;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dismissedFor = prefs.getString(_dismissedKey);
      _loaded = true;
    });
  }

  Future<void> _dismiss(String endedIso) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedKey, endedIso);
    if (mounted) setState(() => _dismissedFor = endedIso);
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();
    final a = Appearance.of(context);
    final l10n = context.l10n;

    final billing = sub.plusBillingIssue;
    final paying = sub.isPeregrinoPlus && (billing || sub.plusInGrace);
    final ended = sub.lastPlusEndedAt;
    final endedRecently =
        !sub.isPeregrinoPlus &&
        sub.isConfigured &&
        ended != null &&
        DateTime.now().difference(ended).inDays <= _endedWindowDays;

    if (!paying && !endedRecently) return const SizedBox.shrink();
    if (endedRecently &&
        (!_loaded || _dismissedFor == ended.toIso8601String())) {
      return const SizedBox.shrink();
    }

    final title = paying
        ? (billing ? l10n.plusBillingHomeTitle : l10n.plusGraceHomeTitle)
        : l10n.plusEndedHomeTitle;
    final body = paying
        ? (billing ? l10n.plusBillingHomeBody : l10n.plusGraceHomeBody)
        : l10n.plusEndedHomeBody;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.section),
      child: GlassCard(
        elevated: true,
        tint: paying ? AppRoles.risk : AppRoles.reward,
        padding: AppMetrics.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.crown,
                  size: AppMetrics.leadingIcon,
                  accent: paying ? AppRoles.risk : AppRoles.reward,
                  glowing: false,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.title(size: 16, color: a.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: AppTypography.body(
                          size: 12,
                          height: 1.35,
                          weight: FontWeight.w600,
                          color: a.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CopperCta(
              label: paying
                  ? l10n.plusBillingHomeAction
                  : l10n.weeklyReviewSeePlus,
              expanded: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PaywallScreen(
                    source: paying ? 'billing_banner' : 'plus_ended_banner',
                  ),
                ),
              ),
            ),
            if (endedRecently) ...[
              const SizedBox(height: 6),
              Center(
                child: TextCta(
                  label: l10n.commonNotNow,
                  color: a.textFaint,
                  onTap: () => _dismiss(ended.toIso8601String()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
