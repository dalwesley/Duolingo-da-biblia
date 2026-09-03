import 'package:flutter/material.dart';

import '../data/trail_repository.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medals.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'medal_cinematic_widgets.dart';
import 'medal_unlock_sheet.dart';

enum _MedalVaultTab { journey, trails }

/// Medalhas v2 — um único painel com abas (jornada / trilhas).
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

  int get _totalUnlocked =>
      _vaults?.fold<int>(0, (sum, v) => sum + v.unlockedCount) ?? 0;

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
    final discovery = _discoveryVault;
    final discoveryTiles = discovery != null
        ? PilgrimMedals.tilesForVault(discovery)
        : PilgrimMedalCatalog.rareMedals
            .map(
              (def) => PilgrimMedalTile(
                id: def.id,
                title: def.title,
                hint: def.hint,
                glyph: def.glyph,
                tier: def.tier,
                unlocked: false,
                secret: def.secret,
              ),
            )
            .toList();
    final hasTrails = trailVaults.isNotEmpty;

    return GlassCard(
      accent: true,
      elevated: true,
      tint: AppColors.medalGold,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _VaultCinematicHeader(
            journey: journey,
            totalUnlocked: _totalUnlocked,
          ),
          const SizedBox(height: 14),
          _GlobalProximityBanner(
            profile: widget.profile,
            catalog: _catalog,
            evalContext: widget.evalContext,
            tab: _tab,
            trailVaultId: _selectedTrailVaultId,
          ),
          if (hasTrails) ...[
            const SizedBox(height: 12),
            _MedalTabBar(
              tab: _tab,
              trailCount: trailVaults.length,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
          ],
          const SizedBox(height: 14),
          if ((!hasTrails || _tab == _MedalVaultTab.journey) && journey != null) ...[
            if (journey.isComplete) ...[
              const _MedalVaultCompleteBanner(),
              const SizedBox(height: 12),
            ],
            _VaultMedalGrid(
              tiles: PilgrimMedals.tilesForVault(journey),
            ),
          ]
          else if (_tab == _MedalVaultTab.trails && hasTrails) ...[
            _TrailVaultPicker(
              vaults: trailVaults,
              selectedId: _selectedTrailVaultId,
              onSelected: (id) => setState(() => _selectedTrailVaultId = id),
            ),
            const SizedBox(height: 14),
            if (_selectedTrailVaultId != null &&
                _vaultById(_selectedTrailVaultId!) != null)
              _VaultMedalGrid(
                tiles: PilgrimMedals.tilesForVault(
                  _vaultById(_selectedTrailVaultId!)!,
                ),
              ),
          ],
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0x1AFFFFFF)),
          const SizedBox(height: 14),
          _MedalGroupLabel(
            title: 'Raras',
            accent: AppColors.medalMirra,
          ),
          const SizedBox(height: 4),
          Text(
            'Conquistas excepcionais da jornada',
            style: AppTypography.body(
              size: 11,
              height: 1.35,
              color: Appearance.of(context).textMuted(0.42),
            ),
          ),
          const SizedBox(height: 10),
          _VaultMedalGrid(tiles: discoveryTiles),
        ],
      ),
    );
  }
}

class _VaultCinematicHeader extends StatelessWidget {
  final PilgrimVaultState? journey;
  final int totalUnlocked;

