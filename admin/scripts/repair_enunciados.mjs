/**
 * Revisa enunciados do banco: V/F vira afirmação natural;
 * perguntas telegráficas / incompletas ganham frase completa.
 *
 *   node admin/scripts/repair_enunciados.mjs
 *   node admin/scripts/repair_enunciados.mjs --only genesis ot
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import {
  extractQuotedAnswer,
  isAsk,
  vfClaim,
  vfClaimFromParts,
} from './_answer_phrase.mjs';

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

const STEM_MAP = {
  'Quem Abrão resgata?': 'Quem Abrão resgata na guerra dos reis?',
  'O que passa entre os pedaços na aliança?':
    'O que passa entre os animais partidos na aliança com Abrão?',
  'O que Deus conta a Abrão no céu?':
    'O que Deus compara à descendência de Abrão ao apontar as estrelas?',
  'O que Ló escolhe?': 'Que região Ló escolhe ao se separar de Abrão?',
  'Quem viaja com Abrão?': 'Quem parte com Abrão quando ele deixa a sua terra?',
  'O sinal da aliança neste capítulo é:':
    'Qual é o sinal da aliança neste capítulo?',
  'O conflito inicial é entre:': 'Entre quem começa o conflito neste passo?',
  'Em Betel, Jacó encontra:': 'O que Jacó encontra em Betel?',
  'Em Peniel, Jacó recebe:': 'O que Jacó recebe em Peniel?',
  'Quem é Melquisedeque?': 'Quem é Melquisedeque no encontro com Abrão?',
  'O que Abrão dá a Melquisedeque?':
    'O que Abrão oferece a Melquisedeque depois da bênção?',
};

function readJson(name) {
  return JSON.parse(readFileSync(join(dataRoot, name), 'utf8'));
}

function writeJson(name, data) {
  writeFileSync(join(dataRoot, name), `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

function parseOnly() {
  const i = process.argv.indexOf('--only');
  if (i < 0) return BANK_FILES;
  const keys = process.argv.slice(i + 1).filter((a) => !a.startsWith('--'));
  const map = Object.fromEntries(
    BANK_FILES.map((f) => [f.replace('_questions.json', ''), f]),
  );
  return keys.map((k) => map[k] || (k.endsWith('.json') ? k : `${k}_questions.json`));
}

function isVf(q) {
  const t = String(q.type || '').toLowerCase();
  return t === 'true_false' || t === 'truefalse' || t === 'tf';
}

const INSTRUCTION_CUE =
  /^(complete a lacuna|monte a sequência|ligue cada|toque no texto|qual palavra une)/i;

function looksLikeStatement(text) {
  const s = (text || '').replace(/\s+/g, ' ').trim();
  if (!s || /[?]$/.test(s)) return false;
  if (INSTRUCTION_CUE.test(s)) return true;
  const bare = s.replace(/[.!?…]+$/g, '').trim();
  if (isAsk(bare) && !/:\s+/.test(s)) return false;
  return s.length >= 16 || /[.!]$/.test(s);
}

function undouble(text) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  if (t.length < 20) return t;
  for (let len = Math.min(80, Math.floor(t.length / 2)); len >= 10; len -= 1) {
    const a = t.slice(0, len).trim();
    const b = t.slice(len).trim();
    if (a.length < 10) continue;
    const al = a.toLowerCase();
    const bl = b.toLowerCase();
    if (bl.startsWith(al)) {
      const rest = b.slice(a.length).trim();
      return `${a} ${rest}`.replace(/\s+/g, ' ').trim();
    }
  }
  return t;
}

function colonToAsk(stem) {
  const t = stem.replace(/:+$/, '').trim();
  if (!t) return stem;
  if (isAsk(t)) return `${t}?`;
  const last = t.split(/\s+/).pop().toLowerCase();
  if (/^(era|eram|é|são|foi|foram|está|estava)$/.test(last)) return t;
  if (/\baponta para$/i.test(t)) {
    const topic = t.replace(/\s+aponta para$/i, '');
    return `Para que aponta ${topic.charAt(0).toLowerCase()}${topic.slice(1)}?`;
  }
  if (/\bfoi chamado para$/i.test(t)) {
    const who = t.replace(/\s+foi chamado para$/i, '');
    return `Para que ${who} foi chamado?`;
  }
  if (/\b(era|eram|é|são|foi|foram)\s+\S+$/i.test(t)) {
    return `Como ${t.charAt(0).toLowerCase()}${t.slice(1)}?`;
  }
  if (
    /\b(incluía|inclui|sinalizavam|sinalizava|indicava|celebravam|celebrava|ocorria|limpa)\b/i.test(
      t,
    )
  ) {
    return `O que ${t.charAt(0).toLowerCase()}${t.slice(1)}?`;
  }
  return `${t}?`;
}

function improveStem(raw) {
  let t = (raw || '').replace(/\s+/g, ' ').trim();
  if (!t) return t;
  if (INSTRUCTION_CUE.test(t)) return t;
  t = t.replace(/\s*\(com atenção ao texto\)\s*/gi, ' ').replace(/\s+/g, ' ').trim();
  if (STEM_MAP[t]) return STEM_MAP[t];
  const withQ = t.endsWith('?') ? t : `${t.replace(/[?:]+$/, '')}?`;
  if (STEM_MAP[withQ]) return STEM_MAP[withQ];
  const bare = t.replace(/[?:]+$/, '').trim();
  if (STEM_MAP[`${bare}?`]) return STEM_MAP[`${bare}?`];
  if (STEM_MAP[`${bare}:`]) return STEM_MAP[`${bare}:`];
  if (t.endsWith(':')) return colonToAsk(t);
  return t;
}

