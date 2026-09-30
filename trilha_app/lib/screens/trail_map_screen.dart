import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/question_bank.dart';
import '../data/entry_trails.dart';
import '../data/trail_repository.dart';
import '../widgets/character_seals_strip.dart';
import '../l10n/app_language.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/difficulty.dart';
import '../models/pilgrim_medals.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../services/content_catalog_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/difficulty_trails.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/genesis_theme.dart';
import '../utils/trail_progress.dart';
import '../widgets/act_feel.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/genesis_trail_scenery.dart';
import '../widgets/immersive_background.dart';
import '../widgets/medal_unlock_sheet.dart';
import '../widgets/milestone_chests.dart';
import '../widgets/mode_emblem.dart';
import '../widgets/mode_selector.dart';
import '../widgets/top_bar.dart';
import '../widgets/trail_map_path.dart';
import '../widgets/ui_primitives.dart';
import 'difficulty_picker_screen.dart';

class TrailMapScreen extends StatefulWidget {
  final String slug;

  const TrailMapScreen({super.key, required this.slug});

  @override
  State<TrailMapScreen> createState() => _TrailMapScreenState();
}

class _TrailMapScreenState extends State<TrailMapScreen> {
  final _repo = TrailRepository();
  final _scrollController = ScrollController();
  Trail? _trail;
  bool _didAutoScroll = false;
  bool _checkingDifficulty = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _fromBank =>
      trailUsesDifficultyBank(widget.slug) ||
      QuestionBank.instance.hasBankForTrail(widget.slug);

  Future<void> _bootstrap() async {
    // Prefetch do banco enquanto o mapa monta — a cena abre sem esperar.
    unawaited(ContentCatalogService.instance.ensureTrailBank(widget.slug));
    final trail = await _repo.getTrailBySlug(widget.slug);
    if (!mounted) return;
    setState(() => _trail = trail);

    if (_fromBank) {
      final ok = await DifficultyPickerScreen.ensureSelected(
        context,
        trailSlug: widget.slug,
      );
      if (!mounted) return;
      if (!ok) {
        Navigator.of(context).pop();
        return;
      }
      final progress = context.read<ProgressService>();
      await progress.advancePastClearedMode(
        widget.slug,
        missionSlugs: trail?.missionSlugs ?? const [],
      );
    }

    if (mounted) setState(() => _checkingDifficulty = false);
  }

  /// Mapa temático sempre que a trilha tem módulos/missões.
  bool get _useThematicMap {
    final trail = _trail;
    return trail != null &&
        trail.modules.isNotEmpty &&
        trail.missionSlugs.isNotEmpty;
  }

  int _activeModuleIndex(Trail trail, List<String> completed) {
    for (var i = 0; i < trail.modules.length; i++) {
      final missions = trail.modules[i].missions;
      for (final m in missions) {
        final idx = trail.missionSlugs.indexOf(m.slug);
        final unlocked =
            idx <= 0 || completed.contains(trail.missionSlugs[idx - 1]);
        if (unlocked && !completed.contains(m.slug)) return i;
      }
    }
    return (trail.modules.length - 1).clamp(0, trail.modules.length);
  }

