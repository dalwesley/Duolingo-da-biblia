import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/trail.dart';
import '../theme/app_theme.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'stage_plate.dart';
import 'ui_primitives.dart';

/// Player dos micro-atos — palco direto no fundo, sem card.
class _ActSkin {
  static const radius = 18.0;
  static const gap = AppSpace.sm;
  static const verseSize = 22.0;
  static const noteSize = 16.0;
  static const pad = EdgeInsets.fromLTRB(14, 14, 16, 14);
  static const anim = Duration(milliseconds: 180);
  static const enter = Duration(milliseconds: 240);

  static const plateShadow = [
    BoxShadow(
      color: Color(0x59000000),
      blurRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  static Color ivory(Color accent) =>
      Color.lerp(AppColors.card, accent, 0.16)!;

  static ({
    Color fill,
    Color border,
    Color well,
    Color wellFg,
    Color text,
    bool hot,
  })
  paint(_OptState state, Color accent) {
    final ivory = _ActSkin.ivory(accent);
    final ink = AppColors.inkOnAccent;
    return switch (state) {
      _OptState.correct || _OptState.picked => (
        fill: accent,
        border: accent,
        well: ink,
        wellFg: accent,
        text: ink,
        hot: true,
      ),
      _OptState.wrong => (
        fill: AppColors.error.withValues(alpha: 0.92),
        border: AppColors.error,
        well: AppColors.textOnDark,
        wellFg: AppColors.error,
        text: AppColors.textOnDark,
        hot: true,
      ),
      _OptState.dimmed => (
        fill: ivory.withValues(alpha: 0.45),
        border: ivory.withValues(alpha: 0.45),
        well: Colors.transparent,
        wellFg: ink.withValues(alpha: 0.35),
        text: ink.withValues(alpha: 0.38),
        hot: false,
      ),
      _OptState.idle => (
        fill: ivory,
        border: ivory,
        well: Colors.transparent,
        wellFg: accent,
        text: ink,
        hot: false,
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
  final int index;
  final int total;
  final String? insightFallback;
  final String? boardText;
  final String? boardRef;

  final VoidCallback? onResolvedContinue;

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
    this.insightFallback,
    this.boardText,
    this.boardRef,
    this.onResolvedContinue,
  });

  @override
  State<ExercisePanel> createState() => _ExercisePanelState();
}

class _ExercisePanelState extends State<ExercisePanel>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _pulse;
  String? _picked;
  String? _matchLeft;
  bool _confirming = false;
  final Map<String, String> _pairs = {};
  late List<QuestionOption> _shuffledOrderItems;

  bool get _lit => widget.isCorrect == true;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: _ActSkin.enter)
      ..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _resetLocal();
  }

