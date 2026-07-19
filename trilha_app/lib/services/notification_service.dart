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

/// Lembretes estilo Duolingo — slots do dia com copy baseada no progresso.
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
  static const _legacyDaily = 1;

  static const _allIds = [
    _legacyDaily,
    _idMorning,
    _idAfternoon,
    _idEvening,
    _idWeekly,
    _idSoft,
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
      );
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
      await _schedule(id: id, when: at, copy: hooks[i]);
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
        body: 'Ainda dá tempo de cumprir sua meta diária na Trilha.',
        action: ReminderAction.home,
        priority: 10,
      ),
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
      hooks.add(_ReminderCopy(
        title: atRisk
            ? 'Sequência em risco'
            : streak > 0
                ? 'Não perca a sequência'
                : 'Meta de hoje',
        body: atRisk
            ? '$name, faltam ${progress.streakRiskCountdown} para salvar $streak ${streak == 1 ? 'dia' : 'dias'}. Um passo agora.'
            : streak > 0
                ? '$name, são $streak ${streak == 1 ? 'dia' : 'dias'} seguidos. Falta${left == 1 ? '' : 'm'} $left missão${left == 1 ? '' : 'ões'} para a meta.'
                : 'Falta${left == 1 ? '' : 'm'} $left missão${left == 1 ? '' : 'ões'} para fechar a meta de hoje.',
        action: ReminderAction.home,
        priority: atRisk ? 120 : 100,
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
