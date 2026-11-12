/**
 * Início: o que precisa de atenção hoje — relatos abertos, edições do painel
 * que ainda não voltaram para os arquivos locais, Pioneiro e versão do app. O status do conteúdo por trilha roda sob demanda.
 */
import { loadRemoteConfig, rcValue } from './remote-config.js';
import {
  COL,
  countWhere,
  formatDate,
  getAppRelease,
  getCatalogMeta,
  getDocById,
  listCollection,
  listPanelEdits,
  listWhere,
  PANEL_DELETES_DOC,
  saveAppRelease,
  listTrash,
  purgeExpiredTrash,
  purgeFromTrash,
  restoreFromTrash,
  TRASH_DAYS,
} from './db.js';
import { isV3Question } from './v3-check.js';
import { getRole } from './roles.js';
import { confirmAction, escapeHtml, setLoading, showToast } from './ui.js';
import { gestureMeta } from './content-preview.js';
import { contentHash } from './content-page.js';
import { openReportsTab } from './reports-page.js';

const REPORT_QUEUES = [
  { col: COL.userReports, label: 'Denúncias', tab: 'people' },
  { col: COL.appReports, label: 'Problemas do app', tab: 'app' },
  { col: COL.reports, label: 'Erros em perguntas', tab: 'questions' },
  { col: COL.suggestions, label: 'Sugestões de trilha', tab: 'trails' },
  { col: COL.authorSuggestions, label: 'Autores', tab: 'authors' },
];

async function safe(promise, fallback = null) {
  try {
    return await promise;
  } catch (e) {
    console.warn(e);
    return fallback;
  }
}

function card(title, body, { tone = '', action = '', span = false } = {}) {
  return `<section class="db-card ${tone} ${span ? 'span-2' : ''}">
    <header><h3>${title}</h3>${action}</header>
    ${body}
  </section>`;
}

