/**
 * Suporte (só admin): lista contas com Plus, aparelho, versão do app e último
 * acesso.
 *
 *   Abrir  → modal de leitura (perfil, Plus, relatos, console)
 *   Ficha  → modal de moderação (person-modal); as duas folhas trocam pelas abas do topo
 *
 * O e-mail não fica mais em `users/{uid}` (qualquer peregrino lê esse doc).
 * A coluna vem do login, via `moderateUser` action `emails`. O que sobrou no
 * perfil público entra só se o login não devolver e-mail.
 *
 * Só leitura. Mudar Plus continua no script (o campo é do webhook RevenueCat):
 *   node scripts/set_plus_active.mjs --uids UID --on --apply
 */
import { getFunctions, httpsCallable } from 'firebase/functions';
import { app } from './firebase.js';
import { COL, formatDate, getAppRelease, getDocById, listDocs, listWhere } from './db.js';
import { getRole } from './roles.js';
import { bindModalDismiss, escapeHtml, showModalElement, showToast } from './ui.js';
import { openPersonModal, accountTabsHtml } from './person-modal.js';

const moderateUser = httpsCallable(getFunctions(app, 'us-central1'), 'moderateUser');

const GIFT_CODE = /^[A-Z0-9]{8}$/;

/** Builds até aqui perdem a trilha da cena emprestada no cache (A Promessa). */
const OLD_BUILD_MAX = 39;
const DAY_MS = 24 * 3600 * 1000;

const FILTERS = [
  { key: 'all', label: 'Todos' },
  { key: 'plus', label: 'Plus' },
  { key: 'trial', label: 'Em teste' },
  { key: 'active7', label: 'Ativos 7 dias' },
  { key: 'android', label: 'Android' },
  { key: 'ios', label: 'iOS' },
  { key: 'outdated', label: 'Versão desatualizada' },
  { key: 'old', label: `Build ≤ ${OLD_BUILD_MAX}` },
];

const TIMELINE_ICON = {
  account: '🔑',
  app: '📱',
  scene: '🎬',
  trail: '🧭',
  bible: '📖',
  invite: '✉️',
  plus: '⭐',
  together: '🤝',
  gift: '🎁',
  report: '⚑',
  moderation: '🛡️',
  season: '🕯️',
};

const PLATFORM_LABEL = {
  android: 'Android',
  ios: 'iOS',
  web: 'Web',
  macos: 'macOS',
  windows: 'Windows',
  linux: 'Linux',
};

const MAIN_FIELDS = [
  ['name', 'Nome'],
  ['email', 'E-mail'],
  ['platform', 'Aparelho'],
  ['appVersion', 'Versão do app'],
  ['authProvider', 'Login'],
  ['plusActive', 'Peregrino+'],
  ['plusInTrial', 'Em teste grátis'],
  ['supporter', 'Selo de apoiador'],
  ['pioneerCounted', 'Pioneiro contado'],
  ['xp', 'Passos (total)'],
  ['weeklyXp', 'Passos na semana'],
  ['streak', 'Sequência'],
  ['bestStreak', 'Melhor sequência'],
  ['firstOpenDate', 'Criado (1º acesso)'],
  ['lastSeenDate', 'Visto por último'],
  ['updatedAt', 'Atualizado'],
];

const SORT_COLS = [
  { key: 'name', label: 'Nome' },
  { key: 'email', label: 'E-mail' },
  { key: 'platform', label: 'Aparelho' },
  { key: 'appVersion', label: 'Versão' },
  { key: 'plus', label: 'Plus' },
  { key: 'activity', label: 'Atividade' },
  { key: 'created', label: 'Criado' },
  { key: 'seen', label: 'Último acesso' },
];

function displayName(u) {
  return u.userName || u.name || u.displayName || '(sem nome)';
}

/** App grava dias como YYYY-MM-DD; Timestamp também aparece em alguns campos. */
function dayKey(raw) {
  if (raw == null || raw === '') return '';
  if (typeof raw?.toDate === 'function') return raw.toDate().toISOString().slice(0, 10);
  const s = String(raw);
  if (/^\d{4}-\d{2}-\d{2}/.test(s)) return s.slice(0, 10);
  const d = new Date(s);
  return Number.isNaN(d.getTime()) ? '' : d.toISOString().slice(0, 10);
}

