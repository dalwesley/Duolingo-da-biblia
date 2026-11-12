/**
 * Traz para os arquivos locais da trilha as edições feitas no painel admin.
 *
 * O `v3:publish` substitui cada pergunta inteira pelo que está em
 * `<trilha>/cenas/*.json`. Sem este passo, uma correção feita no painel some
 * no próximo publish. O painel marca o que mexeu (`panelEditedAt` nas
 * perguntas e estudos; exclusões em `content_meta/panel_deletes`).
 *
 *   node scripts/v3_pull_edits.mjs --trail rute            # mostra o que mudou
 *   node scripts/v3_pull_edits.mjs --trail rute --apply    # grava em cenas/*.json
 *   node scripts/v3_pull_edits.mjs                         # lista edições pendentes de todas as trilhas
 *
 * Depois do --apply: v3:validate --final, v3:merge, v3:translate e v3:publish.
 * O publish limpa as marcas (grava o documento sem elas).
 */
import { createRequire } from 'module';
import { writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { Firestore } from '@google-cloud/firestore';
import { argValue, trailDir } from './_v3_paths.mjs';
import { diffFields, readCenas, stripMeta } from './_v3_panel_edits.mjs';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount, getProjectDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT = 'trilha-biblia';
const TRAIL = argValue('--trail');
const APPLY = process.argv.includes('--apply');

async function getDb() {
  const account = getProjectDefaultAccount(join(__dirname, '..', '..')) || getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) throw new Error('Firebase CLI não logado. Rode: firebase login --reauth');
  process.env.GOOGLE_APPLICATION_CREDENTIALS = await getCredentialPathAsync(account);
  return new Firestore({ projectId: PROJECT });
}

function short(v) {
  const s = typeof v === 'string' ? v : JSON.stringify(v);
  if (s === undefined) return '∅';
  return s.length > 110 ? `${s.slice(0, 107)}…` : s;
}

async function listAll(db) {
  const [qs, ss, del] = await Promise.all([
    db.collection('content_bank_questions').where('panelEditedAt', '>', new Date(0)).get(),
    db.collection('content_mission_studies').where('panelEditedAt', '>', new Date(0)).get(),
    db.collection('content_meta').doc('panel_deletes').get(),
  ]);
  const byTrail = new Map();
  const bump = (t, k) => {
    const e = byTrail.get(t) || { questions: 0, deletes: 0 };
    e[k] += 1;
    byTrail.set(t, e);
  };
  for (const d of qs.docs) bump(d.get('trail') || '(sem trilha)', 'questions');
  for (const [, v] of Object.entries(del.data() || {})) bump(v?.trail || '(sem trilha)', 'deletes');
  console.log('Edições do painel ainda não trazidas para os arquivos locais:\n');
  if (!byTrail.size && !ss.size) console.log('  nenhuma.');
  for (const [t, e] of [...byTrail].sort()) {
    console.log(`  ${t}: ${e.questions} pergunta(s) editada(s), ${e.deletes} excluída(s)`);
  }
  if (ss.size) console.log(`  estudos editados: ${ss.docs.map((d) => d.id).join(', ')}`);
  console.log('\nRode com --trail <slug> para ver e --apply para gravar.');
}

