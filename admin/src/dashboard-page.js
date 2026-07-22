import { COL, countCollection, getCatalogMeta } from './db.js';
import { escapeHtml } from './ui.js';

export async function renderDashboard(root) {
  root.innerHTML = `<div class="ez-page"><div class="ez-skeleton">Carregando…</div></div>`;

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
    <div class="ez-page">
      <header class="ez-hero">
        <div>
          <p class="ez-kicker">Painel Steway</p>
          <h1>Olá — o que vamos publicar hoje?</h1>
          <p class="ez-lead">Tudo que você salva aqui chega no app sem precisar de nova versão na loja.</p>
        </div>
      </header>

      <div class="ez-actions-grid">
        <button type="button" class="ez-action primary" data-route="trails">
          <span class="ez-action-icon">🗺️</span>
          <strong>Editar trilhas</strong>
          <span>Passos e perguntas</span>
          <em>${trails} trilhas</em>
        </button>
        <button type="button" class="ez-action" data-route="bank">
          <span class="ez-action-icon">❓</span>
          <strong>Banco de perguntas</strong>
          <span>Questões reutilizáveis</span>
          <em>${bank} itens</em>
        </button>
        <button type="button" class="ez-action" data-route="studies">
          <span class="ez-action-icon">📖</span>
          <strong>Estudos</strong>
          <span>Textos do preparo</span>
          <em>${studies} estudos</em>
        </button>
        <button type="button" class="ez-action" data-route="import">
          <span class="ez-action-icon">⬆️</span>
          <strong>Importar</strong>
          <span>Enviar JSON local de uma vez</span>
          <em>Catálogo v${meta?.version ?? 0}</em>
        </button>
      </div>

      <div class="ez-panel soft">
        <h2>Como publicar</h2>
        <ol class="ez-howto">
          <li><strong>Crie a trilha</strong> — só o nome (ex.: Êxodo)</li>
          <li><strong>Escreva os passos</strong> — título, texto e versículo</li>
          <li><strong>Adicione as perguntas</strong> — e salve</li>
        </ol>
        <p class="ez-hint">Última atualização do catálogo: ${escapeHtml(updated)}</p>
      </div>
    </div>`;
}
