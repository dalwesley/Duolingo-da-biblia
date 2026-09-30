import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_language.dart';
import '../models/corner_challenge.dart';
import '../models/pilgrim_medal_models.dart';
import '../models/study_room.dart';
import '../models/walk_companion.dart';
import '../services/backend_service.dart';
import '../services/medal_engagement_service.dart';
import '../services/progress_service.dart';
import '../services/companion_service.dart';
import '../services/corner_service.dart';
import '../services/invite_deep_link_service.dart';
import '../services/league_service.dart';
import '../services/remote_config_service.dart';
import '../services/room_service.dart';
import '../services/app_update_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/act_feel.dart';
import '../widgets/corner_board.dart';
import '../widgets/juntos_chrome.dart';
import '../widgets/juntos_inbox.dart';
import '../widgets/caravan_pilgrim_sheet.dart';
import '../widgets/accept_invite_sheet.dart';
import '../widgets/app_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/companion_formed_sheet.dart';
import '../widgets/companion_invite_confirm_sheet.dart';
import '../widgets/companion_nudge_sheet.dart';
import '../widgets/hero_card_atmosphere.dart';
import '../widgets/home_brand_backdrop.dart';
import '../widgets/icon_well.dart';
import '../widgets/immersive_background.dart';
import '../widgets/invite_qr_sheet.dart';
import '../widgets/shell_tab_scope.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/user_avatar.dart';
import '../widgets/recognition_actions.dart';
import '../widgets/room_roster.dart';
import '../widgets/room_panels.dart';
import 'lesson_screen.dart';

/// Altura comum quando CTA ouro e fantasma ficam lado a lado
/// (GhostCta tem mínimo de 48; o ouro denso, 44).
const double _pairedCtaHeight = 48;

class LeagueScreen extends StatefulWidget {
  final Widget? topBar;

  /// Quando a aba Juntos está visível — processa deep link pendente.
  final bool active;
  final VoidCallback? onOpenOwnProfile;

  /// Abre uma missão (desafio do canto) e volta para a missão de hoje
  /// (chamado de companhia) — as novidades que saíram da Home.
  final ValueChanged<String>? onOpenMission;
  final VoidCallback? onGoToday;

