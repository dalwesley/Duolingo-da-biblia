'use strict';

const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { getAuth } = require('firebase-admin/auth');
const functions = require('firebase-functions/v1');
const { logger } = require('firebase-functions');
const { defineSecret } = require('firebase-functions/params');
const { isAllowed } = require('./content_filter');

/**
 * Token FCM do peregrino: `users/{uid}/private/data` (app novo) ou
 * `users/{uid}` (versões antigas, até o próximo save migrar).
 */
async function fcmTokenOf(db, uid) {
  const priv = await db.doc(`users/${uid}/private/data`).get();
  const token = priv.data()?.fcmToken;
  if (typeof token === 'string' && token) return token;
  const pub = await db.doc(`users/${uid}`).get();
  return pub.data()?.fcmToken;
}

initializeApp();

/**
 * Quando alguém acena na companhia, empurra o parceiro (mesmo com o app fechado).
 * 1ª geração de propósito: o 1º deploy 2ª gen trava no Eventarc Service Agent.
 */
exports.onCompanionNudge = functions.firestore
  .document('companies/{code}')
  .onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    if (!after) return;

    const fromId = (after.nudgeFromId || '').trim();
    const day = after.nudgeDay || '';
    const message = (after.nudgeMessage || '').trim();
    if (!fromId || !day) return;

    const same =
      before &&
      before.nudgeFromId === fromId &&
      before.nudgeDay === day &&
      (before.nudgeMessage || '').trim() === message;
    if (same) return;

    const hostId = after.hostId || '';
    const guestId = after.guestId || '';
    const toId = fromId === hostId ? guestId : hostId;
    if (!toId || toId === fromId) {
      logger.info('aceno sem destinatário', { code: context.params.code });
      return;
    }

    const db = getFirestore();
    // Quem bloqueou não recebe nada de quem foi bloqueado (App Store 1.2).
    const blocked = await db.doc(`users/${toId}/blocks/${fromId}`).get();
    if (blocked.exists) {
      logger.info('aceno de bloqueado, sem push', { toId });
      return;
    }

    const token = await fcmTokenOf(db, toId);
    if (!token || typeof token !== 'string') {
      logger.info('destinatário sem token FCM', { toId });
      return;
    }

    const fromName = (after.nudgeFromName || 'Companheiro')
      .trim()
      .split(/\s+/)[0];
    // Texto escrito (Peregrino+) passa pelo filtro; barrado vira o padrão.
    const fallback = 'Um aceno na trilha. Vem caminhar.';
    const body = message && isAllowed(message) ? message : fallback;

    try {
      await getMessaging().send({
        token,
        notification: {
          title: `${fromName} te animou`,
          body,
        },
        data: {
          action: 'home',
          type: 'aceno',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'trilha_habits',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      });
      logger.info('push de aceno enviado', {
        toId,
        code: context.params.code,
      });
    } catch (err) {
      logger.error('falha no push de aceno', err);
    }
  });

/**
 * Quando alguém reconhece a cena ou uma medalha, avisa quem recebeu.
 * O aviso não diz o nome: quem não é Peregrino+ vê o coração, não quem foi.
 * O corpo não usa texto livre do remetente.
 */
