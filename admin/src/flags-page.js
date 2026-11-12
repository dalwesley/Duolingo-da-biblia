/**
 * Flags: valores do Remote Config que o app lê. Só leitura — mudar é no Console.
 */
import { loadRemoteConfig, RC_CONSOLE_URL, RC_GROUPS, rcValue } from './remote-config.js';
import { escapeHtml } from './ui.js';

export async function renderFlagsPage(root) {
  root.innerHTML = `<div class="ez-page wide"><div class="ez-skeleton">Lendo o Remote Config…</div></div>`;
  let rc = null;
  let error = '';
  try {
    rc = await loadRemoteConfig();
  } catch (e) {
    error = e.message || String(e);
  }

  root.innerHTML = `
    <div class="ez-page wide">
      <header class="ez-hero db-hero">
        <div>
          <h1>Flags</h1>
          <p class="ez-lead">Remote Config do app</p>
        </div>
        <div class="ez-hero-actions">
          <a class="btn btn-secondary" href="${escapeHtml(RC_CONSOLE_URL)}" target="_blank" rel="noopener">Mudar no Console ↗</a>
        </div>
      </header>
      ${rc
        ? `<div class="db-grid two">
            ${RC_GROUPS.map((g) => `
              <section class="db-card">
                <header><h3>${escapeHtml(g.title)}</h3></header>
                <ul class="db-list">
                  ${g.keys.map((k) => {
                    const v = rcValue(rc, k);
                    return `<li><span>${escapeHtml(k.label)}<br><code>${escapeHtml(k.key)}</code></span><strong class="${v.on === true ? 'on' : v.on === false ? 'off' : ''}">${escapeHtml(v.text)}</strong></li>`;
                  }).join('')}
                </ul>
              </section>`).join('')}
          </div>
          <p class="ez-hint">Valor do template sem condição de plataforma. Condições por iOS/Android só aparecem no Console.</p>`
        : `<div class="db-card wide"><p class="db-lead">Remote Config indisponível neste navegador${error ? `: ${escapeHtml(error)}` : ''}.</p></div>`}
    </div>`;
}
