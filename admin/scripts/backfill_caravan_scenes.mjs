#!/usr/bin/env node
/**
 * Etapa do mês da Caravana: conta as cenas de cada pessoa no mês a partir de
 * users/{uid}/private/data.missionCompletedOn e grava
 * caravanScenes/{mês}/walkers/{uid} = { scenes } — o mesmo que a função
 * onProgressScenes faz a cada progresso salvo. Serve para preencher o que
 * já existia antes da função.
 *
 *   node scripts/backfill_caravan_scenes.mjs                 # dry-run, mês atual e anterior
 *   node scripts/backfill_caravan_scenes.mjs --months 2026-11,2026-10 --apply
 *
 * Usa a sessão do Firebase CLI.
 */
import { createRequire } from 'module';
import { Firestore, FieldValue } from '@google-cloud/firestore';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const PROJECT_ID = process.env.PROJECT_ID || 'trilha-biblia';
const APPLY = process.argv.includes('--apply');

function argValue(name) {
  const i = process.argv.indexOf(name);
  return i >= 0 ? process.argv[i + 1] : null;
}

function monthKey(d) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
}

function defaultMonths() {
  const now = new Date();
  return [monthKey(now), monthKey(new Date(now.getFullYear(), now.getMonth() - 1, 1))];
}

async function db() {
  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    throw new Error('Sem sessão do Firebase CLI: rode `firebase login`.');
  }
  process.env.GOOGLE_APPLICATION_CREDENTIALS = await getCredentialPathAsync(account);
  return new Firestore({ projectId: PROJECT_ID });
}

const months = (argValue('--months') || '').split(',').map((s) => s.trim()).filter(Boolean);
const targets = months.length ? months : defaultMonths();

const fs = await db();
const totals = Object.fromEntries(targets.map((m) => [m, { walkers: 0, scenes: 0 }]));
const writes = [];
const users = await fs.collection('users').listDocuments();
for (const user of users) {
  const snap = await user.collection('private').doc('data').get();
  const completedOn = snap.exists ? snap.get('missionCompletedOn') : null;
  if (!completedOn || typeof completedOn !== 'object') continue;
  const counts = {};
  for (const day of Object.values(completedOn)) {
    if (typeof day !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(day)) continue;
    counts[day.slice(0, 7)] = (counts[day.slice(0, 7)] || 0) + 1;
  }
  for (const m of targets) {
    const scenes = counts[m] || 0;
    if (!scenes) continue;
    totals[m].walkers += 1;
    totals[m].scenes += scenes;
    writes.push({ ref: fs.doc(`caravanScenes/${m}/walkers/${user.id}`), scenes });
  }
}

console.log(`Pessoas lidas: ${users.length}`);
for (const m of targets) {
  console.log(`${m}: ${totals[m].scenes} cenas de ${totals[m].walkers} pessoas`);
}
if (!APPLY) {
  console.log('Dry-run: nada gravado. Use --apply para gravar.');
  process.exit(0);
}
for (const w of writes) {
  await w.ref.set({ scenes: w.scenes, updatedAt: FieldValue.serverTimestamp() });
}
console.log(`Gravadas ${writes.length} linhas.`);
