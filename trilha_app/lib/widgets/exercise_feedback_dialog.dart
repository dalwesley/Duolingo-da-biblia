import 'package:flutter/material.dart';

import '../models/question_report.dart';
import '../models/trail.dart';
import '../services/bible_service.dart';
import '../services/session_composer.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'question_report_sheet.dart';
import 'ui_primitives.dart';

/// Veredito do ato — dialog no centro, ícone com pop e pulso.
class ExerciseFeedbackDialog extends StatefulWidget {
  final Exercise exercise;
  final String selected;
  final bool isCorrect;
  final bool isLast;
  final Color accent;
  final bool outOfLamps;
  final VoidCallback onContinue;
  final String missionSlug;
  final String? trailSlug;
  final String? difficulty;
  final bool practiceMode;

  const ExerciseFeedbackDialog({
    super.key,
    required this.exercise,
    required this.selected,
    required this.isCorrect,
    required this.isLast,
    required this.accent,
    required this.onContinue,
    required this.missionSlug,
    this.outOfLamps = false,
    this.trailSlug,
    this.difficulty,
    this.practiceMode = false,
  });

  @override
  State<ExerciseFeedbackDialog> createState() => _ExerciseFeedbackDialogState();
}

class _ExerciseFeedbackDialogState extends State<ExerciseFeedbackDialog>
    with TickerProviderStateMixin {
  String? _verseText;

  late final AnimationController _enter;
  late final AnimationController _pulse;
  late final Animation<double> _scrim;
  late final Animation<double> _pop;
  late final Animation<double> _lift;

  static final _verdictPrefix = RegExp(
    r'^(certo|correto|isso|sim|errado|não|nao|quase)\s*[:.!—–-]\s*',
    caseSensitive: false,
  );

  bool get _needsEvidence => !widget.isCorrect || widget.outOfLamps;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _enter.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _pulse.repeat();
      }
    });
    _scrim = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );
    _pop = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.12, 1, curve: Curves.easeOutBack),
    );
    _lift = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.08, 0.85, curve: Curves.easeOutCubic),
    );
    if (_needsEvidence) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadVerse();
      });
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _pulse.dispose();
    super.dispose();
  }

  String _compactFeedback(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return t;
    final stripped = t.replaceFirst(_verdictPrefix, '');
    if (stripped.isEmpty || stripped == t) return t;
    return stripped[0].toUpperCase() + stripped.substring(1);
  }

  Future<void> _loadVerse() async {
    final existing = (widget.exercise.passageText ?? '').trim();
    final hint = [
      widget.exercise.prompt,
      widget.exercise.displayCue,
      widget.selected,
    ].whereType<String>().join(' ');
    if (existing.isNotEmpty) {
      setState(() => _verseText = SessionComposer.clipFeedbackPassage(
            existing,
            hint: hint,
            maxWords: 24,
          ));
      return;
    }
    final ref = (widget.exercise.reference ?? '').trim();
    if (ref.isEmpty) return;
    final full = await BibleService.instance.passageText(
      ref,
      translationId: BibleService.palcoTranslationId,
    );
    if (!mounted || full == null || full.trim().isEmpty) return;
    setState(() => _verseText = SessionComposer.clipFeedbackPassage(
          full.trim(),
          hint: hint,
          maxWords: 24,
        ));
  }

  Future<void> _report() async {
    final exercise = widget.exercise;
    String? optText(String id) {
      for (final o in exercise.options) {
        if (o.id == id) return o.text;
      }
      return null;
    }

    final ok = await showQuestionReportSheet(
      context,
      buildDraft: (category, comment) => QuestionReportDraft(
        questionId: exercise.id,
        questionText: exercise.prompt,
        verseRef: exercise.reference,
        selectedOptionId: widget.selected,
        selectedOptionText: optText(widget.selected),
        correctOptionId: exercise.correctAnswer,
        correctOptionText: optText(exercise.correctAnswer),
        userWasCorrect: widget.isCorrect,
        missionSlug: widget.missionSlug,
        trailSlug: widget.trailSlug,
        difficulty: widget.difficulty,
        practiceMode: widget.practiceMode,
        category: category,
        comment: comment,
      ),
    );
    if (!mounted || !ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Relato enviado. Obrigado.',
          style: AppTypography.body(color: AppColors.textOnDark),
        ),
        backgroundColor: AppColors.nightElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final isCorrect = widget.isCorrect;
    final accent = widget.accent;
    final outOfLamps = widget.outOfLamps;
    final color = isCorrect ? accent : AppColors.error;
    final a = Appearance.of(context);
    final feedback = _compactFeedback(
      exercise.feedbackFor(widget.selected, correct: isCorrect),
    );
    final title = outOfLamps
        ? 'Sem lâmpadas'
        : isCorrect
            ? 'Acertou'
            : 'Quase';
    final cta = outOfLamps
        ? 'Encerrar com passos parciais'
        : isCorrect
            ? (widget.isLast ? 'Seguir' : 'Continuar')
            : 'Tentar de novo';
    final glyph = outOfLamps
        ? CinematicGlyph.lamp
        : isCorrect
            ? CinematicGlyph.check
            : CinematicGlyph.wrong;
    final verse = (_verseText ?? '').trim();
    final ref = (exercise.reference ?? '').trim();
    final showVerse = _needsEvidence && verse.isNotEmpty;

    return AnimatedBuilder(
      animation: _enter,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withValues(alpha: 0.58 * _scrim.value),
            ),
            child!,
          ],
        );
      },
      child: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _enter,
            builder: (context, child) {
              final pop = _pop.value;
              return Opacity(
                opacity: _scrim.value,
                child: Transform.translate(
                  offset: Offset(0, (1 - _lift.value) * 22),
                  child: Transform.scale(
                    scale: 0.84 + 0.16 * pop,
                    child: child,
                  ),
                ),
              );
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: RepaintBoundary(
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color.lerp(a.cardFill, color, 0.08),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      border: Border.all(
                        color: color.withValues(alpha: 0.45),
                        width: 1.4,
                      ),
                      boxShadow: [
                        ...AppTheme.cardShadow(elevated: true),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 10, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              tooltip: 'Relatar problema nesta pergunta',
                              onPressed: _report,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              icon: CinematicIcon(
                                glyph: CinematicGlyph.flag,
                                size: 18,
                                accent: AppColors.textOnDark.withValues(
                                  alpha: 0.38,
                                ),
                                framed: false,
                              ),
                            ),
                          ),
                          _VerdictMark(
                            glyph: glyph,
                            color: color,
                            enter: _enter,
                            pulse: _pulse,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: AppTypography.display(
                              size: 28,
                              height: 1.1,
                              color: color,
                            ),
                          ),
                          if (feedback.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(
                                feedback,
                                textAlign: TextAlign.center,
                                style: AppTypography.body(
                                  size: 15,
                                  weight: FontWeight.w700,
                                  height: 1.4,
                                  color: AppColors.textOnDark.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (showVerse) ...[
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _VerseWell(
                                reference: ref,
                                verse: verse,
                                accent: color,
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: CopperCta(
                              label: cta,
                              onTap: widget.onContinue,
                              trailing: isCorrect
                                  ? CinematicGlyph.forward
                                  : CinematicGlyph.refresh,
                              showArrow: false,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _VerdictMark extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color color;
  final Animation<double> enter;
  final Animation<double> pulse;

  const _VerdictMark({
    required this.glyph,
    required this.color,
    required this.enter,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([enter, pulse]),
      builder: (context, child) {
        final appear = Curves.easeOutBack.transform(
          Interval(0.18, 1, curve: Curves.linear)
              .transform(enter.value)
              .clamp(0.0, 1.0),
        );
        final p = pulse.value;
        final tilt = (1 - appear) * 0.18;
        return SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 2; i++)
                Opacity(
                  opacity: (1 - p) * 0.42 * appear.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.72 + p * (0.55 + i * 0.22),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: 0.5 - i * 0.12),
                          width: 1.6,
                        ),
                      ),
                      child: const SizedBox(width: 88, height: 88),
                    ),
                  ),
                ),
              Transform.rotate(
                angle: tilt,
                child: Transform.scale(
                  scale: 0.62 + 0.38 * appear.clamp(0.0, 1.15),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
      child: CinematicIcon(
        glyph: glyph,
        size: 78,
        accent: color,
        framed: true,
        glowing: true,
      ),
    );
  }
}

class _VerseWell extends StatelessWidget {
  final String reference;
  final String verse;
  final Color accent;

  const _VerseWell({
    required this.reference,
    required this.verse,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          children: [
            if (reference.isNotEmpty)
              Text(
                reference,
                textAlign: TextAlign.center,
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 1.2,
                  color: accent,
                ),
              ),
            if (reference.isNotEmpty) const SizedBox(height: 8),
            Text(
              verse,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.verse(
                size: 15,
                weight: FontWeight.w600,
                height: 1.4,
                color: AppColors.textOnDark.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
