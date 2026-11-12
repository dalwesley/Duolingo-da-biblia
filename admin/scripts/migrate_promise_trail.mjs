/**
 * Leva A Promessa (trilha costurada) do código do app para o Firestore:
 *
 *   - `content_trails/a-promessa` em português: 4 etapas, 12 cenas
 *     emprestadas (cada uma com `bankTrailSlug` + `bankSection` da cena de
 *     origem) e a travessia final `promessa-sintese`;
 *   - as 3 perguntas da travessia em `content_bank_questions`
 *     (antes montadas no app), com o texto JFAAL dos dois trechos;
 *   - inglês e espanhol nos overlays do app (trails_*.json, questions_*.json).
 *
 * Fonte: curated_trails.dart no HEAD do git + app_*.arb.
 *
 *   node scripts/migrate_promise_trail.mjs            # só mostra
 *   node scripts/migrate_promise_trail.mjs --apply    # grava
 */
import { execFileSync } from 'child_process';
import { createRequire } from 'module';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { passageText } from './_jfaal.mjs';

const require = createRequire(import.meta.url);
const __dirname = dirname(fileURLToPath(import.meta.url));
const repo = join(__dirname, '..', '..');
const app = join(repo, 'trilha_app');
const APPLY = process.argv.includes('--apply');
const FORCE = process.argv.includes('--force');

const SLUG = 'a-promessa';
const SYNTH = 'promessa-sintese';
const arb = (lang) => JSON.parse(readFileSync(join(app, `lib/l10n/app_${lang}.arb`), 'utf8'));
const ARB = { pt: arb('pt'), en: arb('en'), es: arb('es') };
const t = (key, lang) => {
  const s = ARB[lang][key];
  if (s === undefined) throw new Error(`Chave ${key} sem texto em app_${lang}.arb`);
  return s;
};

/** `campo: valor` de um trecho Dart: l.chave, 'texto', número ou bool. */
function fields(chunk) {
  const out = {};
  const re = /(\w+):\s*(l\.(\w+)|'((?:[^'\\]|\\.)*)'|(-?\d+)|(true|false)|(\w+))\s*,/g;
  let m;
  while ((m = re.exec(chunk))) {
    const [, key, , l10n, str, num, bool, ident] = m;
    if (key in out) continue;
    if (l10n) out[key] = { l10n };
    else if (str !== undefined) out[key] = str.replace(/\\'/g, "'");
    else if (num !== undefined) out[key] = Number(num);
    else if (bool !== undefined) out[key] = bool === 'true';
    else out[key] = { ident };
  }
  return out;
}
const val = (v, lang) => (v && typeof v === 'object' && v.l10n ? t(v.l10n, lang) : v);

