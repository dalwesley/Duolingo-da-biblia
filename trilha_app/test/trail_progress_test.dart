import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/utils/trail_progress.dart';

void main() {
  final trail = Trail(
    slug: 'test',
    title: 'Test',
    description: 'Test trail',
    icon: '📖',
    order: 1,
    comingSoon: false,
    color: '#2F5D4A',
    modules: [
      TrailModule(
        title: 'Mod 1',
        icon: '🌍',
        missions: [
          Mission(slug: 'm1', title: 'M1', intro: '', type: 'lesson', stepsReward: 50, questions: []),
          Mission(slug: 'm2', title: 'M2', intro: '', type: 'lesson', stepsReward: 50, questions: []),
        ],
      ),
    ],
  );

  test('first mission is always unlocked', () {
    expect(TrailProgress.isMissionUnlocked('m1', trail.missionSlugs, []), isTrue);
    expect(TrailProgress.isMissionUnlocked('m2', trail.missionSlugs, []), isFalse);
  });

  test('progress calculates correctly', () {
    final prog = TrailProgress.getProgress(trail, ['m1']);
    expect(prog.done, 1);
    expect(prog.total, 2);
    expect(prog.pct, 50);
  });

  test('trail unlock requires prerequisite completion', () {
    final trails = [
      trail,
      Trail(
        slug: 't2',
        title: 'T2',
        description: '',
        icon: '📖',
        order: 2,
        unlockAfter: 'test',
        comingSoon: false,
        color: '#2F5D4A',
        modules: [],
      ),
    ];
    expect(TrailProgress.isTrailUnlocked(trails[1], trails, []), isFalse);
    expect(TrailProgress.isTrailUnlocked(trails[1], trails, ['m1', 'm2']), isTrue);
  });
}
