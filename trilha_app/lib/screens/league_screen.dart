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
import '../widgets/cinematic_icon.dart';

class LeagueScreen extends StatefulWidget {
  const LeagueScreen({super.key});

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  List<LeagueEntry> _realPlayers = const [];
  int _tab = 0; // 0 = caravana, 1 = companhia, 2 = salas

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
      await backend.saveNow(progress, week, roomCode: rooms.activeCode);
      final players = await backend.fetchWeekPlayers(week);
      await rooms.syncIfNeeded();
      if (!mounted) return;
      final companionSvc = context.read<CompanionService>();
      await companionSvc.refresh();
      if (progress.missionsToday > 0) {
        await companionSvc.syncWalksIfNeeded(progress);
      }
      if (!mounted) return;
      setState(() {
        _realPlayers = [
          for (final p in players) LeagueEntry(name: p.name, steps: p.steps),
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
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        AppSpace.xl,
        20,
        scrollPaddingBelowNav(context),
      ),
      children: [
        _reveal(
          0,
          _SegmentTabs(
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
        ),
        const SizedBox(height: 20),
        if (_tab == 0)
          ..._buildLeague(context)
        else if (_tab == 1)
          ..._buildCompanions(context)
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

    final entries = league.standings(
      userName: progress.userName,
      userWeeklySteps: progress.weeklySteps,
      realPlayers: _realPlayers,
    );
    final userRank = league.userRank(entries);
    final canPromote = league.tierIndex < LeagueTier.values.length - 1;
    final canDemote = league.tierIndex > 0;

    final children = <Widget>[
      _reveal(1, _LeagueHeader(rank: userRank, weeklySteps: progress.weeklySteps)),
      const SizedBox(height: 18),
      _reveal(2, _TierLadder(currentIndex: league.tierIndex)),
      const SizedBox(height: 14),
      _reveal(3, const _CountdownChip()),
      if (league.pendingOutcome != null) ...[
        const SizedBox(height: 16),
        _reveal(4, _OutcomeBanner(league: league)),
      ],
      const SizedBox(height: 12),
      Text(
        'Ordem por passos dados — não por espiritualidade.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: Appearance.of(context).textMuted(0.55),
        ),
      ),
      const SizedBox(height: 18),
    ];

    for (var i = 0; i < entries.length; i++) {
      final rank = i + 1;
      if (rank == 1 && canPromote) {
        children.add(_ZoneLabel(
          text: 'À FRENTE · CARAVANA ${LeagueTier.values[league.tierIndex + 1].shortLabel.toUpperCase()}',
          up: true,
        ));
      }
      if (rank == LeagueService.groupSize - LeagueService.demoteCount + 1 &&
          canDemote) {
        children.add(_ZoneLabel(
          text: 'RECUPERANDO O RITMO · CARAVANA ${LeagueTier.values[league.tierIndex - 1].shortLabel.toUpperCase()}',
          up: false,
        ));
      }
      children.add(
        _reveal(
          (5 + i ~/ 4).clamp(0, 8),
          _StandingRow(entry: entries[i], rank: rank),
        ),
      );
      if (rank == LeagueService.promoteCount && canPromote) {
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
              'COMPANHIA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.accent.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Até ${CompanionService.maxCompanions} pessoas. Vocês caminham lado a lado — sem ranking entre si.',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código copiado')),
              );
            },
            onLeave: () async {
              final ok = await _confirmLeaveCompanion(context);
              if (ok == true && context.mounted) {
                await context
                    .read<CompanionService>()
                    .leave(companions.companions[i].code);
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
                label: 'Entrar com código',
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
          style: TextStyle(color: a.textMuted(0.7), fontWeight: FontWeight.w700),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código ${created.code} copiado — envie ao companheiro'),
      ),
    );
  }

  Future<void> _joinCompanion(BuildContext context) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final a = Appearance.of(ctx);
        return AlertDialog(
          backgroundColor: AppColors.nightMid,
          title: Text(
            'Entrar na companhia',
            style: GoogleFonts.cormorantGaramond(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            maxLength: 8,
            style: const TextStyle(color: Colors.white, letterSpacing: 2),
            decoration: InputDecoration(
              hintText: 'Código',
              hintStyle: TextStyle(color: a.textMuted(0.5)),
              filled: true,
              fillColor: a.cardFillSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: TextStyle(color: a.textMuted(0.7))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Entrar', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        );
      },
    );
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
              : (context.read<CompanionService>().lastError ?? 'Não foi possível entrar'),
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
          title: const Text('Sair da companhia?', style: TextStyle(color: Colors.white)),
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
              child: const Text('Sair', style: TextStyle(color: AppColors.error)),
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
        _RoomHeader(
          room: room,
          rank: userRank > 0 ? userRank : null,
          isOwner: room.isOwner(backend.uid),
          onCopy: () async {
            await Clipboard.setData(ClipboardData(text: room.code));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Código copiado!')),
            );
          },
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
      _reveal(2, const _CountdownChip()),
      if (rooms.lastError != null) ...[
        const SizedBox(height: 12),
        Text(
          rooms.lastError!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error, fontSize: 12),
        ),
      ],
      const SizedBox(height: 18),
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
        style: TextStyle(
          fontSize: 11,
          color: Appearance.of(context).textMuted(0.55),
        ),
      ),
    ];
  }

