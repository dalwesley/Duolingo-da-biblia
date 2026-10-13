import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/genesis_theme.dart';
import '../utils/trail_progress.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'winding_trail.dart';

/// Cenas de uma etapa como níveis numa curva.
class TrailMapPath extends StatelessWidget {
  final List<Mission> missions;
  final int startGlobalIndex;
  final List<String> allSlugs;
  final List<String> completedMissions;
  final GenesisModuleTheme? theme;
  final Color? modeAccent;
  final void Function(String slug)? onMissionTap;

  const TrailMapPath({
    super.key,
    required this.missions,
    required this.startGlobalIndex,
    required this.allSlugs,
    required this.completedMissions,
    this.theme,
    this.modeAccent,
    this.onMissionTap,
  });

  bool _completed(String slug) => completedMissions.contains(slug);

  bool _unlocked(String slug) =>
      TrailProgress.isMissionUnlocked(slug, allSlugs, completedMissions);

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) return const SizedBox.shrink();

    final accent = modeAccent ?? theme?.pathActive ?? AppRoles.chrome;

    return WindingTrail(
      walked: accent,
      track: Color.lerp(const Color(0xFFB7C6D6), AppColors.textOnDark, 0.15)!,
      waveOffset: startGlobalIndex,
      stops: [for (var i = 0; i < missions.length; i++) _stop(i, accent)],
    );
  }

  WindingStop _stop(int i, Color accent) {
    final mission = missions[i];
    final completed = _completed(mission.slug);
    final unlocked = _unlocked(mission.slug);
    final current = unlocked && !completed;
    final size = current ? 72.0 : (mission.isBoss ? 64.0 : 56.0);
    final bubbleOnLeft = current && windingBubbleOnLeft(startGlobalIndex + i);
    return WindingStop(
      nodeSize: size,
      passed: completed,
      nodeLeading: !bubbleOnLeft,
      child: _SceneLevel(
        mission: mission,
        indexLabel: '${startGlobalIndex + i + 1}',
        completed: completed,
        unlocked: unlocked,
        current: current,
        accent: accent,
        size: size,
        bubbleOnLeft: bubbleOnLeft,
        onTap: unlocked ? () => onMissionTap?.call(mission.slug) : null,
      ),
    );
  }
}

class _SceneLevel extends StatelessWidget {
  final Mission mission;
  final String indexLabel;
  final bool completed;
  final bool unlocked;
  final bool current;
  final Color accent;
  final double size;
  final bool bubbleOnLeft;
  final VoidCallback? onTap;

  const _SceneLevel({
    required this.mission,
    required this.indexLabel,
    required this.completed,
    required this.unlocked,
    required this.current,
    required this.accent,
    required this.size,
    required this.bubbleOnLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disc = _SceneDisc(
      mission: mission,
      indexLabel: indexLabel,
      completed: completed,
      unlocked: unlocked,
      current: current,
      accent: accent,
      size: size,
    );
    final body = current
        ? Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (bubbleOnLeft) ...[
                _SceneBubble(mission: mission, accent: accent),
                const SizedBox(width: 8),
              ],
              disc,
              if (!bubbleOnLeft) ...[
                const SizedBox(width: 8),
                _SceneBubble(mission: mission, accent: accent),
              ],
            ],
          )
        : disc;
    return Semantics(
      label: mission.localizedTitle,
      button: true,
      enabled: onTap != null,
      child: onTap == null
          ? body
          : ActPress(onTap: onTap, depth: current ? 3 : 2, child: body),
    );
  }
}

class _SceneDisc extends StatelessWidget {
  final Mission mission;
  final String indexLabel;
  final bool completed;
  final bool unlocked;
  final bool current;
  final Color accent;
  final double size;

  const _SceneDisc({
    required this.mission,
    required this.indexLabel,
    required this.completed,
    required this.unlocked,
    required this.current,
    required this.accent,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final reward = mission.isBoss;
    final live = completed || current;
    final fill = reward
        ? (live ? AppRoles.reward : const Color(0xFFFFE7A3))
        : (live ? accent : const Color(0xFFE7EEF6));
    final ink = live
        ? (reward ? const Color(0xFF3A2A00) : DifficultyVisuals.onSky(accent))
        : const Color(0xFF4A5C72).withValues(alpha: unlocked ? 0.9 : 0.4);

    if (reward) {
      return _StarNode(
        size: size,
        fill: fill,
        child: CinematicIcon(
          glyph: CinematicGlyph.crown,
          size: current ? 26 : 22,
          accent: ink,
          framed: false,
        ),
      );
    }

    return PathNode(
      size: size,
      fill: fill,
      glow: current ? accent : null,
      child: Text(
        indexLabel,
        style: AppTypography.title(
          size: current ? 20 : 16,
          height: 1,
          color: ink,
        ),
      ),
    );
  }
}

class _StarNode extends StatelessWidget {
  final double size;
  final Color fill;
  final Widget child;

  const _StarNode({
    required this.size,
    required this.fill,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final lip = Color.lerp(fill, const Color(0xFF1A2433), 0.28)!;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _StarPainter(color: lip, dy: 4),
          ),
          CustomPaint(
            size: Size.square(size),
            painter: _StarPainter(color: fill, dy: -1),
          ),
          child,
        ],
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  final double dy;

  const _StarPainter({required this.color, required this.dy});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 + dy);
    final outer = size.width / 2;
    final inner = outer * 0.58;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final p = c + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) =>
      old.color != color || old.dy != dy;
}

class _SceneBubble extends StatelessWidget {
  final Mission mission;
  final Color accent;

  const _SceneBubble({required this.mission, required this.accent});

  @override
  Widget build(BuildContext context) {
    final ink = mission.isBoss ? AppRoles.reward : accent;
    return Container(
      width: 132,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EEF6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            mission.localizedTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.title(
              size: 14,
              height: 1.15,
              color: const Color(0xFF1C2A3A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.commonContinue,
            style: AppTypography.cta(size: 14, color: ink),
          ),
        ],
      ),
    );
  }
}
