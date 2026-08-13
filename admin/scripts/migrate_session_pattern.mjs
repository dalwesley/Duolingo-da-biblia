/**
 * Migra banco + trilhas para o padrão de sessão única
 * ([docs/SESSAO_TREINO.md] v1.1).
 *
 * Banco: cada pergunta ganha `type` (true_false | tap | complete | choice)
 *        + campos de palco (passageText / template / prompt / correctAnswer).
 * Trilhas: cada passo ganha entrada (hook*) + centralInsight a partir do estudo.
 *          Não sobrescreve exercises autorados (ex.: gen-03-imagem).
 *
 * Usage (repo root ou admin/):
 *   node admin/scripts/migrate_session_pattern.mjs
 *   node admin/scripts/migrate_session_pattern.mjs --only ot
 *   node admin/scripts/migrate_session_pattern.mjs --repair-tap
 *   node admin/scripts/migrate_session_pattern.mjs --stamp-trails
 *   node admin/scripts/migrate_session_pattern.mjs --ensure-gestures
 */
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

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

function clip(text, max) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  if (t.length <= max) return t;
  return `${t.slice(0, max - 1).trim()}…`;
}

function clipWords(text, maxWords = 40) {
  const t = (text || '').replace(/\s+/g, ' ').trim();
  const words = t.split(' ').filter(Boolean);
  if (words.length <= maxWords) return t;
  return `${words.slice(0, maxWords).join(' ')}…`;
}

function inText(hay, needle) {
  const h = (hay || '').toLowerCase();
  const n = (needle || '').trim().toLowerCase();
  return n.length >= 3 && h.includes(n);
}

