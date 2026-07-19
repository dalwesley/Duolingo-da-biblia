import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../models/trail_catalog.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_trails.dart';
import '../utils/genesis_theme.dart';
import '../utils/trail_progress.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/genesis_trail_scenery.dart';
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
      final progress = context.read<ProgressService>();
      if (!progress.hasDifficultyForTrail(widget.slug)) {
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
        if (!context.read<ProgressService>().hasDifficultyForTrail(
          widget.slug,
        )) {
          Navigator.of(context).pop();
          return;
        }
      }
    }

    if (mounted) setState(() => _checkingDifficulty = false);
  }

  bool get _useThematicMap =>
      widget.slug == 'genesis-1-11' ||
      widget.slug == 'exodo' ||
      widget.slug == 'evangelhos' ||
      widget.slug == 'atos' ||
      widget.slug == 'apocalipse';

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

  Color _backdropFor(Trail trail, int activeModule) {
    if (!_useThematicMap || trail.modules.isEmpty) {
      return RealmVisualsFallback.atSky.first;
    }
    final title =
        trail.modules[activeModule.clamp(0, trail.modules.length - 1)].title;
    return GenesisModuleTheme.forModule(
      title,
      realm: TrailRealm.fromId(trail.realmId),
      trailSlug: trail.slug,
    ).sky.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();

    if (_trail == null || _checkingDifficulty) {
      final loadingBg = _trail != null
          ? GenesisModuleTheme.forModule(
              _trail!.modules.isNotEmpty ? _trail!.modules.first.title : '',
              realm: TrailRealm.fromId(_trail!.realmId),
              trailSlug: _trail!.slug,
            ).sky.colors.first
          : RealmVisualsFallback.atSky.first;
      return Scaffold(
        backgroundColor: loadingBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final trail = _trail!;
    final allSlugs = trail.missionSlugs;
    final prog = TrailProgress.getProgress(trail, progress.completedMissions);
    final difficultyId = progress.difficultyForTrail(widget.slug);

    if (allSlugs.isEmpty) {
      return Appearance(
        mode: progress.settings.appearanceMode,
        style: AppearanceStyle.resolve(progress.settings.appearanceMode),
        child: Scaffold(
          backgroundColor: AppColors.night,
          body: ListView(
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
              ),
              const SizedBox(height: 48),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CinematicIcon(
                        glyph: CinematicGlyphResolver.forTrail(trail.slug),
                        size: 72,
                        accent: AppTheme.parseHex(trail.color),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Em breve',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        trail.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final activeModule = _activeModuleIndex(trail, progress.completedMissions);
    _maybeScrollToActive(activeModule);
    final backdrop = _backdropFor(trail, activeModule);
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
          backgroundColor: backdrop,
          body: Stack(
            children: [
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        backdrop,
                        Color.lerp(backdrop, const Color(0xFF05040A), 0.55)!,
                        const Color(0xFF05040A),
                      ],
                    ),
                  ),
                ),
              ),
              ListView(
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
                      subtitle:
                          eyebrow ?? '${prog.done}/${prog.total} missões',
                      onBack: () => Navigator.pop(context),
                      leadingGlyph: headerGlyph,
                    ),
                  ),
                  if (_useThematicMap)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: _TrailJourneyIntro(
                        trailTitle: trail.title,
                        done: prog.done,
                        total: prog.total,
                        difficultyLabel: trailUsesDifficultyBank(widget.slug)
                            ? _difficultyLabel(difficultyId ?? 'semente')
                            : null,
                        onDifficultyTap: trailUsesDifficultyBank(widget.slug)
                            ? _changeDifficulty
                            : null,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _GenericTrailHero(
                        slug: trail.slug,
                        color: AppTheme.parseHex(trail.color),
                        done: prog.done,
                        total: prog.total,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
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
                    final moduleTheme = _useThematicMap
                        ? GenesisModuleTheme.forModule(
                            mod.title,
                            realm: _realm,
                            trailSlug: trail.slug,
                          )
                        : null;
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

                    if (_useThematicMap && moduleTheme != null) {
                      return GenesisModuleScenery(
                        theme: moduleTheme,
                        moduleIcon: mod.icon,
                        moduleTitle: mod.title,
                        sectionIndex: mi + 1,
                        isActiveChapter: isActive,
                        missionsDone: modDone,
                        missionsTotal: mod.missions.length,
                        child: path,
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _GenericModuleHeader(
                            index: mi + 1,
                            title: mod.title,
                            glyph: CinematicGlyphResolver.forModule(mod.title),
                          ),
                          path,
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _difficultyLabel(String id) {
    return switch (id) {
      'semente' => 'Modo Semente',
      'caminhada' => 'Modo Caminhada',
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

class _TrailJourneyIntro extends StatelessWidget {
  final String trailTitle;
  final int done;
  final int total;
  final String? difficultyLabel;
  final VoidCallback? onDifficultyTap;

  const _TrailJourneyIntro({
    required this.trailTitle,
    required this.done,
    required this.total,
    this.difficultyLabel,
    this.onDifficultyTap,
  });

  @override
  Widget build(BuildContext context) {
    if (difficultyLabel == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onDifficultyTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                difficultyLabel!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '  ·  mudar',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenericTrailHero extends StatelessWidget {
  final String slug;
  final Color color;
  final int done;
  final int total;

  const _GenericTrailHero({
    required this.slug,
    required this.color,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? done / total : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyphResolver.forTrail(slug),
            size: 56,
            accent: color,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$done de $total missões',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                AppProgressBar(
                  value: pct,
                  color: color,
                  trackColor: color.withValues(alpha: 0.12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenericModuleHeader extends StatelessWidget {
  final int index;
  final CinematicGlyph glyph;
  final String title;

  const _GenericModuleHeader({
    required this.index,
    required this.glyph,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CinematicIcon(glyph: glyph, size: 28, glowing: false),
          const SizedBox(width: 8),
          Text(
            'Cena $index · $title',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
