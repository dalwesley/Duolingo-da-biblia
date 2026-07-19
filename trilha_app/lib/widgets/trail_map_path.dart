import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
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
    final inactive = theme?.pathInactive ?? Colors.white.withValues(alpha: 0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < missions.length; i++) ...[
          if (i > 0)
            _SceneConnector(
              active: _completed(missions[i - 1].slug),
              activeColor: gold,
              inactiveColor: inactive,
            ),
          _MissionSceneCard(
            mission: missions[i],
            index: startGlobalIndex + i + 1,
            completed: _completed(missions[i].slug),
            unlocked: _unlocked(missions[i].slug),
            theme: theme,
            onTap: _unlocked(missions[i].slug)
                ? () => onMissionTap?.call(missions[i].slug)
                : null,
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
      height: 22,
      child: Center(
        child: Column(
          children: [
            Container(
              width: 2,
              height: 6,
              decoration: BoxDecoration(
                color: color.withValues(alpha: active ? 0.7 : 0.35),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: active ? 0.9 : 0.35),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
            Container(
              width: 2,
              height: 6,
              decoration: BoxDecoration(
                color: color.withValues(alpha: active ? 0.7 : 0.35),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
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
    final top = theme?.nodeCurrentTop ?? AppColors.primaryLight;
    final bottom = theme?.nodeCurrentBottom ?? AppColors.primaryDark;
    final accent = theme?.decorColor ?? AppColors.accent;
    final gold = theme?.pathActive ?? AppColors.accent;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_current ? 20 : 16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: unlocked
              ? [
                  Color.lerp(bottom, const Color(0xFF05040A), completed ? 0.72 : 0.22)!
                      .withValues(alpha: _current ? 0.92 : completed ? 0.38 : 0.78),
                  Color.lerp(top, bottom, 0.62)!
                      .withValues(alpha: _current ? 0.62 : completed ? 0.16 : 0.48),
                ]
              : [
                  Colors.white.withValues(alpha: 0.035),
                  Colors.white.withValues(alpha: 0.015),
                ],
        ),
        border: Border.all(
          color: _current
              ? accent.withValues(alpha: 0.42)
              : completed
                  ? gold.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: unlocked ? 0.12 : 0.06),
        ),
        boxShadow: [
          if (_current)
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 32,
              offset: const Offset(0, 14),
            )
          else if (unlocked && !completed)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
        ],
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
                    color: Colors.white.withValues(
                      alpha: unlocked ? (completed ? 0.04 : 0.08) : 0.04,
                    ),
                  ),
                ),
                gradient: _current
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accent.withValues(alpha: 0.14),
                          Colors.transparent,
                        ],
                      )
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    mission.isBoss ? '∞' : _indexLabel,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: _current ? 28 : 22,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: unlocked
                          ? (_current
                              ? accent
                              : Colors.white.withValues(
                                  alpha: completed ? 0.28 : 0.7,
                                ))
                          : Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  if (_current) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 18,
                      height: 1.5,
                      color: accent.withValues(alpha: 0.7),
                    ),
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
                                  ? 'NO CAMINHO'
                                  : completed
                                      ? 'CONCLUÍDO'
                                      : 'PASSO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: _current
                                ? accent.withValues(alpha: 0.95)
                                : completed
                                    ? gold.withValues(alpha: 0.38)
                                    : Colors.white.withValues(
                                        alpha: unlocked ? 0.4 : 0.25,
                                      ),
                          ),
                        ),
                        if (!unlocked) ...[
                          const Spacer(),
                          Text(
                            'Bloqueada',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.32),
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
                          opacity: unlocked
                              ? (completed ? 0.4 : 1)
                              : 0.35,
                          child: CinematicIcon.mission(
                            mission.title,
                            isBoss: mission.isBoss,
                            size: _current ? 42 : 34,
                            accent: accent,
                            glowing: _current,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mission.title,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: _current ? 24 : 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.15,
                                  color: Colors.white.withValues(
                                    alpha: unlocked
                                        ? (completed ? 0.42 : 0.96)
                                        : 0.38,
                                  ),
                                ),
                              ),
                              if (mission.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  mission.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.3,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(
                                      alpha: unlocked
                                          ? (completed ? 0.32 : 0.55)
                                          : 0.28,
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
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                    Text(
                      'Entrar no caminho →',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: gold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 20,
                      color: gold.withValues(alpha: 0.95),
                    ),
                        ],
                      ),
                    ] else if (unlocked && !completed) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Abrir →',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: accent.withValues(alpha: 0.85),
                        ),
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

    // Concluídas recuam — legíveis, mas sem disputar com a cena atual.
    final faded = completed
        ? Opacity(opacity: 0.52, child: card)
        : card;

    if (onTap == null) return faded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_current ? 20 : 16),
        splashColor: accent.withValues(alpha: 0.1),
        highlightColor: accent.withValues(alpha: 0.05),
        child: faded,
      ),
    );
  }
}
