/**
 * Insere cenas novas nas trilhas finas e grava perguntas + estudos.
 * Idempotente: se o slug já existe, só atualiza perguntas e estudo.
 *
 *   node admin/scripts/apply_weak_scenes.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { PACKS } from './_weak_scenes_data.mjs';
import { validateBank, formatReport } from './_bank_validator.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const dataRoot = join(__dirname, '..', '..', 'trilha_app', 'assets', 'data');
const v2Root = join(__dirname, '..', '..', 'perguntas-v2');

const BANK_FILE = {
  ot: 'ot_questions.json',
  epistolas: 'epistolas_questions.json',
};

function readJson(path) {
  return JSON.parse(readFileSync(path, 'utf8'));
}

function writeJson(path, data) {
  writeFileSync(path, `${JSON.stringify(data, null, 2)}\n`);
}

const questions = PACKS.flatMap((pack) => pack.built.flatMap((item) => item.questions));
const report = validateBank(questions);
console.log(formatReport(report));
if (!report.ok) {
  console.error('Abortando: perguntas novas não passaram no validador.');
  process.exit(1);
}

const trails = readJson(join(dataRoot, 'trails.json'));
const studiesDoc = readJson(join(dataRoot, 'mission_studies.json'));
const banks = {};

function bankOf(name) {
  if (!banks[name]) banks[name] = readJson(join(dataRoot, name));
  return banks[name];
}

function allMissions(trail) {
  return (trail.modules || []).flatMap((mod) => mod.missions || []);
}

for (const pack of PACKS) {
  const trail = trails.find((item) => item.slug === pack.trail);
  if (!trail) throw new Error(`trilha ausente: ${pack.trail}`);
  const slugs = new Set(allMissions(trail).map((mission) => mission.slug));
  const fresh = pack.built.map((item) => item.mission);
  const missing = fresh.filter((mission) => !slugs.has(mission.slug));
  if (missing.length && missing.length !== fresh.length) {
    throw new Error(`${pack.trail}: inserção parcial de cenas`);
  }
  if (missing.length === fresh.length) {
    const lastMod = trail.modules[trail.modules.length - 1];
    const last = lastMod.missions[lastMod.missions.length - 1];
    if (!last || last.type !== 'boss') {
      throw new Error(`${pack.trail}: a travessia não está no fim`);
    }
    const boss = lastMod.missions.pop();
    const created = {
      title: pack.module.title,
      icon: pack.module.icon,
      section: pack.module.section,
      missions: pack.place === 'before-last' ? fresh : [...fresh, boss],
    };
    if (pack.place === 'before-last') {
      lastMod.missions.push(boss);
      trail.modules.splice(trail.modules.length - 1, 0, created);
    } else {
      trail.modules.push(created);
    }
    console.log(`${pack.trail}: +${fresh.length} cenas`);
  } else {
    console.log(`${pack.trail}: cenas já estavam no mapa; perguntas atualizadas`);
  }

  for (const item of pack.built) {
    studiesDoc.studies[item.mission.slug] = item.study;
  }

  const file = BANK_FILE[pack.bank];
  const bank = bankOf(file);
  const sections = new Set(fresh.map((mission) => mission.slug));
  bank.questions = bank.questions.filter((question) => !sections.has(question.section));
  bank.questions.push(...pack.built.flatMap((item) => item.questions));

  const v2Path = join(v2Root, `${pack.trail}.json`);
  const v2 = readJson(v2Path);
  if (!Array.isArray(v2)) throw new Error(`perguntas-v2/${pack.trail}.json não é lista`);
  const kept = v2.filter((question) => !sections.has(question.section));
  writeJson(v2Path, [...kept, ...pack.built.flatMap((item) => item.questions)]);
}

writeJson(join(dataRoot, 'trails.json'), trails);
writeJson(join(dataRoot, 'mission_studies.json'), studiesDoc);
for (const [name, bank] of Object.entries(banks)) {
  writeJson(join(dataRoot, name), bank);
  console.log(`${name}: ${bank.questions.length} perguntas`);
}

const totalScenes = PACKS.reduce((sum, pack) => sum + pack.built.length, 0);
console.log(`Pronto: ${totalScenes} cenas em ${PACKS.length} trilhas.`);
