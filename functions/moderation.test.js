'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const M = require('./moderation');

/** Firestore mínimo em memória: o bastante para moderation.js. */
function fakeDb(seed = {}) {
  const docs = new Map(Object.entries(seed));
  const log = [];
  const ref = (path) => ({
    path,
    id: path.split('/').pop(),
    async get() {
      const d = docs.get(path);
      return { exists: d !== undefined, ref: this, id: this.id, data: () => d, get: (k) => d?.[k] };
    },
    async set(data, opts) {
      docs.set(path, opts?.merge ? { ...(docs.get(path) || {}), ...data } : data);
    },
    async update(data) {
      docs.set(path, { ...(docs.get(path) || {}), ...data });
    },
    collection: (name) => col(`${path}/${name}`),
  });
  const col = (path) => ({
    doc: (id) => ref(`${path}/${id}`),
    async add(data) {
      if (path === 'moderation_log') log.push(data);
      return ref(`${path}/x${log.length}`);
    },
    async listDocuments() {
      return [];
    },
    where: () => ({ async get() { return { docs: [], size: 0 }; } }),
  });
  return {
    docs,
    log,
    doc: ref,
    collection: col,
    async getAll(...refs) {
      return Promise.all(refs.map((r) => r.get()));
    },
    batch: () => ({ update() {}, delete() {}, async commit() {} }),
  };
}

function fakeAuth() {
  const calls = [];
  return {
    calls,
    async updateUser(uid, patch) { calls.push(['updateUser', uid, patch]); },
    async revokeRefreshTokens(uid) { calls.push(['revoke', uid]); },
    async deleteUser(uid) { calls.push(['delete', uid]); },
    async getUser(uid) {
      return { uid, email: 'x@y.z', disabled: false, providerData: [{ providerId: 'google.com' }], metadata: {} };
    },
  };
}

const logger = { info() {}, error() {}, warn() {} };
const deps = (db, auth) => ({ db, auth, messaging: { async send() {} }, fcmTokenOf: async () => null, logger });
const admin = { uid: 'adm', email: 'a@b.c' };
const seed = { 'admin_users/adm': { role: 'admin' }, 'admin_users/ed': { role: 'editor' } };

test('só admin modera', async () => {
  const db = fakeDb(seed);
  await assert.rejects(
    M.moderate(deps(db, fakeAuth()), { uid: 'ed' }, { uid: 'u1', action: 'ban', reason: 'spam' }),
    { code: 'permission-denied' },
  );
});

test('motivo é obrigatório e não modera a si nem a equipe', async () => {
  const db = fakeDb(seed);
  const auth = fakeAuth();
  await assert.rejects(M.moderate(deps(db, auth), admin, { uid: 'u1', action: 'ban', reason: '' }), { code: 'invalid-argument' });
  await assert.rejects(M.moderate(deps(db, auth), admin, { uid: 'adm', action: 'ban', reason: 'teste' }), { code: 'failed-precondition' });
  await assert.rejects(M.moderate(deps(db, auth), admin, { uid: 'ed', action: 'ban', reason: 'teste' }), { code: 'failed-precondition' });
  assert.equal(auth.calls.length, 0);
});

test('suspender desliga o login, grava estado, histórico e fecha a denúncia', async () => {
  const db = fakeDb({ ...seed, 'user_reports/r1': { status: 'open' } });
  const auth = fakeAuth();
  await M.moderate(deps(db, auth), admin, { uid: 'u1', action: 'suspend', days: 7, reason: 'nome ofensivo', reportId: 'r1' });
  assert.deepEqual(auth.calls[0], ['updateUser', 'u1', { disabled: true }]);
  assert.deepEqual(auth.calls[1], ['revoke', 'u1']);
  assert.equal(db.docs.get('moderation/u1').state, 'suspended');
  assert.equal(db.log[0].action, 'suspend');
  assert.equal(db.log[0].by, 'adm');
  assert.equal(db.docs.get('user_reports/r1').status, 'actioned');
});

test('prazo de suspensão fora da lista é recusado', async () => {
  const db = fakeDb(seed);
  await assert.rejects(
    M.moderate(deps(db, fakeAuth()), admin, { uid: 'u1', action: 'suspend', days: 365, reason: 'x y z' }),
    { code: 'invalid-argument' },
  );
});

test('trocar nome usa nome neutro estável', async () => {
  const db = fakeDb({ ...seed, 'users/abcd123': { userName: 'Ofensivo' } });
  await M.moderate(deps(db, fakeAuth()), admin, { uid: 'abcd123', action: 'rename', reason: 'nome ofensivo' });
  assert.equal(db.docs.get('users/abcd123').userName, 'Peregrino ABCD');
  assert.equal(M.neutralName('abcd123'), 'Peregrino ABCD');
});

test('aviso sem push fica no histórico', async () => {
  const db = fakeDb(seed);
  const r = await M.moderate(deps(db, fakeAuth()), admin, { uid: 'u1', action: 'warn', message: 'Troque seu nome, por favor.', reason: 'nome' });
  assert.equal(r.details.pushed, false);
  assert.equal(db.log[0].details.message, 'Troque seu nome, por favor.');
});

