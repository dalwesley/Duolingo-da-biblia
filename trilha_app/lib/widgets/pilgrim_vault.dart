import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'profile_section.dart';

/// Uma gaveta do Cofre: rótulo, ícone, quantos itens guarda e o que mostra
/// quando aberta (a prateleira do "Quase lá" já vem dentro de [child]).
class VaultDrawer {
  final String label;
  final CinematicGlyph glyph;
  final int? count;
  final Widget child;

  /// Olho de privacidade desta gaveta (perfil próprio).
  final Widget? eye;

  /// Vitrine curta no perfil; [child] fica para a coleção completa. Sem
  /// prévia, a gaveta mostra [child] direto.
  final Widget? preview;

  const VaultDrawer({
    required this.label,
    required this.glyph,
    required this.count,
    required this.child,
    this.eye,
    this.preview,
  });
}

/// O Cofre como baú aberto à noite: veludo escuro, luz dourada saindo da
/// tampa, poeira de ouro subindo. As abas são gavetas com a contagem de
/// cada coleção; a aberta acende.
class PilgrimVault extends StatefulWidget {
  final String title;
  final List<VaultDrawer> drawers;

  /// Coleção completa (tela cheia): mostra [VaultDrawer.child] em vez da
  /// prévia, sem o botão de abrir.
  final bool full;
  final int initialTab;

  /// Texto do botão que abre a coleção completa.
  final String? seeAllLabel;

  const PilgrimVault({
    super.key,
    required this.title,
    required this.drawers,
    this.full = false,
    this.initialTab = 0,
    this.seeAllLabel,
  });

  @override
  State<PilgrimVault> createState() => _PilgrimVaultState();
}

