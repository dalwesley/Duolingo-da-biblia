/**
 * Prompts de imagem da arte de cada cena, no estilo das pinturas das trilhas.
 * O modelo de imagem (ChatGPT) só pinta; o momento vem do estudo V3 da cena.
 *
 *   node admin/scripts/scene_art_prompts.mjs [--trail rute] [--all]
 *       → admin/arte/cenas/livros/NN-<livro>.md: um arquivo por trilha/livro, com
 *         as instruções e o bloco das cenas que ainda não têm arte (em provisorio/
 *         ou no app), numerado na ordem do mapa; --all lista todas
 *       → admin/arte/cenas/PROMPTS_CENAS.md: índice dos arquivos + instruções
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
const BOOKS_DIR = join(OUT_DIR, 'livros');
const APP_ART = join(REPO_DIR, 'trilha_app', 'assets', 'art');
const DRAFT_ART = join(OUT_DIR, 'provisorio');
const ICON = 'trilha_app/assets/icon/app_icon_ios.png';
const MOMENT_MAX = 360;
const PASSAGE_MAX = 300;

const sceneArtFile = (slug) => `scene_${slug}.jpg`;
const hasArt = (slug) => [DRAFT_ART, APP_ART].some((dir) => existsSync(join(dir, sceneArtFile(slug))));

// Colado uma vez no começo da conversa (ou nas Instruções de um Projeto).
const WORKFLOW = `Você vai pintar a arte das cenas do app STWAY.

Como vamos trabalhar:
- O ícone do STWAY vai anexado: o caminho branco em S sobre camadas azuis. Ele é a base de toda cena: cada imagem carrega esse caminho. Não copie o ícone em si; traga o caminho para dentro da paisagem.
- Eu mando a lista de cenas de uma trilha. Gere todas, em ordem, uma imagem por cena. Antes de cada imagem, escreva só o nome do arquivo dela (ex.: scene_gen-01-criador.jpg).
- Se parar no meio, eu digo "continue" e você segue da próxima cena. Quando eu disser "refaz N", pinte de novo só a cena N.
- Cada imagem = uma cena. Nunca junte cenas numa imagem só: nada de grade, mosaico, colagem, painéis, quadrinhos, tiras, folha de referência ou números nos cantos. Nunca mande variações da mesma cena.
- A imagem ocupa o quadro inteiro, de borda a borda, sem margem branca.`;

// Estilo de cada imagem: vai nas instruções do chat e em cada pedido à API.
export const STYLE = `Estilo de todas as imagens:
Pintura digital cinematográfica e rica em detalhe, com pinceladas e textura visíveis, como quadro de filme épico bíblico. Luz de hora dourada: sol baixo no horizonte (pôr do sol ou aurora), céu que vai do azul profundo no alto ao laranja e dourado perto do sol, nuvens iluminadas por baixo, raios de luz no ar. Sombras e primeiro plano em azul-marinho e marrom profundo, com contraluz dourada recortando as figuras. Cena de noite também vale quando o texto pede: céu azul-escuro com estrelas ou lua, e o calor vem de fogo, tocha ou lamparina. Clima épico, sereno e reverente.
Formato paisagem 3:2 (1536×1024).
Composição em três planos:
- Primeiro plano: uma figura (ou um grupo pequeno) em tamanho médio, de costas ou de perfil, em pé com cajado ou sentada numa pedra, olhando a paisagem. Rosto em sombra ou de perfil, sem close. Moldura natural nas bordas: galho de árvore no alto, coluna ou ruína de pedra, rochas e mato embaixo. Às vezes, em vez da figura, um objeto da cena (pão, cálice, lamparina, rolo) sobre a pedra.
- Plano do meio: o caminho (abaixo) saindo de perto da figura e serpenteando pelo vale.
- Fundo: colinas, ciprestes, oliveiras, montanhas, e uma cidade, muralha ou templo no alto, onde o caminho chega, perto do sol.
Roupas, casas e objetos do mundo bíblico da época do texto: túnicas e mantos de linho e lã, casas de pedra, tendas, muralhas. Deus nunca aparece como figura humana: a presença dele é luz, raios, nuvem ou fogo. Jesus, se aparecer, de costas ou de perfil, rosto em sombra; na cruz, a cruz fica longe, recortada contra o céu.
Sem texto, letras, legendas, placas, inscrições, moldura, logotipo ou marca d'água; rolos e livros aparecem fechados ou com a escrita ilegível.

O caminho do ícone em toda cena: uma linha sinuosa em S, clara e luminosa, que atravessa a paisagem e some no horizonte rumo à luz. Ele vira algo do mundo da cena: estrada de terra ou de pedra, trilha, rio que reflete o sol, ou, quando a cena é do Espírito ou de Deus, fitas de vento e luz no céu. Nunca é uma faixa branca chapada nem um símbolo desenhado por cima.

Cena marcada como Travessia: é o desafio do bloco. Panorama mais amplo, de um ponto alto: o caminho mais longo e visível, atravessando o vale inteiro rumo à luz, e muitas vezes uma multidão ou caravana caminhando por ele.
Cena que trata de uma ideia e não de um acontecimento: pinte um lugar concreto do mundo bíblico que a represente (estrada, colina, porta em arco, mesa com pão e cálice, campo, videira, mar, rolo, lamparina). Nada de símbolos abstratos, diagramas ou ícones.`;

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
  if (!items.length) return { md: '', scenes, count: 0, title: trail.title };
  const md = [
    `## ${trail.title} — ${items.length} cena(s)`,
    '',
    `Anexe \`${ICON}\` e cole:`,
    '',
    '```text',
    `Trilha: ${trail.title} — ${trail.description}`,
    '',
    items.join('\n\n'),
    '',
    `Gere todas as ${items.length} imagens com foco no ícone do STWAY.`,
    '```',
    '',
  ].join('\n');
  return { md, scenes, count: items.length, title: trail.title };
}

const HOW_TO = [
  'No ChatGPT: uma conversa por livro (ou um Projeto com as instruções nas Instruções do Projeto).',
  '',
  '1. Cole as instruções uma vez.',
  `2. Anexe o ícone (${ICON}) e cole o bloco do livro.`,
  '3. Salve cada imagem em admin/arte/cenas/provisorio/ com o nome que o ChatGPT escrever. Se parar no meio, diga "continue".',
  '4. Se vier grade ou várias cenas numa imagem só, diga "refaz N, uma imagem só".',
  '5. No fim: node admin/scripts/scene_art_install.mjs',
];

const instructionsMd = (heading) => [heading, '', '```text', INSTRUCTIONS, '```', ''].join('\n');

function main() {
  const only = argValue('--trail');
  const all = process.argv.includes('--all');
  // Na ordem da Bíblia/do mapa (campo order), para numerar os arquivos.
  const ordered = listTrailSlugs()
    .map((slug) => ({ slug, order: loadTrail(slug).order ?? 9999 }))
    .sort((a, b) => a.order - b.order)
    .map((t) => t.slug);
  mkdirSync(BOOKS_DIR, { recursive: true });
  // Rodada completa refaz a pasta; --trail só regrava o arquivo daquele livro.
  if (!only) for (const f of readdirSync(BOOKS_DIR)) if (f.endsWith('.md')) rmSync(join(BOOKS_DIR, f));

  const seen = new Set();
  const manifest = [];
  const blocks = [];
  for (const slug of ordered) {
    const block = trailBlock(slug, seen, all);
    manifest.push(...block.scenes);
    if (block.md) blocks.push({ slug, ...block });
  }
  const books = [];
  for (const [i, { slug, md, count, title }] of blocks.entries()) {
    if (only && slug !== only) continue;
    const n = String(i + 1).padStart(2, '0');
    const file = `${n}-${slug.replace(/-cap$/, '')}.md`;
    writeFileSync(join(BOOKS_DIR, file), [
      `# ${title} — ${count} cena(s)`,
      '',
      ...HOW_TO,
      '',
      instructionsMd('## Instruções (uma vez por conversa)'),
      md,
    ].join('\n'));
    books.push({ file, title, count });
  }
  const pending = books.reduce((n, b) => n + b.count, 0);
  if (!only) {
    writeFileSync(OUT_FILE, [
      all
        ? `# Arte das cenas — ${manifest.length} cena(s) em ${books.length} livro(s)`
        : `# Arte das cenas — faltam ${pending} de ${manifest.length} cena(s), em ${books.length} livro(s)`,
      '',
      'Um arquivo por livro em `livros/`, cada um com as instruções e o bloco para colar.',
      '',
      ...HOW_TO,
      '',
      '## Livros',
      '',
      ...books.map((b) => `- [${b.title}](livros/${b.file}) — ${b.count} cena(s)`),
      '',
      instructionsMd('## Instruções (uma vez)'),
    ].join('\n'));
  }
  writeFileSync(join(OUT_DIR, 'manifest.json'), `${JSON.stringify(manifest, null, 2)}\n`);
  console.log(`✓ ${pending} cena(s) em ${books.length} arquivo(s) em ${BOOKS_DIR}`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();