  const _VaultCinematicHeader({
    required this.journey,
    required this.totalUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final journeyState = journey;
    final progress = journeyState?.progress ?? 0;
    final journeyUnlocked = journeyState?.unlockedCount ?? 0;
    final journeyTotal = journeyState?.total ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (journeyState != null)
          MedalRingProgress(
            value: journeyUnlocked,
            total: journeyTotal,
            progress: progress,
            accent: AppColors.medalGold,
            size: 76,
          )
        else
          const CinematicIcon(
            glyph: CinematicGlyph.gem,
            size: 36,
            accent: AppColors.medalGold,
            framed: true,
            glowing: true,
          ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.medalGold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'MEDALHAS',
                    style: AppTypography.label(
                      size: 11,
                      letterSpacing: 1.6,
                      color: a.textMuted(0.78),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$totalUnlocked conquistas',
                style: AppTypography.title(
                  size: 15,
                  weight: FontWeight.w800,
                  color: AppColors.medalGold,
                ),
              ),
              if (journeyState != null) ...[
                const SizedBox(height: 2),
                Text(
                  '${(progress * 100).round()}% da jornada',
                  style: AppTypography.body(
                    size: 12,
                    color: a.textMuted(0.48),
                  ),
                ),
              ],
            ],
          ),
        ),
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
    final a = Appearance.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: selected
            ? LinearGradient(
                colors: [
                  AppColors.medalGold.withValues(alpha: 0.28),
                  AppColors.medalGold.withValues(alpha: 0.12),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: selected
            ? Border.all(color: AppColors.medalGold.withValues(alpha: 0.55))
            : null,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.medalGold.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
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
                color: selected ? AppColors.medalGold : a.textMuted(0.5),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final state in vaults) ...[
            _TrailPickerChip(
              title: state.vault.title,
              progress: state.progress,
              complete: state.isComplete,
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
  final double progress;
  final bool complete;
  final bool selected;
  final VoidCallback onTap;

  const _TrailPickerChip({
    required this.title,
    required this.progress,
    required this.complete,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final accent = complete ? AppColors.medalGold : AppColors.accent;
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (complete)
                const Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: CinematicIcon(
                    glyph: CinematicGlyph.check,
                    size: 10,
                    accent: AppColors.medalGold,
                    framed: false,
                  ),
                ),
              Text(
                title,
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.2,
                  color: selected ? accent : a.textMuted(0.62),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                complete ? '100%' : '${(progress * 100).round()}%',
                style: AppTypography.label(
                  size: 9,
                  letterSpacing: 0,
                  color: a.textMuted(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlobalProximityBanner extends StatelessWidget {
  final CaravanPilgrimProfile profile;
  final List<Trail> catalog;
  final PilgrimMedalEvalContext evalContext;
  final _MedalVaultTab tab;
  final String? trailVaultId;

  const _GlobalProximityBanner({
    required this.profile,
    required this.catalog,
    required this.evalContext,
    required this.tab,
    this.trailVaultId,
  });

  @override
  Widget build(BuildContext context) {
    final proximity = PilgrimMedals.nearestLocked(
      profile: profile,
      catalog: catalog,
      ctx: evalContext,
      priorityTrailSlug: tab == _MedalVaultTab.trails && trailVaultId != null
          ? trailVaultId!.replaceFirst('trail:', '')
          : null,
    );
    if (proximity == null) return const SizedBox.shrink();
    return _MedalProximityBanner(proximity: proximity);
  }
}

class _VaultMedalGrid extends StatelessWidget {
  final List<PilgrimMedalTile> tiles;

  const _VaultMedalGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    final sorted = [...tiles]
      ..sort((a, b) {
        if (a.unlocked != b.unlocked) return a.unlocked ? -1 : 1;
        return a.title.compareTo(b.title);
      });

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final tile = sorted[index];
        return MedalVaultMedallion(
          tile: tile,
          onTap: () => showMedalTileSheet(context, tile),
        );
      },
    );
  }
}

class _MedalVaultCompleteBanner extends StatelessWidget {
  const _MedalVaultCompleteBanner();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.medalGold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.medalGold.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.crown,
            size: 22,
            accent: AppColors.medalGold,
            framed: false,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Todas as medalhas deste conjunto estão conquistadas.',
              style: AppTypography.body(
                size: 12,
                height: 1.35,
                color: a.textMuted(0.62),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedalProximityBanner extends StatelessWidget {
  final PilgrimTrackProximity proximity;

  const _MedalProximityBanner({required this.proximity});

  @override
  Widget build(BuildContext context) {
    final accent = tierColor(proximity.nextLevel.tier);
    final a = Appearance.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.2),
            accent.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.18),
              border: Border.all(color: accent.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: CinematicIcon(
                glyph: proximity.nextLevel.glyph,
                size: 20,
                accent: accent,
                framed: false,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUASE LÁ',
                  style: AppTypography.label(
                    size: 9,
                    letterSpacing: 1.2,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  proximity.message,
                  style: AppTypography.body(
                    size: 12,
                    height: 1.35,
                    color: a.textMuted(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedalGroupLabel extends StatelessWidget {
  final String title;
  final Color accent;

  const _MedalGroupLabel({required this.title, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: AppTypography.label(
            size: 10,
            letterSpacing: 1.1,
            color: accent,
          ),
        ),
      ],
    );
  }
}
