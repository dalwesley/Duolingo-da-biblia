'use strict';

/**
 * Prêmio do Advento: quem conclui as cenas da campanha até o prazo ganha
 * meses de Peregrino+. O nível vale pelo mais alto, nunca soma:
 *
 *   sozinho                                   → 1 mês
 *   dupla da Companhia, os dois concluíram    → 2 meses
 *   grupo com 3+ pessoas que concluíram       → 3 meses
 *
 * Só quem conclui ganha. Dupla e grupo contam pela foto tirada no fim do
 * 1º dia (`rosterAtMs`): quem entra depois conclui como "sozinho".
 *
 * Prova (o app não grava nada que o servidor confie):
 *   O app cria `seasonWalks/{c}/scenes/{uid}_{dia}` ao abrir a cena
 *   (state "start") e marca "done" ao terminar. O servidor usa os horários
 *   do próprio Firestore (createTime/updateTime, que o cliente não forja):
 *   - a cena só abre quando o dia chegou (com folga para fusos à frente);
 *   - termina pelo menos `minSceneSeconds` depois de abrir;
 *   - duas cenas provadas ficam a pelo menos `minSceneSeconds` uma da outra;
 *   - termina antes do prazo.
 *   Prova recusada: o doc é apagado e a pessoa pode refazer a cena.
 *   Aceita: entra em `seasonWalks/{c}/proof/{uid}` (só o servidor grava).
 *
 * Entrega: os meses entram no mesmo saldo do convite que vira assinatura
 * (`referralRewards/{uid}.banked`, ver referral.js) e saem um por vez pelo
 * `releaseBanked`: na hora para quem está sem Plus, guardados para quem
 * assina. Não contam no teto anual da indicação.
 */

const { FieldValue } = require('firebase-admin/firestore');

const DAY_MS = 24 * 3600 * 1000;
const HOUR_MS = 3600 * 1000;

/** Mínimo de pessoas para um grupo existir de verdade (vale para tudo). */
const GROUP_MIN_MEMBERS = 3;

/**
 * Padrões da campanha. `campaigns/{id}` no Firestore sobrescreve qualquer
 * campo (prazo, meses...) sem novo deploy.
 */
const DEFAULTS = {
  'advento-2026': {
    // 29/11/2026 — 1º domingo do Advento.
    startYmd: '2026-11-29',
    days: 26,
    // 24/12/2026 23:59:59 de Brasília (UTC-3).
    deadlineMs: Date.UTC(2026, 11, 25, 2, 59, 59),
    // Fim do 1º dia (29/11 23:59:59 de Brasília): foto das duplas e grupos.
    rosterAtMs: Date.UTC(2026, 10, 30, 2, 59, 59),
    months: { solo: 1, pair: 2, group: 3 },
    groupMin: GROUP_MIN_MEMBERS,
    minSceneSeconds: 60,
    // Dias atrasados se recuperam, mas no máximo tantas provas por dia
    // (de Brasília): fechar o Advento exige ao menos ~4 dias de caminhada.
    maxPerDay: 7,
    tzOffsetHours: -3,
    // Fuso mais adiantado do mundo (UTC+14): o dia abre lá primeiro.
    earlyHours: 14,
  },
};

const TIER_ORDER = ['none', 'solo', 'pair', 'group'];

const sceneRef = (db, c, uid, day) => db.doc(`seasonWalks/${c}/scenes/${uid}_${day}`);
const proofRef = (db, c, uid) => db.doc(`seasonWalks/${c}/proof/${uid}`);
const rewardRef = (db, c, uid) => db.doc(`seasonWalks/${c}/rewards/${uid}`);
const rosterRef = (db, c, uid) => db.doc(`seasonWalks/${c}/roster/${uid}`);
const groupRef = (db, c, code) => db.doc(`seasonWalks/${c}/groups/${code}`);
const metaRef = (db, c) => db.doc(`seasonWalks/${c}/server/roster`);
const summaryRef = (db, uid) => db.doc(`referralRewards/${uid}`);

// ---- Configuração ---------------------------------------------------------

/** Junta o padrão do código com o doc `campaigns/{id}` (se houver). */
function mergeConfig(id, override) {
  const base = DEFAULTS[id];
  if (!base) return null;
  const o = override && typeof override === 'object' ? override : {};
  const num = (v, d) => (typeof v === 'number' && Number.isFinite(v) ? v : d);
  const months = { ...base.months, ...(o.months && typeof o.months === 'object' ? o.months : {}) };
  return {
    id,
    startYmd: typeof o.startYmd === 'string' ? o.startYmd : base.startYmd,
    days: num(o.days, base.days),
    deadlineMs: num(o.deadlineMs, base.deadlineMs),
    rosterAtMs: num(o.rosterAtMs, base.rosterAtMs),
    months: {
      solo: num(months.solo, base.months.solo),
      pair: num(months.pair, base.months.pair),
      group: num(months.group, base.months.group),
    },
    groupMin: Math.max(GROUP_MIN_MEMBERS, num(o.groupMin, base.groupMin)),
    minSceneSeconds: num(o.minSceneSeconds, base.minSceneSeconds),
    maxPerDay: num(o.maxPerDay, base.maxPerDay),
    tzOffsetHours: num(o.tzOffsetHours, base.tzOffsetHours),
    earlyHours: num(o.earlyHours, base.earlyHours),
  };
}

