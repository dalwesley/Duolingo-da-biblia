#!/usr/bin/env node
/**
 * Audit: compara ranking nas coleções de Caravana com users/{uid}.
 *
 *   node scripts/audit_rankings.mjs [--fix]
 *
 * Sem --fix: lista inconsistências. Com --fix: corrige (xp = valor do progresso).
 * Usa sessão do Firebase CLI (mesmo auth do seed).
 */
import { createRequire } from 'module';
import { Firestore } from '@google-cloud/firestore';
import {
  inspectOverall,
  inspectWeekly,
  inspectMonthly,
  inspectRoomMember,
  suspiciousProgress,
  userTotalSteps,
  userWeeklySteps,
  userMonthlySteps,
  mondayKey,
  monthKey,
} from './_ranking_mirror.mjs';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const PROJECT_ID = process.env.PROJECT_ID || 'trilha-biblia';
const FIX = process.argv.includes('--fix');

async function getDb() {
  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    throw new Error('Firebase CLI não logado. Rode: firebase login --reauth');
  }
  const credPath = await getCredentialPathAsync(account);
  process.env.GOOGLE_APPLICATION_CREDENTIALS = credPath;
  return new Firestore({ projectId: PROJECT_ID });
}

async function allDocs(db, path) {
  const snap = await db.collection(path).get();
  return snap.docs.map((d) => [d.id, d.data()]);
}

async function main() {
  const db = await getDb();
  console.log(`Auditoria de rankings · projeto ${PROJECT_ID} · ${FIX ? 'FIX' : 'DRY-RUN'}`);

  // 1. Carrega todos os usuários
  const usersRaw = await allDocs(db, 'users');
  const users = Object.fromEntries(usersRaw);
  console.log(`Usuários: ${usersRaw.length}`);

  const issues = [];

  // 2. Suspiciously high steps
  for (const [uid, data] of usersRaw) {
    const hit = suspiciousProgress(uid, data);
    if (hit) issues.push(hit);
  }

  // 3. overallPlayers
  for (const [uid, ranking] of await allDocs(db, 'overallPlayers')) {
    const hit = inspectOverall(uid, users[uid], ranking);
    if (hit) issues.push(hit);
  }

  // 4. Weekly league (current week)
  const week = mondayKey();
  const weeklyFlat = await allDocs(db, `leagues/${week}/players`);
  for (const [uid, ranking] of weeklyFlat) {
    const hit = inspectWeekly(uid, users[uid], ranking, week);
    if (hit) issues.push(hit);
  }

  // Tiers (0..4)
  for (let tier = 0; tier <= 4; tier++) {
    const tierDocs = await allDocs(db, `leagues/${week}/tiers/${tier}/players`);
    for (const [uid, ranking] of tierDocs) {
      const hit = inspectWeekly(uid, users[uid], ranking, week);
      if (hit) issues.push(hit);
    }
  }

  // 5. Monthly
  const month = monthKey();
  for (const [uid, ranking] of await allDocs(db, `monthlyLeagues/${month}/players`)) {
    const hit = inspectMonthly(uid, users[uid], ranking, month);
    if (hit) issues.push(hit);
  }

  // 6. Rooms (all active rooms' members)
  const rooms = await allDocs(db, 'rooms');
  for (const [code] of rooms) {
    const members = await allDocs(db, `rooms/${code}/members`);
    for (const [uid, member] of members) {
      const hit = inspectRoomMember(uid, users[uid], member, code);
      if (hit) issues.push(hit);
    }
  }

  // Report
  if (issues.length === 0) {
    console.log('\n✅ Todos os rankings espelham users/{uid} corretamente.');
    return;
  }

  console.log(`\n⚠️  ${issues.length} inconsistência(s):\n`);
  for (const issue of issues) {
    console.log(
      `  [${issue.kind}] ${issue.path} — esperado ${issue.expected}, encontrado ${issue.actual}`,
    );
  }

  if (!FIX) {
    console.log('\nRode com --fix para corrigir automaticamente.');
    return;
  }

  // Fix: reescreve os rankings com o valor correto de users/{uid}
  let fixed = 0;
  const batch = db.batch();
  for (const issue of issues) {
    if (issue.kind === 'suspicious-steps') continue; // não auto-corrige
    const ref = db.doc(issue.path);
    batch.update(ref, { xp: issue.expected });
    fixed++;
    if (fixed % 400 === 0) {
      await batch.commit();
      console.log(`  …committed ${fixed}`);
    }
  }
  if (fixed % 400 !== 0) await batch.commit();
  console.log(`\n✅ ${fixed} doc(s) corrigido(s).`);

  const suspicious = issues.filter((i) => i.kind === 'suspicious-steps');
  if (suspicious.length > 0) {
    console.log(`\n🔍 ${suspicious.length} perfil(is) com progresso suspeito (revisar manualmente):`);
    for (const s of suspicious) {
      console.log(`  users/${s.uid} — ${s.actual} passos (teto heurístico: ${s.expected})`);
    }
  }
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
