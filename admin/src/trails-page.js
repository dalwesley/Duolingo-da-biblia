import {
  bumpCatalogVersion,
  COL,
  countWhere,
  listCollection,
  listWhere,
  realmLabel,
  removeDoc,
  saveDoc,
  TRASH_DAYS,
} from './db.js';
import { renderIntroPreview, renderInsightPreview, renderJourneyPreview, renderTrailCardPreview } from './content-preview.js';
import {
  GESTURES,
  gestureMeta,
  listPassos,
  openQuestionStudio,
  questionsForPasso,
} from './question-studio.js';
import {
  bindModalDismiss,
  confirmAction,
  escapeHtml,
  setLoading,
  showModalElement,
  showToast,
} from './ui.js';
import { attachVerseCopilot, loadBible } from './verse-copilot.js';
import { contentHash } from './content-page.js';
import {
  CATEGORIES as TREE_CATEGORIES,
  JOURNEYS as TREE_JOURNEYS,
  SHELVES as TREE_SHELVES,
  categoryLabel as treeCategoryLabel,
  setExtraCards,
  setExtraShelves,
} from './catalog-tree.js';

const REALMS = [
  { value: 'antigo-testamento', label: 'Antigo Testamento', icon: '📜' },
  { value: 'novo-testamento', label: 'Novo Testamento', icon: '✝️' },
  { value: 'vida-crista', label: 'Vida Cristã', icon: '🌱' },
  { value: 'teologia', label: 'Teologia', icon: '📖' },
];

const CATEGORIES = [
  // Bíblia toda: gravadas no AT, cada uma vira um card próprio no app.
  { value: 'panorama', label: 'Panorama (Bíblia toda)', realm: 'antigo-testamento' },
  { value: 'personagens', label: 'Personagens (Bíblia toda)', realm: 'antigo-testamento' },
  { value: 'promessa-cumprimento', label: 'Promessa e cumprimento (Bíblia toda)', realm: 'antigo-testamento' },
  { value: 'temas-biblicos', label: 'Temas bíblicos (Bíblia toda)', realm: 'antigo-testamento' },
  { value: 'parabolas-milagres', label: 'Parábolas e milagres (Bíblia toda)', realm: 'antigo-testamento' },
  { value: 'pentateuco', label: 'Pentateuco', realm: 'antigo-testamento' },
  { value: 'historicos-at', label: 'Históricos (AT)', realm: 'antigo-testamento' },
  { value: 'poeticos', label: 'Poéticos', realm: 'antigo-testamento' },
  { value: 'profetas-maiores', label: 'Profetas maiores', realm: 'antigo-testamento' },
  { value: 'profetas-menores', label: 'Profetas menores', realm: 'antigo-testamento' },
  { value: 'intertestamentario', label: 'Intertestamentário', realm: 'antigo-testamento' },
  { value: 'evangelhos', label: 'Evangelhos', realm: 'novo-testamento' },
  { value: 'historicos-nt', label: 'Históricos (NT)', realm: 'novo-testamento' },
  { value: 'epistolas', label: 'Epístolas', realm: 'novo-testamento' },
  { value: 'apocalipse', label: 'Apocalipse', realm: 'novo-testamento' },
  { value: 'discipulado', label: 'Discipulado', realm: 'vida-crista' },
  { value: 'oracao', label: 'Oração', realm: 'vida-crista' },
  { value: 'historia-igreja', label: 'História da Igreja', realm: 'vida-crista' },
  { value: 'hermeneutica', label: 'Hermenêutica', realm: 'teologia' },
  { value: 'linguas', label: 'Línguas', realm: 'teologia' },
  { value: 'sistematica', label: 'Teologia sistemática', realm: 'teologia' },
  { value: 'cristologia', label: 'Cristologia', realm: 'teologia' },
];

function categoryLabel(value) {
  return CATEGORIES.find((c) => c.value === value)?.label || (value ? treeCategoryLabel(value) : '—');
}

/** Cards criados no painel, como opção de categoria (ver card-editor.js). */
function panelCategoryOptions() {
  return TREE_CATEGORIES.filter((c) => c.extra).map((c) => ({ value: c.id, label: `${c.label} (coleção do painel)`, realm: c.realm }));
}

function categoriesForRealm(realm) {
  return [...CATEGORIES, ...panelCategoryOptions()].filter((c) => c.realm === realm);
}

function defaultCategory(realm) {
  return categoriesForRealm(realm)[0]?.value || 'pentateuco';
}

function slugify(text) {
  return String(text || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 48);
}

function stepCount(trail) {
  return (trail.modules || []).reduce((n, m) => n + (m.missions?.length || 0), 0);
}

function emptyStudy() {
  return {
    passageRef: '',
    passageText: '',
    context: '',
    keyword: '',
    keywordGloss: '',
    focusQuestion: '',
    reflectionPrompts: [],
    relatedVerses: [],
  };
}

function emptyStep(n = 1, title = '') {
  return {
    slug: `passo-${n}`,
    title: title || `Cena ${n}`,
    subtitle: '',
    intro: '',
    type: 'lesson',
    xpReward: 50,
    questions: [],
    exercises: [],
    hookRef: '',
    hookVerse: '',
    hookNote: '',
    centralInsight: '',
    echoQuestion: '',
    objective: '',
  };
}

function field(label, control, { hint, where } = {}) {
  return `<label class="ez-field">
    <span class="ez-label-row">
      <span class="ez-label">${label}</span>
      ${where ? `<span class="ez-where">${where}</span>` : ''}
    </span>
    ${control}
    ${hint ? `<span class="ez-hint">${hint}</span>` : ''}
  </label>`;
}

function pad(n) {
  return String(n).padStart(2, '0');
}

