import { COL, listCollection, removeDoc } from './db.js';
import {
  DIFFS,
  GESTURES,
  gestureMeta,
  listPassos,
  openQuestionStudio,
} from './question-studio.js';
import {
  bindModalDismiss,
  confirmAction,
  escapeHtml,
  showModalElement,
  showToast,
} from './ui.js';

function promptOf(q) {
  return (q.cue || q.prompt || q.question || '').trim();
}

function trailTitle(trails, id) {
  const t = (trails || []).find((x) => x.id === id || x.slug === id);
  return t?.title || id || '—';
}

function cleanVerse(text) {
  return String(text || '').replace(/\s+/g, ' ').trim();
}

function openQuickAdd(trails, items, onSaved) {
  const modal = document.getElementById('modal');
  if (!modal) return;
  const passos = listPassos(trails);
  let selected = '';
  let type = 'choice';
  let query = '';
  let closeModal = null;

  function filteredPassos() {
    const q = query.trim().toLowerCase();
    if (!q) return passos;
    return passos.filter((p) =>
      `${p.trailTitle} ${p.title} ${p.section} ${p.hookRef || ''}`.toLowerCase().includes(q),
    );
  }

  function selectedPasso() {
    if (!selected) return null;
    const [trail, section] = selected.split('::');
    return passos.find((p) => p.trail === trail && p.section === section) || null;
  }

  function goNext() {
    if (!selected) {
      showToast('Escolha o passo', 'error');
      return;
    }
    const [trail, section] = selected.split('::');
    closeModal?.();
    openQuestionStudio({
      existing: null,
      trails,
      items,
      defaults: { trail, section, type, lockPlace: true, difficulty: 'semente' },
      onSaved,
    });
  }

  function paint() {
    const list = filteredPassos();
    const sel = selectedPasso();
    const grouped = {};
    for (const p of list) {
      if (!grouped[p.trailTitle]) grouped[p.trailTitle] = [];
      grouped[p.trailTitle].push(p);
    }
    const hasVerse = Boolean(sel?.hookRef || sel?.hookVerse);
    const verseText = cleanVerse(sel?.hookVerse || '');

    modal.innerHTML = `
      <div class="modal-backdrop qa-backdrop">
        <div class="modal-card card quick-add-modal" role="dialog" aria-modal="true">
          <header class="qa-head">
            <div>
              <p class="simple-kicker">Nova pergunta</p>
              <h2>Cadastro rápido</h2>
              <p class="ez-lead">Passo → tipo → escreva ou gere do verso.</p>
            </div>
            <button type="button" class="modal-close" aria-label="Fechar">×</button>
          </header>

          <div class="qa-body">
            <section class="qa-section">
              <p class="qa-step"><em>1</em> Onde entra</p>
              <input
                type="search"
                id="qa-search"
                class="ez-search"
                placeholder="Buscar trilha ou passo…"
                value="${escapeHtml(query)}"
                autocomplete="off"
              />
              <div class="qa-passo-list" role="listbox" aria-label="Passos">
                ${list.length === 0
                  ? `<p class="qa-empty">Nenhum passo encontrado.</p>`
                  : Object.entries(grouped).map(([trailName, steps]) => `
                    <div class="qa-trail-group">
                      <p class="qa-trail-name">${escapeHtml(trailName)}</p>
                      ${steps.map((p) => {
                        const val = `${p.trail}::${p.section}`;
                        const on = selected === val;
                        return `
                          <button type="button" class="qa-passo-item ${on ? 'on' : ''}" data-qa-place="${escapeHtml(val)}" role="option" aria-selected="${on}">
                            <strong>${escapeHtml(p.title)}</strong>
                            <span>${escapeHtml(p.hookRef || 'Sem verso ainda')}</span>
                          </button>`;
                      }).join('')}
                    </div>`).join('')}
              </div>
              ${sel
                ? `<div class="qa-verse-preview ${verseText ? '' : 'empty'}">
                    <p class="qs-verse-ref">${escapeHtml(sel.hookRef || 'Passo sem referência')}</p>
                    ${verseText
                      ? `<blockquote class="qs-verse-text">${escapeHtml(verseText)}</blockquote>`
                      : `<p class="ez-hint">Este passo ainda não tem texto bíblico — você pode preencher manualmente na próxima tela.</p>`}
                  </div>`
                : `<p class="qa-hint">Selecione o passo onde a pergunta aparece no app.</p>`}
            </section>

            <section class="qa-section">
              <p class="qa-step"><em>2</em> Tipo de pergunta</p>
              <div class="gesture-row all-types">
                ${GESTURES.map((g) => `
                  <button type="button" class="gesture-chip ${type === g.id ? 'on' : ''}" data-qa-type="${g.id}" title="${escapeHtml(g.blurb)}">
                    <span class="gesture-icon">${escapeHtml(g.icon || '•')}</span>
                    <strong>${escapeHtml(g.label)}</strong>
                    <small>${escapeHtml(g.verb)}</small>
                  </button>`).join('')}
              </div>
            </section>
          </div>

          <div class="btn-row qa-foot">
            <button type="button" class="btn btn-secondary" id="cancel">Cancelar</button>
            <button type="button" class="btn btn-primary" id="qa-go" ${selected ? '' : 'disabled'}>
              Continuar →
            </button>
          </div>
        </div>
      </div>`;

    showModalElement(modal);
    closeModal = bindModalDismiss(modal);
    modal.querySelector('#cancel')?.addEventListener('click', closeModal);
    modal.querySelector('.modal-close')?.addEventListener('click', closeModal);

    const searchEl = modal.querySelector('#qa-search');
    searchEl?.addEventListener('input', (e) => {
      query = e.target.value;
      paint();
      modal.querySelector('#qa-search')?.focus();
      const el = modal.querySelector('#qa-search');
      el?.setSelectionRange(el.value.length, el.value.length);
    });

    modal.querySelectorAll('[data-qa-place]').forEach((btn) => {
      btn.addEventListener('click', () => {
        selected = btn.dataset.qaPlace;
        paint();
      });
    });

    modal.querySelectorAll('[data-qa-type]').forEach((btn) => {
      btn.addEventListener('click', () => {
        type = btn.dataset.qaType;
        modal.querySelectorAll('[data-qa-type]').forEach((b) => {
          b.classList.toggle('on', b.dataset.qaType === type);
        });
      });
    });

    modal.querySelector('#qa-go')?.addEventListener('click', goNext);

    searchEl?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && selected) goNext();
    });
  }

  paint();
}

