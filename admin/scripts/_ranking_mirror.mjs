/**
 * Contrato do placar da Caravana: xp/steps nas coleções de ranking
 * têm de espelhar o progresso em users/{uid}.
 */

export function asInt(value, fallback = 0) {
  const n = Number(value);
  return Number.isFinite(n) ? Math.trunc(n) : fallback;
}

export function userTotalSteps(user) {
  if (!user) return 0;
  if (user.steps != null) return asInt(user.steps);
  if (user.xp != null) return asInt(user.xp);
  return 0;
}

export function userWeeklySteps(user) {
  if (!user) return 0;
  if (user.weeklySteps != null) return asInt(user.weeklySteps);
  if (user.weeklyXp != null) return asInt(user.weeklyXp);
  return 0;
}

export function userMonthlySteps(user) {
  if (!user) return 0;
  if (user.monthlySteps != null) return asInt(user.monthlySteps);
  return 0;
}

export function rankingScore(doc) {
  if (!doc) return 0;
  if (doc.xp != null) return asInt(doc.xp);
  if (doc.steps != null) return asInt(doc.steps);
  return 0;
}

export function rankingPayload(user, { xp, tier } = {}) {
  const name =
    typeof user?.userName === 'string' && user.userName.trim()
      ? user.userName.trim()
      : typeof user?.name === 'string' && user.name.trim()
        ? user.name.trim()
        : 'Aprendiz';
  const payload = {
    name,
    xp,
    lastWalkDate: user?.lastPlayedDate ?? user?.lastWalkDate ?? null,
    lastSeenDate: user?.lastSeenDate ?? null,
  };
  if (tier != null) payload.tier = tier;
  return payload;
}

/**
 * @returns {{ kind: string, uid: string, expected: number, actual: number, path: string } | null}
 */
export function mismatch(kind, uid, path, expected, actual) {
  if (expected === actual) return null;
  return { kind, uid, path, expected, actual };
}

export function inspectOverall(uid, user, ranking) {
  return mismatch(
    'overall',
    uid,
    `overallPlayers/${uid}`,
    userTotalSteps(user),
    rankingScore(ranking),
  );
}

export function inspectWeekly(uid, user, ranking, week) {
  const userWeek = user?.weeklyWeek;
  if (userWeek && week && userWeek !== week) {
    return {
      kind: 'weekly-week',
      uid,
      path: `leagues/${week}/players/${uid}`,
      expected: userWeek,
      actual: week,
    };
  }
  return mismatch(
    'weekly',
    uid,
    `leagues/${week}/players/${uid}`,
    userWeeklySteps(user),
    rankingScore(ranking),
  );
}

export function inspectMonthly(uid, user, ranking, month) {
  const userMonth = user?.monthlyMonth;
  if (userMonth && month && userMonth !== month) {
    return {
      kind: 'monthly-month',
      uid,
      path: `monthlyLeagues/${month}/players/${uid}`,
      expected: userMonth,
      actual: month,
    };
  }
  return mismatch(
    'monthly',
    uid,
    `monthlyLeagues/${month}/players/${uid}`,
    userMonthlySteps(user),
    rankingScore(ranking),
  );
}

export function inspectRoomMember(uid, user, member, roomCode) {
  return mismatch(
    'room',
    uid,
    `rooms/${roomCode}/members/${uid}`,
    userWeeklySteps(user),
    rankingScore(member),
  );
}

/** Heurística — não prova trapaça; só pede revisão. */
export function suspiciousProgress(uid, user) {
  const steps = userTotalSteps(user);
  const missions = Array.isArray(user?.completedMissions)
    ? user.completedMissions.length
    : 0;
  const ceiling = 250 * Math.max(1, missions) + 1000;
  if (steps <= ceiling) return null;
  return {
    kind: 'suspicious-steps',
    uid,
    path: `users/${uid}`,
    expected: ceiling,
    actual: steps,
  };
}

export function mondayKey(date = new Date(), timeZone = 'America/Sao_Paulo') {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    weekday: 'short',
  }).formatToParts(date);
  const pick = (type) => parts.find((p) => p.type === type)?.value;
  const y = Number(pick('year'));
  const m = Number(pick('month'));
  const d = Number(pick('day'));
  const weekday = pick('weekday');
  const asMondayOffset = {
    Mon: 0,
    Tue: 1,
    Wed: 2,
    Thu: 3,
    Fri: 4,
    Sat: 5,
    Sun: 6,
  };
  const offset = asMondayOffset[weekday] ?? 0;
  const utc = Date.UTC(y, m - 1, d) - offset * 86400000;
  return new Date(utc).toISOString().slice(0, 10);
}

export function monthKey(date = new Date(), timeZone = 'America/Sao_Paulo') {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
  }).formatToParts(date);
  const y = parts.find((p) => p.type === 'year')?.value;
  const m = parts.find((p) => p.type === 'month')?.value;
  return `${y}-${m}`;
}
