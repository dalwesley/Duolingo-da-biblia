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
///
/// [setup]: abre na escolha da Bíblia inteira mesmo com um plano ativo
/// (trocar de plano a partir da aba Planos).
class BibleReadingPlanScreen extends StatefulWidget {
  final bool setup;

  const BibleReadingPlanScreen({super.key, this.setup = false});

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
  late bool _setupMode = widget.setup;

  /// Avanço do plano ativo: capítulos lidos da sequência, ou dias do guiado.
  ({int done, int total})? _progress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    final progress = context.read<ProgressService>();
    final plan = progress.bibleReadingPlan;
    setState(() => _loading = true);

    if (plan.active && !_setupMode) {
      _draftOrder = plan.order;
      _draftMinutes = plan.minutesPerDay;
      final skipped = await progress.syncBibleReadingPlanWithReadChapters();
      if (!mounted) return;
      final synced = progress.bibleReadingPlan;
      final readKeys = progress.readBibleChapters.toSet();
      final guided = GuidedReadingPlan.byId(synced.guidedId);
      final sequence = guided == null
          ? await BibleReadingPlanService.instance.buildSequence(synced.order)
          : null;
      final portion = await BibleReadingPlanService.instance.portionFor(
        plan: synced,
        readKeys: readKeys,
        sequence: sequence,
      );
      if (!mounted) return;
      setState(() {
        _portion = portion;
        _progress = sequence != null
            ? (
                done: sequence
                    .where(
                      (c) => readKeys.contains(
                        ProgressService.bibleChapterKey(c.abbrev, c.chapter),
                      ),
                    )
                    .length,
                total: sequence.length,
              )
            : (done: synced.cursor.clamp(0, guided!.days), total: guided.days);
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
      if (!mounted) return;
      setState(() {
        _portion = null;
        _preview = preview;
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
    final progress = context.read<ProgressService>();
    if (progress.bibleReadingPlan.active) {
      final ok = await showAppConfirm(
        context,
        title: context.l10n.planSwitchTitle,
        body: context.l10n.planSwitchBody,
        confirmLabel: context.l10n.modeSwitch,
      );
      if (!ok || !mounted) return;
    }
    await progress.startBibleReadingPlan(
      order: _draftOrder,
      minutesPerDay: _draftMinutes,
    );
    _setupMode = false;
    await _reload();
  }

  /// Plano guiado sem Peregrino+: o paywall; ao voltar, recarrega.
  Future<void> _openPaywall() async {
    final sub = context.read<SubscriptionService>();
    AnalyticsService.instance.logPlusFeatureOpen(
      feature: 'reading_plan',
      hasPlus: sub.hasPlus,
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PaywallScreen(source: 'reading_plan'),
      ),
    );
    if (!mounted) return;
    await NotificationService.instance.syncFromProgress(
      context.read<ProgressService>(),
    );
    if (mounted) setState(() {});
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
    final plusOpen = context.watch<SubscriptionService>().plusFeaturesOpen;
    final showActive = plan.active && !_setupMode;

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
                  subtitle: showActive
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
                      else if (showActive)
                        _ActivePlanBody(
                          plan: plan,
                          portion: _portion,
                          locked: plan.lockedToday(plusOpen: plusOpen),
                          onUnlock: _openPaywall,
                          progress: _progress,
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

  /// Sem Plus: avisa dos dias grátis junto do botão.

  const _SetupPlanBody({
    required this.order,
    required this.minutes,
    required this.preview,
    required this.onOrder,
    required this.onMinutes,
    required this.onStart,
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
        GlassCard(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(
                label: context.l10n.planSectionOrder,
                glyph: CinematicGlyph.book,
              ),
              const SizedBox(height: AppSpace.sm),
              _OrderToggle(value: order, onChanged: onOrder),
              const SizedBox(height: AppSpace.md),
              const ListDivider(),
              const SizedBox(height: AppSpace.md),
              CardHeader(
                label: context.l10n.planSectionTime,
                glyph: CinematicGlyph.hourglass,
              ),
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
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
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
      ],
    );
  }
}

class _ActivePlanBody extends StatelessWidget {
  final BibleReadingPlan plan;
  final DailyReadingPortion? portion;
  final ({int done, int total})? progress;

  /// Dias grátis gastos e sem Plus: no lugar dos capítulos, o convite.
  final bool locked;
  final VoidCallback onUnlock;
  final ValueChanged<PlanChapterRef> onOpen;
  final VoidCallback onComplete;
  final VoidCallback onClear;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<int?> onReminder;

  const _ActivePlanBody({
    required this.plan,
    required this.portion,
    required this.progress,
    required this.locked,
    required this.onUnlock,
    required this.onOpen,
    required this.onComplete,
    required this.onClear,
    required this.onMinutesChanged,
    required this.onReminder,
  });

  static const _minuteOptions = [5, 10, 15, 20, 30, 45, 60];
  static const _reminderHours = [6, 7, 8, 12, 19, 21];

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final p = portion;
    final doneToday = plan.doneToday;
    final finished = p?.finished == true;
    final guided = GuidedReadingPlan.byId(plan.guidedId);
    final planLabel = guided?.title(l10n) ?? plan.order.shortLabel;
    final chapters = p == null || finished
        ? const <PlanChapterRef>[]
        : p.chapters;
    final pr = progress;
    final ratio = pr == null || pr.total == 0 ? 0.0 : pr.done / pr.total;
    final percent = (ratio * 100).floor();

    final String headline;
    if (finished) {
      headline = guided != null
          ? l10n.guidedPlanFinished(planLabel)
          : l10n.planBibleFinished;
    } else if (doneToday) {
      headline = l10n.planCardDoneToday;
    } else {
      headline = p?.summary ?? '…';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hoje: o que ler, quanto falta e a ação — tudo no mesmo card.
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardHeader(
                      label: l10n.commonToday,
                      trailing: SoftBadge(
                        text: doneToday || finished
                            ? l10n.planDone
                            : locked
                            ? l10n.paywallTitle
                            : guided != null
                            ? l10n.guidedPlanDayOf(
                                (plan.cursor + 1).clamp(1, guided.days),
                                guided.days,
                              )
                            : l10n.planDayNumber(plan.completedDays + 1),
                        glyph: doneToday || finished
                            ? CinematicGlyph.check
                            : locked
                            ? CinematicGlyph.crown
                            : null,
                        accent: doneToday || finished
                            ? AppRoles.success
                            : locked
                            ? AppRoles.reward
                            : a.chrome,
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      headline,
                      style: AppTypography.title(size: 20, color: a.text),
                    ),
                    const SizedBox(height: 4),
                    if (doneToday && !finished)
                      Text(
                        l10n.planTodayDoneBody,
                        style: AppTypography.body(
                          size: 13,
                          height: 1.4,
                          color: a.textSecondary,
                        ),
                      )
                    else if (p != null && !finished)
                      Text(
                        l10n.planPortionMeta(
                          p.estimatedMinutes.round(),
                          p.chapters.length,
                        ),
                        style: AppTypography.body(
                          size: 13,
                          color: a.textSecondary,
                        ),
                      ),
                    if (pr != null) ...[
                      const SizedBox(height: AppSpace.md),
                      AppProgressBar(
                        value: ratio,
                        color: doneToday || finished ? AppRoles.success : null,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              guided != null
                                  ? l10n.planProgressGuided(percent)
                                  : l10n.planProgressBible(percent),
                              style: AppTypography.body(
                                size: 12,
                                weight: FontWeight.w700,
                                color: a.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            l10n.planReadingDays(plan.completedDays),
                            style: AppTypography.body(
                              size: 12,
                              color: a.textFaint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (locked && chapters.isNotEmpty) ...[
                const ListDivider(),
                Padding(
                  padding: const EdgeInsets.all(AppSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.planLockedGuidedBody,
                        style: AppTypography.body(
                          size: 14,
                          height: 1.4,
                          color: a.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpace.md),
                      CopperCta(
                        label: l10n.plusNoticeContinue,
                        onTap: onUnlock,
                        trailing: null,
                      ),
                    ],
                  ),
                ),
              ] else if (chapters.isNotEmpty) ...[
                const ListDivider(),
                if (doneToday)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.md,
                      AppSpace.md,
                      AppSpace.md,
                      0,
                    ),
                    child: SectionLabel(l10n.planNextReading),
                  ),
                for (var i = 0; i < chapters.length; i++) ...[
                  if (i > 0)
                    const ListDivider(
                      indent: AppSpace.md,
                      endIndent: AppSpace.md,
                    ),
                  _ChapterRow(
                    chapter: chapters[i],
                    onTap: () => onOpen(chapters[i]),
                  ),
                ],
                if (!doneToday)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.md,
                      AppSpace.sm,
                      AppSpace.md,
                      AppSpace.md,
                    ),
                    child: CopperCta(
                      label: l10n.planMarkDayRead,
                      onTap: onComplete,
                      trailing: null,
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.section),
        // Ajustes do plano: escolhas sobre o card, nunca soltas no fundo.
        GlassCard(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // No guiado o dia já vem pronto: sem ajuste de tempo.
              if (guided == null) ...[
                CardHeader(
                  label: l10n.planTimePerDay,
                  glyph: CinematicGlyph.hourglass,
                ),
                const SizedBox(height: AppSpace.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in _minuteOptions)
                      AppSelectChip(
                        label: l10n.planMinutes(m),
                        selected: plan.minutesPerDay == m,
                        onTap: () => onMinutesChanged(m),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                const ListDivider(),
                const SizedBox(height: AppSpace.md),
              ],
              CardHeader(
                label: l10n.planReminderHeader,
                glyph: CinematicGlyph.bell,
              ),
              const SizedBox(height: AppSpace.xs),
              Text(
                l10n.planReminderBody,
                style: AppTypography.body(
                  size: 13,
                  height: 1.4,
                  color: a.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppSelectChip(
                    label: l10n.planReminderOff,
                    selected: plan.reminderHour == null,
                    onTap: () => onReminder(null),
                  ),
                  for (final h in _reminderHours)
                    AppSelectChip(
                      label: l10n.planReminderHour(
                        h.toString().padLeft(2, '0'),
                      ),
                      selected: plan.reminderHour == h,
                      onTap: () => onReminder(h),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
        TextCta(label: l10n.planEndCta, onTap: onClear, danger: true),
      ],
    );
  }
}

class _ChapterRow extends StatelessWidget {
  final PlanChapterRef chapter;
  final VoidCallback onTap;

  const _ChapterRow({required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.md,
            vertical: 14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  chapter.label,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
              ),
              Text(
                context.l10n.planApproxMinutes(
                  chapter.estimatedMinutes.round().clamp(1, 99),
                ),
                style: AppTypography.body(size: 12, color: a.textFaint),
              ),
              const SizedBox(width: 4),
              ListChevron(color: a.textFaint),
            ],
          ),
        ),
      ),
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
