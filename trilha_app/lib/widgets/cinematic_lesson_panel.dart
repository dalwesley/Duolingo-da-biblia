import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'lantern_glyph.dart';
import 'ui_primitives.dart';
import 'verse_study_sheet.dart';

/// Painel de pergunta cinematográfico — cena, não quiz genérico.
class CinematicLessonPanel extends StatefulWidget {
  final String narrative;
  final Question question;
  final String? selected;
  final bool? isCorrect;
  final bool showFeedback;
  final ValueChanged<String> onSelect;
  final Color accent;
  final String? sectionLabel;
  final String? encouragement;
  final bool hintUsed;
  final Set<String> eliminatedIds;
  final VoidCallback? onHint;
  final bool outOfLamps;
  final String? verseSnippet;
  final int lamps;

  const CinematicLessonPanel({
    super.key,
    required this.narrative,
    required this.question,
    required this.selected,
    required this.isCorrect,
    required this.showFeedback,
    required this.onSelect,
    this.accent = AppColors.accent,
    this.sectionLabel,
    this.encouragement,
    this.hintUsed = false,
    this.eliminatedIds = const {},
    this.onHint,
    this.outOfLamps = false,
    this.verseSnippet,
    this.lamps = 5,
  });

  @override
  State<CinematicLessonPanel> createState() => _CinematicLessonPanelState();
}