  @override
  void didUpdateWidget(covariant ExercisePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id) {
      _picked = null;
      _resetLocal();
      _enter.forward(from: 0);
    } else if (oldWidget.selected != null && widget.selected == null) {
      // Erro: o pai limpou a seleção para nova tentativa — solta o CTA.
      _picked = null;
      _resetLocal();
    }
    if (widget.selected != null && widget.selected != _picked) {
      _picked = widget.selected;
    }
    if (widget.showFeedback || widget.selected != null) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  void _resetLocal() {
    _confirming = false;
    _matchLeft = null;
    _pairs.clear();
    final items = List<QuestionOption>.from(widget.exercise.effectiveOptions);
    items.shuffle();
    _shuffledOrderItems = items;
    _pulse
      ..stop()
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _enter.dispose();
    _pulse.dispose();
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
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  bool get _locked =>
      _confirming ||
      widget.showFeedback ||
      widget.selected != null ||
      widget.outOfLamps;

  int get _matchNeed {
    final ex = widget.exercise;
    final left = ex.matchLeft.isNotEmpty ? ex.matchLeft : ex.effectiveOptions;
    return left.length;
  }

  void _submit(String answer) {
    if (_locked) return;
    ActHaptics.confirm();
    setState(() => _confirming = true);
    widget.onSelect(answer);
  }

  void _pickChoice(String id) {
    if (_locked || widget.eliminatedIds.contains(id)) return;
    ActHaptics.tap();
    setState(() => _picked = id);
  }

  void _clearComplete() {
    if (_locked) return;
    ActHaptics.tap();
    setState(() => _picked = null);
  }

  void _confirmChoice() {
    if (_locked) return;
    if (widget.exercise.type == ExerciseType.order) {
      if (_shuffledOrderItems.length < 2) return;
      _submit(_shuffledOrderItems.map((o) => o.id).join(','));
      return;
    }
    if (widget.exercise.type == ExerciseType.match) {
      if (_pairs.isEmpty) return;
      final ans = _pairs.entries.map((e) => '${e.key}:${e.value}').join(',');
      _submit(ans);
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

    final canConfirm = switch (ex.type) {
      ExerciseType.order => !_locked && _shuffledOrderItems.length >= 2,
      ExerciseType.match => !_locked && _pairs.length >= _matchNeed,
      _ => _picked != null && !_locked,
    };
    final options = ex.effectiveOptions;
    final palco = _fieldHero(ex);
    final below = _responseSurface(ex, options);
    final showFooter = _showFooter(ex);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.sm,
        AppSpace.screen,
        AppSpace.sm,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _in(
                0,
                0.42,
                _GestureSeal(
                  title: ex.displayCue.trim().isNotEmpty
                      ? ex.displayCue
                      : ex.instructionTitle,
                  instructionTitle: ex.instructionTitle,
                  label: ex.taskPromptLabel,
                  isPrompt: ex.showsStagePrompt,
                  accent: widget.accent,
                ),
              ),
              if (_showNote(ex)) ...[
                const SizedBox(height: AppSpace.md),
                _in(
                  0.1,
                  0.6,
                  _ContextNote(
                    label: (ex.noteLabel ?? 'Contexto').trim(),
                    text: ex.note!.trim(),
                    accent: widget.accent,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (palco != null)
                Expanded(child: _in(0.12, 0.72, SizedBox.expand(child: palco)))
              else
                const Spacer(),
              if (below.isNotEmpty) ...[
                const SizedBox(height: 12),
                _in(
                  0.35,
                  1,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: below,
                  ),
                ),
              ],
              if (showFooter) ...[
                const SizedBox(height: 10),
                _in(0.55, 1, _footer(ex, canConfirm)),
              ],
            ],
          ),
          Positioned.fill(
            child: ActSparkBurst(
              active: widget.isCorrect == true,
              color: widget.accent,
            ),
          ),
        ],
      ),
    );
  }

  bool _showFooter(Exercise ex) {
    if (ex.type.isRevealOnly) return false;
    return true;
  }

  bool _showNote(Exercise ex) {
    final note = (ex.note ?? '').trim();
    if (note.isEmpty) return false;
    final label = (ex.noteLabel ?? '').toLowerCase();
    final beat = (ex.beat ?? '').toLowerCase();
    if (label.contains('revis') || beat.contains('revis')) return false;
    return true;
  }

  Widget? _fieldHero(Exercise ex) {
    switch (ex.type) {
      case ExerciseType.trueFalse:
      case ExerciseType.choice:
      case ExerciseType.textSupported:
      case ExerciseType.bestInterpretation:
        return _witnessPalco(ex);
      case ExerciseType.complete:
      case ExerciseType.tap when ex.usesCompletePalco:
        return _clozePalco(ex);
      case ExerciseType.connect:
      case ExerciseType.tap when ex.passageA != null || ex.passageB != null:
        final id = widget.selected ?? _picked;
        return _BridgePassages(
          passageA: ex.passageA,
          passageB: ex.passageB,
          accent: widget.accent,
          lit: _lit,
          fill: true,
          picked: id == null
              ? null
              : ex.effectiveOptions
                    .where((o) => o.id == id)
                    .map((o) => o.text)
                    .firstOrNull,
          expected: ex.correctOptionText ?? 'ponte',
          state: id == null ? _OptState.idle : _state(id),
          pulse: _pulse,
          onClear: _locked ? null : _clearComplete,
        );
      case ExerciseType.tap:
      case ExerciseType.findInText:
        final text = (ex.passageText ?? '').trim();
        if (text.isNotEmpty && ex.prefersVerseTap) {
          return _PassageBlock(
            text: text,
            accent: widget.accent,
            reference: _witnessRef(ex),
            exercise: ex,
            locked: _locked,
            lit: _lit,
            fill: true,
            onPick: _locked ? null : _pickChoice,
            stateFor: _state,
          );
        }
        return _witnessFromBoard();
      case ExerciseType.order:
        return _witnessPalco(ex);
      case ExerciseType.match:
        return _Manuscript(
          accent: widget.accent,
          lit: _lit,
          fill: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _matchBody(ex),
          ),
        );
      default:
        return null;
    }
  }

  Widget? _clozePalco(Exercise ex) {
    final tpl = (ex.clozeStageText(fallbackPassage: widget.boardText) ?? '')
        .trim();
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
      expected: ex.correctOptionText,
      state: pickedId == null ? _OptState.idle : _state(pickedId),
      accent: widget.accent,
      reference: _witnessRef(ex),
      pulse: _pulse,
      lit: _lit,
      fill: true,
      onClear: _locked ? null : _clearComplete,
    );
  }

  String? _witnessRef(Exercise ex) {
    final own = (ex.reference ?? '').trim();
    if (own.isNotEmpty) return own;
    final board = (widget.boardRef ?? '').trim();
    return board.isEmpty ? null : board;
  }

  Widget? _witnessFromBoard() {
    final board = (widget.boardText ?? '').trim();
    if (board.isEmpty) return null;
    return _PassageBlock(
      text: board,
      accent: widget.accent,
      reference: _witnessRef(widget.exercise),
      lit: _lit,
      fill: true,
    );
  }

  Widget? _witnessPalco(Exercise ex) {
    final text = ex.stageWitness(fallback: widget.boardText);
    if (text == null) return null;
    return _PassageBlock(
      text: text,
      accent: widget.accent,
      reference: _witnessRef(ex),
      framed: true,
      fill: true,
      lit: _lit,
    );
  }

  List<Widget> _responseSurface(Exercise ex, List<QuestionOption> options) {
    switch (ex.type) {
      case ExerciseType.trueFalse:
        return [
          Row(
            children: [
              Expanded(
                child: _VfSlab(
                  label: 'Verdadeiro',
                  mark: 'V',
                  state: _state('true'),
                  accent: widget.accent,
                  onTap: _locked ? null : () => _pickChoice('true'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VfSlab(
                  label: 'Falso',
                  mark: 'F',
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
        if (ex.usesCompletePalco) {
          return _chipBank(ex.effectiveOptions, occupyVerse: true);
        }
        if (ex.prefersVerseTap) return const [];
        return _chipBank(ex.effectiveOptions);
      case ExerciseType.connect:
        return _chipBank(ex.effectiveOptions, occupyVerse: true);
      case ExerciseType.order:
        return [_orderList()];
      case ExerciseType.match:
        return const [];
      case ExerciseType.complete:
        return _chipBank(options, occupyVerse: true);
      default:
        return _optionBank(options);
    }
  }

  Widget _tileFor(QuestionOption o) {
    final eliminated = widget.eliminatedIds.contains(o.id);
    return Opacity(
      opacity: eliminated ? 0.38 : 1,
      child: _OptionTile(
        mark: o.id.length <= 2 ? o.id.toUpperCase() : null,
        text: o.text,
        state: eliminated ? _OptState.dimmed : _state(o.id),
        accent: widget.accent,
        struck: eliminated,
        onTap: eliminated ? null : () => _pickChoice(o.id),
      ),
    );
  }

  Widget _bankChip(QuestionOption o, {bool fill = false}) {
    final eliminated = widget.eliminatedIds.contains(o.id);
    final state = eliminated ? _OptState.dimmed : _state(o.id);
    return _WordChip(
      label: o.text,
      state: state,
      accent: widget.accent,
      fill: fill,
      onTap: eliminated
          ? null
          : () {
              if (state == _OptState.picked) {
                _clearComplete();
              } else {
                _pickChoice(o.id);
              }
            },
    );
  }

  Widget _slabRow(List<QuestionOption> slice) {
    return Row(
      children: [
        for (var i = 0; i < slice.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _bankChip(slice[i], fill: true)),
        ],
      ],
    );
  }

  List<Widget> _chipBank(
    List<QuestionOption> options, {
    bool occupyVerse = false,
  }) {
    if (options.isEmpty) return const [];
    final short = options.every((o) {
      final t = o.text.trim();
      return t.length <= 22 && !t.contains(' ');
    });
    if (!short && !occupyVerse) {
      return [
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == options.length - 1 ? 0 : 10),
            child: _tileFor(options[i]),
          ),
      ];
    }
    // 2–4 peças: partilham a faixa. Frases da ponte empilham em laje cheia.
    final n = options.length;
    if (n >= 2 && n <= 3) {
      if (short) return [_slabRow(options)];
      return [
        Column(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _bankChip(options[i], fill: true),
            ],
          ],
        ),
      ];
    }
    if (n == 4) {
      return [
        Column(
          children: [
            _slabRow(options.sublist(0, 2)),
            const SizedBox(height: 10),
            _slabRow(options.sublist(2)),
          ],
        ),
      ];
    }
    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [for (final o in options) _bankChip(o)],
      ),
    ];
  }

  List<Widget> _optionBank(List<QuestionOption> options) {
    if (options.isEmpty) return const [];
    return [
      for (var i = 0; i < options.length; i++)
        Padding(
          padding: EdgeInsets.only(bottom: i == options.length - 1 ? 0 : 10),
          child: _tileFor(options[i]),
        ),
    ];
  }

  Widget _orderList() {
    final pool = _shuffledOrderItems;
    final railColor = _locked && widget.isCorrect == false
        ? AppColors.error
        : widget.accent;
    return ReorderableListView.builder(
      itemCount: pool.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      padding: EdgeInsets.zero,
      proxyDecorator: (child, index, animation) =>
          ActDragProxy(animation: animation, child: child),
      onReorderStart: (_) {
        if (!_locked) ActHaptics.tick();
      },
      onReorderEnd: (_) {
        if (!_locked) ActHaptics.confirm();
      },
      onReorderItem: (oldIndex, newIndex) {
        if (_locked) return;
        setState(() {
          final item = _shuffledOrderItems.removeAt(oldIndex);
          _shuffledOrderItems.insert(newIndex, item);
        });
      },
      itemBuilder: (context, i) {
        return Padding(
          key: ValueKey(pool[i].id),
          padding: EdgeInsets.only(bottom: i == pool.length - 1 ? 0 : 10),
          child: ReorderableDragStartListener(
            index: i,
            enabled: !_locked,
            child: ActShake(
              active: _locked && widget.isCorrect == false,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OrderTick(
                      first: i == 0,
                      last: i == pool.length - 1,
                      color: railColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _OrderPiece(
                        index: i,
                        text: pool[i].text,
                        accent: widget.accent,
                        locked: _locked,
                        state: _locked ? _state(pool[i].id) : _OptState.idle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _matchBody(Exercise ex) {
    final left = ex.matchLeft.isNotEmpty ? ex.matchLeft : ex.effectiveOptions;
    final right = ex.matchRight;
    return [
      _MatchStepper(pickingLeft: _matchLeft == null, accent: widget.accent),
      const SizedBox(height: AppSpace.md),
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
                              ActHaptics.tap();
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
                              ActHaptics.tap();
                              setState(() {
                                _pairs[_matchLeft!] = right[i].id;
                                _matchLeft = null;
                              });
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
    final hintAvailable = widget.onHint != null && ex.supportsHint;
    final waiting = _confirming || widget.selected != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hintAvailable)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: widget.hintUsed || _locked ? null : widget.onHint,
              child: Text(
                widget.hintUsed ? 'Dica usada' : 'Dica',
                style: AppTypography.body(
                  size: 13,
                  color: widget.hintUsed || _locked
                      ? AppColors.textOnDark.withValues(alpha: 0.35)
                      : widget.accent,
                ),
              ),
            ),
          ),
        CopperCta(
          label: 'Continuar',
          onTap: canConfirm && !waiting ? _confirmChoice : null,
          busy: waiting,
          trailing: null,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        ),
      ],
    );
  }

  _OptState _state(String id) {
    final resolved = widget.selected != null && widget.isCorrect != null;
    if (resolved) {
      if (widget.exercise.type == ExerciseType.order ||
          widget.exercise.type == ExerciseType.match) {
        return widget.isCorrect == true ? _OptState.correct : _OptState.wrong;
      }
      final picked = id == widget.selected;
      if (widget.isCorrect == true) {
        return picked ? _OptState.correct : _OptState.dimmed;
      }
      // Erro + retry: não acender a certa. A faixa já explica o quase.
      return picked ? _OptState.wrong : _OptState.idle;
    }
    if (_picked == id) return _OptState.picked;
    return _OptState.idle;
  }
}

TextStyle _verseWordStyle({
  Color? color,
  FontWeight weight = FontWeight.w600,
  double height = 1.55,
}) => AppTypography.verse(
  size: _ActSkin.verseSize,
  weight: weight,
  height: height,
  color: color ?? AppColors.textOnDark,
);

class _GestureSeal extends StatelessWidget {
  final String title;
  final String instructionTitle;
  final String label;
  final bool isPrompt;
  final Color accent;

  const _GestureSeal({
    required this.title,
    required this.instructionTitle,
    required this.label,
    required this.isPrompt,
    required this.accent,
  });

  CinematicGlyph get _glyph =>
      switch (instructionTitle.split(' ').first.toLowerCase()) {
        'julgue' => CinematicGlyph.scales,
        'toque' => CinematicGlyph.search,
        'escolha' => CinematicGlyph.target,
        'ordene' => CinematicGlyph.path,
        'complete' => CinematicGlyph.spark,
        'conecte' => CinematicGlyph.chain,
        _ => CinematicGlyph.book,
      };

  @override
  Widget build(BuildContext context) {
    final cue = title.trim();
    return Row(
      crossAxisAlignment: isPrompt
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isPrompt ? 2 : 0),
          child: CinematicIcon(
            glyph: _glyph,
            size: 22,
            accent: accent,
            framed: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: isPrompt
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: AppTypography.label(
                        size: 11,
                        letterSpacing: 1.8,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cue,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(
                        size: 22,
                        height: 1.28,
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ],
                )
              : Text(
                  cue.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(
                    size: 18,
                    color: AppColors.textOnDark,
                  ).copyWith(letterSpacing: 1.4),
                ),
        ),
      ],
    );
  }
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

class _RefLabel extends StatelessWidget {
  final String reference;
  final Color accent;

  const _RefLabel({required this.reference, required this.accent});

  @override
  Widget build(BuildContext context) {
    final ref = reference.trim();
    if (ref.isEmpty) return const SizedBox.shrink();
    return Text(
      ref.toUpperCase(),
      textAlign: TextAlign.center,
      style: AppTypography.label(size: 13, letterSpacing: 1.8, color: accent),
    );
  }
}

class _Manuscript extends StatelessWidget {
  final Color accent;
  final Widget child;
  final String? reference;
  final bool framed;
  final bool fill;
  final bool lit;

  const _Manuscript({
    required this.accent,
    required this.child,
    this.reference,
    this.framed = false,
    this.fill = false,
    this.lit = false,
  });

  BoxDecoration get _plate =>
      StagePlate.decoration(accent: accent, lit: lit);

  Widget _filledStage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = (reference ?? '').trim();

    if (!fill) {
      final content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ref.isNotEmpty) ...[
            _RefLabel(reference: ref, accent: accent),
            const SizedBox(height: 14),
          ],
          child,
        ],
      );
      final plate = framed
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              decoration: _plate,
              clipBehavior: Clip.none,
              child: content,
            )
          : content;
      return LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.maxHeight.isFinite) return plate;
          return CustomScrollView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            slivers: [SliverToBoxAdapter(child: plate)],
          );
        },
      );
    }

    final stage = _filledStage();

    if (framed) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        decoration: _plate,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ref.isNotEmpty) ...[
              _RefLabel(reference: ref, accent: accent),
              const SizedBox(height: 14),
            ],
            Expanded(child: stage),
          ],
        ),
      );
    }

    if (ref.isEmpty) return stage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RefLabel(reference: ref, accent: accent),
        const SizedBox(height: 14),
        Expanded(child: stage),
      ],
    );
  }
}

