import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/content_catalog_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

/// Abertura Steway — impacto de jogo + promessa de aprendizado.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _firstDuration = Duration(milliseconds: 2800);
  static const _returnDuration = Duration(milliseconds: 1500);

  late final AnimationController _master;
  late final AnimationController _pulse;

  bool _readyToExit = false;
  bool _exiting = false;
  bool _isReturnVisit = false;
  bool _hitClimax = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _master = AnimationController(vsync: this, duration: _firstDuration);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
    final climax = _isReturnVisit ? 0.35 : 0.4;
    if (!_hitClimax && _master.value >= climax) {
      _hitClimax = true;
      HapticFeedback.mediumImpact();
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
      unawaited(AnalyticsService.instance.setUserId(backend.uid));
      unawaited(AnalyticsService.instance.logAppOpen());

      next = progress.hasSeenOnboarding
          ? const MainShell()
          : const OnboardingScreen();
    }

    if (!mounted) return;
    setState(() => _readyToExit = true);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, a, __, c) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
          child: c,
        ),
        transitionDuration: const Duration(milliseconds: 520),
      ),
    );
  }

  @override
  void dispose() {
    _master.removeListener(_onMasterTick);
    _master.dispose();
    _pulse.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Interval _i(double start, double end, {Curve curve = Curves.easeOutCubic}) {
    if (_isReturnVisit) {
      double map(double t) => (t * 0.72 + 0.08).clamp(0.0, 1.0);
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
        systemNavigationBarColor: AppColors.night,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.night,
        body: AnimatedBuilder(
          animation: Listenable.merge([_master, _pulse]),
          builder: (context, _) {
            final t = _master.value;
            final pulse = _pulse.value;
            final exitFade = _readyToExit ? 0.0 : 1.0;

            final rise = CurvedAnimation(
              parent: _master,
              curve: _i(0.0, 0.55, curve: Curves.easeOutBack),
            );
            final title = CurvedAnimation(
              parent: _master,
              curve: _i(0.28, 0.62),
            );
            final tag = CurvedAnimation(
              parent: _master,
              curve: _i(0.42, 0.75),
            );
            final bar = CurvedAnimation(
              parent: _master,
              curve: _i(0.55, 1.0, curve: Curves.easeOut),
            );

            final riseV = rise.value.clamp(0.0, 1.0);
            final titleV = title.value.clamp(0.0, 1.0);
            final tagV = tag.value.clamp(0.0, 1.0);
            final barV = bar.value.clamp(0.0, 1.0);

            return Opacity(
              opacity: exitFade,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Arena — azul vivo + energia dourada
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF0B1628),
                          AppColors.night,
                          Color.lerp(
                            AppColors.primaryDark,
                            const Color(0xFF1A3A68),
                            0.55,
                          )!,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.12,
                    left: size.width * 0.15,
                    child: _Orb(
                      size: 220,
                      color: AppColors.primary.withValues(
                        alpha: 0.22 + 0.08 * pulse,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: size.height * 0.18,
                    right: -40,
                    child: _Orb(
                      size: 280,
                      color: AppColors.accent.withValues(
                        alpha: 0.14 + 0.1 * pulse,
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.45,
                    left: -60,
                    child: _Orb(
                      size: 160,
                      color: AppColors.teal.withValues(alpha: 0.1),
                    ),
                  ),

                  // Partículas leves
                  ...List.generate(8, (i) {
                    final seed = (i + 1) * 0.11;
                    final y = (0.12 + seed * 0.7 + pulse * 0.02) % 0.9;
                    final x = (0.08 + (i * 0.12) % 0.84);
                    return Positioned(
                      left: size.width * x,
                      top: size.height * y,
                      child: Opacity(
                        opacity: (0.15 + 0.25 * titleV) *
                            (0.5 + 0.5 * math.sin(pulse * math.pi + i)),
                        child: Container(
                          width: 3 + (i % 3).toDouble(),
                          height: 3 + (i % 3).toDouble(),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i.isEven
                                ? AppColors.accent
                                : AppColors.primaryLight,
                          ),
                        ),
                      ),
                    );
                  }),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const Spacer(flex: 3),

                          // Marca — medalhão de jogo
                          Opacity(
                            opacity: riseV,
                            child: Transform.scale(
                              scale: 0.7 + 0.3 * riseV,
                              child: Transform.translate(
                                offset: Offset(0, 36 * (1 - riseV)),
                                child: _BrandMark(pulse: pulse),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          Opacity(
                            opacity: titleV,
                            child: Transform.translate(
                              offset: Offset(0, 18 * (1 - titleV)),
                              child: Text(
                                'STEWAY',
                                textAlign: TextAlign.center,
                                style: AppTypography.display(
                                  size: 52,
                                  weight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 0.95,
                                ).copyWith(
                                  letterSpacing: 10,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.accent.withValues(
                                        alpha: 0.45 * titleV,
                                      ),
                                      blurRadius: 28,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Opacity(
                            opacity: tagV,
                            child: Transform.translate(
                              offset: Offset(0, 12 * (1 - tagV)),
                              child: Column(
                                children: [
                                  Text(
                                    'A Bíblia em missões',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.title(
                                      size: 18,
                                      weight: FontWeight.w700,
                                      color: Colors.white.withValues(alpha: 0.92),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Aprenda · pratique · cresça na fé',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.body(
                                      size: 14,
                                      weight: FontWeight.w600,
                                      color: AppColors.accent.withValues(
                                        alpha: 0.85,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(flex: 4),

                          Opacity(
                            opacity: barV,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: SizedBox(
                                    height: 5,
                                    width: size.width * 0.42,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ColoredBox(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: t.clamp(0.08, 1.0),
                                          child: const DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient: AppGradients.gold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Preparando sua jornada…',
                                  style: AppTypography.label(
                                    size: 10,
                                    letterSpacing: 1.4,
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 36),
                        ],
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

class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final double pulse;

  const _BrandMark({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(
                    alpha: 0.28 + 0.2 * pulse,
                  ),
                  blurRadius: 36 + 16 * pulse,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(AppColors.nightElevated, AppColors.primary, 0.35)!,
                  AppColors.nightMid,
                ],
              ),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.55 + 0.25 * pulse),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.35,
                  child: CinematicIcon(
                    glyph: CinematicGlyph.path,
                    size: 54,
                    accent: AppColors.primaryLight,
                    framed: false,
                  ),
                ),
                const CinematicIcon(
                  glyph: CinematicGlyph.book,
                  size: 40,
                  accent: AppColors.accent,
                  framed: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