  void _maybeScrollToActive(int moduleIndex) {
    if (_didAutoScroll || moduleIndex <= 0) return;
    _didAutoScroll = true;
    // Espera o 1º layout assentar — animar no primeiro frame compete com paint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 280), () {
        if (!mounted || !_scrollController.hasClients) return;
        final target = (160.0 + moduleIndex * 520).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
        );
      });
    });
  }

  TrailRealm get _realm => _trail != null
      ? TrailRealm.fromId(_trail!.realmId)
      : TrailRealm.antigoTestamento;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();

    if (_trail == null || _checkingDifficulty) {
      final mode = progress.settings.appearanceMode;
      final appearance = AppearanceStyle.resolve(mode);
      return Scaffold(
        backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
        body: ImmersiveBackground(
          appearance: appearance,
          child: const AppSpinner(),
        ),
      );
    }

    final trail = _trail!;
    final allSlugs = trail.missionSlugs;
    final completed = progress.completedMissionsForTrail(
      trailSlug: widget.slug,
      missionSlugs: allSlugs,
    );
    final live = TrailProgress.getLiveProgress(trail, completed);
    final prog = live; // mapa da trilha = modo ativo
    final difficultyId = progress.difficultyForTrail(widget.slug);
    final cleared = progress.clearedModesFor(widget.slug);
    final replaying = TrailProgress.isReplayingUnclearedMode(
      clearedModes: cleared,
      activeDifficultyId: difficultyId,
      liveDone: live.done,
      total: live.total,
    );
    final replayHint = replaying
        ? TrailProgress.modeReplayHint(
            clearedModes: cleared,
            activeDifficultyId: difficultyId,
          )
        : null;
    final sealedHint = replayHint == null
        ? TrailProgress.modeSealedHint(
            clearedModes: cleared,
            activeDifficultyId: difficultyId,
          )
        : null;
    final modeBanner = replayHint ?? sealedHint;
    final modeName = TrailProgress.modeLabel(difficultyId);
    final modeAccent = DifficultyVisuals.accentFor(
      TrailDifficulty.fromId(difficultyId) ?? TrailDifficulty.semente,
    );

    if (allSlugs.isEmpty) {
      final mode = progress.settings.appearanceMode;
      final appearance = AppearanceStyle.resolve(mode);
      return Appearance(
        mode: mode,
        style: appearance,
        child: Scaffold(
          backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
          body: ImmersiveBackground(
            appearance: appearance,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpace.screen,
                    MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
                    AppSpace.screen,
                    0,
                  ),
                  child: TopBar(
                    inline: true,
                    immersive: true,
                    title: trail.localizedTitle,
                    subtitle: context.l10n.commonComingSoon,
                    onBack: () => Navigator.pop(context),
                    leadingGlyph: CinematicGlyphResolver.forTrail(trail.slug),
                    chromeAccent: AppRoles.chrome,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.screen,
                      AppSpace.xxxl,
                      AppSpace.screen,
                      32,
                    ),
                    children: [
                      EmptyState(
                        glyph: CinematicGlyphResolver.forTrail(trail.slug),
                        title: context.l10n.commonComingSoon,
                        body: trail.localizedDescription,
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

    final activeModule = _activeModuleIndex(trail, completed);
    _maybeScrollToActive(activeModule);
    final mode = progress.settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

    final eyebrow = _useThematicMap && trail.modules.isNotEmpty
        ? context.l10n.trailsStage(_roman(activeModule + 1))
        : null;
    final headerTitle = _useThematicMap && trail.modules.isNotEmpty
        ? trail.modules[activeModule.clamp(0, trail.modules.length - 1)].title
        : trail.localizedTitle;
    final headerGlyph = _useThematicMap && trail.modules.isNotEmpty
        ? CinematicGlyphResolver.forModule(
            trail
                .modules[activeModule.clamp(0, trail.modules.length - 1)]
                .title,
          )
        : CinematicGlyphResolver.forTrail(trail.slug);

    return Appearance(
      mode: mode,
      style: appearance,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
          body: ImmersiveBackground(
            appearance: appearance,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpace.screen,
                    MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
                    AppSpace.screen,
                    0,
                  ),
                  child: TopBar(
                    inline: true,
                    immersive: true,
                    title: headerTitle,
                    subtitle:
                        eyebrow ??
                        (_fromBank
                            ? TrailProgress.activeModeProgressLabel(
                                clearedModes: cleared,
                                activeDifficultyId: difficultyId,
                                liveDone: prog.done,
                                total: prog.total,
                              )
                            : context.l10n.trailsScenesShort(prog.done, prog.total)),
                    onBack: () => Navigator.pop(context),
                    leadingGlyph: headerGlyph,
                    // TopBar = chrome neutro; cor do modo/área só no conteúdo.
                    chromeAccent: AppRoles.chrome,
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(0, AppSpace.md, 0, 64),
                    children: [
                      if (_fromBank)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.screen,
                            AppSpace.md,
                            AppSpace.screen,
                            AppSpace.sm,
                          ),
                          child: ModeBanner(
                            trailSlug: widget.slug,
                            trailTitle: trail.localizedTitle,
                            missionSlugs: allSlugs,
                            caption: modeBanner,
                          ),
                        )
                      else if (modeBanner != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.screen,
                            0,
                            AppSpace.screen,
                            0,
                          ),
                          child: _ModeReplayBanner(
                            text: modeBanner,
                            difficultyId: difficultyId,
                            sealed: sealedHint != null,
                          ),
                        ),
                      if (!_fromBank)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.screen,
                            AppSpace.md,
                            AppSpace.screen,
                            AppSpace.sm,
                          ),
                          child: _TrailJourneyIntro(
                            difficultyId: null,
                            clearedModeIds: const [],
                            progressCaption:
                                context.l10n.trailsLabeledScenesOf(modeName, prog.done, prog.total),
                          ),
                        ),
                      if (_trailMedalChip(progress, trail) != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.screen,
                            0,
                            AppSpace.screen,
                            AppSpace.md,
                          ),
                          child: _trailMedalChip(progress, trail)!,
                        ),
                      if (_trailSealChip(progress, trail) != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.screen,
                            0,
                            AppSpace.screen,
                            AppSpace.md,
                          ),
                          child: _trailSealChip(progress, trail)!,
                        ),
                      ...trail.modules.asMap().entries.map((entry) {
                        final mi = entry.key;
                        final mod = entry.value;
                        final start = trail.modules
                            .take(mi)
                            .fold(0, (sum, m) => sum + m.missions.length);
                        final moduleTheme = GenesisModuleTheme.forModule(
                          mod.localizedTitle,
                          realm: _realm,
                          trailSlug: trail.slug,
                        );
                        final isActive = mi == activeModule;
                        final modDone = mod.missions
                            .where((m) => completed.contains(m.slug))
                            .length;

                        final path = TrailMapPath(
                          missions: mod.missions,
                          startGlobalIndex: start,
                          allSlugs: allSlugs,
                          completedMissions: completed,
                          theme: moduleTheme,
                          modeAccent: modeAccent,
                          onMissionTap: (slug) => Navigator.of(
                            context,
                          ).pushNamed('/lesson', arguments: slug),
                        );

                        return GenesisModuleScenery(
                          theme: moduleTheme,
                          moduleTitle: mod.localizedTitle,
                          sectionIndex: mi + 1,
                          isActiveChapter: isActive,
                          missionsDone: modDone,
                          missionsTotal: mod.missions.length,
                          modeAccent: modeAccent,
                          child: path,
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpace.screen,
                          AppSpace.md,
                          AppSpace.screen,
                          AppSpace.lg,
                        ),
                        child: MilestoneChestsCard(
                          trailSlug: trail.slug,
                          done: prog.done,
                          total: prog.total,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _roman(int n) {
    const map = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
    if (n >= 1 && n <= map.length) return map[n - 1];
    return '$n';
  }

  Widget? _trailMedalChip(ProgressService progress, Trail trail) {
    final profile = CaravanPilgrimProfile.fromProgress(
      progress: progress,
      uid: '',
    );
    final ctx = PilgrimMedalEvalContext.fromProgress(progress);
    final proximity = PilgrimMedals.nearestLocked(
      profile: profile,
      catalog: [trail],
      priorityTrailSlug: trail.slug,
      ctx: ctx,
    );
    if (proximity == null || proximity.track.trailSlug != trail.slug) {
      return null;
    }
    final accent = tierColor(proximity.nextLevel.tier);
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ActHaptics.tap();
            final vaults = PilgrimMedals.evaluateVaults(
              profile: profile,
              catalog: [trail],
              ctx: ctx,
            );
            for (final vault in vaults) {
              if (vault.vault.id !=
                  PilgrimMedalCatalog.trailVaultId(trail.slug)) {
                continue;
              }
              if (vault.tracks.isEmpty) return;
              showTrackDetailSheet(context, vault.tracks.first);
              return;
            }
          },
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: SoftBadge(
            text: proximity.actionMessage,
            accent: accent,
            textColor: accent,
          ),
        ),
      ),
    );
  }

  Widget? _trailSealChip(ProgressService progress, Trail trail) {
    final seal = CharacterSeals.forTrail(trail.slug);
    if (seal == null) return null;
    final unlocked = progress.isMissionCompleted(seal.missionSlug);
    if (!unlocked) {
      final next = trail.missionSlugs
          .where((s) => !progress.isMissionCompleted(s))
          .firstOrNull;
      if (next != seal.missionSlug) return null;
    }
    final a = Appearance.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: unlocked ? () => showCharacterSealSheet(context, seal) : null,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Opacity(
            opacity: unlocked ? 1 : 0.5,
            child: SoftBadge(
              text: context.l10n.trailMapSeal(seal.name),
              glyph: seal.glyph,
              textColor: a.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeReplayBanner extends StatelessWidget {
  final String text;
  final String? difficultyId;
  final bool sealed;

  const _ModeReplayBanner({
    required this.text,
    this.difficultyId,
    this.sealed = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final mode =
        TrailDifficulty.fromId(difficultyId) ?? TrailDifficulty.semente;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModeEmblem(
            difficulty: mode,
            size: 22,
            cleared: sealed,
            active: !sealed,
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w600,
                color: a.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailJourneyIntro extends StatelessWidget {
  final String? difficultyId;
  final List<String> clearedModeIds;
  final String? progressCaption;

  const _TrailJourneyIntro({
    this.difficultyId,
    this.clearedModeIds = const [],
    this.progressCaption,
  });

  @override
  Widget build(BuildContext context) {
    if (difficultyId == null &&
        progressCaption == null &&
        clearedModeIds.isEmpty) {
      return const SizedBox.shrink();
    }
    final mode = TrailDifficulty.fromId(difficultyId);
    final color = mode != null
        ? DifficultyVisuals.accentFor(mode)
        : AppRoles.chrome;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (clearedModeIds.isNotEmpty || difficultyId != null)
          ModeEmblemStrip(
            clearedModeIds: clearedModeIds,
            activeDifficultyId: difficultyId,
            emblemSize: 32,
            labeled: true,
          ),
        if (progressCaption != null) ...[
          if (clearedModeIds.isNotEmpty || difficultyId != null)
            const SizedBox(height: AppSpace.sm),
          Text(
            progressCaption!,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w700,
              color: DifficultyVisuals.onSky(color).withValues(alpha: 0.88),
            ),
          ),
        ],
      ],
    );
  }
}
