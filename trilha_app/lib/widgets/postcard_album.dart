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
import '../services/league_service.dart';
import '../services/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/remote_config_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'caravan_goal_card.dart';
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

  static const _thumb = 88.0;

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
      (ProgressService p) => (
        p.postcardsOn.length,
        p.missionCompletedOn.length,
        p.caravanPostcards.length,
      ),
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
        // Marcos da Caravana: o do mês a caminho (se a pessoa caminhou) e
        // os guardados, mais recente primeiro.
        final thisMonth = LeagueService.monthKey();
        final caravanMonths = {
          if (progress.currentMonthScenes > 0) thisMonth,
          ...progress.caravanPostcards.keys,
        }.toList()..sort((x, y) => y.compareTo(x));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (review) ...[
              _YearReviewDoor(year: year),
              const SizedBox(height: AppSpace.lg),
            ],
            if (caravanMonths.isNotEmpty) ...[
              Text(
                l10n.caravanPostcardsSection,
                style: AppTypography.title(size: 14, color: a.text),
              ),
              const SizedBox(height: AppSpace.sm),
              SizedBox(
                height: height + 8,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: caravanMonths.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final month = caravanMonths[i];
                    final saved = progress.caravanPostcards[month];
                    if (saved == null) {
                      // A etapa deste mês: o marco a caminho, revelado até
                      // o último pouso que a pessoa viu na Caravana.
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _CaravanOnTheWay(month: month, width: _thumb),
                      );
                    }
                    final card = CaravanPostcards.of(
                      context,
                      month,
                      on: DateTime.tryParse(saved),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: GestureDetector(
                        onTap: () {
                          ActHaptics.tap();
                          showPostcardDetail(context, card);
                        },
                        child: PostcardView(
                          postcard: card,
                          width: _thumb,
                          mini: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpace.lg),
            ],
            for (final album in albums) ...[
              Builder(
                builder: (context) {
                  final got = album.missions
                      .where((m) => _dayOf(progress, m.slug) != null)
                      .length;
                  final total = album.missions.length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              album.trail.localizedTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title(
                                size: 14,
                                color: a.text,
                              ),
                            ),
                          ),
                          Text(
                            l10n.postcardsCount(got, total),
                            style: AppTypography.label(color: AppRoles.reward),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Álbum enchendo: quanto da trilha já virou postal.
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : got / total,
                          minHeight: 3,
                          backgroundColor: a.progressTrack,
                          valueColor: const AlwaysStoppedAnimation(
                            AppRoles.reward,
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
                    // Postais soltos, levemente inclinados — não uma grade.
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Transform.rotate(
                        angle: (i.isEven ? -1 : 1) * 0.025,
                        // Vaga ainda não ganha: recua, os ganhos brilham.
                        child: day == null
                            ? Opacity(opacity: 0.45, child: view)
                            : GestureDetector(
                                onTap: () => _open(card),
                                child: view,
                              ),
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

/// O marco do mês ainda a caminho: revelado até o último pouso visto na
/// Caravana, com a etiqueta "A caminho".
class _CaravanOnTheWay extends StatelessWidget {
  final String month;
  final double width;

  const _CaravanOnTheWay({required this.month, required this.width});

  Future<double> _reveal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getInt('caravanStopSeen_$month') ?? -1;
      return seen < 0 ? 0 : LeagueService.goalMilestones[seen];
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = CaravanPostcards.of(context, month);
    return FutureBuilder<double>(
      future: _reveal(),
      builder: (context, snap) => Stack(
        clipBehavior: Clip.none,
        children: [
          PostcardView(
            postcard: card,
            width: width,
            mini: true,
            reveal: snap.data ?? 0,
            postmark: 0,
          ),
          Positioned(
            left: 0,
            right: 0,
            // Em cima da pintura: o rodapé do postal fica legível.
            top: 10,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppRoles.navTogether,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  context.l10n.caravanAlbumOnTheWay,
                  style: AppTypography.label(
                    size: 9,
                    letterSpacing: 0.3,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
