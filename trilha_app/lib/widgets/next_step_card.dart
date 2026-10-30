import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';
import '../models/difficulty.dart';
import '../models/trail.dart';
import '../screens/paywall_screen.dart';
import '../services/analytics_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/next_step.dart';
import '../utils/trail_progress.dart';
import 'act_feel.dart';
import 'cloud_mascot.dart';
import 'immersive_background.dart';
import 'profile_plus_cards.dart';
import 'ui_primitives.dart';

String _dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Aprofundar [step]: grava o modo seguinte e abre a primeira cena dele.
Future<void> startDeepen(
  BuildContext context,
  DeepenStep step, {
  required void Function(String missionSlug) onOpenMission,
  String source = 'next_step',
}) async {
  ActHaptics.tap();
  final progress = context.read<ProgressService>();
  AnalyticsService.instance.logEvent('next_step_deepen', {
    'trail': step.trail.slug,
    'mode': step.mode.id,
    'percent': step.percent,
    'source': source,
  });
  await progress.deepenTrail(
    step.trail.slug,
    step.mode.id,
    missionSlugs: step.trail.missionSlugs,
  );
  final first = TrailProgress.getCurrentMission(
    step.trail,
    progress.completedMissions,
  );
  if (first != null) onOpenMission(first.slug);
}

/// Seu próximo passo, abaixo do herói: aprofundar a trilha recém-concluída
/// ou reforçar o gesto que mais escapa ([NextStepPicker]). Uma sugestão
/// por vez; "Agora não" esconde aquela por [NextStepPicker.snoozeDays].
class NextStepCard extends StatefulWidget {
  final List<Trail> trails;
  final void Function(String missionSlug) onOpenMission;

  const NextStepCard({
    super.key,
    required this.trails,
    required this.onOpenMission,
  });

  @override
  State<NextStepCard> createState() => _NextStepCardState();
}

class _NextStepCardState extends State<NextStepCard> {
  static const _prefsKey = 'next_step_snoozed';

  Map<String, String> _snoozed = const {};
  String? _logged;

  @override
  void initState() {
    super.initState();
    _loadSnoozed();
  }

  Future<void> _loadSnoozed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || !mounted) return;
      final map = (jsonDecode(raw) as Map).map((k, v) => MapEntry('$k', '$v'));
      setState(() => _snoozed = map);
    } catch (_) {}
  }

  Future<void> _snooze(NextStep step) async {
    ActHaptics.tap();
    AnalyticsService.instance.logEvent('next_step_snooze', {'step': step.key});
    final today = _dayKey(DateTime.now());
    final until = _dayKey(
      DateTime.now().add(const Duration(days: NextStepPicker.snoozeDays)),
    );
    final next = {
      for (final e in _snoozed.entries)
        if (e.value.compareTo(today) > 0) e.key: e.value,
      step.key: until,
    };
    setState(() => _snoozed = next);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(next));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProgressService>();
    final step = NextStepPicker.pick(
      trails: widget.trails,
      completed: p.completedMissions,
      clearedTrailModes: p.clearedTrailModes,
      trailModes: p.activeTrailModes,
      pinnedModes: p.pinnedTrailDifficulties,
      trailAnswerCorrect: p.trailAnswerCorrect,
      trailAnswerTotal: p.trailAnswerTotal,
      answerCorrect: p.answerCorrect,
      answerTotal: p.answerTotal,
      lastMissionSlug: p.lastMissionSlug,
      borrowed: p.borrowedMissions,
      snoozedUntil: _snoozed,
      today: _dayKey(DateTime.now()),
    );
    if (step == null) return const SizedBox.shrink();
    if (_logged != step.key) {
      _logged = step.key;
      AnalyticsService.instance.logEvent('next_step_view', {'step': step.key});
    }
    // Reforço é do Peregrino+: sem ele, a sugestão fica e leva ao paywall.
    final plusOpen = context.select(
      (SubscriptionService s) => s.plusFeaturesOpen,
    );
    final l10n = context.l10n;
    final (title, body, cta, onTap) = switch (step) {
      DeepenStep() => (
        l10n.nextStepDeepenTitle(step.trail.localizedTitle, step.mode.labelPt),
        deepenLine(l10n, step),
        l10n.nextStepDeepenCta,
        () => startDeepen(context, step, onOpenMission: widget.onOpenMission),
      ),
      ReinforceStep() => (
        _weakTitle(l10n, step.gesture),
        l10n.nextStepReinforceLine(step.accuracy.correct, step.accuracy.total),
        plusOpen ? l10n.nextStepReinforceCta : l10n.nextStepReinforcePlusCta,
        () {
          AnalyticsService.instance.logEvent('next_step_reinforce', {
            'gesture': step.gesture.wireId,
            'percent': step.accuracy.percent,
            'plus': plusOpen,
          });
          if (!plusOpen) {
            ActHaptics.tap();
            return Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const PaywallScreen(source: 'next_step_reinforce'),
              ),
            );
          }
          return startReinforce(
            context,
            gesture: step.gesture,
            mode: step.mode,
          );
        },
      ),
    };
    return _NextStepPanel(
      face: step is DeepenStep ? CloudFace.sucesso : CloudFace.feliz,
      title: title,
      body: body,
      cta: cta,
      onTap: onTap,
      onLater: () => _snooze(step),
    );
  }
}

