/**
 * Cenas 5–6 — Vida diante do Pai e Decisões do discípulo (Mateus 6–7)
 * Piedade secreta · Confiança · Discernimento · Caminho estreito · Bosses 5 e 6
 * Usage: node scripts/build_sermao_cena5_7.mjs
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

const module5 = {
  title: 'Vida diante do Pai',
  icon: '🙏',
  section: 'vida-diante-do-pai',
  missions: [],
};

const module6 = {
  title: 'Decisões do discípulo',
  icon: '🪨',
  section: 'decisoes-do-discipulo',
  missions: [],
};

const missions5 = [
  {
    slug: 'sm-18-esmola-secreta',
    title: 'Esmola secreta',
    subtitle: 'Mateus 6:1–4',
    intro:
      'Jesus confronta a justiça feita para ser admirada. A generosidade do Reino socorre o necessitado diante do Pai, não diante de uma plateia. O Pai que vê em secreto conhece o coração e recompensa com justiça.',
    type: 'lesson',
    xpReward: 65,
    questions: [],
  },
  {
    slug: 'sm-19-pai-nosso',
    title: 'Pai nosso',
    subtitle: 'Mateus 6:5–15',
    intro:
      'Oração não é palco nem técnica para controlar Deus. Jesus nos leva ao secreto e nos dá um modelo: o Pai é santo, seu Reino vem primeiro, dependemos dele diariamente e perdoamos porque fomos alcançados por perdão.',
    type: 'lesson',
    xpReward: 70,
    questions: [],
  },
  {
    slug: 'sm-20-jejum-secreto',
    title: 'Jejum secreto',
    subtitle: 'Mateus 6:16–18',
    intro:
      'Jejuar não é anunciar tristeza para ganhar reconhecimento. Jesus chama o discípulo a buscar o Pai com sinceridade, sem transformar disciplina espiritual em identidade pública ou moeda de aprovação.',
    type: 'lesson',
    xpReward: 65,
    questions: [],
  },
  {
    slug: 'sm-21-tesouros-e-ansiedade',
    title: 'Tesouros e ansiedade',
    subtitle: 'Mateus 6:19–34',
    intro:
      'Onde colocamos o tesouro, colocamos o coração. Jesus expõe o olhar dividido, a escravidão a Mamom e a ansiedade pelo amanhã, chamando-nos a buscar primeiro o Reino e confiar no cuidado do Pai.',
    type: 'lesson',
    xpReward: 75,
    questions: [],
  },
  {
    slug: 'sm-boss-05-vida-diante-do-pai',
    title: 'Desafio: Vida diante do Pai',
    subtitle: 'Mateus 6:1–34',
    intro:
      'Desafio da Cena 5. Mostre que entendeu a piedade que o Pai vê, a oração que busca seu Reino e a confiança que vence a ansiedade e a idolatria do tesouro.',
    type: 'boss',
    xpReward: 150,
    questions: [],
  },
];

const missions6 = [
  {
    slug: 'sm-22-nao-julgueis',
    title: 'Não julgueis',
    subtitle: 'Mateus 7:1–6',
    intro:
      'Jesus proíbe a postura hipócrita que condena o outro sem examinar o próprio pecado. Ele não elimina o discernimento: depois de tirar a trave do próprio olho, o discípulo enxerga para servir com humildade e sabedoria.',
    type: 'lesson',
    xpReward: 65,
    questions: [],
  },
  {
    slug: 'sm-23-pedir-buscar-bater',
    title: 'Pedir, buscar, bater',
    subtitle: 'Mateus 7:7–12',
    intro:
      'O discípulo persevera em oração porque conhece o Pai bom. Deus não é uma máquina de desejos, mas um Pai que dá boas dádivas aos seus filhos. Essa confiança transborda na regra de ouro.',
    type: 'lesson',
    xpReward: 65,
    questions: [],
  },
  {
    slug: 'sm-24-porta-estreita',
    title: 'A porta estreita',
    subtitle: 'Mateus 7:13–14',
    intro:
      'Jesus encerra o Sermão exigindo uma decisão. A porta estreita e o caminho apertado não prometem facilidade, mas conduzem à vida. O caminho largo parece amplo, porém termina em perdição.',
    type: 'lesson',
    xpReward: 65,
    questions: [],
  },
  {
    slug: 'sm-25-frutos-e-casa',
    title: 'Frutos e casa na rocha',
    subtitle: 'Mateus 7:15–27',
    intro:
      'Nem toda voz religiosa vem de Deus, e nem toda confissão é obediência. Jesus manda discernir pelos frutos e termina com duas casas: ouvir suas palavras e praticá-las é construir sobre a rocha.',
    type: 'lesson',
    xpReward: 75,
    questions: [],
  },
  {
    slug: 'sm-boss-06-sermao-completo',
    title: 'Desafio final: Sermão completo',
    subtitle: 'Mateus 5–7',
    intro:
      'Desafio final do Sermão do Monte. Reveja o arco inteiro: identidade do Reino, justiça do coração, vida diante do Pai e a decisão de ouvir Jesus e praticar suas palavras.',
    type: 'boss',
    xpReward: 200,
    questions: [],
  },
];

module5.missions = missions5;
module6.missions = missions6;

const studies = {
  'sm-18-esmola-secreta': {
    slug: 'sm-18-esmola-secreta',
    passageRef: 'Mateus 6:1–4',
    passageText:
      'Guardai-vos de exercer a vossa justiça diante dos homens, com o fim de serdes vistos por eles… Tu, porém, ao dares a esmola, ignore a tua mão esquerda o que faz a tua mão direita; para que a tua esmola fique em secreto; e teu Pai, que vê em secreto, te recompensará.',
    context:
      'Jesus não contradiz Mateus 5:16, onde boas obras levam outros a glorificar o Pai. Aqui ele confronta o motivo: fazer justiça para receber aplauso. As trombetas retratam a religiosidade performática; a mão esquerda que não sabe da direita é uma figura para generosidade sem autopropaganda. O Pai vê tanto a necessidade do pobre quanto o coração de quem dá.',
    keyword: 'Secreto',
    keywordGloss: 'Piedade orientada ao Pai, livre da busca de reconhecimento humano.',
    focusQuestion: 'Minha generosidade socorre pessoas ou alimenta minha imagem?',
    reflectionPrompts: [
      'O alvo da justiça é agradar o Pai',
      'Generosidade não precisa de plateia',
      'O Pai vê o que a multidão não vê',
    ],
    relatedVerses: [
      { reference: 'Mateus 5:16', reason: 'Boas obras visíveis devem glorificar o Pai, não o praticante.' },
      { reference: 'Provérbios 19:17', reason: 'Quem se compadece do pobre empresta ao Senhor.' },
      { reference: '2 Coríntios 9:7', reason: 'Deus ama quem dá com alegria, não por ostentação.' },
    ],
  },
  'sm-19-pai-nosso': {
    slug: 'sm-19-pai-nosso',
    passageRef: 'Mateus 6:5–15',
    passageText:
      'Tu, porém, quando orares, entra no teu quarto… porque teu Pai sabe de que tendes necessidade… Portanto, vós orareis assim: Pai nosso, que estás nos céus, santificado seja o teu nome; venha o teu Reino…',
    context:
      'Jesus corrige dois desvios: oração como espetáculo diante das pessoas e repetição vazia como tentativa de pressionar Deus. O Pai nosso não é uma fórmula mágica, mas um modelo de prioridades: nome de Deus, Reino e vontade; pão diário, perdão e livramento. A oração começa em Deus e forma uma comunidade que depende, perdoa e vive diante do Pai.',
    keyword: 'Pai',
    keywordGloss: 'Deus santo e próximo, que conhece as necessidades de seus filhos.',
    focusQuestion: 'Minhas orações buscam primeiro o nome, o Reino e a vontade do Pai?',
    reflectionPrompts: [
      'O Pai conhece necessidades antes das palavras',
      'O Reino vem antes dos pedidos pessoais',
      'Quem recebe perdão é chamado a perdoar',
    ],
    relatedVerses: [
      { reference: 'Lucas 11:1–4', reason: 'Paralelo do ensino de Jesus sobre a oração.' },
      { reference: 'Filipenses 4:6–7', reason: 'Pedidos são apresentados a Deus com oração e gratidão.' },
      { reference: 'Efésios 4:32', reason: 'Perdoamos como Deus nos perdoou em Cristo.' },
      { reference: '1 João 5:14', reason: 'Confiança para pedir segundo a vontade de Deus.' },
    ],
  },
  'sm-20-jejum-secreto': {
    slug: 'sm-20-jejum-secreto',
    passageRef: 'Mateus 6:16–18',
    passageText:
      'Quando jejuardes, não vos mostreis contristados como os hipócritas… Tu, porém, quando jejuares, unge a cabeça e lava o rosto, com o fim de não parecer aos homens que jejuas, e sim ao teu Pai, em secreto.',
    context:
      'Jesus pressupõe que seus discípulos jejuarão (“quando”), mas condena a aparência abatida usada para anunciar devoção. Ungir a cabeça e lavar o rosto comunicam simplicidade: o jejum é busca sincera diante de Deus, não performance religiosa. A disciplina não compra favor divino; ela expressa dependência, arrependimento e foco no Pai.',
    keyword: 'Jejum',
    keywordGloss: 'Disciplina de abster-se para buscar a Deus, não para exibir espiritualidade.',
    focusQuestion: 'Minhas disciplinas espirituais me levam ao Pai ou à necessidade de parecer espiritual?',
    reflectionPrompts: [
      'Jejum não é anúncio de superioridade',
      'O Pai vê a devoção que ninguém aplaude',
      'Disciplina sem humildade vira performance',
    ],
    relatedVerses: [
      { reference: 'Isaías 58:6–7', reason: 'Deus rejeita jejum vazio e chama à justiça e misericórdia.' },
      { reference: 'Joel 2:12–13', reason: 'O retorno a Deus é de todo o coração, não só exterior.' },
      { reference: 'Atos 13:2–3', reason: 'A igreja jejuava e orava no serviço ao Senhor.' },
    ],
  },
  'sm-21-tesouros-e-ansiedade': {
    slug: 'sm-21-tesouros-e-ansiedade',
    passageRef: 'Mateus 6:19–34',
    passageText:
      'Não acumuleis para vós outros tesouros sobre a terra… mas ajuntai tesouros no céu… Ninguém pode servir a dois senhores… Não andeis ansiosos pela vossa vida… buscai, pois, em primeiro lugar, o seu Reino e a sua justiça.',
    context:
      'Jesus une tesouro, visão, senhorio e ansiedade porque todos revelam o que governa o coração. Bens terrenos são frágeis; o olho “bom” é uma visão generosa e íntegra; Mamom é riqueza tratada como senhor rival. Jesus não chama à irresponsabilidade, mas à confiança: o Pai alimenta aves e veste flores. Buscar primeiro o Reino reorganiza o presente e entrega o amanhã a Deus.',
    keyword: 'Reino',
    keywordGloss: 'Governo de Deus que redefine prioridades, segurança e uso dos recursos.',
    focusQuestion: 'O que meu dinheiro, meu olhar e minhas preocupações revelam sobre meu senhor?',
    reflectionPrompts: [
      'O tesouro puxa o coração',
      'Não há neutralidade entre Deus e Mamom',
      'O Pai cuida; o discípulo busca primeiro o Reino',
    ],
    relatedVerses: [
      { reference: 'Colossenses 3:1–2', reason: 'Buscar as coisas do alto orienta os afetos.' },
      { reference: '1 Timóteo 6:6–10', reason: 'A piedade com contentamento confronta o amor ao dinheiro.' },
      { reference: 'Filipenses 4:19', reason: 'Deus supre as necessidades segundo suas riquezas.' },
      { reference: '1 Pedro 5:7', reason: 'Lançamos sobre Deus toda ansiedade porque ele cuida de nós.' },
    ],
  },
  'sm-22-nao-julgueis': {
    slug: 'sm-22-nao-julgueis',
    passageRef: 'Mateus 7:1–6',
    passageText:
      'Não julgueis, para que não sejais julgados… Por que vês tu o argueiro no olho de teu irmão, porém não reparas na trave que está no teu próprio? … tira primeiro a trave do teu olho e, então, verás claramente para tirar o argueiro do olho de teu irmão.',
    context:
      '“Não julgueis” não cancela toda avaliação moral: o próprio texto pede discernimento sobre o que é santo e, adiante, sobre falsos profetas. Jesus condena o julgamento condenatório, orgulhoso e hipócrita. A trave e o argueiro expõem a desproporção de corrigir sem arrependimento próprio. Quem primeiro se examina pode ajudar o irmão com clareza, mansidão e discernimento.',
    keyword: 'Discernimento',
    keywordGloss: 'Avaliar com verdade e humildade, sem ocupar o lugar de juiz hipócrita.',
    focusQuestion: 'Antes de corrigir alguém, tenho tratado meu próprio pecado diante de Deus?',
    reflectionPrompts: [
      'Hipocrisia amplia o pecado do outro e esconde o próprio',
      'Autoexame vem antes de correção fraterna',
      'Amor humilde não dispensa discernimento',
    ],
    relatedVerses: [
      { reference: 'Romanos 2:1–3', reason: 'Quem julga o outro deve considerar a própria prática.' },
      { reference: 'Gálatas 6:1', reason: 'Restauração deve ser feita com espírito de mansidão.' },
      { reference: 'João 7:24', reason: 'Jesus manda julgar com reta justiça, não pela aparência.' },
    ],
  },
  'sm-23-pedir-buscar-bater': {
    slug: 'sm-23-pedir-buscar-bater',
    passageRef: 'Mateus 7:7–12',
    passageText:
      'Pedi, e dar-se-vos-á; buscai e achareis; batei, e abrir-se-vos-á… Ora, se vós, que sois maus, sabeis dar boas dádivas aos vossos filhos, quanto mais vosso Pai celeste dará boas coisas aos que lhe pedirem.',
    context:
      'Os verbos “pedir, buscar e bater” convocam perseverança confiante, não insistência que obriga Deus. O argumento vai de pais humanos imperfeitos ao Pai perfeito: se eles não entregam pedra ou serpente a filhos famintos, Deus dá o que é bom. A regra de ouro conclui o bloco: quem confia no Pai trata os outros com a mesma misericórdia que deseja receber.',
    keyword: 'Pedir',
    keywordGloss: 'Aproximar-se continuamente do Pai com confiança filial e submissão.',
    focusQuestion: 'Minha perseverança em oração confia na bondade do Pai ou tenta controlá-lo?',
    reflectionPrompts: [
      'Oração persevera porque o Pai é bom',
      'Boas dádivas vêm da sabedoria de Deus',
      'A regra de ouro transforma oração em relacionamento',
    ],
    relatedVerses: [
      { reference: 'Lucas 11:9–13', reason: 'Paralelo que destaca o dom do Espírito Santo.' },
      { reference: 'Tiago 1:5', reason: 'Deus dá sabedoria liberalmente a quem pede.' },
      { reference: '1 João 5:14–15', reason: 'Deus ouve pedidos conforme sua vontade.' },
      { reference: 'Levítico 19:18', reason: 'Amar o próximo é a base da regra de ouro.' },
    ],
  },
  'sm-24-porta-estreita': {
    slug: 'sm-24-porta-estreita',
    passageRef: 'Mateus 7:13–14',
    passageText:
      'Entrai pela porta estreita (larga é a porta, e espaçoso, o caminho que conduz para a perdição, e são muitos os que entram por ela), porque estreita é a porta, e apertado, o caminho que conduz para a vida, e são poucos os que acertam com ela.',
    context:
      'Depois de ensinar o caminho do Reino, Jesus exige resposta. A porta estreita não é elitismo humano ou salvação por desempenho; é o chamado a entrar pelo caminho de Cristo, que confronta autonomia e pecado. O caminho largo acomoda desejos e multidões, mas sua aparência fácil não muda seu fim. O discípulo não escolhe pela popularidade, e sim pela vida que Jesus oferece.',
    keyword: 'Estreita',
    keywordGloss: 'O caminho definido por Jesus, que não se adapta à autonomia e ao pecado.',
    focusQuestion: 'Estou escolhendo o caminho de Jesus mesmo quando ele não é o mais fácil ou popular?',
    reflectionPrompts: [
      'Nem todo caminho popular conduz à vida',
      'A decisão pelo Reino é real e urgente',
      'Jesus chama à fidelidade, não à facilidade',
    ],
    relatedVerses: [
      { reference: 'João 14:6', reason: 'Jesus se apresenta como o caminho, a verdade e a vida.' },
      { reference: 'Lucas 13:23–24', reason: 'Jesus chama a esforçar-se por entrar pela porta estreita.' },
      { reference: 'Deuteronômio 30:19–20', reason: 'A Escritura coloca diante do povo vida e morte.' },
    ],
  },
  'sm-25-frutos-e-casa': {
    slug: 'sm-25-frutos-e-casa',
    passageRef: 'Mateus 7:15–27',
    passageText:
      'Acautelai-vos dos falsos profetas… pelos seus frutos os conhecereis… Nem todo o que me diz: Senhor, Senhor! entrará no Reino dos céus, mas aquele que faz a vontade de meu Pai… Todo aquele, pois, que ouve estas minhas palavras e as pratica será comparado a um homem prudente que edificou a sua casa sobre a rocha.',
    context:
      'Jesus oferece dois testes de autenticidade: frutos e obediência. Falsos profetas podem parecer ovelhas, mas sua mensagem e sua vida revelam o que são. Uma confissão verbal, até acompanhada de feitos impressionantes, não substitui fazer a vontade do Pai. A rocha não é mera informação sobre Jesus: é ouvir suas palavras e praticá-las. As tempestades revelam o fundamento.',
    keyword: 'Rocha',
    keywordGloss: 'Fundamento firme de quem ouve Jesus e responde com obediência.',
    focusQuestion: 'Minha fé é só linguagem religiosa ou permanece quando a tempestade prova o fundamento?',
    reflectionPrompts: [
      'Fruto revela o que aparência pode esconder',
      '“Senhor, Senhor” sem obediência não basta',
      'Ouvir Jesus pede prática perseverante',
    ],
    relatedVerses: [
      { reference: 'Deuteronômio 13:1–4', reason: 'Sinais não validam quem desvia o povo do Senhor.' },
      { reference: 'Tiago 1:22', reason: 'Sejam praticantes da palavra, não somente ouvintes.' },
      { reference: '1 João 2:3–4', reason: 'Conhecer a Deus se evidencia em guardar seus mandamentos.' },
      { reference: 'Efésios 2:8–10', reason: 'A salvação é pela graça e produz boas obras preparadas por Deus.' },
    ],
  },
};

const wrong = (b, c, d) => ({ b, c, d });

const banks = {
  'sm-18-esmola-secreta': {
    semente: [
      ['Jesus adverte contra praticar justiça para:', [['a', 'Ser visto pelos homens'], ['b', 'Socorrer o pobre'], ['c', 'Honrar o Pai'], ['d', 'Servir com alegria']], 'a', 'Correto!', wrong('O problema é a busca de aplauso.', 'Esse deve ser o alvo.', 'Isso não exige ostentação.'), 'Mateus 6:1'],
      ['Ao dar esmola, Jesus orienta o discípulo a fazê-lo:', [['a', 'Em secreto'], ['b', 'Tocando trombeta'], ['c', 'Diante da sinagoga'], ['d', 'Para receber elogios']], 'a', 'Exato.', wrong('É a imagem da ostentação.', 'Jesus confronta esse palco.', 'Essa é a recompensa dos hipócritas.'), 'Mateus 6:2–4'],
      ['Quem vê a esmola feita em secreto?', [['a', 'O Pai'], ['b', 'A multidão'], ['c', 'Somente o doador'], ['d', 'Nenhuma pessoa']], 'a', 'Muito bem.', wrong('A multidão não é o alvo.', 'O Pai também vê.', 'Deus vê o que é secreto.'), 'Mateus 6:4'],
      ['A expressão sobre a mão esquerda e a direita enfatiza:', [['a', 'Generosidade sem autopropaganda'], ['b', 'Uma regra literal de postura'], ['c', 'Dar apenas com uma mão'], ['d', 'Esconder ajuda do necessitado']], 'a', 'Isso.', wrong('É uma figura de linguagem.', 'Não é uma técnica corporal.', 'Jesus não proíbe socorrer pessoas.'), 'Mateus 6:3'],
      ['A recompensa buscada pelo hipócrita é:', [['a', 'O louvor humano'], ['b', 'A aprovação do Pai'], ['c', 'A transformação do pobre'], ['d', 'A justiça do Reino']], 'a', 'Correto.', wrong('O Pai recompensa o secreto.', 'Isso não é a motivação condenada.', 'O alvo do hipócrita é aparecer.'), 'Mateus 6:2'],
    ],
    caminhada: [
      ['Mateus 5:16 e 6:1 se harmonizam porque:', [['a', 'Boas obras glorificam o Pai, não o praticante'], ['b', 'Toda obra deve ser escondida'], ['c', 'Jesus proíbe boas obras públicas'], ['d', 'O motivo não importa']], 'a', 'Excelente.', wrong('O texto trata do motivo, não de uma regra absoluta.', 'Jesus manda a luz brilhar.', 'O Pai vê o coração.'), 'Mateus 5:16; 6:1'],
      ['“Tocar trombeta” descreve principalmente:', [['a', 'Piedade transformada em espetáculo'], ['b', 'Um mandamento de culto'], ['c', 'Uma música de gratidão'], ['d', 'Uma oferta obrigatória']], 'a', 'Perfeito.', wrong('Jesus usa a imagem para confrontar vaidade.', 'Gratidão não é o problema.', 'O alvo é a honra humana.'), 'Mateus 6:2'],
      ['Dar em secreto não significa:', [['a', 'Deixar de atender o necessitado'], ['b', 'Examinar o próprio motivo'], ['c', 'Recusar a vaidade religiosa'], ['d', 'Confiar que o Pai vê']], 'a', 'Muito bem.', wrong('Isso é parte da aplicação.', 'Isso é o contraste.', 'Essa é a promessa de Jesus.'), 'Mateus 6:1–4'],
      ['A justiça que Jesus condena é a que busca:', [['a', 'Construir uma imagem religiosa'], ['b', 'Agradar o Pai'], ['c', 'Amar o próximo'], ['d', 'Praticar misericórdia']], 'a', 'Correto.', wrong('Esse é o alvo correto.', 'Misericórdia é boa.', 'O problema é ser visto.'), 'Mateus 6:1'],
      ['A generosidade do Reino é melhor descrita como:', [['a', 'Misericórdia orientada pelo Pai'], ['b', 'Investimento em reputação'], ['c', 'Forma de comprar perdão'], ['d', 'Prova de superioridade']], 'a', 'Excelente.', wrong('Jesus confronta isso.', 'A graça não é comprada.', 'Isso é hipocrisia.'), 'Mateus 6:1–4'],
    ],
    profundezas: [
      ['Publicar cada doação para receber elogios pede:', [['a', 'Reexaminar o coração diante do Pai'], ['b', 'Parar de ser generoso'], ['c', 'Buscar mais seguidores'], ['d', 'Culpar quem agradece']], 'a', 'Isso.', wrong('O problema não é ajudar.', 'Aumenta a tentação de aparecer.', 'O exame começa em nós.'), 'Mateus 6:1–4'],
      ['Por que a recompensa humana é insuficiente?', [['a', 'Ela troca a honra do Pai por aplauso passageiro'], ['b', 'Deus não vê obras'], ['c', 'O pobre não importa'], ['d', 'Toda gratidão é errada']], 'a', 'Muito bem.', wrong('O Pai vê em secreto.', 'O necessitado importa.', 'O problema é buscar aplauso.'), 'Mateus 6:1–4'],
      ['Uma prática fiel de generosidade inclui:', [['a', 'Servir pessoas sem fazer delas vitrine'], ['b', 'Anunciar cada ajuda'], ['c', 'Exigir reconhecimento'], ['d', 'Dar para controlar outros']], 'a', 'Correto.', wrong('Isso replica a trombeta.', 'Esse não é o alvo.', 'Generosidade não manipula.'), 'Mateus 6:2–4'],
      ['O Pai que vê em secreto revela que:', [['a', 'A fidelidade não depende de plateia'], ['b', 'Deus ignora o pobre'], ['c', 'Só atos invisíveis têm valor'], ['d', 'Recompensa é salário comprado']], 'a', 'Perfeito.', wrong('Ele vê o necessitado e o coração.', 'O ponto é o motivo.', 'Não se compra o favor de Deus.'), 'Mateus 6:4'],
      ['Qual síntese expressa esta missão?', [['a', 'Dar para agradar o Pai, não construir a própria fama'], ['b', 'Dar para ser admirado'], ['c', 'Evitar toda misericórdia'], ['d', 'Transformar a fé em vitrine']], 'a', 'Excelente síntese.', wrong('É o contraste de Jesus.', 'Misericórdia permanece necessária.', 'Jesus confronta essa religião.'), 'Mateus 6:1–4'],
    ],
  },
  'sm-19-pai-nosso': {
    semente: [
      ['Ao orar, Jesus orienta o discípulo a buscar:', [['a', 'O Pai em secreto'], ['b', 'A atenção das praças'], ['c', 'Muitas palavras'], ['d', 'A admiração pública']], 'a', 'Correto!', wrong('Jesus condena oração para aparecer.', 'O Pai sabe antes de pedirmos.', 'Oração não é palco.'), 'Mateus 6:5–8'],
      ['A primeira petição do Pai nosso é:', [['a', 'Santificado seja o teu nome'], ['b', 'Dá-me riqueza'], ['c', 'Vence meus rivais'], ['d', 'Aumenta minha fama']], 'a', 'Exato.', wrong('A oração começa com Deus.', 'Não é a primeira prioridade.', 'O centro não é o ego.'), 'Mateus 6:9'],
      ['“Venha o teu Reino” pede:', [['a', 'O governo de Deus'], ['b', 'Meu controle total'], ['c', 'Uma vida sem obediência'], ['d', 'Poder sobre outros']], 'a', 'Muito bem.', wrong('A oração se submete a Deus.', 'O Reino chama à obediência.', 'Não é ambição pessoal.'), 'Mateus 6:10'],
      ['“O pão nosso de cada dia” expressa:', [['a', 'Dependência diária do Pai'], ['b', 'Autossuficiência'], ['c', 'Desprezo pelo corpo'], ['d', 'Garantia de luxo']], 'a', 'Isso.', wrong('A petição reconhece necessidade.', 'Deus cuida das necessidades.', 'Jesus fala de provisão, não luxo.'), 'Mateus 6:11'],
      ['Jesus liga o perdão recebido ao chamado para:', [['a', 'Perdoar os outros'], ['b', 'Guardar rancor'], ['c', 'Negar o pecado'], ['d', 'Comprar salvação']], 'a', 'Correto.', wrong('Isso contradiz a oração.', 'Pecado é sério.', 'Perdão é graça, não moeda.'), 'Mateus 6:12,14–15'],
    ],
    caminhada: [
      ['Jesus rejeita vãs repetições porque:', [['a', 'O Pai conhece as necessidades dos filhos'], ['b', 'Deus não ouve oração'], ['c', 'Palavras são sempre inúteis'], ['d', 'Só líderes podem orar']], 'a', 'Excelente.', wrong('Jesus ensina a orar.', 'O problema é a repetição vazia.', 'O Pai recebe seus filhos.'), 'Mateus 6:7–8'],
      ['“Seja feita a tua vontade” forma a oração como:', [['a', 'Submissão confiante a Deus'], ['b', 'Técnica para controlá-lo'], ['c', 'Busca de autopromoção'], ['d', 'Fórmula mágica']], 'a', 'Perfeito.', wrong('Deus não é manipulável.', 'O centro é o Pai.', 'Jesus confronta formalismo vazio.'), 'Mateus 6:10'],
      ['O “nosso” no Pai nosso lembra que a oração:', [['a', 'Forma uma comunidade dependente'], ['b', 'É apenas individualista'], ['c', 'Dispensa o próximo'], ['d', 'Pertence só aos fortes']], 'a', 'Muito bem.', wrong('Jesus ensina pedidos compartilhados.', 'Perdão e pão envolvem comunidade.', 'Todos dependem do Pai.'), 'Mateus 6:9–13'],
      ['Pedir livramento do mal expressa:', [['a', 'Dependência diante da tentação e do mal'], ['b', 'Confiança em mérito próprio'], ['c', 'Desejo de pecar sem consequência'], ['d', 'Medo de se aproximar de Deus']], 'a', 'Correto.', wrong('A oração busca ajuda do Pai.', 'Jesus chama a resistir ao mal.', 'O Pai é acessível.'), 'Mateus 6:13'],
      ['A ordem do Pai nosso mostra que:', [['a', 'A glória e a vontade de Deus vêm antes das necessidades pessoais'], ['b', 'Nossas necessidades não importam'], ['c', 'Só se deve pedir coisas espirituais'], ['d', 'Deus não cuida do cotidiano']], 'a', 'Excelente.', wrong('O pão diário é pedido real.', 'Jesus inclui provisão e perdão.', 'O Pai conhece necessidades.'), 'Mateus 6:9–13'],
    ],
    profundezas: [
      ['Orar apenas para impressionar pessoas revela:', [['a', 'Que a oração virou performance'], ['b', 'Fé madura'], ['c', 'Confiança filial'], ['d', 'Busca do Reino']], 'a', 'Isso.', wrong('Jesus chama ao secreto.', 'O Pai, não a plateia, é o alvo.', 'O Reino não é aparência.'), 'Mateus 6:5–6'],
      ['Pedir pão diário confronta a ilusão de:', [['a', 'Autossuficiência'], ['b', 'Que Deus é Pai'], ['c', 'Que necessidades existem'], ['d', 'Que devemos agradecer']], 'a', 'Muito bem.', wrong('A oração se dirige ao Pai.', 'Jesus reconhece necessidades.', 'Gratidão permanece adequada.'), 'Mateus 6:11'],
      ['Perdoar não compra o favor de Deus; antes, mostra:', [['a', 'O fruto de quem foi alcançado pela graça'], ['b', 'Que pecado não importa'], ['c', 'Que justiça é desnecessária'], ['d', 'Que só Deus perdoa']], 'a', 'Correto.', wrong('Pecado é tratado seriamente.', 'Graça produz vida transformada.', 'Discípulos também perdoam.'), 'Mateus 6:12,14–15'],
      ['Uma oração moldada por Jesus começa por:', [['a', 'Adorar e submeter-se ao Pai'], ['b', 'Listar conquistas pessoais'], ['c', 'Controlar resultados'], ['d', 'Comparar-se com outros']], 'a', 'Perfeito.', wrong('O foco não é o eu.', 'O Pai não é controlado.', 'A oração não é competição.'), 'Mateus 6:9–10'],
      ['Qual síntese melhor resume o Pai nosso?', [['a', 'Filhos dependentes buscam o nome, o Reino e a vontade do Pai'], ['b', 'Uma fórmula para conseguir tudo'], ['c', 'Um discurso para ser notado'], ['d', 'Uma oração sem perdão']], 'a', 'Excelente síntese.', wrong('Jesus não oferece manipulação.', 'Ele confronta essa motivação.', 'Perdão é parte do modelo.'), 'Mateus 6:9–13'],
    ],
  },
  'sm-20-jejum-secreto': {
    semente: [
      ['Jesus diz “quando jejuardes”, indicando que o jejum:', [['a', 'É uma prática possível do discípulo'], ['b', 'É proibido'], ['c', 'Serve para aparecer'], ['d', 'Substitui a oração']], 'a', 'Correto!', wrong('Jesus pressupõe, não proíbe.', 'Ele condena ostentação.', 'As disciplinas não competem.'), 'Mateus 6:16'],
      ['Os hipócritas desfiguravam o rosto para:', [['a', 'Mostrar às pessoas que jejuavam'], ['b', 'Buscar o Pai em secreto'], ['c', 'Cuidar da saúde'], ['d', 'Servir os pobres']], 'a', 'Exato.', wrong('Esse é o contraste.', 'Não é o motivo do texto.', 'A motivação era reconhecimento.'), 'Mateus 6:16'],
      ['Ao jejuar, Jesus manda:', [['a', 'Ungir a cabeça e lavar o rosto'], ['b', 'Vestir tristeza para todos verem'], ['c', 'Anunciar o sacrifício'], ['d', 'Exigir aplausos']], 'a', 'Muito bem.', wrong('Jesus manda o contrário.', 'O secreto evita essa exibição.', 'Essa é a recompensa humana.'), 'Mateus 6:17–18'],
      ['Quem vê o jejum secreto?', [['a', 'O Pai'], ['b', 'A praça'], ['c', 'A multidão'], ['d', 'Somente líderes']], 'a', 'Isso.', wrong('A plateia não é o alvo.', 'Jesus chama a não parecer jejuar.', 'O Pai vê em secreto.'), 'Mateus 6:18'],
      ['O jejum fiel busca principalmente:', [['a', 'A Deus, não reconhecimento'], ['b', 'Superioridade religiosa'], ['c', 'Uma imagem triste'], ['d', 'Recompensa humana']], 'a', 'Correto.', wrong('Isso é hipocrisia.', 'O exterior não é o alvo.', 'Jesus confronta isso.'), 'Mateus 6:16–18'],
    ],
    caminhada: [
      ['A aparência abatida no jejum revela:', [['a', 'Devoção transformada em espetáculo'], ['b', 'Humildade automática'], ['c', 'Obediência perfeita'], ['d', 'Cuidado com o próximo']], 'a', 'Excelente.', wrong('O texto a chama de hipocrisia.', 'A aparência pode enganar.', 'O foco era ser visto.'), 'Mateus 6:16'],
      ['O jejum não deve ser entendido como:', [['a', 'Moeda para comprar favor de Deus'], ['b', 'Busca humilde do Pai'], ['c', 'Disciplina espiritual'], ['d', 'Prática que pede sinceridade']], 'a', 'Perfeito.', wrong('Isso corresponde ao texto.', 'Jesus pressupõe a prática.', 'O coração importa.'), 'Mateus 6:16–18'],
      ['Lavar o rosto no contexto comunica:', [['a', 'Simplicidade, sem anunciar a disciplina'], ['b', 'Negação de que se jejua'], ['c', 'Desprezo pelo corpo'], ['d', 'Obrigação de parecer rico']], 'a', 'Muito bem.', wrong('O alvo é não parecer aos homens.', 'Jesus não ensina isso.', 'Não é o assunto.'), 'Mateus 6:17–18'],
      ['Isaías 58 ajuda a entender que jejum sem justiça é:', [['a', 'Uma prática vazia'], ['b', 'A forma mais alta de fé'], ['c', 'Substituto da misericórdia'], ['d', 'Licença para orgulho']], 'a', 'Correto.', wrong('Deus chama a justiça e misericórdia.', 'O jejum não elimina amor ao próximo.', 'Orgulho contraria a disciplina.'), 'Isaías 58:6–7'],
      ['A recompensa do Pai destaca que:', [['a', 'Deus vê a devoção não exibida'], ['b', 'Só o público avalia a fé'], ['c', 'Jejum garante riquezas'], ['d', 'Disciplina elimina a graça']], 'a', 'Excelente.', wrong('O Pai vê em secreto.', 'Jesus não promete isso.', 'Disciplina responde à graça.'), 'Mateus 6:18'],
    ],
    profundezas: [
      ['Jejuar para provar ser mais espiritual pede:', [['a', 'Arrependimento da vaidade religiosa'], ['b', 'Mais publicidade'], ['c', 'Comparação com outros'], ['d', 'Desprezo de quem não jejua']], 'a', 'Isso.', wrong('Isso aprofunda o problema.', 'O jejum não é competição.', 'Jesus condena hipocrisia.'), 'Mateus 6:16–18'],
      ['Uma disciplina que agrada ao Pai une:', [['a', 'Sinceridade, humildade e busca de Deus'], ['b', 'Tristeza encenada'], ['c', 'Controle de Deus'], ['d', 'Capital religioso']], 'a', 'Muito bem.', wrong('Jesus confronta a encenação.', 'Deus não é manipulado.', 'Esse é o perigo.'), 'Mateus 6:16–18'],
      ['Joel 2 chama a “rasgar” principalmente:', [['a', 'O coração, em retorno sincero a Deus'], ['b', 'As vestes para impressionar'], ['c', 'Os vínculos com a comunidade'], ['d', 'A Escritura']], 'a', 'Correto.', wrong('O profeta contrasta exterior e interior.', 'O retorno inclui comunidade.', 'A Palavra conduz ao retorno.'), 'Joel 2:12–13'],
      ['Jejum secreto não significa:', [['a', 'Desprezar a comunhão e a justiça'], ['b', 'Fugir da autopropaganda'], ['c', 'Buscar o Pai'], ['d', 'Recusar a performance']], 'a', 'Perfeito.', wrong('Isso é o contraste.', 'Essa é a direção do texto.', 'Jesus condena a exibição.'), 'Mateus 6:16–18'],
      ['Qual síntese expressa o ensino de Jesus?', [['a', 'Jejuar diante do Pai, não para parecer espiritual'], ['b', 'Usar privação como vitrine'], ['c', 'Medir fé por aparência'], ['d', 'Transformar disciplina em poder']], 'a', 'Excelente síntese.', wrong('Jesus condena esse objetivo.', 'O Pai vê o coração.', 'Deus não é manipulado.'), 'Mateus 6:16–18'],
    ],
  },
  'sm-21-tesouros-e-ansiedade': {
    semente: [
      ['Jesus manda ajuntar tesouros principalmente:', [['a', 'No céu'], ['b', 'Onde a traça destrói'], ['c', 'Somente na terra'], ['d', 'Para exibir riqueza']], 'a', 'Correto!', wrong('Tesouros terrenos são frágeis.', 'Jesus contrasta céu e terra.', 'O coração não deve servir à ostentação.'), 'Mateus 6:19–20'],
      ['Onde está o tesouro, ali estará:', [['a', 'O coração'], ['b', 'A salvação comprada'], ['c', 'A ausência de Deus'], ['d', 'O fim da obediência']], 'a', 'Exato.', wrong('O texto fala do coração.', 'Deus não se compra.', 'Tesouro revela prioridades.'), 'Mateus 6:21'],
      ['Ninguém pode servir a:', [['a', 'Deus e a Mamom'], ['b', 'Deus e ao próximo'], ['c', 'Deus e à verdade'], ['d', 'Deus e ao Reino']], 'a', 'Muito bem.', wrong('Amar o próximo é mandamento.', 'Deus é verdadeiro.', 'O Reino é de Deus.'), 'Mateus 6:24'],
      ['Jesus manda buscar primeiro:', [['a', 'O Reino de Deus e sua justiça'], ['b', 'O amanhã'], ['c', 'A aprovação humana'], ['d', 'Tesouros na terra']], 'a', 'Isso.', wrong('Cada dia tem seu cuidado.', 'O Pai, não a plateia, define a vida.', 'Eles são frágeis.'), 'Mateus 6:33'],
      ['As aves e os lírios apontam para:', [['a', 'O cuidado providente do Pai'], ['b', 'Irresponsabilidade humana'], ['c', 'Desprezo pelo trabalho'], ['d', 'Garantia de luxo']], 'a', 'Correto.', wrong('Confiança não é negligência.', 'Jesus não condena trabalho.', 'Ele promete cuidado, não luxo.'), 'Mateus 6:25–32'],
    ],
    caminhada: [
      ['Tesouros na terra são inseguros porque:', [['a', 'Podem ser destruídos ou roubados'], ['b', 'Nunca desaparecem'], ['c', 'Salvam o coração'], ['d', 'Eliminam ansiedade']], 'a', 'Excelente.', wrong('Jesus afirma sua fragilidade.', 'Não podem salvar.', 'Frequentemente alimentam ansiedade.'), 'Mateus 6:19'],
      ['O “olho bom” aponta para:', [['a', 'Visão íntegra e generosa'], ['b', 'Visão física perfeita'], ['c', 'Amor a Mamom'], ['d', 'Indiferença moral']], 'a', 'Perfeito.', wrong('A imagem é espiritual e moral.', 'Mamom divide o coração.', 'Jesus chama à luz.'), 'Mateus 6:22–23'],
      ['Mamom é tratado por Jesus como:', [['a', 'Um senhor rival'], ['b', 'Um dom neutro que governa'], ['c', 'O Reino de Deus'], ['d', 'A resposta para ansiedade']], 'a', 'Muito bem.', wrong('Riqueza não deve governar.', 'Mamom não é o Reino.', 'Ela não oferece segurança final.'), 'Mateus 6:24'],
      ['A ansiedade é confrontada lembrando que:', [['a', 'O Pai sabe do que precisamos'], ['b', 'Necessidades não existem'], ['c', 'Planejar é pecado'], ['d', 'Só ricos podem confiar']], 'a', 'Correto.', wrong('Jesus reconhece necessidades reais.', 'Ele não proíbe prudência.', 'Todos dependem do Pai.'), 'Mateus 6:31–32'],
      ['“Basta a cada dia o seu próprio mal” chama a:', [['a', 'Viver hoje sob a confiança do Pai'], ['b', 'Ignorar responsabilidades'], ['c', 'Controlar o futuro'], ['d', 'Nunca fazer planos']], 'a', 'Excelente.', wrong('Confiança não é descuido.', 'O futuro pertence a Deus.', 'Planejar com sabedoria é diferente de ansiedade.'), 'Mateus 6:34'],
    ],
    profundezas: [
      ['Buscar primeiro o Reino diante de finanças envolve:', [['a', 'Planejar com honestidade sem servir ao dinheiro'], ['b', 'Ignorar contas'], ['c', 'Medir valor por posses'], ['d', 'Acumular para controlar tudo']], 'a', 'Isso.', wrong('Confiança não é negligência.', 'Identidade não vem das posses.', 'Mamom não dá controle final.'), 'Mateus 6:24–34'],
      ['Por que tesouro e ansiedade aparecem juntos?', [['a', 'Ambos revelam o que governa o coração'], ['b', 'Porque Jesus proíbe necessidades'], ['c', 'Porque dinheiro é sempre mau'], ['d', 'Porque fé elimina planejamento']], 'a', 'Muito bem.', wrong('Necessidades são apresentadas ao Pai.', 'O problema é o senhorio da riqueza.', 'Fé orienta planejamento.'), 'Mateus 6:19–34'],
      ['Confiar no Pai NÃO significa:', [['a', 'Negar responsabilidades concretas'], ['b', 'Buscar seu Reino'], ['c', 'Recusar Mamom como senhor'], ['d', 'Entregar o amanhã a Deus']], 'a', 'Correto.', wrong('Isso é o ensino de Jesus.', 'Jesus proíbe dois senhores.', 'Cada dia é vivido diante do Pai.'), 'Mateus 6:25–34'],
      ['A resposta cristã à ansiedade inclui:', [['a', 'Levar necessidades ao Pai e ordenar prioridades pelo Reino'], ['b', 'Fingir que não há dor'], ['c', 'Servir ao dinheiro por segurança'], ['d', 'Viver preso ao amanhã']], 'a', 'Perfeito.', wrong('Jesus reconhece a realidade.', 'Mamom não é senhor seguro.', 'O amanhã não deve governar o hoje.'), 'Mateus 6:25–34'],
      ['Qual síntese resume Mateus 6:19–34?', [['a', 'O Pai cuida; por isso o discípulo busca o Reino acima de Mamom e ansiedade'], ['b', 'Riqueza garante paz'], ['c', 'Ansiedade resolve o futuro'], ['d', 'A vida vale só pelos bens']], 'a', 'Excelente síntese.', wrong('Jesus chama a tesouros no céu.', 'Ansiedade não acrescenta vida.', 'O Pai conhece nosso valor.'), 'Mateus 6:19–34'],
    ],
  },
  'sm-boss-05-vida-diante-do-pai': {
    semente: [
      ['A piedade aprovada por Jesus é feita para:', [['a', 'O Pai, não para plateia'], ['b', 'Ganhar seguidores'], ['c', 'Exibir mérito'], ['d', 'Controlar Deus']], 'a', 'Correto.', wrong('Jesus confronta esse alvo.', 'Mérito não é a base.', 'O Pai não é manipulável.'), 'Mateus 6:1–18'],
      ['A oração de Jesus começa com:', [['a', 'O nome santo do Pai'], ['b', 'Nossos bens'], ['c', 'Nossas vitórias'], ['d', 'Nossa reputação']], 'a', 'Isso.', wrong('A oração começa com Deus.', 'Não é a primeira petição.', 'O centro não é o eu.'), 'Mateus 6:9'],
      ['O jejum fiel é praticado:', [['a', 'Diante do Pai em secreto'], ['b', 'Para parecer abatido'], ['c', 'Para ser admirado'], ['d', 'Para comprar favor']], 'a', 'Muito bem.', wrong('Isso é hipocrisia.', 'O alvo é o Pai.', 'A graça não se compra.'), 'Mateus 6:16–18'],
      ['O senhor que rivaliza com Deus é:', [['a', 'Mamom'], ['b', 'O próximo'], ['c', 'A verdade'], ['d', 'O Reino']], 'a', 'Correto.', wrong('O próximo deve ser amado.', 'Deus é verdadeiro.', 'O Reino pertence a Deus.'), 'Mateus 6:24'],
      ['A prioridade contra a ansiedade é:', [['a', 'Buscar primeiro o Reino'], ['b', 'Controlar o amanhã'], ['c', 'Acumular sem limite'], ['d', 'Viver por aplausos']], 'a', 'Exato.', wrong('Jesus entrega o amanhã ao Pai.', 'Tesouro terreno é frágil.', 'A piedade não é espetáculo.'), 'Mateus 6:33–34'],
    ],
    caminhada: [
      ['Esmola, oração e jejum se unem pelo chamado a:', [['a', 'Viver sinceramente diante do Pai'], ['b', 'Construir imagem religiosa'], ['c', 'Evitar toda disciplina'], ['d', 'Buscar recompensa humana']], 'a', 'Excelente.', wrong('Jesus confronta performance.', 'Ele pressupõe as disciplinas.', 'Esse é o problema do hipócrita.'), 'Mateus 6:1–18'],
      ['O Pai nosso e a ansiedade se conectam porque:', [['a', 'Filhos dependem do Pai para hoje e amanhã'], ['b', 'Oração elimina necessidades'], ['c', 'Deus promete luxo'], ['d', 'Planejamento é incredulidade']], 'a', 'Perfeito.', wrong('Jesus inclui pão diário.', 'Cuidado não significa luxo.', 'Confiança não é imprudência.'), 'Mateus 6:11,25–34'],
      ['Perdoar outros na Cena 5 mostra:', [['a', 'Que a graça recebida transforma relações'], ['b', 'Que pecado é irrelevante'], ['c', 'Que perdão compra salvação'], ['d', 'Que só líderes perdoam']], 'a', 'Muito bem.', wrong('Pecado é sério.', 'Perdão é fruto da graça.', 'Todo discípulo é chamado a perdoar.'), 'Mateus 6:12,14–15'],
      ['Tesouro no céu contrasta com:', [['a', 'Segurança ilusória de bens frágeis'], ['b', 'Cuidado do Pai'], ['c', 'Busca do Reino'], ['d', 'Generosidade sincera']], 'a', 'Correto.', wrong('O Pai é a fonte de cuidado.', 'Jesus ordena essa busca.', 'Ela expressa o Reino.'), 'Mateus 6:19–21'],
      ['O fio da Cena 5 é:', [['a', 'O Pai redefine motivos, prioridades e confiança'], ['b', 'O discípulo controla Deus'], ['c', 'A aparência vale mais que o coração'], ['d', 'Dinheiro resolve ansiedade']], 'a', 'Excelente.', wrong('O Pai é soberano.', 'Jesus confronta exteriorismo.', 'Mamom não salva.'), 'Mateus 6:1–34'],
    ],
    profundezas: [
      ['Uma fé que dá, ora e jejua para ser notada revela:', [['a', 'Piedade performática, não vida diante do Pai'], ['b', 'Maturidade automática'], ['c', 'O Reino em primeiro lugar'], ['d', 'Confiança sem ansiedade']], 'a', 'Isso.', wrong('Jesus chama ao secreto.', 'O Reino não busca plateia.', 'Ansiedade não é tratada por aplauso.'), 'Mateus 6:1–18'],
      ['A dependência do pão diário corrige também:', [['a', 'A pretensão de controlar o futuro'], ['b', 'A bondade do Pai'], ['c', 'O valor da oração'], ['d', 'A necessidade de perdoar']], 'a', 'Muito bem.', wrong('O Pai é bom.', 'A oração expressa dependência.', 'Perdão permanece parte do modelo.'), 'Mateus 6:11,34'],
      ['Buscar Reino antes de riqueza significa:', [['a', 'Submeter recursos e desejos ao senhorio de Deus'], ['b', 'Abandonar toda responsabilidade'], ['c', 'Medir fé por posses'], ['d', 'Servir a dois senhores']], 'a', 'Correto.', wrong('Jesus não ensina negligência.', 'Posses não definem valor.', 'Jesus nega essa possibilidade.'), 'Mateus 6:24,33'],
      ['Qual resposta integra a Cena 5?', [['a', 'Piedade humilde, oração do Reino e confiança no cuidado do Pai'], ['b', 'Rituais para obter fama'], ['c', 'Ansiedade como estratégia'], ['d', 'Mamom como segurança']], 'a', 'Perfeito.', wrong('Jesus confronta esse uso da fé.', 'Ansiedade não acrescenta vida.', 'Mamom rivaliza com Deus.'), 'Mateus 6:1–34'],
      ['O desafio da Cena 5 chama o discípulo a:', [['a', 'Viver sob o olhar do Pai acima do olhar humano'], ['b', 'Fazer do eu o centro'], ['c', 'Guardar tesouros apenas na terra'], ['d', 'Transformar necessidade em desespero']], 'a', 'Excelente síntese.', wrong('O Pai deve ser o centro.', 'Jesus manda tesouros no céu.', 'O Pai conhece necessidades.'), 'Mateus 6:1–34'],
    ],
  },
  'sm-22-nao-julgueis': {
    semente: [
      ['Antes de tirar o argueiro do irmão, Jesus manda:', [['a', 'Tirar a trave do próprio olho'], ['b', 'Humilhar o irmão'], ['c', 'Ignorar todo pecado'], ['d', 'Fingir perfeição']], 'a', 'Correto!', wrong('Jesus condena hipocrisia.', 'Há correção após autoexame.', 'A trave revela o contrário.'), 'Mateus 7:3–5'],
      ['Jesus compara o pecado próprio ignorado a:', [['a', 'Uma trave'], ['b', 'Uma pérola'], ['c', 'Uma porta'], ['d', 'Um pão']], 'a', 'Exato.', wrong('Pérolas aparecem em outra imagem.', 'A porta é outro ensino.', 'Não é a comparação.'), 'Mateus 7:3'],
      ['O argueiro representa:', [['a', 'Uma pequena falha percebida no outro'], ['b', 'A perfeição pessoal'], ['c', 'A ausência de pecado'], ['d', 'Uma riqueza material']], 'a', 'Muito bem.', wrong('Jesus expõe a desproporção.', 'Todos precisam de autoexame.', 'O tema é julgamento hipócrita.'), 'Mateus 7:3–5'],
      ['Depois do autoexame, o discípulo pode:', [['a', 'Ajudar o irmão com clareza'], ['b', 'Continuar hipócrita'], ['c', 'Condenar sem misericórdia'], ['d', 'Negar toda verdade']], 'a', 'Isso.', wrong('Jesus manda tirar primeiro a trave.', 'Correção não é condenação orgulhosa.', 'Discernimento permanece.'), 'Mateus 7:5'],
      ['“Não julgueis” condena principalmente:', [['a', 'A postura hipócrita e condenatória'], ['b', 'Todo discernimento'], ['c', 'Toda correção fraterna'], ['d', 'A busca por verdade']], 'a', 'Correto.', wrong('O texto pede discernimento.', 'Há ajuda após autoexame.', 'Verdade deve ser praticada com humildade.'), 'Mateus 7:1–6'],
    ],
    caminhada: [
      ['A medida usada para julgar lembra que:', [['a', 'Deus leva a sério nosso julgamento dos outros'], ['b', 'Podemos condenar sem limite'], ['c', 'Só o erro alheio importa'], ['d', 'Misericórdia é desnecessária']], 'a', 'Excelente.', wrong('Jesus adverte contra essa presunção.', 'O próprio coração precisa ser examinado.', 'O Reino une verdade e humildade.'), 'Mateus 7:1–2'],
      ['A imagem da trave denuncia:', [['a', 'Cegueira para o próprio pecado'], ['b', 'Cuidado humilde com o irmão'], ['c', 'Discernimento sábio'], ['d', 'Confissão sincera']], 'a', 'Perfeito.', wrong('Esse vem depois do autoexame.', 'Discernimento não é o alvo da crítica.', 'A trave ainda não foi tratada.'), 'Mateus 7:3–5'],
      ['Mateus 7:6 mostra que Jesus também exige:', [['a', 'Discernimento responsável'], ['b', 'Credulidade sem limites'], ['c', 'Julgamento arrogante'], ['d', 'Desprezo por pessoas']], 'a', 'Muito bem.', wrong('O texto não pede ingenuidade.', 'Isso é o que Jesus condena.', 'Discernimento não desumaniza.'), 'Mateus 7:6'],
      ['Uma correção fiel começa por:', [['a', 'Autoexame e arrependimento'], ['b', 'Exposição pública'], ['c', 'Superioridade moral'], ['d', 'Comparação orgulhosa']], 'a', 'Correto.', wrong('Jesus não manda vencer debates.', 'A trave confronta orgulho.', 'O foco deve voltar ao próprio coração.'), 'Mateus 7:3–5'],
      ['João 7:24 complementa este ensino ao chamar a:', [['a', 'Julgar com reta justiça, não aparência'], ['b', 'Nunca avaliar nada'], ['c', 'Aceitar toda mentira'], ['d', 'Ocupar o lugar de Deus']], 'a', 'Excelente.', wrong('Jesus pede discernimento.', 'Verdade importa.', 'O discípulo não é juiz hipócrita.'), 'João 7:24'],
    ],
    profundezas: [
      ['Ao perceber pecado em um irmão, a aplicação fiel é:', [['a', 'Examinar-se, arrepender-se e servir com mansidão'], ['b', 'Expor para vencer'], ['c', 'Ignorar qualquer dano'], ['d', 'Fingir não ter fraquezas']], 'a', 'Isso.', wrong('Isso é julgamento hipócrita.', 'Amor não é indiferença.', 'A trave precisa ser vista.'), 'Mateus 7:3–5; Gálatas 6:1'],
      ['Discernir sem julgar hipocritamente significa:', [['a', 'Unir verdade, humildade e amor ao corrigir'], ['b', 'Chamar todo pecado de bem'], ['c', 'Condenar pessoas para se sentir justo'], ['d', 'Nunca ajudar ninguém']], 'a', 'Muito bem.', wrong('Jesus não elimina a verdade.', 'Isso é a postura condenada.', 'Depois da trave, há ajuda.'), 'Mateus 7:1–6'],
      ['A trave no próprio olho impede:', [['a', 'Tratar o outro como problema sem olhar o coração'], ['b', 'Confessar o próprio pecado'], ['c', 'Receber graça'], ['d', 'Crescer em mansidão']], 'a', 'Correto.', wrong('Confissão é o primeiro passo.', 'A graça trata nossa cegueira.', 'Mansidão é fruto do autoexame.'), 'Mateus 7:3–5'],
      ['A correção fraterna deixa de ser hipocrisia quando:', [['a', 'Quem corrige começa pelo próprio arrependimento'], ['b', 'É feita com mais dureza'], ['c', 'É pública sempre'], ['d', 'Ignora o contexto']], 'a', 'Perfeito.', wrong('Dureza não resolve o coração.', 'O texto não cria essa regra.', 'Amor e sabedoria importam.'), 'Mateus 7:5; Gálatas 6:1'],
      ['Qual síntese resume Mateus 7:1–6?', [['a', 'Rejeitar condenação orgulhosa e praticar discernimento humilde'], ['b', 'Nunca distinguir bem e mal'], ['c', 'Focar somente nos defeitos alheios'], ['d', 'Trocar misericórdia por dureza']], 'a', 'Excelente síntese.', wrong('Jesus ainda pede discernimento.', 'A trave confronta esse impulso.', 'O discípulo serve com humildade.'), 'Mateus 7:1–6'],
    ],
  },
  'sm-23-pedir-buscar-bater': {
    semente: [
      ['Jesus convida o discípulo a:', [['a', 'Pedir, buscar e bater'], ['b', 'Desistir de orar'], ['c', 'Confiar só em si'], ['d', 'Controlar o Pai']], 'a', 'Correto!', wrong('O texto chama à perseverança.', 'Oração é dependência.', 'O Pai não é manipulável.'), 'Mateus 7:7'],
      ['Quem pede, segundo Jesus:', [['a', 'Recebe'], ['b', 'É ignorado sempre'], ['c', 'Deve se envergonhar'], ['d', 'Não precisa confiar']], 'a', 'Exato.', wrong('Jesus promete a bondade do Pai.', 'Ele chama à aproximação.', 'Pedir é ato de confiança.'), 'Mateus 7:7'],
      ['Um pai humano não dá pedra ao filho que pede:', [['a', 'Pão'], ['b', 'Riqueza'], ['c', 'Um título'], ['d', 'Uma multidão']], 'a', 'Muito bem.', wrong('A comparação é pão/pedra.', 'Não é a imagem usada.', 'O texto fala da bondade paternal.'), 'Mateus 7:9'],
      ['O Pai celeste dá:', [['a', 'Boas dádivas aos que pedem'], ['b', 'Pedras aos filhos'], ['c', 'Somente silêncio'], ['d', 'Mal a quem confia']], 'a', 'Isso.', wrong('Jesus argumenta o oposto.', 'Ele manda pedir.', 'O Pai é bom.'), 'Mateus 7:11'],
      ['A regra de ouro manda:', [['a', 'Fazer aos outros o que desejamos receber'], ['b', 'Buscar vantagem própria'], ['c', 'Amar só quem retribui'], ['d', 'Ignorar o próximo']], 'a', 'Correto.', wrong('Jesus chama ao bem ativo.', 'A regra amplia o amor.', 'Ela trata do próximo.'), 'Mateus 7:12'],
    ],
    caminhada: [
      ['Pedir, buscar e bater descrevem:', [['a', 'Perseverança confiante em oração'], ['b', 'Tentativa de obrigar Deus'], ['c', 'Falta de fé'], ['d', 'Repetição vazia']], 'a', 'Excelente.', wrong('Deus não é controlado.', 'Jesus convida a confiar.', 'O texto fala de busca filial.'), 'Mateus 7:7–8'],
      ['O argumento de Jesus vai de:', [['a', 'Pais imperfeitos ao Pai perfeito'], ['b', 'Filhos perfeitos a pais maus'], ['c', 'Riqueza a pobreza'], ['d', 'Lei a anarquia']], 'a', 'Perfeito.', wrong('O texto ressalta a bondade do Pai.', 'Não é o contraste central.', 'Jesus fala de paternidade e oração.'), 'Mateus 7:9–11'],
      ['A bondade do Pai não torna a oração:', [['a', 'Um mecanismo para impor desejos'], ['b', 'Uma expressão de confiança'], ['c', 'Uma aproximação filial'], ['d', 'Uma prática perseverante']], 'a', 'Muito bem.', wrong('Isso é o ensino.', 'Jesus chama a pedir.', 'Buscar e bater comunicam perseverança.'), 'Mateus 7:7–11'],
      ['A regra de ouro é chamada de síntese da:', [['a', 'Lei e dos Profetas'], ['b', 'Ansiedade e Mamom'], ['c', 'Genealogia de Jesus'], ['d', 'Vida de Herodes']], 'a', 'Correto.', wrong('Esse é outro bloco.', 'Não é o assunto.', 'O texto aponta à Escritura.'), 'Mateus 7:12'],
      ['Quem confia no Pai bom deve tratar o próximo com:', [['a', 'O bem que deseja receber'], ['b', 'Indiferença estratégica'], ['c', 'Manipulação religiosa'], ['d', 'Retaliação']], 'a', 'Excelente.', wrong('A regra de ouro pede ação.', 'Oração não manipula.', 'Jesus ensina amor ativo.'), 'Mateus 7:12'],
    ],
    profundezas: [
      ['Perseverar em oração sem tratar Deus como máquina é:', [['a', 'Pedir com confiança e submissão à bondade do Pai'], ['b', 'Exigir qualquer desejo agora'], ['c', 'Nunca agir com sabedoria'], ['d', 'Usar palavras vazias']], 'a', 'Isso.', wrong('O Pai não é controlado.', 'Fé também age responsavelmente.', 'Jesus rejeita vãs repetições.'), 'Mateus 7:7–11'],
      ['A comparação pão/pedra protege a convicção de que:', [['a', 'O Pai não zomba das necessidades dos filhos'], ['b', 'Deus sempre confirma nossos planos'], ['c', 'Pedidos dispensam obediência'], ['d', 'Pais humanos são perfeitos']], 'a', 'Muito bem.', wrong('A bondade não é controle humano.', 'Oração forma discípulos.', 'Jesus os chama imperfeitos.'), 'Mateus 7:9–11'],
      ['Pedir sabedoria em Tiago 1:5 se harmoniza porque:', [['a', 'Deus dá liberalmente a quem pede'], ['b', 'Oração é inútil'], ['c', 'Sabedoria é autonomia'], ['d', 'Só especialistas podem pedir']], 'a', 'Correto.', wrong('Tiago incentiva pedir.', 'Sabedoria vem de Deus.', 'A promessa é ampla.'), 'Tiago 1:5'],
      ['A regra de ouro impede que a oração se torne:', [['a', 'Espiritualidade desconectada do amor ao próximo'], ['b', 'Dependência do Pai'], ['c', 'Busca por sabedoria'], ['d', 'Gratidão pelas dádivas']], 'a', 'Perfeito.', wrong('Isso é parte da oração fiel.', 'Buscar é apropriado.', 'O Pai é bom.'), 'Mateus 7:7–12'],
      ['Qual síntese descreve esta missão?', [['a', 'O Pai bom recebe oração perseverante e forma amor prático'], ['b', 'Oração compra resultados'], ['c', 'O próximo é secundário'], ['d', 'Deus é distante dos filhos']], 'a', 'Excelente síntese.', wrong('Jesus revela a bondade do Pai.', 'A regra de ouro inclui o próximo.', 'Ele convida a pedir.'), 'Mateus 7:7–12'],
    ],
  },
  'sm-24-porta-estreita': {
    semente: [
      ['Jesus manda entrar pela:', [['a', 'Porta estreita'], ['b', 'Porta larga'], ['c', 'Porta mais popular'], ['d', 'Porta sem decisão']], 'a', 'Correto!', wrong('Ela conduz à perdição.', 'Popularidade não é o teste.', 'Jesus exige resposta.'), 'Mateus 7:13'],
      ['O caminho largo conduz para:', [['a', 'A perdição'], ['b', 'A vida'], ['c', 'A maturidade'], ['d', 'O Reino automático']], 'a', 'Exato.', wrong('A vida é o destino do caminho estreito.', 'O texto contrasta dois fins.', 'Não há automatismo.'), 'Mateus 7:13'],
      ['O caminho apertado conduz para:', [['a', 'A vida'], ['b', 'A fama'], ['c', 'A facilidade'], ['d', 'A perdição']], 'a', 'Muito bem.', wrong('Jesus não promete popularidade.', 'Ele não promete conforto automático.', 'Esse é o fim do caminho largo.'), 'Mateus 7:14'],
      ['Jesus diz que muitos entram pela:', [['a', 'Porta larga'], ['b', 'Porta estreita'], ['c', 'Porta da vida'], ['d', 'Porta do Reino por mérito']], 'a', 'Isso.', wrong('Ele diz que poucos encontram a estreita.', 'A vida está ligada ao caminho apertado.', 'A entrada não é mérito humano.'), 'Mateus 7:13–14'],
      ['A imagem das duas portas exige:', [['a', 'Uma decisão real diante de Jesus'], ['b', 'Neutralidade permanente'], ['c', 'Seguir a multidão'], ['d', 'Escolher a facilidade']], 'a', 'Correto.', wrong('Jesus não permite indiferença.', 'A multidão não define a verdade.', 'O caminho largo engana.'), 'Mateus 7:13–14'],
    ],
    caminhada: [
      ['A porta estreita não ensina:', [['a', 'Salvação conquistada por desempenho'], ['b', 'Resposta obediente a Jesus'], ['c', 'Um caminho que confronta pecado'], ['d', 'Urgência de decidir']], 'a', 'Excelente.', wrong('Jesus chama a segui-lo.', 'O caminho não acomoda autonomia.', 'O contraste pede resposta.'), 'Mateus 7:13–14'],
      ['O caminho largo é perigoso porque:', [['a', 'Parece fácil, mas termina em perdição'], ['b', 'É sempre impopular'], ['c', 'Exige muita obediência'], ['d', 'Conduz à vida']], 'a', 'Perfeito.', wrong('O texto diz que muitos entram nele.', 'O caminho estreito confronta o pecado.', 'Esse é o destino oposto.'), 'Mateus 7:13'],
      ['A estreiteza do caminho aponta para:', [['a', 'Fidelidade ao caminho definido por Jesus'], ['b', 'Elitismo humano'], ['c', 'Desprezo pelos perdidos'], ['d', 'Autossalvação']], 'a', 'Muito bem.', wrong('A porta não exalta mérito humano.', 'Jesus chama ao anúncio e amor.', 'Vida é recebida, não conquistada.'), 'Mateus 7:13–14'],
      ['João 14:6 ilumina este texto ao apresentar Jesus como:', [['a', 'O caminho, a verdade e a vida'], ['b', 'Um entre muitos caminhos iguais'], ['c', 'Uma ideia sem exigência'], ['d', 'Um mestre sem autoridade']], 'a', 'Correto.', wrong('Jesus afirma exclusividade.', 'Ele chama a seguir suas palavras.', 'Sua autoridade é central.'), 'João 14:6'],
      ['Escolher a porta estreita significa:', [['a', 'Recusar autonomia e responder a Cristo'], ['b', 'Buscar aprovação da maioria'], ['c', 'Evitar toda renúncia'], ['d', 'Confiar no próprio mérito']], 'a', 'Excelente.', wrong('O caminho popular não define vida.', 'Jesus não promete facilidade.', 'O discípulo depende da graça.'), 'Mateus 7:13–14'],
    ],
    profundezas: [
      ['Por que a porta estreita não é salvação por mérito?', [['a', 'Entrar é responder a Jesus, não conquistar vida por desempenho'], ['b', 'Porque pecado não existe'], ['c', 'Porque todo caminho termina igual'], ['d', 'Porque obediência salva sem graça']], 'a', 'Isso.', wrong('Jesus chama ao arrependimento.', 'Ele contrasta os fins.', 'Graça produz obediência, não orgulho.'), 'Mateus 7:13–14'],
      ['A popularidade de um caminho não prova que ele:', [['a', 'Conduz à vida'], ['b', 'É largo'], ['c', 'Atrai muitos'], ['d', 'Pode parecer fácil']], 'a', 'Muito bem.', wrong('O caminho largo é o popular.', 'Jesus afirma isso.', 'Essa aparência pode enganar.'), 'Mateus 7:13–14'],
      ['A decisão pela porta estreita pede:', [['a', 'Fidelidade quando o caminho não é fácil'], ['b', 'Conformidade com qualquer desejo'], ['c', 'Recusa de todo arrependimento'], ['d', 'Busca de conforto acima de Jesus']], 'a', 'Correto.', wrong('O caminho largo acomoda desejos.', 'Jesus chama a mudança.', 'Ele não promete facilidade.'), 'Mateus 7:13–14'],
      ['Deuteronômio 30:19 ecoa esta missão ao colocar diante do povo:', [['a', 'Vida e morte'], ['b', 'Neutralidade e indiferença'], ['c', 'Riqueza e fama'], ['d', 'Somente regras externas']], 'a', 'Perfeito.', wrong('A Escritura chama à escolha.', 'Não é o contraste central.', 'A escolha é pela vida no Senhor.'), 'Deuteronômio 30:19–20'],
      ['Qual síntese resume a porta estreita?', [['a', 'Jesus chama a uma resposta urgente que conduz à vida'], ['b', 'Todo caminho é equivalente'], ['c', 'A multidão define a verdade'], ['d', 'A vida não requer decisão']], 'a', 'Excelente síntese.', wrong('Jesus contrasta dois destinos.', 'Popularidade não é critério.', 'O imperativo é “entrai”.'), 'Mateus 7:13–14'],
    ],
  },
  'sm-25-frutos-e-casa': {
    semente: [
      ['Jesus manda acautelar-se dos:', [['a', 'Falsos profetas'], ['b', 'Pobres'], ['c', 'Discípulos obedientes'], ['d', 'Ouvintes da Palavra']], 'a', 'Correto!', wrong('Jesus chama a servir os necessitados.', 'O problema é aparência enganosa.', 'O alvo é ouvir e praticar.'), 'Mateus 7:15'],
      ['Falsos profetas são reconhecidos:', [['a', 'Pelos frutos'], ['b', 'Pela fama'], ['c', 'Pelas roupas'], ['d', 'Pelos títulos']], 'a', 'Exato.', wrong('Popularidade pode enganar.', 'Lobos podem vestir pele de ovelha.', 'Título não prova caráter.'), 'Mateus 7:16'],
      ['Nem todo o que diz “Senhor, Senhor”:', [['a', 'Entrará no Reino dos céus'], ['b', 'Conhece a palavra Senhor'], ['c', 'Tem voz religiosa'], ['d', 'Participa de uma multidão']], 'a', 'Muito bem.', wrong('O texto trata de entrada e obediência.', 'Confissão é insuficiente sem prática.', 'Multidão não é o teste.'), 'Mateus 7:21'],
      ['A casa sobre a rocha representa quem:', [['a', 'Ouve Jesus e pratica suas palavras'], ['b', 'Só admira o Sermão'], ['c', 'Evita todas as tempestades'], ['d', 'Fala sem obedecer']], 'a', 'Isso.', wrong('Ouvir pede resposta.', 'Tempestades vêm aos dois.', 'Jesus rejeita confissão vazia.'), 'Mateus 7:24'],
      ['A casa sobre a areia cai porque seu construtor:', [['a', 'Ouve e não pratica'], ['b', 'Ouve e obedece'], ['c', 'Tem uma rocha'], ['d', 'Busca a vontade do Pai']], 'a', 'Correto.', wrong('Esse é o contraste do prudente.', 'A rocha sustenta.', 'Obediência é o fundamento.'), 'Mateus 7:26–27'],
    ],
    caminhada: [
      ['A aparência de ovelha dos falsos profetas ensina que:', [['a', 'Aparência religiosa pode enganar'], ['b', 'Todo líder é falso'], ['c', 'Fruto não importa'], ['d', 'Discernimento é proibido']], 'a', 'Excelente.', wrong('Jesus alerta contra falsidade, não contra todos.', 'Frutos são o critério.', 'Ele manda acautelar-se.'), 'Mateus 7:15–20'],
      ['Os frutos incluem principalmente:', [['a', 'Vida e ensino coerentes com Deus'], ['b', 'Carisma e fama apenas'], ['c', 'Resultados impressionantes apenas'], ['d', 'Palavras bonitas somente']], 'a', 'Perfeito.', wrong('Podem enganar.', 'Jesus alerta sobre obras sem obediência.', 'Fruto vai além do discurso.'), 'Mateus 7:15–23'],
      ['Fazer a vontade do Pai contrasta com:', [['a', 'Confissão verbal sem obediência'], ['b', 'Ouvir e praticar'], ['c', 'Fundamento na rocha'], ['d', 'Fruto verdadeiro']], 'a', 'Muito bem.', wrong('Isso é o caminho apresentado.', 'A rocha envolve prática.', 'Fruto e obediência se unem.'), 'Mateus 7:21–23'],
      ['As tempestades sobre as duas casas mostram que:', [['a', 'A prova revela o fundamento'], ['b', 'O prudente nunca sofre'], ['c', 'A areia é mais firme'], ['d', 'Ouvir basta sem praticar']], 'a', 'Correto.', wrong('A tempestade vem aos dois.', 'Jesus contrasta rocha e areia.', 'A prática é decisiva.'), 'Mateus 7:24–27'],
      ['Tiago 1:22 ecoa Jesus ao ordenar:', [['a', 'Ser praticante da palavra'], ['b', 'Apenas ouvir sermões'], ['c', 'Confiar na aparência'], ['d', 'Evitar obediência']], 'a', 'Excelente.', wrong('Tiago rejeita esse engano.', 'Aparência não sustenta.', 'Ouvir exige resposta.'), 'Tiago 1:22'],
    ],
    profundezas: [
      ['Discernir pelos frutos pede atenção a:', [['a', 'Vida e ensino coerentes com a vontade de Deus'], ['b', 'Carisma e fama somente'], ['c', 'Resultados impressionantes apenas'], ['d', 'Aparência religiosa']], 'a', 'Isso.', wrong('Podem enganar.', 'Jesus adverte sobre obras sem obediência.', 'Lobos podem vestir pele de ovelha.'), 'Mateus 7:15–23'],
      ['A confissão “Senhor, Senhor” sem obediência revela:', [['a', 'Religião verbal sem submissão real'], ['b', 'Fundamento seguro'], ['c', 'Fruto maduro'], ['d', 'Entrada automática no Reino']], 'a', 'Muito bem.', wrong('Jesus liga segurança a ouvir e praticar.', 'Fruto acompanha a vida verdadeira.', 'Ele explicitamente nega isso.'), 'Mateus 7:21–23'],
      ['Construir sobre a rocha hoje significa:', [['a', 'Responder às palavras de Jesus com prática perseverante'], ['b', 'Colecionar informação religiosa'], ['c', 'Evitar toda dificuldade'], ['d', 'Confiar em obras sem graça']], 'a', 'Correto.', wrong('Ouvir sem praticar é areia.', 'Tempestades não são evitadas.', 'Obediência é fruto, não mérito.'), 'Mateus 7:24–27'],
      ['Por que sinais impressionantes não bastam?', [['a', 'Jesus exige conhecer e fazer a vontade do Pai'], ['b', 'Deus não age poderosamente'], ['c', 'Toda experiência é falsa'], ['d', 'A verdade não importa']], 'a', 'Perfeito.', wrong('O texto não nega o poder de Deus.', 'O alerta é contra falsa autenticidade.', 'Verdade e obediência importam.'), 'Mateus 7:21–23'],
      ['Qual síntese une frutos e casa na rocha?', [['a', 'A fé verdadeira se revela em obediência que permanece na prova'], ['b', 'Aparência religiosa sustenta a vida'], ['c', 'Palavras bastam sem prática'], ['d', 'A tempestade define a verdade']], 'a', 'Excelente síntese.', wrong('Fruto revela além da aparência.', 'Jesus exige ouvir e praticar.', 'Ela revela o fundamento, não o cria.'), 'Mateus 7:15–27'],
    ],
  },
  'sm-boss-06-sermao-completo': {
    semente: [
      ['As bem-aventuranças descrevem principalmente:', [['a', 'O caráter dos cidadãos do Reino'], ['b', 'Métodos de riqueza'], ['c', 'Títulos religiosos'], ['d', 'Caminhos de autopromoção']], 'a', 'Correto.', wrong('Jesus redefine bênção.', 'O foco não é status.', 'O Reino confronta aparência.'), 'Mateus 5:3–12'],
      ['Jesus chama seus discípulos de:', [['a', 'Sal da terra e luz do mundo'], ['b', 'Juízes de todos'], ['c', 'Servos de Mamom'], ['d', 'Donos do Reino']], 'a', 'Isso.', wrong('O discípulo serve com humildade.', 'Mamom é rival de Deus.', 'O Reino pertence ao Pai.'), 'Mateus 5:13–16'],
      ['A justiça do Reino alcança:', [['a', 'O coração, não só o exterior'], ['b', 'Somente rituais'], ['c', 'Apenas líderes'], ['d', 'Só a reputação']], 'a', 'Muito bem.', wrong('Jesus aprofunda a Lei.', 'O ensino é para discípulos.', 'Deus vê o coração.'), 'Mateus 5:20–48'],
      ['A oração ensinada por Jesus começa com:', [['a', 'O nome santo do Pai'], ['b', 'Nossas conquistas'], ['c', 'Nossos tesouros'], ['d', 'Nossos inimigos']], 'a', 'Correto.', wrong('A oração começa em Deus.', 'Tesouros não são prioridade.', 'Há pedidos antes da luta com inimigos.'), 'Mateus 6:9'],
      ['O final do Sermão chama a:', [['a', 'Ouvir Jesus e praticar'], ['b', 'Apenas admirar suas palavras'], ['c', 'Escolher o caminho largo'], ['d', 'Buscar plateia']], 'a', 'Exato.', wrong('Ouvir sem praticar é areia.', 'Jesus contrasta dois caminhos.', 'Piedade não é espetáculo.'), 'Mateus 7:24–27'],
    ],
    caminhada: [
      ['O arco do Sermão começa com identidade e avança para:', [['a', 'Vida transformada no Reino'], ['b', 'Prestígio religioso'], ['c', 'Autonomia moral'], ['d', 'Regras sem coração']], 'a', 'Excelente.', wrong('Jesus confronta isso.', 'O Reino pede submissão.', 'A justiça alcança o interior.'), 'Mateus 5–7'],
      ['Amar inimigos demonstra:', [['a', 'O caráter do Pai refletido no discípulo'], ['b', 'Fraqueza moral'], ['c', 'Indiferença ao mal'], ['d', 'Falta de verdade']], 'a', 'Perfeito.', wrong('É força do Reino.', 'Jesus não manda aprovar o mal.', 'Amor e verdade não se excluem.'), 'Mateus 5:44–48'],
      ['Esmola, oração e jejum são corrigidos porque podem virar:', [['a', 'Performance para ser vista'], ['b', 'Busca sincera do Pai'], ['c', 'Misericórdia real'], ['d', 'Dependência humilde']], 'a', 'Muito bem.', wrong('Esse é o alvo correto.', 'O problema não é misericórdia.', 'Jesus chama a essa postura.'), 'Mateus 6:1–18'],
      ['A porta estreita e a casa na rocha juntas exigem:', [['a', 'Decisão e obediência perseverante'], ['b', 'Neutralidade confortável'], ['c', 'Religião só verbal'], ['d', 'Confiança em aparência']], 'a', 'Correto.', wrong('Jesus chama a entrar.', 'Palavras sem prática não bastam.', 'Fruto revela além da aparência.'), 'Mateus 7:13–27'],
      ['O Sermão do Monte apresenta Jesus como:', [['a', 'Senhor cujas palavras devem ser praticadas'], ['b', 'Mestre sem autoridade'], ['c', 'Guia para autopromoção'], ['d', 'Defensor de dois senhores']], 'a', 'Excelente.', wrong('O povo se admira de sua autoridade.', 'Jesus confronta vaidade.', 'Ninguém pode servir a dois senhores.'), 'Mateus 7:24–29'],
    ],
    profundezas: [
      ['Qual sequência resume o arco de Mateus 5–7?', [['a', 'Identidade do Reino, justiça do coração, vida diante do Pai e decisão obediente'], ['b', 'Fama, riqueza e poder'], ['c', 'Regras externas sem graça'], ['d', 'Neutralidade diante de Jesus']], 'a', 'Isso.', wrong('Jesus redefine esses valores.', 'O coração é central.', 'O Sermão exige resposta.'), 'Mateus 5–7'],
      ['Uma pessoa que conhece o Sermão mas não o pratica está como:', [['a', 'A casa construída sobre areia'], ['b', 'A cidade sobre o monte'], ['c', 'O lírio do campo'], ['d', 'A casa sobre a rocha']], 'a', 'Muito bem.', wrong('Sal e luz envolvem testemunho.', 'Essa imagem trata de providência.', 'Rocha é ouvir e praticar.'), 'Mateus 7:24–27'],
      ['A justiça superior à dos escribas e fariseus é:', [['a', 'Justiça que flui de coração transformado'], ['b', 'Mais aparência religiosa'], ['c', 'Desprezo pela Lei'], ['d', 'Superioridade sobre pessoas']], 'a', 'Correto.', wrong('Jesus confronta exteriorismo.', 'Ele cumpre, não aboliu a Lei.', 'O Reino produz humildade.'), 'Mateus 5:20–48'],
      ['O Sermão integra graça e obediência ao chamar o discípulo a:', [['a', 'Confiar no Pai e responder às palavras de Jesus'], ['b', 'Conquistar Deus por obras'], ['c', 'Usar religião para vantagem'], ['d', 'Separar fé de vida']], 'a', 'Perfeito.', wrong('O Pai é recebido com dependência.', 'Jesus confronta essa motivação.', 'A casa na rocha une ouvir e praticar.'), 'Mateus 5–7'],
      ['O desafio final do Sermão pede:', [['a', 'Viver como cidadão do Reino sob a autoridade de Jesus'], ['b', 'Guardar ideias sem mudança'], ['c', 'Escolher a aprovação humana'], ['d', 'Servir a Mamom e a Deus']], 'a', 'Excelente síntese.', wrong('O Sermão chama à prática.', 'O Pai, não a plateia, é o alvo.', 'Jesus declara isso impossível.'), 'Mateus 5–7'],
    ],
  },
};

let bank = [];
for (const [section, levels] of Object.entries(banks)) {
  bank = bank.concat(pack(section, levels));
}

// Reject Cyrillic lookalikes (for example, Cyrillic а in place of Latin a).
const lookalikes = /[\u0400-\u04FF]/;
if (JSON.stringify({ missions5, missions6, studies, banks }).match(lookalikes)) {
  throw new Error('Texto contém letra cirílica parecida com caractere latino.');
}

const trails = JSON.parse(readFileSync(join(assets, 'trails.json'), 'utf8'));
const trail = trails.find((t) => t.slug === 'sermao-do-monte');
if (!trail) throw new Error('Trilha sermao-do-monte não encontrada.');
for (const module of [module5, module6]) {
  const existingIdx = trail.modules.findIndex((m) => m.section === module.section);
  if (existingIdx >= 0) trail.modules[existingIdx] = module;
  else trail.modules.push(module);
}
writeFileSync(join(assets, 'trails.json'), JSON.stringify(trails, null, 2) + '\n');

const studiesData = JSON.parse(readFileSync(join(assets, 'mission_studies.json'), 'utf8'));
Object.assign(studiesData.studies, studies);
Object.assign(studiesData.verses || (studiesData.verses = {}), {
  'Mateus 6:1–4': studies['sm-18-esmola-secreta'].passageText,
  'Mateus 6:5–15': studies['sm-19-pai-nosso'].passageText,
  'Mateus 6:16–18': studies['sm-20-jejum-secreto'].passageText,
  'Mateus 6:19–34': studies['sm-21-tesouros-e-ansiedade'].passageText,
  'Mateus 6:1': 'Guardai-vos de exercer a vossa justiça diante dos homens, com o fim de serdes vistos por eles.',
  'Mateus 6:9': 'Portanto, vós orareis assim: Pai nosso, que estás nos céus, santificado seja o teu nome.',
  'Mateus 6:10': 'Venha o teu Reino; faça-se a tua vontade, assim na terra como no céu.',
  'Mateus 6:11': 'O pão nosso de cada dia dá-nos hoje.',
  'Mateus 6:12,14–15': 'Perdoa-nos as nossas dívidas… se perdoardes aos homens as suas ofensas, também vosso Pai celeste vos perdoará.',
  'Mateus 6:22–23': 'São os olhos a lâmpada do corpo. Se os teus olhos forem bons, todo o teu corpo será luminoso.',
  'Mateus 6:24': 'Ninguém pode servir a dois senhores… Não podeis servir a Deus e às riquezas.',
  'Mateus 6:25–34': 'Não andeis ansiosos… buscai, pois, em primeiro lugar, o seu Reino e a sua justiça.',
  'Mateus 6:33': 'Buscai, pois, em primeiro lugar, o seu Reino e a sua justiça, e todas estas coisas vos serão acrescentadas.',
  'Mateus 6:1–34': 'Justiça secreta… Pai nosso… jejum sincero… tesouros no céu… buscai primeiro o Reino.',
  'Mateus 7:1–6': studies['sm-22-nao-julgueis'].passageText,
  'Mateus 7:7–12': studies['sm-23-pedir-buscar-bater'].passageText,
  'Mateus 7:13–14': studies['sm-24-porta-estreita'].passageText,
  'Mateus 7:15–27': studies['sm-25-frutos-e-casa'].passageText,
  'Mateus 7:3–5': 'Por que vês tu o argueiro no olho de teu irmão, porém não reparas na trave que está no teu próprio? Tira primeiro a trave.',
  'Mateus 7:7': 'Pedi, e dar-se-vos-á; buscai e achareis; batei, e abrir-se-vos-á.',
  'Mateus 7:9–11': 'Se vós, que sois maus, sabeis dar boas dádivas aos vossos filhos, quanto mais vosso Pai celeste dará boas coisas aos que lhe pedirem.',
  'Mateus 7:12': 'Tudo quanto, pois, quereis que os homens vos façam, assim fazei-o vós também a eles.',
  'Mateus 7:15–20': 'Acautelai-vos dos falsos profetas… pelos seus frutos os conhecereis.',
  'Mateus 7:21–23': 'Nem todo o que me diz: Senhor, Senhor! entrará no Reino dos céus, mas aquele que faz a vontade de meu Pai.',
  'Mateus 7:24': 'Todo aquele, pois, que ouve estas minhas palavras e as pratica será comparado a um homem prudente que edificou a sua casa sobre a rocha.',
  'Mateus 7:24–27': 'Quem ouve e pratica constrói sobre a rocha; quem ouve e não pratica constrói sobre a areia.',
  'Mateus 5:16; 6:1': 'Assim brilhe a vossa luz… Guardai-vos de praticar justiça para serdes vistos pelos homens.',
  'Mateus 7:3–5; Gálatas 6:1': 'Tira primeiro a trave… restaurai-o com espírito de brandura.',
  'Mateus 5–7': 'O caminho do Reino: caráter, justiça do coração, vida diante do Pai e obediência às palavras de Jesus.',
  'Provérbios 19:17': 'Quem se compadece do pobre ao Senhor empresta, e este lhe paga o seu benefício.',
  '2 Coríntios 9:7': 'Deus ama a quem dá com alegria.',
  'Lucas 11:1–4': 'Senhor, ensina-nos a orar… Pai, santificado seja o teu nome; venha o teu Reino.',
  'Filipenses 4:6–7': 'Não andeis ansiosos… sejam conhecidas diante de Deus as vossas petições.',
  'Efésios 4:32': 'Perdoando-vos uns aos outros, como também Deus, em Cristo, vos perdoou.',
  '1 João 5:14': 'Se pedirmos alguma coisa segundo a sua vontade, ele nos ouve.',
  'Isaías 58:6–7': 'Não é este o jejum que escolhi… repartir o teu pão com o faminto?',
  'Joel 2:12–13': 'Convertei-vos a mim de todo o vosso coração… rasgai o vosso coração, e não as vossas vestes.',
  'Atos 13:2–3': 'Servindo eles ao Senhor e jejuando… impuseram sobre eles as mãos e os despediram.',
  'Colossenses 3:1–2': 'Buscai as coisas lá do alto… pensai nas coisas lá do alto.',
  '1 Timóteo 6:6–10': 'Grande fonte de lucro é a piedade com o contentamento… o amor do dinheiro é raiz de todos os males.',
  'Filipenses 4:19': 'O meu Deus suprirá todas as vossas necessidades.',
  '1 Pedro 5:7': 'Lançando sobre ele toda a vossa ansiedade, porque ele tem cuidado de vós.',
  'Romanos 2:1–3': 'És indesculpável quando julgas… pois praticas as próprias coisas que condenas.',
  'Gálatas 6:1': 'Restaurai-o com espírito de brandura; e guarda-te para que não sejas também tentado.',
  'João 7:24': 'Não julgueis segundo a aparência, e sim pela reta justiça.',
  'Lucas 11:9–13': 'Pedi, e dar-se-vos-á… quanto mais o Pai celestial dará o Espírito Santo aos que lho pedirem.',
  'Tiago 1:5': 'Se, porém, algum de vós necessita de sabedoria, peça-a a Deus, que a todos dá liberalmente.',
  'Levítico 19:18': 'Amarás o teu próximo como a ti mesmo. Eu sou o Senhor.',
  'João 14:6': 'Eu sou o caminho, e a verdade, e a vida; ninguém vem ao Pai senão por mim.',
  'Lucas 13:23–24': 'Esforçai-vos por entrar pela porta estreita.',
  'Deuteronômio 30:19–20': 'Escolhe, pois, a vida, para que vivas, tu e a tua descendência.',
  'Deuteronômio 13:1–4': 'Não ouvirás as palavras daquele profeta… pois o Senhor vosso Deus vos prova.',
  'Tiago 1:22': 'Tornai-vos, pois, praticantes da palavra e não somente ouvintes.',
  '1 João 2:3–4': 'Sabemos que o temos conhecido por isto: se guardamos os seus mandamentos.',
  'Efésios 2:8–10': 'Pela graça sois salvos… criados em Cristo Jesus para boas obras.',
});
writeFileSync(join(assets, 'mission_studies.json'), JSON.stringify(studiesData, null, 2) + '\n');

const bankPath = join(assets, 'sermao_questions.json');
const bankData = JSON.parse(readFileSync(bankPath, 'utf8'));
const drop = new Set(Object.keys(banks));
bankData.questions = bankData.questions.filter((qq) => !drop.has(qq.section));
bankData.questions.push(...bank);
writeFileSync(bankPath, JSON.stringify(bankData, null, 2) + '\n');

console.log('Cena 5:', module5.missions.map((m) => m.slug).join(' → '));
console.log('Cena 6:', module6.missions.map((m) => m.slug).join(' → '));
console.log(`+${bank.length} perguntas · banco total ${bankData.questions.length}`);
console.log(`estudos: ${Object.keys(studies).join(', ')}`);
