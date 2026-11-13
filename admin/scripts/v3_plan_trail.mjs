/**
 * Trilha "capítulo a capítulo" a partir de um plano: confere os trechos na
 * JFAAL, avisa capítulo sem cena e trecho que repete o Panorama, e monta
 * trail.json, PLANO.md, os pacotes (inputs) e os pedidos completos do ChatGPT.
 *
 *   node scripts/v3_plan_trail.mjs --plan v3/mateus-cap/plano.json
 *   node scripts/v3_plan_trail.mjs --plan v3/mateus-cap/plano.json --check   # só confere
 *
 * plano.json:
 * {
 *   "slug": "mateus-cap", "prefix": "mtc", "book": "Mateus", "title": "Mateus",
 *   "description": "…", "icon": "📜", "color": "#…", "order": 41,
 *   "realm": "novo-testamento", "category": "evangelhos",
 *   "avoidTrails": ["mateus", "sermao-do-monte"],   // trechos que o Panorama já usa
 *   "modules": [
 *     { "title": "O Rei chega · cap. 1–4",
 *       "scenes": [ { "ref": "Mateus 2:1–12", "title": "…", "intro": "…",
 *                     "insight": "…", "objective": "…" } ],
 *       "boss": { "title": "Travessia: …", "intro": "…", "insight": "…" } }
 *   ]
 * }
 * Capítulo de uma cena por bloco (genealogia, lista) entra com "chapters":
 * "1–2" na cena, para a conta de cobertura.
 */
import { execFileSync } from 'child_process';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { ADMIN_DIR, argValue } from './_v3_paths.mjs';
import { chapterLength, parseRef, splitRanges, versesOf } from './_jfaal.mjs';

const planPath = argValue('--plan');
const CHECK = process.argv.includes('--check');
if (!planPath) {
  console.error('Uso: node scripts/v3_plan_trail.mjs --plan v3/<trilha>/plano.json [--check]');
  process.exit(1);
}
const plan = JSON.parse(readFileSync(join(ADMIN_DIR, planPath), 'utf8'));
const dir = dirname(join(ADMIN_DIR, planPath));

const slugify = (s) =>
  s
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .split('-')
    .slice(0, 4)
    .join('-');
const nn = (i) => String(i).padStart(2, '0');

const errors = [];
const warnings = [];

/** Versos já usados pelas trilhas a evitar ("livro:cap:verso"). */
function usedVerses() {
  const used = new Map();
  for (const t of plan.avoidTrails || []) {
    const path = join(ADMIN_DIR, 'v3', t, 'studies_v3.json');
    if (!existsSync(path)) continue;
    const studies = JSON.parse(readFileSync(path, 'utf8')).studies || {};
    for (const st of Object.values(studies)) {
      for (const p of st.passages || [{ ref: st.passageRef }]) {
        const r = parseRef(p.ref);
        if (!r || r.start === null) continue;
        for (let v = r.start; v <= r.end; v++) used.set(`${r.book}:${r.chapter}:${v}`, `${t}`);
      }
    }
  }
  return used;
}

const used = usedVerses();
const covered = new Set();
let sceneNo = 0;
const modules = [];

