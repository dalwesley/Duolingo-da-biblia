/**
 * Publica o piloto V3 de genesis-1-11 no Firestore (sessão do Firebase CLI).
 * Sempre salva backup do que está lá antes. Sem --apply, só simula.
 *
 *   node scripts/publish_pilot_v3.mjs            # simula + backup
 *   node scripts/publish_pilot_v3.mjs --apply    # backup + grava + sobe a versão do catálogo
 *
 * Perguntas: substitui o documento inteiro (sem merge), para não sobrar campo
 * antigo (ex.: `template` nos toques). Estudos: merge. Docs de genesis-1-11
 * que não existem no piloto são listados e só apagados com --delete-extras.
 */
import { createRequire } from 'module';
import { mkdirSync, readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { Firestore } from '@google-cloud/firestore';
import { validateBank, formatReport } from './_bank_validator.mjs';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const __dirname = dirname(fileURLToPath(import.meta.url));
const pilotDir = join(__dirname, '..', 'pilot', 'genesis-1-11');
const TRAIL = 'genesis-1-11';
const PROJECT = 'trilha-biblia';

const apply = process.argv.includes('--apply');
const deleteExtras = process.argv.includes('--delete-extras');

function sanitize(value) {
  if (value && typeof value.toDate === 'function') return value.toDate().toISOString();
  if (Array.isArray(value)) return value.map(sanitize);
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, sanitize(v)]));
  }
  return value;
}

async function main() {
  const questions = JSON.parse(readFileSync(join(pilotDir, 'questions_v3.json'), 'utf8'));
  const { studies } = JSON.parse(readFileSync(join(pilotDir, 'studies_v3.json'), 'utf8'));
  const report = validateBank(questions);
  if (!report.ok) {
    console.error(formatReport(report));
    throw new Error('Piloto não passa no validador do banco.');
  }

  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) throw new Error('Firebase CLI não logado. Rode: firebase login --reauth');
  process.env.GOOGLE_APPLICATION_CREDENTIALS = await getCredentialPathAsync(account);
  const db = new Firestore({ projectId: PROJECT });
  console.log(`Projeto ${PROJECT} · conta ${account.user?.email}`);

  // Backup do estado atual.
  const bankSnap = await db.collection('content_bank_questions').where('trail', '==', TRAIL).get();
  const slugs = Object.keys(studies);
  const studyDocs = await Promise.all(slugs.map((s) => db.collection('content_mission_studies').doc(s).get()));
  const meta = await db.collection('content_meta').doc('catalog').get();
  const backup = {
    takenAt: new Date().toISOString(),
    project: PROJECT,
    catalog: sanitize(meta.data() || null),
    questions: bankSnap.docs.map((d) => ({ id: d.id, ...sanitize(d.data()) })),
    studies: Object.fromEntries(studyDocs.filter((d) => d.exists).map((d) => [d.id, sanitize(d.data())])),
  };
  const backupDir = join(pilotDir, 'backup');
  mkdirSync(backupDir, { recursive: true });
  const backupPath = join(backupDir, `firestore-${backup.takenAt.replace(/[:.]/g, '-')}.json`);
  writeFileSync(backupPath, `${JSON.stringify(backup, null, 2)}\n`);
  console.log(`Backup: ${backupPath}`);
  console.log(`  Firestore hoje: ${backup.questions.length} perguntas de ${TRAIL}, ${Object.keys(backup.studies).length} estudos, catálogo v${backup.catalog?.version ?? '?'}`);

  const pilotIds = new Set(questions.map((q) => q.id));
  const existingIds = new Set(backup.questions.map((q) => q.id));
  const replaced = questions.filter((q) => existingIds.has(q.id)).length;
  const created = questions.length - replaced;
  const extras = backup.questions.filter((q) => !pilotIds.has(q.id)).map((q) => q.id);
  console.log(`  Piloto: ${questions.length} perguntas (${replaced} substituem, ${created} novas), ${slugs.length} estudos`);
  if (extras.length) {
    console.log(`  ! ${extras.length} pergunta(s) de ${TRAIL} no Firestore fora do piloto${deleteExtras ? ' — serão apagadas' : ' — ficam (use --delete-extras para apagar)'}:`);
    for (const id of extras.slice(0, 20)) console.log(`    - ${id}`);
  }

  if (!apply) {
    console.log('\nSimulação: nada foi gravado. Rode com --apply para publicar.');
    return;
  }

  const writes = [
    ...questions.map((q) => {
      const { id, ...data } = q;
      return (b) => b.set(db.collection('content_bank_questions').doc(id), { ...data, updatedAt: Firestore.FieldValue.serverTimestamp() });
    }),
    ...Object.entries(studies).map(([slug, s]) => (b) =>
      b.set(db.collection('content_mission_studies').doc(slug), { ...s, slug, updatedAt: Firestore.FieldValue.serverTimestamp() }, { merge: true })),
    ...(deleteExtras ? extras.map((id) => (b) => b.delete(db.collection('content_bank_questions').doc(id))) : []),
  ];
  for (let i = 0; i < writes.length; i += 200) {
    const batch = db.batch();
    writes.slice(i, i + 200).forEach((w) => w(batch));
    await batch.commit();
    console.log(`  … ${Math.min(i + 200, writes.length)}/${writes.length}`);
  }

  // Mesmo gatilho do painel admin: app vê versão nova e limpa o banco em cache.
  const version = (Number(meta.data()?.version) || 0) + 1;
  await db.collection('content_meta').doc('catalog').set({ version, updatedAt: Firestore.FieldValue.serverTimestamp() }, { merge: true });
  console.log(`\n✓ Publicado. Catálogo v${version}. Para desfazer: restaurar ${backupPath}`);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
