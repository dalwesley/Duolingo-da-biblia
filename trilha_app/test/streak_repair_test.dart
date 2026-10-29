import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/l10n/app_language.dart';
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
    progress.lastPlayedDate = DateTime.now().toIso8601String().substring(0, 10);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const Scaffold(body: StreakRepairCelebrationCard()),
        ),
      ),
    );

    expect(find.text('4 dias ainda podem voltar'), findsOneWidget);
    expect(find.text('Continue com 5 · 1× neste mês'), findsOneWidget);
    expect(find.text('Recuperar'), findsOneWidget);
    expect(find.text('REPARAR SEQUÊNCIA'), findsNothing);
    expect(find.text('Recomeçar do 1'), findsNothing);
  });

  test(
    'repair works before or after today\'s scene and expires after a gap',
    () async {
      SharedPreferences.setMockInitialValues({});
      String key(int daysAgo) => DateTime.now()
          .subtract(Duration(days: daysAgo))
          .toIso8601String()
          .substring(0, 10);

      final progress = ProgressService()
        ..streakRepairPending = true
        ..brokenStreak = 6
        ..streak = 1
        ..lastPlayedDate = key(1);

      expect(progress.showStreakRepairOffer, isTrue);
      expect(progress.streakRepairRestored, 7);
      expect(await progress.claimStreakRepair(), isTrue);
      expect(progress.streak, 7);
      expect(
        progress.wasRepairedOnDate(
          DateTime.now().subtract(const Duration(days: 2)),
        ),
        isTrue,
      );
      expect(progress.showStreakRepairOffer, isFalse);

      // Jogou depois do recomeço sem reparar: a oferta segue e soma os dias.
      final kept = ProgressService()
        ..streakRepairPending = true
        ..brokenStreak = 6
        ..streak = 2
        ..lastPlayedDate = key(0);
      expect(kept.showStreakRepairOffer, isTrue);
      expect(kept.streakRepairRestored, 8);
      expect(
        kept.streakRepairMissedDay!.day,
        DateTime.now().subtract(const Duration(days: 2)).day,
      );
      kept.streak = ProgressService.streakRepairWindowDays + 1;
      expect(kept.showStreakRepairOffer, isFalse);

      final stale = ProgressService()
        ..streakRepairPending = true
        ..brokenStreak = 6
        ..streak = 1
        ..lastPlayedDate = key(2);
      expect(stale.showStreakRepairOffer, isFalse);
      expect(await stale.claimStreakRepair(), isFalse);
    },
  );
}
