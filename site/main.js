const ENDPOINT = '/api/form';
const root = document.documentElement;
const motionOk = !window.matchMedia('(prefers-reduced-motion: reduce)').matches;
const finePointer = window.matchMedia('(pointer: fine)').matches;
let lenis = null;

/* ─── Formulários ──────────────────────────────────── */

function note(form, text, kind) {
  const el = form.querySelector('.form-note');
  el.textContent = text;
  el.className = `form-note ${kind || ''}`;
}

const FIELD_HINTS = {
  name: 'Diga seu nome.',
  email: 'Confira o e-mail.',
  message: 'Escreva sua mensagem.',
  consent: 'Marque a autorização para enviar.',
};

// Marca o primeiro campo inválido e explica em uma linha, antes de ir ao servidor.
function validate(form) {
  form.querySelectorAll('[aria-invalid]').forEach((el) => el.removeAttribute('aria-invalid'));
  const invalid = [...form.elements].find((el) => el.willValidate && !el.checkValidity());
  if (!invalid) return true;
  const target = invalid.type === 'radio' ? invalid.closest('.choices')
    : invalid.type === 'checkbox' ? invalid.closest('.check') : invalid;
  target?.setAttribute('aria-invalid', 'true');
  note(form, FIELD_HINTS[invalid.name] || 'Confira os campos.', 'err');
  invalid.focus({ preventScroll: true });
  target?.scrollIntoView({ block: 'center', behavior: motionOk ? 'smooth' : 'auto' });
  return false;
}

document.querySelectorAll('.form-card').forEach((form) => {
  form.addEventListener('input', (event) => {
    const field = event.target.closest('[aria-invalid]') || event.target.closest('.choices, .check');
    field?.removeAttribute('aria-invalid');
  });
});

async function send(form, kind) {
  if (!validate(form)) return;
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
    form.classList.add('is-sent');
    note(form, 'Mensagem recebida. Respondemos no e-mail que você deixou.', 'ok');
    button.disabled = false;
  } catch (_) {
    note(form, 'Sem conexão. Tente de novo em instantes.', 'err');
    button.disabled = false;
  }
}

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
  const keys = (el.dataset.keys || 'missão|nela.')
    .split('|')
    .map((k) => k.trim())
    .filter(Boolean);
  const pattern = new RegExp(`^(${keys.map((k) => k.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|')})$`);
  splitWords(el, (word) => pattern.test(word));
});

/* ─── Abertura: "No princípio… e houve luz." ───────── */

