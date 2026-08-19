/**
 * Frase de resposta completa — nunca recorte ( «e a terra», «querubins e» ).
 * Usado pelo gerador (migrate_session_pattern) e pelo reparo do banco.
 */

export const TAP_STOP = new Set([
  'porque',
  'quando',
  'onde',
  'como',
  'qual',
  'deus',
  'senhor',
  'povo',
  'terra',
  'israel',
  'texto',
  'passo',
  'sobre',
  'depois',
  'antes',
  'jeova',
  'moises',
  'falou',
  'disse',
]);

const DANGLING_START = /^(e|mas|porém|porem|ou|nem)\s+/i;
const DANGLING_END =
  /\s+(e|mas|ou|nem|de|do|da|dos|das|que|para|por|com|os|as|o|a|ao|à)$/i;
const HANGING_PREP = /^(de|do|da|dos|das|sobre)\s+\S+$/i;
const PEDAGOGICAL =
  /^(porque|já|adão|luminares|como o|o texto|olhando|à luz|em profundidade)\b/i;

export function foldKey(s) {
  return (s || '')
    .normalize('NFD')
    .replace(/\p{M}/gu, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}

export function answerKey(s) {
  return foldKey(s)
    .split(' ')
    .filter(Boolean)
    .map((w) => {
      if (w === 'os' || w === 'o') return 'o';
      if (w === 'as' || w === 'a') return 'a';
      if (w.endsWith('s') && w.length > 3) return w.slice(0, -1);
      return w;
    })
    .join(' ');
}

export function extractQuotedAnswer(feedback) {
  const m = (feedback || '').match(/[“"«]([^”"»]+)[”"»]/);
  return m ? m[1].trim() : '';
}

export function clipPhrase(text, max) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  if (t.length <= max) return stripDanglingEnd(t);
  let cut = t.slice(0, max).trim();
  const sp = cut.lastIndexOf(' ');
  if (sp > max * 0.45) cut = cut.slice(0, sp);
  return stripDanglingEnd(cut.replace(/[.,;:…]+$/g, '').trim());
}

function stripDanglingEnd(t) {
  return t.replace(
    /[,;:]?\s+(e|mas|ou|nem|de|do|da|dos|das|que|para|por|com)$/i,
    '',
  ).trim();
}

export function isIncompletePhrase(text) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  if (!t) return true;
  if (/[…]$/.test(t) && t.length < 36) return true;
  if (DANGLING_END.test(t)) return true;
  if (HANGING_PREP.test(t)) return true;
  if (DANGLING_START.test(t)) {
    const words = t.split(/\s+/);
    if (t.includes(':') && words.length >= 4) return false;
    if (t.includes(',') && words.length >= 5) return false;
    if (words.length >= 5) return false;
    if (/^(e|mas|ou|nem)\s+(o|a|os|as|um|uma)\b/i.test(t) && words.length <= 4) {
      return true;
    }
    if (/^(e|mas|ou|nem)\s+\p{L}+$/iu.test(t)) return false;
    return words.length <= 3;
  }
  if (/^(que|porque)\s+\S+(\s+\S+)?$/i.test(t) && wordsCount(t) <= 3) {
    return true;
  }
  if (/^para\s+\S+$/i.test(t)) return true;
  if (/^(não|nao)\s+havia$/i.test(t)) return true;
  if (/^(sobre os|sobre as|sobre a|sobre o)$/i.test(t)) return true;
  return false;
}

function wordsCount(s) {
  return (s || '').trim().split(/\s+/).filter(Boolean).length;
}

export function isPedagogicalQuote(quote) {
  const q = (quote || '').trim();
  if (!q) return true;
  if (wordsCount(q) > 18) return true;
  if (PEDAGOGICAL.test(q)) return true;
  if (
    /\b(é ligada|aparecem na|inclui terra|contrasta|revela|administram|converter)\b/i.test(
      q,
    )
  ) {
    return true;
  }
  return false;
}

function accentBody(word) {
  const map = {
    a: '[aáàâãä]',
    e: '[eéêèë]',
    i: '[iíìîï]',
    o: '[oóôõòö]',
    u: '[uúùûü]',
    c: '[cç]',
  };
  return [...word]
    .map((ch) => {
      if (map[ch]) return map[ch];
      return /[.*+?^${}()|[\]\\]/.test(ch) ? `\\${ch}` : ch;
    })
    .join('');
}