exports.onRecognition = functions.firestore
  .document('users/{uid}/recognitions/{recognitionId}')
  .onCreate(async (snap, context) => {
    const data = snap.data() || {};
    const toId = context.params.uid;
    const fromId = (data.fromUid || '').trim();
    if (!fromId || fromId === toId) return;

    const db = getFirestore();
    const token = await fcmTokenOf(db, toId);
    if (!token || typeof token !== 'string') {
      logger.info('reconhecimento sem token FCM', { toId });
      return;
    }

    const body = data.kind === 'medal'
      ? 'Reconheceu uma medalha sua.'
      : 'Reconheceu a sua cena.';

    try {
      await getMessaging().send({
        token,
        notification: {
          title: 'Alguém viu o seu passo',
          body,
        },
        data: {
          action: 'home',
          type: 'reconhecimento',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'trilha_habits',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      });
      logger.info('push de reconhecimento enviado', {
        toId,
        recognitionId: context.params.recognitionId,
      });
    } catch (err) {
      logger.error('falha no push de reconhecimento', err);
    }
  });

/** Mesmo teto do app (`kRoomMemberLimit`). */
const ROOM_MEMBER_LIMIT = 20;

/**
 * O app confere o teto antes de entrar, mas duas entradas ao mesmo tempo
 * passam. Aqui quem chegou depois do 20º sai da lista.
 */
/**
 * `rooms/{code}.memberCount`: quantos estão no grupo. Só o servidor grava;
 * as rules usam para exigir 3 pessoas antes de propósito, estudo, leitura
 * e fechamento da semana (o app também confere).
 */
async function syncRoomMemberCount(db, code) {
  try {
    const roomRef = db.doc(`rooms/${code}`);
    const agg = await db.collection(`rooms/${code}/members`).count().get();
    const n = agg.data().count;
    const room = await roomRef.get();
    if (!room.exists || room.get('memberCount') === n) return;
    await roomRef.set({ memberCount: n }, { merge: true });
  } catch (e) {
    logger.warn('grupo: não contei os membros', { code, error: e.message });
  }
}

exports.onRoomMemberDelete = functions.firestore
  .document('rooms/{code}/members/{uid}')
  .onDelete(async (_snap, context) => {
    await syncRoomMemberCount(getFirestore(), context.params.code);
  });

exports.onRoomMemberCreate = functions.firestore
  .document('rooms/{code}/members/{uid}')
  .onCreate(async (snap, context) => {
    const { code } = context.params;
    try {
      await roomMemberJoined(snap, context);
    } finally {
      await syncRoomMemberCount(getFirestore(), code);
    }
  });

async function roomMemberJoined(snap, context) {
    const { code, uid } = context.params;
    const db = getFirestore();
    const room = await db.doc(`rooms/${code}`).get();
    if (!room.exists) return;
    if (room.data()?.ownerId === uid) return;

    const members = await db.collection(`rooms/${code}/members`).get();
    if (members.size <= ROOM_MEMBER_LIMIT) {
      await attributeReferral(db, {
        inviteeUid: uid,
        inviterUid: room.data()?.ownerId,
        via: 'grupo',
        code,
      });
      return;
    }

    // Nem todo doc tem joinedAt (o save de progresso grava sem ele).
    const ownerId = room.data()?.ownerId;
    const byArrival = members.docs
      .filter((d) => d.id !== ownerId)
      .sort((a, b) => a.createTime.toMillis() - b.createTime.toMillis());
    const allowed = new Set(
      byArrival.slice(0, ROOM_MEMBER_LIMIT - 1).map((d) => d.id),
    );
    if (allowed.has(uid)) {
      await attributeReferral(db, { inviteeUid: uid, inviterUid: ownerId, via: 'grupo', code });
      return;
    }
    await snap.ref.delete();
    logger.info('grupo cheio, membro removido', { code, uid });
}

/**
 * Alguém do grupo chamou outra pessoa para estudar.
 * O corpo não usa texto livre do remetente.
 */
exports.onRoomNudge = functions.firestore
  .document('rooms/{code}/nudges/{toId}')
  .onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data() : null;
    if (!after) return;
    const before = change.before.exists ? change.before.data() : null;
    if (before && before.day === after.day) return;

    const { toId } = context.params;
    const fromId = (after.fromId || '').trim();
    if (!fromId || fromId === toId) return;

    const db = getFirestore();
    const token = await fcmTokenOf(db, toId);
    if (!token || typeof token !== 'string') {
      logger.info('chamado do grupo sem token FCM', { toId });
      return;
    }

    const fromName = (after.fromName || 'Alguém').trim().split(/\s+/)[0] || 'Alguém';
    const roomName = clip(after.roomName || 'seu grupo', 40) || 'seu grupo';
    // Recado pronto escolhido no app (sem texto livre). App antigo não manda
    // `kind`: fica o chamado para estudar.
    const waves = {
      plan: `O propósito do grupo ${roomName} vai começar. Entra com a gente?`,
      pray: 'Estou orando por você.',
      cheer: `Força! O grupo ${roomName} está com você.`,
      miss: `Sentimos sua falta no grupo ${roomName}.`,
    };
    const wave = waves[after.kind];

    try {
      await getMessaging().send({
        token,
        notification: {
          title: wave ? `${fromName} acenou para você` : `${fromName} chamou você`,
          body: wave || `O grupo ${roomName} está estudando. Vem junto.`,
        },
        data: {
          action: 'home',
          type: 'grupo',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'trilha_habits',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      });
      logger.info('push de chamado do grupo enviado', {
        toId,
        code: context.params.code,
      });
    } catch (err) {
      logger.error('falha no push de chamado do grupo', err);
    }
  });

