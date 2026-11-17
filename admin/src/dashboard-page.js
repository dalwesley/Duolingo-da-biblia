/**
 * Início: o que precisa de atenção hoje — relatos abertos, edições do painel
 * que ainda não voltaram para os arquivos locais, Pioneiro e versão do app. O status do conteúdo por trilha roda sob demanda.
 */
import { getFunctions, httpsCallable } from 'firebase/functions';
import { app } from './firebase.js';
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

const moderateUser = httpsCallable(getFunctions(app, 'us-central1'), 'moderateUser');
const DAY_MS = 24 * 3600 * 1000;

const TIER_LABEL = { none: '—', solo: 'Sozinho', pair: 'Companhia', group: 'Grupo' };

function ago(iso) {
  if (!iso) return 'nunca';
  const ms = Date.now() - Date.parse(iso);
  if (ms < 3600 * 1000) return `há ${Math.max(1, Math.round(ms / 60000))} min`;
  if (ms < DAY_MS) return `há ${Math.round(ms / 3600000)} h`;
  return `há ${Math.round(ms / DAY_MS)} dia(s)`;
}

function dmy(iso) {
  if (!iso) return '—';
  return new Date(iso).toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
}

/**
 * Saúde do webhook RevenueCat. O carimbo (`ops/revenuecat`) só existe depois
 * do deploy que o grava; até lá, sem entregas registradas.
 */
function webhookCard(ops) {
  if (!ops) {
    return card('Webhook RevenueCat', '<p class="db-lead">Não consegui ler (a função <code>moderateUser</code> precisa do deploy novo).</p>');
  }
  const w = ops.webhook || {};
  const p = ops.plus || {};
  const okMs = w.lastOkAt ? Date.parse(w.lastOkAt) : 0;
  const newer = (iso) => iso && Date.parse(iso) > okMs;
  let tone = 'ok';
  let verdict = 'Entregando normalmente.';
  if (newer(w.lastUnauthorizedAt)) {
    tone = 'bad';
    verdict = 'Última entrega recusada: o Authorization header do RevenueCat não bate com o segredo.';
  } else if (newer(w.lastErrorAt)) {
    tone = 'bad';
    verdict = `Última entrega falhou ao gravar: ${escapeHtml(w.lastError || 'erro')}.`;
  } else if (!w.received) {
    tone = p.total ? 'warn' : '';
    verdict = 'Nenhuma entrega registrada ainda. Use "Send test event" no RevenueCat para conferir.';
  } else if (p.viaWebhook && Date.now() - okMs > 35 * DAY_MS) {
    tone = 'warn';
    verdict = 'Mais de 35 dias sem evento com assinantes ativos: renovações deveriam ter chegado.';
  }
  const body = `
    <p class="db-lead">${verdict}</p>
    <ul class="db-list">
      <li><span>Última entrega aceita</span><strong>${escapeHtml(ago(w.lastOkAt))}${w.lastType ? ` · ${escapeHtml(w.lastType)}` : ''}${w.lastEnv ? ` <small>${escapeHtml(w.lastEnv.toLowerCase())}</small>` : ''}</strong></li>
      <li><span>Último evento de produção</span><strong>${escapeHtml(ago(w.lastProductionAt))}</strong></li>
      <li><span>Entregas registradas</span><strong>${w.received || 0}</strong></li>
      <li><span>Plus ativos</span><strong>${p.total || 0}${p.trial ? ` · ${p.trial} em teste` : ''}</strong></li>
      ${p.manual ? `<li><span>Ligados à mão (sem RevenueCat)</span><strong>${p.manual}</strong></li>` : ''}
    </ul>`;
  return card('Webhook RevenueCat', body, { tone });
}

