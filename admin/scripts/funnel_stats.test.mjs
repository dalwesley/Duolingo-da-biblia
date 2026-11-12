import { test } from 'node:test';
import assert from 'node:assert/strict';
import { computeFunnel, weekOf, daysBetween } from '../src/funnel-stats.js';

const today = '2026-11-11';
const dates = (start, offsets) => offsets.map((o) => {
  const d = new Date(Date.UTC(...start.split('-').map((n, i) => (i === 1 ? n - 1 : +n))) + o * 86400000);
  return d.toISOString().slice(0, 10);
});

test('weekOf e daysBetween', () => {
  assert.equal(weekOf('2026-11-11'), '2026-11-09'); // quarta → segunda
  assert.equal(weekOf('2026-11-09'), '2026-11-09');
  assert.equal(weekOf('2026-11-15'), '2026-11-09'); // domingo
  assert.equal(daysBetween('2026-10-31', '2026-11-01'), 1);
});

test('funil, retenção só de quem tem idade e testers fora', () => {
  const users = [
    // começou há 40 dias, voltou D1, D8 e D30, 10 cenas, pagando
    { id: 'a', firstOpenDate: '2026-10-02', firstLessonDate: '2026-10-02', playDates: dates('2026-10-02', [0, 1, 8, 30]),
      completedMissions: Array(10).fill('x'), plusActive: true, plusInTrial: false, plusSource: 'revenuecat', plusProductId: 'plus_founder_annual:anual' },
    // começou há 40 dias, só no dia 0
    { id: 'b', firstOpenDate: '2026-10-02', firstLessonDate: '2026-10-02', playDates: ['2026-10-02'], completedMissions: ['x'] },
    // começou ontem: só elegível p/ D1 (e não voltou ainda — dia 1 = hoje? não, hoje é dia 1)
    { id: 'c', firstOpenDate: '2026-11-10', firstLessonDate: '2026-11-10', playDates: ['2026-11-10', '2026-11-11'], completedMissions: ['x', 'y'], plusActive: true, plusInTrial: true },
    // conta sem cena
    { id: 'd', firstOpenDate: '2026-11-11' },
    // tester
    { id: 'e', firstOpenDate: '2026-09-01', firstLessonDate: '2026-09-01', playDates: ['2026-09-01'], desbravador: true },
  ];
  const f = computeFunnel(users, { today });
  assert.equal(f.testersHidden, 1);
  assert.deepEqual(f.steps.map((s) => s.n), [4, 3, 2, 1, 1, 1]);
  assert.deepEqual(f.retention.d1, { eligible: 3, kept: 2 });
  assert.deepEqual(f.retention.w2, { eligible: 2, kept: 1 });
  assert.deepEqual(f.retention.d30, { eligible: 2, kept: 1 });
  assert.deepEqual(f.north, { eligible: 1, kept: 1 });
  assert.equal(f.plus.pioneer, 1);
  assert.equal(f.active.dau, 1);
  assert.equal(f.cohorts[0].week, '2026-11-09');
  assert.equal(f.daily.length, 30);
  const withTesters = computeFunnel(users, { today, includeTesters: true });
  assert.equal(withTesters.steps[0].n, 5);
  const since = computeFunnel(users, { today, since: '2026-11-01' });
  assert.equal(since.steps[0].n, 2);
});
