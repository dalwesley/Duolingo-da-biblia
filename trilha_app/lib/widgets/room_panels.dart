import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/season_walk_catalog.dart';
import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/study_room.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../models/room_plan.dart';
import '../models/season_walk.dart';
import '../screens/paywall_screen.dart';
import '../services/subscription_service.dart';
import '../utils/plus_access.dart';
import '../data/mission_study.dart';
import '../services/bible_service.dart';
import '../services/league_service.dart';
import '../services/moderation_service.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../services/session_composer.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/content_filter.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
import '../services/content_catalog_service.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'hero_card_atmosphere.dart';
import 'immersive_background.dart';
import 'user_avatar.dart';
import 'ui_primitives.dart';
import 'user_moderation_sheet.dart';

/// Peças da aba Grupos: estudo da semana, quem precisa de um chamado e as
/// sheets do líder (tipo/nome, escolher estudo, menu, passar liderança).

/// Dias sem estudar a partir dos quais a pessoa aparece em "Chamar".
const int kRoomCallAfterDays = 3;

// ───────────────────────── Estudo da semana ─────────────────────────

class RoomStudyCard extends StatelessWidget {
  final StudyRoom room;
  final RoomStudy? study;
  final List<RoomMember> members;
  final bool isLeader;
  final VoidCallback onPick;
  final VoidCallback onOpen;

  /// Topo do card (nome do grupo + menu). Com ele, o card vira o herói do
  /// grupo e "Trocar" sai daqui — mora no menu do topo.
  final Widget? header;

  const RoomStudyCard({
    super.key,
    required this.room,
    required this.study,
    required this.members,
    required this.isLeader,
    required this.onPick,
    required this.onOpen,
    this.header,
  });

  /// Com [header]: topo curto e à direita (o botão de opções de 48 já traz o
  /// respiro); o corpo recupera o recuo direito.
  static EdgeInsets cardPaddingFor(Widget? header) => header == null
      ? AppMetrics.cardPadding
      : AppMetrics.cardPadding.copyWith(top: AppSpace.sm, right: 6);

  static Widget bodyFor(Widget? header, Widget body) => header == null
      ? body
      : Padding(padding: const EdgeInsets.only(right: 12), child: body);