export function passageForm(passage, needle) {
  if (!passage || !needle) return '';
  const parts = foldKey(needle).split(' ').filter(Boolean);
  if (!parts.length) return '';
  const body = parts.map((w) => accentBody(w)).join('\\s+');
  const m = passage.match(new RegExp(body, 'i'));
  return m ? m[0] : '';
}

function findOccurrence(passage, needle) {
  if (!passage || !needle) return null;
  const found = passageForm(passage, needle);
  if (!found) return null;
  const i = passage.indexOf(found);
  if (i < 0) return null;
  return { start: i, end: i + found.length, text: found };
}

const DET = '(?:o|os|a|as|um|uma|ao|à|às|aos|do|da|dos|das|de|no|na|nos|nas)';
const WORD = '[\\p{L}]+(?:-[\\p{L}]+)?';

export function growInPassage(passage, option) {
  let occ = findOccurrence(passage, option);
  if (!occ) {
    for (const v of variants(option)) {
      occ = findOccurrence(passage, v);
      if (occ) break;
    }
  }
  if (!occ) return '';
  let { start, end } = occ;
  let text = occ.text;

  const takeLeft = () => {
    const left = passage.slice(0, start);
    const m = left.match(
      new RegExp(`(?:${DET}\\s+)?(?!e\\b|mas\\b|ou\\b|nem\\b)(${WORD})[,;:]?\\s+$`, 'iu'),
    );
    if (!m) return false;
    start -= m[0].length;
    return true;
  };

  if (DANGLING_START.test(text)) {
    takeLeft();
    text = passage.slice(start, end);
    if (DANGLING_START.test(text.trim()) || /,\s+e\b/i.test(text)) takeLeft();
  }
  text = passage.slice(start, end);
  if (HANGING_PREP.test(text.trim())) {
    takeLeft();
  }

  text = passage.slice(start, end);
  if (DANGLING_END.test(text.trim()) || HANGING_PREP.test(text.trim())) {
    const right = passage.slice(end);
    const m = right.match(
      new RegExp(`^(?:\\s+(?:${DET}\\s+)?${WORD}){1,7}`, 'iu'),
    );
    if (m) end += m[0].length;
  }

  text = passage.slice(start, end).replace(/^[\s,;:]+|[\s,;:.]+$/g, '');

  if (isIncompletePhrase(text)) {
    const right = passage.slice(end);
    const m = right.match(
      new RegExp(`^(?:\\s+(?:${DET}\\s+)?${WORD}){1,5}`, 'iu'),
    );
    if (m) {
      end += m[0].length;
      text = passage.slice(start, end).replace(/^[\s,;:]+|[\s,;:.]+$/g, '');
    }
  }
  return text;
}

function variants(text) {
  const t = (text || '').trim();
  if (!t) return [];
  const out = [t];
  const push = (s) => {
    if (s && s !== t) out.push(s);
  };
  push(t.replace(/os céus/gi, 'o céu').replace(/céus/gi, 'céu'));
  push(t.replace(/\bo céu\b/gi, 'os céus'));
  push(t.replace(/túnicas de peles/gi, 'vestes de peles'));
  push(t.replace(/vestes de peles/gi, 'túnicas de peles'));
  return out;
}

export function isNamingAsk(question) {
  const t = cleanStem(question);
  return /^(como se chama|que nome|qual (?:é )?(?:o |a )?(?:novo |nova )?nome|quem é|quem são|quem foi|de quem)\b/i.test(
    t,
  );
}

export function isNameLikeAnswer(text) {
  return looksLikeName(text);
}

/** Opção que é o começo do palco — nunca serve como alternativa de escolha. */
export function isPassagePrefix(text, passage, minWords = 4) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  const p = (passage || '').replace(/\s+/g, ' ').trim();
  if (!t || !p || wordsCount(t) < minWords) return false;
  const tf = foldKey(t);
  const pf = foldKey(p);
  if (tf.length < 10) return false;
  return pf.startsWith(tf);
}

export function isVerseSnippet(text, passage) {
  if (isPassagePrefix(text, passage, 4)) return true;
  const t = (text || '').replace(/\s+/g, ' ').trim();
  const p = (passage || '').replace(/\s+/g, ' ').trim();
  if (!t || !p || wordsCount(t) < 6) return false;
  const tf = foldKey(t);
  const pf = foldKey(p);
  return pf.includes(tf) && tf.length >= 24;
}

function asksHowVerseStarts(question) {
  return /como (começa|inicia)|primeiras palavras|in[ií]cio do (texto|vers)/i.test(
    cleanStem(question),
  );
}

