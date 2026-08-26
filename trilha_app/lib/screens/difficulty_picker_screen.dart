import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/difficulty.dart';
import '../services/analytics_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/difficulty_visuals.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';

/// Escolha cinematográfica de dificuldade ao iniciar a trilha de Gênesis.
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
    if (progress.hasDifficultyForTrail(trailSlug)) return true;

    final unlocked = progress.unlockedDifficulties(trailSlug);
    if (unlocked.length <= 1) {
      final id = unlocked.isEmpty
          ? TrailDifficulty.semente.id
          : unlocked.first.id;
      final trail = await TrailRepository().getTrailBySlug(trailSlug);
      if (!context.mounted) return false;
      await progress.setTrailDifficulty(
        trailSlug,
        id,
        missionSlugs: trail?.missionSlugs ?? const [],
      );
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
    return context.read<ProgressService>().hasDifficultyForTrail(trailSlug);
  }

  @override
  State<DifficultyPickerScreen> createState() => _DifficultyPickerScreenState();
}

class _DifficultyPickerScreenState extends State<DifficultyPickerScreen>
    with SingleTickerProviderStateMixin {
  List<DifficultyMeta>? _items;
  TrailDifficulty? _hover;
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
    final items = await QuestionBank.instance.getDifficulties();
    if (mounted) setState(() => _items = items);
  }

  Future<void> _choose(DifficultyMeta meta) async {
    final progress = context.read<ProgressService>();
    if (!progress.isDifficultyUnlocked(widget.trailSlug, meta.difficulty)) {
      HapticFeedback.selectionClick();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Conclua o modo anterior para liberar ${meta.label}.',
            style: AppTypography.body(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    final trail = await TrailRepository().getTrailBySlug(widget.trailSlug);
    if (!mounted) return;
    await progress.setTrailDifficulty(
      widget.trailSlug,
      meta.difficulty.id,
      missionSlugs: trail?.missionSlugs ?? const [],
    );
    AnalyticsService.instance.logDifficultyPick(
      trailSlug: widget.trailSlug,
      difficulty: meta.difficulty.id,
    );
    if (!mounted) return;
    widget.onSelected();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  AppSpace.md,
                  AppSpace.screen,
                  AppSpace.xxl,
                ),
                child: items == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: appearance.cardFillSoft,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.sm,
                                  ),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: appearance.text,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpace.sm),
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _enter,
                              curve: const Interval(
                                0,
                                0.4,
                                curve: Curves.easeOut,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Antes de partir',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.label(
                                    size: 13,
                                    letterSpacing: 1.4,
                                    color: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(height: AppSpace.sm),
                                Text(
                                  'Escolha o modo\nde dificuldade',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.display(
                                    size: 28,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: AppSpace.md),
                                Text(
                                  'Observação, Compreensão ou Interpretação —\noperações diferentes sobre o mesmo texto.\nConclua um modo para liberar o próximo.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.body(
                                    size: 13,
                                    height: 1.4,
                                    color: appearance.textMuted(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpace.xxl),
                          Expanded(
                            child: ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpace.section),
                              itemBuilder: (context, i) {
                                final meta = items[i];
                                final progress = context
                                    .watch<ProgressService>();
                                final unlocked = progress.isDifficultyUnlocked(
                                  widget.trailSlug,
                                  meta.difficulty,
                                );
                                final cleared = progress.hasClearedMode(
                                  widget.trailSlug,
                                  meta.difficulty.id,
                                );
                                final currentId = progress.difficultyForTrail(
                                  widget.trailSlug,
                                );
                                final start = 0.15 + i * 0.12;
                                final curve = CurvedAnimation(
                                  parent: _enter,
                                  curve: Interval(
                                    start,
                                    (start + 0.45).clamp(0, 1),
                                    curve: Curves.easeOutCubic,
                                  ),
                                );
                                return FadeTransition(
                                  opacity: curve,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.12),
                                      end: Offset.zero,
                                    ).animate(curve),
                                    child: Opacity(
                                      opacity: unlocked ? 1 : 0.48,
                                      child: _DifficultyCard(
                                        meta: meta,
                                        selected: _hover == meta.difficulty,
                                        current:
                                            currentId == meta.difficulty.id,
                                        locked: !unlocked,
                                        cleared: cleared,
                                        onTap: () => _choose(meta),
                                        onHighlight: () {
                                          if (unlocked) {
                                            setState(
                                              () => _hover = meta.difficulty,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final DifficultyMeta meta;
  final bool selected;
  final bool current;
  final bool locked;
  final bool cleared;
  final VoidCallback onTap;
  final VoidCallback onHighlight;

  const _DifficultyCard({
    required this.meta,
    required this.selected,
    required this.current,
    required this.locked,
    required this.cleared,
    required this.onTap,
    required this.onHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final color = DifficultyVisuals.accentFor(meta.difficulty);
    final onSky = DifficultyVisuals.onSky(color);
    final ink = DifficultyVisuals.inkOn(meta.difficulty);
    final lit = (current || selected) && !locked;
    final xpLabel = meta.stepsMultiplier == 1
        ? 'Passos padrão'
        : '+${((meta.stepsMultiplier - 1) * 100).round()}% passos';
    final titleColor = locked ? a.textMuted(0.62) : onSky;
    final railColor = locked ? color.withValues(alpha: 0.35) : onSky;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onHighlightChanged: (v) {
          if (v) onHighlight();
        },
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: locked
                  ? [
                      DifficultyVisuals.chipFill(color, alpha: 0.10),
                      Colors.white.withValues(alpha: 0.03),
                    ]
                  : [
                      DifficultyVisuals.chipFill(
                        color,
                        alpha: lit ? 0.52 : 0.36,
                      ),
                      DifficultyVisuals.chipFill(
                        color,
                        alpha: lit ? 0.22 : 0.14,
                      ),
                      Colors.white.withValues(alpha: 0.04),
                    ],
              stops: locked ? null : const [0, 0.42, 1],
            ),
            border: Border.all(
              color: (locked ? color : onSky).withValues(
                alpha: locked ? 0.28 : (lit ? 1 : 0.78),
              ),
              width: lit ? 2.4 : 1.8,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 8,
                child: ColoredBox(color: railColor),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.xl + 6,
                  AppSpace.xl,
                  AppSpace.xl,
                  AppSpace.xl,
                ),
                child: Row(
                  children: [
                    CinematicIcon(
                      glyph: locked
                          ? CinematicGlyph.lock
                          : DifficultyVisuals.glyphFor(meta.difficulty),
                      size: 52,
                      accent: onSky,
                      glowing: lit,
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppSpace.sm,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                meta.label,
                                style: AppTypography.title(
                                  size: 20,
                                  color: titleColor,
                                ),
                              ),
                              if (current && !locked)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpace.sm + 2,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.pill,
                                    ),
                                  ),
                                  child: Text(
                                    'Modo atual',
                                    style: AppTypography.label(
                                      size: 10,
                                      color: ink,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                )
                              else if (cleared)
                                Text(
                                  'Concluído',
                                  style: AppTypography.label(
                                    size: 10,
                                    color: AppColors.teal,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              if (locked)
                                Text(
                                  'Bloqueado',
                                  style: AppTypography.label(
                                    size: 10,
                                    color: a.textMuted(0.54),
                                    letterSpacing: 0.4,
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpace.sm,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.28),
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.pill,
                                    ),
                                  ),
                                  child: Text(
                                    xpLabel,
                                    style: AppTypography.label(
                                      size: 10,
                                      color: color,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpace.xs),
                          Text(
                            locked ? 'Conclua o modo anterior' : meta.subtitle,
                            style: AppTypography.title(
                              size: 12,
                              color: locked ? a.textMuted(0.55) : color,
                            ),
                          ),
                          const SizedBox(height: AppSpace.xs),
                          Text(
                            locked
                                ? 'Termine a trilha no modo atual para liberar.'
                                : meta.description,
                            style: AppTypography.body(
                              size: 13,
                              height: 1.35,
                              color: locked
                                  ? a.textMuted(0.5)
                                  : a.text.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    CinematicIcon(
                      glyph: locked ? CinematicGlyph.lock : CinematicGlyph.rise,
                      size: 20,
                      accent: locked ? color : onSky,
                      framed: false,
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
}
