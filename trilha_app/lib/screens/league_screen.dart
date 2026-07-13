import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
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
    await league.settleWeekIfNeeded(
      lastWeekXp: progress.lastWeekXp,
      lastWeekKey: progress.lastWeekKey,
    );
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
    final progress = context.watch<ProgressService>();
    final league = context.watch<LeagueService>();
    final topInset = MediaQuery.of(context).padding.top;

    if (!league.isLoaded) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    final entries = league.standings(
      userName: progress.userName,
      userWeeklyXp: progress.weeklyXp,
    );
    final userRank = league.userRank(entries);
    final canPromote = league.tierIndex < LeagueTier.values.length - 1;
    final canDemote = league.tierIndex > 0;

    final children = <Widget>[
      _reveal(0, _LeagueHeader(tier: league.tier, rank: userRank)),
      const SizedBox(height: 18),
      _reveal(1, _TierLadder(currentIndex: league.tierIndex)),
      const SizedBox(height: 14),
      _reveal(2, const _CountdownChip()),
      if (league.pendingOutcome != null) ...[
        const SizedBox(height: 16),
        _reveal(3, _OutcomeBanner(league: league)),
      ],
      const SizedBox(height: 22),
    ];

    for (var i = 0; i < entries.length; i++) {
      final rank = i + 1;
      if (rank == 1 && canPromote) {
        children.add(_ZoneLabel(
          text: 'SOBEM PARA ${LeagueTier.values[league.tierIndex + 1].label.toUpperCase()}',
          up: true,
        ));
      }
      if (rank == LeagueService.groupSize - LeagueService.demoteCount + 1 &&
          canDemote) {
        children.add(_ZoneLabel(
          text: 'DESCEM PARA ${LeagueTier.values[league.tierIndex - 1].label.toUpperCase()}',
          up: false,
        ));
      }
      children.add(
        _reveal(
          (4 + i ~/ 4).clamp(0, 8),
          _StandingRow(entry: entries[i], rank: rank),
        ),
      );
      if (rank == LeagueService.promoteCount && canPromote) {
        children.add(const _ZoneDivider());
      }
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20, topInset + 72, 20, scrollPaddingBelowNav(context)),
      children: children,
    );
  }
}

class _LeagueHeader extends StatelessWidget {
  final LeagueTier tier;
  final int rank;

  const _LeagueHeader({required this.tier, required this.rank});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      children: [
        Text(
          'COMPETIÇÃO DA SEMANA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.accent.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          tier.label,
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
          tier.verse,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: a.textMuted(0.65),
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
            'Você está em $rankº lugar',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3D2E00),
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
                accent: reached ? const Color(0xFF3D2E00) : a.textMuted(0.4),
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
    final text = days <= 1 ? 'A liga fecha hoje!' : 'A liga fecha em $days dias';
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
          'Você subiu de liga!',
          'Terminou em ${league.pendingRank}º e avançou para a ${league.tier.label}. +${LeagueService.promotionBonusXp} XP de prêmio!',
        ),
      LeagueOutcome.stayed => (
          'Semana encerrada',
          'Você terminou em ${league.pendingRank}º e permanece na ${league.tier.label}. Nova semana, nova chance!',
        ),
      LeagueOutcome.demoted => (
          'Você desceu de liga',
          'Terminou em ${league.pendingRank}º. Recomece na ${league.tier.label} — dá pra voltar essa semana!',
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
                ? const Color(0xFF3D2E00)
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
                        ? const Color(0xFF3D2E00)
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
                    .grantBonusXp(LeagueService.promotionBonusXp);
              }
              await league.dismissOutcome();
            },
            child: Text(
              outcome == LeagueOutcome.promoted ? 'Coletar' : 'Ok',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: outcome == LeagueOutcome.promoted
                    ? const Color(0xFF3D2E00)
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
                    ? const Color(0xFF3D2E00)
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
                  color: entry.isUser ? const Color(0xFF3D2E00) : Colors.white,
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
                color: entry.isUser ? const Color(0xFF3D2E00) : a.text,
              ),
            ),
          ),
          Text(
            '${entry.xp} XP',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: entry.isUser
                  ? const Color(0xFF3D2E00)
                  : AppColors.accent.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
