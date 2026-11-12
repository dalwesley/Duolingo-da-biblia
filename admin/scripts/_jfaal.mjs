/**
 * Acesso ao texto JFAAL (o mesmo que o palco do app mostra).
 * Referência: "Gênesis 1:1–2" (um capítulo, faixa contínua) ou "Gênesis 1:1".
 * CLI: node admin/scripts/_jfaal.mjs "Hebreus 11:3" ["Gênesis 1:1–2" ...]
 *
 * A lógica mora em `_jfaal_core.mjs` (sem `fs`), compartilhada com o painel.
 */
import { readFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { BOOK_NAMES, createJfaal, fold, parseRef, verseCount } from './_jfaal_core.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const biblePath = join(__dirname, '..', '..', 'trilha_app', 'assets', 'data', 'bible_jfaal.json');

let bible = null;
function load() {
  if (!bible) bible = JSON.parse(readFileSync(biblePath, 'utf8'));
  return bible;
}

const jf = createJfaal(load);

export { BOOK_NAMES, fold, parseRef, verseCount };
export const { passageText, chapterLength, splitRanges, versesOf } = jf;

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  for (const ref of process.argv.slice(2)) {
    const t = passageText(ref);
    console.log(`${ref}\t${t ?? '<<referência inválida>>'}`);
  }
}
