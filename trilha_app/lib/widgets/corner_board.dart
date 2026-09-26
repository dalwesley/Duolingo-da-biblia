import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/corner_challenge.dart';
import '../services/backend_service.dart';
import '../services/corner_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'corner_home_card.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Retângulo do desafio: eu de um lado, a outra pessoa do outro.
/// Na Caravana e na Home, a partir do primeiro.
class DesafioEntry extends StatelessWidget {
  final VoidCallback onTap;

  const DesafioEntry({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final backend = context.watch<BackendService>();
    final progress = context.watch<ProgressService>();
    final corners = context.watch<CornerService>();
    final uid = backend.uid ?? '';
    final challenge = corners.face;
    if (challenge == null || uid.isEmpty) return const SizedBox.shrink();

    final board = CornerScoreboard.of(corners.mine, uid);
    final live = corners.homeCard;
    final status = CornerCopy.stripLine(
      live: live,
      uid: uid,
      days: LeagueService.daysLeft(),
      won: board.won,
      lost: board.lost,
    );
    final them = challenge.peerName(uid);
    final portrait = progress.settings.portraitStyle;

    return Semantics(
      button: true,
      label: 'Desafio com ${CornerCopy.firstName(them)}',
      excludeSemantics: true,
      child: GlassCard(
        glow: live != null ? 0.7 : 0.35,
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: _Person(
                name: progress.userName,
                photo: backend.userPhotoUrl,
                seed: uid,
                style: portrait,
              ),
            ),
            SizedBox(
              width: 108,
              child: Column(
                children: [
                  const CinematicIcon(
                    glyph: CinematicGlyph.flag,
                    size: 18,
                    accent: AppColors.accent,
                    framed: false,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: a.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _Person(
                name: them,
                photo: challenge.peerPhoto(uid),
                seed: challenge.peerId(uid),
                style: portrait,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Person extends StatelessWidget {
  final String name;
  final String? photo;
  final String? seed;
  final PortraitStyle style;

  const _Person({
    required this.name,
    required this.photo,
    required this.seed,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final first = CornerCopy.firstName(name);
    return Column(
      children: [
        UserAvatar(
          name: name,
          photoUrl: photo,
          seed: seed,
          radius: 26,
          style: style,
          borderColor: AppColors.accent.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 6),
        Text(
          first.isEmpty ? '—' : first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.label(
            size: 12,
            letterSpacing: 0.2,
            color: a.text,
          ),
        ),
      ],
    );
  }
}

/// O que está valendo, o placar e cada desafio que já fechou.
class CornerBoard extends StatelessWidget {
  final ValueChanged<String> onOpenMission;
  final VoidCallback onOpenCaravana;

  const CornerBoard({
    super.key,
    required this.onOpenMission,
    required this.onOpenCaravana,
  });

  @override
  Widget build(BuildContext context) {
    final backend = context.watch<BackendService>();
    final corners = context.watch<CornerService>();
    final uid = backend.uid ?? '';

    if (!backend.isActive) {
      return const EmptyState(
        glyph: CinematicGlyph.flag,
        title: CornerCopy.boardEmptyTitle,
        body: CornerCopy.needsCloud,
      );
    }
    if (corners.loading && corners.mine.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: AppSpace.xxxl),
        child: AppSpinner(),
      );
    }

    final board = CornerScoreboard.of(corners.mine, uid);
    if (board.isEmpty) {
      return EmptyState(
        glyph: CinematicGlyph.flag,
        title: CornerCopy.boardEmptyTitle,
        body: CornerCopy.boardEmptyBody,
        action: TextCta(
          label: CornerCopy.boardOpenCaravan,
          onTap: onOpenCaravana,
        ),
      );
    }

    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (board.open.isEmpty) ...[
          Text(
            CornerCopy.boardIdle,
            style: AppTypography.body(size: 14, color: a.textSecondary),
          ),
          const SizedBox(height: AppSpace.xl),
        ] else
          for (var i = 0; i < board.open.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpace.md),
            CornerHomeCard(
              challenge: board.open[i],
              onWalk: () => onOpenMission(board.open[i].missionSlug),
            ),
          ],
        if (board.closed.isNotEmpty) ...[
          SizedBox(height: board.open.isEmpty ? 0 : AppSpace.xl),
          _Tally(won: board.won, together: board.together, lost: board.lost),
          const SizedBox(height: AppSpace.xl),
          const Align(
            alignment: Alignment.centerLeft,
            child: SectionLabel(CornerCopy.closedChapter),
          ),
          const SizedBox(height: AppSpace.sm),
          _ClosedList(results: board.closed, uid: uid),
        ],
      ],
    );
  }
}

class _Tally extends StatelessWidget {
  final int won;
  final int together;
  final int lost;

  const _Tally({required this.won, required this.together, required this.lost});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              _cell(a, CornerCopy.tallyWon, won, AppColors.accent),
              _cell(a, CornerCopy.tallyTogether, together, AppColors.teal),
              _cell(a, CornerCopy.tallyLost, lost, AppColors.clay),
            ],
          ),
          if (together > 0) ...[
            const SizedBox(height: AppSpace.md),
            Text(
              CornerCopy.tallyNote,
              textAlign: TextAlign.center,
              style: AppTypography.body(size: 12, color: a.textFaint),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cell(AppearanceStyle a, String label, int value, Color tone) {
    final ink = value == 0 ? a.textFaint : tone;
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTypography.display(
              size: 24,
              weight: FontWeight.w900,
              color: ink,
            ),
          ),
          const SizedBox(height: 4),
          SectionLabel(label, size: 11, color: ink),
        ],
      ),
    );
  }
}

class _ClosedList extends StatelessWidget {
  final List<CornerResult> results;
  final String uid;

  const _ClosedList({required this.results, required this.uid});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < results.length; i++) ...[
            if (i > 0) const ListDivider(indent: ListDivider.iconIndent),
            _ClosedRow(result: results[i], uid: uid),
          ],
        ],
      ),
    );
  }
}

class _ClosedRow extends StatelessWidget {
  final CornerResult result;
  final String uid;

  const _ClosedRow({required this.result, required this.uid});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tone = switch (result.mark) {
      CornerResultMark.won => AppColors.accent,
      CornerResultMark.together => AppColors.teal,
      CornerResultMark.lost => AppColors.clay,
      CornerResultMark.left => a.textFaint,
    };
    final glyph = switch (result.mark) {
      CornerResultMark.won => CinematicGlyph.check,
      CornerResultMark.together => CinematicGlyph.flag,
      CornerResultMark.lost => CinematicGlyph.wrong,
      CornerResultMark.left => CinematicGlyph.stop,
    };
    return Padding(
      padding: AppMetrics.cardPaddingCompact,
      child: Row(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: AppMetrics.leadingIcon,
            accent: tone,
            framed: true,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.challenge.missionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  result.caption(uid),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(size: 12, color: a.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          SoftBadge(text: result.badge, accent: tone),
        ],
      ),
    );
  }
}
