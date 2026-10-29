'use strict';

/**
 * Exclusão de conta (App Store 5.1.1(v)).
 *
 * O app reautentica e chama `user.delete()`. Este módulo roda no gatilho
 * `auth.user().onDelete` e apaga tudo que o peregrino deixou no Firestore:
 * perfil, placares, grupos, companhias, convites, esquinas, passes de trilha e reconhecimentos.
 * Fica só a lápide `deletedAccounts/{uid}` (sem dado pessoal), para eventos
 * atrasados de compra não recriarem o perfil.
 *
 * Grupo com outros membros passa a liderança; companhia com parceiro promove
 * o parceiro a anfitrião — os outros não perdem o que construíram.
 */

const { FieldValue, FieldPath } = require('firebase-admin/firestore');
const { TOMBSTONES } = require('./revenuecat');

const TIERS = ['0', '1', '2', '3', '4'];

async function deleteRefs(db, refs) {
  for (let i = 0; i < refs.length; i += 400) {
    const batch = db.batch();
    refs.slice(i, i + 400).forEach((ref) => batch.delete(ref));
    await batch.commit();
  }
}

/** Placar do uid em cada semana/mês. Os docs-pai podem não existir. */
async function rankingRefs(db, uid) {
  const refs = [db.doc(`overallPlayers/${uid}`)];

  for (const week of await db.collection('leagues').listDocuments()) {
    refs.push(week.collection('players').doc(uid));
    for (const tier of TIERS) {
      refs.push(week.collection('tiers').doc(tier).collection('players').doc(uid));
    }
  }

  for (const month of await db.collection('monthlyLeagues').listDocuments()) {
    refs.push(month.collection('players').doc(uid));
  }

  for (const walk of await db.collection('seasonWalks').listDocuments()) {
    refs.push(walk.collection('walkers').doc(uid));
  }

  for (const group of await db.collection('leagueGroups').listDocuments()) {
    for (const week of await group.collection('weeks').listDocuments()) {
      refs.push(week.collection('players').doc(uid));
    }
  }

  return refs;
}

