import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import '../theme/app_theme.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/trail_progress.dart';
import 'cinematic_icon.dart';

/// Emblema de um modo cognitivo — semente, caminho ou profundezas.
///
/// Quando [cleared], o selo de check marca o modo concluído (não um
/// check genérico de trilha).
class ModeEmblem extends StatelessWidget {
  final TrailDifficulty difficulty;
  final bool cleared;
  final bool locked;
  final bool active;
  final double size;
  final VoidCallback? onTap;

  const ModeEmblem({
    super.key,
    required this.difficulty,
    this.cleared = false,
    this.locked = false,
    this.active = false,
    this.size = 48,
    this.onTap,
  });

  String get semanticLabel {
    final name = difficulty.labelPt;
    if (cleared) return '$name concluída';
    if (locked) return '$name bloqueada';
    if (active) return '$name atual';
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final color = DifficultyVisuals.accentFor(difficulty);
    final onSky = DifficultyVisuals.onSky(color);
    final ink = DifficultyVisuals.inkOn(difficulty);
    final stamp = (size * 0.38).clamp(12.0, 20.0);
    final dimmed = locked && !cleared;

    final emblem = Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: SizedBox(
        width: size + 6,
        height: size + 6,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: dimmed ? 0.42 : 1,
              child: CinematicIcon(
                glyph: DifficultyVisuals.glyphFor(difficulty),
                size: size,
                accent: onSky,
                framed: true,
                glowing: active && !cleared && !dimmed,
              ),
            ),
            if (cleared)
              Positioned(
                right: 0,
                bottom: 0,
                child: _ClearStamp(size: stamp, fill: color, ink: ink),
              ),
          ],
        ),
      ),
    );

    if (onTap == null) return emblem;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: emblem,
    );
  }
}

class _ClearStamp extends StatelessWidget {
  final double size;
  final Color fill;
  final Color ink;

  const _ClearStamp({
    required this.size,
    required this.fill,
    required this.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(
          color: AppColors.night.withValues(alpha: 0.88),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: CinematicIcon(
        glyph: CinematicGlyph.check,
        size: size * 0.58,
        accent: ink,
        framed: false,
      ),
    );
  }
}

/// Faixa dos três modos desta trilha — o que já foi selado fica explícito.
class ModeEmblemStrip extends StatelessWidget {
  final List<String> clearedModeIds;
  final String? activeDifficultyId;
  final double emblemSize;
  final bool labeled;
  final bool clearedOnly;
  final ValueChanged<TrailDifficulty>? onSelect;

  const ModeEmblemStrip({
    super.key,
    required this.clearedModeIds,
    this.activeDifficultyId,
    this.emblemSize = 36,
    this.labeled = false,
    this.clearedOnly = false,
    this.onSelect,
  });

  List<TrailDifficulty> get _modes {
    if (clearedOnly) {
      return TrailProgress.orderedClearedDifficulties(clearedModeIds);
    }
    return TrailDifficulty.values;
  }

  @override
  Widget build(BuildContext context) {
    final modes = _modes;
    if (modes.isEmpty) return const SizedBox.shrink();
    final active = activeDifficultyId ?? TrailDifficulty.semente.id;

    if (labeled) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < modes.length; i++)
            Expanded(
              child: _LabeledMode(
                difficulty: modes[i],
                cleared: clearedModeIds.contains(modes[i].id),
                locked: _locked(modes[i]),
                active: modes[i].id == active,
                size: emblemSize,
                onTap: onSelect == null ? null : () => onSelect!(modes[i]),
              ),
            ),
        ],
      );
    }

    final children = <Widget>[];
    for (var i = 0; i < modes.length; i++) {
      if (i > 0) children.add(const SizedBox(width: 6));
      final d = modes[i];
      children.add(
        ModeEmblem(
          key: ValueKey('mode-emblem-${d.id}'),
          difficulty: d,
          cleared: clearedModeIds.contains(d.id),
          locked: _locked(d),
          active: d.id == active,
          size: emblemSize,
          onTap: onSelect == null ? null : () => onSelect!(d),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  bool _locked(TrailDifficulty d) {
    if (clearedModeIds.contains(d.id)) return false;
    if (d == TrailDifficulty.semente) return false;
    final prev = switch (d) {
      TrailDifficulty.caminhada => TrailDifficulty.semente,
      TrailDifficulty.profundezas => TrailDifficulty.caminhada,
      TrailDifficulty.semente => null,
    };
    if (prev == null) return false;
    return !clearedModeIds.contains(prev.id);
  }
}

class _LabeledMode extends StatelessWidget {
  final TrailDifficulty difficulty;
  final bool cleared;
  final bool locked;
  final bool active;
  final double size;
  final VoidCallback? onTap;

  const _LabeledMode({
    required this.difficulty,
    required this.cleared,
    required this.locked,
    required this.active,
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = DifficultyVisuals.accentFor(difficulty);
    final onSky = DifficultyVisuals.onSky(color);
    final caption = cleared
        ? 'concluída'
        : locked
            ? 'bloqueada'
            : active
                ? 'atual'
                : '';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ModeEmblem(
            key: ValueKey('mode-emblem-${difficulty.id}'),
            difficulty: difficulty,
            cleared: cleared,
            locked: locked,
            active: active,
            size: size,
          ),
          const SizedBox(height: 6),
          Text(
            difficulty.labelPt,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.2,
              color: (cleared || active)
                  ? onSky
                  : Colors.white.withValues(alpha: locked ? 0.38 : 0.62),
            ),
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: AppTypography.label(
                size: 9,
                letterSpacing: 0.3,
                color: cleared
                    ? onSky.withValues(alpha: 0.88)
                    : Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pílula de modo para cartões da jornada — emblema + "Modo Observação".
class ModeStatusChip extends StatelessWidget {
  final TrailDifficulty difficulty;
  final bool cleared;
  final bool compact;

  const ModeStatusChip({
    super.key,
    required this.difficulty,
    this.cleared = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = DifficultyVisuals.accentFor(difficulty);
    final onSky = DifficultyVisuals.onSky(color);
    final label = cleared
        ? '${difficulty.labelPt} concluída'
        : 'Modo ${difficulty.labelPt}';

    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          compact ? 8 : 10,
          compact ? 5 : 6,
          compact ? 10 : 12,
          compact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: onSky.withValues(alpha: cleared ? 0.55 : 0.70),
            width: 1.15,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CinematicIcon(
              glyph: DifficultyVisuals.glyphFor(difficulty),
              size: compact ? 13 : 15,
              accent: onSky,
              framed: false,
            ),
            SizedBox(width: compact ? 6 : 8),
            Text(
              label,
              style: AppTypography.label(
                size: compact ? 10 : 11,
                letterSpacing: 0.35,
                color: onSky,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
