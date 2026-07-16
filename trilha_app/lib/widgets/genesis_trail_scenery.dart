import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/genesis_theme.dart';

/// Capítulo full-bleed — mundo contínuo com cartão de título no estilo dos cards boas.
class GenesisModuleScenery extends StatefulWidget {
  final GenesisModuleTheme theme;
  final String moduleIcon;
  final String moduleTitle;
  final int sectionIndex;
  final Widget child;
  final bool isActiveChapter;
  final int? missionsDone;
  final int? missionsTotal;

  const GenesisModuleScenery({
    super.key,
    required this.theme,
    required this.moduleIcon,
    required this.moduleTitle,
    required this.sectionIndex,
    required this.child,
    this.isActiveChapter = false,
    this.missionsDone,
    this.missionsTotal,
  });

  @override
  State<GenesisModuleScenery> createState() => _GenesisModuleSceneryState();
}

class _GenesisModuleSceneryState extends State<GenesisModuleScenery> {
  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final mood = genesisMoodForTitle(widget.moduleTitle);

    return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(decoration: BoxDecoration(gradient: theme.sky)),
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _ChapterAtmospherePainter(
                    mood: mood,
                    accent: theme.decorColor,
                    pathAccent: theme.pathActive,
                    phase: 0.5,
                    intensity: widget.isActiveChapter ? 1 : 0.55,
                    seed: widget.sectionIndex * 47,
                  ),
                ),
              ),
            ),
            // Vinheta cinematográfica — escurece bordas, abre o centro
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.35),
                      radius: 1.25,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: widget.isActiveChapter ? 0.22 : 0.38),
                      ],
                      stops: const [0.45, 1],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.42),
                      ],
                      stops: const [0, 0.22, 1],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ChapterTitleCard(
                    title: widget.moduleTitle,
                    sectionIndex: widget.sectionIndex,
                    theme: theme,
                    highlighted: widget.isActiveChapter,
                    missionsDone: widget.missionsDone,
                    missionsTotal: widget.missionsTotal,
                  ),
                  SizedBox(height: widget.isActiveChapter ? 28 : 18),
                  widget.child,
                ],
              ),
            ),
          ],
        );
  }
}

/// Cartão de capítulo — mesma linguagem visual dos TrailCards que funcionam.
class _ChapterTitleCard extends StatelessWidget {
  final String title;
  final int sectionIndex;
  final GenesisModuleTheme theme;
  final bool highlighted;
  final int? missionsDone;
  final int? missionsTotal;

  const _ChapterTitleCard({
    required this.title,
    required this.sectionIndex,
    required this.theme,
    required this.highlighted,
    this.missionsDone,
    this.missionsTotal,
  });

  @override
  Widget build(BuildContext context) {
    final done = missionsDone ?? 0;
    final total = missionsTotal ?? 0;
    final pct = total > 0 ? done / total : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(18, highlighted ? 18 : 14, 18, highlighted ? 18 : 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(theme.nodeCurrentBottom, Colors.black, 0.35)!.withValues(alpha: highlighted ? 0.72 : 0.55),
            Color.lerp(theme.nodeCurrentTop, theme.nodeCurrentBottom, 0.55)!.withValues(alpha: highlighted ? 0.55 : 0.38),
          ],
        ),
        border: Border.all(
          color: highlighted
              ? theme.decorColor.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.12),
          width: highlighted ? 1.4 : 1,
        ),
        boxShadow: [
          if (highlighted)
            BoxShadow(
              color: theme.decorColor.withValues(alpha: 0.22),
              blurRadius: 28,
              offset: const Offset(0, 12),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título fica na app bar quando o capítulo está ativo — evita duplicar o topo.
          if (!highlighted)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CAPÍTULO ${_roman(sectionIndex)}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.6,
                          color: theme.decorColor.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                if (total > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '$done · $total',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.decorColor.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
              ],
            ),
          if (highlighted) ...[
            Text(
              theme.narrative,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              theme.verse,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: theme.decorColor.withValues(alpha: 0.88),
              ),
            ),
            if (total > 0) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 2.5,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  color: theme.pathActive,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static String _roman(int n) {
    const map = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
    if (n >= 1 && n <= map.length) return map[n - 1];
    return '$n';
  }
}

enum GenesisSceneMood { creation, garden, exile, waters, defaultMood }

GenesisSceneMood genesisMoodForTitle(String title) {
  final t = title.toLowerCase();
  if (t.contains('criação') || t.contains('criacao')) return GenesisSceneMood.creation;
  if (t.contains('jardim')) return GenesisSceneMood.garden;
  if (t.contains('libertação') || t.contains('libertacao') || t.contains('mar vermelho')) {
    return GenesisSceneMood.waters;
  }
  if (t.contains('depois') || t.contains('opressão') || t.contains('opressao')) {
    return GenesisSceneMood.exile;
  }
  return GenesisSceneMood.defaultMood;
}

class _ChapterAtmospherePainter extends CustomPainter {
  final GenesisSceneMood mood;
  final Color accent;
  final Color pathAccent;
  final double phase;
  final double intensity;
  final int seed;