  const LeagueScreen({
    super.key,
    this.topBar,
    this.active = true,
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
  List<LeagueEntry> _realPlayers = const [];
  List<LeagueEntry> _overallPlayers = const [];

  /// Variante A: Companhia primeiro (fosso), depois Caravana, depois Grupos.
  static const _tabCompanhia = 0;
  static const _tabCaravana = 1;
  static const _tabGrupos = 2;

  int _tab = _tabCompanhia;
  int _companhiaPane = 0; // 0 = amizade, 1 = desafio
  int _caravanPane = 0; // 0 = mês, 1 = semana
  bool _handlingInvite = false;
  bool _playersLoading = false;
  bool _playersLoadedOnce = false;
  String? _playersError;
  final Set<String> _inviteBusy = {};
  Future<void>? _settleInFlight;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: AppMotion.scene,
    )..forward();
    InviteDeepLinkService.instance.addListener(_onPendingInvite);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settle();
      if (widget.active) _consumePendingInvite();
    });
  }

  @override
  void didUpdateWidget(covariant LeagueScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _consumePendingInvite();
      // Recarrega ranking ao abrir a aba — evita lista vazia se o 1º fetch
      // rodou antes do backend estar pronto ou falhou em silêncio.
      _settle();
    }
  }

  void _onPendingInvite() {
    if (!mounted || !widget.active) return;
    _consumePendingInvite();
  }

  Future<void> _consumePendingInvite() async {
    if (!mounted || _handlingInvite) return;
    final links = InviteDeepLinkService.instance;
    final roomCode = links.takePendingRoomCode();
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
    if (links.takeWantCompanhiaTab()) {
      setState(() {
        _tab = _tabCompanhia;
        _companhiaPane = 0;
      });
    }
    final code = links.takePendingCompanionCode();
    if (code == null) return;
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

      final week = LeagueService.weekKey();
      final groupCode = league.groupCode;
      final fetched = await Future.wait<List<CloudPlayer>>([
        groupCode != null
            ? backend.fetchGroupWeekPlayers(groupCode, week)
            : backend.fetchWeekPlayers(week, tier: league.tierIndex),
        backend.fetchMonthlyPlayers(),
      ]).timeout(const Duration(seconds: 12));
      final players = fetched[0];
      final overallPlayers = fetched[1];

      if (!mounted) return;
      setState(() {
        _realPlayers = [
          for (final p in players)
            LeagueEntry(
              uid: p.uid,
              name: p.name,
              steps: p.steps,
              lastWalkDate: p.lastWalkDate,
              lastSeenDate: p.lastSeenDate,
              photoUrl: p.photoUrl,
              portraitStyle: p.portraitStyle,
            ),
        ];
        _overallPlayers = [
          for (final p in overallPlayers)
            LeagueEntry(
              uid: p.uid,
              name: p.name,
              steps: p.steps,
              lastWalkDate: p.lastWalkDate,
              lastSeenDate: p.lastSeenDate,
              photoUrl: p.photoUrl,
              portraitStyle: p.portraitStyle,
            ),
        ];
        _playersLoading = false;
        _playersLoadedOnce = true;
        _playersError = null;
      });

      final weeklyRank = league.userRank(
        league.standings(
          userName: progress.userName,
          userWeeklySteps: progress.weeklySteps,
          userUid: backend.uid,
          userLastWalkDate: progress.lastPlayedDate,
          userPhotoUrl: backend.userPhotoUrl,
          realPlayers: _realPlayers,
        ),
      );
      if (weeklyRank > 0) {
        await league.observeWeeklyRank(weeklyRank);
      }

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
    final style = Appearance.of(context);
    final listen = tabListens;
    final companionNudge = listen
        ? context.watch<CompanionService>().incomingNudge
        : context.read<CompanionService>().incomingNudge;
    final cornerFace = listen
        ? context.watch<CornerService>().face
        : context.read<CornerService>().face;
    final roomIncoming = listen
        ? context.watch<RoomService>().incoming
        : context.read<RoomService>().incoming;
    return Stack(
      children: [
        // Trilha STWAY velada — lobby social (não cena).
        Positioned.fill(child: HomeBrandBackdrop(style: style)),
        RefreshIndicator(
          color: AppRoles.presence,
          onRefresh: _settle,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              AppSpace.screen,
              widget.topBar == null
                  ? AppSpace.sm
                  : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
              AppSpace.screen,
              scrollPaddingBelowNav(context),
            ),
            children: [
              if (widget.topBar != null) ...[
                widget.topBar!,
                const SizedBox(height: AppSpace.afterTopBar),
              ],
              _reveal(
                0,
                _SegmentTabs(
                  index: _tab,
                  caravanAlert: JuntosInbox.caravanPending(context) > 0,
                  companionAlert: companionNudge != null || cornerFace != null,
                  gruposAlert: roomIncoming.isNotEmpty,
                  onChanged: (i) {
                    ActHaptics.tap();
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
                  key: ValueKey(_tab),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: switch (_tab) {
                    _tabCompanhia => _buildCompanions(context),
                    _tabCaravana => [
                      JuntosInbox(
                        onOpenCaravana: () =>
                            setState(() => _tab = _tabCaravana),
                      ),
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
  }

  List<Widget> _buildLeague(BuildContext context) {
    // Só o que a classificação mostra do próprio peregrino.
    context.select(
      (ProgressService p) => (
        p.userName,
        p.weeklySteps,
        p.currentMonthSteps,
        p.lastPlayedDate,
        p.settings.portraitStyle,
      ),
    );
    final progress = context.read<ProgressService>();
    final league = context.watch<LeagueService>();

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
    final pane = _caravanPane.clamp(0, 1);
    final weekly = pane == 1;
    final children = <Widget>[
      _reveal(
        1,
        _CaravanStageCard(
          pane: pane,
          onPaneChanged: (value) =>
              setState(() => _caravanPane = value.clamp(0, 1)),
        ),
      ),
      const SizedBox(height: AppSpace.md),
    ];

    final weeklyEntries = league.standings(
      userName: progress.userName,
      userWeeklySteps: progress.weeklySteps,
      userUid: backend.uid,
      userLastWalkDate: progress.lastPlayedDate,
      userLastSeenDate: today,
      userPhotoUrl: backend.userPhotoUrl,
      userPortraitStyle: progress.settings.portraitStyle,
      realPlayers: _realPlayers,
    );
    final weeklyRank = league.userRank(weeklyEntries);
    final weeklyCompetitive = LeagueService.fieldIsCompetitive(
      _realPlayers.length,
    );
    if (weeklyRank > 0 && _playersLoadedOnce && weeklyCompetitive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<LeagueService>().observeWeeklyRank(weeklyRank);
      });
    }

    final entries = league.overallStandings(
      userName: progress.userName,
      userTotalSteps: progress.currentMonthSteps,
      userUid: backend.uid,
      userLastWalkDate: progress.lastPlayedDate,
      userLastSeenDate: today,
      userPhotoUrl: backend.userPhotoUrl,
      userPortraitStyle: progress.settings.portraitStyle,
      realPlayers: _overallPlayers,
    );
    final userRank = league.userRank(entries);
    if (userRank == 1 &&
        LeagueService.fieldIsCompetitive(_overallPlayers.length)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        progress.recordLeaderDay();
      });
    }

    final canPromote = league.tierIndex < LeagueTier.values.length - 1;
    final canDemote = league.tierIndex > 0;
    final overallCompetitive = LeagueService.fieldIsCompetitive(
      _overallPlayers.length,
    );

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
    } else if (entries.isNotEmpty) {
      children.add(
        _reveal(
          2,
          _LeaderboardBoard(
            entries: entries,
            weeklyEntries: weeklyEntries,
            weekly: weekly,
            weeklyCompetitive: weeklyCompetitive,
            canPromote: canPromote,
            canDemote: canDemote,
            tierIndex: league.tierIndex,
            onOpenOwnProfile: widget.onOpenOwnProfile,
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
    ]);

    return children;
  }

  List<Widget> _buildCompanions(BuildContext context) {
    final companions = context.watch<CompanionService>();
    final backend = context.watch<BackendService>();
    context.select((ProgressService p) => p.userName);
    final progress = context.read<ProgressService>();
    final corners = context.watch<CornerService>();
    final pane = _companhiaPane.clamp(0, 1);

    Widget? stageBody;
    if (pane == 0 && companions.isLoaded && companions.companions.isEmpty) {
      stageBody = const _AmizadeExplainer();
    } else if (pane == 1) {
      stageBody = const _DesafioExplainer();
    }

    final list = <Widget>[
      _reveal(
        1,
        _CompanhiaStageCard(
          pane: pane,
          companionAlert: companions.incomingNudge != null,
          desafioAlert: corners.face != null,
          onPaneChanged: (value) =>
              setState(() => _companhiaPane = value.clamp(0, 1)),
          body: stageBody,
        ),
      ),
      const SizedBox(height: AppSpace.md),
    ];

    if (pane == 1) {
      list.addAll(_desafioPane(context));
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

    if (companions.companions.isEmpty) {
      list.add(
        _reveal(
          2,
          _CompanionsEmpty(
            loading: companions.loading,
            onInvite: () => _createCompanion(context),
            onJoin: () => _joinCompanion(context),
          ),
        ),
      );
      return list;
    }

    for (var i = 0; i < ordered.length; i++) {
      list.add(
        _reveal(
          (2 + i).clamp(0, 8),
          _CompanionCard(
            companion: ordered[i],
            myName: progress.userName,
            onCopy: () async {
              await Clipboard.setData(ClipboardData(text: ordered[i].code));
              if (!context.mounted) return;
              showAppToastFor(
                context,
                message: context.l10n.juntosCodeCopied,
                glyph: CinematicGlyph.copy,
              );
            },
            onShowQr: () => showInviteQrSheet(
              context,
              code: ordered[i].code,
              inviterName: progress.userName,
            ),
            onNudge: () => showCompanionNudgeSheet(
              context,
              companion: ordered[i],
              myName: progress.userName,
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
  List<Widget> _desafioPane(BuildContext context) {
    return [
      CornerBoard(
        onOpenMission: widget.onOpenMission ?? (_) {},
        onOpenCaravana: () => setState(() => _tab = _tabCaravana),
      ),
      const SizedBox(height: AppSpace.md),
      CopperCta(
        label: CornerCopy.boardOpenCaravan,
        leading: CinematicGlyph.podium,
        trailing: null,
        onTap: () => setState(() => _tab = _tabCaravana),
      ),
    ];
  }

  Future<void> _shareCaravanInvite(BuildContext context) async {
    final name = context.read<ProgressService>().userName.trim();
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

  Future<void> _createCompanion(BuildContext context) async {
    final progress = context.read<ProgressService>();
    final service = context.read<CompanionService>();
    final created = await service.createInvite(progress);
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
      inviterName: progress.userName,
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

    if (!rooms.hasRoom) {
      return [
        for (final invite in incoming) ...[
          _reveal(1, _incomingInviteCard(context, invite)),
          const SizedBox(height: AppSpace.md),
        ],
        _reveal(
          1,
          _RoomsEmptyState(
            loading: rooms.loading,
            error: rooms.lastError,
            onCreate: () => _showCreateRoom(context),
            onJoin: () => _showJoinRoom(context),
          ),
        ),
      ];
    }

    final room = rooms.activeRoom!;
    final members = rooms.members;
    void shareRoom() => showInviteQrSheet(
      context,
      code: room.code,
      title: room.name,
      subtitle: context.l10n.juntosRoomQrSubtitle,
      companionMode: false,
      inviterName: progress.userName,
      shareMessage: context.l10n.juntosRoomShareText(
        room.name,
        InviteDeepLinkService.roomHttpsUrl(room.code),
        room.code,
        AppUpdateService.androidStoreUrl,
      ),
    );
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
    final study = rooms.currentStudy;

    return [
      for (final invite in incoming) ...[
        _reveal(1, _incomingInviteCard(context, invite)),
        const SizedBox(height: AppSpace.md),
      ],
      _reveal(
        2,
        _RoomHearth(
          room: room,
          members: members,
          isOwner: isLeader,
          walkedToday: progress.walkedToday,
          onMenu: () => _openRoomMenu(context),
          onClaim: () => _claimRoomChest(context, room.code),
          // Estudo pendente: o card logo abaixo já chama para ele.
          onWalk:
              study != null &&
                  !members.any((m) => m.isUser && m.didStudy(study))
              ? null
              : widget.onGoToday,
          onSeatTap: (m) => _showRoomSeat(context, m),
        ),
      ),
      const SizedBox(height: AppSpace.md),
      _reveal(
        2,
        _RoomInviteBar(
          code: room.code,
          full: rooms.isFull,
          onCall: callPeople,
          onCopy: () => _copyRoomCode(context, room.code),
        ),
      ),
      const SizedBox(height: AppSpace.md),
      _reveal(
        2,
        RoomStudyCard(
          room: room,
          study: study,
          members: members,
          isLeader: isLeader,
          onPick: () => _pickRoomStudy(context),
          onOpen: () => _openRoomStudy(context, study),
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

  List<LeagueEntry> _caravanPeople(String? myUid) {
    final seen = <String>{};
    final people = <LeagueEntry>[];
    for (final person in [..._realPlayers, ..._overallPlayers]) {
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
    final setup = await showRoomSetupSheet(context);
    if (setup == null || !context.mounted) return;
    final ok = await context.read<RoomService>().createRoom(
      setup.name,
      context.read<ProgressService>(),
      kind: setup.kind,
    );
    if (!context.mounted) return;
    if (ok) {
      showAppToastFor(
        context,
        message: context.l10n.juntosRoomCreated(
          context.read<RoomService>().activeCode ?? '',
        ),
        glyph: CinematicGlyph.people,
      );
    }
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
    final canCall =
        !m.isUser && !m.walkedToday() && !rooms.nudgedToday.contains(m.uid);
    final call = await showRoomSeatSheet(
      context,
      member: m,
      status: seatLabel(m),
      isLeader: m.uid == rooms.activeRoom?.ownerId,
      leaderTitle:
          rooms.activeRoom?.kind.leaderTitle ?? context.l10n.juntosLeader,
      study: rooms.currentStudy,
      canCall: canCall,
      alreadyCalled: rooms.nudgedToday.contains(m.uid),
    );
    if (call == true && context.mounted) {
      await _nudgeRoomMember(context, m);
    }
  }

  Future<void> _copyRoomCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    showAppToastFor(
      context,
      message: context.l10n.juntosCodeCopied,
      glyph: CinematicGlyph.copy,
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

  Future<void> _nudgeRoomMember(BuildContext context, RoomMember m) async {
    final ok = await context.read<RoomService>().nudge(
      m,
      context.read<ProgressService>(),
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
    final progress = context.read<ProgressService>();
    final room = rooms.activeRoom;
    if (room == null) return;
    final isLeader = room.isOwner(context.read<BackendService>().uid);
    final others = rooms.members.where((m) => !m.isUser).toList();

    final action = await showRoomMenu(
      context,
      room: room,
      isLeader: isLeader,
      hasStudy: rooms.currentStudy != null,
      canTransfer: others.isNotEmpty,
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case RoomMenuAction.copyCode:
        await _copyRoomCode(context, room.code);
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
      case RoomMenuAction.clearStudy:
        await rooms.setStudy(null);
      case RoomMenuAction.transfer:
        await _transferRoom(context, others);
      case RoomMenuAction.leave:
        await _leaveRoom(context, isLeader: isLeader, others: others);
      case RoomMenuAction.close:
        final ok = await showAppConfirm(
          context,
          danger: true,
          title: context.l10n.juntosCloseRoomTitle,
          body: context.l10n.juntosCloseRoomBody,
          cancelLabel: context.l10n.commonCancel,
          confirmLabel: context.l10n.juntosCloseConfirm,
        );
        if (!ok || !context.mounted) return;
        await rooms.closeRoom(progress: progress);
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
    return JuntosSegmentTabs(
      index: index,
      onChanged: onChanged,
      accent: AppRoles.reward,
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
    // Submenu interno = presença (azul); ouro fica nas abas-mãe.
    const tone = AppRoles.presence;
    return GlassCard(
      tint: tone,
      glow: 0.32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSegmentedTabs(
            index: pane,
            accent: tone,
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
          ),
          if (hasBody) ...[const SizedBox(height: AppSpace.lg), body!],
        ],
      ),
    );
  }
}

/// Stage da Caravana — mesmo padrão da Companhia: abas + descrição.
class _CaravanStageCard extends StatelessWidget {
  final int pane;
  final ValueChanged<int> onPaneChanged;

  const _CaravanStageCard({required this.pane, required this.onPaneChanged});

  @override
  Widget build(BuildContext context) {
    final weekly = pane == 1;
    // Submenu mês/semana = presença; ouro do ranking fica na lista.
    return GlassCard(
      tint: AppRoles.presence,
      glow: 0.32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSegmentedTabs(
            index: pane,
            accent: AppRoles.presence,
            onChanged: (i) {
              ActHaptics.tap();
              onPaneChanged(i);
            },
            items: [
              (
                label: context.l10n.juntosThisMonth,
                glyph: CinematicGlyph.path,
                mark: null,
                alert: false,
              ),
              (
                label: context.l10n.juntosThisWeek,
                glyph: CinematicGlyph.calendar,
                mark: null,
                alert: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          _CaravanExplainer(weekly: weekly),
        ],
      ),
    );
  }
}

class _CaravanExplainer extends StatelessWidget {
  final bool weekly;

  const _CaravanExplainer({required this.weekly});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final title = weekly
        ? l10n.juntosCaravanWeekTitle
        : l10n.juntosCaravanMonthTitle;
    final body = weekly
        ? l10n.juntosCaravanWeekBody
        : l10n.juntosCaravanMonthBody;
    final steps = weekly
        ? [
            (CinematicGlyph.calendar, l10n.juntosCaravanWeekStep1),
            (CinematicGlyph.podium, l10n.juntosCaravanWeekStep2),
            (CinematicGlyph.rise, l10n.juntosCaravanWeekStep3),
          ]
        : [
            (CinematicGlyph.path, l10n.juntosCaravanMonthStep1),
            (CinematicGlyph.rise, l10n.juntosCaravanMonthStep2),
            (CinematicGlyph.podium, l10n.juntosCaravanMonthStep3),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.display(size: 24, color: a.text),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          body,
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 13,
            height: 1.45,
            color: a.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        _ExplainerSteps(steps: steps, accent: AppRoles.reward),
      ],
    );
  }
}

/// Três passos lado a lado — nó do meio na cor do bloco ([accent]).
class _ExplainerSteps extends StatelessWidget {
  final List<(CinematicGlyph, String)> steps;
  final Color accent;

  const _ExplainerSteps({
    required this.steps,
    this.accent = AppRoles.presence,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final mid = steps.length ~/ 2;
    return Stack(
      children: [
        Positioned(
          left: 40,
          right: 40,
          top: 19,
          child: Container(
            height: 1,
            color: accent.withValues(alpha: 0.35),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < steps.length; i++)
              Expanded(
                child: Column(
                  children: [
                    IconWell(
                      size: 38,
                      accent: i == mid ? accent : AppRoles.chrome,
                      glowing: i == mid,
                      child: CinematicIcon(
                        glyph: steps[i].$1,
                        size: AppMetrics.iconMd,
                        accent: i == mid ? accent : AppRoles.chrome,
                        framed: false,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      steps[i].$2,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 12,
                        height: 1.3,
                        weight: FontWeight.w700,
                        color: i == mid ? a.textSecondary : a.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _AmizadeExplainer extends StatelessWidget {
  const _AmizadeExplainer();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.juntosCompanionExplainerTitle,
          textAlign: TextAlign.center,
          style: AppTypography.display(size: 24, color: a.text),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          context.l10n.juntosCompanionExplainerBody,
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 13,
            height: 1.45,
            color: a.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        _ExplainerSteps(
          steps: [
            (CinematicGlyph.path, context.l10n.juntosCompanionStep1),
            (CinematicGlyph.flame, context.l10n.juntosCompanionStep2),
            (CinematicGlyph.lamp, context.l10n.juntosCompanionStep3),
          ],
        ),
      ],
    );
  }
}

class _DesafioExplainer extends StatelessWidget {
  const _DesafioExplainer();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.juntosChallengeExplainerTitle,
          textAlign: TextAlign.center,
          style: AppTypography.display(size: 24, color: a.text),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          context.l10n.juntosChallengeExplainerBody(CornerCopy.reward),
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 13,
            height: 1.45,
            color: a.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        _ExplainerSteps(
          accent: AppRoles.reward,
          steps: [
            (CinematicGlyph.path, context.l10n.juntosChallengeStep1),
            (CinematicGlyph.calendar, context.l10n.juntosChallengeStep2),
            (CinematicGlyph.rise, context.l10n.juntosChallengeStep3),
          ],
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
    return GlassCard(
      padding: EdgeInsets.zero,
      child: EmptyState(
        glyph: CinematicGlyph.people,
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
    final a = Appearance.of(context);
    return GlassCard(
      glow: 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: SectionLabel(context.l10n.juntosRoomsEmptyEyebrow)),
          const SizedBox(height: AppSpace.lg),
          const _CircleOfSeats(),
          const SizedBox(height: AppSpace.lg),
          Text(
            context.l10n.juntosRoomsEmptyTitle,
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 28, color: a.text),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            context.l10n.juntosRoomsEmptyBody,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.45,
              color: a.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Row(
            children: [
              _RoomBenefit(
                glyph: CinematicGlyph.book,
                label: context.l10n.juntosRoomBenefitStudy,
                detail: context.l10n.juntosRoomBenefitStudyDetail,
                color: a.textSecondary,
              ),
              const SizedBox(width: 8),
              _RoomBenefit(
                glyph: CinematicGlyph.people,
                label: context.l10n.juntosRoomBenefitList,
                detail: context.l10n.juntosRoomBenefitListDetail,
                color: a.textSecondary,
              ),
              const SizedBox(width: 8),
              _RoomBenefit(
                glyph: CinematicGlyph.bell,
                label: context.l10n.juntosRoomBenefitWave,
                detail: context.l10n.juntosRoomBenefitWaveDetail,
                color: a.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xl),
          if (loading)
            const AppSpinner()
          else ...[
            CopperCta(
              label: context.l10n.juntosCreateRoom,
              onTap: onCreate,
              leading: CinematicGlyph.people,
              trailing: null,
            ),
            const SizedBox(height: AppSpace.sm),
            GhostCta(
              label: context.l10n.juntosHaveCode,
              leading: CinematicGlyph.lock,
              expanded: true,
              onTap: onJoin,
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 14),
            InlineNotice(message: error!, standalone: false),
          ],
        ],
      ),
    );
  }
}

/// Roda de lugares em volta de uma lâmpada — o grupo antes de ter gente.
class _CircleOfSeats extends StatelessWidget {
  const _CircleOfSeats();

  @override
  Widget build(BuildContext context) {
    const size = 120.0;
    const seat = 22.0;
    const n = 6;
    final a = Appearance.of(context);
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppRoles.chrome.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            const Center(
              child: CinematicIcon(
                glyph: CinematicGlyph.lamp,
                size: AppMetrics.leadingIcon,
                accent: AppRoles.chrome,
                glowing: true,
              ),
            ),
            for (var i = 0; i < n; i++)
              Positioned(
                left:
                    size / 2 +
                    (size / 2 - seat / 2) *
                        math.cos(2 * math.pi * i / n - math.pi / 2) -
                    seat / 2,
                top:
                    size / 2 +
                    (size / 2 - seat / 2) *
                        math.sin(2 * math.pi * i / n - math.pi / 2) -
                    seat / 2,
                child: Container(
                  width: seat,
                  height: seat,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // O primeiro lugar é você — a mesma marca de "você" das listas.
                    color: i == 0
                        ? AppRoles.selected.withValues(alpha: 0.85)
                        : a.insetFill,
                    border: Border.all(
                      color: i == 0 ? AppRoles.selected : a.cardBorder,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoomBenefit extends StatelessWidget {
  final CinematicGlyph glyph;
  final String label;
  final String detail;
  final Color color;

  const _RoomBenefit({
    required this.glyph,
    required this.label,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Expanded(
      child: InsetPanel(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Column(
          children: [
            CinematicIcon(
              glyph: glyph,
              size: AppMetrics.iconMd,
              accent: AppRoles.chrome,
              framed: false,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(letterSpacing: 0, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 11,
                height: 1.25,
                weight: FontWeight.w600,
                color: a.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Herói do grupo: nome, quem estudou na semana, o baú e o convite.
class _RoomHearth extends StatelessWidget {
  final StudyRoom room;
  final List<RoomMember> members;
  final bool isOwner;
  final bool walkedToday;
  final VoidCallback onMenu;
  final VoidCallback onClaim;

  /// `null` quando o card do estudo logo abaixo já leva ao mesmo lugar.
  final VoidCallback? onWalk;
  final ValueChanged<RoomMember> onSeatTap;

  const _RoomHearth({
    required this.room,
    required this.members,
    required this.isOwner,
    required this.walkedToday,
    required this.onMenu,
    required this.onClaim,
    this.onWalk,
    required this.onSeatTap,
  });

  /// Você primeiro, depois o líder; o resto em ordem fixa (não troca de lugar
  /// conforme o placar).
  List<RoomMember> get _seated {
    final list = [...members];
    list.sort((a, b) {
      if (a.isUser != b.isUser) return a.isUser ? -1 : 1;
      if (a.uid == room.ownerId) return -1;
      if (b.uid == room.ownerId) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final myPhoto = context.select((BackendService b) => b.userPhotoUrl);
    final a = Appearance.of(context);
    final days = LeagueService.daysLeft();
    final l10n = context.l10n;
    final closesText = days <= 1
        ? l10n.juntosClosesToday
        : l10n.juntosDaysLeft(days);
    final leader = isOwner ? l10n.juntosYouLower : room.ownerName;

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

    final missing = ((total + 1) ~/ 2 - lit).clamp(0, total);
    final (String line, Color tone) = total <= 1
        ? (l10n.juntosRoomOnlyYou, a.text)
        : !walkedToday
        ? (l10n.juntosRoomNotStudiedToday, AppRoles.risk)
        : lit == total
        ? (l10n.juntosRoomAllStudied, AppRoles.presence)
        : halfway
        ? (l10n.juntosRoomHalfStudied, AppRoles.presence)
        : (l10n.juntosRoomMissingForHalf(missing), a.text);

    final hint = total <= 1
        ? l10n.juntosRoomHintInvite
        : claimed
        ? l10n.juntosRoomHintClaimed
        : ready
        ? null
        : !walkedToday
        ? l10n.juntosRoomHintStudyToday
        : goal != null && goal > 0
        ? l10n.juntosRoomHintHalfOrGoal
        : l10n.juntosRoomHintHalf;

    return GlassCard(
      tint: ready ? AppRoles.reward : null,
      glow: 0.35 + 0.6 * (total == 0 ? 0 : lit / total),
      elevated: ready,
      // Topo/direita curtos: o botão de opções (48) já traz o respiro.
      padding: AppMetrics.cardPadding.copyWith(top: AppSpace.sm, right: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: room.kind.glyph,
                size: AppMetrics.iconSm,
                accent: AppRoles.chrome,
                framed: false,
              ),
              const SizedBox(width: 6),
              SectionLabel(room.kind.label),
              const SizedBox(width: AppSpace.sm),
              SoftBadge(
                text: closesText,
                accent: days <= 1 ? AppRoles.risk : AppRoles.chrome,
              ),
              const Spacer(),
              _MenuButton(tooltip: l10n.juntosRoomOptions, onTap: onMenu),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  room.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.display(
                    size: 28,
                    height: 1.05,
                    color: a.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.juntosRoomLeaderLine(
                    room.kind.leaderTitle,
                    leader,
                    total,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(size: 13, color: a.textFaint),
                ),
                const SizedBox(height: AppSpace.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$lit',
                      style: AppTypography.display(
                        size: 30,
                        height: 1,
                        color: lit > 0 ? AppRoles.presence : a.text,
                      ),
                    ),
                    Text(
                      l10n.juntosOfTotal(total),
                      style: AppTypography.display(
                        size: 18,
                        height: 1.2,
                        color: a.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          l10n.juntosStudiedThisWeek,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 13,
                            weight: FontWeight.w700,
                            color: a.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.lg),
                RoomRoster(
                  members: _seated,
                  myPhotoUrl: myPhoto,
                  myStyle: progress.settings.portraitStyle,
                  leaderId: room.ownerId,
                  onTap: onSeatTap,
                ),
                const SizedBox(height: AppSpace.xl),
                Text(line, style: AppTypography.title(size: 16, color: tone)),
                if (hint != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    hint,
                    style: AppTypography.body(
                      size: 13,
                      height: 1.35,
                      color: a.textSecondary,
                    ),
                  ),
                ],
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fora do card do grupo: chamar gente e copiar o código.
class _RoomInviteBar extends StatelessWidget {
  final String code;
  final bool full;
  final VoidCallback onCall;
  final VoidCallback onCopy;

  const _RoomInviteBar({
    required this.code,
    required this.full,
    required this.onCall,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      children: [
        Expanded(
          child: full
              ? Text(
                  context.l10n.juntosRoomFull,
                  style: AppTypography.body(
                    size: 12,
                    height: 1.3,
                    weight: FontWeight.w700,
                    color: a.textSecondary,
                  ),
                )
              : GhostCta(
                  label: context.l10n.juntosInvitePeople,
                  leading: CinematicGlyph.people,
                  expanded: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  onTap: onCall,
                ),
        ),
        const SizedBox(width: AppSpace.sm),
        _CodePlate(code: code, onCopy: onCopy, compact: true),
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
            borderSide: BorderSide(
              color: AppRoles.selected.withValues(alpha: 0.7),
            ),
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
  final List<LeagueEntry> entries;
  final List<LeagueEntry> weeklyEntries;
  final bool weekly;
  final bool weeklyCompetitive;
  final bool canPromote;
  final bool canDemote;
  final int tierIndex;
  final VoidCallback? onOpenOwnProfile;

  const _LeaderboardBoard({
    required this.entries,
    required this.weeklyEntries,
    required this.weekly,
    required this.weeklyCompetitive,
    required this.canPromote,
    required this.canDemote,
    required this.tierIndex,
    this.onOpenOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final list = weekly ? weeklyEntries : entries;
    final online = LeagueService.onlineNow(entries);
    final countLabel = LeagueService.onlineCountLabel(online.length);

    final onlineChip = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (online.isNotEmpty) ...[
          _AvatarCluster(
            people: [
              for (final p in online.take(5))
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
          const SizedBox(width: 8),
        ] else ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppRoles.presence.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          countLabel,
          style: AppTypography.label(
            size: 10,
            letterSpacing: 0,
            color: online.isEmpty ? a.textFaint : AppRoles.presence,
          ),
        ),
      ],
    );

    final rows = <Widget>[
      if (online.isEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 10, 8),
          child: onlineChip,
        )
      else
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 4, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              button: true,
              label: context.l10n.juntosOnlineSemantics(countLabel),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showCaravanOnlineSheet(
                    context,
                    people: online,
                    onOpenOwnProfile: onOpenOwnProfile,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 4, 8, 4),
                    child: onlineChip,
                  ),
                ),
              ),
            ),
          ),
        ),
    ];

    if (weekly && (!weeklyCompetitive || list.isEmpty)) {
      rows.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
          child: Text(
            context.l10n.juntosWeekRankingEmpty,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.35,
              color: a.textSecondary,
            ),
          ),
        ),
      );
    } else {
      for (var i = 0; i < list.length; i++) {
        final rank = i + 1;
        if (weekly && rank == 1 && canPromote) {
          rows.add(
            _WeekZoneLabel(
              text: context.l10n.juntosPromoteZone(
                LeagueTier.values[tierIndex + 1].shortLabel,
              ),
              up: true,
            ),
          );
        }
        if (weekly &&
            LeagueService.demoteCountFor(list.length) > 0 &&
            rank ==
                list.length - LeagueService.demoteCountFor(list.length) + 1 &&
            canDemote) {
          rows.add(
            _WeekZoneLabel(
              text: context.l10n.juntosDemoteZone(
                LeagueTier.values[tierIndex - 1].shortLabel,
              ),
              up: false,
            ),
          );
        }
        rows.add(
          _StandingRow(
            entry: list[i],
            rank: rank,
            weeklySteps: weekly,
            gapToAbove: i == 0 ? 0 : list[i - 1].steps - list[i].steps,
            showDivider: i < list.length - 1 && !list[i + 1].isUser,
            onOpenOwnProfile: onOpenOwnProfile,
          ),
        );
        if (weekly &&
            rank == LeagueService.promoteCountFor(list.length) &&
            rank < list.length &&
            canPromote) {
          rows.add(const _WeekZoneDivider());
        }
      }
    }

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
      child: Column(children: rows),
    );
  }
}

class _WeekZoneLabel extends StatelessWidget {
  final String text;
  final bool up;

  const _WeekZoneLabel({required this.text, required this.up});

  @override
  Widget build(BuildContext context) {
    final color = up ? AppRoles.success : AppRoles.risk;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      child: Row(
        children: [
          CinematicIcon(
            glyph: up ? CinematicGlyph.rise : CinematicGlyph.demote,
            size: AppMetrics.iconSm,
            accent: color,
            framed: false,
          ),
          const SizedBox(width: 6),
          Expanded(child: SectionLabel(text, size: 10, color: color)),
        ],
      ),
    );
  }
}

class _WeekZoneDivider extends StatelessWidget {
  const _WeekZoneDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppRoles.success.withValues(alpha: 0.35),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CinematicIcon(
              glyph: CinematicGlyph.rise,
              size: AppMetrics.chipIcon,
              accent: AppRoles.success.withValues(alpha: 0.7),
              framed: false,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppRoles.success.withValues(alpha: 0.35),
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
                  leading: const CinematicIcon(
                    glyph: CinematicGlyph.people,
                    size: AppMetrics.leadingIcon,
                    accent: AppRoles.presence,
                    glowing: true,
                  ),
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
          decoration: _youRowDecoration(entry.isUser),
          child: Row(
            children: [
              _RankMark(rank: rank),
              const SizedBox(width: 10),
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
  final bool weeklySteps;
  final int gapToAbove;
  final bool showDivider;
  final VoidCallback? onOpenOwnProfile;

  const _StandingRow({
    required this.entry,
    required this.rank,
    this.weeklySteps = false,
    this.gapToAbove = 0,
    this.showDivider = false,
    this.onOpenOwnProfile,
  });

  Color _stepsTone(AppearanceStyle a, Color? medal) => medal ?? a.text;

  String _gapLabel(AppLocalizations l10n) {
    if (rank == 1) return l10n.juntosLeader;
    if (gapToAbove <= 0) return l10n.juntosTie;
    return l10n.juntosGapToAbove(gapToAbove, rank - 1);
  }

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
        _RankMark(rank: rank),
        const SizedBox(width: 10),
        UserAvatar(
          name: entry.name,
          radius: AppMetrics.avatarMd,
          // Presença vence a medalha: o anel diz "estudou hoje".
          borderColor: live ? AppRoles.presence : medal,
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
              if (!weeklySteps)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
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
                size: 18,
                weight: FontWeight.w900,
                color: stepsTone,
              ),
            ),
            if (weeklySteps)
              Text(
                _gapLabel(context.l10n),
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.2,
                  color: muted,
                ),
              )
            else if (presence != null)
              Text(
                presence,
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.2,
                  weight: FontWeight.w800,
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
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          padding: const EdgeInsets.fromLTRB(8, 12, 10, 12),
          decoration: entry.isUser
              ? _youRowDecoration(true)
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
    const size = 24.0;
    const overlap = 16.0;
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
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Appearance.of(context).cardFill,
        border: Border.all(color: accent, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: overlay != null
            ? Text(
                overlay!,
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0,
                  weight: FontWeight.w900,
                  color: AppColors.medalGold,
                ),
              )
            : CinematicIcon(
                glyph: glyph,
                size: AppMetrics.chipIcon,
                accent: accent,
                framed: false,
              ),
      ),
    );
  }
}

/// "Você" na lista — a mesma marca em Caravana, Grupos e na folha de quem
/// está online: fundo claro a 0.08 e contorno a 0.4 (nunca placa dourada).
BoxDecoration? _youRowDecoration(bool isUser) {
  if (!isUser) return null;
  return BoxDecoration(
    color: AppRoles.selected.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(AppRadii.md),
    border: Border.all(color: AppRoles.selected.withValues(alpha: 0.4)),
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
    return GlassCard(
      padding: EdgeInsets.zero,
      child: EmptyState(
        glyph: CinematicGlyph.link,
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

class _CompanionsEmpty extends StatelessWidget {
  final bool loading;
  final VoidCallback onInvite;
  final VoidCallback onJoin;

  const _CompanionsEmpty({
    required this.loading,
    required this.onInvite,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final myPhoto = context.select((BackendService b) => b.userPhotoUrl);
    final myUid = context.select((BackendService b) => b.uid);
    final progress = context.watch<ProgressService>();
    final name = progress.userName.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BondMember(
                name: name.isEmpty
                    ? context.l10n.commonYou
                    : name.split(' ').first,
                walked: false,
                highlight: false,
                isUser: true,
                photoUrl: myPhoto,
                seed: myUid ?? name,
                style: progress.settings.portraitStyle,
              ),
              const Expanded(
                child: SizedBox(
                  height: 76,
                  child: Center(child: BondThread(state: BondState.none)),
                ),
              ),
              const _EmptySeat(),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
        if (loading)
          const AppSpinner()
        else ...[
          CopperCta(
            label: context.l10n.juntosInviteCompanion,
            onTap: onInvite,
            leading: CinematicGlyph.people,
            trailing: null,
          ),
          const SizedBox(height: AppSpace.sm),
          GhostCta(
            label: context.l10n.juntosHaveCode,
            leading: CinematicGlyph.qr,
            expanded: true,
            onTap: onJoin,
          ),
        ],
      ],
    );
  }
}

class _CompanionCard extends StatelessWidget {
  final WalkCompanion companion;
  final String myName;
  final VoidCallback onCopy;
  final VoidCallback onLeave;
  final VoidCallback onShowQr;
  final VoidCallback? onNudge;

  const _CompanionCard({
    required this.companion,
    required this.myName,
    required this.onCopy,
    required this.onLeave,
    required this.onShowQr,
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
        code: companion.code,
        myName: myName,
        myPhoto: myPhoto,
        mySeed: myUid ?? myName,
        myStyle: myStyle,
        onCopy: onCopy,
        onShowQr: onShowQr,
        onLeave: onLeave,
      );
    }

    final partnerLabel = companion.displayName.isEmpty
        ? context.l10n.juntosCompanionFallback
        : companion.displayName;
    final myLabel = myName.trim().isEmpty
        ? context.l10n.commonYou
        : myName.trim().split(' ').first;
    final away = companion.theyDaysAway;
    final canNudge =
        onNudge != null &&
        (companion.waitingOnThem || (away != null && away >= 1));

    // Cada ponta é da pessoa: amarelo se caminhou, cinza se ainda não,
    // e some só de quem não está caminhando.
    BondEnd endFor({required bool walked, required bool away}) {
      if (away) return BondEnd.gone;
      if (walked) return BondEnd.lit;
      return BondEnd.idle;
    }

    final leftEnd = endFor(walked: companion.iWalkedToday, away: false);
    final rightEnd = endFor(
      walked: companion.theyWalkedToday,
      away: companion.theyAreDusty,
    );
    return GlassCard(
      // Rodapé com TextCta (sair) — ele já traz o próprio respiro.
      padding: AppMetrics.cardPadding.copyWith(bottom: AppSpace.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (companion.sharedDays > 0)
            SoftBadge(
              text: context.l10n.commonDays(companion.sharedDays),
              glyph: CinematicGlyph.flame,
              accent: AppColors.streak,
            ),

          const SizedBox(height: AppSpace.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BondMember(
                name: myLabel,
                walked: companion.iWalkedToday,
                highlight: companion.waitingOnMe,
                isUser: true,
                photoUrl: myPhoto,
                seed: myUid ?? myName,
                style: myStyle,
              ),
              Expanded(
                child: SizedBox(
                  height: 76,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Center(
                          child: BondThread(
                            state: BondState.idle,
                            left: leftEnd,
                            right: rightEnd,
                          ),
                        ),
                      ),
                      _BondKnot(both: companion.bothWalkedToday),
                    ],
                  ),
                ),
              ),
              _BondMember(
                name: partnerLabel,
                walked: companion.theyWalkedToday,
                highlight: companion.waitingOnThem,
                dusty: companion.theyAreDusty,
                seed: companion.displayName,
              ),
            ],
          ),
          if (companion.hasIncomingNudge) ...[
            const SizedBox(height: 14),
            _IncomingNudgeBanner(companion: companion),
          ],
          RecognizeCompanionWalk(
            partnerUid: companion.partnerUid,
            walkDate: companion.theyLastWalkDate,
          ),
          if (canNudge) ...[
            const SizedBox(height: AppSpace.lg),
            CopperCta(
              label: companion.iNudgedToday
                  ? context.l10n.commonSendWhatsApp
                  : context.l10n.juntosWaveAt(companion.partnerFirstName),
              onTap: onNudge,
              leading: companion.iNudgedToday
                  ? CinematicGlyph.share
                  : CinematicGlyph.lamp,
              trailing: null,
              dense: true,
            ),
          ],
          const SizedBox(height: AppSpace.lg),
          InsetPanel(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CompanionWeekStrip(companion: companion),
                const SizedBox(height: 18),
                _CompanionMilestonesBlock(companion: companion),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextCta(
              label: context.l10n.juntosLeaveCompanionCta,
              danger: true,
              onTap: onLeave,
            ),
          ),
        ],
      ),
    );
  }
}

/// Uma ponta do fio: retrato com halo (aceso se caminhou hoje), nome e
/// uma palavra de estado.
class _BondMember extends StatelessWidget {
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
    // Estudou hoje = presença; sua vez = risco; parado há dias = apagado.
    final tone = walked
        ? AppRoles.presence
        : dusty
        ? a.textFaint
        : highlight
        ? AppRoles.risk
        : a.textFaint;

    Widget avatar = UserAvatar(
      name: name,
      radius: AppMetrics.avatarLg,
      borderColor: isUser ? AppRoles.selected.withValues(alpha: 0.55) : null,
      photoUrl: photoUrl,
      seed: seed ?? name,
      style: style,
    );
    if (dusty) {
      avatar = HeroCardColorGrade(mood: HeroCardMood.dusty, child: avatar);
    }

    return SizedBox(
      width: 88,
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
            style: AppTypography.title(
              size: 14,
              color: dusty ? a.textSecondary : a.text,
            ),
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

/// Nó no meio do fio — coração que acende quando o dia conta para os dois.
class _BondKnot extends StatelessWidget {
  final bool both;

  const _BondKnot({required this.both});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return AnimatedContainer(
      duration: AppMotion.gentle,
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: both ? AppRoles.success : a.cardFill,
        border: Border.all(
          color: both ? AppRoles.success : a.cardBorder,
          width: 1.4,
        ),
        boxShadow: both
            ? [
                BoxShadow(
                  color: AppRoles.success.withValues(alpha: 0.5),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Center(
        child: CinematicIcon(
          glyph: CinematicGlyph.link,
          size: AppMetrics.iconSm,
          accent: both ? AppColors.night : a.textFaint,
          framed: false,
        ),
      ),
    );
  }
}

/// Convite aberto: você de um lado, um lugar vazio do outro — e o código.
class _OpenInviteStage extends StatelessWidget {
  final String code;
  final String myName;
  final String? myPhoto;
  final String mySeed;
  final PortraitStyle myStyle;
  final VoidCallback onCopy;
  final VoidCallback onShowQr;
  final VoidCallback onLeave;

  const _OpenInviteStage({
    required this.code,
    required this.myName,
    required this.myPhoto,
    required this.mySeed,
    required this.myStyle,
    required this.onCopy,
    required this.onShowQr,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final myLabel = myName.trim().isEmpty
        ? context.l10n.commonYou
        : myName.trim().split(' ').first;
    final a = Appearance.of(context);
    return GlassCard(
      // Rodapé com TextCta (sair) — ele já traz o próprio respiro.
      padding: AppMetrics.cardPadding.copyWith(bottom: AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SectionLabel(context.l10n.juntosOpenInvite),
              const Spacer(),
              SoftBadge(
                text: context.l10n.juntosWaiting,
                glyph: CinematicGlyph.lamp,
              ),
            ],
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
                child: SizedBox(
                  height: 76,
                  child: Center(child: BondThread(state: BondState.none)),
                ),
              ),
              const _EmptySeat(),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            context.l10n.juntosOpenInviteMissing,
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 16, color: a.text),
          ),
          const SizedBox(height: AppSpace.md),
          _CodePlate(code: code, onCopy: onCopy),
          const SizedBox(height: AppSpace.md),
          CopperCta(
            label: context.l10n.juntosShowQrShare,
            onTap: onShowQr,
            leading: CinematicGlyph.qr,
            trailing: null,
            dense: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextCta(
              label: context.l10n.juntosCancelInvite,
              danger: true,
              onTap: onLeave,
            ),
          ),
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
class _CodePlate extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;
  final bool compact;

  const _CodePlate({
    required this.code,
    required this.onCopy,
    this.compact = false,
  });

  /// A letra de código de convite é uma só ([inviteCodeStyle]).
  static TextStyle codeStyle(AppearanceStyle a, {bool compact = false}) =>
      inviteCodeStyle(a, size: compact ? 18 : 24);

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final Widget content = compact
        ? ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SectionLabel(
                  context.l10n.juntosCodeLabel,
                  size: 10,
                  color: a.textFaint,
                ),
                const SizedBox(height: 2),
                Text(code, style: codeStyle(a, compact: true)),
              ],
            ),
          )
        : Row(
            children: [
              SectionLabel(context.l10n.juntosCodeLabel, color: a.textFaint),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Text(
                  code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: codeStyle(a),
                ),
              ),
              CinematicIcon(
                glyph: CinematicGlyph.copy,
                size: AppMetrics.iconSm,
                accent: a.textSecondary,
                framed: false,
              ),
              const SizedBox(width: 6),
              Text(
                context.l10n.juntosCopy,
                style: AppTypography.body(
                  size: 13,
                  weight: FontWeight.w800,
                  color: a.textSecondary,
                ),
              ),
            ],
          );
    return Semantics(
      button: true,
      label: compact
          ? context.l10n.juntosCopyCodeSemantics(code)
          : context.l10n.juntosCodeTapToCopy(code),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ActHaptics.tap();
          onCopy();
        },
        child: InsetPanel(
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
              : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: content,
        ),
      ),
    );
  }
}

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(l10n.juntosMilestones),
        const SizedBox(height: 14),
        _MilestoneTrail(sharedDays: shared, next: next, style: a),
        if (shared < next) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  caption,
                  style: AppTypography.body(size: 13, color: a.textSecondary),
                ),
              ),
              Text(
                '$shared/$next',
                style: AppTypography.label(
                  size: 11,
                  weight: FontWeight.w800,
                  color: a.text,
                ),
              ),
            ],
          ),
        ],
      ],
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
                    ? AppRoles.selected
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

class _MilestoneTrail extends StatelessWidget {
  final int sharedDays;
  final int next;
  final AppearanceStyle style;

  const _MilestoneTrail({
    required this.sharedDays,
    required this.next,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final marks = WalkCompanion.milestones;
    return LayoutBuilder(
      builder: (context, constraints) {
        final n = marks.length;
        final slot = constraints.maxWidth / n;
        const node = 28.0;
        return Column(
          children: [
            SizedBox(
              height: node,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: slot / 2,
                    right: slot / 2,
                    top: (node / 2) - 1.5,
                    child: _MilestoneLine(sharedDays: sharedDays, style: style),
                  ),
                  Row(
                    children: [
                      for (final m in marks)
                        Expanded(
                          child: Center(
                            child: _MilestoneNode(
                              reached: sharedDays >= m,
                              current: next == m,
                              arc: _gapProgress(sharedDays, m),
                              style: style,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (final m in marks)
                  Expanded(
                    child: Text(
                      '$m',
                      textAlign: TextAlign.center,
                      style: AppTypography.label(
                        size: 11,
                        letterSpacing: 0,
                        weight: sharedDays >= m || next == m
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: sharedDays >= m
                            ? AppRoles.reward
                            : next == m
                            ? style.text
                            : style.textFaint,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Quanto do trecho até [days] já foi caminhado (0–1). Só o marco atual.
  static double _gapProgress(int shared, int days) {
    if (shared >= days) return 1;
    final marks = WalkCompanion.milestones;
    var prev = 0;
    for (final m in marks) {
      if (m == days) break;
      if (m < days) prev = m;
    }
    if (days <= prev) return 0;
    return ((shared - prev) / (days - prev)).clamp(0.0, 1.0);
  }
}

class _MilestoneLine extends StatelessWidget {
  final int sharedDays;
  final AppearanceStyle style;

  const _MilestoneLine({required this.sharedDays, required this.style});

  @override
  Widget build(BuildContext context) {
    final marks = WalkCompanion.milestones;
    return SizedBox(
      height: 3,
      child: Row(
        children: [
          for (var i = 0; i < marks.length - 1; i++)
            Expanded(child: _segment(marks[i], marks[i + 1])),
        ],
      ),
    );
  }

  Widget _segment(int from, int to) {
    final done = sharedDays >= to;
    final current = sharedDays >= from && sharedDays < to;
    final t = current
        ? ((sharedDays - from) / (to - from)).clamp(0.0, 1.0)
        : (done ? 1.0 : 0.0);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: style.cardBorder.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(AppRadii.hair),
          ),
        ),
        if (t > 0)
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: t,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: AppRoles.reward,
                borderRadius: BorderRadius.all(Radius.circular(AppRadii.hair)),
              ),
            ),
          ),
      ],
    );
  }
}

class _MilestoneNode extends StatelessWidget {
  final bool reached;
  final bool current;
  final double arc;
  final AppearanceStyle style;

  const _MilestoneNode({
    required this.reached,
    required this.current,
    required this.arc,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _MilestoneNodePainter(
          reached: reached,
          current: current,
          arc: arc,
          track: style.cardBorder.withValues(alpha: 0.7),
          empty: style.cardFillSoft,
        ),
        child: reached
            ? const Center(
                child: CinematicIcon(
                  glyph: CinematicGlyph.check,
                  size: AppMetrics.chipIcon,
                  accent: AppRoles.onReward,
                  framed: false,
                ),
              )
            : null,
      ),
    );
  }
}

class _MilestoneNodePainter extends CustomPainter {
  final bool reached;
  final bool current;
  final double arc;
  final Color track;
  final Color empty;

  const _MilestoneNodePainter({
    required this.reached,
    required this.current,
    required this.arc,
    required this.track,
    required this.empty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.2;
    if (reached) {
      canvas.drawCircle(center, radius, Paint()..color = AppRoles.reward);
      return;
    }
    canvas.drawCircle(center, radius, Paint()..color = empty);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = current ? 1.8 : 1.1
        ..color = current ? AppRoles.selected : track,
    );
    if (current && arc > 0.01) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * arc.clamp(0.0, 1.0),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = AppRoles.reward,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MilestoneNodePainter old) =>
      reached != old.reached ||
      current != old.current ||
      arc != old.arc ||
      track != old.track ||
      empty != old.empty;
}

class _IncomingNudgeBanner extends StatelessWidget {
  final WalkCompanion companion;

  const _IncomingNudgeBanner({required this.companion});

  @override
  Widget build(BuildContext context) {
    final from = companion.incomingNudgeFromName?.trim().isNotEmpty == true
        ? companion.incomingNudgeFromName!.trim().split(' ').first
        : context.l10n.juntosCompanionFallback;
    final message = companion.incomingNudgeMessage?.trim();
    final a = Appearance.of(context);
    return InsetPanel(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.lamp,
            size: AppMetrics.iconLg,
            accent: AppRoles.chrome,
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
    return GlassCard(
      padding: EdgeInsets.zero,
      child: EmptyState(
        glyph: CinematicGlyph.people,
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
                glyph: CinematicGlyph.tune,
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
