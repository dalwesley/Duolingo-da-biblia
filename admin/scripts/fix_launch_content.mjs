/**
 * Correções de conteúdo do pente fino de lançamento (2026-10-28).
 *
 *   node scripts/fix_launch_content.mjs            → só mostra o que mudaria
 *   node scripts/fix_launch_content.mjs --apply    → grava e bumpa catalog.version
 *
 * 1. Versículo de entrada (hookRef/hookVerse) errado: Jó 1 mostrava João 1:1,
 *    os desafios de Vida Cristã mostravam Oseias, Salmo 1 mostrava o Salmo 23.
 *    O texto certo vem do estudo V3 da cena (`passageRef`/`passageText`).
 * 2. `hb-boss` era o slug da Travessia de Hebreus e da de Hebraico: a de
 *    Hebreus (jogável) mostrava o estudo do Shemá. Hebraico (em breve) passa a
 *    `hbr-boss`, com estudo e perguntas próprios; `hb-boss` volta a ser
 *    Hebreus.
 */
import { createRequire } from 'module';
import { readFileSync } from 'fs';
import { join } from 'path';
import { Firestore } from '@google-cloud/firestore';
import { ADMIN_DIR } from './_v3_paths.mjs';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const APPLY = process.argv.includes('--apply');
const PROJECT = 'trilha-biblia';

// trilha → cenas cujo versículo de entrada vem do estudo.
const HOOK_FIXES = {
  jo: ['jo-prova-01-jo-integro', 'jo-prova-02-perda-e-adoracao'],
  familia: ['fm-04-desafio'],
  'igreja-primitiva': ['ip-04-desafio'],
  jejum: ['jj-04-desafio'],
  missao: ['ms-04-desafio'],
  oracao: ['or-04-desafio'],
  'historia-igreja': ['hi-03-desafio'],
  salmos: ['salmos-louvor-01-bem-aventurado-o-hom'],
  hebreus: ['hb-boss'],
};
const TITLE_FIXES = { hebreus: { 'hb-boss': 'Revisão: Hebreus' } };
const OLD_BOSS = 'hb-boss';
const NEW_BOSS = 'hbr-boss';

function studies(trail) {
  const path = join(ADMIN_DIR, 'v3', trail, 'studies_v3.json');
  return JSON.parse(readFileSync(path, 'utf8')).studies || {};
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

/** Aplica [edit] a cada missão do doc da trilha; devolve se mudou. */
async function editTrail(db, slug, edit, writes) {
  const ref = db.collection('content_trails').doc(slug);
  const snap = await ref.get();
  if (!snap.exists) throw new Error(`content_trails/${slug} não existe`);
  const modules = structuredClone(snap.data().modules || []);
  let changed = false;
  for (const mod of modules) {
    for (const m of mod.missions || []) {
      if (edit(m)) changed = true;
    }
  }
  if (changed) writes.push(() => ref.update({ modules }));
  return changed;
}

async function main() {
  const db = await connect();
  const writes = [];

  // 1. Versículos de entrada.
  for (const [trail, slugs] of Object.entries(HOOK_FIXES)) {
    const st = studies(trail);
    await editTrail(db, trail, (m) => {
      if (!slugs.includes(m.slug)) return false;
      const s = st[m.slug];
      if (!s?.passageRef || !s?.passageText) {
        throw new Error(`${trail}/${m.slug}: estudo sem passageRef/passageText`);
      }
      const title = TITLE_FIXES[trail]?.[m.slug];
      if (m.hookRef === s.passageRef && m.hookVerse === s.passageText && (!title || m.title === title)) {
        return false;
      }
      console.log(`• ${trail}/${m.slug}\n    ${m.hookRef} → ${s.passageRef}\n    "${String(m.hookVerse).slice(0, 50)}…" → "${s.passageText.slice(0, 50)}…"`);
      m.hookRef = s.passageRef;
      m.hookVerse = s.passageText;
      if (title && m.title !== title) {
        console.log(`    título: ${m.title} → ${title}`);
        m.title = title;
      }
      return true;
    }, writes);
  }

  // 2. Hebraico deixa o slug hb-boss para Hebreus.
  const hebraicoStudy = studies('hebraico')[OLD_BOSS];
  await editTrail(db, 'hebraico', (m) => {
    if (m.slug !== OLD_BOSS) return false;
    console.log(`• hebraico/${OLD_BOSS} → ${NEW_BOSS}`);
    m.slug = NEW_BOSS;
    if (hebraicoStudy?.passageRef) {
      m.hookRef = hebraicoStudy.passageRef;
      m.hookVerse = hebraicoStudy.passageText;
    }
    return true;
  }, writes);

  const studiesCol = db.collection('content_mission_studies');
  const current = await studiesCol.doc(OLD_BOSS).get();
  const hebreusStudy = studies('hebreus')[OLD_BOSS];
  if (!hebreusStudy) throw new Error('hebreus: estudo hb-boss não encontrado');
  if (current.exists && current.data().passageRef !== hebreusStudy.passageRef) {
    console.log(`• content_mission_studies/${NEW_BOSS} ← estudo atual (${current.data().passageRef}, de Hebraico)`);
    const hebraico = { ...current.data(), slug: NEW_BOSS, updatedAt: new Date() };
    writes.push(() => studiesCol.doc(NEW_BOSS).set(hebraico));
    console.log(`• content_mission_studies/${OLD_BOSS} ← estudo de Hebreus (${hebreusStudy.passageRef})`);
    writes.push(() => studiesCol.doc(OLD_BOSS).set({ ...hebreusStudy, slug: OLD_BOSS, updatedAt: new Date() }));
  }

  const bank = await db
    .collection('content_bank_questions')
    .where('trail', '==', 'hebraico')
    .where('section', '==', OLD_BOSS)
    .get();
  if (!bank.empty) {
    console.log(`• ${bank.size} perguntas de Hebraico: section ${OLD_BOSS} → ${NEW_BOSS}`);
    writes.push(async () => {
      const batch = db.batch();
      for (const doc of bank.docs) batch.update(doc.ref, { section: NEW_BOSS });
      await batch.commit();
    });
  }

  if (!writes.length) {
    console.log('Nada a corrigir.');
    return;
  }
  if (!APPLY) {
    console.log(`\n${writes.length} gravação(ões) pendente(s). Rode com --apply para gravar.`);
    return;
  }
  for (const w of writes) await w();
  const version = Date.now();
  await db.collection('content_meta').doc('catalog').set(
    { version, seededAt: Firestore.FieldValue.serverTimestamp(), source: 'fix_launch_content.mjs' },
    { merge: true },
  );
  console.log(`\n✓ ${writes.length} gravação(ões). catalog.version=${version}`);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
