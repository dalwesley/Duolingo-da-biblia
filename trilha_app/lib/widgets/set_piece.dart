import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Som do momento — sai junto com o emblema (mesmo frame da háptica).
enum SetPieceSound { none, streak, complete, crossing }

/// Um grande momento: tela cheia, luz da fonte principal, emblema com
/// juice, título serifado e um único botão. Travessia, marco de sequência,
/// virada de estação e fim de trilha usam o mesmo palco.
class SetPiece {
  final String eyebrow;
  final String title;
  final String? line;
  final CinematicGlyph glyph;

  /// Cor da luz do momento (papel: recompensa, sequência, estação…).
  final Color light;
  final String cta;
  final SetPieceSound sound;

  const SetPiece({
    required this.eyebrow,
    required this.title,
    required this.glyph,
    required this.light,
    required this.cta,
    this.line,
    this.sound = SetPieceSound.none,
  });
}

/// Mostra [piece] por cima de tudo. Resolve quando a pessoa segue.
Future<void> showSetPiece(BuildContext context, SetPiece piece) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      transitionDuration: AppMotion.gentle,
      reverseTransitionDuration: AppMotion.standard,
      pageBuilder: (_, _, _) => _SetPieceStage(piece: piece),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: AppMotion.enter,
          reverseCurve: AppMotion.exit,
        ),
        child: child,
      ),
    ),
  );
}

/// Lembra quais momentos já foram vistos — cada um acontece uma vez.
class SetPieceMemory {
  SetPieceMemory._();

  static const _prefix = 'setPiece:';
  static const _seasonKey = 'setPiece:lastSeason';

  /// `true` na primeira vez que [id] é pedido; marca como visto.
  static Future<bool> claim(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$id';
    if (prefs.getBool(key) ?? false) return false;
    await prefs.setBool(key, true);
    return true;
  }

  /// Estação nova desde a última abertura? A primeira abertura só anota
  /// (quem acabou de instalar não vê "nova estação").
  static Future<bool> seasonTurned(String season) async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_seasonKey);
    if (last == season) return false;
    await prefs.setString(_seasonKey, season);
    return last != null;
  }

  /// Marcos de sequência que viram momento: o compromisso escolhido e
  /// os números redondos da caminhada.
  static bool isStreakMilestone(int streak, {required int goal}) =>
      streak > 0 &&
      (streak == goal || const {7, 30, 50, 100, 200, 365}.contains(streak));
}

class _SetPieceStage extends StatefulWidget {
  final SetPiece piece;

  const _SetPieceStage({required this.piece});

  @override
  State<_SetPieceStage> createState() => _SetPieceStageState();
}

