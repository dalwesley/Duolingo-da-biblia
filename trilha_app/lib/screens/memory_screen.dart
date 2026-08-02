import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/memory_verses.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';

/// Memorização — flashcards com SRS leve (favoritos + catálogo).
class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen>
    with TickerProviderStateMixin {
  static const _bgAsset = 'assets/icon/splash_bg.png';

  List<MemoryVerse> _deck = const [];
  int _index = 0;
  bool _revealed = false;
  bool _loading = true;
  int _known = 0;
  int _learning = 0;
  bool _finished = false;

  late final AnimationController _pulse;
  late final AnimationController _flip;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(const AssetImage(_bgAsset), context);
    });
    _load();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _flip.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final progress = context.read<ProgressService>();
    final deck = <MemoryVerse>[];
    final seen = <String>{};

    // Prioriza o que ainda não está firme.
    final ranked = [...MemoryVerseCatalog.curated]
      ..sort(
        (a, b) =>
            progress.memoryScore(a.id).compareTo(progress.memoryScore(b.id)),
      );

    for (final v in ranked) {
      if (progress.isMemoryMastered(v.id)) continue;
      deck.add(v);
      seen.add(v.id);
      if (deck.length >= 8) break;
    }

    // Completa com favoritos do usuário (texto da TB offline).
    for (final b in progress.parseBookmarks()) {
      final id = 'bm:${b.abbrev}:${b.chapter}:${b.verse}';
      if (seen.contains(id) || progress.isMemoryMastered(id)) continue;
      final text = await BibleService.instance.verseText(
        b.abbrev,
        b.chapter,
        b.verse,
      );
      if (text == null) continue;
      final books = await BibleService.instance.books();
      String name = b.abbrev.toUpperCase();
      for (final book in books) {
        if (book.abbrev.toLowerCase() == b.abbrev.toLowerCase()) {
          name = book.name;
          break;
        }
      }
      deck.add(
        MemoryVerse(
          id: id,
          reference: '$name ${b.chapter}:${b.verse}',
          text: text,
          abbrev: b.abbrev,
          chapter: b.chapter,
          verse: b.verse,
        ),
      );
      seen.add(id);
      if (deck.length >= 10) break;
    }

    // Se tudo está mastered, oferece revisão do catálogo.
    if (deck.isEmpty) {
      deck.addAll(MemoryVerseCatalog.curated.take(6));
    }

    if (!mounted) return;
    setState(() {
      _deck = deck;
      _loading = false;
      _index = 0;
      _revealed = false;
      _finished = false;
      _known = 0;
      _learning = 0;
    });
    _flip.value = 0;
    _pulse.repeat(reverse: true);
  }

  MemoryVerse get _current => _deck[_index];

  void _revealCard() {
    if (_revealed || _flip.isAnimating) return;
    HapticFeedback.lightImpact();
    _pulse.stop();
    setState(() => _revealed = true);
    _flip.forward(from: 0);
  }

  Future<void> _answer({required bool knew}) async {
    final progress = context.read<ProgressService>();
    HapticFeedback.selectionClick();
    await progress.recordMemoryReview(_current.id, knew: knew);
    if (knew) {
      SoundService.instance.playCorrect();
      _known++;
    } else {
      SoundService.instance.playWrong();
      _learning++;
    }

    if (_index + 1 >= _deck.length) {
      await progress.grantBonusSteps(8 + (_known * 4));
      if (!mounted) return;
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index++;
      _revealed = false;
    });
    _flip.value = 0;
    _pulse.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

    return Appearance(
      mode: mode,
      style: appearance,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
          body: ImmersiveBackground(
            appearance: appearance,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpace.screen,
                    MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
                    AppSpace.screen,
                    0,
                  ),
                  child: TopBar(
                    inline: true,
                    immersive: true,
                    dark: true,
                    title: 'Memorizar',
                    subtitle: 'Fixe na memória',
                    onBack: () => Navigator.pop(context),
                    leadingGlyph: CinematicGlyph.heart,
                    chromeAccent: AppColors.clay,
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        )
                      : _finished
                      ? _DonePane(
                          known: _known,
                          learning: _learning,
                          onAgain: _load,
                          onClose: () => Navigator.pop(context),
                        )
                      : Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpace.screen,
                            AppSpace.sm,
                            AppSpace.screen,
                            AppSpace.xxl +
                                MediaQuery.viewPaddingOf(context).bottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ProgressHeader(
                                index: _index,
                                total: _deck.length,
                                revealed: _revealed,
                                trackColor: appearance.progressTrack,
                              ),
                              const SizedBox(height: AppSpace.xl),
                              Expanded(
                                child: _FlashCard(
                                  verse: _current,
                                  revealed: _revealed,
                                  pulse: _pulse,
                                  flip: _flip,
                                  onReveal: _revealCard,
                                ),
                              ),
                              const SizedBox(height: AppSpace.lg),
                              AnimatedBuilder(
                                animation: _flip,
                                builder: (context, _) {
                                  final Widget child;
                                  if (!_revealed) {
                                    child = CopperCta(
                                      key: const ValueKey('reveal'),
                                      label: 'Revelar',
                                      trailing: CinematicGlyph.spark,
                                      onTap: _revealCard,
                                    );
                                  } else if (_flip.value >= 0.55) {
                                    child = _AnswerRow(
                                      key: const ValueKey('answers'),
                                      onLearning: () => _answer(knew: false),
                                      onKnown: () => _answer(knew: true),
                                    );
                                  } else {
                                    child = const SizedBox(
                                      key: ValueKey('flipping'),
                                      height: 56,
                                    );
                                  }
                                  return AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 240),
                                    switchInCurve: Curves.easeOutCubic,
                                    switchOutCurve: Curves.easeInCubic,
                                    transitionBuilder: (widget, anim) {
                                      return FadeTransition(
                                        opacity: anim,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.12),
                                            end: Offset.zero,
                                          ).animate(anim),
                                          child: widget,
                                        ),
                                      );
                                    },
                                    child: child,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int index;
  final int total;
  final bool revealed;
  final Color trackColor;

  const _ProgressHeader({
    required this.index,
    required this.total,
    required this.revealed,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'CARTA',
              style: AppTypography.label(
                size: 10,
                color: AppColors.accent.withValues(alpha: 0.85),
                letterSpacing: 1.6,
              ),
            ),
            const Spacer(),
            Text(
              '${index + 1}  ·  $total',
              style: AppTypography.label(
                size: 12,
                color: Appearance.of(context).textMuted(0.55),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        AppProgressBar(
          value: (index + (revealed ? 0.5 : 0)) / total,
          trackColor: trackColor,
        ),
      ],
    );
  }
}

