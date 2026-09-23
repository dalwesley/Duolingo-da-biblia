import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/caravan_profile_prefs.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/recognition.dart';
import '../models/trail.dart';
import '../data/trail_repository.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../theme/app_theme.dart';
import 'corner_profile_cta.dart';
import 'living_seed_card.dart';
import 'pilgrim_identity_card.dart';
import 'pilgrim_profile_sections.dart';

/// Vitrine social — só para outros peregrinos da caravana.
Future<void> showCaravanPilgrimSheet(
  BuildContext context, {
  required LeagueEntry entry,
  required int rank,
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
    builder: (ctx) => _CaravanPilgrimSheet(entry: entry, rank: rank),
  );
}

class _CaravanPilgrimSheet extends StatefulWidget {
  final LeagueEntry entry;
  final int rank;

  const _CaravanPilgrimSheet({required this.entry, required this.rank});

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
        loadEnrichedVisitorProfile(entry: widget.entry, backend: backend),
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
                                    padding: const EdgeInsets.all(AppSpace.xl),
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
                              const SizedBox(height: AppSpace.sm),
                              const _SheetDragHandle(),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpace.screen,
                                ),
                                child: _VisitorProfileMirror(
                                  entry: widget.entry,
                                  rank: widget.rank,
                                  profile: profile!,
                                  catalog: _catalog,
                                ),
                              ),
                              CornerProfileCta(
                                profile: profile,
                                catalog: _catalog,
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

class _VisitorProfileMirror extends StatelessWidget {
  final LeagueEntry entry;
  final int rank;
  final CaravanPilgrimProfile profile;
  final List<Trail> catalog;

  const _VisitorProfileMirror({
    required this.entry,
    required this.rank,
    required this.profile,
    required this.catalog,
  });

  bool _visible(CaravanProfileSection section) =>
      profile.prefs.shouldShow(section, isOwner: false);

  @override
  Widget build(BuildContext context) {
    final showRanking = _visible(CaravanProfileSection.ranking);
    final showPresence = _visible(CaravanProfileSection.presence);
    final showAccuracy = _visible(CaravanProfileSection.accuracy);
    final showLeader = _visible(CaravanProfileSection.daysAsLeader);
    final showLater =
        _visible(CaravanProfileSection.lastMission) ||
        _visible(CaravanProfileSection.trails) ||
        _visible(CaravanProfileSection.bible) ||
        _visible(CaravanProfileSection.medals);
    final identityVisible =
        showRanking || showPresence || showAccuracy || showLeader;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PilgrimIdentityCard(
          name: profile.name,
          photoUrl: profile.photoUrl ?? entry.photoUrl,
          seed: profile.uid ?? entry.uid ?? profile.name,
          style: entry.portraitStyle,
          steps: profile.steps,
          missions: profile.missionsCompleted,
          showMissions: showRanking,
          accuracyPercent: profile.accuracyPercent,
          accuracyCorrect: profile.lifetimeQuestionsCorrect,
          accuracyTotal: profile.lifetimeQuestionsAnswered,
          rank: rank,
          leaderDays: profile.daysAsCaravanLeader,
          showSteps: showRanking,
          showRank: showRanking,
          showLeaderDays: showLeader,
          showAccuracy: showAccuracy,
          showWeek: showPresence,
          playedOnDate: (day) => pilgrimPlayedOnDate(
            day: day,
            playDates: profile.playDates,
            walkedToday: entry.walkedToday,
          ),
          recognizeWalkToUid: profile.uid,
          recognizeWalkDate: recognizableWalkDate(profile),
        ),
        if (showPresence) ...[
          const SizedBox(height: AppSpace.section),
          LivingSeedCard(streak: profile.streak),
        ],
        if (showLater || !identityVisible) ...[
          const SizedBox(height: AppSpace.section),
          PilgrimProfileDetailSections(
            profile: profile,
            entry: entry,
            isOwner: false,
            omitSections: const {
              CaravanProfileSection.ranking,
              CaravanProfileSection.daysAsLeader,
              CaravanProfileSection.accuracy,
              CaravanProfileSection.presence,
            },
            includeStreakMilestones: false,
            suppressEmptyState: identityVisible,
          ),
        ],
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
