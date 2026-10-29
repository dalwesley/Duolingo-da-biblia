import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'postcard.dart';
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
  final String? currentSubtitle;
  final String? statusLine;
  final int done;
  final int total;
  final String? semanticsLabel;

  /// Acento do chrome quando difere do [accent] (ex.: modo selado).
  final Color? chrome;

  /// Glifo da trilha / cena — identidade à esquerda.
  final CinematicGlyph? glyph;

  /// Pintura da trilha, em faixa no topo do card.
  final String? art;

  /// Pintura de cena cujo postal ainda não foi revelado: aparece velada.
  final bool artVeiled;

  /// Numeral romano grande no fundo (I, II…).
  final String? watermark;

  /// Cena que pede o Peregrino+: o botão, na largura do card, diz
  /// "Continuar" / "com o Peregrino+" (o toque leva ao paywall).
  final bool plusLocked;

  /// Modo sob o título e a barra no pé, mesmo fora da estação em curso.
  /// Usado nas cenas de cada trilha.
  final bool showMeter;

  const JourneyStationCard({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.state,
    required this.accent,
    required this.glow,
    this.onTap,
    this.currentSubtitle,
    this.statusLine,
    this.done = 0,
    this.total = 0,
    this.semanticsLabel,
    this.chrome,
    this.glyph,
    this.art,
    this.artVeiled = false,
    this.watermark,
    this.plusLocked = false,
    this.showMeter = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == JourneyNodeState.current;
    final isDone = state == JourneyNodeState.completed;
    // Peregrino+ fora da estação em curso: aparência de fechada (cadeado,
    // pintura apagada) e o status "Só no Peregrino+". Sem botão: o amarelo
    // fica só na estação em curso; o toque abre a folha do Plus.
    final plusGate =
        plusLocked &&
        state != JourneyNodeState.current &&
        state != JourneyNodeState.locked &&
        state != JourneyNodeState.soon;
    final isLocked = state == JourneyNodeState.locked || plusGate;
    // Fechada não mostra barra: "Falta 1 cena" fazia parecer aberta.
    final meter = isCurrent || (showMeter && !isLocked);
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
              // Rótulo inteiro numa linha; o estado à direita é que encolhe
              // (dividir a largura meio a meio quebrava "TRILHA III").
              // Com Peregrino+, o nome mora no botão — aqui ele virava
              // "Peregr…".
              Text(
                eyebrow.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 1.3,
                  color: isCurrent
                      ? ink
                      : quiet
                      ? Color.lerp(a.textFaint, accent, 0.4)!
                      : a.textFaint,
                ).copyWith(height: 1),
              ),
              if (isCurrent && !plusLocked) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    context.l10n.journeyNow,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppTypography.label(
                      size: 11,
                      color: ink,
                    ).copyWith(height: 1),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 1),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.display(
              size: isCurrent ? 20 : (quiet ? 16 : 18),
              height: 1.0,
              color: quiet ? a.textSecondary : a.text,
            ),
          ),
          if (meter && currentSubtitle != null) ...[
            const SizedBox(height: 2),
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
          ],
          if (!meter) ...[
            const SizedBox(height: 4),
            Text(
              statusLine ?? _defaultStatus(context, isLocked, isSoon, isDone),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: quiet ? 11 : 12,
                weight: FontWeight.w700,
                height: 1.25,
                color: quiet ? Color.lerp(a.textFaint, accent, 0.32)! : ink,
              ),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (glyph != null) ...[
                  _GlyphPlate(
                    // Fechada: o cadeado no lugar do glifo da cena.
                    glyph: isLocked ? CinematicGlyph.lock : glyph!,
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
            // Fora da coluna do título: ali o rótulo quebrava no meio
            // da palavra ("Continua / r com o / Peregrino / +").
            if (isCurrent && plusLocked) ...[
              const SizedBox(height: 10),
              CopperCta(
                label: context.l10n.commonContinue,
                subtitle: context.l10n.journeyPlusCtaDetail,
                leading: CinematicGlyph.plus,
                trailing: null,
                dense: true,
                decorative: true,
                showGlow: false,
                expanded: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
              ),
            ],
            if (meter && total > 0) ...[
              const Spacer(),
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
              const SizedBox(height: 2),
              AppProgressBar(
                value: done / total,
                color: ink,
                trackColor: a.progressTrack,
                height: 6,
              ),
            ],
          ],
        ),
      ],
    );

    // A pintura é o card, não uma faixa. O véu segura o texto e a cena
    // aparece no card inteiro.
    Widget withArt(Widget content) {
      if (art == null) return content;
      final morning = a.look == AppearanceLook.morning;
      final veil = morning ? const Color(0xFFF7FBFE) : a.cardFill;
      // Trilha em curso ou já feita: o véu claro cobre demais a pintura.
      final alphas = morning && (isCurrent || isDone)
          ? const [0.34, 0.14, 0.04]
          : isLocked
          ? const [0.82, 0.70, 0.60]
          : const [0.55, 0.28, 0.16];
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final cacheW = (MediaQuery.sizeOf(context).width * dpr).round();
      final painting = SceneArtImage(
        art!,
        veiled: artVeiled,
        // Decode na resolução do card — JPGs de cena são bem maiores.
        cacheWidth: cacheW,
        cacheHeight: (160 * dpr).round(),
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            // Fechada: pintura sem cor, apagada sob o véu.
            child: isLocked
                ? ColorFiltered(colorFilter: _grayscale, child: painting)
                : painting,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    veil.withValues(alpha: alphas[0]),
                    veil.withValues(alpha: alphas[1]),
                    veil.withValues(alpha: alphas[2]),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          content,
        ],
      );
    }

    final pad = EdgeInsets.fromLTRB(
      quiet ? 12 : 14,
      quiet ? 10 : 12,
      quiet ? 12 : 14,
      meter && total > 0 ? 8 : (quiet ? 10 : 12),
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
              fit: StackFit.expand,
              children: [
                withArt(
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      14,
                      isCurrent ? 14 : 12,
                      14,
                      meter && total > 0 ? 8 : 12,
                    ),
                    child: body,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 18,
                  right: 18,
                  child: CardFilament(color: ink, height: 2),
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
            fit: StackFit.expand,
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
              withArt(Padding(padding: pad, child: body)),
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
            depth: quiet && !plusGate ? 0 : (isCurrent ? 3 : 2),
            child: beacon,
          );

    return Semantics(
      label: semanticsLabel ?? title,
      button: onTap != null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final room = constraints.maxWidth;
          // No tablet a coluna é mais larga: o teto do celular corta
          // o título ("Deuteronômio") e deixa o card minúsculo no vão.
          // Todas as estações usam o tamanho da trilha em curso.
          final wide = room >= 440;
          const fraction = 0.72;
          final cap = wide ? 320.0 : 220.0;
          final floor = wide ? 220.0 : 148.0;
          final preferred = math.min(cap, math.max(floor, room * fraction));
          final width = math.min(preferred, constraints.maxWidth);
          // Altura medida no card em curso (título, modo, barra, cenas).
          // O Peregrino+ soma o botão e passa desse piso.
          // A fonte do app (Ajustes, até 1,35×) cresce o texto: a altura
          // cresce junto, senão título de 2 linhas + botão estouram.
          final scale = MediaQuery.textScalerOf(
            context,
          ).scale(1).clamp(1.0, 1.35);
          final height = (isCurrent && plusLocked ? 182.0 : 129.0) * scale;
          return SizedBox(width: width, height: height, child: tappable);
        },
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

const _grayscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0,
]);

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
      fit: StackFit.expand,
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
