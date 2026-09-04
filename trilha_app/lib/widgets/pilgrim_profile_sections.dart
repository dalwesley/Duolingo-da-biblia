import 'package:flutter/material.dart';

import '../data/trail_repository.dart';
import '../models/caravan_profile_prefs.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medals.dart';
import '../widgets/pilgrim_medal_vault_panel.dart';
import '../services/backend_service.dart';
import '../services/bible_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';

Color pilgrimRankAccent(int rank) => switch (rank) {
      1 => AppColors.medalGold,
      2 => AppColors.medalSilver,
      3 => AppColors.medalBronze,
      _ => AppColors.accent,
    };

String pilgrimFormatDate(String? yyyyMmDd, {String empty = '—'}) {
  if (yyyyMmDd == null || yyyyMmDd.isEmpty) return empty;
  final parts = yyyyMmDd.split('-');
  if (parts.length != 3) return empty;
  return '${parts[2]}/${parts[1]}/${parts[0]}';
}

String pilgrimFormatOnline(String? yyyyMmDd) {
  if (yyyyMmDd == null || yyyyMmDd.isEmpty) return '—';
  final today = DateTime.now().toIso8601String().substring(0, 10);
  if (yyyyMmDd == today) return 'Hoje';
  return pilgrimFormatDate(yyyyMmDd);
}

String pilgrimAccuracyEpithet(int p) {
  if (p >= 95) return 'Leitura afiada das Escrituras';
  if (p >= 80) return 'Boa compreensão nas cenas';
  if (p >= 60) return 'Caminhando com firmeza';
  return 'Ainda em formação';
}

String pilgrimRankEpithet(int rank) => switch (rank) {
      1 => 'Líder da caravana',
      2 => 'Vice-líder',
      3 => 'No pódio',
      _ => 'Peregrino da caravana',
    };

Future<CaravanPilgrimProfile> loadEnrichedOwnerProfile(
  ProgressService progress,
  BackendService backend,
) async {
  final base = CaravanPilgrimProfile.fromProgress(
    progress: progress,
    uid: backend.uid ?? '',
  );
  final trails = await TrailRepository().getTrails();
  final books = await BibleService.instance.books();
  return base.enriched(catalog: trails, bibleBooks: books);
}

Future<CaravanPilgrimProfile> loadEnrichedVisitorProfile({
  required LeagueEntry entry,
  required BackendService backend,
}) async {
  var base = CaravanPilgrimProfile.fromRankingCard(
    uid: entry.uid,
    name: entry.name,
    steps: entry.steps,
    lastWalkDate: entry.lastWalkDate,
    lastSeenDate: entry.lastSeenDate,
  );

  final uid = entry.uid?.trim();
  if (uid != null && uid.isNotEmpty && backend.isActive) {
    try {
      final result = await backend.fetchPilgrimProfile(uid);
      if (result.hasDocument) {
        try {
          base = CaravanPilgrimProfile.fromCloudMap(
            uid: uid,
            data: result.data!,
            fallbackName: entry.name,
          );
        } catch (e, st) {
          debugPrint('Perfil da caravana: mapa inválido ($uid): $e\n$st');
        }
      } else if (result.isError) {
        debugPrint('Perfil da caravana: nuvem falhou ($uid): ${result.error}');
      }
    } catch (e, st) {
      debugPrint('Perfil da caravana: leitura falhou ($uid): $e\n$st');
    }
  }

  try {
    final trails = await TrailRepository().getTrails();
    final books = await BibleService.instance.books();
    return base.enriched(catalog: trails, bibleBooks: books);
  } catch (e, st) {
    debugPrint('Perfil da caravana: catálogo falhou: $e\n$st');
    return base;
  }
}

class PilgrimProfileDetailSections extends StatelessWidget {
  final CaravanPilgrimProfile profile;
  final LeagueEntry entry;
  final bool isOwner;
  final VoidCallback? onOpenSettings;
  final Set<CaravanProfileSection> omitSections;

  const PilgrimProfileDetailSections({
    super.key,
    required this.profile,
    required this.entry,
    required this.isOwner,
    this.onOpenSettings,
    this.omitSections = const {},
  });

