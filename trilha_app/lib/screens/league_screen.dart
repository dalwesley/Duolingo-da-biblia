import 'dart:async';
import 'dart:math' as math;

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
import '../widgets/portrait_face.dart';
import '../widgets/recognition_actions.dart';

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
    final roomCode = links.takePendingRoomCode();
    if (roomCode != null) {
      links.takeWantGruposTab();
      _handlingInvite = true;
      setState(() => _tab = 2);
      try {
        await _joinRoomWithCode(context, roomCode);
      } finally {
        _handlingInvite = false;
      }
      return;
    }
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
      await companionSvc.refresh().timeout(const Duration(seconds: 10));
      final result = await companionSvc
          .syncPresence(progress)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (result.weekTogetherBonusGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'A dupla ganhou +${WalkCompanion.weekTogetherBonusSteps} na caravana',
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
            userPhotoUrl: backend.userPhotoUrl,
            userPortraitStyle: progress.settings.portraitStyle,
            realPlayers: _overallPlayers,
          )
        : league.standings(
            userName: progress.userName,
            userWeeklySteps: progress.weeklySteps,
            userUid: backend.uid,
            userLastWalkDate: progress.lastPlayedDate,
            userLastSeenDate: today,
            userPhotoUrl: backend.userPhotoUrl,
            userPortraitStyle: progress.settings.portraitStyle,
            realPlayers: _realPlayers,
          );
    final userRank = league.userRank(entries);
    if (overall &&
        userRank == 1 &&
        LeagueService.fieldIsCompetitive(_overallPlayers.length)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        progress.recordLeaderDay();
      });
    }
    if (!overall &&
        userRank > 0 &&
        _playersLoadedOnce &&
        LeagueService.fieldIsCompetitive(_realPlayers.length)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<LeagueService>().observeWeeklyRank(userRank);
      });
    }
    final canPromote = league.tierIndex < LeagueTier.values.length - 1;
    final canDemote = league.tierIndex > 0;

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

    if (!LeagueService.fieldIsCompetitive(
          overall ? _overallPlayers.length : _realPlayers.length,
        ) &&
        !_playersLoading) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
          child: _CaravanEmptyCard(
            overall: overall,
            onInvite: () {
              setState(() => _tab = 1);
              _createCompanion(context);
            },
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

    final weekTogetherDays = active.isEmpty
        ? 0
        : active
            .map((c) => c.togetherDaysThisWeek())
            .reduce((a, b) => a > b ? a : b);

    final list = <Widget>[];

    // Com dupla viva, o card da pessoa já é a presença — sem hero duplicado.
    if (companions.companions.isEmpty) {
      list.add(
        _reveal(
          1,
          _CompanhiaHeroCard(
            companionCount: 0,
            activeCount: 0,
            togetherToday: 0,
            waitingOnMe: 0,
            bestStreak: 0,
            weekTogetherDays: 0,
          ),
        ),
      );
      list.add(const SizedBox(height: AppSpace.section));
    } else if (active.isEmpty) {
      // Só convite pendente — hero curto.
      list.add(
        _reveal(
          1,
          _CompanhiaHeroCard(
            companionCount: companions.companions.length,
            activeCount: 0,
            togetherToday: togetherToday,
            waitingOnMe: waitingOnMe,
            bestStreak: bestStreak,
            weekTogetherDays: weekTogetherDays,
          ),
        ),
      );
      list.add(const SizedBox(height: AppSpace.section));
    }

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
      list.add(const SizedBox(height: AppSpace.md));
    }

    final hasLive = ordered.any((c) => !c.awaitingPartner);
    if (hasLive) {
      list.add(_reveal(6, const _CompanionGuideCard()));
      list.add(const SizedBox(height: AppSpace.section));
    }

    if (companions.companions.length > 1) {
      list.add(
        TextButton(
          onPressed: companions.loading
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
          child: Text(
            'Encerrar todas as duplas',
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w700,
              color: AppColors.error.withValues(alpha: 0.85),
            ),
          ),
        ),
      );
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

  Future<bool?> _confirmLeaveAllCompanions(BuildContext context, int count) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final a = Appearance.of(ctx);
        return AlertDialog(
          backgroundColor: a.cardFill,
          title: Text(
            'Encerrar todas as duplas?',
            style: AppTypography.title(color: a.text),
          ),
          content: Text(
            count == 1
                ? 'A parceria termina. Você fica sem companhia.'
                : 'As $count parcerias terminam. Você fica sem companhia.',
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
                'Encerrar todas',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
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
                'Crie o grupo e mande o código.\nVeja quem estudou nesta semana.',
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
                  ? 'Baú do grupo · +$bonus passos'
                  : 'Baú já coletado nesta semana',
              glyph: ok ? CinematicGlyph.gift : CinematicGlyph.wrong,
              tone: ok ? AppToastTone.accent : AppToastTone.warn,
            );
          },
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
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        )
      else if (members.isEmpty)
        Text(
          'Ninguém entrou ainda. Envie o código ${room.code}.',
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
                  photoUrl: m.isUser ? backend.userPhotoUrl : m.photoUrl,
                  portraitStyle: m.isUser
                      ? progress.settings.portraitStyle
                      : m.portraitStyle,
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

  Future<void> _showCreateRoom(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => const _TextInputDialog(
        title: 'Nome do grupo',
        hint: 'Ex.: Célula Norte',
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
            'Grupo criado. Mande o código ${context.read<RoomService>().activeCode}.',
        glyph: CinematicGlyph.people,
      );
    }
  }

  Future<void> _showJoinRoom(BuildContext context) async {
    final code = await showDialog<String>(
      context: context,
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
    final parsed = InviteDeepLinkService.extractRoomCode(code) ??
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

  Future<bool?> _confirmLeave(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final a = Appearance.of(ctx);
        return AlertDialog(
          backgroundColor: a.cardFill,
          title: Text(
            'Sair do grupo?',
            style: AppTypography.title(color: a.text),
          ),
          content: Text(
            'Você sai da lista. Para voltar, use o código de novo.',
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
          _seg(context, 1, 'Companhia', CinematicGlyph.heart, alert: companionAlert),
          _seg(context, 2, 'Grupos', CinematicGlyph.people),
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
    final color = selected ? AppColors.accent : a.textMuted(0.72);
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
            glyph: CinematicGlyph.people,
            size: 40,
            accent: AppColors.clay,
            glowing: false,
          ),
          const SizedBox(height: 14),
          Text(
            'Entre para criar o grupo',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            error ??
                'O grupo fica na sua conta. Entre com Google para criar ou usar um código.',
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
          'CÉLULA, EBD, DEVOCIONAL',
          textAlign: TextAlign.center,
          style: AppTypography.label(
            letterSpacing: 1.1,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.45,
              weight: FontWeight.w600,
              color: a.textMuted(0.72),
            ),
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
            'A lista é só de quem entrou',
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            'Mande o código no WhatsApp da célula, da sala de EBD ou do devocional. Cada pessoa aparece com os passos que fez nesta semana. Quem não tem o código não entra.',
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
                label: 'Código',
                detail: 'Só quem tem entra',
                color: a.textMuted(0.78),
              ),
              const SizedBox(width: 8),
              _RoomBenefit(
                glyph: CinematicGlyph.people,
                label: 'Lista',
                detail: 'Quem estudou',
                color: a.textMuted(0.78),
              ),
              const SizedBox(width: 8),
              _RoomBenefit(
                glyph: CinematicGlyph.podium,
                label: 'Semana',
                detail: 'Fecha no domingo',
                color: a.textMuted(0.78),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (loading)
            const CircularProgressIndicator(color: AppColors.accent)
          else ...[
            CopperCta(
              label: 'Criar grupo',
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
    final myPhoto = context.select((BackendService b) => b.userPhotoUrl);
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
                        photoUrl: m.isUser ? (myPhoto ?? m.photoUrl) : m.photoUrl,
                        seed: m.uid,
                        style: m.isUser
                            ? progress.settings.portraitStyle
                            : m.portraitStyle,
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
                      'Quem estudou',
                      style: AppTypography.display(
                        size: 18,
                        weight: FontWeight.w800,
                        color: a.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      total == 0
                          ? 'Ninguém entrou. Envie o código.'
                          : '$active de $total estudaram · $today hoje',
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
              '$sumSteps de $goal passos somados do grupo',
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
          const SizedBox(height: 12),
          if (claimed)
            Text(
              'Baú coletado nesta semana',
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w700,
                color: a.textMuted(0.55),
              ),
            )
          else if (ready)
            CopperCta(
              label:
                  'Abrir baú · +${RemoteConfigService.instance.roomChestBonusSteps} passos',
              onTap: onClaim,
              leading: CinematicGlyph.gift,
              trailing: null,
              dense: true,
            )
          else
            Text(
              walkedToday
                  ? (goal != null && goal > 0
                        ? 'O baú abre com metade do grupo ou a meta.'
                        : 'O baú abre quando metade do grupo estudar.')
                  : 'Estude hoje para abrir o baú do grupo.',
              style: AppTypography.body(
                size: 13,
                height: 1.35,
                weight: FontWeight.w700,
                color: walkedToday ? a.textMuted(0.62) : AppColors.accent,
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
    final closesText = days <= 1 ? 'Fecha hoje' : 'Fecha em $days dias';

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOwner ? 'SEU GRUPO' : 'GRUPO',
                      style: AppTypography.label(
                        size: 10,
                        letterSpacing: 1.4,
                        color: AppColors.accent.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.display(size: 28, height: 1.05),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Criado por ${room.ownerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 13,
                        color: a.textMuted(0.62),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.streak.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  closesText,
                  style: AppTypography.label(
                    size: 10,
                    letterSpacing: 0.2,
                    color: AppColors.streak,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onCopy,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: a.cardFillSoft,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: a.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CÓDIGO',
                          style: AppTypography.label(
                            size: 10,
                            letterSpacing: 1.2,
                            color: a.textMuted(0.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          room.code,
                          style: AppTypography.title(
                            size: 22,
                            weight: FontWeight.w900,
                            color: AppColors.accent,
                          ).copyWith(letterSpacing: 3),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Copiar',
                    style: AppTypography.body(
                      size: 13,
                      weight: FontWeight.w800,
                      color: a.textMuted(0.72),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          CopperCta(
            label: 'Compartilhar',
            onTap: onShowQr,
            leading: CinematicGlyph.qr,
            trailing: null,
            dense: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _RoomStatChip(
                label: 'Posição',
                value: rank == null ? '—' : '$rankº',
                highlight: rank == 1,
              ),
              _RoomStatChip(label: 'Pessoas', value: '$memberCount'),
              _RoomStatChip(label: 'Seus passos', value: '$weeklySteps'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (isOwner && onEditGoal != null)
                _RoomTextAction(
                  label: room.weeklyGoalSteps != null
                      ? 'Meta ${room.weeklyGoalSteps}'
                      : 'Definir meta',
                  onTap: onEditGoal!,
                ),
              _RoomTextAction(label: 'Atualizar', onTap: onRefresh),
              const Spacer(),
              _RoomTextAction(
                label: 'Sair',
                onTap: onLeave,
                color: AppColors.error.withValues(alpha: 0.9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoomTextAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _RoomTextAction({
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.fromLTRB(0, 8, 14, 8),
      ),
      child: Text(
        label,
        style: AppTypography.body(
          size: 13,
          weight: FontWeight.w700,
          color: color ?? a.textMuted(0.72),
        ),
      ),
    );
  }
}

class _RoomStatChip extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _RoomStatChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.title(
              size: 20,
              weight: FontWeight.w900,
              color: highlight ? AppColors.accent : a.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.3,
              color: a.textMuted(0.5),
            ),
          ),
        ],
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
    final heading = title ??
        (weekly ? 'Esta semana' : 'Toda a jornada');
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
                ? a.textMuted(0.45)
                : AppColors.teal.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
    final rows = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 2, 6, 8),
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
            if (online.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 8, 4),
                child: onlineChip,
              )
            else
              Semantics(
                button: true,
                label: '$countLabel. Ver quem está na trilha',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showCaravanOnlineSheet(
                      context,
                      people: online,
                      weekly: weekly,
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
          gapToAbove: i == 0 ? 0 : entries[i - 1].steps - entries[i].steps,
          showDivider:
              i < entries.length - 1 && !entries[i + 1].isUser,
          onOpenOwnProfile: onOpenOwnProfile,
        ),
      );
      if (weekly && rank == LeagueService.promoteCount && canPromote) {
        rows.add(const _ZoneDivider());
      }
    }

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
      child: Column(children: rows),
    );
  }
}

void _showCaravanOnlineSheet(
  BuildContext context, {
  required List<({LeagueEntry entry, int rank})> people,
  required bool weekly,
  VoidCallback? onOpenOwnProfile,
}) {
  HapticFeedback.lightImpact();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    builder: (ctx) => _CaravanOnlineSheet(
      people: people,
      weekly: weekly,
      onOpenOwnProfile: onOpenOwnProfile,
    ),
  );
}

class _CaravanOnlineSheet extends StatelessWidget {
  final List<({LeagueEntry entry, int rank})> people;
  final bool weekly;
  final VoidCallback? onOpenOwnProfile;

  const _CaravanOnlineSheet({
    required this.people,
    required this.weekly,
    this.onOpenOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.72;
    final count = people.length;
    final subtitle = count == 1
        ? '1 peregrino da caravana'
        : '$count peregrinos da caravana';

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: AppColors.teal.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.nightElevated,
                        AppColors.night,
                        AppColors.nightMid,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.7),
                        radius: 1.1,
                        colors: [
                          AppColors.teal.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(10, AppSpace.sm, 10, bottom + 18),
                itemCount: people.length + 1,
                separatorBuilder: (ctx, i) {
                  if (i == 0) return const SizedBox(height: 4);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ColoredBox(
                      color: a.text.withValues(alpha: 0.06),
                      child: const SizedBox(height: 1, width: double.infinity),
                    ),
                  );
                },
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: 48,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.24),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                                      style: AppTypography.display(
                                        size: 22,
                                        weight: FontWeight.w800,
                                        color: a.text,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      style: AppTypography.body(
                                        size: 13,
                                        color: a.textMuted(0.62),
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
                    weekly: weekly,
                    onOpenOwnProfile: onOpenOwnProfile,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnlineSheetRow extends StatelessWidget {
  final LeagueEntry entry;
  final int rank;
  final bool weekly;
  final VoidCallback? onOpenOwnProfile;

  const _OnlineSheetRow({
    required this.entry,
    required this.rank,
    required this.weekly,
    this.onOpenOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = entry.isUser ? AppColors.inkOnAccent : a.text;
    final muted = entry.isUser
        ? AppColors.inkOnAccent.withValues(alpha: 0.62)
        : a.textMuted(0.55);
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
          showCaravanPilgrimSheet(
            context,
            entry: entry,
            rank: rank,
          );
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
                      style: AppTypography.body(
                        size: 15,
                        weight: entry.isUser ? FontWeight.w900 : FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      walked ? 'Caminhou hoje' : 'Online',
                      style: AppTypography.label(
                        size: 10,
                        letterSpacing: 0.2,
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
    required this.weeklySteps,
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
        : a.textMuted(0.5);
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
                style: AppTypography.body(
                  size: 15,
                  weight: entry.isUser ? FontWeight.w900 : FontWeight.w700,
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
                size: 17,
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
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: ColoredBox(
              color: a.text.withValues(alpha: 0.06),
              child: const SizedBox(height: 1, width: double.infinity),
            ),
          ),
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
          showCaravanPilgrimSheet(
            context,
            entry: entry,
            rank: rank,
          );
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
              (
                glyph: CinematicGlyph.gem,
                accent: AppColors.medalGold,
              ),
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

  const _MedalDisc({
    required this.glyph,
    required this.accent,
    this.overlay,
  });

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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.nightMid,
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
              weight: FontWeight.w800,
              color: onGold
                  ? AppColors.inkOnAccent.withValues(alpha: 0.72)
                  : a.textMuted(0.55),
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
      })> people;
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
            glyph: CinematicGlyph.heart,
            size: 40,
            accent: AppColors.clay,
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
            glyph: CinematicGlyph.heart,
            size: 44,
            accent: AppColors.clay,
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
            'Uma pessoa. Os dois aparecem no mesmo dia — a caminhada fica a dois.',
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
                  glyph: CinematicGlyph.path,
                  label: 'Presença',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompanhiaPerk(
                  glyph: CinematicGlyph.lamp,
                  label: 'Aceno',
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
  final int weekTogetherDays;

  const _CompanhiaHeroCard({
    required this.companionCount,
    required this.activeCount,
    required this.togetherToday,
    this.waitingOnMe = 0,
    required this.bestStreak,
    this.weekTogetherDays = 0,
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
        ? 'Caminhada a dois'
        : bestStreak > 0
        ? '$bestStreak ${bestStreak == 1 ? 'dia' : 'dias'} juntos'
        : togetherToday > 0
        ? 'Juntos hoje'
        : 'Convite aberto';

    final goldSub = waitingOnMe > 0
        ? 'Dê seu passo — a companhia só conta quando os dois caminham'
        : !hasAny
        ? 'Convide uma pessoa. Sem chat — só aparecer no mesmo dia.'
        : bestStreak > 0
        ? togetherToday > 0
              ? 'Vocês caminharam juntos hoje'
              : 'Quando os dois caminham, o dia conta'
        : 'Aguardando alguém entrar com o código';

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
          if (hasAny && weekTogetherDays > 0) ...[
            const SizedBox(height: 12),
            Text(
              '$weekTogetherDays de 7 nesta semana',
              style: AppTypography.label(
                size: 11,
                letterSpacing: 0.4,
                color: a.textMuted(0.55),
              ),
            ),
          ],
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
    final myPhoto = context.select((BackendService b) => b.userPhotoUrl);
    final myUid = context.select((BackendService b) => b.uid);
    final myStyle = context.select(
      (ProgressService p) => p.settings.portraitStyle,
    );
    final partnerLabel = companion.awaitingPartner
        ? 'Convite'
        : (companion.displayName.isEmpty
              ? 'Companheiro'
              : companion.displayName);
    final myLabel = myName.trim().isEmpty
        ? 'Você'
        : myName.trim().split(' ').first;
    final away = companion.theyDaysAway;
    final canNudge =
        onNudge != null &&
        !companion.awaitingPartner &&
        (companion.waitingOnThem || (away != null && away >= 1));

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
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
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  size: 13,
                  weight: FontWeight.w800,
                  color: AppColors.streak,
                ),
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAMINHADA A DOIS',
                      style: AppTypography.label(
                        size: 10,
                        letterSpacing: 1.4,
                        color: AppColors.accent,
                      ),
                    ),
                    if (companion.awaitingPartner) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Convite aberto',
                        style: AppTypography.title(
                          size: 24,
                          weight: FontWeight.w900,
                          color: a.text,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (companion.sharedDays > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
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
                        size: 16,
                        accent: AppColors.streak,
                        framed: false,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${companion.sharedDays}',
                        style: AppTypography.title(
                          size: 18,
                          weight: FontWeight.w900,
                          color: AppColors.streak,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        companion.sharedDays == 1 ? 'dia' : 'dias',
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w700,
                          color: AppColors.streak,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (companion.awaitingPartner) ...[
            const SizedBox(height: 12),
            Text(
              companion.statusLine,
              style: AppTypography.body(
                size: 16,
                height: 1.35,
                weight: FontWeight.w600,
                color: a.text.withValues(alpha: 0.9),
              ),
            ),
          ],
          if (!companion.awaitingPartner) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PresencePill(
                    name: myLabel,
                    walked: companion.iWalkedToday,
                    highlight: companion.waitingOnMe,
                    dusty: false,
                    isUser: true,
                    photoUrl: myPhoto,
                    seed: myUid ?? myName,
                    style: myStyle,
                    large: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    companion.bothWalkedToday ? '✓' : '·',
                    style: AppTypography.title(
                      size: 22,
                      color: companion.bothWalkedToday
                          ? AppColors.accent
                          : a.textMuted(0.35),
                    ),
                  ),
                ),
                Expanded(
                  child: _PresencePill(
                    name: partnerLabel,
                    walked: companion.theyWalkedToday,
                    highlight: companion.waitingOnThem,
                    dusty: companion.theyAreDusty,
                    seed: companion.displayName,
                    large: true,
                  ),
                ),
              ],
            ),
          ],
          if (companion.hasIncomingNudge) ...[
            const SizedBox(height: 14),
            _IncomingNudgeBanner(companion: companion),
          ],
          RecognizeCompanionWalk(
            partnerUid: companion.partnerUid,
            walkDate: companion.theyLastWalkDate,
          ),
          if (canNudge) ...[
            const SizedBox(height: 16),
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
          if (!companion.awaitingPartner) ...[
            const SizedBox(height: 22),
            _CompanionWeekStrip(companion: companion),
            const SizedBox(height: 20),
            _CompanionMilestonesBlock(companion: companion),
          ],
          const SizedBox(height: 6),
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
            Text(
              'ESTA SEMANA',
              style: AppTypography.label(
                size: 10,
                letterSpacing: 1.4,
                color: AppColors.accent,
              ),
            ),
            const Spacer(),
            Text(
              '$together de 7',
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
                  style: a,
                ),
              ),
            ],
          ],
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
        Text(
          'MARCOS',
          style: AppTypography.label(
            size: 10,
            letterSpacing: 1.4,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 14),
        _MilestoneTrail(sharedDays: shared, next: next, style: a),
        if (shared < next) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  caption,
                  style: AppTypography.body(size: 13, color: a.textMuted(0.65)),
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

class _WeekDot extends StatelessWidget {
  final String label;
  final CompanionDayPresence presence;
  final bool isToday;
  final AppearanceStyle style;

  const _WeekDot({
    required this.label,
    required this.presence,
    required this.isToday,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final painted = presence.me || presence.them;
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 36,
            height: 36,
            child: CustomPaint(
              painter: _SplitDayPainter(
                me: presence.me,
                them: presence.them,
                isToday: isToday,
                empty: style.cardFillSoft,
                border: isToday
                    ? AppColors.accent
                    : painted
                    ? AppColors.accent.withValues(alpha: 0.55)
                    : style.cardBorder.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.label(
            size: 10,
            color: isToday ? AppColors.accent : style.textMuted(0.5),
          ),
        ),
      ],
    );
  }
}

/// Bolinha da semana: metade esquerda é você, metade direita é o parceiro.
class _SplitDayPainter extends CustomPainter {
  final bool me;
  final bool them;
  final bool isToday;
  final Color empty;
  final Color border;

  const _SplitDayPainter({
    required this.me,
    required this.them,
    required this.isToday,
    required this.empty,
    required this.border,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final stroke = isToday ? 1.8 : 1.15;
    final disk = radius - stroke / 2;

    canvas.drawCircle(center, disk, Paint()..color = empty);

    final inner = disk - stroke - 2.4;
    const seam = 1.4;
    if (inner > 0 && (me || them)) {
      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: inner)),
      );
      final fill = Paint()..color = AppColors.accent;
      if (me && them) {
        canvas.drawCircle(center, inner, fill);
      } else {
        final half = me
            ? Rect.fromLTRB(0, 0, center.dx - seam / 2, size.height)
            : Rect.fromLTRB(center.dx + seam / 2, 0, size.width, size.height);
        canvas.drawRect(half, fill);
      }
      canvas.restore();
    }

    canvas.drawCircle(
      center,
      disk,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = border,
    );
  }

  @override
  bool shouldRepaint(covariant _SplitDayPainter old) =>
      me != old.me ||
      them != old.them ||
      isToday != old.isToday ||
      empty != old.empty ||
      border != old.border;
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
                            : style.textMuted(0.45),
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
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        if (t > 0)
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: t,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.all(Radius.circular(2)),
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
            ? Center(
                child: Text(
                  '✓',
                  style: AppTypography.label(
                    size: 11,
                    weight: FontWeight.w900,
                    color: AppColors.inkOnAccent,
                  ),
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

class _CompanionGuideCard extends StatelessWidget {
  const _CompanionGuideCard();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final rows = const [
      (CinematicGlyph.path, 'Os dois caminham no mesmo dia'),
      (CinematicGlyph.flame, 'O dia conta para a sequência juntos'),
      (CinematicGlyph.lamp, 'Se um atrasar, o outro pode acenar'),
    ];
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMO FUNCIONA',
            style: AppTypography.label(
              size: 10,
              letterSpacing: 1.4,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: [
                CinematicIcon(
                  glyph: rows[i].$1,
                  size: 22,
                  accent: AppColors.accent,
                  framed: false,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rows[i].$2,
                    style: AppTypography.body(
                      size: 15,
                      height: 1.3,
                      weight: FontWeight.w600,
                      color: a.text.withValues(alpha: 0.88),
                    ),
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

class _PresencePill extends StatelessWidget {
  final String name;
  final bool walked;
  final bool highlight;
  final bool dusty;
  final bool isUser;
  final bool large;
  final String? photoUrl;
  final String? seed;
  final PortraitStyle style;

  const _PresencePill({
    required this.name,
    required this.walked,
    required this.highlight,
    this.dusty = false,
    this.isUser = false,
    this.large = false,
    this.photoUrl,
    this.seed,
    this.style = PortraitStyle.photo,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final status = walked
        ? 'Hoje ✓'
        : dusty
        ? 'Na poeira'
        : (highlight ? 'Espera' : 'Ainda não');
    final dustBorder = const Color(0xFFC4A070);
    final dustFill = const Color(0xFF3A2410);
    final avatarSize = large ? 52.0 : 40.0;

    final pill = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              large ? 12 : 10,
              large ? 14 : 10,
              large ? 12 : 10,
              large ? 14 : 10,
            ),
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
                  size: avatarSize,
                  photoUrl: photoUrl,
                  seed: seed ?? name,
                  style: style,
                ),
                SizedBox(height: large ? 8 : 6),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    size: large ? 14 : 12,
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
                    size: large ? 11 : 10,
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

class _CaravanEmptyCard extends StatelessWidget {
  final bool overall;
  final VoidCallback onInvite;

  const _CaravanEmptyCard({
    required this.overall,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: CinematicIcon(
              glyph: CinematicGlyph.people,
              size: 44,
              accent: AppColors.accent,
              glowing: false,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            overall ? 'A caravana ainda é pequena' : 'Sua divisão ainda é quieta',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 16, color: a.text),
          ),
          const SizedBox(height: 6),
          Text(
            'Ranking só aparece com gente de verdade. Chame um companheiro — um par já muda a caminhada.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.4,
              weight: FontWeight.w600,
              color: a.textMuted(0.7),
            ),
          ),
          const SizedBox(height: 16),
          CopperCta(
            label: 'Chamar um companheiro',
            leading: CinematicGlyph.people,
            onTap: onInvite,
            dense: true,
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
