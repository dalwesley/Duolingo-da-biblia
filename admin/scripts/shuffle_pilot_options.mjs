/**
 * Embaralha as opções das cenas V3 de forma estável (semente = id da pergunta).
 * Completar e Conectar aparecem no app na ordem gravada — sem isto, a certa
 * seria sempre o primeiro botão. Reatribui ids a,b,c(,d) e ajusta
 * correctOptionId, correctAnswer e as chaves de feedbackWrong.
 *   node admin/scripts/shuffle_pilot_options.mjs [--trail <slug>] [cenas/<slug>.json ...]
 */
import { existsSync, readdirSync, readFileSync, writeFileSync } from 'fs';
import { join, resolve } from 'path';
import { argValue, trailDir } from './_v3_paths.mjs';

const pilotDir = trailDir(argValue('--trail') || 'genesis-1-11');
const cenaDir = join(pilotDir, 'cenas');
const TYPES = new Set(['choice', 'complete', 'connect', 'find_in_text']);

function seeded(str) {
  let h = 2166136261;
  for (const ch of str) h = Math.imul(h ^ ch.codePointAt(0), 16777619);
  return () => {
    h = Math.imul(h ^ (h >>> 15), 2246822507);
    h = Math.imul(h ^ (h >>> 13), 3266489909);
    return ((h ^= h >>> 16) >>> 0) / 4294967296;
  };
}

function shuffleQuestion(q, salt = '') {
  if (!TYPES.has(q.type) || !Array.isArray(q.options) || q.options.length < 2) return false;
  // Inclui texto da certa + salt opcional: alguns slugs fazem todos os
  // Completar/Conectar caírem em "a" com semente só do id.
  const right = (q.options || []).find((o) => o.id === q.correctOptionId);
  const rnd = seeded(`${q.id}|${right?.text || ''}|${salt}`);
  const opts = [...q.options];
  for (let i = opts.length - 1; i > 0; i--) {
    const j = Math.floor(rnd() * (i + 1));
    [opts[i], opts[j]] = [opts[j], opts[i]];
  }
  const map = new Map();
  opts.forEach((o, i) => map.set(String(o.id), 'abcd'[i]));
  q.options = opts.map((o) => ({ ...o, id: map.get(String(o.id)) }));
  const cid = map.get(String(q.correctOptionId));
  q.correctOptionId = cid;
  q.correctAnswer = cid;
  const fw = {};
  for (const [k, v] of Object.entries(q.feedbackWrong || {})) fw[map.get(k) ?? k] = v;
  q.feedbackWrong = Object.fromEntries(Object.entries(fw).sort(([a], [b]) => a.localeCompare(b)));
  return true;
}

function toCanonical(q) {
  const correct = q.options.find((o) => o.id === q.correctOptionId);
  const rest = q.options
    .filter((o) => o.id !== q.correctOptionId)
    .sort((a, b) => String(a.text).localeCompare(String(b.text)));
  const canon = [correct, ...rest];
  const back = new Map(canon.map((o, i) => [o.id, 'abcd'[i]]));
  q.options = canon.map((o) => ({ ...o, id: back.get(o.id) }));
  q.feedbackWrong = Object.fromEntries(
    Object.entries(q.feedbackWrong || {}).map(([k, v]) => [back.get(k) ?? k, v]),
  );
  q.correctOptionId = 'a';
  q.correctAnswer = 'a';
}

function shuffleFileQuestions(questions, salt = '') {
  for (const q of questions) {
    if (!TYPES.has(q.type)) continue;
    toCanonical(q);
    shuffleQuestion(q, salt);
  }
}

const args = process.argv.slice(2).filter((a, i, all) => !a.startsWith('--') && all[i - 1] !== '--trail');
const files = args.length
  ? args.map((a) => (existsSync(a) ? resolve(a) : join(pilotDir, a)))
  : readdirSync(cenaDir).filter((f) => f.endsWith('.json')).map((f) => join(cenaDir, f));

const positions = {};
for (const f of files) {
  const data = JSON.parse(readFileSync(f, 'utf8'));
  // Idempotente + evita cena com Completar/Conectar todos em "a" (validação --final).
  let salt = '';
  for (let attempt = 0; attempt < 12; attempt++) {
    salt = attempt === 0 ? '' : `retry${attempt}`;
    shuffleFileQuestions(data.questions, salt);
    const shown = data.questions.filter((q) => q.type === 'complete' || q.type === 'connect');
    if (shown.length < 4 || !shown.every((q) => q.correctOptionId === 'a')) break;
  }
  for (const q of data.questions) {
    if (!TYPES.has(q.type)) continue;
    positions[q.correctOptionId] = (positions[q.correctOptionId] || 0) + 1;
  }
  writeFileSync(f, `${JSON.stringify(data, null, 2)}\n`);
}
console.log(`✓ ${files.length} cena(s) · posição da certa:`, positions);
