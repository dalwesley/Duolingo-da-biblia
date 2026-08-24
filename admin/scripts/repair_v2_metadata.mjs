/**
 * Reparo P0 em bancos legados: skill por difficulty, dedup de stems, gabaritos órfãos.
 *   node admin/scripts/repair_v2_metadata.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { foldKey } from './_answer_phrase.mjs';
import { SKILL_BY_DIFFICULTY, validateBank, formatReport } from './_bank_validator.mjs';

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

const DEFAULT_SKILL = {
  semente: 'observe',
  caminhada: 'understand',
  profundezas: 'interpret',
};

function stemOf(q) {
  return (q.prompt || q.question || '').replace(/\s+/g, ' ').trim();
}

function readJson(name) {
  return JSON.parse(readFileSync(join(dataRoot, name), 'utf8'));
}
function writeJson(name, data) {
  writeFileSync(join(dataRoot, name), `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

let skillFixed = 0;
let deduped = 0;
let answerFixed = 0;

for (const file of BANK_FILES) {
  const raw = readJson(file);
  const questions = Array.isArray(raw) ? raw : raw.questions || [];
  const seen = new Set();
  const kept = [];

  for (const q of questions) {
    const diff = q.difficulty || 'semente';
    const allowed = SKILL_BY_DIFFICULTY[diff];
    if (allowed && q.skill && !allowed.has(q.skill)) {
      q.skill = DEFAULT_SKILL[diff] || 'observe';
      skillFixed += 1;
    } else if (!q.skill && DEFAULT_SKILL[diff]) {
      q.skill = DEFAULT_SKILL[diff];
      skillFixed += 1;
    }

    const stem = foldKey(stemOf(q));
    const key = `${q.trail || q.trailSlug || ''}|${q.section}|${diff}|${stem}`;
    if (stem.length >= 10 && seen.has(key)) {
      deduped += 1;
      continue;
    }
    if (stem.length >= 10) seen.add(key);

    const t = String(q.type || 'choice').toLowerCase();
    if (t === 'true_false') {
      const a = String(q.correctAnswer || q.correctOptionId || '').toLowerCase();
      if (a !== 'true' && a !== 'false') {
        q.correctAnswer = 'true';
        q.correctOptionId = 'true';
        answerFixed += 1;
      }
    } else if (t !== 'order' && t !== 'complete') {
      const cid = String(q.correctOptionId || q.correctAnswer || '').trim();
      const opts = (q.options || []).filter((o) => (o.text || '').trim());
      if (cid && !opts.some((o) => String(o.id) === cid) && opts[0]) {
        q.correctOptionId = opts[0].id;
        q.correctAnswer = opts[0].id;
        answerFixed += 1;
      }
    }

    kept.push(q);
  }

  if (Array.isArray(raw)) writeJson(file, kept);
  else writeJson(file, { ...raw, questions: kept });
}

console.log(`skill corrigido: ${skillFixed}`);
console.log(`stems duplicados removidos: ${deduped}`);
console.log(`gabaritos reparados: ${answerFixed}`);

const all = [];
for (const file of BANK_FILES) {
  const raw = readJson(file);
  all.push(...(Array.isArray(raw) ? raw : raw.questions || []));
}
const report = validateBank(all);
console.log('\n' + formatReport(report));
process.exit(report.ok ? 0 : 1);
