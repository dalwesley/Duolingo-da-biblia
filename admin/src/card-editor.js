/**
 * Coleção do Explorar criada no painel (`content_cards/{id}`).
 *
 * Cada coleção é uma categoria com um card só dela, no fim de uma porta
 * (Temas, Vida Cristã, Teologia) ou numa porta própria (NEW_DOOR: grava
 * também `content_shelves/{id}` com o mesmo nome). A trilha entra na
 * coleção gravando `category = id da coleção`. O app lê estes docs com o
 * catálogo (ExploreCard/ExploreShelf em trail_catalog.dart).
 */
import { COL, saveDoc } from './db.js';
import { cardShelves, CATEGORIES, JOURNEYS, SHELVES } from './catalog-tree.js';
import { renderShelfPreview } from './content-preview.js';
import { bindModalDismiss, escapeHtml, setLoading, showModalElement, showToast } from './ui.js';

const TITLE_MAX = 28;
const BLURB_MAX = 90;

/** Cor da coleção = cor do card no app. */
export const TONES = [
  { id: 'vida-crista', label: 'Vida Cristã (coral)' },
  { id: 'teologia', label: 'Teologia (azul-acinzentado)' },
  { id: 'antigo-testamento', label: 'Antigo Testamento (azul)' },
  { id: 'novo-testamento', label: 'Novo Testamento (verde-água)' },
];

/** Ícones do app (CinematicGlyph) com nome em português. O emoji é só a prévia. */
export const GLYPHS = [
  ['', 'Da coleção', '✦'],
  ['dove', 'Pomba', '🕊️'],
  ['heart', 'Coração', '❤️'],
  ['book', 'Livro', '📖'],
  ['scroll', 'Pergaminho', '📜'],
  ['seed', 'Semente', '🌱'],
  ['sprout', 'Broto', '🌿'],
  ['tree', 'Árvore', '🌳'],
  ['home', 'Casa', '🏠'],
  ['people', 'Pessoas', '👥'],
  ['flame', 'Chama', '🔥'],
  ['lamp', 'Lâmpada', '🪔'],
  ['star', 'Estrela', '⭐'],
  ['sun', 'Sol', '☀️'],
  ['mountain', 'Monte', '⛰️'],
  ['path', 'Caminho', '🛤️'],
  ['sea', 'Mar', '🌊'],
  ['crown', 'Coroa', '👑'],
  ['shield', 'Escudo', '🛡️'],
  ['gem', 'Joia', '💎'],
  ['link', 'Elo', '🔗'],
  ['tower', 'Torre', '🗼'],
  ['search', 'Lupa', '🔍'],
  ['mail', 'Carta', '✉️'],
  ['calendar', 'Calendário', '📅'],
  ['hourglass', 'Ampulheta', '⏳'],
  ['bell', 'Sino', '🔔'],
  ['gift', 'Presente', '🎁'],
  ['target', 'Alvo', '🎯'],
];

/** Valor do select "Onde aparece": porta nova na aba, só desta coleção. */
export const NEW_DOOR = '__new_door';

/** Sem o card (app antigo), a trilha cai na coleção principal. */
const FALLBACK = {
  'antigo-testamento': 'Antigo Testamento',
  'novo-testamento': 'Novo Testamento',
  'vida-crista': 'Discipulado',
  teologia: 'Teologia sistemática',
};

export function slugify(text) {
  return String(text || '')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 40);
}

/**
 * @param {{ cards: object[], shelves?: object[], existing?: object, shelf?: string, onSaved?: (card) => void }} opts
 */
