import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'choice_portal.dart';
import 'immersive_background.dart';

/// Tema — mesma forma do motivo e do modo: linha em Ajustes abre
/// [showAppearanceSheet], com um portal por céu.

extension AppearanceChoiceX on AppearanceMode {
  /// Cor da ilustração (sol, entardecer, lua, ciclo) — cenário, não papel
  /// de UI.
  Color get accent => switch (this) {
    AppearanceMode.morning => AppColors.accent,
    AppearanceMode.afternoon => AppColors.ember,
    AppearanceMode.night => AppColors.orchid,
    AppearanceMode.automatic => AppColors.slate,
  };

  String caption(AppLocalizations l10n) => switch (this) {
    AppearanceMode.morning => l10n.settingsThemeCaptionLight,
    AppearanceMode.afternoon => l10n.settingsThemeCaptionMedium,
    AppearanceMode.night => l10n.settingsThemeCaptionDark,
    AppearanceMode.automatic => l10n.settingsThemeCaptionAuto,
  };

  String blurb(AppLocalizations l10n) => switch (this) {
    AppearanceMode.morning => l10n.settingsThemeBlurbLight,
    AppearanceMode.afternoon => l10n.settingsThemeBlurbMedium,
    AppearanceMode.night => l10n.settingsThemeBlurbDark,
    AppearanceMode.automatic => l10n.settingsThemeBlurbAuto,
  };
}

/// Sheet "Tema" — o portal em foco já veste o app (prévia ao vivo, sheet
/// aberta); o botão fica com ele. Fechar sem o botão volta ao tema de antes.
Future<void> showAppearanceSheet(BuildContext context) async {
  final progress = context.read<ProgressService>();
  final current = progress.settings.appearanceMode;
  var committed = false;
  void wear(AppearanceMode mode) {
    if (progress.settings.appearanceMode == mode) return;
    progress.updateSettings(progress.settings.copyWith(appearanceMode: mode));
  }

  await showChoiceSheet(
    context,
    eyebrow: (l10n) => l10n.settingsThemeLabel,
    title: (l10n) => l10n.settingsThemeSheetTitle,
    tint: current.accent,
    carousel: (sheetContext) => AppearanceCarousel(
      selected: current,
      onFocused: wear,
      onCommitted: (mode) {
        committed = true;
        wear(mode);
        Navigator.of(sheetContext).maybePop();
      },
    ),
  );
  if (!committed) wear(current);
}

/// Quatro portais, um por tema.
class AppearanceCarousel extends StatelessWidget {
  final AppearanceMode selected;
  final ValueChanged<AppearanceMode> onCommitted;

  /// Portal em foco (prévia ao vivo).
  final ValueChanged<AppearanceMode>? onFocused;

  const AppearanceCarousel({
    super.key,
    required this.selected,
    required this.onCommitted,
    this.onFocused,
  });

