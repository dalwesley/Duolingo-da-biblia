import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/caravan_pilgrim_profile.dart';
import '../models/caravan_profile_prefs.dart';
import '../models/corner_challenge.dart';
import '../services/bible_service.dart';
import '../services/backend_service.dart';
import '../services/corner_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/living_seed_card.dart';
import '../widgets/milestone_chests.dart';
import '../widgets/pilgrim_profile_sections.dart';
import '../widgets/portrait_picker_sheet.dart';
import '../widgets/reflection_journal_card.dart';
import '../widgets/relic_panel.dart';
import '../widgets/streak_week.dart';
import '../widgets/top_bar.dart';
import '../widgets/user_avatar.dart';
import 'bible_screen.dart';
import 'settings_screen.dart';

/// Abre o perfil completo do usuário (avatar na home ou card na caravana).
void openMeProfile(BuildContext context) {
  final progress = context.read<ProgressService>();
  final mode = progress.settings.appearanceMode;
  final appearance = AppearanceStyle.resolve(mode);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) => Appearance(
        mode: mode,
        style: appearance,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ImmersiveBackground(
            appearance: appearance,
            child: MeScreen(
              topBar: TopBar(
                inline: true,
                immersive: true,
                dark: appearance.onDark,
                title: 'Perfil',
                subtitle: 'Sua caminhada',
                onBack: () => Navigator.pop(ctx),
                leadingGlyph: CinematicGlyph.humanity,
                chromeAccent: AppColors.orchid,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Perfil / progresso — aberto pelo avatar na home.
class MeScreen extends StatefulWidget {
  final Widget? topBar;

  const MeScreen({super.key, this.topBar});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  CaravanPilgrimProfile? _caravanProfile;
  int _overallRank = 0;
  bool _caravanLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCaravan();
  }

  Future<void> _loadCaravan() async {
    final progress = context.read<ProgressService>();
    final backend = context.read<BackendService>();
    final league = context.read<LeagueService>();

    try {
      final profile = await loadEnrichedOwnerProfile(progress, backend);
      var rank = 0;
      if (backend.isActive) {
        final overall = await backend.fetchOverallPlayers();
        final entries = [
          for (final p in overall)
            LeagueEntry(
              uid: p.uid,
              name: p.name,
              steps: p.steps,
              lastWalkDate: p.lastWalkDate,
              lastSeenDate: p.lastSeenDate,
              photoUrl: p.photoUrl,
            ),
        ];
        rank = league.userRank(entries);
      }
      if (!mounted) return;
      setState(() {
        _caravanProfile = profile;
        _overallRank = rank;
        _caravanLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _caravanLoading = false);
    }
  }

  void _openCaravanPrivacySettings() => openSettings(context);

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final record = context.watch<CornerService>().record;
    final profile = _caravanProfile;
    final accuracy = profile?.accuracyPercent ??
        (progress.lifetimeQuestionsAnswered > 0
            ? ((progress.lifetimeQuestionsCorrect /
                          progress.lifetimeQuestionsAnswered) *
                      100)
                  .round()
                  .clamp(0, 100)
            : null);

    final body = <Widget>[
      _ProfileIdentityCard(
        steps: progress.steps,
        missions: progress.completedMissions.length,
        accuracyPercent: accuracy,
        accuracyCorrect:
            profile?.lifetimeQuestionsCorrect ??
            progress.lifetimeQuestionsCorrect,
        accuracyTotal:
            profile?.lifetimeQuestionsAnswered ??
            progress.lifetimeQuestionsAnswered,
        rank: _overallRank,
        leaderDays: profile?.daysAsCaravanLeader ?? progress.daysAsCaravanLeader,
        record: record,
      ),
      const SizedBox(height: AppSpace.section),
      const LivingSeedCard(),
    ];

    if (_caravanLoading) {
      body.addAll([
        const SizedBox(height: AppSpace.xl),
        const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      ]);
    } else if (profile != null) {
      final backend = context.read<BackendService>();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      body.addAll([
        const SizedBox(height: AppSpace.section),
        PilgrimProfileDetailSections(
          profile: profile,
          entry: LeagueEntry(
            uid: backend.uid,
            name: progress.userName,
            steps: progress.steps,
            isUser: true,
            lastWalkDate: progress.lastPlayedDate,
            lastSeenDate: today,
            photoUrl: backend.userPhotoUrl,
          ),
          isOwner: true,
          onOpenSettings: _openCaravanPrivacySettings,
          omitSections: const {
            CaravanProfileSection.ranking,
            CaravanProfileSection.daysAsLeader,
            CaravanProfileSection.accuracy,
            CaravanProfileSection.presence,
          },
          includeStreakMilestones: false,
        ),
      ]);
    } else {
      body.add(
        PilgrimOwnerPrivacyBanner(onSettings: _openCaravanPrivacySettings),
      );
    }

    body.addAll([
      const SizedBox(height: AppSpace.section),
      const WeeklyQuestsCard(),
      const SizedBox(height: AppSpace.section),
      if (profile != null && !_caravanLoading)
        const _NaPalavraBlock()
      else ...[
        const _FavoritesSection(),
        const _SharedVersesSection(),
      ],
      if (progress.missionReflections.isNotEmpty) ...[
        const SizedBox(height: AppSpace.section),
        const ReflectionJournalCard(),
      ],
      const SizedBox(height: AppSpace.sm),
    ]);

    if (widget.topBar == null) {
      return ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpace.screen,
          AppSpace.lg,
          AppSpace.screen,
          scrollPaddingBelowNav(context),
        ),
        children: body,
      );
    }

    final topInset = MediaQuery.viewPaddingOf(context).top + AppSpace.sm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpace.screen,
            topInset,
            AppSpace.screen,
            0,
          ),
          child: widget.topBar!,
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpace.screen,
              AppSpace.afterTopBar,
              AppSpace.screen,
              scrollPaddingBelowNav(context),
            ),
            children: body,
          ),
        ),
      ],
    );
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  final int steps;
  final int missions;
  final int? accuracyPercent;
  final int accuracyCorrect;
  final int accuracyTotal;
  final int rank;
  final int leaderDays;
  final CornerRecord record;

  const _ProfileIdentityCard({
    required this.steps,
    required this.missions,
    required this.accuracyPercent,
    required this.accuracyCorrect,
    required this.accuracyTotal,
    required this.rank,
    required this.leaderDays,
    required this.record,
  });

  String? get _whisper {
    final parts = <String>[];
    if (rank > 0) {
      parts.add(rank <= 3 ? pilgrimRankEpithet(rank) : '$rankº na caravana');
    }
    if (leaderDays > 0) {
      parts.add(leaderDays == 1 ? '1 dia no topo' : '$leaderDays dias no topo');
    }
    if (!record.isEmpty) parts.add(record.line);
    if (parts.isEmpty && accuracyPercent != null) {
      parts.add(pilgrimAccuracyEpithet(accuracyPercent!));
    }
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final a = Appearance.of(context);
    final name = progress.userName.trim().isEmpty
        ? 'Peregrino'
        : progress.userName.trim();
    final whisper = _whisper;
    final showPrecision = accuracyPercent != null && accuracyTotal > 0;

    return RelicPanel(
      elevated: true,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              UserAvatar(
                name: name,
                photoUrl: backend.userPhotoUrl,
                seed: backend.uid,
                style: progress.settings.portraitStyle,
                radius: 40,
                borderColor: AppColors.accent.withValues(alpha: 0.85),
                editable: true,
                onTap: () => showPortraitPickerSheet(context),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.display(
                        size: 24,
                        weight: FontWeight.w800,
                        color: a.text,
                        height: 1.05,
                      ),
                    ),
                    if (whisper != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        whisper,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          size: 13,
                          height: 1.3,
                          color: rank > 0 && rank <= 3
                              ? pilgrimRankAccent(rank)
                              : a.textMuted(0.62),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const RelicHairline(),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _IdentityStat(
                  value: pilgrimFormatCount(steps),
                  label: 'Passos',
                ),
              ),
              _IdentityRule(a: a),
              Expanded(
                child: _IdentityStat(
                  value: pilgrimFormatCount(missions),
                  label: 'Cenas',
                ),
              ),
              if (showPrecision) ...[
                _IdentityRule(a: a),
                Expanded(
                  child: PilgrimPrecisionArc(
                    percent: accuracyPercent!,
                    correct: accuracyCorrect,
                    total: accuracyTotal,
                    stat: true,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const RelicHairline(),
          const SizedBox(height: 12),
          const StreakWeek(orbSize: 30),
        ],
      ),
    );
  }
}

