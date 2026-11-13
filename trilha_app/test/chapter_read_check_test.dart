import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/chapter_read_check.dart';

void main() {
  test('tempo mínimo cresce com o capítulo, entre 20 s e 150 s', () {
    final short = ['Jesus chorou.'];
    final long = List.filled(50, List.filled(25, 'palavra').join(' '));
    expect(ChapterReadCheck.secondsFor(short), 20);
    expect(ChapterReadCheck.secondsFor(long), 150);
    final mid = List.filled(20, List.filled(25, 'palavra').join(' ')); // 500
    expect(ChapterReadCheck.secondsFor(mid), 60);
  });

  test('ouvir conta; abrir e fechar rápido não', () {
    final verses = List.filled(20, List.filled(25, 'palavra').join(' '));
    expect(
      ChapterReadCheck.attentive(
        verses: verses,
        open: const Duration(seconds: 5),
      ),
      isFalse,
    );
    expect(
      ChapterReadCheck.attentive(
        verses: verses,
        open: const Duration(seconds: 5),
        listened: true,
      ),
      isTrue,
    );
    expect(
      ChapterReadCheck.attentive(
        verses: verses,
        open: const Duration(minutes: 2),
      ),
      isTrue,
    );
  });
}
