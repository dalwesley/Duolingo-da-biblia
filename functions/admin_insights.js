'use strict';

/**
 * Leituras do painel que o cliente não pode fazer sozinho (regras fecham
 * prova do Advento, convites, companhias e a marca do webhook). Entram pelo
 * callable `moderateUser`, que já confere se quem chama é admin.
 *
 *   ops       saúde do webhook RevenueCat (`ops/revenuecat`)
 *   advent    quem caminha o Advento: provas, dupla/grupo, nível e meses
 *   timeline  o que aconteceu com uma conta, em ordem
 *
 * Só leitura. O webhook grava a marca em `recordWebhook`.
 */

const { FieldValue } = require('firebase-admin/firestore');
const advent = require('./advent');

const OPS_REF = 'ops/revenuecat';

const msOf = (t) => {
  if (t == null) return null;
  if (typeof t === 'number') return Number.isFinite(t) ? t : null;
  if (typeof t.toMillis === 'function') return t.toMillis();
  if (typeof t === 'string') {
    const ms = Date.parse(t.length === 10 ? `${t}T12:00:00Z` : t);
    return Number.isNaN(ms) ? null : ms;
  }
  return null;
};

// ---- Webhook --------------------------------------------------------------

/**
 * Carimbo de cada entrega do webhook. Nunca derruba a entrega.
 * `outcome`: 'ok' | 'ignored' | 'unauthorized' | 'error'.
 */
async function recordWebhook(db, { outcome, event, error } = {}) {
  const now = FieldValue.serverTimestamp();
  const patch = { received: FieldValue.increment(1), lastAt: now, lastOutcome: outcome };
  if (outcome === 'ok' || outcome === 'ignored') {
    patch.lastOkAt = now;
    patch.lastType = String(event?.type || '');
    patch.lastEnv = String(event?.environment || '');
    patch.lastStore = String(event?.store || '');
    if (outcome === 'ok' && event?.environment === 'PRODUCTION') patch.lastProductionAt = now;
  } else if (outcome === 'unauthorized') {
    patch.lastUnauthorizedAt = now;
  } else if (outcome === 'error') {
    patch.lastErrorAt = now;
    patch.lastError = String(error || '').slice(0, 300);
  }
  await db.doc(OPS_REF).set(patch, { merge: true });
}

async function opsStatus(db) {
  const [snap, plus] = await Promise.all([
    db.doc(OPS_REF).get(),
    db.collection('users').where('plusActive', '==', true).get(),
  ]);
  const d = snap.exists ? snap.data() : {};
  const iso = (k) => (msOf(d[k]) ? new Date(msOf(d[k])).toISOString() : null);
  let viaWebhook = 0;
  let manual = 0;
  let trial = 0;
  for (const u of plus.docs) {
    if (u.get('plusSource') === 'revenuecat') viaWebhook += 1;
    else manual += 1;
    if (u.get('plusInTrial') === true) trial += 1;
  }
  return {
    webhook: {
      received: d.received || 0,
      lastAt: iso('lastAt'),
      lastOkAt: iso('lastOkAt'),
      lastProductionAt: iso('lastProductionAt'),
      lastOutcome: d.lastOutcome || null,
      lastType: d.lastType || null,
      lastEnv: d.lastEnv || null,
      lastStore: d.lastStore || null,
      lastUnauthorizedAt: iso('lastUnauthorizedAt'),
      lastErrorAt: iso('lastErrorAt'),
      lastError: d.lastError || null,
    },
    plus: { total: plus.size, viaWebhook, manual, trial },
  };
}

// ---- Advento --------------------------------------------------------------

/** Roster vivo (antes da foto): mesma regra da foto, com os dados de agora. */
async function liveRoster(db, cfg) {
  const companies = (await db.collection('companies').get()).docs.map((d) => {
    const x = d.data() || {};
    return {
      hostId: x.hostId,
      guestId: x.guestId,
      endedAt: x.endedAt || null,
      createdMs: advent.msOf(d.createTime),
      guestJoinedMs: advent.msOf(x.guestJoinedAt),
    };
  });
  const rooms = [];
  for (const r of (await db.collection('rooms').get()).docs) {
    const members = (await db.collection(`rooms/${r.id}/members`).get()).docs.map((m) => ({
      uid: m.id,
      joinedMs: advent.msOf(m.createTime),
    }));
    rooms.push({ code: r.id, name: r.get('name') || '', members });
  }
  const roster = advent.buildRoster(cfg, { companies, rooms });
  const names = Object.fromEntries(rooms.map((r) => [r.code, r.name]));
  return { ...roster, roomNames: names };
}