for (const [mi, mod] of plan.modules.entries()) {
  const missions = [];
  for (const sc of mod.scenes) {
    sceneNo++;
    const r = parseRef(sc.ref);
    const where = `cena ${sceneNo} (${sc.ref})`;
    if (!r || r.start === null) {
      errors.push(`${where}: referência inválida (um capítulo, faixa contínua)`);
      continue;
    }
    const len = chapterLength(r.book, r.chapter);
    if (!len || r.end > len) errors.push(`${where}: ${plan.book} ${r.chapter} tem ${len} versos`);
    const count = r.end - r.start + 1;
    if (count > 14) warnings.push(`${where}: ${count} versos (o pacote corta em 40, mas a cena fica longa)`);
    if (count < 4) warnings.push(`${where}: ${count} versos (o pacote completa com vizinhos)`);
    const clash = [];
    for (let v = r.start; v <= r.end; v++) {
      const t = used.get(`${r.book}:${r.chapter}:${v}`);
      if (t) clash.push(`${v}(${t})`);
    }
    if (clash.length > count / 2) warnings.push(`${where}: repete trecho do Panorama: ${clash.join(', ')}`);
    const extra = String(sc.chapters || '').match(/^(\d+)\s*[–-]\s*(\d+)$/);
    if (extra) for (let c = +extra[1]; c <= +extra[2]; c++) covered.add(c);
    covered.add(r.chapter);
    for (const k of ['title', 'intro', 'insight', 'objective']) {
      if (!String(sc[k] || '').trim()) errors.push(`${where}: sem ${k}`);
    }
    if (String(sc.insight || '').length > 140) errors.push(`${where}: insight > 140 caracteres`);
    const verses = splitRanges(sc.ref).flatMap((rg) => versesOf(rg)).slice(0, 2).map((v) => v.text).join(' ');
    missions.push({
      slug: `${plan.prefix}-${nn(sceneNo)}-${slugify(sc.title)}`,
      title: sc.title,
      subtitle: sc.ref,
      intro: sc.intro,
      type: 'lesson',
      xpReward: 60,
      questions: [],
      hookRef: sc.ref,
      hookVerse: verses,
      hookNote: sc.insight,
      centralInsight: sc.insight,
      objective: sc.objective,
    });
  }
  const b = mod.boss || {};
  if (!b.title || !b.intro || !b.insight) errors.push(`etapa ${mi + 1}: Travessia sem title/intro/insight`);
  missions.push({
    slug: `${plan.prefix}-boss-${mi + 1}`,
    title: b.title,
    subtitle: `Revisão da etapa ${mi + 1}`,
    intro: b.intro,
    type: 'boss',
    xpReward: 110,
    questions: [],
    hookRef: b.title,
    hookVerse: b.intro,
    hookNote: b.intro,
    centralInsight: b.insight,
    objective: `Revisão da etapa ${mi + 1}`,
  });
  modules.push({ title: mod.title, icon: mod.icon || 'zap', section: plan.title, missions });
}

const total = plan.chapters || 0;
const missing = [];
for (let c = 1; c <= total; c++) if (!covered.has(c)) missing.push(c);
if (missing.length) warnings.push(`capítulos sem cena: ${missing.join(', ')}`);

for (const w of warnings) console.log(`  ! ${w}`);
for (const e of errors) console.log(`  ✗ ${e}`);
const lessons = modules.flatMap((m) => m.missions).filter((m) => m.type === 'lesson').length;
console.log(`${plan.slug}: ${modules.length} etapa(s), ${lessons} cena(s), ${modules.length} Travessia(s)`);
if (errors.length) process.exit(1);
if (CHECK) process.exit(0);

const trail = {
  slug: plan.slug,
  title: plan.title,
  description: plan.description,
  icon: plan.icon || '📖',
  color: plan.color || '#3E86D6',
  order: plan.order || 0,
  unlockAfter: null,
  comingSoon: false,
  realm: plan.realm,
  category: plan.category,
  isActive: true,
  modules,
};
mkdirSync(dir, { recursive: true });
writeFileSync(join(dir, 'trail.json'), `${JSON.stringify(trail, null, 2)}\n`);

// PLANO.md para revisar.
const lines = [`# ${plan.title} — capítulo a capítulo`, '', `Trilha \`${plan.slug}\` · ${lessons} cenas · ${modules.length} etapas.`, ''];
if (plan.avoidTrails?.length) lines.push(`O Panorama (${plan.avoidTrails.join(', ')}) já usa outros trechos; as cenas novas não os repetem.`, '');
let n = 0;
for (const [mi, m] of modules.entries()) {
  lines.push(`## Etapa ${mi + 1} · ${m.title}`, '', '| # | Cena | Trecho | Ideia central |', '|---|---|---|---|');
  for (const s of m.missions) {
    if (s.type === 'boss') lines.push(`| ⚔ | ${s.title} | as cenas acima | — |`);
    else lines.push(`| ${++n} | ${s.title} | ${s.hookRef} | ${s.centralInsight} |`);
  }
  lines.push('');
}
if (missing.length) lines.push(`Capítulos sem cena: ${missing.join(', ')}.`, '');
writeFileSync(join(dir, 'PLANO.md'), `${lines.join('\n')}\n`);

execFileSync('node', [join(ADMIN_DIR, 'scripts', 'v3_inputs.mjs'), '--trail', plan.slug], { stdio: 'inherit' });
execFileSync('node', [join(ADMIN_DIR, 'scripts', 'v3_manual.mjs'), 'pedidos', '--trail', plan.slug, '--completo'], {
  stdio: 'inherit',
});
