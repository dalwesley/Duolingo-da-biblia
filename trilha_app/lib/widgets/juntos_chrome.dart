import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Peças de interação compartilhadas — abas deslizantes, o fio que liga
/// duas pessoas e o halo de quem já caminhou. Cards e selos vêm do design
/// system ([GlassCard] com `glow`, [SectionLabel], [SoftBadge]).

/// O controle segmentado do app — pílula clara que desliza até a escolha.
/// Use [AppSegmentedTabs] em qualquer tela (Juntos, Bíblia, Ajustes…);
/// [glyph] é opcional. [index] negativo deixa todas apagadas.
typedef AppSegmentedTabs = JuntosSegmentTabs;

class JuntosSegmentTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<({String label, CinematicGlyph? glyph, bool alert})> items;

  const JuntosSegmentTabs({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    const height = 52.0;
    const inset = 4.0;
    final a = Appearance.of(context);
    return Container(
      height: height,
      padding: const EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: a.insetFill,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: a.insetBorder),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final n = items.length;
          final slot = n == 0 ? c.maxWidth : c.maxWidth / n;
          final selected = index >= 0 && index < n;
          return Stack(
            children: [
              if (selected)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutBack,
                  left: slot * index,
                  top: 0,
                  bottom: 0,
                  width: slot,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppRoles.selected,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              Row(
                children: [
                  for (var i = 0; i < n; i++)
                    Expanded(child: _tab(context.l10n, a, i, items[i])),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tab(
    AppLocalizations l10n,
    AppearanceStyle a,
    int i,
    ({String label, CinematicGlyph? glyph, bool alert}) item,
  ) {
    final selected = i == index;
    // Seleção = tinta escura na pílula branca; idle = chrome frio (não
    // branco/secondary — senão some a hierarquia e a tela fica sem vida).
    final ink = selected ? AppColors.night : a.iconMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: item.alert ? l10n.juntosChromeTabAlert(item.label) : item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(i),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.glyph != null) ...[
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CinematicIcon(
                          glyph: item.glyph!,
                          size: AppMetrics.iconSm,
                          accent: ink,
                          framed: false,
                        ),
                        if (item.alert && !selected)
                          const Positioned(
                            right: -3,
                            top: -2,
                            child: AlertDot(size: 8, ring: AppColors.night),
                          ),
                      ],
                    ),
                    const SizedBox(width: 6),
                  ],
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: AppTypography.label(
                      size: 13,
                      letterSpacing: 0.2,
                      weight: selected ? FontWeight.w900 : FontWeight.w700,
                      color: ink,
                    ),
                    child: Text(item.label),
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

/// Como está o fio entre duas pessoas hoje.
enum BondState {
  /// Os dois caminharam — fio aceso (presença), com luz correndo.
  both,

  /// Só a pessoa da esquerda caminhou — metade acesa, metade cinza.
  left,

  /// Só a pessoa da direita caminhou — metade cinza, metade acesa.
  right,

  /// Os dois ainda não caminharam hoje — fio cinza, parado.
  idle,

  /// Lugar vazio (convite) — fio tracejado, apagado.
  none,
}

/// Uma ponta do fio, independente da outra.
enum BondEnd {
  /// Caminhou hoje — trecho aceso (presença).
  lit,

  /// Ainda não caminhou hoje — trecho cinza.
  idle,

  /// Não está caminhando — o trecho some.
  gone,

  /// Convite pendente — trecho tracejado (quem já convidou).
  dashed,
}

/// Fio que liga dois retratos.
///
/// Cada ponta tem cor própria: presença se a pessoa caminhou hoje,
/// cinza se ainda não, e some se ela não está caminhando.
/// Sem [left] e [right], o desenho segue [state].
class BondThread extends StatefulWidget {
  final BondState state;
  final BondEnd? left;
  final BondEnd? right;
  final Color color;

  const BondThread({
    super.key,
    required this.state,
    this.left,
    this.right,
    this.color = AppRoles.presence,
  });

  (BondEnd, BondEnd)? get ends {
    if (left != null && right != null) return (left!, right!);
    return switch (state) {
      BondState.both => (BondEnd.lit, BondEnd.lit),
      BondState.left => (BondEnd.lit, BondEnd.idle),
      BondState.right => (BondEnd.idle, BondEnd.lit),
      BondState.idle => (BondEnd.idle, BondEnd.idle),
      BondState.none => null,
    };
  }

  @override
  State<BondThread> createState() => _BondThreadState();
}

class _BondThreadState extends State<BondThread>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flow;

  @override
  void initState() {
    super.initState();
    _flow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant BondThread oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state ||
        oldWidget.left != widget.left ||
        oldWidget.right != widget.right) {
      _sync();
    }
  }

  void _sync() {
    final ends = widget.ends;
    final flows =
        ends != null && (ends.$1 == BondEnd.lit || ends.$2 == BondEnd.lit);
    if (!flows) {
      _flow.stop();
    } else if (!_flow.isAnimating) {
      _flow.repeat();
    }
  }

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _flow,
        builder: (context, _) => CustomPaint(
          size: const Size(double.infinity, 14),
          painter: _BondPainter(
            ends: widget.ends,
            color: widget.color,
            t: reduce ? 0.5 : _flow.value,
          ),
        ),
      ),
    );
  }
}

