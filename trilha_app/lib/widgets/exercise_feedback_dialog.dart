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

/// Veredito do ato — painel na base, mesmo para acerto e erro.
/// O palco segue visível acima: o aluno vê o versículo enquanto lê o porquê.
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

  /// Acertos seguidos — a partir de 2 aparece no título.
  final int combo;

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
    this.combo = 0,
  });

  @override
  State<ExerciseFeedbackDialog> createState() => _ExerciseFeedbackDialogState();
}

class _ExerciseFeedbackDialogState extends State<ExerciseFeedbackDialog>
    with TickerProviderStateMixin {
  String? _verseText;

  late final AnimationController _enter;
  late final AnimationController _pulse;

  /// Acerto avança sozinho: o botão enche e, cheio, segue.
  late final AnimationController _auto;
  bool _advanced = false;

  static const _autoAdvance = Duration(milliseconds: 2200);

  bool get _autoEnabled => widget.isCorrect && !widget.outOfLamps;
  late final Animation<double> _scrim;
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
    _auto = AnimationController(vsync: this, duration: _autoAdvance)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _advance();
      });
    _enter.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _pulse.repeat();
        if (_autoEnabled) _auto.forward();
      }
    });
    _scrim = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
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
    _auto.dispose();
    super.dispose();
  }

  /// Um avanço só — pelo toque ou pelo fim da contagem.
  void _advance() {
    if (_advanced || !mounted) return;
    _advanced = true;
    _auto.stop();
    widget.onContinue();
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
      setState(
        () => _verseText = SessionComposer.clipFeedbackPassage(
          existing,
          hint: hint,
          maxWords: 24,
        ),
      );
      return;
    }
    final ref = (widget.exercise.reference ?? '').trim();
    if (ref.isEmpty) return;
    final full = await BibleService.instance.passageText(
      ref,
      translationId: BibleService.palcoTranslationId,
    );
    if (!mounted || full == null || full.trim().isEmpty) return;
    setState(
      () => _verseText = SessionComposer.clipFeedbackPassage(
        full.trim(),
        hint: hint,
        maxWords: 24,
      ),
    );
  }

  Future<void> _report() async {
    // Quem vai relatar precisa de tempo: a contagem para.
    _auto.stop();
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
    const cheers = ['Acertou!', 'Isso!', 'Muito bem!', 'Na mosca!'];
    final combo = widget.combo;
    final cheer = cheers[(combo - 1).clamp(0, cheers.length - 1)];
    final title = outOfLamps
        ? 'Sem lâmpadas'
        : isCorrect
        ? (combo >= 2 ? '$cheer  ×$combo' : cheer)
        : 'Quase';
    final cta = outOfLamps
        ? 'Encerrar com passos parciais'
        : isCorrect
        ? 'Continuar'
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
              color: AppColors.scrim.withValues(
                alpha: AppColors.scrim.a * 0.55 * _scrim.value,
              ),
            ),
            child!,
          ],
        );
      },
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedBuilder(
            animation: _enter,
            builder: (context, child) {
              return Opacity(
                opacity: _scrim.value,
                child: Transform.translate(
                  offset: Offset(0, (1 - _lift.value) * 80),
                  child: child,
                ),
              );
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: RepaintBoundary(
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.screen,
                      0,
                      AppSpace.screen,
                      AppSpace.sm,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color.lerp(a.cardFill, color, 0.08),
                        borderRadius: BorderRadius.circular(AppRadii.sheet),
                        border: Border.all(
                          color: color.withValues(alpha: 0.45),
                          width: 1.4,
                        ),
                        boxShadow: [...AppTheme.cardShadow(elevated: true)],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 10, 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: FittedBox(
                                    child: _VerdictMark(
                                      glyph: glyph,
                                      color: color,
                                      enter: _enter,
                                      pulse: _pulse,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: AppTypography.display(
                                      size: 26,
                                      height: 1.1,
                                      color: color,
                                    ),
                                  ),
                                ),
                                IconButton(
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
                                    accent: a.textFaint,
                                    framed: false,
                                  ),
                                ),
                              ],
                            ),
                            if (feedback.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Text(
                                  feedback,
                                  textAlign: TextAlign.start,
                                  style: AppTypography.body(
                                    size: 14,
                                    weight: FontWeight.w700,
                                    height: 1.4,
                                    color: a.text,
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
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: AnimatedBuilder(
                                animation: _auto,
                                builder: (context, _) => CopperCta(
                                  label: cta,
                                  onTap: _advance,
                                  trailing: isCorrect
                                      ? CinematicGlyph.forward
                                      : CinematicGlyph.refresh,
                                  showArrow: false,
                                  progress: _autoEnabled ? _auto.value : null,
                                ),
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
          Interval(
            0.18,
            1,
            curve: Curves.linear,
          ).transform(enter.value).clamp(0.0, 1.0),
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
    final a = Appearance.of(context);
    return InsetPanel(
      borderColor: accent.withValues(alpha: 0.22),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: SizedBox(
        width: double.infinity,
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
                color: a.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
