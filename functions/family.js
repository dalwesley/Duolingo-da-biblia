'use strict';

/**
 * Casal e Família: o mesmo Peregrino+ em 2, 3 ou 4 contas.
 *
 * A loja não divide assinatura entre contas diferentes (nem entre Android
 * e iOS), então a divisão mora aqui:
 *
 * 1. Quem compra (o titular) assina um produto de família na loja. O
 *    webhook do RevenueCat chama [familyActionFromEvent] e cria ou
 *    atualiza `families/{titular}`: produto, vagas, fim e um código de
 *    convite.
 * 2. O titular manda o link (`stway://familia/CODIGO`). Quem entra chama
 *    a callable `familyAction` (join). A vaga é reservada na transação e
 *    o Plus entra como entitlement promocional do RevenueCat até o fim da
 *    assinatura do titular (+ [GRACE_MS]). O app do membro enxerga pelo
 *    SDK, sem nada especial.
 * 3. Renovou: os membros ganham um promocional novo até o novo fim.
 *    Venceu, foi reembolsado ou trocou para um plano individual: o plano
 *    fica pausado (`active: false`) e os promocionais dos membros saem.
 *    Os membros continuam na lista: se o titular voltar a assinar a
 *    família, o Plus volta para todos sem novo convite.
 *
 * O membro nunca grava nada: o doc é só leitura para titular e membros
 * (firestore.rules). Um membro está em uma família por vez.
 *
 * Revogar promocional no RevenueCat tira TODOS os promocionais da conta
 * (mês de indicação, Plus de pastor). [restoreOtherPromos] devolve os que
 * ainda valiam.
 */

const { FieldValue } = require('firebase-admin/firestore');

const ENTITLEMENT_ID = 'peregrino_plus';
const FAMILIES = 'families';
const TOMBSTONES = 'deletedAccounts';

/** Vagas extras de cada produto (o titular já conta como uma pessoa). */
const FAMILY_PRODUCTS = {
  plus_casal_annual: 1,
  plus_familia3_annual: 2,
  plus_familia4_annual: 3,
};

/** Folga do promocional depois do fim: a renovação chega a tempo. */
const GRACE_MS = 3 * 24 * 3600 * 1000;

/** Sem I, O, 0 e 1: código ditado por telefone não confunde. */
const CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const CODE_LENGTH = 6;

class FamilyError extends Error {
  constructor(code, message, reason) {
    super(message);
    this.code = code;
    this.reason = reason || code;
  }
}

// ---- Decisões puras --------------------------------------------------------

/** Id da loja sem o plano base do Android (`plus_casal_annual:annual`). */
function baseProductId(id) {
  return String(id || '').split(':')[0];
}

/** Vagas extras do produto, ou 0 se não é plano de família. */
function seatsForProduct(id) {
  return FAMILY_PRODUCTS[baseProductId(id)] || 0;
}

function cleanUid(v) {
  const s = String(v || '').trim();
  return s && !s.startsWith('$RCAnonymousID') ? s : '';
}

/**
 * O que este evento do RevenueCat faz com a família do titular.
 * Devolve null (nada), {kind:'sync', uid, productId, seats, expiresMs}
 * ou {kind:'pause', uid}. Pura, para testar.
 *
 * - Compra, renovação, volta do cancelamento, extensão: sync.
 * - Troca de plano: só a subida entra na hora (mais vagas). A descida
 *   espera a renovação, que já vem com o produto novo.
 * - Fim (EXPIRATION) de um produto de família: pausa.
 * - Compra ou renovação de um produto que não é de família (o titular
 *   voltou ao individual): pausa, se havia família.
 * - Cancelamento: nada (o acesso vai até o fim). Reembolso chega como
 *   CANCELLATION com motivo CUSTOMER_SUPPORT: pausa.
 * - Promocional nunca mexe em família (o promocional do membro não pode
 *   criar uma família para ele).
 */
