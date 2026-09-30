import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../models/pilgrim_medals.dart';
import '../models/recognition.dart';
import '../services/medal_engagement_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'confetti_overlay.dart';
import 'medal_cinematic_widgets.dart';
import 'recognition_actions.dart';
import 'ui_primitives.dart';

Future<void> showTrackDetailSheet(
  BuildContext context,
  PilgrimTrackState trackState, {
  int? highlightLevelIndex,
  String? recognizeToUid,
}) {
  ActHaptics.tap();
  return showAppSheet<void>(
    context,
    enableDrag: true,
    builder: (ctx) => _TrackDetailSheet(
      trackState: trackState,
      highlightLevelIndex: highlightLevelIndex,
      recognizeToUid: recognizeToUid,
    ),
  );
}

Future<void> showTrackTierUpSheet(
  BuildContext context,
  PilgrimTrackTierUp tierUp,
) {
  ActHaptics.confirm();
  return showAppSheet<void>(
    context,
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
  String? recognizeToUid,
}) {
  if (celebration) {
    ActHaptics.confirm();
  } else {
    ActHaptics.tap();
  }
  return showAppSheet<void>(
    context,
    enableDrag: true,
    builder: (ctx) => _MedalDetailSheet(
      tile: tile,
      celebration: celebration,
      recognizeToUid: recognizeToUid,
    ),
  );
}

