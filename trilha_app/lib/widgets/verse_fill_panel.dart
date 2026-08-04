import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';

/// Micro-modo (~20s): completar palavras faltando no versículo — cena, não quiz.
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

  @override
  void initState() {
    super.initState();
    _words = widget.verseText
        .replaceAll(RegExp(r'[“”"…]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();
    _blankIndexes = _pickBlanks(_words);
    _options = _buildOptions(_words, _blankIndexes);

    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
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

  @override
  void dispose() {
    _stagger.dispose();
    _pulse.dispose();
    _revealFlash.dispose();
    super.dispose();
  }

  static List<int> _pickBlanks(List<String> words) {
    if (words.length < 3) return words.isEmpty ? const [] : [0];
    final candidates = <int>[];
    for (var i = 0; i < words.length; i++) {
      final clean = words[i].replaceAll(RegExp(r'[^\wÀ-ÿ]'), '');
      if (clean.length >= 4) candidates.add(i);
    }
    if (candidates.isEmpty) {
      return [words.length ~/ 2];
    }
    candidates.shuffle(math.Random(words.length * 17));
    final n = words.length >= 10 ? 3 : (words.length >= 6 ? 2 : 1);
    final picked = candidates.take(n).toList()..sort();
    return picked;
  }

  static List<String> _buildOptions(List<String> words, List<int> blanks) {
    final answers = [
      for (final i in blanks) _cleanWord(words[i]),
    ];
    final decoys = <String>[];
    final pool = words
        .map(_cleanWord)
        .where((w) => w.length >= 3 && !answers.contains(w))
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

  static String _cleanWord(String w) =>
      w.replaceAll(RegExp(r'[^\wÀ-ÿ\-]'), '');

  int? get _activeBlank {
    for (final i in _blankIndexes) {
      if (_picked[i] == null) return i;
    }
    return null;
  }

  int get _filledCount =>
      _blankIndexes.where((i) => _picked[i] != null).length;

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
                            alpha: (1 - _revealFlash.value) *
                                (_correct ? 0.32 : 0.24),
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
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _stagger,
                          curve: const Interval(
                            0,
                            0.4,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      ),
                      child: _MemoryHeader(
                        accent: accent,
                        filled: _filledCount,
                        total: _blankIndexes.length,
                        compact: compact,
                      ),
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
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _stagger,
                            curve: const Interval(
                              0.12,
                              0.58,
                              curve: Curves.easeOutCubic,
                            ),
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
                          cleanWord: _cleanWord,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: gap),
                  if (!_revealed)
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _stagger,
                        curve: const Interval(
                          0.4,
                          0.9,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Toque na ordem · ~20s',
                            style: AppTypography.label(
                              size: 10,
                              letterSpacing: 1.2,
                              color: AppColors.textOnDark.withValues(
                                alpha: 0.42,
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 8 : 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              for (var i = 0; i < _options.length; i++)
                                _WordChip(
                                  label: _options[i],
                                  used: used.contains(_options[i]),
                                  accent: accent,
                                  enabled: !used.contains(_options[i]),
                                  stagger: _stagger,
                                  index: i,
                                  onTap: () => _select(_options[i]),
                                ),
                            ],
                          ),
                          SizedBox(height: compact ? 6 : 10),
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
  final bool compact;

  const _MemoryHeader({
    required this.accent,
    required this.filled,
    required this.total,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CinematicIcon(
              glyph: CinematicGlyph.heart,
              size: compact ? 16 : 18,
              accent: accent,
              framed: false,
            ),
            const SizedBox(width: 8),
            Text(
              'A palavra ecoa',
              style: AppTypography.display(
                size: compact ? 13 : 15,
                weight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                height: 1.2,
                color: AppColors.textOnDark.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 6 : 10),
        Text(
          'Completar o verso',
          textAlign: TextAlign.center,
          style: AppTypography.display(
            size: compact ? 22 : 26,
            weight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < total; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                width: i < filled ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  gradient: i < filled
                      ? LinearGradient(
                          colors: [
                            Color.lerp(accent, Colors.white, 0.35)!,
                            accent,
                          ],
                        )
                      : null,
                  color: i < filled
                      ? null
                      : AppColors.textOnDark.withValues(alpha: 0.18),
                  boxShadow: i < filled
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.45),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
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
    required this.cleanWord,
  });

  @override
  Widget build(BuildContext context) {
    final pad = compact ? AppSpace.md : AppSpace.lg;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          pad,
          pad,
          pad,
          compact ? AppSpace.md : AppSpace.section,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.05),
              Colors.black.withValues(alpha: 0.32),
            ],
          ),
          border: Border.all(
            color: AppColors.textOnDark.withValues(alpha: 0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.14),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              reference.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTypography.label(
                size: 11,
                letterSpacing: 1.4,
                color: accent,
              ),
            ),
            SizedBox(height: compact ? 8 : 12),
            Center(
              child: Container(
                width: 40,
                height: 1.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0),
                      accent.withValues(alpha: 0.9),
                      accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: compact ? 12 : 18),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: compact ? 10 : 14,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (var i = 0; i < words.length; i++)
                        if (blankIndexes.contains(i))
                          _BlankSlot(
                            value: picked[i],
                            ordinal: blankIndexes.indexOf(i) + 1,
                            revealed: revealed,
                            correct: revealed &&
                                (picked[i]?.toLowerCase() ==
                                    cleanWord(words[i]).toLowerCase()),
                            active: activeBlank == i && !revealed,
                            accent: accent,
                            pulse: pulse,
                            onTap: () => onClear(i),
                          )
                        else
                          Text(
                            words[i],
                            style: AppTypography.verse(
                              size: compact ? 18 : 21,
                              weight: FontWeight.w600,
                              height: 1.55,
                              color: AppColors.textOnDark.withValues(
                                alpha: 0.92,
                              ),
                            ),
                          ),
                    ],
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

class _BlankSlot extends StatelessWidget {
  final String? value;
  final int ordinal;
  final bool revealed;
  final bool correct;
  final bool active;
  final Color accent;
  final AnimationController pulse;
  final VoidCallback onTap;

  const _BlankSlot({
    required this.value,
    required this.ordinal,
    required this.revealed,
    required this.correct,
    required this.active,
    required this.accent,
    required this.pulse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final filled = value != null;
    final Color border;
    final Color fill;
    if (revealed) {
      border = correct ? accent : AppColors.error;
      fill = (correct ? accent : AppColors.error).withValues(alpha: 0.22);
    } else if (filled) {
      border = accent.withValues(alpha: 0.85);
      fill = accent.withValues(alpha: 0.18);
    } else if (active) {
      border = accent;
      fill = accent.withValues(alpha: 0.12);
    } else {
      border = AppColors.textOnDark.withValues(alpha: 0.22);
      fill = Colors.white.withValues(alpha: 0.05);
    }

    Widget chip = GestureDetector(
      onTap: filled && !revealed ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minWidth: 72),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: border,
            width: active || revealed || filled ? 1.7 : 1.2,
          ),
          boxShadow: [
            if (active || (filled && !revealed))
              BoxShadow(
                color: accent.withValues(alpha: active ? 0.4 : 0.22),
                blurRadius: active ? 16 : 10,
                offset: const Offset(0, 4),
              ),
            if (revealed && correct)
              BoxShadow(
                color: accent.withValues(alpha: 0.35),
                blurRadius: 14,
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!filled && !revealed) ...[
              Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (active ? accent : AppColors.textOnDark)
                      .withValues(alpha: active ? 0.9 : 0.2),
                ),
                child: Text(
                  '$ordinal',
                  style: AppTypography.label(
                    size: 9,
                    letterSpacing: 0,
                    color: active
                        ? AppColors.inkOnAccent
                        : AppColors.textOnDark.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              value ?? '····',
              style: AppTypography.verse(
                size: 18,
                weight: FontWeight.w700,
                color: filled
                    ? AppColors.textOnDark
                    : AppColors.textOnDark.withValues(
                        alpha: active ? 0.55 : 0.35,
                      ),
              ),
            ),
            if (revealed) ...[
              const SizedBox(width: 6),
              Icon(
                correct ? Icons.check_rounded : Icons.close_rounded,
                size: 16,
                color: correct ? accent : AppColors.error,
              ),
            ],
          ],
        ),
      ),
    );

    if (!active || revealed) return chip;

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(pulse.value);
        return Transform.scale(
          scale: 1 + t * 0.035,
          child: child,
        );
      },
      child: chip,
    );
  }
}

