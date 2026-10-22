/**
 * Monta o pacote de entrada de cada cena de uma trilha para o gerador V3.
 * O modelo nunca cita a Bíblia de memória: o pacote leva os versos da JFAAL,
 * um a um, com a referência exata.
 *
 *   node admin/scripts/v3_inputs.mjs --trail mateus
 *
 * Escreve admin/v3/<trilha>/inputs/<slug>.json. Fontes: trails.json (cena),
 * mission_studies.json (estudo V2) e perguntas-v2/<trilha>.json (versos que a
 * V2 já usava).
 */
import { mkdirSync, writeFileSync } from 'fs';
import { join } from 'path';
import { pathToFileURL } from 'url';
import { chapterLength, splitRanges, versesOf } from './_jfaal.mjs';
import { APP_DATA, REPO_DIR, argValue, loadTrail, readJson, trailDir } from './_v3_paths.mjs';

// Teto de versos por pacote: o bastante para a cena, sem afogar o prompt.
const MAX_VERSES = 40;
// Cena de um ou dois versos ganha vizinhos: seis perguntas por modo precisam
// de chão, e o validador limita a 3 o uso do mesmo palco.
const MIN_VERSES = 6;
const PAD = 3;

function padRanges(ranges) {
  const total = ranges.reduce((n, r) => n + (r.end - r.start + 1), 0);
  if (!ranges.length || total >= MIN_VERSES) return ranges;
  const [first, ...rest] = ranges;
  const len = chapterLength(first.book, first.chapter);
  const start = Math.max(1, first.start - PAD);
  const end = Math.min(len, first.end + PAD);
  const book = first.ref.replace(/\s\d+:.*$/, '');
  const ref = start === end ? `${book} ${first.chapter}:${start}` : `${book} ${first.chapter}:${start}–${end}`;
  return [{ ...first, start, end, ref }, ...rest];
}

function uniqueRanges(refs) {
  const seen = new Set();
  const out = [];
  for (const raw of refs) {
    for (const r of splitRanges(raw)) {
      if (seen.has(r.ref)) continue;
      seen.add(r.ref);
      out.push(r);
    }
  }
  return out;
}

/** Versos das faixas, sem repetir e até o teto. Faixa maior que o teto entra cortada. */
function collectVerses(ranges) {
  const seen = new Set();
  const out = [];
  for (const r of ranges) {
    for (const v of versesOf(r)) {
      if (out.length >= MAX_VERSES) return out;
      if (seen.has(v.ref)) continue;
      seen.add(v.ref);
      out.push(v);
    }
  }
  return out;
}

export function buildInputs(trailSlug) {
  const trail = loadTrail(trailSlug);
  const studies = readJson(join(APP_DATA, 'mission_studies.json')).studies || {};
  const v2 = readJson(join(REPO_DIR, 'perguntas-v2', `${trailSlug}.json`), []);
  const v2Refs = new Map();
  for (const q of Array.isArray(v2) ? v2 : []) {
    if (!q.section || !q.verseRef) continue;
    if (!v2Refs.has(q.section)) v2Refs.set(q.section, new Set());
    v2Refs.get(q.section).add(q.verseRef);
  }

  const packets = [];
  const allEarlier = [];
  for (const mod of trail.modules || []) {
    const earlier = [];
    for (const m of mod.missions || []) {
      const boss = m.type === 'boss';
      const study = studies[m.slug] || {};
      // Desafio mistura as cenas anteriores do bloco: os versos vêm delas.
      // Bloco sem cenas antes do Desafio: usa as cenas anteriores da trilha.
      const pool = boss ? (earlier.length ? earlier : allEarlier) : [];
      const sourceRefs = boss
        ? pool.flatMap((e) => e.refs.slice(0, 2)).filter(Boolean)
        : [study.passageRef, m.hookRef, ...(v2Refs.get(m.slug) || [])].filter(Boolean);
      const ranges = boss ? uniqueRanges(sourceRefs) : padRanges(uniqueRanges(sourceRefs));
      const packet = {
        trail: {
          slug: trail.slug,
          title: trail.title,
          description: trail.description,
          realm: trail.realm,
          genre: trail.genre,
        },
        block: mod.title,
        mission: {
          slug: m.slug,
          title: m.title,
          type: boss ? 'boss' : 'lesson',
          intro: m.intro,
          hookRef: m.hookRef,
          hookNote: m.hookNote,
          centralInsight: m.centralInsight,
          objective: m.objective,
        },
        // O que a V2 já tinha. Serve de pista do recorte, não de texto a copiar.
        v2: {
          passageRef: study.passageRef || null,
          context: study.context || null,
          keyword: study.keyword || null,
          verseRefs: [...(v2Refs.get(m.slug) || [])],
        },
        earlierScenes: boss
          ? pool.map((e) => ({ slug: e.slug, title: e.title, centralInsight: e.centralInsight, ref: e.refs[0] || null }))
          : [],
        ranges: ranges.map((r) => r.ref),
        verses: collectVerses(ranges),
      };
      packets.push(packet);
      if (!boss) {
        const scene = {
          slug: m.slug,
          title: m.title,
          centralInsight: m.centralInsight,
          hookRef: m.hookRef,
          passageRef: study.passageRef,
          // Só referências que a JFAAL reconhece (há hookRef que é título).
          refs: ranges.map((r) => r.ref),
        };
        earlier.push(scene);
        allEarlier.push(scene);
      }
    }
  }
  return packets;
}

function main() {
  const trailSlug = argValue('--trail');
  if (!trailSlug) {
    console.error('Uso: node admin/scripts/v3_inputs.mjs --trail <slug>');
    process.exit(1);
  }
  const dir = join(trailDir(trailSlug), 'inputs');
  mkdirSync(dir, { recursive: true });
  const packets = buildInputs(trailSlug);
  let thin = 0;
  for (const p of packets) {
    writeFileSync(join(dir, `${p.mission.slug}.json`), `${JSON.stringify(p, null, 2)}\n`);
    if (p.verses.length < 3) {
      thin++;
      console.log(`  ! ${p.mission.slug}: só ${p.verses.length} verso(s) — confira hookRef/passageRef`);
    }
  }
  console.log(`✓ ${packets.length} pacote(s) em ${dir}${thin ? ` · ${thin} com poucos versos` : ''}`);
}

if (import.meta.url === pathToFileURL(process.argv[1] || '').href) main();
