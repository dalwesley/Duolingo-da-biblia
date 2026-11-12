/**
 * Funil (só admin): de conta a assinante, retenção D1/D7/D30 por coorte
 * semanal e por trilha de entrada. Lê `users` inteiro e calcula no
 * navegador — serve enquanto a base é pequena (alguns milhares de contas).
 * Cálculo em funnel-stats.js.
 */
import { COL, listDocs } from './db.js';
import { computeFunnel, localKey, WINDOWS } from './funnel-stats.js';
import { escapeHtml, showToast } from './ui.js';

let cache = null;
let includeTesters = false;
let since = '';

function pct(kept, eligible) {
  if (!eligible) return '—';
  return `${Math.round((kept / eligible) * 100)}%`;
}

/** Pílula colorida pela meta: verde ≥ boa, amarela ≥ ruim, vermelha abaixo. */
function retPill({ kept, eligible }, good, bad) {
  if (!eligible) return '<span class="rv-pill sm">—</span>';
  const r = kept / eligible;
  const tone = r >= good ? 'ok' : r >= bad ? 'warn' : 'bad';
  return `<span class="rv-pill sm ${tone}" title="${kept} de ${eligible}">${pct(kept, eligible)}</span>`;
}

// Metas do plano de 90 dias (nov/2026).
const TARGETS = { d1: [0.4, 0.25], w2: [0.2, 0.1], d30: [0.12, 0.06] };

function funnelBars(steps) {
  const top = steps[0]?.n || 1;
  return `<ol class="fn-bars">
    ${steps.map((s, i) => {
      const prev = i ? steps[i - 1].n : null;
      const conv = prev ? ` <small>${pct(s.n, prev)} do passo anterior</small>` : '';
      return `<li>
        <div class="fn-bar-label"><span>${escapeHtml(s.label)}${s.hint ? ` <small>· ${escapeHtml(s.hint)}</small>` : ''}</span><strong>${s.n}</strong></div>
        <div class="fn-bar"><span style="width:${Math.max(1, Math.round((s.n / top) * 100))}%"></span></div>
        ${conv ? `<div class="fn-conv">${conv}</div>` : ''}
      </li>`;
    }).join('')}
  </ol>`;
}

function dailyChart(daily) {
  const max = Math.max(1, ...daily.map((d) => Math.max(d.active, d.signups)));
  return `<div class="fn-daily" role="img" aria-label="Atividade dos últimos 30 dias">
    ${daily.map((d) => `
      <div class="fn-day" title="${d.day}: ${d.active} ativos · ${d.signups} contas novas · ${d.firsts} 1ª cena">
        <span class="fn-day-active" style="height:${Math.round((d.active / max) * 100)}%"></span>
        <span class="fn-day-new" style="height:${Math.round((d.signups / max) * 100)}%"></span>
      </div>`).join('')}
  </div>
  <div class="fn-legend"><span><i class="fn-dot active"></i>ativos no dia</span><span><i class="fn-dot new"></i>contas novas</span><span>${escapeHtml(daily[0].day)} → ${escapeHtml(daily[daily.length - 1].day)}</span></div>`;
}

