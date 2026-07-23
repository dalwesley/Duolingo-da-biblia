import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/realm_visuals.dart';
import '../utils/trail_progress.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/journey_path.dart';
import '../widgets/top_bar.dart';
import 'trail_map_screen.dart';

/// Peregrinação cinematográfica — trilhas dentro de um reino.
class RealmJourneyScreen extends StatefulWidget {
  final TrailRealm realm;
  final List<Trail> allTrails;

  const RealmJourneyScreen({
    super.key,
    required this.realm,
    required this.allTrails,
  });

  @override
  State<RealmJourneyScreen> createState() => _RealmJourneyScreenState();
}

class _RealmJourneyScreenState extends State<RealmJourneyScreen>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  final _currentKey = GlobalKey();
  bool _jumped = false;
  late final AnimationController _world;

  @override
  void initState() {
    super.initState();
    _world = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleJumpToCurrent());
  }

  @override
  void dispose() {
    _world.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<JourneyPathItem> _buildItems(List<String> completed) {
    final realmTrails = widget.allTrails
        .where((t) => TrailRealm.fromId(t.realmId) == widget.realm)
        .toList()
      ..sort((a, b) {
        final ca = TrailCategory.fromId(a.categoryId).order;
        final cb = TrailCategory.fromId(b.categoryId).order;
        if (ca != cb) return ca.compareTo(cb);
        return a.order.compareTo(b.order);
      });

    var sawCurrent = false;
    final items = <JourneyPathItem>[];

    for (final trail in realmTrails) {
      final unlocked =
          TrailProgress.isTrailUnlocked(trail, widget.allTrails, completed);
      final done = TrailProgress.isTrailCompleted(trail, completed);
      final prog = TrailProgress.getProgress(trail, completed);
      final hasContent = trail.missionSlugs.isNotEmpty && !trail.comingSoon;

      final JourneyNodeState state;
      if (!unlocked) {
        state = JourneyNodeState.locked;
      } else if (done) {
        state = JourneyNodeState.completed;
      } else if (!hasContent) {
        state = JourneyNodeState.soon;
      } else if (!sawCurrent) {
        state = JourneyNodeState.current;
        sawCurrent = true;
      } else {
        state = JourneyNodeState.upcoming;
      }

      items.add(
        JourneyPathItem(
          trail: trail,
          state: state,
          category: TrailCategory.fromId(trail.categoryId),
          done: prog.done,
          total: prog.total,
        ),
      );
    }

    return items;
  }

  void _jumpToCurrent() {
    if (!mounted) return;
    final ctx = _currentKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.28,
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutCubic,
    );
  }

  void _scheduleJumpToCurrent() {
    if (!mounted || _jumped) return;
    if (_currentKey.currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleJumpToCurrent());
      return;
    }
    _jumped = true;
    Future.delayed(const Duration(milliseconds: 180), _jumpToCurrent);
  }

  void _onNodeTap(JourneyPathItem item) {
    HapticFeedback.selectionClick();
    final trail = item.trail;
    final canOpen = item.state == JourneyNodeState.current ||
        item.state == JourneyNodeState.completed ||
        item.state == JourneyNodeState.upcoming;

    if (canOpen && trail.missionSlugs.isNotEmpty && !trail.comingSoon) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 480),
          pageBuilder: (_, animation, secondaryAnimation) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: TrailMapScreen(slug: trail.slug),
            );
          },
        ),
      );
      return;
    }

    _showSoonSheet(item);
  }

  void _showSoonSheet(JourneyPathItem item) {
    final visuals = RealmVisuals.of(widget.realm);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.night,
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
                item.trail.title,
                textAlign: TextAlign.center,
                style: AppTypography.display(size: 30),
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                item.trail.description,
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  size: 15,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.58),
                ),
              ),
              const SizedBox(height: AppSpace.xxl),
              Text(
                item.state == JourneyNodeState.locked
                    ? 'Continue a jornada anterior para alcançar este horizonte.'
                    : 'Esta trilha ainda está sendo escrita — em breve no caminho.',
                textAlign: TextAlign.center,
                style: AppTypography.label(
                  size: 13,
                  color: visuals.accent.withValues(alpha: 0.9),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final visuals = RealmVisuals.of(widget.realm);
    final items = _buildItems(progress.completedMissions);
    final bottom = MediaQuery.of(context).padding.bottom;
    final mode = progress.settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

    return Appearance(
      mode: mode,
      style: appearance,
      child: Scaffold(
        backgroundColor: visuals.sky.first,
        body: Stack(
          children: [
            // Living world atmosphere
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _world,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _RealmWorldPainter(
                      sky: visuals.sky,
                      accent: visuals.accent,
                      glow: visuals.glow,
                      phase: _world.value,
                      seed: widget.realm.index * 91,
                    ),
                  );
                },
              ),
            ),

            // Edge vignette
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.15),
                      radius: 1.2,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      stops: const [0.42, 1],
                    ),
                  ),
                ),
              ),
            ),

            CustomScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
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
                      title: widget.realm.label,
                      onBack: () => Navigator.pop(context),
                      leadingGlyph: CinematicGlyph.path,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: AppSpace.lg),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 20, 140 + bottom),
                    child: JourneyPath(
                      items: items,
                      accent: visuals.accent,
                      glow: visuals.glow,
                      currentKey: _currentKey,
                      onTap: _onNodeTap,
                    ),
                  ),
                ),
              ],
            ),

            // Soft jump control — not a loud FAB
            Positioned(
              right: 18,
              bottom: 28 + bottom,
              child: _JumpChip(
                accent: visuals.accent,
                onTap: _jumpToCurrent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JumpChip extends StatelessWidget {
  final Color accent;
  final VoidCallback onTap;

  const _JumpChip({required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.section,
            vertical: AppSpace.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            color: const Color(0xEE121816),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.rise,
                size: 16,
                accent: accent,
                framed: false,
                glowing: false,
              ),
              const SizedBox(width: AppSpace.sm),
              Text(
                'Seu passo',
                style: AppTypography.label(
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.88),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Céu, estrelas, colinas e luz — atmosfera da peregrinação.
class _RealmWorldPainter extends CustomPainter {
  final List<Color> sky;
  final Color accent;
  final Color glow;
  final double phase;
  final int seed;

  _RealmWorldPainter({
    required this.sky,
    required this.accent,
    required this.glow,
    required this.phase,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Deep sky
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            sky[0],
            sky.length > 1 ? sky[1] : sky[0],
            sky.length > 2 ? sky[2] : sky.last,
            Color.lerp(sky.last, Colors.black, 0.35)!,
          ],
          stops: const [0, 0.35, 0.7, 1],
        ).createShader(rect),
    );

    final rng = math.Random(seed);

    // Stars
    for (var i = 0; i < 55; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.55;
      final twinkle = 0.35 + 0.65 * ((math.sin(phase * math.pi * 2 + i) + 1) / 2);
      canvas.drawCircle(
        Offset(x, y),
        0.6 + rng.nextDouble() * 1.2,
        Paint()..color = Colors.white.withValues(alpha: 0.15 + twinkle * 0.35),
      );
    }

    // Soft god-ray / light shaft
    final shaftX = size.width * (0.65 + 0.05 * math.sin(phase * math.pi * 2));
    final shaft = Path()
      ..moveTo(shaftX - 40, 0)
      ..lineTo(shaftX + 40, 0)
      ..lineTo(shaftX + 120, size.height * 0.7)
      ..lineTo(shaftX - 80, size.height * 0.7)
      ..close();
    canvas.drawPath(
      shaft,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            glow.withValues(alpha: 0.07),
            accent.withValues(alpha: 0.02),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.7)),
    );

    // Ambient blooms
    _bloom(canvas, Offset(size.width * 0.85, size.height * 0.12), size.width * 0.45,
        glow.withValues(alpha: 0.16));
    _bloom(canvas, Offset(size.width * 0.1, size.height * 0.35), size.width * 0.35,
        accent.withValues(alpha: 0.08));

    // Distant mountain layers
    _hills(
      canvas,
      size,
      baseY: size.height * 0.62,
      amp: size.height * 0.08,
      color: Colors.black.withValues(alpha: 0.18),
      offset: phase * 12,
      seed: seed + 1,
    );
    _hills(
      canvas,
      size,
      baseY: size.height * 0.72,
      amp: size.height * 0.11,
      color: Colors.black.withValues(alpha: 0.28),
      offset: phase * -8,
      seed: seed + 2,
    );
    _hills(
      canvas,
      size,
      baseY: size.height * 0.84,
      amp: size.height * 0.1,
      color: Color.lerp(sky.last, Colors.black, 0.55)!.withValues(alpha: 0.85),
      offset: 0,
      seed: seed + 3,
    );

    // Warm ground haze
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            accent.withValues(alpha: 0.06),
            Colors.black.withValues(alpha: 0.35),
          ],
        ).createShader(
          Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25),
        ),
    );
  }

  void _bloom(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [color, Colors.transparent],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  void _hills(
    Canvas canvas,
    Size size, {
    required double baseY,
    required double amp,
    required Color color,
    required double offset,
    required int seed,
  }) {
    final rng = math.Random(seed);
    final path = Path()..moveTo(-20, size.height);
    path.lineTo(-20, baseY);
    var x = -20.0;
    while (x < size.width + 40) {
      final peak = baseY - amp * (0.4 + rng.nextDouble() * 0.8);
      final mid = x + 40 + rng.nextDouble() * 50;
      path.quadraticBezierTo(mid + offset * 0.3, peak, x + 90, baseY);
      x += 90;
    }
    path.lineTo(size.width + 20, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _RealmWorldPainter old) =>
      old.phase != phase || old.accent != accent;
}
