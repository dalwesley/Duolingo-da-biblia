/**
 * Relatos: o que as pessoas mandam pelo app, uma fila por aba.
 *
 *   Denúncias           user_reports               (pessoa denunciando pessoa)
 *   Problemas do app    app_reports
 *   Erros em perguntas  content_question_reports
 *   Sugestões de trilha trail_suggestions          (pedidos do mapa)
 *   Autores             author_suggestions
 *
 * Toda fila tem o mesmo card: etiquetas + ações no topo, fatos em lista.
 * Mudar o status só muda aqui — ninguém é avisado.
 */
import { collection, getDocs, orderBy, query, updateDoc, doc, Timestamp } from 'firebase/firestore';
import { db } from './firebase.js';
import { COL, getDocById } from './db.js';
import { DIFFS } from './content-preview.js';
import { openQuestionStudio } from './question-studio.js';
import { openPersonModal } from './person-modal.js';
import { escapeHtml, showToast } from './ui.js';

const FIREBASE_PROJECT = import.meta.env.VITE_FIREBASE_PROJECT_ID || 'trilha-biblia';

const STATUS = {
  open: 'Aberto',
  reviewed: 'Revisado',
  fixed: 'Corrigido',
  dismissed: 'Descartado',
};

const PEOPLE_STATUS = {
  open: 'Aberta',
  actioned: 'Já agi',
  dismissed: 'Sem fundamento',
};

const QUESTION_CATEGORY = {
  theological: 'Erro teológico',
  interpretation: 'Interpretação',
  wrong_answer: 'Resposta errada',
  feedback: 'Feedback',
  typo: 'Ortografia',
  other: 'Outro',
};

const APP_CATEGORY = {
  bug: 'Algo não funciona',
  account: 'Conta e progresso',
  subscription: 'Assinatura e compras',
  suggestion: 'Sugestão',
  other: 'Outro',
};

const PEOPLE_REASON = {
  offensive_name: 'Nome ofensivo',
  offensive_photo: 'Foto imprópria',
  harassment: 'Assédio ou ameaça',
  spam: 'Spam ou golpe',
  other: 'Outro',
};

const PEOPLE_SOURCE = {
  ranking: 'Ranking',
  recognition: 'Reconhecimento',
  room_invite: 'Convite de grupo',
  room: 'Grupo',
  corner: 'Desafio',
  companion: 'Companhia',
};

const REALM = {
  'antigo-testamento': 'Antigo Testamento',
  'novo-testamento': 'Novo Testamento',
  'vida-crista': 'Vida Cristã',
  teologia: 'Teologia',
  outros: 'Outros',
};

/* ─── Pequenos formatos ──────────────────────────────────── */

function formatDate(value) {
  if (!value) return '—';
  try {
    const d = value.toDate ? value.toDate() : new Date(value);
    return d.toLocaleString('pt-BR');
  } catch {
    return '—';
  }
}

function hoursSince(value) {
  const ms = value?.toMillis?.();
  if (!ms) return null;
  return Math.floor((Date.now() - ms) / 3_600_000);
}

/** "há 3 h", "há 5 dias". */
function ago(hours) {
  if (hours === null) return '';
  if (hours < 1) return 'agora há pouco';
  if (hours < 48) return `há ${hours} h`;
  return `há ${Math.floor(hours / 24)} dias`;
}

function when(r) {
  const h = hoursSince(r.createdAt);
  return `${escapeHtml(formatDate(r.createdAt))}${h !== null ? ` <span class="field-hint">· ${escapeHtml(ago(h))}</span>` : ''}`;
}

/** uid inteiro à vista (separa contas com o mesmo nome); toque copia. */
function copyChip(uid) {
  if (!uid) return '';
  return `<button type="button" class="rp-uid" data-copy="${escapeHtml(uid)}" title="Copiar uid (cole em Suporte)"><code>${escapeHtml(uid)}</code><span aria-hidden="true">⧉</span></button>`;
}

function quote(text) {
  return text ? `<em>“${escapeHtml(text)}”</em>` : '<span class="field-hint">sem comentário</span>';
}

/** Nome (abre a ficha da pessoa) + uid copiável. */
function person(name, uid, extra = '', reportId = '') {
  const label = name ? escapeHtml(name) : '(sem nome)';
  const who = uid
    ? `<button type="button" class="rp-person" data-person="${escapeHtml(uid)}" data-person-name="${escapeHtml(name || '')}" ${reportId ? `data-report="${escapeHtml(reportId)}"` : ''} title="Abrir ficha">${label}</button>`
    : '<span class="field-hint">conta excluída</span>';
  return `${who}${extra ? ` <span class="field-hint">· ${escapeHtml(extra)}</span>` : ''} ${copyChip(uid)}`;
}

const isOpen = (r) => (r.status || 'open') === 'open';