  static const _modes = AppearanceMode.values;
  static const _ordinals = ['I', 'II', 'III', 'IV'];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ChoiceCarousel(
      selected: _modes.indexOf(selected),
      footnote: l10n.settingsThemeHint,
      ctaLabel: (i, current) => current
          ? l10n.intentCtaContinue(_modes[i].label)
          : l10n.intentCtaChoose(_modes[i].label),
      onCommitted: (i) => onCommitted(_modes[i]),
      onFocused: onFocused == null ? null : (i) => onFocused!(_modes[i]),
      portals: [
        for (final (i, mode) in _modes.indexed)
          ChoicePortal(
            eyebrow: l10n.settingsThemeOrdinal(_ordinals[i]),
            title: mode.label,
            tagline: mode.caption(l10n),
            blurb: mode.blurb(l10n),
            accent: mode.accent,
            emblem: (size, ink) => CustomPaint(
              size: Size.square(size * 1.15),
              painter: SkyMarkPainter(
                mode: mode,
                color: ink,
                t: 0,
                alive: false,
              ),
            ),
            look: AppearanceStyle.resolve(mode),
            tintPlate: false,
            liftSky: false,
            scene: (context, t, focus, parallax) => Stack(
              fit: StackFit.expand,
              children: [
                AmbientAtmosphere(phase: AppearanceStyle.resolve(mode).phase),
                CustomPaint(
                  painter: GlowScenePainter(
                    color: mode.accent,
                    t: t,
                    intensity: 0.3 + 0.6 * focus,
                    parallax: parallax,
                    sky: false,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Marcas do tema: sol entre nuvens, sol, lua entre nuvens, ciclo.
class SkyMarkPainter extends CustomPainter {
  final AppearanceMode mode;
  final Color color;
  final double t;
  final bool alive;
  final double amp;

  SkyMarkPainter({
    required this.mode,
    required this.color,
    required this.t,
    required this.alive,
    this.amp = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;
    final wave = t * math.pi * 2;
    final breathe = 0.5 + 0.5 * math.sin(wave);
    final drift = math.sin(wave) * amp;
    final drift2 = math.cos(wave) * amp;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final soft = Paint()
      ..color = color.withValues(alpha: 0.86)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (alive) {
      canvas.drawCircle(
        c,
        s * (0.46 + breathe * 0.05 * amp),
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: (0.16 + breathe * 0.12) * amp),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: s * 0.52)),
      );
    }

    switch (mode) {
      case AppearanceMode.morning:
        _sun(
          canvas,
          c + Offset(0, -s * 0.08),
          s * (0.9 + breathe * 0.04 * amp),
          fill,
          spin: wave,
        );
        _cloud(
          canvas,
          c + Offset(-s * 0.08 + drift * s * 0.05, s * 0.18),
          s * 0.72,
          fill,
        );
        _cloud(
          canvas,
          c + Offset(s * 0.18 + drift2 * s * 0.04, s * 0.22),
          s * 0.5,
          soft,
        );
      case AppearanceMode.afternoon:
        _sun(
          canvas,
          c + Offset(0, -s * 0.06),
          s * (0.94 + breathe * 0.05 * amp),
          fill,
          spin: wave * 0.7,
        );
        _cloud(
          canvas,
          c + Offset(s * 0.02 + drift * s * 0.04, s * 0.28),
          s * 0.55,
          soft,
        );
      case AppearanceMode.night:
        _star(
          canvas,
          c + Offset(s * 0.28, -s * 0.28),
          s * (0.08 + breathe * 0.025 * amp),
          Paint()
            ..color = color.withValues(alpha: 0.4 + breathe * 0.6 * amp)
            ..isAntiAlias = true,
        );
        _moon(
          canvas,
          c + Offset(-s * 0.04, -s * 0.08 + drift * s * 0.025),
          s * 0.88,
          fill,
        );
        _cloud(
          canvas,
          c + Offset(-s * 0.06 + drift * s * 0.04, s * 0.2),
          s * 0.7,
          fill,
        );
        _cloud(
          canvas,
          c + Offset(s * 0.2 + drift2 * s * 0.03, s * 0.24),
          s * 0.48,
          soft,
        );
      case AppearanceMode.automatic:
        _clock(canvas, c, s, fill, alive: alive);
    }
  }

  void _sun(Canvas canvas, Offset c, double s, Paint paint, {double spin = 0}) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(spin);
    canvas.drawCircle(Offset.zero, s * 0.16, paint);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final len = s * (i.isEven ? 0.13 : 0.09);
      final inner = s * 0.22;
      final p1 = Offset(math.cos(a) * inner, math.sin(a) * inner);
      final p2 = Offset(
        math.cos(a) * (inner + len),
        math.sin(a) * (inner + len),
      );
      final perp = Offset(-math.sin(a), math.cos(a)) * s * 0.04;
      canvas.drawPath(
        Path()
          ..moveTo(p1.dx + perp.dx, p1.dy + perp.dy)
          ..lineTo(p2.dx + perp.dx, p2.dy + perp.dy)
          ..lineTo(p2.dx - perp.dx, p2.dy - perp.dy)
          ..lineTo(p1.dx - perp.dx, p1.dy - perp.dy)
          ..close(),
        paint,
      );
    }
    canvas.restore();
  }

  void _cloud(Canvas canvas, Offset c, double s, Paint paint) {
    canvas.drawCircle(c + Offset(-s * 0.18, 0), s * 0.16, paint);
    canvas.drawCircle(c + Offset(s * 0.02, -s * 0.08), s * 0.2, paint);
    canvas.drawCircle(c + Offset(s * 0.2, 0), s * 0.14, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + Offset(0, s * 0.06),
          width: s * 0.62,
          height: s * 0.2,
        ),
        Radius.circular(s * 0.1),
      ),
      paint,
    );
  }

  void _moon(Canvas canvas, Offset c, double s, Paint paint) {
    final moon = Path()..addOval(Rect.fromCircle(center: c, radius: s * 0.2));
    final cut = Path()
      ..addOval(
        Rect.fromCircle(
          center: c + Offset(s * 0.1, -s * 0.05),
          radius: s * 0.17,
        ),
      );
    canvas.drawPath(Path.combine(PathOperation.difference, moon, cut), paint);
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2 - math.pi / 2;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
      final b = a + math.pi / 4;
      final q = c + Offset(math.cos(b) * r * 0.35, math.sin(b) * r * 0.35);
      path.lineTo(q.dx, q.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _clock(
    Canvas canvas,
    Offset c,
    double s,
    Paint paint, {
    required bool alive,
  }) {
    final ring = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawCircle(c, s * 0.32, ring);

    final tick = Paint()
      ..color = paint.color
      ..strokeWidth = s * 0.045
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2 - math.pi / 2;
      final inner = s * 0.24;
      final outer = s * 0.32;
      canvas.drawLine(
        c + Offset(math.cos(a) * inner, math.sin(a) * inner),
        c + Offset(math.cos(a) * outer, math.sin(a) * outer),
        tick,
      );
    }

    final now = DateTime.now();
    final hour =
        ((now.hour % 12) + now.minute / 60) / 12 * math.pi * 2 - math.pi / 2;
    final minute =
        (now.minute + now.second / 60) / 60 * math.pi * 2 - math.pi / 2;
    final second = alive
        ? (now.second + now.millisecond / 1000) / 60 * math.pi * 2 - math.pi / 2
        : minute;

    void hand(double angle, double len, double weight) {
      canvas.drawLine(
        c,
        c + Offset(math.cos(angle) * s * len, math.sin(angle) * s * len),
        Paint()
          ..color = paint.color
          ..strokeWidth = s * weight
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true,
      );
    }

    hand(hour, 0.16, 0.07);
    hand(minute, 0.24, 0.05);
    if (alive) {
      hand(second, 0.26, 0.03);
    }
    canvas.drawCircle(c, s * 0.035, paint);
  }

  @override
  bool shouldRepaint(covariant SkyMarkPainter old) =>
      old.mode != mode ||
      old.color != color ||
      old.t != t ||
      old.alive != alive ||
      old.amp != amp;
}
