import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../models/difficulty.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
import 'cloud_mascot.dart';
import 'journey_phase_card.dart';
import 'journey_station_card.dart';
import 'mode_emblem.dart';
import 'winding_trail.dart';

export 'journey_station_card.dart'
    show JourneyNodeState, JourneyStationCard, journeyRomanNumeral;

class JourneyPathItem {
  final Trail trail;
  final JourneyNodeState state;
  final TrailCategory category;
  final int done;
  final int total;
  final int chapterIndex;

  /// Ex.: "Observação concluída" — diferencia modo limpo de progresso zerado.
  final String? statusLabel;

  /// IDs dos modos já selados nesta trilha (`semente`, `caminhada`, …).
  final List<String> clearedModeIds;

  /// Modo ativo nesta trilha (`semente` = Observação).
  final String? activeDifficultyId;

  const JourneyPathItem({
    required this.trail,
    required this.state,
    required this.category,
    this.done = 0,
    this.total = 0,
    this.chapterIndex = 1,
    this.statusLabel,
    this.clearedModeIds = const [],
    this.activeDifficultyId,
  });
}

/// Trilhas de uma área como níveis numa curva.
class JourneyPath extends StatelessWidget {
  final List<JourneyPathItem> items;
  final Color accent;
  final Color glow;
  final void Function(JourneyPathItem item) onTap;
  final GlobalKey? currentKey;

  /// Portão com o nome da categoria a cada troca. Desligado quando o
  /// caminho tem uma categoria só — o título da tela já diz qual é.
  final bool phaseCards;

  const JourneyPath({
    super.key,
    required this.items,
    required this.accent,
    required this.glow,
    required this.onTap,
    this.currentKey,
    this.phaseCards = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final a = Appearance.of(context);
    final stops = <WindingStop>[];
    TrailCategory? lastCategory;
    var chapter = 0;
    var phase = 0;

    for (final item in items) {
      if (phaseCards && item.category != lastCategory) {
        phase++;
        final whisper = item.category.description;
        final reached =
            item.state != JourneyNodeState.locked &&
            item.state != JourneyNodeState.soon;
        stops.add(
          WindingStop(
            nodeSize: 48,
            passed: reached,
            gate: true,
            child: JourneyPhaseCard(
              phaseIndex: phase,
              title: item.category.label,
              whisper: whisper.isEmpty ? null : whisper,
              accent: accent,
              open: reached,
              glyph: TrailVisuals.forCategory(item.category.id),
            ),
          ),
        );
        lastCategory = item.category;
      }
      chapter++;
      final station = JourneyPathItem(
        trail: item.trail,
        state: item.state,
        category: item.category,
        done: item.done,
        total: item.total,
        chapterIndex: chapter,
        statusLabel: item.statusLabel,
        clearedModeIds: item.clearedModeIds,
        activeDifficultyId: item.activeDifficultyId,
      );
      final isCurrent = item.state == JourneyNodeState.current;
      stops.add(
        WindingStop(
          key: isCurrent ? currentKey : null,
          nodeSize: 72,
          // Concluída: as pegadas saem daqui e chegam no próximo card.
          // Atual: o traço para na entrada, com o Anan.
          passed: item.state == JourneyNodeState.completed,
          centerAnchor: true,
          beacon: isCurrent,
          child: _TrailStation(
            item: station,
            accent: accent,
            glow: glow,
            onTap: () => onTap(item),
          ),
        ),
      );
    }

    final track = Color.lerp(
      // Claro: trilho em tinta (sem puxar para o branco, some no céu).
      a.onDark
          ? Color.lerp(a.progressTrack, AppColors.textOnDark, 0.42)!
          : a.text.withValues(alpha: 0.22),
      accent,
      0.28,
    )!;

    return FlowingWindingTrail(
      walked: accent,
      track: track,
      // O tracejado só existe no trecho já percorrido.
      showAhead: false,
      stops: stops,
      walker: const WindingWalker(
        child: CloudMascot(face: CloudFace.feliz, size: 56, react: false),
      ),
    );
  }
}

class _TrailStation extends StatelessWidget {
  final JourneyPathItem item;
  final Color accent;
  final Color glow;
  final VoidCallback onTap;