export function openCardEditor({ cards = [], shelves = [], existing = null, shelf = 'tematicos', onSaved } = {}) {
  const modal = document.getElementById('modal');
  if (!modal) return;
  const isNew = !existing;
  const takenIds = new Set([...CATEGORIES.filter((c) => !c.extra).map((c) => c.id), ...cards.map((c) => c.id)]);
  const draft = {
    shelf: existing?.shelf || (shelf === NEW_DOOR || cardShelves().some((s) => s.id === shelf) ? shelf : 'tematicos'),
    realm: existing?.realm || (shelf === 'teologia' ? 'teologia' : 'vida-crista'),
    glyph: existing?.glyph || '',
    plus: existing ? existing.plus !== false : true,
    active: existing ? existing.active !== false : true,
    title: { pt: '', en: '', es: '', ...(existing?.title || {}) },
    blurb: { pt: '', en: '', es: '', ...(existing?.blurb || {}) },
  };

  function newId() {
    const base = slugify(draft.title.pt);
    if (!base) return '';
    if (!takenIds.has(base)) return base;
    let n = 2;
    while (takenIds.has(`${base}-${n}`)) n += 1;
    return `${base}-${n}`;
  }

  const idOf = () => existing?.id || newId();
  /** Porta própria usa o id da coleção (outra coleção do Firestore). */
  function doorId(id) {
    const used = new Set([...SHELVES.map((x) => x.id), ...shelves.map((x) => x.id)]);
    if (!used.has(id)) return id;
    let n = 2;
    while (used.has(`${id}-${n}`)) n += 1;
    return `${id}-${n}`;
  }

  function previewHtml() {
    const shelfLabel = draft.shelf === NEW_DOOR ? draft.title.pt : cardShelves().find((s) => s.id === draft.shelf)?.label || '';
    const neighbor = JOURNEYS.filter((j) => j.shelf === draft.shelf && j.id !== existing?.id).at(-1);
    const glyph = GLYPHS.find(([id]) => id === draft.glyph)?.[2] || '✦';
    return renderShelfPreview({
      shelfLabel,
      cards: [
        ...(neighbor ? [{ title: neighbor.label, blurb: '', tone: CATEGORIES.find((c) => c.id === neighbor.categories[0])?.realm }] : []),
        { title: draft.title.pt, blurb: draft.blurb.pt, plus: draft.plus, tone: draft.realm, icon: glyph, isNew: true },
      ],
    });
  }

  function idLine() {
    const id = idOf();
    if (!id) return 'O id sai do nome.';
    return `id <code>${escapeHtml(id)}</code>${isNew ? ' (fica fixo depois de criar)' : ''}: é o que a trilha grava em <code>category</code>.`;
  }

  function paintLive() {
    const slot = modal.querySelector('#card-preview');
    if (slot) slot.innerHTML = previewHtml();
    const id = modal.querySelector('#card-id');
    if (id) id.innerHTML = idLine();
    const fb = modal.querySelector('#card-fallback');
    if (fb) fb.textContent = FALLBACK[draft.realm] || '';
    modal.querySelectorAll('[data-count]').forEach((c) => {
      const [f, lang, max] = c.dataset.count.split(':');
      c.textContent = `${String(draft[f][lang] || '').trim().length}/${max}`;
    });
  }

  const text = (f, lang, max, ph) => `
    <label class="ez-field">
      <span class="ez-label">${f === 'title' ? 'Nome' : 'Frase'}${lang === 'pt' ? '' : ` (${lang.toUpperCase()})`} <span class="qe-count" data-count="${f}:${lang}:${max}">0/${max}</span></span>
      <input data-text="${f}:${lang}" maxlength="${max}" value="${escapeHtml(draft[f][lang] || '')}" placeholder="${escapeHtml(ph)}" autocomplete="off" />
    </label>`;

  modal.innerHTML = `
    <div class="modal-backdrop qs-backdrop">
      <div class="modal-card card qs-modal ct-create-modal" role="dialog" aria-modal="true" aria-labelledby="card-title">
        <header class="qs-head">
          <div>
            <p class="simple-kicker">Explorar</p>
            <h2 id="card-title">${isNew ? 'Nova coleção' : 'Editar coleção'}</h2>
          </div>
          <button type="button" class="modal-close" aria-label="Fechar">×</button>
        </header>
        <form id="card-form" class="qs-layout" novalidate>
          <div class="qs-form">
            ${text('title', 'pt', TITLE_MAX, 'Ex.: Família')}
            <span class="ez-hint qe-id-line" id="card-id">${idLine()}</span>
            ${text('blurb', 'pt', BLURB_MAX, 'Ex.: Casamento, filhos e lar à luz da Bíblia.')}
            <div class="qs-two">
              <label class="ez-field">
                <span class="ez-label">Onde aparece no Explorar</span>
                <select name="shelf">${cardShelves().map((s) => `<option value="${s.id}" ${s.id === draft.shelf ? 'selected' : ''}>Dentro de ${escapeHtml(s.label)}</option>`).join('')}${isNew ? `<option value="${NEW_DOOR}" ${draft.shelf === NEW_DOOR ? 'selected' : ''}>Porta própria na aba</option>` : ''}</select>
              </label>
              <label class="ez-field">
                <span class="ez-label">Cor</span>
                <select name="realm">${TONES.map((t) => `<option value="${t.id}" ${t.id === draft.realm ? 'selected' : ''}>${escapeHtml(t.label)}</option>`).join('')}</select>
              </label>
            </div>
            <div class="qs-two">
              <label class="ez-field">
                <span class="ez-label">Ícone</span>
                <select name="glyph">${GLYPHS.map(([id, label, emoji]) => `<option value="${id}" ${id === draft.glyph ? 'selected' : ''}>${emoji} ${escapeHtml(label)}</option>`).join('')}</select>
              </label>
              <div class="ez-field">
                <span class="ez-label">Acesso</span>
                <label class="ez-check card-check"><input type="checkbox" name="plus" ${draft.plus ? 'checked' : ''} /> <span>Peregrino+</span></label>
              </div>
            </div>
            <details class="qs-advanced">
              <summary>Inglês e espanhol (opcional: sem tradução, o app mostra o português)</summary>
              <div class="qs-advanced-body">
                ${text('title', 'en', TITLE_MAX, 'Family')}
                ${text('blurb', 'en', BLURB_MAX, 'Marriage, children and home in the light of the Bible.')}
                ${text('title', 'es', TITLE_MAX, 'Familia')}
                ${text('blurb', 'es', BLURB_MAX, 'Matrimonio, hijos y hogar a la luz de la Biblia.')}
              </div>
            </details>
            ${isNew ? '' : `<label class="ez-check card-check"><input type="checkbox" name="active" ${draft.active ? 'checked' : ''} /> <span>Mostrar no app (desmarcado, as trilhas dela vão para a coleção principal)</span></label>`}
            <p class="qe-note">Depois de criar, use <strong>+ Nova trilha</strong> e escolha esta coleção; na trilha, <strong>+ Nova cena</strong>.
              Versões antigas do app não conhecem coleções do painel: lá as trilhas dela aparecem em <strong id="card-fallback">${escapeHtml(FALLBACK[draft.realm] || '')}</strong>.</p>
          </div>
          <aside class="qs-aside" id="card-preview">${previewHtml()}</aside>
        </form>
        <div class="btn-row qs-actions">
          <button type="button" class="btn btn-secondary" id="cancel">Cancelar</button>
          <button type="submit" form="card-form" class="btn btn-primary">${isNew ? 'Criar coleção' : 'Salvar coleção'}</button>
        </div>
      </div>
    </div>`;

  showModalElement(modal);
  const close = bindModalDismiss(modal);
  const form = modal.querySelector('#card-form');
  form.querySelector('[data-text="title:pt"]')?.focus();
  paintLive();

  form.addEventListener('input', (e) => {
    const key = e.target.dataset.text;
    if (key) {
      const [f, lang] = key.split(':');
      draft[f][lang] = e.target.value;
    }
    paintLive();
  });
  form.addEventListener('change', (e) => {
    const { name, value, checked } = e.target;
    if (name === 'shelf' || name === 'realm' || name === 'glyph') draft[name] = value;
    if (name === 'plus' || name === 'active') draft[name] = checked;
    paintLive();
  });

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const id = idOf();
    if (!draft.title.pt.trim() || !id) {
      showToast('Escreva o nome da coleção', 'error');
      form.querySelector('[data-text="title:pt"]')?.focus();
      return;
    }
    const clean = (m) => Object.fromEntries(Object.entries(m).map(([k, v]) => [k, String(v || '').trim()]).filter(([, v]) => v));
    const ownDoor = draft.shelf === NEW_DOOR;
    const shelfId = ownDoor ? doorId(id) : draft.shelf;
    const order = existing?.order ?? Math.max(0, ...cards.filter((c) => c.shelf === shelfId).map((c) => Number(c.order) || 0)) + 1;
    const doc = {
      shelf: shelfId,
      realm: draft.realm,
      title: clean(draft.title),
      blurb: clean(draft.blurb),
      glyph: draft.glyph,
      plus: draft.plus,
      active: draft.active,
      order,
    };
    setLoading(true);
    try {
      // Porta antes da coleção: o app só aceita coleção de porta que existe.
      if (ownDoor) {
        await saveDoc(COL.shelves, shelfId, {
          title: doc.title,
          subtitle: doc.blurb,
          intro: {},
          sky: doc.realm,
          glyph: doc.glyph,
          plus: doc.plus,
          active: true,
          order: Math.max(0, ...shelves.map((x) => Number(x.order) || 0)) + 1,
        });
      }
      await saveDoc(COL.cards, id, doc);
      close();
      showToast(isNew ? 'Coleção criada. Agora a primeira trilha.' : 'Coleção salva');
      onSaved?.({ id, ...doc });
    } catch (err) {
      showToast(err.message || 'Erro', 'error');
    } finally {
      setLoading(false);
    }
  });
}