function ensureStructure(draft, studyMap = {}) {
  if (!draft.modules?.length) {
    draft.modules = [{ title: draft.title || 'Jornada', icon: '📘', missions: [emptyStep(1)] }];
  }
  for (const mod of draft.modules) {
    if (!mod.missions?.length) mod.missions = [emptyStep(1)];
    for (const ms of mod.missions) {
      if (!ms._study) {
        const remote = studyMap[ms.slug];
        ms._study = remote
          ? {
              passageRef: remote.passageRef || '',
              passageText: remote.passageText || '',
              context: remote.context || '',
              keyword: remote.keyword || '',
              keywordGloss: remote.keywordGloss || '',
              focusQuestion: remote.focusQuestion || '',
              reflectionPrompts: remote.reflectionPrompts || [],
              relatedVerses: remote.relatedVerses || [],
            }
          : emptyStudy();
      }
    }
  }
  return draft;
}

function stripStudies(draft) {
  return {
    ...draft,
    modules: (draft.modules || []).map((mod) => ({
      ...mod,
      missions: (mod.missions || []).map(({ _study, ...ms }) => ms),
    })),
  };
}

const STUDY_V2_FIELDS = ['passageRef', 'passageText', 'context', 'keyword', 'keywordGloss', 'focusQuestion', 'reflectionPrompts', 'relatedVerses'];

/** Só os campos que o editor de trilha mexe — para gravar apenas o estudo que mudou. */
function studyFingerprint(study) {
  const s = study || {};
  return JSON.stringify(STUDY_V2_FIELDS.map((k) => s[k] ?? (k === 'reflectionPrompts' || k === 'relatedVerses' ? [] : '')));
}

function studyHasContent(study) {
  if (!study) return false;
  return Boolean(
    study.passageRef?.trim()
      || study.passageText?.trim()
      || study.context?.trim()
      || study.keyword?.trim()
      || study.keywordGloss?.trim()
      || study.focusQuestion?.trim(),
  );
}

function flatSteps(draft) {
  const out = [];
  (draft.modules || []).forEach((mod, mi) => {
    (mod.missions || []).forEach((ms, qi) => {
      out.push({ mi, qi, ms, mod });
    });
  });
  return out;
}

function qCount(bank, trailId) {
  if (bank instanceof Map) return bank.get(trailId) ?? 0;
  return (bank || []).filter((q) => q.trail === trailId || q.trailSlug === trailId).length;
}

function promptOf(q) {
  return (q.cue || q.prompt || q.question || '').trim();
}

/* ─── Lista ─────────────────────────────────────────────── */

export async function renderTrailsList(root, navigate) {
  root.innerHTML = `<div class="ez-page"><div class="ez-skeleton">Carregando…</div></div>`;
  const trails = await listCollection(COL.trails);
  // Contagem por trilha no servidor: não baixa o banco inteiro.
  const bank = new Map(await Promise.all(trails.map(async (t) => {
    const id = t.slug || t.id;
    return [id, await countWhere(COL.bank, 'trail', id).catch(() => 0)];
  })));
  let filter = 'all';
  let queryText = '';

  function filtered() {
    const q = queryText.trim().toLowerCase();
    return trails.filter((t) => {
      if (filter === 'live' && t.comingSoon) return false;
      if (filter === 'soon' && !t.comingSoon) return false;
      if (!q) return true;
      return `${t.title || ''} ${t.slug || ''}`.toLowerCase().includes(q);
    });
  }

  function paint() {
    const items = filtered();
    const live = trails.filter((t) => !t.comingSoon).length;

    root.innerHTML = `
      <div class="ez-page wide">
        <header class="ez-hero">
          <div>
            <h1>Trilhas</h1>
            <p class="ez-lead">Cada trilha é um caminho no app. Abra uma, escreva a cena, veja a miniatura.</p>
          </div>
          <button type="button" class="btn btn-primary" id="btn-new-trail">+ Nova trilha</button>
        </header>

        <div class="ez-toolbar">
          <input type="search" id="trail-search" class="ez-search" placeholder="Buscar pelo nome…" value="${escapeHtml(queryText)}" />
          <div class="ez-pills">
            <button type="button" class="ez-pill ${filter === 'all' ? 'active' : ''}" data-filter="all">Todas (${trails.length})</button>
            <button type="button" class="ez-pill ${filter === 'live' ? 'active' : ''}" data-filter="live">No ar (${live})</button>
            <button type="button" class="ez-pill ${filter === 'soon' ? 'active' : ''}" data-filter="soon">Rascunho (${trails.length - live})</button>
          </div>
        </div>

        ${trails.length === 0
          ? `<div class="ez-empty">
              <h2>Nenhuma trilha ainda</h2>
              <p>Só o nome — depois você vê no celular de mentira onde cada texto entra.</p>
              <button type="button" class="btn btn-primary" id="btn-empty-new">Criar a primeira</button>
            </div>`
          : items.length === 0
            ? `<div class="ez-empty"><p>Nada neste filtro.</p></div>`
            : `<div class="trail-app-grid">
                ${items.map((t) => {
                  const nQ = qCount(bank, t.slug || t.id);
                  const nS = stepCount(t);
                  return `
                  <article class="trail-app-card" data-open="${escapeHtml(t.id)}" style="--trail-c:${escapeHtml(t.color || '#4A9EFF')}">
                    <div class="trail-app-sky">
                      <span class="trail-app-icon">${escapeHtml(t.icon || '📖')}</span>
                      <span class="ez-status ${t.comingSoon ? 'soon' : 'live'}">${t.comingSoon ? 'Rascunho' : 'No ar'}</span>
                    </div>
                    <div class="trail-app-body">
                      <h2>${escapeHtml(t.title || t.id)}</h2>
                      <p>${escapeHtml((t.description || '').trim() || 'Sem descrição ainda')}</p>
                      <div class="ez-meta">
                        <span>${escapeHtml(realmLabel(t.realm))}</span>
                        <span>${nS} ${nS === 1 ? 'cena' : 'cenas'}</span>
                        <span>${nQ} ${nQ === 1 ? 'ação' : 'ações'}</span>
                      </div>
                    </div>
                    <div class="ez-card-actions" onclick="event.stopPropagation()">
                      <button type="button" class="btn btn-primary btn-sm" data-edit="${escapeHtml(t.id)}">Abrir</button>
                      <button type="button" class="btn btn-ghost btn-sm" data-del="${escapeHtml(t.id)}">Excluir</button>
                    </div>
                  </article>`;
                }).join('')}
              </div>`}
      </div>`;

    root.querySelector('#trail-search')?.addEventListener('input', (e) => {
      queryText = e.target.value;
      paint();
      const input = root.querySelector('#trail-search');
      input?.focus();
      input?.setSelectionRange(input.value.length, input.value.length);
    });
    root.querySelectorAll('[data-filter]').forEach((btn) => {
      btn.addEventListener('click', () => {
        filter = btn.dataset.filter;
        paint();
      });
    });
    const openCreate = () => openCreateSimple(trails, navigate);
    root.querySelector('#btn-new-trail')?.addEventListener('click', openCreate);
    root.querySelector('#btn-empty-new')?.addEventListener('click', openCreate);
    root.querySelectorAll('[data-open], [data-edit]').forEach((el) => {
      el.addEventListener('click', () => navigate(`trail:${el.dataset.open || el.dataset.edit}`));
    });
    root.querySelectorAll('[data-del]').forEach((btn) => {
      btn.addEventListener('click', async (e) => {
        e.stopPropagation();
        if (!(await confirmAction(`Excluir “${btn.dataset.del}”?`))) return;
        setLoading(true);
        try {
          await removeDoc(COL.trails, btn.dataset.del);
          showToast('Removida');
          await renderTrailsList(root, navigate);
        } catch (err) {
          showToast(err.message || 'Erro', 'error');
        } finally {
          setLoading(false);
        }
      });
    });
  }

  paint();
}