function dayLabel(raw) {
  const key = dayKey(raw);
  if (!key) return '—';
  const [y, m, d] = key.split('-');
  return `${d}/${m}/${y}`;
}

function shortDay(ms) {
  const d = new Date(ms);
  return `${String(d.getDate()).padStart(2, '0')}/${String(d.getMonth() + 1).padStart(2, '0')}`;
}

function expiresMs(u) {
  const raw = u.plusExpiresAt;
  if (!raw) return null;
  const ms = typeof raw?.toMillis === 'function' ? raw.toMillis() : Date.parse(raw);
  return Number.isNaN(ms) ? null : ms;
}

/**
 * Estado do Plus para a lista. O webhook grava teste, data e renovação;
 * conta ligada pelo script não tem `plusSource` (sem data, "manual").
 */
export function plusState(u, now = Date.now()) {
  if (!u.plusActive) return { kind: 'none', label: 'não', tone: '' };
  const exp = expiresMs(u);
  if (u.plusSource !== 'revenuecat' && !exp) {
    return { kind: 'manual', label: 'Plus · manual', tone: 'plus', title: 'Ligado pelo script, sem dados do RevenueCat' };
  }
  if (exp && exp < now) {
    return { kind: 'stale', label: `Plus · venceu ${shortDay(exp)}`, tone: 'bad', title: 'Data passou e nenhum evento desligou o Plus' };
  }
  const until = exp ? ` ${shortDay(exp)}` : '';
  if (u.plusInTrial) {
    const left = exp ? Math.max(0, Math.ceil((exp - now) / DAY_MS)) : null;
    return {
      kind: 'trial',
      label: `Teste · até${until}`,
      tone: 'warn',
      title: left != null ? `${left} dia(s) de teste restantes` : 'Em teste grátis',
    };
  }
  if (u.plusWillRenew === false) {
    return { kind: 'canceled', label: `Cancelou · vence${until}`, tone: 'warn', title: 'Não renova' };
  }
  return { kind: 'paid', label: exp ? `Plus · renova${until}` : 'Plus', tone: 'ok' };
}

function plusCell(u) {
  const st = plusState(u);
  const title = st.title ? ` title="${escapeHtml(st.title)}"` : '';
  return `<span class="rv-pill ${st.tone} sm"${title}>${escapeHtml(st.label)}</span>`;
}

function scenesDone(u) {
  return Array.isArray(u.completedMissions) ? u.completedMissions.length : 0;
}

function activityCell(u) {
  const n = scenesDone(u);
  const streak = Number(u.streak) || 0;
  if (!n && !streak) return '<span class="us-muted">nenhuma cena</span>';
  const last = u.lastMissionSlug ? ` title="Última: ${escapeHtml(u.lastMissionSlug)}"` : '';
  return `<span${last}>${n} cena${n === 1 ? '' : 's'}${streak ? ` · 🔥${streak}` : ''}</span>`;
}

function buildOf(u) {
  const b = Number(String(u.buildNumber || '').trim());
  if (b) return b;
  const m = String(u.appVersion || '').match(/\((\d+)\)/);
  return m ? Number(m[1]) : 0;
}

/** Marcas que os filtros rápidos usam (uma string por linha). */
function rowTags(u, latestBuild) {
  const tags = [];
  const st = plusState(u);
  if (st.kind !== 'none') tags.push('plus');
  if (st.kind === 'trial') tags.push('trial');
  const seen = dayKey(u.lastSeenDate);
  if (seen && Date.now() - Date.parse(`${seen}T12:00:00Z`) <= 7 * DAY_MS) tags.push('active7');
  const pk = platformKey(u);
  if (pk) tags.push(pk);
  const b = buildOf(u);
  if (b && latestBuild && b < latestBuild) tags.push('outdated');
  if (b && b <= OLD_BUILD_MAX) tags.push('old');
  return tags.join(' ');
}

function platformKey(u) {
  return String(u.platform || '').toLowerCase();
}

