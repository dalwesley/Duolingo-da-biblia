import 'package:flutter/material.dart';

import '../l10n/app_language.dart';

import '../data/trail_repository.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medals.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'medal_cinematic_widgets.dart';
import 'medal_unlock_sheet.dart';
import 'recognition_heart_badge.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';
import 'profile_privacy.dart';
import 'relic_panel.dart';
import '../models/caravan_profile_prefs.dart';

/// Cofre — medalhas da jornada e das trilhas no mesmo grupo.
class PilgrimMedalVaultsPanel extends StatefulWidget {
  final CaravanPilgrimProfile profile;
  final PilgrimMedalEvalContext evalContext;

  /// Quando visita outro peregrino — coração no sheet do emblema.
  final String? recognizeToUid;

  /// Dono sem nenhuma medalha — CTA que leva de volta à trilha.
  final VoidCallback? onStartWalking;

  /// Dentro do cofre: só o miolo, sem o cartão próprio.
  final bool embedded;

  const PilgrimMedalVaultsPanel({
    super.key,
    required this.profile,
    this.evalContext = const PilgrimMedalEvalContext(),
    this.recognizeToUid,
    this.onStartWalking,
    this.embedded = false,
  });

  @override
  State<PilgrimMedalVaultsPanel> createState() =>
      _PilgrimMedalVaultsPanelState();
}

class _PilgrimMedalVaultsPanelState extends State<PilgrimMedalVaultsPanel> {
  List<PilgrimVaultState>? _vaults;
  List<Trail> _catalog = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PilgrimMedalVaultsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile ||
        oldWidget.evalContext.clock != widget.evalContext.clock) {
      _load();
    }
  }

  Future<void> _load() async {
    final catalog = await TrailRepository().getTrails();
    if (!mounted) return;
    final vaults = PilgrimMedals.evaluateVaults(
      profile: widget.profile,
      catalog: catalog,
      ctx: widget.evalContext,
    );
    setState(() {
      _catalog = catalog;
      _vaults = vaults;
    });
  }

  PilgrimVaultState? get _journeyVault {
    for (final vault in _vaults ?? const <PilgrimVaultState>[]) {
      if (vault.vault.kind == PilgrimVaultKind.journey) return vault;
    }
    return null;
  }

  List<PilgrimVaultState> get _trailVaults =>
      _vaults?.where((v) => v.vault.kind == PilgrimVaultKind.trail).toList() ??
      const [];

  PilgrimVaultState? get _discoveryVault {
    for (final vault in _vaults ?? const <PilgrimVaultState>[]) {
      if (vault.vault.kind == PilgrimVaultKind.discovery) return vault;
    }
    return null;
  }

  PilgrimVaultState? get _seasonVault {
    for (final vault in _vaults ?? const <PilgrimVaultState>[]) {
      if (vault.vault.kind == PilgrimVaultKind.season) return vault;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vaults = _vaults;
    if (vaults == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpace.lg),
        child: AppSpinner(),
      );
    }

    final journey = _journeyVault;
    final trailVaults = _trailVaults;
    final tracks = <PilgrimTrackState>[
      ...?journey?.tracks,
      ...?_seasonVault?.tracks,
      for (final vault in trailVaults)
        if (vault.tracks.isNotEmpty) vault.tracks.first,
    ];

    final proximity = PilgrimMedals.nearestLocked(
      profile: widget.profile,
      catalog: _catalog,
      ctx: widget.evalContext,
    );

    final rareTiles = PilgrimMedals.visibleDiscoveryTiles(_discoveryVault);
    final hiddenRares = PilgrimMedals.hiddenDiscoveryCount(_discoveryVault);

    final a = Appearance.of(context);
    final anyLit = vaults.any((v) => v.unlockedCount > 0);
    final showEmpty = !anyLit && widget.onStartWalking != null;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.embedded)
          RelicChapter(
            title: context.l10n.medalVaultTitle,
            accent: AppColors.medalGold,
            divided: false,
            action: PrivacyEye(
              sections: const {CaravanProfileSection.medals},
              label: context.l10n.medalVaultTitle,
            ),
          ),
        if (!widget.embedded) const SizedBox(height: AppSpace.md),
        if (showEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: Text(
              context.l10n.medalVaultEmptyHint,
              style: AppTypography.body(size: 13, color: a.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpace.md),
        ],
        if (tracks.isNotEmpty)
          _MedalGrid(
            tracks: tracks,
            featuredTrackId: proximity?.track.id,
            recognizeToUid: widget.recognizeToUid,
          ),
        if (rareTiles.isNotEmpty || hiddenRares > 0) ...[
          const SizedBox(height: AppSpace.lg),
          _RareStrip(
            tiles: rareTiles,
            hiddenCount: hiddenRares,
            recognizeToUid: widget.recognizeToUid,
          ),
        ],
        if (showEmpty) ...[
          const SizedBox(height: AppSpace.lg),
          CopperCta(
            label: context.l10n.commonNextScene,
            dense: true,
            leading: CinematicGlyph.path,
            trailing: null,
            onTap: widget.onStartWalking,
          ),
        ],
      ],
    );
    if (widget.embedded) return body;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: MedalSpotlightPainter(
                    accent: AppColors.medalGold,
                    intensity: 0.9,
                  ),
                ),
              ),
            ),
            Padding(padding: AppMetrics.cardPadding, child: body),
          ],
        ),
      ),
    );
  }
}

