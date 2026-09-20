import 'package:flutter/material.dart';

import '../data/trail_repository.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medals.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'medal_cinematic_widgets.dart';
import 'medal_unlock_sheet.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

enum _MedalVaultTab { journey, trails }

/// Cofre — 5 emblemas da jornada, não um álbum de 24 moedas.
class PilgrimMedalVaultsPanel extends StatefulWidget {
  final CaravanPilgrimProfile profile;
  final PilgrimMedalEvalContext evalContext;

  const PilgrimMedalVaultsPanel({
    super.key,
    required this.profile,
    this.evalContext = const PilgrimMedalEvalContext(),
  });

  @override
  State<PilgrimMedalVaultsPanel> createState() =>
      _PilgrimMedalVaultsPanelState();
}

class _PilgrimMedalVaultsPanelState extends State<PilgrimMedalVaultsPanel> {
  List<PilgrimVaultState>? _vaults;
  List<Trail> _catalog = const [];
  _MedalVaultTab _tab = _MedalVaultTab.journey;
  String? _selectedTrailVaultId;

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
    final trailVaults = vaults
        .where((v) => v.vault.kind == PilgrimVaultKind.trail)
        .toList();
    setState(() {
      _catalog = catalog;
      _vaults = vaults;
      _selectedTrailVaultId ??=
          trailVaults.isNotEmpty ? trailVaults.first.vault.id : null;
      if (_selectedTrailVaultId != null &&
          trailVaults.every((v) => v.vault.id != _selectedTrailVaultId)) {
        _selectedTrailVaultId =
            trailVaults.isNotEmpty ? trailVaults.first.vault.id : null;
      }
    });
  }

  PilgrimVaultState? _vaultById(String id) {
    for (final vault in _vaults ?? const <PilgrimVaultState>[]) {
      if (vault.vault.id == id) return vault;
    }
    return null;
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
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final journey = _journeyVault;
    final trailVaults = _trailVaults;
    final hasTrails = trailVaults.isNotEmpty;
    final showJourney = !hasTrails || _tab == _MedalVaultTab.journey;
    final selectedTrail = _selectedTrailVaultId == null
        ? null
        : _vaultById(_selectedTrailVaultId!);

    final proximity = PilgrimMedals.nearestLocked(
      profile: widget.profile,
      catalog: _catalog,
      ctx: widget.evalContext,
      priorityTrailSlug: showJourney
          ? null
          : selectedTrail?.vault.id.replaceFirst('trail:', ''),
    );

    final rareTiles = PilgrimMedals.visibleDiscoveryTiles(_discoveryVault);
    final hiddenRares = PilgrimMedals.hiddenDiscoveryCount(_discoveryVault);

    final a = Appearance.of(context);
    final journeyLit = journey?.unlockedCount ?? 0;
    final journeyTotal = journey?.total ?? 0;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: const MedalSpotlightPainter(
                    accent: AppColors.medalGold,
                    intensity: 0.9,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.medalGold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Medalhas',
                          style: AppTypography.title(size: 16, color: a.text),
                        ),
                      ),
                      if (journeyTotal > 0)
                        CountBadge(
                          '$journeyLit/$journeyTotal',
                          color: AppColors.medalGold,
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (hasTrails) ...[
                    _MedalTabBar(
                      tab: _tab,
                      trailCount: trailVaults.length,
                      onChanged: (tab) => setState(() => _tab = tab),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (showJourney && journey != null)
                    _FamilyEmblemRow(
                      tracks: journey.tracks,
                      featuredTrackId: proximity?.track.id,
                    ),
                  if (showJourney && _seasonVault != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      'TEMPORADA',
                      style: AppTypography.label(
                        size: 9,
                        letterSpacing: 1.4,
                        color: AppColors.medalGold.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _FamilyEmblemRow(
                      tracks: _seasonVault!.tracks,
                      featuredTrackId: proximity?.track.id,
                    ),
                  ],
                  if (!showJourney)
                    _TrailEmblemStrip(
                      vaults: trailVaults,
                      featuredTrackId: proximity?.track.id,
                    ),
                  if (showJourney &&
                      (rareTiles.isNotEmpty || hiddenRares > 0)) ...[
                    const SizedBox(height: 18),
                    _RareStrip(
                      tiles: rareTiles,
                      hiddenCount: hiddenRares,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyEmblemRow extends StatelessWidget {
  final List<PilgrimTrackState> tracks;
  final String? featuredTrackId;

  const _FamilyEmblemRow({
    required this.tracks,
    this.featuredTrackId,
  });

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final track in tracks)
          Expanded(
            child: MedalTrackEmblem(
              trackState: track,
              featured: track.track.id == featuredTrackId,
              onTap: () => showTrackDetailSheet(context, track),
            ),
          ),
      ],
    );
  }
}

class _TrailEmblemStrip extends StatelessWidget {
  final List<PilgrimVaultState> vaults;
  final String? featuredTrackId;

  const _TrailEmblemStrip({
    required this.vaults,
    this.featuredTrackId,
  });

  @override
  Widget build(BuildContext context) {
    final tracks = [
      for (final vault in vaults)
        if (vault.tracks.isNotEmpty) vault.tracks.first,
    ];
    if (tracks.isEmpty) return const SizedBox.shrink();
    if (tracks.length == 1) {
      return MedalTrackEmblem(
        trackState: tracks.first,
        featured: true,
        onTap: () => showTrackDetailSheet(context, tracks.first),
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 10,
      children: [
        for (final track in tracks)
          SizedBox(
            width: 72,
            child: MedalTrackEmblem(
              trackState: track,
              featured: track.track.id == featuredTrackId,
              onTap: () => showTrackDetailSheet(context, track),
            ),
          ),
      ],
    );
  }
}

class _RareStrip extends StatelessWidget {
  final List<PilgrimMedalTile> tiles;
  final int hiddenCount;

  const _RareStrip({
    required this.tiles,
    required this.hiddenCount,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.medalMirra.withValues(alpha: 0.18), height: 1),
        const SizedBox(height: 12),
        Text(
          'DESCOBERTAS',
          style: AppTypography.label(
            size: 9,
            letterSpacing: 1.4,
            color: AppColors.medalMirra.withValues(alpha: 0.88),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final tile in tiles)
              MedalVaultMedallion(
                tile: tile,
                size: 52,
                onTap: () => showMedalTileSheet(context, tile),
              ),
            if (hiddenCount > 0)
              _MysteryCount(
                count: hiddenCount,
                onTap: () => showMedalMysterySheet(context, hiddenCount),
              ),
          ],
        ),
        if (tiles.isEmpty && hiddenCount > 0) ...[
          const SizedBox(height: 6),
          Text(
            'Revelam-se no caminho — sem dica.',
            style: AppTypography.body(
              size: 11,
              color: a.textMuted(0.42),
            ),
          ),
        ],
      ],
    );
  }
}

