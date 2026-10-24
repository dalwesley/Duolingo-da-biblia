import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/l10n/app_language.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/cinematic_icon.dart';
import 'package:trilha_app/widgets/journey_station_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('estações usam o tamanho do card em curso', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<Size> measure(
      JourneyNodeState state, {
      bool plus = false,
      String title = 'Gênesis 12–50',
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: Scaffold(
            body: SingleChildScrollView(
              child: JourneyStationCard(
                title: title,
                eyebrow: 'Trilha II',
                state: state,
                accent: const Color(0xFF2E8B57),
                glow: const Color(0xFF2E8B57),
                glyph: CinematicGlyph.book,
                watermark: 'II',
                currentSubtitle: state == JourneyNodeState.current
                    ? 'Modo Observação'
                    : null,
                statusLine: state == JourneyNodeState.current
                    ? null
                    : 'Termine Gênesis 12–50 para abrir',
                done: 4,
                total: 20,
                plusLocked: plus,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      return tester.getSize(find.byType(JourneyStationCard));
    }

    final current = await measure(JourneyNodeState.current);
    final locked = await measure(JourneyNodeState.locked);
    final done = await measure(JourneyNodeState.completed);
    final soon = await measure(JourneyNodeState.soon);
    final plus = await measure(JourneyNodeState.current, plus: true);
    final longTitle = await measure(
      JourneyNodeState.locked,
      title: 'Deuteronômio',
    );

    expect(current, const Size(220, 129));
    expect(locked, current);
    expect(done, current);
    expect(soon, current);
    expect(longTitle, current);
    expect(plus.width, current.width);
    expect(plus.height, greaterThan(current.height));
  });
}
