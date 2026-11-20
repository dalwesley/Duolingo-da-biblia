'use strict';

/**
 * Etapa do mês da Caravana: a meta coletiva soma as cenas de todos.
 *
 * O app grava o dia de cada cena concluída em
 * `users/{uid}/private/data.missionCompletedOn` (toda versão, inclusive as
 * antigas). Aqui o servidor conta as cenas de cada mês e grava
 * `caravanScenes/{YYYY-MM}/walkers/{uid}` = { scenes }. O app soma a
 * coleção do mês (agregação), sem estimativa e sem o cliente poder inflar.
 */

/** Cenas por mês ("YYYY-MM" → n) de um mapa slug → "YYYY-MM-DD". */
function scenesByMonth(completedOn) {
  const out = {};
  if (!completedOn || typeof completedOn !== 'object') return out;
  for (const day of Object.values(completedOn)) {
    if (typeof day !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(day)) continue;
    const month = day.slice(0, 7);
    out[month] = (out[month] || 0) + 1;
  }
  return out;
}

/** Meses cuja contagem mudou entre [before] e [after] (para gravar só eles). */
function changedMonths(before, after) {
  const a = scenesByMonth(before);
  const b = scenesByMonth(after);
  const months = new Set([...Object.keys(a), ...Object.keys(b)]);
  return [...months].filter((m) => (a[m] || 0) !== (b[m] || 0)).sort();
}

/** Grava as cenas de [uid] nos meses [months] (0 apaga a linha). */
async function writeMonths(db, uid, completedOn, months, FieldValue) {
  const counts = scenesByMonth(completedOn);
  for (const month of months) {
    const ref = db.doc(`caravanScenes/${month}/walkers/${uid}`);
    const scenes = counts[month] || 0;
    if (scenes === 0) {
      await ref.delete();
    } else {
      await ref.set({ scenes, updatedAt: FieldValue.serverTimestamp() });
    }
  }
}

module.exports = { scenesByMonth, changedMonths, writeMonths };
