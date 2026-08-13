import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/realm_visuals.dart';
import '../utils/trail_progress.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/ui_primitives.dart';
import 'realm_journey_screen.dart';

/// Seleção de trilhas — cada reino é um caminho cinematográfico.
class TrilhasScreen extends StatefulWidget {
  final TrailRepository repo;
  final bool asPushedPage;
  final Widget? topBar;

  /// Quando false (aba oculta no IndexedStack), pausa animações dos portais.
  final bool portalsActive;

  const TrilhasScreen({
    super.key,
    required this.repo,
    this.asPushedPage = false,
    this.topBar,
    this.portalsActive = true,
  });

  @override
  State<TrilhasScreen> createState() => _TrilhasScreenState();
}

class _TrilhasScreenState extends State<TrilhasScreen>
    with SingleTickerProviderStateMixin {
  List<Trail>? _trails;
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _load();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final trails = await widget.repo.getTrails();
    if (mounted) setState(() => _trails = trails);
  }

  Widget _reveal(int index, Widget child) {
    if (_enter.isCompleted) return child;
    final start = (0.08 * index).clamp(0.0, 0.55);
    final end = (start + 0.42).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  void _openRealm(TrailRealm realm) {
    HapticFeedback.mediumImpact();
    final trails = _trails!;
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: RealmJourneyScreen(realm: realm, allTrails: trails),
          );
        },
      ),
    );
  }

  void _showTeologiaSoonSheet() {
    HapticFeedback.selectionClick();
    final visuals = RealmVisuals.of(TrailRealm.teologia);
    final a = Appearance.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: a.cardFill,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpace.xxl,
            AppSpace.lg,
            AppSpace.xxl,
            AppSpace.xxl + MediaQuery.of(ctx).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpace.xxl),
              Text(
                'Teologia',
                style: AppTypography.display(size: 26, color: a.text),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                'Hermenêutica, línguas originais e dogmática — em preparação.',
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  size: 14,
                  height: 1.4,
                  color: a.textMuted(0.72),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                'Em breve',
                style: AppTypography.label(
                  size: 12,
                  letterSpacing: 1.2,
                  color: visuals.accent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _realmPortal({
    required int revealIndex,
    required TrailRealm realm,
    required List<Trail> trails,
    required ProgressService progress,
    bool locked = false,
    VoidCallback? onTapOverride,
  }) {
    final realmTrails =
        trails.where((t) => TrailRealm.fromId(t.realmId) == realm).toList();
    final unlocked = realmTrails
        .where(
          (t) =>
              TrailProgress.isTrailUnlocked(
                t,
                trails,
                progress.completedMissions,
                clearedTrailModes: progress.clearedTrailModes,
              ) &&
              t.missionSlugs.isNotEmpty &&
              !t.comingSoon,
        )
        .length;
    final completed = realmTrails
        .where(
          (t) => TrailProgress.isTrailCompleted(t, progress.completedMissions),
        )
        .length;

    return _reveal(
      revealIndex,
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpace.section),
        child: _RealmPortal(
          realm: realm,
          trailCount: realmTrails.length,
          unlockedCount: unlocked,
          completedCount: completed,
          animate: widget.portalsActive && !locked,
          locked: locked,
          onTap: onTapOverride ?? () => _openRealm(realm),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final topInset = MediaQuery.viewPaddingOf(context).top;

    if (_trails == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    final trails = _trails!;

    final topPad = widget.topBar != null
        ? topInset + AppSpace.sm
        : widget.asPushedPage
        ? AppSpace.md
        : AppSpace.sm;
    final bottomPad = widget.asPushedPage
        ? 32 + MediaQuery.viewPaddingOf(context).bottom
        : scrollPaddingBelowNav(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        topPad,
        AppSpace.screen,
        bottomPad,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        if (widget.topBar != null) ...[
          widget.topBar!,
          const SizedBox(height: AppSpace.afterTopBar),
        ],
        ...TrailRealm.values
            .where((r) => r != TrailRealm.teologia)
            .toList()
            .asMap()
            .entries
            .map(
              (e) => _realmPortal(
                revealIndex: (widget.asPushedPage ? 0 : 1) + e.key,
                realm: e.value,
                trails: trails,
                progress: progress,
              ),
            ),
        _reveal(
          (widget.asPushedPage ? 0 : 1) +
              TrailRealm.values.length -
              1,
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpace.section),
            child: _ComingSoonPortal(),
          ),
        ),
        _realmPortal(
          revealIndex: (widget.asPushedPage ? 0 : 1) + TrailRealm.values.length,
          realm: TrailRealm.teologia,
          trails: trails,
          progress: progress,
          locked: true,
          onTapOverride: _showTeologiaSoonSheet,
        ),
      ],
    );
  }
}

