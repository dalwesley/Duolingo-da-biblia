import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cinematic/cinematic_resolver.dart';
import '../l10n/app_language.dart';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/tilt_parallax.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/trail_visuals.dart';
import '../widgets/act_feel.dart';
import '../widgets/cinematic_backdrop.dart';
import '../widgets/brand_trail.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/film_layers.dart';
import '../widgets/genesis_hero.dart';
import '../widgets/hero_card_atmosphere.dart';
import '../widgets/immersive_background.dart';
import '../widgets/ui_primitives.dart';
import 'main_shell.dart';

/// Onboarding STWAY — cinco atos, do vazio à primeira missão.
///
/// Retenção: a pessoa escolhe o ritmo, diz o que busca, escolhe o céu e
/// *firma* um compromisso (segurar o botão). O final devolve tudo isso
/// personalizado — "dia 1 de N" já aceso. Tudo é salvo no fim (ou no
/// "Pular"); o pedido de permissão de lembrete fica para depois da 1ª
/// missão, na Home, já com o horário escolhido aqui.
///
/// O primeiro ato é um plano de abertura: trevas, a Palavra, a luz.
/// Depois, o fundo da Criação muda de ato. O texto entra como cartela.
/// O quarto ato marca o retorno de amanhã. O nome, se faltar, entra ali.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Beat { origin, habit, intent, sky, rhythm, threshold }

/// O que a pessoa busca — molda o título do último ato.
enum _Intent {
  know(CinematicGlyph.heart),
  habit(CinematicGlyph.flame),
  understand(CinematicGlyph.book),
  peace(CinematicGlyph.dove);

  final CinematicGlyph glyph;

  const _Intent(this.glyph);

  String title(AppLocalizations l10n) => switch (this) {
    _Intent.know => l10n.onboardingIntentKnowTitle,
    _Intent.habit => l10n.onboardingIntentHabitTitle,
    _Intent.understand => l10n.onboardingIntentUnderstandTitle,
    _Intent.peace => l10n.onboardingIntentPeaceTitle,
  };

  String caption(AppLocalizations l10n) => switch (this) {
    _Intent.know => l10n.onboardingIntentKnowCaption,
    _Intent.habit => l10n.onboardingIntentHabitCaption,
    _Intent.understand => l10n.onboardingIntentUnderstandCaption,
    _Intent.peace => l10n.onboardingIntentPeaceCaption,
  };

  String promise(AppLocalizations l10n) => switch (this) {
    _Intent.know => l10n.onboardingIntentKnowPromise,
    _Intent.habit => l10n.onboardingIntentHabitPromise,
    _Intent.understand => l10n.onboardingIntentUnderstandPromise,
    _Intent.peace => l10n.onboardingIntentPeacePromise,
  };
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  static const _beats = _Beat.values;

  final _nameController = TextEditingController();
  final _tilt = TiltParallax()..start();
  late final AnimationController _scene;
  late final AnimationController _breath;
  late final AnimationController _world;
  late final AnimationController _cut;

  int _index = 0;
  bool _askName = false;
  bool _finishing = false;
  bool _transitioning = false;
  bool _landed = false;

  // Escolhas do onboarding (salvas em _finish).
  int _dailyGoal = 1;
  _Intent? _intent;
  AppearanceMode _sky = AppearanceMode.automatic;
  int _streakGoal = 7;
  int _reminderHour = 7;
  final _startedAt = DateTime.now();

  /// Mesmos horários da folha de lembrete da Home.
  static const reminderHours = [7, 12, 20];
  static const streakGoals = [7, 14, 30];

  TrailShot _fromWorld = GenesisHero.endShot;
  TrailShot _toWorld = _worldFor(_Beat.origin);

  _Beat get _beat => _beats[_index];

  static Duration _durationFor(_Beat beat) => beat == _Beat.origin
      ? const Duration(milliseconds: 6500)
      : const Duration(milliseconds: 1280);

  // A trilha STWAY (a arte do ícone) fica parada no mesmo lugar;
  // mudam só a luz e o céu: aurora, caminho com lâmpadas, noite,
  // caminho inteiro aceso.
  static TrailShot _worldFor(_Beat beat) => switch (beat) {
    _Beat.origin => GenesisHero.endShot,
    _Beat.habit => TrailShot.rest.copyWith(
      exposure: 0.95,
      glow: 1,
      lit: 0.3,
      stars: 0.85,
    ),
    _Beat.intent => TrailShot.rest.copyWith(
      exposure: 1,
      glow: 0.7,
      lit: 0.72,
      lamps: 1,
      stars: 0.75,
    ),
    _Beat.sky => TrailShot.rest.copyWith(
      exposure: 1,
      glow: 1,
      lit: 0.55,
      lamps: 1,
      stars: 0.85,
    ),
    _Beat.rhythm => TrailShot.rest.copyWith(
      exposure: 0.5,
      glow: 0.3,
      lit: 0.72,
      lamps: 1,
      stars: 1,
      night: 1,
    ),
    _Beat.threshold => TrailShot.rest.copyWith(
      exposure: 1,
      glow: 1,
      lit: 1,
      lamps: 1,
      stars: 0.75,
    ),
  };

