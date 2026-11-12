import { didAnonFail, getAnonFailMessage, getUser, isAuthenticated, logOut, mapAuthError, signIn, signInWithGoogle, skipAuth, watchAuth } from './auth.js';
import { renderDashboard } from './dashboard-page.js';
import { renderFunnelPage } from './funnel-page.js';
import { renderBankPage } from './bank-page.js';
import { renderImportPage } from './import-page.js';
import { renderReportsPage } from './reports-page.js';
import { renderStudiesPage } from './studies-page.js';
import { renderUsersPage } from './users-page.js';
import { renderFlagsPage } from './flags-page.js';
import { renderContentPage } from './content-page.js';
import { renderTrailEditor, renderTrailsList } from './trails-page.js';
import {
  canAccessRoute,
  getProfile,
  getProfileLoadError,
  getRole,
  loadUserRole,
  roleLabel,
} from './roles.js';
import { initTheme, themeToggleIcon, toggleTheme } from './theme-admin.js';
import { formatDate, getCatalogMeta } from './db.js';
import { escapeHtml, setLoading, showToast } from './ui.js';

const app = document.getElementById('app');
// #explorar/… abre direto na tela Explorar (link de uma cena).
let route = (location.hash || '').startsWith('#explorar') ? 'content' : 'dashboard';
let sidebarOpen = false;
let catalogLine = '';

/** “Catálogo atualizado …” no rodapé da barra lateral. */
async function refreshCatalogLine() {
  try {
    const meta = await getCatalogMeta();
    catalogLine = meta?.updatedAt ? `Catálogo atualizado ${formatDate(meta.updatedAt)}` : '';
  } catch {
    catalogLine = '';
  }
  const el = document.getElementById('sidebar-catalog');
  if (el) el.textContent = catalogLine;
}

initTheme();

const NAV = [
  { route: 'dashboard', label: 'Hoje', icon: '🏠', hint: 'Pendências e lançamento' },
  { route: 'funnel', label: 'Funil', icon: '📈', hint: 'Retenção e assinantes' },
  { route: 'content', label: 'Explorar', icon: '🧭', hint: 'Trilhas, cenas, estudos e perguntas' },
  { route: 'reports', label: 'Relatos', icon: '⚑', hint: 'Denúncias, erros e sugestões' },
  { route: 'users', label: 'Suporte', icon: '👤', hint: 'Conta, Plus e passes' },
  { route: 'flags', label: 'Flags', icon: '🚩', hint: 'Remote Config do app' },
  { route: 'import', label: 'Importar', icon: '↕️', hint: 'Backup em lote' },
];

function navigate(next) {
  route = next;
  if (next !== 'content' && location.hash) history.replaceState(null, '', location.pathname + location.search);
  sidebarOpen = false;
  render();
}

function pageTitle() {
  if (route.startsWith('trail:')) return 'Editar trilha';
  return NAV.find((n) => n.route === route)?.label || 'STWAY Admin';
}

