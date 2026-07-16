import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../services/backend_service.dart';
import '../services/companion_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../widgets/immersive_background.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/top_bar.dart';
import 'bible_screen.dart';
import 'home_screen.dart';
import 'league_screen.dart';
import 'me_screen.dart';
import 'settings_screen.dart';
import 'trilhas_screen.dart';
import 'trail_map_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _repo = TrailRepository();
  final _frost = FrostController();
  Timer? _phaseTimer;
  AppearanceLook? _lastLook;

  ProgressService? _progressRef;

  @override
  void initState() {
    super.initState();
    // Atualiza o visual automático na virada de faixa horária.
    _phaseTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      final mode = context.read<ProgressService>().settings.appearanceMode;
      final look = AppearanceStyle.resolve(mode).look;
      if (look != _lastLook) setState(() => _lastLook = look);
    });
    // Backup automático na nuvem a cada mudança de progresso.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _progressRef = context.read<ProgressService>();
      _progressRef!.addListener(_onProgressChanged);
      // Garante flush imediato do estado atual.
      context.read<BackendService>().saveNow(
            _progressRef!,
            LeagueService.weekKey(),
            roomCode: context.read<RoomService>().activeCode,
          );
    });
  }

  void _onProgressChanged() {
    if (!mounted) return;
    final progress = _progressRef;
    if (progress == null) return;
    context.read<BackendService>().scheduleSave(
          progress,
          LeagueService.weekKey(),
          roomCode: context.read<RoomService>().activeCode,
        );
    if (progress.missionsToday > 0) {
      context.read<CompanionService>().syncWalksIfNeeded(progress);
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _frost.dispose();
    _progressRef?.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _openTrail(String slug) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrailMapScreen(slug: slug)),
    );
  }

  void _openMission(String missionSlug) {
    Navigator.of(context).pushNamed('/lesson', arguments: missionSlug);
  }

  void _openProfile() {
    final mode = context.read<ProgressService>().settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Appearance(
          mode: mode,
          style: appearance,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: TopBar(
              immersive: true,
              dark: appearance.onDark,
              title: 'Eu',
              subtitle: 'Sua jornada, seu ritmo',
              onBack: () => Navigator.pop(ctx),
            ),
            body: ImmersiveBackground(
              appearance: appearance,
              child: const MeScreen(),
            ),
          ),
        ),
      ),
    );
  }

  void _openTrilhasCatalog() {
    final appearance = AppearanceStyle.resolve(
      context.read<ProgressService>().settings.appearanceMode,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Appearance(
          mode: context.read<ProgressService>().settings.appearanceMode,
          style: appearance,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: TopBar(
              immersive: true,
              dark: true,
              title: 'Trilhas',
              subtitle: 'Escolha o caminho',
              onBack: () => Navigator.pop(ctx),
            ),
            body: ImmersiveBackground(
              appearance: appearance,
              child: TrilhasScreen(
                repo: _repo,
                asPushedPage: true,
              ),
            ),
          ),
        ),
      ),
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
    final statusLight = appearance.onDark || appearance.look == AppearanceLook.morning;

    return Appearance(
      mode: mode,
      style: appearance,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusLight ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: statusLight ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: homeBg,
          extendBody: true,
          extendBodyBehindAppBar: false,
          appBar: TopBar(
            immersive: true,
            dark: appearance.onDark,
            frost: _frost,
            personalGreeting: _index == 0,
            photoUrl: backend.userPhotoUrl,
            onProfileTap: _index == 0 ? _openProfile : null,
            title: switch (_index) {
              0 => progress.userName,
              1 => 'Bíblia',
              2 => 'Juntos',
              _ => 'Configurações',
            },
            subtitle: switch (_index) {
              0 => DayPhaseHelper.greeting(appearance.phase),
              1 => 'Leia a Palavra completa',
              2 => 'Caravana · Companhia · Salas',
              _ => 'Preferências e conta',
            },
          ),
          body: _frost.attach(IndexedStack(
            index: _index,
            children: [
              ImmersiveBackground(
                appearance: appearance,
                child: HomeScreen(
                  repo: _repo,
                  onOpenTrail: _openTrail,
                  onOpenMission: _openMission,
                  onOpenTrilhas: _openTrilhasCatalog,
                ),
              ),
              ImmersiveBackground(
                appearance: appearance,
                child: const BibleScreen(),
              ),
              ImmersiveBackground(
                appearance: appearance,
                child: const LeagueScreen(),
              ),
              ImmersiveBackground(
                appearance: appearance,
                child: const SettingsScreen(),
              ),
            ],
          )),
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
