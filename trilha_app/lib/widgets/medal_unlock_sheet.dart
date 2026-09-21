import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pilgrim_medals.dart';
import '../services/medal_engagement_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'confetti_overlay.dart';
import 'medal_cinematic_widgets.dart';
import 'ui_primitives.dart';

Future<void> showTrackDetailSheet(
  BuildContext context,
  PilgrimTrackState trackState, {
  int? highlightLevelIndex,
}) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    elevation: 0,
    isScrollControlled: true,
    enableDrag: true,
    builder: (ctx) => _TrackDetailSheet(
      trackState: trackState,
      highlightLevelIndex: highlightLevelIndex,
    ),
  );
}

Future<void> showTrackTierUpSheet(
  BuildContext context,
  PilgrimTrackTierUp tierUp,
) {
  HapticFeedback.mediumImpact();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    elevation: 0,
    isScrollControlled: true,
    enableDrag: true,
    builder: (ctx) => _TrackDetailSheet(
      trackState: PilgrimTrackState(
        track: tierUp.track,
        levelIndex: tierUp.levelIndex,
      ),
      celebration: true,
      highlightLevelIndex: tierUp.levelIndex,
    ),
  );
}

Future<void> showMedalTileSheet(
  BuildContext context,
  PilgrimMedalTile tile, {
  bool celebration = false,
}) {
  if (celebration) {
    HapticFeedback.mediumImpact();
  } else {
    HapticFeedback.selectionClick();
  }
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    elevation: 0,
    isScrollControlled: true,
    enableDrag: true,
    builder: (ctx) => _MedalDetailSheet(
      tile: tile,
      celebration: celebration,
    ),
  );
}

Future<void> showMedalMysterySheet(BuildContext context, int hiddenCount) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    elevation: 0,
    isScrollControlled: true,
    enableDrag: true,
    builder: (ctx) => _MedalDetailSheet(
      tile: PilgrimMedalTile(
        id: 'discovery:mystery',
        title: hiddenCount == 1 ? 'Uma descoberta' : '$hiddenCount descobertas',
        hint: 'Revelam-se no caminho — sem dica no cofre.',
        glyph: CinematicGlyph.spark,
        tier: PilgrimMedalTier.mirra,
        unlocked: false,
        secret: true,
      ),
    ),
  );
}

Future<void> showMedalDetailSheet(
  BuildContext context,
  PilgrimMedalStatus medal,
) =>
    showMedalTileSheet(context, PilgrimMedalTile.fromRare(medal));

Future<void> showMedalUnlockSheet(
  BuildContext context,
  PilgrimMedalStatus medal,
) =>
    showMedalTileSheet(
      context,
      PilgrimMedalTile.fromRare(medal),
      celebration: true,
    );

class _MedalDetailSheet extends StatefulWidget {
  final PilgrimMedalTile tile;
  final bool celebration;

  const _MedalDetailSheet({
    required this.tile,
    this.celebration = false,
  });

  @override
  State<_MedalDetailSheet> createState() => _MedalDetailSheetState();
}

