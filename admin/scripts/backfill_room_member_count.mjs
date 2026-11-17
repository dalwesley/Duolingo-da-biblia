#!/usr/bin/env node
/**
 * Grava `rooms/{code}.memberCount` nos grupos que ainda não têm (ou têm
 * errado). Depois do deploy, as functions onRoomMemberCreate/Delete mantêm
 * a contagem; as rules usam o campo para exigir 3 pessoas antes de
 * propósito, estudo, leitura e fechamento da semana. Sala sem o campo passa
 * nas rules até este backfill rodar.
 *
 *   node scripts/backfill_room_member_count.mjs           # dry-run
 *   node scripts/backfill_room_member_count.mjs --apply
 *
 * Usa a sessão do Firebase CLI.
 */
import { createRequire } from 'module';
import { Firestore } from '@google-cloud/firestore';

const require = createRequire(import.meta.url);
const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');

const PROJECT_ID = process.env.PROJECT_ID || 'trilha-biblia';
const APPLY = process.argv.includes('--apply');

async function getDb() {
  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    throw new Error('Firebase CLI não logado. Rode: firebase login --reauth');
  }
  process.env.GOOGLE_APPLICATION_CREDENTIALS = await getCredentialPathAsync(account);
  return new Firestore({ projectId: PROJECT_ID });
}

const db = await getDb();
const rooms = await db.collection('rooms').get();
let changed = 0;
for (const room of rooms.docs) {
  const agg = await room.ref.collection('members').count().get();
  const n = agg.data().count;
  const cur = room.get('memberCount');
  if (cur === n) continue;
  changed++;
  console.log(`${room.id}: ${cur ?? '—'} → ${n}`);
  if (APPLY) await room.ref.set({ memberCount: n }, { merge: true });
}
console.log(`${rooms.size} grupos, ${changed} ${APPLY ? 'gravados' : 'a gravar (dry-run; use --apply)'}`);
