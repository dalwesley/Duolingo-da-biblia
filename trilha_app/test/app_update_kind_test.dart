import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/app_update_service.dart';

AppUpdateKind _kind(
  String local,
  String? store, {
  int localBuild = 49,
  int minBuild = 0,
  bool preview = false,
}) => AppUpdateService.resolveKind(
  localVersion: local,
  storeVersion: store,
  localBuild: localBuild,
  minBuild: minBuild,
  preview: preview,
);

void main() {
  test('local version ahead of the store stays quiet', () {
    expect(_kind('1.0.50', '1.0.49'), AppUpdateKind.none);
  });

  test('store version ahead is a soft prompt', () {
    expect(_kind('1.0.49', '1.0.50'), AppUpdateKind.soft);
  });

  test('compares numerically, not as text', () {
    expect(_kind('1.0.9', '1.0.10'), AppUpdateKind.soft);
    expect(_kind('1.0.10', '1.0.9'), AppUpdateKind.none);
    expect(_kind('1.9.0', '2.0.0'), AppUpdateKind.soft);
  });

  test('below min build is forced even if versions match', () {
    expect(
      _kind('1.0.8', '1.0.8', localBuild: 8, minBuild: 10),
      AppUpdateKind.force,
    );
  });

  test('min build is forced even when the store lookup failed', () {
    expect(
      _kind('1.0.8', null, localBuild: 8, minBuild: 10),
      AppUpdateKind.force,
    );
  });

  test('equal versions do not prompt', () {
    expect(_kind('1.0.49', '1.0.49', minBuild: 1), AppUpdateKind.none);
  });

  test('missing store version does not invent an update', () {
    expect(_kind('1.0.49', null), AppUpdateKind.none);
    expect(_kind('1.0.49', ''), AppUpdateKind.none);
  });

  test('preview flag shows soft even when the local version is ahead', () {
    expect(_kind('1.0.50', '1.0.49', preview: true), AppUpdateKind.soft);
  });

  test('compareVersions ignores build suffix and missing parts', () {
    expect(AppUpdateService.compareVersions('1.0.49+49', '1.0.49'), 0);
    expect(AppUpdateService.compareVersions('1.0', '1.0.0'), 0);
    expect(AppUpdateService.compareVersions('1.0', '1.0.1'), lessThan(0));
  });
}
