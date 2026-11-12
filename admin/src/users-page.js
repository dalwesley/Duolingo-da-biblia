/**
 * Suporte (só admin): lista contas com Plus e último acesso; busca por e-mail,
 * uid ou código de passe para a ficha completa / moderação.
 *
 * Só leitura. Mudar Plus continua no script (o campo é do webhook RevenueCat):
 *   node scripts/set_plus_active.mjs --uids UID --on --apply
 */
import { COL, formatDate, getDocById, listDocs, listWhere } from './db.js';
import { getRole } from './roles.js';
import { escapeHtml, showToast } from './ui.js';
import { openPersonModal } from './person-modal.js';

const GIFT_CODE = /^[A-Z0-9]{8}$/;

const MAIN_FIELDS = [
  ['name', 'Nome'],
  ['email', 'E-mail'],
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
  { key: 'plus', label: 'Plus' },
  { key: 'created', label: 'Criado' },
  { key: 'seen', label: 'Último acesso' },
];

function fmt(v) {
  if (v === true) return '<span class="rv-pill ok sm">sim</span>';
  if (v === false) return '<span class="rv-pill sm">não</span>';
  if (v == null || v === '') return '—';
  if (typeof v?.toDate === 'function') return escapeHtml(formatDate(v));
  if (typeof v === 'object') return `<code>${escapeHtml(JSON.stringify(v).slice(0, 140))}</code>`;
  return escapeHtml(String(v));
}

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

function plusCell(u) {
  if (u.plusActive) {
    return u.plusInTrial
      ? '<span class="rv-pill ok sm">Plus · teste</span>'
      : '<span class="rv-pill ok sm">Plus</span>';
  }
  return '<span class="rv-pill sm">não</span>';
}