export async function renderBankPage(root, navigate) {
  root.innerHTML = `<div class="ez-page"><div class="ez-skeleton">Carregando…</div></div>`;
  let [items, trails] = await Promise.all([
    listCollection(COL.bank),
    listCollection(COL.trails),
  ]);
  let filterDiff = '';
  let filterType = '';
  let filterTrail = '';
  let search = '';

  function filtered() {
    return items.filter((q) => {
      if (filterDiff && q.difficulty !== filterDiff) return false;
      if (filterType && q.type !== filterType) return false;
      if (filterTrail && q.trail !== filterTrail && q.trailSlug !== filterTrail) return false;
      if (search) {
        const hay = `${q.id} ${promptOf(q)} ${q.section || ''}`.toLowerCase();
        if (!hay.includes(search.toLowerCase())) return false;
      }
      return true;
    });
  }

  function onSaved(payload) {
    const idx = items.findIndex((x) => x.id === payload.id);
    if (idx >= 0) items[idx] = { ...items[idx], ...payload };
    else items.push(payload);
    render();
  }

  function openEditor(existing) {
    openQuestionStudio({
      existing,
      trails,
      items,
      defaults: existing
        ? {}
        : {
            trail: filterTrail || trails[0]?.slug || trails[0]?.id || '',
            section: '',
            type: filterType || 'choice',
            difficulty: filterDiff || 'semente',
          },
      onSaved,
    });
  }

  function render() {
    const list = filtered();
    const trailIds = [...new Set(items.map((q) => q.trail || q.trailSlug).filter(Boolean))].sort();
    for (const t of trails) {
      const id = t.slug || t.id;
      if (id && !trailIds.includes(id)) trailIds.push(id);
    }

    root.innerHTML = `
      <div class="ez-page wide">
        <header class="ez-hero">
          <div>
            <h1>Perguntas</h1>
            <p class="ez-lead">Quiz, V/F e complete — cada uma vira uma tela no treino. ${items.length} cadastradas.</p>
          </div>
          <div class="ez-hero-actions">
            <button type="button" class="btn btn-primary" id="btn-new-q">+ Nova pergunta</button>
          </div>
        </header>

        <div class="ez-quick-banner">
          <div class="ez-quick-banner-text">
            <strong>Cadastro em 2 passos</strong>
            <span>Escolha o passo → tipo → escreva ou gere do verso</span>
          </div>
          <button type="button" class="btn btn-secondary btn-sm" id="btn-quick-add">Começar agora</button>
        </div>

        <div class="ez-toolbar wrap">
          <input type="search" id="f-search" class="ez-search" placeholder="Buscar texto ou passo…" value="${escapeHtml(search)}" />
          <select id="f-trail" class="ez-select">
            <option value="">Todas as trilhas</option>
            ${trailIds.map((id) => `<option value="${escapeHtml(id)}" ${filterTrail === id ? 'selected' : ''}>${escapeHtml(trailTitle(trails, id))}</option>`).join('')}
          </select>
          <select id="f-diff" class="ez-select">
            <option value="">Todas as dificuldades</option>
            ${DIFFS.map((d) => `<option value="${d.id}" ${filterDiff === d.id ? 'selected' : ''}>${escapeHtml(d.label)}</option>`).join('')}
          </select>
        </div>
        <div class="ez-pills" style="margin-bottom:var(--space-5)">
          <button type="button" class="ez-pill ${!filterType ? 'active' : ''}" data-type="">Todas</button>
          ${GESTURES.map((g) => `
            <button type="button" class="ez-pill ${filterType === g.id ? 'active' : ''}" data-type="${g.id}">${escapeHtml(g.label)}</button>
          `).join('')}
        </div>

        ${list.length === 0
          ? `<div class="ez-empty">
              <div class="ez-empty-icon">❓</div>
              <h2>${items.length === 0 ? 'Nenhuma pergunta ainda' : 'Nada neste filtro'}</h2>
              <p>${items.length === 0 ? 'O caminho mais fácil: abra uma trilha, preencha o verso do passo e toque em “Gerar do verso”.' : 'Tente outro filtro ou limpe a busca.'}</p>
              ${items.length === 0
                ? `<div class="ez-empty-actions">
                    <button type="button" class="btn btn-primary" id="btn-empty-q">+ Nova pergunta</button>
                    <button type="button" class="btn btn-secondary" data-route="trails">Ir para trilhas</button>
                  </div>`
                : ''}
            </div>`
          : `<div class="q-card-list">
              ${list.slice(0, 200).map((q) => {
                const g = gestureMeta(q.type);
                return `
                <article class="q-card">
                  <div class="q-card-top">
                    <span class="act-type">${escapeHtml(g.icon || '')} ${escapeHtml(g.label)}</span>
                    <span class="act-diff">${escapeHtml(q.difficulty || '')}</span>
                  </div>
                  <p class="q-card-stem">${escapeHtml(promptOf(q) || q.template || '(sem texto)')}</p>
                  <div class="ez-meta">
                    <span>${escapeHtml(trailTitle(trails, q.trail || q.trailSlug))}</span>
                    <span>${escapeHtml(q.section || '—')}</span>
                  </div>
                  <div class="ez-card-actions">
                    <button type="button" class="btn btn-primary btn-sm" data-edit="${escapeHtml(q.id)}">Editar</button>
                    <button type="button" class="btn btn-ghost btn-sm" data-del="${escapeHtml(q.id)}">Excluir</button>
                  </div>
                </article>`;
              }).join('')}
            </div>
            ${list.length > 200 ? `<p class="ez-hint" style="margin-top:var(--space-4)">Mostrando 200 de ${list.length}. Refine a busca.</p>` : ''}`}
      </div>`;

    root.querySelector('#f-search')?.addEventListener('input', (e) => {
      search = e.target.value;
      render();
      const el = root.querySelector('#f-search');
      el?.focus();
      el?.setSelectionRange(el.value.length, el.value.length);
    });
    root.querySelector('#f-diff')?.addEventListener('change', (e) => {
      filterDiff = e.target.value;
      render();
    });
    root.querySelector('#f-trail')?.addEventListener('change', (e) => {
      filterTrail = e.target.value;
      render();
    });
    root.querySelectorAll('[data-type]').forEach((btn) => {
      btn.addEventListener('click', () => {
        filterType = btn.dataset.type;
        render();
      });
    });

    const quick = () => openQuickAdd(trails, items, onSaved);
    root.querySelector('#btn-new-q')?.addEventListener('click', quick);
    root.querySelector('#btn-quick-add')?.addEventListener('click', quick);
    root.querySelector('#btn-empty-q')?.addEventListener('click', quick);
    root.querySelectorAll('[data-edit]').forEach((btn) => {
      btn.addEventListener('click', () => {
        const q = items.find((x) => x.id === btn.dataset.edit);
        openEditor(q);
      });
    });
    root.querySelectorAll('[data-del]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        if (!(await confirmAction('Excluir esta pergunta?'))) return;
        await removeDoc(COL.bank, btn.dataset.del);
        items = items.filter((x) => x.id !== btn.dataset.del);
        showToast('Removida');
        render();
      });
    });
    root.querySelectorAll('[data-route]').forEach((a) => {
      a.addEventListener('click', (e) => {
        e.preventDefault();
        navigate?.(a.dataset.route);
      });
    });
  }

  render();
}
