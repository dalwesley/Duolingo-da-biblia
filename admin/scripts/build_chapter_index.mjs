/**
 * Índice capítulo → cena para o Propósito do grupo: para cada livro, as
 * cenas cujo texto está em cada capítulo, com a pergunta para a vida
 * (`focusQuestion`) e a do texto (`anchorQuestion`). O app baixa só o livro
 * que o líder escolhe, em vez de todos os estudos (passam de 10 MB).
 *
 *   node scripts/build_chapter_index.mjs           # mostra a cobertura
 *   node scripts/build_chapter_index.mjs --apply   # grava content_meta/chapters_<livro>
 *
 * Fonte: `content_mission_studies` e `content_trails` no Firestore (pega as
 * correções do painel). Cena de trilha `-cap` vem primeiro no capítulo.
 * Capítulo que o plano juntou ao vizinho (`"chapters": "a–b"` no
 * `v3/<livro>-cap/plano.json`) aponta para a cena que o cobre.
 *
 * Rode de novo depois de publicar estudos novos ou mexer em trilhas.
 */
import { createRequire } from 'module';
import { existsSync, readFileSync } from 'fs';
import { join } from 'path';
import { ADMIN_DIR, APP_DATA } from './_v3_paths.mjs';

const require = createRequire(import.meta.url);
const APPLY = process.argv.includes('--apply');

/** Igual a `PlanQuestions.normBook` no app. */
function normBook(s) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const to = 'aaaaaeeeeiiiiooooouuuuc';
  let out = '';
  for (const ch of s.toLowerCase()) {
    if (!ch.trim()) continue;
    const i = from.indexOf(ch);
    out += i < 0 ? ch : to[i];
  }
  return out;
}

const REF = /^\s*((?:\d\s*)?\D+?)\s+(\d+)/;

async function firestore() {
  const { Firestore } = await import('@google-cloud/firestore');
  const { getGlobalDefaultAccount } = require('firebase-tools/lib/auth');
  const { getCredentialPathAsync } = require('firebase-tools/lib/defaultCredentials');
  const account = getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) throw new Error('Firebase CLI não logado. Rode: firebase login --reauth');
  process.env.GOOGLE_APPLICATION_CREDENTIALS = await getCredentialPathAsync(account);
  return { db: new Firestore({ projectId: process.env.FIREBASE_PROJECT || 'trilha-biblia' }), Firestore };
}

