import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..forward();
    _boot();
  }

  Future<void> _boot() async {
    final progress = context.read<ProgressService>();
    if (!progress.isLoaded) await progress.load();

    await Future.delayed(Duration(milliseconds: progress.hasSeenSplash ? 800 : 2800));
    if (!mounted) return;

    if (!progress.hasSeenSplash) await progress.setHasSeenSplash(true);
    if (!mounted) return;

    final next = progress.hasSeenOnboarding ? const MainShell() : const OnboardingScreen();
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => next,
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 600),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.cosmic),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppColors.primary.withValues(alpha: 0.4), Colors.transparent]),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1).animate(
                      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5, curve: Curves.elasticOut)),
                    ),
                    child: const CinematicIcon(
                      glyph: CinematicGlyph.book,
                      size: 120,
                      accent: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7)),
                    child: const Text('Trilha', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                  ),
                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8)),
                    child: Text(
                      'Sua jornada pela Palavra começa aqui.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => LinearProgressIndicator(
                          value: _controller.value,
                          minHeight: 4,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