/// Placeholder apagado para trilhas futuras.
class _ComingSoonPortal extends StatelessWidget {
  const _ComingSoonPortal();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final sealSize = _portalSealSize(context);
    return Opacity(
      opacity: 0.42,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: a.cardBorder, width: 1.2),
          color: a.cardFill,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: sealSize,
                height: sealSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: a.cardFillSoft,
                  border: Border.all(color: a.cardBorder),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: sealSize * 0.48,
                  color: a.textMuted(0.38),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                'Em breve…',
                textAlign: TextAlign.center,
                style: AppTypography.display(
                  size: 28,
                  color: a.textMuted(0.45),
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const double _kPortalSealSize = 84;

double _portalSealSize(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(1);
  if (scale <= 1.05) return _kPortalSealSize;
  // Libera espaço vertical quando a fonte sobe — evita card desproporcional.
  return (_kPortalSealSize / scale).clamp(64.0, _kPortalSealSize);
}

class _RealmPortal extends StatefulWidget {
  final TrailRealm realm;
  final int trailCount;
  final int unlockedCount;
  final int completedCount;
  final bool animate;
  final bool locked;
  final VoidCallback onTap;

  const _RealmPortal({
    required this.realm,
    required this.trailCount,
    required this.unlockedCount,
    required this.completedCount,
    required this.animate,
    this.locked = false,
    required this.onTap,
  });

  @override
  State<_RealmPortal> createState() => _RealmPortalState();
}

class _RealmPortalState extends State<_RealmPortal> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final visuals = RealmVisuals.of(widget.realm);
    final hasProgress = widget.unlockedCount > 0;
    final a = Appearance.of(context);
    final sealSize = _portalSealSize(context);

    return Opacity(
      opacity: widget.locked ? 0.42 : 1,
      child: GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.978 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: AppMetrics.cardShadow(elevated: true),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(a.cardFillSoft, visuals.accent, 0.08)!,
                          a.cardFill,
                          Color.lerp(a.cardFill, Colors.black, 0.18)!,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.85, -0.75),
                        radius: 1.05,
                        colors: [
                          visuals.accent.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Vinheta inferior para o rodapé
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.38),
                        ],
                        stops: const [0.5, 0.78, 1],
                      ),
                    ),
                  ),
                ),
                // Moldura
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      border: Border.all(
                        color: visuals.accent.withValues(alpha: 0.42),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                // Cartaz central — altura acompanha a escala da fonte
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.xxl,
                    AppSpace.xxl,
                    AppSpace.xxl,
                    AppSpace.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RealmSeal(
                        glyph: visuals.glyph,
                        accent: visuals.accent,
                        size: sealSize,
                      ),
                      const SizedBox(height: AppSpace.lg),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    visuals.accent.withValues(alpha: 0.55),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.md,
                            ),
                            child: Text(
                              visuals.eyebrow,
                              textAlign: TextAlign.center,
                              softWrap: false,
                              style: AppTypography.label(
                                size: 10,
                                letterSpacing: 1.6,
                                color: visuals.accent,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    visuals.accent.withValues(alpha: 0.55),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        widget.realm.label,
                        textAlign: TextAlign.center,
                        style: AppTypography.display(
                          size: 32,
                          color: a.text,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        visuals.tagline,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          size: 13,
                          height: 1.35,
                          color: a.textMuted(0.62),
                        ),
                      ),
                      const SizedBox(height: AppSpace.xxxl),
                      Container(
                        width: 40,
                        height: 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [
                              visuals.accent.withValues(alpha: 0),
                              visuals.accent.withValues(alpha: 0.8),
                              visuals.accent.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpace.md),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.locked
                                  ? 'Em preparação'
                                  : hasProgress
                                      ? '${widget.completedCount}/${widget.trailCount} concluídas'
                                      : '${widget.trailCount} trilhas',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(
                                size: 12,
                                weight: FontWeight.w700,
                                color: a.textMuted(0.55),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpace.sm),
                          Text(
                            widget.locked ? 'EM BREVE' : 'ABRIR TRILHA',
                            style: AppTypography.label(
                              size: 11,
                              letterSpacing: 1.4,
                              color: visuals.accent,
                            ),
                          ),
                          const SizedBox(width: AppSpace.xs),
                          CinematicIcon(
                            glyph: CinematicGlyph.path,
                            size: 16,
                            accent: visuals.accent,
                            framed: false,
                          ),
                        ],
                      ),
                    ],
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

/// Selo do reino — poço circular limpo.
class _RealmSeal extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color accent;
  final double size;

  const _RealmSeal({required this.glyph, required this.accent, this.size = 84});

  @override
  Widget build(BuildContext context) {
    return CinematicIcon(
      glyph: glyph,
      size: size,
      accent: accent,
      glowing: false,
    );
  }
}
