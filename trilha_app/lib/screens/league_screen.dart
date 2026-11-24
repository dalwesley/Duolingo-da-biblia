import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/season_walk_catalog.dart';
import '../services/content_catalog_service.dart';
import 'season_walk_screen.dart';
import '../models/season_walk.dart';
import '../l10n/app_language.dart';
import '../models/corner_challenge.dart';
import '../models/pilgrim_medal_models.dart';
import '../models/room_plan.dart';
import '../models/room_week.dart';
import '../models/study_room.dart';
import '../models/companion_invite.dart';
import '../models/walk_companion.dart';
import '../services/backend_service.dart';
import '../services/subscription_service.dart';
import '../services/medal_engagement_service.dart';
import '../services/moderation_service.dart';
import '../services/progress_service.dart';
import '../services/companion_service.dart';
import '../services/corner_service.dart';
import '../services/advent_prize_service.dart';
import '../services/invite_deep_link_service.dart';
import '../services/league_service.dart';
import '../services/remote_config_service.dart';
import '../services/room_service.dart';
import '../services/app_update_service.dart';
import '../theme/app_theme.dart';
import '../utils/guest_gate.dart';
import '../utils/juntos_invite_pace.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/content_filter.dart';
import '../widgets/juntos_stage.dart';
import '../widgets/profile_section.dart';
import '../widgets/act_feel.dart';
import '../widgets/anan_speech.dart';
import '../widgets/corner_board.dart';
import '../widgets/corner_pick_sheet.dart';
import '../widgets/corner_home_card.dart' show RaceDashes;
import '../widgets/juntos_chrome.dart';
import '../widgets/medal_art.dart';
import '../widgets/juntos_inbox.dart';
import '../widgets/juntos_invite_sheet.dart';
import '../widgets/caravan_goal_card.dart';
import '../widgets/postcard.dart' show showPostcardReveal;
import '../widgets/caravan_pilgrim_sheet.dart';
import '../widgets/accept_invite_sheet.dart';
import '../widgets/app_sheet.dart';
import '../widgets/room_pilot_cards.dart';
import '../widgets/room_plan_cards.dart';
import '../widgets/room_plan_editor.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/companion_call_sheet.dart';
import '../widgets/companion_formed_sheet.dart';
import '../widgets/companion_invite_confirm_sheet.dart';
import '../widgets/companion_nudge_sheet.dart';
import '../widgets/hero_card_atmosphere.dart';
import '../widgets/icon_well.dart';
import '../widgets/invite_qr_sheet.dart';
import '../widgets/shell_tab_scope.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/season_countdown.dart';
import '../widgets/season_walk_together.dart';
import '../widgets/trail_gift.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/user_avatar.dart';
import '../widgets/user_moderation_sheet.dart';
import '../models/recognition.dart';
import '../widgets/recognition_actions.dart';
import '../widgets/relic_panel.dart';
import '../widgets/room_roster.dart';
import '../widgets/room_panels.dart';
import 'bible_reader_screen.dart';
import 'coming_soon_screen.dart';
import 'lesson_screen.dart';
import 'room_reveal_screen.dart';

/// Altura comum quando CTA ouro e fantasma ficam lado a lado
/// (GhostCta tem mínimo de 48; o ouro denso, 44).
const double _pairedCtaHeight = 48;

class LeagueScreen extends StatefulWidget {
  final Widget? topBar;

  /// Quando a aba Juntos está visível — processa deep link pendente.
  final bool active;

  /// Sobe a cada toque em Juntos no menu. A aba volta para Caravana.
  final int caravanaVisit;

  final VoidCallback? onOpenOwnProfile;

  /// Abre uma missão (desafio do canto) e volta para a missão de hoje
  /// (chamado de companhia) — as novidades que saíram da Home.
  final ValueChanged<String>? onOpenMission;
  final VoidCallback? onGoToday;

