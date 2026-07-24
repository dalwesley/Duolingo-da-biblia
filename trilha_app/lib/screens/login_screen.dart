import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../widgets/immersive_background.dart';
import '../widgets/stway_brand.dart';
import '../widgets/ui_primitives.dart';
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

    await backend.settleAndSyncLeague(progress, league);
    await progress.clearLegacyLocalPrefs();
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
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);
    final a = appearance;

    return ImmersiveScaffold(
      mode: mode,
      style: appearance,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.screen,
            AppSpace.xxl,
            AppSpace.screen,
            AppSpace.screen,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const Center(child: StwayLogo(size: 88)),
              const SizedBox(height: AppSpace.xxl),
              const Center(
                child: StwayWordmark(fontSize: 28, letterSpacing: 4),
              ),
              const SizedBox(height: AppSpace.sm),
              const StwayTagline(size: 9),
              const SizedBox(height: AppSpace.xxl),
              Text(
                'Entre para continuar',
                textAlign: TextAlign.center,
                style: AppTypography.display(size: 32),
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                'Sua conta Google é a fonte da verdade: passos, dias e missões ficam no Firebase.',
                textAlign: TextAlign.center,
                style: AppTypography.body(color: a.textMuted(0.65)),
              ),
              const Spacer(flex: 3),
              if (_error != null) ...[
                GlassCard(
                  color: AppColors.error.withValues(alpha: 0.15),
                  padding: const EdgeInsets.all(AppSpace.md),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w600,
                      color: AppColors.errorSoft,
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
                    side: BorderSide(color: a.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
              ],
              Opacity(
                opacity: busy ? 0.55 : 1,
                child: CopperCta(
                  label: busy ? 'Entrando…' : 'Continuar com Google',
                  onTap: busy ? null : _signIn,
                  trailing: null,
                  showArrow: false,
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                'É necessário entrar para usar o Stway.',
                textAlign: TextAlign.center,
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 0,
                  color: a.textMuted(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
