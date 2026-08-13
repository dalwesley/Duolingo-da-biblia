/**
 * Enriquece banco + trilhas para a "escola" (skills, profundezas, objectives).
 *
 * Usage:
 *   node admin/scripts/enrich_content.mjs
 *   node admin/scripts/enrich_content.mjs --only genesis
 *   node admin/scripts/enrich_content.mjs --force-skills
 */
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

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

function readJson(name) {
  return JSON.parse(readFileSync(join(dataRoot, name), 'utf8'));
}

function writeJson(name, data) {
  writeFileSync(join(dataRoot, name), `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

function clip(text, max) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  if (t.length <= max) return t;
  return `${t.slice(0, max - 1).trim()}…`;
}

function foldKey(s) {
  return (s || '')
    .normalize('NFD')
    .replace(/\p{M}/gu, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}

function isAuthoredGesture(q) {
  if (q.type === 'order' && Array.isArray(q.correctOrder) && q.correctOrder.length >= 3) {
    return true;
  }
  if (q.type === 'connect' && q.passageA && q.passageB) return true;
  const id = String(q.id || '');
  return /-(e0[0-9]|e[0-9]{2})$/i.test(id);
}

function skillFor(q) {
  const diff = q.difficulty || 'semente';
  const type = q.type || 'choice';

  if (type === 'connect') return 'connect';
  if (type === 'order') return diff === 'profundezas' ? 'synthesize' : 'understand';
  if (type === 'complete') return diff === 'profundezas' ? 'recall' : 'observe';
  if (type === 'tap' || type === 'find_in_text') return 'observe';

  if (type === 'true_false') {
    if (diff === 'profundezas') return 'interpret';
    if (diff === 'caminhada') return 'understand';
    return 'observe';
  }

  if (type === 'choice') {
    if (diff === 'profundezas') return 'interpret';
    if (diff === 'caminhada') return 'understand';
    return 'observe';
  }

  return 'understand';
}

function promptKey(q) {
  return foldKey(q.prompt || q.question || '');
}

function buildLowerPromptIndex(questions) {
  const bySection = new Map();
  for (const q of questions) {
    const diff = q.difficulty || 'semente';
    if (diff === 'profundezas') continue;
    const key = q.section || '';
    if (!bySection.has(key)) bySection.set(key, new Set());
    const pk = promptKey(q);
    if (pk.length >= 6) bySection.get(key).add(pk);
  }
  return bySection;
}

function deepenProfundezas(q, lowerPrompts) {
  if ((q.difficulty || 'semente') !== 'profundezas') return false;
  // Piloto / atos autorados: não reescrever copy.
  if (isAuthoredGesture(q)) return false;

  const section = q.section || '';
  const pk = promptKey(q);
  const prompt = (q.prompt || q.question || '').trim();
  if (!prompt) return false;

  // Clone de Semente: mesmo prompt OU skill/gesto ainda de observação rasa.
  const sameAsLower = Boolean(pk && lowerPrompts.get(section)?.has(pk));
  const shallowSkill = (q.skill || '') === 'observe';
  const shallowTap = q.type === 'tap' || q.type === 'find_in_text';
  if (!sameAsLower && !shallowSkill && !shallowTap) return false;

  const alreadyDeep =
    /^com evidência do texto/i.test(prompt) ||
    /^o que o texto sustenta/i.test(prompt) ||
    /^distinga texto e tradição/i.test(prompt) ||
    /^sintetize/i.test(prompt);
  if (alreadyDeep) {
    q.skill =
      q.type === 'connect'
        ? 'connect'
        : q.type === 'order'
          ? 'synthesize'
          : 'interpret';
    return true;
  }

  if (q.type === 'true_false') {
    const claim = prompt.replace(/\?\s*$/, '').trim();
    q.prompt = clip(
      `Distinga texto e tradição: é fiel ao versículo afirmar — ${claim}?`,
      160,
    );
    q.question = q.prompt;
    if ((q.cue || '').trim()) q.cue = q.prompt;
    q.skill = 'interpret';
    return true;
  }

  if (q.type === 'choice') {
    const lower = prompt.charAt(0).toLowerCase() + prompt.slice(1);
    q.prompt = clip(
      prompt.endsWith('?')
        ? `O que o texto sustenta — e o que não sustenta? ${lower}`
        : `Com evidência do texto: ${lower}`,
      160,
    );
    if ((q.cue || '').trim() === prompt || !(q.cue || '').trim()) q.cue = q.prompt;
    if ((q.question || '').trim() === prompt) q.question = q.prompt;
    q.skill = 'interpret';
    return true;
  }

  if (q.type === 'order') {
    q.prompt = clip(`Sintetize a lógica do trecho: ${prompt}`, 140);
    if ((q.cue || '').trim()) q.cue = q.prompt;
    q.skill = 'synthesize';
    return true;
  }

  if (q.type === 'complete') {
    q.prompt = clip('Complete com a leitura que o texto sustenta (não a tradição).', 120);
    q.skill = 'interpret';
    return true;
  }

  if (q.type === 'tap' || q.type === 'find_in_text') {
    q.prompt = clip(
      `Toque o trecho que decide a leitura — não a tradição: ${(q.question || prompt).slice(0, 60)}`,
      140,
    );
    q.cue = q.prompt;
    q.skill = 'interpret';
    return true;
  }

  if (q.type === 'connect') {
    q.prompt = clip(
      'Como as passagens se relacionam sem anular o primeiro texto?',
      120,
    );
    q.cue = q.prompt;
    q.skill = 'connect';
    return true;
  }

  q.skill = 'interpret';
  return true;
}

function tagSkills(questions, force) {
  let tagged = 0;
  for (const q of questions) {
    if (!force && (q.skill || '').trim()) continue;
    if (!force && isAuthoredGesture(q) && (q.skill || '').trim()) continue;
    const next = skillFor(q);
    if (q.skill !== next) {
      q.skill = next;
      tagged += 1;
    }
  }
  return tagged;
}

function stampObjectives(trails, studies) {
  let stamped = 0;
  let kept = 0;
  for (const trail of trails) {
    for (const mod of trail.modules || []) {
      for (const mission of mod.missions || []) {
        const existing = (mission.objective || '').trim();
        if (existing.length >= 8) {
          kept += 1;
          continue;
        }
        const study = studies[mission.slug];
        if (!study) continue;
        const fq = (study.focusQuestion || '').trim();
        if (fq.length >= 8) {
          mission.objective = clip(fq, 140);
          stamped += 1;
          continue;
        }
        const kw = (study.keyword || '').trim();
        if (kw.length >= 3) {
          mission.objective = clip(`Entender “${kw}” neste trecho.`, 140);
          stamped += 1;
        }
      }
    }
  }
  return { stamped, kept };
}

function parseOnlyFiles() {
  const idx = process.argv.findIndex((a) => a === '--only' || a.startsWith('--only='));
  if (idx < 0) return BANK_FILES;
  const raw = process.argv[idx].startsWith('--only=')
    ? process.argv[idx].slice('--only='.length)
    : process.argv[idx + 1] || '';
  const keys = raw
    .split(',')
    .map((s) => s.trim().toLowerCase())
    .filter(Boolean);
  if (!keys.length) return BANK_FILES;
  const map = {
    genesis: 'genesis_questions.json',
    exodo: 'exodo_questions.json',
    ot: 'ot_questions.json',
    nt: 'nt_questions.json',
    epistolas: 'epistolas_questions.json',
    sermao: 'sermao_questions.json',
    buracos: 'buracos_questions.json',
  };
  return keys.map((k) => map[k] || (k.endsWith('.json') ? k : `${k}_questions.json`));
}

function loadQuestions(file) {
  const raw = readJson(file);
  const wrapped = Array.isArray(raw);
  const questions = wrapped ? raw : raw.questions || [];
  return { raw, wrapped, questions };
}

function saveQuestions(file, raw, wrapped, questions) {
  if (wrapped) writeJson(file, questions);
  else writeJson(file, { ...raw, questions });
}

function main() {
  const forceSkills = process.argv.includes('--force-skills');
  const onlyFiles = parseOnlyFiles();
  const studies = readJson('mission_studies.json').studies || {};

  let totalSkills = 0;
  let totalDeepened = 0;
  let totalQuestions = 0;

  for (const file of onlyFiles) {
    const path = join(dataRoot, file);
    if (!existsSync(path)) {
      console.log(`skip ${file}`);
      continue;
    }
    const { raw, wrapped, questions } = loadQuestions(file);
    const lowerIdx = buildLowerPromptIndex(questions);

    let deepened = 0;
    for (const q of questions) {
      if (deepenProfundezas(q, lowerIdx)) deepened += 1;
    }

    const skills = tagSkills(questions, forceSkills);
    saveQuestions(file, raw, wrapped, questions);

    totalSkills += skills;
    totalDeepened += deepened;
    totalQuestions += questions.length;
    console.log(`✓ ${file}: ${questions.length} · skills +${skills} · profundezas ${deepened}`);
  }

  if (onlyFiles.length === BANK_FILES.length) {
    const trails = readJson('trails.json');
    const { stamped, kept } = stampObjectives(trails, studies);
    writeJson('trails.json', trails);
    console.log(`✓ trails.json: ${stamped} objectives · ${kept} já tinham`);
  }

  console.log(
    `total: ${totalQuestions} perguntas · skills ${totalSkills} · profundezas ${totalDeepened}`,
  );
}

main();
