#!/usr/bin/env node
/**
 * Marca os testadores de antes do lançamento como Desbravadores
 * (`users/{uid}.desbravador = true`). O app lê a marca e dá a medalha
 * "Desbravador"; as rules barram o cliente de gravar esse campo.
 *
 *   node scripts/mark_desbravadores.mjs --all-current        # dry-run
 *   node scripts/mark_desbravadores.mjs --all-current --apply
 *   node scripts/mark_desbravadores.mjs --file exports/desbravadores.json --apply
 *   node scripts/mark_desbravadores.mjs --uids uid1,uid2 --apply
 *
 * --all-current: todo doc em `users` hoje (antes do lançamento, só testadores).
 * A lista de UIDs marcados é salva em exports/desbravadores.json. Se os
 * dados forem zerados antes do lançamento, rode de novo com --file depois
 * do reset (as contas de login continuam, o UID é o mesmo).
 * Usa a sessão do Firebase CLI (mesmo auth do seed).
 */
import { createRequire } from 'module';
import { mkdirSync, readFileSync, writeFileSync } from 'fs';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';
import { Firestore } from '@google-cloud/firestore';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const PROJECT_ID = process.env.PROJECT_ID || 'trilha-biblia';
const APPLY = process.argv.includes('--apply');
const ALL_CURRENT = process.argv.includes('--all-current');
const EXPORT_PATH = resolve(
  dirname(fileURLToPath(import.meta.url)),
  '../exports/desbravadores.json',
);

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

async function targetUids(db) {
  const uids = new Set();
  if (ALL_CURRENT) {
    const refs = await db.collection('users').listDocuments();
    for (const ref of refs) uids.add(ref.id);
  }
  const file = argValue('--file');
  if (file) {
    const list = JSON.parse(readFileSync(resolve(file), 'utf8'));
    for (const uid of list) uids.add(String(uid).trim());
  }
  const inline = argValue('--uids');
  if (inline) {
    for (const uid of inline.split(',')) uids.add(uid.trim());
  }
  uids.delete('');
  return [...uids].sort();
}

async function main() {
  if (!ALL_CURRENT && !argValue('--file') && !argValue('--uids')) {
    console.error('Diga quem marcar: --all-current, --file <json> ou --uids a,b');
    process.exit(1);
  }
  const db = await getDb();
  const uids = await targetUids(db);
  console.log(
    `Desbravadores · projeto ${PROJECT_ID} · ${APPLY ? 'APPLY' : 'DRY-RUN'} · ${uids.length} contas`,
  );
  for (const uid of uids) console.log(`  ${uid}`);
  if (!APPLY) {
    console.log('Nada gravado. Rode de novo com --apply.');
    return;
  }

  // Lotes de até 500 escritas (limite do Firestore).
  for (let i = 0; i < uids.length; i += 500) {
    const batch = db.batch();
    for (const uid of uids.slice(i, i + 500)) {
      batch.set(db.doc(`users/${uid}`), { desbravador: true }, { merge: true });
    }
    await batch.commit();
  }

  mkdirSync(dirname(EXPORT_PATH), { recursive: true });
  const previous = (() => {
    try {
      return JSON.parse(readFileSync(EXPORT_PATH, 'utf8'));
    } catch {
      return [];
    }
  })();
  const all = [...new Set([...previous, ...uids])].sort();
  writeFileSync(EXPORT_PATH, `${JSON.stringify(all, null, 2)}\n`);
  console.log(`Marcadas ${uids.length}. Lista em ${EXPORT_PATH} (${all.length} no total).`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
