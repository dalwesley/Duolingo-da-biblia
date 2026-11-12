/**
 * JFAAL no painel: baixa o mesmo `bible_jfaal.json` do app (3,8 MB, uma vez
 * por sessão) e expõe as consultas de `scripts/_jfaal_core.mjs`.
 */
import bibleUrl from '../../trilha_app/assets/data/bible_jfaal.json?url';
import { createJfaal, parseRef, verseCount } from '../scripts/_jfaal_core.mjs';

let bible = null;
let loading = null;

export function jfaalReady() {
  return bible != null;
}

/** Carrega a Bíblia; devolve as funções de consulta. */
export async function loadJfaal() {
  if (!loading) {
    loading = fetch(bibleUrl)
      .then((r) => {
        if (!r.ok) throw new Error(`JFAAL indisponível (${r.status})`);
        return r.json();
      })
      .then((data) => {
        bible = data;
        return jfaal;
      })
      .catch((e) => {
        loading = null;
        throw e;
      });
  }
  return loading;
}

export const jfaal = {
  parseRef,
  verseCount,
  ...createJfaal(() => bible || []),
};
