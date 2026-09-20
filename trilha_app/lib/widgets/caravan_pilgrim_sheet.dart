import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/caravan_profile_prefs.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/trail.dart';
import '../data/trail_repository.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'corner_profile_cta.dart';
import 'portrait_face.dart';
import 'pilgrim_profile_sections.dart';
import 'stway_brand.dart';

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
  List<Trail> _catalog = const [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(const AssetImage(StwayPathBackdrop.asset), context);
    });
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
      final results = await Future.wait<Object?>([
        loadEnrichedVisitorProfile(
          entry: widget.entry,
          backend: backend,
        ),
        TrailRepository().getTrails(),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as CaravanPilgrimProfile;
        _catalog = results[1] as List<Trail>;
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
          photoUrl: widget.entry.photoUrl,
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
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 24,
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
                                  CornerProfileCta(
                                    profile: profile,
                                    catalog: _catalog,
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
    final seed = profile.uid ?? entry.uid ?? profile.name;
    final showStats = profile.prefs.shouldShow(
      CaravanProfileSection.ranking,
      isOwner: false,
    );
    final showTrailsStat = profile.prefs.shouldShow(
      CaravanProfileSection.trails,
      isOwner: false,
    );
    final showAccuracyStat = profile.prefs.shouldShow(
          CaravanProfileSection.accuracy,
          isOwner: false,
        ) &&
        profile.accuracyPercent != null;
    final showStreakStat = profile.prefs.shouldShow(
          CaravanProfileSection.presence,
          isOwner: false,
        ) &&
        profile.streak > 0 &&
        !showAccuracyStat;
    final trailsOpen = profile.trails.where((t) => !t.isComplete).length;

    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: AppColors.night),
        ),
        const Positioned.fill(
          child: StwayPathBackdrop(
            opacity: 0.88,
            alignment: Alignment(0, 0.28),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66070B14),
                  Color(0x22070B14),
                  Color(0xE6070B14),
                ],
                stops: [0, 0.38, 1],
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetDragHandle(),
              const SizedBox(height: 12),
              _TopoPanel(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.nightMid,
                                border: Border.all(
                                  color: entry.isOnlineToday
                                      ? AppColors.teal
                                      : rankColor.withValues(alpha: 0.9),
                                  width: 2,
                                ),
                              ),
                              child: PortraitFace(
                                name: profile.name,
                                photoUrl: profile.photoUrl ?? entry.photoUrl,
                                seed: seed,
                                size: 52,
                                style: entry.portraitStyle,
                              ),
                            ),
                            Positioned(
                              right: -6,
                              bottom: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
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
                                    size: 9,
                                    letterSpacing: 0.3,
                                    color: rank <= 3
                                        ? AppColors.inkOnAccent
                                        : AppColors.night,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pilgrimRankEpithet(rank).toUpperCase(),
                                style: AppTypography.label(
                                  size: 10,
                                  letterSpacing: 1.4,
                                  color: rankColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.display(
                                  size: 22,
                                  weight: FontWeight.w900,
                                  color: a.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Um passo. Uma jornada.',
                                style: AppTypography.body(
                                  size: 12,
                                  height: 1.2,
                                  color: a.textMuted(0.62),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (showStats) ...[
                      const SizedBox(height: 12),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _PosterStat(
                              glyph: CinematicGlyph.path,
                              value: pilgrimFormatCount(profile.steps),
                              label: weeklySteps
                                  ? 'Na semana'
                                  : 'Passos na Palavra',
                            ),
                          ),
                          Expanded(
                            child: _PosterStat(
                              glyph: CinematicGlyph.scroll,
                              value: '${profile.missionsCompleted}',
                              label: profile.missionsCompleted == 1
                                  ? 'Cena concluída'
                                  : 'Cenas concluídas',
                            ),
                          ),
                          if (showTrailsStat)
                            Expanded(
                              child: _PosterStat(
                                glyph: CinematicGlyph.book,
                                value: '$trailsOpen',
                                label: trailsOpen == 1
                                    ? 'Trilha em andamento'
                                    : 'Trilhas em andamento',
                              ),
                            ),
                          if (showAccuracyStat)
                            Expanded(
                              child: _PosterStat(
                                glyph: CinematicGlyph.target,
                                value: '${profile.accuracyPercent}%',
                                label: 'Precisão',
                              ),
                            )
                          else if (showStreakStat)
                            Expanded(
                              child: _PosterStat(
                                glyph: CinematicGlyph.flame,
                                value: '${profile.streak}',
                                label: profile.streak == 1
                                    ? 'Dia seguido'
                                    : 'Dias seguidos',
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopoPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _TopoPanel({
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.night.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _PosterStat extends StatelessWidget {
  final CinematicGlyph glyph;
  final String value;
  final String label;

  const _PosterStat({
    required this.glyph,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      children: [
        CinematicIcon(
          glyph: glyph,
          size: 14,
          accent: AppColors.accent.withValues(alpha: 0.9),
          framed: false,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.display(
            size: 16,
            weight: FontWeight.w900,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.label(
            size: 7,
            letterSpacing: 0.3,
            color: a.textMuted(0.5),
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
