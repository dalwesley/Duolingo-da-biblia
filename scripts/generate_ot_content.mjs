/**
 * Gera cenas/passos + banco × 3 níveis para trilhas do AT ainda vazias.
 * Mantém genesis-1-11 e exodo intactos.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const trailsPath = path.join(root, 'trilha_app/assets/data/trails.json');
const outBankPath = path.join(root, 'trilha_app/assets/data/ot_questions.json');

const DIFFS = ['semente', 'caminhada', 'profundezas'];

/** Currículo: slug → cenas com section + passos */
const CURRICULUM = {
  'genesis-12-50': {
    description: 'Abraão, Isaque, Jacó e José — a família da promessa.',
    scenes: [
      {
        title: 'Abraão',
        section: 'abraao',
        icon: '🌟',
        steps: [
          ['Chamado de Abrão', 'Deixa a terra e vai — a promessa começa com obediência.'],
          ['A aliança e a fé', 'Estrelas no céu: descendência e bênção para as nações.'],
          ['Isaque prometido', 'Riso e fidelidade: o filho da promessa nasce.'],
          ['Desafio: A promessa', 'boss', 'Revise o chamado, a aliança e a fé de Abraão.'],
        ],
      },
      {
        title: 'Isaque e Jacó',
        section: 'jaco',
        icon: '⛺',
        steps: [
          ['Isaque e Rebeca', 'A linha da promessa continua na próxima geração.'],
          ['Jacó e Esaú', 'Primogenitura, bênção e conflito entre irmãos.'],
          ['Betel e o novo nome', 'De Jacó a Israel — encontro com Deus.'],
        ],
      },
      {
        title: 'José',
        section: 'jose',
        icon: '👑',
        steps: [
          ['Sonhos e traição', 'O poço e o Egito: Deus na trama humana.'],
          ['Do cárcere ao palácio', 'Interpretação, provisão e elevação.'],
          ['Reconciliação', 'O que intentaram para mal, Deus tornou em bem.'],
          ['Desafio: José', 'boss', 'A soberania de Deus na história de José.'],
        ],
      },
    ],
  },
  levitico: {
    description: 'Santidade, sacrifício e culto — viver perto de um Deus santo.',
    scenes: [
      {
        title: 'Sacrifícios',
        section: 'sacrificios',
        icon: '🔥',
        steps: [
          ['Ofertas ao Senhor', 'Holocausto, oferta de manjares e comunhão.'],
          ['Expiação pelo pecado', 'Sangue e perdão no sistema sacrificial.'],
          ['Desafio: O altar', 'boss', 'Por que o sacrifício importa na santidade.'],
        ],
      },
      {
        title: 'Sacerdócio',
        section: 'sacerdocio',
        icon: '👔',
        steps: [
          ['Arão e os sacerdotes', 'Consagração para servir no santuário.'],
          ['Nadabe e Abiú', 'Fogo estranho — santidade não se brinca.'],
        ],
      },
      {
        title: 'Santidade',
        section: 'santidade',
        icon: '✨',
        steps: [
          ['Sede santos', 'O chamado ético e ritual do povo.'],
          ['Dia da Expiação', 'Yom Kipur — limpeza anual do santuário e do povo.'],
          ['Desafio: Santo como Eu', 'boss', 'Santidade de Deus e vida do povo.'],
        ],
      },
    ],
  },
  numeros: {
    description: 'No deserto: censo, murmuração, serpente e a porta da terra.',
    scenes: [
      {
        title: 'Partida',
        section: 'partida',
        icon: '🏕️',
        steps: [
          ['O censo do povo', 'Organização das tribos em marcha.'],
          ['A nuvem e a trombeta', 'Quando mover e quando parar com Deus.'],
        ],
      },
      {
        title: 'Murmurações',
        section: 'murmuracao',
        icon: '😤',
        steps: [
          ['Espias em Canaã', 'Fé versus medo na porta da terra.'],
          ['Quarenta anos', 'A geração que não entrou.'],
          ['A serpente de bronze', 'Olhar e viver — juízo e graça.'],
          ['Desafio: No deserto', 'boss', 'Fé, medo e provisão no caminho.'],
        ],
      },
      {
        title: 'Às portas',
        section: 'portas',
        icon: '🚪',
        steps: [
          ['Balaão', 'Bênção que não se compra.'],
          ['Nova geração', 'Preparação para herdar a terra.'],
        ],
      },
    ],
  },
  deuteronomio: {
    description: 'Moisés repete a Lei: amar ao Senhor de todo o coração.',
    scenes: [
      {
        title: 'Lembrar',
        section: 'lembrar',
        icon: '📜',
        steps: [
          ['Recontar a jornada', 'Memória da libertação e da fidelidade.'],
          ['O Shemá', 'Ouve, Israel — amar a Deus acima de tudo.'],
        ],
      },
      {
        title: 'Aliança',
        section: 'alianca',
        icon: '🤝',
        steps: [
          ['Bênçãos e maldições', 'Escolha de vida ou morte.'],
          ['Um profeta como Moisés', 'Esperança de um mediador futuro.'],
          ['Desafio: Escolhei a vida', 'boss', 'Amor, obediência e aliança.'],
        ],
      },
      {
        title: 'Despedida',
        section: 'despedida',
        icon: '🌅',
        steps: [
          ['Josué designado', 'A liderança passa; a promessa continua.'],
          ['Cântico de Moisés', 'Testemunho final do servo do Senhor.'],
        ],
      },
    ],
  },
  josue: {
    description: 'Entrada na terra: coragem, Jericó e aliança renovada.',
    scenes: [
      {
        title: 'Entrada',
        section: 'entrada',
        icon: '🌊',
        steps: [
          ['Sê forte e corajoso', 'A promessa acompanha Josué.'],
          ['Raabe e os espias', 'Fé inesperada em Jericó.'],
          ['O Jordão', 'Passagem em terra seca — novo êxodo.'],
        ],
      },
      {
        title: 'Conquista',
        section: 'conquista',
        icon: '🎺',
        steps: [
          ['Jericó', 'Muros e obediência — a vitória é do Senhor.'],
          ['Ai e o pecado de Acã', 'Derrota quando a aliança é quebrada.'],
          ['Desafio: A terra', 'boss', 'Fé, obediência e conquista.'],
        ],
      },
      {
        title: 'Aliança',
        section: 'alianca-josue',
        icon: '🪨',
        steps: [
          ['Reparto das terras', 'Herança para as tribos.'],
          ['Escolhei hoje a quem servir', 'Renovação em Siquém.'],
        ],
      },
    ],
  },
  juizes: {
    description: 'Ciclo de pecado, opressão, clamor e livramento.',
    scenes: [
      {
        title: 'O ciclo',
        section: 'ciclo',
        icon: '🔁',
        steps: [
          ['Cada um fazia o que era reto', 'Sem rei e sem fidelidade.'],
          ['Deus levanta juízes', 'Livradores no meio da crise.'],
        ],
      },
      {
        title: 'Juízes',
        section: 'juizes',
        icon: '⚔️',
        steps: [
          ['Débora e Baraque', 'Vitória cantada por uma profetisa.'],
          ['Gideão', 'Do medo à fé — poucos contra muitos.'],
          ['Sansão', 'Força, falha e um último ato.'],
          ['Desafio: O ciclo', 'boss', 'Pecado, juízo e misericórdia.'],
        ],
      },
    ],
  },
  rute: {
    description: 'Lealdade, redenção e a linhagem de Davi.',
    scenes: [
      {
        title: 'Lealdade',
        section: 'lealdade',
        icon: '🌾',
        steps: [
          ['Rute e Noemi', 'Teu Deus será o meu Deus.'],
          ['Nos campos de Boaz', 'Provisão e favor no meio da perda.'],
        ],
      },
      {
        title: 'Redenção',
        section: 'redencao',
        icon: '💍',
        steps: [
          ['O resgatador', 'Boaz cumpre o papel de parente-redentor.'],
          ['Desafio: Linhagem', 'boss', 'Fidelidade que entra na história de Davi.'],
        ],
      },
    ],
  },
  samuel: {
    description: 'De Samuel a Saul e Davi — rei segundo o coração de Deus.',
    scenes: [
      {
        title: 'Samuel',
        section: 'samuel',
        icon: '🔔',
        steps: [
          ['O chamado de Samuel', 'Fala, Senhor, porque o teu servo ouve.'],
          ['Israel pede um rei', 'Rejeitar o governo de Deus?'],
        ],
      },
      {
        title: 'Saul',
        section: 'saul',
        icon: '👑',
        steps: [
          ['Saul ungido', 'Começo promissor, coração dividido.'],
          ['Desobediência de Saul', 'Obedecer é melhor do que sacrificar.'],
        ],
      },
      {
        title: 'Davi',
        section: 'davi',
        icon: '🎵',
        steps: [
          ['Davi ungido', 'O Senhor vê o coração.'],
          ['Davi e Golias', 'A batalha é do Senhor.'],
          ['Desafio: O rei', 'boss', 'Samuel, Saul e o coração de Davi.'],
        ],
      },
    ],
  },
  reis: {
    description: 'Salomão, divisão do reino, profetas e exílio.',
    scenes: [
      {
        title: 'Salomão',
        section: 'salomao',
        icon: '🏛️',
        steps: [
          ['Sabedoria e o templo', 'Glória e perigo da prosperidade.'],
          ['O coração dividido', 'Mulheres estrangeiras e idolatria.'],
        ],
      },
      {
        title: 'Reino dividido',
        section: 'dividido',
        icon: '💔',
        steps: [
          ['Norte e Sul', 'Jeroboão e a ruptura.'],
          ['Elias no Carmelo', 'O Senhor é Deus!'],
          ['Desafio: Fidelidade', 'boss', 'Templo, cisma e profetas.'],
        ],
      },
      {
        title: 'Queda',
        section: 'queda-reis',
        icon: '🏚️',
        steps: [
          ['Queda de Samaria', 'O fim do reino do norte.'],
          ['Queda de Jerusalém', 'Exílio da Judá.'],
        ],
      },
    ],
  },
  cronicas: {
    description: 'História pelo olhar do culto: Davi, templo e reforma.',
    scenes: [
      {
        title: 'Davi e o culto',
        section: 'culto',
        icon: '🎶',
        steps: [
          ['A arca e a adoração', 'Davi organiza o louvor.'],
          ['Preparação do templo', 'Materiais e coração para a casa de Deus.'],
        ],
      },
      {
        title: 'Templo e reis',
        section: 'templo',
        icon: '🛕',
        steps: [
          ['Salomão dedica o templo', 'Glória enche a casa.'],
          ['Reformas e quedas', 'Quando o culto é restaurado ou abandonado.'],
          ['Desafio: O templo', 'boss', 'Culto, rei e presença de Deus.'],
        ],
      },
    ],
  },
  esdras: {
    description: 'Volta do exílio: altar, templo e a Lei.',
    scenes: [
      {
        title: 'Retorno',
        section: 'retorno',
        icon: '🧱',
        steps: [
          ['Decreto de Ciro', 'Deus mexe nos reis para cumprir promessa.'],
          ['Altar e fundamentos', 'Começar pelo culto.'],
        ],
      },
      {
        title: 'Reforma',
        section: 'reforma-esdras',
        icon: '📖',
        steps: [
          ['Esdras e a Lei', 'Ensinar a Torá ao povo.'],
          ['Desafio: Restauração', 'boss', 'Volta, templo e Palavra.'],
        ],
      },
    ],
  },
  neemias: {
    description: 'Muros, oração e renovação da aliança.',
    scenes: [
      {
        title: 'Os muros',
        section: 'muros',
        icon: '🧱',
        steps: [
          ['Oração de Neemias', 'Jejuar, confessar e pedir.'],
          ['Edificar sob oposição', 'Espada numa mão, tijolo na outra.'],
        ],
      },
      {
        title: 'Renovação',
        section: 'renovacao',
        icon: '📜',
        steps: [
          ['Leitura da Lei', 'O povo chora e depois celebra.'],
          ['Desafio: Reconstruir', 'boss', 'Oração, muros e aliança.'],
        ],
      },
    ],
  },
  ester: {
    description: 'Providência oculta: rainha, risco e livramento.',
    scenes: [
      {
        title: 'A corte',
        section: 'corte',
        icon: '👑',
        steps: [
          ['Ester rainha', 'Posicionada para um tempo como este.'],
          ['O plano de Hamã', 'Ameaça de extinção.'],
        ],
      },
      {
        title: 'Livramento',
        section: 'livramento',
        icon: '🎉',
        steps: [
          ['Jejuar e agir', 'Se eu perecer, pereci.'],
          ['Purim', 'Lembrar o livramento com festa.'],
          ['Desafio: Providência', 'boss', 'Deus age mesmo quando o nome não aparece.'],
        ],
      },
    ],
  },
  jo: {
    description: 'Sofrimento, fé e o mistério de Deus.',
    scenes: [
      {
        title: 'Prova',
        section: 'prova',
        icon: '🌪️',
        steps: [
          ['Jó íntegro', 'Teme a Deus e se desvia do mal.'],
          ['Perda e adoração', 'O Senhor o deu; o Senhor o tomou.'],
        ],
      },
      {
        title: 'Diálogo',
        section: 'dialogo',
        icon: '💬',
        steps: [
          ['Amigos e acusações', 'Teologia rasa diante da dor.'],
          ['Deus responde', 'Onde estavas tu…?'],
          ['Desafio: Sofrimento', 'boss', 'Fé, mistério e restauração.'],
        ],
      },
    ],
  },
  salmos: {
    description: 'Oração, louvor e lamento do povo de Deus.',
    scenes: [
      {
        title: 'Louvor',
        section: 'louvor',
        icon: '🙌',
        steps: [
          ['Bem-aventurado o homem', 'Salmo 1 — dois caminhos.'],
          ['O Senhor é o meu pastor', 'Salmo 23 — cuidado e presença.'],
        ],
      },
      {
        title: 'Lamento e confiança',
        section: 'lamento',
        icon: '😢',
        steps: [
          ['Até quando, Senhor?', 'Clamar com honestidade.'],
          ['Criai em mim um coração puro', 'Arrependimento e renovação.'],
          ['Desafio: Orar os Salmos', 'boss', 'Louvor, lamento e confiança.'],
        ],
      },
    ],
  },
  proverbios: {
    description: 'Sabedoria prática para o temor do Senhor.',
    scenes: [
      {
        title: 'Temor e sabedoria',
        section: 'sabedoria',
        icon: '🦉',
        steps: [
          ['O princípio da sabedoria', 'Temor do Senhor.'],
          ['Dois caminhos', 'Sábio e tolo.'],
        ],
      },
      {
        title: 'Vida prática',
        section: 'pratica',
        icon: '🧭',
        steps: [
          ['Palavras e trabalho', 'Língua, preguiça e diligência.'],
          ['Desafio: Sabedoria', 'boss', 'Temor, caminho e caráter.'],
        ],
      },
    ],
  },
  eclesiastes: {
    description: 'Vaidade sob o sol — e o temor de Deus no fim.',
    scenes: [
      {
        title: 'Sob o sol',
        section: 'sol',
        icon: '☀️',
        steps: [
          ['Vaidade de vaidades', 'Tudo é vapor sem Deus.'],
          ['Tempo para todo propósito', 'Sazonalidade da vida.'],
        ],
      },
      {
        title: 'Conclusão',
        section: 'conclusao',
        icon: '⚖️',
        steps: [
          ['Teme a Deus', 'O fim de todo o homem.'],
          ['Desafio: Sentido', 'boss', 'Vaidade e temor do Senhor.'],
        ],
      },
    ],
  },
  cantares: {
    description: 'Amor fiel — poesia da aliança e do desejo santo.',
    scenes: [
      {
        title: 'Amor',
        section: 'amor',
        icon: '💝',
        steps: [
          ['Cântico dos cânticos', 'Beleza do amor conjugal.'],
          ['Selado no coração', 'Amor forte como a morte.'],
          ['Desafio: Aliança de amor', 'boss', 'Fidelidade e celebração do amor.'],
        ],
      },
    ],
  },
  isaias: {
    description: 'Santo, santo, santo — juízo, consolação e o Servo.',
    scenes: [
      {
        title: 'Chamado',
        section: 'chamado-isaias',
        icon: '🔥',
        steps: [
          ['Visão do trono', 'Santo, santo, santo é o Senhor.'],
          ['Aqui estou eu, envia-me', 'Profeta para um povo rebelde.'],
        ],
      },
      {
        title: 'Juízo e esperança',
        section: 'esperanca-isaias',
        icon: '🌿',
        steps: [
          ['O Emanuel', 'Um menino, um sinal.'],
          ['O Servo sofredor', 'Ferido por nossas transgressões.'],
          ['Desafio: Isaías', 'boss', 'Santidade, juízo e salvação.'],
        ],
      },
    ],
  },
  jeremias: {
    description: 'Lágrimas e aliança nova no meio do colapso.',
    scenes: [
      {
        title: 'Chamado',
        section: 'chamado-jeremias',
        icon: '😭',
        steps: [
          ['Antes que te formasse', 'Profeta às nações.'],
          ['Templo não salva', 'Confiança falsa religiosa.'],
        ],
      },
      {
        title: 'Nova aliança',
        section: 'nova-alianca',
        icon: '✍️',
        steps: [
          ['Lei no coração', 'A aliança escrita por dentro.'],
          ['Desafio: Jeremias', 'boss', 'Juízo, lágrimas e esperança.'],
        ],
      },
    ],
  },
  lamentacoes: {
    description: 'Luto de Jerusalém — e misericórdias que se renovam.',
    scenes: [
      {
        title: 'Luto',
        section: 'luto',
        icon: '🕊️',
        steps: [
          ['Como está sentada solitária', 'A cidade que caiu.'],
          ['As misericórdias do Senhor', 'Novas a cada manhã.'],
          ['Desafio: Esperança no luto', 'boss', 'Dor honesta e fidelidade de Deus.'],
        ],
      },
    ],
  },
  ezequiel: {
    description: 'Glória, juízo e um coração novo.',
    scenes: [
      {
        title: 'Visões',
        section: 'visoes',
        icon: '👁️',
        steps: [
          ['A glória de Deus', 'Rodas e trono — Deus não está preso.'],
          ['Atalaia de Israel', 'Responsabilidade de avisar.'],
        ],
      },
      {
        title: 'Restauração',
        section: 'restauracao-ez',
        icon: '❤️',
        steps: [
          ['Coração de carne', 'Espírito e vida nova.'],
          ['Vale de ossos secos', 'Pode esta ossada viver?'],
          ['Desafio: Ezequiel', 'boss', 'Glória, juízo e renovação.'],
        ],
      },
    ],
  },
  daniel: {
    description: 'Fidelidade no exílio e reinos sob o Altíssimo.',
    scenes: [
      {
        title: 'No palácio',
        section: 'palacio',
        icon: '🦁',
        steps: [
          ['Propósito no coração', 'Alimento e fidelidade.'],
          ['A fornalha', 'O quarto homem no fogo.'],
          ['A cova dos leões', 'Deus fecha a boca dos leões.'],
        ],
      },
      {
        title: 'Reinos',
        section: 'reinos',
        icon: '🗿',
        steps: [
          ['O sonho da estátua', 'Reinos passam; o de Deus permanece.'],
          ['Desafio: Daniel', 'boss', 'Fidelidade e soberania no exílio.'],
        ],
      },
    ],
  },
  oseias: {
    description: 'Amor fiel de Deus a um povo adúltero.',
    scenes: [
      {
        title: 'Amor e infidelidade',
        section: 'oseias',
        icon: '💔',
        steps: [
          ['Oséias e Gômer', 'Profecia vivida no casamento.'],
          ['Misericórdia quero', 'Não sacrifício vazio.'],
          ['Desafio: Oséias', 'boss', 'Amor que busca o infiel.'],
        ],
      },
    ],
  },
  joel: {
    description: 'O dia do Senhor e o derramar do Espírito.',
    scenes: [
      {
        title: 'O dia do Senhor',
        section: 'joel',
        icon: '🌑',
        steps: [
          ['Gafanhotos e juízo', 'Despertar para o arrependimento.'],
          ['Derramarei o meu Espírito', 'Promessa para toda a carne.'],
          ['Desafio: Joel', 'boss', 'Juízo, arrependimento e Espírito.'],
        ],
      },
    ],
  },
  amos: {
    description: 'Justiça como águas — Deus defende o oprimido.',
    scenes: [
      {
        title: 'Justiça',
        section: 'amos',
        icon: '⚖️',
        steps: [
          ['Rugido de Sião', 'O Senhor fala contra a injustiça.'],
          ['Deixai correr o juízo', 'Culto sem justiça não basta.'],
          ['Desafio: Amós', 'boss', 'Justiça, culto e o dia do Senhor.'],
        ],
      },
    ],
  },
  obadias: {
    description: 'Orgulho de Edom e o reino do Senhor.',
    scenes: [
      {
        title: 'Edom',
        section: 'obadias',
        icon: '🏔️',
        steps: [
          ['Orgulho abatido', 'Não te eleves como a águia.'],
          ['O reino será do Senhor', 'Esperança final.'],
          ['Desafio: Obadias', 'boss', 'Orgulho, juízo e reino de Deus.'],
        ],
      },
    ],
  },
  jonas: {
    description: 'Profeta em fuga — misericórdia até para Nínive.',
    scenes: [
      {
        title: 'Fuga e peixe',
        section: 'fuga',
        icon: '🐋',
        steps: [
          ['Jonas foge', 'Não se foge do Senhor.'],
          ['No ventre do peixe', 'Oração desde o abismo.'],
        ],
      },
      {
        title: 'Nínive',
        section: 'ninive',
        icon: '🏙️',
        steps: [
          ['A cidade se arrepende', 'Misericórdia que incomoda.'],
          ['Desafio: Jonas', 'boss', 'Obediência e compaixão de Deus.'],
        ],
      },
    ],
  },
  miqueias: {
    description: 'Agir com justiça, amar a misericórdia, andar com Deus.',
    scenes: [
      {
        title: 'Justiça e esperança',
        section: 'miqueias',
        icon: '🥾',
        steps: [
          ['O Senhor requer de ti', 'Justiça, misericórdia e humildade.'],
          ['Belém Efrata', 'De ti me sairá o Dominador.'],
          ['Desafio: Miqueias', 'boss', 'Ética e messias.'],
        ],
      },
    ],
  },
  naum: {
    description: 'Nínive cai — o Senhor é refúgio e juízo.',
    scenes: [
      {
        title: 'Nínive',
        section: 'naum',
        icon: '💥',
        steps: [
          ['O Senhor é bom', 'Refúgio no dia da angústia.'],
          ['Queda da cidade cruel', 'Juízo sobre a opressão.'],
          ['Desafio: Naum', 'boss', 'Consolo e juízo.'],
        ],
      },
    ],
  },
  habacuque: {
    description: 'Até quando? — o justo viverá pela fé.',
    scenes: [
      {
        title: 'Perguntas e fé',
        section: 'habacuque',
        icon: '❓',
        steps: [
          ['A queixa do profeta', 'Por que a injustiça prosperar?'],
          ['O justo pela sua fé', 'Resposta que sustenta.'],
          ['Desafio: Habacuque', 'boss', 'Dúvida honesta e fé viva.'],
        ],
      },
    ],
  },
  sofonias: {
    description: 'O dia do Senhor — juízo e cântico de alegria.',
    scenes: [
      {
        title: 'Dia do Senhor',
        section: 'sofonias',
        icon: '🌅',
        steps: [
          ['Dia de juízo', 'Buscai ao Senhor.'],
          ['O Senhor se alegra por ti', 'Deus canta sobre o remanescente.'],
          ['Desafio: Sofonias', 'boss', 'Juízo e alegria divina.'],
        ],
      },
    ],
  },
  ageu: {
    description: 'Reconstruí a casa — prioridade do templo.',
    scenes: [
      {
        title: 'A casa do Senhor',
        section: 'ageu',
        icon: '🏗️',
        steps: [
          ['Casas forradas, templo em ruínas', 'Repriorizar a Deus.'],
          ['Eu estou convosco', 'Ânimo para edificar.'],
          ['Desafio: Ageu', 'boss', 'Prioridade e presença.'],
        ],
      },
    ],
  },
  zacarias: {
    description: 'Visões de esperança — Rei humilde e fonte aberta.',
    scenes: [
      {
        title: 'Visões',
        section: 'zacarias',
        icon: '🔮',
        steps: [
          ['Voltai para mim', 'Arrependimento e restauração.'],
          ['Rei no jumentinho', 'Messias humilde.'],
          ['Desafio: Zacarias', 'boss', 'Esperança e Messias.'],
        ],
      },
    ],
  },
  malaquias: {
    description: 'Última palavra do AT — coração e o mensageiro.',
    scenes: [
      {
        title: 'Coração e aliança',
        section: 'malaquias',
        icon: '✉️',
        steps: [
          ['Eu vos tenho amado', 'Amor questionado e reafirmado.'],
          ['O mensageiro da aliança', 'Preparar o caminho.'],
          ['Desafio: Malaquias', 'boss', 'Fidelidade até a virada do Testamento.'],
        ],
      },
    ],
  },
  'periodo-intertestamentario': {
    description: 'Os anos de silêncio profético — e a preparação do cenário.',
    scenes: [
      {
        title: 'Entre os testamentos',
        section: 'inter',
        icon: '⏳',
        steps: [
          ['Impérios em cena', 'Persas, gregos e romanos.'],
          ['Esperança messiânica', 'Anseio por livramento.'],
          ['Desafio: A espera', 'boss', 'História e expectativa do Messias.'],
        ],
      },
    ],
  },
};

