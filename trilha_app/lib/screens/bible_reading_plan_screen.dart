import 'dart:math' as math;

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
import '../widgets/act_feel.dart';
import '../widgets/app_nav_row.dart';
import '../widgets/app_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/immersive_background.dart';
import '../widgets/juntos_chrome.dart';
import '../widgets/profile_section.dart';
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

  /// Modo prazo: dias para terminar; os minutos saem do que falta ler.
  int? _draftDeadline;
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
    // Chamado depois de awaits (_start, _confirmClear, _completeDay): a tela
    // pode já ter saído.
    if (!mounted) return;
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
    final deadline = _draftDeadline;
    if (deadline != null) {
      // O que falta não depende dos minutos: mede, divide pelo prazo.
      // Mesmo teto que o plano salvo (1 min–6 h); a estimativa mostra os
      // dias reais quando o prazo não cabe.
      final base = await BibleReadingPlanService.instance.previewStats(
        order: _draftOrder,
        minutesPerDay: _draftMinutes,
        readKeys: progress.readBibleChapters.toSet(),
      );
      if (!mounted) return;
      _draftMinutes = (base.remainingMinutes / deadline).ceil().clamp(
        BibleReadingPlan.minMinutesPerDay,
        BibleReadingPlan.maxMinutesPerDay,
      );
    }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
                  AppSpace.screen,
                  0,
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
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    AppSpace.afterTopBar,
                    0,
                    MediaQuery.viewPaddingOf(context).bottom + AppSpace.xl,
                  ),
                  children: [
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
                                deadlineDays: _draftDeadline,
                                onDeadlineMode: (on) {
                                  setState(
                                    () => _draftDeadline = on ? 365 : null,
                                  );
                                  _refreshPreview();
                                },
                                onDeadline: (d) {
                                  setState(() => _draftDeadline = d);
                                  _refreshPreview();
                                },
                              ),
                          ],
                        ),
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
}

/// Minutos por dia oferecidos; um valor fora da lista (vindo de um prazo)
/// entra no lugar certo para continuar marcado.
const _minuteOptions = [5, 10, 15, 20, 30, 45, 60, 90, 120, 180, 240, 300, 360];

/// "45 min", "1 h", "1 h 30": a partir de uma hora, em horas.
String _duration(AppLocalizations l10n, int minutes) {
  if (minutes < 60) return l10n.planMinutes(minutes);
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h h' : '$h h ${m.toString().padLeft(2, '0')}';
}

List<int> _minuteChoices(int current) => _minuteOptions.contains(current)
    ? _minuteOptions
    : ([..._minuteOptions, current]..sort());

/// Prazos oferecidos, em dias: 1, 3, 6 meses; 1, 2, 3 anos.
final _deadlineOptions = [for (var m = 1; m <= 48; m++) (m * 365 / 12).round()];

