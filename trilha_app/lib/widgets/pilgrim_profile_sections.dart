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
import 'living_seed_card.dart';
import 'relic_panel.dart';
import 'streak_week.dart';

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
    photoUrl: entry.photoUrl,
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
            fallbackPhotoUrl: entry.photoUrl,
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
      final featured = profile.featuredTrail;
      if (featured == null) {
        add(
          const RelicPanel(
            accent: AppColors.cedar,
            child: RelicChapter(
              title: 'Trilha',
              whisper: 'Nenhuma trilha em andamento ainda.',
              accent: AppColors.cedar,
            ),
          ),
        );
      } else {
        add(
          PilgrimTrailPath(
            trail: featured,
            owner: isOwner,
            rest: profile.restOpenTrails,
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
          ? RelicPanel(
              accent: AppColors.teal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RelicChapter(
                    title: 'Precisão',
                    whisper: pilgrimAccuracyEpithet(profile.accuracyPercent!),
                    accent: AppColors.teal,
                  ),
                  const SizedBox(height: 16),
                  PilgrimPrecisionArc(
                    percent: profile.accuracyPercent!,
                    correct: profile.lifetimeQuestionsCorrect,
                    total: profile.lifetimeQuestionsAnswered,
                  ),
                ],
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
        RelicPanel(
          accent: AppColors.cedar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RelicChapter(
                title: 'Escrituras',
                whisper: subtitle,
                accent: AppColors.cedar,
              ),
              if (chapters > 0 && profile.completeBookNames.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final name in profile.completeBookNames.take(8))
                      _ScriptureChip(name: name),
                    if (profile.completeBookNames.length > 8)
                      _ScriptureChip(
                        name: '+${profile.completeBookNames.length - 8}',
                      ),
                  ],
                ),
              ],
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
        const RelicPanel(
          accent: AppColors.slate,
          child: RelicChapter(
            title: 'Perfil privado',
            whisper: 'Escolheu não compartilhar detalhes com a caravana.',
            accent: AppColors.slate,
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
    return RelicPanel(
      accent: rankColor,
      elevated: rank <= 3,
      child: Row(
        children: [
          RelicDisc(
            glyph: CinematicGlyph.crown,
            accent: rankColor,
            size: 56,
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
                    letterSpacing: 1.4,
                    color: rankColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$rankº',
                  style: AppTypography.display(
                    size: 28,
                    weight: FontWeight.w900,
                    color: a.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  weeklySteps
                      ? 'Ranking semanal da caravana'
                      : 'Ranking geral da caravana',
                  style: AppTypography.body(
                    size: 13,
                    color: a.textMuted(0.62),
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
    return RelicPanel(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RelicChapter(
            title: chapter,
            whisper: subtitle,
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
    return RelicPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RelicChapter(
            title: 'Última cena',
            whisper: trail,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.display(
              size: 22,
              weight: FontWeight.w900,
              color: a.text,
            ),
          ),
          if (verseRef != null && verseRef!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              verseRef!,
              style: AppTypography.label(
                size: 11,
                letterSpacing: 1.2,
                color: AppColors.accent.withValues(alpha: 0.85),
              ),
            ),
          ],
          if (quote != null && quote.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '“$quote”',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.verse(
                size: 16,
                color: a.text.withValues(alpha: 0.9),
              ),
            ),
          ],
          if (date != null && date!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Concluída em $date',
              style: AppTypography.label(
                size: 9,
                letterSpacing: 1.1,
                color: a.textMuted(0.48),
              ),
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
          RelicDisc(
            glyph: stop.glyph,
            accent: stop.accent,
            size: 36,
            lit: stop.live,
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
  final bool stat;

  const PilgrimPrecisionArc({
    required this.percent,
    required this.correct,
    required this.total,
    this.compact = false,
    this.stat = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tone = percent >= 80
        ? AppColors.teal
        : percent >= 60
            ? AppColors.accent
            : AppColors.coral;
    final ring = stat
        ? 44.0
        : compact
        ? 72.0
        : 108.0;
    final gauge = SizedBox(
      width: ring,
      height: ring,
      child: CustomPaint(
        painter: _PrecisionGaugePainter(
          progress: percent / 100,
          tone: tone,
          stroke: stat ? 4.2 : 7,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: stat ? 6 : 0),
              child: Text(
                '$percent%',
                style: AppTypography.title(
                  size: stat
                      ? 11
                      : compact
                      ? 18
                      : 22,
                  weight: FontWeight.w900,
                  color: a.text,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (stat) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 44, child: Center(child: gauge)),
          const SizedBox(height: 6),
          Text(
            '$correct/$total',
            style: AppTypography.label(
              size: 9,
              letterSpacing: 1.2,
              color: a.textMuted(0.5),
            ),
          ),
        ],
      );
    }

    if (compact) {
      return Column(
        children: [
          gauge,
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
              letterSpacing: 0.8,
              color: a.textMuted(0.5),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        gauge,
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
                  size: 13,
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

class _PrecisionGaugePainter extends CustomPainter {
  final double progress;
  final Color tone;
  final double stroke;

  const _PrecisionGaugePainter({
    required this.progress,
    required this.tone,
    this.stroke = 7,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    const start = -math.pi * 0.75;
    const sweep = math.pi * 1.5;

    canvas.drawCircle(
      center,
      r * 0.78,
      Paint()
        ..shader = RadialGradient(
          colors: [
            tone.withValues(alpha: 0.16),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r * 0.78)),
    );

    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      start,
      sweep,
      false,
      track,
    );

    if (progress <= 0) return;
    final arc = Paint()
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: [
          tone.withValues(alpha: 0.45),
          tone,
          Color.lerp(tone, const Color(0xFFFFF0C8), 0.4)!,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      start,
      sweep * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _PrecisionGaugePainter old) =>
      old.progress != progress || old.tone != tone || old.stroke != stroke;
}

class PilgrimLeadershipMonument extends StatelessWidget {
  final int days;

  const PilgrimLeadershipMonument({required this.days});

  @override
  Widget build(BuildContext context) {
    return RelicPanel(
      elevated: true,
      child: Row(
        children: [
          const RelicDisc(
            glyph: CinematicGlyph.crown,
            accent: AppColors.accent,
            size: 52,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days == 1 ? '1 dia no topo' : '$days dias no topo',
                  style: AppTypography.display(
                    size: 20,
                    weight: FontWeight.w900,
                    color: Appearance.of(context).text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Já liderou o ranking geral',
                  style: AppTypography.body(
                    size: 13,
                    color: Appearance.of(context).textMuted(0.62),
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
  final bool owner;
  final List<CaravanTrailSnapshot> rest;

  const PilgrimTrailPath({
    required this.trail,
    this.compact = false,
    this.owner = false,
    this.rest = const [],
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

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 10 : 0),
      child: RelicPanel(
        accent: accent,
        padding: EdgeInsets.fromLTRB(16, compact ? 14 : 16, 16, compact ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RelicChapter(
              title: compact
                  ? 'Trilha'
                  : rest.isNotEmpty
                  ? (owner ? 'Suas trilhas' : 'Trilhas')
                  : (owner ? 'Sua trilha' : 'Trilha'),
              whisper: rest.isEmpty
                  ? subtitle
                  : '${rest.length + (trail.isComplete ? 0 : 1)} em curso',
              accent: accent,
              trailing: Text(
                '$pct%',
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 1.1,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              trail.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.display(
                size: compact ? 16 : 22,
                weight: FontWeight.w900,
                color: a.text,
              ),
            ),
            const SizedBox(height: 12),
            RelicProgress(value: trail.progress, accent: accent),
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
            if (rest.isNotEmpty) ...[
              const SizedBox(height: 16),
              RelicHairline(accent: accent),
              const SizedBox(height: 4),
              for (final other in rest) _OpenTrailRow(trail: other),
            ],
          ],
        ),
      ),
    );
  }
}

class _OpenTrailRow extends StatelessWidget {
  final CaravanTrailSnapshot trail;

  const _OpenTrailRow({required this.trail});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final pct = (trail.progress * 100).round();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trail.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(
                    size: 15,
                    color: a.text,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$pct%',
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 0.8,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${trail.missionsDone} de ${trail.missionsTotal} cenas',
            style: AppTypography.body(
              size: 12,
              color: a.textMuted(0.52),
            ),
          ),
          const SizedBox(height: 8),
          RelicProgress(value: trail.progress, accent: AppColors.accent),
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

    return RelicPanel(
      accent: AppColors.streak,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RelicChapter(
            title: 'Constância',
            accent: AppColors.streak,
            whisper: showStreak ? 'sequência atual' : 'última caminhada',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              RelicDisc(
                glyph: CinematicGlyph.flame,
                accent: AppColors.streak,
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  showStreak
                      ? (streak == 1 ? '1 dia' : '$streak dias')
                      : walk,
                  style: AppTypography.display(
                    size: 24,
                    weight: FontWeight.w900,
                    color: a.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
            const SizedBox(height: 8),
            Text(
              'Online $online',
              style: AppTypography.label(
                size: 9,
                letterSpacing: 0.8,
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
    return RelicPanel(
      onTap: onSettings,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          const RelicDisc(
            glyph: CinematicGlyph.tune,
            accent: AppColors.accent,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Toque para escolher o que a caravana vê no seu perfil.',
              style: AppTypography.body(
                size: 13,
                height: 1.4,
                color: a.textMuted(0.68),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScriptureChip extends StatelessWidget {
  final String name;

  const _ScriptureChip({required this.name});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.cedar.withValues(alpha: 0.35)),
        color: AppColors.cedar.withValues(alpha: 0.08),
      ),
      child: Text(
        name,
        style: AppTypography.verse(
          size: 14,
          color: a.text.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

