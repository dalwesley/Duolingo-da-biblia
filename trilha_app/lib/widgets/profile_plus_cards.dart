import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
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
import 'profile_section.dart';
import 'ui_primitives.dart';

/// Perfil · "Meu estudo": o olhar de leitor em quatro camadas — o acerto
/// de primeira num anel, as três profundidades (Observação → Compreensão →
/// Interpretação) como colunas, as últimas semanas e o mapa dos gestos
/// (Peregrino+, [plusOpen]). Erros explicados são de todos.
class ProfileAccuracyCard extends StatelessWidget {
  final bool plusOpen;

  const ProfileAccuracyCard({super.key, required this.plusOpen});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final progress = context.watch<ProgressService>();
    final stats = WalkStats.from(
      answerCorrect: progress.answerCorrect,
      answerTotal: progress.answerTotal,
    );
    final weak = stats.weakest;
    final strong = stats.strongest;
    final mistakes = progress.mistakeQuestionIds.length;
    final lifeC = progress.lifetimeQuestionsCorrect;
    final lifeT = progress.lifetimeQuestionsAnswered;
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
                    _GrowthLine(
                      correct: progress.weekAnswerCorrect,
                      total: progress.weekAnswerTotal,
                    ),
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
            const SizedBox(height: AppSpace.lg),
            _Label(l10n.studyWeeksTitle),
            const SizedBox(height: AppSpace.sm),
            _WeeksBars(
              correct: progress.weekAnswerCorrect,
              total: progress.weekAnswerTotal,
            ),
            const SizedBox(height: AppSpace.lg),
            _Label(l10n.studyGesturesTitle),
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
          const SizedBox(height: AppSpace.lg),
          if (plusOpen && weak != null) ...[
            _ReinforceButton(gesture: weak.$1, mode: stats.weakestMode),
            const SizedBox(height: AppSpace.sm),
          ],
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

/// Três colunas, uma por profundidade, na cor do modo. Sem resposta, a
/// coluna fica em contorno — um convite, não uma falha.
class _DepthPillars extends StatelessWidget {
  final Map<TrailDifficulty, Accuracy> byMode;

  const _DepthPillars({required this.byMode});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final still = MediaQuery.disableAnimationsOf(context);
    const barH = 78.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final (i, mode) in TrailDifficulty.values.indexed) ...[
          if (i > 0) const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Builder(
              builder: (context) {
                final acc = byMode[mode] ?? const Accuracy(0, 0);
                final empty = acc.total == 0;
                final tone = a.ink(DifficultyVisuals.accentFor(mode));
                return Column(
                  children: [
                    Text(
                      empty ? l10n.studyDepthToExplore : '${acc.percent}%',
                      style:
                          AppTypography.title(
                            size: empty ? 11 : 16,
                            weight: FontWeight.w900,
                            color: empty ? a.textFaint : a.text,
                          ).copyWith(
                            fontFeatures: const [FontFeature.liningFigures()],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: barH,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        color: empty ? null : tone.withValues(alpha: 0.08),
                        border: Border.all(
                          color: tone.withValues(alpha: empty ? 0.35 : 0.25),
                          width: empty ? 1.2 : 1,
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: empty
                          ? Center(
                              child: CinematicIcon(
                                glyph: DifficultyVisuals.glyphFor(mode),
                                size: 22,
                                accent: tone.withValues(alpha: 0.5),
                                framed: false,
                              ),
                            )
                          : TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: still ? acc.percent / 100 : 0,
                                end: acc.percent / 100,
                              ),
                              duration: Duration(milliseconds: 900 + i * 150),
                              curve: Curves.easeOutCubic,
                              builder: (context, t, _) => FractionallySizedBox(
                                heightFactor: t.clamp(0.04, 1.0),
                                widthFactor: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.sm - 1,
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        tone.withValues(alpha: 0.55),
                                        tone,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: tone.withValues(alpha: 0.4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.topCenter,
                                  padding: const EdgeInsets.only(top: 6),
                                  child: CinematicIcon(
                                    glyph: DifficultyVisuals.glyphFor(mode),
                                    size: 16,
                                    accent: DifficultyVisuals.inkOn(mode),
                                    framed: false,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mode.labelPt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 11,
                        weight: FontWeight.w800,
                        color: empty ? a.textFaint : a.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
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

/// Mapa dos gestos: um chip por gesto, colorido pelo acerto; o firme leva
/// coroa e o a reforçar, o alvo.
class _GestureMap extends StatelessWidget {
  final List<(ExerciseType, Accuracy)> gestures;
  final ExerciseType? strong;
  final ExerciseType? weak;

  const _GestureMap({required this.gestures, this.strong, this.weak});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final sorted = [...gestures]
      ..sort((x, y) => y.$2.percent.compareTo(x.$2.percent));
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (g, acc) in sorted)
          Builder(
            builder: (context) {
              final tone = _tierColor(acc.percent, a);
              final mark = g == strong
                  ? CinematicGlyph.crown
                  : g == weak
                  ? CinematicGlyph.target
                  : null;
              return Container(
                padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  color: tone.withValues(alpha: 0.14),
                  border: Border.all(
                    color: tone.withValues(alpha: mark != null ? 0.8 : 0.35),
                    width: mark != null ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CinematicIcon(
                      glyph: mark ?? gestureGlyphOf(g),
                      size: 13,
                      accent: tone,
                      framed: false,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      g.labelPt,
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w800,
                        color: a.text,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${acc.percent}%',
                      style: AppTypography.title(
                        size: 12,
                        weight: FontWeight.w900,
                        color: tone,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
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

class _ReinforceButton extends StatefulWidget {
  final ExerciseType gesture;
  final TrailDifficulty? mode;

  const _ReinforceButton({required this.gesture, this.mode});

  @override
  State<_ReinforceButton> createState() => _ReinforceButtonState();
}

class _ReinforceButtonState extends State<_ReinforceButton> {
  bool _loading = false;

  Future<void> _start() async {
    setState(() => _loading = true);
    await startReinforce(context, gesture: widget.gesture, mode: widget.mode);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CopperCta(
      label: _loading
          ? l10n.reinforcePreparing
          : l10n.reinforceCta(widget.gesture.labelPt),
      leading: CinematicGlyph.target,
      expanded: true,
      onTap: _loading ? null : _start,
    );
  }
}
