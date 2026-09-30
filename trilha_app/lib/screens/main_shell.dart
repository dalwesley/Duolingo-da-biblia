import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/corner_challenge.dart';
import '../models/walk_companion.dart';
import '../services/app_update_service.dart';
import '../services/backend_service.dart';
import '../services/companion_service.dart';
import '../services/corner_service.dart';
import '../services/home_widget_service.dart';
import '../services/invite_deep_link_service.dart';
import '../services/league_service.dart';
import '../services/medal_engagement_service.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../services/remote_config_service.dart';
import '../services/room_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/liturgical_calendar.dart';
import '../widgets/juntos_inbox.dart';
import '../widgets/app_update_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/corner_burst.dart';
import '../widgets/immersive_background.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'bible_screen.dart';
import 'home_screen.dart';
import 'league_screen.dart';
import 'me_screen.dart';
import 'memory_screen.dart';
import 'practice_screen.dart';
import 'settings_screen.dart';
import 'trilhas_screen.dart';
import 'trail_map_screen.dart';

class MainShell extends StatefulWidget {
  /// Se definido, abre o mapa dessa trilha após o primeiro frame
  /// (ex.: onboarding → Gênesis).
  final String? initialTrailSlug;

  const MainShell({super.key, this.initialTrailSlug});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _index = 0;

  /// Abas já montadas. A aberta monta na hora; as demais entram uma por vez
  /// depois que a Home assenta — a 1ª abertura não constrói as cinco juntas.
  final Set<int> _built = {};
  Timer? _warmTimer;
  static const _warmOrder = [1, 3, 2, 4];

  void _warmNextTab() {
    _warmTimer = null;
    if (!mounted) return;
    final next = _warmOrder.where((i) => !_built.contains(i)).firstOrNull;
    if (next == null) return;
    setState(() => _built.add(next));
    _warmTimer = Timer(const Duration(milliseconds: 350), _warmNextTab);
  }

  Widget _lazyTab(int index, Widget Function() build) {
    if (!_built.contains(index)) return const SizedBox.shrink();
    // Trocar o idioma recria as abas guardadas no IndexedStack (textos
    // lidos em initState/L10n.current). Ajustes fica de fora: é onde o
    // idioma muda, e já lê tudo por context.l10n.
    final child = index == 4
        ? build()
        : KeyedSubtree(key: ValueKey(_languageCode), child: build());
    return TickerMode(enabled: _index == index, child: child);
  }

  String _languageCode = 'pt';

  final _repo = TrailRepository();
  final _frost = FrostController();
  Timer? _phaseTimer;
  Timer? _presenceTimer;
  bool _presenceSyncing = false;
  AppearanceLook? _lastLook;
  DayPhase? _lastClockPhase;

  ProgressService? _progressRef;
  BackendService? _backendRef;
  CornerService? _cornerRef;