Future<void> showMedalMysterySheet(BuildContext context, int hiddenCount) {
  ActHaptics.tap();
  return showAppSheet<void>(
    context,
    enableDrag: true,
    builder: (ctx) => _MedalDetailSheet(
      tile: PilgrimMedalTile(
        id: 'discovery:mystery',
        title: ctx.l10n.medalMysteryTitle(hiddenCount),
        hint: ctx.l10n.medalMysteryHint,
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
) => showMedalTileSheet(context, PilgrimMedalTile.fromRare(medal));

Future<void> showMedalUnlockSheet(
  BuildContext context,
  PilgrimMedalStatus medal,
) => showMedalTileSheet(
  context,
  PilgrimMedalTile.fromRare(medal),
  celebration: true,
);

class _MedalDetailSheet extends StatefulWidget {
  final PilgrimMedalTile tile;
  final bool celebration;
  final String? recognizeToUid;

  const _MedalDetailSheet({
    required this.tile,
    this.celebration = false,
    this.recognizeToUid,
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
        if (mounted) ActHaptics.light();
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
        : a.textFaint;
    final tier = tierLabel(tile.tier);
    final isDiscovery = tile.secret;
    final ultra = tile.tier == PilgrimMedalTier.aurora;
    final l10n = context.l10n;
    final headline = widget.celebration
        ? (ultra
              ? l10n.medalTierAurora
              : (isDiscovery
                    ? l10n.medalHeadlineDiscovery
                    : l10n.medalHeadlineNew))
        : (unlocked
              ? (ultra
                    ? l10n.medalTierAurora
                    : (isDiscovery ? l10n.medalHeadlineRare : tier))
              : (isDiscovery
                    ? l10n.medalHeadlineDiscovery
                    : l10n.medalHeadlineLocked));

    return AppSheetPanel(
      tint: unlocked ? accent : null,
      padding: const EdgeInsets.fromLTRB(24, AppSpace.md, 24, 24),
      background: Stack(
        children: [
          if (widget.celebration && unlocked)
            const Positioned.fill(
              child: ConfettiOverlay(active: true, cinematic: true),
            ),
          AnimatedBuilder(
            animation: Listenable.merge([_pulse, _heroGlow]),
            builder: (context, _) {
              final breath = (math.sin(_pulse.value * math.pi * 2) + 1) / 2;
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
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _titleOpacity,
            child: SlideTransition(
              position: _titleSlide,
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SectionLabel(headline, color: accent),
                    if (!widget.celebration && unlocked)
                      Align(
                        alignment: Alignment.centerRight,
                        child: RecognizeHeartButton(
                          toUid: widget.recognizeToUid,
                          kind: RecognitionKind.medal,
                          subjectKey: tile.id,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          ScaleTransition(
            scale: _heroScale,
            child: MedalVaultMedallion(tile: tile, size: 104),
          ),
          const SizedBox(height: 18),
          FadeTransition(
            opacity: _bodyOpacity,
            child: Column(
              children: [
                if (!isDiscovery && unlocked && widget.celebration) ...[
                  SoftBadge(text: tier, accent: accent),
                  const SizedBox(height: 14),
                ],
                Text(
                  tile.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.display(
                    size: widget.celebration ? 28 : 24,
                    weight: FontWeight.w900,
                    color: a.text,
                  ),
                ),
                if (tile.hint.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    unlocked || isDiscovery
                        ? tile.hint
                        : context.l10n.medalHowToEarn(tile.hint),
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 14,
                      height: 1.5,
                      color: a.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                CopperCta(
                  label: widget.celebration
                      ? context.l10n.commonContinue
                      : (unlocked
                            ? context.l10n.commonClose
                            : context.l10n.commonGotIt),
                  onTap: () => Navigator.pop(context),
                  trailing: widget.celebration ? CinematicGlyph.forward : null,
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackDetailSheet extends StatefulWidget {
  final PilgrimTrackState trackState;
  final bool celebration;
  final int? highlightLevelIndex;
  final String? recognizeToUid;

  const _TrackDetailSheet({
    required this.trackState,
    this.celebration = false,
    this.highlightLevelIndex,
    this.recognizeToUid,
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
        if (mounted) ActHaptics.light();
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
        : a.textFaint;
    final celebratedIndex =
        widget.highlightLevelIndex ??
        (trackState.hasStarted ? trackState.levelIndex : null);
    final celebrated =
        celebratedIndex != null &&
            celebratedIndex >= 0 &&
            celebratedIndex < track.levels.length
        ? track.levels[celebratedIndex]
        : current;
    final sparkUp = widget.celebration && celebrated?.isSpark == true;
    final l10n = context.l10n;
    final headline = widget.celebration
        ? (sparkUp ? l10n.medalHeadlineLit : l10n.medalHeadlineLevelUp)
        : (trackState.hasStarted
              ? (track.kind == PilgrimVaultKind.trail
                    ? l10n.medalHeadlineTrail
                    : l10n.medalHeadlineJourney)
              : l10n.medalHeadlineLocked);

    return AppSheetPanel(
      tint: trackState.hasStarted ? accent : null,
      padding: const EdgeInsets.only(top: AppSpace.md),
      background: Stack(
        children: [
          if (widget.celebration)
            const Positioned.fill(
              child: ConfettiOverlay(active: true, cinematic: true),
            ),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final breath = (math.sin(_pulse.value * math.pi * 2) + 1) / 2;
              return Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: MedalSpotlightPainter(
                      accent: accent,
                      breath: breath,
                      intensity: widget.celebration || trackState.hasStarted
                          ? 1
                          : 0.35,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      child: ConstrainedBox(
        // Alça e margens do painel ficam fora da área rolável.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82 - 32,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SectionLabel(headline, color: accent),
                    if (!widget.celebration &&
                        trackState.hasStarted &&
                        current != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: RecognizeHeartButton(
                          toUid: widget.recognizeToUid,
                          kind: RecognitionKind.medal,
                          subjectKey: current.id,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                  ],
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
                  style: AppTypography.body(size: 13, color: a.textFaint),
                ),
              ],
              if (widget.celebration && celebrated != null) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.medalNowTier(tierLabel(celebrated.tier)),
                  style: AppTypography.title(size: 14, color: accent),
                ),
                const SizedBox(height: 6),
                Text(
                  celebrated.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    size: 14,
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
                    ? context.l10n.commonContinue
                    : context.l10n.commonClose,
                onTap: () => Navigator.pop(context),
                trailing: widget.celebration ? CinematicGlyph.forward : null,
                dense: true,
              ),
            ],
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
                            tierColor(
                              levels[i - 1].tier,
                            ).withValues(alpha: i - 1 <= current ? 0.7 : 0.14),
                            tierColor(
                              levels[i].tier,
                            ).withValues(alpha: i <= current ? 0.7 : 0.14),
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
            next.isSpark
                ? next.title
                : '${tierLabel(next.tier)} · ${next.title}',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 14, color: tierColor(next.tier)),
          ),
          const SizedBox(height: 4),
          Text(
            next.hint,
            textAlign: TextAlign.center,
            style: AppTypography.body(size: 13, color: a.textFaint),
          ),
        ] else if (trackState.isComplete) ...[
          Text(
            context.l10n.medalAllLevelsDone,
            textAlign: TextAlign.center,
            style: AppTypography.body(size: 13, color: a.textFaint),
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
    final accent = unlocked ? tierColor(level.tier) : a.textFaint;
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
            size: 10,
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
  ActHaptics.success();
  return showAppSheet<void>(
    context,
    enableDrag: true,
    builder: (ctx) =>
        _MedalVaultCompleteSheet(vaultTitle: vaultTitle, total: total),
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

    return AppSheetPanel(
      tint: AppColors.medalGold,
      padding: const EdgeInsets.fromLTRB(24, AppSpace.md, 24, 24),
      background: Stack(
        children: [
          const Positioned.fill(
            child: ConfettiOverlay(active: true, cinematic: true),
          ),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final breath = (math.sin(_pulse.value * math.pi * 2) + 1) / 2;
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
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SectionLabel(
            context.l10n.medalVaultCompleteLabel,
            color: AppColors.medalGold,
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
            context.l10n.medalVaultAllMedals(widget.total),
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 14, color: AppColors.medalGold),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.medalVaultCompleteBody,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.5,
              color: a.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          CopperCta(
            label: context.l10n.commonGotIt,
            onTap: () => Navigator.pop(context),
            trailing: CinematicGlyph.dove,
            dense: true,
          ),
        ],
      ),
    );
  }
}
