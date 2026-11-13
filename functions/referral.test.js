'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const R = require('./referral');

// ---- Firestore falso (get/set merge, increment, transação, where >) ----

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
      where: (field, op, val) => ({
        get: async () => ({
          docs: [...store.keys()]
            .filter((k) => k.startsWith(`${name}/`) && k.split('/').length === 2)
            .filter((k) => op === '>' && store.get(k)[field] > val)
            .map((k) => snap(k)),
        }),
      }),
    }),
    runTransaction: async (fn) =>
      fn({
        get: async (ref) => snap(ref.path),
        set: (ref, data, opts) => write(ref.path, data, opts),
      }),
  };
}

function fakeRc(plus = {}) {
  const grants = [];
  return {
    grants,
    hasPlus: async (uid) => Boolean(plus[uid]),
    grantMonth: async (uid, now) => {
      grants.push(uid);
      plus[uid] = true;
      return now + R.MONTH_MS;
    },
  };
}

const NOW = Date.UTC(2026, 10, 13);

// ---- Decisões puras ----

test('compra fora do teste e conversão do teste contam; teste e promo não', () => {
  const base = { app_user_id: 'b', entitlement_ids: ['peregrino_plus'], environment: 'PRODUCTION' };
  assert.equal(R.paidUidFromEvent({ ...base, type: 'INITIAL_PURCHASE', period_type: 'NORMAL' }), 'b');
  assert.equal(R.paidUidFromEvent({ ...base, type: 'INITIAL_PURCHASE', period_type: 'TRIAL' }), null);
  assert.equal(R.paidUidFromEvent({ ...base, type: 'RENEWAL', is_trial_conversion: true }), 'b');
  assert.equal(R.paidUidFromEvent({ ...base, type: 'RENEWAL' }), null);
  assert.equal(
    R.paidUidFromEvent({ ...base, type: 'INITIAL_PURCHASE', period_type: 'NORMAL', store: 'PROMOTIONAL' }),
    null,
  );
  assert.equal(
    R.paidUidFromEvent({ ...base, type: 'INITIAL_PURCHASE', environment: 'SANDBOX' }),
    null,
  );
  assert.equal(
    R.paidUidFromEvent({ ...base, type: 'INITIAL_PURCHASE', environment: 'SANDBOX' }, { allowSandbox: true }),
    'b',
  );
  assert.equal(R.paidUidFromEvent({ ...base, entitlement_ids: ['outro'], type: 'INITIAL_PURCHASE' }), null);
});

test('teto de 12 meses em 365 dias', () => {
  const recent = Array.from({ length: 12 }, (_, i) => NOW - i * 1000);
  assert.equal(R.rewardDecision({ earnedAtMs: recent, now: NOW, inviterHasPlus: false }), 'cap');
  const old = Array.from({ length: 12 }, () => NOW - 400 * 24 * 3600 * 1000);
  assert.equal(R.rewardDecision({ earnedAtMs: old, now: NOW, inviterHasPlus: false }), 'grant');
  assert.equal(R.rewardDecision({ earnedAtMs: [], now: NOW, inviterHasPlus: true }), 'bank');
});

// ---- Atribuição ----

test('primeira atribuição vale; a si mesmo e Plus pago não contam', async () => {
  const db = fakeDb({
    'users/pago': { plusActive: true, plusInTrial: false },
    'users/teste': { plusActive: true, plusInTrial: true },
  });
  assert.equal(await R.attribute(db, { inviteeUid: 'b', inviterUid: 'a', via: 'grupo', code: 'X' }), true);
  assert.equal(await R.attribute(db, { inviteeUid: 'b', inviterUid: 'c', via: 'companhia' }), false);
  assert.equal(db.store.get('users/b/server/referral').inviterUid, 'a');
  assert.equal(await R.attribute(db, { inviteeUid: 'a', inviterUid: 'a', via: 'grupo' }), false);
  assert.equal(await R.attribute(db, { inviteeUid: 'pago', inviterUid: 'a', via: 'grupo' }), false);
  assert.equal(await R.attribute(db, { inviteeUid: 'teste', inviterUid: 'a', via: 'passe' }), true);
  assert.equal(await R.attribute(db, { inviteeUid: 'z', inviterUid: 'a', via: 'outro' }), false);
});

test('conta excluída não é atribuída', async () => {
  const db = fakeDb({ 'deletedAccounts/a': {} });
  assert.equal(await R.attribute(db, { inviteeUid: 'b', inviterUid: 'a', via: 'grupo' }), false);
});

// ---- Recompensa ----

