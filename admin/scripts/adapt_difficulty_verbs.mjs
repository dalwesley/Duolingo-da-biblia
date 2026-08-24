/**
 * Alinha skills ao modo cognitivo e limpa carimbos "Observe:/Compreenda:/Interprete:".
 * A operação fica no perfil do modo (UI + skill), não no primeiro verbo do ato.
 *
 *   node admin/scripts/adapt_difficulty_verbs.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { DIFFICULTY_META } from './_v2_generator.mjs';
import { foldKey } from './_answer_phrase.mjs';
import { validateBank, formatReport } from './_bank_validator.mjs';

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

const PRIMARY_SKILL = {
  semente: 'observe',
  caminhada: 'understand',
  profundezas: 'interpret',
};

function readJson(name) {
  return JSON.parse(readFileSync(join(dataRoot, name), 'utf8'));
}
function writeJson(name, data) {
  writeFileSync(join(dataRoot, name), `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

function stemOf(q) {
  return (q.question || q.prompt || q.cue || '').replace(/\s+/g, ' ').trim();
}

function ensureQuestionMark(s) {
  const t = String(s || '').replace(/\s+/g, ' ').trim();
  if (!t) return t;
  if (/[.!?]$/.test(t)) return t;
  if (/^(o trecho afirma|revisão:)/i.test(t) && !/\?/.test(t)) return t;
  return `${t}?`;
}

function capitalize(s) {
  const t = String(s || '').trim();
  if (!t) return t;
  return t.charAt(0).toUpperCase() + t.slice(1);
}

function naturalizeStem(raw) {
  let stem = String(raw || '').replace(/\s+/g, ' ').trim();
  if (!stem) return stem;

  // "Observe Gênesis 1:1–2: qual trecho…" (preserva ":" do versículo)
  let m = stem.match(
    /^(?:revisão\s*[—–:\-]\s*)?(observe|compreenda|interprete)\s+(.+):\s*(qual|o que|quem|como|onde|quando|por que)\b(.+)$/i,
  );
  if (m) {
    const ref = m[2].trim();
    const rest = `${m[3]}${m[4]}`.trim();
    // Se ref parece passagem bíblica, usa "Em …,"
    if (/\d/.test(ref)) {
      stem = `Em ${ref}, ${rest.charAt(0).toLowerCase()}${rest.slice(1)}`;
    } else {
      stem = capitalize(rest);
    }
  } else if (
    /^(?:revisão\s*[—–:\-]\s*)?(observe|compreenda|interprete)\s+((?:a ordem|a sequência|o arco)\b.+)$/i.test(
      stem,
    )
  ) {
    m = stem.match(
      /^(?:revisão\s*[—–:\-]\s*)?(observe|compreenda|interprete)\s+((?:a ordem|a sequência|o arco)\b.+)$/i,
    );
    stem = `Qual ${m[2].trim()}`;
  } else if (
    /^(?:revisão\s*[—–:\-]\s*)?(observe|observar|compreenda|compreender|interprete|interpretar)(\s+com\s+cuidado)?\s*[:—–\-]\s*/i.test(
      stem,
    )
  ) {
    stem = stem.replace(
      /^(?:revisão\s*[—–:\-]\s*)?(observe|observar|compreenda|compreender|interprete|interpretar)(\s+com\s+cuidado)?\s*[:—–\-]\s*/i,
      '',
    );
    stem = capitalize(stem);
  }

  // Conserto de ref quebrada por strip anterior: "Em Gênesis 1, 1–2:" → "Em Gênesis 1:1–2,"
  stem = stem.replace(
    /\b(Em\s+)([A-Za-zÀ-ú][A-Za-zÀ-úçãõáéíóúâêôà]*)\s+(\d+),\s+(\d+[–\-−]\d+)\s*:/g,
    '$1$2 $3:$4,',
  );
  stem = stem.replace(
    /\b(Em\s+)([A-Za-zÀ-ú][A-Za-zÀ-úçãõáéíóúâêôà]*)\s+(\d+),\s+(\d+)\s*:/g,
    '$1$2 $3:$4,',
  );

  stem = stem.replace(/^o trecho afirma que\s+/i, 'O trecho afirma: ');
  stem = stem.replace(/^revisão\s*[—–:\-]\s*/i, 'Revisão: ');

  // "Qual A ordem" → "Qual a ordem"
  stem = stem.replace(/^Qual\s+([A-ZÀ-Ú])/u, (_, c) => `Qual ${c.toLowerCase()}`);

  if (/^(a ordem|a sequência|o arco)\b/i.test(stem)) {
    stem = `Qual ${stem.charAt(0).toLowerCase()}${stem.slice(1)}`;
  }

  return ensureQuestionMark(stem);
}

let stemFixed = 0;
let skillFixed = 0;
let dedupFixed = 0;
const allQuestions = [];

for (const file of BANK_FILES) {
  const raw = readJson(file);
  const questions = Array.isArray(raw) ? raw : raw.questions || [];

  for (const q of questions) {
    const diff = q.difficulty || 'semente';
    const want = PRIMARY_SKILL[diff] || 'observe';
    if (q.skill !== want) {
      q.skill = want;
      skillFixed += 1;
    }

    const before = stemOf(q);
    const after = naturalizeStem(before);
    if (after && after !== before) {
      q.question = after;
      q.prompt = after;
      q.cue = after;
      stemFixed += 1;
    } else if (after) {
      q.question = after;
      q.prompt = after;
      q.cue = after;
    }
  }

  const seen = new Map();
  for (const q of questions) {
    const diff = q.difficulty || 'semente';
    const fold = foldKey(stemOf(q));
    const key = `${q.trail || ''}|${q.section}|${diff}|${fold}`;
    if (!fold || fold.length < 8) continue;
    if (!seen.has(key)) {
      seen.set(key, q);
      continue;
    }
    let body = stemOf(q).replace(/^revisão:\s*/i, '').trim();
    const slot = String(q.id || '').match(/-(\d{2})$/)?.[1] || 'x';
    const unique = ensureQuestionMark(`Revisão (${slot}): ${body.charAt(0).toLowerCase()}${body.slice(1)}`);
    q.question = unique;
    q.prompt = unique;
    q.cue = unique;
    seen.set(`${q.trail || ''}|${q.section}|${diff}|${foldKey(unique)}`, q);
    dedupFixed += 1;
  }

  writeJson(file, {
    ...(Array.isArray(raw) ? {} : raw),
    difficulties: DIFFICULTY_META,
    questions,
  });
  allQuestions.push(...questions);
  console.log(`✓ ${file}: ${questions.length}`);
}

console.log(`\nStems limpos: ${stemFixed} · skills: ${skillFixed} · dedup: ${dedupFixed}`);
const check = validateBank(allQuestions);
console.log(formatReport(check));
if (!check.ok) process.exit(1);
console.log('\n✓ Skills no modo; enunciados naturais (sem carimbo de verbo).');
