import 'dart:io';

import 'package:home_widget/home_widget.dart';

import 'progress_service.dart';

/// Sincroniza streak e meta diária com o widget da tela inicial (Android/iOS).
class HomeWidgetService {
  HomeWidgetService._();

  static const _androidProvider = 'TrilhaHomeWidgetProvider';
  static const _iosKind = 'TrilhaHomeWidget';
  static const _appGroupId = 'group.com.trilha.trilhaApp';

  static Future<void> init() async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    if (Platform.isIOS) {
      await HomeWidget.setAppGroupId(_appGroupId);
    }
  }

  static Future<void> syncFromProgress(ProgressService progress) async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    if (!progress.isLoaded) return;

    final goal = progress.settings.dailyGoal.clamp(1, 99);
    final done = progress.walkedToday ? progress.missionsToday : 0;
    final streak = progress.streak;
    final goalMet = progress.dailyGoalMet;
    final atRisk = progress.isStreakAtRisk;

    final statusLine = _statusLine(
      goalMet: goalMet,
      atRisk: atRisk,
      streak: streak,
      goal: goal,
      done: done,
    );
    final streakLabel = streak == 1 ? '1 dia' : '$streak dias';
    final progressLabel = goalMet
        ? 'Meta concluída'
        : '$done/$goal missõ${goal == 1 ? 'ão' : 'es'}';

    await HomeWidget.saveWidgetData('streak', streak);
    await HomeWidget.saveWidgetData('missions_done', done);
    await HomeWidget.saveWidgetData('daily_goal', goal);
    await HomeWidget.saveWidgetData('goal_met', goalMet);
    await HomeWidget.saveWidgetData('streak_at_risk', atRisk);
    await HomeWidget.saveWidgetData('status_line', statusLine);
    await HomeWidget.saveWidgetData('streak_label', streakLabel);
    await HomeWidget.saveWidgetData('progress_label', progressLabel);

    await HomeWidget.updateWidget(
      androidName: _androidProvider,
      iOSName: _iosKind,
      qualifiedAndroidName: 'com.trilha.trilha_app.$_androidProvider',
    );
  }

  /// Android 8+: pede para fixar o widget na tela inicial (quando o launcher suporta).
  static Future<void> requestPinIfSupported() async {
    if (!Platform.isAndroid) return;
    final supported = await HomeWidget.isRequestPinWidgetSupported();
    if (supported != true) return;
    await HomeWidget.requestPinWidget(
      androidName: _androidProvider,
      qualifiedAndroidName: 'com.trilha.trilha_app.$_androidProvider',
    );
  }

  static String _statusLine({
    required bool goalMet,
    required bool atRisk,
    required int streak,
    required int goal,
    required int done,
  }) {
    if (goalMet) return 'Meta de hoje concluída';
    if (atRisk && streak > 0) return 'Sequência em risco — caminhe hoje';
    final left = (goal - done).clamp(1, goal);
    return left == 1 ? 'Falta 1 missão' : 'Faltam $left missões';
  }
}
