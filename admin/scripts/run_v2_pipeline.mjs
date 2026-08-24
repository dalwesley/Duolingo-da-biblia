/**
 * Pipeline V2: purge clones → Gênesis 1–11 V2 → repair → validate.
 *   node admin/scripts/run_v2_pipeline.mjs
 */
import { spawnSync } from 'child_process';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, '..');

function run(script, args = []) {
  const path = join(__dirname, script);
  console.log(`\n▶ node ${script} ${args.join(' ')}`.trim());
  const r = spawnSync('node', [path, ...args], { stdio: 'inherit', cwd: join(root, '..') });
  if (r.status !== 0) process.exit(r.status ?? 1);
}

run('purge_clones.mjs');
run('author_handcraft_trails.mjs');
run('build_all_trails_v2.mjs');
// repair_p0_p6 convertia gestos (tap→complete etc.) e quebrava a rotação 6 gestos.
run('repair_v2_metadata.mjs');
run('adapt_difficulty_verbs.mjs');
run('validate_bank.mjs');

console.log('\n✓ Pipeline V2 concluído.');