function foldKey(s) {
  return (s || '')
    .normalize('NFD')
    .replace(/\p{M}/gu, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}

function inTextWord(hay, needle) {
  const n = foldKey(needle);
  if (n.length < 3) return false;
  const h = foldKey(hay);
  const escaped = n.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').replace(/\s+/g, '\\s+');
  return new RegExp(`(?:^|[^a-z0-9])${escaped}(?:$|[^a-z0-9])`).test(h);
}

/** Grafia do trecho como está no palco (para o toque achar o alvo). */
function passageForm(passage, needle) {
  if (!passage || !needle) return '';
  const parts = foldKey(needle).split(' ').filter(Boolean);
  if (!parts.length) return '';
  const accent = (ch) => {
    const map = {
      a: '[aáàâãä]',
      e: '[eéêèë]',
      i: '[iíìîï]',
      o: '[oóôõòö]',
      u: '[uúùûü]',
      c: '[cç]',
    };
    if (map[ch]) return map[ch];
    return /[.*+?^${}()|[\]\\]/.test(ch) ? `\\${ch}` : ch;
  };
  const body = parts.map((w) => [...w].map(accent).join('')).join('\\s+');
  const m = passage.match(new RegExp(body, 'i'));
  return m ? m[0] : '';
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
    'cantico dos canticos': 'cânticos',
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
  let book = byName.get(key);
  if (book) return book;
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
    const ch = Number(m[2]);
    const v1 = Number(m[3]);
    const v2 = m[4] ? Number(m[4]) : v1;
    return take(book.chapters[ch - 1], v1, v2);
  }

  m = raw.match(/^(.+?)\s+(\d+)\s*[–\-−]\s*(\d+)\s*$/);
  if (m) {
    const book = findBook(byName, m[1]);
    if (!book) return null;
    const chapter = book.chapters[Number(m[2]) - 1];
    if (!chapter?.length) return null;
    return chapter.slice(0, Math.min(3, chapter.length)).join(' ');
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

const TAP_STOP = new Set([
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

/** Trecho da resposta que realmente aparece no palco — senão o tap vira chute. */
function findTapTarget(correctText, passage) {
  const c = (correctText || '').trim();
  if (!passage || !c) return '';
  const hit = (raw) => passageForm(passage, raw);

  if (c.length >= 3 && c.length <= 40 && inTextWord(passage, c)) {
    const s = hit(c);
    if (s) return s;
  }

  const parts = c
    .split(/[/—–()]/)
    .map((s) => s.trim())
    .filter(Boolean);
  for (const part of parts) {
    if (
      part.length >= 8 &&
      part.length <= 40 &&
      part.includes(' ') &&
      inTextWord(passage, part)
    ) {
      const s = hit(part);
      if (s) return s;
    }
  }

  const words = c.split(/\s+/).filter(Boolean);
  for (let n = Math.min(5, words.length); n >= 2; n--) {
    for (let i = 0; i <= words.length - n; i++) {
      const phrase = words.slice(i, i + n).join(' ');
      const clean = phrase.replace(/^[^\p{L}]+|[^\p{L}]+$/gu, '');
      if (
        clean.length >= 8 &&
        clean.length <= 40 &&
        inTextWord(passage, clean)
      ) {
        const s = hit(clean);
        if (s) return s;
      }
    }
  }

  const candidates = (c.match(/\p{L}{6,}/gu) || []).sort(
    (a, b) => b.length - a.length,
  );
  for (const w of candidates) {
    if (TAP_STOP.has(foldKey(w))) continue;
    if (inTextWord(passage, w)) {
      const s = hit(w);
      if (s) return s;
    }
  }
  return '';
}

function resolvePassage(q, study, bibleByName) {
  const fromBible = lookupPassage(bibleByName, q.verseRef);
  if (fromBible) return clipWords(fromBible, 40);
  const studyText = clipWords(study?.passageText || '', 40);
  const ref = study?.passageRef || '';
  if (
    studyText.length >= 40 &&
    !/^referência:/i.test(ref) &&
    !/^por que /i.test(studyText)
  ) {
    return studyText;
  }
  return '';
}

function optionById(q, id) {
  return (q.options || []).find((o) => o.id === id) || null;
}

function distractors(q) {
  return (q.options || []).filter((o) => o.id !== q.correctOptionId);
}

function passagePhrases(passage, exclude) {
  const ex = (exclude || '').toLowerCase();
  const words = (passage || '')
    .replace(/[“”"']/g, '')
    .split(/[\s,;:!?—–]+/)
    .map((w) => w.replace(/^[^\p{L}]+|[^\p{L}]+$/gu, ''))
    .filter(
      (w) =>
        w.length >= 5 &&
        w.toLowerCase() !== ex &&
        !TAP_STOP.has(foldKey(w)),
    );
  const uniq = [];
  for (const w of words) {
    if (uniq.some((u) => u.toLowerCase() === w.toLowerCase())) continue;
    uniq.push(w);
    if (uniq.length >= 3) break;
  }
  return uniq;
}

function vfPrompt(q, asTrue) {
  const correct = optionById(q, q.correctOptionId);
  const wrong = distractors(q)[0];
  const piece = asTrue ? correct?.text : wrong?.text;
  const text = (piece || '').trim();
  if (!text) return q.question;
  if (/[.!?]$/.test(text) || text.length > 28) return text;
  const stem = (q.question || '').replace(/\?\s*$/, '').trim();
  if (stem.length > 12 && stem.length < 90) return `${stem}: ${text}.`;
  return `${text}.`;
}

function capabilities(q, study, bibleByName) {
  const passage = resolvePassage(q, study, bibleByName);
  const keyword = (study?.keyword || '').trim();
  const correct = optionById(q, q.correctOptionId);
  const correctText = (correct?.text || '').trim();
  const tapTarget = findTapTarget(correctText, passage);
  const canTap = Boolean(
    passage &&
      tapTarget &&
      tapTarget.length >= 3 &&
      tapTarget.length <= 40,
  );
  const canComplete = Boolean(
    canTap && tapTarget.length <= 32 && !tapTarget.includes('…'),
  );
  return { passage, keyword, correctText, tapTarget, canTap, canComplete };
}

function applyVf(q, asTrue) {
  q.type = 'true_false';
  q.prompt = vfPrompt(q, asTrue);
  q.correctAnswer = asTrue ? 'true' : 'false';
  q.options = [
    { id: 'true', text: 'Verdadeiro' },
    { id: 'false', text: 'Falso' },
  ];
  q.correctOptionId = q.correctAnswer;
}

function hasMcqOptions(q) {
  return (q.options || []).some((o) => ['a', 'b', 'c', 'd'].includes(o.id));
}

function extractQuotedAnswer(feedback) {
  const m = (feedback || '').match(/[“"]([^”"]+)[”"]/);
  return m ? m[1].trim() : '';
}

/** Afirmação verdadeira a partir do feedback / pergunta (quando options já são V/F). */
function trueClaimFromVf(q) {
  const quoted = extractQuotedAnswer(q.feedbackCorrect);
  if (quoted) {
    const stem = (q.question || '').replace(/\?\s*$/, '').trim();
    if (stem.length > 12 && stem.length < 90 && quoted.length <= 28 && !/[.!?]$/.test(quoted)) {
      return `${stem}: ${quoted}.`;
    }
    return /[.!?]$/.test(quoted) || quoted.length > 28 ? quoted : `${quoted}.`;
  }
  const ask = (q.question || '').trim();
  if (ask) return ask.replace(/\?\s*$/, '.');
  return (q.prompt || '').trim();
}

function setVfAnswer(q, asTrue, distractorText) {
  if (hasMcqOptions(q)) {
    applyVf(q, asTrue);
    return;
  }
  if (asTrue) {
    q.prompt = trueClaimFromVf(q);
    q.correctAnswer = 'true';
  } else {
    const wrong = (distractorText || '').trim();
    if (wrong) {
      const stem = (q.question || '').replace(/\?\s*$/, '').trim();
      if (stem.length > 12 && stem.length < 90 && wrong.length <= 40 && !/[.!?]$/.test(wrong)) {
        q.prompt = `${stem}: ${wrong}.`;
      } else {
        q.prompt = /[.!?]$/.test(wrong) || wrong.length > 28 ? wrong : `${wrong}.`;
      }
    }
    // Se não há distrator, mantém o prompt atual (assume já ser afirmação falsa)
    // ou marca falso mesmo — caller deve preferir trocar pares.
    q.correctAnswer = 'false';
  }
  q.options = [
    { id: 'true', text: 'Verdadeiro' },
    { id: 'false', text: 'Falso' },
  ];
  q.correctOptionId = q.correctAnswer;
  q.type = 'true_false';
}

function distractorsBySection(questions) {
  const map = new Map();
  for (const q of questions) {
    if (q.type !== 'choice' && q.type !== 'complete') continue;
    const key = `${q.section || ''}::${q.difficulty || 'semente'}`;
    const correct = q.correctOptionId || q.correctAnswer;
    for (const o of q.options || []) {
      if (!o?.text || o.id === correct) continue;
      const t = o.text.trim();
      if (t.length < 3 || t.length > 48) continue;
      if (!map.has(key)) map.set(key, []);
      map.get(key).push(t);
    }
  }
  return map;
}

/**
 * Alterna V/F por seção×dificuldade (ids estáveis).
 * Com options MCQ: regenera prompt via applyVf.
 * Sem MCQ: troca pares true↔false; sobras usam feedback / distrator da seção.
 */
function stableStartTrue(key) {
  let h = 0;
  for (let i = 0; i < key.length; i++) h = (h * 31 + key.charCodeAt(i)) | 0;
  return (h & 1) === 0;
}

function rebalanceVf(questions) {
  const groups = new Map();
  for (const q of questions) {
    if (q.type !== 'true_false') continue;
    const key = `${q.trail || q.trailSlug || ''}::${q.section || ''}::${q.difficulty || 'semente'}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(q);
  }
  const distractors = distractorsBySection(questions);

  let changed = 0;
  for (const [key, list] of groups) {
    list.sort((a, b) => String(a.id).localeCompare(String(b.id)));
    const startTrue = stableStartTrue(key);
    const wantTrue = list.map((_, i) => (i % 2 === 0) === startTrue);
    const sectionKey = `${list[0].section || ''}::${list[0].difficulty || 'semente'}`;
    const pool = distractors.get(sectionKey) || [];
    let poolIdx = 0;
    const nextDistractor = () => {
      if (pool.length === 0) return '';
      const t = pool[poolIdx % pool.length];
      poolIdx += 1;
      return t;
    };

    // 1) MCQ intacto → aplica applyVf direto
    for (let i = 0; i < list.length; i++) {
      const q = list[i];
      if (!hasMcqOptions(q)) continue;
      const before = String(q.correctAnswer);
      const beforePrompt = q.prompt;
      applyVf(q, wantTrue[i]);
      if (String(q.correctAnswer) !== before || q.prompt !== beforePrompt) changed += 1;
    }

    // 2) Só options V/F: emparelha trocas; sobras regeneram claim
    const soft = list
      .map((q, i) => ({ q, i, want: wantTrue[i] }))
      .filter(({ q }) => !hasMcqOptions(q));

    const needTrue = soft.filter(
      ({ q, want }) => want && String(q.correctAnswer).toLowerCase() !== 'true',
    );
    const needFalse = soft.filter(
      ({ q, want }) => !want && String(q.correctAnswer).toLowerCase() === 'true',
    );

    const pairs = Math.min(needTrue.length, needFalse.length);
    for (let p = 0; p < pairs; p++) {
      const a = needTrue[p].q;
      const b = needFalse[p].q;
      const promptA = a.prompt;
      const promptB = b.prompt;
      a.prompt = promptB;
      a.correctAnswer = 'true';
      a.correctOptionId = 'true';
      a.options = [
        { id: 'true', text: 'Verdadeiro' },
        { id: 'false', text: 'Falso' },
      ];
      b.prompt = promptA;
      b.correctAnswer = 'false';
      b.correctOptionId = 'false';
      b.options = [
        { id: 'true', text: 'Verdadeiro' },
        { id: 'false', text: 'Falso' },
      ];
      changed += 2;
    }

    for (let p = pairs; p < needTrue.length; p++) {
      const q = needTrue[p].q;
      const before = q.prompt;
      setVfAnswer(q, true);
      if (q.prompt !== before || q.correctAnswer === 'true') changed += 1;
    }
    for (let p = pairs; p < needFalse.length; p++) {
      const q = needFalse[p].q;
      const before = q.prompt;
      setVfAnswer(q, false, nextDistractor());
      if (q.prompt !== before || q.correctAnswer === 'false') changed += 1;
    }
  }
  return changed;
}

function tapAsk(q) {
  const ask = (q.question || '').trim();
  // Cue = pergunta (não o trecho-alvo — evita spoiler). Verbo OBSERVE fica na UI.
  if (ask) return ask.length > 80 ? `${ask.slice(0, 79).trim()}…` : ask;
  return 'Toque o trecho que responde.';
}

function applyTap(q, caps) {
  const { passage, tapTarget } = caps;
  q.type = 'tap';
  q.passageText = passage;
  q.prompt = tapAsk(q);
  q.cue = q.prompt;
  const others = passagePhrases(passage, tapTarget);
  q.options = [
    { id: 'a', text: tapTarget },
    ...others.slice(0, 3).map((t, idx) => ({
      id: String.fromCharCode(98 + idx),
      text: t,
    })),
  ];
  q.correctAnswer = 'a';
  q.correctOptionId = 'a';
}

/** Corrige atos tap cujo enunciado já entrega o trecho-alvo. */
function repairTapSpoilers(questions) {
  let fixed = 0;
  for (const q of questions) {
    if (q.type !== 'tap' && q.type !== 'find_in_text') continue;
    const prompt = (q.prompt || q.cue || '').trim();
    const m = prompt.match(/^Toque no texto:\s*(.+)$/i);
    if (!m) continue;
    const target = m[1].trim().toLowerCase();
    const opts = (q.options || []).map((o) => (o.text || '').trim().toLowerCase());
    if (!opts.includes(target)) continue;
    const ask = tapAsk(q);
    if (!ask || ask.toLowerCase() === prompt.toLowerCase()) continue;
    q.prompt = ask;
    q.cue = ask;
    fixed += 1;
  }
  return fixed;
}

function applyComplete(q, caps) {
  const { passage, tapTarget } = caps;
  q.type = 'complete';
  const re = new RegExp(tapTarget.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
  q.template = passage.replace(re, '___');
  q.prompt = 'Complete a lacuna.';
  q.correctAnswer = 'a';
  q.correctOptionId = 'a';
  const wrongs = distractors(q)
    .map((o) => o.text)
    .filter((t) => t && t !== tapTarget);
  q.options = [
    { id: 'a', text: tapTarget },
    { id: 'b', text: wrongs[0] || passagePhrases(passage, tapTarget)[0] || 'povo' },
    { id: 'c', text: wrongs[1] || passagePhrases(passage, tapTarget)[1] || 'terra' },
  ];
}

function applyChoice(q, study, passage) {
  q.type = 'choice';
  if (!(q.prompt || '').trim()) q.prompt = q.question;
  if (!(q.correctAnswer || '').trim()) q.correctAnswer = q.correctOptionId;
  if (study?.passageRef && !q.verseRef) q.verseRef = study.passageRef;
  const palco = (passage || '').trim();
  if (palco && !(q.passageText || '').trim()) q.passageText = palco;
}

/**
 * Mix por seção×dificuldade (contrato sessão ≤~40% choice):
 * 1 VF · 1 tap (se der) · 1 complete (se der) · resto choice com VF extras.
 * Preserva atos autorados (type ≠ choice com prompt+answer).
 */
function assignTypes(questions, studyBySection, bibleByName) {
  const groups = new Map();
  for (const q of questions) {
    const key = `${q.trail || q.trailSlug || ''}::${q.section || ''}::${q.difficulty || 'semente'}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(q);
  }

  const counts = { true_false: 0, tap: 0, complete: 0, choice: 0 };

  for (const [key, list] of groups) {
    list.sort((a, b) => String(a.id).localeCompare(String(b.id)));

    const authored = [];
    const free = [];
    for (const q of list) {
      if (q.type && q.type !== 'choice' && q.prompt && q.correctAnswer) {
        authored.push(q);
        counts[q.type] = (counts[q.type] || 0) + 1;
      } else {
        free.push(q);
      }
    }
    if (free.length === 0) continue;

    const meta = free.map((q) => {
      const study = studyBySection.get(q.section) || null;
      return { q, study, caps: capabilities(q, study, bibleByName) };
    });

    const used = new Set();
    const take = (pred) => {
      const i = meta.findIndex((m, idx) => !used.has(idx) && pred(m));
      if (i < 0) return null;
      used.add(i);
      return meta[i];
    };

    // Alterna V/F dentro do grupo (antes o 1º era sempre false → ~75% falso).
    let vfNext = stableStartTrue(key);

    // Palco primeiro: tap/complete precisam da opção original ainda intacta.
    const tap = take((m) => m.caps.canTap);
    if (tap) {
      applyTap(tap.q, tap.caps);
      if (tap.study?.passageRef && !tap.q.verseRef) tap.q.verseRef = tap.study.passageRef;
      counts.tap += 1;
    }

    const complete = take((m) => m.caps.canComplete);
    if (complete) {
      applyComplete(complete.q, complete.caps);
      if (complete.study?.passageRef && !complete.q.verseRef) {
        complete.q.verseRef = complete.study.passageRef;
      }
      counts.complete += 1;
    }

    const vf = take(() => true);
    if (vf) {
      applyVf(vf.q, vfNext);
      vfNext = !vfNext;
      if (vf.study?.passageRef && !vf.q.verseRef) vf.q.verseRef = vf.study.passageRef;
      counts.true_false += 1;
    }

    // 4) Restante: no máx ~40% choice; extras viram V/F
    const restIdx = meta.map((_, i) => i).filter((i) => !used.has(i));
    const maxChoice = Math.max(1, Math.ceil(free.length * 0.4));
    let choiceLeft = maxChoice;
    for (const i of restIdx) {
      const { q, study } = meta[i];
      used.add(i);
      if (choiceLeft > 0) {
        applyChoice(q, study, meta[i].caps.passage);
        counts.choice += 1;
        choiceLeft -= 1;
      } else {
        applyVf(q, vfNext);
        vfNext = !vfNext;
        if (study?.passageRef && !q.verseRef) q.verseRef = study.passageRef;
        counts.true_false += 1;
      }
    }
  }

  return counts;
}

function applyOrder(q, pieces) {
  const opts = pieces.slice(0, 4).map((t, i) => ({
    id: String.fromCharCode(97 + i),
    text: clip(t, 48),
  }));
  q.type = 'order';
  q.prompt = 'Monte a sequência do trecho.';
  q.cue = q.prompt;
  q.options = opts;
  q.correctOrder = opts.map((o) => o.id);
  q.correctAnswer = q.correctOrder.join(',');
  q.correctOptionId = opts[0]?.id || 'a';
  delete q.passageText;
  delete q.template;
  delete q.passageA;
  delete q.passageB;
}

function applyConnect(q, study, passage) {
  const parts = (passage || '')
    .split(/[;.…]+/)
    .map((s) => s.trim())
    .filter((s) => s.length >= 12);
  const related = Array.isArray(study?.relatedVerses) ? study.relatedVerses[0] : null;
  const textA = clip(parts[0] || '', 110);
  const textB = related?.reason
    ? clip(related.reason, 110)
    : clip(parts[1] || '', 110);
  if (!textA || !textB || foldKey(textA) === foldKey(textB)) return false;

  const kw = ((study?.keyword || '').split(/[/(]/)[0] || '').trim();
  const candidates = [
    kw,
    ...passagePhrases(textA, ''),
    ...passagePhrases(textB, ''),
  ].filter(
    (w) => w && w.length >= 4 && w.length <= 28 && !TAP_STOP.has(foldKey(w)),
  );
  const target = candidates.find(
    (w) => inTextWord(textA, w) && inTextWord(textB, w),
  );
  if (!target) return false;

  const distractors = passagePhrases(`${textA} ${textB}`, target).filter(
    (w) => w.toLowerCase() !== target.toLowerCase(),
  );
  if (distractors.length < 1) return false;

  const refA = q.verseRef || study?.passageRef || '';
  const refB = related?.reference || (refA ? `${refA} · segue` : '');
  q.type = 'connect';
  q.prompt = 'Qual palavra une os textos?';
  q.cue = q.prompt;
  q.passageA = { ref: refA, text: textA };
  q.passageB = { ref: refB, text: textB };
  q.options = [
    { id: 'a', text: target },
    ...distractors.slice(0, 3).map((t, i) => ({
      id: String.fromCharCode(98 + i),
      text: t,
    })),
  ];
  q.correctAnswer = 'a';
  q.correctOptionId = 'a';
  delete q.passageText;
  delete q.template;
  delete q.correctOrder;
  return true;
}

function orderPiecesFromPassage(passage) {
  const text = clipWords(passage || '', 55);
  if (!text) return null;
  const clauses = text
    .split(/[;.…]+/)
    .map((s) => s.trim())
    .filter((s) => s.length >= 10)
    .map((s) => clip(s, 42));
  if (clauses.length >= 3) return clauses.slice(0, 3);

  const commas = text
    .split(/,/)
    .map((s) => s.trim())
    .filter((s) => s.length >= 8)
    .map((s) => clip(s, 42));
  if (commas.length >= 3) return commas.slice(0, 3);

  const words = text.split(/\s+/).filter(Boolean);
  if (words.length >= 12) {
    const third = Math.max(4, Math.floor(words.length / 3));
    const pieces = [
      clip(words.slice(0, third).join(' '), 42),
      clip(words.slice(third, third * 2).join(' '), 42),
      clip(words.slice(third * 2).join(' '), 42),
    ].filter((s) => s.length >= 8);
    if (pieces.length >= 3) return pieces.slice(0, 3);
  }
  return null;
}

function isAuthoredGesture(q) {
  if (q.type === 'order' && Array.isArray(q.correctOrder) && q.correctOrder.length >= 3) {
    return true;
  }
  if (q.type === 'connect' && q.passageA && q.passageB) return true;
  const id = String(q.id || '');
  return /-(e0[0-9]|e[0-9]{2})$/i.test(id);
}

function cloneQuestion(q, suffix) {
  const copy = JSON.parse(JSON.stringify(q));
  copy.id = `${q.id}-${suffix}`;
  return copy;
}

/**
 * Completa gestos que dá para autorar com palco real.
 * Não fabrica tap/complete (alvo fora do versículo) nem order/connect genéricos.
 */
function ensureGestures(questions, studyBySection, bibleByName) {
  const REQUIRED = ['true_false', 'tap', 'choice', 'order', 'complete', 'connect'];
  const groups = new Map();
  for (const q of questions) {
    const key = `${q.trail || q.trailSlug || ''}::${q.section || ''}::${q.difficulty || 'semente'}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(q);
  }

  let converted = 0;
  let cloned = 0;

  for (const [, list] of groups) {
    list.sort((a, b) => String(a.id).localeCompare(String(b.id)));
    const study = studyBySection.get(list[0]?.section) || null;
    const capsFor = (q) => capabilities(q, study, bibleByName);
    const passageFor = (q) =>
      resolvePassage(q, study, bibleByName) ||
      clipWords(study?.passageText || '', 40);

    const hasType = (t) => list.some((q) => q.type === t);
    const protectedIds = new Set(list.filter(isAuthoredGesture).map((q) => q.id));

    const convertible = () =>
      list.filter((q) => {
        if (protectedIds.has(q.id)) return false;
        const t = q.type || 'choice';
        const count = list.filter((x) => x.type === t).length;
        if (REQUIRED.includes(t)) return count > 1;
        return true;
      });

    const cloneDonor = (need) => {
      const base =
        list.find((q) => q.type === 'choice') ||
        list.find((q) => q.type === 'true_false') ||
        list[list.length - 1];
      if (!base) return null;
      const donor = cloneQuestion(base, need.slice(0, 3));
      let n = 2;
      while (list.some((q) => q.id === donor.id) || questions.some((q) => q.id === donor.id)) {
        donor.id = `${base.id}-${need.slice(0, 3)}${n}`;
        n += 1;
      }
      list.push(donor);
      questions.push(donor);
      cloned += 1;
      return donor;
    };

    for (const need of REQUIRED) {
      if (hasType(need)) continue;
      const pool = convertible();

      if (need === 'tap' || need === 'complete') {
        const donor = pool.find((q) => {
          const c = capsFor(q);
          return need === 'complete' ? c.canComplete : c.canTap;
        });
        if (!donor) continue;
        if (need === 'tap') applyTap(donor, capsFor(donor));
        else applyComplete(donor, capsFor(donor));
        converted += 1;
        continue;
      }

      if (need === 'order') {
        const passage =
          passageFor(list[0]) ||
          list.map((q) => passageFor(q)).find(Boolean) ||
          '';
        const pieces = orderPiecesFromPassage(passage);
        if (!pieces || pieces.length < 3) continue;
        const donor = pool[0] || cloneDonor(need);
        if (!donor) continue;
        applyOrder(donor, pieces);
        converted += 1;
        continue;
      }

      if (need === 'connect') {
        const passage =
          passageFor(list[0]) ||
          list.map((q) => passageFor(q)).find(Boolean) ||
          '';
        const donor = pool[0] || cloneDonor(need);
        if (!donor) continue;
        if (!applyConnect(donor, study, passage)) {
          if (cloned && donor.id.endsWith(`-${need.slice(0, 3)}`)) {
            const idx = questions.findIndex((q) => q.id === donor.id);
            if (idx >= 0) questions.splice(idx, 1);
            const li = list.findIndex((q) => q.id === donor.id);
            if (li >= 0) list.splice(li, 1);
            cloned -= 1;
          }
          continue;
        }
        converted += 1;
        continue;
      }

      if (need === 'true_false') {
        const donor = pool[0] || cloneDonor(need);
        if (!donor) continue;
        applyVf(donor, stableStartTrue(donor.id));
        converted += 1;
        continue;
      }

      if (need === 'choice') {
        const donor = pool[0];
        if (!donor) continue;
        applyChoice(donor, study, passageFor(donor));
        const ask = (donor.question || '').trim();
        if (ask) {
          donor.prompt = ask;
          donor.cue = ask;
        }
        const opts = donor.options || [];
        const onlyVf =
          opts.length === 2 &&
          opts.every((o) =>
            ['true', 'false', 'verdadeiro', 'falso'].includes(
              String(o.id || o.text).toLowerCase(),
            ),
          );
        if (onlyVf || !opts.some((o) => o.id === 'a')) {
          const correct =
            extractQuotedAnswer(donor.feedbackCorrect) ||
            ((study?.keyword || '').split(/[/(]/)[0] || '').trim();
          if (!correct || correct.length > 48) continue;
          donor.options = [
            { id: 'a', text: correct },
            { id: 'b', text: 'Outra leitura do trecho' },
            { id: 'c', text: 'Não aparece no texto' },
          ];
          donor.correctOptionId = 'a';
          donor.correctAnswer = 'a';
        }
        converted += 1;
      }
    }
  }

  return { converted, cloned };
}

function stampMissions(trails, studies) {
  let stamped = 0;
  let skippedAuthored = 0;
  for (const trail of trails) {
    for (const mod of trail.modules || []) {
      for (const mission of mod.missions || []) {
        const authored = (mission.exercises || []).some(
          (e) => e && e.type && e.type !== 'choice' && e.type !== 'insight',
        );
        if (authored) {
          skippedAuthored += 1;
          continue;
        }
        const study = studies[mission.slug];
        if (!study) continue;
        const verse = clipWords(study.passageText || '', 28);
        const note = clip(study.context || '', 140);
        // Insight ≠ contexto: preferir 1ª reflexão / related reason.
        const fromPrompt = Array.isArray(study.reflectionPrompts)
          ? study.reflectionPrompts.find((p) => (p || '').trim().length >= 8)
          : null;
        const fromRelated = Array.isArray(study.relatedVerses)
          ? study.relatedVerses.find((r) => (r?.reason || '').trim().length >= 12)
          : null;
        const insight = clip(
          fromPrompt ||
            fromRelated?.reason ||
            study.centralInsight ||
            study.context ||
            '',
          140,
        );
        if (study.passageRef) mission.hookRef = study.passageRef;
        if (verse) mission.hookVerse = verse;
        if (note) mission.hookNote = note;
        // Fio de conexão (entrada): 1 related, sem spoiler do insight.
        if (!mission.hookThread && fromRelated?.reference) {
          mission.hookThread = clip(
            `${fromRelated.reference}: ${fromRelated.reason || ''}`.trim(),
            120,
          );
        }
        const contextClip = clip(study.context || '', 140);
        const shouldRefreshInsight =
          !mission.centralInsight ||
          mission.centralInsight === contextClip ||
          (mission.centralInsight || '').length < 12;
        if (shouldRefreshInsight && insight.length >= 8) {
          mission.centralInsight = insight;
        }
        if (!(mission.objective || '').trim() && (study.focusQuestion || '').trim().length >= 8) {
          mission.objective = clip(study.focusQuestion, 140);
        }
        stamped += 1;
      }
    }
  }
  return { stamped, skippedAuthored };
}

function parseOnlyFiles() {
  const idx = process.argv.findIndex((a) => a === '--only' || a.startsWith('--only='));
  if (idx < 0) return BANK_FILES;
  const raw = process.argv[idx].startsWith('--only=')
    ? process.argv[idx].slice('--only='.length)
    : process.argv[idx + 1] || '';
  const keys = raw
    .split(',')
    .map((s) => s.trim().toLowerCase())
    .filter(Boolean);
  if (!keys.length) return BANK_FILES;
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

function main() {
  const stampOnly = process.argv.includes('--stamp-trails');
  const onlyRepair = process.argv.includes('--repair-tap');
  const onlyRebalanceVf = process.argv.includes('--rebalance-vf');
  const onlyEnsure = process.argv.includes('--ensure-gestures');
  const studiesRaw = readJson('mission_studies.json');
  const studies = studiesRaw.studies || {};

  if (stampOnly) {
    const trails = readJson('trails.json');
    const { stamped, skippedAuthored } = stampMissions(trails, studies);
    writeJson('trails.json', trails);
    console.log(
      `✓ trails.json: ${stamped} passos com entrada/insight · ${skippedAuthored} autorados preservados`,
    );
    return;
  }

  const onlyFiles = parseOnlyFiles();
  const scoped = onlyFiles.length !== BANK_FILES.length;
  const studyBySection = new Map();
  for (const [slug, s] of Object.entries(studies)) {
    studyBySection.set(slug, s);
  }
  const bibleByName = buildBibleIndex();

  const totals = {
    true_false: 0,
    tap: 0,
    complete: 0,
    choice: 0,
    questions: 0,
    tapRepaired: 0,
    vfRebalanced: 0,
    gesturesConverted: 0,
    gesturesCloned: 0,
  };
  for (const file of onlyFiles) {
    const path = join(dataRoot, file);
    if (!existsSync(path)) {
      console.log(`skip ${file}`);
      continue;
    }
    const raw = readJson(file);
    const wrapped = Array.isArray(raw);
    const questions = wrapped ? raw : raw.questions || [];
    let counts = { true_false: 0, tap: 0, complete: 0, choice: 0 };
    let repaired = 0;
    let vfChanged = 0;
    let ensured = { converted: 0, cloned: 0 };

    if (onlyEnsure) {
      ensured = ensureGestures(questions, studyBySection, bibleByName);
      repaired = repairTapSpoilers(questions);
    } else if (onlyRebalanceVf) {
      vfChanged = rebalanceVf(questions);
    } else if (onlyRepair) {
      repaired = repairTapSpoilers(questions);
    } else {
      counts = assignTypes(questions, studyBySection, bibleByName);
      repaired = repairTapSpoilers(questions);
      vfChanged = rebalanceVf(questions);
      ensured = ensureGestures(questions, studyBySection, bibleByName);
    }

    if (wrapped) writeJson(file, questions);
    else writeJson(file, { ...raw, questions });
    totals.questions += questions.length;
    totals.tapRepaired += repaired;
    totals.vfRebalanced += vfChanged;
    totals.gesturesConverted += ensured.converted;
    totals.gesturesCloned += ensured.cloned;
    for (const k of ['true_false', 'tap', 'complete', 'choice']) {
      totals[k] += counts[k] || 0;
    }
    if (onlyEnsure) {
      console.log(
        `✓ ${file}: ${questions.length} · gestos +${ensured.converted} (clones ${ensured.cloned}) · tapFix ${repaired}`,
      );
    } else if (onlyRebalanceVf) {
      console.log(`✓ ${file}: ${questions.length} · V/F rebalanceados: ${vfChanged}`);
    } else if (onlyRepair) {
      console.log(`✓ ${file}: ${questions.length} · tap spoiler → pergunta: ${repaired}`);
    } else {
      console.log(
        `✓ ${file}: ${questions.length} · vf ${counts.true_false} · tap ${counts.tap} · complete ${counts.complete} · choice ${counts.choice} · repair ${repaired} · vfFix ${vfChanged} · gestos +${ensured.converted}`,
      );
    }
  }

  if (!onlyRepair && !onlyRebalanceVf && !onlyEnsure && !scoped) {
    const trails = readJson('trails.json');
    const { stamped, skippedAuthored } = stampMissions(trails, studies);
    writeJson('trails.json', trails);
    console.log(
      `✓ trails.json: ${stamped} passos com entrada/insight · ${skippedAuthored} autorados preservados`,
    );
  }
  if (onlyEnsure) {
    console.log(
      `gestos: convertidos ${totals.gesturesConverted} · clones ${totals.gesturesCloned} · tapFix ${totals.tapRepaired}`,
    );
  } else if (onlyRebalanceVf) {
    console.log(`V/F rebalanceados: ${totals.vfRebalanced}`);
  } else if (onlyRepair) {
    console.log(`tap spoiler reparados: ${totals.tapRepaired}`);
  } else {
    console.log(
      `total banco: ${totals.questions} · vf ${totals.true_false} · tap ${totals.tap} · complete ${totals.complete} · choice ${totals.choice} · gestos +${totals.gesturesConverted}`,
    );
  }
}

main();