function shell(content) {
  const navHtml = `
    <div class="nav-section">
      <span class="nav-section-label">Menu</span>
      ${NAV.filter((n) => canAccessRoute(n.route))
        .map((n) => {
          const active = route === n.route || (route.startsWith('trail:') && n.route === 'content');
          return `<a href="#" data-route="${n.route}" class="${active ? 'active' : ''}" title="${n.hint}">
            <span class="nav-icon">${n.icon}</span>
            <span class="nav-text"><strong>${n.label}</strong><small>${n.hint}</small></span>
          </a>`;
        })
        .join('')}
    </div>`;

  app.innerHTML = `
    <header class="desktop-header">
      <div class="desktop-brand">
        <div class="brand-lockup">
          <div class="brand-mark"><img src="/icon.png" alt="" width="44" height="44" /></div>
          <div>
            <h1 class="stway-wordmark">STW<span class="stway-a">A</span>Y</h1>
            <p>Painel de conteúdo</p>
          </div>
        </div>
      </div>
      <div class="desktop-header-title"></div>
      <div class="desktop-header-actions">
        <span class="header-role badge badge-muted">${escapeHtml(roleLabel(getRole()))}</span>
        <button type="button" class="header-btn" id="theme-toggle" aria-label="Tema">${themeToggleIcon()}</button>
        <button type="button" class="btn btn-secondary btn-sm btn-logout">Sair</button>
      </div>
    </header>
    <div class="layout">
      <div class="sidebar-backdrop ${sidebarOpen ? 'open' : ''}" id="sidebar-backdrop"></div>
      <aside class="sidebar ${sidebarOpen ? 'open' : ''}" id="sidebar">
        <div class="sidebar-brand">
          <div class="brand-lockup">
            <div class="brand-mark"><img src="/icon.png" alt="" width="44" height="44" /></div>
            <div>
              <h1 class="stway-wordmark">STW<span class="stway-a">A</span>Y</h1>
              <p>Painel de conteúdo</p>
            </div>
          </div>
        </div>
        <nav>${navHtml}</nav>
        <div class="sidebar-footer">
          <p class="sidebar-catalog" id="sidebar-catalog">${escapeHtml(catalogLine)}</p>
          ${getUser() ? `<p class="sidebar-user">${escapeHtml(getUser().email || getUser().uid)}</p>` : ''}
          <button type="button" class="btn btn-ghost btn-logout" title="Sair">Sair</button>
        </div>
      </aside>
      <div class="main-wrap">
        <header class="mobile-header">
          <button type="button" class="menu-toggle" id="menu-toggle" aria-label="Menu">☰</button>
          <strong class="page-title">${escapeHtml(pageTitle())}</strong>
          <div class="mobile-header-actions">
            <button type="button" class="header-btn" id="theme-toggle-m" aria-label="Tema">${themeToggleIcon()}</button>
            <button type="button" class="btn btn-secondary btn-sm btn-logout">Sair</button>
          </div>
        </header>
        <main class="main">
          <div class="page-content" id="page">${content}</div>
        </main>
      </div>
    </div>`;

  app.querySelectorAll('[data-route]').forEach((a) => {
    a.onclick = (e) => {
      e.preventDefault();
      navigate(a.dataset.route);
    };
  });
  document.getElementById('menu-toggle')?.addEventListener('click', () => {
    sidebarOpen = !sidebarOpen;
    document.getElementById('sidebar')?.classList.toggle('open', sidebarOpen);
    document.getElementById('sidebar-backdrop')?.classList.toggle('open', sidebarOpen);
  });
  document.getElementById('sidebar-backdrop')?.addEventListener('click', () => {
    sidebarOpen = false;
    document.getElementById('sidebar')?.classList.remove('open');
    document.getElementById('sidebar-backdrop')?.classList.remove('open');
  });
  document.querySelectorAll('.btn-logout').forEach((btn) => {
    btn.addEventListener('click', () => logOut());
  });
  document.getElementById('theme-toggle')?.addEventListener('click', () => {
    toggleTheme();
    render();
  });
  document.getElementById('theme-toggle-m')?.addEventListener('click', () => {
    toggleTheme();
    render();
  });
}