  /// Evita fetch duplicado se o SO dispara vários `resumed` em sequência.
  bool _resumeHydrateInFlight = false;
  DateTime? _lastResumeHydrateAt;
  static const _resumeHydrateMinInterval = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastClockPhase = DayPhaseHelper.current();
    _phaseTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      final mode = context.read<ProgressService>().settings.appearanceMode;
      final look = AppearanceStyle.resolve(mode).look;
      final clockPhase = DayPhaseHelper.current();
      // Look (tema) ou fase do relógio (saudação) mudou.
      if (look != _lastLook || clockPhase != _lastClockPhase) {
        setState(() {
          _lastLook = look;
          _lastClockPhase = clockPhase;
        });
      }
    });
    InviteDeepLinkService.instance.addListener(_onInviteDeepLink);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _progressRef = context.read<ProgressService>();
      _progressRef!.addListener(_onProgressChanged);
      _backendRef = context.read<BackendService>();
      _backendRef!.addListener(_onBackendChanged);
      _cornerRef = context.read<CornerService>();
      _cornerRef!.addListener(_onCornerChanged);
      _flushCloudSave();
      _syncReminders();
      _warmTimer = Timer(const Duration(milliseconds: 1200), _warmNextTab);
      NotificationService.instance.onAction = _handleReminderAction;
      NotificationService.instance.onRemoteToken = (token) {
        context.read<BackendService>().saveFcmToken(token);
      };
      NotificationService.instance.onRemoteNudge = () {
        unawaited(context.read<CompanionService>().refresh());
        unawaited(context.read<CornerService>().refresh());
      };
      unawaited(
        NotificationService.instance.initRemote(
          requestPermission:
              _progressRef?.notificationsPrompted == true &&
              _progressRef?.settings.notifications == true,
        ),
      );
      unawaited(RemoteConfigService.instance.init());
      _onBackendChanged();
      final pending = NotificationService.instance.takePendingAction();
      if (pending != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _handleReminderAction(pending);
        });
      }
      final trail = widget.initialTrailSlug;
      if (trail != null && trail.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openTrail(trail);
        });
      }
      unawaited(_maybePromptAppUpdate());
      _openJuntosIfInvitePending();
      MedalEngagementService.instance.scheduleCheck(context);
    });
  }

  void _onBackendChanged() {
    final backend = _backendRef;
    if (backend == null || !backend.isActive) return;
    NotificationService.instance.emitRemoteToken();
  }

  void _onInviteDeepLink() {
    if (!mounted) return;
    _openJuntosIfInvitePending();
  }

  void _openJuntosIfInvitePending() {
    final links = InviteDeepLinkService.instance;
    final openTab = links.takeWantJuntosTab();
    if (!openTab &&
        links.pendingCompanionCode == null &&
        links.pendingRoomCode == null) {
      return;
    }
    setState(() {
      _index = 3;
      _frost.value = 0;
    });
  }

  Future<void> _maybePromptAppUpdate() async {
    final status = await AppUpdateService.checkForPrompt();
    if (!mounted || status == null) return;
    await showAppUpdateSheet(context, status);
  }

  void _syncReminders() {
    final progress = _progressRef;
    if (progress == null) return;
    if (!progress.isLoaded) {
      void once() {
        if (!progress.isLoaded) return;
        progress.removeListener(once);
        NotificationService.instance.syncFromProgress(progress);
        HomeWidgetService.syncFromProgress(progress);
      }

      progress.addListener(once);
      return;
    }
    NotificationService.instance.syncFromProgress(progress);
    HomeWidgetService.syncFromProgress(progress, immediate: true);
  }

  void _flushCloudSave() {
    if (!mounted) return;
    final progress = _progressRef;
    if (progress == null) return;
    context.read<BackendService>().saveNow(
      progress,
      LeagueService.weekKey(),
      roomCode: context.read<RoomService>().activeCode,
      league: context.read<LeagueService>(),
    );
  }

  void _onProgressChanged() {
    if (!mounted) return;
    final progress = _progressRef;
    if (progress == null) return;
    context.read<BackendService>().scheduleSave(
      progress,
      LeagueService.weekKey(),
      roomCode: context.read<RoomService>().activeCode,
      league: context.read<LeagueService>(),
    );
    if (progress.walkedToday) {
      // Uma ação dispara vários notify; junta num só sync (Firestore +
      // refresh da companhia) em vez de um por notify.
      _presenceTimer?.cancel();
      _presenceTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted || _presenceSyncing) return;
        _presenceSyncing = true;
        unawaited(
          _syncCompanionAndCelebrateReferral(
            progress,
          ).whenComplete(() => _presenceSyncing = false),
        );
      });
    }
    HomeWidgetService.syncFromProgress(progress);
    if (context.read<BackendService>().isSignedIn &&
        progress.hasSeenOnboarding) {
      MedalEngagementService.instance.scheduleCheck(context);
    }
  }

  Future<void> _syncCompanionAndCelebrateReferral(
    ProgressService progress,
  ) async {
    final result = await context.read<CompanionService>().syncPresence(
      progress,
    );
    if (!mounted || !result.hasFeedback) return;
    final messages = <String>[
      if (result.referralCodes.isNotEmpty)
        context.l10n.shellReferralBonus(
          result.referralCodes.length,
          result.referralCodes.length *
              ProgressService.referralFirstMissionBonus,
        ),
      if (result.weekTogetherBonusGranted)
        context.l10n.shellWeekTogetherBonus(
          WalkCompanion.weekTogetherBonusSteps,
        ),
    ];
    if (messages.isEmpty) return;
    showAppToastFor(
      context,
      message: messages.join(' · '),
      glyph: CinematicGlyph.gift,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(TtsService.instance.stop());
      _flushCloudSave();
      _syncReminders();
      final progress = _progressRef;
      if (progress != null) {
        unawaited(progress.persistLocalCache());
        HomeWidgetService.syncFromProgress(progress, immediate: true);
      }
    }
    if (state == AppLifecycleState.resumed) {
      final pending = NotificationService.instance.takePendingAction();
      if (pending != null) _handleReminderAction(pending);
      _syncReminders();
      // Outro aparelho pode ter avançado na nuvem enquanto este ficou aberto.
      unawaited(_syncCloudOnResume());
    }
  }

  /// Re-lê `users/{uid}` e só depois fecha a semana da liga.
  Future<void> _syncCloudOnResume() async {
    if (!mounted) return;
    final progress = _progressRef;
    if (progress == null || !progress.isLoaded) return;

    final now = DateTime.now();
    final last = _lastResumeHydrateAt;
    if (_resumeHydrateInFlight ||
        (last != null && now.difference(last) < _resumeHydrateMinInterval)) {
      return;
    }

    _resumeHydrateInFlight = true;
    try {
      final backend = context.read<BackendService>();
      final league = context.read<LeagueService>();
      final rooms = context.read<RoomService>();
      if (!backend.isActive) return;

      await backend.pullLatestProgress(
        progress,
        league: league,
        roomCode: rooms.activeCode,
      );
      if (!mounted) return;
      _lastResumeHydrateAt = DateTime.now();

      unawaited(_syncCompanionAndCelebrateReferral(progress));
      unawaited(context.read<CornerService>().refresh());
      rooms.ensureInviteListener();

      await backend.settleAndSyncLeague(
        progress,
        league,
        roomCode: rooms.activeCode,
      );
    } finally {
      _resumeHydrateInFlight = false;
    }
  }

  /// Quem convidou vê a travessia começar quando descobre que o outro aceitou.
  void _onCornerChanged() {
    final corners = _cornerRef;
    final uid = _backendRef?.uid;
    if (!mounted || corners == null || uid == null) return;
    final reveal = corners.takeAcceptReveal();
    if (reveal == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showCornerBurst(
        context,
        peerName: reveal.peerName(uid),
        peerPhoto: reveal.peerPhoto(uid),
        caption: CornerCopy.acceptedBy(reveal.peerName(uid)),
        kicker: reveal.missionTitle,
      );
    });
  }

  void _handleReminderAction(ReminderAction action) {
    if (!mounted) return;
    switch (action) {
      case ReminderAction.home:
        setState(() {
          _index = 0;
          _frost.value = 0;
        });
      case ReminderAction.league:
        setState(() {
          _index = 3;
          _frost.value = 0;
        });
      case ReminderAction.practice:
        setState(() {
          _index = 0;
          _frost.value = 0;
        });
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PracticeScreen()));
      case ReminderAction.memory:
        setState(() {
          _index = 0;
          _frost.value = 0;
        });
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MemoryScreen()));
      case ReminderAction.favorites:
      case ReminderAction.weekly:
        _openProfile();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _phaseTimer?.cancel();
    _presenceTimer?.cancel();
    _warmTimer?.cancel();
    _frost.dispose();
    _progressRef?.removeListener(_onProgressChanged);
    InviteDeepLinkService.instance.removeListener(_onInviteDeepLink);
    NotificationService.instance.onAction = null;
    NotificationService.instance.onRemoteNudge = null;
    NotificationService.instance.onRemoteToken = null;
    _backendRef?.removeListener(_onBackendChanged);
    _cornerRef?.removeListener(_onCornerChanged);
    super.dispose();
  }

  void _openTrail(String slug) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TrailMapScreen(slug: slug)));
  }

  void _openMission(String missionSlug) {
    Navigator.of(context).pushNamed('/lesson', arguments: missionSlug);
  }

  void _openProfile() => openMeProfile(context);

  void _goToTrilhas() => setState(() {
    _index = 1;
    _frost.value = 0;
  });

  Widget _tabTopBar({
    required int index,
    required String userName,
    required String? photoUrl,
    required AppearanceStyle appearance,
  }) {
    return TopBar(
      inline: true,
      immersive: true,
      dark: appearance.onDark,
      personalGreeting: index == 0,
      photoUrl: photoUrl,
      onProfileTap: index == 0 ? _openProfile : null,
      showLeading: true,
      chromeAccent: AppRoles.chrome,
      leadingGlyph: switch (index) {
        0 => CinematicGlyph.home,
        1 => CinematicGlyph.path,
        2 => CinematicGlyph.book,
        3 => CinematicGlyph.people,
        _ => CinematicGlyph.tune,
      },
      title: switch (index) {
        0 => userName,
        1 => context.l10n.navTrails,
        2 => context.l10n.navBible,
        3 => context.l10n.navTogether,
        _ => context.l10n.settingsTitle,
      },
      subtitle: switch (index) {
        0 => DayPhaseHelper.greeting(), // relógio — não o tema de aparência
        1 => context.l10n.shellTrailsSubtitle,
        2 => LiturgicalCalendar.momentFor().subtitle,
        3 => context.l10n.shellTogetherSubtitle,
        _ => context.l10n.settingsSubtitle,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Só o que muda o chrome do shell — evita rebuild de todas as abas
    // a cada passo/quest.
    final mode = context.select(
      (ProgressService p) => p.settings.appearanceMode,
    );
    final userName = context.select((ProgressService p) => p.userName);
    final photoUrl = context.select((BackendService b) => b.userPhotoUrl);
    final appearance = AppearanceStyle.resolve(mode);
    _lastLook = appearance.look;
    _built.add(_index);
    // Depende do idioma: o shell reconstrói (e recria as abas) ao trocar.
    _languageCode = Localizations.localeOf(context).languageCode;

    Widget tabBar(int index) => _tabTopBar(
      index: index,
      userName: userName,
      photoUrl: photoUrl,
      appearance: appearance,
    );

    return ImmersiveScaffold(
      mode: mode,
      style: appearance,
      extendBody: true,
      body: _frost.attach(
        _TabFade(
          index: _index,
          child: IndexedStack(
            index: _index,
            children: [
              _lazyTab(
                0,
                () => HomeScreen(
                  repo: _repo,
                  onOpenMission: _openMission,
                  onOpenTrilhas: _goToTrilhas,
                  onOpenProfile: _openProfile,
                  onOpenBible: () => setState(() {
                    _index = 2;
                    _frost.value = 0;
                  }),
                  onOpenLeague: () => setState(() {
                    _index = 3;
                    _frost.value = 0;
                  }),
                ),
              ),
              _lazyTab(
                1,
                () => TrilhasScreen(
                  repo: _repo,
                  topBar: tabBar(1),
                  portalsActive: _index == 1,
                ),
              ),
              _lazyTab(2, () => BibleScreen(topBar: tabBar(2))),
              _lazyTab(
                3,
                () => LeagueScreen(
                  topBar: tabBar(3),
                  active: _index == 3,
                  onOpenOwnProfile: _openProfile,
                  onOpenMission: _openMission,
                  onGoToday: () => setState(() {
                    _index = 0;
                    _frost.value = 0;
                  }),
                ),
              ),
              _lazyTab(
                4,
                () => SettingsScreen(
                  topBar: tabBar(4),
                  onOpenProfile: _openProfile,
                ),
              ),
            ],
          ),
        ),
      ),
      // Builder isola os watch de Juntos: uma novidade só redesenha a barra,
      // não as cinco abas.
      bottomNavigationBar: Builder(
        builder: (context) => MainBottomNav(
          alerts: {if (JuntosInbox.pending(context) > 0) 3},
          currentIndex: _index,
          onTap: (i) => setState(() {
            if (_index == 2 && i != 2) unawaited(TtsService.instance.stop());
            _index = i;
            _frost.value = 0;
          }),
          immersive: true,
          dark: appearance.onDark,
          appearance: appearance,
        ),
      ),
    );
  }
}

/// Troca de aba com um fade curto e leve subida — sem recriar as abas
/// (o [IndexedStack] por baixo mantém o estado de cada uma).
class _TabFade extends StatefulWidget {
  final int index;
  final Widget child;

  const _TabFade({required this.index, required this.child});

  @override
  State<_TabFade> createState() => _TabFadeState();
}

class _TabFadeState extends State<_TabFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
    value: 1,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );
  late final Animation<double> _opacity = Tween<double>(
    begin: 0.35,
    end: 1,
  ).animate(_t);
  late final Animation<Offset> _lift = Tween<Offset>(
    begin: const Offset(0, 10),
    end: Offset.zero,
  ).animate(_t);

  @override
  void didUpdateWidget(covariant _TabFade old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index &&
        !MediaQuery.of(context).disableAnimations) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FadeTransition não reconstrói as abas a cada frame do fade.
    return FadeTransition(
      opacity: _opacity,
      child: AnimatedBuilder(
        animation: _lift,
        builder: (context, child) =>
            Transform.translate(offset: _lift.value, child: child),
        child: widget.child,
      ),
    );
  }
}
