const ENDPOINT = '/api/form';
const root = document.documentElement;
const motionOk = !window.matchMedia('(prefers-reduced-motion: reduce)').matches;

/* ─── Formulários ──────────────────────────────────── */

function note(form, text, kind) {
  const el = form.querySelector('.form-note');
  el.textContent = text;
  el.className = `form-note ${kind || ''}`;
}

async function send(form, kind) {
  const button = form.querySelector('button[type="submit"]');
  const data = Object.fromEntries(new FormData(form).entries());
  data.kind = kind;
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
    note(
      form,
      kind === 'tester'
        ? 'Recebemos. Vamos chamar no WhatsApp quando abrir a sua vaga no teste.'
        : 'Mensagem recebida. Respondemos no e-mail que você deixou.',
      'ok',
    );
    button.disabled = false;
  } catch (_) {
    note(form, 'Sem conexão. Tente de novo em instantes.', 'err');
    button.disabled = false;
  }
}

document.getElementById('form-tester')?.addEventListener('submit', (event) => {
  event.preventDefault();
  send(event.currentTarget, 'tester');
});

document.getElementById('form-contact')?.addEventListener('submit', (event) => {
  event.preventDefault();
  send(event.currentTarget, 'contact');
});

/* ─── Palavras: cada uma vira um span com --i ──────── */

function splitWords(el, isKey) {
  const words = el.textContent.trim().split(/\s+/);
  el.setAttribute('aria-label', el.textContent.trim());
  el.textContent = '';
  words.forEach((word, i) => {
    const span = document.createElement('span');
    span.className = 'w';
    span.setAttribute('aria-hidden', 'true');
    span.style.setProperty('--i', String(i));
    span.textContent = i < words.length - 1 ? `${word} ` : word;
    if (isKey?.(word)) span.classList.add('is-key');
    el.appendChild(span);
  });
  el.style.setProperty('--n', String(words.length));
}

document.querySelectorAll('[data-words]').forEach((el) => splitWords(el));
document.querySelectorAll('[data-kinetic]').forEach((el) => {
  splitWords(el, (word) => /^(missão|nela\.)$/.test(word));
});

/* ─── Abertura: "No princípio… e houve luz." ───────── */

(function intro() {
  let seen = false;
  try { seen = sessionStorage.getItem('stway-intro') === '1'; } catch (_) { /* sem storage */ }
  if (!motionOk || seen || window.scrollY > 40 || location.hash) return;

  root.classList.add('intro');
  const stages = ['s1', 's2', 's3', 's4'];
  const times = [180, 1700, 2750, 3600];
  const timers = stages.map((stage, i) => setTimeout(() => root.classList.add(stage), times[i]));

  function finish() {
    timers.forEach(clearTimeout);
    root.classList.add(...stages);
    try { sessionStorage.setItem('stway-intro', '1'); } catch (_) { /* sem storage */ }
    ['wheel', 'touchmove', 'keydown'].forEach((type) => window.removeEventListener(type, finish));
  }

  setTimeout(finish, times[3]);
  document.querySelector('.skip-intro')?.addEventListener('click', finish);
  ['wheel', 'touchmove', 'keydown'].forEach((type) => {
    window.addEventListener(type, finish, { passive: true, once: true });
  });
})();

/* ─── Motor de cenas: --p de 0→1 por seção ─────────── */

const header = document.querySelector('.site-header');
const meter = document.querySelector('.scroll-meter span');
const scenes = [...document.querySelectorAll('[data-scene]')].map((el) => ({
  el,
  pinned: Boolean(el.querySelector(':scope > .pin')),
  steps: Number(el.dataset.steps || 0),
  items: [...el.querySelectorAll('[data-step]')],
  last: -1,
  step: -1,
}));
const strong = document.querySelector('.strong');
const rail = document.querySelector('.rail');
const jornada = document.querySelector('.jornada');
const depthTones = ['var(--gold)', 'var(--coral)', 'var(--orchid)'];
let railLength = 0;
let railStops = [];
let railLit = -1;

