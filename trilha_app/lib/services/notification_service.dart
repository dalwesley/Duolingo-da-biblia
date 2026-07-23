import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/memory_verses.dart';
import '../models/daily_quest.dart';
import 'progress_service.dart';

/// Ação ao tocar na notificação (deep link leve).
enum ReminderAction {
  home,
  practice,
  memory,
  favorites,
  weekly,
  league,
}

extension ReminderActionX on ReminderAction {
  String get payload => name;

  static ReminderAction? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final a in ReminderAction.values) {
      if (a.name == raw) return a;
    }
    return null;
  }
}

class _ReminderCopy {
  final String title;
  final String body;
  final ReminderAction action;
  final int priority;

  const _ReminderCopy({
    required this.title,
    required this.body,
    required this.action,
    required this.priority,
  });
}

/// Lembretes estilo Duolingo — slots recorrentes + lost-learner D+1/D+2.
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _available = true;

  /// Última ação pendente (lida pelo MainShell ao abrir).
  ReminderAction? pendingAction;
  void Function(ReminderAction action)? onAction;

  static const _channelId = 'trilha_habits';
  static const _channelName = 'Lembretes da caminhada';
  static const _channelDesc =
      'Meta diária, missões, prática, memorizar e favoritos';

  static const _idMorning = 100;
  static const _idAfternoon = 101;
  static const _idEvening = 102;
  static const _idWeekly = 103;
  static const _idSoft = 104;
  static const _idLost1 = 105;
  static const _idLost2 = 106;
  static const _legacyDaily = 1;

  static const _allIds = [
    _legacyDaily,
    _idMorning,
    _idAfternoon,
    _idEvening,
    _idWeekly,
    _idSoft,
    _idLost1,
    _idLost2,
  ];

  Future<void> init() async {
    if (_initialized || !_available) return;
    tz_data.initializeTimeZones();
    _configureLocalTimezone();

    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onTap,
      );

      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();

      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true) {
        pendingAction =
            ReminderActionX.tryParse(launch!.notificationResponse?.payload);
      }

      _initialized = true;
    } on MissingPluginException {
      _available = false;
    } catch (_) {
      _available = false;
    }
  }

  void _onTap(NotificationResponse response) {
    final action = ReminderActionX.tryParse(response.payload);
    if (action == null) return;
    pendingAction = action;
    onAction?.call(action);
  }

  ReminderAction? takePendingAction() {
    final a = pendingAction;
    pendingAction = null;
    return a;
  }

  /// Reagenda lembretes conforme o progresso atual.
  Future<void> syncFromProgress(ProgressService progress) async {
    await init();
    if (!_available || !_initialized) return;

    final enabled = progress.settings.notifications;
    await _cancelAll();
    if (!enabled) return;

    final hooks = _buildHooks(progress);
    if (hooks.isEmpty) {
      await _schedule(
        id: _idMorning,
        when: _nextSlot(10, 0),
        copy: const _ReminderCopy(
          title: 'Seu próximo passo',
          body: 'A caminhada continua amanhã. Um passo basta.',
          action: ReminderAction.home,
          priority: 1,
        ),
        daily: true,
      );
      await _scheduleLostLearner(progress);
      return;
    }

    hooks.sort((a, b) => b.priority.compareTo(a.priority));

    final slots = <(int id, tz.TZDateTime when)>[
      (_idMorning, _nextSlot(10, 0)),
      (_idAfternoon, _nextSlot(15, 0)),
      (_idEvening, _nextSlot(19, 0)),
    ];

    if (hooks.length >= 4) {
      slots.add((_idSoft, _nextSlot(20, 30)));
    }

    for (var i = 0; i < slots.length && i < hooks.length; i++) {
      final (id, at) = slots[i];
      // Slots principais repetem diariamente — não morrem se o app não abrir.
      final daily = id == _idMorning ||
          id == _idAfternoon ||
          id == _idEvening;
      await _schedule(id: id, when: at, copy: hooks[i], daily: daily);
    }

    final weeklyIncomplete =
        progress.weeklyQuestsCompleted < WeeklyQuestDefs.all.length;
    if (weeklyIncomplete) {
      await _schedule(
        id: _idWeekly,
        when: _nextWeekday(DateTime.saturday, 11, 0),
        copy: const _ReminderCopy(
          title: 'Passos da semana',
          body: 'Ainda dá tempo de fechar as missões semanais.',
          action: ReminderAction.weekly,
          priority: 4,
        ),
      );
    }

    await _scheduleLostLearner(progress);
  }

  /// D+1 / D+2 — copy de ausência mesmo sem reabrir o app.
  Future<void> _scheduleLostLearner(ProgressService progress) async {
    if (progress.walkedToday) return;
    if (progress.lastPlayedDate == null) return;

    final daysAway = progress.daysSinceLastPlayed;
    final name = progress.userName.trim().isEmpty
        ? 'peregrino'
        : progress.userName.trim().split(' ').first;
    final streak = progress.streak;

    // Já ausente ≥1 dia: agenda amanhã (D+1 a partir de agora) e depois.
    if (daysAway >= 1) {
      await _schedule(
        id: _idLost1,
        when: _daysFromNow(1, 10, 15),
        copy: _ReminderCopy(
          title: 'A caravana sente sua falta',
          body: streak > 0
              ? '$name, sua chama de $streak ${streak == 1 ? 'dia' : 'dias'} ainda brilha. Um passo e você alcança o grupo.'
              : '$name, a caravana seguiu — mas o lugar ao seu lado continua aberto.',
          action: ReminderAction.home,
          priority: 110,
        ),
      );
    }

    if (daysAway >= 1) {
      await _schedule(
        id: _idLost2,
        when: _daysFromNow(2, 19, 0),
        copy: _ReminderCopy(
          title: 'Ainda dá tempo',
          body: progress.hasStreakFreeze
              ? '$name, o gelo pode cobrir 1 dia. Volte hoje e proteja a caminhada.'
              : '$name, um único passo reacende a chama. A caravana te espera.',
          action: ReminderAction.home,
          priority: 105,
        ),
      );
    }

    // Ainda no dia em risco (jogou ontem): reforço noturno one-shot.
    if (progress.isStreakAtRisk && daysAway == 1) {
      await _schedule(
        id: _idSoft,
        when: _nextSlot(20, 30),
        copy: _ReminderCopy(
          title: 'Última chamada',
          body:
              '$name, faltam ${progress.streakRiskCountdown}. Um passo e a caravana te alcança.',
          action: ReminderAction.home,
          priority: 130,
        ),
      );
    }
  }

  Future<void> scheduleDailyReminder({
    required bool enabled,
    int hour = 19,
    int minute = 0,
  }) async {
    await init();
    if (!_available || !_initialized) return;
    if (!enabled) {
      await _cancelAll();
      return;
    }
    await _schedule(
      id: _idEvening,
      when: _nextSlot(hour, minute),
      copy: const _ReminderCopy(
        title: 'Meta de hoje',
        body: 'Ainda dá tempo de cumprir sua meta diária no Steway.',
        action: ReminderAction.home,
        priority: 10,
      ),
      daily: true,
    );
  }

  List<_ReminderCopy> _buildHooks(ProgressService progress) {
    final hooks = <_ReminderCopy>[];
    final name = progress.userName.trim().isEmpty
        ? 'peregrino'
        : progress.userName.trim().split(' ').first;
    final goal = progress.settings.dailyGoal;
    final done = progress.walkedToday ? progress.missionsToday : 0;
    final streak = progress.streak;
    final mistakes = progress.mistakeQuestionIds.length;
    final memoryPending = MemoryVerseCatalog.curated
        .where((v) => !progress.isMemoryMastered(v.id))
        .length;
    final favs = progress.parseBookmarks().length;

    if (!progress.dailyGoalMet) {
      final left = (goal - done).clamp(1, goal);
      final atRisk = progress.isStreakAtRisk;
      final returning = progress.isReturningAfterGap;
      hooks.add(_ReminderCopy(
        title: atRisk
            ? 'A caravana segue'
            : returning
                ? 'A caravana te espera'
                : streak > 0
                    ? 'A caravana te espera'
                    : 'Meta de hoje',
        body: atRisk
            ? '$name, você está ficando para trás na caravana. Faltam ${progress.streakRiskCountdown} — um passo e você alcança o grupo.'
            : returning
                ? '$name, faz ${progress.daysSinceLastPlayed} ${progress.daysSinceLastPlayed == 1 ? 'dia' : 'dias'} sem passo. Um toque reacende a chama.'
                : streak > 0
                    ? '$name, a caravana já anda há $streak ${streak == 1 ? 'dia' : 'dias'}. Falta${left == 1 ? '' : 'm'} $left missão${left == 1 ? '' : 'ões'} para acompanhar.'
                    : 'Falta${left == 1 ? '' : 'm'} $left missão${left == 1 ? '' : 'ões'} para fechar a meta de hoje.',
        action: ReminderAction.home,
        priority: atRisk
            ? 120
            : returning
                ? 115
                : 100,
      ));
    }

    final questsLeft =
        DailyQuestDefs.all.length - progress.questsCompletedToday;
    if (questsLeft > 0) {
      hooks.add(_ReminderCopy(
        title: 'Missões diárias',
        body: questsLeft == 1
            ? 'Sobrou 1 missão diária. Um toque e ela some da lista.'
            : 'Você ainda tem $questsLeft missões diárias pela frente.',
        action: ReminderAction.home,
        priority: 80,
      ));
    }

    if (mistakes > 0) {
      hooks.add(_ReminderCopy(
        title: 'Hora de praticar',
        body: mistakes == 1
            ? 'Tem 1 erro para reforçar. Pratique agora e fixe o aprendizado.'
            : 'Tem $mistakes erros para reforçar. Prática rápida, mente firme.',
        action: ReminderAction.practice,
        priority: 70,
      ));
    }

    if (memoryPending > 0) {
      hooks.add(_ReminderCopy(
        title: 'Memorizar',
        body: memoryPending == 1
            ? 'Um versículo espera por você. Dois minutos bastam.'
            : '$memoryPending versículos no deck. Memorizar fortalece a jornada.',
        action: ReminderAction.memory,
        priority: 55,
      ));
    }

    if (favs > 0) {
      hooks.add(_ReminderCopy(
        title: 'Seus favoritos',
        body: favs == 1
            ? 'Você guardou um versículo. Que tal revisitá-lo agora?'
            : 'Você tem $favs favoritos. Releia um e reacenda o fogo.',
        action: ReminderAction.favorites,
        priority: 40,
      ));
    }

    if (progress.weeklyQuestsCompleted < WeeklyQuestDefs.all.length) {
      final left =
          WeeklyQuestDefs.all.length - progress.weeklyQuestsCompleted;
      hooks.add(_ReminderCopy(
        title: 'Passos da semana',
        body: left == 1
            ? 'Falta 1 passo semanal. Feche o ciclo com calma.'
            : 'Ainda faltam $left passos semanais. A semana ainda é sua.',
        action: ReminderAction.weekly,
        priority: 50,
      ));
    }

    if (progress.dailyGoalMet && hooks.length < 2) {
      hooks.add(_ReminderCopy(
        title: '${progress.steps} passos',
        body: 'Meta cumprida. Que tal um reforço rápido ou um versículo?',
        action: mistakes > 0
            ? ReminderAction.practice
            : memoryPending > 0
                ? ReminderAction.memory
                : ReminderAction.home,
        priority: 20,
      ));
    }

    return hooks;
  }

  Future<void> _schedule({
    required int id,
    required tz.TZDateTime when,
    required _ReminderCopy copy,
    bool daily = false,
  }) async {
    await _plugin.zonedSchedule(
      id,
      copy.title,
      copy.body,
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(copy.body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: daily ? DateTimeComponents.time : null,
      payload: copy.action.payload,
    );
  }

  Future<void> _cancelAll() async {
    for (final id in _allIds) {
      await _plugin.cancel(id);
    }
  }

  tz.TZDateTime _nextSlot(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now.add(const Duration(minutes: 2)))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _daysFromNow(int days, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).add(Duration(days: days));
    if (!scheduled.isAfter(now.add(const Duration(minutes: 2)))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday ||
        !scheduled.isAfter(now.add(const Duration(minutes: 2)))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  void _configureLocalTimezone() {
    try {
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    } catch (_) {
      /* tz.local permanece o padrão */
    }
  }
}