class _PilgrimVaultState extends State<PilgrimVault>
    with TickerProviderStateMixin {
  late var _tab = widget.initialTab;

  /// A tampa abre quando o baú aparece: a luz acende de baixo para cima.
  late final AnimationController _lid = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late final AnimationController _dust = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _dust.stop();
      _lid.value = 1;
    } else {
      if (!_dust.isAnimating) _dust.repeat();
      if (_lid.value == 0 && !_lid.isAnimating) _lid.forward();
    }
  }

  @override
  void dispose() {
    _dust.dispose();
    _lid.dispose();
    super.dispose();
  }

  static const _gold = Color(0xFFE9C46A);

  void _openFull(BuildContext context, int tab) {
    ActHaptics.tap();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _VaultPage(
          title: widget.title,
          drawers: widget.drawers,
          initialTab: tab,
        ),
      ),
    );
  }

  static const _velvetTop = Color(0xFF1A1630);
  static const _velvetBottom = Color(0xFF0A0F1E);

  @override
  Widget build(BuildContext context) {
    final drawers = widget.drawers;
    final tab = _tab.clamp(0, drawers.length - 1);
    final current = drawers[tab];

    final body = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        // Moldura de ouro velho: mais clara em cima, onde bate a luz.
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3D98B), Color(0xFF8A6A2A), Color(0xFF4A3A1A)],
        ),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg - 1.4),
        child: Stack(
          children: [
            // Veludo.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_velvetTop, _velvetBottom],
                  ),
                ),
              ),
            ),
            // Luz da tampa aberta: acende ao aparecer e respira devagar.
            // Ocupa o baú inteiro: o gradiente chega a zero antes de
            // qualquer borda, sem linha entre a luz e o escuro.
            // Camada própria: a respiração perpétua não repinta o baú
            // inteiro (feixes borrados, gavetas) a cada quadro.
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_lid, _dust]),
                    builder: (context, _) {
                      final open = Curves.easeOutCubic.transform(_lid.value);
                      final breath =
                          0.9 + 0.1 * math.sin(_dust.value * math.pi * 2 * 3);
                      final k = open * breath;
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0, -1.15),
                            radius: 1.1,
                            colors: [
                              _gold.withValues(alpha: 0.42 * k),
                              _gold.withValues(alpha: 0.20 * k),
                              _gold.withValues(alpha: 0.07 * k),
                              _gold.withValues(alpha: 0),
                            ],
                            stops: const [0, 0.3, 0.6, 1],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Raios da tampa: três feixes finos que descem da luz.
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _lid,
                    builder: (context, _) => CustomPaint(
                      painter: _RaysPainter(
                        Curves.easeOutCubic.transform(_lid.value),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Poeira de ouro.
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_dust, _lid]),
                    builder: (context, _) => CustomPaint(
                      painter: _DustPainter(_dust.value, _lid.value),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.md,
                AppSpace.lg,
                AppSpace.md,
                AppSpace.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileSectionHeader(
                    accent: _gold,
                    glyph: CinematicGlyph.crown,
                    title: widget.title,
                    trailing: current.eye,
                  ),
                  const SizedBox(height: AppSpace.md),
                  Row(
                    children: [
                      for (var i = 0; i < drawers.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: _DrawerTile(
                            drawer: drawers[i],
                            open: i == tab,
                            onTap: () {
                              if (i == tab) return;
                              ActHaptics.tap();
                              setState(() => _tab = i);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpace.lg),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.03),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topCenter,
                      children: [...previous, ?current],
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(tab),
                      child: widget.full || current.preview == null
                          ? current.child
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                current.preview!,
                                const SizedBox(height: AppSpace.md),
                                _SeeAll(
                                  label: widget.seeAllLabel ?? widget.title,
                                  onTap: () => _openFull(context, tab),
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
    );

    // Dentro do baú é sempre noite: texto claro sobre o veludo.
    return Appearance(
      style: AppearanceStyle.resolve(AppearanceMode.night),
      mode: AppearanceMode.night,
      child: body,
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final VaultDrawer drawer;
  final bool open;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.drawer,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const gold = _PilgrimVaultState._gold;
    final count = drawer.count;
    return Semantics(
      button: true,
      selected: open,
      label: count == null ? drawer.label : '${drawer.label}, $count',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, open ? -2 : 0, 0),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: open
                  ? [gold.withValues(alpha: 0.30), gold.withValues(alpha: 0.08)]
                  : [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.02),
                    ],
            ),
            border: Border.all(
              color: open
                  ? gold.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.10),
              width: open ? 1.4 : 1,
            ),
            boxShadow: open
                ? [
                    BoxShadow(
                      color: gold.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CinematicIcon(
                    glyph: drawer.glyph,
                    size: 18,
                    accent: open ? gold : Colors.white.withValues(alpha: 0.55),
                    framed: false,
                  ),
                  if (count != null) ...[
                    const SizedBox(width: 5),
                    Text(
                      '$count',
                      style:
                          AppTypography.title(
                            size: 18,
                            weight: FontWeight.w900,
                            height: 1,
                            color: open
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.75),
                          ).copyWith(
                            fontFeatures: const [FontFeature.liningFigures()],
                          ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                drawer.label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(
                  size: 9,
                  letterSpacing: 1,
                  weight: FontWeight.w900,
                  color: open
                      ? const Color(0xFFF6E3B0)
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 5),
              // Puxador da gaveta.
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: open ? 26 : 18,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: open
                        ? const [Color(0xFFFFF0C2), gold, Color(0xFF8A6A2A)]
                        : [
                            Colors.white.withValues(alpha: 0.25),
                            Colors.white.withValues(alpha: 0.12),
                          ],
                  ),
                  boxShadow: open
                      ? [
                          BoxShadow(
                            color: gold.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Partículas douradas subindo devagar pela luz da tampa.
class _DustPainter extends CustomPainter {
  final double t;
  final double open;

  _DustPainter(this.t, this.open);

  static final _motes = () {
    final r = math.Random(11);
    return [
      for (var i = 0; i < 26; i++)
        (
          x: r.nextDouble(),
          y: r.nextDouble(),
          s: 0.6 + r.nextDouble() * 1.6,
          v: 0.4 + r.nextDouble() * 0.8,
          p: r.nextDouble() * math.pi * 2,
        ),
    ];
  }();

  @override
  void paint(Canvas canvas, Size size) {
    for (final m in _motes) {
      final y = (m.y - t * m.v) % 1.0;
      final x = m.x + 0.015 * math.sin(t * math.pi * 2 * 2 + m.p);
      // Mais visível perto da tampa, some ao descer.
      final fade = (1 - y).clamp(0.0, 1.0);
      final tw = 0.5 + 0.5 * math.sin(t * math.pi * 2 * 6 + m.p);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        m.s,
        Paint()
          ..color = const Color(
            0xFFFFE3A0,
          ).withValues(alpha: (0.15 + 0.55 * tw) * fade * 0.8 * open),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter old) =>
      old.t != t || old.open != open;
}

/// Feixes de luz descendo da tampa, abrindo junto com ela.
class _RaysPainter extends CustomPainter {
  final double open;

  _RaysPainter(this.open);

  @override
  void paint(Canvas canvas, Size size) {
    if (open <= 0) return;
    final w = size.width;
    final h = math.min(size.height, 260.0) * open;
    final top = Offset(w / 2, -20);
    for (final (dx, spread, alpha) in const [
      (-0.32, 0.10, 0.10),
      (0.0, 0.14, 0.14),
      (0.30, 0.09, 0.09),
    ]) {
      final cx = w / 2 + dx * w;
      final path = Path()
        ..moveTo(top.dx - 6, top.dy)
        ..lineTo(top.dx + 6, top.dy)
        ..lineTo(cx + spread * w, h)
        ..lineTo(cx - spread * w, h)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFE3A0).withValues(alpha: alpha * open),
              const Color(0xFFFFE3A0).withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(0, top.dy, w, h - top.dy))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter old) => old.open != open;
}

class _SeeAll extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SeeAll({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const gold = _PilgrimVaultState._gold;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: gold.withValues(alpha: 0.55)),
            gradient: LinearGradient(
              colors: [
                gold.withValues(alpha: 0.04),
                gold.withValues(alpha: 0.16),
                gold.withValues(alpha: 0.04),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.body(
                  size: 13,
                  weight: FontWeight.w900,
                  color: const Color(0xFFF6E3B0),
                ),
              ),
              const SizedBox(width: 6),
              const CinematicIcon(
                glyph: CinematicGlyph.forward,
                size: 13,
                accent: gold,
                framed: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A coleção completa em tela cheia: o mesmo baú, aberto de vez.
class _VaultPage extends StatelessWidget {
  final String title;
  final List<VaultDrawer> drawers;
  final int initialTab;

  const _VaultPage({
    required this.title,
    required this.drawers,
    required this.initialTab,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.viewPaddingOf(context).top;
    return Scaffold(
      backgroundColor: const Color(0xFF070B16),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpace.screen,
          top + AppSpace.sm,
          AppSpace.screen,
          AppSpace.xl + MediaQuery.viewPaddingOf(context).bottom,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                alignment: Alignment.center,
                child: CinematicIcon(
                  glyph: CinematicGlyph.back,
                  size: 18,
                  accent: Colors.white.withValues(alpha: 0.85),
                  framed: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          PilgrimVault(
            title: title,
            drawers: drawers,
            full: true,
            initialTab: initialTab,
          ),
        ],
      ),
    );
  }
}
