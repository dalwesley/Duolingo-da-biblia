import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/trail.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'lamps_bar.dart';
import 'ui_primitives.dart';
import 'verse_study_sheet.dart';

/// Player dos micro-atos.
///
/// Palco = mesmo do bônus ([VerseFillPanel]): card nightElevated,
/// verso centralizado, palavra interativa em amarelo, chips embaixo.
class _ActSkin {
  static const radius = AppRadii.lg;
  static const gap = AppSpace.sm;
  static const afterChrome = AppSpace.lg;
  static const afterHero = AppSpace.md;
  static const cueSize = 24.0;
  static const verseSize = 22.0;
  static const noteSize = 16.0;
  static const badge = 32.0;
  static const pad = EdgeInsets.fromLTRB(14, 14, 16, 14);
  static const anim = Duration(milliseconds: 180);

  static ({
    Color fill,
    Color border,
    Color badge,
    Color badgeFg,
    Color text,
    bool hot,
  })
  paint(_OptState state, Color accent) {
    final hot =
        state == _OptState.picked ||
        state == _OptState.correct ||
        state == _OptState.wrong;
    return switch (state) {
      _OptState.correct => (
        fill: accent.withValues(alpha: 0.2),
        border: accent,
        badge: accent,
        badgeFg: AppColors.inkOnAccent,
        text: AppColors.textOnDark,
        hot: true,
      ),
      _OptState.wrong => (
        fill: AppColors.error.withValues(alpha: 0.16),
        border: AppColors.error.withValues(alpha: 0.9),
        badge: AppColors.error,
        badgeFg: Colors.white,
        text: AppColors.textOnDark,
        hot: true,
      ),
      _OptState.picked => (
        fill: accent.withValues(alpha: 0.14),
        border: accent.withValues(alpha: 0.9),
        badge: accent,
        badgeFg: AppColors.inkOnAccent,
        text: AppColors.textOnDark,
        hot: true,
      ),
      _OptState.dimmed => (
        fill: Colors.white.withValues(alpha: 0.03),
        border: Colors.white.withValues(alpha: 0.08),
        badge: Colors.white.withValues(alpha: 0.06),
        badgeFg: Colors.white.withValues(alpha: 0.3),
        text: Colors.white.withValues(alpha: 0.38),
        hot: false,
      ),
      _OptState.idle => (
        fill: Colors.white.withValues(alpha: 0.06),
        border: Colors.white.withValues(alpha: 0.12),
        badge: Colors.white.withValues(alpha: 0.1),
        badgeFg: Colors.white.withValues(alpha: 0.82),
        text: AppColors.textOnDark,
        hot: hot,
      ),
    };
  }
}

class ExercisePanel extends StatefulWidget {
  final Exercise exercise;
  final String? selected;
  final bool? isCorrect;
  final bool showFeedback;
  final ValueChanged<String> onSelect;
  final Color accent;
  final bool hintUsed;
  final Set<String> eliminatedIds;
  final VoidCallback? onHint;
  final bool outOfLamps;
  final int lamps;
  final int index;
  final int total;
  final String? insightFallback;

  const ExercisePanel({
    super.key,
    required this.exercise,
    required this.selected,
    required this.isCorrect,
    required this.showFeedback,
    required this.onSelect,
    required this.index,
    required this.total,
    this.accent = AppColors.accent,
    this.hintUsed = false,
    this.eliminatedIds = const {},
    this.onHint,
    this.outOfLamps = false,
    this.lamps = 5,
    this.insightFallback,
  });

  @override
  State<ExercisePanel> createState() => _ExercisePanelState();
}

