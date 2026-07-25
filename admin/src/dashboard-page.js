import {
  COL,
  countCollection,
  getAppRelease,
  getCatalogMeta,
  saveAppRelease,
} from './db.js';
import { escapeHtml, showToast } from './ui.js';

export async function renderDashboard(root) {
  root.innerHTML = `<div class="ez-page"><div class="ez-skeleton">Carregando…</div></div>`;

  const [trails, bank, studies, meta, release] = await Promise.all([
    countCollection(COL.trails),
    countCollection(COL.bank),
    countCollection(COL.studies),
    getCatalogMeta(),
    getAppRelease(),
  ]);

  const updated = meta?.updatedAt?.toDate
    ? meta.updatedAt.toDate().toLocaleString('pt-BR')
    : '—';

  const r = release || {};
  const enabled = r.enabled !== false;

  root.innerHTML = `
    <div class="ez-page">
      <header class="ez-hero">
        <div>
          <p class="ez-kicker">Painel STWAY</p>
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

      <div class="ez-panel">
        <h2>Versão do app (lojas)</h2>
        <p class="ez-hint">Quando subir um build novo, aumente <code>latestBuild</code>. Use <code>minBuild</code> só para forçar update.</p>
        <form id="app-release-form" class="ez-form" style="margin-top:12px;display:grid;gap:10px;max-width:520px">
          <label>
            <span>Ativo</span>
            <input type="checkbox" name="enabled" ${enabled ? 'checked' : ''} />
          </label>
          <label>
            <span>Versão (ex. 1.0.3)</span>
            <input name="latestVersion" value="${escapeHtml(r.latestVersion || '')}" placeholder="1.0.3" />
          </label>
          <label>
            <span>Build mais recente (versionCode)</span>
            <input name="latestBuild" type="number" min="1" value="${escapeHtml(String(r.latestBuild ?? ''))}" placeholder="4" />
          </label>
          <label>
            <span>Build mínimo (force update)</span>
            <input name="minBuild" type="number" min="0" value="${escapeHtml(String(r.minBuild ?? 0))}" placeholder="1" />
          </label>
          <label>
            <span>URL Play Store</span>
            <input name="androidStoreUrl" value="${escapeHtml(r.androidStoreUrl || 'https://play.google.com/store/apps/details?id=com.trilha.trilha_app')}" />
          </label>
          <label>
            <span>URL App Store</span>
            <input name="iosStoreUrl" value="${escapeHtml(r.iosStoreUrl || '')}" placeholder="https://apps.apple.com/app/id…" />
          </label>
          <label>
            <span>Mensagem no app</span>
            <textarea name="message" rows="2">${escapeHtml(r.message || '')}</textarea>
          </label>
          <button type="submit" class="btn btn-primary">Salvar versão</button>
        </form>
      </div>
    </div>`;

  root.querySelector('#app-release-form')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const form = e.currentTarget;
    const fd = new FormData(form);
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
