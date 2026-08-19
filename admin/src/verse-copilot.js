/**
 * Verse Copilot — guided bible reference picker with live preview.
 * Three-step drill-down: Book → Chapter → Verse(s), with breadcrumb nav,
 * keyboard support, instant text preview, and one-click fill.
 */

const BOOKS = [
  { abbrev: 'Gn', name: 'Gênesis', group: 'Pentateuco' },
  { abbrev: 'Êx', name: 'Êxodo', group: 'Pentateuco' },
  { abbrev: 'Lv', name: 'Levítico', group: 'Pentateuco' },
  { abbrev: 'Nm', name: 'Números', group: 'Pentateuco' },
  { abbrev: 'Dt', name: 'Deuteronômio', group: 'Pentateuco' },
  { abbrev: 'Js', name: 'Josué', group: 'Históricos' },
  { abbrev: 'Jz', name: 'Juízes', group: 'Históricos' },
  { abbrev: 'Rt', name: 'Rute', group: 'Históricos' },
  { abbrev: '1Sm', name: '1 Samuel', group: 'Históricos' },
  { abbrev: '2Sm', name: '2 Samuel', group: 'Históricos' },
  { abbrev: '1Rs', name: '1 Reis', group: 'Históricos' },
  { abbrev: '2Rs', name: '2 Reis', group: 'Históricos' },
  { abbrev: '1Cr', name: '1 Crônicas', group: 'Históricos' },
  { abbrev: '2Cr', name: '2 Crônicas', group: 'Históricos' },
  { abbrev: 'Ed', name: 'Esdras', group: 'Históricos' },
  { abbrev: 'Ne', name: 'Neemias', group: 'Históricos' },
  { abbrev: 'Et', name: 'Ester', group: 'Históricos' },
  { abbrev: 'Jó', name: 'Jó', group: 'Poéticos' },
  { abbrev: 'Sl', name: 'Salmos', group: 'Poéticos' },
  { abbrev: 'Pv', name: 'Provérbios', group: 'Poéticos' },
  { abbrev: 'Ec', name: 'Eclesiastes', group: 'Poéticos' },
  { abbrev: 'Ct', name: 'Cantares', group: 'Poéticos' },
  { abbrev: 'Is', name: 'Isaías', group: 'Profetas maiores' },
  { abbrev: 'Jr', name: 'Jeremias', group: 'Profetas maiores' },
  { abbrev: 'Lm', name: 'Lamentações', group: 'Profetas maiores' },
  { abbrev: 'Ez', name: 'Ezequiel', group: 'Profetas maiores' },
  { abbrev: 'Dn', name: 'Daniel', group: 'Profetas maiores' },
  { abbrev: 'Os', name: 'Oséias', group: 'Profetas menores' },
  { abbrev: 'Jl', name: 'Joel', group: 'Profetas menores' },
  { abbrev: 'Am', name: 'Amós', group: 'Profetas menores' },
  { abbrev: 'Ob', name: 'Obadias', group: 'Profetas menores' },
  { abbrev: 'Jn', name: 'Jonas', group: 'Profetas menores' },
  { abbrev: 'Mq', name: 'Miquéias', group: 'Profetas menores' },
  { abbrev: 'Na', name: 'Naum', group: 'Profetas menores' },
  { abbrev: 'Hc', name: 'Habacuque', group: 'Profetas menores' },
  { abbrev: 'Sf', name: 'Sofonias', group: 'Profetas menores' },
  { abbrev: 'Ag', name: 'Ageu', group: 'Profetas menores' },
  { abbrev: 'Zc', name: 'Zacarias', group: 'Profetas menores' },
  { abbrev: 'Ml', name: 'Malaquias', group: 'Profetas menores' },
  { abbrev: 'Mt', name: 'Mateus', group: 'Evangelhos' },
  { abbrev: 'Mc', name: 'Marcos', group: 'Evangelhos' },
  { abbrev: 'Lc', name: 'Lucas', group: 'Evangelhos' },
  { abbrev: 'Jo', name: 'João', group: 'Evangelhos' },
  { abbrev: 'At', name: 'Atos', group: 'Históricos NT' },
  { abbrev: 'Rm', name: 'Romanos', group: 'Epístolas paulinas' },
  { abbrev: '1Co', name: '1 Coríntios', group: 'Epístolas paulinas' },
  { abbrev: '2Co', name: '2 Coríntios', group: 'Epístolas paulinas' },
  { abbrev: 'Gl', name: 'Gálatas', group: 'Epístolas paulinas' },
  { abbrev: 'Ef', name: 'Efésios', group: 'Epístolas paulinas' },
  { abbrev: 'Fp', name: 'Filipenses', group: 'Epístolas paulinas' },
  { abbrev: 'Cl', name: 'Colossenses', group: 'Epístolas paulinas' },
  { abbrev: '1Ts', name: '1 Tessalonicenses', group: 'Epístolas paulinas' },
  { abbrev: '2Ts', name: '2 Tessalonicenses', group: 'Epístolas paulinas' },
  { abbrev: '1Tm', name: '1 Timóteo', group: 'Epístolas paulinas' },
  { abbrev: '2Tm', name: '2 Timóteo', group: 'Epístolas paulinas' },
  { abbrev: 'Tt', name: 'Tito', group: 'Epístolas paulinas' },
  { abbrev: 'Fm', name: 'Filemom', group: 'Epístolas paulinas' },
  { abbrev: 'Hb', name: 'Hebreus', group: 'Epístolas gerais' },
  { abbrev: 'Tg', name: 'Tiago', group: 'Epístolas gerais' },
  { abbrev: '1Pe', name: '1 Pedro', group: 'Epístolas gerais' },
  { abbrev: '2Pe', name: '2 Pedro', group: 'Epístolas gerais' },
  { abbrev: '1Jo', name: '1 João', group: 'Epístolas gerais' },
  { abbrev: '2Jo', name: '2 João', group: 'Epístolas gerais' },
  { abbrev: '3Jo', name: '3 João', group: 'Epístolas gerais' },
  { abbrev: 'Jd', name: 'Judas', group: 'Epístolas gerais' },
  { abbrev: 'Ap', name: 'Apocalipse', group: 'Profecia NT' },
];