function platformCell(u) {
  const key = platformKey(u);
  if (!key) return '—';
  const label = PLATFORM_LABEL[key] || key;
  const tone = key === 'ios' ? 'ok' : key === 'android' ? 'warn' : '';
  return `<span class="rv-pill ${tone} sm">${escapeHtml(label)}</span>`;
}

/** Ex.: `1.4.2 (83)` — perfil do app; build opcional. */
function versionLabel(u) {
  const v = String(u?.appVersion || '').trim();
  if (!v) return '';
  const build = String(u?.buildNumber || '').trim();
  return build ? `${v} (${build})` : v;
}

function versionCell(u, latestBuild = 0) {
  const label = versionLabel(u);
  if (!label) return '—';
  const b = buildOf(u);
  const tone = b && b <= OLD_BUILD_MAX ? ' is-old' : b && latestBuild && b < latestBuild ? ' is-outdated' : '';
  const title = tone === ' is-old'
    ? ' title="Build antigo: perde cenas emprestadas. Peça para atualizar."'
    : tone ? ` title="Loja já tem o build ${latestBuild}"` : '';
  return `<code class="us-uid${tone}"${title}>${escapeHtml(label)}</code>`;
}

function fmt(v, key, u = null) {
  if (key === 'platform') return platformCell({ platform: v });
  if (key === 'appVersion') return versionCell(u || { appVersion: v });
  if (v === true) return '<span class="rv-pill ok sm">sim</span>';
  if (v === false) return '<span class="rv-pill sm">não</span>';
  if (v == null || v === '') return '—';
  if (typeof v?.toDate === 'function') return escapeHtml(formatDate(v));
  if (typeof v === 'object') return `<code>${escapeHtml(JSON.stringify(v).slice(0, 140))}</code>`;
  return escapeHtml(String(v));
}

function sortValue(u, key) {
  switch (key) {
    case 'name':
      return displayName(u).toLowerCase();
    case 'email':
      return String(u.email || '').toLowerCase();
    case 'platform':
      return platformKey(u);
    case 'appVersion':
      return versionLabel(u).toLowerCase();
    case 'plus': {
      const order = { none: 0, stale: 1, manual: 2, trial: 3, canceled: 4, paid: 5 };
      return order[plusState(u).kind] ?? 0;
    }
    case 'activity':
      return scenesDone(u);
    case 'created':
      return dayKey(u.firstOpenDate);
    case 'seen':
      return dayKey(u.lastSeenDate);
    default:
      return '';
  }
}

function sortUsers(users, key, dir) {
  const mult = dir === 'asc' ? 1 : -1;
  return [...users].sort((a, b) => {
    const av = sortValue(a, key);
    const bv = sortValue(b, key);
    if (av === '' && bv !== '') return 1;
    if (bv === '' && av !== '') return -1;
    if (typeof av === 'number' && typeof bv === 'number') return (av - bv) * mult;
    return String(av).localeCompare(String(bv), 'pt-BR') * mult;
  });
}

function sortTh(col, sort) {
  const active = sort.key === col.key;
  const arrow = active ? (sort.dir === 'asc' ? ' ↑' : ' ↓') : '';
  const aria = active ? ` aria-sort="${sort.dir === 'asc' ? 'ascending' : 'descending'}"` : '';
  return `<th class="sortable${active ? ' is-sorted' : ''}" data-sort="${col.key}"${aria} title="Ordenar por ${escapeHtml(col.label)}">${escapeHtml(col.label)}${arrow}</th>`;
}

function rawJson(obj) {
  return JSON.stringify(
    obj,
    (k, v) => (v && typeof v === 'object' && typeof v.toDate === 'function' ? v.toDate().toISOString() : v),
    2,
  );
}

function copyBtn(text, label = 'Copiar') {
  return `<button type="button" class="btn btn-ghost btn-sm" data-copy="${escapeHtml(text)}">${escapeHtml(label)}</button>`;
}

async function reportsFor(uid) {
  const tag = (kind) => (list) => list.map((r) => ({ ...r, kind }));
  const parts = await Promise.all([
    listWhere(COL.userReports, 'targetUid', uid).then(tag('denunciada')).catch(() => []),
    listWhere(COL.userReports, 'reporterUid', uid).then(tag('denunciou')).catch(() => []),
    listWhere(COL.appReports, 'uid', uid).then(tag('problema no app')).catch(() => []),
    listWhere(COL.reports, 'uid', uid).then(tag('erro em pergunta')).catch(() => []),
  ]);
  return parts.flat();
}

