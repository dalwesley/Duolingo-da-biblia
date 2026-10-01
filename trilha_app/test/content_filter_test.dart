import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/content_filter.dart';

void main() {
  test('nomes comuns passam', () {
    for (final name in [
      'Ana Clara',
      'João Paulo',
      'Célula Esperança',
      'EBD Curso Bíblico',
      'Família Cunha',
      'Discipulado Retardar não',
      'Grupo de oração',
      'Maria das Dores',
      'Escrituras',
    ]) {
      expect(ContentFilter.isAllowed(name), isTrue, reason: name);
    }
  });

  test('palavrões e disfarces são barrados', () {
    for (final name in [
      'porra',
      'P0RR4',
      'caralhoooo',
      'filho da puta',
      'f.d.p',
      'c.a.r.a.l.h.o',
      'Fuck you',
      'hijo de puta',
      'Admin STWAY',
    ]) {
      expect(ContentFilter.isAllowed(name), isFalse, reason: name);
    }
  });
}
