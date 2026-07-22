import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/living_seed_card.dart';
import '../widgets/milestone_chests.dart';
import '../widgets/reflection_journal_card.dart';
import '../widgets/ui_primitives.dart';
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
          const SizedBox(height: AppSpace.afterTopBar),
        ],
        const LivingSeedCard(),
        const SizedBox(height: AppSpace.section),
        _JourneySeals(
          steps: progress.steps,
          missions: progress.completedMissions.length,
          trails: _trailCount,
          streak: progress.streak,
        ),
        const SizedBox(height: AppSpace.section),
        const WeeklyQuestsCard(),
        const _FavoritesSection(),
        const _SharedVersesSection(),
        const SizedBox(height: AppSpace.section),
        const ReflectionJournalCard(),
        const SizedBox(height: AppSpace.sm),
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
    final a = Appearance.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.md),
      child: GlassCard(
        onTap: bookmarks.isEmpty
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BibleScreen()),
                )
            : null,
        padding: AppMetrics.cardPadding,
        child: Column(
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
                    framed: false,
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
                            builder: (_) =>
                                BibleReaderScreen(reference: label),
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
                                accent:
                                    AppColors.accent.withValues(alpha: 0.95),
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
        ),
      ),
    );
  }
}

class _SharedVersesSection extends StatelessWidget {
  const _SharedVersesSection();

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final refs = progress.sharedVerses.take(12).toList();
    final a = Appearance.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.md),
      child: GlassCard(
        padding: AppMetrics.cardPadding,
        child: Column(
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
                style: AppTypography.body(
                  size: 12,
                  color: a.textMuted(0.55),
                ),
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
        ),
      ),
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
        const SizedBox(width: AppSpace.sm),
        Expanded(
          child: _Seal(
            glyph: CinematicGlyph.flame,
            value: '$streak',
            label: 'Dias',
            accent: AppColors.streak,
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        Expanded(
          child: _Seal(
            glyph: CinematicGlyph.scroll,
            value: '$missions',
            label: 'Avanços',
            accent: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: AppSpace.sm),
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
      padding: const EdgeInsets.symmetric(
        vertical: AppSpace.md,
        horizontal: AppSpace.xs,
      ),
      child: Column(
        children: [
          CinematicIcon(glyph: glyph, size: 26, accent: accent, glowing: false),
          const SizedBox(height: AppSpace.xs),
          Text(
            value,
            style: AppTypography.title(
              size: 15,
              weight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.label(
              size: 9,
              letterSpacing: 0.4,
              color: a.textMuted(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
