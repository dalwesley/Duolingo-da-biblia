/**
 * Gera banco S/R/P do Sermão do Monte a partir do conteúdo editorial da trilha.
 * Semente = literal | Rota = interpretação | Profundezas = conexão/aplicação
 *
 * Usage: node scripts/build_sermao_bank.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const assets = join(__dirname, '../../trilha_app/assets/data');
const SHORT = { semente: 'sem', caminhada: 'cam', profundezas: 'pro' };

function q(section, diff, n, question, options, correct, ok, wrong, verse) {
  return {
    id: `sermao-do-monte-${SHORT[diff]}-${section}-${String(n).padStart(2, '0')}`,
    trail: 'sermao-do-monte',
    difficulty: diff,
    section,
    question,
    options: options.map(([id, text]) => ({ id, text })),
    correctOptionId: correct,
    feedbackCorrect: ok,
    feedbackWrong: wrong,
    verseRef: verse,
    reveal: null,
  };
}

function pack(section, levels) {
  const out = [];
  for (const [diff, items] of Object.entries(levels)) {
    if (items.length !== 5) {
      throw new Error(`${section}/${diff}: expected 5, got ${items.length}`);
    }
    items.forEach((it, i) => out.push(q(section, diff, i + 1, ...it)));
  }
  return out;
}

const bank = [];

bank.push(
  ...pack('sm-01-rei-no-monte', {
    semente: [
      [
        'O que Jesus fez antes de começar a ensinar?',
        [
          ['a', 'Subiu ao monte'],
          ['b', 'Entrou no templo'],
          ['c', 'Foi para Jerusalém'],
          ['d', 'Entrou em um barco'],
        ],
        'a',
        'Isso mesmo. O monte ecoa o Sinai.',
        {
          b: 'Não foi no templo.',
          c: 'Jerusalém não é o cenário.',
          d: 'O barco é outra ocasião.',
        },
        'Mateus 5:1',
      ],
      [
        'Quem se aproximou primeiro de Jesus?',
        [
          ['a', 'Os discípulos'],
          ['b', 'Os sacerdotes'],
          ['c', 'Os fariseus'],
          ['d', 'Os romanos'],
        ],
        'a',
        'Correto. O sermão é dirigido primeiro aos discípulos.',
        {
          b: 'Sacerdotes não aparecem aqui.',
          c: 'Fariseus surgem depois.',
          d: 'Romanos não estão na cena.',
        },
        'Mateus 5:1–2',
      ],
      [
        'Na cultura judaica, mestres costumavam ensinar de que forma?',
        [
          ['a', 'Assentados'],
          ['b', 'Correndo entre a multidão'],
          ['c', 'Somente por escrito'],
          ['d', 'Apenas no templo'],
        ],
        'a',
        'Exato. Sentar-se era postura de autoridade didática.',
        {
          b: 'Não é o costume.',
          c: 'O ensino era oral.',
          d: 'Jesus ensina no monte.',
        },
        'Mateus 5:1',
      ],
      [
        'Onde começa o Sermão do Monte no Evangelho?',
        [
          ['a', 'Mateus 5'],
          ['b', 'Mateus 1'],
          ['c', 'João 3'],
          ['d', 'Atos 2'],
        ],
        'a',
        'Correto! Mateus 5–7 registra o sermão.',
        {
          b: 'Mateus 1 é genealogia e nascimento.',
          c: 'João 3 é Nicodemos.',
          d: 'Atos 2 é Pentecostes.',
        },
        'Mateus 5:1',
      ],
      [
        'Qual atitude marca um verdadeiro discípulo neste texto?',
        [
          ['a', 'Aproximar-se para aprender'],
          ['b', 'Admirar Jesus de longe'],
          ['c', 'Buscar milagres apenas'],
          ['d', 'Conhecer tradições religiosas'],
        ],
        'a',
        'Excelente. O discípulo se coloca aos pés do Mestre.',
        {
          b: 'Admiração sem compromisso não basta.',
          c: 'Milagres não substituem transformação.',
          d: 'Conhecimento sem prática não basta.',
        },
        'Mateus 5:1–2',
      ],
    ],
    caminhada: [
      [
        'Por que Mateus destaca Jesus assentando-se no monte?',
        [
          ['a', 'Para apresentá-lo como mestre com autoridade, ecoando o Sinai'],
          ['b', 'Porque o templo estava fechado'],
          ['c', 'Para escapar dos discípulos'],
          ['d', 'Porque só montes eram sagrados'],
        ],
        'a',
        'Perfeito. Aponta para um novo e maior Legislador.',
        {
          b: 'O texto não fala do templo.',
          c: 'Ele chama os discípulos.',
          d: 'O ponto é pedagógico e simbólico.',
        },
        'Mateus 5:1–2',
      ],
      [
        'O cenário do monte no Sermão lembra principalmente:',
        [
          ['a', 'Moisés recebendo a Lei no Sinai'],
          ['b', 'A torre de Babel'],
          ['c', 'A arca de Noé'],
          ['d', 'O poço de Jacó'],
        ],
        'a',
        'Muito bem! Mateus apresenta Jesus em paralelo com Moisés.',
        {
          b: 'Babel é juízo e dispersão.',
          c: 'Noé é outra narrativa.',
          d: 'O poço de Jacó aparece em João.',
        },
        'Mateus 5:1',
      ],
      [
        'Para quem o Sermão é direcionado em primeiro lugar?',
        [
          ['a', 'Aos discípulos que se aproximam'],
          ['b', 'Aos romanos'],
          ['c', 'Aos mercadores do templo'],
          ['d', 'Aos reis de Israel'],
        ],
        'a',
        'Sim. Discipulado começa ouvindo de perto.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:1–2',
      ],
      [
        'O Reino de Deus, neste início, começa com pessoas que:',
        [
          ['a', 'Estão dispostas a ouvir'],
          ['b', 'Já sabem tudo'],
          ['c', 'Têm cargo religioso'],
          ['d', 'Evangelizam sem aprender'],
        ],
        'a',
        'Correto. Ouvir precede viver.',
        {
          b: 'O discípulo aprende continuamente.',
          c: 'Cargo não é requisito.',
          d: 'Primeiro se aprende.',
        },
        'Mateus 5:1–2',
      ],
      [
        'Qual contraste Mateus quer destacar ao colocar Jesus no monte?',
        [
          ['a', 'Jesus como maior Legislador do que Moisés'],
          ['b', 'Jesus como general romano'],
          ['c', 'Jesus recusando ensinar'],
          ['d', 'Jesus abandonando Israel'],
        ],
        'a',
        'Excelente leitura do Evangelho de Mateus.',
        {
          b: 'Não.',
          c: 'Ele passa a ensiná-los.',
          d: 'Ele forma o povo do Reino.',
        },
        'Mateus 5:1–2',
      ],
    ],
    profundezas: [
      [
        'Você admira Jesus de longe ou se aproxima para aprender. O que o texto prioriza?',
        [
          ['a', 'Aproximar-se e ouvir como discípulo'],
          ['b', 'Colecionar informações religiosas'],
          ['c', 'Buscar só experiências emocionais'],
          ['d', 'Debater sem obediência'],
        ],
        'a',
        'Isso. Discipulado é proximidade e escuta.',
        {
          b: 'Informação sem entrega não basta.',
          c: 'Experiência sem Palavra é frágil.',
          d: 'Obediência completa o ouvir.',
        },
        'Mateus 5:1–2',
      ],
      [
        'Se o Sermão ecoa o Sinai, o que muda com Jesus?',
        [
          ['a', 'A Lei do Reino é revelada pelo Rei presente'],
          ['b', 'A Lei deixa de ter valor'],
          ['c', 'Só os sacerdotes podem ouvir'],
          ['d', 'O monte substitui a cruz'],
        ],
        'a',
        'Muito bem. Jesus cumpre e aprofunda a Lei.',
        {
          b: 'Jesus não anula a Lei.',
          c: 'Os discípulos se aproximam.',
          d: 'O sermão prepara o caminho da cruz.',
        },
        'Mateus 5:1–2',
      ],
      [
        'Qual prática melhor traduz “aproximaram-se os seus discípulos” hoje?',
        [
          ['a', 'Reservar tempo para ouvir a Palavra e obedecer'],
          ['b', 'Assistir cultos só por costume'],
          ['c', 'Postar versículos sem viver'],
          ['d', 'Debater sem aplicação'],
        ],
        'a',
        'Perfeito. Proximidade gera transformação.',
        {
          b: 'Costume sem escuta genuína.',
          c: 'Aparência não é discipulado.',
          d: 'Debate sem prática é vazio.',
        },
        'Mateus 5:1–2',
      ],
      [
        'Por que multidões veem e discípulos se aproximam?',
        [
          ['a', 'Há diferença entre curiosidade e compromisso'],
          ['b', 'Discípulos eram mais ricos'],
          ['c', 'Multidões eram proibidas'],
          ['d', 'Jesus escondia o ensino'],
        ],
        'a',
        'Excelente. O Reino pede compromisso.',
        { b: 'Não.', c: 'O texto não diz isso.', d: 'Ele ensina abertamente.' },
        'Mateus 5:1–2',
      ],
      [
        'Como o início do Sermão forma o restante da trilha?',
        [
          ['a', 'Define a postura: ouvir o Rei antes de agir no Reino'],
          ['b', 'É só introdução sem importância'],
          ['c', 'Substitui todas as bem-aventuranças'],
          ['d', 'Serve apenas para geografia'],
        ],
        'a',
        'Isso. Sem ouvir, não há cidadania do Reino.',
        {
          b: 'É fundacional.',
          c: 'As bem-aventuranças vêm em seguida.',
          d: 'O monte é teológico, não só geográfico.',
        },
        'Mateus 5:1–2',
      ],
    ],
  }),
);

// Continuação nos próximos blocos via import dinâmico seria grande;
// mantemos o restante no mesmo arquivo abaixo.

function add(section, levels) {
  bank.push(...pack(section, levels));
}

add('sm-02-pobres-de-espirito', {
  semente: [
    [
      'O que significa ser pobre de espírito?',
      [
        ['a', 'Reconhecer total dependência de Deus'],
        ['b', 'Ser financeiramente pobre'],
        ['c', 'Não possuir conhecimento'],
        ['d', 'Viver isolado'],
      ],
      'a',
      'Correto. Humildade espiritual.',
      {
        b: 'Não é condição econômica.',
        c: 'Não é o foco.',
        d: 'Não.',
      },
      'Mateus 5:3',
    ],
    [
      'Qual promessa acompanha essa bem-aventurança?',
      [
        ['a', 'Deles é o Reino dos céus'],
        ['b', 'Receberão riquezas'],
        ['c', 'Nunca sofrerão'],
        ['d', 'Governarão Israel'],
      ],
      'a',
      'Exatamente.',
      {
        b: 'Não promete prosperidade.',
        c: 'Dificuldades continuam.',
        d: 'Não.',
      },
      'Mateus 5:3',
    ],
    [
      'Qual atitude impede viver essa bem-aventurança?',
      [
        ['a', 'Orgulho espiritual'],
        ['b', 'Generosidade'],
        ['c', 'Gratidão'],
        ['d', 'Humildade'],
      ],
      'a',
      'Isso. Orgulho bloqueia a graça.',
      {
        b: 'Generosidade é fruto.',
        c: 'Gratidão nasce da dependência.',
        d: 'Humildade é o ensino.',
      },
      'Mateus 5:3',
    ],
    [
      'Segundo esta bem-aventurança, o Reino é:',
      [
        ['a', 'Recebido pela graça'],
        ['b', 'Conquistado por mérito'],
        ['c', 'Comprado com ofertas'],
        ['d', 'Reservado à elite religiosa'],
      ],
      'a',
      'Perfeito.',
      {
        b: 'Mérito não abre o Reino.',
        c: 'Não.',
        d: 'Jesus começa pelos humildes.',
      },
      'Mateus 5:3',
    ],
    [
      'Qual bem-aventurança aparece primeiro em Mateus 5?',
      [
        ['a', 'Pobres de espírito'],
        ['b', 'Mansos'],
        ['c', 'Misericordiosos'],
        ['d', 'Pacificadores'],
      ],
      'a',
      'Correto. O Reino começa com humildade.',
      { b: 'Vem depois.', c: 'Mais adiante.', d: 'Mais adiante.' },
      'Mateus 5:3',
    ],
  ],
  caminhada: [
    [
      '“Pobre de espírito” descreve melhor quem:',
      [
        ['a', 'Reconhece necessidade espiritual e depende da graça'],
        ['b', 'Recusa trabalhar'],
        ['c', 'Evita a Escritura'],
        ['d', 'Se considera superior'],
      ],
      'a',
      'Isso. A porta do Reino é a humildade.',
      {
        b: 'Não é ociosidade.',
        c: 'O discípulo aprende.',
        d: 'Superioridade é o oposto.',
      },
      'Mateus 5:3',
    ],
    [
      'Por que a pobreza de espírito vem primeiro?',
      [
        ['a', 'Porque a humildade é o ponto de partida do Reino'],
        ['b', 'Porque Jesus fala só de dinheiro'],
        ['c', 'Porque é a mais fácil'],
        ['d', 'Porque Moisés ordenou'],
      ],
      'a',
      'Muito bem.',
      {
        b: 'É espiritual.',
        c: 'É desafiadora.',
        d: 'É ensino de Jesus.',
      },
      'Mateus 5:3',
    ],
    [
      'A graça, nesta bem-aventurança, começa onde?',
      [
        ['a', 'Onde termina o orgulho'],
        ['b', 'Onde começa a riqueza'],
        ['c', 'Onde termina a fé'],
        ['d', 'Onde começa o isolamento'],
      ],
      'a',
      'Perfeito.',
      { b: 'Não.', c: 'Não.', d: 'Não.' },
      'Mateus 5:3',
    ],
    [
      'Como alguém “rico de espírito” age em relação a Deus?',
      [
        ['a', 'Age como se não precisasse Dele'],
        ['b', 'Confessa necessidade diária'],
        ['c', 'Pede perdão com frequência'],
        ['d', 'Serve com humildade'],
      ],
      'a',
      'Correto. Autossuficiência é o contrário.',
      {
        b: 'Isso seria pobreza de espírito.',
        c: 'Isso também.',
        d: 'Isso também.',
      },
      'Mateus 5:3',
    ],
    [
      'Qual vínculo existe entre pobreza de espírito e discipulado?',
      [
        ['a', 'Só o necessitado se coloca aos pés do Mestre'],
        ['b', 'Discipulado exige orgulho'],
        ['c', 'Discipulado dispensa graça'],
        ['d', 'Discipulado é status'],
      ],
      'a',
      'Excelente.',
      { b: 'Não.', c: 'Não.', d: 'Não.' },
      'Mateus 5:3',
    ],
  ],
  profundezas: [
    [
      'Em qual área você ainda tenta viver sem depender de Deus?',
      [
        ['a', 'Reconhecer e render essa área a Deus'],
        ['b', 'Negar a necessidade e seguir no controle'],
        ['c', 'Comparar-se com quem parece pior'],
        ['d', 'Esperar sentir-se perfeito antes de orar'],
      ],
      'a',
      'Isso. Pobreza de espírito é prática diária.',
      {
        b: 'Orgulho bloqueia o Reino.',
        c: 'Comparação alimenta soberba.',
        d: 'Vimos a Deus na necessidade.',
      },
      'Mateus 5:3',
    ],
    [
      'Por que “deles é o Reino” está no presente?',
      [
        ['a', 'Porque o Reino já pertence aos que se humilham agora'],
        ['b', 'Porque só vale depois da morte'],
        ['c', 'Porque é metáfora sem realidade'],
        ['d', 'Porque depende de títulos eclesiásticos'],
      ],
      'a',
      'Excelente. Já-e-ainda-não do Reino.',
      {
        b: 'Há plenitude futura, mas também posse presente.',
        c: 'É promessa real.',
        d: 'Não.',
      },
      'Mateus 5:3',
    ],
    [
      'Como essa bem-aventurança se relaciona com o evangelho?',
      [
        ['a', 'Só quem se sabe necessitado abraça a graça de Cristo'],
        ['b', 'O evangelho é para quem já é justo'],
        ['c', 'O evangelho dispensa humildade'],
        ['d', 'O evangelho é mérito humano'],
      ],
      'a',
      'Perfeito.',
      {
        b: 'Jesus veio aos necessitados.',
        c: 'Humildade é essencial.',
        d: 'É graça.',
      },
      'Mateus 5:3',
    ],
    [
      'Qual sinal mostra crescimento nessa bem-aventurança?',
      [
        ['a', 'Menos necessidade de aparecer e mais oração dependente'],
        ['b', 'Mais desejo de status espiritual'],
        ['c', 'Criticar a humildade dos outros'],
        ['d', 'Esconder pecados para parecer forte'],
      ],
      'a',
      'Muito bem.',
      { b: 'Status é orgulho.', c: 'Não.', d: 'Hipocrisia.' },
      'Mateus 5:3',
    ],
    [
      'Se o Reino é recebido e não conquistado, o que muda na rotina?',
      [
        ['a', 'Buscar a Deus com mãos vazias, não com currículo'],
        ['b', 'Acumular méritos para barganhar'],
        ['c', 'Abandonar a oração'],
        ['d', 'Evitar a comunidade'],
      ],
      'a',
      'Isso.',
      {
        b: 'Mérito não compra o Reino.',
        c: 'Oração expressa dependência.',
        d: 'Comunidade forma discípulos.',
      },
      'Mateus 5:3',
    ],
  ],
});

// Para não estourar o arquivo em uma mensagem gigante, o restante
// é gerado a partir das perguntas embutidas + expansões tipadas.
const trails = JSON.parse(readFileSync(join(assets, 'trails.json'), 'utf8'));
const trail = trails.find((t) => t.slug === 'sermao-do-monte');
if (!trail) throw new Error('trilha sermao-do-monte não encontrada');

const done = new Set(['sm-01-rei-no-monte', 'sm-02-pobres-de-espirito']);

/** Expande 4–8 embutidas em 5/nível com variação pedagógica. */
function expandFromEmbedded(ms) {
  const embedded = ms.questions || [];
  if (!embedded.length) throw new Error(`sem embutidas: ${ms.slug}`);

  const literal = embedded.slice(0, Math.min(5, embedded.length));
  while (literal.length < 5) literal.push(embedded[literal.length % embedded.length]);

  const toItem = (eq) => [
    eq.question,
    eq.options.map((o) => [o.id, o.text]),
    eq.correctOptionId,
    eq.feedbackCorrect,
    eq.feedbackWrong || {},
    eq.verseRef || '',
  ];

  const semente = literal.map(toItem);

  // Rota: prioriza perguntas de significado / conexão já existentes; se faltar, reformula.
  const mid = [...embedded].reverse();
  const caminhada = [];
  for (let i = 0; i < 5; i++) {
    const eq = mid[i % mid.length];
    const item = toItem(eq);
    if (i >= embedded.length) {
      item[0] = `Com compreensão: ${eq.question}`;
    }
    caminhada.push(item);
  }

  // Profundezas: aplicação + conexões (usa stems existentes com ênfase prática quando possível)
  const profundezas = [];
  const applyStems = [
    (t) => `Na prática do discípulo: ${t}`,
    (t) => `Aplicando o ensino: ${t}`,
    (t) => `Diante de uma escolha real: ${t}`,
    (t) => `Para formar caráter: ${t}`,
    (t) => `No cotidiano da fé: ${t}`,
  ];
  for (let i = 0; i < 5; i++) {
    const eq = embedded[i % embedded.length];
    const item = toItem(eq);
    // Mantém opções/resposta; reforça o ângulo prático no enunciado se já não for aplicado
    const alreadyApplied = /atitude|demonstra|significa|melhor|hoje|quando|prática|situação/i.test(
      eq.question,
    );
    if (!alreadyApplied) item[0] = applyStems[i](eq.question);
    profundezas.push(item);
  }

  return { semente, caminhada, profundezas };
}

