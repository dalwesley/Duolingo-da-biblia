import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/question_bank.dart';
import '../data/entry_trails.dart';
import '../data/trail_art.dart';
import '../data/trail_repository.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/plus_log.dart';
import '../services/subscription_service.dart';
import '../utils/plus_access.dart';
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
import '../utils/layout_utils.dart';
import '../utils/day_phase.dart';
import '../utils/difficulty_trails.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/genesis_theme.dart';
import '../utils/trail_progress.dart';
import '../widgets/act_feel.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/genesis_trail_scenery.dart';
import '../widgets/immersive_background.dart';
import '../widgets/journey_sky.dart';
import '../widgets/journey_station_card.dart' show journeyRomanNumeral;
import '../widgets/medal_unlock_sheet.dart';
import '../widgets/milestone_chests.dart';
import '../widgets/path_preview_sheet.dart';
import '../widgets/plus_locked_sheet.dart';
import '../widgets/mode_emblem.dart';
import '../widgets/mode_selector.dart';
import '../widgets/reset_progress_sheet.dart';
import '../widgets/top_bar.dart';
import '../widgets/trail_gift.dart';
import '../widgets/trail_map_path.dart';
import '../widgets/ui_primitives.dart';
import 'difficulty_picker_screen.dart';
import 'paywall_screen.dart';

class TrailMapScreen extends StatefulWidget {
  final String slug;

  const TrailMapScreen({super.key, required this.slug});

  @override
  State<TrailMapScreen> createState() => _TrailMapScreenState();
}

class _TrailMapScreenState extends State<TrailMapScreen> {
  final _repo = TrailRepository();
  final _scrollController = ScrollController();
  final _currentKey = GlobalKey();
  Trail? _trail;
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

  TrailRealm get _realm => _trail != null
      ? TrailRealm.fromId(_trail!.realmId)
      : TrailRealm.antigoTestamento;

