/**
 * Seed Firestore from local JSON assets.
 * Usage (from admin/):
 *   SEED_EMAIL=voce@email.com SEED_PASSWORD='…' npm run seed
 *
 * Ou defina SEED_EMAIL / SEED_PASSWORD em admin/.env
 *
 * Spark (free) = ~20k writes/dia (reset ~00:00 Pacific / ~04:00 BRT).
 * Full seed (~6.5k Qs + trails + studies) ≈ 7–8k writes — 2–3 seeds/dia
 * esgotam a cota. Se RESOURCE_EXHAUSTED: espere o reset ou use Blaze.
 *
 * Opções:
 *   SEED_ONLY=bank          — só content_bank_questions
 *   SEED_ONLY=sermao        — só banco do Sermão (~465 writes)
 *   SEED_ONLY=trails        — só trilhas
 *   SEED_BANKS=sermao,genesis — subset de arquivos do banco
 *   SEED_BANKS=ot            — AT (ot_questions.json); remove órfãos dessas trilhas
 *   SEED_CHUNK=80           — docs por batch (default 80; máx 400)
 *   SEED_PAUSE_MS=400       — pausa entre batches
 *
 * Rode antes: npm run prepare:content
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
  collection,
  doc,
  getDocs,
  query,
  setDoc,
  where,
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

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function isQuotaError(err) {
  const code = err?.code || err?.message || '';
  return (
    String(code).includes('resource-exhausted') ||
    String(code).includes('RESOURCE_EXHAUSTED') ||
    String(err?.message || '').includes('Quota exceeded')
  );
}

async function commitWithRetry(batch, label, { maxAttempts = 8 } = {}) {
  let delay = 5000;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      await batch.commit();
      return;
    } catch (err) {
      if (!isQuotaError(err) || attempt === maxAttempts) throw err;
      console.warn(
        `  ⚠ cota/rate (${label}) — tentativa ${attempt}/${maxAttempts}, espera ${Math.round(delay / 1000)}s…`,
      );
      await sleep(delay);
      delay = Math.min(delay * 2, 120000);
    }
  }
}

async function batchWrite(db, colId, items, idKey, env = {}) {
  const chunk = Math.min(
    400,
    Math.max(20, Number(env.SEED_CHUNK || 80) || 80),
  );
  const pauseMs = Math.max(0, Number(env.SEED_PAUSE_MS || 400) || 400);
  for (let i = 0; i < items.length; i += chunk) {
    const slice = items.slice(i, i + chunk);
    const batch = writeBatch(db);
    for (const item of slice) {
      const id = String(item[idKey]);
      const { id: _d, ...data } = item;
      batch.set(
        doc(db, colId, id),
        { ...data, updatedAt: Timestamp.now() },
        { merge: true },
      );
    }
    const label = `${colId} ${Math.min(i + chunk, items.length)}/${items.length}`;
    await commitWithRetry(batch, label);
    console.log(`  … ${Math.min(i + chunk, items.length)}/${items.length}`);
    if (pauseMs && i + chunk < items.length) await sleep(pauseMs);
  }
}

async function deleteOrphanBankQuestions(db, keepIds, trails, env = {}) {
  if (!trails.length) return;
  const chunk = Math.min(
    400,
    Math.max(20, Number(env.SEED_CHUNK || 80) || 80),
  );
  const pauseMs = Math.max(0, Number(env.SEED_PAUSE_MS || 400) || 400);
  let removed = 0;
  for (const trail of trails) {
    const snap = await getDocs(
      query(
        collection(db, 'content_bank_questions'),
        where('trail', '==', trail),
      ),
    );
    const orphans = snap.docs.filter((d) => !keepIds.has(d.id));
    for (let i = 0; i < orphans.length; i += chunk) {
      const slice = orphans.slice(i, i + chunk);
      const batch = writeBatch(db);
      for (const d of slice) batch.delete(d.ref);
      await commitWithRetry(
        batch,
        `órfãos ${trail} ${Math.min(i + chunk, orphans.length)}/${orphans.length}`,
      );
      removed += slice.length;
      if (pauseMs && i + chunk < orphans.length) await sleep(pauseMs);
    }
  }
  console.log(`  órfãos removidos: ${removed}`);
}

async function deleteOrphanStudies(db, keepSlugs, env = {}) {
  const chunk = Math.min(
    400,
    Math.max(20, Number(env.SEED_CHUNK || 80) || 80),
  );
  const pauseMs = Math.max(0, Number(env.SEED_PAUSE_MS || 400) || 400);
  const snap = await getDocs(collection(db, 'content_mission_studies'));
  const orphans = snap.docs.filter((d) => !keepSlugs.has(d.id));
  if (!orphans.length) {
    console.log('  estudos órfãos: 0');
    return 0;
  }
  let removed = 0;
  for (let i = 0; i < orphans.length; i += chunk) {
    const slice = orphans.slice(i, i + chunk);
    const batch = writeBatch(db);
    for (const d of slice) batch.delete(d.ref);
    await commitWithRetry(
      batch,
      `estudos órfãos ${Math.min(i + chunk, orphans.length)}/${orphans.length}`,
    );
    removed += slice.length;
    if (pauseMs && i + chunk < orphans.length) await sleep(pauseMs);
  }
  console.log(`  estudos órfãos removidos: ${removed}`);
  return removed;
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

  const only = (env.SEED_ONLY || '').trim().toLowerCase();
  const doTrails = !only || only === 'trails' || only === 'full';
  const doBank =
    !only || only === 'bank' || only === 'sermao' || only === 'full';
  const doStudies = !only || only === 'studies' || only === 'full';
  const doMeta =
    !only ||
    only === 'meta' ||
    only === 'full' ||
    only === 'bank' ||
    only === 'sermao' ||
    only === 'trails' ||
    only === 'studies';

  if (only) console.log(`SEED_ONLY=${only}`);

  try {
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
  } catch (err) {
    if (isQuotaError(err)) {
      console.warn(
        'admin_users: cota — seguindo (doc provavelmente já existe).',
      );
    } else {
      throw err;
    }
  }

  if (doTrails) {
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
      env,
    );
  }

  if (doBank) {
    const genesis = readJson('genesis_questions.json');
    const difficulties = genesis.difficulties || [];
    if ((!only || only === 'full' || only === 'bank') && difficulties.length) {
      console.log(`Dificuldades: ${difficulties.length}`);
      await batchWrite(
        db,
        'content_difficulties',
        difficulties.map((d, i) => ({ ...d, id: d.id, order: i + 1 })),
        'id',
        env,
      );
    }

    const allBankFiles = [
      ['genesis_questions.json', 'genesis-1-11', 'genesis'],
      ['exodo_questions.json', 'exodo', 'exodo'],
      ['ot_questions.json', null, 'ot'],
      ['nt_questions.json', null, 'nt'],
      ['sermao_questions.json', 'sermao-do-monte', 'sermao'],
      ['epistolas_questions.json', null, 'epistolas'],
      ['buracos_questions.json', null, 'buracos'],
    ];
    const bankFilter = (env.SEED_BANKS || '')
      .split(',')
      .map((s) => s.trim().toLowerCase())
      .filter(Boolean);
    const bankFiles =
      only === 'sermao'
        ? allBankFiles.filter(([, , key]) => key === 'sermao')
        : bankFilter.length
          ? allBankFiles.filter(([, , key]) => bankFilter.includes(key))
          : allBankFiles;

    const seen = new Set();
    const questions = [];
    for (const [file, defaultTrail] of bankFiles) {
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
        if (!q.trail && !q.trailSlug && defaultTrail) {
          q.trail = defaultTrail;
        }
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
      env,
    );

    if (bankFilter.length) {
      const keepIds = new Set(questions.map((q) => String(q.id)));
      const trails = [
        ...new Set(questions.map((q) => q.trail || q.trailSlug).filter(Boolean)),
      ];
      await deleteOrphanBankQuestions(db, keepIds, trails, env);
    }
  }

  if (doStudies) {
    const studiesPath = join(assetsRoot, 'mission_studies.json');
    if (existsSync(studiesPath)) {
      const data = readJson('mission_studies.json');
      const docs = Object.entries(data.studies || {}).map(([slug, s]) => ({
        ...s,
        id: slug,
        slug,
      }));
      console.log(`Estudos: ${docs.length}`);
      await batchWrite(db, 'content_mission_studies', docs, 'slug', env);
      const keepSlugs = new Set(docs.map((d) => String(d.slug || d.id)));
      await deleteOrphanStudies(db, keepSlugs, env);
      if (data.verses) {
        await setDoc(
          doc(db, 'content_meta', 'verses'),
          { verses: data.verses, updatedAt: Timestamp.now() },
          { merge: true },
        );
        console.log('Versículos OK');
      }
    }
  }

  if (doMeta) {
    await setDoc(
      doc(db, 'content_meta', 'catalog'),
      {
        version: Date.now(),
        updatedAt: Timestamp.now(),
        seededAt: Timestamp.now(),
      },
      { merge: true },
    );

    await setDoc(
      doc(db, 'content_meta', 'app_release'),
      {
        enabled: true,
        latestVersion: '1.0.14',
        latestBuild: 14,
        minBuild: 1,
        androidStoreUrl:
          'https://play.google.com/store/apps/details?id=com.trilha.trilha_app',
        iosStoreUrl: 'https://apps.apple.com/br/search?term=STWAY',
        message:
          'Uma nova versão do STWAY está pronta — melhorias e correções te esperam.',
        updatedAt: Timestamp.now(),
      },
      { merge: true },
    );

    await setDoc(
      doc(db, 'content_meta', 'bootstrap_locked'),
      {
        locked: true,
        lockedAt: Timestamp.now(),
        note: 'Novos admin_users só via Console / admin existente',
      },
      { merge: true },
    );
  }

  console.log('Catálogo atualizado. Seed concluído.');
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
  if (isQuotaError(err)) {
    console.error(
      'Cota Firestore esgotada (Spark ≈ 20k writes/dia).\n' +
        'Espere o reset (~00:00 Pacific / ~04:00 BRT) ou ative Blaze.\n' +
        'Enquanto isso, para a vitrine:\n' +
        '  SEED_ONLY=sermao node scripts/seed_content.mjs\n' +
        '(só ~465 writes — roda quando sobrar cota).',
    );
  } else {
    console.error(err.message || err);
  }
  process.exit(1);
});
