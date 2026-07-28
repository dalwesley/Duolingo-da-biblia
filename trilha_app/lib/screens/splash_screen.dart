import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/content_catalog_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../widgets/immersive_background.dart';
import '../widgets/stway_brand.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

/// Abertura STWAY — impacto de jogo + promessa de aprendizado.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _firstDuration = Duration(milliseconds: 4000);
  static const _returnDuration = Duration(milliseconds: 4000);

  late final AnimationController _master;
  late final AnimationController _pulse;

  bool _exiting = false;
  bool _isReturnVisit = false;
  bool _hitClimax = false;
  String? _versionLabel;

  @override
  void initState() {
    super.initState();

    _master = AnimationController(vsync: this, duration: _firstDuration);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _loadVersionLabel();
    _boot();
  }

  Future<void> _loadVersionLabel() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _versionLabel = 'v${info.version}');
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
      next = progress.hasSeenOnboarding
          ? const MainShell()
          : const OnboardingScreen();

      // Só sincroniza liga/progresso se já passou do onboarding.
      // Senão o save assíncrono pode gravar hasSeenOnboarding:false
      // depois do finish() e reabrir a intro no próximo boot.
      if (progress.hasSeenOnboarding) {
        unawaited(() async {
          await backend.settleAndSyncLeague(progress, league);
          await progress.clearLegacyLocalPrefs();
        }());
      }
      unawaited(ContentCatalogService.instance.ensureLoaded());
      unawaited(AnalyticsService.instance.setUserId(backend.uid));
      unawaited(AnalyticsService.instance.logAppOpen());
    }

    if (!mounted) return;
    // Mantém a splash visível por baixo do fade — evita flash do
    // windowBackground nativo (verde/teal) entre splash e onboarding.
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, a, __, c) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
          child: c,
        ),
        transitionDuration: const Duration(milliseconds: 420),
      ),
    );
  }

  @override
  void dispose() {
    _master.removeListener(_onMasterTick);
    _master.dispose();
    _pulse.dispose();
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
    // Usa a aparência salva no aparelho (mesma do restante do app).
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

    return ImmersiveScaffold(
      mode: mode,
      style: appearance,
      background: const ColoredBox(
        color: AppColors.primaryDark,
        child: SizedBox.expand(
          child: Image(
            image: AssetImage('assets/icon/splash_bg.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_master, _pulse]),
        builder: (context, _) {
          final t = _master.value;
          final pulse = _pulse.value;

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

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.xxxl,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Opacity(
                    opacity: riseV,
                    child: Transform.scale(
                      scale: 0.7 + 0.3 * riseV,
                      child: Transform.translate(
                        offset: Offset(0, 36 * (1 - riseV)),
                        child: StwayLogo(size: 112, pulse: pulse),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Opacity(
                    opacity: titleV,
                    child: Transform.translate(
                      offset: Offset(0, 18 * (1 - titleV)),
                      child: const StwayWordmark(
                        fontSize: 48,
                        letterSpacing: 6,
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
                          const StwayTagline(size: 11),
                          const SizedBox(height: 10),
                          Text(
                            'A Bíblia em missões',
                            textAlign: TextAlign.center,
                            style: AppTypography.title(
                              size: 16,
                              weight: FontWeight.w700,
                              color: AppColors.textOnDark.withValues(alpha: 0.92),
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
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          child: SizedBox(
                            height: 5,
                            width: size.width * 0.42,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ColoredBox(
                                  color: AppColors.textOnDark.withValues(alpha: 0.1),
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
                            color: AppColors.textOnDark.withValues(alpha: 0.35),
                          ),
                        ),
                        if (_versionLabel != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _versionLabel!,
                            style: AppTypography.label(
                              size: 10,
                              letterSpacing: 0.8,
                              color: AppColors.textOnDark.withValues(alpha: 0.28),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
