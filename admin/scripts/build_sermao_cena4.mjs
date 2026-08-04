/**
 * Cena 4 — Relações do Reino (Mateus 5:27–48)
 * Adultério do coração · Verdade · Não retaliar · Amor aos inimigos · Boss 4
 * Usage: node scripts/build_sermao_cena4.mjs
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
    if (items.length !== 5) throw new Error(`${section}/${diff}: ${items.length}`);
    items.forEach((it, i) => out.push(q(section, diff, i + 1, ...it)));
  }
  return out;
}

const module4 = {
  title: 'Relações do Reino',
  icon: '🤝',
  section: 'relacoes-do-reino',
  missions: [],
};

const missions = [
  {
    slug: 'sm-14-adulterio-do-coracao',
    title: 'Adultério do coração',
    subtitle: 'Mateus 5:27–32',
    intro:
      'A segunda antítese aprofunda o sétimo mandamento. Jesus não relaxa a ética sexual — a leva ao olhar e ao desejo. Fidelidade no Reino começa no coração e protege o casamento.',
    type: 'lesson',
    xpReward: 65,
    questions: [],
  },
  {
    slug: 'sm-15-sim-sim-nao-nao',
    title: 'Sim, sim; não, não',
    subtitle: 'Mateus 5:33–37',
    intro:
      'No Reino, a palavra do discípulo deve bastar. Jesus confronta a cultura de juramentos elaborados para mascarar a falta de integridade. Verdade simples é marca do cidadão.',
    type: 'lesson',
    xpReward: 65,
    questions: [],
  },
  {
    slug: 'sm-16-outra-face',
    title: 'A outra face',
    subtitle: 'Mateus 5:38–42',
    intro:
      '“Olho por olho” limitava a vingança — Jesus vai além: o discípulo não retribui o mal com mal. Generosidade e não retaliação revelam o caráter do Reino sob pressão.',
    type: 'lesson',
    xpReward: 65,
    questions: [],
  },
  {
    slug: 'sm-17-amor-aos-inimigos',
    title: 'Amor aos inimigos',
    subtitle: 'Mateus 5:43–48',
    intro:
      'O clímax das antíteses: amar quem nos odeia e orar por quem nos persegue. Assim o discípulo reflete o Pai, que faz o sol nascer sobre maus e bons — e é chamado à maturidade do amor.',
    type: 'lesson',
    xpReward: 70,
    questions: [],
  },
  {
    slug: 'sm-boss-04-relacoes-do-reino',
    title: 'Desafio: Relações do Reino',
    subtitle: 'Mateus 5:27–48',
    intro:
      'Desafio da Cena 4. Mostre que entendeu pureza de coração, verdade na palavra, não retaliação e o amor radical aos inimigos.',
    type: 'boss',
    xpReward: 150,
    questions: [],
  },
];

module4.missions = missions;

const studies = {
  'sm-14-adulterio-do-coracao': {
    slug: 'sm-14-adulterio-do-coracao',
    passageRef: 'Mateus 5:27–32',
    passageText:
      'Ouvistes que foi dito: Não adulterarás. Eu, porém, vos digo: qualquer que olhar para uma mulher com intenção impura, no coração já adulterou… Se o teu olho direito te faz tropeçar, arranca-o… Também foi dito: Aquele que repudiar sua mulher, dê-lhe carta de divórcio. Eu, porém, vos digo…',
    context:
      'Jesus aprofunda Êxodo 20:14. O adultério não começa só no ato — começa no olhar com desejo possessivo (epithymēsai). As imagens fortes de “arrancar o olho” e “cortar a mão” ensinam radicalidade contra o pecado, não automutilação literal. Em seguida, Jesus confronta o divórcio fácil: o casamento não é descartável; repudiar por qualquer motivo gera adultério. Pureza e fidelidade andam juntas.',
    keyword: 'Coração',
    keywordGloss:
      'Centro da vontade e do desejo; Jesus julga a intenção, não só a aparência.',
    focusQuestion:
      'Meus olhos e minha fidelidade protegem o que Deus uniu — ou negociam com o desejo?',
    reflectionPrompts: [
      'O desejo pode adulterar antes do ato',
      'Radicalidade contra o pecado, não contra o corpo',
      'Casamento exige fidelidade, não facilidade de ruptura',
    ],
    relatedVerses: [
      {
        reference: 'Êxodo 20:14',
        reason: 'O mandamento “não adulterarás” que Jesus aprofunda.',
      },
      {
        reference: 'Jó 31:1',
        reason: 'Jó fez pacto com os olhos — disciplina do olhar.',
      },
      {
        reference: 'Provérbios 6:25',
        reason: 'Não cobices a beleza no coração; não te prendam as pestanas.',
      },
      {
        reference: '1 Tessalonicenses 4:3–4',
        reason: 'A vontade de Deus é a vossa santificação.',
      },
    ],
  },
  'sm-15-sim-sim-nao-nao': {
    slug: 'sm-15-sim-sim-nao-nao',
    passageRef: 'Mateus 5:33–37',
    passageText:
      'Ouvistes que foi dito aos antigos: Não jurarás falso… Eu, porém, vos digo: de modo algum jureis… Seja, porém, a tua palavra: Sim, sim; não, não. O que passar disso vem do maligno.',
    context:
      'Na época, muitos usavam fórmulas de juramento (pelo céu, pela terra, por Jerusalém) para parecer sérios sem compromisso real. Jesus corta o atalho: o discípulo deve ser tão íntegro que a palavra simples basta. Não é proibição absoluta de todo juramento em contextos legais (cf. Paulo), mas rejeição da manipulação da verdade. Integridade > performance.',
    keyword: 'Verdade',
    keywordGloss:
      'Integridade da palavra: o sim e o não do discípulo devem bastar.',
    focusQuestion:
      'Minha palavra precisa de exageros e juramentos — ou já carrega confiança?',
    reflectionPrompts: [
      'Palavra simples revela caráter',
      'Juramento elaborado muitas vezes mascara dubiedade',
      'O excesso na fala aponta para o maligno',
    ],
    relatedVerses: [
      {
        reference: 'Tiago 5:12',
        reason: 'Eco direto: sim, sim; não, não — para não cairdes em juízo.',
      },
      {
        reference: 'Provérbios 12:22',
        reason: 'Lábios mentirosos são abomináveis ao Senhor.',
      },
      {
        reference: 'Efésios 4:25',
        reason: 'Falai a verdade cada um com o seu próximo.',
      },
      {
        reference: 'Salmo 15:1–2',
        reason: 'Quem habita no santo monte: fala a verdade no coração.',
      },
    ],
  },
  'sm-16-outra-face': {
    slug: 'sm-16-outra-face',
    passageRef: 'Mateus 5:38–42',
    passageText:
      'Ouvistes que foi dito: Olho por olho, dente por dente. Eu, porém, vos digo: não resistais ao perverso; mas, se alguém te bater na face direita, oferece-lhe também a outra… ao que te pedir, dá; ao que deseja que lhe emprestes, não voltes as costas.',
    context:
      '“Olho por olho” (Êx 21; Lv 24; Dt 19) limitava a retaliação proporcional na justiça pública — não autorizava vingança pessoal desenfreada. Jesus chama o discípulo a abrir mão do direito de revidar: outra face, capa além da túnica, segunda milha, generosidade a quem pede. Não é passividade covarde diante de toda injustiça estrutural; é renúncia à vingança e disposição de superar o mal com o bem no relacionamento pessoal.',
    keyword: 'Não retaliar',
    keywordGloss:
      'Recusar devolver mal por mal; responder com generosidade do Reino.',
    focusQuestion:
      'Quando ofendido, minha primeira reação é vingar — ou espelhar o Reino?',
    reflectionPrompts: [
      'Lei limitava vingança; Jesus transcende',
      'Segunda milha revela caráter sob pressão',
      'Generosidade é resistência ao ciclo do mal',
    ],
    relatedVerses: [
      {
        reference: 'Êxodo 21:24',
        reason: 'A lei do talião que Jesus aprofunda e transcende.',
      },
      {
        reference: 'Romanos 12:17–21',
        reason: 'Não torneis a ninguém mal por mal; vence o mal com o bem.',
      },
      {
        reference: '1 Pedro 2:23',
        reason: 'Cristo, quando ultrajado, não revidava.',
      },
      {
        reference: 'Provérbios 20:22',
        reason: 'Não digas: vingar-me-ei do mal; espera no Senhor.',
      },
    ],
  },
  'sm-17-amor-aos-inimigos': {
    slug: 'sm-17-amor-aos-inimigos',
    passageRef: 'Mateus 5:43–48',
    passageText:
      'Ouvistes que foi dito: Amarás o teu próximo e odiarás o teu inimigo. Eu, porém, vos digo: amai os vossos inimigos e orai pelos que vos perseguem… sede vós perfeitos como perfeito é o vosso Pai celeste.',
    context:
      '“Odiarás o teu inimigo” não está na Torá como mandamento — era tradição popular que distorcia “amarás o próximo” (Lv 19:18). Jesus corrige e eleva: amar inimigos e orar pelos perseguidores. O modelo é o Pai, cuja providência alcança justos e injustos. “Perfeitos” (teleioi) aponta maturidade/completude do amor — não impecabilidade instantânea. Quem ama só quem ama de volta não se diferencia; o Reino exige amor que imita Deus.',
    keyword: 'Amor',
    keywordGloss:
      'Agápē: escolha de querer o bem do outro — inclusive do inimigo — à semelhança do Pai.',
    focusQuestion:
      'Há alguém que trato como inimigo e ainda não coloquei em oração?',
    reflectionPrompts: [
      'Amar só os amigos não distingue o discípulo',
      'Oração pelos perseguidores desarma o ódio',
      'Perfeição aqui é maturidade no amor do Pai',
    ],
    relatedVerses: [
      {
        reference: 'Levítico 19:18',
        reason: 'Amarás o teu próximo — base que Jesus expande.',
      },
      {
        reference: 'Lucas 6:27–28',
        reason: 'Paralelo: amai os inimigos, fazei o bem, orai.',
      },
      {
        reference: 'Romanos 5:8',
        reason: 'Cristo morreu por nós quando ainda éramos pecadores.',
      },
      {
        reference: '1 João 4:19–21',
        reason: 'Quem não ama o irmão a quem vê não ama a Deus.',
      },
    ],
  },
};

const banks = {
  'sm-14-adulterio-do-coracao': {
    semente: [
      [
        'Que mandamento Jesus aprofunda em Mateus 5:27?',
        [
          ['a', 'Não adulterarás'],
          ['b', 'Não matarás'],
          ['c', 'Honra teu pai'],
          ['d', 'Guarda o sábado'],
        ],
        'a',
        'Correto!',
        { b: 'Isso foi na antítese anterior.', c: 'Não.', d: 'Não.' },
        'Mateus 5:27',
      ],
      [
        'Segundo Jesus, adultério no coração começa quando alguém:',
        [
          ['a', 'Olha com intenção impura / desejo cobiçoso'],
          ['b', 'Apenas cumprimenta'],
          ['c', 'Lê a Lei'],
          ['d', 'Ora em público'],
        ],
        'a',
        'Exato.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:28',
      ],
      [
        '“Arranca o olho / corta a mão” ensina principalmente:',
        [
          ['a', 'Ser radical contra o pecado que faz tropeçar'],
          ['b', 'Automutilação literal obrigatória'],
          ['c', 'Que o corpo é mau'],
          ['d', 'Que casamento é proibido'],
        ],
        'a',
        'Muito bem. É hipérbole pedagógica.',
        { b: 'Não é literalismo.', c: 'O corpo é criação de Deus.', d: 'Não.' },
        'Mateus 5:29–30',
      ],
      [
        'Sobre repudiar a mulher, Jesus ensina que o divórcio fácil:',
        [
          ['a', 'Não é o padrão do Reino e gera adultério'],
          ['b', 'É sempre obrigatório'],
          ['c', 'Não importa para Deus'],
          ['d', 'Só vale para líderes'],
        ],
        'a',
        'Correto.',
        { b: 'Não.', c: 'Importa.', d: 'Aplica-se a todos.' },
        'Mateus 5:31–32',
      ],
      [
        'O centro dessa antítese é:',
        [
          ['a', 'Pureza e fidelidade que começam no coração'],
          ['b', 'Regras de vestimenta'],
          ['c', 'Impostos do templo'],
          ['d', 'Genealogia'],
        ],
        'a',
        'Isso.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:27–32',
      ],
    ],
    caminhada: [
      [
        'Por que Jesus fala do olhar e não só do ato?',
        [
          ['a', 'Porque a justiça do Reino alcança a intenção'],
          ['b', 'Porque o ato não importa'],
          ['c', 'Porque fariseus ignoravam o olhar'],
          ['d', 'Porque só o olhar é pecado'],
        ],
        'a',
        'Excelente.',
        {
          b: 'O ato também importa.',
          c: 'Alguns eram externos; Jesus aprofunda para todos.',
          d: 'Ambos importam.',
        },
        'Mateus 5:28',
      ],
      [
        'Como Jó 31:1 ecoa este ensino?',
        [
          ['a', 'Disciplina do olhar como pacto de pureza'],
          ['b', 'Jó proibia casamento'],
          ['c', 'Olhos não importam'],
          ['d', 'Só mulheres precisam de pureza'],
        ],
        'a',
        'Muito bem.',
        { b: 'Não.', c: 'Importam.', d: 'É para todos.' },
        'Jó 31:1',
      ],
      [
        'A hipérbole do olho/mão NÃO significa:',
        [
          ['a', 'Que Deus exige automutilação física'],
          ['b', 'Que o pecado deve ser cortado com seriedade'],
          ['c', 'Que é melhor perder algo do que cair'],
          ['d', 'Que o tropeço tem custo eterno sério'],
        ],
        'a',
        'Correto.',
        { b: 'Isso é o ponto.', c: 'Isso é o ponto.', d: 'Isso é o ponto.' },
        'Mateus 5:29–30',
      ],
      [
        'Por que Jesus liga desejo cobiçoso e divórcio fácil?',
        [
          ['a', 'Ambos ferem a fidelidade que Deus exige'],
          ['b', 'São temas sem relação'],
          ['c', 'Divórcio cancela o desejo'],
          ['d', 'Só o desejo importa'],
        ],
        'a',
        'Perfeito.',
        { b: 'Estão no mesmo bloco ético.', c: 'Não.', d: 'Ambos importam.' },
        'Mateus 5:27–32',
      ],
      [
        'Qual contraste com a justiça só externa?',
        [
          ['a', 'Aparência limpa com coração cobiçoso não basta'],
          ['b', 'Só importa a reputação'],
          ['c', 'Deus não vê o íntimo'],
          ['d', 'Regras externas são inúteis'],
        ],
        'a',
        'Isso.',
        {
          b: 'Deus vê o coração.',
          c: 'Vê.',
          d: 'Não são inúteis — são insuficientes sozinhas.',
        },
        'Mateus 5:20,28',
      ],
    ],
    profundezas: [
      [
        'No celular, contentes que alimentam desejo cobiçoso pedem:',
        [
          ['a', 'Cortar a fonte do tropeço com radicalidade prática'],
          ['b', 'Continuar “só olhando”'],
          ['c', 'Culpar só a cultura sem mudar hábitos'],
          ['d', 'Negar que o olhar importa'],
        ],
        'a',
        'Isso. Arrancar o que faz tropeçar.',
        { b: 'Jesus confronta.', c: 'Responsabilidade pessoal.', d: 'Importa.' },
        'Mateus 5:28–29',
      ],
      [
        'Como 1 Tessalonicenses 4:3–4 aprofunda o tema?',
        [
          ['a', 'Santificação inclui posse do próprio corpo em santidade'],
          ['b', 'Santidade é só ritual'],
          ['c', 'Corpo não importa'],
          ['d', 'Desejo nunca precisa de disciplina'],
        ],
        'a',
        'Excelente.',
        { b: 'É ética de vida.', c: 'Importa.', d: 'Precisa.' },
        '1 Tessalonicenses 4:3–4',
      ],
      [
        'Fidelidade matrimonial no Reino inclui:',
        [
          ['a', 'Olhar, desejo, compromisso e rejeição do descarte fácil'],
          ['b', 'Só o papel de casamento'],
          ['c', 'Liberdade total sem limites'],
          ['d', 'Aparência pública apenas'],
        ],
        'a',
        'Perfeito.',
        { b: 'Insuficiente.', c: 'Não.', d: 'Insuficiente.' },
        'Mateus 5:27–32',
      ],
      [
        'O que NÃO é aplicação fiel deste texto?',
        [
          ['a', 'Envergonhar alguém com legalismo cruel sem graça'],
          ['b', 'Confessar e buscar pureza'],
          ['c', 'Proteger o casamento'],
          ['d', 'Disciplinar o olhar'],
        ],
        'a',
        'Correto. Jesus aprofunda com verdade e chamado à vida.',
        { b: 'Isso é.', c: 'Isso é.', d: 'Isso é.' },
        'Mateus 5:27–32',
      ],
      [
        'Por que este bloco vem depois de “ira e reconciliação”?',
        [
          ['a', 'As antíteses mostram justiça que alcança coração e relações'],
          ['b', 'São temas aleatórios'],
          ['c', 'Só ética sexual importa'],
          ['d', 'Lei foi abolida'],
        ],
        'a',
        'Muito bem.',
        { b: 'Há progressão.', c: 'Há mais antíteses.', d: 'Jesus cumpre, não abole.' },
        'Mateus 5:21–32',
      ],
    ],
  },

  'sm-15-sim-sim-nao-nao': {
    semente: [
      [
        'Qual deve ser a palavra do discípulo, segundo Jesus?',
        [
          ['a', 'Sim, sim; não, não'],
          ['b', 'Juramentos longos'],
          ['c', 'Promessas vagas'],
          ['d', 'Silêncio absoluto'],
        ],
        'a',
        'Correto!',
        { b: 'Jesus rejeita o excesso.', c: 'Não.', d: 'Não.' },
        'Mateus 5:37',
      ],
      [
        'Jesus diz para não jurar:',
        [
          ['a', 'De modo algum (pelo céu, terra, Jerusalém…)'],
          ['b', 'Apenas no templo'],
          ['c', 'Só aos sábados'],
          ['d', 'Nunca falar'],
        ],
        'a',
        'Exato.',
        { b: 'É mais amplo.', c: 'Não.', d: 'Não.' },
        'Mateus 5:34–36',
      ],
      [
        'O que passa do “sim, sim; não, não” vem:',
        [
          ['a', 'Do maligno'],
          ['b', 'Do Espírito'],
          ['c', 'Dos anjos'],
          ['d', 'Da Torá'],
        ],
        'a',
        'Correto.',
        { b: 'Não.', c: 'Não.', d: 'Não é o ponto aqui.' },
        'Mateus 5:37',
      ],
      [
        'O problema central que Jesus confronta é:',
        [
          ['a', 'Falta de integridade na palavra'],
          ['b', 'Falta de rituais'],
          ['c', 'Excesso de estudo'],
          ['d', 'Jejuar demais'],
        ],
        'a',
        'Isso.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:33–37',
      ],
      [
        'Jurar pelo céu é inadequado, segundo Jesus, porque o céu é:',
        [
          ['a', 'O trono de Deus'],
          ['b', 'Propriedade romana'],
          ['c', 'Ilusão'],
          ['d', 'Só metáfora sem valor'],
        ],
        'a',
        'Muito bem.',
        { b: 'Não.', c: 'Não.', d: 'Tem valor — por isso não se usa assim.' },
        'Mateus 5:34',
      ],
    ],
    caminhada: [
      [
        'Por que fórmulas elaboradas de juramento eram problemáticas?',
        [
          ['a', 'Podiam mascarar compromisso frágil com aparência de seriedade'],
          ['b', 'Porque falar é pecado'],
          ['c', 'Porque Deus odeia qualquer promessa'],
          ['d', 'Porque só fariseus podiam jurar'],
        ],
        'a',
        'Excelente.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:33–37',
      ],
      [
        'Como Tiago 5:12 ecoa Jesus?',
        [
          ['a', 'Repete sim/sim, não/não para não cairdes em juízo'],
          ['b', 'Manda jurar sempre'],
          ['c', 'Cancela a ética da palavra'],
          ['d', 'Fala só de dinheiro'],
        ],
        'a',
        'Correto.',
        { b: 'Contrário.', c: 'Não.', d: 'Não.' },
        'Tiago 5:12',
      ],
      [
        'Integridade da palavra no Reino significa:',
        [
          ['a', 'Ser confiável sem precisar “reforçar” com exageros'],
          ['b', 'Nunca fazer planos'],
          ['c', 'Mentir com elegância'],
          ['d', 'Prometer e não cumprir'],
        ],
        'a',
        'Perfeito.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:37',
      ],
      [
        'Qual NÃO é o ponto principal do texto?',
        [
          ['a', 'Proibir todo contrato legal em qualquer contexto'],
          ['b', 'Exigir verdade simples do discípulo'],
          ['c', 'Rejeitar manipulação da fala'],
          ['d', 'Confrontar dubiedade moral'],
        ],
        'a',
        'Isso. O alvo é integridade, não casuística jurídica.',
        { b: 'É o ponto.', c: 'É o ponto.', d: 'É o ponto.' },
        'Mateus 5:33–37',
      ],
      [
        'Efésios 4:25 conecta-se assim:',
        [
          ['a', 'Falar a verdade faz parte do novo homem'],
          ['b', 'Verdade é opcional'],
          ['c', 'Mentira edifica a igreja'],
          ['d', 'Só líderes precisam de verdade'],
        ],
        'a',
        'Muito bem.',
        { b: 'Não.', c: 'Não.', d: 'Todos.' },
        'Efésios 4:25',
      ],
    ],
    profundezas: [
      [
        'No trabalho, “sim” que vira “talvez” crônico pede:',
        [
          ['a', 'Alinhar palavra e ação — sim que se cumpre'],
          ['b', 'Mais juramentos dramáticos'],
          ['c', 'Mais desculpas elaboradas'],
          ['d', 'Culpar só a agenda'],
        ],
        'a',
        'Isso.',
        { b: 'Jesus rejeita.', c: 'Não resolve.', d: 'Responsabilidade pessoal.' },
        'Mateus 5:37',
      ],
      [
        'Como Salmo 15 liga-se a este ensino?',
        [
          ['a', 'Quem habita com Deus fala a verdade no coração'],
          ['b', 'Culto dispensa ética'],
          ['c', 'Verdade é só doutrina'],
          ['d', 'Palavra não importa'],
        ],
        'a',
        'Excelente.',
        { b: 'Não.', c: 'É vida.', d: 'Importa.' },
        'Salmo 15:1–2',
      ],
      [
        'Exagerar promessas para impressionar revela:',
        [
          ['a', 'Falha de confiança na simples verdade'],
          ['b', 'Espiritualidade madura'],
          ['c', 'Obediência a Mt 5:37'],
          ['d', 'Fruto do Espírito'],
        ],
        'a',
        'Correto.',
        { b: 'Não.', c: 'Contrário.', d: 'Não.' },
        'Mateus 5:37',
      ],
      [
        'Prática fiel desta antítese inclui:',
        [
          ['a', 'Cumprir o que promete e corrigir quando falha'],
          ['b', 'Nunca admitir erro'],
          ['c', 'Prometer sem intenção'],
          ['d', 'Usar “juro por Deus” o tempo todo'],
        ],
        'a',
        'Perfeito.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:37',
      ],
      [
        'Por que a verdade da palavra importa para sal e luz?',
        [
          ['a', 'Testemunho sem integridade perde o sabor'],
          ['b', 'Sal não tem a ver com caráter'],
          ['c', 'Luz é só discurso'],
          ['d', 'Ética verbal é secundária'],
        ],
        'a',
        'Muito bem.',
        { b: 'Tem.', c: 'É vida.', d: 'É central neste bloco.' },
        'Mateus 5:13–16,37',
      ],
    ],
  },

  'sm-16-outra-face': {
    semente: [
      [
        'Qual ditado Jesus cita em Mateus 5:38?',
        [
          ['a', 'Olho por olho, dente por dente'],
          ['b', 'Olho por olho, mão por mão'],
          ['c', 'Dente por ouro'],
          ['d', 'Vida por vida apenas'],
        ],
        'a',
        'Correto!',
        { b: 'A fórmula clássica é olho/dente.', c: 'Não.', d: 'Incompleto.' },
        'Mateus 5:38',
      ],
      [
        'Se alguém bater na face direita, Jesus manda:',
        [
          ['a', 'Oferecer também a outra'],
          ['b', 'Revidar na hora'],
          ['c', 'Processar imediatamente'],
          ['d', 'Fugir da fé'],
        ],
        'a',
        'Exato.',
        { b: 'Não.', c: 'Não é o ponto aqui.', d: 'Não.' },
        'Mateus 5:39',
      ],
      [
        'Se alguém obrigar a andar uma milha, o discípulo:',
        [
          ['a', 'Vai com ele duas'],
          ['b', 'Recusa sempre'],
          ['c', 'Pede três de volta'],
          ['d', 'Ignora o próximo'],
        ],
        'a',
        'Correto.',
        { b: 'Jesus vai além.', c: 'Não.', d: 'Não.' },
        'Mateus 5:41',
      ],
      [
        'Diante de quem pede, Jesus ensina:',
        [
          ['a', 'Dá; e ao que quer emprestar, não voltes as costas'],
          ['b', 'Nunca ajude'],
          ['c', 'Ajude só amigos'],
          ['d', 'Ajude só se houver lucro'],
        ],
        'a',
        'Muito bem.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:42',
      ],
      [
        'O movimento desta antítese é:',
        [
          ['a', 'Da retaliação limitada à generosidade do Reino'],
          ['b', 'Da graça à vingança'],
          ['c', 'Do amor ao ódio'],
          ['d', 'Da Lei à anarquia'],
        ],
        'a',
        'Isso.',
        { b: 'Contrário.', c: 'Contrário.', d: 'Não.' },
        'Mateus 5:38–42',
      ],
    ],
    caminhada: [
      [
        'Qual era a função original do “olho por olho” na Lei?',
        [
          ['a', 'Limitar a vingança proporcional na justiça'],
          ['b', 'Incentivar ódio pessoal'],
          ['c', 'Abolir qualquer julgamento'],
          ['d', 'Justificar crueldade infinita'],
        ],
        'a',
        'Excelente.',
        { b: 'Limitava.', c: 'Não.', d: 'Não.' },
        'Êxodo 21:24',
      ],
      [
        'Jesus NÃO está ensinando:',
        [
          ['a', 'Que o cristão nunca pode buscar justiça pública'],
          ['b', 'Renúncia à vingança pessoal'],
          ['c', 'Generosidade sob ofensa'],
          ['d', 'Superar o ciclo do mal'],
        ],
        'a',
        'Correto. O foco é ética pessoal do discípulo.',
        { b: 'É o ponto.', c: 'É o ponto.', d: 'É o ponto.' },
        'Mateus 5:38–42',
      ],
      [
        'Como Romanos 12:17–21 ecoa este texto?',
        [
          ['a', 'Não retribuir mal com mal; vencer o mal com o bem'],
          ['b', 'Vingar-se com sabedoria'],
          ['c', 'Odiar o inimigo'],
          ['d', 'Ignorar o próximo'],
        ],
        'a',
        'Perfeito.',
        { b: 'Contrário.', c: 'Contrário.', d: 'Não.' },
        'Romanos 12:17–21',
      ],
      [
        'A “segunda milha” ilustra:',
        [
          ['a', 'Disposição de ir além do exigido, com espírito do Reino'],
          ['b', 'Obrigação militar eterna'],
          ['c', 'Fraqueza moral'],
          ['d', 'Desprezo pela justiça'],
        ],
        'a',
        'Muito bem.',
        { b: 'É imagem ética.', c: 'É força sob controle.', d: 'Não.' },
        'Mateus 5:41',
      ],
      [
        '1 Pedro 2:23 aponta para:',
        [
          ['a', 'Cristo como modelo de quem não revidava ultrajes'],
          ['b', 'Cristo vingativo'],
          ['c', 'Passividade sem confiança no Pai'],
          ['d', 'Indiferença ao sofrimento'],
        ],
        'a',
        'Excelente.',
        { b: 'Não.', c: 'Ele confiou ao Pai.', d: 'Não.' },
        '1 Pedro 2:23',
      ],
    ],
    profundezas: [
      [
        'Ofendido nas redes, aplicar “outra face” pode significar:',
        [
          ['a', 'Não alimentar o ciclo de insultos; responder com dignidade'],
          ['b', 'Destruir a reputação do outro'],
          ['c', 'Repetir o insulto com mais força'],
          ['d', 'Negar que houve ofensa sempre'],
        ],
        'a',
        'Isso.',
        { b: 'É retaliação.', c: 'É retaliação.', d: 'Há discernimento, sem vingança.' },
        'Mateus 5:39',
      ],
      [
        'Generosidade a quem pede exige também:',
        [
          ['a', 'Discernimento amoroso — sem endurecer o coração'],
          ['b', 'Dar a todo golpe sem sabedoria'],
          ['c', 'Nunca ajudar'],
          ['d', 'Ajudar só por aparência'],
        ],
        'a',
        'Perfeito.',
        { b: 'Sabedoria faz parte do amor.', c: 'Jesus manda dar.', d: 'Motivo importa.' },
        'Mateus 5:42',
      ],
      [
        'Como esta antítese prepara o amor aos inimigos?',
        [
          ['a', 'Quebra a lógica da retribuição antes do clímax do amor'],
          ['b', 'Não tem ligação'],
          ['c', 'Ensina ódio primeiro'],
          ['d', 'Cancela o próximo bloco'],
        ],
        'a',
        'Excelente progressão.',
        { b: 'Há progressão.', c: 'Não.', d: 'Não.' },
        'Mateus 5:38–48',
      ],
      [
        'Qual postura NÃO reflete o Reino aqui?',
        [
          ['a', 'Guardar rancor e esperar a chance de revidar'],
          ['b', 'Abrir mão do direito de vingar'],
          ['c', 'Oferecer generosidade sob pressão'],
          ['d', 'Confiar a justiça a Deus'],
        ],
        'a',
        'Correto.',
        { b: 'É o ponto.', c: 'É o ponto.', d: 'É o ponto.' },
        'Mateus 5:38–42',
      ],
      [
        '“Não resistais ao perverso” no contexto aponta para:',
        [
          ['a', 'Não retaliar pessoalmente ao ofensor'],
          ['b', 'Aprovar toda injustiça social'],
          ['c', 'Nunca proteger o fraco'],
          ['d', 'Odiar a Lei'],
        ],
        'a',
        'Muito bem.',
        { b: 'Não é o sentido.', c: 'Não.', d: 'Não.' },
        'Mateus 5:39',
      ],
    ],
  },

  'sm-17-amor-aos-inimigos': {
    semente: [
      [
        'O que Jesus manda fazer aos inimigos?',
        [
          ['a', 'Amai-os e orai pelos que vos perseguem'],
          ['b', 'Odeiai-os em silêncio'],
          ['c', 'Ignorai-os para sempre'],
          ['d', 'Vingai-os depois'],
        ],
        'a',
        'Correto!',
        { b: 'Contrário.', c: 'Há mais: amar e orar.', d: 'Não.' },
        'Mateus 5:44',
      ],
      [
        'Por que amar só quem nos ama não basta?',
        [
          ['a', 'Até publicanos fazem isso — não distingue o discípulo'],
          ['b', 'Porque amigos são maus'],
          ['c', 'Porque Jesus proíbe amizades'],
          ['d', 'Porque o Pai odeia os justos'],
        ],
        'a',
        'Exato.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:46–47',
      ],
      [
        'O Pai faz o sol nascer:',
        [
          ['a', 'Sobre maus e bons'],
          ['b', 'Só sobre os justos'],
          ['c', 'Só sobre Israel'],
          ['d', 'Nunca sobre inimigos'],
        ],
        'a',
        'Correto.',
        { b: 'Sobre todos.', c: 'Não.', d: 'Não.' },
        'Mateus 5:45',
      ],
      [
        '“Sede perfeitos” neste texto aponta para:',
        [
          ['a', 'Maturidade/completude no amor, como o Pai'],
          ['b', 'Nunca errar em nada desde hoje'],
          ['c', 'Ser anjo'],
          ['d', 'Abandonar a graça'],
        ],
        'a',
        'Muito bem.',
        { b: 'Teleios = maduro/completo.', c: 'Não.', d: 'Não.' },
        'Mateus 5:48',
      ],
      [
        'A frase “odiarás o teu inimigo” no ditado popular:',
        [
          ['a', 'Não é mandamento da Torá — era distorção'],
          ['b', 'Está em Êxodo 20'],
          ['c', 'É ordem de Moisés clara'],
          ['d', 'É o centro do Shemá'],
        ],
        'a',
        'Isso.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:43',
      ],
    ],
    caminhada: [
      [
        'Como Levítico 19:18 se relaciona com este ensino?',
        [
          ['a', 'Jesus expande “amarás o próximo” até o inimigo'],
          ['b', 'Jesus cancela o próximo'],
          ['c', 'Levítico manda odiar'],
          ['d', 'Não há relação'],
        ],
        'a',
        'Excelente.',
        { b: 'Não.', c: 'Não.', d: 'Há.' },
        'Levítico 19:18',
      ],
      [
        'Orar pelos perseguidores serve para:',
        [
          ['a', 'Desarmar o ódio e alinhar o coração ao Pai'],
          ['b', 'Pedir maldição'],
          ['c', 'Evitar qualquer ação justa'],
          ['d', 'Substituir o evangelho'],
        ],
        'a',
        'Perfeito.',
        { b: 'É oração de amor.', c: 'Não.', d: 'Não.' },
        'Mateus 5:44',
      ],
      [
        'Romanos 5:8 mostra o modelo porque:',
        [
          ['a', 'Cristo amou inimigos — morreu por pecadores'],
          ['b', 'Cristo só amou amigos'],
          ['c', 'Deus espera mérito primeiro'],
          ['d', 'Amor divino exclui inimigos'],
        ],
        'a',
        'Muito bem.',
        { b: 'Contrário.', c: 'Graça precede.', d: 'Não.' },
        'Romanos 5:8',
      ],
      [
        'O que diferencia o cidadão do Reino aqui?',
        [
          ['a', 'Amor que imita a generosidade do Pai aos indignos'],
          ['b', 'Amor exclusivo ao círculo íntimo'],
          ['c', 'Ódio santo aos rivais'],
          ['d', 'Neutralidade absoluta'],
        ],
        'a',
        'Isso.',
        { b: 'Insuficiente.', c: 'Não.', d: 'Há amor ativo.' },
        'Mateus 5:45–48',
      ],
      [
        'Lucas 6:27–28 confirma:',
        [
          ['a', 'Amar, fazer o bem e orar pelos que maltratam'],
          ['b', 'Só amar em teoria'],
          ['c', 'Vingar com oração'],
          ['d', 'Ignorar perseguidores'],
        ],
        'a',
        'Correto.',
        { b: 'Há ação.', c: 'Não.', d: 'Não.' },
        'Lucas 6:27–28',
      ],
    ],
    profundezas: [
      [
        'Há alguém que trato como inimigo e ainda não orei por ele?',
        [
          ['a', 'Começar a orar — passo concreto do Reino'],
          ['b', 'Esperar sentimento primeiro'],
          ['c', 'Justificar o ódio'],
          ['d', 'Publicar acusações'],
        ],
        'a',
        'Isso. Amor age antes do sentimento perfeito.',
        { b: 'Obediência precede.', c: 'Não.', d: 'Não.' },
        'Mateus 5:44',
      ],
      [
        'Como 1 João 4:19–21 pressiona a aplicação?',
        [
          ['a', 'Amor a Deus se prova no amor concreto ao outro'],
          ['b', 'Dá para amar a Deus odiando o próximo'],
          ['c', 'Amor é só emoção'],
          ['d', 'Inimigos estão fora da ética cristã'],
        ],
        'a',
        'Excelente.',
        { b: 'João nega isso.', c: 'É escolha e ação.', d: 'Jesus inclui.' },
        '1 João 4:19–21',
      ],
      [
        '“Perfeitos como o Pai” NÃO significa:',
        [
          ['a', 'Impecabilidade instantânea sem crescimento'],
          ['b', 'Buscar maturidade no amor'],
          ['c', 'Imitar a generosidade divina'],
          ['d', 'Completar o amor além do círculo fácil'],
        ],
        'a',
        'Correto.',
        { b: 'É o sentido.', c: 'É o sentido.', d: 'É o sentido.' },
        'Mateus 5:48',
      ],
      [
        'Em conflito familiar antigo, amor ao “inimigo” pode ser:',
        [
          ['a', 'Buscar o bem dele sem negar a verdade, e orar'],
          ['b', 'Fingir que nada aconteceu sempre'],
          ['c', 'Retaliar em silêncio'],
          ['d', 'Cortar toda dignidade do outro'],
        ],
        'a',
        'Perfeito.',
        { b: 'Há reconciliação sábia.', c: 'É ódio.', d: 'Não é amor.' },
        'Mateus 5:44–48',
      ],
      [
        'Por que este é o clímax das antíteses de Mateus 5?',
        [
          ['a', 'Leva a justiça do Reino ao amor que imita o próprio Deus'],
          ['b', 'É o texto mais fácil'],
          ['c', 'Cancela as bem-aventuranças'],
          ['d', 'Só vale para mártires'],
        ],
        'a',
        'Excelente síntese.',
        { b: 'É o mais exigente.', c: 'Não.', d: 'Para todo discípulo.' },
        'Mateus 5:43–48',
      ],
    ],
  },

  'sm-boss-04-relacoes-do-reino': {
    semente: [
      [
        'Adultério do coração, segundo Jesus, envolve:',
        [
          ['a', 'Olhar com desejo cobiçoso'],
          ['b', 'Apenas o ato público'],
          ['c', 'Só divórcio'],
          ['d', 'Só palavras'],
        ],
        'a',
        'Correto.',
        { b: 'Começa antes.', c: 'Há mais no bloco.', d: 'Não só.' },
        'Mateus 5:28',
      ],
      [
        'A marca da palavra no Reino é:',
        [
          ['a', 'Sim, sim; não, não'],
          ['b', 'Juramentos elaborados'],
          ['c', 'Promessas vazias'],
          ['d', 'Exagero constante'],
        ],
        'a',
        'Isso.',
        { b: 'Rejeitados.', c: 'Não.', d: 'Não.' },
        'Mateus 5:37',
      ],
      [
        '“Olho por olho” no Sermão é:',
        [
          ['a', 'Citado para ser transcendido pela não retaliação'],
          ['b', 'O ideal final de Jesus'],
          ['c', 'Cancelado sem sentido'],
          ['d', 'Ordem de vingança pessoal'],
        ],
        'a',
        'Correto.',
        { b: 'Jesus vai além.', c: 'Há aprofundamento.', d: 'Não.' },
        'Mateus 5:38–39',
      ],
      [
        'Jesus manda amar:',
        [
          ['a', 'Os inimigos'],
          ['b', 'Só os amigos'],
          ['c', 'Só a família'],
          ['d', 'Só os justos'],
        ],
        'a',
        'Exato.',
        { b: 'Além disso.', c: 'Além disso.', d: 'Além disso.' },
        'Mateus 5:44',
      ],
      [
        'O modelo do amor aos inimigos é:',
        [
          ['a', 'O Pai celeste'],
          ['b', 'Roma'],
          ['c', 'Os publicanos'],
          ['d', 'A vingança'],
        ],
        'a',
        'Muito bem.',
        { b: 'Não.', c: 'São contraste.', d: 'Não.' },
        'Mateus 5:45–48',
      ],
    ],
    caminhada: [
      [
        'O fio das antíteses 5:27–48 é:',
        [
          ['a', 'Justiça que alcança desejo, palavra, ofensa e inimizade'],
          ['b', 'Só regras de culto'],
          ['c', 'Abolição total da ética'],
          ['d', 'Nacionalismo'],
        ],
        'a',
        'Excelente.',
        { b: 'É relacional/ético.', c: 'Não.', d: 'Não.' },
        'Mateus 5:27–48',
      ],
      [
        'Pureza de olhar e amor ao inimigo se conectam porque:',
        [
          ['a', 'Ambos exigem coração transformado, não só rótulo religioso'],
          ['b', 'Não se conectam'],
          ['c', 'Um cancela o outro'],
          ['d', 'Só o olhar importa'],
        ],
        'a',
        'Perfeito.',
        { b: 'Há unidade.', c: 'Não.', d: 'Há mais.' },
        'Mateus 5:28,44',
      ],
      [
        'Integridade da palavra sustenta relações porque:',
        [
          ['a', 'Sem confiança verbal, comunidade e testemunho ruem'],
          ['b', 'Palavra não importa'],
          ['c', 'Mentira edifica'],
          ['d', 'Só sentimentos importam'],
        ],
        'a',
        'Isso.',
        { b: 'Importa.', c: 'Não.', d: 'Não só.' },
        'Mateus 5:37',
      ],
      [
        'Não retaliar prepara o amor aos inimigos ao:',
        [
          ['a', 'Quebrar a lógica de devolver o mal'],
          ['b', 'Ensinar indiferença'],
          ['c', 'Justificar ódio'],
          ['d', 'Eliminar a oração'],
        ],
        'a',
        'Muito bem.',
        { b: 'Há amor ativo depois.', c: 'Não.', d: 'Não.' },
        'Mateus 5:38–44',
      ],
      [
        '“Perfeitos” resume a cena como:',
        [
          ['a', 'Chamado à maturidade do amor que imita o Pai'],
          ['b', 'Orgulho espiritual'],
          ['c', 'Dispensa da graça'],
          ['d', 'Só doutrina abstrata'],
        ],
        'a',
        'Excelente.',
        { b: 'Não.', c: 'Não.', d: 'É vida.' },
        'Mateus 5:48',
      ],
    ],
    profundezas: [
      [
        'Se domino doutrina mas cultivo desejo cobiçoso e rancor, falta:',
        [
          ['a', 'Justiça do Reino no coração e nas relações'],
          ['b', 'Mais informação só'],
          ['c', 'Mais juramentos'],
          ['d', 'Mais vingança'],
        ],
        'a',
        'Isso.',
        { b: 'Insuficiente.', c: 'Não.', d: 'Não.' },
        'Mateus 5:27–48',
      ],
      [
        'Qual prática une Cena 4?',
        [
          ['a', 'Tratar o outro — e o próprio desejo — sob o olhar do Pai'],
          ['b', 'Isolar-se de todos'],
          ['c', 'Vencer debates'],
          ['d', 'Colecionar ofensas'],
        ],
        'a',
        'Perfeito.',
        { b: 'Relações importam.', c: 'Não.', d: 'Não.' },
        'Mateus 5:27–48',
      ],
      [
        'Como as Cenas 1–4 formam arco?',
        [
          [
            'a',
            'Identidade → caráter → missão → relações transformadas pelo Reino',
          ],
          ['b', 'Só milagres'],
          ['c', 'Só genealogia'],
          ['d', 'Só juízo sem graça'],
        ],
        'a',
        'Excelente progressão.',
        { b: 'Incompleto.', c: 'Não.', d: 'Há graça e exigência.' },
        'Mateus 5:1–48',
      ],
      [
        'Amar inimigos sem pureza de coração vira:',
        [
          ['a', 'Performance externa sem transformação interior'],
          ['b', 'Obediência plena'],
          ['c', 'Meta do Sermão'],
          ['d', 'Fruto automático'],
        ],
        'a',
        'Correto. As antíteses andam juntas.',
        { b: 'Falta o interior.', c: 'Falta integração.', d: 'Não.' },
        'Mateus 5:28,44',
      ],
      [
        'Próximo passo fiel após esta cena:',
        [
          [
            'a',
            'Examinar olhar, palavra, retaliação e orar por um “inimigo”',
          ],
          ['b', 'Arquivar o Sermão'],
          ['c', 'Comparar-se com fariseus e parar'],
          ['d', 'Esperar sentimento perfeito para agir'],
        ],
        'a',
        'Muito bem.',
        { b: 'Continua vivo.', c: 'Não.', d: 'Obediência age.' },
        'Mateus 5:27–48',
      ],
    ],
  },
};

let bank = [];
for (const [section, levels] of Object.entries(banks)) {
  bank = bank.concat(pack(section, levels));
}

const trails = JSON.parse(readFileSync(join(assets, 'trails.json'), 'utf8'));
const trail = trails.find((t) => t.slug === 'sermao-do-monte');
const existingIdx = trail.modules.findIndex((m) => m.section === 'relacoes-do-reino');
if (existingIdx >= 0) trail.modules[existingIdx] = module4;
else trail.modules.push(module4);
writeFileSync(join(assets, 'trails.json'), JSON.stringify(trails, null, 2) + '\n');

const studiesData = JSON.parse(readFileSync(join(assets, 'mission_studies.json'), 'utf8'));
Object.assign(studiesData.studies, studies);
Object.assign(studiesData.verses || (studiesData.verses = {}), {
  'Mateus 5:27–32': studies['sm-14-adulterio-do-coracao'].passageText,
  'Mateus 5:27': 'Ouvistes que foi dito: Não adulterarás.',
  'Mateus 5:28':
    'Eu, porém, vos digo: qualquer que olhar para uma mulher com intenção impura, no coração já adulterou com ela.',
  'Mateus 5:29–30':
    'Se o teu olho direito te faz tropeçar, arranca-o…; se a tua mão direita te faz tropeçar, corta-a…',
  'Mateus 5:31–32':
    'Também foi dito: Aquele que repudiar sua mulher, dê-lhe carta de divórcio. Eu, porém, vos digo…',
  'Mateus 5:33–37': studies['sm-15-sim-sim-nao-nao'].passageText,
  'Mateus 5:34': 'Eu, porém, vos digo: de modo algum jureis; nem pelo céu, por ser o trono de Deus.',
  'Mateus 5:34–36':
    'De modo algum jureis; nem pelo céu… nem pela terra… nem por Jerusalém… nem jures pela tua cabeça…',
  'Mateus 5:37':
    'Seja, porém, a tua palavra: Sim, sim; não, não. O que passar disso vem do maligno.',
  'Mateus 5:38–42': studies['sm-16-outra-face'].passageText,
  'Mateus 5:38': 'Ouvistes que foi dito: Olho por olho, dente por dente.',
  'Mateus 5:39':
    'Eu, porém, vos digo: não resistais ao perverso; mas, se alguém te bater na face direita, oferece-lhe também a outra.',
  'Mateus 5:41': 'Se alguém te obrigar a andar uma milha, vai com ele duas.',
  'Mateus 5:42':
    'Dá a quem te pede e não voltes as costas ao que deseja que lhe emprestes.',
  'Mateus 5:43–48': studies['sm-17-amor-aos-inimigos'].passageText,
  'Mateus 5:43': 'Ouvistes que foi dito: Amarás o teu próximo e odiarás o teu inimigo.',
  'Mateus 5:44': 'Eu, porém, vos digo: amai os vossos inimigos e orai pelos que vos perseguem.',
  'Mateus 5:45':
    '… para que vos torneis filhos do vosso Pai celeste, porque ele faz nascer o seu sol sobre maus e bons…',
  'Mateus 5:46–47':
    'Porque, se amardes os que vos amam, que recompensa tendes? … Não fazem os gentios as mesmas coisas?',
  'Mateus 5:48': 'Portanto, sede vós perfeitos como perfeito é o vosso Pai celeste.',
  'Mateus 5:27–48':
    'Adultério do coração… sim, sim; não, não… outra face… amai os inimigos… sede perfeitos.',
  'Mateus 5:1–48': 'Das bem-aventuranças ao amor que imita o Pai.',
  'Mateus 5:20,28':
    'Se a vossa justiça não exceder… qualquer que olhar… no coração já adulterou.',
  'Mateus 5:21–32': 'Ira e reconciliação… adultério do coração e fidelidade.',
  'Mateus 5:28,44': 'Olhar com desejo… amai os vossos inimigos.',
  'Mateus 5:13–16,37': 'Sal e luz… seja a tua palavra: Sim, sim; não, não.',
  'Mateus 5:38–44': 'Não retaliar… amai os inimigos.',
  'Mateus 5:38–48': 'Outra face… amor aos inimigos.',
  'Mateus 5:45–48': 'Sol sobre maus e bons… sede perfeitos.',
  'Êxodo 20:14': 'Não adulterarás.',
  'Êxodo 21:24': 'Olho por olho, dente por dente…',
  'Jó 31:1': 'Fiz pacto com os meus olhos; como, pois, os fixaria numa donzela?',
  'Provérbios 6:25':
    'Não cobices no teu coração a sua formosura, nem te prendam as suas pestanas.',
  '1 Tessalonicenses 4:3–4':
    'Porquanto esta é a vontade de Deus: a vossa santificação… que cada um de vós saiba possuir o próprio corpo em santificação e honra.',
  'Tiago 5:12':
    'Antes de tudo, meus irmãos, não jureis… Seja, porém, a vossa palavra: sim, sim e não, não…',
  'Provérbios 12:22': 'Os lábios mentirosos são abomináveis ao Senhor…',
  'Efésios 4:25': 'Por isso, deixando a mentira, fale cada um a verdade com o seu próximo…',
  'Salmo 15:1–2':
    'Quem, Senhor, habitará no teu tabernáculo? … O que anda com integridade, e pratica a justiça, e com o seu coração fala a verdade.',
  'Romanos 12:17–21':
    'Não torneis a ninguém mal por mal… Não vos vingueis… vence o mal com o bem.',
  '1 Pedro 2:23':
    'Pois ele, quando ultrajado, não revidava; quando padecia, não ameaçava…',
  'Provérbios 20:22': 'Não digas: Vingar-me-ei do mal; espera pelo Senhor, e ele te livrará.',
  'Levítico 19:18': '… amarás o teu próximo como a ti mesmo. Eu sou o Senhor.',
  'Lucas 6:27–28':
    'Amai os vossos inimigos, fazei o bem aos que vos odeiam; bendizei… orai pelos que vos maltratam.',
  'Romanos 5:8':
    'Mas Deus prova o seu próprio amor para conosco pelo fato de ter Cristo morrido por nós, sendo nós ainda pecadores.',
  '1 João 4:19–21':
    'Nós amamos porque ele nos amou primeiro… quem não ama a seu irmão, a quem vê, não pode amar a Deus, a quem não vê.',
});
writeFileSync(join(assets, 'mission_studies.json'), JSON.stringify(studiesData, null, 2) + '\n');

const bankPath = join(assets, 'sermao_questions.json');
const bankData = JSON.parse(readFileSync(bankPath, 'utf8'));
const drop = new Set(Object.keys(banks));
bankData.questions = bankData.questions.filter((qq) => !drop.has(qq.section));
bankData.questions.push(...bank);
writeFileSync(bankPath, JSON.stringify(bankData, null, 2) + '\n');

console.log('Cena 4:', module4.missions.map((m) => m.slug).join(' → '));
console.log(`+${bank.length} perguntas · banco total ${bankData.questions.length}`);
console.log(`estudos: ${Object.keys(studies).join(', ')}`);
