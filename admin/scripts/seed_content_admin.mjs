/**
 * Seed Firestore via Admin SDK (ignora regras — use com Firebase CLI / ADC).
 *
 *   node scripts/seed_content_admin.mjs
 *   SEED_ONLY=bank node scripts/seed_content_admin.mjs
 *
 * Credenciais (uma delas):
 *   - GOOGLE_APPLICATION_CREDENTIALS → service account JSON
 *   - gcloud auth application-default login
 */
import { readFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import admin from 'firebase-admin';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

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

async function batchWrite(db, colId, items, idKey, env = {}) {
  const chunk = Math.min(
    400,
    Math.max(20, Number(env.SEED_CHUNK || 80) || 80),
  );
  const pauseMs = Math.max(0, Number(env.SEED_PAUSE_MS || 400) || 400);
  for (let i = 0; i < items.length; i += chunk) {
    const slice = items.slice(i, i + chunk);
    const batch = db.batch();
    for (const item of slice) {
      const id = String(item[idKey]);
      const { id: _d, ...data } = item;
      batch.set(
        db.collection(colId).doc(id),
        { ...data, updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
    }
    await batch.commit();
    console.log(`  … ${Math.min(i + chunk, items.length)}/${items.length}`);
    if (pauseMs && i + chunk < items.length) await sleep(pauseMs);
  }
}

async function main() {
  const env = loadEnv();
  const projectId = env.VITE_FIREBASE_PROJECT_ID || 'trilha-biblia';

  if (!admin.getApps().length) {
    admin.initializeApp({
      credential: admin.applicationDefault(),
      projectId,
    });
  }
  const db = getFirestore();
  console.log(`Admin seed → ${projectId}`);

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
  }

  if (doStudies) {
    const studiesDoc = readJson('mission_studies.json');
    const studiesMap = studiesDoc.studies || studiesDoc;
    const docs = Object.entries(studiesMap)
      .filter(([, s]) => s && typeof s === 'object' && !Array.isArray(s))
      .map(([slug, s]) => ({ ...s, id: slug, slug }));
    const clean = docs.filter((d) => d.slug !== 'verses' && d.passageRef != null);
    console.log(`Estudos: ${(clean.length ? clean : docs).length}`);
    await batchWrite(
      db,
      'content_mission_studies',
      clean.length ? clean : docs,
      'slug',
      env,
    );
    if (studiesDoc.verses) {
      await batchWrite(
        db,
        'content_meta',
        [{ id: 'verses', verses: studiesDoc.verses }],
        'id',
        env,
      );
    }
  }

  if (doMeta) {
    const version = Date.now();
    await db.collection('content_meta').doc('catalog').set(
      {
        version,
        seededAt: FieldValue.serverTimestamp(),
        source: 'seed_content_admin.mjs',
      },
      { merge: true },
    );
    console.log(`Catálogo version=${version}`);
  }

  console.log('Seed admin concluído.');
}

main().catch((err) => {
  console.error(err.message || err);
  if (String(err.message || '').includes('Could not load the default credentials')) {
    console.error(
      '\nCredenciais ausentes. Opções:\n' +
        '  1. gcloud auth application-default login\n' +
        '  2. GOOGLE_APPLICATION_CREDENTIALS=/caminho/service-account.json\n' +
        '  3. admin/.env com SEED_EMAIL/SEED_PASSWORD (Email/Password + admin_users)\n' +
        '  4. Painel admin → Importar (npm run dev)',
    );
  }
  process.exit(1);
});