class _CinematicLessonPanelState extends State<CinematicLessonPanel>
    with TickerProviderStateMixin {
  late final AnimationController _stagger;
  String? _picked;

  @override
  void initState() {
    super.initState();
    _stagger = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
  }

  @override
  void didUpdateWidget(covariant CinematicLessonPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.question != widget.question.question) {
      _picked = null;
      _stagger.forward(from: 0);
    }
    if (widget.selected != null && widget.selected != _picked) {
      _picked = widget.selected;
    }
    if (_picked != null && widget.eliminatedIds.contains(_picked)) {
      _picked = null;
    }
  }

  @override
  void dispose() {
    _stagger.dispose();
    super.dispose();
  }

  void _pick(String id) {
    if (widget.showFeedback || widget.selected != null || widget.outOfLamps) return;
    if (widget.eliminatedIds.contains(id)) return;
    HapticFeedback.selectionClick();
    setState(() => _picked = id);
  }

  void _confirm() {
    final id = _picked;
    if (id == null || widget.showFeedback || widget.selected != null || widget.outOfLamps) return;
    HapticFeedback.mediumImpact();
    widget.onSelect(id);
  }

  _ChoiceState _state(String id) {
    if (widget.showFeedback && widget.selected != null) {
      if (id == widget.question.correctOptionId) return _ChoiceState.correct;
      if (id == widget.selected) return _ChoiceState.wrong;
      return _ChoiceState.dimmed;
    }
    if (_picked == id) return _ChoiceState.picked;
    return _ChoiceState.idle;
  }

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final locked =
        widget.showFeedback || widget.selected != null || widget.outOfLamps;
    final canConfirm = _picked != null && !locked;

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final compact = h < 680;
        final tight = h < 580;
        final gap = tight
            ? AppSpace.xs
            : compact
                ? AppSpace.sm
                : AppSpace.section;
        final sidePad = tight ? AppSpace.md : AppSpace.screen;
        final optionPad = tight ? 8.0 : compact ? 10.0 : 13.0;
        final questionSize = tight ? 20.0 : compact ? 23.0 : 26.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, bodyConstraints) {
                  final body = Padding(
                    padding: EdgeInsets.fromLTRB(
                      sidePad,
                      gap,
                      sidePad,
                      tight ? AppSpace.sm : AppSpace.md,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _stagger,
                            curve: const Interval(
                              0,
                              0.4,
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
                                  0,
                                  0.45,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                            ),
                            child: _ChallengePrompt(
                              question: widget.question.question,
                              verseRef: widget.question.verseRef,
                              accent: accent,
                              showHint: !locked && widget.onHint != null,
                              hintUsed: widget.hintUsed,
                              onHint: widget.onHint,
                              questionSize: questionSize,
                              compact: compact,
                              lamps: widget.lamps,
                            ),
                          ),
                        ),
                        SizedBox(height: gap),
                        ...widget.question.options.asMap().entries.map((e) {
                          final i = e.key;
                          final opt = e.value;
                          final eliminated =
                              widget.eliminatedIds.contains(opt.id);
                          final start = 0.22 + i * 0.1;
                          final curve = CurvedAnimation(
                            parent: _stagger,
                            curve: Interval(
                              start,
                              (start + 0.42).clamp(0.0, 1.0),
                              curve: Curves.easeOutCubic,
                            ),
                          );
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: i == widget.question.options.length - 1
                                  ? 0
                                  : (tight ? 4 : AppSpace.sm),
                            ),
                            child: FadeTransition(
                              opacity: curve,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(0.04 + i * 0.01, 0.08),
                                  end: Offset.zero,
                                ).animate(curve),
                                child: Opacity(
                                  opacity: eliminated ? 0.32 : 1,
                                  child: _ChoiceTile(
                                    letter: _letters[
                                        i.clamp(0, _letters.length - 1)],
                                    text: opt.text,
                                    state: eliminated
                                        ? _ChoiceState.dimmed
                                        : _state(opt.id),
                                    enabled: !locked && !eliminated,
                                    accent: accent,
                                    onTap: () => _pick(opt.id),
                                    verticalPad: optionPad,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        if (!widget.showFeedback) ...[
                          SizedBox(
                            height: tight ? AppSpace.sm : AppSpace.md,
                          ),
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _stagger,
                              curve: const Interval(
                                0.55,
                                1,
                                curve: Curves.easeOut,
                              ),
                            ),
                            child: canConfirm
                                ? CopperCta(
                                    label: 'Verificar',
                                    onTap: _confirm,
                                    trailing: CinematicGlyph.check,
                                    padding: EdgeInsets.symmetric(
                                      vertical: compact ? 14 : AppSpace.lg,
                                      horizontal: AppSpace.lg,
                                    ),
                                  )
                                : Opacity(
                                    opacity: 0.45,
                                    child: CopperCta(
                                      label: 'Toque uma opção',
                                      onTap: null,
                                      trailing: null,
                                      padding: EdgeInsets.symmetric(
                                        vertical: compact ? 14 : AppSpace.lg,
                                        horizontal: AppSpace.lg,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ],
                    ),
                  );

                  // Escala para caber — zero scroll em qualquer altura.
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: bodyConstraints.maxWidth,
                      child: body,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChallengePrompt extends StatelessWidget {
  final String question;
  final String? verseRef;
  final Color accent;
  final bool showHint;
  final bool hintUsed;
  final VoidCallback? onHint;
  final double questionSize;
  final bool compact;
  final int lamps;

  const _ChallengePrompt({
    required this.question,
    required this.verseRef,
    required this.accent,
    required this.showHint,
    required this.hintUsed,
    required this.onHint,
    required this.lamps,
    this.questionSize = 26,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          question,
          textAlign: TextAlign.center,
          maxLines: compact ? 4 : 5,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.display(
            size: questionSize,
            weight: FontWeight.w800,
            height: 1.22,
          ),
        ),
        if (verseRef != null) ...[
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: () => showVerseStudyFromReference(context, verseRef!),
              child: Text(
                verseRef!,
                textAlign: TextAlign.center,
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 0.4,
                  color: accent.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
        ],
        SizedBox(height: compact ? 14 : 16),
        // Mecânicas separadas: vidas ≠ dica
        Row(
          children: [
            _LivesHud(current: lamps, accent: accent),
            const Spacer(),
            if (showHint)
              _HintChip(
                used: hintUsed,
                accent: accent,
                onTap: onHint,
              ),
          ],
        ),
      ],
    );
  }
}

/// Vidas da missão — cada erro apaga uma lanterna.
class _LivesHud extends StatelessWidget {
  final int current;
  final Color accent;

  const _LivesHud({
    required this.current,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    const max = 5;
    return Semantics(
      label: '$current de $max vidas. Cada erro apaga uma.',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Vidas',
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.8,
              color: AppColors.textOnDark.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 8),
          for (var i = 0; i < max; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Opacity(
              opacity: i < current ? 1 : 0.28,
              child: CustomPaint(
                size: const Size(13, 18),
                painter: LanternPainter(lit: i < current, color: accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  final bool used;
  final Color accent;
  final VoidCallback? onTap;

  const _HintChip({
    required this.used,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: used ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            color: used
                ? Colors.white.withValues(alpha: 0.05)
                : AppMetrics.accentFill(color: accent, alpha: 0.14),
            border: Border.all(
              color: used
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppMetrics.accentBorder(color: accent, alpha: 0.65),
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 15,
                color: used ? Colors.white38 : accent,
              ),
              const SizedBox(width: 5),
              Text(
                used ? 'Usada' : 'Dica',
                style: AppTypography.title(
                  size: 12,
                  color: used ? Colors.white38 : accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ChoiceState { idle, picked, correct, wrong, dimmed }

class _ChoiceTile extends StatelessWidget {
  final String letter;
  final String text;
  final _ChoiceState state;
  final bool enabled;
  final Color accent;
  final VoidCallback onTap;
  final double verticalPad;

  const _ChoiceTile({
    required this.letter,
    required this.text,
    required this.state,
    required this.enabled,
    required this.accent,
    required this.onTap,
    this.verticalPad = 13,
  });

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    final Color letterBg;
    final Color letterFg;
    final Color textColor;

    switch (state) {
      case _ChoiceState.picked:
        border = AppMetrics.accentBorder(color: accent, alpha: 0.9);
        fill = AppMetrics.accentFill(color: accent, alpha: 0.16);
        letterBg = accent;
        letterFg = AppColors.inkOnAccent;
        textColor = AppColors.textOnDark;
      case _ChoiceState.correct:
        border = accent;
        fill = AppMetrics.accentFill(color: accent, alpha: 0.22);
        letterBg = accent;
        letterFg = AppColors.inkOnAccent;
        textColor = AppColors.textOnDark;
      case _ChoiceState.wrong:
        border = AppColors.error.withValues(alpha: 0.85);
        fill = AppColors.error.withValues(alpha: 0.14);
        letterBg = AppColors.error;
        letterFg = Colors.white;
        textColor = AppColors.textOnDark;
      case _ChoiceState.dimmed:
        border = Colors.white.withValues(alpha: 0.08);
        fill = Colors.white.withValues(alpha: 0.03);
        letterBg = Colors.white.withValues(alpha: 0.06);
        letterFg = Colors.white.withValues(alpha: 0.28);
        textColor = Colors.white.withValues(alpha: 0.35);
      case _ChoiceState.idle:
        border = Colors.white.withValues(alpha: 0.16);
        fill = Colors.white.withValues(alpha: 0.06);
        letterBg = Colors.white.withValues(alpha: 0.1);
        letterFg = Colors.white.withValues(alpha: 0.8);
        textColor = Colors.white.withValues(alpha: 0.95);
    }

    final emphasized =
        state == _ChoiceState.picked ||
        state == _ChoiceState.correct ||
        state == _ChoiceState.wrong;
    final letterSize = verticalPad < 10 ? 30.0 : 34.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.fromLTRB(14, verticalPad, 16, verticalPad),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: border,
              width: emphasized ? 1.7 : 1.3,
            ),
            boxShadow: state == _ChoiceState.picked
                ? AppMetrics.cardShadow(elevated: true)
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: letterSize,
                height: letterSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: letterBg,
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: emphasized ? 0.2 : 0.08,
                    ),
                  ),
                ),
                child: Text(
                  letter,
                  style: AppTypography.title(size: 13, color: letterFg),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    size: verticalPad < 10 ? 14 : 16,
                    weight: FontWeight.w700,
                    height: 1.3,
                    color: textColor,
                  ),
                ),
              ),
              if (state == _ChoiceState.correct)
                CinematicIcon(
                  glyph: CinematicGlyph.check,
                  size: 20,
                  accent: accent,
                  framed: false,
                )
              else if (state == _ChoiceState.wrong)
                const Icon(
                  Icons.close_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