/* ─── Filas ──────────────────────────────────────────────── */

const DEFAULT_ACTIONS = [
  ['reviewed', 'Revisado', 'btn-secondary', 'Vi e anotei'],
  ['fixed', 'Corrigido', 'btn-primary', 'Resolvido'],
  ['dismissed', 'Descartar', 'btn-ghost', 'Não procede'],
];

const TABS = [
  {
    id: 'people',
    label: 'Denúncias',
    col: COL.userReports,
    statuses: PEOPLE_STATUS,
    actions: [
      ['actioned', 'Já agi', 'btn-primary', 'Use depois de trocar o nome/foto ou desativar a conta'],
      ['dismissed', 'Sem fundamento', 'btn-ghost', 'A denúncia não procede: nada a fazer'],
    ],
    help: () => `
      <details class="rp-howto">
        <summary>O que fazer com uma denúncia (agir em até 24h)</summary>
        <ol>
          <li>Olhe nome/foto da <strong>pessoa denunciada</strong> (copie o uid e cole em Suporte).</li>
          <li>Viola as regras? Troque nome/foto em <code>users/{uid}</code> e nos placares, ou desative a conta no
            <a href="https://console.firebase.google.com/project/${escapeHtml(FIREBASE_PROJECT)}/authentication/users" target="_blank" rel="noopener">Firebase Auth ↗</a>.
            Depois toque <strong>Já agi</strong>.</li>
          <li>Não viola? <strong>Sem fundamento</strong>.</li>
        </ol>
        <p><strong>Os botões não avisam ninguém.</strong> O app ainda não tem canal de resposta. Para responder a quem denunciou,
          procure o uid no Firebase Auth (lá está o e-mail) e escreva de fora. Diga só que a denúncia foi analisada; não conte o que aconteceu com a outra pessoa.</p>
      </details>`,
    card: (r, ctx) => {
      const h = hoursSince(r.createdAt);
      const late = isOpen(r) && h !== null && h >= 24;
      const source = PEOPLE_SOURCE[r.source] || r.source || '—';
      return {
        late,
        tags: [
          [PEOPLE_REASON[r.reason] || r.reason || '—', 'bad'],
          late ? ['Passou de 24h', 'warn', 'A App Store pede ação em até 24h'] : null,
        ],
        facts: [
          ['Pessoa denunciada', person(r.targetName, r.targetUid, '', r.id)],
          ['Onde foi vista', escapeHtml(r.roomName ? `${source} · grupo “${r.roomName}” (${r.roomCode || ''})` : source)],
          ['Comentário', quote(r.comment)],
          ['Quando', when(r)],
          ['Quem denunciou', person(ctx.names.get(r.reporterUid), r.reporterUid, '', r.id)],
        ],
      };
    },
  },
  {
    id: 'app',
    label: 'Problemas do app',
    col: COL.appReports,
    statuses: STATUS,
    help: () => '<p class="rp-lead">Enviados pelo app em “Relatar problema”. Se a pessoa deixou e-mail, responda por fora.</p>',
    card: (r) => ({
      tags: [[APP_CATEGORY[r.category] || r.category || '—', '']],
      facts: [
        ['Relato', quote(r.comment)],
        ['Aparelho', escapeHtml([
          r.platform,
          r.osVersion,
          r.appVersion ? `v${r.appVersion}${r.buildNumber ? ` (${r.buildNumber})` : ''}` : '',
          r.locale,
        ].filter(Boolean).join(' · ') || '—')],
        ['Quando', when(r)],
        ['Quem mandou', person(r.displayName, r.uid, r.email)],
      ],
    }),
  },
  {
    id: 'questions',
    label: 'Erros em perguntas',
    col: COL.reports,
    statuses: STATUS,
    categories: QUESTION_CATEGORY,
    help: () => '<p class="rp-lead">Toque <strong>Abrir pergunta</strong> para corrigir no editor. Depois marque <strong>Corrigido</strong>.</p>',
    card: (r) => {
      const mode = DIFFS.find((d) => d.id === r.difficulty)?.label || r.difficulty;
      return {
        tags: [[QUESTION_CATEGORY[r.category] || r.category || '—', '']],
        extraAction: r.questionId
          ? `<button type="button" class="btn btn-sm btn-secondary" data-open-q="${escapeHtml(r.questionId)}">Abrir pergunta</button>`
          : '',
        facts: [
          ['Pergunta', `${escapeHtml(r.questionText || '—')}${r.verseRef ? ` <span class="field-hint">· ${escapeHtml(r.verseRef)}</span>` : ''}`],
          ['Resposta', `${r.userWasCorrect ? 'acertou' : 'errou'} · escolheu “${escapeHtml(r.selectedOptionText || r.selectedOptionId || '—')}” · certa “${escapeHtml(r.correctOptionText || r.correctOptionId || '—')}”`],
          ['Comentário', quote(r.comment)],
          ['Onde', `${escapeHtml([r.missionSlug, mode].filter(Boolean).join(' · ') || '—')}${r.questionId ? ` <code class="rp-id">${escapeHtml(r.questionId)}</code>` : ''}`],
          ['Quando', when(r)],
          ['Quem mandou', person(r.displayName, r.uid, r.email)],
        ],
      };
    },
  },
  {
    id: 'trails',
    label: 'Sugestões de trilha',
    col: COL.suggestions,
    statuses: STATUS,
    help: () => '<p class="rp-lead">Pedidos feitos no mapa: o que as pessoas querem estudar.</p>',
    card: (s) => ({
      tags: [[REALM[s.realmId] || s.realmId || 'Sem reino', '']],
      facts: [
        ['Sugestão', escapeHtml(s.text || '—')],
        ['Quando', when(s)],
        ['Quem mandou', person(s.displayName, s.uid, s.email)],
      ],
    }),
  },
  {
    id: 'authors',
    label: 'Autores',
    col: COL.authorSuggestions,
    statuses: STATUS,
    help: () => '<p class="rp-lead">Autores indicados para escrever trilhas.</p>',
    card: (s) => ({
      tags: [],
      facts: [
        ['Autor', `<strong>${escapeHtml(s.name || '—')}</strong>`],
        ['Contato', escapeHtml([s.phone ? `Tel. ${s.phone}` : '', s.email || '', s.instagram ? `@${s.instagram}` : ''].filter(Boolean).join(' · ') || '—')],
        ['Quando', when(s)],
        ['Indicado por', person(s.submitterName, s.uid, s.submitterEmail)],
      ],
    }),
  },
];