(function intro() {
  const stages = ['s1', 's2', 's3', 's4'];
  // s1 versículo · s2 "Haja luz" · s3 luz no céu · s4 versículo sai, título entra
  const times = [180, 1700, 2750, 3900];
  const skipEvents = ['wheel', 'touchmove', 'keydown'];
  const replay = document.querySelector('.replay-intro');
  let timers = [];

  function finish() {
    timers.forEach(clearTimeout);
    timers = [];
    root.classList.add(...stages);
    try { sessionStorage.setItem('stway-intro', '1'); } catch (_) { /* sem storage */ }
    skipEvents.forEach((type) => window.removeEventListener(type, finish));
  }

  function play() {
    timers.forEach(clearTimeout);
    // Volta ao escuro sem animar a saída, depois roda a linha do tempo do zero.
    root.classList.add('intro-reset', 'intro');
    root.classList.remove(...stages);
    void root.offsetHeight;
    root.classList.remove('intro-reset');
    timers = stages.map((stage, i) => setTimeout(() => root.classList.add(stage), times[i]));
    timers.push(setTimeout(finish, times[3]));
    skipEvents.forEach((type) => window.addEventListener(type, finish, { passive: true, once: true }));
  }

  document.querySelector('.skip-intro')?.addEventListener('click', finish);

  if (!motionOk) {
    replay?.remove();
    return;
  }

  // Só a home tem o prólogo de Gênesis; páginas internas não rodam a intro.
  if (!document.querySelector('.prologue')) {
    replay?.remove();
    return;
  }

  replay?.addEventListener('click', () => {
    if (lenis) lenis.scrollTo(0, { immediate: true });
    else window.scrollTo({ top: 0, behavior: 'instant' });
    // Evita que o próprio scroll de volta conte como "pular".
    requestAnimationFrame(play);
  });

  let seen = false;
  try { seen = sessionStorage.getItem('stway-intro') === '1'; } catch (_) { /* sem storage */ }
  if (seen || window.scrollY > 40 || location.hash) return;
  play();
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
const dentro = document.querySelector('.dentro');
const ocean = document.querySelector('.ocean');
const oceanMeter = ocean?.querySelector('[data-meter]');
let oceanDepth = -1;

// Profundidades: o medidor conta os metros da descida.
function paintOcean(p) {
  const meters = Math.round(Math.max(0, p - 0.04) * 125);
  if (meters === oceanDepth || !oceanMeter) return;
  oceanDepth = meters;
  oceanMeter.textContent = String(meters);
}
const orbitRing = dentro?.querySelector('.orbit-ring');
const orbs = orbitRing ? [...orbitRing.querySelectorAll('.orb')] : [];
const orbitCount = dentro?.querySelector('.orbit-count b');
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

// A trilha é uma estrada que passa por baixo de cada cena; o Anan anda nela.
const anan = rail?.querySelector('.anan');
const railDust = rail?.querySelector('.rail-dust');
const skies = jornada ? [...jornada.querySelectorAll('[data-sky]')] : [];
const walk = { len: -1, lean: 0, dust: 0, still: 0, cheer: 0, caption: 0 };
const jornadaCaption = jornada?.querySelector('.jornada-caption');
const jornadaNumeral = jornada?.querySelector('.jornada-numeral');
const numerals = ['I', 'II', 'III', 'IV', 'V', 'VI', '∞'];

// Legenda de cinema embaixo e o numeral grande ao fundo trocam com a etapa.
function caption(index) {
  const card = rail.querySelectorAll('.scene')[index];
  const text = card?.querySelector('.scene-art img')?.alt || '';
  if (jornadaCaption) {
    jornadaCaption.classList.remove('is-on');
    clearTimeout(walk.caption);
    walk.caption = setTimeout(() => {
      jornadaCaption.textContent = text;
      jornadaCaption.classList.add('is-on');
    }, motionOk ? 380 : 0);
  }
  if (jornadaNumeral) {
    jornadaNumeral.classList.remove('is-on');
    void jornadaNumeral.offsetWidth;
    jornadaNumeral.textContent = numerals[index] || '';
    jornadaNumeral.classList.add('is-on');
  }
}

function drawRailPath() {
  const svg = rail.querySelector('.rail-path');
  const cards = [...rail.querySelectorAll('.scene')];
  if (!svg || !cards.length) return;
  const box = rail.getBoundingClientRect();
  const below = window.innerWidth < 720 ? 52 : 74;
  const feet = cards.map((card) => {
    const r = card.getBoundingClientRect();
    const lift = card.classList.contains('is-lit') ? 6 : 0;
    return { x: r.left - box.left + r.width / 2, y: r.bottom - box.top + below + lift };
  });
  const first = feet[0];
  const last = feet[feet.length - 1];
  const lead = Math.min(first.x - 20, Math.max(60, first.x - 180));
  const points = [{ x: lead, y: first.y + 30 }, ...feet, { x: Math.min(box.width, last.x + 170), y: last.y - 22 }];
  const d = curveThrough(points);
  svg.setAttribute('viewBox', `0 0 ${box.width.toFixed(0)} ${box.height.toFixed(0)}`);
  svg.querySelectorAll('path').forEach((path) => path.setAttribute('d', d));

  // Fração do comprimento da estrada em que ela passa por baixo de cada cena.
  const track = svg.querySelector('.rail-track');
  railLength = track.getTotalLength();
  railStops = feet.map(({ x }) => {
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
  walk.len = -1;
}

// Poeira dourada que fica para trás a cada passo.
function puff(point) {
  if (!railDust || railDust.childElementCount > 28) return;
  const mote = document.createElement('i');
  mote.style.left = `${(point.x + (Math.random() - 0.5) * 22).toFixed(1)}px`;
  mote.style.top = `${(point.y - Math.random() * 6).toFixed(1)}px`;
  mote.style.setProperty('--dx', `${((Math.random() - 0.5) * 40).toFixed(1)}px`);
  mote.style.setProperty('--dy', `${(-20 - Math.random() * 46).toFixed(1)}px`);
  mote.addEventListener('animationend', () => mote.remove(), { once: true });
  railDust.appendChild(mote);
}

function cheer() {
  if (!anan) return;
  anan.classList.remove('is-cheer');
  void anan.offsetWidth;
  anan.classList.add('is-cheer');
  clearTimeout(walk.cheer);
  walk.cheer = setTimeout(() => anan.classList.remove('is-cheer'), 1400);
}

// O scroll é o passo: o Anan anda, quica a cada passada, inclina na direção e acende a cena de cima.
function paintRail(p) {
  if (!railLength) return;
  const drawn = Math.min(1, p * 1.08);
  const track = rail.querySelector('.rail-track');
  const len = drawn * railLength;
  const point = track.getPointAtLength(len);

  if (anan) {
    const ahead = track.getPointAtLength(Math.min(railLength, len + 14));
    const slope = (Math.atan2(ahead.y - point.y, Math.max(1, ahead.x - point.x)) * 180) / Math.PI;
    const delta = walk.len < 0 ? 0 : len - walk.len;
    walk.len = len;
    walk.lean += (Math.max(-12, Math.min(12, delta * 0.45)) - walk.lean) * 0.4;
    const hop = motionOk && delta !== 0 ? Math.abs(Math.sin((len / 52) * Math.PI)) : 0;
    anan.style.transform = `translate3d(${point.x.toFixed(1)}px, ${point.y.toFixed(1)}px, 0)`;
    anan.style.setProperty('--hop', hop.toFixed(3));
    anan.style.setProperty('--lean', `${(walk.lean + slope * 0.4).toFixed(2)}deg`);
    anan.classList.toggle('is-back', delta < -0.5);
    if (delta !== 0) {
      anan.classList.remove('is-still');
      clearTimeout(walk.still);
      walk.still = setTimeout(() => anan.classList.add('is-still'), 160);
    }
    if (motionOk && Math.abs(len - walk.dust) > 26) {
      walk.dust = len;
      puff(point);
    }
  }

  let lit = 0;
  railStops.forEach((stop, i) => { if (drawn >= stop - 0.004) lit = i; });
  if (lit === railLit) return;
  const forward = railLit >= 0 && lit > railLit;
  railLit = lit;
  rail.querySelectorAll('.scene').forEach((card, i) => {
    card.classList.toggle('is-lit', i === lit);
    card.classList.toggle('is-past', i < lit);
  });
  skies.forEach((img, i) => img.classList.toggle('is-on', i === lit));
  caption(lit);
  if (forward && motionOk) cheer();
}

function sizeRail() {
  if (!rail || !jornada) return;
  const shift = Math.max(0, rail.scrollWidth - window.innerWidth);
  rail.style.setProperty('--shift', `${shift}px`);
  jornada.style.height = `${Math.round(shift * 1.6 + window.innerHeight * 1.6)}px`;
  drawRailPath();
}

// Por dentro: o anel gira com o scroll e "trava" um instante em cada tela.
function paintOrbit(scene, p) {
  if (!orbitRing) return;
  const span = orbs.length - 1;
  const f = clamp01(p * 1.06) * span;
  const i = Math.min(span, Math.floor(f));
  const t = clamp01(((f - i) - 0.3) / 0.4);
  const at = i + t * t * (3 - 2 * t);
  const rot = -at * (360 / orbs.length);
  orbitRing.style.setProperty('--rot', `${rot.toFixed(2)}deg`);
  orbs.forEach((orb, k) => {
    const angle = k * (360 / orbs.length) + rot;
    const cos = Math.cos((angle * Math.PI) / 180);
    orb.style.setProperty('--dim', Math.min(0.92, Math.max(0, (1 - cos) * 0.95)).toFixed(3));
    const lean = ((((angle + 180) % 360) + 360) % 360) - 180;
    orb.style.setProperty('--sheen', `${(lean * 4).toFixed(1)}%`);
  });
  const step = Math.round(at);
  setStep(scene, step);
  if (orbitCount) orbitCount.textContent = String(step + 1).padStart(2, '0');
}

function setStep(scene, index) {
  if (scene.step === index) return;
  scene.step = index;
  scene.el.style.setProperty('--step', String(index));
  scene.el.dataset.step = String(index);
  document.dispatchEvent(new CustomEvent('stway:step', { detail: { id: scene.el.id, step: index } }));
  scene.items.forEach((item) => {
    const at = Number(item.dataset.step);
    item.classList.toggle('is-on', at === index);
    item.classList.toggle('is-past', at < index);
  });
  if (scene.el.id === 'profundidades') scene.el.style.setProperty('--tone-now', depthTones[index]);
}

const coda = document.querySelector('.coda');
const filmstrip = document.querySelector('.filmstrip');
const acts = [...document.querySelectorAll('.reel a')].map((link) => ({
  link,
  id: link.dataset.act,
  el: document.getElementById(link.dataset.act),
})).filter((act) => act.el);
let currentAct = '';

// Ato atual = seção que cruza o meio da tela; muda a cor do céu e o trilho.
function paintAct(vh) {
  let active = acts[0]?.id || '';
  for (const act of acts) {
    if (act.el.getBoundingClientRect().top <= vh * 0.5) active = act.id;
  }
  if (active === currentAct) return;
  currentAct = active;
  root.dataset.act = active;
  acts.forEach((act) => act.link.classList.toggle('is-on', act.id === active));
}

// Menu do topo: acende o link da seção que ocupa o meio da tela.
const navLinks = [...document.querySelectorAll('.nav a.quiet')]
  .filter((link) => (link.getAttribute('href') || '').startsWith('#'))
  .map((link) => ({
    link,
    el: document.querySelector(link.getAttribute('href')),
  }))
  .filter((item) => item.el);

function paintNav(vh) {
  for (const { link, el } of navLinks) {
    const rect = el.getBoundingClientRect();
    const on = rect.top <= vh * 0.5 && rect.bottom >= vh * 0.5;
    link.classList.toggle('is-on', on);
    if (on) link.setAttribute('aria-current', 'true');
    else link.removeAttribute('aria-current');
  }
}

function paint() {
  const vh = window.innerHeight;

  for (const scene of scenes) {
    const rect = scene.el.getBoundingClientRect();
    if (rect.bottom < -vh * 0.2 || rect.top > vh * 1.2) {
      if (scene.step < 0 && scene.steps) setStep(scene, 0);
      continue;
    }
    // "Presa" só quando o palco ocupa a tela inteira: efeitos de cinema não aparecem no meio da rolagem.
    if (scene.pinned) scene.el.classList.toggle('is-pinned', rect.top <= 2 && rect.bottom >= vh - 2);
    const span = scene.pinned ? rect.height - vh : rect.height;
    const p = span > 0 ? clamp01(-rect.top / span) : 0;
    const rounded = Math.round(p * 1000) / 1000;
    if (rounded !== scene.last) {
      scene.last = rounded;
      scene.el.style.setProperty('--p', String(rounded));
    }
    if (scene.steps && scene.el !== dentro) setStep(scene, Math.min(scene.steps - 1, Math.floor(p * scene.steps)));
    if (scene.el === jornada) paintRail(p);
    if (scene.el === dentro) paintOrbit(scene, p);
    if (scene.el === ocean) paintOcean(p);
  }

  if (strong) {
    const rect = strong.getBoundingClientRect();
    const t = clamp01((vh - rect.top) / (vh + rect.height));
    strong.style.setProperty('--drift', t.toFixed(3));
  }

  if (coda) {
    const rect = coda.getBoundingClientRect();
    coda.style.setProperty('--lit', clamp01((vh - rect.top) / (vh * 0.9)).toFixed(3));
  }

  if (filmstrip) {
    const rect = filmstrip.getBoundingClientRect();
    filmstrip.style.setProperty('--film', clamp01((vh - rect.top) / (vh + rect.height)).toFixed(3));
  }

  paintAct(vh);
  paintNav(vh);

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

/* ─── Strong: uma aula de seminário sobre Gênesis 1:1 ─ */

(function seminario() {
  const row = document.querySelector('.il-row');
  const panel = document.querySelector('.lesson');
  if (!row || !panel) return;
  const pt = document.querySelector('.il-pt');

  // Ordem do texto hebraico (direita → esquerda). Contagens: concordância de Strong.
  const words = [
    {
      heb: 'בְּרֵאשִׁית', tr: 'bərēʾšît', pt: 'No princípio', lemma: 'רֵאשִׁית', num: 'H7225', say: 'be-re-CHÍT',
      gloss: 'começo, primeiro, primícias', morph: 'Preposição בְּ (em) + substantivo feminino singular',
      count: 51, countNote: 'vezes no Antigo Testamento',
      note: 'A Bíblia começa sem artigo: "num princípio", o começo de tudo, não de alguma coisa. João abre o evangelho com a mesma frase para falar do Verbo.',
      refs: [['Jo 1:1', 'No princípio era o Verbo'], ['Pv 8:22', 'O Senhor me possuiu no princípio de seus caminhos'], ['Hb 1:10', 'Tu, Senhor, no princípio fundaste a terra']],
    },
    {
      heb: 'בָּרָא', tr: 'bārāʾ', pt: 'criou', lemma: 'בָּרָא', num: 'H1254', say: 'ba-RÁ',
      gloss: 'criar, formar, fazer surgir', morph: 'Verbo, Qal perfeito, 3ª pessoa masculino singular',
      count: 54, countNote: 'vezes no Antigo Testamento',
      note: 'No Qal, o sujeito é sempre Deus. O texto nunca diz de que material: a ênfase está em quem cria. Em Gn 1:27 o verbo volta três vezes para o ser humano.',
      refs: [['Gn 1:27', 'Criou Deus o homem à sua imagem'], ['Sl 51:10', 'Cria em mim um coração puro'], ['Is 65:17', 'Eu crio céus novos e nova terra']],
    },
    {
      heb: 'אֱלֹהִים', tr: 'ʾĕlōhîm', pt: 'Deus', lemma: 'אֱלֹהִים', num: 'H430', say: 'e-lo-RRÍM (h aspirado)',
      gloss: 'Deus; deuses; juízes', morph: 'Substantivo masculino plural, aqui com verbo no singular',
      count: 2600, countNote: 'vezes, aproximadamente, no Antigo Testamento',
      note: 'A forma é plural, mas o verbo "criou" está no singular: um só Deus age. Muitos gramáticos chamam isso de plural de majestade. O nome aparece 32 vezes só em Gênesis 1.',
      refs: [['Dt 6:4', 'O Senhor, nosso Deus, é o único Senhor'], ['Gn 1:26', 'Façamos o homem à nossa imagem'], ['Is 45:18', 'Deus que formou a terra']],
    },
    {
      heb: 'אֵת', tr: 'ʾēt', pt: '—', lemma: 'אֵת', num: 'H853', say: 'ét',
      gloss: 'marca do objeto direto (não se traduz)', morph: 'Partícula',
      count: 11000, countNote: 'vezes, aproximadamente: a palavra mais comum que não se traduz',
      note: 'Não vira palavra em português: só avisa que "o céu" é o objeto do verbo. É escrita com א e ת, a primeira e a última letra do alfabeto hebraico.',
      refs: [['Gn 1:1', 'aparece duas vezes no versículo'], ['Êx 20:11', 'a mesma dupla: o céu e a terra, com a partícula']],
    },
    {
      heb: 'הַשָּׁמַיִם', tr: 'haššāmayim', pt: 'o céu', lemma: 'שָׁמַיִם', num: 'H8064', say: 'ha-cha-MÁ-yim',
      gloss: 'céu, céus; o firmamento; a morada de Deus', morph: 'Artigo הַ + substantivo masculino plural',
      count: 420, countNote: 'vezes no Antigo Testamento',
      note: '"O céu e a terra" juntos é um merismo: dois extremos para dizer "tudo o que existe". O hebraico não tem uma palavra só para "universo".',
      refs: [['Sl 19:1', 'Os céus manifestam a glória de Deus'], ['Ne 9:6', 'Tu fizeste o céu, o céu dos céus'], ['Ap 21:1', 'Vi um novo céu e uma nova terra']],
    },
    {
      heb: 'וְאֵת', tr: 'wəʾēt', pt: 'e', lemma: 'וְ + אֵת', num: 'H853', say: 've-ÉT',
      gloss: 'e + marca do objeto direto', morph: 'Conjunção וְ (e) + partícula',
      count: 11000, countNote: 'vezes, aproximadamente, para a partícula',
      note: 'O "e" hebraico é só uma letra colada na palavra seguinte. Aqui ele liga os dois extremos da criação: o céu e a terra.',
      refs: [['Gn 1:1', 'liga o céu à terra'], ['Êx 20:11', 'em seis dias fez o Senhor os céus e a terra']],
    },
    {
      heb: 'הָאָרֶץ', tr: 'hāʾāreṣ', pt: 'a terra', lemma: 'אֶרֶץ', num: 'H776', say: 'ha-Á-rets',
      gloss: 'terra, chão, país, o mundo', morph: 'Artigo הָ + substantivo feminino singular',
      count: 2500, countNote: 'vezes, aproximadamente, no Antigo Testamento',
      note: 'A mesma palavra pode ser o chão, a terra de Israel ou o mundo inteiro. O versículo seguinte a mostra "sem forma e vazia" (tōhû wābōhû): o ponto de partida.',
      refs: [['Gn 1:2', 'A terra era sem forma e vazia'], ['Sl 24:1', 'Do Senhor é a terra'], ['Is 66:1', 'A terra, o escabelo dos meus pés']],
    },
  ];

  row.innerHTML = words.map((w, i) => `
    <button type="button" class="il-word" role="tab" aria-selected="false" data-i="${i}" aria-label="${w.heb} — ${w.tr}, ${w.pt === '—' ? 'sem tradução' : w.pt}">
      <span class="il-heb" lang="he">${w.heb}</span>
      <span class="il-tr" dir="ltr">${w.tr}</span>
      <span class="il-gl" dir="ltr">${w.pt}</span>
    </button>`).join('');
  const ptOrder = [0, 1, 2, 4, 5, 6]; // ordem em português (a partícula אֵת não aparece)
  if (pt) pt.innerHTML = ptOrder.map((i) => `<span data-i="${i}">${words[i].pt === 'e' ? 'e' : words[i].pt}</span>`).join(' ') + '.';

  const buttons = [...row.querySelectorAll('.il-word')];
  const field = (name) => panel.querySelector(`[data-f="${name}"]`);
  const fmt = (n) => n.toLocaleString('pt-BR');
  let swapTimer = 0;
  let countFrame = 0;

  function countUp(el, to) {
    cancelAnimationFrame(countFrame);
    if (!motionOk) { el.textContent = fmt(to); return; }
    const start = performance.now();
    const tick = (now) => {
      const t = Math.min(1, (now - start) / 900);
      el.textContent = fmt(Math.round(to * (1 - (1 - t) ** 3)));
      if (t < 1) countFrame = requestAnimationFrame(tick);
    };
    countFrame = requestAnimationFrame(tick);
  }

  function show(index) {
    const w = words[index];
    buttons.forEach((b, i) => {
      b.setAttribute('aria-selected', String(i === index));
      b.tabIndex = i === index ? 0 : -1;
    });
    pt?.querySelectorAll('span').forEach((s) => s.classList.toggle('is-on', Number(s.dataset.i) === index || (index === 3 && s.dataset.i === '4')));
    const apply = () => {
      field('lemma').textContent = w.lemma;
      field('gloss').textContent = w.gloss;
      field('num').textContent = w.num;
      field('translit').textContent = w.tr;
      field('say').textContent = w.say;
      field('morph').textContent = w.morph;
      field('countNote').textContent = w.countNote;
      field('note').textContent = w.note;
      field('refs').innerHTML = w.refs.map(([ref, text], k) => `<li style="--k:${k}"><b>${ref}</b><span>${text}</span></li>`).join('');
      // Barra da concordância em escala logarítmica: 51 ocorrências ainda aparece ao lado de 11 mil.
      panel.style.setProperty('--count', (Math.log10(w.count) / Math.log10(11000)).toFixed(3));
      countUp(field('count'), w.count);
      panel.classList.remove('is-swap', 'is-writing');
      void panel.offsetWidth;
      panel.classList.add('is-writing');
    };
    clearTimeout(swapTimer);
    if (!motionOk) return apply();
    panel.classList.add('is-swap');
    swapTimer = setTimeout(apply, 240);
  }

  buttons.forEach((button, i) => {
    button.addEventListener('click', () => show(i));
    button.addEventListener('keydown', (event) => {
      // Em hebraico, "seguinte" fica à esquerda.
      if (event.key !== 'ArrowRight' && event.key !== 'ArrowLeft') return;
      event.preventDefault();
      const next = (i + (event.key === 'ArrowLeft' ? 1 : -1) + buttons.length) % buttons.length;
      buttons[next].focus();
      show(next);
    });
  });
  show(1);
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

  let dpr = 1;

  function resize() {
    // Resolução nativa da tela (até 3x) para estrelas nítidas em celular e 4K.
    dpr = Math.min(window.devicePixelRatio || 1, 3);
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
      // Alinha cada estrela ao pixel físico: sem borrão de antialiasing.
      const size = Math.max(1, Math.round((0.4 + star.z * 1.3) * dpr)) / dpr;
      ctx.fillRect(Math.round(star.x * dpr) / dpr, Math.round(y * dpr) / dpr, size, size);
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

/* ─── Títulos: máscara palavra por palavra ─────────── */

(function titles() {
  const heads = document.querySelectorAll('.display');
  if (!motionOk || !('IntersectionObserver' in window)) return;
  let index = 0;

  function wrap(node) {
    [...node.childNodes].forEach((child) => {
      if (child.nodeType === Node.TEXT_NODE) {
        const parts = child.textContent.split(/(\s+)/);
        const frag = document.createDocumentFragment();
        parts.forEach((part) => {
          if (!part) return;
          if (/^\s+$/.test(part)) {
            frag.appendChild(document.createTextNode(part));
            return;
          }
          const outer = document.createElement('span');
          outer.className = 'sw';
          const inner = document.createElement('span');
          inner.style.setProperty('--i', String(index));
          index += 1;
          inner.textContent = part;
          outer.appendChild(inner);
          frag.appendChild(outer);
        });
        child.replaceWith(frag);
      } else if (child.nodeType === Node.ELEMENT_NODE && child.tagName !== 'BR') {
        wrap(child);
      }
    });
  }

  heads.forEach((head) => {
    index = 0;
    head.setAttribute('aria-label', head.textContent.replace(/\s+/g, ' ').trim());
    wrap(head);
    head.querySelectorAll('.sw').forEach((sw) => sw.setAttribute('aria-hidden', 'true'));
  });

  const watcher = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue;
      entry.target.classList.add('is-shown');
      watcher.unobserve(entry.target);
    }
  }, { threshold: 0.4 });
  heads.forEach((head) => watcher.observe(head));
})();

/* ─── Scroll suave (Lenis) ─────────────────────────── */

(function smooth() {
  if (!motionOk || !window.Lenis) return;
  lenis = new window.Lenis({ lerp: 0.085, smoothWheel: true, anchors: true });
  window.stwayLenis = lenis;
  lenis.on('scroll', queuePaint);
  const raf = (time) => {
    lenis.raf(time);
    requestAnimationFrame(raf);
  };
  requestAnimationFrame(raf);
})();

/* ─── Parallax do mouse e botões magnéticos ────────── */

(function pointer() {
  if (!motionOk || !finePointer) return;
  const opening = document.querySelector('.opening');

  window.addEventListener('pointermove', (event) => {
    if (!opening || window.scrollY >= window.innerHeight) return;
    opening.style.setProperty('--mx', ((event.clientX / window.innerWidth) * 2 - 1).toFixed(3));
    opening.style.setProperty('--my', ((event.clientY / window.innerHeight) * 2 - 1).toFixed(3));
  }, { passive: true });

  document.querySelectorAll('.hero-actions .btn, .coda-cta .btn, .head-actions .btn').forEach((button) => {
    button.addEventListener('pointermove', (event) => {
      const rect = button.getBoundingClientRect();
      const dx = event.clientX - (rect.left + rect.width / 2);
      const dy = event.clientY - (rect.top + rect.height / 2);
      button.style.translate = `${(dx * 0.22).toFixed(1)}px ${(dy * 0.3).toFixed(1)}px`;
    });
    button.addEventListener('pointerleave', () => { button.style.translate = ''; });
  });
})();

/* ─── Por onde começar: as cartas se distribuem e inclinam com o mouse ─ */

(function deck() {
  const deckEl = document.querySelector('.deck');
  if (!deckEl) return;
  if (!motionOk || !('IntersectionObserver' in window)) {
    deckEl.classList.add('in');
    return;
  }
  const watcher = new IntersectionObserver((entries) => {
    if (!entries.some((entry) => entry.isIntersecting)) return;
    deckEl.classList.add('in');
    watcher.disconnect();
  }, { threshold: 0.25 });
  watcher.observe(deckEl);

  if (!finePointer) return;
  deckEl.querySelectorAll('.deck-card').forEach((card) => {
    card.addEventListener('pointermove', (event) => {
      const rect = card.getBoundingClientRect();
      const x = (event.clientX - rect.left) / rect.width;
      const y = (event.clientY - rect.top) / rect.height;
      card.classList.add('is-tilting');
      card.style.setProperty('--ry', `${((x - 0.5) * 16).toFixed(2)}deg`);
      card.style.setProperty('--rx', `${((0.5 - y) * 12).toFixed(2)}deg`);
      card.style.setProperty('--gx', `${(x * 100).toFixed(1)}%`);
      card.style.setProperty('--gy', `${(y * 100).toFixed(1)}%`);
    });
    card.addEventListener('pointerleave', () => {
      card.classList.remove('is-tilting');
      card.style.removeProperty('--rx');
      card.style.removeProperty('--ry');
    });
  });
})();

/* ─── Juntos: lamparinas na noite — o par, a roda em volta do fogo, a caravana ─ */

(function juntos() {
  const section = document.querySelector('.juntos');
  const box = section?.querySelector('.pilgrims');
  if (!box) return;
  const names = ['Você', 'Ana', 'Pedro', 'Júlia', 'Davi', 'Rute', 'Tiago', 'Sara', 'João', 'Ester', 'Lucas', 'Raquel', 'Marcos', 'Lia'];
  const N = names.length;
  const studied = new Set([0, 1, 2, 4, 5]);

  // Par: os dois nas pontas do fio.
  const pair = (i) => (i === 0 ? [30, 57.1, 1] : i === 1 ? [70, 57.1, 1] : [50, 60, 0]);
  // Roda: elipse no chão em volta da fogueira; quem está na frente parece maior.
  const ring = (i) => {
    if (i > 6) return [50, 60, 0];
    const a = Math.PI / 2 + (i * 2 * Math.PI) / 7;
    return [50 + Math.cos(a) * 27, 60 + Math.sin(a) * 13, 0.82 + Math.sin(a) * 0.22];
  };
  // Caravana: a estrada sai de perto (embaixo, à esquerda) e some no horizonte.
  const road = (t) => {
    const p = [[6, 97], [66, 95], [22, 54], [84, 30]];
    const u = 1 - t;
    const x = u ** 3 * p[0][0] + 3 * u * u * t * p[1][0] + 3 * u * t * t * p[2][0] + t ** 3 * p[3][0];
    const y = u ** 3 * p[0][1] + 3 * u * u * t * p[1][1] + 3 * u * t * t * p[2][1] + t ** 3 * p[3][1];
    return [x, y];
  };
  const order = [7, 3, 10, 5, 12, 1, 9, 0, 4, 13, 2, 6, 11, 8]; // posição na fila → pessoa (o 1º vai mais longe)
  const caravan = (i) => {
    const rank = order.indexOf(i);
    const t = rank < 3 ? 0.97 - rank * 0.085 : 0.8 - (rank - 3) * 0.066;
    const [x, y] = road(Math.max(0.04, t));
    return [x, y, 1.2 - t * 0.78];
  };
  const forms = [pair, ring, caravan];
  const steps = [2120, 1984, 1871];

  let html = '';
  for (let i = 0; i < N; i += 1) {
    const vars = forms.map((f, k) => {
      const [x, y, s] = f(i);
      return `--x${k}:${x.toFixed(2)}%;--y${k}:${y.toFixed(2)}%;--s${k}:${s.toFixed(3)}`;
    }).join(';');
    const rank = order.indexOf(i);
    const medal = rank === 0 ? ' gold' : rank === 1 ? ' silver' : rank === 2 ? ' bronze' : '';
    const pairNote = i < 2 ? '<em class="when-0">estudou hoje</em>' : '';
    const rankNote = rank < 3 ? `<em class="when-2">${rank + 1}º · ${steps[rank].toLocaleString('pt-BR')} passos</em>`
      : i === 0 ? `<em class="when-2">${rank + 1}º no mês</em>` : '';
    html += `<span class="lamp${studied.has(i) ? ' done' : ''}${medal}${i === 0 ? ' me' : ''}" style="${vars};--i:${i};--f:${(i * 0.37) % 1.7}s">
      <i></i><b>${names[i]}</b>${pairNote}${rankNote}
    </span>`;
  }
  box.innerHTML = html;

  const pts = (f, n) => Array.from({ length: n }, (_, i) => f(i)).map(([x, y]) => ({ x: x * 10, y: y * 7 }));
  // Roda: a elipse inteira, desenhada no chão.
  const ringD = `M 230 420 A 270 91 0 1 0 770 420 A 270 91 0 1 0 230 420`;
  section.querySelector('.link-1')?.setAttribute('d', ringD);
  const roadPts = Array.from({ length: 24 }, (_, k) => road(k / 23)).map(([x, y]) => ({ x: x * 10, y: y * 7 }));
  section.querySelector('.link-2')?.setAttribute('d', curveThrough(roadPts));
  void pts;
})();

/* ─── Advento: contagem regressiva e o mural dos 26 postais ─ */

(function adventoHome() {
  // Home antiga: seção com mural. Home nova: o bilhete do Advento no portal (só a contagem).
  const section = document.querySelector('.advento-home, .ticket-advento');
  if (!section) return;
  const titles = ['O Verbo se fez carne', 'No princípio', 'Imagem', 'Chamado', 'Estrelas', 'Moriá', 'Moisés', 'Páscoa',
    'O Rei no monte', 'Pobres de espírito', 'Os que choram', 'Pacificadores', 'Batismo', 'Sermão', 'Pai nosso',
    'Meu pastor', 'Humildade', 'Parábolas', 'Milagres', 'Ansiedade', 'Ceia', 'Cruz', 'Ressurreição', 'Descanso',
    'Alegria', 'Fome de justiça'];
  const start = new Date(2026, 10, 29);
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const tile = (n) => {
    const when = new Date(2026, 10, 28 + n);
    const veiled = n > 1 && when > today;
    const nn = String(n).padStart(2, '0');
    return `<figure class="wall-postal${veiled ? ' is-veiled' : ''}">
      <img src="/advento/img/dia-${nn}.webp" alt="" width="374" height="314" loading="lazy" decoding="async" />
      ${veiled ? `<span class="wall-seal">${when.getDate()}/${when.getMonth() + 1}</span>` : ''}
      <figcaption><b>Dia ${n}</b>${titles[n - 1]}</figcaption>
    </figure>`;
  };
  const rows = section.querySelectorAll('.wall-row');
  const first = Array.from({ length: 13 }, (_, i) => tile(i + 1)).join('');
  const second = Array.from({ length: 13 }, (_, i) => tile(i + 14)).join('');
  // Conteúdo duplicado: a faixa anda sem emenda.
  if (rows[0]) rows[0].innerHTML = `<div class="wall-track">${first}${first}</div>`;
  if (rows[1]) rows[1].innerHTML = `<div class="wall-track">${second}${second}</div>`;

  const counter = section.querySelector('[data-countdown]');
  if (!counter) return;
  const cells = Object.fromEntries([...counter.querySelectorAll('[data-unit]')].map((el) => [el.dataset.unit, el]));
  const label = counter.querySelector('.countdown-label');

  function tick() {
    const now = new Date();
    const ms = start - now;
    if (ms <= 0) {
      const day = Math.floor((now - start) / 86400000) + 1;
      if (day > 26) {
        counter.hidden = true;
        return false;
      }
      label.textContent = `Hoje é o dia ${day} de 26`;
      counter.querySelector('.countdown-cells').innerHTML = `<span class="is-today"><b>${titles[day - 1]}</b><small>a cena de hoje</small></span>`;
      return false;
    }
    const s = Math.floor(ms / 1000);
    const parts = { d: Math.floor(s / 86400), h: Math.floor(s / 3600) % 24, m: Math.floor(s / 60) % 60, s: s % 60 };
    Object.entries(parts).forEach(([unit, value]) => {
      const el = cells[unit];
      const text = String(value).padStart(2, '0');
      if (el && el.textContent !== text) {
        el.textContent = text;
        el.classList.remove('tick');
        void el.offsetWidth;
        el.classList.add('tick');
      }
    });
    return true;
  }
  if (tick()) setInterval(tick, 1000);
})();

/* ─── Anan, o guia: acompanha a página inteira e comenta cada ato ─ */

const ANAN_FACE = `<svg class="anan-face" viewBox="0 0 480 356" aria-hidden="true">
  <g class="face-feliz"><g class="anan-eyes"><path d="M199 168 V199" /><path d="M273 168 V199" /></g><path class="anan-mouth" d="M210 234 Q236 270 263 234" /></g>
  <g class="face-sucesso"><path d="M162 195 Q187 160 212 195" /><path d="M264 195 Q289 160 314 195" /><path class="anan-open" d="M199 224 Q237 224 275 224 Q237 308 199 224 Z" /></g>
</svg>`;

(function guide() {
  // Home: fala por ato. Páginas internas: fala nas seções marcadas com data-anan.
  // Folhas do app (/palco, /strong…) falam como a home: uma fala por ato, fixo no data-act da página.
  const homePage = Boolean(document.querySelector('.prologue')) || document.body.dataset.guide === 'act';
  const pageLines = [...document.querySelectorAll('[data-anan]')];
  if (!homePage && !pageLines.length) return;
  let off = false;
  try { off = sessionStorage.getItem('stway-guide-off') === '1'; } catch (_) { /* sem storage */ }
  if (off) return;

  // Mesma conta do contador da seção: dias inteiros que faltam.
  const msToAdvent = new Date(2026, 10, 29) - new Date();
  const daysToAdvent = Math.floor(msToAdvent / 86400000);
  const adventLine = msToAdvent <= 0 ? 'O Advento já começou. Tem cena nova hoje!'
    : daysToAdvent >= 2 ? `Faltam ${daysToAdvent} dias pro Advento. Bora junto?`
      : 'O Advento começa já já. Bora junto?';
  const lines = {
    abertura: 'Oi! Eu sou o Anan. Vou caminhar com você.',
    conhecer: 'Role que eu te mostro tudo. Gostou? Toque pra entrar!',
    palco: 'Toque no texto. Eu digo na hora se acertou.',
    profundidades: 'Mesmo texto, três voltas. Cada uma mais funda.',
    strong: 'Toque numa palavra em hebraico. Hoje tem aula!',
    dentro: 'Hoje, Bíblia, Juntos… tá tudo aqui dentro.',
    juntos: 'Chama alguém? Junto a gente vai mais longe.',
    postais: 'Terminou a cena, ganhou postal. Eu adoro carimbar!',
    advento: adventLine,
    comecar: 'E aí, o que te traz aqui?',
    planos: 'A Bíblia é grátis. O resto custa menos de 25 centavos por dia!',
    contato: 'Igreja, célula, imprensa? Escreve pra gente.',
    coda: 'Vamos? É grátis no Android.',
  };
  const cheerActs = new Set(['postais', 'coda', 'advento', 'planos']);
  // Nas seções com passos, a fala acompanha o que está na tela.
  const stepLines = {
    palco: [
      'Toque no versículo o trecho que responde.',
      'Verdadeiro ou falso? Só vale o que o texto diz.',
      'Três caminhos. Só um é fiel ao texto.',
      'Falta uma palavra. Qual encaixa?',
      'Arraste os trechos na ordem em que acontecem.',
      'Ligue o versículo ao contexto dele.',
      'No fim, o versículo inteiro. Passos extras!',
    ],
    profundidades: [
      'Primeira volta: toque em quem cria. Eu espero!',
      'Segunda volta: ligue a terra do 1:1 ao 1:2.',
      'Última volta, a mais funda. Escolha com calma.',
    ],
    juntos: [
      'Chama alguém pra caminhar do seu lado?',
      'Até domingo! Quem chega primeiro?',
      'No grupo, todo mundo caminha no mesmo texto.',
      'A caravana do mês. Bora subir junto?',
    ],
    postais: [
      'Terminou a cena…',
      '…e a pintura vira postal.',
      'Carimbado! Eu adoro essa parte.',
      'E o seu álbum vai crescendo.',
    ],
  };
  const stepCheer = { 'palco:6': true, 'postais:2': true, 'juntos:1': true };
  let stepTimer = 0;

  function lineFor(act) {
    const steps = stepLines[act];
    if (!steps) return lines[act];
    const n = Number(document.getElementById(act)?.dataset.step || 0);
    return steps[Math.max(0, Math.min(steps.length - 1, n))];
  }

  // Outras partes da página pedem uma fala direta (ex.: acerto no mergulho).
  document.addEventListener('stway:anan', (event) => {
    if (el.classList.contains('is-away')) return;
    clearTimeout(stepTimer);
    say(event.detail.line, event.detail.hold);
    if (event.detail.cheer) cheer();
  });

  document.addEventListener('stway:step', (event) => {
    const { id, step } = event.detail;
    if (!stepLines[id] || root.dataset.act !== id || last !== id) return;
    clearTimeout(stepTimer);
    // Espera a rolagem assentar: quem rola rápido não ouve cinco falas seguidas.
    stepTimer = setTimeout(() => {
      if (root.dataset.act !== id) return;
      say(stepLines[id][step]);
      if (stepCheer[`${id}:${step}`]) cheer();
    }, 280);
  });

  const el = document.createElement('div');
  el.className = 'guide';
  el.setAttribute('aria-hidden', 'true');
  el.innerHTML = `
    <div class="guide-bubble"><p></p></div>
    <div class="guide-body"><div class="guide-float"><img src="/img/anan.webp" alt="" width="240" height="178" />${ANAN_FACE}</div></div>
    <button type="button" class="guide-close" tabindex="-1" aria-label="Esconder o Anan">×</button>`;
  document.body.appendChild(el);
  const bubble = el.querySelector('.guide-bubble p');
  let typing = 0;
  let hideTimer = 0;
  let cheerTimer = 0;
  let last = '';

  function cheer(ms = 1300) {
    el.classList.remove('is-cheer');
    void el.offsetWidth;
    el.classList.add('is-cheer');
    clearTimeout(cheerTimer);
    cheerTimer = setTimeout(() => el.classList.remove('is-cheer'), ms);
  }

  function say(text, hold) {
    clearInterval(typing);
    clearTimeout(hideTimer);
    el.classList.toggle('is-pointing', Boolean(hold));
    el.classList.add('is-talking');
    if (!motionOk) {
      bubble.textContent = text;
    } else {
      let n = 0;
      bubble.textContent = '';
      typing = setInterval(() => {
        n += 1;
        bubble.textContent = text.slice(0, n);
        if (n >= text.length) clearInterval(typing);
      }, 22);
    }
    if (hold) return; // fala fixa: fica até a pessoa agir
    hideTimer = setTimeout(() => el.classList.remove('is-talking'), window.innerWidth < 860 ? 4200 : 6200);
  }

  // Do lado direito, o Anan sobe e desce pelo trilho de capítulos, ao lado do ato atual.
  const reel = document.querySelector('.reel');
  function place() {
    const link = reel?.querySelector('a.is-on');
    if (!link || getComputedStyle(reel).display === 'none') {
      el.style.removeProperty('--gy');
      el.style.removeProperty('--gr');
      return;
    }
    const tick = link.querySelector('i').getBoundingClientRect();
    el.style.setProperty('--gy', `${Math.round(tick.top + tick.height / 2)}px`);
    el.style.setProperty('--gr', `${Math.round(window.innerWidth - tick.right - 6)}px`);
  }
  window.addEventListener('resize', place);
  root.classList.add('has-guide');

  function onAct() {
    place();
    if (!homePage) {
      el.classList.toggle('is-away', root.classList.contains('menu-open') || root.classList.contains('folha-open'));
      return;
    }
    const act = root.dataset.act || 'abertura';
    // Na trilha o Anan já está andando na estrada: o guia sai de cena.
    el.classList.toggle('is-away', act === 'jornada' || root.classList.contains('menu-open') || root.classList.contains('folha-open'));
    if (act === 'jornada' || act === last) return;
    last = act;
    const line = lineFor(act);
    if (!line) return;
    say(line);
    if (cheerActs.has(act)) cheer();
  }

  // Contato e coda não têm data-act próprio: olha a posição da página.
  const extra = [['contato', document.querySelector('#contato')], ['coda', document.querySelector('.coda')]];
  function actNow() {
    const vh = window.innerHeight;
    for (let i = extra.length - 1; i >= 0; i -= 1) {
      const [name, node] = extra[i];
      if (node && node.getBoundingClientRect().top < vh * 0.55) {
        if (last !== name) {
          last = name;
          say(lines[name]);
          if (cheerActs.has(name)) cheer();
        }
        return true;
      }
    }
    return false;
  }

  new MutationObserver(() => { if (!actNow()) onAct(); }).observe(root, { attributes: true, attributeFilter: ['data-act', 'class'] });
  window.addEventListener('scroll', () => {
    if (!actNow() && (last === 'contato' || last === 'coda')) { last = ''; onAct(); }
  }, { passive: true });

  el.querySelector('.guide-body').addEventListener('click', () => {
    cheer();
    const pool = ['Uma cena por dia basta.', 'O texto vem primeiro. Sempre.', 'Eu fico feliz quando você volta amanhã.', lineFor(root.dataset.act) || lines.abertura];
    say(pool[Math.floor(Math.random() * pool.length)]);
  });
  el.querySelector('.guide-close').addEventListener('click', () => {
    el.classList.add('is-gone');
    root.classList.remove('has-guide');
    try { sessionStorage.setItem('stway-guide-off', '1'); } catch (_) { /* sem storage */ }
    setTimeout(() => el.remove(), 700);
  });
  document.querySelectorAll('.btn-gold').forEach((btn) => {
    btn.addEventListener('pointerenter', () => cheer(900));
  });

  if (!homePage) {
    let current = null;
    new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting || entry.target === current || !el.classList.contains('is-in')) return;
        current = entry.target;
        say(entry.target.dataset.anan);
        if (entry.target.hasAttribute('data-anan-cheer')) cheer();
      });
    }, { rootMargin: '-42% 0px -42% 0px' }).observe(pageLines[0]);
    pageLines.slice(1).forEach((node) => {
      new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting || entry.target === current) return;
          current = entry.target;
          say(entry.target.dataset.anan);
          if (entry.target.hasAttribute('data-anan-cheer')) cheer();
        });
      }, { rootMargin: '-42% 0px -42% 0px' }).observe(node);
    });
    setTimeout(() => {
      el.classList.add('is-in');
      if (!current) { current = pageLines[0]; say(pageLines[0].dataset.anan); }
    }, 1200);
    return;
  }

  // Entra depois da abertura (ou logo, se ela já foi vista).
  const enter = () => {
    el.classList.add('is-in');
    onAct();
  };
  if (root.classList.contains('intro') && !root.classList.contains('s4')) {
    const wait = new MutationObserver(() => {
      if (root.classList.contains('s4')) {
        wait.disconnect();
        setTimeout(enter, 1600);
      }
    });
    wait.observe(root, { attributes: true, attributeFilter: ['class'] });
  } else {
    setTimeout(enter, 900);
  }
})();

