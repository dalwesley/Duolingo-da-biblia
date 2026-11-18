import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/year_review.dart';
import '../l10n/app_language.dart';
import '../services/analytics_service.dart';
import '../services/app_update_service.dart';
import '../models/walk_companion.dart';
import '../services/companion_service.dart';
import '../services/progress_service.dart';
import '../services/recognition_service.dart';
import '../services/room_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../widgets/act_feel.dart';
import '../widgets/anan_speech.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/postcard.dart';
import '../utils/layout_utils.dart';
import '../widgets/reveal_stage.dart';
import '../widgets/stway_brand.dart';
import '../widgets/year_review_video.dart';
import '../widgets/ui_primitives.dart';
import 'paywall_screen.dart';

/// Abre a retrospectiva de [year] (padrão: o ano corrente). Sem o mínimo de
/// postais, não abre — a não ser com [force] (laboratório).
Future<void> openYearReview(
  BuildContext context, {
  int? year,
  bool force = false,
}) async {
  final progress = context.read<ProgressService>();
  final y = year ?? DateTime.now().year;
  final review = await YearReview.build(
    progress,
    y,
    together: _togetherFrom(context, y),
  );
  if (!context.mounted) return;
  if (!force && !review.worthShowing) return;
  await Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => YearReviewScreen(review: review),
    ),
  );
}

