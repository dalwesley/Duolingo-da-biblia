import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/layout_utils.dart';
import '../utils/realm_visuals.dart';
import '../utils/trail_progress.dart';
import '../widgets/cinematic_icon.dart';
import 'realm_journey_screen.dart';

/// Seleção de trilhas — cada reino é um caminho cinematográfico.
class TrilhasScreen extends StatefulWidget {
  final TrailRepository repo;
  final bool asPushedPage;
  final Widget? topBar;

  const TrilhasScreen({
    super.key,
    required this.repo,
    this.asPushedPage = false,
    this.topBar,
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
        ? 12.0
        : AppSpace.sm;
    final bottomPad = widget.asPushedPage
        ? 32 + MediaQuery.viewPaddingOf(context).bottom
        : scrollPaddingBelowNav(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(AppSpace.screen, topPad, AppSpace.screen, bottomPad),
      physics: const BouncingScrollPhysics(),
      children: [
        if (widget.topBar != null) ...[
          widget.topBar!,
          const SizedBox(height: 18),
        ],
        ...TrailRealm.values.asMap().entries.map((e) {
          final realm = e.value;
          final realmTrails = trails
              .where((t) => TrailRealm.fromId(t.realmId) == realm)
              .toList();
          final unlocked = realmTrails
              .where(
                (t) =>
                    TrailProgress.isTrailUnlocked(
                      t,
                      trails,
                      progress.completedMissions,
                    ) &&
                    t.missionSlugs.isNotEmpty &&
                    !t.comingSoon,
              )
              .length;
          final completed = realmTrails
              .where(
                (t) => TrailProgress.isTrailCompleted(
                  t,
                  progress.completedMissions,
                ),
              )
              .length;

          return _reveal(
            (widget.asPushedPage ? 0 : 1) + e.key,
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _RealmPortal(
                realm: realm,
                trailCount: realmTrails.length,
                unlockedCount: unlocked,
                completedCount: completed,
                onTap: () => _openRealm(realm),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _RealmPortal extends StatefulWidget {
  final TrailRealm realm;
  final int trailCount;
  final int unlockedCount;
  final int completedCount;
  final VoidCallback onTap;

  const _RealmPortal({
    required this.realm,
    required this.trailCount,
    required this.unlockedCount,
    required this.completedCount,
    required this.onTap,
  });

  @override
  State<_RealmPortal> createState() => _RealmPortalState();
}

class _RealmPortalState extends State<_RealmPortal>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visuals = RealmVisuals.of(widget.realm);
    final hasProgress = widget.unlockedCount > 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.978 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedBuilder(
          animation: _breath,
          builder: (context, child) {
            final pulse = _breath.value;
            return Container(
              height: 286,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: visuals.glow.withValues(alpha: 0.16 + pulse * 0.14),
                    blurRadius: 28 + pulse * 12,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Céu do reino
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        visuals.sky.first,
                        visuals.sky[1],
                        Color.lerp(visuals.sky.last, Colors.black, 0.35)!,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
                // Paisagem única da trilha
                CustomPaint(
                  painter: _RealmWorldPainter(
                    realm: widget.realm,
                    accent: visuals.accent,
                    glow: visuals.glow,
                  ),
                ),
                // Vinheta de filme
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.15),
                      radius: 1.05,
                      colors: [Colors.transparent, Color(0x99000000)],
                      stops: [0.35, 1],
                    ),
                  ),
                ),
                // Gradiente inferior para legibilidade do rodapé
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x66000000),
                        Color(0xCC000000),
                      ],
                      stops: [0.45, 0.72, 1],
                    ),
                  ),
                ),
                // Moldura fina
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: visuals.accent.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                ),
                // Cartaz central
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                  child: Column(
                    children: [
                      _RealmSeal(
                        glyph: visuals.glyph,
                        accent: visuals.accent,
                        glow: visuals.glow,
                        size: 84,
                      ),
                      const SizedBox(height: 16),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              visuals.eyebrow,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.4,
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
                      const SizedBox(height: 10),
                      Text(
                        widget.realm.label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        visuals.tagline,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ),
                      const Spacer(),
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            hasProgress
                                ? '${widget.completedCount}/${widget.trailCount} concluídas'
                                : '${widget.trailCount} trilhas',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'ABRIR TRILHA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                              color: visuals.accent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: visuals.accent,
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
    );
  }
}

/// Selo do reino — medalhão editorial, sem glow de jogo.
class _RealmSeal extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color accent;
  final Color glow;
  final double size;

  const _RealmSeal({
    required this.glyph,
    required this.accent,
    required this.glow,
    this.size = 84,
  });

