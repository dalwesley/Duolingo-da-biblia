import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_language.dart';
import '../models/room_plan.dart';
import '../models/study_room.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/content_filter.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Peças do Propósito do grupo: o card do dia (herói), o pulso do grupo,
/// as respostas à pergunta do dia e o acompanhamento do líder.

String planDateShort(BuildContext context, String ymd) {
  final d = parsePlanYmd(ymd);
  if (d == null) return ymd;
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.MMMd(locale).format(d);
}

/// "amanhã" ou o dia da semana ("sábado").
String planWhen(BuildContext context, String ymd) {
  final d = parsePlanYmd(ymd);
  if (d == null) return ymd;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = d.difference(today).inDays;
  if (diff == 1) return context.l10n.planTomorrow;
  final locale = Localizations.localeOf(context).toString();
  if (diff > 1 && diff < 7) return DateFormat.EEEE(locale).format(d);
  return DateFormat.MMMd(locale).format(d);
}

// ───────────────────────── Herói: o dia ─────────────────────────

class RoomPlanCard extends StatelessWidget {
  final StudyRoom room;
  final RoomPlan plan;
  final PlanProgress mine;
  final PlanGroup group;
  final ProgressService progress;
  final bool isLeader;
  final Widget header;

  /// Dia mostrado (hoje, ou um dia para recuperar).
  final PlanDay? selected;
  final ValueChanged<PlanDay> onSelect;

  final bool closed;
  final bool closing;
  final VoidCallback onJoin;
  final ValueChanged<PlanDay> onRead;
  final ValueChanged<PlanDay> onScene;
  final ValueChanged<PlanDay> onAnswer;
  final ValueChanged<PlanDay> onManual;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final VoidCallback onReveal;