async function main() {
  // Livros como o app os chama (JFAAL e TB usam os mesmos nomes).
  const bible = JSON.parse(readFileSync(join(APP_DATA, 'bible_jfaal.json'), 'utf8').replace(/^﻿/, ''));
  const books = bible.map((b) => ({ name: b.name, key: normBook(b.name), chapters: b.chapters.length }));
  // Nome que as cenas usam e a Bíblia do app não.
  const ALIAS = { cantares: 'canticos', cantaresdesalomao: 'canticos' };
  const bookOf = (refBook) => {
    const k = ALIAS[normBook(refBook)] ?? normBook(refBook);
    return books.find((b) => b.key === k) ?? books.find((b) => b.key.startsWith(k) || k.startsWith(b.key)) ?? null;
  };

  const { db, Firestore } = await firestore();
  const trails = (await db.collection('content_trails').get()).docs.map((d) => ({ slug: d.id, ...d.data() }));
  const capScenes = new Set();
  const bosses = new Set();
  for (const t of trails) {
    for (const m of t.modules || []) {
      for (const x of m.missions || []) {
        if (x.type === 'boss') bosses.add(x.slug);
        else if (t.slug.endsWith('-cap')) capScenes.add(x.slug);
      }
    }
  }
  const studies = (await db.collection('content_mission_studies').get()).docs;

  // key livro → capítulo → [{s, l, t, cap}]
  const index = new Map();
  const add = (book, ch, entry) => {
    if (!index.has(book.key)) index.set(book.key, { book, chapters: new Map() });
    const chapters = index.get(book.key).chapters;
    if (!chapters.has(ch)) chapters.set(ch, []);
    const list = chapters.get(ch);
    if (!list.some((e) => e.s === entry.s)) list.push(entry);
  };
  const unresolved = new Set();
  const entries = new Map();
  for (const d of studies) {
    if (bosses.has(d.id) || d.id.includes('-boss-')) continue;
    const st = d.data();
    const life = typeof st.focusQuestion === 'string' ? st.focusQuestion.trim() : '';
    const text = typeof st.anchorQuestion === 'string' ? st.anchorQuestion.trim() : '';
    if (!life && !text) continue;
    const entry = { s: d.id, ...(life && { l: life }), ...(text && { t: text }), cap: capScenes.has(d.id) };
    entries.set(d.id, entry);
    const refs = new Set([st.passageRef, ...(st.passages || []).map((p) => p?.ref)].filter((r) => typeof r === 'string'));
    for (const ref of refs) {
      const m = REF.exec(ref);
      if (!m) continue;
      const book = bookOf(m[1].trim());
      if (!book) {
        unresolved.add(m[1].trim());
        continue;
      }
      add(book, Number(m[2]), entry);
    }
  }

  // Capítulos juntados ao vizinho no plano: a cena cobre os dois.
  for (const t of trails.filter((x) => x.slug.endsWith('-cap'))) {
    const planPath = join(ADMIN_DIR, 'v3', t.slug, 'plano.json');
    if (!existsSync(planPath)) continue;
    const plan = JSON.parse(readFileSync(planPath, 'utf8'));
    const byRef = new Map();
    for (const m of t.modules || []) for (const x of m.missions || []) if (x.type !== 'boss') byRef.set(x.subtitle, x.slug);
    for (const mod of plan.modules || []) {
      for (const sc of mod.scenes || []) {
        const span = /^(\d+)\s*[–-]\s*(\d+)$/.exec(String(sc.chapters || ''));
        const slug = byRef.get(sc.ref);
        const entry = slug && entries.get(slug);
        const m = REF.exec(sc.ref || '');
        const book = m && bookOf(m[1].trim());
        if (!span || !entry || !book) continue;
        for (let ch = Number(span[1]); ch <= Number(span[2]); ch++) add(book, ch, entry);
      }
    }
  }

  let covered = 0;
  let total = 0;
  const docs = [];
  for (const book of books) {
    const chapters = index.get(book.key)?.chapters ?? new Map();
    const missing = [];
    const out = {};
    for (let ch = 1; ch <= book.chapters; ch++) {
      total++;
      const list = chapters.get(ch);
      if (!list?.length) {
        missing.push(ch);
        continue;
      }
      covered++;
      // Cena capítulo a capítulo primeiro; depois as demais, pelo slug.
      out[ch] = [...list]
        .sort((a, b) => Number(b.cap) - Number(a.cap) || a.s.localeCompare(b.s))
        .map(({ cap, ...e }) => e);
    }
    docs.push({ id: `chapters_${book.key}`, data: { book: book.name, chapters: out } });
    const size = JSON.stringify(out).length;
    console.log(
      `${book.name.padEnd(24)} ${String(book.chapters - missing.length).padStart(3)}/${String(book.chapters).padEnd(3)}` +
        ` ${(size / 1024).toFixed(0).padStart(4)} KB${missing.length ? `  sem cena: ${missing.join(', ')}` : ''}`,
    );
  }
  console.log(`\n${covered}/${total} capítulos com cena`);
  if (unresolved.size) console.log(`Livro não reconhecido nas referências: ${[...unresolved].join(', ')}`);

  if (!APPLY) {
    console.log('\nDry run. Para gravar: acrescente --apply');
    return;
  }
  for (let i = 0; i < docs.length; i += 20) {
    const batch = db.batch();
    for (const { id, data } of docs.slice(i, i + 20)) {
      batch.set(db.collection('content_meta').doc(id), { ...data, updatedAt: Firestore.FieldValue.serverTimestamp() });
    }
    await batch.commit();
  }
  console.log(`✓ ${docs.length} livros em content_meta/chapters_<livro>`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
