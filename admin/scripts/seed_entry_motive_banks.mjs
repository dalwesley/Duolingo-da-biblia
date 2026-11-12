/**
 * Publica a travessia d'A Promessa (perguntas-v2):
 *
 *   - perguntas-v2/<trilha>.json          → content_bank_questions
 *   - perguntas-v2/<trilha>.studies.json  → content_mission_studies (se existir)
 *
 *   node scripts/seed_entry_motive_banks.mjs           # só mostra (simulação)
 *   node scripts/seed_entry_motive_banks.mjs --apply   # grava
 *
 * Não roda limpeza de órfãos — só faz merge destas trilhas e bumpa
 * catalog.version. Os estudos são conferidos: cada `evidenceSpan` precisa
 * estar no texto JFAAL do seu `evidenceRef`.
 */
import { createRequire } from 'module';
import { readFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { Firestore } from '@google-cloud/firestore';
import { validateBank, formatReport } from './_bank_validator.mjs';
import { passageText } from './_jfaal.mjs';

const APPLY = process.argv.includes('--apply');

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const __dirname = dirname(fileURLToPath(import.meta.url));
const adminRoot = join(__dirname, '..');
const v2Root = join(adminRoot, '..', 'perguntas-v2');

// a-promessa: só a travessia `promessa-sintese` (as outras cenas usam o
// banco da trilha de origem). Conhecer a Deus e Entender a Bíblia saíram
// daqui em 2026-11-11: agora são V3 (admin/v3/<trilha>, `npm run v3:publish`).
const TRAILS = ['a-promessa'];

/** Estudos da trilha, se houver arquivo; erra se algum fato não bate. */
function loadStudies(trail) {
  const path = join(v2Root, `${trail}.studies.json`);
  if (!existsSync(path)) return {};
  const studies = JSON.parse(readFileSync(path, 'utf8'));
  const bad = [];
  for (const [slug, s] of Object.entries(studies)) {
    if (!s.passageRef || !s.passageText) bad.push(`${slug}: falta passageRef/passageText`);
    for (const f of s.facts || []) {
      const text = passageText(f.evidenceRef) || '';
      if (!text.includes(f.evidenceSpan)) bad.push(`${slug}: "${f.evidenceSpan}" não está em ${f.evidenceRef}`);
    }
  }
  if (bad.length) throw new Error(`Estudos de ${trail} inválidos:\n  ${bad.join('\n  ')}`);
  return studies;
}

function loadEnv() {
  const env = { ...process.env };
  const envPath = join(adminRoot, '.env');
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

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function main() {
  const env = loadEnv();
  const projectId =
    env.VITE_FIREBASE_PROJECT_ID || env.FIREBASE_PROJECT || 'trilha-biblia';

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
  console.log(`Auth Firebase CLI (${email}) → ${projectId}`);

  const db = new Firestore({ projectId });
  const questions = [];
  const studies = {};
  for (const trail of TRAILS) {
    const own = loadStudies(trail);
    Object.assign(studies, own);
    if (Object.keys(own).length) console.log(`  ${trail}.studies.json: ${Object.keys(own).length}`);
    const path = join(v2Root, `${trail}.json`);
    const list = JSON.parse(readFileSync(path, 'utf8'));
    if (!Array.isArray(list)) throw new Error(`${trail}.json não é lista`);
    for (const q of list) {
      if (!q?.id) continue;
      if (!q.trail) q.trail = trail;
      questions.push(q);
    }
    console.log(`  ${trail}.json: ${list.length}`);
  }

  const check = validateBank(questions);
  if (!check.ok) {
    console.error(formatReport(check));
    throw new Error('Banco não passa no validador pedagógico.');
  }
  if (check.warnings?.length) {
    console.log(`Avisos: ${check.warnings.length}`);
    for (const w of check.warnings.slice(0, 8)) console.log(`  ⚠ ${w}`);
  }
  console.log(`Validador OK — ${questions.length} atos, ${Object.keys(studies).length} estudos`);

  if (!APPLY) {
    console.log('\nSimulação: nada foi gravado. Rode com --apply para publicar.');
    return;
  }

  const studyBatch = db.batch();
  for (const [slug, s] of Object.entries(studies)) {
    studyBatch.set(
      db.collection('content_mission_studies').doc(slug),
      { ...s, slug, updatedAt: Firestore.FieldValue.serverTimestamp() },
      { merge: true },
    );
  }
  if (Object.keys(studies).length) {
    await studyBatch.commit();
    console.log(`  ✓ ${Object.keys(studies).length} estudos`);
  }

  const chunk = Math.min(400, Math.max(10, Number(env.SEED_CHUNK || 40) || 40));
  const pauseMs = Math.max(0, Number(env.SEED_PAUSE_MS || 800) || 800);
  for (let i = 0; i < questions.length; i += chunk) {
    const slice = questions.slice(i, i + chunk);
    const batch = db.batch();
    for (const q of slice) {
      const { id, ...data } = q;
      batch.set(
        db.collection('content_bank_questions').doc(String(id)),
        { ...data, updatedAt: Firestore.FieldValue.serverTimestamp() },
        { merge: true },
      );
    }
    await batch.commit();
    console.log(`  … ${Math.min(i + chunk, questions.length)}/${questions.length}`);
    if (pauseMs && i + chunk < questions.length) await sleep(pauseMs);
  }

  const version = Date.now();
  await db.collection('content_meta').doc('catalog').set(
    {
      version,
      seededAt: Firestore.FieldValue.serverTimestamp(),
      source: 'seed_entry_motive_banks.mjs',
    },
    { merge: true },
  );
  console.log(`✓ catalog.version=${version}`);
  console.log('Seed dos motivos concluído.');
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
