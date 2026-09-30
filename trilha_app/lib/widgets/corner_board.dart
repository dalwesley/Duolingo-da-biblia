import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
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
      label: context.l10n.cornerChallengeWith(CornerCopy.firstName(them)),
      excludeSemantics: true,
      child: GlassCard(
        glow: challenge.status == CornerStatus.active ? 0.7 : null,
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
                    size: AppMetrics.iconMd,
                    accent: AppRoles.chrome,
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
          radius: AppMetrics.avatarLg,
          style: style,
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
  /// Mantido na API; o CTA de abrir a caravana mora no pai.
  final VoidCallback onOpenCaravana;

  /// Ignorado: o vazio sempre aparece como [EmptyState].
  @Deprecated('Ignored — the empty state always renders.')
  final bool hideEmptyChrome;

  const CornerBoard({
    super.key,
    required this.onOpenMission,
    required this.onOpenCaravana,
    @Deprecated('Ignored — the empty state always renders.')
    this.hideEmptyChrome = false,
  });

  @override
  Widget build(BuildContext context) {
    final backend = context.watch<BackendService>();
    final corners = context.watch<CornerService>();
    final uid = backend.uid ?? '';

    if (!backend.isActive) {
      return EmptyState(
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
          _ClosedArchive(results: board.closed, uid: uid),
        ],
      ],
    );
  }
}

enum _ArchiveFilter { all, won, lost }

class _ClosedArchive extends StatefulWidget {
  final List<CornerResult> results;
  final String uid;

  const _ClosedArchive({required this.results, required this.uid});

  @override
  State<_ClosedArchive> createState() => _ClosedArchiveState();
}

class _ClosedArchiveState extends State<_ClosedArchive> {
  _ArchiveFilter? _filter;

  int get _wonCount => widget.results
      .where(
        (r) =>
            r.mark == CornerResultMark.won ||
            r.mark == CornerResultMark.together,
      )
      .length;

  int get _lostCount => widget.results
      .where(
        (r) =>
            r.mark == CornerResultMark.lost ||
            r.mark == CornerResultMark.left,
      )
      .length;

  List<CornerResult> get _visible {
    final f = _filter;
    if (f == null) return const [];
    return switch (f) {
      _ArchiveFilter.all => widget.results,
      _ArchiveFilter.won => [
        for (final r in widget.results)
          if (r.mark == CornerResultMark.won ||
              r.mark == CornerResultMark.together)
            r,
      ],
      _ArchiveFilter.lost => [
        for (final r in widget.results)
          if (r.mark == CornerResultMark.lost ||
              r.mark == CornerResultMark.left)
            r,
      ],
    };
  }

  void _tap(_ArchiveFilter next) {
    setState(() => _filter = _filter == next ? null : next);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final visible = _visible;
    final challengeLabel = widget.results.length == 1
        ? CornerCopy.tallyChallenge
        : CornerCopy.tallyChallenges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          child: Row(
            children: [
              _FilterCell(
                value: widget.results.length,
                label: challengeLabel,
                tone: a.text,
                selected: _filter == _ArchiveFilter.all,
                onTap: () => _tap(_ArchiveFilter.all),
              ),
              _FilterDot(a: a),
              _FilterCell(
                value: _wonCount,
                label: CornerCopy.tallyWon,
                tone: AppRoles.success,
                selected: _filter == _ArchiveFilter.won,
                onTap: _wonCount == 0 ? null : () => _tap(_ArchiveFilter.won),
              ),
              _FilterDot(a: a),
              _FilterCell(
                value: _lostCount,
                label: CornerCopy.tallyLost,
                tone: AppRoles.risk,
                selected: _filter == _ArchiveFilter.lost,
                onTap: _lostCount == 0 ? null : () => _tap(_ArchiveFilter.lost),
              ),
            ],
          ),
        ),
        if (_filter != null) ...[
          const SizedBox(height: AppSpace.md),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
              child: Text(
                context.l10n.cornerBoardFilterEmpty,
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 13, color: a.textSecondary),
              ),
            )
          else
            _ClosedList(results: visible, uid: widget.uid),
        ],
      ],
    );
  }
}

class _FilterDot extends StatelessWidget {
  final AppearanceStyle a;

  const _FilterDot({required this.a});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '·',
        style: AppTypography.body(size: 18, color: a.textFaint),
      ),
    );
  }
}

class _FilterCell extends StatelessWidget {
  final int value;
  final String label;
  final Color tone;
  final bool selected;
  final VoidCallback? onTap;

  const _FilterCell({
    required this.value,
    required this.label,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final canTap = onTap != null;
    final ink = !canTap
        ? a.textFaint
        : selected
        ? tone
        : value == 0
        ? a.textFaint
        : tone;

    return Expanded(
      child: Semantics(
        button: canTap,
        selected: selected,
        enabled: canTap,
        label: '$value $label',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
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
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.label(
                      size: 11,
                      letterSpacing: 0.3,
                      weight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: AppMotion.quick,
                    height: 2,
                    width: selected ? 28 : 0,
                    decoration: BoxDecoration(
                      color: selected ? tone : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.hair),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
      CornerResultMark.won => AppRoles.success,
      CornerResultMark.together => AppRoles.success,
      CornerResultMark.lost => AppRoles.risk,
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
