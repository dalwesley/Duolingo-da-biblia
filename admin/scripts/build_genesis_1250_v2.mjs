/**
 * Substitui perguntas de Gênesis 12–50 pelo banco editorial V2 em ot_questions.json.
 *   node admin/scripts/build_genesis_1250_v2.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { genesis1250V2Packs } from './_genesis_1250_v2_data.mjs';
import { validateBank, formatReport } from './_bank_validator.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const dataRoot = join(__dirname, '..', '..', 'trilha_app', 'assets', 'data');
const file = join(dataRoot, 'ot_questions.json');

const TRAIL = 'genesis-12-50';
const SECTIONS = new Set([
  'gen12-01-chamado',
  'gen12-02-egito-e-lot',
  'gen12-03-melquisedeque',
  'gen12-04-alianca-estrelas',
  'gen12-05-agar-ismael',
  'gen12-06-circuncisao',
  'gen12-07-sodoma',
  'gen12-08-isaque-nasce',
  'gen12-09-moria',
  'gen12-boss-abraao',
  'gen12-10-rebeca',
  'gen12-11-esaue-jaco',
  'gen12-12-betel',
  'gen12-13-labao',
  'gen12-14-peniel',
  'gen12-boss-jaco',
  'gen12-15-sonhos',
  'gen12-16-potifar',
  'gen12-17-farao',
  'gen12-18-irmaos',
  'gen12-19-revelacao',
  'gen12-20-egito-bencao',
  'gen12-boss-jose',
]);

const v2 = genesis1250V2Packs();
const check = validateBank(v2);
console.log(formatReport(check));
if (!check.ok) {
  console.error('Banco V2 inválido — abortando.');
  process.exit(1);
}

const raw = JSON.parse(readFileSync(file, 'utf8'));
const kept = (raw.questions || []).filter(
  (q) =>
    q.trail !== TRAIL &&
    q.trailSlug !== TRAIL &&
    !SECTIONS.has(q.section),
);
const merged = [...kept, ...v2];
writeFileSync(file, `${JSON.stringify({ ...raw, questions: merged }, null, 2)}\n`, 'utf8');
console.log(`\n✓ ot_questions.json: ${v2.length} V2 + ${kept.length} mantidas = ${merged.length} total`);
