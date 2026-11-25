// Copia os blocos de site/_partials/*.html para as páginas que os usam.
// Na página: <!-- @partial nome --> ... <!-- @end nome -->. Tudo entre os
// marcadores é substituído pelo conteúdo de _partials/nome.html (indentado
// como o marcador). Roda sozinho no predeploy do hosting (firebase.json).
import { readFileSync, writeFileSync, readdirSync, statSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const site = join(dirname(fileURLToPath(import.meta.url)), '..');
const partialsDir = join(site, '_partials');

function pages(dir) {
  return readdirSync(dir).flatMap((name) => {
    if (name.startsWith('_') || name.startsWith('.') || name === 'node_modules') return [];
    const p = join(dir, name);
    if (statSync(p).isDirectory()) return pages(p);
    return name.endsWith('.html') ? [p] : [];
  });
}

const re = /^([ \t]*)<!-- @partial ([\w-]+) -->\n[\s\S]*?^[ \t]*<!-- @end \2 -->/gm;
let changed = 0;
for (const file of pages(site)) {
  const html = readFileSync(file, 'utf8');
  const out = html.replace(re, (_, indent, name) => {
    const src = readFileSync(join(partialsDir, `${name}.html`), 'utf8')
      .replace(/^<!--[\s\S]*?-->\n/, '') // comentário de cabeçalho do partial
      .replace(/\n+$/, '');
    const body = src.split('\n').map((l) => (l ? indent + l : l)).join('\n');
    return `${indent}<!-- @partial ${name} -->\n${body}\n${indent}<!-- @end ${name} -->`;
  });
  if (out !== html) {
    writeFileSync(file, out);
    changed++;
    console.log('partials:', file.slice(site.length + 1));
  }
}
console.log(`partials: ${changed} página(s) atualizada(s)`);
