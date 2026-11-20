import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/trail_repository.dart';
import '../data/entry_trails.dart';
import '../l10n/app_language.dart';
import '../l10n/l10n_global.dart';
import '../models/caravan_profile_prefs.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medals.dart';
import '../models/trail.dart';
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
import 'near_rewards_card.dart';
import 'pilgrim_profile_cover.dart' show PilgrimPostcardStrip;
import 'pilgrim_vault.dart';
import 'postcard_album.dart';
import 'relic_panel.dart';
import 'streak_week.dart';
import 'ui_primitives.dart';
import 'profile_privacy.dart';
import 'profile_section.dart';

String pilgrimFormatCount(int n) =>
    NumberFormat.decimalPattern(L10n.current.localeName).format(n);

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

Color pilgrimRankAccent(int rank, {Color fallback = AppRoles.chrome}) =>
    switch (rank) {
      1 => AppColors.medalGold,
      2 => AppColors.medalSilver,
      3 => AppColors.medalBronze,
      _ => fallback,
    };

String pilgrimFormatShort(String? yyyyMmDd, {String empty = '—'}) {
  if (yyyyMmDd == null || yyyyMmDd.isEmpty) return empty;
  final date = DateTime.tryParse(yyyyMmDd);
  if (yyyyMmDd.split('-').length != 3 || date == null) return empty;
  return DateFormat.Md(L10n.current.localeName).format(date);
}

String pilgrimFormatOnline(String? yyyyMmDd) {
  if (yyyyMmDd == null || yyyyMmDd.isEmpty) return '—';
  final today = DateTime.now().toIso8601String().substring(0, 10);
  if (yyyyMmDd == today) return L10n.current.commonToday;
  return pilgrimFormatShort(yyyyMmDd);
}

String pilgrimAccuracyEpithet(int p) {
  final l10n = L10n.current;
  if (p >= 95) return l10n.pilgrimAccuracySharp;
  if (p >= 80) return l10n.pilgrimAccuracyGood;
  if (p >= 60) return l10n.pilgrimAccuracySteady;
  return l10n.pilgrimAccuracyForming;
}