  @override
  Widget build(BuildContext context) {
    final metal = Color.lerp(accent, const Color(0xFFF2E6C8), 0.35)!;
    final deep = Color.lerp(glow, const Color(0xFF07090B), 0.72)!;
    final mid = Color.lerp(glow, const Color(0xFF141A1C), 0.45)!;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Aura externa muito contida
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glow.withValues(alpha: 0.28),
                  blurRadius: size * 0.28,
                  spreadRadius: -2,
                ),
              ],
            ),
          ),
          // Anel externo fino
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: metal.withValues(alpha: 0.35),
                width: 1.1,
              ),
            ),
          ),
          // Disco principal
          Container(
            width: size * 0.86,
            height: size * 0.86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.28, -0.38),
                radius: 1.05,
                colors: [mid, deep, Color.lerp(deep, Colors.black, 0.35)!],
                stops: const [0.0, 0.55, 1.0],
              ),
              border: Border.all(
                color: metal.withValues(alpha: 0.55),
                width: size * 0.018,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: size * 0.12,
                  offset: Offset(0, size * 0.04),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Poço interno
                Container(
                  width: size * 0.68,
                  height: size * 0.68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.16),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Glifo
                CinematicIcon(
                  glyph: glyph,
                  size: size * 0.52,
                  accent: Color.lerp(accent, Colors.white, 0.18),
                  framed: false,
                  glowing: false,
                ),
                // Reflexo de lente no topo
                Positioned(
                  top: size * 0.08,
                  child: Container(
                    width: size * 0.38,
                    height: size * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
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

/// Atmosfera de cada trilha — horizonte e silhueta, sem sol/raios.
class _RealmWorldPainter extends CustomPainter {
  final TrailRealm realm;
  final Color accent;
  final Color glow;

  _RealmWorldPainter({
    required this.realm,
    required this.accent,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(realm.index * 97 + 13);

    // Estrelas discretas (céu da criação — sem “explosão” de luz)
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.16);
    for (var i = 0; i < 18; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.48;
      final r = rng.nextDouble() * 1.1 + 0.35;
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }

    // Aurora suave em faixa horizontal (não disco solar)
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.28, size.width, size.height * 0.28),
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                glow.withValues(alpha: 0.12),
                accent.withValues(alpha: 0.06),
                Colors.transparent,
              ],
              stops: const [0.0, 0.35, 0.65, 1.0],
            ).createShader(
              Rect.fromLTWH(
                0,
                size.height * 0.28,
                size.width,
                size.height * 0.28,
              ),
            ),
    );

    // Bloom difuso no alto (atmosfera, sem ponto central)
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.08),
      size.width * 0.55,
      Paint()
        ..shader =
            RadialGradient(
              colors: [glow.withValues(alpha: 0.14), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.5, size.height * 0.08),
                radius: size.width * 0.55,
              ),
            ),
    );

    // Colinas em camadas
    void hill(double yBase, double amp, Color color, double phase) {
      final path = Path()..moveTo(0, size.height);
      path.lineTo(0, size.height * yBase);
      for (var x = 0.0; x <= size.width; x += 8) {
        final t = x / size.width;
        final y =
            size.height * yBase +
            math.sin(t * math.pi * 2 + phase) * amp +
            math.sin(t * math.pi * 5 + phase * 1.7) * amp * 0.35;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, Paint()..color = color);
    }

    switch (realm) {
      case TrailRealm.antigoTestamento:
        hill(0.62, 18, Colors.black.withValues(alpha: 0.18), 0.2);
        hill(0.72, 14, Colors.black.withValues(alpha: 0.28), 1.1);
        hill(0.82, 10, Colors.black.withValues(alpha: 0.4), 2.0);
      case TrailRealm.novoTestamento:
        hill(0.58, 22, Colors.black.withValues(alpha: 0.16), 0.8);
        hill(0.70, 16, Colors.black.withValues(alpha: 0.26), 1.6);
        hill(0.84, 8, Colors.black.withValues(alpha: 0.42), 0.3);
      case TrailRealm.vidaCrista:
        hill(0.66, 12, glow.withValues(alpha: 0.10), 0.4);
        hill(0.76, 16, Colors.black.withValues(alpha: 0.24), 1.3);
        hill(0.86, 9, Colors.black.withValues(alpha: 0.38), 2.2);
      case TrailRealm.teologia:
        hill(0.70, 10, Colors.black.withValues(alpha: 0.22), 0.5);
        hill(0.84, 8, Colors.black.withValues(alpha: 0.4), 1.8);
    }

    // Neblina baixa no chão
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.25),
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.12),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromLTWH(
                0,
                size.height * 0.55,
                size.width,
                size.height * 0.25,
              ),
            ),
    );
  }

  @override
  bool shouldRepaint(covariant _RealmWorldPainter oldDelegate) =>
      oldDelegate.realm != realm ||
      oldDelegate.accent != accent ||
      oldDelegate.glow != glow;
}
