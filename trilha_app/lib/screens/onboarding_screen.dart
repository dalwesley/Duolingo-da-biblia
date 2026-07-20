import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import 'main_shell.dart';

/// Onboarding cinematográfico — 4 batidas, não tour de features.
/// Promessa → motivo → ritmo → limiar (primeiro passo em Gênesis).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Beat { promise, why, rhythm, threshold }

enum _Why {
  know,
  depth,
  habit,
  grow;

  String get label => switch (this) {
    _Why.know => 'Conhecer a Bíblia',
    _Why.depth => 'Estudar com profundidade',
    _Why.habit => 'Criar um hábito diário',
    _Why.grow => 'Crescer na fé',
  };

  String get echo => switch (this) {
    _Why.know => 'Então começamos no princípio — Gênesis.',
    _Why.depth => 'Quando o versículo pedir, o original está a um toque.',
    _Why.habit => 'Um passo por dia basta para reacender a chama.',
    _Why.grow => 'A caminhada forma o coração. Vamos juntos.',
  };

  CinematicGlyph get glyph => switch (this) {
    _Why.know => CinematicGlyph.book,
    _Why.depth => CinematicGlyph.scroll,
    _Why.habit => CinematicGlyph.flame,
    _Why.grow => CinematicGlyph.seed,
  };
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  static const _beats = _Beat.values;

  final _nameController = TextEditingController();
  late final AnimationController _atmosphere;
  late final AnimationController _breathe;
  late final AnimationController _beatIn;

  int _index = 0;
  int _dailyGoal = 1;
  _Why? _why;
  bool _finishing = false;

