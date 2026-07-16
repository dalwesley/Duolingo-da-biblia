import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
    await backend.hydrateProgress(progress);

    final name = result.displayName?.trim();
    if (name != null &&
        name.isNotEmpty &&
        (progress.userName == 'Peregrino' || progress.userName == 'Estudante')) {
      await progress.setUserName(name);
    }

    await backend.saveNow(progress, LeagueService.weekKey());
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
      setState(() => _error = result.error ?? 'Falha no login com Google');
      return;
    }
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
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
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
                const SizedBox(height: 28),
                Text(
                  'TRILHA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.2,
                    color: AppColors.accent.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Entre para continuar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sua conta Google guarda o progresso, a caravana e as salas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const Spacer(flex: 3),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFC9C9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (!backend.isFirebaseReady && !backend.isInitializing) ...[
                  OutlinedButton.icon(
                    onPressed: busy ? null : () => backend.retry(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Tentar reconectar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                FilledButton(
                  onPressed: busy ? null : _signIn,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A211C),
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Color(0xFF1A211C),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata_rounded, size: 28),
                            SizedBox(width: 4),
                            Text(
                              'Continuar com Google',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  'É necessário entrar para usar o Trilha.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
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