async function savedRoster(db, cfg) {
  const base = `seasonWalks/${cfg.id}`;
  const [users, groups] = await Promise.all([
    db.collection(`${base}/roster`).get(),
    db.collection(`${base}/groups`).get(),
  ]);
  const roster = { users: {}, groups: {}, roomNames: {} };
  for (const d of users.docs) roster.users[d.id] = { pairs: d.get('pairs') || [], groups: d.get('groups') || [] };
  for (const d of groups.docs) roster.groups[d.id] = d.get('members') || [];
  const codes = Object.keys(roster.groups);
  if (codes.length) {
    const rooms = await db.getAll(...codes.map((c) => db.doc(`rooms/${c}`)));
    for (const r of rooms) if (r.exists) roster.roomNames[r.id] = r.get('name') || '';
  }
  return roster;
}

async function adventStatus(db, campaignId = 'advento-2026') {
  const cfg = await advent.loadConfig(db, campaignId);
  if (!cfg) throw new Error(`Campanha desconhecida: ${campaignId}`);
  const base = `seasonWalks/${cfg.id}`;
  const [walkers, proofs, rewards, meta] = await Promise.all([
    db.collection(`${base}/walkers`).get(),
    db.collection(`${base}/proof`).get(),
    db.collection(`${base}/rewards`).get(),
    db.doc(`${base}/server/roster`).get(),
  ]);
  const rosterTaken = Boolean(meta.exists && meta.get('takenAtMs'));
  const roster = rosterTaken ? await savedRoster(db, cfg) : await liveRoster(db, cfg);

  const people = new Map();
  const person = (uid) => {
    if (!people.has(uid)) {
      people.set(uid, {
        uid,
        name: '',
        joined: false,
        walkerDays: 0,
        proven: 0,
        completedAtMs: null,
        lastDoneMs: null,
        rejects: 0,
        lastReject: null,
        tier: 'none',
        months: 0,
        grantedMonths: 0,
        pairs: [],
        groups: [],
      });
    }
    return people.get(uid);
  };
  for (const d of walkers.docs) {
    const p = person(d.id);
    p.joined = true;
    p.name = d.get('name') || p.name;
    p.walkerDays = d.get('days') || 0;
  }
  for (const d of proofs.docs) {
    const p = person(d.id);
    p.proven = d.get('count') || 0;
    p.completedAtMs = d.get('completedAtMs') || null;
    p.lastDoneMs = d.get('lastDoneMs') || null;
    p.rejects = d.get('rejects') || 0;
    p.lastReject = d.get('lastReject') || null;
  }
  for (const d of rewards.docs) {
    const p = person(d.id);
    p.tier = d.get('tier') || 'none';
    p.months = d.get('months') || 0;
    p.grantedMonths = d.get('grantedMonths') || 0;
  }
  // Dupla/grupo só importa para quem caminha.
  for (const [uid, r] of Object.entries(roster.users)) {
    if (!people.has(uid)) continue;
    const p = person(uid);
    p.pairs = r.pairs || [];
    p.groups = r.groups || [];
  }

  // Nomes que faltam (provas de quem não está em walkers, parceiros).
  const need = new Set();
  for (const p of people.values()) {
    if (!p.name) need.add(p.uid);
    for (const o of p.pairs) if (!people.get(o)?.name) need.add(o);
  }
  const names = {};
  const ids = [...need];
  for (let i = 0; i < ids.length; i += 100) {
    const snaps = await db.getAll(...ids.slice(i, i + 100).map((u) => db.doc(`users/${u}`)));
    for (const s of snaps) {
      if (s.exists) names[s.id] = s.get('userName') || s.get('name') || s.get('displayName') || '';
    }
  }
  for (const p of people.values()) if (!p.name) p.name = names[p.uid] || '';
  for (const uid of Object.keys(names)) if (!people.has(uid)) people.set(uid, null);

  const nameOf = (uid) => people.get(uid)?.name || names[uid] || '';
  const list = [...people.values()].filter(Boolean).map((p) => ({
    ...p,
    pairs: p.pairs.map((o) => ({ uid: o, name: nameOf(o), proven: people.get(o)?.proven || 0 })),
    groups: p.groups.map((code) => ({
      code,
      name: roster.roomNames[code] || '',
      size: (roster.groups[code] || []).length,
      proven: (roster.groups[code] || []).filter((m) => (people.get(m)?.proven || 0) > 0).length,
    })),
    // Melhor nível possível hoje, se todos concluírem.
    potential: p.groups.length ? 'group' : p.pairs.length ? 'pair' : 'solo',
  }));

  return {
    config: {
      id: cfg.id,
      startYmd: cfg.startYmd,
      days: cfg.days,
      deadline: new Date(cfg.deadlineMs).toISOString(),
      rosterAt: new Date(cfg.rosterAtMs).toISOString(),
      months: cfg.months,
      groupMin: cfg.groupMin,
    },
    rosterTaken,
    rosterTakenAt: rosterTaken ? new Date(meta.get('takenAtMs')).toISOString() : null,
    people: list,
  };
}

