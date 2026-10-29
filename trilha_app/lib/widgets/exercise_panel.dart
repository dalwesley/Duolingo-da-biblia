import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../l10n/app_language.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import 'act_feel.dart';
import 'anan_speech.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'stage_plate.dart';
import 'relic_panel.dart';
import 'ui_primitives.dart';

/// Player dos micro-atos — palco direto no fundo, sem card.
class _ActSkin {
  static const radius = AppRadii.xl;
  static const gap = AppSpace.sm;
  // Cormorant tem olho pequeno: 25 lê como ~21 num serifado comum.
  static const verseSize = 24.0; // degrau da escala de versículo
  // Abaixo disso o palco encolhido ganha a lupa.
  static const zoomBelow = 21.0;
  static const noteSize = 16.0;
  static const pad = EdgeInsets.fromLTRB(14, 14, 16, 14);
  static const anim = Duration(milliseconds: 180);
  static const enter = Duration(milliseconds: 240);

  static final plateShadow = AppLight.lip();

  /// Placa idle: segue o papel da aparência ([AppearanceStyle.stageFill]) —
  /// poço elevado no escuro, papel branco no Claro.
  static Color idleFill(AppearanceStyle a) => a.stageFill;
  static Color idleInk(AppearanceStyle a) => a.text;

  /// Seleção: branco no céu escuro; no papel claro (onde idle já é branco)
  /// um marfim quente. Acerto: ouro. Erro: vermelho.
  static Color selectedFill(AppearanceStyle a) =>
      a.onDark ? AppColors.card : const Color(0xFFFFF3D6);

  /// Tinta escura sobre placa clara (branco / ouro).
  static const ink = AppColors.night;

  static ({
    Color fill,
    Color well,
    Color wellFg,
    Color wellBorder,
    Color text,
    Border? outline,
    bool hot,
  })
  paint(_OptState state, Color accent, AppearanceStyle a) {
    final idleFill = _ActSkin.idleFill(a);
    final idleInk = _ActSkin.idleInk(a);
    return switch (state) {
      _OptState.picked => (
        fill: selectedFill(a),
        well: Colors.transparent,
        wellFg: ink,
        wellBorder: ink.withValues(alpha: 0.22),
        text: ink,
        outline: Border.all(
          color: AppRoles.action.withValues(alpha: 0.85),
          width: 2,
        ),
        hot: true,
      ),
      _OptState.correct => (
        fill: AppRoles.action,
        well: Colors.transparent,
        wellFg: AppRoles.onAction,
        wellBorder: AppRoles.onAction.withValues(alpha: 0.35),
        text: AppRoles.onAction,
        outline: null,
        hot: true,
      ),
      _OptState.wrong => (
        fill: AppRoles.error.withValues(alpha: 0.92),
        well: Colors.transparent,
        wellFg: AppColors.textOnDark,
        wellBorder: AppColors.textOnDark.withValues(alpha: 0.55),
        text: AppColors.textOnDark,
        outline: null,
        hot: true,
      ),
      _OptState.dimmed => (
        fill: idleFill.withValues(alpha: 0.45),
        well: Colors.transparent,
        wellFg: idleInk.withValues(alpha: 0.35),
        wellBorder: idleInk.withValues(alpha: 0.2),
        text: idleInk.withValues(alpha: 0.38),
        outline: null,
        hot: false,
      ),
      _OptState.idle => (
        fill: idleFill,
        well: Colors.transparent,
        wellFg: idleInk.withValues(alpha: 0.85),
        wellBorder: idleInk.withValues(alpha: 0.22),
        text: idleInk,
        outline: null,
        hot: false,
      ),
    };
  }

  /// Contorno por cima da placa — não mexe no layout do conteúdo.
  static BoxDecoration outlineOf(Border? outline) => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    border: outline,
  );
}

class ExercisePanel extends StatefulWidget {
  final Exercise exercise;
  final String? selected;
  final bool? isCorrect;
  final bool showFeedback;
  final ValueChanged<String> onSelect;
  final Color accent;

  /// Verso do balão (banco V3). Toque vira; o 1º verso chama [onRevealHint].
  final String? hintText;
  final VoidCallback? onRevealHint;
  final Set<String> eliminatedIds;
  final bool outOfLamps;

  /// Toque no Anan: abre o texto da cena (ouvir, estudar).
  final VoidCallback? onAnan;

  /// O Anan chama a pessoa: balança e escreve [ananCaption] embaixo dele.
  final bool ananBeckon;
  final String? ananCaption;