class _MysteryCount extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _MysteryCount({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.medalMirra.withValues(alpha: 0.35)),
          ),
          child: Text(
            count == 1 ? '1 no véu' : '$count no véu',
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.8,
              color: a.textMuted(0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _MedalTabBar extends StatelessWidget {
  final _MedalVaultTab tab;
  final int trailCount;
  final ValueChanged<_MedalVaultTab> onChanged;

  const _MedalTabBar({
    required this.tab,
    required this.trailCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MedalChapter(
            label: 'Jornada',
            selected: tab == _MedalVaultTab.journey,
            onTap: () => onChanged(_MedalVaultTab.journey),
          ),
        ),
        Expanded(
          child: _MedalChapter(
            label: 'Trilhas',
            count: trailCount,
            selected: tab == _MedalVaultTab.trails,
            onTap: () => onChanged(_MedalVaultTab.trails),
          ),
        ),
      ],
    );
  }
}

class _MedalChapter extends StatelessWidget {
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  const _MedalChapter({
    required this.label,
    this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ink = selected
        ? AppColors.medalGold
        : Colors.white.withValues(alpha: 0.42);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  count == null ? label.toUpperCase() : '${label.toUpperCase()}  $count',
                  textAlign: TextAlign.center,
                  style: AppTypography.label(
                    size: 11,
                    letterSpacing: 1.4,
                    color: ink,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 2,
                decoration: BoxDecoration(
                  color: selected ? AppColors.medalGold : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
