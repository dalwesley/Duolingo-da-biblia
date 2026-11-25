'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const F = require('./family');

const DAY = 24 * 3600 * 1000;
const future = Date.now() + 365 * DAY;

// ---- Firestore falso (get/set/update/delete, where ==/array-contains) ----

function fakeDb(seed = {}) {
  const store = new Map(Object.entries(seed).map(([k, v]) => [k, structuredClone(v)]));
  const resolve = (value) => {
    const name = value && value.constructor && value.constructor.name;
    if (name === 'ServerTimestampTransform') return 'ts';
    return value;
  };
  const snap = (path) => {
    const data = store.get(path);
    return {
      id: path.split('/').pop(),
      ref: doc(path),
      exists: data !== undefined,
      data: () => (data ? structuredClone(data) : undefined),
      get: (f) => (data ? data[f] : undefined),
    };
  };
  const write = (path, data, opts) => {
    const prev = opts && opts.merge ? store.get(path) || {} : {};
    const next = { ...prev };
    for (const [k, v] of Object.entries(data)) next[k] = resolve(v);
    store.set(path, next);
  };
  const update = (path, data) => {
    if (!store.has(path)) throw new Error(`no doc ${path}`);
    write(path, data, { merge: true });
  };
  function doc(path) {
    return {
      path,
      id: path.split('/').pop(),
      get: async () => snap(path),
      set: async (data, opts) => write(path, data, opts),
      update: async (data) => update(path, data),
      delete: async () => store.delete(path),
    };
  }
  const query = (name, filters, max) => ({
    where: (field, op, val) => query(name, [...filters, [field, op, val]], max),
    limit: (n) => query(name, filters, n),
    get: async () => {
      let keys = [...store.keys()].filter(
        (k) => k.startsWith(`${name}/`) && k.split('/').length === 2,
      );
      for (const [field, op, val] of filters) {
        keys = keys.filter((k) => {
          const v = store.get(k)[field];
          if (op === '==') return v === val;
          if (op === 'array-contains') return Array.isArray(v) && v.includes(val);
          return false;
        });
      }
      if (max != null) keys = keys.slice(0, max);
      const docs = keys.map((k) => snap(k));
      return { empty: docs.length === 0, docs };
    },
  });
  return {
    store,
    doc,
    collection: (name) => query(name, [], null),
    runTransaction: async (fn) =>
      fn({
        get: async (ref) => snap(ref.path),
        set: (ref, data, opts) => write(ref.path, data, opts),
        update: (ref, data) => update(ref.path, data),
      }),
  };
}

function fakeRc(info = {}) {
  const calls = [];
  return {
    calls,
    plusInfo: async (uid) => info[uid] || { active: false },
    grantUntil: async (uid, endMs) => {
      calls.push(['grant', uid, endMs]);
      return endMs;
    },
    revokePromotional: async (uid) => {
      calls.push(['revoke', uid]);
    },
  };
}

const log = { info() {}, warn() {}, error() {} };

const purchase = (over = {}) => ({
  type: 'INITIAL_PURCHASE',
  app_user_id: 'dono',
  product_id: 'plus_familia3_annual',
  entitlement_ids: ['peregrino_plus'],
  expiration_at_ms: future,
  environment: 'PRODUCTION',
  ...over,
});

// ---- Decisões puras ----

test('vagas por produto, com ou sem o plano base do Android', () => {
  assert.equal(F.seatsForProduct('plus_casal_annual'), 1);
  assert.equal(F.seatsForProduct('plus_familia3_annual:annual'), 2);
  assert.equal(F.seatsForProduct('plus_familia4_annual'), 3);
  assert.equal(F.seatsForProduct('plus_annual'), 0);
});

