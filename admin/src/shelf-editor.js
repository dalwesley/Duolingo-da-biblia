/**
 * Porta do Explorar criada no painel (`content_shelves/{id}`), no mesmo nível
 * de Bíblia, Temas, Vida Cristã e Teologia. Nasce com a primeira coleção
 * ("Porta própria na aba" em card-editor.js); aqui só se edita (frase,
 * apresentação, cor, ícone, ocultar). O app lê com o catálogo (ExploreShelf).
 */
import { COL, saveDoc } from './db.js';
import { SHELVES } from './catalog-tree.js';
import { GLYPHS, slugify, TONES } from './card-editor.js';
import { renderDoorsPreview } from './content-preview.js';
import { bindModalDismiss, escapeHtml, setLoading, showModalElement, showToast } from './ui.js';

const TITLE_MAX = 24;
const SUBTITLE_MAX = 70;
const INTRO_MAX = 220;

/** Portas fixas do app, para a prévia (cor e ícone como no app). */
const BUILT_IN_DOORS = {
  biblia: { tone: 'antigo-testamento', icon: '📖', subtitle: 'Antigo e Novo Testamento' },
  tematicos: { tone: 'novo-testamento', icon: '🛤️', subtitle: 'Caminhos pela Bíblia toda' },
  vidaCrista: { tone: 'vida-crista', icon: '🌱', subtitle: 'Fé no dia a dia' },
  teologia: { tone: 'teologia', icon: '📜', subtitle: 'Estudo mais fundo' },
};

/**
 * @param {{ shelves: object[], existing?: object, onSaved?: (shelf) => void }} opts
 */
