/**
 * Rebuild só Gênesis 1–11 + 12–50 (handcraft + gerador V2).
 *   node admin/scripts/build_genesis_v2.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { genesis111V2Packs } from './_genesis_111_v2_data.mjs';
import { genesis1250V2Packs } from './_genesis_1250_v2_data.mjs';
import { generateMissionV2, mergeMissionQuestions, DIFFICULTY_META } from './_v2_generator.mjs';
import { validateBank, formatReport } from './_bank_validator.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const dataRoot = join(__dirname, '..', '..', 'trilha_app', 'assets', 'data');
const file = join(dataRoot, 'genesis_questions.json');

const HANDCRAFTED = {
  'genesis-1-11': genesis111V2Packs,
  'genesis-12-50': genesis1250V2Packs,
};

const trails = JSON.parse(readFileSync(join(dataRoot, 'trails.json'), 'utf8'));
const studiesDoc = JSON.parse(readFileSync(join(dataRoot, 'mission_studies.json'), 'utf8'));
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

const pack = [];
const counts = {};

for (const trail of trails) {
  if (!HANDCRAFTED[trail.slug]) continue;
  const handcrafted = HANDCRAFTED[trail.slug]();
  const hcBySection = new Map();
  for (const q of handcrafted) {
    const list = hcBySection.get(q.section) || [];
    list.push(q);
    hcBySection.set(q.section, list);
  }
  let n = 0;
  for (const mission of missionsOf(trail)) {
    const study = studyFor(mission);
    const generated = generateMissionV2({ trail: trail.slug, mission, study, legacy: [] });
    const hcMission = hcBySection.get(mission.slug) || [];
    const merged = mergeMissionQuestions(hcMission, generated);
    pack.push(...merged);
    n += merged.length;
  }
  counts[trail.slug] = n;
}

const check = validateBank(pack);
console.log(formatReport(check));
if (!check.ok) {
  console.error('Abortando — banco Gênesis inválido.');
  process.exit(1);
}

const raw = JSON.parse(readFileSync(file, 'utf8'));
const out = { ...raw, difficulties: DIFFICULTY_META, questions: pack };
writeFileSync(file, `${JSON.stringify(out, null, 2)}\n`, 'utf8');

console.log('\n✓ genesis_questions.json');
for (const [slug, n] of Object.entries(counts)) console.log(`  ${slug}: ${n}`);
console.log(`  total: ${pack.length}`);
