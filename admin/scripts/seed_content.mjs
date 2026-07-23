/**
 * Seed Firestore from local JSON assets.
 * Usage (from admin/):
 *   SEED_EMAIL=voce@email.com SEED_PASSWORD='…' npm run seed
 *
 * Ou defina SEED_EMAIL / SEED_PASSWORD em admin/.env
 *
 * Rode antes: npm run prepare:content  (normaliza banks + estudos + NT)
 *
 * O uid precisa existir em admin_users/{uid} com role admin|editor
 * (rules de content_* só permitem escrita a content editors).
 *
 * Preferir o painel "Importar" quando já logado como admin.
 */
import { readFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { initializeApp } from 'firebase/app';
import {
  getAuth,
  signInAnonymously,
  signInWithEmailAndPassword,
} from 'firebase/auth';
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
  const env = { ...process.env };
  if (existsSync(envPath)) {
    for (const line of readFileSync(envPath, 'utf8').split('\n')) {
      const m = line.match(/^([^#=]+)=(.*)$/);
      if (m && env[m[1].trim()] === undefined) {
        env[m[1].trim()] = m[2].trim().replace(/^['"]|['"]$/g, '');
      }
    }
  }
  return env;
}

function readJson(name) {
  return JSON.parse(readFileSync(join(assetsRoot, name), 'utf8'));
}

function asQuestionList(data) {
  if (Array.isArray(data)) return data;
  if (data && Array.isArray(data.questions)) return data.questions;
  return [];
}

async function batchWrite(db, colId, items, idKey) {
  const chunk = 400;
  for (let i = 0; i < items.length; i += chunk) {
    const batch = writeBatch(db);
    for (const item of items.slice(i, i + chunk)) {
      const id = String(item[idKey]);
      const { id: _d, ...data } = item;
      batch.set(
        doc(db, colId, id),
        { ...data, updatedAt: Timestamp.now() },
        { merge: true },
      );
    }
    await batch.commit();
    console.log(`  … ${Math.min(i + chunk, items.length)}/${items.length}`);
  }
}

async function authenticate(auth, env) {
  const email = env.SEED_EMAIL?.trim();
  const password = env.SEED_PASSWORD;
  if (email && password) {
    console.log(`Auth e-mail (${email})…`);
    await signInWithEmailAndPassword(auth, email, password);
    return;
  }

  console.log('Auth anônimo (fallback)…');
  try {
    await signInAnonymously(auth);
  } catch (err) {
    throw new Error(
      `Auth falhou (${err.code || err.message}). ` +
        'Defina SEED_EMAIL e SEED_PASSWORD de um admin em admin/.env ' +
        '(uid deve estar em admin_users), ou use o painel Importar.',
    );
  }
}

async function main() {
  const env = loadEnv();
  if (!env.VITE_FIREBASE_API_KEY || !env.VITE_FIREBASE_PROJECT_ID) {
    throw new Error('Missing Firebase config in admin/.env');
  }

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

  await authenticate(auth, env);
  const uid = auth.currentUser?.uid;
  if (!uid) throw new Error('Sem uid após autenticação');
  console.log('Autenticado:', uid);

  await setDoc(
    doc(db, 'admin_users', uid),
    {
      email: auth.currentUser.email || env.SEED_EMAIL || '',
      role: 'admin',
      permissions: { trails: true, bank: true, studies: true },
      updatedAt: Timestamp.now(),
    },
    { merge: true },
  );
  console.log('admin_users OK');

  const trails = readJson('trails.json');
  console.log(`Trilhas: ${trails.length}`);
  await batchWrite(
    db,
    'content_trails',
    trails.map((t, i) => ({
      ...t,
      id: t.slug,
      slug: t.slug,
      order: t.order ?? i + 1,
      isActive: true,
    })),
    'slug',
  );

  const genesis = readJson('genesis_questions.json');
  const difficulties = genesis.difficulties || [];
  console.log(`Dificuldades: ${difficulties.length}`);
  if (difficulties.length) {
    await batchWrite(
      db,
      'content_difficulties',
      difficulties.map((d, i) => ({ ...d, id: d.id, order: i + 1 })),
      'id',
    );
  }

  const bankFiles = [
    'genesis_questions.json',
    'exodo_questions.json',
    'ot_questions.json',
    'nt_questions.json',
  ];
  const seen = new Set();
  const questions = [];
  for (const file of bankFiles) {
    const path = join(assetsRoot, file);
    if (!existsSync(path)) {
      console.log(`  (sem ${file})`);
      continue;
    }
    const list = asQuestionList(readJson(file));
    let added = 0;
    for (const q of list) {
      if (!q?.id || seen.has(q.id)) continue;
      seen.add(q.id);
      questions.push(q);
      added += 1;
    }
    console.log(`  ${file}: +${added}`);
  }
  console.log(`Perguntas do banco: ${questions.length}`);
  await batchWrite(
    db,
    'content_bank_questions',
    questions.map((q, i) => ({ ...q, id: q.id, order: i + 1 })),
    'id',
  );

  const studiesPath = join(assetsRoot, 'mission_studies.json');
  if (existsSync(studiesPath)) {
    const data = readJson('mission_studies.json');
    const docs = Object.entries(data.studies || {}).map(([slug, s]) => ({
      ...s,
      id: slug,
      slug,
    }));
    console.log(`Estudos: ${docs.length}`);
    await batchWrite(db, 'content_mission_studies', docs, 'slug');
    if (data.verses) {
      await setDoc(
        doc(db, 'content_meta', 'verses'),
        { verses: data.verses, updatedAt: Timestamp.now() },
        { merge: true },
      );
      console.log('Versículos OK');
    }
  }

  await setDoc(
    doc(db, 'content_meta', 'catalog'),
    {
      version: Date.now(),
      updatedAt: Timestamp.now(),
      seededAt: Timestamp.now(),
    },
    { merge: true },
  );
  // Fecha bootstrap de admin_users (create só enquanto este doc não existir).
  await setDoc(
    doc(db, 'content_meta', 'bootstrap_locked'),
    {
      locked: true,
      lockedAt: Timestamp.now(),
      note: 'Novos admin_users só via Console / admin existente',
    },
    { merge: true },
  );
  console.log('Catálogo atualizado. Seed concluído.');
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
