import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../models/caravan_profile_extras.dart';
import '../models/caravan_profile_prefs.dart';
import '../models/difficulty.dart';
import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../screens/explained_errors_screen.dart';
import '../screens/lesson_screen.dart';
import '../screens/paywall_screen.dart';
import '../services/analytics_service.dart';
import '../services/content_catalog_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/reading_growth.dart';
import '../utils/reinforce_picker.dart';
import '../utils/walk_stats.dart';
import 'cinematic_icon.dart';
import 'profile_privacy.dart';
import 'profile_section.dart';
import 'ui_primitives.dart';

/// Perfil · "Meu estudo": o olhar de leitor em quatro camadas — o acerto
/// de primeira num anel, as três profundidades (Observação → Compreensão →
/// Interpretação) como colunas, as últimas semanas e o mapa dos gestos
/// (Peregrino+, [plusOpen]). Erros explicados são de todos.
class ProfileAccuracyCard extends StatelessWidget {
  final bool plusOpen;

  /// Perfil de outra pessoa na caravana: o resumo publicado por ela. Sem
  /// reforço, sem erros e sem frase em segunda pessoa.
  final CaravanProfileExtras? visitor;
  final int visitorCorrect;
  final int visitorAnswered;

  const ProfileAccuracyCard({super.key, required this.plusOpen})
    : visitor = null,
      visitorCorrect = 0,
      visitorAnswered = 0;

  const ProfileAccuracyCard.visitor({
    super.key,
    required CaravanProfileExtras this.visitor,
    this.visitorCorrect = 0,
    this.visitorAnswered = 0,
  }) : plusOpen = true;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final v = visitor;
    final progress = v == null ? context.watch<ProgressService>() : null;
    final answerCorrect = v?.studyCorrect ?? progress!.answerCorrect;
    final answerTotal = v?.studyTotal ?? progress!.answerTotal;
    final weekCorrect = v?.studyWeekCorrect ?? progress!.weekAnswerCorrect;
    final weekTotal = v?.studyWeekTotal ?? progress!.weekAnswerTotal;
    final stats = WalkStats.from(
      answerCorrect: answerCorrect,
      answerTotal: answerTotal,
    );
    final weak = stats.weakest;
    final strong = stats.strongest;
    final mistakes = progress?.mistakeQuestionIds.length ?? 0;
    final lifeC = v == null
        ? progress!.lifetimeQuestionsCorrect
        : visitorCorrect;
    final lifeT = v == null
        ? progress!.lifetimeQuestionsAnswered
        : visitorAnswered;
    final weeksEmpty = !weekTotal.values.any((n) => n > 0);
    final overall = lifeT > 0
        ? Accuracy(lifeC, lifeT)
        : Accuracy(
            stats.byMode.values.fold(0, (x, m) => x + m.correct),
            stats.answered,
          );

