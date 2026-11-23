#!/usr/bin/env node
/**
 * Perfil público (`users/{uid}`) sem dado pessoal. Qualquer peregrino
 * logado lê esse doc; o que é pessoal mora em `users/{uid}/private/data`
 * desde 2026-10-16 (BackendService.privateKeys). Builds antigos e o
 * antigo "fallback" ainda deixaram cópias no público.
 *
 *   node scripts/clean_public_user_fields.mjs            # relatório (simula)
 *   node scripts/clean_public_user_fields.mjs --apply    # copia o que falta
 *        para private/data (sem sobrescrever) e apaga do público
 *
 * Usa a sessão do Firebase CLI (mesmo auth do seed).
 */
import { createRequire } from 'module';
import { Firestore, FieldValue } from '@google-cloud/firestore';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const PROJECT_ID = process.env.PROJECT_ID || 'trilha-biblia';
const APPLY = process.argv.includes('--apply');
const MOVED = process.argv.includes('--moved');

// Mesma lista de BackendService.privateKeys (trilha_app/lib/services/backend_service.dart).
export const PRIVATE_KEYS = [
  'email', 'fcmToken', 'fcmTokenUpdatedAt', 'authProvider', 'missionReflections',
  'mistakeQuestionIds', 'mistakeAnswers', 'usedQuestionIds', 'answerCorrect',
  'answerTotal', 'trailAnswerCorrect', 'trailAnswerTotal', 'domainAnswerCorrect',
  'domainAnswerTotal', 'weekAnswerCorrect', 'weekAnswerTotal', 'bibleChapterReadOn',
  'missionCompletedOn', 'sceneHours', 'postcardsOn', 'postcardRefs', 'giftedTrails',
  'borrowedMissions', 'weeklyReviewsDone', 'memoryScores', 'bibleBookmarks',
  'bibleNotes', 'sharedVerses', 'lifeChallengesDone', 'settings', 'bibleReadingPlan',
  'companionCodes', 'activeRoomCode', 'claimedReferralRewards', 'firstOpenAtMs',
  'listEdits',
];
// Saíram do público na 1.0.50; a regra só os recusa quando a 1.0.49 sair de
// uso. Rode com --moved para limpá-los também.
export const MOVED_KEYS = ['rankedScenes', 'sceneLastDoneOn'];

async function getDb() {
  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    throw new Error('Firebase CLI não logado. Rode: firebase login --reauth');
  }
  process.env.GOOGLE_APPLICATION_CREDENTIALS = await getCredentialPathAsync(account);
  return new Firestore({ projectId: PROJECT_ID });
}

async function main() {
  const db = await getDb();
  const snap = await db.collection('users').get();
  const versions = new Map();
  const recentVersions = new Map();
  const since = new Date(Date.now() - 30 * 86_400_000).toISOString().slice(0, 10);
  const dirty = [];
  const keyCount = new Map();
  for (const doc of snap.docs) {
    const d = doc.data();
    const v = d.appVersion || '?';
    versions.set(v, (versions.get(v) || 0) + 1);
    if ((d.lastSeenDate || '') >= since) recentVersions.set(v, (recentVersions.get(v) || 0) + 1);
    const leaked = [...PRIVATE_KEYS, ...(MOVED ? MOVED_KEYS : [])].filter((k) => k in d);
    if (leaked.length) {
      dirty.push({ ref: doc.ref, leaked, data: d });
      for (const k of leaked) keyCount.set(k, (keyCount.get(k) || 0) + 1);
    }
  }
  const sortV = (m) => [...m.entries()].sort((a, b) => b[1] - a[1]).map(([k, n]) => `${k}: ${n}`).join(' · ');
  console.log(`users: ${snap.size}`);
  console.log(`versões (todas): ${sortV(versions)}`);
  console.log(`versões (vistos desde ${since}): ${sortV(recentVersions)}`);
  console.log(`perfis com dado pessoal no público: ${dirty.length}`);
  console.log(`campos: ${sortV(keyCount)}`);
  if (!APPLY) {
    console.log('Simulação: nada gravado. Rode com --apply para limpar.');
    return;
  }
  let done = 0;
  for (const { ref, leaked, data } of dirty) {
    const privRef = ref.collection('private').doc('data');
    await db.runTransaction(async (tx) => {
      const priv = (await tx.get(privRef)).data() || {};
      const copy = {};
      for (const k of leaked) if (!(k in priv)) copy[k] = data[k];
      if (Object.keys(copy).length) tx.set(privRef, copy, { merge: true });
      tx.update(ref, Object.fromEntries(leaked.map((k) => [k, FieldValue.delete()])));
    });
    done++;
  }
  console.log(`Limpos: ${done} perfil(is).`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
