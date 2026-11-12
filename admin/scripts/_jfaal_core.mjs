/**
 * Núcleo do acesso à JFAAL, sem `fs`: o mesmo código serve ao Node
 * (`_jfaal.mjs`, que lê o arquivo do app) e ao painel no navegador
 * (`src/jfaal-browser.js`, que baixa o JSON).
 *
 * `createJfaal(getBible)` recebe uma função que devolve a Bíblia carregada
 * (array de livros com `chapters[][]`) e devolve as funções de consulta.
 */

export const BOOK_NAMES = [
  'Gênesis', 'Êxodo', 'Levítico', 'Números', 'Deuteronômio', 'Josué', 'Juízes', 'Rute',
  '1 Samuel', '2 Samuel', '1 Reis', '2 Reis', '1 Crônicas', '2 Crônicas', 'Esdras', 'Neemias',
  'Ester', 'Jó', 'Salmos', 'Provérbios', 'Eclesiastes', 'Cantares', 'Isaías', 'Jeremias',
  'Lamentações', 'Ezequiel', 'Daniel', 'Oseias', 'Joel', 'Amós', 'Obadias', 'Jonas', 'Miqueias',
  'Naum', 'Habacuque', 'Sofonias', 'Ageu', 'Zacarias', 'Malaquias', 'Mateus', 'Marcos', 'Lucas',
  'João', 'Atos', 'Romanos', '1 Coríntios', '2 Coríntios', 'Gálatas', 'Efésios', 'Filipenses',
  'Colossenses', '1 Tessalonicenses', '2 Tessalonicenses', '1 Timóteo', '2 Timóteo', 'Tito',
  'Filemom', 'Hebreus', 'Tiago', '1 Pedro', '2 Pedro', '1 João', '2 João', '3 João', 'Judas',
  'Apocalipse',
];

export function fold(s) {
  return String(s || '')
    .normalize('NFD')
    .replace(/\p{M}/gu, '')
    .toLowerCase()
    .replace(/\s+/g, '');
}

const INDEX = new Map(BOOK_NAMES.map((b, i) => [fold(b), i]));
INDEX.set(fold('Salmo'), 18);

/** { book, chapter, start, end } ou null. Rejeita múltiplas faixas (";"). */
export function parseRef(ref) {
  const r = String(ref || '').trim();
  if (!r || r.includes(';') || r.includes(',')) return null;
  const m = r.match(/^(\d?\s*[^\d:]+?)\s*(\d+)(?::(\d+)(?:\s*[–-]\s*(\d+))?)?$/u);
  if (!m) return null;
  const book = INDEX.get(fold(m[1]));
  if (book === undefined) return null;
  const chapter = Number(m[2]);
  const start = m[3] ? Number(m[3]) : null;
  const end = m[4] ? Number(m[4]) : start;
  if (start !== null && end < start) return null;
  return { book, chapter, start, end };
}

export function verseCount(ref) {
  const p = parseRef(ref);
  if (!p || p.start === null) return Infinity;
  return p.end - p.start + 1;
}

export function createJfaal(getBible) {
  /** Texto JFAAL exatamente como `BibleService.passageText` monta (versos unidos por espaço). */
  function passageText(ref) {
    const p = parseRef(ref);
    if (!p) return null;
    const chapters = getBible()[p.book]?.chapters;
    const verses = chapters?.[p.chapter - 1];
    if (!verses) return null;
    const start = p.start ?? 1;
    const end = Math.min(p.end ?? verses.length, verses.length);
    if (start < 1 || start > verses.length) return null;
    const parts = [];
    for (let v = start; v <= end; v++) {
      const t = String(verses[v - 1] || '').trim();
      if (t) parts.push(t);
    }
    return parts.length ? parts.join(' ') : null;
  }

  /** Número de versos do capítulo (0 se não existir). */
  function chapterLength(bookIndex, chapter) {
    return getBible()[bookIndex]?.chapters?.[chapter - 1]?.length ?? 0;
  }

  /**
   * Faixas contínuas (um capítulo cada) de uma referência livre do catálogo:
   * "Gênesis 6:5–9; 9:12–13", "Gênesis 1:1–2:3", "Gênesis 2–3", "Gênesis 1:1".
   * Devolve [{ ref, book, chapter, start, end }]. Ignora o que não reconhece.
   */
  function splitRanges(raw) {
    const out = [];
    let book = null;
    let lastChapter = null;
    const push = (b, ch, s, e) => {
      const len = chapterLength(b, ch);
      if (!len) return;
      const start = Math.max(1, s ?? 1);
      const end = Math.min(len, e ?? len);
      if (start > end) return;
      const ref = start === end ? `${BOOK_NAMES[b]} ${ch}:${start}` : `${BOOK_NAMES[b]} ${ch}:${start}–${end}`;
      out.push({ ref, book: b, chapter: ch, start, end });
    };
    for (const part0 of String(raw || '').split(/[;,]/)) {
      let part = part0.trim().replace(/-/g, '–');
      if (!part) continue;
      const named = part.match(/^(\d?\s*[^\d:–]+?)\s*(\d.*)$/u);
      if (named) {
        const idx = BOOK_NAMES.findIndex((b) => fold(b) === fold(named[1]));
        const alt = fold(named[1]) === fold('Salmo') ? 18 : -1;
        if (idx >= 0 || alt >= 0) {
          book = idx >= 0 ? idx : alt;
          part = named[2];
          lastChapter = null;
        }
      }
      if (book === null) continue;
      let m;
      if ((m = part.match(/^(\d+):(\d+)–(\d+):(\d+)$/))) {
        const [c1, v1, c2, v2] = m.slice(1).map(Number);
        for (let ch = c1; ch <= c2; ch++) push(book, ch, ch === c1 ? v1 : 1, ch === c2 ? v2 : undefined);
        lastChapter = c2;
      } else if ((m = part.match(/^(\d+):(\d+)(?:–(\d+))?$/))) {
        const ch = Number(m[1]);
        push(book, ch, Number(m[2]), m[3] ? Number(m[3]) : Number(m[2]));
        lastChapter = ch;
      } else if ((m = part.match(/^(\d+)(?:–(\d+))?$/))) {
        // "12–13" depois de "9:" é faixa de versos no mesmo capítulo; sozinho, capítulos.
        if (lastChapter !== null && part0.trim().match(/^\d+(–\d+)?$/)) {
          push(book, lastChapter, Number(m[1]), m[2] ? Number(m[2]) : Number(m[1]));
        } else {
          const c1 = Number(m[1]);
          const c2 = m[2] ? Number(m[2]) : c1;
          for (let ch = c1; ch <= c2; ch++) push(book, ch);
          lastChapter = c2;
        }
      }
    }
    return out;
  }

  /** Versos um a um de uma faixa: [{ ref: "Gênesis 1:3", text }]. */
  function versesOf(range) {
    const verses = getBible()[range.book]?.chapters?.[range.chapter - 1] || [];
    const out = [];
    for (let v = range.start; v <= range.end; v++) {
      const t = String(verses[v - 1] || '').trim();
      if (t) out.push({ ref: `${BOOK_NAMES[range.book]} ${range.chapter}:${v}`, text: t });
    }
    return out;
  }

  return { parseRef, verseCount, passageText, chapterLength, splitRanges, versesOf };
}