function keepFactualAnswer(option, question) {
  return isNameLikeAnswer(option) || isNamingAsk(question);
}

export function preferredAnswer({ option, quote, passage, question = '' }) {
  const opt = (option || '').replace(/\s+/g, ' ').trim();
  const q = (quote || '').replace(/\s+/g, ' ').trim();
  const grown = growInPassage(passage || '', opt);

  if (keepFactualAnswer(opt, question)) {
    if (
      grown &&
      foldKey(grown).includes(foldKey(opt)) &&
      wordsCount(grown) <= 4 &&
      !isPassagePrefix(grown, passage)
    ) {
      return grown;
    }
    return opt;
  }

  if (grown && !isIncompletePhrase(grown) && wordsCount(grown) >= 2) {
    return grown;
  }

  const quoteForm =
    passageForm(passage || '', q) ||
    growInPassage(passage || '', q) ||
    '';

  if (q && !isPedagogicalQuote(q) && !isIncompletePhrase(q)) {
    if (quoteForm && !isIncompletePhrase(quoteForm)) return quoteForm;
    if (isIncompletePhrase(opt) || isThinVsQuote(opt, q, question)) {
      return q;
    }
  }

  if (grown && !isIncompletePhrase(grown)) return grown;
  if (q && isIncompletePhrase(opt) && foldKey(opt) && foldKey(q).includes(foldKey(opt))) {
    const clause = q.split(/[,;]/)[0].trim();
    const form =
      passageForm(passage || '', clause) ||
      growInPassage(passage || '', clause) ||
      clause;
    if (form && !isIncompletePhrase(form)) return form;
  }
  return stripDanglingEnd(opt);
}

function isThinVsQuote(option, quote, question) {
  if (!option || !quote) return false;
  if (isPedagogicalQuote(quote)) return false;
  if (!foldKey(quote).includes(foldKey(option))) return false;
  const ow = wordsCount(option);
  const qw = wordsCount(quote);
  if (ow >= qw) return false;
  if (ow <= 2 && qw >= 2 && qw <= 10) {
    if (/^[A-ZÁÉÍÓÚÂÊÔÃÕ]/u.test(option) && ow === 1) return false;
    if (/^(quem|qual|quais|o que|para que|como|sobre o que)\b/i.test(question)) {
      return true;
    }
    if (isIncompletePhrase(option)) return true;
    if (ow === 1 && qw >= 3) return true;
  }
  return false;
}

