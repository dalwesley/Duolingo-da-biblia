import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/services/progress_service.dart';

void main() {
  const slug = 'genesis-1-11';
  const missions = ['m1', 'm2', 'm3'];

  ProgressService seeded() {
    final progress = ProgressService();
    progress.trailDifficulties = {slug: 'semente'};
    progress.pinnedTrailDifficulties = {slug: 'semente'};
    progress.clearedTrailModes = {
      slug: ['semente'],
    };
    progress.completedMissions = ['m1'];
    return progress;
  }

  test('entering a scene advances past a cleared mode even if pinned', () async {
    final progress = seeded();
    expect(progress.difficultyForTrail(slug), 'caminhada');

    final moved = await progress.advancePastClearedMode(
      slug,
      missionSlugs: missions,
    );

    expect(moved, isTrue);
    expect(progress.storedDifficultyForTrail(slug), 'caminhada');
    expect(progress.canonicalDifficultyId(slug), 'caminhada');
    expect(progress.difficultyForTrail(slug), 'caminhada');
    expect(progress.completedMissions, isEmpty);
  });

  test('session switch does not persist and restores canonical', () async {
    final progress = seeded();
    await progress.advancePastClearedMode(slug, missionSlugs: missions);
    progress.completedMissions = ['m1'];

    progress.setSessionTrailDifficulty(
      slug,
      TrailDifficulty.semente.id,
      missionSlugs: missions,
    );

    expect(progress.hasSessionDifficulty(slug), isTrue);
    expect(progress.difficultyForTrail(slug), 'semente');
    expect(progress.canonicalDifficultyId(slug), 'caminhada');
    expect(progress.storedDifficultyForTrail(slug), 'caminhada');
    expect(progress.completedMissions, ['m1']);
    expect(
      progress.completedMissionsForTrail(trailSlug: slug, missionSlugs: missions)
          .toSet(),
      {'m1', 'm2', 'm3'},
    );
    expect(progress.isSessionReplayMission('m2'), isTrue);

    progress.setSessionTrailDifficulty(
      slug,
      TrailDifficulty.caminhada.id,
      missionSlugs: missions,
    );

    expect(progress.hasSessionDifficulty(slug), isFalse);
    expect(progress.difficultyForTrail(slug), 'caminhada');
    expect(progress.completedMissions, ['m1']);
    expect(
      progress.completedMissionsForTrail(trailSlug: slug, missionSlugs: missions),
      ['m1'],
    );
  });

  test('session switch is not written to the cloud map', () async {
    final progress = seeded();
    await progress.advancePastClearedMode(slug, missionSlugs: missions);
    progress.setSessionTrailDifficulty(slug, 'semente', missionSlugs: missions);

    final cloud = progress.toCloudMap();
    expect(cloud['trailDifficulties'], {slug: 'caminhada'});
    expect(progress.difficultyForTrail(slug), 'semente');
  });
}
