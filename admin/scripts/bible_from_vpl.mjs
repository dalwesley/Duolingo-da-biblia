#!/usr/bin/env node
// Converte um arquivo VPL do eBible.org (ex.: engbsb_vpl.txt) para o formato
// de Bíblia offline do app: [{abbrev, name, chapters: [[verso, ...], ...]}].
//
// Uso:
//   node admin/scripts/bible_from_vpl.mjs <arquivo_vpl.txt> <en|es> <saida.json>
//
// A ordem dos 66 livros é a mesma da JFAAL. `abbrev` continua a sigla PT
// (é chave de progresso: capítulos lidos, marcadores, notas); a sigla do
// idioma vai em `short`, só para exibir.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const ptBooks = JSON.parse(
  fs.readFileSync(
    path.join(here, '../../trilha_app/assets/data/bible_jfaal.json'),
    'utf8',
  ),
);

const CODES = [
  'GEN', 'EXO', 'LEV', 'NUM', 'DEU', 'JOS', 'JDG', 'RUT', '1SA', '2SA', '1KI',
  '2KI', '1CH', '2CH', 'EZR', 'NEH', 'EST', 'JOB', 'PSA', 'PRO', 'ECC', 'SOL',
  'ISA', 'JER', 'LAM', 'EZE', 'DAN', 'HOS', 'JOE', 'AMO', 'OBA', 'JON', 'MIC',
  'NAH', 'HAB', 'ZEP', 'HAG', 'ZEC', 'MAL', 'MAT', 'MAR', 'LUK', 'JOH', 'ACT',
  'ROM', '1CO', '2CO', 'GAL', 'EPH', 'PHI', 'COL', '1TH', '2TH', '1TI', '2TI',
  'TIT', 'PHM', 'HEB', 'JAM', '1PE', '2PE', '1JO', '2JO', '3JO', 'JUD', 'REV',
];