/**
 * Modal de suporte (só leitura): perfil, aparelho, Plus, relatos.
 * Diferente da Ficha, que é moderação.
 */
async function openSupportModal({ uid, user: known, onOpenFicha } = {}) {
  const modal = document.getElementById('modal');
  if (!modal || !uid) return;

  modal.innerHTML = `
    <div class="modal-backdrop qs-backdrop">
      <div class="modal-card card qs-modal" role="dialog" aria-modal="true">
        <header class="qs-head">
          <div>
            <p class="simple-kicker">Suporte</p>
            <h2>Carregando…</h2>
          </div>
          <button type="button" class="modal-close" aria-label="Fechar">×</button>
        </header>
        <div class="ez-skeleton">Buscando conta…</div>
      </div>
    </div>`;
  showModalElement(modal);
  let closed = false;
  const close = bindModalDismiss(modal, () => {
    closed = true;
  });
  // Cada render troca o innerHTML: religa fechar (Esc já está no document).
  const wireClose = () => {
    modal.querySelector('.modal-close')?.addEventListener('click', close);
    modal.querySelector('.modal-backdrop')?.addEventListener('click', (e) => {
      if (e.target.classList.contains('modal-backdrop')) close();
    });
  };

  try {
    let u = known;
    if (!u || u.id !== uid) {
      u = await getDocById(COL.users, uid);
      if (closed) return;
      if (!u) {
        modal.innerHTML = `
          <div class="modal-backdrop qs-backdrop">
            <div class="modal-card card qs-modal" role="dialog" aria-modal="true">
              <header class="qs-head">
                <div>
                  <p class="simple-kicker">Suporte</p>
                  <h2>Conta não encontrada</h2>
                  <p class="pm-sub"><code>${escapeHtml(uid)}</code></p>
                </div>
                <button type="button" class="modal-close" aria-label="Fechar">×</button>
              </header>
              <p class="ez-hint">Não há perfil em <code>users</code> com este uid. A conta pode ter sido excluída.</p>
            </div>
          </div>`;
        wireClose();
        return;
      }
      if (known?.email) u.email = known.email;
      if (known?.platform && !u.platform) u.platform = known.platform;
      if (known?.appVersion && !u.appVersion) {
        u.appVersion = known.appVersion;
        u.buildNumber = known.buildNumber || u.buildNumber;
      }
    }
    const reports = await reportsFor(uid);
    if (closed) return;
    const name = displayName(u);
    const rest = Object.fromEntries(
      Object.entries(u).filter(
        ([k]) => k !== 'id' && k !== 'buildNumber' && !MAIN_FIELDS.some(([f]) => f === k),
      ),
    );
    modal.innerHTML = `
      <div class="modal-backdrop qs-backdrop">
        <div class="modal-card card qs-modal" role="dialog" aria-modal="true">
          <header class="qs-head">
            <div>
              <p class="simple-kicker">Suporte · só leitura</p>
              <h2>${escapeHtml(name)}</h2>
              <p class="pm-sub"><code>${escapeHtml(uid)}</code> ${copyBtn(uid, 'Copiar uid')}</p>
            </div>
            ${onOpenFicha ? accountTabsHtml('support') : ''}
            <button type="button" class="modal-close" aria-label="Fechar">×</button>
          </header>
          <ul class="db-list">
            <li><span>Situação do Plus</span><strong>${plusCell(u)}</strong></li>
            ${MAIN_FIELDS.map(([k, label]) => `<li><span>${escapeHtml(label)}</span><strong>${fmt(u[k], k, u)}</strong></li>`).join('')}
            <li><span>Cenas concluídas</span><strong>${scenesDone(u)}</strong></li>
          </ul>
          <div class="us-actions">
            <p class="ez-hint">Plus vem do webhook RevenueCat. Para teste manual:</p>
            ${copyBtn(`node scripts/set_plus_active.mjs --uids ${uid} --on --apply`, 'Comando: ligar Plus')}
            ${copyBtn(`node scripts/set_plus_active.mjs --uids ${uid} --off --apply`, 'Comando: desligar Plus')}
            <a class="btn btn-ghost btn-sm" target="_blank" rel="noopener" href="https://console.firebase.google.com/project/${escapeHtml(import.meta.env.VITE_FIREBASE_PROJECT_ID || 'trilha-biblia')}/firestore/data/~2Fusers~2F${encodeURIComponent(uid)}">Abrir no Console ↗</a>
          </div>
          <h4 class="us-sub">Linha do tempo</h4>
          <div id="us-timeline"><p class="ez-hint">Carregando…</p></div>
          <h4 class="us-sub">Relatos</h4>
          ${reports.length
            ? `<ul class="db-list">${reports.map((r) => `<li><span>${escapeHtml(r.kind)} · ${escapeHtml(r.reason || r.category || '')} ${r.comment ? `— ${escapeHtml(String(r.comment).slice(0, 120))}` : ''}</span><strong>${escapeHtml(r.status || 'open')} · ${escapeHtml(formatDate(r.createdAt, { time: false }))}</strong></li>`).join('')}</ul>`
            : '<p class="ez-hint">Nenhum relato feito por esta conta ou contra ela.</p>'}
          <details class="qs-advanced">
            <summary>Todos os campos</summary>
            <pre class="us-raw">${escapeHtml(rawJson(rest))}</pre>
          </details>
        </div>
      </div>`;
    wireClose();
    modal.querySelectorAll('[data-copy]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        try {
          await navigator.clipboard.writeText(btn.dataset.copy);
          showToast('Copiado');
        } catch {
          showToast(btn.dataset.copy, 'info');
        }
      });
    });
    modal.querySelector('[data-account-tab="ficha"]')?.addEventListener('click', () => {
      close();
      onOpenFicha?.(uid, name);
    });
    loadTimeline(modal.querySelector('#us-timeline'), uid, () => closed, (other) => {
      close();
      openSupportModal({ uid: other, onOpenFicha });
    });
  } catch (e) {
    close();
    showToast(e.message || String(e), 'error');
  }
}