test('emails devolve o e-mail do Auth e ignora uid repetido ou vazio', async () => {
  const db = fakeDb(seed);
  const auth = fakeAuth();
  auth.getUsers = async (ids) => ({
    users: ids.map(({ uid }) => ({ uid, email: uid === 'u2' ? '' : `${uid}@x.com` })),
    notFound: [],
  });
  const r = await M.moderate(deps(db, auth), admin, { action: 'emails', uids: ['u1', 'u2', 'u1', ''] });
  assert.deepEqual(r.emails, { u1: 'u1@x.com' });
  assert.equal(db.log.length, 0);
});

test('editor não lista e-mails', async () => {
  const db = fakeDb(seed);
  await assert.rejects(
    M.moderate(deps(db, fakeAuth()), { uid: 'ed' }, { action: 'emails', uids: ['u1'] }),
    { code: 'permission-denied' },
  );
});

test('info não exige motivo e devolve o Auth', async () => {
  const db = fakeDb(seed);
  const r = await M.moderate(deps(db, fakeAuth()), admin, { uid: 'u1', action: 'info' });
  assert.equal(r.auth.email, 'x@y.z');
  assert.equal(db.log.length, 0);
});

test('excluir conta não é ação de moderação', async () => {
  const db = fakeDb(seed);
  const auth = fakeAuth();
  await assert.rejects(
    M.moderate(deps(db, auth), admin, { uid: 'u1', action: 'delete', reason: 'teste' }),
    { code: 'invalid-argument' },
  );
  assert.equal(auth.calls.length, 0);
});

test('Plus manual: promocional no RevenueCat, espelho no doc e histórico', async () => {
  const db = fakeDb(seed);
  const calls = [];
  const revenueCat = {
    async grantDays(uid, days) { calls.push(['grant', uid, days]); return Date.UTC(2027, 0, 1); },
    async revokePromotional(uid) { calls.push(['revoke', uid]); },
  };
  const d = { ...deps(db, fakeAuth()), revenueCat };
  await assert.rejects(M.moderate(d, admin, { uid: 'u1', action: 'plusOn', reason: '' }), { code: 'invalid-argument' });
  await assert.rejects(M.moderate(d, admin, { uid: 'u1', action: 'plusOn', days: 5, reason: 'teste' }), { code: 'invalid-argument' });

  // Vale para a própria conta (teste no aparelho do admin).
  await M.moderate(d, admin, { uid: 'adm', action: 'plusOn', days: 30, reason: 'teste' });
  assert.deepEqual(calls[0], ['grant', 'adm', 30]);
  assert.equal(db.docs.get('users/adm').plusActive, true);
  assert.equal(db.docs.get('users/adm').plusExpiresAt, '2027-01-01T00:00:00.000Z');

  await M.moderate(d, admin, { uid: 'adm', action: 'plusOff', reason: 'fim do teste' });
  assert.deepEqual(calls[1], ['revoke', 'adm']);
  assert.equal(db.docs.get('users/adm').plusActive, false);
  assert.deepEqual(db.log.map((l) => l.action), ['plusOn', 'plusOff']);
});

test('Plus manual sem chave do RevenueCat ainda grava o espelho e avisa', async () => {
  const db = fakeDb(seed);
  const { details } = await M.moderate(deps(db, fakeAuth()), admin, { uid: 'u1', action: 'plusOn', days: 7, reason: 'teste' });
  assert.equal(details.revenueCat, false);
  assert.equal(db.docs.get('users/u1').plusActive, true);
});

test('Plus manual vencido sai do doc; o que ainda vale fica', async () => {
  const past = new Date(Date.now() - 3600_000).toISOString();
  const future = new Date(Date.now() + 86_400_000).toISOString();
  const docs = {
    'users/a': { plusManual: true, plusActive: true, plusExpiresAt: past },
    'users/b': { plusManual: true, plusActive: true, plusExpiresAt: future },
  };
  const log = [];
  const ref = (path) => ({
    path,
    async update(patch) {
      const cur = { ...docs[path] };
      for (const [k, v] of Object.entries(patch)) {
        if (v && v.constructor && v.constructor.name === 'DeleteTransform') delete cur[k];
        else if (typeof v === 'object' && v !== null && !Array.isArray(v) && String(v).includes('delete')) delete cur[k];
        else cur[k] = v;
      }
      docs[path] = cur;
    },
  });
  const db = {
    collection: (name) =>
      name === 'users'
        ? {
            where: () => ({
              async get() {
                return {
                  docs: Object.entries(docs)
                    .filter(([, d]) => d.plusManual === true)
                    .map(([p, d]) => ({ id: p.split('/')[1], ref: ref(p), get: (k) => d[k] })),
                };
              },
            }),
          }
        : { async add(x) { log.push(x); } },
  };
  const n = await M.expireManualPlus({ db, logger });
  assert.equal(n, 1);
  assert.equal(docs['users/a'].plusActive, false);
  assert.equal(docs['users/b'].plusActive, true);
  assert.equal(log[0].action, 'plusExpired');
});
