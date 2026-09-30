import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_language.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medals.dart';
import '../models/trail.dart';
import '../services/backend_service.dart';
import '../services/invite_deep_link_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Desafio sazonal público (Advento/Quaresma) — só aparece na janela ativa.
/// Convite do cofre; a Caminhada tem entrada própria na home.
class SeasonChallengeBanner extends StatelessWidget {
  final List<Trail> catalog;

  const SeasonChallengeBanner({super.key, required this.catalog});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final uid = context.read<BackendService>().uid ?? '';
    final profile = CaravanPilgrimProfile.fromProgress(
      progress: progress,
      uid: uid,
    );
    final ctx = PilgrimMedalEvalContext.fromProgress(progress);
    final vaults = PilgrimMedals.evaluateVaults(
      profile: profile,
      catalog: catalog,
      ctx: ctx,
    );

    PilgrimVaultState? season;
    for (final v in vaults) {
      if (v.vault.kind == PilgrimVaultKind.season) {
        season = v;
        break;
      }
    }
    // Abre numa folha: nunca fica vazio — mostra um estado calmo.
    if (season == null || season.tracks.isEmpty) {
      return _SeasonQuietCard(
        title: l10n.seasonChallengeEmptyTitle,
        body: l10n.seasonChallengeEmptyBody,
      );
    }
    final track = season.tracks.first;
    if (track.isComplete) {
      return _SeasonQuietCard(
        title: season.vault.title,
        body: l10n.seasonChallengeDoneBody,
        done: true,
      );
    }
    final vaultTitle = season.vault.title;

    final next = track.nextLevel;
    final accent = tierColor(
      next?.tier ?? track.currentLevel?.tier ?? PilgrimMedalTier.bronze,
    );

    return Semantics(
      container: true,
      child: GlassCard(
        elevated: true,
        padding: AppMetrics.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CinematicIcon(
                  glyph: track.track.glyph,
                  size: AppMetrics.leadingIcon,
                  accent: accent,
                  glowing: false,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaultTitle,
                        style: AppTypography.title(size: 16, color: a.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        next != null
                            ? next.hint
                            : l10n.seasonChallengeInProgress,
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
            const SizedBox(height: AppSpace.md),
            AppProgressBar(value: track.progress, color: accent, height: 6),
            const SizedBox(height: 6),
            Text(
              l10n.seasonChallengePathPercent(
                (track.progress * 100).round(),
              ),
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: accent.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            CopperCta(
              label: l10n.seasonChallengeInvite,
              trailing: CinematicGlyph.share,
              onTap: () => _share(context, vaultTitle),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _share(BuildContext context, String title) async {
    final body = context.l10n.seasonChallengeShareBody(
      title,
      InviteDeepLinkService.openAppFooter(),
    );
    await SharePlus.instance.share(ShareParams(text: body, subject: title));
  }
}

class _SeasonQuietCard extends StatelessWidget {
  final String title;
  final String body;
  final bool done;

  const _SeasonQuietCard({
    required this.title,
    required this.body,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final accent = done ? AppColors.teal : AppColors.orchid;
    return GlassCard(
      elevated: true,
      padding: AppMetrics.cardPadding,
      child: Row(
        children: [
          CinematicIcon(
            glyph: done ? CinematicGlyph.check : CinematicGlyph.crown,
            size: AppMetrics.leadingIcon,
            accent: accent,
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
    );
  }
}