class _MedalGrid extends StatelessWidget {
  final List<PilgrimTrackState> tracks;
  final String? featuredTrackId;
  final String? recognizeToUid;

  const _MedalGrid({
    required this.tracks,
    this.featuredTrackId,
    this.recognizeToUid,
  });

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        const cols = 5;
        final cell = constraints.maxWidth / cols;
        return Wrap(
          children: [
            for (final track in tracks)
              SizedBox(
                width: cell,
                child: MedalTrackEmblem(
                  trackState: track,
                  featured: track.track.id == featuredTrackId,
                  heartKeys: recognizeToUid == null
                      ? track.earnedMedalIds
                      : null,
                  onTap: () => showTrackDetailSheet(
                    context,
                    track,
                    recognizeToUid: recognizeToUid,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RareStrip extends StatelessWidget {
  final List<PilgrimMedalTile> tiles;
  final int hiddenCount;
  final String? recognizeToUid;

  const _RareStrip({
    required this.tiles,
    required this.hiddenCount,
    this.recognizeToUid,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListDivider(),
        const SizedBox(height: AppSpace.md),
        _VaultSubhead(
          context.l10n.medalVaultDiscoveries,
          color: AppColors.medalMirra.withValues(alpha: 0.92),
        ),
        if (tiles.isNotEmpty) ...[
          const SizedBox(height: AppSpace.sm + 2),
          Wrap(
            spacing: AppSpace.sm + 2,
            runSpacing: AppSpace.sm + 2,
            children: [
              for (final tile in tiles)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    MedalVaultMedallion(
                      tile: tile,
                      size: 52,
                      onTap: () => showMedalTileSheet(
                        context,
                        tile,
                        recognizeToUid: recognizeToUid,
                      ),
                    ),
                    if (recognizeToUid == null && tile.unlocked)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: ReceivedHeartBadge(
                          subjectKeys: {tile.id},
                          compact: true,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
        if (hiddenCount > 0) ...[
          const SizedBox(height: AppSpace.xs),
          Semantics(
            button: true,
            child: InkWell(
              onTap: () => showMedalMysterySheet(context, hiddenCount),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tiles.isEmpty
                            ? context.l10n.medalVaultMysteryEmpty
                            : context.l10n.medalVaultMysteryMore,
                        style: AppTypography.body(
                          size: 13,
                          color: a.textSecondary,
                        ),
                      ),
                    ),
                    ListChevron(color: a.textFaint),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Subtítulo interno do cofre — caixa normal, legível.
class _VaultSubhead extends StatelessWidget {
  final String text;
  final Color color;

  const _VaultSubhead(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.title(size: 12, color: color));
  }
}