function slugify(text) {
  return String(text || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 40);
}

function makeMission(trailSlug, sceneSection, step, index) {
  const isBoss = step[1] === 'boss';
  const title = step[0];
  const intro = isBoss ? step[2] : step[1];
  const slug = `${trailSlug.slice(0, 12)}-${sceneSection.slice(0, 10)}-${String(index + 1).padStart(2, '0')}-${slugify(title).slice(0, 20)}`;
  return {
    slug,
    title,
    subtitle: '',
    intro,
    type: isBoss ? 'boss' : 'lesson',
    xpReward: isBoss ? 80 : 50,
    questions: [],
  };
}

function makeModules(trailSlug, curriculum) {
  return curriculum.scenes.map((scene) => ({
    title: scene.title,
    section: scene.section,
    icon: scene.icon || '📘',
    missions: scene.steps.map((step, i) => makeMission(trailSlug, scene.section, step, i)),
  }));
}

/** Gera 5 perguntas por passo × 3 níveis (section = slug do passo). */
function buildQuestionsForTrail(trailSlug, curriculum) {
  const out = [];
  const bookLabel = curriculum.bookLabel || trailSlug;
  const modules = makeModules(trailSlug, curriculum);

  for (const mod of modules) {
    for (const mission of mod.missions) {
      for (const diff of DIFFS) {
        for (let i = 0; i < 5; i++) {
          const item = questionFor(
            diff,
            trailSlug,
            mission.slug,
            mod.title,
            mission.title,
            bookLabel,
            i,
          );
          item.id = `${trailSlug.slice(0, 8)}-${diff.slice(0, 3)}-${mission.slug.slice(0, 24)}-${String(i + 1).padStart(2, '0')}`;
          out.push(item);
        }
      }
    }
  }
  return out;
}

