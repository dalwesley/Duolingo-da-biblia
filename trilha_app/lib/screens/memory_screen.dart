import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/memory_verses.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/top_bar.dart';

/// Memorização — flashcards com SRS leve (favoritos + catálogo).
class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  List<MemoryVerse> _deck = const [];
  int _index = 0;
  bool _revealed = false;
  bool _loading = true;
  int _known = 0;
  int _learning = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _load();
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
  }

  MemoryVerse get _current => _deck[_index];

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
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.night,
        body: Column(
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
                subtitle: 'Guarde a Palavra',
                onBack: () => Navigator.pop(context),
                leadingGlyph: CinematicGlyph.scroll,
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
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '${_index + 1} / ${_deck.length}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: a.textMuted(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: (_index + (_revealed ? 0.5 : 0)) /
                                  _deck.length,
                              minHeight: 5,
                              backgroundColor: Colors.white12,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1E2A24),
                                    Color(0xFF121816),
                                  ],
                                ),
                                border: Border.all(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                                boxShadow: AppTheme.glow(
                                  AppColors.accent,
                                  blur: 22,
                                ),
                              ),
                              child: Column(
                                children: [
                                  CinematicIcon(
                                    glyph: CinematicGlyph.scroll,
                                    size: 48,
                                    accent: AppColors.accent,
                                    glowing: true,
                                  ),
                            const SizedBox(height: 18),
                            Text(
                              _current.reference,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Expanded(
                              child: Center(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 220),
                                  opacity: _revealed ? 1 : 0.35,
                                  child: Text(
                                    _revealed
                                        ? _current.text
                                        : 'Toque para revelar o versículo',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: _revealed ? 22 : 16,
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: _revealed
                                          ? FontStyle.normal
                                          : FontStyle.italic,
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (!_revealed)
                              TextButton(
                                onPressed: () =>
                                    setState(() => _revealed = true),
                                child: const Text(
                                  'Revelar',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_revealed)
                      Row(
                        children: [
                          Expanded(
                            child: _ActionBtn(
                              label: 'Ainda não',
                              color: const Color(0xFFFF8C8C),
                              onTap: () => _answer(knew: false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionBtn(
                              label: 'Já sei',
                              color: AppColors.teal,
                              onTap: () => _answer(knew: true),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.7)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
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
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.spark,
            size: 72,
            glowing: true,
          ),
          const SizedBox(height: 20),
          Text(
            'Sessão concluída',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$known firmes · $learning em progresso',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: onAgain,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.inkOnAccent,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            child: const Text(
              'Treinar de novo',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          TextButton(
            onPressed: onClose,
            child: const Text(
              'Fechar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