  _Beat get _beat => _beats[_index];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _atmosphere = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);
    _beatIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final name = context.read<ProgressService>().userName.trim();
      if (name.isNotEmpty &&
          name != 'Peregrino' &&
          name != 'Estudante' &&
          _nameController.text.isEmpty) {
        _nameController.text = name.split(' ').first;
      }
    });
  }

  @override
  void dispose() {
    _atmosphere.dispose();
    _breathe.dispose();
    _beatIn.dispose();
    _nameController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Future<void> _playBeatIn() async {
    _beatIn
      ..stop()
      ..reset();
    await _beatIn.forward();
  }

  Future<void> _goNext() async {
    if (_beat == _Beat.why && _why == null) {
      HapticFeedback.selectionClick();
      return;
    }
    if (_index >= _beats.length - 1) {
      await _finish();
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _index += 1);
    await _playBeatIn();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    HapticFeedback.mediumImpact();

    final progress = context.read<ProgressService>();
    final backend = context.read<BackendService>();
    final league = context.read<LeagueService>();
    final name = _nameController.text.trim();
    if (name.isNotEmpty) await progress.setUserName(name);
    await progress.updateSettings(
      progress.settings.copyWith(dailyGoal: _dailyGoal),
    );
    await progress.setHasSeenOnboarding(true);
    await backend.saveNow(
      progress,
      LeagueService.weekKey(),
      league: league,
    );

    if (!mounted) return;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainShell(initialTrailSlug: 'genesis-1-11'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  String get _ctaLabel => switch (_beat) {
    _Beat.promise => 'ENTRAR NO CAMINHO',
    _Beat.why => 'CONTINUAR',
    _Beat.rhythm => 'DEFINIR MEU RITMO',
    _Beat.threshold => 'DAR O PRIMEIRO PASSO',
  };

  bool get _ctaEnabled => _beat != _Beat.why || _why != null;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dawn = (_index / (_beats.length - 1)).clamp(0.0, 1.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF030208),
        body: AnimatedBuilder(
          animation: Listenable.merge([_atmosphere, _breathe, _beatIn]),
          builder: (context, _) {
            final breath = _breathe.value;
            final enter = Curves.easeOutCubic.transform(_beatIn.value);

            return Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    size: size,
                    painter: _OnboardingSkyPainter(
                      progress: _atmosphere.value,
                      dawn: dawn,
                      breath: breath,
                      beat: _index,
                    ),
                  ),
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.2),
                        radius: 1.2,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.2, 0.58, 1],
                      ),
                    ),
                  ),
                ),

                // Letterbox
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ColoredBox(
                    color: Colors.black,
                    child: SizedBox(height: 22),
                  ),
                ),
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ColoredBox(
                    color: Colors.black,
                    child: SizedBox(height: 22),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpace.sm, AppSpace.xs, AppSpace.sm, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _BeatProgress(
                                index: _index,
                                total: _beats.length,
                              ),
                            ),
                            TextButton(
                              onPressed: _finishing ? null : _finish,
                              child: Text(
                                'Pular',
                                style: AppTypography.body(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Opacity(
                          opacity: enter,
                          child: Transform.translate(
                            offset: Offset(0, 22 * (1 - enter)),
                            child: _buildBeat(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.screen, AppSpace.xl),
                        child: _CtaButton(
                          label: _ctaLabel,
                          enabled: _ctaEnabled && !_finishing,
                          loading: _finishing,
                          onTap: _goNext,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBeat() {
    return switch (_beat) {
      _Beat.promise => const _PromiseBeat(),
      _Beat.why => _WhyBeat(
        selected: _why,
        onSelect: (w) {
          HapticFeedback.selectionClick();
          setState(() => _why = w);
        },
      ),
      _Beat.rhythm => _RhythmBeat(
        controller: _nameController,
        dailyGoal: _dailyGoal,
        onGoal: (g) {
          HapticFeedback.selectionClick();
          setState(() => _dailyGoal = g);
        },
      ),
      _Beat.threshold => _ThresholdBeat(
        name: _nameController.text.trim(),
        why: _why,
        dailyGoal: _dailyGoal,
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// Beats
// ---------------------------------------------------------------------------

class _PromiseBeat extends StatelessWidget {
  const _PromiseBeat();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.xxl, AppSpace.md, AppSpace.xxl, AppSpace.sm),
      child: Column(
        children: [
          const Spacer(flex: 2),
          const CinematicIcon(
            glyph: CinematicGlyph.path,
            size: 88,
            accent: AppColors.accent,
            glowing: true,
          ),
          const SizedBox(height: 28),
          Text(
            'NO PRINCÍPIO',
            style: AppTypography.label(
              size: 11,
              letterSpacing: 3.2,
              color: AppColors.accent.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppSpace.section),
          Text(
            'Um caminho diário\npara aprender a Bíblia\nde verdade.',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 34, height: 1.12),
          ),
          const SizedBox(height: AppSpace.lg),
          Text(
            'Missões curtas. Profundidade quando o versículo pedir.\nFeito em português, para a sua caminhada.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
          const Spacer(flex: 3),
          Text(
            '"Lâmpada para os meus pés é a tua palavra."',
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 15,
              weight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: AppColors.accent.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            'Salmos 119:105',
            style: AppTypography.label(
              size: 10,
              letterSpacing: 1.4,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _WhyBeat extends StatelessWidget {
  final _Why? selected;
  final ValueChanged<_Why> onSelect;

  const _WhyBeat({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.screen, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            'O QUE TE TROUXE',
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 11,
              letterSpacing: 2.8,
              color: AppColors.accent.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Por que você quer caminhar\nna Palavra?',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 30, height: 1.15),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Escolha o que mais ressoa agora.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpace.section),
          ..._Why.values.map((w) {
            final on = selected == w;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.sm),
              child: _ChoiceTile(
                glyph: w.glyph,
                label: w.label,
                selected: on,
                onTap: () => onSelect(w),
              ),
            );
          }),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 280),
            opacity: selected == null ? 0 : 1,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpace.sm),
              child: Text(
                selected?.echo ?? '',
                textAlign: TextAlign.center,
                style: AppTypography.display(
                  size: 16,
                  weight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: AppColors.accent.withValues(alpha: 0.88),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RhythmBeat extends StatelessWidget {
  final TextEditingController controller;
  final int dailyGoal;
  final ValueChanged<int> onGoal;

  const _RhythmBeat({
    required this.controller,
    required this.dailyGoal,
    required this.onGoal,
  });

  String get _goalEcho => switch (dailyGoal) {
    1 => 'Leve e constante — o hábito nasce no retorno.',
    2 => 'Ritmo firme. Dois passos por dia mudam a semana.',
    _ => 'Intenso. Reserve o tempo — a Palavra merece presença.',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.sm, AppSpace.screen, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            'SEU RITMO',
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 11,
              letterSpacing: 2.8,
              color: AppColors.accent.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Como podemos te chamar\nnessa caminhada?',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 30, height: 1.15),
          ),
          const SizedBox(height: AppSpace.section),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            style: AppTypography.title(size: 16, color: Colors.white),
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              hintText: 'Seu nome',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.07),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpace.lg,
                vertical: AppSpace.lg,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                borderSide: BorderSide(
                  color: AppColors.accent.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.xxl),
          Text(
            'Passos por dia',
            textAlign: TextAlign.center,
            style: AppTypography.title(
              size: 13,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [1, 2, 3].map((g) {
              final on = dailyGoal == g;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: g < 3 ? AppSpace.sm : 0),
                  child: GestureDetector(
                    onTap: () => onGoal(g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
                      decoration: BoxDecoration(
                        color: on
                            ? AppColors.accent.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                          color: on
                              ? AppColors.accent.withValues(alpha: 0.65)
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$g',
                            style: AppTypography.display(
                              size: 28,
                              color: on ? AppColors.accent : Colors.white70,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: AppSpace.xs),
                          Text(
                            g == 1 ? 'passo' : 'passos',
                            style: AppTypography.body(
                              size: 11,
                              weight: FontWeight.w700,
                              color: on
                                  ? AppColors.accent.withValues(alpha: 0.9)
                                  : Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpace.lg),
          Text(
            _goalEcho,
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 16,
              weight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: AppColors.accent.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThresholdBeat extends StatelessWidget {
  final String name;
  final _Why? why;
  final int dailyGoal;

  const _ThresholdBeat({
    required this.name,
    required this.why,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final greeting = name.isEmpty ? 'Peregrino' : name;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.xxl, AppSpace.md, AppSpace.xxl, 0),
      child: Column(
        children: [
          const Spacer(flex: 2),
          const CinematicIcon(
            glyph: CinematicGlyph.spark,
            size: 92,
            accent: AppColors.accent,
            glowing: true,
          ),
          const SizedBox(height: 26),
          Text(
            'O CAMINHO SE ABRE',
            style: AppTypography.label(
              size: 11,
              letterSpacing: 3,
              color: AppColors.accent.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            '$greeting,\nsua primeira trilha espera.',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 32, height: 1.15),
          ),
          const SizedBox(height: AppSpace.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.lg),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
            ),
            child: Column(
              children: [
                Text(
                  'Gênesis 1–11',
                  style: AppTypography.display(size: 24),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  'Do vazio à luz — onde tudo começa',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    size: 13,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: AppSpace.section),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MiniChip(
                      label: why?.label ?? 'Caminhada',
                      glyph: why?.glyph ?? CinematicGlyph.path,
                    ),
                    const SizedBox(width: 8),
                    _MiniChip(
                      label: '$dailyGoal passo${dailyGoal > 1 ? 's' : ''}/dia',
                      glyph: CinematicGlyph.flame,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          Text(
            'Um passo basta para começar.',
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 17,
              weight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpace.md),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// UI pieces
// ---------------------------------------------------------------------------

class _ChoiceTile extends StatelessWidget {
  final CinematicGlyph glyph;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.glyph,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.section, vertical: AppSpace.section),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: selected
                  ? AppColors.accent.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              CinematicIcon(
                glyph: glyph,
                size: 36,
                accent: selected ? AppColors.accent : AppColors.primaryLight,
                glowing: selected,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.title(
                    size: 15,
                    color: Colors.white.withValues(alpha: selected ? 0.95 : 0.78),
                  ),
                ),
              ),
              selected
                  ? CinematicIcon(
                      glyph: CinematicGlyph.check,
                      size: 20,
                      accent: AppColors.accent,
                      framed: false,
                    )
                  : Icon(
                      Icons.circle_outlined,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final CinematicGlyph glyph;

  const _MiniChip({required this.label, required this.glyph});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CinematicIcon(
            glyph: glyph,
            size: 18,
            accent: AppColors.accent,
            glowing: false,
            framed: false,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.body(
              size: 11,
              weight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeatProgress extends StatelessWidget {
  final int index;
  final int total;

  const _BeatProgress({required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    final t = (index + 1) / total;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: SizedBox(
              height: 2.5,
              width: 120,
              child: Stack(
                children: [
                  Container(color: Colors.white.withValues(alpha: 0.1)),
                  FractionallySizedBox(
                    widthFactor: t,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppGradients.gold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${index + 1} / $total',
            style: AppTypography.label(
              size: 10,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _CtaButton({
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
              gradient: AppGradients.gold,
              borderRadius: BorderRadius.circular(AppRadii.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentDark.withValues(alpha: 0.4),
                  offset: const Offset(0, 5),
                  blurRadius: 16,
                ),
              ],
            ),
            child: loading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.inkOnAccent,
                      ),
                    ),
                  )
                : Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.cta(size: 14),
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Atmosphere
// ---------------------------------------------------------------------------

class _OnboardingSkyPainter extends CustomPainter {
  final double progress;
  final double dawn;
  final double breath;
  final int beat;

  _OnboardingSkyPainter({
    required this.progress,
    required this.dawn,
    required this.breath,
    required this.beat,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final top = Color.lerp(
      const Color(0xFF05070A),
      const Color(0xFF152820),
      dawn * 0.75,
    )!;
    final mid = Color.lerp(
      const Color(0xFF0E1412),
      const Color(0xFF243F36),
      dawn * 0.55,
    )!;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, mid, const Color(0xFF060908)],
          stops: const [0.0, 0.48, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Glow
    final glowCenter = Offset(
      size.width * (0.55 + 0.1 * dawn),
      size.height * (0.22 - 0.04 * dawn),
    );
    canvas.drawCircle(
      glowCenter,
      size.width * (0.42 + 0.08 * breath),
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primaryLight.withValues(
              alpha: 0.14 * progress * (0.65 + 0.35 * breath),
            ),
            AppColors.accent.withValues(alpha: 0.07 * progress * dawn),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: glowCenter, radius: size.width * 0.55),
        ),
    );

    // Stars fade as dawn rises
    final starAlpha = (1 - dawn * 0.85) * progress;
    final rnd = math.Random(42);
    for (var i = 0; i < 48; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.55;
      final r = 0.6 + rnd.nextDouble() * 1.4;
      final a = (0.25 + rnd.nextDouble() * 0.55) * starAlpha;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Colors.white.withValues(alpha: a),
      );
    }

    // Horizon path (beats 2–3)
    if (beat >= 2) {
      final pathStrength = ((beat - 1) / 2).clamp(0.0, 1.0) * progress;
      final horizonY = size.height * 0.72;
      final path = Path()
        ..moveTo(size.width * 0.12, horizonY + 40)
        ..quadraticBezierTo(
          size.width * 0.38,
          horizonY - 18 * pathStrength,
          size.width * 0.52,
          horizonY + 8,
        )
        ..quadraticBezierTo(
          size.width * 0.68,
          horizonY + 28,
          size.width * 0.88,
          horizonY - 10 * pathStrength,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.35 * pathStrength)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      // Soft ground wash
      canvas.drawRect(
        Rect.fromLTWH(0, horizonY + 20, size.width, size.height - horizonY),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.12 * pathStrength),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY),
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OnboardingSkyPainter old) =>
      old.progress != progress ||
      old.dawn != dawn ||
      old.breath != breath ||
      old.beat != beat;
}
