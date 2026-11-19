'use strict';

/**
 * Convite que vira assinatura: quem convidou ganha 1 mês de Peregrino+.
 *
 * 1. Atribuição (triggers em index.js): quem entra por um convite —
 *    companhia (`companies/{code}` ganha guestId), grupo
 *    (`rooms/{code}/members/{uid}` nasce, convidado = líder) ou passe de
 *    trilha (`trailGifts/{code}` ganha toUid) — fica marcado em
 *    `users/{convidado}/server/referral` com quem convidou. Vale a
 *    primeira atribuição. Quem já é Plus pago no momento não conta.
 *    O cliente nunca grava isso (sem regra = negado).
 * 2. Recompensa (webhook RevenueCat): no primeiro pagamento real do
 *    convidado (compra fora do teste ou conversão do teste) quem convidou
 *    ganha 1 mês. Uma vez por convidado. Até 12 meses por 365 dias.
 * 3. Entrega: se quem convidou está sem Plus, o mês entra na hora como
 *    entitlement promocional do RevenueCat (o SDK no aparelho já enxerga).
 *    Se já tem Plus, o mês fica guardado e entra quando o Plus acabar
 *    (EXPIRATION no webhook ou a varredura de hora em hora).
 *
 * Saldo visível ao dono em `referralRewards/{uid}` (só leitura; no topo
 * para a varredura consultar `banked > 0` sem índice de collection group).
 * Reembolso do convidado não revoga o mês (decisão de produto).
 */

const { FieldValue } = require('firebase-admin/firestore');

const ENTITLEMENT_ID = 'peregrino_plus';
const TOMBSTONES = 'deletedAccounts';
const MONTH_MS = 30 * 24 * 3600 * 1000;
const YEAR_MS = 365 * 24 * 3600 * 1000;
const YEARLY_CAP = 12;
const VIA = new Set(['companhia', 'grupo', 'passe']);

const attributionRef = (db, uid) => db.doc(`users/${uid}/server/referral`);
const summaryRef = (db, uid) => db.doc(`referralRewards/${uid}`);

function cleanUid(v) {
  const s = String(v || '').trim();
  return s && !s.startsWith('$RCAnonymousID') ? s : '';
}

// ---- Decisões puras ------------------------------------------------------

/**
 * Este evento do RevenueCat é o primeiro pagamento real? Devolve o uid
 * de quem pagou, ou null. Teste grátis não conta (conta a conversão).
 * Promocional nunca conta: senão o mês dado geraria outro mês.
 */
function paidUidFromEvent(event, { allowSandbox = false } = {}) {
  if (!event || typeof event !== 'object') return null;
  if (!allowSandbox && String(event.environment || '') === 'SANDBOX') return null;
  if (String(event.store || '') === 'PROMOTIONAL') return null;
  const ids = Array.isArray(event.entitlement_ids)
    ? event.entitlement_ids
    : typeof event.entitlement_id === 'string'
      ? [event.entitlement_id]
      : [];
  if (!ids.includes(ENTITLEMENT_ID)) return null;
  const type = String(event.type || '');
  const inTrial = String(event.period_type || '') === 'TRIAL';
  const paid =
    (type === 'INITIAL_PURCHASE' && !inTrial) ||
    (type === 'RENEWAL' && event.is_trial_conversion === true);
  if (!paid) return null;
  return cleanUid(event.app_user_id) || null;
}

/** O Plus de quem convidou acabou (hora de soltar um mês guardado)? */
function expiredUidFromEvent(event) {
  if (!event || typeof event !== 'object') return null;
  if (String(event.type || '') !== 'EXPIRATION') return null;
  return cleanUid(event.app_user_id) || null;
}

/** Pode atribuir o convite? Pura: recebe o que já foi lido. */
function attributionDecision({ inviteeUid, inviterUid, via, alreadyAttributed, inviteePaidPlus }) {
  if (!inviteeUid || !inviterUid || inviteeUid === inviterUid) return false;
  if (!VIA.has(via)) return false;
  if (alreadyAttributed) return false;
  if (inviteePaidPlus) return false;
  return true;
}

/**
 * Concede (ou guarda) o mês? `earnedAtMs`: quando cada mês foi ganho.
 * Devolve 'cap' (passou do teto), 'grant' (sem Plus: entra já) ou 'bank'.
 */
function rewardDecision({ earnedAtMs, now, inviterHasPlus }) {
  const recent = (earnedAtMs || []).filter((t) => typeof t === 'number' && now - t < YEAR_MS);
  if (recent.length >= YEARLY_CAP) return 'cap';
  return inviterHasPlus ? 'bank' : 'grant';
}

