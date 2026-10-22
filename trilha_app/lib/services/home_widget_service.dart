import 'dart:async';
import 'dart:io';

import 'package:home_widget/home_widget.dart';

import '../l10n/l10n_global.dart';
import 'progress_service.dart';

/// Sincroniza streak e meta diária com o widget da tela inicial (Android/iOS).
class HomeWidgetService {
  HomeWidgetService._();

  static const _androidProvider = 'TrilhaHomeWidgetProvider';
  static const _iosKind = 'TrilhaHomeWidget';
  static const iosAppGroupId = 'group.ZS7LYV9Y7U.stway';
  static const _debounce = Duration(seconds: 2);

  static Timer? _timer;
  static ProgressService? _pending;
  static bool _iosGroupReady = false;

  static bool get _enabled => Platform.isAndroid || Platform.isIOS;

  static Future<void> init() async {
    if (!_enabled) return;
    if (Platform.isIOS) {
      try {
        await HomeWidget.setAppGroupId(iosAppGroupId);
        _iosGroupReady = true;
      } catch (_) {
        _iosGroupReady = false;
      }
    }
  }

  /// Agenda sync (debounce 2s). Use [immediate] no lifecycle pause/resume.
  static void syncFromProgress(
    ProgressService progress, {
    bool immediate = false,
  }) {
    if (!_enabled) return;
    if (Platform.isIOS && !_iosGroupReady) return;
    _pending = progress;
    if (immediate) {
      _timer?.cancel();
      _timer = null;
      unawaited(_flush());
      return;
    }
    _timer?.cancel();
    _timer = Timer(_debounce, () {
      unawaited(_flush());
    });
  }

  static Future<void> _flush() async {
    final progress = _pending;
    _pending = null;
    _timer = null;
    if (progress == null || !progress.isLoaded) return;
    if (Platform.isIOS && !_iosGroupReady) return;

    final l = L10n.current;
    final goal = progress.settings.dailyGoal.clamp(1, 99);
    final walked = progress.walkedToday;
    final done = walked ? progress.missionsToday : 0;
    final streak = progress.streak;
    final goalMet = progress.dailyGoalMet;
    final atRisk =
        progress.isStreakAtRisk ||
        (streak > 0 && !walked && progress.yesterdayWasFrozen);

    final nextTitle = (progress.nextSceneTitle ?? '').trim();
    final todayLabel = nextTitle.isNotEmpty
        ? l.widgetTodayTitle(nextTitle)
        : l.widgetScenesLeftToday(goal - done);
    final progressLabel = goalMet
        ? (nextTitle.isNotEmpty
              ? l.widgetTomorrowTitle(nextTitle)
              : l.widgetGoalDone)
        : (nextTitle.isNotEmpty
              ? l.widgetTodayTitle(nextTitle)
              : l.widgetProgressScenes(done, goal));
    final days = l.widgetDaysInRow(streak);

    // O card: o widget nativo conta até [dayEnd] sozinho e, se o app não
    // abrir, vira o dia com os textos `next_*` (garantida → em risco) ou
    // `away_*` (dia perdido).
    final String state;
    final String headline;
    final String big;
    final String sub;
    if (walked) {
      state = 'safe';
      headline = l.widgetStreakSafe;
      big = progressLabel;
      sub = goalMet ? days : '$days · ${l.widgetScenesLeft(goal - done)}';
    } else if (atRisk) {
      state = 'risk';
      headline = l.widgetKeepStreak;
      big = '';
      sub = '$days · ${l.widgetScenesLeft(goal)}';
    } else if (streak <= 0) {
      state = 'start';
      headline = l.widgetStartStreak;
      big = '';
      sub = todayLabel;
    } else {
      state = 'away';
      headline = l.widgetBackToTrail;
      big = todayLabel;
      sub = l.widgetBehindCaravan;
    }

    final now = DateTime.now();
    final dayEnd = DateTime(now.year, now.month, now.day + 1);

    await HomeWidget.saveWidgetData('streak', streak);
    await HomeWidget.saveWidgetData('card_state', state);
    await HomeWidget.saveWidgetData(
      'card_day_end',
      dayEnd.millisecondsSinceEpoch,
    );
    await HomeWidget.saveWidgetData('card_headline', headline);
    await HomeWidget.saveWidgetData('card_big', big);
    await HomeWidget.saveWidgetData('card_sub', sub);
    await HomeWidget.saveWidgetData('card_next_headline', l.widgetKeepStreak);
    await HomeWidget.saveWidgetData(
      'card_next_sub',
      '$days · ${l.widgetScenesLeft(goal)}',
    );
    await HomeWidget.saveWidgetData('card_away_headline', l.widgetBackToTrail);
    await HomeWidget.saveWidgetData('card_away_big', todayLabel);
    await HomeWidget.saveWidgetData('card_away_sub', l.widgetBehindCaravan);

    await HomeWidget.updateWidget(
      androidName: _androidProvider,
      iOSName: _iosKind,
      qualifiedAndroidName: 'com.trilha.trilha_app.$_androidProvider',
    );
  }
}
