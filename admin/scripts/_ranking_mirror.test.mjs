import test from 'node:test';
import assert from 'node:assert/strict';
import {
  inspectOverall,
  inspectWeekly,
  inspectMonthly,
  inspectRoomMember,
  rankingPayload,
  suspiciousProgress,
  userTotalSteps,
  mondayKey,
} from './_ranking_mirror.mjs';

test('overall mismatch when ranking xp differs from users.steps', () => {
  const hit = inspectOverall('u1', { steps: 40, xp: 40 }, { xp: 9999 });
  assert.equal(hit.kind, 'overall');
  assert.equal(hit.expected, 40);
  assert.equal(hit.actual, 9999);
});

test('overall matches when ranking mirrors users', () => {
  assert.equal(inspectOverall('u1', { steps: 40 }, { xp: 40 }), null);
});

test('weekly xp must equal weeklySteps, not lifetime steps', () => {
  const user = { steps: 900, weeklySteps: 30, weeklyWeek: '2026-09-01' };
  assert.equal(
    inspectWeekly('u1', user, { xp: 30 }, '2026-09-01'),
    null,
  );
  const hit = inspectWeekly('u1', user, { xp: 900 }, '2026-09-01');
  assert.equal(hit.kind, 'weekly');
  assert.equal(hit.expected, 30);
});

test('weekly board in another week is flagged', () => {
  const hit = inspectWeekly(
    'u1',
    { weeklySteps: 30, weeklyWeek: '2026-09-01' },
    { xp: 30 },
    '2026-08-25',
  );
  assert.equal(hit.kind, 'weekly-week');
});

test('monthly and room follow the same contract', () => {
  const user = {
    monthlySteps: 80,
    monthlyMonth: '2026-09',
    weeklySteps: 12,
  };
  assert.equal(
    inspectMonthly('u1', user, { xp: 80 }, '2026-09'),
    null,
  );
  assert.equal(
    inspectRoomMember('u1', user, { xp: 12 }, 'ABC123'),
    null,
  );
  assert.equal(
    inspectRoomMember('u1', user, { xp: 500 }, 'ABC123').actual,
    500,
  );
});

test('payload keeps name and xp the client already publishes', () => {
  const payload = rankingPayload(
    { userName: 'Ana', lastPlayedDate: '2026-09-03' },
    { xp: 40, tier: 1 },
  );
  assert.deepEqual(
    { name: payload.name, xp: payload.xp, tier: payload.tier },
    { name: 'Ana', xp: 40, tier: 1 },
  );
});

test('suspicious heuristic ignores normal vitrine progress', () => {
  const missions = Array.from({ length: 10 }, (_, i) => `m${i}`);
  assert.equal(
    suspiciousProgress('u1', { steps: 800, completedMissions: missions }),
    null,
  );
  const hit = suspiciousProgress('u1', {
    steps: 50000,
    completedMissions: ['sm-01'],
  });
  assert.equal(hit.kind, 'suspicious-steps');
});

test('mondayKey is YYYY-MM-DD', () => {
  assert.match(mondayKey(new Date('2026-09-03T15:00:00-03:00')), /^\d{4}-\d{2}-\d{2}$/);
  assert.equal(userTotalSteps({ xp: 7 }), 7);
});