/* ─── Criar: nome + miniatura ───────────────────────────── */

/** Criar trilha de fora desta tela (Explorar). Nasce "em breve": não aparece no app. */
export function openCreateTrail(trails, navigate, { category } = {}) {
  openCreateSimple(trails, navigate, { category });
}

const TITLE_MAX = 40;
const DESC_MAX = 90;

/** Lugar no Explorar, agrupado como a árvore: AT e NT por fase, o resto por prateleira. */
function placeOptions(selected) {
  const opt = (c) => `<option value="${c}" ${c === selected ? 'selected' : ''}>${escapeHtml(treeCategoryLabel(c))}</option>`;
  return TREE_SHELVES.map((shelf) => {
    const journeys = TREE_JOURNEYS.filter((j) => j.shelf === shelf.id);
    if (shelf.id === 'biblia') {
      return journeys.map((j) => `<optgroup label="${escapeHtml(`Bíblia › ${j.label}`)}">${j.categories.map(opt).join('')}</optgroup>`).join('');
    }
    return `<optgroup label="${escapeHtml(shelf.label)}">${journeys.flatMap((j) => j.categories).map(opt).join('')}</optgroup>`;
  }).join('');
}

function realmOfCategory(category) {
  return TREE_CATEGORIES.find((c) => c.id === category)?.realm || 'antigo-testamento';
}

/** Onde a trilha aparece, por extenso: "Bíblia › Antigo Testamento › Pentateuco". */
function placePath(category) {
  const j = TREE_JOURNEYS.find((x) => x.categories.includes(category));
  const shelf = TREE_SHELVES.find((x) => x.id === j?.shelf);
  const parts = shelf?.id === 'biblia' ? [shelf.label, j.label] : [shelf?.label];
  return [...parts, treeCategoryLabel(category)].filter(Boolean).join(' › ');
}

function roman(n) {
  const table = [[1000, 'M'], [900, 'CM'], [500, 'D'], [400, 'CD'], [100, 'C'], [90, 'XC'], [50, 'L'], [40, 'XL'], [10, 'X'], [9, 'IX'], [5, 'V'], [4, 'IV'], [1, 'I']];
  let out = '';
  let k = n;
  for (const [v, r] of table) {
    while (k >= v) {
      out += r;
      k -= v;
    }
  }
  return out;
}

/** Lido na hora: os cards do painel entram depois do carregamento. */
const categoryOrder = (id) => TREE_CATEGORIES.find((c) => c.id === id)?.order ?? 0;

/**
 * O caminho da jornada como o app monta (ordem da categoria, depois `order`),
 * com a trilha nova no fim da categoria dela. Mostra a fase dela: até 2
 * vizinhas antes e a nova em destaque.
 */
function journeyPreviewData(trails, draft) {
  const journey = TREE_JOURNEYS.find((j) => j.categories.includes(draft.category));
  const shelf = TREE_SHELVES.find((x) => x.id === journey?.shelf);
  const scenes = (t) => (t.modules || []).reduce((n, m) => n + (m.missions || []).length, 0);
  const existing = trails
    .filter((t) => journey?.categories.includes(t.category))
    .sort((a, b) => (categoryOrder(a.category) - categoryOrder(b.category)) || ((Number(a.order) || 0) - (Number(b.order) || 0)));
  const fresh = { isNew: true, category: draft.category, title: draft.title, description: draft.description };
  const lastOfCat = existing.map((t) => categoryOrder(t.category) <= categoryOrder(draft.category)).lastIndexOf(true);
  const list = [...existing.slice(0, lastOfCat + 1), fresh, ...existing.slice(lastOfCat + 1)];

  let phase = 0;
  let last = null;
  const stations = list.map((t, i) => {
    if (t.category !== last) {
      phase += 1;
      last = t.category;
    }
    return {
      phase,
      roman: roman(i + 1),
      title: t.title || t.slug || t.id || '',
      status: t.isNew ? t.description : t.comingSoon ? '' : t.description || `${scenes(t)} cenas`,
      soon: t.isNew || Boolean(t.comingSoon),
      isNew: Boolean(t.isNew),
      category: t.category,
    };
  });
  const at = stations.findIndex((x) => x.isNew);
  const sameCat = stations.filter((x, i) => x.category === draft.category && i <= at);
  const shown = sameCat.slice(-3);
  const multi = (journey?.categories.length || 0) > 1;
  return {
    journeyLabel: journey?.label || '',
    subtitle: shelf?.label || '',
    phaseIndex: multi ? stations[at].phase : 1,
    phaseLabel: treeCategoryLabel(draft.category),
    stations: shown,
    before: at + 1 - shown.length,
  };
}

