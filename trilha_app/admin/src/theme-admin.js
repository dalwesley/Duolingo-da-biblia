const KEY = 'trilha-admin-theme';

export function initTheme() {
  const saved = localStorage.getItem(KEY);
  const dark = saved === 'dark' || (!saved && window.matchMedia('(prefers-color-scheme: dark)').matches);
  document.documentElement.classList.toggle('theme-dark', dark);
  document.querySelector('meta[name="color-scheme"]')?.setAttribute('content', dark ? 'dark' : 'light');
  return dark;
}

export function isDarkTheme() {
  return document.documentElement.classList.contains('theme-dark');
}

export function toggleTheme() {
  const dark = !isDarkTheme();
  document.documentElement.classList.toggle('theme-dark', dark);
  localStorage.setItem(KEY, dark ? 'dark' : 'light');
  document.querySelector('meta[name="color-scheme"]')?.setAttribute('content', dark ? 'dark' : 'light');
  return dark;
}

export function themeToggleIcon() {
  return isDarkTheme() ? '☀️' : '🌙';
}
