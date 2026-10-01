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

const USER_REASON_LABELS = {
  offensive_name: 'Nome ofensivo',
  offensive_photo: 'Foto imprópria',
  harassment: 'Assédio ou ameaça',
  spam: 'Spam ou golpe',
  other: 'Outro',
};

const USER_SOURCE_LABELS = {
  ranking: 'Ranking',
  recognition: 'Reconhecimento',
  room_invite: 'Convite de grupo',
  room: 'Grupo',
  corner: 'Desafio',
  companion: 'Companhia',
};

const USER_STATUS_LABELS = {
  open: 'Aberta',
  actioned: 'Ação tomada',
  dismissed: 'Descartada',
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

function userReportButtons(id, status) {
  if ((status || 'open') === 'open') {
    return `
      <button type="button" class="btn btn-sm btn-primary" data-user-status="actioned" data-id="${escapeHtml(id)}">Ação tomada</button>
      <button type="button" class="btn btn-sm btn-ghost" data-user-status="dismissed" data-id="${escapeHtml(id)}">Descartar</button>
    `;
  }
  return `<button type="button" class="btn btn-sm btn-secondary" data-user-status="open" data-id="${escapeHtml(id)}">Reabrir</button>`;
}

/** Horas desde a denúncia — a App Store pede resposta em até 24h. */
function hoursSince(value) {
  const ms = value?.toMillis?.();
  if (!ms) return null;
  return Math.floor((Date.now() - ms) / 3_600_000);
}

export async function renderReportsPage(root) {
  root.innerHTML = `<div class="page-header"><h1>Relatos</h1></div><div class="card"><p>Carregando…</p></div>`;

  let items = [];
  let suggestions = [];
  let authors = [];
  let userReports = [];
  try {
    [items, suggestions, authors, userReports] = await Promise.all([
      loadOrdered(COL.reports),
      loadOrdered(COL.suggestions),
      loadOrdered(COL.authorSuggestions),
      loadOrdered(COL.userReports),
    ]);
  } catch (err) {
    root.innerHTML = `<div class="card"><p>Erro ao carregar relatos: ${escapeHtml(err.message || String(err))}</p></div>`;
    return;
  }

  let filterStatus = 'open';
  let filterCategory = '';
  let filterSuggestionStatus = 'open';
  let filterAuthorStatus = 'open';
  let filterUserStatus = 'open';

  async function setUserReportStatus(id, status) {
    try {
      await updateDoc(doc(db, COL.userReports, id), {
        status,
        reviewedAt: Timestamp.now(),
      });
      const item = userReports.find((r) => r.id === id);
      if (item) item.status = status;
      showToast('Status atualizado', 'success');
      render();
    } catch (err) {
      showToast(err.message || 'Falha ao atualizar', 'error');
    }
  }

  function filteredUserReports() {
    return userReports.filter(
      (r) => !filterUserStatus || (r.status || 'open') === filterUserStatus,
    );
  }

  function userReportsHtml() {
    const list = filteredUserReports();
    if (list.length === 0) {
      return '<p class="field-hint">Nenhuma denúncia neste filtro.</p>';
    }
    return list
      .map((r) => {
        const reason = USER_REASON_LABELS[r.reason] || r.reason || '—';
        const source = USER_SOURCE_LABELS[r.source] || r.source || '—';
        const status = USER_STATUS_LABELS[r.status] || r.status || 'Aberta';
        const hours = hoursSince(r.createdAt);
        const late = (r.status || 'open') === 'open' && hours !== null && hours >= 24;
        return `
            <article class="ez-panel" style="margin-bottom:12px">
              <div class="row-between" style="gap:12px;flex-wrap:wrap">
                <div>
                  <strong>${escapeHtml(r.targetName || '—')}</strong>
                  <span class="badge badge-muted" style="margin-left:8px">${escapeHtml(reason)}</span>
                  <span class="badge badge-muted" style="margin-left:4px">${escapeHtml(status)}</span>
                  ${late ? '<span class="badge" style="margin-left:4px">+24h</span>' : ''}
                  <p class="field-hint" style="margin:6px 0 0">
                    ${escapeHtml(formatDate(r.createdAt))} · ${escapeHtml(source)}
                    · alvo <code>${escapeHtml(r.targetUid || '')}</code>
                    ${r.roomName ? ` · grupo “${escapeHtml(r.roomName)}” (${escapeHtml(r.roomCode || '')})` : ''}
                  </p>
                </div>
                <div class="td-actions">
                  ${userReportButtons(r.id, r.status)}
                </div>
              </div>
              ${r.comment ? `<p style="margin-top:8px"><em>“${escapeHtml(r.comment)}”</em></p>` : ''}
              <p class="field-hint" style="margin-top:8px">
                Denunciado por <code>${escapeHtml(r.reporterUid || 'conta excluída')}</code>
              </p>
            </article>`;
      })
      .join('');
  }

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

  function filteredAuthors() {
    return authors.filter((r) => {
      if (filterAuthorStatus && (r.status || 'open') !== filterAuthorStatus) {
        return false;
      }
      return true;
    });
  }

  async function setAuthorStatus(id, status) {
    try {
      await updateDoc(doc(db, COL.authorSuggestions, id), {
        status,
        reviewedAt: Timestamp.now(),
      });
      const item = authors.find((r) => r.id === id);
      if (item) item.status = status;
      showToast('Status atualizado', 'success');
      render();
    } catch (err) {
      showToast(err.message || 'Falha ao atualizar', 'error');
    }
  }

  function render() {
    const list = filtered();
    const suggestionList = filteredSuggestions();
    const authorList = filteredAuthors();
    const openCount = items.filter((r) => (r.status || 'open') === 'open').length;
    const openSuggestions = suggestions.filter((r) => (r.status || 'open') === 'open').length;
    const openAuthors = authors.filter((r) => (r.status || 'open') === 'open').length;
    const openUserReports = userReports.filter((r) => (r.status || 'open') === 'open').length;

    root.innerHTML = `
      <div class="page-header row-between">
        <div>
          <h1>Relatos e sugestões</h1>
          <p class="page-sub">Denúncias, erros de perguntas e caminhos pedidos pelo mapa — ${openUserReports} denúncias, ${openCount} relatos, ${openSuggestions} trilhas e ${openAuthors} autores abertos</p>
        </div>
      </div>
      <div class="card filters-bar">
        <select id="f-user-status">
          <option value="">Todos status</option>
          ${Object.entries(USER_STATUS_LABELS)
            .map(
              ([k, v]) =>
                `<option value="${k}" ${filterUserStatus === k ? 'selected' : ''}>${v}</option>`,
            )
            .join('')}
        </select>
      </div>
      <div class="card">
        <h2 style="margin:0 0 4px;font-size:1.05rem">Denúncias de pessoas · ${openUserReports} abertas</h2>
        <p class="field-hint" style="margin:0 0 12px">
          Responder em até 24h. Para agir: corrigir nome/foto em <code>users/{uid}</code>
          e nos placares, ou desativar a conta no Firebase Auth.
        </p>
        ${userReportsHtml()}
      </div>
      <div class="card filters-bar" style="margin-top:18px">
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
      </div>
      <div class="card filters-bar" style="margin-top:18px">
        <select id="f-author-status">
          <option value="">Todos status</option>
          ${Object.entries(STATUS_LABELS)
            .map(
              ([k, v]) =>
                `<option value="${k}" ${filterAuthorStatus === k ? 'selected' : ''}>${v}</option>`,
            )
            .join('')}
        </select>
      </div>
      <div class="card">
        <h2 style="margin:0 0 12px;font-size:1.05rem">Sugestões de autores</h2>
        ${
          authorList.length === 0
            ? '<p class="field-hint">Nenhum autor neste filtro.</p>'
            : authorList
                .map((s) => {
                  const status = STATUS_LABELS[s.status] || s.status || 'Aberto';
                  const contact = [
                    s.phone ? `Tel. ${s.phone}` : '',
                    s.email || '',
                    s.instagram ? `@${s.instagram}` : '',
                  ]
                    .filter(Boolean)
                    .join(' · ');
                  return `
            <article class="ez-panel" style="margin-bottom:12px">
              <div class="row-between" style="gap:12px;flex-wrap:wrap">
                <div>
                  <strong>${escapeHtml(s.name || '—')}</strong>
                  <span class="badge badge-muted" style="margin-left:8px">${escapeHtml(status)}</span>
                  <p class="field-hint" style="margin:6px 0 0">
                    ${escapeHtml(formatDate(s.createdAt))}
                  </p>
                </div>
                <div class="td-actions">
                  ${statusButtons(s.id, s.status, 'data-author-status')}
                </div>
              </div>
              <p style="margin:10px 0 4px">${escapeHtml(contact || '—')}</p>
              <p class="field-hint" style="margin-top:8px">
                Indicado por ${escapeHtml(s.submitterName || s.submitterEmail || s.uid || 'anônimo')}
              </p>
            </article>`;
                })
                .join('')
        }
      </div>`;

    document.getElementById('f-user-status')?.addEventListener('change', (e) => {
      filterUserStatus = e.target.value;
      render();
    });
    root.querySelectorAll('[data-user-status]').forEach((btn) => {
      btn.addEventListener('click', () =>
        setUserReportStatus(btn.dataset.id, btn.dataset.userStatus),
      );
    });
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
    document.getElementById('f-author-status')?.addEventListener('change', (e) => {
      filterAuthorStatus = e.target.value;
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
    root.querySelectorAll('[data-author-status]').forEach((btn) => {
      btn.addEventListener('click', () =>
        setAuthorStatus(btn.dataset.id, btn.dataset.authorStatus),
      );
    });
  }

  render();
}