function timelineHtml(events) {
  if (!events.length) return '<p class="ez-hint">Nada registrado para esta conta.</p>';
  return `<ol class="us-timeline">
    ${events.map((e) => {
      const when = new Date(e.at);
      const date = Number.isNaN(when.getTime()) ? '' : when.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: '2-digit' });
      const link = e.uid ? ` <button type="button" class="us-tl-link" data-tl-uid="${escapeHtml(e.uid)}" title="Abrir esta conta">${escapeHtml(e.uid.slice(0, 6))}…</button>` : '';
      return `<li class="us-tl-${escapeHtml(e.kind)}">
        <time>${escapeHtml(date)}</time>
        <span class="us-tl-icon" aria-hidden="true">${TIMELINE_ICON[e.kind] || '•'}</span>
        <span>${escapeHtml(e.text)}${e.detail ? ` <small>${escapeHtml(e.detail)}</small>` : ''}${link}</span>
      </li>`;
    }).join('')}
  </ol>`;
}

async function loadTimeline(el, uid, isClosed, openOther) {
  if (!el) return;
  try {
    const { data } = await moderateUser({ action: 'timeline', uid });
    if (isClosed()) return;
    el.innerHTML = timelineHtml(data?.events || []);
    el.querySelectorAll('[data-tl-uid]').forEach((b) => b.addEventListener('click', () => openOther(b.dataset.tlUid)));
  } catch (e) {
    if (isClosed()) return;
    el.innerHTML = `<p class="ez-hint">Linha do tempo indisponível (${escapeHtml(e.message || String(e))}). A função <code>moderateUser</code> precisa do deploy novo.</p>`;
  }
}

