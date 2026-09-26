import 'package:flutter/material.dart';

import '../data/trail_repository.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medals.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'medal_cinematic_widgets.dart';
import 'medal_unlock_sheet.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';
import 'profile_privacy.dart';
import 'relic_panel.dart';
import '../models/caravan_profile_prefs.dart';

enum _MedalVaultTab { journey, trails }

/// Cofre — 5 emblemas da jornada, não um álbum de 24 moedas.
class PilgrimMedalVaultsPanel extends StatefulWidget {
  final CaravanPilgrimProfile profile;
  final PilgrimMedalEvalContext evalContext;

  /// Quando visita outro peregrino — coração no sheet do emblema.
  final String? recognizeToUid;

  /// Dono sem nenhuma medalha — CTA que leva de volta à trilha.
  final VoidCallback? onStartWalking;

  const PilgrimMedalVaultsPanel({
    super.key,
    required this.profile,
    this.evalContext = const PilgrimMedalEvalContext(),
    this.recognizeToUid,
    this.onStartWalking,
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
      _selectedTrailVaultId ??= trailVaults.isNotEmpty
          ? trailVaults.first.vault.id
          : null;
      if (_selectedTrailVaultId != null &&
          trailVaults.every((v) => v.vault.id != _selectedTrailVaultId)) {
        _selectedTrailVaultId = trailVaults.isNotEmpty
            ? trailVaults.first.vault.id
            : null;
      }
    });
  }

  PilgrimTrackState? _trackById(String id) {
    for (final vault in _vaults ?? const <PilgrimVaultState>[]) {
      for (final track in vault.tracks) {
        if (track.track.id == id) return track;
      }
    }
    return null;
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
        child: AppSpinner(),
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

    // Próxima medalha de toda a coleção (sem prioridade de aba) — a meta
    // que mais puxa: "Faltam 3 cenas para Prata".
    final spot = PilgrimMedals.nearestLocked(
      profile: widget.profile,
      catalog: _catalog,
      ctx: widget.evalContext,
    );
    final spotTrack = spot == null ? null : _trackById(spot.track.id);

    final rareTiles = PilgrimMedals.visibleDiscoveryTiles(_discoveryVault);
    final hiddenRares = PilgrimMedals.hiddenDiscoveryCount(_discoveryVault);

    final a = Appearance.of(context);
    final journeyLit = journey?.unlockedCount ?? 0;
    final journeyTotal = journey?.total ?? 0;
    final anyLit = vaults.any((v) => v.unlockedCount > 0);
    final showEmpty = !anyLit && widget.onStartWalking != null;

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
              padding: const EdgeInsets.fromLTRB(
                AppSpace.lg,
                AppSpace.lg,
                AppSpace.lg,
                AppSpace.lg + 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RelicChapter(
                    title: 'Medalhas',
                    accent: AppColors.medalGold,
                    // A barra de progresso já faz o papel do filete.
                    divided: journeyTotal == 0,
                    action: const PrivacyEye(
                      sections: {CaravanProfileSection.medals},
                      label: 'Medalhas',
                    ),
                  ),
                  if (journeyTotal > 0) ...[
                    const SizedBox(height: AppSpace.sm),
                    RelicProgress(
                      value: journeyLit / journeyTotal,
                      accent: AppColors.medalGold,
                    ),
                  ],
                  if (spot != null && spotTrack != null) ...[
                    const SizedBox(height: AppSpace.md),
                    _NextMedalSpotlight(
                      proximity: spot,
                      onTap: () => showTrackDetailSheet(
                        context,
                        spotTrack,
                        highlightLevelIndex: spotTrack.levelIndex + 1,
                        recognizeToUid: widget.recognizeToUid,
                      ),
                    ),
                  ],
                  if (showEmpty) ...[
                    const SizedBox(height: AppSpace.xs + 2),
                    Padding(
                      padding: const EdgeInsets.only(left: 13),
                      child: Text(
                        'Cada cena concluída acende uma moeda. '
                        'A primeira está a um passo.',
                        style: AppTypography.body(
                          size: 13,
                          color: a.textSecondary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpace.md),
                  if (hasTrails) ...[
                    _MedalTabBar(
                      tab: _tab,
                      trailCount: trailVaults.length,
                      onChanged: (tab) => setState(() => _tab = tab),
                    ),
                    const SizedBox(height: AppSpace.md),
                  ],
                  if (showJourney && journey != null)
                    _FamilyEmblemRow(
                      tracks: journey.tracks,
                      featuredTrackId: proximity?.track.id,
                      recognizeToUid: widget.recognizeToUid,
                    ),
                  if (showJourney && _seasonVault != null) ...[
                    const SizedBox(height: AppSpace.lg),
                    _VaultSubhead(
                      'Temporada',
                      color: AppColors.medalGold.withValues(alpha: 0.85),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    _FamilyEmblemRow(
                      tracks: _seasonVault!.tracks,
                      featuredTrackId: proximity?.track.id,
                      recognizeToUid: widget.recognizeToUid,
                    ),
                  ],
                  if (!showJourney)
                    _TrailEmblemStrip(
                      vaults: trailVaults,
                      featuredTrackId: proximity?.track.id,
                      recognizeToUid: widget.recognizeToUid,
                    ),
                  if (showJourney &&
                      (rareTiles.isNotEmpty || hiddenRares > 0)) ...[
                    const SizedBox(height: AppSpace.lg + 2),
                    _RareStrip(
                      tiles: rareTiles,
                      hiddenCount: hiddenRares,
                      recognizeToUid: widget.recognizeToUid,
                    ),
                  ],
                  if (showEmpty) ...[
                    const SizedBox(height: AppSpace.lg + 2),
                    CopperCta(
                      label: 'Caminhar a próxima cena',
                      dense: true,
                      leading: CinematicGlyph.path,
                      trailing: null,
                      onTap: widget.onStartWalking,
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
  final String? recognizeToUid;

  const _FamilyEmblemRow({
    required this.tracks,
    this.featuredTrackId,
    this.recognizeToUid,
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
              onTap: () => showTrackDetailSheet(
                context,
                track,
                recognizeToUid: recognizeToUid,
              ),
            ),
          ),
      ],
    );
  }
}

class _TrailEmblemStrip extends StatelessWidget {
  final List<PilgrimVaultState> vaults;
  final String? featuredTrackId;
  final String? recognizeToUid;

  const _TrailEmblemStrip({
    required this.vaults,
    this.featuredTrackId,
    this.recognizeToUid,
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
        onTap: () => showTrackDetailSheet(
          context,
          tracks.first,
          recognizeToUid: recognizeToUid,
        ),
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
              onTap: () => showTrackDetailSheet(
                context,
                track,
                recognizeToUid: recognizeToUid,
              ),
            ),
          ),
      ],
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
          'Descobertas',
          color: AppColors.medalMirra.withValues(alpha: 0.92),
        ),
        if (tiles.isNotEmpty) ...[
          const SizedBox(height: AppSpace.sm + 2),
          Wrap(
            spacing: AppSpace.sm + 2,
            runSpacing: AppSpace.sm + 2,
            children: [
              for (final tile in tiles)
                MedalVaultMedallion(
                  tile: tile,
                  size: 52,
                  onTap: () => showMedalTileSheet(
                    context,
                    tile,
                    recognizeToUid: recognizeToUid,
                  ),
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
                            ? 'Revelam-se no caminho — sem dica.'
                            : 'Outras se revelam no caminho.',
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
    final a = Appearance.of(context);
    final ink = selected ? AppColors.medalGold : a.textFaint;
    final text = count == null ? label : '$label · $count';
    return Semantics(
      button: true,
      selected: selected,
      label: text,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTypography.title(
                      size: 14,
                      weight: selected ? FontWeight.w800 : FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: 2,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.medalGold : a.textMuted(0.1),
                    borderRadius: BorderRadius.circular(AppRadii.hair),
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

/// "Próxima medalha": a moeda que falta, o halo do quanto já andou e o
/// recado de ação ("Faltam 3 cenas para Prata em Palavra").
class _NextMedalSpotlight extends StatelessWidget {
  final PilgrimTrackProximity proximity;
  final VoidCallback onTap;

  const _NextMedalSpotlight({required this.proximity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final p = proximity;
    final accent = tierColor(p.nextLevel.tier);
    final ratio = p.target <= 0 ? 0.0 : (p.current / p.target).clamp(0.0, 1.0);
    final tile = PilgrimMedalTile.fromLevel(
      track: p.track,
      level: p.nextLevel,
      unlocked: false,
    );
    return Semantics(
      button: true,
      label: 'Próxima medalha: ${p.message}',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: InsetPanel(
            borderColor: accent.withValues(alpha: 0.45),
            child: Row(
              children: [
                MedalHaloRing(
                  progress: ratio,
                  accent: accent,
                  size: 66,
                  stroke: 3,
                  child: MedalVaultMedallion(tile: tile, size: 48),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Próxima medalha',
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tierLabel(p.nextLevel.tier)} · ${p.track.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title(size: 16, color: a.text),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.remaining == 1
                            ? 'Falta 1 ${p.unitLabel}'
                            : 'Faltam ${p.remaining} ${p.unitLabel}',
                        style: AppTypography.body(
                          size: 13,
                          weight: FontWeight.w600,
                          color: a.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AppProgressBar(
                              value: ratio,
                              color: accent,
                              height: 6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${p.current}/${p.target}',
                            style: AppTypography.body(
                              size: 12,
                              weight: FontWeight.w800,
                              color: a.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                ListChevron(color: a.textFaint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