class _IdentityStat extends StatelessWidget {
  final String value;
  final String label;

  const _IdentityStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: AppTypography.title(
                  size: 20,
                  weight: FontWeight.w900,
                  color: a.text,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: AppTypography.label(
            size: 9,
            letterSpacing: 1.2,
            color: a.textMuted(0.5),
          ),
        ),
      ],
    );
  }
}

class _IdentityRule extends StatelessWidget {
  final AppearanceStyle a;

  const _IdentityRule({required this.a});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: a.cardBorder.withValues(alpha: 0.85),
    );
  }
}

class _NaPalavraBlock extends StatelessWidget {
  const _NaPalavraBlock();

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final hasBookmarks = progress.parseBookmarks().isNotEmpty;
    final hasShared = progress.sharedVerses.isNotEmpty;

    return RelicPanel(
      accent: AppColors.cedar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelicChapter(
            title: 'Na Palavra',
            accent: AppColors.cedar,
            whisper: hasBookmarks || hasShared
                ? null
                : 'Versos que você guarda e os que já saíram daqui.',
          ),
          const SizedBox(height: 14),
          const _FavoritesSection(embedded: true),
          if (hasShared && hasBookmarks) ...[
            const SizedBox(height: 14),
            const RelicHairline(accent: AppColors.cedar),
            const SizedBox(height: 14),
          ],
          const _SharedVersesSection(embedded: true),
        ],
      ),
    );
  }
}

