import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'act_feel.dart';
import 'brand_flip_card.dart';
import 'cinematic_icon.dart';
import 'stage_plate.dart';
import 'ui_primitives.dart';

/// Micro-modo (~20s): completar palavras do versículo — cena, alinhada ao estudo.
class VerseFillPanel extends StatefulWidget {
  final String reference;
  final String verseText;
  final Color accent;
  final ValueChanged<bool> onDone; // true = acertou

  const VerseFillPanel({
    super.key,
    required this.reference,
    required this.verseText,
    required this.accent,
    required this.onDone,
  });

  @override
  State<VerseFillPanel> createState() => _VerseFillPanelState();
}

class _VerseFillPanelState extends State<VerseFillPanel>
    with TickerProviderStateMixin {
  late final List<String> _words;
  late final List<int> _blankIndexes;
  late final List<String> _options;
  final Map<int, String?> _picked = {};
  bool _revealed = false;
  bool _correct = false;

  late final AnimationController _stagger;
  late final AnimationController _pulse;
  late final AnimationController _revealFlash;
  final Map<int, TapGestureRecognizer> _clearRecognizers = {};

  @override
  void initState() {
    super.initState();
    _words = _tokenizeVerse(widget.verseText);
    _blankIndexes = _pickBlanks(_words);
    _options = _buildOptions(_words, _blankIndexes);

    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _revealFlash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
  }

  /// Ellipsis de trecho → pontuação legível; preserva vírgulas/pontos nos tokens.
  static List<String> _tokenizeVerse(String raw) {
    var t = raw.trim();
    t = t.replaceAll(RegExp(r'[“”"]'), '');
    // Marcadores de excerto nas bordas (…texto… / .texto.)
    t = t.replaceAll(RegExp(r'^[\s.…]+'), '');
    t = t.replaceAll(RegExp(r'[\s.…]+$'), '');
    // "astuta… Disse" → "astuta. Disse"
    t = t.replaceAll(RegExp(r'\s*…\s*'), '. ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Evita ". ."
    t = t.replaceAll(RegExp(r'\.\s*\.'), '.');
    if (t.isNotEmpty && !RegExp(r'[.!?]$').hasMatch(t)) {
      t = '$t.';
    }
    return t.split(RegExp(r'\s+')).where((w) => w.trim().isNotEmpty).toList();
  }

  static String _trailingPunct(String w) {
    final m = RegExp(r'[^\wÀ-ÿ\-]+$').firstMatch(w);
    return m?.group(0) ?? '';
  }

  static String _leadingPunct(String w) {
    final m = RegExp(r'^[^\wÀ-ÿ\-]+').firstMatch(w);
    return m?.group(0) ?? '';
  }

  TapGestureRecognizer _clearRecognizer(int index) {
    return _clearRecognizers.putIfAbsent(
      index,
      () => TapGestureRecognizer()..onTap = () => _clearSlot(index),
    );
  }

  @override
  void dispose() {
    for (final recognizer in _clearRecognizers.values) {
      recognizer.dispose();
    }
    _stagger.dispose();
    _pulse.dispose();
    _revealFlash.dispose();
    super.dispose();
  }

  static List<int> _pickBlanks(List<String> words) {
    if (words.length < 3) return words.isEmpty ? const [] : [0];
    final stop = {
      'pois',
      'para',
      'como',
      'quando',
      'onde',
      'então',
      'entao',
      'dele',
      'dela',
      'eles',
      'elas',
      'este',
      'esta',
      'isso',
      'aqui',
      'ali',
      'seu',
      'sua',
      'seus',
      'suas',
      'pelo',
      'pela',
      'nos',
      'nas',
      'dos',
      'das',
    };
    final candidates = <int>[];
    for (var i = 0; i < words.length; i++) {
      final clean = _cleanWord(words[i]);
      if (clean.length < 4) continue;
      if (stop.contains(clean.toLowerCase())) continue;
      // Não blanka só pontuação
      if (clean.isEmpty) continue;
      candidates.add(i);
    }
    if (candidates.isEmpty) return [words.length ~/ 2];
    candidates.shuffle(math.Random(words.length * 17));
    final n = words.length >= 10 ? 3 : (words.length >= 6 ? 2 : 1);
    final picked = <int>[];
    for (final i in candidates) {
      if (picked.any((p) => (p - i).abs() < 2)) continue;
      picked.add(i);
      if (picked.length >= n) break;
    }
    if (picked.isEmpty) picked.add(candidates.first);
    picked.sort();
    return picked;
  }

  static List<String> _buildOptions(List<String> words, List<int> blanks) {
    final answers = [for (final i in blanks) _cleanWord(words[i])];
    final decoys = <String>[];
    final pool = words
        .map(_cleanWord)
        .where((w) => w.length >= 4 && !answers.contains(w))
        .toSet()
        .toList();
    pool.shuffle(math.Random(blanks.length + 3));
    for (final w in pool) {
      if (decoys.length >= answers.length) break;
      decoys.add(w);
    }
    const fillers = ['Senhor', 'Deus', 'palavra', 'caminho', 'coração', 'luz'];
    for (final f in fillers) {
      if (decoys.length >= answers.length) break;
      if (!answers.contains(f) && !decoys.contains(f)) decoys.add(f);
    }
    final all = [...answers, ...decoys]..shuffle(math.Random(42));
    return all;
  }

  static String _cleanWord(String w) => w.replaceAll(RegExp(r'[^\wÀ-ÿ\-]'), '');

  int? get _activeBlank {
    for (final i in _blankIndexes) {
      if (_picked[i] == null) return i;
    }
    return null;
  }

  int get _filledCount => _blankIndexes.where((i) => _picked[i] != null).length;

  void _select(String option) {
    if (_revealed) return;
    final nextBlank = _activeBlank;
    if (nextBlank == null) return;
    HapticFeedback.selectionClick();
    setState(() => _picked[nextBlank] = option);
    if (_blankIndexes.every((i) => _picked[i] != null)) {
      _submit();
    }
  }

  void _submit() {
    var ok = true;
    for (final i in _blankIndexes) {
      final expected = _cleanWord(_words[i]);
      final got = _picked[i] ?? '';
      if (got.toLowerCase() != expected.toLowerCase()) {
        ok = false;
        break;
      }
    }
    setState(() {
      _revealed = true;
      _correct = ok;
    });
    _pulse.stop();
    _revealFlash.forward(from: 0);
    if (ok) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _clearSlot(int index) {
    if (_revealed) return;
    HapticFeedback.selectionClick();
    setState(() => _picked.remove(index));
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final used = _picked.values.whereType<String>().toSet();
    final active = _activeBlank;

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final compact = h < 680;
        final tight = h < 580;
        final sidePad = tight ? AppSpace.md : AppSpace.screen;
        final gap = tight
            ? AppSpace.xs
            : compact
            ? AppSpace.sm
            : AppSpace.md;

        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _revealFlash,
              builder: (context, _) {
                if (!_revealed ||
                    _revealFlash.value <= 0 ||
                    _revealFlash.value >= 1) {
                  return const SizedBox.shrink();
                }
                final flashColor = _correct ? accent : AppColors.error;
                return IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.15),
                        radius: 1.15,
                        colors: [
                          flashColor.withValues(
                            alpha:
                                (1 - _revealFlash.value) *
                                (_correct ? 0.28 : 0.2),
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                sidePad,
                gap,
                sidePad,
                tight ? AppSpace.sm : AppSpace.section,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _stagger,
                      curve: const Interval(0, 0.35, curve: Curves.easeOut),
                    ),
                    child: _MemoryHeader(
                      accent: accent,
                      filled: _filledCount,
                      total: _blankIndexes.length,
                    ),
                  ),
                  SizedBox(height: gap),
                  Expanded(
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _stagger,
                        curve: const Interval(
                          0.12,
                          0.55,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: _VerseStage(
                        words: _words,
                        blankIndexes: _blankIndexes,
                        picked: _picked,
                        revealed: _revealed,
                        accent: accent,
                        reference: widget.reference,
                        activeBlank: active,
                        pulse: _pulse,
                        compact: compact,
                        onClear: _clearSlot,
                        clearRecognizer: _clearRecognizer,
                        cleanWord: _cleanWord,
                      ),
                    ),
                  ),
                  SizedBox(height: gap),
                  if (!_revealed)
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _stagger,
                        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
                      ),
                      child: Column(
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              for (var i = 0; i < _options.length; i++)
                                _WordChip(
                                  label: _options[i],
                                  used: used.contains(_options[i]),
                                  accent: accent,
                                  stagger: _stagger,
                                  index: i,
                                  onTap: used.contains(_options[i])
                                      ? () {
                                          final slot = _picked.entries
                                              .where(
                                                (e) => e.value == _options[i],
                                              )
                                              .map((e) => e.key)
                                              .firstOrNull;
                                          if (slot != null) _clearSlot(slot);
                                        }
                                      : () => _select(_options[i]),
                                ),
                            ],
                          ),
                          SizedBox(height: compact ? 4 : 8),
                          TextButton(
                            onPressed: () => widget.onDone(false),
                            child: Text(
                              'Pular',
                              style: AppTypography.body(
                                size: 13,
                                weight: FontWeight.w700,
                                color: AppColors.textOnDark.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _revealFlash,
                        curve: const Interval(0.25, 1, curve: Curves.easeOut),
                      ),
                      child: _RevealBanner(
                        correct: _correct,
                        accent: accent,
                        corrections: [
                          for (final i in _blankIndexes)
                            if ((_picked[i] ?? '').toLowerCase() !=
                                _cleanWord(_words[i]).toLowerCase())
                              (
                                got: _picked[i] ?? '—',
                                expected: _cleanWord(_words[i]),
                              ),
                        ],
                        onContinue: () => widget.onDone(_correct),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MemoryHeader extends StatelessWidget {
  final Color accent;
  final int filled;
  final int total;

  const _MemoryHeader({
    required this.accent,
    required this.filled,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: CinematicIcon(
            glyph: CinematicGlyph.spark,
            size: 22,
            accent: accent,
            framed: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PALAVRA',
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 1.8,
                  color: accent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Complete o versículo',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.title(
                  size: 22,
                  height: 1.28,
                  color: AppColors.textOnDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Row(
          children: [
            for (var i = 0; i < total; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: i < filled ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  color: i < filled
                      ? accent
                      : AppColors.textOnDark.withValues(alpha: 0.2),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _VerseStage extends StatelessWidget {
  final List<String> words;
  final List<int> blankIndexes;
  final Map<int, String?> picked;
  final bool revealed;
  final Color accent;
  final String reference;
  final int? activeBlank;
  final AnimationController pulse;
  final bool compact;
  final ValueChanged<int> onClear;
  final TapGestureRecognizer Function(int index) clearRecognizer;
  final String Function(String) cleanWord;

  const _VerseStage({
    required this.words,
    required this.blankIndexes,
    required this.picked,
    required this.revealed,
    required this.accent,
    required this.reference,
    required this.activeBlank,
    required this.pulse,
    required this.compact,
    required this.onClear,
    required this.clearRecognizer,
    required this.cleanWord,
  });

  InlineSpan _spanFor(int i, TextStyle verseStyle) {
    if (!blankIndexes.contains(i)) {
      return TextSpan(text: words[i]);
    }

    final token = words[i];
    final value = picked[i];
    final expected = cleanWord(token);
    final correct =
        revealed && (value?.toLowerCase() == expected.toLowerCase());
    final filled = value != null;
    final wrong = revealed && filled && !correct;

    // Palavra preenchida entra no mesmo recorte do versículo — mesma
    // família/peso/corpo; só a cor marca a lacuna.
    if (filled && !wrong) {
      final lead = _VerseFillPanelState._leadingPunct(token);
      final trail = _VerseFillPanelState._trailingPunct(token);
      return TextSpan(
        children: [
          if (lead.isNotEmpty) TextSpan(text: lead),
          TextSpan(
            text: value,
            style: verseStyle.copyWith(color: accent),
            recognizer: revealed ? null : clearRecognizer(i),
          ),
          if (trail.isNotEmpty) TextSpan(text: trail),
        ],
      );
    }

    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: _BlankToken(
        value: value,
        token: token,
        revealed: revealed,
        correct: correct,
        active: activeBlank == i && !revealed,
        accent: accent,
        pulse: pulse,
        verseStyle: verseStyle,
        onTap: () => onClear(i),
        cleanWord: cleanWord,
        leadingPunct: _VerseFillPanelState._leadingPunct,
        trailingPunct: _VerseFillPanelState._trailingPunct,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verseStyle = AppTypography.verse(
      size: compact ? 20 : 22,
      weight: FontWeight.w600,
      height: 1.55,
    );

    final chosen = [
      for (final index in blankIndexes)
        if (picked[index] != null) '$index:${picked[index]}',
    ].join('|');

    return BrandFlipCard(
      accent: accent,
      answer: chosen.isEmpty ? null : chosen,
      front: StagePlate(
        accent: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              reference.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTypography.label(
                size: 13,
                letterSpacing: 1.8,
                color: accent,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text.rich(
                    TextSpan(
                      style: verseStyle,
                      children: [
                        for (var i = 0; i < words.length; i++) ...[
                          if (i > 0) const TextSpan(text: ' '),
                          _spanFor(i, verseStyle),
                        ],
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlankToken extends StatelessWidget {
  final String? value;
  final String token;
  final bool revealed;
  final bool correct;
  final bool active;
  final Color accent;
  final AnimationController pulse;
  final TextStyle verseStyle;
  final VoidCallback onTap;
  final String Function(String) cleanWord;
  final String Function(String) leadingPunct;
  final String Function(String) trailingPunct;

  const _BlankToken({
    required this.value,
    required this.token,
    required this.revealed,
    required this.correct,
    required this.active,
    required this.accent,
    required this.pulse,
    required this.verseStyle,
    required this.onTap,
    required this.cleanWord,
    required this.leadingPunct,
    required this.trailingPunct,
  });

  @override
  Widget build(BuildContext context) {
    final expected = cleanWord(token);
    final lead = leadingPunct(token);
    final trail = trailingPunct(token);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (lead.isNotEmpty) Text(lead, style: verseStyle),
        _BlankSlot(
          value: value,
          expected: expected,
          revealed: revealed,
          correct: correct,
          active: active,
          accent: accent,
          pulse: pulse,
          verseStyle: verseStyle,
          onTap: onTap,
        ),
        if (trail.isNotEmpty) Text(trail, style: verseStyle),
      ],
    );
  }
}

class _BlankSlot extends StatelessWidget {
  final String? value;
  final String expected;
  final bool revealed;
  final bool correct;
  final bool active;
  final Color accent;
  final AnimationController pulse;
  final TextStyle verseStyle;
  final VoidCallback onTap;

  const _BlankSlot({
    required this.value,
    required this.expected,
    required this.revealed,
    required this.correct,
    required this.active,
    required this.accent,
    required this.pulse,
    required this.verseStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final filled = value != null;
    final fontSize = verseStyle.fontSize ?? 22;

    final probe = TextPainter(
      text: TextSpan(text: filled ? value! : expected, style: verseStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final minW = math.max(40.0, probe.width);

    Widget slot;
    if (!filled) {
      final lineColor = active
          ? accent
          : AppColors.textOnDark.withValues(alpha: 0.4);
      slot = SizedBox(
        width: minW,
        height: fontSize * 1.45,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: active ? 3 : 2.5,
            width: minW,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
        ),
      );
    } else if (revealed && !correct) {
      slot = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value!,
            style: verseStyle
                .copyWith(color: AppColors.error, height: 1.2)
                .copyWith(decoration: TextDecoration.lineThrough),
          ),
          Text(
            expected,
            style: verseStyle.copyWith(
              fontSize: fontSize * 0.85,
              height: 1.15,
              color: accent,
            ),
          ),
        ],
      );
    } else {
      slot = GestureDetector(
        onTap: revealed ? null : onTap,
        child: Text(value!, style: verseStyle.copyWith(color: accent)),
      );
    }

    if (!active || revealed || filled) return slot;

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(pulse.value);
        return Opacity(opacity: 0.75 + t * 0.25, child: child);
      },
      child: slot,
    );
  }
}

class _WordChip extends StatelessWidget {
  final String label;
  final bool used;
  final Color accent;
  final AnimationController stagger;
  final int index;
  final VoidCallback onTap;

  const _WordChip({
    required this.label,
    required this.used,
    required this.accent,
    required this.stagger,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final start = 0.42 + index * 0.07;
    final curve = CurvedAnimation(
      parent: stagger,
      curve: Interval(
        start.clamp(0.0, 0.9),
        (start + 0.35).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.1 + index * 0.015),
          end: Offset.zero,
        ).animate(curve),
        child: ActPress(
          onTap: onTap,
          depth: 4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: used ? accent : Color.lerp(AppColors.card, accent, 0.16)!,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x59000000),
                  blurRadius: 0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              label,
              style: AppTypography.title(
                size: 15,
                color: AppColors.inkOnAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RevealBanner extends StatelessWidget {
  final bool correct;
  final Color accent;
  final VoidCallback onContinue;
  final List<({String got, String expected})> corrections;

  const _RevealBanner({
    required this.correct,
    required this.accent,
    required this.onContinue,
    required this.corrections,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? accent : AppColors.error;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.lg,
            vertical: AppSpace.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              CinematicIcon(
                glyph: correct ? CinematicGlyph.check : CinematicGlyph.wrong,
                size: 22,
                accent: color,
                framed: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      correct ? 'Acertou!' : 'Errou!',
                      style: AppTypography.title(size: 18, color: color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      correct
                          ? '+2 passos'
                          : corrections.isEmpty
                          ? 'Veja a palavra certa'
                          : corrections
                                .map((c) => '${c.got} → ${c.expected}')
                                .join(' · '),
                      style: AppTypography.body(
                        size: 13,
                        weight: FontWeight.w700,
                        color: AppColors.textOnDark.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CopperCta(
          label: correct ? 'Seguir' : 'Continuar',
          onTap: onContinue,
          trailing: CinematicGlyph.forward,
        ),
      ],
    );
  }
}
