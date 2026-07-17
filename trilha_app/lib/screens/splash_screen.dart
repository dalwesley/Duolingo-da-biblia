import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/backend_service.dart';
import '../services/content_catalog_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

/// Abertura — luz → marca → estudar.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _firstDuration = Duration(milliseconds: 3200);
  static const _returnDuration = Duration(milliseconds: 1600);

  late final AnimationController _master;
  late final AnimationController _shimmer;
  late final AnimationController _breathe;

  bool _readyToExit = false;
  bool _exiting = false;
  bool _isReturnVisit = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _master = AnimationController(vsync: this, duration: _firstDuration);
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _boot();
  }

  Future<void> _boot() async {
    final progress = context.read<ProgressService>();
    final load = progress.isLoaded
        ? Future<void>.value()
        : progress.load();

    await load;
    if (!mounted) return;

    _isReturnVisit = progress.hasSeenSplash;
    if (_isReturnVisit) {
      _master.duration = _returnDuration;
    }

    // Gatilhos de impacto no clímax da luz.
    _master.addListener(_onMasterTick);
    await _master.forward();

    if (!mounted) return;
    if (!progress.hasSeenSplash) await progress.setHasSeenSplash(true);
    if (!mounted) return;

    await _exit(progress);
  }

  bool _hitClimax = false;
  void _onMasterTick() {
    final climax = _isReturnVisit ? 0.42 : 0.48;
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
      // Sem bloquear a navegação: schema e catálogo carregam em segundo plano.
      // A Home exibe um skeleton enquanto o catálogo chega.
      unawaited(() async {
        final saved = await backend.saveNow(
          progress,
          LeagueService.weekKey(),
          league: league,
        );
        if (saved) await progress.clearLegacyLocalPrefs();
      }());
      unawaited(ContentCatalogService.instance.ensureLoaded());
      next = progress.hasSeenOnboarding
          ? const MainShell()
          : const OnboardingScreen();
    }

    if (!mounted) return;
    setState(() => _readyToExit = true);
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _master.removeListener(_onMasterTick);
    _master.dispose();
    _shimmer.dispose();
    _breathe.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  // Intervalos: primeira visita vs retorno (mais comprimidos).
  Interval _i(double start, double end) {
    if (_isReturnVisit) {
      // Comprime a narrativa mantendo a ordem emocional.
      double map(double t) => (t * 0.75 + 0.05).clamp(0.0, 1.0);
      return Interval(map(start), map(end), curve: Curves.easeOutCubic);
    }
    return Interval(start, end, curve: Curves.easeOutCubic);
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
        backgroundColor: const Color(0xFF030208),
        body: AnimatedBuilder(
          animation: Listenable.merge([_master, _shimmer, _breathe]),
          builder: (context, _) {
            final t = _master.value;
            final breath = _breathe.value;
            final exitFade = _readyToExit ? 0.0 : 1.0;

            final stars = CurvedAnimation(parent: _master, curve: _i(0.02, 0.28));
            final dawn = CurvedAnimation(parent: _master, curve: _i(0.18, 0.52));
            final seal = CurvedAnimation(parent: _master, curve: _i(0.38, 0.62));
            final title = CurvedAnimation(parent: _master, curve: _i(0.52, 0.72));
            final tagline = CurvedAnimation(parent: _master, curve: _i(0.62, 0.82));
            final verse = CurvedAnimation(parent: _master, curve: _i(0.72, 0.92));
            final letterbox = CurvedAnimation(parent: _master, curve: _i(0.0, 0.2));

            return Opacity(
              opacity: exitFade,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Void absoluto
                  const ColoredBox(color: Color(0xFF030208)),

                  // 2. Nebulosa + estrelas
                  RepaintBoundary(
                    child: CustomPaint(
                      size: size,
                      painter: _CinematicSkyPainter(
                        progress: stars.value,
                        shimmer: _shimmer.value,
                        breath: breath,
                        dawn: dawn.value,
                      ),
                    ),
                  ),

                  // 3. Aurora / raios da criação
                  RepaintBoundary(
                    child: CustomPaint(
                      size: size,
                      painter: _DawnRaysPainter(
                        progress: dawn.value,
                        breath: breath,
                      ),
                    ),
                  ),

                  // 4. Horizonte dourado + trilha
                  RepaintBoundary(
                    child: CustomPaint(
                      size: size,
                      painter: _HorizonPathPainter(
                        progress: dawn.value,
                        breath: breath,
                      ),
                    ),
                  ),

                  // 5. Vinheta cinematográfica
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.15),
                          radius: 1.15,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.15 + 0.35 * (1 - dawn.value)),
                            Colors.black.withValues(alpha: 0.72),
                          ],
                          stops: const [0.25, 0.62, 1],
                        ),
                      ),
                    ),
                  ),

                  // 6. Conteúdo central
                  SafeArea(
                    child: Column(
                      children: [
                        const Spacer(flex: 3),

                        // Selo luminoso
                        Transform.scale(
                          scale: 0.55 + 0.45 * Curves.elasticOut.transform(seal.value.clamp(0.0, 1.0)),
                          child: Opacity(
                            opacity: seal.value.clamp(0.0, 1.0),
                            child: _LightSeal(
                              pulse: breath,
                              glow: dawn.value,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Marca
                        Opacity(
                          opacity: title.value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, 18 * (1 - title.value)),
                            child: _BrandTitle(
                              shimmer: _shimmer.value,
                              visible: title.value,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Tagline
                        Opacity(
                          opacity: tagline.value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, 10 * (1 - tagline.value)),
                            child: Text(
                              'A jornada pela Palavra começa aqui',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.4,
                                height: 1.35,
                                color: Colors.white.withValues(alpha: 0.72),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),

                        // Versículo sussurrado
                        Opacity(
                          opacity: (verse.value * 0.95).clamp(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 36),
                            child: Column(
                              children: [
                                Text(
                                  '"Lâmpada para os meus pés é a tua palavra,\ne luz para o meu caminho."',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                    height: 1.45,
                                    color: AppColors.accent.withValues(alpha: 0.88),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Salmos 119:105',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.6,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Barra de progresso da abertura
                        Padding(
                          padding: const EdgeInsets.fromLTRB(48, 0, 48, 28),
                          child: Opacity(
                            opacity: (0.35 + 0.65 * tagline.value).clamp(0.0, 1.0),
                            child: _LaunchProgress(value: t),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 7. Letterbox (barras de cinema)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Transform.translate(
                      offset: Offset(0, -40 * (1 - letterbox.value)),
                      child: Container(
                        height: 28 + 10 * (1 - dawn.value),
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Transform.translate(
                      offset: Offset(0, 40 * (1 - letterbox.value)),
                      child: Container(
                        height: 28 + 10 * (1 - dawn.value),
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Flash suave no clímax
                  if (dawn.value > 0.55 && dawn.value < 0.85)
                    IgnorePointer(
                      child: Opacity(
                        opacity: (1 - ((dawn.value - 0.55) / 0.3).abs()) * 0.12,
                        child: const ColoredBox(color: Color(0xFFF5D78E)),
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
// Peças visuais
// ---------------------------------------------------------------------------

class _LightSeal extends StatelessWidget {
  final double pulse;
  final double glow;

  const _LightSeal({required this.pulse, required this.glow});

  @override
  Widget build(BuildContext context) {
    final radius = 54.0 + 6 * pulse;
    return SizedBox(
      width: 148,
      height: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo externo
          Container(
            width: 140 + 20 * glow,
            height: 140 + 20 * glow,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.22 + 0.2 * glow),
                  blurRadius: 48 + 24 * pulse,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.12),
                  blurRadius: 56,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          // Anel dourado
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.3),
                  AppColors.accent.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.5 + 0.2 * pulse),
                width: 1.5,
              ),
            ),
          ),
          // Núcleo
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF28332C).withValues(alpha: 0.9),
                  const Color(0xFF121816).withValues(alpha: 0.95),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Center(
              child: CinematicIcon(
                glyph: CinematicGlyph.book,
                size: 52,
                accent: AppColors.accent,
                glowing: true,
                framed: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  final double shimmer;
  final double visible;

  const _BrandTitle({required this.shimmer, required this.visible});

  @override
  Widget build(BuildContext context) {
    final shift = (shimmer * 2 - 1).clamp(-1.0, 1.0);
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(-1 + shift, -0.3),
          end: Alignment(1 + shift, 0.3),
          colors: const [
            Color(0xFFC99A2E),
            Color(0xFFF5D78E),
            Color(0xFFFFF8E7),
            Color(0xFFF5D78E),
            Color(0xFFE8B84B),
          ],
          stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
        ).createShader(bounds);
      },
      child: Text(
        'TRILHA',
        textAlign: TextAlign.center,
        style: GoogleFonts.cormorantGaramond(
          fontSize: 64,
          fontWeight: FontWeight.w700,
          letterSpacing: 10,
          height: 1,
          color: Colors.white,
          shadows: [
            Shadow(
              color: AppColors.accent.withValues(alpha: 0.35 * visible),
              blurRadius: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _LaunchProgress extends StatelessWidget {
  final double value;

  const _LaunchProgress({required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 2.5,
            child: Stack(
              children: [
                Container(color: Colors.white.withValues(alpha: 0.08)),
                FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppGradients.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'PREPARANDO SEU ESTUDO',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.4,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------

class _CinematicSkyPainter extends CustomPainter {
  final double progress;
  final double shimmer;
  final double breath;
  final double dawn;

  _CinematicSkyPainter({
    required this.progress,
    required this.shimmer,
    required this.breath,
    required this.dawn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Céu de amanhecer — charcoal → olive/dourado
    final top = Color.lerp(
      const Color(0xFF0A0E0C),
      const Color(0xFF1E3D32),
      dawn * 0.7,
    )!;
    final mid = Color.lerp(
      const Color(0xFF121816),
      const Color(0xFF3D5A48),
      dawn * 0.55,
    )!;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, mid, const Color(0xFF0A0E0C)],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Luz ambiente quente
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryLight.withValues(alpha: 0.16 * progress * (0.7 + 0.3 * breath)),
          AppColors.accent.withValues(alpha: 0.06 * progress),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.72, size.height * 0.22),
          radius: size.width * 0.55,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.22),
      size.width * 0.55,
      glow,
    );

    // Estrelas determinísticas
    final rng = math.Random(42);
    final count = 90;
    for (var i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.72;
      final base = 0.35 + rng.nextDouble() * 0.65;
      final twinkle =
          0.55 + 0.45 * math.sin((shimmer * math.pi * 2) + i * 0.7);
      final appear = ((progress * 1.4) - (i / count) * 0.4).clamp(0.0, 1.0);
      final r = (0.5 + rng.nextDouble() * 1.4) * (i % 11 == 0 ? 1.8 : 1);
      final paint = Paint()
        ..color = Colors.white.withValues(
          alpha: (base * twinkle * appear * (1 - dawn * 0.25)).clamp(0.0, 1.0),
        );
      canvas.drawCircle(Offset(x, y), r, paint);

      // Algumas estrelas com cruz de brilho
      if (i % 17 == 0 && appear > 0.6) {
        final cross = Paint()
          ..color = Colors.white.withValues(alpha: 0.25 * appear * twinkle)
          ..strokeWidth = 0.8;
        canvas.drawLine(Offset(x - 5, y), Offset(x + 5, y), cross);
        canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), cross);
      }
    }

    // Poeira dourada flutuante
    final dustRng = math.Random(7);
    for (var i = 0; i < 28; i++) {
      final x = dustRng.nextDouble() * size.width;
      final baseY = dustRng.nextDouble() * size.height;
      final drift = math.sin(shimmer * math.pi * 2 + i) * 12;
      final y = (baseY + drift) % size.height;
      final a = dawn * (0.15 + dustRng.nextDouble() * 0.35);
      canvas.drawCircle(
        Offset(x, y),
        1.2 + dustRng.nextDouble(),
        Paint()..color = AppColors.accent.withValues(alpha: a),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CinematicSkyPainter old) =>
      old.progress != progress ||
      old.shimmer != shimmer ||
      old.breath != breath ||
      old.dawn != dawn;
}

class _DawnRaysPainter extends CustomPainter {
  final double progress;
  final double breath;

  _DawnRaysPainter({required this.progress, required this.breath});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;

    final origin = Offset(size.width * 0.5, size.height * 0.58);
    final rayCount = 9;
    for (var i = 0; i < rayCount; i++) {
      final angle = -math.pi * 0.92 + (math.pi * 0.84) * (i / (rayCount - 1));
      final len = size.height * (0.55 + 0.12 * math.sin(i + breath));
      final tip = Offset(
        origin.dx + math.cos(angle) * len,
        origin.dy + math.sin(angle) * len,
      );
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.accent.withValues(alpha: 0.0),
            AppColors.accent.withValues(alpha: 0.18 * progress),
            const Color(0xFFFFF3D6).withValues(alpha: 0.08 * progress),
            Colors.transparent,
          ],
        ).createShader(Rect.fromPoints(origin, tip))
        ..strokeWidth = 18 + (i.isEven ? 10 : 0)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawLine(origin, tip, paint);
    }

    // Núcleo da luz
    canvas.drawCircle(
      origin,
      size.width * (0.18 + 0.06 * breath) * progress,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF3D6).withValues(alpha: 0.55 * progress),
            AppColors.accent.withValues(alpha: 0.28 * progress),
            AppColors.accent.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: origin,
            radius: size.width * 0.28,
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _DawnRaysPainter old) =>
      old.progress != progress || old.breath != breath;
}

class _HorizonPathPainter extends CustomPainter {
  final double progress;
  final double breath;

  _HorizonPathPainter({required this.progress, required this.breath});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;

    final horizonY = size.height * 0.62;

    // Brilho do horizonte
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY - 40, size.width, 120),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.accent.withValues(alpha: 0.22 * progress),
            AppColors.accent.withValues(alpha: 0.05 * progress),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, horizonY - 40, size.width, 120)),
    );

    // Trilha / caminho de luz subindo ao encontro do usuário
    final path = Path();
    final start = Offset(size.width * 0.5, size.height * 0.98);
    final end = Offset(size.width * 0.5, horizonY + 8);
    path.moveTo(start.dx, start.dy);

    final steps = 24;
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final y = start.dy + (end.dy - start.dy) * t;
      final sway = math.sin(t * math.pi * 2 + breath) * 10 * (1 - t);
      final widthFactor = 0.18 * (1 - t) + 0.01;
      // só guia central
      path.lineTo(size.width * 0.5 + sway, y);
      // ignore unused for path width — drawn separately
      if (widthFactor < 0) break;
    }

    final reveal = progress.clamp(0.0, 1.0);
    final metrics = path.computeMetrics().first;
    final drawn = metrics.extractPath(0, metrics.length * reveal);

    canvas.drawPath(
      drawn,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.55 * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      drawn,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.accent.withValues(alpha: 0.9 * progress),
            const Color(0xFFFFF3D6).withValues(alpha: 0.5 * progress),
            Colors.white.withValues(alpha: 0.15 * progress),
          ],
        ).createShader(Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    // Passos/pontos ao longo do caminho
    for (var i = 1; i <= 5; i++) {
      final t = (i / 6) * reveal;
      if (t <= 0) continue;
      final tan = metrics.getTangentForOffset(metrics.length * t);
      if (tan == null) continue;
      canvas.drawCircle(
        tan.position,
        2.5,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55 * progress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HorizonPathPainter old) =>
      old.progress != progress || old.breath != breath;
}