class _FavoritesSection extends StatefulWidget {
  final bool embedded;

  const _FavoritesSection({this.embedded = false});

  @override
  State<_FavoritesSection> createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<_FavoritesSection> {
  Map<String, String> _namesByAbbrev = const {};

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    final books = await BibleService.instance.books();
    if (!mounted) return;
    setState(() {
      _namesByAbbrev = {for (final b in books) b.abbrev.toLowerCase(): b.name};
    });
  }

  String _label(({String abbrev, int chapter, int verse}) b) {
    final name =
        _namesByAbbrev[b.abbrev.toLowerCase()] ?? b.abbrev.toUpperCase();
    return '$name ${b.chapter}:${b.verse}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final bookmarks = progress.parseBookmarks().take(8).toList();
    final a = Appearance.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RelicChapter(
          title: 'Guardados',
          accent: AppColors.cedar,
          displayTitle: false,
          trailing: bookmarks.isEmpty
              ? null
              : Text(
                  '${bookmarks.length}',
                  style: AppTypography.label(
                    size: 10,
                    letterSpacing: 1.1,
                    color: a.textMuted(0.5),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        if (bookmarks.isEmpty)
          Text(
            'Na Bíblia, toque num versículo e guarde no coração.',
            style: AppTypography.body(size: 13, color: a.textMuted(0.55)),
          )
        else
          ...bookmarks.asMap().entries.map((entry) {
            final i = entry.key;
            final label = _label(entry.value);
            return Column(
              children: [
                if (i > 0) const RelicHairline(accent: AppColors.cedar),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BibleReaderScreen(reference: label),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: AppTypography.verse(
                              size: 16,
                              color: a.text.withValues(alpha: 0.92),
                            ),
                          ),
                        ),
                        Text(
                          'abrir',
                          style: AppTypography.label(
                            size: 9,
                            letterSpacing: 1.1,
                            color: AppColors.cedar.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
      ],
    );

    if (widget.embedded) {
      if (bookmarks.isEmpty) {
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BibleScreen()),
          ),
          child: content,
        );
      }
      return content;
    }

    return RelicPanel(
      accent: AppColors.cedar,
      onTap: bookmarks.isEmpty
          ? () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BibleScreen()),
              )
          : null,
      child: content,
    );
  }
}

class _SharedVersesSection extends StatelessWidget {
  final bool embedded;

  const _SharedVersesSection({this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final refs = progress.sharedVerses.take(12).toList();
    final a = Appearance.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RelicChapter(
          title: 'Enviados',
          accent: AppColors.cedar,
          displayTitle: false,
          trailing: refs.isEmpty
              ? null
              : Text(
                  '${refs.length}',
                  style: AppTypography.label(
                    size: 10,
                    letterSpacing: 1.1,
                    color: a.textMuted(0.5),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        if (refs.isEmpty)
          Text(
            'Versículos que você compartilhar aparecem aqui — só a referência.',
            style: AppTypography.body(size: 13, color: a.textMuted(0.55)),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final ref in refs)
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BibleReaderScreen(reference: ref),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(
                        color: AppColors.cedar.withValues(alpha: 0.35),
                      ),
                      color: AppColors.cedar.withValues(alpha: 0.08),
                    ),
                    child: Text(
                      ref,
                      style: AppTypography.verse(
                        size: 14,
                        color: a.text.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );

    if (embedded) return content;

    return RelicPanel(accent: AppColors.cedar, child: content);
  }
}

