import {
  collection,
  getDocs,
  orderBy,
  query,
  updateDoc,
  doc,
  Timestamp,
} from 'firebase/firestore';
import { db } from './firebase.js';
import { COL } from './db.js';
import { escapeHtml, showToast } from './ui.js';

const CATEGORY_LABELS = {
  theological: 'Erro teológico',
  interpretation: 'Interpretação',
  wrong_answer: 'Resposta errada',
  feedback: 'Feedback',
  typo: 'Ortografia',
  other: 'Outro',
};

const REALM_LABELS = {
  'antigo-testamento': 'Antigo Testamento',
  'novo-testamento': 'Novo Testamento',
  'vida-crista': 'Vida Cristã',
  teologia: 'Teologia',
  outros: 'Outros',
};

const STATUS_LABELS = {
  open: 'Aberto',
  reviewed: 'Revisado',
  fixed: 'Corrigido',
  dismissed: 'Descartado',
};

function formatDate(value) {
  if (!value) return '—';
  try {
    const d = value.toDate ? value.toDate() : new Date(value);
    return d.toLocaleString('pt-BR');
  } catch {
    return '—';
  }
}

async function loadOrdered(colId) {
  try {
    const q = query(collection(db, colId), orderBy('createdAt', 'desc'));
    const snap = await getDocs(q);
    return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
  } catch {
    const snap = await getDocs(collection(db, colId));
    const items = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    items.sort((a, b) => {
      const ta = a.createdAt?.toMillis?.() ?? 0;
      const tb = b.createdAt?.toMillis?.() ?? 0;
      return tb - ta;
    });
    return items;
  }
}

function statusButtons(id, status, attr) {
  if ((status || 'open') === 'open') {
    return `
      <button type="button" class="btn btn-sm btn-secondary" ${attr}="reviewed" data-id="${escapeHtml(id)}">Revisado</button>
      <button type="button" class="btn btn-sm btn-primary" ${attr}="fixed" data-id="${escapeHtml(id)}">Corrigido</button>
      <button type="button" class="btn btn-sm btn-ghost" ${attr}="dismissed" data-id="${escapeHtml(id)}">Descartar</button>
    `;
  }
  return `<button type="button" class="btn btn-sm btn-secondary" ${attr}="open" data-id="${escapeHtml(id)}">Reabrir</button>`;
}

