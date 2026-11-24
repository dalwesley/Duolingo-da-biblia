import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trilha_app/l10n/app_language.dart';
import 'package:trilha_app/services/bible_service.dart';
import 'package:trilha_app/widgets/verse_compare_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('compare sheet lists every version and the active first', (
    tester,
  ) async {
    // Tela de celular (Redmi Note 8): a folha sobe da base.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.runAsync(
      () => BibleService.instance.setTranslation('pt=jfaal'),
    );
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) {
            ctx = c;
            return const Scaffold();
          },
        ),
      ),
    );
    showVerseCompareSheet(
      ctx,
      bookIndex: 0,
      bookName: 'Gênesis',
      chapter: 1,
      verse: 1,
    );
    // Carrega as quatro traduções (asset + isolate) fora do relógio falso.
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      if (find.textContaining('In the beginning').evaluate().isNotEmpty &&
          find.textContaining('Al principio').evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.text('Gênesis 1:1'), findsOneWidget);
    expect(find.text('Versículo 1 de 31'), findsOneWidget);
    for (final code in ['JFAAL · PT', 'TB · PT', 'BSB · EN', 'BES · ES']) {
      expect(
        find.textContaining(code, findRichText: true),
        findsWidgets,
        reason: code,
      );
    }
    expect(find.textContaining('No princípio'), findsWidgets);
    expect(find.textContaining('In the beginning'), findsOneWidget);
    expect(find.textContaining('Al principio'), findsOneWidget);
    // Ativa (JFAAL) no topo, antes das outras.
    final hero = tester
        .getTopLeft(find.textContaining('JFAAL · PT', findRichText: true))
        .dy;
    final en = tester.getTopLeft(find.textContaining('In the beginning')).dy;
    expect(hero, lessThan(en));
    expect(find.byTooltip('Copiar tudo'), findsOneWidget);
    // Outras versões na ordem PT → EN → ES.
    final tb = tester
        .getTopLeft(find.textContaining('TB · PT', findRichText: true))
        .dy;
    final bsb = tester
        .getTopLeft(find.textContaining('BSB · EN', findRichText: true))
        .dy;
    expect(tb, lessThan(bsb));

    // Seta: próximo versículo sem fechar a folha.
    // Termina a animação de entrada da folha.
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Próximo versículo'));
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 400));
      if (find.text('Gênesis 1:2').evaluate().isNotEmpty &&
          find.text('Versículo 2 de 31').evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.text('Gênesis 1:2'), findsOneWidget);
    expect(find.text('Versículo 2 de 31'), findsOneWidget);
  });
}
