import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/pilgrim_medal_models.dart';
import '../models/study_room.dart';
import '../models/walk_companion.dart';
import '../services/backend_service.dart';
import '../services/medal_engagement_service.dart';
import '../services/progress_service.dart';
import '../services/companion_service.dart';
import '../services/invite_deep_link_service.dart';
import '../services/league_service.dart';
import '../services/remote_config_service.dart';
import '../services/room_service.dart';
import '../services/app_update_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/caravan_pilgrim_sheet.dart';
import '../widgets/accept_invite_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/companion_formed_sheet.dart';
import '../widgets/companion_invite_confirm_sheet.dart';
import '../widgets/companion_nudge_sheet.dart';
import '../widgets/hero_card_atmosphere.dart';
import '../widgets/immersive_background.dart';
import '../widgets/invite_qr_sheet.dart';
import '../widgets/ui_primitives.dart';

class LeagueScreen extends StatefulWidget {
  final Widget? topBar;

  /// Quando a aba Juntos está visível — processa deep link pendente.
  final bool active;
  final VoidCallback? onOpenOwnProfile;

  const LeagueScreen({
    super.key,
    this.topBar,
    this.active = true,
    this.onOpenOwnProfile,
  });

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  List<LeagueEntry> _realPlayers = const [];
  List<LeagueEntry> _overallPlayers = const [];
  int _tab = 0; // 0 = caravana, 1 = companhia, 2 = salas
  bool _overallRanking = true;
  bool _handlingInvite = false;
  bool _playersLoading = false;
  bool _playersLoadedOnce = false;
  String? _playersError;
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
    if (links.takeWantCompanhiaTab()) {
      setState(() => _tab = 1);
    }
    final code = links.takePendingCompanionCode();
    if (code == null) return;
    _handlingInvite = true;
    setState(() => _tab = 1);
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
        backend.fetchOverallPlayers(),
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
      await companionSvc.refresh().timeout(const Duration(seconds: 10));
      await companionSvc
          .syncPresence(progress)
          .timeout(const Duration(seconds: 10));
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
              companionAlert:
                  context.watch<CompanionService>().incomingNudge != null,
              onChanged: (i) {
                HapticFeedback.selectionClick();
                setState(() => _tab = i);
              },
            ),
          ),
          const SizedBox(height: AppSpace.section),
          if (_tab == 0)
            ..._buildLeague(context)
          else if (_tab == 1)
            ..._buildCompanions(context)
          else
            ..._buildRooms(context),
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
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      ];
    }

    if (_playersLoading && !_playersLoadedOnce) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: AppSpace.xxxl + AppSpace.lg),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      ];
    }

    final overall = _overallRanking;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final backend = context.watch<BackendService>();
    final entries = overall
        ? league.overallStandings(
            userName: progress.userName,
            userTotalSteps: progress.steps,
            userUid: backend.uid,
            userLastWalkDate: progress.lastPlayedDate,
            userLastSeenDate: today,
            realPlayers: _overallPlayers,
          )
        : league.standings(
            userName: progress.userName,
            userWeeklySteps: progress.weeklySteps,
            userUid: backend.uid,
            userLastWalkDate: progress.lastPlayedDate,
            userLastSeenDate: today,
            realPlayers: _realPlayers,
          );
    final userRank = league.userRank(entries);
    if (overall && userRank == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        progress.recordLeaderDay();
      });
    }
    if (!overall && userRank > 0 && _playersLoadedOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<LeagueService>().observeWeeklyRank(userRank);
      });
    }
    final canPromote = league.tierIndex < LeagueTier.values.length - 1;
    final canDemote = league.tierIndex > 0;
    final a = Appearance.of(context);

    final children = <Widget>[
      _reveal(
        1,
        Center(
          child: _RankingPeriodTabs(
            overall: overall,
            onChanged: (value) => setState(() => _overallRanking = value),
          ),
        ),
      ),
      if (_playersError != null) ...[
        const SizedBox(height: AppSpace.md),
        Text(
          _playersError!,
          textAlign: TextAlign.center,
          style: AppTypography.body(size: 12, color: AppColors.error),
        ),
      ],
      const SizedBox(height: AppSpace.md),
    ];

    if (entries.length <= 1 && !_playersLoading) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
          child: Text(
            overall
                ? 'Ainda poucos peregrinos no ranking geral.\nPuxe para atualizar — ou caminhe hoje e volte.'
                : 'Nesta divisão da caravana ainda há pouca gente.\nContinue a missão — o grupo cresce com quem caminha.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.4,
              color: a.textMuted(0.7),
            ),
          ),
        ),
      );
    } else if (entries.isNotEmpty) {
      children.add(
        _reveal(
          3,
          _LeaderboardBoard(
            entries: entries,
            weekly: !overall,
            canPromote: !overall && canPromote,
            canDemote: !overall && canDemote,
            tierIndex: league.tierIndex,
            onOpenOwnProfile: widget.onOpenOwnProfile,
          ),
        ),
      );
    }
    return children;
  }

  List<Widget> _buildCompanions(BuildContext context) {
    final companions = context.watch<CompanionService>();
    final backend = context.watch<BackendService>();
    final progress = context.watch<ProgressService>();

    if (!companions.isLoaded) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: AppSpace.xxxl + AppSpace.lg),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      ];
    }

    if (!backend.isActive) {
      return [
        _reveal(
          1,
          _CompanionsOfflineCard(
            error: backend.lastError,
            loading: backend.isInitializing,
            onRetry: () => backend.retry(),
          ),
        ),
      ];
    }

    final active = companions.companions
        .where((c) => !c.awaitingPartner)
        .toList();
    final togetherToday = active.where((c) => c.bothWalkedToday).length;
    final waitingOnMe = active.where((c) => c.waitingOnMe).length;
    final bestStreak = companions.companions.isEmpty
        ? 0
        : companions.companions
              .map((c) => c.sharedDays)
              .reduce((a, b) => a > b ? a : b);

    final ordered = [...companions.companions]..sort((a, b) {
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

    final list = <Widget>[
      _reveal(
        1,
        _CompanhiaHeroCard(
          companionCount: companions.companions.length,
          activeCount: active.length,
          togetherToday: togetherToday,
          waitingOnMe: waitingOnMe,
          bestStreak: bestStreak,
          maxSlots: companions.maxCompanions,
        ),
      ),
      const SizedBox(height: AppSpace.section),
    ];

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
              await Clipboard.setData(
                ClipboardData(text: ordered[i].code),
              );
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
      list.add(const SizedBox(height: AppSpace.sm));
    }

    list.add(const SizedBox(height: AppSpace.sm));
    if (companions.canAdd) {
      list.add(
        Row(
          children: [
            Expanded(
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
    return list;
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
        glyph: CinematicGlyph.echo,
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
        glyph: CinematicGlyph.echo,
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

  Future<bool?> _confirmLeaveCompanion(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final a = Appearance.of(ctx);
        return AlertDialog(
          backgroundColor: a.cardFill,
          title: Text(
            'Sair da companhia?',
            style: AppTypography.title(color: a.text),
          ),
          content: Text(
            'A parceria com esta pessoa termina. A caravana continua.',
            style: TextStyle(color: a.textMuted(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Ficar', style: TextStyle(color: a.textMuted(0.7))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Sair',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
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
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
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

    if (!rooms.hasRoom) {
      return [
        _reveal(
          1,
          const _RoomsIntro(
            title: 'Estudem juntos',
            subtitle:
                'Crie uma sala privada para turma, célula ou amigos.\nRanking só de quem entrou — foco no grupo.',
          ),
        ),
        const SizedBox(height: AppSpace.section),
        _reveal(
          2,
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
    final userRank = members.indexWhere((m) => m.isUser) + 1;

    return [
      _reveal(
        2,
        _RoomHeader(
          room: room,
          rank: userRank > 0 ? userRank : null,
          memberCount: members.length,
          weeklySteps: progress.weeklySteps,
          isOwner: room.isOwner(backend.uid),
          onCopy: () async {
            await Clipboard.setData(ClipboardData(text: room.code));
            if (!context.mounted) return;
            showAppToastFor(
              context,
              message: 'Código copiado',
              glyph: CinematicGlyph.copy,
            );
          },
          onShowQr: () => showInviteQrSheet(
            context,
            code: room.code,
            title: room.name,
            subtitle: 'Escaneie o QR ou entre com o código',
            companionMode: false,
            inviterName: progress.userName,
            shareMessage:
                'Entre na sala "${room.name}" no Stway com o código ${room.code}.\n\n'
                'Ainda não tem o app? Baixe: ${AppUpdateService.androidStoreUrl}',
          ),
          onLeave: () async {
            final ok = await _confirmLeave(context);
            if (ok == true && context.mounted) {
              await context.read<RoomService>().leaveRoom(
                progress: context.read<ProgressService>(),
              );
            }
          },
          onRefresh: () => rooms.refreshMembers(),
          onEditGoal: () => _editRoomGoal(context, room.weeklyGoalSteps),
        ),
      ),
      const SizedBox(height: AppSpace.md),
      _reveal(
        2,
        _RoomWeekPulse(
          members: members,
          roomCode: room.code,
          walkedToday: progress.walkedToday,
          weeklyGoalSteps: room.weeklyGoalSteps,
          onClaim: () async {
            final week = LeagueService.weekKey();
            final chestId = 'room-pulse-$week-${room.code}';
            final bonus = RemoteConfigService.instance.roomChestBonusSteps;
            final ok = await progress.claimChest(chestId, bonus);
            if (!context.mounted) return;
            showAppToastFor(
              context,
              message: ok
                  ? 'Baú da sala · +$bonus passos'
                  : 'Baú já coletado nesta semana',
              glyph: ok ? CinematicGlyph.gem : CinematicGlyph.echo,
              tone: ok ? AppToastTone.accent : AppToastTone.warn,
            );
          },
        ),
      ),
      const SizedBox(height: AppSpace.md),
      if (rooms.lastError != null) ...[
        const SizedBox(height: AppSpace.md),
        Text(
          rooms.lastError!,
          textAlign: TextAlign.center,
          style: AppTypography.body(size: 12, color: AppColors.error),
        ),
      ],
      const SizedBox(height: AppSpace.md),
      if (rooms.loading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpace.xxl),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        )
      else if (members.isEmpty)
        Text(
          'Ainda sem participantes. Compartilhe o código ${room.code}.',
          textAlign: TextAlign.center,
          style: AppTypography.body(
            color: Appearance.of(context).textMuted(0.7),
          ),
        )
      else ...[
        _reveal(
          3,
          _LeaderboardBoard(
            entries: [
              for (final m in members)
                LeagueEntry(
                  uid: m.uid,
                  name: m.name,
                  steps: m.steps,
                  isUser: m.isUser,
                  lastWalkDate: m.lastWalk,
                ),
            ],
            weekly: true,
            canPromote: false,
            canDemote: false,
            title: 'Esta semana',
            onOpenOwnProfile: widget.onOpenOwnProfile,
          ),
        ),
      ],
    ];
  }

  /// Dono define (ou apaga, deixando em branco) a meta semanal de passos da sala.
  Future<void> _editRoomGoal(BuildContext context, int? current) async {
    final raw = await showDialog<String>(
      context: context,
      builder: (ctx) => _TextInputDialog(
        title: 'Meta semanal da sala',
        hint: 'Ex.: 500 (deixe em branco para tirar a meta)',
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

  Future<void> _showCreateRoom(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => const _TextInputDialog(
        title: 'Criar sala',
        hint: 'Ex.: Turma 7º ano',
        confirmLabel: 'Criar',
        maxLength: 40,
      ),
    );
    if (name == null || name.isEmpty || !context.mounted) return;
    final ok = await context.read<RoomService>().createRoom(
      name,
      context.read<ProgressService>(),
    );
    if (!context.mounted) return;
    if (ok) {
      showAppToastFor(
        context,
        message:
            'Sala criada! Código: ${context.read<RoomService>().activeCode}',
        glyph: CinematicGlyph.people,
      );
    }
  }

  Future<void> _showJoinRoom(BuildContext context) async {
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => const _TextInputDialog(
        title: 'Entrar na sala',
        hint: 'Código',
        confirmLabel: 'Entrar',
        maxLength: 8,
        capitalize: true,
        letterSpacing: 3,
      ),
    );
    if (code == null || code.isEmpty || !context.mounted) return;
    await context.read<RoomService>().joinRoom(
      code,
      context.read<ProgressService>(),
    );
  }

  Future<bool?> _confirmLeave(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final a = Appearance.of(ctx);
        return AlertDialog(
          backgroundColor: a.cardFill,
          title: Text(
            'Sair da sala?',
            style: AppTypography.title(color: a.text),
          ),
          content: Text(
            'Você sai do ranking desta sala. Pode entrar de novo com o código.',
            style: TextStyle(color: a.textMuted(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: a.textMuted(0.7)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Sair',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SegmentTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final bool companionAlert;

  const _SegmentTabs({
    required this.index,
    required this.onChanged,
    this.companionAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      radius: AppRadii.md,
      child: Row(
        children: [
          _seg(context, 0, 'Caravana', CinematicGlyph.podium),
          _seg(context, 1, 'Companhia', CinematicGlyph.path, alert: companionAlert),
          _seg(context, 2, 'Salas', CinematicGlyph.people),
        ],
      ),
    );
  }

  Widget _seg(
    BuildContext context,
    int i,
    String label,
    CinematicGlyph glyph, {
    bool alert = false,
  }) {
    final selected = index == i;
    final a = Appearance.of(context);
    final color = selected ? AppColors.accent : a.textMuted(0.55);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(i),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accent.withValues(alpha: 0.16)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: selected
                  ? Border.all(color: AppColors.accent.withValues(alpha: 0.55))
                  : null,
            ),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CinematicIcon(
                      glyph: glyph,
                      size: 22,
                      accent: color,
                      framed: false,
                    ),
                    if (alert)
                      Positioned(
                        right: -3,
                        top: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.streak,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTypography.label(
                    size: 11,
                    letterSpacing: 0.2,
                    weight: selected ? FontWeight.w900 : FontWeight.w700,
                    color: color,
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

class _RankingPeriodTabs extends StatelessWidget {
  final bool overall;
  final ValueChanged<bool> onChanged;

  const _RankingPeriodTabs({required this.overall, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: a.cardFillSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: a.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(context, label: 'Geral', value: true),
          _item(context, label: 'Semana', value: false),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required String label,
    required bool value,
  }) {
    final selected = overall == value;
    return AppSelectChip(
      label: label,
      selected: selected,
      onTap: () => onChanged(value),
      style: AppSelectChipStyle.solid,
      fontSize: 12,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.sm)),
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
            glyph: CinematicGlyph.path,
            size: 40,
            accent: AppColors.accent,
            glowing: false,
          ),
          const SizedBox(height: 14),
          Text(
            'Salas precisam da nuvem',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Entre com Google para caminhar na caravana ao vivo.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.35,
              color: a.textMuted(0.75),
            ),
          ),
          const SizedBox(height: 16),
          CopperCta(
            label: loading ? 'Conectando…' : 'Tentar de novo',
            onTap: loading ? null : onRetry,
            trailing: null,
            expanded: false,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          ),
          const SizedBox(height: 10),
          Text(
            'Faça login com Google ao abrir o app',
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

class _RoomsIntro extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RoomsIntro({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      children: [
        Text(
          'SALAS PRIVADAS',
          style: AppTypography.label(
            letterSpacing: 2,
            color: AppColors.accent.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.display(size: 30, height: 1.1),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 13,
            weight: FontWeight.w600,
            color: a.textMuted(0.58),
          ),
        ),
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
    final a = Appearance.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpace.xl),
      child: Column(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.people,
            size: 48,
            accent: AppColors.accent,
            glowing: true,
          ),
          const SizedBox(height: 14),
          Text(
            'Quem vai estudar com você?',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            'Crie uma sala e envie o código, ou entre em uma sala que alguém já preparou. A semana fica mais clara quando o grupo aparece no mesmo placar.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.45,
              color: a.textMuted(0.65),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _RoomBenefit(
                glyph: CinematicGlyph.lock,
                label: 'Só o grupo',
                detail: 'Entra com código',
                color: a.textMuted(0.78),
              ),
              const SizedBox(width: 8),
              _RoomBenefit(
                glyph: CinematicGlyph.people,
                label: 'Convide',
                detail: 'Envie o código',
                color: a.textMuted(0.78),
              ),
              const SizedBox(width: 8),
              _RoomBenefit(
                glyph: CinematicGlyph.podium,
                label: 'Ranking',
                detail: 'Placar da semana',
                color: a.textMuted(0.78),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (loading)
            const CircularProgressIndicator(color: AppColors.accent)
          else ...[
            CopperCta(
              label: 'Criar sala',
              onTap: onCreate,
              trailing: null,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            const SizedBox(height: 10),
            _OutlineAction(label: 'Entrar com código', onTap: onJoin),
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
              size: 16,
              accent: AppColors.accent.withValues(alpha: 0.9),
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
                size: 10,
                height: 1.2,
                weight: FontWeight.w600,
                color: a.textMuted(0.48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomWeekPulse extends StatelessWidget {
  final List<RoomMember> members;
  final String roomCode;
  final bool walkedToday;
  final int? weeklyGoalSteps;
  final VoidCallback onClaim;

  const _RoomWeekPulse({
    required this.members,
    required this.roomCode,
    required this.walkedToday,
    this.weeklyGoalSteps,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final total = members.length;
    final active = members.where((m) => m.walkedThisWeek).length;
    final today = members.where((m) => m.walkedToday()).length;
    final sumSteps = members.fold<int>(0, (sum, m) => sum + m.steps);
    final goal = weeklyGoalSteps;
    final goalReached = goal != null && goal > 0 && sumSteps >= goal;
    final week = LeagueService.weekKey();
    final chestId = 'room-pulse-$week-$roomCode';
    final claimed = progress.isChestClaimed(chestId);
    final ready =
        !claimed &&
        walkedToday &&
        total > 0 &&
        (goalReached || active * 2 >= total); // meta batida OU ≥50% caminhou

    return GlassCard(
      padding: AppMetrics.cardPadding,
      elevated: ready,
      accent: ready,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (today > 0)
                _AvatarCluster(
                  people: [
                    for (final m in members.where((m) => m.walkedToday()))
                      (
                        name: m.name,
                        isUser: m.isUser,
                        live: true,
                      ),
                  ],
                  size: 28,
                )
              else
                const CinematicIcon(
                  glyph: CinematicGlyph.people,
                  size: 28,
                  accent: AppColors.accent,
                  glowing: false,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pulso da semana',
                      style: AppTypography.display(
                        size: 18,
                        weight: FontWeight.w800,
                        color: a.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      total == 0
                          ? 'Convide alguém para a sala'
                          : '$active de $total caminharam · $today hoje',
                      style: AppTypography.body(
                        size: 13,
                        color: a.textMuted(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 12),
            AppProgressBar(
              value: (active / total).clamp(0.0, 1.0),
              color: AppColors.accent,
            ),
          ],
          if (goal != null && goal > 0) ...[
            const SizedBox(height: 10),
            Text(
              '$sumSteps de $goal passos da meta do grupo',
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: a.textMuted(0.7),
              ),
            ),
            const SizedBox(height: 6),
            AppProgressBar(
              value: (sumSteps / goal).clamp(0.0, 1.0),
              color: AppColors.streak,
            ),
          ],
          const SizedBox(height: 14),
          if (claimed)
            Text(
              'Baú da sala já coletado nesta semana',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: a.textMuted(0.55),
              ),
            )
          else
            Opacity(
              opacity: ready ? 1 : 0.55,
              child: CopperCta(
                label: ready
                    ? 'Abrir baú do grupo · +${RemoteConfigService.instance.roomChestBonusSteps}'
                    : walkedToday
                    ? (goal != null && goal > 0
                          ? 'Baú libera com metade do grupo ou a meta'
                          : 'Baú libera com metade do grupo')
                    : 'Caminhe hoje para liberar o baú',
                onTap: ready ? onClaim : null,
                expanded: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _RoomHeader extends StatelessWidget {
  final StudyRoom room;
  final int? rank;
  final int memberCount;
  final int weeklySteps;
  final bool isOwner;
  final VoidCallback onCopy;
  final VoidCallback onShowQr;
  final VoidCallback onLeave;
  final VoidCallback onRefresh;
  final VoidCallback? onEditGoal;

  const _RoomHeader({
    required this.room,
    required this.rank,
    required this.memberCount,
    required this.weeklySteps,
    required this.isOwner,
    required this.onCopy,
    required this.onShowQr,
    required this.onLeave,
    required this.onRefresh,
    this.onEditGoal,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final days = LeagueService.daysLeft();
    final closesText = days <= 1 ? 'Fecha hoje' : '$days dias';

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        children: [
          Row(
            children: [
              const CinematicIcon(
                glyph: CinematicGlyph.people,
                size: 42,
                accent: AppColors.accent,
                glowing: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOwner ? 'Sua sala' : 'Sala',
                      style: AppTypography.label(
                        letterSpacing: 1.5,
                        color: AppColors.accent.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      room.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.display(size: 26, height: 1.05),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Criada por ${room.ownerName}',
              style: AppTypography.body(
                size: 12,
                color: a.textMuted(0.65),
              ).copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: a.cardFillSoft,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.32),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Código da sala',
                          style: AppTypography.label(
                            letterSpacing: 0,
                            color: a.textMuted(0.58),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          room.code,
                          style: AppTypography.title(
                            size: 22,
                            weight: FontWeight.w900,
                            color: AppColors.accent,
                          ).copyWith(letterSpacing: 4),
                        ),
                      ],
                    ),
                  ),
                  CinematicIcon(
                    glyph: CinematicGlyph.copy,
                    size: 20,
                    accent: a.textMuted(0.72),
                    framed: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CopperCta(
                  label: 'Compartilhar QR',
                  onTap: onShowQr,
                  leading: CinematicGlyph.qr,
                  trailing: null,
                  dense: true,
                ),
              ),
              const SizedBox(width: 10),
              _RoomIconButton(
                glyph: CinematicGlyph.echo,
                label: 'Atualizar',
                onTap: onRefresh,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _RoomStatChip(
                label: 'Seu lugar',
                value: rank == null ? '--' : '$rankº',
                accent: rank != null,
              ),
              const SizedBox(width: 8),
              _RoomStatChip(label: 'Pessoas', value: '$memberCount'),
              const SizedBox(width: 8),
              _RoomStatChip(label: 'Você', value: '$weeklySteps'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.calendar,
                size: 14,
                accent: AppColors.streak.withValues(alpha: 0.95),
                framed: false,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Semana da caravana: $closesText',
                  style: AppTypography.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: a.textMuted(0.72),
                  ),
                ),
              ),
              if (isOwner && onEditGoal != null)
                TextButton(
                  onPressed: onEditGoal,
                  child: Text(
                    room.weeklyGoalSteps != null ? 'Meta' : 'Definir meta',
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: a.textMuted(0.55),
                    ),
                  ),
                ),
              TextButton(
                onPressed: onLeave,
                child: Text(
                  'Sair',
                  style: AppTypography.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: a.textMuted(0.55),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoomIconButton extends StatelessWidget {
  final CinematicGlyph glyph;
  final String label;
  final VoidCallback onTap;

  const _RoomIconButton({
    required this.glyph,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: a.cardFillSoft,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: a.cardBorder),
        ),
        child: Column(
          children: [
            CinematicIcon(
              glyph: glyph,
              size: 17,
              accent: AppColors.accent.withValues(alpha: 0.9),
              framed: false,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.label(
                size: 9,
                letterSpacing: 0,
                color: a.textMuted(0.68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomStatChip extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _RoomStatChip({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          gradient: accent ? AppGradients.gold : null,
          color: accent ? null : a.cardFillSoft,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: accent ? Colors.white.withValues(alpha: 0.45) : a.cardBorder,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(
                size: 15,
                weight: FontWeight.w900,
                color: accent ? AppColors.inkOnAccent : AppColors.accent,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(
                size: 10,
                letterSpacing: 0,
                color: accent
                    ? AppColors.inkOnAccent.withValues(alpha: 0.75)
                    : a.textMuted(0.58),
              ),
            ),
          ],
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
    return AlertDialog(
      backgroundColor: a.cardFill,
      title: Text(widget.title, style: AppTypography.display(size: 24)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        textCapitalization: widget.capitalize
            ? TextCapitalization.characters
            : TextCapitalization.none,
        style: AppTypography.body(
          weight: widget.capitalize ? FontWeight.w800 : FontWeight.w500,
        ).copyWith(letterSpacing: widget.letterSpacing),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTypography.body(color: a.textMuted(0.5)),
          filled: true,
          fillColor: a.cardFillSoft,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: AppTypography.body(color: a.textMuted(0.7)),
          ),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.inkOnAccent,
          ),
          child: Text(widget.confirmLabel, style: AppTypography.cta()),
        ),
      ],
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  final String text;
  final bool up;

  const _ZoneLabel({required this.text, required this.up});

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
            child: Text(
              text,
              style: AppTypography.label(
                size: 10,
                letterSpacing: 1.2,
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneDivider extends StatelessWidget {
  const _ZoneDivider();

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

class _LeaderboardBoard extends StatelessWidget {
  final List<LeagueEntry> entries;
  final bool weekly;
  final bool canPromote;
  final bool canDemote;
  final int tierIndex;
  final String? title;
  final VoidCallback? onOpenOwnProfile;

  const _LeaderboardBoard({
    required this.entries,
    required this.weekly,
    required this.canPromote,
    required this.canDemote,
    this.tierIndex = 0,
    this.title,
    this.onOpenOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final leaderSteps = entries.first.steps;
    final heading = title ??
        (weekly ? 'Esta semana' : 'Toda a jornada');
    final today = entries.where((e) => e.walkedToday).toList();
    final rows = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 2, 10, 8),
        child: Row(
          children: [
            Text(
              heading.toUpperCase(),
              style: AppTypography.label(
                size: 10,
                letterSpacing: 1.4,
                color: AppColors.accent.withValues(alpha: 0.9),
              ),
            ),
            const Spacer(),
            if (today.isNotEmpty) ...[
              _AvatarCluster(
                people: [
                  for (final e in today.take(5))
                    (
                      name: e.name,
                      isUser: e.isUser,
                      live: true,
                    ),
                ],
                size: 22,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              today.isEmpty
                  ? '${entries.length}'
                  : '${today.length} hoje',
              style: AppTypography.label(
                size: 10,
                letterSpacing: 0,
                color: a.textMuted(0.5),
              ),
            ),
          ],
        ),
      ),
    ];

    for (var i = 0; i < entries.length; i++) {
      final rank = i + 1;
      if (weekly && rank == 1 && canPromote) {
        rows.add(
          _ZoneLabel(
            text:
                'ZONA DE SUBIDA · ${LeagueTier.values[tierIndex + 1].shortLabel.toUpperCase()}',
            up: true,
          ),
        );
      }
      if (weekly &&
          rank ==
              LeagueService.groupSize - LeagueService.demoteCount + 1 &&
          canDemote) {
        rows.add(
          _ZoneLabel(
            text:
                'ZONA DE DESCIDA · ${LeagueTier.values[tierIndex - 1].shortLabel.toUpperCase()}',
            up: false,
          ),
        );
      }
      rows.add(
        _StandingRow(
          entry: entries[i],
          rank: rank,
          weeklySteps: weekly,
          gapToLeader: rank == 1 ? 0 : leaderSteps - entries[i].steps,
          shareOfLeader: leaderSteps <= 0
              ? 0
              : (entries[i].steps / leaderSteps).clamp(0.0, 1.0),
          onOpenOwnProfile: onOpenOwnProfile,
        ),
      );
      if (weekly && rank == LeagueService.promoteCount && canPromote) {
        rows.add(const _ZoneDivider());
      }
    }

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
      child: Column(children: rows),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final LeagueEntry entry;
  final int rank;
  final bool weeklySteps;
  final int gapToLeader;
  final double shareOfLeader;
  final VoidCallback? onOpenOwnProfile;

  const _StandingRow({
    required this.entry,
    required this.rank,
    required this.weeklySteps,
    this.gapToLeader = 0,
    this.shareOfLeader = 0,
    this.onOpenOwnProfile,
  });

  Color _ink(AppearanceStyle a) {
    return entry.isUser ? AppColors.inkOnAccent : a.text;
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
    final stepsTone = entry.isUser
        ? AppColors.inkOnAccent
        : (medal ?? AppColors.accent).withValues(alpha: 0.95);
    final gapLabel = gapToLeader <= 0 ? 'líder' : '−$gapToLeader';

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _PilgrimAvatar(
          name: entry.name,
          isUser: entry.isUser,
          live: entry.walkedToday || entry.isOnlineToday,
          size: 40,
          ring: medal,
          rank: rank,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.isUser ? '${entry.name} (você)' : entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body(
                  size: 14,
                  weight: entry.isUser ? FontWeight.w900 : FontWeight.w700,
                  color: _ink(a),
                ),
              ),
              if (entry.isUser && !weeklySteps)
                const _UserMedalBadge()
              else if (entry.activitySummary != null)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    entry.activitySummary!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(
                      size: 10,
                      letterSpacing: 0,
                      weight: FontWeight.w700,
                      color: entry.isUser
                          ? AppColors.inkOnAccent.withValues(alpha: 0.62)
                          : entry.walkedToday
                          ? AppColors.teal.withValues(alpha: 0.95)
                          : a.textMuted(0.5),
                    ),
                  ),
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
            Text(
              gapLabel,
              style: AppTypography.label(
                size: 9,
                letterSpacing: 0.2,
                color: entry.isUser
                    ? AppColors.inkOnAccent.withValues(alpha: 0.62)
                    : a.textMuted(0.45),
              ),
            ),
          ],
        ),
      ],
    );

    final row = entry.isUser
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              gradient: AppGradients.gold,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: content,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (shareOfLeader > 0)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: shareOfLeader.clamp(0.06, 1),
                          heightFactor: 1,
                          child: ColoredBox(
                            color: (medal ?? AppColors.accent)
                                .withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                  child: content,
                ),
              ],
            ),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (entry.isUser) {
            onOpenOwnProfile?.call();
            return;
          }
          showCaravanPilgrimSheet(
            context,
            entry: entry,
            rank: rank,
            weeklySteps: weeklySteps,
          );
        },
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: row,
      ),
    );
  }
}

/// Medalhas raras na linha do usuário — só no ranking geral da jornada.
class _UserMedalBadge extends StatelessWidget {
  const _UserMedalBadge();

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final uid = context.read<BackendService>().uid ?? '';

    return FutureBuilder<List<Object>>(
      future: Future.wait<Object>([
        MedalEngagementService.unlockedRareMedalsCached(progress, uid),
        MedalEngagementService.unlockedCountCached(progress, uid),
      ]),
      builder: (context, snapshot) {
        final rares = snapshot.data?[0] as List<PilgrimMedalDef>? ?? const [];
        final total = snapshot.data?[1] as int? ?? 0;
        if (rares.isEmpty && total <= 0) return const SizedBox.shrink();

        final shown = rares.take(3).toList();
        final extraRares = rares.length - shown.length;
        const label = AppColors.inkOnAccent;

        return Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (shown.isEmpty)
                const CinematicIcon(
                  glyph: CinematicGlyph.gem,
                  size: 16,
                  accent: AppColors.medalGold,
                  framed: false,
                ),
              for (final def in shown) ...[
                CinematicIcon(
                  glyph: def.glyph,
                  size: 16,
                  accent: MedalEngagementService.tierColor(def.tier),
                  framed: false,
                ),
                const SizedBox(width: 3),
              ],
              if (extraRares > 0) ...[
                Text(
                  '+$extraRares',
                  style: AppTypography.label(
                    size: 9,
                    letterSpacing: 0.2,
                    color: label.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                rares.isNotEmpty
                    ? '${rares.length} rara${rares.length == 1 ? '' : 's'}'
                    : '$total medalha${total == 1 ? '' : 's'}',
                style: AppTypography.label(
                  size: 9,
                  letterSpacing: 0.2,
                  weight: FontWeight.w700,
                  color: label.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PilgrimAvatar extends StatelessWidget {
  final String name;
  final bool isUser;
  final bool live;
  final double size;
  final Color? ring;
  final int? rank;

  const _PilgrimAvatar({
    required this.name,
    required this.isUser,
    this.live = false,
    this.size = 36,
    this.ring,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    final border = live
        ? AppColors.teal
        : ring ??
            (isUser
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isUser ? AppGradients.gold : null,
              color: isUser
                  ? null
                  : AppColors.primaryLight.withValues(alpha: 0.28),
              border: Border.all(color: border, width: live ? 2 : 1.2),
            ),
            child: Center(
              child: Text(
                initial,
                style: AppTypography.title(
                  size: size >= 52 ? 22 : size >= 38 ? 16 : 13,
                  weight: FontWeight.w900,
                  color: isUser ? AppColors.inkOnAccent : a.text,
                ),
              ),
            ),
          ),
          if (rank != null)
            Positioned(
              left: -3,
              top: -3,
              child: _RankPip(rank: rank!),
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

class _RankPip extends StatelessWidget {
  final int rank;

  const _RankPip({required this.rank});

  @override
  Widget build(BuildContext context) {
    final fill = switch (rank) {
      1 => AppColors.medalGold,
      2 => AppColors.medalSilver,
      3 => AppColors.medalBronze,
      _ => AppColors.nightElevated,
    };
    final ink = rank <= 3 ? AppColors.medalInk : AppColors.accent;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: AppColors.night, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$rank',
          style: AppTypography.title(
            size: 10,
            weight: FontWeight.w900,
            color: ink,
          ),
        ),
      ),
    );
  }
}

class _AvatarCluster extends StatelessWidget {
  final List<({String name, bool isUser, bool live})> people;
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
            glyph: CinematicGlyph.path,
            size: 40,
            accent: AppColors.accent,
            glowing: false,
          ),
          const SizedBox(height: 14),
          Text(
            'Companhia precisa da nuvem',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Entre com Google para caminhar com alguém de verdade.',
            textAlign: TextAlign.center,
            style: AppTypography.body(size: 13, color: a.textMuted(0.7)),
          ),
          const SizedBox(height: 16),
          if (loading)
            const CircularProgressIndicator(color: AppColors.accent)
          else
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Tentar de novo',
                style: AppTypography.body(
                  weight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
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
    final a = Appearance.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpace.xl),
      child: Column(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.path,
            size: 44,
            accent: AppColors.accent,
            glowing: false,
          ),
          const SizedBox(height: 14),
          Text(
            'Quem caminha ao seu lado?',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            'Até 3 pares. Sem disputa — o foco é presença: quando os dois dão um passo no dia, a companhia avança.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.45,
              color: a.textMuted(0.65),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CompanhiaPerk(
                  glyph: CinematicGlyph.flame,
                  label: 'Dias juntos',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompanhiaPerk(
                  glyph: CinematicGlyph.seed,
                  label: 'Marcos',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompanhiaPerk(
                  glyph: CinematicGlyph.people,
                  label: 'Presença',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (loading)
            const CircularProgressIndicator(color: AppColors.accent)
          else ...[
            CopperCta(
              label: 'Convidar amigo',
              onTap: onInvite,
              leading: CinematicGlyph.people,
            ),
            const SizedBox(height: 10),
            GhostCta(
              label: 'Aceitar convite',
              leading: CinematicGlyph.qr,
              onTap: onJoin,
            ),
          ],
        ],
      ),
    );
  }
}

class _CompanhiaPerk extends StatelessWidget {
  final CinematicGlyph glyph;
  final String label;

  const _CompanhiaPerk({required this.glyph, required this.label});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: 22,
            accent: AppColors.accent,
            framed: false,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0,
              weight: FontWeight.w700,
              color: a.textMuted(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanhiaHeroCard extends StatelessWidget {
  final int companionCount;
  final int activeCount;
  final int togetherToday;
  final int waitingOnMe;
  final int bestStreak;
  final int maxSlots;

  const _CompanhiaHeroCard({
    required this.companionCount,
    required this.activeCount,
    required this.togetherToday,
    this.waitingOnMe = 0,
    required this.bestStreak,
    required this.maxSlots,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final hasAny = companionCount > 0;
    final goldLine = waitingOnMe > 0
        ? waitingOnMe == 1
            ? 'Alguém te espera hoje'
            : '$waitingOnMe te esperam hoje'
        : !hasAny
        ? 'Até $maxSlots amigos íntimos'
        : bestStreak > 0
        ? '$bestStreak ${bestStreak == 1 ? 'dia' : 'dias'} juntos'
        : togetherToday > 0
        ? '$togetherToday caminharam hoje'
        : '$activeCount de $companionCount ativos';

    final goldSub = waitingOnMe > 0
        ? 'Dê seu passo — a companhia só conta quando os dois caminham'
        : !hasAny
        ? 'Convide alguém e andem lado a lado'
        : bestStreak > 0
        ? togetherToday > 0
              ? '$togetherToday juntos hoje · sem disputa, só presença'
              : 'Sem disputa — só presença compartilhada'
        : 'Quando os dois caminham, o dia conta';

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          Text(
            goldLine,
            textAlign: TextAlign.center,
            style: AppTypography.title(
              size: 18,
              weight: FontWeight.w900,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            goldSub,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 12,
              height: 1.35,
              color: a.textMuted(0.65),
            ),
          ),
          if (hasAny) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _CompanhiaStatChip(
                    label: 'Hoje',
                    value: '$togetherToday/$activeCount',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CompanhiaStatChip(
                    label: 'Vagas',
                    value: '$companionCount/$maxSlots',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CompanhiaStatChip(
                    label: 'Recorde',
                    value: bestStreak > 0 ? '${bestStreak}d' : '—',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CompanhiaStatChip extends StatelessWidget {
  final String label;
  final String value;

  const _CompanhiaStatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.title(
              size: 16,
              weight: FontWeight.w900,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0,
              color: a.textMuted(0.55),
            ),
          ),
        ],
      ),
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
    final a = Appearance.of(context);
    final partnerLabel = companion.awaitingPartner
        ? 'Convite'
        : (companion.displayName.isEmpty
              ? 'Companheiro'
              : companion.displayName);
    final myLabel = myName.trim().isEmpty
        ? 'Você'
        : myName.trim().split(' ').first;
    final away = companion.theyDaysAway;
    final showAwayBadge =
        !companion.awaitingPartner &&
        away != null &&
        away >= 1 &&
        !companion.theyWalkedToday;
    final insight = companion.insightLine;
    final canNudge =
        onNudge != null &&
        !companion.awaitingPartner &&
        (companion.waitingOnThem || (away != null && away >= 1));

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      elevated: companion.bothWalkedToday ||
          companion.hasIncomingNudge ||
          companion.waitingOnMe,
      accent: companion.waitingOnMe || companion.hasIncomingNudge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (companion.waitingOnMe) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.streak.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(
                  color: AppColors.streak.withValues(alpha: 0.55),
                ),
              ),
              child: Text(
                'Sua vez — $partnerLabel já caminhou',
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w800,
                  color: AppColors.streak,
                ),
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  companion.awaitingPartner ? 'Convite aberto' : partnerLabel,
                  style: AppTypography.title(
                    size: 16,
                    weight: FontWeight.w900,
                    color: a.text,
                  ),
                ),
              ),
              if (showAwayBadge)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.clay.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    away == 1 ? '1d fora' : '${away}d fora',
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w900,
                      color: AppColors.clay,
                    ),
                  ),
                ),
              if (companion.sharedDays > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.streak.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CinematicIcon(
                        glyph: CinematicGlyph.flame,
                        size: 14,
                        accent: AppColors.streak,
                        framed: false,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${companion.sharedDays}d juntos',
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w900,
                          color: AppColors.streak,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            companion.statusLine,
            style: AppTypography.body(
              size: 12,
              height: 1.3,
              color: a.textMuted(0.7),
            ),
          ),
          if (insight != null) ...[
            const SizedBox(height: 4),
            Text(
              insight,
              style: AppTypography.body(
                size: 12,
                height: 1.3,
                weight: FontWeight.w700,
                color: AppColors.accent.withValues(alpha: 0.85),
              ),
            ),
          ],
          if (!companion.awaitingPartner) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _PresencePill(
                    name: myLabel,
                    walked: companion.iWalkedToday,
                    highlight: companion.waitingOnMe,
                    dusty: false,
                    isUser: true,
                    subtitle: companion.myWeeklySteps > 0
                        ? '${companion.myWeeklySteps} passos'
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CinematicIcon(
                    glyph: companion.bothWalkedToday
                        ? CinematicGlyph.star
                        : CinematicGlyph.path,
                    size: 18,
                    accent: companion.bothWalkedToday
                        ? AppColors.accent
                        : a.textMuted(0.4),
                    framed: false,
                  ),
                ),
                Expanded(
                  child: _PresencePill(
                    name: partnerLabel,
                    walked: companion.theyWalkedToday,
                    highlight: companion.waitingOnThem,
                    dusty: companion.theyAreDusty,
                    subtitle: companion.theirWeeklySteps > 0
                        ? '${companion.theirWeeklySteps} passos'
                        : (showAwayBadge
                              ? (away == 1 ? 'ontem' : '${away}d atrás')
                              : null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Marco ${companion.nextMilestone}d',
                  style: AppTypography.label(
                    size: 11,
                    letterSpacing: 0,
                    weight: FontWeight.w700,
                    color: a.textMuted(0.55),
                  ),
                ),
                const Spacer(),
                Text(
                  '${companion.sharedDays}/${companion.nextMilestone}',
                  style: AppTypography.label(
                    size: 11,
                    letterSpacing: 0,
                    weight: FontWeight.w800,
                    color: AppColors.accent.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AppProgressBar(
              value: companion.milestoneProgress,
              color: companion.bothWalkedToday
                  ? AppColors.accent
                  : AppColors.accent.withValues(alpha: 0.75),
            ),
          ],
          if (companion.hasIncomingNudge) ...[
            const SizedBox(height: 12),
            _IncomingNudgeBanner(companion: companion),
          ],
          if (canNudge) ...[
            const SizedBox(height: 12),
            CopperCta(
              label: companion.iNudgedToday
                  ? 'Mandar no WhatsApp'
                  : 'Animar ${companion.partnerFirstName}',
              onTap: onNudge,
              leading: companion.iNudgedToday
                  ? CinematicGlyph.share
                  : CinematicGlyph.lamp,
              trailing: null,
              dense: true,
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              if (companion.awaitingPartner) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: onCopy,
                    child: Text(
                      'Código ${companion.code}',
                      style: AppTypography.label(
                        size: 12,
                        letterSpacing: 1.2,
                        color: AppColors.accent.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onShowQr,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CinematicIcon(
                        glyph: CinematicGlyph.qr,
                        size: 18,
                        accent: AppColors.accent,
                        framed: false,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'QR',
                        style: AppTypography.label(
                          size: 12,
                          letterSpacing: 0,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                const Spacer(),
              TextButton(
                onPressed: onLeave,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                ),
                child: Text(
                  'Sair',
                  style: AppTypography.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: a.textMuted(0.55),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PresencePill extends StatelessWidget {
  final String name;
  final bool walked;
  final bool highlight;
  final bool dusty;
  final bool isUser;
  final String? subtitle;

  const _PresencePill({
    required this.name,
    required this.walked,
    required this.highlight,
    this.dusty = false,
    this.isUser = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final status = walked
        ? 'Caminhou'
        : dusty
        ? 'Na poeira'
        : (highlight ? 'Esperando' : 'Ainda não');
    final dustBorder = const Color(0xFFC4A070);
    final dustFill = const Color(0xFF3A2410);

    final pill = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: walked
                  ? AppColors.accent.withValues(alpha: 0.12)
                  : dusty
                  ? dustFill.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: walked
                    ? AppColors.accent.withValues(alpha: 0.45)
                    : dusty
                    ? dustBorder.withValues(alpha: 0.55)
                    : highlight
                    ? AppColors.streak.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.1),
                width: walked || highlight || dusty ? 1.4 : 1,
              ),
            ),
            child: Column(
              children: [
                _PilgrimAvatar(
                  name: name,
                  isUser: isUser,
                  live: walked,
                  size: 40,
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    size: 12,
                    weight: FontWeight.w800,
                    color: dusty
                        ? Colors.white.withValues(alpha: 0.78)
                        : a.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: AppTypography.label(
                    size: 10,
                    letterSpacing: 0,
                    weight: FontWeight.w700,
                    color: walked
                        ? AppColors.accent
                        : dusty
                        ? dustBorder
                        : highlight
                        ? AppColors.streak
                        : a.textMuted(0.5),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(
                      size: 9,
                      letterSpacing: 0,
                      weight: FontWeight.w600,
                      color: dusty
                          ? dustBorder.withValues(alpha: 0.75)
                          : a.textMuted(0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (dusty)
            const Positioned.fill(
              child: HeroCardAtmosphere(mood: HeroCardMood.dusty),
            ),
        ],
      ),
    );

    if (!dusty) return pill;
    return HeroCardColorGrade(mood: HeroCardMood.dusty, child: pill);
  }
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
                  '$from te animou',
                  style: AppTypography.title(size: 13, color: AppColors.accent),
                ),
                if (message != null && message.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      size: 12,
                      height: 1.3,
                      color: Colors.white.withValues(alpha: 0.78),
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

class _OutlineAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _OutlineAction({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlineCta(label: label, onTap: onTap);
  }
}
