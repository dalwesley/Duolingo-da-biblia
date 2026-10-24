/**
 * Prompts de imagem da arte de cada cena, no estilo das pinturas das trilhas.
 * O modelo de imagem (ChatGPT) só pinta; o momento vem do estudo V3 da cena.
 *
 *   node admin/scripts/scene_art_prompts.mjs [--trail rute] [--all]
 *       → admin/arte/cenas/PROMPTS_CENAS.md: as instruções (coladas uma vez) e um
 *         bloco por trilha com as cenas que ainda não têm arte (em provisorio/ ou
 *         no app), na ordem do mapa; --all lista todas
 *       → admin/arte/cenas/manifest.json: cena → arquivo esperado (sempre todas)
 *
 * Cenas das trilhas de entrada (conhecer-a-deus, entender-a-biblia) usam a arte
 * da cena do banco (bankSection) e não ganham prompt próprio.
 */
import { existsSync, mkdirSync, readdirSync, rmSync, writeFileSync } from 'fs';
import { join } from 'path';
import { fileURLToPath } from 'url';
import { ADMIN_DIR, REPO_DIR, argValue, listTrailSlugs, loadTrail, readJson, trailDir } from './_v3_paths.mjs';

const OUT_DIR = join(ADMIN_DIR, 'arte', 'cenas');
const OUT_FILE = join(OUT_DIR, 'PROMPTS_CENAS.md');
const APP_ART = join(REPO_DIR, 'trilha_app', 'assets', 'art');
const DRAFT_ART = join(OUT_DIR, 'provisorio');
const MOMENT_MAX = 360;
const PASSAGE_MAX = 300;

const sceneArtFile = (slug) => `scene_${slug}.jpg`;
const hasArt = (slug) => [DRAFT_ART, APP_ART].some((dir) => existsSync(join(dir, sceneArtFile(slug))));

// Colado uma vez no começo da conversa (ou nas Instruções de um Projeto).
const WORKFLOW = `Você vai pintar a arte das cenas do app STWAY, uma imagem por vez.

Como vamos trabalhar:
- Eu mando a lista de cenas de uma trilha, com a pintura da trilha anexada. Use essa pintura como referência de estilo, paleta e luz; não copie a composição.
- Pinte a cena 1. Antes da imagem, escreva só o nome do arquivo dela (ex.: scene_gen-01-criador.jpg).
- Quando eu disser "próxima", pinte a cena seguinte da lista. Quando eu disser "refaz", pinte de novo a mesma cena.
- Uma resposta = uma imagem = uma cena. Nunca junte cenas numa imagem só: nada de grade, mosaico, colagem, painéis, quadrinhos, tiras, folha de referência ou números nos cantos. Nunca mande variações da mesma cena.
- A imagem ocupa o quadro inteiro, de borda a borda, sem margem branca.`;

// Estilo de cada imagem: vai nas instruções do chat e em cada pedido à API.
export const STYLE = `Estilo de todas as imagens:
Ilustração digital pintada, formas simplificadas com gradientes suaves e textura leve, cinematográfica. Paleta: azul-marinho profundo e azul-ardósia dominam a imagem, com uma luz quente âmbar/dourada como o único ponto de calor (crepúsculo, aurora, fogo ou lamparina). Nada de céu inteiro laranja nem pôr do sol saturado. Clima sereno e reverente.
Formato paisagem 3:2 (1536×1024). Assunto principal do centro para a direita; o terço esquerdo e a faixa de baixo ficam calmos e mais escuros, porque o app escreve o título e o progresso por cima.
Pessoas pequenas na paisagem, de costas, de perfil ou em silhueta, com rosto sem detalhe. Câmera sempre aberta: nada de close de rosto, mãos ou corpo. Roupas, casas e objetos do mundo bíblico da época do texto. Deus nunca aparece como figura humana: a presença dele é luz, nuvem ou fogo. Jesus, se aparecer, pequeno, de longe e de costas ou em silhueta, sem rosto visível.
Sem texto, letras, legendas, placas, inscrições, moldura, logotipo ou marca d'água; rolos e livros aparecem fechados ou com a escrita ilegível.

Cena marcada como Travessia: é o desafio do bloco. Composição mais ampla, um caminho que atravessa a paisagem rumo à luz.
Cena que trata de uma ideia e não de um acontecimento: pinte um lugar concreto do mundo bíblico que a represente (estrada, colina, porta, mesa, campo, mar, rolo, lamparina). Nada de símbolos abstratos, diagramas ou ícones.`;

const INSTRUCTIONS = `${WORKFLOW}\n\n${STYLE}`;

function clip(text, max) {
  const t = String(text || '').replace(/\s+/g, ' ').trim();
  if (t.length <= max) return t;
  const cut = t.slice(0, max);
  return `${cut.slice(0, cut.lastIndexOf(' '))} …`;
}

