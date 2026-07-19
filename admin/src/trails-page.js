import {
  COL,
  batchSet,
  bumpCatalogVersion,
  listCollection,
  realmLabel,
  removeDoc,
  saveDoc,
} from './db.js';
import {
  bindModalDismiss,
  confirmAction,
  escapeHtml,
  setLoading,
  showModalElement,
  showToast,
} from './ui.js';

const REALMS = [
  { value: 'antigo-testamento', label: 'Antigo Testamento', icon: '📜' },
  { value: 'novo-testamento', label: 'Novo Testamento', icon: '✝️' },
  { value: 'vida-crista', label: 'Vida Cristã', icon: '🌱' },
  { value: 'teologia', label: 'Teologia', icon: '📖' },
];

const CATEGORIES = [
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
  return CATEGORIES.find((c) => c.value === value)?.label || value || '—';
}

function categoriesForRealm(realm) {
  return CATEGORIES.filter((c) => c.realm === realm);
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
  };
}

function emptyStep(n = 1, title = '') {
  return {
    slug: `passo-${n}`,
    title: title || `Passo ${n}`,
    subtitle: '',
    intro: '',
    type: 'lesson',
    xpReward: 50,
    questions: [],
  };
}

function emptyQuestion() {
  return {
    question: '',
    options: [
      { id: 'a', text: '' },
      { id: 'b', text: '' },
      { id: 'c', text: '' },
      { id: 'd', text: '' },
    ],
    correctOptionId: 'a',
    feedbackCorrect: '',
    feedbackWrong: { b: '', c: '', d: '' },
    verseRef: '',
  };
}