test('compra e renovação de família sincronizam; individual pausa', () => {
  const sync = F.familyActionFromEvent(purchase());
  assert.equal(sync.kind, 'sync');
  assert.equal(sync.seats, 2);
  assert.equal(F.familyActionFromEvent(purchase({ type: 'RENEWAL' })).kind, 'sync');
  const solo = F.familyActionFromEvent(purchase({ type: 'RENEWAL', product_id: 'plus_annual' }));
  assert.deepEqual(solo, { kind: 'pause', uid: 'dono', onlyIfExists: true });
  assert.equal(F.familyActionFromEvent(purchase({ type: 'EXPIRATION' })).kind, 'pause');
});

test('cancelar não pausa; reembolso pausa', () => {
  assert.equal(F.familyActionFromEvent(purchase({ type: 'CANCELLATION' })), null);
  assert.equal(
    F.familyActionFromEvent(purchase({ type: 'CANCELLATION', cancel_reason: 'CUSTOMER_SUPPORT' })).kind,
    'pause',
  );
});

test('promocional, sandbox, anônimo e TRANSFER não mexem em família', () => {
  assert.equal(F.familyActionFromEvent(purchase({ store: 'PROMOTIONAL' })), null);
  assert.equal(F.familyActionFromEvent(purchase({ environment: 'SANDBOX' })), null);
  assert.equal(F.familyActionFromEvent(purchase({ app_user_id: '$RCAnonymousID:x' })), null);
  assert.equal(F.familyActionFromEvent(purchase({ type: 'TRANSFER' })), null);
  assert.equal(F.familyActionFromEvent(purchase({ environment: 'SANDBOX' }), { allowSandbox: true }).kind, 'sync');
});

test('troca de plano: só a subida entra na hora', () => {
  const up = F.familyActionFromEvent(
    purchase({ type: 'PRODUCT_CHANGE', product_id: 'plus_casal_annual', new_product_id: 'plus_familia4_annual' }),
  );
  assert.equal(up.seats, 3);
  assert.equal(up.upgradeOnly, true);
  assert.equal(
    F.familyActionFromEvent(
      purchase({ type: 'PRODUCT_CHANGE', product_id: 'plus_familia4_annual', new_product_id: 'plus_casal_annual' }),
    ),
    null,
  );
});

test('entrar: dono, cheio, outra família, Plus pago, inativo', () => {
  const now = Date.now();
  const family = { ownerUid: 'dono', seats: 1, active: true, expiresAtMs: future, members: {} };
  assert.equal(F.joinDecision({ family, uid: 'a', now }), null);
  assert.equal(F.joinDecision({ family: null, uid: 'a', now }), 'invalid');
  assert.equal(F.joinDecision({ family, uid: 'dono', now }), 'own');
  assert.equal(F.joinDecision({ family, uid: 'a', now, paidPlus: true }), 'has_plus');
  assert.equal(F.joinDecision({ family, uid: 'a', now, otherFamilyOwner: 'outro' }), 'other_family');
  assert.equal(F.joinDecision({ family: { ...family, active: false }, uid: 'a', now }), 'inactive');
  const full = { ...family, members: { b: { joinedAtMs: 1 } } };
  assert.equal(F.joinDecision({ family: full, uid: 'a', now }), 'full');
  // Quem já é membro entra de novo sem gastar vaga.
  assert.equal(F.joinDecision({ family: full, uid: 'b', now }), null);
});

test('Plus que bloqueia: assinatura que renova e vitalício; promo e cancelada não', () => {
  assert.equal(F.paidPlusBlocks({ active: true, productId: 'plus_annual', expiresAt: 'x', willRenew: true }), true);
  assert.equal(F.paidPlusBlocks({ active: true, productId: 'plus_pioneer_lifetime', expiresAt: null }), true);
  assert.equal(F.paidPlusBlocks({ active: true, productId: 'plus_annual', expiresAt: 'x', willRenew: false }), false);
  assert.equal(F.paidPlusBlocks({ active: true, productId: 'rc_promo_peregrino_plus_custom', expiresAt: 'x' }), false);
  assert.equal(F.paidPlusBlocks({ active: false }), false);
});

