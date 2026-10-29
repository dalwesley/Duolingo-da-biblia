#!/usr/bin/env node
/**
 * Liga/desliga `users/{uid}.plusActive` para testes manuais do passe de
 * trilha e do selo Peregrino+. Em produção o campo vem do webhook
 * RevenueCat; o cliente não pode gravá-lo (rules).
 *
 *   node scripts/set_plus_active.mjs --uids UID --on            # dry-run
 *   node scripts/set_plus_active.mjs --uids UID --on --apply
 *   node scripts/set_plus_active.mjs --uids UID1,UID2 --off --apply
 *   node scripts/set_plus_active.mjs --from-company EAMLJD --on --apply
 *
 * Usa a sessão do Firebase CLI (mesmo auth do seed).
 */
import { createRequire } from 'module';
import { Firestore } from '@google-cloud/firestore';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const PROJECT_ID = process.env.PROJECT_ID || 'trilha-biblia';
const APPLY = process.argv.includes('--apply');
const ON = process.argv.includes('--on');
const OFF = process.argv.includes('--off');

function argValue(name) {
  const i = process.argv.indexOf(name);
  return i >= 0 ? process.argv[i + 1] : null;
}

async function getDb() {
  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    throw new Error('Firebase CLI não logado. Rode: firebase login --reauth');
  }
  const credPath = await getCredentialPathAsync(account);
  process.env.GOOGLE_APPLICATION_CREDENTIALS = credPath;
  return new Firestore({ projectId: PROJECT_ID });
}

async function resolveUids(db) {
  const uids = new Set();
  const inline = argValue('--uids');
  if (inline) {
    for (const uid of inline.split(',')) uids.add(uid.trim());
  }
  const company = argValue('--from-company');
  if (company) {
    const snap = await db.doc(`companies/${company.trim().toUpperCase()}`).get();
    if (!snap.exists) {
      throw new Error(`companies/${company} não existe`);
    }
    const hostId = snap.data()?.hostId;
    if (typeof hostId !== 'string' || !hostId) {
      throw new Error(`companies/${company} sem hostId`);
    }
    console.log(`Companhia ${company}: hostId=${hostId} guestId=${snap.data()?.guestId ?? '—'}`);
    uids.add(hostId);
  }
  uids.delete('');
  return [...uids].sort();
}

async function main() {
  if (ON === OFF) {
    console.error('Diga --on ou --off');
    process.exit(1);
  }
  if (!argValue('--uids') && !argValue('--from-company')) {
    console.error('Diga --uids a,b ou --from-company CODE');
    process.exit(1);
  }

  const value = ON;
  const db = await getDb();
  const uids = await resolveUids(db);
  if (uids.length === 0) {
    console.error('Nenhum uid.');
    process.exit(1);
  }

  console.log(
    `plusActive=${value} · projeto ${PROJECT_ID} · ${APPLY ? 'APPLY' : 'DRY-RUN'} · ${uids.length} conta(s)`,
  );
  for (const uid of uids) {
    const snap = await db.doc(`users/${uid}`).get();
    const current = snap.exists ? snap.data()?.plusActive === true : null;
    console.log(`  ${uid}  agora=${current === null ? '(sem doc)' : current}`);
  }

  if (!APPLY) {
    console.log('Nada gravado. Rode de novo com --apply.');
    return;
  }

  for (let i = 0; i < uids.length; i += 500) {
    const batch = db.batch();
    for (const uid of uids.slice(i, i + 500)) {
      batch.set(db.doc(`users/${uid}`), { plusActive: value }, { merge: true });
    }
    await batch.commit();
  }
  console.log(`Atualizado plusActive=${value} em ${uids.length} conta(s).`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
