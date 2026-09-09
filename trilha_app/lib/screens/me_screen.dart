import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/trail_repository.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../services/bible_service.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/top_bar.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/living_seed_card.dart';
import '../widgets/milestone_chests.dart';
import '../models/pilgrim_medals.dart';
import '../widgets/pilgrim_medal_vault_panel.dart';
import '../widgets/pilgrim_profile_sections.dart';
import '../widgets/reflection_journal_card.dart';
import '../widgets/ui_primitives.dart';
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
                title: progress.userName,
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
  final _repo = TrailRepository();
  int _trailCount = 0;
  CaravanPilgrimProfile? _caravanProfile;
  int _overallRank = 0;
  bool _caravanLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final trails = await _repo.getTrails();
    if (!mounted) return;
    setState(() {
      _trailCount = trails.where((t) => t.missionSlugs.isNotEmpty).length;
    });
    await _loadCaravan();
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
    final profile = _caravanProfile;
    final accuracy = profile?.accuracyPercent;

    final body = <Widget>[
      const LivingSeedCard(),
      const SizedBox(height: AppSpace.md),
      _JourneySummaryBar(
        steps: progress.steps,
        missions: progress.completedMissions.length,
        trails: _trailCount,
        accuracyPercent: accuracy,
      ),
    ];

    if (_caravanLoading) {
      body.addAll([
        const SizedBox(height: AppSpace.xl),
        const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      ]);
    } else if (profile != null) {
      body.addAll([
        const SizedBox(height: AppSpace.section),
        PilgrimMedalVaultsPanel(
          profile: profile,
          evalContext: PilgrimMedalEvalContext.fromProfile(profile),
        ),
        if (profile.trails.isNotEmpty) ...[
          const SizedBox(height: AppSpace.section),
          _ActiveTrailsCard(trails: profile.trails.take(3).toList()),
        ],
        if (_overallRank > 0) ...[
          const SizedBox(height: AppSpace.md),
          PilgrimMeRankHeader(
            rank: _overallRank,
            weeklySteps: false,
          ),
        ],
      ]);
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
      if (!_caravanLoading) ...[
        const SizedBox(height: AppSpace.md),
        PilgrimOwnerPrivacyBanner(onSettings: _openCaravanPrivacySettings),
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

class _ActiveTrailsCard extends StatelessWidget {
  final List<CaravanTrailSnapshot> trails;

  const _ActiveTrailsCard({required this.trails});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(label: 'Trilhas em andamento'),
          const SizedBox(height: 10),
          for (final trail in trails) PilgrimTrailPath(trail: trail),
        ],
      ),
    );
  }
}

class _JourneySummaryBar extends StatelessWidget {
  final int steps;
  final int missions;
  final int trails;
  final int? accuracyPercent;

  const _JourneySummaryBar({
    required this.steps,
    required this.missions,
    required this.trails,
    this.accuracyPercent,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCell(
              value: '$steps',
              label: 'Passos',
              accent: AppColors.accent,
              glyph: CinematicGlyph.path,
            ),
          ),
          _summaryDivider(context),
          Expanded(
            child: _SummaryCell(
              value: '$missions',
              label: 'Cenas',
              accent: AppColors.primaryLight,
              glyph: CinematicGlyph.scroll,
            ),
          ),
          _summaryDivider(context),
          Expanded(
            child: _SummaryCell(
              value: accuracyPercent != null ? '$accuracyPercent%' : '$trails',
              label: accuracyPercent != null ? 'Acertos' : 'Trilhas',
              accent: accuracyPercent != null ? AppColors.teal : AppColors.cedar,
              glyph: accuracyPercent != null
                  ? CinematicGlyph.target
                  : CinematicGlyph.book,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Appearance.of(context).cardBorder.withValues(alpha: 0.45),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;
  final CinematicGlyph glyph;

  const _SummaryCell({
    required this.value,
    required this.label,
    required this.accent,
    required this.glyph,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      children: [
        CinematicIcon(
          glyph: glyph,
          size: 20,
          accent: accent.withValues(alpha: 0.9),
          framed: false,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTypography.title(
            size: 18,
            weight: FontWeight.w900,
            color: accent,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.label(
            size: 9,
            letterSpacing: 0.35,
            color: a.textMuted(0.5),
          ),
        ),
      ],
    );
  }
}

class _NaPalavraBlock extends StatelessWidget {
  const _NaPalavraBlock();

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final hasBookmarks = progress.parseBookmarks().isNotEmpty;
    final hasShared = progress.sharedVerses.isNotEmpty;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader(label: 'Na Palavra'),
          const SizedBox(height: 12),
          const _FavoritesSection(embedded: true),
          if (hasShared && hasBookmarks) _sectionDivider(a),
          const _SharedVersesSection(embedded: true),
        ],
      ),
    );
  }