  _ChapterAtmospherePainter({
    required this.mood,
    required this.accent,
    required this.pathAccent,
    required this.phase,
    required this.intensity,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (mood) {
      case GenesisSceneMood.creation:
        _paintCreation(canvas, size);
      case GenesisSceneMood.garden:
        _paintGarden(canvas, size);
      case GenesisSceneMood.exile:
        _paintExile(canvas, size);
      case GenesisSceneMood.waters:
        _paintWaters(canvas, size);
      case GenesisSceneMood.defaultMood:
        _paintDefault(canvas, size);
    }
  }

  void _paintCreation(Canvas canvas, Size size) {
    // Abismo — véu inferior (noite oliva, não azul puro)
    canvas.drawRect(
      Rect.fromLTRB(0, size.height * 0.55, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF061210).withValues(alpha: 0),
            const Color(0xFF030806).withValues(alpha: 0.55 * intensity),
            const Color(0xFF010403).withValues(alpha: 0.85 * intensity),
          ],
        ).createShader(Rect.fromLTRB(0, size.height * 0.55, size.width, size.height)),
    );

    // Luz primeira — glow no alto
    final light = Offset(size.width * 0.5, size.height * (0.08 + phase * 0.02));
    final r = size.width * (0.55 + phase * 0.04);
    canvas.drawCircle(
      light,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF6D8).withValues(alpha: 0.28 * intensity),
            pathAccent.withValues(alpha: 0.14 * intensity),
            Colors.transparent,
          ],
          stops: const [0, 0.35, 1],
        ).createShader(Rect.fromCircle(center: light, radius: r)),
    );

    // Estrelas do vazio
    final rnd = math.Random(seed);
    final count = (22 * intensity).round();
    for (var i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.48;
      final twinkle = 0.45 + 0.55 * ((math.sin(phase * math.pi * 2 + i * 0.9) + 1) / 2);
      canvas.drawCircle(
        Offset(x, y),
        0.7 + rnd.nextDouble() * 1.5,
        Paint()..color = Colors.white.withValues(alpha: 0.16 * twinkle * intensity),
      );
    }

    // Horizonte dourado suave
    final band = size.height * 0.62;
    canvas.drawRect(
      Rect.fromLTWH(0, band, size.width, 2),
      Paint()..color = pathAccent.withValues(alpha: 0.18 * intensity),
    );
  }

  void _paintGarden(Canvas canvas, Size size) {
    // Dossel — arcos verdes no alto
    for (var i = 0; i < 3; i++) {
      final cx = size.width * (0.15 + i * 0.35);
      final cy = -size.height * 0.05 + phase * 8;
      final rr = size.width * (0.42 + i * 0.06);
      canvas.drawCircle(
        Offset(cx, cy),
        rr,
        Paint()
          ..shader = RadialGradient(
            colors: [
              accent.withValues(alpha: 0.14 * intensity),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: rr)),
      );
    }

    // Feixes de luz
    final shaft = Path()
      ..moveTo(size.width * 0.42, 0)
      ..lineTo(size.width * 0.58, 0)
      ..lineTo(size.width * 0.72, size.height * 0.55)
      ..lineTo(size.width * 0.28, size.height * 0.55)
      ..close();
    canvas.drawPath(
      shaft,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.1 * intensity),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );

    // Solo vivo
    final ground = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * (0.58 - phase * 0.02),
        size.width * 0.55,
        size.height * 0.7,
      )
      ..quadraticBezierTo(size.width * 0.82, size.height * 0.82, size.width, size.height * 0.66)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      ground,
      Paint()..color = const Color(0xFF0E2A1C).withValues(alpha: 0.45 * intensity),
    );
  }

  void _paintExile(Canvas canvas, Size size) {
    // Poeira / calor
    final haze = Offset(size.width * 0.5, size.height * 0.35);
    canvas.drawCircle(
      haze,
      size.width * 0.7,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: 0.12 * intensity),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: haze, radius: size.width * 0.7)),
    );

    final dunes = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.68)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * (0.52 + phase * 0.02),
        size.width * 0.5,
        size.height * 0.66,
      )
      ..quadraticBezierTo(size.width * 0.78, size.height * 0.8, size.width, size.height * 0.58)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      dunes,
      Paint()..color = const Color(0xFF1A2214).withValues(alpha: 0.5 * intensity),
    );
  }

  void _paintWaters(Canvas canvas, Size size) {
    final deep = Rect.fromLTRB(0, size.height * 0.5, size.width, size.height);
    canvas.drawRect(
      deep,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // Águas frias dentro da família oliva/teal — não azul "outro mundo".
            const Color(0xFF0A2A28).withValues(alpha: 0.15 * intensity),
            const Color(0xFF041816).withValues(alpha: 0.65 * intensity),
          ],
        ).createShader(deep),
    );

    // Ondas sutis
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.58 + i * 0.08) + math.sin(phase * math.pi * 2 + i) * 4;
      final wave = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(size.width * 0.25, y - 8, size.width * 0.5, y)
        ..quadraticBezierTo(size.width * 0.75, y + 8, size.width, y);
      canvas.drawPath(
        wave,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.06 * intensity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _paintDefault(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.5, size.height * 0.12);
    canvas.drawCircle(
      c,
      size.width * 0.45,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withValues(alpha: 0.16 * intensity), Colors.transparent],
        ).createShader(Rect.fromCircle(center: c, radius: size.width * 0.45)),
    );
  }

  @override
  bool shouldRepaint(covariant _ChapterAtmospherePainter old) =>
      old.phase != phase || old.mood != mood || old.intensity != intensity;
}

class GenesisTrailHeader extends StatelessWidget {
  final String icon;
  final int done;
  final int total;

  const GenesisTrailHeader({
    super.key,
    required this.icon,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? done / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$done de $total missões',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70),
            ),
          ),
          Text(
            '${(pct * 100).round()}%',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
