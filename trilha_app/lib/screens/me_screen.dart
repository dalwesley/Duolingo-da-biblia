import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../models/bible_note.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/caravan_profile_prefs.dart';
import '../services/bible_service.dart';
import '../services/backend_service.dart';
import '../services/corner_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/remote_config_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/act_feel.dart';
import '../widgets/bible_note_tag.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/milestone_chests.dart';
import '../widgets/pilgrim_identity_card.dart';
import '../widgets/pilgrim_profile_sections.dart';
import '../widgets/profile_plus_cards.dart';
import '../widgets/profile_privacy.dart';
import '../widgets/portrait_picker_sheet.dart';
import '../widgets/profile_hero.dart';
import '../widgets/relic_panel.dart';
import '../widgets/top_bar.dart';
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
            frameChild: false,
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
    // Desafio fechado: o recorde não aparece no Perfil.
    final challengeOn = context.watch<RemoteConfigService>().challengeEnabled;
    final record = context.watch<CornerService>().record;
    final sub = context.watch<SubscriptionService>();
    final plusOpen = sub.plusFeaturesOpen;
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
          : context.l10n.profileMonthRank(_overallRank);
      if (_overallRank <= 3) epithetColor = pilgrimRankAccent(_overallRank);
    }
    final leaderDays =
        profile?.daysAsCaravanLeader ?? progress.daysAsCaravanLeader;
    if (leaderDays > 0) {
      final top = context.l10n.profileDaysOnTop(leaderDays);
      epithet = epithet == null ? top : '$epithet · $top';
    }
    if (challengeOn && !record.isEmpty) {
      epithet = epithet == null ? record.line : '$epithet · ${record.line}';
    }

    Widget pad(Widget child) => ContentFrame(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
        child: child,
      ),
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
          chromePinned: true,
          epithet: epithet,
          epithetColor: epithetColor,
          sinceLabel: ProfileHero.sinceFrom(
            progress.firstLessonDate ?? progress.firstOpenDate,
          ),
          supporter: sub.isSupporter,
          pilgrim: sub.hasPilgrimBadge,
          pioneer: sub.hasPioneerBadge,
          steps: progress.steps,
          missions: progress.completedMissions.length,
          accuracyPercent: accuracy,
        )
      else
        pad(
          PilgrimIdentityCard(
            name: progress.userName,
            supporter: sub.isSupporter,
            pilgrim: sub.hasPilgrimBadge,
            pioneer: sub.hasPioneerBadge,
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
            recordLine: !challengeOn || record.isEmpty ? null : record.line,
          ),
        ),
      const SizedBox(height: AppSpace.section),
      // Peregrino+: sequência semana a semana e acerto por modo/gesto.
      if (plusOpen) ...[
        pad(
          ConstancyCard(
            playDates: progress.playDates,
            streak: progress.streak,
            goal: progress.settings.streakGoal,
          ),
        ),
        const SizedBox(height: AppSpace.md),
        pad(const ProfileAccuracyCard()),
        const SizedBox(height: AppSpace.md),
        pad(const ExplainedErrorsCard()),
      ] else
        pad(const ProfilePlusTeaser()),
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
              // Escrituras e última cena repetem o cofre e "Suas trilhas".
              // Na caravana os dois continuam, para quem abre o perfil de outro.
              CaravanProfileSection.bible,
              CaravanProfileSection.lastMission,
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
    ]);

    // Só no próprio perfil os cards mostram o olho de privacidade.
    // Voltar fica preso; barra de aba sobe com o conteúdo.
    if (hero) {
      return ProfilePrivacyScope(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeroBar(
              onBack: widget.onBack,
              onSettings: () => openSettings(context),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  0,
                  0,
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

    final bottom = scrollPaddingBelowNav(context);
    if (widget.topBar == null || !topBarStaysFixed(widget.topBar)) {
      return ProfilePrivacyScope(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            0,
            widget.topBar == null
                ? AppSpace.lg
                : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
            0,
            bottom,
          ),
          children: [
            if (widget.topBar != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screen,
                ),
                child: widget.topBar!,
              ),
              const SizedBox(height: AppSpace.afterTopBar),
            ],
            ...body,
          ],
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
              padding: EdgeInsets.fromLTRB(0, AppSpace.afterTopBar, 0, bottom),
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
    final hasNotes = progress.parseNotes().isNotEmpty;

    return RelicPanel(
      accent: AppRoles.presence,
      glow: 0.35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelicChapter(
            title: context.l10n.profileInTheWord,
            accent: AppRoles.presence,
            whisper: hasBookmarks || hasShared || hasNotes
                ? null
                : context.l10n.profileInTheWordWhisper,
          ),
          const SizedBox(height: AppSpace.md),
          const _FavoritesSection(embedded: true),
          if (hasNotes) ...[
            const SizedBox(height: AppSpace.sm),
            const RelicHairline(),
            const SizedBox(height: AppSpace.sm),
            const _NotesSection(),
          ],
          if (hasShared && hasBookmarks) ...[
            const SizedBox(height: AppSpace.sm),
            const RelicHairline(),
            const SizedBox(height: AppSpace.sm),
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
  Map<String, String> _verseByKey = const {};
  String? _loadedKeys;
  bool _open = false;

  static String _key(({String abbrev, int chapter, int verse}) b) =>
      '${b.abbrev}:${b.chapter}:${b.verse}';

  void _schedule(List<({String abbrev, int chapter, int verse})> shown) {
    final stamp = shown.map(_key).join('|');
    if (stamp == _loadedKeys) return;
    _loadedKeys = stamp;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(shown, stamp));
  }

  Future<void> _load(
    List<({String abbrev, int chapter, int verse})> shown,
    String stamp,
  ) async {
    final books = await BibleService.instance.books();
    if (!mounted || stamp != _loadedKeys) return;
    final names = {for (final b in books) b.abbrev.toLowerCase(): b.name};
    final verses = <String, String>{};
    for (final b in shown) {
      final text = (await BibleService.instance.verseText(
        b.abbrev,
        b.chapter,
        b.verse,
      ))?.trim();
      if (text != null && text.isNotEmpty) verses[_key(b)] = text;
    }
    if (!mounted || stamp != _loadedKeys) return;
    setState(() {
      _namesByAbbrev = names;
      _verseByKey = verses;
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
    final all = progress.parseBookmarks();
    final shown = all.take(8).toList();
    if (_open) _schedule(shown);
    final a = Appearance.of(context);
    void openBible() => Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BibleScreen()));

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (all.isEmpty)
          CardHeader(label: context.l10n.profileSavedVerses)
        else
          _FoldHeader(
            label: context.l10n.profileSavedVerses,
            count: all.length,
            open: _open,
            onTap: () => setState(() => _open = !_open),
          ),
        if (shown.isEmpty) ...[
          const SizedBox(height: AppSpace.md),
          Text(
            context.l10n.profileSavedVersesEmpty,
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
          const SizedBox(height: AppSpace.md),
          GhostCta(
            label: context.l10n.profileOpenBible,
            leading: CinematicGlyph.book,
            expanded: true,
            onTap: openBible,
          ),
        ] else
          _FoldBody(
            open: _open,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < shown.length; i++) ...[
                  if (i > 0) const RelicHairline(),
                  _WordRow(
                    reference: _label(shown[i]),
                    verse: _verseByKey[_key(shown[i])],
                    onTap: () =>
                        BibleReaderScreen.open(context, _label(shown[i])),
                  ),
                ],
              ],
            ),
          ),
      ],
    );

    if (widget.embedded) return content;

    return RelicPanel(child: content);
  }
}