/// Companhia, grupo e reconhecimentos que já estão carregados no app.
/// Sem o serviço (teste, convidado), o slide simplesmente não mostra.
YearTogether _togetherFrom(BuildContext context, int year) {
  T? maybe<T>() {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  WalkCompanion? pair;
  for (final c in maybe<CompanionService>()?.companions ?? const []) {
    if (c.sharedDays > (pair?.sharedDays ?? 0)) pair = c;
  }
  final recognitions =
      maybe<RecognitionService>()?.received
          .where((r) => r.createdAt?.year == year)
          .length ??
      0;
  final room = maybe<RoomService>()?.activeRoom;
  return YearTogether(
    companionName: pair?.displayName,
    companionDays: pair?.sharedDays ?? 0,
    groupName: room?.name,
    recognitions: recognitions,
  );
}

/// Retrospectiva em stories, no palco das revelações (raios em volta do
/// destaque de cada slide): capa (grátis), coleção, números, livro, mês,
/// modo, frase e caminhar junto (Peregrino+), o Anan e o card do ano.
/// Toque à direita avança, à esquerda volta.
class YearReviewScreen extends StatefulWidget {
  final YearReview review;

  const YearReviewScreen({super.key, required this.review});

  @override
  State<YearReviewScreen> createState() => _YearReviewScreenState();
}

/// Um slide: a cor do palco e o que ele mostra.
class _Page {
  final Color accent;
  final Widget Function(BuildContext) build;

  /// Último slide: botões fixos, sem avançar no toque.
  final bool last;

  /// Slide de clímax: confete, som e vibração ao chegar.
  final bool climax;

  /// Nome do slide (analytics). Vazio = não tem botão de compartilhar.
  final String id;

  const _Page(
    this.id,
    this.accent,
    this.build, {
    this.last = false,
    this.climax = false,
  });

  bool get shareable => id.isNotEmpty && !last;
}

class _YearReviewScreenState extends State<YearReviewScreen>
    with TickerProviderStateMixin {
  final _cardKey = GlobalKey();
  final _slideKey = GlobalKey();
  bool _sharing = false;

  /// Capturando o slide: some o que é de tela (barras, dica, botão) e entra
  /// a marca no rodapé.
  bool _capturing = false;

  late final AnimationController _rays = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 48),
  );
  late final AnimationController _beat = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  int _index = 0;
  int _confettiShot = 0;

  final _stackKey = GlobalKey();
  final _focusKeys = <int, GlobalKey>{};
  Offset _focus = const Offset(0.5, 0.34);

  GlobalKey get _focusKey => _focusKeys.putIfAbsent(_index, GlobalKey.new);

  YearReview get _r => widget.review;

  @override
  void initState() {
    super.initState();
    _beat.addListener(_measureFocus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!MediaQuery.disableAnimationsOf(context)) _rays.repeat();
      _beat.forward(from: 0);
      ActHaptics.light();
    });
  }

  @override
  void dispose() {
    _rays.dispose();
    _beat.dispose();
    super.dispose();
  }

  void _measureFocus() {
    if (!mounted) return;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final hero =
        _focusKeys[_index]?.currentContext?.findRenderObject() as RenderBox?;
    if (stack == null || hero == null || !hero.attached) return;
    if (!stack.hasSize || !hero.hasSize || stack.size.isEmpty) return;
    final c = hero.localToGlobal(
      hero.size.center(Offset.zero),
      ancestor: stack,
    );
    final next = Offset(c.dx / stack.size.width, c.dy / stack.size.height);
    if ((next - _focus).distance > 0.002) setState(() => _focus = next);
  }

  void _go(int delta, List<_Page> pages) {
    final next = (_index + delta).clamp(0, pages.length - 1);
    if (next == _index) return;
    ActHaptics.tap();
    setState(() => _index = next);
    _beat.forward(from: 0);
    if (delta > 0 && pages[next].climax) {
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted || _index != next) return;
        ActHaptics.success();
        SoundService.instance.playComplete(boss: true);
        setState(() => _confettiShot++);
      });
    }
  }

  Animation<double> _slice(
    double from,
    double to, [
    Curve curve = Curves.easeOutCubic,
  ]) => CurvedAnimation(
    parent: _beat,
    curve: Interval(from.clamp(0.0, 1.0), to.clamp(0.0, 1.0), curve: curve),
  );

  Widget _hero(Widget child, {Curve curve = Curves.elasticOut}) => KeyedSubtree(
    key: _focusKey,
    child: ScaleTransition(scale: _slice(0, 0.45, curve), child: child),
  );

  Widget _rise(double from, Widget child) =>
      RevealRise(anim: _slice(from, from + 0.3), child: child);

  /// Captura o card do ano e abre o compartilhar. Grátis para todos: o card
  /// só leva números gerais (o detalhe fica nos slides do Peregrino+).
  Future<void> _share({String? slide}) async {
    if (_sharing) return;
    setState(() {
      _sharing = true;
      _capturing = slide != null;
    });
    ActHaptics.light();
    if (slide != null) _beat.value = 1;
    final l10n = context.l10n;
    final text = l10n.yearReviewShareText(
      '${_r.year}',
      AppUpdateService.androidStoreUrl,
    );
    try {
      await WidgetsBinding.instance.endOfFrame;
      if (slide != null) await WidgetsBinding.instance.endOfFrame;
      final key = slide != null ? _slideKey : _cardKey;
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      final image = await boundary?.toImage(
        pixelRatio: slide != null ? 2.5 : 3,
      );
      final bytes = await image?.toByteData(format: ui.ImageByteFormat.png);
      if (mounted && _capturing) setState(() => _capturing = false);
      if (bytes == null) {
        await SharePlus.instance.share(ShareParams(text: text));
      } else {
        final file = File(
          '${Directory.systemTemp.path}/stway_ano_${_r.year}_${slide ?? 'card'}.png',
        );
        await file.writeAsBytes(bytes.buffer.asUint8List());
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'image/png')],
            text: text,
          ),
        );
      }
      await AnalyticsService.instance.logEvent('year_review_share', {
        'year': _r.year,
        'postcards': _r.postcards.length,
        'slide': slide ?? 'card',
      });
    } catch (e) {
      debugPrint('Retrospectiva: compartilhar falhou: $e');
    } finally {
      if (mounted) {
        setState(() {
          _sharing = false;
          _capturing = false;
        });
      }
    }
  }

  List<_Page> _pages(bool plus) {
    final r = _r;
    const gold = AppRoles.reward;
    const blue = AppRoles.presence;
    return [
      _Page('cover', gold, _cover),
      if (!plus)
        _Page('', gold, _locked)
      else ...[
        if (r.postcards.isNotEmpty) _Page('collection', blue, _collection),
        if (r.hasMap) _Page('map', gold, _map),
        if (r.daysWalked >= 3) _Page('days', blue, _days),
        if (r.topBook != null) _Page('book', gold, _book),
        if (r.hasFeats || r.chapters > 0) _Page('feats', blue, _feats),
        if (r.growth != null)
          _Page('growth', gold, _growth)
        else if (r.bestMode != null)
          _Page('mode', gold, _mode),
        if (r.phrase != null) _Page('phrase', blue, _phrase),
        if (r.hasTogether) _Page('together', gold, _together),
        _Page('persona', gold, _persona, climax: true),
      ],
      _Page('end', gold, _end),
      _Page('card', gold, _shareSlide, last: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final plus = context.select((SubscriptionService s) => s.plusFeaturesOpen);
    final pages = _pages(plus);
    final index = _index.clamp(0, pages.length - 1);
    final page = pages[index];
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureFocus());
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.night,
      body: RepaintBoundary(
        key: _slideKey,
        child: Stack(
          key: _stackKey,
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: page.accent),
                duration: AppMotion.scene,
                builder: (_, color, _) => TweenAnimationBuilder<Offset>(
                  tween: Tween(end: _focus),
                  duration: AppMotion.scene,
                  curve: AppMotion.enter,
                  builder: (_, focus, _) => RevealStage(
                    rays: _rays,
                    color: color ?? page.accent,
                    focus: focus,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Opacity(
                    opacity: _capturing ? 0 : 1,
                    child: RevealTopBar(
                      count: pages.length,
                      index: index,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: page.last
                            ? null
                            : (d) => _go(
                                d.localPosition.dx < box.maxWidth / 3 ? -1 : 1,
                                pages,
                              ),
                        child: ContentFrame(
                          child: AnimatedSwitcher(
                            duration: AppMotion.standard,
                            switchInCurve: AppMotion.enter,
                            transitionBuilder: (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                            child: KeyedSubtree(
                              key: ValueKey(index),
                              child: page.build(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_capturing)
                    _Brand(year: _r.year)
                  else if (!page.last)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.md),
                      child: FadeTransition(
                        opacity: _slice(0.6, 0.9),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (page.shareable)
                              _SharePill(
                                label: l10n.yearReviewShareSlide,
                                onTap: _sharing
                                    ? null
                                    : () => _share(slide: page.id),
                              ),
                            const SizedBox(height: AppSpace.sm),
                            Text(
                              l10n.yearReviewTap,
                              style: AppTypography.label(
                                size: 12,
                                color: AppColors.textOnDark.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_confettiShot > 0 && !_capturing)
              Positioned.fill(
                child: IgnorePointer(
                  child: ConfettiOverlay(
                    key: ValueKey(_confettiShot),
                    active: true,
                    cinematic: true,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Slides ────────────────────────────────────────────────────────────

  Widget _cover(BuildContext context) {
    final l10n = context.l10n;
    final r = _r;
    return RevealCentered(
      scroll: true,
      children: [
        _hero(const CloudMascot(face: CloudFace.sucesso, size: 150)),
        const SizedBox(height: AppSpace.lg),
        _rise(
          0.15,
          SectionLabel(l10n.yearReviewEyebrow, color: AppRoles.reward),
        ),
        const SizedBox(height: AppSpace.sm),
        _rise(0.22, _Headline(l10n.yearReviewTitle('${r.year}'))),
        const SizedBox(height: AppSpace.xl),
        _rise(0.35, _Count(value: r.postcards.length, anim: _slice(0.35, 0.8))),
        const SizedBox(height: AppSpace.xs),
        _rise(0.45, _Line(l10n.yearReviewPostcardsWord(r.postcards.length))),
        const SizedBox(height: AppSpace.xs),
        _rise(0.52, _Line(l10n.yearReviewDays(r.days), faint: true)),
      ],
    );
  }

  Widget _collection(BuildContext context) {
    final l10n = context.l10n;
    final r = _r;
    final fmt = DateFormat('d MMM', l10n.localeName);
    String day(DateTime d) => fmt.format(d).replaceAll('.', '');
    return RevealCentered(
      scroll: true,
      children: [
        _hero(
          _Fan(cards: r.postcards.reversed.take(3).toList(), width: 150),
          curve: Curves.easeOutBack,
        ),
        const SizedBox(height: AppSpace.lg),
        _rise(
          0.2,
          SectionLabel(
            l10n.yearReviewCollectionEyebrow,
            color: AppRoles.presence,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        _rise(
          0.26,
          _Headline(
            l10n.yearReviewCollectionTitle(r.postcards.length),
            size: 30,
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        _rise(
          0.36,
          _Milestone(
            label: l10n.yearReviewFirst,
            title: r.postcards.first.title,
            date: day(r.postcards.first.on),
          ),
        ),
        if (r.postcards.length > 1) ...[
          const SizedBox(height: AppSpace.sm),
          _rise(
            0.44,
            _Milestone(
              label: l10n.yearReviewLatest,
              title: r.postcards.last.title,
              date: day(r.postcards.last.on),
            ),
          ),
        ],
      ],
    );
  }

  Widget _book(BuildContext context) {
    final l10n = context.l10n;
    final r = _r;
    final cards = [
      for (final c in r.postcards.reversed)
        if (c.book == r.topBook) c,
    ].take(3).toList();
    return RevealCentered(
      scroll: true,
      children: [
        _hero(
          cards.isEmpty
              ? const _Emblem(glyph: CinematicGlyph.book)
              : _Fan(cards: cards, width: 140),
          curve: Curves.easeOutBack,
        ),
        const SizedBox(height: AppSpace.lg),
        _rise(
          0.2,
          SectionLabel(l10n.yearReviewBookEyebrow, color: AppRoles.presence),
        ),
        const SizedBox(height: AppSpace.sm),
        _rise(0.28, _Big(r.topBook!, size: 60)),
        _rise(0.34, _Line(l10n.yearReviewPostcards(r.topBookCount))),
        const SizedBox(height: AppSpace.lg),
        _rise(0.5, _AnanSays(l10n.yearReviewAnanBook(r.topBook!))),
      ],
    );
  }

  Widget _map(BuildContext context) {
    final l10n = context.l10n;
    final r = _r;
    return RevealCentered(
      scroll: true,
      children: [
        _rise(
          0,
          SectionLabel(l10n.yearReviewMapEyebrow, color: AppRoles.reward),
        ),
        const SizedBox(height: AppSpace.md),
        KeyedSubtree(
          key: _focusKey,
          child: AnimatedBuilder(
            animation: _slice(0.05, 0.75, Curves.easeInOut),
            builder: (_, _) => BibleMapGrid(
              labels: r.bookLabels,
              lit: r.litBooks,
              progress: _slice(0.05, 0.75, Curves.easeInOut).value,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        _rise(
          0.55,
          _Headline(l10n.yearReviewMapTitle(r.litBooks.length), size: 30),
        ),
        const SizedBox(height: AppSpace.sm),
        _rise(
          0.6,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _Swatch(strong: true),
              const SizedBox(width: 6),
              _Small(l10n.yearReviewMapPostcard),
              const SizedBox(width: AppSpace.lg),
              const _Swatch(strong: false),
              const SizedBox(width: 6),
              _Small(l10n.yearReviewMapRead),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        _rise(0.7, _AnanSays(l10n.yearReviewAnanMap)),
      ],
    );
  }

  Widget _days(BuildContext context) {
    final l10n = context.l10n;
    final r = _r;
    final month = r.topMonth == null
        ? null
        : toBeginningOfSentenceCase(
            DateFormat.MMMM(
              l10n.localeName,
            ).format(DateTime(r.year, r.topMonth!)),
          );
    return RevealCentered(
      scroll: true,
      children: [
        _rise(
          0,
          SectionLabel(l10n.yearReviewDaysEyebrow, color: AppRoles.presence),
        ),
        const SizedBox(height: AppSpace.md),
        KeyedSubtree(
          key: _focusKey,
          child: AnimatedBuilder(
            animation: _slice(0.05, 0.7, Curves.easeInOut),
            builder: (_, _) => YearDots(
              year: r.year,
              days: r.walkedDays,
              progress: _slice(0.05, 0.7, Curves.easeInOut).value,
              locale: l10n.localeName,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        _rise(0.45, _Count(value: r.daysWalked, anim: _slice(0.45, 0.85))),
        _rise(0.5, _Line(l10n.yearReviewDaysWord(r.daysWalked))),
        const SizedBox(height: AppSpace.sm),
        if (r.yearStreak > 1)
          _rise(
            0.58,
            _Line(l10n.yearReviewYearStreak(r.yearStreak), faint: true),
          ),
        if (month != null && r.topMonthCount > 1)
          _rise(0.62, _Line(l10n.yearReviewTopMonthLine(month), faint: true)),
        const SizedBox(height: AppSpace.lg),
        _rise(0.7, _AnanSays(l10n.yearReviewAnanDays)),
      ],
    );
  }

  Widget _feats(BuildContext context) {
    final l10n = context.l10n;
    final r = _r;
    final tiles = [
      if (r.chapters > 0)
        (
          CinematicGlyph.book,
          r.chapters,
          l10n.yearReviewChaptersWord(r.chapters),
        ),
      if (r.perfectScenes > 0)
        (
          CinematicGlyph.crown,
          r.perfectScenes,
          l10n.yearReviewPerfectWord(r.perfectScenes),
        ),
      if (r.trailsDone.isNotEmpty)
        (
          CinematicGlyph.path,
          r.trailsDone.length,
          l10n.yearReviewTrailsWord(r.trailsDone.length),
        ),
      if (r.versesKept > 0)
        (
          CinematicGlyph.heart,
          r.versesKept,
          l10n.yearReviewVersesWord(r.versesKept),
        ),
    ];
    return RevealCentered(
      scroll: true,
      children: [
        _hero(const _Emblem(glyph: CinematicGlyph.crown)),
        const SizedBox(height: AppSpace.lg),
        _rise(
          0.15,
          SectionLabel(l10n.yearReviewFeatsEyebrow, color: AppRoles.reward),
        ),
        const SizedBox(height: AppSpace.lg),
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpace.sm),
          _rise(
            0.22 + i * 0.1,
            _StatTile(
              glyph: tiles[i].$1,
              value: tiles[i].$2,
              anim: _slice(0.25 + i * 0.1, 0.7 + i * 0.08),
              label: tiles[i].$3,
            ),
          ),
        ],
        if (r.trailsDone.isNotEmpty) ...[
          const SizedBox(height: AppSpace.sm),
          _rise(0.62, _Line(r.trailsDone.take(3).join(' · '), faint: true)),
        ],
        const SizedBox(height: AppSpace.lg),
        _rise(0.7, _AnanSays(l10n.yearReviewAnanFeats)),
      ],
    );
  }

  Widget _growth(BuildContext context) {
    final l10n = context.l10n;
    final g = _r.growth!;
    final fill = _slice(0.08, 0.7);
    return RevealCentered(
      scroll: true,
      children: [
        KeyedSubtree(
          key: _focusKey,
          child: AnimatedBuilder(
            animation: fill,
            builder: (_, _) {
              final pct = g.fromPct + (g.toPct - g.fromPct) * fill.value;
              return RevealRing(
                value: pct / 100,
                label: '${pct.round()}%',
                glow: _slice(0.65, 0.9).value,
              );
            },
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        _rise(
          0.5,
          SectionLabel(l10n.yearReviewGrowthEyebrow, color: AppRoles.reward),
        ),
        const SizedBox(height: AppSpace.sm),
        _rise(0.56, _Big('+${g.delta}', size: 60)),
        _rise(0.6, _Line(l10n.yearReviewGrowthWord)),
        const SizedBox(height: AppSpace.xs),
        _rise(
          0.64,
          _Line(
            l10n.yearReviewGrowthLine(g.mode.labelPt, g.fromPct, g.toPct),
            faint: true,
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        _rise(0.72, _AnanSays(l10n.yearReviewAnanGrowth)),
      ],
    );
  }

  Widget _persona(BuildContext context) {
    final l10n = context.l10n;
    final r = _r;
    final p = personaCopy(l10n, r.persona);
    final part = daypartLabel(l10n, r.daypart);
    return RevealCentered(
      scroll: true,
      children: [
        _hero(_Emblem(glyph: personaGlyph(r.persona), size: 150)),
        const SizedBox(height: AppSpace.lg),
        _rise(
          0.3,
          SectionLabel(
            l10n.yearReviewPersonaEyebrow('${r.year}'),
            color: AppRoles.reward,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        _rise(
          0.38,
          Text(
            p.$1,
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 42,
              color: AppRoles.reward,
              height: 1.1,
            ),
          ),
        ),
        if (part != null) ...[
          const SizedBox(height: AppSpace.sm),
          _rise(
            0.46,
            SoftBadge(text: part, accent: AppRoles.presence, bordered: true),
          ),
        ],
        const SizedBox(height: AppSpace.md),
        _rise(0.52, _Line(p.$2)),
      ],
    );
  }

  Widget _mode(BuildContext context) {
    final l10n = context.l10n;
    final r = _r;
    final fill = _slice(0.08, 0.7);
    return RevealCentered(
      scroll: true,
      children: [
        KeyedSubtree(
          key: _focusKey,
          child: AnimatedBuilder(
            animation: fill,
            builder: (_, _) => RevealRing(
              value: r.bestModePct / 100 * fill.value,
              label: '${(r.bestModePct * fill.value).round()}%',
              glow: _slice(0.65, 0.9).value,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        _rise(
          0.55,
          SectionLabel(l10n.yearReviewModeEyebrow, color: AppRoles.presence),
        ),
        const SizedBox(height: AppSpace.sm),
        _rise(0.6, _Big(r.bestMode!.labelPt, size: 48)),
        _rise(0.64, _Line(l10n.yearReviewModeWord)),
        const SizedBox(height: AppSpace.lg),
        _rise(0.7, _AnanSays(l10n.yearReviewAnanMode)),
      ],
    );
  }

  Widget _phrase(BuildContext context) {
    final l10n = context.l10n;
    final p = _r.phrase!;
    return RevealCentered(
      scroll: true,
      children: [
        _hero(PostcardView(postcard: p, width: 190), curve: Curves.easeOutBack),
        const SizedBox(height: AppSpace.lg),
        _rise(
          0.2,
          SectionLabel(l10n.yearReviewPhraseEyebrow, color: AppRoles.reward),
        ),
        const SizedBox(height: AppSpace.md),
        _rise(
          0.3,
          Text(
            '“${p.insight}”',
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 26,
              color: AppColors.textOnDark,
              height: 1.25,
            ),
          ),
        ),
        if (p.ref.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpace.sm),
          _rise(0.4, _Line(p.ref.trim(), faint: true)),
        ],
      ],
    );
  }

  Widget _together(BuildContext context) {
    final l10n = context.l10n;
    final r = _r;
    final t = r.together;
    final tiles = [
      if (t.companionDays > 0 && (t.companionName ?? '').trim().isNotEmpty)
        (
          CinematicGlyph.people,
          t.companionDays,
          l10n.yearReviewCompanionWord(
            t.companionDays,
            t.companionName!.trim().split(' ').first,
          ),
        ),
      if (r.adventDays > 0 && r.adventLength > 0)
        (
          CinematicGlyph.star,
          r.adventDays,
          l10n.yearReviewAdventWord(r.adventLength),
        ),
      if (r.groupSeals > 0)
        (
          CinematicGlyph.shield,
          r.groupSeals,
          l10n.yearReviewSealsWord(r.groupSeals),
        ),
      if (t.recognitions > 0)
        (
          CinematicGlyph.heart,
          t.recognitions,
          l10n.yearReviewRecognitionsWord(t.recognitions),
        ),
    ];
    return RevealCentered(
      scroll: true,
      children: [
        _hero(const _Emblem(glyph: CinematicGlyph.people)),
        const SizedBox(height: AppSpace.lg),
        _rise(
          0.15,
          SectionLabel(
            l10n.yearReviewTogetherEyebrow,
            color: AppRoles.presence,
          ),
        ),
        if ((t.groupName ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: AppSpace.xs),
          _rise(
            0.2,
            _Line(l10n.yearReviewGroupLine(t.groupName!.trim()), faint: true),
          ),
        ],
        const SizedBox(height: AppSpace.lg),
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpace.sm),
          _rise(
            0.22 + i * 0.12,
            _StatTile(
              glyph: tiles[i].$1,
              value: tiles[i].$2,
              anim: _slice(0.25 + i * 0.12, 0.7 + i * 0.1),
              label: tiles[i].$3,
            ),
          ),
        ],
        const SizedBox(height: AppSpace.lg),
        _rise(0.55, _AnanSays(l10n.yearReviewAnanTogether)),
      ],
    );
  }

  Widget _locked(BuildContext context) {
    final l10n = context.l10n;
    return RevealCentered(
      scroll: true,
      children: [
        _hero(
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: _Fan(
              cards: _r.postcards.reversed.take(3).toList(),
              width: 150,
            ),
          ),
          curve: Curves.easeOutBack,
        ),
        const SizedBox(height: AppSpace.xl),
        _rise(0.2, _Headline(l10n.yearReviewLocked, size: 28)),
        const SizedBox(height: AppSpace.xl),
        _rise(
          0.3,
          CopperCta(
            label: l10n.plusLockedSheetCta,
            leading: CinematicGlyph.plus,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PaywallScreen(source: 'year_review'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _end(BuildContext context) {
    final l10n = context.l10n;
    return RevealCentered(
      scroll: true,
      children: [
        _hero(const CloudMascot(face: CloudFace.sucesso, size: 170)),
        const SizedBox(height: AppSpace.md),
        _rise(
          0.25,
          AnanSpeechBubble(
            child: Text(
              l10n.yearReviewEndBody('${_r.year + 1}'),
              textAlign: TextAlign.center,
              style: AppTypography.display(
                size: 24,
                color: AnanSpeechBubble.ink,
                height: 1.25,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _shareSlide(BuildContext context) {
    final l10n = context.l10n;
    final plus = context.read<SubscriptionService>().plusFeaturesOpen;
    return Column(
      children: [
        const SizedBox(height: AppSpace.md),
        _rise(
          0,
          SectionLabel(l10n.yearReviewShareEyebrow, color: AppRoles.reward),
        ),
        const SizedBox(height: AppSpace.md),
        Expanded(
          child: KeyedSubtree(
            key: _focusKey,
            child: ScaleTransition(
              scale: _slice(0, 0.4, Curves.easeOutBack),
              child: FittedBox(
                child: RepaintBoundary(
                  key: _cardKey,
                  child: _YearCard(review: _r, plus: plus),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.screen,
            AppSpace.lg,
            AppSpace.screen,
            AppSpace.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CopperCta(
                label: l10n.yearReviewShareCta,
                leading: CinematicGlyph.share,
                expanded: true,
                onTap: _sharing ? null : _share,
              ),
              const SizedBox(height: AppSpace.sm),
              GhostCta(
                label: l10n.yearReviewVideoCta,
                leading: plus ? CinematicGlyph.spark : CinematicGlyph.plus,
                expanded: true,
                onTap: _sharing ? null : () => shareYearVideo(context, _r),
              ),
              const SizedBox(height: AppSpace.sm),
              GhostCta(
                label: l10n.commonClose,
                expanded: true,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  final String text;
  final double size;

  const _Headline(this.text, {this.size = 36});

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: AppTypography.display(
      size: size,
      color: AppColors.textOnDark,
      height: 1.15,
    ),
  );
}

class _Big extends StatelessWidget {
  final String text;
  final double size;

  const _Big(this.text, {this.size = 96});

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Padding(
      // Folga para acento e descendente da Cormorant (altura de linha 1
      // cortava o "ê" de Gênesis).
      padding: EdgeInsets.symmetric(vertical: size * 0.08),
      child: Text(
        text,
        maxLines: 1,
        style: AppTypography.display(
          size: size,
          exact: true,
          color: AppRoles.reward,
          height: 1.2,
        ),
      ),
    ),
  );
}

/// Número que sobe de 0 até [value] no ritmo de [anim].
class _Count extends StatelessWidget {
  final int value;
  final Animation<double> anim;

  const _Count({required this.value, required this.anim});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: anim,
    builder: (_, _) => _Big('${(value * anim.value).round()}'),
  );
}

class _Line extends StatelessWidget {
  final String text;
  final bool faint;

  const _Line(this.text, {this.faint = false});

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: AppTypography.body(
      size: 17,
      color: AppColors.textOnDark.withValues(alpha: faint ? 0.6 : 0.88),
      height: 1.4,
    ),
  );
}

/// Círculo de luz com um símbolo: o destaque dos slides sem pintura.
class _Emblem extends StatelessWidget {
  final CinematicGlyph glyph;
  final double size;

  const _Emblem({required this.glyph, this.size = 128});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color.lerp(AppColors.night, AppRoles.reward, 0.26)!,
            AppColors.night,
          ],
        ),
        border: Border.all(
          color: AppRoles.reward.withValues(alpha: 0.8),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppRoles.reward.withValues(alpha: 0.4),
            blurRadius: 46,
            spreadRadius: 4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: CinematicIcon(
        glyph: glyph,
        size: size * 0.42,
        accent: AppRoles.reward,
        framed: false,
      ),
    );
  }
}

/// Título e frase do perfil do ano.
(String, String) personaCopy(AppLocalizations l10n, YearPersona p) =>
    switch (p) {
      YearPersona.group => (
        l10n.yearReviewPersonaGroup,
        l10n.yearReviewPersonaGroupLine,
      ),
      YearPersona.advent => (
        l10n.yearReviewPersonaAdvent,
        l10n.yearReviewPersonaAdventLine,
      ),
      YearPersona.reader => (
        l10n.yearReviewPersonaReader,
        l10n.yearReviewPersonaReaderLine,
      ),
      YearPersona.explorer => (
        l10n.yearReviewPersonaExplorer,
        l10n.yearReviewPersonaExplorerLine,
      ),
      YearPersona.constant => (
        l10n.yearReviewPersonaConstant,
        l10n.yearReviewPersonaConstantLine,
      ),
      YearPersona.grower => (
        l10n.yearReviewPersonaGrower,
        l10n.yearReviewPersonaGrowerLine,
      ),
      YearPersona.pilgrim => (
        l10n.yearReviewPersonaPilgrim,
        l10n.yearReviewPersonaPilgrimLine,
      ),
    };

CinematicGlyph personaGlyph(YearPersona p) => switch (p) {
  YearPersona.group => CinematicGlyph.people,
  YearPersona.advent => CinematicGlyph.star,
  YearPersona.reader => CinematicGlyph.book,
  YearPersona.explorer => CinematicGlyph.mountain,
  YearPersona.constant => CinematicGlyph.flame,
  YearPersona.grower => CinematicGlyph.sprout,
  YearPersona.pilgrim => CinematicGlyph.path,
};

String? daypartLabel(AppLocalizations l10n, YearDaypart? d) => switch (d) {
  null => null,
  YearDaypart.dawn => l10n.yearReviewDaypartDawn,
  YearDaypart.morning => l10n.yearReviewDaypartMorning,
  YearDaypart.afternoon => l10n.yearReviewDaypartAfternoon,
  YearDaypart.night => l10n.yearReviewDaypartNight,
};

/// Os 66 livros em grade (11 por linha, ordem canônica). Acende em ordem
/// conforme [progress] (0–1): ouro cheio com postal, contorno com leitura.
class BibleMapGrid extends StatelessWidget {
  final List<String> labels;
  final Map<int, int> lit;
  final double progress;
  final double cell;
  final bool showLabels;

  const BibleMapGrid({
    super.key,
    required this.labels,
    required this.lit,
    this.progress = 1,
    this.cell = 26,
    this.showLabels = true,
  });

  static const columns = 11;

  @override
  Widget build(BuildContext context) {
    const gap = 3.0;
    const ink = AppColors.textOnDark;
    final shown = (labels.length * progress).ceil();
    return SizedBox(
      width: columns * cell + (columns - 1) * gap,
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var i = 0; i < labels.length; i++)
            _cell(i, i < shown ? (lit[i] ?? 0) : 0, ink),
        ],
      ),
    );
  }

  Widget _cell(int i, int level, Color ink) {
    final strong = level == 2;
    final soft = level == 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: cell,
      height: cell,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cell * 0.22),
        color: strong
            ? AppRoles.reward
            : soft
            ? AppRoles.reward.withValues(alpha: 0.18)
            : ink.withValues(alpha: i < 39 ? 0.06 : 0.09),
        border: soft
            ? Border.all(color: AppRoles.reward.withValues(alpha: 0.9))
            : null,
        boxShadow: strong
            ? [
                BoxShadow(
                  color: AppRoles.reward.withValues(alpha: 0.5),
                  blurRadius: cell * 0.4,
                ),
              ]
            : null,
      ),
      child: showLabels
          ? Text(
              labels[i],
              maxLines: 1,
              style: AppTypography.label(
                size: cell * 0.32,
                weight: FontWeight.w700,
                color: strong
                    ? AppColors.night
                    : ink.withValues(alpha: soft ? 0.95 : 0.35),
              ),
            )
          : null,
    );
  }
}

/// O ano em pontos: uma linha por mês, um ponto por dia, aceso quando a
/// pessoa caminhou. Acende mês a mês conforme [progress].
class YearDots extends StatelessWidget {
  final int year;
  final Set<String> days;
  final double progress;
  final String locale;
  final double dot;

  const YearDots({
    super.key,
    required this.year,
    required this.days,
    required this.locale,
    this.progress = 1,
    this.dot = 7,
  });

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.textOnDark;
    final gap = dot * 0.36;
    final shownMonths = (12 * progress).ceil();
    final letter = DateFormat('MMMMM', locale);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var m = 1; m <= 12; m++)
          Padding(
            padding: EdgeInsets.only(bottom: gap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: dot * 1.8,
                  child: Text(
                    letter.format(DateTime(year, m)).toUpperCase(),
                    style: AppTypography.label(
                      size: dot * 1.15,
                      color: ink.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                for (var d = 1; d <= 31; d++)
                  Padding(
                    padding: EdgeInsets.only(right: d < 31 ? gap : 0),
                    child: _dot(m, d, m <= shownMonths, ink),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _dot(int m, int d, bool shown, Color ink) {
    final exists = DateTime(year, m, d).month == m;
    final key =
        '$year-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
    final on = shown && exists && days.contains(key);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: dot,
      height: dot,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: !exists
            ? Colors.transparent
            : on
            ? AppRoles.reward
            : ink.withValues(alpha: 0.1),
        boxShadow: on
            ? [
                BoxShadow(
                  color: AppRoles.reward.withValues(alpha: 0.55),
                  blurRadius: dot,
                ),
              ]
            : null,
      ),
    );
  }
}

/// Botão discreto de compartilhar o slide da tela.
class _SharePill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SharePill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.textOnDark;
    return Material(
      color: ink.withValues(alpha: 0.1),
      shape: StadiumBorder(
        side: BorderSide(color: ink.withValues(alpha: 0.28)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.share,
                size: 18,
                accent: ink,
                framed: false,
                glowing: false,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.label(
                  size: 13,
                  weight: FontWeight.w700,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rodapé da imagem compartilhada: a marca e o ano.
class _Brand extends StatelessWidget {
  final int year;

  const _Brand({required this.year});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpace.lg, top: AppSpace.sm),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const StwayWordmark(fontSize: 18, letterSpacing: 5),
        const SizedBox(height: 4),
        Text(
          context.l10n.yearReviewTitle('$year'),
          style: AppTypography.label(
            size: 11,
            color: AppColors.textOnDark.withValues(alpha: 0.65),
          ),
        ),
      ],
    ),
  );
}

/// Amostra da legenda do mapa.
class _Swatch extends StatelessWidget {
  final bool strong;

  const _Swatch({required this.strong});

  @override
  Widget build(BuildContext context) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(3),
      color: strong ? AppRoles.reward : AppRoles.reward.withValues(alpha: 0.18),
      border: strong ? null : Border.all(color: AppRoles.reward),
    ),
  );
}

class _Small extends StatelessWidget {
  final String text;

  const _Small(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.label(
      size: 12,
      color: AppColors.textOnDark.withValues(alpha: 0.7),
    ),
  );
}

/// Linha de número: símbolo, o número subindo e o que ele conta.
class _StatTile extends StatelessWidget {
  final CinematicGlyph glyph;
  final int value;
  final Animation<double> anim;
  final String label;

  const _StatTile({
    required this.glyph,
    required this.value,
    required this.anim,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.textOnDark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        color: ink.withValues(alpha: 0.06),
        border: Border.all(color: AppRoles.reward.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: 26,
            accent: AppRoles.reward,
            framed: false,
          ),
          const SizedBox(width: AppSpace.md),
          AnimatedBuilder(
            animation: anim,
            builder: (_, _) => Text(
              '${(value * anim.value).round()}',
              style: AppTypography.display(
                size: 40,
                exact: true,
                color: AppRoles.reward,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body(
                size: 15,
                color: ink.withValues(alpha: 0.85),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Marco da coleção: rótulo, título da cena e o dia.
class _Milestone extends StatelessWidget {
  final String label;
  final String title;
  final String date;

  const _Milestone({
    required this.label,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.textOnDark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        color: ink.withValues(alpha: 0.06),
        border: Border.all(color: AppRoles.presence.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(label, size: 10, color: AppRoles.presence),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(size: 16, color: ink),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Text(
            date,
            style: AppTypography.label(
              size: 12,
              color: ink.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// O Anan pequeno ao lado, comentando o slide.
class _AnanSays extends StatelessWidget {
  final String text;

  const _AnanSays(this.text);

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const CloudMascot(face: CloudFace.feliz, size: 60),
      const SizedBox(width: AppSpace.sm),
      Expanded(
        child: AnanSpeechBubble(
          tail: AnanTail.left,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Text(
            text,
            style: AppTypography.body(
              size: 15,
              weight: FontWeight.w600,
              color: AnanSpeechBubble.ink,
              height: 1.35,
            ),
          ),
        ),
      ),
    ],
  );
}

/// Até três postais em leque, o mais recente por cima.
class _Fan extends StatelessWidget {
  final List<Postcard> cards;
  final double width;

  const _Fan({required this.cards, this.width = 168});

  @override
  Widget build(BuildContext context) {
    const angles = [-0.16, 0.0, 0.16];
    final k = width / 168;
    final shifts = [-74.0 * k, 0.0, 74.0 * k];
    final shown = cards.reversed.toList();
    final offset = 3 - shown.length;
    return SizedBox(
      height: PostcardView.heightFor(width) + 40 * k,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < shown.length; i++)
            Transform.translate(
              offset: Offset(
                shifts[i + offset],
                ((i + offset == 1) ? -10 : 8) * k,
              ),
              child: Transform.rotate(
                angle: angles[i + offset],
                child: PostcardView(postcard: shown[i], width: width),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card do ano para story (9:16): marca, o perfil do ano, a Bíblia acesa
/// (ou os postais, sem mapa) e três números. Nada pessoal além disso.
class _YearCard extends StatelessWidget {
  final YearReview review;

  /// Com Plus o card leva também o livro mais visitado (slide do Plus).
  final bool plus;

  const _YearCard({required this.review, required this.plus});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = review;
    const ink = AppColors.textOnDark;
    final persona = personaCopy(l10n, r.persona);
    final part = daypartLabel(l10n, r.daypart);
    final stats = [
      (r.daysWalked > 0 ? r.daysWalked : r.days, l10n.yearReviewCardDays),
      (r.postcards.length, l10n.yearReviewCardPostcards),
      if (r.yearStreak > 1) (r.yearStreak, l10n.yearReviewCardStreak),
    ];
    return Container(
      width: 360,
      height: 640,
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: RadialGradient(
          center: const Alignment(0, -0.45),
          radius: 1.1,
          colors: [
            Color.lerp(AppColors.night, AppRoles.reward, 0.22)!,
            AppColors.night,
          ],
        ),
      ),
      child: Column(
        children: [
          const StwayWordmark(fontSize: 20, letterSpacing: 5),
          const SizedBox(height: 8),
          SectionLabel(
            l10n.yearReviewTitle('${r.year}'),
            size: 11,
            color: ink.withValues(alpha: 0.7),
          ),
          const Spacer(),
          _Emblem(glyph: personaGlyph(r.persona), size: 84),
          const SizedBox(height: 12),
          Text(
            persona.$1,
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 32,
              color: AppRoles.reward,
              height: 1.05,
            ),
          ),
          if (part != null) ...[
            const SizedBox(height: 4),
            Text(
              part,
              style: AppTypography.label(
                size: 12,
                color: ink.withValues(alpha: 0.7),
              ),
            ),
          ],
          const Spacer(),
          if (r.hasMap) ...[
            BibleMapGrid(labels: r.bookLabels, lit: r.litBooks, cell: 24),
            const SizedBox(height: 10),
            Text(
              l10n.yearReviewMapTitle(r.litBooks.length),
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w700,
                color: ink,
              ),
            ),
          ] else if (r.postcards.isNotEmpty)
            _Fan(cards: r.postcards.reversed.take(3).toList(), width: 110),
          const Spacer(),
          Row(
            children: [
              for (final s in stats)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${s.$1}',
                        style: AppTypography.display(
                          size: 34,
                          exact: true,
                          color: AppRoles.reward,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.$2,
                        textAlign: TextAlign.center,
                        style: AppTypography.label(
                          size: 11,
                          color: ink.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (plus && r.topBook != null) ...[
            const SizedBox(height: 12),
            Text(
              '${l10n.yearReviewBookEyebrow}: ${r.topBook}',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: ink.withValues(alpha: 0.85),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const CloudMascot(face: CloudFace.sucesso, size: 44),
        ],
      ),
    );
  }
}
