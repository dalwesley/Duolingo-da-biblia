/* Animações próprias da página Sobre — não mexe na home. */
(function sobrePage() {
  if (!document.body.classList.contains('page-sobre')) return;

  const motionOk = !window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const nome = document.querySelector('.sb-nome');
  const hero = document.querySelector('.sb-hero');
  const como = document.querySelector('.sb-como');
  const letters = [...document.querySelectorAll('.sb-letters li')];
  const lamps = [...document.querySelectorAll('.sb-lamps [data-lamp]')];
  const trail = document.querySelector('.sb-trail-draw');
  const comoLine = document.querySelector('.sb-como-line i');

  function clamp01(v) {
    return Math.min(1, Math.max(0, v));
  }

  function progress(el) {
    if (!el) return 0;
    const rect = el.getBoundingClientRect();
    const vh = window.innerHeight;
    const pinned = Boolean(el.querySelector(':scope > .pin'));
    const span = pinned ? rect.height - vh : rect.height;
    if (span <= 0) return 0;
    return clamp01(-rect.top / span);
  }

  function paint() {
    const pNome = progress(nome);
    const pHero = progress(hero);
    const pComo = progress(como);

    // Letras: primeiro St (step/street), depois Way (caminho).
    const stOn = pNome > 0.18;
    const wayOn = pNome > 0.48;
    letters.forEach((li) => {
      const isSt = li.classList.contains('sb-st');
      li.classList.toggle('is-lit', isSt ? stOn : wayOn);
    });

    // Trilha do herói desenha e lâmpadas acendem.
    if (trail) {
      const drawn = clamp01(0.15 + pHero * 0.85);
      trail.style.strokeDashoffset = String(1 - drawn);
      lamps.forEach((lamp, i) => {
        lamp.classList.toggle('is-on', drawn > (i + 0.4) / (lamps.length + 0.6));
      });
    }

    // Linha vertical dos passos.
    if (comoLine) {
      comoLine.style.transform = `scaleY(${clamp01(pComo)})`;
    }

    // Parallax leve do herói.
    if (hero && motionOk) {
      hero.style.setProperty('--lift', (pHero * 40).toFixed(1));
    }
  }

  let queued = false;
  function queue() {
    if (queued) return;
    queued = true;
    requestAnimationFrame(() => {
      queued = false;
      paint();
    });
  }

  window.addEventListener('scroll', queue, { passive: true });
  window.addEventListener('resize', queue);
  paint();

  // Cascata: delay escalonado além do reveal padrão.
  document.querySelectorAll('.sb-cascade .reveal').forEach((el, i) => {
    el.style.transitionDelay = `${i * 0.08}s`;
  });
})();
