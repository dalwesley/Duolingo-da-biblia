import { getUser, isAuthenticated, logOut, mapAuthError, signIn, skipAuth, watchAuth } from './auth.js';
import { renderDashboard } from './dashboard-page.js';
import { renderBankPage } from './bank-page.js';
import { renderImportPage } from './import-page.js';
import { renderStudiesPage } from './studies-page.js';
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
import { escapeHtml, setLoading, showToast } from './ui.js';

const app = document.getElementById('app');
let route = 'dashboard';
let sidebarOpen = false;

initTheme();

const NAV = [
  { route: 'dashboard', label: 'Início', icon: '🏠' },
  { route: 'trails', label: 'Trilhas', icon: '🗺️' },
  { route: 'bank', label: 'Perguntas', icon: '❓' },
  { route: 'studies', label: 'Estudos', icon: '📖' },
  { route: 'import', label: 'Importar', icon: '⬆️' },
];

function navigate(next) {
  route = next;
  sidebarOpen = false;
  render();
}

function shell(content) {
  const navHtml = `
    <div class="nav-section">
      <span class="nav-section-label">Conteúdo</span>
      ${NAV.filter((n) => canAccessRoute(n.route))
        .map((n) => {
          const active = route === n.route || (route.startsWith('trail:') && n.route === 'trails');
          return `<a href="#" data-route="${n.route}" class="${active ? 'active' : ''}">
            <span class="nav-icon">${n.icon}</span>${n.label}</a>`;
        })
        .join('')}
    </div>`;

  app.innerHTML = `
    <div class="layout">
      <div class="sidebar-backdrop ${sidebarOpen ? 'open' : ''}" id="sidebar-backdrop"></div>
      <aside class="sidebar ${sidebarOpen ? 'open' : ''}" id="sidebar">
        <div class="sidebar-brand">
          <div class="brand-lockup">
            <div class="brand-mark">📖</div>
            <div>
              <h1>Trilha Admin</h1>
              <p>Conteúdo do app</p>
            </div>
          </div>
        </div>
        <nav>${navHtml}</nav>
        <div class="sidebar-footer">
          ${getUser() ? `<p class="sidebar-user">${escapeHtml(getUser().email || getUser().uid)}</p>` : ''}
          ${skipAuth ? '<p class="sidebar-user" style="opacity:.7">dev bypass</p>' : ''}
          <button type="button" class="btn btn-ghost btn-logout" title="Sair">Sair</button>
        </div>
      </aside>
      <div class="main-wrap">
        <header class="mobile-header">
          <button type="button" class="menu-toggle" id="menu-toggle" aria-label="Menu">☰</button>
          <strong class="page-title">Trilha Admin</strong>
          <div class="mobile-header-actions">
            <button type="button" class="header-btn" id="theme-toggle-m" aria-label="Tema">${themeToggleIcon()}</button>
            <button type="button" class="btn btn-secondary btn-sm btn-logout">Sair</button>
          </div>
        </header>
        <header class="desktop-header">
          <div class="desktop-header-actions" style="margin-left:auto">
            <span class="header-role badge badge-muted">${escapeHtml(roleLabel(getRole()))}</span>
            <button type="button" class="header-btn" id="theme-toggle" aria-label="Tema">${themeToggleIcon()}</button>
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
          <div class="login-hero-mark">📖</div>
          <h1>Trilha Admin</h1>
          <p>Trilhas, perguntas e estudos no Firebase — sem republicar o app.</p>
        </div>
      </div>
      <div class="login-form-side">
        <form class="login-card card" id="login-form">
          <h2>Entrar</h2>
          <p class="login-sub">Use a conta admin do Firebase Auth</p>
          ${error ? `<div class="login-error">${escapeHtml(error)}</div>` : ''}
          ${skipAuth ? '<p class="field-hint">Dev: VITE_ADMIN_SKIP_AUTH=true</p>' : ''}
          <label class="field"><span>E-mail</span><input name="email" type="email" required autocomplete="username" /></label>
          <label class="field"><span>Senha</span><input name="password" type="password" required autocomplete="current-password" /></label>
          <button type="submit" class="btn btn-primary btn-block">Entrar</button>
        </form>
      </div>
    </div>`;

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

  if (route === 'dashboard') return renderDashboard(page);
  if (route === 'trails') return renderTrailsList(page, navigate);
  if (route.startsWith('trail:')) return renderTrailEditor(page, route.slice(6), navigate);
  if (route === 'bank') return renderBankPage(page);
  if (route === 'studies') return renderStudiesPage(page);
  if (route === 'import') return renderImportPage(page);
  page.innerHTML = `<div class="card"><p>Rota desconhecida.</p></div>`;
}

async function render() {
  if (!isAuthenticated() && !skipAuth) {
    loginScreen();
    return;
  }

  if (!isAuthenticated() && skipAuth) {
    loginScreen('Aguardando auth anônimo… Habilite Anonymous Auth no Firebase Console se travar.');
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
  await renderPage();

  // Re-bind route clicks inside page content (dashboard shortcuts)
  document.getElementById('page')?.querySelectorAll('[data-route]').forEach((a) => {
    a.addEventListener('click', (e) => {
      e.preventDefault();
      navigate(a.dataset.route);
    });
  });
}

watchAuth(async () => {
  try {
    await render();
  } catch (e) {
    console.error(e);
    showToast(e.message || 'Erro ao carregar painel', 'error');
  }
});
