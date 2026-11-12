/**
 * Leva as trilhas de entrada (Ansiedade, Conhecer a Deus, Entender a Bíblia)
 * do código do app (entry_trails.dart no HEAD do git + app_*.arb) para
 * o Firestore, como as outras trilhas:
 *
 *   - `content_trails/{slug}` em português (nome, cenas, entrada);
 *   - inglês e espanhol no overlay do app
 *     (trilha_app/assets/l10n/content/trails_{en,es}.json).
 *
 * Perguntas e estudos já estão no Firestore (content_bank_questions,
 * content_mission_studies) e não mudam.
 *
 *   node scripts/migrate_entry_trails.mjs            # só mostra (dry run)
 *   node scripts/migrate_entry_trails.mjs --apply    # grava Firestore + overlays
 *
 * Não sobrescreve doc que já existe em content_trails (use --force).
 */
import { execFileSync } from 'child_process';
import { createRequire } from 'module';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const require = createRequire(import.meta.url);
const __dirname = dirname(fileURLToPath(import.meta.url));
const repo = join(__dirname, '..', '..');
const app = join(repo, 'trilha_app');
const APPLY = process.argv.includes('--apply');
const FORCE = process.argv.includes('--force');

const arb = (lang) => JSON.parse(readFileSync(join(app, `lib/l10n/app_${lang}.arb`), 'utf8'));
const ARB = { pt: arb('pt'), en: arb('en'), es: arb('es') };

/** `campo: valor` de um trecho Dart: l.chave, 'texto', número ou bool. */
function fields(chunk) {
  const out = {};
  const re = /(\w+):\s*(l\.(\w+)|'((?:[^'\\]|\\.)*)'|(-?\d+)|(true|false))\s*,/g;
  let m;
  while ((m = re.exec(chunk))) {
    const [, key, , l10n, str, num, bool] = m;
    if (key in out) continue;
    if (l10n) out[key] = { l10n };
    else if (str !== undefined) out[key] = str.replace(/\\'/g, "'").replace(/\\\\/g, '\\');
    else if (num !== undefined) out[key] = Number(num);
    else out[key] = bool === 'true';
  }
  return out;
}

const text = (v, lang) => {
  if (v && typeof v === 'object') {
    const s = ARB[lang][v.l10n];
    if (s === undefined) throw new Error(`Chave ${v.l10n} sem texto em app_${lang}.arb`);
    return s;
  }
  return v;
};

function parse() {
  // Só a classe EntryTrails (o arquivo tem outras depois dela).
  // O app já não tem as cenas: lê a última versão commitada que tinha.
  const all = execFileSync('git', ['show', `HEAD:trilha_app/lib/data/entry_trails.dart`], { cwd: repo, encoding: 'utf8' });
  const start = all.indexOf('class EntryTrails');
  const src = all.slice(start, all.indexOf('\n}\n', start));
  const trails = [];
  for (const block of src.split(/static Trail get _\w+ \{/).slice(1)) {
    const [head, ...mods] = block.split(/\bTrailModule\(/);
    const t = fields(head);
    const modules = mods.map((modChunk) => {
      const [modHead, ...missions] = modChunk.split(/\bMission\(/);
      return { ...fields(modHead), missions: missions.map(fields) };
    });
    trails.push({ ...t, modules });
  }
  return trails;
}

const MISSION_TEXT = ['title', 'intro', 'hookNote', 'centralInsight', 'objective'];

function toDoc(t) {
  return {
    slug: t.slug,
    title: text(t.title, 'pt'),
    description: text(t.description, 'pt'),
    icon: t.icon,
    order: t.order ?? 0,
    comingSoon: t.comingSoon ?? false,
    color: t.color,
    realm: t.realmId,
    category: t.categoryId,
    isActive: true,
    modules: t.modules.map((mod) => ({
      title: text(mod.title, 'pt'),
      icon: mod.icon,
      missions: mod.missions.map((m) => {
        const out = { slug: m.slug, type: m.type || 'lesson', stepsReward: m.stepsReward ?? 50 };
        for (const k of [...MISSION_TEXT, 'hookRef', 'hookVerse', 'bankSection', 'bankTrailSlug']) {
          if (m[k] !== undefined) out[k] = text(m[k], 'pt');
        }
        return out;
      }),
    })),
  };
}

function overlay(trails, lang) {
  const o = { trails: {}, modules: {}, missions: {} };
  for (const t of trails) {
    o.trails[t.slug] = { title: text(t.title, lang), description: text(t.description, lang) };
    t.modules.forEach((mod, i) => {
      o.modules[`${t.slug}:${i}`] = { title: text(mod.title, lang) };
      for (const m of mod.missions) {
        o.missions[m.slug] = Object.fromEntries(MISSION_TEXT.filter((k) => m[k] !== undefined).map((k) => [k, text(m[k], lang)]));
      }
    });
  }
  return o;
}

function mergeOverlay(lang, add) {
  const path = join(app, `assets/l10n/content/trails_${lang}.json`);
  const cur = existsSync(path) ? JSON.parse(readFileSync(path, 'utf8')) : { trails: {}, modules: {}, missions: {} };
  for (const k of ['trails', 'modules', 'missions']) cur[k] = { ...(cur[k] || {}), ...add[k] };
  if (APPLY) writeFileSync(path, `${JSON.stringify(cur, null, 2)}\n`);
  return Object.keys(add.missions).length;
}

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
  const trails = parse();
  if (trails.length !== 3) throw new Error(`Esperava 3 trilhas em entry_trails.dart, achei ${trails.length}`);
  const docs = trails.map(toDoc);
  for (const d of docs) {
    const scenes = d.modules.flatMap((m) => m.missions);
    console.log(`${d.slug} (${d.category}): ${scenes.length} cenas — ${scenes.map((s) => s.title).join(' · ')}`);
    for (const s of scenes) {
      const missing = ['title', 'intro', 'hookRef', 'hookVerse', 'hookNote', 'centralInsight', 'objective'].filter((k) => !s[k]);
      if (missing.length) console.log(`  ⚠ ${s.slug} sem ${missing.join(', ')}`);
    }
  }
  for (const lang of ['en', 'es']) console.log(`overlay ${lang}: ${mergeOverlay(lang, overlay(trails, lang))} cenas${APPLY ? ' gravadas' : ''}`);

  if (!APPLY) {
    console.log('\nDry run. Para gravar: node scripts/migrate_entry_trails.mjs --apply');
    return;
  }
  const { db, Firestore } = await firestore();
  for (const d of docs) {
    const ref = db.collection('content_trails').doc(d.slug);
    if ((await ref.get()).exists && !FORCE) {
      console.log(`= ${d.slug} já existe em content_trails (use --force para sobrescrever)`);
      continue;
    }
    await ref.set({ ...d, updatedAt: Firestore.FieldValue.serverTimestamp() });
    console.log(`✓ content_trails/${d.slug}`);
  }
  const version = Date.now();
  await db.collection('content_meta').doc('catalog').set(
    { version, seededAt: Firestore.FieldValue.serverTimestamp(), source: 'migrate_entry_trails.mjs' },
    { merge: true },
  );
  console.log(`✓ catalog.version=${version}`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
