/**
 * Edições feitas no painel admin (perguntas e estudos com `panelEditedAt`,
 * exclusões em `content_meta/panel_deletes`) comparadas com os arquivos locais
 * da trilha. Usado por `v3_pull_edits.mjs` e pela trava do `publish_pilot_v3.mjs`.
 */
import { existsSync, readdirSync, readFileSync } from 'fs';
import { join } from 'path';

/** Campos que só existem no Firestore: não entram na comparação nem no arquivo. */
export const META_KEYS = new Set(['id', 'updatedAt', 'panelEditedAt', 'panelEditedBy', 'order']);

export function stripMeta(doc) {
  return Object.fromEntries(Object.entries(doc || {}).filter(([k]) => !META_KEYS.has(k)));
}

function stable(value) {
  if (Array.isArray(value)) return value.map(stable);
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.keys(value).sort().map((k) => [k, stable(value[k])]));
  }
  return value;
}

export function sameDoc(a, b) {
  return JSON.stringify(stable(stripMeta(a))) === JSON.stringify(stable(stripMeta(b)));
}

/** Campos que diferem: [{ key, local, remote }]. */
export function diffFields(local, remote) {
  const l = stripMeta(local);
  const r = stripMeta(remote);
  const keys = [...new Set([...Object.keys(l), ...Object.keys(r)])].sort();
  return keys
    .filter((k) => JSON.stringify(stable(l[k])) !== JSON.stringify(stable(r[k])))
    .map((k) => ({ key: k, local: l[k], remote: r[k] }));
}

/** Cenas locais da trilha: Map<slug, { path, data }>. */
export function readCenas(trailDir) {
  const dir = join(trailDir, 'cenas');
  const out = new Map();
  if (!existsSync(dir)) return out;
  for (const f of readdirSync(dir).filter((x) => x.endsWith('.json')).sort()) {
    const path = join(dir, f);
    out.set(f.replace(/\.json$/, ''), { path, data: JSON.parse(readFileSync(path, 'utf8')) });
  }
  return out;
}

export function isPanelEdited(doc) {
  return Boolean(doc && doc.panelEditedAt);
}