  const LeagueScreen({
    super.key,
    this.topBar,
    this.active = true,
    this.caravanaVisit = 0,
    this.onOpenOwnProfile,
    this.onOpenMission,
    this.onGoToday,
  });

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen>
    with SingleTickerProviderStateMixin, ShellTabFreezeMixin {
  late final AnimationController _enter;
  List<LeagueEntry> _loadedOverallPlayers = const [];

  /// Placar sem quem eu bloqueei.
  List<LeagueEntry> get _overallPlayers =>
      _withoutBlocked(_loadedOverallPlayers);

  static List<LeagueEntry> _withoutBlocked(List<LeagueEntry> entries) {
    final moderation = ModerationService.instance;
    if (moderation.blocked.isEmpty) return entries;
    return [
      for (final e in entries)
        if (!moderation.isBlocked(e.uid)) e,
    ];
  }

  static const _tabCompanhia = 0;
  static const _tabCaravana = 1;
  static const _tabGrupos = 2;

  /// O trecho da Caravana (ver [CaravanWindow]), já como [LeagueEntry].
  ({
    List<LeagueEntry> top,
    List<LeagueEntry> above,
    List<LeagueEntry> below,
    List<LeagueEntry> online,
    int ahead,
    int total,
  })?
  _window;

  /// Meta coletiva do mês: cenas somadas e quem caminhou no mês passado.
  ({int scenes, int lastMonthWalkers})? _goal;

  static LeagueEntry _entryOf(CloudPlayer p) => LeagueEntry(
    uid: p.uid,
    name: p.name,
    steps: p.steps,
    lastWalkDate: p.lastWalkDate,
    lastSeenDate: p.lastSeenDate,
    photoUrl: p.photoUrl,
    portraitStyle: p.portraitStyle,
    weekSteps: p.weekSteps,
    dayStartSteps: p.dayStartSteps,
    plus: p.plus,
  );

  int _tab = _tabCaravana;
  int _companhiaPane = 0; // 0 = amizade, 1 = desafio
  bool _handlingInvite = false;
  bool _playersLoading = false;
  bool _playersLoadedOnce = false;
  String? _playersError;

  /// Convite aberto como visitante: pede a conta uma vez por tela.
  bool _guestInviteAsked = false;
  final Set<String> _inviteBusy = {};
  Future<void>? _settleInFlight;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: AppMotion.scene)
      ..forward();
    InviteDeepLinkService.instance.addListener(_onPendingInvite);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settle().then((_) => _afterSettle());
      if (widget.active) _consumePendingInvite();
    });
  }

  @override
  void didUpdateWidget(covariant LeagueScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.caravanaVisit != oldWidget.caravanaVisit) {
      _tab = _tabCaravana;
    }
    if (widget.active && !oldWidget.active) {
      _consumePendingInvite();
      // Recarrega ranking ao abrir a aba — evita lista vazia se o 1º fetch
      // rodou antes do backend estar pronto ou falhou em silêncio.
      _settle().then((_) => _afterSettle());
    }
  }

  bool _pitchOpen = false;

  /// Depois de carregar: primeiro o postal do mês que fechou (se houver),
  /// senão o convite.
  Future<void> _afterSettle() async {
    if (await _maybeRevealLastMonth()) return;
    await _maybeInvitePitch();
  }

  /// Meses já conferidos nesta sessão (não repete a leitura).
  static final _lastMonthChecked = <String>{};
  static const _keyCaravanMissed = 'caravanGoalMissedMonth';

  /// O mês virou com a meta batida: na próxima visita à Caravana, quem fez
  /// [LeagueService.goalMinScenes] cenas no mês que fechou ganha a
  /// revelação do postal (sem prazo). `true` quando revelou.
  Future<bool> _maybeRevealLastMonth() async {
    if (!mounted || !widget.active || _tab != _tabCaravana) return false;
    if (GuestGate.isGuest(context)) return false;
    final progress = context.read<ProgressService>();
    final backend = context.read<BackendService>();
    final prev = LeagueService.previousMonthKey(LeagueService.monthKey());
    if (progress.caravanPostcards.containsKey(prev)) return false;
    final mine = progress.monthScenesIn(prev);
    if (mine < LeagueService.goalMinScenes) return false;
    if (!_lastMonthChecked.add(prev)) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_keyCaravanMissed) == prev) return false;
      final goal = await backend
          .fetchCaravanGoal(month: prev)
          .timeout(const Duration(seconds: 10));
      if (goal == null) {
        _lastMonthChecked.remove(prev); // sem rede: tenta na próxima
        return false;
      }
      final done = math.max(goal.scenes, mine);
      if (done < LeagueService.monthSceneGoal(goal.lastMonthWalkers)) {
        await prefs.setString(_keyCaravanMissed, prev);
        return false;
      }
      if (!mounted || !widget.active) {
        _lastMonthChecked.remove(prev);
        return false;
      }
      await progress.saveCaravanPostcard(prev);
      if (!mounted) return true;
      await showPostcardReveal(
        context,
        CaravanPostcards.of(context, prev, scenes: done),
        eyebrow: context.l10n.caravanPostcardArrived,
      );
      return true;
    } catch (e) {
      _lastMonthChecked.remove(prev);
      debugPrint('Postal da Caravana do mês passado falhou: $e');
      return false;
    }
  }

  /// Folha de convite (Advento ou indicação), no ritmo de
  /// [JuntosInvitePace]. O botão abre o compartilhar externo que já existe
  /// (estação ou Caravana). Só com Companhia e grupos já lidos (para saber
  /// se a dupla/grupo do Advento já existe), sem convite chegando por link
  /// e sem outra tela por cima.
  Future<void> _maybeInvitePitch() async {
    if (!mounted || !widget.active || _handlingInvite || _pitchOpen) return;
    if (GuestGate.isGuest(context)) return;
    final links = InviteDeepLinkService.instance;
    if (links.pendingCompanionCode != null || links.pendingRoomCode != null) {
      return;
    }
    final companions = context.read<CompanionService>();
    final rooms = context.read<RoomService>();
    if (!companions.isLoaded || !rooms.isLoaded) return;
    final hasPartner = companions.companions.any((c) => !c.awaitingPartner);
    // Indicação só pelo convite que conta: Companhia (vaga livre ou convite
    // esperando) ou o grupo em que a pessoa está.
    final awaiting = companions.companions
        .where((c) => c.awaitingPartner)
        .firstOrNull;
    final companionOpen =
        context.read<RemoteConfigService>().companionEnabled &&
        (companions.canAdd || awaiting != null);
    final room = rooms.activeRoom;
    final via = companionOpen
        ? JuntosReferralVia.companion
        : room != null
        ? JuntosReferralVia.group
        : null;
    final adventDone =
        hasPartner || (rooms.activeRoom != null && rooms.isFormed);
    final advent = AdventPrizeService.instance.upcomingRoster();
    final now = DateTime.now();
    _pitchOpen = true;
    try {
      final kind = await JuntosInvitePace.load(
        now: now,
        rosterAt: advent?.rosterAt,
        adventDone: adventDone,
        canRefer: via != null,
      );
      if (kind == null || !mounted || !widget.active) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
      await JuntosInvitePace.markShown(now);
      if (!mounted) return;
      final choice = await showJuntosInviteSheet(
        context,
        kind: kind,
        advent: advent,
        via: via ?? JuntosReferralVia.companion,
      );
      if (!mounted) return;
      switch (choice) {
        case JuntosInviteChoice.later:
          await JuntosInvitePace.markDeclined(kind);
        case JuntosInviteChoice.share when kind == JuntosInviteKind.referral:
          // A folha de QR tem o Compartilhar (WhatsApp); compartilhar ou
          // copiar lá marca a indicação como feita.
          if (via == JuntosReferralVia.group && room != null) {
            setState(() => _tab = _tabGrupos);
            await _shareRoomInvite(context, room);
          } else {
            setState(() {
              _tab = _tabCompanhia;
              _companhiaPane = 0;
            });
            if (awaiting != null) {
              await _openCompanionInvite(context, awaiting);
            } else {
              await _createCompanion(context);
            }
          }
        case JuntosInviteChoice.share:
          await JuntosInvitePace.markActed(kind);
          if (!mounted) return;
          final campaign = advent == null
              ? null
              : SeasonWalkCatalog.all()
                    .where((c) => c.id == advent.campaignId)
                    .firstOrNull;
          if (campaign != null) {
            await shareSeasonWalkInvite(context, campaign);
          }
      }
    } finally {
      _pitchOpen = false;
    }
  }

  void _onPendingInvite() {
    if (!mounted || !widget.active) return;
    _consumePendingInvite();
  }

  Future<void> _consumePendingInvite() async {
    if (!mounted || _handlingInvite) return;
    final links = InviteDeepLinkService.instance;
    final rc = RemoteConfigService.instance;
    // Visitante com convite: o código fica guardado e a tela de salvar
    // abre; depois do login o convite segue (LoginScreen/Juntos o consomem).
    if (GuestGate.isGuest(context) &&
        (links.pendingCompanionCode != null || links.pendingRoomCode != null)) {
      if (_guestInviteAsked) return;
      _guestInviteAsked = true;
      await GuestGate.requireAccount(context, reason: 'invite');
      return;
    }
    // App aberto a frio pelo link (câmera do celular): o Remote Config ainda
    // não carregou e as flags leem `false`. Espera antes de decidir.
    if (links.pendingCompanionCode != null || links.pendingRoomCode != null) {
      _handlingInvite = true;
      try {
        await rc.ensureLoaded();
      } finally {
        _handlingInvite = false;
      }
      if (!mounted) return;
    }
    final roomCode = links.takePendingRoomCode();
    final roomsSvc = context.read<RoomService>();
    // Chave desligada: só abre o convite de um grupo do piloto.
    var roomClosed = false;
    if (roomCode != null && !roomsSvc.groupsOpen(rc.groupsEnabled)) {
      roomClosed = !await roomsSvc.isPilotRoom(roomCode);
      if (!mounted) return;
    }
    if (roomCode != null && roomClosed) {
      links.takeWantGruposTab();
      await openComingSoon(
        context,
        ComingSoonFeature.groups,
        source: 'invite_link',
      );
      return;
    }
    if (roomCode != null) {
      links.takeWantGruposTab();
      _handlingInvite = true;
      setState(() => _tab = _tabGrupos);
      try {
        await _joinRoomWithCode(context, roomCode);
      } finally {
        _handlingInvite = false;
      }
      return;
    }
    // Companhia fechada: o pedido de aba cai na Caravana; o painel resolve
    // para o Desafio se só ele estiver aberto.
    if (links.takeWantCompanhiaTab() &&
        (rc.companionEnabled || rc.challengeEnabled)) {
      setState(() {
        _tab = _tabCompanhia;
        _companhiaPane = 0;
      });
    }
    final code = links.takePendingCompanionCode();
    if (code == null) return;
    if (!rc.companionEnabled) {
      await openComingSoon(
        context,
        ComingSoonFeature.companion,
        source: 'invite_link',
      );
      return;
    }
    _handlingInvite = true;
    setState(() {
      _tab = _tabCompanhia;
      _companhiaPane = 0;
    });
    try {
      await _joinCompanionWithCode(context, code, confirm: true);
    } finally {
      _handlingInvite = false;
    }
  }

  Future<void> _settle() {
    return _settleInFlight ??= _settleBody().whenComplete(() {
      _settleInFlight = null;
    });
  }

  Future<void> _settleBody() async {
    if (!mounted) return;
    setState(() {
      _playersLoading = true;
      _playersError = null;
    });
    try {
      final progress = context.read<ProgressService>();
      final league = context.read<LeagueService>();
      final backend = context.read<BackendService>();
      final rooms = context.read<RoomService>();

      // Backend ainda inicializando — espera curto antes de decidir offline.
      final readyDeadline = DateTime.now().add(const Duration(seconds: 6));
      while (backend.isInitializing && DateTime.now().isBefore(readyDeadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
      }

      try {
        await backend
            .settleAndSyncLeague(progress, league, roomCode: rooms.activeCode)
            .timeout(const Duration(seconds: 12));
      } on TimeoutException {
        debugPrint('settleAndSyncLeague timeout — segue sem bloquear a UI');
      }

      if (!backend.isActive) {
        if (!mounted) return;
        setState(() {
          _playersLoading = false;
          _playersError =
              backend.lastError ?? context.l10n.juntosCaravanSignInLive;
        });
        return;
      }

      final loaded = await Future.wait([
        backend.fetchCaravanWindow(mySteps: progress.currentMonthSteps),
        backend.fetchCaravanGoal(),
      ]).timeout(const Duration(seconds: 12));
      final window = loaded[0] as CaravanWindow?;
      final goal = loaded[1] as ({int scenes, int lastMonthWalkers})?;
      if (window == null) throw Exception('Trecho da Caravana vazio');

      if (!mounted) return;
      setState(() {
        _window = (
          top: [for (final p in window.top) _entryOf(p)],
          above: [for (final p in window.above) _entryOf(p)],
          below: [for (final p in window.below) _entryOf(p)],
          online: [for (final p in window.online) _entryOf(p)],
          ahead: window.ahead,
          total: window.total,
        );
        if (goal != null) _goal = goal;
        // Todos que o trecho trouxe — para convites e para "quem é real".
        final seen = <String>{};
        _loadedOverallPlayers = [
          for (final p in [
            ...window.top,
            ...window.above,
            ...window.below,
            ...window.online,
          ])
            if (seen.add(p.uid)) _entryOf(p),
        ];
        _playersLoading = false;
        _playersLoadedOnce = true;
        _playersError = null;
      });

      // Salas/companhia não devem travar o spinner da Caravana.
      final companionSvc = context.read<CompanionService>();
      unawaited(_syncSideTabs(rooms, companionSvc, progress));
    } on TimeoutException catch (e) {
      debugPrint('Falha ao carregar caravana (timeout): $e');
      if (!mounted) return;
      setState(() {
        _playersLoading = false;
        _playersError = context.l10n.juntosCaravanTimeout;
      });
    } catch (e) {
      debugPrint('Falha ao carregar caravana: $e');
      if (!mounted) return;
      setState(() {
        _playersLoading = false;
        _playersError = context.l10n.juntosCaravanLoadError;
      });
    }
  }

  Future<void> _syncSideTabs(
    RoomService rooms,
    CompanionService companionSvc,
    ProgressService progress,
  ) async {
    try {
      await rooms.syncIfNeeded().timeout(const Duration(seconds: 10));
      await rooms.syncStudyDone(progress).timeout(const Duration(seconds: 10));
      await rooms.syncReading(progress).timeout(const Duration(seconds: 10));
      await rooms.syncPlan(progress).timeout(const Duration(seconds: 10));
      await rooms.syncSeals(progress).timeout(const Duration(seconds: 10));
      await rooms.syncGrowth(progress).timeout(const Duration(seconds: 10));
      await companionSvc.refresh().timeout(const Duration(seconds: 10));
      final result = await companionSvc
          .syncPresence(progress)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (result.weekTogetherBonusGranted) {
        showAppToastFor(
          context,
          message: context.l10n.juntosWeekTogetherBonus(
            WalkCompanion.weekTogetherBonusSteps,
          ),
          glyph: CinematicGlyph.people,
        );
      }
    } catch (e) {
      debugPrint('Falha ao sincronizar salas/companhia: $e');
    }
  }

  @override
  void dispose() {
    InviteDeepLinkService.instance.removeListener(_onPendingInvite);
    _enter.dispose();
    super.dispose();
  }

  Widget _reveal(int index, Widget child) {
    // Mesma árvore antes e depois da entrada: devolver o filho sem o
    // wrapper no fim remontava o card inteiro (estado e animações dele).
    // drive() não prende listener no controller (CurvedAnimation prenderia
    // um por build).
    final start = (0.08 * index).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final curve = _enter.drive(
      CurveTween(curve: Interval(start, end, curve: AppMotion.enter)),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: curve.drive(
          Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return freezeTab(() => _buildRoot(context));
  }

  Widget _buildRoot(BuildContext context) {
    final listen = tabListens;
    final companionNudge = listen
        ? context.watch<CompanionService>().incomingNudge
        : context.read<CompanionService>().incomingNudge;
    final companionInvites = context
        .read<CompanionService>()
        .incomingInvites
        .isNotEmpty;
    final cornerFace = listen
        ? context.watch<CornerService>().face
        : context.read<CornerService>().face;
    final roomIncoming = listen
        ? context.watch<RoomService>().incoming
        : context.read<RoomService>().incoming;
    final rc = listen
        ? context.watch<RemoteConfigService>()
        : context.read<RemoteConfigService>();
    // Piloto: o líder escolhido e quem está no grupo dele veem Grupos.
    final groupsOn =
        (listen ? context.watch<RoomService>() : context.read<RoomService>())
            .groupsOpen(rc.groupsEnabled);
    final companionOn = rc.companionEnabled;
    final challengeOn = rc.challengeEnabled;
    // A aba Companhia abre com a companhia ou com o desafio.
    final companhiaOn = companionOn || challengeOn;
    // Aba fechada mostra a vizinha aberta; a Caravana sempre abre.
    final tab = switch (_tab) {
      _tabGrupos when !groupsOn => companhiaOn ? _tabCompanhia : _tabCaravana,
      _tabCompanhia when !companhiaOn => _tabCaravana,
      _ => _tab,
    };
    return Stack(
      children: [
        RefreshIndicator(
          color: AppRoles.presence,
          onRefresh: _settle,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final gutter = contentGutterOf(constraints.maxWidth);
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  0,
                  widget.topBar == null
                      ? AppSpace.sm
                      : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
                  0,
                  scrollPaddingBelowNav(context),
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
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpace.screen + gutter,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _reveal(
                          0,
                          _SegmentTabs(
                            index: tab,
                            caravanAlert:
                                JuntosInbox.caravanPending(context) > 0,
                            companionAlert:
                                (companionOn &&
                                    (companionNudge != null ||
                                        companionInvites)) ||
                                (challengeOn && cornerFace != null),
                            gruposAlert: groupsOn && roomIncoming.isNotEmpty,
                            onChanged: (i) {
                              ActHaptics.tap();
                              // Aba fechada: aviso em tela inteira, a aba
                              // atual fica.
                              if (i == _tabGrupos && !groupsOn) {
                                openComingSoon(
                                  context,
                                  ComingSoonFeature.groups,
                                  source: 'tab',
                                );
                                return;
                              }
                              if (i == _tabCompanhia && !companhiaOn) {
                                openComingSoon(
                                  context,
                                  ComingSoonFeature.companion,
                                  source: 'tab',
                                );
                                return;
                              }
                              setState(() => _tab = i);
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpace.section),
                        // Troca de aba: um filho só — empilhar o anterior dobrava paint.
                        AnimatedSwitcher(
                          duration: AppMotion.standard,
                          switchInCurve: AppMotion.enter,
                          switchOutCurve: AppMotion.exit,
                          layoutBuilder: (current, _) =>
                              current ?? const SizedBox.shrink(),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.04, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            key: ValueKey(tab),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: switch (tab) {
                              _tabCompanhia => _buildCompanions(context),
                              _tabCaravana => [
                                const JuntosInbox(),
                                ..._buildLeague(context),
                              ],
                              _ => _buildRooms(context),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLeague(BuildContext context) {
    // Só o que a classificação mostra do próprio peregrino.
    context.select(
      (ProgressService p) => (
        p.userName,
        p.currentWeekSteps,
        p.currentMonthSteps,
        p.monthStartOfToday,
        p.lastPlayedDate,
        p.settings.portraitStyle,
      ),
    );
    final progress = context.read<ProgressService>();
    final league = context.watch<LeagueService>();
    // Bloquear alguém tira a pessoa do placar na hora.
    context.watch<ModerationService>();

    if (!league.isLoaded) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: AppSpace.xxxl + AppSpace.lg),
          child: AppSpinner(),
        ),
      ];
    }

    if (_playersLoading && !_playersLoadedOnce) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: AppSpace.xxxl + AppSpace.lg),
          child: AppSpinner(),
        ),
      ];
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    context.select((BackendService b) => (b.uid, b.userPhotoUrl));
    final backend = context.read<BackendService>();
    // A caminhada da estação (Advento) vive na Home, não aqui: a Caravana
    // fica com a etapa do mês e o ranking.
    final children = <Widget>[
      // A etapa do mês abre a Caravana; o cabeçalho do ranking vem logo
      // depois, colado na lista.
      if (_goal case final goal? when !GuestGate.isGuest(context)) ...[
        _reveal(
          1,
          CaravanGoalCard(
            scenes: goal.scenes,
            goal: LeagueService.monthSceneGoal(goal.lastMonthWalkers),
            myScenes: progress.currentMonthScenes,
          ),
        ),
        const SizedBox(height: AppSpace.md),
      ],
      _reveal(1, const _CaravanStageCard()),
      const SizedBox(height: AppSpace.md),
    ];

    final me = LeagueEntry(
      uid: backend.uid,
      name: progress.publicUserName,
      steps: progress.currentMonthSteps,
      isUser: true,
      lastWalkDate: progress.lastPlayedDate,
      lastSeenDate: today,
      photoUrl: backend.userPhotoUrl,
      portraitStyle: progress.settings.portraitStyle,
      weekSteps: progress.currentWeekSteps,
      dayStartSteps: progress.monthStartOfToday,
      plus: backend.myPlus,
    );
    final w = _window;
    final rows = w == null
        ? const <({LeagueEntry? entry, int rank})>[]
        : LeagueService.caravanWindow(
            me: me,
            top: _withoutBlocked(w.top),
            above: _withoutBlocked(w.above),
            below: _withoutBlocked(w.below),
            ahead: w.ahead,
            total: w.total,
            reach: LeagueService.reachSteps(
              monthSteps: progress.currentMonthSteps,
              monthScenes: progress.currentMonthScenes,
            ),
          );
    final peers = math.max(0, (w?.total ?? 0) - 1);
    final overallCompetitive = LeagueService.fieldIsCompetitive(peers);
    final userRank = w == null ? 0 : w.ahead + 1;
    if (userRank == 1 && overallCompetitive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        progress.recordLeaderDay();
      });
    }

    if (GuestGate.isGuest(context) &&
        context.read<BackendService>().isFirebaseReady) {
      children.add(_reveal(2, const _GuestJuntosCard(reason: 'caravan')));
      return children;
    }

    if (_playersError != null) {
      children.addAll([
        InlineNotice(
          message: _playersError!,
          busy: _playersLoading,
          onRetry: _settle,
        ),
        const SizedBox(height: AppSpace.md),
      ]);
    }

    if (!overallCompetitive && !_playersLoading) {
      children.add(_reveal(2, const _CaravanEmptyCard()));
    } else if (rows.isNotEmpty) {
      children.add(
        _reveal(
          2,
          _LeaderboardBoard(
            rows: rows,
            myRank: userRank,
            total: w?.total ?? rows.length,
            online: _withoutBlocked(w?.online ?? const []),
            me: me,
            onOpenOwnProfile: widget.onOpenOwnProfile,
            onSeeAll:
                (w?.total ?? 0) > rows.where((r) => r.entry != null).length
                ? () => _openWholeCaravan(context, me)
                : null,
          ),
        ),
      );
    }

    children.addAll([
      const SizedBox(height: AppSpace.md),
      CopperCta(
        label: context.l10n.juntosCaravanInviteCta,
        leading: CinematicGlyph.share,
        trailing: null,
        onTap: () => _shareCaravanInvite(context),
      ),
      if (context.watch<RemoteConfigService>().companionEnabled) ...[
        const SizedBox(height: AppSpace.sm),
        GhostCta(
          label: context.l10n.juntosOrInviteCompanion,
          leading: CinematicGlyph.link,
          expanded: true,
          onTap: () => setState(() {
            _tab = _tabCompanhia;
            _companhiaPane = 0;
          }),
        ),
      ],
    ]);

    return children;
  }

  List<Widget> _buildCompanions(BuildContext context) {
    final companions = context.watch<CompanionService>();
    final backend = context.watch<BackendService>();
    context.select((ProgressService p) => p.userName);
    final progress = context.read<ProgressService>();
    final corners = context.watch<CornerService>();
    final rc = context.watch<RemoteConfigService>();
    // Painel fechado cai no outro (a aba só abre com um dos dois aberto).
    var pane = _companhiaPane.clamp(0, 1);
    if (pane == 0 && !rc.companionEnabled) pane = 1;
    if (pane == 1 && !rc.challengeEnabled) pane = 0;

    final me = (
      name: progress.userName,
      photo: backend.userPhotoUrl,
      seed: backend.uid ?? progress.userName,
      style: progress.settings.portraitStyle,
      cover: profileCoverSceneOf(progress),
    );
    // Sem desafio aberto na semana: o palco convida, como na Companhia —
    // o placar e o histórico (se houver) ficam abaixo.
    final desafioEmpty =
        backend.isActive &&
        !(corners.loading && corners.mine.isEmpty) &&
        CornerScoreboard.of(corners.mine, backend.uid ?? '').open.isEmpty;

    Widget? stageBody;
    if (pane == 0 && companions.isLoaded && companions.companions.isEmpty) {
      stageBody = _CompanionEmptyStage(
        me: me,
        loading: companions.loading,
        onInvite: () => _createCompanion(context),
        onCall: () => _createAndCallCompanion(context),
        onJoin: () => _joinCompanion(context),
      );
    } else if (pane == 1) {
      if (desafioEmpty) {
        stageBody = _DesafioEmptyStage(
          me: me,
          onPick: () => _openCornerPick(context),
        );
      }
    }

    final list = <Widget>[
      _reveal(
        1,
        _CompanhiaStageCard(
          pane: pane,
          companionAlert:
              rc.companionEnabled &&
              (companions.incomingNudge != null ||
                  companions.incomingInvites.isNotEmpty),
          desafioAlert: rc.challengeEnabled && corners.face != null,
          onPaneChanged: (value) {
            final closed = value == 0
                ? (rc.companionEnabled ? null : ComingSoonFeature.companion)
                : (rc.challengeEnabled ? null : ComingSoonFeature.challenge);
            if (closed != null) {
              openComingSoon(context, closed, source: 'pane');
              return;
            }
            setState(() => _companhiaPane = value.clamp(0, 1));
          },
          body: stageBody,
        ),
      ),
      const SizedBox(height: AppSpace.md),
    ];

    if (pane == 1) {
      list.addAll(_desafioPane(context, pickInStage: desafioEmpty));
      return list;
    }

    if (!companions.isLoaded) {
      list.add(
        const Padding(
          padding: EdgeInsets.only(top: AppSpace.xxxl + AppSpace.lg),
          child: AppSpinner(),
        ),
      );
      return list;
    }

    if (GuestGate.isGuest(context) && backend.isFirebaseReady) {
      list.add(_reveal(2, const _GuestJuntosCard(reason: 'companion')));
      return list;
    }

    if (!backend.isActive) {
      list.add(
        _reveal(
          2,
          _CompanionsOfflineCard(
            error: backend.lastError,
            loading: backend.isInitializing,
            onRetry: () => backend.retry(),
          ),
        ),
      );
      return list;
    }

    final ordered = [...companions.companions]
      ..sort((a, b) {
        int score(WalkCompanion c) {
          if (c.hasIncomingNudge) return 0;
          if (c.waitingOnMe) return 1;
          if (c.theyAreDusty) return 2;
          if (c.awaitingPartner) return 3;
          if (c.bothWalkedToday) return 5;
          return 4;
        }

        return score(a).compareTo(score(b));
      });

    // Convite pelo nome: aparece primeiro, acima da própria companhia.
    for (final invite in companions.incomingInvites) {
      list.add(
        _reveal(
          2,
          CompanionIncomingInviteCard(
            invite: invite,
            onAccept: _inviteBusy.contains(invite.code)
                ? null
                : () => _acceptCompanionInvite(context, invite),
            onDecline: _inviteBusy.contains(invite.code)
                ? null
                : () => context.read<CompanionService>().declineInvite(invite),
          ),
        ),
      );
      list.add(const SizedBox(height: AppSpace.md));
    }

    if (companions.lastError != null) {
      list.add(
        InlineNotice(
          message: companions.lastError!,
          busy: companions.loading,
          onRetry: () => context.read<CompanionService>().refresh(),
        ),
      );
      list.add(const SizedBox(height: AppSpace.md));
    }

    // Vazio: o palco acima já traz o convite e as outras portas.
    if (companions.companions.isEmpty) return list;

    for (var i = 0; i < ordered.length; i++) {
      list.add(
        _reveal(
          (2 + i).clamp(0, 8),
          _CompanionCard(
            companion: ordered[i],
            myName: progress.publicUserName,
            calledName: companions.outgoingFor(ordered[i].code)?.toName,
            onCall: () => _openCompanionCall(context, ordered[i]),
            onShowQr: () => _openCompanionInvite(context, ordered[i]),
            onNudge: () => showCompanionNudgeSheet(
              context,
              companion: ordered[i],
              myName: progress.publicUserName,
            ),
            onLeave: () async {
              final ok = await _confirmLeaveCompanion(context);
              if (ok == true && context.mounted) {
                await context.read<CompanionService>().leave(
                  ordered[i].code,
                  progress: progress,
                );
              }
            },
          ),
        ),
      );
      list.add(const SizedBox(height: AppSpace.md));
    }

    list.add(const SizedBox(height: AppSpace.sm));
    if (companions.canAdd) {
      list.add(
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: _pairedCtaHeight,
                child: CopperCta(
                  label: context.l10n.juntosInviteShort,
                  leading: CinematicGlyph.people,
                  trailing: null,
                  dense: true,
                  onTap: companions.loading
                      ? null
                      : () => _createCompanion(context),
                ),
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: GhostCta(
                label: context.l10n.juntosHaveCode,
                leading: CinematicGlyph.qr,
                onTap: companions.loading
                    ? null
                    : () => _joinCompanion(context),
              ),
            ),
          ],
        ),
      );
    }

    // Ação destrutiva por último, discreta — não compete com convidar.
    if (companions.companions.length > 1) {
      list.add(const SizedBox(height: AppSpace.md));
      list.add(
        Center(
          child: TextCta(
            label: context.l10n.juntosLeaveAllCompanionsCta,
            danger: true,
            onTap: companions.loading
                ? null
                : () async {
                    final ok = await _confirmLeaveAllCompanions(
                      context,
                      companions.companions.length,
                    );
                    if (ok == true && context.mounted) {
                      await context.read<CompanionService>().leaveAll(
                        progress: progress,
                      );
                    }
                  },
          ),
        ),
      );
    }
    return list;
  }

  /// Desafio sob Companhia — mesmo padrão da Amizade: stage → cards → CTA.
  List<Widget> _desafioPane(BuildContext context, {bool pickInStage = false}) {
    return [
      CornerBoard(
        showEmpty: false,
        onOpenMission: widget.onOpenMission ?? (_) {},
        onOpenCaravana: () => setState(() => _tab = _tabCaravana),
      ),
      // Vazio: a ação já mora no palco acima.
      if (!pickInStage) ...[
        const SizedBox(height: AppSpace.md),
        CopperCta(
          label: CornerCopy.boardPickCta,
          leading: CinematicGlyph.flag,
          trailing: null,
          onTap: () => _openCornerPick(context),
        ),
      ],
    ];
  }

  /// Escolher quem desafiar — fora da nuvem ou com desafio na semana, avisa.
  void _openCornerPick(BuildContext context) {
    final backend = context.read<BackendService>();
    final corners = context.read<CornerService>();
    final blocked = !backend.isActive
        ? CornerCopy.needsCloud
        : corners.isBusy()
        ? CornerCopy.busyWeek
        : null;
    if (blocked != null) {
      showAppToastFor(
        context,
        message: blocked,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    showCornerPickSheet(context, people: _caravanPeople(backend.uid));
  }

  Future<void> _shareCaravanInvite(BuildContext context) async {
    final name = context.read<ProgressService>().realUserName;
    final l10n = context.l10n;
    final who = name.isEmpty ? l10n.juntosSomeone : name;
    final store = AppUpdateService.androidStoreUrl;
    await SharePlus.instance.share(
      ShareParams(
        text: l10n.juntosCaravanShareText(who, store),
        subject: l10n.juntosCaravanShareSubject,
      ),
    );
  }

  /// Lista da Caravana para chamar pelo nome o convite aberto.
  void _openCompanionCall(BuildContext context, WalkCompanion invite) {
    final uid = context.read<BackendService>().uid;
    showCompanionCallSheet(
      context,
      code: invite.code,
      people: _caravanPeople(uid),
      onShareLink: () => _openCompanionInvite(context, invite),
    );
  }

  /// Sem companhia: abre o convite e já mostra a lista para chamar.
  Future<void> _createAndCallCompanion(BuildContext context) async {
    final service = context.read<CompanionService>();
    final created = await service.createInvite(
      context.read<ProgressService>(),
      withTrailGift: context.read<SubscriptionService>().canShareTrailGift,
    );
    if (!context.mounted) return;
    if (created == null) {
      showAppToastFor(
        context,
        message: service.lastError ?? context.l10n.juntosCreateInviteError,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    _openCompanionCall(context, created);
  }

  Future<void> _acceptCompanionInvite(
    BuildContext context,
    CompanionInvite invite,
  ) async {
    if (_inviteBusy.contains(invite.code)) return;
    setState(() => _inviteBusy.add(invite.code));
    final service = context.read<CompanionService>();
    final bool ok;
    try {
      ok = await service.acceptInvite(invite, context.read<ProgressService>());
    } finally {
      if (mounted) setState(() => _inviteBusy.remove(invite.code));
    }
    if (!context.mounted) return;
    if (!ok) {
      showAppToastFor(
        context,
        message: service.lastError ?? context.l10n.juntosJoinError,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    await showCompanionFormedSheet(context, partnerName: invite.fromName);
  }

  /// Convite aberto: atualiza antes de mostrar — se alguém já entrou pelo
  /// código, celebra a companhia em vez de oferecer o convite de novo.
  Future<void> _openCompanionInvite(
    BuildContext context,
    WalkCompanion invite,
  ) async {
    final service = context.read<CompanionService>();
    final progress = context.read<ProgressService>();
    await service.refresh();
    if (!context.mounted) return;
    final live = service.companions
        .where((c) => c.code == invite.code)
        .firstOrNull;
    // Convite sumiu (cancelado do outro lado): a lista já se atualizou.
    if (live == null) return;
    if (!live.awaitingPartner) {
      await showCompanionFormedSheet(context, partnerName: live.displayName);
      return;
    }
    await showInviteQrSheet(
      context,
      code: live.code,
      inviterName: progress.publicUserName,
      trailGift: live.giftCode != null,
    );
  }

  Future<void> _createCompanion(BuildContext context) async {
    final progress = context.read<ProgressService>();
    final service = context.read<CompanionService>();
    final created = await service.createInvite(
      progress,
      withTrailGift: context.read<SubscriptionService>().canShareTrailGift,
    );
    if (!context.mounted) return;
    if (created == null) {
      showAppToastFor(
        context,
        message: service.lastError ?? context.l10n.juntosCreateInviteError,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    await Clipboard.setData(
      ClipboardData(text: InviteDeepLinkService.companionUri(created.code)),
    );
    if (!context.mounted) return;
    await showInviteQrSheet(
      context,
      code: created.code,
      inviterName: progress.publicUserName,
      trailGift: created.giftCode != null,
    );
  }

  Future<void> _joinCompanion(BuildContext context) async {
    final code = await showAcceptInviteSheet(context);
    if (code == null || code.isEmpty || !context.mounted) return;
    await _joinCompanionWithCode(context, code, confirm: false);
  }

  Future<void> _joinCompanionWithCode(
    BuildContext context,
    String code, {
    required bool confirm,
  }) async {
    if (confirm) {
      final ok = await showCompanionInviteConfirmSheet(context, code: code);
      if (!ok || !context.mounted) return;
    }
    final service = context.read<CompanionService>();
    final joinedOk = await service.joinWithCode(
      code,
      context.read<ProgressService>(),
    );
    if (!context.mounted) return;
    if (!joinedOk) {
      showAppToastFor(
        context,
        message: service.lastError ?? context.l10n.juntosJoinError,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    WalkCompanion? joined;
    for (final c in service.companions) {
      if (c.code.toUpperCase() == code.trim().toUpperCase()) {
        joined = c;
        break;
      }
    }
    await showCompanionFormedSheet(context, partnerName: joined?.displayName);
    if (!context.mounted) return;
    // Quem chamou tem o Plus: o convite trouxe uma trilha à escolha.
    final giftCode = await context.read<BackendService>().companionGiftCode(
      code.trim().toUpperCase(),
    );
    if (giftCode == null || !context.mounted) return;
    await redeemTrailGiftLink(context, giftCode);
  }

  Future<bool> _confirmLeaveAllCompanions(BuildContext context, int count) {
    return showAppConfirm(
      context,
      danger: true,
      title: context.l10n.juntosLeaveAllCompanionsTitle,
      body: context.l10n.juntosLeaveAllCompanionsBody(count),
      cancelLabel: context.l10n.commonCancel,
      confirmLabel: context.l10n.juntosLeaveAllConfirm,
    );
  }

  Future<bool> _confirmLeaveCompanion(BuildContext context) {
    return showAppConfirm(
      context,
      danger: true,
      title: context.l10n.juntosLeaveCompanionTitle,
      body: context.l10n.juntosLeaveCompanionBody,
      cancelLabel: context.l10n.commonCancel,
      confirmLabel: context.l10n.juntosLeaveConfirm,
    );
  }

  List<Widget> _buildRooms(BuildContext context) {
    final rooms = context.watch<RoomService>();
    final backend = context.watch<BackendService>();
    context.select((ProgressService p) => (p.userName, p.walkedToday));
    final progress = context.read<ProgressService>();

    if (!rooms.isLoaded) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: AppSpace.xxxl + AppSpace.lg),
          child: AppSpinner(),
        ),
      ];
    }

    if (GuestGate.isGuest(context) && backend.isFirebaseReady) {
      return [_reveal(1, const _GuestJuntosCard(reason: 'groups'))];
    }

    if (!backend.isActive) {
      return [
        _reveal(
          1,
          _RoomsOfflineCard(
            error: backend.lastError,
            loading: backend.isInitializing,
            onRetry: () => backend.retry(),
          ),
        ),
      ];
    }

    final incoming = rooms.incoming;

    // Sala salva que não abriu: sem "criar/entrar" — trocaria de grupo.
    if (!rooms.hasRoom && rooms.loadFailed) {
      return [
        _reveal(
          1,
          InlineNotice(
            message: rooms.lastError ?? context.l10n.roomErrorLoad,
            busy: rooms.loading,
            onRetry: () => context.read<RoomService>().syncIfNeeded(),
          ),
        ),
      ];
    }

    if (!rooms.hasRoom) {
      final closed = rooms.closedRoom;
      return [
        if (closed != null) ...[
          _reveal(1, _ClosedRoomNotice(room: closed, myUid: backend.uid)),
          const SizedBox(height: AppSpace.md),
        ],
        for (final invite in incoming) ...[
          _reveal(1, _incomingInviteCard(context, invite)),
          const SizedBox(height: AppSpace.md),
        ],
        _reveal(
          1,
          _RoomsEmptyState(
            loading: rooms.loading,
            error: closed != null ? null : rooms.lastError,
            onCreate: () => _showCreateRoom(context),
            onJoin: () => _showJoinRoom(context),
          ),
        ),
      ];
    }

    final room = rooms.activeRoom!;
    final members = rooms.members;
    void shareRoom() => _shareRoomInvite(context, room);
    void callPeople() => showRoomCallSheet(
      context,
      people: [
        for (final person in _caravanPeople(backend.uid))
          if (!members.any((m) => m.uid == person.uid)) person,
      ],
      onInvite: (person) => _inviteCaravanPerson(context, person),
      onCancel: (person) => _cancelRoomInvite(context, person),
      onShareLink: shareRoom,
    );

    final isLeader = room.isOwner(backend.uid);
    // Grupo com menos de 3 pessoas ainda está se formando: só pessoas,
    // convite e saída. Dupla vai para a Companhia.
    if (!rooms.isFormed && !(rooms.loading && members.isEmpty)) {
      return _buildFormingRoom(
        context,
        rooms: rooms,
        backend: backend,
        progress: progress,
        room: room,
        isLeader: isLeader,
        incoming: incoming,
        callPeople: callPeople,
      );
    }
    if (room.plan != null) {
      return _buildPlanRoom(
        context,
        rooms: rooms,
        backend: backend,
        progress: progress,
        room: room,
        plan: room.plan!,
        isLeader: isLeader,
        incoming: incoming,
        callPeople: callPeople,
      );
    }
    final study = rooms.currentStudy;
    final reading = rooms.currentReading;
    final me = members.where((m) => m.isUser).firstOrNull;
    final unseen = rooms.unseenClosing;
    final closedThisWeek = rooms.latestClosing?.week == LeagueService.weekKey();
    // Estudo/leitura da semana marcados antes do propósito: a semana antiga
    // segue até acabar (acompanhamento e fechar ainda valem).
    final weeklyContent = study != null || reading != null;

    return [
      for (final invite in incoming) ...[
        _reveal(1, _incomingInviteCard(context, invite)),
        const SizedBox(height: AppSpace.md),
      ],
      // Herói: sem propósito, o convite para criar (trilha, livro e datas
      // são escolhidos dentro dele). Estudo da semana antigo ainda aparece
      // até a semana acabar.
      _reveal(
        2,
        study == null
            ? RoomPlanEmptyCard(
                room: room,
                isLeader: isLeader,
                onCreate: () => _editRoomPlan(context),
                header: _RoomTitle(
                  room: room,
                  isOwner: isLeader,
                  onMenu: () => _openRoomMenu(context),
                ),
              )
            : RoomStudyCard(
                room: room,
                study: study,
                members: members,
                isLeader: isLeader,
                onPick: () => _editRoomPlan(context),
                onOpen: () => _openRoomStudy(context, study),
                header: _RoomTitle(
                  room: room,
                  isOwner: isLeader,
                  onMenu: () => _openRoomMenu(context),
                ),
              ),
      ),
      if (unseen != null && !isLeader) ...[
        const SizedBox(height: AppSpace.md),
        _reveal(
          2,
          RoomClosingBanner(
            closing: unseen,
            onOpen: () => _openRoomReveal(context, unseen),
          ),
        ),
      ],
      if (isLeader && study != null) ...[
        const SizedBox(height: AppSpace.md),
        _reveal(2, RoomPlanInviteCard(onTap: () => _editRoomPlan(context))),
      ],
      if (reading != null) ...[
        const SizedBox(height: AppSpace.md),
        _reveal(
          2,
          RoomReadingCard(
            reading: reading,
            isLeader: false,
            done: me?.readingDoneFor(reading) ?? 0,
            onPick: () => _pickRoomReading(context, reading),
            onOpen: () => _openRoomReading(context, reading),
          ),
        ),
      ],
      const SizedBox(height: AppSpace.md),
      _reveal(
        2,
        _RoomHearth(
          room: room,
          members: members,
          walkedToday: progress.walkedToday,
          onClaim: () => _claimRoomChest(context, room.code),
          showClock: weeklyContent,
          // Estudo pendente: o card acima já chama para ele.
          onWalk:
              study != null &&
                  !members.any((m) => m.isUser && m.didStudy(study))
              ? null
              : widget.onGoToday,
          roster: RoomMembersList(
            members: _seatedMembers(members, room.ownerId),
            myPhotoUrl: backend.userPhotoUrl,
            myStyle: progress.settings.portraitStyle,
            leaderId: room.ownerId,
            leaderTitle: room.kind.leaderTitle,
            study: study,
            onTap: (m) => _showRoomSeat(context, m),
            onInvite: rooms.isFull ? null : callPeople,
          ),
          // Líder: fechar e revelar fica no fim da lista de pessoas.
          footer: isLeader && members.isNotEmpty && weeklyContent
              ? RoomCloseWeekCta(
                  closedThisWeek: closedThisWeek,
                  closing: _closingWeek,
                  onClose: () => _closeRoomWeek(context),
                  onReveal: rooms.latestClosing == null
                      ? null
                      : () => _openRoomReveal(context, rooms.latestClosing!),
                )
              : null,
        ),
      ),
      const SizedBox(height: AppSpace.md),
      if (rooms.lastError != null) ...[
        InlineNotice(
          message: rooms.lastError!,
          busy: rooms.loading,
          onRetry: () => context.read<RoomService>().syncIfNeeded(),
        ),
        const SizedBox(height: AppSpace.md),
      ],
      if (rooms.loading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpace.xxl),
          child: AppSpinner(),
        ),
    ];
  }

  /// Grupo com menos de [kRoomMinMembers] pessoas: o Anan explica que o
  /// grupo começa com 3, chama gente e oferece a Companhia para a dupla.
  List<Widget> _buildFormingRoom(
    BuildContext context, {
    required RoomService rooms,
    required BackendService backend,
    required ProgressService progress,
    required StudyRoom room,
    required bool isLeader,
    required List<RoomInvite> incoming,
    required VoidCallback callPeople,
  }) {
    final l10n = context.l10n;
    final members = rooms.members;
    return [
      for (final invite in incoming) ...[
        _reveal(1, _incomingInviteCard(context, invite)),
        const SizedBox(height: AppSpace.md),
      ],
      // Palco como o da Caravana (sem pintura): os lugares do grupo no
      // miolo (acesos os já ocupados) e o convite logo abaixo.
      _reveal(
        2,
        JuntosHero(
          accent: AppRoles.lamp,
          // Nome e tipo do grupo dentro do card, com o menu ao lado.
          header: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StageChip(
                    accent: AppRoles.lamp,
                    glyph: room.kind.glyph,
                    label: '${room.name} · ${room.kind.label}',
                  ),
                ),
              ),
              _MenuButton(
                tooltip: l10n.juntosRoomOptions,
                onTap: () => _openRoomMenu(context),
              ),
            ],
          ),
          title: l10n.roomFormingTitle(kRoomMinMembers),
          body: l10n.roomFormingBody(rooms.missingToForm),
          middle: _FormingSeats(
            filled: kRoomMinMembers - rooms.missingToForm,
            total: kRoomMinMembers,
          ),
          actions: [
            CopperCta(
              label: l10n.roomFormingInvite,
              leading: CinematicGlyph.share,
              expanded: true,
              onTap: callPeople,
            ),
            // Só com dupla formada: sozinho, "vocês dois" não faz sentido.
            if (members.length == 2)
              GhostCta(
                label: l10n.roomFormingCompanion,
                leading: CinematicGlyph.people,
                expanded: true,
                onTap: () => setState(() => _tab = _tabCompanhia),
              ),
          ],
        ),
      ),
      const SizedBox(height: AppSpace.lg),
      _reveal(
        2,
        ProfilePanel(
          accent: AppRoles.lamp,
          padding: AppMetrics.cardPadding,
          child: RoomMembersList(
            members: _seatedMembers(members, room.ownerId),
            myPhotoUrl: backend.userPhotoUrl,
            myStyle: progress.settings.portraitStyle,
            leaderId: room.ownerId,
            leaderTitle: room.kind.leaderTitle,
            study: null,
            onTap: (m) => _showRoomSeat(context, m),
            onInvite: rooms.isFull ? null : callPeople,
          ),
        ),
      ),
      const SizedBox(height: AppSpace.md),
      if (rooms.lastError != null)
        InlineNotice(
          message: rooms.lastError!,
          busy: rooms.loading,
          onRetry: () => context.read<RoomService>().syncIfNeeded(),
        ),
    ];
  }

  /// Grupo com propósito: o dia (herói), o pulso, as respostas, o
  /// acompanhamento do líder e as pessoas. Sem semana de segunda a domingo.
  List<Widget> _buildPlanRoom(
    BuildContext context, {
    required RoomService rooms,
    required BackendService backend,
    required ProgressService progress,
    required StudyRoom room,
    required RoomPlan plan,
    required bool isLeader,
    required List<RoomInvite> incoming,
    required VoidCallback callPeople,
  }) {
    final members = rooms.members;
    final mine = rooms.myPlan ?? PlanProgress(planId: plan.id);
    final group = PlanGroup(plan, members);
    final phase = plan.phase();
    final unseen = rooms.unseenClosing;
    // Dia mostrado: o escolhido na faixa (se já abriu) ou o de hoje.
    final todayYmd = planYmd(DateTime.now());
    final picked = _planDay == null ? null : plan.dayNumber(_planDay!);
    final selected = picked != null && picked.date.compareTo(todayYmd) <= 0
        ? picked
        : plan.today();
    final answersDay =
        phase == PlanPhase.active && selected?.hasQuestion == true
        ? selected
        : null;
    // Texto das respostas só depois de responder (o líder vê sempre): as
    // rules recusam a leitura antes.
    final answersUnlocked =
        answersDay != null &&
        (isLeader || mine.answered.contains(answersDay.n));
    final othersAnswered = answersDay == null
        ? 0
        : members
              .where(
                (m) =>
                    !m.isUser &&
                    (plan.progressOf(m.plan)?.answered.contains(answersDay.n) ??
                        false),
              )
              .length;
    if (answersDay != null &&
        answersUnlocked &&
        rooms.answersFor(answersDay.n) == null &&
        !rooms.answersLoading(answersDay.n)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => rooms.loadAnswers(answersDay.n),
      );
    }

    return [
      for (final invite in incoming) ...[
        _reveal(1, _incomingInviteCard(context, invite)),
        const SizedBox(height: AppSpace.md),
      ],
      _reveal(
        2,
        RoomPlanCard(
          room: room,
          plan: plan,
          mine: mine,
          group: group,
          progress: progress,
          isLeader: isLeader,
          header: _RoomTitle(
            room: room,
            isOwner: isLeader,
            onMenu: () => _openRoomMenu(context),
          ),
          onMenu: () => _openRoomMenu(context),
          myPhotoUrl: backend.userPhotoUrl,
          myStyle: progress.settings.portraitStyle,
          selected: selected,
          onSelect: (d) => setState(() => _planDay = d.n),
          closed: rooms.planClosed,
          closing: _closingWeek,
          onJoin: () => _joinRoomPlan(context),
          onRead: (d) => _openPlanReading(context, d),
          onScene: (d) => _openPlanScene(context, d),
          onAnswer: (d) => _answerPlanDay(context, d),
          onManual: (d) => _markPlanDay(context, d),
          onEdit: () => _editRoomPlan(
            context,
            current: phase == PlanPhase.ended ? null : plan,
          ),
          onClose: () => _closeRoomPlan(context),
          onReveal: () {
            final c = rooms.latestClosing;
            if (c != null) _openRoomReveal(context, c);
          },
        ),
      ),
      // 2º cartão, como na Caravana: relógio do propósito e quem caminha.
      const SizedBox(height: AppSpace.md),
      _reveal(
        2,
        _RoomHearth(
          room: room,
          plan: plan,
          members: members,
          walkedToday: progress.walkedToday,
          onClaim: () => _claimRoomChest(context, room.code),
          // O card do propósito já tem o próximo passo: sem 2º botão.
          onWalk: null,
          roster: RoomMembersList(
            members: _seatedMembers(members, room.ownerId),
            myPhotoUrl: backend.userPhotoUrl,
            myStyle: progress.settings.portraitStyle,
            leaderId: room.ownerId,
            leaderTitle: room.kind.leaderTitle,
            study: null,
            onTap: (m) => _showRoomSeat(context, m),
            onInvite: rooms.isFull ? null : callPeople,
          ),
        ),
      ),
      if (unseen != null && !isLeader) ...[
        const SizedBox(height: AppSpace.md),
        _reveal(
          2,
          RoomClosingBanner(
            closing: unseen,
            onOpen: () => _openRoomReveal(context, unseen),
          ),
        ),
      ],
      if (answersDay != null) ...[
        const SizedBox(height: AppSpace.md),
        _reveal(
          2,
          RoomPlanAnswersCard(
            day: answersDay,
            answered: mine.answered.contains(answersDay.n),
            isLeader: isLeader,
            answers: rooms.answersFor(answersDay.n),
            othersAnswered: othersAnswered,
            private: room.answersPrivate,
            loading: rooms.answersLoading(answersDay.n),
            myUid: backend.uid,
            onAnswer: () => _answerPlanDay(context, answersDay),
            onHold: (a) => _holdPlanAnswer(context, answersDay, a),
          ),
        ),
      ],
      const SizedBox(height: AppSpace.md),
      if (rooms.lastError != null) ...[
        InlineNotice(
          message: rooms.lastError!,
          busy: rooms.loading,
          onRetry: () => context.read<RoomService>().syncIfNeeded(),
        ),
        const SizedBox(height: AppSpace.md),
      ],
      if (rooms.loading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpace.xxl),
          child: AppSpinner(),
        ),
    ];
  }

  /// Dia escolhido na faixa do propósito (null = hoje).
  int? _planDay;

  Future<void> _editRoomPlan(BuildContext context, {RoomPlan? current}) async {
    final rooms = context.read<RoomService>();
    // O propósito parte do estudo e da leitura da semana corrente, os mesmos
    // que a tela do grupo mostra. Os de semana já fechada (room.study /
    // room.reading vencidos) não entram: a tela não os mostra mais.
    final next = await showRoomPlanEditor(
      context,
      current: current,
      study: rooms.currentStudy,
      reading: rooms.currentReading,
    );
    if (next == null || !context.mounted) return;
    final ok = await rooms.setPlan(next);
    if (!context.mounted) return;
    setState(() => _planDay = null);
    showAppToastFor(
      context,
      message: ok
          ? context.l10n.planEditorSaved
          : context.l10n.planEditorSaveError,
      glyph: ok ? CinematicGlyph.calendar : CinematicGlyph.wrong,
      tone: ok ? AppToastTone.accent : AppToastTone.warn,
    );
    if (ok) await rooms.syncPlan(context.read<ProgressService>());
  }

  Future<void> _endRoomPlan(BuildContext context) async {
    final rooms = context.read<RoomService>();
    final plan = rooms.plan;
    if (plan == null) return;
    final go = await showAppConfirm(
      context,
      danger: true,
      title: context.l10n.planEndTitle,
      body: context.l10n.planEndBody,
      cancelLabel: context.l10n.commonCancel,
      confirmLabel: context.l10n.planEndConfirm,
    );
    if (!go || !context.mounted) return;
    final today = planYmd(DateTime.now());
    final kept = [
      for (final d in plan.days)
        if (d.date.compareTo(today) <= 0) d,
    ];
    // Ainda não começou: só tira o propósito.
    await rooms.setPlan(
      kept.isEmpty ? null : plan.copyWith(end: today, days: kept),
    );
    if (mounted) setState(() => _planDay = null);
  }

  Future<void> _joinRoomPlan(BuildContext context) async {
    final rooms = context.read<RoomService>();
    final ok = await rooms.joinPlan();
    if (!context.mounted || !ok) return;
    final first = rooms.plan?.days.first;
    showAppToastFor(
      context,
      message: context.l10n.planJoinedToast(
        first == null ? '' : planWhen(context, first.date),
      ),
      glyph: CinematicGlyph.heart,
      tone: AppToastTone.accent,
    );
  }

  Future<void> _openPlanReading(BuildContext context, PlanDay day) async {
    final r = day.reading;
    if (r == null) return;
    await BibleReaderScreen.open(context, r.openRef);
    if (!context.mounted) return;
    await context.read<RoomService>().syncPlan(context.read<ProgressService>());
  }

  /// A cena do dia já foi liberada para o grupo — não passa pelo cadeado.
  Future<void> _openPlanScene(BuildContext context, PlanDay day) async {
    final scene = day.scene;
    if (scene == null) return;
    // Dia de temporada (Advento) no propósito: vale a regra da estação
    // (presente aberto a todos; fora dele, Plus do 2º dia em diante) e o
    // dia conta na Caminhada como se aberto por ela.
    final progress = context.read<ProgressService>();
    final season = _seasonDayFor(scene.slug, day.date);
    if (season != null) {
      final access = SeasonWalkCatalog.access(
        campaign: season.campaign,
        index: season.day.index,
        today: progress.seasonToday,
        plusOpen: context.read<SubscriptionService>().plusFeaturesOpen,
      );
      if (access.needsPlus) {
        openSeasonPaywall(context);
        return;
      }
      if (!access.playable) return;
      await ContentCatalogService.instance.ensureTrailBank(
        season.day.trailSlug,
      );
      if (!context.mounted) return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          missionSlug: scene.slug,
          skipTrailLock: true,
          plusGateDone: season != null,
        ),
      ),
    );
    if (!context.mounted) return;
    if (season != null && progress.isMissionCompleted(scene.slug)) {
      await progress.markWalkDate(season.campaign.id, day.date);
      if (!context.mounted) return;
    }
    await context.read<RoomService>().syncPlan(progress);
  }

  /// O dia da temporada que cai em [date] com a cena [slug], se houver.
  static ({SeasonWalkCampaign campaign, SeasonWalkDay day})? _seasonDayFor(
    String slug,
    String date,
  ) {
    final d = parsePlanYmd(date);
    if (d == null) return null;
    final now = DateTime.now();
    for (final c in [
      ...SeasonWalkCatalog.all(now),
      ?SeasonWalkCatalog.justEnded(now),
    ]) {
      final day = c.dayAt(c.dayIndexOn(d) ?? 0);
      if (day != null && day.missionSlug == slug) {
        return (campaign: c, day: day);
      }
    }
    return null;
  }

  Future<void> _answerPlanDay(BuildContext context, PlanDay day) async {
    final rooms = context.read<RoomService>();
    if (rooms.myPlan?.answered.contains(day.n) ?? false) {
      setState(() => _planDay = day.n);
      return;
    }
    final text = await showPlanAnswerSheet(context, day);
    if (text == null || !context.mounted) return;
    final ok = await rooms.answerDay(
      day,
      text,
      context.read<ProgressService>(),
    );
    if (!context.mounted) return;
    setState(() => _planDay = day.n);
    showAppToastFor(
      context,
      message: ok ? context.l10n.planAnswerSaved : context.l10n.planAnswerError,
      glyph: ok ? CinematicGlyph.quote : CinematicGlyph.wrong,
      tone: ok ? AppToastTone.accent : AppToastTone.warn,
    );
  }

  Future<void> _markPlanDay(BuildContext context, PlanDay day) async {
    await context.read<RoomService>().markManualDay(
      day,
      context.read<ProgressService>(),
    );
  }

  /// Segurar uma resposta: a minha (ou, para o líder, qualquer uma) pode
  /// ser apagada; a de outra pessoa abre denunciar/bloquear.
  Future<void> _holdPlanAnswer(
    BuildContext context,
    PlanDay day,
    PlanAnswer answer,
  ) async {
    final rooms = context.read<RoomService>();
    final backend = context.read<BackendService>();
    final room = rooms.activeRoom;
    if (room == null) return;
    final mine = answer.uid == backend.uid;
    if (mine || room.isOwner(backend.uid)) {
      if (!mine) {
        final outcome = await showUserModerationSheet(
          context,
          uid: answer.uid,
          name: answer.name,
          source: UserReportSource.room,
          roomCode: room.code,
          roomName: room.name,
        );
        if (outcome != ModerationOutcome.none || !context.mounted) return;
      }
      final go = await showAppConfirm(
        context,
        danger: true,
        title: context.l10n.planAnswerDeleteTitle,
        body: context.l10n.planAnswerDeleteBody,
        cancelLabel: context.l10n.commonCancel,
        confirmLabel: context.l10n.planAnswerDelete,
      );
      if (!go || !context.mounted) return;
      await rooms.deleteAnswer(day.n, answer);
      return;
    }
    await showUserModerationSheet(
      context,
      uid: answer.uid,
      name: answer.name,
      source: UserReportSource.room,
      roomCode: room.code,
      roomName: room.name,
    );
  }

  Future<void> _closeRoomPlan(BuildContext context) async {
    setState(() => _closingWeek = true);
    final rooms = context.read<RoomService>();
    await rooms.syncPlan(context.read<ProgressService>());
    await rooms.refreshMembers();
    final closing = await rooms.closePlan();
    if (!mounted) return;
    setState(() => _closingWeek = false);
    if (!context.mounted) return;
    if (closing == null) {
      showAppToastFor(
        context,
        message: context.l10n.roomCloseWeekFailed,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    await _openRoomReveal(context, closing);
  }

  /// Você primeiro, depois quem conduz; o resto por nome. Ordem fixa: ninguém
  /// troca de lugar conforme o placar.
  static List<RoomMember> _seatedMembers(
    List<RoomMember> members,
    String ownerId,
  ) {
    final list = [...members];
    list.sort((a, b) {
      if (a.isUser != b.isUser) return a.isUser ? -1 : 1;
      if (a.uid == ownerId) return -1;
      if (b.uid == ownerId) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  /// Dono define (ou apaga, deixando em branco) a meta semanal de passos da sala.
  Future<void> _editRoomGoal(BuildContext context, int? current) async {
    final raw = await showAppDialog<String>(
      context,
      builder: (ctx) => _TextInputDialog(
        title: context.l10n.juntosRoomGoalTitle,
        hint: context.l10n.juntosRoomGoalHint,
        confirmLabel: context.l10n.commonSave,
        maxLength: 6,
        initialValue: current != null ? '$current' : '',
      ),
    );
    if (raw == null || !context.mounted) return;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      await context.read<RoomService>().setWeeklyGoal(null);
      return;
    }
    final goal = int.tryParse(trimmed);
    if (goal == null) return;
    await context.read<RoomService>().setWeeklyGoal(goal);
  }

  Future<void> _openWholeCaravan(BuildContext context, LeagueEntry me) {
    ActHaptics.light();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _WholeCaravanScreen(
          me: me,
          onOpenOwnProfile: widget.onOpenOwnProfile,
        ),
      ),
    );
  }

  List<LeagueEntry> _caravanPeople(String? myUid) {
    final seen = <String>{};
    final people = <LeagueEntry>[];
    for (final person in _overallPlayers) {
      final uid = person.uid;
      if (uid == null || uid.isEmpty || uid == myUid || person.isUser) continue;
      if (!seen.add(uid)) continue;
      people.add(person);
    }
    people.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return people;
  }

  Widget _incomingInviteCard(BuildContext context, RoomInvite invite) {
    return RoomIncomingInviteCard(
      invite: invite,
      onAccept: _inviteBusy.contains(invite.id)
          ? null
          : () => _acceptRoomInvite(context, invite),
      onDecline: _inviteBusy.contains(invite.id)
          ? null
          : () => _declineRoomInvite(context, invite),
    );
  }

  Future<bool> _inviteCaravanPerson(
    BuildContext context,
    LeagueEntry person,
  ) async {
    final uid = person.uid;
    if (uid == null || _inviteBusy.contains(uid)) return false;
    setState(() => _inviteBusy.add(uid));
    try {
      return await context.read<RoomService>().inviteMember(
        toUid: uid,
        toName: person.name,
        toPhotoUrl: person.photoUrl,
        progress: context.read<ProgressService>(),
      );
    } finally {
      if (mounted) setState(() => _inviteBusy.remove(uid));
    }
  }

  Future<void> _acceptRoomInvite(
    BuildContext context,
    RoomInvite invite,
  ) async {
    final rooms = context.read<RoomService>();
    if (rooms.hasRoom && rooms.activeCode != invite.roomCode) {
      final go = await showAppConfirm(
        context,
        title: context.l10n.juntosSwitchRoomTitle(invite.roomName),
        body: context.l10n.juntosSwitchRoomBody,
        cancelLabel: context.l10n.commonNotNow,
        confirmLabel: context.l10n.juntosAccept,
      );
      if (!go || !context.mounted) return;
    }
    setState(() => _inviteBusy.add(invite.id));
    try {
      final ok = await rooms.acceptInvite(
        invite,
        context.read<ProgressService>(),
      );
      if (!context.mounted) return;
      showAppToastFor(
        context,
        message: ok
            ? context.l10n.juntosRoomJoined(
                rooms.activeRoom?.name ?? invite.roomName,
              )
            : rooms.lastError ?? context.l10n.juntosRoomJoinError,
        glyph: ok ? CinematicGlyph.people : CinematicGlyph.wrong,
        tone: ok ? AppToastTone.accent : AppToastTone.warn,
      );
    } finally {
      if (mounted) setState(() => _inviteBusy.remove(invite.id));
    }
  }

  Future<void> _declineRoomInvite(
    BuildContext context,
    RoomInvite invite,
  ) async {
    final ok = await context.read<RoomService>().declineInvite(invite);
    if (!context.mounted || ok) return;
    showAppToastFor(
      context,
      message: context.l10n.juntosDeclineInviteError,
      glyph: CinematicGlyph.wrong,
      tone: AppToastTone.warn,
    );
  }

  Future<bool> _cancelRoomInvite(
    BuildContext context,
    LeagueEntry person,
  ) async {
    final uid = person.uid;
    if (uid == null) return false;
    final ok = await context.read<RoomService>().cancelInvite(uid);
    if (!context.mounted) return ok;
    if (!ok) {
      showAppToastFor(
        context,
        message: context.l10n.juntosCancelInviteError,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
    }
    return ok;
  }

  Future<void> _showCreateRoom(BuildContext context) async {
    final rc = context.read<RemoteConfigService>();
    if (!context.read<RoomService>().canCreate(rc.groupsEnabled)) {
      await openComingSoon(
        context,
        ComingSoonFeature.groups,
        source: 'create_room',
      );
      return;
    }
    final setup = await showRoomSetupSheet(context);
    if (setup == null || !context.mounted) return;
    final ok = await context.read<RoomService>().createRoom(
      setup.name,
      context.read<ProgressService>(),
      kind: setup.kind,
    );
    if (!context.mounted || !ok) return;
    // Mesmo gesto da Companhia: link copiado + sheet de QR/código.
    final room = context.read<RoomService>().activeRoom;
    if (room == null) return;
    await Clipboard.setData(
      ClipboardData(text: InviteDeepLinkService.roomHttpsUrl(room.code)),
    );
    if (!context.mounted) return;
    await _shareRoomInvite(context, room);
  }

  Future<void> _shareRoomInvite(BuildContext context, StudyRoom room) {
    return showInviteQrSheet(
      context,
      code: room.code,
      headline: room.name,
      companionMode: false,
      inviterName: context.read<ProgressService>().publicUserName,
      shareMessage: context.l10n.juntosRoomShareText(
        room.name,
        InviteDeepLinkService.roomHttpsUrl(room.code),
        room.code,
        AppUpdateService.androidStoreUrl,
      ),
    );
  }

  Future<void> _claimRoomChest(BuildContext context, String code) async {
    final progress = context.read<ProgressService>();
    final chestId = 'room-pulse-${LeagueService.weekKey()}-$code';
    final bonus = RemoteConfigService.instance.roomChestBonusSteps;
    final ok = await progress.claimChest(chestId, bonus);
    if (!context.mounted) return;
    if (ok) ActHaptics.confirm();
    showAppToastFor(
      context,
      message: ok
          ? context.l10n.juntosRoomChestClaimed(bonus)
          : context.l10n.juntosRoomChestAlready,
      glyph: ok ? CinematicGlyph.gift : CinematicGlyph.wrong,
      tone: ok ? AppToastTone.accent : AppToastTone.warn,
    );
  }

  Future<void> _showRoomSeat(BuildContext context, RoomMember m) async {
    final rooms = context.read<RoomService>();
    final room = rooms.activeRoom;
    final other = !m.isUser && m.uid.isNotEmpty;
    final iLead = room?.isOwner(context.read<BackendService>().uid) ?? false;
    // Aceno vale para qualquer pessoa (apoio, oração, saudade), não só
    // para quem não caminhou: um por pessoa por dia.
    final canCall = other && !rooms.nudgedToday.contains(m.uid);
    // Respostas da pessoa: o líder vê todas; quem é membro vê só os dias
    // que também respondeu (mesma regra do card de respostas).
    final plan = rooms.plan;
    Future<Map<int, String>>? answers;
    var hiddenAnswers = 0;
    if (room != null && plan != null && m.uid.isNotEmpty) {
      final theirs = plan.progressOf(m.plan)?.answered ?? const <int>{};
      final myAnswered = rooms.myPlan?.answered ?? const <int>{};
      final visible = m.isUser || iLead
          ? theirs
          : room.answersPrivate
          ? <int>{}
          : theirs.where(myAnswered.contains).toSet();
      // Fechadas pelo líder: nada a destravar respondendo.
      hiddenAnswers = room.answersPrivate && !iLead
          ? 0
          : theirs.length - visible.length;
      if (visible.isNotEmpty) {
        answers = context.read<BackendService>().fetchMemberPlanAnswers(
          room.code,
          plan.id,
          m.uid,
          visible,
        );
      }
    }
    final action = await showRoomSeatSheet(
      context,
      member: m,
      status: seatLabel(m),
      isLeader: m.uid == room?.ownerId,
      leaderTitle: room?.kind.leaderTitle ?? context.l10n.juntosLeader,
      study: rooms.currentStudy,
      plan: rooms.plan,
      canCall: canCall,
      alreadyCalled: rooms.nudgedToday.contains(m.uid),
      canViewProfile: other,
      canTransfer: other && iLead,
      canModerate: other,
      answers: answers,
      hiddenAnswers: hiddenAnswers,
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case RoomSeatAction.wave:
        final plan = rooms.plan;
        final invitePlan =
            plan != null &&
            plan.phase() == PlanPhase.upcoming &&
            !(plan.progressOf(m.plan)?.joined ?? false);
        final kind = await showRoomWavePicker(
          context,
          name: m.name.trim().split(RegExp(r'\s+')).first,
          invitePlan: invitePlan,
        );
        if (kind == null || !context.mounted) return;
        await _nudgeRoomMember(context, m, kind: kind);
      case RoomSeatAction.profile:
        await showCaravanPilgrimSheet(
          context,
          entry: LeagueEntry(
            uid: m.uid,
            name: m.name,
            steps: m.steps,
            lastWalkDate: m.lastWalk,
            photoUrl: m.photoUrl,
            portraitStyle: m.portraitStyle,
          ),
          rank: 0,
        );
      case RoomSeatAction.transfer:
        await _transferRoomTo(context, m);
      case RoomSeatAction.moderate:
        await showUserModerationSheet(
          context,
          uid: m.uid,
          name: m.name,
          source: UserReportSource.room,
          roomCode: room?.code,
          roomName: room?.name,
        );
    }
  }

  /// Passar a liderança direto da folha da pessoa (sem escolher na lista).
  Future<void> _transferRoomTo(BuildContext context, RoomMember to) async {
    final first = to.name.trim().split(RegExp(r'\s+')).first;
    final ok = await showAppConfirm(
      context,
      title: context.l10n.groupSeatMakeLeader(first),
      body: context.l10n.groupSeatMakeLeaderBody(first),
      cancelLabel: context.l10n.commonCancel,
      confirmLabel: context.l10n.juntosTransferTitle,
    );
    if (!ok || !context.mounted) return;
    final done = await context.read<RoomService>().transferOwnership(to);
    if (!context.mounted) return;
    showAppToastFor(
      context,
      message: done
          ? context.l10n.juntosTransferDone(to.name)
          : context.l10n.juntosTransferError,
      glyph: done ? CinematicGlyph.crown : CinematicGlyph.wrong,
      tone: done ? AppToastTone.accent : AppToastTone.warn,
    );
  }

  Future<void> _pickRoomStudy(BuildContext context) async {
    final study = await showRoomStudyPicker(context);
    if (study == null || !context.mounted) return;
    final rooms = context.read<RoomService>();
    final ok = await rooms.setStudy(study);
    if (!context.mounted) return;
    showAppToastFor(
      context,
      message: ok
          ? context.l10n.juntosRoomStudySet
          : context.l10n.juntosRoomStudySetError,
      glyph: ok ? CinematicGlyph.book : CinematicGlyph.wrong,
      tone: ok ? AppToastTone.accent : AppToastTone.warn,
    );
    if (ok) await rooms.syncStudyDone(context.read<ProgressService>());
  }

  bool _closingWeek = false;

  Future<void> _pickRoomReading(
    BuildContext context,
    RoomReading? current,
  ) async {
    final picked = await showRoomReadingPicker(
      context,
      current: current,
      study: context.read<RoomService>().currentStudy,
    );
    if (picked == null || !context.mounted) return;
    final rooms = context.read<RoomService>();
    final ok = await rooms.setReading(picked);
    if (!context.mounted) return;
    showAppToastFor(
      context,
      message: ok
          ? context.l10n.roomReadingSaved
          : context.l10n.juntosRoomStudySetError,
      glyph: ok ? CinematicGlyph.book : CinematicGlyph.wrong,
      tone: ok ? AppToastTone.accent : AppToastTone.warn,
    );
    if (ok) await rooms.syncReading(context.read<ProgressService>());
  }

  /// Abre o 1º capítulo da leitura; ao voltar, grava quanto foi lido.
  Future<void> _openRoomReading(
    BuildContext context,
    RoomReading? reading,
  ) async {
    if (reading == null) return;
    await BibleReaderScreen.open(context, reading.openRef);
    if (!context.mounted) return;
    await context.read<RoomService>().syncReading(
      context.read<ProgressService>(),
    );
  }

  Future<void> _closeRoomWeek(BuildContext context) async {
    final go = await showAppConfirm(
      context,
      title: context.l10n.roomCloseWeekConfirmTitle,
      body: context.l10n.roomCloseWeekConfirmBody,
      cancelLabel: context.l10n.commonCancel,
      confirmLabel: context.l10n.roomCloseWeek,
    );
    if (!go || !context.mounted) return;
    setState(() => _closingWeek = true);
    final rooms = context.read<RoomService>();
    final progress = context.read<ProgressService>();
    // O líder também entra na conta com a leitura e o crescimento de hoje.
    await rooms.syncReading(progress);
    await rooms.syncGrowth(progress);
    await rooms.refreshMembers();
    final closing = await rooms.closeWeek();
    if (!mounted) return;
    setState(() => _closingWeek = false);
    if (!context.mounted) return;
    if (closing == null) {
      showAppToastFor(
        context,
        message: context.l10n.roomCloseWeekFailed,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    await _openRoomReveal(context, closing);
  }

  Future<void> _openRoomReveal(BuildContext context, RoomClosing closing) {
    final rooms = context.read<RoomService>();
    final backend = context.read<BackendService>();
    final room = rooms.activeRoom;
    return RoomRevealScreen.open(
      context,
      closing: closing,
      roomName: room?.name ?? '',
      isLeader: room?.isOwner(backend.uid) ?? false,
      myUid: backend.uid,
    );
  }

  /// O líder já autorizou a missão para o grupo — não passa pelo cadeado.
  Future<void> _openRoomStudy(BuildContext context, RoomStudy? study) async {
    if (study == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            LessonScreen(missionSlug: study.missionSlug, skipTrailLock: true),
      ),
    );
    if (!context.mounted) return;
    await context.read<RoomService>().syncStudyDone(
      context.read<ProgressService>(),
    );
  }

  Future<void> _nudgeRoomMember(
    BuildContext context,
    RoomMember m, {
    RoomWaveKind? kind,
  }) async {
    final ok = await context.read<RoomService>().nudge(
      m,
      context.read<ProgressService>(),
      kind: kind?.name,
    );
    if (!context.mounted) return;
    final first = m.name.trim().split(RegExp(r'\s+')).first;
    showAppToastFor(
      context,
      message: ok
          ? context.l10n.juntosWavedAt(first)
          : context.l10n.juntosWaveError,
      glyph: ok ? CinematicGlyph.bell : CinematicGlyph.wrong,
      tone: ok ? AppToastTone.accent : AppToastTone.warn,
    );
  }

  Future<void> _openRoomMenu(BuildContext context) async {
    final rooms = context.read<RoomService>();
    final room = rooms.activeRoom;
    if (room == null) return;
    final others = rooms.members.where((m) => !m.isUser).toList();
    final backend = context.read<BackendService>();

    final plan = rooms.plan;
    final action = await showRoomMenu(
      context,
      room: room,
      hasStudy: rooms.currentStudy != null,
      canTransfer: others.isNotEmpty,
      isLeader: room.isOwner(backend.uid),
      plan: plan == null
          ? RoomMenuPlan.none
          : plan.phase() == PlanPhase.ended
          ? RoomMenuPlan.ended
          : RoomMenuPlan.live,
      planClosed: rooms.planClosed,
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case RoomMenuAction.pickStudy:
        await _pickRoomStudy(context);
      case RoomMenuAction.edit:
        final setup = await showRoomSetupSheet(
          context,
          title: context.l10n.juntosEditRoomTitle,
          confirmLabel: context.l10n.commonSave,
          initialName: room.name,
          initialKind: room.kind,
        );
        if (setup == null || !context.mounted) return;
        await rooms.editRoom(name: setup.name, kind: setup.kind);
      case RoomMenuAction.goal:
        await _editRoomGoal(context, room.weeklyGoalSteps);
      case RoomMenuAction.answersPrivacy:
        final private = !room.answersPrivate;
        final ok = await rooms.setAnswersPrivate(private);
        if (!context.mounted) return;
        showAppToastFor(
          context,
          message: !ok
              ? context.l10n.cornerActionFailed
              : private
              ? context.l10n.planAnswersNowPrivate
              : context.l10n.planAnswersNowOpen,
          glyph: ok ? CinematicGlyph.check : CinematicGlyph.wrong,
          tone: ok ? AppToastTone.accent : AppToastTone.warn,
        );
      case RoomMenuAction.clearStudy:
        await rooms.setStudy(null);
      case RoomMenuAction.transfer:
        await _transferRoom(context, others);
      case RoomMenuAction.plan:
        await _editRoomPlan(
          context,
          current: plan != null && plan.phase() != PlanPhase.ended
              ? plan
              : null,
        );
      case RoomMenuAction.endPlan:
        await _endRoomPlan(context);
      case RoomMenuAction.revealPlan:
        await _closeRoomPlan(context);
      case RoomMenuAction.leave:
        await _leaveRoom(
          context,
          isLeader: room.isOwner(backend.uid),
          others: others,
        );
      case RoomMenuAction.close:
        await _closeRoom(context);
    }
  }

  Future<void> _closeRoom(BuildContext context) async {
    final ok = await showAppConfirm(
      context,
      danger: true,
      title: context.l10n.juntosCloseRoomTitle,
      body: context.l10n.juntosCloseRoomBody,
      cancelLabel: context.l10n.commonCancel,
      confirmLabel: context.l10n.juntosCloseConfirm,
      confirmDelay: const Duration(seconds: 5),
    );
    if (!ok || !context.mounted) return;
    final closed = await context.read<RoomService>().closeRoom(
      progress: context.read<ProgressService>(),
    );
    if (!closed && context.mounted) {
      showAppToastFor(
        context,
        message: context.l10n.cornerActionFailed,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
    }
  }

  Future<bool> _transferRoom(
    BuildContext context,
    List<RoomMember> others,
  ) async {
    final rooms = context.read<RoomService>();
    final to = await showRoomMemberPicker(
      context,
      title: context.l10n.juntosTransferTitle,
      body: context.l10n.juntosTransferBody,
      members: others,
    );
    if (to == null || !context.mounted) return false;
    final ok = await rooms.transferOwnership(to);
    if (!context.mounted) return ok;
    showAppToastFor(
      context,
      message: ok
          ? context.l10n.juntosTransferDone(to.name)
          : context.l10n.juntosTransferError,
      glyph: ok ? CinematicGlyph.crown : CinematicGlyph.wrong,
      tone: ok ? AppToastTone.accent : AppToastTone.warn,
    );
    return ok;
  }

  /// Líder com gente no grupo passa a liderança antes de sair — senão o
  /// grupo fica sem ninguém que marque o estudo.
  Future<void> _leaveRoom(
    BuildContext context, {
    required bool isLeader,
    required List<RoomMember> others,
  }) async {
    final rooms = context.read<RoomService>();
    final progress = context.read<ProgressService>();
    if (isLeader && others.isNotEmpty) {
      final go = await showAppConfirm(
        context,
        title: context.l10n.juntosBeforeLeaveTitle,
        body: context.l10n.juntosBeforeLeaveBody,
        cancelLabel: context.l10n.commonCancel,
        confirmLabel: context.l10n.juntosChoose,
      );
      if (!go || !context.mounted) return;
      final ok = await _transferRoom(context, others);
      if (!ok || !context.mounted) return;
      await rooms.leaveRoom(progress: progress);
      return;
    }
    final ok = await _confirmLeave(context);
    if (ok && context.mounted) {
      await rooms.leaveRoom(progress: progress);
    }
  }

  Future<void> _showJoinRoom(BuildContext context) async {
    final code = await showAppDialog<String>(
      context,
      builder: (ctx) => _TextInputDialog(
        title: context.l10n.juntosJoinRoomTitle,
        hint: context.l10n.juntosJoinRoomHint,
        confirmLabel: context.l10n.juntosJoin,
        maxLength: 8,
        capitalize: true,
        letterSpacing: 3,
      ),
    );
    if (code == null || code.isEmpty || !context.mounted) return;
    final parsed =
        InviteDeepLinkService.extractRoomCode(code) ??
        InviteDeepLinkService.extractCompanionCode(code) ??
        code;
    await _joinRoomWithCode(context, parsed);
  }

  Future<void> _joinRoomWithCode(BuildContext context, String code) async {
    final rooms = context.read<RoomService>();
    final ok = await rooms.joinRoom(code, context.read<ProgressService>());
    if (!context.mounted) return;
    if (!ok) {
      showAppToastFor(
        context,
        message: rooms.lastError ?? context.l10n.juntosRoomJoinError,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    showAppToastFor(
      context,
      message: rooms.activeRoom?.name != null
          ? context.l10n.juntosRoomJoined(rooms.activeRoom!.name)
          : context.l10n.juntosRoomJoinedGeneric,
      glyph: CinematicGlyph.people,
    );
  }

  Future<bool> _confirmLeave(BuildContext context) {
    return showAppConfirm(
      context,
      danger: true,
      title: context.l10n.juntosLeaveRoomTitle,
      body: context.l10n.juntosLeaveRoomBody,
      cancelLabel: context.l10n.commonCancel,
      confirmLabel: context.l10n.juntosLeaveConfirm,
    );
  }
}

class _SegmentTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final bool caravanAlert;
  final bool companionAlert;
  final bool gruposAlert;

  const _SegmentTabs({
    required this.index,
    required this.onChanged,
    this.caravanAlert = false,
    this.companionAlert = false,
    this.gruposAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    // Mesmo trilho da Bíblia: fundo do card, a arte não atravessa o texto.
    return AppSegmentedTabs(
      index: index,
      onChanged: onChanged,
      accent: AppRoles.presence,
      fill: Appearance.of(context).cardFill,
      items: [
        (
          label: context.l10n.juntosTabCompanion,
          glyph: CinematicGlyph.link,
          mark: null,
          alert: companionAlert,
        ),
        (
          label: context.l10n.juntosTabCaravan,
          glyph: CinematicGlyph.podium,
          mark: null,
          alert: caravanAlert,
        ),
        (
          label: context.l10n.juntosTabGroups,
          glyph: CinematicGlyph.people,
          mark: null,
          alert: gruposAlert,
        ),
      ],
    );
  }
}

class _CompanhiaStageCard extends StatelessWidget {
  final int pane;
  final ValueChanged<int> onPaneChanged;
  final bool companionAlert;
  final bool desafioAlert;
  final Widget? body;

  const _CompanhiaStageCard({
    required this.pane,
    required this.onPaneChanged,
    this.companionAlert = false,
    this.desafioAlert = false,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    final hasBody = body != null;
    // Submenu e abas-mãe usam o azul da nuvem. O ouro fica no botão.
    const tone = AppRoles.presence;
    final tabs = AppSegmentedTabs(
      index: pane,
      accent: tone,
      // Solto na tela (sem card em volta), igual à Bíblia; dentro do card
      // fica o poço translúcido.
      fill: Appearance.of(context).cardFill,
      onChanged: (i) {
        ActHaptics.tap();
        onPaneChanged(i);
      },
      items: [
        // Sem glifo: a aba-mãe já leva o elo + "Companhia".
        (
          label: context.l10n.juntosTabCompanion,
          glyph: null,
          mark: null,
          alert: companionAlert,
        ),
        (
          label: context.l10n.juntosTabChallenge,
          glyph: null,
          mark: null,
          alert: desafioAlert,
        ),
      ],
    );
    // Só a troca, sem card em volta: um card inteiro para dois botões
    // empurrava a companhia para baixo da dobra. O card volta quando há
    // explicação embaixo (sem companhia ou no Desafio).
    if (!hasBody) return tabs;
    // A explicação é um quadro do Perfil logo abaixo da troca.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tabs,
        const SizedBox(height: AppSpace.md),
        body!,
      ],
    );
  }
}

/// Stage da Caravana — ranking do mês + nível (semanas firmes).
class _CaravanStageCard extends StatelessWidget {
  const _CaravanStageCard();

  /// Meia-noite local do dia 1 do próximo mês (quando o ranking zera).
  static DateTime _monthClosesAt([DateTime? now]) {
    final n = now ?? DateTime.now();
    return DateTime(n.year, n.month + 1, 1);
  }

  /// Preview das fases: `null` = calendário real; `0` azul, `1` amarelo, `2` vermelho.
  static const int? _previewUrgencyPart = null;

  /// Mês em 3 terços: azul → amarelo → vermelho. Última semana pisca.
  static (Color tone, bool blink) _monthUrgency([DateTime? now]) {
    final n = now ?? DateTime.now();
    final daysInMonth = DateTime(n.year, n.month + 1, 0).day;
    final part = _previewUrgencyPart ?? ((n.day - 1) * 3) ~/ daysInMonth;
    final tone = switch (part) {
      0 => AppRoles.navTogether, // teal do Juntos — início
      1 => AppRoles.reward, // amarelo — meio
      _ => AppRoles.risk, // vermelho — fim
    };
    final blink = n.day > daysInMonth - 7;
    return (tone, blink);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final (tone, blink) = _monthUrgency();
    final league = context.watch<LeagueService>();
    final weekScenes = context.select(
      (ProgressService p) => p.currentWeekScenes,
    );
    // Sem pintura: a capa do cartão da etapa logo abaixo já é a imagem.
    // Aqui o protagonista é o relógio do mês.
    return JuntosHero(
      accent: tone,
      title: l10n.juntosCaravanMonthTitle,
      body: l10n.juntosCaravanMonthBody,
      middle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SeasonCountdown(
            large: true,
            opens: _monthClosesAt(),
            color: a.onDark ? tone : a.ink(tone),
            muted: a.textSecondary,
            accent: tone,
            centered: true,
            blink: blink,
            label: l10n.juntosCaravanMonthCloses,
          ),
          const SizedBox(height: AppSpace.md),
          const ListDivider(),
          const SizedBox(height: AppSpace.sm),
          _CaravanLevel(
            tier: league.tier,
            isMaxTier: league.isMaxTier,
            steadyWeeks: league.steadyWeeks,
            weekScenes: weekScenes,
          ),
        ],
      ),
    );
  }
}

/// Seu nível: semanas firmes rumo ao próximo (nunca desce).
class _CaravanLevel extends StatelessWidget {
  final LeagueTier tier;
  final bool isMaxTier;
  final int steadyWeeks;
  final int weekScenes;

  /// Cada nível tem sua cor — semente verde, videira uva, oliveira areia,
  /// cedro teal, estrela ouro.
  static Color _tierTone(LeagueTier tier) => switch (tier) {
    LeagueTier.semente => AppRoles.observation,
    LeagueTier.videira => AppRoles.interpretation,
    LeagueTier.oliveira => AppRoles.areaOldTestament,
    LeagueTier.cedro => AppRoles.areaChristianLife,
    LeagueTier.estrela => AppRoles.reward,
  };

  const _CaravanLevel({
    required this.tier,
    required this.isMaxTier,
    required this.steadyWeeks,
    required this.weekScenes,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    const goal = LeagueService.steadyWeekScenes;
    const total = LeagueService.steadyWeeksToRise;
    final weekFirm = weekScenes >= goal;
    final steadyLine = isMaxTier
        ? l10n.juntosLevelTop
        : l10n.juntosLevelSteady(
            steadyWeeks,
            total,
            LeagueTier.values[tier.index + 1].label,
          );
    final weekLine = weekFirm
        ? l10n.juntosLevelWeekDone
        : l10n.juntosLevelWeek(weekScenes, goal);

    final tone = _tierTone(tier);
    final toneInk = a.onDark ? tone : a.ink(tone);

    return Row(
      children: [
        IconWell(
          size: 40,
          accent: tone,
          glowing: true,
          child: CinematicIcon(
            glyph: CinematicGlyph.tree,
            size: AppMetrics.iconMd,
            accent: tone,
            framed: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(
                l10n.juntosLevelTitle(tier.label),
                size: 10,
                color: toneInk,
              ),
              const SizedBox(height: 2),
              Text(
                steadyLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.title(size: 14, color: a.text),
              ),
              if (!isMaxTier)
                Text(
                  weekLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: weekFirm ? AppRoles.success : a.textFaint,
                  ),
                ),
            ],
          ),
        ),
        if (!isMaxTier) ...[
          const SizedBox(width: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < total; i++)
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < steadyWeeks
                        ? AppRoles.success
                        : tone.withValues(alpha: 0.16),
                    border: Border.all(
                      color: i < steadyWeeks
                          ? AppRoles.success
                          : tone.withValues(alpha: 0.6),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Grupo encerrado: quem encerrou e quando. O líder pode reabrir; tudo
/// (membros, propósito, respostas) continua guardado.
class _ClosedRoomNotice extends StatelessWidget {
  final StudyRoom room;
  final String? myUid;

  const _ClosedRoomNotice({required this.room, required this.myUid});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a = Appearance.of(context);
    final mine = room.isOwner(myUid);
    final at = room.closedAt;
    final date = at == null
        ? ''
        : DateFormat.MMMd(l10n.localeName).format(at.toLocal());
    final by = (room.closedByName ?? '').trim();
    final message = room.closedBy != null && room.closedBy == myUid
        ? l10n.roomClosedNoticeMine(room.name, date)
        : by.isEmpty
        ? l10n.roomClosedNoticeAnon(room.name, date)
        : l10n.roomClosedNotice(room.name, by.split(' ').first, date);
    final rooms = context.read<RoomService>();
    return ProfilePanel(
      accent: AppRoles.presence,
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.lock,
                size: AppMetrics.leadingIcon,
                accent: a.textSecondary,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.body(
                    size: 13,
                    height: 1.4,
                    color: a.textSecondary,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.commonClose,
                onPressed: rooms.dismissClosedRoom,
                icon: Icon(Icons.close, size: 18, color: a.textFaint),
              ),
            ],
          ),
          if (mine) ...[
            const SizedBox(height: AppSpace.sm),
            GhostCta(
              label: l10n.roomReopen,
              leading: CinematicGlyph.door,
              onTap: rooms.loading
                  ? null
                  : () => rooms.reopenClosedRoom(
                      progress: context.read<ProgressService>(),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

typedef _Me = ({
  String name,
  String? photo,
  String seed,
  PortraitStyle style,
  String? cover,
});

/// Sem companhia: o palco pintado com a sua capa, só o convite — sem
/// retratos nem fio (o Anan aparece só no carregando).
class _CompanionEmptyStage extends StatelessWidget {
  final _Me me;
  final bool loading;
  final VoidCallback onInvite;
  final VoidCallback onCall;
  final VoidCallback onJoin;

  const _CompanionEmptyStage({
    required this.me,
    required this.loading,
    required this.onInvite,
    required this.onCall,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return JuntosHero(
      accent: AppRoles.presence,
      sceneSlug: me.cover,
      title: l10n.juntosCompanionExplainerTitle,
      body: l10n.juntosCompanionExplainerBody,
      middle: StageSteps(
        steps: [
          (CinematicGlyph.path, l10n.juntosCompanionStep1, AppRoles.presence),
          (CinematicGlyph.flame, l10n.juntosCompanionStep2, AppRoles.streak),
          (CinematicGlyph.lamp, l10n.juntosCompanionStep3, AppRoles.lamp),
        ],
      ),
      loading: loading,
      actions: [
        CopperCta(
          label: l10n.juntosInviteCompanion,
          onTap: onInvite,
          leading: CinematicGlyph.people,
          trailing: null,
        ),
        GhostCta(
          label: l10n.juntosCallFromCaravan,
          leading: CinematicGlyph.people,
          expanded: true,
          onTap: onCall,
        ),
        GhostCta(
          label: l10n.juntosHaveCode,
          leading: CinematicGlyph.qr,
          expanded: true,
          onTap: onJoin,
        ),
      ],
    );
  }
}

/// Sem desafio: o mesmo palco, só o convite — sem retratos nem bandeira.
class _DesafioEmptyStage extends StatelessWidget {
  final _Me me;
  final VoidCallback onPick;

  const _DesafioEmptyStage({required this.me, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return JuntosHero(
      accent: AppRoles.navTrails,
      sceneSlug: me.cover,
      title: l10n.juntosChallengeExplainerTitle,
      body: l10n.juntosChallengeExplainerBody(CornerCopy.reward),
      middle: StageSteps(
        steps: [
          (CinematicGlyph.path, l10n.juntosChallengeStep1, AppRoles.presence),
          (
            CinematicGlyph.calendar,
            l10n.juntosChallengeStep2,
            AppRoles.navTrails,
          ),
          (CinematicGlyph.rise, l10n.juntosChallengeStep3, AppRoles.reward),
        ],
      ),
      actions: [
        CopperCta(
          label: CornerCopy.boardPickCta,
          leading: CinematicGlyph.flag,
          trailing: null,
          onTap: onPick,
        ),
      ],
    );
  }
}

class _RoomsOfflineCard extends StatelessWidget {
  final String? error;
  final bool loading;
  final VoidCallback onRetry;

  const _RoomsOfflineCard({
    this.error,
    this.loading = false,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    // EmptyState já traz o próprio respiro — o card não soma padding.
    return ProfilePanel(
      accent: AppRoles.risk,
      padding: EdgeInsets.zero,
      child: EmptyState(
        mark: CloudMascot(
          face: loading ? CloudFace.carregando : CloudFace.erro,
          size: 96,
        ),
        title: context.l10n.juntosRoomsOfflineTitle,
        body: error ?? context.l10n.juntosRoomsOfflineBody,
        action: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CopperCta(
              label: loading
                  ? context.l10n.juntosConnecting
                  : context.l10n.commonTryAgain,
              onTap: loading ? null : onRetry,
              busy: loading,
              leading: CinematicGlyph.refresh,
              trailing: null,
              dense: true,
            ),
            const SizedBox(height: AppSpace.md),
            Text(
              context.l10n.juntosRoomsOfflineFoot,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: a.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Os lugares do grupo em formação: ocupados acesos na cor do Grupo,
/// vazios no tom apagado.
class _FormingSeats extends StatelessWidget {
  final int filled;
  final int total;

  const _FormingSeats({required this.filled, required this.total});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: AppSpace.md),
          IconWell(
            size: 44,
            accent: i < filled ? AppRoles.lamp : a.textFaint,
            glowing: i < filled,
            child: CinematicIcon(
              glyph: CinematicGlyph.people,
              size: AppMetrics.iconMd,
              accent: i < filled ? AppRoles.lamp : a.textFaint,
              framed: false,
            ),
          ),
        ],
      ],
    );
  }
}

class _RoomsEmptyState extends StatelessWidget {
  final bool loading;
  final String? error;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const _RoomsEmptyState({
    required this.loading,
    required this.error,
    required this.onCreate,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cover = context.select(profileCoverSceneOf);
    return JuntosHero(
      accent: AppRoles.lamp,
      sceneSlug: cover,
      title: l10n.juntosRoomsEmptyTitle,
      body: l10n.juntosRoomsEmptyBody,
      middle: StageSteps(
        steps: [
          (CinematicGlyph.book, l10n.juntosRoomBenefitStudy, AppRoles.navBible),
          (
            CinematicGlyph.people,
            l10n.juntosRoomBenefitList,
            AppRoles.presence,
          ),
          (CinematicGlyph.bell, l10n.juntosRoomBenefitWave, AppRoles.lamp),
        ],
        details: [
          l10n.juntosRoomBenefitStudyDetail,
          l10n.juntosRoomBenefitListDetail,
          l10n.juntosRoomBenefitWaveDetail,
        ],
      ),
      loading: loading,
      actions: [
        CopperCta(
          label: l10n.juntosCreateRoom,
          onTap: onCreate,
          leading: CinematicGlyph.people,
          trailing: null,
        ),
        GhostCta(
          label: l10n.juntosHaveCode,
          leading: CinematicGlyph.lock,
          expanded: true,
          onTap: onJoin,
        ),
      ],
      notice: error == null
          ? null
          : InlineNotice(message: error!, standalone: false),
    );
  }
}

class _RoomTitle extends StatelessWidget {
  final StudyRoom room;
  final bool isOwner;
  final VoidCallback onMenu;

  const _RoomTitle({
    required this.room,
    required this.isOwner,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // O botão de opções flutua à direita para não empurrar o tipo.
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.sm, right: 48),
              // Traço de título de card, na altura da 1ª linha do display.
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: 24,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: a.place,
                      borderRadius: BorderRadius.circular(AppRadii.hair),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        room.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.display(
                          size: 28,
                          height: 1.05,
                          color: a.text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Menu para todos: o líder conduz; todos podem sair por ele.
            Positioned(
              top: 0,
              right: 0,
              child: _MenuButton(
                tooltip: context.l10n.juntosRoomOptions,
                onTap: onMenu,
              ),
            ),
          ],
        ),
        // 4 = mesmo vão visível (tinta a tinta) que o resto do card.
        const SizedBox(height: 4),
        Row(
          children: [
            const SizedBox(width: 13),
            CinematicIcon(
              glyph: room.kind.glyph,
              size: AppMetrics.iconSm,
              accent: a.place,
              framed: false,
            ),
            const SizedBox(width: 6),
            Expanded(child: SectionLabel(room.kind.label, maxLines: 1)),
          ],
        ),
      ],
    );
  }
}

/// Semana do grupo: o relógio até segunda 00:00, quem está no grupo (com as
/// bolinhas da semana), a meta e o baú.
/// Relógio do grupo (igual ao da Caravana). Sem propósito: fecha segunda
/// 00:00. Com propósito: até o começo, depois até o fim do último dia.
/// Âmbar → amarelo (2–3 dias) → vermelho e pisca no último dia; esperar o
/// começo não é urgência.
class _RoomClock extends StatelessWidget {
  final RoomPlan? plan;

  const _RoomClock({this.plan});

  static ({DateTime closesAt, Color tone, bool blink, bool upcoming}) of(
    RoomPlan? p,
  ) {
    final now = DateTime.now();
    final upcoming = p != null && p.phase() == PlanPhase.upcoming;
    // Fim do propósito = 00:00 do dia seguinte ao último.
    final planEnd = p == null ? null : parsePlanYmd(p.end);
    final closesAt = p == null
        ? DateTime(now.year, now.month, now.day + LeagueService.daysLeft(now))
        : upcoming
        ? parsePlanYmd(p.start)!
        : DateTime(planEnd!.year, planEnd.month, planEnd.day + 1);
    final days = closesAt
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    final urgent = upcoming ? 99 : days;
    final tone = urgent <= 1
        ? AppRoles.risk
        : urgent <= 3
        ? AppRoles.reward
        : AppRoles.lamp;
    return (
      closesAt: closesAt,
      tone: tone,
      blink: urgent <= 1,
      upcoming: upcoming,
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final c = of(plan);
    return SeasonCountdown(
      opens: c.closesAt,
      color: a.onDark ? c.tone : a.ink(c.tone),
      muted: a.textSecondary,
      accent: c.tone,
      large: true,
      centered: true,
      blink: c.blink,
      label: plan == null
          ? l10n.juntosCaravanMonthCloses
          : c.upcoming
          ? l10n.planHearthStarts
          : l10n.planHearthEnds,
    );
  }
}

class _RoomHearth extends StatelessWidget {
  final StudyRoom room;
  final List<RoomMember> members;
  final bool walkedToday;
  final VoidCallback onClaim;

  /// `null` quando o card do estudo acima já leva ao mesmo lugar.
  final VoidCallback? onWalk;

  /// Quem está no grupo, sob o relógio.
  final Widget roster;

  /// Logo abaixo da lista de pessoas (líder: fechar a semana e revelar).
  final Widget? footer;

  /// Com propósito: o relógio segue o período que o líder escolheu (até o
  /// começo, depois até o fim do último dia), não a semana de seg a dom.
  final RoomPlan? plan;

  /// Falso: sem propósito e sem estudo da semana não há nada fechando —
  /// o relógio some (antes contava até segunda sem o líder ter marcado nada).
  final bool showClock;

  const _RoomHearth({
    required this.room,
    required this.members,
    required this.walkedToday,
    required this.onClaim,
    this.onWalk,
    required this.roster,
    this.footer,
    this.plan,
    this.showClock = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final p = plan;

    final total = members.length;
    final lit = members.where((m) => m.walkedThisWeek).length;
    final sumSteps = members.fold<int>(0, (sum, m) => sum + m.steps);
    final goal = room.weeklyGoalSteps;
    final goalReached = goal != null && goal > 0 && sumSteps >= goal;
    final halfway = total > 0 && lit * 2 >= total;
    final chestId = 'room-pulse-${LeagueService.weekKey()}-${room.code}';
    final claimed = progress.isChestClaimed(chestId);
    final ready =
        !claimed && walkedToday && total > 0 && (goalReached || halfway);
    final bonus = RemoteConfigService.instance.roomChestBonusSteps;

    // Mesma cara da Caravana: um cartão com o título e o relógio (a moldura
    // acende na cor da urgência) e, embaixo, outro com as pessoas.
    final title = Text(
      p == null ? l10n.juntosRoomWeekLabel : l10n.planHearthLabel,
      textAlign: TextAlign.center,
      style: AppTypography.display(size: 26, color: a.text),
    );
    final people = <Widget>[
      roster,
      if (footer != null) ...[const SizedBox(height: AppSpace.lg), footer!],
      if (goal != null && goal > 0) ...[
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            SectionLabel(l10n.juntosRoomGoalLabel, size: 10),
            const Spacer(),
            Text(
              l10n.juntosRoomGoalProgress(sumSteps, goal),
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w800,
                color: goalReached ? AppRoles.reward : a.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AppProgressBar(
          value: (sumSteps / goal).clamp(0.0, 1.0),
          color: AppRoles.reward,
        ),
      ],
      if (!walkedToday && total > 1 && onWalk != null) ...[
        const SizedBox(height: AppSpace.lg),
        CopperCta(
          label: l10n.juntosStudyToday,
          onTap: onWalk,
          leading: CinematicGlyph.book,
          dense: true,
        ),
      ],
      if (ready) ...[
        const SizedBox(height: AppSpace.lg),
        CopperCta(
          label: l10n.juntosRoomChestOpen(bonus),
          onTap: onClaim,
          leading: CinematicGlyph.gift,
          trailing: null,
          dense: true,
        ),
      ],
    ];

    if (!showClock) {
      return ProfilePanel(
        accent: ready ? AppRoles.presence : AppRoles.lamp,
        lit: ready,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            title,
            const SizedBox(height: AppSpace.md),
            ...people,
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfilePanel(
          accent: _RoomClock.of(p).tone,
          lit: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: AppSpace.lg),
              _RoomClock(plan: p),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
        ProfilePanel(
          accent: ready ? AppRoles.presence : AppRoles.lamp,
          lit: ready,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: people,
          ),
        ),
      ],
    );
  }
}

class _TextInputDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String confirmLabel;
  final int maxLength;
  final bool capitalize;
  final double letterSpacing;
  final String initialValue;

  const _TextInputDialog({
    required this.title,
    required this.hint,
    required this.confirmLabel,
    required this.maxLength,
    this.capitalize = false,
    this.letterSpacing = 0,
    this.initialValue = '',
  });

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return AppDialog(
      title: widget.title,
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        textCapitalization: widget.capitalize
            ? TextCapitalization.characters
            : TextCapitalization.none,
        style: AppTypography.body(
          weight: widget.capitalize ? FontWeight.w800 : FontWeight.w500,
          color: a.text,
        ).copyWith(letterSpacing: widget.letterSpacing),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTypography.body(color: a.textFaint),
          counterStyle: AppTypography.body(size: 11, color: a.textFaint),
          filled: true,
          fillColor: a.cardFillSoft,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            borderSide: BorderSide(color: a.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            borderSide: BorderSide(color: a.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            borderSide: BorderSide(color: a.selected.withValues(alpha: 0.7)),
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        GhostCta(
          label: context.l10n.commonCancel,
          onTap: () => Navigator.pop(context),
        ),
        CopperCta(
          label: widget.confirmLabel,
          onTap: _submit,
          trailing: null,
          dense: true,
          showGlow: false,
        ),
      ],
    );
  }
}

class _LeaderboardBoard extends StatelessWidget {
  /// O trecho ([LeagueService.caravanWindow]): `entry == null` = `···`.
  final List<({LeagueEntry? entry, int rank})> rows;
  final int myRank;
  final int total;

  /// Quem passou por aqui hoje (sem o próprio usuário).
  final List<LeagueEntry> online;
  final LeagueEntry me;
  final VoidCallback? onOpenOwnProfile;

  /// Abre a Caravana inteira; `null` quando o cartão já mostra todos.
  final VoidCallback? onSeeAll;

  const _LeaderboardBoard({
    required this.rows,
    required this.myRank,
    required this.total,
    required this.online,
    required this.me,
    this.onOpenOwnProfile,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final people = [
      for (final r in rows)
        if (r.entry != null) r.entry!,
    ];
    final upToday = LeagueService.placesUpToday(people);
    final next = LeagueService.nextToPass(rows);
    final onlineNow = [
      if (me.isOnlineToday) (entry: me, rank: myRank),
      for (final p in online)
        (
          entry: p,
          rank: rows
              .firstWhere(
                (r) => r.entry?.uid == p.uid,
                orElse: () => (entry: null, rank: 0),
              )
              .rank,
        ),
    ];
    final countLabel = l10n.caravanHereToday(onlineNow.length);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 4, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.caravanYouRank(myRank, total),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(size: 14, color: a.text),
            ),
          ),
          if (onlineNow.isNotEmpty)
            Semantics(
              button: true,
              label: l10n.juntosOnlineSemantics(countLabel),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showCaravanOnlineSheet(
                    context,
                    people: onlineNow,
                    onOpenOwnProfile: onOpenOwnProfile,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 4, 8, 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AvatarCluster(
                          people: [
                            for (final p in onlineNow.take(4))
                              (
                                name: p.entry.name,
                                isUser: p.entry.isUser,
                                live: true,
                                photoUrl: p.entry.photoUrl,
                                seed: p.entry.uid ?? p.entry.name,
                                style: p.entry.portraitStyle,
                              ),
                          ],
                          radius: AppMetrics.avatarSm,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          countLabel,
                          style: AppTypography.label(
                            size: 10,
                            letterSpacing: 0,
                            color: AppRoles.presence,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final children = <Widget>[header];
    var person = 0;
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      final entry = r.entry;
      if (entry == null) {
        children.add(const _WindowGap());
        continue;
      }
      final nextRow = i + 1 < rows.length ? rows[i + 1].entry : null;
      children.add(
        _StandingRow(
          entry: entry,
          rank: r.rank,
          placesUpToday: upToday[person++],
          showDivider: nextRow != null && !nextRow.isUser && !entry.isUser,
          chase: entry.isUser
              ? (next == null
                    ? (myRank == 1 && total > 1 ? l10n.caravanLeading : null)
                    // Só o primeiro nome: a frase cabe numa linha.
                    : l10n.caravanNextToPass(
                        next.steps,
                        next.who.name.trim().split(RegExp(r'\s+')).first,
                      ))
              : null,
          onOpenOwnProfile: onOpenOwnProfile,
        ),
      );
    }
    if (onSeeAll != null) {
      children.addAll([
        const SizedBox(height: 4),
        GhostCta(
          label: l10n.caravanSeeAll,
          leading: CinematicGlyph.people,
          expanded: true,
          onTap: onSeeAll,
        ),
      ]);
    }

    return ProfilePanel(
      accent: AppRoles.navTogether,
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
      child: Column(children: children),
    );
  }
}

/// `···` entre o pódio e o seu trecho.
class _WindowGap extends StatelessWidget {
  const _WindowGap();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Center(
        child: Text(
          '···',
          style: AppTypography.title(
            size: 18,
            weight: FontWeight.w900,
            color: a.textFaint,
          ),
        ),
      ),
    );
  }
}

/// A Caravana inteira, de 20 em 20 (a sua linha aparece no lugar dela).
class _WholeCaravanScreen extends StatefulWidget {
  final LeagueEntry me;
  final VoidCallback? onOpenOwnProfile;

  const _WholeCaravanScreen({required this.me, this.onOpenOwnProfile});

  @override
  State<_WholeCaravanScreen> createState() => _WholeCaravanScreenState();
}

class _WholeCaravanScreenState extends State<_WholeCaravanScreen> {
  final _people = <LeagueEntry>[];
  final _scroll = ScrollController();
  Object? _cursor;
  bool _loading = false;
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) _more();
    });
    _more();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _more() async {
    if (_loading || _done) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await context.read<BackendService>().fetchCaravanPage(
        after: _cursor,
      );
      if (!mounted) return;
      final myUid = widget.me.uid;
      final blocked = ModerationService.instance;
      setState(() {
        for (final p in page.players) {
          if (blocked.isBlocked(p.uid)) continue;
          _people.add(
            p.uid == myUid ? widget.me : _LeagueScreenState._entryOf(p),
          );
        }
        _cursor = page.cursor;
        _done = page.cursor == null;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Página da Caravana falhou: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = context.l10n.juntosCaravanLoadError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final up = LeagueService.placesUpToday(_people);
    return Scaffold(
      backgroundColor: a.stageFill,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: a.text,
        title: Text(
          l10n.caravanWholeTitle,
          style: AppTypography.title(size: 17, color: a.text),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 24),
              itemCount: _people.length + 1,
              itemBuilder: (context, i) {
                if (i < _people.length) {
                  return _StandingRow(
                    entry: _people[i],
                    rank: i + 1,
                    placesUpToday: up[i],
                    showDivider: i < _people.length - 1,
                    onOpenOwnProfile: widget.onOpenOwnProfile,
                  );
                }
                if (_error != null) {
                  return InlineNotice(
                    message: _error!,
                    busy: _loading,
                    onRetry: _more,
                  );
                }
                if (_done) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpace.lg),
                    child: Center(
                      child: Text(
                        l10n.caravanWholeEnd,
                        style: AppTypography.label(color: a.textFaint),
                      ),
                    ),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.all(AppSpace.lg),
                  child: AppSpinner(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _showCaravanOnlineSheet(
  BuildContext context, {
  required List<({LeagueEntry entry, int rank})> people,
  VoidCallback? onOpenOwnProfile,
}) {
  ActHaptics.light();
  showAppSheet<void>(
    context,
    builder: (ctx) =>
        _CaravanOnlineSheet(people: people, onOpenOwnProfile: onOpenOwnProfile),
  );
}

class _CaravanOnlineSheet extends StatelessWidget {
  final List<({LeagueEntry entry, int rank})> people;
  final VoidCallback? onOpenOwnProfile;

  const _CaravanOnlineSheet({required this.people, this.onOpenOwnProfile});

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.72;
    final count = people.length;
    final subtitle = context.l10n.juntosCaravanPilgrimsCount(count);

    return AppSheetPanel(
      tint: AppRoles.presence,
      padding: const EdgeInsets.fromLTRB(10, AppSpace.md, 10, AppSpace.md),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: people.length + 1,
          separatorBuilder: (ctx, i) {
            if (i == 0) return const SizedBox(height: 4);
            return const ListDivider(indent: 12, endIndent: 12);
          },
          itemBuilder: (ctx, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: AppSheetHeader(
                  title: context.l10n.juntosStudyingNow,
                  subtitle: subtitle,
                ),
              );
            }
            final p = people[i - 1];
            return _OnlineSheetRow(
              entry: p.entry,
              rank: p.rank,
              onOpenOwnProfile: onOpenOwnProfile,
            );
          },
        ),
      ),
    );
  }
}

class _OnlineSheetRow extends StatelessWidget {
  final LeagueEntry entry;
  final int rank;
  final VoidCallback? onOpenOwnProfile;

  const _OnlineSheetRow({
    required this.entry,
    required this.rank,
    this.onOpenOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final walked = entry.walkedToday;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (entry.isUser) {
            Navigator.pop(context);
            onOpenOwnProfile?.call();
            return;
          }
          showCaravanPilgrimSheet(context, entry: entry, rank: rank);
        },
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          padding: const EdgeInsets.fromLTRB(8, 10, 10, 10),
          decoration: _youRowDecoration(entry.isUser, a),
          child: Row(
            children: [
              if (rank > 0) ...[
                _RankMark(rank: rank),
                const SizedBox(width: 10),
              ],
              UserAvatar(
                name: entry.name,
                radius: AppMetrics.avatarMd,
                borderColor: AppRoles.presence,
                photoUrl: entry.photoUrl,
                seed: entry.uid ?? entry.name,
                style: entry.portraitStyle,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 14, color: a.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      walked
                          ? context.l10n.juntosWalkedToday
                          : context.l10n.juntosSeenToday,
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w800,
                        color: walked ? AppRoles.presence : a.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.steps}',
                style: AppTypography.title(
                  size: 16,
                  weight: FontWeight.w900,
                  color: a.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final LeagueEntry entry;
  final int rank;

  /// Posições ganhas hoje (0 = sem seta).
  final int placesUpToday;
  final bool showDivider;
  final VoidCallback? onOpenOwnProfile;

  /// Na sua linha: quanto falta para passar quem está logo acima. Vai no
  /// lugar das medalhas.
  final String? chase;

  const _StandingRow({
    required this.entry,
    required this.rank,
    this.placesUpToday = 0,
    this.showDivider = false,
    this.onOpenOwnProfile,
    this.chase,
  });

  Color _stepsTone(AppearanceStyle a, Color? medal) => medal ?? a.text;

  String? _presenceShort(BuildContext context) {
    if (entry.walkedToday) return context.l10n.commonToday;
    final date = DateTime.tryParse(entry.lastWalkDate ?? '');
    if (date == null) return null;
    return DateFormat.Md(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final medal = switch (rank) {
      1 => AppColors.medalGold,
      2 => AppColors.medalSilver,
      3 => AppColors.medalBronze,
      _ => null,
    };
    final stepsTone = _stepsTone(a, medal);
    final muted = a.textFaint;
    final presence = _presenceShort(context);

    final live = entry.walkedToday || entry.isOnlineToday;

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RankMark(rank: rank),
            if (placesUpToday > 0)
              Semantics(
                label: context.l10n.leagueDriftUp(placesUpToday),
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CinematicIcon(
                      glyph: CinematicGlyph.rise,
                      size: 10,
                      accent: AppRoles.success,
                      framed: false,
                    ),
                    Text(
                      '$placesUpToday',
                      style: AppTypography.label(
                        size: 10,
                        letterSpacing: 0,
                        weight: FontWeight.w900,
                        color: AppRoles.success,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(width: 10),
        _MarkedAvatar(
          crown: rank == 1,
          plus: entry.plus,
          child: UserAvatar(
            name: entry.name,
            radius: 17,
            // Presença vence a medalha: o anel diz "estudou hoje".
            borderColor: live ? AppRoles.presence : medal,
            photoUrl: entry.photoUrl,
            seed: entry.uid ?? entry.name,
            style: entry.portraitStyle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.title(size: 14, color: a.text),
              ),
              if (chase != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    chase!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppRoles.success,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: _StandingMedalLine(entry: entry),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${entry.steps}',
              style: AppTypography.title(
                size: 16,
                weight: FontWeight.w900,
                color: stepsTone,
              ),
            ),
            if (presence != null)
              Text(
                presence,
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.2,
                  color: entry.walkedToday ? AppRoles.presence : muted,
                ),
              ),
          ],
        ),
      ],
    );

    final row = Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          padding: const EdgeInsets.fromLTRB(8, 7, 10, 7),
          decoration: entry.isUser
              ? _youRowDecoration(true, a)
              : BoxDecoration(
                  color: medal?.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
          child: content,
        ),
        if (showDivider) const ListDivider(indent: 14, endIndent: 14),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (entry.isUser) {
            onOpenOwnProfile?.call();
            return;
          }
          showCaravanPilgrimSheet(context, entry: entry, rank: rank);
        },
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: row,
      ),
    );
  }
}

/// Avatar da Caravana com as marcas: coroa em cima para quem lidera o mês
/// (a coroa é de liderança) e o selo + do Peregrino+ no canto, pequeno —
/// mostra quem apoia sem pesar mais que a posição.
class _MarkedAvatar extends StatelessWidget {
  final Widget child;
  final bool crown;
  final bool plus;

  const _MarkedAvatar({
    required this.child,
    this.crown = false,
    this.plus = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!crown && !plus) return child;
    final a = Appearance.of(context);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child,
        if (crown)
          Positioned(
            top: -13,
            child: Transform.rotate(
              angle: -0.18,
              child: CinematicIcon(
                glyph: CinematicGlyph.crown,
                size: 18,
                accent: AppColors.medalGold,
                framed: false,
              ),
            ),
          ),
        if (plus)
          Positioned(
            right: -3,
            bottom: -3,
            child: Semantics(
              label: context.l10n.pilgrimBadge,
              child: Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppRoles.reward,
                  border: Border.all(color: a.cardFill, width: 1.5),
                ),
                child: const Center(
                  child: CinematicIcon(
                    glyph: CinematicGlyph.plus,
                    size: 11,
                    accent: AppColors.inkOnAccent,
                    framed: false,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Só os discos — o ouro já conta as medalhas, sem “2 raras”.
class _StandingMedalLine extends StatelessWidget {
  final LeagueEntry entry;

  const _StandingMedalLine({required this.entry});

  @override
  Widget build(BuildContext context) {
    // O cache é por uid (não muda com o progresso): ler basta — watch
    // reconstruía cada linha da classificação a cada resposta.
    final progress = context.read<ProgressService>();
    final backend = context.read<BackendService>();
    final uid = entry.isUser ? (backend.uid ?? '') : (entry.uid ?? '');

    return FutureBuilder<({List<PilgrimMedalDef> rares, int total})>(
      future: MedalEngagementService.standingMedalsCached(
        isUser: entry.isUser,
        uid: uid,
        name: entry.name,
        progress: progress,
        backend: backend,
      ),
      builder: (context, snapshot) {
        final rares = snapshot.data?.rares ?? const <PilgrimMedalDef>[];
        final total = snapshot.data?.total ?? 0;
        if (rares.isEmpty && total <= 0) return const SizedBox.shrink();

        final shown = rares.take(3).toList();
        final extraRares = rares.length - shown.length;

        return _MedalStack(
          glyphs: [
            if (shown.isEmpty)
              (glyph: CinematicGlyph.gem, accent: AppColors.medalGold),
            for (final def in shown)
              (
                glyph: def.glyph,
                accent: MedalEngagementService.tierColor(def.tier),
              ),
          ],
          extra: extraRares > 0 ? extraRares : null,
        );
      },
    );
  }
}

class _MedalStack extends StatelessWidget {
  final List<({CinematicGlyph glyph, Color accent})> glyphs;
  final int? extra;

  const _MedalStack({required this.glyphs, this.extra});

  @override
  Widget build(BuildContext context) {
    const size = 18.0;
    const overlap = 12.0;
    final extraSlot = extra != null ? 1 : 0;
    final count = glyphs.length + extraSlot;
    if (count == 0) return const SizedBox.shrink();

    return SizedBox(
      width: size + (count - 1) * overlap,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < glyphs.length; i++)
            Positioned(
              left: i * overlap,
              child: _MedalDisc(
                glyph: glyphs[i].glyph,
                accent: glyphs[i].accent,
              ),
            ),
          if (extra != null)
            Positioned(
              left: glyphs.length * overlap,
              child: _MedalDisc(
                glyph: CinematicGlyph.gem,
                accent: AppColors.medalGold,
                overlay: '+$extra',
              ),
            ),
        ],
      ),
    );
  }
}

class _MedalDisc extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color accent;
  final String? overlay;

  const _MedalDisc({required this.glyph, required this.accent, this.overlay});

  @override
  Widget build(BuildContext context) {
    // A medalha do app em miniatura; "+N" vai gravado num disco de ouro.
    if (overlay == null) {
      return MedalArt(metal: accent, size: 18, glyph: glyph);
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        const MedalArt(metal: AppColors.accent, size: 18),
        Text(
          overlay!,
          style: AppTypography.label(
            size: 8,
            letterSpacing: 0,
            weight: FontWeight.w900,
            color: AppColors.inkOnAccent,
          ),
        ),
      ],
    );
  }
}

/// "Você" na lista — a mesma marca em Caravana, Grupos e na folha de quem
/// está online: fundo claro a 0.08 e contorno a 0.4 (nunca placa dourada).
BoxDecoration? _youRowDecoration(bool isUser, AppearanceStyle a) {
  if (!isUser) return null;
  return BoxDecoration(
    color: a.selected.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(AppRadii.md),
    border: Border.all(color: a.selected.withValues(alpha: 0.4)),
  );
}

class _RankMark extends StatelessWidget {
  final int rank;

  const _RankMark({required this.rank});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final medal = switch (rank) {
      1 => AppColors.medalGold,
      2 => AppColors.medalSilver,
      3 => AppColors.medalBronze,
      _ => null,
    };

    if (medal == null) {
      return SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: Text(
            '$rank',
            textAlign: TextAlign.center,
            style: AppTypography.title(
              size: rank >= 10 ? 12 : 14,
              color: a.textFaint,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: medal,
        boxShadow: [
          BoxShadow(
            color: medal.withValues(alpha: 0.38),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$rank',
          style: AppTypography.title(
            size: 14,
            weight: FontWeight.w900,
            color: AppColors.medalInk,
          ),
        ),
      ),
    );
  }
}

class _AvatarCluster extends StatelessWidget {
  final List<
    ({
      String name,
      bool isUser,
      bool live,
      String? photoUrl,
      String? seed,
      PortraitStyle style,
    })
  >
  people;
  final double radius;

  const _AvatarCluster({
    required this.people,
    this.radius = AppMetrics.avatarSm,
  });

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();
    final shown = people.take(5).toList();
    final size = radius * 2;
    final step = size * 0.62;
    return SizedBox(
      width: size + (shown.length - 1) * step,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * step,
              child: UserAvatar(
                name: shown[i].name,
                radius: radius,
                borderColor: shown[i].live ? AppRoles.presence : null,
                photoUrl: shown[i].photoUrl,
                seed: shown[i].seed,
                style: shown[i].style,
              ),
            ),
        ],
      ),
    );
  }
}

/// Visitante em Juntos: a Caravana, a companhia e os grupos vivem na
/// conta. Um convite, não um erro.
class _GuestJuntosCard extends StatelessWidget {
  final String reason;

  const _GuestJuntosCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Convite: borda e luz douradas (ação), o recado na fala do Anan.
    return ProfilePanel(
      accent: AppRoles.reward,
      lit: true,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        AppSpace.xl,
        AppSpace.lg,
        AppSpace.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnanSpeech(
            face: CloudFace.feliz,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.juntosGuestTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.display(
                    size: 24,
                    color: AnanSpeechBubble.ink,
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                Text(
                  l10n.juntosGuestBody,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    size: 14,
                    height: 1.45,
                    color: AnanSpeechBubble.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          CopperCta(
            label: l10n.juntosGuestCta,
            onTap: () => GuestGate.requireAccount(context, reason: reason),
            trailing: null,
            dense: true,
          ),
        ],
      ),
    );
  }
}

class _CompanionsOfflineCard extends StatelessWidget {
  final String? error;
  final bool loading;
  final VoidCallback onRetry;

  const _CompanionsOfflineCard({
    this.error,
    this.loading = false,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // EmptyState já traz o próprio respiro — o card não soma padding.
    return ProfilePanel(
      accent: AppRoles.risk,
      padding: EdgeInsets.zero,
      child: EmptyState(
        mark: CloudMascot(
          face: loading ? CloudFace.carregando : CloudFace.erro,
          size: 96,
        ),
        title: context.l10n.juntosCompanionsOfflineTitle,
        body: error ?? context.l10n.juntosCompanionsOfflineBody,
        action: CopperCta(
          label: loading
              ? context.l10n.juntosConnecting
              : context.l10n.commonTryAgain,
          onTap: loading ? null : onRetry,
          busy: loading,
          leading: CinematicGlyph.refresh,
          trailing: null,
          dense: true,
        ),
      ),
    );
  }
}

class _CompanionCard extends StatelessWidget {
  final WalkCompanion companion;
  final String myName;
  final VoidCallback onLeave;
  final VoidCallback onShowQr;
  final VoidCallback? onNudge;

  /// Convite aberto: chamar alguém da Caravana e quem já foi chamado.
  final VoidCallback onCall;
  final String? calledName;

  const _CompanionCard({
    required this.companion,
    required this.myName,
    required this.onLeave,
    required this.onShowQr,
    required this.onCall,
    this.calledName,
    this.onNudge,
  });

  @override
  Widget build(BuildContext context) {
    final myPhoto = context.select((BackendService b) => b.userPhotoUrl);
    final myUid = context.select((BackendService b) => b.uid);
    final myStyle = context.select(
      (ProgressService p) => p.settings.portraitStyle,
    );
    if (companion.awaitingPartner) {
      return _OpenInviteStage(
        myName: myName,
        myPhoto: myPhoto,
        mySeed: myUid ?? myName,
        myStyle: myStyle,
        onShowQr: onShowQr,
        onLeave: onLeave,
        onCall: onCall,
        calledName: calledName,
      );
    }

    final l10n = context.l10n;
    final a = Appearance.of(context);
    final partnerName = companion.partnerFirstName;
    final away = companion.theyDaysAway;
    final canNudge =
        onNudge != null &&
        (companion.waitingOnThem || (away != null && away >= 1));
    final both = companion.bothWalkedToday;
    final yourTurn = companion.waitingOnMe;
    // Hoje numa frase só: quem falta, quem já foi, quanto tempo parado.
    final statusTone = both
        ? AppRoles.success
        : yourTurn
        ? AppRoles.presence
        : a.textSecondary;

    // Dois cards: o palco (os dois, a semana, o marco) e, embaixo, o dia —
    // a frase de hoje, as ações para o outro e o sair.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfilePanel(
          // Os dois caminharam: o palco acende em verde. Sua vez: a moldura
          // chama mais forte, como o risco da Home.
          accent: both ? AppRoles.success : AppRoles.presence,
          lit: both || yourTurn,
          padding: AppMetrics.cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Os dois nas pontas e a semana acendendo entre eles — o
              // mesmo palco vivo do Desafio, com o elo no meio.
              _CompanionRace(
                companion: companion,
                myName: myName.trim().isEmpty
                    ? l10n.commonYou
                    : myName.trim().split(' ').first,
                myPhoto: myPhoto,
                mySeed: myUid ?? myName,
                myStyle: myStyle,
              ),
              const SizedBox(height: AppSpace.lg),
              const ListDivider(),
              const SizedBox(height: AppSpace.md),
              _CompanionWeekStrip(companion: companion),
              const SizedBox(height: AppSpace.lg),
              _CompanionMilestonesBlock(companion: companion),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
        ProfilePanel(
          accent: both ? AppRoles.success : AppRoles.lamp,
          // Rodapé com TextCta (sair) — ele já traz o próprio respiro.
          padding: AppMetrics.cardPadding.copyWith(bottom: AppSpace.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                companion.statusLine,
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  size: 13,
                  height: 1.35,
                  weight: FontWeight.w700,
                  color: statusTone,
                ),
              ),
              if (companion.hasIncomingNudge) ...[
                const SizedBox(height: AppSpace.md),
                _IncomingNudgeBanner(companion: companion),
              ],
              if (canNudge) ...[
                const SizedBox(height: AppSpace.md),
                // Acenar e reconhecer lado a lado: as duas ações para o outro.
                Row(
                  children: [
                    Expanded(
                      child: CopperCta(
                        label: companion.iNudgedToday
                            ? l10n.commonSendWhatsApp
                            : l10n.juntosWaveAt(partnerName),
                        onTap: onNudge,
                        leading: companion.iNudgedToday
                            ? CinematicGlyph.share
                            : CinematicGlyph.lamp,
                        trailing: null,
                        dense: true,
                      ),
                    ),
                    if (companion.theyLastWalkDate != null)
                      RecognizeHeartButton(
                        toUid: companion.partnerUid,
                        kind: RecognitionKind.walk,
                        subjectKey: companion.theyLastWalkDate!,
                        padding: const EdgeInsets.only(left: AppSpace.sm),
                      ),
                  ],
                ),
              ] else
                RecognizeCompanionWalk(
                  partnerUid: companion.partnerUid,
                  walkDate: companion.theyLastWalkDate,
                ),
              const SizedBox(height: AppSpace.xs),
              Center(
                child: TextCta(
                  label: l10n.juntosLeaveCompanionCta,
                  danger: true,
                  onTap: onLeave,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Palco da companhia — o mesmo do Desafio na Home: você e o outro nas
/// pontas, 7 traços de cada lado acesos do retrato para o meio (os dias que
/// cada um caminhou na semana) e o marco respirando no centro, aceso quando
/// os dois caminharam hoje.
class _CompanionRace extends StatelessWidget {
  final WalkCompanion companion;
  final String myName;
  final String? myPhoto;
  final String mySeed;
  final PortraitStyle myStyle;

  const _CompanionRace({
    required this.companion,
    required this.myName,
    required this.myPhoto,
    required this.mySeed,
    required this.myStyle,
  });

  @override
  Widget build(BuildContext context) {
    final c = companion;
    final mine = context.select((ProgressService p) => p.playDates);
    final now = DateTime.now();
    final todayIdx = now.weekday - 1;
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: todayIdx));
    var meDays = 0;
    var themDays = 0;
    for (var i = 0; i <= todayIdx; i++) {
      final day = c.presenceOn(
        monday.add(Duration(days: i)),
        now: now,
        alsoMine: mine,
      );
      // Hoje vem do estado ao vivo (o mapa da semana pode atrasar um sync).
      if (day.me || (i == todayIdx && c.iWalkedToday)) meDays++;
      if (day.them || (i == todayIdx && c.theyWalkedToday)) themDays++;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BondMember(
          name: myName,
          walked: c.iWalkedToday,
          highlight: c.waitingOnMe,
          isUser: true,
          photoUrl: myPhoto,
          seed: mySeed,
          style: myStyle,
        ),
        Expanded(
          child: SizedBox(
            height: 68,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Center(
                    child: RaceDashes(
                      left: meDays,
                      right: themDays,
                      leftTone: AppRoles.presence,
                      rightTone: AppRoles.presence,
                    ),
                  ),
                ),
                // O Anan no meio da dupla: comemora quando os dois foram,
                // sorri com um já no caminho, entristece com o outro sumido.
                CloudMascot(
                  face: c.bothWalkedToday
                      ? CloudFace.sucesso
                      : c.theyAreDusty
                      ? CloudFace.triste
                      : (c.iWalkedToday || c.theyWalkedToday)
                      ? CloudFace.feliz
                      : CloudFace.carregando,
                  size: 64,
                ),
              ],
            ),
          ),
        ),
        _BondMember(
          name: c.displayName.isEmpty
              ? context.l10n.juntosCompanionFallback
              : c.partnerFirstName,
          walked: c.theyWalkedToday,
          highlight: c.waitingOnThem,
          dusty: c.theyAreDusty,
          seed: c.displayName,
        ),
      ],
    );
  }
}

/// Uma ponta do fio: retrato com halo (aceso se caminhou hoje), nome e
/// uma palavra de estado.
class _BondMember extends StatelessWidget {
  /// Largura da coluna (retrato + nome).
  static const double width = 88;

  final String name;
  final bool walked;
  final bool highlight;
  final bool dusty;
  final bool isUser;
  final String? photoUrl;
  final String? seed;
  final PortraitStyle style;

  const _BondMember({
    required this.name,
    required this.walked,
    required this.highlight,
    this.dusty = false,
    this.isUser = false,
    this.photoUrl,
    this.seed,
    this.style = PortraitStyle.photo,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final status = walked
        ? l10n.commonToday
        : dusty
        ? l10n.juntosBondNotStudying
        : (highlight ? l10n.juntosBondYourTurn : l10n.juntosBondNotYet);
    // Estudou hoje e a sua vez = azul da nuvem. Parado = apagado.
    final tone = walked || highlight ? AppRoles.presence : a.textFaint;

    Widget avatar = UserAvatar(
      name: name,
      radius: AppMetrics.avatarLg,
      borderColor: isUser ? a.selected.withValues(alpha: 0.55) : null,
      photoUrl: photoUrl,
      seed: seed ?? name,
      style: style,
    );

    if (dusty) {
      avatar = HeroCardColorGrade(mood: HeroCardMood.dusty, child: avatar);
    }

    return SizedBox(
      width: width,
      child: Column(
        children: [
          JuntosHalo(
            size: AppMetrics.avatarLg * 2,
            lit: walked || highlight,
            color: walked ? AppRoles.presence : AppRoles.risk,
            child: avatar,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 14, color: a.text),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: AppTypography.label(
              size: 11,
              letterSpacing: 0.2,
              weight: FontWeight.w700,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }
}

/// Convite aberto: você de um lado, um lugar vazio do outro — e o código.
/// Convite aberto: o palco no card e, embaixo dele, as ações — mesmo
/// arranjo do Grupo (o código mora na folha do QR).
class _OpenInviteStage extends StatelessWidget {
  final String myName;
  final String? myPhoto;
  final String mySeed;
  final PortraitStyle myStyle;
  final VoidCallback onShowQr;
  final VoidCallback onLeave;
  final VoidCallback onCall;

  /// Quem foi chamado pelo nome (convite direto pendente).
  final String? calledName;

  const _OpenInviteStage({
    required this.myName,
    required this.myPhoto,
    required this.mySeed,
    required this.myStyle,
    required this.onShowQr,
    required this.onLeave,
    required this.onCall,
    this.calledName,
  });

  @override
  Widget build(BuildContext context) {
    final myLabel = myName.trim().isEmpty
        ? context.l10n.commonYou
        : myName.trim().split(' ').first;
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfilePanel(
          accent: AppRoles.lamp,
          padding: AppMetrics.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(
                label: context.l10n.juntosOpenInvite,
                trailing: SoftBadge(
                  text: context.l10n.juntosWaiting,
                  glyph: CinematicGlyph.lamp,
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BondMember(
                    name: myLabel,
                    walked: false,
                    highlight: false,
                    isUser: true,
                    photoUrl: myPhoto,
                    seed: mySeed,
                    style: myStyle,
                  ),
                  const Expanded(
                    child: _WaitingThread(face: CloudFace.carregando),
                  ),
                  const _EmptySeat(),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                calledName == null
                    ? context.l10n.juntosOpenInviteMissing
                    : context.l10n.companionInviteCalled(
                        calledName!.trim().split(' ').first,
                      ),
                textAlign: TextAlign.center,
                style: AppTypography.title(size: 16, color: a.text),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
        CopperCta(
          label: context.l10n.juntosShowQrShare,
          onTap: onShowQr,
          leading: CinematicGlyph.share,
          trailing: null,
          dense: true,
        ),
        const SizedBox(height: AppSpace.sm),
        GhostCta(
          label: context.l10n.juntosCallFromCaravan,
          leading: CinematicGlyph.people,
          expanded: true,
          onTap: onCall,
        ),
        const SizedBox(height: AppSpace.sm),
        GhostCta(
          label: context.l10n.juntosCancelInvite,
          leading: CinematicGlyph.close,
          danger: true,
          expanded: true,
          onTap: onLeave,
        ),
      ],
    );
  }
}

/// Fio ainda apagado entre você e o lugar vazio, com o Anan no meio:
/// triste sem companhia; esperando (carregando) com o convite aberto.
class _WaitingThread extends StatelessWidget {
  final CloudFace face;

  const _WaitingThread({required this.face});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const BondThread(state: BondState.none),
          CloudMascot(face: face, size: 68),
        ],
      ),
    );
  }
}

/// Lugar vazio da dupla — anel tracejado que respira com um “?”.
class _EmptySeat extends StatelessWidget {
  const _EmptySeat();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return SizedBox(
      width: 88,
      child: Column(
        children: [
          JuntosHalo(
            size: AppMetrics.avatarLg * 2,
            lit: true,
            color: a.textFaint,
            child: Container(
              width: AppMetrics.avatarLg * 2,
              height: AppMetrics.avatarLg * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: a.insetFill,
              ),
              child: Center(
                child: Text(
                  '?',
                  style: AppTypography.display(size: 28, color: a.textFaint),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.juntosWho,
            style: AppTypography.title(size: 14, color: a.textFaint),
          ),
        ],
      ),
    );
  }
}

/// Código de convite, tocável para copiar — o mesmo poço e a mesma letra
/// para dupla e grupo. [compact]: chip ao lado do convite do grupo.
/// Faixa da semana — embutida no card da dupla.
class _CompanionWeekStrip extends StatelessWidget {
  final WalkCompanion companion;

  const _CompanionWeekStrip({required this.companion});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final mine = context.select((ProgressService p) => p.playDates);
    final now = DateTime.now();
    final todayIdx = now.weekday - 1; // seg=0
    final together = companion.bothWalkedThisWeek(alsoMine: mine);
    final narrow = DateFormat(
      'EEEEE',
      Localizations.localeOf(context).toLanguageTag(),
    );
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: todayIdx));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SectionLabel(context.l10n.juntosThisWeek),
            const Spacer(),
            Text(
              context.l10n.juntosTogetherOfSeven(together),
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w800,
                color: a.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < 7; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: _WeekDot(
                  label: narrow.format(monday.add(Duration(days: i))),
                  presence: companion.presenceOn(
                    monday.add(Duration(days: i)),
                    now: now,
                    alsoMine: mine,
                  ),
                  isToday: i == todayIdx,
                  future: i > todayIdx,
                  style: a,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        // Sem legenda, meia bolinha não se lê: diz quem é cada metade.
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _WeekLegend(
              me: true,
              them: false,
              label: context.l10n.commonYou,
              style: a,
            ),
            _WeekLegend(
              me: false,
              them: true,
              label: companion.partnerFirstName,
              style: a,
            ),
            _WeekLegend(
              me: true,
              them: true,
              label: context.l10n.juntosTogetherLegend,
              style: a,
            ),
          ],
        ),
      ],
    );
  }
}

class _WeekLegend extends StatelessWidget {
  final bool me;
  final bool them;
  final String label;
  final AppearanceStyle style;

  const _WeekLegend({
    required this.me,
    required this.them,
    required this.label,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CustomPaint(
            painter: _SplitDayPainter(
              me: me,
              them: them,
              isToday: false,
              empty: style.cardFillSoft,
              border: AppRoles.presence.withValues(alpha: 0.55),
              legend: true,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.body(
            size: 12,
            weight: FontWeight.w700,
            color: style.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CompanionMilestonesBlock extends StatelessWidget {
  final WalkCompanion companion;

  const _CompanionMilestonesBlock({required this.companion});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final shared = companion.sharedDays;
    final next = companion.nextMilestone;
    final marks = WalkCompanion.milestones;
    final l10n = context.l10n;
    final caption = shared == 0
        ? l10n.juntosFirstMilestone(next)
        : shared >= marks.last
        ? l10n.juntosNextMilestone(next)
        : l10n.juntosMilestoneLeft(next - shared, next);

    // Mesmo idioma do próximo marco da sequência no perfil: frase + barra.
    return Semantics(
      label: '$caption · $shared/$next',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  caption,
                  style: AppTypography.body(
                    size: 13,
                    weight: FontWeight.w800,
                    color: a.text,
                  ),
                ),
              ),
              Text(
                '$shared/$next',
                style: AppTypography.label(
                  size: 11,
                  color: shared > 0 ? AppRoles.presence : a.textFaint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RelicProgress(
            value: companion.milestoneProgress,
            accent: AppRoles.presence,
          ),
        ],
      ),
    );
  }
}

/// Dia da dupla — mesmo idioma do "Esta semana" do perfil: cheio com
/// check quando os dois caminharam, meia bolinha quando só um, anel em
/// hoje, apagado no futuro.
class _WeekDot extends StatelessWidget {
  final String label;
  final CompanionDayPresence presence;
  final bool isToday;
  final bool future;
  final AppearanceStyle style;

  const _WeekDot({
    required this.label,
    required this.presence,
    required this.isToday,
    required this.future,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final both = presence.me && presence.them;
    const size = 34.0;
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _SplitDayPainter(
                me: presence.me,
                them: presence.them,
                isToday: isToday,
                empty: future
                    ? Colors.transparent
                    : style.text.withValues(alpha: 0.07),
                border: isToday
                    ? style.selected
                    : future
                    ? style.text.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
              child: both
                  ? const Center(
                      child: CinematicIcon(
                        glyph: CinematicGlyph.check,
                        size: AppMetrics.iconSm,
                        accent: AppColors.night,
                        framed: false,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isToday ? context.l10n.commonToday : label,
          style: AppTypography.body(
            size: 11,
            weight: FontWeight.w800,
            color: isToday
                ? style.text
                : (future ? style.textFaint : style.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Bolinha da semana: metade esquerda é você, metade direita é o parceiro;
/// os dois = disco inteiro de presença, com brilho.
class _SplitDayPainter extends CustomPainter {
  final bool me;
  final bool them;
  final bool isToday;
  final Color empty;
  final Color border;

  /// Miniatura da legenda: sem brilho, traço fino.
  final bool legend;

  const _SplitDayPainter({
    required this.me,
    required this.them,
    required this.isToday,
    required this.empty,
    required this.border,
    this.legend = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final both = me && them;

    if (both && !legend) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppRoles.presence.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    canvas.drawCircle(center, radius, Paint()..color = empty);

    final fill = Paint()..color = AppRoles.presence;
    if (both) {
      canvas.drawCircle(center, radius, fill);
    } else if (me || them) {
      // Metade pintada até a borda; a outra fica com um contorno leve.
      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      );
      canvas.drawRect(
        me
            ? Rect.fromLTRB(0, 0, center.dx, size.height)
            : Rect.fromLTRB(center.dx, 0, size.width, size.height),
        fill,
      );
      canvas.restore();
      canvas.drawCircle(
        center,
        radius - 0.6,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = legend ? 1 : 1.2
          ..color = AppRoles.presence.withValues(alpha: 0.7),
      );
    }

    if (isToday && !both) {
      canvas.drawCircle(
        center,
        radius - 1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = border,
      );
    } else if (!both && !(me || them) && border != Colors.transparent) {
      canvas.drawCircle(
        center,
        radius - 0.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = border,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplitDayPainter old) =>
      me != old.me ||
      them != old.them ||
      isToday != old.isToday ||
      empty != old.empty ||
      border != old.border ||
      legend != old.legend;
}

class _IncomingNudgeBanner extends StatelessWidget {
  final WalkCompanion companion;

  const _IncomingNudgeBanner({required this.companion});

  @override
  Widget build(BuildContext context) {
    final from = companion.incomingNudgeFromName?.trim().isNotEmpty == true
        ? companion.incomingNudgeFromName!.trim().split(' ').first
        : context.l10n.juntosCompanionFallback;
    final raw = companion.incomingNudgeMessage?.trim();
    // Texto escrito por outra pessoa: o filtro vale também na chegada.
    final message = raw != null && ContentFilter.isAllowed(raw) ? raw : null;
    final partnerUid = companion.partnerUid;
    final a = Appearance.of(context);
    return InsetPanel(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.lamp,
            size: AppMetrics.iconLg,
            accent: a.place,
            framed: false,
            glowing: true,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.juntosWavedAtYou(from),
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                if (message != null && message.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      size: 13,
                      height: 1.3,
                      color: a.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Aceno é texto de outra pessoa: denunciar e bloquear à mão
          // (App Store 1.2). Bloqueado some na próxima leitura.
          if (partnerUid != null && partnerUid.isNotEmpty)
            UserModerationButton(
              uid: partnerUid,
              name: from,
              source: UserReportSource.companion,
              onDone: (outcome) {
                if (outcome == ModerationOutcome.blocked && context.mounted) {
                  context.read<CompanionService>().refresh();
                }
              },
            ),
        ],
      ),
    );
  }
}

class _CaravanEmptyCard extends StatelessWidget {
  const _CaravanEmptyCard();

  @override
  Widget build(BuildContext context) {
    // EmptyState já traz o próprio respiro — o card não soma padding.
    return ProfilePanel(
      accent: AppRoles.navTogether,
      padding: EdgeInsets.zero,
      child: EmptyState(
        title: context.l10n.juntosCaravanEmptyTitle,
        body: context.l10n.juntosCaravanEmptyBody,
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onTap;

  const _MenuButton({required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ActHaptics.tap();
            onTap();
          },
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: CinematicIcon(
                glyph: CinematicGlyph.more,
                size: AppMetrics.iconMd,
                accent: a.textSecondary,
                framed: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