function clamp01(value) {
  return Math.min(1, Math.max(0, value));
}

function curveThrough(points) {
  let d = `M ${points[0].x.toFixed(1)} ${points[0].y.toFixed(1)}`;
  for (let i = 0; i < points.length - 1; i += 1) {
    const p0 = points[i - 1] || points[i];
    const p1 = points[i];
    const p2 = points[i + 1];
    const p3 = points[i + 2] || p2;
    d += ` C ${(p1.x + (p2.x - p0.x) / 6).toFixed(1)} ${(p1.y + (p2.y - p0.y) / 6).toFixed(1)},`
      + ` ${(p2.x - (p3.x - p1.x) / 6).toFixed(1)} ${(p2.y - (p3.y - p1.y) / 6).toFixed(1)},`
      + ` ${p2.x.toFixed(1)} ${p2.y.toFixed(1)}`;
  }
  return d;
}

// Trilha passa pelo centro de cada cena; os cards cobrem a linha e ela aparece nos vãos.
function drawRailPath() {
  const svg = rail.querySelector('.rail-path');
  const cards = [...rail.querySelectorAll('.scene')];
  if (!svg || !cards.length) return;
  const box = rail.getBoundingClientRect();
  const centers = cards.map((card) => {
    const r = card.getBoundingClientRect();
    return { x: r.left - box.left + r.width / 2, y: r.top - box.top + r.height / 2 };
  });
  const points = [{ x: 0, y: centers[0].y }, ...centers, { x: box.width, y: centers[centers.length - 1].y }];
  const d = curveThrough(points);
  svg.setAttribute('viewBox', `0 0 ${box.width.toFixed(0)} ${box.height.toFixed(0)}`);
  svg.querySelectorAll('path').forEach((path) => path.setAttribute('d', d));

  // Fração do comprimento da linha em que ela chega ao centro de cada cena.
  const track = svg.querySelector('.rail-track');
  railLength = track.getTotalLength();
  railStops = centers.map(({ x }) => {
    let lo = 0;
    let hi = railLength;
    for (let i = 0; i < 24; i += 1) {
      const mid = (lo + hi) / 2;
      if (track.getPointAtLength(mid).x < x) lo = mid;
      else hi = mid;
    }
    return hi / railLength;
  });
  railLit = -1;
}

// Linha anda com o scroll; a cena alcançada acende, as anteriores apagam.
function paintRail(p) {
  if (!railLength) return;
  const drawn = Math.min(1, p * 1.1);
  const track = rail.querySelector('.rail-track');
  const tip = rail.querySelector('.rail-tip');
  const point = track.getPointAtLength(drawn * railLength);
  tip?.setAttribute('cx', point.x.toFixed(1));
  tip?.setAttribute('cy', point.y.toFixed(1));

  let lit = 0;
  railStops.forEach((stop, i) => { if (drawn >= stop - 0.004) lit = i; });
  if (lit === railLit) return;
  railLit = lit;
  rail.querySelectorAll('.scene').forEach((card, i) => {
    card.classList.toggle('is-lit', i === lit);
    card.classList.toggle('is-past', i < lit);
  });
}

function sizeRail() {
  if (!rail || !jornada) return;
  const shift = Math.max(0, rail.scrollWidth - window.innerWidth);
  rail.style.setProperty('--shift', `${shift}px`);
  jornada.style.height = `${Math.round(shift * 1.1 + window.innerHeight * 1.35)}px`;
  drawRailPath();
}

function setStep(scene, index) {
  if (scene.step === index) return;
  scene.step = index;
  scene.el.style.setProperty('--step', String(index));
  scene.items.forEach((item) => {
    const at = Number(item.dataset.step);
    item.classList.toggle('is-on', at === index);
    item.classList.toggle('is-past', at < index);
  });
  if (scene.el.id === 'profundidades') scene.el.style.setProperty('--tone-now', depthTones[index]);
}

