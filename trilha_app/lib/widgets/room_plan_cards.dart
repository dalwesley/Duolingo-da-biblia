import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/season_walk_catalog.dart';
import '../data/trail_art.dart';
import '../l10n/app_language.dart';
import '../models/room_plan.dart';
import '../models/season_walk.dart';
import '../models/study_room.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/content_filter.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';
import 'profile_section.dart';

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

  /// Cabeçalho do grupo para o propósito sem arte (só capítulo).
  final Widget header;

  /// Menu do grupo ("…"), sobre a capa.
  final VoidCallback onMenu;
  final String? myPhotoUrl;
  final PortraitStyle myStyle;

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
    required this.onMenu,
    this.myPhotoUrl,
    this.myStyle = PortraitStyle.photo,
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
    final art = _art(day);
    final body = switch (phase) {
      PlanPhase.upcoming => _upcoming(context, a, cover: art != null),
      PlanPhase.active => _active(context, a, cover: art != null),
      PlanPhase.ended => _ended(context, a, cover: art != null),
    };
    return ProfilePanel(
      accent: quiet ? AppRoles.presence : a.place,
      lit: !quiet,
      padding: art != null
          ? const EdgeInsets.all(AppSpace.sm)
          : AppMetrics.cardPadding.copyWith(top: AppSpace.sm, right: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (art != null)
            _PlanCover(
              art: art,
              room: room,
              plan: plan,
              group: group,
              eyebrow: _eyebrow(context, phase),
              myPhotoUrl: myPhotoUrl,
              myStyle: myStyle,
              onMenu: onMenu,
            )
          else
            header,
          Padding(
            padding: art != null
                ? const EdgeInsets.fromLTRB(
                    AppSpace.md,
                    AppSpace.md,
                    AppSpace.md,
                    AppSpace.md,
                  )
                : const EdgeInsets.only(right: 12, top: AppSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: body,
            ),
          ),
        ],
      ),
    );
  }

  String _eyebrow(BuildContext context, PlanPhase phase) {
    final l10n = context.l10n;
    return switch (phase) {
      PlanPhase.upcoming => l10n.planCoverStarts(plan.daysUntilStart()),
      PlanPhase.ended => l10n.planLabelEnded,
      PlanPhase.active => switch (plan.today()) {
        final t? => l10n.planCoverDay(t.n, plan.total),
        null => l10n.planRestToday,
      },
    };
  }

  /// Pintura do propósito, a mesma do editor: a da estação, ou a da cena
  /// do dia mostrado (sem dia, a da 1ª cena) com a trilha de fallback.
  String? _art(PlanDay? day) {
    final sw = plan.seasonId;
    if (sw != null) {
      return SeasonWalkCatalog.artAsset(
        sw.startsWith('advento') ? SeasonWalkKind.advent : SeasonWalkKind.lent,
      );
    }
    final trail = plan.gen['tsk'];
    if (trail is! String || trail.isEmpty) return null;
    final scene =
        day?.scene ??
        plan.days.where((d) => d.scene != null).firstOrNull?.scene;
    return scene == null
        ? TrailArt.of(trail)
        : TrailArt.ofScene(trail, scene.slug);
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

  List<Widget> _upcoming(
    BuildContext context,
    AppearanceStyle a, {
    required bool cover,
  }) {
    final l10n = context.l10n;
    final first = plan.days.first;
    return [
      if (!cover) ...[
        SectionLabel(l10n.planLabelStartsIn(plan.daysUntilStart())),
        const SizedBox(height: AppSpace.sm),
        _title(a),
        const SizedBox(height: AppSpace.xs),
      ],
      _range(context, a),
      const SizedBox(height: AppSpace.lg),
      // O que o dia 1 traz, no mesmo caminho do dia (só para ver).
      _PlanPath(steps: _steps(context, first, null), next: null),
      const SizedBox(height: AppSpace.md),
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

  List<Widget> _active(
    BuildContext context,
    AppearanceStyle a, {
    required bool cover,
  }) {
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
    final chain = group.chain();
    // Contagem até o fim do propósito (00:00 do dia seguinte ao último).
    final end = parsePlanYmd(plan.end);
    final now = DateTime.now();
    final daysLeft = end == null
        ? 0
        : DateTime(
                end.year,
                end.month,
                end.day + 1,
              ).difference(DateTime(now.year, now.month, now.day)).inDays -
              1;
    return [
      if (!cover) ...[
        SectionLabel(label, maxLines: 1),
        const SizedBox(height: AppSpace.sm),
        _title(a),
        const SizedBox(height: AppSpace.md),
      ],
      // Igual às trilhas: contagem + barra fina.
      Row(
        children: [
          Expanded(
            child: Text(
              l10n.planYouDid(mine.done.length, plan.total),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(size: 12, color: a.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          Text(
            l10n.planHearthEndsIn(daysLeft < 0 ? 0 : daysLeft),
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w700,
              color: a.textSecondary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      AppProgressBar(
        value: plan.total == 0 ? 0 : mine.done.length / plan.total,
        height: 4,
        color: AppRoles.presence,
        trackColor: AppRoles.presence.withValues(alpha: 0.18),
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
      if (chain > 0) ...[
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            const CinematicIcon(
              glyph: CinematicGlyph.chain,
              size: 16,
              accent: AppRoles.reward,
              framed: false,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.planChain(chain),
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w800,
                color: AppRoles.reward,
              ),
            ),
          ],
        ),
      ],
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

  /// Passos do dia, na ordem: cena → leitura → pergunta (ou o dia à mão).
  List<_PlanStep> _steps(
    BuildContext context,
    PlanDay day,
    ({bool reading, bool scene, bool question})? items,
  ) {
    final l10n = context.l10n;
    final done = mine.done.containsKey(day.n);
    return [
      if (day.scene != null)
        _PlanStep(
          glyph: CinematicGlyph.path,
          kind: l10n.planStepScene,
          text: day.scene!.title,
          detail: day.scene!.ref,
          done: items?.scene ?? false,
          cta: l10n.planGoScene,
          onTap: items == null ? null : () => onScene(day),
        ),
      if (day.reading != null)
        _PlanStep(
          glyph: CinematicGlyph.book,
          kind: l10n.planStepRead,
          text: day.reading!.label,
          done: items?.reading ?? false,
          cta: l10n.planItemRead(day.reading!.label),
          onTap: items == null ? null : () => onRead(day),
        ),
      if (day.hasQuestion)
        _PlanStep(
          glyph: CinematicGlyph.quote,
          kind: l10n.planItemQuestion,
          text: day.question!,
          done: items?.question ?? false,
          cta: l10n.planAnswerCta,
          onTap: items == null ? null : () => onAnswer(day),
        ),
      if (day.isManual)
        _PlanStep(
          glyph: CinematicGlyph.heart,
          kind: l10n.planItemManual,
          text: l10n.planItemManualBody,
          done: done,
          cta: l10n.planItemManual,
          onTap: items == null || done ? null : () => onManual(day),
        ),
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
    final steps = _steps(context, day, items);
    final next = steps.where((s) => !s.done && s.onTap != null).firstOrNull;
    final nextDay = plan.nextDay();
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
        const SizedBox(height: AppSpace.md),
      ],
      if (day.hasNote) ...[
        _Note(note: day.note!),
        const SizedBox(height: AppSpace.md),
      ],
      _PlanPath(steps: steps, next: next),
      if (next != null && !done) ...[
        const SizedBox(height: AppSpace.md),
        // Um só botão: o próximo passo que falta.
        CopperCta(label: next.cta, expanded: true, onTap: next.onTap),
      ],
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
            nextDay == null
                ? l10n.planLastDayDone
                : l10n.planNextOpens(
                    nextDay.n,
                    planWhen(context, nextDay.date),
                  ),
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
        ],
      ],
    ];
  }

  List<Widget> _ended(
    BuildContext context,
    AppearanceStyle a, {
    required bool cover,
  }) {
    final l10n = context.l10n;
    final done = plan.days.where((d) => mine.done.containsKey(d.n)).length;
    return [
      if (!cover) ...[
        SectionLabel(l10n.planLabelEnded),
        const SizedBox(height: AppSpace.sm),
        _title(a),
        const SizedBox(height: AppSpace.xs),
      ],
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

/// Capa do propósito: a pintura ocupa o topo do card, com o grupo, o
/// propósito e os rostos de quem caminha por cima dela.
class _PlanCover extends StatelessWidget {
  final String art;
  final StudyRoom room;
  final RoomPlan plan;
  final PlanGroup group;
  final String eyebrow;
  final String? myPhotoUrl;
  final PortraitStyle myStyle;
  final VoidCallback onMenu;

  const _PlanCover({
    required this.art,
    required this.room,
    required this.plan,
    required this.group,
    required this.eyebrow,
    required this.myPhotoUrl,
    required this.myStyle,
    required this.onMenu,
  });

  static const _ink = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = group.plan.phase(group.now) == PlanPhase.active
        ? group.plan.today(group.now)
        : null;
    final lit = today == null
        ? const <String>{}
        : {for (final m in group.doneOn(today)) m.uid};
    final members = group.members;
    final line = today == null
        ? l10n.planCoverTogether(members.length)
        : lit.isEmpty
        ? l10n.planCoverNoneToday
        : l10n.planCoverToday(lit.length, members.length);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: AspectRatio(
        // Mais largo que alto: capa compacta, sem “zoom” de card alto.
        aspectRatio: 1.78,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Artes de cena são largas (até 4:1): recortar em 16:9 dava
            // zoom demais. A arte cabe pela largura no topo e o resto da
            // capa é a mesma arte desfocada, onde o texto se apoia.
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Image.asset(
                art,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: Colors.black),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white, Colors.transparent],
                  stops: [0, 0.7, 1],
                ).createShader(r),
                child: Image.asset(
                  art,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
            // Sombra em cima (menu) e embaixo (texto): o texto sempre lê.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.3, 0.55, 1],
                  colors: [
                    Color(0x66000000),
                    Color(0x00000000),
                    Color(0x22000000),
                    Color(0xD9000000),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 14,
              right: 56,
              child: Row(
                children: [
                  CinematicIcon(
                    glyph: room.kind.glyph,
                    size: 15,
                    accent: _ink,
                    framed: false,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      room.kind.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 13,
                        weight: FontWeight.w700,
                        color: _ink.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: Semantics(
                button: true,
                label: l10n.juntosRoomOptions,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ActHaptics.tap();
                    onMenu();
                  },
                  // Placa escura sob o glifo: sobre a pintura clara o
                  // "…" sumia. Mesmo tratamento do fechar da folha da
                  // estação.
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.45),
                          border: Border.all(
                            color: _ink.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Center(
                          child: CinematicIcon(
                            glyph: CinematicGlyph.more,
                            size: AppMetrics.iconLg,
                            accent: _ink,
                            framed: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w800,
                      color: AppRoles.reward,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Semantics(
                    header: true,
                    child: Text(
                      room.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.display(
                        size: 24,
                        height: 1.05,
                        color: _ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      size: 13,
                      color: _ink.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Row(
                    children: [
                      _CoverFaces(
                        members: members,
                        lit: lit,
                        dimUnlit: today != null,
                        myPhotoUrl: myPhotoUrl,
                        myStyle: myStyle,
                      ),
                      const SizedBox(width: AppSpace.sm),
                      Expanded(
                        child: Text(
                          line,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                      ),
                    ],
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

/// Rostos sobrepostos na capa: quem já foi hoje com anel de presença.
class _CoverFaces extends StatelessWidget {
  final List<RoomMember> members;
  final Set<String> lit;
  final bool dimUnlit;
  final String? myPhotoUrl;
  final PortraitStyle myStyle;

  const _CoverFaces({
    required this.members,
    required this.lit,
    required this.dimUnlit,
    required this.myPhotoUrl,
    required this.myStyle,
  });

  @override
  Widget build(BuildContext context) {
    final shown = members.take(6).toList();
    if (shown.isEmpty) return const SizedBox.shrink();
    const r = 15.0;
    const step = 22.0;
    return SizedBox(
      width: r * 2 + step * (shown.length - 1) + 4,
      height: r * 2 + 4,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * step,
              child: Opacity(
                opacity: dimUnlit && !lit.contains(shown[i].uid) ? 0.55 : 1,
                child: UserAvatar(
                  photoUrl: shown[i].isUser ? myPhotoUrl : shown[i].photoUrl,
                  name: shown[i].name,
                  seed: shown[i].uid,
                  radius: r,
                  style: shown[i].isUser ? myStyle : shown[i].portraitStyle,
                  borderColor: lit.contains(shown[i].uid)
                      ? AppRoles.presence
                      : Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Um passo do dia: o que é ([kind]), o conteúdo ([text]) e o botão dele.
class _PlanStep {
  final CinematicGlyph glyph;
  final String kind;
  final String text;
  final String? detail;
  final bool done;
  final String cta;
  final VoidCallback? onTap;

  const _PlanStep({
    required this.glyph,
    required this.kind,
    required this.text,
    this.detail,
    required this.done,
    required this.cta,
    this.onTap,
  });
}

/// O dia como um caminho: nós ligados por uma linha, feito = marcado.
class _PlanPath extends StatelessWidget {
  final List<_PlanStep> steps;

  /// O próximo passo que falta (aceso em amarelo).
  final _PlanStep? next;

  const _PlanPath({required this.steps, required this.next});

  static const _node = 30.0;

  /// Altura de uma linha de detalhe (body 12) — reserva fixa pra
  /// todo passo ter a mesma altura e o vão entre nós ficar igual.
  static const _detailLine = 16.0;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < steps.length; i++)
          _row(context, a, steps[i], last: i == steps.length - 1),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    AppearanceStyle a,
    _PlanStep s, {
    required bool last,
  }) {
    final isNext = identical(s, next);
    final ring = s.done
        ? AppRoles.presence
        : isNext
        ? AppRoles.reward
        : a.cardBorder;
    final detail = s.detail?.trim();
    final node = AnimatedContainer(
      duration: AppMotion.quick,
      width: _node,
      height: _node,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: s.done ? AppRoles.presence : a.cardFill,
        border: Border.all(color: ring, width: isNext ? 2 : 1.5),
      ),
      alignment: Alignment.center,
      child: CinematicIcon(
        glyph: s.done ? CinematicGlyph.check : s.glyph,
        size: 15,
        accent: s.done
            ? AppColors.primaryDark
            : isNext
            ? AppRoles.reward
            : a.textSecondary,
        framed: false,
      ),
    );
    return Semantics(
      button: s.onTap != null,
      label: '${s.kind}: ${s.text}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: s.onTap == null
            ? null
            : () {
                ActHaptics.tap();
                s.onTap!();
              },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _node,
                child: Column(
                  children: [
                    node,
                    if (!last)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: s.done
                                ? AppRoles.presence.withValues(alpha: 0.6)
                                : a.cardBorder,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: last ? 0 : AppSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.kind,
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w700,
                          color: a.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title(
                          size: 15,
                          color: s.done ? a.textSecondary : a.text,
                        ),
                      ),
                      SizedBox(
                        height: _detailLine,
                        child: detail != null && detail.isNotEmpty
                            ? Text(
                                detail,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body(
                                  size: 12,
                                  color: a.textFaint,
                                ),
                              )
                            : null,
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

// ───────────────────────── Respostas do dia ─────────────────────────

class RoomPlanAnswersCard extends StatelessWidget {
  final PlanDay day;
  final bool answered;

  /// Líder vê as respostas sem precisar responder (para moderar).
  final bool isLeader;
  final List<PlanAnswer>? answers;

  /// Quantos outros já responderam (do progresso dos membros): o texto só
  /// é lido depois de responder, e as rules garantem isso.
  final int othersAnswered;

  /// Líder fechou as respostas: o membro vê só a própria.
  final bool private;
  final bool loading;
  final String? myUid;
  final VoidCallback onAnswer;
  final ValueChanged<PlanAnswer> onHold;

  const RoomPlanAnswersCard({
    super.key,
    required this.day,
    required this.answered,
    this.isLeader = false,
    required this.answers,
    this.othersAnswered = 0,
    this.private = false,
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
    final unlocked = answered || isLeader;
    // Amarelo é do card do dia (um botão por tela): aqui, link.
    final answerLink = Align(
      alignment: Alignment.centerLeft,
      child: TextCta(
        label: l10n.planAnswerCta,
        leading: CinematicGlyph.pencil,
        onTap: onAnswer,
      ),
    );
    return ProfilePanel(
      accent: AppRoles.lamp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // O card é sobre a pergunta (e o que o grupo respondeu): hoje
          // na maioria das vezes; dia passado quando escolhido na faixa.
          CardHeader(
            label: day.date == planYmd(DateTime.now())
                ? l10n.planQuestionTodayTitle
                : l10n.planQuestionDayTitle(day.n),
          ),
          const SizedBox(height: AppSpace.sm),
          // A pergunta já está no caminho do dia; aqui ela volta só junto
          // das respostas, para dar contexto ao que o grupo escreveu.
          if (unlocked) ...[
            Text(
              day.question ?? '',
              style: AppTypography.display(
                size: 18,
                height: 1.2,
                color: a.text,
              ),
            ),
            const SizedBox(height: AppSpace.md),
          ],
          if (!unlocked) ...[
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
                    private && !isLeader
                        ? l10n.planAnswersLockedPrivate
                        : l10n.planAnswersLocked,
                    style: AppTypography.body(size: 13, color: a.textSecondary),
                  ),
                ),
              ],
            ),
            if (othersAnswered > 0) ...[
              const SizedBox(height: AppSpace.xs),
              Text(
                l10n.planAnswersCount(othersAnswered),
                style: AppTypography.body(size: 13, color: a.textFaint),
              ),
            ],
            const SizedBox(height: AppSpace.sm),
            answerLink,
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
            if (private && !isLeader)
              Text(
                l10n.planAnswersPrivateNote,
                style: AppTypography.body(size: 13, color: a.textSecondary),
              )
            else if (others.isEmpty)
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
            if (!answered) ...[const SizedBox(height: AppSpace.sm), answerLink],
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
    return ProfilePanel(
      accent: AppRoles.reward,
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
