/**
 * P0–P6: repara o banco local para o contrato de sessão.
 *
 *   node admin/scripts/repair_p0_p6.mjs
 */
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import {
  TAP_STOP,
  answerKey,
  clipPhrase,
  extractQuotedAnswer,
  findTapTarget,
  foldKey,
  growInPassage,
  isDummyDistractor,
  isIncompletePhrase,
  isNamingAsk,
  isNameLikeAnswer,
  isPassagePrefix,
  isVerseSnippet,
  isWeakDistractor,
  optionPoolFromQuestions,
  passageForm,
  passagePhrases,
  preferredAnswer,
  repairQuestion,
  styleOption,
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

const META =
  /por que estudar|pergunta profunda|tens[aã]o teol|aplica[cç][aã]o justa|povo \(ou a personagem\)|olhando para o tema|em profundidade/i;
const GENERIC_COMPLETE = /^(complete( a lacuna)?!?\.?)$/i;
const GENERIC_ORDER = /^monte a sequ/i;
const ASK_LEAD =
  /^(à imagem de quem|para onde|aonde|por que|porque|por quê|o que|em qual|em que|de quem|a quem|com quem|para quem|para que|de que|quem|quais|qual|que|como|onde|quando|quantos|quantas)\b/i;

const stats = {
  tapFixed: 0,
  vfFixed: 0,
  choiceFixed: 0,
  orderFixed: 0,
  completeFixed: 0,
  cloned: 0,
  converted: 0,
  authoredEmpty: 0,
};

function readJson(name) {
  return JSON.parse(readFileSync(join(dataRoot, name), 'utf8'));
}
function writeJson(name, data) {
  writeFileSync(join(dataRoot, name), `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

function words(s) {
  return (s || '').replace(/\s+/g, ' ').trim().split(' ').filter(Boolean);
}
function clipWords(text, maxWords = 40) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  const w = t.split(' ').filter(Boolean);
  if (w.length <= maxWords) return t;
  return `${w.slice(0, maxWords).join(' ')}…`;
}
function clip(text, max) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  if (t.length <= max) return t;
  return `${t.slice(0, max - 1).trim()}…`;
}
function slot(type) {
  const t = String(type || 'choice').trim().toLowerCase();
  if (['true_false', 'truefalse', 'tf'].includes(t)) return 'true_false';
  if (['tap', 'find_in_text', 'findintext'].includes(t)) return 'tap';
  if (['complete', 'fill'].includes(t)) return 'complete';
  if (['connect', 'match', 'pair'].includes(t)) return 'connect';
  if (['text_supported', 'best_interpretation', 'bestinterpretation'].includes(t)) {
    return 'choice';
  }
  return t || 'choice';
}
function cidOf(q) {
  const t = slot(q.type);
  if (t === 'true_false') {
    const a = String(q.correctAnswer || q.correctOptionId || '')
      .trim()
      .toLowerCase();
    if (['true', 'verdadeiro', 'v'].includes(a)) return 'true';
    if (['false', 'falso', 'f'].includes(a)) return 'false';
    return a || 'false';
  }
  return String(q.correctOptionId || q.correctAnswer || 'a').trim();
}
function optText(q, id) {
  return ((q.options || []).find((o) => String(o.id) === String(id))?.text || '').trim();
}
function inText(hay, needle) {
  const n = foldKey(needle);
  return n.length >= 2 && foldKey(hay).includes(n);
}

function buildBibleIndex() {
  const path = join(dataRoot, 'bible_tb.json');
  if (!existsSync(path)) return null;
  const books = JSON.parse(readFileSync(path, 'utf8'));
  const byName = new Map();
  for (const b of books) {
    byName.set(foldKey(b.name), b);
    if (b.abbrev) byName.set(foldKey(b.abbrev), b);
  }
  const aliases = {
    genesis: 'gênesis',
    exodo: 'êxodo',
    levitico: 'levítico',
    numeros: 'números',
    deuteronomio: 'deuteronômio',
    josue: 'josué',
    juizes: 'juízes',
    '1 cronicas': '1 crônicas',
    '2 cronicas': '2 crônicas',
    proverbios: 'provérbios',
    cantares: 'cânticos',
    isaias: 'isaías',
    lamentacoes: 'lamentações',
    oseias: 'oséias',
    miqueias: 'miquéias',
    jo: 'jó',
  };
  for (const [alias, target] of Object.entries(aliases)) {
    const book = byName.get(foldKey(target));
    if (book) byName.set(foldKey(alias), book);
  }
  return byName;
}
function findBook(byName, bookName) {
  if (!byName) return null;
  const key = foldKey(bookName);
  const hit = byName.get(key);
  if (hit) return hit;
  for (const [k, b] of byName) {
    if (key && (key.includes(k) || k.includes(key))) return b;
  }
  return null;
}
function lookupPassage(byName, ref) {
  if (!byName || !ref || typeof ref !== 'string') return null;
  const raw = ref.split(';')[0].trim();
  if (/^referência:/i.test(raw)) return null;
  const take = (chapter, v1, v2) => {
    if (!chapter) return null;
    const parts = [];
    for (let i = v1 - 1; i < Math.min(v2, chapter.length); i++) {
      if (chapter[i]) parts.push(chapter[i]);
    }
    return parts.length ? parts.join(' ') : null;
  };
  let m = raw.match(/^(.+?)\s+(\d+)\s*:\s*(\d+)(?:\s*[–\-−]\s*(\d+))?/);
  if (m) {
    const book = findBook(byName, m[1]);
    if (!book) return null;
    return take(book.chapters[Number(m[2]) - 1], Number(m[3]), m[4] ? Number(m[4]) : Number(m[3]));
  }
  m = raw.match(/^(.+?)\s+(\d+)\s*[–\-−]\s*(\d+)\s*$/);
  if (m) {
    const book = findBook(byName, m[1]);
    if (!book) return null;
    const chapter = book.chapters[Number(m[2]) - 1];
    if (!chapter?.length) return null;
    return chapter.slice(0, Math.min(4, chapter.length)).join(' ');
  }
  m = raw.match(/^(.+?)\s+(\d+)\s*$/);
  if (m) {
    const book = findBook(byName, m[1]);
    if (!book) return null;
    const chapter = book.chapters[Number(m[2]) - 1];
    if (!chapter?.length) return null;
    return chapter.slice(0, Math.min(3, chapter.length)).join(' ');
  }
  return null;
}
function resolvePassage(q, study, bible) {
  const fromQ = (q.passageText || '').replace(/\s+/g, ' ').trim();
  const fromBible = lookupPassage(bible, q.verseRef || study?.passageRef);
  if (fromBible) {
    const clipped = clipWords(fromBible, 40);
    if (!fromQ || fromQ.endsWith('…') || words(fromQ).length < 8) return clipped;
    if (fromQ.length < clipped.length * 0.5) return clipped;
  }
  if (fromQ && !/^referência:/i.test(fromQ) && !/^por que /i.test(fromQ)) {
    return clipWords(fromQ, 40);
  }
  const studyText = clipWords(study?.passageText || '', 40);
  if (studyText.length >= 24 && !/^referência:/i.test(studyText)) return studyText;
  return fromBible ? clipWords(fromBible, 40) : fromQ;
}

function innerQuote(s) {
  const m = (s || '').match(/[“"]([^”"]+)[”"]/);
  return m ? m[1].trim() : '';
}

function cleanQuestion(raw, difficulty) {
  let t = (raw || '').replace(/\s+/g, ' ').trim();
  if (!t) return t;
  if (/olhando para o tema/i.test(t)) {
    const inner = innerQuote(t).replace(/:$/, '');
    if (inner.endsWith('?')) return inner.slice(0, 80);
    if (inner) return clip(`O que o texto diz: ${inner}?`.replace(/: \?/, '?'), 80);
    t = 'O que o texto afirma?';
  }
  t = t.replace(/^em profundidade:\s*/i, '');
  t = t.replace(/\s*\((?:levítico|gênesis|êxodo|números|deuteronômio|josué|juízes)[^)]*\)\s*/i, ' ');
  t = t.replace(/\s*revela sobre Deus e o povo\??$/i, '?');
  if (/por que estudar/i.test(t)) t = 'O que o trecho ensina?';
  if (/pergunta profunda/i.test(t)) t = 'O que o trecho sustenta?';
  if (/tens[aã]o teol/i.test(t)) t = 'Qual tensão o trecho apresenta?';
  if (/aplica[cç][aã]o justa/i.test(t)) t = 'O que o trecho pede do leitor?';
  if (/povo \(ou a personagem\)/i.test(t)) t = 'O que o texto desafia o povo a fazer?';
  t = t.replace(/\s+/g, ' ').trim();
  if (difficulty === 'profundezas' && /^o que “/.test(t)) {
    t = t.replace(/^o que /i, 'O que ');
  }
  if (t.length > 80) t = `${t.slice(0, 79).trim()}…`;
  return t;
}

function isAsk(text) {
  const t = (text || '').replace(/[.!?…]+$/, '').trim();
  return t.endsWith('?') || ASK_LEAD.test(t);
}

function isGluedClaim(text) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  if (!t || /[.!?:;]/.test(t)) return false;
  return /[a-záéíóúãõâêôç]\s+[A-ZÁÉÍÓÚÂÊÔÃÕ][a-záéíóú]{3,}/.test(t);
}

function unglueClaim(text) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  const m = t.match(/^(.{12,}?[a-záéíóúãõâêôç])\s+([A-ZÁÉÍÓÚÂÊÔÃÕ][a-záéíóú].+)$/);
  if (!m) return t;
  const keep = new Set(['Deus', 'Senhor', 'Jeová', 'Jesus', 'Moisés', 'Israel', 'Espírito']);
  const second = m[2].split(/\s+/)[0];
  if (keep.has(second)) return t;
  return m[1].trim();
}

function looksTruncated(text) {
  const t = (text || '').trim();
  if (/separaçã$/i.test(t)) return true;
  if (/[a-záéíóú]{6,}[aç]$/i.test(t) && !t.includes(' ') && t.length < 24) return true;
  return false;
}

function quoteOf(q) {
  return extractQuotedAnswer(q.feedbackCorrect || '');
}

function writeFeedback(q) {
  const ref = (q.verseRef || '').trim();
  const t = slot(q.type);
  const cid = cidOf(q);
  const correct = t === 'true_false' ? '' : optText(q, cid);
  const quote = quoteOf(q);
  const piece = clipPhrase(quote || correct || '', 42);
  const head = ref ? `${ref}` : 'O trecho';
  q.feedbackCorrect = clip(
    piece ? `Correto. ${head}: “${piece}”.` : `Correto. ${head}.`,
    100,
  );
  const wrong = {};
  for (const o of q.options || []) {
    const id = String(o.id);
    if (id === cid) continue;
    if (t === 'true_false' && id === 'true' && cid === 'true') continue;
    if (t === 'true_false' && id === 'false' && cid === 'false') continue;
    const inP = q.passageText && inText(q.passageText, o.text || '');
    wrong[id] = clip(
      inP && t !== 'true_false'
        ? 'Isso aparece no trecho, mas não responde.'
        : piece
          ? `Não. ${head}: “${piece}”.`
          : `Não. ${head} afirma outra coisa.`,
      100,
    );
  }
  q.feedbackWrong = wrong;
}

function realDistractors(candidates, correctFold, passage) {
  const out = [];
  const seen = new Set([correctFold]);
  for (const raw of candidates) {
    const t = styleOption(String(raw || '').trim(), passage);
    if (!t || isDummyDistractor(t) || isWeakDistractor(t) || isIncompletePhrase(t)) continue;
    if (passage && isPassagePrefix(t, passage)) continue;
    const k = answerKey(t);
    if (!k || seen.has(k)) continue;
    seen.add(k);
    out.push(t);
    if (out.length >= 2) break;
  }
  return out;
}

function applyVf(q, asTrue, passage, fact) {
  const ask = cleanQuestion(q.question || '', q.difficulty);
  const quote = quoteOf(q) || fact || optText(q, cidOf(q));
  let prompt;
  if (asTrue) {
    prompt = quote
      ? vfClaimFromParts(ask || q.question || '', quote)
      : vfClaim(ask || q.prompt || q.question || '');
  } else {
    const wrong = fact && foldKey(fact) !== foldKey(quote) ? fact : '';
    prompt = wrong
      ? vfClaimFromParts(ask || q.question || '', wrong)
      : vfClaim(unglueClaim(q.prompt || ask));
  }
  if (isAsk(prompt) || META.test(prompt) || isGluedClaim(prompt)) {
    const stem = passage ? words(passage).slice(0, 12).join(' ') : ask;
    prompt = asTrue
      ? vfClaimFromParts('o texto afirma', quote || stem)
      : vfClaimFromParts('o texto afirma', wrongFact(passage, quote));
  }
  q.type = 'true_false';
  q.prompt = vfClaim(unglueClaim(prompt));
  q.cue = q.prompt;
  q.correctAnswer = asTrue ? 'true' : 'false';
  q.correctOptionId = q.correctAnswer;
  q.options = [
    { id: 'true', text: 'Verdadeiro' },
    { id: 'false', text: 'Falso' },
  ];
  if (passage) q.passageText = passage;
  delete q.template;
  delete q.correctOrder;
  delete q.passageA;
  delete q.passageB;
}

function wrongFact(passage, quote) {
  const phrases = passagePhrases(passage || '', quote || '');
  return phrases[0] || 'uma tese que o trecho não afirma';
}

function applyTap(q, passage) {
  const quote = quoteOf(q);
  const current = optText(q, cidOf(q));
  let target =
    findTapTarget(current, passage) ||
    findTapTarget(quote, passage) ||
    growInPassage(passage, current);
  if (target && words(target).length < 3) {
    const grown = growInPassage(passage, target);
    if (grown && words(grown).length >= 3) target = grown;
  }
  if (!target || !inText(passage, target) || words(target).length < 2) return false;
  const others = passagePhrases(passage, target).filter(
    (p) => words(p).length >= 2 && inText(passage, p) && !isDummyDistractor(p),
  );
  if (!others.length) return false;
  const ask = cleanQuestion(q.question || q.prompt || '', q.difficulty) || 'Toque o trecho que responde.';
  q.type = 'tap';
  q.passageText = passage;
  q.prompt = ask;
  q.cue = ask;
  q.question = ask;
  q.options = [
    { id: 'a', text: styleOption(target, passage) },
    ...others.slice(0, 2).map((t, i) => ({
      id: String.fromCharCode(98 + i),
      text: styleOption(t, passage),
    })),
  ];
  q.correctAnswer = 'a';
  q.correctOptionId = 'a';
  q.skill = q.skill || 'observe';
  delete q.template;
  delete q.correctOrder;
  delete q.passageA;
  delete q.passageB;
  return true;
}

function applyComplete(q, passage) {
  const quote = quoteOf(q);
  const current = optText(q, cidOf(q));
  const target =
    findTapTarget(current, passage) ||
    findTapTarget(quote, passage) ||
    growInPassage(passage, current);
  if (!target || !inText(passage, target) || target.includes('…')) return false;
  const re = new RegExp(target.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
  if (!re.test(passage)) return false;
  const others = realDistractors(
    [...passagePhrases(passage, target), ...(q._pool || [])],
    answerKey(target),
    passage,
  );
  const ask = cleanQuestion(q.question || '', q.difficulty);
  q.type = 'complete';
  q.passageText = passage;
  q.template = passage.replace(re, '___');
  q.question = ask || q.question;
  q.prompt = ask && !GENERIC_COMPLETE.test(ask) ? ask : q.question || 'Qual palavra completa o trecho?';
  q.cue = q.prompt;
  q.options = [
    { id: 'a', text: styleOption(target, passage) },
    ...others.slice(0, 2).map((t, i) => ({
      id: String.fromCharCode(98 + i),
      text: styleOption(t, passage),
    })),
  ];
  q.correctAnswer = 'a';
  q.correctOptionId = 'a';
  q.skill = q.skill || 'understand';
  delete q.correctOrder;
  delete q.passageA;
  delete q.passageB;
  return q.options.length >= 2;
}

function orderPiecesFromPassage(passage) {
  const text = clipWords(passage || '', 55);
  if (!text) return null;
  const clauses = text
    .split(/[;.…]+/)
    .map((s) => s.trim())
    .filter((s) => s.length >= 10 && !looksTruncated(s))
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
    const pieces = [
      clipPhrase(w.slice(0, third).join(' '), 56),
      clipPhrase(w.slice(third, third * 2).join(' '), 56),
      clipPhrase(w.slice(third * 2).join(' '), 56),
    ].filter((s) => s.length >= 8 && !looksTruncated(s));
    if (pieces.length >= 3) return pieces.slice(0, 3);
  }
  return null;
}

function applyOrder(q, passage) {
  const pieces = orderPiecesFromPassage(passage);
  if (!pieces) return false;
  const ask = cleanQuestion(q.question || '', q.difficulty);
  const cue =
    ask && !GENERIC_ORDER.test(ask) && !META.test(ask)
      ? ask
      : 'Ordene as frases na ordem do texto.';
  q.type = 'order';
  q.prompt = cue;
  q.cue = cue;
  q.question = ask || cue;
  q.options = pieces.slice(0, 4).map((t, i) => ({
    id: String.fromCharCode(97 + i),
    text: styleOption(t, passage),
  }));
  q.correctOrder = q.options.map((o) => o.id);
  q.correctAnswer = q.correctOrder.join(',');
  q.correctOptionId = 'a';
  q.skill = q.skill || 'understand';
  q.passageText = passage;
  delete q.template;
  delete q.passageA;
  delete q.passageB;
  return true;
}

function applyChoice(q, passage, pool) {
  const quote = quoteOf(q);
  const cid = cidOf(q);
  let current = optText(q, cid);
  if (
    /^(verdadeiro|falso)$/i.test(current) ||
    ((q.options || []).length === 2 &&
      (q.options || []).every((o) => /^(verdadeiro|falso)$/i.test((o.text || '').trim())))
  ) {
    applyVf(q, !/^falso$/i.test(current), passage, quote);
    return true;
  }
  const full = preferredAnswer({
    option: current,
    quote,
    passage,
    question: q.question || '',
  });
  const correct = styleOption(full || current || quote, passage);
  if (!correct || isIncompletePhrase(correct) || isDummyDistractor(correct)) return false;
  const others = realDistractors(
    [
      ...(q.options || [])
        .filter((o) => String(o.id) !== String(cid))
        .map((o) => o.text),
      ...pool,
      ...(isNamingAsk(q.question || '') || isNameLikeAnswer(correct)
        ? []
        : passagePhrases(passage, correct)),
    ],
    answerKey(correct),
    passage,
  );
  const ask = cleanQuestion(q.question || q.prompt || '', q.difficulty) || 'O que o texto afirma?';
  q.type = 'choice';
  q.question = ask;
  q.prompt = ask;
  q.cue = ask;
  if (passage) q.passageText = passage;
  q.options = [
    { id: 'a', text: correct },
    ...others.slice(0, 2).map((t, i) => ({
      id: String.fromCharCode(98 + i),
      text: t,
    })),
  ];
  q.correctAnswer = 'a';
  q.correctOptionId = 'a';
  q.skill = q.difficulty === 'profundezas' ? 'interpret' : q.skill || 'understand';
  delete q.template;
  delete q.correctOrder;
  delete q.passageA;
  delete q.passageB;
  return q.options.length >= 2;
}

function applyConnect(q, passage, verseRef) {
  const parts = (passage || '')
    .split(/[;.…]+/)
    .map((s) => s.trim())
    .filter((s) => s.length >= 12);
  let textA = clip(parts[0] || '', 110);
  let textB = clip(parts[1] || '', 110);
  if (!textB) {
    const w = words(passage);
    if (w.length >= 16) {
      const mid = Math.floor(w.length / 2);
      textA = clip(w.slice(0, mid).join(' '), 110);
      textB = clip(w.slice(mid).join(' '), 110);
    }
  }
  if (!textA || !textB || foldKey(textA) === foldKey(textB)) return false;
  const candidates = [
    ...passagePhrases(textA, ''),
    ...passagePhrases(textB, ''),
    ...words(textA).filter((w) => w.length >= 5),
  ].filter((w) => w && w.length >= 4 && w.length <= 28 && !TAP_STOP.has(foldKey(w)));
  const target = candidates.find((w) => inText(textA, w) && inText(textB, w));
  if (!target) return false;
  const distractors = passagePhrases(`${textA} ${textB}`, target).filter(
    (w) => foldKey(w) !== foldKey(target) && !isDummyDistractor(w),
  );
  if (!distractors.length) return false;
  const ask = 'Qual palavra une os dois trechos?';
  q.type = 'connect';
  q.prompt = ask;
  q.cue = ask;
  q.question = ask;
  q.passageA = { ref: verseRef || q.verseRef || '', text: textA };
  q.passageB = { ref: verseRef || q.verseRef || '', text: textB };
  q.options = [
    { id: 'a', text: styleOption(target, `${textA} ${textB}`) },
    ...distractors.slice(0, 2).map((t, i) => ({
      id: String.fromCharCode(98 + i),
      text: styleOption(t, `${textA} ${textB}`),
    })),
  ];
  q.correctAnswer = 'a';
  q.correctOptionId = 'a';
  q.skill = 'connect';
  delete q.passageText;
  delete q.template;
  delete q.correctOrder;
  return q.options.length >= 2;
}

function uniqueId(base, used) {
  let id = base;
  let n = 2;
  while (used.has(id)) {
    id = `${base}${n}`;
    n += 1;
  }
  used.add(id);
  return id;
}

function cloneQ(q, suffix, used) {
  const copy = JSON.parse(JSON.stringify(q));
  const root = String(q.id || 'q').replace(/-x[a-z0-9]+$/i, '');
  copy.id = uniqueId(`${root}-x${suffix}`, used);
  return copy;
}

function repairOne(q, passage, pool) {
  const t = slot(q.type);
  q.question = cleanQuestion(q.question || q.prompt || '', q.difficulty) || q.question;
  if (passage && !(q.passageText || '').trim() && t !== 'connect') {
    q.passageText = passage;
  }

  if (t === 'tap') {
    if (applyTap(q, passage)) {
      stats.tapFixed += 1;
    } else if (applyComplete(q, passage)) {
      stats.converted += 1;
    } else {
      applyChoice(q, passage, pool);
      stats.converted += 1;
    }
    return;
  }
  if (t === 'complete') {
    if (applyComplete(q, passage)) stats.completeFixed += 1;
    else if (applyTap(q, passage)) stats.converted += 1;
    else applyChoice(q, passage, pool);
    return;
  }
  if (t === 'order') {
    const broken = (q.options || []).some((o) => looksTruncated(o.text) || isDummyDistractor(o.text));
    if (broken || GENERIC_ORDER.test(q.prompt || q.cue || '') || (q.options || []).length < 3) {
      if (applyOrder(q, passage)) stats.orderFixed += 1;
    } else {
      const ask = cleanQuestion(q.question || '', q.difficulty);
      if (ask && !GENERIC_ORDER.test(ask) && !META.test(ask)) {
        q.prompt = ask;
        q.cue = ask;
      } else {
        q.prompt = 'Ordene as frases na ordem do texto.';
        q.cue = q.prompt;
      }
      for (const o of q.options || []) {
        o.text = styleOption(o.text, passage);
      }
      stats.orderFixed += 1;
    }
    return;
  }
  if (t === 'connect') {
    const ok =
      q.passageA?.text &&
      q.passageB?.text &&
      (q.options || []).length >= 2 &&
      !((q.options || []).some((o) => isDummyDistractor(o.text)));
    if (!ok) {
      applyConnect(q, passage, q.verseRef) || applyChoice(q, passage, pool);
    } else {
      q.prompt = q.prompt || 'Qual palavra une os dois trechos?';
      q.cue = q.prompt;
    }
    return;
  }
  if (t === 'true_false') {
    const prompt = (q.prompt || q.cue || '').trim();
    const needs =
      isAsk(prompt) ||
      META.test(prompt) ||
      META.test(q.question || '') ||
      isGluedClaim(prompt) ||
      !prompt;
    if (needs) {
      const asTrue = cidOf(q) === 'true';
      applyVf(q, asTrue, passage, pool[0]);
      stats.vfFixed += 1;
    } else {
      q.prompt = vfClaim(unglueClaim(prompt));
      q.cue = q.prompt;
      q.options = [
        { id: 'true', text: 'Verdadeiro' },
        { id: 'false', text: 'Falso' },
      ];
      q.correctOptionId = cidOf(q);
      q.correctAnswer = q.correctOptionId;
    }
    return;
  }
  applyChoice(q, passage, pool);
  stats.choiceFixed += 1;
}

function expandGroup(list, all, used, study, bible) {
  const passage =
    list.map((q) => resolvePassage(q, study, bible)).find((p) => words(p).length >= 8) ||
    resolvePassage(list[0], study, bible);
  const pool = [];
  for (const q of list) {
    const quote = quoteOf(q);
    if (quote) pool.push(quote);
    for (const o of q.options || []) {
      if (o.text && !isDummyDistractor(o.text) && words(o.text).length >= 2) pool.push(o.text);
    }
  }
  const facts = [...new Set(pool.map((s) => s.trim()).filter(Boolean))];
  const byType = () => {
    const m = {};
    for (const q of list) m[slot(q.type)] = (m[slot(q.type)] || 0) + 1;
    return m;
  };
  const count = (t) => byType()[t] || 0;
  const surplus = () =>
    list.filter((q) => {
      const t = slot(q.type);
      if (t === 'true_false') return count('true_false') > 2;
      if (t === 'choice') return count('choice') > 2;
      return count(t) > 1;
    });

  const tryConvert = (need) => {
    const donor = surplus()[0];
    if (!donor) return false;
    const before = donor.type;
    const beforeOpts = donor.options;
    let ok = false;
    if (need === 'tap') ok = applyTap(donor, passage);
    else if (need === 'complete') ok = applyComplete(donor, passage);
    else if (need === 'order') ok = applyOrder(donor, passage);
    else if (need === 'connect') ok = applyConnect(donor, passage, donor.verseRef);
    else if (need === 'choice') ok = applyChoice(donor, passage, facts);
    else if (need === 'true_false') {
      applyVf(donor, count('true_false') % 2 === 0, passage, facts[0]);
      ok = true;
    }
    if (ok && slot(donor.type) === need) {
      stats.converted += 1;
      writeFeedback(donor);
      return true;
    }
    donor.type = before;
    donor.options = beforeOpts;
    return false;
  };

  const tryClone = (need) => {
    if (list.length >= 10) return false;
    const base =
      list.find((q) => slot(q.type) === 'choice') ||
      list.find((q) => slot(q.type) === 'true_false') ||
      list[0];
    if (!base) return false;
    const donor = cloneQ(base, need.slice(0, 3), used);
    let ok = false;
    if (need === 'tap') ok = applyTap(donor, passage);
    else if (need === 'complete') ok = applyComplete(donor, passage);
    else if (need === 'order') ok = applyOrder(donor, passage);
    else if (need === 'connect') ok = applyConnect(donor, passage, donor.verseRef);
    else if (need === 'choice') ok = applyChoice(donor, passage, facts);
    else if (need === 'true_false') {
      applyVf(donor, count('true_false') % 2 === 0, passage, facts[0]);
      ok = true;
    }
    if (!ok || slot(donor.type) !== need) return false;
    writeFeedback(donor);
    list.push(donor);
    all.push(donor);
    stats.cloned += 1;
    return true;
  };

  const ensure = (need) => {
    if (count(need) > 0) return;
    if (tryConvert(need)) return;
    tryClone(need);
  };

  let vfGuard = 0;
  while (count('true_false') > 2 && vfGuard < 8) {
    vfGuard += 1;
    const extra = list.find((q) => slot(q.type) === 'true_false');
    if (!extra) break;
    const before = extra.type;
    const beforeOpts = extra.options;
    const ok =
      applyTap(extra, passage) ||
      applyComplete(extra, passage) ||
      applyOrder(extra, passage) ||
      applyConnect(extra, passage, extra.verseRef);
    if (ok && slot(extra.type) !== 'true_false') {
      stats.converted += 1;
      writeFeedback(extra);
    } else {
      extra.type = before;
      extra.options = beforeOpts;
      break;
    }
  }

  ensure('tap');
  ensure('complete');
  ensure('choice');
  ensure('order');
  ensure('connect');
  if (count('true_false') === 0) ensure('true_false');

  const forceChoice = () => {
    const base =
      list.find((q) => (q.passageText || '').length >= 20) ||
      list.find((q) => slot(q.type) === 'choice') ||
      list[0];
    if (!base) return false;
    const passage =
      (base.passageText || '').trim() ||
      list.map((q) => q.passageText || '').find((p) => words(p).length >= 8) ||
      '';
    const usableFacts = facts.filter(
      (f) =>
        words(f).length >= 2 &&
        !isDummyDistractor(f) &&
        !/^(verdadeiro|falso)$/i.test(f) &&
        !isIncompletePhrase(f) &&
        !isPassagePrefix(f, passage) &&
        !isVerseSnippet(f, passage),
    );
    const correct = usableFacts[0];
    if (!correct) return false;
    const others = realDistractors(
      usableFacts.filter((f) => foldKey(f) !== foldKey(correct)),
      answerKey(correct),
      passage,
    );
    if (!others.length) return false;
    const donor = cloneQ(base, 'ch', used);
    const ask = cleanQuestion(base.question || '', base.difficulty) || 'O que o trecho afirma?';
    donor.type = 'choice';
    donor.question = ask;
    donor.prompt = ask;
    donor.cue = ask;
    donor.passageText = passage || donor.passageText;
    donor.options = [
      { id: 'a', text: styleOption(correct, passage) },
      ...others.slice(0, 2).map((t, i) => ({
        id: String.fromCharCode(98 + i),
        text: styleOption(t, passage),
      })),
    ];
    donor.correctAnswer = 'a';
    donor.correctOptionId = 'a';
    delete donor.template;
    delete donor.correctOrder;
    delete donor.passageA;
    delete donor.passageB;
    writeFeedback(donor);
    list.push(donor);
    all.push(donor);
    stats.cloned += 1;
    return true;
  };

  const fillOrder = ['tap', 'complete', 'order', 'choice', 'connect'];
  let guard = 0;
  while (list.length < 8 && guard < 14) {
    guard += 1;
    const missing = fillOrder.filter((t) => count(t) < 1);
    let added = false;
    for (const need of missing) {
      if (list.length >= 8) break;
      if (tryClone(need)) {
        added = true;
        break;
      }
    }
    if (added) continue;
    if (count('choice') < 3 && forceChoice()) continue;
    if (count('true_false') < 2) {
      if (tryClone('true_false')) continue;
    }
    break;
  }
}

function profundezasPass(questions) {
  const semente = new Map();
  for (const q of questions) {
    if (q.difficulty !== 'semente') continue;
    const stem = foldKey(cleanQuestion(q.question || '', 'semente'));
    if (stem.length < 12) continue;
    const key = `${q.trail}|${q.section}|${stem}`;
    semente.set(key, q);
  }
  for (const q of questions) {
    if (q.difficulty !== 'profundezas') continue;
    const stem = foldKey(cleanQuestion(q.question || '', 'profundezas'));
    const key = `${q.trail}|${q.section}|${stem}`;
    if (!semente.has(key) && !/^em profundidade/i.test(q.question || '')) continue;
    const ref = q.verseRef || 'o trecho';
    q.question = clip(`O que ${ref} sustenta?`, 80);
    q.prompt = q.type === 'true_false' ? q.prompt : q.question;
    q.cue = q.type === 'true_false' ? q.cue : q.question;
    q.skill = 'interpret';
  }
}

function authorCantico(questions, used, bible) {
  const section = 'deuteronomio-despedida-02-cantico-de-moises';
  if (questions.some((q) => q.section === section)) return;
  const p32 = lookupPassage(bible, 'Deuteronômio 32:1-4') || '';
  const p33 = lookupPassage(bible, 'Deuteronômio 33:1') || '';
  const p34 = lookupPassage(bible, 'Deuteronômio 34:5-6') || '';
  const specs = [
    {
      type: 'tap',
      diff: 'semente',
      n: '01',
      question: 'Como Moisés é chamado ao abençoar Israel?',
      verseRef: 'Deuteronômio 33:1',
      passage: p33,
    },
    {
      type: 'choice',
      diff: 'semente',
      n: '02',
      question: 'Quem deu a bênção a Israel antes de morrer?',
      verseRef: 'Deuteronômio 33:1',
      passage: p33,
      correct: 'Moisés, homem de Deus',
      wrong: ['Josué, filho de Num', 'Arão, o sacerdote'],
    },
    {
      type: 'complete',
      diff: 'semente',
      n: '03',
      question: 'De onde Jeová veio, segundo a bênção?',
      verseRef: 'Deuteronômio 33:2',
      passage: lookupPassage(bible, 'Deuteronômio 33:2') || p33,
    },
    {
      type: 'true_false',
      diff: 'semente',
      n: '04',
      question: 'Moisés é chamado homem de Deus.',
      verseRef: 'Deuteronômio 33:1',
      passage: p33,
      asTrue: true,
    },
    {
      type: 'order',
      diff: 'semente',
      n: '05',
      question: 'Ordene o fio final de Deuteronômio.',
      verseRef: 'Deuteronômio 33:1; 34:5',
      passage: `${p33} ${p34}`.trim(),
    },
    {
      type: 'connect',
      diff: 'semente',
      n: '06',
      question: 'Qual palavra une os trechos?',
      verseRef: 'Deuteronômio 32:1; 33:1',
      passage: `${p32} ${p33}`.trim(),
    },
    {
      type: 'tap',
      diff: 'semente',
      n: '07',
      question: 'Onde Moisés morreu?',
      verseRef: 'Deuteronômio 34:5',
      passage: p34,
    },
    {
      type: 'choice',
      diff: 'semente',
      n: '08',
      question: 'O que o cântico pede no início?',
      verseRef: 'Deuteronômio 32:1',
      passage: p32,
      correct: 'dai ouvidos, ó céus',
      wrong: ['edificai uma torre', 'volte ao Egito'],
    },
  ];

  const diffs = [
    ['semente', 'sem', 'observe'],
    ['caminhada', 'cam', 'understand'],
    ['profundezas', 'pro', 'interpret'],
  ];
  for (const [diff, short, skill] of diffs) {
    for (const spec of specs) {
      const q = {
        id: uniqueId(`deuteron-${short}-deuteronomio-despedida-2-${spec.n}`, used),
        trail: 'deuteronomio',
        difficulty: diff,
        section,
        question: spec.question,
        options: [],
        correctOptionId: 'a',
        feedbackCorrect: '',
        feedbackWrong: {},
        verseRef: spec.verseRef,
        type: spec.type,
        prompt: spec.question,
        cue: spec.question,
        correctAnswer: 'a',
        skill: diff === 'profundezas' ? 'interpret' : skill,
        passageText: clipWords(spec.passage, 40),
      };
      if (diff === 'profundezas') {
        q.question = clip(`O que ${spec.verseRef} sustenta?`, 80);
      } else if (diff === 'caminhada' && spec.type === 'choice') {
        q.question = spec.question;
      }
      const passage = q.passageText;
      let ok = false;
      if (spec.type === 'tap') ok = applyTap(q, passage);
      else if (spec.type === 'complete') ok = applyComplete(q, passage);
      else if (spec.type === 'order') ok = applyOrder(q, passage);
      else if (spec.type === 'connect') ok = applyConnect(q, passage, spec.verseRef);
      else if (spec.type === 'true_false') {
        applyVf(q, spec.asTrue !== false, passage, spec.correct);
        ok = true;
      } else {
        q.feedbackCorrect = `Correto. ${spec.verseRef}: “${spec.correct}”.`;
        q.options = [
          { id: 'a', text: spec.correct },
          { id: 'b', text: spec.wrong[0] },
          { id: 'c', text: spec.wrong[1] },
        ];
        ok = applyChoice(q, passage, spec.wrong);
      }
      if (!ok) applyChoice(q, passage, spec.wrong || []);
      writeFeedback(q);
      questions.push(q);
      stats.authoredEmpty += 1;
    }
  }
}

function polishOptions(q) {
  const t = slot(q.type);
  const passage = q.passageText || q.template || '';
  if (t === 'true_false') {
    q.options = [
      { id: 'true', text: 'Verdadeiro' },
      { id: 'false', text: 'Falso' },
    ];
    return;
  }
  for (const o of q.options || []) {
    o.text = styleOption(o.text, passage);
  }
}

function main() {
  const bible = buildBibleIndex();
  const studies = readJson('mission_studies.json');
  const studyBy = new Map(Object.entries(studies || {}));
  const used = new Set();
  const files = [];

  for (const file of BANK_FILES) {
    const raw = readJson(file);
    const wrapped = Array.isArray(raw);
    const questions = wrapped ? raw : raw.questions || [];
    for (const q of questions) if (q.id) used.add(q.id);
    files.push({ file, raw, wrapped, questions });
  }

  const all = files.flatMap((f) => f.questions);
  console.log('bancos:', files.map((f) => f.file).join(', '));
  authorCantico(all, used, bible);
  const cantico = all.filter((q) => q.section === 'deuteronomio-despedida-02-cantico-de-moises');
  const ot = files.find((f) => f.file === 'ot_questions.json');
  if (ot) {
    for (const q of cantico) {
      if (!ot.questions.includes(q)) ot.questions.push(q);
    }
  }

  for (const { questions } of files) {
    const poolMap = optionPoolFromQuestions(questions);
    let i = 0;
    for (const q of questions) {
      i += 1;
      if (i % 800 === 0) console.log(`  repara ${i}/${questions.length}`);
      const study = studyBy.get(q.section) || null;
      const passage = resolvePassage(q, study, bible);
      const pool = poolMap.get(`${q.section || ''}::${q.difficulty || ''}`) || [];
      q._pool = pool;
      repairQuestion(q, pool);
      repairOne(q, passage, pool);
      polishOptions(q);
      writeFeedback(q);
      delete q._pool;
    }
  }

  profundezasPass(all);

  for (const { questions } of files) {
    const groups = new Map();
    for (const q of questions) {
      const key = `${q.trail || ''}::${q.section || ''}::${q.difficulty || ''}`;
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key).push(q);
    }
    let g = 0;
    for (const list of groups.values()) {
      g += 1;
      if (g % 200 === 0) console.log(`  expande grupo ${g}/${groups.size}`);
      const study = studyBy.get(list[0]?.section) || null;
      expandGroup(list, questions, used, study, bible);
      for (const q of list) {
        polishOptions(q);
        writeFeedback(q);
        delete q._pool;
      }
    }
  }

  profundezasPass(all);

  for (const { questions } of files) {
    const groups = new Map();
    for (const q of questions) {
      const key = `${q.trail || ''}::${q.section || ''}::${q.difficulty || ''}`;
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key).push(q);
    }
    for (const list of groups.values()) {
      const study = studyBy.get(list[0]?.section) || null;
      const passage =
        list.map((q) => resolvePassage(q, study, bible)).find((p) => words(p).length >= 8) ||
        '';
      const facts = [];
      for (const q of list) {
        const quote = quoteOf(q);
        if (quote) facts.push(quote);
        for (const o of q.options || []) {
          const t = (o.text || '').trim();
          if (t && words(t).length >= 2 && !/^(verdadeiro|falso)$/i.test(t) && !isDummyDistractor(t)) {
            facts.push(t);
          }
        }
      }
      let guard = 0;
      while (list.length < 8 && guard < 4) {
        guard += 1;
        const base = list.find((q) => (q.passageText || '').length >= 12) || list[0];
        const donor = cloneQ(base, 'fill', used);
        const palco = (base.passageText || passage || '').trim();
        const asTrue = list.filter((q) => slot(q.type) === 'true_false').length % 2 === 0;
        if (list.filter((q) => slot(q.type) === 'true_false').length < 2 && palco) {
          applyVf(donor, asTrue, palco, facts[0]);
        } else if (!applyChoice(donor, palco, facts)) {
          const phrases = passagePhrases(palco, '');
          if (phrases.length < 2) break;
          donor.type = 'choice';
          donor.question = 'O que o trecho afirma?';
          donor.prompt = donor.question;
          donor.cue = donor.question;
          donor.options = phrases.slice(0, 3).map((t, i) => ({
            id: String.fromCharCode(97 + i),
            text: styleOption(t, palco),
          }));
          donor.correctAnswer = 'a';
          donor.correctOptionId = 'a';
          donor.passageText = palco;
        }
        writeFeedback(donor);
        list.push(donor);
        questions.push(donor);
        stats.cloned += 1;
      }
    }
  }

  for (const { questions } of files) {
    for (const q of questions) {
      const t = slot(q.type);
      const passage = (q.passageText || '').trim();
      if (t === 'true_false') {
        let p = (q.prompt || '').trim();
        if (p.includes('?') || isAsk(p) || isGluedClaim(p) || META.test(p)) {
          const clause = (passage.split(/[.!?]/)[0] || '').trim();
          const body = quoteOf(q) || clause || unglueClaim(p).replace(/[?]+$/g, '');
          q.prompt = vfClaim(body.includes('?') ? `o trecho registra esta pergunta: ${body.replace(/\?+$/, '')}` : body);
          if (q.prompt.includes('?')) {
            q.prompt = `O trecho afirma: “${clipPhrase(clause || body.replace(/[?]+$/g, ''), 80)}”.`;
          }
          q.cue = q.prompt;
          q.correctAnswer = 'true';
          q.correctOptionId = 'true';
          q.options = [
            { id: 'true', text: 'Verdadeiro' },
            { id: 'false', text: 'Falso' },
          ];
          writeFeedback(q);
        }
      }
      if (t === 'order' && /monte a sequ/i.test((q.prompt || '') + (q.cue || ''))) {
        const ask = cleanQuestion(q.question || '', q.difficulty);
        q.prompt = ask && !/monte a sequ/i.test(ask) ? ask : 'Ordene as frases na ordem do texto.';
        q.cue = q.prompt;
      }
      if (t === 'tap' && passage) {
        const a = (q.options || []).find((o) => String(o.id) === cidOf(q) || String(o.id) === 'a');
        if (a && words(a.text).length < 3) {
          const grown = growInPassage(passage, a.text);
          if (grown && words(grown).length >= 3 && inText(passage, grown)) a.text = grown;
          else {
            const w = words(passage);
            const idx = w.findIndex((x) => foldKey(x).includes(foldKey(a.text.split(' ')[0] || '')));
            if (idx >= 0) {
              const slice = w.slice(Math.max(0, idx), Math.max(0, idx) + 4).join(' ');
              if (inText(passage, slice) && words(slice).length >= 3) a.text = slice;
            }
          }
        }
      }
      if (t !== 'true_false' && (q.options || []).length < 2 && passage) {
        const extra = passagePhrases(passage, optText(q, cidOf(q)))[0];
        if (extra) {
          q.options = [
            ...(q.options || []),
            { id: 'b', text: styleOption(extra, passage) },
          ];
          writeFeedback(q);
        }
      }
    }
  }

  const trails = readJson('trails.json');
  for (const trail of trails) {
    for (const mod of trail.modules || []) {
      for (const m of mod.missions || []) {
        if (m.slug !== 'deuteronomio-despedida-02-cantico-de-moises') continue;
        m.centralInsight = 'Moisés abençoa e morre; a palavra permanece com o povo.';
        m.objective = 'O que o fim de Deuteronômio revela sobre a palavra e o servo?';
        m.hookRef = 'Deuteronômio 32:1–4; 33:1; 34:5';
        const song = lookupPassage(bible, 'Deuteronômio 32:1-3');
        if (song) m.hookVerse = clipWords(song, 28);
      }
    }
  }
  writeJson('trails.json', trails);

  for (const { file, raw, wrapped, questions } of files) {
    for (const q of questions) delete q._pool;
    if (wrapped) writeJson(file, questions);
    else writeJson(file, { ...raw, questions });
  }

  console.log(JSON.stringify(stats, null, 2));
  console.log(`perguntas: ${files.reduce((n, f) => n + f.questions.length, 0)}`);
}

main();