test('quem convidou sem Plus ganha o mês na hora, uma vez só', async () => {
  const db = fakeDb({
    'users/b/server/referral': { inviterUid: 'a', via: 'grupo' },
    'users/b': { name: 'Maria Souza' },
  });
  const rc = fakeRc();
  assert.equal(await R.rewardInviter(db, rc, 'b', null, NOW), 'grant');
  assert.deepEqual(rc.grants, ['a']);
  const sum = db.store.get('referralRewards/a');
  assert.equal(sum.banked, 0);
  assert.equal(sum.earnedTotal, 1);
  assert.equal(sum.promoUntilMs, NOW + R.MONTH_MS);
  assert.equal(sum.lastReward.name, 'Maria');
  // Webhook reenviado: nada muda.
  assert.equal(await R.rewardInviter(db, rc, 'b', null, NOW), null);
  assert.deepEqual(rc.grants, ['a']);
});

test('quem convidou já com Plus guarda o mês e recebe quando o Plus acabar', async () => {
  const db = fakeDb({ 'users/b/server/referral': { inviterUid: 'a', via: 'companhia' } });
  const plus = { a: true };
  const rc = fakeRc(plus);
  assert.equal(await R.rewardInviter(db, rc, 'b', null, NOW), 'bank');
  assert.equal(db.store.get('referralRewards/a').banked, 1);
  assert.equal(await R.releaseBanked(db, rc, 'a', null, NOW), false);
  plus.a = false;
  assert.equal(await R.releaseAllBanked(db, rc, null, NOW), 1);
  assert.deepEqual(rc.grants, ['a']);
  assert.equal(db.store.get('referralRewards/a').banked, 0);
});

test('com dois meses guardados, o segundo só entra depois do primeiro acabar', async () => {
  const db = fakeDb({ 'referralRewards/a': { banked: 2 } });
  const plus = {};
  const rc = fakeRc(plus);
  assert.equal(await R.releaseBanked(db, rc, 'a', null, NOW), true);
  plus.a = false; // mesmo se a API disser sem Plus, o mês dado ainda vale
  assert.equal(await R.releaseBanked(db, rc, 'a', null, NOW + 1000), false);
  assert.equal(await R.releaseBanked(db, rc, 'a', null, NOW + R.MONTH_MS + 1), true);
  assert.equal(db.store.get('referralRewards/a').banked, 0);
});

test('falha da API ao entregar devolve o mês ao saldo', async () => {
  const db = fakeDb({ 'referralRewards/a': { banked: 1 } });
  const rc = {
    hasPlus: async () => false,
    grantMonth: async () => {
      throw new Error('500');
    },
  };
  assert.equal(await R.releaseBanked(db, rc, 'a', null, NOW), false);
  assert.equal(db.store.get('referralRewards/a').banked, 1);
  assert.equal(db.store.get('referralRewards/a').promoUntilMs, null);
});

test('passou do teto: marca e não dá', async () => {
  const earned = Array.from({ length: 12 }, (_, i) => NOW - i);
  const db = fakeDb({
    'users/b/server/referral': { inviterUid: 'a', via: 'grupo' },
    'referralRewards/a': { earnedAtMs: earned, banked: 0 },
  });
  const rc = fakeRc();
  assert.equal(await R.rewardInviter(db, rc, 'b', null, NOW), 'cap');
  assert.deepEqual(rc.grants, []);
  assert.equal(db.store.get('users/b/server/referral').outcome, 'cap');
});

test('cliente REST: lê entitlement e concede com end_time_ms', async () => {
  const calls = [];
  const fetchImpl = async (url, opts = {}) => {
    calls.push({ url, opts });
    if (opts.method === 'POST') return { ok: true, json: async () => ({}) };
    return {
      ok: true,
      json: async () => ({
        subscriber: { entitlements: { peregrino_plus: { expires_date: new Date(NOW + 1000).toISOString() } } },
      }),
    };
  };
  const rc = R.revenueCatClient('sk_test', fetchImpl);
  assert.equal(await rc.hasPlus('u 1', NOW), true);
  assert.equal(await rc.hasPlus('u 1', NOW + 2000), false);
  const end = await rc.grantMonth('u1', NOW);
  assert.equal(end, NOW + R.MONTH_MS);
  const post = calls.find((c) => c.opts.method === 'POST');
  assert.match(post.url, /subscribers\/u1\/entitlements\/peregrino_plus\/promotional$/);
  assert.deepEqual(JSON.parse(post.opts.body), { end_time_ms: NOW + R.MONTH_MS });
  assert.equal(post.opts.headers.Authorization, 'Bearer sk_test');
  assert.match(calls[0].url, /subscribers\/u%201$/);
});
