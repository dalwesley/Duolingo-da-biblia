import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/l10n/l10n_global.dart';
import 'package:trilha_app/services/bible_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('looksLikeReference accepts citations and rejects labels', () {
    expect(BibleService.looksLikeReference('Gênesis 1:1–2'), isTrue);
    expect(BibleService.looksLikeReference('Êxodo 3'), isTrue);
    expect(BibleService.looksLikeReference('1 Pedro 2:9'), isTrue);
    expect(BibleService.looksLikeReference('Contexto'), isFalse);
    expect(BibleService.looksLikeReference(''), isFalse);
  });

  test('default reading translation is Almeida, not TB', () {
    expect(BibleService.defaultTranslationId, 'jfaal');
    expect(BibleService.instance.readerTranslationId, isNot('tb'));
  });

  group('EN/ES', () {
    tearDown(() => L10n.setLocale(const Locale('pt')));

    test('app language picks its own default translation', () {
      expect(BibleService.effectiveId('jfaal', 'pt'), 'jfaal');
      expect(BibleService.effectiveId('tb', 'pt'), 'tb');
      expect(BibleService.effectiveId('jfaal', 'en'), 'bsb');
      expect(BibleService.effectiveId('jfaal', 'es'), 'bes');
      expect(BibleService.effectiveId('bsb', 'pt'), 'jfaal');
      expect(BibleService.effectiveId('ara', 'pt'), 'jfaal');
    });

    test('reader lists every text language, PT first', () {
      expect(BibleService.textLanguages, ['pt', 'en', 'es']);
      expect(BibleService.translationsIn('en').map((t) => t.id), ['bsb']);
      expect(BibleService.translationsIn('es').map((t) => t.id), ['bes']);
      expect(
        BibleService.translationsIn('pt').map((t) => t.id),
        containsAll(['tb', 'jfaal']),
      );
    });

    test('choice is kept per app language', () {
      // App em PT escolhe BSB: só o PT muda.
      var stored = BibleService.withChoice('jfaal', 'bsb', 'pt');
      expect(stored, 'pt=bsb');
      expect(BibleService.effectiveId(stored, 'pt'), 'bsb');
      expect(BibleService.effectiveId(stored, 'en'), 'bsb');
      expect(BibleService.effectiveId(stored, 'es'), 'bes');
      // App em EN escolhe TB: PT continua BSB.
      stored = BibleService.withChoice(stored, 'tb', 'en');
      expect(stored, 'pt=bsb;en=tb');
      expect(BibleService.effectiveId(stored, 'pt'), 'bsb');
      expect(BibleService.effectiveId(stored, 'en'), 'tb');
      // Legado sem "=": vale para o idioma do próprio texto.
      expect(BibleService.effectiveId('tb', 'pt'), 'tb');
      expect(BibleService.effectiveId('tb', 'en'), 'bsb');
      // "Em breve" ou lixo: padrão do idioma.
      expect(BibleService.effectiveId('pt=ara', 'pt'), 'jfaal');
      expect(BibleService.effectiveId('pt=xyz;', 'pt'), 'jfaal');
    });

    test('verseIn reads any translation and releaseExtras frees it', () async {
      final bible = BibleService.instance;
      await bible.setTranslation('jfaal');
      expect(
        await bible.verseIn('bsb', 0, 1, 1),
        startsWith('In the beginning'),
      );
      expect(await bible.verseIn('bes', 42, 3, 16), contains('Dios'));
      expect(await bible.verseIn('jfaal', 0, 1, 1), startsWith('No princípio'));
      // Mt 17:21 é omitido na BSB: sem texto, não string vazia.
      expect(await bible.verseIn('bsb', 39, 17, 21), isNull);
      expect(await bible.verseIn('bsb', 0, 99, 1), isNull);
      bible.releaseExtras();
      expect(bible.translationId, 'jfaal');
    });

    test('palco stays on JFAAL in every language', () {
      expect(BibleService.palcoTranslationId, 'jfaal');
    });

    test('EN/ES assets keep PT abbrev keys and JFAAL versification', () {
      List<dynamic> load(String id) =>
          jsonDecode(File('assets/data/bible_$id.json').readAsStringSync())
              as List<dynamic>;
      final pt = load('jfaal');
      for (final id in ['bsb', 'bes']) {
        final other = load(id);
        expect(other.length, pt.length, reason: id);
        for (var i = 0; i < pt.length; i++) {
          final a = pt[i] as Map<String, dynamic>;
          final b = other[i] as Map<String, dynamic>;
          expect(b['abbrev'], a['abbrev'], reason: '$id #$i');
          final ca = a['chapters'] as List<dynamic>;
          final cb = b['chapters'] as List<dynamic>;
          expect(cb.length, ca.length, reason: '$id ${a['abbrev']}');
          for (var c = 0; c < ca.length; c++) {
            expect(
              (cb[c] as List).length,
              (ca[c] as List).length,
              reason: '$id ${a['abbrev']} ${c + 1}',
            );
          }
        }
      }
    });

    test('PT references resolve in the EN text', () async {
      L10n.setLocale(const Locale('en'));
      final bible = BibleService.instance;
      await bible.setTranslation('jfaal');
      expect(bible.translationId, 'bsb');
      final text = await bible.passageText('Gênesis 1:1');
      expect(text, startsWith('In the beginning God created'));
      expect(await bible.passageText('Exodus 3:14'), contains('I AM'));
      expect(await bible.passageText('Êx 3:14'), contains('I AM'));
      final books = await bible.books();
      expect(books[1].abbrev, 'Êx');
      expect(books[1].short, 'Ex');
      expect(books[1].name, 'Exodus');
    });

    test('PT references resolve in the ES text', () async {
      L10n.setLocale(const Locale('es'));
      final bible = BibleService.instance;
      expect(bible.translationId, 'bes');
      expect(await bible.passageText('João 3:16'), contains('Dios'));
      expect(await bible.passageText('Juan 3:16'), contains('Dios'));
    });
  });
}