function uniqueSlug(name, trails) {
  const base = slugify(name);
  if (!base) return '';
  const used = new Set(trails.flatMap((t) => [t.id, t.slug]));
  if (!used.has(base)) return base;
  let n = 2;
  while (used.has(`${base}-${n}`)) n += 1;
  return `${base}-${n}`;
}

/* ─── Criar: nome, linha, lugar + cartão ────────────────── */

function openCreateSimple(trails, navigate, { category: initial } = {}) {
  const modal = document.getElementById('modal');
  if (!modal) return;
  const draft = {
    title: '',
    description: '',
    category: TREE_CATEGORIES.some((c) => c.id === initial) ? initial : 'pentateuco',
  };

  function realmMeta() {
    return REALMS.find((x) => x.value === realmOfCategory(draft.category)) || REALMS[0];
  }

  function previewHtml() {
    return renderJourneyPreview(journeyPreviewData(trails, draft));
  }

  function idLine() {
    const slug = uniqueSlug(draft.title, trails);
    return slug ? `id <code>${escapeHtml(slug)}</code> (fica fixo depois de criar)` : 'O id sai do nome.';
  }

  function paintLive() {
    const slot = modal.querySelector('#create-preview');
    if (slot) slot.innerHTML = previewHtml();
    const id = modal.querySelector('#create-id');
    if (id) id.innerHTML = idLine();
    const where = modal.querySelector('#create-where');
    if (where) where.textContent = placePath(draft.category);
    for (const [f, max] of [['title', TITLE_MAX], ['description', DESC_MAX]]) {
      const c = modal.querySelector(`[data-count="${f}"]`);
      if (c) c.textContent = `${draft[f].trim().length}/${max}`;
    }
  }

  modal.innerHTML = `
    <div class="modal-backdrop qs-backdrop">
      <div class="modal-card card qs-modal ct-create-modal" role="dialog" aria-modal="true" aria-labelledby="ct-create-title">
        <header class="qs-head">
          <div>
            <p class="simple-kicker">Explorar</p>
            <h2 id="ct-create-title">Nova trilha</h2>
          </div>
          <button type="button" class="modal-close" aria-label="Fechar">×</button>
        </header>
        <form id="create-trail-form" class="qs-layout" novalidate>
          <div class="qs-form">
            <label class="ez-field">
              <span class="ez-label">Nome <span class="qe-count" data-count="title">0/${TITLE_MAX}</span></span>
              <input name="title" maxlength="${TITLE_MAX}" required placeholder="Ex.: Gênesis 1–11" autocomplete="off" />
              <span class="ez-hint" id="create-id">O id sai do nome.</span>
            </label>
            <label class="ez-field">
              <span class="ez-label">Uma linha sobre o caminho <span class="qe-count" data-count="description">0/${DESC_MAX}</span></span>
              <input name="description" maxlength="${DESC_MAX}" placeholder="Ex.: Da criação a Babel: quem é Deus e quem somos nós." autocomplete="off" />
              <span class="ez-hint">Opcional. Aparece embaixo do nome no cartão.</span>
            </label>
            <label class="ez-field">
              <span class="ez-label">Coleção</span>
              <select name="category">${placeOptions(draft.category)}</select>
              <span class="ez-hint"><span id="create-where">${escapeHtml(placePath(draft.category))}</span>. A trilha é nova e tem cenas próprias; aqui você só escolhe em qual coleção do Explorar ela aparece.</span>
            </label>
            <p class="qe-note">A trilha nasce <strong>em breve</strong>: ninguém vê no app. Depois de criar, você monta as cenas e tira o “em breve” em <strong>Editar trilha</strong>.</p>
          </div>
          <aside class="qs-aside" id="create-preview">${previewHtml()}</aside>
        </form>
        <div class="btn-row qs-actions">
          <button type="button" class="btn btn-secondary" id="cancel">Cancelar</button>
          <button type="submit" form="create-trail-form" class="btn btn-primary">Criar e abrir</button>
        </div>
      </div>
    </div>`;

  showModalElement(modal);
  const close = bindModalDismiss(modal);
  modal.querySelector('#cancel')?.addEventListener('click', close);
  const form = modal.querySelector('#create-trail-form');
  form.querySelector('[name="title"]')?.focus();

  form.addEventListener('input', (e) => {
    const { name, value } = e.target;
    if (name in draft) draft[name] = value;
    paintLive();
  });
  form.addEventListener('change', (e) => {
    if (e.target.name === 'category') {
      draft.category = e.target.value;
      paintLive();
    }
  });

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const title = draft.title.trim();
    if (!title) {
      showToast('Escreva o nome da trilha', 'error');
      form.querySelector('[name="title"]')?.focus();
      return;
    }
    const slug = uniqueSlug(title, trails) || `trilha-${Date.now()}`;
    const realm = realmOfCategory(draft.category);
    setLoading(true);
    try {
      await saveDoc(COL.trails, slug, {
        slug,
        title,
        description: draft.description.trim(),
        icon: realmMeta().icon,
        order: trails.filter((t) => t.category === draft.category).length + 1,
        unlockAfter: null,
        comingSoon: true,
        color: realm === 'novo-testamento' ? '#3DCFBE' : realm === 'vida-crista' ? '#FFA898' : realm === 'teologia' ? '#7EB0D8' : '#4A9EFF',
        realm,
        category: draft.category,
        modules: [{ title, icon: '📘', missions: [emptyStep(1, 'Primeira cena')] }],
        isActive: true,
      });
      close();
      showToast('Trilha criada (em breve). Agora a primeira cena.');
      navigate(`trail:${slug}`);
    } catch (err) {
      showToast(err.message || 'Erro', 'error');
    } finally {
      setLoading(false);
    }
  });
}

