/* Folhas: cada parte do Stway tem página própria (endereço, Google, link para mandar).
   Na home, clicar numa parte abre essa página numa folha por cima — sem sair da home.
   Dentro da folha (?folha=1), a página esconde a barra de cima e ganha o botão de fechar. */
(function folha() {
  const PATHS = new Set([
    '/palco', '/profundidades', '/strong', '/trilhas', '/por-dentro', '/juntos', '/postais',
    '/advento', '/planos', '/manifesto', '/sobre', '/doar',
  ]);
  const root = document.documentElement;
  const motionOk = !window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function target(href) {
    try {
      const url = new URL(href, location.href);
      if (url.origin !== location.origin) return null;
      const path = url.pathname.replace(/\/index\.html$/, '').replace(/\/$/, '') || '/';
      return PATHS.has(path) ? { path, hash: url.hash, key: path + url.hash } : null;
    } catch (_) {
      return null;
    }
  }

  const plainClick = (event) => !(event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey);

  if (root.classList.contains('is-folha')) {
    inside();
    return;
  }
  if (!document.querySelector('.portal') || new URLSearchParams(location.search).get('src') === 'app') return;
  outside();

  /* ─── Dentro da folha ─── */
  function inside() {
    const send = (msg) => window.parent.postMessage({ stway: 'folha', ...msg }, location.origin);

    const close = document.createElement('button');
    close.type = 'button';
    close.className = 'folha-close';
    close.setAttribute('aria-label', 'Fechar e voltar ao início');
    close.innerHTML = '<i></i><i></i>';
    document.body.appendChild(close);
    close.addEventListener('click', () => send({ type: 'close' }));

    // Esc fecha a folha, a não ser que outra janela (ex.: lista do iOS) esteja aberta por cima.
    document.addEventListener('keydown', (event) => {
      if (event.key !== 'Escape') return;
      const modal = [...document.querySelectorAll('[aria-modal="true"]')].some((node) => node.getClientRects().length);
      if (!modal) send({ type: 'close' });
    });

    document.addEventListener('click', (event) => {
      if (!plainClick(event)) return;
      const link = event.target.closest('a[href]');
      if (!link || link.target === '_blank' || link.hasAttribute('download')) return;
      const url = new URL(link.href, location.href);
      if (url.origin !== location.origin) return;
      const here = location.pathname.replace(/\/$/, '');
      if (url.pathname.replace(/\/$/, '') === here && url.hash) return; // âncora na própria página
      event.preventDefault();
      const next = target(link.href);
      if (next) send({ type: 'go', key: next.key });
      else if ((url.pathname.replace(/\/$/, '') || '/') === '/') send({ type: 'home', hash: url.hash });
      else send({ type: 'nav', href: url.pathname + url.search + url.hash });
    });

    send({ type: 'ready', title: document.title });
  }

  /* ─── Na home: abre, troca e fecha a folha ─── */
  function outside() {
    const el = document.createElement('div');
    el.className = 'folha';
    el.hidden = true;
    el.setAttribute('role', 'dialog');
    el.setAttribute('aria-modal', 'true');
    el.innerHTML = `
      <div class="folha-veil" aria-hidden="true"></div>
      <div class="folha-sheet">
        <div class="folha-card" aria-hidden="true">
          <img class="folha-card-art" alt="" />
          <p class="folha-card-num"></p>
          <p class="folha-card-title"></p>
          <span class="folha-card-load"><i></i></span>
        </div>
        <iframe title="Stway"></iframe>
      </div>`;
    document.body.appendChild(el);
    let frame = el.querySelector('iframe');
    const art = el.querySelector('.folha-card-art');
    const num = el.querySelector('.folha-card-num');
    const title = el.querySelector('.folha-card-title');
    const homeTitle = document.title;
    const behind = [...document.body.children].filter((node) => node !== el && node.tagName !== 'SCRIPT');

    let current = null;
    let openedAt = 0;
    let shownTimer = 0;
    let hideTimer = 0;
    let lastFocus = null;
    let afterClose = null;

    // Título da folha vem da própria escolha na home (pintura, numeral, nome).
    function describe(path) {
      const link = document.querySelector(`.ring-card a[href="${path}"], .portal-more a[href="${path}"]`);
      return {
        link,
        img: link?.dataset.art || link?.querySelector('.ticket-art img')?.getAttribute('src') || '',
        num: link?.dataset.num || link?.querySelector('small')?.textContent || '',
        title: link?.dataset.title || link?.querySelector('.ticket-title')?.textContent || '',
      };
    }

    // Quem chama a folha: o quadro de cinema do palco, o bilhete ou o próprio link.
    const sourceOf = (node) => node?.closest('.ring-card, .ticket') || node;

    // A folha nasce do retângulo de quem a chamou e cresce até a tela inteira.
    function from(source) {
      const vw = window.innerWidth;
      const vh = window.innerHeight;
      let r = source?.getBoundingClientRect();
      if (!r || !r.width || r.bottom < 0 || r.top > vh) r = { top: vh * 0.3, left: vw * 0.3, right: vw * 0.7, bottom: vh * 0.7 };
      el.style.setProperty('--ft', `${Math.max(0, r.top)}px`);
      el.style.setProperty('--fl', `${Math.max(0, r.left)}px`);
      el.style.setProperty('--fr', `${Math.max(0, vw - r.right)}px`);
      el.style.setProperty('--fb', `${Math.max(0, vh - r.bottom)}px`);
    }

    function open(href, source, mode = 'push') {
      const next = target(href);
      if (!next) return false;
      clearTimeout(hideTimer);
      clearTimeout(shownTimer);
      const meta = describe(next.path);
      art.src = meta.img;
      art.hidden = !meta.img;
      num.textContent = meta.num;
      title.textContent = meta.title || document.title;
      el.setAttribute('aria-label', meta.title || 'Stway');
      el.classList.remove('is-loaded');
      openedAt = performance.now();

      if (!current) {
        lastFocus = document.activeElement;
        from(source || sourceOf(meta.link));
        el.hidden = false;
        void el.offsetWidth;
        el.classList.add('is-open');
        root.classList.add('folha-open');
        behind.forEach((node) => { node.inert = true; });
        window.stwayLenis?.stop();
      }
      current = next.key;
      load(`${next.path}?folha=1${next.hash}`);

      if (mode === 'push') history.pushState({ folha: next.key }, '', next.key);
      else if (mode === 'replace') history.replaceState({ folha: next.key }, '', next.key);
      return true;
    }

    function teardown() {
      if (!current) return;
      current = null;
      clearTimeout(shownTimer);
      el.classList.remove('is-open');
      root.classList.remove('folha-open');
      behind.forEach((node) => { node.inert = false; });
      document.title = homeTitle;
      window.stwayLenis?.start();
      lastFocus?.focus?.({ preventScroll: true });
      const after = afterClose;
      afterClose = null;
      hideTimer = setTimeout(() => {
        el.hidden = true;
        el.classList.remove('is-loaded');
        load('');
        after?.();
      }, motionOk ? 760 : 0);
    }

    function close(after) {
      if (!current) return;
      afterClose = after || null;
      // Abriu por clique: o "voltar" do navegador e o × fazem a mesma coisa.
      if (history.state?.folha) history.back();
      else {
        history.replaceState(null, '', '/');
        teardown();
      }
    }

    // A folha só aparece depois de a página pintar; o cartão de título fica pelo menos um instante.
    function onLoad() {
      if (!current || !frame.getAttribute('src')) return;
      try { document.title = frame.contentDocument.title || homeTitle; } catch (_) { /* outra origem */ }
      const wait = motionOk ? Math.max(0, 750 - (performance.now() - openedAt)) : 0;
      clearTimeout(shownTimer);
      shownTimer = setTimeout(() => {
        el.classList.add('is-loaded');
        frame.focus();
      }, wait);
    }

    // Iframe novo a cada página: trocar o src de um iframe já usado cria entrada no histórico
    // e o "voltar" passaria a navegar dentro da folha em vez de fechá-la.
    function load(url) {
      const fresh = document.createElement('iframe');
      fresh.title = 'Stway';
      if (url) fresh.src = url;
      fresh.addEventListener('load', onLoad);
      frame.replaceWith(fresh);
      frame = fresh;
    }

    window.addEventListener('message', (event) => {
      if (event.origin !== location.origin || event.source !== frame.contentWindow) return;
      const msg = event.data;
      if (!msg || msg.stway !== 'folha') return;
      if (msg.type === 'close') close();
      else if (msg.type === 'go') open(msg.key, null, 'replace');
      else if (msg.type === 'nav') location.href = msg.href;
      else if (msg.type === 'home') {
        close(() => {
          const node = msg.hash && document.querySelector(msg.hash);
          if (!node) return;
          if (window.stwayLenis) window.stwayLenis.scrollTo(node, { duration: 1.4 });
          else node.scrollIntoView({ behavior: motionOk ? 'smooth' : 'auto' });
        });
      }
    });

    window.addEventListener('popstate', (event) => {
      const key = event.state?.folha;
      if (key) open(key, null, 'none');
      else teardown();
    });

    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && current) close();
    });

    // Links da página (portal, rodapé, planos) — o menu passa por window.stwayFolha.
    document.addEventListener('click', (event) => {
      if (!plainClick(event)) return;
      const link = event.target.closest('a[href]');
      if (!link || link.target === '_blank' || link.closest('.menu, .folha')) return;
      if (open(link.href, sourceOf(link))) event.preventDefault();
    });

    // Links antigos da home longa (/#strong, /#jornada…) abrem a folha certa.
    const OLD = { palco: '/palco', profundidades: '/profundidades', strong: '/strong', jornada: '/trilhas', dentro: '/por-dentro', juntos: '/juntos', postais: '/postais', advento: '/advento', comecar: '/trilhas' };
    const oldAct = OLD[location.hash.slice(1)];
    if (oldAct) {
      history.replaceState(null, '', '/');
      open(oldAct, null);
    }

    window.stwayFolha = {
      handles: (href) => Boolean(target(href)),
      open: (href) => open(href, document.querySelector('.burger')),
    };
  }
})();
