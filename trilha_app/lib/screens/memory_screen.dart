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
  List<MemoryVerse> _deck = const [];
  int _index = 0;
  bool _revealed = false;
  bool _loading = true;
  int _known = 0;
  int _learning = 0;
  bool _finished = false;

  late final AnimationController _pulse;
  late final AnimationController _reveal;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _load();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _reveal.dispose();
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
    _reveal.value = 0;
    _pulse.repeat(reverse: true);
  }

  MemoryVerse get _current => _deck[_index];

  void _revealCard() {
    if (_revealed) return;
    HapticFeedback.lightImpact();
    _pulse.stop();
    _reveal.forward(from: 0);
    setState(() => _revealed = true);
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
    _reveal.value = 0;
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
                                      appearance: appearance,
                                      pulse: _pulse,
                                      reveal: _reveal,
                                      onReveal: _revealCard,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpace.lg),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 240),
                                    switchInCurve: Curves.easeOutCubic,
                                    switchOutCurve: Curves.easeInCubic,
                                    transitionBuilder: (child, anim) {
                                      return FadeTransition(
                                        opacity: anim,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.12),
                                            end: Offset.zero,
                                          ).animate(anim),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _revealed
                                        ? _AnswerRow(
                                            key: const ValueKey('answers'),
                                            onLearning: () =>
                                                _answer(knew: false),
                                            onKnown: () =>
                                                _answer(knew: true),
                                          )
                                        : CopperCta(
                                            key: const ValueKey('reveal'),
                                            label: 'Revelar',
                                            trailing: CinematicGlyph.spark,
                                            onTap: _revealCard,
                                          ),
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

class _FlashCard extends StatelessWidget {
  final MemoryVerse verse;
  final bool revealed;
  final AppearanceStyle appearance;
  final AnimationController pulse;
  final AnimationController reveal;
  final VoidCallback onReveal;

  const _FlashCard({
    required this.verse,
    required this.revealed,
    required this.appearance,
    required this.pulse,
    required this.reveal,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: revealed ? null : onReveal,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([pulse, reveal]),
        builder: (context, _) {
          final breathe = revealed ? 1.0 : 0.92 + (pulse.value * 0.08);
          final lift = revealed ? 1.0 : Curves.easeOut.transform(reveal.value);

          return Transform.scale(
            scale: 0.985 + (lift * 0.015),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpace.xxl,
                AppSpace.xxl,
                AppSpace.xxl,
                AppSpace.xl,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    appearance.cardFillSoft,
                    appearance.cardFill,
                  ],
                ),
                border: Border.all(
                  color: AppMetrics.accentBorder(alpha: revealed ? 0.7 : 0.55),
                  width: 1.2,
                ),
                boxShadow: AppMetrics.cardShadow(
                  elevated: true,
                  accent: true,
                  tint: AppColors.accent.withValues(
                    alpha: revealed ? 0.28 : 0.18 * breathe,
                  ),
                ),
              ),
              child: Column(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyph.heart,
                    size: 44,
                    accent: AppColors.clay,
                    glowing: true,
                  ),
                  const SizedBox(height: AppSpace.lg),
                  Text(
                    verse.reference.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTypography.label(
                      size: 13,
                      letterSpacing: 1.8,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                  Container(
                    width: 36,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) {
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.06),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        );
                      },
                      child: revealed
                          ? _RevealedBody(
                              key: const ValueKey('shown'),
                              text: verse.text,
                              color: appearance.text,
                            )
                          : _HiddenBody(
                              key: const ValueKey('hidden'),
                              pulse: breathe,
                              muted: appearance.textMuted(0.72),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HiddenBody extends StatelessWidget {
  final double pulse;
  final Color muted;

  const _HiddenBody({
    super.key,
    required this.pulse,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Opacity(
          opacity: 0.35 + (pulse - 0.92) * 4,
          child: Column(
            children: [
              _VerseSkeleton(widthFactor: 0.92),
              const SizedBox(height: 10),
              _VerseSkeleton(widthFactor: 0.78),
              const SizedBox(height: 10),
              _VerseSkeleton(widthFactor: 0.84),
              const SizedBox(height: 10),
              _VerseSkeleton(widthFactor: 0.56),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.xxl),
        Text(
          'Toque para revelar',
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 15,
            weight: FontWeight.w600,
            color: muted,
          ),
        ),
      ],
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
          color: AppColors.textOnDark.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
    );
  }
}

class _RevealedBody extends StatelessWidget {
  final String text;
  final Color color;

  const _RevealedBody({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.verse(
            size: 24,
            weight: FontWeight.w600,
            height: 1.45,
            color: color,
          ),
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
              Text(
                label,
                style: AppTypography.cta(size: 14, color: color),
              ),
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
            glowing: true,
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
            style: AppTypography.body(
              color: a.textMuted(0.65),
            ),
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
