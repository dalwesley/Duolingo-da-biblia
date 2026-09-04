import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/caravan_profile_prefs.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'pilgrim_profile_sections.dart';

/// Vitrine social — só para outros peregrinos da caravana.
Future<void> showCaravanPilgrimSheet(
  BuildContext context, {
  required LeagueEntry entry,
  required int rank,
  bool weeklySteps = false,
}) {
  assert(!entry.isUser, 'Use o perfil para ver seus próprios dados.');
  HapticFeedback.lightImpact();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    builder: (ctx) => _CaravanPilgrimSheet(
      entry: entry,
      rank: rank,
      weeklySteps: weeklySteps,
    ),
  );
}

class _CaravanPilgrimSheet extends StatefulWidget {
  final LeagueEntry entry;
  final int rank;
  final bool weeklySteps;

  const _CaravanPilgrimSheet({
    required this.entry,
    required this.rank,
    required this.weeklySteps,
  });

  @override
  State<_CaravanPilgrimSheet> createState() => _CaravanPilgrimSheetState();
}

class _CaravanPilgrimSheetState extends State<_CaravanPilgrimSheet> {
  CaravanPilgrimProfile? _profile;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final retrying = _error != null || !_loading;
    if (retrying && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final backend = context.read<BackendService>();
      final enriched = await loadEnrichedVisitorProfile(
        entry: widget.entry,
        backend: backend,
      );
      if (!mounted) return;
      setState(() {
        _profile = enriched;
        _error = null;
        _loading = false;
      });
      if (widget.rank == 1) HapticFeedback.mediumImpact();
    } catch (e, st) {
      debugPrint('CaravanPilgrimSheet: $e\n$st');
      if (!mounted) return;
      setState(() {
        _profile = CaravanPilgrimProfile.fromRankingCard(
          uid: widget.entry.uid,
          name: widget.entry.name,
          steps: widget.entry.steps,
          lastWalkDate: widget.entry.lastWalkDate,
          lastSeenDate: widget.entry.lastSeenDate,
        );
        _error = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.82;
    final profile = _profile;
    final rankColor = pilgrimRankAccent(widget.rank);

    return SizedBox(
      height: sheetHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: rankColor.withValues(alpha: widget.rank <= 3 ? 0.55 : 0.28),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: rankColor.withValues(alpha: widget.rank <= 3 ? 0.22 : 0.08),
              blurRadius: 36,
              offset: const Offset(0, -12),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.nightElevated,
                      AppColors.night,
                      AppColors.nightMid,
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.55),
                        radius: 1.05,
                        colors: [
                          rankColor.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: _loading
                        ? const Column(
                            children: [
                              SizedBox(height: AppSpace.sm),
                              _SheetDragHandle(),
                              Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _error != null
                            ? Column(
                                children: [
                                  const SizedBox(height: AppSpace.sm),
                                  const _SheetDragHandle(),
                                  Expanded(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                          AppSpace.xl,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _error!,
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 12),
                                            TextButton(
                                              onPressed: _load,
                                              child: const Text('Tentar de novo'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView(
                                padding: EdgeInsets.only(bottom: bottom + 24),
                                children: [
                                  _VisitorPoster(
                                    entry: widget.entry,
                                    rank: widget.rank,
                                    profile: profile!,
                                    weeklySteps: widget.weeklySteps,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      AppSpace.screen,
                                      AppSpace.md,
                                      AppSpace.screen,
                                      0,
                                    ),
                                    child: PilgrimProfileDetailSections(
                                      profile: profile,
                                      entry: widget.entry,
                                      isOwner: false,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisitorPoster extends StatelessWidget {
  final LeagueEntry entry;
  final int rank;
  final CaravanPilgrimProfile profile;
  final bool weeklySteps;

  const _VisitorPoster({
    required this.entry,
    required this.rank,
    required this.profile,
    required this.weeklySteps,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final rankColor = pilgrimRankAccent(rank);
    final initial =
        profile.name.isEmpty ? '?' : profile.name[0].toUpperCase();
    final showStats = profile.prefs.shouldShow(
      CaravanProfileSection.ranking,
      isOwner: false,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 280,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  rankColor.withValues(alpha: 0.32),
                  rankColor.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.screen,
            AppSpace.sm,
            AppSpace.screen,
            AppSpace.md,
          ),
          child: Column(
            children: [
              const _SheetDragHandle(),
              const SizedBox(height: 14),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -8,
                    top: -20,
                    child: Text(
                      '$rank',
                      style: AppTypography.display(
                        size: rank <= 3 ? 148 : 120,
                        weight: FontWeight.w900,
                        color: rankColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.32),
                                  AppColors.nightMid,
                                ],
                              ),
                              border: Border.all(
                                color: entry.isOnlineToday
                                    ? AppColors.teal
                                    : rankColor.withValues(alpha: 0.85),
                                width: 2.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: AppTypography.display(
                                  size: 32,
                                  color: a.text,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -6,
                            bottom: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient:
                                    rank <= 3 ? AppGradients.gold : null,
                                color: rank > 3 ? rankColor : null,
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                                border: Border.all(
                                  color: AppColors.night,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '$rankº',
                                style: AppTypography.label(
                                  size: 11,
                                  letterSpacing: 0.4,
                                  color: rank <= 3
                                      ? AppColors.inkOnAccent
                                      : AppColors.night,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        pilgrimRankEpithet(rank).toUpperCase(),
                        style: AppTypography.label(
                          size: 10,
                          letterSpacing: 1.8,
                          color: rankColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profile.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.display(
                          size: 26,
                          weight: FontWeight.w900,
                          color: a.text,
                        ),
                      ),
                      if (showStats) ...[
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${profile.steps}',
                              style: AppTypography.display(
                                size: 44,
                                weight: FontWeight.w900,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                weeklySteps
                                    ? 'passos nesta semana'
                                    : 'passos na jornada',
                                style: AppTypography.body(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: a.textMuted(0.62),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (profile.missionsCompleted > 0) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${profile.missionsCompleted} cenas concluídas',
                            style: AppTypography.body(
                              size: 12,
                              weight: FontWeight.w700,
                              color: a.textMuted(0.55),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 48,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
    );
  }
}
