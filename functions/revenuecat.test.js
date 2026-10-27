'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const RC = require('./revenuecat');

const future = Date.now() + 30 * 24 * 3600 * 1000;
const past = Date.now() - 24 * 3600 * 1000;
const iso = (ms) => new Date(ms).toISOString();

test('compra inicial ativa o Plus pelo entitlement, sem olhar preço/SKU', () => {
  const out = RC.plusStateFromEvent({
    type: 'INITIAL_PURCHASE',
    app_user_id: 'uid1',
    product_id: 'qualquer_produto',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: future,
  });
  assert.equal(out.uid, 'uid1');
  assert.equal(out.fields.plusActive, true);
  assert.equal(out.fields.plusWillRenew, true);
  assert.equal(out.fields.plusExpiresAt, iso(future));
});

test('cancelar mantém ativo até vencer, sem renovar', () => {
  const out = RC.plusStateFromEvent({
    type: 'CANCELLATION',
    app_user_id: 'uid1',
    product_id: 'p',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: future,
  });
  assert.equal(out.fields.plusActive, true);
  assert.equal(out.fields.plusWillRenew, false);

  const expired = RC.plusStateFromEvent({
    type: 'CANCELLATION',
    app_user_id: 'uid1',
    product_id: 'p',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: past,
  });
  assert.equal(expired.fields.plusActive, false);
});

test('expiração desliga', () => {
  const out = RC.plusStateFromEvent({
    type: 'EXPIRATION',
    app_user_id: 'uid1',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: past,
  });
  assert.equal(out.fields.plusActive, false);
});

test('evento de outro entitlement é ignorado', () => {
  assert.equal(
    RC.plusStateFromEvent({
      type: 'INITIAL_PURCHASE',
      app_user_id: 'uid1',
      entitlement_ids: ['outra_coisa'],
    }),
    null,
  );
});

test('apoio avulso dá só o selo; outro consumível, nada', () => {
  const tip = RC.plusStateFromEvent({
    type: 'NON_RENEWING_PURCHASE',
    app_user_id: 'uid1',
    product_id: 'apoio_15',
  });
  assert.deepEqual(tip.fields, { supporter: true });
  assert.equal(
    RC.plusStateFromEvent({
      type: 'NON_RENEWING_PURCHASE',
      app_user_id: 'uid1',
      product_id: 'moedas_100',
    }),
    null,
  );
});

test('usuário anônimo ou evento vazio não grava', () => {
  assert.equal(RC.plusStateFromEvent(null), null);
  assert.equal(
    RC.plusStateFromEvent({
      type: 'RENEWAL',
      app_user_id: '$RCAnonymousID:abc',
    }),
    null,
  );
});

test('autorização exige o segredo, com ou sem prefixo Bearer', () => {
  assert.equal(RC.authorized('Bearer segredo', 'segredo'), true);
  assert.equal(RC.authorized('Bearer segredo', 'Bearer segredo'), true);
  assert.equal(RC.authorized('segredo', 'segredo'), true);
  assert.equal(RC.authorized('segredo', 'Bearer segredo'), true);
  assert.equal(RC.authorized('Bearer outro', 'segredo'), false);
  assert.equal(RC.authorized('Bearer segredo', ''), false);
  assert.equal(RC.authorized(undefined, 'segredo'), false);
});

test('transferência liga o Plus na conta de destino', () => {
  const out = RC.plusStateFromEvent({
    type: 'TRANSFER',
    app_user_id: '$RCAnonymousID:abc',
    transferred_to: ['uid-novo'],
    product_id: 'plus_annual',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: future,
  });
  // app_user_id anônimo seria ignorado; o destino é quem recebe.
  assert.equal(out.uid, 'uid-novo');
  assert.equal(out.fields.plusActive, true);
});

test('transferência desliga a conta de origem', () => {
  const out = RC.plusStateFromEvent({
    type: 'TRANSFER',
    app_user_id: 'uid-velho',
    transferred_from: ['uid-velho'],
    transferred_to: ['uid-novo'],
    product_id: 'plus_annual',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: future,
  });
  assert.equal(out.uid, 'uid-novo');
  assert.deepEqual(out.also, [
    { uid: 'uid-velho', fields: { plusActive: false, plusWillRenew: false } },
  ]);
});

test('Pioneiro: primeira compra ocupa vaga; renovar, cancelar e sandbox não', () => {
  const buy = RC.pioneerSlotFromEvent({
    type: 'INITIAL_PURCHASE',
    app_user_id: 'uid1',
    product_id: 'plus_founder_annual',
    environment: 'PRODUCTION',
  });
  assert.deepEqual(buy, { uid: 'uid1', from: [] });

  assert.equal(
    RC.pioneerSlotFromEvent({
      type: 'RENEWAL',
      app_user_id: 'uid1',
      product_id: 'plus_founder_annual',
      environment: 'PRODUCTION',
    }),
    null,
  );
  assert.equal(
    RC.pioneerSlotFromEvent({
      type: 'CANCELLATION',
      app_user_id: 'uid1',
      product_id: 'plus_founder_annual',
      environment: 'PRODUCTION',
    }),
    null,
  );
  assert.equal(
    RC.pioneerSlotFromEvent({
      type: 'INITIAL_PURCHASE',
      app_user_id: 'uid1',
      product_id: 'plus_founder_annual',
      environment: 'SANDBOX',
    }),
    null,
  );
  assert.equal(
    RC.pioneerSlotFromEvent({
      type: 'INITIAL_PURCHASE',
      app_user_id: 'uid1',
      product_id: 'plus_annual',
      environment: 'PRODUCTION',
    }),
    null,
  );
});