class _WordChip extends StatelessWidget {
  final String label;
  final bool used;
  final bool enabled;
  final Color accent;
  final AnimationController stagger;
  final int index;
  final VoidCallback onTap;

  const _WordChip({
    required this.label,
    required this.used,
    required this.enabled,
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
          begin: Offset(0, 0.12 + index * 0.02),
          end: Offset.zero,
        ).animate(curve),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: used ? 0.28 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  color: used
                      ? Colors.white.withValues(alpha: 0.04)
                      : Color.lerp(AppColors.night, accent, 0.12),
                  border: Border.all(
                    color: used
                        ? Colors.white.withValues(alpha: 0.08)
                        : accent.withValues(alpha: 0.55),
                    width: used ? 1 : 1.4,
                  ),
                  boxShadow: used
                      ? null
                      : [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Text(
                  label,
                  style: AppTypography.body(
                    size: 15,
                    weight: FontWeight.w800,
                    color: AppColors.textOnDark.withValues(
                      alpha: used ? 0.45 : 0.95,
                    ),
                  ),
                ),
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

  const _RevealBanner({
    required this.correct,
    required this.accent,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.lg,
            vertical: AppSpace.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: correct
                  ? [
                      accent.withValues(alpha: 0.22),
                      accent.withValues(alpha: 0.08),
                    ]
                  : [
                      AppColors.error.withValues(alpha: 0.18),
                      AppColors.sand.withValues(alpha: 0.08),
                    ],
            ),
            border: Border.all(
              color: (correct ? accent : AppColors.error).withValues(
                alpha: 0.45,
              ),
            ),
          ),
          child: Row(
            children: [
              CinematicIcon(
                glyph: correct ? CinematicGlyph.check : CinematicGlyph.echo,
                size: 22,
                accent: correct ? accent : AppColors.sand,
                framed: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      correct ? 'Combo de memória' : 'Quase — o verso fica',
                      style: AppTypography.title(
                        size: 15,
                        color: correct ? accent : AppColors.sand,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      correct
                          ? '+2 passos na trilha'
                          : 'A palavra ainda ecoa em você',
                      style: AppTypography.body(
                        size: 12,
                        color: AppColors.textOnDark.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onContinue,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              gradient: AppGradients.gold,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              correct ? 'SEGUIR' : 'CONTINUAR',
              textAlign: TextAlign.center,
              style: AppTypography.cta(size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
