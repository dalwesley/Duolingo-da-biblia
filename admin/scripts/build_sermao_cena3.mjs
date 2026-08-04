/**
 * Cena 3 — Identidade e Missão (Mateus 5:13–26)
 * Sal · Luz · Lei · Ira · Boss 3
 * Usage: node scripts/build_sermao_cena3.mjs
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

const module3 = {
  title: 'Identidade e Missão',
  icon: '✨',
  section: 'identidade-e-missao',
  missions: [],
};

const missions = [
  {
    slug: 'sm-10-sal-da-terra',
    title: 'Sal da terra',
    subtitle: 'Mateus 5:13',
    intro:
      'Depois de descrever o caráter do cidadão, Jesus revela sua missão no mundo. O discípulo não é chamado a se isolar — é chamado a preservar, temperar e impedir a corrupção, como o sal na terra.',
    type: 'lesson',
    xpReward: 60,
    questions: [],
  },
  {
    slug: 'sm-11-luz-do-mundo',
    title: 'Luz do mundo',
    subtitle: 'Mateus 5:14–16',
    intro:
      'A luz não existe para ficar escondida. Jesus chama seus discípulos a brilhar de modo que as boas obras apontem para o Pai — visibilidade com propósito, não exibicionismo.',
    type: 'lesson',
    xpReward: 60,
    questions: [],
  },
  {
    slug: 'sm-12-jesus-e-a-lei',
    title: 'Jesus e a Lei',
    subtitle: 'Mateus 5:17–20',
    intro:
      'Jesus não veio abolir a Lei ou os Profetas — veio cumprir. No Reino, a justiça não é superficial: supera a dos escribas e fariseus porque alcança o coração.',
    type: 'lesson',
    xpReward: 65,
    questions: [],
  },
  {
    slug: 'sm-13-ira-e-reconciliacao',
    title: 'Ira e reconciliação',
    subtitle: 'Mateus 5:21–26',
    intro:
      'A primeira antítese do Sermão aprofunda o sexto mandamento. Matar começa no coração — na ira e no desprezo. O Reino exige reconciliação antes mesmo da adoração.',
    type: 'lesson',
    xpReward: 65,
    questions: [],
  },
  {
    slug: 'sm-boss-03-identidade-e-missao',
    title: 'Desafio: Identidade e Missão',
    subtitle: 'Mateus 5:13–26',
    intro:
      'Desafio da Cena 3. Mostre que entendeu o chamado a ser sal e luz, a justiça mais profunda da Lei e o caminho da reconciliação.',
    type: 'boss',
    xpReward: 150,
    questions: [],
  },
];

module3.missions = missions;

const studies = {
  'sm-10-sal-da-terra': {
    slug: 'sm-10-sal-da-terra',
    passageRef: 'Mateus 5:13',
    passageText:
      'Vós sois o sal da terra; ora, se o sal vier a ser insípido, como lhe restaurar o sabor? Para nada mais presta senão para, lançado fora, ser pisado pelos homens.',
    context:
      'Na antiguidade, o sal preservava alimentos, temperava e até simbolizava pureza e aliança. Jesus aplica a imagem aos discípulos: presença que impede a decadência moral e dá sabor ao mundo. O aviso é sério — sal sem sabor perde a função. O discípulo que se acomoda ao mundo deixa de cumprir sua vocação.',
    keyword: 'Sal',
    keywordGloss:
      'Imagem da influência preservadora e transformadora do discípulo no mundo.',
    focusQuestion:
      'Minha presença onde vivo preserva o bem ou se dissolve no padrão do ambiente?',
    reflectionPrompts: [
      'O discípulo influencia o mundo — não o contrário',
      'Sem caráter, a missão perde o sabor',
      'Acomodação espiritual é sal insípido',
    ],
    relatedVerses: [
      {
        reference: 'Levítico 2:13',
        reason: 'O sal na oferta lembra a aliança permanente com Deus.',
      },
      {
        reference: 'Colossenses 4:6',
        reason: 'A palavra do cristão deve ser temperada com sal.',
      },
      {
        reference: 'Marcos 9:50',
        reason: 'Tende sal em vós mesmos e paz uns com os outros.',
      },
    ],
  },
  'sm-11-luz-do-mundo': {
    slug: 'sm-11-luz-do-mundo',
    passageRef: 'Mateus 5:14–16',
    passageText:
      'Vós sois a luz do mundo. Não se pode esconder a cidade edificada sobre um monte; nem se acende a candeia e se coloca debaixo do alqueire, mas no velador, e alumia a todos os que estão na casa. Assim resplandeça a vossa luz diante dos homens, para que vejam as vossas boas obras e glorifiquem a vosso Pai, que está nos céus.',
    context:
      'No AT, Israel era chamado a ser luz às nações (Isaías 42; 49). Jesus aplica isso à comunidade do Reino. Luz revela, orienta e expõe trevas. O alvo não é autopromoção: as boas obras devem levar as pessoas a glorificar o Pai. Esconder a luz — por medo ou comodismo — contradiz a identidade do discípulo.',
    keyword: 'Luz',
    keywordGloss:
      'Testemunho visível da vida transformada que aponta para Deus.',
    focusQuestion:
      'Minhas obras fazem as pessoas olharem para mim — ou para o Pai?',
    reflectionPrompts: [
      'Luz existe para ser vista',
      'Boas obras glorificam o Pai',
      'Medo e acomodação escondem a candeia',
    ],
    relatedVerses: [
      {
        reference: 'Isaías 42:6',
        reason: 'Deus chama seu servo para ser luz das nações.',
      },
      {
        reference: 'João 8:12',
        reason: 'Jesus é a luz do mundo — os discípulos refletem essa luz.',
      },
      {
        reference: 'Efésios 5:8',
        reason: 'Outrora éreis trevas; agora sois luz no Senhor.',
      },
      {
        reference: 'Filipenses 2:15',
        reason: 'Resplandecer como luzeiros no mundo.',
      },
    ],
  },
  'sm-12-jesus-e-a-lei': {
    slug: 'sm-12-jesus-e-a-lei',
    passageRef: 'Mateus 5:17–20',
    passageText:
      'Não penseis que vim revogar a Lei ou os Profetas; não vim para revogar, vim para cumprir… Porque vos digo que, se a vossa justiça não exceder em muito a dos escribas e fariseus, jamais entrareis no Reino dos céus.',
    context:
      'Alguns acusavam Jesus de relaxar a Lei. Ele responde com autoridade: veio cumprir — realizar o sentido pleno da Escritura. Nem um iota passará até que tudo se cumpra. A justiça do Reino não é menos exigente que a farisaica; é mais profunda, porque alcança motivações, não só aparências. Isso prepara as antíteses (“ouvistes… eu, porém, vos digo”).',
    keyword: 'Cumprir',
    keywordGloss:
      'Levar a Lei e os Profetas à sua realização plena em Cristo — não anular, mas completar o propósito.',
    focusQuestion:
      'Minha obediência para na aparência — ou alcança o coração?',
    reflectionPrompts: [
      'Jesus não relativiza a Lei — aprofunda',
      'Justiça do Reino começa no interior',
      'Cumprir é mais do que cumprir regras externas',
    ],
    relatedVerses: [
      {
        reference: 'Romanos 3:31',
        reason: 'A fé não anula a Lei; antes a confirma.',
      },
      {
        reference: 'Romanos 8:4',
        reason: 'O Espírito capacita a viver o justo requisito da Lei.',
      },
      {
        reference: 'Jeremias 31:33',
        reason: 'A nova aliança escreve a Lei no coração.',
      },
    ],
  },
  'sm-13-ira-e-reconciliacao': {
    slug: 'sm-13-ira-e-reconciliacao',
    passageRef: 'Mateus 5:21–26',
    passageText:
      'Ouvistes que foi dito aos antigos: Não matarás… Eu, porém, vos digo que todo aquele que se irar contra seu irmão estará sujeito a julgamento… Se, pois, ao trazeres ao altar a tua oferta, ali te lembrares de que teu irmão tem alguma coisa contra ti, deixa perante o altar a tua oferta, vai primeiro reconciliar-te…',
    context:
      'Jesus interpreta o sexto mandamento a partir do coração. Ira, insulto (“raça”) e desprezo já estão na trajetória do assassinato. A adoração não cobre relacionamento quebrado: reconciliar vem antes de ofertar. No Reino, urgência relacional importa — “depressa te reconcilia”.',
    keyword: 'Reconciliação',
    keywordGloss:
      'Restaurar o relacionamento quebrado; prioridade do Reino antes mesmo do culto.',
    focusQuestion:
      'Há alguém com quem preciso me reconciliar antes de continuar “adorando”?',
    reflectionPrompts: [
      'Matar começa no coração',
      'Adoração sem reconciliação é incompleta',
      'A urgência do Reino é restaurar vínculos',
    ],
    relatedVerses: [
      {
        reference: 'Êxodo 20:13',
        reason: 'O mandamento “não matarás” que Jesus aprofunda.',
      },
      {
        reference: '1 João 3:15',
        reason: 'Todo o que odeia a seu irmão é homicida.',
      },
      {
        reference: 'Efésios 4:26–27',
        reason: 'Irai-vos e não pequeis; não deis lugar ao diabo.',
      },
      {
        reference: 'Romanos 12:18',
        reason: 'Se possível, tende paz com todos.',
      },
    ],
  },
};

const banks = {
  'sm-10-sal-da-terra': {
    semente: [
      [
        'Como Jesus chama seus discípulos em Mateus 5:13?',
        [
          ['a', 'Sal da terra'],
          ['b', 'Pedras do templo'],
          ['c', 'Reis de Israel'],
          ['d', 'Anjos da guarda'],
        ],
        'a',
        'Correto!',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:13',
      ],
      [
        'O que acontece se o sal ficar insípido?',
        [
          ['a', 'Para nada mais presta, senão ser lançado fora'],
          ['b', 'Fica mais poderoso'],
          ['c', 'Vira ouro'],
          ['d', 'Substitui a oração'],
        ],
        'a',
        'Exato. Perde a função.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:13',
      ],
      [
        'O sal, neste texto, aponta principalmente para:',
        [
          ['a', 'Influência preservadora dos discípulos no mundo'],
          ['b', 'Receita culinária'],
          ['c', 'Imposto romano'],
          ['d', 'Construção do templo'],
        ],
        'a',
        'Muito bem.',
        { b: 'É metáfora.', c: 'Não.', d: 'Não.' },
        'Mateus 5:13',
      ],
      [
        'Quem são o “vós” de “vós sois o sal”?',
        [
          ['a', 'Os discípulos / cidadãos do Reino'],
          ['b', 'Os romanos'],
          ['c', 'Os fariseus hipócritas'],
          ['d', 'Os anjos'],
        ],
        'a',
        'Correto.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:13',
      ],
      [
        'Sal sem sabor, na aplicação de Jesus, representa:',
        [
          ['a', 'Discípulos que perderam a influência distintiva'],
          ['b', 'Discípulos perfeitos'],
          ['c', 'Anjos caídos'],
          ['d', 'A criação do sol'],
        ],
        'a',
        'Isso.',
        { b: 'É um aviso.', c: 'Não.', d: 'Não.' },
        'Mateus 5:13',
      ],
    ],
    caminhada: [
      [
        'Por que a imagem do sal combina com a missão do discípulo?',
        [
          ['a', 'Porque preserva e tempera — impede corrupção e dá sabor'],
          ['b', 'Porque o sal era inútil na antiguidade'],
          ['c', 'Porque Jesus falava só de comida'],
          ['d', 'Porque sal significa isolamento'],
        ],
        'a',
        'Excelente.',
        { b: 'Era valioso.', c: 'É metáfora missionária.', d: 'É presença no mundo.' },
        'Mateus 5:13',
      ],
      [
        '“Lançado fora e pisado” sugere:',
        [
          ['a', 'Perda de relevância e testemunho'],
          ['b', 'Promoção automática'],
          ['c', 'Vitória militar'],
          ['d', 'Entrada no templo'],
        ],
        'a',
        'Correto.',
        { b: 'É juízo/perda de função.', c: 'Não.', d: 'Não.' },
        'Mateus 5:13',
      ],
      [
        'Como Colossenses 4:6 ecoa esta metáfora?',
        [
          ['a', 'A palavra do cristão deve ser temperada com sal'],
          ['b', 'Cristãos não devem falar'],
          ['c', 'Sal cancela a graça'],
          ['d', 'Só líderes podem falar'],
        ],
        'a',
        'Muito bem.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Colossenses 4:6',
      ],
      [
        'Sal da terra NÃO significa:',
        [
          ['a', 'Isolar-se do mundo para não se “contaminar” de forma absoluta'],
          ['b', 'Preservar o bem no meio da sociedade'],
          ['c', 'Influenciar com caráter do Reino'],
          ['d', 'Manter distinção santa no mundo'],
        ],
        'a',
        'Isso. A metáfora implica presença.',
        { b: 'Isso é.', c: 'Isso é.', d: 'Isso é.' },
        'Mateus 5:13',
      ],
      [
        'Qual risco Jesus destaca para a comunidade do Reino?',
        [
          ['a', 'Perder a distinção e a eficácia do testemunho'],
          ['b', 'Orar demais'],
          ['c', 'Ler a Escritura'],
          ['d', 'Servir ao próximo'],
        ],
        'a',
        'Perfeito.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:13',
      ],
    ],
    profundezas: [
      [
        'Minha presença onde vivo preserva o bem ou se dissolve no ambiente?',
        [
          ['a', 'Examinar e recuperar o “sabor” do caráter do Reino'],
          ['b', 'Ignorar a questão'],
          ['c', 'Culpar só os outros'],
          ['d', 'Abandonar qualquer influência'],
        ],
        'a',
        'Isso. Vocação exige distinção santa.',
        { b: 'Jesus confronta.', c: 'Começa em nós.', d: 'Somos sal.' },
        'Mateus 5:13',
      ],
      [
        'Como o sal da aliança (Lv 2:13) ilumina Mateus 5:13?',
        [
          ['a', 'Fidelidade duradoura a Deus marca o povo'],
          ['b', 'Sal era proibido no culto'],
          ['c', 'Aliança não importa'],
          ['d', 'Só ritual sem ética'],
        ],
        'a',
        'Excelente.',
        { b: 'Era requerido.', c: 'Importa.', d: 'Ética e culto unidos.' },
        'Levítico 2:13',
      ],
      [
        'Em um ambiente corrupto no trabalho, ser sal significa:',
        [
          ['a', 'Manter integridade e influenciar para o bem'],
          ['b', 'Participar de tudo para “pertencer”'],
          ['c', 'Denunciar sem nunca amar'],
          ['d', 'Fugir de qualquer responsabilidade'],
        ],
        'a',
        'Perfeito.',
        { b: 'Acomodação = insípido.', c: 'Verdade com graça.', d: 'Presença importa.' },
        'Mateus 5:13',
      ],
      [
        'O que restaura o “sabor” de um discípulo acomodado?',
        [
          ['a', 'Arrependimento e renovação no caráter de Cristo'],
          ['b', 'Mais aparência religiosa'],
          ['c', 'Mais isolamento orgulhoso'],
          ['d', 'Mais críticas sem mudança'],
        ],
        'a',
        'Muito bem.',
        { b: 'Aparência não basta.', c: 'Não.', d: 'Não.' },
        'Mateus 5:13',
      ],
      [
        'Por que Jesus fala “vós sois” e não “deveis ser”?',
        [
          ['a', 'É identidade antes de ser só imperativo'],
          ['b', 'Discípulos não têm missão'],
          ['c', 'É só sugestão'],
          ['d', 'Só vale para os Doze'],
        ],
        'a',
        'Correto. Identidade gera missão.',
        { b: 'Têm.', c: 'É declaração forte.', d: 'Aplica-se aos discípulos do Reino.' },
        'Mateus 5:13',
      ],
    ],
  },

  'sm-11-luz-do-mundo': {
    semente: [
      [
        'Como Jesus chama os discípulos em Mateus 5:14?',
        [
          ['a', 'Luz do mundo'],
          ['b', 'Trevas do mundo'],
          ['c', 'Sal do templo'],
          ['d', 'Reis de Roma'],
        ],
        'a',
        'Correto!',
        { b: 'Não.', c: 'Sal da terra veio antes.', d: 'Não.' },
        'Mateus 5:14',
      ],
      [
        'O que não se pode esconder, segundo Jesus?',
        [
          ['a', 'Cidade edificada sobre um monte'],
          ['b', 'Uma moeda no bolso'],
          ['c', 'Um peixe no mar'],
          ['d', 'Uma nuvem'],
        ],
        'a',
        'Exato.',
        { b: 'Não é a imagem.', c: 'Não.', d: 'Não.' },
        'Mateus 5:14',
      ],
      [
        'Onde se coloca a candeia acesa?',
        [
          ['a', 'No velador, para alumiar a casa'],
          ['b', 'Debaixo do alqueire'],
          ['c', 'Fora da cidade'],
          ['d', 'No fundo do poço'],
        ],
        'a',
        'Perfeito.',
        { b: 'Jesus rejeita esconder.', c: 'Não.', d: 'Não.' },
        'Mateus 5:15',
      ],
      [
        'Para que a luz dos discípulos resplandeça?',
        [
          ['a', 'Para que vejam as boas obras e glorifiquem o Pai'],
          ['b', 'Para fama pessoal'],
          ['c', 'Para esconder o evangelho'],
          ['d', 'Para substituir a oração'],
        ],
        'a',
        'Correto.',
        { b: 'Alvo é o Pai.', c: 'Não.', d: 'Não.' },
        'Mateus 5:16',
      ],
      [
        'Quem deve ser glorificado pelo testemunho visível?',
        [
          ['a', 'O Pai que está nos céus'],
          ['b', 'O discípulo'],
          ['c', 'Os fariseus'],
          ['d', 'César'],
        ],
        'a',
        'Isso.',
        { b: 'Não é autopromoção.', c: 'Não.', d: 'Não.' },
        'Mateus 5:16',
      ],
    ],
    caminhada: [
      [
        'Qual o alvo das boas obras neste texto?',
        [
          ['a', 'Glorificar o Pai'],
          ['b', 'Conquistar likes'],
          ['c', 'Provar superioridade'],
          ['d', 'Evitar a Escritura'],
        ],
        'a',
        'Excelente.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:16',
      ],
      [
        'Por que esconder a luz contradiz a identidade do discípulo?',
        [
          ['a', 'Luz existe para iluminar'],
          ['b', 'Luz deve ser secreta sempre'],
          ['c', 'Jesus proíbe boas obras'],
          ['d', 'O mundo não precisa de luz'],
        ],
        'a',
        'Perfeito.',
        { b: 'Ele manda resplandecer.', c: 'Ele manda boas obras.', d: 'Precisa.' },
        'Mateus 5:14–16',
      ],
      [
        'Como Isaías 42:6 prepara esta metáfora?',
        [
          ['a', 'O povo/servo de Deus é luz para as nações'],
          ['b', 'Israel deveria se esconder'],
          ['c', 'Luz é só física'],
          ['d', 'Não há missão'],
        ],
        'a',
        'Muito bem.',
        { b: 'Não.', c: 'É testemunho.', d: 'Há.' },
        'Isaías 42:6',
      ],
      [
        'Qual diferença entre brilhar e se exibir?',
        [
          ['a', 'Brilhar aponta para o Pai; exibir aponta para o eu'],
          ['b', 'São idênticos'],
          ['c', 'Exibir é mais santo'],
          ['d', 'Brilhar é pecado'],
        ],
        'a',
        'Isso. Mateus 6 condena a justiça para ser vista.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:16',
      ],
      [
        'A cidade sobre o monte sugere:',
        [
          ['a', 'Comunidade do Reino visível e distintiva'],
          ['b', 'Urbanismo romano'],
          ['c', 'Esconderijo'],
          ['d', 'Templo pagão'],
        ],
        'a',
        'Correto.',
        { b: 'É metáfora.', c: 'É visibilidade.', d: 'Não.' },
        'Mateus 5:14',
      ],
    ],
    profundezas: [
      [
        'Minhas obras fazem as pessoas olharem para mim — ou para o Pai?',
        [
          ['a', 'Ajustar o testemunho para glorificar a Deus'],
          ['b', 'Buscar mais aplauso'],
          ['c', 'Esconder toda boa obra por medo'],
          ['d', 'Abandonar boas obras'],
        ],
        'a',
        'Perfeito.',
        { b: 'Alvo errado.', c: 'Jesus manda brilhar com propósito.', d: 'Não.' },
        'Mateus 5:16',
      ],
      [
        'Como João 8:12 se relaciona com “vós sois a luz”?',
        [
          ['a', 'Discípulos refletem a luz de Cristo, a Luz verdadeira'],
          ['b', 'Discípulos substituem Jesus'],
          ['c', 'Jesus não é luz'],
          ['d', 'Luz humana basta sem Cristo'],
        ],
        'a',
        'Excelente.',
        { b: 'Não.', c: 'Ele é.', d: 'Dependemos Dele.' },
        'João 8:12',
      ],
      [
        'Em um ambiente hostil à fé, “não esconder a candeia” pode significar:',
        [
          ['a', 'Testemunhar com sabedoria e coerência de vida'],
          ['b', 'Ser agressivo e sem amor'],
          ['c', 'Negar a fé'],
          ['d', 'Viver em hipocrisia'],
        ],
        'a',
        'Muito bem.',
        { b: 'Luz com caráter.', c: 'Não.', d: 'Não.' },
        'Mateus 5:14–16',
      ],
      [
        'Efésios 5:8 chama crentes de luz no Senhor. O que isso exige?',
        [
          ['a', 'Andar como filhos da luz'],
          ['b', 'Voltar às trevas'],
          ['c', 'Ignorar a ética'],
          ['d', 'Esconder o evangelho'],
        ],
        'a',
        'Isso.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Efésios 5:8',
      ],
      [
        'Qual combinação resume sal + luz?',
        [
          ['a', 'Presença distintiva + testemunho visível que glorifica a Deus'],
          ['b', 'Isolamento + silêncio'],
          ['c', 'Poder + violência'],
          ['d', 'Riqueza + fama'],
        ],
        'a',
        'Perfeito.',
        { b: 'Contrário ao texto.', c: 'Não.', d: 'Não.' },
        'Mateus 5:13–16',
      ],
    ],
  },

  'sm-12-jesus-e-a-lei': {
    semente: [
      [
        'Jesus veio para quê, segundo Mateus 5:17?',
        [
          ['a', 'Cumprir a Lei e os Profetas'],
          ['b', 'Revogar a Lei'],
          ['c', 'Ignorar os Profetas'],
          ['d', 'Substituir Moisés por César'],
        ],
        'a',
        'Correto!',
        { b: 'Ele nega isso.', c: 'Não.', d: 'Não.' },
        'Mateus 5:17',
      ],
      [
        'O que Jesus diz sobre a Lei até que tudo se cumpra?',
        [
          ['a', 'Nem um iota ou til passará'],
          ['b', 'Tudo já foi cancelado'],
          ['c', 'Só os Dez Mandamentos importam e nada mais'],
          ['d', 'A Lei era erro'],
        ],
        'a',
        'Exato.',
        { b: 'Não.', c: 'Ele fala da Escritura como um todo.', d: 'Não.' },
        'Mateus 5:18',
      ],
      [
        'Quem for solto e ensinar outros a relaxar mandamentos será chamado:',
        [
          ['a', 'O menor no Reino'],
          ['b', 'O maior no Reino'],
          ['c', 'Profeta de Roma'],
          ['d', 'Sumo sacerdote'],
        ],
        'a',
        'Correto.',
        { b: 'O maior é quem pratica e ensina.', c: 'Não.', d: 'Não.' },
        'Mateus 5:19',
      ],
      [
        'A justiça do discípulo deve exceder a de quem?',
        [
          ['a', 'Escribas e fariseus'],
          ['b', 'Os anjos'],
          ['c', 'Noé apenas'],
          ['d', 'Os romanos'],
        ],
        'a',
        'Perfeito.',
        { b: 'Não é a comparação.', c: 'Não.', d: 'Não.' },
        'Mateus 5:20',
      ],
      [
        'Sem essa justiça mais profunda, Jesus diz que:',
        [
          ['a', 'Não entrareis no Reino dos céus'],
          ['b', 'Sereis ricos'],
          ['c', 'Sereis reis'],
          ['d', 'Nada acontece'],
        ],
        'a',
        'Isso. Exigência radical do Reino.',
        { b: 'Não.', c: 'Não.', d: 'Há consequência.' },
        'Mateus 5:20',
      ],
    ],
    caminhada: [
      [
        '“Cumprir” a Lei, no sentido de Jesus, significa principalmente:',
        [
          ['a', 'Levar a Escritura à sua realização plena'],
          ['b', 'Apagar o Antigo Testamento'],
          ['c', 'Criar uma religião sem ética'],
          ['d', 'Imitar fariseus'],
        ],
        'a',
        'Excelente.',
        { b: 'Ele cumpre, não apaga.', c: 'Não.', d: 'Ele aprofunda além deles.' },
        'Mateus 5:17',
      ],
      [
        'Por que a justiça farisaica é insuficiente?',
        [
          ['a', 'Muitas vezes fica na aparência externa'],
          ['b', 'Eles liam demais a Bíblia'],
          ['c', 'Eles oravam demais'],
          ['d', 'Eles conheciam a Lei'],
        ],
        'a',
        'Muito bem. Mateus 23 ilustra isso.',
        { b: 'Não é o problema.', c: 'Não.', d: 'Conhecer é bom; incoerência não.' },
        'Mateus 5:20',
      ],
      [
        'Como Jeremias 31:33 conecta-se a este ensino?',
        [
          ['a', 'A Lei escrita no coração'],
          ['b', 'A Lei cancelada'],
          ['c', 'Só ritual importa'],
          ['d', 'Sem aliança'],
        ],
        'a',
        'Perfeito.',
        { b: 'Não.', c: 'Não.', d: 'Nova aliança.' },
        'Jeremias 31:33',
      ],
      [
        'Este texto prepara as antíteses (“eu, porém, vos digo”) ao ensinar que:',
        [
          ['a', 'Jesus aprofunda a Lei até o coração'],
          ['b', 'Jesus rejeita Moisés'],
          ['c', 'Não haverá mais ética'],
          ['d', 'Só milagres importam'],
        ],
        'a',
        'Isso.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:17–20',
      ],
      [
        'Romanos 3:31 afirma que a fé:',
        [
          ['a', 'Não anula a Lei, antes a confirma'],
          ['b', 'Destrói a Lei'],
          ['c', 'Dispensa obediência'],
          ['d', 'É mérito humano'],
        ],
        'a',
        'Correto.',
        { b: 'Não.', c: 'Não.', d: 'É graça.' },
        'Romanos 3:31',
      ],
    ],
    profundezas: [
      [
        'Minha obediência para na aparência — ou alcança o coração?',
        [
          ['a', 'Pedir a Deus justiça interior genuína'],
          ['b', 'Aumentar só o teatro religioso'],
          ['c', 'Abandonar a Lei toda'],
          ['d', 'Julgar todos sem se examinar'],
        ],
        'a',
        'Perfeito.',
        { b: 'Jesus exige mais.', c: 'Ele cumpre e aprofunda.', d: 'Começa em nós.' },
        'Mateus 5:20',
      ],
      [
        'Como viver “justiça que excede” sem cair em legalismo?',
        [
          ['a', 'Dependendo de Cristo e do Espírito, do interior para fora'],
          ['b', 'Somando regras humanas'],
          ['c', 'Competindo em piedade'],
          ['d', 'Ignorando a Escritura'],
        ],
        'a',
        'Excelente. Romanos 8:4.',
        { b: 'Farisaísmo.', c: 'Orgulho.', d: 'Não.' },
        'Romanos 8:4',
      ],
      [
        'O que muda se Jesus é o cumprimento da Lei?',
        [
          ['a', 'Lemos Moisés e os Profetas à luz de Cristo'],
          ['b', 'Descartamos o AT'],
          ['c', 'Viramos antinomistas'],
          ['d', 'A ética fica opcional'],
        ],
        'a',
        'Muito bem.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:17',
      ],
      [
        'Qual risco Jesus combate em 5:19?',
        [
          ['a', 'Ensinar outros a relativizar a vontade de Deus'],
          ['b', 'Ensinar demais'],
          ['c', 'Memorizar a Escritura'],
          ['d', 'Obedecer'],
        ],
        'a',
        'Isso.',
        { b: 'Não.', c: 'Não.', d: 'Obedecer é elogiado.' },
        'Mateus 5:19',
      ],
      [
        'Como este passo liga Cena 2 (caráter) à ética prática que vem?',
        [
          ['a', 'Coração transformado → obediência mais profunda que a aparência'],
          ['b', 'Ética sem coração'],
          ['c', 'Coração sem ética'],
          ['d', 'Nenhuma ligação'],
        ],
        'a',
        'Perfeito.',
        { b: 'Não.', c: 'Não.', d: 'Há progressão clara.' },
        'Mateus 5:17–20',
      ],
    ],
  },

  'sm-13-ira-e-reconciliacao': {
    semente: [
      [
        'O mandamento antigo citado por Jesus é:',
        [
          ['a', 'Não matarás'],
          ['b', 'Não furtarás'],
          ['c', 'Honra teu pai'],
          ['d', 'Guarda o sábado'],
        ],
        'a',
        'Correto.',
        { b: 'Não neste texto.', c: 'Não.', d: 'Não.' },
        'Mateus 5:21',
      ],
      [
        'Jesus diz que quem se irar contra o irmão:',
        [
          ['a', 'Estará sujeito a julgamento'],
          ['b', 'Será recompensado'],
          ['c', 'É automaticamente inocente'],
          ['d', 'Deve ignorar o assunto'],
        ],
        'a',
        'Exato.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:22',
      ],
      [
        'Antes de oferecer no altar, o discípulo deve:',
        [
          ['a', 'Reconciliar-se com o irmão'],
          ['b', 'Aumentar a oferta'],
          ['c', 'Esconder o conflito'],
          ['d', 'Acusar publicamente'],
        ],
        'a',
        'Perfeito.',
        { b: 'Relacionamento vem primeiro.', c: 'Não.', d: 'Não.' },
        'Mateus 5:23–24',
      ],
      [
        'Jesus recomenda reconciliar-se:',
        [
          ['a', 'Depressa / enquanto estás com o adversário a caminho'],
          ['b', 'Nunca'],
          ['c', 'Só depois de anos'],
          ['d', 'Só se a outra pessoa pedir'],
        ],
        'a',
        'Correto. Urgência.',
        { b: 'Não.', c: 'Não.', d: 'Iniciativa importa.' },
        'Mateus 5:25',
      ],
      [
        'Insultos como “raça” no texto mostram que:',
        [
          ['a', 'Palavras de desprezo também são julgadas'],
          ['b', 'Só ações físicas importam'],
          ['c', 'Xingamentos são virtudes'],
          ['d', 'Língua não peca'],
        ],
        'a',
        'Isso.',
        { b: 'Jesus aprofunda.', c: 'Não.', d: 'Não.' },
        'Mateus 5:22',
      ],
    ],
    caminhada: [
      [
        'Qual é o movimento da antítese neste texto?',
        [
          ['a', 'Do ato externo (matar) para o coração (ira/desprezo)'],
          ['b', 'Cancelar o mandamento'],
          ['c', 'Incentivar a violência'],
          ['d', 'Focar só em ritual'],
        ],
        'a',
        'Excelente.',
        { b: 'Ele aprofunda.', c: 'Não.', d: 'Não.' },
        'Mateus 5:21–22',
      ],
      [
        'Por que a reconciliação precede a oferta?',
        [
          ['a', 'Relacionamento quebrado compromete a adoração genuína'],
          ['b', 'Deus prefere conflito'],
          ['c', 'Oferta é inútil sempre'],
          ['d', 'Irmãos não importam'],
        ],
        'a',
        'Muito bem.',
        { b: 'Não.', c: 'Oferta importa no contexto certo.', d: 'Importam.' },
        'Mateus 5:23–24',
      ],
      [
        'Como 1 João 3:15 ecoa este ensino?',
        [
          ['a', 'Odiar o irmão é homicida'],
          ['b', 'Ódio é irrelevante'],
          ['c', 'Só ações contam'],
          ['d', 'Amor é opcional'],
        ],
        'a',
        'Perfeito.',
        { b: 'Não.', c: 'Coração conta.', d: 'Não.' },
        '1 João 3:15',
      ],
      [
        'Efésios 4:26–27 ensina sobre a ira:',
        [
          ['a', 'Não pecar na ira e não dar lugar ao diabo'],
          ['b', 'Cultivar ira sem limites'],
          ['c', 'Nunca sentir nada'],
          ['d', 'Explodir sempre'],
        ],
        'a',
        'Correto.',
        { b: 'Não.', c: 'Há ira justa, mas sem pecado.', d: 'Não.' },
        'Efésios 4:26–27',
      ],
      [
        '“Adversário a caminho” ilustra:',
        [
          ['a', 'Urgência de resolver conflito antes das consequências'],
          ['b', 'Viagem turística'],
          ['c', 'Guerra santa'],
          ['d', 'Ignorar processos'],
        ],
        'a',
        'Isso.',
        { b: 'É parábola prática.', c: 'Não.', d: 'Não.' },
        'Mateus 5:25–26',
      ],
    ],
    profundezas: [
      [
        'Há alguém com quem preciso me reconciliar antes de continuar “adorando”?',
        [
          ['a', 'Sim — priorizar a reconciliação concreta'],
          ['b', 'Não — culto cobre tudo automaticamente'],
          ['c', 'Só se eu estiver certo'],
          ['d', 'Esperar a outra pessoa sofrer primeiro'],
        ],
        'a',
        'Perfeito. Jesus coloca urgência nisso.',
        { b: 'Ele discorda.', c: 'Iniciativa do discípulo.', d: 'Não.' },
        'Mateus 5:23–24',
      ],
      [
        'Qual ira o Reino confronta neste texto?',
        [
          ['a', 'Ira destrutiva, insulto e desprezo contra o irmão'],
          ['b', 'Qualquer emoção humana'],
          ['c', 'Zelo santo por justiça'],
          ['d', 'Luto'],
        ],
        'a',
        'Excelente.',
        { b: 'Há distinção.', c: 'Não é o alvo aqui.', d: 'Não.' },
        'Mateus 5:22',
      ],
      [
        'Em uma discussão familiar inflamada, o cidadão do Reino:',
        [
          ['a', 'Busca reconciliação rápida, sem humilhar'],
          ['b', 'Guarda rancor como “direito”'],
          ['c', 'Xingа para vencer'],
          ['d', 'Finge adoração e ignora o vínculo'],
        ],
        'a',
        'Muito bem.',
        { b: 'Contrário ao texto.', c: 'Julgamento sobre insultos.', d: 'Altar espera.' },
        'Mateus 5:22–24',
      ],
      [
        'Como este passo conecta-se aos pacificadores (5:9)?',
        [
          ['a', 'Paz do Reino se prova na reconciliação prática'],
          ['b', 'Não há ligação'],
          ['c', 'Pacificadores evitam toda conversa'],
          ['d', 'Ira substitui a paz'],
        ],
        'a',
        'Isso.',
        { b: 'Há progressão.', c: 'Não.', d: 'Não.' },
        'Mateus 5:9,23–24',
      ],
      [
        'Romanos 12:18 limita a paz ao “se possível”. O que isso ensina?',
        [
          ['a', 'Faça a sua parte; o outro pode recusar'],
          ['b', 'Nunca tente'],
          ['c', 'Force reconcilição abusiva'],
          ['d', 'Paz é impossível sempre'],
        ],
        'a',
        'Correto. Responsabilidade do discípulo.',
        { b: 'Tente.', c: 'Sabedoria e segurança importam.', d: 'Não.' },
        'Romanos 12:18',
      ],
    ],
  },

  'sm-boss-03-identidade-e-missao': {
    semente: [
      [
        '“Vós sois o sal da terra” fala principalmente de:',
        [
          ['a', 'Influência preservadora dos discípulos'],
          ['b', 'Receita de cozinha'],
          ['c', 'Imposto'],
          ['d', 'Arquitetura'],
        ],
        'a',
        'Correto.',
        { b: 'Metáfora.', c: 'Não.', d: 'Não.' },
        'Mateus 5:13',
      ],
      [
        'A luz dos discípulos deve levar as pessoas a:',
        [
          ['a', 'Glorificar o Pai'],
          ['b', 'Idolatrar o discípulo'],
          ['c', 'Esconder o evangelho'],
          ['d', 'Odiar a igreja'],
        ],
        'a',
        'Exato.',
        { b: 'Alvo é Deus.', c: 'Não.', d: 'Não.' },
        'Mateus 5:16',
      ],
      [
        'Jesus veio para:',
        [
          ['a', 'Cumprir a Lei e os Profetas'],
          ['b', 'Revogar a Lei'],
          ['c', 'Ignorar Moisés'],
          ['d', 'Cancelar a ética'],
        ],
        'a',
        'Perfeito.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:17',
      ],
      [
        'Antes da oferta no altar, Jesus manda:',
        [
          ['a', 'Reconciliar-se com o irmão'],
          ['b', 'Aumentar o valor'],
          ['c', 'Ignorar o conflito'],
          ['d', 'Acusar em público'],
        ],
        'a',
        'Correto.',
        { b: 'Não é o ponto.', c: 'Não.', d: 'Não.' },
        'Mateus 5:23–24',
      ],
      [
        'Qual sequência resume a Cena 3?',
        [
          ['a', 'Sal → Luz → Cumprir a Lei → Ira/reconciliação'],
          ['b', 'Dilúvio → Babel → Egito'],
          ['c', 'Pobres → Mansos → Misericórdia'],
          ['d', 'Cruz → Pentecostes → Roma'],
        ],
        'a',
        'Excelente.',
        { b: 'Outra trilha.', c: 'Cenas 1–2.', d: 'Outro arco.' },
        'Mateus 5:13–26',
      ],
    ],
    caminhada: [
      [
        'Sal e luz juntos ensinam que o discípulo é:',
        [
          ['a', 'Presença distintiva e testemunho visível'],
          ['b', 'Invisível e irrelevante'],
          ['c', 'Apenas crítico'],
          ['d', 'Apenas isolado'],
        ],
        'a',
        'Muito bem.',
        { b: 'Não.', c: 'Incompleto.', d: 'Não.' },
        'Mateus 5:13–16',
      ],
      [
        'A justiça que excede a dos fariseus é:',
        [
          ['a', 'Mais profunda — alcança o coração'],
          ['b', 'Mais teatral'],
          ['c', 'Mais rica'],
          ['d', 'Mais política'],
        ],
        'a',
        'Perfeito.',
        { b: 'Contrário.', c: 'Não.', d: 'Não.' },
        'Mateus 5:20',
      ],
      [
        'A primeira antítese (ira) mostra que:',
        [
          ['a', 'O sexto mandamento começa no coração'],
          ['b', 'Matar nunca importa'],
          ['c', 'Palavras são neutras'],
          ['d', 'Culto substitui reconciliação'],
        ],
        'a',
        'Isso.',
        { b: 'Importa.', c: 'Não.', d: 'Jesus inverte a ordem.' },
        'Mateus 5:21–24',
      ],
      [
        'Qual elo une luz (5:16) e reconciliação (5:23–24)?',
        [
          ['a', 'Testemunho autêntico inclui relacionamentos restaurados'],
          ['b', 'Não há elo'],
          ['c', 'Luz dispensa ética'],
          ['d', 'Reconciliação é opcional'],
        ],
        'a',
        'Excelente.',
        { b: 'Há.', c: 'Não.', d: 'Não.' },
        'Mateus 5:16,23–24',
      ],
      [
        '“Não vim revogar” protege a igreja de qual erro?',
        [
          ['a', 'Descartar o AT / relativizar a vontade de Deus'],
          ['b', 'Ler demais a Escritura'],
          ['c', 'Orar'],
          ['d', 'Fazer o bem'],
        ],
        'a',
        'Correto.',
        { b: 'Não.', c: 'Não.', d: 'Não.' },
        'Mateus 5:17',
      ],
    ],
    profundezas: [
      [
        'Qual aplicação resume a Cena 3?',
        [
          ['a', 'Viver distinto e visível, sob a Lei cumprida em Cristo, reconciliando-se com urgência'],
          ['b', 'Esconder a fé e guardar rancor'],
          ['c', 'Parecer santo sem mudar o coração'],
          ['d', 'Revogar a ética bíblica'],
        ],
        'a',
        'Excelente síntese.',
        { b: 'Contrário.', c: 'Insuficiente.', d: 'Não.' },
        'Mateus 5:13–26',
      ],
      [
        'Se sou “luz” mas vivo em ira não reconciliada, o que falta?',
        [
          ['a', 'Coerência entre testemunho e relacionamentos'],
          ['b', 'Mais posts religiosos'],
          ['c', 'Mais isolamento'],
          ['d', 'Mais insultos'],
        ],
        'a',
        'Isso.',
        { b: 'Não resolve.', c: 'Não.', d: 'Não.' },
        'Mateus 5:16,22–24',
      ],
      [
        'Como sal/luz evitam tanto isolamento quanto acomodação?',
        [
          ['a', 'Estar no mundo com distinção santa'],
          ['b', 'Fugir de tudo'],
          ['c', 'Copiar tudo'],
          ['d', 'Odiar o mundo'],
        ],
        'a',
        'Perfeito.',
        { b: 'Sal precisa de contato.', c: 'Insípido.', d: 'Não.' },
        'Mateus 5:13–16',
      ],
      [
        'Qual passo prático Jesus prioriza neste bloco?',
        [
          ['a', 'Ir primeiro reconciliar-se'],
          ['b', 'Aumentar a oferta sem diálogo'],
          ['c', 'Vencer o debate'],
          ['d', 'Esperar sentimentos perfeitos'],
        ],
        'a',
        'Muito bem.',
        { b: 'Altar espera.', c: 'Não.', d: 'Ação precede sentimento.' },
        'Mateus 5:24',
      ],
      [
        'Como as Cenas 1–3 formam um arco?',
        [
          ['a', 'Identidade interior → caráter relacional → missão ética no mundo'],
          ['b', 'Só milagres'],
          ['c', 'Só genealogia'],
          ['d', 'Só juízo sem graça'],
        ],
        'a',
        'Excelente progressão pedagógica.',
        { b: 'Incompleto.', c: 'Não.', d: 'Há graça e exigência.' },
        'Mateus 5:1–26',
      ],
    ],
  },
};

// Fix typo Xingа -> Xinga in one option - use ASCII
// already wrote Xingа with cyrillic possibly - check in file when writing

// Assemble bank
let bank = [];
for (const [section, levels] of Object.entries(banks)) {
  bank = bank.concat(pack(section, levels));
}

// Fix cyrillic a if any
for (const qq of bank) {
  for (const o of qq.options) {
    o.text = o.text.replace(/Xingа/g, 'Xinga');
  }
}

const trails = JSON.parse(readFileSync(join(assets, 'trails.json'), 'utf8'));
const trail = trails.find((t) => t.slug === 'sermao-do-monte');
const existingIdx = trail.modules.findIndex((m) => m.section === 'identidade-e-missao');
if (existingIdx >= 0) trail.modules[existingIdx] = module3;
else trail.modules.push(module3);
writeFileSync(join(assets, 'trails.json'), JSON.stringify(trails, null, 2) + '\n');

const studiesData = JSON.parse(readFileSync(join(assets, 'mission_studies.json'), 'utf8'));
Object.assign(studiesData.studies, studies);
Object.assign(studiesData.verses || (studiesData.verses = {}), {
  'Mateus 5:13':
    'Vós sois o sal da terra; ora, se o sal vier a ser insípido, como lhe restaurar o sabor?',
  'Mateus 5:14–16': studies['sm-11-luz-do-mundo'].passageText,
  'Mateus 5:17–20':
    'Não penseis que vim revogar a Lei ou os Profetas; não vim para revogar, vim para cumprir…',
  'Mateus 5:21–26': studies['sm-13-ira-e-reconciliacao'].passageText,
  'Mateus 5:13–26': 'Vós sois o sal… luz… cumprir a Lei… ira e reconciliação…',
  'Levítico 2:13': 'Tempera com sal a tua oferta de cereais… sal da aliança do teu Deus.',
  'Colossenses 4:6': 'A vossa palavra seja sempre com graça, temperada com sal…',
  'Marcos 9:50': 'O sal é bom; … tende sal em vós mesmos e paz uns com os outros.',
  'Isaías 42:6': '… e te darei… por luz das nações.',
  'João 8:12': 'Eu sou a luz do mundo; quem me segue não andará em trevas…',
  'Efésios 5:8': 'Outrora éreis trevas; porém, agora, sois luz no Senhor…',
  'Filipenses 2:15': '… resplandeceis como luzeiros no mundo.',
  'Romanos 3:31': 'Anulamos, pois, a Lei pela fé? Não, de maneira nenhuma! Antes, confirmamos a Lei.',
  'Romanos 8:4': '… a fim de que o preceito da Lei se cumprisse em nós…',
  'Jeremias 31:33': '… porei a minha Lei no seu íntimo…',
  'Êxodo 20:13': 'Não matarás.',
  '1 João 3:15': 'Todo o que odeia a seu irmão é homicida…',
  'Efésios 4:26–27': 'Irai-vos e não pequeis… nem deis lugar ao diabo.',
  'Romanos 12:18': 'Se possível, no que depender de vós, tende paz com todos.',
});
writeFileSync(join(assets, 'mission_studies.json'), JSON.stringify(studiesData, null, 2) + '\n');

const bankPath = join(assets, 'sermao_questions.json');
const bankData = JSON.parse(readFileSync(bankPath, 'utf8'));
const drop = new Set(Object.keys(banks));
bankData.questions = bankData.questions.filter((qq) => !drop.has(qq.section));
bankData.questions.push(...bank);
writeFileSync(bankPath, JSON.stringify(bankData, null, 2) + '\n');

console.log('Cena 3:', module3.missions.map((m) => m.slug).join(' → '));
console.log(`+${bank.length} perguntas · banco total ${bankData.questions.length}`);
console.log(`estudos: ${Object.keys(studies).join(', ')}`);
