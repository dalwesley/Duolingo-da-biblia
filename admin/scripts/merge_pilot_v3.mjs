/**
 * Junta <pasta da trilha>/cenas/*.json em studies_v3.json + questions_v3.json.
 * Não toca trilha_app/assets/data nem o Firestore.
 *   node admin/scripts/merge_pilot_v3.mjs [--trail <slug>]
 */
import { readdirSync, readFileSync, writeFileSync } from 'fs';
import { join } from 'path';
import { argValue, trailDir } from './_v3_paths.mjs';

const pilotDir = trailDir(argValue('--trail') || 'genesis-1-11');
const cenaDir = join(pilotDir, 'cenas');

const studies = {};
const questions = [];
for (const file of readdirSync(cenaDir).filter((f) => f.endsWith('.json')).sort()) {
  const { study, questions: qs } = JSON.parse(readFileSync(join(cenaDir, file), 'utf8'));
  studies[study.slug] = study;
  questions.push(...qs);
}

writeFileSync(join(pilotDir, 'studies_v3.json'), `${JSON.stringify({ studies }, null, 2)}\n`);
writeFileSync(join(pilotDir, 'questions_v3.json'), `${JSON.stringify(questions, null, 2)}\n`);
console.log(`✓ ${Object.keys(studies).length} estudos · ${questions.length} perguntas`);
