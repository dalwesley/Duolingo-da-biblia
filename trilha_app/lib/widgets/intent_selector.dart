import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../models/user_intent.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'choice_portal.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Motivo de entrada — mesma forma do modo de estudo.
///
/// - [IntentBanner]: resumo vivo em Ajustes; abre [showIntentSheet].
/// - [IntentCarousel]: os quatro portais (sheet e onboarding).

/// Sheet "Seu motivo" — a mesma em Ajustes e onde mais precisar trocar.
Future<void> showIntentSheet(BuildContext context, {Color? tint}) {
  final progress = context.read<ProgressService>();
  final current = progress.settings.intent;
  return showChoiceSheet(
    context,
    eyebrow: (l10n) => l10n.intentSheetEyebrow,
    title: (l10n) => l10n.intentSheetTitle,
    tint: tint ?? current?.accent,
    carousel: (sheetContext) => IntentCarousel(
      selected: current,
      onCommitted: (intent) {
        progress.updateSettings(progress.settings.copyWith(intent: intent));
        Navigator.of(sheetContext).maybePop();
      },
    ),
  );
}

/// Quatro portais, um por motivo — deslize para conhecer, confirme no botão.
class IntentCarousel extends StatelessWidget {
  final UserIntent? selected;
  final double height;
  final ValueChanged<UserIntent>? onCommitted;

  /// Sem rodapé (CTA + nota) — o pai avança no próprio Continuar.
  final bool hideFooter;

  /// Enquanto desliza, avisa a página em foco (onboarding marca a escolha).
  final ValueChanged<UserIntent>? onFocused;

  const IntentCarousel({
    super.key,
    this.selected,
    this.height = 372,
    this.onCommitted,
    this.hideFooter = false,
    this.onFocused,
  });

  static const _intents = UserIntent.values;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final i = selected == null ? -1 : _intents.indexOf(selected!);
    return ChoiceCarousel(
      selected: i < 0 ? null : i,
      height: height,
      hideFooter: hideFooter,
      footnote: l10n.intentRuleFootnote,
      ctaLabel: (i, current) => current
          ? l10n.intentCtaContinue(_intents[i].title)
          : l10n.intentCtaChoose(_intents[i].title),
      onCommitted: onCommitted == null
          ? null
          : (i) => onCommitted!(_intents[i]),
      onFocused: onFocused == null ? null : (i) => onFocused!(_intents[i]),
      portals: [
        for (final intent in _intents)
          ChoicePortal(
            eyebrow: l10n.intentOrdinal(intent.ordinal),
            title: intent.title,
            tagline: intent.tagline,
            blurb: intent.blurb,
            chips: intent.skills,
            footer: l10n.intentOpensTrail(intent.entryTrailLabel),
            accent: intent.accent,
            emblem: ChoiceHalo.glyph(intent.glyph),
            scene: (context, t, focus, parallax) => CustomPaint(
              painter: IntentScenePainter(
                intent: intent,
                color: intent.accent,
                t: t,
                intensity: 0.35 + 0.65 * focus,
                parallax: parallax,
              ),
            ),
          ),
      ],
    );
  }
}

/// Faixa viva do motivo em Ajustes — espelho do [ModeBanner].
class IntentBanner extends StatefulWidget {
  const IntentBanner({super.key});

  @override
  State<IntentBanner> createState() => _IntentBannerState();
}

