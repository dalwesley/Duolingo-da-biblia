import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/data/trail_art.dart';

void main() {
  test('-cap trail uses the book trail painting', () {
    expect(TrailArt.bookOf('1corintios-cap'), 'corintios');
    expect(TrailArt.bookOf('1joao-cap'), 'cartas-joao');
    expect(TrailArt.bookOf('joao-cap'), 'joao');
    expect(TrailArt.bookOf('canticos-cap'), 'cantares');
    expect(TrailArt.bookOf('genesis-cap'), 'genesis-1-11');
    expect(TrailArt.bookOf('romanos'), 'romanos');
  });

  test('every -cap trail in trails.json has a painting on disk', () {
    final trails = jsonDecode(
      File('assets/data/trails.json').readAsStringSync(),
    ) as List;
    final cap = trails
        .map((t) => (t as Map)['slug'] as String)
        .where((s) => s.endsWith('-cap'))
        .toList();
    expect(cap, isNotEmpty);
    for (final slug in cap) {
      final art = TrailArt.of(slug);
      expect(art, isNotNull, reason: slug);
      expect(File(art!).existsSync(), isTrue, reason: '$slug → $art');
      expect(TrailArt.ofScene(slug, 'no-such-scene'), art, reason: slug);
    }
  });
}