function questionFor(diff, trail, section, sceneTitle, theme, book, i) {
  const verse = `Referência: ${book}`;
  if (diff === 'semente') {
    return q(
      trail,
      diff,
      section,
      `Sobre “${theme}” (${sceneTitle}): qual afirmação é verdadeira?`,
      0,
      [
        `O texto bíblico apresenta esse episódio/tema como parte da história de ${book}.`,
        'Isso não aparece nas Escrituras.',
        'É apenas uma lenda egípcia sem relação com Israel.',
        'Foi inventado no período medieval.',
      ],
      verse,
      `Correto — “${theme}” faz parte da narrativa bíblica de ${book}.`,
      {
        b: `Revise ${book}: o tema “${theme}” está no texto.`,
        c: 'Não é lenda estrangeira desconectada — é Escritura.',
        d: 'A origem é canônica, não medieval.',
      },
    );
  }
  if (diff === 'caminhada') {
    return q(
      trail,
      diff,
      section,
      `Em “${theme}”, qual é o sentido principal para a fé?`,
      0,
      [
        `Deus age na história e chama o povo a responder com confiança e obediência.`,
        'O episódio só serve para dados geográficos.',
        'Deus está ausente nesses relatos.',
        'A moral é: cada um faça o que quiser.',
      ],
      verse,
      `Sim — “${theme}” aponta para a ação de Deus e a resposta humana.`,
      {
        b: 'Há geografia, mas o centro é teológico.',
        c: 'Deus está presente e ativo na narrativa.',
        d: 'A Escritura forma caráter e aliança, não autonomia absoluta.',
      },
    );
  }
  // profundezas
  const angles = [
    [
      `Como “${theme}” revela o caráter de Deus?`,
      `Santidade, fidelidade e misericórdia aparecem mesmo no meio da crise humana.`,
      'Deus muda de essência a cada capítulo.',
      'Deus é indiferente ao sofrimento.',
      'Só importa o poder político de Israel.',
    ],
    [
      `Qual leitura madura de “${theme}” evita?`,
      `Reduzir o texto a moralismo raso, ignorando aliança e graça.`,
      'Ler com oração e contexto.',
      'Comparar Escritura com Escritura.',
      'Considerar o caráter de Deus.',
    ],
    [
      `Em “${theme}”, qual tensão teológica aparece?`,
      `Soberania de Deus e responsabilidade humana caminham juntas no relato.`,
      'Apenas acaso histórico.',
      'Negação completa do livre arbítrio em todo detalhe.',
      'Ausência total de propósito.',
    ],
  ];
  const a = angles[i % angles.length];
  return q(
    trail,
    diff,
    section,
    a[0],
    0,
    [a[1], a[2], a[3], a[4]],
    verse,
    `Correto — uma leitura profunda de “${theme}” enxerga ${a[1].toLowerCase()}`,
  );
}