function familyActionFromEvent(event, { allowSandbox = false } = {}) {
  if (!event || typeof event !== 'object') return null;
  if (!allowSandbox && String(event.environment || '') === 'SANDBOX') return null;
  if (String(event.store || '') === 'PROMOTIONAL') return null;
  const type = String(event.type || '');
  if (type === 'TRANSFER') return null;
  const uid = cleanUid(event.app_user_id);
  if (!uid) return null;
  const product = String(event.product_id || '');
  const seats = seatsForProduct(product);
  const expiresMs =
    typeof event.expiration_at_ms === 'number' ? event.expiration_at_ms : null;

  if (type === 'PRODUCT_CHANGE') {
    const next = String(event.new_product_id || '');
    const nextSeats = seatsForProduct(next);
    if (nextSeats > seats && nextSeats > 0) {
      return { kind: 'sync', uid, productId: baseProductId(next), seats: nextSeats, expiresMs, upgradeOnly: true };
    }
    return null;
  }
  if (type === 'EXPIRATION') {
    return seats > 0 ? { kind: 'pause', uid } : null;
  }
  if (type === 'CANCELLATION') {
    const refund = String(event.cancel_reason || '') === 'CUSTOMER_SUPPORT';
    return seats > 0 && refund ? { kind: 'pause', uid } : null;
  }
  const renewing = new Set([
    'INITIAL_PURCHASE',
    'RENEWAL',
    'UNCANCELLATION',
    'SUBSCRIPTION_EXTENDED',
  ]);
  if (!renewing.has(type)) return null;
  if (seats === 0) {
    // Assinatura individual nova: se havia família, ela pausa. Compra
    // avulsa (apoio, vitalício) não encerra a família de ninguém.
    return type === 'INITIAL_PURCHASE' || type === 'RENEWAL'
      ? { kind: 'pause', uid, onlyIfExists: true }
      : null;
  }
  if (expiresMs == null || expiresMs <= Date.now()) return null;
  return { kind: 'sync', uid, productId: baseProductId(product), seats, expiresMs };
}

/**
 * Pode entrar? Pura: recebe o que já foi lido. Devolve null (pode) ou o
 * motivo: invalid, inactive, own, full, other_family, has_plus.
 */
function joinDecision({ family, uid, now, otherFamilyOwner, paidPlus }) {
  if (!family) return 'invalid';
  if (family.ownerUid === uid) return 'own';
  const members = family.members || {};
  if (members[uid]) return null; // já é membro: entra de novo sem gastar vaga
  if (otherFamilyOwner && otherFamilyOwner !== family.ownerUid) return 'other_family';
  if (family.active !== true || !(family.expiresAtMs > now)) return 'inactive';
  if (paidPlus) return 'has_plus';
  if (Object.keys(members).length >= (family.seats || 0)) return 'full';
  return null;
}

/** Membros que sobram depois de diminuir as vagas: os que entraram por último. */
function membersOverSeats(members, seats) {
  const list = Object.entries(members || {}).sort(
    (a, b) => (a[1].joinedAtMs || 0) - (b[1].joinedAtMs || 0),
  );
  return list.slice(Math.max(0, seats)).map(([uid]) => uid);
}

/**
 * Plus pago pela loja que faria a pessoa pagar duas vezes: assinatura que
 * renova ou vitalício. Promocional (indicação, pastor, outra família) e
 * assinatura já cancelada não contam.
 */
function paidPlusBlocks(info) {
  if (!info || !info.active) return false;
  const product = String(info.productId || '');
  if (!product || product.startsWith('rc_promo')) return false;
  if (info.expiresAt == null) return true; // vitalício
  return info.willRenew === true;
}

function newCode(random = Math.random) {
  let out = '';
  for (let i = 0; i < CODE_LENGTH; i++) {
    out += CODE_ALPHABET[Math.floor(random() * CODE_ALPHABET.length)];
  }
  return out;
}

function normalizeCode(raw) {
  const s = String(raw || '').trim().toUpperCase();
  return /^[A-Z0-9]{6}$/.test(s) ? s : '';
}

// ---- RevenueCat ------------------------------------------------------------

/**
 * Promocional até [endMs]. Usa o cliente de referral.js (mesma chave).
 * O RevenueCat soma promocionais: o maior fim vale.
 */
async function grantUntil(rc, uid, endMs) {
  if (typeof rc.grantUntil !== 'function') throw new Error('cliente RevenueCat sem grantUntil');
  return rc.grantUntil(uid, endMs);
}

/** Primeiro nome curto, como o resto do app mostra. */
async function displayName(db, uid) {
  try {
    const snap = await db.doc(`users/${uid}`).get();
    const raw = snap.exists ? snap.get('name') || snap.get('displayName') || '' : '';
    return String(raw).trim().slice(0, 40);
  } catch (_) {
    return '';
  }
}

