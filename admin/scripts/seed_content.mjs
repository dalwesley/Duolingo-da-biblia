/**
 * Seed Firestore from local JSON assets.
 * Usage (from admin/):
 *   npm run seed
 *
 * Requires admin/.env with Firebase web config.
 * For first run with VITE_ADMIN_SKIP_AUTH, enable Anonymous Auth
 * OR set GOOGLE_APPLICATION_CREDENTIALS to a service account.
 *
 * Prefer the painel "Importar" when already logged in as admin.
 */
import { readFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { initializeApp } from 'firebase/app';
import { getAuth, signInAnonymously } from 'firebase/auth';
import {
  getFirestore,
  doc,
  setDoc,
  writeBatch,
  Timestamp,
} from 'firebase/firestore';

const __dirname = dirname(fileURLToPath(import.meta.url));
const adminRoot = join(__dirname, '..');
const assetsRoot = join(adminRoot, '..', 'trilha_app', 'assets', 'data');

function loadEnv() {
  const envPath = join(adminRoot, '.env');
  if (!existsSync(envPath)) throw new Error('Missing admin/.env');
  const env = {};
  for (const line of readFileSync(envPath, 'utf8').split('\n')) {
    const m = line.match(/^([^#=]+)=(.*)$/);
    if (m) env[m[1].trim()] = m[2].trim();
  }
  return env;
}

async function batchWrite(db, colId, items, idKey) {
  const chunk = 400;
  for (let i = 0; i < items.length; i += chunk) {
    const batch = writeBatch(db);
    for (const item of items.slice(i, i + chunk)) {
      const id = String(item[idKey]);
      const { id: _d, ...data } = item;
      batch.set(doc(db, colId, id), { ...data, updatedAt: Timestamp.now() }, { merge: true });
    }
    await batch.commit();
    console.log(`  … ${Math.min(i + chunk, items.length)}/${items.length}`);
  }
}

async function main() {
  const env = loadEnv();
  const app = initializeApp({
    apiKey: env.VITE_FIREBASE_API_KEY,
    authDomain: env.VITE_FIREBASE_AUTH_DOMAIN,
    projectId: env.VITE_FIREBASE_PROJECT_ID,
    storageBucket: env.VITE_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: env.VITE_FIREBASE_MESSAGING_SENDER_ID,
    appId: env.VITE_FIREBASE_APP_ID,
  });
  const auth = getAuth(app);
  const db = getFirestore(app);

  console.log('Auth anônimo…');
  await signInAnonymously(auth);

  const trails = JSON.parse(readFileSync(join(assetsRoot, 'trails.json'), 'utf8'));
  console.log(`Trilhas: ${trails.length}`);
  await batchWrite(
    db,
    'content_trails',
    trails.map((t, i) => ({ ...t, id: t.slug, slug: t.slug, order: t.order ?? i + 1, isActive: true })),
    'slug',
  );

  const bank = JSON.parse(readFileSync(join(assetsRoot, 'genesis_questions.json'), 'utf8'));
  console.log(`Dificuldades: ${bank.difficulties.length}`);
  await batchWrite(
    db,
    'content_difficulties',
    bank.difficulties.map((d, i) => ({ ...d, id: d.id, order: i + 1 })),
    'id',
  );
  console.log(`Perguntas: ${bank.questions.length}`);
  await batchWrite(
    db,
    'content_bank_questions',
    bank.questions.map((q, i) => ({ ...q, id: q.id, order: i + 1 })),
    'id',
  );

  const studiesPath = join(assetsRoot, 'mission_studies.json');
  if (existsSync(studiesPath)) {
    const data = JSON.parse(readFileSync(studiesPath, 'utf8'));
    const docs = Object.entries(data.studies || {}).map(([slug, s]) => ({ ...s, id: slug, slug }));
    console.log(`Estudos: ${docs.length}`);
    await batchWrite(db, 'content_mission_studies', docs, 'slug');
    if (data.verses) {
      await setDoc(doc(db, 'content_meta', 'verses'), { verses: data.verses, updatedAt: Timestamp.now() }, { merge: true });
      console.log('Versículos OK');
    }
  }

  await setDoc(
    doc(db, 'content_meta', 'catalog'),
    { version: Date.now(), updatedAt: Timestamp.now(), seededAt: Timestamp.now() },
    { merge: true },
  );
  console.log('Catálogo atualizado. Seed concluído.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
