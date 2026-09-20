import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/streak_repair_banner.dart';

void main() {
  testWidgets('celebration repair is a quiet row, not a second gold CTA', (
    tester,
  ) async {
    final progress = ProgressService();
    progress.streakRepairPending = true;
    progress.brokenStreak = 4;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: StreakRepairCelebrationCard()),
        ),
      ),
    );

    expect(find.text('4 dias ainda podem voltar'), findsOneWidget);
    expect(find.text('Segue com 5 · 1× neste mês'), findsOneWidget);
    expect(find.text('Reparar'), findsOneWidget);
    expect(find.text('REPARAR SEQUÊNCIA'), findsNothing);
    expect(find.text('Recomeçar do 1'), findsNothing);
  });
}