  Future<void> _showCreateRoom(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final a = Appearance.of(ctx);
        return AlertDialog(
          backgroundColor: AppColors.nightMid,
          title: Text(
            'Criar sala',
            style: GoogleFonts.cormorantGaramond(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ex.: Turma 7º ano',
              hintStyle: TextStyle(color: a.textMuted(0.5)),
              filled: true,
              fillColor: a.cardFillSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: TextStyle(color: a.textMuted(0.7))),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.inkOnAccent,
              ),
              child: const Text('Criar', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
    controller.dispose();
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
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final a = Appearance.of(ctx);
        return AlertDialog(
          backgroundColor: AppColors.nightMid,
          title: Text(
            'Entrar na sala',
            style: GoogleFonts.cormorantGaramond(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 8,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              color: Colors.white,
              letterSpacing: 3,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              hintText: 'Código',
              hintStyle: TextStyle(color: a.textMuted(0.5), letterSpacing: 0),
              filled: true,
              fillColor: a.cardFillSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: TextStyle(color: a.textMuted(0.7))),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.inkOnAccent,
              ),
              child: const Text('Entrar', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
    controller.dispose();
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
          title: const Text('Sair da sala?', style: TextStyle(color: Colors.white)),
          content: Text(
            'Você sai do ranking desta sala. Pode entrar de novo com o código.',
            style: TextStyle(color: a.textMuted(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancelar', style: TextStyle(color: a.textMuted(0.7))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sair', style: TextStyle(color: AppColors.error)),
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
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: a.cardFillSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: a.cardBorder),
      ),
      child: Row(
        children: [
          _seg(context, 0, 'Caravana'),
          _seg(context, 1, 'Companhia'),
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
            error ??
                'Entre com Google para caminhar na caravana ao vivo.',
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
          'Estude em grupo',
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Professores e amigos criam salas com código — ranking só de quem entrou.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color: a.textMuted(0.7),
          ),
        ),
        const SizedBox(height: 24),
        if (loading)
          const CircularProgressIndicator(color: AppColors.accent)
        else ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.inkOnAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Criar sala',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onJoin,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Entrar com código',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
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
    );
  }
}

class _RoomHeader extends StatelessWidget {
  final StudyRoom room;
  final int? rank;
  final bool isOwner;
  final VoidCallback onCopy;
  final VoidCallback onLeave;
  final VoidCallback onRefresh;

  const _RoomHeader({
    required this.room,
    required this.rank,
    required this.isOwner,
    required this.onCopy,
    required this.onLeave,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      children: [
        Text(
          isOwner ? 'SUA SALA' : 'SALA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.accent.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          room.name,
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Criada por ${room.ownerName}',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: a.textMuted(0.65),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: onCopy,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: a.cardFillSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: a.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  room.code,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: a.textMuted(0.7),
                ),
              ],
            ),
          ),
        ),
        if (rank != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              gradient: AppGradients.gold,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Text(
              'Você está em $rankº lugar',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.inkOnAccent,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: onRefresh,
              icon: Icon(Icons.refresh_rounded, size: 16, color: a.textMuted(0.7)),
              label: Text(
                'Atualizar',
                style: TextStyle(color: a.textMuted(0.7), fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(
              onPressed: onLeave,
              child: const Text(
                'Sair',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LeagueHeader extends StatelessWidget {
  final int rank;
  final int weeklySteps;

  const _LeagueHeader({required this.rank, required this.weeklySteps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'CARAVANA DA SEMANA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.accent.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Quem deu mais passos — para se animarem uns aos outros.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: AppGradients.gold,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.35),
                blurRadius: 14,
              ),
            ],
          ),
          child: Text(
            'Você está em $rankº · $weeklySteps passos esta semana',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.inkOnAccent,
            ),
          ),
        ),
      ],
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(LeagueTier.values.length, (i) {
        final reached = i <= currentIndex;
        final current = i == currentIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            width: current ? 42 : 34,
            height: current ? 42 : 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: reached ? AppGradients.gold : null,
              color: reached ? null : Colors.white.withValues(alpha: 0.07),
              border: Border.all(
                color: current
                    ? Colors.white.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: reached ? 0.2 : 0.12),
                width: current ? 2 : 1,
              ),
              boxShadow: current
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.45),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: CinematicIcon(
                glyph: switch (LeagueTier.values[i]) {
                  LeagueTier.semente => CinematicGlyph.seed,
                  LeagueTier.videira => CinematicGlyph.tree,
                  LeagueTier.oliveira => CinematicGlyph.mountain,
                  LeagueTier.cedro => CinematicGlyph.crown,
                  LeagueTier.estrela => CinematicGlyph.star,
                },
                size: current ? 22 : 18,
                accent: reached ? AppColors.inkOnAccent : a.textMuted(0.4),
                glowing: false,
                framed: false,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CountdownChip extends StatelessWidget {
  const _CountdownChip();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final days = LeagueService.daysLeft();
    final text = days <= 1
        ? 'A caravana fecha hoje'
        : 'A caravana fecha em $days dias';
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: a.cardFillSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: a.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_bottom_rounded,
                size: 14, color: AppColors.streak),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: a.textMuted(0.8),
              ),
            ),
          ],
        ),
      ),
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
                await context
                    .read<ProgressService>()
                    .grantBonusSteps(LeagueService.promotionBonusXp);
              }
              await league.dismissOutcome();
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
            up ? Icons.keyboard_double_arrow_up_rounded : Icons.keyboard_double_arrow_down_rounded,
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
            error ??
                'Entre com Google para caminhar com alguém de verdade.',
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
            _OutlineAction(label: 'Convidar companheiro', onTap: onInvite),
            const SizedBox(height: 10),
            _OutlineAction(label: 'Entrar com código', onTap: onJoin),
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

  const _CompanionCard({
    required this.companion,
    required this.onCopy,
    required this.onLeave,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