class _CompleteVerse extends StatelessWidget {
  final String template;
  final String? filled;
  final String? expected;
  final _OptState state;
  final Color accent;
  final String? reference;
  final AnimationController pulse;
  final VoidCallback? onClear;
  final bool lit;
  final bool fill;

  const _CompleteVerse({
    required this.template,
    required this.filled,
    required this.state,
    required this.accent,
    required this.pulse,
    this.expected,
    this.reference,
    this.onClear,
    this.lit = false,
    this.fill = false,
  });

  static final _blank = RegExp(r'_{3,}');

  @override
  Widget build(BuildContext context) {
    final match = _blank.firstMatch(template);
    final last = _blank.allMatches(template).lastOrNull;
    final hasBlank = match != null && last != null;
    final before = hasBlank ? template.substring(0, match.start) : template;
    final after = hasBlank ? template.substring(last.end) : '';
    final style = _verseWordStyle();

    return _Manuscript(
      accent: accent,
      reference: reference,
      framed: true,
      fill: fill,
      lit: lit,
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            if (before.isNotEmpty) TextSpan(text: before),
            if (hasBlank)
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: ActShake(
                  active: state == _OptState.wrong,
                  child: _BlankGap(
                    filled: filled,
                    expected: expected ?? filled ?? 'palavra',
                    state: state,
                    accent: accent,
                    pulse: pulse,
                    onClear: onClear,
                  ),
                ),
              ),
            if (after.isNotEmpty) TextSpan(text: after),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _BlankGap extends StatelessWidget {
  final String? filled;
  final String expected;
  final _OptState state;
  final Color accent;
  final AnimationController pulse;
  final VoidCallback? onClear;

  const _BlankGap({
    required this.filled,
    required this.expected,
    required this.state,
    required this.accent,
    required this.pulse,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final has = (filled ?? '').trim().isNotEmpty;
    final probeStyle = _verseWordStyle(weight: FontWeight.w700);
    final probe = TextPainter(
      text: TextSpan(text: has ? filled! : expected, style: probeStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final minW = math.min(260.0, math.max(72.0, probe.width + 8));

    if (has && state == _OptState.wrong) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filled!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: probeStyle
                  .copyWith(color: AppColors.error, height: 1.25)
                  .copyWith(decoration: TextDecoration.lineThrough),
            ),
            Text(
              expected,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _verseWordStyle(color: accent, weight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    if (has) {
      return GestureDetector(
        onTap: onClear,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Text(
            filled!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _verseWordStyle(color: accent, weight: FontWeight.w700),
          ),
        ),
      );
    }

    final slot = SizedBox(
      width: minW,
      height: _ActSkin.verseSize * 1.5,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 3,
          width: minW,
          margin: const EdgeInsets.only(bottom: 3),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: [
              BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: 8),
            ],
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(pulse.value);
        return Opacity(opacity: 0.72 + t * 0.28, child: child);
      },
      child: slot,
    );
  }
}

class _BridgePassages extends StatelessWidget {
  final ExercisePassage? passageA;
  final ExercisePassage? passageB;
  final Color accent;
  final bool lit;
  final bool fill;
  final String? picked;
  final String expected;
  final _OptState state;
  final AnimationController pulse;
  final VoidCallback? onClear;

  const _BridgePassages({
    required this.accent,
    required this.pulse,
    required this.expected,
    required this.state,
    this.passageA,
    this.passageB,
    this.lit = false,
    this.fill = false,
    this.picked,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final caption = _connectCaption(passageA, passageB);
    return _Manuscript(
      accent: accent,
      framed: true,
      fill: fill,
      lit: lit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (passageA != null) _connectStanza(passageA!),
          if (passageA != null && passageB != null) ...[
            const SizedBox(height: 10),
            ActShake(
              active: state == _OptState.wrong,
              child: Center(
                child: _BlankGap(
                  filled: picked,
                  expected: expected,
                  state: state,
                  accent: accent,
                  pulse: pulse,
                  onClear: onClear,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (passageB != null) _connectStanza(passageB!),
          if (caption != null) ...[
            const SizedBox(height: 16),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: AppTypography.label(
                size: 11,
                letterSpacing: 1.2,
                color: accent.withValues(alpha: 0.72),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String? _connectCaption(ExercisePassage? a, ExercisePassage? b) {
  final refs = <String>[
    if (a != null) a.ref.trim(),
    if (b != null) b.ref.trim(),
  ].where((r) => r.isNotEmpty).toList();
  if (refs.isEmpty) return null;
  if (refs.length == 2 &&
      refs[0].toLowerCase() == refs[1].toLowerCase()) {
    return refs[0];
  }
  return refs.join('  ·  ');
}

Widget _connectStanza(ExercisePassage passage) {
  return Text(
    passage.text.trim(),
    textAlign: TextAlign.center,
    style: _verseWordStyle(height: 1.35),
  );
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.spark,
                size: 22,
                accent: accent,
                framed: false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'HOJE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(
                    size: 18,
                    color: AppColors.textOnDark,
                  ).copyWith(letterSpacing: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(AppColors.nightElevated, accent, 0.07)!,
                    AppColors.nightElevated.withValues(alpha: 0.92),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTypography.title(
                      size: 22,
                      height: 1.32,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          CopperCta(label: 'Seguir', onTap: onContinue, trailing: null),
          const SizedBox(height: AppSpace.lg),
        ],
      ),
    );
  }
}

enum _OptState { idle, picked, correct, wrong, dimmed }

class _PassageBlock extends StatelessWidget {
  final String text;
  final Color accent;
  final String? reference;
  final Exercise? exercise;
  final bool locked;
  final bool framed;
  final bool fill;
  final bool lit;
  final ValueChanged<String>? onPick;
  final _OptState Function(String id)? stateFor;

  const _PassageBlock({
    required this.text,
    required this.accent,
    this.reference,
    this.exercise,
    this.locked = false,
    this.framed = true,
    this.fill = false,
    this.lit = false,
    this.onPick,
    this.stateFor,
  });

  @override
  Widget build(BuildContext context) {
    final ex = exercise;
    final spans = ex == null
        ? const <TapSpan>[]
        : buildTapSpans(text, ex.effectiveOptions);
    final tappable = spans.any((s) => s.optionId != null);
    final style = _verseWordStyle(height: 1.45);

    return _Manuscript(
      accent: accent,
      reference: reference,
      framed: framed,
      fill: fill,
      lit: lit,
      child: tappable
          ? Text.rich(
              TextSpan(
                style: style,
                children: [
                  for (final span in spans)
                    if (span.optionId != null)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: ActShake(
                          active:
                              stateFor?.call(span.optionId!) == _OptState.wrong,
                          child: _PressScale(
                            onTap: locked || onPick == null
                                ? null
                                : () => onPick!(span.optionId!),
                            child: _VerseMark(
                              text: span.text,
                              state:
                                  stateFor?.call(span.optionId!) ??
                                  _OptState.idle,
                              accent: accent,
                            ),
                          ),
                        ),
                      )
                    else
                      TextSpan(text: span.text),
                ],
              ),
              textAlign: TextAlign.center,
            )
          : Text(text, textAlign: TextAlign.center, style: style),
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
          ? () {}
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

class _VerseMark extends StatelessWidget {
  final String text;
  final _OptState state;
  final Color accent;

  const _VerseMark({
    required this.text,
    required this.state,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final hot =
        state == _OptState.correct ||
        state == _OptState.picked ||
        state == _OptState.wrong;
    final color = switch (state) {
      _OptState.wrong => AppColors.error,
      _OptState.dimmed => AppColors.textOnDark.withValues(alpha: 0.38),
      _OptState.correct || _OptState.picked => accent,
      _OptState.idle => AppColors.textOnDark,
    };
    final wash = switch (state) {
      _OptState.wrong => color.withValues(alpha: 0.18),
      _OptState.dimmed => Colors.transparent,
      _OptState.correct || _OptState.picked => color.withValues(alpha: 0.28),
      _OptState.idle => Colors.transparent,
    };
    final underline = switch (state) {
      _OptState.idle => accent.withValues(alpha: 0.7),
      _OptState.dimmed => Colors.transparent,
      _ => color,
    };

    return AnimatedScale(
      scale: hot ? 1.04 : 1,
      duration: _ActSkin.anim,
      curve: Curves.easeOutCubic,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: wash,
          borderRadius: BorderRadius.circular(AppRadii.xs),
          border: Border(
            bottom: BorderSide(color: underline, width: hot ? 2.4 : 1.6),
          ),
          boxShadow: state == _OptState.correct || state == _OptState.picked
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.32),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 2, 5, 3),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: _verseWordStyle(
              color: color,
              weight: hot ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String label;
  final _OptState state;
  final Color accent;
  final VoidCallback? onTap;
  final bool fill;

  const _WordChip({
    required this.label,
    required this.state,
    required this.accent,
    this.onTap,
    this.fill = false,
  });

  @override
  Widget build(BuildContext context) {
    final skin = _ActSkin.paint(state, accent);
    final used = state == _OptState.dimmed;
    return ActShake(
      active: state == _OptState.wrong,
      child: ActPress(
        onTap: onTap,
        depth: 4,
        child: AnimatedOpacity(
          duration: _ActSkin.anim,
          opacity: used ? 0.38 : 1,
          child: AnimatedContainer(
            duration: _ActSkin.anim,
            curve: Curves.easeOutCubic,
            width: fill ? double.infinity : null,
            constraints: BoxConstraints(minHeight: fill ? 72 : 56),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_ActSkin.radius),
              color: skin.fill,
              boxShadow: _ActSkin.plateShadow,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(size: 15, color: skin.text),
            ),
          ),
        ),
      ),
    );
  }
}

class _VfSlab extends StatelessWidget {
  final String label;
  final String mark;
  final _OptState state;
  final Color accent;
  final VoidCallback? onTap;

  const _VfSlab({
    required this.label,
    required this.mark,
    required this.state,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final skin = _ActSkin.paint(state, accent);
    final wellBorder = state == _OptState.wrong
        ? AppColors.textOnDark
        : accent;

    return ActShake(
      active: state == _OptState.wrong,
      child: ActPress(
        onTap: onTap,
        depth: 4,
        child: AnimatedContainer(
          duration: _ActSkin.anim,
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 96),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_ActSkin.radius),
            color: skin.fill,
            boxShadow: _ActSkin.plateShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: _ActSkin.anim,
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: skin.well,
                  border: Border.all(
                    color: wellBorder,
                    width: skin.hot ? 0 : 1.6,
                  ),
                ),
                child: Text(
                  mark,
                  style: AppTypography.title(size: 14, color: skin.wellFg),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.title(size: 15, color: skin.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final _OptState state;
  final Color accent;
  final VoidCallback? onTap;
  final bool struck;
  final String? mark;

  const _OptionTile({
    required this.text,
    required this.state,
    required this.accent,
    this.onTap,
    this.struck = false,
    this.mark,
  });

  @override
  Widget build(BuildContext context) {
    final skin = _ActSkin.paint(state, accent);
    final wellBorder = state == _OptState.wrong
        ? AppColors.textOnDark
        : accent;
    return ActShake(
      active: state == _OptState.wrong,
      child: ActPress(
        onTap: onTap,
        depth: 4,
        child: AnimatedContainer(
          duration: _ActSkin.anim,
          curve: Curves.easeOutCubic,
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          alignment: Alignment.centerLeft,
          padding: _ActSkin.pad,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_ActSkin.radius),
            color: skin.fill,
            boxShadow: _ActSkin.plateShadow,
          ),
          child: Row(
            children: [
              if (mark != null) ...[
                AnimatedContainer(
                  duration: _ActSkin.anim,
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: skin.well,
                    border: Border.all(
                      color: wellBorder,
                      width: skin.hot ? 0 : 1.6,
                    ),
                  ),
                  child: Text(
                    mark!,
                    style: AppTypography.title(size: 13, color: skin.wellFg),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.start,
                  style:
                      AppTypography.title(
                        size: 15,
                        height: 1.3,
                        color: skin.text,
                      ).copyWith(
                        decoration: struck
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: skin.text,
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

class _OrderTick extends StatelessWidget {
  final bool first;
  final bool last;
  final Color color;

  const _OrderTick({
    required this.first,
    required this.last,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OrderTickPainter(first: first, last: last, color: color),
      child: const SizedBox(width: 14),
    );
  }
}

class _OrderTickPainter extends CustomPainter {
  final bool first;
  final bool last;
  final Color color;

  const _OrderTickPainter({
    required this.first,
    required this.last,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final line = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final dot = Paint()..color = color;
    final r = first || last ? 5.0 : 4.0;
    if (!first) canvas.drawLine(Offset(cx, 0), Offset(cx, cy), line);
    if (!last) canvas.drawLine(Offset(cx, cy), Offset(cx, size.height), line);
    canvas.drawCircle(Offset(cx, cy), r, dot);
  }

  @override
  bool shouldRepaint(covariant _OrderTickPainter old) =>
      old.first != first || old.last != last || old.color != color;
}

class _OrderPiece extends StatelessWidget {
  final int index;
  final String text;
  final Color accent;
  final bool locked;
  final _OptState state;

  const _OrderPiece({
    required this.index,
    required this.text,
    required this.accent,
    required this.locked,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final skin = _ActSkin.paint(state, accent);
    final wellBorder = state == _OptState.wrong
        ? AppColors.textOnDark
        : accent;
    return AnimatedContainer(
      duration: _ActSkin.anim,
      curve: Curves.easeOutCubic,
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_ActSkin.radius),
        color: skin.fill,
        boxShadow: _ActSkin.plateShadow,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: _ActSkin.anim,
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: skin.well,
              border: Border.all(color: wellBorder, width: skin.hot ? 0 : 1.6),
            ),
            child: Text(
              '${index + 1}',
              style: AppTypography.title(size: 13, color: skin.wellFg),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.title(
                size: 15,
                height: 1.3,
                color: skin.text,
              ),
            ),
          ),
          Icon(
            Icons.drag_indicator_rounded,
            size: 22,
            color: locked
                ? AppColors.inkOnAccent.withValues(alpha: 0.18)
                : accent.withValues(alpha: 0.85),
          ),
        ],
      ),
    );
  }
}

class _MatchStepper extends StatelessWidget {
  final bool pickingLeft;
  final Color accent;

  const _MatchStepper({required this.pickingLeft, required this.accent});

  @override
  Widget build(BuildContext context) {
    Widget step(int n, String label, bool on) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on ? accent : Colors.white.withValues(alpha: 0.08),
            ),
            child: Text(
              '$n',
              style: AppTypography.title(
                size: 11,
                color: on
                    ? AppColors.inkOnAccent
                    : AppColors.textOnDark.withValues(alpha: 0.45),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.8,
              color: on ? accent : AppColors.textOnDark.withValues(alpha: 0.4),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        step(1, 'Escolha', pickingLeft),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 18,
            height: 1,
            color: Colors.white.withValues(alpha: 0.16),
          ),
        ),
        step(2, 'Pareie', !pickingLeft),
      ],
    );
  }
}
