import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/ui_primitives.dart';
import 'main_shell.dart';

/// Onboarding Steway — 4 passos no visual atual do app.
/// Promessa → motivo → ritmo → primeira trilha.
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
    _Why.grow => 'Conhecer melhor a Cristo',
  };

  String get echo => switch (this) {
    _Why.know => 'Começamos no princípio — Gênesis.',
    _Why.depth => 'Quando o versículo pedir, o original está a um toque.',
    _Why.habit => 'Uma lição por dia basta para manter o ritmo.',
    _Why.grow => 'Missões curtas. A fé cresce com o que você entende.',
  };

  CinematicGlyph get glyph => switch (this) {
    _Why.know => CinematicGlyph.book,
    _Why.depth => CinematicGlyph.scroll,
    _Why.habit => CinematicGlyph.flame,
    _Why.grow => CinematicGlyph.heart,
  };
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  static const _beats = _Beat.values;

  final _nameController = TextEditingController();
  late final AnimationController _enter;
  late final AnimationController _pulse;

  int _index = 0;
  int _dailyGoal = 1;
  _Why? _why;
  bool _finishing = false;

  _Beat get _beat => _beats[_index];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final name = context.read<ProgressService>().userName.trim();
      if (name.isNotEmpty &&
          name != 'Aprendiz' &&
          name != 'Peregrino' &&
          name != 'Estudante' &&
          _nameController.text.isEmpty) {
        _nameController.text = name.split(' ').first;
      }
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    _pulse.dispose();
    _nameController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Future<void> _playEnter() async {
    _enter
      ..stop()
      ..reset();
    await _enter.forward();
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
    await _playEnter();
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
    await backend.saveNow(progress, LeagueService.weekKey(), league: league);

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
        transitionDuration: const Duration(milliseconds: 520),
      ),
    );
  }

  String get _ctaLabel => switch (_beat) {
    _Beat.promise => 'Começar',
    _Beat.why => 'Continuar',
    _Beat.rhythm => 'Definir ritmo',
    _Beat.threshold => 'Abrir primeira lição',
  };

  bool get _ctaEnabled => _beat != _Beat.why || _why != null;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.night,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.night,
        body: AnimatedBuilder(
          animation: Listenable.merge([_enter, _pulse]),
          builder: (context, _) {
            final enter = Curves.easeOutCubic.transform(_enter.value);
            final pulse = _pulse.value;

            return Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0B1628),
                        AppColors.night,
                        Color(0xFF122038),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: size.height * 0.08,
                  right: -40,
                  child: _GlowOrb(
                    size: 220,
                    color: AppColors.primary.withValues(
                      alpha: 0.2 + 0.08 * pulse,
                    ),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.22,
                  left: -50,
                  child: _GlowOrb(
                    size: 200,
                    color: AppColors.accent.withValues(
                      alpha: 0.12 + 0.08 * pulse,
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StepDots(
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
                            offset: Offset(0, 16 * (1 - enter)),
                            child: Transform.scale(
                              scale: 0.97 + 0.03 * enter,
                              child: _buildBeat(pulse),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        child: _PrimaryCta(
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

  Widget _buildBeat(double pulse) {
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
    final a = Appearance.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      children: [
        Text(
          'STEWAY',
          textAlign: TextAlign.center,
          style: AppTypography.label(
            size: 12,
            letterSpacing: 3,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Aprenda a Bíblia\nem missões diárias',
          textAlign: TextAlign.center,
          style: AppTypography.display(
            size: 30,
            height: 1.12,
            weight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Jogo de hábito · estudo real · fé com clareza',
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 13,
            weight: FontWeight.w600,
            color: a.textMuted(0.55),
          ),
        ),
        const SizedBox(height: 22),
        GlassCard(
          accent: true,
          elevated: true,
          radius: AppMetrics.heroRadius,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: a.cardFillSoft,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: a.cardBorder),
                    ),
                    child: Text(
                      'GÊNESIS 1–11',
                      style: AppTypography.label(
                        size: 9,
                        letterSpacing: 1,
                        color: a.text.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const CinematicIcon(
                    glyph: CinematicGlyph.flame,
                    size: 18,
                    accent: AppColors.streak,
                    framed: false,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'PRÓXIMA LIÇÃO',
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 1.4,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Quem criou o mundo?',
                style: AppTypography.display(
                  size: 22,
                  weight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 14),
              const CopperCta(
                label: 'Continuar',
                showArrow: true,
                trailing: null,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _FeatureRow(
          glyph: CinematicGlyph.path,
          title: 'Missões curtas',
          subtitle: 'Perguntas + feedback, no seu tempo',
        ),
        const SizedBox(height: 10),
        const _FeatureRow(
          glyph: CinematicGlyph.book,
          title: 'Estudo na passagem',
          subtitle: 'Contexto e Bíblia offline a um toque',
        ),
        const SizedBox(height: 10),
        const _FeatureRow(
          glyph: CinematicGlyph.flame,
          title: 'Sequência diária',
          subtitle: 'Hábito que sustenta o aprendizado',
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final CinematicGlyph glyph;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.glyph,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      padding: AppMetrics.cardPaddingCompact,
      child: Row(
        children: [
          Container(
            width: AppMetrics.leadingIcon + 6,
            height: AppMetrics.leadingIcon + 6,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Center(
              child: CinematicIcon(
                glyph: glyph,
                size: 22,
                accent: AppColors.accent,
                framed: false,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                Text(
                  subtitle,
                  style: AppTypography.body(size: 12, color: a.textMuted(0.5)),
                ),
              ],
            ),
          ),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      children: [
        Text(
          'SEU OBJETIVO',
          textAlign: TextAlign.center,
          style: AppTypography.label(
            size: 11,
            letterSpacing: 1.8,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'O que te traz ao Steway?',
          textAlign: TextAlign.center,
          style: AppTypography.display(size: 26, height: 1.15),
        ),
        const SizedBox(height: 6),
        Text(
          'Isso ajuda a ajustar o ritmo das missões.',
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 13,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 18),
        ..._Why.values.map((w) {
          final on = selected == w;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChoiceCard(
              glyph: w.glyph,
              label: w.label,
              selected: on,
              onTap: () => onSelect(w),
            ),
          );
        }),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: selected == null ? 0 : 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GlassCard(
              child: Text(
                selected?.echo ?? '',
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.accent.withValues(alpha: 0.95),
                ),
              ),
            ),
          ),
        ),
      ],
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
    2 => 'Ritmo firme. Duas lições por dia mudam a semana.',
    _ => 'Intenso. Reserve o tempo — o estudo vale a presença.',
  };

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      children: [
        Text(
          'SEU RITMO',
          textAlign: TextAlign.center,
          style: AppTypography.label(
            size: 11,
            letterSpacing: 1.8,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personalize sua jornada',
          textAlign: TextAlign.center,
          style: AppTypography.display(size: 26, height: 1.15),
        ),
        const SizedBox(height: 18),
        Text(
          'Nome',
          style: AppTypography.label(
            size: 10,
            letterSpacing: 1.2,
            color: a.textMuted(0.45),
          ),
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 20),
        Text(
          'Meta diária',
          style: AppTypography.label(
            size: 10,
            letterSpacing: 1.2,
            color: a.textMuted(0.45),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 3].map((g) {
            final on = dailyGoal == g;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: g < 3 ? 10 : 0),
                child: GestureDetector(
                  onTap: () => onGoal(g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: on
                          ? AppColors.accent.withValues(alpha: 0.16)
                          : a.cardFill,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(
                        color: on
                            ? AppMetrics.accentBorder(alpha: 0.75)
                            : a.cardBorder,
                        width: on ? 1.5 : 1,
                      ),
                      boxShadow: AppMetrics.cardShadow(accent: on),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$g',
                          style: AppTypography.display(
                            size: 28,
                            weight: FontWeight.w900,
                            color: on ? AppColors.accent : Colors.white70,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          g == 1 ? 'lição' : 'lições',
                          style: AppTypography.body(
                            size: 11,
                            weight: FontWeight.w700,
                            color: on
                                ? AppColors.accent.withValues(alpha: 0.95)
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
        const SizedBox(height: 14),
        GlassCard(
          child: Text(
            _goalEcho,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.accent.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
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
    final a = Appearance.of(context);
    final greeting = name.isEmpty ? 'Aprendiz' : name;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      children: [
        Text(
          'TUDO PRONTO',
          textAlign: TextAlign.center,
          style: AppTypography.label(
            size: 11,
            letterSpacing: 1.8,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$greeting, vamos começar',
          textAlign: TextAlign.center,
          style: AppTypography.display(size: 26, height: 1.15),
        ),
        const SizedBox(height: 6),
        Text(
          'Sua primeira trilha já está preparada.',
          textAlign: TextAlign.center,
          style: AppTypography.body(size: 13, color: a.textMuted(0.5)),
        ),
        const SizedBox(height: 20),
        GlassCard(
          accent: true,
          elevated: true,
          radius: AppMetrics.heroRadius,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: a.cardFillSoft,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: a.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CinematicIcon(
                          glyph: CinematicGlyph.path,
                          size: 16,
                          accent: AppColors.accent,
                          framed: false,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'GÊNESIS 1–11',
                          style: AppTypography.label(
                            size: 10,
                            letterSpacing: 1.1,
                            color: a.text.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const CinematicIcon(
                    glyph: CinematicGlyph.book,
                    size: 36,
                    accent: AppColors.accent,
                    framed: false,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'PRIMEIRA LIÇÃO',
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 1.4,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Do começo — no princípio de tudo',
                style: AppTypography.display(
                  size: 22,
                  weight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(
                    label: why?.label ?? 'Jornada',
                    glyph: why?.glyph ?? CinematicGlyph.path,
                  ),
                  _Chip(
                    label: '$dailyGoal lição${dailyGoal > 1 ? 'ões' : ''}/dia',
                    glyph: CinematicGlyph.flame,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _FeatureRow(
          glyph: CinematicGlyph.check,
          title: 'Estudo curto antes das perguntas',
          subtitle: 'Você vê a passagem e depois pratica',
        ),
        const SizedBox(height: 10),
        const _FeatureRow(
          glyph: CinematicGlyph.path,
          title: 'Passos e sequência',
          subtitle: 'Cada lição alimenta seu progresso',
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final CinematicGlyph glyph;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.glyph,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.14)
                : a.cardFill,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: selected
                  ? AppMetrics.accentBorder(alpha: 0.7)
                  : a.cardBorder,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: AppMetrics.cardShadow(accent: selected),
          ),
          child: Row(
            children: [
              CinematicIcon(
                glyph: glyph,
                size: 32,
                accent: selected ? AppColors.accent : AppColors.primaryLight,
                glowing: false,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.title(
                    size: 15,
                    color: a.text.withValues(alpha: selected ? 0.98 : 0.8),
                  ),
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 22,
                color: selected
                    ? AppColors.accent
                    : a.text.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final CinematicGlyph glyph;

  const _Chip({required this.label, required this.glyph});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
            size: 16,
            accent: AppColors.accent,
            framed: false,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.body(
              size: 11,
              weight: FontWeight.w700,
              color: a.text.withValues(alpha: 0.8),
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
            borderRadius: BorderRadius.circular(999),
            gradient: on ? AppGradients.gold : null,
            color: on ? null : Colors.white.withValues(alpha: 0.15),
          ),
        );
      }),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _PrimaryCta({
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
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: AppGradients.gold,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  offset: const Offset(0, 8),
                  blurRadius: 18,
                ),
              ],
            ),
            child: loading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.inkOnAccent,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: AppTypography.cta(size: 15),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: AppColors.inkOnAccent,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
