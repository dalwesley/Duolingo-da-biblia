/* Lista de espera iOS: modal simples (nome, e-mail, celular). */
(function iosWaitlist() {
  const ENDPOINT = '/api/form';
  const SELECTOR = '[data-ios-waitlist]';

  const FIELD_HINTS = {
    name: 'Diga seu nome.',
    email: 'Confira o e-mail.',
    phone: 'Informe o celular com DDD.',
    consent: 'Marque a autorização para enviar.',
  };

  // Estilos do modal (também em styles.css). Aqui cobre páginas sem a folha principal.
  function ensureStyles() {
    if (document.getElementById('ios-waitlist-css')) return;
    const style = document.createElement('style');
    style.id = 'ios-waitlist-css';
    style.textContent = `
      html.ios-waitlist-open { overflow: hidden; }
      .ios-waitlist {
        position: fixed; inset: 0; z-index: 80; display: grid; place-items: center;
        padding: max(16px, env(safe-area-inset-top)) 16px max(16px, env(safe-area-inset-bottom));
        font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif;
        color: #eef3fa;
      }
      .ios-waitlist[hidden] { display: none; }
      .ios-waitlist-backdrop {
        position: absolute; inset: 0; background: rgba(2, 6, 14, 0.72);
        backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);
      }
      .ios-waitlist-panel {
        position: relative; width: min(420px, 100%); max-height: min(92vh, 720px);
        overflow: auto; padding: 28px 24px 24px; border-radius: 24px;
        background: linear-gradient(180deg, rgba(18, 28, 44, 0.98), rgba(8, 14, 24, 0.98));
        border: 1px solid rgba(247, 187, 1, 0.28);
        box-shadow: 0 40px 100px rgba(0, 0, 0, 0.55);
      }
      .ios-waitlist-panel .kicker {
        margin: 0 0 8px; font-size: 11px; letter-spacing: 0.22em; text-transform: uppercase; color: #f7bb01;
      }
      .ios-waitlist-panel h2 {
        margin: 0 0 8px; font-weight: 600; font-size: clamp(1.5rem, 4vw, 1.9rem); letter-spacing: -0.02em;
      }
      .ios-waitlist-lead { margin: 0 0 20px; color: #9aa8bc; font-size: 15px; line-height: 1.55; }
      .ios-waitlist-form { display: grid; gap: 14px; }
      .ios-waitlist-form label span, .ios-waitlist-form .field-label {
        display: block; margin-bottom: 6px; font-size: 13px; color: #d5deea;
      }
      .ios-waitlist-form input[type="text"],
      .ios-waitlist-form input[type="email"],
      .ios-waitlist-form input[type="tel"],
      .ios-waitlist-form input:not([type]) {
        width: 100%; box-sizing: border-box; padding: 13px 14px; border-radius: 12px;
        border: 1px solid rgba(255, 255, 255, 0.14); background: rgba(4, 8, 16, 0.72);
        color: #eef3fa; font: inherit; font-size: 16px;
      }
      .ios-waitlist-form input:focus {
        outline: none; border-color: rgba(247, 187, 1, 0.8);
        box-shadow: 0 0 0 4px rgba(247, 187, 1, 0.14);
      }
      .ios-waitlist-form .check {
        display: flex; gap: 10px; align-items: flex-start; color: #9aa8bc;
        font-size: 13px; line-height: 1.45;
      }
      .ios-waitlist-form .check input { width: auto; margin-top: 3px; accent-color: #f7bb01; }
      .ios-waitlist-form .check a { color: #f7bb01; }
      .ios-waitlist-form .btn {
        display: inline-flex; align-items: center; justify-content: center;
        padding: 13px 18px; border-radius: 999px; border: 0; cursor: pointer;
        font: inherit; font-weight: 600; color: #120c02; background: #f7bb01;
      }
      .ios-waitlist-form .btn:disabled { opacity: 0.65; cursor: progress; }
      .ios-waitlist-form .form-note { min-height: 1.2em; margin: 0; font-size: 14px; }
      .ios-waitlist-form .form-note.ok { color: #7dcc9a; }
      .ios-waitlist-form .form-note.err { color: #ff8f8f; }
      .ios-waitlist-form .hp { position: absolute; left: -10000px; width: 1px; height: 1px; overflow: hidden; }
      .ios-waitlist-x {
        position: absolute; top: 12px; right: 12px; width: 40px; height: 40px;
        border: 0; border-radius: 999px; background: rgba(255, 255, 255, 0.06);
        color: #eef3fa; font-size: 24px; line-height: 1; cursor: pointer;
      }
      .ios-waitlist-x:hover { background: rgba(255, 255, 255, 0.12); }
      button.soon[data-ios-waitlist] {
        display: block; width: 100%; margin-top: 10px; padding: 12px 16px;
        border-radius: 12px; border: 1px dashed rgba(255,255,255,0.22);
        background: transparent; color: #9aa8bc; font: inherit; cursor: pointer;
      }
    `;
    document.head.appendChild(style);
  }

  function ensureDialog() {
    ensureStyles();
    let root = document.getElementById('ios-waitlist');
    if (root) return root;

    root = document.createElement('div');
    root.id = 'ios-waitlist';
    root.className = 'ios-waitlist';
    root.hidden = true;
    root.innerHTML = `
      <div class="ios-waitlist-backdrop" data-ios-close tabindex="-1"></div>
      <div class="ios-waitlist-panel" role="dialog" aria-modal="true" aria-labelledby="ios-waitlist-title">
        <button type="button" class="ios-waitlist-x" data-ios-close aria-label="Fechar">×</button>
        <p class="kicker">App Store</p>
        <h2 id="ios-waitlist-title">Ainda não saiu no iOS</h2>
        <p class="ios-waitlist-lead">Entre na lista de espera: nome, e-mail e celular. Avisamos assim que o app estiver na App Store.</p>
        <form id="form-ios-waitlist" class="form-card ios-waitlist-form" novalidate>
          <div class="hp" aria-hidden="true">
            <label>Site <input name="website" tabindex="-1" autocomplete="off" /></label>
          </div>
          <input type="hidden" name="platform" value="ios" />
          <label>
            <span>Nome</span>
            <input name="name" autocomplete="name" required maxlength="80" />
          </label>
          <label>
            <span>E-mail</span>
            <input name="email" type="email" autocomplete="email" required maxlength="120" />
          </label>
          <label>
            <span>Celular</span>
            <input name="phone" type="tel" autocomplete="tel" inputmode="tel" required maxlength="30" placeholder="(11) 99999-9999" />
          </label>
          <label class="check">
            <input type="checkbox" name="consent" value="sim" required />
            <span>Concordo que a STWAY use esses dados para avisar sobre o lançamento no iOS. <a href="/privacidade">Privacidade</a></span>
          </label>
          <button class="btn btn-gold" type="submit">Entrar na lista de espera</button>
          <p class="form-note" role="status"></p>
        </form>
      </div>
    `;
    document.body.appendChild(root);
    return root;
  }

  function note(form, text, kind) {
    const el = form.querySelector('.form-note');
    if (!el) return;
    el.textContent = text;
    el.className = `form-note ${kind || ''}`;
  }

  function validate(form) {
    form.querySelectorAll('[aria-invalid]').forEach((el) => el.removeAttribute('aria-invalid'));
    const invalid = [...form.elements].find((el) => el.willValidate && !el.checkValidity());
    if (!invalid) return true;
    const target = invalid.type === 'checkbox' ? invalid.closest('.check') : invalid;
    target?.setAttribute('aria-invalid', 'true');
    note(form, FIELD_HINTS[invalid.name] || 'Confira os campos.', 'err');
    invalid.focus({ preventScroll: true });
    return false;
  }

  let lastFocus = null;
  let open = false;

  function setOpen(next) {
    const root = ensureDialog();
    const form = root.querySelector('#form-ios-waitlist');
    open = next;
    root.hidden = !next;
    document.documentElement.classList.toggle('ios-waitlist-open', next);
    if (next) {
      lastFocus = document.activeElement;
      form?.classList.remove('is-sent');
      note(form, '', '');
      const first = form?.querySelector('input[name="name"]');
      requestAnimationFrame(() => first?.focus());
    } else {
      form?.reset();
      note(form, '', '');
      form?.classList.remove('is-sent');
      if (lastFocus && typeof lastFocus.focus === 'function') lastFocus.focus();
    }
  }

  async function send(form) {
    if (!validate(form)) return;
    const button = form.querySelector('button[type="submit"]');
    const data = Object.fromEntries(new FormData(form).entries());
    data.kind = 'tester';
    data.platform = 'ios';
    data.message = 'Lista de espera iOS';
    if (!form.elements.consent.checked) data.consent = '';

    button.disabled = true;
    note(form, 'Enviando…', '');

    try {
      const response = await fetch(ENDPOINT, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      const payload = await response.json().catch(() => ({}));
      if (!response.ok || !payload.ok) {
        note(form, payload.error || 'Não foi possível enviar.', 'err');
        button.disabled = false;
        return;
      }
      form.reset();
      form.classList.add('is-sent');
      note(form, 'Você entrou na lista. Avisamos quando o iOS estiver pronto.', 'ok');
      button.disabled = false;
    } catch (_) {
      note(form, 'Sem conexão. Tente de novo em instantes.', 'err');
      button.disabled = false;
    }
  }

  function bind() {
    const root = ensureDialog();
    const form = root.querySelector('#form-ios-waitlist');

    document.addEventListener('click', (event) => {
      const trigger = event.target.closest(SELECTOR);
      if (trigger) {
        event.preventDefault();
        setOpen(true);
        return;
      }
      if (event.target.closest('[data-ios-close]')) setOpen(false);
    });

    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && open) setOpen(false);
    });

    form?.addEventListener('input', (event) => {
      const field = event.target.closest('[aria-invalid]') || event.target.closest('.check');
      field?.removeAttribute('aria-invalid');
    });

    form?.addEventListener('submit', (event) => {
      event.preventDefault();
      send(form);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bind);
  } else {
    bind();
  }
})();
