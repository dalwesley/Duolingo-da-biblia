#!/usr/bin/env node
/**
 * Piloto de grupos: marca líderes escolhidos (`users/{uid}.groupsPilot`).
 * Com a marca, a pessoa cria grupo mesmo com `groups_enabled` desligado;
 * o grupo nasce `pilot` e quem entra nele (código ou link) também vê Grupos.
 * As rules barram o cliente de gravar esse campo.
 *
 *   node scripts/mark_group_pilots.mjs --emails a@x.com,b@y.com          # dry-run
 *   node scripts/mark_group_pilots.mjs --emails a@x.com,b@y.com --apply
 *   node scripts/mark_group_pilots.mjs --uids uid1,uid2 --apply
 *   node scripts/mark_group_pilots.mjs --uids uid1 --off --apply          # tira
 *   node scripts/mark_group_pilots.mjs --list                             # quem está
 *
 * O e-mail é procurado em users/{uid}/private/data.email (a pessoa precisa
 * ter entrado no app ao menos uma vez). Usa a sessão do Firebase CLI.
 */
import { createRequire } from 'module';
import { Firestore, FieldValue } from '@google-cloud/firestore';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const PROJECT_ID = process.env.PROJECT_ID || 'trilha-biblia';
const APPLY = process.argv.includes('--apply');
const OFF = process.argv.includes('--off');
const LIST = process.argv.includes('--list');

function argValue(name) {
  const i = process.argv.indexOf(name);
  return i >= 0 ? process.argv[i + 1] : null;
}

function splitList(raw) {
  return (raw || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
}

async function getDb() {
  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    throw new Error('Firebase CLI não logado. Rode: firebase login --reauth');
  }
  process.env.GOOGLE_APPLICATION_CREDENTIALS = await getCredentialPathAsync(account);
  return new Firestore({ projectId: PROJECT_ID });
}

/** Busca por e-mail. Sem índice de collection group, varre as contas
 *  (base pequena) lendo users/{uid}/private/data. */
async function uidsForEmail(db, email) {
  try {
    const snap = await db
      .collectionGroup('private')
      .where('email', '==', email)
      .limit(2)
      .get();
    return snap.docs.map((d) => d.ref.parent.parent?.id).filter(Boolean);
  } catch {
    if (!scanCache) {
      scanCache = new Map();
      const refs = await db.collection('users').listDocuments();
      for (const ref of refs) {
        const priv = await ref.collection('private').doc('data').get();
        const e = String(priv.get('email') || '').toLowerCase();
        if (!e) continue;
        scanCache.set(e, [...(scanCache.get(e) || []), ref.id]);
      }
    }
    return scanCache.get(email) || [];
  }
}

let scanCache = null;

async function uidsByEmail(db, emails) {
  const found = new Map();
  for (const email of emails) {
    const uids = await uidsForEmail(db, email.toLowerCase());
    if (uids.length === 0) {
      console.warn(`  ! ${email}: nenhuma conta (a pessoa já entrou no app?)`);
    } else if (uids.length > 1) {
      console.warn(`  ! ${email}: mais de uma conta (${uids.join(', ')}) — use --uids`);
    } else {
      found.set(uids[0], email);
    }
  }
  return found;
}

async function main() {
  const db = await getDb();

  if (LIST) {
    const snap = await db.collection('users').where('groupsPilot', '==', true).get();
    console.log(`Líderes do piloto · ${snap.size}`);
    for (const d of snap.docs) {
      console.log(`  ${d.id}  ${d.get('userName') || ''}`);
    }
    return;
  }

  const targets = new Map();
  for (const uid of splitList(argValue('--uids'))) targets.set(uid, uid);
  const emails = splitList(argValue('--emails'));
  if (emails.length) {
    for (const [uid, email] of await uidsByEmail(db, emails)) targets.set(uid, email);
  }
  if (targets.size === 0) {
    console.error('Diga quem: --emails a@x,b@y ou --uids a,b (ou --list)');
    process.exit(1);
  }

  console.log(
    `Piloto de grupos · ${PROJECT_ID} · ${APPLY ? 'APPLY' : 'DRY-RUN'} · ${OFF ? 'TIRAR' : 'MARCAR'} · ${targets.size} conta(s)`,
  );
  for (const [uid, label] of targets) {
    const ref = db.doc(`users/${uid}`);
    const doc = await ref.get();
    const name = doc.exists ? doc.get('userName') || '' : '(sem doc em users)';
    console.log(`  ${uid}  ${label === uid ? '' : label}  ${name}`);
    if (!APPLY || !doc.exists) continue;
    await ref.set(
      { groupsPilot: OFF ? FieldValue.delete() : true },
      { merge: true },
    );
  }
  if (!APPLY) console.log('Dry-run. Rode de novo com --apply.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
