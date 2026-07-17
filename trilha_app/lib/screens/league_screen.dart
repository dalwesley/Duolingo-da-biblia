import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/study_room.dart';
import '../models/walk_companion.dart';
import '../services/backend_service.dart';
import '../services/companion_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/accept_invite_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/invite_qr_sheet.dart';

class LeagueScreen extends StatefulWidget {
  final Widget? topBar;

  const LeagueScreen({super.key, this.topBar});

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  List<LeagueEntry> _realPlayers = const [];
  List<LeagueEntry> _overallPlayers = const [];
  int _tab = 0; // 0 = companhia, 1 = caravana, 2 = salas
  bool _overallRanking = false;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _settle());
  }

  Future<void> _settle() async {
    if (!mounted) return;
    final progress = context.read<ProgressService>();
    final league = context.read<LeagueService>();
    final backend = context.read<BackendService>();
    final rooms = context.read<RoomService>();
    await league.settleWeekIfNeeded(
      lastWeekSteps: progress.lastWeekSteps,
      lastWeekKey: progress.lastWeekKey,
    );
    if (backend.isActive) {
      final week = LeagueService.weekKey();
      await backend.saveNow(
        progress,
        week,
        roomCode: rooms.activeCode,
        league: league,
      );
      final players = await backend.fetchWeekPlayers(week);
      final overallPlayers = await backend.fetchOverallPlayers();
      await rooms.syncIfNeeded();
      if (!mounted) return;
      final companionSvc = context.read<CompanionService>();
      await companionSvc.refresh();
      if (progress.walkedToday) {
        await companionSvc.syncWalksIfNeeded(progress);
      }
      if (!mounted) return;
      setState(() {
        _realPlayers = [
          for (final p in players) LeagueEntry(name: p.name, steps: p.steps),
        ];
        _overallPlayers = [
          for (final p in overallPlayers)
            LeagueEntry(name: p.name, steps: p.steps),
        ];
      });
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Widget _reveal(int index, Widget child) {
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
    return ListView(
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
          const SizedBox(height: 18),
        ],
        _reveal(
          0,
          _SegmentTabs(index: _tab, onChanged: (i) => setState(() => _tab = i)),
        ),
        const SizedBox(height: 20),
        if (_tab == 0)
          ..._buildCompanions(context)
        else if (_tab == 1)
          ..._buildLeague(context)
        else
          ..._buildRooms(context),
      ],
    );
  }

  List<Widget> _buildLeague(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final league = context.watch<LeagueService>();

    if (!league.isLoaded) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 48),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      ];
    }

    final overall = _overallRanking;
    final entries = overall
        ? league.overallStandings(
            userName: progress.userName,
            userTotalSteps: progress.steps,
            realPlayers: _overallPlayers,
          )
        : league.standings(
            userName: progress.userName,
            userWeeklySteps: progress.weeklySteps,
            realPlayers: _realPlayers,
          );
    final userRank = league.userRank(entries);
    final userSteps = overall ? progress.steps : progress.weeklySteps;
    final canPromote = league.tierIndex < LeagueTier.values.length - 1;
    final canDemote = league.tierIndex > 0;
    final a = Appearance.of(context);

    final children = <Widget>[
      _reveal(
        1,
        _RankingPeriodTabs(
          overall: overall,
          onChanged: (value) => setState(() => _overallRanking = value),
        ),
      ),
      const SizedBox(height: 16),
      _reveal(
        2,
        _CaravanaHeroCard(
          overall: overall,
          rank: userRank,
          steps: userSteps,
          tierIndex: league.tierIndex,
        ),
      ),
      if (!overall && league.pendingOutcome != null) ...[
        const SizedBox(height: 12),
        _reveal(3, _OutcomeBanner(league: league)),
      ],
      const SizedBox(height: 20),
      Text(
        overall ? 'CLASSIFICAÇÃO GERAL' : 'CLASSIFICAÇÃO DA SEMANA',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
          color: a.textMuted(0.55),
        ),
      ),
      const SizedBox(height: 10),
    ];

    for (var i = 0; i < entries.length; i++) {
      final rank = i + 1;
      if (!overall && rank == 1 && canPromote) {
        children.add(
          _ZoneLabel(
            text:
                'SOBEM · ${LeagueTier.values[league.tierIndex + 1].shortLabel.toUpperCase()}',
            up: true,
          ),
        );
      }
      if (!overall &&
          rank == LeagueService.groupSize - LeagueService.demoteCount + 1 &&
          canDemote) {
        children.add(
          _ZoneLabel(
            text:
                'DESCEM · ${LeagueTier.values[league.tierIndex - 1].shortLabel.toUpperCase()}',
            up: false,
          ),
        );
      }
      children.add(
        _reveal(
          (4 + i ~/ 4).clamp(0, 8),
          _StandingRow(entry: entries[i], rank: rank),
        ),
      );
      if (!overall && rank == LeagueService.promoteCount && canPromote) {
        children.add(const _ZoneDivider());
      }
    }
    return children;
  }

  List<Widget> _buildCompanions(BuildContext context) {
    final companions = context.watch<CompanionService>();
    final backend = context.watch<BackendService>();
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);

    if (!companions.isLoaded) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 48),
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

    final list = <Widget>[
      _reveal(
        1,
        Column(
          children: [
            Text(
              'Andem juntos',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Convide até ${CompanionService.maxCompanions} pessoas.\nSem ranking entre vocês — só presença.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
    ];

    if (companions.lastError != null) {
      list.add(
        Text(
          companions.lastError!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error, fontSize: 12),
        ),
      );
      list.add(const SizedBox(height: 12));
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

    for (var i = 0; i < companions.companions.length; i++) {
      list.add(
        _reveal(
          (2 + i).clamp(0, 8),
          _CompanionCard(
            companion: companions.companions[i],
            onCopy: () async {
              await Clipboard.setData(
                ClipboardData(text: companions.companions[i].code),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Código copiado')));
            },
            onShowQr: () =>
                showInviteQrSheet(context, code: companions.companions[i].code),
            onLeave: () async {
              final ok = await _confirmLeaveCompanion(context);
              if (ok == true && context.mounted) {
                await context.read<CompanionService>().leave(
                  companions.companions[i].code,
                );
              }
            },
          ),
        ),
      );
      list.add(const SizedBox(height: 10));
    }

    list.add(const SizedBox(height: 8));
    list.add(
      Row(
        children: [
          if (companions.canAdd)
            Expanded(
              child: _OutlineAction(
                label: 'Convidar',
                onTap: companions.loading
                    ? null
                    : () => _createCompanion(context),
              ),
            ),
          if (companions.canAdd) const SizedBox(width: 10),
          if (companions.canAdd)
            Expanded(
              child: _OutlineAction(
                label: 'Aceitar convite',
                onTap: companions.loading
                    ? null
                    : () => _joinCompanion(context),
              ),
            ),
        ],
      ),
    );
    list.add(const SizedBox(height: 12));
    list.add(
      TextButton(
        onPressed: () async {
          await companions.syncWalksIfNeeded(progress);
          await companions.refresh();
        },
        child: Text(
          'Atualizar presença',
          style: TextStyle(
            color: a.textMuted(0.7),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    return list;
  }

  Future<void> _createCompanion(BuildContext context) async {
    final progress = context.read<ProgressService>();
    final service = context.read<CompanionService>();
    final created = await service.createInvite(progress);
    if (!context.mounted) return;
    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(service.lastError ?? 'Falha ao criar')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: created.code));
    if (!context.mounted) return;
    await showInviteQrSheet(context, code: created.code);
  }

  Future<void> _joinCompanion(BuildContext context) async {
    final code = await showAcceptInviteSheet(context);
    if (code == null || code.isEmpty || !context.mounted) return;
    final ok = await context.read<CompanionService>().joinWithCode(
      code,
      context.read<ProgressService>(),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Companhia formada — caminhem juntos'
              : (context.read<CompanionService>().lastError ??
                    'Não foi possível entrar'),
        ),
      ),
    );
  }

  Future<bool?> _confirmLeaveCompanion(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final a = Appearance.of(ctx);
        return AlertDialog(
          backgroundColor: AppColors.nightMid,
          title: const Text(
            'Sair da companhia?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'A caminhada juntos com esta pessoa termina. Sem culpa — a Caravana continua.',
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
    final a = Appearance.of(context);

    if (!rooms.isLoaded) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 48),
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
        const SizedBox(height: 18),
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
        1,
        const _RoomsIntro(
          title: 'Caminhem em sala',
          subtitle:
              'Acompanhe a semana do grupo, compartilhe o código e anime quem ficou perto no ranking.',
        ),
      ),
      const SizedBox(height: 18),
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Código copiado!')));
          },
          onShowQr: () => showInviteQrSheet(
            context,
            code: room.code,
            title: room.name,
            subtitle: 'Escaneie o QR ou entre com o código',
            shareMessage:
                'Entre na sala "${room.name}" no Trilha com o código ${room.code}.',
          ),
          onLeave: () async {
            final ok = await _confirmLeave(context);
            if (ok == true && context.mounted) {
              await context.read<RoomService>().leaveRoom();
            }
          },
          onRefresh: () => rooms.refreshMembers(),
        ),
      ),
      const SizedBox(height: 14),
      if (rooms.lastError != null) ...[
        const SizedBox(height: 12),
        Text(
          rooms.lastError!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error, fontSize: 12),
        ),
      ],
      const SizedBox(height: 18),
      Text(
        'RANKING DA SALA',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
          color: a.textMuted(0.55),
        ),
      ),
      const SizedBox(height: 10),
      if (rooms.loading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        )
      else if (members.isEmpty)
        Text(
          'Ainda sem participantes. Compartilhe o código ${room.code}.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Appearance.of(context).textMuted(0.7),
            fontSize: 13,
          ),
        )
      else
        for (var i = 0; i < members.length; i++)
          _reveal(
            (3 + i ~/ 4).clamp(0, 8),
            _StandingRow(
              entry: LeagueEntry(
                name: members[i].name,
                steps: members[i].steps,
                isUser: members[i].isUser,
              ),
              rank: i + 1,
            ),
          ),
      const SizedBox(height: 8),
      Text(
        'Ordem por passos nesta semana · ${progress.userName}',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: a.textMuted(0.55)),
      ),
    ];
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sala criada! Código: ${context.read<RoomService>().activeCode}',
          ),
        ),
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
          backgroundColor: AppColors.nightMid,
          title: const Text(
            'Sair da sala?',
            style: TextStyle(color: Colors.white),
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

  const _SegmentTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      radius: AppRadii.md,
      child: Row(
        children: [
          _seg(context, 0, 'Companhia'),
          _seg(context, 1, 'Caravana'),
          _seg(context, 2, 'Salas'),
        ],
      ),
    );
  }

  Widget _seg(BuildContext context, int i, String label) {
    final selected = index == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.gold : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: selected
                  ? AppColors.inkOnAccent
                  : Appearance.of(context).textMuted(0.7),
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
    return Center(
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: a.cardFillSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: a.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(context, label: 'Semana', value: false),
            _item(context, label: 'Geral', value: true),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required String label,
    required bool value,
  }) {
    final selected = overall == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.gold : null,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: selected
                ? AppColors.inkOnAccent
                : Appearance.of(context).textMuted(0.7),
          ),
        ),
      ),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: a.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: a.cardBorder),
      ),
      child: Column(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.path,
            size: 40,
            accent: AppColors.accent,
            glowing: false,
            framed: false,
          ),
          const SizedBox(height: 14),
          Text(
            'Salas precisam da nuvem',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Entre com Google para caminhar na caravana ao vivo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: a.textMuted(0.75),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: loading ? null : onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                loading ? 'Conectando…' : 'Tentar de novo',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.inkOnAccent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Faça login com Google ao abrir o app',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
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
    return Column(
      children: [
        Text(
          'SALAS PRIVADAS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.accent.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.58),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: a.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: a.cardBorder),
      ),
      child: Column(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.dove,
            size: 38,
            accent: AppColors.accent,
            glowing: false,
            framed: false,
          ),
          const SizedBox(height: 14),
          Text(
            'Quem vai estudar com você?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Crie uma sala e envie o código, ou entre em uma sala que alguém já preparou. A semana fica mais clara quando o grupo aparece no mesmo placar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _RoomBenefit(
                icon: Icons.lock_rounded,
                label: 'Privada',
                color: a.textMuted(0.78),
              ),
              const SizedBox(width: 8),
              _RoomBenefit(
                icon: Icons.ios_share_rounded,
                label: 'Código',
                color: a.textMuted(0.78),
              ),
              const SizedBox(width: 8),
              _RoomBenefit(
                icon: Icons.leaderboard_rounded,
                label: 'Semanal',
                color: a.textMuted(0.78),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (loading)
            const CircularProgressIndicator(color: AppColors.accent)
          else ...[
            GestureDetector(
              onTap: onCreate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'Criar sala',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.inkOnAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _OutlineAction(label: 'Entrar com código', onTap: onJoin),
          ],
          if (error != null) ...[
            const SizedBox(height: 14),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoomBenefit extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _RoomBenefit({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.accent.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
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
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final days = LeagueService.daysLeft();
    final closesText = days <= 1 ? 'Fecha hoje' : '$days dias';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        gradient: a.cardGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: a.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CinematicIcon(
                glyph: CinematicGlyph.dove,
                size: 38,
                accent: AppColors.accent,
                glowing: false,
                framed: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOwner ? 'Sua sala' : 'Sala',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppColors.accent.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      room.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.05,
                      ),
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
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: a.textMuted(0.65),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.055),
                borderRadius: BorderRadius.circular(16),
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
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: a.textMuted(0.58),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          room.code,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.copy_rounded, size: 20, color: a.textMuted(0.72)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onShowQr,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppGradients.gold,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 18,
                          color: AppColors.inkOnAccent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Compartilhar QR',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.inkOnAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _RoomIconButton(
                icon: Icons.refresh_rounded,
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
              Icon(
                Icons.hourglass_bottom_rounded,
                size: 14,
                color: AppColors.streak.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Semana da caravana: $closesText',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: a.textMuted(0.72),
                  ),
                ),
              ),
              TextButton(
                onPressed: onLeave,
                child: Text(
                  'Sair',
                  style: TextStyle(
                    fontSize: 12,
                    color: a.textMuted(0.55),
                    fontWeight: FontWeight.w700,
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
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RoomIconButton({
    required this.icon,
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
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: a.cardBorder),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 17,
              color: AppColors.accent.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
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
          color: accent ? null : Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accent
                ? Colors.white.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: accent ? AppColors.inkOnAccent : AppColors.accent,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
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

class _CaravanaHeroCard extends StatelessWidget {
  final bool overall;
  final int rank;
  final int steps;
  final int tierIndex;

  const _CaravanaHeroCard({
    required this.overall,
    required this.rank,
    required this.steps,
    required this.tierIndex,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tier = LeagueTier.values[tierIndex];
    final days = LeagueService.daysLeft();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: a.cardGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: a.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            overall ? 'Ranking geral' : 'Sua semana',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            overall
                ? 'Passos de toda a jornada'
                : 'Quem mais caminhou nesta caravana',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: a.textMuted(0.65),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppGradients.gold,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '$rankº lugar',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.inkOnAccent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$steps passos${overall ? ' no total' : ' esta semana'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkOnAccent.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          if (!overall) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    tier.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const Icon(
                  Icons.hourglass_bottom_rounded,
                  size: 14,
                  color: AppColors.streak,
                ),
                const SizedBox(width: 4),
                Text(
                  days <= 1 ? 'Fecha hoje' : '$days dias',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: a.textMuted(0.75),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _TierLadder(currentIndex: tierIndex),
            const SizedBox(height: 8),
            Text(
              'Top 7 sobem de caravana · últimos 5 descem',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: a.textMuted(0.5)),
            ),
          ],
        ],
      ),
    );
  }
}

class _TierLadder extends StatelessWidget {
  final int currentIndex;

  const _TierLadder({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);

    return Row(
      children: List.generate(LeagueTier.values.length, (i) {
        final tier = LeagueTier.values[i];
        final reached = i <= currentIndex;
        final isCurrent = i == currentIndex;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: isCurrent ? 34 : 28,
                height: isCurrent ? 34 : 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: reached ? AppGradients.gold : null,
                  color: reached ? null : Colors.white.withValues(alpha: 0.07),
                  border: Border.all(
                    color: isCurrent
                        ? Colors.white.withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: reached ? 0.2 : 0.1),
                    width: isCurrent ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: CinematicIcon(
                    glyph: switch (tier) {
                      LeagueTier.semente => CinematicGlyph.seed,
                      LeagueTier.videira => CinematicGlyph.tree,
                      LeagueTier.oliveira => CinematicGlyph.mountain,
                      LeagueTier.cedro => CinematicGlyph.crown,
                      LeagueTier.estrela => CinematicGlyph.star,
                    },
                    size: isCurrent ? 17 : 14,
                    accent: reached ? AppColors.inkOnAccent : a.textMuted(0.35),
                    glowing: false,
                    framed: false,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tier.shortLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                  color: isCurrent
                      ? AppColors.accent
                      : a.textMuted(reached ? 0.55 : 0.3),
                ),
              ),
            ],
          ),
        );
      }),
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

  const _TextInputDialog({
    required this.title,
    required this.hint,
    required this.confirmLabel,
    required this.maxLength,
    this.capitalize = false,
    this.letterSpacing = 0,
  });

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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
      backgroundColor: AppColors.nightMid,
      title: Text(
        widget.title,
        style: GoogleFonts.cormorantGaramond(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        textCapitalization: widget.capitalize
            ? TextCapitalization.characters
            : TextCapitalization.none,
        style: TextStyle(
          color: Colors.white,
          letterSpacing: widget.letterSpacing,
          fontWeight: widget.capitalize ? FontWeight.w800 : FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: a.textMuted(0.5), letterSpacing: 0),
          filled: true,
          fillColor: a.cardFillSoft,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: a.textMuted(0.7))),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.inkOnAccent,
          ),
          child: Text(
            widget.confirmLabel,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _OutcomeBanner extends StatelessWidget {
  final LeagueService league;

  const _OutcomeBanner({required this.league});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final outcome = league.pendingOutcome!;
    final (title, message) = switch (outcome) {
      LeagueOutcome.promoted => (
        'Você avançou de caravana',
        'Ficou em ${league.pendingRank}º e agora caminha na ${league.tier.label}. +${LeagueService.promotionBonusXp} passos de encorajamento!',
      ),
      LeagueOutcome.stayed => (
        'Semana da caravana encerrada',
        'Você ficou em ${league.pendingRank}º na ${league.tier.label}. Nova semana — continuem se animando.',
      ),
      LeagueOutcome.demoted => (
        'Sua caminhada continua daqui',
        'Você ficou em ${league.pendingRank}º. Na ${league.tier.label} há espaço para o próximo passo — sem vergonha, só graça.',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: outcome == LeagueOutcome.promoted ? AppGradients.gold : null,
        color: outcome == LeagueOutcome.promoted ? null : a.cardFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: a.cardBorder),
      ),
      child: Row(
        children: [
          CinematicIcon(
            glyph: outcome == LeagueOutcome.promoted
                ? CinematicGlyph.crown
                : CinematicGlyph.path,
            size: 34,
            accent: outcome == LeagueOutcome.promoted
                ? AppColors.inkOnAccent
                : AppColors.accent,
            glowing: false,
            framed: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: outcome == LeagueOutcome.promoted
                        ? AppColors.inkOnAccent
                        : a.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: outcome == LeagueOutcome.promoted
                        ? const Color(0xFF5A4400)
                        : a.textMuted(0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              if (outcome == LeagueOutcome.promoted) {
                await context.read<ProgressService>().grantBonusSteps(
                  LeagueService.promotionBonusXp,
                );
              }
              await league.dismissOutcome();
              if (!context.mounted) return;
              final progress = context.read<ProgressService>();
              final backend = context.read<BackendService>();
              final rooms = context.read<RoomService>();
              await backend.saveNow(
                progress,
                LeagueService.weekKey(),
                roomCode: rooms.activeCode,
                league: league,
              );
            },
            child: Text(
              outcome == LeagueOutcome.promoted ? 'Coletar' : 'Ok',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: outcome == LeagueOutcome.promoted
                    ? AppColors.inkOnAccent
                    : AppColors.accent,
              ),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Icon(
            up
                ? Icons.keyboard_double_arrow_up_rounded
                : Icons.keyboard_double_arrow_down_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
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
      padding: const EdgeInsets.symmetric(vertical: 10),
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
            child: Icon(
              Icons.keyboard_double_arrow_up_rounded,
              size: 14,
              color: AppColors.accent.withValues(alpha: 0.7),
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

class _StandingRow extends StatelessWidget {
  final LeagueEntry entry;
  final int rank;

  const _StandingRow({required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final isTop3 = rank <= 3;
    final medal = switch (rank) {
      1 => const Color(0xFFF5D78E),
      2 => const Color(0xFFC8CEDC),
      3 => const Color(0xFFD9995B),
      _ => null,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: entry.isUser ? AppGradients.gold : a.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isUser
              ? Colors.white.withValues(alpha: 0.5)
              : a.cardBorder,
          width: entry.isUser ? 1.5 : 1,
        ),
        boxShadow: entry.isUser
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: isTop3 ? 16 : 13,
                fontWeight: FontWeight.w900,
                color: entry.isUser
                    ? AppColors.inkOnAccent
                    : (medal ?? a.textMuted(0.6)),
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.isUser
                  ? Colors.white.withValues(alpha: 0.35)
                  : AppColors.primaryLight.withValues(alpha: 0.3),
              border: Border.all(
                color: entry.isUser
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Center(
              child: Text(
                entry.name.isEmpty ? '?' : entry.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: entry.isUser ? AppColors.inkOnAccent : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.isUser ? '${entry.name} (você)' : entry.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: entry.isUser ? FontWeight.w900 : FontWeight.w600,
                color: entry.isUser ? AppColors.inkOnAccent : a.text,
              ),
            ),
          ),
          Text(
            '${entry.steps} passos',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: entry.isUser
                  ? AppColors.inkOnAccent
                  : AppColors.accent.withValues(alpha: 0.9),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: a.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: a.cardBorder),
      ),
      child: Column(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.path,
            size: 40,
            accent: AppColors.accent,
            glowing: false,
            framed: false,
          ),
          const SizedBox(height: 14),
          Text(
            'Companhia precisa da nuvem',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Entre com Google para caminhar com alguém de verdade.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            const CircularProgressIndicator(color: AppColors.accent)
          else
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Tentar de novo',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: a.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: a.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            'Quem caminha ao seu lado?',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Convide um amigo ou entre com um código. Quando os dois dão um passo no dia, a companhia avança.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          if (loading)
            const CircularProgressIndicator(color: AppColors.accent)
          else ...[
            _OutlineAction(label: 'Convidar amigo', onTap: onInvite),
            const SizedBox(height: 10),
            _OutlineAction(label: 'Aceitar convite', onTap: onJoin),
          ],
        ],
      ),
    );
  }
}

class _CompanionCard extends StatelessWidget {
  final WalkCompanion companion;
  final VoidCallback onCopy;
  final VoidCallback onLeave;
  final VoidCallback onShowQr;

  const _CompanionCard({
    required this.companion,
    required this.onCopy,
    required this.onLeave,
    required this.onShowQr,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: a.cardFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: companion.bothWalkedToday
              ? AppColors.accent.withValues(alpha: 0.45)
              : a.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.gold,
                ),
                child: Center(
                  child: Text(
                    companion.displayName.isEmpty
                        ? '?'
                        : companion.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.inkOnAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companion.awaitingPartner
                          ? 'Convite aberto'
                          : companion.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: a.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      companion.statusLine,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: a.textMuted(0.7),
                      ),
                    ),
                  ],
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${companion.sharedDays}d',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.streak,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCopy,
                  child: Text(
                    'Código ${companion.code}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.accent.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
              if (companion.awaitingPartner)
                TextButton.icon(
                  onPressed: onShowQr,
                  icon: const Icon(
                    Icons.qr_code_2_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                  label: const Text(
                    'QR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              TextButton(
                onPressed: onLeave,
                child: Text(
                  'Sair',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _OutlineAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _OutlineAction({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: onTap == null
                ? Colors.white.withValues(alpha: 0.12)
                : AppColors.accent.withValues(alpha: 0.45),
          ),
          color: Colors.white.withValues(alpha: 0.04),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: onTap == null
                ? Colors.white.withValues(alpha: 0.35)
                : AppColors.accent,
          ),
        ),
      ),
    );
  }
}
