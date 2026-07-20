import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../services/backend_service.dart';
import '../services/companion_service.dart';
import '../services/home_widget_service.dart';
import '../services/league_service.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/top_bar.dart';
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
  final _repo = TrailRepository();
  final _frost = FrostController();
  Timer? _phaseTimer;
  AppearanceLook? _lastLook;

  ProgressService? _progressRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _phaseTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      final mode = context.read<ProgressService>().settings.appearanceMode;
      final look = AppearanceStyle.resolve(mode).look;
      if (look != _lastLook) setState(() => _lastLook = look);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _progressRef = context.read<ProgressService>();
      _progressRef!.addListener(_onProgressChanged);
      _flushCloudSave();
      _syncReminders();
      NotificationService.instance.onAction = _handleReminderAction;
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
    });
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
    HomeWidgetService.syncFromProgress(progress);
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
      context.read<CompanionService>().syncWalksIfNeeded(progress);
    }
    HomeWidgetService.syncFromProgress(progress);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _flushCloudSave();
      _syncReminders();
      final progress = _progressRef;
      if (progress != null) {
        HomeWidgetService.syncFromProgress(progress);
      }
    }
    if (state == AppLifecycleState.resumed) {
      final pending = NotificationService.instance.takePendingAction();
      if (pending != null) _handleReminderAction(pending);
      _syncReminders();
    }
  }

  void _handleReminderAction(ReminderAction action) {
    if (!mounted) return;
    switch (action) {
      case ReminderAction.home:
        setState(() {
          _index = 0;
          _frost.value = 0;
        });
      case ReminderAction.practice:
        setState(() {
          _index = 0;
          _frost.value = 0;
        });
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PracticeScreen()),
        );
      case ReminderAction.memory:
        setState(() {
          _index = 0;
          _frost.value = 0;
        });
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MemoryScreen()),
        );
      case ReminderAction.favorites:
      case ReminderAction.weekly:
        _openProfile();
    }
  }

  @override
  void dispose() {
    _flushCloudSave();
    WidgetsBinding.instance.removeObserver(this);
    _phaseTimer?.cancel();
    _frost.dispose();
    _progressRef?.removeListener(_onProgressChanged);
    NotificationService.instance.onAction = null;
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

  void _openProfile() {
    final progress = context.read<ProgressService>();
    final backend = context.read<BackendService>();
    final mode = progress.settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Appearance(
          mode: mode,
          style: appearance,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: ImmersiveBackground(
              appearance: appearance,
              child: MeScreen(
                topBar: TopBar(
                  inline: true,
                  immersive: true,
                  dark: appearance.onDark,
                  title: progress.userName,
                  subtitle: 'Sua jornada, seu ritmo',
                  onBack: () => Navigator.pop(ctx),
                  photoUrl: backend.userPhotoUrl,
                  showTrailingAvatar: true,
                  showLeading: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToTrilhas() => setState(() {
    _index = 2;
    _frost.value = 0;
  });

  Widget _tabTopBar({
    required int index,
    required ProgressService progress,
    required BackendService backend,
    required AppearanceStyle appearance,
  }) {
    return TopBar(
      inline: true,
      immersive: true,
      dark: appearance.onDark,
      personalGreeting: index == 0,
      photoUrl: backend.userPhotoUrl,
      onProfileTap: index == 0 ? _openProfile : null,
      showLeading: true,
      leadingGlyph: switch (index) {
        0 => CinematicGlyph.home,
        1 => CinematicGlyph.book,
        2 => CinematicGlyph.path,
        3 => CinematicGlyph.people,
        _ => CinematicGlyph.tune,
      },
      title: switch (index) {
        0 => progress.userName,
        1 => 'Bíblia',
        2 => 'Trilhas',
        3 => 'Juntos',
        _ => 'Config',
      },
      subtitle: switch (index) {
        0 => DayPhaseHelper.greeting(appearance.phase),
        1 => 'A Palavra, offline',
        2 => 'Escolha o caminho',
        3 => 'Companhia · Caravana · Salas',
        _ => 'Ritmo · Aparência · Conta',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final mode = progress.settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);
    _lastLook = appearance.look;
    final homeBg = DayPhaseHelper.scaffoldBackground(appearance.phase);
    final statusLight =
        appearance.onDark || appearance.look == AppearanceLook.morning;

    return Appearance(
      mode: mode,
      style: appearance,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusLight
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: statusLight
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: homeBg,
          extendBody: true,
          body: _frost.attach(
            IndexedStack(
              index: _index,
              children: [
                ImmersiveBackground(
                  appearance: appearance,
                  child: HomeScreen(
                    repo: _repo,
                    topBar: _tabTopBar(
                      index: 0,
                      progress: progress,
                      backend: backend,
                      appearance: appearance,
                    ),
                    onOpenTrail: _openTrail,
                    onOpenMission: _openMission,
                    onOpenTrilhas: _goToTrilhas,
                  ),
                ),
                ImmersiveBackground(
                  appearance: appearance,
                  child: BibleScreen(
                    topBar: _tabTopBar(
                      index: 1,
                      progress: progress,
                      backend: backend,
                      appearance: appearance,
                    ),
                  ),
                ),
                ImmersiveBackground(
                  appearance: appearance,
                  child: TrilhasScreen(
                    repo: _repo,
                    topBar: _tabTopBar(
                      index: 2,
                      progress: progress,
                      backend: backend,
                      appearance: appearance,
                    ),
                  ),
                ),
                ImmersiveBackground(
                  appearance: appearance,
                  child: LeagueScreen(
                    topBar: _tabTopBar(
                      index: 3,
                      progress: progress,
                      backend: backend,
                      appearance: appearance,
                    ),
                  ),
                ),
                ImmersiveBackground(
                  appearance: appearance,
                  child: SettingsScreen(
                    topBar: _tabTopBar(
                      index: 4,
                      progress: progress,
                      backend: backend,
                      appearance: appearance,
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: MainBottomNav(
            currentIndex: _index,
            onTap: (i) => setState(() {
              _index = i;
              _frost.value = 0;
            }),
            immersive: true,
            dark: appearance.onDark,
            appearance: appearance,
          ),
        ),
      ),
    );
  }
}
