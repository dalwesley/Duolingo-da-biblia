import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

enum JourneyNodeState { locked, upcoming, current, completed, soon }

/// Card de estação na curva — mapa do reino e mapa da trilha.
class JourneyStationCard extends StatelessWidget {
  final String title;
  final String eyebrow;
  final JourneyNodeState state;
  final Color accent;
  final Color glow;
  final VoidCallback? onTap;
  final Widget? leading;
  final String? currentSubtitle;
  final String? statusLine;
  final int done;
  final int total;
  final String? semanticsLabel;

  /// Acento do chrome quando difere do [accent] (ex.: modo selado).
  final Color? chrome;

  /// Glifo da trilha / cena — identidade à esquerda.
  final CinematicGlyph? glyph;

  /// Numeral romano grande no fundo (I, II…).
  final String? watermark;

  /// Cena que pede o Peregrino+: o "Agora" vira "Peregrino+" e o botão
  /// convida a continuar com o Plus (o toque leva ao paywall).
  final bool plusLocked;

  const JourneyStationCard({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.state,
    required this.accent,
    required this.glow,
    this.onTap,
    this.leading,
    this.currentSubtitle,
    this.statusLine,
    this.done = 0,
    this.total = 0,
    this.semanticsLabel,
    this.chrome,
    this.glyph,
    this.watermark,
    this.plusLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == JourneyNodeState.current;
    final isDone = state == JourneyNodeState.completed;
    final isLocked = state == JourneyNodeState.locked;
    final isSoon = state == JourneyNodeState.soon;
    final a = Appearance.of(context);
    final tone = chrome;
    final ink = tone ?? accent;
    final left = (total - done).clamp(0, total);
    final lit = !isLocked && !isSoon && (isCurrent || tone != null || isDone);
    final quiet = isLocked || isSoon;
    final plateSize = isCurrent ? 40.0 : (quiet ? 32.0 : 36.0);

    final textCol = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              // Rótulo inteiro numa linha; o estado à direita é que encolhe
              // (dividir a largura meio a meio quebrava "TRILHA III").
              SectionLabel(
                eyebrow,
                size: 10,
                maxLines: 1,
                color: isCurrent
                    ? ink
                    : quiet
                    ? Color.lerp(a.textFaint, accent, 0.4)!
                    : a.textFaint,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: isCurrent
                    ? Text(
                        plusLocked
                            ? context.l10n.paywallTitle
                            : context.l10n.journeyNow,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: AppTypography.label(size: 11, color: ink),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.display(
              size: isCurrent ? 20 : (quiet ? 16 : 18),
              height: 1.1,
              color: quiet ? a.textSecondary : a.text,
            ),
          ),
          const SizedBox(height: 4),
          if (isCurrent && currentSubtitle != null)
            Text(
              currentSubtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w800,
                color: ink,
              ),
            ),
          if (!isCurrent)
            Text(
              statusLine ?? _defaultStatus(context, isLocked, isSoon, isDone),
              maxLines: quiet ? 2 : 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: quiet ? 11 : 12,
                weight: FontWeight.w700,
                height: 1.25,
                color: quiet ? Color.lerp(a.textFaint, accent, 0.32)! : ink,
              ),
            ),
          if (isCurrent && total > 0) ...[
            const SizedBox(height: 8),
            AppProgressBar(
              value: done / total,
              color: ink,
              trackColor: a.progressTrack,
              height: 6,
            ),
            const SizedBox(height: 6),
            Text(
              left > 0
                  ? context.l10n.journeyScenesLeft(left)
                  : (statusLine ?? context.l10n.trailsScenesOf(done, total)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: a.text,
              ),
            ),
          ],
          if (isCurrent) ...[
            const SizedBox(height: 10),
            CopperCta(
              label: plusLocked
                  ? context.l10n.plusNoticeContinue
                  : context.l10n.journeyPlay,
              leading: plusLocked ? CinematicGlyph.plus : null,
              dense: true,
              decorative: true,
              showGlow: false,
              expanded: true,
            ),
          ],
        ],
      ),
    );

    final body = Stack(
      clipBehavior: Clip.none,
      children: [
        if (watermark != null && watermark!.isNotEmpty)
          Positioned(
            right: -4,
            bottom: -10,
            child: IgnorePointer(
              child: Text(
                watermark!,
                style: AppTypography.display(
                  size: isCurrent ? 56 : (quiet ? 40 : 48),
                  height: 1,
                  color: (quiet ? accent : ink).withValues(
                    alpha: quiet ? 0.10 : 0.14,
                  ),
                ),
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (glyph != null) ...[
              _GlyphPlate(
                glyph: glyph!,
                size: plateSize,
                ink: quiet ? accent : ink,
                quiet: quiet,
                lit: isCurrent,
              ),
              SizedBox(width: quiet ? 10 : 12),
            ],
            textCol,
          ],
        ),
      ],
    );

    final pad = EdgeInsets.fromLTRB(
      quiet ? 12 : 14,
      quiet ? 10 : 12,
      quiet ? 12 : 14,
      quiet ? 10 : 12,
    );

    final Widget card;
    if (lit) {
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: [
            BoxShadow(
              color: (isCurrent ? glow : ink).withValues(
                alpha: isCurrent ? 0.30 : 0.20,
              ),
              blurRadius: isCurrent ? 18 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: DecoratedBox(
          decoration: DifficultyVisuals.stationCard(
            accent: ink,
            baseFill: a.cardFill,
            lit: isCurrent,
            sealed: isDone && !isCurrent,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 18,
                  right: 18,
                  child: CardFilament(color: ink, height: 2),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    14,
                    isCurrent ? 14 : 12,
                    14,
                    isCurrent ? 12 : 12,
                  ),
                  child: body,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      card = GlassCard(
        padding: EdgeInsets.zero,
        tint: accent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 12,
                bottom: 12,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accent.withValues(alpha: 0),
                        accent.withValues(alpha: 0.5),
                        accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: pad, child: body),
            ],
          ),
        ),
      );
    }

    final beacon = isCurrent ? _CurrentBeacon(color: ink, child: card) : card;

    final tappable = onTap == null
        ? beacon
        : ActPress(
            onTap: onTap,
            depth: quiet ? 0 : (isCurrent ? 3 : 2),
            child: beacon,
          );

    return Opacity(
      opacity: quiet ? 0.62 : 1,
      child: Semantics(
        label: semanticsLabel ?? title,
        button: onTap != null,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final room = constraints.maxWidth;
            // No tablet a coluna é mais larga: o teto do celular corta
            // o título ("Deuteronômio") e deixa o card minúsculo no vão.
            final wide = room >= 440;
            final fraction = isCurrent
                ? 0.72
                : quiet
                ? 0.48
                : 0.56;
            final cap = wide
                ? (isCurrent ? 320.0 : (quiet ? 248.0 : 280.0))
                : (isCurrent ? 220.0 : (quiet ? 152.0 : 176.0));
            final floor = wide
                ? (quiet ? 200.0 : 220.0)
                : (quiet ? 128.0 : 148.0);
            final preferred = math.min(cap, math.max(floor, room * fraction));
            final width = math.min(preferred, constraints.maxWidth);
            return SizedBox(width: width, child: tappable);
          },
        ),
      ),
    );
  }

  String _defaultStatus(
    BuildContext context,
    bool isLocked,
    bool isSoon,
    bool isDone,
  ) {
    if (isLocked) return context.l10n.journeyBeyondHorizon;
    if (isSoon) return context.l10n.commonComingSoon;
    if (isDone) return context.l10n.trailsCleared;
    if (total > 0) return context.l10n.trailsScenesShort(done, total);
    return '';
  }
}