async function main() {
  const db = await getDb();
  if (!TRAIL) return listAll(db);

  const dir = trailDir(TRAIL);
  const cenas = readCenas(dir);
  if (!cenas.size) throw new Error(`Sem cenas locais em ${dir}/cenas — trilha fora do pipeline V3.`);

  const [qSnap, delSnap, studySnaps] = await Promise.all([
    db.collection('content_bank_questions').where('trail', '==', TRAIL).get(),
    db.collection('content_meta').doc('panel_deletes').get(),
    Promise.all([...cenas.keys()].map((slug) => db.collection('content_mission_studies').doc(slug).get())),
  ]);

  const localById = new Map();
  for (const [slug, c] of cenas) {
    for (const q of c.data.questions || []) localById.set(q.id, { slug, q });
  }

  const touched = new Set();
  let changes = 0;

  // Perguntas editadas ou criadas no painel.
  for (const d of qSnap.docs) {
    const remote = d.data();
    if (!remote.panelEditedAt) continue;
    const id = d.id;
    const hit = localById.get(id);
    const by = remote.panelEditedBy ? ` (por ${remote.panelEditedBy})` : '';
    if (!hit) {
      const slug = remote.section;
      const c = cenas.get(slug);
      console.log(`\n+ ${id}${by} — nova no painel${c ? '' : `, mas a cena ${slug} não existe localmente (ignorada)`}`);
      if (!c) continue;
      c.data.questions.push({ id, ...stripMeta(remote) });
      touched.add(slug);
      changes += 1;
      continue;
    }
    const diff = diffFields(hit.q, { id, ...remote });
    if (!diff.length) continue;
    console.log(`\n~ ${id}${by}`);
    for (const f of diff) console.log(`    ${f.key}: ${short(f.local)}\n      → ${short(f.remote)}`);
    const c = cenas.get(hit.slug);
    const i = c.data.questions.findIndex((q) => q.id === id);
    // Mantém a ordem dos campos do arquivo; campos novos vão para o fim.
    const next = { id };
    const remoteClean = stripMeta(remote);
    for (const k of Object.keys(hit.q)) if (k !== 'id' && k in remoteClean) next[k] = remoteClean[k];
    for (const k of Object.keys(remoteClean)) if (!(k in next)) next[k] = remoteClean[k];
    c.data.questions[i] = next;
    touched.add(hit.slug);
    changes += 1;
  }

  // Exclusões.
  const deletes = Object.entries(delSnap.data() || {}).filter(([, v]) => v?.trail === TRAIL);
  for (const [id, v] of deletes) {
    const hit = localById.get(id);
    if (!hit) continue;
    console.log(`\n- ${id} — excluída no painel${v.by ? ` por ${v.by}` : ''}`);
    const c = cenas.get(hit.slug);
    c.data.questions = c.data.questions.filter((q) => q.id !== id);
    touched.add(hit.slug);
    changes += 1;
  }

  // Estudos editados no painel (merge: só os campos que o arquivo já tem ou que o painel criou).
  for (const snap of studySnaps) {
    if (!snap.exists || !snap.get('panelEditedAt')) continue;
    const slug = snap.id;
    const c = cenas.get(slug);
    const remote = stripMeta(snap.data());
    const local = c.data.study || {};
    const diff = diffFields(local, remote).filter((f) => f.remote !== undefined);
    if (!diff.length) continue;
    console.log(`\n~ estudo ${slug}${snap.get('panelEditedBy') ? ` (por ${snap.get('panelEditedBy')})` : ''}`);
    for (const f of diff) console.log(`    ${f.key}: ${short(f.local)}\n      → ${short(f.remote)}`);
    c.data.study = { ...local, ...Object.fromEntries(diff.map((f) => [f.key, f.remote])) };
    touched.add(slug);
    changes += 1;
  }

  if (!changes) {
    console.log(`Nada a trazer: ${TRAIL} local já bate com o que o painel editou.`);
    return;
  }
  if (!APPLY) {
    console.log(`\n${changes} mudança(s) em ${touched.size} cena(s). Simulação: rode com --apply para gravar.`);
    return;
  }
  for (const slug of touched) {
    const c = cenas.get(slug);
    writeFileSync(c.path, `${JSON.stringify(c.data, null, 2)}\n`);
  }
  console.log(`\n✓ ${changes} mudança(s) gravada(s) em ${touched.size} cena(s).`);
  console.log(`Próximo: npm run v3:validate -- --trail ${TRAIL} --final && npm run v3:merge -- --trail ${TRAIL}`);
  console.log(`         npm run v3:translate -- --trail ${TRAIL} (EN/ES) e npm run v3:publish -- --trail ${TRAIL}`);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
