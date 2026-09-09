'use strict';

const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
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
