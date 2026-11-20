'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const C = require('./caravan');

test('scenesByMonth counts scenes per month and skips junk', () => {
  assert.deepEqual(
    C.scenesByMonth({
      a: '2026-11-18',
      b: '2026-11-13',
      c: '2026-10-30',
      d: 'ontem',
      e: null,
    }),
    { '2026-11': 2, '2026-10': 1 },
  );
  assert.deepEqual(C.scenesByMonth(undefined), {});
});

test('changedMonths lists only months whose count moved', () => {
  assert.deepEqual(
    C.changedMonths(
      { a: '2026-10-30', b: '2026-11-01' },
      { a: '2026-10-30', b: '2026-11-01', c: '2026-11-19' },
    ),
    ['2026-11'],
  );
  assert.deepEqual(C.changedMonths({ a: '2026-11-01' }, { a: '2026-11-01' }), []);
  assert.deepEqual(C.changedMonths(null, { a: '2026-11-01' }), ['2026-11']);
});