function loginScreen(error = '') {
  app.innerHTML = `
    <div class="login-page">
      <div class="login-hero">
        <div class="login-hero-inner">
          <div class="login-hero-mark"><img src="/icon.png" alt="STWAY" width="88" height="88" /></div>
          <h1 class="stway-wordmark">STW<span class="stway-a">A</span>Y</h1>
          <p>Conteúdo, relatos e lançamento do STWAY.</p>
        </div>
      </div>
      <div class="login-form-side">
        <form class="login-card card" id="login-form">
          <h2>Entrar</h2>
          <p class="login-sub">Use a conta admin do Firebase Auth</p>
          ${error ? `<div class="login-error">${escapeHtml(error)}</div>` : ''}
          ${skipAuth ? '<p class="field-hint">Dev: VITE_ADMIN_SKIP_AUTH=true</p>' : ''}
          <button type="button" class="btn btn-secondary btn-block" id="btn-google">Entrar com Google</button>
          <p class="login-sub" style="text-align:center;margin:0.25rem 0">ou com e-mail e senha</p>
          <label class="field"><span>E-mail</span><input name="email" type="email" required autocomplete="username" /></label>
          <label class="field"><span>Senha</span><input name="password" type="password" required autocomplete="current-password" /></label>
          <button type="submit" class="btn btn-primary btn-block">Entrar</button>
        </form>
      </div>
    </div>`;

  document.getElementById('btn-google')?.addEventListener('click', async () => {
    setLoading(true);
    try {
      await signInWithGoogle();
    } catch (err) {
      loginScreen(mapAuthError(err));
    } finally {
      setLoading(false);
    }
  });

  document.getElementById('login-form')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const fd = new FormData(e.target);
    setLoading(true);
    try {
      await signIn(fd.get('email'), fd.get('password'));
    } catch (err) {
      loginScreen(mapAuthError(err));
    } finally {
      setLoading(false);
    }
  });
}

async function renderPage() {
  const page = document.getElementById('page');
  if (!page) return;

  if (!canAccessRoute(route.startsWith('trail:') ? 'trails' : route)) {
    page.innerHTML = `<div class="card"><p>Sem permissão.</p></div>`;
    return;
  }

  if (route === 'dashboard') return renderDashboard(page, navigate);
  if (route === 'funnel') return renderFunnelPage(page);
  if (route === 'trails') return renderTrailsList(page, navigate);
  if (route.startsWith('trail:')) return renderTrailEditor(page, route.slice(6), navigate);
  if (route === 'bank') return renderBankPage(page, navigate);
  if (route === 'studies') return renderStudiesPage(page);
  if (route === 'reports') return renderReportsPage(page);
  if (route === 'import') return renderImportPage(page);
  if (route === 'users') return renderUsersPage(page);
  if (route === 'flags') return renderFlagsPage(page);
  if (route === 'content') return renderContentPage(page, navigate);
  page.innerHTML = `<div class="card"><p>Rota desconhecida.</p></div>`;
}

async function render() {
  // Sem usuário: sempre mostra login (e-mail/senha).
  // SKIP_AUTH só tenta anônimo; se falhar, não trava a tela.
  if (!isAuthenticated()) {
    let hint = '';
    if (skipAuth && !didAnonFail()) {
      hint = 'Tentando bypass anônimo… Se travar, entre com e-mail/senha de admin.';
    } else if (skipAuth && didAnonFail()) {
      hint =
        getAnonFailMessage() ||
        'Auth anônimo indisponível. Entre com e-mail/senha (Authentication → Email/Password).';
    }
    loginScreen(hint);
    return;
  }

  setLoading(true);
  try {
    await loadUserRole();
  } finally {
    setLoading(false);
  }

  if (!getProfile()) {
    const err = getProfileLoadError();
    app.innerHTML = `
      <div class="login-page">
        <div class="login-form-side" style="margin:auto">
          <div class="login-card card">
            <h2>Acesso negado</h2>
            <p class="field-hint">Seu UID não está em <code>admin_users</code>.</p>
            <p class="field-hint">${err === 'permission' ? 'Permissão Firestore negada.' : 'Peça a um admin para liberar o acesso.'}</p>
            <p class="field-hint">UID: <code>${escapeHtml(getUser()?.uid || '')}</code></p>
            <button type="button" class="btn btn-secondary btn-block" id="btn-logout">Sair</button>
          </div>
        </div>
      </div>`;
    document.getElementById('btn-logout')?.addEventListener('click', () => logOut());
    return;
  }

  shell('<div class="card"><p>Carregando…</p></div>');
  refreshCatalogLine();
  // Cada página liga os próprios atalhos [data-route].
  await renderPage();
}

watchAuth(async () => {
  try {
    await render();
  } catch (e) {
    console.error(e);
    showToast(e.message || 'Erro ao carregar painel', 'error');
  }
});
