'use strict';

const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const functions = require('firebase-functions/v1');
const { logger } = require('firebase-functions');

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
    const userSnap = await db.doc(`users/${toId}`).get();
    const token = userSnap.data()?.fcmToken;
    if (!token || typeof token !== 'string') {
      logger.info('destinatário sem token FCM', { toId });
      return;
    }

    const fromName = (after.nudgeFromName || 'Companheiro')
      .trim()
      .split(/\s+/)[0];
    const body = message || 'Um aceno na trilha. Vem caminhar.';

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
    const userSnap = await db.doc(`users/${toId}`).get();
    const token = userSnap.data()?.fcmToken;
    if (!token || typeof token !== 'string') {
      logger.info('reconhecimento sem token FCM', { toId });
      return;
    }

    const fromName = (data.fromName || 'Alguém').trim().split(/\s+/)[0] || 'Alguém';
    const body = data.kind === 'medal'
      ? 'Reconheceu uma medalha sua.'
      : 'Reconheceu a sua cena.';

    try {
      await getMessaging().send({
        token,
        notification: {
          title: `${fromName} viu o seu passo`,
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
 * Formulários do site público (teste fechado e fale conosco).
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
        res.status(400).json({ ok: false, error: 'Informe um WhatsApp com DDD.' });
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