class _MedalDetailSheetState extends State<_MedalDetailSheet>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _pulse;
  late final Animation<double> _heroScale;
  late final Animation<double> _heroGlow;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _bodyOpacity;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _heroScale = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );
    _heroGlow = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _titleOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.32, 0.62, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.32, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _bodyOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.48, 0.78, curve: Curves.easeOut),
    );

    if (widget.celebration) {
      _entrance.forward();
    } else {
      _entrance.value = 1;
    }
    if (widget.celebration && widget.tile.unlocked) {
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (mounted) HapticFeedback.lightImpact();
      });
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tile = widget.tile;
    final unlocked = tile.unlocked;
    final accent = unlocked
        ? MedalEngagementService.tierColor(tile.tier)
        : a.textMuted(0.45);
    final tier = tierLabel(tile.tier);
    final isDiscovery = tile.secret;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final headline = widget.celebration
        ? (isDiscovery ? 'DESCOBERTA' : 'NOVA CONQUISTA')
        : (unlocked
            ? (isDiscovery ? 'RARA' : tier.toUpperCase())
            : (isDiscovery ? 'DESCOBERTA' : 'A CONQUISTAR'));

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, bottom + 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(
                color: accent.withValues(alpha: unlocked ? 0.8 : 0.28),
                width: 1.5,
              ),
              color: AppColors.night,
              boxShadow: widget.celebration && unlocked
                  ? AppMetrics.cardShadow(elevated: true)
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              child: Stack(
                children: [
                  if (widget.celebration && unlocked)
                    const Positioned.fill(
                      child: ConfettiOverlay(active: true, cinematic: true),
                    ),
                  AnimatedBuilder(
                    animation: Listenable.merge([_pulse, _heroGlow]),
                    builder: (context, _) {
                      final breath =
                          (math.sin(_pulse.value * math.pi * 2) + 1) / 2;
                      return Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: MedalSpotlightPainter(
                              accent: accent,
                              breath: breath,
                              intensity: _heroGlow.value,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _titleOpacity,
                          child: SlideTransition(
                            position: _titleSlide,
                            child: Text(
                              headline,
                              style: AppTypography.label(
                                size: 11,
                                letterSpacing: 2.0,
                                color: accent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        ScaleTransition(
                          scale: _heroScale,
                          child: MedalVaultMedallion(
                            tile: tile,
                            size: 104,
                          ),
                        ),
                        const SizedBox(height: 18),
                        FadeTransition(
                          opacity: _bodyOpacity,
                          child: Column(
                            children: [
                              if (!isDiscovery && unlocked && widget.celebration) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.18),
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.pill),
                                    border: Border.all(
                                      color: accent.withValues(alpha: 0.55),
                                    ),
                                  ),
                                  child: Text(
                                    tier.toUpperCase(),
                                    style: AppTypography.label(
                                      size: 10,
                                      letterSpacing: 1.4,
                                      color: accent,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],
                              Text(
                                tile.title,
                                textAlign: TextAlign.center,
                                style: AppTypography.display(
                                  size: 26,
                                  weight: FontWeight.w900,
                                  color: a.text,
                                ),
                              ),
                              if (tile.hint.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  unlocked || isDiscovery
                                      ? tile.hint
                                      : 'Como conquistar: ${tile.hint}',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.body(
                                    size: 14,
                                    height: 1.5,
                                    color: a.textMuted(0.62),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              CopperCta(
                                label: widget.celebration
                                    ? 'Continuar a jornada'
                                    : (unlocked ? 'Fechar' : 'Entendi'),
                                onTap: () => Navigator.pop(context),
                                trailing: widget.celebration
                                    ? CinematicGlyph.forward
                                    : null,
                                dense: true,
                              ),
                            ],
                          ),
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

class _TrackDetailSheet extends StatefulWidget {
  final PilgrimTrackState trackState;
  final bool celebration;
  final int? highlightLevelIndex;

  const _TrackDetailSheet({
    required this.trackState,
    this.celebration = false,
    this.highlightLevelIndex,
  });

  @override
  State<_TrackDetailSheet> createState() => _TrackDetailSheetState();
}

class _TrackDetailSheetState extends State<_TrackDetailSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    if (widget.celebration) {
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (mounted) HapticFeedback.lightImpact();
      });
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final trackState = widget.trackState;
    final track = trackState.track;
    final current = trackState.currentLevel;
    final accent = current != null
        ? MedalEngagementService.tierColor(current.tier)
        : a.textMuted(0.35);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final celebratedIndex = widget.highlightLevelIndex ??
        (trackState.hasStarted ? trackState.levelIndex : null);
    final celebrated = celebratedIndex != null &&
            celebratedIndex >= 0 &&
            celebratedIndex < track.levels.length
        ? track.levels[celebratedIndex]
        : current;
    final sparkUp = widget.celebration && celebrated?.isSpark == true;
    final headline = widget.celebration
        ? (sparkUp ? 'EMBLEMA ACESO' : 'SUBIU DE NÍVEL')
        : (trackState.hasStarted
            ? (track.kind == PilgrimVaultKind.trail
                ? 'EMBLEMA DA TRILHA'
                : 'EMBLEMA DA JORNADA')
            : 'A CONQUISTAR');

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, bottom + 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(
                color: accent.withValues(
                  alpha: trackState.hasStarted ? 0.8 : 0.28,
                ),
              ),
              color: AppColors.night,
              boxShadow: widget.celebration
                  ? AppMetrics.cardShadow(elevated: true)
                  : null,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.82,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.xl),
                child: Stack(
                  children: [
                    if (widget.celebration)
                      const Positioned.fill(
                        child: ConfettiOverlay(active: true, cinematic: true),
                      ),
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) {
                        final breath =
                            (math.sin(_pulse.value * math.pi * 2) + 1) / 2;
                        return Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: MedalSpotlightPainter(
                                accent: accent,
                                breath: breath,
                                intensity: widget.celebration ||
                                        trackState.hasStarted
                                    ? 1
                                    : 0.35,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              headline,
                              style: AppTypography.label(
                                size: 11,
                                letterSpacing: 2,
                                color: accent,
                              ),
                            ),
                            const SizedBox(height: 18),
                            MedalVaultMedallion(
                              tile: PilgrimMedalTile.fromTrack(trackState),
                              size: widget.celebration ? 112 : 104,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              track.title,
                              textAlign: TextAlign.center,
                              style: AppTypography.display(
                                size: 24,
                                weight: FontWeight.w900,
                                color: a.text,
                              ),
                            ),
                            if (!widget.celebration) ...[
                              const SizedBox(height: 6),
                              Text(
                                track.subtitle,
                                textAlign: TextAlign.center,
                                style: AppTypography.body(
                                  size: 13,
                                  color: a.textMuted(0.55),
                                ),
                              ),
                            ],
                            if (widget.celebration && celebrated != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Agora em ${tierLabel(celebrated.tier)}',
                                style: AppTypography.title(
                                  size: 14,
                                  weight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                celebrated.title,
                                textAlign: TextAlign.center,
                                style: AppTypography.body(
                                  size: 15,
                                  weight: FontWeight.w700,
                                  color: a.text,
                                ),
                              ),
                            ],
                            const SizedBox(height: 22),
                            _AlloyPath(trackState: trackState),
                            const SizedBox(height: 20),
                            CopperCta(
                              label: widget.celebration
                                  ? 'Continuar a jornada'
                                  : 'Fechar',
                              onTap: () => Navigator.pop(context),
                              trailing: widget.celebration
                                  ? CinematicGlyph.forward
                                  : null,
                              dense: true,
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

class _AlloyPath extends StatelessWidget {
  final PilgrimTrackState trackState;

  const _AlloyPath({required this.trackState});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final track = trackState.track;
    final levels = track.levels;
    if (levels.isEmpty) return const SizedBox.shrink();
    final current = trackState.levelIndex;
    final next = trackState.nextLevel;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < levels.length; i++) ...[
              if (i > 0)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tierColor(levels[i - 1].tier).withValues(
                              alpha: i - 1 <= current ? 0.7 : 0.14,
                            ),
                            tierColor(levels[i].tier).withValues(
                              alpha: i <= current ? 0.7 : 0.14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              _AlloyStep(
                track: track,
                level: levels[i],
                unlocked: i <= current,
                lit: i == current && trackState.hasStarted,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (next != null) ...[
          Text(
            next.isSpark ? next.title : '${tierLabel(next.tier)} · ${next.title}',
            textAlign: TextAlign.center,
            style: AppTypography.title(
              size: 14,
              weight: FontWeight.w800,
              color: tierColor(next.tier),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            next.hint,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              color: a.textMuted(0.55),
            ),
          ),
        ] else if (trackState.isComplete) ...[
          Text(
            'A escada está completa.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              color: a.textMuted(0.55),
            ),
          ),
        ],
      ],
    );
  }
}

class _AlloyStep extends StatelessWidget {
  final PilgrimMedalTrackDef track;
  final PilgrimMedalLevelDef level;
  final bool unlocked;
  final bool lit;

  const _AlloyStep({
    required this.track,
    required this.level,
    required this.unlocked,
    required this.lit,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final accent = unlocked ? tierColor(level.tier) : a.textMuted(0.35);
    return Column(
      children: [
        MedalVaultMedallion(
          tile: PilgrimMedalTile(
            id: level.id,
            title: level.title,
            hint: level.hint,
            glyph: track.glyph,
            tier: level.tier,
            unlocked: unlocked,
          ),
          size: lit ? 48 : 34,
        ),
        const SizedBox(height: 6),
        Text(
          tierLabel(level.tier),
          style: AppTypography.label(
            size: 8,
            letterSpacing: 0.8,
            color: accent,
          ),
        ),
      ],
    );
  }
}

Future<void> showMedalVaultCompleteSheet(
  BuildContext context, {
  required String vaultTitle,
  required int total,
}) {
  HapticFeedback.heavyImpact();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    elevation: 0,
    isScrollControlled: true,
    enableDrag: true,
    builder: (ctx) => _MedalVaultCompleteSheet(
      vaultTitle: vaultTitle,
      total: total,
    ),
  );
}

class _MedalVaultCompleteSheet extends StatefulWidget {
  final String vaultTitle;
  final int total;

  const _MedalVaultCompleteSheet({
    required this.vaultTitle,
    required this.total,
  });

  @override
  State<_MedalVaultCompleteSheet> createState() =>
      _MedalVaultCompleteSheetState();
}

class _MedalVaultCompleteSheetState extends State<_MedalVaultCompleteSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, bottom + 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(
            color: AppColors.medalGold.withValues(alpha: 0.85),
            width: 1.5,
          ),
          color: AppColors.night,
          boxShadow: AppMetrics.cardShadow(elevated: true),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: Stack(
            children: [
              const Positioned.fill(
                child: ConfettiOverlay(active: true, cinematic: true),
              ),
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) {
                  final breath =
                      (math.sin(_pulse.value * math.pi * 2) + 1) / 2;
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: MedalSpotlightPainter(
                          accent: AppColors.medalGold,
                          breath: breath,
                          intensity: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'COFRE COMPLETO',
                      style: AppTypography.label(
                        size: 11,
                        letterSpacing: 2,
                        color: AppColors.medalGold,
                      ),
                    ),
                    const SizedBox(height: 22),
                    MedalVaultMedallion(
                      tile: PilgrimMedalTile(
                        id: 'vault:complete',
                        title: widget.vaultTitle,
                        hint: '',
                        glyph: CinematicGlyph.crown,
                        tier: PilgrimMedalTier.gold,
                        unlocked: true,
                      ),
                      size: 96,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.vaultTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.display(
                        size: 24,
                        weight: FontWeight.w900,
                        color: a.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Todas as ${widget.total} conquistas',
                      textAlign: TextAlign.center,
                      style: AppTypography.title(
                        size: 15,
                        weight: FontWeight.w800,
                        color: AppColors.medalGold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Você iluminou cada medalha deste cofre. '
                      'A caravana vê sua vitrine — continue caminhando na Palavra.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 14,
                        height: 1.5,
                        color: a.textMuted(0.65),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CopperCta(
                      label: 'Glória a Deus',
                      onTap: () => Navigator.pop(context),
                      trailing: CinematicGlyph.dove,
                      dense: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