function paint() {
  const vh = window.innerHeight;

  for (const scene of scenes) {
    const rect = scene.el.getBoundingClientRect();
    if (rect.bottom < -vh * 0.2 || rect.top > vh * 1.2) {
      if (scene.step < 0 && scene.steps) setStep(scene, 0);
      continue;
    }
    const span = scene.pinned ? rect.height - vh : rect.height;
    const p = span > 0 ? clamp01(-rect.top / span) : 0;
    const rounded = Math.round(p * 1000) / 1000;
    if (rounded !== scene.last) {
      scene.last = rounded;
      scene.el.style.setProperty('--p', String(rounded));
    }
    if (scene.steps) setStep(scene, Math.min(scene.steps - 1, Math.floor(p * scene.steps)));
    if (scene.el === jornada) paintRail(p);
  }

  if (strong) {
    const rect = strong.getBoundingClientRect();
    const t = clamp01((vh - rect.top) / (vh + rect.height));
    strong.style.setProperty('--drift', t.toFixed(3));
  }

  const max = root.scrollHeight - vh;
  header?.classList.toggle('is-solid', window.scrollY > 40);
  meter?.style.setProperty('--read', max > 0 ? (window.scrollY / max).toFixed(4) : '0');
}

let queued = false;
function queuePaint() {
  if (queued) return;
  queued = true;
  requestAnimationFrame(() => {
    queued = false;
    paint();
  });
}

window.addEventListener('scroll', queuePaint, { passive: true });
window.addEventListener('resize', () => {
  sizeRail();
  queuePaint();
});
window.addEventListener('load', () => {
  sizeRail();
  paint();
});
sizeRail();
paint();

/* ─── Strong: toque a palavra ──────────────────────── */

(function lexicon() {
  const entries = [
    { heb: 'רֵאשִׁית', translit: "rē'šît", num: 'H7225', def: 'Começo, primeiro. A primeira palavra da Bíblia hebraica: bərē\'šît, "no princípio".' },
    { heb: 'בָּרָא', translit: "bārā'", num: 'H1254', def: 'Criar. Nesta forma, o Antigo Testamento só usa o verbo com Deus como sujeito.' },
    { heb: 'אֱלֹהִים', translit: "'ĕlōhîm", num: 'H430', def: 'Deus. A palavra tem forma plural, mas aqui vem com verbo no singular: um só Deus age.' },
    { heb: 'שָׁמַיִם', translit: 'šāmayim', num: 'H8064', def: 'Céu, céus. Do alto visível, onde ficam as estrelas, até a morada de Deus.' },
    { heb: 'אֶרֶץ', translit: "'ereṣ", num: 'H776', def: 'Terra. O chão, o país, o mundo inteiro em oposição ao céu.' },
  ];
  const buttons = [...document.querySelectorAll('.strong-verse [data-word]')];
  const panel = document.querySelector('.lexicon');
  if (!buttons.length || !panel) return;
  const heb = panel.querySelector('.lex-heb');
  const translit = panel.querySelector('.lex-translit');
  const num = panel.querySelector('.lex-num');
  const def = panel.querySelector('.lex-def');
  let swapTimer = 0;

  function show(index) {
    const entry = entries[index];
    buttons.forEach((button, i) => {
      button.setAttribute('aria-selected', String(i === index));
      button.tabIndex = i === index ? 0 : -1;
    });
    const apply = () => {
      heb.textContent = entry.heb;
      translit.textContent = entry.translit;
      num.textContent = entry.num;
      def.textContent = entry.def;
      panel.classList.remove('is-swap');
    };
    clearTimeout(swapTimer);
    if (!motionOk) return apply();
    panel.classList.add('is-swap');
    swapTimer = setTimeout(apply, 260);
  }

  buttons.forEach((button, i) => {
    button.tabIndex = button.getAttribute('aria-selected') === 'true' ? 0 : -1;
    button.addEventListener('click', () => show(i));
    button.addEventListener('keydown', (event) => {
      if (event.key !== 'ArrowRight' && event.key !== 'ArrowLeft') return;
      event.preventDefault();
      const next = (i + (event.key === 'ArrowRight' ? 1 : -1) + buttons.length) % buttons.length;
      buttons[next].focus();
      show(next);
    });
  });
})();

