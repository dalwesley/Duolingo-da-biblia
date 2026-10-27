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