async function loadConfig(db, id) {
  if (!DEFAULTS[id]) return null;
  let override = null;
  try {
    const snap = await db.doc(`campaigns/${id}`).get();
    if (snap.exists) override = snap.data();
  } catch (_) {
    // Sem o doc (ou sem leitura): vale o padrão.
  }
  return mergeConfig(id, override);
}

// ---- Decisões puras -------------------------------------------------------

/** Instante em que o dia `day` (1..N) abre no fuso mais adiantado. */
function dayUnlockMs(cfg, day) {
  const [y, m, d] = cfg.startYmd.split('-').map(Number);
  return Date.UTC(y, m - 1, d + day - 1) - cfg.earlyHours * HOUR_MS;
}

/** Dia civil (no fuso da campanha) de um instante. */
function localDay(cfg, ms) {
  return Math.floor((ms + (cfg.tzOffsetHours || 0) * HOUR_MS) / DAY_MS);
}

/**
 * A cena terminada vale como prova? Devolve null (vale) ou o motivo.
 * `startMs`/`doneMs`: createTime/updateTime do doc. `lastDoneMs`: última
 * prova aceita; `provenTimes`: horários de todas as provas aceitas (o
 * trigger pode chegar fora de ordem, então a distância vale para qualquer
 * uma, antes ou depois).
 */
function proofDecision(cfg, { day, startMs, doneMs, lastDoneMs, provenDays, provenTimes }) {
  if (!Number.isInteger(day) || day < 1 || day > cfg.days) return 'day';
  if (provenDays && provenDays.includes(day)) return 'dup';
  if (!(startMs >= dayUnlockMs(cfg, day))) return 'early';
  if (!(doneMs <= cfg.deadlineMs)) return 'late';
  const min = cfg.minSceneSeconds * 1000;
  if (!(doneMs - startMs >= min)) return 'fast';
  const times = [...(provenTimes || []), ...(typeof lastDoneMs === 'number' ? [lastDoneMs] : [])];
  if (times.some((t) => typeof t === 'number' && Math.abs(doneMs - t) < min)) return 'burst';
  if (cfg.maxPerDay > 0) {
    const today = localDay(cfg, doneMs);
    const same = (provenTimes || []).filter((t) => typeof t === 'number' && localDay(cfg, t) === today);
    if (same.length >= cfg.maxPerDay) return 'cap';
  }
  return null;
}

/**
 * Nível de quem concluiu. `completed(uid)` diz se a pessoa concluiu.
 * `groups`: listas de membros (da foto) dos grupos dela.
 */
function tierFor(cfg, { uid, pairs, groups, completed }) {
  if (!completed(uid)) return 'none';
  for (const members of groups || []) {
    if (!Array.isArray(members) || !members.includes(uid)) continue;
    const done = members.filter((m) => completed(m)).length;
    if (members.length >= cfg.groupMin && done >= cfg.groupMin) return 'group';
  }
  for (const other of pairs || []) {
    if (other && other !== uid && completed(other)) return 'pair';
  }
  return 'solo';
}

function monthsFor(cfg, tier) {
  if (tier === 'group') return cfg.months.group;
  if (tier === 'pair') return cfg.months.pair;
  if (tier === 'solo') return cfg.months.solo;
  return 0;
}

/** Nunca desce: o nível já dado fica. */
function higherTier(a, b) {
  return TIER_ORDER.indexOf(a) >= TIER_ORDER.indexOf(b) ? a : b;
}

/**
 * Foto do dia 1: duplas ativas e grupos de verdade (3+ membros que já
 * estavam lá até `rosterAtMs`). Pura: recebe os dados lidos.
 *   companies: [{ hostId, guestId, endedAt, createdMs, guestJoinedMs }]
 *   rooms: [{ code, members: [{ uid, joinedMs }] }]
 * Devolve { users: { uid: { pairs: [], groups: [] } }, groups: { code: [uids] } }.
 */