/// Prazo em dias como "5 meses", "2 anos" ou "1 ano e 3 meses".
String _deadlineLabel(AppLocalizations l10n, int days) {
  final total = (days * 12 / 365).round().clamp(1, 1200);
  final years = total ~/ 12;
  final months = total % 12;
  if (years == 0) return l10n.planDeadlineMonths(months);
  if (months == 0) return l10n.planDeadlineYears(years);
  return l10n.planDeadlineYearsMonths(
    l10n.planDeadlineYears(years),
    l10n.planDeadlineMonths(months),
  );
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

  /// Prazo escolhido em dias; null = modo "tempo por dia".
  final int? deadlineDays;
  final ValueChanged<bool> onDeadlineMode;
  final ValueChanged<int> onDeadline;

  const _SetupPlanBody({
    required this.order,
    required this.minutes,
    required this.preview,
    required this.onOrder,
    required this.onMinutes,
    required this.onStart,
    required this.deadlineDays,
    required this.onDeadlineMode,
    required this.onDeadline,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final days = preview?.estimatedDays;
    final remainingHours = preview == null
        ? null
        : (preview!.remainingMinutes / 60).round();
    final alreadyRead = preview == null
        ? 0
        : preview!.totalChapters - preview!.remainingChapters;
    final byDeadline = deadlineDays != null;
    final paceText = preview == null
        ? '—'
        : days == null || days == 0
        ? (preview!.remainingChapters == 0 ? l10n.planAllRead : '—')
        : days >= 365
        ? l10n.planApproxMonths((days / 30).round())
        : l10n.planApproxDays(days);
    final remainingText = remainingHours == null
        ? '—'
        : remainingHours == 0
        ? l10n.planApproxMinutes(preview!.remainingMinutes.round())
        : l10n.planApproxHours(remainingHours);

    // Mostrador: um valor grande, um trilho dourado e o resultado ao vivo.
    final stops = byDeadline ? _deadlineOptions : _minuteChoices(minutes);
    final index = byDeadline
        ? _deadlineOptions.indexOf(deadlineDays!).clamp(0, stops.length - 1)
        : stops.indexOf(minutes).clamp(0, stops.length - 1);
    final bigValue = byDeadline
        ? _deadlineLabel(l10n, deadlineDays!)
        : _duration(l10n, minutes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Escolher pelo tempo de cada dia ou pelo prazo para terminar.
        AppSegmentedTabs(
          index: byDeadline ? 1 : 0,
          accent: AppRoles.presence,
          onChanged: (i) => onDeadlineMode(i == 1),
          items: [
            (
              label: l10n.planModeDaily,
              glyph: CinematicGlyph.hourglass,
              mark: null,
              alert: false,
            ),
            (
              label: l10n.planModeDeadline,
              glyph: CinematicGlyph.calendar,
              mark: null,
              alert: false,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
        Text(
          byDeadline ? l10n.planDeadlineQuestion : l10n.planSetupQuestion,
          style: AppTypography.title(size: 20, color: a.text),
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          byDeadline ? l10n.planDeadlineBody : l10n.planSetupBody,
          style: AppTypography.body(
            size: 14,
            height: 1.45,
            color: a.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        _Dial(
          label: byDeadline ? l10n.planSectionDeadline : l10n.planSectionTime,
          glyph: byDeadline
              ? CinematicGlyph.calendar
              : CinematicGlyph.hourglass,
          value: bigValue,
          index: index,
          count: stops.length,
          minLabel: byDeadline
              ? _deadlineLabel(l10n, stops.first)
              : _duration(l10n, stops.first),
          maxLabel: byDeadline
              ? _deadlineLabel(l10n, stops.last)
              : _duration(l10n, stops.last),
          resultLabel: byDeadline ? l10n.planDailyReading : l10n.planAtYourPace,
          result: byDeadline
              ? (preview == null || preview!.remainingChapters == 0
                    ? '—'
                    : l10n.planApproxMinutesPerDay(_duration(l10n, minutes)))
              : paceText,
          onIndex: (i) =>
              byDeadline ? onDeadline(stops[i]) : onMinutes(stops[i]),
        ),
        const SizedBox(height: AppSpace.md),
        // Rota empurrada: sem cor de aba, o lugar seria cinza. Cada quadro
        // leva o seu tom (Bíblia lilás, estimativa céu).
        ProfileSection(
          accent: AppRoles.navBible,
          glyph: CinematicGlyph.book,
          title: l10n.planSectionOrder,
          lit: true,
          child: _OrderToggle(value: order, onChanged: onOrder),
        ),
        if (preview != null) ...[
          const SizedBox(height: AppSpace.md),
          // Estimativa no quadro padrão: cada linha com o seu tom.
          ProfileSection(
            accent: AppColors.sky,
            glyph: CinematicGlyph.target,
            title: l10n.planEstimate,
            lit: true,
            trailing: SoftBadge(
              text: order.shortLabel,
              accent: AppRoles.navBible,
              glyph: CinematicGlyph.book,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EstimateRow(
                  tone: AppColors.sky,
                  glyph: CinematicGlyph.hourglass,
                  label: l10n.planRemaining,
                  value: remainingText,
                ),
                const AppNavDivider(),
                _EstimateRow(
                  tone: AppRoles.lamp,
                  glyph: CinematicGlyph.calendar,
                  label: byDeadline
                      ? l10n.planAtYourPace
                      : l10n.planDailyReading,
                  value: byDeadline ? paceText : _duration(l10n, minutes),
                ),
                const AppNavDivider(),
                _EstimateRow(
                  tone: const Color(0xFFB592FF),
                  glyph: CinematicGlyph.book,
                  label: l10n.planPendingChapters,
                  value: '${preview!.remainingChapters}',
                ),
                if (alreadyRead > 0) ...[
                  const AppNavDivider(),
                  _EstimateRow(
                    tone: AppColors.sprout,
                    glyph: CinematicGlyph.check,
                    label: l10n.planAlreadyRead,
                    value: l10n.planChaptersSkipped(alreadyRead),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpace.section),
        CopperCta(
          label: l10n.planStartCta(_duration(l10n, minutes)),
          onTap: onStart,
          trailing: null,
        ),
      ],
    );
  }
}

/// Mostrador do plano: valor grande em serif, trilho dourado com paradas e
/// o resultado logo abaixo, na luz da lâmpada.
class _Dial extends StatelessWidget {
  final String label;
  final CinematicGlyph glyph;
  final String value;
  final int index;
  final int count;
  final String minLabel;
  final String maxLabel;
  final String resultLabel;
  final String result;
  final ValueChanged<int> onIndex;

  const _Dial({
    required this.label,
    required this.glyph,
    required this.value,
    required this.index,
    required this.count,
    required this.minLabel,
    required this.maxLabel,
    required this.resultLabel,
    required this.result,
    required this.onIndex,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    const tone = AppRoles.lamp;
    // Mesmo quadro dos Ajustes/Perfil, aceso na lâmpada.
    return ProfileSection(
      accent: tone,
      glyph: glyph,
      title: label,
      lit: true,
      // Nascer do sol: ouro no alto, brasa no meio, lilás da Bíblia embaixo.
      backdrop: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    tone.withValues(alpha: a.onDark ? 0.26 : 0.2),
                    AppColors.ember.withValues(alpha: a.onDark ? 0.12 : 0.08),
                    AppRoles.navBible.withValues(alpha: a.onDark ? 0.2 : 0.12),
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: Container(
                width: 220,
                height: 120,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      tone.withValues(alpha: 0.35),
                      tone.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: AnimatedSwitcher(
              duration: AppMotion.standard,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: Tween(begin: 0.92, end: 1.0).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                value,
                key: ValueKey(value),
                style: AppTypography.display(
                  size: 48,
                  weight: FontWeight.w700,
                  color: a.text,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          // O Anan é o cursor: arrasta ou toca no trilho.
          _AnanTrack(
            index: index,
            count: count,
            semanticsValue: value,
            onIndex: (i) {
              if (i == index) return;
              ActHaptics.tap();
              onIndex(i);
            },
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  minLabel,
                  style: AppTypography.body(size: 11, color: a.textFaint),
                ),
                const Spacer(),
                Text(
                  maxLabel,
                  style: AppTypography.body(size: 11, color: a.textFaint),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.md,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: tone.withValues(alpha: 0.45)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    resultLabel,
                    style: AppTypography.body(size: 13, color: a.textSecondary),
                  ),
                ),
                Text(result, style: AppTypography.title(size: 17, color: tone)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Trilho dourado com o Anan como cursor. Toque ou arraste escolhe a
/// parada mais próxima; leitor de tela usa aumentar/diminuir.
class _AnanTrack extends StatelessWidget {
  final int index;
  final int count;
  final String semanticsValue;
  final ValueChanged<int> onIndex;

  const _AnanTrack({
    required this.index,
    required this.count,
    required this.semanticsValue,
    required this.onIndex,
  });

  static const _anan = 46.0;
  static const _track = 8.0;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    const tone = AppRoles.lamp;
    final steps = math.max(1, count - 1);
    return Semantics(
      slider: true,
      value: semanticsValue,
      onIncrease: index < count - 1 ? () => onIndex(index + 1) : null,
      onDecrease: index > 0 ? () => onIndex(index - 1) : null,
      child: LayoutBuilder(
        builder: (context, c) {
          final usable = c.maxWidth - _anan;
          final x = usable * index / steps;
          int pick(double dx) =>
              ((dx - _anan / 2) / usable * steps).round().clamp(0, steps);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => onIndex(pick(d.localPosition.dx)),
            onHorizontalDragUpdate: (d) => onIndex(pick(d.localPosition.dx)),
            child: SizedBox(
              height: _anan + 8,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Trilho apagado.
                  Positioned(
                    left: _anan / 2,
                    right: _anan / 2,
                    top: (_anan + 8 - _track) / 2,
                    height: _track,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: a.progressTrack,
                        borderRadius: BorderRadius.circular(_track),
                      ),
                    ),
                  ),
                  // Paradas (só quando cabem).
                  if (count <= 16)
                    for (var i = 0; i < count; i++)
                      Positioned(
                        left: _anan / 2 + usable * i / steps - 2,
                        top: (_anan + 8) / 2 - 2,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i <= index
                                ? AppColors.inkOnAccent.withValues(alpha: 0.4)
                                : a.textFaint.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                  // Trecho aceso, até o Anan.
                  AnimatedPositioned(
                    duration: AppMotion.quick,
                    curve: AppMotion.settle,
                    left: _anan / 2,
                    width: x,
                    top: (_anan + 8 - _track) / 2,
                    height: _track,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accentSoft, tone],
                        ),
                        borderRadius: BorderRadius.circular(_track),
                        boxShadow: [
                          BoxShadow(
                            color: tone.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: AppMotion.quick,
                    curve: AppMotion.settle,
                    left: x,
                    top: 0,
                    child: const IgnorePointer(
                      child: CloudMascot(
                        face: CloudFace.feliz,
                        size: _anan,
                        react: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Linha da estimativa: o desenho das linhas dos Ajustes, com o número
/// no lugar da seta.
class _EstimateRow extends StatelessWidget {
  final Color tone;
  final CinematicGlyph glyph;
  final String label;
  final String value;

  const _EstimateRow({
    required this.tone,
    required this.glyph,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Row(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: AppMetrics.leadingIcon,
            accent: tone,
            glowing: false,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.title(size: 14, color: a.text),
            ),
          ),
          Text(
            value,
            style: AppTypography.title(
              size: 15,
              color: a.onDark ? tone : a.ink(tone),
            ),
          ),
        ],
      ),
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
                            ? CinematicGlyph.plus
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
                SectionLabel(l10n.planTimePerDay),
                const SizedBox(height: AppSpace.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in _minuteChoices(plan.minutesPerDay))
                      AppSelectChip(
                        label: _duration(l10n, m),
                        selected: plan.minutesPerDay == m,
                        onTap: () => onMinutesChanged(m),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                const ListDivider(),
                const SizedBox(height: AppSpace.md),
              ],
              SectionLabel(l10n.planReminderHeader),
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