export async function renderReportsPage(root) {
  root.innerHTML = `<div class="page-header"><h1>Relatos</h1></div><div class="card"><p>Carregando…</p></div>`;

  let items = [];
  let suggestions = [];
  try {
    [items, suggestions] = await Promise.all([
      loadOrdered(COL.reports),
      loadOrdered(COL.suggestions),
    ]);
  } catch (err) {
    root.innerHTML = `<div class="card"><p>Erro ao carregar relatos: ${escapeHtml(err.message || String(err))}</p></div>`;
    return;
  }

  let filterStatus = 'open';
  let filterCategory = '';
  let filterSuggestionStatus = 'open';

  async function setStatus(id, status) {
    try {
      await updateDoc(doc(db, COL.reports, id), {
        status,
        reviewedAt: Timestamp.now(),
      });
      const item = items.find((r) => r.id === id);
      if (item) item.status = status;
      showToast('Status atualizado', 'success');
      render();
    } catch (err) {
      showToast(err.message || 'Falha ao atualizar', 'error');
    }
  }

  async function setSuggestionStatus(id, status) {
    try {
      await updateDoc(doc(db, COL.suggestions, id), {
        status,
        reviewedAt: Timestamp.now(),
      });
      const item = suggestions.find((r) => r.id === id);
      if (item) item.status = status;
      showToast('Status atualizado', 'success');
      render();
    } catch (err) {
      showToast(err.message || 'Falha ao atualizar', 'error');
    }
  }

  function filtered() {
    return items.filter((r) => {
      if (filterStatus && (r.status || 'open') !== filterStatus) return false;
      if (filterCategory && r.category !== filterCategory) return false;
      return true;
    });
  }

  function filteredSuggestions() {
    return suggestions.filter((r) => {
      if (filterSuggestionStatus && (r.status || 'open') !== filterSuggestionStatus) {
        return false;
      }
      return true;
    });
  }

  function render() {
    const list = filtered();
    const suggestionList = filteredSuggestions();
    const openCount = items.filter((r) => (r.status || 'open') === 'open').length;
    const openSuggestions = suggestions.filter((r) => (r.status || 'open') === 'open').length;

    root.innerHTML = `
      <div class="page-header row-between">
        <div>
          <h1>Relatos e sugestões</h1>
          <p class="page-sub">Erros de perguntas e caminhos pedidos pelo mapa — ${openCount} relatos e ${openSuggestions} sugestões abertos</p>
        </div>
      </div>
      <div class="card filters-bar">
        <select id="f-status">
          <option value="">Todos status</option>
          ${Object.entries(STATUS_LABELS)
            .map(
              ([k, v]) =>
                `<option value="${k}" ${filterStatus === k ? 'selected' : ''}>${v}</option>`,
            )
            .join('')}
        </select>
        <select id="f-cat">
          <option value="">Todas categorias</option>
          ${Object.entries(CATEGORY_LABELS)
            .map(
              ([k, v]) =>
                `<option value="${k}" ${filterCategory === k ? 'selected' : ''}>${v}</option>`,
            )
            .join('')}
        </select>
      </div>
      <div class="card">
        <h2 style="margin:0 0 12px;font-size:1.05rem">Relatos de perguntas</h2>
        ${
          list.length === 0
            ? '<p class="field-hint">Nenhum relato neste filtro.</p>'
            : list
                .map((r) => {
                  const cat = CATEGORY_LABELS[r.category] || r.category || '—';
                  const status = STATUS_LABELS[r.status] || r.status || 'Aberto';
                  return `
            <article class="ez-panel" style="margin-bottom:12px">
              <div class="row-between" style="gap:12px;flex-wrap:wrap">
                <div>
                  <strong>${escapeHtml(cat)}</strong>
                  <span class="badge badge-muted" style="margin-left:8px">${escapeHtml(status)}</span>
                  <p class="field-hint" style="margin:6px 0 0">
                    ${escapeHtml(formatDate(r.createdAt))}
                    · <code>${escapeHtml(r.questionId || '')}</code>
                    ${r.missionSlug ? ` · ${escapeHtml(r.missionSlug)}` : ''}
                    ${r.difficulty ? ` · ${escapeHtml(r.difficulty)}` : ''}
                  </p>
                </div>
                <div class="td-actions">
                  ${statusButtons(r.id, r.status, 'data-status')}
                </div>
              </div>
              <p style="margin:10px 0 4px"><strong>Pergunta:</strong> ${escapeHtml(r.questionText || '—')}</p>
              ${r.verseRef ? `<p class="field-hint">Verso: ${escapeHtml(r.verseRef)}</p>` : ''}
              <p class="field-hint">
                Usuário ${r.userWasCorrect ? 'acertou' : 'errou'} ·
                escolheu “${escapeHtml(r.selectedOptionText || r.selectedOptionId || '—')}” ·
                certa: “${escapeHtml(r.correctOptionText || r.correctOptionId || '—')}”
              </p>
              ${
                r.comment
                  ? `<p style="margin-top:8px"><em>“${escapeHtml(r.comment)}”</em></p>`
                  : ''
              }
              <p class="field-hint" style="margin-top:8px">
                ${escapeHtml(r.displayName || r.email || r.uid || 'anônimo')}
              </p>
            </article>`;
                })
                .join('')
        }
      </div>
      <div class="card filters-bar" style="margin-top:18px">
        <select id="f-sug-status">
          <option value="">Todos status</option>
          ${Object.entries(STATUS_LABELS)
            .map(
              ([k, v]) =>
                `<option value="${k}" ${filterSuggestionStatus === k ? 'selected' : ''}>${v}</option>`,
            )
            .join('')}
        </select>
      </div>
      <div class="card">
        <h2 style="margin:0 0 12px;font-size:1.05rem">Sugestões de trilhas</h2>
        ${
          suggestionList.length === 0
            ? '<p class="field-hint">Nenhuma sugestão neste filtro.</p>'
            : suggestionList
                .map((s) => {
                  const status = STATUS_LABELS[s.status] || s.status || 'Aberto';
                  const realm = REALM_LABELS[s.realmId] || s.realmId || 'Sem reino';
                  return `
            <article class="ez-panel" style="margin-bottom:12px">
              <div class="row-between" style="gap:12px;flex-wrap:wrap">
                <div>
                  <strong>${escapeHtml(realm)}</strong>
                  <span class="badge badge-muted" style="margin-left:8px">${escapeHtml(status)}</span>
                  <p class="field-hint" style="margin:6px 0 0">
                    ${escapeHtml(formatDate(s.createdAt))}
                  </p>
                </div>
                <div class="td-actions">
                  ${statusButtons(s.id, s.status, 'data-sug-status')}
                </div>
              </div>
              <p style="margin:10px 0 4px">${escapeHtml(s.text || '—')}</p>
              <p class="field-hint" style="margin-top:8px">
                ${escapeHtml(s.displayName || s.email || s.uid || 'anônimo')}
              </p>
            </article>`;
                })
                .join('')
        }
      </div>`;

    document.getElementById('f-status')?.addEventListener('change', (e) => {
      filterStatus = e.target.value;
      render();
    });
    document.getElementById('f-cat')?.addEventListener('change', (e) => {
      filterCategory = e.target.value;
      render();
    });
    document.getElementById('f-sug-status')?.addEventListener('change', (e) => {
      filterSuggestionStatus = e.target.value;
      render();
    });
    root.querySelectorAll('[data-status]').forEach((btn) => {
      btn.addEventListener('click', () => setStatus(btn.dataset.id, btn.dataset.status));
    });
    root.querySelectorAll('[data-sug-status]').forEach((btn) => {
      btn.addEventListener('click', () =>
        setSuggestionStatus(btn.dataset.id, btn.dataset.sugStatus),
      );
    });
  }

  render();
}