  /// Erro que já revela a resposta: a opção certa acende junto da errada.
  final bool revealCorrect;
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
    this.accent = AppRoles.chrome,
    this.hintText,
    this.onRevealHint,
    this.eliminatedIds = const {},
    this.outOfLamps = false,
    this.onAnan,
    this.ananBeckon = false,
    this.ananCaption,
    this.revealCorrect = false,
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
  late List<QuestionOption> _shuffledMatchRight;

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
    final newAct = oldWidget.exercise.id != widget.exercise.id;
    final retry = oldWidget.selected != null && widget.selected == null;
    final dismissed =
        oldWidget.showFeedback &&
        !widget.showFeedback &&
        widget.selected == null;
    if (newAct || retry || dismissed) {
      _picked = null;
      // Tentar de novo mantém a ordem que a pessoa já montou — só
      // um ato novo embaralha.
      _resetLocal(keepOrder: !newAct);
      if (newAct) _enter.forward(from: 0);
    }
    if (widget.selected != null && widget.selected != _picked) {
      _picked = widget.selected;
    }
    if (widget.showFeedback || widget.selected != null) {
      _pulse.stop();
    } else if (TickerMode.valuesOf(context).enabled && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  void _resetLocal({bool keepOrder = false}) {
    _confirming = false;
    _matchLeft = null;
    _pairs.clear();
    if (!keepOrder) {
      final items = List<QuestionOption>.from(widget.exercise.effectiveOptions);
      items.shuffle();
      // Ordenar nunca começa já resolvido: se o acaso acertou, gira um.
      if (widget.exercise.type == ExerciseType.order && items.length > 1) {
        final want = widget.exercise.resolvedCorrectAnswer
            .split(',')
            .map((s) => s.trim())
            .join(',');
        if (items.map((o) => o.id).join(',') == want) {
          items.add(items.removeAt(0));
        }
      }
      _shuffledOrderItems = items;
      _shuffledMatchRight = List<QuestionOption>.from(
        widget.exercise.matchRight,
      )..shuffle();
    }
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
    // drive() não prende listener no controller (CurvedAnimation prenderia
    // um por build — e o painel reconstrói a cada toque).
    final curve = _enter.drive(
      CurveTween(curve: Interval(start, end, curve: AppMotion.enter)),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: curve.drive(
          Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero),
        ),
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
    // Só um toque leve: a vibração do veredito vem logo depois.
    ActHaptics.tap();
    setState(() => _confirming = true);
    widget.onSelect(widget.exercise.canonicalizeAnswer(answer));
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
                  isPrompt: ex.showsStagePrompt,
                  picked: widget.selected ?? _picked,
                  hint: widget.hintText,
                  onRevealHint: widget.onRevealHint,
                  onAnan: widget.onAnan,
                  beckon: widget.ananBeckon,
                  caption: widget.ananCaption,
                ),
              ),
              if (_showNote(ex)) ...[
                const SizedBox(height: AppSpace.md),
                _in(
                  0.1,
                  0.6,
                  _ContextNote(
                    label: (ex.noteLabel ?? context.l10n.exerciseNoteLabel)
                        .trim(),
                    text: ex.note!.trim(),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (palco != null)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: stageMaxHeight,
                          ),
                          child: _in(
                            0.12,
                            0.72,
                            // Palco fixo em todo gesto: o versículo é para
                            // ler e tocar, nunca uma carta que gira ao toque.
                            SizedBox.expand(child: palco),
                          ),
                        ),
                      ),
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
                )
              else ...[
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
            ],
          ),
          Positioned.fill(
            child: ActSparkBurst(
              active: widget.isCorrect == true,
              color: AppRoles.action,
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
            // Dica elimina uma palavra: ela apaga no versículo.
            stateFor: (id) => widget.eliminatedIds.contains(id)
                ? _OptState.dimmed
                : _state(id),
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
                  label: context.l10n.exerciseTrue,
                  mark: context.l10n.exerciseTrueMark,
                  state: _state('true'),
                  accent: widget.accent,
                  onTap: _locked ? null : () => _pickChoice('true'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VfSlab(
                  label: context.l10n.exerciseFalse,
                  mark: context.l10n.exerciseFalseMark,
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
        if (ex.passageA != null || ex.passageB != null) {
          return _bridgeBank(ex);
        }
        return _chipBank(ex.effectiveOptions);
      case ExerciseType.connect:
        return _bridgeBank(ex);
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

  List<Widget> _bridgeBank(Exercise ex) => _chipBank([
    for (final o in ex.effectiveOptions)
      QuestionOption(id: o.id, text: _bridgeLabel(o.text)),
  ], occupyVerse: true);

  Widget _tileFor(QuestionOption o) {
    final eliminated = widget.eliminatedIds.contains(o.id);
    return Opacity(
      opacity: eliminated ? 0.38 : 1,
      child: _OptionTile(
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
    final railColor = !_locked
        ? widget.accent
        : widget.isCorrect == false
        ? AppRoles.error
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
    final right = _shuffledMatchRight;
    return [
      _MatchStepper(pickingLeft: _matchLeft == null),
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
                          ? _OptState.picked
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

  /// A dica mora no Anan (toque nele); aqui fica só o Verificar.
  Widget _footer(Exercise ex, bool canConfirm) {
    final waiting = _confirming || widget.selected != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ao armar, o botão dá um pulinho: a resposta escolhida pede o toque.
        TweenAnimationBuilder<double>(
          key: ValueKey(canConfirm),
          tween: Tween(begin: canConfirm ? 0.94 : 1, end: 1),
          duration: AppMotion.gentle,
          curve: AppMotion.pop,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: CopperCta(
            label: context.l10n.exerciseCheck,
            onTap: canConfirm && !waiting ? _confirmChoice : null,
            trailing: null,
            // Sem escolha: desligado à vista (vidro fosco). Conferindo: segue
            // ouro, só não responde ao toque.
            decorative: waiting,
          ),
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
      // Erro que revela: a certa acende para o aluno ver onde estava.
      if (picked) return _OptState.wrong;
      if (widget.revealCorrect &&
          id == widget.exercise.resolvedCorrectAnswer.trim()) {
        return _OptState.correct;
      }
      return _OptState.idle;
    }
    if (_picked == id) return _OptState.picked;
    return _OptState.idle;
  }
}

TextStyle _verseWordStyle({
  Color? color,
  FontWeight weight = FontWeight.w600,
  double height = 1.55,
  double? size,
}) => AppTypography.verse(
  size: size ?? _ActSkin.verseSize,
  weight: weight,
  height: height,
  color: color ?? AppColors.textOnDark,
);

/// Palavra na lacuna: ouro (seleção clara some no texto do verso); erro no poço.
TextStyle _filledWordStyle(TextStyle base, _OptState state) {
  // wrong usa _BlankGap; aqui só picked/correct.
  return base.copyWith(
    color: state == _OptState.wrong ? AppRoles.error : AppRoles.action,
  );
}

/// O enunciado como fala do Anan. O tipo do gesto fica na barra de cima.
///
/// Com dica (banco V3), o verso já está no balão: toque vira pergunta ↔ dica.
/// O primeiro verso dispara [onRevealHint].
class _GestureSeal extends StatefulWidget {
  final String title;
  final bool isPrompt;
  final String? picked;
  final String? hint;
  final VoidCallback? onRevealHint;
  final VoidCallback? onAnan;
  final bool beckon;
  final String? caption;

  const _GestureSeal({
    required this.title,
    required this.isPrompt,
    this.picked,
    this.hint,
    this.onRevealHint,
    this.onAnan,
    this.beckon = false,
    this.caption,
  });

  @override
  State<_GestureSeal> createState() => _GestureSealState();
}

class _GestureSealState extends State<_GestureSeal> {
  bool _onHint = false;
  bool _revealed = false;

  String get _tip => (widget.hint ?? '').trim();

  @override
  void didUpdateWidget(covariant _GestureSeal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tip.isEmpty) {
      _onHint = false;
      _revealed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cue = widget.title.trim();
    const ink = AnanSpeechBubble.ink;
    final tip = _tip;
    return AnanSideSpeech(
      hop: widget.picked,
      onAnanTap: widget.onAnan,
      ananLabel: context.l10n.lessonAnanHelpLabel,
      beckon: widget.beckon,
      caption: widget.caption,
      flipped: tip.isNotEmpty && _onHint,
      back: tip.isEmpty ? null : _hintFace(tip),
      onTap: tip.isEmpty
          ? null
          : () {
              ActHaptics.tap();
              final showHint = !_onHint;
              setState(() => _onHint = showHint);
              if (showHint && !_revealed) {
                _revealed = true;
                widget.onRevealHint?.call();
              }
            },
      // A pergunta inteira, sempre: afirmação longa (V/F do banco V3) desce
      // um passo no tamanho em vez de ser cortada.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cue,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.title(
              size: cue.length > 90 ? 16 : (widget.isPrompt ? 18 : 17),
              height: 1.15,
              color: ink,
            ),
          ),
          if (tip.isNotEmpty) _turnCue(context.l10n.exerciseHintShowHint),
        ],
      ),
    );
  }

  /// Rodapé dos dois lados do balão: diz que ele vira com um toque.
  Widget _turnCue(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.refresh,
            size: 14,
            accent: AnanSpeechBubble.mark,
            framed: false,
            glowing: false,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: AnanSpeechBubble.mark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintFace(String tip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.exerciseHint.toUpperCase(),
          style: AppTypography.label(
            size: 11,
            letterSpacing: 1.2,
            color: AnanSpeechBubble.mark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tip,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.title(
            size: 17,
            height: 1.2,
            color: AnanSpeechBubble.ink,
          ),
        ),
        _turnCue(context.l10n.exerciseHintShowQuestion),
      ],
    );
  }
}

class _ContextNote extends StatelessWidget {
  final String label;
  final String text;

  const _ContextNote({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: a.divider, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SectionLabel(label, color: a.sectionLabel),
            ),
            Expanded(child: Divider(color: a.divider, height: 1)),
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
            color: a.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RefLabel extends StatelessWidget {
  final String reference;

  const _RefLabel({required this.reference});

  @override
  Widget build(BuildContext context) {
    final ref = reference.trim();
    if (ref.isEmpty) return const SizedBox.shrink();
    final meta = Appearance.of(context).sectionLabel;
    return Center(child: SectionLabel(ref, color: meta, size: 13));
  }
}

class _Manuscript extends StatefulWidget {
  final Color accent;
  final Widget child;
  final String? reference;
  final bool framed;
  final bool fill;
  final bool lit;

  /// Trechos para a lupa: quando o palco encolhe o texto abaixo de
  /// [_ActSkin.zoomBelow], a lupa abre o mesmo texto em corpo de leitura.
  final List<ExercisePassage> zoom;

  /// Corpo de origem do texto no palco, antes de encolher.
  final double verseSize;

  const _Manuscript({
    required this.accent,
    required this.child,
    this.reference,
    this.framed = false,
    this.fill = false,
    this.lit = false,
    this.zoom = const [],
    this.verseSize = _ActSkin.verseSize,
  });

  @override
  State<_Manuscript> createState() => _ManuscriptState();
}

class _ManuscriptState extends State<_Manuscript> {
  bool _small = false;

  Color get accent => widget.accent;
  Widget get child => widget.child;
  String? get reference => widget.reference;
  bool get framed => widget.framed;
  bool get fill => widget.fill;
  bool get lit => widget.lit;

  BoxDecoration _plate(BuildContext context) => StagePlate.decoration(
    // Acerto = glow de ouro no rim do palco; idle = luz do modo.
    accent: lit ? AppRoles.action : accent,
    lit: lit,
    tint: true,
    style: Appearance.of(context),
  );

  /// O palco mostra o trecho inteiro. Se não cabe na altura, encolhe —
  /// sem rolagem interna, que cortava o versículo sem indicar scroll.
  Widget _filledStage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        if (!maxW.isFinite || !maxH.isFinite || maxW <= 0 || maxH <= 0) {
          return child;
        }
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: widget.zoom.isEmpty
              ? SizedBox(width: maxW, child: child)
              : _ScaleProbe(
                  limit: maxH,
                  minScale: _ActSkin.zoomBelow / widget.verseSize,
                  onSmall: (small) {
                    if (mounted && small != _small) {
                      setState(() => _small = small);
                    }
                  },
                  child: SizedBox(width: maxW, child: child),
                ),
        );
      },
    );
  }

  /// Lupa no canto do palco — só quando o texto ficou pequeno.
  Widget _withZoom(Widget plate) {
    if (!_small || widget.zoom.isEmpty) return plate;
    return Stack(
      children: [
        plate,
        PositionedDirectional(
          top: 10,
          end: 10,
          child: _ZoomButton(
            onTap: () {
              ActHaptics.tap();
              _showStageZoom(context, widget.zoom, widget.accent);
            },
          ),
        ),
      ],
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
            _RefLabel(reference: ref),
            const SizedBox(height: 14),
          ],
          child,
        ],
      );
      final plate = framed
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              decoration: _plate(context),
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
      return _withZoom(
        Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          decoration: _plate(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (ref.isNotEmpty) ...[
                _RefLabel(reference: ref),
                const SizedBox(height: 14),
              ],
              Expanded(child: stage),
            ],
          ),
        ),
      );
    }

    if (ref.isEmpty) return _withZoom(stage);

    return _withZoom(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RefLabel(reference: ref),
          const SizedBox(height: 14),
          Expanded(child: stage),
        ],
      ),
    );
  }
}