/**
 * Convite de companhia pelo nome (chamar alguém da Caravana). Avisa quando
 * o convite fica pendente para alguém novo — inclusive quando quem chamou
 * troca o destinatário.
 */
exports.onCompanionInvite = functions.firestore
  .document('companionInvites/{code}')
  .onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data() : null;
    if (!after || after.status !== 'pending') return;
    const before = change.before.exists ? change.before.data() : null;
    if (before && before.status === 'pending' && before.toUid === after.toUid) {
      return;
    }

    const toId = (after.toUid || '').trim();
    const fromId = (after.fromUid || '').trim();
    if (!toId || !fromId || toId === fromId) return;

    const db = getFirestore();
    const blocked = await db.doc(`users/${toId}/blocks/${fromId}`).get();
    if (blocked.exists) {
      logger.info('convite de companhia de bloqueado, sem push', { toId });
      return;
    }
    const token = await fcmTokenOf(db, toId);
    if (!token || typeof token !== 'string') {
      logger.info('convite de companhia sem token FCM', { toId });
      return;
    }

    const fromName =
      (after.fromName || 'Alguém').trim().split(/\s+/)[0] || 'Alguém';

    try {
      await getMessaging().send({
        token,
        notification: {
          title: `${fromName} te chamou`,
          body: 'Para caminhar junto na companhia. O convite está em Juntos.',
        },
        data: {
          action: 'league',
          type: 'companhia-convite',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'trilha_habits',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      });
      logger.info('push de convite de companhia enviado', {
        toId,
        code: context.params.code,
      });
    } catch (err) {
      logger.error('falha no push de convite de companhia', err);
    }
  });

/**
 * Convite de grupo dentro do app. Só avisa quando o status vira pending
 * (convite novo ou reenvio depois de uma recusa).
 */
exports.onRoomInvite = functions.firestore
  .document('roomInvites/{id}')
  .onWrite(async (change) => {
    const after = change.after.exists ? change.after.data() : null;
    if (!after || after.status !== 'pending') return;
    const before = change.before.exists ? change.before.data() : null;
    if (before && before.status === 'pending') return;

    const toId = (after.toUid || '').trim();
    const fromId = (after.fromUid || '').trim();
    if (!toId || !fromId || toId === fromId) return;

    const db = getFirestore();
    const token = await fcmTokenOf(db, toId);
    if (!token || typeof token !== 'string') {
      logger.info('convite de grupo sem token FCM', { toId });
      return;
    }

    const fromName = (after.fromName || 'Alguém').trim().split(/\s+/)[0] || 'Alguém';
    const roomName = clip(after.roomName || 'um grupo', 40) || 'um grupo';

    try {
      await getMessaging().send({
        token,
        notification: {
          title: `${fromName} te chamou`,
          body: `Entra no grupo ${roomName}. O convite está em Juntos.`,
        },
        data: {
          action: 'league',
          type: 'grupo-convite',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'trilha_habits',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      });
      logger.info('push de convite de grupo enviado', { toId, id: change.after.id });
    } catch (err) {
      logger.error('falha no push de convite de grupo', err);
    }
  });

const SITE_ORIGINS = new Set([
  'https://stway.com.br',
  'https://www.stway.com.br',
  'https://stway-app.web.app',
  'https://stway-app.firebaseapp.com',
]);

function clip(value, max) {
  if (typeof value !== 'string') return '';
  return value.replace(/\s+/g, ' ').trim().slice(0, max);
}

function validEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) && email.length <= 120;
}

function phoneDigits(value) {
  return clip(value, 30).replace(/\D/g, '');
}

