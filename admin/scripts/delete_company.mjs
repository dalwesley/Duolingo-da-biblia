#!/usr/bin/env node
/**
 * Apaga um convite/companhia aberto (`companies/{code}`) para refazer o
 * fluxo com passe de trilha. Só apaga se ainda não tiver guest.
 *
 *   node scripts/delete_company.mjs --code EAMLJD            # dry-run
 *   node scripts/delete_company.mjs --code EAMLJD --apply
 */
import { createRequire } from 'module';
import { Firestore } from '@google-cloud/firestore';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const PROJECT_ID = process.env.PROJECT_ID || 'trilha-biblia';
const APPLY = process.argv.includes('--apply');

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

async function main() {
  const raw = argValue('--code');
  if (!raw) {
    console.error('Diga --code EAMLJD');
    process.exit(1);
  }
  const code = raw.trim().toUpperCase();
  const db = await getDb();
  const ref = db.doc(`companies/${code}`);
  const snap = await ref.get();
  if (!snap.exists) {
    console.log(`companies/${code} já não existe.`);
    return;
  }
  const data = snap.data() || {};
  console.log(
    `companies/${code} · host=${data.hostId ?? '—'} · guest=${data.guestId ?? '—'} · giftCode=${data.giftCode ?? '—'} · ${APPLY ? 'APPLY' : 'DRY-RUN'}`,
  );
  if (data.guestId) {
    console.error('Tem guest — não apago companhia já formada. Saia pelo app.');
    process.exit(1);
  }
  if (!APPLY) {
    console.log('Nada apagado. Rode de novo com --apply.');
    return;
  }
  await ref.delete();
  console.log(`Apagado companies/${code}.`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