/// Mede o texto do palco antes do [FittedBox] e avisa quando a escala
/// necessária para caber em [limit] fica abaixo de [minScale].
class _ScaleProbe extends SingleChildRenderObjectWidget {
  final double limit;
  final double minScale;
  final ValueChanged<bool> onSmall;

  const _ScaleProbe({
    required this.limit,
    required this.minScale,
    required this.onSmall,
    required super.child,
  });

  @override
  _RenderScaleProbe createRenderObject(BuildContext context) =>
      _RenderScaleProbe(limit: limit, minScale: minScale, onSmall: onSmall);

  @override
  void updateRenderObject(BuildContext context, _RenderScaleProbe probe) {
    probe
      ..limit = limit
      ..minScale = minScale
      ..onSmall = onSmall;
  }
}

class _RenderScaleProbe extends RenderProxyBox {
  _RenderScaleProbe({
    required this._limit,
    required this._minScale,
    required this.onSmall,
  });

  ValueChanged<bool> onSmall;
  bool? _reported;

  double _limit;
  set limit(double v) {
    if (v == _limit) return;
    _limit = v;
    markNeedsLayout();
  }

  double _minScale;
  set minScale(double v) {
    if (v == _minScale) return;
    _minScale = v;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    super.performLayout();
    final h = size.height;
    final small = h > 0 && _limit / h < _minScale;
    if (small == _reported) return;
    _reported = small;
    WidgetsBinding.instance.addPostFrameCallback((_) => onSmall(small));
  }
}

