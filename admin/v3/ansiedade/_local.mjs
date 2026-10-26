/**
 * Ansiedade é trilha de entrada: vive no app (trilha_app/lib/data/entry_trails.dart),
 * não em trails.json. Este script faz para ela o que v3_inputs.mjs e
 * `v3_manual.mjs conferir` fazem para as outras, sem tocar nos scripts comuns.
 *
 *   node v3/ansiedade/_local.mjs inputs     # inputs/<cena>.json (versos da JFAAL)
 *   node v3/ansiedade/_local.mjs conferir   # manual/respostas/<cena>.json → hidrata, valida → cenas/
 *   node v3/ansiedade/_local.mjs traducao   # depois do merge: traducao-fonte → traducao-respostas
 *
 * Depois, como nas outras trilhas (de admin/):
 *   npm run v3:shuffle -- --trail ansiedade
 *   npm run v3:validate -- --trail ansiedade --final
 *   npm run v3:merge -- --trail ansiedade
 *   npm run validate:bank -- v3/ansiedade/questions_v3.json
 */
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { splitRanges, versesOf } from '../../scripts/_jfaal.mjs';
import { hydrateCena, scopeErrors } from '../../scripts/_v3_hydrate.mjs';
import { validateCenaData } from '../../scripts/validate_pilot_v3.mjs';

const DIR = dirname(fileURLToPath(import.meta.url));
const REPO = join(DIR, '..', '..', '..');
const L10N = JSON.parse(readFileSync(join(REPO, 'trilha_app', 'lib', 'l10n', 'parts', 'content_entry_trails.json'), 'utf8'));
const pt = (key) => L10N[key]?.pt ?? null;

// Espelho de `_anxiety` em entry_trails.dart (hookRef) + recorte de versos do pacote.
const SCENES = [
  { slug: 'dor-ansia-01', key: 'DorAnsia01', hookRef: 'Mateus 6:25–34', ranges: ['Mateus 6:19–34'] },
  { slug: 'dor-ansia-02', key: 'DorAnsia02', hookRef: 'Filipenses 4:12–13', ranges: ['Filipenses 4:4–13'] },
  { slug: 'dor-ansia-03', key: 'DorAnsia03', hookRef: 'Salmo 23:1–3', ranges: ['Salmos 23:1–6'] },
  { slug: 'dor-ansia-04', key: 'DorAnsia04', hookRef: 'Mateus 6:9–11', ranges: ['Mateus 6:7–13'] },
  { slug: 'dor-ansia-05', key: 'DorAnsia05', hookRef: '1 Pedro 1:3–5', ranges: ['1 Pedro 1:3–9'] },
];

const TRAIL = {
  slug: 'ansiedade',
  title: pt('entryTrailAnsiedadeTitle'),
  description: pt('entryTrailAnsiedadeDescription'),
  realm: 'vida-crista',
};

function packet(s) {
  const ranges = s.ranges.flatMap((r) => splitRanges(r));
  return {
    trail: TRAIL,
    block: pt('entryTrailAnsiedadeModuleTitle'),
    mission: {
      slug: s.slug,
      title: pt(`entryMission${s.key}Title`),
      type: 'lesson',
      intro: pt(`entryMission${s.key}Intro`),
      hookRef: s.hookRef,
      hookNote: pt(`entryMission${s.key}HookNote`),
      centralInsight: pt(`entryMission${s.key}CentralInsight`),
      objective: pt(`entryMission${s.key}Objective`),
    },
    v2: { passageRef: null, context: null, keyword: null, verseRefs: [] },
    earlierScenes: [],
    ranges: ranges.map((r) => r.ref),
    verses: ranges.flatMap((r) => versesOf(r)),
  };
}

function inputs() {
  const dir = join(DIR, 'inputs');
  mkdirSync(dir, { recursive: true });
  for (const s of SCENES) writeFileSync(join(dir, `${s.slug}.json`), `${JSON.stringify(packet(s), null, 2)}\n`);
  console.log(`✓ ${SCENES.length} pacote(s) em ${dir}`);
}