/** Distratores de tap: trechos completos do palco, nunca 1 verbo. */
export function passagePhrases(passage, exclude) {
  const ex = foldKey(exclude);
  const chunks = (passage || '')
    .split(/[,;:.!?—–]+/)
    .map((s) => s.trim())
    .filter((s) => wordsCount(s) >= 2 && wordsCount(s) <= 8 && s.length >= 8);

  const ngrams = [];
  const words = (passage || '')
    .replace(/[“”"']/g, '')
    .split(/\s+/)
    .map((w) => w.replace(/^[^\p{L}]+|[^\p{L}]+$/gu, ''))
    .filter(Boolean);
  for (let n = 4; n >= 2; n--) {
    for (let i = 0; i <= words.length - n; i++) {
      const phrase = words.slice(i, i + n).join(' ');
      if (phrase.length < 8 || phrase.length > 48) continue;
      if (isIncompletePhrase(phrase)) continue;
      ngrams.push(phrase);
    }
  }

  const uniq = [];
  for (const p of [...chunks, ...ngrams]) {
    const k = foldKey(p);
    if (!k || k === ex) continue;
    if (ex && (k.includes(ex) || ex.includes(k))) continue;
    if (TAP_STOP.has(k)) continue;
    if (uniq.some((u) => foldKey(u) === k)) continue;
    if (isIncompletePhrase(p)) continue;
    uniq.push(p);
    if (uniq.length >= 3) break;
  }
  return uniq;
}

export function findTapTarget(correctText, passage) {
  const c = (correctText || '').trim();
  if (!passage || !c) return '';
  const tryNeedle = (raw) => {
    if (!raw) return '';
    const grown = growInPassage(passage, raw);
    const hit = grown || passageForm(passage, raw);
    if (!hit) return '';
    if (hit.length < 3 || hit.length > 72) return '';
    if (isIncompletePhrase(hit) && hit.length < 18) return '';
    return hit;
  };

  const direct = tryNeedle(c);
  if (direct && !isIncompletePhrase(direct)) return direct;

  for (const v of variants(c)) {
    const hit = tryNeedle(v);
    if (hit && !isIncompletePhrase(hit)) return hit;
  }

  const parts = c
    .split(/[/—–()]/)
    .map((s) => s.trim())
    .filter(Boolean);
  for (const part of parts) {
    if (part.length >= 8 && part.includes(' ')) {
      const hit = tryNeedle(part);
      if (hit && !isIncompletePhrase(hit)) return hit;
    }
  }

  const words = c.split(/\s+/).filter(Boolean);
  for (let n = Math.min(8, words.length); n >= 2; n--) {
    for (let i = 0; i <= words.length - n; i++) {
      const phrase = words.slice(i, i + n).join(' ');
      const clean = phrase.replace(/^[^\p{L}]+|[^\p{L}]+$/gu, '');
      if (clean.length < 8) continue;
      const hit = tryNeedle(clean);
      if (hit && !isIncompletePhrase(hit)) return hit;
    }
  }

  return direct && !isIncompletePhrase(direct) ? direct : '';
}

function looksLikeVerseTokenList(options, passage) {
  if (!passage || !options?.length) return false;
  const p = foldKey(passage);
  let fromVerse = 0;
  let weak = 0;
  for (const o of options) {
    const t = (o.text || '').trim();
    if (!t) continue;
    if (p.includes(foldKey(t))) fromVerse += 1;
    if (isWeakDistractor(t) || isIncompletePhrase(t)) weak += 1;
  }
  return fromVerse === options.length && weak >= 2;
}

export function isWeakDistractor(text) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  if (!t || isIncompletePhrase(t)) return true;
  const n = wordsCount(t);
  if (n === 1) {
    if (/^[A-ZÁÉÍÓÚÂÊÔÃÕ][\p{L}]+$/u.test(t) && t.length >= 3) return false;
    return true;
  }
  if (n === 2 && /^(o|a)\s+\p{L}+$/iu.test(t) === false) {
    if (/^(não|nao)\s/i.test(t)) return true;
  }
  return false;
}

export function uniqueComplete(texts, correctFold, { passage = '', question = '' } = {}) {
  const out = [];
  const seen = new Set([correctFold]);
  const blockPrefix = passage && !asksHowVerseStarts(question);
  const naming = isNamingAsk(question);
  for (const t of texts) {
    const s = (t || '').replace(/\s+/g, ' ').trim();
    if (!s || isWeakDistractor(s)) continue;
    if (blockPrefix && isPassagePrefix(s, passage)) continue;
    if (naming && isVerseSnippet(s, passage)) continue;
    const k = answerKey(s);
    if (!k || seen.has(k)) continue;
    if (s.length < 4 || s.length > 72) continue;
    seen.add(k);
    out.push(s);
  }
  return out;
}

export function rebuildOptions({
  options,
  correctId,
  correctText,
  passage,
  pool = [],
  question = '',
}) {
  const full = (correctText || '').replace(/\s+/g, ' ').trim();
  const cf = answerKey(full);
  const others = (options || []).filter((o) => String(o.id) !== String(correctId));
  const otherIds = others.map((o) => String(o.id));
  const existing = others.map((o) => (o.text || '').trim());
  const tokens = looksLikeVerseTokenList(options, passage);
  const naming = keepFactualAnswer(full, question);
  const verseFill = naming ? [] : passagePhrases(passage, full);
  const filter = { passage, question };

  const cleanExisting = existing.filter((t) => !isDummyDistractor(t));
  let distractors = uniqueComplete(cleanExisting, cf, filter);
  if (tokens && naming) {
    distractors = uniqueComplete([...pool], cf, filter);
  } else if (tokens) {
    distractors = uniqueComplete([...pool, ...verseFill], cf, filter);
  } else if (distractors.length < 2) {
    distractors = uniqueComplete(
      [...distractors, ...pool, ...verseFill],
      cf,
      filter,
    );
  }
  const out = [{ id: String(correctId), text: full }];
  for (let i = 0; i < Math.min(2, distractors.length); i++) {
    out.push({
      id: otherIds[i] || String.fromCharCode(98 + i),
      text: distractors[i],
    });
  }
  return out;
}

export function replaceInTemplate(template, passage, answer) {
  const tpl = (template || '').trim();
  const ans = (answer || '').trim();
  const palco = (passage || '').trim();
  if (!ans) return tpl;

  const source = palco || tpl.replace(/_{3,}/g, ans);
  if (!source) return tpl;
  const found = passageForm(source, ans);
  if (found) {
    return source.replace(found, '___');
  }
  if (tpl.includes('___')) return tpl;
  return tpl;
}

export function repairQuestion(q, pool = []) {
  const type = (q.type || 'choice').toLowerCase();
  if (type === 'true_false' || type === 'truefalse' || type === 'tf') return false;
  if (type === 'order' || type === 'connect' || type === 'match') {
    return repairSequencePieces(q);
  }

  const opts = Array.isArray(q.options) ? q.options : [];
  if (!opts.length) return false;

  const cid = String(q.correctOptionId || q.correctAnswer || 'a');
  const current = (opts.find((o) => String(o.id) === cid)?.text || '').trim();
  const quote = extractQuotedAnswer(q.feedbackCorrect);
  const passage = (q.passageText || '').trim() || (q.template || '').replace(/_{3,}/g, current);
  const question = q.question || q.prompt || '';
  const full = preferredAnswer({
    option: current,
    quote,
    passage,
    question,
  });

  const needs =
    isIncompletePhrase(current) ||
    foldKey(full) !== foldKey(current) ||
    looksLikeVerseTokenList(opts, q.passageText) ||
    new Set(opts.map((o) => answerKey(o.text))).size < opts.length ||
    opts.some((o) => String(o.id) !== cid && isWeakDistractor(o.text || ''));

  if (!needs && !isIncompletePhrase(full)) return false;

  q.options = rebuildOptions({
    options: opts,
    correctId: cid,
    correctText: full || current,
    passage: q.passageText || passage,
    pool,
    question,
  });
  q.correctOptionId = cid;
  if (q.correctAnswer && !String(q.correctAnswer).includes(',')) {
    q.correctAnswer = cid;
  }

  if (type === 'complete' || type === 'fill') {
    const tpl = replaceInTemplate(q.template, q.passageText || passage, full || current);
    if (tpl) q.template = tpl;
  }

  if (type === 'tap' || type === 'find_in_text' || type === 'findintext') {
    const target = growInPassage(q.passageText || passage, full || current) || (full || current);
    const a = q.options.find((o) => String(o.id) === cid);
    if (a && target) a.text = target;
  }

  return true;
}

function repairSequencePieces(q) {
  const opts = Array.isArray(q.options) ? q.options : [];
  if (!opts.length) return false;
  let changed = false;
  for (const o of opts) {
    const t = (o.text || '').trim();
    if (!t) continue;
    if (DANGLING_END.test(t) || /[…]$/.test(t)) {
      const next = stripDanglingEnd(t.replace(/[…]+$/g, '').trim());
      if (next && next !== t) {
        o.text = next;
        changed = true;
      }
    }
  }
  return changed;
}

export function optionPoolFromQuestions(questions) {
  const map = new Map();
  for (const q of questions) {
    const key = `${q.section || ''}::${q.difficulty || ''}`;
    if (!map.has(key)) map.set(key, []);
    const list = map.get(key);
    const quote = extractQuotedAnswer(q.feedbackCorrect);
    if (quote && !isPedagogicalQuote(quote) && !isIncompletePhrase(quote)) {
      list.push(quote);
    }
    for (const o of q.options || []) {
      const t = (o.text || '').trim();
      if (!t || isIncompletePhrase(t)) continue;
      if (q.passageText && isPassagePrefix(t, q.passageText)) continue;
      if (wordsCount(t) >= 2 || looksLikeName(t)) list.push(t);
    }
  }
  return map;
}

const ASK_LEAD =
  /^(à imagem de quem|para onde|aonde|por que|porque|por quê|o que|em qual|em que|de quem|a quem|com quem|para quem|para que|de que|quem|quais|qual|que|como|onde|quando|quantos|quantas)\b/i;
const COPULA =
  /^(é|era|foi|são|eram|foram|será|seriam|está|estava|esteve)\b/i;
const COMPLEMENT_LEAD =
  /^(para|por|porque|pois|devido|pela|pelo|pelas|pelos|com|como|em|no|na|nos|nas|de|do|da|dos|das|à|ao|às|aos|sem|só|somente|apenas)\b/i;
const KEEP_CAP = new Set([
  'Deus',
  'Senhor',
  'Jeová',
  'Jesus',
  'Cristo',
  'Espírito',
  'Pai',
  'Verbo',
  'Haja',
  'Abrão',
  'Abraão',
  'Sarai',
  'Sara',
  'Ló',
  'Moisés',
  'Adão',
  'Eva',
  'Noé',
  'Paulo',
  'Pedro',
  'João',
  'Maria',
  'Israel',
  'Egito',
  'Isaque',
  'Ismael',
  'Jacó',
  'José',
  'Melquisedeque',
  'Agar',
  'Faraó',
]);
const ROLE_WORDS = [
  'rei',
  'sacerdote',
  'serva',
  'servo',
  'anjo',
  'faraó',
  'planície',
  'túnica',
  'escada',
  'nação',
  'forno',
  'tocha',
  'arca',
];
const VERB_WORDS = new Set([
  'passa',
  'passam',
  'dá',
  'dao',
  'dão',
  'vem',
  'vão',
  'sai',
  'saem',
  'faz',
  'fazem',
  'cria',
  'criou',
  'promete',
  'pede',
  'recebe',
  'mostra',
  'conta',
  'revela',
  'une',
  'marca',
  'ocorre',
  'acontece',
  'sucede',
  'viaja',
  'resgata',
  'escolhe',
  'caminham',
  'caminha',
]);
const LEAD_LOWER = new Set([
  'para',
  'por',
  'porque',
  'pois',
  'com',
  'de',
  'em',
  'a',
  'o',
  'os',
  'as',
  'um',
  'uma',
  'pela',
  'pelo',
  'pelas',
  'pelos',
  'ao',
  'à',
  'aos',
  'às',
  'no',
  'na',
  'nos',
  'nas',
  'que',
  'somente',
  'só',
  'apenas',
  'não',
  'nao',
]);

function cleanStem(raw) {
  return (raw || '')
    .replace(/\s*\([^)]*\)/g, ' ')
    .replace(/\s+/g, ' ')
    .replace(/[.!?…]+$/g, '')
    .trim();
}