function buildRoster(cfg, { companies, rooms }) {
  const users = {};
  const user = (uid) => (users[uid] ||= { pairs: [], groups: [] });
  for (const c of companies || []) {
    const a = String(c.hostId || '');
    const b = String(c.guestId || '');
    if (!a || !b || a === b || c.endedAt) continue;
    // Dupla criada depois do fim do 1º dia não entra (a foto pode sair
    // até 30 min depois).
    if (c.createdMs > cfg.rosterAtMs || c.guestJoinedMs > cfg.rosterAtMs) continue;
    if (!user(a).pairs.includes(b)) user(a).pairs.push(b);
    if (!user(b).pairs.includes(a)) user(b).pairs.push(a);
  }
  const groups = {};
  for (const r of rooms || []) {
    const uids = [
      ...new Set(
        (r.members || [])
          .filter((m) => m && m.uid && !(m.joinedMs > cfg.rosterAtMs))
          .map((m) => String(m.uid)),
      ),
    ];
    if (uids.length < cfg.groupMin) continue;
    groups[r.code] = uids;
    for (const uid of uids) user(uid).groups.push(r.code);
  }
  return { users, groups };
}

// ---- Firestore ------------------------------------------------------------

const msOf = (t) =>
  t == null ? NaN : typeof t === 'number' ? t : typeof t.toMillis === 'function' ? t.toMillis() : NaN;

/**
 * Trigger da cena: "start" virou "done". Confere e grava a prova.
 * Devolve { accepted, reason, completed }.
 */
