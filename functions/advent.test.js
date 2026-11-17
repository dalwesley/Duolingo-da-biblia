'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const A = require('./advent');

const CFG = A.mergeConfig('advento-2026', null);
const MIN = 60 * 1000;

// ---- Firestore falso (get/set merge, increment, transação, batch, coleção) ----

function fakeDb(seed = {}) {
  const store = new Map(Object.entries(seed).map(([k, v]) => [k, { ...v }]));
  const resolve = (prev, value) => {
    const name = value && value.constructor && value.constructor.name;
    if (name === 'NumericIncrementTransform') return (typeof prev === 'number' ? prev : 0) + value.operand;
    if (name === 'ServerTimestampTransform') return 'ts';
    return value;
  };
  const snap = (path) => {
    const data = store.get(path);
    return {
      id: path.split('/').pop(),
      exists: data !== undefined,
      data: () => (data ? { ...data } : undefined),
      get: (f) => (data ? data[f] : undefined),
      createTime: data && data.__created ? { toMillis: () => data.__created } : undefined,
    };
  };
  const write = (path, data, opts) => {
    const prev = opts && opts.merge ? store.get(path) || {} : {};
    const next = { ...prev };
    for (const [k, v] of Object.entries(data)) next[k] = resolve(prev[k], v);
    store.set(path, next);
  };
  const doc = (path) => ({
    path,
    get: async () => snap(path),
    set: async (data, opts) => write(path, data, opts),
    delete: async () => store.delete(path),
  });
  return {
    store,
    doc,
    collection: (name) => ({
      get: async () => {
        const depth = name.split('/').length + 1;
        return {
          docs: [...store.keys()]
            .filter((k) => k.startsWith(`${name}/`) && k.split('/').length === depth)
            .map((k) => snap(k)),
        };
      },
    }),
    batch: () => {
      const ops = [];
      return {
        set: (ref, data, opts) => ops.push(() => write(ref.path, data, opts)),
        commit: async () => ops.forEach((f) => f()),
      };
    },
    runTransaction: async (fn) =>
      fn({
        get: async (ref) => snap(ref.path),
        set: (ref, data, opts) => write(ref.path, data, opts),
      }),
  };
}

const C = 'advento-2026';
const done = (uid) => ({ [`seasonWalks/${C}/proof/${uid}`]: { completedAtMs: 1, count: 26 } });

// ---- Configuração ----

test('config: padrão e sobrescrita parcial; grupo nunca abaixo de 3', () => {
  assert.equal(CFG.days, 26);
  assert.equal(CFG.deadlineMs, Date.parse('2026-12-24T23:59:59-03:00'));
  assert.equal(CFG.rosterAtMs, Date.parse('2026-11-29T23:59:59-03:00'));
  assert.deepEqual(CFG.months, { solo: 1, pair: 2, group: 3 });
  const o = A.mergeConfig(C, { months: { group: 4 }, groupMin: 2, deadlineMs: 5 });
  assert.deepEqual(o.months, { solo: 1, pair: 2, group: 4 });
  assert.equal(o.groupMin, 3);
  assert.equal(o.deadlineMs, 5);
  assert.equal(A.mergeConfig('outra', null), null);
});

// ---- Prova ----

test('dia abre no fuso mais adiantado (UTC+14)', () => {
  assert.equal(A.dayUnlockMs(CFG, 1), Date.parse('2026-11-29T00:00:00+14:00'));
  assert.equal(A.dayUnlockMs(CFG, 26), Date.parse('2026-12-24T00:00:00+14:00'));
});