  /// Enquadramento do ato já com o céu escolhido (a partir do ato do céu).
  /// "Amanhã" é sempre noite: é a promessa do dia seguinte.
  TrailShot _shotFor(_Beat beat) {
    final base = _worldFor(beat);
    if (beat.index < _Beat.sky.index || beat == _Beat.rhythm) return base;
    // Só o céu (acima dos morros) muda; a arte STWAY fica igual.
    return base.withSky(AppearanceStyle.resolve(_sky));
  }

  AppearanceMode get _chromeMode =>
      _index >= _Beat.sky.index ? _sky : AppearanceMode.morning;

  void _pickSky(AppearanceMode mode) {
    if (mode == _sky) return;
    ActHaptics.tap();
    final shown = Curves.easeInOutCubic.transform(_world.value);
    setState(() {
      _fromWorld = TrailShot.lerp(_fromWorld, _toWorld, shown);
      _sky = mode;
      _toWorld = _shotFor(_beat);
    });
    _world.forward(from: 0);
    _logChoice('sky', mode.name);
  }

  void _pickGoal(int goal) {
    if (goal == _dailyGoal) return;
    ActHaptics.tap();
    setState(() => _dailyGoal = goal);
    _logChoice('daily_goal', goal);
  }

  void _pickIntent(_Intent intent) {
    if (intent == _intent) return;
    ActHaptics.tap();
    setState(() => _intent = intent);
    _logChoice('intent', intent.name);
  }

  void _pickStreak(int goal) {
    if (goal == _streakGoal) return;
    ActHaptics.tap();
    setState(() => _streakGoal = goal);
    _logChoice('streak_goal', goal);
  }

  void _pickHour(int hour) {
    if (hour == _reminderHour) return;
    ActHaptics.tap();
    setState(() => _reminderHour = hour);
    _logChoice('reminder_hour', hour);
  }

  // Funil do onboarding: onde a pessoa para, o que escolhe, se conclui.
  void _logStep() => unawaited(
    AnalyticsService.instance.logEvent('onboarding_step', {
      'step': _index + 1,
      'name': _beat.name,
    }),
  );

  void _logChoice(String field, Object value) => unawaited(
    AnalyticsService.instance.logEvent('onboarding_choice', {
      'field': field,
      'value': '$value',
      'step': _beat.name,
    }),
  );