/* ─── Profundidades: o toque cai bem em cima de "Deus" ─ */

(function diveTap() {
  const verse = document.querySelector('.dive-stage .v1');
  const word = verse?.querySelector('.m-who');
  const tap = verse?.querySelector('.tap');
  if (!word || !tap) return;
  function place() {
    const v = verse.getBoundingClientRect();
    const w = word.getBoundingClientRect();
    if (!w.width) return;
    tap.style.setProperty('--tx', `${(w.left - v.left + w.width / 2 - 23).toFixed(1)}px`);
    tap.style.setProperty('--ty', `${(w.top - v.top + w.height / 2 - 23).toFixed(1)}px`);
  }
  place();
  window.addEventListener('resize', place);
  document.fonts?.ready.then(place);
})();

/* ─── Profundidades: neve marinha em três camadas (perto anda mais rápido) ─ */

(function marineSnow() {
  const layers = document.querySelectorAll('.ocean-snow .snow-layer');
  if (!layers.length) return;
  const counts = [28, 22, 14];
  layers.forEach((layer, k) => {
    let html = '';
    for (let i = 0; i < counts[k]; i += 1) {
      const x = Math.random() * 100;
      const y = Math.random() * 260;
      const d = (Math.random() * -14).toFixed(1);
      const t = (10 + Math.random() * 12).toFixed(1);
      html += `<i style="left:${x.toFixed(1)}%;top:${y.toFixed(1)}%;animation-delay:${d}s;animation-duration:${t}s"></i>`;
    }
    layer.innerHTML = html;
  });
})();