/** Espelho em users/{uid} a partir do RevenueCat (selo, passe, aceno). */
async function mirrorPlus(db, rc, uid, logger) {
  try {
    const tomb = await db.doc(`${TOMBSTONES}/${uid}`).get();
    if (tomb.exists) return;
    const info = await rc.plusInfo(uid);
    await db.doc(`users/${uid}`).set(
      info.active
        ? {
            plusActive: true,
            plusExpiresAt: info.expiresAt,
            plusProductId: info.productId,
            plusInTrial: info.inTrial === true,
            plusWillRenew: info.willRenew === true,
            plusUpdatedAt: FieldValue.serverTimestamp(),
          }
        : {
            plusActive: false,
            plusWillRenew: false,
            plusInTrial: false,
            plusUpdatedAt: FieldValue.serverTimestamp(),
          },
      { merge: true },
    );
  } catch (e) {
    logger?.warn?.('família: espelho do Plus falhou', { uid, error: e.message });
  }
}

/**
 * Depois de revogar: devolve os promocionais que não eram desta família
 * (mês de indicação ainda correndo, Plus de pastor).
 */
async function restoreOtherPromos(db, rc, uid, logger, now = Date.now()) {
  const ends = [];
  try {
    const ref = await db.doc(`referralRewards/${uid}`).get();
    const until = ref.exists ? ref.get('promoUntilMs') : null;
    if (typeof until === 'number' && until > now) ends.push(until);
  } catch (_) {
    /* sem saldo de indicação */
  }
  try {
    const pastor = await db.doc(`pastorGrants/${uid}`).get();
    const until = pastor.exists ? pastor.get('untilMs') : null;
    if (typeof until === 'number' && until > now) ends.push(until);
  } catch (_) {
    /* sem bolsa pastoral */
  }
  for (const end of ends) {
    try {
      await grantUntil(rc, uid, end);
    } catch (e) {
      logger?.error?.('família: falha ao devolver promocional', { uid, error: e.message });
    }
  }
}

/** Tira o Plus da família de um membro (e devolve os outros promocionais). */
async function revokeMember(db, rc, uid, logger) {
  if (!rc) return false;
  try {
    await rc.revokePromotional(uid);
    await restoreOtherPromos(db, rc, uid, logger);
    await mirrorPlus(db, rc, uid, logger);
    return true;
  } catch (e) {
    logger?.error?.('família: falha ao revogar', { uid, error: e.message });
    return false;
  }
}

async function grantMember(db, rc, uid, expiresAtMs, logger) {
  if (!rc) return false;
  try {
    await grantUntil(rc, uid, expiresAtMs + GRACE_MS);
    await mirrorPlus(db, rc, uid, logger);
    return true;
  } catch (e) {
    logger?.error?.('família: falha ao conceder', { uid, error: e.message });
    return false;
  }
}

// ---- Webhook -----------------------------------------------------------------

/**
 * Aplica a ação do webhook. Transação para o doc; chamadas ao RevenueCat
 * depois (rede fora de transação).
 */
