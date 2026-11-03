import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/season_walk_debug.dart';

/// Contagem regressiva até [opens] (dias, horas, min, seg), a cada segundo.
///
/// [seasonToday] — relógio da Caminhada no laboratório: desloca o "agora"
/// pela diferença de dias. Sem ele, usa o relógio do aparelho.
/// [label] — sobrescreve "Abre em" (ex.: ranking mensal: "Fecha em").
/// [large] — números grandes em placas. [centered] — alinha ao centro.
/// [blink] — números piscam (última semana do ranking mensal).
/// [onDone] — uma vez, quando a contagem chega a zero com a tela aberta.
class SeasonCountdown extends StatefulWidget {
  final DateTime opens;
  final DateTime? seasonToday;
  final Color color;
  final Color muted;
  final bool large;
  final bool centered;
  final bool blink;
  final Color? accent;
  final String? label;
  final VoidCallback? onDone;

  const SeasonCountdown({
    super.key,
    required this.opens,
    this.seasonToday,
    required this.color,
    required this.muted,
    this.large = false,
    this.centered = false,
    this.blink = false,
    this.accent,
    this.label,
    this.onDone,
  });

  @override
  State<SeasonCountdown> createState() => _SeasonCountdownState();
}

// Não Single: o pisca é descartado e recriado quando [blink] alterna.
class _SeasonCountdownState extends State<SeasonCountdown>
    with TickerProviderStateMixin {
  Timer? _timer;
  AnimationController? _blink;
  bool _doneFired = false;

  @override
  void initState() {
    super.initState();
    if (widget.blink) _ensureBlink();
  }

  @override
  void didUpdateWidget(covariant SeasonCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.opens != oldWidget.opens) _doneFired = false;
    if (widget.blink == oldWidget.blink) return;
    if (widget.blink) {
      _ensureBlink();
      if (TickerMode.valuesOf(context).enabled) {
        _blink?.repeat(reverse: true);
      }
    } else {
      _blink?.dispose();
      _blink = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Aba fora da tela: não acorda a cada segundo / não pisca.
    if (TickerMode.valuesOf(context).enabled) {
      _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {});
        if (!_doneFired && _left() == Duration.zero) {
          _doneFired = true;
          widget.onDone?.call();
        }
      });
      if (widget.blink) {
        _ensureBlink();
        _blink?.repeat(reverse: true);
      }
    } else {
      _timer?.cancel();
      _timer = null;
      _blink?.stop();
    }
  }

  void _ensureBlink() {
    _blink ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blink?.dispose();
    super.dispose();
  }

  Duration _left() {
    final real = DateTime.now();
    var now = real;
    // Só o relógio do Laboratório desloca: o dia real guardado no build
    // ficaria velho depois da meia-noite e somaria um dia à contagem.
    final shiftDay = SeasonWalkDebug.active ? widget.seasonToday : null;
    if (shiftDay != null) {
      final realDay = DateTime(real.year, real.month, real.day);
      final shift = DateTime(
        shiftDay.year,
        shiftDay.month,
        shiftDay.day,
      ).difference(realDay);
      now = real.add(shift);
    }
    final left = widget.opens.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final left = _left();
    String two(int n) => n.toString().padLeft(2, '0');
    final units = [
      ('${left.inDays}', l10n.walkCountdownDays),
      (two(left.inHours % 24), l10n.walkCountdownHours),
      (two(left.inMinutes % 60), l10n.walkCountdownMinutes),
      (two(left.inSeconds % 60), l10n.walkCountdownSeconds),
    ];
    final large = widget.large;
    final centered = widget.centered;
    // Fill neutro; no ranking mensal (centered) a borda segue a cor do dígito.
    final fill = widget.accent ?? widget.muted;
    final edge = centered ? widget.color : fill;
    final digits = AppTypography.body(
      size: large ? 30 : 18,
      weight: FontWeight.w800,
      height: 1.1,
      color: widget.color,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final unitStyle = AppTypography.body(
      size: large ? 10 : 9,
      weight: FontWeight.w600,
      color: widget.muted,
    );

    Widget digitText(String value) {
      final text = Text(value, style: digits);
      final ctrl = _blink;
      if (ctrl == null) return text;
      return FadeTransition(
        opacity: Tween<double>(
          begin: 1,
          end: 0.28,
        ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut)),
        child: text,
      );
    }

    Widget unit((String, String) u) {
      final column = Column(
        crossAxisAlignment: large || centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          digitText(u.$1),
          Text(u.$2, style: unitStyle),
        ],
      );
      if (!large) return column;

      Widget plate({required double borderAlpha}) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            color: fill.withValues(alpha: 0.12),
            border: Border.all(
              color: edge.withValues(alpha: borderAlpha),
              width: centered ? 1.6 : 1,
            ),
          ),
          child: column,
        );
      }

      final ctrl = _blink;
      if (ctrl == null) {
        return Expanded(child: plate(borderAlpha: centered ? 0.85 : 0.35));
      }
      // Vermelho: borda pisca junto com o número.
      return Expanded(
        child: AnimatedBuilder(
          animation: ctrl,
          child: column,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(ctrl.value);
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                color: fill.withValues(alpha: 0.12),
                border: Border.all(
                  color: edge.withValues(alpha: 0.25 + 0.7 * t),
                  width: 1.6,
                ),
              ),
              child: child,
            );
          },
        ),
      );
    }

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label ?? l10n.walkCountdownLabel,
            style: AppTypography.body(
              size: large ? 12 : 11,
              weight: FontWeight.w600,
              color: widget.muted,
            ),
          ),
          SizedBox(height: large ? 8 : 2),
          // Compacto: FittedBox evita overflow com muitos dias (ex.: Advento
          // do ano que vem). Large já usa Expanded por unidade.
          large
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < units.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      unit(units[i]),
                    ],
                  ],
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: centered ? Alignment.center : Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < units.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        unit(units[i]),
                      ],
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