class _ZoomButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ZoomButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Semantics(
      button: true,
      label: context.l10n.exerciseZoomStage,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: a.stageFill,
              border: Border.all(color: a.divider),
            ),
            child: CinematicIcon(
              glyph: CinematicGlyph.search,
              size: 18,
              accent: a.sectionLabel,
              framed: false,
            ),
          ),
        ),
      ),
    );
  }
}

/// O texto do palco em corpo de leitura, com a referência de cada trecho.
Future<void> _showStageZoom(
  BuildContext context,
  List<ExercisePassage> passages,
  Color accent,
) {
  return showAppSheet<void>(
    context,
    builder: (_) => _StageZoomSheet(passages: passages, accent: accent),
  );
}

/// Lupa do palco: o mesmo papel do palco, em corpo de leitura. A−/A+ mudam
/// o corpo e a sheet cresce junto (lembrado na sessão). Na ponte, um fio
/// liga os trechos.
class _StageZoomSheet extends StatefulWidget {
  final List<ExercisePassage> passages;
  final Color accent;

  const _StageZoomSheet({required this.passages, required this.accent});

  static const sizes = [22.0, 26.0, 30.0, 34.0];
  static int _step = 1;

  @override
  State<_StageZoomSheet> createState() => _StageZoomSheetState();
}

class _StageZoomSheetState extends State<_StageZoomSheet> {
  int get _step => _StageZoomSheet._step;

