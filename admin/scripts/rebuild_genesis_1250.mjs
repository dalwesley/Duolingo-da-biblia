/**
 * Reconstrói Gênesis 12–50 a partir dos fatos autorados.
 * Não fabrica escolha com n-grama do versículo. Não gera clones -xch.
 *
 *   node scripts/rebuild_genesis_1250.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import {
  clipPhrase,
  findTapTarget,
  foldKey,
  isNamingAsk,
  isNameLikeAnswer,
  passagePhrases,
  vfClaimFromParts,
} from './_answer_phrase.mjs';
import {
  MODULES,
  generateGenesis1250Questions,
  loadGenesisBook,
} from './expand_genesis_complete.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const dataRoot = join(__dirname, '..', '..', 'trilha_app', 'assets', 'data');

function readJson(name) {
  return JSON.parse(readFileSync(join(dataRoot, name), 'utf8'));
}
function writeJson(name, data) {
  writeFileSync(join(dataRoot, name), `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

function clipWords(text, maxWords = 40) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  const words = t.split(' ').filter(Boolean);
  if (words.length <= maxWords) return t;
  return `${words.slice(0, maxWords).join(' ')}…`;
}

function optText(q) {
  const cid = String(q.correctOptionId || 'a');
  return ((q.options || []).find((o) => String(o.id) === cid)?.text || '').trim();
}

function chapterVerses(book, chapters) {
  const out = [];
  for (const ch of chapters || []) {
    out.push(...(book.chapters[ch - 1] || []));
  }
  return out;
}

function palcoFor(correct, verses) {
  const needle = foldKey((correct || '').split(/[—–(/]/)[0].trim());
  if (needle.length >= 3) {
    for (let i = 0; i < verses.length; i++) {
      if (foldKey(verses[i]).includes(needle)) {
        return clipWords([verses[i], verses[i + 1] || ''].join(' ').trim(), 40);
      }
    }
  }
  return clipWords(verses.slice(0, 3).join(' '), 40);
}

function orderPieces(passage) {
  const text = clipWords(passage || '', 55);
  const clauses = text
    .split(/[;.…]+/)
    .map((s) => s.trim())
    .filter((s) => s.length >= 10)
    .map((s) => clipPhrase(s, 56));
  if (clauses.length >= 3) return clauses.slice(0, 3);
  const commas = text
    .split(/,/)
    .map((s) => s.trim())
    .filter((s) => s.length >= 8)
    .map((s) => clipPhrase(s, 56));
  if (commas.length >= 3) return commas.slice(0, 3);
  const w = text.split(/\s+/).filter(Boolean);
  if (w.length >= 12) {
    const third = Math.max(4, Math.floor(w.length / 3));
    return [
      clipPhrase(w.slice(0, third).join(' '), 56),
      clipPhrase(w.slice(third, third * 2).join(' '), 56),
      clipPhrase(w.slice(third * 2).join(' '), 56),
    ].filter((s) => s.length >= 8);
  }
  return null;
}

function keepAsChoice(q) {
  const ask = q.question || q.prompt || '';
  const correct = optText(q);
  return isNamingAsk(ask) || isNameLikeAnswer(correct);
}

function applyVf(q, asTrue) {
  const correct = optText(q);
  const wrong = (q.options || []).find((o) => o.id !== q.correctOptionId)?.text || '';
  const piece = asTrue ? correct : wrong;
  q.type = 'true_false';
  q.prompt = vfClaimFromParts(q.question || '', piece);
  q.cue = q.prompt;
  q.correctAnswer = asTrue ? 'true' : 'false';
  q.correctOptionId = q.correctAnswer;
  q.options = [
    { id: 'true', text: 'Verdadeiro' },
    { id: 'false', text: 'Falso' },
  ];
  q.skill = 'observe';
  delete q.template;
  delete q.correctOrder;
}

function applyTapSafe(q) {
  const passage = q.passageText || '';
  const target = findTapTarget(optText(q), passage);
  if (!target || foldKey(passage).includes(foldKey(target)) === false) return false;
  const others = passagePhrases(passage, target);
  if (!others.length) return false;
  q.type = 'tap';
  q.prompt = q.question;
  q.cue = q.question;
  q.options = [
    { id: 'a', text: target },
    ...others.slice(0, 2).map((t, i) => ({
      id: String.fromCharCode(98 + i),
      text: t,
    })),
  ];
  q.correctOptionId = 'a';
  q.correctAnswer = 'a';
  q.skill = 'observe';
  return true;
}

function applyCompleteSafe(q) {
  const passage = q.passageText || '';
  const target = findTapTarget(optText(q), passage);
  if (!target || target.includes('…')) return false;
  const re = new RegExp(target.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
  if (!re.test(passage)) return false;
  const extras = passagePhrases(passage, target);
  q.type = 'complete';
  q.template = passage.replace(re, '___');
  q.prompt = q.question;
  q.cue = q.prompt;
  q.options = [
    { id: 'a', text: target },
    { id: 'b', text: extras[0] || 'outra leitura do trecho' },
    { id: 'c', text: extras[1] || 'uma tese que o trecho não afirma' },
  ].filter((o, i, arr) => o.text && arr.findIndex((x) => x.text === o.text) === i);
  q.correctOptionId = 'a';
  q.correctAnswer = 'a';
  q.skill = 'understand';
  return q.options.length >= 2;
}

function applyOrderSafe(q) {
  const pieces = orderPieces(q.passageText || '');
  if (!pieces || pieces.length < 3) return false;
  q.type = 'order';
  q.question = 'Ordene as frases na ordem do texto.';
  q.prompt = q.question;
  q.cue = q.question;
  q.options = pieces.slice(0, 3).map((t, i) => ({
    id: String.fromCharCode(97 + i),
    text: t,
  }));
  q.correctOrder = q.options.map((o) => o.id);
  q.correctAnswer = q.correctOrder.join(',');
  q.correctOptionId = 'a';
  q.skill = 'understand';
  return true;
}

function stampChoice(q, passage) {
  q.type = 'choice';
  q.passageText = passage;
  q.prompt = q.question;
  q.cue = q.question;
  q.correctAnswer = q.correctOptionId || 'a';
  q.skill = q.difficulty === 'profundezas' ? 'interpret' : q.skill || 'observe';
}

function isDuplicate(q, list) {
  const stem = foldKey(q.question || '');
  if (!stem) return false;
  const first = list.findIndex((x) => foldKey(x.question || '') === stem);
  return first >= 0 && list.indexOf(q) !== first;
}

function assignSafeTypes(questions, book) {
  const missionBySlug = new Map(
    MODULES.flatMap((m) => m.missions.map((x) => [x.slug, x])),
  );
  const groups = new Map();
  for (const q of questions) {
    const key = `${q.section}::${q.difficulty}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(q);
  }

  for (const list of groups.values()) {
    list.sort((a, b) => String(a.id).localeCompare(String(b.id)));
    const mission = missionBySlug.get(list[0]?.section);
    const verses = chapterVerses(book, mission?.chapters || []);

    for (const q of list) {
      stampChoice(q, palcoFor(optText(q), verses));
    }

    const used = new Set();
    const take = (pred) => {
      const idx = list.findIndex((item, i) => !used.has(i) && pred(item, i));
      if (idx < 0) return null;
      used.add(idx);
      return list[idx];
    };

    const disposable = (q) => isDuplicate(q, list) || !keepAsChoice(q);

    const vfTrue = take(disposable);
    if (vfTrue) applyVf(vfTrue, true);

    const vfFalse = take(disposable);
    if (vfFalse) applyVf(vfFalse, false);

    const tap = take((q) => disposable(q) && Boolean(findTapTarget(optText(q), q.passageText)));
    if (tap && !applyTapSafe(tap)) {
      used.delete(list.indexOf(tap));
      stampChoice(tap, tap.passageText);
    }

    const complete = take(
      (q) => disposable(q) && Boolean(findTapTarget(optText(q), q.passageText)),
    );
    if (complete && !applyCompleteSafe(complete)) {
      used.delete(list.indexOf(complete));
      stampChoice(complete, complete.passageText);
    }

    const order = take(disposable);
    if (order && !applyOrderSafe(order)) {
      used.delete(list.indexOf(order));
      stampChoice(order, order.passageText);
    }
  }
}

function main() {
  const book = loadGenesisBook();
  if (!book) throw new Error('Gênesis não encontrado');

  const raw = readJson('ot_questions.json');
  const wrapped = Array.isArray(raw);
  const questions = wrapped ? raw : raw.questions || [];
  const kept = questions.filter((q) => q.trail !== 'genesis-12-50');
  const generated = generateGenesis1250Questions(book);
  assignSafeTypes(generated, book);

  const merged = [...kept, ...generated];
  if (wrapped) writeJson('ot_questions.json', merged);
  else writeJson('ot_questions.json', { ...raw, questions: merged });

  const agar = generated.filter((q) => q.section === 'gen12-05-agar-ismael');
  const choiceAgar = agar.filter((q) => q.type === 'choice' && /filho de Agar/i.test(q.question));
  console.log(
    `✓ genesis-12-50: ${generated.length} atos (removidos clones). ` +
      `Agar/Ismael choice: ${choiceAgar.map((q) => (q.options || []).map((o) => o.text).join(' | ')).join(' || ') || '(nenhuma)'}`,
  );
}

main();