function vfIsTrue(q) {
  const a = String(q.correctAnswer || q.correctOptionId || '')
    .trim()
    .toLowerCase();
  return a === 'true' || a === 'verdadeiro' || a === 'v';
}

function withPeriod(text) {
  let t = (text || '').replace(/\s+/g, ' ').trim();
  t = t.replace(/:\.$/, ':');
  if (!t || /[.!?]$/.test(t) || /:$/.test(t)) return t;
  return `${t}.`;
}

function repairVfPrompt(q) {
  const question = improveStem(q.question || '');
  let prompt = (q.prompt || '').replace(/\s+/g, ' ').trim();
  const quoted = extractQuotedAnswer(q.feedbackCorrect || '');
  const asTrue = vfIsTrue(q);

  if (INSTRUCTION_CUE.test(prompt)) return prompt;

  prompt = prompt.replace(/\s*\(com atenção ao texto\)\s*/gi, ' ').replace(/\s+/g, ' ').trim();
  prompt = undouble(prompt);

  const fromStored = vfClaim(prompt);
  if (fromStored && fromStored !== prompt && looksLikeStatement(fromStored) && !isAsk(fromStored)) {
    return withPeriod(undouble(fromStored));
  }

  if (!isAsk(prompt) && looksLikeStatement(prompt)) {
    return withPeriod(prompt);
  }

  if (isAsk(prompt) && prompt.length > 24) {
    return prompt;
  }

  if (sameish(prompt, question)) {
    if (asTrue && quoted) return vfClaimFromParts(question, quoted);
    return prompt;
  }

  if (isAsk(question) && prompt && !looksLikeStatement(prompt) && !isAsk(prompt)) {
    return vfClaimFromParts(question, prompt.replace(/[.!?…]+$/g, ''));
  }

  return withPeriod(fromStored || prompt);
}

function sameish(a, b) {
  const n = (s) =>
    (s || '')
      .replace(/\s*\(com atenção ao texto\)\s*/gi, ' ')
      .replace(/[?:]+$/g, '')
      .replace(/\s+/g, ' ')
      .trim()
      .toLowerCase();
  return n(a) === n(b);
}

function repairQuestion(q) {
  let changed = false;
  const oldQ = q.question || '';
  const nextQ = improveStem(oldQ);
  if (nextQ && nextQ !== oldQ) {
    q.question = nextQ;
    changed = true;
  }

  if (isVf(q)) {
    const nextPrompt = repairVfPrompt(q);
    if (nextPrompt && nextPrompt !== q.prompt) {
      q.prompt = nextPrompt;
      changed = true;
    }
    if ((q.cue || '') !== (q.prompt || '')) {
      q.cue = q.prompt;
      changed = true;
    }
    return changed;
  }

  if (INSTRUCTION_CUE.test(q.prompt || '') || INSTRUCTION_CUE.test(q.cue || '')) {
    return changed;
  }

  if (q.prompt && (sameish(q.prompt, oldQ) || String(q.prompt).endsWith(':'))) {
    const next = improveStem(q.prompt);
    if (next !== q.prompt) {
      q.prompt = next;
      changed = true;
    }
  }
  if (q.cue && (sameish(q.cue, oldQ) || String(q.cue).endsWith(':'))) {
    const next = improveStem(q.cue);
    if (next !== q.cue) {
      q.cue = next;
      changed = true;
    }
  }
  return changed;
}

function main() {
  const files = parseOnly();
  for (const name of files) {
    const data = readJson(name);
    const list = Array.isArray(data) ? data : data.questions || [];
    let n = 0;
    const samples = [];
    for (const q of list) {
      const before = `${q.question || ''} || ${q.prompt || ''}`;
      if (repairQuestion(q)) {
        n += 1;
        if (samples.length < 6) {
          samples.push(`${q.id}: ${before.split(' || ')[1]} → ${q.prompt}`);
        }
      }
    }
    if (Array.isArray(data)) writeJson(name, list);
    else {
      data.questions = list;
      writeJson(name, data);
    }
    console.log(`${name}: ${n} enunciados revisados`);
    for (const s of samples) console.log(`  · ${s}`);
  }
}

main();
