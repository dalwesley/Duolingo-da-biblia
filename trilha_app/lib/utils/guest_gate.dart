import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/login_screen.dart';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

/// Visitante: instalação nova faz a 1ª cena sem conta. Depois dela, cena
/// nova, assinatura e o que vive na nuvem pedem a conta ("Salve sua
/// caminhada"), sempre com "Agora não" de volta para onde estava.
class GuestGate {
  GuestGate._();

  /// Sem BackendService na árvore (testes, prévias) conta como com conta.
  static bool isGuest(BuildContext context) {
    final backend = Provider.of<BackendService?>(context, listen: false);
    return backend != null && !backend.isSignedIn;
  }

  /// Já andou como visitante (a 1ª cena está feita).
  static bool walked(ProgressService progress) =>
      progress.completedMissions.isNotEmpty ||
      (progress.firstLessonDate ?? '').isNotEmpty;

  /// Visitante que já fez a 1ª cena: cena nova só com conta. Refazer uma
  /// cena feita e a prática (revisão, reforço) seguem livres.
  static bool blocksScene(
    BuildContext context, {
    required String missionSlug,
    bool practice = false,
  }) {
    if (practice || !isGuest(context)) return false;
    final progress = context.read<ProgressService>();
    return walked(progress) && !progress.isMissionCompleted(missionSlug);
  }

  static const _promptDayKey = 'guestSavePromptDay';

  /// Abertura sozinha da tela de salvar: uma vez por dia. True = pode abrir
  /// (e já marca o dia).
  static Future<bool> takeDailyPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (prefs.getString(_promptDayKey) == today) return false;
    await prefs.setString(_promptDayKey, today);
    return true;
  }

  /// Rota da tela de salvar. [reason] vai para os eventos do funil.
  static Route<void> saveRoute(BuildContext context, {required String reason}) {
    unawaited(
      AnalyticsService.instance.logEvent('guest_gate', {'reason': reason}),
    );
    final walkedNow = walked(context.read<ProgressService>());
    return PageRouteBuilder<void>(
      pageBuilder: (_, _, _) =>
          LoginScreen(afterGuestScene: walkedNow, guestReason: reason),
      transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: AppMotion.gentle,
    );
  }

  /// Com conta segue (true). Visitante: abre a tela de salvar por cima e
  /// devolve false — o login, se acontecer, já leva o app ao shell.
  static Future<bool> requireAccount(
    BuildContext context, {
    required String reason,
  }) async {
    if (!isGuest(context)) return true;
    await Navigator.of(
      context,
      rootNavigator: true,
    ).push(saveRoute(context, reason: reason));
    return false;
  }
}
