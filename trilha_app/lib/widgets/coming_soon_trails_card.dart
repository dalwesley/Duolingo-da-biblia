import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'realm_world_atmosphere.dart';
import 'ui_primitives.dart';

/// Página de doação no site. O pagamento fica fora do app.
const donatePageUrl = 'https://stway.com.br/doar';

/// Abre a página de doação no navegador externo.
Future<void> openDonatePage() {
  return launchUrl(
    Uri.parse(donatePageUrl),
    mode: LaunchMode.externalApplication,
  );
}

/// Slot vazio no fim do mapa — próximos lançamentos + sugestões.
class ComingSoonTrailsCard extends StatelessWidget {
  final VoidCallback onSuggest;
  final VoidCallback onSuggestAuthor;

  const ComingSoonTrailsCard({
    super.key,
    required this.onSuggest,
    required this.onSuggestAuthor,
  });

  @override
  Widget build(BuildContext context) {
    return _HorizonSlot(
      eyebrow: 'No horizonte',
      title: 'Lançamentos em breve',
      body: 'Novos caminhos estão sendo preparados.',
      primaryLabel: 'Sugerir uma trilha',
      primaryGlyph: CinematicGlyph.spark,
      onPrimary: onSuggest,
      secondaryLabel: 'Sugerir um autor',
      secondaryGlyph: CinematicGlyph.people,
      onSecondary: onSuggestAuthor,
    );
  }
}

/// Faixa sólida de doação — distinta do slot tracejado de lançamentos.
class DonateCard extends StatelessWidget {
  final VoidCallback onDonate;

  const DonateCard({super.key, required this.onDonate});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      tint: AppColors.accent,
      glow: 0.45,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const CinematicIcon(
                glyph: CinematicGlyph.gift,
                size: AppMetrics.leadingIcon,
                accent: AppColors.accent,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajude a continuar',
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Uma contribuição voluntária para o próximo passo.',
                      style: AppTypography.body(
                        size: 13,
                        height: 1.35,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CopperCta(
            label: 'Doar',
            leading: CinematicGlyph.gift,
            trailing: null,
            dense: true,
            showGlow: false,
            onTap: onDonate,
          ),
        ],
      ),
    );
  }
}

class _HorizonSlot extends StatefulWidget {
  final String eyebrow;
  final String title;
  final String body;
  final String primaryLabel;
  final CinematicGlyph primaryGlyph;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final CinematicGlyph? secondaryGlyph;
  final VoidCallback? onSecondary;

  const _HorizonSlot({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.primaryGlyph,
    required this.onPrimary,
    this.secondaryLabel,
    this.secondaryGlyph,
    this.onSecondary,
  });

  @override
  State<_HorizonSlot> createState() => _HorizonSlotState();
}

class _HorizonSlotState extends State<_HorizonSlot> {
  bool _pressed = false;

  bool get _hasSecondary =>
      widget.secondaryLabel != null && widget.onSecondary != null;

  void _primary() {
    ActHaptics.tap();
    widget.onPrimary();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    const accent = AppColors.accent;

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          height: _hasSecondary ? 292 : 232,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
              boxShadow: AppMetrics.cardShadow(elevated: false),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0B2430), Color(0xFF071820)],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _primary,
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              children: [
                                _PlusMark(
                                  accent: accent.withValues(alpha: 0.88),
                                ),
                                const SizedBox(height: 14),
                                FilmEyebrow(text: widget.eyebrow, accent: accent),
                                const SizedBox(height: 10),
                                Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.display(
                                    size: 20,
                                    color: a.text,
                                    height: 1.08,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.body,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.body(
                                    size: 13,
                                    height: 1.35,
                                    color: a.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                IgnorePointer(
                                  child: OutlineCta(
                                    label: widget.primaryLabel,
                                    leading: widget.primaryGlyph,
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_hasSecondary) ...[
                          const SizedBox(height: 8),
                          OutlineCta(
                            label: widget.secondaryLabel!,
                            leading: widget.secondaryGlyph,
                            onTap: widget.onSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _DashedRRectPainter(
                          color: AppColors.accent.withValues(alpha: 0.6),
                          radius: AppMetrics.heroRadius,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlusMark extends StatelessWidget {
  final Color accent;

  const _PlusMark({required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: CustomPaint(
        painter: _DashedCirclePainter(color: accent.withValues(alpha: 0.55)),
        child: Center(
          child: Text(
            '+',
            style: AppTypography.display(size: 28, color: accent, height: 1),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    final path = Path()..addOval(rect.deflate(1));
    _strokeDashed(canvas, path, paint, dash: 3.5, gap: 3);
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round;
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.8),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    _strokeDashed(canvas, path, paint, dash: 7, gap: 5.5);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

void _strokeDashed(
  Canvas canvas,
  Path path,
  Paint paint, {
  required double dash,
  required double gap,
}) {
  for (final metric in path.computeMetrics()) {
    var dist = 0.0;
    while (dist < metric.length) {
      final next = dist + dash;
      canvas.drawPath(
        metric.extractPath(dist, next.clamp(0, metric.length)),
        paint,
      );
      dist = next + gap;
    }
  }
}