class _ExercisePanelState extends State<ExercisePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  String? _picked;
  String? _matchLeft;
  final Map<String, String> _pairs = {};
  late List<QuestionOption> _shuffledOrderItems;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
    _resetLocal();
  }

  @override
  void didUpdateWidget(covariant ExercisePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id) {
      _picked = null;
      _resetLocal();
      _enter.forward(from: 0);
    }
    if (widget.selected != null && widget.selected != _picked) {
      _picked = widget.selected;
    }
  }

  void _resetLocal() {
    _matchLeft = null;
    _pairs.clear();
    final items = List<QuestionOption>.from(widget.exercise.effectiveOptions);
    items.shuffle();
    _shuffledOrderItems = items;
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Widget _in(double start, double end, Widget child) {
    final curve = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  bool get _locked =>
      widget.showFeedback || widget.selected != null || widget.outOfLamps;

  void _submit(String answer) {
    if (_locked) return;
    HapticFeedback.mediumImpact();
    widget.onSelect(answer);
  }

  void _pickChoice(String id) {
    if (_locked || widget.eliminatedIds.contains(id)) return;
    HapticFeedback.selectionClick();
    setState(() => _picked = id);
    final t = widget.exercise.type;
    if (t == ExerciseType.trueFalse ||
        t == ExerciseType.tap ||
        t == ExerciseType.findInText ||
        t == ExerciseType.complete ||
        t == ExerciseType.connect ||
        t == ExerciseType.choice ||
        t == ExerciseType.textSupported ||
        t == ExerciseType.bestInterpretation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _picked == id) _submit(id);
      });
    }
  }

  void _confirmChoice() {
    if (_locked) return;
    if (widget.exercise.type == ExerciseType.order) {
      if (_shuffledOrderItems.length < 2) return;
      _submit(_shuffledOrderItems.map((o) => o.id).join(','));
      return;
    }
    final id = _picked;
    if (id == null) return;
    _submit(id);
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    if (ex.type == ExerciseType.insight) {
      return _InsightView(
        text: ex.prompt.trim().isNotEmpty
            ? ex.prompt
            : (widget.insightFallback ?? ''),
        accent: widget.accent,
        onContinue: () => _submit('insight'),
      );
    }

    final canConfirm = ex.type == ExerciseType.order
        ? !_locked && _shuffledOrderItems.length >= 2
        : _picked != null && !_locked;
    final options = ex.effectiveOptions;
    final cue = ex.displayCue;
    // V/F: prompt é o palco — não repetir como pergunta.
    final showQuestion = cue.isNotEmpty &&
        !(ex.type == ExerciseType.trueFalse && cue == ex.prompt.trim());
    final questionIsLongChoice = showQuestion &&
        (ex.type == ExerciseType.choice ||
            ex.type == ExerciseType.textSupported ||
            ex.type == ExerciseType.bestInterpretation) &&
        cue.length > 72;

    final hero = _fieldHero(ex);
    final response = _responseSurface(ex, options);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.sm,
        AppSpace.screen,
        AppSpace.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _in(
            0,
            0.28,
            Text(
              ex.instructionVerb.toUpperCase(),
              style: AppTypography.label(
                size: 11,
                letterSpacing: 1.6,
                color: widget.accent,
              ),
            ),
          ),
          if (showQuestion) ...[
            const SizedBox(height: 8),
            _in(
              0.05,
              0.4,
              Text(
                cue,
                textAlign: TextAlign.left,
                style: questionIsLongChoice
                    ? AppTypography.body(
                        size: 18,
                        height: 1.28,
                        weight: FontWeight.w600,
                        color: AppColors.textOnDark,
                      )
                    : AppTypography.display(
                        size: _ActSkin.cueSize,
                        height: 1.22,
                      ),
              ),
            ),
          ],
          if (_showNote(ex)) ...[
            const SizedBox(height: AppSpace.md),
            _in(
              0.1,
              0.5,
              _ContextNote(
                label: (ex.noteLabel ?? 'Contexto').trim(),
                text: ex.note!.trim(),
                accent: widget.accent,
              ),
            ),
          ],
          const SizedBox(height: _ActSkin.afterChrome),
          if (hero != null)
            Expanded(child: _in(0.18, 0.62, hero))
          else if (response.isNotEmpty)
            Expanded(
              child: _in(
                0.28,
                0.78,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [const Spacer(), ...response, const Spacer()],
                ),
              ),
            )
          else
            const Spacer(),
          if (hero != null && response.isNotEmpty) ...[
            const SizedBox(height: _ActSkin.afterHero),
            _in(
              0.4,
              0.88,
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: response,
              ),
            ),
          ],
          const SizedBox(height: AppSpace.md),
          _in(0.55, 1, _footer(ex, canConfirm)),
        ],
      ),
    );
  }

  bool _showNote(Exercise ex) {
    final note = (ex.note ?? '').trim();
    if (note.isEmpty) return false;
    final label = (ex.noteLabel ?? '').toLowerCase();
    final beat = (ex.beat ?? '').toLowerCase();
    if (label.contains('revis') || beat.contains('revis')) return false;
    return true;
  }

  /// Campo herói: texto / afirmação / template — nunca o beat pedagógico.
  Widget? _fieldHero(Exercise ex) {
    switch (ex.type) {
      case ExerciseType.trueFalse:
        return _Manuscript(
          accent: widget.accent,
          child: Text(
            ex.prompt,
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 24, height: 1.35),
          ),
        );
      case ExerciseType.complete:
        final tpl = (ex.template ?? '').trim();
        if (tpl.isEmpty && ex.prompt.trim().isEmpty) return null;
        final pickedId = widget.selected ?? _picked;
        final filled = pickedId == null
            ? null
            : ex.effectiveOptions
                  .where((o) => o.id == pickedId)
                  .map((o) => o.text)
                  .firstOrNull;
        return _CompleteVerse(
          template: tpl.isNotEmpty ? tpl : ex.prompt,
          filled: filled,
          state: pickedId == null ? _OptState.idle : _state(pickedId),
          accent: widget.accent,
          reference: ex.reference,
        );
      case ExerciseType.connect:
      case ExerciseType.tap when ex.passageA != null || ex.passageB != null:
        return _BridgePassages(
          passageA: ex.passageA,
          passageB: ex.passageB,
          options: ex.effectiveOptions,
          stateFor: _state,
          accent: widget.accent,
          locked: _locked,
          eliminatedIds: widget.eliminatedIds,
          onTapOption: _pickChoice,
          highlightId: widget.showFeedback ? ex.resolvedCorrectAnswer : _picked,
        );
      case ExerciseType.tap:
      case ExerciseType.findInText:
        final text = (ex.passageText ?? '').trim();
        if (text.isEmpty) {
          if (ex.prompt.trim().isEmpty) return null;
          return _Manuscript(
            accent: widget.accent,
            child: Text(
              ex.prompt,
              style: AppTypography.display(size: 22, height: 1.28),
            ),
          );
        }
        return _TapPassageBlock(
          text: text,
          reference: ex.reference,
          options: ex.effectiveOptions,
          stateFor: _state,
          accent: widget.accent,
          locked: _locked,
          eliminatedIds: widget.eliminatedIds,
          onTapOption: _pickChoice,
        );
      case ExerciseType.choice:
      case ExerciseType.textSupported:
      case ExerciseType.bestInterpretation:
        final passage = (ex.passageText ?? '').trim();
        if (passage.isNotEmpty) {
          return _PassageBlock(
            text: passage,
            accent: widget.accent,
            reference: ex.reference,
          );
        }
        return null;
      case ExerciseType.order:
      case ExerciseType.match:
        return null;
      default:
        return null;
    }
  }

  List<Widget> _responseSurface(Exercise ex, List<QuestionOption> options) {
    switch (ex.type) {
      case ExerciseType.trueFalse:
        return [
          Row(
            children: [
              Expanded(
                child: _OptionTile(
                  letter: 'V',
                  text: 'Verdadeiro',
                  state: _state('true'),
                  accent: widget.accent,
                  onTap: _locked ? null : () => _pickChoice('true'),
                ),
              ),
              const SizedBox(width: _ActSkin.gap),
              Expanded(
                child: _OptionTile(
                  letter: 'F',
                  text: 'Falso',
                  state: _state('false'),
                  accent: widget.accent,
                  onTap: _locked ? null : () => _pickChoice('false'),
                ),
              ),
            ],
          ),
        ];
      case ExerciseType.tap:
      case ExerciseType.findInText:
      case ExerciseType.connect:
        return _tapChipsFallback(ex);
      case ExerciseType.order:
        return _orderBody(options);
      case ExerciseType.match:
        return _matchBody(ex);
      case ExerciseType.complete:
        return _optionBank(options);
      default:
        return _optionBank(options, stacked: !_hasVerseStage(ex));
    }
  }

  Widget _tileFor(QuestionOption o, int i) {
    final eliminated = widget.eliminatedIds.contains(o.id);
    return Opacity(
      opacity: eliminated ? 0.38 : 1,
      child: _OptionTile(
        letter: _kLetters[i.clamp(0, _kLetters.length - 1)],
        text: o.text,
        state: eliminated ? _OptState.dimmed : _state(o.id),
        accent: widget.accent,
        struck: eliminated,
        onTap: eliminated ? null : () => _pickChoice(o.id),
      ),
    );
  }

  bool _hasVerseStage(Exercise ex) {
    return (ex.passageText ?? '').trim().isNotEmpty ||
        (ex.template ?? '').trim().isNotEmpty ||
        ex.passageA != null ||
        ex.passageB != null;
  }

  List<Widget> _optionBank(List<QuestionOption> options, {bool stacked = false}) {
    if (options.isEmpty) return const [];
    if (stacked) {
      return [
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == options.length - 1 ? 0 : 8),
            child: _tileFor(options[i], i),
          ),
      ];
    }
    return [
      for (var i = 0; i < options.length; i += 2)
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 >= options.length ? 0 : 8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _tileFor(options[i], i)),
                const SizedBox(width: _ActSkin.gap),
                Expanded(
                  child: i + 1 < options.length
                      ? _tileFor(options[i + 1], i + 1)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  /// Chips só para opções que não entram no versículo (distratores).
  List<Widget> _tapChipsFallback(Exercise ex) {
    final corpus = [
      ex.passageA?.text ?? '',
      ex.passageB?.text ?? '',
      ex.passageText ?? '',
    ].join(' ');
    final hasInText =
        corpus.trim().isNotEmpty && ex.optionsEmbeddedIn(corpus).isNotEmpty;
    // Toque = resposta no texto. Distrator fora do trecho quebra o gesto.
    if (hasInText) return const [];
    final chips = ex.effectiveOptions;
    if (chips.isEmpty) return const [];
    return _optionBank(chips);
  }

  List<Widget> _orderBody(List<QuestionOption> options) {
    final pool = _shuffledOrderItems;
    return [
      ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        onReorderItem: (oldIndex, newIndex) {
          if (_locked) return;
          setState(() {
            final item = _shuffledOrderItems.removeAt(oldIndex);
            _shuffledOrderItems.insert(newIndex, item);
          });
          HapticFeedback.selectionClick();
        },
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final t = Curves.easeOut.transform(animation.value);
              return Transform.scale(
                scale: 1.03 + 0.02 * t,
                child: Material(
                  color: Colors.transparent,
                  elevation: 10 * t,
                  shadowColor: widget.accent.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(_ActSkin.radius),
                  child: child,
                ),
              );
            },
          );
        },
        children: [
          for (var i = 0; i < pool.length; i++)
            Padding(
              key: ValueKey(pool[i].id),
              padding: const EdgeInsets.only(bottom: 10),
              child: ReorderableDragStartListener(
                index: i,
                enabled: !_locked,
                child: _OptionTile(
                  letter: '${i + 1}',
                  text: pool[i].text,
                  state: _locked ? _state(pool[i].id) : _OptState.idle,
                  accent: widget.accent,
                  textAlign: TextAlign.center,
                  trailing: Icon(
                    Icons.drag_handle_rounded,
                    size: 22,
                    color: AppColors.textOnDark.withValues(alpha: 0.42),
                  ),
                ),
              ),
            ),
        ],
      ),
    ];
  }

  List<Widget> _matchBody(Exercise ex) {
    final left = ex.matchLeft.isNotEmpty ? ex.matchLeft : ex.effectiveOptions;
    final right = ex.matchRight;
    return [
      Text(
        _matchLeft == null
            ? 'Toque um item à esquerda'
            : 'Agora o par à direita',
        style: AppTypography.body(
          size: 12,
          color: AppColors.textOnDark.withValues(alpha: 0.55),
        ),
      ),
      const SizedBox(height: AppSpace.sm),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                for (var i = 0; i < left.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == left.length - 1 ? 0 : _ActSkin.gap,
                    ),
                    child: _OptionTile(
                      letter: _kLetters[i.clamp(0, _kLetters.length - 1)],
                      text: left[i].text,
                      state: _pairs.containsKey(left[i].id)
                          ? _OptState.correct
                          : (_matchLeft == left[i].id
                                ? _OptState.picked
                                : _OptState.idle),
                      accent: widget.accent,
                      onTap: _locked || _pairs.containsKey(left[i].id)
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              setState(() => _matchLeft = left[i].id);
                            },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                for (var i = 0; i < right.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == right.length - 1 ? 0 : _ActSkin.gap,
                    ),
                    child: _OptionTile(
                      letter: '${i + 1}',
                      text: right[i].text,
                      state: _pairs.containsValue(right[i].id)
                          ? _OptState.dimmed
                          : _OptState.idle,
                      accent: widget.accent,
                      onTap:
                          _locked ||
                              _matchLeft == null ||
                              _pairs.containsValue(right[i].id)
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _pairs[_matchLeft!] = right[i].id;
                                _matchLeft = null;
                              });
                              if (_pairs.length == left.length) {
                                final ans = _pairs.entries
                                    .map((e) => '${e.key}:${e.value}')
                                    .join(',');
                                _submit(ans);
                              }
                            },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  Widget _footer(Exercise ex, bool canConfirm) {
    final needsConfirm = ex.type == ExerciseType.order;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm, bottom: AppSpace.md),
      child: Row(
        children: [
          LampsBar(
            current: widget.lamps,
            max: 5,
            accent: widget.accent,
            compact: true,
          ),
          if (widget.onHint != null && ex.supportsHint && !_locked)
            TextButton(
              onPressed: widget.hintUsed ? null : widget.onHint,
              child: Text(
                widget.hintUsed ? 'Dica usada' : 'Dica',
                style: AppTypography.body(
                  size: 13,
                  color: widget.hintUsed
                      ? AppColors.textOnDark.withValues(alpha: 0.35)
                      : widget.accent,
                ),
              ),
            ),
          const Spacer(),
          if (needsConfirm)
            Opacity(
              opacity: canConfirm ? 1 : 0.45,
              child: CopperCta(
                label: 'Confirmar',
                onTap: canConfirm ? _confirmChoice : null,
                trailing: null,
                expanded: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  _OptState _state(String id) {
    if (widget.showFeedback && widget.selected != null) {
      final correct = widget.exercise.checkAnswer(widget.selected!);
      if (widget.exercise.type == ExerciseType.order ||
          widget.exercise.type == ExerciseType.match) {
        return correct ? _OptState.correct : _OptState.wrong;
      }
      if (id == widget.exercise.resolvedCorrectAnswer) return _OptState.correct;
      if (id == widget.selected) return _OptState.wrong;
      return _OptState.dimmed;
    }
    if (_picked == id) return _OptState.picked;
    return _OptState.idle;
  }
}

// ─── Passage / tap helpers ───────────────────────────────────────────────────

class _TapSpan {
  final String text;
  final String? optionId;
  const _TapSpan(this.text, [this.optionId]);
}

TextStyle _verseWordStyle({
  Color? color,
  FontWeight weight = FontWeight.w600,
}) => AppTypography.verse(
  size: _ActSkin.verseSize,
  weight: weight,
  height: 1.5,
  color: color ?? AppColors.textOnDark,
);

List<Widget> _verseWords(String text) {
  return [
    for (final w in text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty))
      Text(w, style: _verseWordStyle()),
  ];
}

List<_TapSpan> _buildTapSpans(String passage, List<QuestionOption> options) {
  if (passage.isEmpty) return const [];
  final sorted = List<QuestionOption>.from(
    options.where((o) => o.text.trim().isNotEmpty),
  )..sort((a, b) => b.text.length.compareTo(a.text.length));

  final lower = passage.toLowerCase();
  final hits = <({int start, int end, String id})>[];
  for (final o in sorted) {
    final needle = o.text.toLowerCase();
    var from = 0;
    while (true) {
      final i = lower.indexOf(needle, from);
      if (i < 0) break;
      final end = i + needle.length;
      final overlaps = hits.any((h) => i < h.end && end > h.start);
      if (!overlaps) {
        hits.add((start: i, end: end, id: o.id));
      }
      from = i + 1;
    }
  }
  hits.sort((a, b) => a.start.compareTo(b.start));

  final spans = <_TapSpan>[];
  var cursor = 0;
  for (final h in hits) {
    if (h.start > cursor) {
      spans.add(_TapSpan(passage.substring(cursor, h.start)));
    }
    spans.add(_TapSpan(passage.substring(h.start, h.end), h.id));
    cursor = h.end;
  }
  if (cursor < passage.length) {
    spans.add(_TapSpan(passage.substring(cursor)));
  }
  return spans;
}

class _ContextNote extends StatelessWidget {
  final String label;
  final String text;
  final Color accent;

  const _ContextNote({
    required this.label,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: accent.withValues(alpha: 0.35), height: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 1.8,
                  color: accent,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: accent.withValues(alpha: 0.35), height: 1),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: _ActSkin.noteSize,
            height: 1.45,
            weight: FontWeight.w600,
            color: AppColors.textOnDark.withValues(alpha: 0.82),
          ),
        ),
      ],
    );
  }
}

