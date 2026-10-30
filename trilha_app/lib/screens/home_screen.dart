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
import '../utils/plus_access.dart';
import '../utils/trail_progress.dart';
import '../utils/tomorrow_hook.dart';
import '../models/daily_quest.dart';
import '../widgets/app_sheet.dart';
import '../widgets/corner_board.dart';
import '../widgets/season_walk_feature_card.dart';
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
import '../widgets/next_step_card.dart';
import 'bible_screen.dart';
import 'memory_screen.dart';
import 'paywall_screen.dart';
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
        final plusOpen = context.read<SubscriptionService>().plusFeaturesOpen;
        final hook = TomorrowHook.resolve(
          trails: trails,
          completed: progress.completedMissions,
          clearedTrailModes: progress.clearedTrailModes,
          plusOpen: plusOpen,
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
            trailModes: progress.activeTrailModes,
            pinnedModes: progress.pinnedTrailDifficulties,
            borrowed: progress.borrowedMissions,
            plusOpen: plusOpen,
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

  /// Principal / secundária / presente — só quando há mais de uma das
  /// minhas no carrossel (uma só não precisa de rótulo).
  Map<String, String> _trailRoles(
    ProgressService progress,
    List<Trail> trails,
    List<Trail> shown,
  ) {
    final l10n = context.l10n;
    final mine = TrailProgress.myTrails(
      trails,
      progress.completedMissions,
      chosenAt: progress.trailChosenAt,
      seeded: progress.trailChoicesSeeded,
      clearedTrailModes: progress.clearedTrailModes,
      trailModes: progress.activeTrailModes,
      pinnedModes: progress.pinnedTrailDifficulties,
      completedOn: progress.missionCompletedOn,
      borrowed: progress.borrowedMissions,
    );
    final roles = <String, String>{};
    String? principal;
    for (final t in mine) {
      if (!shown.any((s) => s.slug == t.slug)) continue;
      if (PlusAccess.giftedTrails.contains(t.slug)) {
        roles[t.slug] = l10n.myTrailsGift;
      } else if (principal == null) {
        principal = t.slug;
        roles[t.slug] = l10n.myTrailsPrincipal;
      } else {
        roles[t.slug] = l10n.myTrailsSecondary;
      }
    }
    return roles.length > 1 ? roles : const {};
  }

  /// Quem já usava o app ganha Minhas trilhas a partir das trilhas que
  /// já tinha começado, na ordem do 1º dia jogado em cada uma.
  void _maybeSeedTrailChoices(ProgressService progress, List<Trail> trails) {
    if (progress.trailChoicesSeeded || progress.completedMissions.isEmpty) {
      return;
    }
    final order = TrailProgress.legacyChoices(
      trails,
      progress.completedMissions,
      clearedTrailModes: progress.clearedTrailModes,
      trailModes: progress.activeTrailModes,
      pinnedModes: progress.pinnedTrailDifficulties,
      completedOn: progress.missionCompletedOn,
      borrowed: progress.borrowedMissions,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(progress.seedTrailChoices(order));
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
        onSettled: () => Navigator.of(context).pop(),
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
    final now = progress.seasonToday;
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
    // Caminhada sazonal tem card próprio abaixo da missão — não entra aqui.
    final tiles = [
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
    final progress = context.read<ProgressService>();
    // Assina só o que muda o layout da Home. Header/hero/banners fazem
    // select próprio — sync de streak/cloud não reconstrói a ListView.
    if (listen) {
      context.select(
        (ProgressService p) => (
          completedLen: p.completedMissions.length,
          completedTail: p.completedMissions.isEmpty
              ? ''
              : p.completedMissions.last,
          clearedSig: Object.hashAll(
            p.clearedTrailModes.entries.map(
              (e) => Object.hash(e.key, e.value.length),
            ),
          ),
          goalMet: p.dailyGoalMet,
          atRisk: p.isStreakAtRisk,
          streakRepair: p.showStreakRepairOffer,
          pendingFirst: p.pendingOpenFirstScene,
          comeback: p.shouldShowComeback,
          notif: p.notificationsPrompted,
          chest: p.dailyChestAvailable,
          weeklyReview: p.weeklyReviewReady,
          reviewDoneToday: p.isReviewDoneToday,
          mistakes: p.mistakeQuestionIds.length,
          missionsToday: p.missionsToday,
          walkedToday: p.walkedToday,
          seasonWalk: SeasonWalkFeatureCard.visible(p),
        ),
      );
    }

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
    // Sem Plus, o herói não oferece cena que abre o paywall.
    final plusOpen = listen
        ? context.select((SubscriptionService s) => s.plusFeaturesOpen)
        : context.read<SubscriptionService>().plusFeaturesOpen;
    // Carrossel do herói: todas as trilhas com próxima cena agora; a 1ª é
    // a ativa (onde a pessoa está andando).
    // Sem Plus, uma trilha por vez no herói — não o catálogo inteiro em 0.
    final heroTrails = plusOpen
        ? TrailProgress.plusOpenTrails(
            trails,
            progress.completedMissions,
            chosenAt: progress.trailChosenAt,
            seeded: progress.trailChoicesSeeded,
            clearedTrailModes: progress.clearedTrailModes,
            trailModes: progress.activeTrailModes,
            pinnedModes: progress.pinnedTrailDifficulties,
            completedOn: progress.missionCompletedOn,
            borrowed: progress.borrowedMissions,
          )
        : TrailProgress.freeOpenTrails(
            trails,
            progress.completedMissions,
            chosenAt: progress.trailChosenAt,
            seeded: progress.trailChoicesSeeded,
            clearedTrailModes: progress.clearedTrailModes,
            trailModes: progress.activeTrailModes,
            pinnedModes: progress.pinnedTrailDifficulties,
            completedOn: progress.missionCompletedOn,
            borrowed: progress.borrowedMissions,
          );
    // Sem Plus, a trilha começada que parou no Plus vira o último card,
    // com cadeado: a vitrine nunca toma o lugar do que dá para andar.
    final plusTeasers = plusOpen || heroTrails.isEmpty
        ? const <Trail>[]
        : TrailProgress.plusTeaserTrails(
            trails,
            progress.completedMissions,
            clearedTrailModes: progress.clearedTrailModes,
            trailModes: progress.activeTrailModes,
            pinnedModes: progress.pinnedTrailDifficulties,
            completedOn: progress.missionCompletedOn,
            borrowed: progress.borrowedMissions,
          );
    final active = heroTrails.firstOrNull;
    final current = active != null
        ? TrailProgress.getCurrentMission(active, progress.completedMissions)
        : null;
    final goalMet = progress.dailyGoalMet;

    if (listen) {
      _maybeSeedTrailChoices(progress, trails);
      _maybeOpenFirstScene(progress, current?.slug);
      _maybeShowComeback(progress, missionSlug: current?.slug);
      _maybePromptReminders(progress);
      _maybeOfferPlus(progress);
      _maybeTeachGelo(progress);
      _maybeOfferChest(progress);
    }

    final nudge = listen
        ? context.select((CompanionService c) => c.incomingNudge)
        : context.read<CompanionService>().incomingNudge;
    final challengeOn = listen
        ? context.select((RemoteConfigService r) => r.challengeEnabled)
        : context.read<RemoteConfigService>().challengeEnabled;
    final cornerFace = !challengeOn
        ? null
        : listen
        ? context.select((CornerService c) => c.face)
        : context.read<CornerService>().face;
    // Fundo = céu do shell. A pintura da trilha vive só no card herói
    // (com gelo/poeira por cima).
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
                const SizedBox(height: AppSpace.lg),
                // CTA dominante: missão pronta. O carrossel vai de borda a
                // borda (os cards vizinhos entram de fora da tela); o resto
                // fica na coluna do conteúdo.
                _reveal(
                  1,
                  heroTrails.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpace.screen + gutter,
                          ),
                          child: HeroEndCard(
                            trails: trails,
                            plusOpen: plusOpen,
                            onOpenMission: widget.onOpenMission,
                            onExploreTrails: widget.onOpenTrilhas,
                          ),
                        )
                      : _HeroCarousel(
                          trails: [...heroTrails, ...plusTeasers],
                          plusLocked: {for (final t in plusTeasers) t.slug},
                          completed: progress.completedMissions,
                          roles: _trailRoles(progress, trails, heroTrails),
                          side: AppSpace.screen + gutter,
                          onOpenMission: widget.onOpenMission,
                          onExploreTrails: widget.onOpenTrilhas,
                          goalMet: goalMet,
                          atRisk: progress.isStreakAtRisk,
                        ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpace.screen + gutter,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Chip só quando a temporada já começou e o
                      // card destaque não está cobrindo o dia.
                      if (!SeasonWalkFeatureCard.visible(progress))
                        _reveal(
                          1,
                          _WalkHomeCard(heroMissionSlug: current?.slug),
                        ),
                      // Seu próximo passo: aprofundar ou reforçar (some
                      // sozinho quando não há o que sugerir).
                      _reveal(
                        2,
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpace.section),
                          child: NextStepCard(
                            trails: trails,
                            onOpenMission: widget.onOpenMission,
                          ),
                        ),
                      ),
                      if (SeasonWalkFeatureCard.visible(progress)) ...[
                        const SizedBox(height: AppSpace.section),
                        _reveal(2, const SeasonWalkFeatureCard()),
                      ],
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

/// Herói em carrossel: uma página por trilha com próxima cena. A ativa vem
/// primeiro; ao mudar a ativa (cena feita), o carrossel volta ao começo.
/// Vai de borda a borda: o card central fica alinhado à coluna do conteúdo
/// ([side]) e os vizinhos aparecem dos dois lados, cortados pela tela. Gira
/// sem fim (depois da última vem a primeira), então sempre há vizinho.
class _HeroCarousel extends StatefulWidget {
  final List<Trail> trails;

  /// Trilhas de vitrine: a próxima cena pede o Peregrino+.
  final Set<String> plusLocked;
  final List<String> completed;

  /// Papel de cada trilha em Minhas trilhas (principal, secundária,
  /// presente), ao lado do nome no card.
  final Map<String, String> roles;

  /// Margem lateral da coluna do conteúdo.
  final double side;
  final void Function(String missionSlug) onOpenMission;
  final VoidCallback? onExploreTrails;
  final bool goalMet;
  final bool atRisk;

  const _HeroCarousel({
    required this.trails,
    this.plusLocked = const {},
    required this.completed,
    this.roles = const {},
    required this.side,
    required this.onOpenMission,
    required this.onExploreTrails,
    required this.goalMet,
    required this.atRisk,
  });

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  static const _maxDots = 7;

  /// Espaço entre os cards.
  static const _gap = AppSpace.sm;

  /// O card central entra este tanto além da coluna, para o vizinho
  /// aparecer com folga dos dois lados.
  static const _peek = 10.0;

  /// Página inicial no meio de uma faixa longa: dá para voltar e avançar
  /// "sem fim" a partir da ativa.
  static const _loopBase = 10000;

  /// Passa sozinho a cada [_autoEvery]; depois de um toque ou arrasto,
  /// espera [_idleAfterTouch] antes de voltar a passar.
  static const _autoEvery = Duration(seconds: 6);
  static const _idleAfterTouch = Duration(seconds: 12);
  static const _autoSlide = Duration(milliseconds: 700);

  PageController? _controller;
  double _fraction = 1;
  int _page = 0;

  /// Página crua no PageView (sem o módulo): a do centro.
  int _raw = 0;
  Timer? _timer;
  DateTime _lastTouch = DateTime.fromMillisecondsSinceEpoch(0);
  bool _autoMoving = false;

  /// Lidos no build: aba visível (o shell desliga o TickerMode das abas
  /// escondidas e sob outra rota) e "reduzir movimento" do sistema.
  bool _visible = true;
  bool _reduceMotion = false;

  int get _count => widget.trails.length;

  /// Controller para a largura atual; recriado se a fração mudar (giro da
  /// tela) ou a lista mudar ([didUpdateWidget] o descarta).
  PageController _controllerFor(double fraction) {
    final current = _controller;
    if (current != null && fraction == _fraction) return current;
    current?.dispose();
    _fraction = fraction;
    _raw = _loopBase * _count + _page;
    return _controller = PageController(
      viewportFraction: fraction,
      initialPage: _raw,
    );
  }

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  void _syncTimer() {
    _timer?.cancel();
    _timer = _count > 1 ? Timer.periodic(_autoEvery, (_) => _advance()) : null;
  }

  void _advance() {
    final controller = _controller;
    if (!mounted || controller == null || !controller.hasClients) return;
    if (!_visible || _reduceMotion) return;
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    if (DateTime.now().difference(_lastTouch) < _idleAfterTouch) return;
    _autoMoving = true;
    controller
        .nextPage(duration: _autoSlide, curve: AppMotion.enter)
        .whenComplete(() => _autoMoving = false);
  }

  @override
  void didUpdateWidget(covariant _HeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final restart =
        oldWidget.trails.first.slug != widget.trails.first.slug ||
        oldWidget.trails.length != widget.trails.length;
    if (restart) {
      _controller?.dispose();
      _controller = null;
      _page = 0;
      _syncTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Widget _card(Trail trail) {
    final mission = TrailProgress.getCurrentMission(trail, widget.completed);
    final locked = widget.plusLocked.contains(trail.slug);
    return HeroContinueCard(
      mission: mission,
      trailTitle: switch (widget.roles[trail.slug]) {
        final role? => '${trail.localizedTitle} · $role',
        null => trail.localizedTitle,
      },
      trailSlug: trail.slug,
      trailColor: trail.color,
      plusLocked: locked,
      onTap: locked
          ? () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PaywallScreen(source: 'home_hero_plus'),
              ),
            )
          : mission != null
          ? () => widget.onOpenMission(mission.slug)
          : null,
      onExploreTrails: widget.onExploreTrails,
      goalMet: widget.goalMet,
      atRisk: widget.atRisk,
    );
  }

  @override
  Widget build(BuildContext context) {
    final trails = widget.trails;
    if (trails.length == 1) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.side),
        child: _card(trails.single),
      );
    }
    _visible = TickerMode.valuesOf(context).enabled;
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    final a = Appearance.of(context);
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            // Página = card (largura da coluna menos o respiro) + o vão.
            final card = width - 2 * (widget.side + _peek);
            final fraction = ((card + _gap) / width).clamp(0.5, 1.0);
            final controller = _controllerFor(fraction);
            return SizedBox(
              height: HeroContinueCard.stageHeight(context),
              child: Listener(
                onPointerDown: (_) => _lastTouch = DateTime.now(),
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (i) {
                    setState(() {
                      _raw = i;
                      _page = i % trails.length;
                    });
                    // Só a troca feita pela pessoa vibra e conta.
                    if (_autoMoving) return;
                    ActHaptics.tick();
                    AnalyticsService.instance.logEvent('home_hero_page', {
                      'trail': trails[_page].slug,
                      'index': _page,
                      'count': trails.length,
                    });
                  },
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _gap / 2),
                    child: _card(trails[i % trails.length]),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpace.sm),
        Semantics(
          label: context.l10n.homeCarouselPosition(_page + 1, trails.length),
          excludeSemantics: true,
          child: trails.length > _maxDots
              ? Text(
                  context.l10n.homeCarouselPosition(_page + 1, trails.length),
                  style: AppTypography.body(size: 12, color: a.textSecondary),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < trails.length; i++)
                      AnimatedContainer(
                        duration: AppMotion.quick,
                        curve: AppMotion.enter,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? a.text
                              : a.textSecondary.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
        ),
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
    final today = context.select((ProgressService p) => p.seasonToday);
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
