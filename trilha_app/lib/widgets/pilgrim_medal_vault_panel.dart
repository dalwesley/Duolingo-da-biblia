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
    if (oldWidget.profile != widget.profile) _load();
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

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader(label: 'Medalhas'),
          const SizedBox(height: 12),
          if (hasTrails) ...[
            _MedalTabBar(
              tab: _tab,
              trailCount: trailVaults.length,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
            if (_tab == _MedalVaultTab.trails) ...[
              const SizedBox(height: 10),
              _TrailVaultPicker(
                vaults: trailVaults,
                selectedId: _selectedTrailVaultId,
                onSelected: (id) => setState(() => _selectedTrailVaultId = id),
              ),
            ],
            const SizedBox(height: 12),
          ],
          if (proximity != null) ...[
            _ProximityWhisper(
              proximity: proximity,
              onTap: () {
                final trackState = _trackStateFor(proximity.track.id);
                if (trackState != null) {
                  showTrackDetailSheet(context, trackState);
                }
              },
            ),
            const SizedBox(height: 12),
          ],
          if (showJourney && journey != null)
            _FamilyEmblemRow(
              tracks: journey.tracks,
              featuredTrackId: proximity?.track.id,
            ),
          if (showJourney && _seasonVault != null) ...[
            const SizedBox(height: 10),
            _FamilyEmblemRow(
              tracks: _seasonVault!.tracks,
              featuredTrackId: proximity?.track.id,
            ),
          ],
          if (!showJourney && selectedTrail != null)
            _TrailLevelRow(state: selectedTrail),
          if (showJourney && (rareTiles.isNotEmpty || hiddenRares > 0)) ...[
            const SizedBox(height: 16),
            _RareStrip(
              tiles: rareTiles,
              hiddenCount: hiddenRares,
            ),
          ],
        ],
      ),
    );
  }

  PilgrimTrackState? _trackStateFor(String trackId) {
    for (final vault in _vaults ?? const <PilgrimVaultState>[]) {
      for (final track in vault.tracks) {
        if (track.track.id == trackId) return track;
      }
    }
    return null;
  }
}

class _ProximityWhisper extends StatelessWidget {
  final PilgrimTrackProximity proximity;
  final VoidCallback onTap;

  const _ProximityWhisper({
    required this.proximity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = tierColor(proximity.nextLevel.tier);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            proximity.monitorMessage,
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 11,
              letterSpacing: 0.35,
              color: accent.withValues(alpha: 0.9),
            ),
          ),
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

class _TrailLevelRow extends StatelessWidget {
  final PilgrimVaultState state;

  const _TrailLevelRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final tiles = PilgrimMedals.trailLevelTiles(state);
    if (tiles.isEmpty) return const SizedBox.shrink();
    final track = state.tracks.isEmpty ? null : state.tracks.first;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final tile in tiles)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: MedalVaultMedallion(
                  tile: tile,
                  size: 40,
                  onTap: () {
                    if (track != null) {
                      final index = track.track.levels.indexWhere(
                        (level) => level.id == tile.id,
                      );
                      showTrackDetailSheet(
                        context,
                        track,
                        highlightLevelIndex: index >= 0 ? index : null,
                      );
                    } else {
                      showMedalTileSheet(context, tile);
                    }
                  },
                ),
              ),
          ],
        ),
        if (track != null) ...[
          const SizedBox(height: 8),
          MedalTrackDots(
            trackState: track,
            accent: track.currentLevel != null
                ? tierColor(track.currentLevel!.tier)
                : Colors.white.withValues(alpha: 0.28),
          ),
        ],
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
        Text(
          'RARAS',
          style: AppTypography.label(
            size: 10,
            letterSpacing: 1.2,
            color: AppColors.medalMirra.withValues(alpha: 0.8),
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
                size: 44,
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
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Center(
              child: Text(
                '$count',
                style: AppTypography.label(
                  size: 12,
                  letterSpacing: 0.4,
                  color: a.textMuted(0.55),
                ),
              ),
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
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MedalTabChip(
              label: 'Jornada',
              selected: tab == _MedalVaultTab.journey,
              onTap: () => onChanged(_MedalVaultTab.journey),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _MedalTabChip(
              label: 'Trilhas ($trailCount)',
              selected: tab == _MedalVaultTab.trails,
              onTap: () => onChanged(_MedalVaultTab.trails),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedalTabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MedalTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.medalGold.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: selected
            ? Border.all(color: AppColors.medalGold.withValues(alpha: 0.55))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.label(
                size: 10,
                letterSpacing: 0.6,
                color: selected
                    ? AppColors.medalGold
                    : Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrailVaultPicker extends StatelessWidget {
  final List<PilgrimVaultState> vaults;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const _TrailVaultPicker({
    required this.vaults,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (vaults.length <= 1) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final state in vaults) ...[
            _TrailPickerChip(
              title: state.vault.title,
              selected: state.vault.id == selectedId,
              onTap: () => onSelected(state.vault.id),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _TrailPickerChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _TrailPickerChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent;
    return Material(
      color: selected
          ? accent.withValues(alpha: 0.16)
          : Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            title,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.2,
              color: selected
                  ? accent
                  : Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}