/* ─── Reveal ───────────────────────────────────────── */

(function reveal() {
  const nodes = document.querySelectorAll('.reveal');
  if (!motionOk || !('IntersectionObserver' in window)) {
    nodes.forEach((node) => node.classList.add('in'));
    return;
  }
  const watcher = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue;
      entry.target.classList.add('in');
      watcher.unobserve(entry.target);
    }
  }, { threshold: 0.16, rootMargin: '0px 0px -8% 0px' });
  nodes.forEach((node) => watcher.observe(node));
})();

/* ─── Céu: estrelas em camadas + estrela cadente ───── */

(function cosmos() {
  const canvas = document.querySelector('.cosmos');
  const ctx = canvas?.getContext('2d');
  if (!ctx) return;

  let width = 0;
  let height = 0;
  let stars = [];
  let meteor = null;
  let nextMeteor = performance.now() + 6000;
  let frame = 0;

  function resize() {
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    width = window.innerWidth;
    height = window.innerHeight;
    canvas.width = Math.round(width * dpr);
    canvas.height = Math.round(height * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    const count = Math.min(260, Math.round((width * height) / 7000));
    stars = Array.from({ length: count }, () => ({
      x: Math.random() * width,
      y: Math.random() * height,
      z: Math.random() ** 2,
      phase: Math.random() * Math.PI * 2,
      warm: Math.random() < 0.14,
    }));
  }

  function draw(now) {
    ctx.clearRect(0, 0, width, height);
    const scroll = window.scrollY;
    for (const star of stars) {
      const depth = 0.15 + star.z * 0.85;
      const y = (((star.y - scroll * depth * 0.12) % height) + height) % height;
      const twinkle = motionOk ? 0.55 + 0.45 * Math.sin(now * 0.0012 * (0.4 + star.z) + star.phase) : 0.8;
      ctx.globalAlpha = (0.25 + star.z * 0.75) * twinkle;
      ctx.fillStyle = star.warm ? '#ffe7a0' : '#ffffff';
      const size = 0.4 + star.z * 1.3;
      ctx.fillRect(star.x, y, size, size);
    }

    if (motionOk) {
      if (!meteor && now > nextMeteor) {
        meteor = { x: width * (0.3 + Math.random() * 0.7), y: height * Math.random() * 0.35, t: 0 };
      }
      if (meteor) {
        meteor.t += 1;
        const len = 140;
        const hx = meteor.x - meteor.t * 9;
        const hy = meteor.y + meteor.t * 4;
        const grad = ctx.createLinearGradient(hx, hy, hx + len, hy - len * 0.45);
        grad.addColorStop(0, 'rgba(255, 231, 160, 0.9)');
        grad.addColorStop(1, 'rgba(255, 231, 160, 0)');
        ctx.globalAlpha = Math.max(0, 1 - meteor.t / 70);
        ctx.strokeStyle = grad;
        ctx.lineWidth = 1.2;
        ctx.beginPath();
        ctx.moveTo(hx, hy);
        ctx.lineTo(hx + len, hy - len * 0.45);
        ctx.stroke();
        if (meteor.t > 70) {
          meteor = null;
          nextMeteor = now + 7000 + Math.random() * 9000;
        }
      }
    }
    ctx.globalAlpha = 1;
  }

  function loop(now) {
    draw(now);
    frame = requestAnimationFrame(loop);
  }

  resize();
  window.addEventListener('resize', () => {
    resize();
    if (!motionOk) draw(0);
  });

  if (!motionOk) {
    draw(0);
    window.addEventListener('scroll', () => draw(0), { passive: true });
    return;
  }

  frame = requestAnimationFrame(loop);
  document.addEventListener('visibilitychange', () => {
    cancelAnimationFrame(frame);
    if (!document.hidden) frame = requestAnimationFrame(loop);
  });
})();
