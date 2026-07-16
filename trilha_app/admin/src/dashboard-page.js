import { COL, countCollection, getCatalogMeta } from './db.js';
import { escapeHtml } from './ui.js';

export async function renderDashboard(root) {
  root.innerHTML = `<div class="page-header"><h1>Início</h1><p class="page-sub">Conteúdo do app Trilha — trilhas, perguntas e estudos</p></div><div class="card"><p>Carregando…</p></div>`;

  const [trails, bank, studies, meta] = await Promise.all([
    countCollection(COL.trails),
    countCollection(COL.bank),
    countCollection(COL.studies),
    getCatalogMeta(),
  ]);

  const updated = meta?.updatedAt?.toDate
    ? meta.updatedAt.toDate().toLocaleString('pt-BR')
    : '—';

  root.innerHTML = `
    <div class="page-header">
      <h1>Início</h1>
      <p class="page-sub">Conteúdo remoto do app — atualize sem publicar nova versão</p>
    </div>
    <div class="stats-grid">
      <div class="stat-card"><div class="stat-icon">🗺️</div><div class="stat-body"><div class="stat-value">${trails}</div><div class="stat-label">Trilhas</div></div></div>
      <div class="stat-card"><div class="stat-icon">❓</div><div class="stat-body"><div class="stat-value">${bank}</div><div class="stat-label">Perguntas (banco)</div></div></div>
      <div class="stat-card"><div class="stat-icon">📖</div><div class="stat-body"><div class="stat-value">${studies}</div><div class="stat-label">Estudos de missão</div></div></div>
      <div class="stat-card"><div class="stat-icon">🔄</div><div class="stat-body"><div class="stat-value">v${meta?.version ?? 0}</div><div class="stat-label">Catálogo · ${escapeHtml(updated)}</div></div></div>
    </div>
    <div class="card" style="margin-top:var(--space-6)">
      <h2 style="margin:0 0 var(--space-3)">Atalhos</h2>
      <div class="btn-row">
        <button type="button" class="btn btn-primary" data-route="trails">Gerenciar trilhas</button>
        <button type="button" class="btn btn-secondary" data-route="bank">Banco de perguntas</button>
        <button type="button" class="btn btn-secondary" data-route="studies">Estudos</button>
        <button type="button" class="btn btn-secondary" data-route="import">Importar JSON local</button>
      </div>
      <p class="hint" style="margin-top:var(--space-4)">
        O app lê <code>content_trails</code>, <code>content_bank_questions</code> e
        <code>content_mission_studies</code> no Firestore. Se estiver offline, usa os assets empacotados.
      </p>
    </div>`;
}