    return ProfileSection(
      accent: AppRoles.presence,
      glyph: CinematicGlyph.target,
      title: l10n.profileStudyTitle,
      caption: l10n.profileAccuracyBody,
      trailing: PrivacyEye(
        sections: const {CaravanProfileSection.study},
        label: l10n.profileStudyTitle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Anel + evolução.
          Row(
            children: [
              _AccuracyRing(accuracy: overall),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (v == null)
                      _GrowthLine(correct: weekCorrect, total: weekTotal),
                    if (overall.total > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.studyAnswersOf(overall.correct, overall.total),
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w700,
                          color: a.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (stats.answered > 0) ...[
            const SizedBox(height: AppSpace.lg),
            _Label(l10n.studyDepthTitle),
            const SizedBox(height: AppSpace.sm),
            _DepthPillars(byMode: stats.byMode),
            if (v == null || !weeksEmpty) ...[
              const SizedBox(height: AppSpace.lg),
              _Label(l10n.studyWeeksTitle),
              const SizedBox(height: AppSpace.sm),
              _WeeksBars(correct: weekCorrect, total: weekTotal),
            ],
            const SizedBox(height: AppSpace.lg),
            _Label(l10n.studyGesturesTitle),
            if (v == null && plusOpen && stats.byGesture.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyph.target,
                    size: 12,
                    accent: a.textSecondary,
                    framed: false,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      l10n.studyGesturesTapHint,
                      style: AppTypography.body(
                        size: 12,
                        color: a.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpace.sm),
            if (plusOpen)
              stats.byGesture.isEmpty
                  ? Text(
                      l10n.profileAccuracyFewGestures(
                        WalkStats.minGestureAnswers,
                      ),
                      style: AppTypography.body(size: 12, color: a.textFaint),
                    )
                  : _GestureMap(
                      gestures: stats.byGesture,
                      strong: strong?.$1,
                      weak: weak?.$1,
                      onReinforce: v != null
                          ? null
                          : (g) => startReinforce(
                              context,
                              gesture: g,
                              mode: stats.weakestMode,
                            ),
                    )
            else
              _LockedGestures(gestures: stats.byGesture),
          ] else ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              l10n.profileAccuracyEmpty,
              style: AppTypography.body(size: 12, color: a.textSecondary),
            ),
          ],
          if (v == null) ...[
            const SizedBox(height: AppSpace.lg),
            GhostCta(
              label: mistakes == 0
                  ? l10n.profileStudyErrorsNone
                  : l10n.profileStudyErrors(mistakes),
              leading: CinematicGlyph.lamp,
              expanded: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ExplainedErrorsScreen(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppTypography.label(
      size: 10.5,
      letterSpacing: 1.2,
      weight: FontWeight.w900,
      color: Appearance.of(context).textFaint,
    ),
  );
}

/// Acerto de primeira num anel grande, com o número no meio.
class _AccuracyRing extends StatelessWidget {
  final Accuracy accuracy;

  const _AccuracyRing({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final pct = accuracy.total == 0 ? 0 : accuracy.percent;
    final tone = _tierColor(pct, a);
    final still = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      width: 104,
      height: 104,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: still ? pct / 100 : 0, end: pct / 100),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => CustomPaint(
          painter: _RingPainter(value: t, tone: tone, track: a.progressTrack),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  accuracy.total == 0 ? '—' : '${(t * 100).round()}%',
                  style: AppTypography.title(
                    size: 26,
                    weight: FontWeight.w900,
                    height: 1,
                    color: a.text,
                  ).copyWith(fontFeatures: const [FontFeature.liningFigures()]),
                ),
                Text(
                  context.l10n.studyFirstTry,
                  style: AppTypography.body(
                    size: 10.5,
                    weight: FontWeight.w800,
                    color: a.textSecondary,
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

/// Faixas de acerto: firme (verde), formando (âmbar), a reforçar (coral).
Color _tierColor(int pct, AppearanceStyle a) => pct >= 85
    ? a.ink(AppRoles.success)
    : pct >= 65
    ? a.ink(AppRoles.lamp)
    : a.ink(AppRoles.navTrails);

class _RingPainter extends CustomPainter {
  final double value;
  final Color tone;
  final Color track;

  _RingPainter({required this.value, required this.tone, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 6;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = track,
    );
    if (value <= 0) return;
    final sweep = 2 * math.pi * value;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..color = tone.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + sweep,
          colors: [tone.withValues(alpha: 0.6), tone],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.tone != tone || old.track != track;
}

/// Três cartões, um por profundidade, na cor do modo: ícone, acerto,
/// barra fina (0–100, honesta entre modos) e quantas respostas sustentam o
/// número. Sem resposta, o cartão fica apagado — um convite, não uma falha.
class _DepthPillars extends StatelessWidget {
  final Map<TrailDifficulty, Accuracy> byMode;

  const _DepthPillars({required this.byMode});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final still = MediaQuery.disableAnimationsOf(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, mode) in TrailDifficulty.values.indexed) ...[
            if (i > 0) const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Builder(
                builder: (context) {
                  final acc = byMode[mode] ?? const Accuracy(0, 0);
                  final empty = acc.total == 0;
                  final tone = a.ink(DifficultyVisuals.accentFor(mode));
                  // Modo vazio logo depois de um já jogado: é o próximo
                  // passo, não um buraco.
                  final isNext =
                      empty &&
                      i > 0 &&
                      (byMode[TrailDifficulty.values[i - 1]]?.total ?? 0) > 0;
                  return Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      gradient: empty
                          ? null
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                tone.withValues(alpha: 0.18),
                                tone.withValues(alpha: 0.04),
                              ],
                            ),
                      color: empty ? tone.withValues(alpha: 0.03) : null,
                      border: Border.all(
                        color: tone.withValues(
                          alpha: empty ? (isNext ? 0.35 : 0.18) : 0.45,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tone.withValues(
                                  alpha: empty ? 0.06 : 0.18,
                                ),
                                border: Border.all(
                                  color: tone.withValues(
                                    alpha: empty ? 0.25 : 0.5,
                                  ),
                                ),
                              ),
                              child: CinematicIcon(
                                glyph: DifficultyVisuals.glyphFor(mode),
                                size: 14,
                                accent: empty
                                    ? tone.withValues(alpha: 0.6)
                                    : tone,
                                framed: false,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                empty
                                    ? l10n.studyDepthToExplore
                                    : '${acc.percent}%',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style:
                                    AppTypography.title(
                                      size: empty ? 11.5 : 18,
                                      weight: FontWeight.w900,
                                      height: 1.1,
                                      color: empty ? a.textFaint : a.text,
                                    ).copyWith(
                                      fontFeatures: const [
                                        FontFeature.liningFigures(),
                                      ],
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: SizedBox(
                            height: 5,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ColoredBox(color: a.progressTrack),
                                if (!empty)
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(
                                      begin: still ? acc.percent / 100 : 0,
                                      end: acc.percent / 100,
                                    ),
                                    duration: Duration(
                                      milliseconds: 900 + i * 150,
                                    ),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, t, _) =>
                                        FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: t.clamp(0.0, 1.0),
                                          child: ColoredBox(color: tone),
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mode.labelPt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 11.5,
                            weight: FontWeight.w800,
                            color: empty ? a.textFaint : a.text,
                          ),
                        ),
                        Text(
                          isNext
                              ? l10n.studyDepthNext
                              : empty
                              ? l10n.studyDepthNone
                              : l10n.studyDepthAnswers(acc.total),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 10.5,
                            color: a.textFaint,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Acerto das últimas 8 semanas (todas as profundidades), a atual acesa.
class _WeeksBars extends StatelessWidget {
  final Map<String, int> correct;
  final Map<String, int> total;

  const _WeeksBars({required this.correct, required this.total});

  static const weeks = 8;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final now = DateTime.now();
    final keys = [
      for (var i = weeks - 1; i >= 0; i--)
        ReadingGrowth.weekKey(now.subtract(Duration(days: 7 * i))),
    ];
    final c = <String, int>{}, t = <String, int>{};
    for (final e in total.entries) {
      final w = e.key.split('.').first;
      t[w] = (t[w] ?? 0) + e.value;
      c[w] = (c[w] ?? 0) + (correct[e.key] ?? 0);
    }
    if (keys.every((w) => (t[w] ?? 0) == 0)) {
      return Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.seed,
            size: 13,
            accent: a.textSecondary,
            framed: false,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              context.l10n.studyWeeksEmpty,
              style: AppTypography.body(size: 12, color: a.textSecondary),
            ),
          ),
        ],
      );
    }
    const h = 52.0;
    return SizedBox(
      height: h + 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, w) in keys.indexed) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Builder(
                builder: (context) {
                  final tot = t[w] ?? 0;
                  final pct = tot == 0 ? 0 : ((c[w] ?? 0) * 100 / tot).round();
                  final current = i == keys.length - 1;
                  final tone = _tierColor(pct, a);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (tot > 0)
                        Text(
                          '$pct',
                          style: AppTypography.label(
                            size: 9,
                            weight: FontWeight.w900,
                            color: current ? a.text : a.textFaint,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Container(
                        height: tot == 0 ? 4 : math.max(6, h * pct / 100),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: tot == 0
                              ? a.progressTrack
                              : tone.withValues(alpha: current ? 1 : 0.55),
                          boxShadow: current && tot > 0
                              ? [
                                  BoxShadow(
                                    color: tone.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mapa dos gestos: uma linha por gesto, do mais firme ao a reforçar, com
/// barra de acerto na cor da faixa. O ponto forte e o a reforçar ganham
/// etiqueta; o ícone do gesto fica sempre o mesmo. Com [onReinforce], cada
/// linha abre o reforço daquele gesto.
class _GestureMap extends StatefulWidget {
  final List<(ExerciseType, Accuracy)> gestures;
  final ExerciseType? strong;
  final ExerciseType? weak;
  final Future<void> Function(ExerciseType gesture)? onReinforce;

  const _GestureMap({
    required this.gestures,
    this.strong,
    this.weak,
    this.onReinforce,
  });

  @override
  State<_GestureMap> createState() => _GestureMapState();
}

class _GestureMapState extends State<_GestureMap> {
  ExerciseType? _busy;

  Future<void> _tap(ExerciseType g) async {
    if (_busy != null) return;
    setState(() => _busy = g);
    try {
      await widget.onReinforce!(g);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strong = widget.strong, weak = widget.weak;
    final sorted = [...widget.gestures]
      ..sort((x, y) => y.$2.percent.compareTo(x.$2.percent));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, (g, acc)) in sorted.indexed) ...[
          if (i > 0) const SizedBox(height: 6),
          _GestureRow(
            busy: _busy == g,
            onTap: widget.onReinforce == null || _busy != null
                ? null
                : () => _tap(g),
            gesture: g,
            accuracy: acc,
            index: i,
            tag: g == strong
                ? _GestureTag.strong
                : g == weak
                ? _GestureTag.weak
                : null,
          ),
        ],
      ],
    );
  }
}

enum _GestureTag { strong, weak }

class _GestureRow extends StatelessWidget {
  final ExerciseType gesture;
  final Accuracy accuracy;
  final int index;
  final _GestureTag? tag;
  final bool busy;
  final VoidCallback? onTap;

  const _GestureRow({
    required this.gesture,
    required this.accuracy,
    required this.index,
    this.tag,
    this.busy = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final pct = accuracy.percent;
    final tone = _tierColor(pct, a);
    final still = MediaQuery.disableAnimationsOf(context);
    final tagTone = tag == _GestureTag.weak
        ? a.ink(AppRoles.lamp)
        : a.ink(AppRoles.success);
    final tappable = onTap != null || busy;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CinematicIcon(
              glyph: gestureGlyphOf(gesture),
              size: 14,
              accent: a.textSecondary,
              framed: false,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                gesture.labelPt,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body(
                  size: 13,
                  weight: FontWeight.w800,
                  color: a.text,
                ),
              ),
            ),
            if (tag != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.fromLTRB(5, 2, 7, 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  color: tagTone.withValues(alpha: 0.14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CinematicIcon(
                      glyph: tag == _GestureTag.weak
                          ? CinematicGlyph.target
                          : CinematicGlyph.crown,
                      size: 10,
                      accent: tagTone,
                      framed: false,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      tag == _GestureTag.weak
                          ? l10n.profileAccuracyToStrengthen
                          : l10n.profileAccuracyStrongest,
                      style: AppTypography.label(
                        size: 9.5,
                        weight: FontWeight.w900,
                        color: tagTone,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            Text(
              '$pct%',
              style: AppTypography.title(
                size: 13,
                weight: FontWeight.w900,
                color: tone,
              ).copyWith(fontFeatures: const [FontFeature.liningFigures()]),
            ),
            if (tappable) ...[
              const SizedBox(width: 4),
              SizedBox(
                width: 14,
                height: 14,
                child: busy
                    ? CircularProgressIndicator(
                        color: a.textSecondary,
                        strokeWidth: 1.6,
                      )
                    : ListChevron(color: a.textFaint, size: 14),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: a.progressTrack),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: still ? pct / 100 : 0, end: pct / 100),
                  duration: Duration(milliseconds: 800 + index * 90),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: t.clamp(0.0, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: LinearGradient(
                          colors: [tone.withValues(alpha: 0.55), tone],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    final radius = BorderRadius.circular(AppRadii.sm);
    final tile = Ink(
      decoration: BoxDecoration(
        borderRadius: radius,
        color: tag == _GestureTag.weak
            ? tagTone.withValues(alpha: 0.08)
            : a.text.withValues(alpha: 0.04),
        border: Border.all(
          color: tag == _GestureTag.weak
              ? tagTone.withValues(alpha: 0.55)
              : a.text.withValues(alpha: 0.10),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
      child: body,
    );
    if (!tappable) {
      return Material(type: MaterialType.transparency, child: tile);
    }
    return Semantics(
      button: true,
      label: l10n.reinforceCta(gesture.labelPt),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(borderRadius: radius, onTap: onTap, child: tile),
      ),
    );
  }
}

/// Sem Peregrino+: o mapa existe, desfocado, com o convite por cima.
class _LockedGestures extends StatelessWidget {
  final List<(ExerciseType, Accuracy)> gestures;

  const _LockedGestures({required this.gestures});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: IgnorePointer(
            child: _GestureMap(
              gestures: gestures.isEmpty
                  ? const [
                      (ExerciseType.choice, Accuracy(8, 10)),
                      (ExerciseType.order, Accuracy(6, 10)),
                      (ExerciseType.connect, Accuracy(9, 10)),
                    ]
                  : gestures,
            ),
          ),
        ),
        const _PlusGestureNudge(),
      ],
    );
  }
}

/// "Sua leitura": a maior evolução entre os modos, ou o aviso de que ela
/// aparece depois de algumas semanas.
class _GrowthLine extends StatelessWidget {
  final Map<String, int> correct;
  final Map<String, int> total;

  const _GrowthLine({required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final up = ReadingGrowth.best(correct: correct, total: total);
    String text;
    var glyph = CinematicGlyph.rise;
    if (up != null) {
      text = l10n.profileGrowthUp(up.mode.labelPt, up.fromPct, up.toPct);
    } else {
      ReadingGrowth? steady;
      for (final mode in TrailDifficulty.values) {
        final g = ReadingGrowth.forMode(mode, correct: correct, total: total);
        if (g != null && (steady == null || g.toPct > steady.toPct)) {
          steady = g;
        }
      }
      if (steady != null) {
        text = l10n.profileGrowthSteady(steady.mode.labelPt, steady.toPct);
      } else {
        text = l10n.profileGrowthWaiting;
        glyph = CinematicGlyph.seed;
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CinematicIcon(
          glyph: glyph,
          size: AppMetrics.chipIcon,
          accent: AppRoles.presence,
          framed: false,
        ),
        const SizedBox(width: AppSpace.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.title(size: 14, color: a.text),
          ),
        ),
      ],
    );
  }
}

/// Sem Peregrino+: o convite por cima do mapa desfocado.
class _PlusGestureNudge extends StatelessWidget {
  const _PlusGestureNudge();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        color: a.cardFill.withValues(alpha: 0.92),
        border: Border.all(color: AppRoles.reward.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.lock,
            size: 14,
            accent: AppRoles.reward,
            framed: false,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              context.l10n.profilePlusGestureNudge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(size: 12, color: a.textSecondary),
            ),
          ),
          TextCta(
            label: context.l10n.profilePlusGestureNudgeCta,
            color: AppRoles.reward,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PaywallScreen(source: 'profile_gestures'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reforço do ponto fraco: até 5 perguntas do gesto mais fraco, das cenas
/// já feitas (só nos modos que a pessoa já usa), em modo prática.
/// Reforço do [gesture] (o [mode] mais fraco primeiro): até 5 perguntas das
/// últimas cenas feitas, em modo prática. Usado pelo cartão de Minha
/// caminhada e pelo Seu próximo passo da Home.
Future<void> startReinforce(
  BuildContext context, {
  required ExerciseType gesture,
  TrailDifficulty? mode,
}) async {
  const recentScenes = 12;
  const maxTrails = 4;
  final progress = context.read<ProgressService>();
  final trails = await TrailRepository().getTrails();
  final trailOf = <String, Trail>{
    for (final t in trails)
      for (final mod in t.modules)
        for (final m in mod.missions) m.slug: t,
  };
  final recent = progress.completedMissions.reversed
      .where(trailOf.containsKey)
      .take(recentScenes)
      .toList();
  final trailSlugs = {
    for (final slug in recent) trailOf[slug]!.slug,
  }.take(maxTrails).toSet();
  for (final slug in trailSlugs) {
    await ContentCatalogService.instance.ensureTrailBank(slug);
  }

  final pool = <ReinforceCandidate>[];
  for (final slug in recent) {
    final trail = trailOf[slug]!.slug;
    if (!trailSlugs.contains(trail)) continue;
    final modes = {
      ?TrailDifficulty.fromId(progress.difficultyForTrail(trail)),
      for (final id in progress.clearedTrailModes[trail] ?? const <String>[])
        ?TrailDifficulty.fromId(id),
    };
    if (modes.isEmpty) modes.add(TrailDifficulty.semente);
    for (final mode in modes) {
      final qs = await QuestionBank.instance.listForMission(
        difficulty: mode,
        moduleTitle: null,
        section: slug,
        trailSlug: trail,
      );
      pool.addAll([
        for (final q in qs) (id: q.id, type: q.type, mode: q.difficulty),
      ]);
    }
  }
  final ids = ReinforcePicker.pick(
    pool: pool,
    gesture: gesture,
    mode: mode,
    mistakes: progress.mistakeQuestionIds.toSet(),
    used: progress.usedQuestionIds.toSet(),
  );
  if (!context.mounted) return;
  final l10n = context.l10n;
  if (ids.isEmpty) {
    showAppToastFor(context, message: l10n.reinforceEmpty);
    return;
  }
  AnalyticsService.instance.logEvent('reinforce_start', {
    'gesture': gesture.wireId,
    'mode': mode?.id ?? 'any',
    'questions': ids.length,
  });
  final mission = Mission(
    slug: 'reinforce-${gesture.wireId}',
    title: l10n.reinforceMissionTitle(gesture.labelPt),
    intro: l10n.reinforceMissionIntro(gesture.labelPt),
    type: 'lesson',
    stepsReward: 30,
    questions: const [],
  );
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => LessonScreen(
        missionSlug: mission.slug,
        practiceMode: true,
        missionOverride: mission,
        questionIdsOverride: ids,
        requiresPlus: true,
      ),
    ),
  );
}
