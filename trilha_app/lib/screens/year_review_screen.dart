import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/year_review.dart';
import '../l10n/app_language.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../widgets/act_feel.dart';
import '../widgets/anan_speech.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/postcard.dart';
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
  final review = await YearReview.build(progress, year ?? DateTime.now().year);
  if (!context.mounted) return;
  if (!force && !review.worthShowing) return;
  await Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => YearReviewScreen(review: review),
    ),
  );
}

/// Retrospectiva em stories: capa (grátis), postais, livro e modo
/// (Peregrino+) e o fechamento com o Anan. Toque à direita avança, à
/// esquerda volta.
class YearReviewScreen extends StatefulWidget {
  final YearReview review;

  const YearReviewScreen({super.key, required this.review});

  @override
  State<YearReviewScreen> createState() => _YearReviewScreenState();
}

class _YearReviewScreenState extends State<YearReviewScreen> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int delta, int count) {
    final next = (_page + delta).clamp(0, count - 1);
    if (next == _page) return;
    ActHaptics.tap();
    _pages.animateToPage(
      next,
      duration: AppMotion.standard,
      curve: AppMotion.enter,
    );
  }

  List<Widget> _slides(BuildContext context, bool plus) {
    final r = widget.review;
    final l10n = context.l10n;
    return [
      _Slide(
        children: [
          const CloudMascot(face: CloudFace.sucesso, size: 112),
          const SizedBox(height: AppSpace.xl),
          SectionLabel(l10n.yearReviewEyebrow, color: AppRoles.reward),
          const SizedBox(height: AppSpace.sm),
          _Headline(l10n.yearReviewTitle('${r.year}')),
          const SizedBox(height: AppSpace.xxl),
          _Big('${r.postcards.length}'),
          _Line(l10n.yearReviewPostcards(r.postcards.length)),
          const SizedBox(height: AppSpace.xs),
          _Line(l10n.yearReviewDays(r.days), faint: true),
        ],
      ),
      if (!plus)
        _LockedSlide(review: r)
      else ...[
        if (r.postcards.isNotEmpty)
          _Slide(
            children: [
              _Fan(cards: r.postcards.reversed.take(3).toList()),
              const SizedBox(height: AppSpace.xxl),
              _Line(
                l10n.yearReviewFirstLast(
                  r.postcards.first.title,
                  r.postcards.last.title,
                ),
              ),
            ],
          ),
        if (r.topBook != null)
          _Slide(
            anan: true,
            children: [
              SectionLabel(l10n.yearReviewBookEyebrow, color: AppRoles.reward),
              const SizedBox(height: AppSpace.md),
              _Big(r.topBook!, size: 64),
              _Line(l10n.yearReviewPostcards(r.topBookCount)),
            ],
          ),
        if (r.bestMode != null)
          _Slide(
            anan: true,
            children: [
              SectionLabel(l10n.yearReviewModeEyebrow, color: AppRoles.reward),
              const SizedBox(height: AppSpace.md),
              _Big(r.bestMode!.labelPt, size: 56),
              _Line(l10n.yearReviewModeLine(r.bestModePct)),
            ],
          ),
      ],
      _Slide(
        children: [
          AnanSpeech(
            face: CloudFace.sucesso,
            ananSize: 112,
            child: Text(
              l10n.yearReviewEndBody('${r.year + 1}'),
              textAlign: TextAlign.center,
              style: AppTypography.display(
                size: 26,
                color: AnanSpeechBubble.ink,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.xxl),
          CopperCta(
            label: l10n.commonClose,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final plus = context.select((SubscriptionService s) => s.plusFeaturesOpen);
    final slides = _slides(context, plus);
    const ink = AppColors.textOnDark;
    return Scaffold(
      backgroundColor: AppColors.night,
      body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 0.9,
                  colors: [
                    AppRoles.reward.withValues(alpha: 0.16),
                    AppColors.night.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          PageView(
            controller: _pages,
            onPageChanged: (i) => setState(() => _page = i),
            children: slides,
          ),
          // Toque à esquerda volta, à direita avança (como nos stories).
          Positioned.fill(
            top: 120,
            bottom: 160,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _go(-1, slides.length),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _go(1, slides.length),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  AppSpace.sm,
                  AppSpace.sm,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          for (var i = 0; i < slides.length; i++) ...[
                            if (i > 0) const SizedBox(width: 4),
                            Expanded(
                              child: AnimatedContainer(
                                duration: AppMotion.standard,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: ink.withValues(
                                    alpha: i <= _page ? 0.9 : 0.25,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      icon: CinematicIcon(
                        glyph: CinematicGlyph.close,
                        size: 32,
                        accent: ink.withValues(alpha: 0.85),
                        glowing: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final List<Widget> children;

  /// Anan pequeno no pé do slide (os do meio, sem nuvem própria).
  final bool anan;

  const _Slide({required this.children, this.anan = false});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.screen,
          56,
          AppSpace.screen,
          AppSpace.xl,
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            ),
            if (anan) const CloudMascot(face: CloudFace.feliz, size: 64),
          ],
        ),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  final String text;

  const _Headline(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: AppTypography.display(
      size: 36,
      color: AppColors.textOnDark,
      height: 1.1,
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
    child: Text(
      text,
      maxLines: 1,
      style: AppTypography.display(
        size: size,
        exact: true,
        color: AppRoles.reward,
        height: 1,
      ),
    ),
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

/// Até três postais em leque, o mais recente por cima.
class _Fan extends StatelessWidget {
  final List<Postcard> cards;

  const _Fan({required this.cards});

  @override
  Widget build(BuildContext context) {
    const width = 168.0;
    const angles = [-0.16, 0.0, 0.16];
    const shifts = [-74.0, 0.0, 74.0];
    final shown = cards.reversed.toList();
    final offset = 3 - shown.length;
    return SizedBox(
      height: PostcardView.heightFor(width) + 40,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < shown.length; i++)
            Transform.translate(
              offset: Offset(shifts[i + offset], (i + offset == 1) ? -10 : 8),
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

/// Sem Plus: o leque velado e o convite.
class _LockedSlide extends StatelessWidget {
  final YearReview review;

  const _LockedSlide({required this.review});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Slide(
      anan: true,
      children: [
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: _Fan(cards: review.postcards.reversed.take(3).toList()),
        ),
        const SizedBox(height: AppSpace.xxl),
        _Headline(l10n.yearReviewLocked),
        const SizedBox(height: AppSpace.xl),
        CopperCta(
          label: l10n.plusLockedSheetCta,
          leading: CinematicGlyph.plus,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const PaywallScreen(source: 'year_review'),
            ),
          ),
        ),
      ],
    );
  }
}
