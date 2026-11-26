/**
 * Funil e retenção a partir do doc público `users/{uid}` (sem Analytics).
 *
 * Datas do app são o dia local do aparelho (YYYY-MM-DD):
 *  - `firstOpenDate`   1º acesso com conta
 *  - `firstLessonDate` 1ª cena terminada (`firstLessonTrailSlug` = trilha)
 *  - `playDates`       dias com cena (o app guarda só os últimos 120)
 *  - `plusActive` / `plusInTrial` / `plusProductId` vêm do webhook RevenueCat
 *
 * Retenção conta a partir da 1ª cena. Cada janela só entra na conta para
 * quem já tem idade para ela (quem começou ontem não pesa no D7).
 */

export const WINDOWS = [
  { key: 'd1', label: 'D1', hint: 'voltou no dia seguinte', from: 1, to: 1 },
  { key: 'w2', label: 'D7', hint: 'fez cena entre o 7º e o 13º dia', from: 7, to: 13 },
  { key: 'd30', label: 'D30', hint: 'fez cena entre o 28º e o 34º dia', from: 28, to: 34 },
];

// Vitalício de lançamento e o anual antigo dos testadores (mesmos ids do
// webhook, functions/revenuecat.js).
const PIONEER_PRODUCTS = ['plus_pioneer_lifetime', 'plus_founder_annual'];

export function dayKey(raw) {
  if (raw == null || raw === '') return '';
  if (typeof raw?.toDate === 'function') return localKey(raw.toDate());
  const s = String(raw);
  if (/^\d{4}-\d{2}-\d{2}/.test(s)) return s.slice(0, 10);
  const d = new Date(s);
  return Number.isNaN(d.getTime()) ? '' : localKey(d);
}