function render(root, f) {
  const r = f.retention;
  const kpi = (label, value, hint) => `<div class="fn-kpi"><span>${escapeHtml(label)}</span><strong>${value}</strong>${hint ? `<small>${escapeHtml(hint)}</small>` : ''}</div>`;

  root.innerHTML = `
    <div class="ez-page wide">
      <header class="ez-hero db-hero">
        <div>
          <h1>Funil</h1>
          <p class="ez-lead">De conta a assinante. Retenção conta a partir da 1ª cena.</p>
        </div>
        <div class="ez-hero-actions">
          <label class="fn-toggle"><input type="checkbox" id="fn-testers" ${includeTesters ? 'checked' : ''}/> Incluir testers${f.testersHidden ? ` (${f.testersHidden} ocultos)` : ''}</label>
          <label class="fn-toggle">Desde <input type="date" id="fn-since" value="${escapeHtml(since)}"/></label>
          <button type="button" class="btn btn-secondary" id="fn-reload">Recarregar</button>
        </div>
      </header>

      <div class="fn-kpis">
        ${kpi('Ativos hoje', f.active.dau)}
        ${kpi('Ativos 7 dias', f.active.wau)}
        ${kpi('Ativos 30 dias', f.active.mau)}
        ${WINDOWS.map((w) => kpi(`Retenção ${w.label}`, retPill(r[w.key], ...TARGETS[w.key]), `${w.hint} · ${r[w.key].kept}/${r[w.key].eligible}`)).join('')}
        ${kpi('Norte: D30 de quem fez 7+', retPill(f.north, ...TARGETS.d30), `${f.north.kept}/${f.north.eligible} com idade para medir`)}
      </div>

      <div class="db-grid two">
        <section class="db-card">
          <header><h3>Funil</h3></header>
          ${funnelBars(f.steps)}
        </section>
        <section class="db-card">
          <header><h3>Peregrino+</h3></header>
          <ul class="db-list">
            <li><span>Em teste grátis</span><strong>${f.plus.trial}</strong></li>
            <li><span>Pagando</span><strong>${f.plus.paid}</strong></li>
            <li><span>…dos quais Pioneiro</span><strong>${f.plus.pioneer}</strong></li>
            <li><span>Pagando ÷ fizeram 7+ cenas</span><strong>${pct(f.plus.paid, f.steps[3].n)}</strong></li>
          </ul>
          <p class="db-lead" style="margin-top:12px">Conversão do teste em pago: acompanhe no RevenueCat (o doc só guarda o estado atual).</p>
          <header style="margin-top:16px"><h3>Últimos 30 dias</h3></header>
          ${dailyChart(f.daily)}
        </section>
      </div>

      <section class="db-card wide">
        <header><h3>Coortes semanais</h3><small class="db-sub">semana da 1ª cena · passe o mouse para ver os números</small></header>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>Semana</th><th>Pessoas</th>${WINDOWS.map((w) => `<th title="${escapeHtml(w.hint)}">${w.label}</th>`).join('')}<th>7+ cenas</th><th>Plus</th></tr></thead>
            <tbody>
              ${f.cohorts.length ? f.cohorts.map((c) => `
                <tr>
                  <td>${escapeHtml(c.week)}</td>
                  <td>${c.n}</td>
                  ${WINDOWS.map((w) => `<td>${retPill(c[w.key], ...TARGETS[w.key])}</td>`).join('')}
                  <td>${c.committed} <small>(${pct(c.committed, c.n)})</small></td>
                  <td>${c.plus}</td>
                </tr>`).join('') : '<tr><td colspan="7">Ninguém fez cena ainda neste filtro.</td></tr>'}
            </tbody>
          </table>
        </div>
      </section>

      <section class="db-card wide">
        <header><h3>Trilha da 1ª cena</h3><small class="db-sub">qual porta segura mais gente</small></header>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>Trilha</th><th>Pessoas</th><th>Voltaram em outro dia</th><th>D7</th></tr></thead>
            <tbody>
              ${f.entryTrails.map((t) => `
                <tr>
                  <td><code>${escapeHtml(t.trail)}</code></td>
                  <td>${t.n}</td>
                  <td>${t.returned} <small>(${pct(t.returned, t.n)})</small></td>
                  <td>${retPill(t.w2, ...TARGETS.w2)}</td>
                </tr>`).join('')}
            </tbody>
          </table>
        </div>
      </section>

      <p class="ez-hint">Fonte: <code>users/{uid}</code> (${f.total} contas). Dias são o dia local do aparelho. <code>playDates</code> guarda só os últimos 120 dias. Quem fez a 1ª cena sem conta e não entrou não aparece aqui — esse topo do funil está no Analytics (<code>guest_*</code>).</p>
    </div>`;

  root.querySelector('#fn-testers')?.addEventListener('change', (e) => {
    includeTesters = e.target.checked;
    draw(root);
  });
  root.querySelector('#fn-since')?.addEventListener('change', (e) => {
    since = e.target.value || '';
    draw(root);
  });
  root.querySelector('#fn-reload')?.addEventListener('click', () => {
    cache = null;
    renderFunnelPage(root);
  });
}

function draw(root) {
  render(root, computeFunnel(cache, { today: localKey(new Date()), includeTesters, since }));
}

export async function renderFunnelPage(root) {
  root.innerHTML = `<div class="ez-page wide"><div class="ez-skeleton">Lendo contas…</div></div>`;
  try {
    if (!cache) cache = await listDocs(COL.users);
    draw(root);
  } catch (e) {
    console.error(e);
    root.innerHTML = `<div class="card"><p>Falhou ao ler contas: ${escapeHtml(e.message || String(e))}</p></div>`;
    showToast(e.message || 'Erro', 'error');
  }
}