class _IntentBannerState extends State<IntentBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _life;
  bool _down = false;

  @override
  void initState() {
    super.initState();
    _life = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final intent = progress.settings.intent;
    final a = AppearanceStyle.resolve(AppearanceMode.night);
    final page = Appearance.of(context);
    final accent = intent?.accent ?? AppRoles.chrome;
    final onSky = AppColors.glyphInk(accent);
    final title = intent?.title ?? context.l10n.intentNoneTitle;
    final tagline = intent?.tagline ?? context.l10n.intentNoneTagline;
    final line = intent == null
        ? context.l10n.settingsIntentHint
        : context.l10n.intentOpensTrail(intent.entryTrailLabel);
    final glyph = intent?.glyph ?? CinematicGlyph.path;

    return Semantics(
      button: true,
      label: context.l10n.intentBannerSemantics(title, tagline),
      value: line,
      hint: context.l10n.intentBannerHint,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () => showIntentSheet(context, tint: intent?.accent),
        child: AnimatedScale(
          scale: _down ? 0.98 : 1,
          duration: AppMotion.quick,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
              border: Border.all(
                color: onSky.withValues(alpha: 0.6),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.24),
                  blurRadius: 26,
                  spreadRadius: -6,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Appearance(
              style: a,
              mode: AppearanceMode.night,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppMetrics.heroRadius - 1),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ArtLift(
                        page: page,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            RepaintBoundary(
                              child: AnimatedBuilder(
                                animation: _life,
                                builder: (context, _) => CustomPaint(
                                  painter: IntentScenePainter(
                                    intent: intent ?? UserIntent.know,
                                    color: accent,
                                    t: _life.value,
                                    intensity: intent == null ? 0.35 : 0.85,
                                  ),
                                ),
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    AppColors.night.withValues(alpha: 0.85),
                                    AppColors.night.withValues(alpha: 0.2),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Row(
                        children: [
                          ChoiceHalo(
                            emblem: ChoiceHalo.glyph(glyph),
                            accent: accent,
                            life: _life,
                            size: 64,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  intent == null
                                      ? context.l10n.intentSheetEyebrow
                                      : context.l10n.intentOrdinalBadge(
                                          intent.ordinal,
                                          context.l10n.intentBadgeHere,
                                        ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.label(
                                    size: 10,
                                    letterSpacing: 1.6,
                                    color: onSky.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  title,
                                  style: AppTypography.display(
                                    size: 20,
                                    height: 1.05,
                                    color: a.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tagline,
                                  style: AppTypography.body(
                                    size: 12,
                                    weight: FontWeight.w700,
                                    color: a.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  line,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.label(
                                    size: 11,
                                    color: a.textFaint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _IntentLadder(selected: intent),
                              const SizedBox(height: 12),
                              ChoicePill(
                                text: context.l10n.intentSwitch,
                                accent: accent,
                                solid: false,
                              ),
                            ],
                          ),
                        ],
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

/// Escada vertical dos quatro motivos (IV no topo).
class _IntentLadder extends StatelessWidget {
  final UserIntent? selected;

  const _IntentLadder({required this.selected});

  @override
  Widget build(BuildContext context) {
    final intents = UserIntent.values;
    final children = <Widget>[];
    for (var i = intents.length - 1; i >= 0; i--) {
      final intent = intents[i];
      final accent = intent.accent;
      final on = intent == selected;
      if (i < intents.length - 1) {
        children.add(
          Container(
            width: 2,
            height: 6,
            color: on
                ? accent.withValues(alpha: 0.8)
                : AppRoles.chrome.withValues(alpha: 0.18),
          ),
        );
      }
      children.add(
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? accent.withValues(alpha: 0.25) : Colors.transparent,
            border: Border.all(
              color: on ? accent : AppRoles.chrome.withValues(alpha: 0.25),
              width: on ? 2.2 : 1.4,
            ),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Cenas — mesma densidade dos portais de modo
// ─────────────────────────────────────────────────────────────────────────

/// Cena viva de cada motivo. [t] em 0–1 fecha o ciclo sem salto.
///
/// - Conhecer: presença — feixes quentes descem do alto.
/// - Sequência: chama — fogo sobe do chão, faíscas sobem.
/// - Entender: constelação — um pulso liga o céu.
/// - Paz: águas — anéis e ondas calmas.
class IntentScenePainter extends CustomPainter {
  final UserIntent intent;
  final Color color;
  final double t;
  final double intensity;
  final double parallax;

  IntentScenePainter({
    required this.intent,
    required this.color,
    required this.t,
    this.intensity = 1,
    this.parallax = 0,
  });

  static double _frac(double x) => x - x.floorToDouble();
  static const _tau = math.pi * 2;

  /// Acento levantado no céu — vermelho/ouro puros somem no night.
  Color get _sky {
    final lift = switch (intent) {
      UserIntent.know => 0.28,
      UserIntent.habit => 0.18,
      UserIntent.understand => 0.22,
      UserIntent.peace => 0.15,
    };
    return Color.lerp(color, Colors.white, lift)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const base = 0.42;
    final sky = _sky;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: switch (intent) {
            UserIntent.know => [
              Color.lerp(AppColors.night, sky, base * 0.35)!,
              Color.lerp(AppColors.night, sky, base * 0.95)!,
            ],
            UserIntent.habit => [
              Color.lerp(AppColors.night, sky, base * 0.25)!,
              Color.lerp(AppColors.night, sky, base * 1.05)!,
            ],
            UserIntent.understand => [
              Color.lerp(AppColors.night, sky, base * 0.75)!,
              Color.lerp(AppColors.night, sky, base * 0.28)!,
            ],
            UserIntent.peace => [
              Color.lerp(AppColors.night, sky, base * 0.55)!,
              Color.lerp(AppColors.night, Colors.black, 0.35)!,
            ],
          },
        ).createShader(rect),
    );
    final k = intensity;
    canvas.save();
    canvas.translate(parallax * size.width * 0.12, 0);
    switch (intent) {
      case UserIntent.know:
        _presence(canvas, size, k);
      case UserIntent.habit:
        _flame(canvas, size, k);
      case UserIntent.understand:
        _constellation(canvas, size, k);
      case UserIntent.peace:
        _waters(canvas, size, k);
    }
    canvas.restore();
  }

  /// Presença: feixes quentes do alto + chão que acende + mote que sobe.
  void _presence(Canvas canvas, Size size, double k) {
    final w = size.width;
    final h = size.height;
    final sky = _sky;
    final warm = Color.lerp(sky, AppRoles.streak, 0.35)!;
    final origin = Offset(w * 0.5, -h * 0.05);
    final sway = math.sin(t * _tau) * 0.04;
    final len = math.max(w, h) * 1.7;
    for (var i = 0; i < 5; i++) {
      final a = math.pi / 2 + (i - 2) * 0.18 + sway;
      final spread = 0.055 + 0.015 * i;
      final p1 =
          origin + Offset(math.cos(a - spread), math.sin(a - spread)) * len;
      final p2 =
          origin + Offset(math.cos(a + spread), math.sin(a + spread)) * len;
      canvas.drawPath(
        Path()
          ..moveTo(origin.dx, origin.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..close(),
        Paint()
          ..shader = RadialGradient(
            colors: [
              warm.withValues(alpha: 0.22 * k),
              warm.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: origin, radius: len * 0.65)),
      );
    }
    // Halo de encontro no meio do céu.
    final meet = Offset(w * 0.5, h * 0.38);
    canvas.drawCircle(
      meet,
      w * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: [
            sky.withValues(alpha: 0.48 * k),
            sky.withValues(alpha: 0.12 * k),
            sky.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: meet, radius: w * 0.42)),
    );
    // Chão que responde à luz.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 1.02),
        width: w * 1.35,
        height: h * 0.4,
      ),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                warm.withValues(alpha: 0.5 * k),
                warm.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(w / 2, h), radius: w * 0.75),
            ),
    );
    final mote = Color.lerp(warm, Colors.white, 0.45)!;
    final count = (w * h / 2800).clamp(14, 36).round();
    for (var i = 0; i < count; i++) {
      final x = w * (0.05 + 0.9 * _frac(i * 0.618));
      final speed = 0.55 + (i % 3) * 0.25;
      final p = _frac(t * speed + _frac(i * 0.293));
      final y = h * (1.02 - p * 1.05);
      final dx = math.sin((p * 2 + i * 0.17) * _tau) * 5;
      final alpha = math.sin(p * math.pi) * k;
      final r = 1.2 + 2.0 * _frac(i * 0.731);
      canvas.drawCircle(
        Offset(x + dx, y),
        r * 3.2,
        Paint()..color = warm.withValues(alpha: alpha * 0.16),
      );
      canvas.drawCircle(
        Offset(x + dx, y),
        r,
        Paint()..color = mote.withValues(alpha: alpha * 0.95),
      );
    }
  }

  /// Chama: fogo do chão + faíscas — a sequência que sobe todo dia.
  void _flame(Canvas canvas, Size size, double k) {
    final w = size.width;
    final h = size.height;
    final sky = _sky;
    final hot = Color.lerp(sky, Colors.white, 0.25)!;
    final base = Offset(w * 0.5, h * 0.98);
    // Línguas de fogo.
    for (var i = 0; i < 6; i++) {
      final sway = math.sin(t * _tau * 1.2 + i * 0.9) * 0.1;
      final a = -math.pi / 2 + sway + (i - 2.5) * 0.11;
      final len = h * (0.5 + (i % 3) * 0.08);
      final tip = base + Offset(math.cos(a), math.sin(a)) * len;
      final half = 14.0 - i * 1.2;
      canvas.drawPath(
        Path()
          ..moveTo(base.dx - half * 0.3, base.dy)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(base.dx + half * 0.3, base.dy)
          ..close(),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              sky.withValues(alpha: 0.55 * k),
              hot.withValues(alpha: 0.28 * k),
              hot.withValues(alpha: 0),
            ],
            stops: const [0, 0.45, 1],
          ).createShader(Rect.fromPoints(base, tip)),
      );
    }
    // Brasa no chão.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 1.02),
        width: w * 1.2,
        height: h * 0.36,
      ),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                sky.withValues(alpha: 0.62 * k),
                sky.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(w / 2, h), radius: w * 0.65),
            ),
    );
    for (var i = 0; i < 28; i++) {
      final x = w * (0.12 + 0.76 * _frac(i * 0.47));
      final p = _frac(t * (1.0 + (i % 4) * 0.28) + _frac(i * 0.29));
      final y = h * (0.98 - p * 0.88);
      final alpha = math.sin(p * math.pi) * k;
      final r = 1.1 + 1.8 * (1 - p);
      canvas.drawCircle(
        Offset(x + math.sin((p + i) * _tau) * 5, y),
        r * 2.8,
        Paint()..color = sky.withValues(alpha: alpha * 0.18),
      );
      canvas.drawCircle(
        Offset(x + math.sin((p + i) * _tau) * 5, y),
        r,
        Paint()..color = hot.withValues(alpha: alpha * 0.95),
      );
    }
  }

  /// Constelação: céu que cintila + traço que liga — entender o fio.
  void _constellation(Canvas canvas, Size size, double k) {
    final w = size.width;
    final h = size.height;
    final sky = _sky;
    for (var i = 0; i < 40; i++) {
      final x = w * _frac(i * 0.754 + 0.1);
      final y = h * _frac(i * 0.381 + 0.05);
      final tw = 0.5 + 0.5 * math.sin((t * 2 + _frac(i * 0.47)) * _tau);
      canvas.drawCircle(
        Offset(x, y),
        0.7 + 0.7 * _frac(i * 0.29),
        Paint()..color = Colors.white.withValues(alpha: (0.14 + 0.35 * tw) * k),
      );
    }
    final tall = h > w * 0.8;
    final pts = tall
        ? const [
            Offset(0.16, 0.55),
            Offset(0.34, 0.26),
            Offset(0.52, 0.44),
            Offset(0.70, 0.18),
            Offset(0.86, 0.38),
            Offset(0.68, 0.58),
          ]
        : const [
            Offset(0.18, 0.62),
            Offset(0.36, 0.28),
            Offset(0.54, 0.48),
            Offset(0.72, 0.22),
            Offset(0.88, 0.42),
            Offset(0.70, 0.64),
          ];
    final nodes = [for (final p in pts) Offset(p.dx * w, p.dy * h)];
    final segs = nodes.length - 1;
    final draw = (t / 0.7).clamp(0.0, 1.0);
    final fade = t < 0.85 ? 1.0 : 1 - (t - 0.85) / 0.15;
    final p = draw * segs;
    final seg = p.floor().clamp(0, segs - 1);
    final local = p - seg;
    final head = Offset.lerp(nodes[seg], nodes[seg + 1], local)!;

    final all = Path()..moveTo(nodes.first.dx, nodes.first.dy);
    for (final n in nodes.skip(1)) {
      all.lineTo(n.dx, n.dy);
    }
    canvas.drawPath(
      all,
      Paint()
        ..color = sky.withValues(alpha: 0.2 * k)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke,
    );

    final lit = Path()..moveTo(nodes.first.dx, nodes.first.dy);
    for (var i = 1; i <= seg; i++) {
      lit.lineTo(nodes[i].dx, nodes[i].dy);
    }
    lit.lineTo(head.dx, head.dy);
    canvas.drawPath(
      lit,
      Paint()
        ..color = sky.withValues(alpha: 0.28 * k * fade)
        ..strokeWidth = 9
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      lit,
      Paint()
        ..color = sky.withValues(alpha: 0.95 * k * fade)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    final star = Color.lerp(sky, Colors.white, 0.35)!;
    for (var i = 0; i < nodes.length; i++) {
      final reached = i < p + 0.02;
      final pop = reached ? 1 - (p - i).clamp(0.0, 1.0) : 0.0;
      final r = 2.6 + (reached ? 1.4 : 0) + 2.4 * pop;
      canvas.drawCircle(
        nodes[i],
        r * 3.2,
        Paint()
          ..color = sky.withValues(
            alpha: (reached ? 0.28 + 0.32 * pop : 0.06) * k * fade,
          ),
      );
      canvas.drawCircle(
        nodes[i],
        r,
        Paint()
          ..color = (reached ? star : sky).withValues(
            alpha: (reached ? 1.0 : 0.45) * k,
          ),
      );
    }
    if (draw < 1) {
      canvas.drawCircle(
        head,
        10,
        Paint()..color = sky.withValues(alpha: 0.32 * k),
      );
      canvas.drawCircle(
        head,
        2.8,
        Paint()..color = Colors.white.withValues(alpha: 0.95 * k),
      );
    }
  }

  /// Águas: luz suave + ondas — paz que desce (sem anéis).
  void _waters(Canvas canvas, Size size, double k) {
    final w = size.width;
    final h = size.height;
    final sky = _sky;
    final c = Offset(w * 0.5, h * 0.36);
    canvas.drawCircle(
      c,
      w * 0.36,
      Paint()
        ..shader = RadialGradient(
          colors: [
            sky.withValues(alpha: 0.42 * k),
            sky.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: w * 0.36)),
    );
    for (var layer = 0; layer < 3; layer++) {
      final baseY = h * (0.58 + layer * 0.12);
      final amp = h * (0.04 - layer * 0.008);
      final phase = t * _tau * (layer + 1) * (layer.isEven ? 1 : -1);
      final path = Path()..moveTo(0, h);
      for (var x = 0.0; x <= w + 4; x += 4) {
        final y =
            baseY + math.sin(x / w * _tau * (1.15 + layer * 0.4) + phase) * amp;
        path.lineTo(x, y);
      }
      path
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(
            sky,
            AppColors.night,
            0.35 + layer * 0.16,
          )!.withValues(alpha: (0.38 + layer * 0.16) * k),
      );
    }
    final grain = Color.lerp(sky, Colors.white, 0.35)!;
    for (var i = 0; i < 16; i++) {
      final x = w * (0.06 + 0.88 * _frac(i * 0.414));
      final p = _frac(t * 0.7 + _frac(i * 0.57));
      final y = h * (-0.02 + p * 1.05);
      canvas.drawCircle(
        Offset(x + math.sin((p + i * 0.3) * _tau) * 3, y),
        0.9 + _frac(i * 0.63) * 1.3,
        Paint()
          ..color = grain.withValues(alpha: math.sin(p * math.pi) * 0.65 * k),
      );
    }
  }

  @override
  bool shouldRepaint(covariant IntentScenePainter old) =>
      old.t != t ||
      old.intensity != intensity ||
      old.parallax != parallax ||
      old.color != color ||
      old.intent != intent;
}
