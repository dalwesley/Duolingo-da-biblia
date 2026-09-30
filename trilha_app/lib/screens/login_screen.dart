import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/companion_service.dart';
import '../services/content_catalog_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../widgets/immersive_background.dart';
import '../widgets/stway_brand.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/ui_primitives.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';
import '../l10n/app_language.dart';

/// Porta de entrada — exige conta (Google; Apple no iOS) antes de usar o app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _error;
  String? _versionLabel;

  /// True do tap até a navegação (ou erro) — inclusive durante o hydrate.
  bool _entering = false;

  bool get _showApple => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    _loadVersionLabel();
    unawaited(ContentCatalogService.instance.ensureLoaded());
  }

  Future<void> _loadVersionLabel() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _versionLabel = 'v${info.version}');
  }

  Future<void> _continueAfterLogin(
    ProgressService progress,
    BackendService backend,
    AuthSignInResult result,
  ) async {
    final league = context.read<LeagueService>();
    final hydrate = await backend
        .hydrateProgress(progress, league: league)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => BackendService.hydrateFailed,
        );

    // hydrate já tenta o displayName da sessão; reforça com o do login.
    await progress.ensureUserNameFromAuth(
      result.displayName ?? backend.userDisplayName,
    );

    if (hydrate == BackendService.hydrateFailed) {
      if (!mounted) return;
      setState(() {
        _entering = false;
        _error = context.l10n.loginHydrateError;
      });
      // Mantém sessão mas não entra no app até hydrate ok.
      return;
    }

    unawaited(backend.settleAndSyncLeague(progress, league));
    unawaited(progress.clearLegacyLocalPrefs());

    if (!mounted) return;
    final companions = context.read<CompanionService>();
    final rooms = context.read<RoomService>();
    unawaited(companions.applyCloudCodes(progress.companionCodes, progress));
    unawaited(
      rooms.applyCloudCode(progress.activeRoomCode, progress: progress),
    );
    unawaited(ContentCatalogService.instance.ensureLoaded());

    if (!mounted) return;

    final next = progress.hasSeenOnboarding
        ? const MainShell()
        : const OnboardingScreen();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => next,
        transitionsBuilder: (_, a, _, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: AppMotion.slow,
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    if (_entering) return;
    final progress = context.read<ProgressService>();
    final backend = context.read<BackendService>();
    setState(() {
      _error = null;
      _entering = true;
    });

    debugPrint('[STWAY:Auth] LoginScreen: tap Continuar com Google');
    final result = await backend.signInWithGoogle();
    if (!mounted) return;
    if (!result.ok) {
      debugPrint('[STWAY:Auth] LoginScreen: fail → ${result.error}');
      unawaited(AnalyticsService.instance.logLoginFailed(reason: result.error));
      setState(() {
        _entering = false;
        _error = result.error ?? context.l10n.loginGoogleError;
      });
      return;
    }
    debugPrint('[STWAY:Auth] LoginScreen: ok → ${result.email}');
    unawaited(AnalyticsService.instance.logLogin(method: 'google'));
    unawaited(AnalyticsService.instance.setUserId(backend.uid));
    await _continueAfterLogin(progress, backend, result);
  }

  Future<void> _signInWithApple() async {
    if (_entering) return;
    final progress = context.read<ProgressService>();
    final backend = context.read<BackendService>();
    setState(() {
      _error = null;
      _entering = true;
    });

    debugPrint('[STWAY:Auth] LoginScreen: tap Continuar com Apple');
    final result = await backend.signInWithApple();
    if (!mounted) return;
    if (!result.ok) {
      debugPrint('[STWAY:Auth] LoginScreen: Apple fail → ${result.error}');
      unawaited(AnalyticsService.instance.logLoginFailed(reason: result.error));
      setState(() {
        _entering = false;
        _error = result.error ?? context.l10n.loginAppleError;
      });
      return;
    }
    debugPrint('[STWAY:Auth] LoginScreen: Apple ok → ${result.email}');
    unawaited(AnalyticsService.instance.logLogin(method: 'apple'));
    unawaited(AnalyticsService.instance.setUserId(backend.uid));
    await _continueAfterLogin(progress, backend, result);
  }

  @override
  Widget build(BuildContext context) {
    final backend = context.watch<BackendService>();
    final busy = _entering || backend.isAuthBusy || backend.isInitializing;
    final preparing = _entering && backend.isSignedIn;
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
                child: StwayWordmark(fontSize: 48, letterSpacing: 6),
              ),
              const SizedBox(height: 14),
              const StwayTagline(size: 11),
              const SizedBox(height: AppSpace.xxl),
              Text(
                preparing
                    ? context.l10n.splashPreparing
                    : context.l10n.loginTitle,
                textAlign: TextAlign.center,
                style: AppTypography.display(size: 28),
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                preparing
                    ? context.l10n.loginLoadingBody
                    : context.l10n.loginBody,
                textAlign: TextAlign.center,
                style: AppTypography.body(color: a.textSecondary),
              ),
              const Spacer(flex: 3),
              if (_error != null) ...[
                GlassCard(
                  tint: AppRoles.error,
                  padding: const EdgeInsets.all(AppSpace.md),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w600,
                      color: a.text,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.md),
              ],
              AbsorbPointer(
                absorbing: busy,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!backend.isFirebaseReady &&
                        !backend.isInitializing) ...[
                      GhostCta(
                        label: context.l10n.loginReconnect,
                        leading: CinematicGlyph.refresh,
                        expanded: true,
                        onTap: busy ? null : () => backend.retry(),
                      ),
                      const SizedBox(height: AppSpace.sm),
                    ],
                    if (_showApple) ...[
                      Opacity(
                        opacity: busy ? 0.55 : 1,
                        // GhostCta só aceita CinematicGlyph no leading; o logo
                        // da Apple (obrigatório no botão) fica sobreposto à esquerda.
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            GhostCta(
                              label: busy
                                  ? context.l10n.loginEntering
                                  : context.l10n.loginWithApple,
                              expanded: true,
                              onTap: busy ? null : _signInWithApple,
                            ),
                            Positioned(
                              left: AppSpace.lg,
                              child: IgnorePointer(
                                child: busy
                                    ? AppSpinner(inline: true, color: a.text)
                                    : Icon(
                                        Icons.apple,
                                        size: 22,
                                        color: a.text,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpace.sm),
                    ],
                    CopperCta(
                      label: busy
                          ? context.l10n.loginEntering
                          : context.l10n.loginWithGoogle,
                      onTap: busy ? null : _signInWithGoogle,
                      busy: busy,
                      trailing: null,
                      showArrow: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                context.l10n.loginRequired,
                textAlign: TextAlign.center,
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 0,
                  color: a.textFaint,
                ),
              ),
              if (_versionLabel != null) ...[
                const SizedBox(height: AppSpace.md),
                Text(
                  _versionLabel!,
                  textAlign: TextAlign.center,
                  style: AppTypography.label(
                    size: 10,
                    letterSpacing: 0.8,
                    color: a.textFaint,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
