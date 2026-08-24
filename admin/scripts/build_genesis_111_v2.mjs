/**
 * Substitui perguntas de Gênesis 1–11 pelo banco editorial V2.
 *   node admin/scripts/build_genesis_111_v2.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { genesis111V2Packs } from './_genesis_111_v2_data.mjs';
import { validateBank, formatReport } from './_bank_validator.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const dataRoot = join(__dirname, '..', '..', 'trilha_app', 'assets', 'data');
const file = join(dataRoot, 'genesis_questions.json');

const GEN111 = 'genesis-1-11';
const GEN111_SECTIONS = new Set([
  'gen-01-criador',
  'gen-02-dias',
  'gen-03-imagem',
  'gen-04-descanso',
  'gen-05-eden',
  'gen-06-queda',
  'gen-07-consequencias',
  'gen-08-caim',
  'gen-09-diluvio',
  'gen-10-babel',
  'gen-11-abraao',
  'gen-boss-01',
  'gen-boss-02',
  'gen-boss-final',
]);

const v2 = genesis111V2Packs();
const check = validateBank(v2);
console.log(formatReport(check));
if (!check.ok) {
  console.error('Banco V2 inválido — abortando.');
  process.exit(1);
}

const raw = JSON.parse(readFileSync(file, 'utf8'));
const kept = (raw.questions || []).filter(
  (q) =>
    q.trail !== GEN111 &&
    q.trailSlug !== GEN111 &&
    !GEN111_SECTIONS.has(q.section),
);
const merged = [...kept, ...v2];
const out = { ...raw, questions: merged };
writeFileSync(file, `${JSON.stringify(out, null, 2)}\n`, 'utf8');
console.log(`\n✓ genesis_questions.json: ${v2.length} V2 + ${kept.length} mantidas = ${merged.length} total`);
