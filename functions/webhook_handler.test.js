'use strict';

// O handler de verdade (index.js), não só as funções puras: foi aqui que o
// `functions.config()` removido no v7 derrubava toda chamada com 500.

const test = require('node:test');
const assert = require('node:assert/strict');

process.env.GCLOUD_PROJECT = process.env.GCLOUD_PROJECT || 'demo-test';
const { revenueCatWebhook } = require('./index');

function call({ method = 'POST', auth, body } = {}) {
  return new Promise((resolve) => {
    const res = {
      statusCode: 200,
      set() {
        return res;
      },
      status(code) {
        res.statusCode = code;
        return res;
      },
      json(payload) {
        resolve({ status: res.statusCode, body: payload });
      },
    };
    const req = {
      method,
      body,
      get: (name) => (name.toLowerCase() === 'authorization' ? auth : undefined),
      header: (name) => (name.toLowerCase() === 'authorization' ? auth : undefined),
      headers: auth ? { authorization: auth } : {},
    };
    revenueCatWebhook(req, res);
  });
}

test('sem o segredo: 503, sem quebrar', async () => {
  delete process.env.REVENUECAT_WEBHOOK_AUTH;
  const out = await call({ auth: 'Bearer x', body: { event: { type: 'TEST' } } });
  assert.equal(out.status, 503);
});

test('com o segredo: confere método e autorização', async () => {
  process.env.REVENUECAT_WEBHOOK_AUTH = 'segredo-longo';
  assert.equal((await call({ method: 'GET', auth: 'Bearer segredo-longo' })).status, 405);
  assert.equal((await call({ auth: 'Bearer outro', body: {} })).status, 401);
  const ok = await call({
    auth: 'Bearer segredo-longo',
    body: { event: { type: 'TEST', app_user_id: 'uid1' } },
  });
  assert.equal(ok.status, 200);
  assert.equal(ok.body.ignored, true);
  delete process.env.REVENUECAT_WEBHOOK_AUTH;
});

// ---- Gravação (revenuecat.applyEvent) com um Firestore de mentira --------

const RC = require('./revenuecat');

function fakeDb(initial = {}) {
  const docs = new Map(Object.entries(initial));
  const snap = (path) => {
    const data = docs.get(path);
    return {
      exists: data !== undefined,
      data: () => data,
      get: (field) => (data ? data[field] : undefined),
    };
  };
  const write = (path, data, opts) => {
    const before = opts && opts.merge ? docs.get(path) || {} : {};
    docs.set(path, { ...before, ...data });
  };
  const db = {
    docs,
    doc: (path) => ({ path }),
    runTransaction: async (fn) => {
      const pending = [];
      const out = await fn({
        get: async (ref) => snap(ref.path),
        set: (ref, data, opts) => pending.push([ref.path, data, opts]),
      });
      for (const [path, data, opts] of pending) write(path, data, opts);
      return out;
    },
  };
  return db;
}

const T0 = 1_700_000_000_000;
const later = Date.now() + 30 * 24 * 3600 * 1000;

test('apoio avulso não carimba a marca: EXPIRATION reenviada ainda vale', async () => {
  const db = fakeDb({ 'users/u1': { plusActive: true } });
  await RC.applyEvent(db, {
    type: 'NON_RENEWING_PURCHASE',
    app_user_id: 'u1',
    product_id: 'apoio_15',
    event_timestamp_ms: T0 + 2000,
  });
  assert.equal(db.docs.get('users/u1/server/revenuecat'), undefined);
  const out = await RC.applyEvent(db, {
    type: 'EXPIRATION',
    app_user_id: 'u1',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: T0,
    event_timestamp_ms: T0 + 1000,
  });
  assert.equal(out.skipped, null);
  assert.equal(db.docs.get('users/u1').plusActive, false);
  assert.equal(db.docs.get('users/u1').supporter, true);
});

test('evento de assinatura mais velho que o último aplicado é ignorado', async () => {
  const db = fakeDb({
    'users/u1': { plusActive: true },
    'users/u1/server/revenuecat': { lastEventAtMs: T0 + 5000 },
  });
  const out = await RC.applyEvent(db, {
    type: 'EXPIRATION',
    app_user_id: 'u1',
    entitlement_ids: ['peregrino_plus'],
    event_timestamp_ms: T0 + 1000,
  });
  assert.equal(out.skipped, 'stale');
  assert.equal(db.docs.get('users/u1').plusActive, true);
});

test('TRANSFER carimba a origem: evento mais velho não a religa', async () => {
  const db = fakeDb({
    'users/velho': { plusActive: true },
    'users/novo': {},
  });
  await RC.applyEvent(db, {
    type: 'TRANSFER',
    transferred_from: ['velho'],
    transferred_to: ['novo'],
    product_id: 'plus_annual',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: later,
    event_timestamp_ms: T0 + 5000,
  });
  assert.equal(db.docs.get('users/velho').plusActive, false);
  assert.equal(db.docs.get('users/novo').plusActive, true);
  assert.equal(db.docs.get('users/velho/server/revenuecat').lastEventAtMs, T0 + 5000);

  const out = await RC.applyEvent(db, {
    type: 'RENEWAL',
    app_user_id: 'velho',
    product_id: 'plus_annual',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: later,
    event_timestamp_ms: T0 + 1000,
  });
  assert.equal(out.skipped, 'stale');
  assert.equal(db.docs.get('users/velho').plusActive, false);
});

test('TRANSFER vencido desliga a origem sem ligar o destino', async () => {
  const db = fakeDb({ 'users/velho': { plusActive: true } });
  await RC.applyEvent(db, {
    type: 'TRANSFER',
    transferred_from: ['velho'],
    transferred_to: ['novo'],
    product_id: 'plus_annual',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: T0,
    event_timestamp_ms: T0 + 5000,
  });
  assert.equal(db.docs.get('users/velho').plusActive, false);
  assert.equal(db.docs.get('users/novo'), undefined);
});

test('conta excluída (lápide) não renasce com evento atrasado', async () => {
  const db = fakeDb({ 'deletedAccounts/u1': { deletedAt: 1 } });
  await RC.applyEvent(db, {
    type: 'RENEWAL',
    app_user_id: 'u1',
    product_id: 'plus_founder_annual',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: later,
    event_timestamp_ms: T0,
    is_trial_conversion: true,
  });
  assert.equal(db.docs.get('users/u1'), undefined);
  assert.equal(db.docs.get('users/u1/server/revenuecat'), undefined);
  assert.equal(db.docs.get('stats/pioneer'), undefined);
});

test('compra de conta nova (doc ainda não gravado) cria o Plus', async () => {
  const db = fakeDb();
  await RC.applyEvent(db, {
    type: 'INITIAL_PURCHASE',
    app_user_id: 'u1',
    product_id: 'plus_annual',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: later,
    event_timestamp_ms: T0,
  });
  assert.equal(db.docs.get('users/u1').plusActive, true);
});

test('origem do TRANSFER sem doc não vira doc-zumbi', async () => {
  const db = fakeDb();
  await RC.applyEvent(db, {
    type: 'TRANSFER',
    transferred_from: ['sumiu'],
    transferred_to: ['novo'],
    product_id: 'plus_annual',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: later,
    event_timestamp_ms: T0,
  });
  assert.equal(db.docs.get('users/sumiu'), undefined);
  assert.equal(db.docs.get('users/sumiu/server/revenuecat'), undefined);
});
