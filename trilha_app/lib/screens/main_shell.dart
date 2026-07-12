import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../services/progress_service.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../widgets/immersive_background.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/top_bar.dart';
import 'home_screen.dart';
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
  Timer? _phaseTimer;
  AppearanceLook? _lastLook;

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
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
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
          extendBodyBehindAppBar: true,
          appBar: TopBar(
            immersive: true,
            dark: appearance.onDark,
            personalGreeting: _index == 0,
            title: switch (_index) {
              0 => progress.userName,
              1 => 'Trilhas',
              _ => 'Configurações',
            },
            subtitle: switch (_index) {
              0 => DayPhaseHelper.greeting(appearance.phase),
              1 => 'Escolha seu caminho',
              _ => 'Personalize sua experiência',
            },
          ),
          body: switch (_index) {
            0 => ImmersiveBackground(
                appearance: appearance,
                child: HomeScreen(
                  repo: _repo,
                  onOpenTrail: _openTrail,
                  onOpenMission: _openMission,
                ),
              ),
            1 => ImmersiveBackground(
                appearance: appearance,
                child: TrilhasScreen(repo: _repo, onOpenTrail: _openTrail),
              ),
            _ => ImmersiveBackground(
                appearance: appearance,
                child: const SettingsScreen(),
              ),
          },
          bottomNavigationBar: MainBottomNav(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            immersive: true,
            dark: appearance.onDark,
            appearance: appearance,
          ),
        ),
      ),
    );
  }
}
