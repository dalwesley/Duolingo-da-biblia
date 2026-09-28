'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const L = require('./league');

const field = (xps, tier = 1) =>
  xps.map((xp, i) => ({ uid: `u${i + 1}`, xp, tier }));

test('zonas proporcionais iguais ao app', () => {
  assert.deepEqual(
    [20, 10, 5, 4, 2].map(L.promoteCountFor),
    [5, 3, 1, 1, 1],
  );
  assert.deepEqual(
    [20, 10, 5, 4, 2].map(L.demoteCountFor),
    [3, 2, 1, 0, 0],
  );
});

test('sala de 20: 5 sobem, 3 descem, meio fica', () => {
  const xps = Array.from({ length: 20 }, (_, i) => 200 - i * 10);
  const out = L.settleField(field(xps));
  const count = (o) => out.filter((r) => r.outcome === o).length;
  assert.equal(count('promoted'), 5);
  assert.equal(count('demoted'), 3);
  assert.equal(count('stayed'), 12);
  assert.equal(out.find((r) => r.uid === 'u6').outcome, 'stayed');
  assert.equal(out.find((r) => r.uid === 'u20').tier, 0);
});

test('quem não somou passos não entra no campo', () => {
  const out = L.settleField(field([50, 0, 0, 30]));
  assert.equal(out.length, 2);
  assert.equal(out[0].fieldSize, 2);
});

test('sozinho na sala: sem resultado', () => {
  const out = L.settleField(field([80]));
  assert.equal(out[0].outcome, 'none');
  assert.equal(out[0].tier, 1);
});

test('empate divide a melhor posição', () => {
  const out = L.settleField(field([90, 90, 10, 10, 10]));
  assert.equal(out.find((r) => r.uid === 'u2').rank, 1);
  // 5 no campo: 1 desce, mas o último está empatado em 3º — ninguém cai.
  assert.equal(out.filter((r) => r.outcome === 'demoted').length, 0);
});

test('Estrela não sobe, Semente não desce', () => {
  const top = L.settleField(field([90, 10], 4));
  assert.equal(top[0].outcome, 'stayed');
  const low = L.settleField(field([90, 80, 70, 60, 5], 0));
  assert.equal(low[4].outcome, 'stayed');
});

test('ausência: desce 1× após 2 semanas sem jogar', () => {
  const ctx = { closedWeek: '2026-09-21', cutoff: '2026-09-14' };
  const user = { leagueTier: 2, lastPlayedDate: '2026-09-10' };
  const r = L.inactiveResult(user, ctx);
  assert.equal(r.tier, 1);
  assert.equal(r.reason, 'inactive');
  // Mesma ausência na semana seguinte: não desce de novo.
  const again = L.inactiveResult(
    { ...user, leagueResult: r },
    { closedWeek: '2026-09-28', cutoff: '2026-09-21' },
  );
  assert.equal(again, null);
});

test('ausência: jogou na semana anterior não desce', () => {
  const r = L.inactiveResult(
    { leagueTier: 2, lastPlayedDate: '2026-09-16' },
    { closedWeek: '2026-09-21', cutoff: '2026-09-14' },
  );
  assert.equal(r, null);
});

test('ausência parte do resultado ainda não aplicado no app', () => {
  const user = {
    leagueTier: 1,
    leagueProcessedWeek: '2026-09-14',
    leagueResult: { week: '2026-09-14', tier: 2, outcome: 'promoted' },
    lastPlayedDate: '2026-09-18',
  };
  assert.equal(L.baseTierForInactive(user), 2);
});

test('datas: segunda da semana', () => {
  assert.equal(L.mondayOf('2026-09-28'), '2026-09-28');
  assert.equal(L.mondayOf('2026-10-04'), '2026-09-28');
  assert.equal(L.addDays('2026-09-28', -7), '2026-09-21');
});
