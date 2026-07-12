import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/genesis_theme.dart';
import '../utils/trail_progress.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/genesis_trail_scenery.dart';
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

  Future<void> _bootstrap() async {
    final trail = await _repo.getTrailBySlug(widget.slug);
    if (!mounted) return;
    setState(() => _trail = trail);

    if (widget.slug == 'genesis-1-11') {
      final progress = context.read<ProgressService>();
      if (!progress.hasDifficultyForTrail(widget.slug)) {
        await Navigator.of(context).push(
          PageRouteBuilder(
            opaque: true,
            pageBuilder: (_, _, _) => DifficultyPickerScreen(
              trailSlug: widget.slug,
              onSelected: () => Navigator.of(context).pop(),
            ),
            transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
          ),
        );
        if (!mounted) return;
        if (!context.read<ProgressService>().hasDifficultyForTrail(widget.slug)) {
          Navigator.of(context).pop();
          return;
        }
      }
    }

    if (mounted) setState(() => _checkingDifficulty = false);
  }

  bool get _useThematicMap => widget.slug == 'genesis-1-11' || widget.slug == 'exodo';

  int _activeModuleIndex(Trail trail, List<String> completed) {
    for (var i = 0; i < trail.modules.length; i++) {
      final missions = trail.modules[i].missions;
      for (final m in missions) {
        final idx = trail.missionSlugs.indexOf(m.slug);
        final unlocked = idx <= 0 || completed.contains(trail.missionSlugs[idx - 1]);
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
      final target = (160.0 + moduleIndex * 520).clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.animateTo(target, duration: const Duration(milliseconds: 1200), curve: Curves.easeInOutCubic);
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
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
    if (mounted) setState(() {});
  }

  Color _backdropFor(Trail trail, int activeModule) {
    if (!_useThematicMap || trail.modules.isEmpty) return const Color(0xFF070B18);
    final title = trail.modules[activeModule.clamp(0, trail.modules.length - 1)].title;
    return GenesisModuleTheme.forModule(title).sky.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();

    if (_trail == null || _checkingDifficulty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B1D3A),
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    final trail = _trail!;
    final allSlugs = trail.missionSlugs;
    final prog = TrailProgress.getProgress(trail, progress.completedMissions);
    final difficultyId = progress.difficultyForTrail(widget.slug);

    if (allSlugs.isEmpty) {
      return Scaffold(
        appBar: TopBar(title: trail.title, onBack: () => Navigator.pop(context)),
        body: Center(
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
                const Text('Em breve', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(trail.description, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      );
    }

    final activeModule = _activeModuleIndex(trail, progress.completedMissions);
    _maybeScrollToActive(activeModule);
    final backdrop = _backdropFor(trail, activeModule);
    final topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
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
              padding: EdgeInsets.only(top: topInset + 88, bottom: 64),
              children: [
                if (_useThematicMap)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: _TrailJourneyIntro(
                      trailTitle: trail.title,
                      done: prog.done,
                      total: prog.total,
                      difficultyLabel: widget.slug == 'genesis-1-11'
                          ? _difficultyLabel(difficultyId ?? 'semente')
                          : null,
                      onDifficultyTap: widget.slug == 'genesis-1-11' ? _changeDifficulty : null,
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
                ...trail.modules.asMap().entries.map((entry) {
                  final mi = entry.key;
                  final mod = entry.value;
                  final start = trail.modules.take(mi).fold(0, (sum, m) => sum + m.missions.length);
                  final moduleTheme = _useThematicMap ? GenesisModuleTheme.forModule(mod.title) : null;
                  final isActive = mi == activeModule;
                  final modDone = mod.missions.where((m) => progress.completedMissions.contains(m.slug)).length;

                  final path = TrailMapPath(
                    missions: mod.missions,
                    startGlobalIndex: start,
                    allSlugs: allSlugs,
                    completedMissions: progress.completedMissions,
                    theme: moduleTheme,
                    onMissionTap: (slug) => Navigator.of(context).pushNamed('/lesson', arguments: slug),
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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _CinematicChrome(
                topInset: topInset,
                eyebrow: _useThematicMap && trail.modules.isNotEmpty
                    ? 'CAPÍTULO ${_roman(activeModule + 1)}'
                    : null,
                title: _useThematicMap && trail.modules.isNotEmpty
                    ? trail.modules[activeModule.clamp(0, trail.modules.length - 1)].title
                    : trail.title,
                glyph: _useThematicMap && trail.modules.isNotEmpty
                    ? CinematicGlyphResolver.forModule(
                        trail.modules[activeModule.clamp(0, trail.modules.length - 1)].title,
                      )
                    : CinematicGlyphResolver.forTrail(trail.slug),
                xp: progress.xp,
                streak: progress.streak,
                progressLabel: '${prog.done}/${prog.total}',
                onBack: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _difficultyLabel(String id) {
    return switch (id) {
      'semente' => 'Semente',
      'caminhada' => 'Caminhada',
      'profundezas' => 'Profundezas',
      _ => id,
    };
  }

  static String _roman(int n) {
    const map = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
    if (n >= 1 && n <= map.length) return map[n - 1];
    return '$n';
  }
}

/// App bar sólido — vidro fosco + borda inferior para não se misturar ao capítulo.
class _CinematicChrome extends StatelessWidget {
  final double topInset;
  final String? eyebrow;
  final String title;
  final CinematicGlyph glyph;
  final int xp;
  final int streak;
  final String progressLabel;
  final VoidCallback onBack;

  const _CinematicChrome({
    required this.topInset,
    this.eyebrow,
    required this.title,
    required this.glyph,
    required this.xp,
    required this.streak,
    required this.progressLabel,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: EdgeInsets.fromLTRB(10, topInset + 8, 12, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF070B18).withValues(alpha: 0.82),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 4),
              CinematicIcon(glyph: glyph, size: 40, glowing: false),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (eyebrow != null)
                      Text(
                        eyebrow!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                          color: AppColors.accent.withValues(alpha: 0.9),
                        ),
                      ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _ChromeStat(
                icon: Icons.auto_awesome_rounded,
                value: '$xp',
                tint: AppColors.accent,
              ),
              const SizedBox(width: 6),
              _ChromeStat(
                icon: Icons.flag_rounded,
                value: progressLabel,
                tint: Colors.white70,
              ),
              const SizedBox(width: 6),
              _ChromeStat(
                icon: Icons.local_fire_department_rounded,
                value: '$streak',
                tint: AppColors.streak,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChromeStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color tint;

  const _ChromeStat({required this.icon, required this.value, required this.tint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: tint),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
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

  const _GenericTrailHero({required this.slug, required this.color, required this.done, required this.total});

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
                Text('$done de $total missões', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.12),
                    color: color,
                  ),
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

  const _GenericModuleHeader({required this.index, required this.glyph, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CinematicIcon(glyph: glyph, size: 28, glowing: false),
          const SizedBox(width: 8),
          Text('Seção $index · $title', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }
}
