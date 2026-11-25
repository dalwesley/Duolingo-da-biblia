import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/caravan_profile_prefs.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/recognition.dart';
import '../models/trail.dart';
import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/moderation_service.dart';
import '../services/remote_config_service.dart';
import '../theme/app_theme.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'corner_profile_cta.dart';
import 'pilgrim_profile_cover.dart';
import 'profile_hero.dart' show ProfileHero;
import 'recognition_actions.dart';
import '../services/progress_service.dart';
import '../utils/appearance.dart';
import '../utils/spiritual_growth.dart';
import 'pilgrim_profile_sections.dart';
import 'profile_plus_cards.dart' show ProfileAccuracyCard;
import 'room_pilot_cards.dart' show GroupSealsCard;
import 'cloud_mascot.dart';
import 'ui_primitives.dart';
import 'user_moderation_sheet.dart';

/// Vitrine social — só para outros peregrinos da caravana.
/// [rank] 0 = fora do ranking (ex.: aberto da Caminhada sazonal).
Future<void> showCaravanPilgrimSheet(
  BuildContext context, {
  required LeagueEntry entry,
  required int rank,
}) {
  assert(!entry.isUser, 'Use o perfil para ver seus próprios dados.');
  ActHaptics.light();
  return showAppSheet<void>(
    context,
    enableDrag: true,
    isDismissible: true,
    builder: (ctx) => _CaravanPilgrimSheet(entry: entry, rank: rank),
  );
}

/// Prévia do **próprio** perfil como a caravana vê. No topo, os olhos de
/// todas as seções: tocar muda o que aparece e a vitrine responde na hora.
Future<void> showCaravanSelfPreviewSheet(
  BuildContext context, {
  required LeagueEntry entry,
  required int rank,
}) {
  ActHaptics.light();
  return showAppSheet<void>(
    context,
    enableDrag: true,
    isDismissible: true,
    builder: (ctx) =>
        _CaravanPilgrimSheet(entry: entry, rank: rank, preview: true),
  );
}

class _CaravanPilgrimSheet extends StatefulWidget {
  final LeagueEntry entry;
  final int rank;
  final bool preview;

  const _CaravanPilgrimSheet({
    required this.entry,
    required this.rank,
    this.preview = false,
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
        widget.preview
            ? loadEnrichedOwnerProfile(context.read<ProgressService>(), backend)
            : loadEnrichedVisitorProfile(entry: widget.entry, backend: backend),
        TrailRepository().getTrails(),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as CaravanPilgrimProfile;
        _catalog = results[1] as List<Trail>;
        _error = null;
        _loading = false;
      });
      if (widget.rank == 1 && !widget.preview) ActHaptics.confirm();
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

  /// Jogador real (com conta) — os de exemplo não têm uid.
  String? get _reportableUid {
    if (widget.preview) return null;
    final uid = widget.entry.uid;
    return uid == null || uid.isEmpty ? null : uid;
  }