async function applyFamilyEvent(db, rc, event, logger, { allowSandbox = false } = {}) {
  const action = familyActionFromEvent(event, { allowSandbox });
  if (!action) return null;
  const ref = db.doc(`${FAMILIES}/${action.uid}`);

  if (action.kind === 'pause') {
    const members = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists) return null;
      if (snap.get('active') !== true) return [];
      tx.set(ref, { active: false, pausedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() }, { merge: true });
      return Object.keys(snap.get('members') || {});
    });
    if (members == null) return null;
    for (const m of members) await revokeMember(db, rc, m, logger);
    logger?.info?.('família: pausada', { owner: action.uid, members: members.length });
    return { kind: 'pause', owner: action.uid };
  }

  const ownerName = await displayName(db, action.uid);
  const result = await db.runTransaction(async (tx) => {
    const tomb = await tx.get(db.doc(`${TOMBSTONES}/${action.uid}`));
    if (tomb.exists) return null;
    const snap = await tx.get(ref);
    const prev = snap.exists ? snap.data() : {};
    const seats = action.upgradeOnly ? Math.max(prev.seats || 0, action.seats) : action.seats;
    const members = { ...(prev.members || {}) };
    const removed = membersOverSeats(members, seats);
    for (const uid of removed) delete members[uid];
    const expiresAtMs = action.expiresMs ?? prev.expiresAtMs ?? null;
    tx.set(
      ref,
      {
        ownerUid: action.uid,
        ownerName: ownerName || prev.ownerName || '',
        productId: action.productId,
        seats,
        expiresAtMs,
        active: true,
        inviteCode: prev.inviteCode || newCode(),
        members,
        memberIds: Object.keys(members),
        createdAt: prev.createdAt || FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: false },
    );
    return { members: Object.keys(members), removed, expiresAtMs };
  });
  if (!result) return null;
  // Era membro da família de outra pessoa e comprou a própria: sai da
  // outra (a vaga volta para aquele titular).
  try {
    const asMember = await familyOfMember(db, action.uid);
    if (asMember && asMember.id !== action.uid) {
      await removeMember({ db, rc, logger }, asMember.id, action.uid, { self: true });
    }
  } catch (e) {
    logger?.warn?.('família: não saiu da família anterior', { uid: action.uid, error: e.message });
  }
  for (const uid of result.removed) await revokeMember(db, rc, uid, logger);
  if (result.expiresAtMs) {
    for (const uid of result.members) await grantMember(db, rc, uid, result.expiresAtMs, logger);
  }
  logger?.info?.('família: sincronizada', {
    owner: action.uid,
    seats: action.seats,
    members: result.members.length,
    removed: result.removed.length,
  });
  return { kind: 'sync', owner: action.uid };
}

// ---- Callable (app) ----------------------------------------------------------

async function findFamilyByCode(db, code) {
  const snap = await db.collection(FAMILIES).where('inviteCode', '==', code).limit(1).get();
  return snap.empty ? null : snap.docs[0];
}

async function familyOfMember(db, uid) {
  const snap = await db.collection(FAMILIES).where('memberIds', 'array-contains', uid).limit(1).get();
  return snap.empty ? null : snap.docs[0];
}

/** Pré-visualização do convite: de quem é e se ainda cabe gente. */
async function peek(db, uid, code) {
  const doc = await findFamilyByCode(db, code);
  if (!doc) throw new FamilyError('not-found', 'Convite inválido.', 'invalid');
  const f = doc.data();
  return {
    ownerName: f.ownerName || '',
    seats: f.seats || 0,
    taken: Object.keys(f.members || {}).length,
    active: f.active === true && f.expiresAtMs > Date.now(),
    own: f.ownerUid === uid,
    member: Boolean((f.members || {})[uid]),
  };
}

async function join(deps, uid, code) {
  const { db, rc, logger } = deps;
  if (!rc) throw new FamilyError('unavailable', 'Plano da família indisponível agora.', 'unavailable');
  const doc = await findFamilyByCode(db, code);
  if (!doc) throw new FamilyError('not-found', 'Convite inválido.', 'invalid');
  const other = await familyOfMember(db, uid);
  // Plus pago fora da transação (rede). Na dúvida (API fora), não bloqueia.
  let paidPlus = false;
  try {
    paidPlus = paidPlusBlocks(await rc.plusInfo(uid));
  } catch (e) {
    logger?.warn?.('família: não consegui ler o Plus de quem entra', { uid, error: e.message });
  }
  const name = await displayName(db, uid);
  const now = Date.now();
  const outcome = await db.runTransaction(async (tx) => {
    const snap = await tx.get(doc.ref);
    const family = snap.exists ? snap.data() : null;
    const reason = joinDecision({
      family,
      uid,
      now,
      otherFamilyOwner: other ? other.id : null,
      paidPlus,
    });
    if (reason) return { reason };
    const members = { ...(family.members || {}) };
    const again = Boolean(members[uid]);
    if (!again) members[uid] = { name, joinedAtMs: now };
    tx.update(doc.ref, {
      members,
      memberIds: Object.keys(members),
      updatedAt: FieldValue.serverTimestamp(),
    });
    return { again, expiresAtMs: family.expiresAtMs, active: family.active === true };
  });
  if (outcome.reason) {
    const messages = {
      invalid: 'Convite inválido.',
      own: 'Este é o seu próprio plano.',
      other_family: 'Você já está em outro plano de família.',
      inactive: 'Este plano da família não está ativo.',
      has_plus: 'Você já tem o Peregrino+. Cancele a sua assinatura antes de entrar.',
      full: 'Todas as vagas deste plano já foram usadas.',
    };
    throw new FamilyError('failed-precondition', messages[outcome.reason], outcome.reason);
  }
  if (outcome.active) await grantMember(db, rc, uid, outcome.expiresAtMs, logger);
  logger?.info?.('família: entrou', { owner: doc.id, uid, again: outcome.again });
  return { ok: true, owner: doc.id };
}