/* ─── Editor: cena + miniatura + ações do banco ─────────── */

export async function renderTrailEditor(root, route, navigate) {
  // `trail:<id>:cena` (botão + Nova cena do Explorar) abre já com a cena nova.
  const [trailId, intent] = String(route).split(':');
  root.innerHTML = `<div class="ez-page"><div class="ez-skeleton">Abrindo…</div></div>`;
  loadBible();
  const [trails, studies, bankStart, cards, shelves] = await Promise.all([
    listCollection(COL.trails),
    listCollection(COL.studies, 'slug'),
    listWhere(COL.bank, 'trail', trailId),
    listCollection(COL.cards).catch(() => []),
    listCollection(COL.shelves).catch(() => []),
  ]);
  setExtraShelves(shelves);
  setExtraCards(cards);
  const trail = trails.find((t) => t.id === trailId);
  if (!trail) {
    root.innerHTML = `<div class="ez-page"><div class="ez-empty"><h2>Não encontrada</h2><button class="btn btn-primary" data-route="trails">Voltar</button></div></div>`;
    root.querySelector('[data-route]')?.addEventListener('click', (e) => {
      e.preventDefault();
      navigate('trails');
    });
    return;
  }

  const studyMap = Object.fromEntries(studies.map((s) => [s.id, s]));
  const studyPrints = new Map(studies.map((s) => [s.id, studyFingerprint(s)]));
  let draft = ensureStructure(
    structuredClone({ ...trail, modules: trail.modules || [] }),
    studyMap,
  );
  let bank = bankStart;
  let focus = { mi: 0, qi: 0 };
  let showMore = false;
  let dirty = false;
  let previewScreen = 'intro';
  let previewFocus = 'title';

  function markDirty() {
    dirty = true;
    root.querySelectorAll('[data-save]').forEach((b) => {
      b.classList.add('needs-save');
      b.textContent = 'Salvar';
    });
  }

  function current() {
    return draft.modules[focus.mi]?.missions?.[focus.qi] || null;
  }

  function stepIndex() {
    const steps = flatSteps(draft);
    const i = steps.findIndex((s) => s.mi === focus.mi && s.qi === focus.qi);
    return i >= 0 ? i + 1 : 1;
  }

  function paintPreview() {
    const slot = root.querySelector('#studio-preview');
    if (!slot) return;
    const ms = current();
    if (previewScreen === 'insight') {
      slot.innerHTML = renderInsightPreview(ms?.centralInsight || '', { focus: previewFocus });
      return;
    }
    slot.innerHTML = renderIntroPreview(ms || {}, {
      focus: previewFocus,
      trailTitle: draft.title,
    });
  }

  function render() {
    const steps = flatSteps(draft);
    const ms = current();
    const idx = stepIndex();
    const study = ms?._study || emptyStudy();
    const acts = ms ? questionsForPasso(bank, { trail: trailId, section: ms.slug }) : [];
    const legacy = (ms?.questions || []).filter((q) => (q.question || '').trim());

    root.innerHTML = `
      <div class="ez-page studio-page">
        <header class="simple-top">
          <button type="button" class="btn btn-ghost btn-sm" data-back>← Explorar</button>
          <div class="simple-top-title">
            <strong>${escapeHtml(draft.title || trailId)}</strong>
            <span>${draft.comingSoon ? 'Rascunho' : 'No ar'} · ${steps.length} cenas · ${qCount(bank, trailId)} ações</span>
          </div>
          <button type="button" class="btn btn-primary" data-save>${dirty ? 'Salvar' : 'Salvo'}</button>
        </header>

        <p class="simple-guide">Escreva a <strong>cena</strong> (título + verso) e adicione as <strong>perguntas</strong> embaixo. A miniatura à direita mostra o celular.</p>

        <div class="simple-steps">
          ${steps.map((s, i) => {
            const n = questionsForPasso(bank, { trail: trailId, section: s.ms.slug }).length;
            return `
            <button type="button" class="simple-step-chip ${s.mi === focus.mi && s.qi === focus.qi ? 'active' : ''}" data-focus="${s.mi}-${s.qi}" title="${escapeHtml(s.ms.title || '')}">
              ${pad(i + 1)}${n ? `<em>${n}</em>` : ''}
            </button>`;
          }).join('')}
          <button type="button" class="simple-step-chip add" data-add-step>+ Nova cena</button>
        </div>

        ${!ms
          ? `<div class="ez-empty"><p>Sem cenas.</p><button type="button" class="btn btn-primary" data-add-step>Criar cena</button></div>`
          : `
        <div class="studio">
          <div class="studio-main">
            <section class="simple-card">
              <p class="simple-kicker">Cena ${pad(idx)} · tela de entrada</p>
              ${field(
                'Título',
                `<input id="f-title" data-preview="title" data-screen="intro" value="${escapeHtml(ms.title || '')}" placeholder="Ex.: Quem criou o mundo?" />`,
                { where: 'Topo da tela e nome no caminho' },
              )}
              ${field(
                'Verso âncora · referência',
                `<input id="f-hook-ref" data-preview="hookRef" data-screen="intro" value="${escapeHtml(ms.hookRef || study.passageRef || '')}" placeholder="Comece a digitar — Ex.: Gênesis, Jo, Sl…" />`,
                { where: 'Dourado, acima do texto do verso', hint: 'Um ou dois versos — não um capítulo.' },
              )}
              <div id="vc-preview" class="vc-preview-box"></div>
              ${field(
                'Texto do verso',
                `<textarea id="f-hook-verse" data-preview="hookVerse" data-screen="intro" rows="3" placeholder="Trecho curto, o aluno lê antes de começar.">${escapeHtml(ms.hookVerse || study.passageText || '')}</textarea>`,
                { where: 'Cartão no centro da tela de entrada' },
              )}
              ${field(
                'Nota de entrada',
                `<textarea id="f-hook-note" data-preview="hookNote" data-screen="intro" rows="2" placeholder="Uma ou duas linhas de contexto.">${escapeHtml(ms.hookNote || study.context || '')}</textarea>`,
                { where: 'Abaixo do verso, ainda na entrada' },
              )}
              ${field(
                'Descritivo (se não houver verso)',
                `<textarea id="f-intro" data-preview="intro" data-screen="intro" rows="2" placeholder="Só aparece se o verso e a nota estiverem vazios.">${escapeHtml(ms.intro || '')}</textarea>`,
                { where: 'Texto solto no lugar do cartão' },
              )}
              ${field(
                'Frase “Hoje”',
                `<input id="f-insight" data-preview="insight" data-screen="insight" maxlength="140" value="${escapeHtml(ms.centralInsight || '')}" placeholder="O que ficou — até 140 caracteres" />`,
                { where: 'Tela final, depois das perguntas' },
              )}
              ${field(
                'Eco (pergunta aberta)',
                `<textarea id="f-echo" rows="2" maxlength="160" placeholder="Pergunta que esta missão responde — plantada ontem, sem spoiler.">${escapeHtml(ms.echoQuestion || '')}</textarea>`,
                { where: 'Celebração de ontem + porta de hoje. Vazio = gancho clássico.' },
              )}
              ${field(
                'Objetivo (só no painel)',
                `<input id="f-objective" value="${escapeHtml(ms.objective || '')}" placeholder="O que o aprendiz deve conseguir fazer" />`,
                { hint: 'Não aparece no app. Ajuda quem escreve o conteúdo.' },
              )}
            </section>

            <section class="simple-card">
              <div class="row-between">
                <div>
                  <h2>Perguntas desta cena</h2>
                  <p class="ez-lead" style="margin:0">Toque num gesto para criar; toque numa pergunta para editar.</p>
                </div>
                <button type="button" class="btn btn-ghost btn-sm" data-route-bank>Revisar no banco →</button>
              </div>
              <div class="gesture-row add-row all-types">
                ${GESTURES.filter((g) => !g.legacy).map((g) => `
                  <button type="button" class="gesture-chip" data-add-g="${g.id}" title="${escapeHtml(g.blurb)}">
                    <span class="gesture-icon">${escapeHtml(g.icon || '•')}</span>
                    <strong>${escapeHtml(g.label)}</strong>
                    <small>${escapeHtml(g.verb)}</small>
                  </button>`).join('')}
              </div>
              ${acts.length === 0
                ? `<div class="simple-empty-q"><p>Nenhuma pergunta ainda. Toque em um tipo acima.</p></div>`
                : `<div class="act-list">
                    ${acts.map((q) => {
                      const g = gestureMeta(q.type);
                      return `
                        <div class="act-row-wrap">
                          <button type="button" class="act-row" data-edit-q="${escapeHtml(q.id)}">
                            <span class="act-type">${escapeHtml(g.label)}</span>
                            <span class="act-stem">${escapeHtml(promptOf(q).slice(0, 90) || '(sem texto)')}</span>
                            <span class="act-diff">${escapeHtml(q.difficulty || '')}</span>
                          </button>
                          <button type="button" class="btn btn-ghost btn-sm" data-del-q="${escapeHtml(q.id)}" title="Excluir">✕</button>
                        </div>`;
                    }).join('')}
                  </div>`}
              ${legacy.length
                ? `<details class="simple-more" style="margin-top:var(--space-4)">
                    <summary>Quiz antigo nesta cena (${legacy.length}) — fallback</summary>
                    <p class="ez-hint">O app prefere as ações do banco. Isto só entra se o banco desta cena estiver vazio.</p>
                  </details>`
                : ''}
            </section>

            <details class="simple-more" ${showMore ? 'open' : ''}>
              <summary>Trilha, estudo e avançado</summary>
              <div class="simple-more-body">
                ${field('Nome da trilha', `<input id="t-title" value="${escapeHtml(draft.title || '')}" />`, { where: 'Cartão da trilha no app' })}
                ${field('Descrição', `<textarea id="t-desc" rows="2">${escapeHtml(draft.description || '')}</textarea>`, { where: 'Abaixo do nome no cartão' })}
                <div class="ez-form-grid">
                  ${field('Ícone', `<input id="t-icon" value="${escapeHtml(draft.icon || '')}" maxlength="4" />`)}
                  ${field(
                    'Reino',
                    `<select id="t-realm">${REALMS.map((r) => `<option value="${r.value}" ${draft.realm === r.value ? 'selected' : ''}>${r.label}</option>`).join('')}</select>`,
                  )}
                  ${field(
                    'Categoria',
                    `<select id="t-category">${categoriesForRealm(draft.realm || 'antigo-testamento').map((c) => `<option value="${c.value}" ${draft.category === c.value ? 'selected' : ''}>${escapeHtml(c.label)}</option>`).join('')}</select>`,
                  )}
                </div>
                ${field(
                  'Identificador da cena',
                  `<input id="f-slug" value="${escapeHtml(ms.slug || '')}" />`,
                  { hint: 'Liga as perguntas a esta cena. Evite mudar depois de cadastrar ações.' },
                )}
                ${field('Versículo base (estudo)', `<input id="st-ref" value="${escapeHtml(study.passageRef || '')}" placeholder="Ex.: Gênesis 1:1–2" />`)}
                ${field('Texto da passagem (estudo)', `<textarea id="st-text" rows="2">${escapeHtml(study.passageText || '')}</textarea>`)}
                ${field('Dica de leitura', `<input id="st-kw" value="${escapeHtml(study.keyword || '')}" placeholder="Ex.: Criar (bara)" />`)}
                <label class="ez-check">
                  <input id="t-soon" type="checkbox" ${draft.comingSoon ? 'checked' : ''}/>
                  <span>Rascunho (ainda não publicar no app)</span>
                </label>
                <button type="button" class="btn btn-ghost btn-sm btn-danger" data-del-step>Remover esta cena</button>
              </div>
            </details>

            <div class="simple-actions">
              <button type="button" class="btn btn-secondary" data-add-step>+ Próxima cena</button>
              <button type="button" class="btn btn-primary" data-save>Salvar trilha</button>
            </div>
          </div>

          <aside class="studio-preview-col">
            <div class="pv-tabs">
              <button type="button" class="${previewScreen === 'intro' ? 'on' : ''}" data-pv="intro">Entrada</button>
              <button type="button" class="${previewScreen === 'insight' ? 'on' : ''}" data-pv="insight">Hoje</button>
            </div>
            <div id="studio-preview"></div>
          </aside>
        </div>`}
      </div>`;

    bind();
    paintPreview();
  }

  async function save() {
    readForm();
    showMore = root.querySelector('details.simple-more:last-of-type')?.open ?? false;
    if (draft.modules?.[0]) {
      draft.modules[0].title = draft.modules[0].title || draft.title || 'Jornada';
    }
    setLoading(true);
    try {
      const clean = stripStudies(draft);
      const { id, updatedAt, ...payload } = clean;
      await saveDoc(COL.trails, trailId, { ...payload, slug: trailId, isActive: trail.isActive ?? true }, { bump: false });

      // Só o estudo que mudou: gravar todos marcaria a cena inteira como editada no painel.
      let changedStudies = 0;
      for (const mod of draft.modules || []) {
        for (const step of mod.missions || []) {
          if (!step.slug || !studyHasContent(step._study)) continue;
          const print = studyFingerprint(step._study);
          if (studyPrints.get(step.slug) === print) continue;
          const st = step._study;
          await saveDoc(COL.studies, step.slug, {
            slug: step.slug,
            ...Object.fromEntries(STUDY_V2_FIELDS.map((k) => [k, st[k] ?? (k === 'reflectionPrompts' || k === 'relatedVerses' ? [] : '')])),
          }, { bump: false });
          studyPrints.set(step.slug, print);
          changedStudies += 1;
        }
      }
      await bumpCatalogVersion();
      if (changedStudies) showToast(`${changedStudies} estudo(s) atualizado(s)`);

      dirty = false;
      showToast('Trilha salva');
      render();
    } catch (e) {
      showToast(e.message || 'Erro', 'error');
    } finally {
      setLoading(false);
    }
  }

  function nextStepSlug(n) {
    const used = new Set(flatSteps(draft).map((s) => s.ms.slug).filter(Boolean));
    let i = n;
    let slug = `passo-${i}`;
    while (used.has(slug)) {
      i += 1;
      slug = `passo-${i}`;
    }
    return slug;
  }

  function addStep() {
    readForm();
    showMore = root.querySelector('details.simple-more:last-of-type')?.open ?? false;
    if (!draft.modules.length) {
      draft.modules = [{ title: draft.title || 'Jornada', icon: '📘', missions: [] }];
    }
    const mi = Number.isFinite(focus.mi) ? focus.mi : 0;
    const mod = draft.modules[mi] || draft.modules[0];
    if (!mod.missions) mod.missions = [];
    const n = flatSteps(draft).length + 1;
    const step = emptyStep(n, `Cena ${n}`);
    step.slug = nextStepSlug(n);
    mod.missions.push({ ...step, _study: emptyStudy() });
    focus = { mi: draft.modules.indexOf(mod), qi: mod.missions.length - 1 };
    markDirty();
    showToast(`Cena ${n} criada`);
    render();
    requestAnimationFrame(() => {
      root.querySelector('.simple-step-chip.active')?.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
      root.querySelector('#f-title')?.focus();
    });
  }

  function openAct(existing, type) {
    readForm();
    const ms = current();
    if (!ms) {
      showToast('Não foi possível abrir o editor desta cena', 'error');
      return;
    }
    if (!ms.slug || String(ms.slug).startsWith('passo-')) {
      const s = slugify(ms.title);
      if (s) ms.slug = s;
    }
    if (!ms.slug) {
      ms.slug = nextStepSlug(stepIndex());
    }
    try {
      openQuestionStudio({
        existing,
        trails: [{ ...draft, id: trailId, slug: trailId }],
        items: bank,
        defaults: {
          type: type || existing?.type || 'choice',
          trail: trailId,
          section: ms.slug,
          lockPlace: true,
          difficulty: existing?.difficulty || 'semente',
        },
        onSaved: (payload) => {
          const i = bank.findIndex((x) => x.id === payload.id);
          if (i >= 0) bank[i] = { ...payload };
          else bank.push(payload);
          render();
        },
      });
    } catch (err) {
      console.error(err);
      showToast(err?.message || 'Erro ao abrir editor', 'error');
    }
  }

  function onRootClick(e) {
    const el = e.target.closest(
      '[data-add-step],[data-add-g],[data-route-bank],[data-edit-q],[data-del-q],[data-focus],[data-back],[data-save],[data-del-step],[data-pv]',
    );
    if (!el || !root.contains(el)) return;

    if (el.matches('[data-add-step]')) {
      e.preventDefault();
      addStep();
      return;
    }
    if (el.matches('[data-add-g]')) {
      e.preventDefault();
      openAct(null, el.dataset.addG);
      return;
    }
    if (el.matches('[data-route-bank]')) {
      e.preventDefault();
      history.replaceState(null, '', contentHash(trailId));
      navigate('content');
      return;
    }
    if (el.matches('[data-edit-q]')) {
      e.preventDefault();
      const q = bank.find((x) => x.id === el.dataset.editQ);
      if (q) openAct(q, q.type);
      return;
    }
    if (el.matches('[data-del-q]')) {
      e.preventDefault();
      e.stopPropagation();
      (async () => {
        if (!(await confirmAction(`Mover esta pergunta para a lixeira? Sai do app agora e fica ${TRASH_DAYS} dias para restaurar.`, { confirmLabel: 'Mover para a lixeira' }))) return;
        try {
          const gone = bank.find((x) => x.id === el.dataset.delQ);
          await removeDoc(COL.bank, el.dataset.delQ, { info: { trail: gone?.trail || trailId, section: gone?.section || '' } });
          bank = bank.filter((x) => x.id !== el.dataset.delQ);
          showToast('Movida para a lixeira');
          render();
        } catch (err) {
          showToast(err.message || 'Erro', 'error');
        }
      })();
      return;
    }
    if (el.matches('[data-focus]')) {
      e.preventDefault();
      readForm();
      showMore = root.querySelector('details.simple-more:last-of-type')?.open ?? false;
      const [mi, qi] = el.dataset.focus.split('-').map(Number);
      focus = { mi, qi };
      previewScreen = 'intro';
      previewFocus = 'title';
      render();
      return;
    }
    if (el.matches('[data-back]')) {
      e.preventDefault();
      history.replaceState(null, '', contentHash(trailId));
      navigate('content');
      return;
    }
    if (el.matches('[data-save]')) {
      e.preventDefault();
      save();
      return;
    }
    if (el.matches('[data-del-step]')) {
      e.preventDefault();
      (async () => {
        if (!(await confirmAction('Remover esta cena?'))) return;
        readForm();
        draft.modules[focus.mi].missions.splice(focus.qi, 1);
        if (!draft.modules[focus.mi].missions.length) {
          draft.modules[focus.mi].missions.push({ ...emptyStep(1), _study: emptyStudy() });
        }
        focus.qi = Math.min(focus.qi, draft.modules[focus.mi].missions.length - 1);
        markDirty();
        render();
      })();
      return;
    }
    if (el.matches('[data-pv]')) {
      e.preventDefault();
      previewScreen = el.dataset.pv;
      previewFocus = previewScreen === 'insight' ? 'insight' : 'title';
      root.querySelectorAll('[data-pv]').forEach((t) => t.classList.toggle('on', t.dataset.pv === previewScreen));
      paintPreview();
    }
  }

  if (root._trailEditorClick) {
    root.removeEventListener('click', root._trailEditorClick);
  }
  root._trailEditorClick = onRootClick;
  root.addEventListener('click', onRootClick);

  function readForm() {
    if (root.querySelector('#t-title')) {
      draft.title = root.querySelector('#t-title')?.value || draft.title;
      draft.description = root.querySelector('#t-desc')?.value || '';
      draft.icon = root.querySelector('#t-icon')?.value || draft.icon;
      const nextRealm = root.querySelector('#t-realm')?.value || draft.realm;
      draft.realm = nextRealm;
      let cat = root.querySelector('#t-category')?.value || draft.category;
      if (!categoriesForRealm(nextRealm).some((c) => c.value === cat)) cat = defaultCategory(nextRealm);
      draft.category = cat;
      draft.comingSoon = Boolean(root.querySelector('#t-soon')?.checked);
    }

    const ms = current();
    if (!ms || !root.querySelector('#f-title')) return;

    ms.title = root.querySelector('#f-title')?.value || ms.title;
    ms.intro = root.querySelector('#f-intro')?.value || '';
    ms.objective = root.querySelector('#f-objective')?.value || '';
    ms.centralInsight = root.querySelector('#f-insight')?.value || '';
    ms.echoQuestion = root.querySelector('#f-echo')?.value?.trim() || '';
    ms.hookRef = root.querySelector('#f-hook-ref')?.value || '';
    ms.hookVerse = root.querySelector('#f-hook-verse')?.value || '';
    ms.hookNote = root.querySelector('#f-hook-note')?.value || '';
    ms.hookThread = '';
    const slugEl = root.querySelector('#f-slug');
    if (slugEl) {
      const s = slugify(slugEl.value) || ms.slug;
      if (s) ms.slug = s;
    } else if (!ms.slug || String(ms.slug).startsWith('passo-')) {
      const s = slugify(ms.title);
      if (s) ms.slug = s;
    }
    const prev = ms._study || emptyStudy();
    ms._study = {
      ...prev,
      passageRef: root.querySelector('#st-ref')?.value || prev.passageRef,
      passageText: root.querySelector('#st-text')?.value || prev.passageText,
      keyword: root.querySelector('#st-kw')?.value || prev.keyword,
    };
  }

  function bind() {
    root.querySelectorAll('details.simple-more').forEach((det) => {
      det.addEventListener('toggle', (e) => {
        if (e.target === det) showMore = det.open;
      });
    });

    const hookRefInput = root.querySelector('#f-hook-ref');
    const vcPreview = root.querySelector('#vc-preview');
    if (hookRefInput) {
      attachVerseCopilot(hookRefInput, {
        previewEl: vcPreview,
        onPick: ({ ref, text }) => {
          const verseArea = root.querySelector('#f-hook-verse');
          if (verseArea && text) {
            const prev = verseArea.value;
            verseArea.value = text;
            verseArea.dispatchEvent(new Event('input', { bubbles: true }));
            markDirty();
            showToast('Texto preenchido', 'success', {
              action: 'Desfazer',
              onAction: () => {
                verseArea.value = prev;
                verseArea.dispatchEvent(new Event('input', { bubbles: true }));
                showToast('Desfeito');
              },
            });
          }
        },
      });
    }

    root.querySelectorAll(
      '#f-title, #f-intro, #f-objective, #f-insight, #f-echo, #f-hook-ref, #f-hook-verse, #f-hook-note, #f-slug, #st-ref, #st-text, #st-kw, #t-title, #t-desc, #t-icon, #t-realm, #t-category, #t-soon',
    ).forEach((el) => {
      const bump = () => {
        if (el.id === 't-realm') {
          readForm();
          showMore = true;
          render();
          return;
        }
        readForm();
        markDirty();
        if (el.dataset.preview) previewFocus = el.dataset.preview;
        if (el.dataset.screen) {
          previewScreen = el.dataset.screen;
          root.querySelectorAll('[data-pv]').forEach((t) => t.classList.toggle('on', t.dataset.pv === previewScreen));
        }
        paintPreview();
      };
      el.addEventListener('input', bump);
      el.addEventListener('change', bump);
      el.addEventListener('focus', bump);
    });
  }

  render();
  if (intent === 'cena') addStep();
}

export { categoryLabel, listPassos };
