import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../models/question_report.dart';
import '../models/trail.dart';
import '../services/bible_service.dart';
import '../services/session_composer.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'evidence_verse.dart';
import 'immersive_background.dart';
import 'question_report_sheet.dart';
import 'anan_speech.dart';
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

  /// Acerto avança sozinho: o botão enche e, cheio, segue.
  late final AnimationController _auto;
  bool _advanced = false;

  /// Tocou no painel: a pessoa quer ler com calma, a contagem para de vez.
  bool _held = false;

  static const _autoAdvance = Duration(milliseconds: 2200);

  /// Acerto com o trecho aceso: tempo para ler as palavras que provaram.
  static const _autoAdvanceWithVerse = Duration(milliseconds: 3600);

  bool get _autoEnabled => widget.isCorrect && !widget.outOfLamps && !_held;
  late final Animation<double> _scrim;
  late final Animation<double> _lift;

  static final _verdictPrefix = RegExp(
    r'^(certo|correto|isso|sim|errado|não|nao|quase)\s*[:.!—–-]\s*',
    caseSensitive: false,
  );

  /// Tentar de novo e pular não mostram versículo nem porquê: o palco já
  /// está na tela, e o porquê entregaria a resposta. No acerto, o versículo
  /// volta só quando o banco diz qual trecho provou (V3).
  bool get _needsEvidence => _reveal || widget.outOfLamps || _spanOnCorrect;

  bool get _spanOnCorrect =>
      widget.isCorrect &&
      !widget.exercise.type.isRevealOnly &&
      (widget.exercise.evidenceSpan ?? '').trim().isNotEmpty;

  bool get _holdsAnswer => !widget.isCorrect && !_reveal && !widget.outOfLamps;

  bool get _reveal => !widget.isCorrect && widget.revealAnswer;

  String get _span => _reveal || _spanOnCorrect
      ? (widget.exercise.evidenceSpan ?? '').trim()
      : '';

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: AppMotion.slow)
      ..forward();
    _auto =
        AnimationController(
          vsync: this,
          duration: _spanOnCorrect ? _autoAdvanceWithVerse : _autoAdvance,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) _advance();
        });
    _enter.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
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
    _auto.dispose();
    super.dispose();
  }

  void _hold() {
    if (_held || !_autoEnabled) return;
    _auto.stop();
    setState(() => _held = true);
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
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final feedback = _holdsAnswer
        ? (widget.willRequeue
              ? l10n.feedbackRequeueHint
              : exercise.textHint ?? l10n.feedbackRereadHint)
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
    final face = outOfLamps
        ? CloudFace.triste
        : isCorrect
        ? CloudFace.sucesso
        : CloudFace.erro;
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
              constraints: const BoxConstraints(maxWidth: 560),
              child: RepaintBoundary(
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.sm,
                      0,
                      AppSpace.sm,
                      AppSpace.sm,
                    ),
                    child: Listener(
                      onPointerDown: (_) => _hold(),
                      child: GlassCard(
                        radius: AppMetrics.heroRadius,
                        elevated: true,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 8),
                                Center(
                                  child: SizedBox(
                                    width: 96,
                                    height: 96,
                                    child: _VerdictMark(
                                      face: face,
                                      enter: _enter,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpace.sm),
                                // O veredito e o porquê saem da boca do Anan.
                                AnanSpeechBubble(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    16,
                                    20,
                                    18,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        title,
                                        textAlign: TextAlign.center,
                                        style: AppTypography.display(
                                          size: combo >= 3 ? 32 : 28,
                                          height: 1.1,
                                          color: AnanSpeechBubble.ink,
                                        ),
                                      ),
                                      if (feedback.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          feedback,
                                          textAlign: TextAlign.center,
                                          style: AppTypography.body(
                                            size: 18,
                                            height: 1.45,
                                            color: AnanSpeechBubble.ink,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (_holdsAnswer &&
                                    widget.onReadPassage != null) ...[
                                  const SizedBox(height: 4),
                                  Center(
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
                                  _AnswerReveal(answer: answer, accent: accent),
                                ],
                                if (showVerse) ...[
                                  const SizedBox(height: 16),
                                  EvidenceVerse(
                                    reference: ref,
                                    verse: verse,
                                    accent: AppRoles.presence,
                                    highlight: _span,
                                    highlightColor: AppRoles.presence,
                                    verseSize: 19,
                                  ),
                                ],
                                const SizedBox(height: 16),
                                AnimatedBuilder(
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
                                if (canSkip) ...[
                                  const SizedBox(height: 8),
                                  GhostCta(
                                    label: l10n.feedbackSkipToEnd,
                                    expanded: true,
                                    matchCopper: true,
                                    onTap: _skip,
                                  ),
                                ],
                              ],
                            ),
                            Positioned(
                              top: -4,
                              right: -10,
                              child: IconButton(
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
  final CloudFace face;
  final Animation<double> enter;

  const _VerdictMark({required this.face, required this.enter});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: enter,
      builder: (context, child) {
        final appear = AppMotion.pop.transform(
          const Interval(0.18, 1).transform(enter.value).clamp(0.0, 1.0),
        );
        return Transform.scale(
          scale: 0.72 + 0.28 * appear.clamp(0.0, 1.0),
          child: child,
        );
      },
      child: CloudMascot(face: face, size: 96),
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