/* ─── Profundidades: o mergulho jogável — três voltas, cada uma libera a próxima ─ */

(function mergulho() {
  const sec = document.querySelector('.mergulho');
  if (!sec) return;
  const steps = [...sec.querySelectorAll('.mg-step')];
  const modes = [...sec.querySelectorAll('.mg-mode')];
  const diveBtn = sec.querySelector('.mg-dive');
  const showBtn = sec.querySelector('.mg-show');
  const meter = sec.querySelector('[data-meter]');
  const depths = [0, 40, 85, 120];
  const praise = [
    'Certo. "Deus" é quem faz o verbo "criou": a Bíblia começa por quem age.',
    'Isso. O 1:2 mostra a terra crua, sem forma e vazia: é dali que Deus vai dar forma.',
    'É isso. Antes de qualquer coisa existir, Deus já age. A Bíblia começa por Ele, não por nós.',
  ];
  const hints = [
    'Quase. Quem faz a ação de "criou"?',
    'Ainda não. O que o versículo diz que a terra "era"?',
    'Pense de novo: quem está agindo na primeira frase?',
  ];
  const anan = (line, happy, hold) => document.dispatchEvent(new CustomEvent('stway:anan', { detail: { line, cheer: happy, hold } }));
  let depth = 0;
  let solved = false;
  let meterFrame = 0;

  function countMeter(to) {
    cancelAnimationFrame(meterFrame);
    const from = Number(meter.textContent) || 0;
    if (!motionOk) { meter.textContent = String(to); return; }
    const start = performance.now();
    const tick = (now) => {
      const t = Math.min(1, (now - start) / 1600);
      meter.textContent = String(Math.round(from + (to - from) * (1 - (1 - t) ** 3)));
      if (t < 1) meterFrame = requestAnimationFrame(tick);
    };
    meterFrame = requestAnimationFrame(tick);
  }

  function say(step, text, kind) {
    const el = steps[step].querySelector('.mg-say');
    if (!el) return;
    el.textContent = text;
    el.className = `mg-say ${kind}`;
    if (kind === 'bad') {
      el.classList.remove('shake');
      void el.offsetWidth;
      el.classList.add('shake');
    }
  }

  function solve() {
    if (solved) return;
    solved = true;
    clearTimeout(idleTimer);
    steps[depth].classList.remove('is-cueing');
    say(depth, praise[depth], 'ok');
    steps[depth].classList.add('is-solved');
    modes[depth].classList.remove('is-current');
    modes[depth].classList.add('is-done');
    if (modes[depth + 1]) {
      modes[depth + 1].classList.remove('is-locked');
      modes[depth + 1].classList.add('is-unlocking');
    }
    showBtn.hidden = true;
    diveBtn.hidden = false;
    diveBtn.innerHTML = depth < 2 ? 'Mergulhar mais fundo <span aria-hidden="true">↓</span>' : 'Ir até o fundo <span aria-hidden="true">↓</span>';
    anan(depth < 2 ? `${modes[depth].querySelector('b').textContent} concluída! Liberou a próxima.` : 'Você chegou ao fundo do texto!', true);
  }

  function miss(step, button) {
    say(step, hints[step], 'bad');
    button.classList.remove('is-wrong');
    void button.offsetWidth;
    button.classList.add('is-wrong');
  }

  // Cartela de cinema entre as voltas: nome do modo e os metros contando.
  const card = sec.querySelector('.mg-card');
  const cards = [null, ['Modo II', 'Compreensão'], ['Modo III', 'Interpretação'], ['O fundo', 'Deus no centro']];
  let cardTimer = 0;

  function titleCard(n) {
    if (!card || !cards[n]) return 0;
    card.querySelector('.mg-card-k').textContent = cards[n][0];
    card.querySelector('.mg-card-t').textContent = cards[n][1];
    const em = card.querySelector('.mg-card-m em');
    const from = depths[n - 1];
    const to = depths[n];
    const start = performance.now();
    const tick = (now) => {
      const t = Math.min(1, (now - start) / 1500);
      em.textContent = String(Math.round(from + (to - from) * (1 - (1 - t) ** 3)));
      if (t < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
    sec.classList.add('is-card');
    clearTimeout(cardTimer);
    cardTimer = setTimeout(() => sec.classList.remove('is-card'), 1900);
    return 1500;
  }

  function go(next) {
    depth = next;
    solved = false;
    diveBtn.hidden = true;
    const wait = motionOk && next > 0 ? titleCard(next) : 0;
    window.stwayFx?.dive(next);
    sec.classList.toggle('is-down', next > 0);
    // Antes da troca, a volta atual sobe e some; a nova entra depois da cartela.
    steps.forEach((s) => { if (s.classList.contains('is-on')) s.classList.add('is-leaving'); });
    setTimeout(() => swap(next), wait);
  }

  // A câmera acompanha: depois da cartela, o palco fica no meio da tela.
  const stage = sec.querySelector('.mg-stage');
  function frameStage() {
    const r = stage.getBoundingClientRect();
    const target = window.scrollY + r.top - Math.max(80, (window.innerHeight - r.height) / 2);
    if (window.stwayLenis) window.stwayLenis.scrollTo(target, { duration: 1.2 });
    else window.scrollTo({ top: target, behavior: motionOk ? 'smooth' : 'auto' });
  }

  function swap(next) {
    if (next > 0) frameStage();
    sec.dataset.depth = String(depth);
    sec.dataset.step = String(Math.min(depth, 2));
    steps.forEach((s, i) => {
      s.classList.remove('is-leaving');
      s.classList.toggle('is-on', i === depth);
      s.classList.toggle('is-past', i < depth);
    });
    if (next === 3) window.stwayFx?.reveal(sec.querySelector('.mg-core b'));
    modes.forEach((m, i) => {
      m.classList.toggle('is-current', i === depth);
      m.classList.remove('is-unlocking');
    });
    diveBtn.hidden = true;
    showBtn.hidden = depth > 2;
    countMeter(depths[depth]);
    sec.classList.remove('is-diving');
    void sec.offsetWidth;
    sec.classList.add('is-diving');
    if (depth <= 2) setTimeout(teachNow, 900);
    if (depth === 3) setTimeout(() => anan('Deus no centro. Eu não canso de ver isso.', true), 2600);
  }

  // Volta 1: toque a palavra
  steps[0].querySelectorAll('.mg-w').forEach((b) => b.addEventListener('click', () => {
    if (depth !== 0 || solved) return;
    if (b.hasAttribute('data-ok')) { b.classList.add('is-right'); solve(); } else miss(0, b);
  }));

  // Volta 2: conecte "a terra" ao que ela "era"
  const area = steps[1].querySelector('.mg-link-area');
  const thread = area.querySelector('.mg-thread');
  const a = area.querySelector('[data-a]');
  let picked = null;
  function drawThread(to) {
    const box = area.getBoundingClientRect();
    const r1 = a.getBoundingClientRect();
    const r2 = to.getBoundingClientRect();
    const x1 = r1.left - box.left + r1.width / 2;
    const y1 = r1.bottom - box.top + 2;
    const x2 = r2.left - box.left + r2.width / 2;
    const y2 = r2.top - box.top - 2;
    thread.setAttribute('viewBox', `0 0 ${box.width.toFixed(0)} ${box.height.toFixed(0)}`);
    const mid = (y1 + y2) / 2;
    thread.querySelector('path').setAttribute('d', `M ${x1} ${y1} C ${x1} ${mid}, ${x2} ${mid}, ${x2} ${y2}`);
    area.classList.add('is-linked');
  }
  a.addEventListener('click', () => {
    if (depth !== 1 || solved) return;
    picked = 'a';
    a.classList.add('is-picked');
    say(1, 'Agora toque no que o 1:2 diz que a terra era.', '');
  });
  area.querySelectorAll('[data-b]').forEach((b) => b.addEventListener('click', () => {
    if (depth !== 1 || solved) return;
    if (picked !== 'a') { say(1, 'Comece por "a terra", no 1:1.', 'bad'); a.classList.add('is-hint'); return; }
    if (b.hasAttribute('data-ok')) { b.classList.add('is-right'); drawThread(b); solve(); } else miss(1, b);
  }));
  window.addEventListener('resize', () => {
    const right = area.querySelector('[data-b].is-right');
    if (right) drawThread(right);
  });

  // Volta 3: escolha
  steps[2].querySelectorAll('.mg-opt').forEach((b) => b.addEventListener('click', () => {
    if (depth !== 2 || solved) return;
    if (b.hasAttribute('data-ok')) { b.classList.add('is-right'); solve(); } else miss(2, b);
  }));

  // O Anan da lateral explica a tarefa quando o versículo entra na tela, e insiste se a pessoa travar.
  const teach = [
    'Sua vez! Clique na palavra do versículo que responde: quem cria?',
    'Clique em "a terra" no 1:1. Depois, no que o 1:2 diz que ela era.',
    'Agora escolha uma das três respostas. Sem pressa.',
  ];
  const nudge = [
    'Dica: é quem faz a ação de "criou". Clique nessa palavra.',
    'Dica: a terra "era sem forma e vazia". Clique nessas palavras.',
    'Dica: quem está agindo na primeira frase da Bíblia?',
  ];
  let inView = false;
  let taught = -1;
  let idleTimer = 0;
  // O dedo fantasma vai até a palavra certa (posição medida no layout atual).
  const finger = steps[0].querySelector('.mg-finger');
  function placeFinger() {
    const verse = finger?.parentElement;
    const target = verse?.querySelector('[data-ok]');
    if (!target) return;
    const v = verse.getBoundingClientRect();
    const t = target.getBoundingClientRect();
    if (!t.width) return;
    finger.style.setProperty('--fx', `${t.left - v.left + t.width / 2}px`);
    finger.style.setProperty('--fy', `${t.top - v.top + t.height * 0.7}px`);
  }
  window.addEventListener('resize', placeFinger);

  function teachNow() {
    placeFinger();
    if (!inView || solved || depth > 2 || taught === depth) return;
    taught = depth;
    anan(teach[depth], false, true);
    steps[depth].classList.add('is-cueing');
    clearTimeout(idleTimer);
    const at = depth;
    idleTimer = setTimeout(() => { if (!solved && depth === at && inView) anan(nudge[at], false, true); }, 9000);
  }
  new IntersectionObserver((entries) => {
    inView = entries.some((e) => e.isIntersecting);
    if (inView) setTimeout(teachNow, 500);
  }, { threshold: 0.55 }).observe(sec.querySelector('.mg-stage'));
  // Qualquer toque no palco encerra a dica visual.
  sec.querySelector('.mg-stage').addEventListener('pointerdown', () => steps[depth]?.classList.remove('is-cueing'));

  diveBtn.addEventListener('click', () => go(depth + 1));
  showBtn.addEventListener('click', () => {
    if (depth === 0) steps[0].querySelector('[data-ok]').click();
    if (depth === 1) { a.click(); area.querySelector('[data-b][data-ok]').click(); }
    if (depth === 2) steps[2].querySelector('[data-ok]').click();
  });
  sec.querySelector('.mg-again').addEventListener('click', () => {
    sec.querySelectorAll('.is-right, .is-picked, .is-wrong, .is-hint').forEach((el) => el.classList.remove('is-right', 'is-picked', 'is-wrong', 'is-hint'));
    sec.querySelectorAll('.mg-say').forEach((el) => { el.textContent = ''; el.className = 'mg-say'; });
    steps.forEach((s) => s.classList.remove('is-solved'));
    area.classList.remove('is-linked');
    picked = null;
    modes.forEach((m, i) => { m.className = `mg-mode${i === 0 ? ' is-current' : ' is-locked'}`; });
    window.stwayFx?.reset();
    taught = -1;
    go(0);
  });
})();

/* ─── Mergulho: luz viva na água — partículas, bolhas e a luz que forma "Deus" ─ */

(function mergulhoFx() {
  const sec = document.querySelector('.mergulho');
  const canvas = sec?.querySelector('.mg-fx');
  const ctx = canvas?.getContext('2d');
  if (!ctx || !motionOk) return;

  let w = 0;
  let h = 0;
  let dpr = 1;
  let running = false;
  let frame = 0;
  let depthNow = 0;
  const motes = [];
  let bubbles = [];
  let swarm = [];
  let swarmStart = 0;

  function size() {
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    w = sec.clientWidth;
    h = sec.clientHeight;
    canvas.width = Math.round(w * dpr);
    canvas.height = Math.round(h * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }

  function seed() {
    motes.length = 0;
    const n = Math.round(Math.min(70, (w * h) / 22000));
    for (let i = 0; i < n; i += 1) {
      motes.push({ x: Math.random() * w, y: Math.random() * h, r: 0.6 + Math.random() * 1.8, vy: -(0.08 + Math.random() * 0.25), ph: Math.random() * 6.28 });
    }
  }

  // Ao mergulhar: uma rajada de bolhas sobe passando pela tela.
  function dive(next) {
    depthNow = next;
    if (!next) return;
    for (let i = 0; i < 90; i += 1) {
      bubbles.push({ x: Math.random() * w, y: h + Math.random() * h * 0.6, r: 1.5 + Math.random() * 7, vy: -(7 + Math.random() * 12), ph: Math.random() * 6.28, life: 1 });
    }
  }

  // No fundo: a luz se junta e desenha a palavra antes de ela acender.
  function reveal(word) {
    if (!word) return;
    // Posição pelo layout (offset), não pelo retângulo: a palavra ainda está animando a entrada.
    let left = 0;
    let top = 0;
    for (let el = word; el && el !== sec; el = el.offsetParent) {
      left += el.offsetLeft;
      top += el.offsetTop;
    }
    const style = getComputedStyle(word);
    const off = document.createElement('canvas');
    const ow = Math.ceil(word.offsetWidth);
    const oh = Math.ceil(word.offsetHeight);
    off.width = ow;
    off.height = oh;
    const o = off.getContext('2d');
    o.fillStyle = '#fff';
    o.textBaseline = 'middle';
    o.textAlign = 'center';
    o.font = `${style.fontWeight} ${style.fontSize} ${style.fontFamily}`;
    o.fillText(word.textContent, ow / 2, oh / 2);
    const data = o.getImageData(0, 0, ow, oh).data;
    const step = Math.max(3, Math.round(ow / 120));
    swarm = [];
    for (let y = 0; y < oh; y += step) {
      for (let x = 0; x < ow; x += step) {
        if (data[(y * ow + x) * 4 + 3] > 140) {
          const a = Math.random() * 6.28;
          const d = Math.max(w, h) * (0.4 + Math.random() * 0.5);
          swarm.push({
            tx: left + x, ty: top + y,
            sx: w / 2 + Math.cos(a) * d, sy: h * 0.55 + Math.sin(a) * d,
            delay: Math.random() * 0.5, r: 0.8 + Math.random() * 1.4,
          });
        }
      }
    }
    swarmStart = performance.now();
  }

  function reset() {
    swarm = [];
    bubbles = [];
  }

  function draw(now) {
    ctx.clearRect(0, 0, w, h);
    const deep = depthNow / 3;
    // Partículas ambientes: frias perto da superfície, lilases no fundo.
    for (const m of motes) {
      m.y += m.vy;
      m.x += Math.sin(now * 0.0005 + m.ph) * 0.15;
      if (m.y < -10) { m.y = h + 10; m.x = Math.random() * w; }
      const tw = 0.4 + 0.6 * Math.abs(Math.sin(now * 0.001 + m.ph));
      ctx.globalAlpha = tw * (0.35 + deep * 0.5);
      ctx.fillStyle = deep > 0.6 ? '#f2b8ff' : deep > 0.3 ? '#ffd2c0' : '#cdeaff';
      ctx.beginPath();
      ctx.arc(m.x, m.y, m.r, 0, 6.283);
      ctx.fill();
    }

    if (bubbles.length) {
      ctx.lineWidth = 1;
      bubbles = bubbles.filter((b) => b.y > -40);
      for (const b of bubbles) {
        b.y += b.vy;
        b.vy *= 0.985;
        b.x += Math.sin(now * 0.006 + b.ph) * 1.2;
        ctx.globalAlpha = 0.55;
        ctx.strokeStyle = 'rgba(210, 238, 255, 0.9)';
        ctx.beginPath();
        ctx.arc(b.x, b.y, b.r, 0, 6.283);
        ctx.stroke();
        ctx.globalAlpha = 0.35;
        ctx.fillStyle = '#ffffff';
        ctx.beginPath();
        ctx.arc(b.x - b.r * 0.35, b.y - b.r * 0.35, b.r * 0.25, 0, 6.283);
        ctx.fill();
      }
    }

    if (swarm.length) {
      const t = (now - swarmStart) / 1000;
      const fade = t > 2.6 ? Math.max(0, 1 - (t - 2.6) / 0.9) : 1;
      if (fade <= 0) swarm = [];
      for (const p of swarm) {
        const k = Math.min(1, Math.max(0, (t - p.delay) / 1.7));
        const e = 1 - (1 - k) ** 3;
        const x = p.sx + (p.tx - p.sx) * e + Math.sin(t * 3 + p.delay * 9) * (1 - e) * 20;
        const y = p.sy + (p.ty - p.sy) * e;
        ctx.globalAlpha = (0.25 + e * 0.75) * fade;
        ctx.fillStyle = e > 0.95 ? '#fff4ff' : '#f48cff';
        ctx.beginPath();
        ctx.arc(x, y, p.r * (1.4 - e * 0.5), 0, 6.283);
        ctx.fill();
      }
    }
    ctx.globalAlpha = 1;
  }

  function loop(now) {
    draw(now);
    frame = requestAnimationFrame(loop);
  }

  new IntersectionObserver((entries) => {
    const on = entries.some((e) => e.isIntersecting);
    if (on && !running) { running = true; size(); if (!motes.length) seed(); frame = requestAnimationFrame(loop); }
    if (!on && running) { running = false; cancelAnimationFrame(frame); }
  }, { rootMargin: '100px' }).observe(sec);
  window.addEventListener('resize', () => { if (running) { size(); seed(); } });

  window.stwayFx = { dive, reveal, reset };
})();

/* ─── Páginas: números que contam quando aparecem (ex.: 10% do dízimo) ─ */

(function counters() {
  const nodes = document.querySelectorAll('[data-count]');
  if (!nodes.length) return;
  const run = (el) => {
    const to = Number(el.dataset.count);
    if (!motionOk) { el.textContent = String(to); el.closest('.mf-ring')?.classList.add('is-on'); return; }
    el.closest('.mf-ring')?.classList.add('is-on');
    const start = performance.now();
    const tick = (now) => {
      const t = Math.min(1, (now - start) / 1600);
      el.textContent = String(Math.round(to * (1 - (1 - t) ** 3)));
      if (t < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  };
  const io = new IntersectionObserver((entries) => {
    entries.forEach((e) => { if (e.isIntersecting) { run(e.target); io.unobserve(e.target); } });
  }, { threshold: 0.6 });
  nodes.forEach((n) => io.observe(n));
})();

/* ─── Manifesto: cada frase acende palavra por palavra quando entra ─ */

(function beliefs() {
  const items = document.querySelectorAll('.mf-belief');
  if (!items.length) return;
  if (!motionOk || !('IntersectionObserver' in window)) { items.forEach((i) => i.classList.add('in')); return; }
  const io = new IntersectionObserver((entries) => {
    entries.forEach((e) => e.target.classList.toggle('in', e.isIntersecting));
  }, { rootMargin: '-30% 0px -30% 0px' });
  items.forEach((i) => io.observe(i));
})();
