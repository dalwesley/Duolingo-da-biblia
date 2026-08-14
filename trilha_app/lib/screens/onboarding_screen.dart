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

/// Onboarding STWAY — primeiro contato cinematográfico.
/// Origem → hábito → missão → ritmo → primeira trilha.
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
  late final AnimationController _enter;
  late final AnimationController _world;

  int _index = 0;
  int _dailyGoal = 1;
  bool _askName = false;
  bool _finishing = false;

  CreationWorldState _fromWorld = const CreationWorldState(voidDepth: 1);
  CreationWorldState _toWorld = _worldFor(_Beat.origin);

  _Beat get _beat => _beats[_index];

  static CreationWorldState _worldFor(_Beat beat) => switch (beat) {
    _Beat.origin => const CreationWorldState(
      voidDepth: 0.92,
      spirit: 0.75,
      waters: 0.5,
    ),
    _Beat.habit => const CreationWorldState(
      voidDepth: 0.28,
      spirit: 0.35,
      waters: 0.28,
      light: 0.88,
    ),
    _Beat.walk => const CreationWorldState(
      voidDepth: 0.18,
      light: 0.58,
      waters: 0.36,
      land: 0.78,
      plants: 0.55,
    ),
    _Beat.rhythm => const CreationWorldState(
      voidDepth: 0.38,
      light: 0.4,
      stars: 0.82,
      land: 0.28,
    ),
    _Beat.threshold => const CreationWorldState(
      voidDepth: 0.22,
      light: 0.72,
      waters: 0.28,
      land: 0.62,
      plants: 0.42,
      humanity: 0.7,
    ),
  };

  @override
  void initState() {
    super.initState();

    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    )..forward();

    _world = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

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
    _enter.dispose();
    _world.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _playEnter() async {
    _enter
      ..stop()
      ..reset();
    await _enter.forward();
  }

  Future<void> _goNext() async {
    if (_index >= _beats.length - 1) {
      await _finish();
      return;
    }
    HapticFeedback.lightImpact();
    final next = _beats[_index + 1];
    setState(() {
      _fromWorld = _toWorld;
      _toWorld = _worldFor(next);
      _index += 1;
    });
    _world
      ..stop()
      ..forward(from: 0);
    await _playEnter();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    HapticFeedback.mediumImpact();

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
        appearanceMode: AppearanceMode.morning,
      ),
    );
    await progress.setHasSeenOnboarding(true);
    await backend.saveNow(progress, LeagueService.weekKey(), league: league);

    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainShell(initialTrailSlug: 'genesis-1-11'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 640),
      ),
    );
  }

  String get _ctaLabel => switch (_beat) {
    _Beat.origin => 'Começar',
    _Beat.habit => 'Continuar',
    _Beat.walk => 'Continuar',
    _Beat.rhythm => 'Definir ritmo',
    _Beat.threshold => 'Abrir primeira lição',
  };

  bool get _showSkip => _beat != _Beat.threshold;

  @override
  Widget build(BuildContext context) {
    const mode = AppearanceMode.morning;
    final appearance = AppearanceStyle.resolve(mode);

    return ImmersiveScaffold(
      mode: mode,
      style: appearance,
      background: AnimatedBuilder(
        animation: _world,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CinematicBackdrop(
                world: _fromWorld,
                revealing: _toWorld,
                revealProgress: _world.value,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66040910),
                      Color(0x33040910),
                      Color(0x99040910),
                    ],
                    stops: [0.0, 0.42, 1.0],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      body: AnimatedBuilder(
        animation: _enter,
        builder: (context, _) {
          final enter = Curves.easeOutCubic.transform(_enter.value);

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.screen, 8, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StepDots(index: _index, total: _beats.length),
                      ),
                      if (_showSkip)
                        TextButton(
                          onPressed: _finishing ? null : _finish,
                          child: Text(
                            'Pular',
                            style: AppTypography.body(
                              size: 13,
                              weight: FontWeight.w700,
                              color: Appearance.of(context).textMuted(0.45),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: Opacity(
                    opacity: enter,
                    child: Transform.translate(
                      offset: Offset(0, 22 * (1 - enter)),
                      child: Transform.scale(
                        scale: 0.96 + 0.04 * enter,
                        child: _buildBeat(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.screen,
                    8,
                    AppSpace.screen,
                    AppSpace.screen,
                  ),
                  child: Opacity(
                    opacity: _finishing ? 0.55 : 1,
                    child: CopperCta(
                      label: _finishing ? 'Abrindo…' : _ctaLabel,
                      onTap: _finishing ? null : _goNext,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBeat() {
    return switch (_beat) {
      _Beat.origin => const _OriginBeat(),
      _Beat.habit => const _HabitBeat(),
      _Beat.walk => const _WalkBeat(),
      _Beat.rhythm => _RhythmBeat(
        controller: _nameController,
        askName: _askName,
        dailyGoal: _dailyGoal,
        onGoal: (g) {
          HapticFeedback.selectionClick();
          setState(() => _dailyGoal = g);
        },
      ),
      _Beat.threshold => _ThresholdBeat(
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : context.read<ProgressService>().userName,
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// Beats
// ---------------------------------------------------------------------------

class _OriginBeat extends StatelessWidget {
  const _OriginBeat();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        8,
        AppSpace.screen,
        8,
      ),
      child: Column(
        children: [
          const Center(child: StwayWordmark(fontSize: 20, letterSpacing: 3.2)),
          const SizedBox(height: 6),
          const StwayTagline(size: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CinematicIcon(
                  glyph: CinematicGlyph.cosmos,
                  size: 84,
                  accent: AppColors.accent,
                  glowing: true,
                ),
                const SizedBox(height: 22),
                Text(
                  'NO PRINCÍPIO',
                  textAlign: TextAlign.center,
                  style: AppTypography.label(
                    size: 12,
                    letterSpacing: 2.2,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Deus falou.\nO mundo começou.',
                  textAlign: TextAlign.center,
                  style: AppTypography.display(
                    size: 34,
                    height: 1.1,
                    weight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'A Bíblia não é um livro para terminar.\nÉ o lugar onde você encontra quem te criou.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    size: 15,
                    height: 1.45,
                    weight: FontWeight.w600,
                    color: a.text.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          GlassCard(
            accent: true,
            elevated: true,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              children: [
                Text(
                  'No princípio, Deus criou os céus e a terra.',
                  textAlign: TextAlign.center,
                  style: AppTypography.verse(size: 22, height: 1.4),
                ),
                const SizedBox(height: 10),
                Text(
                  'GÊNESIS 1.1',
                  style: AppTypography.label(
                    size: 11,
                    letterSpacing: 1.8,
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
  const _HabitBeat();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        4,
        AppSpace.screen,
        8,
      ),
      child: Column(
        children: [
          Text(
            'O HÁBITO',
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 12,
              letterSpacing: 2.2,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Três minutos.\nTodo dia.',
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 34,
              height: 1.1,
              weight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Conhecer a Deus não pede uma maratona.\nPede presença — um passo curto, repetido, até virar caminho.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 15,
              height: 1.45,
              weight: FontWeight.w600,
              color: a.text.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 22),
          const Expanded(
            child: _StoryPoints(
              items: [
                (
                  glyph: CinematicGlyph.sun,
                  title: '3 minutos',
                  subtitle: 'Cabe entre o café e a porta',
                ),
                (
                  glyph: CinematicGlyph.flame,
                  title: 'Todo dia',
                  subtitle: 'O retorno forma o hábito',
                ),
                (
                  glyph: CinematicGlyph.heart,
                  title: 'A Palavra',
                  subtitle: 'Presença, não performance',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkBeat extends StatelessWidget {
  const _WalkBeat();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        4,
        AppSpace.screen,
        8,
      ),
      child: Column(
        children: [
          Text(
            'A MISSÃO',
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 12,
              letterSpacing: 2.2,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Leia. Responda.\nEntenda.',
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 34,
              height: 1.1,
              weight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Não é trivia. Não é só leitura.\nÉ a Bíblia na mão, uma pergunta de verdade, e o entendimento que fica.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 15,
              height: 1.45,
              weight: FontWeight.w600,
              color: a.text.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 22),
          const Expanded(
            child: _StoryPoints(
              items: [
                (
                  glyph: CinematicGlyph.book,
                  title: 'Leia a passagem',
                  subtitle: 'Contexto curto, Bíblia offline',
                ),
                (
                  glyph: CinematicGlyph.lamp,
                  title: 'Responda a missão',
                  subtitle: 'Perguntas + feedback imediato',
                ),
                (
                  glyph: CinematicGlyph.path,
                  title: 'Volte amanhã',
                  subtitle: 'A sequência sustenta o hábito',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryPoints extends StatelessWidget {
  final List<({CinematicGlyph glyph, String title, String subtitle})> items;

  const _StoryPoints({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Expanded(
            child: _StoryPointCard(
              glyph: items[i].glyph,
              title: items[i].title,
              subtitle: items[i].subtitle,
            ),
          ),
        ],
      ],
    );
  }
}

class _StoryPointCard extends StatelessWidget {
  final CinematicGlyph glyph;
  final String title;
  final String subtitle;

  const _StoryPointCard({
    required this.glyph,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      elevated: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CinematicIcon(glyph: glyph, size: 48, accent: AppColors.accent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTypography.title(size: 17, color: a.text)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.body(
                    size: 13,
                    color: a.textMuted(0.62),
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

class _GoalOption {
  final int goal;
  final String pace;
  final String echo;
  final String time;

  const _GoalOption({
    required this.goal,
    required this.pace,
    required this.echo,
    required this.time,
  });

  String get unit => goal == 1 ? 'passo' : 'passos';
}

const _goals = <_GoalOption>[
  _GoalOption(
    goal: 1,
    pace: 'Leve',
    echo: 'Uma missão. O hábito nasce no retorno.',
    time: '~3 min',
  ),
  _GoalOption(
    goal: 2,
    pace: 'Firme',
    echo: 'Dois passos. A semana muda de cara.',
    time: '~6 min',
  ),
  _GoalOption(
    goal: 3,
    pace: 'Intenso',
    echo: 'Reserve o tempo — o estudo vale a presença.',
    time: '~9 min',
  ),
];

class _RhythmBeat extends StatelessWidget {
  final TextEditingController controller;
  final bool askName;
  final int dailyGoal;
  final ValueChanged<int> onGoal;

  const _RhythmBeat({
    required this.controller,
    required this.askName,
    required this.dailyGoal,
    required this.onGoal,
  });

  _GoalOption get _selected =>
      _goals.firstWhere((g) => g.goal == dailyGoal, orElse: () => _goals.first);

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        4,
        AppSpace.screen,
        8,
      ),
      child: Column(
        children: [
          Text(
            'SEU RITMO',
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 12,
              letterSpacing: 2.2,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Quanto você caminha\npor dia?',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 30, height: 1.12),
          ),
          if (askName) ...[
            const SizedBox(height: 16),
            GlassCard(
              padding: EdgeInsets.zero,
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.words,
                style: AppTypography.title(size: 16, color: a.text),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  hintText: 'Como te chamamos?',
                  hintStyle: TextStyle(color: a.textMuted(0.35)),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _goals.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _GoalCard(
                      option: _goals[i],
                      selected: dailyGoal == _goals[i].goal,
                      onTap: () => onGoal(_goals[i].goal),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            accent: true,
            elevated: true,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Row(
              children: [
                const CinematicIcon(
                  glyph: CinematicGlyph.flame,
                  size: 40,
                  accent: AppColors.accent,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selected.pace.toUpperCase()}  ·  ${_selected.time}',
                        style: AppTypography.label(
                          size: 11,
                          letterSpacing: 1.4,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selected.echo,
                        style: AppTypography.body(
                          size: 14,
                          weight: FontWeight.w700,
                          height: 1.35,
                          color: a.text.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
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

class _GoalCard extends StatelessWidget {
  final _GoalOption option;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = selected ? AppColors.inkOnAccent : a.text;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.gold : null,
            color: selected ? null : a.cardFill,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : a.cardBorder.withValues(alpha: 0.55),
              width: selected ? 0 : 1.5,
            ),
            boxShadow: selected
                ? AppMetrics.accentGlow()
                : AppMetrics.cardShadow(),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${option.goal}',
                style: AppTypography.display(
                  size: 42,
                  weight: FontWeight.w900,
                  color: ink,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                option.unit,
                style: AppTypography.body(
                  size: 13,
                  weight: FontWeight.w800,
                  color: selected
                      ? AppColors.inkOnAccent.withValues(alpha: 0.85)
                      : a.textMuted(0.6),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                option.pace,
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 1.2,
                  color: selected
                      ? AppColors.inkOnAccent
                      : AppColors.accent.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                option.time,
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: selected
                      ? AppColors.inkOnAccent.withValues(alpha: 0.72)
                      : a.textMuted(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThresholdBeat extends StatelessWidget {
  final String name;

  const _ThresholdBeat({required this.name});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final greeting = ProgressService.isPlaceholderUserName(name)
        ? null
        : name.split(' ').first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        4,
        AppSpace.screen,
        8,
      ),
      child: Column(
        children: [
          Text(
            'A JORNADA COMEÇA',
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 12,
              letterSpacing: 2.2,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            greeting == null
                ? 'O primeiro passo\nestá pronto.'
                : '$greeting, o primeiro passo\nestá pronto.',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 30, height: 1.12),
          ),
          const SizedBox(height: 10),
          Text(
            'Começamos no princípio — Gênesis.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              weight: FontWeight.w600,
              color: a.text.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          const Expanded(child: _FirstMissionHero()),
        ],
      ),
    );
  }
}

class _FirstMissionHero extends StatelessWidget {
  const _FirstMissionHero();

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
        boxShadow: [
          ...AppMetrics.cardShadow(elevated: true),
          BoxShadow(
            color: style.glow,
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.heroRadius - 0.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: HeroCardColorGrade(
                mood: HeroCardMood.alive,
                child: CinematicBackdrop(world: world),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.28),
                      Color.lerp(
                        a.cardFill,
                        Colors.black,
                        0.22,
                      )!.withValues(alpha: 0.82),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: HeroCardAtmosphere(mood: HeroCardMood.alive),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
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
                      letterSpacing: 1.8,
                      color: style.label,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _title,
                    style: AppTypography.display(
                      size: 32,
                      height: 1.1,
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
          CinematicIcon(
            glyph: glyph,
            size: 14,
            accent: accent,
            framed: false,
          ),
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

class _StepDots extends StatelessWidget {
  final int index;
  final int total;

  const _StepDots({required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      children: List.generate(total, (i) {
        final on = i <= index;
        final current = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
          width: current ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            gradient: on ? AppGradients.gold : null,
            color: on ? null : a.progressTrack,
          ),
        );
      }),
    );
  }
}