/* ─── Bible loader (singleton) ─── */

let _bible = null;
let _loading = false;
const _waiters = [];

async function loadBible() {
  if (_bible) return _bible;
  if (_loading) return new Promise((r) => _waiters.push(r));
  _loading = true;
  try {
    const res = await fetch('/data/bible_tb.json');
    _bible = await res.json();
  } catch {
    try {
      const res = await fetch('../trilha_app/assets/data/bible_tb.json');
      _bible = await res.json();
    } catch {
      _bible = [];
    }
  }
  _loading = false;
  _waiters.forEach((r) => r(_bible));
  _waiters.length = 0;
  return _bible;
}

/* ─── Text utils ─── */

function norm(s) {
  return String(s || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim();
}

function esc(s) {
  const d = document.createElement('div');
  d.textContent = s || '';
  return d.innerHTML;
}

function findBook(q) {
  const n = norm(q);
  if (!n) return null;
  return (
    BOOKS.find((b) => norm(b.abbrev) === n)
    || BOOKS.find((b) => norm(b.name) === n)
    || BOOKS.find((b) => norm(b.name).startsWith(n))
    || BOOKS.find((b) => norm(b.abbrev).startsWith(n))
    || BOOKS.find((b) => norm(b.name).includes(n))
    || null
  );
}

function parseRef(text) {
  const s = String(text || '').trim();
  if (!s) return null;
  const m = s.match(/^(\d?\s*[A-Za-zÀ-ú]+)\s*(\d+)?(?:\s*[:.,]\s*(\d+))?(?:\s*[-–]\s*(\d+))?/);
  if (!m) return null;
  return {
    bookQuery: m[1].trim(),
    chapter: m[2] ? parseInt(m[2], 10) : null,
    verseStart: m[3] ? parseInt(m[3], 10) : null,
    verseEnd: m[4] ? parseInt(m[4], 10) : null,
  };
}

function getVerses(bookIdx, chapter, vs, ve) {
  const ch = _bible?.[bookIdx]?.chapters?.[chapter - 1];
  if (!ch) return null;
  const start = (vs || 1) - 1;
  const end = ve || vs || ch.length;
  return ch.slice(start, end).map((t, i) => ({ num: start + i + 1, text: t }));
}

function canonicalRef(bookName, chapter, vs, ve) {
  if (!chapter) return bookName;
  if (!vs) return `${bookName} ${chapter}`;
  return `${bookName} ${chapter}:${vs}${ve && ve !== vs ? '–' + ve : ''}`;
}

function lookupRef(refText) {
  if (!_bible?.length) return null;
  const parsed = parseRef(refText);
  if (!parsed?.bookQuery) return null;
  const book = findBook(parsed.bookQuery);
  if (!book) return null;
  const idx = BOOKS.indexOf(book);
  if (!parsed.chapter) return { book: book.name, ref: book.name, text: null, chapters: _bible[idx]?.chapters?.length || 0 };
  const verses = getVerses(idx, parsed.chapter, parsed.verseStart, parsed.verseEnd);
  if (!verses) return null;
  const ref = canonicalRef(book.name, parsed.chapter, parsed.verseStart, parsed.verseEnd);
  return { book: book.name, ref, verses, text: verses.map((v) => v.text).join(' ') };
}

/* ─── Copilot panel (replaces simple dropdown) ─── */

/**
 * Attach the full copilot experience.
 * @param {HTMLInputElement} input
 * @param {object} opts
 * @param {HTMLElement} opts.previewEl — preview box element
 * @param {function} opts.onPick — called with { ref, text, verses } when user confirms
 */
export function attachVerseCopilot(input, { previewEl, onPick } = {}) {
  if (!input) return;
  loadBible();
  input.setAttribute('autocomplete', 'off');

  let panel = null;
  let step = 'book'; // 'book' | 'chapter' | 'verse'
  let pickedBook = null; // BOOKS entry
  let pickedChapter = null;
  let highlighted = -1;
  let pickedRange = null;

  function bookIndex() {
    return pickedBook ? BOOKS.indexOf(pickedBook) : -1;
  }

  /* — Panel lifecycle — */

  function openPanel() {
    if (panel) return;
    panel = document.createElement('div');
    panel.className = 'vc-panel';
    const wrapper = input.closest('.ez-field') || input.parentElement;
    wrapper.style.position = 'relative';
    wrapper.appendChild(panel);
    paintPanel();
  }

  function closePanel() {
    if (panel) { panel.remove(); panel = null; }
    highlighted = -1;
  }

  /* — Paint — */

  function paintPanel() {
    if (!panel) return;
    highlighted = -1;

    const breadcrumb = `
      <div class="vc-breadcrumb">
        <button type="button" class="vc-crumb ${step === 'book' ? 'vc-crumb-on' : ''}" data-go="book">📖 Livro</button>
        ${pickedBook ? `<span class="vc-crumb-sep">›</span><button type="button" class="vc-crumb ${step === 'chapter' ? 'vc-crumb-on' : ''}" data-go="chapter">${esc(pickedBook.name)}</button>` : ''}
        ${pickedChapter ? `<span class="vc-crumb-sep">›</span><button type="button" class="vc-crumb vc-crumb-on" data-go="verse">${pickedChapter}</button>` : ''}
      </div>`;

    if (step === 'book') {
      const q = norm(input.value);
      const groups = {};
      BOOKS.forEach((b) => {
        if (q && !norm(b.name).includes(q) && !norm(b.abbrev).includes(q)) return;
        (groups[b.group] = groups[b.group] || []).push(b);
      });
      const empty = !Object.keys(groups).length;
      panel.innerHTML = `
        ${breadcrumb}
        <div class="vc-body vc-book-grid">
          ${empty ? '<p class="vc-empty">Nenhum livro encontrado</p>' : ''}
          ${Object.entries(groups).map(([g, books]) => `
            <div class="vc-group">
              <span class="vc-group-label">${esc(g)}</span>
              <div class="vc-group-items">
                ${books.map((b) => `<button type="button" class="vc-book-btn vc-item" data-book="${esc(b.abbrev)}" title="${esc(b.name)}">${esc(b.abbrev)}</button>`).join('')}
              </div>
            </div>`).join('')}
        </div>`;
    } else if (step === 'chapter') {
      const total = _bible?.[bookIndex()]?.chapters?.length || 0;
      panel.innerHTML = `
        ${breadcrumb}
        <div class="vc-body vc-num-grid">
          ${Array.from({ length: total }, (_, i) => `<button type="button" class="vc-num-btn vc-item" data-ch="${i + 1}">${i + 1}</button>`).join('')}
        </div>`;
    } else {
      const ch = _bible?.[bookIndex()]?.chapters?.[pickedChapter - 1] || [];
      panel.innerHTML = `
        ${breadcrumb}
        <p class="vc-tip">Clique num versículo ou selecione um intervalo (clique no primeiro, shift+clique no último).</p>
        <div class="vc-body vc-verse-list">
          ${ch.map((t, i) => `
            <button type="button" class="vc-verse-row vc-item" data-v="${i + 1}">
              <span class="vc-verse-num">${i + 1}</span>
              <span class="vc-verse-txt">${esc(t)}</span>
            </button>`).join('')}
        </div>
        ${pickedRange ? `
          <div class="vc-panel-action">
            <span class="vc-panel-action-ref">${esc(canonicalRef(pickedBook.name, pickedChapter, pickedRange.vs, pickedRange.ve))}</span>
            <button type="button" class="vc-panel-use" data-use-selected>Usar este texto</button>
          </div>` : ''}`;
    }

    bindPanel();
  }

  let rangeStart = null;

  function bindPanel() {
    if (!panel) return;

    // Prevent any mousedown inside the panel from stealing focus / triggering blur
    panel.addEventListener('mousedown', (e) => e.preventDefault());

    panel.querySelectorAll('[data-go]').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        const target = btn.dataset.go;
        if (target === 'book') { step = 'book'; pickedBook = null; pickedChapter = null; }
        else if (target === 'chapter') { step = 'chapter'; pickedChapter = null; }
        paintPanel();
        input.focus();
      });
    });

    panel.querySelectorAll('[data-book]').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        const b = BOOKS.find((x) => x.abbrev === btn.dataset.book);
        if (!b) return;
        pickedBook = b;
        step = 'chapter';
        input.value = b.name + ' ';
        input.dispatchEvent(new Event('input', { bubbles: true }));
        paintPanel();
        input.focus();
      });
    });

    panel.querySelectorAll('[data-ch]').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        pickedChapter = parseInt(btn.dataset.ch, 10);
        step = 'verse';
        rangeStart = null;
        pickedRange = null;
        input.value = `${pickedBook.name} ${pickedChapter}:`;
        input.dispatchEvent(new Event('input', { bubbles: true }));
        paintPanel();
        input.focus();
      });
    });

    panel.querySelectorAll('[data-v]').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        const v = parseInt(btn.dataset.v, 10);

        if (e.shiftKey && rangeStart != null && rangeStart !== v) {
          const vs = Math.min(rangeStart, v);
          const ve = Math.max(rangeStart, v);
          selectVerses(vs, ve);
        } else {
          rangeStart = v;
          selectVerses(v, null);
        }
      });
    });

    panel.querySelector('[data-use-selected]')?.addEventListener('click', (e) => {
      e.preventDefault();
      if (!pickedRange) return;
      const result = lookupRef(canonicalRef(pickedBook.name, pickedChapter, pickedRange.vs, pickedRange.ve));
      const plainText = result?.verses?.map((v) => v.text).join(' ');
      if (result && plainText && onPick) {
        onPick({ ref: result.ref, text: plainText, verses: result.verses });
        closePanel();
      }
    });
  }

  function selectVerses(vs, ve) {
    const ref = canonicalRef(pickedBook.name, pickedChapter, vs, ve);
    pickedRange = { vs, ve };
    input.value = ref;
    input.dispatchEvent(new Event('input', { bubbles: true }));
    updatePreview();
    paintPanel();

    // Highlight selected rows
    if (panel) {
      panel.querySelectorAll('[data-v]').forEach((r) => {
        const n = parseInt(r.dataset.v, 10);
        const inRange = ve ? (n >= vs && n <= ve) : n === vs;
        r.classList.toggle('vc-verse-selected', inRange);
      });
    }
  }

  /* — Preview — */

  function updatePreview() {
    if (!previewEl) return;
    const val = input.value.trim();
    if (!val || !_bible?.length) {
      previewEl.innerHTML = `<div class="vc-pv-empty"><span class="vc-pv-icon">📖</span>Digite ou escolha uma referência</div>`;
      previewEl.classList.remove('vc-pv-has-content');
      return;
    }
    const result = lookupRef(val);
    if (!result) {
      previewEl.innerHTML = `<div class="vc-pv-empty"><span class="vc-pv-icon">🔍</span>Referência não encontrada</div>`;
      previewEl.classList.remove('vc-pv-has-content');
      return;
    }
    if (!result.verses) {
      previewEl.innerHTML = `<div class="vc-pv-empty"><span class="vc-pv-icon">📖</span><strong>${esc(result.book)}</strong> — ${result.chapters} capítulos</div>`;
      previewEl.classList.remove('vc-pv-has-content');
      return;
    }

    previewEl.classList.add('vc-pv-has-content');
    previewEl.innerHTML = `
      <div class="vc-pv-card">
        <span class="vc-pv-ref">${esc(result.ref)}</span>
        <div class="vc-pv-verses">
          ${result.verses.map((v) => `<p class="vc-pv-v"><sup>${v.num}</sup>${esc(v.text)}</p>`).join('')}
        </div>
        <button type="button" class="vc-pv-use" title="Copiar texto para o campo 'Texto do verso'">Usar este texto ↓</button>
      </div>`;

    previewEl.querySelector('.vc-pv-use')?.addEventListener('click', () => {
      const plainText = result.verses.map((v) => v.text).join(' ');
      if (onPick) onPick({ ref: result.ref, text: plainText, verses: result.verses });
    });
  }

  /* — Events — */

  input.addEventListener('focus', () => {
    const parsed = parseRef(input.value);
    if (parsed?.bookQuery) {
      const b = findBook(parsed.bookQuery);
      if (b) {
        pickedBook = b;
        if (parsed.chapter) {
          pickedChapter = parsed.chapter;
          step = 'verse';
        } else {
          step = 'chapter';
        }
      }
    } else {
      step = 'book';
      pickedBook = null;
      pickedChapter = null;
    }
    openPanel();
    updatePreview();
  });

  input.addEventListener('input', () => {
    const val = input.value.trim();
    if (!val) {
      step = 'book';
      pickedBook = null;
      pickedChapter = null;
    }
    if (step === 'book') paintPanel();
    updatePreview();
  });

  input.addEventListener('blur', () => {
    setTimeout(closePanel, 200);
  });

  input.addEventListener('keydown', (e) => {
    if (!panel) return;
    const items = panel.querySelectorAll('.vc-item');
    if (!items.length) return;

    if (e.key === 'ArrowDown' || e.key === 'ArrowRight') {
      e.preventDefault();
      highlighted = Math.min(highlighted + 1, items.length - 1);
      items.forEach((it, i) => it.classList.toggle('vc-highlight', i === highlighted));
      items[highlighted]?.scrollIntoView({ block: 'nearest' });
    } else if (e.key === 'ArrowUp' || e.key === 'ArrowLeft') {
      e.preventDefault();
      highlighted = Math.max(highlighted - 1, 0);
      items.forEach((it, i) => it.classList.toggle('vc-highlight', i === highlighted));
      items[highlighted]?.scrollIntoView({ block: 'nearest' });
    } else if (e.key === 'Enter' && highlighted >= 0) {
      e.preventDefault();
      items[highlighted]?.click();
    } else if (e.key === 'Escape') {
      closePanel();
    } else if (e.key === 'Backspace' && !input.value.trim()) {
      if (step === 'verse') { step = 'chapter'; pickedChapter = null; paintPanel(); }
      else if (step === 'chapter') { step = 'book'; pickedBook = null; paintPanel(); }
    }
  });

  // Hydrate if field already has a value
  if (input.value.trim()) {
    loadBible().then(() => updatePreview());
  }
}

export { loadBible, lookupRef, BOOKS };
