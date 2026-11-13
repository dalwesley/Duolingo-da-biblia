'use strict';

/**
 * Moderação de peregrinos (painel admin → callable `moderateUser`).
 *
 * Base: Termos de Uso ("podemos remover o conteúdo, trocar o nome ou a foto,
 * e suspender ou excluir a conta de quem abusou") e App Store 1.2.
 *
 * Toda ação exige motivo e fica em `moderation_log` (quem, quando, por quê) —
 * é o registro que sustenta a decisão se a pessoa contestar. O estado atual
 * mora em `moderation/{uid}`. Os dois só o admin lê; ninguém grava pelo cliente.
 *
 *   info         dados do Auth (e-mail, login, criada, último acesso)
 *   emails       e-mail do Auth de uma lista de uids (a lista do Suporte;
 *                o perfil público não guarda mais e-mail)
 *   warn         aviso por push (fica no histórico mesmo sem push)
 *   rename       nome neutro no perfil, placares, grupos e companhias
 *   removePhoto  tira a foto do perfil, dos placares e do Auth
 *   suspend      desativa o login por N dias (volta sozinha: liftSuspensions)
 *   ban          inativa: desliga o login sem prazo (o Auth não deixa o mesmo
 *                e-mail entrar; perfil, placares e dados ficam como estão)
 *   reactivate   desfaz suspensão ou inativação
 *
 * Excluir conta não é ação de moderação: quem exclui é a própria pessoa (app).
 */

const { FieldValue, Timestamp } = require('firebase-admin/firestore');
const { rankingRefs } = require('./account');

const ACTIONS = new Set(['info', 'warn', 'rename', 'removePhoto', 'suspend', 'ban', 'reactivate']);
const SUSPEND_DAYS = new Set([1, 3, 7, 15, 30]);
const LOG = 'moderation_log';
const STATE = 'moderation';

class ModerationError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
  }
}

async function roleOf(db, uid) {
  if (!uid) return null;
  const snap = await db.doc(`admin_users/${uid}`).get();
  return snap.exists ? snap.get('role') || null : null;
}

/** Nome neutro e estável: o mesmo uid sempre vira o mesmo "Peregrino XXXX". */
function neutralName(uid) {
  return `Peregrino ${String(uid).slice(0, 4).toUpperCase()}`;
}

/** Atualiza só os docs que existem (os placares têm muitos caminhos vazios). */
async function updateExisting(db, refs, patch) {
  let n = 0;
  for (let i = 0; i < refs.length; i += 100) {
    const chunk = refs.slice(i, i + 100);
    const snaps = await db.getAll(...chunk);
    const batch = db.batch();
    let any = false;
    for (const s of snaps) {
      if (!s.exists) continue;
      batch.update(s.ref, patch);
      any = true;
      n += 1;
    }
    if (any) await batch.commit();
  }
  return n;
}

async function roomMemberRefs(db, uid) {
  const rooms = await db.collection('rooms').listDocuments();
  return rooms.map((r) => r.collection('members').doc(uid));
}

/** Nome do uid nas companhias (host ou guest). */
async function renameInCompanions(db, uid, name) {
  const [hosted, guested] = await Promise.all([
    db.collection('companies').where('hostId', '==', uid).get(),
    db.collection('companies').where('guestId', '==', uid).get(),
  ]);
  for (const d of hosted.docs) await d.ref.update({ hostName: name });
  for (const d of guested.docs) await d.ref.update({ guestName: name });
  return hosted.size + guested.size;
}

/** Uids únicos e curtos. O que não serve é ignorado. */
function uniqueUids(raw) {
  const uids = [];
  const seen = new Set();
  if (!Array.isArray(raw)) return uids;
  for (const item of raw) {
    const uid = String(item || '').trim();
    if (!uid || uid.length > 128 || seen.has(uid)) continue;
    seen.add(uid);
    uids.push(uid);
  }
  return uids;
}

/** E-mail do login, em lotes de 100 (limite do Auth). Sem e-mail, o uid fica de fora. */
async function emailsFor(auth, uids) {
  const emails = {};
  for (let i = 0; i < uids.length; i += 100) {
    const chunk = uids.slice(i, i + 100).map((uid) => ({ uid }));
    const res = await auth.getUsers(chunk);
    for (const u of res.users || []) {
      const email = String(u.email || '').trim();
      if (email) emails[u.uid] = email;
    }
  }
  return emails;
}

async function authInfo(auth, uid) {
  try {
    const u = await auth.getUser(uid);
    return {
      exists: true,
      email: u.email || null,
      emailVerified: Boolean(u.emailVerified),
      disabled: Boolean(u.disabled),
      providers: (u.providerData || []).map((p) => p.providerId),
      createdAt: u.metadata?.creationTime || null,
      lastSignInAt: u.metadata?.lastSignInTime || null,
      lastRefreshAt: u.metadata?.lastRefreshTime || null,
    };
  } catch (e) {
    if (e.code === 'auth/user-not-found') return { exists: false };
    throw e;
  }
}

/**
 * @param {{ db, auth, messaging, fcmTokenOf, logger }} deps
 * @param {{ uid: string, email?: string }} caller
 * @param {{ uid: string, action: string, reason?: string, message?: string, days?: number, reportId?: string }} input
 */
