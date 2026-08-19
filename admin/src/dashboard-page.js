import {
  COL,
  countCollection,
  getAppRelease,
  getCatalogMeta,
  saveAppRelease,
} from './db.js';
import { escapeHtml, showToast } from './ui.js';

export async function renderDashboard(root, navigate) {
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
          <h1>Cadastre perguntas em minutos</h1>
          <p class="ez-lead">Trilha → passo com verso → pergunta. Tudo chega no app sem nova versão na loja.</p>
        </div>
        <button type="button" class="btn btn-primary btn-lg" data-route="bank">+ Nova pergunta</button>
      </header>

      <div class="ez-flow-card">
        <ol class="ez-flow-steps">
          <li>
            <span class="ez-flow-n">1</span>
            <div>
              <strong>Abra a trilha</strong>
              <p>Crie ou escolha uma trilha e escreva o passo com título e verso.</p>
              <button type="button" class="btn btn-secondary btn-sm" data-route="trails">Ir para trilhas</button>
            </div>
          </li>
          <li>
            <span class="ez-flow-n">2</span>
            <div>
              <strong>Adicione a pergunta</strong>
              <p>Toque no tipo (Quiz, V/F, Complete) ou use “Gerar do verso”.</p>
              <button type="button" class="btn btn-primary btn-sm" data-route="bank">Cadastrar pergunta</button>
            </div>
          </li>
          <li>
            <span class="ez-flow-n">3</span>
            <div>
              <strong>Revise e salve</strong>
              <p>A miniatura mostra como fica no celular. Ajuste e publique.</p>
            </div>
          </li>
        </ol>
      </div>

      <div class="ez-actions-grid">
        <button type="button" class="ez-action primary" data-route="trails">
          <span class="ez-action-icon">🗺️</span>
          <strong>Trilhas</strong>
          <span>Passos e versos âncora</span>
          <em>${trails} trilhas</em>
        </button>
        <button type="button" class="ez-action" data-route="bank">
          <span class="ez-action-icon">❓</span>
          <strong>Perguntas</strong>
          <span>Quiz, V/F, complete…</span>
          <em>${bank} cadastradas</em>
        </button>
        <button type="button" class="ez-action" data-route="studies">
          <span class="ez-action-icon">📖</span>
          <strong>Estudos</strong>
          <span>Textos do preparo</span>
          <em>${studies} estudos</em>
        </button>
        <button type="button" class="ez-action" data-route="reports">
          <span class="ez-action-icon">⚑</span>
          <strong>Relatos</strong>
          <span>Revisão da comunidade</span>
          <em>Erros reportados</em>
        </button>
        <button type="button" class="ez-action" data-route="import">
          <span class="ez-action-icon">↕️</span>
          <strong>Importar</strong>
          <span>Backup em lote</span>
          <em>Catálogo v${meta?.version ?? 0}</em>
        </button>
      </div>

      <p class="ez-foot-hint">Última atualização do catálogo: ${escapeHtml(updated)}</p>

      <details class="ez-panel soft ez-advanced-panel">
        <summary>Versão do app (lojas)</summary>
        <p class="ez-hint">Quando subir build novo, aumente <code>latestBuild</code>. Use <code>minBuild</code> só para forçar update.</p>
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
      </details>
    </div>`;

  root.querySelectorAll('[data-route]').forEach((a) => {
    a.addEventListener('click', (e) => {
      e.preventDefault();
      navigate?.(a.dataset.route);
    });
  });

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
