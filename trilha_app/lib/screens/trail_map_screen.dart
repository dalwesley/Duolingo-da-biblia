import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../models/trail_catalog.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/difficulty_trails.dart';
import '../utils/genesis_theme.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/genesis_trail_scenery.dart';
import '../widgets/immersive_background.dart';
import '../widgets/milestone_chests.dart';
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

  Future<void> _bootstrap() async {
    final trail = await _repo.getTrailBySlug(widget.slug);
    if (!mounted) return;
    setState(() => _trail = trail);

    if (trailUsesDifficultyBank(widget.slug)) {
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
    if (mounted) setState(() {});
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
    final live = TrailProgress.getLiveProgress(trail, progress.completedMissions);
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
            child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpace.screen,
              MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
              AppSpace.screen,
              32,
            ),
            children: [
              TopBar(
                inline: true,
                immersive: true,
                dark: true,
                title: trail.title,
                subtitle: 'Em breve',
                onBack: () => Navigator.pop(context),
                leadingGlyph: CinematicGlyphResolver.forTrail(trail.slug),
                chromeAccent: TrailVisuals.forTrail(trail).accent,
              ),
              const SizedBox(height: AppSpace.xxxl),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.xxxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CinematicIcon(
                        glyph: CinematicGlyphResolver.forTrail(trail.slug),
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
                        style: AppTypography.body(color: AppColors.textMuted),
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

    final activeModule = _activeModuleIndex(trail, progress.completedMissions);
    _maybeScrollToActive(activeModule);
    final mode = progress.settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

    final eyebrow = _useThematicMap && trail.modules.isNotEmpty
        ? 'CENA ${_roman(activeModule + 1)}'
        : null;
    final headerTitle = _useThematicMap && trail.modules.isNotEmpty
        ? trail
              .modules[activeModule.clamp(0, trail.modules.length - 1)]
              .title
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
            child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  0,
                  MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
                  0,
                  64,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.screen,
                    ),
                    child: TopBar(
                      inline: true,
                      immersive: true,
                      dark: true,
                      title: headerTitle,
                      subtitle: eyebrow ??
                          (trailUsesDifficultyBank(widget.slug)
                              ? '$modeName · ${prog.done}/${prog.total} missões'
                              : '${prog.done}/${prog.total} missões'),
                      onBack: () => Navigator.pop(context),
                      leadingGlyph: headerGlyph,
                      chromeAccent: TrailVisuals.forTrail(trail).accent,
                    ),
                  ),
                  if (replayHint != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.screen,
                        AppSpace.sm,
                        AppSpace.screen,
                        0,
                      ),
                      child: _ModeReplayBanner(text: replayHint),
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
                      difficultyLabel: trailUsesDifficultyBank(widget.slug)
                          ? _difficultyLabel(difficultyId ?? 'semente')
                          : null,
                      progressCaption:
                          '$modeName · ${prog.done} de ${prog.total} passos',
                      onDifficultyTap:
                          trailUsesDifficultyBank(widget.slug) &&
                                  progress.hasDifficultyChoice(widget.slug)
                              ? _changeDifficulty
                              : null,
                    ),
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
                      child: path,
                    );
                  }),
                ],
            ),
          ),
        ),
      ),
    );
  }

  String _difficultyLabel(String id) {
    return switch (id) {
      'semente' => 'Modo Semente',
      'caminhada' => 'Modo Rota',
      'profundezas' => 'Modo Profundezas',
      _ => id,
    };
  }

  static String _roman(int n) {
    const map = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
    if (n >= 1 && n <= map.length) return map[n - 1];
    return '$n';
  }
}

class _ModeReplayBanner extends StatelessWidget {
  final String text;

  const _ModeReplayBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppMetrics.accentBorder(alpha: 0.45)),
      ),
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.path,
            size: 18,
            accent: AppColors.accent,
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
  final String? difficultyLabel;
  final String? progressCaption;
  final VoidCallback? onDifficultyTap;

  const _TrailJourneyIntro({
    required this.trailTitle,
    required this.done,
    required this.total,
    this.difficultyLabel,
    this.progressCaption,
    this.onDifficultyTap,
  });

  @override
  Widget build(BuildContext context) {
    if (difficultyLabel == null && progressCaption == null) {
      return const SizedBox.shrink();
    }
    final a = Appearance.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (difficultyLabel != null)
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onDifficultyTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.md,
                  vertical: AppSpace.sm - 1,
                ),
                decoration: BoxDecoration(
                  color: a.cardFill,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: AppMetrics.accentBorder(alpha: 0.4)),
                  boxShadow: AppMetrics.cardShadow(),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      difficultyLabel!,
                      style: AppTypography.label(
                        size: 12,
                        color: a.text,
                        letterSpacing: 0.4,
                      ),
                    ),
                    if (onDifficultyTap != null)
                      Text(
                        '  ·  mudar',
                        style: AppTypography.label(
                          size: 11,
                          color: AppColors.accent,
                          letterSpacing: 0.3,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        if (progressCaption != null) ...[
          if (difficultyLabel != null) const SizedBox(height: AppSpace.sm),
          Text(
            progressCaption!,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w700,
              color: a.textMuted(0.55),
            ),
          ),
        ],
      ],
    );
  }
}
