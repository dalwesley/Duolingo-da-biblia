import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../data/season_walk_catalog.dart';
import '../l10n/app_language.dart';
import '../models/season_walk.dart';
import '../models/trail.dart';
import '../widgets/act_feel.dart';
import '../services/analytics_service.dart';
import '../services/companion_service.dart';
import '../services/content_catalog_service.dart';
import '../services/corner_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/remote_config_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/plus_offers.dart';
import '../utils/liturgical_calendar.dart';
import '../utils/trail_progress.dart';
import '../utils/tomorrow_hook.dart';
import '../models/daily_quest.dart';
import '../widgets/app_sheet.dart';
import '../widgets/corner_board.dart';
import '../widgets/season_walk_together.dart';
import '../widgets/corner_home_card.dart';
import '../widgets/juntos_inbox.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/comeback_sheet.dart';
import '../widgets/daily_chest_sheet.dart';
import '../widgets/daily_quests_card.dart';
import '../widgets/hero_continue_card.dart';
import '../widgets/home_player_header.dart';
import '../widgets/home_word_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/offline_curriculum_dialog.dart';
import '../widgets/reminder_prompt_sheet.dart';
import '../widgets/shell_tab_scope.dart';
import '../widgets/streak_repair_banner.dart';
import '../widgets/season_challenge_banner.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/wave_hands_overlay.dart';
import '../widgets/plus_billing_banner.dart';
import '../widgets/plus_offer_sheet.dart';
import 'bible_screen.dart';
import 'memory_screen.dart';
import 'practice_screen.dart';
import 'weekly_review_screen.dart';
import 'season_walk_screen.dart';

/// Home — um único trabalho: a próxima cena.
class HomeScreen extends StatefulWidget {
  final TrailRepository repo;
  final void Function(String missionSlug) onOpenMission;
  final VoidCallback onOpenTrilhas;
  final VoidCallback? onOpenLeague;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenBible;

  const HomeScreen({
    super.key,
    required this.repo,
    required this.onOpenMission,
    required this.onOpenTrilhas,
    this.onOpenLeague,
    this.onOpenProfile,
    this.onOpenBible,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, ShellTabFreezeMixin {
  List<Trail>? _trails;
  late final AnimationController _fadeIn;
  bool _comebackChecked = false;
  bool _reminderChecked = false;
  bool _plusOfferChecked = false;
  bool _firstSceneChecked = false;
  bool _geloTeachChecked = false;
  bool _chestOfferPending = false;
  bool _retryingCatalog = false;
  bool _offlineDialogShown = false;

  @override
  void initState() {
    super.initState();
    _fadeIn = AnimationController(vsync: this, duration: AppMotion.slow)
      ..forward();
    _load();
  }

  @override
  void dispose() {
    _fadeIn.dispose();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (forceRefresh) {
      setState(() {
        _retryingCatalog = true;
        _trails = null;
      });
    }
    final trails = await widget.repo.getTrails(forceRefresh: forceRefresh);
    if (mounted) {
      setState(() {
        _trails = trails;
        _retryingCatalog = false;
      });
      AnalyticsService.instance.logHomeView();
      if (trails.isEmpty) {
        _maybeShowOfflineDialog();
      } else {
        _offlineDialogShown = false;
        final progress = context.read<ProgressService>();
        final hook = TomorrowHook.resolve(
          trails: trails,
          completed: progress.completedMissions,
          clearedTrailModes: progress.clearedTrailModes,
        );
        if (hook != null) {
          unawaited(() async {
            final hydrated = await hook.withReaderVerse();
            await progress.setNextScene(
              title: hydrated.title,
              tease: hydrated.trailer,
            );
          }());
          // Banco da trilha ativa em background — abrir cena não espera Firestore.
          final active = TrailProgress.findActiveTrail(
            trails,
            progress.completedMissions,
            clearedTrailModes: progress.clearedTrailModes,
          );
          if (active != null) {
            unawaited(
              ContentCatalogService.instance.ensureTrailBank(active.slug),
            );
          }
        }
      }
    }
  }

  void _maybeShowOfflineDialog() {
    if (_offlineDialogShown || !mounted) return;
    _offlineDialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || (_trails?.isNotEmpty ?? false)) return;
      final ok = await showOfflineCurriculumDialog(
        context,
        onRetry: () async {
          final trails = await widget.repo.getTrails(forceRefresh: true);
          if (mounted) {
            setState(() {
              _trails = trails;
              _retryingCatalog = false;
            });
          }
          return trails.isNotEmpty;
        },
      );
      if (!mounted) return;
      if (!ok) {
        // Permite reabrir o diálogo no próximo retry da card.
        _offlineDialogShown = false;
      }
    });
  }

