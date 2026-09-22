import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../cinematic/cinematic_resolver.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/trail_visuals.dart';
import '../widgets/cinematic_backdrop.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/hero_card_atmosphere.dart';
import '../widgets/immersive_background.dart';
import '../widgets/stway_brand.dart';
import '../widgets/ui_primitives.dart';
import 'main_shell.dart';

/// Onboarding STWAY — cinco atos, do vazio à primeira missão.
///
/// O fundo da Criação muda de ato. O texto entra como cartela.
/// O quarto ato marca o retorno de amanhã. O nome, se faltar, entra ali.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Beat { origin, habit, walk, rhythm, threshold }

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  static const _beats = _Beat.values;

  final _nameController = TextEditingController();
  late final AnimationController _scene;
  late final AnimationController _breath;
  late final AnimationController _world;
  late final AnimationController _cut;

  int _index = 0;
  bool _askName = false;
  bool _finishing = false;
  bool _transitioning = false;
  bool _landed = false;

  CreationWorldState _fromWorld = const CreationWorldState(voidDepth: 1);
  CreationWorldState _toWorld = _worldFor(_Beat.origin);

  _Beat get _beat => _beats[_index];

  static CreationWorldState _worldFor(_Beat beat) => switch (beat) {
    _Beat.origin => const CreationWorldState(
      voidDepth: 0.96,
      spirit: 0.82,
      waters: 0.42,
    ),
    _Beat.habit => const CreationWorldState(
      voidDepth: 0.22,
      spirit: 0.4,
      waters: 0.26,
      light: 0.96,
    ),
    _Beat.walk => const CreationWorldState(
      voidDepth: 0.16,
      light: 0.62,
      waters: 0.34,
      land: 0.86,
      plants: 0.62,
    ),
    _Beat.rhythm => const CreationWorldState(
      voidDepth: 0.42,
      light: 0.34,
      stars: 0.96,
      land: 0.3,
    ),
    _Beat.threshold => const CreationWorldState(
      voidDepth: 0.16,
      light: 0.84,
      waters: 0.3,
      land: 0.7,
      plants: 0.5,
      humanity: 0.86,
    ),
  };

  static CinematicGlyph? _watermarkFor(_Beat beat) => switch (beat) {
    _Beat.origin => null,
    _Beat.habit => null,
    _Beat.walk => CinematicGlyph.path,
    _Beat.rhythm => null,
    _Beat.threshold => null,
  };

  @override
  void initState() {
    super.initState();

    _scene = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1280),
    )..addListener(_onSceneTick);

    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7600),
    )..repeat();

    _world = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _cut = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _scene.forward();
    _world.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final name = context.read<ProgressService>().userName.trim();
      if (ProgressService.isPlaceholderUserName(name)) {
        setState(() => _askName = true);
      } else if (_nameController.text.isEmpty) {
        _nameController.text = name.split(' ').first;
      }
    });
  }

  @override
  void dispose() {
    _scene.removeListener(_onSceneTick);
    _scene.dispose();
    _breath.dispose();
    _world.dispose();
    _cut.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onSceneTick() {
    if (_landed || _scene.status != AnimationStatus.forward) return;
    if (_scene.value < 0.48) return;
    _landed = true;
    HapticFeedback.selectionClick();
  }

  Future<void> _goNext() async {
    if (_finishing || _transitioning) return;
    if (_index >= _beats.length - 1) {
      await _finish();
      return;
    }

    _transitioning = true;
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.lightImpact();

    await _cut.animateTo(
      1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInCubic,
    );
    if (!mounted) return;

    final next = _beats[_index + 1];
    _scene.value = 0;
    _landed = false;
    setState(() {
      _fromWorld = _toWorld;
      _toWorld = _worldFor(next);
      _index += 1;
      _transitioning = false;
    });
    _world.forward(from: 0);
    unawaited(
      _cut.animateTo(
        0,
        duration: const Duration(milliseconds: 560),
        curve: Curves.easeOutCubic,
      ),
    );
    unawaited(_scene.forward());
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    HapticFeedback.mediumImpact();
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final progress = context.read<ProgressService>();
      final backend = context.read<BackendService>();
      final league = context.read<LeagueService>();
      if (_askName) {
        final name = _nameController.text.trim();
        if (name.isNotEmpty) await progress.setUserName(name);
      }
      await progress.updateSettings(
        progress.settings.copyWith(
          dailyGoal: 1,
          streakGoal: 7,
          appearanceMode: AppearanceMode.morning,
        ),
      );
      await progress.setHasSeenOnboarding(true);
      await backend.saveNow(progress, LeagueService.weekKey(), league: league);

      if (!mounted) return;
      await _cut.animateTo(
        1,
        duration: const Duration(milliseconds: 460),
        curve: Curves.easeInOutCubic,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainShell(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                ),
                child: child,
              ),
          transitionDuration: const Duration(milliseconds: 780),
        ),
      );
    } catch (e) {
      debugPrint('Onboarding finish failed: $e');
      if (!mounted) return;
      setState(() => _finishing = false);
    }
  }

  String get _ctaLabel => switch (_beat) {
    _Beat.origin => 'Começar',
    _Beat.habit => 'Continuar',
    _Beat.walk => 'Continuar',
    _Beat.rhythm => 'Até amanhã',
    _Beat.threshold => 'Entrar na trilha',
  };

  bool get _showSkip => _beat != _Beat.threshold && !_finishing;

  double get _skipOpacity {
    if (!_showSkip) return 0;
    if (_beat != _Beat.origin) return 1;
    return ((_scene.value - 0.42) / 0.22).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    const mode = AppearanceMode.morning;
    final appearance = AppearanceStyle.resolve(mode);

    return ImmersiveScaffold(
      mode: mode,
      style: appearance,
      background: AnimatedBuilder(
        animation: Listenable.merge([_world, _breath, _scene]),
        builder: (context, _) => _WorldFrame(
          from: _fromWorld,
          to: _toWorld,
          reveal: _world.value,
          breath: _breath.value,
          scene: _scene.value,
          beat: _beat,
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _scene,
            builder: (context, _) {
              final cta = const Interval(
                0.64,
                0.94,
                curve: Curves.easeOutCubic,
              ).transform(_scene.value);

              return SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 10, 8, 0),
                      child: SizedBox(
                        height: 36,
                        child: Row(
                          children: [
                            Expanded(
                              child: _FilmBar(
                                index: _index,
                                total: _beats.length,
                                scene: _scene,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Opacity(
                              opacity: _skipOpacity,
                              child: IgnorePointer(
                                ignoring: _skipOpacity < 0.4 || _transitioning,
                                child: GestureDetector(
                                  onTap: _finishing ? null : _finish,
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Pular',
                                      style: AppTypography.body(
                                        size: 13,
                                        weight: FontWeight.w700,
                                        color: Appearance.of(
                                          context,
                                        ).textMuted(0.42),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: _buildBeat()),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.screen,
                        8,
                        AppSpace.screen,
                        AppSpace.screen,
                      ),
                      child: IgnorePointer(
                        ignoring: _transitioning || _finishing || cta < 0.45,
                        child: Opacity(
                          opacity: _finishing ? 1 : cta,
                          child: Transform.translate(
                            offset: Offset(0, 18 * (1 - cta)),
                            child: CopperCta(
                              label: _finishing ? 'Abrindo…' : _ctaLabel,
                              busy: _finishing,
                              onTap: _finishing ? null : _goNext,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _cut,
            builder: (context, _) {
              final veil = _cut.value;
              if (veil <= 0.001) return const SizedBox.shrink();
              return IgnorePointer(
                ignoring: veil < 0.08,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.88 * veil),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBeat() {
    return switch (_beat) {
      _Beat.origin => _OriginBeat(scene: _scene, breath: _breath),
      _Beat.habit => _HabitBeat(scene: _scene, breath: _breath),
      _Beat.walk => _WalkBeat(scene: _scene),
      _Beat.rhythm => _TomorrowBeat(
        scene: _scene,
        breath: _breath,
        controller: _nameController,
        askName: _askName,
      ),
      _Beat.threshold => _ThresholdBeat(
        scene: _scene,
        breath: _breath,
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : context.read<ProgressService>().userName,
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// Mundo
// ---------------------------------------------------------------------------

class _WorldFrame extends StatelessWidget {
  final CreationWorldState from;
  final CreationWorldState to;
  final double reveal;
  final double breath;
  final double scene;
  final _Beat beat;

  const _WorldFrame({
    required this.from,
    required this.to,
    required this.reveal,
    required this.breath,
    required this.scene,
    required this.beat,
  });

  @override
  Widget build(BuildContext context) {
    final drift = math.sin(breath * math.pi * 2);
    final lift = math.cos(breath * math.pi * 2);
    final sweep = math.sin(reveal * math.pi);
    final mark = _OnboardingScreenState._watermarkFor(beat);
    final light = switch (beat) {
      _Beat.origin => 0.05,
      _Beat.habit => 0.2,
      _Beat.walk => 0.06,
      _Beat.rhythm => 0.04,
      _Beat.threshold => 0.14,
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.scale(
          scale: 1.08,
          child: Transform.translate(
            offset: Offset(10 * drift, 14 * lift),
            child: CinematicBackdrop(
              world: from,
              revealing: to,
              revealProgress: reveal,
            ),
          ),
        ),
        Positioned(
          top: -60,
          right: beat == _Beat.habit ? -20 : -80,
          child: IgnorePointer(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(
                      alpha: light * (0.65 + 0.35 * ((drift + 1) / 2)),
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        if (mark != null)
          Align(
            alignment: beat == _Beat.walk
                ? const Alignment(-0.85, 0.05)
                : const Alignment(0.72, -0.42),
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.07 + 0.1 * scene,
                child: CinematicIcon(
                  glyph: mark,
                  size: 200,
                  framed: false,
                  accent: AppColors.accent,
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: (0.4 * sweep).clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1.35 + 2.7 * reveal, -0.35),
                    end: Alignment(-0.55 + 2.7 * reveal, 0.35),
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x99040910),
                Color(0x22040910),
                Color(0x66040910),
                Color(0xE6040910),
              ],
              stops: [0.0, 0.28, 0.62, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilmBar extends StatelessWidget {
  final int index;
  final int total;
  final Animation<double> scene;

  const _FilmBar({
    required this.index,
    required this.total,
    required this.scene,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scene,
      builder: (context, _) {
        return Row(
          children: List.generate(total, (i) {
            final fill = i < index
                ? 1.0
                : i == index
                ? scene.value
                : 0.0;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 2,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const ColoredBox(color: Color(0x33FFFFFF)),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: fill.clamp(0.0, 1.0),
                          child: const ColoredBox(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Linha que sobe e aparece dentro do intervalo da cartela.
class _Reveal extends StatelessWidget {
  final Animation<double> scene;
  final double from;
  final double to;
  final double rise;
  final double scaleFrom;
  final Widget child;

  const _Reveal({
    required this.scene,
    required this.from,
    required this.to,
    required this.child,
    this.rise = 16,
    this.scaleFrom = 1,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scene,
      builder: (context, child) {
        final span = (to - from).clamp(0.01, 1.0);
        final raw = ((scene.value - from) / span).clamp(0.0, 1.0);
        final t = Curves.easeOutCubic.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, rise * (1 - t)),
            child: Transform.scale(
              scale: scaleFrom + (1 - scaleFrom) * t,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _Kicker extends StatelessWidget {
  final String text;
  final Animation<double> scene;

  const _Kicker({required this.text, required this.scene});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scene,
      builder: (context, _) {
        const from = 0.06;
        const to = 0.34;
        final raw = ((scene.value - from) / (to - from)).clamp(0.0, 1.0);
        final t = Curves.easeOutCubic.transform(raw);
        return Opacity(
          opacity: t,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: AppTypography.label(
                size: 12,
                letterSpacing: 5.6 - 3.4 * t,
                color: AppColors.accent,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BreathingMark extends StatelessWidget {
  final Animation<double> breath;
  final CinematicGlyph glyph;
  final double size;

  const _BreathingMark({
    required this.breath,
    required this.glyph,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: breath,
      builder: (context, child) {
        final t = math.sin(breath.value * math.pi * 2);
        return Transform.scale(scale: 1 + 0.04 * t, child: child);
      },
      child: CinematicIcon(
        glyph: glyph,
        size: size,
        accent: AppColors.accent,
        glowing: true,
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  final Widget child;

  const _Stage({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
          sliver: SliverFillRemaining(hasScrollBody: false, child: child),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Atos
// ---------------------------------------------------------------------------

class _OriginBeat extends StatelessWidget {
  final Animation<double> scene;
  final Animation<double> breath;

  const _OriginBeat({required this.scene, required this.breath});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final short = MediaQuery.sizeOf(context).height < 740;

    return _Stage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Reveal(
            scene: scene,
            from: 0.0,
            to: 0.26,
            rise: 8,
            child: const StwayWordmark(fontSize: 15, letterSpacing: 2.4),
          ),
          SizedBox(height: short ? 22 : 36),
          _Reveal(
            scene: scene,
            from: 0.08,
            to: 0.4,
            rise: 10,
            scaleFrom: 0.92,
            child: _BreathingMark(
              breath: breath,
              glyph: CinematicGlyph.cosmos,
              size: short ? 68 : 86,
            ),
          ),
          SizedBox(height: short ? 18 : 26),
          _Kicker(text: 'I   ·   NO PRINCÍPIO', scene: scene),
          const SizedBox(height: 14),
          _Reveal(
            scene: scene,
            from: 0.26,
            to: 0.52,
            child: Text(
              'Deus falou.',
              textAlign: TextAlign.center,
              style: AppTypography.display(
                size: short ? 36 : 42,
                height: 1.02,
                weight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _Reveal(
            scene: scene,
            from: 0.38,
            to: 0.64,
            child: Text(
              'O mundo começou.',
              textAlign: TextAlign.center,
              style: AppTypography.display(
                size: short ? 36 : 42,
                height: 1.02,
                weight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Reveal(
            scene: scene,
            from: 0.5,
            to: 0.76,
            child: Text(
              'A Bíblia não é um livro para terminar.\nÉ o lugar onde você encontra quem te criou.',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 15,
                height: 1.45,
                weight: FontWeight.w600,
                color: a.text.withValues(alpha: 0.76),
              ),
            ),
          ),
          SizedBox(height: short ? 22 : 32),
          _Reveal(
            scene: scene,
            from: 0.62,
            to: 0.9,
            rise: 22,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 1.5,
                  color: AppColors.accent.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 16),
                Text(
                  'No princípio, Deus criou\nos céus e a terra.',
                  textAlign: TextAlign.center,
                  style: AppTypography.verse(
                    size: short ? 22 : 26,
                    height: 1.25,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'GÊNESIS 1.1',
                  style: AppTypography.label(
                    size: 11,
                    letterSpacing: 2.2,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitBeat extends StatelessWidget {
  final Animation<double> scene;
  final Animation<double> breath;

  const _HabitBeat({required this.scene, required this.breath});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final short = MediaQuery.sizeOf(context).height < 740;
    final number = short ? 96.0 : 120.0;

    return _Stage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Kicker(text: 'II   ·   UM PASSO', scene: scene),
          SizedBox(height: short ? 18 : 28),
          _Reveal(
            scene: scene,
            from: 0.16,
            to: 0.52,
            rise: 10,
            scaleFrom: 0.9,
            child: Column(
              children: [
                SizedBox(
                  height: number * 0.92,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: breath,
                        builder: (context, _) {
                          final glow =
                              0.55 +
                              0.45 * math.sin(breath.value * math.pi * 2);
                          return Container(
                            width: number * 1.7,
                            height: number * 1.7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accent.withValues(
                                    alpha: 0.2 * glow,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Text(
                        '3',
                        style: AppTypography.display(
                          size: number,
                          weight: FontWeight.w900,
                          height: 0.8,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'MINUTOS',
                  style: AppTypography.label(
                    size: 13,
                    letterSpacing: 4,
                    color: a.text.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: short ? 16 : 22),
          _Reveal(
            scene: scene,
            from: 0.38,
            to: 0.66,
            child: Text(
              'Todo dia.',
              textAlign: TextAlign.center,
              style: AppTypography.display(
                size: short ? 32 : 38,
                height: 1.05,
                weight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Reveal(
            scene: scene,
            from: 0.5,
            to: 0.78,
            child: Text(
              'Conhecer a Deus não pede uma maratona.\nPede que você volte. Um passo curto,\nrepetido, até virar caminho.',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 15,
                height: 1.45,
                weight: FontWeight.w600,
                color: a.text.withValues(alpha: 0.76),
              ),
            ),
          ),
          SizedBox(height: short ? 22 : 32),
          _Reveal(
            scene: scene,
            from: 0.64,
            to: 0.9,
            child: const _Whisper(parts: ['presença', 'retorno', 'a Palavra']),
          ),
        ],
      ),
    );
  }
}

class _Whisper extends StatelessWidget {
  final List<String> parts;

  const _Whisper({required this.parts});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(width: 10),
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            parts[i],
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w700,
              color: a.text.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}

class _WalkBeat extends StatelessWidget {
  final Animation<double> scene;

  const _WalkBeat({required this.scene});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final short = MediaQuery.sizeOf(context).height < 740;
    final size = short ? 36.0 : 44.0;

    return _Stage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Kicker(text: 'III   ·   O CAMINHO', scene: scene),
          SizedBox(height: short ? 26 : 40),
          _SpokenLine(
            scene: scene,
            from: 0.16,
            to: 0.4,
            text: 'Leia.',
            size: size,
          ),
          _LineRule(scene: scene, from: 0.3, to: 0.48),
          _SpokenLine(
            scene: scene,
            from: 0.32,
            to: 0.56,
            text: 'Responda.',
            size: size,
          ),
          _LineRule(scene: scene, from: 0.46, to: 0.64),
          _SpokenLine(
            scene: scene,
            from: 0.48,
            to: 0.72,
            text: 'Entenda.',
            size: size,
          ),
          SizedBox(height: short ? 22 : 32),
          _Reveal(
            scene: scene,
            from: 0.6,
            to: 0.86,
            child: Text(
              'Não é trivia. É a Bíblia na mão,\numa pergunta de verdade,\ne o entendimento que fica.',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 15,
                height: 1.45,
                weight: FontWeight.w600,
                color: a.text.withValues(alpha: 0.76),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpokenLine extends StatelessWidget {
  final Animation<double> scene;
  final double from;
  final double to;
  final String text;
  final double size;

  const _SpokenLine({
    required this.scene,
    required this.from,
    required this.to,
    required this.text,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return _Reveal(
      scene: scene,
      from: from,
      to: to,
      rise: 20,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.display(
          size: size,
          height: 1.05,
          weight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LineRule extends StatelessWidget {
  final Animation<double> scene;
  final double from;
  final double to;

  const _LineRule({required this.scene, required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return _Reveal(
      scene: scene,
      from: from,
      to: to,
      rise: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            width: 18,
            height: 1.5,
            color: AppColors.accent.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

class _TomorrowBeat extends StatelessWidget {
  final Animation<double> scene;
  final Animation<double> breath;
  final TextEditingController controller;
  final bool askName;

  const _TomorrowBeat({
    required this.scene,
    required this.breath,
    required this.controller,
    required this.askName,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final short = MediaQuery.sizeOf(context).height < 740;
    final word = short ? 52.0 : 64.0;

    return _Stage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Kicker(text: 'IV   ·   AMANHÃ', scene: scene),
          SizedBox(height: short ? 18 : 28),
          _Reveal(
            scene: scene,
            from: 0.14,
            to: 0.48,
            rise: 10,
            scaleFrom: 0.92,
            child: SizedBox(
              height: word * 1.15,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: breath,
                    builder: (context, _) {
                      final glow =
                          0.55 + 0.45 * math.sin(breath.value * math.pi * 2);
                      return Container(
                        width: word * 3.2,
                        height: word * 1.6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(word),
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accent.withValues(alpha: 0.16 * glow),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Text(
                    'Amanhã',
                    textAlign: TextAlign.center,
                    style: AppTypography.display(
                      size: word,
                      weight: FontWeight.w900,
                      height: 0.9,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _Reveal(
            scene: scene,
            from: 0.36,
            to: 0.64,
            child: Text(
              'Não daqui a uma semana.\nO hábito começa quando você\nvolta no dia seguinte.',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 15,
                height: 1.45,
                weight: FontWeight.w600,
                color: a.text.withValues(alpha: 0.76),
              ),
            ),
          ),
          if (askName) ...[
            const SizedBox(height: 22),
            _Reveal(
              scene: scene,
              from: 0.48,
              to: 0.74,
              child: _NameLine(controller: controller),
            ),
          ],
          SizedBox(height: short ? 22 : 28),
          _Reveal(
            scene: scene,
            from: 0.58,
            to: 0.86,
            child: const _Whisper(parts: ['três minutos', 'de novo']),
          ),
        ],
      ),
    );
  }
}

class _NameLine extends StatelessWidget {
  final TextEditingController controller;

  const _NameLine({required this.controller});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      children: [
        Text(
          'COMO TE CHAMAMOS',
          style: AppTypography.label(
            size: 10,
            letterSpacing: 1.8,
            color: a.textMuted(0.55),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.words,
          style: AppTypography.display(
            size: 22,
            weight: FontWeight.w800,
            color: a.text,
          ),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: 'seu nome',
            hintStyle: AppTypography.display(
              size: 22,
              weight: FontWeight.w700,
              color: a.textMuted(0.28),
            ),
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.accent.withValues(alpha: 0.4),
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThresholdBeat extends StatelessWidget {
  final Animation<double> scene;
  final Animation<double> breath;
  final String name;

  const _ThresholdBeat({
    required this.scene,
    required this.breath,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final short = MediaQuery.sizeOf(context).height < 740;
    final greeting = ProgressService.isPlaceholderUserName(name)
        ? null
        : name.split(' ').first;
    final title = greeting == null
        ? 'O primeiro passo\njá está no caminho.'
        : '$greeting,\no primeiro passo\njá está no caminho.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        4,
        AppSpace.screen,
        4,
      ),
      child: Column(
        children: [
          _Kicker(text: 'V   ·   A CAMINHADA', scene: scene),
          const SizedBox(height: 12),
          _Reveal(
            scene: scene,
            from: 0.14,
            to: 0.46,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.display(
                size: short ? 28 : 32,
                height: 1.08,
                weight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _Reveal(
            scene: scene,
            from: 0.32,
            to: 0.58,
            child: Text(
              'Esta missão abre a trilha.',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w600,
                color: a.text.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _Reveal(
              scene: scene,
              from: 0.4,
              to: 0.78,
              rise: 28,
              scaleFrom: 0.97,
              child: _FirstMissionHero(breath: breath),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstMissionHero extends StatelessWidget {
  final Animation<double> breath;

  const _FirstMissionHero({required this.breath});

  static const _slug = 'genesis-1-11';
  static const _title = 'Quem criou o mundo?';

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final visuals = TrailVisuals.forSlug(_slug);
    final world = CinematicResolver.ambientForHome(
      trailSlug: _slug,
      missionTitle: _title,
    );
    final style = HeroCardMoodStyle.of(
      HeroCardMood.alive,
      trailAccent: visuals.accent,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
        border: Border.all(color: style.border, width: style.borderWidth),
        boxShadow: AppMetrics.cardShadow(elevated: true),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.heroRadius - 0.5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: breath,
              builder: (context, child) {
                final t = math.sin(breath.value * math.pi * 2);
                final drift = math.cos(breath.value * math.pi * 2);
                return Transform.scale(
                  scale: 1.12 + 0.04 * t,
                  child: Transform.translate(
                    offset: Offset(8 * t, 10 * drift),
                    child: child,
                  ),
                );
              },
              child: HeroCardColorGrade(
                mood: HeroCardMood.alive,
                child: CinematicBackdrop(world: world),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.22),
                    Color.lerp(
                      a.cardFill,
                      Colors.black,
                      0.28,
                    )!.withValues(alpha: 0.88),
                  ],
                  stops: const [0.0, 0.38, 1.0],
                ),
              ),
            ),
            const HeroCardAtmosphere(mood: HeroCardMood.alive),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _HeroChip(
                        glyph: visuals.glyph,
                        accent: visuals.accent,
                        label: 'GÊNESIS 1–11',
                      ),
                      const SizedBox(width: 8),
                      const _HeroChip(
                        glyph: CinematicGlyph.lamp,
                        accent: AppColors.accent,
                        label: '5 LÂMPADAS',
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'MISSÃO PRONTA',
                    style: AppTypography.label(
                      size: 12,
                      letterSpacing: 2,
                      color: style.label,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _title,
                    style: AppTypography.display(
                      size: 32,
                      height: 1.08,
                      weight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Do começo — no princípio de tudo',
                    style: AppTypography.body(
                      size: 14,
                      weight: FontWeight.w600,
                      color: a.text.withValues(alpha: 0.74),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color accent;
  final String label;

  const _HeroChip({
    required this.glyph,
    required this.accent,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: a.cardFillSoft,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: a.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CinematicIcon(glyph: glyph, size: 14, accent: accent, framed: false),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.label(
              size: 9,
              letterSpacing: 1,
              color: a.text.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}
