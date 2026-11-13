/**
 * Publica as trilhas "capítulo a capítulo" (`admin/v3/<livro>-cap/trail.json`)
 * no catálogo: `content_trails/<slug>` e a cópia local do app
 * (`trilha_app/assets/data/trails.json`). Perguntas e estudos sobem antes,
 * pelo `v3:publish`; este script confere que estão lá.
 *
 *   node scripts/publish_cap_trails.mjs                      # todas, só mostra
 *   node scripts/publish_cap_trails.mjs --trails mateus-cap  # algumas
 *   node scripts/publish_cap_trails.mjs --apply              # grava
 *   node scripts/publish_cap_trails.mjs --apply --force      # sobrescreve doc existente
 *
 * Ordem: grava `order` = ORDER_OFFSET + order do plano. O app ordena a fila
 * do AT/NT por categoria e depois por `order`, e trava a trilha seguinte até
 * a anterior acabar. App antigo ignora `collection` e mantém as trilhas
 * antigas no AT/NT; com o mesmo `order`, uma `-cap` cairia no meio da fila
 * antiga e travaria quem está em Gênesis 12–50, Êxodo etc. Com o offset, a
 * `-cap` vem depois das antigas da mesma categoria. Quando as antigas forem
 * para o Panorama (set_trail_collection.mjs), só as `-cap` ficam na fila.
 */
import { createRequire } from 'module';
import { readdirSync, readFileSync, writeFileSync } from 'fs';
import { join } from 'path';
import { ADMIN_DIR, APP_DATA, argValue } from './_v3_paths.mjs';

const require = createRequire(import.meta.url);
const APPLY = process.argv.includes('--apply');
const FORCE = process.argv.includes('--force');
const ORDER_OFFSET = 100;

const V3 = join(ADMIN_DIR, 'v3');
const requested = (argValue('--trails') || '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);
const slugs = requested.length
  ? requested
  : readdirSync(V3).filter((d) => d.endsWith('-cap')).sort();

async function firestore() {
  const { Firestore } = await import('@google-cloud/firestore');
  const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
  const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');
  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) throw new Error('Firebase CLI não logado. Rode: firebase login --reauth');
  process.env.GOOGLE_APPLICATION_CREDENTIALS = await getCredentialPathAsync(account);
  return { db: new Firestore({ projectId: process.env.FIREBASE_PROJECT || 'trilha-biblia' }), Firestore };
}

function loadCapTrail(slug) {
  const trail = JSON.parse(readFileSync(join(V3, slug, 'trail.json'), 'utf8'));
  if (trail.slug !== slug) throw new Error(`${slug}/trail.json tem slug "${trail.slug}"`);
  const bank = JSON.parse(readFileSync(join(V3, slug, 'questions_v3.json'), 'utf8'));
  const questions = Array.isArray(bank) ? bank : Object.values(bank);
  return {
    trail: { ...trail, order: ORDER_OFFSET + trail.order },
    planOrder: trail.order,
    missionSlugs: trail.modules.flatMap((m) => m.missions.map((x) => x.slug)),
    localQuestions: questions.length,
  };
}

async function countIn(db, Firestore, collection, ids) {
  let n = 0;
  for (let i = 0; i < ids.length; i += 30) {
    const snap = await db
      .collection(collection)
      .where(Firestore.FieldPath.documentId(), 'in', ids.slice(i, i + 30))
      .count()
      .get();
    n += snap.data().count;
  }
  return n;
}

async function main() {
  const { db, Firestore } = await firestore();
  const catalogPath = join(APP_DATA, 'trails.json');
  const local = JSON.parse(readFileSync(catalogPath, 'utf8'));

  // Cena com slug repetido em outra trilha quebra progresso e estudos.
  const owner = new Map();
  for (const t of local) {
    if (slugs.includes(t.slug)) continue;
    for (const m of t.modules || []) for (const x of m.missions || []) owner.set(x.slug, t.slug);
  }

  const ready = [];
  let problems = 0;
  for (const slug of slugs) {
    const { trail, planOrder, missionSlugs, localQuestions } = loadCapTrail(slug);
    const issues = [];
    for (const s of missionSlugs) {
      if (owner.has(s)) issues.push(`cena ${s} já existe em ${owner.get(s)}`);
      owner.set(s, slug);
    }
    const questions = (
      await db.collection('content_bank_questions').where('trail', '==', slug).count().get()
    ).data().count;
    if (questions !== localQuestions) issues.push(`perguntas no Firestore ${questions}/${localQuestions}`);
    const studies = await countIn(db, Firestore, 'content_mission_studies', missionSlugs);
    if (studies !== missionSlugs.length) issues.push(`estudos no Firestore ${studies}/${missionSlugs.length}`);
    const exists = (await db.collection('content_trails').doc(slug).get()).exists;

    const tag = issues.length ? '✗' : exists && !FORCE ? '=' : '✓';
    console.log(
      `${tag} ${slug.padEnd(22)} ${trail.realm === 'novo-testamento' ? 'NT' : 'AT'} ${trail.category.padEnd(17)}` +
        ` order ${String(planOrder).padStart(2)}→${trail.order}  ${String(missionSlugs.length).padStart(3)} cenas` +
        `  ${String(questions).padStart(4)} perguntas${exists ? '  (já existe)' : ''}`,
    );
    for (const i of issues) console.log(`    ${i}`);
    if (issues.length) problems++;
    else ready.push({ trail, exists });
  }

  const toWrite = ready.filter((r) => !r.exists || FORCE);
  console.log(`\n${slugs.length} trilha(s): ${toWrite.length} para gravar, ${ready.length - toWrite.length} já existem, ${problems} com problema`);
  if (problems) {
    console.log('Corrija os ✗ antes de gravar.');
    process.exit(1);
  }
  if (!APPLY) {
    console.log('\nDry run. Para gravar: acrescente --apply');
    return;
  }

  for (let i = 0; i < toWrite.length; i += 20) {
    const batch = db.batch();
    for (const { trail } of toWrite.slice(i, i + 20)) {
      batch.set(db.collection('content_trails').doc(trail.slug), {
        ...trail,
        source: 'publish_cap_trails.mjs',
        updatedAt: Firestore.FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
  console.log(`✓ ${toWrite.length} trilha(s) em content_trails`);

  // Cópia local do catálogo: troca a entrada existente ou acrescenta.
  for (const { trail } of ready) {
    const at = local.findIndex((t) => t.slug === trail.slug);
    if (at >= 0) local[at] = trail;
    else local.push(trail);
  }
  writeFileSync(catalogPath, `${JSON.stringify(local, null, 2)}\n`);
  console.log(`✓ trails.json: ${ready.length} trilha(s)`);

  const version = Date.now();
  await db.collection('content_meta').doc('catalog').set(
    { version, seededAt: Firestore.FieldValue.serverTimestamp(), source: 'publish_cap_trails.mjs' },
    { merge: true },
  );
  console.log(`✓ catalog.version=${version}`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
