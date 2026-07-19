/**
 * Garante 5 perguntas × 3 dificuldades por passo (15/passo).
 * section no banco = slug do passo (mission.slug).
 *
 * - genesis: redistribui perguntas existentes e completa o que faltar
 * - exodo + AT: regenera banco por passo a partir do currículo/trails.json
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const trailsPath = path.join(root, 'trilha_app/assets/data/trails.json');
const genesisPath = path.join(root, 'trilha_app/assets/data/genesis_questions.json');
const exodoPath = path.join(root, 'trilha_app/assets/data/exodo_questions.json');
const otPath = path.join(root, 'trilha_app/assets/data/ot_questions.json');
const slugsPath = path.join(root, 'scripts/ot_difficulty_slugs.json');

const DIFFS = ['semente', 'caminhada', 'profundezas'];
const PER_STEP = 5;

const SCENE_TO_GENESIS = {
  'A Criação': 'criacao',
  'O Jardim': 'jardim',
  'Depois do Éden': 'depois',
};

const BOOK_LABEL = {
  'genesis-1-11': 'Gênesis 1–11',
  'genesis-12-50': 'Gênesis 12–50',
  exodo: 'Êxodo',
  levitico: 'Levítico',
  numeros: 'Números',
  deuteronomio: 'Deuteronômio',
  josue: 'Josué',
  juizes: 'Juízes',
  rute: 'Rute',
  samuel: '1–2 Samuel',
  reis: '1–2 Reis',
  cronicas: '1–2 Crônicas',
  esdras: 'Esdras',
  neemias: 'Neemias',
  ester: 'Ester',
  jo: 'Jó',
  salmos: 'Salmos',
  proverbios: 'Provérbios',
  eclesiastes: 'Eclesiastes',
  cantares: 'Cantares',
  isaias: 'Isaías',
  jeremias: 'Jeremias',
  lamentacoes: 'Lamentações',
  ezequiel: 'Ezequiel',
  daniel: 'Daniel',
  oseias: 'Oséias',
  joel: 'Joel',
  amos: 'Amós',
  obadias: 'Obadias',
  jonas: 'Jonas',
  miqueias: 'Miqueias',
  naum: 'Naum',
  habacuque: 'Habacuque',
  sofonias: 'Sofonias',
  ageu: 'Ageu',
  zacarias: 'Zacarias',
  malaquias: 'Malaquias',
  'periodo-intertestamentario': 'Período Intertestamentário',
};

function loadJson(p) {
  return JSON.parse(fs.readFileSync(p, 'utf8'));
}

function writeJson(p, data) {
  fs.writeFileSync(p, `${JSON.stringify(data, null, 2)}\n`);
}

function optIds() {
  return ['a', 'b', 'c', 'd'];
}

function makeQ({
  id,
  trail,
  difficulty,
  section,
  question,
  options,
  correct = 0,
  verseRef,
  feedbackCorrect,
  wrongHints = {},
  reveal = null,
}) {
  const ids = optIds();
  const correctOptionId = ids[correct];
  const feedbackWrong = {};
  for (const oid of ids) {
    if (oid === correctOptionId) continue;
    feedbackWrong[oid] =
      wrongHints[oid] ||
      `Revise o texto — a resposta correta é: “${options[correct]}”.`;
  }
  const out = {
    id,
    trail,
    difficulty,
    section,
    question,
    options: options.map((text, i) => ({ id: ids[i], text })),
    correctOptionId,
    feedbackCorrect,
    feedbackWrong,
    verseRef,
  };
  if (reveal != null) out.reveal = reveal;
  return out;
}

function templatesFor(diff, book, sceneTitle, stepTitle, stepIntro, i) {
  const theme = stepTitle;
  const tip = (stepIntro || '').trim();
  const verse = tip ? `${book} — ${theme}` : `Referência: ${book}`;

  if (diff === 'semente') {
    const variants = [
      {
        question: `Sobre “${theme}”, o que a Escritura ensina?`,
        options: [
          tip
            ? tip.replace(/\.$/, '')
            : `Esse episódio faz parte da narrativa de ${book}.`,
          'Isso não aparece na Bíblia.',
          'É só uma lenda sem base no texto.',
          'Foi inventado muito depois, sem relação com o cânon.',
        ],
        feedback: `Correto — “${theme}” está na história de ${book}.`,
        wrong: {
          b: `Revise ${book}: “${theme}” está no texto.`,
          c: 'Não é lenda solta — é Escritura.',
          d: 'A origem é canônica.',
        },
      },
      {
        question: `Em “${theme}” (${sceneTitle}), qual afirmação é verdadeira?`,
        options: [
          `O relato de ${book} inclui esse tema/passo na jornada do povo de Deus.`,
          'O tema é exclusivamente romano.',
          'Não há relação com a aliança.',
          'Serve só para entretenimento.',
        ],
        feedback: `Sim — “${theme}” pertence ao testemunho de ${book}.`,
      },
      {
        question: `Qual opção resume melhor o passo “${theme}”?`,
        options: [
          tip || `Um momento decisivo na narrativa de ${book}.`,
          'Um detalhe irrelevante.',
          'Uma contradição sem propósito.',
          'Um acréscimo medieval.',
        ],
        feedback: `Isso mesmo — “${theme}” importa na leitura de ${book}.`,
      },
      {
        question: `“${theme}” acontece no contexto de:`,
        options: [
          sceneTitle || book,
          'Somente o Apocalipse',
          'Somente as cartas de Paulo',
          'Mitos egípcios isolados',
        ],
        feedback: `Correto — o contexto é ${sceneTitle || book}.`,
      },
      {
        question: `Por que estudar “${theme}”?`,
        options: [
          `Para conhecer a ação de Deus e a resposta do povo em ${book}.`,
          'Só para memorizar nomes sem sentido.',
          'Porque a Bíblia não fala disso.',
          'Para negar a história bíblica.',
        ],
        feedback: `Exato — o estudo forma fé e memória bíblica.`,
      },
    ];
    return variants[i % variants.length];
  }

  if (diff === 'caminhada') {
    const variants = [
      {
        question: `Em “${theme}”, qual é o sentido principal para a fé?`,
        options: [
          'Deus age na história e chama o povo a confiar e obedecer.',
          'O episódio só serve para mapa e cronologia.',
          'Deus está ausente nesses relatos.',
          'A moral é: cada um faça o que quiser.',
        ],
        feedback: `Sim — “${theme}” aponta para a ação de Deus e a resposta humana.`,
      },
      {
        question: `O que “${theme}” revela sobre a aliança?`,
        options: [
          'Deus permanece fiel e o povo é chamado a responder.',
          'A aliança foi cancelada nesse ponto.',
          'Não há relação com aliança.',
          'A aliança depende só de força militar.',
        ],
        feedback: `Correto — fidelidade divina e resposta humana caminham juntas.`,
      },
      {
        question: `Qual aplicação justa de “${theme}”?`,
        options: [
          tip
            ? `Levar a sério: ${tip.replace(/\.$/, '')}.`
            : 'Ouvir o texto, crer e viver à luz do caráter de Deus.',
          'Ignorar o contexto e inventar o significado.',
          'Tratar o relato como ficção inútil.',
          'Usar o texto só para vencer debates.',
        ],
        feedback: `Boa — a aplicação nasce do texto e do caráter de Deus.`,
      },
      {
        question: `Em “${theme}”, o povo (ou a personagem) é desafiado(a) a:`,
        options: [
          'Confiar em Deus no meio da prova ou da decisão.',
          'Abandonar completamente a fé.',
          'Confiar só em ídolos.',
          'Negar a história passada.',
        ],
        feedback: `Sim — o desafio da fé atravessa “${theme}”.`,
      },
      {
        question: `Como “${theme}” se liga à cena “${sceneTitle}”?`,
        options: [
          `É um passo dessa cena na jornada de ${book}.`,
          'Não tem ligação com a cena.',
          'Pertence a outro testamento sem eco.',
          'É um acréscimo externo ao cânon.',
        ],
        feedback: `Correto — o passo pertence à cena ${sceneTitle}.`,
      },
    ];
    return variants[i % variants.length];
  }

  // profundezas
  const variants = [
    {
      question: `Como “${theme}” revela o caráter de Deus?`,
      options: [
        'Santidade, fidelidade e misericórdia aparecem mesmo na crise humana.',
        'Deus muda de essência a cada capítulo.',
        'Deus é indiferente ao sofrimento.',
        'Só importa o poder político.',
      ],
      feedback: `Correto — o caráter de Deus brilha em “${theme}”.`,
    },
    {
      question: `Qual leitura madura de “${theme}” evita?`,
      options: [
        'Reduzir o texto a moralismo raso, ignorando aliança e graça.',
        'Ler com oração e contexto.',
        'Comparar Escritura com Escritura.',
        'Considerar o caráter de Deus.',
      ],
      feedback: `Sim — profundidade honra o texto além do moralismo raso.`,
    },
    {
      question: `Em “${theme}”, qual tensão teológica aparece?`,
      options: [
        'Soberania de Deus e responsabilidade humana caminham juntas.',
        'Apenas acaso histórico.',
        'Negação total de qualquer escolha humana.',
        'Ausência completa de propósito.',
      ],
      feedback: `Exato — soberania e responsabilidade se encontram no relato.`,
    },
    {
      question: `O que “${theme}” ensina sobre pecado e graça?`,
      options: [
        'O pecado tem consequências, e Deus ainda preserva propósito e misericórdia.',
        'O pecado nunca tem custo.',
        'A graça anula qualquer chamado à fidelidade.',
        'Deus ignora o pecado do povo.',
      ],
      feedback: `Correto — juízo e graça aparecem com seriedade no texto.`,
    },
    {
      question: `Qual pergunta profunda “${theme}” deixa ao leitor?`,
      options: [
        'Como confiar e obedecer a Deus neste tipo de história?',
        'Como apagar o texto do cânon?',
        'Como negar a aliança?',
        'Como viver sem qualquer referência a Deus?',
      ],
      feedback: `Sim — o texto forma discípulos que perguntam e respondem com fé.`,
    },
  ];
  return variants[i % variants.length];
}

function synthesizeQuestion(trail, diff, mission, sceneTitle, index) {
  const book = BOOK_LABEL[trail] || trail;
  const t = templatesFor(
    diff,
    book,
    sceneTitle,
    mission.title,
    mission.intro || '',
    index,
  );
  const id = `${trail.slice(0, 10)}-${diff.slice(0, 3)}-${mission.slug.slice(0, 28)}-${String(index + 1).padStart(2, '0')}`;
  return makeQ({
    id,
    trail,
    difficulty: diff,
    section: mission.slug,
    question: t.question,
    options: t.options,
    verseRef: `Referência: ${book}`,
    feedbackCorrect: t.feedback,
    wrongHints: t.wrong || {},
  });
}

function stepsOfTrail(trail) {
  const out = [];
  for (const mod of trail.modules || []) {
    for (const m of mod.missions || []) {
      out.push({ mission: m, sceneTitle: mod.title, sceneSection: mod.section });
    }
  }
  return out;
}

function ensureTrailBank(trail, existingQs = []) {
  const steps = stepsOfTrail(trail);
  const byKey = new Map();
  for (const q of existingQs) {
    const sec = q.section;
    const diff = q.difficulty;
    const k = `${diff}||${sec}`;
    if (!byKey.has(k)) byKey.set(k, []);
    byKey.get(k).push(q);
  }

  // Se o banco antigo usava section de cena, redistribui para slugs de passo.
  const sceneBuckets = new Map();
  for (const q of existingQs) {
    const looksLikeMission = steps.some((s) => s.mission.slug === q.section);
    if (looksLikeMission) continue;
    const k = `${q.difficulty}||${q.section}`;
    if (!sceneBuckets.has(k)) sceneBuckets.set(k, []);
    sceneBuckets.get(k).push({ ...q });
  }

  const out = [];
  for (const { mission, sceneTitle, sceneSection } of steps) {
    for (const diff of DIFFS) {
      const key = `${diff}||${mission.slug}`;
      let pool = [...(byKey.get(key) || [])];

      if (pool.length < PER_STEP && sceneSection) {
        const sceneKey = `${diff}||${sceneSection}`;
        const leftover = sceneBuckets.get(sceneKey) || [];
        while (pool.length < PER_STEP && leftover.length) {
          const q = leftover.shift();
          q.section = mission.slug;
          q.trail = trail.slug;
          q.id = `${trail.slug.slice(0, 8)}-${diff.slice(0, 3)}-${mission.slug.slice(0, 24)}-${String(pool.length + 1).padStart(2, '0')}`;
          pool.push(q);
        }
        sceneBuckets.set(sceneKey, leftover);
      }

      // Gênesis: mapa título da cena → section antiga
      if (pool.length < PER_STEP && trail.slug === 'genesis-1-11') {
        const oldSec = SCENE_TO_GENESIS[sceneTitle];
        if (oldSec) {
          const sceneKey = `${diff}||${oldSec}`;
          const leftover = sceneBuckets.get(sceneKey) || [];
          while (pool.length < PER_STEP && leftover.length) {
            const q = leftover.shift();
            const next = { ...q, section: mission.slug, trail: trail.slug };
            next.id = `g-${diff.slice(0, 3)}-${mission.slug}-${String(pool.length + 1).padStart(2, '0')}`;
            pool.push(next);
          }
          sceneBuckets.set(sceneKey, leftover);
        }
      }

      while (pool.length < PER_STEP) {
        pool.push(synthesizeQuestion(trail.slug, diff, mission, sceneTitle, pool.length));
      }

      out.push(...pool.slice(0, PER_STEP));
    }
  }
  return out;
}

function main() {
  const trails = loadJson(trailsPath);
  const list = Array.isArray(trails) ? trails : trails.trails || [];
  const bySlug = Object.fromEntries(list.map((t) => [t.slug, t]));
  const otSlugs = loadJson(slugsPath).filter((s) => s !== 'genesis-1-11' && s !== 'exodo');

  // --- Gênesis ---
  const genesisFile = loadJson(genesisPath);
  const genesisTrail = bySlug['genesis-1-11'];
  const genesisQs = ensureTrailBank(genesisTrail, genesisFile.questions || []);
  writeJson(genesisPath, {
    ...genesisFile,
    questions: genesisQs.map(({ trail, ...rest }) => {
      // genesis asset historicamente sem trail; catalog injeta default
      void trail;
      return rest;
    }),
  });
  console.log(`genesis-1-11: ${genesisQs.length} Qs (${genesisQs.length / 15} passos × 15)`);

  // --- Êxodo ---
  const exodoTrail = bySlug.exodo;
  const exodoExisting = loadJson(exodoPath);
  const exodoArr = Array.isArray(exodoExisting) ? exodoExisting : exodoExisting.questions || [];
  const exodoQs = ensureTrailBank(exodoTrail, exodoArr);
  writeJson(exodoPath, exodoQs);
  console.log(`exodo: ${exodoQs.length} Qs`);

  // --- Restante AT ---
  const otExisting = loadJson(otPath);
  const otArr = Array.isArray(otExisting) ? otExisting : otExisting.questions || [];
  const otByTrail = new Map();
  for (const q of otArr) {
    const t = q.trail || q.trailSlug;
    if (!otByTrail.has(t)) otByTrail.set(t, []);
    otByTrail.get(t).push(q);
  }

  const otOut = [];
  for (const slug of otSlugs) {
    const trail = bySlug[slug];
    if (!trail) {
      console.warn('missing trail', slug);
      continue;
    }
    const qs = ensureTrailBank(trail, otByTrail.get(slug) || []);
    otOut.push(...qs);
    console.log(`${slug}: ${qs.length} Qs`);
  }
  writeJson(otPath, otOut);
  console.log(`\nTOTAL ot_questions: ${otOut.length}`);
  console.log(`TOTAL all banks: ${genesisQs.length + exodoQs.length + otOut.length}`);
}

main();