test('prova: cedo, rápida, em rajada, atrasada e repetida são recusadas', () => {
  const d5 = A.dayUnlockMs(CFG, 5);
  const ok = { day: 5, startMs: d5 + 1000, doneMs: d5 + 1000 + 2 * MIN };
  assert.equal(A.proofDecision(CFG, ok), null);
  assert.equal(A.proofDecision(CFG, { ...ok, startMs: d5 - 1 }), 'early');
  assert.equal(A.proofDecision(CFG, { ...ok, doneMs: ok.startMs + 59 * 1000 }), 'fast');
  assert.equal(A.proofDecision(CFG, { ...ok, lastDoneMs: ok.doneMs - 30 * 1000 }), 'burst');
  assert.equal(A.proofDecision(CFG, { ...ok, lastDoneMs: ok.doneMs - MIN }), null);
  assert.equal(A.proofDecision(CFG, { ...ok, provenDays: [5] }), 'dup');
  // Trigger fora de ordem: prova aceita depois desta, longe → vale; perto → não.
  assert.equal(A.proofDecision(CFG, { ...ok, provenTimes: [ok.doneMs + 2 * MIN] }), null);
  assert.equal(A.proofDecision(CFG, { ...ok, provenTimes: [ok.doneMs + 20 * 1000] }), 'burst');
  // No máximo 7 provas no mesmo dia de Brasília; a 8ª espera o dia seguinte.
  const late = { day: 5, startMs: CFG.deadlineMs - 10 * MIN, doneMs: CFG.deadlineMs - 5 * MIN };
  const sameDay = Array.from({ length: 7 }, (_, i) => late.doneMs - (i + 1) * 2 * MIN);
  assert.equal(A.proofDecision(CFG, { ...late, provenTimes: sameDay.slice(0, 6) }), null);
  assert.equal(A.proofDecision(CFG, { ...late, provenTimes: sameDay }), 'cap');
  assert.equal(A.proofDecision(CFG, { ...late, provenTimes: sameDay.map((t) => t - A.DAY_MS) }), null);
  assert.equal(A.proofDecision(CFG, { ...ok, day: 27 }), 'day');
  assert.equal(A.proofDecision(CFG, { ...ok, day: 0 }), 'day');
  assert.equal(
    A.proofDecision(CFG, { ...ok, startMs: CFG.deadlineMs - 2 * MIN, doneMs: CFG.deadlineMs + 1 }),
    'late',
  );
  // Dia atrasado feito depois vale (até o prazo).
  assert.equal(
    A.proofDecision(CFG, { day: 1, startMs: CFG.deadlineMs - 5 * MIN, doneMs: CFG.deadlineMs }),
    null,
  );
});

test('prova aceita conta; recusada apaga a cena; a 26ª conclui uma vez só', async () => {
  const db = fakeDb();
  const scene = 'seasonWalks/advento-2026/scenes/a_1';
  db.store.set(scene, { uid: 'a', day: 1, state: 'done' });
  const fast = await A.onSceneDone(
    db,
    CFG,
    { uid: 'a', day: 1, startMs: A.dayUnlockMs(CFG, 1), doneMs: A.dayUnlockMs(CFG, 1) + 1000, ref: db.doc(scene) },
  );
  assert.equal(fast.reason, 'fast');
  assert.equal(db.store.has(scene), false);

  // Uma cena por dia, em cada dia liberado (ao meio-dia de Brasília).
  let last;
  let t;
  for (let day = 1; day <= 26; day++) {
    t = A.dayUnlockMs(CFG, day) + 29 * 3600 * 1000;
    last = await A.onSceneDone(db, CFG, { uid: 'a', day, startMs: t, doneMs: t + 2 * MIN });
    assert.equal(last.accepted, true, `dia ${day}`);
  }
  t += 3 * MIN;
  assert.equal(last.completed, true);
  const proof = db.store.get('seasonWalks/advento-2026/proof/a');
  assert.equal(proof.count, 26);
  assert.ok(proof.completedAtMs);
  const again = await A.onSceneDone(db, CFG, { uid: 'a', day: 3, startMs: t, doneMs: t + 2 * MIN });
  assert.equal(again.reason, 'dup');
});

// ---- Nível ----

test('nível: o mais alto vale; só quem concluiu ganha', () => {
  const set = (...u) => (x) => u.includes(x);
  const g = ['a', 'b', 'c', 'd'];
  assert.equal(A.tierFor(CFG, { uid: 'a', pairs: [], groups: [], completed: set('a') }), 'solo');
  assert.equal(A.tierFor(CFG, { uid: 'a', pairs: ['b'], groups: [], completed: set('a') }), 'solo');
  assert.equal(A.tierFor(CFG, { uid: 'a', pairs: ['b'], groups: [], completed: set('a', 'b') }), 'pair');
  assert.equal(A.tierFor(CFG, { uid: 'a', pairs: [], groups: [g], completed: set('a', 'b') }), 'solo');
  assert.equal(A.tierFor(CFG, { uid: 'a', pairs: ['z'], groups: [g], completed: set('a', 'b', 'c') }), 'group');
  assert.equal(A.tierFor(CFG, { uid: 'd', pairs: [], groups: [g], completed: set('a', 'b', 'c') }), 'none');
  assert.equal(A.tierFor(CFG, { uid: 'a', pairs: [], groups: [['a', 'b']], completed: set('a', 'b') }), 'solo');
});

