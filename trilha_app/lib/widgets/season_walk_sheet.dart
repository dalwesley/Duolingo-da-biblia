import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/season_walk_catalog.dart';
import '../l10n/app_language.dart';
import '../models/season_walk.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/liturgical_calendar.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'season_countdown.dart';
import 'season_walk_together.dart';
import 'ui_primitives.dart';

/// Folha da Estação antes do início — o grande evento do ano no app.
///
/// Pintura viva no alto (aproximação lenta, estrelas piscando) com o título
/// por cima; contagem regressiva em placas; e o resto da altura para quem
/// já entrou (uma bolinha por peregrino), com o botão no pé.
Future<void> showSeasonWalkSheet(
  BuildContext context, {
  required SeasonWalkCampaign campaign,
  required DateTime seasonToday,
}) {
  return showAppSheet<void>(
    context,
    builder: (_) =>
        _SeasonWalkSheet(campaign: campaign, seasonToday: seasonToday),
  );
}

class _SeasonWalkSheet extends StatefulWidget {
  final SeasonWalkCampaign campaign;
  final DateTime seasonToday;

  const _SeasonWalkSheet({required this.campaign, required this.seasonToday});

  @override
  State<_SeasonWalkSheet> createState() => _SeasonWalkSheetState();
}

class _SeasonWalkSheetState extends State<_SeasonWalkSheet>
    with SingleTickerProviderStateMixin {
  // Um relógio só para a pintura: aproximação e estrelas.
  late final AnimationController _life = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _life.stop();
    } else if (!_life.isAnimating) {
      _life.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final media = MediaQuery.of(context);
    final campaign = widget.campaign;
    final tone = LiturgicalCalendar.accentOf(
      campaign.kind == SeasonWalkKind.advent
          ? LiturgicalSeason.advent
          : LiturgicalSeason.lent,
    );
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dates = DateFormat.MMMd(locale);
    final range =
        '${dates.format(campaign.start)} – ${dates.format(campaign.end)}';
    const radius = AppRadii.sheet;
    final height = media.size.height * 0.92 - 12;
    final heroH = (height * 0.38).clamp(220.0, 320.0);

    // Só o tema ("Espera do Verbo"); o ritmo vem na linha sob a contagem.
    final theme = campaign.subtitle.split(' · ').first;

    // ClipRect: a aproximação da pintura não vaza sobre a contagem.
    final hero = SizedBox(
      height: heroH,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _life,
                builder: (context, child) => Transform.scale(
                  scale: 1.0 + 0.08 * Curves.easeInOut.transform(_life.value),
                  alignment: const Alignment(0.4, -0.2),
                  child: child,
                ),
                child: Image.asset(
                  SeasonWalkCatalog.artAsset(campaign.kind),
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.15),
                ),
              ),
            ),
          ),
          RepaintBoundary(child: CustomPaint(painter: _Stars(_life, tone))),
          // Pé da pintura afunda na folha — o título fica sobre o escuro.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  a.cardFill.withValues(alpha: 0),
                  a.cardFill.withValues(alpha: 0.55),
                  a.cardFill,
                ],
                stops: const [0.35, 0.72, 1.0],
              ),
            ),
          ),
          const Positioned(
            top: AppSpace.md,
            left: 0,
            right: 0,
            child: Center(child: SheetGrabber()),
          ),
          Positioned(
            top: AppSpace.sm,
            right: AppSpace.sm,
            child: IconButton(
              tooltip: l10n.commonClose,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.45),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(40, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => Navigator.pop(context),
              icon: const CinematicIcon(
                glyph: CinematicGlyph.close,
                size: AppMetrics.iconMd,
                accent: Colors.white,
                framed: false,
              ),
            ),
          ),
          Positioned(
            left: AppSpace.xl,
            right: AppSpace.xl,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Pill(
                  text: '${l10n.walkTogetherKicker} · $range',
                  accent: tone,
                ),
                const SizedBox(height: AppSpace.sm),
                Text(
                  campaign.title,
                  style:
                      AppTypography.display(
                        size: 38,
                        height: 1.0,
                        color: a.text,
                      ).copyWith(
                        shadows: [
                          Shadow(
                            color: tone.withValues(alpha: 0.55),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  theme,
                  style: AppTypography.display(
                    size: 18,
                    weight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: Color.lerp(tone, Colors.white, 0.55)!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: contentMaxWidth,
            maxHeight: height,
            minHeight: height,
          ),
          child: Material(
            color: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: a.cardFill,
                border: Border.all(
                  color: tone.withValues(alpha: 0.55),
                  width: AppMetrics.cardBorderWidth,
                ),
                boxShadow: [
                  ...AppMetrics.cardShadow(elevated: true),
                  BoxShadow(
                    color: tone.withValues(alpha: 0.28),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  radius - AppMetrics.cardBorderWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    hero,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.xl,
                        AppSpace.lg,
                        AppSpace.xl,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SeasonCountdown(
                            opens: campaign.start,
                            seasonToday: widget.seasonToday,
                            color: a.text,
                            muted: a.textSecondary,
                            accent: tone,
                            large: true,
                          ),
                          const SizedBox(height: AppSpace.sm),
                          Text(
                            l10n.walkTogetherPitch(campaign.length),
                            style: AppTypography.body(
                              size: 13,
                              height: 1.4,
                              color: a.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpace.xl,
                          AppSpace.lg,
                          AppSpace.xl,
                          AppSpace.lg + media.padding.bottom,
                        ),
                        child: const SeasonWalkTogetherCard(
                          bare: true,
                          crowd: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color accent;

  const _Pill({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withValues(alpha: 0.35),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
      ),
      child: SectionLabel(text, size: 10, color: accent, maxLines: 1),
    );
  }
}

/// Estrelas piscando no céu da pintura (metade de cima), lugares fixos.
class _Stars extends CustomPainter {
  final Animation<double> clock;
  final Color tint;

  _Stars(this.clock, this.tint) : super(repaint: clock);

  static final _seeds = () {
    final rng = Random(7);
    return [
      for (var i = 0; i < 22; i++)
        (
          rng.nextDouble(),
          rng.nextDouble() * 0.45,
          0.6 + rng.nextDouble() * 1.4,
          rng.nextDouble() * 2 * pi,
        ),
    ];
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value * 2 * pi * 6;
    final paint = Paint();
    for (final (x, y, r, phase) in _seeds) {
      final twinkle = 0.25 + 0.75 * (0.5 + 0.5 * sin(t + phase));
      paint.color = Color.lerp(
        Colors.white,
        tint,
        0.25,
      )!.withValues(alpha: 0.85 * twinkle);
      canvas.drawCircle(Offset(x * size.width, y * size.height), r, paint);
    }
  }

  @override
  bool shouldRepaint(_Stars old) => false;
}