export async function renderDashboard(root, navigate) {
  root.innerHTML = `<div class="ez-page wide"><div class="ez-skeleton">Carregando…</div></div>`;
  const isAdmin = getRole() === 'admin';

  const [meta, release, reportCounts, editedQ, editedS, deletes, pioneer, rc, trashAll] = await Promise.all([
    safe(getCatalogMeta()),
    safe(getAppRelease()),
    Promise.all(REPORT_QUEUES.map((r) => safe(countWhere(r.col, 'status', 'open'), null))),
    safe(listPanelEdits(COL.bank), []),
    safe(listPanelEdits(COL.studies), []),
    safe(getDocById(COL.meta, PANEL_DELETES_DOC)),
    safe(getDocById(COL.stats, 'pioneer')),
    safe(loadRemoteConfig(), null),
    safe(listTrash(), []),
  ]);

  // Edições do painel agrupadas por trilha.
  const byTrail = new Map();
  const add = (trail, kind, id) => {
    const e = byTrail.get(trail) || { questions: [], deletes: [] };
    e[kind].push(id);
    byTrail.set(trail, e);
  };
  for (const q of editedQ || []) add(q.trail || '(sem trilha)', 'questions', q.id);
  for (const [id, v] of Object.entries(deletes || {})) {
    if (id === 'id' || !v || typeof v !== 'object') continue;
    add(v.trail || '(sem trilha)', 'deletes', id);
  }
  const pendingTotal = [...byTrail.values()].reduce((n, e) => n + e.questions.length + e.deletes.length, 0) + (editedS?.length || 0);

  const openReports = reportCounts.reduce((n, c) => n + (c || 0), 0);
  const r = release || {};

  const reportsBody = `
    <ul class="db-list">
      ${REPORT_QUEUES.map((q, i) => `<li><a href="#" class="db-link" data-reports-tab="${q.tab}">${escapeHtml(q.label)}</a><strong>${reportCounts[i] ?? '—'}</strong></li>`).join('')}
    </ul>`;

  const pendingBody = pendingTotal
    ? `<p class="db-lead">Edições feitas aqui que o próximo <code>v3:publish</code> apagaria. Traga para os arquivos locais:</p>
       <ul class="db-list">
         ${[...byTrail].sort().map(([trail, e]) => `
           <li>
             <span><strong>${escapeHtml(trail)}</strong> · ${e.questions.length} editada(s)${e.deletes.length ? `, ${e.deletes.length} excluída(s)` : ''}</span>
             <button type="button" class="btn btn-ghost btn-sm" data-copy="npm run v3:pull -- --trail ${escapeHtml(trail)} --apply">Copiar comando</button>
           </li>`).join('')}
         ${editedS?.length ? `<li><span>Estudos editados: ${editedS.map((s) => `<code>${escapeHtml(s.id)}</code>`).join(' ')}</span></li>` : ''}
       </ul>`
    : '<p class="db-lead">Nada pendente: o Firestore bate com os arquivos locais.</p>';

  const cap = Number(pioneer?.cap) || 200;
  const count = Number(pioneer?.count) || 0;
  const reserved = rc ? Number(rc.pioneer_reserved?.asNumber?.() || 0) : 0;
  const taken = Math.min(cap, count + reserved);
  const pioneerBody = pioneer
    ? `<div class="db-meter" role="img" aria-label="${taken} de ${cap} vagas">
         <span style="width:${Math.round((taken / cap) * 100)}%"></span>
       </div>
       <ul class="db-list">
         <li><span>Compras contadas</span><strong>${count}</strong></li>
         <li><span>Reservadas (Remote Config)</span><strong>${rc ? reserved : '—'}</strong></li>
         <li><span>Vagas restantes</span><strong>${Math.max(0, cap - taken)} de ${cap}</strong></li>
         <li><span>Até</span><strong>${escapeHtml(rc ? rcValue(rc, { key: 'pioneer_until', kind: 'date' }).text : '—')}</strong></li>
       </ul>`
    : '<p class="db-lead">Sem compras do Pioneiro ainda (<code>stats/pioneer</code> não existe).</p>';

  // Lixeira: some sozinha depois de TRASH_DAYS (limpa ao abrir o Hoje).
  const expired = await safe(purgeExpiredTrash(trashAll), 0);
  const trash = (trashAll || []).filter((x) => x.daysLeft > 0);
  const trashBody = trash.length
    ? `<p class="db-lead">Perguntas excluídas saem do app na hora e ficam aqui ${TRASH_DAYS} dias.${expired ? ` ${expired} antiga(s) saíram agora.` : ''}</p>
       <ul class="db-list db-trash">
         ${trash.slice(0, 8).map((x) => `
           <li>
             <span><strong>${escapeHtml(x.trail)}</strong> · ${escapeHtml(x.section)} · ${escapeHtml(gestureMeta(x.data?.type).label)}<br><small>${escapeHtml((x.data?.question || x.id).slice(0, 80))} · some em ${x.daysLeft} dia(s)</small></span>
             <span class="db-actions">
               <button type="button" class="btn btn-secondary btn-sm" data-restore="${escapeHtml(x.id)}">Restaurar</button>
               <button type="button" class="btn btn-ghost btn-sm" data-purge="${escapeHtml(x.id)}" title="Excluir de vez">✕</button>
             </span>
           </li>`).join('')}
       </ul>
       ${trash.length > 8 ? `<p class="ez-hint">…e mais ${trash.length - 8}. Cada cena em Explorar mostra a lixeira dela.</p>` : ''}`
    : `<p class="db-lead">Vazia. Pergunta excluída fica aqui ${TRASH_DAYS} dias antes de sumir.</p>`;

  root.innerHTML = `
    <div class="ez-page wide">
      <header class="ez-hero db-hero">
        <div>
          <h1>Hoje</h1>
          <p class="ez-lead">Pendências e lançamento</p>
        </div>
        <div class="ez-hero-actions">
          <button type="button" class="btn btn-primary" data-route="content">Explorar</button>
          <button type="button" class="btn btn-secondary" data-route="reports">Relatos</button>
        </div>
      </header>

      <div class="db-grid">
        ${card('Relatos abertos', reportsBody, {
          tone: openReports ? 'warn' : '',
          action: `<button type="button" class="btn btn-ghost btn-sm" data-route="reports">${openReports} abertos →</button>`,
        })}
        ${card('Edições do painel', pendingBody, { tone: pendingTotal ? 'warn' : 'ok' })}
        ${card('Pioneiro', pioneerBody)}
      </div>

      <section class="db-card wide" id="content-status">
        <header>
          <h3>Conteúdo por trilha</h3>
          <button type="button" class="btn btn-secondary btn-sm" id="btn-content-status">Ver status</button>
        </header>
        <p class="db-lead">Perguntas por trilha no Firestore e se o banco é V3 ou V2. Conta no servidor (não baixa o banco).</p>
        <div id="content-status-body"></div>
      </section>

      ${isAdmin ? `
      <details class="ez-panel soft ez-advanced-panel">
        <summary>Versão do app (lojas) · ${escapeHtml(r.latestVersion || '—')} build ${escapeHtml(String(r.latestBuild ?? '—'))}${r.minBuild ? ` · mínimo ${escapeHtml(String(r.minBuild))}` : ''} · catálogo v${escapeHtml(String(meta?.version ?? 0))}</summary>
        <p class="ez-hint">Quando subir build novo, aumente <code>latestBuild</code>. Use <code>minBuild</code> só para forçar update.</p>
        <p class="ez-hint">Catálogo de conteúdo: <strong>v${escapeHtml(String(meta?.version ?? 0))}</strong> · atualizado ${escapeHtml(formatDate(meta?.updatedAt))}. Sobe sozinho a cada edição; o app baixa o conteúdo de novo quando ele muda.</p>
        <form id="app-release-form" class="ez-form" style="margin-top:12px;display:grid;gap:10px;max-width:520px">
          <label><span>Ativo</span><input type="checkbox" name="enabled" ${r.enabled !== false ? 'checked' : ''} /></label>
          <label><span>Versão (ex. 1.0.3)</span><input name="latestVersion" value="${escapeHtml(r.latestVersion || '')}" placeholder="1.0.3" /></label>
          <label><span>Build mais recente (versionCode)</span><input name="latestBuild" type="number" min="1" value="${escapeHtml(String(r.latestBuild ?? ''))}" /></label>
          <label><span>Build mínimo (force update)</span><input name="minBuild" type="number" min="0" value="${escapeHtml(String(r.minBuild ?? 0))}" /></label>
          <label><span>URL Play Store</span><input name="androidStoreUrl" value="${escapeHtml(r.androidStoreUrl || 'https://play.google.com/store/apps/details?id=com.trilha.trilha_app')}" /></label>
          <label><span>URL App Store</span><input name="iosStoreUrl" value="${escapeHtml(r.iosStoreUrl || '')}" placeholder="https://apps.apple.com/app/id…" /></label>
          <label><span>Mensagem no app</span><textarea name="message" rows="2">${escapeHtml(r.message || '')}</textarea></label>
          <button type="submit" class="btn btn-primary">Salvar versão</button>
        </form>
      </details>` : ''}
      ${card(`Lixeira <small class="db-sub">${trash.length}</small>`, trashBody, { tone: trash.length ? 'warn wide' : 'wide' })}
    </div>`;

  root.querySelectorAll('[data-route]').forEach((a) => {
    a.addEventListener('click', (e) => {
      e.preventDefault();
      navigate?.(a.dataset.route);
    });
  });

  root.querySelectorAll('[data-reports-tab]').forEach((a) => {
    a.addEventListener('click', (e) => {
      e.preventDefault();
      openReportsTab(a.dataset.reportsTab);
      navigate?.('reports');
    });
  });
  root.querySelectorAll('[data-restore]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const item = trash.find((x) => x.id === btn.dataset.restore);
      if (!item) return;
      setLoading(true);
      try {
        await restoreFromTrash(item);
        showToast('Pergunta restaurada — já vale no app');
        renderDashboard(root, navigate);
      } catch (e) {
        showToast(e.message || 'Erro', 'error');
      } finally {
        setLoading(false);
      }
    });
  });
  root.querySelectorAll('[data-purge]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      if (!(await confirmAction(`Excluir ${btn.dataset.purge} de vez? Não dá para restaurar depois.`))) return;
      await purgeFromTrash(btn.dataset.purge);
      renderDashboard(root, navigate);
    });
  });

  root.querySelectorAll('[data-copy]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(btn.dataset.copy);
        showToast('Comando copiado');
      } catch {
        showToast(btn.dataset.copy, 'info');
      }
    });
  });

  root.querySelector('#btn-content-status')?.addEventListener('click', async (e) => {
    const btn = e.currentTarget;
    const body = root.querySelector('#content-status-body');
    btn.disabled = true;
    body.innerHTML = '<p class="ez-hint">Contando…</p>';
    try {
      const trails = await listCollection(COL.trails);
      trails.sort((a, b) => String(a.title || a.id).localeCompare(String(b.title || b.id), 'pt-BR'));
      const rows = await Promise.all(trails.map(async (t) => {
        const id = t.slug || t.id;
        const [n, sample] = await Promise.all([
          safe(countWhere(COL.bank, 'trail', id), 0),
          safe(listWhere(COL.bank, 'trail', id, 1), []),
        ]);
        const scenes = (t.modules || []).reduce((k, m) => k + (m.missions || []).length, 0);
        return { id, title: t.title || id, soon: Boolean(t.comingSoon), n, scenes, v3: sample[0] ? isV3Question(sample[0]) : null };
      }));
      const v3 = rows.filter((x) => x.v3).length;
      const v2 = rows.filter((x) => x.v3 === false).length;
      const empty = rows.filter((x) => !x.n).length;
      body.innerHTML = `
        <p class="db-lead">${rows.length} trilhas · ${v3} V3 · ${v2} V2 · ${empty} sem perguntas</p>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>Trilha</th><th>Cenas</th><th>Perguntas</th><th>Banco</th><th></th></tr></thead>
            <tbody>
              ${rows.map((x) => `
                <tr>
                  <td>${escapeHtml(x.title)} <code>${escapeHtml(x.id)}</code>${x.soon ? ' <span class="badge badge-muted">em breve</span>' : ''}</td>
                  <td>${x.scenes}</td>
                  <td>${x.n}</td>
                  <td>${x.v3 === null ? '—' : x.v3 ? '<span class="rv-pill ok sm">V3</span>' : '<span class="rv-pill warn sm">V2</span>'}</td>
                  <td><button type="button" class="btn btn-ghost btn-sm" data-open-trail="${escapeHtml(x.id)}">Revisar</button></td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>`;
      body.querySelectorAll('[data-open-trail]').forEach((b) => {
        b.addEventListener('click', () => {
          history.replaceState(null, '', contentHash(b.dataset.openTrail));
          navigate?.('content');
        });
      });
    } catch (err) {
      body.innerHTML = `<p class="ez-hint">Falhou: ${escapeHtml(err.message || String(err))}</p>`;
    } finally {
      btn.disabled = false;
    }
  });

  root.querySelector('#app-release-form')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    try {
      await saveAppRelease({
        enabled: fd.get('enabled') === 'on',
        latestVersion: fd.get('latestVersion'),
        latestBuild: fd.get('latestBuild'),
        minBuild: fd.get('minBuild'),
        androidStoreUrl: fd.get('androidStoreUrl'),
        iosStoreUrl: fd.get('iosStoreUrl'),
        message: fd.get('message'),
      });
      showToast('Versão do app publicada');
    } catch (err) {
      showToast(err?.message || 'Falha ao salvar', 'error');
    }
  });
}
