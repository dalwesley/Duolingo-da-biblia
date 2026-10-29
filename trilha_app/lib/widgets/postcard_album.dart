import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/postcard_index.dart';
import '../data/trail_art.dart';
import '../data/trail_repository.dart';
import '../data/year_review.dart';
import '../l10n/app_language.dart';
import '../models/trail.dart';
import '../services/content_catalog_service.dart';
import '../screens/year_review_screen.dart';
import '../services/progress_service.dart';
import '../services/remote_config_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'postcard.dart';
import 'ui_primitives.dart';

/// Gaveta "Postais" do Cofre: um álbum por trilha, os revelados com a
/// pintura e os que faltam velados. Só no perfil próprio (os postais moram
/// no doc privado). Ver docs/postais.md.
class PostcardAlbum extends StatefulWidget {
  const PostcardAlbum({super.key});

  @override
  State<PostcardAlbum> createState() => _PostcardAlbumState();
}

class _PostcardAlbumState extends State<PostcardAlbum> {
  final _catalog = ContentCatalogService.instance;
  late Future<List<Trail>> _trails = TrailRepository().getTrails();

  @override
  void initState() {
    super.initState();
    _catalog.trailsRevision.addListener(_reload);
  }

  @override
  void dispose() {
    _catalog.trailsRevision.removeListener(_reload);
    super.dispose();
  }

  /// O catálogo chegou da rede depois do cache: pede a lista nova (frase
  /// "Hoje" e referência podem ter mudado).
  void _reload() {
    if (!mounted) return;
    setState(() => _trails = TrailRepository().getTrails());
  }

  /// Última lista mostrada: o recarregar não pisca o spinner.
  List<Trail>? _last;

  static const _thumb = 104.0;

  /// Dia do postal. Cena feita antes dos postais entra já revelada, com o
  /// dia em que foi feita.
  static String? _dayOf(ProgressService p, String slug) =>
      p.postcardsOn[slug] ?? p.missionCompletedOn[slug];

  Postcard _card(ProgressService p, Trail t, Mission m, String? day) =>
      Postcard(
        slug: m.slug,
        title: m.localizedTitle,
        ref: PostcardIndex.refOf(p, m),
        insight: (m.localizedCentralInsight ?? '').trim(),
        art: TrailArt.ofScene(t.slug, m.slug),
        on: DateTime.tryParse(day ?? '') ?? DateTime.now(),
      );

  void _open(Postcard card) {
    ActHaptics.tap();
    showPostcardDetail(
      context,
      card,
      onRedo: () =>
          Navigator.of(context).pushNamed('/lesson', arguments: card.slug),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reconstrói quando entra postal ou cena nova.
    context.select(
      (ProgressService p) =>
          (p.postcardsOn.length, p.missionCompletedOn.length),
    );
    final progress = context.read<ProgressService>();
    final l10n = context.l10n;
    final a = Appearance.of(context);

    return FutureBuilder<List<Trail>>(
      future: _trails,
      initialData: _last,
      builder: (context, snap) {
        if (snap.data != null) _last = snap.data;
        final trails = snap.data;
        if (trails == null) {
          return const SizedBox(height: 160, child: AppSpinner());
        }
        final albums = <({Trail trail, List<Mission> missions, String last})>[];
        for (final t in trails) {
          final missions = [for (final m in t.modules) ...m.missions];
          String? last;
          for (final m in missions) {
            final day = _dayOf(progress, m.slug);
            if (day != null && (last == null || day.compareTo(last) > 0)) {
              last = day;
            }
          }
          if (last != null) {
            albums.add((trail: t, missions: missions, last: last));
          }
        }
        if (albums.isEmpty) {
          return EmptyState(
            face: CloudFace.feliz,
            title: l10n.postcardsEmptyTitle,
            body: l10n.postcardsEmptyBody,
          );
        }
        // A trilha do postal mais recente vem primeiro.
        albums.sort((x, y) => y.last.compareTo(x.last));

        final height = PostcardView.heightFor(_thumb, mini: true);
        final year = DateTime.now().year;
        final inYear = {
          ...progress.missionCompletedOn,
          ...progress.postcardsOn,
        }.values.where((d) => d.startsWith('$year-')).length;
        final review =
            RemoteConfigService.instance.yearReviewOpen &&
            inYear >= YearReview.minPostcards;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (review) ...[
              _YearReviewDoor(year: year),
              const SizedBox(height: AppSpace.lg),
            ],
            for (final album in albums) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      album.trail.localizedTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                  ),
                  Text(
                    l10n.postcardsCount(
                      album.missions
                          .where((m) => _dayOf(progress, m.slug) != null)
                          .length,
                      album.missions.length,
                    ),
                    style: AppTypography.label(color: AppRoles.reward),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              SizedBox(
                height: height + 8,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: album.missions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final m = album.missions[i];
                    final day = _dayOf(progress, m.slug);
                    final card = _card(progress, album.trail, m, day);
                    final view = PostcardView(
                      postcard: card,
                      width: _thumb,
                      mini: true,
                      reveal: day == null ? 0 : 1,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: day == null
                          ? view
                          : GestureDetector(
                              onTap: () => _open(card),
                              child: view,
                            ),
                    );
                  },
                ),
              ),
              if (album != albums.last) const SizedBox(height: AppSpace.lg),
            ],
          ],
        );
      },
    );
  }
}

/// Porta da retrospectiva no topo do álbum (só quando ela abre).
class _YearReviewDoor extends StatelessWidget {
  final int year;

  const _YearReviewDoor({required this.year});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a = Appearance.of(context);
    return Material(
      color: AppRoles.reward.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(color: AppRoles.reward.withValues(alpha: 0.55)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ActHaptics.tap();
          openYearReview(context, year: year);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Row(
            children: [
              const CloudMascot(face: CloudFace.feliz, size: 44),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.yearReviewTitle('$year'),
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.yearReviewOpen,
                      style: AppTypography.body(
                        size: 13,
                        color: AppRoles.reward,
                      ),
                    ),
                  ],
                ),
              ),
              CinematicIcon(
                glyph: CinematicGlyph.forward,
                size: 28,
                accent: AppRoles.reward,
                glowing: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
