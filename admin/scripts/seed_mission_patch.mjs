/**
 * Seed pontual: sobrescreve perguntas de 1 missão no Firestore.
 * Uso: SEED_SECTION=gen-01-criador node scripts/seed_mission_patch.mjs
 */
import { createRequire } from 'module';
import { readFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { Firestore } from '@google-cloud/firestore';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const __dirname = dirname(fileURLToPath(import.meta.url));
const adminRoot = join(__dirname, '..');
const assetsRoot = join(adminRoot, '..', 'trilha_app', 'assets', 'data');

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

async function main() {
  const env = loadEnv();
  const section = (env.SEED_SECTION || 'gen-01-criador').trim();
  const projectId = env.FIREBASE_PROJECT || 'trilha-biblia';

  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    throw new Error('Firebase CLI não logado.');
  }
  const credPath = await getCredentialPathAsync(account);
  process.env.GOOGLE_APPLICATION_CREDENTIALS = credPath;
  const db = new Firestore({ projectId });

  const files = [
    'genesis_questions.json',
    'exodo_questions.json',
    'ot_questions.json',
    'nt_questions.json',
    'epistolas_questions.json',
    'sermao_questions.json',
    'buracos_questions.json',
  ];

  const qs = [];
  for (const file of files) {
    const raw = JSON.parse(readFileSync(join(assetsRoot, file), 'utf8'));
    const list = Array.isArray(raw) ? raw : raw.questions || [];
    for (const q of list) {
      if (q.section === section) qs.push(q);
    }
  }
  if (!qs.length) throw new Error(`Nenhuma pergunta para section=${section}`);

  console.log(`Patch ${section}: ${qs.length} perguntas → ${projectId}`);
  const chunk = 10;
  for (let i = 0; i < qs.length; i += chunk) {
    const batch = db.batch();
    for (const q of qs.slice(i, i + chunk)) {
      const { id, ...data } = q;
      batch.set(
        db.collection('content_bank_questions').doc(String(id)),
        { ...data, updatedAt: Firestore.FieldValue.serverTimestamp() },
        { merge: true },
      );
    }
    await batch.commit();
    console.log(`  ${Math.min(i + chunk, qs.length)}/${qs.length}`);
    await new Promise((r) => setTimeout(r, 1200));
  }

  // Bump catalog version so o app refetch.
  const version = Date.now();
  await db.collection('content_meta').doc('catalog').set(
    { version, updatedAt: Firestore.FieldValue.serverTimestamp() },
    { merge: true },
  );
  console.log(`✓ catalog.version=${version}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
