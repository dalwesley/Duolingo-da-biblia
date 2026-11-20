/* Arco de escolha da home: as 7 partes em arco 3D, todas à vista.
   A rolagem passa os cartões (o palco fica preso), arrastar para o lado também; clicar num cartão abre a folha. */
(function ring() {
  const stage = document.querySelector('[data-ring]');
  if (!stage) return;
  const root = document.documentElement;
  const motionOk = !window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const ringEl = stage.querySelector('.ring');
  const wheel = stage.querySelector('.ring-wheel');
  const cards = [...wheel.querySelectorAll('.ring-card')];
  const countEl = stage.querySelector('.ring-count b');
  const n = cards.length;

  // Luz ambiente: a pintura da parte da frente, borrada, enche a sala.
  const amb = document.createElement('div');
  amb.className = 'ring-ambient';
  amb.setAttribute('aria-hidden', 'true');
  amb.innerHTML = cards.map((card) => `<img src="${card.querySelector('a').dataset.art}" alt="" />`).join('');
  stage.prepend(amb);
  const ambs = [...amb.children];
  cards.forEach((card) => {
    card.querySelector('a').draggable = false;
    card.querySelector('img').draggable = false;
  });

  // O Anan apresenta cada porta: fala a da frente e comemora quando alguém mira um cartão.
  const anan = (() => {
    const box = stage.querySelector('.ring-anan');
    const flip = box?.querySelector('.bubble-flip');
    const faces = flip ? [...flip.querySelectorAll('.bubble-face')] : [];
    const LINES = {
      '/palco': 'Aqui você responde dentro do versículo!',
      '/profundidades': 'Três mergulhos no mesmo texto. Bora?',
      '/strong': 'Hebraico e grego sem medo. Eu te mostro!',
      '/trilhas': 'Do Gênesis ao Apocalipse, um passo por dia.',
      '/por-dentro': 'Quer ver o app por dentro? Vem comigo!',
      '/juntos': 'Chama alguém. Junto a gente vai mais longe!',
      '/postais': 'Cada cena vira um postal. Eu carimbo!',
    };
    let cheerTimer = 0;
    let first = true;
    let shownLine = faces[0]?.textContent || '';
    function cheer() {
      if (!box) return;
      box.classList.remove('is-cheer');
      void box.offsetWidth;
      box.classList.add('is-cheer');
      clearTimeout(cheerTimer);
      cheerTimer = setTimeout(() => box.classList.remove('is-cheer'), 1150);
    }
    // Como no app (pergunta → dica): a fala nova vem no verso e o balão gira. Frase inteira, na hora.
    function say(href) {
      if (!flip) return;
      if (first) { first = false; return; } // a 1ª fala é a do HTML (apresentação)
      const line = LINES[href];
      if (!line || line === shownLine) return;
      shownLine = line;
      const flipped = flip.classList.contains('is-flipped');
      faces[flipped ? 0 : 1].textContent = line;
      flip.classList.toggle('is-flipped', !flipped);
    }
    box?.querySelector('.ring-anan-body').addEventListener('click', cheer);
    return { say, cheer };
  })();
  cards.forEach((card) => {
    const link = card.querySelector('a');
    link.addEventListener('pointerenter', (event) => {
      if (event.pointerType !== 'mouse') return;
      anan.say(link.getAttribute('href'));
      anan.cheer();
    });
    link.addEventListener('click', () => anan.cheer());
  });

  // O trilho em volta do palco é alto: a rolagem passa os cartões (pos 0 → 6),
  // e o arraste para o lado rola a página até a parte certa — uma fonte só de verdade.
  const track = stage.closest('[data-ring-track]') || stage;
  let pos = 0; // parte no centro (contínuo: 2.4 = entre a III e a IV)
  let shown = 0; // o que está desenhado (segue pos com suavidade)
  let front = -1;
  let visible = false;
  let raf = 0;
  let drag = null;
  let moved = 0;

  const wrapI = (i) => ((Math.round(i) % n) + n) % n;
  const gapPx = () => cards[0].offsetWidth * (window.innerWidth <= 760 ? 0.6 : 1.02);
  const span = () => Math.max(1, track.offsetHeight - window.innerHeight);
  const trackTop = () => track.getBoundingClientRect().top + window.scrollY;
  const yFor = (p) => trackTop() + (Math.min(n - 1, Math.max(0, p)) / (n - 1)) * span();

  function scrollToY(y, smooth) {
    if (window.stwayLenis) window.stwayLenis.scrollTo(y, smooth ? { duration: 0.9 } : { immediate: true });
    else window.scrollTo({ top: y, behavior: smooth && motionOk ? 'smooth' : 'auto' });
  }

  function readScroll() {
    const p = Math.min(1, Math.max(0, -track.getBoundingClientRect().top / span()));
    pos = p * (n - 1);
  }

  function paint() {
    cards.forEach((card, k) => {
      let d = k - shown;
      d -= Math.round(d / n) * n; // anel sem fim: cada cartão no lado mais curto
      const ad = Math.abs(d);
      card.style.setProperty('--d', d.toFixed(3));
      card.style.setProperty('--ad', ad.toFixed(3));
      card.style.setProperty('--dim', Math.min(0.6, ad * 0.2).toFixed(3));
      // Quem passa por trás (|d| perto de 3,5) some e reaparece do outro lado.
      card.style.setProperty('--o', Math.min(1, Math.max(0, (3.45 - ad) / 0.45)).toFixed(3));
      card.style.zIndex = String(100 - Math.round(ad * 10));
    });
    stage.style.setProperty('--ring-p', (shown / (n - 1)).toFixed(3));
    const f = wrapI(shown);
    if (f === front) return;
    front = f;
    cards.forEach((card, k) => card.classList.toggle('is-front', k === f));
    ambs.forEach((img, k) => img.classList.toggle('is-on', k === f));
    if (countEl) countEl.textContent = String(f + 1).padStart(2, '0');
    anan.say(cards[f].querySelector('a').getAttribute('href'));
  }

  function tick() {
    raf = 0;
    shown += motionOk ? (pos - shown) * 0.2 : pos - shown;
    if (Math.abs(pos - shown) < 0.001) shown = pos;
    paint();
    if (visible && shown !== pos) raf = requestAnimationFrame(tick);
  }
  function run() {
    if (!raf) raf = requestAnimationFrame(tick);
  }

  new IntersectionObserver(([entry]) => {
    visible = entry.isIntersecting;
    if (visible) { readScroll(); run(); }
  }, { threshold: 0 }).observe(track);

  window.addEventListener('scroll', () => {
    if (!visible) return;
    readScroll();
    run();
  }, { passive: true });
  window.addEventListener('resize', () => { readScroll(); run(); });

  // Arrastar para o lado: a página rola junto, então rolar e arrastar nunca brigam.
  ringEl.addEventListener('pointerdown', (event) => {
    if (event.button !== 0) return;
    drag = { x: event.clientX, pos, lastX: event.clientX, lastT: performance.now(), v: 0, on: false, id: event.pointerId };
    moved = 0;
  });
  window.addEventListener('pointermove', (event) => {
    if (!drag || event.pointerId !== drag.id) return;
    const dx = event.clientX - drag.x;
    moved = Math.max(moved, Math.abs(dx));
    if (!drag.on && Math.abs(dx) > 6) {
      drag.on = true;
      ringEl.classList.add('is-drag');
    }
    if (!drag.on) return;
    const now = performance.now();
    drag.v = (event.clientX - drag.lastX) / Math.max(1, now - drag.lastT);
    drag.lastX = event.clientX;
    drag.lastT = now;
    scrollToY(yFor(drag.pos - dx / gapPx()), false);
  });
  const release = () => {
    if (!drag) return;
    // Solta com embalo e assenta numa parte.
    if (drag.on) scrollToY(yFor(Math.round(pos - (drag.v * 200) / gapPx())), true);
    drag = null;
    ringEl.classList.remove('is-drag');
  };
  window.addEventListener('pointerup', release);
  window.addEventListener('pointercancel', release);
  // Depois de arrastar, soltar em cima de um cartão não abre a folha.
  ringEl.addEventListener('click', (event) => {
    if (moved > 6) {
      event.preventDefault();
      event.stopPropagation();
    }
  }, true);

  // Teclado: o cartão focado vem para a frente; setas passam.
  cards.forEach((card, k) => {
    card.querySelector('a').addEventListener('focus', () => scrollToY(yFor(k), true));
  });
  stage.addEventListener('keydown', (event) => {
    if (event.key !== 'ArrowLeft' && event.key !== 'ArrowRight') return;
    event.preventDefault();
    const next = Math.min(n - 1, Math.max(0, Math.round(pos) + (event.key === 'ArrowRight' ? 1 : -1)));
    cards[next].querySelector('a').focus({ preventScroll: true });
  });

  readScroll();
  shown = pos;
  paint();
})();