async function removeMember(deps, ownerUid, memberUid, { self = false } = {}) {
  const { db, rc, logger } = deps;
  const ref = db.doc(`${FAMILIES}/${ownerUid}`);
  const removed = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return false;
    const members = { ...(snap.get('members') || {}) };
    if (!members[memberUid]) return false;
    delete members[memberUid];
    tx.update(ref, {
      members,
      memberIds: Object.keys(members),
      updatedAt: FieldValue.serverTimestamp(),
    });
    return true;
  });
  if (!removed) throw new FamilyError('not-found', 'Essa pessoa não está no plano.', 'not_member');
  await revokeMember(db, rc, memberUid, logger);
  logger?.info?.('família: saiu', { owner: ownerUid, uid: memberUid, self });
  return { ok: true };
}

async function rotateCode(deps, ownerUid) {
  const { db } = deps;
  const ref = db.doc(`${FAMILIES}/${ownerUid}`);
  const snap = await ref.get();
  if (!snap.exists) throw new FamilyError('not-found', 'Você não tem plano de família.', 'no_family');
  const code = newCode();
  await ref.update({ inviteCode: code, updatedAt: FieldValue.serverTimestamp() });
  return { ok: true, code };
}

/**
 * Entrada da callable `familyAction`.
 *   peek {code}      de quem é o convite
 *   join {code}      entrar
 *   leave            membro sai
 *   remove {uid}     titular tira alguém
 *   rotate           titular troca o código (link antigo para de valer)
 */
async function handle(deps, uid, input) {
  if (!uid) throw new FamilyError('unauthenticated', 'Entre na sua conta.', 'needs_account');
  const action = String(input?.action || '');
  if (action === 'peek' || action === 'join') {
    const code = normalizeCode(input?.code);
    if (!code) throw new FamilyError('invalid-argument', 'Convite inválido.', 'invalid');
    return action === 'peek' ? peek(deps.db, uid, code) : join(deps, uid, code);
  }
  if (action === 'leave') {
    const doc = await familyOfMember(deps.db, uid);
    if (!doc) throw new FamilyError('not-found', 'Você não está em um plano de família.', 'not_member');
    return removeMember(deps, doc.id, uid, { self: true });
  }
  if (action === 'remove') {
    const member = String(input?.uid || '').trim();
    if (!member || member.length > 128) throw new FamilyError('invalid-argument', 'Pessoa inválida.', 'invalid');
    return removeMember(deps, uid, member);
  }
  if (action === 'rotate') return rotateCode(deps, uid);
  throw new FamilyError('invalid-argument', 'Ação desconhecida.', 'invalid');
}

/**
 * Conta excluída: sai da família em que estava (vaga volta para o
 * titular). Se era titular, o plano fica pausado e os membros perdem o
 * Plus (a assinatura da loja também morre com a conta).
 */
async function onAccountDeleted(deps, uid) {
  const { db, rc, logger } = deps;
  const asMember = await familyOfMember(db, uid);
  if (asMember) {
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(asMember.ref);
      const members = { ...(snap.get('members') || {}) };
      delete members[uid];
      tx.update(asMember.ref, { members, memberIds: Object.keys(members) });
    });
  }
  const own = await db.doc(`${FAMILIES}/${uid}`).get();
  if (own.exists) {
    for (const m of Object.keys(own.get('members') || {})) {
      await revokeMember(db, rc, m, logger);
    }
    await own.ref.delete();
  }
}

module.exports = {
  FAMILY_PRODUCTS,
  GRACE_MS,
  FamilyError,
  seatsForProduct,
  familyActionFromEvent,
  joinDecision,
  membersOverSeats,
  paidPlusBlocks,
  newCode,
  normalizeCode,
  applyFamilyEvent,
  restoreOtherPromos,
  handle,
  onAccountDeleted,
};