export function isAsk(stem) {
  return ASK_LEAD.test(cleanStem(stem));
}

function looksLikeVerb(word) {
  const w = (word || '').toLowerCase();
  if (w.length < 3) return false;
  if (VERB_WORDS.has(w) || w === 'tem' || w === 'têm' || w === 'há') return true;
  return /(ou|eu|iu|aram|eram|iam|ava|avam)$/i.test(w);
}

function looksIndependentClaim(text) {
  const t = (text || '').trim();
  const words = t.split(/\s+/).filter(Boolean);
  if (words.length < 5) return false;
  if (isAsk(t)) return false;
  return words.some((w) => looksLikeVerb(w.replace(/[^\p{L}]+$/u, '')));
}

function looksLikeName(text) {
  const t = (text || '').trim();
  const words = t.split(/\s+/).filter(Boolean);
  if (!words.length || words.length > 3) return false;
  if (/^(não|nao|sim|sem|todos|todas|isso|nenhum|nenhuma)\b/i.test(t)) return false;
  const folded = t.toLowerCase();
  if (words.length >= 2 && ROLE_WORDS.some((r) => folded.includes(r))) return false;
  return /^[A-ZÁÉÍÓÚÂÊÔÃÕ]/.test(t);
}

function objectQuem(rest) {
  if (COPULA.test(rest)) return false;
  if (/^[A-ZÁÉÍÓÚÂÊÔÃÕ]/.test(rest)) return true;
  if (/^(o|a|os|as)\s+[A-ZÁÉÍÓÚÂÊÔÃÕ]/.test(rest)) return true;
  return false;
}

