/**
 * Valida bancos locais contra regras pedagógicas V2.
 *   node admin/scripts/validate_bank.mjs [--strict] [arquivo.json ...]
 */
import { readFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { validateBank, formatReport } from './_bank_validator.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const dataRoot = join(__dirname, '..', '..', 'trilha_app', 'assets', 'data');

const DEFAULT_FILES = [
  'genesis_questions.json',
  'exodo_questions.json',
  'ot_questions.json',
  'nt_questions.json',
  'epistolas_questions.json',
  'sermao_questions.json',
  'buracos_questions.json',
];

const args = process.argv.slice(2);
const strict = args.includes('--strict');
const files = args.filter((a) => !a.startsWith('--'));

let failed = false;
for (const file of files.length ? files : DEFAULT_FILES) {
  const path = file.includes('/') ? file : join(dataRoot, file);
  if (!existsSync(path)) {
    console.warn(`skip: ${path}`);
    continue;
  }
  const raw = JSON.parse(readFileSync(path, 'utf8'));
  const questions = Array.isArray(raw) ? raw : raw.questions || [];
  const result = validateBank(questions, { strict });
  console.log(`\n=== ${file} ===`);
  console.log(formatReport(result));
  if (!result.ok) failed = true;
}

process.exit(failed ? 1 : 0);
