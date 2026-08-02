import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'lamps_bar.dart';
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
    final narrative =
        widget.narrative.split('\n').where((l) => l.trim().isNotEmpty).firstOrNull ??
            widget.narrative;

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
        final showVerseSnippet = !tight && widget.verseSnippet != null;
        final lampsCompact = compact;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _stagger,
                curve: const Interval(0, 0.35, curve: Curves.easeOut),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  sidePad,
                  lampsCompact ? 4 : AppSpace.sm,
                  sidePad,
                  lampsCompact ? 6 : AppSpace.md,
                ),
                color: Colors.black.withValues(alpha: 0.38),
                child: LampsBar(
                  current: widget.lamps,
                  accent: accent,
                  labeled: true,
                  fullWidth: true,
                  compact: lampsCompact,
                ),
              ),
            ),
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
                            child: _ScenePrompt(
                              narrative: narrative,
                              question: widget.question.question,
                              verseRef: widget.question.verseRef,
                              verseSnippet: showVerseSnippet
                                  ? widget.verseSnippet
                                  : null,
                              accent: accent,
                              showHint: !locked && widget.onHint != null,
                              hintUsed: widget.hintUsed,
                              onHint: widget.onHint,
                              questionSize: questionSize,
                              compact: compact,
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
                            child: _ConfirmCta(
                              enabled: canConfirm,
                              accent: accent,
                              onTap: _confirm,
                              compact: compact,
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

class _ScenePrompt extends StatelessWidget {
  final String narrative;
  final String question;
  final String? verseRef;
  final String? verseSnippet;
  final Color accent;
  final bool showHint;
  final bool hintUsed;
  final VoidCallback? onHint;
  final double questionSize;
  final bool compact;

  const _ScenePrompt({
    required this.narrative,
    required this.question,
    required this.verseRef,
    required this.verseSnippet,
    required this.accent,
    required this.showHint,
    required this.hintUsed,
    required this.onHint,
    this.questionSize = 26,
    this.compact = false,
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
              Colors.black.withValues(alpha: 0.3),
            ],
          ),
          border: Border.all(
            color: AppColors.textOnDark.withValues(alpha: 0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              narrative,
              textAlign: TextAlign.center,
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.display(
                size: compact ? 13 : 15,
                weight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                height: 1.3,
                color: AppColors.textOnDark.withValues(alpha: 0.55),
              ),
            ),
            SizedBox(height: compact ? AppSpace.xs : AppSpace.sm),
            Container(
              width: 36,
              height: 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0),
                    accent.withValues(alpha: 0.85),
                    accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            SizedBox(height: compact ? AppSpace.sm : AppSpace.md),
            Text(
              question,
              textAlign: TextAlign.center,
              maxLines: compact ? 3 : 4,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.display(
                size: questionSize,
                weight: FontWeight.w600,
                height: 1.22,
              ),
            ),
            if (verseRef != null) ...[
              SizedBox(height: compact ? AppSpace.sm : AppSpace.section),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      showVerseStudyFromReference(context, verseRef!),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: Ink(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpace.section,
                      vertical: compact ? 6 : AppSpace.sm,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      color: accent.withValues(alpha: 0.1),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              verseRef!,
                              textAlign: TextAlign.center,
                              style: AppTypography.label(
                                size: 11,
                                color: accent,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(width: AppSpace.xs),
                            CinematicIcon(
                              glyph: CinematicGlyph.scroll,
                              size: 14,
                              accent: accent.withValues(alpha: 0.9),
                              framed: false,
                            ),
                          ],
                        ),
                        if (verseSnippet != null) ...[
                          const SizedBox(height: AppSpace.xs),
                          Text(
                            '“$verseSnippet”',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(
                              size: 12,
                              weight: FontWeight.w600,
                              height: 1.35,
                              color: AppColors.textOnDark
                                  .withValues(alpha: 0.72),
                            ).copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                        if (!compact) ...[
                          const SizedBox(height: AppSpace.xs),
                          Text(
                            'Tocar para estudar',
                            style: AppTypography.label(
                              size: 10,
                              weight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: AppColors.textOnDark
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (showHint) ...[
              SizedBox(height: compact ? 4 : AppSpace.sm),
              Align(
                alignment: Alignment.centerRight,
                child: _WhisperChip(
                  used: hintUsed,
                  accent: accent,
                  onTap: onHint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WhisperChip extends StatelessWidget {
  final bool used;
  final Color accent;
  final VoidCallback? onTap;

  const _WhisperChip({required this.used, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: used ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            color: used ? Colors.white.withValues(alpha: 0.05) : accent.withValues(alpha: 0.12),
            border: Border.all(
              color: used ? Colors.white.withValues(alpha: 0.1) : accent.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.echo,
                size: 14,
                accent: used ? Colors.white38 : accent,
                framed: false,
              ),
              const SizedBox(width: AppSpace.xs),
              Text(
                used ? 'Sussurro usado' : 'Sussurro',
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
    final double elevation;

    switch (state) {
      case _ChoiceState.picked:
        border = accent.withValues(alpha: 0.9);
        fill = Color.lerp(AppColors.nightMid, accent, 0.22)!;
        letterBg = accent;
        letterFg = AppColors.inkOnAccent;
        elevation = 1;
      case _ChoiceState.correct:
        border = accent;
        fill = Color.lerp(AppColors.nightMid, accent, 0.3)!;
        letterBg = accent;
        letterFg = AppColors.inkOnAccent;
        elevation = 1;
      case _ChoiceState.wrong:
        border = AppColors.error.withValues(alpha: 0.9);
        fill = Color.lerp(AppColors.nightMid, AppColors.error, 0.22)!;
        letterBg = AppColors.error;
        letterFg = Colors.white;
        elevation = 0;
      case _ChoiceState.dimmed:
        border = Colors.white.withValues(alpha: 0.06);
        fill = AppColors.night.withValues(alpha: 0.69);
        letterBg = Colors.white.withValues(alpha: 0.06);
        letterFg = Colors.white.withValues(alpha: 0.28);
        elevation = 0;
      case _ChoiceState.idle:
        border = Colors.white.withValues(alpha: 0.14);
        fill = AppColors.night.withValues(alpha: 0.8);
        letterBg = Colors.white.withValues(alpha: 0.08);
        letterFg = Colors.white.withValues(alpha: 0.7);
        elevation = 0;
    }

    final active = state == _ChoiceState.picked || state == _ChoiceState.correct;
    final letterSize = verticalPad < 10 ? 30.0 : 36.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: AnimatedScale(
          scale: active ? 1.015 : 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.fromLTRB(
              AppSpace.md,
              verticalPad,
              AppSpace.section,
              verticalPad,
            ),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: border,
                width: active || state == _ChoiceState.wrong ? 1.7 : 1,
              ),
              boxShadow: [
                if (active)
                  BoxShadow(
                    color: accent.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                if (elevation > 0)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
              ],
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
                    gradient: active
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(letterBg, Colors.white, 0.25)!,
                              letterBg,
                            ],
                          )
                        : null,
                    color: active ? null : letterBg,
                    border: Border.all(
                      color: active
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.45),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    letter,
                    style: AppTypography.title(size: 14, color: letterFg),
                  ),
                ),
                const SizedBox(width: AppSpace.section),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      size: verticalPad < 10 ? 14 : 16,
                      weight: FontWeight.w700,
                      height: 1.3,
                      color: Colors.white.withValues(
                        alpha: state == _ChoiceState.dimmed ? 0.35 : 0.95,
                      ),
                    ),
                  ),
                ),
                if (state == _ChoiceState.correct)
                  CinematicIcon(
                    glyph: CinematicGlyph.check,
                    size: 22,
                    accent: accent,
                    framed: false,
                  )
                else if (state == _ChoiceState.wrong)
                  const Icon(
                    Icons.close_rounded,
                    color: AppColors.error,
                    size: 22,
                  )
                else if (state == _ChoiceState.picked)
                  CinematicIcon(
                    glyph: CinematicGlyph.rise,
                    size: 18,
                    accent: accent.withValues(alpha: 0.8),
                    framed: false,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmCta extends StatelessWidget {
  final bool enabled;
  final Color accent;
  final VoidCallback onTap;
  final bool compact;

  const _ConfirmCta({
    required this.enabled,
    required this.accent,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: compact ? 13 : 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          gradient: enabled ? AppGradients.gold : null,
          color: enabled ? null : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: enabled
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.4),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          enabled ? 'CONFIRMAR RESPOSTA' : 'ESCOLHA UMA OPÇÃO',
          textAlign: TextAlign.center,
          style: enabled
              ? AppTypography.cta(size: 14)
              : AppTypography.cta(
                  size: 14,
                  color: AppColors.textOnDark.withValues(alpha: 0.38),
                ),
        ),
      ),
    );
  }
}