test('Pioneiro: começo do teste não ocupa vaga; a conversão ocupa', () => {
  const base = {
    app_user_id: 'uid1',
    product_id: 'plus_founder_annual',
    environment: 'PRODUCTION',
  };
  assert.equal(
    RC.pioneerSlotFromEvent({ ...base, type: 'INITIAL_PURCHASE', period_type: 'TRIAL' }),
    null,
  );
  assert.deepEqual(
    RC.pioneerSlotFromEvent({ ...base, type: 'INITIAL_PURCHASE', period_type: 'NORMAL' }),
    { uid: 'uid1', from: [] },
  );
  assert.deepEqual(
    RC.pioneerSlotFromEvent({ ...base, type: 'RENEWAL', is_trial_conversion: true }),
    { uid: 'uid1', from: [] },
  );
  assert.equal(
    RC.pioneerSlotFromEvent({ ...base, type: 'RENEWAL', is_trial_conversion: false }),
    null,
  );
  assert.equal(
    RC.pioneerSlotFromEvent({
      ...base,
      type: 'PRODUCT_CHANGE',
      product_id: 'plus_annual',
      new_product_id: 'plus_founder_annual',
      period_type: 'TRIAL',
    }),
    null,
  );

  const moved = RC.pioneerSlotFromEvent({
    ...base,
    type: 'TRANSFER',
    period_type: 'TRIAL',
    transferred_from: ['uid-velho'],
    transferred_to: ['uid-novo'],
  });
  assert.deepEqual(moved, { uid: 'uid-novo', from: ['uid-velho'], inheritOnly: true });
  assert.deepEqual(
    RC.pioneerClaimDecision({ alreadyCounted: false, sourceCounted: false, count: 4, inheritOnly: true }),
    { action: 'skip' },
  );
  assert.deepEqual(
    RC.pioneerClaimDecision({ alreadyCounted: false, sourceCounted: true, count: 4, inheritOnly: true }),
    { action: 'inherit' },
  );
});

test('Pioneiro: troca para o produto e transferência anônima contam uma vez', () => {
  const changed = RC.pioneerSlotFromEvent({
    type: 'PRODUCT_CHANGE',
    app_user_id: 'uid1',
    product_id: 'plus_annual',
    new_product_id: 'plus_founder_annual:annual',
    environment: 'PRODUCTION',
  });
  assert.equal(changed.uid, 'uid1');
  assert.equal(
    RC.pioneerSlotFromEvent({
      type: 'PRODUCT_CHANGE',
      app_user_id: 'uid1',
      product_id: 'plus_founder_annual',
      new_product_id: 'plus_monthly',
      environment: 'PRODUCTION',
    }),
    null,
  );

  assert.equal(
    RC.pioneerSlotFromEvent({
      type: 'INITIAL_PURCHASE',
      app_user_id: '$RCAnonymousID:abc',
      product_id: 'plus_founder_annual',
      environment: 'PRODUCTION',
    }),
    null,
  );
  const moved = RC.pioneerSlotFromEvent({
    type: 'TRANSFER',
    app_user_id: '$RCAnonymousID:abc',
    transferred_from: ['$RCAnonymousID:abc'],
    transferred_to: ['uid-novo'],
    product_id: 'plus_founder_annual',
    environment: 'PRODUCTION',
  });
  assert.deepEqual(moved, { uid: 'uid-novo', from: [] });
});

test('vaga de Pioneiro não soma duas vezes nem na transferência de quem já contou', () => {
  assert.deepEqual(
    RC.pioneerClaimDecision({ alreadyCounted: true, sourceCounted: false, count: 4 }),
    { action: 'skip' },
  );
  assert.deepEqual(
    RC.pioneerClaimDecision({ alreadyCounted: false, sourceCounted: true, count: 4 }),
    { action: 'inherit' },
  );
  assert.deepEqual(
    RC.pioneerClaimDecision({ alreadyCounted: false, sourceCounted: false, count: 4 }),
    { action: 'increment', count: 5 },
  );
  assert.deepEqual(
    RC.pioneerClaimDecision({ alreadyCounted: false, sourceCounted: false, count: null }),
    { action: 'increment', count: 1 },
  );
});

test('problema de cobrança mantém ativo (graça da loja)', () => {
  const out = RC.plusStateFromEvent({
    type: 'BILLING_ISSUE',
    app_user_id: 'uid1',
    product_id: 'p',
    entitlement_ids: ['peregrino_plus'],
    expiration_at_ms: past,
  });
  assert.equal(out.fields.plusActive, true);
  assert.equal(out.fields.plusWillRenew, false);
});

test('pausa agendada mantém ativo até vencer, sem renovar', () => {
  const r = RC.plusStateFromEvent({
    type: 'SUBSCRIPTION_PAUSED',
    app_user_id: 'uid1',
    entitlement_ids: ['peregrino_plus'],
    product_id: 'plus_monthly',
    expiration_at_ms: future,
  });
  assert.equal(r.fields.plusActive, true);
  assert.equal(r.fields.plusWillRenew, false);
});