/// Referência tocável → sheet Strong (sem conflitar com toque de resposta no verso).
class _StudyRefChip extends StatelessWidget {
  final String reference;
  final Color accent;
  final bool compact;

  const _StudyRefChip({
    required this.reference,
    required this.accent,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final ref = reference.trim();
    if (ref.isEmpty) return const SizedBox.shrink();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: () {
            HapticFeedback.selectionClick();
            showVerseStudyFromReference(context, ref);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 12,
              vertical: compact ? 4 : 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ref,
                  style: AppTypography.label(
                    size: compact ? 11 : 11,
                    letterSpacing: compact ? 0.6 : 1.4,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ESTUDAR',
                  style: AppTypography.label(
                    size: 9,
                    letterSpacing: 1.2,
                    color: accent.withValues(alpha: 0.72),
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

class _Manuscript extends StatelessWidget {
  final Color accent;
  final Widget child;
  final String? reference;

  const _Manuscript({
    required this.accent,
    required this.child,
    this.reference,
  });

  @override
  Widget build(BuildContext context) {
    final ref = (reference ?? '').trim();
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.nightElevated.withValues(alpha: 0.72),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  if (ref.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _StudyRefChip(reference: ref, accent: accent),
                  ],
                  const SizedBox(height: 14),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(width: double.infinity, child: child),
                      ),
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

class _CompleteVerse extends StatelessWidget {
  final String template;
  final String? filled;
  final _OptState state;
  final Color accent;
  final String? reference;

  const _CompleteVerse({
    required this.template,
    required this.filled,
    required this.state,
    required this.accent,
    this.reference,
  });

  static final _blank = RegExp(r'_{3,}');

  @override
  Widget build(BuildContext context) {
    final match = _blank.firstMatch(template);
    final last = _blank.allMatches(template).lastOrNull;
    final hasBlank = match != null && last != null;
    final before = hasBlank ? template.substring(0, match.start) : template;
    final after = hasBlank ? template.substring(last.end) : '';

    return _Manuscript(
      accent: accent,
      reference: reference,
      child: Wrap(
        spacing: 5,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ..._verseWords(before),
          if (hasBlank)
            _VerseMark(
              text: filled ?? '',
              state: state,
              accent: accent,
              placeholder: true,
            ),
          ..._verseWords(after),
        ],
      ),
    );
  }
}

class _TapPassageBlock extends StatelessWidget {
  final String text;
  final String? reference;
  final List<QuestionOption> options;
  final _OptState Function(String id) stateFor;
  final Color accent;
  final bool locked;
  final Set<String> eliminatedIds;
  final ValueChanged<String> onTapOption;

  const _TapPassageBlock({
    required this.text,
    required this.options,
    required this.stateFor,
    required this.accent,
    required this.locked,
    required this.eliminatedIds,
    required this.onTapOption,
    this.reference,
  });

  @override
  Widget build(BuildContext context) {
    return _Manuscript(
      accent: accent,
      reference: reference,
      child: _TappableVerse(
        text: text,
        options: options,
        stateFor: stateFor,
        accent: accent,
        locked: locked,
        eliminatedIds: eliminatedIds,
        onTapOption: onTapOption,
      ),
    );
  }
}

class _BridgePassages extends StatelessWidget {
  final ExercisePassage? passageA;
  final ExercisePassage? passageB;
  final List<QuestionOption> options;
  final _OptState Function(String id) stateFor;
  final Color accent;
  final bool locked;
  final Set<String> eliminatedIds;
  final ValueChanged<String> onTapOption;
  final String? highlightId;

  const _BridgePassages({
    required this.options,
    required this.stateFor,
    required this.accent,
    required this.locked,
    required this.eliminatedIds,
    required this.onTapOption,
    this.passageA,
    this.passageB,
    this.highlightId,
  });

  Widget _verse(ExercisePassage passage) {
    final ref = passage.ref.trim();
    return Column(
      children: [
        if (ref.isNotEmpty) ...[
          _StudyRefChip(reference: ref, accent: accent, compact: true),
          const SizedBox(height: 12),
        ],
        _TappableVerse(
          text: passage.text,
          options: options,
          stateFor: stateFor,
          accent: accent,
          locked: locked,
          eliminatedIds: eliminatedIds,
          onTapOption: onTapOption,
          highlightId: highlightId,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Manuscript(
      accent: accent,
      child: Column(
        children: [
          if (passageA != null) _verse(passageA!),
          if (passageA != null && passageB != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.12),
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.12),
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          if (passageB != null) _verse(passageB!),
        ],
      ),
    );
  }
}

class _TappableVerse extends StatelessWidget {
  final String text;
  final List<QuestionOption> options;
  final _OptState Function(String id) stateFor;
  final Color accent;
  final bool locked;
  final Set<String> eliminatedIds;
  final ValueChanged<String> onTapOption;
  final String? highlightId;

  const _TappableVerse({
    required this.text,
    required this.options,
    required this.stateFor,
    required this.accent,
    required this.locked,
    required this.eliminatedIds,
    required this.onTapOption,
    this.highlightId,
  });

  @override
  Widget build(BuildContext context) {
    final spans = _buildTapSpans(text, options);
    final children = <Widget>[];
    for (final s in spans) {
      if (s.optionId == null) {
        children.addAll(_verseWords(s.text));
      } else {
        children.add(
          _VerseMark(
            text: s.text,
            state: eliminatedIds.contains(s.optionId)
                ? _OptState.dimmed
                : highlightId == s.optionId
                    ? _OptState.picked
                    : stateFor(s.optionId!),
            accent: accent,
            enabled: !locked && !eliminatedIds.contains(s.optionId),
            onTap: () => onTapOption(s.optionId!),
          ),
        );
      }
    }

    return Wrap(
      spacing: 5,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children.isEmpty ? _verseWords(text) : children,
    );
  }
}

class _VerseMark extends StatelessWidget {
  final String text;
  final _OptState state;
  final Color accent;
  final bool enabled;
  final VoidCallback? onTap;
  final bool placeholder;

  const _VerseMark({
    required this.text,
    required this.state,
    required this.accent,
    this.enabled = true,
    this.onTap,
    this.placeholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final filled = text.trim().isNotEmpty;
    final color = switch (state) {
      _OptState.wrong => AppColors.error,
      _OptState.dimmed => AppColors.textOnDark.withValues(alpha: 0.38),
      _OptState.correct || _OptState.picked => accent,
      _OptState.idle => accent,
    };

    if (placeholder && !filled) {
      return SizedBox(
        width: 96,
        height: _ActSkin.verseSize * 1.5,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 3,
            margin: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
        ),
      );
    }

    final child = Text(
      text,
      style: _verseWordStyle(color: color, weight: FontWeight.w700),
    );

    if (onTap == null) return child;
    return _PressScale(onTap: enabled ? onTap : null, child: child);
  }
}

class _InsightView extends StatelessWidget {
  final String text;
  final Color accent;
  final VoidCallback onContinue;

  const _InsightView({
    required this.text,
    required this.accent,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: Column(
        children: [
          const Spacer(flex: 2),
          CinematicIcon(
            glyph: CinematicGlyph.spark,
            size: 36,
            accent: accent,
            framed: false,
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              Expanded(
                child: Divider(color: accent.withValues(alpha: 0.4), height: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'HOJE',
                  style: AppTypography.label(
                    size: 12,
                    letterSpacing: 2.2,
                    color: accent,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: accent.withValues(alpha: 0.4), height: 1),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 26, height: 1.32),
          ),
          const Spacer(flex: 3),
          CopperCta(label: 'Seguir', onTap: onContinue),
          const SizedBox(height: AppSpace.lg),
        ],
      ),
    );
  }
}

enum _OptState { idle, picked, correct, wrong, dimmed }

const _kLetters = ['A', 'B', 'C', 'D', 'E', 'F'];

class _PassageBlock extends StatelessWidget {
  final String text;
  final Color accent;
  final String? reference;
  const _PassageBlock({
    required this.text,
    required this.accent,
    this.reference,
  });

  @override
  Widget build(BuildContext context) {
    return _Manuscript(
      accent: accent,
      reference: reference,
      child: Wrap(
        spacing: 5,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: _verseWords(text),
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressScale({required this.child, this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _down = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() => _down = false),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final _OptState state;
  final Color accent;
  final VoidCallback? onTap;
  final Widget? trailing;
  final TextAlign textAlign;
  final bool struck;

  const _OptionTile({
    required this.letter,
    required this.text,
    required this.state,
    required this.accent,
    this.onTap,
    this.trailing,
    this.textAlign = TextAlign.start,
    this.struck = false,
  });

  @override
  Widget build(BuildContext context) {
    final skin = _ActSkin.paint(state, accent);
    return _PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _ActSkin.anim,
        curve: Curves.easeOutCubic,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: _ActSkin.pad,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_ActSkin.radius),
          color: skin.fill,
          border: Border.all(color: skin.border, width: skin.hot ? 1.6 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: _ActSkin.badge,
              height: _ActSkin.badge,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: skin.badge,
              ),
              child: Text(
                letter,
                style: AppTypography.title(size: 13, color: skin.badgeFg),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                textAlign: textAlign,
                style: AppTypography.body(
                  size: 15,
                  height: 1.3,
                  weight: FontWeight.w700,
                  color: skin.text,
                ).copyWith(
                  decoration: struck
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: skin.text,
                ),
              ),
            ),
            if (trailing != null)
              SizedBox(width: _ActSkin.badge, child: trailing),
          ],
        ),
      ),
    );
  }
}