/** Sai de cada grupo; se liderava, passa a liderança ou apaga o grupo vazio. */
async function leaveRooms(db, uid) {
  const rooms = await db.collection('rooms').listDocuments();
  for (const room of rooms) {
    const member = room.collection('members').doc(uid);
    const [memberSnap, roomSnap] = await Promise.all([member.get(), room.get()]);
    const owns = roomSnap.exists && roomSnap.get('ownerId') === uid;
    if (!memberSnap.exists && !owns) continue;

    await member.delete();
    await room.collection('nudges').doc(uid).delete();
    if (!owns) continue;

    const others = await room
      .collection('members')
      .where(FieldPath.documentId(), '!=', uid)
      .limit(1)
      .get();
    if (others.empty) {
      await db.recursiveDelete(room);
    } else {
      const heir = others.docs[0];
      await room.update({
        ownerId: heir.id,
        ownerName: heir.get('name') || '',
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  }
}

/** Mesma regra de `BackendService.leaveCompanion` no app. */
async function leaveCompanions(db, uid) {
  const [hosted, guested] = await Promise.all([
    db.collection('companies').where('hostId', '==', uid).get(),
    db.collection('companies').where('guestId', '==', uid).get(),
  ]);

  for (const doc of hosted.docs) {
    const data = doc.data();
    if (data.guestId) {
      await doc.ref.set(
        {
          hostId: data.guestId,
          hostName: data.guestName || null,
          guestId: null,
          guestName: null,
          hostLastWalk: data.guestLastWalk || null,
          guestLastWalk: null,
          hostLastSeen: data.guestLastSeen || null,
          guestLastSeen: null,
          hostWeeklySteps: data.guestWeeklySteps || 0,
          guestWeeklySteps: 0,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    } else {
      await doc.ref.delete();
    }
  }

  for (const doc of guested.docs) {
    await doc.ref.set(
      {
        guestId: null,
        guestName: null,
        guestLastWalk: null,
        guestLastSeen: null,
        guestWeeklySteps: 0,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }
}

async function participantDocs(db, collection, uid) {
  const snap = await db
    .collection(collection)
    .where('participantIds', 'array-contains', uid)
    .get();
  return snap.docs.map((d) => d.ref);
}

/** Passes de trilha que o uid deu (levam o nome dele). */
async function trailGiftRefs(db, uid) {
  const snap = await db.collection('trailGifts').where('fromUid', '==', uid).get();
  return snap.docs.map((d) => d.ref);
}

/**
 * Passes que o uid recebeu: apagar deixava o `giftMonths` de quem deu
 * apontando para o nada — o app mostrava o passe como livre e o envio
 * caía na regra. Fica o passe, sai quem recebeu. `toUid` vazio continua
 * presente: a regra não deixa outra pessoa resgatar de novo.
 */
async function detachReceivedGifts(db, uid) {
  const snap = await db.collection('trailGifts').where('toUid', '==', uid).get();
  for (const doc of snap.docs) {
    await doc.ref.update({ toUid: '', toName: FieldValue.delete() });
  }
}

/** Reconhecimentos que o uid deu a outros (levam o nome dele). */
async function sentRecognitionRefs(db, uid, logger) {
  try {
    const snap = await db
      .collectionGroup('recognitions')
      .where('fromUid', '==', uid)
      .get();
    return snap.docs.map((d) => d.ref);
  } catch (e) {
    // Sem índice de grupo de coleção em fromUid a consulta falha; o resto segue.
    logger.warn('conta: reconhecimentos enviados não apagados', { uid, error: e.message });
    return [];
  }
}

/** Relatos, sugestões e denúncias guardam o uid — desliga do autor sem perder o conteúdo. */
async function detachAuthorship(db, uid) {
  for (const [name, field] of [
    ['content_question_reports', 'uid'],
    ['app_reports', 'uid'],
    ['content_trail_suggestions', 'uid'],
    ['content_author_suggestions', 'uid'],
    ['user_reports', 'reporterUid'],
  ]) {
    const snap = await db.collection(name).where(field, '==', uid).get();
    for (const doc of snap.docs) {
      if (name === 'content_author_suggestions') {
        await doc.ref.delete();
      } else if (name === 'app_reports') {
        await doc.ref.update({
          uid: FieldValue.delete(),
          email: FieldValue.delete(),
          displayName: FieldValue.delete(),
        });
      } else {
        await doc.ref.update({ [field]: FieldValue.delete() });
      }
    }
  }
}

async function purgeUserData(db, uid, logger) {
  const steps = [
    // Antes do perfil: o webhook do RevenueCat confere a lápide e não
    // recria `users/{uid}` com evento atrasado (ver revenuecat.js).
    [
      'lápide',
      () =>
        db.doc(`${TOMBSTONES}/${uid}`).set({ deletedAt: FieldValue.serverTimestamp() }),
    ],
    ['perfil', () => db.recursiveDelete(db.doc(`users/${uid}`))],
    ['placares', async () => deleteRefs(db, await rankingRefs(db, uid))],
    ['grupos', () => leaveRooms(db, uid)],
    ['companhias', () => leaveCompanions(db, uid)],
    ['convites', async () => deleteRefs(db, await participantDocs(db, 'roomInvites', uid))],
    ['esquinas', async () => deleteRefs(db, await participantDocs(db, 'corners', uid))],
    ['passes', async () => deleteRefs(db, await trailGiftRefs(db, uid))],
    ['passes recebidos', () => detachReceivedGifts(db, uid)],
    ['reconhecimentos', async () => deleteRefs(db, await sentRecognitionRefs(db, uid, logger))],
    ['autoria', () => detachAuthorship(db, uid)],
  ];

  // Uma etapa que falha não impede as outras.
  const failed = [];
  for (const [label, run] of steps) {
    try {
      await run();
    } catch (e) {
      failed.push(label);
      logger.error(`conta: falha em ${label}`, { uid, error: e.message });
    }
  }
  return failed;
}

module.exports = { purgeUserData };