export function localKey(d) {
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`;
}

function toUtc(key) {
  const [y, m, d] = key.split('-').map(Number);
  return Date.UTC(y, m - 1, d);
}

export function daysBetween(a, b) {
  return Math.round((toUtc(b) - toUtc(a)) / 86400000);
}

export function addDays(key, n) {
  const d = new Date(toUtc(key) + n * 86400000);
  return d.toISOString().slice(0, 10);
}

/** Segunda-feira da semana do dia (chave da coorte semanal). */
export function weekOf(key) {
  const dow = new Date(toUtc(key)).getUTCDay(); // 0 = domingo
  return addDays(key, -((dow + 6) % 7));
}

/** Normaliza um doc de usuário no que o funil usa. */
export function summarize(u) {
  const plays = [...new Set((Array.isArray(u.playDates) ? u.playDates : []).map(dayKey).filter(Boolean))].sort();
  const firstLesson = dayKey(u.firstLessonDate) || plays[0] || '';
  const firstOpen = dayKey(u.firstOpenDate) || firstLesson;
  const scenes = Array.isArray(u.completedMissions) ? u.completedMissions.length : 0;
  const product = String(u.plusProductId || '');
  const plus = u.plusActive === true;
  return {
    id: u.id,
    firstOpen,
    firstLesson,
    plays,
    scenes,
    entryTrail: String(u.firstLessonTrailSlug || '') || '(sem registro)',
    tester: u.desbravador === true,
    trial: plus && u.plusInTrial === true,
    paid: plus && u.plusInTrial !== true && u.plusSource === 'revenuecat',
    pioneer: plus && PIONEER_PRODUCTS.includes(product.split(':')[0]),
  };
}

function playedBetween(s, from, to) {
  return s.plays.some((d) => {
    const n = daysBetween(s.firstLesson, d);
    return n >= from && n <= to;
  });
}

/** { eligible, kept } de uma janela para um grupo de pessoas. */
export function retention(list, win, today) {
  let eligible = 0;
  let kept = 0;
  for (const s of list) {
    if (!s.firstLesson || daysBetween(s.firstLesson, today) < win.to) continue;
    eligible += 1;
    if (playedBetween(s, win.from, win.to)) kept += 1;
  }
  return { eligible, kept };
}

function activeWithin(list, today, days) {
  return list.filter((s) => s.plays.some((d) => {
    const n = daysBetween(d, today);
    return n >= 0 && n < days;
  })).length;
}

/**
 * @param users docs de `users` (com `id`)
 * @param opts.today YYYY-MM-DD
 * @param opts.includeTesters inclui desbravadores (testers de antes do lançamento)
 * @param opts.since só contas com 1º acesso a partir deste dia ('' = todas)
 */
export function computeFunnel(users, { today, includeTesters = false, since = '' } = {}) {
  const all = users.map(summarize).filter((s) => s.firstOpen);
  const people = all.filter((s) => (includeTesters || !s.tester) && (!since || s.firstOpen >= since));
  const started = people.filter((s) => s.firstLesson);
  const committed = started.filter((s) => s.scenes >= 7);

  const steps = [
    { label: 'Contas', n: people.length, hint: 'abriram o app com login' },
    { label: 'Fizeram a 1ª cena', n: started.length },
    { label: 'Voltaram em outro dia', n: started.filter((s) => s.plays.length >= 2).length },
    { label: '7+ cenas', n: committed.length },
    { label: 'Teste grátis agora', n: people.filter((s) => s.trial).length },
    { label: 'Pagando agora', n: people.filter((s) => s.paid).length, hint: 'Plus ativo fora do teste' },
  ];

  const ret = Object.fromEntries(WINDOWS.map((w) => [w.key, retention(started, w, today)]));
  // Métrica-norte: quem chegou a 7 cenas ainda caminha um mês depois?
  const north = retention(committed, WINDOWS[2], today);

  const cohortMap = new Map();
  for (const s of started) {
    const k = weekOf(s.firstLesson);
    if (!cohortMap.has(k)) cohortMap.set(k, []);
    cohortMap.get(k).push(s);
  }
  const cohorts = [...cohortMap.entries()]
    .sort((a, b) => b[0].localeCompare(a[0]))
    .map(([week, list]) => ({
      week,
      n: list.length,
      committed: list.filter((s) => s.scenes >= 7).length,
      plus: list.filter((s) => s.trial || s.paid).length,
      ...Object.fromEntries(WINDOWS.map((w) => [w.key, retention(list, w, today)])),
    }));

  const trailMap = new Map();
  for (const s of started) {
    if (!trailMap.has(s.entryTrail)) trailMap.set(s.entryTrail, []);
    trailMap.get(s.entryTrail).push(s);
  }
  const entryTrails = [...trailMap.entries()]
    .map(([trail, list]) => ({
      trail,
      n: list.length,
      returned: list.filter((s) => s.plays.length >= 2).length,
      w2: retention(list, WINDOWS[1], today),
    }))
    .sort((a, b) => b.n - a.n);

  // Novas contas e 1ªs cenas por dia, últimos 30 dias.
  const daily = [];
  for (let i = 29; i >= 0; i -= 1) {
    const d = addDays(today, -i);
    daily.push({
      day: d,
      signups: people.filter((s) => s.firstOpen === d).length,
      firsts: started.filter((s) => s.firstLesson === d).length,
      active: people.filter((s) => s.plays.includes(d)).length,
    });
  }

  return {
    total: all.length,
    testersHidden: includeTesters ? 0 : all.filter((s) => s.tester).length,
    steps,
    active: {
      dau: activeWithin(people, today, 1),
      wau: activeWithin(people, today, 7),
      mau: activeWithin(people, today, 30),
    },
    retention: ret,
    north,
    plus: {
      trial: people.filter((s) => s.trial).length,
      paid: people.filter((s) => s.paid).length,
      pioneer: people.filter((s) => s.pioneer && !s.trial).length,
    },
    cohorts,
    entryTrails,
    daily,
  };
}
