import 'package:flutter/material.dart';

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

/// Barra do grupo: uma parte por pessoa, cheia quando ela estudou.
class RoomWeekBar extends StatelessWidget {
  final List<RoomMember> members;

  const RoomWeekBar({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    if (members.isEmpty) return const SizedBox.shrink();
    final ordered = [
      ...members.where((m) => m.walkedToday()),
      ...members.where((m) => !m.walkedToday() && m.walkedThisWeek),
      ...members.where((m) => !m.walkedThisWeek),
    ];
    return SizedBox(
      height: 8,
      child: Row(
        children: [
          for (var i = 0; i < ordered.length; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  color: switch (seatStateOf(ordered[i])) {
                    SeatState.today => AppRoles.presence,
                    SeatState.week => AppRoles.presence.withValues(alpha: 0.5),
                    _ => a.progressTrack,
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Quem está no grupo, uma linha por pessoa: rosto, nome e a barra da
/// semana, que enche a cada dia de estudo.
class RoomRoster extends StatelessWidget {
  final List<RoomMember> members;
  final String? myPhotoUrl;
  final PortraitStyle myStyle;
  final String? leaderId;
  final ValueChanged<RoomMember>? onTap;

  const RoomRoster({
    super.key,
    required this.members,
    this.myPhotoUrl,
    this.myStyle = PortraitStyle.photo,
    this.leaderId,
    this.onTap,
  });

  /// Quem mais caminhou na semana primeiro; empate, quem estudou hoje.
  static List<RoomMember> ordered(List<RoomMember> members) {
    final list = [...members];
    list.sort((a, b) {
      final d = b.daysThisWeek.compareTo(a.daysThisWeek);
      if (d != 0) return d;
      final t = (b.walkedToday() ? 1 : 0).compareTo(a.walkedToday() ? 1 : 0);
      if (t != 0) return t;
      final s = b.steps.compareTo(a.steps);
      if (s != 0) return s;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final rows = ordered(members);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++)
          _RosterRow(
            member: rows[i],
            index: i,
            isLeader: rows[i].uid == leaderId,
            photoUrl: rows[i].isUser
                ? (myPhotoUrl ?? rows[i].photoUrl)
                : rows[i].photoUrl,
            style: rows[i].isUser ? myStyle : rows[i].portraitStyle,
            onTap: onTap == null ? null : () => onTap!(rows[i]),
          ),
      ],
    );
  }
}

class _RosterRow extends StatelessWidget {
  final RoomMember member;
  final int index;
  final bool isLeader;
  final String? photoUrl;
  final PortraitStyle style;
  final VoidCallback? onTap;

  const _RosterRow({
    required this.member,
    required this.index,
    required this.isLeader,
    required this.photoUrl,
    required this.style,
    this.onTap,
  });

  static const double _face = AppMetrics.avatarMd * 2;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final state = seatStateOf(member);
    final days = member.daysThisWeek;
    final quiet = state == SeatState.quiet;
    final idle = member.daysSinceWalk();
    final l10n = context.l10n;
    final name = member.isUser ? l10n.commonYou : member.name;

    final caption = switch (state) {
      SeatState.today => l10n.groupCaptionToday,
      SeatState.week => null,
      SeatState.quiet =>
        idle == null ? l10n.groupCaptionNotYet : l10n.groupDaysAway(idle),
      SeatState.idle => null,
    };

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

    return Semantics(
      button: onTap != null,
      label: l10n.groupRosterSemantics(name, days),
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                ActHaptics.tap();
                onTap!();
              },
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: member.isUser
              ? BoxDecoration(
                  color: AppRoles.selected.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color: AppRoles.selected.withValues(alpha: 0.4),
                  ),
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
                    // Coroa = dono do grupo (papel, não prêmio): chrome.
                    if (isLeader)
                      const Positioned(
                        right: -2,
                        bottom: -2,
                        child: _Badge(
                          color: AppColors.nightElevated,
                          ink: AppRoles.chrome,
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
                              size: 14,
                              color: quiet ? a.textSecondary : a.text,
                            ),
                          ),
                        ),
                        if (caption != null) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '· $caption',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(
                                size: 11,
                                weight: FontWeight.w700,
                                color: state == SeatState.today
                                    ? AppRoles.presence
                                    : a.textFaint,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 7),
                    _WeekTrack(
                      days: days,
                      today: state == SeatState.today,
                      delay: index,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 44,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$days',
                      style: AppTypography.display(
                        size: 20,
                        height: 1,
                        color: days > 0 ? a.text : a.textFaint,
                      ),
                    ),
                    Text(
                      l10n.groupDayUnit(days).trim(),
                      style: AppTypography.label(
                        size: 10,
                        letterSpacing: 0.4,
                        color: a.textFaint,
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

/// Trilho de 7 dias. Enche da esquerda para a direita conforme os dias de
/// estudo da semana; a ponta brilha quando a pessoa estudou hoje.
class _WeekTrack extends StatelessWidget {
  final int days;
  final bool today;
  final int delay;

  const _WeekTrack({
    required this.days,
    required this.today,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final target = (days / 7).clamp(0.0, 1.0);
    final reduce = MediaQuery.of(context).disableAnimations;
    return SizedBox(
      height: 10,
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target),
        duration: reduce
            ? Duration.zero
            : Duration(milliseconds: 700 + 90 * delay.clamp(0, 8)),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => CustomPaint(
          painter: _TrackPainter(
            value: v,
            track: a.progressTrack,
            tick: a.cardBorder,
            glow: today && v >= target - 0.001 && target > 0,
          ),
        ),
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  final double value;
  final Color track;
  final Color tick;
  final bool glow;

  const _TrackPainter({
    required this.value,
    required this.track,
    required this.tick,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final h = 6.0;
    final top = (size.height - h) / 2;
    final r = Radius.circular(h / 2);
    final full = RRect.fromLTRBR(0, top, size.width, top + h, r);
    canvas.drawRRect(full, Paint()..color = track);

    if (value > 0) {
      final w = size.width * value;
      final fill = RRect.fromLTRBR(0, top, w, top + h, r);
      canvas.drawRRect(
        fill,
        Paint()
          ..shader = LinearGradient(
            colors: [
              AppRoles.presence.withValues(alpha: 0.6),
              AppRoles.presence,
            ],
          ).createShader(Rect.fromLTWH(0, top, w, h)),
      );
      if (glow) {
        canvas.drawCircle(
          Offset(w - h / 2, size.height / 2),
          4.5,
          Paint()
            ..color = AppRoles.presence.withValues(alpha: 0.55)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    // Marcas dos 7 dias.
    final p = Paint()
      ..color = tick
      ..strokeWidth = 1.2;
    for (var i = 1; i < 7; i++) {
      final x = size.width * i / 7;
      canvas.drawLine(Offset(x, top + 1), Offset(x, top + h - 1), p);
    }
  }

  @override
  bool shouldRepaint(covariant _TrackPainter old) =>
      old.value != value ||
      old.glow != glow ||
      old.track != track ||
      old.tick != tick;
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
        border: Border.all(color: AppColors.night, width: 1.6),
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
