/**
 * Seed Firestore usando sessão do Firebase CLI.
 *
 *   SEED_ONLY=bank node scripts/seed_content_cli.mjs
 */
import { createRequire } from 'module';
import { readFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { Firestore } from '@google-cloud/firestore';
import { validateBank, formatReport } from './_bank_validator.mjs';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

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

async function firebaseCliFirestore(projectId) {
  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    throw new Error('Firebase CLI não logado. Rode: firebase login --reauth');
  }
  const email = account.user?.email || '(desconhecido)';
  const credPath = await getCredentialPathAsync(account);
  if (!credPath) {
    throw new Error('Não foi possível materializar credenciais do Firebase CLI.');
  }
  process.env.GOOGLE_APPLICATION_CREDENTIALS = credPath;
  console.log(`Auth Firebase CLI (${email})`);
  return new Firestore({ projectId });
}

async function batchWrite(db, colId, items, idKey, env = {}) {
    const chunk = Math.min(
      400,
      Math.max(10, Number(env.SEED_CHUNK || 40) || 40),
    );
    const pauseMs = Math.max(0, Number(env.SEED_PAUSE_MS || 800) || 800);
  for (let i = 0; i < items.length; i += chunk) {
    const slice = items.slice(i, i + chunk);
    const batch = db.batch();
    for (const item of slice) {
      const id = String(item[idKey]);
      const { id: _d, ...data } = item;
      batch.set(
        db.collection(colId).doc(id),
        { ...data, updatedAt: Firestore.FieldValue.serverTimestamp() },
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
  const db = await firebaseCliFirestore(projectId);
  console.log(`CLI seed → ${projectId}`);

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
    if ((!only || only === 'full' || only === 'bank') && difficulties.length && !env.SEED_TRAIL && env.SEED_ORPHANS_ONLY !== '1') {
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
    const trailFilter = (env.SEED_TRAIL || '').trim();
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
        if (
          trailFilter &&
          (q.trail || q.trailSlug || defaultTrail) !== trailFilter
        ) {
          continue;
        }
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
    if (questions.length && env.SEED_SKIP_VALIDATE !== '1') {
      const check = validateBank(questions);
      if (!check.ok) {
        console.error('\nSeed abortado: banco não passa no validador pedagógico.\n');
        console.error(formatReport(check));
        console.error('\nCorrija com `npm run pipeline:v2` ou SEED_SKIP_VALIDATE=1 (não usar em prod).');
        process.exit(1);
      }
      console.log(`Validador: OK (${questions.length} atos)`);
    }
    const orphansOnly = env.SEED_ORPHANS_ONLY === '1';
    if (!orphansOnly) {
      await batchWrite(
        db,
        'content_bank_questions',
        questions.map((q, i) => ({ ...q, id: q.id, order: i + 1 })),
        'id',
        env,
      );
    } else {
      console.log('SEED_ORPHANS_ONLY=1 — pulando escrita do banco');
    }

    if (questions.length && env.SEED_SKIP_ORPHANS !== '1') {
      const keep = new Set(questions.map((q) => String(q.id)));
      const pageSize = Math.min(
        500,
        Math.max(50, Number(env.SEED_ORPHAN_PAGE || 100) || 100),
      );
      const delChunk = Math.min(
        400,
        Math.max(10, Number(env.SEED_DELETE_CHUNK || 40) || 40),
      );
      const pauseMs = Math.max(0, Number(env.SEED_PAUSE_MS || 800) || 800);
      let lastDoc = null;
      let scanned = 0;
      let removed = 0;
      let pending = [];

      console.log('Varrendo content_bank_questions para órfãos…');
      while (true) {
        let q = db
          .collection('content_bank_questions')
          .orderBy('__name__')
          .limit(pageSize);
        if (lastDoc) q = q.startAfter(lastDoc);
        const snap = await q.get();
        if (snap.empty) break;
        for (const d of snap.docs) {
          scanned += 1;
          if (!keep.has(d.id)) pending.push(d);
          if (pending.length >= delChunk) {
            const batch = db.batch();
            for (const doc of pending.splice(0, delChunk)) batch.delete(doc.ref);
            await batch.commit();
            removed += delChunk;
            console.log(`  órfãos removidos: ${removed} (lidos ${scanned})`);
            if (pauseMs) await sleep(pauseMs);
          }
        }
        lastDoc = snap.docs[snap.docs.length - 1];
        if (snap.size < pageSize) break;
        if (pauseMs) await sleep(pauseMs);
      }
      if (pending.length) {
        const batch = db.batch();
        for (const doc of pending) batch.delete(doc.ref);
        await batch.commit();
        removed += pending.length;
      }
      console.log(
        removed
          ? `Órfãos removidos: ${removed} (${scanned} docs lidos)`
          : `Nenhum órfão (${scanned} docs lidos)`,
      );
    } else if (questions.length && env.SEED_SKIP_ORPHANS === '1') {
      console.log('SEED_SKIP_ORPHANS=1 — limpeza de órfãos ignorada');
    }
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
        seededAt: Firestore.FieldValue.serverTimestamp(),
        source: 'seed_content_cli.mjs',
      },
      { merge: true },
    );
    console.log(`Catálogo version=${version}`);
  }

  console.log('Seed CLI concluído.');
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
