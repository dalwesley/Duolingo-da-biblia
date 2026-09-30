import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../models/question_report.dart';
import '../models/trail.dart';
import '../services/bible_service.dart';
import '../services/session_composer.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
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

  /// Deixar a pergunta para o fim da cena (com [willRequeue]).
  final VoidCallback? onSkip;

  /// Abre o texto da cena por cima — reler antes de tentar de novo.
  final VoidCallback? onReadPassage;
  final String missionSlug;
  final String? trailSlug;
  final String? difficulty;
  final bool practiceMode;

  /// Acertos seguidos — a partir de 2 aparece no título.
  final int combo;

  /// Erro que revela a resposta certa e o trecho que a prova.
  final bool revealAnswer;

  /// 2º erro: o aluno escolhe tentar de novo ou pular para o fim da cena.
  final bool willRequeue;

  const ExerciseFeedbackDialog({
    super.key,
    required this.exercise,
    required this.selected,
    required this.isCorrect,
    required this.isLast,
    required this.accent,
    required this.onContinue,
    this.onSkip,
    this.onReadPassage,
    required this.missionSlug,
    this.outOfLamps = false,
    this.trailSlug,
    this.difficulty,
    this.practiceMode = false,
    this.combo = 0,
    this.revealAnswer = false,
    this.willRequeue = false,
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

  /// Tentar de novo e pular não mostram versículo nem porquê: o palco já
  /// está na tela, e o porquê entregaria a resposta.
  bool get _needsEvidence => _reveal || widget.outOfLamps;

  bool get _holdsAnswer => !widget.isCorrect && !_reveal && !widget.outOfLamps;

  bool get _reveal => !widget.isCorrect && widget.revealAnswer;

  String get _span =>
      _reveal ? (widget.exercise.evidenceSpan ?? '').trim() : '';

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
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
      curve: const Interval(0, 0.45, curve: AppMotion.enter),
    );
    _lift = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.08, 0.85, curve: AppMotion.enter),
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

  void _skip() {
    if (_advanced || !mounted) return;
    _advanced = true;
    _auto.stop();
    (widget.onSkip ?? widget.onContinue)();
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
      if (_span.isNotEmpty) _span,
      widget.exercise.prompt,
      widget.exercise.displayCue,
      widget.selected,
    ].whereType<String>().join(' ');
    if (existing.isNotEmpty) {
      setState(
        () => _verseText = SessionComposer.clipFeedbackPassage(
          existing,
          hint: hint,
          maxWords: _span.isNotEmpty ? 32 : 24,
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
        maxWords: _span.isNotEmpty ? 32 : 24,
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
    showAppToastFor(context, message: context.l10n.feedbackReportSent);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final isCorrect = widget.isCorrect;
    final accent = widget.accent;
    final outOfLamps = widget.outOfLamps;
    // Acerto = ouro; erro = risk. Sem azul nos gestos.
    final color = isCorrect ? AppRoles.action : AppRoles.error;
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final feedback = _holdsAnswer
        ? (widget.willRequeue
              ? l10n.feedbackRequeueHint
              : l10n.feedbackRereadHint)
        : _compactFeedback(
            exercise.feedbackFor(widget.selected, correct: isCorrect),
          );
    final cheers = [
      l10n.feedbackCheer1,
      l10n.feedbackCheer2,
      l10n.feedbackCheer3,
      l10n.feedbackCheer4,
    ];
    final combo = widget.combo;
    final cheer = cheers[(combo - 1).clamp(0, cheers.length - 1)];
    final reveal = _reveal;
    final answer = reveal ? (exercise.revealText ?? '').trim() : '';
    final title = outOfLamps
        ? l10n.feedbackOutOfLamps
        : isCorrect
        ? (combo >= 2 ? '$cheer  ×$combo' : cheer)
        : reveal
        ? l10n.feedbackSeeText
        : widget.willRequeue
        ? l10n.feedbackNotYet
        : l10n.feedbackAlmost;
    final cta = outOfLamps
        ? l10n.feedbackEndPartial
        : isCorrect
        ? l10n.commonContinue
        : reveal
        ? l10n.commonContinue
        : l10n.commonTryAgain;
    final canSkip = widget.willRequeue && !outOfLamps && !isCorrect;
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
                    child: GlassCard(
                      tint: color,
                      radius: AppMetrics.heroRadius,
                      elevated: true,
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
                                    size: combo >= 3 ? 28 : 24,
                                    height: 1.1,
                                    color: color,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.feedbackReportTooltip,
                                onPressed: _report,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                icon: CinematicIcon(
                                  glyph: CinematicGlyph.flag,
                                  size: AppMetrics.iconMd,
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
                          if (_holdsAnswer && widget.onReadPassage != null) ...[
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextCta(
                                label: l10n.feedbackReadPassage,
                                leading: CinematicGlyph.book,
                                color: accent,
                                onTap: widget.onReadPassage,
                              ),
                            ),
                          ],
                          if (answer.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _AnswerReveal(
                                answer: answer,
                                accent: accent,
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
                                highlight: _span,
                                highlightColor: accent,
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
                                trailing: isCorrect || reveal
                                    ? CinematicGlyph.forward
                                    : CinematicGlyph.refresh,
                                showArrow: false,
                                progress: _autoEnabled ? _auto.value : null,
                              ),
                            ),
                          ),
                          if (canSkip) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GhostCta(
                                label: l10n.feedbackSkipToEnd,
                                expanded: true,
                                matchCopper: true,
                                onTap: _skip,
                              ),
                            ),
                          ],
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
        final appear = AppMotion.pop.transform(
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

/// Resposta certa revelada no segundo erro.
class _AnswerReveal extends StatelessWidget {
  final String answer;
  final Color accent;

  const _AnswerReveal({required this.answer, required this.accent});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return InsetPanel(
      borderColor: accent.withValues(alpha: 0.4),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.feedbackAnswer,
              style: AppTypography.label(
                size: 11,
                letterSpacing: 1.2,
                color: accent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              answer,
              style: AppTypography.body(
                size: 15,
                weight: FontWeight.w700,
                height: 1.4,
                color: a.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerseWell extends StatelessWidget {
  final String reference;
  final String verse;
  final Color accent;

  /// Trecho que prova a resposta — acende dentro do versículo.
  final String highlight;
  final Color? highlightColor;

  const _VerseWell({
    required this.reference,
    required this.verse,
    required this.accent,
    this.highlight = '',
    this.highlightColor,
  });

  /// Posição do trecho no versículo, ignorando caixa e pontuação nas bordas.
  (int, int)? _spanRange() {
    final needle = highlight
        .trim()
        .replaceAll(RegExp(r'^[^\p{L}]+|[^\p{L}]+$', unicode: true), '')
        .toLowerCase();
    if (needle.isEmpty) return null;
    final i = verse.toLowerCase().indexOf(needle);
    if (i < 0) return null;
    return (i, i + needle.length);
  }

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
            () {
              final base = AppTypography.verse(
                size: 15,
                weight: FontWeight.w600,
                height: 1.4,
                color: a.textSecondary,
              );
              final range = _spanRange();
              if (range == null) {
                return Text(
                  verse,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: base,
                );
              }
              final (start, end) = range;
              final hot = highlightColor ?? accent;
              return Text.rich(
                TextSpan(
                  style: base,
                  children: [
                    TextSpan(text: verse.substring(0, start)),
                    TextSpan(
                      text: verse.substring(start, end),
                      style: base.copyWith(
                        color: a.text,
                        fontWeight: FontWeight.w800,
                        backgroundColor: hot.withValues(alpha: 0.22),
                      ),
                    ),
                    TextSpan(text: verse.substring(end)),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              );
            }(),
          ],
        ),
      ),
    );
  }
}