// ---- Linha do tempo -------------------------------------------------------

/**
 * Marcas de convite (`users/{x}/server/referral`) que apontam para `uid`.
 * Consulta de grupo precisa de índice que o projeto não declara: sem ele,
 * varre as contas (poucas centenas hoje; só o admin chama).
 */
async function invitedBy(db, uid) {
  try {
    const snap = await db.collectionGroup('server').where('inviterUid', '==', uid).get();
    return snap.docs;
  } catch (_) {
    const users = await db.collection('users').select().limit(5000).get();
    const refs = users.docs.map((d) => d.ref.collection('server').doc('referral'));
    const out = [];
    for (let i = 0; i < refs.length; i += 300) {
      const snaps = await db.getAll(...refs.slice(i, i + 300));
      for (const s of snaps) if (s.exists && s.get('inviterUid') === uid) out.push(s);
    }
    return out;
  }
}

async function timeline(db, auth, uid) {
  const events = [];
  const push = (ms, kind, text, extra = {}) => {
    if (ms == null) return;
    events.push({ at: new Date(ms).toISOString(), kind, text, ...extra });
  };
  const safe = (p) => p.catch(() => null);

  const [user, authUser, referral, rewardsSum, rcMark] = await Promise.all([
    db.doc(`users/${uid}`).get(),
    safe(auth.getUser(uid)),
    db.doc(`users/${uid}/server/referral`).get(),
    db.doc(`referralRewards/${uid}`).get(),
    db.doc(`users/${uid}/server/revenuecat`).get(),
  ]);
  const u = user.exists ? user.data() : {};

  if (authUser) {
    push(msOf(authUser.metadata?.creationTime), 'account', 'Criou a conta', {
      detail: (authUser.providerData || []).map((p) => p.providerId).join(', '),
    });
    push(msOf(authUser.metadata?.lastSignInTime), 'account', 'Último login');
  }
  push(msOf(u.firstOpenDate), 'app', 'Primeiro acesso ao app');
  push(msOf(u.firstLessonDate), 'scene', 'Primeira cena', { detail: u.firstLessonTrailSlug || '' });
  for (const [slug, at] of Object.entries(u.trailChosenAt || {})) push(msOf(at), 'trail', 'Escolheu a trilha', { detail: slug });
  for (const [slug, at] of Object.entries(u.trailsLeftAt || {})) push(msOf(at), 'trail', 'Deixou a trilha', { detail: slug });
  push(msOf(u.lastMissionCompletedDate), 'scene', 'Última cena concluída', { detail: u.lastMissionSlug || '' });
  push(msOf(u.lastBibleReadDate), 'bible', 'Última leitura na Bíblia');
  push(msOf(u.lastSeenDate), 'app', 'Visto por último', {
    detail: [u.platform, u.appVersion].filter(Boolean).join(' '),
  });

  if (referral.exists) {
    const inviter = referral.get('inviterUid');
    push(msOf(referral.get('createdAt')), 'invite', 'Entrou por convite', {
      detail: `via ${referral.get('via') || '?'}`,
      uid: inviter,
    });
    push(msOf(referral.get('rewardedAt')), 'invite', 'Pagou Plus: mês contado para quem convidou', { uid: inviter });
  }
  for (const d of await invitedBy(db, uid)) {
    const invitee = d.ref.parent.parent?.id;
    push(msOf(d.get('createdAt')), 'invite', 'Convidou alguém que entrou', { uid: invitee });
    push(msOf(d.get('rewardedAt')), 'invite', 'Ganhou mês: convidado pagou Plus', { uid: invitee });
  }

  if (rcMark.exists) {
    push(msOf(rcMark.get('lastEventAtMs')), 'plus', `RevenueCat: ${rcMark.get('lastEventType') || 'evento'}`);
  }
  if (u.plusActive) {
    const until = msOf(u.plusExpiresAt);
    push(msOf(u.plusUpdatedAt) || null, 'plus', u.plusInTrial ? 'Plus em teste grátis' : 'Plus ativo', {
      detail: until ? `até ${new Date(until).toISOString().slice(0, 10)}` : 'sem data (ligado à mão?)',
    });
  }
  if (rewardsSum.exists) {
    const r = rewardsSum.data();
    if (r.banked || r.adventMonths || r.earned) {
      push(msOf(r.updatedAt), 'plus', 'Saldo de meses grátis', {
        detail: `guardados ${r.banked || 0} · Advento ${r.adventMonths || 0}`,
      });
    }
  }

  const [hosted, guested, giftsFrom, giftsTo] = await Promise.all([
    safe(db.collection('companies').where('hostId', '==', uid).get()),
    safe(db.collection('companies').where('guestId', '==', uid).get()),
    safe(db.collection('trailGifts').where('fromUid', '==', uid).get()),
    safe(db.collection('trailGifts').where('toUid', '==', uid).get()),
  ]);
  for (const d of [...(hosted?.docs || []), ...(guested?.docs || [])]) {
    const other = d.get('hostId') === uid ? d.get('guestId') : d.get('hostId');
    const otherName = d.get('hostId') === uid ? d.get('guestName') : d.get('hostName');
    const start = msOf(d.get('guestJoinedAt')) || msOf(d.createTime);
    push(start, 'together', 'Companhia começou', { detail: otherName || '', uid: other });
    push(msOf(d.get('endedAt')), 'together', 'Companhia terminou', { detail: otherName || '', uid: other });
  }
  for (const d of giftsFrom?.docs || []) {
    push(msOf(d.get('createdAt')), 'gift', 'Criou presente de trilha', { detail: d.id });
    push(msOf(d.get('redeemedAt')), 'gift', 'Presente resgatado', { detail: d.get('toName') || '', uid: d.get('toUid') });
  }
  for (const d of giftsTo?.docs || []) {
    push(msOf(d.get('redeemedAt')), 'gift', 'Recebeu presente de trilha', { detail: d.get('trailSlug') || '', uid: d.get('fromUid') });
  }

  const rooms = await safe(db.collection('rooms').listDocuments());
  if (rooms?.length) {
    const memberRefs = rooms.map((r) => r.collection('members').doc(uid));
    for (let i = 0; i < memberRefs.length; i += 100) {
      const snaps = await db.getAll(...memberRefs.slice(i, i + 100));
      const hits = snaps.filter((s) => s.exists);
      const roomSnaps = hits.length ? await db.getAll(...hits.map((s) => s.ref.parent.parent)) : [];
      hits.forEach((s, k) => {
        push(msOf(s.createTime), 'together', 'Entrou no grupo', { detail: roomSnaps[k]?.get('name') || s.ref.parent.parent.id });
      });
    }
  }

  const [rep1, rep2, rep3, rep4, mod] = await Promise.all([
    safe(db.collection('user_reports').where('targetUid', '==', uid).get()),
    safe(db.collection('user_reports').where('reporterUid', '==', uid).get()),
    safe(db.collection('app_reports').where('uid', '==', uid).get()),
    safe(db.collection('content_question_reports').where('uid', '==', uid).get()),
    safe(db.collection('moderation_log').where('uid', '==', uid).get()),
  ]);
  for (const d of rep1?.docs || []) push(msOf(d.get('createdAt')), 'report', 'Foi denunciada', { detail: d.get('reason') || '' });
  for (const d of rep2?.docs || []) push(msOf(d.get('createdAt')), 'report', 'Denunciou alguém', { detail: d.get('reason') || '', uid: d.get('targetUid') });
  for (const d of rep3?.docs || []) push(msOf(d.get('createdAt')), 'report', 'Relatou problema no app', { detail: String(d.get('comment') || d.get('category') || '').slice(0, 80) });
  for (const d of rep4?.docs || []) push(msOf(d.get('createdAt')), 'report', 'Relatou erro em pergunta', { detail: String(d.get('comment') || d.get('reason') || '').slice(0, 80) });
  for (const d of mod?.docs || []) push(msOf(d.get('at')), 'moderation', `Moderação: ${d.get('action') || ''}`, { detail: d.get('reason') || '' });

  for (const id of Object.keys(advent.DEFAULTS)) {
    const p = await safe(db.doc(`seasonWalks/${id}/proof/${uid}`).get());
    if (p?.exists) {
      push(p.get('lastDoneMs'), 'season', `${id}: ${p.get('count') || 0} cena(s) provada(s)`);
      push(p.get('completedAtMs'), 'season', `${id}: concluiu`);
    }
    const r = await safe(db.doc(`seasonWalks/${id}/rewards/${uid}`).get());
    if (r?.exists) push(r.get('firstAtMs'), 'season', `${id}: prêmio ${r.get('tier')} · ${r.get('months') || 0} mês(es)`);
  }

  events.sort((a, b) => (a.at < b.at ? 1 : a.at > b.at ? -1 : 0));
  return { events };
}

module.exports = { recordWebhook, opsStatus, adventStatus, timeline, OPS_REF };
