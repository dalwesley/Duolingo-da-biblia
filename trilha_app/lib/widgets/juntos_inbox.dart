import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/companion_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/recognition_service.dart';
import '../services/room_service.dart';
import '../theme/app_theme.dart';
import 'league_outcome_card.dart';
import 'league_risk_card.dart';
import 'recognition_home_card.dart';
import 'ui_primitives.dart';

/// Novidades da caravana, no topo da aba Caravana: resultado da semana,
/// risco de descer e reconhecimentos.
///
/// O desafio mora na aba Desafio. O aceno da companhia já tem banner no
/// card da Companhia. Nada fica acima das abas; um ponto na aba avisa.
/// Na Home, o desafio aparece como linha em "Mais para hoje".
class JuntosInbox extends StatelessWidget {
  final VoidCallback onOpenCaravana;

  const JuntosInbox({super.key, required this.onOpenCaravana});

  /// Novidades de Juntos para o cartão da Home. O desafio tem linha própria.
  static int pending(BuildContext context) {
    var n = caravanPending(context);
    if (context.watch<CompanionService>().incomingNudge != null) n++;
    n += context.watch<RoomService>().incoming.length;
    return n;
  }

  /// Novidades que moram na aba Caravana (o ponto na aba).
  static int caravanPending(BuildContext context) {
    var n = 0;
    final league = context.watch<LeagueService>();
    if (league.isLoaded && league.pendingOutcome != null) n++;
    if (context.watch<RecognitionService>().incoming.isNotEmpty) n++;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final league = context.watch<LeagueService>();
    final recognitions = context.watch<RecognitionService>().incoming;
    final progress = context.watch<ProgressService>();

    var nearDemotion = false;
    if (league.isLoaded) {
      final entries = league.standings(
        userName: progress.userName,
        userWeeklySteps: progress.weeklySteps,
      );
      nearDemotion = league.isNearDemotion(league.userRank(entries));
    }

    final items = <Widget>[
      if (league.isLoaded && league.pendingOutcome != null)
        const LeagueOutcomeCard(),
      if (nearDemotion) LeagueRiskCard(onOpenLeague: onOpenCaravana),
      if (recognitions.isNotEmpty) RecognitionHomeCard(items: recognitions),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    // Uma novidade só já tem o próprio rótulo no card; com várias, um
    // rótulo curto agrupa e separa do placar logo abaixo.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.length > 1)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpace.xs,
              bottom: AppSpace.sm,
            ),
            child: SectionLabel(
              'Novidades · ${items.length}',
              color: AppColors.accent.withValues(alpha: 0.9),
            ),
          ),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpace.md),
          items[i],
        ],
        const SizedBox(height: AppSpace.xl),
      ],
    );
  }
}