function studiesOf(trail) {
  const path = join(trailDir(trail), 'studies_v3.json');
  return existsSync(path) ? readJson(path).studies || {} : {};
}

export function sceneLines(n, { block, mission, study }) {
  const ref = study.passageRef || mission.hookRef;
  const lines = [
    `${n}. ${sceneArtFile(mission.slug)} — "${mission.title}"${ref ? ` (${ref})` : ''}${mission.type === 'boss' ? ' · Travessia' : ''} · bloco "${block}"`,
    `Momento: ${clip(study.context || mission.intro, MOMENT_MAX)}`,
  ];
  if (study.passageText) lines.push(`Texto: "${clip(study.passageText, PASSAGE_MAX)}"`);
  if (study.keyword) lines.push(`Destaque: ${study.keyword}${study.keywordGloss ? ` — ${study.keywordGloss}` : ''}`);
  return lines.join('\n');
}

/** Cenas sem arte, na ordem do mapa, com o texto do pedido de cada uma. */
export function pendingScenes(slugs = listTrailSlugs()) {
  const seen = new Set();
  const out = [];
  for (const slug of slugs) {
    const trail = loadTrail(slug);
    const studies = studiesOf(slug);
    for (const mod of trail.modules || []) {
      for (const m of mod.missions || []) {
        if (seen.has(m.slug)) continue;
        seen.add(m.slug);
        if (hasArt(m.slug)) continue;
        out.push({
          trail: slug,
          slug: m.slug,
          file: sceneArtFile(m.slug),
          brief: `Trilha: ${trail.title} — ${trail.description}\n\n${sceneLines(1, { block: mod.title, mission: m, study: studies[m.slug] || {} }).replace(/^1\. \S+ — /, 'Cena: ')}`,
        });
      }
    }
  }
  return out;
}

function trailBlock(slug, seen, all) {
  const trail = loadTrail(slug);
  const studies = studiesOf(slug);
  const art = `trail_${slug}.jpg`;
  const trailArt = existsSync(join(APP_ART, art)) ? art : null;
  const items = [];
  const scenes = [];
  for (const mod of trail.modules || []) {
    for (const m of mod.missions || []) {
      if (seen.has(m.slug)) continue;
      seen.add(m.slug);
      scenes.push({ trail: slug, slug: m.slug, title: m.title, type: m.type, file: sceneArtFile(m.slug) });
      if (!all && hasArt(m.slug)) continue;
      items.push(sceneLines(items.length + 1, { block: mod.title, mission: m, study: studies[m.slug] || {} }));
    }
  }
  if (!items.length) return { md: '', scenes };
  const md = [
    `## ${trail.title} — ${items.length} cena(s)`,
    '',
    trailArt ? `Anexe \`trilha_app/assets/art/${trailArt}\` e cole:` : 'Cole:',
    '',
    '```text',
    `Trilha: ${trail.title} — ${trail.description}`,
    '',
    items.join('\n\n'),
    '',
    'Comece pela cena 1.',
    '```',
    '',
  ].join('\n');
  return { md, scenes };
}

function main() {
  const only = argValue('--trail');
  const slugs = only ? [only] : listTrailSlugs();
  const all = process.argv.includes('--all');
  mkdirSync(OUT_DIR, { recursive: true });
  // Formato antigo: um arquivo por trilha.
  for (const f of readdirSync(OUT_DIR)) if (/^\d{2}-.+\.md$/.test(f)) rmSync(join(OUT_DIR, f));

  const seen = new Set();
  const manifest = [];
  const blocks = [];
  for (const slug of slugs) {
    const { md, scenes } = trailBlock(slug, seen, all);
    manifest.push(...scenes);
    if (md) blocks.push(md);
  }
  const pending = blocks.reduce((n, md) => n + Number(/— (\d+) cena/.exec(md)[1]), 0);
  const head = [
    all
      ? `# Arte das cenas — ${manifest.length} cena(s) em ${blocks.length} trilha(s)`
      : `# Arte das cenas — faltam ${pending} de ${manifest.length} cena(s), em ${blocks.length} trilha(s)`,
    '',
    'No ChatGPT: uma conversa por trilha (ou um Projeto com o passo 1 nas Instruções).',
    '',
    '1. Cole as instruções abaixo uma vez.',
    '2. Anexe a pintura da trilha e cole o bloco dela.',
    '3. Salve cada imagem com o nome que o ChatGPT escrever e diga "próxima".',
    '4. Se vier grade ou várias imagens juntas, diga "refaz, uma imagem só".',
    '',
    '## Instruções (uma vez)',
    '',
    '```text',
    INSTRUCTIONS,
    '```',
    '',
  ].join('\n');
  writeFileSync(OUT_FILE, [head, ...blocks].join('\n'));
  writeFileSync(join(OUT_DIR, 'manifest.json'), `${JSON.stringify(manifest, null, 2)}\n`);
  console.log(`✓ ${all ? manifest.length : pending} cena(s) em ${OUT_FILE}`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();
