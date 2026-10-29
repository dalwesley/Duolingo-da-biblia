import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../models/difficulty.dart';
import '../models/exercise.dart';
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
import '../utils/reinforce_picker.dart';
import '../utils/walk_stats.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'plus_perks.dart';
import 'relic_panel.dart';
import 'ui_primitives.dart';

/// Perfil · Peregrino+ · "Meu estudo": acerto de primeira por modo, o
/// gesto firme e o que reforçar, e as duas ações (treinar o ponto fraco e
/// rever os erros explicados) num card só.
class ProfileAccuracyCard extends StatelessWidget {
  const ProfileAccuracyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final progress = context.watch<ProgressService>();
    final stats = WalkStats.from(
      answerCorrect: progress.answerCorrect,
      answerTotal: progress.answerTotal,
    );
    final strong = stats.strongest;
    final weak = stats.weakest;
    final mistakes = progress.mistakeQuestionIds.length;

    return GlassCard(
      tint: AppRoles.presence,
      glow: 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelicChapter(
            title: l10n.profileStudyTitle,
            divided: false,
            accent: AppRoles.presence,
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            stats.answered == 0
                ? l10n.profileAccuracyEmpty
                : l10n.profileAccuracyBody,
            style: AppTypography.body(size: 12, color: a.textSecondary),
          ),
          if (stats.answered > 0) ...[
            const SizedBox(height: AppSpace.md),
            for (final mode in TrailDifficulty.values) ...[
              _MeterRow(label: mode.labelPt, accuracy: stats.byMode[mode]!),
              const SizedBox(height: AppSpace.md),
            ],
            if (strong != null || weak != null)
              Row(
                children: [
                  if (strong != null)
                    Expanded(
                      child: _Highlight(
                        glyph: CinematicGlyph.rise,
                        label: l10n.profileAccuracyStrongest,
                        gesture: strong.$1,
                        accuracy: strong.$2,
                      ),
                    ),
                  if (strong != null && weak != null)
                    const SizedBox(width: AppSpace.sm),
                  if (weak != null)
                    Expanded(
                      child: _Highlight(
                        glyph: CinematicGlyph.target,
                        label: l10n.profileAccuracyToStrengthen,
                        gesture: weak.$1,
                        accuracy: weak.$2,
                      ),
                    ),
                ],
              )
            else
              Text(
                l10n.profileAccuracyFewGestures(WalkStats.minGestureAnswers),
                style: AppTypography.body(size: 12, color: a.textFaint),
              ),
          ],
          const SizedBox(height: AppSpace.md),
          if (weak != null) ...[
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

/// Perfil Plus: caminho para "Seus erros explicados" — a página com os
/// erros guardados, a resposta certa e o porquê de cada um.
class ExplainedErrorsCard extends StatelessWidget {
  const ExplainedErrorsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final count = context.watch<ProgressService>().mistakeQuestionIds.length;
    return GlassCard(
      tint: AppRoles.presence,
      glow: 0.4,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ExplainedErrorsScreen(),
          ),
        ),
        child: Row(
          children: [
            CinematicIcon(
              glyph: CinematicGlyph.lamp,
              size: AppMetrics.leadingIcon,
              accent: AppRoles.reward,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.explainErrorsTitle,
                    style: AppTypography.title(size: 15, color: a.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count == 0
                        ? l10n.explainErrorsEmptyBody
                        : l10n.explainErrorsEntry(count),
                    style: AppTypography.body(size: 12, color: a.textSecondary),
                  ),
                ],
              ),
            ),
            CinematicIcon(
              glyph: CinematicGlyph.path,
              size: AppMetrics.iconMd,
              accent: a.textFaint,
              framed: false,
            ),
          ],
        ),
      ),
    );
  }
}

/// Perfil sem Peregrino+: um cartão só no lugar da constância e do acerto.
class ProfilePlusTeaser extends StatelessWidget {
  const ProfilePlusTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    // Palco dourado no máximo: entre os cards azuis do perfil, a oferta
    // precisa ler como o único lugar que pede a assinatura.
    return GlassCard(
      tint: AppRoles.reward,
      glow: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.plus,
                size: AppMetrics.leadingIcon,
                accent: AppRoles.reward,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Text(
                  l10n.profilePlusTeaserTitle,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          const PlusPerkCard(boxed: false),
          const SizedBox(height: AppSpace.lg),
          CopperCta(
            label: l10n.weeklyReviewSeePlus,
            expanded: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PaywallScreen(source: 'profile'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeterRow extends StatelessWidget {
  final String label;
  final Accuracy accuracy;

  const _MeterRow({required this.label, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final empty = accuracy.total == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.title(size: 14, color: a.text),
              ),
            ),
            Text(
              empty
                  ? l10n.profileAccuracyNoAnswers
                  : l10n.profileAccuracyLine(
                      accuracy.percent,
                      accuracy.correct,
                      accuracy.total,
                    ),
              style: AppTypography.body(size: 12, color: a.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AppProgressBar(
          value: empty ? 0 : accuracy.percent / 100,
          color: AppRoles.presence,
        ),
      ],
    );
  }
}

class _Highlight extends StatelessWidget {
  final CinematicGlyph glyph;
  final String label;
  final ExerciseType gesture;
  final Accuracy accuracy;

  const _Highlight({
    required this.glyph,
    required this.label,
    required this.gesture,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: a.insetFill,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: a.insetBorder),
      ),
      child: Row(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: AppMetrics.iconLg,
            accent: a.chrome,
            framed: false,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body(size: 12, color: a.textSecondary),
                ),
                Text(
                  gesture.labelPt,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
              ],
            ),
          ),
          Text(
            '${accuracy.percent}%',
            style: AppTypography.title(size: 15, color: a.text),
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
