import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/models/room_week.dart';
import 'package:trilha_app/screens/room_reveal_screen.dart';
import 'package:trilha_app/services/backend_service.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/services/room_service.dart';
import 'package:trilha_app/services/subscription_service.dart';

import 'helpers/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  RoomClosing closing({List<String> faithful = const ['a', 'b', 'c']}) =>
      RoomClosing(
        week: 'w',
        groupPct: 78,
        members: 12,
        faithful: faithful,
        constant: const ['d'],
        grown: const ['e'],
        names: const {
          'a': 'Ana',
          'b': 'Lucas',
          'c': 'Maria Eduarda Albuquerque',
          'd': 'Marta',
          'e': 'Pedro',
        },
        studyTitle: 'Êxodo · O sangue na porta',
        readingLabel: 'Êxodo 12–14',
      );

  Future<void> pump(WidgetTester tester, RoomClosing c) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SubscriptionService>.value(
            value: SubscriptionService(),
          ),
          ChangeNotifierProvider<ProgressService>.value(
            value: ProgressService(),
          ),
          ChangeNotifierProvider<RoomService>.value(
            value: RoomService(BackendService()),
          ),
        ],
        child: l10nApp(
          RoomRevealScreen(
            closing: c,
            roomName: 'Célula Esperança',
            isLeader: true,
            myUid: 'a',
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> settleBeat(WidgetTester tester) async {
    for (var i = 0; i < 45; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('a cerimônia passa por todas as etapas e termina nos botões', (
    tester,
  ) async {
    await pump(tester, closing());
    await settleBeat(tester);
    await tester.tap(find.text('A semana do grupo'));
    await settleBeat(tester);
    expect(find.text('78%'), findsOneWidget);
    expect(find.text('Caminhamos juntos'), findsOneWidget);

    await tester.tap(find.text('78%'));
    await settleBeat(tester);
    expect(find.text('Lucas'), findsOneWidget);
    expect(find.text('Você'), findsOneWidget);

    await tester.tap(find.text('Fiéis na semana'));
    await settleBeat(tester);
    expect(find.text('Marta'), findsOneWidget);

    await tester.tap(find.text('Marta'));
    await settleBeat(tester);
    expect(find.text('Mandar o resumo no grupo'), findsOneWidget);
    expect(find.text('Amém'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem fiéis: mensagem gentil, sem confete', (tester) async {
    await pump(tester, closing(faithful: const []));
    await settleBeat(tester);
    await tester.tap(find.text('A semana do grupo'));
    await settleBeat(tester);
    await tester.tap(find.text('78%'));
    await settleBeat(tester);
    expect(
      find.textContaining('Desta vez ninguém completou tudo'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
