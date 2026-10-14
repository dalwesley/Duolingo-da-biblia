import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Raio do entalhe por onde a trilha entra e sai (para dentro).
const double kJourneyPhaseNotchR = 14.0;

/// Silhueta do marco de fase — cantos lisos, entalhes centrais para dentro.
Path journeyPhaseTicketPath(Rect bounds) {
  const corner = 18.0;
  final notchR = kJourneyPhaseNotchR;
  final left = bounds.left;
  final right = bounds.right;
  final top = bounds.top;
  final bottom = bounds.bottom;
  final cx = bounds.center.dx;
  final path = Path();

  // Sentido horário. Em Flutter, sweep positivo = horário (y para baixo).
  // Fundo: de π com +π passa pelo topo do círculo → entalhe para dentro.
  // Topo: de 0 com +π passa pela base do círculo → entalhe para dentro.
  path.moveTo(left + corner, bottom);
  path.lineTo(cx - notchR, bottom);
  path.arcTo(
    Rect.fromCircle(center: Offset(cx, bottom), radius: notchR),
    math.pi,
    math.pi,
    false,
  );
  path.lineTo(right - corner, bottom);
  path.quadraticBezierTo(right, bottom, right, bottom - corner);
  path.lineTo(right, top + corner);
  path.quadraticBezierTo(right, top, right - corner, top);
  path.lineTo(cx + notchR, top);
  path.arcTo(
    Rect.fromCircle(center: Offset(cx, top), radius: notchR),
    0,
    math.pi,
    false,
  );
  path.lineTo(left + corner, top);
  path.quadraticBezierTo(left, top, left, top + corner);
  path.lineTo(left, bottom - corner);
  path.quadraticBezierTo(left, bottom, left + corner, bottom);
  path.close();
  return path;
}

/// Marco de fase de ponta a ponta — ícone, rótulo, título e sussurro.
class JourneyPhaseCard extends StatelessWidget {
  final int phaseIndex;
  final String title;
  final String? whisper;
  final Color accent;
  final bool open;
  final CinematicGlyph glyph;

  const JourneyPhaseCard({
    super.key,
    required this.phaseIndex,
    required this.title,
    this.whisper,
    required this.accent,
    this.open = true,
    this.glyph = CinematicGlyph.book,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final nn = phaseIndex.toString().padLeft(2, '0');
    final label = context.l10n.journeyPhase(nn);
    final ink = open ? accent : a.textFaint;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Respiro lateral — o muro não cola na beira da tela.
        final width = math.max(0.0, constraints.maxWidth - 24);
        return SizedBox(
          width: width,
          child: Opacity(
            opacity: open ? 1 : 0.72,
            child: CustomPaint(
              painter: _PhaseTicketPainter(
                fill: a.cardFill,
                accent: ink,
                edge: Color.lerp(a.cardBorder, accent, open ? 0.55 : 0.18)!,
                glow: open
                    ? accent.withValues(alpha: 0.34)
                    : Colors.transparent,
                open: open,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                          color: ink.withValues(alpha: open ? 0.7 : 0.4),
                          width: 1.2,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ink.withValues(alpha: open ? 0.22 : 0.08),
                            ink.withValues(alpha: open ? 0.06 : 0.03),
                          ],
                        ),
                        boxShadow: open
                            ? [
                                BoxShadow(
                                  color: ink.withValues(alpha: 0.28),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: CinematicIcon(
                        glyph: glyph,
                        size: 26,
                        accent: ink,
                        framed: false,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(label, size: 11, color: ink),
                          const SizedBox(height: 3),
                          Container(
                            width: 44,
                            height: 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                colors: [
                                  ink,
                                  ink.withValues(alpha: 0.15),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.display(
                              size: 22,
                              height: 1.1,
                              color: a.text,
                            ),
                          ),
                          if (whisper != null && whisper!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              whisper!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(
                                size: 13,
                                height: 1.25,
                                color: a.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhaseTicketPainter extends CustomPainter {
  final Color fill;
  final Color accent;
  final Color edge;
  final Color glow;
  final bool open;

  const _PhaseTicketPainter({
    required this.fill,
    required this.accent,
    required this.edge,
    required this.glow,
    required this.open,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final path = journeyPhaseTicketPath(bounds);

    if (glow.a > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = glow
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 14),
      );
    }

    final wash = open ? 0.18 : 0.05;
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(fill, accent, wash)!,
            fill,
            Color.lerp(fill, const Color(0xFF000000), open ? 0.14 : 0.06)!,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(bounds),
    );

    // Filete superior — o marco “acende” na borda de cima.
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 3.5),
      Paint()
        ..shader = LinearGradient(
          colors: [
            accent.withValues(alpha: 0),
            accent.withValues(alpha: open ? 0.95 : 0.35),
            accent.withValues(alpha: 0),
          ],
          stops: const [0.08, 0.5, 0.92],
        ).createShader(Rect.fromLTWH(0, 0, size.width, 3.5)),
    );
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = open ? 1.45 : 1.15,
    );
  }

  @override
  bool shouldRepaint(covariant _PhaseTicketPainter old) =>
      old.fill != fill ||
      old.accent != accent ||
      old.edge != edge ||
      old.glow != glow ||
      old.open != open;
}