  void _maybeShowComeback(ProgressService progress, {String? missionSlug}) {
    if (_comebackChecked) return;
    if (!progress.shouldShowComeback) {
      _comebackChecked = true;
      return;
    }
    _comebackChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showComebackSheet(
        context,
        onContinue: () {
          if (missionSlug != null) {
            widget.onOpenMission(missionSlug);
          } else {
            widget.onOpenTrilhas();
          }
        },
      );
    });
  }

  void _maybePromptReminders(ProgressService progress) {
    if (_reminderChecked) return;
    if (progress.notificationsPrompted) {
      _reminderChecked = true;
      return;
    }
    final first = progress.firstLessonDate;
    if (first == null || first.isEmpty) return;
    if (progress.shouldShowComeback) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (progress.notificationsPrompted) {
        _reminderChecked = true;
        return;
      }
      final route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) return;
      if (_reminderChecked) return;
      _reminderChecked = true;
      showReminderPromptSheet(context);
    });
  }

  /// Oferta do Peregrino+ (1×/semana, cada uma uma vez), só sem outra folha.
  void _maybeOfferPlus(ProgressService progress) {
    if (_plusOfferChecked) return;
    if (progress.shouldShowComeback || !progress.notificationsPrompted) return;
    _plusOfferChecked = true;
    final sub = context.read<SubscriptionService>();
    unawaited(() async {
      final state = await loadPlusOfferState();
      final week = LeagueService.weekKey();
      final kind = PlusOffers.pick(
        today: DateTime.now(),
        paid: sub.isPeregrinoPlus,
        storeReady: sub.canPurchase,
        scenesDone: progress.completedMissions.length,
        accountAgeDays: progress.accountAgeDays,
        promoUntil: sub.launchPromoDate,
        shown: state.shown,
        lastOfferWeek: state.lastWeek,
        thisWeek: week,
        plusEndedAt: sub.lastPlusEndedAt,
      );
      if (kind == null || !mounted) return;
      final route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) return;
      await showPlusOfferSheet(
        context,
        kind: kind,
        week: week,
        promoUntil: sub.launchPromoDate,
      );
    }());
  }

  /// Pós-onboarding: abre a 1ª cena sem esperar o toque no herói.
  void _maybeOpenFirstScene(ProgressService progress, String? missionSlug) {
    if (_firstSceneChecked) return;
    if (!progress.pendingOpenFirstScene) {
      _firstSceneChecked = true;
      return;
    }
    final slug = (missionSlug ?? '').trim();
    // Catálogo ainda carregando — tenta de novo no próximo frame.
    if (slug.isEmpty) return;
    if (!progress.takePendingOpenFirstScene()) {
      _firstSceneChecked = true;
      return;
    }
    _firstSceneChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) return;
      widget.onOpenMission(slug);
    });
  }

  void _maybeTeachGelo(ProgressService progress) {
    if (_geloTeachChecked) return;
    if (progress.shouldShowComeback) return;
    if (!progress.takePendingGeloTeach()) {
      _geloTeachChecked = true;
      return;
    }
    _geloTeachChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) return;
      showAppSheet<void>(
        context,
        builder: (ctx) {
          return AppSheetPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSheetHeader(
                  title: ctx.l10n.homeFreezeSheetTitle,
                  subtitle: ctx.l10n.homeFreezeSheetBody,
                  center: true,
                ),
                const SizedBox(height: AppSpace.xl),
                CopperCta(
                  label: ctx.l10n.commonGotIt,
                  onTap: () => Navigator.pop(ctx),
                  trailing: null,
                  dense: true,
                ),
                SizedBox(height: MediaQuery.viewPaddingOf(ctx).bottom),
              ],
            ),
          );
        },
      );
    });
  }

  /// O baú do dia chega sozinho (1×/dia) quando fica pronto, sem disputar
  /// a tela com outra folha; depois espera em "Mais para hoje".
  void _maybeOfferChest(ProgressService progress) {
    if (_chestOfferPending || !progress.dailyChestAvailable) return;
    if (progress.shouldShowComeback || !progress.notificationsPrompted) return;
    _chestOfferPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final route = mounted ? ModalRoute.of(context) : null;
      if (route == null || !route.isCurrent) {
        _chestOfferPending = false;
        return;
      }
      if (await takeDailyChestOffer() && mounted) {
        await showDailyChestSheet(context);
      }
      _chestOfferPending = false;
    });
  }

  void _openBible([String? reference]) {
    if ((reference == null || reference.isEmpty) &&
        widget.onOpenBible != null) {
      widget.onOpenBible!();
      return;
    }
    if (reference != null && reference.isNotEmpty) {
      BibleReaderScreen.open(context, reference);
      return;
    }
    final mode = context.read<ProgressService>().settings.appearanceMode;
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
              child: BibleScreen(
                topBar: TopBar(
                  inline: true,
                  immersive: true,
                  dark: appearance.onDark,
                  title: ctx.l10n.navBible,
                  subtitle: ctx.l10n.homeBibleOfflineSubtitle,
                  leadingGlyph: CinematicGlyph.book,
                  onBack: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openMemory() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MemoryScreen()));
  }

  /// Quests → ação certa (missão, Bíblia, memorizar).
  void _onQuestTap(DailyQuest quest, {String? missionSlug}) {
    switch (quest.id) {
      case 'mission':
      case 'accuracy':
      case 'perfect':
        if (missionSlug != null) {
          widget.onOpenMission(missionSlug);
        } else {
          widget.onOpenTrilhas();
        }
        return;
      case 'read':
      case 'bookmark':
        _openBible();
        return;
      case 'seasonal':
        _openBible(LiturgicalCalendar.momentFor().focusRef);
        return;
      case 'memory':
        _openMemory();
        return;
      default:
        if (missionSlug != null) {
          widget.onOpenMission(missionSlug);
        } else {
          widget.onOpenTrilhas();
        }
    }
  }

  Widget _reveal(int index, Widget child) {
    // Mesma árvore antes e depois da entrada: devolver o filho sem o
    // wrapper no fim remontava o card inteiro (estado e animações dele).
    // drive() não prende listener no controller (CurvedAnimation prenderia
    // um por build).
    final start = (0.1 * index).clamp(0.0, 0.65);
    final end = (start + 0.38).clamp(0.0, 1.0);
    final curve = _fadeIn.drive(
      CurveTween(curve: Interval(start, end, curve: AppMotion.enter)),
    );
    // Só fade+slide — ScaleTransition no 1º paint competia com o hero animado.
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: curve.drive(
          Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }

  void _openDesafioFace() {
    final corner = context.read<CornerService>().face;
    if (corner == null) return;
    _openCardSheet(
      CornerHomeCard(
        challenge: corner,
        onWalk: () {
          Navigator.of(context).pop();
          widget.onOpenMission(corner.missionSlug);
        },
      ),
    );
  }

  /// Cartões compactos de "Mais para hoje" — cada um abre o card completo
  /// numa folha (ou leva direto ao destino).
  List<_MoreTile> _moreToday(
    BuildContext context, {
    required ProgressService progress,
    required bool goalMet,
    required List<Trail> trails,
    required String? missionSlug,
  }) {
    final l10n = context.l10n;
    final a = Appearance.of(context);
    final juntos = JuntosInbox.pending(context);
    final mistakes = progress.mistakeQuestionIds.length;
    // Linhas com medida: cada uma mostra quanto falta, não só um rótulo.
    final questsTotal = DailyQuestDefs.all.length;
    final questsDone = goalMet ? DailyQuestsCard.doneCount(progress) : 0;
    final questsAllDone = questsDone >= questsTotal;
    final season = goalMet
        ? SeasonChallengeBanner.seasonVault(context, trails, progress: progress)
        : null;
    final seasonTrack = season?.tracks.first;
    final reviewScenes = progress.weeklyReviewReady
        ? progress
              .missionsCompletedInWeek(progress.weeklyReviewWeekKey())
              .length
        : 0;
    // Hierarquia da revisão (1 fluxo de revisão por dia): fechamento da
    // temporada pendente silencia a oferta da semana; qualquer revisão
    // feita hoje encerra as ofertas até amanhã.
    final now = DateTime.now();
    final campaign = SeasonWalkCatalog.current(now);
    final liturgy = LiturgicalCalendar.momentFor(now);
    String ymdOf(DateTime d) => d.toIso8601String().substring(0, 10);
    final seasonReviewPending = SeasonWalkAccess.weekReviewPending(
      campaign: campaign,
      today: now,
      isDayDone: (d) =>
          progress.isWalkDateDone(campaign.id, ymdOf(d.dateOn(campaign.start))),
      isReviewDone: (w) => progress.isSeasonReviewDone(campaign.id, w),
    );
    final weeklyReview =
        reviewScenes > 0 && !seasonReviewPending && !progress.isReviewDoneToday;
    // Caminhada coletiva antes do 1º dia; durante, o card da temporada
    // abaixo da missão já leva ao dia.
    final walkSoon =
        SeasonWalkTogetherCard.visibleOn(campaign, now) &&
        campaign.dayIndexOn(now) == null;
    final walkJoined = progress.hasJoinedWalk(campaign.id);
    final walkStartsIn = l10n.walkTogetherStartsIn(
      SeasonWalkTogetherCard.daysUntilStart(campaign, now),
    );
    final tiles = [
      if (walkSoon)
        _MoreTile(
          glyph: CinematicGlyph.path,
          title: campaign.title,
          caption: walkJoined
              ? '${l10n.walkTogetherJoined} · $walkStartsIn'
              : walkStartsIn,
          color: AppRoles.presence,
          hot: !walkJoined,
          onTap: () => _openCardSheet(const SeasonWalkTogetherCard()),
        ),
      if (weeklyReview)
        _MoreTile(
          glyph: CinematicGlyph.scroll,
          title: l10n.weeklyReviewTitle,
          caption: l10n.homeWeeklyReviewCaption(reviewScenes),
          color: a.chrome,
          hot: DateTime.now().weekday == DateTime.sunday,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const WeeklyReviewScreen())),
        ),
      if (progress.dailyChestAvailable)
        _MoreTile(
          glyph: CinematicGlyph.gem,
          title: l10n.chestDailyTitle,
          caption: l10n.chestReadyShort,
          color: AppRoles.presence,
          hot: true,
          onTap: () => showDailyChestSheet(context),
        ),
      if (juntos > 0)
        _MoreTile(
          glyph: CinematicGlyph.people,
          title: l10n.navTogether,
          caption: l10n.homeJuntosNews(juntos),
          color: a.chrome,
          hot: true,
          onTap: () => widget.onOpenLeague?.call(),
        ),
      if (goalMet)
        _MoreTile(
          glyph: CinematicGlyph.target,
          title: l10n.questDailyTitle,
          caption: questsAllDone ? l10n.questDone : l10n.homeQuestsExtraCaption,
          color: questsAllDone ? AppRoles.success : AppRoles.presence,
          badge: '$questsDone/$questsTotal',
          meter: questsDone / questsTotal,
          segments: questsTotal,
          onTap: () => _openCardSheet(
            DailyQuestsCard(
              onQuestTap: (q) {
                Navigator.of(context).pop();
                _onQuestTap(q, missionSlug: missionSlug);
              },
            ),
          ),
        ),
      if (goalMet)
        _MoreTile(
          glyph: CinematicGlyph.crown,
          title: season?.vault.title ?? l10n.seasonChallengeTitle,
          caption: seasonTrack == null
              ? l10n.seasonChallengeSeeProgress
              : seasonTrack.isComplete
              ? l10n.questDone
              : l10n.seasonChallengePathPercent(
                  (seasonTrack.progress * 100).round(),
                ),
          color: seasonTrack?.isComplete == true ? AppRoles.success : a.chrome,
          meter: seasonTrack == null
              ? null
              : seasonTrack.isComplete
              ? 1
              : seasonTrack.progress,
          meterColor: seasonTrack == null || seasonTrack.isComplete
              ? null
              : SeasonChallengeBanner.trackAccent(seasonTrack),
          onTap: () => _openCardSheet(SeasonChallengeBanner(catalog: trails)),
        ),
      // A fila de erros é grátis para todo mundo — inclusive assinante.
      // Uma revisão por vez: com a da semana na lista, os erros esperam.
      if (mistakes > 0 && !weeklyReview)
        _MoreTile(
          glyph: CinematicGlyph.refresh,
          title: l10n.homeReviewTitle,
          caption: l10n.homeReviewMistakesCaption(mistakes),
          color: a.chrome,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PracticeScreen())),
        ),
      // Estação do calendário cristão: sempre presente, abre a leitura dela.
      _MoreTile(
        glyph: CinematicGlyph.calendar,
        title: liturgy.title,
        caption: l10n.homeLiturgyReadCaption(liturgy.focusRef),
        color: LiturgicalCalendar.accentOf(liturgy.season),
        onTap: () => _openBible(liturgy.focusRef),
      ),
    ];
    // O que pede atenção sobe; o resto mantém a ordem acima.
    return [...tiles.where((t) => t.hot), ...tiles.where((t) => !t.hot)];
  }

  Future<void> _openCardSheet(Widget card) {
    // O card já é o painel (GlassCard próprio): sem AppSheetPanel, para não
    // empilhar card dentro de card — só a casca e a alça do design system.
    return showAppSheet<void>(
      context,
      builder: (context) {
        final bottom = MediaQuery.paddingOf(context).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Alça: mostra que a folha fecha arrastando para baixo.
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: SheetGrabber(),
              ),
              Flexible(child: SingleChildScrollView(child: card)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return freezeTab(() => _buildHome(context));
  }

  Widget _buildHome(BuildContext context) {
    final listen = tabListens;
    final progress = listen
        ? context.watch<ProgressService>()
        : context.read<ProgressService>();

    if (_trails == null) {
      return const _HomeSkeleton();
    }

    if (_trails!.isEmpty) {
      return _CatalogUnavailable(
        retrying: _retryingCatalog,
        onShowDialog: _maybeShowOfflineDialog,
      );
    }

    final trails = _trails!;
    final active = TrailProgress.findActiveTrail(
      trails,
      progress.completedMissions,
      clearedTrailModes: progress.clearedTrailModes,
    );
    final current = active != null
        ? TrailProgress.getCurrentMission(active, progress.completedMissions)
        : null;
    final goalMet = progress.dailyGoalMet;

    if (listen) {
      _maybeOpenFirstScene(progress, current?.slug);
      _maybeShowComeback(progress, missionSlug: current?.slug);
      _maybePromptReminders(progress);
      _maybeOfferPlus(progress);
      _maybeTeachGelo(progress);
      _maybeOfferChest(progress);
    }

    final nudge = listen
        ? context.watch<CompanionService>().incomingNudge
        : context.read<CompanionService>().incomingNudge;
    final challengeOn = listen
        ? context.watch<RemoteConfigService>().challengeEnabled
        : context.read<RemoteConfigService>().challengeEnabled;
    final cornerFace = !challengeOn
        ? null
        : listen
        ? context.watch<CornerService>().face
        : context.read<CornerService>().face;
    // Fundo = gradiente da fase do dia do shell (ImmersiveScaffold); a arte
    // da trilha vive só dentro do card herói. Cards comuns ficam neutros.
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final gutter = contentGutterOf(constraints.maxWidth);
            return ListView(
              padding: EdgeInsets.fromLTRB(
                0,
                MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
                0,
                scrollPaddingBelowNav(context),
              ),
              physics: const ClampingScrollPhysics(),
              children: [
                // Header: saudação + pulso do dia.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.screen,
                  ),
                  child: _reveal(
                    0,
                    HomePlayerHeader(
                      onProfileTap: widget.onOpenProfile,
                      onTapMission: goalMet
                          ? null
                          : current != null
                          ? () => widget.onOpenMission(current.slug)
                          : widget.onOpenTrilhas,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpace.screen + gutter,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpace.lg),
                      // CTA dominante: missão pronta.
                      _reveal(
                        1,
                        Column(
                          children: [
                            HeroContinueCard(
                              mission: current,
                              trailTitle: active?.title ?? '',
                              trailSlug: active?.slug ?? 'genesis-1-11',
                              trailColor: active?.color ?? '#1B3A5C',
                              onTap: current != null
                                  ? () => widget.onOpenMission(current.slug)
                                  : null,
                              onExploreTrails: widget.onOpenTrilhas,
                              goalMet: goalMet,
                              atRisk: progress.isStreakAtRisk,
                            ),
                            _WalkHomeCard(heroMissionSlug: current?.slug),
                          ],
                        ),
                      ),
                      if (cornerFace != null) ...[
                        const SizedBox(height: AppSpace.section),
                        _reveal(
                          2,
                          DesafioEntry(
                            onTap: () {
                              ActHaptics.tap();
                              _openDesafioFace();
                            },
                          ),
                        ),
                      ],
                      // Uma coisa só abaixo da missão: o reparo da sequência, se houver.
                      if (progress.showStreakRepairOffer) ...[
                        const SizedBox(height: AppSpace.section),
                        _reveal(2, const StreakRepairBanner()),
                      ],
                      // Cobrança do Peregrino+ falhou, venceu na graça ou
                      // acabou nesta semana: o banner decide se aparece
                      // (e carrega o próprio espaçamento — dispensar não
                      // deixa buraco na Home).
                      _reveal(2, const PlusBillingBanner()),
                      // O resto vive em "Mais para hoje" (abre em folha) e na aba
                      // Juntos — nada some, só deixa de disputar com a missão.
                      Builder(
                        builder: (context) {
                          final tiles = _moreToday(
                            context,
                            progress: progress,
                            goalMet: goalMet,
                            trails: trails,
                            missionSlug: current?.slug,
                          );
                          if (tiles.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpace.section,
                            ),
                            child: _reveal(3, _MoreToday(tiles: tiles)),
                          );
                        },
                      ),
                      if (current == null) ...[
                        const SizedBox(height: AppSpace.section),
                        _reveal(
                          4,
                          HomeWordCard(
                            mission: current,
                            onOpen: (ref) => _openBible(ref),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        WaveHandsOverlay(active: nudge != null),
      ],
    );
  }
}

class _CatalogUnavailable extends StatelessWidget {
  final bool retrying;
  final VoidCallback onShowDialog;

  const _CatalogUnavailable({
    required this.retrying,
    required this.onShowDialog,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen + contentGutterOf(MediaQuery.sizeOf(context).width),
        MediaQuery.viewPaddingOf(context).top + AppSpace.xxl,
        AppSpace.screen + contentGutterOf(MediaQuery.sizeOf(context).width),
        scrollPaddingBelowNav(context),
      ),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpace.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CloudMascot(
                face: retrying ? CloudFace.carregando : CloudFace.erro,
                size: 120,
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                context.l10n.homeCatalogEmptyTitle,
                textAlign: TextAlign.center,
                style: AppTypography.title(size: 18, color: a.text),
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                context.l10n.homeCatalogEmptyBody,
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 14, color: a.textSecondary),
              ),
              const SizedBox(height: AppSpace.xxl),
              CopperCta(
                label: retrying
                    ? context.l10n.homeCatalogDownloading
                    : context.l10n.commonTryAgain,
                onTap: retrying ? null : onShowDialog,
                showArrow: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Skeleton exibido enquanto o catálogo de trilhas carrega — espelha o layout
/// real da home para evitar tela preta na abertura.
class _HomeSkeleton extends StatefulWidget {
  const _HomeSkeleton();

  @override
  State<_HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<_HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen + contentGutterOf(MediaQuery.sizeOf(context).width),
        MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        AppSpace.screen + contentGutterOf(MediaQuery.sizeOf(context).width),
        scrollPaddingBelowNav(context),
      ),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Mesmas alturas do conteúdo real — sem pulo quando carrega.
        _ShimmerBox(
          controller: _shimmer,
          height: HeroContinueCard.homeHeaderReserve,
        ),
        const SizedBox(height: AppSpace.lg),
        SizedBox(
          height: HeroContinueCard.stageHeight(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: _ShimmerBox(
                  controller: _shimmer,
                  height: HeroContinueCard.stageHeight(context),
                  radius: AppMetrics.heroRadius,
                ),
              ),
              const CloudMascot(face: CloudFace.carregando, size: 112),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.section),
        _ShimmerBox(controller: _shimmer, height: 96),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final AnimationController controller;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.controller,
    required this.height,
    this.radius = AppMetrics.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final base = Color.lerp(a.cardFill, a.text, 0.03)!;
    final highlight = Color.lerp(a.cardFill, a.text, 0.1)!;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: a.cardBorder),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}

class _WalkHomeCard extends StatelessWidget {
  final String? heroMissionSlug;

  const _WalkHomeCard({this.heroMissionSlug});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final campaign = SeasonWalkCatalog.current(today);
    if (!campaign.contains(today)) return const SizedBox.shrink();
    final index = campaign.dayIndexOn(today);
    final day = index == null ? null : campaign.dayAt(index);
    final ymd =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    // Só o "feito hoje" — não reconstrói a cada resposta da cena.
    final done = context.select(
      (ProgressService p) =>
          day != null &&
          (p.isWalkDateDone(campaign.id, ymd) ||
              p.isMissionCompleted(day.missionSlug)),
    );
    final sameAsHero =
        day != null &&
        heroMissionSlug != null &&
        day.missionSlug == heroMissionSlug;

    final l10n = context.l10n;
    // A missão do hero já é o dia da Caminhada — não duplica o CTA.
    if (sameAsHero) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: TextCta(
          label: done
              ? l10n.homeSeasonDayOfDone(
                  index!,
                  campaign.length,
                  campaign.title,
                )
              : l10n.homeSeasonDayOf(index!, campaign.length, campaign.title),
          onTap: () => openSeasonWalk(context),
          color: a.textSecondary,
        ),
      );
    }

    // Toque no card inteiro (antes o InkWell ficava dentro do padding).
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: Semantics(
        button: true,
        label: day == null
            ? '${campaign.title}. ${campaign.subtitle}'
            : done
            ? l10n.homeSeasonChipDoneSemantics(
                campaign.title,
                index!,
                day.title,
              )
            : l10n.homeSeasonChipOpenSemantics(
                campaign.title,
                index!,
                day.title,
              ),
        excludeSemantics: true,
        child: GlassCard(
          padding: AppMetrics.cardPaddingCompact,
          onTap: () => openSeasonWalk(context),
          child: Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.calendar,
                size: AppMetrics.leadingIcon,
                accent: a.chrome,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 14, color: a.text),
                    ),
                    Text(
                      day == null
                          ? campaign.subtitle
                          : done
                          ? l10n.homeSeasonDayDone(index!, day.title)
                          : l10n.homeSeasonDayLine(index!, day.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 12,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              if (done)
                const CinematicIcon(
                  glyph: CinematicGlyph.check,
                  size: AppMetrics.iconMd,
                  accent: AppRoles.success,
                  framed: false,
                )
              else
                ListChevron(color: a.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreTile {
  final CinematicGlyph glyph;
  final String title;
  final String caption;
  final Color color;
  final bool hot;
  final VoidCallback onTap;

  /// Contagem à direita (ex.: "2/3", "12").
  final String? badge;

  /// Barra de progresso 0–1 sob a legenda; null = linha sem medida.
  final double? meter;

  /// > 1 divide a barra em gomos (tarefas contáveis); 0 = barra contínua.
  final int segments;

  /// Cor da barra quando difere do tom da linha (nível do desafio).
  final Color? meterColor;

  const _MoreTile({
    required this.glyph,
    required this.title,
    required this.caption,
    required this.color,
    required this.onTap,
    this.hot = false,
    this.badge,
    this.meter,
    this.segments = 0,
    this.meterColor,
  });
}

/// "Mais para hoje": um painel só, com linhas — lista de ações, não
/// mosaico de cartões soltos. O humor da trilha (borda da sequência) fica
/// no card da missão; aqui o painel é neutro para não disputar.
/// Mostra até [_visible] linhas; o resto abre em "Ver mais".
class _MoreToday extends StatefulWidget {
  final List<_MoreTile> tiles;

  const _MoreToday({required this.tiles});

  @override
  State<_MoreToday> createState() => _MoreTodayState();
}

class _MoreTodayState extends State<_MoreToday> {
  static const _visible = 3;
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    const radius = AppRadii.xl;
    final all = widget.tiles;
    final folds = all.length > _visible;
    final tiles = folds && !_open ? all.take(_visible).toList() : all;
    // Título dentro do painel: o rótulo e as linhas são um bloco só.
    return GlassCard(
      padding: EdgeInsets.zero,
      radius: radius,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedSize(
          duration: still ? Duration.zero : AppMotion.quick,
          curve: AppMotion.enter,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.lg,
                  AppSpace.lg,
                  AppSpace.lg,
                  0,
                ),
                child: Semantics(
                  header: true,
                  child: SectionLabel(context.l10n.homeMoreToday),
                ),
              ),
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0)
                  const ListDivider(
                    indent: ListDivider.iconIndent,
                    endIndent: AppSpace.lg,
                  ),
                _MoreTileRow(tile: tiles[i]),
              ],
              if (folds) ...[
                const ListDivider(endIndent: AppSpace.lg),
                _MoreFoldRow(
                  open: _open,
                  hidden: all.length - _visible,
                  onTap: () => setState(() => _open = !_open),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rodapé do painel: abre e fecha as linhas além das primeiras.
class _MoreFoldRow extends StatelessWidget {
  final bool open;
  final int hidden;
  final VoidCallback onTap;

  const _MoreFoldRow({
    required this.open,
    required this.hidden,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      expanded: open,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ActHaptics.tap();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                open ? l10n.homeMoreSeeLess : l10n.homeMoreSeeMore(hidden),
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: a.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpace.xs),
              AnimatedRotation(
                turns: open ? -0.25 : 0.25,
                duration: still ? Duration.zero : AppMotion.quick,
                curve: AppMotion.enter,
                child: ListChevron(color: a.textSecondary, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreTileRow extends StatefulWidget {
  final _MoreTile tile;

  const _MoreTileRow({required this.tile});

  @override
  State<_MoreTileRow> createState() => _MoreTileRowState();
}

class _MoreTileRowState extends State<_MoreTileRow> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tile = widget.tile;
    final tone = a.ink(tile.color);
    return Semantics(
      button: true,
      label: [
        tile.title,
        tile.caption,
        if (tile.badge != null) tile.badge!,
      ].join(', '),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () {
          ActHaptics.tap();
          tile.onTap();
        },
        child: AnimatedContainer(
          duration: AppMotion.quick,
          curve: AppMotion.enter,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.lg,
            vertical: AppSpace.lg,
          ),
          decoration: BoxDecoration(
            // Toda linha carrega um sopro da própria cor vindo do ícone;
            // com novidade o brilho dobra. Pressionar clareia a linha.
            gradient: LinearGradient(
              colors: [
                tone.withValues(alpha: tile.hot ? 0.14 : 0.06),
                tone.withValues(alpha: 0),
              ],
              stops: const [0, 0.6],
            ),
          ),
          foregroundDecoration: BoxDecoration(
            color: _pressed ? a.text.withValues(alpha: 0.06) : null,
          ),
          child: Row(
            children: [
              _MoreTileBadge(tile: tile, tone: tone),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tile.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 14, color: a.text),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tile.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 12,
                        weight: tile.hot ? FontWeight.w700 : FontWeight.w600,
                        color: tile.hot ? tone : a.textSecondary,
                      ),
                    ),
                    if (tile.meter != null) ...[
                      const SizedBox(height: AppSpace.sm),
                      _MoreTileMeter(
                        value: tile.meter!,
                        segments: tile.segments,
                        color: tile.meterColor != null
                            ? a.ink(tile.meterColor!)
                            : tone,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              if (tile.badge != null) ...[
                CountBadge(tile.badge!, color: tone),
                const SizedBox(width: AppSpace.sm),
              ],
              AnimatedSlide(
                duration: AppMotion.quick,
                offset: _pressed ? const Offset(0.15, 0) : Offset.zero,
                child: ListChevron(color: tile.hot ? tone : a.textFaint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Medida da linha: barra contínua ou em gomos (um por tarefa), fina para
/// não disputar com o título.
class _MoreTileMeter extends StatelessWidget {
  final double value;
  final int segments;
  final Color color;

  const _MoreTileMeter({
    required this.value,
    required this.segments,
    required this.color,
  });

  static const _height = 4.0;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    if (segments <= 1) {
      return AppProgressBar(value: value, color: color, height: _height);
    }
    final filled = (value.clamp(0.0, 1.0) * segments).round();
    return Row(
      children: [
        for (var i = 0; i < segments; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: AnimatedContainer(
              duration: AppMotion.quick,
              curve: AppMotion.enter,
              height: _height,
              decoration: BoxDecoration(
                color: i < filled ? color : a.progressTrack,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Ícone da linha: poço padrão de row ([AppMetrics.leadingIcon]) e, se
/// houver novidade, um ponto aceso no canto — como selo de notificação.
class _MoreTileBadge extends StatelessWidget {
  final _MoreTile tile;
  final Color tone;

  const _MoreTileBadge({required this.tile, required this.tone});

  @override
  Widget build(BuildContext context) {
    const size = AppMetrics.leadingIcon;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CinematicIcon(glyph: tile.glyph, size: size, accent: tile.color),
          if (tile.hot)
            Positioned(
              top: -3,
              right: -3,
              child: AlertDot(color: tone, size: 12, glow: true),
            ),
        ],
      ),
    );
  }
}