/**
 * Formulários do site público (lista de espera iOS / tester e fale conosco).
 * Grava em site_inbox. O console do Firestore lê; o cliente não.
 */
exports.submitSiteForm = functions
  .region('us-central1')
  .https.onRequest(async (req, res) => {
    res.set('Cache-Control', 'no-store');
    const origin = req.get('origin');
    if (origin && !SITE_ORIGINS.has(origin)) {
      res.status(403).json({ ok: false, error: 'Origem não permitida.' });
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).json({ ok: false, error: 'Use POST.' });
      return;
    }

    const body = req.body && typeof req.body === 'object' ? req.body : {};
    if (clip(body.website, 200)) {
      res.status(200).json({ ok: true });
      return;
    }

    const kind = body.kind === 'contact' ? 'contact' : body.kind === 'tester' ? 'tester' : '';
    const name = clip(body.name, 80);
    const email = clip(body.email, 120).toLowerCase();
    const phone = clip(body.phone, 30);
    const platform = clip(body.platform, 12);
    const subject = clip(body.subject, 120);
    const message = clip(body.message, 1500);
    const consent = body.consent === 'sim' || body.consent === true;

    if (!kind) {
      res.status(400).json({ ok: false, error: 'Formulário inválido.' });
      return;
    }
    if (name.length < 2) {
      res.status(400).json({ ok: false, error: 'Escreva seu nome.' });
      return;
    }
    if (!validEmail(email)) {
      res.status(400).json({ ok: false, error: 'E-mail inválido.' });
      return;
    }
    if (!consent) {
      res.status(400).json({ ok: false, error: 'Confirme o uso dos dados para continuar.' });
      return;
    }

    if (kind === 'tester') {
      if (phoneDigits(phone).length < 10) {
        res.status(400).json({ ok: false, error: 'Informe um celular com DDD.' });
        return;
      }
      if (!['android', 'ios', 'both'].includes(platform)) {
        res.status(400).json({ ok: false, error: 'Escolha o aparelho.' });
        return;
      }
    } else if (message.length < 8) {
      res.status(400).json({ ok: false, error: 'Escreva a mensagem.' });
      return;
    }

    const db = getFirestore();
    try {
      const prior = await db.collection('site_inbox').where('email', '==', email).limit(10).get();
      const dayAgo = Date.now() - 24 * 60 * 60 * 1000;
      const recent = prior.docs.filter((doc) => {
        const created = doc.get('createdAt');
        return created && typeof created.toMillis === 'function' && created.toMillis() > dayAgo;
      });
      if (recent.length >= 5) {
        res.status(429).json({
          ok: false,
          error: 'Este e-mail já enviou várias mensagens hoje. Tente amanhã.',
        });
        return;
      }

      await db.collection('site_inbox').add({
        kind,
        name,
        email,
        phone: kind === 'tester' ? phone : '',
        platform: kind === 'tester' ? platform : '',
        subject: kind === 'contact' ? subject : '',
        message,
        status: 'new',
        source: 'stway-app',
        createdAt: FieldValue.serverTimestamp(),
      });
      res.status(200).json({ ok: true });
    } catch (err) {
      logger.error('falha no formulário do site', err);
      res.status(500).json({ ok: false, error: 'Não foi possível enviar. Tente de novo em instantes.' });
    }
  });

// ---- Peregrino+: webhook do RevenueCat (ver revenuecat.js) ---------------

const revenueCat = require('./revenuecat');
const insights = require('./admin_insights');

// Mesmo valor do "Authorization header" do webhook no RevenueCat.
// `firebase functions:secrets:set REVENUECAT_WEBHOOK_AUTH`. O
// `functions.config()` antigo foi removido no firebase-functions v7 e
// derrubava toda chamada com 500.
const revenueCatWebhookAuth = defineSecret('REVENUECAT_WEBHOOK_AUTH');

const referral = require('./referral');

// Chave secreta (sk_...) da API REST do RevenueCat: concede o mês
// promocional. `firebase functions:secrets:set REVENUECAT_SECRET_KEY`.
const revenueCatSecretKey = defineSecret('REVENUECAT_SECRET_KEY');