/// Anotações por tema — filtro pela cor (ex.: só as promessas).
class _NotesSection extends StatefulWidget {
  const _NotesSection();

  @override
  State<_NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<_NotesSection> {
  Map<String, String> _namesByAbbrev = const {};
  bool _open = false;
  bool _namesRequested = false;
  BibleNoteTag? _filter;

  Future<void> _loadNames() async {
    final books = await BibleService.instance.books();
    if (!mounted) return;
    setState(() {
      _namesByAbbrev = {for (final b in books) b.abbrev.toLowerCase(): b.name};
    });
  }

  String _label(String abbrev, int chapter, int verse) {
    final name = _namesByAbbrev[abbrev.toLowerCase()] ?? abbrev.toUpperCase();
    return '$name $chapter:$verse';
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<ProgressService>().parseNotes();
    if (_open && !_namesRequested) {
      _namesRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadNames());
    }
    final a = Appearance.of(context);
    final used = {for (final n in all) n.note.tag};
    final filter = used.contains(_filter) ? _filter : null;
    final shown = [
      for (final n in all)
        if (filter == null || n.note.tag == filter) n,
    ].take(20).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FoldHeader(
          label: context.l10n.profileNotes,
          count: all.length,
          open: _open,
          onTap: () => setState(() => _open = !_open),
        ),
        _FoldBody(
          open: _open,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (used.length > 1) ...[
                const SizedBox(height: AppSpace.sm),
                Wrap(
                  spacing: AppSpace.xs,
                  runSpacing: AppSpace.xs,
                  children: [
                    BibleNoteTagChip(
                      label: context.l10n.profileNotesAll,
                      color: null,
                      selected: filter == null,
                      ink: a.text,
                      idleFill: a.text.withValues(alpha: 0.04),
                      idleBorder: a.cardBorder,
                      onTap: () => setState(() => _filter = null),
                    ),
                    for (final t in BibleNoteTag.values)
                      if (used.contains(t))
                        BibleNoteTagChip(
                          label: bibleNoteTagLabel(context, t),
                          color: t.color,
                          selected: filter == t,
                          ink: a.text,
                          idleFill: a.text.withValues(alpha: 0.04),
                          idleBorder: a.cardBorder,
                          onTap: () {
                            ActHaptics.tap();
                            setState(() => _filter = t);
                          },
                        ),
                  ],
                ),
                const SizedBox(height: AppSpace.xs),
              ],
              for (var i = 0; i < shown.length; i++) ...[
                if (i > 0) const RelicHairline(),
                _NoteRow(
                  reference: _label(
                    shown[i].abbrev,
                    shown[i].chapter,
                    shown[i].verse,
                  ),
                  note: shown[i].note,
                  onTap: () => BibleReaderScreen.open(
                    context,
                    _label(shown[i].abbrev, shown[i].chapter, shown[i].verse),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NoteRow extends StatelessWidget {
  final String reference;
  final BibleNote note;
  final VoidCallback onTap;

  const _NoteRow({
    required this.reference,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tag = note.tag;
    final color = tag?.color ?? a.textFaint;
    return Semantics(
      button: true,
      label: context.l10n.profileOpenRef(reference),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: note.text.isEmpty ? 20 : 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [
                          reference,
                          if (tag != null) bibleNoteTagLabel(context, tag),
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w800,
                          color: a.textSecondary,
                        ),
                      ),
                      if (note.text.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          note.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 14,
                            height: 1.35,
                            color: a.text,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                ListChevron(color: a.textFaint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SharedVersesSection extends StatefulWidget {
  final bool embedded;

  const _SharedVersesSection({this.embedded = false});

  @override
  State<_SharedVersesSection> createState() => _SharedVersesSectionState();
}

class _SharedVersesSectionState extends State<_SharedVersesSection> {
  Map<String, String> _texts = const {};
  String? _loaded;
  bool _open = false;

  void _schedule(List<String> refs) {
    final stamp = refs.join('|');
    if (stamp == _loaded) return;
    _loaded = stamp;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(refs, stamp));
  }

  Future<void> _load(List<String> refs, String stamp) async {
    final texts = <String, String>{};
    for (final ref in refs) {
      final text = (await BibleService.instance.passageText(ref))?.trim();
      if (text != null && text.isNotEmpty) texts[ref] = text;
    }
    if (!mounted || stamp != _loaded) return;
    setState(() => _texts = texts);
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final all = progress.sharedVerses;
    final refs = all.take(12).toList();
    if (_open) _schedule(refs);
    final a = Appearance.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (all.isEmpty)
          CardHeader(label: context.l10n.profileSharedVerses)
        else
          _FoldHeader(
            label: context.l10n.profileSharedVerses,
            count: all.length,
            open: _open,
            onTap: () => setState(() => _open = !_open),
          ),
        if (refs.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.md),
            child: Text(
              context.l10n.profileSharedVersesEmpty,
              style: AppTypography.body(size: 13, color: a.textSecondary),
            ),
          )
        else
          _FoldBody(
            open: _open,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < refs.length; i++) ...[
                  if (i > 0) const RelicHairline(),
                  _WordRow(
                    reference: refs[i],
                    verse: _texts[refs[i]],
                    onTap: () => BibleReaderScreen.open(context, refs[i]),
                  ),
                ],
              ],
            ),
          ),
      ],
    );

    if (widget.embedded) return content;

    return RelicPanel(child: content);
  }
}

/// Título da lista: toque abre ou fecha. Fechado, só o nome e a contagem.
class _FoldHeader extends StatelessWidget {
  final String label;
  final int count;
  final bool open;
  final VoidCallback onTap;

  const _FoldHeader({
    required this.label,
    required this.count,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      expanded: open,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ActHaptics.tap();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              children: [
                Expanded(child: SectionLabel(label)),
                CountBadge('$count', filled: false, color: AppRoles.presence),
                const SizedBox(width: AppSpace.sm),
                AnimatedRotation(
                  turns: open ? 0.25 : 0,
                  duration: still ? Duration.zero : AppMotion.quick,
                  curve: AppMotion.enter,
                  child: ListChevron(color: a.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoldBody extends StatelessWidget {
  final bool open;
  final Widget child;

  const _FoldBody({required this.open, required this.child});

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return AnimatedSize(
      duration: still ? Duration.zero : AppMotion.standard,
      curve: open ? AppMotion.enter : AppMotion.exit,
      alignment: Alignment.topCenter,
      child: open
          ? Padding(
              padding: const EdgeInsets.only(top: AppSpace.sm),
              child: child,
            )
          : const SizedBox(width: double.infinity),
    );
  }
}

/// Referência em cima, o versículo embaixo. O toque abre a leitura.
class _WordRow extends StatelessWidget {
  final String reference;
  final String? verse;
  final VoidCallback onTap;

  const _WordRow({required this.reference, this.verse, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final quote = verse?.trim();
    final hasQuote = quote != null && quote.isNotEmpty;
    return Semantics(
      button: true,
      label: context.l10n.profileOpenRef(reference),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reference,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: hasQuote
                            ? AppTypography.body(
                                size: 12,
                                weight: FontWeight.w800,
                                color: a.textSecondary,
                              )
                            : AppTypography.verse(size: 16, color: a.text),
                      ),
                      if (hasQuote) ...[
                        const SizedBox(height: 2),
                        Text(
                          quote,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.verse(
                            size: 16,
                            height: 1.35,
                            color: a.text,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                ListChevron(color: a.textFaint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
