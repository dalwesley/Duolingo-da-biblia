import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
/// Convida a compartilhar, reaproveitando o cofre de medalhas já calculado.
class SeasonChallengeBanner extends StatelessWidget {
  final List<Trail> catalog;

  const SeasonChallengeBanner({super.key, required this.catalog});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
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
    if (season == null || season.tracks.isEmpty) return const SizedBox.shrink();
    final track = season.tracks.first;
    if (track.isComplete) return const SizedBox.shrink();

    final next = track.nextLevel;
    final accent = tierColor(
      next?.tier ?? track.currentLevel?.tier ?? PilgrimMedalTier.bronze,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.section),
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
                  size: 40,
                  accent: accent,
                  glowing: false,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        season.vault.title,
                        style: AppTypography.title(size: 14, color: a.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        next != null
                            ? next.hint
                            : 'Desafio da temporada em andamento',
                        style: AppTypography.body(
                          size: 12,
                          height: 1.35,
                          weight: FontWeight.w600,
                          color: a.textMuted(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: LinearProgressIndicator(
                value: track.progress,
                minHeight: 6,
                backgroundColor: a.text.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CopperCta(
                    label: 'Convidar para o desafio',
                    trailing: CinematicGlyph.path,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _share(season!.vault.title);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(String title) async {
    final body = '''
🕯️ Entrei no desafio $title no Stway.

Vamos caminhar juntos essa temporada?

${InviteDeepLinkService.openAppFooter()}
'''
        .trim();
    await SharePlus.instance.share(
      ShareParams(text: body, subject: title),
    );
  }
}