function asSubject(text) {
  const t = (text || '').trim();
  if (!t) return t;
  return t[0].toUpperCase() + t.slice(1);
}

function asComplement(text) {
  const t = (text || '').trim();
  if (!t) return t;
  const first = t.split(/\s+/)[0].replace(/[^\p{L}]+$/u, '');
  if (KEEP_CAP.has(first)) return t;
  const lower = first.toLowerCase();
  if (
    LEAD_LOWER.has(lower) ||
    ROLE_WORDS.includes(lower) ||
    first.includes('-') ||
    /(ou|eu|iu|ava|iam|am)$/i.test(first)
  ) {
    return t[0].toLowerCase() + t.slice(1);
  }
  if (/^[a-záéíóúãõâêôç]/.test(t)) return t;
  if (/^[A-ZÁÉÍÓÚÂÊÔÃÕ][a-záéíóúãõâêôç]+$/u.test(first) && first.length >= 3) {
    return t;
  }
  return t[0].toLowerCase() + t.slice(1);
}

function asSentence(raw) {
  let t = (raw || '').replace(/\s+/g, ' ').trim();
  t = t.replace(/\s+,/g, ',').replace(/\s+\./g, '.');
  if (!t) return t;
  t = t[0].toUpperCase() + t.slice(1);
  if (!/[.!?…]$/.test(t)) t += '.';
  return t.replace(/\.+$/g, '.');
}

