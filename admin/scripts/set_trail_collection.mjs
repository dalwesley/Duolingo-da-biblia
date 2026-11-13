/**
 * Põe (ou tira) trilhas de uma coleção à parte do Explorar. Hoje só existe
 * `panorama`: os pontos altos de cada livro e as trilhas que passam por
 * vários livros, ao lado de AT e NT. O app lê o campo `collection` da
 * trilha; app antigo ignora o campo e mantém a trilha em AT/NT.
 *
 *   node scripts/set_trail_collection.mjs --trails evangelhos,cartas-paulo           # mostra
 *   node scripts/set_trail_collection.mjs --trails evangelhos,cartas-paulo --apply   # grava
 *   node scripts/set_trail_collection.mjs --trails marcos --clear --apply            # volta para AT/NT
 *
 * Grava em `content_trails/<slug>.collection`, no trails.json do app (cópia
 * local do catálogo) e sobe `content_meta/catalog.version`.
 */
import { createRequire } from 'module';
import { readFileSync, writeFileSync } from 'fs';
import { join } from 'path';
import { APP_DATA, argValue } from './_v3_paths.mjs';

const require = createRequire(import.meta.url);
const APPLY = process.argv.includes('--apply');
const CLEAR = process.argv.includes('--clear');
const COLLECTIONS = new Set(['panorama']);

const collection = CLEAR ? null : argValue('--collection') || 'panorama';
const slugs = (argValue('--trails') || '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

async function firestore() {
  const { Firestore } = await import('@google-cloud/firestore');
  const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
  const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');
  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) throw new Error('Firebase CLI não logado. Rode: firebase login --reauth');
  process.env.GOOGLE_APPLICATION_CREDENTIALS = await getCredentialPathAsync(account);
  return { db: new Firestore({ projectId: process.env.FIREBASE_PROJECT || 'trilha-biblia' }), Firestore };
}

async function main() {
  if (!slugs.length) {
    console.error('Uso: node scripts/set_trail_collection.mjs --trails a,b [--collection panorama | --clear] [--apply]');
    process.exit(1);
  }
  if (collection && !COLLECTIONS.has(collection)) {
    throw new Error(`Coleção desconhecida: ${collection} (válidas: ${[...COLLECTIONS].join(', ')})`);
  }

  const { db, Firestore } = await firestore();
  const found = [];
  for (const slug of slugs) {
    const snap = await db.collection('content_trails').doc(slug).get();
    if (!snap.exists) {
      console.log(`! ${slug}: não existe em content_trails — pulada`);
      continue;
    }
    const cur = snap.get('collection') || '—';
    console.log(`${slug.padEnd(28)} ${String(cur).padEnd(10)} → ${collection || '— (AT/NT)'}`);
    found.push(snap.ref);
  }

  if (!APPLY) {
    console.log('\nDry run. Para gravar: acrescente --apply');
    return;
  }

  const batch = db.batch();
  for (const ref of found) {
    batch.set(
      ref,
      {
        collection: collection ?? Firestore.FieldValue.delete(),
        updatedAt: Firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }
  await batch.commit();
  console.log(`✓ ${found.length} trilha(s) em content_trails`);

  // Cópia local do catálogo (o app usa até o Firestore responder).
  const path = join(APP_DATA, 'trails.json');
  const local = JSON.parse(readFileSync(path, 'utf8'));
  let touched = 0;
  for (const t of local) {
    if (!slugs.includes(t.slug)) continue;
    if (collection) t.collection = collection;
    else delete t.collection;
    touched++;
  }
  writeFileSync(path, `${JSON.stringify(local, null, 2)}\n`);
  console.log(`✓ trails.json: ${touched} trilha(s)`);

  const version = Date.now();
  await db.collection('content_meta').doc('catalog').set(
    { version, seededAt: Firestore.FieldValue.serverTimestamp(), source: 'set_trail_collection.mjs' },
    { merge: true },
  );
  console.log(`✓ catalog.version=${version}`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