const NAMES = {
  en: [
    ['Gn', 'Genesis'], ['Ex', 'Exodus'], ['Lv', 'Leviticus'], ['Nm', 'Numbers'],
    ['Dt', 'Deuteronomy'], ['Jos', 'Joshua'], ['Jdg', 'Judges'], ['Ru', 'Ruth'],
    ['1Sm', '1 Samuel'], ['2Sm', '2 Samuel'], ['1Kgs', '1 Kings'],
    ['2Kgs', '2 Kings'], ['1Chr', '1 Chronicles'], ['2Chr', '2 Chronicles'],
    ['Ezr', 'Ezra'], ['Neh', 'Nehemiah'], ['Est', 'Esther'], ['Jb', 'Job'],
    ['Ps', 'Psalms'], ['Prv', 'Proverbs'], ['Eccl', 'Ecclesiastes'],
    ['Sg', 'Song of Songs'], ['Is', 'Isaiah'], ['Jer', 'Jeremiah'],
    ['Lam', 'Lamentations'], ['Ez', 'Ezekiel'], ['Dn', 'Daniel'],
    ['Hos', 'Hosea'], ['Jl', 'Joel'], ['Am', 'Amos'], ['Ob', 'Obadiah'],
    ['Jon', 'Jonah'], ['Mi', 'Micah'], ['Na', 'Nahum'], ['Hb', 'Habakkuk'],
    ['Zep', 'Zephaniah'], ['Hg', 'Haggai'], ['Zec', 'Zechariah'],
    ['Mal', 'Malachi'], ['Mt', 'Matthew'], ['Mk', 'Mark'], ['Lk', 'Luke'],
    ['Jn', 'John'], ['Acts', 'Acts'], ['Rom', 'Romans'],
    ['1Cor', '1 Corinthians'], ['2Cor', '2 Corinthians'], ['Gal', 'Galatians'],
    ['Eph', 'Ephesians'], ['Phil', 'Philippians'], ['Col', 'Colossians'],
    ['1Thes', '1 Thessalonians'], ['2Thes', '2 Thessalonians'],
    ['1Tm', '1 Timothy'], ['2Tm', '2 Timothy'], ['Ti', 'Titus'],
    ['Phlm', 'Philemon'], ['Heb', 'Hebrews'], ['Jas', 'James'],
    ['1Pt', '1 Peter'], ['2Pt', '2 Peter'], ['1Jn', '1 John'],
    ['2Jn', '2 John'], ['3Jn', '3 John'], ['Jude', 'Jude'],
    ['Rv', 'Revelation'],
  ],
  es: [
    ['Gn', 'Génesis'], ['Éx', 'Éxodo'], ['Lv', 'Levítico'], ['Nm', 'Números'],
    ['Dt', 'Deuteronomio'], ['Jos', 'Josué'], ['Jue', 'Jueces'], ['Rt', 'Rut'],
    ['1S', '1 Samuel'], ['2S', '2 Samuel'], ['1R', '1 Reyes'],
    ['2R', '2 Reyes'], ['1Cr', '1 Crónicas'], ['2Cr', '2 Crónicas'],
    ['Esd', 'Esdras'], ['Neh', 'Nehemías'], ['Est', 'Ester'], ['Job', 'Job'],
    ['Sal', 'Salmos'], ['Pr', 'Proverbios'], ['Ec', 'Eclesiastés'],
    ['Cnt', 'Cantares'], ['Is', 'Isaías'], ['Jer', 'Jeremías'],
    ['Lm', 'Lamentaciones'], ['Ez', 'Ezequiel'], ['Dn', 'Daniel'],
    ['Os', 'Oseas'], ['Jl', 'Joel'], ['Am', 'Amós'], ['Abd', 'Abdías'],
    ['Jon', 'Jonás'], ['Mi', 'Miqueas'], ['Nah', 'Nahúm'], ['Hab', 'Habacuc'],
    ['Sof', 'Sofonías'], ['Hag', 'Hageo'], ['Zac', 'Zacarías'],
    ['Mal', 'Malaquías'], ['Mt', 'Mateo'], ['Mr', 'Marcos'], ['Lc', 'Lucas'],
    ['Jn', 'Juan'], ['Hch', 'Hechos'], ['Ro', 'Romanos'],
    ['1Co', '1 Corintios'], ['2Co', '2 Corintios'], ['Gá', 'Gálatas'],
    ['Ef', 'Efesios'], ['Fil', 'Filipenses'], ['Col', 'Colosenses'],
    ['1Ts', '1 Tesalonicenses'], ['2Ts', '2 Tesalonicenses'],
    ['1Ti', '1 Timoteo'], ['2Ti', '2 Timoteo'], ['Tit', 'Tito'],
    ['Flm', 'Filemón'], ['He', 'Hebreos'], ['Stg', 'Santiago'],
    ['1P', '1 Pedro'], ['2P', '2 Pedro'], ['1Jn', '1 Juan'],
    ['2Jn', '2 Juan'], ['3Jn', '3 Juan'], ['Jud', 'Judas'],
    ['Ap', 'Apocalipsis'],
  ],
};

const [src, lang, out] = process.argv.slice(2);
if (!src || !NAMES[lang] || !out) {
  console.error('uso: bible_from_vpl.mjs <vpl.txt> <en|es> <saida.json>');
  process.exit(1);
}

const books = CODES.map((_, i) => ({
  abbrev: ptBooks[i].abbrev,
  short: NAMES[lang][i][0],
  name: NAMES[lang][i][1],
  chapters: [],
}));
const index = new Map(CODES.map((c, i) => [c, i]));
const line = /^(\S+) (\d+):(\d+) (.*)$/;

for (const raw of fs.readFileSync(src, 'utf8').split(/\r?\n/)) {
  if (!raw.trim()) continue;
  const m = line.exec(raw);
  if (!m) throw new Error(`linha inválida: ${raw.slice(0, 80)}`);
  const bi = index.get(m[1]);
  if (bi === undefined) continue; // deuterocanônicos, se houver
  const ch = Number(m[2]);
  const v = Number(m[3]);
  const chapters = books[bi].chapters;
  while (chapters.length < ch) chapters.push([]);
  const verses = chapters[ch - 1];
  // Versículo omitido pela tradução: fica vazio para manter a numeração.
  while (verses.length < v - 1) verses.push('');
  verses[v - 1] = m[4].replace(/\s+/g, ' ').trim();
}

for (const b of books) {
  if (!b.chapters.length) throw new Error(`livro sem texto: ${b.name}`);
}
fs.writeFileSync(out, JSON.stringify(books));
const verses = books.reduce(
  (n, b) => n + b.chapters.reduce((m, c) => m + c.length, 0),
  0,
);
console.log(`${out}: ${books.length} livros, ${verses} versículos`);