function feminineNoun(word) {
  const w = (word || '').toLowerCase();
  return /(ção|são|gem|dade|tude|ice|a)$/.test(w) && !/(ema|ista)$/.test(w);
}

function subjectThenRest(subject, rest) {
  let r = rest;
  if (/\be\b/i.test(subject) && /^passa\b/i.test(r)) {
    r = r.replace(/^passa\b/i, 'passam');
  }
  return `${asSubject(subject)} ${r}`;
}

function joinAsk(stem, answer) {
  const t = cleanStem(stem);
  const m = t.match(ASK_LEAD);
  const rest = m ? t.slice(m[0].length).trim() : t;
  const key = (m ? m[1] : '').toLowerCase().replace(/ê/g, 'e');

  if (key === 'por que' || key === 'porque') {
    const a = asComplement(answer);
    if (/^(para|por|porque|pois|devido)\b/i.test(a)) return `${rest} ${a}`;
    return `${rest} porque ${a}`;
  }
  if (['quem', 'de quem', 'a quem', 'com quem', 'para quem'].includes(key)) {
    if (key === 'de quem') return `${rest} ${asComplement(answer)}`;
    const ser = rest.match(/^(é|era|foi|são|eram|foram|será|seriam)\s+(.+)$/i);
    if (ser) {
      const verb = ser[1];
      const topic = ser[2];
      if (looksLikeName(topic) && !looksLikeName(answer)) {
        return `${asSubject(topic)} ${verb} ${asComplement(answer)}`;
      }
      if (looksLikeName(answer) && !looksLikeName(topic)) {
        return `${asSubject(answer)} ${verb} ${asComplement(topic)}`;
      }
      return `${asSubject(topic)} ${verb} ${asComplement(answer)}`;
    }
    if (objectQuem(rest)) return `${rest} ${asComplement(answer)}`;
    return `${asSubject(answer)} ${asComplement(rest)}`;
  }
  if (key === 'à imagem de quem') {
    const a = asComplement(answer);
    const img = /^de\b/i.test(a) ? `à imagem ${a}` : `à imagem de ${a}`;
    return `${rest} ${img}`;
  }
  if (key === 'qual' || key === 'quais' || key === 'em qual') {
    if (key === 'em qual') {
      const day = rest.match(/^(\S+)\s+(.+)$/);
      if (day) return `${day[2]} ${asComplement(answer)}`;
    }
    const ser = rest.match(/^(foi|é|era|eram|são|foram|será|seriam)\s+(.+)$/i);
    if (ser) {
      if (/^(haja|faça|faze|venha|sê|seja)\b/i.test(answer)) {
        return `${ser[2]} ${ser[1]} “${answer}”`;
      }
      if (looksLikeName(answer) && !looksLikeName(ser[2])) {
        return `${asSubject(answer)} ${ser[1]} ${asComplement(ser[2])}`;
      }
      return `${ser[2]} ${ser[1]} ${asComplement(answer)}`;
    }
    const det = rest.match(/^(o|a|os|as)\s+(.+)$/i);
    if (det) return `${asSubject(det[0])} é ${asComplement(answer)}`;
    const noun = rest.match(/^(\S+)\s+(.+)$/);
    if (noun) {
      const tail = noun[2];
      if (objectQuem(tail) || /^(deus|o senhor)\b/i.test(tail)) {
        const art = feminineNoun(noun[1]) ? 'A' : 'O';
        return `${art} ${noun[1]} que ${tail} é ${asComplement(answer)}`;
      }
      return `${asSubject(answer)} ${tail}`;
    }
    return `${asSubject(answer)} ${rest}`;
  }
  if (key === 'onde' || key === 'para onde' || key === 'aonde') {
    const a = asComplement(answer);
    if (/^(em|no|na|nos|nas|para|a|ao|à|junto|perante|diante|de|do|da)\b/i.test(a)) {
      return `${rest} ${a}`;
    }
    const prep = /\b(fugiu|foi|viajou|manda|vai|partiu|desceu)\b/i.test(rest)
      ? 'para'
      : 'em';
    return `${rest} ${prep} ${a}`;
  }
  if (key === 'o que') {
    const after = rest.match(
      /^(acontece|ocorre|sucede)\s+(logo após|depois de|quando|ao)\s+(.+)$/i,
    );
    if (after) {
      return `${asSubject(`${after[2]} ${after[3]}`)}, ${asComplement(answer)}`;
    }
    const happ = rest.match(
      /^(acontece|ocorre|sucede)(?:\s+(?:a|ao|à|às|com))\s+(.+)$/i,
    );
    if (happ) return `${happ[2]} ${asComplement(answer)}`;
    const first = rest.split(/\s+/)[0];
    if (!objectQuem(rest) && looksLikeVerb(first)) {
      return subjectThenRest(answer, rest);
    }
    return `${rest} ${asComplement(answer)}`;
  }
  if (key === 'que' || key === 'em que') {
    if (key === 'em que') {
      const trans = rest.match(/^se transforma(?:\s+(.+))?$/i);
      if (trans) {
        const who = (trans[1] || '').trim();
        const a = asComplement(answer);
        const into = /^em\b/i.test(a) ? a : `em ${a}`;
        if (!who) return `Se transforma ${into}`;
        return `${who} se transforma ${into}`;
      }
    }
    const noun = rest.match(/^(\S+)\s+(.+)$/);
    if (noun) {
      const art = feminineNoun(noun[1]) ? 'A' : 'O';
      return `${art} ${noun[1]} que ${noun[2]} é ${asComplement(answer)}`;
    }
    return `${asSubject(answer)} ${rest}`;
  }
  if (key === 'como') {
    const called = rest.match(/^se chama\s+(.+)$/i);
    if (called) return `${called[1]} se chama ${asComplement(answer)}`;
    const a = asComplement(answer);
    if (
      /\b(é|foi|era|são|eram)\s+(descrit[oa]s?|chamad[oa]s?|declarad[oa]s?|apresentad[oa]s?)\b/i.test(
        rest,
      ) &&
      !COMPLEMENT_LEAD.test(a)
    ) {
      return `${rest} como ${a}`;
    }
    return `${rest} ${a}`;
  }
  if (key === 'para que') {
    const a = asComplement(answer);
    return /^(para)\b/i.test(a) ? `${rest} ${a}` : `${rest} para ${a}`;
  }
  return `${rest} ${asComplement(answer)}`;
}

