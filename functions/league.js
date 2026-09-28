'use strict';

/**
 * Caravana semanal no servidor.
 *
 * - Salas (`cohorts`): quem joga primeiro na semana entra na primeira sala
 *   aberta da própria divisão; cheia (COHORT_SIZE), abre a próxima.
 * - Fechamento: segunda 00:10 (São Paulo) cada sala da semana que acabou é
 *   ordenada e ~25% sobe / ~15% desce (mesma regra do app,
 *   `LeagueService.promoteCountFor` / `demoteCountFor`).
 * - Ausência: quem fica 2 semanas sem jogar desce uma divisão (1× por ausência).
 *
 * O resultado vai para `users/{uid}.leagueResult` — campo só do servidor
 * (as regras do Firestore impedem o cliente de mexer nele).
 */

const COHORT_SIZE = 20;
const MAX_TIER = 4;
const TIME_ZONE = 'America/Sao_Paulo';

// ---- Regras puras (testadas em league.test.js) ---------------------------

function promoteCountFor(fieldSize) {
  if (fieldSize < 2) return 0;
  return Math.max(1, Math.round(fieldSize * 0.25));
}

function demoteCountFor(fieldSize) {
  if (fieldSize < 5) return 0;
  return Math.max(1, Math.round(fieldSize * 0.15));
}

/**
 * Fecha um campo (sala ou grupo fechado).
 * [entries]: `{ uid, xp, tier }` — só quem somou passos na semana.
 * Empates dividem a melhor posição (ninguém cai por empate).
 */
function settleField(entries) {
  const field = entries.filter((e) => e.xp > 0);
  const n = field.length;
  const promote = promoteCountFor(n);
  const demote = demoteCountFor(n);
  const sorted = [...field].sort((a, b) => b.xp - a.xp);
  return sorted.map((e) => {
    const rank = 1 + sorted.filter((o) => o.xp > e.xp).length;
    let outcome = 'stayed';
    let tier = e.tier;
    if (n < 2) {
      outcome = 'none';
    } else if (rank <= promote && e.tier < MAX_TIER) {
      outcome = 'promoted';
      tier = e.tier + 1;
    } else if (rank > n - demote && e.tier > 0) {
      outcome = 'demoted';
      tier = e.tier - 1;
    }
    return { uid: e.uid, rank, fieldSize: n, fromTier: e.tier, tier, outcome };
  });
}

/** Divisão de partida para decidir descida por ausência. */
function baseTierForInactive(user) {
  const prev = user.leagueResult;
  const leagueTier = Number.isInteger(user.leagueTier) ? user.leagueTier : 0;
  // Resultado ainda não aplicado no app (pessoa sumiu): vale o do servidor.
  if (prev && typeof prev.week === 'string'
      && prev.week >= (user.leagueProcessedWeek || '')) {
    return prev.tier;
  }
  return leagueTier;
}

/** Deve descer por ausência? Retorna o resultado ou null. */
function inactiveResult(user, { closedWeek, cutoff }) {
  const lastPlayed = user.lastPlayedDate || '';
  if (lastPlayed >= cutoff) return null;
  const prev = user.leagueResult;
  if (prev && prev.reason === 'inactive' && prev.lastPlayed === lastPlayed) {
    return null; // já desceu nesta ausência
  }
  const from = baseTierForInactive(user);
  if (!(from > 0)) return null;
  return {
    week: closedWeek,
    fromTier: from,
    tier: from - 1,
    outcome: 'demoted',
    reason: 'inactive',
    rank: 0,
    fieldSize: 0,
    lastPlayed,
  };
}

// ---- Datas (semana começa na segunda, fuso de São Paulo) -----------------

function ymdInZone(date, timeZone = TIME_ZONE) {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(date);
}

function addDays(ymd, days) {
  const d = new Date(`${ymd}T12:00:00Z`);
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}

function mondayOf(ymd) {
  const d = new Date(`${ymd}T12:00:00Z`);
  const offset = (d.getUTCDay() + 6) % 7;
  return addDays(ymd, -offset);
}

// ---- Firestore ----------------------------------------------------------