/** Plus pago agora pelo doc público (gravado só pelo webhook). */
function paidPlusFromProfile(data, now = Date.now()) {
  if (!data || data.plusActive !== true || data.plusInTrial === true) return false;
  const exp = data.plusExpiresAt ? Date.parse(data.plusExpiresAt) : NaN;
  return Number.isNaN(exp) || exp > now;
}

// ---- RevenueCat REST (v1) -----------------------------------------------

/**
 * Cliente mínimo. `fetchImpl` injetável para teste.
 * hasPlus: entitlement ativo agora (pago, teste ou promocional).
 */
function revenueCatClient(secretKey, fetchImpl = fetch) {
  const base = 'https://api.revenuecat.com/v1/subscribers/';
  const headers = {
    Authorization: `Bearer ${secretKey}`,
    'Content-Type': 'application/json',
  };
  return {
    async hasPlus(uid, now = Date.now()) {
      const res = await fetchImpl(base + encodeURIComponent(uid), { headers });
      if (!res.ok) throw new Error(`revenuecat get ${res.status}`);
      const body = await res.json();
      const ent = body?.subscriber?.entitlements?.[ENTITLEMENT_ID];
      if (!ent) return false;
      if (ent.expires_date == null) return true; // vitalício
      return Date.parse(ent.expires_date) > now;
    },
    async grantMonth(uid, now = Date.now()) {
      const url = `${base}${encodeURIComponent(uid)}/entitlements/${ENTITLEMENT_ID}/promotional`;
      const endMs = now + MONTH_MS;
      const res = await fetchImpl(url, {
        method: 'POST',
        headers,
        body: JSON.stringify({ end_time_ms: endMs }),
      });
      if (!res.ok) throw new Error(`revenuecat grant ${res.status}`);
      return endMs;
    },
    /** Plus promocional por [days] dias (painel: teste manual). */
    async grantDays(uid, days, now = Date.now()) {
      const url = `${base}${encodeURIComponent(uid)}/entitlements/${ENTITLEMENT_ID}/promotional`;
      const endMs = now + days * 86_400_000;
      const res = await fetchImpl(url, {
        method: 'POST',
        headers,
        body: JSON.stringify({ end_time_ms: endMs }),
      });
      if (!res.ok) throw new Error(`revenuecat grant ${res.status}`);
      return endMs;
    },
    /** Tira todo Plus promocional (o pago pela loja fica). */
    async revokePromotional(uid) {
      const url = `${base}${encodeURIComponent(uid)}/entitlements/${ENTITLEMENT_ID}/revoke_promotionals`;
      const res = await fetchImpl(url, { method: 'POST', headers });
      if (!res.ok) throw new Error(`revenuecat revoke ${res.status}`);
    },
  };
}

// ---- Firestore -----------------------------------------------------------

/**
 * Marca quem convidou. Idempotente: a primeira atribuição fica.
 * Devolve true quando gravou.
 */
async function attribute(db, { inviteeUid, inviterUid, via, code }) {
  inviteeUid = cleanUid(inviteeUid);
  inviterUid = cleanUid(inviterUid);
  if (!inviteeUid || !inviterUid || inviteeUid === inviterUid) return false;
  const ref = attributionRef(db, inviteeUid);
  return db.runTransaction(async (tx) => {
    const [mark, invitee, tombA, tombB] = await Promise.all([
      tx.get(ref),
      tx.get(db.doc(`users/${inviteeUid}`)),
      tx.get(db.doc(`${TOMBSTONES}/${inviteeUid}`)),
      tx.get(db.doc(`${TOMBSTONES}/${inviterUid}`)),
    ]);
    if (tombA.exists || tombB.exists) return false;
    const ok = attributionDecision({
      inviteeUid,
      inviterUid,
      via,
      alreadyAttributed: mark.exists,
      inviteePaidPlus: paidPlusFromProfile(invitee.exists ? invitee.data() : null),
    });
    if (!ok) return false;
    tx.set(ref, {
      inviterUid,
      via,
      code: String(code || ''),
      createdAt: FieldValue.serverTimestamp(),
    });
    return true;
  });
}

/**
 * Primeiro pagamento do convidado: conta o mês para quem convidou.
 * O mês é reservado na transação (rewardedAt + banked/pending) e só
 * depois vai ao RevenueCat — reenvio do webhook não paga duas vezes.
 */