function field(label, control, hint = '') {
  return `<label class="ez-field"><span class="ez-label">${label}</span>${control}${
    hint ? `<span class="ez-hint">${hint}</span>` : ''
  }</label>`;
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

/* ─── Lista ─────────────────────────────────────────────── */

export async function renderTrailsList(root, navigate) {
  root.innerHTML = `<div class="ez-page"><div class="ez-skeleton">Carregando…</div></div>`;
  const trails = await listCollection(COL.trails);
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
      <div class="ez-page">
        <header class="ez-hero">
          <div>
            <h1>Trilhas</h1>
            <p class="ez-lead">Crie a trilha, escreva os passos, pronto.</p>
          </div>
          <button type="button" class="btn btn-primary" id="btn-new-trail">+ Nova trilha</button>
        </header>

        <div class="ez-toolbar">
          <input type="search" id="trail-search" class="ez-search" placeholder="Buscar…" value="${escapeHtml(queryText)}" />
          <div class="ez-pills">
            <button type="button" class="ez-pill ${filter === 'all' ? 'active' : ''}" data-filter="all">Todas (${trails.length})</button>
            <button type="button" class="ez-pill ${filter === 'live' ? 'active' : ''}" data-filter="live">No ar (${live})</button>
            <button type="button" class="ez-pill ${filter === 'soon' ? 'active' : ''}" data-filter="soon">Rascunho (${trails.length - live})</button>
          </div>
        </div>

        ${trails.length === 0
          ? `<div class="ez-empty">
              <h2>Nenhuma trilha</h2>
              <p>Comece pelo nome — o resto é passo a passo.</p>
              <button type="button" class="btn btn-primary" id="btn-empty-new">Criar trilha</button>
            </div>`
          : items.length === 0
            ? `<div class="ez-empty"><p>Nada neste filtro.</p></div>`
            : `<div class="ez-trail-grid">
                ${items.map((t) => `
                  <article class="ez-trail-card" data-open="${escapeHtml(t.id)}">
                    <div class="ez-trail-top">
                      <span class="ez-trail-icon">${escapeHtml(t.icon || '📖')}</span>
                      <span class="ez-status ${t.comingSoon ? 'soon' : 'live'}">${t.comingSoon ? 'Rascunho' : 'No ar'}</span>
                    </div>
                    <h2>${escapeHtml(t.title || t.id)}</h2>
                    <div class="ez-meta">
                      <span>${escapeHtml(realmLabel(t.realm))}</span>
                      <span>${stepCount(t)} passos</span>
                    </div>
                    <div class="ez-card-actions" onclick="event.stopPropagation()">
                      <button type="button" class="btn btn-primary btn-sm" data-edit="${escapeHtml(t.id)}">Editar</button>
                      <button type="button" class="btn btn-ghost btn-sm" data-del="${escapeHtml(t.id)}">Excluir</button>
                    </div>
                  </article>`).join('')}
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

/* ─── Criar: só o nome ──────────────────────────────────── */

function openCreateSimple(trails, navigate) {
  const modal = document.getElementById('modal');
  if (!modal) return;
  let realm = 'antigo-testamento';

  function paint() {
    modal.innerHTML = `
      <div class="modal-backdrop">
        <div class="modal-card card ez-modal" role="dialog" aria-modal="true">
          <button type="button" class="modal-close" aria-label="Fechar">×</button>
          <h2>Nova trilha</h2>
          <p class="ez-lead" style="margin-top:0">Só o nome. Depois você escreve os passos.</p>
          <form id="create-trail-form" class="ez-form">
            ${field('Nome', '<input name="title" required placeholder="Ex.: Gênesis 1–11" autofocus />')}
            <p class="ez-label" style="margin-bottom:0.5rem">Onde fica</p>
            <div class="simple-realm-row">
              ${REALMS.map((r) => `
                <button type="button" class="simple-realm ${realm === r.value ? 'active' : ''}" data-realm="${r.value}">
                  ${r.icon} ${escapeHtml(r.label)}
                </button>`).join('')}
            </div>
            <div class="btn-row" style="margin-top:var(--space-5)">
              <button type="button" class="btn btn-secondary" id="cancel">Cancelar</button>
              <button type="submit" class="btn btn-primary">Criar</button>
            </div>
          </form>
        </div>
      </div>`;

    showModalElement(modal);
    const close = bindModalDismiss(modal);
    modal.querySelector('#cancel')?.addEventListener('click', close);
    modal.querySelectorAll('[data-realm]').forEach((btn) => {
      btn.addEventListener('click', () => {
        realm = btn.dataset.realm;
        paint();
      });
    });
    modal.querySelector('#create-trail-form')?.addEventListener('submit', async (e) => {
      e.preventDefault();
      const title = String(new FormData(e.target).get('title') || '').trim();
      if (!title) return;
      let clean = slugify(title) || `trilha-${Date.now()}`;
      if (trails.some((t) => t.id === clean || t.slug === clean)) {
        clean = `${clean}-${trails.length + 1}`;
      }
      setLoading(true);
      try {
        await saveDoc(COL.trails, clean, {
          slug: clean,
          title,
          description: '',
          icon: '📖',
          order: trails.length + 1,
          unlockAfter: null,
          comingSoon: true,
          color: '#2F5D4A',
          realm,
          category: defaultCategory(realm),
          modules: [
            {
              title,
              icon: '📘',
              missions: [emptyStep(1, 'Primeiro passo')],
            },
          ],
          isActive: true,
        });
        close();
        showToast('Pronta — escreva o primeiro passo');
        navigate(`trail:${clean}`);
      } catch (err) {
        showToast(err.message || 'Erro', 'error');
      } finally {
        setLoading(false);
      }
    });
  }

  paint();
}

/* ─── Editor simples: trilha + passos ───────────────────── */

export async function renderTrailEditor(root, trailId, navigate) {
  root.innerHTML = `<div class="ez-page"><div class="ez-skeleton">Abrindo…</div></div>`;
  const [trails, studies] = await Promise.all([
    listCollection(COL.trails),
    listCollection(COL.studies),
  ]);
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
  let draft = ensureStructure(
    structuredClone({ ...trail, modules: trail.modules || [] }),
    studyMap,
  );
  let focus = { mi: 0, qi: 0 };
  let showMore = false;
  let dirty = false;

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

  function render() {
    const steps = flatSteps(draft);
    const ms = current();
    const idx = stepIndex();
    const study = ms?._study || emptyStudy();

    root.innerHTML = `
      <div class="ez-page simple-editor">
        <header class="simple-top">
          <button type="button" class="btn btn-ghost btn-sm" data-back>← Trilhas</button>
          <div class="simple-top-title">
            <strong>${escapeHtml(draft.title || trailId)}</strong>
            <span>${draft.comingSoon ? 'Rascunho' : 'No ar'} · ${steps.length} passos</span>
          </div>
          <button type="button" class="btn btn-primary" data-save>${dirty ? 'Salvar' : 'Salvo'}</button>
        </header>

        <p class="simple-guide">No app o usuário vê cada <strong>passo</strong> no caminho. Em cada um: um texto curto e as perguntas.</p>

        <div class="simple-steps">
          ${steps.map((s, i) => `
            <button type="button" class="simple-step-chip ${s.mi === focus.mi && s.qi === focus.qi ? 'active' : ''}" data-focus="${s.mi}-${s.qi}" title="${escapeHtml(s.ms.title || '')}">
              ${pad(i + 1)}
            </button>`).join('')}
          <button type="button" class="simple-step-chip add" data-add-step>+ Passo</button>
        </div>

        ${!ms
          ? `<div class="ez-empty"><p>Sem passos.</p><button type="button" class="btn btn-primary" data-add-step>Criar passo</button></div>`
          : `
          <section class="simple-card">
            <p class="simple-kicker">Passo ${pad(idx)}</p>
            ${field('Título', `<input id="f-title" value="${escapeHtml(ms.title || '')}" placeholder="Ex.: Quem criou o mundo?" />`)}
            ${field(
              'Descritivo',
              `<textarea id="f-intro" rows="2" placeholder="Uma ou duas frases para contextualizar…">${escapeHtml(ms.intro || '')}</textarea>`,
            )}
            ${field(
              'Versículo base',
              `<input id="st-ref" value="${escapeHtml(study.passageRef || '')}" placeholder="Ex.: Gênesis 1:1–2" />`,
            )}
            ${field(
              'Texto da passagem',
              `<textarea id="st-text" rows="2" placeholder="Cole o trecho (prévia)…">${escapeHtml(study.passageText || '')}</textarea>`,
            )}
            ${field(
              'Dica de leitura',
              `<input id="st-kw" value="${escapeHtml(study.keyword || '')}" placeholder="Ex.: Criar (bara) — o que observar ao ler" />`,
            )}
          </section>

          <section class="simple-card">
            <div class="row-between">
              <div>
                <h2>Perguntas</h2>
                <p class="ez-lead" style="margin:0">Enunciado + 4 opções. Marque a certa.</p>
              </div>
              <button type="button" class="btn btn-secondary btn-sm" data-add-q>+ Pergunta</button>
            </div>
            ${(ms.questions || []).length === 0
              ? `<div class="simple-empty-q"><p>Nenhuma ainda.</p><button type="button" class="btn btn-primary btn-sm" data-add-q>Adicionar</button></div>`
              : (ms.questions || []).map((q, qi2) => renderQ(q, qi2)).join('')}
          </section>

          <div class="simple-actions">
            <button type="button" class="btn btn-secondary" data-add-step>+ Próximo passo</button>
            <button type="button" class="btn btn-primary" data-save>Salvar</button>
          </div>`}

        <details class="simple-more" ${showMore ? 'open' : ''}>
          <summary>Mais opções</summary>
          <div class="simple-more-body">
            ${field('Nome da trilha', `<input id="t-title" value="${escapeHtml(draft.title || '')}" />`)}
            ${field('Descrição', `<textarea id="t-desc" rows="2">${escapeHtml(draft.description || '')}</textarea>`)}
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
            <label class="ez-check">
              <input id="t-soon" type="checkbox" ${draft.comingSoon ? 'checked' : ''}/>
              <span>Rascunho (ainda não publicar no app)</span>
            </label>
            ${ms ? `<button type="button" class="btn btn-ghost btn-sm btn-danger" data-del-step>Remover este passo</button>` : ''}
          </div>
        </details>
      </div>`;

    bind();
  }

  function renderQ(q, qi2) {
    const opts = q.options || [];
    return `
      <div class="simple-q">
        <div class="simple-q-head">
          <strong>Pergunta ${qi2 + 1}</strong>
          <button type="button" class="btn btn-ghost btn-sm" data-del-q="${qi2}">✕</button>
        </div>
        <textarea data-q-text="${qi2}" rows="2" placeholder="Enunciado">${escapeHtml(q.question || '')}</textarea>
        <div class="simple-opts">
          ${['a', 'b', 'c', 'd'].map((id) => {
            const opt = opts.find((o) => o.id === id) || { id, text: '' };
            const correct = q.correctOptionId === id;
            return `
              <label class="simple-opt ${correct ? 'correct' : ''}">
                <input type="radio" name="correct-${qi2}" value="${id}" ${correct ? 'checked' : ''} data-q-correct="${qi2}" />
                <span>${id.toUpperCase()}</span>
                <input type="text" data-q-opt="${qi2}-${id}" value="${escapeHtml(opt.text || '')}" placeholder="Opção ${id.toUpperCase()}" />
              </label>`;
          }).join('')}
        </div>
      </div>`;
  }

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
    if (!ms) return;

    if (root.querySelector('#f-title')) {
      ms.title = root.querySelector('#f-title')?.value || ms.title;
      ms.intro = root.querySelector('#f-intro')?.value || '';
      if (!ms.slug || String(ms.slug).startsWith('passo-')) {
        const s = slugify(ms.title);
        if (s) ms.slug = s;
      }
      const prev = ms._study || emptyStudy();
      ms._study = {
        ...prev,
        passageRef: root.querySelector('#st-ref')?.value || '',
        passageText: root.querySelector('#st-text')?.value || '',
        keyword: root.querySelector('#st-kw')?.value || '',
      };
    }

    if (!root.querySelector('[data-q-text]')) return;

    ms.questions = (ms.questions || []).map((q, qi2) => {
      if (!root.querySelector(`[data-q-text="${qi2}"]`)) return q;
      const correct = root.querySelector(`input[data-q-correct="${qi2}"]:checked`)?.value
        || root.querySelector(`[name="correct-${qi2}"]:checked`)?.value
        || 'a';
      const options = ['a', 'b', 'c', 'd'].map((id) => ({
        id,
        text: root.querySelector(`[data-q-opt="${qi2}-${id}"]`)?.value || '',
      }));
      const feedbackWrong = {};
      for (const id of ['a', 'b', 'c', 'd']) {
        if (id !== correct) feedbackWrong[id] = 'Resposta incorreta. Revise o texto.';
      }
      return {
        question: root.querySelector(`[data-q-text="${qi2}"]`)?.value || '',
        options,
        correctOptionId: correct,
        feedbackCorrect: q.feedbackCorrect || 'Muito bem!',
        feedbackWrong,
        verseRef: q.verseRef || '',
      };
    });
  }

  async function save() {
    readForm();
    showMore = Boolean(root.querySelector('.simple-more')?.open);
    // Mantém uma cena interna (o app usa); o editor não obriga o usuário a criá-la
    if (draft.modules?.[0]) {
      draft.modules[0].title = draft.modules[0].title || draft.title || 'Jornada';
    }
    setLoading(true);
    try {
      const clean = stripStudies(draft);
      const { id, updatedAt, ...payload } = clean;
      await saveDoc(COL.trails, trailId, { ...payload, slug: trailId, isActive: true });

      for (const mod of draft.modules || []) {
        for (const ms of mod.missions || []) {
          if (!ms.slug || !studyHasContent(ms._study)) continue;
          await saveDoc(COL.studies, ms.slug, {
            slug: ms.slug,
            passageRef: ms._study.passageRef || '',
            passageText: ms._study.passageText || '',
            context: ms._study.context || '',
            keyword: ms._study.keyword || '',
            keywordGloss: ms._study.keywordGloss || '',
            focusQuestion: ms._study.focusQuestion || '',
            reflectionPrompts: ms._study.reflectionPrompts || [],
          });
        }
      }

      dirty = false;
      showToast('Salvo');
      render();
    } catch (e) {
      showToast(e.message || 'Erro', 'error');
    } finally {
      setLoading(false);
    }
  }

  function bind() {
    root.querySelector('[data-back]')?.addEventListener('click', () => navigate('trails'));
    root.querySelectorAll('[data-save]').forEach((b) => b.addEventListener('click', save));

    root.querySelector('.simple-more')?.addEventListener('toggle', (e) => {
      showMore = e.target.open;
    });

    root.querySelectorAll('[data-focus]').forEach((btn) => {
      btn.addEventListener('click', () => {
        readForm();
        showMore = Boolean(root.querySelector('.simple-more')?.open);
        const [mi, qi] = btn.dataset.focus.split('-').map(Number);
        focus = { mi, qi };
        render();
      });
    });

    const addStep = () => {
      readForm();
      showMore = Boolean(root.querySelector('.simple-more')?.open);
      if (!draft.modules.length) {
        draft.modules = [{ title: draft.title || 'Jornada', icon: '📘', missions: [] }];
      }
      const mod = draft.modules[0];
      const n = flatSteps(draft).length + 1;
      mod.missions.push({ ...emptyStep(n), _study: emptyStudy() });
      focus = { mi: 0, qi: mod.missions.length - 1 };
      markDirty();
      render();
    };
    root.querySelectorAll('[data-add-step]').forEach((b) => b.addEventListener('click', addStep));

    root.querySelector('[data-del-step]')?.addEventListener('click', async () => {
      if (!(await confirmAction('Remover este passo?'))) return;
      readForm();
      draft.modules[focus.mi].missions.splice(focus.qi, 1);
      if (!draft.modules[focus.mi].missions.length) {
        draft.modules[focus.mi].missions.push({ ...emptyStep(1), _study: emptyStudy() });
      }
      focus.qi = Math.min(focus.qi, draft.modules[focus.mi].missions.length - 1);
      markDirty();
      render();
    });

    root.querySelectorAll('[data-add-q]').forEach((b) => {
      b.addEventListener('click', () => {
        readForm();
        showMore = Boolean(root.querySelector('.simple-more')?.open);
        const ms = current();
        ms.questions = ms.questions || [];
        ms.questions.push(emptyQuestion());
        markDirty();
        render();
      });
    });

    root.querySelectorAll('[data-del-q]').forEach((b) => {
      b.addEventListener('click', () => {
        readForm();
        showMore = Boolean(root.querySelector('.simple-more')?.open);
        current().questions.splice(Number(b.dataset.delQ), 1);
        markDirty();
        render();
      });
    });

    root.querySelectorAll(
      '#f-title, #f-intro, #st-ref, #st-text, #st-kw, #t-title, #t-desc, #t-icon, #t-realm, #t-category, #t-soon, textarea[data-q-text], input[data-q-opt], input[data-q-correct], input[type="radio"]',
    ).forEach((el) => {
      el.addEventListener('input', markDirty);
      el.addEventListener('change', () => {
        if (el.id === 't-realm') {
          readForm();
          showMore = true;
          render();
          return;
        }
        markDirty();
      });
    });
  }

  render();
}

export { batchSet, bumpCatalogVersion, categoryLabel };