  @override
  Widget build(BuildContext context) {
    final s = study;
    if (s == null) {
      return _EmptyStage(
        room: room,
        isLeader: isLeader,
        onPick: onPick,
        header: header,
      );
    }

    final a = Appearance.of(context);
    final meDone = members.any((m) => m.isUser && m.didStudy(s));

    // O card inteiro abre o estudo. Quem já fez quem vê é o líder (na
    // Semana do grupo); aqui fica a trilha e a cena.
    final head = header;
    return GlassCard(
      tint: meDone ? AppRoles.presence : a.place,
      glow: meDone ? 0.3 : 0.75,
      elevated: !meDone,
      padding: cardPaddingFor(head),
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (head != null)
            head
          else
            CardHeader(
              label: context.l10n.groupWeekStudy,
              accent: meDone ? AppRoles.presence : null,
              trailing: isLeader
                  ? TextCta(
                      label: context.l10n.groupStudySwap,
                      leading: CinematicGlyph.pencil,
                      onTap: onPick,
                    )
                  : null,
            ),
          bodyFor(
            head,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (head != null) const SizedBox(height: AppSpace.lg),
                SectionLabel(
                  [
                    context.l10n.groupWeekStudy,
                    if (s.verseRef != null && s.verseRef!.trim().isNotEmpty)
                      s.verseRef!.trim(),
                  ].join(' · '),
                  maxLines: 1,
                ),
                const SizedBox(height: AppSpace.sm),
                Text(
                  s.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.display(
                    size: 24,
                    height: 1.08,
                    color: a.text,
                  ),
                ),
                _StudyTrailInfo(missionSlug: s.missionSlug),
                if (s.note != null && s.note!.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.md),
                  _LeaderNote(
                    title: context.l10n.groupLeaderNoteTitle(
                      room.kind.leaderTitle,
                      _firstName(room.ownerName),
                    ),
                    note: s.note!,
                  ),
                ],
                const SizedBox(height: AppSpace.md),
                Row(
                  children: [
                    CinematicIcon(
                      glyph: meDone
                          ? CinematicGlyph.check
                          : CinematicGlyph.book,
                      size: 14,
                      accent: meDone ? AppRoles.presence : a.textSecondary,
                      framed: false,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        meDone
                            ? context.l10n.groupStudyDoneTapAgain
                            : context.l10n.groupStudyTapToOpen,
                        style: AppTypography.body(
                          size: 13,
                          weight: FontWeight.w700,
                          color: meDone ? AppRoles.presence : a.textSecondary,
                        ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Trilha e lugar da cena ("Gênesis 1–11 · cena 1 de 12") e o começo da
/// introdução — o que o grupo vai encontrar.
class _StudyTrailInfo extends StatefulWidget {
  final String missionSlug;

  const _StudyTrailInfo({required this.missionSlug});

  @override
  State<_StudyTrailInfo> createState() => _StudyTrailInfoState();
}

class _StudyTrailInfoState extends State<_StudyTrailInfo> {
  late Future<({Trail trail, Mission mission, int index, int total})?> _info =
      _load(widget.missionSlug);

  @override
  void didUpdateWidget(covariant _StudyTrailInfo old) {
    super.didUpdateWidget(old);
    if (old.missionSlug != widget.missionSlug) {
      _info = _load(widget.missionSlug);
    }
  }

  static Future<({Trail trail, Mission mission, int index, int total})?> _load(
    String slug,
  ) async {
    for (final trail in await TrailRepository().getTrails()) {
      final scenes = [for (final m in trail.modules) ...m.missions];
      final i = scenes.indexWhere((m) => m.slug == slug);
      if (i >= 0) {
        return (
          trail: trail,
          mission: scenes[i],
          index: i,
          total: scenes.length,
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return FutureBuilder(
      future: _info,
      builder: (context, snap) {
        final info = snap.data;
        if (info == null) return const SizedBox.shrink();
        final intro = info.mission.localizedIntro.trim();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpace.sm),
            Text(
              context.l10n.groupStudyTrailLine(
                info.trail.localizedTitle,
                info.index + 1,
                info.total,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w700,
                color: a.textSecondary,
              ),
            ),
            if (intro.isNotEmpty) ...[
              const SizedBox(height: AppSpace.sm),
              Text(
                intro,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body(size: 14, height: 1.4, color: a.text),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Sem estudo marcado: um palco vazio. O líder é convidado a escolher.
class _EmptyStage extends StatelessWidget {
  final StudyRoom room;
  final bool isLeader;
  final VoidCallback onPick;
  final Widget? header;

  /// Textos do vazio do propósito (sem eles, o do estudo da semana).
  final ({String label, String title, String body, String cta})? copy;

  const _EmptyStage({
    required this.room,
    required this.isLeader,
    required this.onPick,
    this.header,
    this.copy,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final head = header;
    return GlassCard(
      glow: isLeader ? 0.55 : null,
      tint: isLeader ? a.place : null,
      padding: RoomStudyCard.cardPaddingFor(head),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (head != null)
            head
          else
            CardHeader(label: context.l10n.groupWeekStudy),
          RoomStudyCard.bodyFor(
            head,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (head != null) ...[
                  const SizedBox(height: AppSpace.lg),
                  SectionLabel(copy?.label ?? context.l10n.groupWeekStudy),
                ],
                const SizedBox(height: AppSpace.md),
                CustomPaint(
                  painter: _DashedFramePainter(color: a.textFaint),
                  child: EmptyState(
                    title:
                        copy?.title ??
                        (isLeader
                            ? context.l10n.groupEmptyLeaderTitle
                            : context.l10n.groupEmptyMemberTitle),
                    body:
                        copy?.body ??
                        (isLeader
                            ? context.l10n.groupEmptyLeaderBody
                            : context.l10n.groupEmptyMemberBody(
                                room.kind.leaderTitle,
                              )),
                  ),
                ),
                if (isLeader) ...[
                  const SizedBox(height: AppSpace.lg),
                  CopperCta(
                    label: copy?.cta ?? context.l10n.groupPickStudyCta,
                    onTap: onPick,
                    leading: copy == null
                        ? CinematicGlyph.book
                        : CinematicGlyph.calendar,
                    trailing: null,
                    dense: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grupo sem propósito: o topo convida o líder a criar (trilha, livro e
/// datas moram dentro do propósito); o membro espera.
class RoomPlanEmptyCard extends StatelessWidget {
  final StudyRoom room;
  final bool isLeader;
  final Widget header;
  final VoidCallback onCreate;

  const RoomPlanEmptyCard({
    super.key,
    required this.room,
    required this.isLeader,
    required this.header,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _EmptyStage(
      room: room,
      isLeader: isLeader,
      onPick: onCreate,
      header: header,
      copy: (
        label: l10n.planEmptyLabel,
        title: isLeader ? l10n.planEmptyLeaderTitle : l10n.planEmptyMemberTitle,
        body: isLeader
            ? l10n.planEmptyLeaderBody
            : l10n.planEmptyMemberBody(room.kind.leaderTitle),
        cta: l10n.planEmptyCta,
      ),
    );
  }
}

/// Trecho da Palavra com fio claro (chrome) à esquerda.
class _VerseStage extends StatelessWidget {
  final String text;
  final String? reference;
  const _VerseStage({super.key, required this.text, this.reference});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.hair),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [a.place, a.place.withValues(alpha: 0.1)],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '“${text.replaceAll(RegExp(r'[,;:]\s*…$'), '…')}”',
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.verse(
                    size: 19,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    color: a.text,
                  ),
                ),
                if (reference != null && reference!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  SectionLabel(reference!, size: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Recado de quem conduz: aspas + texto em 2 linhas, sem painel. Toque
/// abre o recado inteiro. "Responsável Fulano" fica só no leitor de tela.
class _LeaderNote extends StatefulWidget {
  final String title;
  final String note;

  const _LeaderNote({required this.title, required this.note});

  @override
  State<_LeaderNote> createState() => _LeaderNoteState();
}

class _LeaderNoteState extends State<_LeaderNote> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Semantics(
      label: '${widget.title}: ${widget.note}',
      excludeSemantics: true,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _open = !_open),
        child: AnimatedSize(
          duration: AppMotion.quick,
          alignment: Alignment.topCenter,
          child: Row(
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
                  widget.note,
                  maxLines: _open ? null : 2,
                  overflow: _open ? null : TextOverflow.ellipsis,
                  style: AppTypography.body(
                    size: 14,
                    height: 1.4,
                    color: a.textSecondary,
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

class _DashedFramePainter extends CustomPainter {
  final Color color;

  const _DashedFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppRadii.md),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedFramePainter old) => old.color != color;
}

// ───────────────────────── Pessoa do grupo ─────────────────────────

/// O que a pessoa escolheu na folha de alguém do grupo.
enum RoomSeatAction { wave, profile, transfer, moderate }

/// Recado do aceno no grupo. Só recados prontos (sem texto livre): a
/// notificação sai da function `onRoomNudge` com o texto de cada um.
enum RoomWaveKind { plan, pray, cheer, miss, study }

/// Escolher o recado do aceno. [invitePlan]: a pessoa ainda não entrou no
/// propósito que vai começar — o convite vem primeiro.
Future<RoomWaveKind?> showRoomWavePicker(
  BuildContext context, {
  required String name,
  bool invitePlan = false,
}) {
  return showAppSheet<RoomWaveKind>(
    context,
    builder: (ctx) {
      final l10n = ctx.l10n;
      String label(RoomWaveKind k) => switch (k) {
        RoomWaveKind.plan => l10n.waveKindPlan,
        RoomWaveKind.pray => l10n.waveKindPray,
        RoomWaveKind.cheer => l10n.waveKindCheer,
        RoomWaveKind.miss => l10n.waveKindMiss,
        RoomWaveKind.study => l10n.waveKindStudy,
      };
      CinematicGlyph glyph(RoomWaveKind k) => switch (k) {
        RoomWaveKind.plan => CinematicGlyph.calendar,
        RoomWaveKind.pray => CinematicGlyph.heart,
        RoomWaveKind.cheer => CinematicGlyph.spark,
        RoomWaveKind.miss => CinematicGlyph.people,
        RoomWaveKind.study => CinematicGlyph.book,
      };
      final kinds = [
        if (invitePlan) RoomWaveKind.plan,
        RoomWaveKind.cheer,
        RoomWaveKind.pray,
        RoomWaveKind.miss,
        if (!invitePlan) RoomWaveKind.study,
      ];
      return AppSheetPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              title: l10n.nudgeTitle(name),
              subtitle: l10n.waveSheetSubtitle(name),
            ),
            const SizedBox(height: AppSpace.md),
            for (final k in kinds)
              _SeatActionRow(
                label: label(k),
                glyph: glyph(k),
                onTap: () => Navigator.pop(ctx, k),
              ),
          ],
        ),
      );
    },
  );
}

/// Toque numa pessoa do grupo: quem é, como está e o que dá para fazer
/// (acenar, ver o perfil, passar a liderança, denunciar ou bloquear).
Widget _planStat(BuildContext ctx, RoomMember member, RoomPlan plan) {
  final l10n = ctx.l10n;
  final mine = plan.progressOf(member.plan);
  if (plan.phase() == PlanPhase.upcoming) {
    final joined = mine?.joined ?? false;
    return _SeatStat(
      value: joined ? l10n.planSeatIn : l10n.planSeatNotIn,
      label: l10n.planSeatLabel,
      highlight: joined,
    );
  }
  final done = mine?.done.length ?? 0;
  return _SeatStat(
    value: '$done/${plan.total}',
    label: l10n.planSeatDays,
    highlight: done > 0,
  );
}

Future<RoomSeatAction?> showRoomSeatSheet(
  BuildContext context, {
  required RoomMember member,
  required String status,
  required bool isLeader,
  required String leaderTitle,
  required RoomStudy? study,
  RoomPlan? plan,
  required bool canCall,
  required bool alreadyCalled,
  bool canViewProfile = false,
  bool canTransfer = false,
  bool canModerate = false,

  /// Respostas da pessoa às perguntas do propósito (dia → texto), só dos
  /// dias que quem olha pode ver.
  Future<Map<int, String>>? answers,

  /// Dias que a pessoa respondeu e quem olha ainda não pode ver.
  int hiddenAnswers = 0,
}) {
  return showAppSheet<RoomSeatAction>(
    context,
    builder: (ctx) {
      final a = Appearance.of(ctx);
      void pick(RoomSeatAction action) => Navigator.pop(ctx, action);
      final today = member.walkedToday();
      final first = _firstName(member.name);
      final quiet =
          !member.walkedThisWeek &&
          (member.daysSinceWalk() == null ||
              member.daysSinceWalk()! >= kRoomCallAfterDays);
      // "Estudou hoje" = presença (teal): anel e halo.
      final face = UserAvatar(
        name: member.name,
        photoUrl: member.photoUrl,
        seed: member.uid,
        radius: AppMetrics.avatarLg,
        style: member.portraitStyle,
        borderColor: today ? AppRoles.presence : a.cardBorder,
      );
      return AppSheetPanel(
        tint: today ? AppRoles.presence : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: today
                      ? [
                          BoxShadow(
                            color: AppRoles.presence.withValues(alpha: 0.4),
                            blurRadius: 22,
                          ),
                        ]
                      : null,
                ),
                child: _SeatFace(
                  onTap: canViewProfile
                      ? () => pick(RoomSeatAction.profile)
                      : null,
                  semanticsLabel: ctx.l10n.groupSeatViewProfile,
                  child: quiet
                      ? HeroCardColorGrade(
                          mood: HeroCardMood.dusty,
                          child: face,
                        )
                      : face,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            AppSheetHeader(
              cloud: false,
              title: member.isUser ? ctx.l10n.commonYou : member.name,
              center: true,
            ),
            if (isLeader) ...[
              const SizedBox(height: 6),
              Center(
                child: SoftBadge(
                  text: leaderTitle,
                  glyph: CinematicGlyph.crown,
                  accent: a.place,
                ),
              ),
            ],
            const SizedBox(height: AppSpace.sm),
            Text(
              status[0].toUpperCase() + status.substring(1),
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w700,
                color: today ? AppRoles.presence : a.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            _WeekDaysStrip(days: member.weekDays),
            const SizedBox(height: AppSpace.md),
            InsetPanel(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  _SeatStat(
                    value: '${member.daysThisWeek}/7',
                    label: ctx.l10n.groupSeatDaysInWeek,
                    highlight: member.daysThisWeek > 0,
                  ),
                  Container(width: 1, height: 28, color: a.cardBorder),
                  _SeatStat(
                    value: '${member.steps}',
                    label: ctx.l10n.groupSeatSteps,
                  ),
                  Container(width: 1, height: 28, color: a.cardBorder),
                  // Com propósito, o terceiro número é dele: antes de
                  // começar, se a pessoa está dentro; depois, os dias feitos.
                  if (plan != null)
                    _planStat(ctx, member, plan)
                  else
                    _SeatStat(
                      value: study == null
                          ? '—'
                          : (member.didStudy(study)
                                ? ctx.l10n.groupSeatStudyDone
                                : ctx.l10n.groupSeatStudyNotYet),
                      label: ctx.l10n.groupWeekStudy,
                      highlight: member.didStudy(study),
                    ),
                ],
              ),
            ),
            if (plan != null && (answers != null || hiddenAnswers > 0))
              _SeatAnswers(
                plan: plan,
                answers: answers,
                hidden: hiddenAnswers,
                firstName: first,
              ),
            if (canCall) ...[
              const SizedBox(height: AppSpace.lg),
              CopperCta(
                label: ctx.l10n.nudgeTitle(first),
                onTap: () => pick(RoomSeatAction.wave),
                leading: CinematicGlyph.bell,
                trailing: null,
              ),
            ] else if (alreadyCalled) ...[
              const SizedBox(height: AppSpace.md),
              Text(
                ctx.l10n.groupSeatAlreadyWaved(first),
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 13, color: a.textFaint),
              ),
            ],
            if (canViewProfile || canTransfer || canModerate) ...[
              const SizedBox(height: AppSpace.md),
              if (canViewProfile)
                _SeatActionRow(
                  label: ctx.l10n.groupSeatViewProfile,
                  glyph: CinematicGlyph.people,
                  onTap: () => pick(RoomSeatAction.profile),
                ),
              if (canTransfer)
                _SeatActionRow(
                  label: ctx.l10n.groupSeatMakeLeader(first),
                  glyph: CinematicGlyph.crown,
                  onTap: () => pick(RoomSeatAction.transfer),
                ),
              if (canModerate)
                _SeatActionRow(
                  label: ctx.l10n.moderationMenuLabel,
                  glyph: CinematicGlyph.flag,
                  faint: true,
                  onTap: () => pick(RoomSeatAction.moderate),
                ),
            ],
          ],
        ),
      );
    },
  );
}

/// Respostas da pessoa na folha: a mais recente primeiro, cada uma com o
/// dia e a pergunta. Rola por dentro para a folha não crescer demais.
class _SeatAnswers extends StatelessWidget {
  final RoomPlan plan;
  final Future<Map<int, String>>? answers;
  final int hidden;
  final String firstName;

  const _SeatAnswers({
    required this.plan,
    required this.answers,
    required this.hidden,
    required this.firstName,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return FutureBuilder<Map<int, String>>(
      future: answers,
      builder: (context, snap) {
        final loading =
            answers != null && snap.connectionState != ConnectionState.done;
        final map = snap.data ?? const <int, String>{};
        final days = map.keys.toList()..sort((x, y) => y.compareTo(x));
        if (!loading && days.isEmpty && hidden == 0) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: AppSpace.md),
          child: InsetPanel(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionLabel(l10n.planSeatAnswersLabel, size: 10),
                const SizedBox(height: AppSpace.sm),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpace.sm),
                    child: AppSpinner(inline: true),
                  )
                else if (days.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (i, n) in days.indexed) ...[
                            if (i > 0) const SizedBox(height: AppSpace.md),
                            Text(
                              [
                                l10n.planSeatAnswerDay(n),
                                ?plan.dayNumber(n)?.question?.trim(),
                              ].join(' · '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(
                                size: 12,
                                weight: FontWeight.w700,
                                color: a.textFaint,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              map[n]!,
                              style: AppTypography.body(
                                size: 14,
                                height: 1.35,
                                color: a.text,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                if (!loading && hidden > 0) ...[
                  if (days.isNotEmpty) const SizedBox(height: AppSpace.sm),
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
                          l10n.planSeatAnswersHidden(firstName),
                          style: AppTypography.body(
                            size: 13,
                            color: a.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Rosto da folha: tocar abre o perfil (quando há perfil para ver).
class _SeatFace extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String semanticsLabel;

  const _SeatFace({
    required this.child,
    required this.onTap,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ActHaptics.tap();
          onTap!();
        },
        child: child,
      ),
    );
  }
}

/// Linha discreta de ação na folha da pessoa (ícone, rótulo, seta).
class _SeatActionRow extends StatelessWidget {
  final String label;
  final CinematicGlyph glyph;
  final VoidCallback onTap;
  final bool faint;

  const _SeatActionRow({
    required this.label,
    required this.glyph,
    required this.onTap,
    this.faint = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: () {
          ActHaptics.tap();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              CinematicIcon(
                glyph: glyph,
                size: AppMetrics.iconMd,
                accent: faint ? a.textFaint : a.place,
                framed: false,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(
                    size: 14,
                    color: faint ? a.textSecondary : a.text,
                  ),
                ),
              ),
              ListChevron(color: a.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeatStat extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;

  const _SeatStat({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.title(
              size: 18,
              color: highlight ? AppRoles.presence : a.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.3,
              color: a.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

/// Seg → Dom: dia cheio quando a pessoa estudou; hoje com contorno.
class _WeekDaysStrip extends StatelessWidget {
  final List<int> days;

  const _WeekDaysStrip({required this.days});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final today = DateTime.now().weekday;
    final narrow = DateFormat(
      'EEEEE',
      Localizations.localeOf(context).toLanguageTag(),
    );
    // 1 de janeiro de 2024 foi segunda: dia d da semana = 2024-01-d.
    String label(int d) => narrow.format(DateTime(2024, 1, d));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var d = 1; d <= 7; d++)
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: days.contains(d)
                      ? AppRoles.presence
                      : d > today
                      ? Colors.transparent
                      : a.cardFillSoft,
                  border: Border.all(
                    color: d == today
                        ? a.selected
                        : days.contains(d)
                        ? AppRoles.presence
                        : a.cardBorder,
                    width: d == today ? 2 : 1,
                  ),
                ),
                child: days.contains(d)
                    ? const Center(
                        child: CinematicIcon(
                          glyph: CinematicGlyph.check,
                          size: AppMetrics.chipIcon,
                          accent: AppColors.night,
                          framed: false,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                label(d),
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.4,
                  color: d == today ? a.text : a.textFaint,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ───────────────────────── Tipo e nome do grupo ─────────────────────────

typedef RoomSetup = ({String name, RoomKind kind});

Future<RoomSetup?> showRoomSetupSheet(
  BuildContext context, {
  String? title,
  String? confirmLabel,
  String initialName = '',
  RoomKind initialKind = RoomKind.celula,
}) {
  return showAppSheet<RoomSetup>(
    context,
    builder: (_) => _RoomSetupSheet(
      title: title ?? context.l10n.groupNewTitle,
      confirmLabel: confirmLabel ?? context.l10n.groupCreateCta,
      initialName: initialName,
      initialKind: initialKind,
    ),
  );
}

class _RoomSetupSheet extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String initialName;
  final RoomKind initialKind;

  const _RoomSetupSheet({
    required this.title,
    required this.confirmLabel,
    required this.initialName,
    required this.initialKind,
  });

  @override
  State<_RoomSetupSheet> createState() => _RoomSetupSheetState();
}

class _RoomSetupSheetState extends State<_RoomSetupSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );
  late RoomKind _kind = widget.initialKind;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    // O nome do grupo aparece no convite para outras pessoas.
    if (!ContentFilter.isAllowed(name)) {
      setState(() => _error = context.l10n.contentNameNotAllowed);
      return;
    }
    Navigator.pop(context, (name: name, kind: _kind));
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return AppSheetPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(title: widget.title),
          const SizedBox(height: AppSpace.lg),
          SectionLabel(context.l10n.groupSetupKindLabel),
          const SizedBox(height: AppSpace.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in RoomKind.values)
                _KindChip(
                  kind: k,
                  selected: k == _kind,
                  onTap: () => setState(() => _kind = k),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          SectionLabel(context.l10n.groupSetupNameLabel),
          const SizedBox(height: AppSpace.sm),
          TextField(
            controller: _name,
            maxLength: 40,
            textCapitalization: TextCapitalization.sentences,
            style: AppTypography.body(size: 16, color: a.text),
            decoration: InputDecoration(
              hintText: _kind.namePlaceholder,
              counterText: '',
              errorText: _error,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            context.l10n.groupSetupLimitHint(kRoomMemberLimit),
            style: AppTypography.body(
              size: 12,
              height: 1.35,
              color: a.textFaint,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          ValueListenableBuilder(
            valueListenable: _name,
            builder: (context, value, _) => CopperCta(
              label: widget.confirmLabel,
              onTap: value.text.trim().isEmpty ? null : _submit,
              leading: _kind.glyph,
              trailing: null,
            ),
          ),
        ],
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  final RoomKind kind;
  final bool selected;
  final VoidCallback onTap;

  const _KindChip({
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GestureDetector(
      onTap: () {
        ActHaptics.tap();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppMotion.quick,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? a.selected.withValues(alpha: 0.12) : a.cardFillSoft,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected ? a.selected.withValues(alpha: 0.7) : a.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CinematicIcon(
              glyph: kind.glyph,
              size: AppMetrics.chipIcon,
              accent: selected ? a.selected : a.textSecondary,
              framed: false,
            ),
            const SizedBox(width: 6),
            Text(
              kind.label,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w800,
                color: selected ? a.selected : a.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Escolher o estudo ─────────────────────────

/// [title] troca o topo ("Estudo da semana"); [skipNote] devolve a cena no
/// toque, sem o passo do recado (o propósito tem recado por dia).
/// [withSeason]: mostra a aba Estação (Advento). Escolher a temporada
/// devolve um [RoomStudy] com [RoomStudy.seasonId] (só o propósito usa).
Future<RoomStudy?> showRoomStudyPicker(
  BuildContext context, {
  String? title,
  bool skipNote = false,
  bool withSeason = false,
}) {
  return showAppSheet<RoomStudy>(
    context,
    builder: (_) => _RoomStudyPicker(
      title: title,
      skipNote: skipNote,
      withSeason: withSeason,
    ),
  );
}

/// Aba Estação do seletor (fora das prateleiras de trilha).
const _seasonShelf = 'season';

class _RoomStudyPicker extends StatefulWidget {
  final String? title;
  final bool skipNote;
  final bool withSeason;

  const _RoomStudyPicker({
    this.title,
    this.skipNote = false,
    this.withSeason = false,
  });

  @override
  State<_RoomStudyPicker> createState() => _RoomStudyPickerState();
}

class _RoomStudyPickerState extends State<_RoomStudyPicker> {
  late final Future<List<Trail>> _trails = TrailRepository().getTrails();
  final _note = TextEditingController();
  final _search = TextEditingController();
  String? _noteError;
  Trail? _trail;
  Mission? _mission;

  /// Aba das trilhas: null = Suas trilhas; senão a prateleira da aba Trilhas.
  TrailShelf? _shelf;
  bool _shelfPicked = false;

  /// Aba Estação aberta (só com [_RoomStudyPicker.withSeason]).
  bool _seasonTab = false;

  /// Temporada em cartaz: a que corre agora, senão a próxima.
  /// Só aparece se começa em até 120 dias (mesmo limite do início do
  /// propósito): depois do Natal não oferece o Advento do ano seguinte.
  late final SeasonWalkCampaign? _season = () {
    if (!widget.withSeason) return null;
    final c = SeasonWalkCatalog.current();
    final now = DateTime.now();
    final limit = DateTime(now.year, now.month, now.day + 120);
    return c.start.isAfter(limit) ? null : c;
  }();

  /// Sem o Plus, trilha do Plus e temporada fora do presente levam à
  /// assinatura: o grupo caminharia por algo que o líder não abre.
  bool get _plusOpen => context.read<SubscriptionService>().plusFeaturesOpen;

  void _openPaywall() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PaywallScreen(source: 'group_pick'),
      ),
    );
  }

  void _pickSeason(SeasonWalkCampaign c) {
    if (!c.isGift && !_plusOpen) {
      _openPaywall();
      return;
    }
    Navigator.pop(
      context,
      RoomStudy(
        missionSlug: c.days.first.missionSlug,
        title: c.title,
        week: '${RoomStudy.seasonPrefix}${c.id}',
      ),
    );
  }

  /// Grupo aberto na aba Bíblia (um por vez).
  TrailCategory? _openGroup;

  /// Palco da cena (ref + trecho) — o mesmo que a missão abre.
  ({String? ref, String? verse})? _stage;

  @override
  void dispose() {
    _note.dispose();
    _search.dispose();
    super.dispose();
  }

  void _back() => setState(() {
    if (_mission != null) {
      _mission = null;
      _stage = null;
    } else {
      _trail = null;
    }
  });

  Future<void> _pickMission(Mission m) async {
    if (widget.skipNote) {
      Navigator.pop(
        context,
        RoomStudy(
          missionSlug: m.slug,
          title: m.localizedTitle,
          verseRef: m.hookRef ?? m.subtitle,
          week: LeagueService.weekKey(),
        ),
      );
      return;
    }
    setState(() {
      _mission = m;
      _stage = null;
    });
    final stage = await _resolveStage(m);
    if (!mounted || _mission?.slug != m.slug) return;
    setState(() => _stage = stage);
  }

  static final _refLike = RegExp(r'\d');

  static Future<({String? ref, String? verse})> _resolveStage(Mission m) async {
    // Estudos vêm por trilha: a cena escolhida aqui pode ser de outra.
    await ContentCatalogService.instance.ensureStudies([
      m.slug,
      m.resolvedBankSection,
    ]);
    final study =
        MissionStudy.forSlug(m.slug) ??
        MissionStudy.forSlug(m.resolvedBankSection);
    final entrance = SessionComposer.resolveEntrance(
      mission: m,
      studyRef: study?.passageRef,
      studyVerse: study?.passageText,
      studyContext: study?.localizedContext,
    );
    var ref = (entrance.ref ?? '').trim();
    var verse = (entrance.verse ?? '').trim();
    // Catálogo sem palco: o subtítulo da cena já é a referência.
    if (ref.isEmpty && _refLike.hasMatch(m.subtitle)) ref = m.subtitle.trim();
    if (ref.isNotEmpty) {
      try {
        final full = await BibleService.instance.passageText(
          ref,
          translationId: BibleService.palcoTranslationId,
        );
        if (full != null && full.trim().isNotEmpty) verse = full.trim();
      } catch (_) {}
    }
    if (verse.isNotEmpty) {
      verse = SessionComposer.clipEntranceVerse(
        verse,
        maxWords: 36,
      ).replaceAll(RegExp(r'[,;:]\s*…$'), '…');
    }
    return (ref: ref.isEmpty ? null : ref, verse: verse.isEmpty ? null : verse);
  }

  void _confirm() {
    final m = _mission;
    if (m == null) return;
    if (!ContentFilter.isAllowed(_note.text)) {
      setState(() => _noteError = context.l10n.contentTextNotAllowed);
      return;
    }
    Navigator.pop(
      context,
      RoomStudy(
        missionSlug: m.slug,
        title: m.localizedTitle,
        verseRef: _stage?.ref ?? m.hookRef,
        verse: _stage?.verse ?? m.hookVerse,
        note: _note.text.trim(),
        week: LeagueService.weekKey(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    // Com teclado aberto (recado), o painel encolhe em vez de transbordar.
    final screen = MediaQuery.sizeOf(context).height;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final top = MediaQuery.paddingOf(context).top;
    final height = (screen * 0.72)
        .clamp(0.0, screen - keyboard - top - 96)
        .toDouble();
    final heading = _mission != null
        ? context.l10n.groupPickerMarkScene
        : (_trail?.localizedTitle ??
              widget.title ??
              context.l10n.groupWeekStudy);

    return AppSheetPanel(
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (_trail != null)
                  Semantics(
                    button: true,
                    label: context.l10n.commonBack,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ActHaptics.tap();
                        _back();
                      },
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: CinematicIcon(
                            glyph: CinematicGlyph.back,
                            size: AppMetrics.iconMd,
                            accent: a.text,
                            framed: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    heading,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title(size: 20, color: a.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            Expanded(
              child: _mission != null
                  ? _noteStep(a)
                  : FutureBuilder<List<Trail>>(
                      future: _trails,
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const AppSpinner();
                        }
                        final t = _trail;
                        return t == null
                            ? _trailList(snap.data!, a)
                            : _missionList(t, a);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Categoria da trilha dentro do seu card (dado antigo cai no 1º).
  static TrailCategory _categoryOf(Trail t) {
    final journey = t.journey;
    final c = TrailCategory.tryFromId(t.categoryId);
    return c != null && journey.categories.contains(c)
        ? c
        : journey.categories.first;
  }

  /// Minúsculas sem acento — "genesis" acha "Gênesis".
  static String _fold(String s) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    final lower = s.toLowerCase();
    final out = StringBuffer();
    for (final ch in lower.split('')) {
      final i = from.indexOf(ch);
      out.write(i < 0 ? ch : to[i]);
    }
    return out.toString();
  }

  Widget _trailRow(Trail t) {
    final locked = PlusAccess.trailIsPlus(t) && !_plusOpen;
    return _PickRow(
      leading: _TrailDisc(visuals: TrailVisuals.forTrail(t)),
      title: t.localizedTitle,
      subtitle: context.l10n.commonScenes(t.missionSlugs.length),
      trailing: locked ? const _PlusLock() : null,
      onTap: () {
        FocusScope.of(context).unfocus();
        if (locked) {
          _openPaywall();
          return;
        }
        setState(() => _trail = t);
      },
    );
  }

  Widget _seasonRow(SeasonWalkCampaign c) {
    final locked = !c.isGift && !_plusOpen;
    return _PickRow(
      leading: ClipOval(
        child: Image.asset(
          SeasonWalkCatalog.artAsset(c.kind),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      ),
      title: c.title,
      subtitle: [
        context.l10n.commonScenes(c.length),
        if (c.isGift) context.l10n.seasonGiftTag,
      ].join(' · '),
      trailing: locked ? const _PlusLock() : null,
      onTap: () {
        FocusScope.of(context).unfocus();
        _pickSeason(c);
      },
    );
  }

  Widget _trailList(List<Trail> all, AppearanceStyle a) {
    final trails = [
      for (final t in all)
        if (!t.comingSoon && t.missionSlugs.isNotEmpty) t,
    ];
    final progress = context.watch<ProgressService>();
    final mine = [
      for (final t in TrailProgress.myTrails(
        all,
        progress.completedMissions,
        chosenAt: progress.trailChosenAt,
        seeded: progress.trailChoicesSeeded,
        clearedTrailModes: progress.clearedTrailModes,
        trailModes: progress.activeTrailModes,
        pinnedModes: progress.pinnedTrailDifficulties,
        completedOn: progress.missionCompletedOn,
        borrowed: progress.borrowedMissions,
      ))
        if (trails.contains(t)) t,
    ];
    // As mesmas prateleiras da aba Trilhas (não o `realm` gravado: Temas
    // mora em Vida Cristã ou no AT/NT).
    final shelves = [
      for (final shelf in TrailShelf.values)
        if (trails.any((t) => t.journey.shelf == shelf)) shelf,
    ];
    TrailShelf? shelf = _shelfPicked
        ? _shelf
        : (mine.isNotEmpty ? null : shelves.firstOrNull);
    if (shelf == null && mine.isEmpty) shelf = shelves.firstOrNull;

    final query = _fold(_search.text.trim());
    final searching = query.isNotEmpty;

    final List<Widget> rows;
    if (searching) {
      final hits = [
        for (final t in trails)
          if (_fold(t.localizedTitle).contains(query) ||
              _fold(_categoryOf(t).label).contains(query))
            t,
      ];
      final season = _season;
      final seasonHit = season != null && _fold(season.title).contains(query);
      rows = hits.isEmpty && !seasonHit
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
                child: Text(
                  context.l10n.groupPickerSearchEmpty,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(size: 13, color: a.textSecondary),
                ),
              ),
            ]
          : [
              if (seasonHit) _seasonRow(season),
              for (final t in hits) _trailRow(t),
            ];
    } else if (_seasonTab && _season != null) {
      rows = [_seasonRow(_season)];
    } else if (shelf == null) {
      rows = [for (final t in mine) _trailRow(t)];
    } else if (shelf == TrailShelf.biblia) {
      rows = [
        for (final journey in TrailJourney.forShelf(shelf))
          if (trails.any((t) => t.journey == journey)) ...[
            Padding(
              padding: EdgeInsets.only(
                top: journey == TrailJourney.antigoTestamento ? 0 : AppSpace.md,
                bottom: AppSpace.sm,
              ),
              child: SectionLabel(journey.realm.label),
            ),
            for (final category in journey.categories)
              if (trails.any(
                (t) => t.journey == journey && _categoryOf(t) == category,
              ))
                _PickGroup(
                  title: category.label,
                  visuals: TrailVisuals.forSlug('', categoryId: category.id),
                  expanded: _openGroup == category,
                  onToggle: () => setState(
                    () => _openGroup = _openGroup == category ? null : category,
                  ),
                  trails: [
                    for (final t in trails)
                      if (t.journey == journey && _categoryOf(t) == category) t,
                  ],
                  rowFor: _trailRow,
                ),
          ],
      ];
    } else {
      rows = [
        for (final journey in TrailJourney.forShelf(shelf))
          for (final t in trails)
            if (t.journey == journey) _trailRow(t),
      ];
    }

    String shelfLabel(TrailShelf s) => s.isExtra
        ? s.label
        : switch (s.name) {
            'biblia' => context.l10n.trailsShelfBible,
            'tematicos' => context.l10n.trailsHubThemes,
            'vidaCrista' => TrailRealm.vidaCrista.label,
            _ => context.l10n.trailsHubStudy,
          };

    Widget chip(String label, Object? value) => Padding(
      padding: const EdgeInsets.only(right: AppSpace.sm),
      child: AppSelectChip(
        label: label,
        selected: value == _seasonShelf
            ? _seasonTab
            : !_seasonTab && shelf == value,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        onTap: () {
          ActHaptics.tap();
          setState(() {
            _shelfPicked = true;
            _seasonTab = value == _seasonShelf;
            if (value is TrailShelf?) _shelf = value;
          });
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.groupPickerIntro,
          style: AppTypography.body(size: 13, color: a.textSecondary),
        ),
        const SizedBox(height: AppSpace.md),
        TextField(
          controller: _search,
          textInputAction: TextInputAction.search,
          style: AppTypography.body(size: 14, color: a.text),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            isDense: true,
            hintText: context.l10n.groupPickerSearchHint,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CinematicIcon(
                glyph: CinematicGlyph.search,
                size: AppMetrics.iconSm,
                accent: a.textFaint,
                framed: false,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            suffixIcon: searching
                ? IconButton(
                    tooltip: context.l10n.commonClose,
                    onPressed: () => setState(_search.clear),
                    icon: CinematicIcon(
                      glyph: CinematicGlyph.close,
                      size: AppMetrics.iconSm,
                      accent: a.textFaint,
                      framed: false,
                    ),
                  )
                : null,
          ),
        ),
        if (!searching) ...[
          const SizedBox(height: AppSpace.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (mine.isNotEmpty)
                  chip(context.l10n.groupPickerTabMine, null),
                if (_season != null)
                  chip(context.l10n.walkTogetherKicker, _seasonShelf),
                for (final s in shelves) chip(shelfLabel(s), s),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpace.xs),
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(top: AppSpace.md),
            children: rows,
          ),
        ),
      ],
    );
  }

  Widget _missionList(Trail trail, AppearanceStyle a) {
    return ListView(
      children: [
        for (final mod in trail.modules)
          if (mod.missions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpace.md,
                bottom: AppSpace.sm,
              ),
              child: SectionLabel(mod.localizedTitle),
            ),
            for (final m in mod.missions)
              _PickRow(
                leading: _SceneNumber(
                  n: trail.missionSlugs.indexOf(m.slug) + 1,
                  accent: TrailVisuals.forTrail(trail).accent,
                ),
                title: m.localizedTitle,
                subtitle: m.hookRef ?? m.subtitle,
                onTap: () => _pickMission(m),
              ),
          ],
      ],
    );
  }

  Widget _noteStep(AppearanceStyle a) {
    final m = _mission!;
    final stage = _stage;
    return ListView(
      children: [
        SectionLabel(context.l10n.groupPickerPreviewLabel),
        const SizedBox(height: AppSpace.sm),
        InsetPanel(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                m.localizedTitle,
                style: AppTypography.display(size: 20, color: a.text),
              ),
              const SizedBox(height: AppSpace.md),
              AnimatedSwitcher(
                duration: AppMotion.gentle,
                child: stage == null
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        height: 48,
                        child: Center(child: AppSpinner(inline: true)),
                      )
                    : stage.verse != null
                    ? _VerseStage(
                        key: const ValueKey('verse'),
                        text: stage.verse!,
                        reference: stage.ref,
                      )
                    : Text(
                        stage.ref ?? m.subtitle,
                        key: const ValueKey('ref'),
                        style: AppTypography.body(
                          size: 13,
                          color: a.textSecondary,
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        SectionLabel(context.l10n.groupPickerNoteLabel),
        const SizedBox(height: AppSpace.sm),
        TextField(
          controller: _note,
          maxLength: 160,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          style: AppTypography.body(size: 14, color: a.text),
          decoration: InputDecoration(
            hintText: context.l10n.groupPickerNoteHint,
            errorText: _noteError,
          ),
          onChanged: (_) {
            if (_noteError != null) setState(() => _noteError = null);
          },
        ),
        const SizedBox(height: AppSpace.md),
        CopperCta(
          label: context.l10n.groupPickerConfirmCta,
          onTap: stage == null ? null : _confirm,
          busy: stage == null,
          leading: CinematicGlyph.check,
          trailing: null,
        ),
      ],
    );
  }
}

/// Item padrão do seletor: card com selo (40), título, linha de apoio e
/// seta. Trilha, grupo da Bíblia e cena usam o mesmo formato.
class _PickRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  /// Seta à direita; null = chevron padrão.
  final Widget? trailing;

  /// Contorno de destaque (grupo aberto).
  final Color? highlight;
  final bool? expanded;

  const _PickRow({
    required this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
    this.highlight,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final radius = BorderRadius.circular(AppRadii.md);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Semantics(
        button: true,
        expanded: expanded,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ActHaptics.tap();
              onTap();
            },
            borderRadius: radius,
            child: Ink(
              decoration: BoxDecoration(
                color: a.insetFill,
                borderRadius: radius,
                border: Border.all(
                  color: highlight?.withValues(alpha: 0.5) ?? a.insetBorder,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              child: Row(
                children: [
                  SizedBox(width: 40, height: 40, child: leading),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title(size: 14, color: a.text),
                        ),
                        if (subtitle != null && subtitle!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(
                                size: 12,
                                color: a.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  trailing ?? ListChevron(color: a.textFaint),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Grupo recolhível do seletor (categoria da Bíblia): o mesmo card das
/// trilhas, com "N trilhas · títulos"; abre as trilhas por baixo, recuadas.
class _PickGroup extends StatelessWidget {
  final String title;
  final TrailVisuals visuals;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Trail> trails;
  final Widget Function(Trail) rowFor;

  const _PickGroup({
    required this.title,
    required this.visuals,
    required this.expanded,
    required this.onToggle,
    required this.trails,
    required this.rowFor,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final still = MediaQuery.disableAnimationsOf(context);
    final duration = still ? Duration.zero : const Duration(milliseconds: 220);
    final count = context.l10n.trailsRealmTrailCount(trails.length);
    final names = [
      for (final t in trails)
        if (t.localizedTitle.toLowerCase() != title.toLowerCase())
          t.localizedTitle,
    ];
    final subtitle = names.isEmpty ? count : '$count · ${names.join(' · ')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PickRow(
          leading: _TrailDisc(visuals: visuals),
          title: title,
          subtitle: subtitle,
          onTap: onToggle,
          expanded: expanded,
          highlight: expanded ? visuals.accent : null,
          trailing: AnimatedRotation(
            turns: expanded ? 0.25 : 0,
            duration: duration,
            curve: AppMotion.enter,
            child: ListChevron(color: a.textFaint),
          ),
        ),
        AnimatedSize(
          duration: duration,
          curve: AppMotion.enter,
          alignment: Alignment.topCenter,
          child: expanded
              ? Container(
                  margin: const EdgeInsets.only(left: 31, bottom: AppSpace.xs),
                  padding: const EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: visuals.accent.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [for (final t in trails) rowFor(t)],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Selo da trilha — o mesmo glifo e gradiente do mapa de trilhas.
/// Cadeado do Peregrino+ no fim da linha do seletor.
class _PlusLock extends StatelessWidget {
  const _PlusLock();

  @override
  Widget build(BuildContext context) => CinematicIcon(
    glyph: CinematicGlyph.lock,
    size: AppMetrics.iconSm,
    accent: Appearance.of(context).textFaint,
    framed: false,
  );
}

class _TrailDisc extends StatelessWidget {
  final TrailVisuals visuals;

  const _TrailDisc({required this.visuals});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: visuals.iconGradient,
        boxShadow: [
          BoxShadow(
            color: visuals.glow.withValues(alpha: 0.35),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: CinematicIcon(
          glyph: visuals.glyph,
          size: AppMetrics.iconMd,
          accent: AppColors.inkOnAccent,
          framed: false,
        ),
      ),
    );
  }
}

/// Número da cena na trilha.
class _SceneNumber extends StatelessWidget {
  final int n;
  final Color accent;

  const _SceneNumber({required this.n, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.12),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Center(
        child: Text('$n', style: AppTypography.title(size: 14, color: accent)),
      ),
    );
  }
}

// ───────────────────────── Menu do grupo ─────────────────────────

/// Menu do card: só o que o líder conduz. Copiar, sair e encerrar ficam
/// no fim da página.
enum RoomMenuAction {
  pickStudy,
  edit,
  goal,
  clearStudy,
  transfer,
  plan,
  endPlan,
  answersPrivacy,
  leave,
  close,
}

/// Propósito do grupo visto pelo menu: nenhum, em curso/próximo, terminado.
enum RoomMenuPlan { none, live, ended }

Future<RoomMenuAction?> showRoomMenu(
  BuildContext context, {
  required StudyRoom room,
  required bool hasStudy,
  required bool canTransfer,
  RoomMenuPlan plan = RoomMenuPlan.none,
  bool isLeader = true,
}) {
  // Grupo se formando (menos de 3): sem propósito, semana nem meta.
  final formed = context.read<RoomService>().isFormed;
  return showAppSheet<RoomMenuAction>(
    context,
    builder: (ctx) {
      Widget item(
        RoomMenuAction action,
        String label,
        CinematicGlyph glyph, {
        bool danger = false,
      }) {
        final a = Appearance.of(ctx);
        final ink = danger ? AppRoles.risk : a.text;
        return InkWell(
          onTap: () => Navigator.pop(ctx, action),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                CinematicIcon(
                  glyph: glyph,
                  size: AppMetrics.leadingIcon,
                  accent: danger ? AppRoles.risk : a.place,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.title(size: 14, color: ink),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return AppSheetPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(title: room.name),
            if (isLeader) ...[
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.md, bottom: 2),
                child: SectionLabel(ctx.l10n.groupMenuLeadSection),
              ),
              if (formed)
                item(
                  RoomMenuAction.plan,
                  plan == RoomMenuPlan.live
                      ? ctx.l10n.planMenuEdit
                      : ctx.l10n.planMenuCreate,
                  CinematicGlyph.calendar,
                ),
              item(
                RoomMenuAction.edit,
                ctx.l10n.groupMenuEdit,
                CinematicGlyph.pencil,
              ),
              if (formed)
                item(
                  RoomMenuAction.goal,
                  room.weeklyGoalSteps != null
                      ? ctx.l10n.groupMenuGoal(room.weeklyGoalSteps!)
                      : ctx.l10n.groupMenuSetGoal,
                  CinematicGlyph.target,
                ),
              // Liga/desliga: membros veem as respostas uns dos outros.
              if (formed && plan == RoomMenuPlan.live)
                item(
                  RoomMenuAction.answersPrivacy,
                  room.answersPrivate
                      ? ctx.l10n.planMenuAnswersOpen
                      : ctx.l10n.planMenuAnswersPrivate,
                  room.answersPrivate
                      ? CinematicGlyph.people
                      : CinematicGlyph.lock,
                ),
              if (formed && plan == RoomMenuPlan.live)
                item(
                  RoomMenuAction.endPlan,
                  ctx.l10n.planMenuEnd,
                  CinematicGlyph.stop,
                ),
              if (formed && hasStudy && plan == RoomMenuPlan.none)
                item(
                  RoomMenuAction.clearStudy,
                  ctx.l10n.groupMenuClearStudy,
                  CinematicGlyph.close,
                ),
              if (canTransfer)
                item(
                  RoomMenuAction.transfer,
                  ctx.l10n.groupMenuTransfer,
                  CinematicGlyph.crown,
                ),
            ],
            // Sair e encerrar moram aqui, não no fim da página.
            const SizedBox(height: AppSpace.md),
            item(
              RoomMenuAction.leave,
              ctx.l10n.groupMenuLeave,
              CinematicGlyph.door,
              danger: true,
            ),
            if (isLeader)
              item(
                RoomMenuAction.close,
                ctx.l10n.groupMenuClose,
                CinematicGlyph.stop,
                danger: true,
              ),
          ],
        ),
      );
    },
  );
}

/// Escolhe quem assume o grupo.
Future<RoomMember?> showRoomMemberPicker(
  BuildContext context, {
  required String title,
  required String body,
  required List<RoomMember> members,
}) {
  return showAppSheet<RoomMember>(
    context,
    builder: (ctx) {
      final a = Appearance.of(ctx);
      final others = [
        for (final m in members)
          if (!m.isUser) m,
      ];
      return AppSheetPanel(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSheetHeader(title: title, subtitle: body),
              const SizedBox(height: AppSpace.md),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final m in others)
                      InkWell(
                        onTap: () => Navigator.pop(ctx, m),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              UserAvatar(
                                name: m.name,
                                photoUrl: m.photoUrl,
                                seed: m.uid,
                                radius: AppMetrics.avatarMd,
                                style: m.portraitStyle,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  m.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.title(
                                    size: 14,
                                    color: a.text,
                                  ),
                                ),
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
      );
    },
  );
}

String _firstName(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  return parts.isEmpty || parts.first.isEmpty ? name : parts.first;
}

/// Convite que chegou: a pessoa entra no grupo ou recusa, no próprio app.
class RoomIncomingInviteCard extends StatelessWidget {
  final RoomInvite invite;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const RoomIncomingInviteCard({
    super.key,
    required this.invite,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final from = _firstName(invite.fromName);
    return GlassCard(
      glow: 0.7,
      tint: a.place,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(label: context.l10n.groupInviteLabel),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              UserAvatar(
                name: invite.fromName,
                photoUrl: invite.fromPhotoUrl,
                seed: invite.fromUid,
                radius: AppMetrics.avatarMd,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.roomName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.groupInviteBody(from, invite.kind.label),
                      style: AppTypography.body(
                        size: 13,
                        height: 1.3,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              UserModerationButton(
                uid: invite.fromUid,
                name: invite.fromName,
                source: UserReportSource.roomInvite,
                roomCode: invite.roomCode,
                roomName: invite.roomName,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          CopperCta(
            label: context.l10n.groupInviteAccept,
            leading: CinematicGlyph.check,
            trailing: null,
            dense: true,
            onTap: onAccept,
          ),
          const SizedBox(height: AppSpace.xs),
          Center(
            child: TextCta(label: context.l10n.commonNotNow, onTap: onDecline),
          ),
        ],
      ),
    );
  }
}

/// Abre ao tocar em Chamar pessoas: escolhe quem da caravana ou manda o link.
Future<void> showRoomCallSheet(
  BuildContext context, {
  required List<LeagueEntry> people,
  required Future<bool> Function(LeagueEntry person) onInvite,
  required Future<bool> Function(LeagueEntry person) onCancel,
  required VoidCallback onShareLink,
}) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => _RoomCallSheet(
      people: people,
      onInvite: onInvite,
      onCancel: onCancel,
      onShareLink: () {
        Navigator.pop(ctx);
        onShareLink();
      },
    ),
  );
}

class _RoomCallSheet extends StatefulWidget {
  final List<LeagueEntry> people;
  final Future<bool> Function(LeagueEntry person) onInvite;
  final Future<bool> Function(LeagueEntry person) onCancel;
  final VoidCallback onShareLink;

  const _RoomCallSheet({
    required this.people,
    required this.onInvite,
    required this.onCancel,
    required this.onShareLink,
  });

  @override
  State<_RoomCallSheet> createState() => _RoomCallSheetState();
}

class _RoomCallSheetState extends State<_RoomCallSheet> {
  final Set<String> _busy = {};
  final Set<String> _invited = {};
  String? _error;

  Future<void> _invite(LeagueEntry person) async {
    final uid = person.uid;
    if (uid == null || _busy.contains(uid) || _isInvited(uid)) return;
    setState(() {
      _busy.add(uid);
      _error = null;
    });
    try {
      final ok = await widget.onInvite(person);
      if (!mounted) return;
      if (ok) {
        setState(() => _invited.add(uid));
      } else {
        setState(() {
          _error =
              context.read<RoomService>().lastError ??
              context.l10n.groupInviteSendFailed;
        });
      }
    } finally {
      if (mounted) setState(() => _busy.remove(uid));
    }
  }

  Future<void> _cancel(LeagueEntry person) async {
    final uid = person.uid;
    if (uid == null || _busy.contains(uid)) return;
    setState(() {
      _busy.add(uid);
      _error = null;
    });
    try {
      final ok = await widget.onCancel(person);
      if (!mounted) return;
      if (ok) {
        setState(() => _invited.remove(uid));
      } else {
        setState(() => _error = context.l10n.groupInviteUndoFailed);
      }
    } finally {
      if (mounted) setState(() => _busy.remove(uid));
    }
  }

  bool _isInvited(String? uid) {
    if (uid == null) return false;
    if (_invited.contains(uid)) return true;
    return context.read<RoomService>().pendingTargets.contains(uid);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final rooms = context.watch<RoomService>();
    final memberIds = {for (final member in rooms.members) member.uid};
    final people = [
      for (final person in widget.people)
        if (!memberIds.contains(person.uid)) person,
    ];
    final pending = {...rooms.pendingTargets, ..._invited};
    final full = rooms.isFull;
    final maxH = MediaQuery.sizeOf(context).height * 0.72;

    return AppSheetPanel(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              title: context.l10n.groupCallTitle,
              subtitle: context.l10n.groupCallSubtitle,
            ),
            const SizedBox(height: AppSpace.md),
            if (people.isEmpty)
              EmptyState(title: context.l10n.groupCallEmpty)
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    for (final person in people)
                      CaravanInviteRow(
                        person: person,
                        pending: pending.contains(person.uid),
                        busy: _busy.contains(person.uid),
                        enabled: !full,
                        onInvite: () => _invite(person),
                        onCancel: () => _cancel(person),
                      ),
                  ],
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: AppSpace.sm),
              GlassCard(
                padding: AppMetrics.cardPaddingCompact,
                child: Row(
                  children: [
                    const CloudMascot(face: CloudFace.erro, size: 28),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: AppTypography.body(size: 12, color: a.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (full) ...[
              const SizedBox(height: AppSpace.sm),
              Text(
                context.l10n.groupCallFull(kRoomMemberLimit),
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppRoles.risk,
                ),
              ),
            ],
            const SizedBox(height: AppSpace.md),
            // Abre a folha do convite: QR code, código para copiar e link.
            CopperCta(
              label: context.l10n.groupCallShareCta,
              leading: CinematicGlyph.qr,
              trailing: null,
              dense: true,
              onTap: full ? null : widget.onShareLink,
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma pessoa da Caravana com "Chamar" (ou "Convite enviado · Desfazer").
/// Grupos e Companhia.
class CaravanInviteRow extends StatelessWidget {
  final LeagueEntry person;
  final bool pending;
  final bool busy;
  final bool enabled;
  final VoidCallback onInvite;
  final VoidCallback onCancel;

  const CaravanInviteRow({
    super.key,
    required this.person,
    required this.pending,
    required this.busy,
    required this.enabled,
    required this.onInvite,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          UserAvatar(
            name: person.name,
            photoUrl: person.photoUrl,
            seed: person.uid ?? person.name,
            radius: AppMetrics.avatarMd,
            style: person.portraitStyle,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              person.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(size: 14, color: a.text),
            ),
          ),
          if (pending) ...[
            Text(
              busy ? '…' : context.l10n.groupInviteSent,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w800,
                color: AppRoles.success,
              ),
            ),
            const SizedBox(width: 4),
            TextCta(
              label: context.l10n.groupInviteUndo,
              onTap: busy ? null : onCancel,
            ),
          ] else
            TextCta(
              label: busy
                  ? context.l10n.groupInviteSending
                  : context.l10n.groupInviteCta,
              color: AppRoles.action,
              onTap: !enabled || busy ? null : onInvite,
            ),
        ],
      ),
    );
  }
}
