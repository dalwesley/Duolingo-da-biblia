/**
 * Validador do banco V3. Confere estudo e perguntas contra a JFAAL e contra a
 * matriz gesto × modo de admin/pilot/genesis-1-11/SPEC_V3.md.
 *
 *   node admin/scripts/validate_pilot_v3.mjs                       # cenas do piloto genesis-1-11
 *   node admin/scripts/validate_pilot_v3.mjs --trail mateus        # cenas de admin/v3/mateus
 *   node admin/scripts/validate_pilot_v3.mjs cenas/gen-01-criador.json ...
 *
 * Também é importável: `validateCenaData(data, slug, { trail, final })`.
 */
import { existsSync, readdirSync, readFileSync } from 'fs';
import { basename, join, resolve } from 'path';
import { pathToFileURL } from 'url';
import { parseRef, passageText, verseCount } from './_jfaal.mjs';
import { argValue, trailDir } from './_v3_paths.mjs';
import { createV3Validator } from './_v3_rules.mjs';

export const { validateCenaData } = createV3Validator({ parseRef, passageText, verseCount });

let TRAIL = 'genesis-1-11';
let FINAL = false;

function validateCena(path) {
  const slug = basename(path, '.json');
  let data;
  try {
    data = JSON.parse(readFileSync(path, 'utf8'));
  } catch (e) {
    return { slug, errors: [`JSON inválido: ${e.message}`], warnings: [], trueCount: 0, tfCount: 0 };
  }
  return validateCenaData(data, slug, { trail: TRAIL, final: FINAL });
}

function main() {
TRAIL = argValue('--trail') || 'genesis-1-11';
FINAL = process.argv.includes('--final');
const pilotDir = trailDir(TRAIL);
const args = process.argv.slice(2).filter((a, i, all) => !a.startsWith('--') && all[i - 1] !== '--trail');
const cenaDir = join(pilotDir, 'cenas');
const files = args.length
  ? args.map((a) => (existsSync(a) ? resolve(a) : join(pilotDir, a)))
  : existsSync(cenaDir)
    ? readdirSync(cenaDir).filter((f) => f.endsWith('.json')).sort().map((f) => join(cenaDir, f))
    : [];

let failed = false;
let T = 0;
let N = 0;
for (const f of files) {
  const r = validateCena(f);
  T += r.trueCount;
  N += r.tfCount;
  const status = r.errors.length ? 'FALHOU' : 'ok';
  console.log(`\n=== ${r.slug}: ${status} (${r.errors.length} erros, ${r.warnings.length} avisos · V/F verdadeiras ${r.trueCount}/${r.tfCount})`);
  for (const e of r.errors) console.log(`  ✗ ${e}`);
  for (const w of r.warnings) console.log(`  ! ${w}`);
  if (r.errors.length) failed = true;
}
if (files.length > 1 && N) {
  const pct = Math.round((T / N) * 100);
  console.log(`\nV/F verdadeiras na trilha: ${T}/${N} (${pct}%) — alvo 45–55%`);
  if (pct < 45 || pct > 55) console.log('  ! fora do alvo de equilíbrio');
}
console.log(failed ? '\n✗ Validação falhou.' : `\n✓ ${files.length} cena(s) válidas.`);
process.exit(failed ? 1 : 0);
}

if (import.meta.url === pathToFileURL(process.argv[1] || '').href) main();
