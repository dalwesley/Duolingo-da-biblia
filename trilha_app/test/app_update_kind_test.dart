import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/app_update_service.dart';

void main() {
  test('local build ahead of the store stays quiet', () {
    expect(
      AppUpdateService.resolveKind(
        localBuild: 27,
        latestBuild: 14,
        minBuild: 0,
      ),
      AppUpdateKind.none,
    );
  });

  test('store build ahead is a soft prompt', () {
    expect(
      AppUpdateService.resolveKind(
        localBuild: 27,
        latestBuild: 28,
        minBuild: 10,
      ),
      AppUpdateKind.soft,
    );
  });

  test('below min build is forced even if the store build matches', () {
    expect(
      AppUpdateService.resolveKind(
        localBuild: 8,
        latestBuild: 28,
        minBuild: 10,
      ),
      AppUpdateKind.force,
    );
  });

  test('equal builds do not prompt', () {
    expect(
      AppUpdateService.resolveKind(
        localBuild: 27,
        latestBuild: 27,
        minBuild: 1,
      ),
      AppUpdateKind.none,
    );
  });

  test('missing store build does not invent an update', () {
    expect(
      AppUpdateService.resolveKind(localBuild: 27, latestBuild: 0, minBuild: 0),
      AppUpdateKind.none,
    );
  });

  test('preview flag shows soft even when the local build is ahead', () {
    expect(
      AppUpdateService.resolveKind(
        localBuild: 27,
        latestBuild: 14,
        minBuild: 0,
        preview: true,
      ),
      AppUpdateKind.soft,
    );
  });
}
