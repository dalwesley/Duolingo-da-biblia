import {
  collection,
  deleteDoc,
  deleteField,
  doc,
  getCountFromServer,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  setDoc,
  Timestamp,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';
import { auth, db } from './firebase.js';

export const COL = {
  trails: 'content_trails',
  cards: 'content_cards',
  shelves: 'content_shelves',
  bank: 'content_bank_questions',
  difficulties: 'content_difficulties',
  studies: 'content_mission_studies',
  meta: 'content_meta',
  reports: 'content_question_reports',
  appReports: 'app_reports',
  suggestions: 'content_trail_suggestions',
  authorSuggestions: 'content_author_suggestions',
  userReports: 'user_reports',
  users: 'users',
  trailGifts: 'trailGifts',
  stats: 'stats',
};

/**
 * Perguntas e estudos têm fonte local (admin/v3/<trilha>/cenas). Toda edição
 * feita aqui fica marcada com `panelEditedAt` para `npm run v3:pull` trazer de
 * volta antes do próximo `v3:publish` — que substitui o documento inteiro.
 */
const TRACKED = new Set([COL.bank, COL.studies]);
export const PANEL_DELETES_DOC = 'panel_deletes';

function editor() {
  const u = auth.currentUser;
  return u?.email || u?.uid || 'painel';
}

function sortByOrder(items) {
  return [...items].sort((a, b) => (Number(a.order) || 0) - (Number(b.order) || 0));
}

/** Todos os docs da coleção, sem orderBy (use quando o campo de ordem não existe em todos). */
export async function listDocs(colId) {
  const snap = await getDocs(collection(db, colId));
  return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
}

export async function listCollection(colId, orderField = 'order') {
  try {
    const q = query(collection(db, colId), orderBy(orderField, 'asc'));
    const snap = await getDocs(q);
    return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
  } catch {
    return listDocs(colId).then(sortByOrder);
  }
}

/** Documentos com `field == value` (ex.: perguntas de uma trilha). */
export async function listWhere(colId, field, value, max = 0) {
  const parts = [collection(db, colId), where(field, '==', value)];
  if (max) parts.push(limit(max));
  const snap = await getDocs(query(...parts));
  return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
}

/** Perguntas e estudos editados no painel que ainda não voltaram para os arquivos locais. */
export async function listPanelEdits(colId) {
  const snap = await getDocs(
    query(collection(db, colId), where('panelEditedAt', '>', Timestamp.fromMillis(0))),
  );
  return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
}

export async function countCollection(colId) {
  try {
    const snap = await getCountFromServer(collection(db, colId));
    return snap.data().count;
  } catch {
    const snap = await getDocs(collection(db, colId));
    return snap.size;
  }
}

export async function countWhere(colId, field, value) {
  const snap = await getCountFromServer(query(collection(db, colId), where(field, '==', value)));
  return snap.data().count;
}

export async function getDocById(colId, docId) {
  const snap = await getDoc(doc(db, colId, docId));
  if (!snap.exists()) return null;
  return { id: snap.id, ...snap.data() };
}

/**
 * Grava com merge. `remove` apaga campos (ex.: `template` quando o gesto deixa
 * de ser Completar). `bump: false` deixa para quem chama subir o catálogo uma
 * vez só no fim de um lote.
 */
export async function saveDoc(colId, docId, data, { bump = true, remove = [] } = {}) {
  const payload = { ...data, updatedAt: Timestamp.now() };
  delete payload.id;
  if (TRACKED.has(colId)) {
    payload.panelEditedAt = Timestamp.now();
    payload.panelEditedBy = editor();
  }
  for (const key of remove) payload[key] = deleteField();
  await setDoc(doc(db, colId, docId), payload, { merge: true });
  if (bump) await bumpCatalogVersion();
  return docId;
}

/**
 * Exclui. Pergunta excluída vai para a lixeira (`content_meta/panel_trash`,
 * cópia inteira, restaurável por TRASH_DAYS dias) e fica anotada para o
 * `v3:pull` tirar também do arquivo local.
 */
export async function removeDoc(colId, docId, { info = {} } = {}) {
  if (colId === COL.bank) {
    const snap = await getDoc(doc(db, colId, docId));
    if (snap.exists()) {
      const data = snap.data();
      await setDoc(
        doc(db, COL.meta, PANEL_TRASH_DOC),
        {
          [docId]: {
            data,
            trail: data.trail || info.trail || '',
            section: data.section || info.section || '',
            at: Timestamp.now(),
            by: editor(),
          },
        },
        { merge: true },
      );
    }
  }
  await deleteDoc(doc(db, colId, docId));
  if (colId === COL.bank) {
    await setDoc(
      doc(db, COL.meta, PANEL_DELETES_DOC),
      { [docId]: { ...info, at: Timestamp.now(), by: editor() } },
      { merge: true },
    );
  }
  await bumpCatalogVersion();
}

/* ─── Lixeira de perguntas ───────────────────────────────── */

export const PANEL_TRASH_DOC = 'panel_trash';
export const TRASH_DAYS = 30;

/** [{ id, data, trail, section, at, by, daysLeft }], mais recentes primeiro. */
export async function listTrash() {
  const snap = await getDoc(doc(db, COL.meta, PANEL_TRASH_DOC));
  const raw = snap.exists() ? snap.data() : {};
  const now = Date.now();
  return Object.entries(raw)
    .filter(([, v]) => v && typeof v === 'object' && v.data)
    .map(([id, v]) => {
      const at = toDate(v.at)?.getTime() || now;
      const daysLeft = Math.max(0, TRASH_DAYS - Math.floor((now - at) / 86_400_000));
      return { id, ...v, daysLeft };
    })
    .sort((a, b) => (toDate(b.at)?.getTime() || 0) - (toDate(a.at)?.getTime() || 0));
}

/** Tira da lixeira o que passou de TRASH_DAYS. Devolve quantos saíram. */
export async function purgeExpiredTrash(items) {
  const expired = (items || []).filter((x) => x.daysLeft <= 0);
  if (!expired.length) return 0;
  await setDoc(
    doc(db, COL.meta, PANEL_TRASH_DOC),
    Object.fromEntries(expired.map((x) => [x.id, deleteField()])),
    { merge: true },
  );
  return expired.length;
}

/**
 * Volta a pergunta para o banco exatamente como estava. Fica marcada como
 * editada no painel: se o `v3:pull` já a tirou do arquivo local, o próximo
 * pull põe de volta.
 */
export async function restoreFromTrash(item) {
  const { updatedAt, panelEditedAt, panelEditedBy, ...data } = item.data || {};
  await setDoc(doc(db, COL.bank, item.id), {
    ...data,
    updatedAt: Timestamp.now(),
    panelEditedAt: Timestamp.now(),
    panelEditedBy: editor(),
  });
  await setDoc(doc(db, COL.meta, PANEL_TRASH_DOC), { [item.id]: deleteField() }, { merge: true });
  await setDoc(doc(db, COL.meta, PANEL_DELETES_DOC), { [item.id]: deleteField() }, { merge: true });
  await bumpCatalogVersion();
  return { id: item.id, ...data, panelEditedAt: new Date() };
}

/** Exclui de vez (só da lixeira; o banco já não tem a pergunta). */
export async function purgeFromTrash(id) {
  await setDoc(doc(db, COL.meta, PANEL_TRASH_DOC), { [id]: deleteField() }, { merge: true });
}

export async function updateDocField(colId, docId, field, value) {
  await updateDoc(doc(db, colId, docId), { [field]: value, updatedAt: Timestamp.now() });
  await bumpCatalogVersion();
}

export async function bumpCatalogVersion() {
  const ref = doc(db, COL.meta, 'catalog');
  const snap = await getDoc(ref);
  const version = (snap.exists() ? Number(snap.data().version) || 0 : 0) + 1;
  await setDoc(
    ref,
    { version, updatedAt: Timestamp.now() },
    { merge: true },
  );
  return version;
}

export async function getCatalogMeta() {
  return getDocById(COL.meta, 'catalog');
}

export async function getAppRelease() {
  return getDocById(COL.meta, 'app_release');
}

/** Publica versão do app nas lojas (sem bump do catálogo de conteúdo). */
export async function saveAppRelease(data) {
  const payload = {
    enabled: data.enabled !== false,
    latestVersion: String(data.latestVersion || '').trim(),
    latestBuild: Number(data.latestBuild) || 0,
    minBuild: Number(data.minBuild) || 0,
    androidStoreUrl: String(data.androidStoreUrl || '').trim(),
    iosStoreUrl: String(data.iosStoreUrl || '').trim(),
    message: String(data.message || '').trim(),
    updatedAt: Timestamp.now(),
  };
  await setDoc(doc(db, COL.meta, 'app_release'), payload, { merge: true });
  return payload;
}

/** Grava em lotes de até 400 (limite Firestore ~500). */
export async function batchSet(colId, items, idKey = 'id') {
  const chunkSize = 400;
  for (let i = 0; i < items.length; i += chunkSize) {
    const batch = writeBatch(db);
    const slice = items.slice(i, i + chunkSize);
    for (const item of slice) {
      const id = String(item[idKey] || item.slug || item.id);
      const { id: _drop, ...data } = item;
      batch.set(doc(db, colId, id), { ...data, updatedAt: Timestamp.now() }, { merge: true });
    }
    await batch.commit();
  }
  await bumpCatalogVersion();
}

export function realmLabel(id) {
  return {
    'antigo-testamento': 'Antigo Testamento',
    'novo-testamento': 'Novo Testamento',
    'vida-crista': 'Vida Cristã',
    teologia: 'Teologia',
  }[id] || id || '—';
}

export function toDate(value) {
  if (!value) return null;
  if (typeof value.toDate === 'function') return value.toDate();
  const d = new Date(value);
  return Number.isNaN(d.getTime()) ? null : d;
}

export function formatDate(value, { time = true } = {}) {
  const d = toDate(value);
  if (!d) return '—';
  return time ? d.toLocaleString('pt-BR') : d.toLocaleDateString('pt-BR');
}
