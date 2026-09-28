import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
import '../widgets/immersive_background.dart';
import '../widgets/invite_qr_sheet.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/portrait_face.dart';
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
    with SingleTickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 900),
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
              backend.lastError ??
              'Entre com Google para ver a caravana ao vivo.';
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
        _playersError =
            'A caravana demorou para responder. Puxe para atualizar.';
      });
    } catch (e) {
      debugPrint('Falha ao carregar caravana: $e');
      if (!mounted) return;
      setState(() {
        _playersLoading = false;
        _playersError =
            'Não foi possível carregar a caravana. Puxe para atualizar.';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'A companhia ganhou +${WalkCompanion.weekTogetherBonusSteps} passos na jornada',
            ),
          ),
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
    if (_enter.isCompleted) return child;
    final start = (0.08 * index).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
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
              companionAlert:
                  context.watch<CompanionService>().incomingNudge != null ||
                  context.watch<CornerService>().face != null,
              gruposAlert: context.watch<RoomService>().incoming.isNotEmpty,
              onChanged: (i) {
                ActHaptics.tap();
                setState(() => _tab = i);
              },
            ),
          ),
          const SizedBox(height: AppSpace.section),
          // Troca de aba desliza o conteúdo para o lado da aba escolhida —
          // o palco muda, a moldura fica.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            transitionBuilder: (child, animation) {
              final incoming = child.key == ValueKey(_tab);
              final dx = incoming ? 0.06 : -0.06;
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(dx, 0),
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
                    onOpenCaravana: () => setState(() => _tab = _tabCaravana),
                  ),
                  ..._buildLeague(context),
                ],
                _ => _buildRooms(context),
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLeague(BuildContext context) {
    final progress = context.watch<ProgressService>();
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
    final backend = context.watch<BackendService>();
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
        _InlineErrorCard(
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
        label: 'Chamar para a caravana',
        leading: CinematicGlyph.share,
        trailing: null,
        onTap: () => _shareCaravanInvite(context),
      ),
      const SizedBox(height: AppSpace.sm),
      GhostCta(
        label: 'Ou chamar um companheiro',
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
    final progress = context.watch<ProgressService>();
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
        Text(
          companions.lastError!,
          textAlign: TextAlign.center,
          style: AppTypography.body(size: 12, color: AppColors.error),
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
                message: 'Código copiado',
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
                  label: 'Convidar',
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
                label: 'Aceitar',
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
            label: 'Encerrar todas as companhias',
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
        hideEmptyChrome: true,
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
    final who = name.isEmpty ? 'Alguém' : name;
    final store = AppUpdateService.androidStoreUrl;
    await SharePlus.instance.share(
      ShareParams(
        text:
            '$who te chama pra caravana no Stway — aprenda a Bíblia em cenas curtas e caminhe junto no ranking.\n\nBaixe: $store',
        subject: 'Venha pra caravana no Stway',
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
        message: service.lastError ?? 'Falha ao criar',
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
        message: service.lastError ?? 'Não foi possível entrar',
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
      title: 'Encerrar todas as companhias?',
      body: count == 1
          ? 'A companhia termina. Você fica sem companheiro.'
          : 'As $count companhias terminam. Você fica sem companheiro.',
      cancelLabel: 'Cancelar',
      confirmLabel: 'Encerrar todas',
    );
  }

  Future<bool> _confirmLeaveCompanion(BuildContext context) {
    return showAppConfirm(
      context,
      danger: true,
      title: 'Sair da companhia?',
      body: 'A companhia com esta pessoa termina. A caravana continua.',
      cancelLabel: 'Cancelar',
      confirmLabel: 'Sair',
    );
  }

  List<Widget> _buildRooms(BuildContext context) {
    final rooms = context.watch<RoomService>();
    final backend = context.watch<BackendService>();
    final progress = context.watch<ProgressService>();

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
      subtitle: 'Aponte a câmera ou digite o código para entrar',
      companionMode: false,
      inviterName: progress.userName,
      shareMessage:
          'Entra no grupo "${room.name}" no Stway.\n'
          'Toque ou aponte a câmera:\n'
          '${InviteDeepLinkService.roomHttpsUrl(room.code)}\n\n'
          'Código: ${room.code}\n\n'
          'A lista mostra quem estudou nesta semana.\n\n'
          'Ainda não tem o app? Baixe: ${AppUpdateService.androidStoreUrl}',
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
        Text(
          rooms.lastError!,
          textAlign: TextAlign.center,
          style: AppTypography.body(size: 12, color: AppColors.error),
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
        title: 'Meta de passos do grupo',
        hint: 'Soma da semana. Em branco, tira a meta.',
        confirmLabel: 'Salvar',
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
        title: 'Entrar em ${invite.roomName}?',
        body: 'Você sai do grupo em que está agora.',
        cancelLabel: 'Agora não',
        confirmLabel: 'Entrar',
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
            ? 'Você entrou em ${rooms.activeRoom?.name ?? invite.roomName}.'
            : rooms.lastError ?? 'Não foi possível entrar no grupo.',
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
      message: 'Não foi possível recusar o convite.',
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
        message: 'Não foi possível cancelar o convite.',
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
        message:
            'Grupo criado. Chame alguém da lista, ou mande o código ${context.read<RoomService>().activeCode}.',
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
          ? 'Baú do grupo · +$bonus passos'
          : 'Baú já coletado nesta semana',
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
      leaderTitle: rooms.activeRoom?.kind.leaderTitle ?? 'Líder',
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
      message: 'Código copiado',
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
          ? 'Estudo marcado para o grupo'
          : 'Não foi possível marcar o estudo.',
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
          ? 'Você acenou para $first'
          : 'Não foi possível acenar agora.',
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
          title: 'Editar grupo',
          confirmLabel: 'Salvar',
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
          title: 'Encerrar o grupo?',
          body:
              'O grupo some para todos e o código deixa de funcionar. '
              'Não dá para desfazer.',
          cancelLabel: 'Cancelar',
          confirmLabel: 'Encerrar',
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
      title: 'Passar a liderança',
      body:
          'Quem assumir marca o estudo, a meta e chama o grupo. '
          'Você continua na lista.',
      members: others,
    );
    if (to == null || !context.mounted) return false;
    final ok = await rooms.transferOwnership(to);
    if (!context.mounted) return ok;
    showAppToastFor(
      context,
      message: ok
          ? '${to.name} agora conduz o grupo'
          : 'Não foi possível passar a liderança.',
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
        title: 'Antes de sair',
        body: 'Escolha quem vai conduzir o grupo depois de você.',
        cancelLabel: 'Cancelar',
        confirmLabel: 'Escolher',
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
      builder: (ctx) => const _TextInputDialog(
        title: 'Entrar no grupo',
        hint: 'Código que você recebeu',
        confirmLabel: 'Entrar',
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
        message: rooms.lastError ?? 'Não foi possível entrar no grupo.',
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    showAppToastFor(
      context,
      message: 'Você entrou em ${rooms.activeRoom?.name ?? 'o grupo'}.',
      glyph: CinematicGlyph.people,
    );
  }

  Future<bool> _confirmLeave(BuildContext context) {
    return showAppConfirm(
      context,
      danger: true,
      title: 'Sair do grupo?',
      body: 'Você sai da lista. Para voltar, use o código de novo.',
      cancelLabel: 'Cancelar',
      confirmLabel: 'Sair',
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
      items: [
        (label: 'Companhia', glyph: CinematicGlyph.link, alert: companionAlert),
        (label: 'Caravana', glyph: CinematicGlyph.podium, alert: caravanAlert),
        (label: 'Grupos', glyph: CinematicGlyph.people, alert: gruposAlert),
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
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, hasBody ? 0 : 10),
            child: JuntosSegmentTabs(
              index: pane,
              onChanged: (i) {
                ActHaptics.tap();
                onPaneChanged(i);
              },
              items: [
                (
                  label: 'Amizade',
                  glyph: CinematicGlyph.link,
                  alert: companionAlert,
                ),
                (
                  label: 'Desafio',
                  glyph: CinematicGlyph.flag,
                  alert: desafioAlert,
                ),
              ],
            ),
          ),
          if (hasBody) ...[
            const SizedBox(height: AppSpace.md),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: body!,
            ),
          ],
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
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: JuntosSegmentTabs(
              index: pane,
              onChanged: (i) {
                ActHaptics.tap();
                onPaneChanged(i);
              },
              items: const [
                (
                  label: 'Este mês',
                  glyph: CinematicGlyph.path,
                  alert: false,
                ),
                (
                  label: 'Esta semana',
                  glyph: CinematicGlyph.calendar,
                  alert: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: _CaravanExplainer(weekly: weekly),
          ),
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
    final title = weekly
        ? 'Quem avançou nesta semana?'
        : 'Quem mais caminhou neste mês?';
    final body = weekly
        ? 'Só passos de cenas novas, de segunda a domingo. No fim da semana, os primeiros sobem de divisão e os últimos descem.'
        : 'Tudo conta: cenas, missões, baús e companhia. Zera todo dia 1 — quem chegou agora também pode liderar.';
    final steps = weekly
        ? const [
            (CinematicGlyph.calendar, 'Passos\nda semana'),
            (CinematicGlyph.podium, 'Lugar no\nranking'),
            (CinematicGlyph.rise, 'Sobe ou\ndesce'),
          ]
        : const [
            (CinematicGlyph.path, 'Estude\numa cena'),
            (CinematicGlyph.rise, 'Some\npassos'),
            (CinematicGlyph.podium, 'Veja o\ncaminho'),
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
        _CaravanSteps(steps: steps),
      ],
    );
  }
}

class _CaravanSteps extends StatelessWidget {
  final List<(CinematicGlyph, String)> steps;

  const _CaravanSteps({required this.steps});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Stack(
      children: [
        Positioned(
          left: 40,
          right: 40,
          top: 19,
          child: Container(
            height: 1,
            color: AppColors.accent.withValues(alpha: 0.25),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final s in steps)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.nightMid,
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Center(
                        child: CinematicIcon(
                          glyph: s.$1,
                          size: 18,
                          accent: AppColors.accent,
                          framed: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.$2,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 12,
                        height: 1.3,
                        weight: FontWeight.w700,
                        color: a.textSecondary,
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
          'Quem caminha ao seu lado?',
          textAlign: TextAlign.center,
          style: AppTypography.display(size: 24, color: a.text),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          'Uma amizade de estudo. No dia em que os dois caminham, o fio acende e a sequência cresce.',
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 13,
            height: 1.45,
            color: a.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        const _CompanionSteps(),
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
          'Quem chega junto na cena?',
          textAlign: TextAlign.center,
          style: AppTypography.display(size: 24, color: a.text),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          'Mesma cena, até domingo. Cada um que chegar ganha ${CornerCopy.reward} — os dois podem ganhar; não é duelo.',
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 13,
            height: 1.45,
            color: a.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        const _DesafioSteps(),
      ],
    );
  }
}

/// Os três passos do desafio — mesmo idioma visual da Amizade.
class _DesafioSteps extends StatelessWidget {
  const _DesafioSteps();

  static const _steps = [
    (CinematicGlyph.path, 'Mesma\ncena'),
    (CinematicGlyph.calendar, 'Chegar até\ndomingo'),
    (CinematicGlyph.rise, 'Cada um\nganha +10'),
  ];

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Stack(
      children: [
        Positioned(
          left: 40,
          right: 40,
          top: 19,
          child: Container(
            height: 1,
            color: AppColors.accent.withValues(alpha: 0.25),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final s in _steps)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.nightMid,
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Center(
                        child: CinematicIcon(
                          glyph: s.$1,
                          size: 18,
                          accent: AppColors.accent,
                          framed: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.$2,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 12,
                        height: 1.3,
                        weight: FontWeight.w700,
                        color: a.textSecondary,
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
    return GlassCard(
      padding: const EdgeInsets.all(AppSpace.xl),
      child: Column(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.people,
            size: 40,
            accent: AppColors.clay,
            glowing: false,
          ),
          const SizedBox(height: 14),
          Text(
            'Entre para criar o grupo',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 24, color: a.text),
          ),
          const SizedBox(height: 8),
          Text(
            error ??
                'O grupo fica na sua conta. Entre com Google para criar ou usar um código.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.35,
              color: a.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          CopperCta(
            label: loading ? 'Conectando…' : 'Tentar de novo',
            onTap: loading ? null : onRetry,
            busy: loading,
            leading: CinematicGlyph.refresh,
            trailing: null,
            dense: true,
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            'Sem login, o código não funciona',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w700,
              color: AppColors.accent.withValues(alpha: 0.9),
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: SectionLabel(
              'Célula · Discipulado · EBD',
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          const _CircleOfSeats(),
          const SizedBox(height: AppSpace.lg),
          Text(
            'Quem estuda com você?',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 28, color: a.text),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Um grupo fechado: célula, discipulado ou EBD. Marque a cena da semana e veja quem estudou — o convite vai no app ou no WhatsApp.',
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
                label: 'Estudo',
                detail: 'Mesma cena',
                color: a.textSecondary,
              ),
              const SizedBox(width: 8),
              _RoomBenefit(
                glyph: CinematicGlyph.people,
                label: 'Lista',
                detail: 'Quem estudou',
                color: a.textSecondary,
              ),
              const SizedBox(width: 8),
              _RoomBenefit(
                glyph: CinematicGlyph.bell,
                label: 'Acenar',
                detail: 'Quem sumiu',
                color: a.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xl),
          if (loading)
            const AppSpinner()
          else ...[
            CopperCta(
              label: 'Criar grupo',
              onTap: onCreate,
              leading: CinematicGlyph.people,
              trailing: null,
            ),
            const SizedBox(height: AppSpace.sm),
            GhostCta(
              label: 'Entrar com código',
              leading: CinematicGlyph.lock,
              expanded: true,
              onTap: onJoin,
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 14),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: AppTypography.body(size: 12, color: AppColors.error),
            ),
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
                      AppColors.accent.withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            const Center(
              child: CinematicIcon(
                glyph: CinematicGlyph.lamp,
                size: 34,
                accent: AppColors.accent,
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
                    color: i == 0
                        ? AppColors.accent
                        : Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: i == 0
                          ? AppColors.accent
                          : Colors.white.withValues(alpha: 0.22),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: a.cardFillSoft,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: a.cardBorder),
        ),
        child: Column(
          children: [
            CinematicIcon(
              glyph: glyph,
              size: 20,
              accent: AppColors.accent,
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
    final closesText = days <= 1 ? 'Fecha hoje' : 'Fecha em $days dias';
    final leader = isOwner ? 'você' : room.ownerName;

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
        ? ('Só você no grupo por enquanto.', a.text)
        : !walkedToday
        ? ('Você ainda não estudou hoje.', AppColors.streak)
        : lit == total
        ? ('O grupo inteiro estudou nesta semana.', AppColors.accent)
        : halfway
        ? ('Metade do grupo já estudou.', AppColors.accent)
        : (
            missing == 1
                ? 'Falta 1 pessoa para metade do grupo.'
                : 'Faltam $missing pessoas para metade do grupo.',
            a.text,
          );

    final hint = total <= 1
        ? 'Convide quem estuda com você: célula, família, amigos.'
        : claimed
        ? 'Baú do grupo coletado nesta semana.'
        : ready
        ? null
        : !walkedToday
        ? 'Estude hoje para abrir o baú do grupo.'
        : goal != null && goal > 0
        ? 'O baú abre com metade do grupo ou a meta.'
        : 'O baú abre quando metade do grupo estudar.';

    return GlassCard(
      tint: ready ? AppColors.accent : null,
      glow: 0.35 + 0.6 * (total == 0 ? 0 : lit / total),
      elevated: ready,
      padding: const EdgeInsets.fromLTRB(18, 10, 6, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: room.kind.glyph,
                size: 16,
                accent: AppColors.accent,
                framed: false,
              ),
              const SizedBox(width: 6),
              SectionLabel(room.kind.label, color: AppColors.accent),
              const SizedBox(width: AppSpace.sm),
              SoftBadge(
                text: closesText,
                accent: days <= 1 ? AppColors.streak : AppColors.accent,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Opções do grupo',
                onPressed: onMenu,
                icon: Icon(Icons.more_horiz_rounded, color: a.textSecondary),
              ),
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
                  '${room.kind.leaderTitle}: $leader · $total ${total == 1 ? 'pessoa' : 'pessoas'}',
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
                        color: lit > 0 ? AppColors.accent : a.text,
                      ),
                    ),
                    Text(
                      ' de $total',
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
                          'estudaram nesta semana',
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
                      const SectionLabel('Meta do grupo', size: 10),
                      const Spacer(),
                      Text(
                        '$sumSteps / $goal passos',
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w800,
                          color: goalReached ? AppColors.accent : a.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AppProgressBar(
                    value: (sumSteps / goal).clamp(0.0, 1.0),
                    color: AppColors.accent,
                  ),
                ],
                if (!walkedToday && total > 1 && onWalk != null) ...[
                  const SizedBox(height: AppSpace.lg),
                  CopperCta(
                    label: 'Estudar hoje',
                    onTap: onWalk,
                    leading: CinematicGlyph.book,
                    dense: true,
                  ),
                ],
                if (ready) ...[
                  const SizedBox(height: AppSpace.lg),
                  CopperCta(
                    label: 'Abrir o baú do grupo · +$bonus passos',
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
                  'Grupo cheio. Para mais gente, abra outro grupo.',
                  style: AppTypography.body(
                    size: 12,
                    height: 1.3,
                    weight: FontWeight.w700,
                    color: a.textSecondary,
                  ),
                )
              : GhostCta(
                  label: 'Chamar pessoas',
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
        _RoomCodeChip(code: code, onTap: onCopy),
      ],
    );
  }
}

/// Código pequeno ao lado do convite — toque copia.
class _RoomCodeChip extends StatelessWidget {
  final String code;
  final VoidCallback onTap;

  const _RoomCodeChip({required this.code, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Semantics(
      button: true,
      label: 'Copiar código $code',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: a.cardFillSoft,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: a.cardBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SectionLabel('Código', size: 10, color: a.textFaint),
              const SizedBox(height: 2),
              Text(
                code,
                style: AppTypography.title(
                  size: 16,
                  weight: FontWeight.w900,
                  color: AppColors.accent,
                ).copyWith(letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
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
              color: AppColors.accent.withValues(alpha: 0.7),
            ),
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        GhostCta(label: 'Cancelar', onTap: () => Navigator.pop(context)),
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
            size: 22,
          ),
          const SizedBox(width: 8),
        ] else ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          countLabel,
          style: AppTypography.label(
            size: 10,
            letterSpacing: 0,
            color: online.isEmpty
                ? a.textFaint
                : AppColors.teal.withValues(alpha: 0.9),
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
              label: '$countLabel. Ver quem está na trilha',
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
            'O ranking da semana só aparece com gente de verdade na caravana.',
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
              text:
                  'Zona de subida · ${LeagueTier.values[tierIndex + 1].shortLabel}',
              up: true,
            ),
          );
        }
        if (weekly &&
            LeagueService.demoteCountFor(list.length) > 0 &&
            rank == list.length - LeagueService.demoteCountFor(list.length) + 1 &&
            canDemote) {
          rows.add(
            _WeekZoneLabel(
              text:
                  'Zona de descida · ${LeagueTier.values[tierIndex - 1].shortLabel}',
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
    final color = up ? AppColors.accent : AppColors.error;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      child: Row(
        children: [
          CinematicIcon(
            glyph: up ? CinematicGlyph.rise : CinematicGlyph.demote,
            size: 16,
            accent: color,
            framed: false,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SectionLabel(
              text,
              size: 10,
              color: color.withValues(alpha: 0.9),
            ),
          ),
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
              color: AppColors.accent.withValues(alpha: 0.35),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CinematicIcon(
              glyph: CinematicGlyph.rise,
              size: 14,
              accent: AppColors.accent.withValues(alpha: 0.7),
              framed: false,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.accent.withValues(alpha: 0.35),
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
    final a = Appearance.of(context);
    final maxH = MediaQuery.sizeOf(context).height * 0.72;
    final count = people.length;
    final subtitle = count == 1
        ? '1 peregrino da caravana'
        : '$count peregrinos da caravana';

    return AppSheetPanel(
      tint: AppColors.teal,
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CinematicIcon(
                          glyph: CinematicGlyph.people,
                          size: 36,
                          accent: AppColors.teal,
                          glowing: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Na trilha agora',
                                style: AppTypography.title(
                                  size: 20,
                                  color: a.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: AppTypography.body(
                                  size: 13,
                                  color: a.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
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
    final ink = entry.isUser ? AppColors.inkOnAccent : a.text;
    final muted = entry.isUser
        ? AppColors.inkOnAccent.withValues(alpha: 0.62)
        : a.textFaint;
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
          decoration: BoxDecoration(
            gradient: entry.isUser ? AppGradients.gold : null,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: entry.isUser
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 1.4,
                  )
                : null,
          ),
          child: Row(
            children: [
              _RankMark(rank: rank, onGold: entry.isUser),
              const SizedBox(width: 10),
              _PilgrimAvatar(
                name: entry.name,
                isUser: entry.isUser,
                live: true,
                size: 40,
                onGold: entry.isUser,
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
                      style: AppTypography.title(
                        size: 14,
                        weight: entry.isUser
                            ? FontWeight.w900
                            : FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      walked ? 'Caminhou hoje' : 'Online',
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w800,
                        color: walked
                            ? (entry.isUser
                                  ? muted
                                  : AppColors.teal.withValues(alpha: 0.95))
                            : muted,
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
                  color: entry.isUser ? AppColors.inkOnAccent : a.text,
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

  Color _stepsTone(AppearanceStyle a, Color? medal) {
    if (entry.isUser) return AppColors.inkOnAccent;
    if (medal != null) return medal;
    return a.text;
  }

  String get _gapLabel {
    if (rank == 1) return 'líder';
    if (gapToAbove <= 0) return 'empate';
    return '$gapToAbove do ${rank - 1}º';
  }

  String? get _presenceShort {
    if (entry.walkedToday) return 'hoje';
    return LeagueEntry.formatShortBrDate(entry.lastWalkDate);
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
    final muted = entry.isUser
        ? AppColors.inkOnAccent.withValues(alpha: 0.62)
        : a.textFaint;
    final presence = _presenceShort;

    final ink = entry.isUser ? AppColors.inkOnAccent : a.text;
    final live = entry.walkedToday || entry.isOnlineToday;

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _RankMark(rank: rank, onGold: entry.isUser),
        const SizedBox(width: 10),
        _PilgrimAvatar(
          name: entry.name,
          isUser: entry.isUser,
          live: live,
          size: 40,
          ring: medal,
          onGold: entry.isUser,
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
                style: AppTypography.title(
                  size: 14,
                  weight: entry.isUser ? FontWeight.w900 : FontWeight.w800,
                  color: ink,
                ),
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
                _gapLabel,
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
                  color: entry.isUser
                      ? muted
                      : entry.walkedToday
                      ? AppColors.teal.withValues(alpha: 0.95)
                      : muted,
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
          decoration: BoxDecoration(
            gradient: entry.isUser ? AppGradients.gold : null,
            color: entry.isUser ? null : medal?.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: entry.isUser
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 1.4,
                  )
                : null,
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
    final progress = context.watch<ProgressService>();
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
        color: const Color(0xFF1A1408),
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
                  size: 8,
                  letterSpacing: 0,
                  weight: FontWeight.w900,
                  color: AppColors.medalGold,
                ),
              )
            : CinematicIcon(
                glyph: glyph,
                size: 13,
                accent: accent,
                framed: false,
              ),
      ),
    );
  }
}

class _PilgrimAvatar extends StatelessWidget {
  final String name;
  final bool isUser;
  final bool live;
  final double size;
  final Color? ring;
  final bool onGold;
  final String? photoUrl;
  final String? seed;
  final PortraitStyle style;

  const _PilgrimAvatar({
    required this.name,
    required this.isUser,
    this.live = false,
    this.size = 36,
    this.ring,
    this.onGold = false,
    this.photoUrl,
    this.seed,
    this.style = PortraitStyle.photo,
  });

  @override
  Widget build(BuildContext context) {
    final onPlate = isUser && onGold;
    final border = live
        ? AppColors.teal
        : ring ??
              (onPlate
                  ? Colors.white.withValues(alpha: 0.45)
                  : isUser
                  ? Colors.white.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.16));

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.nightMid,
            ),
            // Borda por cima do rosto — o retrato preenche o círculo todo.
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: border, width: live ? 2 : 1.2),
            ),
            child: PortraitFace(
              name: name,
              photoUrl: photoUrl,
              seed: seed,
              size: size,
              style: style,
            ),
          ),
          if (live)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size >= 48 ? 12 : 10,
                height: size >= 48 ? 12 : 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal,
                  border: Border.all(color: AppColors.night, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RankMark extends StatelessWidget {
  final int rank;
  final bool onGold;

  const _RankMark({required this.rank, this.onGold = false});

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
              color: onGold
                  ? AppColors.inkOnAccent.withValues(alpha: 0.72)
                  : a.textFaint,
            ),
          ),
        ),
      );
    }

    final fill = onGold ? AppColors.inkOnAccent : medal;
    final ink = onGold ? medal : AppColors.medalInk;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        boxShadow: onGold
            ? null
            : [
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
            size: 13,
            weight: FontWeight.w900,
            color: ink,
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
  final double size;

  const _AvatarCluster({required this.people, this.size = 24});

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();
    final shown = people.take(5).toList();
    final step = size * 0.62;
    return SizedBox(
      width: size + (shown.length - 1) * step,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * step,
              child: _PilgrimAvatar(
                name: shown[i].name,
                isUser: shown[i].isUser,
                live: shown[i].live,
                size: size,
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
    final a = Appearance.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpace.xl),
      child: Column(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.link,
            size: 40,
            accent: AppColors.clay,
            glowing: false,
          ),
          const SizedBox(height: 14),
          Text(
            'Companhia precisa da nuvem',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 24, color: a.text),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Entre com Google para caminhar com alguém de verdade.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.35,
              color: a.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          CopperCta(
            label: loading ? 'Conectando…' : 'Tentar de novo',
            onTap: loading ? null : onRetry,
            busy: loading,
            leading: CinematicGlyph.refresh,
            trailing: null,
            dense: true,
          ),
        ],
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
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BondMember(
                name: name.isEmpty ? 'Você' : name.split(' ').first,
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
            label: 'Convidar amigo',
            onTap: onInvite,
            leading: CinematicGlyph.people,
            trailing: null,
          ),
          const SizedBox(height: AppSpace.sm),
          GhostCta(
            label: 'Tenho um código',
            leading: CinematicGlyph.qr,
            expanded: true,
            onTap: onJoin,
          ),
        ],
      ],
    );
  }
}

/// Os três passos da companhia, lado a lado e ligados por um fio.
class _CompanionSteps extends StatelessWidget {
  const _CompanionSteps();

  static const _steps = [
    (CinematicGlyph.path, 'Os dois\nestudam'),
    (CinematicGlyph.flame, 'O dia conta\njuntos'),
    (CinematicGlyph.lamp, 'Se um atrasa,\no outro acena'),
  ];

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Stack(
      children: [
        Positioned(
          left: 40,
          right: 40,
          top: 19,
          child: Container(
            height: 1,
            color: AppColors.accent.withValues(alpha: 0.25),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final s in _steps)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.nightMid,
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Center(
                        child: CinematicIcon(
                          glyph: s.$1,
                          size: 18,
                          accent: AppColors.accent,
                          framed: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.$2,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 12,
                        height: 1.3,
                        weight: FontWeight.w700,
                        color: a.textSecondary,
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
        ? 'Companheiro'
        : companion.displayName;
    final myLabel = myName.trim().isEmpty
        ? 'Você'
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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (companion.sharedDays > 0)
            SoftBadge(
              text:
                  '${companion.sharedDays} ${companion.sharedDays == 1 ? 'dia' : 'dias'}',
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
                  ? 'Mandar no WhatsApp'
                  : 'Acenar para ${companion.partnerFirstName}',
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
              label: 'Sair da companhia',
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
    const dustTone = AppColors.dust;
    final a = Appearance.of(context);
    final status = walked
        ? 'Hoje'
        : dusty
        ? 'Na poeira'
        : (highlight ? 'Sua vez' : 'Ainda não');
    final tone = walked
        ? AppColors.accent
        : dusty
        ? dustTone
        : highlight
        ? AppColors.streak
        : a.textFaint;

    Widget avatar = _PilgrimAvatar(
      name: name,
      isUser: isUser,
      live: false,
      size: 60,
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
            size: 60,
            lit: walked || highlight,
            color: walked ? AppColors.accent : AppColors.streak,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: both ? AppColors.accent : AppColors.night,
        border: Border.all(
          color: both ? AppColors.accent : Colors.white.withValues(alpha: 0.18),
          width: 1.4,
        ),
        boxShadow: both
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.5),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Center(
        child: CinematicIcon(
          glyph: CinematicGlyph.link,
          size: 16,
          accent: both
              ? AppColors.inkOnAccent
              : Colors.white.withValues(alpha: 0.4),
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
        ? 'Você'
        : myName.trim().split(' ').first;
    final a = Appearance.of(context);
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              SectionLabel('Convite aberto', color: AppColors.accent),
              Spacer(),
              SoftBadge(text: 'Aguardando', glyph: CinematicGlyph.lamp),
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
            'Falta uma pessoa do outro lado',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 16, color: a.text),
          ),
          const SizedBox(height: AppSpace.md),
          _CodePlate(code: code, onCopy: onCopy),
          const SizedBox(height: AppSpace.md),
          CopperCta(
            label: 'Mostrar QR e compartilhar',
            onTap: onShowQr,
            leading: CinematicGlyph.qr,
            trailing: null,
            dense: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextCta(
              label: 'Cancelar convite',
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
            size: 60,
            lit: true,
            color: Colors.white.withValues(alpha: 0.5),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
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
            'Quem?',
            style: AppTypography.title(size: 14, color: a.textFaint),
          ),
        ],
      ),
    );
  }
}

/// Código grande, tocável para copiar.
class _CodePlate extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;

  const _CodePlate({required this.code, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Semantics(
      button: true,
      label: 'Código $code. Toque para copiar',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onCopy,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: a.insetFill,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                SectionLabel('Código', color: a.textFaint),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title(
                      size: 24,
                      weight: FontWeight.w900,
                      color: AppColors.accent,
                    ).copyWith(letterSpacing: 4),
                  ),
                ),
                CinematicIcon(
                  glyph: CinematicGlyph.copy,
                  size: 16,
                  accent: a.textSecondary,
                  framed: false,
                ),
                const SizedBox(width: 6),
                Text(
                  'Copiar',
                  style: AppTypography.body(
                    size: 13,
                    weight: FontWeight.w800,
                    color: a.textSecondary,
                  ),
                ),
              ],
            ),
          ),
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
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
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
            const SectionLabel('Esta semana', color: AppColors.accent),
            const Spacer(),
            Text(
              '$together de 7 juntos',
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
                  label: labels[i],
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
            _WeekLegend(me: true, them: false, label: 'você', style: a),
            _WeekLegend(
              me: false,
              them: true,
              label: companion.partnerFirstName,
              style: a,
            ),
            _WeekLegend(me: true, them: true, label: 'juntos', style: a),
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
              border: AppColors.accent.withValues(alpha: 0.55),
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
    final caption = shared == 0
        ? 'Primeiro marco: $next dias juntos'
        : shared >= marks.last
        ? 'Próximo marco: $next dias'
        : 'Faltam ${next - shared} para o marco de $next';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Marcos', color: AppColors.accent),
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
                  color: AppColors.accent,
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
                    ? AppColors.accent
                    : future
                    ? style.text.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
              child: both
                  ? const Center(
                      child: CinematicIcon(
                        glyph: CinematicGlyph.check,
                        size: 16,
                        accent: AppColors.inkOnAccent,
                        framed: false,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isToday ? 'hoje' : label,
          style: AppTypography.body(
            size: 11,
            weight: FontWeight.w800,
            color: isToday
                ? AppColors.accent
                : (future ? style.textFaint : style.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Bolinha da semana: metade esquerda é você, metade direita é o parceiro;
/// os dois = disco dourado inteiro, com brilho.
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
          ..color = AppColors.accent.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    canvas.drawCircle(center, radius, Paint()..color = empty);

    final fill = Paint()..color = AppColors.accent;
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
          ..color = AppColors.accent.withValues(alpha: 0.7),
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
                            ? AppColors.accent
                            : next == m
                            ? AppColors.streak
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
                color: AppColors.accent,
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
                  size: 14,
                  accent: AppColors.inkOnAccent,
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
      canvas.drawCircle(center, radius, Paint()..color = AppColors.accent);
      return;
    }
    canvas.drawCircle(center, radius, Paint()..color = empty);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = current ? 1.8 : 1.1
        ..color = current ? AppColors.streak : track,
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
          ..color = AppColors.accent,
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
        : 'Companheiro';
    final message = companion.incomingNudgeMessage?.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.lamp,
            size: 22,
            accent: AppColors.accent,
            framed: false,
            glowing: true,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$from acenou para você',
                  style: AppTypography.title(size: 14, color: AppColors.accent),
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
                      color: Appearance.of(context).textSecondary,
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
    final a = Appearance.of(context);
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      child: Column(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.people,
            size: 40,
            accent: AppColors.accent,
            glowing: false,
          ),
          const SizedBox(height: 14),
          Text(
            'A caravana ainda é pequena',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 24, color: a.text),
          ),
          const SizedBox(height: 8),
          Text(
            'O ranking aparece com pelo menos mais uma pessoa caminhando. Chame alguém para a caravana — ou comece por uma amizade.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.35,
              color: a.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Falha de carregamento com saída clara — em vez de só texto vermelho.
class _InlineErrorCard extends StatelessWidget {
  final String message;
  final bool busy;
  final Future<void> Function() onRetry;

  const _InlineErrorCard({
    required this.message,
    required this.busy,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      padding: AppMetrics.cardPaddingCompact,
      child: Row(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.wrong,
            size: 20,
            accent: AppColors.error,
            framed: false,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body(
                size: 13,
                height: 1.35,
                color: a.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          busy
              ? const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(child: AppSpinner(inline: true)),
                )
              : TextCta(
                  label: 'Tentar de novo',
                  leading: CinematicGlyph.refresh,
                  onTap: onRetry,
                ),
        ],
      ),
    );
  }
}