/// Por que aprofundar, numa linha: o acerto e o que o modo novo pergunta.
String deepenLine(AppLocalizations l10n, DeepenStep step) =>
    step.mode == TrailDifficulty.profundezas
    ? l10n.nextStepDeepenLineProfundezas(step.percent)
    : l10n.nextStepDeepenLineCaminhada(step.percent);

/// O passo de reforço nomeado pelo que o gesto treina.
String _weakTitle(AppLocalizations l10n, ExerciseType gesture) =>
    switch (gesture) {
      ExerciseType.order => l10n.nextStepWeakOrder,
      ExerciseType.tap => l10n.nextStepWeakTap,
      ExerciseType.complete => l10n.nextStepWeakComplete,
      ExerciseType.connect => l10n.nextStepWeakConnect,
      ExerciseType.choice => l10n.nextStepWeakChoice,
      ExerciseType.trueFalse => l10n.nextStepWeakTrueFalse,
      ExerciseType.findInText ||
      ExerciseType.textSupported => l10n.nextStepWeakText,
      ExerciseType.bestInterpretation => l10n.nextStepWeakInterpret,
      _ => l10n.nextStepWeakOther(gesture.labelPt),
    };

class _NextStepPanel extends StatelessWidget {
  final CloudFace face;
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;
  final VoidCallback onLater;

  const _NextStepPanel({
    required this.face,
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return GlassCard(
      padding: AppMetrics.cardPaddingCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CloudMascot(face: face, size: 44),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.nextStepEyebrow.toUpperCase(),
                      style: AppTypography.body(
                        size: 11,
                        color: a.textSecondary,
                      ).copyWith(letterSpacing: 1.1),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      title,
                      style: AppTypography.title(size: 15, color: a.text),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      body,
                      style: AppTypography.body(
                        size: 13,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              TextCta(
                label: l10n.nextStepLater,
                onTap: onLater,
                color: a.textSecondary,
              ),
              const SizedBox(width: AppSpace.sm),
              // O rótulo do CopperCta é flexível: precisa de largura finita.
              Expanded(
                child: CopperCta(label: cta, expanded: true, onTap: onTap),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Herói sem cena para dar: nenhuma trilha aberta tem próxima cena.
/// Aprofundar a última trilha selada, se houver modo seguinte; sem
/// Peregrino+, contar que as próximas são do Plus; senão, dizer que tudo
/// foi caminhado.
class HeroEndCard extends StatelessWidget {
  final List<Trail> trails;
  final bool plusOpen;
  final void Function(String missionSlug) onOpenMission;
  final VoidCallback? onExploreTrails;

  const HeroEndCard({
    super.key,
    required this.trails,
    required this.plusOpen,
    required this.onOpenMission,
    this.onExploreTrails,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProgressService>();
    final l10n = context.l10n;
    final a = Appearance.of(context);

    DeepenStep? deepen;
    final last = p.lastMissionSlug;
    final ordered = [
      ...trails.where((t) => last != null && t.missionSlugs.contains(last)),
      ...trails,
    ];
    for (final t in ordered) {
      deepen = NextStepPicker.deepenOf(
        t,
        completed: p.completedMissions,
        clearedTrailModes: p.clearedTrailModes,
        trailModes: p.activeTrailModes,
        pinnedModes: p.pinnedTrailDifficulties,
        trailAnswerCorrect: p.trailAnswerCorrect,
        trailAnswerTotal: p.trailAnswerTotal,
        borrowed: p.borrowedMissions,
      );
      if (deepen != null) break;
    }
    final plusAhead =
        !plusOpen &&
        trails.any(
          (t) =>
              !t.comingSoon &&
              TrailProgress.nextSceneNeedsPlus(t, p.completedMissions),
        );

    final step = deepen;
    final (title, body, cta, onTap) = step != null
        ? (
            l10n.homeTrailDoneTitle,
            '${l10n.nextStepDeepenTitle(step.trail.localizedTitle, step.mode.labelPt)}. '
                '${deepenLine(l10n, step)}',
            l10n.nextStepDeepenCta,
            () => startDeepen(
              context,
              step,
              onOpenMission: onOpenMission,
              source: 'hero_end',
            ),
          )
        : plusAhead
        ? (
            l10n.heroEndPlusTitle,
            l10n.heroEndPlusBody,
            l10n.heroEndPlusCta,
            () {
              ActHaptics.tap();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PaywallScreen(source: 'hero_end'),
                ),
              );
            },
          )
        : (
            l10n.heroEndAllTitle,
            l10n.heroEndAllBody,
            l10n.homeSeeTrails,
            onExploreTrails,
          );

    return GlassCard(
      glow: 0.3,
      tint: AppRoles.presence,
      radius: AppMetrics.heroRadius,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          CloudMascot(
            face: step != null ? CloudFace.sucesso : CloudFace.feliz,
            size: 88,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 26, color: a.text),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTypography.body(color: a.textSecondary),
          ),
          if (onTap != null) ...[
            const SizedBox(height: 20),
            CopperCta(label: cta, expanded: false, onTap: onTap),
          ],
          if (onExploreTrails != null && onTap != onExploreTrails) ...[
            const SizedBox(height: AppSpace.sm),
            TextCta(
              label: l10n.homeSeeTrails,
              onTap: onExploreTrails,
              color: a.textSecondary,
            ),
          ],
        ],
      ),
    );
  }
}
