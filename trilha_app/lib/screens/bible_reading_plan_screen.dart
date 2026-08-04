import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/bible_reading_plan.dart';
import '../services/bible_reading_plan_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'bible_screen.dart';

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
  })? _preview;
  bool _loading = true;

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
      final skipped =
          await progress.syncBibleReadingPlanWithReadChapters();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              skipped == 1
                  ? '1 capítulo já lido foi pulado'
                  : '$skipped capítulos já lidos foram pulados',
            ),
            behavior: SnackBarBehavior.floating,
          ),
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
    HapticFeedback.mediumImpact();
    await context.read<ProgressService>().startBibleReadingPlan(
          order: _draftOrder,
          minutesPerDay: _draftMinutes,
        );
    await _reload();
  }

  Future<void> _completeDay() async {
    final portion = _portion;
    if (portion == null || portion.finished || portion.chapters.isEmpty) return;
    HapticFeedback.mediumImpact();
    await context.read<ProgressService>().completeBibleReadingPortion(
          toCursor: portion.toCursor,
          chapters: [
            for (final c in portion.chapters)
              (abbrev: c.abbrev, chapter: c.chapter),
          ],
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Leitura do dia concluída · ${portion.chapters.length} '
          '${portion.chapters.length == 1 ? 'capítulo' : 'capítulos'}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    await _reload();
  }

  Future<void> _openChapter(PlanChapterRef chapter) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BibleReaderScreen(
          reference: '${chapter.bookName} ${chapter.chapter}',
        ),
      ),
    );
    if (mounted) await _reload();
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.sheet,
        title: const Text('Encerrar plano?'),
        content: const Text(
          'Seu progresso no plano será zerado. Os capítulos já '
          'marcados como lidos na Bíblia permanecem.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
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
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpace.screen,
              MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
              AppSpace.screen,
              MediaQuery.viewPaddingOf(context).bottom + AppSpace.xl,
            ),
            children: [
              TopBar(
                inline: true,
                immersive: true,
                dark: style.onDark,
                title: 'Plano de leitura',
                subtitle: plan.active ? plan.order.shortLabel : 'No seu ritmo',
                leadingGlyph: CinematicGlyph.book,
                chromeAccent: AppColors.cedar,
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: AppSpace.afterTopBar),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.cedar),
                  ),
                )
              else if (plan.active)
                _ActivePlanBody(
                  plan: plan,
                  portion: _portion,
                  onOpen: _openChapter,
                  onComplete: _completeDay,
                  onClear: _confirmClear,
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
  })? preview;
  final ValueChanged<BibleReadingOrder> onOrder;
  final ValueChanged<int> onMinutes;
  final VoidCallback onStart;

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
          'Quanto tempo você tem por dia?',
          style: AppTypography.title(
            size: 20,
            weight: FontWeight.w800,
            color: a.text,
          ),
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          'Montamos a porção diária para caber nesse tempo — '
          'na ordem da Bíblia ou na ordem dos acontecimentos. '
          'Capítulos que você já leu são pulados.',
          style: AppTypography.body(
            size: 14,
            height: 1.45,
            color: a.textMuted(0.7),
          ),
        ),
        const SizedBox(height: AppSpace.section),
        SectionLabel('Ordem', color: a.sectionLabel),
        const SizedBox(height: AppSpace.sm),
        _OrderToggle(value: order, onChanged: onOrder),
        const SizedBox(height: AppSpace.section),
        SectionLabel('Tempo disponível', color: a.sectionLabel),
        const SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in _minuteOptions)
              _MinuteChip(
                label: '$m min',
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
                  label: 'Estimativa',
                  trailing: SoftBadge(
                    text: order.shortLabel,
                    accent: AppColors.cedar,
                    glyph: CinematicGlyph.book,
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                if (alreadyRead > 0) ...[
                  _StatRow(
                    label: 'Já lidos',
                    value: '$alreadyRead caps. (pulados)',
                  ),
                  const SizedBox(height: 6),
                ],
                _StatRow(
                  label: 'Restante',
                  value: remainingHours == null
                      ? '—'
                      : remainingHours == 0
                          ? '~${preview!.remainingMinutes.round()} min'
                          : '~$remainingHours h',
                ),
                const SizedBox(height: 6),
                _StatRow(
                  label: 'No seu ritmo',
                  value: days == null || days == 0
                      ? (preview!.remainingChapters == 0
                          ? 'Tudo lido'
                          : '—')
                      : days >= 365
                          ? '~${(days / 30).round()} meses'
                          : '~$days dias',
                ),
                const SizedBox(height: 6),
                _StatRow(
                  label: 'Capítulos pendentes',
                  value: '${preview!.remainingChapters}',
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpace.section),
        FilledButton(
          onPressed: onStart,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.cedar,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
          ),
          child: Text(
            'Começar plano · $minutes min/dia',
            style: AppTypography.body(
              size: 15,
              weight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
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

  const _ActivePlanBody({
    required this.plan,
    required this.portion,
    required this.onOpen,
    required this.onComplete,
    required this.onClear,
    required this.onMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final p = portion;
    final doneToday = plan.doneToday;
    final finished = p?.finished == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                label: 'Hoje',
                trailing: SoftBadge(
                  text: doneToday
                      ? 'Feito'
                      : '${plan.minutesPerDay} min',
                  accent: doneToday ? AppColors.accent : AppColors.cedar,
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                finished
                    ? 'Você concluiu a Bíblia neste plano.'
                    : (p?.summary ?? '…'),
                style: AppTypography.title(
                  size: 18,
                  weight: FontWeight.w800,
                  color: a.text,
                ),
              ),
              if (p != null && !finished) ...[
                const SizedBox(height: 4),
                Text(
                  '~${p.estimatedMinutes.round()} min · '
                  '${p.chapters.length} '
                  '${p.chapters.length == 1 ? 'capítulo' : 'capítulos'} · '
                  '${plan.order.shortLabel}',
                  style: AppTypography.body(
                    size: 13,
                    color: a.textMuted(0.65),
                  ),
                ),
              ],
              const SizedBox(height: AppSpace.sm),
              Text(
                '${plan.completedDays} '
                '${plan.completedDays == 1 ? 'dia' : 'dias'} de leitura',
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w600,
                  color: a.textMuted(0.5),
                ),
              ),
            ],
          ),
        ),
        if (p != null && !finished) ...[
          const SizedBox(height: AppSpace.section),
          SectionLabel('Capítulos de hoje', color: a.sectionLabel),
          const SizedBox(height: AppSpace.sm),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < p.chapters.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
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
                                  size: 15,
                                  weight: FontWeight.w700,
                                  color: a.text,
                                ),
                              ),
                            ),
                            Text(
                              '~${p.chapters[i].estimatedMinutes.toStringAsFixed(1)} min',
                              style: AppTypography.body(
                                size: 12,
                                color: a.textMuted(0.55),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
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
            FilledButton(
              onPressed: onComplete,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cedar,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
              ),
              child: Text(
                'Marcar leitura do dia',
                style: AppTypography.body(
                  size: 15,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            )
          else
            GlassCard(
              padding: const EdgeInsets.all(AppSpace.md),
              child: Text(
                'Porção de hoje concluída. Volte amanhã — '
                'ou continue explorando a Bíblia livremente.',
                style: AppTypography.body(
                  size: 14,
                  height: 1.4,
                  color: a.textMuted(0.75),
                ),
              ),
            ),
        ],
        const SizedBox(height: AppSpace.section),
        SectionLabel('Ajustar tempo', color: a.sectionLabel),
        const SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in const [5, 10, 15, 20, 30, 45, 60])
              _MinuteChip(
                label: '$m min',
                selected: plan.minutesPerDay == m,
                onTap: () => onMinutesChanged(m),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.section),
        TextButton(
          onPressed: onClear,
          child: Text(
            'Encerrar plano',
            style: AppTypography.body(
              size: 14,
              weight: FontWeight.w700,
              color: a.textMuted(0.55),
            ),
          ),
        ),
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
    return Row(
      children: [
        for (final o in BibleReadingOrder.values) ...[
          if (o != BibleReadingOrder.values.first) const SizedBox(width: 8),
          Expanded(
            child: _MinuteChip(
              label: o.shortLabel,
              selected: value == o,
              onTap: () => onChanged(o),
            ),
          ),
        ],
      ],
    );
  }
}

class _MinuteChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MinuteChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.cedar.withValues(alpha: 0.22)
                : a.cardFillSoft,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected
                  ? AppColors.cedar.withValues(alpha: 0.7)
                  : a.cardBorder,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w800,
              color: selected ? AppColors.cedar : a.text,
            ),
          ),
        ),
      ),
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
            style: AppTypography.body(
              size: 13,
              color: a.textMuted(0.65),
            ),
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