/** Aba a abrir na próxima entrada em Relatos (o Hoje escolhe). */
let pendingTab = null;
export function openReportsTab(id) {
  pendingTab = id;
}

async function loadOrdered(colId) {
  try {
    const snap = await getDocs(query(collection(db, colId), orderBy('createdAt', 'desc')));
    return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
  } catch {
    const snap = await getDocs(collection(db, colId));
    return snap.docs
      .map((d) => ({ id: d.id, ...d.data() }))
      .sort((a, b) => (b.createdAt?.toMillis?.() ?? 0) - (a.createdAt?.toMillis?.() ?? 0));
  }
}

/* ─── Página ─────────────────────────────────────────────── */

export async function renderReportsPage(root) {
  root.innerHTML = '<div class="ez-page wide"><div class="ez-skeleton">Carregando relatos…</div></div>';

  const data = {};
  try {
    const lists = await Promise.all(TABS.map((t) => loadOrdered(t.col)));
    TABS.forEach((t, i) => {
      data[t.id] = lists[i];
    });
  } catch (err) {
    root.innerHTML = `<div class="ez-page wide"><p class="ez-hint">Erro ao carregar relatos: ${escapeHtml(err.message || String(err))}</p></div>`;
    return;
  }

  // Nome de quem denunciou: `users/{uid}` é público (o e-mail não é).
  const names = new Map();
  await Promise.all(
    [...new Set(data.people.map((r) => r.reporterUid).filter(Boolean))].map(async (uid) => {
      try {
        const u = await getDocById(COL.users, uid);
        if (u) names.set(uid, u.userName || u.name || u.displayName || '');
      } catch {
        /* sem nome: fica o uid */
      }
    }),
  );
  const ctx = { names };

  const openCount = (id) => data[id].filter(isOpen).length;
  let tab = TABS.some((t) => t.id === pendingTab)
    ? pendingTab
    : (TABS.find((t) => openCount(t.id)) || TABS[0]).id;
  pendingTab = null;
  const statusFilter = Object.fromEntries(TABS.map((t) => [t.id, 'open']));
  let category = '';

  function cardHtml(t, r) {
    const c = t.card(r, ctx);
    const open = isOpen(r);
    const actions = open
      ? (t.actions || DEFAULT_ACTIONS)
          .map(([status, label, cls, title]) => `<button type="button" class="btn btn-sm ${cls}" data-set="${status}" data-id="${escapeHtml(r.id)}" title="${escapeHtml(title)}">${escapeHtml(label)}</button>`)
          .join('')
      : `<button type="button" class="btn btn-sm btn-ghost" data-set="open" data-id="${escapeHtml(r.id)}">Reabrir</button>`;
    const tags = [...c.tags, open ? null : [t.statuses[r.status] || r.status, 'ok']].filter(Boolean);
    return `
      <article class="rp-card ${c.late ? 'late' : ''} ${open ? '' : 'done'}">
        <header class="rp-card-head">
          <div class="rp-tags">
            ${tags.map(([label, tone, title]) => `<span class="rv-pill ${tone}" ${title ? `title="${escapeHtml(title)}"` : ''}>${escapeHtml(label)}</span>`).join('')}
          </div>
          <div class="td-actions">${c.extraAction || ''}${actions}</div>
        </header>
        <dl class="rp-facts">
          ${c.facts.map(([k, v]) => `<dt>${escapeHtml(k)}</dt><dd>${v}</dd>`).join('')}
        </dl>
      </article>`;
  }

  function panelHtml() {
    const t = TABS.find((x) => x.id === tab);
    const status = statusFilter[tab];
    const list = data[tab].filter((r) => {
      if (status && (r.status || 'open') !== status) return false;
      if (t.categories && category && r.category !== category) return false;
      return true;
    });
    return `
      <div class="rp-toolbar">
        <select id="rp-status" class="rp-filter" aria-label="Status">
          <option value="">Todos os status</option>
          ${Object.entries(t.statuses).map(([k, v]) => `<option value="${k}" ${status === k ? 'selected' : ''}>${escapeHtml(v)}</option>`).join('')}
        </select>
        ${t.categories ? `
          <select id="rp-cat" class="rp-filter" aria-label="Categoria">
            <option value="">Todas as categorias</option>
            ${Object.entries(t.categories).map(([k, v]) => `<option value="${k}" ${category === k ? 'selected' : ''}>${escapeHtml(v)}</option>`).join('')}
          </select>` : ''}
        <span class="field-hint">${list.length} ${list.length === 1 ? 'item' : 'itens'}</span>
      </div>
      ${t.help()}
      ${list.length
        ? list.map((r) => cardHtml(t, r)).join('')
        : `<div class="rp-empty">${status === 'open' ? 'Nada aberto aqui.' : 'Nada neste filtro.'}</div>`}`;
  }

  function render() {
    root.innerHTML = `
      <div class="ez-page wide">
        <header class="ez-hero db-hero">
          <div>
            <h1>Relatos</h1>
            <p class="ez-lead">O que as pessoas mandam pelo app. Mudar o status não avisa ninguém.</p>
          </div>
        </header>
        <nav class="rp-tabs" role="tablist">
          ${TABS.map((t) => {
            const n = openCount(t.id);
            return `<button type="button" role="tab" class="${t.id === tab ? 'on' : ''}" aria-selected="${t.id === tab}" data-tab="${t.id}">${escapeHtml(t.label)}${n ? `<span class="rp-count ${t.id === 'people' ? 'hot' : ''}">${n}</span>` : ''}</button>`;
          }).join('')}
        </nav>
        <section class="rp-panel" role="tabpanel">${panelHtml()}</section>
      </div>`;
    bind();
  }

  async function setStatus(id, status) {
    const t = TABS.find((x) => x.id === tab);
    try {
      await updateDoc(doc(db, t.col, id), { status, reviewedAt: Timestamp.now() });
      const item = data[tab].find((r) => r.id === id);
      if (item) item.status = status;
      showToast(status === 'open' ? 'Reaberto' : 'Status atualizado', 'success');
      render();
    } catch (err) {
      showToast(err.message || 'Falha ao atualizar', 'error');
    }
  }

  function bind() {
    root.querySelectorAll('[data-tab]').forEach((btn) => {
      btn.addEventListener('click', () => {
        tab = btn.dataset.tab;
        category = '';
        render();
      });
    });
    root.querySelector('#rp-status')?.addEventListener('change', (e) => {
      statusFilter[tab] = e.target.value;
      render();
    });
    root.querySelector('#rp-cat')?.addEventListener('change', (e) => {
      category = e.target.value;
      render();
    });
    root.querySelectorAll('[data-set]').forEach((btn) => {
      btn.addEventListener('click', () => setStatus(btn.dataset.id, btn.dataset.set));
    });
    root.querySelectorAll('[data-copy]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        try {
          await navigator.clipboard.writeText(btn.dataset.copy);
          showToast('uid copiado', 'success');
        } catch {
          showToast(btn.dataset.copy, 'info');
        }
      });
    });
    root.querySelectorAll('[data-person]').forEach((btn) => {
      btn.addEventListener('click', () => {
        openPersonModal({
          uid: btn.dataset.person,
          name: btn.dataset.personName,
          reportId: btn.dataset.report || '',
          onChanged: () => {
            openReportsTab(tab);
            renderReportsPage(root);
          },
        });
      });
    });
    root.querySelectorAll('[data-open-q]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        try {
          const q = await getDocById(COL.bank, btn.dataset.openQ);
          if (!q) {
            showToast('A pergunta não existe mais no banco', 'error');
            return;
          }
          const trail = q.trail ? await getDocById(COL.trails, q.trail) : null;
          await openQuestionStudio({ existing: q, trails: trail ? [trail] : [] });
        } catch (err) {
          showToast(err.message || 'Falha ao abrir', 'error');
        }
      });
    });
  }

  render();
}