function parse() {
  const src = execFileSync('git', ['show', 'HEAD:trilha_app/lib/data/curated_trails.dart'], { cwd: repo, encoding: 'utf8' });
  const origins = Object.fromEntries([...src.matchAll(/'(promessa-\d+)': '([^']+)'/g)].map((m) => [m[1], m[2]]));
  const pairs = [...src.matchAll(/\('([^']+)', '([^']+)', '([abc])'\)/g)].map((m) => ({ a: m[1], b: m[2], correct: m[3] }));
  const body = src.slice(src.indexOf('static Trail get _promise'));
  const [head, ...mods] = body.split(/\bTrailModule\(/);
  const trail = fields(head);
  const modules = mods.map((chunk) => {
    const [modHead, ...rest] = chunk.split(/\b_scene\(|\bMission\(/);
    const missions = rest.map((sc) => {
      const pos = sc.match(/^\s*'([^']+)'/);
      const f = fields(sc);
      return pos ? { slug: pos[1], ...f } : { ...f, slug: SYNTH };
    });
    return { ...fields(modHead), missions };
  });
  return { origins, pairs, trail, modules };
}

function build(lang, { origins, trail, modules }) {
  return {
    slug: SLUG,
    title: val(trail.title, lang),
    description: val(trail.description, lang),
    icon: trail.icon,
    order: trail.order ?? 1,
    comingSoon: false,
    color: trail.color,
    realm: trail.realmId,
    category: trail.categoryId,
    isActive: true,
    modules: modules.map((mod) => ({
      title: val(mod.title, lang),
      icon: mod.icon,
      missions: mod.missions.map((m) => {
        if (m.slug === SYNTH) {
          return {
            slug: SYNTH, type: 'boss', stepsReward: 90, title: val(m.title, lang), intro: val(m.intro, lang),
            hookRef: m.hookRef, hookNote: val(m.hookNote, lang), bankSection: SYNTH, bankTrailSlug: SLUG,
          };
        }
        if (!origins[m.slug]) throw new Error(`${m.slug} sem cena de origem`);
        return {
          slug: m.slug, type: 'lesson', stepsReward: 60, title: val(m.title, lang), intro: val(m.intro, lang),
          hookRef: m.ref, hookNote: val(m.note, lang), bankSection: origins[m.slug], bankTrailSlug: m.trail,
        };
      }),
    })),
  };
}

const qId = (i) => `${SLUG}-pro-${SYNTH}-0${i + 1}`;
const WRONG = [['b', 'c'], ['a', 'c'], ['a', 'b']];

function synthQuestion(i, pair, lang) {
  const n = i + 1;
  const q = t(`promiseTrailQ${n}Question`, lang);
  return {
    question: q,
    prompt: q,
    cue: q,
    options: ['A', 'B', 'C'].map((o) => ({ id: o.toLowerCase(), text: t(`promiseTrailQ${n}${o}`, lang) })),
    feedbackCorrect: t(`promiseTrailQ${n}Correct`, lang),
    feedbackWrong: Object.fromEntries(WRONG[i].map((w) => [w, t(`promiseTrailQ${n}Wrong${w.toUpperCase()}`, lang)])),
    hint: t(`promiseTrailQ${n}Hint`, lang),
    learningObjective: t('promiseTrailSynthObjective', lang),
    correct: pair.correct,
  };
}

function questionDoc(i, pair) {
  const { correct, ...q } = synthQuestion(i, pair, 'pt');
  const textA = passageText(pair.a) || '';
  const textB = passageText(pair.b) || '';
  if (!textA || !textB) throw new Error(`Sem texto JFAAL para ${pair.a} ou ${pair.b}`);
  return {
    ...q,
    trail: SLUG,
    section: SYNTH,
    difficulty: 'profundezas',
    type: 'connect',
    skill: 'interpret',
    verseRef: pair.a,
    passageText: textA,
    passageA: { ref: pair.a, text: textA },
    passageB: { ref: pair.b, text: textB },
    correctOptionId: correct,
    correctAnswer: correct,
    evidence: [pair.a, pair.b],
  };
}

function mergeJson(path, mutate) {
  const cur = existsSync(path) ? JSON.parse(readFileSync(path, 'utf8')) : {};
  mutate(cur);
  if (APPLY) writeFileSync(path, `${JSON.stringify(cur, null, 2)}\n`);
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
  const parsed = parse();
  if (parsed.pairs.length !== 3) throw new Error(`Esperava 3 pares da travessia, achei ${parsed.pairs.length}`);
  const doc = build('pt', parsed);
  const scenes = doc.modules.flatMap((m) => m.missions);
  if (scenes.length !== 13) throw new Error(`Esperava 13 cenas (12 + travessia), achei ${scenes.length}`);
  for (const mod of doc.modules) {
    console.log(`${mod.title}: ${mod.missions.map((m) => `${m.title} ← ${m.bankTrailSlug}/${m.bankSection}`).join(' · ')}`);
  }
  for (const s of scenes) {
    const missing = ['title', 'intro', 'hookRef', 'hookNote'].filter((k) => !s[k]);
    if (missing.length) throw new Error(`${s.slug} sem ${missing.join(', ')}`);
  }
  const questions = parsed.pairs.map((p, i) => [qId(i), questionDoc(i, p)]);
  for (const [id, q] of questions) console.log(`pergunta ${id}: ${q.passageA.ref} ↔ ${q.passageB.ref} (certa ${q.correctOptionId})`);

  for (const lang of ['en', 'es']) {
    const tr = build(lang, parsed);
    mergeJson(join(app, `assets/l10n/content/trails_${lang}.json`), (o) => {
      o.trails = { ...(o.trails || {}), [SLUG]: { title: tr.title, description: tr.description } };
      o.modules = { ...(o.modules || {}) };
      o.missions = { ...(o.missions || {}) };
      tr.modules.forEach((mod, i) => {
        o.modules[`${SLUG}:${i}`] = { title: mod.title };
        for (const m of mod.missions) o.missions[m.slug] = { title: m.title, intro: m.intro, hookNote: m.hookNote };
      });
    });
    mergeJson(join(app, `assets/l10n/content/questions_${lang}.json`), (o) => {
      parsed.pairs.forEach((p, i) => {
        const { correct, options, ...q } = synthQuestion(i, p, lang);
        o[qId(i)] = { ...q, options: Object.fromEntries(options.map((x) => [x.id, x.text])) };
      });
    });
    console.log(`overlay ${lang}: 13 cenas + 3 perguntas${APPLY ? ' gravadas' : ''}`);
  }

  if (!APPLY) {
    console.log('\nDry run. Para gravar: node scripts/migrate_promise_trail.mjs --apply');
    return;
  }
  const { db, Firestore } = await firestore();
  const ref = db.collection('content_trails').doc(SLUG);
  if ((await ref.get()).exists && !FORCE) {
    console.log(`= ${SLUG} já existe em content_trails (use --force para sobrescrever)`);
  } else {
    await ref.set({ ...doc, updatedAt: Firestore.FieldValue.serverTimestamp() });
    console.log(`✓ content_trails/${SLUG}`);
  }
  const batch = db.batch();
  for (const [id, q] of questions) {
    batch.set(db.collection('content_bank_questions').doc(id), { ...q, updatedAt: Firestore.FieldValue.serverTimestamp() }, { merge: true });
  }
  await batch.commit();
  console.log(`✓ ${questions.length} perguntas da travessia`);
  const version = Date.now();
  await db.collection('content_meta').doc('catalog').set(
    { version, seededAt: Firestore.FieldValue.serverTimestamp(), source: 'migrate_promise_trail.mjs' },
    { merge: true },
  );
  console.log(`✓ catalog.version=${version}`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