  @override
  Widget build(BuildContext context) {
    // Alça + margens do painel ficam fora da área de conteúdo.
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.82 - 32;
    // Na prévia, as escolhas vêm ao vivo do aparelho.
    final profile = widget.preview && _profile != null
        ? _profile!.withPrefs(
            context.watch<ProgressService>().caravanProfilePrefs,
          )
        : _profile;
    // Pódio (1–3) acende em metal; do 4º em diante o halo é chrome neutro.
    final podium = widget.rank > 0 && widget.rank <= 3;
    final rankColor = podium ? pilgrimRankAccent(widget.rank) : AppRoles.chrome;

    return AppSheetPanel(
      tint: podium ? rankColor : null,
      padding: const EdgeInsets.only(top: AppSpace.md),
      background: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.55),
              radius: 1.05,
              colors: [rankColor.withValues(alpha: 0.2), Colors.transparent],
            ),
          ),
        ),
      ),
      child: SizedBox(
        height: sheetHeight,
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Column(children: [Expanded(child: AppSpinner())])
                  : _error != null
                  ? Center(
                      child: SingleChildScrollView(
                        child: EmptyState(
                          mark: const CloudMascot(
                            face: CloudFace.erro,
                            size: 96,
                          ),
                          title: _error!,
                          action: GhostCta(
                            label: context.l10n.commonTryAgain,
                            leading: CinematicGlyph.refresh,
                            onTap: _load,
                          ),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        if (_reportableUid case final uid?)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpace.sm,
                              ),
                              child: UserModerationButton(
                                uid: uid,
                                name: widget.entry.name,
                                source: UserReportSource.ranking,
                                onDone: (outcome) {
                                  // Bloqueado some do placar — fecha o perfil.
                                  if (outcome == ModerationOutcome.blocked &&
                                      context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ),
                          )
                        else if (widget.preview)
                          const Padding(
                            padding: EdgeInsets.fromLTRB(
                              AppSpace.screen,
                              4,
                              AppSpace.screen,
                              AppSpace.section,
                            ),
                            child: _SelfPreviewControls(),
                          )
                        else
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
                        if (!widget.preview &&
                            context
                                .watch<RemoteConfigService>()
                                .challengeEnabled)
                          CornerProfileCta(profile: profile, catalog: _catalog),
                      ],
                    ),
            ),
          ],
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
    final extras = profile.extras;
    final showStudy = _visible(CaravanProfileSection.study) && extras.hasStudy;
    final showWord =
        _visible(CaravanProfileSection.word) &&
        (profile.bibleChaptersRead > 0 ||
            extras.bookmarkCount > 0 ||
            extras.noteCount > 0);
    final showQuests =
        _visible(CaravanProfileSection.quests) && extras.questsThisWeek;
    final showGroupSeals =
        _visible(CaravanProfileSection.groupSeals) && extras.groupSealCount > 0;
    final identityVisible =
        showRanking || showPresence || showAccuracy || showLeader;

    final l10n = context.l10n;
    final growth = SpiritualGrowth.fromStreak(profile.streak);
    final viewerDone = context
        .read<ProgressService>()
        .completedMissions
        .toSet();
    final showLastScene = _visible(CaravanProfileSection.lastMission);
    final showTrails = _visible(CaravanProfileSection.trails);
    final chosen = profile.coverScene;
    final cover = showLastScene || showTrails
        ? ((chosen != null && profile.completedMissions.contains(chosen)
                  ? chosen
                  : null) ??
              profile.lastMissionSlug ??
              (profile.completedMissions.isEmpty
                  ? null
                  : profile.completedMissions.last))
        : null;

    final epithetParts = <String>[
      if (showRanking && rank > 0)
        rank <= 3 ? pilgrimRankEpithet(rank) : l10n.pilgrimRank(rank),
      if (showLeader && profile.daysAsCaravanLeader > 0)
        l10n.profileDaysOnTop(profile.daysAsCaravanLeader),
    ];
    final walkDate = recognizableWalkDate(profile);
    final accuracy = profile.accuracyPercent;

    final stats = <PilgrimStat>[
      if (showPresence)
        PilgrimStat(
          glyph: CinematicGlyph.flame,
          tone: AppRoles.streak,
          value: profile.streak,
          label: l10n.profileStatStreak,
          caption: profile.streak > 0 ? growth.title : null,
        ),
      if (showRanking)
        PilgrimStat(
          glyph: CinematicGlyph.sneaker,
          tone: AppRoles.lamp,
          value: profile.steps,
          label: l10n.pilgrimStatSteps,
        ),
      if (showRanking)
        PilgrimStat(
          glyph: CinematicGlyph.scroll,
          tone: AppRoles.navTrails,
          value: profile.missionsCompleted,
          label: l10n.pilgrimStatScenes,
        ),
      if (showAccuracy &&
          accuracy != null &&
          profile.lifetimeQuestionsAnswered > 0)
        PilgrimStat(
          glyph: CinematicGlyph.target,
          tone: AppRoles.success,
          value: accuracy,
          suffix: '%',
          label: l10n.pilgrimAccuracyTitle,
          caption: l10n.pilgrimCorrectRatio(
            profile.lifetimeQuestionsCorrect,
            profile.lifetimeQuestionsAnswered,
          ),
        ),
    ];

    // Postais: a cena mais recente primeiro.
    final scenes = <({String slug, String? day})>[];
    if (showTrails) {
      final seen = <String>{};
      final last = profile.lastMissionSlug;
      if (last != null && seen.add(last)) {
        scenes.add((slug: last, day: profile.lastMissionCompletedDate));
      }
      for (final slug in profile.completedMissions.reversed) {
        if (seen.add(slug)) scenes.add((slug: slug, day: null));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PilgrimProfileTop(
          name: ProgressService.isPlaceholderUserName(profile.name)
              ? l10n.pilgrimFallbackName
              : profile.name.trim(),
          photoUrl: profile.photoUrl ?? entry.photoUrl,
          seed: profile.uid ?? entry.uid ?? profile.name,
          style: entry.portraitStyle,
          coverScene: cover,
          stats: stats,
          coverVeiled: cover != null && !viewerDone.contains(cover),
          rank: showRanking ? rank : 0,
          epithet: epithetParts.isEmpty ? null : epithetParts.join(' · '),
          sinceLabel: profile.firstOpenDate == null
              ? null
              : ProfileHero.sinceFrom(profile.firstOpenDate),
          supporter: profile.supporter,
          pilgrim: profile.pilgrim,
          pioneer: profile.pioneer,
          footer: showPresence
              ? PilgrimStreakFooter(
                  streak: profile.streak,
                  playDates: profile.playDates,
                  walk: entry.walkedToday
                      ? l10n.commonToday
                      : pilgrimFormatShort(profile.lastWalkDate),
                  online: pilgrimFormatOnline(profile.lastSeenDate),
                  walkedToday: entry.walkedToday,
                  showStreak: profile.streak > 0,
                  bestStreak: profile.bestStreak,
                )
              : null,
          coverAction: profile.uid != null && walkDate != null
              ? RecognizeHeartButton(
                  toUid: profile.uid,
                  kind: RecognitionKind.walk,
                  subjectKey: walkDate,
                  padding: EdgeInsets.zero,
                )
              : null,
        ),
        // Mesma ordem do perfil próprio: tarefas e selos de grupo logo
        // depois do topo.
        if (showQuests) ...[
          const SizedBox(height: AppSpace.section),
          PilgrimQuestsCard(extras: extras),
        ],
        if (showGroupSeals) ...[
          const SizedBox(height: AppSpace.section),
          GroupSealsCard(count: extras.groupSealCount),
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
            visitorPostcards: scenes.isEmpty
                ? null
                : PilgrimPostcardStrip(
                    scenes: scenes,
                    viewerDone: viewerDone,
                    showHeader: false,
                  ),
          ),
        ],
        if (showStudy) ...[
          const SizedBox(height: AppSpace.section),
          ProfileAccuracyCard.visitor(
            visitor: extras,
            visitorCorrect: profile.lifetimeQuestionsCorrect,
            visitorAnswered: profile.lifetimeQuestionsAnswered,
          ),
        ],
        if (showWord) ...[
          const SizedBox(height: AppSpace.section),
          NaPalavraCard(
            chapters: profile.bibleChaptersRead,
            books: profile.completeBibleBooks.length,
            favorites: extras.bookmarkCount,
            notes: extras.noteCount,
          ),
        ],
      ],
    );
  }
}