function chunk(list, size) {
  const out = [];
  for (let i = 0; i < list.length; i += size) out.push(list.slice(i, i + size));
  return out;
}

/** Coloca [uid] numa sala da divisão [tier] na semana [week]. Idempotente. */
async function assignCohort(db, { week, tier, uid }) {
  const tierRef = db.doc(`leagues/${week}/tiers/${tier}`);
  const cohorts = tierRef.collection('cohorts');
  const { FieldValue } = require('firebase-admin/firestore');
  return db.runTransaction(async (tx) => {
    const already = await tx.get(
      cohorts.where('members', 'array-contains', uid).limit(1),
    );
    if (!already.empty) return already.docs[0].id;
    const meta = (await tx.get(tierRef)).data() || {};
    let seq = meta.cohortSeq || 0;
    let openId = meta.openCohort;
    let count = meta.openCount || 0;
    if (!openId || count >= COHORT_SIZE) {
      seq += 1;
      openId = `c${String(seq).padStart(3, '0')}`;
      count = 1;
      tx.set(cohorts.doc(openId), {
        members: [uid],
        tier: Number(tier),
        week,
        createdAt: FieldValue.serverTimestamp(),
      });
    } else {
      count += 1;
      tx.update(cohorts.doc(openId), { members: FieldValue.arrayUnion(uid) });
    }
    tx.set(
      tierRef,
      { cohortSeq: seq, openCohort: openId, openCount: count },
      { merge: true },
    );
    return openId;
  });
}

/** Salas da divisão; quem ficou sem sala (antes do deploy) vira sala por chegada. */
async function fieldsForTier(db, week, tier) {
  const tierRef = db.doc(`leagues/${week}/tiers/${tier}`);
  const [playersSnap, cohortsSnap] = await Promise.all([
    tierRef.collection('players').get(),
    tierRef.collection('cohorts').get(),
  ]);
  const xpByUid = new Map();
  for (const d of playersSnap.docs) {
    xpByUid.set(d.id, Number(d.data().xp ?? d.data().steps ?? 0) || 0);
  }
  const seated = new Set();
  const fields = [];
  for (const c of cohortsSnap.docs) {
    const members = (c.data().members || []).filter((uid) => xpByUid.has(uid));
    members.forEach((uid) => seated.add(uid));
    fields.push(members.map((uid) => ({ uid, xp: xpByUid.get(uid), tier })));
  }
  const loose = playersSnap.docs
    .filter((d) => !seated.has(d.id))
    .sort((a, b) => a.createTime.toMillis() - b.createTime.toMillis())
    .map((d) => ({ uid: d.id, xp: xpByUid.get(d.id), tier }));
  for (const part of chunk(loose, COHORT_SIZE)) fields.push(part);
  return fields;
}

async function loadUsers(db, uids) {
  const out = new Map();
  for (const part of chunk(uids, 100)) {
    if (part.length === 0) continue;
    const snaps = await db.getAll(...part.map((uid) => db.doc(`users/${uid}`)));
    for (const s of snaps) if (s.exists) out.set(s.id, s.data());
  }
  return out;
}

/** Tira da semana nova quem já gravou placar na divisão antiga. */
async function moveToNewTier(db, currentWeek, uid, oldTier) {
  const { FieldValue } = require('firebase-admin/firestore');
  const tierRef = db.doc(`leagues/${currentWeek}/tiers/${oldTier}`);
  await tierRef.collection('players').doc(uid).delete();
  const seats = await tierRef
    .collection('cohorts')
    .where('members', 'array-contains', uid)
    .get();
  for (const s of seats.docs) {
    await s.ref.update({ members: FieldValue.arrayRemove(uid) });
  }
}