/**
 * Grava `users/{uid}.plus*` (e o selo, no apoio avulso) a partir do
 * RevenueCat. Sem o segredo configurado, 503 — nunca grava sem conferir.
 */
exports.revenueCatWebhook = functions
  .runWith({ secrets: [revenueCatWebhookAuth, revenueCatSecretKey] })
  .region('us-central1')
  .https.onRequest(async (req, res) => {
    res.set('Cache-Control', 'no-store');
    const secret = revenueCatWebhookAuth.value() || '';
    if (!secret) {
      res.status(503).json({ ok: false, error: 'Webhook não configurado.' });
      return;
    }
    if (req.method !== 'POST') {
      res.status(405).json({ ok: false, error: 'Use POST.' });
      return;
    }
    // Carimbo para o painel (Hoje › Webhook): nunca derruba a entrega.
    const stamp = (outcome, event, error) =>
      insights.recordWebhook(getFirestore(), { outcome, event, error }).catch((e) =>
        logger.warn('revenuecat: carimbo falhou', { error: e.message }),
      );
    if (!revenueCat.authorized(req.get('authorization'), secret)) {
      await stamp('unauthorized');
      res.status(401).json({ ok: false, error: 'Não autorizado.' });
      return;
    }
    const event = req.body && req.body.event;
    try {
      const out = await revenueCat.applyEvent(getFirestore(), event, {
        rc: referralRc(),
        // Teste com compra de mentira: ligue só enquanto testa.
        allowSandbox: process.env.REVENUECAT_ALLOW_SANDBOX === '1',
      });
      await referralFromEvent(getFirestore(), event);
      await stamp(out ? 'ok' : 'ignored', event);
      if (!out) {
        // Evento que não muda o Plus nem ocupa vaga de Pioneiro.
        res.status(200).json({ ok: true, ignored: true });
        return;
      }
      logger.info('revenuecat: estado gravado', {
        uid: out.uid,
        type: event && event.type,
        pioneer: out.pioneer,
        skipped: out.skipped,
      });
      res.status(200).json({ ok: true });
    } catch (err) {
      logger.error('revenuecat: falha ao gravar', err);
      await stamp('error', event, err && err.message);
      res.status(500).json({ ok: false, error: 'Falha ao gravar.' });
    }
  });

// ---- Convite que vira assinatura (ver referral.js) --------------------------

/** Atribuição nunca derruba o trigger que a chama. */
async function attributeReferral(db, input) {
  try {
    const saved = await referral.attribute(db, input);
    if (saved) logger.info('indicação: convite atribuído', input);
  } catch (e) {
    logger.error('indicação: falha ao atribuir', { ...input, error: e.message });
  }
}

function referralRc() {
  // Até a chave real entrar, o segredo pode guardar um marcador
  // ("pendente"): sem `sk_`, a indicação fica desligada (só a atribuição corre).
  const key = (revenueCatSecretKey.value() || '').trim();
  return key.startsWith('sk_') ? referral.revenueCatClient(key) : null;
}

/**
 * Depois do estado Plus gravado: 1º pagamento do convidado conta o mês
 * de quem convidou; Plus que acabou solta um mês guardado. Falha aqui
 * só loga — o webhook já gravou o principal e não deve ser reenviado.
 */
async function referralFromEvent(db, event) {
  const rc = referralRc();
  if (!rc) return;
  const allowSandbox = process.env.REFERRAL_ALLOW_SANDBOX === '1';
  try {
    const paid = referral.paidUidFromEvent(event, { allowSandbox });
    if (paid) await referral.rewardInviter(db, rc, paid, logger);
    const expired = referral.expiredUidFromEvent(event);
    if (expired) await referral.releaseBanked(db, rc, expired, logger);
  } catch (e) {
    logger.error('indicação: falha no webhook', { error: e.message });
  }
}

/** Companhia aceita pelo link: quem entra de convidado foi chamado pelo host. */
exports.onCompanionJoinReferral = functions.firestore
  .document('companies/{code}')
  .onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    const guest = (after && after.guestId) || '';
    if (!guest || (before && before.guestId === guest)) return;
    await attributeReferral(getFirestore(), {
      inviteeUid: guest,
      inviterUid: after.hostId,
      via: 'companhia',
      code: context.params.code,
    });
  });

