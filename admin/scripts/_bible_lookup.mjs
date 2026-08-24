/**
 * Resolve referências bíblicas → texto completo (Tradução Brasileira).
 * Usado pelo gerador V2 para não fatiar trechos com reticências do estudo.
 */
import { readFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const BIBLE_PATH = join(
  __dirname,
  '..',
  '..',
  'trilha_app',
  'assets',
  'data',
  'bible_tb.json',
);

let _books = null;
let _byName = null;
let _byAbbrev = null;

function fold(s) {
  return String(s || '')
    .normalize('NFD')
    .replace(/\p{M}/gu, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '');
}

function loadBooks() {
  if (_books) return _books;
  if (!existsSync(BIBLE_PATH)) {
    _books = [];
    return _books;
  }
  _books = JSON.parse(readFileSync(BIBLE_PATH, 'utf8'));
  _byName = new Map();
  _byAbbrev = new Map();
  for (const b of _books) {
    _byName.set(fold(b.name), b);
    _byAbbrev.set(fold(b.abbrev), b);
  }
  // Aliases comuns
  const aliases = {
    genesis: 'gênesis',
    exodo: 'êxodo',
    levitico: 'levítico',
    numeros: 'números',
    deuteronomio: 'deuteronômio',
    samuel: '1 samuel',
    reis: '1 reis',
    cronicas: '1 crônicas',
    salmos: 'salmos',
    salmo: 'salmos',
    proverbios: 'provérbios',
    ecclesiastes: 'eclesiastes',
    isaias: 'isaías',
    jeremias: 'jeremias',
    ezequiel: 'ezequiel',
    mateus: 'mateus',
    marcos: 'marcos',
    lucas: 'lucas',
    joao: 'joão',
    atos: 'atos',
    romanos: 'romanos',
    corintios: '1 coríntios',
    galatas: 'gálatas',
    efesios: 'efésios',
    filipenses: 'filipenses',
    colossenses: 'colossenses',
    tessalonicenses: '1 tessalonicenses',
    timoteo: '1 timóteo',
    tito: 'tito',
    hebreus: 'hebreus',
    tiago: 'tiago',
    pedro: '1 pedro',
    judas: 'judas',
    apocalipse: 'apocalipse',
  };
  for (const [alias, name] of Object.entries(aliases)) {
    const book = _byName.get(fold(name));
    if (book) _byName.set(fold(alias), book);
  }
  return _books;
}

/**
 * Parse "Êxodo 1:8–14", "Mateus 5:3", "Gn 12:1-3", "Êxodo 7–12",
 * "Gênesis 1:1–2:3". Refs compostas ("A; B") → só o 1º segmento.
 * @returns {{ bookName, chapter, vStart, vEnd, chapterEnd? } | null}
 */
export function parseRef(raw) {
  const t = String(raw || '')
    .replace(/\s+/g, ' ')
    .trim();
  if (!t) return null;
  // Drop leading "Referência:" etc. e pegar o primeiro bloco útil.
  let cleaned = t.replace(/^(refer[eê]ncia:\s*)/i, '').trim();
  cleaned = cleaned.split(/\s*;\s*/)[0].trim();
  // "2Timóteo 3" → "2 Timóteo 3"
  cleaned = cleaned.replace(/^(\d+)([A-Za-zÀ-ú])/u, '$1 $2');

  // Cap:verso–Cap:verso (Gn 1:1–2:3)
  const cross = cleaned.match(
    /^(.+?)\s+(\d+)\s*:\s*(\d+)\s*[–\-—]\s*(\d+)\s*:\s*(\d+)\s*$/u,
  );
  if (cross) {
    return {
      bookName: cross[1].trim(),
      chapter: Number(cross[2]),
      vStart: Number(cross[3]),
      vEnd: null,
      chapterEnd: Number(cross[4]),
      vEndAtChapterEnd: Number(cross[5]),
    };
  }

  const m = cleaned.match(
    /^(.+?)\s+(\d+)\s*(?::\s*(\d+)\s*(?:[–\-—]\s*(\d+))?|(?:[–\-—]\s*(\d+)))?\s*$/u,
  );
  if (!m) return null;
  const bookName = m[1].trim();
  const chapter = Number(m[2]);
  let vStart = 1;
  let vEnd = null;
  if (m[3]) {
    vStart = Number(m[3]);
    vEnd = m[4] ? Number(m[4]) : vStart;
  } else if (m[5]) {
    // "Êxodo 7–12" = chapters 7 through 12 → use ch7 v1–end as sample
    vStart = 1;
    vEnd = null;
    return { bookName, chapter, vStart, vEnd, chapterEnd: Number(m[5]) };
  }
  return { bookName, chapter, vStart, vEnd: vEnd ?? vStart };
}

function findBook(bookName) {
  loadBooks();
  const f = fold(bookName);
  return _byName.get(f) || _byAbbrev.get(f) || null;
}

/**
 * Texto contínuo da passagem. Limita a ~maxVerses para não estourar o palco.
 */
export function lookupPassage(ref, { maxVerses = 8, maxChars = 520 } = {}) {
  const parsed = parseRef(ref);
  if (!parsed) return '';
  const book = findBook(parsed.bookName);
  if (!book?.chapters?.length) return '';

  // Livros de 1 capítulo: "Obadias 21" / "Judas 3" = cap 1, verso N
  if (
    book.chapters.length === 1 &&
    parsed.chapter > 1 &&
    !String(ref).includes(':') &&
    parsed.chapter <= (book.chapters[0]?.length || 0)
  ) {
    parsed.vStart = parsed.chapter;
    parsed.vEnd = parsed.chapterEnd || parsed.chapter;
    parsed.chapter = 1;
    delete parsed.chapterEnd;
    delete parsed.vEndAtChapterEnd;
  }

  const chapters = [];
  if (parsed.chapterEnd && parsed.chapterEnd >= parsed.chapter) {
    // Intervalo de capítulos / Gn 1:1–2:3: amostra do 1º capítulo (e um pedaço do fim)
    const chStart = book.chapters[parsed.chapter - 1];
    if (!chStart) return '';
    const from = Math.max(0, (parsed.vStart || 1) - 1);
    chapters.push(...chStart.slice(from, from + maxVerses));
    if (parsed.vEndAtChapterEnd && parsed.chapterEnd > parsed.chapter) {
      const chEnd = book.chapters[parsed.chapterEnd - 1];
      if (chEnd) {
        const endTo = Math.min(chEnd.length, parsed.vEndAtChapterEnd);
        chapters.push(...chEnd.slice(0, Math.min(endTo, 3)));
      }
    }
  } else {
    const ch = book.chapters[parsed.chapter - 1];
    if (!ch) return '';
    const start = Math.max(0, (parsed.vStart || 1) - 1);
    const end = Math.min(ch.length, parsed.vEnd || parsed.vStart || start + 1);
    chapters.push(...ch.slice(start, end));
  }

  let text = chapters.join(' ').replace(/\s+/g, ' ').trim();
  if (text.length > maxChars) {
    const cut = text.slice(0, maxChars);
    const period = cut.lastIndexOf('.');
    const sp = cut.lastIndexOf(' ');
    text = (period > 80 ? cut.slice(0, period + 1) : sp > 40 ? cut.slice(0, sp) : cut).trim();
  }
  return text;
}

/** Prefer bible full text when study snippet is ellipsis / curto / vazio / rótulo. */
export function bestPassageText({ passageRef, passageText, hookRef, hookVerse } = {}) {
  const ref = passageRef || hookRef || '';
  const snippet = String(passageText || hookVerse || '').replace(/\s+/g, ' ').trim();
  const bible = lookupPassage(ref);
  const labelOnly =
    !!snippet &&
    wordCountSafe(snippet) <= 4 &&
    !/[;.!?]/.test(snippet.replace(/\.$/, ''));
  const weak =
    !snippet ||
    snippet.length < 24 ||
    labelOnly ||
    /…|\.\.\./.test(snippet) ||
    (bible && snippet.length < bible.length * 0.45);
  if (bible && weak) return bible;
  return snippet || bible || '';
}

function wordCountSafe(s) {
  return String(s || '')
    .split(/\s+/)
    .filter(Boolean).length;
}