/** Fecha [closedWeek]. Idempotente via `leagueSettlements/{closedWeek}`. */
async function settleWeek(db, { closedWeek, currentWeek, logger }) {
  const lockRef = db.doc(`leagueSettlements/${closedWeek}`);
  const lock = await lockRef.get();
  if (lock.exists && lock.data().done) {
    logger?.info('semana já fechada', { closedWeek });
    return lock.data();
  }

  // 1) Salas por divisão. Se a pessoa mudou de divisão no meio da semana,
  //    vale onde somou mais passos.
  const results = new Map();
  for (let tier = 0; tier <= MAX_TIER; tier++) {
    const fields = await fieldsForTier(db, closedWeek, tier);
    for (const field of fields) {
      const xpOf = new Map(field.map((e) => [e.uid, e.xp]));
      for (const r of settleField(field)) {
        const prev = results.get(r.uid);
        if (!prev || xpOf.get(r.uid) > prev.xp) {
          results.set(r.uid, { ...r, xp: xpOf.get(r.uid) });
        }
      }
    }
  }

  // 2) Grupo fechado (célula/paróquia/amigos) substitui a sala automática.
  const users = await loadUsers(db, [...results.keys()]);
  const groups = new Map();
  for (const [uid, u] of users) {
    const code = typeof u.leagueGroupCode === 'string'
      ? u.leagueGroupCode.trim().toUpperCase()
      : '';
    if (!code) continue;
    if (!groups.has(code)) groups.set(code, []);
    groups.get(code).push(uid);
  }
  for (const [code, memberUids] of groups) {
    const snap = await db
      .collection(`leagueGroups/${code}/weeks/${closedWeek}/players`)
      .get();
    const field = snap.docs.map((d) => ({
      uid: d.id,
      xp: Number(d.data().xp ?? d.data().steps ?? 0) || 0,
      tier: results.get(d.id)?.fromTier
        ?? (Number.isInteger(users.get(d.id)?.leagueTier)
          ? users.get(d.id).leagueTier
          : 0),
    }));
    const mine = new Set(memberUids);
    for (const r of settleField(field)) {
      if (!mine.has(r.uid)) continue;
      results.set(r.uid, { ...r, group: code });
    }
  }

  // 3) Grava resultados e limpa placar da semana nova na divisão antiga.
  const { FieldValue } = require('firebase-admin/firestore');
  const entries = [...results.values()];
  for (const part of chunk(entries, 400)) {
    const batch = db.batch();
    for (const r of part) {
      batch.set(
        db.doc(`users/${r.uid}`),
        {
          leagueResult: {
            week: closedWeek,
            fromTier: r.fromTier,
            tier: r.tier,
            outcome: r.outcome,
            rank: r.rank,
            fieldSize: r.fieldSize,
            ...(r.group ? { group: r.group } : {}),
            settledAt: FieldValue.serverTimestamp(),
          },
        },
        { merge: true },
      );
    }
    await batch.commit();
  }
  for (const r of entries) {
    if (r.tier !== r.fromTier) {
      await moveToNewTier(db, currentWeek, r.uid, r.fromTier);
    }
  }

  // 4) Ausência: 2 semanas sem jogar (nem a que fechou, nem a anterior).
  const cutoff = addDays(closedWeek, -7);
  const ranked = await db.collection('users').where('leagueTier', '>', 0).get();
  let inactive = 0;
  const writes = [];
  for (const d of ranked.docs) {
    if (results.has(d.id)) continue;
    const r = inactiveResult(d.data(), { closedWeek, cutoff });
    if (!r) continue;
    inactive += 1;
    writes.push([d.ref, r]);
  }
  for (const part of chunk(writes, 400)) {
    const batch = db.batch();
    for (const [ref, r] of part) {
      batch.set(
        ref,
        { leagueResult: { ...r, settledAt: FieldValue.serverTimestamp() } },
        { merge: true },
      );
    }
    await batch.commit();
  }

  const summary = {
    done: true,
    closedWeek,
    settled: entries.length,
    promoted: entries.filter((r) => r.outcome === 'promoted').length,
    demoted: entries.filter((r) => r.outcome === 'demoted').length,
    inactiveDemoted: inactive,
    at: FieldValue.serverTimestamp(),
  };
  await lockRef.set(summary);
  logger?.info('caravana fechada', { ...summary, at: undefined });
  return summary;
}

module.exports = {
  COHORT_SIZE,
  MAX_TIER,
  TIME_ZONE,
  promoteCountFor,
  demoteCountFor,
  settleField,
  baseTierForInactive,
  inactiveResult,
  ymdInZone,
  addDays,
  mondayOf,
  assignCohort,
  settleWeek,
};
