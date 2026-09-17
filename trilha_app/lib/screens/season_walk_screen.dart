import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/question_bank.dart';
import '../data/season_walk_catalog.dart';
import '../models/difficulty.dart';
import '../models/season_walk.dart';
import '../models/trail.dart';
import '../services/content_catalog_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'lesson_screen.dart';
import 'paywall_screen.dart';

void openSeasonWalk(BuildContext context) {
  final progress = context.read<ProgressService>();
  final mode = progress.settings.appearanceMode;
  final appearance = AppearanceStyle.resolve(mode);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) => Appearance(
        mode: mode,
        style: appearance,
        child: const SeasonWalkScreen(),
      ),
    ),
  );
}

class SeasonWalkScreen extends StatelessWidget {
  const SeasonWalkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final progress = context.watch<ProgressService>();
    final sub = context.watch<SubscriptionService>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final campaign = SeasonWalkCatalog.current(today);
    final todayIndex = campaign.dayIndexOn(today);
    final done = progress.walkDatesFor(campaign.id).length;
    final inWindow = campaign.contains(today);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ImmersiveBackground(
        child: SafeArea(
          child: Column(
            children: [
              TopBar(
                title: campaign.title,
                subtitle: campaign.subtitle,
                onBack: () => Navigator.pop(context),
                leadingGlyph: CinematicGlyph.calendar,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.screen,
                    AppSpace.md,
                    AppSpace.screen,
                    AppSpace.xl,
                  ),
                  children: [
                    GlassCard(
                      elevated: true,
                      padding: AppMetrics.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inWindow
                                ? 'Dia ${todayIndex ?? '—'} de ${campaign.length}'
                                : campaign.start.isAfter(today)
                                    ? 'Começa em ${_daysUntil(campaign.start, today)} dias'
                                    : 'Temporada encerrada',
                            style: AppTypography.title(size: 16, color: a.text),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Gratuito: 3 primeiros dias · depois, Peregrino+',
                            style: AppTypography.body(
                              size: 13,
                              color: a.textMuted(0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: campaign.length == 0
                                ? 0
                                : (done / campaign.length).clamp(0, 1),
                            minHeight: AppMetrics.progressHeight,
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.accent,
                            backgroundColor: a.textMuted(0.12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$done / ${campaign.length} dias caminhados',
                            style: AppTypography.body(
                              size: 12,
                              color: a.textMuted(0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.section),
                    for (var w = 0; w < campaign.weekCount; w++) ...[
                      _WeekBlock(
                        campaign: campaign,
                        weekIndex: w,
                        today: today,
                        todayIndex: todayIndex,
                        proConfigured: sub.isConfigured,
                        isPro: sub.isPeregrinoPlus,
                      ),
                      const SizedBox(height: AppSpace.lg),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static int _daysUntil(DateTime start, DateTime today) =>
      start.difference(today).inDays;
}

class _WeekBlock extends StatelessWidget {
  final SeasonWalkCampaign campaign;
  final int weekIndex;
  final DateTime today;
  final int? todayIndex;
  final bool proConfigured;
  final bool isPro;

  const _WeekBlock({
    required this.campaign,
    required this.weekIndex,
    required this.today,
    required this.todayIndex,
    required this.proConfigured,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final progress = context.watch<ProgressService>();
    final days = campaign.week(weekIndex);
    final doneCount = days
        .where(
          (d) => progress.isWalkDateDone(
            campaign.id,
            _ymd(d.dateOn(campaign.start)),
          ),
        )
        .length;
    final weekEnded = days.isNotEmpty &&
        !days.last.dateOn(campaign.start).isAfter(today);
    final reviewReady = weekEnded && doneCount >= (days.length / 2).ceil();
    final reviewLocked = reviewReady && proConfigured && !isPro;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Semana ${weekIndex + 1}',
          style: AppTypography.title(size: 14, color: a.text),
        ),
        const SizedBox(height: 8),
        for (final day in days)
          _DayTile(
            campaign: campaign,
            day: day,
            today: today,
            todayIndex: todayIndex,
            proConfigured: proConfigured,
            isPro: isPro,
          ),
        if (reviewReady) ...[
          const SizedBox(height: 8),
          if (reviewLocked)
            GhostCta(
              label: 'Revisão da semana · Peregrino+',
              leading: CinematicGlyph.lock,
              expanded: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                );
              },
            )
          else
            CopperCta(
              label: 'Revisão da semana',
              expanded: true,
              onTap: () {
                final progress = context.read<ProgressService>();
                final mode = progress.settings.appearanceMode;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Appearance(
                      mode: mode,
                      style: AppearanceStyle.resolve(mode),
                      child: SeasonWalkReviewScreen(
                        campaign: campaign,
                        weekIndex: weekIndex,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  final SeasonWalkCampaign campaign;
  final SeasonWalkDay day;
  final DateTime today;
  final int? todayIndex;
  final bool proConfigured;
  final bool isPro;

  const _DayTile({
    required this.campaign,
    required this.day,
    required this.today,
    required this.todayIndex,
    required this.proConfigured,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final progress = context.watch<ProgressService>();
    final date = day.dateOn(campaign.start);
    final ymd = _ymd(date);
    final done = progress.isWalkDateDone(campaign.id, ymd) ||
        progress.isMissionCompleted(day.missionSlug);
    final access = SeasonWalkCatalog.access(
      campaign: campaign,
      index: day.index,
      today: today,
      proConfigured: proConfigured,
      isPro: isPro,
    );
    final isToday = todayIndex == day.index;
    final locked = !access.playable;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: AppMetrics.cardPaddingCompact,
        child: InkWell(
          onTap: () => _open(context, access, done),
          child: Row(
            children: [
              CinematicIcon(
                glyph: locked
                    ? CinematicGlyph.lock
                    : done
                        ? CinematicGlyph.check
                        : CinematicGlyph.calendar,
                size: 36,
                accent: done
                    ? AppColors.accent
                    : isToday
                        ? AppColors.accent
                        : a.textMuted(0.45),
                framed: false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dia ${day.index} · ${day.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 14, color: a.text),
                    ),
                    Text(
                      access.needsPro
                          ? 'Peregrino+ a partir do dia 4'
                          : access.future
                              ? 'Ainda não é hoje'
                              : day.insight,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 12,
                        color: a.textMuted(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    SeasonWalkAccess access,
    bool done,
  ) async {
    if (access.future) return;
    if (access.needsPro) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }
    if (!access.playable) return;
    await ContentCatalogService.instance.ensureTrailBank(day.trailSlug);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          missionSlug: day.missionSlug,
          skipTrailLock: true,
        ),
      ),
    );
    if (!context.mounted) return;
    final progress = context.read<ProgressService>();
    if (progress.isMissionCompleted(day.missionSlug) || done) {
      await progress.markWalkDate(campaign.id, _ymd(day.dateOn(campaign.start)));
    }
  }
}

class SeasonWalkReviewScreen extends StatefulWidget {
  final SeasonWalkCampaign campaign;
  final int weekIndex;

  const SeasonWalkReviewScreen({
    super.key,
    required this.campaign,
    required this.weekIndex,
  });

  @override
  State<SeasonWalkReviewScreen> createState() => _SeasonWalkReviewScreenState();
}

class _SeasonWalkReviewScreenState extends State<SeasonWalkReviewScreen> {
  bool _loading = false;

  List<SeasonWalkDay> get _days => widget.campaign.week(widget.weekIndex);

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ImmersiveBackground(
        child: SafeArea(
          child: Column(
            children: [
              TopBar(
                title: 'Revisão da semana ${widget.weekIndex + 1}',
                subtitle: widget.campaign.title,
                onBack: () => Navigator.pop(context),
                leadingGlyph: CinematicGlyph.scroll,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.screen,
                    AppSpace.md,
                    AppSpace.screen,
                    AppSpace.xl,
                  ),
                  children: [
                    Text(
                      'Os 7 “Hoje:” desta semana',
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    const SizedBox(height: 12),
                    for (final day in _days)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          padding: AppMetrics.cardPaddingCompact,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dia ${day.index} · ${day.title}',
                                style: AppTypography.body(
                                  size: 12,
                                  color: a.textMuted(0.55),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hoje: ${day.insight}',
                                style: AppTypography.title(
                                  size: 15,
                                  color: a.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpace.lg),
                    CopperCta(
                      label: _loading ? 'Preparando…' : '3 atos de revisão',
                      expanded: true,
                      onTap: _loading ? null : _startReview,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startReview() async {
    setState(() => _loading = true);
    final progress = context.read<ProgressService>();
    final slugs = {for (final d in _days) d.trailSlug};
    for (final slug in slugs) {
      await ContentCatalogService.instance.ensureTrailBank(slug);
    }
    final ids = <String>[];
    for (final day in _days) {
      if (ids.length >= 3) break;
      final pool = await QuestionBank.instance.listForMission(
        difficulty: TrailDifficulty.fromId(
              progress.difficultyForTrail(day.trailSlug),
            ) ??
            TrailDifficulty.semente,
        moduleTitle: null,
        section: day.missionSlug,
        trailSlug: day.trailSlug,
      );
      if (pool.isEmpty) continue;
      final id = SeasonWalkAccess.pickReviewActId(
        poolIds: pool.map((q) => q.id),
        mistakeIds: progress.mistakeQuestionIds,
        usedIds: progress.usedQuestionIds,
      );
      if (id != null) ids.add(id);
    }
    if (!mounted) return;
    setState(() => _loading = false);
    if (ids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ainda não há atos desta semana no aparelho. Abra um dia primeiro.',
            style: AppTypography.body(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
      );
      return;
    }
    final review = Mission(
      slug: 'walk-review-${widget.campaign.id}-${widget.weekIndex}',
      title: 'Revisão da semana',
      intro: 'Três atos dos textos que você já andou.',
      type: 'lesson',
      stepsReward: 30,
      questions: const [],
      centralInsight: _days.map((d) => d.insight).take(3).join(' · '),
    );
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          missionSlug: review.slug,
          practiceMode: true,
          missionOverride: review,
          questionIdsOverride: ids,
        ),
      ),
    );
  }
}

String _ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
