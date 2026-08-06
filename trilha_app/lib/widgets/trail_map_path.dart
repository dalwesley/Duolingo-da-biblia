import 'package:flutter/material.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/genesis_theme.dart';
import 'cinematic_icon.dart';

/// Sequência editorial de cenas — tipografia no lugar de ícones de app.
class TrailMapPath extends StatelessWidget {
  final List<Mission> missions;
  final int startGlobalIndex;
  final List<String> allSlugs;
  final List<String> completedMissions;
  final GenesisModuleTheme? theme;
  final void Function(String slug)? onMissionTap;

  const TrailMapPath({
    super.key,
    required this.missions,
    required this.startGlobalIndex,
    required this.allSlugs,
    required this.completedMissions,
    this.theme,
    this.onMissionTap,
  });

  bool _completed(String slug) => completedMissions.contains(slug);

  bool _unlocked(String slug) {
    final index = allSlugs.indexOf(slug);
    if (index <= 0) return true;
    return completedMissions.contains(allSlugs[index - 1]);
  }

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) return const SizedBox.shrink();

    final gold = theme?.pathActive ?? AppColors.accent;
    final inactive =
        theme?.pathInactive ?? Colors.white.withValues(alpha: 0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < missions.length; i++) ...[
          Padding(
            padding: EdgeInsets.only(
              top: i == 0 ? 0 : AppSpace.sm,
              bottom: i == missions.length - 1 ? 0 : 0,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 50,
                    child: _TrailMapStepRail(
                      activeAbove: i > 0 && _completed(missions[i - 1].slug),
                      activeBelow: _completed(missions[i].slug),
                      completed: _completed(missions[i].slug),
                      unlocked: _unlocked(missions[i].slug),
                      activeColor: gold,
                      inactiveColor: inactive,
                      showTop: i > 0,
                      showBottom: i < missions.length - 1,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _MissionSceneCard(
                      mission: missions[i],
                      index: startGlobalIndex + i + 1,
                      completed: _completed(missions[i].slug),
                      unlocked: _unlocked(missions[i].slug),
                      theme: theme,
                      onTap: _unlocked(missions[i].slug)
                          ? () => onMissionTap?.call(missions[i].slug)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SceneConnector extends StatelessWidget {
  final bool active;
  final Color activeColor;
  final Color inactiveColor;

  const _SceneConnector({
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;
    return SizedBox(
      width: 24,
      child: CustomPaint(
        painter: _SceneConnectorPainter(
          color: color.withValues(alpha: active ? 0.7 : 0.35),
        ),
      ),
    );
  }
}

class _SceneConnectorPainter extends CustomPainter {
  final Color color;

  _SceneConnectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final midX = size.width / 2;
    final variance = size.width * 0.6;

    path.moveTo(midX, 0);
    path.cubicTo(
      midX + variance * 0.2,
      size.height * 0.18,
      midX - variance * 0.3,
      size.height * 0.35,
      midX + variance * 0.1,
      size.height * 0.5,
    );
    path.cubicTo(
      midX + variance * 0.35,
      size.height * 0.65,
      midX - variance * 0.15,
      size.height * 0.82,
      midX,
      size.height,
    );

    const dashLength = 6.0;
    const gap = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SceneConnectorPainter old) {
    return old.color != color;
  }
}

class _TrailMapStepRail extends StatelessWidget {
  final bool activeAbove;
  final bool activeBelow;
  final bool completed;
  final bool unlocked;
  final Color activeColor;
  final Color inactiveColor;
  final bool showTop;
  final bool showBottom;

  const _TrailMapStepRail({
    required this.activeAbove,
    required this.activeBelow,
    required this.completed,
    required this.unlocked,
    required this.activeColor,
    required this.inactiveColor,
    required this.showTop,
    required this.showBottom,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = completed
        ? activeColor
        : unlocked
        ? activeColor.withValues(alpha: 0.85)
        : inactiveColor.withValues(alpha: 0.35);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showTop)
          Expanded(
            child: _SceneConnector(
              active: activeAbove,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
            boxShadow: [
              if (completed || unlocked)
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.22),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
            ],
          ),
        ),
        if (showBottom)
          Expanded(
            child: _SceneConnector(
              active: activeBelow,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ),
      ],
    );
  }
}

class _MissionSceneCard extends StatelessWidget {
  final Mission mission;
  final int index;
  final bool completed;
  final bool unlocked;
  final GenesisModuleTheme? theme;
  final VoidCallback? onTap;

  const _MissionSceneCard({
    required this.mission,
    required this.index,
    required this.completed,
    required this.unlocked,
    required this.theme,
    this.onTap,
  });

  bool get _current => unlocked && !completed;

  String get _indexLabel => index.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    // Chrome de UI = mesmo amarelo do CTA Continuar (pathActive / accent).
    final gold = theme?.pathActive ?? AppColors.accent;
    final accent = gold;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        color: unlocked
            ? (completed ? a.cardFill.withValues(alpha: 0.72) : a.cardFill)
            : a.cardFill.withValues(alpha: 0.55),
        border: Border.all(
          color: _current
              ? AppColors.accent
              : completed
              ? gold.withValues(alpha: 0.28)
              : a.cardBorder,
          width: _current ? 1.5 : 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: _current ? 64 : 56,
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: _current ? 18 : 16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: a.cardBorder.withValues(alpha: unlocked ? 0.9 : 0.5),
                  ),
                ),
                color: _current
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    mission.isBoss ? '∞' : _indexLabel,
                    style: AppTypography.display(
                      size: _current ? 28 : 22,
                      weight: FontWeight.w700,
                      height: 1,
                      color: unlocked
                          ? (_current
                                ? AppColors.accent
                                : a.text.withValues(
                                    alpha: completed ? 0.35 : 0.75,
                                  ))
                          : a.text.withValues(alpha: 0.28),
                    ),
                  ),
                  if (_current) ...[
                    const SizedBox(height: 8),
                    Container(width: 18, height: 1.5, color: AppColors.accent),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  _current ? 16 : 14,
                  16,
                  _current ? 16 : 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          mission.isBoss
                              ? 'DESAFIO'
                              : _current
                              ? 'PRÓXIMA LIÇÃO'
                              : completed
                              ? 'CONCLUÍDO'
                              : 'PASSO',
                          style: AppTypography.label(
                            size: 10,
                            weight: FontWeight.w700,
                            letterSpacing: 1.6,
                            color: _current
                                ? AppColors.accent
                                : completed
                                ? gold.withValues(alpha: 0.55)
                                : a.textMuted(unlocked ? 0.45 : 0.28),
                          ),
                        ),
                        if (!unlocked) ...[
                          const Spacer(),
                          Text(
                            'Bloqueada',
                            style: AppTypography.body(
                              size: 11,
                              weight: FontWeight.w600,
                              color: a.textMuted(0.35),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Opacity(
                          opacity: unlocked ? (completed ? 0.45 : 1) : 0.35,
                          child: CinematicIcon.mission(
                            mission.title,
                            isBoss: mission.isBoss,
                            size: _current ? 42 : 34,
                            accent: AppColors.accent,
                            glowing: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mission.title,
                                style: AppTypography.display(
                                  size: _current ? 22 : 18,
                                  weight: FontWeight.w800,
                                  height: 1.15,
                                  color: a.text.withValues(
                                    alpha: unlocked
                                        ? (completed ? 0.45 : 0.98)
                                        : 0.4,
                                  ),
                                ),
                              ),
                              if (mission.subtitle.isNotEmpty) ...[
                                const SizedBox(height: AppSpace.xs),
                                Text(
                                  mission.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.body(
                                    size: 13,
                                    height: 1.3,
                                    weight: FontWeight.w500,
                                    color: a.textMuted(
                                      unlocked
                                          ? (completed ? 0.35 : 0.55)
                                          : 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_current && mission.intro.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        mission.intro,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          size: 13,
                          height: 1.4,
                          weight: FontWeight.w500,
                          color: a.textMuted(0.6),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Continuar →',
                        style: AppTypography.cta(
                          size: 14,
                          color: gold,
                        ).copyWith(letterSpacing: 0.2),
                      ),
                    ] else if (_current) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Continuar →',
                        style: AppTypography.cta(
                          size: 14,
                          color: gold,
                        ).copyWith(letterSpacing: 0.2),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Concluídas recuam — legíveis, sem disputar com a cena atual.
    final faded = completed ? Opacity(opacity: 0.55, child: card) : card;

    if (onTap == null) return faded;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        splashColor: accent.withValues(alpha: 0.1),
        highlightColor: accent.withValues(alpha: 0.05),
        child: faded,
      ),
    );
  }
}
