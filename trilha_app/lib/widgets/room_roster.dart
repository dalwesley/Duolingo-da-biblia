import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_language.dart';
import '../l10n/l10n_global.dart';
import '../models/study_room.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'ui_primitives.dart';
import 'cinematic_icon.dart';
import 'hero_card_atmosphere.dart';
import 'user_avatar.dart';

/// Como cada pessoa está na semana do grupo.
enum SeatState { today, week, quiet, idle }

SeatState seatStateOf(RoomMember m) {
  if (m.walkedToday()) return SeatState.today;
  if (m.walkedThisWeek) return SeatState.week;
  final days = m.daysSinceWalk();
  if (days == null || days >= 3) return SeatState.quiet;
  return SeatState.idle;
}

String seatLabel(RoomMember m) {
  final l10n = L10n.current;
  return switch (seatStateOf(m)) {
    SeatState.today => l10n.groupSeatToday,
    SeatState.week => l10n.groupSeatWeek,
    SeatState.quiet =>
      m.daysSinceWalk() == null
          ? l10n.groupSeatNever
          : l10n.groupDaysAway(m.daysSinceWalk()!),
    SeatState.idle => l10n.groupSeatIdle,
  };
}

/// Lista de quem está no grupo: uma linha por pessoa (rosto, status e as
/// bolinhas da semana) e, no fim, o convite. Sem card próprio — mora no card
/// do grupo, sob [RoomWeekLetters].
///
/// A ordem vem pronta de quem chama e não muda com o placar: ninguém troca
/// de lugar ao longo da semana.
class RoomMembersList extends StatelessWidget {
  final List<RoomMember> members;
  final String? myPhotoUrl;
  final PortraitStyle myStyle;
  final String? leaderId;
  final String leaderTitle;
  final RoomStudy? study;
  final ValueChanged<RoomMember>? onTap;

  /// `null` quando o grupo está cheio.
  final VoidCallback? onInvite;

  const RoomMembersList({
    super.key,
    required this.members,
    this.myPhotoUrl,
    this.myStyle = PortraitStyle.photo,
    this.leaderId,
    required this.leaderTitle,
    this.study,
    this.onTap,
    this.onInvite,
  });