export function vfClaimFromParts(question, answer) {
  const stem = cleanStem(question);
  const piece = (answer || '').replace(/\s+/g, ' ').replace(/[.!?…]+$/g, '').trim();
  if (!piece) return asSentence(stem);
  if (isAsk(stem)) {
    if (
      looksIndependentClaim(piece) &&
      !COMPLEMENT_LEAD.test(piece) &&
      piece.split(/\s+/).length >= 6
    ) {
      return asSentence(piece);
    }
    return asSentence(joinAsk(stem, piece));
  }
  if (piece.length > 28 || piece.split(/\s+/).length >= 4) return asSentence(piece);
  if (!stem) return asSentence(piece);
  return asSentence(`${stem} ${asComplement(piece)}`);
}

export function isDummyDistractor(text) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  return /outra leitura|n[aã]o aparece no texto|isso n[aã]o [eé] o que o trecho diz|n[aã]o est[aá] no trecho/i.test(
    t,
  );
}

export function styleOption(text, passage = '') {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  if (!t) return t;
  if (/^verdadeiro$/i.test(t)) return 'Verdadeiro';
  if (/^falso$/i.test(t)) return 'Falso';
  const form = passageForm(passage, t);
  if (form) {
    return form.replace(/^[\s,;:]+|[\s,;:.]+$/g, '');
  }
  const one = t.split(/\n/)[0].trim();
  if (one.length > 90) return clipPhrase(one, 72);
  return asComplement(one);
}

export function vfClaim(prompt) {
  const text = (prompt || '').replace(/\s+/g, ' ').trim();
  if (!text) return text;
  let inQuote = false;
  for (let i = 0; i < text.length - 1; i++) {
    const ch = text[i];
    if ('“”"«»'.includes(ch)) inQuote = !inQuote;
    if (inQuote || ch !== ':') continue;
    let j = i + 1;
    while (j < text.length && text[j] === ':') j += 1;
    if (j >= text.length || text[j] !== ' ') continue;
    const stem = text.slice(0, i).trim();
    const claim = text.slice(j + 1).trim();
    if (isAsk(stem) && claim) return vfClaimFromParts(stem, claim);
    return text;
  }
  return text;
}