String pilgrimRankEpithet(int rank) => switch (rank) {
  1 => L10n.current.pilgrimRankLeader,
  2 => L10n.current.pilgrimRankRunnerUp,
  3 => L10n.current.pilgrimRankPodium,
  _ => L10n.current.pilgrimRankListed,
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

/// Selos e medalhas no mesmo cofre — e, no perfil próprio, os postais e o
/// "Quase lá" de cada gaveta. O baú em si mora em [PilgrimVault].
class PilgrimChest extends StatefulWidget {
  final Widget seals;
  final Widget medals;
  final Widget? postcards;
  final CaravanPilgrimProfile profile;
  final bool isOwner;

  const PilgrimChest({
    super.key,
    required this.seals,
    required this.medals,
    required this.profile,
    required this.isOwner,
    this.postcards,
  });

  @override
  State<PilgrimChest> createState() => _PilgrimChestState();
}

class _PilgrimChestState extends State<PilgrimChest> {
  late final Future<List<Trail>> _trails = TrailRepository().getTrails();

  Widget _withNear(NearKind kind, Widget child) => widget.isOwner
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NearRewardsCard(kind: kind),
            child,
          ],
        )
      : child;

  /// Vitrine no perfil: o conteúdo e, no pé, a linha fina do "Quase lá".
  Widget? _slimNear(NearKind kind, Widget child) => widget.isOwner
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            child,
            NearRewardsCard(kind: kind, slim: true),
          ],
        )
      : null;

  /// Vitrine dos postais no perfil: uma fileira com os mais novos e a
  /// linha do "Quase lá".
  Widget _postcardsPreview(BuildContext context) {
    final profile = widget.profile;
    final List<({String slug, String? day})> scenes;
    if (widget.isOwner) {
      final p = context.read<ProgressService>();
      final days = <String, String>{...p.missionCompletedOn, ...p.postcardsOn};
      scenes = [
        for (final e in days.entries) (slug: e.key, day: e.value as String?),
      ]..sort((x, y) => (y.day ?? '').compareTo(x.day ?? ''));
    } else {
      scenes = [
        for (final slug in profile.completedMissions.reversed)
          (slug: slug, day: null),
      ];
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PilgrimPostcardStrip(
          scenes: scenes,
          showHeader: false,
          max: 8,
          viewerDone: widget.isOwner
              ? null
              : context.read<ProgressService>().completedMissions.toSet(),
          onRedo: widget.isOwner
              ? (slug) =>
                    Navigator.of(context).pushNamed('/lesson', arguments: slug)
              : null,
        ),
        if (widget.isOwner)
          const NearRewardsCard(kind: NearKind.postcards, slim: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = widget.profile;
    final postcards = widget.postcards;
    final postcardCount = postcards == null
        ? null
        : widget.isOwner
        ? context.select(
            (ProgressService p) =>
                {...p.missionCompletedOn.keys, ...p.postcardsOn.keys}.length,
          )
        : profile.completedMissions.length;
    final sealCount = CharacterSeals.unlocked(profile.completedMissions).length;

    return FutureBuilder<List<Trail>>(
      future: _trails,
      builder: (context, snap) {
        final trails = snap.data;
        final medalCount = trails == null
            ? null
            : PilgrimMedals.unlockedCount(
                profile,
                trails,
                ctx: PilgrimMedalEvalContext.fromProfile(profile),
              );
        return PilgrimVault(
          title: l10n.pilgrimCollections,
          seeAllLabel: l10n.vaultSeeAll,
          drawers: [
            // No perfil próprio os postais vêm primeiro: é a parte mais
            // visual da coleção.
            if (postcards != null)
              VaultDrawer(
                label: l10n.postcardsTitle,
                glyph: CinematicGlyph.mail,
                count: postcardCount,
                preview: _postcardsPreview(context),
                child: _withNear(NearKind.postcards, postcards),
              ),
            VaultDrawer(
              label: l10n.medalVaultTitle,
              glyph: CinematicGlyph.trophy,
              count: medalCount,
              preview: _slimNear(NearKind.medals, widget.medals),
              child: _withNear(NearKind.medals, widget.medals),
              eye: PrivacyEye(
                sections: const {CaravanProfileSection.medals},
                label: l10n.medalVaultTitle,
              ),
            ),
            VaultDrawer(
              label: l10n.sealsTitle,
              glyph: CinematicGlyph.seal,
              count: sealCount,
              preview: _slimNear(NearKind.seals, widget.seals),
              child: _withNear(NearKind.seals, widget.seals),
              eye: PrivacyEye(
                sections: const {CaravanProfileSection.trails},
                label: l10n.pilgrimSealsAndTrails,
              ),
            ),
          ],
        );
      },
    );
  }
}

class PilgrimProfileDetailSections extends StatelessWidget {
  final CaravanPilgrimProfile profile;
  final LeagueEntry entry;
  final bool isOwner;
  final VoidCallback? onOpenSettings;
  final Set<CaravanProfileSection> omitSections;
  final bool includeStreakMilestones;

  /// Esconde o caminho da trilha em destaque (no perfil próprio as trilhas
  /// já estão na aba Trilhas e no herói da Hoje). Os selos continuam.
  final bool showTrailPath;

  /// Quando o cartão de identidade já mostra o que estas seções omitem.
  final bool suppressEmptyState;

  /// Perfil próprio: selos e medalhas sobem logo após a identidade;
  /// o histórico (última cena, trilha, Escrituras) vem depois.
  final bool collectionsFirst;

  /// Quando a tela já mostra o banner de privacidade em outro ponto.
  final bool showOwnerPrivacyBanner;

  /// CTA do estado vazio das medalhas (só dono).
  final VoidCallback? onStartWalking;

  /// Postais de quem é visitado: entram no cofre, ao lado das medalhas.
  final Widget? visitorPostcards;

  const PilgrimProfileDetailSections({
    super.key,
    required this.profile,
    required this.entry,
    required this.isOwner,
    this.onOpenSettings,
    this.omitSections = const {},
    this.includeStreakMilestones = true,
    this.showTrailPath = true,
    this.suppressEmptyState = false,
    this.collectionsFirst = false,
    this.showOwnerPrivacyBanner = true,
    this.onStartWalking,
    this.visitorPostcards,
  });

  bool _show(CaravanProfileSection section) =>
      !omitSections.contains(section) &&
      profile.prefs.shouldShow(section, isOwner: isOwner);

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];

    void add(Widget w) {
      if (sections.isNotEmpty) {
        sections.add(const SizedBox(height: AppSpace.section));
      }
      sections.add(w);
    }

    void addCollections() {
      final acquiredSeals = CharacterSeals.unlocked(profile.completedMissions);
      final showSeals =
          _show(CaravanProfileSection.trails) &&
          (isOwner || acquiredSeals.isNotEmpty);
      final showMedals = _show(CaravanProfileSection.medals);
      final seals = CharacterSealsStrip(
        completed: profile.completedMissions,
        acquiredOnly: !isOwner,
        embedded: showMedals,
      );
      final medals = PilgrimMedalVaultsPanel(
        profile: profile,
        evalContext: PilgrimMedalEvalContext.fromProfile(profile),
        recognizeToUid: isOwner ? null : profile.uid,
        onStartWalking: isOwner ? onStartWalking : null,
        embedded: showSeals,
      );

      if (showSeals && showMedals) {
        add(
          PilgrimChest(
            seals: seals,
            medals: medals,
            profile: profile,
            isOwner: isOwner,
            postcards: isOwner ? const PostcardAlbum() : visitorPostcards,
          ),
        );
      } else {
        if (!isOwner && visitorPostcards != null) add(visitorPostcards!);
        if (showSeals) {
          add(seals);
        } else if (showMedals) {
          add(medals);
        }
      }

      if (collectionsFirst && _show(CaravanProfileSection.bible)) {
        add(_escriturasPanel());
      }
    }

    if (collectionsFirst) addCollections();

    if (_show(CaravanProfileSection.daysAsLeader) &&
        profile.daysAsCaravanLeader > 0) {
      add(PilgrimLeadershipMonument(days: profile.daysAsCaravanLeader));
    }

    if (_show(CaravanProfileSection.lastMission) &&
        (profile.lastMissionTitle != null || profile.lastMissionSlug != null)) {
      add(
        PilgrimScenePoster(
          title:
              profile.lastMissionTitle ??
              profile.lastMissionSlug ??
              L10n.current.pilgrimSceneFallback,
          trail: profile.lastTrailTitle,
          date: pilgrimFormatShort(profile.lastMissionCompletedDate, empty: ''),
          insight: profile.lastMissionInsight,
          verseRef: profile.lastMissionRef,
        ),
      );
    }

    if (_show(CaravanProfileSection.trails) && showTrailPath) {
      final featured = profile.featuredTrail;
      if (featured == null) {
        add(
          ProfileSection(
            accent: AppRoles.navTrails,
            glyph: CinematicGlyph.path,
            title: L10n.current.pilgrimTrail,
            caption: L10n.current.pilgrimNoTrailYet,
            trailing: PrivacyEye(
              sections: const {CaravanProfileSection.trails},
              label: L10n.current.pilgrimSealsAndTrails,
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
    final showAccuracy =
        _show(CaravanProfileSection.accuracy) &&
        profile.accuracyPercent != null;
    if (showPresence || showAccuracy) {
      final presence = showPresence
          ? PilgrimConstancyCard(
              streak: profile.streak,
              playDates: profile.playDates,
              walk: entry.walkedToday
                  ? L10n.current.commonToday
                  : pilgrimFormatShort(profile.lastWalkDate),
              online: pilgrimFormatOnline(profile.lastSeenDate),
              walkedToday: entry.walkedToday,
              showStreak: !isOwner && profile.streak > 0,
            )
          : null;
      final accuracy = showAccuracy
          ? RelicPanel(
              accent: AppRoles.success,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RelicChapter(
                    title: L10n.current.pilgrimAccuracyTitle,
                    whisper: pilgrimAccuracyEpithet(profile.accuracyPercent!),
                    accent: AppRoles.success,
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
      if (showPresence && includeStreakMilestones && profile.streak > 0) {
        add(LivingSeedCard(streak: profile.streak));
      }
      if (accuracy != null) add(accuracy);
    }

    if (_show(CaravanProfileSection.bible) && !collectionsFirst) {
      add(_escriturasPanel());
    }

    if (!collectionsFirst) addCollections();

    if (isOwner && showOwnerPrivacyBanner) {
      add(PilgrimOwnerPrivacyBanner(onSettings: onOpenSettings));
    }

    if (!isOwner && sections.isEmpty && !suppressEmptyState) {
      add(
        ProfileSection(
          accent: AppRoles.chrome,
          glyph: CinematicGlyph.lock,
          title: L10n.current.pilgrimPrivateTitle,
          caption: L10n.current.pilgrimPrivateBody,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections,
    );
  }

  Widget _escriturasPanel() {
    final chapters = profile.bibleChaptersRead;
    final books = profile.completeBibleBooks.length;
    final l10n = L10n.current;
    final subtitle = chapters == 0
        ? l10n.pilgrimNoReadingYet
        : books == 0
        ? l10n.pilgrimChaptersWordMedal(chapters)
        : l10n.pilgrimChaptersBooks(chapters, books);
    final hasBooks = chapters > 0 && profile.completeBookNames.isNotEmpty;
    return ProfileSection(
      accent: AppRoles.navBible,
      glyph: CinematicGlyph.book,
      title: l10n.pilgrimScriptures,
      caption: subtitle,
      trailing: PrivacyEye(
        sections: const {CaravanProfileSection.bible},
        label: l10n.pilgrimScriptures,
      ),
      child: !hasBooks
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...[
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
    super.key,
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
    return ProfileSection(
      accent: AppColors.clay,
      glyph: CinematicGlyph.scroll,
      title: context.l10n.profileSectionLastScene,
      caption: trail,
      trailing: PrivacyEye(
        sections: const {CaravanProfileSection.lastMission},
        label: context.l10n.profileSectionLastScene,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            const SizedBox(height: 6),
            Text(
              verseRef!,
              style: AppTypography.label(
                size: 11,
                letterSpacing: 1.2,
                color: a.sectionLabel,
              ),
            ),
          ],
          if (quote != null && quote.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '“$quote”',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.verse(size: 16, color: a.text),
            ),
          ],
          if (date != null && date!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              context.l10n.pilgrimCompletedOn(date!),
              style: AppTypography.body(size: 12, color: a.textFaint),
            ),
          ],
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
    super.key,
    required this.percent,
    required this.correct,
    required this.total,
    this.compact = false,
    this.stat = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    // Acerto alto = sucesso; abaixo disso, neutro (formando, não erro).
    final tone = percent >= 80 ? AppRoles.success : a.chrome;
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
          track: a.progressTrack,
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
                      ? 12
                      : compact
                      ? 18
                      : 20,
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              context.l10n.pilgrimCorrectRatio(correct, total),
              maxLines: 1,
              style: AppTypography.body(size: 12, color: a.textSecondary),
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
            context.l10n.pilgrimCorrectOf(correct, total),
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 12, color: a.text),
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.pilgrimOnTheJourney,
            textAlign: TextAlign.center,
            style: AppTypography.body(size: 11, color: a.textFaint),
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
                context.l10n.pilgrimCorrectOf(correct, total),
                style: AppTypography.display(size: 20, color: a.text),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.pilgrimCorrectOnJourney,
                style: AppTypography.body(size: 13, color: a.textSecondary),
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
  final Color track;
  final double stroke;

  const _PrecisionGaugePainter({
    required this.progress,
    required this.tone,
    required this.track,
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
          colors: [tone.withValues(alpha: 0.16), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: r * 0.78)),
    );

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      start,
      sweep,
      false,
      trackPaint,
    );

    if (progress <= 0) return;
    final arc = Paint()
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: [
          tone.withValues(alpha: 0.45),
          tone,
          Color.lerp(tone, AppColors.textOnDark, 0.4)!,
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
      old.progress != progress ||
      old.tone != tone ||
      old.track != track ||
      old.stroke != stroke;
}

class PilgrimLeadershipMonument extends StatelessWidget {
  final int days;

  const PilgrimLeadershipMonument({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      accent: AppRoles.reward,
      glyph: CinematicGlyph.crown,
      title: context.l10n.profileDaysOnTop(days),
      caption: context.l10n.pilgrimLedOverall,
    );
  }
}

class PilgrimTrailPath extends StatelessWidget {
  final CaravanTrailSnapshot trail;
  final bool compact;
  final bool owner;
  final List<CaravanTrailSnapshot> rest;

  const PilgrimTrailPath({
    super.key,
    required this.trail,
    this.compact = false,
    this.owner = false,
    this.rest = const [],
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final complete = trail.isComplete;
    final accent = complete ? AppRoles.reward : AppRoles.presence;
    final l10n = context.l10n;
    final subtitle = trail.description.trim().isEmpty
        ? l10n.pilgrimScenesOf(trail.missionsDone, trail.missionsTotal)
        : trail.description;

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 10 : 0),
      child: ProfileSection(
        accent: complete ? AppRoles.reward : AppRoles.navTrails,
        glyph: CinematicGlyph.path,
        title: compact
            ? l10n.pilgrimTrail
            : rest.isNotEmpty
            ? (owner ? l10n.pilgrimYourTrails : l10n.pilgrimTrails)
            : (owner ? l10n.pilgrimYourTrail : l10n.pilgrimTrail),
        caption: rest.isEmpty
            ? subtitle
            : l10n.pilgrimTrailsInProgress(
                rest.length + (trail.isComplete ? 0 : 1),
              ),
        trailing: PrivacyEye(
          sections: const {CaravanProfileSection.trails},
          label: l10n.pilgrimSealsAndTrails,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trail.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.display(
                size: compact ? 18 : 20,
                weight: FontWeight.w900,
                color: a.text,
              ),
            ),
            const SizedBox(height: 12),
            AppProgressBar(value: trail.progress, color: accent),
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
                '${l10n.pilgrimScenesOf(trail.missionsDone, trail.missionsTotal)}'
                '${trail.clearedModes.isNotEmpty ? ' · ${trail.clearedModes.join(', ')}' : ''}',
                style: AppTypography.body(size: 12, color: a.textFaint),
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
                  style: AppTypography.title(size: 14, color: a.text),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$pct%',
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 0.8,
                  color: trail.isComplete ? AppRoles.reward : AppRoles.presence,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            context.l10n.pilgrimScenesOf(
              trail.missionsDone,
              trail.missionsTotal,
            ),
            style: AppTypography.body(size: 12, color: a.textFaint),
          ),
          const SizedBox(height: 8),
          AppProgressBar(
            value: trail.progress,
            color: trail.isComplete ? AppRoles.reward : AppRoles.presence,
            height: 6,
          ),
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
                idle: a.textFaint,
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
                          size: 10,
                          letterSpacing: 0.1,
                          color: i == current ? accent : a.textFaint,
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
    final a = Appearance.of(context);
    final size = current ? 18.0 : 12.0;
    return SizedBox(
      height: 22,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: complete || current ? accent : a.textFaint,
            border: Border.all(
              color: complete || current ? accent : a.textFaint,
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
    super.key,
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

    return ProfileSection(
      accent: AppRoles.streak,
      glyph: CinematicGlyph.flame,
      title: context.l10n.pilgrimStreak,
      caption: showStreak
          ? context.l10n.pilgrimStreakOngoing
          : context.l10n.pilgrimLastStudyDay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RelicDisc(
                glyph: CinematicGlyph.flame,
                accent: AppRoles.streak,
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  showStreak ? context.l10n.commonDays(streak) : walk,
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
              final isToday =
                  day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              return played.contains(key) || (isToday && walkedToday);
            },
          ),
          if (online.isNotEmpty && online != '—') ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.pilgrimLastSeen(online),
              style: AppTypography.body(size: 12, color: a.textFaint),
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
    return Semantics(
      button: onSettings != null,
      child: RelicPanel(
        onTap: onSettings,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg,
          vertical: AppSpace.md,
        ),
        child: Row(
          children: [
            CinematicIcon(
              glyph: CinematicGlyph.tune,
              accent: a.chrome,
              size: AppMetrics.leadingIcon,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.pilgrimPrivacyTitle,
                    style: AppTypography.title(size: 14, color: a.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.pilgrimPrivacyBody,
                    style: AppTypography.body(
                      size: 12,
                      height: 1.35,
                      color: a.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onSettings != null) ...[
              const SizedBox(width: AppSpace.sm),
              ListChevron(color: a.textFaint),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScriptureChip extends StatelessWidget {
  final String name;

  const _ScriptureChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return SoftBadge(
      text: name,
      glyph: CinematicGlyph.star,
      accent: AppRoles.reward,
    );
  }
}