test('descer de plano tira quem entrou por último', () => {
  const members = { a: { joinedAtMs: 1 }, b: { joinedAtMs: 3 }, c: { joinedAtMs: 2 } };
  assert.deepEqual(F.membersOverSeats(members, 1), ['c', 'b']);
  assert.deepEqual(F.membersOverSeats(members, 3), []);
});

test('código: 6 letras sem I, O, 0 e 1', () => {
  for (let i = 0; i < 50; i++) assert.match(F.newCode(), /^[A-HJ-NP-Z2-9]{6}$/);
  assert.equal(F.normalizeCode(' abc234 '), 'ABC234');
  assert.equal(F.normalizeCode('ABC'), '');
});

// ---- Webhook e callable com Firestore falso ----

test('compra cria a família com código; renovação estende o Plus dos membros', async () => {
  const db = fakeDb({ 'users/dono': { name: 'Ana' } });
  const rc = fakeRc();
  await F.applyFamilyEvent(db, rc, purchase(), log);
  const fam = db.store.get('families/dono');
  assert.equal(fam.ownerName, 'Ana');
  assert.equal(fam.seats, 2);
  assert.equal(fam.active, true);
  assert.match(fam.inviteCode, /^[A-Z2-9]{6}$/);
  assert.deepEqual(fam.memberIds, []);

  db.store.set('families/dono', { ...fam, members: { m1: { name: 'Bia', joinedAtMs: 1 } }, memberIds: ['m1'] });
  const later = future + 365 * DAY;
  await F.applyFamilyEvent(db, rc, purchase({ type: 'RENEWAL', expiration_at_ms: later }), log);
  assert.equal(db.store.get('families/dono').inviteCode, fam.inviteCode);
  assert.deepEqual(rc.calls.find((c) => c[0] === 'grant'), ['grant', 'm1', later + F.GRACE_MS]);
});

test('fim do plano pausa e revoga; devolve o mês de indicação que ainda valia', async () => {
  const promo = Date.now() + 10 * DAY;
  const db = fakeDb({
    'families/dono': {
      ownerUid: 'dono',
      seats: 2,
      active: true,
      expiresAtMs: future,
      inviteCode: 'ABCDEF',
      members: { m1: { joinedAtMs: 1 } },
      memberIds: ['m1'],
    },
    'referralRewards/m1': { promoUntilMs: promo },
  });
  const rc = fakeRc();
  await F.applyFamilyEvent(db, rc, purchase({ type: 'EXPIRATION' }), log);
  assert.equal(db.store.get('families/dono').active, false);
  // Membro continua na lista: se o titular voltar, o Plus volta.
  assert.deepEqual(db.store.get('families/dono').memberIds, ['m1']);
  assert.deepEqual(rc.calls, [
    ['revoke', 'm1'],
    ['grant', 'm1', promo],
  ]);
});

test('individual novo pausa só se havia família', async () => {
  const db = fakeDb();
  const out = await F.applyFamilyEvent(db, fakeRc(), purchase({ product_id: 'plus_annual' }), log);
  assert.equal(out, null);
  assert.equal(db.store.has('families/dono'), false);
});