/// Topo da prévia: o que é e um olho por seção. Mesmas escolhas dos olhos
/// nos cards do perfil e de Ajustes.
class _SelfPreviewControls extends StatelessWidget {
  const _SelfPreviewControls();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final progress = context.watch<ProgressService>();
    final prefs = progress.caravanProfilePrefs;
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        color: AppRoles.presence.withValues(alpha: 0.08),
        border: Border.all(color: AppRoles.presence.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CinematicIcon(
                glyph: CinematicGlyph.people,
                size: 16,
                accent: AppRoles.presence,
                framed: false,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.caravanPreviewTitle,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.caravanPreviewBody,
            style: AppTypography.body(size: 12, color: a.textSecondary),
          ),
          const SizedBox(height: AppSpace.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in CaravanProfileSection.values)
                _SectionEyeChip(
                  label: s.label,
                  visible: prefs.isVisible(s),
                  onTap: () {
                    ActHaptics.tap();
                    progress.updateCaravanProfilePrefs(
                      prefs.copyWithSection(s, !prefs.isVisible(s)),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionEyeChip extends StatelessWidget {
  final String label;
  final bool visible;
  final VoidCallback onTap;

  const _SectionEyeChip({
    required this.label,
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = visible ? AppRoles.presence : a.textFaint;
    return Semantics(
      button: true,
      toggled: visible,
      label: visible
          ? context.l10n.profilePrivacyShownSemantics(label)
          : context.l10n.profilePrivacyHiddenSemantics(label),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.quick,
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            color: visible
                ? AppRoles.presence.withValues(alpha: 0.14)
                : Colors.transparent,
            border: Border.all(
              color: visible
                  ? AppRoles.presence.withValues(alpha: 0.55)
                  : a.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                visible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 14,
                color: ink,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w800,
                  color: visible ? a.text : a.textFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