/// Carta de baralho — frente com trilha viva; verso com fundo apagado + versículo.
class _FlashCard extends StatelessWidget {
  final MemoryVerse verse;
  final bool revealed;
  final AnimationController pulse;
  final AnimationController flip;
  final VoidCallback onReveal;

  const _FlashCard({
    required this.verse,
    required this.revealed,
    required this.pulse,
    required this.flip,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: revealed ? null : onReveal,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([pulse, flip]),
        builder: (context, _) {
          final breathe = revealed ? 1.0 : 0.92 + (pulse.value * 0.08);
          final angle = Curves.easeInOutCubic.transform(flip.value) * math.pi;
          final showFront = angle <= (math.pi / 2);
          final glowAlpha = showFront ? 0.18 * breathe : 0.28;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: Transform(
              alignment: Alignment.center,
              // Desfaz o espelhamento do verso depois do meio giro.
              transform: showFront
                  ? Matrix4.identity()
                  : Matrix4.rotationY(math.pi),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
                  border: Border.all(
                    color: AppMetrics.accentBorder(
                      alpha: showFront
                          ? 0.55 + (0.12 * breathe)
                          : 0.75,
                    ),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: glowAlpha),
                      blurRadius: showFront ? 16 : 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppMetrics.heroRadius - 1.2,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: AppColors.primaryDark),
                      Opacity(
                        // Frente viva; verso apagado para o texto sobressair.
                        opacity: showFront ? 1.0 : 0.28,
                        child: const Image(
                          image: AssetImage('assets/icon/splash_bg.png'),
                          fit: BoxFit.cover,
                          alignment: Alignment(0, -0.08),
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: showFront
                                ? [
                                    Colors.black.withValues(alpha: 0.18),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.42),
                                  ]
                                : [
                                    Colors.black.withValues(alpha: 0.55),
                                    Colors.black.withValues(alpha: 0.72),
                                    Colors.black.withValues(alpha: 0.82),
                                  ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpace.xxl,
                          AppSpace.xxl,
                          AppSpace.xxl,
                          AppSpace.xl,
                        ),
                        child: showFront
                            ? _CardFront(
                                reference: verse.reference,
                                pulse: breathe,
                              )
                            : _CardBack(
                                reference: verse.reference,
                                text: verse.text,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final String reference;
  final double pulse;

  const _CardFront({required this.reference, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CinematicIcon(
          glyph: CinematicGlyph.heart,
          size: 44,
          accent: AppColors.clay,
          glowing: false,
        ),
        const SizedBox(height: AppSpace.lg),
        Text(
          reference.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTypography.label(
            size: 13,
            letterSpacing: 1.8,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpace.md),
        const _GoldRule(),
        const SizedBox(height: AppSpace.xl),
        Expanded(
          child: Center(
            child: Opacity(
              opacity: 0.35 + (pulse - 0.92) * 4,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _VerseSkeleton(widthFactor: 0.92),
                  SizedBox(height: 10),
                  _VerseSkeleton(widthFactor: 0.78),
                  SizedBox(height: 10),
                  _VerseSkeleton(widthFactor: 0.84),
                  SizedBox(height: 10),
                  _VerseSkeleton(widthFactor: 0.56),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardBack extends StatelessWidget {
  final String reference;
  final String text;

  const _CardBack({required this.reference, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CinematicIcon(
          glyph: CinematicGlyph.heart,
          size: 44,
          accent: AppColors.clay,
          glowing: true,
        ),
        const SizedBox(height: AppSpace.lg),
        Text(
          reference.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTypography.label(
            size: 13,
            letterSpacing: 1.8,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpace.md),
        const _GoldRule(),
        const SizedBox(height: AppSpace.xl),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppTypography.verse(
                  size: 24,
                  weight: FontWeight.w600,
                  height: 1.45,
                  color: AppColors.textOnDark,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoldRule extends StatelessWidget {
  const _GoldRule();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.05),
            AppColors.accent.withValues(alpha: 0.7),
            AppColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }
}

class _VerseSkeleton extends StatelessWidget {
  final double widthFactor;

  const _VerseSkeleton({required this.widthFactor});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.textOnDark.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final VoidCallback onLearning;
  final VoidCallback onKnown;

  const _AnswerRow({
    super.key,
    required this.onLearning,
    required this.onKnown,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            label: 'Ainda não',
            glyph: CinematicGlyph.echo,
            color: AppColors.error,
            onTap: onLearning,
          ),
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: _ActionBtn(
            label: 'Já sei',
            glyph: CinematicGlyph.check,
            color: AppColors.teal,
            onTap: onKnown,
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final CinematicGlyph glyph;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.glyph,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: color.withValues(alpha: 0.65)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CinematicIcon(
                glyph: glyph,
                size: 18,
                accent: color,
                framed: false,
              ),
              const SizedBox(width: 8),
              Text(label, style: AppTypography.cta(size: 14, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonePane extends StatelessWidget {
  final int known;
  final int learning;
  final VoidCallback onAgain;
  final VoidCallback onClose;

  const _DonePane({
    required this.known,
    required this.learning,
    required this.onAgain,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpace.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.spark,
            size: 72,
            glowing: false,
          ),
          const SizedBox(height: AppSpace.xl),
          Text(
            'Sessão concluída',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 32),
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            '$known firmes · $learning em progresso',
            textAlign: TextAlign.center,
            style: AppTypography.body(color: a.textMuted(0.65)),
          ),
          const SizedBox(height: AppSpace.xxl),
          CopperCta(
            label: 'Tentar de novo',
            trailing: CinematicGlyph.path,
            onTap: onAgain,
          ),
          const SizedBox(height: AppSpace.sm),
          TextButton(
            onPressed: onClose,
            child: Text(
              'Fechar',
              style: AppTypography.body(color: a.textMuted(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}