  Widget _sectionDivider(AppearanceStyle a) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
      child: Divider(
        height: 1,
        color: a.cardBorder.withValues(alpha: 0.45),
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
        CardHeader(
          label: 'Favoritos',
          trailing: bookmarks.isEmpty
              ? null
              : CountBadge('${bookmarks.length}'),
        ),
        const SizedBox(height: AppSpace.md),
        if (bookmarks.isEmpty)
          Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.star,
                size: 22,
                accent: AppColors.accent.withValues(alpha: 0.95),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nenhum versículo salvo',
                      style: AppTypography.title(size: 14, color: a.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Na Bíblia, toque num versículo e guarde no coração.',
                      style: AppTypography.body(
                        size: 12,
                        color: a.textMuted(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.embedded)
                Icon(
                  Icons.chevron_right_rounded,
                  color: a.textMuted(0.4),
                  size: 20,
                ),
            ],
          )
        else
          ...bookmarks.asMap().entries.map((entry) {
            final i = entry.key;
            final label = _label(entry.value);
            final isLast = i == bookmarks.length - 1;
            return Column(
              children: [
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: a.cardBorder.withValues(alpha: 0.45),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BibleReaderScreen(reference: label),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isLast && i == 0 ? 0 : AppSpace.sm,
                      ),
                      child: Row(
                        children: [
                          CinematicIcon(
                            glyph: CinematicGlyph.star,
                            size: 18,
                            accent: AppColors.accent.withValues(
                              alpha: 0.95,
                            ),
                            framed: false,
                          ),
                          const SizedBox(width: AppSpace.sm),
                          Expanded(
                            child: Text(
                              label,
                              style: AppTypography.title(
                                size: 14,
                                color: a.text,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: a.textMuted(0.4),
                            size: 20,
                          ),
                        ],
                      ),
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
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BibleScreen()),
            ),
            child: content,
          ),
        );
      }
      return content;
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.md),
      child: GlassCard(
        onTap: bookmarks.isEmpty
            ? () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const BibleScreen()))
            : null,
        padding: AppMetrics.cardPadding,
        child: content,
      ),
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
        CardHeader(
          label: 'Compartilhados',
          trailing: refs.isEmpty ? null : CountBadge('${refs.length}'),
        ),
        const SizedBox(height: AppSpace.md),
        if (refs.isEmpty)
          Text(
            'Versículos que você compartilhar aparecem aqui — só a referência.',
            style: AppTypography.body(size: 12, color: a.textMuted(0.55)),
          )
        else
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              for (final ref in refs)
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BibleReaderScreen(reference: ref),
                    ),
                  ),
                  child: SoftBadge(
                    text: ref,
                    glyph: CinematicGlyph.share,
                    accent: AppColors.accent,
                  ),
                ),
            ],
          ),
      ],
    );

    if (embedded) return content;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.md),
      child: GlassCard(
        padding: AppMetrics.cardPadding,
        child: content,
      ),
    );
  }
}