class _SetPieceStageState extends State<_SetPieceStage>
    with SingleTickerProviderStateMixin {
  /// Linha do tempo do momento (0–1): véu → luz → emblema → título → botão.
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  bool _struck = false;

  @override
  void initState() {
    super.initState();
    _t.addListener(_beat);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_t.isAnimating || _t.isCompleted) return;
    if (AppMotion.reduced(context)) {
      _t.value = 1;
      _strike();
    } else {
      _t.forward();
    }
  }

  /// O emblema pousa: som e háptica no mesmo instante.
  void _beat() {
    if (!_struck && _t.value >= 0.30) _strike();
  }

  void _strike() {
    _struck = true;
    ActHaptics.success();
    final sound = SoundService.instance;
    switch (widget.piece.sound) {
      case SetPieceSound.none:
        break;
      case SetPieceSound.streak:
        sound.playStreak();
      case SetPieceSound.complete:
        sound.playComplete();
      case SetPieceSound.crossing:
        sound.playComplete(boss: true);
    }
  }

  @override
  void dispose() {
    _t
      ..removeListener(_beat)
      ..dispose();
    super.dispose();
  }

  static double _span(double t, double a, double b) =>
      ((t - a) / (b - a)).clamp(0.0, 1.0);

  void _skipOrClose() {
    if (_t.value < 0.8) {
      _t.value = 1;
      if (!_struck) _strike();
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final piece = widget.piece;
    // O véu é sempre noite: texto claro, independente da aparência.
    const ink = AppColors.textOnDark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _skipOrClose,
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final t = _t.value;
          final veil = AppMotion.enter.transform(_span(t, 0, 0.18));
          final light = AppMotion.enter.transform(_span(t, 0.08, 0.55));
          final emblem = AppMotion.pop.transform(_span(t, 0.22, 0.42));
          final words = AppMotion.enter.transform(_span(t, 0.40, 0.66));
          final line = AppMotion.enter.transform(_span(t, 0.56, 0.80));
          final cta = AppMotion.enter.transform(_span(t, 0.78, 1));
          return Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: AppColors.night.withValues(alpha: 0.86 * veil)),
              IgnorePointer(
                child: CustomPaint(
                  painter: _LightPainter(
                    color: piece.light,
                    light: light,
                    drift: t,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.screen,
                  ),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      Transform.scale(
                        scale: 0.6 + 0.4 * emblem,
                        child: Opacity(
                          opacity: emblem.clamp(0.0, 1.0),
                          child: _Emblem(
                            glyph: piece.glyph,
                            color: piece.light,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpace.xxl),
                      _Rise(
                        t: words,
                        child: SectionLabel(piece.eyebrow, color: piece.light),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      _Rise(
                        t: words,
                        child: Text(
                          piece.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.display(
                            size: 40,
                            color: ink,
                            height: 1.05,
                          ),
                        ),
                      ),
                      if ((piece.line ?? '').isNotEmpty) ...[
                        const SizedBox(height: AppSpace.md),
                        _Rise(
                          t: line,
                          child: Text(
                            piece.line!,
                            textAlign: TextAlign.center,
                            style: AppTypography.body(
                              size: 16,
                              height: 1.45,
                              color: ink.withValues(alpha: 0.78),
                            ),
                          ),
                        ),
                      ],
                      const Spacer(flex: 4),
                      IgnorePointer(
                        ignoring: cta < 0.5,
                        child: Opacity(
                          opacity: cta,
                          child: CopperCta(
                            label: piece.cta,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpace.lg),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Sobe e acende — entrada de texto dos momentos.
class _Rise extends StatelessWidget {
  final double t;
  final Widget child;

  const _Rise({required this.t, required this.child});

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: t.clamp(0.0, 1.0),
    child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
  );
}

class _Emblem extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color color;

  const _Emblem({required this.glyph, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.night.withValues(alpha: 0.55),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 42,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: CinematicIcon(
        glyph: glyph,
        size: AppMetrics.iconHero,
        accent: color,
        framed: false,
        glowing: true,
      ),
    );
  }
}

/// Luz do momento: bloom vindo da fonte principal, raios lentos e poeira de
/// luz no ar. Um só pintor, sem blur — barato em aparelho intermediário.
class _LightPainter extends CustomPainter {
  final Color color;
  final double light;
  final double drift;

  _LightPainter({
    required this.color,
    required this.light,
    required this.drift,
  });

  static final _motes = List.generate(18, (i) {
    final r = math.Random(i * 7919);
    return (
      x: r.nextDouble(),
      y: r.nextDouble(),
      s: 0.6 + r.nextDouble() * 1.6,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (light <= 0) return;
    final center = Offset(size.width * 0.5, size.height * 0.36);
    final rect = Offset.zero & size;

    // Bloom a partir de cima (a luz principal), pousando no emblema.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(0, -0.28),
          radius: 0.9,
          colors: [
            color.withValues(alpha: 0.34 * light),
            color.withValues(alpha: 0.10 * light),
            color.withValues(alpha: 0),
          ],
          stops: const [0, 0.42, 1],
        ).createShader(rect),
    );

    // Raios: leque suave que gira devagar.
    final rays = Paint()..blendMode = BlendMode.plus;
    const count = 9;
    final spin = drift * 0.35;
    for (var i = 0; i < count; i++) {
      final a0 = -math.pi / 2 + (i - count / 2) * 0.22 + spin * 0.2;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(a0 - 0.035) * size.height,
          center.dy + math.sin(a0 - 0.035) * size.height,
        )
        ..lineTo(
          center.dx + math.cos(a0 + 0.035) * size.height,
          center.dy + math.sin(a0 + 0.035) * size.height,
        )
        ..close();
      rays.shader = RadialGradient(
        center: Alignment(
          (center.dx / size.width) * 2 - 1,
          (center.dy / size.height) * 2 - 1,
        ),
        radius: 0.9,
        colors: [
          color.withValues(alpha: 0.10 * light),
          color.withValues(alpha: 0),
        ],
      ).createShader(rect);
      canvas.drawPath(path, rays);
    }

    // Poeira de luz subindo.
    final mote = Paint()..color = Colors.white.withValues(alpha: 0.35 * light);
    for (final m in _motes) {
      final y = (m.y - drift * 0.18 * m.s) % 1.0;
      canvas.drawCircle(Offset(m.x * size.width, y * size.height), m.s, mote);
    }
  }

  @override
  bool shouldRepaint(_LightPainter old) =>
      old.light != light || old.drift != drift || old.color != color;
}
