import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/difficulty.dart';
import '../models/pilgrim_medals.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/difficulty_trails.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/genesis_theme.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/genesis_trail_scenery.dart';
import '../widgets/immersive_background.dart';
import '../widgets/medal_unlock_sheet.dart';
import '../widgets/milestone_chests.dart';
import '../widgets/top_bar.dart';
import '../widgets/trail_map_path.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = (160.0 + moduleIndex * 520).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Future<void> _changeDifficulty() async {
    final progress = context.read<ProgressService>();
    // Sem escolha real (só Semente), não abre o picker.
    if (!progress.hasDifficultyChoice(widget.slug)) return;
    final before = progress.difficultyForTrail(widget.slug);
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, _, _) => DifficultyPickerScreen(
          trailSlug: widget.slug,
          onSelected: () => Navigator.of(context).pop(),
        ),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
    if (!mounted) return;
    final after = progress.difficultyForTrail(widget.slug);
    if (after != null && after != before) {
      HapticFeedback.mediumImpact();
    }
    setState(() {});
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
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      );
    }

    final trail = _trail!;
    final allSlugs = trail.missionSlugs;
    final live = TrailProgress.getLiveProgress(
      trail,
      progress.completedMissions,
    );
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
                    dark: true,
                    title: trail.title,
                    subtitle: 'Em breve',
                    onBack: () => Navigator.pop(context),
                    leadingGlyph: CinematicGlyphResolver.forTrail(trail.slug),
                    chromeAccent: TrailVisuals.forTrail(trail).accent,
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
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpace.xxxl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CinematicIcon(
                                glyph: CinematicGlyphResolver.forTrail(
                                  trail.slug,
                                ),
                                size: 72,
                                accent: AppTheme.parseHex(trail.color),
                              ),
                              const SizedBox(height: AppSpace.section),
                              Text(
                                'Em breve',
                                style: AppTypography.title(size: 24),
                              ),
                              const SizedBox(height: AppSpace.sm),
                              Text(
                                trail.description,
                                textAlign: TextAlign.center,
                                style: AppTypography.body(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
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

    final activeModule = _activeModuleIndex(trail, progress.completedMissions);
    _maybeScrollToActive(activeModule);
    final mode = progress.settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

    final eyebrow = _useThematicMap && trail.modules.isNotEmpty
        ? 'CENA ${_roman(activeModule + 1)}'
        : null;
    final headerTitle = _useThematicMap && trail.modules.isNotEmpty
        ? trail.modules[activeModule.clamp(0, trail.modules.length - 1)].title
        : trail.title;
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
                    dark: true,
                    title: headerTitle,
                    subtitle:
                        eyebrow ??
                        (_fromBank
                            ? '$modeName · ${prog.done}/${prog.total} missões'
                            : '${prog.done}/${prog.total} missões'),
                    onBack: () => Navigator.pop(context),
                    leadingGlyph: headerGlyph,
                    chromeAccent: TrailVisuals.forTrail(trail).accent,
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(0, AppSpace.md, 0, 64),
                    children: [
                      if (replayHint != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.screen,
                            0,
                            AppSpace.screen,
                            0,
                          ),
                          child: _ModeReplayBanner(
                            text: replayHint,
                            difficultyId: difficultyId,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpace.screen,
                          AppSpace.md,
                          AppSpace.screen,
                          AppSpace.md,
                        ),
                        child: _TrailJourneyIntro(
                          trailTitle: trail.title,
                          done: prog.done,
                          total: prog.total,
                          difficultyId: _fromBank
                              ? (difficultyId ?? TrailDifficulty.semente.id)
                              : null,
                          progressCaption:
                              '$modeName · ${prog.done} de ${prog.total} passos',
                          onDifficultyTap:
                              _fromBank &&
                                  progress.hasDifficultyChoice(widget.slug)
                              ? _changeDifficulty
                              : null,
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpace.screen,
                          AppSpace.xs,
                          AppSpace.screen,
                          AppSpace.sm,
                        ),
                        child: MilestoneChestsCard(
                          trailSlug: trail.slug,
                          done: prog.done,
                          total: prog.total,
                        ),
                      ),
                      ...trail.modules.asMap().entries.map((entry) {
                        final mi = entry.key;
                        final mod = entry.value;
                        final start = trail.modules
                            .take(mi)
                            .fold(0, (sum, m) => sum + m.missions.length);
                        final moduleTheme = GenesisModuleTheme.forModule(
                          mod.title,
                          realm: _realm,
                          trailSlug: trail.slug,
                        );
                        final isActive = mi == activeModule;
                        final modDone = mod.missions
                            .where(
                              (m) =>
                                  progress.completedMissions.contains(m.slug),
                            )
                            .length;

                        final path = TrailMapPath(
                          missions: mod.missions,
                          startGlobalIndex: start,
                          allSlugs: allSlugs,
                          completedMissions: progress.completedMissions,
                          theme: moduleTheme,
                          modeAccent: modeAccent,
                          onMissionTap: (slug) => Navigator.of(
                            context,
                          ).pushNamed('/lesson', arguments: slug),
                        );

                        return GenesisModuleScenery(
                          theme: moduleTheme,
                          moduleTitle: mod.title,
                          sectionIndex: mi + 1,
                          isActiveChapter: isActive,
                          missionsDone: modDone,
                          missionsTotal: mod.missions.length,
                          modeAccent: modeAccent,
                          child: path,
                        );
                      }),
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
            HapticFeedback.selectionClick();
            final vaults = PilgrimMedals.evaluateVaults(
              profile: profile,
              catalog: [trail],
              ctx: ctx,
            );
            for (final vault in vaults) {
              if (vault.vault.id != PilgrimMedalCatalog.trailVaultId(trail.slug)) {
                continue;
              }
              if (vault.tracks.isEmpty) return;
              showTrackDetailSheet(context, vault.tracks.first);
              return;
            }
          },
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Text(
              proximity.actionMessage,
              style: AppTypography.label(
                size: 11,
                letterSpacing: 0.2,
                color: accent,
              ),
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

  const _ModeReplayBanner({required this.text, this.difficultyId});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final mode =
        TrailDifficulty.fromId(difficultyId) ?? TrailDifficulty.semente;
    final color = DifficultyVisuals.accentFor(mode);
    final onSky = DifficultyVisuals.onSky(color);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.sm + 2,
      ),
      decoration: BoxDecoration(
        color: DifficultyVisuals.chipFill(color, alpha: 0.22),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: onSky.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          CinematicIcon(
            glyph: DifficultyVisuals.glyphFor(mode),
            size: 18,
            accent: onSky,
            framed: false,
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: a.text,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailJourneyIntro extends StatelessWidget {
  final String trailTitle;
  final int done;
  final int total;
  final String? difficultyId;
  final String? progressCaption;
  final VoidCallback? onDifficultyTap;

  const _TrailJourneyIntro({
    required this.trailTitle,
    required this.done,
    required this.total,
    this.difficultyId,
    this.progressCaption,
    this.onDifficultyTap,
  });

  @override
  Widget build(BuildContext context) {
    if (difficultyId == null && progressCaption == null) {
      return const SizedBox.shrink();
    }
    final a = Appearance.of(context);
    final mode = TrailDifficulty.fromId(difficultyId);
    final color = mode != null
        ? DifficultyVisuals.accentFor(mode)
        : AppColors.accent;
    final onSky = DifficultyVisuals.onSky(color);
    final glyph = mode != null
        ? DifficultyVisuals.glyphFor(mode)
        : CinematicGlyph.seed;
    final label = mode != null ? 'Modo ${mode.labelPt}' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onDifficultyTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.sm + 2,
                  AppSpace.sm - 1,
                  AppSpace.md,
                  AppSpace.sm - 1,
                ),
                decoration: BoxDecoration(
                  color: DifficultyVisuals.chipFill(color),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: onSky, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CinematicIcon(
                      glyph: glyph,
                      size: 22,
                      accent: onSky,
                      framed: false,
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Text(
                      label,
                      style: AppTypography.label(
                        size: 12,
                        color: onSky,
                        letterSpacing: 0.4,
                      ),
                    ),
                    if (onDifficultyTap != null)
                      Text(
                        '  ·  mudar',
                        style: AppTypography.label(
                          size: 11,
                          color: a.text.withValues(alpha: 0.72),
                          letterSpacing: 0.3,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        if (progressCaption != null) ...[
          if (label != null) const SizedBox(height: AppSpace.sm),
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
