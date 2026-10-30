import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/data/curated_trails.dart';
import 'package:trilha_app/data/trail_art.dart';
import 'package:trilha_app/data/trail_repository.dart';
import 'package:trilha_app/models/trail_catalog.dart';
import 'package:trilha_app/utils/plus_access.dart';

void main() {
  final promise = CuratedTrails.overlay.single;

  test('A Promessa: 12 cenas em 4 blocos, todas com banco de origem', () {
    expect(promise.slug, CuratedTrails.promiseSlug);
    expect(promise.modules, hasLength(4));
    expect(CuratedTrails.promiseBlocks.map((b) => b.scenes.length), [
      3,
      3,
      3,
      3,
    ]);
    // A Travessia de síntese fecha o último bloco.
    final last = promise.modules.last.missions.last;
    expect(last.slug, CuratedTrails.synthesisSlug);
    expect(last.isBoss, isTrue);
    expect(last.bankTrailSlug, CuratedTrails.promiseSlug);
    for (final m
        in promise.modules
            .expand((mod) => mod.missions)
            .where((m) => !m.isBoss)) {
      expect(m.bankSection, CuratedTrails.originOf(m.slug));
      expect(m.bankTrailSlug, isNotEmpty);
      expect(m.hookRef, isNotEmpty);
    }
  });

  test('fica no card Promessa e cumprimento, do Plus desde a 1ª cena', () {
    expect(promise.journey, TrailJourney.promessaCumprimento);
    expect(PlusAccess.trailIsPlus(promise), isTrue);
    expect(PlusAccess.missionNeedsPlus(promise, 'promessa-01'), isTrue);
    expect(PlusAccess.missionNeedsPlus(promise, 'promessa-02'), isTrue);
  });

  test('a cena curada e a de origem contam uma pela outra', () {
    expect(CuratedTrails.linkedScenes('promessa-03'), {'gen12-09-moria'});
    expect(CuratedTrails.linkedScenes('gen12-09-moria'), {'promessa-03'});
    expect(CuratedTrails.linkedScenes('gen12-02-egito-e-lot'), isEmpty);
  });

  test('a cena mostra a pintura da origem', () {
    expect(
      TrailArt.ofScene(CuratedTrails.promiseSlug, 'promessa-01'),
      'assets/art/scene_gen12-01-chamado.jpg',
    );
  });

  test('o catálogo traz a trilha curada e ela vence um stub remoto', () {
    final merged = TrailRepository.mergeEntry(const []);
    expect(
      merged.where((t) => t.slug == CuratedTrails.promiseSlug),
      hasLength(1),
    );
  });

  test('mapa: erros do bloco pela seção de origem, não de outra cena', () {
    const mistakes = [
      'genesis-12-50-sem-gen12-09-moria-03',
      'genesis-12-50-cam-gen12-02-egito-e-lot-01',
      'exodo-pro-exo-07-sinai-05',
    ];
    final first = CuratedTrails.promiseBlocks.first.scenes.map(
      (m) => m.resolvedBankSection,
    );
    expect(CuratedTrails.mistakesFor(mistakes, first), [
      'genesis-12-50-sem-gen12-09-moria-03',
    ]);
    expect(CuratedTrails.synthesisQuestionIds, hasLength(3));
  });
}
