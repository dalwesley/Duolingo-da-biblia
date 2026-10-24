import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/models/bible_note.dart';
import 'package:trilha_app/services/progress_service.dart';

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
}
