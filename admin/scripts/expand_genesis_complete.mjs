/**
 * Expande Gênesis 12–50 para cobertura completa dos capítulos,
 * com 3 dificuldades (5 Q/passo) + preparos densos.
 *
 * Mantém genesis-1-11 intacto (já completo com banco).
 *
 * Usage: node scripts/expand_genesis_complete.mjs
 */
import { readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const dataRoot = join(__dirname, '..', '..', 'trilha_app', 'assets', 'data');

function readJson(name) {
  return JSON.parse(readFileSync(join(dataRoot, name), 'utf8'));
}
function writeJson(name, data) {
  writeFileSync(join(dataRoot, name), `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

const DIFFS = ['semente', 'caminhada', 'profundezas'];
const DIFF_SHORT = { semente: 'sem', caminhada: 'cam', profundezas: 'pro' };

/** Currículo Gênesis 12–50 — cada passo cobre um arco de capítulos. */
const MODULES = [
  {
    title: 'Abraão',
    section: 'abraao',
    icon: '🌟',
    missions: [
      {
        slug: 'gen12-01-chamado',
        title: 'O chamado de Abrão',
        chapters: [12],
        intro:
          'Deixa a terra, a parentela e a casa do pai — a promessa começa com um passo de fé.',
        keyword: 'Chamado',
        keywordGloss:
          'Deus inicia a aliança chamando Abrão a sair: obediência abre a bênção às nações.',
        focus: 'O que Abrão deixa para trás — e o que Deus promete à frente?',
        facts: [
          ['Para onde Deus manda Abrão ir?', 'Para a terra que Ele mostraria', 'De volta a Ur', 'Só ao Egito', 'Para Babel'],
          ['Quem viaja com Abrão?', 'Sarai e Ló', 'Só Isaque', 'Faraó', 'Melquisedeque'],
          ['O que Deus promete tornar Abrão?', 'Uma grande nação', 'Um rei do Egito', 'Um juiz em Canaã', 'Um sacerdote em Ur'],
        ],
      },
      {
        slug: 'gen12-02-egito-e-lot',
        title: 'Egito e a separação de Ló',
        chapters: [12, 13],
        intro:
          'Fome leva Abrão ao Egito; depois, ele e Ló se separam — Abrão fica com a promessa, Ló escolhe a planície.',
        keyword: 'Separação',
        keywordGloss:
          'A fé às vezes exige soltar o que compete com a promessa — Abrão cede a Ló e Deus renova a aliança.',
        focus: 'O que a escolha de Ló revela sobre o que valorizamos?',
        facts: [
          ['Por que Abrão desce ao Egito?', 'Por causa da fome', 'Para guerrear', 'Para comprar terra', 'Para achar Isaque'],
          ['O que Ló escolhe?', 'A planície do Jordão', 'As montanhas de Ur', 'O deserto de Sur', 'Hebrom somente'],
          ['Depois da separação, o que Deus mostra a Abrão?', 'A terra em todas as direções', 'Um trono no Egito', 'A torre de Babel', 'O dilúvio'],
        ],
      },
      {
        slug: 'gen12-03-melquisedeque',
        title: 'Guerra e Melquisedeque',
        chapters: [14],
        intro:
          'Abrão resgata Ló e encontra Melquisedeque, rei de Salém — pão, vinho e bênção no nome do Deus Altíssimo.',
        keyword: 'Melquisedeque',
        keywordGloss:
          'Rei-sacerdote que abençoa Abrão: antecipação de um sacerdócio maior que o de Levi.',
        focus: 'Por que Abrão recusa os bens de Sodoma?',
        facts: [
          ['Quem Abrão resgata?', 'Ló', 'Sarai', 'Isaque', 'Ismael'],
          ['Quem é Melquisedeque?', 'Rei de Salém e sacerdote', 'Rei de Sodoma', 'Faraó', 'Um anjo'],
          ['O que Abrão dá a Melquisedeque?', 'O dízimo', 'Toda a terra', 'Seu filho', 'As ovelhas de Ló'],
        ],
      },
      {
        slug: 'gen12-04-alianca-estrelas',
        title: 'A aliança das estrelas',
        chapters: [15],
        intro:
          'Abrão crê — e isso lhe é imputado por justiça. Deus corta aliança: descendência como as estrelas.',
        keyword: 'Fé',
        keywordGloss:
          'Crer na promessa de Deus é o coração da aliança — justiça pela fé, antes da Lei.',
        focus: 'O que significa “creu Abrão no Senhor”?',
        facts: [
          ['O que Deus conta a Abrão no céu?', 'As estrelas — sua descendência', 'Os dias do dilúvio', 'Os reis de Canaã', 'Os anjos caídos'],
          ['Como Abrão é declarado justo?', 'Pela fé', 'Pelas obras da Lei', 'Pelo dízimo', 'Pela circuncisão só'],
          ['O que passa entre os pedaços na aliança?', 'Um forno fumegante e uma tocha', 'Um anjo com espada', 'A arca', 'O Jordão'],
        ],
      },
      {
        slug: 'gen12-05-agar-ismael',
        title: 'Agar e Ismael',
        chapters: [16],
        intro:
          'Impaciência gera um atalho: Agar concebe Ismael. Deus vê a aflita — El-Roi.',
        keyword: 'El-Roi',
        keywordGloss:
          '“Deus que me vê”: mesmo no desvio, Deus cuida de Agar e da criança.',
        focus: 'O que acontece quando tentamos “ajudar” a promessa de Deus?',
        facts: [
          ['Quem é Agar?', 'Serva egípcia de Sarai', 'Irmã de Abrão', 'Filha de Ló', 'Rainha de Salém'],
          ['Como se chama o filho de Agar?', 'Ismael', 'Isaque', 'Esaú', 'José'],
          ['Que nome Agar dá a Deus?', 'El-Roi — Deus que me vê', 'Jeová-Jiré', 'Emanuel', 'Adonai'],
        ],
      },
      {
        slug: 'gen12-06-circuncisao',
        title: 'Nomes novos e circuncisão',
        chapters: [17],
        intro:
          'Abrão vira Abraão; Sarai vira Sara. A circuncisão sela a aliança — e Isaque é anunciado.',
        keyword: 'Aliança',
        keywordGloss:
          'Deus renomeia e marca o povo: a aliança tem sinal no corpo e promessa no coração.',
        focus: 'Por que Deus muda os nomes de Abrão e Sarai?',
        facts: [
          ['Qual o novo nome de Abrão?', 'Abraão', 'Israel', 'Isaque', 'Efraim'],
          ['O sinal da aliança neste capítulo é:', 'A circuncisão', 'O arco-íris', 'O batismo', 'O dízimo'],
          ['Que filho é prometido a Sara?', 'Isaque', 'Ismael', 'Jacó', 'José'],
        ],
      },
      {
        slug: 'gen12-07-sodoma',
        title: 'Visitantes e Sodoma',
        chapters: [18, 19],
        intro:
          'Três visitantes; Abraão intercede. Sodoma cai — e Ló é tirado. A justiça de Deus e a misericórdia se encontram.',
        keyword: 'Intercessão',
        keywordGloss:
          'Abraão ousa negociar com Deus por causa dos justos — coração de mediador.',
        focus: 'O que a intercessão de Abraão ensina sobre orar pelos outros?',
        facts: [
          ['O que Abraão pede a Deus por Sodoma?', 'Poupar a cidade por causa dos justos', 'Destruir Ló', 'Dar-lhe o trono', 'Acabar com Ismael'],
          ['Quem é salvo de Sodoma?', 'Ló e suas filhas', 'O rei de Sodoma', 'Todos os moradores', 'Melquisedeque'],
          ['Em que se transforma a mulher de Ló?', 'Em estátua de sal', 'Em pomba', 'Em árvore', 'Em rio'],
        ],
      },
      {
        slug: 'gen12-08-isaque-nasce',
        title: 'Isaque nasce',
        chapters: [20, 21],
        intro:
          'No tempo de Deus, Sara ri de alegria: Isaque nasce. Abimeleque e a aliança mostram que Deus guarda a promessa.',
        keyword: 'Isaque',
        keywordGloss:
          '“Ele ri”: o filho da promessa chega quando já parecia impossível.',
        focus: 'Como o nascimento de Isaque confirma a fidelidade de Deus?',
        facts: [
          ['Quem nasce a Abraão e Sara?', 'Isaque', 'Ismael', 'Esaú', 'Benjamim'],
          ['O que o nome Isaque evoca?', 'Riso', 'Guerra', 'Fome', 'Exílio'],
          ['O que acontece com Agar e Ismael?', 'São enviados; Deus os sustém', 'Recebem a terra de Canaã', 'Tornam-se reis de Salém', 'Morrem no deserto sem cuidado'],
        ],
      },
      {
        slug: 'gen12-09-moria',
        title: 'Moriá — o filho oferecido',
        chapters: [22],
        intro:
          'O teste máximo: oferecer Isaque. No monte, Deus provê o cordeiro. Jeová-Jiré.',
        keyword: 'Jeová-Jiré',
        keywordGloss:
          '“O Senhor proverá”: fé que entrega o mais amado e encontra provisão no altar.',
        focus: 'O que Abraão aprende sobre Deus em Moriá?',
        facts: [
          ['O que Deus pede a Abraão?', 'Oferecer Isaque', 'Oferecer Ismael', 'Queimar Sodoma', 'Voltar a Ur'],
          ['O que Deus provê no lugar de Isaque?', 'Um carneiro', 'Uma pomba', 'Ouro', 'Pão'],
          ['Como Abraão chama aquele lugar?', 'Jeová-Jiré', 'Betel', 'Peniel', 'Éden'],
        ],
      },
      {
        slug: 'gen12-boss-abraao',
        title: 'Desafio: Abraão',
        chapters: [12, 15, 22],
        intro:
          'Do chamado a Moriá — una fé, aliança e provisão na jornada de Abraão.',
        keyword: 'Promessa',
        keywordGloss:
          'A vida de Abraão é escola de confiança: sair, crer, esperar e entregar.',
        focus: 'Qual o fio que liga o chamado, a aliança e Moriá?',
        type: 'boss',
        facts: [
          ['O que marca o início da jornada de Abrão?', 'O chamado para sair', 'A torre de Babel', 'O dilúvio', 'A venda de José'],
          ['Como Abrão é justificado em Gênesis 15?', 'Pela fé', 'Pela circuncisão apenas', 'Pelo resgate de Ló', 'Pela riqueza'],
          ['Em Moriá, o que Deus revela?', 'Que Ele provê', 'Que a promessa acabou', 'Que Ismael é o herdeiro', 'Que a Lei já chegou'],
        ],
      },
    ],
  },
  {
    title: 'Isaque e Jacó',
    section: 'jaco',
    icon: '⛺',
    missions: [
      {
        slug: 'gen12-10-rebeca',
        title: 'Isaque e Rebeca',
        chapters: [23, 24],
        intro:
          'Sara descansa; o servo ora no poço — e Rebeca aparece. A linha da promessa continua na próxima geração.',
        keyword: 'Providência',
        keywordGloss:
          'Deus guia o encontro no poço: a promessa não depende do acaso.',
        focus: 'Como a oração do servo mostra dependência de Deus?',
        facts: [
          ['Quem busca esposa para Isaque?', 'O servo de Abraão', 'Ló', 'Ismael', 'Esaú'],
          ['Onde o servo encontra Rebeca?', 'Junto ao poço', 'Em Sodoma', 'No Egito', 'Em Babel'],
          ['O que Rebeca faz pelos camelos?', 'Dá-lhes de beber', 'Vende-os', 'Esconde-os', 'Leva-os a Ur'],
        ],
      },
      {
        slug: 'gen12-11-esaue-jaco',
        title: 'Esaú e Jacó',
        chapters: [25, 26, 27],
        intro:
          'Dois povos no ventre. Isaque em Gerar; primogenitura trocada por um prato; bênção tomada com engano.',
        keyword: 'Primogenitura',
        keywordGloss:
          'A bênção da aliança é cobiçada — e o conflito familiar expõe o custo do engano.',
        focus: 'O que Jacó busca — e a que preço?',
        facts: [
          ['Quem nasce primeiro?', 'Esaú', 'Jacó', 'José', 'Benjamim'],
          ['O que Esaú troca por um prato de lentilhas?', 'A primogenitura', 'A terra de Canaã', 'O nome Israel', 'O poço'],
          ['Quem se disfarça para receber a bênção?', 'Jacó', 'Esaú', 'Isaque', 'Labão'],
        ],
      },
      {
        slug: 'gen12-12-betel',
        title: 'Betel — a escada',
        chapters: [28],
        intro:
          'Em fuga, Jacó sonha: escada entre céu e terra. Deus renova a promessa — este é Betel.',
        keyword: 'Betel',
        keywordGloss:
          '“Casa de Deus”: mesmo no exílio, o céu se abre e a aliança segue.',
        focus: 'O que o sonho da escada revela sobre a presença de Deus?',
        facts: [
          ['O que Jacó vê no sonho?', 'Uma escada com anjos', 'Um dilúvio', 'Sete vacas', 'Uma torre'],
          ['Como Jacó chama o lugar?', 'Betel', 'Peniel', 'Moriá', 'Salém'],
          ['O que Jacó promete a Deus?', 'O dízimo e que o Senhor será o seu Deus', 'Voltar a Ur', 'Destruir Esaú', 'Reinar no Egito'],
        ],
      },
      {
        slug: 'gen12-13-labao',
        title: 'Labão, Lia e Raquel',
        chapters: [29, 30, 31],
        intro:
          'Anos em Harã: engano de Labão, Lia e Raquel, filhos das tribos — e a fuga de volta à terra.',
        keyword: 'Espera',
        keywordGloss:
          'Jacó colhe o que plantou em engano — e Deus ainda tece a família da promessa.',
        focus: 'Como Deus trabalha mesmo em meio a rivalidade e espera?',
        facts: [
          ['Por quem Jacó serve sete anos?', 'Raquel', 'Lia', 'Rebeca', 'Agar'],
          ['Quem Labão dá a Jacó primeiro?', 'Lia', 'Raquel', 'Zilpa só', 'Bila só'],
          ['Quantos filhos Jacó tem neste arco (com as servas)?', 'Os que formam as tribos de Israel', 'Apenas dois', 'Doze reis do Egito', 'Nenhum'],
        ],
      },
      {
        slug: 'gen12-14-peniel',
        title: 'Peniel — luta e novo nome',
        chapters: [32, 33, 34, 35],
        intro:
          'Jacó luta e vira Israel; encontra Esaú; a família volta a Betel — feridas e renovação no caminho.',
        keyword: 'Israel',
        keywordGloss:
          '“Luta com Deus”: o novo nome marca um homem transformado pelo encontro.',
        focus: 'O que muda em Jacó depois de Peniel?',
        facts: [
          ['Qual o novo nome de Jacó?', 'Israel', 'Abraão', 'Efraim', 'Judá'],
          ['Como se chama o lugar da luta?', 'Peniel', 'Betel', 'Moriá', 'Éden'],
          ['Como Esaú recebe Jacó?', 'Com abraço', 'Com guerra', 'Com prisão', 'Com exílio'],
        ],
      },
      {
        slug: 'gen12-boss-jaco',
        title: 'Desafio: Isaque e Jacó',
        chapters: [25, 28, 32],
        intro:
          'Da rivalidade ao novo nome — una o fio de Isaque, Jacó e a promessa.',
        keyword: 'Transformação',
        keywordGloss:
          'De enganador a Israel: Deus não abandona a linha da promessa.',
        focus: 'Como Deus transforma Jacó ao longo da jornada?',
        type: 'boss',
        facts: [
          ['O conflito inicial é entre:', 'Esaú e Jacó', 'José e Benjamim', 'Abraão e Ló', 'Moisés e Faraó'],
          ['Em Betel, Jacó encontra:', 'A presença de Deus', 'O trono do Egito', 'A arca', 'O mar Vermelho'],
          ['Em Peniel, Jacó recebe:', 'Um novo nome', 'A Lei', 'O sacerdócio levítico', 'O dilúvio'],
        ],
      },
    ],
  },
  {
    title: 'José',
    section: 'jose',
    icon: ' palácio',
    missions: [
      {
        slug: 'gen12-15-sonhos',
        title: 'Sonhos e traição',
        chapters: [37, 38],
        intro:
          'Túnica, sonhos e ciúme: José é vendido. Judá e Tamar também revelam a linha messiânica no meio do fracasso.',
        keyword: 'Providência',
        keywordGloss:
          'Mesmo vendido, José é levado aonde a salvação da família será preparada — e Judá aponta para o futuro.',
        focus: 'Onde você vê Deus em meio à traição e ao fracasso familiar?',
        facts: [
          ['O que o pai dá a José?', 'Uma túnica especial', 'A espada de Esaú', 'O trono de Faraó', 'A terra de Ur'],
          ['O que os sonhos de José anunciam?', 'Que a família se inclinará a ele', 'O dilúvio', 'A torre de Babel', 'A Lei no Sinai'],
          ['Para onde José é levado?', 'Ao Egito', 'A Ur', 'A Sodoma', 'A Babel'],
        ],
      },
      {
        slug: 'gen12-16-potifar',
        title: 'Potifar e a prisão',
        chapters: [39],
        intro:
          'José prospera na casa de Potifar — e é acusado falsamente. Na prisão, o Senhor continua com ele.',
        keyword: 'Integridade',
        keywordGloss:
          'Fidelidade a Deus no privado: José recusa o pecado e sofre por justiça.',
        focus: 'O que a integridade de José custa — e vale?',
        facts: [
          ['Em cuja casa José serve?', 'Potifar', 'Faraó desde o início', 'Labão', 'Abimeleque'],
          ['Por que José é preso?', 'Acusação falsa da mulher de Potifar', 'Roubo de grãos', 'Matar um egípcio', 'Fugir para Canaã'],
          ['O que o texto enfatiza na prisão?', 'Que o Senhor era com José', 'Que Deus o abandonou', 'Que a promessa acabou', 'Que Ismael herdou tudo'],
        ],
      },
      {
        slug: 'gen12-17-farao',
        title: 'Do cárcere ao palácio',
        chapters: [40, 41],
        intro:
          'Sonhos do copeiro, do padeiro e de Faraó. José interpreta — e é posto sobre o Egito.',
        keyword: 'Sabedoria',
        keywordGloss:
          'Dom de Deus para tempos de crise: José prepara o mundo para a fome.',
        focus: 'Como o dom de José serve à salvação de muitos?',
        facts: [
          ['O que os sonhos de Faraó anunciam?', 'Sete anos de fartura e sete de fome', 'Um dilúvio', 'Guerra contra Canaã', 'A morte de José'],
          ['O que José aconselha?', 'Guardar grãos na fartura', 'Destruir o Egito', 'Voltar a Ur', 'Vender os sonhos'],
          ['Que posição José recebe?', 'Governador do Egito', 'Rei de Sodoma', 'Sacerdote de Salém', 'Juiz em Canaã'],
        ],
      },
      {
        slug: 'gen12-18-irmaos',
        title: 'Os irmãos diante de José',
        chapters: [42, 43, 44],
        intro:
          'A fome traz os irmãos ao Egito. José prova o coração deles — e Benjamim entra em cena.',
        keyword: 'Prova',
        keywordGloss:
          'José testa se os irmãos mudaram: a história da família está sendo reescrita.',
        focus: 'O que José procura ver nos irmãos?',
        facts: [
          ['Por que os irmãos vão ao Egito?', 'Comprar trigo', 'Buscar Abraão', 'Fazer guerra', 'Achar Melquisedeque'],
          ['Quem José manda trazer na segunda viagem?', 'Benjamim', 'Isaque', 'Esaú', 'Labão'],
          ['O que é colocado no saco de Benjamim?', 'O cálice de José', 'Ouro de Faraó', 'A túnica', 'Um ídolo'],
        ],
      },
      {
        slug: 'gen12-19-revelacao',
        title: 'José se revela',
        chapters: [45],
        intro:
          '“Eu sou José.” Choro, perdão e convite: Deus enviou-me adiante para preservar vidas.',
        keyword: 'Perdão',
        keywordGloss:
          'José lê a história com olhos de fé: o que fizeram para mal, Deus usou para bem.',
        focus: 'Como José interpreta o sofrimento à luz de Deus?',
        facts: [
          ['O que José diz sobre sua venda?', 'Deus o enviou adiante para preservar vidas', 'Foi só azar', 'Os irmãos venceram', 'A promessa morreu'],
          ['Quem José quer ver no Egito?', 'Seu pai Jacó', 'Abraão', 'Melquisedeque', 'Faraó morto'],
          ['Como os irmãos reagem à revelação?', 'Ficam atemorizados', 'Celebram na hora', 'Fogem para Babel', 'Atacam José'],
        ],
      },
      {
        slug: 'gen12-20-egito-bencao',
        title: 'Jacó no Egito e a bênção',
        chapters: [46, 47, 48, 49, 50],
        intro:
          'A família desce ao Egito. Jacó abençoa os filhos; José chora o pai — e afirma: Deus o sentido do mal em bem.',
        keyword: 'Bênção',
        keywordGloss:
          'As palavras finais de Jacó e de José fecham Gênesis apontando para o futuro do povo.',
        focus: 'Como Gênesis termina apontando para esperança?',
        facts: [
          ['Para onde a família de Jacó se muda?', 'Para o Egito', 'Para Babel', 'Para Ur', 'Para Sodoma'],
          ['O que José diz aos irmãos após a morte do pai?', 'Que Deus intentou o mal para bem', 'Que os matará', 'Que a aliança acabou', 'Que voltem a Adão'],
          ['Onde José manda que seus ossos sejam levados um dia?', 'À terra prometida', 'A Babel', 'Ao fundo do Nilo', 'A Moriá apenas'],
        ],
      },
      {
        slug: 'gen12-boss-jose',
        title: 'Desafio: José',
        chapters: [37, 41, 45, 50],
        intro:
          'Da cisterna ao palácio — una sonhos, sofrimento, perdão e providência.',
        keyword: 'Salvação',
        keywordGloss:
          'José antecipa um padrão: o rejeitado que se torna instrumento de vida para muitos.',
        focus: 'Qual o tema central da história de José?',
        type: 'boss',
        facts: [
          ['O ponto de virada de José no Egito é:', 'Interpretar os sonhos de Faraó', 'Construir a torre', 'Vencer Esaú', 'Circuncidar o Egito'],
          ['José revela-se quando:', 'Os irmãos estão diante dele', 'Abraão volta', 'O dilúvio começa', 'A Lei é dada'],
          ['A frase-chave de José em Gn 50 é sobre:', 'Deus transformar o mal em bem', 'Vingança total', 'Fim da promessa', 'Volta ao Éden imediata'],
        ],
      },
    ],
  },
];

function fold(s) {
  return s
    .normalize('NFD')
    .replace(/\p{M}/gu, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}

function loadGenesis() {
  const books = readJson('bible_tb.json');
  return books.find((b) => fold(b.name) === 'genesis');
}

function passageFromChapters(book, chapters, maxVerses = 4) {
  const parts = [];
  let refStart = chapters[0];
  let refEnd = chapters[chapters.length - 1];
  for (const ch of chapters.slice(0, 2)) {
    const verses = book.chapters[ch - 1] || [];
    for (let i = 0; i < Math.min(maxVerses, verses.length); i++) {
      parts.push(verses[i]);
    }
  }
  let text = parts.join(' ');
  if (text.length > 320) text = `${text.slice(0, 317).trim()}…`;
  const passageRef =
    refStart === refEnd ? `Gênesis ${refStart}` : `Gênesis ${refStart}–${refEnd}`;
  return { passageRef, passageText: text };
}

function buildOptions(correct, wrongs) {
  const opts = [
    { id: 'a', text: correct },
    { id: 'b', text: wrongs[0] },
    { id: 'c', text: wrongs[1] },
    { id: 'd', text: wrongs[2] },
  ];
  return opts;
}

function feedbackWrong(wrongs, correct, verseRef) {
  const tip = verseRef
    ? `Revise ${verseRef} — a resposta é: “${correct}”.`
    : `A resposta correta é: “${correct}”.`;
  return { b: tip, c: tip, d: tip };
}

function makeQuestions(mission, book) {
  const { passageRef } = passageFromChapters(book, mission.chapters, 2);
  const out = [];
  const facts = mission.facts || [];

  for (const diff of DIFFS) {
    const pool = [];

    // Semente: fatos diretos
    for (const [q, correct, w1, w2, w3] of facts) {
      pool.push({
        difficulty: 'semente',
        question: q,
        correct,
        wrongs: [w1, w2, w3],
        verseRef: passageRef,
      });
    }

    // Caminhada: compreensão
    pool.push({
      difficulty: 'caminhada',
      question: `Neste arco (${passageRef}), qual é o foco principal?`,
      correct: mission.title,
      wrongs: ['A construção da torre de Babel', 'A entrega da Lei no Sinai', 'A conquista de Jericó'],
      verseRef: passageRef,
    });
    pool.push({
      difficulty: 'caminhada',
      question: mission.focus,
      correct: mission.keywordGloss.split('.')[0] + '.',
      wrongs: [
        'Que a promessa de Deus falhou.',
        'Que o povo deve abandonar a aliança.',
        'Que Deus está ausente da história.',
      ],
      verseRef: passageRef,
    });
    pool.push({
      difficulty: 'caminhada',
      question: `O que a palavra-chave “${mission.keyword}” destaca neste passo?`,
      correct: mission.keywordGloss,
      wrongs: [
        'Que Abrão deve voltar a Ur.',
        'Que não há propósito na criação.',
        'Que a fé é desnecessária.',
      ],
      verseRef: passageRef,
    });

    // Profundezas: detalhe / aplicação
    pool.push({
      difficulty: 'profundezas',
      question: `Segundo ${passageRef}, como este episódio avança a aliança?`,
      correct: mission.intro.split('.')[0] + '.',
      wrongs: [
        'Encerrando a promessa feita a Abraão.',
        'Substituindo a fé por meras genealogias.',
        'Negando o cuidado de Deus com a família.',
      ],
      verseRef: passageRef,
    });
    pool.push({
      difficulty: 'profundezas',
      question: `Qual leitura melhor captura o sentido teológico deste passo?`,
      correct: mission.keywordGloss,
      wrongs: [
        'Deus recompensa apenas os poderosos.',
        'A história bíblica é só moralismo humano.',
        'Não há continuidade entre as gerações.',
      ],
      verseRef: passageRef,
    });

    const chosen = pool.filter((p) => p.difficulty === diff);
    // completar até 5 com fatos (ou reuso)
    let i = 0;
    while (chosen.length < 5 && facts.length) {
      const [q, correct, w1, w2, w3] = facts[i % facts.length];
      chosen.push({
        difficulty: diff,
        question: diff === 'profundezas' ? `${q} (com atenção ao texto)` : q,
        correct,
        wrongs: [w1, w2, w3],
        verseRef: passageRef,
      });
      i += 1;
      if (i > 10) break;
    }

    chosen.slice(0, 5).forEach((item, qi) => {
      const id = `genesis-12-50-${DIFF_SHORT[diff]}-${mission.slug}-${String(qi + 1).padStart(2, '0')}`;
      out.push({
        id,
        trail: 'genesis-12-50',
        difficulty: diff,
        section: mission.slug,
        question: item.question,
        options: buildOptions(item.correct, item.wrongs),
        correctOptionId: 'a',
        feedbackCorrect: `Correto. ${item.verseRef} sustenta esta resposta.`,
        feedbackWrong: feedbackWrong(item.wrongs, item.correct, item.verseRef),
        verseRef: item.verseRef,
        reveal: null,
      });
    });
  }
  return out;
}

function buildStudy(mission, book) {
  const { passageRef, passageText } = passageFromChapters(book, mission.chapters, 3);
  return {
    slug: mission.slug,
    passageRef,
    passageText: passageText || mission.intro,
    context: mission.intro,
    keyword: mission.keyword,
    keywordGloss: mission.keywordGloss,
    focusQuestion: mission.focus,
    reflectionPrompts: [
      'O que este trecho revela sobre a fidelidade de Deus?',
      'Onde a fé humana é testada ou amadurecida?',
      'Como isso se liga à promessa maior da Escritura?',
    ],
  };
}

function main() {
  const book = loadGenesis();
  if (!book) throw new Error('Gênesis não encontrado em bible_tb.json');

  const trails = readJson('trails.json');
  const idx = trails.findIndex((t) => t.slug === 'genesis-12-50');
  if (idx < 0) throw new Error('trilha genesis-12-50 não encontrada');

  const modules = MODULES.map((mod) => ({
    title: mod.title,
    section: mod.section,
    icon: mod.icon === ' palácio' ? '👑' : mod.icon,
    missions: mod.missions.map((m) => ({
      slug: m.slug,
      title: m.title,
      subtitle: `Gênesis ${m.chapters[0]}${m.chapters.length > 1 ? `–${m.chapters[m.chapters.length - 1]}` : ''}`,
      intro: m.intro,
      type: m.type === 'boss' ? 'boss' : 'lesson',
      xpReward: m.type === 'boss' ? 80 : 55,
      questions: [],
    })),
  }));

  trails[idx] = {
    ...trails[idx],
    title: 'Gênesis 12–50',
    description:
      'Abraão, Isaque, Jacó e José — a promessa do começo ao Egito. Cobertura completa dos capítulos 12–50.',
    comingSoon: false,
    modules,
  };
  writeJson('trails.json', trails);
  console.log(
    `✓ trails.json genesis-12-50: ${modules.length} cenas, ${modules.reduce((n, m) => n + m.missions.length, 0)} passos`,
  );

  // Perguntas: remove antigas de genesis-12-50 do OT e reinsere
  const otRaw = readJson('ot_questions.json');
  const otList = Array.isArray(otRaw) ? otRaw : otRaw.questions || [];
  const kept = otList.filter((q) => q.trail !== 'genesis-12-50');
  const allMissions = MODULES.flatMap((m) => m.missions);
  const generated = allMissions.flatMap((m) => makeQuestions(m, book));
  const merged = [...kept, ...generated];
  writeJson('ot_questions.json', { questions: merged });
  console.log(
    `✓ ot_questions.json: +${generated.length} Gênesis 12–50 (total OT ${merged.length})`,
  );

  // Estudos
  const studiesDoc = readJson('mission_studies.json');
  const studies = { ...(studiesDoc.studies || {}) };
  const verses = { ...(studiesDoc.verses || {}) };
  // remove estudos antigos genesis-12-5-*
  for (const key of Object.keys(studies)) {
    if (key.startsWith('genesis-12-5-')) delete studies[key];
  }
  for (const m of allMissions) {
    const s = buildStudy(m, book);
    studies[m.slug] = s;
    if (s.passageRef && s.passageText) verses[s.passageRef] = s.passageText;
  }
  writeJson('mission_studies.json', { studies, verses });
  console.log(`✓ mission_studies.json: ${allMissions.length} preparos novos Gênesis 12–50`);

  // Capítulos cobertos
  const covered = new Set(allMissions.flatMap((m) => m.chapters));
  const missing = [];
  for (let c = 12; c <= 50; c++) if (!covered.has(c)) missing.push(c);
  console.log(`Capítulos tocados em 12–50: ${[...covered].sort((a, b) => a - b).join(', ')}`);
  if (missing.length) {
    console.log(
      `Nota: caps sem missão dedicada (cobertos em arcos vizinhos ou genealógicos): ${missing.join(', ')}`,
    );
  }
  console.log('Pronto. Rode: npm run prepare:content && npm run seed');
}

main();
