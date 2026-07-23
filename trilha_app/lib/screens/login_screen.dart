import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

/// Porta de entrada — exige conta Google antes de usar o app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _error;

  Future<void> _continueAfterLogin(
    ProgressService progress,
    BackendService backend,
    GoogleSignInResult result,
  ) async {
    // Firebase é a fonte da verdade.
    final league = context.read<LeagueService>();
    await backend.hydrateProgress(progress, league: league);

    final name = result.displayName?.trim();
    if (name != null &&
        name.isNotEmpty &&
        (progress.userName == 'Aprendiz' ||
            progress.userName == 'Peregrino' ||
            progress.userName == 'Estudante')) {
      await progress.setUserName(name);
    }

    final saved = await backend.saveNow(
      progress,
      LeagueService.weekKey(),
      league: league,
    );
    if (saved) await progress.clearLegacyLocalPrefs();
    if (!mounted) return;

    final next = progress.hasSeenOnboarding
        ? const MainShell()
        : const OnboardingScreen();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 480),
      ),
    );
  }

  Future<void> _signIn() async {
    final progress = context.read<ProgressService>();
    final backend = context.read<BackendService>();
    setState(() => _error = null);
    HapticFeedback.lightImpact();

    final result = await backend.signInWithGoogle();
    if (!mounted) return;
    if (!result.ok) {
      unawaited(AnalyticsService.instance.logLoginFailed(reason: result.error));
      setState(() => _error = result.error ?? 'Falha no login com Google');
      return;
    }
    unawaited(AnalyticsService.instance.logLogin(method: 'google'));
    unawaited(AnalyticsService.instance.setUserId(backend.uid));
    await _continueAfterLogin(progress, backend, result);
  }

  @override
  Widget build(BuildContext context) {
    final backend = context.watch<BackendService>();
    final busy = backend.isGoogleBusy || backend.isInitializing;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.cosmic),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.xxl,
              AppSpace.xxl,
              AppSpace.xxl,
              AppSpace.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                const Center(
                  child: CinematicIcon(
                    glyph: CinematicGlyph.path,
                    size: 72,
                    accent: AppColors.accent,
                    glowing: true,
                  ),
                ),
                const SizedBox(height: AppSpace.xxl),
                Text(
                  'STEWAY',
                  textAlign: TextAlign.center,
                  style: AppTypography.label(
                    size: 13,
                    letterSpacing: 3.2,
                    color: AppColors.accent.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                Text(
                  'Entre para continuar',
                  textAlign: TextAlign.center,
                  style: AppTypography.display(size: 36),
                ),
                const SizedBox(height: AppSpace.md),
                Text(
                  'Sua conta Google é a fonte da verdade: passos, dias e missões ficam no Firebase.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const Spacer(flex: 3),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpace.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w600,
                        color: const Color(0xFFFFC9C9),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                ],
                if (!backend.isFirebaseReady && !backend.isInitializing) ...[
                  OutlinedButton.icon(
                    onPressed: busy ? null : () => backend.retry(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      'Tentar reconectar',
                      style: AppTypography.cta(color: Colors.white70),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpace.md,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.sm),
                ],
                FilledButton(
                  onPressed: busy ? null : _signIn,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.inkOnAccent,
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                  ),
                  child: busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.inkOnAccent,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.g_mobiledata_rounded, size: 28),
                            const SizedBox(width: AppSpace.xs),
                            Text(
                              'Continuar com Google',
                              style: AppTypography.cta(
                                size: 15,
                                color: AppColors.inkOnAccent,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: AppSpace.lg),
                Text(
                  'É necessário entrar para usar o Steway.',
                  textAlign: TextAlign.center,
                  style: AppTypography.label(
                    size: 11,
                    letterSpacing: 0,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