test('foto do dia 1: dupla ativa, grupo com 3+, quem chegou depois não conta', () => {
  const r = A.buildRoster(CFG, {
    companies: [
      { hostId: 'a', guestId: 'b' },
      { hostId: 'c', guestId: null },
      { hostId: 'd', guestId: 'e', endedAt: 1 },
      { hostId: 'p', guestId: 'q', createdMs: CFG.rosterAtMs + 1 },
      { hostId: 'r', guestId: 's', createdMs: 1, guestJoinedMs: CFG.rosterAtMs + 1 },
    ],
    rooms: [
      { code: 'G1', members: [{ uid: 'a', joinedMs: 1 }, { uid: 'c', joinedMs: 1 }, { uid: 'f', joinedMs: 1 }] },
      {
        code: 'G2',
        members: [{ uid: 'x', joinedMs: 1 }, { uid: 'y', joinedMs: 1 }, { uid: 'z', joinedMs: CFG.rosterAtMs + 1 }],
      },
    ],
  });
  assert.deepEqual(r.users.a, { pairs: ['b'], groups: ['G1'] });
  assert.deepEqual(r.users.b, { pairs: ['a'], groups: [] });
  assert.equal(r.users.d, undefined);
  assert.equal(r.users.p, undefined);
  assert.equal(r.users.r, undefined);
  assert.deepEqual(r.groups, { G1: ['a', 'c', 'f'] });
  assert.equal(r.users.x, undefined);
});

// ---- Entrega ----

test('sozinho 1 mês; a dupla conclui e os dois sobem para 2; nunca soma', async () => {
  const db = fakeDb({
    ...done('a'),
    [`seasonWalks/${C}/roster/a`]: { pairs: ['b'], groups: [] },
    [`seasonWalks/${C}/roster/b`]: { pairs: ['a'], groups: [] },
  });
  const released = [];
  const opts = { rc: {}, release: async (_db, _rc, uid) => released.push(uid) };
  assert.deepEqual(await A.evaluate(db, CFG, 'a', opts), { tier: 'solo', delta: 1 });
  assert.equal(db.store.get('referralRewards/a').banked, 1);
  assert.equal(db.store.get('referralRewards/a').adventMonths, 1);

  db.store.set(`seasonWalks/${C}/proof/b`, { completedAtMs: 2 });
  await A.evaluateAround(db, CFG, 'b', opts);
  assert.equal(db.store.get(`seasonWalks/${C}/rewards/a`).tier, 'pair');
  assert.equal(db.store.get(`seasonWalks/${C}/rewards/a`).grantedMonths, 2);
  assert.equal(db.store.get(`seasonWalks/${C}/rewards/b`).grantedMonths, 2);
  assert.equal(db.store.get('referralRewards/a').banked, 2);
  assert.equal(db.store.get('referralRewards/b').banked, 2);
  assert.deepEqual(released, ['a', 'b', 'a']);

  // Reavaliar não paga de novo.
  assert.deepEqual(await A.evaluate(db, CFG, 'a', opts), { tier: 'pair', delta: 0 });
  assert.equal(db.store.get('referralRewards/a').banked, 2);
});

test('grupo: 3 concluem e ganham 3 meses; quem não concluiu nada', async () => {
  const members = ['a', 'b', 'c', 'd'];
  const seed = { [`seasonWalks/${C}/groups/G`]: { members } };
  for (const m of members) seed[`seasonWalks/${C}/roster/${m}`] = { pairs: [], groups: ['G'] };
  const db = fakeDb({ ...seed, ...done('a'), ...done('b') });
  await A.sweep(db, CFG, {});
  assert.equal(db.store.get(`seasonWalks/${C}/rewards/a`).months, 1);

  db.store.set(`seasonWalks/${C}/proof/c`, { completedAtMs: 3 });
  await A.evaluateAround(db, CFG, 'c', {});
  for (const m of ['a', 'b', 'c']) {
    assert.equal(db.store.get(`seasonWalks/${C}/rewards/${m}`).tier, 'group', m);
    assert.equal(db.store.get(`referralRewards/${m}`).banked, 3, m);
  }
  assert.equal(db.store.has(`seasonWalks/${C}/rewards/d`), false);
  assert.equal(db.store.has('referralRewards/d'), false);
});

test('conta excluída não recebe', async () => {
  const db = fakeDb({ ...done('a'), 'deletedAccounts/a': {} });
  assert.deepEqual(await A.evaluate(db, CFG, 'a', {}), { tier: 'solo', delta: 0 });
  assert.equal(db.store.has('referralRewards/a'), false);
});

test('foto do dia 1 só uma vez e só depois da hora', async () => {
  const db = fakeDb({
    'companies/K1': { hostId: 'a', guestId: 'b' },
    'rooms/G': { ownerId: 'a' },
    'rooms/G/members/a': { __created: 1 },
    'rooms/G/members/b': { __created: 1 },
    'rooms/G/members/c': { __created: 1 },
  });
  assert.equal(await A.takeRosterIfDue(db, CFG, CFG.rosterAtMs - 1), false);
  assert.equal(await A.takeRosterIfDue(db, CFG, CFG.rosterAtMs + 1), true);
  assert.deepEqual(db.store.get(`seasonWalks/${C}/groups/G`).members, ['a', 'b', 'c']);
  assert.deepEqual(db.store.get(`seasonWalks/${C}/roster/a`), { pairs: ['b'], groups: ['G'] });
  assert.equal(await A.takeRosterIfDue(db, CFG, CFG.rosterAtMs + 2), false);
});
