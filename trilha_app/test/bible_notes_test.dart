import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/l10n/app_language.dart';
import 'package:trilha_app/models/bible_note.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/widgets/share_verse_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('note survives the cloud round trip', () async {
    final a = ProgressService();
    await a.setVerseNote('gn', 14, 1, tag: BibleNoteTag.promessa, text: ' Fé ');

    final b = ProgressService();
    await b.applyFromCloud(a.toCloudMap());

    final note = b.verseNote('gn', 14, 1);
    expect(note?.tag, BibleNoteTag.promessa);
    expect(note?.text, 'Fé');
    expect(b.parseNotes().single.chapter, 14);
  });

  test('deleted note does not come back from an older cloud copy', () async {
    final p = ProgressService();
    await p.setVerseNote('jo', 3, 16, tag: BibleNoteTag.jesus, text: '');
    final older = p.toCloudMap();
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await p.setVerseNote('jo', 3, 16, tag: null, text: '');

    await p.applyFromCloud(older);

    expect(p.verseNote('jo', 3, 16), isNull);
    expect(p.parseNotes(), isEmpty);
  });

  testWidgets('share card shows the note theme, author and text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: ShareVerseCard(
              bookName: 'Gênesis',
              chapter: 13,
              verse: 2,
              text: 'E Abrão era extremamente rico.',
              note: BibleNote(
                tag: BibleNoteTag.promessa,
                text: 'Deus cuida',
                updatedAtMs: 1,
              ),
              noteAuthor: 'Anotação de Ana',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Promessa · Anotação de Ana'), findsOneWidget);
    expect(find.text('Deus cuida'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