function giftCard(g) {
  const used = Boolean(g.toUid);
  return `
    <section class="db-card wide ${used ? '' : 'ok'}">
      <header>
        <h3>Passe <code>${escapeHtml(g.id)}</code></h3>
        <span>
          <span class="rv-pill ${used ? '' : 'ok'}">${used ? 'resgatado' : 'livre'}</span>
          <button type="button" class="btn btn-ghost btn-sm" data-clear-results>Fechar</button>
        </span>
      </header>
      <ul class="db-list">
        <li><span>De</span><strong>${escapeHtml(g.fromName || '—')} <code>${escapeHtml(g.fromUid || '')}</code></strong></li>
        <li><span>Trilha</span><strong>${escapeHtml(g.trailSlug || '(quem recebe escolhe)')}</strong></li>
        <li><span>Mês</span><strong>${escapeHtml(g.month || '—')}</strong></li>
        <li><span>Criado</span><strong>${fmt(g.createdAt)}</strong></li>
        <li><span>Para</span><strong>${used ? `${escapeHtml(g.toName || '')} <code>${escapeHtml(g.toUid)}</code>` : '—'}</strong></li>
        <li><span>Resgatado</span><strong>${fmt(g.redeemedAt)}</strong></li>
      </ul>
      ${used
        ? `<p class="us-actions"><button type="button" class="btn btn-secondary btn-sm" data-ficha="${escapeHtml(g.toUid)}" data-ficha-name="${escapeHtml(g.toName || '')}">Ficha de quem resgatou</button></p>`
        : ''}
    </section>`;
}

function usersTable(users, sort, latestBuild, filter) {
  if (!users.length) return '<p class="ez-hint">Nenhuma conta em <code>users</code>.</p>';
  const tagged = users.map((u) => ({ u, tags: rowTags(u, latestBuild) }));
  const count = (k) => (k === 'all' ? users.length : tagged.filter((x) => x.tags.split(' ').includes(k)).length);
  return `
    <div class="us-filters" role="group" aria-label="Filtros rápidos">
      ${FILTERS.map((f) => `<button type="button" class="ez-chip${filter === f.key ? ' active' : ''}" data-filter-key="${f.key}">${escapeHtml(f.label)} <small>${count(f.key)}</small></button>`).join('')}
    </div>
    <p class="db-lead"><span id="us-count">${users.length}</span> contas · clique no cabeçalho para ordenar${latestBuild ? ` · loja no build ${latestBuild}` : ''}</p>
    <div class="table-wrap">
      <table class="data-table" id="us-table">
        <thead>
          <tr>
            ${SORT_COLS.map((c) => sortTh(c, sort)).join('')}
            <th></th>
          </tr>
        </thead>
        <tbody>
          ${tagged.map(({ u, tags }) => {
            const name = displayName(u);
            const email = u.email || '';
            const hay = `${name} ${email} ${u.id}`.toLowerCase();
            return `
              <tr data-filter="${escapeHtml(hay)}" data-tags="${tags}">
                <td>${escapeHtml(name)}<br><code class="us-uid">${escapeHtml(u.id)}</code></td>
                <td>${email ? escapeHtml(email) : '—'}</td>
                <td>${platformCell(u)}</td>
                <td>${versionCell(u, latestBuild)}</td>
                <td>${plusCell(u)}</td>
                <td>${activityCell(u)}</td>
                <td>${escapeHtml(dayLabel(u.firstOpenDate))}</td>
                <td>${escapeHtml(dayLabel(u.lastSeenDate))}</td>
                <td class="td-actions">
                  <button type="button" class="btn btn-secondary btn-sm" data-abrir="${escapeHtml(u.id)}" data-abrir-name="${escapeHtml(name)}">Abrir</button>
                </td>
              </tr>`;
          }).join('')}
        </tbody>
      </table>
    </div>`;
}