  @override
  void initState() {
    super.initState();

    _scene = AnimationController(
      vsync: this,
      duration: _durationFor(_Beat.origin),
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

    // Já está no cache da splash; o fundo repinta a cada quadro.
    BrandTrail.ensureLoaded().then((_) {}, onError: (_) {});
    _scene.forward();
    _world.forward();
    _logStep();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final settings = context.read<ProgressService>().settings;
      setState(() {
        _dailyGoal = settings.dailyGoal.clamp(1, 3);
        _sky = settings.appearanceMode;
        if (reminderHours.contains(settings.reminderHour)) {
          _reminderHour = settings.reminderHour;
        }
        if (streakGoals.contains(settings.streakGoal)) {
          _streakGoal = settings.streakGoal;
        }
      });
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
    _tilt.dispose();
    super.dispose();
  }

  void _onSceneTick() {
    if (_landed || _scene.status != AnimationStatus.forward) return;
    if (_beat == _Beat.origin) {
      if (_scene.value < GenesisHero.flashAt) return;
      _landed = true;
      ActHaptics.success();
      return;
    }
    if (_scene.value < 0.48) return;
    _landed = true;
    ActHaptics.tap();
  }

  Future<void> _goNext() async {
    if (_finishing || _transitioning) return;
    if (_index >= _beats.length - 1) {
      await _finish();
      return;
    }

    _transitioning = true;
    FocusManager.instance.primaryFocus?.unfocus();
    ActHaptics.light();

    await _cut.animateTo(
      1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInCubic,
    );
    if (!mounted) return;

    final next = _beats[_index + 1];
    _scene.value = 0;
    _scene.duration = _durationFor(next);
    _landed = false;
    setState(() {
      _fromWorld = _toWorld;
      _index += 1;
      _toWorld = _shotFor(next);
      _transitioning = false;
    });
    _logStep();
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

  Future<void> _finish({bool skipped = false}) async {
    if (_finishing) return;
    setState(() => _finishing = true);
    unawaited(
      AnalyticsService.instance.logEvent('onboarding_complete', {
        'skipped': skipped ? 1 : 0,
        'at_step': _beat.name,
        'daily_goal': _dailyGoal,
        'streak_goal': _streakGoal,
        'sky': _sky.name,
        'reminder_hour': _reminderHour,
        'intent': _intent?.name ?? 'none',
        'seconds': DateTime.now().difference(_startedAt).inSeconds,
      }),
    );
    ActHaptics.confirm();
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
          dailyGoal: _dailyGoal,
          streakGoal: _streakGoal,
          appearanceMode: _sky,
          reminderHour: _reminderHour,
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

  String _ctaLabel(AppLocalizations l10n) => switch (_beat) {
    _Beat.origin || _Beat.threshold => l10n.commonStart,
    _Beat.rhythm => l10n.onboardingHoldToCommit,
    _Beat.habit || _Beat.intent || _Beat.sky => l10n.commonContinue,
  };

  bool get _showSkip => _beat != _Beat.threshold && !_finishing;

  double get _skipOpacity {
    if (!_showSkip) return 0;
    if (_beat != _Beat.origin) return 1;
    return ((_scene.value - 0.42) / 0.22).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final mode = _chromeMode;
    final appearance = AppearanceStyle.resolve(mode);
    final l10n = context.l10n;

    return ImmersiveScaffold(
      mode: mode,
      style: appearance,
      background: AnimatedBuilder(
        animation: Listenable.merge([_world, _breath, _scene, _tilt]),
        builder: (context, _) => _WorldFrame(
          from: _fromWorld,
          to: _toWorld,
          reveal: _world.value,
          breath: _breath.value,
          scene: _scene.value,
          beat: _beat,
          tilt: _tilt.value,
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _scene,
            builder: (context, _) {
              // Na abertura, o botão só vem depois que a luz se abre.
              final cta =
                  (_beat == _Beat.origin
                          ? const Interval(
                              0.8,
                              0.96,
                              curve: Curves.easeOutCubic,
                            )
                          : const Interval(
                              0.64,
                              0.94,
                              curve: Curves.easeOutCubic,
                            ))
                      .transform(_scene.value);
              final ctaLabel = _ctaLabel(l10n);

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
                                  onTap: _finishing
                                      ? null
                                      : () => _finish(skipped: true),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      l10n.commonSkip,
                                      style: AppTypography.body(
                                        size: 13,
                                        weight: FontWeight.w700,
                                        color: Appearance.of(context).textFaint,
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
                            child: _beat == _Beat.rhythm && !_finishing
                                ? _HoldCta(
                                    label: ctaLabel,
                                    holdingLabel: l10n.onboardingHolding,
                                    onDone: _goNext,
                                  )
                                : _SiteCta(
                                    label: _finishing
                                        ? l10n.onboardingOpening
                                        : ctaLabel,
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
      _Beat.origin => _OriginBeat(scene: _scene),
      _Beat.habit => _HabitBeat(
        scene: _scene,
        breath: _breath,
        goal: _dailyGoal,
        onGoal: _pickGoal,
      ),
      _Beat.intent => _IntentBeat(
        scene: _scene,
        intent: _intent,
        onIntent: _pickIntent,
      ),
      _Beat.sky => _SkyBeat(scene: _scene, sky: _sky, onSky: _pickSky),
      _Beat.rhythm => _TomorrowBeat(
        scene: _scene,
        breath: _breath,
        controller: _nameController,
        askName: _askName,
        hour: _reminderHour,
        hours: reminderHours,
        onHour: _pickHour,
        streak: _streakGoal,
        streaks: streakGoals,
        onStreak: _pickStreak,
      ),
      _Beat.threshold => _ThresholdBeat(
        scene: _scene,
        breath: _breath,
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : context.read<ProgressService>().userName,
        intent: _intent,
        streakGoal: _streakGoal,
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// Mundo
// ---------------------------------------------------------------------------

class _WorldFrame extends StatelessWidget {
  final TrailShot from;
  final TrailShot to;
  final double reveal;
  final double breath;
  final double scene;
  final _Beat beat;
  final Offset tilt;

  const _WorldFrame({
    required this.from,
    required this.to,
    required this.reveal,
    required this.breath,
    required this.scene,
    required this.beat,
    required this.tilt,
  });

  @override
  Widget build(BuildContext context) {
    if (beat == _Beat.origin) {
      return GenesisHero(progress: scene, time: breath, tilt: tilt);
    }
    final sweep = math.sin(reveal * math.pi);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Arte parada; só a luz e o céu se movem.
        TrailScene(
          from: from,
          to: to,
          reveal: reveal,
          time: breath,
          tilt: tilt,
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
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryDark.withValues(alpha: 0.6),
                AppColors.primaryDark.withValues(alpha: 0.2),
                AppColors.primaryDark.withValues(alpha: 0.2),
                AppColors.primaryDark.withValues(alpha: 0.8),
              ],
              stops: const [0.0, 0.3, 0.66, 1.0],
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
                  borderRadius: BorderRadius.circular(AppRadii.hair),
                  child: SizedBox(
                    height: 2,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: Colors.white.withValues(alpha: 0.2)),
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
            child: SectionLabel(text, color: AppColors.accent),
          ),
        );
      },
    );
  }
}

/// Palco dos atos: a cartela fica no céu, acima da trilha.
class _Stage extends StatelessWidget {
  final Widget child;

  /// false = centraliza (prólogo em tela escura).
  final bool lift;

  const _Stage({required this.child, this.lift = true});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const Spacer(),
                child,
                Spacer(flex: lift ? 4 : 1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Atos
// ---------------------------------------------------------------------------

/// Prólogo, como no site: só a animação e Gênesis 1:1–3.
///
/// A primeira linha entra palavra por palavra saindo da névoa; "Haja luz"
/// chega junto do clarão ([GenesisHero.flashAt]) e "e houve luz" acende.
class _OriginBeat extends StatelessWidget {
  final Animation<double> scene;

  const _OriginBeat({required this.scene});

  static const _first = 'No princípio, criou Deus o céu e a terra.';
  static const _goldSoft = Color(0xFFFFE7A0);

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final short = MediaQuery.sizeOf(context).height < 740;
    final size = short ? 23.0 : 25.0;
    final style = AppTypography.verse(
      size: size,
      height: 1.5,
      weight: FontWeight.w500,
      fontStyle: FontStyle.italic,
      color: a.text,
    );
    final words = _first.split(' ');
    final gap = size * 0.26;

    // Na luz, o versículo sobe e se dissolve (como o prólogo do site).
    return _Stage(
      lift: false,
      child: AnimatedBuilder(
        animation: scene,
        builder: (context, child) {
          final out = Curves.easeInCubic.transform(
            ((scene.value - GenesisHero.flashAt) / 0.1).clamp(0.0, 1.0),
          );
          if (out >= 1) return const SizedBox.shrink();
          Widget verse = Transform.translate(
            offset: Offset(0, -48 * out),
            child: Transform.scale(scale: 1 - 0.02 * out, child: child),
          );
          if (out > 0.01) {
            verse = ImageFiltered(
              imageFilter: ui.ImageFilter.blur(
                sigmaX: 10 * out,
                sigmaY: 10 * out,
              ),
              child: verse,
            );
          }
          return Opacity(opacity: 1 - out, child: verse);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: gap,
              children: [
                for (var i = 0; i < words.length; i++)
                  _Mist(
                    scene: scene,
                    from: 0.04 + i * 0.03,
                    to: 0.16 + i * 0.03,
                    child: Text(words[i], style: style),
                  ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: gap,
              children: [
                _Mist(
                  scene: scene,
                  from: 0.36,
                  to: 0.46,
                  child: Text('Disse Deus: Haja luz;', style: style),
                ),
                _Mist(
                  scene: scene,
                  from: 0.47,
                  to: GenesisHero.flashAt,
                  child: AnimatedBuilder(
                    animation: scene,
                    builder: (context, _) {
                      final k = const Interval(
                        GenesisHero.flashAt - 0.03,
                        GenesisHero.flashAt + 0.02,
                        curve: Curves.easeInOut,
                      ).transform(scene.value);
                      return Text(
                        'e houve luz.',
                        style: style.copyWith(
                          color: Color.lerp(_goldSoft, Colors.white, k),
                          shadows: [
                            Shadow(
                              color: _goldSoft.withValues(alpha: 0.9 * k),
                              blurRadius: 30 * k,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _Mist(
              scene: scene,
              from: 0.14,
              to: 0.34,
              blur: 0,
              rise: 0,
              child: SectionLabel('Gênesis 1:1–3', color: a.textFaint),
            ),
          ],
        ),
      ),
    );
  }
}

/// Entra saindo da névoa: opacidade, desfoque e leve subida.
class _Mist extends StatelessWidget {
  final Animation<double> scene;
  final double from;
  final double to;
  final double blur;
  final double rise;
  final Widget child;

  const _Mist({
    required this.scene,
    required this.from,
    required this.to,
    required this.child,
    this.blur = 8,
    this.rise = 10,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scene,
      builder: (context, child) {
        final raw = ((scene.value - from) / (to - from)).clamp(0.0, 1.0);
        final t = Curves.easeOut.transform(raw);
        final sigma = blur * (1 - t);
        Widget out = Transform.translate(
          offset: Offset(0, rise * (1 - t)),
          child: child,
        );
        if (sigma > 0.05) {
          out = ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: out,
          );
        }
        return Opacity(opacity: t, child: out);
      },
      child: child,
    );
  }
}

class _HabitBeat extends StatelessWidget {
  final Animation<double> scene;
  final Animation<double> breath;
  final int goal;
  final ValueChanged<int> onGoal;

  const _HabitBeat({
    required this.scene,
    required this.breath,
    required this.goal,
    required this.onGoal,
  });

  static List<_Choice<int>> _paces(AppLocalizations l10n) => [
    _Choice(
      1,
      l10n.settingsPaceLight,
      l10n.onboardingPaceCaption(1, 3),
    ),
    _Choice(
      2,
      l10n.settingsPaceSteady,
      l10n.onboardingPaceCaption(2, 6),
    ),
    _Choice(
      3,
      l10n.settingsPaceIntense,
      l10n.onboardingPaceCaption(3, 9),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final short = MediaQuery.sizeOf(context).height < 740;
    final number = short ? 84.0 : 104.0;

    return _Stage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Kicker(text: l10n.onboardingKickerGoal, scene: scene),
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
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween(begin: 0.8, end: 1.0).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          '${goal * 3}',
                          key: ValueKey(goal),
                          style: AppTypography.display(
                            size: number,
                            weight: FontWeight.w900,
                            height: 0.8,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                SectionLabel(
                  l10n.onboardingMinutes,
                  color: a.textSecondary,
                  size: 13,
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
              l10n.onboardingEveryDay,
              textAlign: TextAlign.center,
              style: AppTypography.display(
                size: short ? 32 : 40,
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
              l10n.onboardingHabitBody,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                height: 1.45,
                weight: FontWeight.w600,
                color: a.textSecondary,
              ),
            ),
          ),
          SizedBox(height: short ? 22 : 32),
          _Reveal(
            scene: scene,
            from: 0.64,
            to: 0.9,
            child: _ChoiceRow<int>(
              label: l10n.onboardingYourPace,
              options: _paces(l10n),
              selected: goal,
              onChanged: onGoal,
            ),
          ),
        ],
      ),
    );
  }
}

class _TomorrowBeat extends StatelessWidget {
  final Animation<double> scene;
  final Animation<double> breath;
  final TextEditingController controller;
  final bool askName;
  final int hour;
  final List<int> hours;
  final ValueChanged<int> onHour;
  final int streak;
  final List<int> streaks;
  final ValueChanged<int> onStreak;

  const _TomorrowBeat({
    required this.scene,
    required this.breath,
    required this.controller,
    required this.askName,
    required this.hour,
    required this.hours,
    required this.onHour,
    required this.streak,
    required this.streaks,
    required this.onStreak,
  });

  static String _moment(AppLocalizations l10n, int h) => switch (h) {
    < 11 => l10n.onboardingReminderMorning,
    < 17 => l10n.onboardingReminderNoon,
    _ => l10n.onboardingReminderNight,
  };

  static String _span(AppLocalizations l10n, int days) => switch (days) {
    7 => l10n.onboardingStreakWeek,
    14 => l10n.onboardingStreakTwoWeeks,
    30 => l10n.onboardingStreakMonth,
    _ => l10n.onboardingStreakDays(days),
  };

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final short = MediaQuery.sizeOf(context).height < 740;
    final word = short ? 44.0 : 54.0;

    return _Stage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Kicker(text: l10n.onboardingKickerTomorrow, scene: scene),
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
                    l10n.onboardingTomorrowWord,
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
              l10n.onboardingTomorrowBody,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                height: 1.45,
                weight: FontWeight.w600,
                color: a.textSecondary,
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
            child: Column(
              children: [
                _ChoiceRow<int>(
                  label: l10n.onboardingCommitmentLabel,
                  options: [
                    for (final d in streaks)
                      _Choice(d, l10n.settingsDays(d), _span(l10n, d)),
                  ],
                  selected: streak,
                  onChanged: onStreak,
                ),
                SizedBox(height: short ? 14 : 18),
                _ChoiceRow<int>(
                  label: l10n.onboardingRemindAtLabel,
                  options: [
                    for (final h in hours)
                      _Choice(h, l10n.reminderHour(h), _moment(l10n, h)),
                  ],
                  selected: hour,
                  onChanged: onHour,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Choice<T> {
  final T value;
  final String title;
  final String caption;

  const _Choice(this.value, this.title, this.caption);
}

/// Linha de escolhas: mesmos cantos do botão principal; borda fina, a
/// marcada ganha borda ouro e fundo ouro 10%. O detalhe vem embaixo.
class _ChoiceRow<T> extends StatelessWidget {
  final String label;
  final List<_Choice<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const _ChoiceRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final current = options.where((o) => o.value == selected).firstOrNull;
    return Column(
      children: [
        SectionLabel(label, color: a.textFaint),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _ChoicePill(
                  choice: options[i],
                  on: options[i].value == selected,
                  onTap: () => onChanged(options[i].value),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            current?.caption ?? '',
            key: ValueKey(current?.value),
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w600,
              color: a.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChoicePill<T> extends StatelessWidget {
  final _Choice<T> choice;
  final bool on;
  final VoidCallback onTap;

  const _ChoicePill({
    required this.choice,
    required this.on,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Semantics(
      button: true,
      selected: on,
      label: '${choice.title}, ${choice.caption}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: on
                ? AppColors.accent.withValues(alpha: 0.1)
                : AppColors.night.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(_SiteCta.radius),
            border: Border.all(color: on ? AppColors.accent : a.cardBorder),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              choice.title,
              maxLines: 1,
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w700,
                color: on ? AppColors.accent : a.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Escolha do céu do app: o fundo da trilha muda ao vivo.
class _SkyBeat extends StatelessWidget {
  final Animation<double> scene;
  final AppearanceMode sky;
  final ValueChanged<AppearanceMode> onSky;

  const _SkyBeat({required this.scene, required this.sky, required this.onSky});

  static String _title(AppLocalizations l10n, AppearanceMode mode) =>
      switch (mode) {
        AppearanceMode.morning => l10n.settingsThemeLight,
        AppearanceMode.afternoon => l10n.settingsThemeMedium,
        AppearanceMode.night => l10n.settingsThemeDark,
        AppearanceMode.automatic => l10n.settingsThemeAuto,
      };

  static String _caption(AppLocalizations l10n, AppearanceMode mode) =>
      switch (mode) {
        AppearanceMode.morning => l10n.settingsThemeCaptionLight,
        AppearanceMode.afternoon => l10n.settingsThemeCaptionMedium,
        AppearanceMode.night => l10n.settingsThemeCaptionDark,
        AppearanceMode.automatic => l10n.settingsThemeCaptionAuto,
      };

  static DayPhase _phase(AppearanceMode mode) =>
      AppearanceStyle.resolve(mode).phase;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final short = MediaQuery.sizeOf(context).height < 740;

    return _Stage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Kicker(text: l10n.onboardingKickerAppearance, scene: scene),
          SizedBox(height: short ? 16 : 24),
          _Reveal(
            scene: scene,
            from: 0.14,
            to: 0.44,
            child: Text(
              l10n.onboardingAppearanceTitle,
              textAlign: TextAlign.center,
              style: AppTypography.display(
                size: short ? 32 : 40,
                height: 1.05,
                weight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Reveal(
            scene: scene,
            from: 0.3,
            to: 0.58,
            child: Text(
              l10n.onboardingAppearanceBody,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                height: 1.45,
                weight: FontWeight.w600,
                color: a.textSecondary,
              ),
            ),
          ),
          SizedBox(height: short ? 20 : 28),
          _Reveal(
            scene: scene,
            from: 0.46,
            to: 0.8,
            rise: 22,
            child: _OptionList(
              children: [
                for (final mode in AppearanceMode.values)
                  _OptionCard(
                    glyph: mode.glyph,
                    title: _title(l10n, mode),
                    caption: _caption(l10n, mode),
                    semantics: l10n.onboardingAppearanceSemantics(
                      _title(l10n, mode),
                    ),
                    // Amostra do céu que o app vai usar.
                    gradient: DayPhaseHelper.backgroundGradient(_phase(mode)),
                    on: mode == sky,
                    onTap: () => onSky(mode),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Opções uma debaixo da outra — texto inteiro, sem corte.
class _OptionList extends StatelessWidget {
  final List<Widget> children;

  const _OptionList({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          children[i],
        ],
      ],
    );
  }
}

/// "O que te traz aqui?" — a resposta volta no último ato.
class _IntentBeat extends StatelessWidget {
  final Animation<double> scene;
  final _Intent? intent;
  final ValueChanged<_Intent> onIntent;

  const _IntentBeat({
    required this.scene,
    required this.intent,
    required this.onIntent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final short = MediaQuery.sizeOf(context).height < 740;

    return _Stage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Kicker(text: l10n.onboardingKickerIntent, scene: scene),
          SizedBox(height: short ? 16 : 24),
          _Reveal(
            scene: scene,
            from: 0.14,
            to: 0.44,
            child: Text(
              l10n.onboardingIntentQuestion,
              textAlign: TextAlign.center,
              style: AppTypography.display(
                size: short ? 28 : 32,
                height: 1.05,
                weight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Reveal(
            scene: scene,
            from: 0.3,
            to: 0.58,
            child: Text(
              l10n.onboardingIntentBody,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                height: 1.45,
                weight: FontWeight.w600,
                color: a.textSecondary,
              ),
            ),
          ),
          SizedBox(height: short ? 20 : 28),
          _Reveal(
            scene: scene,
            from: 0.46,
            to: 0.8,
            rise: 22,
            child: _OptionList(
              children: [
                for (final i in _Intent.values)
                  _OptionCard(
                    glyph: i.glyph,
                    title: i.title(l10n),
                    caption: i.caption(l10n),
                    semantics: i.title(l10n),
                    on: i == intent,
                    onTap: () => onIntent(i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão de compromisso: segurar para firmar.
///
/// Segurar é um gesto deliberado — a pessoa sente que assumiu algo, e
/// compromisso assumido é o que faz voltar amanhã. Leitor de tela: toque
/// simples firma direto. Mesmo formato do botão ouro do site.
class _HoldCta extends StatefulWidget {
  final String label;
  final String holdingLabel;
  final VoidCallback onDone;

  const _HoldCta({
    required this.label,
    required this.holdingLabel,
    required this.onDone,
  });

  @override
  State<_HoldCta> createState() => _HoldCtaState();
}

class _HoldCtaState extends State<_HoldCta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..addListener(_onTick);
  int _tick = 0;
  bool _done = false;

  void _onTick() {
    // Vibração que cresce enquanto segura.
    final step = (_hold.value * 4).floor();
    if (_hold.status == AnimationStatus.forward && step > _tick) {
      _tick = step;
      ActHaptics.tap();
    }
    if (_hold.value >= 1 && !_done) {
      _done = true;
      ActHaptics.success();
      widget.onDone();
    }
  }

  void _start() {
    if (_done) return;
    ActHaptics.light();
    _hold.forward();
  }

  void _cancel() {
    if (_done) return;
    _tick = 0;
    _hold.animateBack(
      0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(_SiteCta.radius);
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      onTap: () {
        if (_done) return;
        _done = true;
        widget.onDone();
      },
      child: GestureDetector(
        onTapDown: (_) => _start(),
        onTapUp: (_) => _cancel(),
        onTapCancel: _cancel,
        child: AnimatedBuilder(
          animation: _hold,
          builder: (context, _) {
            final t = _hold.value;
            final ink = t > 0.5 ? AppColors.inkOnAccent : AppColors.accent;
            return Transform.scale(
              scale: 1 - 0.02 * t,
              child: Container(
                height: CopperCta.height,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: radius,
                  border: Border.all(color: AppColors.accent, width: 1.4),
                  boxShadow: AppMetrics.accentGlow(alpha: 0.12 + 0.3 * t),
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Ouro enchendo da esquerda para a direita.
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: t,
                        child: const ColoredBox(color: AppColors.accent),
                      ),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CinematicIcon(
                              glyph: CinematicGlyph.lamp,
                              size: 18,
                              accent: ink,
                              framed: false,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  t > 0 ? widget.holdingLabel : widget.label,
                                  maxLines: 1,
                                  style: CopperCta.labelStyle(color: ink),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Botão ouro do site (`.btn-gold.btn-sheen`): 52px, cantos 14, texto
/// normal (sem caixa alta), brilho dourado embaixo e um reflexo que passa
/// de tempos em tempos. Aperta um pouco no toque.
class _SiteCta extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool busy;

  static const height = CopperCta.height;
  static const radius = AppRadii.md;

  const _SiteCta({required this.label, this.onTap, this.busy = false});

  @override
  State<_SiteCta> createState() => _SiteCtaState();
}

class _SiteCtaState extends State<_SiteCta>
    with SingleTickerProviderStateMixin {
  // Mesmo ritmo do site: parado, depois o reflexo cruza (5s).
  late final AnimationController _sheen = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );
  bool _down = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _sheen.stop();
    } else if (!_sheen.isAnimating) {
      _sheen.repeat();
    }
  }

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(_SiteCta.radius);
    final enabled = widget.onTap != null && !widget.busy;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      onTap: enabled ? widget.onTap : null,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTap: enabled ? widget.onTap : null,
        child: AnimatedScale(
          scale: _down ? 0.98 : 1,
          duration: const Duration(milliseconds: 160),
          child: Container(
            height: _SiteCta.height,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: radius,
              boxShadow: AppMetrics.accentGlow(),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Luz de cima (inset do site).
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: 1,
                      width: double.infinity,
                      child: ColoredBox(
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _sheen,
                    builder: (context, _) {
                      final p = FilmLayers.seg(_sheen.value, 0.6, 1);
                      if (p <= 0 || p >= 1) return const SizedBox.shrink();
                      final x = -1.3 + 2.6 * p;
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(x - 0.6, -0.4),
                            end: Alignment(x + 0.6, 0.4),
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: 0.6),
                              Colors.white.withValues(alpha: 0),
                            ],
                            stops: const [0.3, 0.5, 0.68],
                          ),
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.busy) ...[
                          const AppSpinner(
                            inline: true,
                            color: AppColors.inkOnAccent,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              style: CopperCta.labelStyle(),
                            ),
                          ),
                        ),
                        if (!widget.busy) ...[
                          const SizedBox(width: 8),
                          const CinematicIcon(
                            glyph: CinematicGlyph.forward,
                            size: 16,
                            accent: AppColors.inkOnAccent,
                            framed: false,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Dia 1 de N": o primeiro passo já aceso, os outros esperando.
class _StreakPath extends StatelessWidget {
  final int goal;
  final Animation<double> breath;

  const _StreakPath({required this.goal, required this.breath});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    const dots = 7;
    return Column(
      children: [
        SizedBox(
          height: 22,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < dots; i++) ...[
                if (i > 0)
                  Container(width: 14, height: 1.5, color: a.textFaint),
                if (i == 0)
                  AnimatedBuilder(
                    animation: breath,
                    builder: (context, _) {
                      final glow =
                          0.6 + 0.4 * math.sin(breath.value * math.pi * 2);
                      return Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(
                                alpha: 0.6 * glow,
                              ),
                              blurRadius: 14 * glow,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                else
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: a.textFaint, width: 1.4),
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        SectionLabel(
          context.l10n.onboardingDayOneOf(goal),
          color: AppColors.accent,
        ),
      ],
    );
  }
}

/// Opção em linha (céu, motivo), no estilo das escolhas do site:
/// borda fina; marcada = borda ouro, fundo ouro 10% e marcador aceso.
/// Com [gradient], mostra a amostra do céu num círculo.
class _OptionCard extends StatelessWidget {
  final CinematicGlyph glyph;
  final String title;
  final String caption;
  final String semantics;
  final Gradient? gradient;
  final bool on;
  final VoidCallback onTap;

  const _OptionCard({
    required this.glyph,
    required this.title,
    required this.caption,
    required this.semantics,
    required this.on,
    required this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final short = MediaQuery.sizeOf(context).height < 740;
    return Semantics(
      button: true,
      selected: on,
      label: '$semantics, $caption',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: short ? 52 : 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: on
                ? AppColors.accent.withValues(alpha: 0.1)
                : AppColors.night.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(_SiteCta.radius),
            border: Border.all(color: on ? AppColors.accent : a.cardBorder),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: gradient == null
                    ? Center(
                        child: CinematicIcon(
                          glyph: glyph,
                          size: 22,
                          accent: on ? AppColors.accent : a.text,
                          framed: false,
                        ),
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: gradient,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: CinematicIcon(
                            glyph: glyph,
                            size: 15,
                            accent: Colors.white,
                            framed: false,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: AppTypography.body(
                          size: 16,
                          weight: FontWeight.w700,
                          color: on ? AppColors.accent : a.text,
                        ),
                      ),
                      TextSpan(
                        text: '   $caption',
                        style: AppTypography.body(
                          size: 13,
                          weight: FontWeight.w600,
                          color: a.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
              // Marcador de rádio, como o `accent-color` ouro do site.
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: on
                        ? AppColors.accent
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1.6,
                  ),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: on ? 10 : 0,
                    height: on ? 10 : 0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final l10n = context.l10n;
    return Column(
      children: [
        SectionLabel(l10n.onboardingNamePrompt, color: a.textFaint),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.words,
          style: AppTypography.display(
            size: 20,
            weight: FontWeight.w800,
            color: a.text,
          ),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: l10n.onboardingNameHint,
            hintStyle: AppTypography.display(
              size: 20,
              weight: FontWeight.w700,
              color: a.textFaint,
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
  final _Intent? intent;
  final int streakGoal;

  const _ThresholdBeat({
    required this.scene,
    required this.breath,
    required this.name,
    required this.intent,
    required this.streakGoal,
  });

  @override
  Widget build(BuildContext context) {
    final short = MediaQuery.sizeOf(context).height < 740;
    final l10n = context.l10n;
    final greeting = ProgressService.isPlaceholderUserName(name)
        ? null
        : name.split(' ').first;
    final promise =
        intent?.promise(l10n) ?? l10n.onboardingDefaultPromise;
    final title = greeting == null
        ? '${promise[0].toUpperCase()}${promise.substring(1)}'
        : '$greeting,\n$promise';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        4,
        AppSpace.screen,
        4,
      ),
      child: Column(
        children: [
          _Kicker(text: l10n.onboardingKickerJourney, scene: scene),
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
            child: _StreakPath(goal: streakGoal, breath: breath),
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

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final title = l10n.onboardingFirstSceneTitle;
    final visuals = TrailVisuals.forSlug(_slug);
    final world = CinematicResolver.ambientForHome(
      trailSlug: _slug,
      missionTitle: title,
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _HeroChip(
                        glyph: visuals.glyph,
                        accent: visuals.accent,
                        label: l10n.settingsGenesisTitle,
                      ),
                      _HeroChip(
                        glyph: CinematicGlyph.lamp,
                        accent: AppColors.accent,
                        label: l10n.onboardingFiveLamps,
                      ),
                    ],
                  ),
                  const Spacer(),
                  SectionLabel(l10n.homeHeroReady, color: style.label),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: AppTypography.display(
                      size: 28,
                      height: 1.08,
                      weight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.onboardingFirstSceneMeta,
                    style: AppTypography.body(
                      size: 14,
                      weight: FontWeight.w600,
                      color: a.textSecondary,
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
    return SoftBadge(
      text: label,
      glyph: glyph,
      accent: accent,
      textColor: a.text,
    );
  }
}
