import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../data/guided_reading_plans.dart';
import '../models/bible_reading_plan.dart';
import '../services/analytics_service.dart';
import '../services/bible_reading_plan_service.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/app_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/juntos_chrome.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'bible_screen.dart';
import 'paywall_screen.dart';

/// Plano de leitura — canônico ou cronológico, no tempo que couber no dia.
class BibleReadingPlanScreen extends StatefulWidget {
  const BibleReadingPlanScreen({super.key});

  @override
  State<BibleReadingPlanScreen> createState() => _BibleReadingPlanScreenState();
}

class _BibleReadingPlanScreenState extends State<BibleReadingPlanScreen> {
  BibleReadingOrder _draftOrder = BibleReadingOrder.canonical;
  int _draftMinutes = 15;
  DailyReadingPortion? _portion;
  ({
    int totalChapters,
    int remainingChapters,
    double totalMinutes,
    double remainingMinutes,
    int estimatedDays,
  })?
  _preview;
  bool _loading = true;

  /// Minutos médios por dia de cada plano guiado (cartões da escolha).
  Map<String, double> _guidedMinutes = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    final progress = context.read<ProgressService>();
    final plan = progress.bibleReadingPlan;
    setState(() => _loading = true);

    if (plan.active) {
      _draftOrder = plan.order;
      _draftMinutes = plan.minutesPerDay;
      final skipped = await progress.syncBibleReadingPlanWithReadChapters();
      if (!mounted) return;
      final synced = progress.bibleReadingPlan;
      final portion = await BibleReadingPlanService.instance.portionFor(
        plan: synced,
        readKeys: progress.readBibleChapters.toSet(),
      );
      if (!mounted) return;
      setState(() {
        _portion = portion;
        _preview = null;
        _loading = false;
      });
      if (skipped > 0 && mounted) {
        showAppToastFor(
          context,
          message: context.l10n.planSkippedChaptersToast(skipped),
          glyph: CinematicGlyph.book,
        );
      }
    } else {
      final preview = await BibleReadingPlanService.instance.previewStats(
        order: _draftOrder,
        minutesPerDay: _draftMinutes,
        readKeys: progress.readBibleChapters.toSet(),
      );
      final minutes = <String, double>{
        for (final def in GuidedReadingPlan.all)
          def.id: await BibleReadingPlanService.instance.guidedMinutesPerDay(
            def,
          ),
      };
      if (!mounted) return;
      setState(() {
        _portion = null;
        _preview = preview;
        _guidedMinutes = minutes;
        _loading = false;
      });
    }
  }

  Future<void> _refreshPreview() async {
    final progress = context.read<ProgressService>();
    final preview = await BibleReadingPlanService.instance.previewStats(
      order: _draftOrder,
      minutesPerDay: _draftMinutes,
      readKeys: progress.readBibleChapters.toSet(),
    );
    if (!mounted) return;
    setState(() => _preview = preview);
  }

  Future<void> _start() async {
    await context.read<ProgressService>().startBibleReadingPlan(
      order: _draftOrder,
      minutesPerDay: _draftMinutes,
    );
    await _reload();
  }

  /// Planos guiados são do Peregrino+; sem ele, o paywall.
  Future<void> _startGuided(GuidedReadingPlan def) async {
    final sub = context.read<SubscriptionService>();
    AnalyticsService.instance.logPlusFeatureOpen(
      feature: 'guided_plan',
      hasPlus: sub.hasPlus,
    );
    if (!sub.plusFeaturesOpen) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const PaywallScreen(source: 'reading_plan'),
        ),
      );
      return;
    }
    await context.read<ProgressService>().startGuidedReadingPlan(def.id);
    await _reload();
  }

  Future<void> _setReminder(int? hour) async {
    final progress = context.read<ProgressService>();
    await progress.setBibleReadingReminder(hour);
    await NotificationService.instance.syncFromProgress(progress);
  }

  Future<void> _completeDay() async {
    final portion = _portion;
    if (portion == null || portion.finished || portion.chapters.isEmpty) return;
    await context.read<ProgressService>().completeBibleReadingPortion(
      toCursor: portion.toCursor,
      chapters: [
        for (final c in portion.chapters)
          (abbrev: c.abbrev, chapter: c.chapter),
      ],
    );
    if (!mounted) return;
    final progress = context.read<ProgressService>();
    if (progress.bibleReadingPlan.reminderHour != null) {
      await NotificationService.instance.syncFromProgress(progress);
      if (!mounted) return;
    }
    showAppToastFor(
      context,
      message: context.l10n.planDayDoneToast(portion.chapters.length),
      glyph: CinematicGlyph.book,
    );
    await _reload();
  }

  Future<void> _openChapter(PlanChapterRef chapter) async {
    await BibleReaderScreen.open(
      context,
      '${chapter.bookName} ${chapter.chapter}',
    );
    if (mounted) await _reload();
  }

  Future<void> _confirmClear() async {
    final ok = await showAppConfirm(
      context,
      title: context.l10n.planEndConfirmTitle,
      body: context.l10n.planEndConfirmBody,
      confirmLabel: context.l10n.planEndConfirmAction,
      danger: true,
    );
    if (!ok || !mounted) return;
    await context.read<ProgressService>().clearBibleReadingPlan();
    _draftOrder = BibleReadingOrder.canonical;
    _draftMinutes = 15;
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final style = AppearanceStyle.resolve(mode);
    final plan = context.watch<ProgressService>().bibleReadingPlan;

    return Appearance(
      mode: mode,
      style: style,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ImmersiveBackground(
          appearance: style,
          frameChild: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              0,
              MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
              0,
              MediaQuery.viewPaddingOf(context).bottom + AppSpace.xl,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screen,
                ),
                child: TopBar(
                  inline: true,
                  immersive: true,
                  dark: style.onDark,
                  title: context.l10n.planTitle,
                  subtitle: plan.active
                      ? (GuidedReadingPlan.byId(
                              plan.guidedId,
                            )?.title(context.l10n) ??
                            plan.order.shortLabel)
                      : context.l10n.planAtYourPace,
                  leadingGlyph: CinematicGlyph.book,
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: AppSpace.afterTopBar),
              ContentFrame(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.screen,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: AppSpinner(),
                        )
                      else if (plan.active)
                        _ActivePlanBody(
                          plan: plan,
                          portion: _portion,
                          onOpen: _openChapter,
                          onComplete: _completeDay,
                          onClear: _confirmClear,
                          onReminder: _setReminder,
                          onMinutesChanged: (m) async {
                            await context
                                .read<ProgressService>()
                                .updateBibleReadingPlanMinutes(m);
                            await _reload();
                          },
                        )
                      else
                        _SetupPlanBody(
                          order: _draftOrder,
                          minutes: _draftMinutes,
                          preview: _preview,
                          onOrder: (o) {
                            setState(() => _draftOrder = o);
                            _refreshPreview();
                          },
                          onMinutes: (m) {
                            setState(() => _draftMinutes = m);
                            _refreshPreview();
                          },
                          onStart: _start,
                          guidedMinutes: _guidedMinutes,
                          guidedLocked: !context
                              .watch<SubscriptionService>()
                              .plusFeaturesOpen,
                          onStartGuided: _startGuided,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupPlanBody extends StatelessWidget {
  final BibleReadingOrder order;
  final int minutes;
  final ({
    int totalChapters,
    int remainingChapters,
    double totalMinutes,
    double remainingMinutes,
    int estimatedDays,
  })?
  preview;
  final ValueChanged<BibleReadingOrder> onOrder;
  final ValueChanged<int> onMinutes;
  final VoidCallback onStart;
  final Map<String, double> guidedMinutes;
  final bool guidedLocked;
  final ValueChanged<GuidedReadingPlan> onStartGuided;

  const _SetupPlanBody({
    required this.order,
    required this.minutes,
    required this.preview,
    required this.onOrder,
    required this.onMinutes,
    required this.onStart,
    required this.guidedMinutes,
    required this.guidedLocked,
    required this.onStartGuided,
  });

  static const _minuteOptions = [5, 10, 15, 20, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final days = preview?.estimatedDays;
    final remainingHours = preview == null
        ? null
        : (preview!.remainingMinutes / 60).round();
    final alreadyRead = preview == null
        ? 0
        : preview!.totalChapters - preview!.remainingChapters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.planSetupQuestion,
          style: AppTypography.title(size: 20, color: a.text),
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          context.l10n.planSetupBody,
          style: AppTypography.body(
            size: 14,
            height: 1.45,
            color: a.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpace.section),
        SectionLabel(context.l10n.planSectionOrder),
        const SizedBox(height: AppSpace.sm),
        _OrderToggle(value: order, onChanged: onOrder),
        const SizedBox(height: AppSpace.section),
        SectionLabel(context.l10n.planSectionTime),
        const SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in _minuteOptions)
              AppSelectChip(
                label: context.l10n.planMinutes(m),
                selected: minutes == m,
                onTap: () => onMinutes(m),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.section),
        if (preview != null)
          GlassCard(
            padding: const EdgeInsets.all(AppSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(
                  label: context.l10n.planEstimate,
                  trailing: SoftBadge(
                    text: order.shortLabel,
                    accent: a.chrome,
                    glyph: CinematicGlyph.book,
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                if (alreadyRead > 0) ...[
                  _StatRow(
                    label: context.l10n.planAlreadyRead,
                    value: context.l10n.planChaptersSkipped(alreadyRead),
                  ),
                  const SizedBox(height: 6),
                ],
                _StatRow(
                  label: context.l10n.planRemaining,
                  value: remainingHours == null
                      ? '—'
                      : remainingHours == 0
                      ? context.l10n.planApproxMinutes(
                          preview!.remainingMinutes.round(),
                        )
                      : context.l10n.planApproxHours(remainingHours),
                ),
                const SizedBox(height: 6),
                _StatRow(
                  label: context.l10n.planAtYourPace,
                  value: days == null || days == 0
                      ? (preview!.remainingChapters == 0
                            ? context.l10n.planAllRead
                            : '—')
                      : days >= 365
                      ? context.l10n.planApproxMonths((days / 30).round())
                      : context.l10n.planApproxDays(days),
                ),
                const SizedBox(height: 6),
                _StatRow(
                  label: context.l10n.planPendingChapters,
                  value: '${preview!.remainingChapters}',
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpace.section),
        CopperCta(
          label: context.l10n.planStartCta(minutes),
          onTap: onStart,
          trailing: null,
        ),
        const SizedBox(height: AppSpace.section),
        Row(
          children: [
            Expanded(child: SectionLabel(context.l10n.guidedPlansHeader)),
            SoftBadge(
              text: context.l10n.paywallTitle,
              glyph: CinematicGlyph.crown,
              accent: AppRoles.reward,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          context.l10n.guidedPlansBody,
          style: AppTypography.body(size: 13, color: a.textSecondary),
        ),
        const SizedBox(height: AppSpace.sm),
        for (final def in GuidedReadingPlan.all) ...[
          _GuidedPlanTile(
            def: def,
            minutesPerDay: guidedMinutes[def.id],
            locked: guidedLocked,
            onTap: () => onStartGuided(def),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _GuidedPlanTile extends StatelessWidget {
  final GuidedReadingPlan def;
  final double? minutesPerDay;
  final bool locked;
  final VoidCallback onTap;

  const _GuidedPlanTile({
    required this.def,
    required this.minutesPerDay,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final m = minutesPerDay;
    return GlassCard(
      padding: AppMetrics.cardPaddingCompact,
      onTap: onTap,
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.book,
            size: AppMetrics.leadingIcon,
            accent: AppRoles.reward,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  def.title(l10n),
                  style: AppTypography.title(size: 15, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  m == null
                      ? def.subtitle(l10n)
                      : l10n.guidedPlanMeta(
                          def.subtitle(l10n),
                          m.round().clamp(1, 120),
                        ),
                  style: AppTypography.body(size: 12, color: a.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          locked
              ? CinematicIcon(
                  glyph: CinematicGlyph.lock,
                  size: AppMetrics.iconMd,
                  accent: a.textFaint,
                  framed: false,
                )
              : ListChevron(color: a.textFaint),
        ],
      ),
    );
  }
}

class _ActivePlanBody extends StatelessWidget {
  final BibleReadingPlan plan;
  final DailyReadingPortion? portion;
  final ValueChanged<PlanChapterRef> onOpen;
  final VoidCallback onComplete;
  final VoidCallback onClear;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<int?> onReminder;

  const _ActivePlanBody({
    required this.plan,
    required this.portion,
    required this.onOpen,
    required this.onComplete,
    required this.onClear,
    required this.onMinutesChanged,
    required this.onReminder,
  });

  static const _reminderHours = [6, 7, 8, 12, 19, 21];

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final p = portion;
    final doneToday = plan.doneToday;
    final finished = p?.finished == true;
    final guided = GuidedReadingPlan.byId(plan.guidedId);
    final planLabel = guided?.title(context.l10n) ?? plan.order.shortLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                label: context.l10n.commonToday,
                trailing: SoftBadge(
                  text: doneToday
                      ? context.l10n.planDone
                      : guided != null
                      ? context.l10n.guidedPlanDayOf(
                          (plan.cursor + 1).clamp(1, guided.days),
                          guided.days,
                        )
                      : context.l10n.planMinutes(plan.minutesPerDay),
                  accent: doneToday ? AppRoles.success : a.chrome,
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                finished
                    ? (guided != null
                          ? context.l10n.guidedPlanFinished(planLabel)
                          : context.l10n.planBibleFinished)
                    : (p?.summary ?? '…'),
                style: AppTypography.title(size: 18, color: a.text),
              ),
              if (p != null && !finished) ...[
                const SizedBox(height: 4),
                Text(
                  context.l10n.planPortionMeta(
                    p.estimatedMinutes.round(),
                    p.chapters.length,
                    planLabel,
                  ),
                  style: AppTypography.body(size: 13, color: a.textSecondary),
                ),
              ],
              const SizedBox(height: AppSpace.sm),
              Text(
                context.l10n.planReadingDays(plan.completedDays),
                style: AppTypography.body(size: 12, color: a.textFaint),
              ),
            ],
          ),
        ),
        if (p != null && !finished) ...[
          const SizedBox(height: AppSpace.section),
          SectionLabel(context.l10n.planTodayChapters),
          const SizedBox(height: AppSpace.sm),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < p.chapters.length; i++) ...[
                  if (i > 0) const ListDivider(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onOpen(p.chapters[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.md,
                          vertical: AppSpace.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.chapters[i].label,
                                style: AppTypography.title(
                                  size: 14,
                                  color: a.text,
                                ),
                              ),
                            ),
                            Text(
                              context.l10n.planApproxMinutesDecimal(
                                p.chapters[i].estimatedMinutes.toStringAsFixed(
                                  1,
                                ),
                              ),
                              style: AppTypography.body(
                                size: 12,
                                color: a.textFaint,
                              ),
                            ),
                            const SizedBox(width: 4),
                            ListChevron(color: a.textFaint),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          if (!doneToday)
            CopperCta(
              label: context.l10n.planMarkDayRead,
              onTap: onComplete,
              trailing: null,
            )
          else
            GlassCard(
              padding: const EdgeInsets.all(AppSpace.md),
              child: Text(
                context.l10n.planTodayDoneBody,
                style: AppTypography.body(
                  size: 14,
                  height: 1.4,
                  color: a.textSecondary,
                ),
              ),
            ),
        ],
        // No guiado o dia já vem pronto: sem ajuste de tempo.
        if (guided == null) ...[
          const SizedBox(height: AppSpace.section),
          SectionLabel(context.l10n.planAdjustTime),
          const SizedBox(height: AppSpace.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in const [5, 10, 15, 20, 30, 45, 60])
                AppSelectChip(
                  label: context.l10n.planMinutes(m),
                  selected: plan.minutesPerDay == m,
                  onTap: () => onMinutesChanged(m),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpace.section),
        SectionLabel(context.l10n.planReminderHeader),
        const SizedBox(height: AppSpace.xs),
        Text(
          context.l10n.planReminderBody,
          style: AppTypography.body(size: 13, color: a.textSecondary),
        ),
        const SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppSelectChip(
              label: context.l10n.planReminderOff,
              selected: plan.reminderHour == null,
              onTap: () => onReminder(null),
            ),
            for (final h in _reminderHours)
              AppSelectChip(
                label: context.l10n.planReminderHour(
                  h.toString().padLeft(2, '0'),
                ),
                selected: plan.reminderHour == h,
                onTap: () => onReminder(h),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.section),
        TextCta(label: context.l10n.planEndCta, onTap: onClear, danger: true),
      ],
    );
  }
}

class _OrderToggle extends StatelessWidget {
  final BibleReadingOrder value;
  final ValueChanged<BibleReadingOrder> onChanged;

  const _OrderToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const orders = BibleReadingOrder.planOrders;
    return AppSegmentedTabs(
      index: orders.indexOf(value),
      accent: AppRoles.presence,
      onChanged: (i) => onChanged(orders[i]),
      items: [
        for (final o in orders)
          (label: o.shortLabel, glyph: null, mark: null, alert: false),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
        ),
        Text(
          value,
          style: AppTypography.body(
            size: 13,
            weight: FontWeight.w800,
            color: a.text,
          ),
        ),
      ],
    );
  }
}
