/**
 * Congela packs editoriais de Êxodo e Sermão (cobertura completa 6 gestos × 3 modos).
 * Fonte: gerador V2 + texto bíblico completo (não snippet com reticências).
 *
 *   node admin/scripts/author_handcraft_trails.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { generateMissionV2 } from './_v2_generator.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const dataRoot = join(__dirname, '..', '..', 'trilha_app', 'assets', 'data');

function readJson(name) {
  return JSON.parse(readFileSync(join(dataRoot, name), 'utf8'));
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
    }
  );
}

function missionsOf(trail) {
  return (trail.modules || []).flatMap((mod) => mod.missions || []);
}

function authorTrail(slug) {
  const trail = trails.find((t) => t.slug === slug);
  if (!trail) throw new Error(`trilha não encontrada: ${slug}`);
  const pack = [];
  for (const mission of missionsOf(trail)) {
    pack.push(
      ...generateMissionV2({
        trail: slug,
        mission,
        study: studyFor(mission),
        legacy: [],
      }),
    );
  }
  return pack;
}

const targets = [
  ['exodo', '_exodo_v2_data.json'],
  ['sermao-do-monte', '_sermao_v2_data.json'],
];

for (const [slug, file] of targets) {
  const pack = authorTrail(slug);
  writeFileSync(join(__dirname, file), `${JSON.stringify(pack, null, 2)}\n`);
  console.log(`${slug}: ${pack.length} atos → ${file}`);
}
