import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/trail_repository.dart';
import '../data/entry_trails.dart';
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
import 'character_seals_strip.dart';
import 'immersive_background.dart';
import 'living_seed_card.dart';
import 'streak_week.dart';
import 'ui_primitives.dart';

String pilgrimFormatCount(int n) {
  final digits = n.abs().toString();
  final buf = StringBuffer();
  if (n < 0) buf.write('-');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return buf.toString();
}

String pilgrimShortStopLabel(String title) {
  var t = title.trim();
  t = t.replaceFirst(
    RegExp(r'^(a|o|as|os|um|uma|de|do|da|dos|das)\s+', caseSensitive: false),
    '',
  );
  if (t.length <= 12) return t;
  final words = t.split(RegExp(r'\s+'));
  if (words.length >= 2 && words.last.length >= 3 && words.last.length <= 12) {
    return words.last;
  }
  return t;
}

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

String pilgrimFormatShort(String? yyyyMmDd, {String empty = '—'}) {
  if (yyyyMmDd == null || yyyyMmDd.isEmpty) return empty;
  final parts = yyyyMmDd.split('-');
  if (parts.length != 3) return empty;
  return '${parts[2]}/${parts[1]}';
}

String pilgrimFormatOnline(String? yyyyMmDd) {
  if (yyyyMmDd == null || yyyyMmDd.isEmpty) return '—';
  final today = DateTime.now().toIso8601String().substring(0, 10);
  if (yyyyMmDd == today) return 'Hoje';
  return pilgrimFormatShort(yyyyMmDd);
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
  final bool includeStreakMilestones;

  const PilgrimProfileDetailSections({
    super.key,
    required this.profile,
    required this.entry,
    required this.isOwner,
    this.onOpenSettings,
    this.omitSections = const {},
    this.includeStreakMilestones = true,
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
        PilgrimScenePoster(
          title: profile.lastMissionTitle ??
              profile.lastMissionSlug ??
              'Missão',
          trail: profile.lastTrailTitle,
          date: pilgrimFormatShort(profile.lastMissionCompletedDate, empty: ''),
          insight: profile.lastMissionInsight,
          verseRef: profile.lastMissionRef,
        ),
      );
    }

    if (_show(CaravanProfileSection.trails)) {
      add(
        profile.trails.isEmpty
            ? const PilgrimCinematicSection(
                chapter: 'Trilha',
                subtitle: 'Nenhuma trilha em andamento',
                accent: AppColors.cedar,
                child: PilgrimEmptyHint('Nenhuma trilha em andamento ainda.'),
              )
            : PilgrimTrailPath(trail: profile.trails.first),
      );
      if (profile.trails.length > 1) {
        add(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final trail in profile.trails.skip(1).take(4))
                PilgrimTrailPath(trail: trail, compact: true),
              if (profile.trails.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+ ${profile.trails.length - 5} trilha${profile.trails.length - 5 == 1 ? '' : 's'}',
                    style: AppTypography.label(
                      size: 10,
                      letterSpacing: 0.3,
                      color: Appearance.of(context).textMuted(0.5),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    }

    final showPresence = _show(CaravanProfileSection.presence);
    final showAccuracy = _show(CaravanProfileSection.accuracy) &&
        profile.accuracyPercent != null;
    if (showPresence || showAccuracy) {
      final presence = showPresence
          ? PilgrimConstancyCard(
              streak: profile.streak,
              playDates: profile.playDates,
              walk: entry.walkedToday
                  ? 'Hoje'
                  : pilgrimFormatShort(profile.lastWalkDate),
              online: pilgrimFormatOnline(profile.lastSeenDate),
              walkedToday: entry.walkedToday,
              showStreak: !isOwner && profile.streak > 0,
            )
          : null;
      final accuracy = showAccuracy
          ? PilgrimCinematicSection(
              chapter: 'Precisão',
              subtitle: pilgrimAccuracyEpithet(profile.accuracyPercent!),
              accent: AppColors.teal,
              child: PilgrimPrecisionArc(
                percent: profile.accuracyPercent!,
                correct: profile.lifetimeQuestionsCorrect,
                total: profile.lifetimeQuestionsAnswered,
              ),
            )
          : null;
      if (presence != null) add(presence);
      if (showPresence &&
          includeStreakMilestones &&
          profile.streak > 0) {
        add(LivingSeedCard(streak: profile.streak));
      }
      if (accuracy != null) add(accuracy);
    }

    if (_show(CaravanProfileSection.bible)) {
      final chapters = profile.bibleChaptersRead;
      final books = profile.completeBibleBooks.length;
      final subtitle = chapters == 0
          ? 'Ainda sem leitura registrada'
          : books == 0
              ? '$chapters capítulo${chapters == 1 ? '' : 's'} · medalha Palavra'
              : '$chapters capítulo${chapters == 1 ? '' : 's'} · $books livro${books == 1 ? '' : 's'}';
      add(
        PilgrimCinematicSection(
          chapter: 'Escrituras',
          subtitle: subtitle,
          accent: AppColors.cedar,
          child: chapters == 0
              ? const PilgrimEmptyHint('Ainda sem capítulos lidos registrados.')
              : profile.completeBookNames.isEmpty
                  ? null
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final name in profile.completeBookNames.take(8))
                          SoftBadge(
                            text: name,
                            glyph: CinematicGlyph.book,
                            accent: AppColors.cedar,
                          ),
                        if (profile.completeBookNames.length > 8)
                          SoftBadge(
                            text: '+${profile.completeBookNames.length - 8}',
                            accent: AppColors.cedar,
                          ),
                      ],
                    ),
        ),
      );
    }

    final acquiredSeals =
        CharacterSeals.unlocked(profile.completedMissions);
    if (_show(CaravanProfileSection.trails) &&
        (isOwner || acquiredSeals.isNotEmpty)) {
      add(
        CharacterSealsStrip(
          completed: profile.completedMissions,
          acquiredOnly: !isOwner,
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
  final Widget? child;

  const PilgrimCinematicSection({
    required this.chapter,
    this.subtitle,
    required this.accent,
    this.child,
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
          if (child != null) ...[
            const SizedBox(height: 14),
            child!,
          ],
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
  final String? insight;
  final String? verseRef;

  const PilgrimScenePoster({
    required this.title,
    this.trail,
    this.date,
    this.insight,
    this.verseRef,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final quote = insight?.trim();
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ÚLTIMA CENA',
                style: AppTypography.label(
                  size: 9,
                  letterSpacing: 1.6,
                  color: a.textMuted(0.55),
                ),
              ),
              if (trail != null &&
                  (verseRef == null || verseRef!.isEmpty)) ...[
                const Spacer(),
                Text(
                  trail!,
                  style: AppTypography.label(
                    size: 9,
                    letterSpacing: 0.3,
                    color: a.textMuted(0.5),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.display(
              size: 20,
              weight: FontWeight.w900,
              color: a.text,
            ),
          ),
          if (verseRef != null && verseRef!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              verseRef!,
              style: AppTypography.body(
                size: 13,
                color: a.textMuted(0.65),
              ),
            ),
          ] else if (trail != null) ...[
            const SizedBox(height: 4),
            Text(
              trail!,
              style: AppTypography.body(
                size: 13,
                color: a.textMuted(0.65),
              ),
            ),
          ],
          if (quote != null && quote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '“$quote”',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.verse(
                size: 15,
                color: a.text.withValues(alpha: 0.88),
              ),
            ),
          ],
          if (date != null && date!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.calendar,
                  size: 13,
                  accent: AppColors.accent,
                  framed: false,
                ),
                const SizedBox(width: 6),
                Text(
                  'Concluída em $date',
                  style: AppTypography.label(
                    size: 9,
                    letterSpacing: 0.3,
                    color: AppColors.accent.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ],
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
  final bool compact;

  const PilgrimPrecisionArc({
    required this.percent,
    required this.correct,
    required this.total,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tone = percent >= 80
        ? AppColors.teal
        : percent >= 60
            ? AppColors.accent
            : AppColors.coral;
    final ring = compact ? 72.0 : 100.0;

    if (compact) {
      return Column(
        children: [
          SizedBox(
            width: ring,
            height: ring,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: ring,
                  height: ring,
                  child: CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    color: tone,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$percent%',
                  style: AppTypography.title(
                    size: 18,
                    weight: FontWeight.w900,
                    color: tone,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$correct de $total',
            textAlign: TextAlign.center,
            style: AppTypography.title(
              size: 13,
              weight: FontWeight.w800,
              color: a.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'na jornada',
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 9,
              letterSpacing: 0.2,
              color: a.textMuted(0.5),
            ),
          ),
        ],
      );
    }

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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.inkOnAccent,
            ),
            child: const Center(
              child: CinematicIcon(
                glyph: CinematicGlyph.crown,
                size: 22,
                accent: AppColors.accent,
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
                  days == 1 ? '1 dia no topo' : '$days dias no topo',
                  style: AppTypography.title(
                    size: 16,
                    weight: FontWeight.w900,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Já liderou o ranking geral',
                  style: AppTypography.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: Appearance.of(context).textMuted(0.7),
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
  final bool compact;

  const PilgrimTrailPath({
    required this.trail,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final pct = (trail.progress * 100).round();
    final complete = trail.isComplete;
    final accent = complete ? AppColors.cedar : AppColors.accent;
    final subtitle = trail.description.trim().isEmpty
        ? '${trail.missionsDone} de ${trail.missionsTotal} cenas'
        : trail.description;

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 10 : 12),
      padding: EdgeInsets.fromLTRB(16, compact ? 12 : 14, 16, compact ? 12 : 14),
      decoration: BoxDecoration(
        color: AppColors.nightLight.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: accent.withValues(alpha: complete ? 0.4 : 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                compact ? 'TRILHA' : 'SUA TRILHA',
                style: AppTypography.label(
                  size: 9,
                  letterSpacing: 1.5,
                  color: a.textMuted(0.55),
                ),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 0.2,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            trail.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.display(
              size: compact ? 16 : 20,
              weight: FontWeight.w900,
              color: a.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              size: 12,
              color: a.textMuted(0.58),
            ),
          ),
          const SizedBox(height: 12),
          AppProgressBar(
            value: trail.progress,
            color: accent,
          ),
          if (trail.modules.length >= 2) ...[
            const SizedBox(height: 16),
            _PilgrimHorizontalTrail(
              modules: trail.modules,
              progress: trail.progress,
              accent: accent,
            ),
          ] else ...[
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
        ],
      ),
    );
  }
}

class _PilgrimHorizontalTrail extends StatelessWidget {
  final List<CaravanTrailModuleStop> modules;
  final double progress;
  final Color accent;

  const _PilgrimHorizontalTrail({
    required this.modules,
    required this.progress,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final stops = modules.length > 6 ? modules.take(6).toList() : modules;
    var current = stops.lastIndexWhere((m) => m.isCurrent);
    if (current < 0) current = stops.indexWhere((m) => !m.isComplete);
    if (current < 0) current = stops.length - 1;

    return SizedBox(
      height: 72,
      child: Stack(
        children: [
          Positioned(
            left: 10,
            right: 10,
            top: 11,
            height: 18,
            child: CustomPaint(
              painter: _HorizontalTrailPainter(
                progress: progress,
                active: accent,
                idle: Colors.white.withValues(alpha: 0.18),
                seed: stops.length,
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < stops.length; i++)
                Expanded(
                  child: Column(
                    children: [
                      _TrailStopBeacon(
                        complete: stops[i].isComplete,
                        current: i == current && !stops[i].isComplete,
                        accent: accent,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pilgrimShortStopLabel(stops[i].title),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(
                          size: 8,
                          letterSpacing: 0.1,
                          color: i == current
                              ? accent
                              : a.textMuted(stops[i].isComplete ? 0.55 : 0.38),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrailStopBeacon extends StatelessWidget {
  final bool complete;
  final bool current;
  final Color accent;

  const _TrailStopBeacon({
    required this.complete,
    required this.current,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final size = current ? 18.0 : 12.0;
    return SizedBox(
      height: 22,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: complete || current
                ? accent
                : Colors.white.withValues(alpha: 0.12),
            border: Border.all(
              color: current
                  ? accent
                  : Colors.white.withValues(alpha: complete ? 0.0 : 0.22),
              width: current ? 2 : 1,
            ),
            boxShadow: current
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: complete
              ? Center(
                  child: CinematicIcon(
                    glyph: CinematicGlyph.check,
                    size: 8,
                    accent: AppColors.night.withValues(alpha: 0.85),
                    framed: false,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _HorizontalTrailPainter extends CustomPainter {
  final double progress;
  final Color active;
  final Color idle;
  final int seed;

  const _HorizontalTrailPainter({
    required this.progress,
    required this.active,
    required this.idle,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 1) return;
    final path = _trailPath(size);

    final idlePaint = Paint()
      ..color = idle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    _drawDashed(canvas, path, idlePaint, dash: 5.5, gap: 5.5);

    if (progress <= 0) return;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final activePath = metric.extractPath(
        0,
        metric.length * progress.clamp(0.0, 1.0),
      );
      final activePaint = Paint()
        ..color = active
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      _drawDashed(canvas, activePath, activePaint, dash: 10, gap: 4);
    }
  }

  Path _trailPath(Size size) {
    final rng = math.Random(seed);
    final y = size.height / 2;
    final swing = 5.0 + rng.nextDouble() * 3;
    final dir = seed.isEven ? 1.0 : -1.0;
    final path = Path()..moveTo(0, y);
    path.cubicTo(
      size.width * 0.22,
      y + dir * swing,
      size.width * 0.38,
      y - dir * swing * 0.8,
      size.width * 0.52,
      y + dir * swing * 0.35,
    );
    path.cubicTo(
      size.width * 0.68,
      y - dir * swing,
      size.width * 0.84,
      y + dir * swing * 0.55,
      size.width,
      y,
    );
    return path;
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final len = draw ? dash : gap;
        final next = math.min(distance + len, metric.length);
        if (draw) {
          canvas.drawPath(metric.extractPath(distance, next), paint);
        }
        distance = next;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HorizontalTrailPainter old) =>
      old.progress != progress ||
      old.active != active ||
      old.idle != idle ||
      old.seed != seed;
}

class PilgrimConstancyCard extends StatelessWidget {
  final int streak;
  final List<String> playDates;
  final String walk;
  final String online;
  final bool walkedToday;
  final bool showStreak;

  const PilgrimConstancyCard({
    required this.streak,
    required this.playDates,
    required this.walk,
    required this.online,
    required this.walkedToday,
    required this.showStreak,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final played = playDates.toSet();

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONSTÂNCIA',
            style: AppTypography.label(
              size: 9,
              letterSpacing: 1.5,
              color: a.textMuted(0.55),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.flame,
                size: 18,
                accent: AppColors.streak,
                framed: false,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showStreak
                          ? (streak == 1 ? '1 dia' : '$streak dias')
                          : walk,
                      style: AppTypography.title(
                        size: 16,
                        weight: FontWeight.w900,
                        color: a.text,
                      ),
                    ),
                    Text(
                      showStreak ? 'sequência atual' : 'última caminhada',
                      style: AppTypography.label(
                        size: 8,
                        letterSpacing: 0.2,
                        color: a.textMuted(0.48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreakWeek(
            playedOnDate: (day) {
              final key = day.toIso8601String().substring(0, 10);
              final now = DateTime.now();
              final isToday = day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              return played.contains(key) || (isToday && walkedToday);
            },
          ),
          if (online.isNotEmpty && online != '—') ...[
            const SizedBox(height: 4),
            Text(
              'Online $online',
              style: AppTypography.label(
                size: 8,
                letterSpacing: 0.2,
                color: a.textMuted(0.42),
              ),
            ),
          ],
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
                ListChevron(color: a.textMuted(0.45), size: 20),
            ],
          ),
        ),
      ),
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

