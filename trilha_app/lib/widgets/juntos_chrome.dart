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

/// O controle segmentado do app — pílula escura com rim do [accent].
/// Use [AppSegmentedTabs] em qualquer tela (Juntos, Bíblia, Ajustes…);
/// [glyph] é opcional. [index] negativo deixa todas apagadas.
///
/// [accent] = cromático do bloco (`presence` social, `reward` disputa,
/// `chrome` neutro). Aba ativa **não** usa o branco de seleção da cena.
/// [mark] no item = leading custom (ex.: bandeira de idioma); senão [glyph].
typedef AppSegmentedTabs = JuntosSegmentTabs;

class JuntosSegmentTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<({String label, CinematicGlyph? glyph, Widget? mark, bool alert})>
  items;

  /// Cromático do bloco — presença ou reward. Sem valor: neutro do tema
  /// (chrome no escuro, azul de seleção no papel).
  final Color? accent;

  /// Fundo do trilho. Sem valor, o poço translúcido ([AppearanceStyle.insetFill]).
  /// Sobre a arte da trilha, use [AppearanceStyle.cardFill]: o desenho
  /// não atravessa o texto.
  final Color? fill;

  const JuntosSegmentTabs({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
    this.accent,
    this.fill,
  });

  @override
  Widget build(BuildContext context) {
    const height = 52.0;
    const inset = 4.0;
    final a = Appearance.of(context);
    final tone = accent ?? (a.onDark ? a.chrome : a.selected);
    return Container(
      height: height,
      padding: const EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: fill ?? a.insetFill,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: fill == null ? a.insetBorder : a.cardBorder),
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
                  duration: AppMotion.gentle,
                  curve: AppMotion.settle,
                  left: slot * index,
                  top: 0,
                  bottom: 0,
                  width: slot,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.lerp(a.cardFill, tone, 0.22)!,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: tone.withValues(alpha: 0.75),
                        width: 1.25,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: tone.withValues(alpha: 0.28),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              Row(
                children: [
                  for (var i = 0; i < n; i++)
                    Expanded(child: _tab(context.l10n, a, i, items[i], tone)),
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
    ({String label, CinematicGlyph? glyph, Widget? mark, bool alert}) item,
    Color tone,
  ) {
    final selected = i == index;
    // Ativo = tinta do accent; idle = chrome frio. Branco fica na cena.
    final ink = selected ? tone : a.iconMuted;
    final leading =
        item.mark ??
        (item.glyph != null
            ? CinematicIcon(
                glyph: item.glyph!,
                size: AppMetrics.iconSm,
                accent: ink,
                framed: false,
              )
            : null);
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
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        leading,
                        if (item.alert && !selected)
                          Positioned(
                            right: -3,
                            top: -2,
                            child: AlertDot(size: 8, ring: a.insetFill),
                          ),
                      ],
                    ),
                    const SizedBox(width: 5),
                  ],
                  AnimatedDefaultTextStyle(
                    duration: AppMotion.quick,
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
    final a = Appearance.of(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _flow,
        builder: (context, _) => CustomPaint(
          size: const Size(double.infinity, 14),
          painter: _BondPainter(
            ends: widget.ends,
            color: widget.color,
            dashInk: a.chrome,
            idle: a.textFaint,
            spark: a.text,
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

  /// Tracejado de "ninguém" (chrome do tema).
  final Color dashInk;

  /// Trecho apagado de quem ainda não caminhou.
  final Color idle;

  /// Miolo da faísca.
  final Color spark;
  final double t;

  const _BondPainter({
    required this.ends,
    required this.color,
    required this.dashInk,
    required this.idle,
    required this.spark,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final w = size.width;
    final pair = ends;

    if (pair == null) {
      final dim = Paint()
        ..color = dashInk.withValues(alpha: 0.16)
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
      ..color = idle.withValues(alpha: 0.72);
    final lit = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color;
    final glow = Paint()
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.2);

    void stretch(double from, double to, BondEnd end) {
      if (end == BondEnd.gone || to <= from) return;
      if (end == BondEnd.dashed) {
        final dim = Paint()
          ..color = dashInk.withValues(alpha: 0.16)
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
      4.5,
      Paint()..color = color.withValues(alpha: 0.35 * fade),
    );
    canvas.drawCircle(
      Offset(sx, y),
      2.2,
      Paint()..color = spark.withValues(alpha: 0.9 * fade),
    );
  }

  @override
  bool shouldRepaint(covariant _BondPainter old) =>
      old.t != t ||
      old.ends != ends ||
      old.color != color ||
      old.dashInk != dashInk ||
      old.idle != idle ||
      old.spark != spark;
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
  // Criado no initState, nunca preguiçoso: apagado (lit false) o
  // controller só nascia no dispose, e o vsync procurava o TickerMode num
  // elemento já desativado.
  late final AnimationController _pulse;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _glow = _pulse.drive(
      Tween<double>(
        begin: 0.45,
        end: 1,
      ).chain(CurveTween(curve: AppMotion.move)),
    );
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
    final chrome = Appearance.of(context).chrome;
    final ringColor = widget.lit
        ? widget.color.withValues(alpha: 0.9)
        : chrome.withValues(alpha: 0.1);
    return SizedBox(
      width: ring,
      height: ring,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (widget.lit)
            FadeTransition(
              opacity: _glow,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: SizedBox.square(dimension: ring),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ringColor, width: 1.6),
            ),
            child: SizedBox.square(dimension: ring),
          ),
          Center(child: widget.child),
        ],
      ),
    );
  }
}