function q(trail, difficulty, section, question, correct, options, verseRef, feedbackCorrect, wrongHints = {}) {
  const ids = ['a', 'b', 'c', 'd'];
  const correctOptionId = ids[correct];
  const feedbackWrong = {};
  for (const oid of ids) {
    if (oid === correctOptionId) continue;
    feedbackWrong[oid] =
      wrongHints[oid] ||
      `Revise o texto — a resposta correta é: “${options[correct]}”.`;
  }
  return {
    trail,
    difficulty,
    section,
    question,
    options: ids.map((oid, i) => ({ id: oid, text: options[i] })),
    correctOptionId,
    feedbackCorrect,
    feedbackWrong,
    verseRef,
  };
}

// Book display names for verse refs
const BOOK_NAMES = {
  'genesis-12-50': 'Gênesis 12–50',
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

// ── Enrich question templates with more specific content per trail ──
// Override build for better quality on key books via SPECIFIC_Q if needed later.

function main() {
  const trails = JSON.parse(fs.readFileSync(trailsPath, 'utf8'));
  const allQuestions = [];
  const updatedSlugs = [];

  for (const [slug, curriculum] of Object.entries(CURRICULUM)) {
    curriculum.bookLabel = BOOK_NAMES[slug] || slug;
    const trail = trails.find((t) => t.slug === slug || t.id === slug);
    if (!trail) {
      console.warn('Trail not found:', slug);
      continue;
    }
    trail.description = curriculum.description || trail.description;
    trail.modules = makeModules(slug, curriculum);
    trail.comingSoon = false;
    trail.isActive = true;
    updatedSlugs.push(slug);

    const qs = buildQuestionsForTrail(slug, curriculum);
    // Ensure unique ids
    qs.forEach((q) => {
      q.id = q.id.replace(/[^a-z0-9-]/gi, '').slice(0, 64);
      allQuestions.push(q);
    });
    console.log(slug, 'scenes', trail.modules.length, 'steps', trail.modules.reduce((n, m) => n + m.missions.length, 0), 'qs', qs.length);
  }

  // Also tag existing exodo modules with section if missing
  const exodo = trails.find((t) => t.slug === 'exodo');
  if (exodo?.modules) {
    const map = {
      'Opressão no Egito': 'opressao',
      'A Libertação': 'libertacao',
      'No deserto': 'deserto',
    };
    for (const m of exodo.modules) {
      if (!m.section && map[m.title]) m.section = map[m.title];
    }
  }
  const gen = trails.find((t) => t.slug === 'genesis-1-11');
  if (gen?.modules) {
    const map = {
      'A Criação': 'criacao',
      'O Jardim': 'jardim',
      'Depois do Éden': 'depois',
    };
    for (const m of gen.modules) {
      if (!m.section && map[m.title]) m.section = map[m.title];
    }
  }

  fs.writeFileSync(trailsPath, JSON.stringify(trails, null, 2) + '\n');
  fs.writeFileSync(outBankPath, JSON.stringify({ questions: allQuestions }, null, 2) + '\n');

  const dartSet = ['genesis-1-11', 'exodo', ...updatedSlugs];
  console.log('\nUpdated trails:', updatedSlugs.length);
  console.log('Total OT new questions:', allQuestions.length);
  console.log('difficultyBankTrails slugs:', dartSet.length);
  fs.writeFileSync(
    path.join(root, 'scripts/ot_difficulty_slugs.json'),
    JSON.stringify(dartSet, null, 2),
  );
}

main();