  @override
  Widget build(BuildContext context) {
    // Só o que o mapa usa — watch amplo reconstruía arte + winding a cada XP.
    final appearanceMode = context.select(
      (ProgressService p) => p.settings.appearanceMode,
    );
    final difficultyId = context.select(
      (ProgressService p) => p.difficultyForTrail(widget.slug),
    );
    final clearedSig = context.select(
      (ProgressService p) => p.clearedModesFor(widget.slug).join('|'),
    );
    final plusOpen = context.select(
      (SubscriptionService s) => s.plusFeaturesOpen,
    );
    final subscriber = context.select(
      (SubscriptionService s) => s.isPeregrinoPlus,
    );

    if (_trail == null || _checkingDifficulty) {
      final appearance = AppearanceStyle.resolve(appearanceMode);
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
    final completedSig = context.select((ProgressService p) {
      final done = p.completedMissionsForTrail(
        trailSlug: widget.slug,
        missionSlugs: allSlugs,
      );
      final set = done.toSet();
      return allSlugs.where(set.contains).join('|');
    });
    final completed = completedSig.isEmpty
        ? const <String>[]
        : completedSig.split('|');
    // ProgressService ainda precisa para medal/selo (leituras pontuais).
    final progress = context.read<ProgressService>();
    final live = TrailProgress.getLiveProgress(trail, completed);
    final prog = live; // mapa da trilha = modo ativo
    final cleared = clearedSig.isEmpty
        ? const <String>[]
        : clearedSig.split('|');
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
      final mode = appearanceMode;
      final appearance = AppearanceStyle.resolve(mode);
      return Appearance(
        mode: mode,
        style: appearance,
        child: Scaffold(
          backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
          body: ImmersiveBackground(
            appearance: appearance,
            frameChild: false,
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
                  ),
                ),
                Expanded(
                  child: ContentFrame(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.screen,
                        AppSpace.xxxl,
                        AppSpace.screen,
                        32,
                      ),
                      children: [
                        EmptyState(
                          title: context.l10n.commonComingSoon,
                          body: trail.localizedDescription,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final activeModule = _activeModuleIndex(trail, completed);
    final mode = appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

    final currentSlug = TrailProgress.getCurrentMission(trail, completed)?.slug;
    final medalChip = _trailMedalChip(progress, trail);

    // Cabeçalhos antes dos módulos (virtualizados com ListView.builder).
    final headers = <Widget>[
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
            progressCaption: context.l10n.trailsLabeledScenesOf(
              modeName,
              prog.done,
              prog.total,
            ),
          ),
        ),
      if (medalChip != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.screen,
            0,
            AppSpace.screen,
            AppSpace.md,
          ),
          child: medalChip,
        ),
    ];
    final moduleCount = trail.modules.length;
    final itemCount = headers.length + moduleCount + 1;

    return Appearance(
      mode: mode,
      style: appearance,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: appearance.systemOverlay,
        child: Scaffold(
          backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
          body: ImmersiveBackground(
            appearance: appearance,
            frameChild: false,
            // Mesmo fundo da tela do caminho.
            background: JourneySkyBackdrop(
              journey: trail.journey,
              appearance: appearance,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpace.screen,
                    MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
                    AppSpace.screen,
                    0,
                  ),
                  // Nome da trilha no topo; a etapa já tem o card dela logo
                  // abaixo (antes os dois diziam "Etapa I · Abraão").
                  child: TopBar(
                    inline: true,
                    immersive: true,
                    title: trail.localizedTitle,
                    subtitle: _useThematicMap
                        ? trail.journey.label
                        : (_fromBank
                              ? TrailProgress.activeModeProgressLabel(
                                  clearedModes: cleared,
                                  activeDifficultyId: difficultyId,
                                  liveDone: prog.done,
                                  total: prog.total,
                                )
                              : context.l10n.trailsScenesShort(
                                  prog.done,
                                  prog.total,
                                )),
                    onBack: () => Navigator.pop(context),
                    leadingGlyph: CinematicGlyphResolver.forTrail(trail.slug),
                    // TopBar = chrome neutro; cor do modo/área só no conteúdo.
                  ),
                ),
                Expanded(
                  child: ContentFrame(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(0, AppSpace.md, 0, 64),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (index < headers.length) return headers[index];
                        final mi = index - headers.length;
                        if (mi >= moduleCount) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpace.screen,
                              AppSpace.md,
                              AppSpace.screen,
                              AppSpace.lg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (subscriber &&
                                    PlusAccess.trailInPlus(trail)) ...[
                                  TrailGiftCard(trail: trail),
                                  const SizedBox(height: AppSpace.lg),
                                ],
                                MilestoneChestsCard(
                                  trailSlug: trail.slug,
                                  done: prog.done,
                                  total: prog.total,
                                ),
                                const SizedBox(height: AppSpace.lg),
                                GhostCta(
                                  label: context.l10n.trailsLeaveCta,
                                  danger: true,
                                  expanded: true,
                                  onTap: () => _confirmLeaveTrail(trail),
                                ),
                              ],
                            ),
                          );
                        }
                        final mod = trail.modules[mi];
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

                        return RepaintBoundary(
                          child: GenesisModuleScenery(
                            theme: moduleTheme,
                            moduleTitle: mod.localizedTitle,
                            sectionIndex: mi + 1,
                            isActiveChapter: isActive,
                            missionsDone: modDone,
                            missionsTotal: mod.missions.length,
                            modeAccent: modeAccent,
                            art: isActive ? TrailArt.of(trail.slug) : null,
                            badge: _sealMarkFor(progress, trail, mod),
                            child: TrailMapPath(
                              missions: mod.missions,
                              startGlobalIndex: start,
                              allSlugs: allSlugs,
                              completedMissions: completed,
                              trailSlug: trail.slug,
                              modeLabel: modeName,
                              theme: moduleTheme,
                              modeAccent: modeAccent,
                              onMissionTap: (slug) => Navigator.of(
                                context,
                              ).pushNamed('/lesson', arguments: slug),
                              currentKey: _currentKey,
                              currentSlug: currentSlug,
                              revealed: progress.sceneRevealed,
                              plusLocked: plusOpen
                                  ? null
                                  : (slug) => PlusAccess.missionNeedsPlus(
                                      trail,
                                      slug,
                                    ),
                              onLockedTap: (slug) => _showLockedScene(
                                trail,
                                slug,
                                currentSlug: currentSlug,
                                plusOpen: plusOpen,
                                accent: modeAccent,
                              ),
                              onPlusTap: (slug) {
                                // A cena em curso tem o botão amarelo: vai
                                // direto à compra. As seguintes explicam.
                                if (slug != currentSlug) {
                                  _showPlusScene(
                                    trail,
                                    slug,
                                    accent: modeAccent,
                                  );
                                  return;
                                }
                                PlusLog.log(
                                  'trava',
                                  'mapa ${trail.slug} · cena $slug: '
                                      'sem Plus, paywall',
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const PaywallScreen(source: 'trail'),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Cena fechada pela ordem: diz qual cena falta e leva até ela (ou à
  /// compra, se a cena em curso pede o Peregrino+).
  void _showLockedScene(
    Trail trail,
    String slug, {
    required String? currentSlug,
    required bool plusOpen,
    required Color? accent,
  }) {
    final missions = [for (final m in trail.modules) ...m.missions];
    final index = missions.indexWhere((m) => m.slug == slug);
    if (index < 0) return;
    final mission = missions[index];
    final current = currentSlug == null
        ? null
        : missions.where((m) => m.slug == currentSlug).firstOrNull;
    final l10n = context.l10n;
    final roman = journeyRomanNumeral(index + 1);
    ActHaptics.tap();
    showPathPreviewSheet(
      context,
      title: mission.localizedTitle,
      description: current == null
          ? l10n.journeyBeyondHorizon
          : l10n.trailMapSceneLockedBody(current.localizedTitle),
      art: TrailArt.ofScene(trail.slug, mission.slug),
      artVeiled: !context.read<ProgressService>().sceneRevealed(mission.slug),
      accent: accent,
      eyebrow: mission.isBoss
          ? l10n.trailMapCrossing
          : '${l10n.commonScene} $roman',
      glyph: CinematicGlyph.lock,
      footer: current == null
          ? null
          : CopperCta(
              label: l10n.trailMapGoToScene(current.localizedTitle),
              expanded: true,
              onTap: () {
                Navigator.of(context).pop();
                if (!plusOpen &&
                    PlusAccess.missionNeedsPlus(trail, current.slug)) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PaywallScreen(source: 'trail'),
                    ),
                  );
                  return;
                }
                Navigator.of(
                  context,
                ).pushNamed('/lesson', arguments: current.slug);
              },
            ),
    );
  }

  /// Cena Peregrino+ que ainda não é a da vez: a folha do Plus.
  void _showPlusScene(Trail trail, String slug, {required Color? accent}) {
    final missions = [for (final m in trail.modules) ...m.missions];
    final index = missions.indexWhere((m) => m.slug == slug);
    if (index < 0) return;
    final mission = missions[index];
    final l10n = context.l10n;
    ActHaptics.tap();
    showPlusLockedSheet(
      context,
      title: mission.localizedTitle,
      description: mission.subtitle.trim().isEmpty
          ? trail.localizedTitle
          : mission.subtitle,
      source: 'trail_sheet',
      art: TrailArt.ofScene(trail.slug, mission.slug),
      artVeiled: !context.read<ProgressService>().sceneRevealed(mission.slug),
      eyebrow: mission.isBoss
          ? l10n.trailMapCrossing
          : '${l10n.commonScene} ${journeyRomanNumeral(index + 1)}',
      accent: accent,
      glyph: CinematicGlyph.lock,
    );
  }

  Future<void> _confirmLeaveTrail(Trail trail) async {
    final leave = await showLeaveTrailSheet(context);
    if (!leave || !mounted) return;

    final progress = context.read<ProgressService>();
    await progress.leaveTrail(
      trailSlug: trail.slug,
      missionSlugs: trail.missionSlugs,
    );
    if (!mounted) return;

    final backend = context.read<BackendService>();
    final league = context.read<LeagueService>();
    await backend.saveNow(progress, LeagueService.weekKey(), league: league);
    if (!mounted) return;
    Navigator.pop(context);
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

  /// Selo de personagem no canto do cartão da etapa que o guarda. Aparece
  /// já ganho, ou apagado quando a cena dele é a próxima.
  Widget? _sealMarkFor(ProgressService progress, Trail trail, TrailModule mod) {
    final seal = CharacterSeals.forTrail(trail.slug);
    if (seal == null) return null;
    if (!mod.missions.any((m) => m.slug == seal.missionSlug)) return null;
    final unlocked = progress.isMissionCompleted(seal.missionSlug);
    if (!unlocked) {
      final next = trail.missionSlugs
          .where((s) => !progress.isMissionCompleted(s))
          .firstOrNull;
      if (next != seal.missionSlug) return null;
    }
    return CharacterSealMark(seal: seal, unlocked: unlocked);
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
    final a = Appearance.of(context);
    final mode = TrailDifficulty.fromId(difficultyId);
    final color = mode != null ? DifficultyVisuals.accentFor(mode) : a.chrome;

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
              color: a.ink(color).withValues(alpha: 0.88),
            ),
          ),
        ],
      ],
    );
  }
}
