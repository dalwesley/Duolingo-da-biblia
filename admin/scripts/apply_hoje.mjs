/**
 * Frases "Hoje" (centralInsight) de todas as cenas (2026-10-28).
 *
 *   node scripts/apply_hoje.mjs                  → só mostra o que mudaria (arquivos + Firestore)
 *   node scripts/apply_hoje.mjs --no-firestore   → só mostra o que mudaria nos arquivos, sem login
 *   node scripts/apply_hoje.mjs --local          → grava trails.json e os overlays EN/ES do app
 *   node scripts/apply_hoje.mjs --apply          → grava no Firestore e bumpa catalog.version
 *
 * As frases vêm de v3/_hoje/respostas/lote-*.json ({slug, pt, en, es, fonte}),
 * escritas a partir de v3/_hoje/GUIA.md. Base dos Postais da caminhada
 * (trilha_app/docs/postais.md).
 */
import { createRequire } from 'module';
import { readFileSync, readdirSync, writeFileSync } from 'fs';
import { join } from 'path';
import { Firestore } from '@google-cloud/firestore';
import { ADMIN_DIR } from './_v3_paths.mjs';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const APPLY = process.argv.includes('--apply');
const LOCAL = process.argv.includes('--local');
const PROJECT = 'trilha-biblia';
const HOJE_DIR = join(ADMIN_DIR, 'v3', '_hoje', 'respostas');
const APP_DIR = join(ADMIN_DIR, '..', 'trilha_app');
const TRAILS_JSON = join(APP_DIR, 'assets', 'data', 'trails.json');
const OVERLAY = (locale) => join(APP_DIR, 'assets', 'l10n', 'content', `trails_${locale}.json`);

function phrases() {
  const bySlug = {};
  for (const f of readdirSync(HOJE_DIR).filter((f) => /^lote-\d+\.json$/.test(f)).sort()) {
    for (const p of JSON.parse(readFileSync(join(HOJE_DIR, f), 'utf8'))) {
      for (const k of ['pt', 'en', 'es']) {
        const t = (p[k] || '').trim();
        if (!t || t.length > 80 || /[?…]|\.$/.test(t)) throw new Error(`${f} ${p.slug}.${k} inválida: "${t}"`);
      }
      if (bySlug[p.slug]) throw new Error(`${p.slug} repetida (${f})`);
      bySlug[p.slug] = p;
    }
  }
  return bySlug;
}

// O desafio de Hebraico ainda é `hb-boss` no trails.json (e no Firestore até
// rodar fix_launch_content.mjs --apply, que o renomeia para `hbr-boss`).
const LOCAL_ALIASES = { 'hebraico/hb-boss': 'hbr-boss' };

function editModules(modules, bySlug, seen, trailSlug = null) {
  let changed = 0;
  for (const mod of modules || []) {
    for (const m of mod.missions || []) {
      const p = bySlug[(trailSlug && LOCAL_ALIASES[`${trailSlug}/${m.slug}`]) || m.slug];
      if (!p) continue;
      seen.add(p.slug);
      if ((m.centralInsight || '').trim() === p.pt) continue;
      m.centralInsight = p.pt;
      changed++;
    }
  }
  return changed;
}

function applyLocal(bySlug) {
  const trails = JSON.parse(readFileSync(TRAILS_JSON, 'utf8'));
  const seen = new Set();
  let changed = 0;
  for (const t of trails) changed += editModules(t.modules, bySlug, seen, t.slug);
  const missing = Object.keys(bySlug).filter((s) => !seen.has(s));
  console.log(`trails.json: ${changed} frase(s) nova(s); ${missing.length} slug(s) fora do arquivo${missing.length ? `: ${missing.join(', ')}` : ''}`);

  const overlays = {};
  for (const locale of ['en', 'es']) {
    const data = JSON.parse(readFileSync(OVERLAY(locale), 'utf8'));
    let n = 0;
    for (const [slug, p] of Object.entries(bySlug)) {
      const entry = (data.missions[slug] ||= {});
      if (entry.centralInsight === p[locale]) continue;
      entry.centralInsight = p[locale];
      n++;
    }
    overlays[locale] = data;
    console.log(`trails_${locale}.json: ${n} frase(s) nova(s)`);
  }

  if (!LOCAL) return;
  writeFileSync(TRAILS_JSON, `${JSON.stringify(trails, null, 2)}\n`);
  for (const [locale, data] of Object.entries(overlays)) {
    writeFileSync(OVERLAY(locale), `${JSON.stringify(data, null, 2)}\n`);
  }
  console.log('✓ arquivos do app gravados');
}

async function connect() {
  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    throw new Error('Firebase CLI não logado. Rode: firebase login --reauth');
  }
  process.env.GOOGLE_APPLICATION_CREDENTIALS = await getCredentialPathAsync(account);
  console.log(`Auth ${account.user?.email || '?'} → ${PROJECT} ${APPLY ? '(GRAVANDO)' : '(simulação)'}`);
  return new Firestore({ projectId: PROJECT });
}

async function applyFirestore(bySlug) {
  const db = await connect();
  const snap = await db.collection('content_trails').get();
  const seen = new Set();
  const writes = [];
  let total = 0;
  for (const doc of snap.docs) {
    const modules = structuredClone(doc.data().modules || []);
    const changed = editModules(modules, bySlug, seen, doc.id);
    if (!changed) continue;
    total += changed;
    console.log(`• ${doc.id}: ${changed}`);
    writes.push(() => doc.ref.update({ modules }));
  }
  const missing = Object.keys(bySlug).filter((s) => !seen.has(s));
  console.log(`Firestore: ${total} frase(s) em ${writes.length} trilha(s); ${missing.length} slug(s) sem missão${missing.length ? `: ${missing.join(', ')}` : ''}`);
  if (!APPLY) {
    console.log('\nSimulação. Rode com --apply para gravar.');
    return;
  }
  for (const w of writes) await w();
  const version = Date.now();
  await db.collection('content_meta').doc('catalog').set(
    { version, seededAt: Firestore.FieldValue.serverTimestamp(), source: 'apply_hoje.mjs' },
    { merge: true },
  );
  console.log(`\n✓ ${writes.length} gravação(ões). catalog.version=${version}`);
}

async function main() {
  const bySlug = phrases();
  console.log(`${Object.keys(bySlug).length} frases carregadas\n`);
  applyLocal(bySlug);
  if ((LOCAL || process.argv.includes('--no-firestore')) && !APPLY) return;
  console.log('');
  await applyFirestore(bySlug);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