async function onSceneDone(db, cfg, { uid, day, startMs, doneMs, ref }, logger) {
  const pRef = proofRef(db, cfg.id, uid);
  const result = await db.runTransaction(async (tx) => {
    const proof = await tx.get(pRef);
    const data = proof.exists ? proof.data() : {};
    const days = data.days && typeof data.days === 'object' ? data.days : {};
    const provenDays = Object.keys(days).map(Number);
    const reason = proofDecision(cfg, {
      day,
      startMs,
      doneMs,
      lastDoneMs: typeof data.lastDoneMs === 'number' ? data.lastDoneMs : undefined,
      provenDays,
      provenTimes: Object.values(days),
    });
    if (reason) {
      if (reason !== 'dup') {
        tx.set(pRef, { rejects: FieldValue.increment(1), lastReject: reason }, { merge: true });
      }
      return { accepted: false, reason, completed: false };
    }
    const count = provenDays.length + 1;
    const completed = count >= cfg.days;
    tx.set(
      pRef,
      {
        uid,
        days: { ...days, [String(day)]: doneMs },
        count,
        lastDoneMs: Math.max(doneMs, typeof data.lastDoneMs === 'number' ? data.lastDoneMs : 0),
        ...(completed && !data.completedAtMs ? { completedAtMs: doneMs } : {}),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return { accepted: true, reason: null, completed: completed && !data.completedAtMs };
  });
  // Recusada (menos repetida): apaga a cena para a pessoa poder refazer.
  if (!result.accepted && result.reason !== 'dup' && ref) {
    try {
      await ref.delete();
    } catch (e) {
      logger?.warn?.('advento: não apaguei a cena recusada', { uid, day, error: e.message });
    }
  }
  return result;
}

async function isCompleted(db, cfg, uid, cache) {
  if (cache.has(uid)) return cache.get(uid);
  const snap = await proofRef(db, cfg.id, uid).get();
  const v = Boolean(snap.exists && snap.get('completedAtMs'));
  cache.set(uid, v);
  return v;
}

/**
 * Recalcula o nível de `uid` e entrega a diferença de meses. Idempotente:
 * `rewards/{uid}.grantedMonths` guarda o que já entrou.
 */
async function evaluate(db, cfg, uid, { rc, release, logger, cache = new Map() } = {}) {
  if (!(await isCompleted(db, cfg, uid, cache))) return null;
  const roster = await rosterRef(db, cfg.id, uid).get();
  const pairs = roster.exists ? roster.get('pairs') || [] : [];
  const groupCodes = roster.exists ? roster.get('groups') || [] : [];
  const groups = [];
  for (const code of groupCodes) {
    const g = await groupRef(db, cfg.id, code).get();
    if (g.exists) groups.push(g.get('members') || []);
  }
  const done = new Set();
  for (const m of [...pairs, ...groups.flat()]) {
    if (await isCompleted(db, cfg, m, cache)) done.add(m);
  }
  done.add(uid);
  const tier = tierFor(cfg, { uid, pairs, groups, completed: (m) => done.has(m) });

  const rRef = rewardRef(db, cfg.id, uid);
  const sRef = summaryRef(db, uid);
  const delta = await db.runTransaction(async (tx) => {
    const [cur, tomb] = await Promise.all([
      tx.get(rRef),
      tx.get(db.doc(`deletedAccounts/${uid}`)),
    ]);
    if (tomb.exists) return 0;
    const prevTier = cur.exists ? cur.get('tier') || 'none' : 'none';
    const granted = cur.exists ? cur.get('grantedMonths') || 0 : 0;
    const best = higherTier(tier, prevTier);
    const want = monthsFor(cfg, best);
    const add = Math.max(0, want - granted);
    if (add === 0 && best === prevTier) return 0;
    tx.set(
      rRef,
      {
        uid,
        tier: best,
        grantedMonths: granted + add,
        months: want,
        ...(cur.exists && cur.get('firstAtMs') ? {} : { firstAtMs: Date.now() }),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    if (add > 0) {
      tx.set(
        sRef,
        {
          banked: FieldValue.increment(add),
          adventMonths: FieldValue.increment(add),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }
    return add;
  });
  if (delta > 0) {
    logger?.info?.('advento: meses contados', { uid, tier, delta });
    if (rc && release) {
      try {
        await release(db, rc, uid, logger);
      } catch (e) {
        logger?.error?.('advento: falha ao soltar o mês', { uid, error: e.message });
      }
    }
  }
  return { tier, delta };
}

/** Quem concluiu agora puxa junto a dupla e o grupo (podem subir de nível). */
async function evaluateAround(db, cfg, uid, opts = {}) {
  const cache = opts.cache || new Map();
  const out = [await evaluate(db, cfg, uid, { ...opts, cache })];
  const roster = await rosterRef(db, cfg.id, uid).get();
  if (!roster.exists) return out;
  const others = new Set(roster.get('pairs') || []);
  for (const code of roster.get('groups') || []) {
    const g = await groupRef(db, cfg.id, code).get();
    for (const m of (g.exists && g.get('members')) || []) others.add(m);
  }
  others.delete(uid);
  for (const o of others) out.push(await evaluate(db, cfg, o, { ...opts, cache }));
  return out;
}

/**
 * Tira a foto do dia 1 uma vez (depois de `rosterAtMs`). Devolve true
 * quando tirou agora.
 */
async function takeRosterIfDue(db, cfg, now, logger) {
  if (now < cfg.rosterAtMs) return false;
  const meta = await metaRef(db, cfg.id).get();
  if (meta.exists && meta.get('takenAtMs')) return false;

  const companies = (await db.collection('companies').get()).docs.map((d) => {
    const x = d.data() || {};
    return {
      hostId: x.hostId,
      guestId: x.guestId,
      endedAt: x.endedAt || null,
      createdMs: msOf(d.createTime),
      guestJoinedMs: msOf(x.guestJoinedAt),
    };
  });
  const rooms = [];
  for (const r of (await db.collection('rooms').get()).docs) {
    const members = (await db.collection(`rooms/${r.id}/members`).get()).docs.map((m) => ({
      uid: m.id,
      joinedMs: msOf(m.createTime),
    }));
    rooms.push({ code: r.id, members });
  }
  const roster = buildRoster(cfg, { companies, rooms });

  let batch = db.batch();
  let n = 0;
  const flush = async () => {
    if (n) await batch.commit();
    batch = db.batch();
    n = 0;
  };
  for (const [code, members] of Object.entries(roster.groups)) {
    batch.set(groupRef(db, cfg.id, code), { members, size: members.length });
    if (++n >= 400) await flush();
  }
  for (const [uid, r] of Object.entries(roster.users)) {
    batch.set(rosterRef(db, cfg.id, uid), { pairs: r.pairs, groups: r.groups });
    if (++n >= 400) await flush();
  }
  batch.set(metaRef(db, cfg.id), {
    takenAtMs: now,
    users: Object.keys(roster.users).length,
    groups: Object.keys(roster.groups).length,
  });
  n++;
  await flush();
  logger?.info?.('advento: foto do dia 1', {
    users: Object.keys(roster.users).length,
    groups: Object.keys(roster.groups).length,
  });
  return true;
}

/** Varredura: todo mundo que concluiu é recalculado (cobre corridas). */
async function sweep(db, cfg, opts = {}) {
  const snap = await db.collection(`seasonWalks/${cfg.id}/proof`).get();
  const cache = new Map();
  let delta = 0;
  for (const d of snap.docs) {
    if (!d.get('completedAtMs')) continue;
    const r = await evaluate(db, cfg, d.id, { ...opts, cache });
    delta += (r && r.delta) || 0;
  }
  return delta;
}

module.exports = {
  DEFAULTS,
  GROUP_MIN_MEMBERS,
  DAY_MS,
  mergeConfig,
  loadConfig,
  dayUnlockMs,
  proofDecision,
  tierFor,
  monthsFor,
  higherTier,
  buildRoster,
  msOf,
  onSceneDone,
  evaluate,
  evaluateAround,
  takeRosterIfDue,
  sweep,
  sceneRef,
};