function conferir() {
  const respDir = join(DIR, 'manual', 'respostas');
  mkdirSync(join(DIR, 'cenas'), { recursive: true });
  let failed = 0;
  for (const s of SCENES) {
    const f = join(respDir, `${s.slug}.json`);
    if (!existsSync(f)) {
      console.log(`  - ${s.slug}: sem resposta`);
      continue;
    }
    const p = JSON.parse(readFileSync(join(DIR, 'inputs', `${s.slug}.json`), 'utf8'));
    const cena = hydrateCena(JSON.parse(readFileSync(f, 'utf8')), p);
    const r = validateCenaData(cena, s.slug, { trail: TRAIL.slug, boss: false });
    r.errors.push(...scopeErrors(cena, p));
    if (r.errors.length) {
      failed++;
      console.log(`  ✗ ${s.slug}: ${r.errors.length} erro(s)`);
      for (const e of r.errors) console.log(`      ${e}`);
    } else {
      writeFileSync(join(DIR, 'cenas', `${s.slug}.json`), `${JSON.stringify(cena, null, 2)}\n`);
      console.log(`  ✓ ${s.slug}`);
    }
    for (const w of r.warnings) console.log(`      ! ${w}`);
  }
  const done = readdirSync(join(DIR, 'cenas')).filter((x) => x.endsWith('.json')).length;
  console.log(`\n${done}/${SCENES.length} cena(s) em cenas/${failed ? ` · ${failed} com erro` : ''}`);
  process.exitCode = failed ? 1 : 0;
}

/**
 * Tradução escrita contra as respostas (ids de opção antes do shuffle):
 * manual/traducao-fonte/<lang>.json → manual/traducao-respostas/<lang>/<cena>.json
 * com os ids embaralhados de questions_v3.json. Depois:
 *   node scripts/v3_manual.mjs conferir-traducao --trail ansiedade
 */
const MODES = ['semente', 'caminhada', 'profundezas'];
function traducao() {
  const merged = new Map(JSON.parse(readFileSync(join(DIR, 'questions_v3.json'), 'utf8')).map((q) => [q.id, q]));
  let errors = 0;
  for (const lang of ['en', 'es']) {
    const src = JSON.parse(readFileSync(join(DIR, 'manual', 'traducao-fonte', `${lang}.json`), 'utf8'));
    const outDir = join(DIR, 'manual', 'traducao-respostas', lang);
    mkdirSync(outDir, { recursive: true });
    for (const s of SCENES) {
      const resp = JSON.parse(readFileSync(join(DIR, 'manual', 'respostas', `${s.slug}.json`), 'utf8')).questions;
      const tr = src[s.slug]?.questions || [];
      if (tr.length !== resp.length) {
        console.log(`  ✗ ${lang} ${s.slug}: ${tr.length} traduções para ${resp.length} perguntas`);
        errors++;
        continue;
      }
      const out = {};
      const nth = Object.fromEntries(MODES.map((m) => [m, 0]));
      resp.forEach((r, i) => {
        const nn = String(++nth[r.difficulty]).padStart(2, '0');
        const id = `ansiedade-${{ semente: 'sem', caminhada: 'cam', profundezas: 'pro' }[r.difficulty]}-${s.slug}-${nn}`;
        const q = merged.get(id);
        const t = tr[i];
        // id original → id embaralhado, pelo texto da opção em português.
        const remap = new Map((r.options || []).map((o) => [o.id, (q.options || []).find((m) => m.text === o.text)?.id ?? o.id]));
        const fwKeys = Object.keys(r.feedbackWrong || {}).sort().join();
        if (Object.keys(t.feedbackWrong || {}).sort().join() !== fwKeys) {
          console.log(`  ✗ ${lang} ${id}: chaves de feedbackWrong ${Object.keys(t.feedbackWrong || {})} ≠ ${fwKeys}`);
          errors++;
        }
        const e = { ...t, feedbackWrong: Object.fromEntries(Object.entries(t.feedbackWrong || {}).map(([k, v]) => [remap.get(k) ?? k, v])) };
        if (t.options) {
          if (Object.keys(t.options).sort().join() !== (r.options || []).map((o) => o.id).sort().join()) {
            console.log(`  ✗ ${lang} ${id}: chaves de options`);
            errors++;
          }
          e.options = Object.fromEntries(Object.entries(t.options).map(([k, v]) => [remap.get(k) ?? k, v]));
        }
        out[id] = e;
      });
      out[`estudo:${s.slug}`] = src[s.slug].study;
      writeFileSync(join(outDir, `${s.slug}.json`), `${JSON.stringify(out, null, 1)}\n`);
    }
  }
  console.log(errors ? `✗ ${errors} problema(s)` : '✓ traducao-respostas/{en,es} prontas. Agora: node scripts/v3_manual.mjs conferir-traducao --trail ansiedade');
  process.exitCode = errors ? 1 : 0;
}

const cmd = process.argv[2];
if (cmd === 'inputs') inputs();
else if (cmd === 'conferir') conferir();
else if (cmd === 'traducao') traducao();
else {
  console.log('Uso: node v3/ansiedade/_local.mjs inputs | conferir | traducao');
  process.exitCode = 1;
}
