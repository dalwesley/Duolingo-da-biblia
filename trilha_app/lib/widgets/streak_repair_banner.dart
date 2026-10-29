import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';
import '../l10n/app_language.dart';

/// Oferta de reparo — restaura a sequência após faltar 1 dia (1×/mês).
class StreakRepairBanner extends StatelessWidget {
  const StreakRepairBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final offer = context.select(
      (ProgressService p) => (
        show: p.showStreakRepairOffer,
        broken: p.brokenStreak,
        restored: p.streakRepairRestored,
        current: p.streak < 1 ? 1 : p.streak,
        missed: p.streakRepairMissedDay,
      ),
    );
    if (!offer.show) return const SizedBox.shrink();
    final progress = context.read<ProgressService>();

    final a = Appearance.of(context);
    final restored = offer.restored;

    // O Anan conta o que houve (triste: a sequência caiu) e oferece
    // juntar de volta — no ouro da sequência, não no gelo do congelamento.
    return GlassCard(
      elevated: true,
      tint: AppRoles.streak,
      borderColor: AppRoles.streak.withValues(alpha: 0.35),
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CloudMascot(face: CloudFace.triste, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(context, offer.missed),
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.streakRepairBody(offer.broken, restored),
                      style: AppTypography.body(
                        size: 13,
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
          Row(
            children: [
              Expanded(
                child: CopperCta(
                  label: context.l10n.streakRepairAction,
                  trailing: CinematicGlyph.flame,
                  dense: true,
                  showGlow: false,
                  onTap: () async {
                    final ok = await progress.claimStreakRepair();
                    if (!context.mounted || !ok) return;
                    showAppToastFor(
                      context,
                      message: context.l10n.streakRepairDone(restored),
                      glyph: CinematicGlyph.flame,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              TextCta(
                label: context.l10n.streakRepairDismiss(offer.current),
                color: a.textSecondary,
                onTap: () async {
                  await progress.dismissStreakRepair();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// "Ontem ficou em branco" — ou o dia da semana, se a falta já passou.
  static String _title(BuildContext context, DateTime? missed) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (missed == null || DateUtils.isSameDay(missed, yesterday)) {
      return context.l10n.streakRepairTitle;
    }
    final tag = Localizations.localeOf(context).toLanguageTag();
    final day = DateFormat.EEEE(tag).format(missed);
    final lead = Localizations.localeOf(context).languageCode == 'pt'
        ? '${day[0].toUpperCase()}${day.substring(1)}'
        : day;
    return context.l10n.streakRepairTitleDay(lead);
  }
}

/// Oferta na celebração — quieta, sem segundo CTA ouro.
class StreakRepairCelebrationCard extends StatelessWidget {
  const StreakRepairCelebrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final offer = context.select(
      (ProgressService p) => (
        show: p.showStreakRepairOffer,
        broken: p.brokenStreak,
        restored: p.streakRepairRestored,
      ),
    );
    if (!offer.show) return const SizedBox.shrink();
    final progress = context.read<ProgressService>();

    final a = Appearance.of(context);
    final broken = offer.broken;
    final restored = offer.restored;

    return GlassCard(
      tint: AppRoles.streak,
      padding: AppMetrics.cardPaddingCompact,
      child: Row(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.flame,
            size: AppMetrics.leadingIcon,
            accent: AppRoles.streak,
            framed: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.streakRepairCanReturn(broken),
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.streakRepairContinueWith(restored),
                  style: AppTypography.body(
                    size: 12,
                    height: 1.3,
                    weight: FontWeight.w600,
                    color: a.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextCta(
            label: context.l10n.streakRepairAction,
            color: AppRoles.streak,
            onTap: () async {
              await progress.claimStreakRepair();
            },
          ),
        ],
      ),
    );
  }
}
