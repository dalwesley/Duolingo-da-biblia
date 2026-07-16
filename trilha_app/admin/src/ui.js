const toastRoot = () => document.getElementById('toast-container');
const loadingEl = () => document.getElementById('loading-overlay');

export function setLoading(show) {
  const el = loadingEl();
  if (!el) return;
  el.classList.toggle('hidden', !show);
  el.setAttribute('aria-hidden', show ? 'false' : 'true');
}

export function showToast(message, type = 'success') {
  const root = toastRoot();
  if (!root) return;

  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  toast.setAttribute('role', 'status');
  toast.innerHTML = `
    <span class="toast-icon">${type === 'success' ? '✓' : type === 'error' ? '!' : 'i'}</span>
    <span class="toast-msg">${escapeHtml(message)}</span>`;
  root.appendChild(toast);

  requestAnimationFrame(() => toast.classList.add('show'));
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 300);
  }, 3200);
}

export function confirmAction(message, { confirmLabel = 'Excluir', danger = true } = {}) {
  return new Promise((resolve) => {
    const backdrop = document.createElement('div');
    backdrop.className = 'confirm-backdrop';
    backdrop.innerHTML = `
      <div class="confirm-dialog" role="alertdialog" aria-modal="true">
        <div class="confirm-icon ${danger ? 'confirm-icon-danger' : ''}">${danger ? '!' : '?'}</div>
        <p class="confirm-message">${escapeHtml(message)}</p>
        <div class="confirm-actions">
          <button type="button" class="btn btn-secondary" data-action="cancel">Cancelar</button>
          <button type="button" class="btn ${danger ? 'btn-danger-solid' : 'btn-primary'}" data-action="confirm">${confirmLabel}</button>
        </div>
      </div>`;

    const close = (result) => {
      backdrop.remove();
      document.removeEventListener('keydown', onKey);
      resolve(result);
    };

    const onKey = (e) => {
      if (e.key === 'Escape') close(false);
    };

    backdrop.querySelector('[data-action="cancel"]').onclick = () => close(false);
    backdrop.querySelector('[data-action="confirm"]').onclick = () => close(true);
    backdrop.onclick = (e) => {
      if (e.target === backdrop) close(false);
    };
    document.addEventListener('keydown', onKey);
    document.body.appendChild(backdrop);
    backdrop.querySelector('[data-action="confirm"]').focus();
  });
}

export function showModalElement(modal) {
  modal.hidden = false;
  modal.style.display = 'block';
  document.body.classList.add('modal-open');
}

export function hideModalElement(modal) {
  modal.style.display = 'none';
  modal.hidden = true;
  modal.innerHTML = '';
  document.body.classList.remove('modal-open');
}

export function bindModalDismiss(modal, onClose) {
  const close = () => {
    hideModalElement(modal);
    document.removeEventListener('keydown', onEsc);
    onClose?.();
  };

  const onEsc = (e) => {
    if (e.key === 'Escape') close();
  };

  document.addEventListener('keydown', onEsc);
  modal.querySelector('.modal-close')?.addEventListener('click', close);
  modal.querySelector('.modal-backdrop')?.addEventListener('click', (e) => {
    if (e.target.classList.contains('modal-backdrop')) close();
  });
  modal.querySelector('#cancel')?.addEventListener('click', close);
  return close;
}

export function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}
