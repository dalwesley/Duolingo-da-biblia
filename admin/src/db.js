import {
  collection,
  deleteDoc,
  doc,
  getCountFromServer,
  getDoc,
  getDocs,
  orderBy,
  query,
  setDoc,
  Timestamp,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';
import { db } from './firebase.js';

export const COL = {
  trails: 'content_trails',
  bank: 'content_bank_questions',
  difficulties: 'content_difficulties',
  studies: 'content_mission_studies',
  meta: 'content_meta',
};

function sortByOrder(items) {
  return [...items].sort((a, b) => (Number(a.order) || 0) - (Number(b.order) || 0));
}

export async function listCollection(colId, orderField = 'order') {
  try {
    const q = query(collection(db, colId), orderBy(orderField, 'asc'));
    const snap = await getDocs(q);
    return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
  } catch {
    const snap = await getDocs(collection(db, colId));
    return sortByOrder(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
  }
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

export async function getDocById(colId, docId) {
  const snap = await getDoc(doc(db, colId, docId));
  if (!snap.exists()) return null;
  return { id: snap.id, ...snap.data() };
}

export async function saveDoc(colId, docId, data) {
  const payload = { ...data, updatedAt: Timestamp.now() };
  await setDoc(doc(db, colId, docId), payload, { merge: true });
  await bumpCatalogVersion();
  return docId;
}

export async function removeDoc(colId, docId) {
  await deleteDoc(doc(db, colId, docId));
  await bumpCatalogVersion();
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