  const RoomPlanCard({
    super.key,
    required this.room,
    required this.plan,
    required this.mine,
    required this.group,
    required this.progress,
    required this.isLeader,
    required this.header,
    required this.selected,
    required this.onSelect,
    required this.closed,
    required this.closing,
    required this.onJoin,
    required this.onRead,
    required this.onScene,
    required this.onAnswer,
    required this.onManual,
    required this.onEdit,
    required this.onClose,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final phase = plan.phase();
    final day = selected;
    final dayDone = day != null && mine.done.containsKey(day.n);
    final quiet = phase == PlanPhase.active && dayDone;
    return GlassCard(
      tint: quiet ? AppRoles.presence : a.place,
      glow: quiet ? 0.3 : 0.75,
      elevated: !quiet,
      padding: AppMetrics.cardPadding.copyWith(top: AppSpace.sm, right: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpace.lg),
                ...switch (phase) {
                  PlanPhase.upcoming => _upcoming(context, a),
                  PlanPhase.active => _active(context, a),
                  PlanPhase.ended => _ended(context, a),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(AppearanceStyle a) => Text(
    plan.title,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: AppTypography.display(size: 24, height: 1.08, color: a.text),
  );

  Widget _range(BuildContext context, AppearanceStyle a) => Text(
    context.l10n.planDateRange(
      plan.total,
      planDateShort(context, plan.start),
      planDateShort(context, plan.end),
    ),
    style: AppTypography.body(size: 13, color: a.textSecondary),
  );

  List<Widget> _upcoming(BuildContext context, AppearanceStyle a) {
    final l10n = context.l10n;
    final first = plan.days.first;
    final items = [
      if (first.scene != null) first.scene!.title,
      if (first.reading != null) first.reading!.label,
      if (first.hasQuestion) l10n.planItemQuestion,
    ].join(' · ');
    return [
      SectionLabel(l10n.planLabelStartsIn(plan.daysUntilStart())),
      const SizedBox(height: AppSpace.sm),
      _title(a),
      const SizedBox(height: AppSpace.xs),
      _range(context, a),
      if (items.isNotEmpty) ...[
        const SizedBox(height: AppSpace.md),
        Text(
          l10n.planFirstDay(items),
          style: AppTypography.body(size: 14, height: 1.4, color: a.text),
        ),
      ],
      const SizedBox(height: AppSpace.lg),
      if (mine.joined)
        _StatusLine(
          glyph: CinematicGlyph.check,
          color: AppRoles.presence,
          text: l10n.planJoined,
        )
      else
        CopperCta(
          label: l10n.planJoin,
          leading: CinematicGlyph.heart,
          expanded: true,
          onTap: onJoin,
        ),
      const SizedBox(height: AppSpace.sm),
      Row(
        children: [
          Expanded(
            child: Text(
              l10n.planJoinedCount(group.joinedCount(), group.members.length),
              style: AppTypography.body(size: 13, color: a.textSecondary),
            ),
          ),
          if (isLeader)
            TextCta(
              label: l10n.planMenuEdit,
              leading: CinematicGlyph.pencil,
              onTap: onEdit,
            ),
        ],
      ),
    ];
  }

  List<Widget> _active(BuildContext context, AppearanceStyle a) {
    final l10n = context.l10n;
    final today = plan.today();
    final day = selected;
    final todayYmd = planYmd(DateTime.now());
    final missed = [
      for (final d in plan.openDays())
        if (d.date != todayYmd && !mine.done.containsKey(d.n)) d,
    ];
    final label = today != null
        ? l10n.planLabelDay(today.n, plan.total)
        : l10n.planRestToday;
    return [
      SectionLabel(label, maxLines: 1),
      const SizedBox(height: AppSpace.sm),
      _title(a),
      const SizedBox(height: AppSpace.md),
      PlanDayStrip(
        plan: plan,
        mine: mine,
        selected: day?.n,
        onSelect: onSelect,
      ),
      const SizedBox(height: AppSpace.md),
      if (day == null) ...[
        _StatusLine(
          glyph: CinematicGlyph.sprout,
          color: a.textSecondary,
          text: l10n.planRestToday,
        ),
        if (plan.nextDay() != null) ...[
          const SizedBox(height: AppSpace.xs),
          Text(
            l10n.planNextOpens(
              plan.nextDay()!.n,
              planWhen(context, plan.nextDay()!.date),
            ),
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
        ],
      ] else
        ..._dayBody(context, a, day, isToday: day.date == todayYmd),
      if (missed.isNotEmpty && (day == null || day.date == todayYmd)) ...[
        const SizedBox(height: AppSpace.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextCta(
            label: l10n.planCatchUpHint(missed.length),
            leading: CinematicGlyph.refresh,
            onTap: () => onSelect(missed.first),
          ),
        ),
      ],
    ];
  }

  List<Widget> _dayBody(
    BuildContext context,
    AppearanceStyle a,
    PlanDay day, {
    required bool isToday,
  }) {
    final l10n = context.l10n;
    final done = mine.done.containsKey(day.n);
    final items = RoomService.dayItems(plan, day, mine, progress);
    final next = plan.nextDay();
    return [
      if (!isToday) ...[
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.planDayDate(day.n, planDateShort(context, day.date)),
                style: AppTypography.title(size: 15, color: a.text),
              ),
            ),
            if (!done) _Tag(text: l10n.planCatchUpTag),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
      ],
      if (day.hasNote) ...[
        _Note(note: day.note!),
        const SizedBox(height: AppSpace.md),
      ],
      if (day.scene != null)
        _PlanItemRow(
          glyph: CinematicGlyph.path,
          title: l10n.planItemScene(day.scene!.title),
          subtitle: day.scene!.ref,
          done: items.scene,
          onTap: () => onScene(day),
        ),
      if (day.reading != null)
        _PlanItemRow(
          glyph: CinematicGlyph.book,
          title: l10n.planItemRead(day.reading!.label),
          done: items.reading,
          onTap: () => onRead(day),
        ),
      if (day.hasQuestion)
        _PlanItemRow(
          glyph: CinematicGlyph.quote,
          title: l10n.planItemQuestion,
          subtitle: day.question,
          done: items.question,
          onTap: () => onAnswer(day),
        ),
      if (day.isManual)
        _PlanItemRow(
          glyph: CinematicGlyph.heart,
          title: l10n.planItemManual,
          subtitle: l10n.planItemManualBody,
          done: done,
          onTap: done ? null : () => onManual(day),
        ),
      if (done) ...[
        const SizedBox(height: AppSpace.sm),
        _StatusLine(
          glyph: CinematicGlyph.check,
          color: AppRoles.presence,
          text: l10n.planDayDone(day.n),
        ),
        if (isToday) ...[
          const SizedBox(height: AppSpace.xs),
          Text(
            next == null
                ? l10n.planLastDayDone
                : l10n.planNextOpens(next.n, planWhen(context, next.date)),
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
        ],
      ],
    ];
  }

  List<Widget> _ended(BuildContext context, AppearanceStyle a) {
    final l10n = context.l10n;
    final done = plan.days.where((d) => mine.done.containsKey(d.n)).length;
    return [
      SectionLabel(l10n.planLabelEnded),
      const SizedBox(height: AppSpace.sm),
      _title(a),
      const SizedBox(height: AppSpace.xs),
      _range(context, a),
      const SizedBox(height: AppSpace.md),
      _StatusLine(
        glyph: CinematicGlyph.check,
        color: AppRoles.presence,
        text: l10n.planYouDid(done, plan.total),
      ),
      const SizedBox(height: AppSpace.lg),
      if (closed)
        GhostCta(
          label: l10n.planReveal,
          leading: CinematicGlyph.spark,
          expanded: true,
          onTap: onReveal,
        )
      else if (isLeader)
        CopperCta(
          label: closing ? l10n.planClosing : l10n.planCloseReveal,
          leading: CinematicGlyph.spark,
          expanded: true,
          onTap: closing ? null : onClose,
        )
      else
        Text(
          l10n.planWaitReveal,
          style: AppTypography.body(size: 13, color: a.textSecondary),
        ),
      if (isLeader) ...[
        const SizedBox(height: AppSpace.sm),
        Center(
          child: TextCta(
            label: l10n.planStartAnother,
            leading: CinematicGlyph.calendar,
            onTap: onEdit,
          ),
        ),
      ],
    ];
  }
}

/// Bolinhas dos dias do propósito: feito, aberto, hoje, ainda fechado.
class PlanDayStrip extends StatefulWidget {
  final RoomPlan plan;
  final PlanProgress mine;
  final int? selected;
  final ValueChanged<PlanDay> onSelect;

  const PlanDayStrip({
    super.key,
    required this.plan,
    required this.mine,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<PlanDayStrip> createState() => _PlanDayStripState();
}

class _PlanDayStripState extends State<PlanDayStrip> {
  static const _dot = 34.0;
  static const _gap = 6.0;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    final today = planYmd(DateTime.now());
    final index = widget.plan.days.lastIndexWhere(
      (d) => d.date.compareTo(today) <= 0,
    );
    _scroll = ScrollController(
      initialScrollOffset: math.max(0, (index - 3) * (_dot + _gap)),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final today = planYmd(DateTime.now());
    return SizedBox(
      height: _dot + 4,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        itemCount: widget.plan.days.length,
        separatorBuilder: (_, _) => const SizedBox(width: _gap),
        itemBuilder: (context, i) {
          final d = widget.plan.days[i];
          final open = d.date.compareTo(today) <= 0;
          final done = widget.mine.done.containsKey(d.n);
          final isToday = d.date == today;
          final selected = widget.selected == d.n;
          final fill = done ? AppRoles.presence : Colors.transparent;
          final border = selected
              ? AppRoles.reward
              : isToday
              ? a.place
              : done
              ? AppRoles.presence
              : open
              ? a.textSecondary
              : a.cardBorder;
          final ink = done
              ? AppColors.primaryDark
              : open
              ? a.text
              : a.textFaint;
          return Semantics(
            button: open,
            selected: selected,
            label: context.l10n.planDayDate(d.n, d.date),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: open
                  ? () {
                      ActHaptics.tap();
                      widget.onSelect(d);
                    }
                  : null,
              child: Center(
                child: AnimatedContainer(
                  duration: AppMotion.quick,
                  width: _dot,
                  height: _dot,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fill,
                    border: Border.all(
                      color: border,
                      width: selected || isToday ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${d.n}',
                    style: AppTypography.body(
                      size: 13,
                      weight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlanItemRow extends StatelessWidget {
  final CinematicGlyph glyph;
  final String title;
  final String? subtitle;
  final bool done;
  final VoidCallback? onTap;

  const _PlanItemRow({
    required this.glyph,
    required this.title,
    required this.done,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: InsetPanel(
        padding: EdgeInsets.zero,
        borderColor: done ? AppRoles.presence.withValues(alpha: 0.5) : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          onTap: onTap == null
              ? null
              : () {
                  ActHaptics.tap();
                  onTap!();
                },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            child: Row(
              children: [
                CinematicIcon(
                  glyph: done ? CinematicGlyph.check : glyph,
                  size: AppMetrics.iconMd,
                  accent: done ? AppRoles.presence : a.place,
                  framed: false,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title(
                          size: 15,
                          color: done ? a.textSecondary : a.text,
                        ),
                      ),
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 13,
                            color: a.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  CinematicIcon(
                    glyph: CinematicGlyph.chevron,
                    size: 14,
                    accent: a.textSecondary,
                    framed: false,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color color;
  final String text;

  const _StatusLine({
    required this.glyph,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CinematicIcon(glyph: glyph, size: 16, accent: color, framed: false),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body(
              size: 14,
              weight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: a.textSecondary),
      ),
      child: Text(
        text,
        style: AppTypography.label(size: 11, color: a.textSecondary),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final String note;

  const _Note({required this.note});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: CinematicIcon(
            glyph: CinematicGlyph.quote,
            size: AppMetrics.iconSm,
            accent: a.place,
            framed: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            note,
            style: AppTypography.body(
              size: 14,
              height: 1.4,
              color: a.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Pulso do grupo ─────────────────────────

/// Quem já cumpriu hoje (só rostos, sem lista de quem falta) e a corrente
/// do grupo.
class RoomPlanPulseCard extends StatelessWidget {
  final PlanGroup group;
  final String? myPhotoUrl;
  final PortraitStyle myStyle;

  const RoomPlanPulseCard({
    super.key,
    required this.group,
    required this.myPhotoUrl,
    required this.myStyle,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final today = group.plan.today(group.now);
    final done = today == null ? const <RoomMember>[] : group.doneOn(today);
    final chain = group.chain();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(label: l10n.planPulseTitle),
          const SizedBox(height: AppSpace.sm),
          if (today == null)
            Text(
              l10n.planRestToday,
              style: AppTypography.body(size: 14, color: a.textSecondary),
            )
          else
            Row(
              children: [
                if (done.isNotEmpty) ...[
                  _Faces(
                    members: done,
                    myPhotoUrl: myPhotoUrl,
                    myStyle: myStyle,
                  ),
                  const SizedBox(width: AppSpace.md),
                ],
                Expanded(
                  child: Text(
                    done.isEmpty
                        ? l10n.planPulseNone(today.n)
                        : l10n.planPulseDone(
                            done.length,
                            group.members.length,
                            today.n,
                          ),
                    style: AppTypography.body(
                      size: 14,
                      weight: FontWeight.w700,
                      color: a.text,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpace.md),
          InsetPanel(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.chain,
                  size: AppMetrics.leadingIcon,
                  accent: chain > 0 ? AppRoles.reward : a.textSecondary,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chain > 0 ? l10n.planChain(chain) : l10n.planChainZero,
                        style: AppTypography.title(
                          size: 15,
                          color: chain > 0 ? AppRoles.reward : a.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.planChainBody,
                        style: AppTypography.body(
                          size: 12,
                          color: a.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Faces extends StatelessWidget {
  final List<RoomMember> members;
  final String? myPhotoUrl;
  final PortraitStyle myStyle;

  const _Faces({
    required this.members,
    required this.myPhotoUrl,
    required this.myStyle,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final shown = members.take(5).toList();
    const r = 14.0;
    const step = 20.0;
    return SizedBox(
      width: r * 2 + step * (shown.length - 1),
      height: r * 2,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * step,
              child: UserAvatar(
                photoUrl: shown[i].isUser ? myPhotoUrl : shown[i].photoUrl,
                name: shown[i].name,
                seed: shown[i].uid,
                radius: r,
                style: shown[i].isUser ? myStyle : shown[i].portraitStyle,
                borderColor: a.cardFill,
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Respostas do dia ─────────────────────────

class RoomPlanAnswersCard extends StatelessWidget {
  final PlanDay day;
  final bool answered;
  final List<PlanAnswer>? answers;
  final bool loading;
  final String? myUid;
  final VoidCallback onAnswer;
  final ValueChanged<PlanAnswer> onHold;

  const RoomPlanAnswersCard({
    super.key,
    required this.day,
    required this.answered,
    required this.answers,
    required this.loading,
    required this.myUid,
    required this.onAnswer,
    required this.onHold,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final list = answers ?? const <PlanAnswer>[];
    final others = [
      for (final x in list)
        if (x.uid != myUid) x,
    ];
    final mine = list.where((x) => x.uid == myUid).firstOrNull;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(label: l10n.planAnswersTitle(day.n)),
          const SizedBox(height: AppSpace.sm),
          Text(
            day.question ?? '',
            style: AppTypography.display(size: 19, height: 1.2, color: a.text),
          ),
          const SizedBox(height: AppSpace.md),
          if (!answered) ...[
            Row(
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.lock,
                  size: 14,
                  accent: a.textSecondary,
                  framed: false,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.planAnswersLocked,
                    style: AppTypography.body(size: 13, color: a.textSecondary),
                  ),
                ),
              ],
            ),
            if (answers != null) ...[
              const SizedBox(height: AppSpace.xs),
              Text(
                l10n.planAnswersCount(others.length),
                style: AppTypography.body(size: 13, color: a.textFaint),
              ),
            ],
            const SizedBox(height: AppSpace.md),
            CopperCta(
              label: l10n.planAnswerCta,
              leading: CinematicGlyph.pencil,
              expanded: true,
              onTap: onAnswer,
            ),
          ] else if (loading && answers == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpace.md),
              child: AppSpinner(inline: true),
            )
          else ...[
            if (mine != null)
              _AnswerRow(answer: mine, mine: true, onHold: onHold),
            for (final x in others)
              _AnswerRow(answer: x, mine: false, onHold: onHold),
            if (others.isEmpty)
              Text(
                l10n.planAnswerEmpty,
                style: AppTypography.body(size: 13, color: a.textSecondary),
              )
            else ...[
              const SizedBox(height: AppSpace.xs),
              Text(
                l10n.planAnswerHint,
                style: AppTypography.body(size: 12, color: a.textFaint),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final PlanAnswer answer;
  final bool mine;
  final ValueChanged<PlanAnswer> onHold;

  const _AnswerRow({
    required this.answer,
    required this.mine,
    required this.onHold,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        ActHaptics.light();
        onHold(answer);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpace.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              photoUrl: answer.photoUrl,
              name: answer.name,
              seed: answer.uid,
              radius: 16,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mine ? context.l10n.commonYou : answer.name,
                    style: AppTypography.label(
                      size: 12,
                      color: mine ? AppRoles.presence : a.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    answer.text,
                    style: AppTypography.body(
                      size: 14,
                      height: 1.4,
                      color: a.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Folha para responder a pergunta do dia. Devolve o texto.
Future<String?> showPlanAnswerSheet(BuildContext context, PlanDay day) {
  return showAppSheet<String>(context, builder: (_) => _AnswerSheet(day: day));
}

class _AnswerSheet extends StatefulWidget {
  final PlanDay day;

  const _AnswerSheet({required this.day});

  @override
  State<_AnswerSheet> createState() => _AnswerSheetState();
}

class _AnswerSheetState extends State<_AnswerSheet> {
  final _text = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send() {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    if (!ContentFilter.isAllowed(text)) {
      setState(() => _error = context.l10n.contentTextNotAllowed);
      return;
    }
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            title: widget.day.question ?? l10n.planItemQuestion,
            subtitle: l10n.planAnswerSheetHint,
            cloud: false,
          ),
          const SizedBox(height: AppSpace.md),
          TextField(
            controller: _text,
            autofocus: true,
            maxLength: 280,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            style: AppTypography.body(size: 15, color: a.text),
            decoration: InputDecoration(errorText: _error),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
              setState(() {});
            },
          ),
          const SizedBox(height: AppSpace.md),
          CopperCta(
            label: l10n.planAnswerSend,
            expanded: true,
            onTap: _text.text.trim().isEmpty ? null : _send,
          ),
        ],
      ),
    );
  }
}

/// Convite para o líder criar o primeiro propósito.
class RoomPlanInviteCard extends StatelessWidget {
  final VoidCallback onTap;

  const RoomPlanInviteCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return GlassCard(
      tint: AppRoles.reward,
      onTap: onTap,
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.calendar,
            size: AppMetrics.leadingIcon,
            accent: AppRoles.reward,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.planInviteTitle,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  l10n.planInviteBody,
                  style: AppTypography.body(size: 13, color: a.textSecondary),
                ),
              ],
            ),
          ),
          CinematicIcon(
            glyph: CinematicGlyph.chevron,
            size: 14,
            accent: a.textSecondary,
            framed: false,
          ),
        ],
      ),
    );
  }
}
