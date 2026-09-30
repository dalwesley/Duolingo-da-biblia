import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/difficulty.dart';
import '../services/analytics_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/mode_selector.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';

/// Primeira escolha do modo de estudo — mesma lista da sheet do mapa.
class DifficultyPickerScreen extends StatefulWidget {
  final String trailSlug;
  final VoidCallback onSelected;

  const DifficultyPickerScreen({
    super.key,
    required this.trailSlug,
    required this.onSelected,
  });

  /// Garante um modo na trilha. Se só um estiver liberado, aplica sem UI.
  /// Retorna `false` se o usuário cancelou o picker sem escolher.
  static Future<bool> ensureSelected(
    BuildContext context, {
    required String trailSlug,
  }) async {
    final progress = context.read<ProgressService>();
    final trail = await TrailRepository().getTrailBySlug(trailSlug);
    if (!context.mounted) return false;
    final slugs = trail?.missionSlugs ?? const [];

    final hadStored = progress.hasDifficultyForTrail(trailSlug);
    if (!hadStored) {
      final unlocked = progress.unlockedDifficulties(trailSlug);
      if (unlocked.length <= 1) {
        final id = unlocked.isEmpty
            ? TrailDifficulty.semente.id
            : unlocked.first.id;
        await progress.setTrailDifficulty(trailSlug, id, missionSlugs: slugs);
        AnalyticsService.instance.logDifficultyPick(
          trailSlug: trailSlug,
          difficulty: id,
        );
        return true;
      }

      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (_, _, _) => DifficultyPickerScreen(
            trailSlug: trailSlug,
            onSelected: () => Navigator.of(context).pop(),
          ),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
      if (!context.mounted) return false;
      return progress.hasDifficultyForTrail(trailSlug);
    }

    return true;
  }

  @override
  State<DifficultyPickerScreen> createState() => _DifficultyPickerScreenState();
}

class _DifficultyPickerScreenState extends State<DifficultyPickerScreen>
    with SingleTickerProviderStateMixin {
  List<String> _missionSlugs = const [];
  String _trailTitle = '';
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _load();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final trail = await TrailRepository().getTrailBySlug(widget.trailSlug);
    if (!mounted) return;
    setState(() {
      _missionSlugs = trail?.missionSlugs ?? const [];
      _trailTitle = trail?.title ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

    return Appearance(
      mode: mode,
      style: appearance,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
          body: ImmersiveBackground(
            appearance: appearance,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  AppSpace.md,
                  0,
                  AppSpace.xxl,
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
                      title: context.l10n.modePickerTopBar,
                      onBack: () => Navigator.pop(context),
                      leadingGlyph: CinematicGlyphResolver.forTrail(
                        widget.trailSlug,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _enter,
                      curve: const Interval(0, 0.4, curve: Curves.easeOut),
                    ),
                    child: Column(
                      children: [
                        SectionLabel(
                          context.l10n.modeSheetEyebrow,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpace.sm),
                        Text(
                          context.l10n.modePickerTitle,
                          textAlign: TextAlign.center,
                          style: AppTypography.display(size: 28, height: 1.15),
                        ),
                        if (_trailTitle.isNotEmpty) ...[
                          const SizedBox(height: AppSpace.md),
                          Text(
                            _trailTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.body(
                              size: 13,
                              height: 1.4,
                              color: appearance.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.xxl),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _enter,
                      curve: const Interval(
                        0.2,
                        0.8,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: ModeCarousel(
                      trailSlug: widget.trailSlug,
                      missionSlugs: _missionSlugs,
                      height: 420,
                      onCommitted: (_) => widget.onSelected(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