async function moderate(deps, caller, input) {
  const { db, auth, messaging, fcmTokenOf, logger } = deps;
  if ((await roleOf(db, caller?.uid)) !== 'admin') {
    throw new ModerationError('permission-denied', 'Só administradores moderam contas.');
  }

  const action = String(input?.action || '');
  if (action === 'emails') {
    const uids = uniqueUids(input?.uids);
    if (uids.length > 2000) throw new ModerationError('invalid-argument', 'Lista grande demais.');
    return { emails: await emailsFor(auth, uids) };
  }

  const uid = String(input?.uid || '').trim();
  const reason = String(input?.reason || '').trim().slice(0, 500);
  if (!uid || uid.length > 128) throw new ModerationError('invalid-argument', 'uid inválido.');
  if (!ACTIONS.has(action)) throw new ModerationError('invalid-argument', `Ação desconhecida: ${action}`);

  if (action === 'info') {
    const [authUser, state] = await Promise.all([authInfo(auth, uid), db.doc(`${STATE}/${uid}`).get()]);
    return { auth: authUser, state: state.exists ? serialize(state.data()) : null };
  }

  if (reason.length < 3) throw new ModerationError('invalid-argument', 'Escreva o motivo (fica no histórico).');
  if (uid === caller.uid) throw new ModerationError('failed-precondition', 'Você não pode moderar a própria conta.');
  if (await roleOf(db, uid)) {
    throw new ModerationError('failed-precondition', 'Esta conta é da equipe do painel. Tire o acesso dela antes.');
  }

  const stateRef = db.doc(`${STATE}/${uid}`);
  const details = {};
  let state = null;

  switch (action) {
    case 'warn': {
      const message = String(input.message || '').trim().slice(0, 300);
      if (message.length < 5) throw new ModerationError('invalid-argument', 'Escreva a mensagem do aviso.');
      details.message = message;
      const token = await fcmTokenOf(db, uid);
      if (token) {
        try {
          await messaging.send({
            token,
            notification: { title: 'Aviso da equipe STWAY', body: message },
            data: { type: 'moderation_warning' },
          });
          details.pushed = true;
        } catch (e) {
          details.pushed = false;
          details.pushError = e.code || e.message;
        }
      } else {
        details.pushed = false;
        details.pushError = 'sem token de push';
      }
      await stateRef.set({ warnings: FieldValue.increment(1) }, { merge: true });
      break;
    }

    case 'rename': {
      const name = neutralName(uid);
      details.name = name;
      await db.doc(`users/${uid}`).set({ userName: name }, { merge: true });
      details.rankings = await updateExisting(db, await rankingRefs(db, uid), { name });
      details.rooms = await updateExisting(db, await roomMemberRefs(db, uid), { name });
      details.companions = await renameInCompanions(db, uid, name);
      await stateRef.set({ nameLocked: name }, { merge: true });
      break;
    }

    case 'removePhoto': {
      await db.doc(`users/${uid}`).set({ photoUrl: FieldValue.delete() }, { merge: true });
      details.rankings = await updateExisting(db, await rankingRefs(db, uid), { photoUrl: FieldValue.delete() });
      try {
        await auth.updateUser(uid, { photoURL: null });
      } catch (e) {
        details.authError = e.code || e.message;
      }
      await stateRef.set({ photoRemoved: true }, { merge: true });
      break;
    }

    case 'suspend': {
      const days = Number(input.days);
      if (!SUSPEND_DAYS.has(days)) throw new ModerationError('invalid-argument', 'Prazo inválido.');
      const until = Timestamp.fromMillis(Date.now() + days * 86_400_000);
      await auth.updateUser(uid, { disabled: true });
      await auth.revokeRefreshTokens(uid);
      details.days = days;
      state = { state: 'suspended', until };
      break;
    }

    case 'ban': {
      await auth.updateUser(uid, { disabled: true });
      await auth.revokeRefreshTokens(uid);
      state = { state: 'banned', until: null };
      break;
    }

    case 'reactivate': {
      await auth.updateUser(uid, { disabled: false });
      state = { state: 'active', until: null };
      break;
    }

    default:
      break;
  }

  const at = FieldValue.serverTimestamp();
  await stateRef.set(
    { ...(state || {}), lastAction: action, lastReason: reason, updatedAt: at },
    { merge: true },
  );
  await db.collection(LOG).add({
    uid,
    action,
    reason,
    details,
    by: caller.uid,
    byEmail: caller.email || null,
    reportId: input.reportId || null,
    at,
  });

  // A denúncia que motivou a ação sai da fila.
  if (input.reportId) {
    try {
      await db.doc(`user_reports/${input.reportId}`).update({ status: 'actioned', reviewedAt: Timestamp.now() });
    } catch (e) {
      details.reportError = e.message;
    }
  }

  logger.info('moderação', { uid, action, by: caller.uid });
  return { ok: true, details };
}

/** Suspensões vencidas voltam sozinhas. */
async function liftExpired({ db, auth, logger }) {
  const now = Timestamp.now();
  const snap = await db.collection(STATE).where('until', '<=', now).get();
  let lifted = 0;
  for (const d of snap.docs) {
    if (d.get('state') !== 'suspended') continue;
    try {
      await auth.updateUser(d.id, { disabled: false });
    } catch (e) {
      if (e.code !== 'auth/user-not-found') {
        logger.error('moderação: falha ao reativar', { uid: d.id, error: e.message });
        continue;
      }
    }
    await d.ref.set({ state: 'active', until: null, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    await db.collection(LOG).add({
      uid: d.id,
      action: 'autoReactivate',
      reason: 'Fim da suspensão',
      details: {},
      by: 'sistema',
      at: FieldValue.serverTimestamp(),
    });
    lifted += 1;
  }
  return lifted;
}

/** Timestamps viram ISO para o cliente (só o nível de cima; o doc é raso). */
function serialize(obj) {
  return Object.fromEntries(
    Object.entries(obj || {}).map(([k, v]) => [k, v && typeof v.toDate === 'function' ? v.toDate().toISOString() : v]),
  );
}

module.exports = { moderate, liftExpired, ModerationError, neutralName };
