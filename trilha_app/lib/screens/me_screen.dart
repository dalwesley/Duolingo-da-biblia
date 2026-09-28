import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/caravan_pilgrim_profile.dart';
import '../models/caravan_profile_prefs.dart';
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
import '../widgets/milestone_chests.dart';
import '../widgets/pilgrim_identity_card.dart';
import '../widgets/pilgrim_profile_sections.dart';
import '../widgets/profile_privacy.dart';
import '../widgets/portrait_picker_sheet.dart';
import '../widgets/profile_hero.dart';
import '../widgets/reflection_journal_card.dart';
import '../widgets/relic_panel.dart';
import '../widgets/recognition_history_sheet.dart';
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
            child: MeScreen(onBack: () => Navigator.pop(ctx)),
          ),
        ),
      ),
    ),
  );
}

/// Perfil / progresso — aberto pelo avatar na home.
class MeScreen extends StatefulWidget {
  final Widget? topBar;

  /// Com [onBack], o perfil abre com o topo cinematográfico ([ProfileHero])
  /// no lugar da barra + cartão de identidade.
  final VoidCallback? onBack;

  const MeScreen({super.key, this.topBar, this.onBack});

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

  /// Volta à trilha (home) — o perfil é aberto por cima do shell.
  void _backToTrail() =>
      Navigator.of(context).popUntil((route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final record = context.watch<CornerService>().record;
    final profile = _caravanProfile;
    final accuracy =
        profile?.accuracyPercent ??
        (progress.lifetimeQuestionsAnswered > 0
            ? ((progress.lifetimeQuestionsCorrect /
                          progress.lifetimeQuestionsAnswered) *
                      100)
                  .round()
                  .clamp(0, 100)
            : null);

    final hero = widget.onBack != null;
    String? epithet;
    Color? epithetColor;
    if (_overallRank > 0) {
      epithet = _overallRank <= 3
          ? pilgrimRankEpithet(_overallRank)
          : '$_overallRankº na caravana';
      if (_overallRank <= 3) epithetColor = pilgrimRankAccent(_overallRank);
    }
    final leaderDays =
        profile?.daysAsCaravanLeader ?? progress.daysAsCaravanLeader;
    if (leaderDays > 0) {
      final top = leaderDays == 1
          ? '1 dia no topo'
          : '$leaderDays dias no topo';
      epithet = epithet == null ? top : '$epithet · $top';
    }
    if (!record.isEmpty) {
      epithet = epithet == null ? record.line : '$epithet · ${record.line}';
    }

    Widget pad(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: child,
    );

    final body = <Widget>[
      if (hero)
        ProfileHero(
          name: progress.userName,
          photoUrl: backend.userPhotoUrl,
          seed: backend.uid,
          style: progress.settings.portraitStyle,
          onEditPortrait: () => showPortraitPickerSheet(context),
          onBack: widget.onBack,
          onSettings: () => openSettings(context),
          epithet: epithet,
          epithetColor: epithetColor,
          sinceLabel: ProfileHero.sinceFrom(
            progress.firstLessonDate ?? progress.firstOpenDate,
          ),
          steps: progress.steps,
          missions: progress.completedMissions.length,
          accuracyPercent: accuracy,
        )
      else
        pad(
          PilgrimIdentityCard(
            name: progress.userName,
            photoUrl: backend.userPhotoUrl,
            seed: backend.uid,
            style: progress.settings.portraitStyle,
            editable: true,
            onEditPortrait: () => showPortraitPickerSheet(context),
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
            leaderDays: leaderDays,
            recordLine: record.isEmpty ? null : record.line,
          ),
        ),
      const SizedBox(height: AppSpace.section),
      pad(
        ConstancyCard(
          playDates: progress.playDates,
          streak: progress.streak,
          goal: progress.settings.streakGoal,
        ),
      ),
      if (progress.hasOpenWeeklyQuests) ...[
        const SizedBox(height: AppSpace.md),
        pad(const WeeklyQuestsCard()),
      ],
    ];

    if (_caravanLoading) {
      body.addAll([const SizedBox(height: AppSpace.xl), const AppSpinner()]);
    } else if (profile != null) {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      body.addAll([
        const SizedBox(height: AppSpace.section),
        pad(
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
            collectionsFirst: true,
            showOwnerPrivacyBanner: false,
            onStartWalking: _backToTrail,
          ),
        ),
      ]);
    }

    body.addAll([
      const SizedBox(height: AppSpace.section),
      if (profile != null && !_caravanLoading)
        pad(const _NaPalavraBlock())
      else ...[
        pad(const _FavoritesSection()),
        pad(const _SharedVersesSection()),
      ],
      if (progress.missionReflections.isNotEmpty) ...[
        const SizedBox(height: AppSpace.md),
        pad(const ReflectionJournalCard()),
      ],
      const SizedBox(height: AppSpace.section),
      pad(const RecognitionHistoryCard()),
      const SizedBox(height: AppSpace.sm),
    ]);

    // Só no próprio perfil os cards mostram o olho de privacidade.
    if (hero || widget.topBar == null) {
      return ProfilePrivacyScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            0,
            hero ? 0 : AppSpace.lg,
            0,
            scrollPaddingBelowNav(context),
          ),
          children: body,
        ),
      );
    }

    final topInset = MediaQuery.viewPaddingOf(context).top + AppSpace.sm;
    return ProfilePrivacyScope(
      child: Column(
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
                0,
                AppSpace.afterTopBar,
                0,
                scrollPaddingBelowNav(context),
              ),
              children: body,
            ),
          ),
        ],
      ),
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
          const SizedBox(height: AppSpace.md),
          const _FavoritesSection(embedded: true),
          if (hasShared && hasBookmarks) ...[
            const SizedBox(height: AppSpace.md),
            const RelicHairline(accent: AppColors.cedar),
            const SizedBox(height: AppSpace.md),
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
    void openBible() => Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BibleScreen()));

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardHeader(
          label: 'Guardados',
          trailing: bookmarks.isEmpty
              ? null
              : CountBadge(
                  '${bookmarks.length}',
                  color: AppColors.cedar,
                  filled: false,
                ),
        ),
        const SizedBox(height: AppSpace.md),
        if (bookmarks.isEmpty) ...[
          Text(
            'Na Bíblia, toque num versículo e guarde no coração.',
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
          const SizedBox(height: AppSpace.md),
          GhostCta(
            label: 'Abrir a Bíblia',
            leading: CinematicGlyph.book,
            expanded: true,
            onTap: openBible,
          ),
        ] else
          ...bookmarks.asMap().entries.map((entry) {
            final i = entry.key;
            final label = _label(entry.value);
            return Column(
              children: [
                if (i > 0) const RelicHairline(accent: AppColors.cedar),
                Semantics(
                  button: true,
                  label: 'Abrir $label',
                  excludeSemantics: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    onTap: () => BibleReaderScreen.open(context, label),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: AppTypography.verse(
                                size: 16,
                                color: a.text,
                              ),
                            ),
                          ),
                          ListChevron(
                            color: AppColors.cedar.withValues(alpha: 0.8),
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

    if (widget.embedded) return content;

    return RelicPanel(accent: AppColors.cedar, child: content);
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
          label: 'Enviados',
          trailing: refs.isEmpty
              ? null
              : CountBadge(
                  '${refs.length}',
                  color: AppColors.cedar,
                  filled: false,
                ),
        ),
        const SizedBox(height: AppSpace.md),
        if (refs.isEmpty)
          Text(
            'Versículos que você compartilhar aparecem aqui — só a referência.',
            style: AppTypography.body(size: 13, color: a.textSecondary),
          )
        else
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              for (final ref in refs)
                Semantics(
                  button: true,
                  label: 'Abrir $ref',
                  excludeSemantics: true,
                  child: Material(
                    color: AppColors.cedar.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      side: BorderSide(
                        color: AppColors.cedar.withValues(alpha: 0.35),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => BibleReaderScreen.open(context, ref),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.md,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ref,
                                style: AppTypography.verse(
                                  size: 14,
                                  color: a.text,
                                ),
                              ),
                            ],
                          ),
                        ),
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
