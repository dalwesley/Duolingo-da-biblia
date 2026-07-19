import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../services/backend_service.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/spiritual_growth.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/living_seed_card.dart';
import '../widgets/milestone_chests.dart';
import '../widgets/reflection_journal_card.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/user_avatar.dart';
import 'bible_screen.dart';

/// Perfil / jornada — aberto pelo avatar na home.
class MeScreen extends StatefulWidget {
  final Widget? topBar;

  const MeScreen({
    super.key,
    this.topBar,
  });

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  final _repo = TrailRepository();
  int _trailCount = 0;

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
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final a = Appearance.of(context);
    final growth = SpiritualGrowth.fromStreak(progress.streak);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        widget.topBar == null
            ? AppSpace.lg
            : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        AppSpace.screen,
        scrollPaddingBelowNav(context),
      ),
      children: [
        if (widget.topBar != null) ...[
          widget.topBar!,
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            UserAvatar(
              photoUrl: backend.userPhotoUrl,
              name: progress.userName,
              radius: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.userName,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: a.text,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    growth.title,
                    style: AppTypography.body(
                      size: 13,
                      weight: FontWeight.w700,
                      color: AppColors.accent.withValues(alpha: 0.9),
                    ),
                  ),
                  if (backend.userEmail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      backend.userEmail!,
                      style: AppTypography.body(size: 11, color: a.textMuted(0.55)),
                    ),
                  ],
                ],
              ),
            ),
            CinematicIcon(
              glyph: switch (growth.stage) {
                GrowthStage.seed => CinematicGlyph.seed,
                GrowthStage.sprout => CinematicGlyph.tree,
                GrowthStage.sapling => CinematicGlyph.tree,
                GrowthStage.olive => CinematicGlyph.tree,
                GrowthStage.lamp => CinematicGlyph.lamp,
              },
              size: 44,
              accent: growth.stage == GrowthStage.lamp
                  ? AppColors.accent
                  : AppColors.primaryLight,
              glowing: false,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const LivingSeedCard(),
        const SizedBox(height: 14),
        _JourneySeals(
          steps: progress.steps,
          missions: progress.completedMissions.length,
          trails: _trailCount,
          streak: progress.streak,
        ),
        const SizedBox(height: 18),
        const WeeklyQuestsCard(),
        const _FavoritesSection(),
        const SizedBox(height: 14),
        const ReflectionJournalCard(),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FavoritesSection extends StatefulWidget {
  const _FavoritesSection();

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
      _namesByAbbrev = {
        for (final b in books) b.abbrev.toLowerCase(): b.name,
      };
    });
  }

  String _label(({String abbrev, int chapter, int verse}) b) {
    final name =
        _namesByAbbrev[b.abbrev.toLowerCase()] ?? b.abbrev.toUpperCase();
    return '${name} ${b.chapter}:${b.verse}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final bookmarks = progress.parseBookmarks().take(8).toList();
    if (bookmarks.isEmpty) return const SizedBox.shrink();

    final a = Appearance.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const SectionLabel('Favoritos'),
        const SizedBox(height: 10),
        ...bookmarks.map((b) {
          final label = _label(b);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BibleReaderScreen(reference: label),
                ),
              ),
              padding: AppMetrics.cardPadding,
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: AppColors.accent.withValues(alpha: 0.95),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.title(size: 14, color: a.text),
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
          );
        }),
      ],
    );
  }
}

class _JourneySeals extends StatelessWidget {
  final int steps;
  final int missions;
  final int trails;
  final int streak;

  const _JourneySeals({
    required this.steps,
    required this.missions,
    required this.trails,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Seal(
            glyph: CinematicGlyph.spark,
            value: '$steps',
            label: 'Passos',
            accent: AppColors.accent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Seal(
            glyph: CinematicGlyph.flame,
            value: '$streak',
            label: 'Dias',
            accent: AppColors.streak,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Seal(
            glyph: CinematicGlyph.scroll,
            value: '$missions',
            label: 'Avanços',
            accent: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Seal(
            glyph: CinematicGlyph.path,
            value: '$trails',
            label: 'Trilhas',
            accent: AppColors.cedar,
          ),
        ),
      ],
    );
  }
}

class _Seal extends StatelessWidget {
  final CinematicGlyph glyph;
  final String value;
  final String label;
  final Color accent;

  const _Seal({
    required this.glyph,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Column(
        children: [
          CinematicIcon(glyph: glyph, size: 26, accent: accent, glowing: false),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: a.textMuted(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
