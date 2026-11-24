import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/postcard_index.dart';
import '../data/trail_art.dart';
import '../data/year_review.dart';
import '../l10n/app_language.dart';
import '../models/trail.dart';
import '../screens/year_review_screen.dart';
import '../services/progress_service.dart';
import '../services/remote_config_service.dart';
import '../theme/app_theme.dart';
import '../utils/season_walk_debug.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'postcard.dart';
import 'ui_primitives.dart';

/// Card da retrospectiva na Home, com a cara da própria retrospectiva:
/// noite com brilho dourado, os três últimos postais do ano em leque (selos
/// picotados) e o carimbo do ano por cima. Aparece só na janela
/// (28/12–31/01) e para quem tem postais suficientes; fora disso não ocupa
/// espaço.
class YearReviewHomeCard extends StatefulWidget {
  final List<Trail> trails;
  final double topGap;

  const YearReviewHomeCard({super.key, required this.trails, this.topGap = 0});

  /// Laboratório (debug): mostra o card fora da janela e com poucos postais.
  static final forceShow = ValueNotifier<bool>(false);

  /// Cenas do [year] (postal ou conclusão), uma por cena, dias distintos e
  /// os três postais mais recentes (o mais novo primeiro). Mesma conta de
  /// [YearReview.build], sem esperar o catálogo.
  static ({int count, int days, List<Postcard> latest}) summary(
    ProgressService progress,
    List<Trail> trails,
    int year,
  ) {
    final prefix = '$year-';
    final seen = <String>{};
    final days = <String>{};
    final cards = <Postcard>[];
    for (final t in trails) {
      for (final m in [for (final mod in t.modules) ...mod.missions]) {
        if (!seen.add(m.slug)) continue;
        final day =
            progress.postcardsOn[m.slug] ?? progress.missionCompletedOn[m.slug];
        if (day == null || !day.startsWith(prefix)) continue;
        days.add(day);
        cards.add(
          Postcard(
            slug: m.slug,
            title: m.localizedTitle,
            ref: PostcardIndex.refOf(progress, m),
            insight: '',
            art: TrailArt.ofScene(t.slug, m.slug),
            on: DateTime.tryParse(day) ?? DateTime(year),
          ),
        );
      }
    }
    final withArt = cards.where((c) => c.art != null).toList()
      ..sort((x, y) => y.on.compareTo(x.on));
    return (
      count: cards.length,
      days: days.length,
      latest: withArt.take(3).toList(),
    );
  }

  @override
  State<YearReviewHomeCard> createState() => _YearReviewHomeCardState();
}

class _YearReviewHomeCardState extends State<YearReviewHomeCard> {
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    YearReviewHomeCard.forceShow.addListener(_refresh);
  }

  @override
  void dispose() {
    YearReviewHomeCard.forceShow.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Relógio da Caminhada: em debug o Laboratório consegue simular 28/12.
    final progress = context.watch<ProgressService>();
    final today = SeasonWalkDebug.today();
    final forced = kDebugMode && YearReviewHomeCard.forceShow.value;
    if (!forced && !RemoteConfigService.instance.yearReviewOpenAt(today)) {
      return const SizedBox.shrink();
    }
    final year = RemoteConfigService.reviewYearFor(today);
    final s = YearReviewHomeCard.summary(progress, widget.trails, year);
    if (!forced && s.count < YearReview.minPostcards) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    const gold = AppRoles.reward;
    const ink = AppColors.textOnDark;
    final title = l10n.yearReviewTitle('$year');
    final line =
        '${l10n.yearReviewPostcards(s.count)} ${l10n.yearReviewDays(s.days)}';
    final radius = BorderRadius.circular(AppMetrics.heroRadius);

    return Padding(
      padding: EdgeInsets.only(top: widget.topGap),
      child: Semantics(
        button: true,
        label: [title, line, l10n.yearReviewOpen].join('. '),
        excludeSemantics: true,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () {
            ActHaptics.confirm();
            openYearReview(context, year: year, force: forced);
          },
          child: AnimatedScale(
            scale: _pressed ? 0.985 : 1,
            duration: AppMotion.quick,
            curve: AppMotion.enter,
            // Sempre noite, como a retrospectiva e o card do ano.
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: RadialGradient(
                  center: const Alignment(0.55, -0.2),
                  radius: 1.25,
                  colors: [
                    Color.lerp(AppColors.night, gold, 0.26)!,
                    AppColors.night,
                  ],
                ),
                border: Border.all(color: gold.withValues(alpha: 0.55)),
                boxShadow: [
                  BoxShadow(
                    color: gold.withValues(alpha: 0.18),
                    blurRadius: 24,
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 10, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SectionLabel(
                              l10n.yearReviewEyebrow,
                              size: 10,
                              color: gold,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.display(
                                size: 22,
                                color: ink,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              line,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(
                                size: 13,
                                height: 1.3,
                                color: ink.withValues(alpha: 0.78),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _OpenPill(label: l10n.yearReviewOpen),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      _StampFan(
                        cards: s.latest,
                        year: year,
                        top: l10n.yearReviewEyebrow,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pílula amarela de ação (amarelo = ação + recompensa).
class _OpenPill extends StatelessWidget {
  final String label;

  const _OpenPill({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
    decoration: BoxDecoration(
      color: AppRoles.reward,
      borderRadius: BorderRadius.circular(AppRadii.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w800,
              color: AppColors.night,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const CinematicIcon(
          glyph: CinematicGlyph.forward,
          size: 16,
          accent: AppColors.night,
          framed: false,
        ),
      ],
    ),
  );
}

/// Até três postais em leque (selos picotados) com o carimbo do ano.
class _StampFan extends StatelessWidget {
  final List<Postcard> cards;
  final int year;
  final String top;

  const _StampFan({required this.cards, required this.year, required this.top});

  static const _w = 64.0;

  @override
  Widget build(BuildContext context) {
    // Do fundo para a frente: o mais novo fica por cima, no meio.
    final shown = cards.reversed.toList();
    const slots = [
      (dx: -30.0, dy: 6.0, angle: -0.20),
      (dx: 30.0, dy: 10.0, angle: 0.18),
      (dx: 0.0, dy: -6.0, angle: -0.03),
    ];
    final first = slots.length - shown.length;
    return SizedBox(
      width: 140,
      height: 132,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < shown.length; i++)
            Transform.translate(
              offset: Offset(slots[first + i].dx, slots[first + i].dy),
              child: Transform.rotate(
                angle: slots[first + i].angle,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: PostcardView(
                    postcard: shown[i],
                    width: _w,
                    mini: true,
                  ),
                ),
              ),
            ),
          // Carimbo do ano batido no canto do postal da frente, meio torto
          // (tinta do correio só aparece sobre o papel).
          Positioned(
            left: 70,
            top: 62,
            child: Transform.rotate(
              angle: -0.18,
              child: Opacity(
                opacity: 0.92,
                child: PostmarkStamp(
                  radius: 18,
                  top: top,
                  on: DateTime(year, 12, 31),
                  waves: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