export async function renderUsersPage(root) {
  if (getRole() !== 'admin') {
    root.innerHTML = '<div class="card"><p>Só administradores.</p></div>';
    return;
  }
  let allUsers = [];
  let sort = { key: 'seen', dir: 'desc' };
  let emailsReady = true;
  let latestBuild = 0;
  let filter = 'all';

  root.innerHTML = `
    <div class="ez-page wide">
      <header class="ez-hero">
        <div>
          <h1>Suporte</h1>
          <p class="ez-lead">Abrir mostra conta e Plus; a aba Moderação fica na mesma folha. Busque por e-mail, uid ou código de passe.</p>
        </div>
      </header>
      <form class="ez-toolbar" id="us-form">
        <input type="search" id="us-q" class="ez-search" placeholder="Filtrar lista ou buscar e-mail · uid · ABCD1234" autocomplete="off" />
        <button type="submit" class="btn btn-primary">Buscar</button>
      </form>
      <div id="us-list"><div class="ez-skeleton">Carregando contas…</div></div>
      <div id="us-results"></div>
    </div>`;

  const listEl = root.querySelector('#us-list');
  const out = root.querySelector('#us-results');
  const input = root.querySelector('#us-q');

  function clearResults() {
    out.innerHTML = '';
  }

  function applyFilter() {
    const q = (input?.value || '').trim().toLowerCase();
    let shown = 0;
    listEl.querySelectorAll('#us-table tbody tr').forEach((tr) => {
      const hay = tr.dataset.filter || '';
      const tags = (tr.dataset.tags || '').split(' ');
      tr.hidden = (Boolean(q) && !hay.includes(q)) || (filter !== 'all' && !tags.includes(filter));
      if (!tr.hidden) shown += 1;
    });
    const countEl = listEl.querySelector('#us-count');
    if (countEl) countEl.textContent = shown === allUsers.length ? String(shown) : `${shown} de ${allUsers.length}`;
  }

  function openFicha(uid, name = '') {
    clearResults();
    openPersonModal({ uid, name, onChanged: loadList, onOpenSupport: openAbrir });
  }

  function openAbrir(uid, name = '') {
    const known = allUsers.find((x) => x.id === uid) || { id: uid, userName: name };
    openSupportModal({
      uid,
      user: known,
      onOpenFicha: openFicha,
    });
  }

  function wireRowActions(el) {
    el.querySelectorAll('[data-abrir]').forEach((btn) => {
      btn.addEventListener('click', () => openAbrir(btn.dataset.abrir, btn.dataset.abrirName));
    });
    el.querySelectorAll('[data-ficha]').forEach((btn) => {
      btn.addEventListener('click', () => openFicha(btn.dataset.ficha, btn.dataset.fichaName));
    });
  }

  function renderList() {
    const sorted = sortUsers(allUsers, sort.key, sort.dir);
    const note = emailsReady
      ? ''
      : '<p class="ez-hint">E-mails do login não carregaram. A lista mostra só o que ainda está no perfil público.</p>';
    listEl.innerHTML = note + usersTable(sorted, sort, latestBuild, filter);
    wireRowActions(listEl);
    listEl.querySelectorAll('[data-filter-key]').forEach((btn) => {
      btn.addEventListener('click', () => {
        filter = btn.dataset.filterKey;
        listEl.querySelectorAll('[data-filter-key]').forEach((b) => b.classList.toggle('active', b === btn));
        applyFilter();
      });
    });
    listEl.querySelectorAll('th[data-sort]').forEach((th) => {
      th.addEventListener('click', () => {
        const key = th.dataset.sort;
        if (sort.key === key) sort = { key, dir: sort.dir === 'asc' ? 'desc' : 'asc' };
        else {
          const ascFirst = key === 'name' || key === 'email' || key === 'platform' || key === 'appVersion';
          sort = { key, dir: ascFirst ? 'asc' : 'desc' };
        }
        renderList();
      });
    });
    applyFilter();
  }

  async function loadList() {
    listEl.innerHTML = '<div class="ez-skeleton">Carregando contas…</div>';
    try {
      // Sem orderBy: users não tem campo `order` — listCollection devolveria [].
      const [users, reports, release] = await Promise.all([
        listDocs(COL.users),
        listDocs(COL.appReports).catch(() => []),
        getAppRelease().catch(() => null),
      ]);
      latestBuild = Number(release?.latestBuild) || 0;
      // Último relato com cada campo — cobre contas sem sync recente do perfil.
      const fromReport = {};
      for (const r of reports) {
        if (!r.uid) continue;
        const ms = r.createdAt?.toMillis?.() ?? (r.createdAt ? new Date(r.createdAt).getTime() : 0);
        const cur = fromReport[r.uid] || {
          platformMs: -1,
          versionMs: -1,
          platform: '',
          appVersion: '',
          buildNumber: '',
        };
        if (r.platform && ms >= cur.platformMs) {
          cur.platformMs = ms;
          cur.platform = String(r.platform).toLowerCase();
        }
        if (r.appVersion && ms >= cur.versionMs) {
          cur.versionMs = ms;
          cur.appVersion = String(r.appVersion);
          cur.buildNumber = r.buildNumber ? String(r.buildNumber) : '';
        }
        fromReport[r.uid] = cur;
      }
      let authEmails = null;
      try {
        const { data } = await moderateUser({ action: 'emails', uids: users.map((u) => u.id) });
        if (data?.emails && typeof data.emails === 'object') authEmails = data.emails;
      } catch (e) {
        console.warn(e);
      }
      emailsReady = authEmails != null;
      allUsers = users.map((u) => {
        const rep = fromReport[u.id];
        return {
          ...u,
          email: (authEmails && authEmails[u.id]) || u.email || '',
          // Perfil (sync do app) tem prioridade; relato do app cobre contas antigas.
          platform: u.platform || rep?.platform || '',
          appVersion: u.appVersion || rep?.appVersion || '',
          buildNumber: u.buildNumber || rep?.buildNumber || '',
        };
      });
      renderList();
    } catch (e) {
      listEl.innerHTML = `<p class="ez-hint">Falhou ao listar: ${escapeHtml(e.message || String(e))}</p>`;
    }
  }

  async function search() {
    const q = (input?.value || '').trim();
    if (!q) {
      clearResults();
      return;
    }
    out.innerHTML = '<div class="ez-skeleton">Buscando…</div>';
    try {
      if (q.includes('@')) {
        const want = q.toLowerCase();
        const users = allUsers.filter((u) => String(u.email || '').toLowerCase() === want);
        if (!users.length) {
          out.innerHTML = emailsReady
            ? '<p class="ez-hint">Nenhuma conta com este e-mail.</p>'
            : '<p class="ez-hint">Nenhuma conta com este e-mail no perfil público. O e-mail do login não carregou.</p>';
          return;
        }
        if (users.length === 1) {
          clearResults();
          openAbrir(users[0].id, displayName(users[0]));
          return;
        }
        out.innerHTML = `
          <p class="db-lead">${users.length} contas com este e-mail</p>
          <ul class="db-list">${users.map((u) => `
            <li>
              <span>${escapeHtml(displayName(u))} <code>${escapeHtml(u.id)}</code></span>
              <strong>
                <button type="button" class="btn btn-secondary btn-sm" data-abrir="${escapeHtml(u.id)}" data-abrir-name="${escapeHtml(displayName(u))}">Abrir</button>
              </strong>
            </li>`).join('')}</ul>`;
        wireRowActions(out);
        return;
      }

      const code = q.toUpperCase();
      const [u, g] = await Promise.all([
        getDocById(COL.users, q).catch(() => null),
        GIFT_CODE.test(code) ? getDocById(COL.trailGifts, code).catch(() => null) : null,
      ]);
      if (u) {
        const known = allUsers.find((x) => x.id === u.id);
        if (known?.email) u.email = known.email;
        if (known?.platform && !u.platform) u.platform = known.platform;
        clearResults();
        openSupportModal({ uid: u.id, user: { ...u, ...known }, onOpenFicha: openFicha });
        if (g) {
          out.innerHTML = giftCard(g);
          out.querySelector('[data-clear-results]')?.addEventListener('click', clearResults);
          wireRowActions(out);
        }
        return;
      }
      if (g) {
        out.innerHTML = giftCard(g);
        out.querySelector('[data-clear-results]')?.addEventListener('click', clearResults);
        wireRowActions(out);
        return;
      }
      out.innerHTML = '<p class="ez-hint">Nada encontrado com este uid ou código.</p>';
    } catch (e) {
      out.innerHTML = `<p class="ez-hint">Falhou: ${escapeHtml(e.message || String(e))}</p>`;
    }
  }

  root.querySelector('#us-form')?.addEventListener('submit', (e) => {
    e.preventDefault();
    search();
  });
  input?.addEventListener('input', applyFilter);

  await loadList();
}