  const _TrailStation({
    required this.item,
    required this.accent,
    required this.glow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mode = _emblemMode(item);
    final tone = _stationChromeOf(item);
    final isLocked = item.state == JourneyNodeState.locked;
    final isSoon = item.state == JourneyNodeState.soon;
    final isDone = item.state == JourneyNodeState.completed;
    final isCurrent = item.state == JourneyNodeState.current;
    final visuals = TrailVisuals.forTrail(item.trail);
    final roman = journeyRomanNumeral(item.chapterIndex);

    String? status;
    if (!isCurrent) {
      if (isLocked || isSoon) {
        final desc = item.trail.localizedDescription.trim();
        status = desc.isEmpty
            ? (isSoon
                  ? context.l10n.commonComingSoon
                  : context.l10n.journeyBeyondHorizon)
            : desc;
      } else if (item.statusLabel != null) {
        status = item.statusLabel;
      } else if (isDone) {
        status = context.l10n.trailsCleared;
      } else if (item.total > 0) {
        status = context.l10n.trailsScenesShort(item.done, item.total);
      } else {
        status = item.trail.localizedDescription;
      }
    }

    return JourneyStationCard(
      title: item.trail.localizedTitle,
      eyebrow: context.l10n.trailsTrailNumber(roman),
      watermark: roman,
      glyph: visuals.glyph,
      state: item.state,
      accent: accent,
      glow: glow,
      chrome: tone,
      onTap: onTap,
      leading: mode == null
          ? null
          : ModeEmblem(
              key: ValueKey('mode-emblem-${mode.id}'),
              difficulty: mode,
              size: 22,
              cleared: item.clearedModeIds.contains(mode.id),
              active: !item.clearedModeIds.contains(mode.id),
            ),
      currentSubtitle: isCurrent && mode != null
          ? context.l10n.modeNamed(mode.labelPt)
          : null,
      statusLine: status,
      done: item.done,
      total: item.total,
      semanticsLabel: item.trail.localizedTitle,
    );
  }
}

/// Selo do nó: modo em curso, ou o único modo já selado.
TrailDifficulty? _emblemMode(JourneyPathItem item) {
  final isLocked = item.state == JourneyNodeState.locked;
  final isSoon = item.state == JourneyNodeState.soon;
  final open = TrailDifficulty.fromId(item.activeDifficultyId);
  final openUncleared = open != null && !item.clearedModeIds.contains(open.id);
  if (openUncleared && !isLocked && !isSoon) return open;
  if (item.state != JourneyNodeState.completed) return null;
  final sealed = TrailProgress.orderedClearedDifficulties(item.clearedModeIds);
  if (sealed.length != 1) return null;
  return sealed.first;
}

Color? _stationChromeOf(JourneyPathItem item) {
  if (item.state == JourneyNodeState.locked ||
      item.state == JourneyNodeState.soon) {
    return null;
  }
  final live = _liveModeAccentOf(item);
  if (live != null) return live;
  final open = TrailDifficulty.fromId(item.activeDifficultyId);
  if (open != null) return DifficultyVisuals.accentFor(open);
  return _sealedModeAccentOf(item);
}

Color? _liveModeAccentOf(JourneyPathItem item) {
  if (item.state == JourneyNodeState.locked ||
      item.state == JourneyNodeState.soon) {
    return null;
  }
  final live = TrailDifficulty.fromId(item.activeDifficultyId);
  if (item.state == JourneyNodeState.completed) {
    if (live != null && !item.clearedModeIds.contains(live.id)) {
      return DifficultyVisuals.accentFor(live);
    }
    return null;
  }
  return live == null ? null : DifficultyVisuals.accentFor(live);
}

Color? _sealedModeAccentOf(JourneyPathItem item) {
  final ordered = TrailProgress.orderedClearedDifficulties(item.clearedModeIds);
  if (ordered.isEmpty) return null;
  return DifficultyVisuals.accentFor(ordered.last);
}