  void _nudge(int by) {
    final next = (_step + by).clamp(0, _StageZoomSheet.sizes.length - 1);
    if (next == _step) return;
    ActHaptics.tick();
    setState(() => _StageZoomSheet._step = next);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final accent = widget.accent;
    final size = _StageZoomSheet.sizes[_step];
    final maxH = MediaQuery.sizeOf(context).height * 0.62;
    final passages = widget.passages;

    return AppSheetPanel(
      tint: accent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _SizeStep(
                label: 'A',
                semantics: context.l10n.exerciseZoomSmaller,
                small: true,
                onTap: _step == 0 ? null : () => _nudge(-1),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CinematicIcon(
                      glyph: CinematicGlyph.search,
                      size: 16,
                      accent: a.sectionLabel,
                      framed: false,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: SectionLabel(
                        context.l10n.exerciseZoomStage,
                        size: 12,
                        color: a.sectionLabel,
                      ),
                    ),
                  ],
                ),
              ),
              _SizeStep(
                label: 'A',
                semantics: context.l10n.exerciseZoomLarger,
                onTap: _step == _StageZoomSheet.sizes.length - 1
                    ? null
                    : () => _nudge(1),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          AnimatedSize(
            duration: AppMotion.standard,
            curve: AppMotion.enter,
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, p) in passages.indexed) ...[
                      if (i > 0) _ZoomRope(accent: accent),
                      StagePlate(
                        accent: accent,
                        tint: true,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (p.ref.trim().isNotEmpty) ...[
                              _RefLabel(reference: p.ref),
                              const SizedBox(height: 12),
                            ],
                            Text(
                              p.text.trim(),
                              textAlign: TextAlign.center,
                              style: _verseWordStyle(
                                color: a.text,
                                height: 1.5,
                                size: size,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          GhostCta(
            label: context.l10n.commonClose,
            expanded: true,
            matchCopper: true,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Botão de corpo: “A” pequeno diminui, “A” grande aumenta.
class _SizeStep extends StatelessWidget {
  final String label;
  final String semantics;
  final bool small;
  final VoidCallback? onTap;

  const _SizeStep({
    required this.label,
    required this.semantics,
    this.small = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final on = onTap != null;
    return Semantics(
      button: true,
      enabled: on,
      label: semantics,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: AppMotion.standard,
          opacity: on ? 1 : 0.35,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: a.insetFill,
              border: Border.all(color: a.insetBorder),
            ),
            child: Text(
              label,
              style: AppTypography.verse(
                size: small ? 16 : 24,
                weight: FontWeight.w700,
                height: 1,
                color: a.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fio entre os trechos da ponte, como no palco.
class _ZoomRope extends StatelessWidget {
  final Color accent;

  const _ZoomRope({required this.accent});

  @override
  Widget build(BuildContext context) {
    final line = accent.withValues(alpha: 0.45);
    return SizedBox(
      height: 28,
      child: Column(
        children: [
          Expanded(child: Container(width: 1.5, color: line)),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
          ),
          Expanded(child: Container(width: 1.5, color: line)),
        ],
      ),
    );
  }
}

class _CompleteVerse extends StatefulWidget {
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

  @override
  State<_CompleteVerse> createState() => _CompleteVerseState();
}

class _CompleteVerseState extends State<_CompleteVerse> {
  static final _blank = RegExp(r'_{3,}');
  TapGestureRecognizer? _clear;

  @override
  void initState() {
    super.initState();
    _bindClear();
  }

  @override
  void didUpdateWidget(covariant _CompleteVerse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onClear != widget.onClear) _bindClear();
  }

  @override
  void dispose() {
    _clear?.dispose();
    super.dispose();
  }

  void _bindClear() {
    if (widget.onClear == null) {
      _clear?.dispose();
      _clear = null;
      return;
    }
    _clear ??= TapGestureRecognizer();
    _clear!.onTap = widget.onClear;
  }

  InlineSpan _blankSpan(TextStyle style) {
    final filled = (widget.filled ?? '').trim();
    // Palavra preenchida fica no mesmo recorte do versículo — mesma
    // família/peso/corpo; só a cor marca a lacuna.
    if (filled.isNotEmpty && widget.state != _OptState.wrong) {
      return TextSpan(
        text: widget.filled,
        style: _filledWordStyle(style, widget.state),
        recognizer: _clear,
      );
    }
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      style: style,
      child: ActShake(
        key: const ValueKey('cloze-shake'),
        active: widget.state == _OptState.wrong,
        child: _BlankGap(
          size: style.fontSize ?? _ActSkin.verseSize,
          filled: widget.filled,
          expected: widget.expected ?? widget.filled ?? 'palavra',
          state: widget.state,
          accent: widget.accent,
          pulse: widget.pulse,
          onClear: widget.onClear,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final template = widget.template;
    final match = _blank.firstMatch(template);
    final last = _blank.allMatches(template).lastOrNull;
    final hasBlank = match != null && last != null;
    final before = hasBlank ? template.substring(0, match.start) : template;
    final after = hasBlank ? template.substring(last.end) : '';
    final size = _verseSizeFor(template);
    final style = _verseWordStyle(
      color: Appearance.of(context).text,
      size: size,
      height: 1.45,
    );

    return _Manuscript(
      accent: widget.accent,
      reference: widget.reference,
      framed: true,
      fill: widget.fill,
      lit: widget.lit,
      verseSize: size,
      zoom: [
        ExercisePassage(
          ref: widget.reference ?? '',
          text: template.replaceAll(_blank, '_____'),
        ),
      ],
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            if (before.isNotEmpty) TextSpan(text: before),
            if (hasBlank) _blankSpan(style),
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
  final double size;

  const _BlankGap({
    required this.filled,
    this.size = _ActSkin.verseSize,
    required this.expected,
    required this.state,
    required this.accent,
    required this.pulse,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final has = (filled ?? '').trim().isNotEmpty;
    final probeStyle = _verseWordStyle(
      color: Appearance.of(context).text,
      size: size,
    );
    final probe = TextPainter(
      text: TextSpan(text: has ? filled! : expected, style: probeStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final minW = math.min(260.0, math.max(72.0, probe.width + 8));
    probe.dispose();

    if (has && state == _OptState.wrong) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Text(
          filled!,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: probeStyle
              .copyWith(color: AppRoles.error, height: 1)
              .copyWith(decoration: TextDecoration.lineThrough),
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
            style: _filledWordStyle(
              _verseWordStyle(
                color: Appearance.of(context).text,
                height: 1,
                size: size,
              ),
              state,
            ),
          ),
        ),
      );
    }

    final slot = SizedBox(
      width: minW,
      height: size * 1.5,
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

    // FadeTransition + camada própria: a lacuna pulsa sem repintar o
    // versículo inteiro a cada frame.
    return RepaintBoundary(
      child: FadeTransition(
        // drive() não prende listener no controller (CurvedAnimation prenderia
        // um por build).
        opacity: pulse.drive(
          CurveTween(
            curve: AppMotion.move,
          ).chain(Tween<double>(begin: 0.72, end: 1)),
        ),
        child: slot,
      ),
    );
  }
}

/// Ponte: duas margens (trechos) e a tábua entre elas. A ideia escolhida
/// assenta na tábua — em letra de interface, não de versículo, porque é
/// leitura nossa e não Escritura. No acerto, a ponte acende de ponta a ponta.
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
    final size = _verseSizeFor(
      '${passageA?.text ?? ''} ${passageB?.text ?? ''}',
    );
    final both = passageA != null && passageB != null;
    return _Manuscript(
      accent: accent,
      framed: true,
      fill: fill,
      lit: lit,
      verseSize: size,
      zoom: [?passageA, ?passageB],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (passageA != null)
            _connectStanza(context, passageA!, accent, size),
          if (both) ...[
            const SizedBox(height: 10),
            _BridgeRope(state: state, accent: accent),
            ActShake(
              active: state == _OptState.wrong,
              child: _BridgePlank(
                filled: picked,
                state: state,
                accent: accent,
                pulse: pulse,
                onClear: onClear,
              ),
            ),
            _BridgeRope(state: state, accent: accent),
            const SizedBox(height: 10),
          ],
          if (passageB != null)
            _connectStanza(context, passageB!, accent, size),
        ],
      ),
    );
  }
}

/// Primeira letra maiúscula: as ideias da ponte vêm do banco em caixa mista.
String _bridgeLabel(String text) {
  final t = text.trim();
  if (t.isEmpty) return t;
  return t[0].toUpperCase() + t.substring(1);
}

/// Fio que liga a margem à tábua: tênue à espera, aceso no acerto.
class _BridgeRope extends StatelessWidget {
  final _OptState state;
  final Color accent;

  const _BridgeRope({required this.state, required this.accent});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _OptState.correct => AppRoles.action,
      _OptState.wrong => AppRoles.error.withValues(alpha: 0.6),
      _OptState.picked => AppRoles.action.withValues(alpha: 0.6),
      _ => accent.withValues(alpha: 0.45),
    };
    return AnimatedContainer(
      duration: _ActSkin.anim,
      curve: AppMotion.enter,
      width: state == _OptState.correct ? 3 : 2,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }
}

/// A tábua da ponte. Vazia: encaixe tracejado que pulsa. Cheia: a ideia
/// escolhida (toque devolve ao banco).
class _BridgePlank extends StatelessWidget {
  final String? filled;
  final _OptState state;
  final Color accent;
  final AnimationController pulse;
  final VoidCallback? onClear;

  const _BridgePlank({
    required this.filled,
    required this.state,
    required this.accent,
    required this.pulse,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final label = _bridgeLabel(filled ?? '');
    if (label.isEmpty) {
      // FadeTransition + camada própria: a tábua pulsa sem repintar o palco.
      return RepaintBoundary(
        child: FadeTransition(
          opacity: pulse.drive(
            CurveTween(
              curve: AppMotion.move,
            ).chain(Tween<double>(begin: 0.55, end: 1)),
          ),
          child: CustomPaint(
            painter: _DashedPillPainter(color: accent),
            child: SizedBox(
              width: 200,
              height: 48,
              child: Center(
                child: Text(
                  '?',
                  style: AppTypography.title(size: 20, color: accent),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final skin = _ActSkin.paint(state, accent, Appearance.of(context));
    return GestureDetector(
      onTap: state == _OptState.picked ? onClear : null,
      child: AnimatedContainer(
        duration: _ActSkin.anim,
        curve: AppMotion.enter,
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: skin.fill,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: skin.outline,
          boxShadow: _ActSkin.plateShadow,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.title(size: 16, height: 1.2, color: skin.text)
              .copyWith(
                decoration: state == _OptState.wrong
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: skin.text,
              ),
        ),
      ),
    );
  }
}

class _DashedPillPainter extends CustomPainter {
  final Color color;

  const _DashedPillPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1);
    final pill = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.height / 2),
    );
    canvas.drawRRect(pill, Paint()..color = color.withValues(alpha: 0.08));
    final path = Path()..addRRect(pill);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dash = 7.0;
    const gap = 6.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPillPainter old) => old.color != color;
}

/// Cada trecho com a própria referência em cima — como todo palco.
Widget _connectStanza(
  BuildContext context,
  ExercisePassage passage,
  Color accent,
  double size,
) {
  final ref = passage.ref.trim();
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (ref.isNotEmpty) ...[
        _RefLabel(reference: ref),
        const SizedBox(height: 8),
      ],
      Text(
        passage.text.trim(),
        textAlign: TextAlign.center,
        style: _verseWordStyle(
          color: Appearance.of(context).text,
          height: 1.45,
          size: size,
        ),
      ),
    ],
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
          RelicChapter(
            title: context.l10n.commonToday,
            accent: accent,
            divided: false,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: AnanSpeech(
                  face: CloudFace.sucesso,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTypography.title(
                      size: 20,
                      height: 1.32,
                      color: AnanSpeechBubble.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          CopperCta(
            label: context.l10n.commonContinue,
            onTap: onContinue,
            trailing: null,
          ),
          const SizedBox(height: AppSpace.lg),
        ],
      ),
    );
  }
}

/// Escala única do palco (todo gesto): o corpo segue o tamanho do que está
/// em cena — versículo curto não fica perdido, longo não estoura.
double _verseSizeFor(String text) {
  final words = text
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .length;
  if (words <= 12) return 30;
  if (words <= 24) return 27;
  if (words <= 40) return _ActSkin.verseSize;
  return 22;
}

/// Pontuação logo após a palavra tocável (", " "." ";") — gruda nela.
final _leadingPunct = RegExp(r'^[,.;:!?…)»”"]+');

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
    final size = _verseSizeFor(text);
    final style = _verseWordStyle(
      color: Appearance.of(context).text,
      height: 1.45,
      size: size,
    );
    // A marca tem margem interna; a pontuação seguinte vai junto dela,
    // senão sobra um espaço antes da vírgula ("princípio ,").
    final tails = <int, String>{};
    final heads = <int, String>{};
    for (var i = 0; i + 1 < spans.length; i++) {
      if (spans[i].optionId == null || spans[i + 1].optionId != null) continue;
      final m = _leadingPunct.firstMatch(spans[i + 1].text);
      if (m == null) continue;
      tails[i] = m.group(0)!;
      heads[i + 1] = spans[i + 1].text.substring(m.end);
    }

    return _Manuscript(
      accent: accent,
      reference: reference,
      framed: framed,
      fill: fill,
      lit: lit,
      verseSize: size,
      zoom: [ExercisePassage(ref: reference ?? '', text: text)],
      child: tappable
          ? Text.rich(
              TextSpan(
                style: style,
                children: [
                  for (final (i, span) in spans.indexed)
                    if (span.optionId != null)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: ActShake(
                          key: ValueKey('tap-shake-${span.optionId}'),
                          active:
                              stateFor?.call(span.optionId!) == _OptState.wrong,
                          child: _PressScale(
                            onTap: locked || onPick == null
                                ? null
                                : () => onPick!(span.optionId!),
                            child: _VerseMark(
                              text: span.text,
                              tail: tails[i],
                              size: size,
                              state:
                                  stateFor?.call(span.optionId!) ??
                                  _OptState.idle,
                              accent: accent,
                            ),
                          ),
                        ),
                      )
                    else if ((heads[i] ?? span.text).isNotEmpty)
                      TextSpan(text: heads[i] ?? span.text),
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
        duration: AppMotion.instant,
        curve: AppMotion.enter,
        child: widget.child,
      ),
    );
  }
}

class _VerseMark extends StatelessWidget {
  final String text;
  final _OptState state;
  final Color accent;

  /// Pontuação que segue a palavra — fora da marca, mas colada nela.
  final String? tail;
  final double size;

  const _VerseMark({
    required this.text,
    required this.state,
    required this.accent,
    this.tail,
    this.size = _ActSkin.verseSize,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final hot =
        state == _OptState.correct ||
        state == _OptState.picked ||
        state == _OptState.wrong;
    final color = switch (state) {
      _OptState.wrong => AppRoles.error,
      _OptState.dimmed => a.text.withValues(alpha: 0.38),
      _OptState.correct => AppRoles.action,
      // Escolhida: o amarelo de ação, como a palavra na lacuna.
      _OptState.picked => AppRoles.action,
      _OptState.idle => a.text,
    };
    final wash = switch (state) {
      _OptState.wrong => color.withValues(alpha: 0.18),
      _OptState.dimmed => Colors.transparent,
      _OptState.correct => color.withValues(alpha: 0.22),
      _OptState.picked => color.withValues(alpha: 0.24),
      _OptState.idle => Colors.transparent,
    };
    final underline = switch (state) {
      _OptState.idle => accent.withValues(alpha: 0.7),
      _OptState.dimmed => Colors.transparent,
      _ => color,
    };

    final mark = AnimatedScale(
      scale: hot ? 1.04 : 1,
      duration: _ActSkin.anim,
      curve: AppMotion.enter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: wash,
          borderRadius: BorderRadius.circular(AppRadii.xs),
          border: Border(
            bottom: BorderSide(color: underline, width: hot ? 2.4 : 1.6),
          ),
          boxShadow: state == _OptState.correct
              ? [
                  BoxShadow(
                    color: AppRoles.action.withValues(alpha: 0.32),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(3, 2, 3, 3),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: _verseWordStyle(
              color: color,
              weight: hot ? FontWeight.w700 : FontWeight.w600,
              size: size,
            ),
          ),
        ),
      ),
    );
    final punct = tail;
    if (punct == null) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        mark,
        Text(
          punct,
          style: _verseWordStyle(
            color: Appearance.of(context).text,
            size: size,
          ),
        ),
      ],
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
    final skin = _ActSkin.paint(state, accent, Appearance.of(context));
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
            curve: AppMotion.enter,
            width: fill ? double.infinity : null,
            constraints: BoxConstraints(minHeight: fill ? 72 : 56),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_ActSkin.radius),
              color: skin.fill,
              boxShadow: _ActSkin.plateShadow,
            ),
            foregroundDecoration: _ActSkin.outlineOf(skin.outline),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(size: 14, color: skin.text),
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
    final a = Appearance.of(context);
    final skin = _ActSkin.paint(state, accent, a);
    final wellBorder = skin.wellBorder;
    // Selecionada: o selo leva o azul do palco (no Claro o palco é papel,
    // então fica a tinta escura da placa).
    final pickedWell = state == _OptState.picked && a.onDark;
    final hotWell = pickedWell ? a.stageFill : skin.text;
    final hotMark = pickedWell
        ? AppColors.textOnDark
        : skin.fill.withValues(alpha: 1);

    return ActShake(
      active: state == _OptState.wrong,
      child: ActPress(
        onTap: onTap,
        depth: 4,
        child: AnimatedContainer(
          duration: _ActSkin.anim,
          curve: AppMotion.enter,
          constraints: const BoxConstraints(minHeight: 96),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_ActSkin.radius),
            color: skin.fill,
            boxShadow: _ActSkin.plateShadow,
          ),
          foregroundDecoration: _ActSkin.outlineOf(skin.outline),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: _ActSkin.anim,
                width: 30,
                height: 30,
                alignment: Alignment.center,
                // Aceso: o selo inverte (poço cheio na tinta da placa) — o
                // contorno fino sumia na placa clara da seleção.
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: skin.hot ? hotWell : skin.well,
                  border: skin.hot
                      ? null
                      : Border.all(color: wellBorder, width: 1.6),
                ),
                child: Text(
                  mark,
                  style: AppTypography.title(
                    size: 14,
                    color: skin.hot ? hotMark : skin.wellFg,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.title(size: 14, color: skin.text),
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

  const _OptionTile({
    required this.text,
    required this.state,
    required this.accent,
    this.onTap,
    this.struck = false,
  });

  @override
  Widget build(BuildContext context) {
    final skin = _ActSkin.paint(state, accent, Appearance.of(context));
    return ActShake(
      active: state == _OptState.wrong,
      child: ActPress(
        onTap: onTap,
        depth: 4,
        child: AnimatedContainer(
          duration: _ActSkin.anim,
          curve: AppMotion.enter,
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          alignment: Alignment.centerLeft,
          padding: _ActSkin.pad,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_ActSkin.radius),
            color: skin.fill,
            boxShadow: _ActSkin.plateShadow,
          ),
          foregroundDecoration: _ActSkin.outlineOf(skin.outline),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.start,
                  style:
                      AppTypography.title(
                        size: 14,
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
  final String text;
  final Color accent;
  final bool locked;
  final _OptState state;

  const _OrderPiece({
    required this.text,
    required this.accent,
    required this.locked,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final skin = _ActSkin.paint(state, accent, Appearance.of(context));
    return AnimatedContainer(
      duration: _ActSkin.anim,
      curve: AppMotion.enter,
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_ActSkin.radius),
        color: skin.fill,
        boxShadow: _ActSkin.plateShadow,
      ),
      foregroundDecoration: _ActSkin.outlineOf(skin.outline),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: AppTypography.title(
                size: 14,
                height: 1.3,
                color: skin.text,
              ),
            ),
          ),
          Icon(
            Icons.drag_indicator_rounded,
            size: AppMetrics.iconLg,
            color: locked
                ? skin.text.withValues(alpha: 0.18)
                : skin.text.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }
}

class _MatchStepper extends StatelessWidget {
  final bool pickingLeft;

  const _MatchStepper({required this.pickingLeft});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
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
              color: on ? AppRoles.action : a.divider,
            ),
            child: Text(
              '$n',
              style: AppTypography.title(
                size: 11,
                color: on ? AppRoles.onAction : a.textFaint,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.8,
              color: on ? AppRoles.action : a.textFaint,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        step(1, context.l10n.exerciseMatchPick, pickingLeft),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(width: 18, height: 1, color: a.divider),
        ),
        step(2, context.l10n.exerciseMatchPair, !pickingLeft),
      ],
    );
  }
}
