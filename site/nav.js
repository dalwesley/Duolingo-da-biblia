/* Menu do Stway: a barra de cima só tem os dois botões de baixar; o resto mora aqui. */
(function menu() {
  const burger = document.querySelector('.burger');
  // Aberta pelo app: sem navegação para o resto do site (regra das lojas).
  if (!burger || new URLSearchParams(location.search).get('src') === 'app') return;

  const root = document.documentElement;
  const motionOk = !window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const here = location.pathname.replace(/index\.html$/, '').replace(/\/$/, '') || '/';
  const onHome = here === '/';

  // Cada parte tem endereço próprio; na home, folha.js abre por cima (folha) em vez de sair da página.
  const main = [
    { href: '/palco', label: 'O palco', hint: 'Seis gestos no versículo', shot: 'g1-toque' },
    { href: '/profundidades', label: 'Profundidades', hint: 'Observação, Compreensão, Interpretação', shot: 'g3-escolha' },
    { href: '/strong', label: 'Strong', hint: 'O hebraico e o grego por baixo', shot: 'estudar' },
    { href: '/trilhas', label: 'Trilhas', hint: 'Do Gênesis ao Apocalipse', shot: 'explorar' },
    { href: '/por-dentro', label: 'Por dentro', hint: 'Hoje, Bíblia, Explorar, Juntos', shot: 'hoje' },
    { href: '/juntos', label: 'Juntos', hint: 'Companhia, Grupo, Caravana', shot: 'caravana' },
    { href: '/postais', label: 'Postais', hint: 'Toda cena vira um postal', shot: 'postal' },
  ];
  const more = [
    { href: '/advento', label: 'Advento', hint: '26 cenas até o Natal' },
    { href: '/planos', label: 'Planos', hint: 'Tudo o que a assinatura abre' },
    { href: '/manifesto', label: 'Manifesto', hint: 'No que cremos e o dízimo' },
    { href: '/sobre', label: 'Sobre', hint: 'Por que o Stway existe' },
    { href: '/doar', label: 'Doar', hint: 'Ajude o próximo passo' },
    { href: '/#contato', label: 'Fale conosco', hint: 'Igreja, imprensa ou dúvida' },
  ];
  const roman = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX'];

  const menuEl = document.createElement('div');
  menuEl.className = 'menu';
  menuEl.id = 'menu';
  menuEl.setAttribute('role', 'dialog');
  menuEl.setAttribute('aria-modal', 'true');
  menuEl.setAttribute('aria-label', 'Menu');
  menuEl.hidden = true;
  menuEl.innerHTML = `
    <div class="menu-sky" aria-hidden="true">
      <svg class="menu-path" viewBox="0 0 1000 1000" preserveAspectRatio="none">
        <path d="M 620 1040 C 760 860, 340 760, 520 600 S 900 420, 640 260 S 380 80, 560 -40" pathLength="1" />
      </svg>
    </div>
    <div class="menu-inner">
      <nav class="menu-main" aria-label="O app">
        <p class="menu-label">O app</p>
        <ol>
          ${main.map((item, i) => `
            <li style="--i:${i}">
              <a href="${item.href}" data-shot="${item.shot}">
                <b>${roman[i]}</b>
                <span class="menu-word"><span>${item.label}</span></span>
                <small>${item.hint}</small>
              </a>
            </li>`).join('')}
        </ol>
      </nav>
      <nav class="menu-main menu-pages" aria-label="Stway">
        <p class="menu-label">O Stway</p>
        <ol>
          ${more.map((item, i) => `
            <li style="--i:${i + main.length}">
              <a href="${item.href}">
                <b>·</b>
                <span class="menu-word"><span>${item.label}</span></span>
                <small>${item.hint}</small>
              </a>
            </li>`).join('')}
        </ol>
        <p class="menu-foot" style="--i:${main.length + more.length}">
          <a href="mailto:stway.app@gmail.com">stway.app@gmail.com</a>
          <span>Lâmpada para os meus pés é a tua palavra. · Sl 119:105</span>
        </p>
      </nav>
    </div>`;
  document.body.appendChild(menuEl);

  const links = [...menuEl.querySelectorAll('a')];
  const mainLinks = [...menuEl.querySelectorAll('.menu-main a')];

  links.forEach((link) => {
    const path = link.getAttribute('href').split('#')[0].replace(/\/$/, '') || '/';
    if (!link.getAttribute('href').includes('#') && path === here) link.setAttribute('aria-current', 'page');
  });

  // Hover acende o item e mostra a dica embaixo dele.
  mainLinks.forEach((a) => {
    const hot = () => mainLinks.forEach((x) => x.classList.toggle('is-hot', x === a));
    a.addEventListener('pointerenter', hot);
    a.addEventListener('focus', hot);
  });
  menuEl.querySelectorAll('.menu-main ol').forEach((ol) => ol.addEventListener('pointerleave', () => mainLinks.forEach((x) => x.classList.remove('is-hot'))));

  let open = false;
  let closeTimer = 0;

  function origin() {
    const r = burger.getBoundingClientRect();
    menuEl.style.setProperty('--ox', `${Math.round(r.left + r.width / 2)}px`);
    menuEl.style.setProperty('--oy', `${Math.round(r.top + r.height / 2)}px`);
  }

  function show() {
    if (open) return;
    open = true;
    clearTimeout(closeTimer);
    origin();
    menuEl.hidden = false;
    void menuEl.offsetWidth;
    root.classList.add('menu-open');
    burger.setAttribute('aria-expanded', 'true');
    burger.setAttribute('aria-label', 'Fechar menu');
    window.stwayLenis?.stop();
    setTimeout(() => mainLinks[0]?.focus({ preventScroll: true }), motionOk ? 380 : 0);
  }

  function hide(after) {
    if (!open) return;
    open = false;
    origin();
    root.classList.remove('menu-open');
    burger.setAttribute('aria-expanded', 'false');
    burger.setAttribute('aria-label', 'Abrir menu');
    window.stwayLenis?.start();
    closeTimer = setTimeout(() => {
      menuEl.hidden = true;
      after?.();
    }, motionOk ? 620 : 0);
    if (!after) burger.focus({ preventScroll: true });
  }

  burger.addEventListener('click', () => (open ? hide() : show()));

  menuEl.addEventListener('click', (event) => {
    const link = event.target.closest('a');
    if (!link) return;
    const href = link.getAttribute('href');
    // Na home, as partes abrem numa folha por cima (folha.js).
    if (window.stwayFolha?.handles(href)) {
      event.preventDefault();
      hide(() => window.stwayFolha.open(href));
      return;
    }
    if (onHome && href.startsWith('/#')) {
      const target = document.querySelector(href.slice(1));
      if (!target) return;
      event.preventDefault();
      hide(() => {
        if (window.stwayLenis) window.stwayLenis.scrollTo(target, { offset: 0, duration: 1.6 });
        else target.scrollIntoView({ behavior: motionOk ? 'smooth' : 'auto' });
        history.replaceState(null, '', href.slice(1));
      });
    }
  });

  document.addEventListener('keydown', (event) => {
    if (!open) return;
    if (event.key === 'Escape') {
      event.preventDefault();
      hide();
      return;
    }
    if (event.key !== 'Tab') return;
    const focusables = [burger, ...links];
    const index = focusables.indexOf(document.activeElement);
    if (event.shiftKey && index <= 0) {
      event.preventDefault();
      focusables[focusables.length - 1].focus();
    } else if (!event.shiftKey && index === focusables.length - 1) {
      event.preventDefault();
      focusables[0].focus();
    }
  });

  window.addEventListener('resize', () => { if (open) origin(); });
})();
