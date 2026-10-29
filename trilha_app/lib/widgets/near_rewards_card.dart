import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/entry_trails.dart';
import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medals.dart';
import '../models/trail.dart';
import '../screens/trail_map_screen.dart';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/trail_progress.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'medal_unlock_sheet.dart';
import 'relic_panel.dart';
import 'ui_primitives.dart';

/// Um prêmio perto: título, quanto falta, o quanto já foi (0–1) e para
/// onde o toque leva.
class _Near {
  final CinematicGlyph glyph;
  final Color accent;
  final String title;
  final String line;
  final double progress;

  /// Quanto falta, na unidade do prêmio: ordena a lista.
  final int remaining;
  final String kind;
  final Future<void> Function(BuildContext context) open;

  const _Near({
    required this.glyph,
    required this.accent,
    required this.title,
    required this.line,
    required this.progress,
    required this.remaining,
    required this.kind,
    required this.open,
  });
}

/// "Quase lá" no Perfil: os prêmios a poucos passos (medalha, selo de
/// personagem, álbum de postais quase cheio). Some quando nada está perto.
class NearRewardsCard extends StatefulWidget {
  const NearRewardsCard({super.key});

  static const maxItems = 3;

  /// Álbum entra quando faltam até tantos postais.
  static const albumWithin = 3;

  @override
  State<NearRewardsCard> createState() => _NearRewardsCardState();
}

class _NearRewardsCardState extends State<NearRewardsCard> {
  late final Future<List<Trail>> _trails = TrailRepository().getTrails();

  Future<void> _openTrail(BuildContext context, String slug) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => TrailMapScreen(slug: slug)));

  List<_Near> _items(ProgressService p, String uid, List<Trail> trails) {
    final l10n = context.l10n;
    final items = <_Near>[];
    final completed = p.completedMissions;

    // Medalhas: as trilhas mais perto do próximo nível.
    final profile = CaravanPilgrimProfile.fromProgress(progress: p, uid: uid);
    final ctx = PilgrimMedalEvalContext.fromProgress(p);
    for (final m in PilgrimMedals.nearestLockedList(
      profile: profile,
      catalog: trails,
      ctx: ctx,
    )) {
      items.add(
        _Near(
          glyph: m.track.glyph,
          accent: tierColor(m.nextLevel.tier),
          title: '${m.track.title} · ${tierLabel(m.nextLevel.tier)}',
          line: m.remainingLabel,
          progress: m.target <= 0 ? 0 : m.current / m.target,
          remaining: m.remaining,
          kind: 'medal',
          open: (context) async {
            for (final vault in PilgrimMedals.evaluateVaults(
              profile: profile,
              catalog: trails,
              ctx: ctx,
            )) {
              for (final track in vault.tracks) {
                if (track.track.id == m.track.id) {
                  await showTrackDetailSheet(context, track);
                  return;
                }
              }
            }
          },
        ),
      );
    }

    // Selo de personagem: a cena dele é a próxima da trilha (aberta).
    for (final seal in CharacterSeals.all) {
      if (completed.contains(seal.missionSlug)) continue;
      final trail = trails.where((t) => t.slug == seal.trailSlug).firstOrNull;
      if (trail == null ||
          !TrailProgress.isTrailUnlocked(
            trail,
            trails,
            completed,
            clearedTrailModes: p.clearedTrailModes,
          ) ||
          TrailProgress.getCurrentMission(trail, completed)?.slug !=
              seal.missionSlug) {
        continue;
      }
      items.add(
        _Near(
          glyph: seal.glyph,
          accent: AppRoles.reward,
          title: l10n.profileNearSeal(seal.name),
          line: l10n.profileNearSealLine(trail.localizedTitle),
          progress: 0.9,
          remaining: 1,
          kind: 'seal',
          open: (context) => _openTrail(context, trail.slug),
        ),
      );
    }

    // Álbum de postais quase cheio.
    final revealed = {...p.missionCompletedOn.keys, ...p.postcardsOn.keys};
    for (final t in trails) {
      if (t.comingSoon || t.missionSlugs.isEmpty) continue;
      final total = t.missionSlugs.length;
      final done = t.missionSlugs.where(revealed.contains).length;
      final left = total - done;
      if (done == 0 || left <= 0 || left > NearRewardsCard.albumWithin) {
        continue;
      }
      items.add(
        _Near(
          glyph: CinematicGlyph.gem,
          accent: AppRoles.reward,
          title: l10n.profileNearAlbum(t.localizedTitle),
          line: l10n.profileNearAlbumLine(done, total, left),
          progress: done / total,
          remaining: left,
          kind: 'album',
          open: (context) => _openTrail(context, t.slug),
        ),
      );
    }

    items.sort((a, b) => a.remaining.compareTo(b.remaining));
    return items.take(NearRewardsCard.maxItems).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProgressService>();
    final uid = context.read<BackendService>().uid ?? '';
    return FutureBuilder<List<Trail>>(
      future: _trails,
      builder: (context, snap) {
        final trails = snap.data;
        if (trails == null || trails.isEmpty) return const SizedBox.shrink();
        final items = _items(p, uid, trails);
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpace.md),
          child: RelicPanel(
            accent: AppRoles.reward,
            glow: 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RelicChapter(
                  title: context.l10n.profileNearTitle,
                  accent: AppRoles.reward,
                  divided: false,
                ),
                const SizedBox(height: AppSpace.md),
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpace.sm),
                  _NearRow(item: items[i]),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NearRow extends StatelessWidget {
  final _Near item;

  const _NearRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: () {
        ActHaptics.tap();
        AnalyticsService.instance.logEvent('profile_near_open', {
          'kind': item.kind,
          'remaining': item.remaining,
        });
        item.open(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
        child: Row(
          children: [
            CinematicIcon(
              glyph: item.glyph,
              size: AppMetrics.leadingIcon,
              accent: item.accent,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title(size: 14, color: a.text),
                  ),
                  Text(
                    item.line,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(size: 12, color: a.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  RelicProgress(
                    value: item.progress.clamp(0.0, 1.0),
                    accent: item.accent,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            ListChevron(color: a.textSecondary),
          ],
        ),
      ),
    );
  }
}