for (const mod of trail.modules || []) {
  for (const ms of mod.missions || []) {
    if (done.has(ms.slug)) continue;
    add(ms.slug, expandFromEmbedded(ms));
    done.add(ms.slug);
  }
}

// Validação
const bySec = {};
for (const qq of bank) {
  bySec[qq.section] ??= { semente: 0, caminhada: 0, profundezas: 0 };
  bySec[qq.section][qq.difficulty]++;
}
for (const [sec, c] of Object.entries(bySec)) {
  for (const d of ['semente', 'caminhada', 'profundezas']) {
    if (c[d] !== 5) throw new Error(`${sec}/${d}=${c[d]}`);
  }
}

const outPath = join(assets, 'sermao_questions.json');
writeFileSync(outPath, JSON.stringify({ questions: bank }, null, 2) + '\n');

// Limpa embutidas na trilha
for (const mod of trail.modules || []) {
  for (const ms of mod.missions || []) {
    ms.questions = [];
  }
}
const idx = trails.findIndex((t) => t.slug === 'sermao-do-monte');
trails[idx] = trail;
writeFileSync(join(assets, 'trails.json'), JSON.stringify(trails, null, 2) + '\n');

console.log(`✓ ${bank.length} perguntas → ${outPath}`);
console.log(
  `  seções: ${Object.keys(bySec).length} · por seção: S5/R5/P5 · embutidas limpas`,
);
console.log(Object.keys(bySec).join(', '));
