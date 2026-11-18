import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/year_review.dart';
import '../l10n/app_language.dart';
import '../screens/paywall_screen.dart';
import '../screens/year_review_screen.dart';
import '../services/analytics_service.dart';
import '../services/app_update_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'postcard_share.dart';
import 'reveal_stage.dart';
import 'stway_brand.dart';
import 'ui_primitives.dart';

/// Vídeo do ano (Peregrino+): monta o quadro fora da tela, grava o MP4 no
/// encoder nativo (o mesmo do vídeo do postal) e abre o compartilhar. Sem
/// Plus, abre o paywall. Se o vídeo falhar, avisa e não compartilha nada.
Future<void> shareYearVideo(BuildContext context, YearReview review) async {
  final plus = context.read<SubscriptionService>().plusFeaturesOpen;
  if (!plus) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PaywallScreen(source: 'year_review_video'),
      ),
    );
    return;
  }
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  final key = GlobalKey();
  final t = ValueNotifier<double>(0);
  final progress = ValueNotifier<double?>(0);

  final frameEntry = OverlayEntry(
    builder: (_) => Positioned(
      left: -4000,
      top: 0,
      child: RepaintBoundary(
        key: key,
        child: ValueListenableBuilder<double>(
          valueListenable: t,
          builder: (_, value, _) => YearVideoFrame(review: review, t: value),
        ),
      ),
    ),
  );
  final progressEntry = OverlayEntry(
    builder: (_) => ValueListenableBuilder<double?>(
      valueListenable: progress,
      builder: (ctx, value, _) {
        if (value == null) return const SizedBox.shrink();
        const ink = AppColors.textOnDark;
        return Positioned.fill(
          child: ColoredBox(
            color: AppColors.night.withValues(alpha: 0.94),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screen * 2,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CloudMascot(face: CloudFace.carregando, size: 96),
                    const SizedBox(height: AppSpace.lg),
                    Text(
                      ctx.l10n.yearReviewVideoRendering,
                      textAlign: TextAlign.center,
                      style: AppTypography.title(size: 17, color: ink),
                    ),
                    const SizedBox(height: AppSpace.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        color: AppRoles.reward,
                        backgroundColor: ink.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  overlay.insert(frameEntry);
  overlay.insert(progressEntry);
  try {
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    final path = await PostcardVideo.renderFrames(
      boundaryKey: key,
      t: t,
      size: YearVideoFrame.size,
      seconds: YearVideoFrame.seconds,
      holdSeconds: 2,
      fileName: 'stway_ano_${review.year}.mp4',
      onProgress: (v) => progress.value = v,
    );
    progress.value = null;
    if (path == null || !context.mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: 'video/mp4')],
        text: context.l10n.yearReviewShareText(
          '${review.year}',
          AppUpdateService.androidStoreUrl,
        ),
      ),
    );
    await AnalyticsService.instance.logEvent('year_review_share', {
      'year': review.year,
      'postcards': review.postcards.length,
      'slide': 'video',
    });
  } catch (e) {
    debugPrint('Retrospectiva: vídeo falhou: $e');
    progress.value = null;
    if (context.mounted) {
      await showAppToastFor(
        context,
        message: context.l10n.postcardShareVideoFailed,
        tone: AppToastTone.warn,
      );
    }
  } finally {
    frameEntry.remove();
    progressEntry.remove();
    t.dispose();
    progress.dispose();
  }
}

enum _Scene { cover, map, days, numbers, persona }

/// Um quadro do vídeo do ano em [t] (0–1): capa, Bíblia acesa, o ano em
/// dias, os números e o perfil do ano. Cenas sem dado ficam de fora e as
/// outras dividem o tempo.
class YearVideoFrame extends StatelessWidget {
  final YearReview review;
  final double t;

  const YearVideoFrame({super.key, required this.review, required this.t});

  static const size = Size(360, 640);
  static const seconds = 16;

  List<(_Scene, double)> _scenes() => [
    (_Scene.cover, 1),
    if (review.hasMap) (_Scene.map, 1.3),
    if (review.daysWalked >= 3) (_Scene.days, 1.2),
    if (_numbers(null).isNotEmpty) (_Scene.numbers, 1),
    (_Scene.persona, 1.6),
  ];

  List<(int, String, String)> _numbers(BuildContext? context) {
    final r = review;
    final l10n = context?.l10n;
    String w(String Function() f) => l10n == null ? '' : f();
    return [
      if (r.chapters > 0)
        (r.chapters, w(() => l10n!.yearReviewChaptersWord(r.chapters)), ''),
      if (r.perfectScenes > 0)
        (
          r.perfectScenes,
          w(() => l10n!.yearReviewPerfectWord(r.perfectScenes)),
          '',
        ),
      if (r.trailsDone.isNotEmpty)
        (
          r.trailsDone.length,
          w(() => l10n!.yearReviewTrailsWord(r.trailsDone.length)),
          '',
        ),
      if (r.growth != null && r.growth!.delta > 0)
        (r.growth!.delta, w(() => l10n!.yearReviewGrowthWord), '+'),
    ].take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scenes = _scenes();
    final total = scenes.fold<double>(0, (a, s) => a + s.$2);
    var start = 0.0;
    final layers = <Widget>[];
    var focus = const Offset(0.5, 0.4);
    for (var i = 0; i < scenes.length; i++) {
      final a = start / total;
      final b = (start + scenes[i].$2) / total;
      start += scenes[i].$2;
      final last = i == scenes.length - 1;
      final local = ((t - a) / (b - a)).clamp(0.0, 1.0);
      final fadeIn = i == 0 ? 1.0 : (local / 0.12).clamp(0.0, 1.0);
      final fadeOut = last ? 1.0 : ((1 - local) / 0.1).clamp(0.0, 1.0);
      final visible = t >= a && (t < b || last);
      if (!visible) continue;
      focus = switch (scenes[i].$1) {
        _Scene.map => const Offset(0.5, 0.36),
        _Scene.days => const Offset(0.5, 0.36),
        _Scene.numbers => const Offset(0.5, 0.5),
        _ => const Offset(0.5, 0.38),
      };
      layers.add(
        Opacity(
          opacity: math.min(fadeIn, fadeOut),
          child: _scene(context, scenes[i].$1, local),
        ),
      );
    }
    // Fora da tela não há Material acima: sem ele, o Flutter sublinha todo
    // texto de amarelo (estilo de erro).
    return Material(
      type: MaterialType.transparency,
      child: SizedBox.fromSize(
        size: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.night),
            RevealStage(
              rays: AlwaysStoppedAnimation(t * 0.35),
              color: AppRoles.reward,
              focus: focus,
            ),
            ...layers,
            const Positioned(
              top: 26,
              left: 0,
              right: 0,
              child: Center(
                child: StwayWordmark(fontSize: 18, letterSpacing: 5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Progresso de [p] entre [from] e [to] da cena, com curva suave.
  static double _p(double p, double from, double to) =>
      Curves.easeOutCubic.transform(((p - from) / (to - from)).clamp(0.0, 1.0));

  Widget _rise(double v, Widget child) => Opacity(
    opacity: v,
    child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
  );

  Widget _scene(BuildContext context, _Scene scene, double p) {
    final l10n = context.l10n;
    final r = review;
    const ink = AppColors.textOnDark;
    final children = switch (scene) {
      _Scene.cover => [
        Transform.scale(
          scale: Curves.elasticOut.transform(_p(p, 0, 0.45)).clamp(0.0, 1.2),
          child: const CloudMascot(face: CloudFace.sucesso, size: 130),
        ),
        const SizedBox(height: 22),
        _rise(
          _p(p, 0.15, 0.4),
          Text(
            l10n.yearReviewTitle('${r.year}'),
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 34, color: ink, height: 1.1),
          ),
        ),
        const SizedBox(height: 20),
        _rise(
          _p(p, 0.3, 0.5),
          _big('${(r.postcards.length * _p(p, 0.3, 0.8)).round()}'),
        ),
        _rise(
          _p(p, 0.4, 0.6),
          _line(l10n.yearReviewPostcardsWord(r.postcards.length)),
        ),
      ],
      _Scene.map => [
        _rise(
          _p(p, 0, 0.15),
          SectionLabel(l10n.yearReviewMapEyebrow, color: AppRoles.reward),
        ),
        const SizedBox(height: 16),
        BibleMapGrid(
          labels: r.bookLabels,
          lit: r.litBooks,
          progress: _p(p, 0.05, 0.7),
          cell: 27,
        ),
        const SizedBox(height: 22),
        _rise(
          _p(p, 0.55, 0.75),
          Text(
            l10n.yearReviewMapTitle(r.litBooks.length),
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 28, color: ink, height: 1.15),
          ),
        ),
      ],
      _Scene.days => [
        _rise(
          _p(p, 0, 0.15),
          SectionLabel(l10n.yearReviewDaysEyebrow, color: AppRoles.reward),
        ),
        const SizedBox(height: 16),
        YearDots(
          year: r.year,
          days: r.walkedDays,
          progress: _p(p, 0.05, 0.65),
          locale: l10n.localeName,
          dot: 7.4,
        ),
        const SizedBox(height: 18),
        _big('${(r.daysWalked * _p(p, 0.4, 0.8)).round()}'),
        _rise(_p(p, 0.5, 0.7), _line(l10n.yearReviewDaysWord(r.daysWalked))),
        if (r.yearStreak > 1)
          _rise(
            _p(p, 0.6, 0.8),
            _line(l10n.yearReviewYearStreak(r.yearStreak), faint: true),
          ),
      ],
      _Scene.numbers => [
        for (final (i, n) in _numbers(context).indexed) ...[
          if (i > 0) const SizedBox(height: 22),
          _rise(
            _p(p, 0.05 + i * 0.15, 0.3 + i * 0.15),
            Column(
              children: [
                _big(
                  '${n.$3}'
                  '${(n.$1 * _p(p, 0.05 + i * 0.15, 0.5 + i * 0.15)).round()}',
                  size: 64,
                ),
                _line(n.$2),
              ],
            ),
          ),
        ],
      ],
      _Scene.persona => _persona(context, p),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 70, 16, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  List<Widget> _persona(BuildContext context, double p) {
    final l10n = context.l10n;
    final r = review;
    const ink = AppColors.textOnDark;
    final copy = personaCopy(l10n, r.persona);
    final part = daypartLabel(l10n, r.daypart);
    final grow = Curves.easeOutBack.transform(_p(p, 0, 0.3));
    return [
      Transform.scale(
        scale: grow,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color.lerp(AppColors.night, AppRoles.reward, 0.3)!,
                AppColors.night,
              ],
            ),
            border: Border.all(color: AppRoles.reward, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppRoles.reward.withValues(alpha: 0.5),
                blurRadius: 50,
                spreadRadius: 6,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: CinematicIcon(
            glyph: personaGlyph(r.persona),
            size: 60,
            accent: AppRoles.reward,
            framed: false,
          ),
        ),
      ),
      const SizedBox(height: 24),
      _rise(
        _p(p, 0.2, 0.35),
        SectionLabel(
          l10n.yearReviewPersonaEyebrow('${r.year}'),
          color: AppRoles.reward,
        ),
      ),
      const SizedBox(height: 10),
      _rise(
        _p(p, 0.28, 0.45),
        Text(
          copy.$1,
          textAlign: TextAlign.center,
          style: AppTypography.display(
            size: 40,
            color: AppRoles.reward,
            height: 1.08,
          ),
        ),
      ),
      if (part != null) ...[
        const SizedBox(height: 10),
        _rise(
          _p(p, 0.38, 0.5),
          Text(
            part,
            style: AppTypography.label(
              size: 13,
              color: ink.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
      const SizedBox(height: 14),
      _rise(_p(p, 0.45, 0.6), _line(copy.$2)),
    ];
  }

  Widget _big(String text, {double size = 84}) => Text(
    text,
    style: AppTypography.display(
      size: size,
      exact: true,
      color: AppRoles.reward,
      height: 1.1,
    ),
  );

  Widget _line(String text, {bool faint = false}) => Text(
    text,
    textAlign: TextAlign.center,
    style: AppTypography.body(
      size: 17,
      color: AppColors.textOnDark.withValues(alpha: faint ? 0.6 : 0.9),
      height: 1.35,
    ),
  );
}