/** Passe de trilha resgatado: quem recebeu foi chamado por quem deu. */
exports.onTrailGiftReferral = functions.firestore
  .document('trailGifts/{code}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {};
    const after = change.after.data() || {};
    if (!after.toUid || before.toUid) return;
    const db = getFirestore();
    await attributeReferral(db, {
      inviteeUid: after.toUid,
      inviterUid: after.fromUid,
      via: 'passe',
      code: context.params.code,
    });
    await notifyTrailGiftRedeemed(db, after, context.params.code);
  });

/**
 * Avisa quem deu que o passe foi recebido: fecha o ciclo do presente.
 * Falha de push não desfaz nada (o resgate já está gravado).
 */
async function notifyTrailGiftRedeemed(db, gift, code) {
  const fromUid = gift.fromUid || '';
  const toUid = gift.toUid || '';
  if (!fromUid || !toUid || fromUid === toUid) return;
  try {
    const blocked = await db.doc(`users/${fromUid}/blocks/${toUid}`).get();
    if (blocked.exists) return;
    const token = await fcmTokenOf(db, fromUid);
    if (!token || typeof token !== 'string') return;
    let trailTitle = '';
    const slug = gift.trailSlug || '';
    if (slug) {
      const trail = await db.doc(`content_trails/${slug}`).get();
      const title = trail.data()?.title;
      if (typeof title === 'string') trailTitle = title.trim();
    }
    const name = String(gift.toName || '').trim().split(/\s+/)[0] || 'Alguém';
    const body = trailTitle
      ? `Sua assinatura liberou ${trailTitle} inteira para essa pessoa.`
      : 'Sua assinatura liberou uma trilha inteira para essa pessoa.';
    await getMessaging().send({
      token,
      notification: { title: `${name} recebeu seu passe de trilha 🎁`, body },
      data: { action: 'home', type: 'passe' },
      android: {
        priority: 'high',
        notification: { channelId: 'trilha_habits', sound: 'default' },
      },
      apns: { payload: { aps: { sound: 'default' } } },
    });
    logger.info('push de passe recebido enviado', { fromUid, code });
  } catch (err) {
    logger.error('falha no push de passe recebido', err);
  }
}

/** Mês guardado de quem ficou sem Plus (fim do mês dado ou da assinatura). */
exports.releaseReferralMonths = functions
  .runWith({ secrets: [revenueCatSecretKey] })
  .pubsub.schedule('every 60 minutes')
  .onRun(async () => {
    const rc = referralRc();
    if (!rc) return;
    const released = await referral.releaseAllBanked(getFirestore(), rc, logger);
    if (released) logger.info('indicação: meses guardados entregues', { released });
  });

// ---- Prêmio do Advento (ver advent.js) -------------------------------------

const advent = require('./advent');

/** Cena do Advento terminada: confere os horários e grava a prova. */
exports.onAdventSceneDone = functions
  .runWith({ secrets: [revenueCatSecretKey] })
  .firestore.document('seasonWalks/{campaign}/scenes/{id}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {};
    const after = change.after.data() || {};
    if (before.state !== 'start' || after.state !== 'done') return;
    const db = getFirestore();
    const cfg = await advent.loadConfig(db, context.params.campaign);
    if (!cfg) return;
    const uid = String(after.uid || '');
    if (!uid || context.params.id !== `${uid}_${after.day}`) return;
    try {
      const out = await advent.onSceneDone(
        db,
        cfg,
        {
          uid,
          day: after.day,
          startMs: advent.msOf(change.after.createTime),
          doneMs: advent.msOf(change.after.updateTime),
          ref: change.after.ref,
        },
        logger,
      );
      if (!out.accepted) {
        logger.info('advento: cena recusada', { uid, day: after.day, reason: out.reason });
        return;
      }
      if (out.completed) {
        await advent.evaluateAround(db, cfg, uid, {
          rc: referralRc(),
          release: referral.releaseBanked,
          logger,
        });
      }
    } catch (e) {
      logger.error('advento: falha na prova', { uid, error: e.message });
    }
  });

