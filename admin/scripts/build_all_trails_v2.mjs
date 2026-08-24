/**
 * Reescreve TODAS as trilhas no padrão V2.
 * Gênesis 1–11 e 12–50 usam bancos editoriais handcrafted.
 *
 *   node admin/scripts/build_all_trails_v2.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { genesis111V2Packs } from './_genesis_111_v2_data.mjs';
import { genesis1250V2Packs } from './_genesis_1250_v2_data.mjs';
import { exodoV2Packs } from './_exodo_v2_data.mjs';
import { sermaoV2Packs } from './_sermao_v2_data.mjs';
import { generateMissionV2, mergeMissionQuestions, dedupeCrossModeGestures, DIFFICULTY_META } from './_v2_generator.mjs';
import { validateBank, formatReport } from './_bank_validator.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const dataRoot = join(__dirname, '..', '..', 'trilha_app', 'assets', 'data');

const BANK_FILES = [
  'genesis_questions.json',
  'exodo_questions.json',
  'ot_questions.json',
  'nt_questions.json',
  'epistolas_questions.json',
  'sermao_questions.json',
  'buracos_questions.json',
];

const HANDCRAFTED = {
  'genesis-1-11': genesis111V2Packs,
  'genesis-12-50': genesis1250V2Packs,
  exodo: exodoV2Packs,
  'sermao-do-monte': sermaoV2Packs,
};

function readJson(name) {
  return JSON.parse(readFileSync(join(dataRoot, name), 'utf8'));
}
function writeJson(name, data) {
  writeFileSync(join(dataRoot, name), `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

const trails = readJson('trails.json');
const studiesDoc = readJson('mission_studies.json');
const studies = studiesDoc.studies || studiesDoc;

function studyFor(mission) {
  return (
    studies[mission.slug] || {
      passageRef: mission.hookRef || '',
      passageText: mission.hookVerse || '',
      context: mission.hookNote || mission.intro || '',
      keyword: mission.title?.split(' ').slice(0, 2).join(' ') || 'Deus',
      keywordGloss: mission.centralInsight || mission.objective || '',
      focusQuestion: mission.objective || '',
      reflectionPrompts: [mission.centralInsight].filter(Boolean),
    }
  );
}

function missionsOf(trail) {
  return (trail.modules || []).flatMap((mod) => mod.missions || []);
}

const trailToFile = new Map();
for (const file of BANK_FILES) {
  for (const q of readJson(file).questions || []) {
    const t = q.trail || q.trailSlug;
    if (t) trailToFile.set(t, file);
  }
}

const allV2 = [];
const trailCounts = {};

for (const trail of trails) {
  const slug = trail.slug;
  if (HANDCRAFTED[slug]) {
    const handcrafted = HANDCRAFTED[slug]();
    const hcBySection = new Map();
    for (const q of handcrafted) {
      const list = hcBySection.get(q.section) || [];
      list.push(q);
      hcBySection.set(q.section, list);
    }
    const pack = [];
    for (const mission of missionsOf(trail)) {
      const study = studyFor(mission);
      const generated = generateMissionV2({ trail: slug, mission, study, legacy: [] });
      const hcMission = hcBySection.get(mission.slug) || [];
      pack.push(...mergeMissionQuestions(hcMission, generated));
    }
    allV2.push(...pack);
    trailCounts[slug] = pack.length;
    continue;
  }

  let count = 0;
  for (const mission of missionsOf(trail)) {
    const study = studyFor(mission);
    const qs = generateMissionV2({ trail: slug, mission, study, legacy: [] });
    allV2.push(...qs);
    count += qs.length;
  }
  trailCounts[slug] = count;
}

console.log(`Geradas ${allV2.length} perguntas V2 · ${trails.length} trilhas`);

dedupeCrossModeGestures(allV2);

const check = validateBank(allV2);
console.log(formatReport(check));
if (!check.ok) {
  console.error('\nAbortando.');
  process.exit(1);
}

const byFile = new Map(BANK_FILES.map((f) => [f, []]));
for (const q of allV2) {
  const file = trailToFile.get(q.trail) || 'buracos_questions.json';
  byFile.get(file).push(q);
}

for (const file of BANK_FILES) {
  const raw = readJson(file);
  const v2ForFile = byFile.get(file) || [];
  writeJson(file, { ...raw, difficulties: DIFFICULTY_META, questions: v2ForFile });
  const trailSlugs = new Set(v2ForFile.map((q) => q.trail));
  console.log(`✓ ${file}: ${v2ForFile.length} perguntas · ${trailSlugs.size} trilhas`);
}

console.log('\nResumo:', Object.values(trailCounts).reduce((a, b) => a + b, 0), 'perguntas');