async function rewardInviter(db, rc, inviteeUid, logger, now = Date.now()) {
  const ref = attributionRef(db, inviteeUid);
  const pre = await ref.get();
  if (!pre.exists || pre.get('rewardedAt')) return null;
  const inviterUid = pre.get('inviterUid');
  if (!inviterUid) return null;

  // Fora da transação: chamada externa. Na dúvida (API fora), guarda.
  let inviterHasPlus = true;
  try {
    inviterHasPlus = await rc.hasPlus(inviterUid, now);
  } catch (e) {
    logger?.warn?.('indicação: não consegui ler o Plus de quem convidou', {
      inviterUid,
      error: e.message,
    });
  }

  const invitee = await db.doc(`users/${inviteeUid}`).get();
  const inviteeName =
    String((invitee.exists && (invitee.get('name') || invitee.get('displayName'))) || '')
      .trim()
      .split(/\s+/)[0]
      .slice(0, 40);

  const sumRef = summaryRef(db, inviterUid);
  const decision = await db.runTransaction(async (tx) => {
    const [mark, sum, tomb] = await Promise.all([
      tx.get(ref),
      tx.get(sumRef),
      tx.get(db.doc(`${TOMBSTONES}/${inviterUid}`)),
    ]);
    if (!mark.exists || mark.get('rewardedAt')) return null;
    if (tomb.exists) {
      tx.set(ref, { rewardedAt: now, outcome: 'gone' }, { merge: true });
      return null;
    }
    const earnedAtMs = sum.exists ? sum.get('earnedAtMs') || [] : [];
    const d = rewardDecision({ earnedAtMs, now, inviterHasPlus });
    tx.set(ref, { rewardedAt: now, outcome: d }, { merge: true });
    if (d === 'cap') return d;
    const banked = (sum.exists ? sum.get('banked') || 0 : 0) + 1;
    tx.set(
      sumRef,
      {
        earnedTotal: FieldValue.increment(1),
        earnedAtMs: [...earnedAtMs.filter((t) => now - t < YEAR_MS), now],
        banked,
        lastReward: { name: inviteeName, at: now, kept: d === 'bank' },
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return d;
  });
  if (decision === 'grant') await releaseBanked(db, rc, inviterUid, logger, now, { knownNoPlus: true });
  logger?.info?.('indicação: mês contado', { inviterUid, inviteeUid, decision });
  return decision;
}

/**
 * Solta um mês guardado se quem convidou está sem Plus.
 * Tira 1 do saldo na transação antes do POST; se o POST falhar, devolve.
 */
async function releaseBanked(db, rc, uid, logger, now = Date.now(), { knownNoPlus = false } = {}) {
  const sumRef = summaryRef(db, uid);
  const sum = await sumRef.get();
  if (!sum.exists || !(sum.get('banked') > 0)) return false;
  const promoUntil = sum.get('promoUntilMs');
  if (typeof promoUntil === 'number' && promoUntil > now) return false;
  if (!knownNoPlus) {
    try {
      if (await rc.hasPlus(uid, now)) return false;
    } catch (e) {
      logger?.warn?.('indicação: não consegui ler o Plus', { uid, error: e.message });
      return false;
    }
  }
  const took = await db.runTransaction(async (tx) => {
    const s = await tx.get(sumRef);
    const banked = s.exists ? s.get('banked') || 0 : 0;
    const until = s.exists ? s.get('promoUntilMs') : null;
    if (banked <= 0 || (typeof until === 'number' && until > now)) return false;
    tx.set(
      sumRef,
      { banked: banked - 1, promoUntilMs: now + MONTH_MS, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
    return true;
  });
  if (!took) return false;
  try {
    const endMs = await rc.grantMonth(uid, now);
    await sumRef.set(
      { promoUntilMs: endMs, grantedTotal: FieldValue.increment(1) },
      { merge: true },
    );
    logger?.info?.('indicação: mês entregue', { uid });
    return true;
  } catch (e) {
    await sumRef.set(
      { banked: FieldValue.increment(1), promoUntilMs: null },
      { merge: true },
    );
    logger?.error?.('indicação: falha ao entregar o mês', { uid, error: e.message });
    return false;
  }
}

/** Varredura: todo mundo com mês guardado e sem Plus recebe o próximo. */
async function releaseAllBanked(db, rc, logger, now = Date.now()) {
  const snap = await db.collection('referralRewards').where('banked', '>', 0).get();
  let released = 0;
  for (const doc of snap.docs) {
    if (await releaseBanked(db, rc, doc.id, logger, now)) released++;
  }
  return released;
}

module.exports = {
  ENTITLEMENT_ID,
  YEARLY_CAP,
  MONTH_MS,
  paidUidFromEvent,
  expiredUidFromEvent,
  attributionDecision,
  rewardDecision,
  paidPlusFromProfile,
  revenueCatClient,
  attribute,
  rewardInviter,
  releaseBanked,
  releaseAllBanked,
};