test('entrar pelo código reserva a vaga e concede até o fim + folga', async () => {
  const db = fakeDb({
    'families/dono': {
      ownerUid: 'dono',
      seats: 1,
      active: true,
      expiresAtMs: future,
      inviteCode: 'ABCDEF',
      members: {},
      memberIds: [],
    },
    'users/m1': { name: 'Bia' },
  });
  const rc = fakeRc();
  await F.handle({ db, rc, logger: log }, 'm1', { action: 'join', code: 'abcdef' });
  const fam = db.store.get('families/dono');
  assert.deepEqual(fam.memberIds, ['m1']);
  assert.equal(fam.members.m1.name, 'Bia');
  assert.deepEqual(rc.calls[0], ['grant', 'm1', future + F.GRACE_MS]);

  await assert.rejects(
    F.handle({ db, rc, logger: log }, 'm2', { action: 'join', code: 'ABCDEF' }),
    (e) => e.reason === 'full',
  );
  await assert.rejects(
    F.handle({ db, rc, logger: log }, 'dono', { action: 'join', code: 'ABCDEF' }),
    (e) => e.reason === 'own',
  );
  await assert.rejects(
    F.handle({ db, rc, logger: log }, 'm2', { action: 'join', code: 'ZZZZZZ' }),
    (e) => e.reason === 'invalid',
  );
});

test('quem paga o próprio Plus não entra (pagaria duas vezes)', async () => {
  const db = fakeDb({
    'families/dono': { ownerUid: 'dono', seats: 3, active: true, expiresAtMs: future, inviteCode: 'ABCDEF', members: {}, memberIds: [] },
  });
  const rc = fakeRc({ m1: { active: true, productId: 'plus_annual', expiresAt: 'x', willRenew: true } });
  await assert.rejects(
    F.handle({ db, rc, logger: log }, 'm1', { action: 'join', code: 'ABCDEF' }),
    (e) => e.reason === 'has_plus',
  );
});

test('membro sai; titular tira alguém; código novo', async () => {
  const db = fakeDb({
    'families/dono': {
      ownerUid: 'dono',
      seats: 3,
      active: true,
      expiresAtMs: future,
      inviteCode: 'ABCDEF',
      members: { m1: { joinedAtMs: 1 }, m2: { joinedAtMs: 2 } },
      memberIds: ['m1', 'm2'],
    },
  });
  const rc = fakeRc();
  await F.handle({ db, rc, logger: log }, 'm1', { action: 'leave' });
  assert.deepEqual(db.store.get('families/dono').memberIds, ['m2']);
  await F.handle({ db, rc, logger: log }, 'dono', { action: 'remove', uid: 'm2' });
  assert.deepEqual(db.store.get('families/dono').memberIds, []);
  assert.deepEqual(
    rc.calls.filter((c) => c[0] === 'revoke').map((c) => c[1]),
    ['m1', 'm2'],
  );
  const { code } = await F.handle({ db, rc, logger: log }, 'dono', { action: 'rotate' });
  assert.notEqual(code, 'ABCDEF');
  assert.equal(db.store.get('families/dono').inviteCode, code);
});

test('conta excluída: membro libera a vaga; titular apaga a família', async () => {
  const db = fakeDb({
    'families/dono': {
      ownerUid: 'dono',
      seats: 3,
      active: true,
      expiresAtMs: future,
      inviteCode: 'ABCDEF',
      members: { m1: { joinedAtMs: 1 }, m2: { joinedAtMs: 2 } },
      memberIds: ['m1', 'm2'],
    },
  });
  const rc = fakeRc();
  await F.onAccountDeleted({ db, rc, logger: log }, 'm1');
  assert.deepEqual(db.store.get('families/dono').memberIds, ['m2']);
  await F.onAccountDeleted({ db, rc, logger: log }, 'dono');
  assert.equal(db.store.has('families/dono'), false);
  assert.deepEqual(rc.calls, [['revoke', 'm2']]);
});

test('membro que compra a própria família sai da família anterior', async () => {
  const db = fakeDb({
    'families/outro': {
      ownerUid: 'outro',
      seats: 2,
      active: true,
      expiresAtMs: future,
      inviteCode: 'ABCDEF',
      members: { dono: { joinedAtMs: 1 } },
      memberIds: ['dono'],
    },
  });
  const rc = fakeRc();
  await F.applyFamilyEvent(db, rc, purchase(), log);
  assert.deepEqual(db.store.get('families/outro').memberIds, []);
  assert.equal(db.store.get('families/dono').active, true);
});
