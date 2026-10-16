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

    final locked = [
      (CinematicGlyph.scroll, l10n.paywallPerkWeeklyTitle),
      (CinematicGlyph.path, l10n.paywallPerkStreakTitle),
      (CinematicGlyph.target, l10n.paywallPerkReinforceTitle),
    ];
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
                  _Block(
                    title: _ended
                        ? l10n.plusNoticeLockedHeader
                        : l10n.plusNoticeLockedHeaderSoon(date),
                    accent: AppRoles.reward,
                    highlighted: true,
                    rows: [
                      for (final (glyph, label) in locked)
                        _Row(glyph: glyph, label: label, locked: true),
                    ],
                  ),
                  const SizedBox(height: AppSpace.md),
                  _Block(
                    title: l10n.plusNoticeFreeHeader,
                    accent: a.textSecondary,
                    rows: [
                      for (final label in free)
                        _Row(
                          glyph: CinematicGlyph.check,
                          label: label,
                          locked: false,
                        ),
                    ],
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

class _Block extends StatelessWidget {
  final String title;
  final Color accent;
  final bool highlighted;
  final List<Widget> rows;

  const _Block({
    required this.title,
    required this.accent,
    required this.rows,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        color: highlighted ? AppMetrics.accentFill(alpha: 0.10) : a.insetFill,
        border: Border.all(
          color: highlighted
              ? AppMetrics.accentBorder(alpha: 0.6)
              : a.insetBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: AppSpace.md),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final CinematicGlyph glyph;
  final String label;
  final bool locked;

  const _Row({required this.glyph, required this.label, required this.locked});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      children: [
        CinematicIcon(
          glyph: glyph,
          size: AppMetrics.iconMd,
          accent: locked ? AppRoles.reward : a.textSecondary,
          framed: false,
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Text(
            label,
            style: AppTypography.title(size: 14, color: a.text),
          ),
        ),
        if (locked)
          CinematicIcon(
            glyph: CinematicGlyph.lock,
            size: AppMetrics.iconMd,
            accent: a.textFaint,
            framed: false,
          ),
      ],
    );
  }
}