class _GlyphPlate extends StatelessWidget {
  final CinematicGlyph glyph;
  final double size;
  final Color ink;
  final bool quiet;
  final bool lit;

  const _GlyphPlate({
    required this.glyph,
    required this.size,
    required this.ink,
    required this.quiet,
    required this.lit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: ink.withValues(alpha: lit ? 0.75 : (quiet ? 0.4 : 0.55)),
          width: lit ? 1.3 : 1.1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ink.withValues(alpha: lit ? 0.24 : (quiet ? 0.10 : 0.14)),
            ink.withValues(alpha: lit ? 0.06 : 0.03),
          ],
        ),
      ),
      child: CinematicIcon(
        glyph: glyph,
        size: size * 0.52,
        accent: ink,
        framed: false,
      ),
    );
  }
}

/// Halo que respira na estação atual — “você está aqui”.
class _CurrentBeacon extends StatefulWidget {
  final Color color;
  final Widget child;

  const _CurrentBeacon({required this.color, required this.child});

  @override
  State<_CurrentBeacon> createState() => _CurrentBeaconState();
}

class _CurrentBeaconState extends State<_CurrentBeacon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _glow = _pulse.drive(
      Tween<double>(
        begin: 0.35,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeInOut)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = AppMotion.reduced(context);
    if (reduced) {
      _pulse.stop();
      _pulse.value = 0.55;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // O halo é uma camada parada. O pulso só muda a opacidade — o desfoque
    // do BoxShadow não se recalcula a cada frame.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: _glow,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.lg + 4),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.30),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

String journeyRomanNumeral(int n) {
  const map = [
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
    'X',
    'XI',
    'XII',
    'XIII',
    'XIV',
    'XV',
    'XVI',
    'XVII',
    'XVIII',
    'XIX',
    'XX',
  ];
  if (n >= 1 && n <= map.length) return map[n - 1];
  return '$n';
}