export function openShelfEditor({ shelves = [], existing = null, onSaved } = {}) {
  const modal = document.getElementById('modal');
  if (!modal) return;
  const isNew = !existing;
  const taken = new Set([...SHELVES.filter((s) => !s.extra).map((s) => s.id), ...shelves.map((s) => s.id)]);
  const draft = {
    sky: existing?.sky || 'vida-crista',
    glyph: existing?.glyph || '',
    plus: existing ? existing.plus !== false : true,
    active: existing ? existing.active !== false : true,
    title: { pt: '', en: '', es: '', ...(existing?.title || {}) },
    subtitle: { pt: '', en: '', es: '', ...(existing?.subtitle || {}) },
    intro: { pt: '', en: '', es: '', ...(existing?.intro || {}) },
  };

  function newId() {
    const base = slugify(draft.title.pt);
    if (!base) return '';
    if (!taken.has(base)) return base;
    let n = 2;
    while (taken.has(`${base}-${n}`)) n += 1;
    return `${base}-${n}`;
  }
  const idOf = () => existing?.id || newId();

  function previewHtml() {
    const others = SHELVES.filter((s) => s.id !== existing?.id && !s.hidden).map((s) => {
      const b = BUILT_IN_DOORS[s.id];
      const glyph = GLYPHS.find(([id]) => id === s.shelf?.glyph)?.[2];
      return {
        title: s.label,
        subtitle: b?.subtitle || s.shelf?.subtitle?.pt || '',
        tone: b?.tone || s.shelf?.sky,
        icon: b?.icon || glyph || '✦',
      };
    });
    return renderDoorsPreview({
      doors: [
        ...others.slice(-3),
        {
          title: draft.title.pt,
          subtitle: draft.subtitle.pt,
          tone: draft.sky,
          icon: GLYPHS.find(([id]) => id === draft.glyph)?.[2] || '✦',
          plus: draft.plus,
          isNew: true,
        },
      ],
    });
  }

  function idLine() {
    const id = idOf();
    if (!id) return 'O id sai do nome.';
    return `id <code>${escapeHtml(id)}</code>${isNew ? ' (fica fixo depois de criar)' : ''}`;
  }

  function paintLive() {
    const slot = modal.querySelector('#shelf-preview');
    if (slot) slot.innerHTML = previewHtml();
    const id = modal.querySelector('#shelf-id');
    if (id) id.innerHTML = idLine();
    modal.querySelectorAll('[data-count]').forEach((c) => {
      const [f, lang, max] = c.dataset.count.split(':');
      c.textContent = `${String(draft[f][lang] || '').trim().length}/${max}`;
    });
  }

  const LABEL = { title: 'Nome', subtitle: 'Frase', intro: 'Apresentação' };
  const text = (f, lang, max, ph, area = false) => `
    <label class="ez-field">
      <span class="ez-label">${LABEL[f]}${lang === 'pt' ? '' : ` (${lang.toUpperCase()})`} <span class="qe-count" data-count="${f}:${lang}:${max}">0/${max}</span></span>
      ${area
        ? `<textarea data-text="${f}:${lang}" maxlength="${max}" rows="3" placeholder="${escapeHtml(ph)}">${escapeHtml(draft[f][lang] || '')}</textarea>`
        : `<input data-text="${f}:${lang}" maxlength="${max}" value="${escapeHtml(draft[f][lang] || '')}" placeholder="${escapeHtml(ph)}" autocomplete="off" />`}
    </label>`;

  modal.innerHTML = `
    <div class="modal-backdrop qs-backdrop">
      <div class="modal-card card qs-modal ct-create-modal" role="dialog" aria-modal="true" aria-labelledby="shelf-title">
        <header class="qs-head">
          <div>
            <p class="simple-kicker">Explorar</p>
            <h2 id="shelf-title">${isNew ? 'Nova porta' : 'Editar porta'}</h2>
          </div>
          <button type="button" class="modal-close" aria-label="Fechar">×</button>
        </header>
        <form id="shelf-form" class="qs-layout" novalidate>
          <div class="qs-form">
            ${text('title', 'pt', TITLE_MAX, 'Ex.: Família')}
            <span class="ez-hint qe-id-line" id="shelf-id">${idLine()}</span>
            ${text('subtitle', 'pt', SUBTITLE_MAX, 'Ex.: Casamento, filhos e lar à luz da Bíblia')}
            ${text('intro', 'pt', INTRO_MAX, 'Texto no topo da porta, acima das coleções. Vazio usa a frase.', true)}
            <div class="qs-two">
              <label class="ez-field">
                <span class="ez-label">Cor</span>
                <select name="sky">${TONES.map((t) => `<option value="${t.id}" ${t.id === draft.sky ? 'selected' : ''}>${escapeHtml(t.label)}</option>`).join('')}</select>
              </label>
              <label class="ez-field">
                <span class="ez-label">Ícone</span>
                <select name="glyph">${GLYPHS.map(([id, label, emoji]) => `<option value="${id}" ${id === draft.glyph ? 'selected' : ''}>${emoji} ${escapeHtml(label)}</option>`).join('')}</select>
              </label>
            </div>
            <label class="ez-check card-check"><input type="checkbox" name="plus" ${draft.plus ? 'checked' : ''} /> <span>Selo Peregrino+ na porta (cada card decide o próprio acesso)</span></label>
            <details class="qs-advanced">
              <summary>Inglês e espanhol (opcional: sem tradução, o app mostra o português)</summary>
              <div class="qs-advanced-body">
                ${text('title', 'en', TITLE_MAX, 'Family')}
                ${text('subtitle', 'en', SUBTITLE_MAX, 'Marriage, children and home in the light of the Bible')}
                ${text('intro', 'en', INTRO_MAX, '', true)}
                ${text('title', 'es', TITLE_MAX, 'Familia')}
                ${text('subtitle', 'es', SUBTITLE_MAX, 'Matrimonio, hijos y hogar a la luz de la Biblia')}
                ${text('intro', 'es', INTRO_MAX, '', true)}
              </div>
            </details>
            ${isNew ? '' : `<label class="ez-check card-check"><input type="checkbox" name="active" ${draft.active ? 'checked' : ''} /> <span>Mostrar no app</span></label>`}
            <p class="qe-note">A porta só aparece no app quando tiver pelo menos uma coleção. Para pôr outra coleção nela, use <strong>+ Nova coleção</strong> ao lado do nome.
              Precisa da versão do app que lê o Explorar do painel; nas antigas, as trilhas dela vão para a coleção principal.</p>
          </div>
          <aside class="qs-aside" id="shelf-preview">${previewHtml()}</aside>
        </form>
        <div class="btn-row qs-actions">
          <button type="button" class="btn btn-secondary" id="cancel">Cancelar</button>
          <button type="submit" form="shelf-form" class="btn btn-primary">${isNew ? 'Criar porta' : 'Salvar porta'}</button>
        </div>
      </div>
    </div>`;

  showModalElement(modal);
  const close = bindModalDismiss(modal);
  const form = modal.querySelector('#shelf-form');
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
    if (name === 'sky' || name === 'glyph') draft[name] = value;
    if (name === 'plus' || name === 'active') draft[name] = checked;
    paintLive();
  });

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const id = idOf();
    if (!draft.title.pt.trim() || !id) {
      showToast('Escreva o nome da porta', 'error');
      form.querySelector('[data-text="title:pt"]')?.focus();
      return;
    }
    const clean = (m) => Object.fromEntries(Object.entries(m).map(([k, v]) => [k, String(v || '').trim()]).filter(([, v]) => v));
    const order = existing?.order ?? Math.max(0, ...shelves.map((s) => Number(s.order) || 0)) + 1;
    const doc = {
      title: clean(draft.title),
      subtitle: clean(draft.subtitle),
      intro: clean(draft.intro),
      sky: draft.sky,
      glyph: draft.glyph,
      plus: draft.plus,
      active: draft.active,
      order,
    };
    setLoading(true);
    try {
      await saveDoc(COL.shelves, id, doc);
      close();
      showToast(isNew ? 'Porta criada. Agora a primeira coleção.' : 'Porta salva');
      onSaved?.({ id, ...doc });
    } catch (err) {
      showToast(err.message || 'Erro', 'error');
    } finally {
      setLoading(false);
    }
  });
}