  bool _show(CaravanProfileSection section) =>
      !omitSections.contains(section) &&
      profile.prefs.shouldShow(section, isOwner: isOwner);

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];

    void add(Widget w) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: AppSpace.md));
      sections.add(w);
    }

    if (_show(CaravanProfileSection.daysAsLeader) &&
        profile.daysAsCaravanLeader > 0) {
      add(PilgrimLeadershipMonument(days: profile.daysAsCaravanLeader));
    }

    if (_show(CaravanProfileSection.lastMission) &&
        (profile.lastMissionTitle != null || profile.lastMissionSlug != null)) {
      add(
        PilgrimCinematicSection(
          chapter: 'Última cena',
          subtitle: 'O capítulo mais recente da jornada',
          accent: AppColors.coral,
          child: PilgrimScenePoster(
            title: profile.lastMissionTitle ??
                profile.lastMissionSlug ??
                'Missão',
            trail: profile.lastTrailTitle,
            date: pilgrimFormatDate(profile.lastMissionCompletedDate, empty: ''),
          ),
        ),
      );
    }

    if (_show(CaravanProfileSection.presence)) {
      add(
        PilgrimCinematicSection(
          chapter: 'Presença',
          subtitle: isOwner
              ? 'Última caminhada e online'
              : 'Última caminhada, online e sequência',
          accent: AppColors.teal,
          child: PilgrimPresenceTimeline(
            walk: pilgrimFormatDate(profile.lastWalkDate),
            online: pilgrimFormatOnline(profile.lastSeenDate),
            streak: !isOwner && profile.streak > 0
                ? '${profile.streak} dias'
                : null,
            walkedToday: entry.walkedToday,
            onlineToday: entry.isOnlineToday,
          ),
        ),
      );
    }

    if (_show(CaravanProfileSection.accuracy) &&
        profile.accuracyPercent != null) {
      add(
        PilgrimCinematicSection(
          chapter: 'Precisão',
          subtitle: pilgrimAccuracyEpithet(profile.accuracyPercent!),
          accent: AppColors.teal,
          child: PilgrimPrecisionArc(
            percent: profile.accuracyPercent!,
            correct: profile.lifetimeQuestionsCorrect,
            total: profile.lifetimeQuestionsAnswered,
          ),
        ),
      );
    }

    if (_show(CaravanProfileSection.bible)) {
      add(
        PilgrimCinematicSection(
          chapter: 'Escrituras',
          subtitle: profile.bibleChaptersRead == 0
              ? 'Ainda sem leitura registrada'
              : '${profile.bibleChaptersRead} capítulo${profile.bibleChaptersRead == 1 ? '' : 's'} lidos',
          accent: AppColors.cedar,
          child: profile.bibleChaptersRead == 0
              ? const PilgrimEmptyHint('Ainda sem capítulos lidos registrados.')
              : _PilgrimBibleStats(
                  chapters: profile.bibleChaptersRead,
                  completeBooks: profile.completeBibleBooks.length,
                ),
        ),
      );
    }

    if (_show(CaravanProfileSection.trails)) {
      add(
        PilgrimCinematicSection(
          chapter: 'Trilhas',
          subtitle: profile.trails.isEmpty
              ? 'Nenhuma trilha em andamento'
              : '${profile.trails.length} caminhos abertos',
          accent: AppColors.cedar,
          child: profile.trails.isEmpty
              ? const PilgrimEmptyHint('Nenhuma trilha em andamento ainda.')
              : Column(
                  children: [
                    for (final trail in profile.trails.take(6))
                      PilgrimTrailPath(trail: trail),
                    if (profile.trails.length > 6)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '+ ${profile.trails.length - 6} trilha${profile.trails.length - 6 == 1 ? '' : 's'}',
                          style: AppTypography.label(
                            size: 10,
                            letterSpacing: 0.3,
                            color: Appearance.of(context).textMuted(0.5),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      );
    }

    if (_show(CaravanProfileSection.medals)) {
      add(
        PilgrimMedalVaultsPanel(
          profile: profile,
          evalContext: PilgrimMedalEvalContext.fromProfile(profile),
        ),
      );
    }

    if (isOwner) {
      add(PilgrimOwnerPrivacyBanner(onSettings: onOpenSettings));
    }

    if (!isOwner && sections.isEmpty) {
      add(
        PilgrimCinematicSection(
          chapter: 'Perfil privado',
          subtitle: 'Este peregrino guarda sua jornada',
          accent: AppColors.slate,
          child: const PilgrimEmptyHint(
            'Escolheu não compartilhar detalhes com a caravana.',
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections,
    );
  }
}

class PilgrimMeRankHeader extends StatelessWidget {
  final int rank;
  final bool weeklySteps;

  const PilgrimMeRankHeader({
    super.key,
    required this.rank,
    required this.weeklySteps,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final rankColor = pilgrimRankAccent(rank);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    rankColor.withValues(alpha: 0.22),
                    AppColors.nightLight.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: rank <= 3 ? AppGradients.gold : null,
                    color: rank > 3 ? rankColor.withValues(alpha: 0.25) : null,
                    border: Border.all(
                      color: rankColor.withValues(alpha: 0.65),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '$rankº',
                    style: AppTypography.title(
                      size: 20,
                      weight: FontWeight.w900,
                      color: rank <= 3 ? AppColors.inkOnAccent : rankColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pilgrimRankEpithet(rank).toUpperCase(),
                        style: AppTypography.label(
                          size: 10,
                          letterSpacing: 1.3,
                          color: rankColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weeklySteps
                            ? 'Ranking semanal da caravana'
                            : 'Ranking geral da caravana',
                        style: AppTypography.body(
                          size: 13,
                          weight: FontWeight.w700,
                          color: a.textMuted(0.68),
                        ),
                      ),
                    ],
                  ),
                ),
                CinematicIcon(
                  glyph: CinematicGlyph.crown,
                  size: 28,
                  accent: rankColor,
                  framed: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PilgrimCinematicSection extends StatelessWidget {
  final String chapter;
  final String? subtitle;
  final Color accent;
  final Widget child;

  const PilgrimCinematicSection({
    required this.chapter,
    this.subtitle,
    required this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PilgrimChapterTitle(
            title: chapter,
            subtitle: subtitle,
            accent: accent,
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class PilgrimChapterTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color accent;

  const PilgrimChapterTitle({
    required this.title,
    this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 1.4,
                  color: a.textMuted(0.78),
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: Text(
              subtitle!,
              style: AppTypography.body(
                size: 12,
                color: a.textMuted(0.52),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class PilgrimScenePoster extends StatelessWidget {
  final String title;
  final String? trail;
  final String? date;

  const PilgrimScenePoster({
    required this.title,
    this.trail,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.coral.withValues(alpha: 0.22),
            AppColors.nightLight.withValues(alpha: 0.85),
            AppColors.nightMid,
          ],
        ),
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.42)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: -10,
            child: CinematicIcon(
              glyph: CinematicGlyph.scroll,
              size: 72,
              accent: AppColors.coral.withValues(alpha: 0.18),
              framed: false,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CENA',
                style: AppTypography.label(
                  size: 9,
                  letterSpacing: 2,
                  color: AppColors.coral.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.display(
                  size: 22,
                  weight: FontWeight.w900,
                  color: a.text,
                ),
              ),
              if (trail != null) ...[
                const SizedBox(height: 6),
                Text(
                  trail!,
                  style: AppTypography.body(
                    size: 13,
                    color: a.textMuted(0.65),
                  ),
                ),
              ],
              if (date != null && date!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    CinematicIcon(
                      glyph: CinematicGlyph.calendar,
                      size: 14,
                      accent: AppColors.coral,
                      framed: false,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Concluída em $date',
                      style: AppTypography.label(
                        size: 9,
                        letterSpacing: 0.3,
                        color: AppColors.coral.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class PilgrimPresenceTimeline extends StatelessWidget {
  final String walk;
  final String online;
  final String? streak;
  final bool walkedToday;
  final bool onlineToday;

  const PilgrimPresenceTimeline({
    required this.walk,
    required this.online,
    this.streak,
    required this.walkedToday,
    required this.onlineToday,
  });

  @override
  Widget build(BuildContext context) {
    final stops = <_PilgrimTimelineStop>[
      _PilgrimTimelineStop(
        glyph: CinematicGlyph.path,
        label: 'Caminhou',
        value: walk,
        accent: AppColors.cedar,
        live: walkedToday,
      ),
      _PilgrimTimelineStop(
        glyph: CinematicGlyph.calendar,
        label: 'Online',
        value: online,
        accent: AppColors.teal,
        live: onlineToday,
      ),
      if (streak != null)
        _PilgrimTimelineStop(
          glyph: CinematicGlyph.flame,
          label: 'Sequência',
          value: streak!,
          accent: AppColors.streak,
          live: false,
        ),
    ];

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < stops.length; i++) ...[
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          stops[i - 1].accent.withValues(alpha: 0.35),
                          stops[i].accent.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                  ),
                ),
              _PilgrimTimelineNode(stop: stops[i]),
            ],
          ],
        ),
      ],
    );
  }
}

class _PilgrimTimelineStop {
  final CinematicGlyph glyph;
  final String label;
  final String value;
  final Color accent;
  final bool live;

  const _PilgrimTimelineStop({
    required this.glyph,
    required this.label,
    required this.value,
    required this.accent,
    required this.live,
  });
}

class _PilgrimTimelineNode extends StatelessWidget {
  final _PilgrimTimelineStop stop;

  const _PilgrimTimelineNode({required this.stop});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: stop.accent.withValues(alpha: stop.live ? 0.22 : 0.1),
              border: Border.all(
                color: stop.accent.withValues(alpha: stop.live ? 0.9 : 0.4),
                width: stop.live ? 2 : 1.5,
              ),
            ),
            child: Center(
              child: CinematicIcon(
                glyph: stop.glyph,
                size: 16,
                accent: stop.accent,
                framed: false,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            stop.value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.title(
              size: 13,
              weight: FontWeight.w900,
              color: a.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stop.label,
            style: AppTypography.label(
              size: 8,
              letterSpacing: 0.2,
              color: a.textMuted(0.48),
            ),
          ),
        ],
      ),
    );
  }
}

class PilgrimPrecisionArc extends StatelessWidget {
  final int percent;
  final int correct;
  final int total;

  const PilgrimPrecisionArc({
    required this.percent,
    required this.correct,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tone = percent >= 80
        ? AppColors.teal
        : percent >= 60
            ? AppColors.accent
            : AppColors.coral;

    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  color: tone,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tone.withValues(alpha: 0.1),
                  border: Border.all(color: tone.withValues(alpha: 0.28)),
                ),
                child: Center(
                  child: Text(
                    '$percent%',
                    style: AppTypography.title(
                      size: 22,
                      weight: FontWeight.w900,
                      color: tone,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$correct de $total',
                style: AppTypography.display(
                  size: 20,
                  color: a.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'perguntas certas na jornada',
                style: AppTypography.body(
                  size: 12,
                  color: a.textMuted(0.62),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PilgrimLeadershipMonument extends StatelessWidget {
  final int days;

  const PilgrimLeadershipMonument({required this.days});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.gold),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.28),
                      Colors.transparent,
                      AppColors.inkOnAccent.withValues(alpha: 0.1),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 18, 18),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.inkOnAccent,
                    border: Border.all(
                      color: AppColors.accentSoft,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: CinematicIcon(
                      glyph: CinematicGlyph.crown,
                      size: 30,
                      accent: AppColors.accent,
                      framed: false,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LÍDER DO RANKING',
                        style: AppTypography.label(
                          size: 9,
                          letterSpacing: 1.3,
                          color: AppColors.medalInk.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$days',
                        style: AppTypography.display(
                          size: 38,
                          color: AppColors.inkOnAccent,
                        ),
                      ),
                      Text(
                        days == 1
                            ? 'dia no comando do ranking geral'
                            : 'dias no comando do ranking geral',
                        style: AppTypography.body(
                          size: 13,
                          weight: FontWeight.w800,
                          color: AppColors.medalInk.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
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

class PilgrimTrailPath extends StatelessWidget {
  final CaravanTrailSnapshot trail;

  const PilgrimTrailPath({required this.trail});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final pct = (trail.progress * 100).round();
    final complete = trail.isComplete;
    final accent = complete ? AppColors.cedar : AppColors.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: accent.withValues(alpha: complete ? 0.45 : 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: complete ? CinematicGlyph.check : CinematicGlyph.path,
                size: 20,
                accent: accent,
                framed: false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  trail.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(
                    size: 14,
                    weight: FontWeight.w900,
                    color: a.text,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.2,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: trail.progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${trail.missionsDone} de ${trail.missionsTotal} cenas'
            '${trail.clearedModes.isNotEmpty ? ' · ${trail.clearedModes.join(', ')}' : ''}',
            style: AppTypography.label(
              size: 9,
              letterSpacing: 0,
              color: a.textMuted(0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class PilgrimOwnerPrivacyBanner extends StatelessWidget {
  final VoidCallback? onSettings;

  const PilgrimOwnerPrivacyBanner({super.key, this.onSettings});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSettings,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              const CinematicIcon(
                glyph: CinematicGlyph.tune,
                size: 18,
                accent: AppColors.accent,
                framed: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Toque para escolher o que a caravana vê no seu perfil.',
                  style: AppTypography.body(
                    size: 11,
                    height: 1.4,
                    color: a.textMuted(0.7),
                  ),
                ),
              ),
              if (onSettings != null)
                Icon(Icons.chevron_right_rounded, color: a.textMuted(0.45), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PilgrimBibleStats extends StatelessWidget {
  final int chapters;
  final int completeBooks;

  const _PilgrimBibleStats({
    required this.chapters,
    required this.completeBooks,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      children: [
        _stat(a, '$chapters', chapters == 1 ? 'capítulo' : 'capítulos'),
        const SizedBox(width: 28),
        _stat(
          a,
          '$completeBooks',
          completeBooks == 1 ? 'livro lido' : 'livros lidos',
        ),
      ],
    );
  }

  Widget _stat(AppearanceStyle a, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.title(
            size: 22,
            weight: FontWeight.w900,
            color: a.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.label(
            size: 10,
            letterSpacing: 0.3,
            color: a.textMuted(0.5),
          ),
        ),
      ],
    );
  }
}

class PilgrimEmptyHint extends StatelessWidget {
  final String text;

  const PilgrimEmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Text(
      text,
      style: AppTypography.body(size: 13, color: a.textMuted(0.58)),
    );
  }
}