  /// Recuo horizontal de cada linha — alinhe [RoomWeekLetters] com ele.
  static const double inset = 8;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dias da semana uma vez só, sobre a coluna das bolinhas.
        if (members.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(right: inset, bottom: 2),
            child: Align(
              alignment: Alignment.centerRight,
              child: RoomWeekLetters(),
            ),
          ),
        for (var i = 0; i < members.length; i++)
          _MemberRow(
            member: members[i],
            index: i,
            isLeader: members[i].uid == leaderId,
            leaderTitle: leaderTitle,
            study: study,
            photoUrl: members[i].isUser
                ? (myPhotoUrl ?? members[i].photoUrl)
                : members[i].photoUrl,
            style: members[i].isUser ? myStyle : members[i].portraitStyle,
            onTap: onTap == null ? null : () => onTap!(members[i]),
          ),
        const SizedBox(height: AppSpace.xs),
        if (onInvite != null)
          _InviteRow(onTap: onInvite!)
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(inset, AppSpace.sm, inset, 0),
            child: Text(
              l10n.juntosRoomFull,
              style: AppTypography.body(
                size: 12,
                height: 1.3,
                weight: FontWeight.w700,
                color: a.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Largura de cada dia na coluna da semana (cabeçalho e bolinhas).
const double _kDaySlot = 11;
const double _kDayGap = 2;
const double _kWeekWidth = _kDaySlot * 7 + _kDayGap * 6;

/// S T Q Q S S D sobre as bolinhas de cada pessoa; hoje em destaque.
class RoomWeekLetters extends StatelessWidget {
  const RoomWeekLetters({super.key});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final today = DateTime.now().weekday;
    final narrow = DateFormat(
      'EEEEE',
      Localizations.localeOf(context).toLanguageTag(),
    );
    // 1 de janeiro de 2024 foi segunda: dia d da semana = 2024-01-d.
    String label(int d) => narrow.format(DateTime(2024, 1, d)).toUpperCase();
    return ExcludeSemantics(
      child: SizedBox(
        width: _kWeekWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var d = 1; d <= 7; d++)
              SizedBox(
                width: _kDaySlot,
                child: Text(
                  label(d),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: AppTypography.label(
                    size: 9,
                    letterSpacing: 0,
                    color: d == today ? a.text : a.textFaint,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final RoomMember member;
  final int index;
  final bool isLeader;
  final String leaderTitle;
  final RoomStudy? study;
  final String? photoUrl;
  final PortraitStyle style;
  final VoidCallback? onTap;

  const _MemberRow({
    required this.member,
    required this.index,
    required this.isLeader,
    required this.leaderTitle,
    required this.study,
    required this.photoUrl,
    required this.style,
    this.onTap,
  });

  static const double _face = AppMetrics.avatarMd * 2;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final state = seatStateOf(member);
    final quiet = state == SeatState.quiet;
    final name = member.isUser ? l10n.commonYou : member.name;
    final raw = seatLabel(member);
    final status = raw.isEmpty ? raw : raw[0].toUpperCase() + raw.substring(1);
    final didStudy = member.didStudy(study);

    // Anel de presença: teal quando estudou hoje.
    Widget face = UserAvatar(
      name: member.name,
      photoUrl: photoUrl,
      seed: member.uid,
      radius: AppMetrics.avatarMd,
      style: style,
      borderColor: state == SeatState.today ? AppRoles.presence : a.cardBorder,
    );
    if (quiet) {
      face = Opacity(
        opacity: 0.7,
        child: HeroCardColorGrade(mood: HeroCardMood.dusty, child: face),
      );
    }

    final semantics = [
      l10n.groupRosterSemantics(name, member.daysThisWeek),
      if (isLeader) leaderTitle,
      status,
      if (didStudy) l10n.groupMemberDidStudy,
    ].join('. ');

    return Semantics(
      button: onTap != null,
      label: semantics,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                ActHaptics.tap();
                onTap!();
              },
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: member.isUser
              ? BoxDecoration(
                  color: a.selected.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                )
              : null,
          child: Row(
            children: [
              SizedBox(
                width: _face + 4,
                height: _face + 4,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(child: face),
                    // Coroa = quem conduz o grupo (papel, não prêmio): chrome.
                    if (isLeader)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: _Badge(
                          color: a.cardFill,
                          ink: a.place,
                          glyph: CinematicGlyph.crown,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title(
                              size: 15,
                              color: quiet ? a.textSecondary : a.text,
                            ),
                          ),
                        ),
                        if (isLeader) ...[
                          const SizedBox(width: 6),
                          // Teto: nome longo não some atrás do papel.
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 84),
                            child: Text(
                              leaderTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label(
                                size: 9,
                                letterSpacing: 0.4,
                                color: a.place,
                              ),
                            ),
                          ),
                        ],
                        // Selos "Fiel na semana" ganhos neste grupo.
                        if (member.sealWeeks.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Tooltip(
                            message: l10n.roomSealCount(
                              member.sealWeeks.length,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CinematicIcon(
                                  glyph: CinematicGlyph.shield,
                                  size: 12,
                                  accent: AppRoles.reward,
                                  framed: false,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${member.sealWeeks.length}',
                                  style: AppTypography.label(
                                    size: 11,
                                    color: AppRoles.reward,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (didStudy) ...[
                          const CinematicIcon(
                            glyph: CinematicGlyph.book,
                            size: 12,
                            accent: AppRoles.presence,
                            framed: false,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            // O estudo do grupo vale mais que caminhar hoje:
                            // são coisas diferentes e o grupo quer ver este.
                            didStudy ? l10n.groupMemberDidStudy : status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(
                              size: 12,
                              weight: FontWeight.w700,
                              color: state == SeatState.today || didStudy
                                  ? AppRoles.presence
                                  : quiet
                                  ? a.textFaint
                                  : a.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _WeekDots(member: member, delay: index),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sete bolinhas (seg → dom): cheia = estudou nesse dia; hoje com contorno;
/// dias que ainda vêm ficam só no traço.
class _WeekDots extends StatelessWidget {
  final RoomMember member;
  final int delay;

  const _WeekDots({required this.member, required this.delay});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final today = DateTime.now().weekday;
    final days = {
      ...member.weekDays,
      // Dado antigo sem os dias: ao menos o de hoje aparece.
      if (member.weekDays.isEmpty && member.walkedToday()) today,
    };
    final still = MediaQuery.disableAnimationsOf(context);
    final dots = SizedBox(
      width: _kWeekWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var d = 1; d <= 7; d++)
            SizedBox(
              width: _kDaySlot,
              height: _kDaySlot,
              child: Center(
                child: AnimatedContainer(
                  duration: still
                      ? Duration.zero
                      : Duration(milliseconds: 300 + 40 * delay.clamp(0, 8)),
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: days.contains(d)
                        ? AppRoles.presence
                        : d > today
                        ? Colors.transparent
                        : a.progressTrack,
                    border: d == today && !days.contains(d)
                        ? Border.all(color: a.selected, width: 1.5)
                        : d > today
                        ? Border.all(color: a.cardBorder)
                        : null,
                    boxShadow: d == today && days.contains(d)
                        ? [
                            BoxShadow(
                              color: AppRoles.presence.withValues(alpha: 0.55),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return dots;
  }
}

/// Última linha da lista: o lugar vazio que chama mais gente.
class _InviteRow extends StatelessWidget {
  final VoidCallback onTap;

  const _InviteRow({required this.onTap});

  static const double _face = AppMetrics.avatarMd * 2;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.groupCallTitle,
      excludeSemantics: true,
      child: InkWell(
        onTap: () {
          ActHaptics.tap();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          child: Row(
            children: [
              SizedBox(
                width: _face + 4,
                height: _face + 4,
                child: Center(
                  child: Container(
                    width: _face,
                    height: _face,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: a.cardFillSoft,
                      border: Border.all(color: a.cardBorder),
                    ),
                    child: Center(
                      child: CinematicIcon(
                        glyph: CinematicGlyph.plus,
                        size: AppMetrics.iconSm,
                        accent: a.place,
                        framed: false,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.groupCallTitle,
                      style: AppTypography.title(size: 15, color: a.text),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.groupCallSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 12,
                        height: 1.3,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              ListChevron(color: a.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final Color color;
  final Color ink;
  final CinematicGlyph glyph;

  const _Badge({required this.color, required this.ink, required this.glyph});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Appearance.of(context).cardFill, width: 1.6),
      ),
      child: Center(
        child: CinematicIcon(
          glyph: glyph,
          size: 10,
          accent: ink,
          framed: false,
        ),
      ),
    );
  }
}
