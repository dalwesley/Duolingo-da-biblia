import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cinematic/cinematic_resolver.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/dust_copy.dart';
import '../utils/layout_utils.dart';
import '../utils/tomorrow_hook.dart';
import '../utils/trail_visuals.dart';
import 'act_feel.dart';
import 'cinematic_backdrop.dart';
import 'cinematic_icon.dart';
import 'hero_card_atmosphere.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Próxima cena — CTA único. Três faces cinematográficas:
/// em risco = poeira + teia · gelo usado = congelado · em dia = vidro limpo.
class HeroContinueCard extends StatefulWidget {
  final Mission? mission;
  final String trailTitle;
  final String trailSlug;
  final String trailColor;
  final VoidCallback? onTap;
  final VoidCallback? onExploreTrails;
  final bool goalMet;
  final bool atRisk;

  const HeroContinueCard({
    super.key,
    required this.mission,
    required this.trailTitle,
    this.trailSlug = 'genesis-1-11',
    this.trailColor = '#1B3A5C',
    this.onTap,
    this.onExploreTrails,
    this.goalMet = false,
    this.atRisk = false,
  });

  /// Altura estimada do header da Home acima do hero (saudação + pulso +
  /// semana). Usada só para caber o CTA acima do menu flutuante.
  static const homeHeaderReserve = 144.0;

  /// Menor palco que ainda comporta título + CTA sem cortar.
  static const minStageHeight = 360.0;

  /// Palco adaptativo: o ideal de [AppMetrics.heroStageHeight], mas nunca
  /// empurrando o CTA para trás do menu flutuante no primeiro viewport.
  static double stageHeight(BuildContext context) {
    final screen = MediaQuery.sizeOf(context).height;
    final ideal = AppMetrics.heroStageHeight(screen);
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4);
    final above =
        MediaQuery.viewPaddingOf(context).top +
        AppSpace.sm +
        homeHeaderReserve * textScale +
        AppSpace.lg;
    final room = screen - above - scrollPaddingBelowNav(context);
    return math.min(ideal, math.max(minStageHeight, room));
  }

  @override
  State<HeroContinueCard> createState() => _HeroContinueCardState();
}