/** Advento: quem caminha, provas, dupla/grupo e meses entregues. */
function adventCard(adv) {
  if (!adv) {
    return `<section class="db-card wide"><header><h3>Advento</h3></header><p class="db-lead">Não consegui ler (a função <code>moderateUser</code> precisa do deploy novo).</p></section>`;
  }
  const c = adv.config;
  const people = [...(adv.people || [])].sort((a, b) => b.proven - a.proven || String(a.name).localeCompare(String(b.name), 'pt-BR'));
  const joined = people.filter((p) => p.joined).length;
  const proving = people.filter((p) => p.proven > 0).length;
  const done = people.filter((p) => p.completedAtMs).length;
  const months = people.reduce((n, p) => n + (p.grantedMonths || 0), 0);
  const startMs = Date.parse(`${c.startYmd}T03:00:00Z`);
  const before = Date.now() < startMs;
  const status = before
    ? `Começa ${dmy(new Date(startMs).toISOString())} (em ${Math.ceil((startMs - Date.now()) / DAY_MS)} dia(s)). Duplas e grupos contam pela foto de ${dmy(c.rosterAt)} 23:59; até lá a coluna mostra como está agora.`
    : adv.rosterTaken
      ? `Foto das duplas e grupos tirada ${dmy(adv.rosterTakenAt)}. Prazo ${dmy(c.deadline)}.`
      : `Em andamento · prazo ${dmy(c.deadline)}.`;
  const together = (p) => {
    const parts = [];
    for (const g of p.groups || []) {
      const ok = g.size >= c.groupMin;
      parts.push(`<span class="rv-pill ${ok ? 'ok' : ''} sm" title="${g.proven} de ${g.size} com prova">Grupo ${escapeHtml(g.name || g.code)} · ${g.size}</span>`);
    }
    for (const o of p.pairs || []) {
      parts.push(`<span class="rv-pill sm" title="${o.proven} cena(s) provada(s)">Companhia: ${escapeHtml(o.name || o.uid.slice(0, 6))}</span>`);
    }
    return parts.join(' ') || '<span class="us-muted">sozinho</span>';
  };
  const rows = people.map((p) => {
    const pct = Math.min(100, Math.round((p.proven / c.days) * 100));
    const prize = p.tier !== 'none'
      ? `<span class="rv-pill ok sm">${TIER_LABEL[p.tier]} · ${p.months} mês(es)</span>`
      : `<span class="us-muted" title="Melhor nível possível hoje">até ${TIER_LABEL[p.potential]} · ${c.months[p.potential]} mês(es)</span>`;
    const rej = p.rejects ? `<span class="rv-pill warn sm" title="Último motivo: ${escapeHtml(p.lastReject || '')}">${p.rejects} recusa(s)</span>` : '';
    return `<tr>
      <td>${escapeHtml(p.name || '(sem nome)')}${p.joined ? '' : ' <small class="us-muted">(fora da caminhada)</small>'}<br><code class="us-uid">${escapeHtml(p.uid)}</code></td>
      <td><div class="db-meter adv-meter" title="${p.proven} de ${c.days}"><span style="width:${pct}%"></span></div><small>${p.proven}/${c.days}${p.completedAtMs ? ' · concluiu' : ''}</small> ${rej}</td>
      <td>${together(p)}</td>
      <td>${prize}</td>
    </tr>`;
  }).join('');
  return `
    <section class="db-card wide${done ? ' ok' : ''}" id="advent-card">
      <header>
        <h3>Advento <small class="db-sub">${escapeHtml(c.id)}</small></h3>
        <span class="db-sub">${joined} na caminhada · ${proving} com prova · ${done} concluíram · ${months} mês(es) entregue(s)</span>
      </header>
      <p class="db-lead">${status} Prêmio: sozinho ${c.months.solo}, Companhia ${c.months.pair}, grupo de ${c.groupMin}+ ${c.months.group} mês(es).</p>
      ${people.length
        ? `<div class="table-wrap"><table class="data-table">
            <thead><tr><th>Peregrino</th><th>Cenas provadas</th><th>Junto com</th><th>Prêmio</th></tr></thead>
            <tbody>${rows}</tbody>
          </table></div>`
        : '<p class="ez-hint">Ninguém entrou na caminhada ainda.</p>'}
    </section>`;
}

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

  const callData = (input) => moderateUser(input).then((r) => r.data);
  const [meta, release, reportCounts, editedQ, editedS, deletes, pioneer, rc, trashAll, ops, adv] = await Promise.all([
    safe(getCatalogMeta()),
    safe(getAppRelease()),
    Promise.all(REPORT_QUEUES.map((r) => safe(countWhere(r.col, 'status', 'open'), null))),
    safe(listPanelEdits(COL.bank), []),
    safe(listPanelEdits(COL.studies), []),
    safe(getDocById(COL.meta, PANEL_DELETES_DOC)),
    safe(getDocById(COL.stats, 'pioneer')),
    safe(loadRemoteConfig(), null),
    safe(listTrash(), []),
    isAdmin ? safe(callData({ action: 'ops' })) : null,
    isAdmin ? safe(callData({ action: 'advent' })) : null,
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
        ${isAdmin ? webhookCard(ops) : ''}
      </div>

      ${isAdmin ? adventCard(adv) : ''}

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
