/**
 * Só leitura: confere o versículo de entrada de todas as missões.
 * hookRef tem de ser uma referência única (um capítulo, faixa contínua,
 * até 2 versos) e hookVerse, o texto JFAAL dela.
 *
 *   node scripts/check_hooks.mjs            → lista os problemas
 *   node scripts/check_hooks.mjs --strict   → sai com 1 se houver problema
 */
import { existsSync, readFileSync, readdirSync } from 'fs';
import { join } from 'path';
import { ADMIN_DIR, APP_DATA } from './_v3_paths.mjs';
import { parseRef, passageText } from './_jfaal.mjs';

const norm = (s) => String(s || '').replace(/[“”"«»]/g, '"').replace(/\s+/g, ' ').trim();
const trails = JSON.parse(readFileSync(join(APP_DATA, 'trails.json'), 'utf8'));
const seen = new Set(trails.map((t) => t.slug));
const v3 = join(ADMIN_DIR, 'v3');
for (const d of existsSync(v3) ? readdirSync(v3) : []) {
  const p = join(v3, d, 'trail.json');
  if (!seen.has(d) && existsSync(p)) trails.push(JSON.parse(readFileSync(p, 'utf8')));
}

const problems = [];
for (const t of trails) {
  for (const mod of t.modules || []) {
    for (const m of mod.missions || []) {
      const where = `${t.slug}/${m.slug}`;
      const r = parseRef(m.hookRef);
      if (!r || r.start === null) { problems.push(`${where}: hookRef "${m.hookRef}" não é referência única`); continue; }
      if (r.end - r.start + 1 > 2) problems.push(`${where}: hookRef "${m.hookRef}" tem mais de 2 versos`);
      const live = passageText(m.hookRef);
      if (!live) problems.push(`${where}: hookRef "${m.hookRef}" não existe na JFAAL`);
      else if (norm(live) !== norm(m.hookVerse)) problems.push(`${where}: hookVerse ≠ JFAAL de ${m.hookRef} ("${String(m.hookVerse || '').slice(0, 40)}…")`);
    }
  }
}
for (const p of problems) console.log(`  ✗ ${p}`);
console.log(`${problems.length} problema(s) em ${trails.length} trilha(s)`);
if (problems.length && process.argv.includes('--strict')) process.exit(1);