class _BondPainter extends CustomPainter {
  final (BondEnd, BondEnd)? ends;
  final Color color;
  final double t;

  const _BondPainter({
    required this.ends,
    required this.color,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final w = size.width;
    final pair = ends;

    if (pair == null) {
      final dim = Paint()
        ..color = AppRoles.chrome.withValues(alpha: 0.16)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      const dash = 5.0;
      const gap = 5.0;
      var x = 0.0;
      while (x < w) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + dash, w), y), dim);
        x += dash + gap;
      }
      return;
    }

    final gray = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.textMutedDark.withValues(alpha: 0.72);
    final lit = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color;
    final glow = Paint()
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    void stretch(double from, double to, BondEnd end) {
      if (end == BondEnd.gone || to <= from) return;
      if (end == BondEnd.dashed) {
        final dim = Paint()
          ..color = AppRoles.chrome.withValues(alpha: 0.16)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round;
        const dash = 5.0;
        const gap = 5.0;
        var x = from;
        while (x < to) {
          canvas.drawLine(Offset(x, y), Offset(math.min(x + dash, to), y), dim);
          x += dash + gap;
        }
        return;
      }
      if (end == BondEnd.lit) {
        canvas.drawLine(Offset(from, y), Offset(to, y), glow);
        canvas.drawLine(Offset(from, y), Offset(to, y), lit);
      } else {
        canvas.drawLine(Offset(from, y), Offset(to, y), gray);
      }
    }

    final mid = w / 2;
    final (left, right) = pair;
    stretch(0, mid, left);
    stretch(mid, w, right);

    // Faísca só no trecho aceso. Os dois juntos: corre o fio inteiro.
    final (double from, double to, bool inward) = switch ((left, right)) {
      (BondEnd.lit, BondEnd.lit) => (0.0, w, false),
      (BondEnd.lit, _) => (0.0, mid, false),
      (_, BondEnd.lit) => (mid, w, true),
      _ => (0.0, 0.0, false),
    };
    final span = to - from;
    if (span <= 0) return;
    final progress = inward ? 1 - t : t;
    final sx = from + span * progress;
    final fade = math.sin(math.pi * t);
    canvas.drawCircle(
      Offset(sx, y),
      5,
      Paint()
        ..color = color.withValues(alpha: 0.45 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      Offset(sx, y),
      2.2,
      Paint()..color = AppRoles.selected.withValues(alpha: 0.9 * fade),
    );
  }

  @override
  bool shouldRepaint(covariant _BondPainter old) =>
      old.t != t || old.ends != ends || old.color != color;
}

/// Anel que respira em volta de um retrato (quem já caminhou hoje).
class JuntosHalo extends StatefulWidget {
  final Widget child;
  final double size;
  final Color color;
  final bool lit;

  const JuntosHalo({
    super.key,
    required this.child,
    required this.size,
    this.color = AppRoles.presence,
    this.lit = true,
  });

  @override
  State<JuntosHalo> createState() => _JuntosHaloState();
}

class _JuntosHaloState extends State<JuntosHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    if (widget.lit) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant JuntosHalo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lit && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.lit) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Anel encostado no retrato (1.6 de cada lado), sem folga escura.
    final ring = widget.size + 3.2;
    return SizedBox(
      width: ring,
      height: ring,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final t = widget.lit
                ? Curves.easeInOut.transform(_pulse.value)
                : 0.0;
            return DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.lit
                      ? widget.color.withValues(alpha: 0.55 + 0.35 * t)
                      : AppRoles.chrome.withValues(alpha: 0.1),
                  width: 1.6,
                ),
                boxShadow: widget.lit
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(
                            alpha: 0.18 + 0.22 * t,
                          ),
                          blurRadius: 10 + 8 * t,
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
          child: RepaintBoundary(child: Center(child: widget.child)),
        ),
      ),
    );
  }
}
