/**
 * Repara opções de resposta recortadas / duplicadas no banco JSON.
 * Restaura fatos autorados (Gênesis 12–50) quando a escolha virou n-grama do verso.
 *
 *   node admin/scripts/repair_broken_answers.mjs
 *   node admin/scripts/repair_broken_answers.mjs --only ot
 */
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import {
  foldKey,
  isIncompletePhrase,
  isNamingAsk,
  isPassagePrefix,
  isVerseSnippet,
  optionPoolFromQuestions,
  repairQuestion,
  vfClaimFromParts,
} from './_answer_phrase.mjs';
import { authoredFacts } from './expand_genesis_complete.mjs';

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

function readJson(name) {
  return JSON.parse(readFileSync(join(dataRoot, name), 'utf8'));
}

function writeJson(name, data) {
  writeFileSync(join(dataRoot, name), `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

function parseOnly() {
  const i = process.argv.indexOf('--only');
  if (i < 0) return BANK_FILES;
  const keys = process.argv
    .slice(i + 1)
    .filter((a) => !a.startsWith('--'));
  const map = {
    genesis: 'genesis_questions.json',
    exodo: 'exodo_questions.json',
    ot: 'ot_questions.json',
    nt: 'nt_questions.json',
    epistolas: 'epistolas_questions.json',
    sermao: 'sermao_questions.json',
    buracos: 'buracos_questions.json',
  };
  return keys.map((k) => map[k] || (k.endsWith('.json') ? k : `${k}_questions.json`));
}

function stemOf(text) {
  return foldKey(
    String(text || '')
      .replace(/\s*\(com atenção ao texto\)\s*/gi, ' ')
      .replace(/[.!?…]+$/g, '')
      .trim(),
  );
}

function writeChoiceFeedback(q, correct) {
  const ref = (q.verseRef || '').trim();
  const piece = String(correct || '').replace(/\s+/g, ' ').trim();
  q.feedbackCorrect = ref
    ? `Correto. ${ref}: “${piece}”.`
    : `Correto. A resposta é: “${piece}”.`;
  const wrong = {};
  for (const o of q.options || []) {
    if (String(o.id) === String(q.correctOptionId)) continue;
    wrong[o.id] = `Não. A resposta é: “${piece}”.`;
  }
  q.feedbackWrong = wrong;
}

function restoreFromFacts(questions) {
  const facts = authoredFacts();
  const byStem = new Map();
  for (const f of facts) {
    const stem = stemOf(f.question);
    byStem.set(stem, f);
    byStem.set(`${f.section}::${stem}`, f);
  }
  let n = 0;
  for (const q of questions) {
    const stem = stemOf(q.question || q.prompt || '');
    const fact = byStem.get(`${q.section || ''}::${stem}`) || byStem.get(stem);
    if (!fact) continue;
    const type = String(q.type || 'choice').toLowerCase();
    const passage = q.passageText || '';
    const opts = Array.isArray(q.options) ? q.options : [];

    if (
      type === 'choice' ||
      type === 'text_supported' ||
      type === 'best_interpretation'
    ) {
      q.options = [
        { id: 'a', text: fact.correct },
        ...fact.wrongs.slice(0, 3).map((t, i) => ({
          id: String.fromCharCode(98 + i),
          text: t,
        })),
      ];
      q.correctOptionId = 'a';
      q.correctAnswer = 'a';
      writeChoiceFeedback(q, fact.correct);
      n += 1;
      continue;
    }

    if (type === 'true_false' || type === 'truefalse' || type === 'tf') {
      const prompt = q.prompt || q.cue || '';
      const asTrue = ['true', 'verdadeiro', 'v'].includes(
        String(q.correctAnswer || q.correctOptionId || '').toLowerCase(),
      );
      const expected = asTrue ? fact.correct : fact.wrongs[0] || fact.correct;
      const ref = (q.verseRef || '').trim();
      if (!foldKey(prompt).includes(foldKey(expected))) {
        q.prompt = vfClaimFromParts(fact.question, expected);
        q.cue = q.prompt;
      }
      q.feedbackCorrect = ref ? `Correto. ${ref}.` : 'Correto.';
      q.feedbackWrong = asTrue
        ? { false: ref ? `Não. ${ref} afirma outra coisa.` : 'Não.' }
        : { true: ref ? `Não. ${ref} afirma outra coisa.` : 'Não.' };
      n += 1;
      continue;
    }

    if (type === 'order' && isNamingAsk(q.question || q.prompt || '')) {
      const dirty = opts.some(
        (o) => isPassagePrefix(o.text, passage) || isVerseSnippet(o.text, passage),
      );
      if (!dirty) continue;
      q.prompt = 'Ordene as frases na ordem do texto.';
      q.cue = q.prompt;
      q.question = q.prompt;
      n += 1;
    }
  }
  return n;
}

function remainingBroken(questions) {
  let n = 0;
  const samples = [];
  for (const q of questions) {
    const type = (q.type || '').toLowerCase();
    if (['true_false', 'truefalse', 'order', 'connect', 'match', 'tap', 'find_in_text', 'complete'].includes(type)) {
      continue;
    }
    const cid = String(q.correctOptionId || q.correctAnswer || '');
    const opt = (q.options || []).find((o) => String(o.id) === cid);
    const text = (opt?.text || '').trim();
    const passage = q.passageText || '';
    if (isIncompletePhrase(text)) {
      n += 1;
      if (samples.length < 8) samples.push(`${q.id} :: ${text}`);
    }
    const prefix = (q.options || []).find((o) => isPassagePrefix(o.text, passage));
    if (prefix && !/como (começa|inicia)/i.test(q.question || '')) {
      n += 1;
      if (samples.length < 8) {
        samples.push(`${q.id} :: prefix “${prefix.text}”`);
      }
    }
    const folds = (q.options || []).map((o) => (o.text || '').toLowerCase());
    if (folds.length && new Set(folds).size < folds.length) {
      n += 1;
      if (samples.length < 8) samples.push(`${q.id} :: dup`);
    }
  }
  return { n, samples };
}

function main() {
  let changedTotal = 0;
  for (const file of parseOnly()) {
    if (!existsSync(join(dataRoot, file))) {
      console.log(`skip ${file}`);
      continue;
    }
    const raw = readJson(file);
    const wrapped = Array.isArray(raw);
    const questions = wrapped ? raw : raw.questions || [];
    const restored = restoreFromFacts(questions);
    const poolMap = optionPoolFromQuestions(questions);
    let changed = restored;
    for (const q of questions) {
      const key = `${q.section || ''}::${q.difficulty || ''}`;
      const pool = poolMap.get(key) || [];
      if (repairQuestion(q, pool)) changed += 1;
    }
    if (wrapped) writeJson(file, questions);
    else writeJson(file, { ...raw, questions });
    const leftover = remainingBroken(questions);
    changedTotal += changed;
    console.log(
      `${file}: ${changed} reparadas (${restored} fatos) · ${questions.length} total · ` +
        `ainda incompletas/prefix/dups: ${leftover.n}`,
    );
    for (const s of leftover.samples) console.log(`  · ${s}`);
  }
  console.log(`✓ ${changedTotal} perguntas atualizadas`);
}

main();