class _HeroContinueCardState extends State<HeroContinueCard>
    with TickerProviderStateMixin {
  Timer? _tick;
  late final AnimationController _pulseController;
  late final AnimationController _burst;
  final _stageKey = GlobalKey();
  Offset _burstOrigin = Offset.zero;
  bool _launching = false;
  bool _pressed = false;
  String? _readerTease;
  String? _readerTeaseKey;

  @override
  void initState() {
    super.initState();
    _syncTick(widget.atRisk);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
  }

  /// Toque vira gesto: o pó sopra / o gelo trinca / a luz abre — e só então
  /// a cena abre. Curto o bastante para não parecer atraso.
  Future<void> _launch(Offset globalPosition) async {
    if (_launching) return;
    _launching = true;
    final box = _stageKey.currentContext?.findRenderObject() as RenderBox?;
    _burstOrigin = box != null
        ? box.globalToLocal(globalPosition)
        : Offset.zero;
    ActHaptics.confirm();
    unawaited(_burst.forward(from: 0));
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    widget.onTap?.call();
    // Timer, não o ticker: sob a rota nova o ticker fica mudo e a rajada
    // reapareceria na volta.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _burst.stop();
    _burst.value = 0;
    _launching = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadReaderTease();
  }

  @override
  void didUpdateWidget(covariant HeroContinueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.atRisk != widget.atRisk) {
      _syncTick(widget.atRisk);
    }
    if (oldWidget.mission?.slug != widget.mission?.slug ||
        oldWidget.mission?.hookRef != widget.mission?.hookRef) {
      _readerTease = null;
      _readerTeaseKey = null;
    }
    _loadReaderTease();
  }

  void _syncTick(bool atRisk) {
    _tick?.cancel();
    _tick = null;
    if (!atRisk) return;
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _loadReaderTease() {
    final mission = widget.mission;
    if (mission == null) return;
    final translationId = context
        .read<ProgressService>()
        .settings
        .bibleTranslationId;
    final key = '${mission.slug}|${mission.hookRef}|$translationId';
    if (key == _readerTeaseKey) return;
    _readerTeaseKey = key;
    unawaited(_resolveReaderTease(mission, key));
  }

  Future<void> _resolveReaderTease(Mission mission, String key) async {
    final text = await TomorrowHook.readerTease(mission);
    if (!mounted || _readerTeaseKey != key) return;
    if (text == _readerTease) return;
    setState(() => _readerTease = text);
  }

  @override
  void dispose() {
    _tick?.cancel();
    _pulseController.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;
    if (mission == null) return _completedState(context);

    final a = Appearance.of(context);
    final visuals = TrailVisuals.forSlug(
      widget.trailSlug,
      color: widget.trailColor,
    );
    final trailAccent = visuals.accent;
    final progress = context.watch<ProgressService>();
    final hasFreeze = progress.hasStreakFreeze;
    final walkedToday = progress.walkedToday;
    final returningAfterGap = progress.isReturningAfterGap;
    final mood = resolveHeroCardMood(
      atRisk: widget.atRisk,
      yesterdayFrozen: progress.yesterdayWasFrozen,
      walkedToday: walkedToday,
      returningAfterGap: returningAfterGap,
    );
    if (mood == HeroCardMood.alive) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else if (_pulseController.isAnimating) {
      _pulseController.stop();
    }
    final style = HeroCardMoodStyle.of(mood, trailAccent: trailAccent);

    // Em dia: o cartão é o trailer de amanhã — o ouro convida a abrir agora.
    final resting = widget.goalMet && mood == HeroCardMood.alive;
    final arrived =
        !walkedToday &&
        TomorrowHook.promisedArrived(
          promisedTitle: progress.nextSceneTitle,
          currentTitle: mission.title,
        );
    final yesterday = !walkedToday
        ? TomorrowHook.yesterdayLine(progress.lastInsight)
        : null;
    final echoDoor = !walkedToday && arrived
        ? TomorrowHook.echoDoorLine(progress.lastEchoQuestion)
        : null;
    final ctaLabel = switch (mood) {
      HeroCardMood.frozen => 'Retomar a trilha',
      HeroCardMood.dusty => 'Continuar a trilha',
      HeroCardMood.alive =>
        resting
            ? 'Abrir agora'
            : walkedToday
            ? 'Continuar'
            : echoDoor != null
            ? 'Descobrir'
            : 'Entrar',
    };
    final rewardColor = mission.isBoss ? AppColors.sand : style.footer;
    final world = CinematicResolver.ambientForHome(
      trailSlug: widget.trailSlug,
      missionTitle: mission.title,
      missionSlug: mission.slug,
    );

    final countdown = progress.streakRiskCountdown;
    final riskLine = switch (mood) {
      HeroCardMood.frozen => 'O gelo cobriu ontem · sequência preservada',
      HeroCardMood.dusty =>
        returningAfterGap
            ? DustCopy.heroGapLine(hasFreeze: hasFreeze)
            : DustCopy.heroRiskLine(
                countdown: countdown,
                hasFreeze: hasFreeze,
                streak: progress.streak,
              ),
      HeroCardMood.alive => null,
    };

    final tease = resting
        ? TomorrowHook.pullOf(mission)
        : (_readerTease ?? TomorrowHook.teaseOf(mission));

    final stepLabel = switch (mood) {
      HeroCardMood.frozen => style.stepLabel,
      HeroCardMood.dusty => style.stepLabel,
      HeroCardMood.alive =>
        resting
            ? 'Amanhã'
            : echoDoor != null
            ? 'Eco de ontem'
            : arrived
            ? 'Hoje'
            : walkedToday
            ? 'Em dia'
            : 'Cena pronta',
    };

    final heroHeight = HeroContinueCard.stageHeight(context);
    // Palco baixo (telas ~800dp com header): título em 2 linhas, sem cortar.
    final compact = heroHeight < 400;
    final borderWidth =
        style.borderWidth + (mood == HeroCardMood.alive ? 0.6 : 0);

    return Semantics(
      button: true,
      label: '$ctaLabel · ${mission.title}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (details) {
          setState(() => _pressed = false);
          if (resting) return;
          _launch(details.globalPosition);
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.986 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
            height: heroHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
              border: Border.all(color: style.border, width: borderWidth),
              boxShadow: [
                ...AppMetrics.cardShadow(elevated: true, hardLip: false),
                if (mood == HeroCardMood.alive)
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.22),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
              ],
            ),
            child: ClipRRect(
              key: _stageKey,
              borderRadius: BorderRadius.circular(
                (AppMetrics.heroRadius - borderWidth).clamp(
                  0.0,
                  AppMetrics.heroRadius,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: HeroCardColorGrade(
                      mood: mood,
                      child: CinematicBackdrop(world: world),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: _scrimColors(mood, a.cardFill),
                          stops: const [0.0, 0.38, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Peso da atmosfera sob o texto; só partículas finas por cima.
                  Positioned.fill(
                    child: HeroCardAtmosphere(
                      mood: mood,
                      layer: HeroAtmosphereLayer.back,
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Chip(
                            tone: trailAccent,
                            worn: mood == HeroCardMood.dusty,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    final scale = mood == HeroCardMood.alive
                                        ? 1.0 + _pulseController.value * 0.06
                                        : 1.0;
                                    return Transform.scale(
                                      scale: scale,
                                      alignment: Alignment.center,
                                      child: child,
                                    );
                                  },
                                  child: CinematicIcon(
                                    glyph: visuals.glyph,
                                    size: 16,
                                    accent: trailAccent,
                                    glowing: false,
                                    framed: false,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SectionLabel(
                                  widget.trailTitle,
                                  size: 10,
                                  color: mood == HeroCardMood.dusty
                                      ? a.textSecondary
                                      : a.text,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(flex: 2),
                          SectionLabel(stepLabel, size: 13, color: style.label),
                          SizedBox(height: compact ? 6 : 10),
                          Text(
                            mission.title,
                            maxLines: compact ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.display(
                              size: compact ? 28 : 32,
                              height: 1.08,
                              weight: FontWeight.w900,
                              color: switch (mood) {
                                HeroCardMood.dusty => const Color(
                                  0xFFDCC7A4,
                                ).withValues(alpha: 0.92),
                                HeroCardMood.frozen => const Color(
                                  0xFFE8F6FC,
                                ).withValues(alpha: 0.95),
                                HeroCardMood.alive => a.text,
                              },
                            ),
                          ),
                          if (riskLine != null) ...[
                            SizedBox(height: compact ? 8 : 12),
                            Flexible(
                              child: Text(
                                riskLine,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body(
                                  size: 14,
                                  weight: FontWeight.w700,
                                  height: 1.35,
                                  color: style.label.withValues(alpha: 0.92),
                                ),
                              ),
                            ),
                          ],
                          if (tease.trim().isNotEmpty &&
                              mood != HeroCardMood.dusty) ...[
                            if (arrived && yesterday != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                yesterday,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: a.textFaint,
                                ),
                              ),
                            ],
                            if (echoDoor != null) ...[
                              const SizedBox(height: 10),
                              Flexible(
                                child: Text(
                                  echoDoor,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.verse(
                                    size: 18,
                                    height: 1.35,
                                    fontStyle: FontStyle.italic,
                                    color: a.text,
                                  ),
                                ),
                              ),
                            ] else ...[
                              SizedBox(height: compact ? 8 : 12),
                              Flexible(
                                child: Text(
                                  tease,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.verse(
                                    size: 20,
                                    height: 1.35,
                                    color: a.text,
                                  ),
                                ),
                              ),
                            ],
                          ] else if (mission.subtitle.trim().isNotEmpty &&
                              mood == HeroCardMood.dusty) ...[
                            const SizedBox(height: 10),
                            Flexible(
                              child: Text(
                                mission.subtitle.trim(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body(
                                  size: 14,
                                  weight: FontWeight.w600,
                                  color: a.textSecondary,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(flex: 3),
                          if (resting)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (d) => _launch(d.globalPosition),
                              child: _CtaBar(label: ctaLabel, mood: mood),
                            )
                          else
                            _CtaBar(label: ctaLabel, mood: mood),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              resting
                                  ? '+${mission.stepsReward} passos · extra de hoje'
                                  : mood == HeroCardMood.dusty
                                  ? 'Protege a sequência · ~3 min'
                                  : '~3 min',
                              style: AppTypography.body(
                                size: 13,
                                weight: FontWeight.w700,
                                color: rewardColor.withValues(alpha: 0.78),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (mood != HeroCardMood.alive)
                    Positioned.fill(
                      child: HeroCardAtmosphere(
                        mood: mood,
                        layer: HeroAtmosphereLayer.front,
                      ),
                    ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _burst,
                        builder: (context, _) => CustomPaint(
                          painter: HeroTapBurstPainter(
                            mood: mood,
                            progress: _burst.value,
                            origin: _burstOrigin,
                          ),
                        ),
                      ),
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

  List<Color> _scrimColors(HeroCardMood mood, Color cardFill) {
    return switch (mood) {
      HeroCardMood.frozen => [
        AppColors.iceDeep.withValues(alpha: 0.35),
        Color.lerp(
          Colors.black,
          AppColors.iceDeep,
          0.35,
        )!.withValues(alpha: 0.48),
        Color.lerp(cardFill, AppColors.iceDeep, 0.55)!.withValues(alpha: 0.92),
      ],
      HeroCardMood.dusty => [
        const Color(0xFF3A2410).withValues(alpha: 0.7),
        const Color(0xFF140C06).withValues(alpha: 0.76),
        Color.lerp(
          cardFill,
          const Color(0xFF0A0604),
          0.82,
        )!.withValues(alpha: 0.96),
      ],
      // Scrim mais leve no topo — deixa o vidro / reflexo aparecer
      HeroCardMood.alive => [
        Colors.black.withValues(alpha: 0.06),
        Colors.black.withValues(alpha: 0.28),
        Color.lerp(cardFill, Colors.black, 0.22)!.withValues(alpha: 0.82),
      ],
    };
  }

  Widget _completedState(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      onTap: widget.onExploreTrails,
      glow: 0.3,
      tint: AppColors.accent,
      radius: AppMetrics.heroRadius,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.crown,
            size: 56,
            accent: AppColors.accent,
            glowing: false,
          ),
          const SizedBox(height: 16),
          Text(
            'Trilha concluída',
            style: AppTypography.display(size: 28, color: a.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha a próxima e continue aprendendo.',
            textAlign: TextAlign.center,
            style: AppTypography.body(color: a.textSecondary),
          ),
          if (widget.onExploreTrails != null) ...[
            const SizedBox(height: 20),
            // Antes vinha sem onTap e aparecia apagado (parecia desligado).
            CopperCta(
              label: 'Explorar trilhas',
              expanded: false,
              onTap: widget.onExploreTrails,
            ),
          ],
        ],
      ),
    );
  }
}

class _CtaBar extends StatelessWidget {
  final String label;
  final HeroCardMood mood;

  const _CtaBar({required this.label, required this.mood});

  @override
  Widget build(BuildContext context) {
    if (mood == HeroCardMood.alive) {
      return _AliveShineCta(label: label);
    }

    final frozen = mood == HeroCardMood.frozen;
    final ink = frozen ? AppColors.iceDeep : AppColors.inkOnAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: frozen ? null : const Color(0xFFB89858),
        gradient: frozen
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.ice, Color(0xFF3A8AAA)],
              )
            : null,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: frozen
            ? Border.all(color: AppColors.iceDeep.withValues(alpha: 0.55))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.cta(size: 18).copyWith(color: ink),
          ),
          const SizedBox(width: 12),
          CinematicIcon(
            glyph: CinematicGlyph.forward,
            size: 22,
            accent: ink,
            framed: false,
          ),
        ],
      ),
    );
  }
}

/// CTA em dia — açafrão chapado, sem reflexo.
class _AliveShineCta extends StatelessWidget {
  final String label;

  const _AliveShineCta({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.cta(
              size: 18,
            ).copyWith(color: AppColors.inkOnAccent, letterSpacing: 1.4),
          ),
          const SizedBox(width: 12),
          CinematicIcon(
            glyph: CinematicGlyph.forward,
            size: 22,
            accent: AppColors.inkOnAccent.withValues(alpha: 0.9),
            framed: false,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final Widget child;
  final Color? tone;
  final bool worn;

  const _Chip({required this.child, this.tone, this.worn = false});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = tone;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: worn
            ? const Color(0xFF1A1008).withValues(alpha: 0.55)
            : ink != null
            ? Colors.black.withValues(alpha: 0.35)
            : a.cardFill,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          width: 1.5,
          color: worn
              ? const Color(0xFF6B4A28).withValues(alpha: 0.5)
              : ink != null
              ? ink.withValues(alpha: 0.55)
              : a.cardBorder,
        ),
      ),
      child: child,
    );
  }
}