/**
 * De meia em meia hora durante a campanha: tira a foto do dia 1 (uma vez)
 * e recalcula quem concluiu (cobre duas conclusões ao mesmo tempo).
 */
exports.adventTick = functions
  .runWith({ secrets: [revenueCatSecretKey], timeoutSeconds: 300, memory: '512MB' })
  .pubsub.schedule('every 30 minutes')
  .onRun(async () => {
    const db = getFirestore();
    const now = Date.now();
    for (const id of Object.keys(advent.DEFAULTS)) {
      const cfg = await advent.loadConfig(db, id);
      if (!cfg) continue;
      // Até 3 dias depois do prazo (meses que ficaram na fila).
      if (now > cfg.deadlineMs + 3 * advent.DAY_MS) continue;
      try {
        await advent.takeRosterIfDue(db, cfg, now, logger);
        if (now >= cfg.rosterAtMs) {
          const delta = await advent.sweep(db, cfg, {
            rc: referralRc(),
            release: referral.releaseBanked,
            logger,
          });
          if (delta) logger.info('advento: varredura', { id, delta });
        }
      } catch (e) {
        logger.error('advento: falha na rodada', { id, error: e.message });
      }
    }
  });

// ---- Caravana: salas e fechamento semanal (league.js) — em pausa ------------
// Com a base pequena a Caravana é um ranking só, o do mês, e o nível sobe no
// app por semanas firmes. As salas semanais (`assignCohort`, `settleWeek`)
// ficam em league.js para voltar quando houver gente para encher salas.

// ---- Exclusão de conta (ver account.js) -----------------------------------

const account = require('./account');

/** Conta apagada no app (ou no Console): limpa o rastro no Firestore. */
exports.onAuthUserDelete = functions
  .runWith({ timeoutSeconds: 300, memory: '256MB' })
  .auth.user()
  .onDelete(async (user) => {
    const failed = await account.purgeUserData(getFirestore(), user.uid, logger);
    logger.info('conta: excluída', { uid: user.uid, failed });
  });

const moderation = require('./moderation');

/** Painel admin: ver e moderar uma conta (ver moderation.js). */
exports.moderateUser = functions
  .region('us-central1')
  .runWith({ secrets: [revenueCatSecretKey], timeoutSeconds: 120, memory: '256MB' })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Entre no painel.');
    }
    try {
      return await moderation.moderate(
        {
          db: getFirestore(),
          auth: getAuth(),
          messaging: getMessaging(),
          fcmTokenOf,
          logger,
          revenueCat: referralRc(),
        },
        { uid: context.auth.uid, email: context.auth.token?.email },
        data || {},
      );
    } catch (e) {
      if (e instanceof moderation.ModerationError) {
        throw new functions.https.HttpsError(e.code, e.message);
      }
      logger.error('moderação: falhou', { error: e.message, action: data?.action });
      throw new functions.https.HttpsError('internal', e.message || 'Falhou.');
    }
  });

/** Suspensão vencida: reativa o login (de hora em hora). */
exports.liftSuspensions = functions.pubsub
  .schedule('every 60 minutes')
  .onRun(async () => {
    const lifted = await moderation.liftExpired({ db: getFirestore(), auth: getAuth(), logger });
    if (lifted) logger.info('moderação: suspensões encerradas', { lifted });
    // Plus dado no painel que venceu sai do doc (selo, passe, aceno).
    await moderation.expireManualPlus({ db: getFirestore(), logger });
  });

// ---- Etapa do mês da Caravana (ver caravan.js) ----------------------------

const caravan = require('./caravan');

/** Progresso salvo: recontar as cenas do mês que mudou (meta coletiva). */
exports.onProgressScenes = functions.firestore
  .document('users/{uid}/private/{docId}')
  .onWrite(async (change, context) => {
    if (context.params.docId !== 'data') return;
    const before = change.before.exists ? change.before.data() : {};
    const after = change.after.exists ? change.after.data() : {};
    const months = caravan.changedMonths(
      before.missionCompletedOn,
      after.missionCompletedOn,
    );
    if (months.length === 0) return;
    await caravan.writeMonths(
      getFirestore(),
      context.params.uid,
      after.missionCompletedOn,
      months,
      FieldValue,
    );
  });