function sortValue(u, key) {
  switch (key) {
    case 'name':
      return displayName(u).toLowerCase();
    case 'email':
      return String(u.email || '').toLowerCase();
    case 'plus':
      return u.plusActive ? (u.plusInTrial ? 1 : 2) : 0;
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

function userCard(u, reports) {
  const uid = u.id;
  const rest = Object.fromEntries(Object.entries(u).filter(([k]) => k !== 'id' && !MAIN_FIELDS.some(([f]) => f === k)));
  return `
    <section class="db-card wide">
      <header>
        <h3>${escapeHtml(displayName(u))}</h3>
        <span><code>${escapeHtml(uid)}</code> ${copyBtn(uid, 'Copiar uid')}
          <button type="button" class="btn btn-secondary btn-sm" data-person="${escapeHtml(uid)}" data-person-name="${escapeHtml(displayName(u))}">Ficha e moderação</button></span>
      </header>
      <ul class="db-list">
        ${MAIN_FIELDS.map(([k, label]) => `<li><span>${escapeHtml(label)}</span><strong>${fmt(u[k])}</strong></li>`).join('')}
      </ul>
      <div class="us-actions">
        <p class="ez-hint">Plus vem do webhook RevenueCat. Para teste manual:</p>
        ${copyBtn(`node scripts/set_plus_active.mjs --uids ${uid} --on --apply`, 'Comando: ligar Plus')}
        ${copyBtn(`node scripts/set_plus_active.mjs --uids ${uid} --off --apply`, 'Comando: desligar Plus')}
        <a class="btn btn-ghost btn-sm" target="_blank" rel="noopener" href="https://console.firebase.google.com/project/${escapeHtml(import.meta.env.VITE_FIREBASE_PROJECT_ID || 'trilha-biblia')}/firestore/data/~2Fusers~2F${encodeURIComponent(uid)}">Abrir no Console ↗</a>
      </div>
      <h4 class="us-sub">Relatos</h4>
      ${reports.length
        ? `<ul class="db-list">${reports.map((r) => `<li><span>${escapeHtml(r.kind)} · ${escapeHtml(r.reason || r.category || '')} ${r.comment ? `— ${escapeHtml(String(r.comment).slice(0, 120))}` : ''}</span><strong>${escapeHtml(r.status || 'open')} · ${escapeHtml(formatDate(r.createdAt, { time: false }))}</strong></li>`).join('')}</ul>`
        : '<p class="ez-hint">Nenhum relato feito por esta conta ou contra ela.</p>'}
      <details class="qs-advanced">
        <summary>Todos os campos</summary>
        <pre class="us-raw">${escapeHtml(rawJson(rest))}</pre>
      </details>
    </section>`;
}

function giftCard(g) {
  const used = Boolean(g.toUid);
  return `
    <section class="db-card wide ${used ? '' : 'ok'}">
      <header><h3>Passe <code>${escapeHtml(g.id)}</code></h3><span class="rv-pill ${used ? '' : 'ok'}">${used ? 'resgatado' : 'livre'}</span></header>
      <ul class="db-list">
        <li><span>De</span><strong>${escapeHtml(g.fromName || '—')} <code>${escapeHtml(g.fromUid || '')}</code></strong></li>
        <li><span>Trilha</span><strong>${escapeHtml(g.trailSlug || '(quem recebe escolhe)')}</strong></li>
        <li><span>Mês</span><strong>${escapeHtml(g.month || '—')}</strong></li>
        <li><span>Criado</span><strong>${fmt(g.createdAt)}</strong></li>
        <li><span>Para</span><strong>${used ? `${escapeHtml(g.toName || '')} <code>${escapeHtml(g.toUid)}</code>` : '—'}</strong></li>
        <li><span>Resgatado</span><strong>${fmt(g.redeemedAt)}</strong></li>
      </ul>
    </section>`;
}

function usersTable(users, sort) {
  if (!users.length) return '<p class="ez-hint">Nenhuma conta em <code>users</code>.</p>';
  const plusN = users.filter((u) => u.plusActive).length;
  return `
    <p class="db-lead">${users.length} contas · ${plusN} Plus · clique no cabeçalho para ordenar</p>
    <div class="table-wrap">
      <table class="data-table" id="us-table">
        <thead>
          <tr>
            ${SORT_COLS.map((c) => sortTh(c, sort)).join('')}
            <th></th>
          </tr>
        </thead>
        <tbody>
          ${users.map((u) => {
            const name = displayName(u);
            const email = u.email || '';
            const hay = `${name} ${email} ${u.id}`.toLowerCase();
            return `
              <tr data-filter="${escapeHtml(hay)}">
                <td>${escapeHtml(name)}<br><code class="us-uid">${escapeHtml(u.id)}</code></td>
                <td>${email ? escapeHtml(email) : '—'}</td>
                <td>${plusCell(u)}</td>
                <td>${escapeHtml(dayLabel(u.firstOpenDate))}</td>
                <td>${escapeHtml(dayLabel(u.lastSeenDate))}</td>
                <td class="td-actions">
                  <button type="button" class="btn btn-ghost btn-sm" data-open-uid="${escapeHtml(u.id)}">Abrir</button>
                  <button type="button" class="btn btn-secondary btn-sm" data-person="${escapeHtml(u.id)}" data-person-name="${escapeHtml(name)}">Ficha</button>
                </td>
              </tr>`;
          }).join('')}
        </tbody>
      </table>
    </div>`;
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

function wireResultActions(root, { onPersonChanged } = {}) {
  root.querySelectorAll('[data-person]').forEach((btn) => {
    btn.addEventListener('click', () => openPersonModal({ uid: btn.dataset.person, name: btn.dataset.personName, onChanged: onPersonChanged }));
  });
  root.querySelectorAll('[data-copy]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(btn.dataset.copy);
        showToast('Copiado');
      } catch {
        showToast(btn.dataset.copy, 'info');
      }
    });
  });
}

