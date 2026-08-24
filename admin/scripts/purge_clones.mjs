/**
 * Remove perguntas clone (-xch, -xfill, etc.) de todos os bancos locais.
 *   node admin/scripts/purge_clones.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { CLONE_ID } from './_bank_validator.mjs';

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

let totalRemoved = 0;
for (const file of BANK_FILES) {
  const raw = readJson(file);
  const questions = Array.isArray(raw) ? raw : raw.questions || [];
  const kept = questions.filter((q) => !CLONE_ID.test(String(q.id || '')));
  const removed = questions.length - kept.length;
  if (removed) {
    if (Array.isArray(raw)) {
      writeJson(file, kept);
    } else {
      writeJson(file, { ...raw, questions: kept });
    }
    console.log(`${file}: -${removed} clones (${kept.length} restantes)`);
    totalRemoved += removed;
  } else {
    console.log(`${file}: ok (${kept.length})`);
  }
}
console.log(`\nTotal removido: ${totalRemoved}`);
