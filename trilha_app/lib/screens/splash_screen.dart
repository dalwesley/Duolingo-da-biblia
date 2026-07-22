import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backend_service.dart';
import '../services/content_catalog_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

/// Abertura cinematográfica — o vazio se abre, a trilha aparece, a marca respira.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// One-shot: força onboarding na próxima abertura após este update.
  static const _replayOnboardingKey = 'replayOnboarding_2026_07_21';

  static const _firstDuration = Duration(milliseconds: 4200);
  static const _returnDuration = Duration(milliseconds: 2100);

  late final AnimationController _master;
  late final AnimationController _drift;
  late final AnimationController _breathe;

  bool _readyToExit = false;
  bool _exiting = false;
  bool _isReturnVisit = false;
  bool _hitClimax = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _master = AnimationController(vsync: this, duration: _firstDuration);
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);

    _boot();
  }

  Future<void> _boot() async {
    final progress = context.read<ProgressService>();
    final load = progress.isLoaded ? Future<void>.value() : progress.load();

    await load;
    if (!mounted) return;

    _isReturnVisit = progress.hasSeenSplash;
    if (_isReturnVisit) {
      _master.duration = _returnDuration;
    }

    _master.addListener(_onMasterTick);
    await _master.forward();

    if (!mounted) return;
    if (!progress.hasSeenSplash) await progress.setHasSeenSplash(true);
    if (!mounted) return;

    await _exit(progress);
  }

  void _onMasterTick() {
    final climax = _isReturnVisit ? 0.38 : 0.42;
    if (!_hitClimax && _master.value >= climax) {
      _hitClimax = true;
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _exit(ProgressService progress) async {
    if (_exiting) return;
    _exiting = true;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    final backend = context.read<BackendService>();
    final deadline = DateTime.now().add(const Duration(seconds: 8));
    while (backend.isInitializing && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted) return;
    }

    final Widget next;
    if (!backend.isGoogleSignedIn) {
      next = const LoginScreen();
    } else {
      final league = context.read<LeagueService>();
      await backend.hydrateProgress(progress, league: league);
      if (!mounted) return;
      unawaited(() async {
        final saved = await backend.saveNow(
          progress,
          LeagueService.weekKey(),
          league: league,
        );
        if (saved) await progress.clearLegacyLocalPrefs();
      }());
      unawaited(ContentCatalogService.instance.ensureLoaded());

      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(_replayOnboardingKey) ?? false)) {
        await progress.setHasSeenOnboarding(false);
        await backend.saveNow(
          progress,
          LeagueService.weekKey(),
          league: league,
        );
        await prefs.setBool(_replayOnboardingKey, true);
      }

      next = progress.hasSeenOnboarding
          ? const MainShell()
          : const OnboardingScreen();
    }

    if (!mounted) return;
    setState(() => _readyToExit = true);
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, a, __, c) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
          child: c,
        ),
        transitionDuration: const Duration(milliseconds: 780),
      ),
    );
  }

  @override
  void dispose() {
    _master.removeListener(_onMasterTick);
    _master.dispose();
    _drift.dispose();
    _breathe.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Interval _i(double start, double end, {Curve curve = Curves.easeOutCubic}) {
    if (_isReturnVisit) {
      double map(double t) => (t * 0.78 + 0.04).clamp(0.0, 1.0);
      return Interval(map(start), map(end), curve: curve);
    }
    return Interval(start, end, curve: curve);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF050807),
        body: AnimatedBuilder(
          animation: Listenable.merge([_master, _drift, _breathe]),
          builder: (context, _) {
            final t = _master.value;
            final breath = _breathe.value;
            final drift = _drift.value;
            final exitFade = _readyToExit ? 0.0 : 1.0;

            final atmosphere = CurvedAnimation(
              parent: _master,
              curve: _i(0.0, 0.42, curve: Curves.easeOut),
            );
            final path = CurvedAnimation(
              parent: _master,
              curve: _i(0.18, 0.58, curve: Curves.easeInOutCubic),
            );
            final mark = CurvedAnimation(
              parent: _master,
              curve: _i(0.36, 0.62, curve: Curves.easeOutCubic),
            );
            final title = CurvedAnimation(
              parent: _master,
              curve: _i(0.48, 0.72),
            );
            final line = CurvedAnimation(
              parent: _master,
              curve: _i(0.58, 0.8),
            );
            final verse = CurvedAnimation(
              parent: _master,
              curve: _i(0.7, 0.92),
            );
            final letterbox = CurvedAnimation(
              parent: _master,
              curve: _i(0.0, 0.22),
            );

            final markV = mark.value.clamp(0.0, 1.0);
            final titleV = title.value.clamp(0.0, 1.0);
            final lineV = line.value.clamp(0.0, 1.0);
            final verseV = verse.value.clamp(0.0, 1.0);
            final atm = atmosphere.value.clamp(0.0, 1.0);

            return Opacity(
              opacity: exitFade,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFF050807)),

                  // Mundo — névoa, colinas, horizonte
                  RepaintBoundary(
                    child: CustomPaint(
                      size: size,
                      painter: _WorldPainter(
                        atmosphere: atm,
                        pathReveal: path.value.clamp(0.0, 1.0),
                        breath: breath,
                        drift: drift,
                      ),
                    ),
                  ),

                  // Vinheta profunda
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.05),
                          radius: 1.2,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.25 + 0.2 * (1 - atm)),
                            Colors.black.withValues(alpha: 0.78),
                          ],
                          stops: const [0.2, 0.58, 1],
                        ),
                      ),
                    ),
                  ),

                  // Conteúdo
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const Spacer(flex: 5),

                          // Marca visual — poço limpo, livro
                          Opacity(
                            opacity: markV,
                            child: Transform.scale(
                              scale: 0.82 + 0.18 * markV,
                              child: Transform.translate(
                                offset: Offset(0, 24 * (1 - markV)),
                                child: _Mark(
                                  breath: breath,
                                  intensity: atm,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // STEWAY — herói tipográfico
                          Opacity(
                            opacity: titleV,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - titleV)),
                              child: Text(
                                'STEWAY',
                                textAlign: TextAlign.center,
                                style: AppTypography.display(
                                  size: 58,
                                  weight: FontWeight.w600,
                                  color: const Color(0xFFF2EDE4),
                                  height: 0.95,
                                ).copyWith(
                                  letterSpacing: 14,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.28 * titleV),
                                      blurRadius: 32,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Linha de luz sob a marca
                          Opacity(
                            opacity: lineV,
                            child: Container(
                              width: 48 + 36 * lineV,
                              height: 1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.accent.withValues(alpha: 0.75),
                                    const Color(0xFFE8C9A0)
                                        .withValues(alpha: 0.9),
                                    AppColors.accent.withValues(alpha: 0.75),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Opacity(
                            opacity: lineV,
                            child: Transform.translate(
                              offset: Offset(0, 10 * (1 - lineV)),
                              child: Text(
                                'O caminho pela Palavra',
                                textAlign: TextAlign.center,
                                style: AppTypography.body(
                                  size: 15,
                                  height: 1.4,
                                  color: Colors.white.withValues(alpha: 0.58),
                                ).copyWith(letterSpacing: 0.6),
                              ),
                            ),
                          ),

                          const Spacer(flex: 4),

                          // Versículo — sussurro final
                          Opacity(
                            opacity: verseV * 0.95,
                            child: Transform.translate(
                              offset: Offset(0, 12 * (1 - verseV)),
                              child: Column(
                                children: [
                                  Text(
                                    'Lâmpada para os meus pés é a tua palavra,\ne luz para o meu caminho.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.display(
                                      size: 16,
                                      weight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                      height: 1.5,
                                      color: const Color(0xFFE8D5B8)
                                          .withValues(alpha: 0.82),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'SALMOS 119:105',
                                    style: AppTypography.label(
                                      size: 10,
                                      letterSpacing: 2.4,
                                      color:
                                          Colors.white.withValues(alpha: 0.32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Progresso mínimo — um fio
                          Opacity(
                            opacity: (0.2 + 0.8 * lineV).clamp(0.0, 1.0),
                            child: _BreathLine(value: t, breath: breath),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Letterbox
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: 36 + 8 * (1 - atm),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black,
                              Colors.black.withValues(
                                alpha: 0.85 * letterbox.value.clamp(0.0, 1.0),
                              ),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: 48 + 10 * (1 - atm),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black,
                              Colors.black.withValues(
                                alpha: 0.9 * letterbox.value.clamp(0.0, 1.0),
                              ),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Marca
// ---------------------------------------------------------------------------

class _Mark extends StatelessWidget {
  final double breath;
  final double intensity;

  const _Mark({required this.breath, required this.intensity});

  @override
  Widget build(BuildContext context) {
    final halo = 0.12 + 0.1 * breath;
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: halo * intensity),
                  blurRadius: 42 + 12 * breath,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                colors: [
                  Color.lerp(
                    const Color(0xFF2A3832),
                    AppColors.accent,
                    0.12,
                  )!,
                  const Color(0xFF0E1411),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
            child: const Center(
              child: CinematicIcon(
                glyph: CinematicGlyph.book,
                size: 42,
                accent: Color(0xFFE8C9A0),
                framed: false,
                glowing: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreathLine extends StatelessWidget {
  final double value;
  final double breath;

  const _BreathLine({required this.value, required this.breath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth * 0.42;
          return Center(
            child: Container(
              width: w,
              height: 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white.withValues(alpha: 0.08),
              ),
              clipBehavior: Clip.antiAlias,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0.05, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.35),
                          Color.lerp(
                            AppColors.accent,
                            const Color(0xFFE8C9A0),
                            0.45 + 0.2 * breath,
                          )!,
                          AppColors.accent.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mundo — horizonte oceânico ao entardecer, caminho de luz
// ---------------------------------------------------------------------------

class _WorldPainter extends CustomPainter {
  final double atmosphere;
  final double pathReveal;
  final double breath;
  final double drift;

  _WorldPainter({
    required this.atmosphere,
    required this.pathReveal,
    required this.breath,
    required this.drift,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final a = atmosphere;

    // Céu profundo → oceano
    final skyTop = Color.lerp(
      const Color(0xFF04060A),
      const Color(0xFF0A1420),
      a,
    )!;
    final skyMid = Color.lerp(
      const Color(0xFF060A10),
      const Color(0xFF0C1A2C),
      a * 0.85,
    )!;
    final skyLow = Color.lerp(
      const Color(0xFF080C14),
      const Color(0xFF1A3050),
      a * 0.7,
    )!;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyMid, skyLow, const Color(0xFF060A10)],
          stops: const [0.0, 0.35, 0.62, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Luz volumétrica no horizonte (sem raios baratos)
    final horizonY = size.height * 0.58;
    final glowCenter = Offset(size.width * 0.5, horizonY);
    canvas.drawCircle(
      glowCenter,
      size.width * (0.55 + 0.04 * breath),
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(
              const Color(0xFF4A7BA8),
              AppColors.accent,
              0.35,
            )!
                .withValues(alpha: 0.22 * a),
            AppColors.accent.withValues(alpha: 0.1 * a),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: glowCenter,
            radius: size.width * 0.6,
          ),
        ),
    );

    // Faixa quente no horizonte
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY - 30, size.width, 90),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.accent.withValues(alpha: 0.14 * a),
            const Color(0xFFE8C9A0).withValues(alpha: 0.06 * a),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, horizonY - 30, size.width, 90)),
    );

    // Silhuetas de colinas (camadas) — flutuação vertical suave
    final driftWave = drift * math.pi * 2;
    _hill(
      canvas,
      size,
      y: horizonY + 8 + math.sin(driftWave) * 5,
      amp: 28,
      phase: 0.8,
      color: const Color(0xFF0A1210).withValues(alpha: 0.55 * a),
      seed: 1,
    );
    _hill(
      canvas,
      size,
      y: horizonY + 36 + math.sin(driftWave + 1.2) * 7,
      amp: 42,
      phase: 1.6,
      color: const Color(0xFF070E0C).withValues(alpha: 0.72 * a),
      seed: 2,
    );
    _hill(
      canvas,
      size,
      y: horizonY + 70 + math.sin(driftWave * 0.6 + 2.0) * 9,
      amp: 56,
      phase: 2.4,
      color: const Color(0xFF050908).withValues(alpha: 0.9 * a),
      seed: 3,
    );

    // Névoa flutuante
    _mist(canvas, size, a, drift, breath);

    // Caminho de luz — perspectiva
    if (pathReveal > 0.01) {
      _path(canvas, size, pathReveal, breath, a);
    }
  }

  void _hill(
    Canvas canvas,
    Size size, {
    required double y,
    required double amp,
    required double phase,
    required Color color,
    required int seed,
  }) {
    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, y);
    for (var x = 0.0; x <= size.width; x += 6) {
      final n = math.sin(x * 0.012 + phase + seed) * amp +
          math.sin(x * 0.031 + seed * 2) * (amp * 0.35);
      path.lineTo(x, y + n);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _mist(
    Canvas canvas,
    Size size,
    double a,
    double drift,
    double breath,
  ) {
    final layers = [
      (0.32, 0.42, 0.08),
      (0.55, 0.62, 0.06),
      (0.72, 0.78, 0.05),
    ];
    for (var i = 0; i < layers.length; i++) {
      final (cy, rx, alpha) = layers[i];
      final verticalShift =
          size.height * 0.018 * math.sin(drift * math.pi * 2 + i * 1.4);
      final center = Offset(
        size.width * 0.5,
        size.height * cy + verticalShift,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: size.width * (0.7 + 0.1 * breath),
          height: size.height * rx * 0.35,
        ),
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: alpha * a * (0.7 + 0.3 * breath)),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCenter(
              center: center,
              width: size.width * 0.8,
              height: size.height * 0.2,
            ),
          )
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 28),
      );
    }
  }

  void _path(
    Canvas canvas,
    Size size,
    double reveal,
    double breath,
    double atm,
  ) {
    final pathLift = math.sin(breath * math.pi * 2) * 6;
    final start = Offset(size.width * 0.5, size.height * 0.97);
    final end = Offset(size.width * 0.5, size.height * 0.56 + pathLift);

    const steps = 40;
    final ptsL = <Offset>[];
    final ptsR = <Offset>[];
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      if (t > reveal) break;
      final y = ui.lerpDouble(start.dy, end.dy, t)!;
      final halfW =
          ui.lerpDouble(size.width * 0.2, 2.0, Curves.easeIn.transform(t))!;
      final x = size.width * 0.5;
      ptsL.add(Offset(x - halfW, y));
      ptsR.add(Offset(x + halfW, y));
    }
    if (ptsL.length < 2) return;

    final fill = Path()..moveTo(ptsL.first.dx, ptsL.first.dy);
    for (final p in ptsL.skip(1)) {
      fill.lineTo(p.dx, p.dy);
    }
    for (final p in ptsR.reversed) {
      fill.lineTo(p.dx, p.dy);
    }
    fill.close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.accent.withValues(alpha: 0.35 * atm),
            AppColors.accent.withValues(alpha: 0.18 * atm),
            const Color(0xFFE8C9A0).withValues(alpha: 0.12 * atm),
            Colors.transparent,
          ],
        ).createShader(Rect.fromPoints(start, end))
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant _WorldPainter old) =>
      old.atmosphere != atmosphere ||
      old.pathReveal != pathReveal ||
      old.breath != breath ||
      old.drift != drift;
}