export async function renderUsersPage(root) {
  if (getRole() !== 'admin') {
    root.innerHTML = '<div class="card"><p>Só administradores.</p></div>';
    return;
  }
  let term = '';
  let allUsers = [];
  let sort = { key: 'seen', dir: 'desc' };

  root.innerHTML = `
    <div class="ez-page wide">
      <header class="ez-hero">
        <div>
          <h1>Suporte</h1>
          <p class="ez-lead">Todas as contas com Plus, criação e último acesso. Busque por e-mail, uid ou código de passe para a ficha. Só leitura.</p>
        </div>
      </header>
      <form class="ez-toolbar" id="us-form">
        <input type="search" id="us-q" class="ez-search" placeholder="Filtrar lista ou buscar e-mail · uid · ABCD1234" autocomplete="off" />
        <button type="submit" class="btn btn-primary">Buscar ficha</button>
      </form>
      <div id="us-list"><div class="ez-skeleton">Carregando contas…</div></div>
      <div id="us-results"></div>
    </div>`;

  const listEl = root.querySelector('#us-list');
  const out = root.querySelector('#us-results');
  const input = root.querySelector('#us-q');

  function applyFilter() {
    const q = (input?.value || '').trim().toLowerCase();
    listEl.querySelectorAll('#us-table tbody tr').forEach((tr) => {
      const hay = tr.dataset.filter || '';
      tr.hidden = Boolean(q) && !hay.includes(q);
    });
  }

  function renderList() {
    const sorted = sortUsers(allUsers, sort.key, sort.dir);
    listEl.innerHTML = usersTable(sorted, sort);
    wireResultActions(listEl, { onPersonChanged: loadList });
    listEl.querySelectorAll('[data-open-uid]').forEach((btn) => {
      btn.addEventListener('click', () => {
        term = btn.dataset.openUid;
        if (input) input.value = term;
        search();
      });
    });
    listEl.querySelectorAll('th[data-sort]').forEach((th) => {
      th.addEventListener('click', () => {
        const key = th.dataset.sort;
        if (sort.key === key) sort = { key, dir: sort.dir === 'asc' ? 'desc' : 'asc' };
        else sort = { key, dir: key === 'name' || key === 'email' ? 'asc' : 'desc' };
        renderList();
      });
    });
    applyFilter();
  }

  async function loadList() {
    listEl.innerHTML = '<div class="ez-skeleton">Carregando contas…</div>';
    try {
      // Sem orderBy: users não tem campo `order` — listCollection devolveria [].
      allUsers = await listDocs(COL.users);
      renderList();
    } catch (e) {
      listEl.innerHTML = `<p class="ez-hint">Falhou ao listar: ${escapeHtml(e.message || String(e))}</p>`;
    }
  }

  async function search() {
    const q = term.trim();
    if (!q) {
      out.innerHTML = '';
      return;
    }
    out.innerHTML = '<div class="ez-skeleton">Buscando…</div>';
    try {
      const html = [];
      if (q.includes('@')) {
        const users = [
          ...(await listWhere(COL.users, 'email', q)),
          ...(q !== q.toLowerCase() ? await listWhere(COL.users, 'email', q.toLowerCase()) : []),
        ];
        for (const u of users) html.push(userCard(u, await reportsFor(u.id)));
        if (!users.length) html.push('<p class="ez-hint">Nenhuma conta com este e-mail (o app grava o e-mail no primeiro backup).</p>');
      } else {
        const code = q.toUpperCase();
        const [u, g] = await Promise.all([
          getDocById(COL.users, q).catch(() => null),
          GIFT_CODE.test(code) ? getDocById(COL.trailGifts, code).catch(() => null) : null,
        ]);
        if (u) html.push(userCard(u, await reportsFor(u.id)));
        if (g) html.push(giftCard(g));
        if (!u && !g) html.push('<p class="ez-hint">Nada encontrado com este uid ou código.</p>');
      }
      out.innerHTML = html.join('');
      wireResultActions(out, { onPersonChanged: search });
      out.scrollIntoView({ behavior: 'smooth', block: 'start' });
    } catch (e) {
      out.innerHTML = `<p class="ez-hint">Falhou: ${escapeHtml(e.message || String(e))}</p>`;
    }
  }

  root.querySelector('#us-form')?.addEventListener('submit', (e) => {
    e.preventDefault();
    term = input.value;
    search();
  });
  input?.addEventListener('input', applyFilter);

  await loadList();
}
