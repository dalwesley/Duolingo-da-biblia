/// Resumo histórico de cada livro — prosa, não ficha técnica.
///
/// Chaves = [BibleChronology.normalizeAbbrev] (gn, jo, joao, …).
/// Tom: tradição cristã evangélica, datas aproximadas, sem debate acadêmico.
library;

import 'bible_chronology.dart';

class BibleBookIntro {
  /// O que o livro é, em uma linha.
  final String title;

  /// Resumo histórico: cenário, destinatários e o que o livro narra.
  final String summary;

  /// Quem escreveu (tradição, quando for o caso).
  final String author;

  /// Quando foi escrito / ministério do autor.
  final String when;

  /// Primeiros leitores.
  final String audience;

  const BibleBookIntro({
    required this.title,
    required this.summary,
    required this.author,
    required this.when,
    required this.audience,
  });

  static const _traditionPrefix = 'Tradição: ';

  bool get byTradition => author.startsWith(_traditionPrefix);

  String get authorName =>
      byTradition ? author.substring(_traditionPrefix.length) : author;
}

class BibleBookIntros {
  BibleBookIntros._();

  static BibleBookIntro? of(String abbrev, {String? bookName}) {
    final key = BibleChronology.normalizeAbbrev(abbrev, bookName: bookName);
    return byAbbrev[key];
  }

  static const byAbbrev = <String, BibleBookIntro>{
    'gn': BibleBookIntro(
      title: 'Criação, queda e os patriarcas',
      summary:
          'No Egito e na Mesopotâmia, o mundo começava com muitos deuses e o faraó no centro. Israel, recém-saído da escravidão, precisava saber de onde veio. Gênesis abre a Bíblia com um só Criador, a queda, o dilúvio e Abraão — a família pela qual Deus promete abençoar as nações.',
      author: 'Tradição: Moisés',
      when: '~1400 a.C.',
      audience: 'Israel no deserto',
    ),
    'ex': BibleBookIntro(
      title: 'Libertação e aliança no Sinai',
      summary:
          'O Egito era a superpotência da época; Israel, mão de obra. O livro narra as pragas, a Páscoa, o mar e o monte Sinai, onde um povo escravo recebe a Lei. Atrás fica o império do Nilo; à frente, o deserto e a terra prometida.',
      author: 'Tradição: Moisés',
      when: '~1400 a.C.',
      audience: 'Israel recém-liberto',
    ),
    'lv': BibleBookIntro(
      title: 'O culto de um povo santo',
      summary:
          'Acampados no deserto, entre nações com templos e ídolos, Israel recebe o mapa do culto: sacrifícios, festas, sacerdotes e pureza. Levítico ensina como um povo se aproxima de um Deus santo sem copiar os santuários vizinhos.',
      author: 'Tradição: Moisés',
      when: '~1400 a.C.',
      audience: 'Israel no acampamento',
    ),
    'nm': BibleBookIntro(
      title: 'A marcha no deserto',
      summary:
          'Do Sinai até a beira de Canaã, o povo é contado, murmura e quase perde a herança. Quarenta anos no deserto separam duas gerações. Números é o diário de uma nação em trânsito, entre o Egito que ficou e a terra que ainda não é deles.',
      author: 'Tradição: Moisés',
      when: '~1400 a.C.',
      audience: 'Israel a caminho',
    ),
    'dt': BibleBookIntro(
      title: 'O testamento de Moisés',
      summary:
          'Às portas de Canaã, a geração que não viu o Egito ouve a Lei de novo. Moisés resume a aliança antes de morrer: amar o Senhor, não esquecer, escolher a vida. Ao redor, os povos e os deuses da terra que estão prestes a entrar.',
      author: 'Tradição: Moisés',
      when: '~1400 a.C.',
      audience: 'A nova geração',
    ),
    'js': BibleBookIntro(
      title: 'A conquista da terra',
      summary:
          'Moisés morreu. Josué atravessa o Jordão e as cidades-estado de Canaã caem uma a uma. O livro mostra a terra como dádiva — e avisa que a herança só permanece se o povo permanecer fiel.',
      author: 'Tradição: Josué',
      when: '~séc. XIV–XIII a.C.',
      audience: 'Israel na terra',
    ),
    'jz': BibleBookIntro(
      title: 'Quando cada um fazia o que queria',
      summary:
          'Sem rei e sem Moisés, as tribos esquecem o Senhor, sofrem nas mãos de povos vizinhos e clamam por livramento. Um juiz se levanta, a paz dura pouco, o ciclo recomeça. Juízes retrata Israel solto — e o vazio dessa liberdade.',
      author: 'Tradição: Samuel',
      when: '~séc. XI a.C.',
      audience: 'Israel nas tribos',
    ),
    'rt': BibleBookIntro(
      title: 'Fidelidade no tempo dos juízes',
      summary:
          'Enquanto Juízes mostra o caos, Rute conta uma família em Belém e uma moabita que se apega a Israel. No fundo, a linha de Davi começa num campo de cevada — graça miúda numa época dura.',
      author: 'Desconhecido',
      when: '~séc. XI a.C.',
      audience: 'Israel, tempo dos juízes',
    ),
    '1sm': BibleBookIntro(
      title: 'Samuel, Saul e o pedido de um rei',
      summary:
          'Os filisteus dominam a costa; as tribos querem um rei “como as nações”. Samuel unge Saul. O livro pergunta o que acontece quando o trono substitui a obediência — e prepara a subida de Davi.',
      author: 'Tradição: Samuel e profetas',
      when: '~séc. X a.C.',
      audience: 'Israel da monarquia',
    ),
    '2sm': BibleBookIntro(
      title: 'O reinado de Davi',
      summary:
          'Davi unifica as tribos, toma Jerusalém e recebe a promessa de uma casa eterna. Depois cai, e o livro não esconde. O auge de Israel e a rachadura do rei ocupam o mesmo palco.',
      author: 'Tradição: profetas da corte',
      when: '~séc. X a.C.',
      audience: 'Israel unificado',
    ),
    '1rs': BibleBookIntro(
      title: 'Salomão, o templo e o reino dividido',
      summary:
          'Salomão pede sabedoria e constrói o templo; o coração depois se desvia e o reino se parte. Egito, Síria e Assíria rondam. 1 Reis lê a política de Israel pela aliança — não pelo tamanho do palácio.',
      author: 'Tradição: profetas',
      when: '~séc. VI a.C.',
      audience: 'O povo no ou após o exílio',
    ),
    '2rs': BibleBookIntro(
      title: 'A queda de Samaria e de Jerusalém',
      summary:
          'O Norte cai na Assíria; Judá resiste até a Babilônia queimar a cidade e o templo. Profetas avisaram. 2 Reis foi escrito à sombra do exílio: a pergunta não é quem tinha mais exército, e sim o que a infidelidade custou.',
      author: 'Tradição: profetas',
      when: '~séc. VI a.C.',
      audience: 'O povo no exílio',
    ),
    '1cr': BibleBookIntro(
      title: 'Nomes, culto e a memória de Davi',
      summary:
          'Depois do exílio, sob o império persa, o povo precisa se reconhecer de novo. Crônicas recomeça com genealogias, o templo e Davi. Não é só repetir Samuel e Reis: é devolver identidade a quem voltou.',
      author: 'Tradição: Esdras',
      when: '~séc. V a.C.',
      audience: 'Judeus de volta à terra',
    ),
    '2cr': BibleBookIntro(
      title: 'Judá, o templo e os avivamentos',
      summary:
          'De Salomão ao cativeiro, o foco é Judá e o culto. Reis ímpios e reformas se alternam. Para a comunidade que reconstruía o templo, a lição é clara: paredes de pé não bastam se o coração não volta.',
      author: 'Tradição: Esdras',
      when: '~séc. V a.C.',
      audience: 'A comunidade restaurada',
    ),
    'ed': BibleBookIntro(
      title: 'O retorno e a Lei de novo',
      summary:
          'Ciro da Pérsia derruba a Babilônia e manda os judeus para casa. Esdras reconduz a Lei; o segundo templo se levanta. Um povo pequeno recomeça debaixo de um império — sem rei da casa de Davi, mas com as Escrituras.',
      author: 'Esdras',
      when: '~séc. V a.C.',
      audience: 'Os repatriados',
    ),
    'ne': BibleBookIntro(
      title: 'Muros e reforma em Jerusalém',
      summary:
          'Neemias deixa o palácio persa para erguer os muros em 52 dias, sob ameaça dos vizinhos. Depois lê a Lei em público. Restauração aqui é pedra e arrependimento — cidade e povo ao mesmo tempo.',
      author: 'Neemias',
      when: '~445 a.C.',
      audience: 'Jerusalém reconstruída',
    ),
    'et': BibleBookIntro(
      title: 'Judeus no palácio da Pérsia',
      summary:
          'Na diáspora, longe do templo, um decreto ameaça extinguir o povo. Ester arrisca o trono de Xerxes. Deus não é nomeado no livro — mas a providência vira cada cena no coração do império.',
      author: 'Desconhecido',
      when: '~séc. V a.C.',
      audience: 'Judeus na diáspora',
    ),
    'jo': BibleBookIntro(
      title: 'O sofrimento do justo',
      summary:
          'A cena é a era dos patriarcas, no Oriente. Jó perde tudo sem uma culpa que explique. Os amigos recitam fórmulas; Deus responde do redemoinho. O livro entra no debate antigo da sabedoria: por que o inocente sofre?',
      author: 'Desconhecido',
      when: 'Era patriarcal',
      audience: 'Quem sofre e pergunta',
    ),
    'sl': BibleBookIntro(
      title: 'O hinário de Israel',
      summary:
          'Orações de Davi e de outros, compostas ao longo de séculos — do templo de Salomão ao exílio e à volta. Lamento, louvor, rei e peregrino. Salmos é a voz de Israel diante de Deus, em festa e em noite escura.',
      author: 'Davi e outros',
      when: 'séc. X–V a.C.',
      audience: 'O culto de Israel',
    ),
    'pv': BibleBookIntro(
      title: 'Sabedoria para o dia a dia',
      summary:
          'Na corte de Israel e no diálogo com a sabedoria do Oriente, sábios reúnem sentenças sobre língua, trabalho, justiça e família. O centro é um só: o temor do Senhor. Sem ele, a esperteza vira ruína.',
      author: 'Tradição: Salomão e sábios',
      when: '~séc. X–VI a.C.',
      audience: 'Jovens e o povo',
    ),
    'ec': BibleBookIntro(
      title: 'Tudo é vapor',
      summary:
          'Um sábio — a tradição diz Salomão — testa prazer, obra e conhecimento no auge da prosperidade. Tudo é vapor. Eclesiastes não é cinismo: é um alerta para não idolatrar o sol, e um convite a temer a Deus no chão da vida.',
      author: 'Tradição: Salomão',
      when: '~séc. X a.C.',
      audience: 'Quem busca sentido',
    ),
    'ct': BibleBookIntro(
      title: 'Canto de amor e aliança',
      summary:
          'Poesia nupcial do antigo Oriente, atribuída a Salomão. Dois amantes se procuram em linguagem ousada e pura. A tradição também lê aqui o amor de Deus pelo seu povo — o humano e o santo no mesmo cântico.',
      author: 'Tradição: Salomão',
      when: '~séc. X a.C.',
      audience: 'Israel; quem ama',
    ),
    'is': BibleBookIntro(
      title: 'O Santo de Israel e o Servo',
      summary:
          'Enquanto a Assíria engole nações, Isaías vê o Senhor no templo de Jerusalém. Anuncia juízo sobre Judá e, no mesmo fôlego, um menino, um Servo sofredor e céus novos. Profecia de crise imperial — e de esperança maior que o império.',
      author: 'Isaías',
      when: '~740–680 a.C.',
      audience: 'Judá ameaçada',
    ),
    'jr': BibleBookIntro(
      title: 'O profeta da queda de Jerusalém',
      summary:
          'Por décadas, Jeremias prega arrependimento enquanto a Babilônia se aproxima. Quase ninguém ouve. A cidade cai em 586 a.C. No meio da ruína, Deus promete uma nova aliança escrita no coração.',
      author: 'Jeremias',
      when: '~627–580 a.C.',
      audience: 'Judá no fim',
    ),
    'lm': BibleBookIntro(
      title: 'O luto de Jerusalém',
      summary:
          'Depois do fogo, cinco poemas de choro. A cidade queimada, o templo no chão, o povo a caminho do exílio. Lamentações dá língua à dor — e ainda assim afirma que as misericórdias do Senhor se renovam cada manhã.',
      author: 'Tradição: Jeremias',
      when: '~586 a.C.',
      audience: 'O povo na ruína',
    ),
    'ez': BibleBookIntro(
      title: 'A glória de Deus no exílio',
      summary:
          'Sacerdote levado à Babilônia, Ezequiel vê a glória partir do templo — e promete que voltará. Deus não ficou preso às ruínas de Jerusalém: alcança os exilados junto aos canais e fala de coração novo e de um templo novo.',
      author: 'Ezequiel',
      when: '~593–571 a.C.',
      audience: 'Exilados na Babilônia',
    ),
    'dn': BibleBookIntro(
      title: 'Fiel no palácio dos impérios',
      summary:
          'Jovem judeu na corte de Babilônia, depois da Pérsia. Daniel serve reis sem dobrar o joelho. As visões mostram impérios que sobem e caem. A tese do livro: o Altíssimo governa o reino dos homens.',
      author: 'Daniel',
      when: '~séc. VI a.C.',
      audience: 'Judeus no exílio',
    ),
    'os': BibleBookIntro(
      title: 'O amor de Deus por um povo infiel',
      summary:
          'No reino do Norte, rico e idólatra, às vésperas da Assíria, Oséias casa com Gômer para encenar a aliança traída. Deus não desiste. O livro é ciúme santo — e um amor que compra de volta quem fugiu.',
      author: 'Oséias',
      when: '~750–725 a.C.',
      audience: 'O reino do Norte',
    ),
    'jl': BibleBookIntro(
      title: 'Gafanhotos e o dia do Senhor',
      summary:
          'Uma praga devasta o campo de Judá. Joel lê o desastre como chamado ao jejum e anuncia o dia do Senhor. Promete o Espírito derramado sobre toda a carne — texto que a igreja vai ouvir de novo em Atos 2.',
      author: 'Joel',
      when: 'Data incerta',
      audience: 'Judá',
    ),
    'am': BibleBookIntro(
      title: 'Justiça no tempo da fartura',
      summary:
          'Israel vive paz aparente e oprime o pobre. Um boieiro de Judá confronta o Norte: festas lotadas, culto vazio. Amós anuncia que o dia do Senhor não é festa para quem esmaga o próximo. A Assíria ainda não chegou — mas a sentença já está na porta.',
      author: 'Amós',
      when: '~760 a.C.',
      audience: 'Israel próspero',
    ),
    'ob': BibleBookIntro(
      title: 'O orgulho de Edom',
      summary:
          'Quando Jerusalém cai, Edom — irmão de Israel — zomba e aproveita. Obadias, o menor dos profetas, diz que o orgulho da montanha não escapa. Um oráculo curto contra quem bate palmas na desgraça alheia.',
      author: 'Obadias',
      when: '~séc. VI a.C.',
      audience: 'Judá ferida',
    ),
    'jn': BibleBookIntro(
      title: 'O profeta que foge de Nínive',
      summary:
          'Nínive é a capital da Assíria, o terror do século. Jonas prefere o mar a pregar para inimigos. Deus insiste. A questão do livro não é o peixe: é um profeta irritado porque o Senhor perdoa demais.',
      author: 'Jonas',
      when: '~séc. VIII a.C.',
      audience: 'Israel insular',
    ),
    'mq': BibleBookIntro(
      title: 'Justiça, misericórdia e um rei em Belém',
      summary:
          'Assíria na fronteira, líderes corruptos em casa. Miquéias denuncia príncipes e profetas venais — e aponta Belém como berço do governante eterno. Juízo e esperança no mesmo fôlego.',
      author: 'Miquéias',
      when: '~735–700 a.C.',
      audience: 'Judá e Israel',
    ),
    'na': BibleBookIntro(
      title: 'A queda de Nínive',
      summary:
          'Décadas depois de Jonas, a Assíria não se arrepende. Naum anuncia o colapso da capital que oprimia o mundo. Consolo para Judá: nenhum império é eterno diante de Deus.',
      author: 'Naum',
      when: '~630 a.C.',
      audience: 'Judá oprimida',
    ),
    'hc': BibleBookIntro(
      title: 'Até quando, Senhor?',
      summary:
          'A injustiça cresce em Judá; a Babilônia sobe no horizonte. Habacuque pergunta por que o mal vence. Deus responde com um plano que assusta — e com a frase: o justo viverá pela fé. O profeta termina cantando, sem ter entendido tudo.',
      author: 'Habacuque',
      when: '~605 a.C.',
      audience: 'Judá inquieta',
    ),
    'sf': BibleBookIntro(
      title: 'O dia do Senhor e um resto que canta',
      summary:
          'Ídolos em Jerusalém, nações ao redor. Sofonias vê um dia de trevas — e, no fim, Deus cantando por um povo humilde. Juízo não é a última palavra. A alegria de Deus é.',
      author: 'Sofonias',
      when: '~630 a.C.',
      audience: 'Judá, antes da reforma',
    ),
    'ag': BibleBookIntro(
      title: 'Reconstruam o templo',
      summary:
          'Dezoito anos após o retorno da Pérsia, o templo ainda é ruína e as casas do povo já estão forradas. Ageu confronta a comunidade e a obra recomeça em 520 a.C. Prioridade: a casa de Deus, não só as nossas.',
      author: 'Ageu',
      when: '520 a.C.',
      audience: 'Os que voltaram',
    ),
    'zc': BibleBookIntro(
      title: 'Visões de restauração e o Rei que virá',
      summary:
          'Colega de Ageu, Zacarias anima a reconstrução com visões — candelabros, cavalos, um Rei no jumentinho. O templo é o agora; o horizonte é maior. Deus ainda não terminou com Jerusalém.',
      author: 'Zacarias',
      when: '~520–480 a.C.',
      audience: 'Jerusalém pós-exílio',
    ),
    'ml': BibleBookIntro(
      title: 'O último profeta do Antigo Testamento',
      summary:
          'O templo está de pé, o amor esfriou. Malaquias cobra culto sincero, casamento e dízimo — e promete um mensageiro que prepara o caminho. Depois, quatro séculos de silêncio até João Batista.',
      author: 'Malaquias',
      when: '~430 a.C.',
      audience: 'Judá restaurada, fria',
    ),
    'mt': BibleBookIntro(
      title: 'Jesus, o Messias de Israel',
      summary:
          'Judeia sob Roma, espera messiânica no ar. Mateus escreve para quem conhecia a Lei: Jesus é filho de Davi, novo Moisés, o Rei do sermão do monte. Cada página liga o Nazareno às Escrituras que Israel já tinha.',
      author: 'Mateus',
      when: '~50–70 d.C.',
      audience: 'Cristãos de origem judaica',
    ),
    'mc': BibleBookIntro(
      title: 'O Evangelho em marcha',
      summary:
          'Provavelmente o mais antigo dos quatro, escrito com a igreja de Roma em vista — e talvez sob perseguição. Marcos é curto e rápido: Jesus age com poder e caminha para a cruz. Um Senhor que sofre com os discípulos.',
      author: 'Marcos',
      when: '~50–65 d.C.',
      audience: 'Cristãos em Roma',
    ),
    'lc': BibleBookIntro(
      title: 'Jesus para todos os povos',
      summary:
          'Lucas, médico grego, ordena o relato para Teófilo e o mundo romano. Mulheres, pobres, samaritanos e perdidos ocupam o centro. O Evangelho não fica em Israel: nasce em Belém e aponta para as nações.',
      author: 'Lucas',
      when: '~60–70 d.C.',
      audience: 'Teófilo e o mundo grego',
    ),
    'joao': BibleBookIntro(
      title: 'O Verbo se fez carne',
      summary:
          'No fim do século I, com debates sobre quem é Jesus, João escolhe sinais e diálogos em vez de repetir os outros. O propósito está escrito: crer que Jesus é o Cristo, o Filho de Deus, e ter vida no nome dele.',
      author: 'João, o apóstolo',
      when: '~80–90 d.C.',
      audience: 'A igreja da Ásia',
    ),
    'at': BibleBookIntro(
      title: 'A igreja e o Evangelho até Roma',
      summary:
          'Continuação de Lucas. De Jerusalém a Roma, o Espírito empurra testemunhas por sinagogas, cidades gregas e tribunais do império. Atos é o mapa de uma fé que não ficou no cenáculo.',
      author: 'Lucas',
      when: '~60–70 d.C.',
      audience: 'Teófilo; a igreja nascente',
    ),
    'rm': BibleBookIntro(
      title: 'O Evangelho da justiça de Deus',
      summary:
          'Paulo ainda não esteve em Roma, capital do mundo, quando escreve sua carta mais densa. Judeus e gentios na mesma igreja, tensões no ar. Todos pecaram; Cristo justifica; o Espírito habita. A carta que formou a igreja.',
      author: 'Paulo',
      when: '~57 d.C.',
      audience: 'A igreja em Roma',
    ),
    '1co': BibleBookIntro(
      title: 'Uma igreja talentosa e dividida',
      summary:
          'Corinto é porto rico, culto a muitos deuses, moral frouxa. A igreja imita a cidade: partidos, imoralidade, ceia desordenada. Paulo chama de volta à cruz. Dons sem amor não edificam; a ressurreição não é opcional.',
      author: 'Paulo',
      when: '~55 d.C.',
      audience: 'A igreja em Corinto',
    ),
    '2co': BibleBookIntro(
      title: 'Ministério ferido, poder na fraqueza',
      summary:
          'A relação rachou. Falsos apóstolos vendem prestígio. Paulo defende o apostolado sem vanglória: tesouro em vaso de barro. A carta mais pessoal dele nasce de conflito, não de aula.',
      author: 'Paulo',
      when: '~56 d.C.',
      audience: 'Corinto, após conflito',
    ),
    'gl': BibleBookIntro(
      title: 'Liberdade em Cristo',
      summary:
          'Nas igrejas da Galácia, alguém exigia circuncisão dos gentios convertidos. Paulo recusa qualquer evangelho misturado. Justificação pela fé, fruto do Espírito — não marca na carne. A carta da liberdade.',
      author: 'Paulo',
      when: '~48–55 d.C.',
      audience: 'Igrejas da Galácia',
    ),
    'ef': BibleBookIntro(
      title: 'A igreja, o corpo de Cristo',
      summary:
          'Da prisão em Roma, Paulo descreve o plano eterno: judeu e gentio num só corpo. Éfeso vivia o culto a Ártemis; a carta desce ao chão — casamento, trabalho, luta espiritual. Doutrina alta, vida comum.',
      author: 'Paulo',
      when: '~60–62 d.C.',
      audience: 'Éfeso e a Ásia',
    ),
    'fp': BibleBookIntro(
      title: 'Alegria na prisão',
      summary:
          'Filipos, colônia romana, foi a primeira igreja na Europa. Paulo escreve acorrentado, pede unidade e cita o hino de Cristo que se esvaziou. Alegria aqui não espera circunstâncias — vive de Cristo.',
      author: 'Paulo',
      when: '~60–62 d.C.',
      audience: 'A igreja em Filipos',
    ),
    'cl': BibleBookIntro(
      title: 'Cristo é suficiente',
      summary:
          'Em Colossos, alguém vendia um evangelho com visões, anjos e regras de comida. Paulo responde da prisão: em Cristo habita toda a plenitude. Não falta peça no Senhor que a igreja já recebeu.',
      author: 'Paulo',
      when: '~60–62 d.C.',
      audience: 'A igreja em Colossos',
    ),
    '1ts': BibleBookIntro(
      title: 'Uma igreja jovem e a volta do Senhor',
      summary:
          'Paulo saiu depressa, perseguido na Via Egnácia. Escreve para recém-convertidos: o Senhor voltará, os mortos em Cristo ressuscitarão. Consolo concreto, não especulação sobre datas.',
      author: 'Paulo',
      when: '~51 d.C.',
      audience: 'Tessalônica',
    ),
    '2ts': BibleBookIntro(
      title: 'O Dia ainda não chegou',
      summary:
          'Alguém fingiu carta de Paulo e a igreja parou de trabalhar. 2 Tessalonicenses corrige o relógio: há apostasia antes do fim. Enquanto isso, permaneçam e ocupem as mãos.',
      author: 'Paulo',
      when: '~51–52 d.C.',
      audience: 'Tessalônica, confusa',
    ),
    '1tm': BibleBookIntro(
      title: 'Como cuidar da casa de Deus',
      summary:
          'Timóteo pastoreia em Éfeso, cidade de falsos mestres. Paulo orienta oração, oficiais, viúvas e doutrina sã. O Evangelho precisa de igreja bem cuidada — não só de pregação solta.',
      author: 'Paulo',
      when: '~62–64 d.C.',
      audience: 'Timóteo, em Éfeso',
    ),
    '2tm': BibleBookIntro(
      title: 'O testamento de Paulo',
      summary:
          'Última carta, sob Nero, perto da morte. Muitos o abandonaram. Paulo pede que Timóteo venha e que pregue a Palavra. Um pai espiritual entrega o testemunho antes de partir.',
      author: 'Paulo',
      when: '~64–67 d.C.',
      audience: 'Timóteo',
    ),
    'tt': BibleBookIntro(
      title: 'Igrejas firmes em Creta',
      summary:
          'Creta tinha má fama; as igrejas eram novas. Tito deve constituir presbíteros e calar mestres vãos. A graça que salva também educa. Fé que não vira conduta ainda não amadureceu.',
      author: 'Paulo',
      when: '~62–64 d.C.',
      audience: 'Tito, em Creta',
    ),
    'fm': BibleBookIntro(
      title: 'Um escravo, um senhor, o Evangelho no meio',
      summary:
          'Onésimo fugiu e encontrou Paulo na prisão. A carta pede a Filemom, em Colossos, que o receba como irmão. Uma folha que mostra o Evangelho desmontando relações de poder por dentro da casa romana.',
      author: 'Paulo',
      when: '~60–62 d.C.',
      audience: 'Filemom, em Colossos',
    ),
    'hb': BibleBookIntro(
      title: 'Jesus é melhor — não voltem atrás',
      summary:
          'Autor desconhecido, antes da queda do templo em 70 d.C. Cristãos de origem judaica, cansados, olhavam de volta ao culto antigo. Hebreus mostra o Filho acima de anjos, Moisés e sacerdotes. A nova aliança é o cumprimento, não um plano B.',
      author: 'Desconhecido',
      when: 'antes de 70 d.C.',
      audience: 'Cristãos de origem judaica',
    ),
    'tg': BibleBookIntro(
      title: 'Fé que se vê',
      summary:
          'Provavelmente o escrito mais antigo do Novo Testamento, de Tiago, irmão de Jesus, às tribos na diáspora. Confronta favoritismo, língua solta e fé sem obras. Não contradiz Paulo: fé viva produz fruto.',
      author: 'Tiago, irmão de Jesus',
      when: '~45–49 d.C.',
      audience: 'As tribos na diáspora',
    ),
    '1pe': BibleBookIntro(
      title: 'Peregrinos sob pressão',
      summary:
          'Cristãos da Ásia Menor, espalhados e estranhos, sofrem por causa do nome. O império fica hostil. Pedro aponta a herança incorruptível e o exemplo de Cristo. Sofrer bem é testemunho.',
      author: 'Pedro',
      when: '~62–64 d.C.',
      audience: 'Cristãos da Ásia Menor',
    ),
    '2pe': BibleBookIntro(
      title: 'Cuidado com mestres falsos',
      summary:
          'Perto da morte, Pedro alerta: haverá quem zombe da volta de Cristo. A demora do Senhor é paciência, não esquecimento. Cresçam na graça — e não se deixem arrastar.',
      author: 'Pedro',
      when: '~64–68 d.C.',
      audience: 'As mesmas igrejas',
    ),
    '1jo': BibleBookIntro(
      title: 'Sinais de vida em Cristo',
      summary:
          'No fim do século, alguns saíram da igreja negando que Cristo veio em carne. João oferece testes simples: fé no Filho, amor aos irmãos, prática da verdade. Comunhão com Deus se verifica.',
      author: 'João, o apóstolo',
      when: '~85–95 d.C.',
      audience: 'Igrejas da Ásia',
    ),
    '2jo': BibleBookIntro(
      title: 'Verdade, amor e discernimento',
      summary:
          'Carta breve a uma igreja: permanecei no ensino de Cristo. Missionários itinerantes nem sempre são sãos. Hospitalidade é virtude; receber quem nega a encarnação é participar da obra má.',
      author: 'João, o apóstolo',
      when: '~85–95 d.C.',
      audience: 'Uma igreja local',
    ),
    '3jo': BibleBookIntro(
      title: 'Hospitalidade e orgulho na igreja',
      summary:
          'Gaio acolhe irmãos; Diótrefes gosta de ser o primeiro e fecha a porta. 3 João honra quem serve na retaguarda e confronta o ego no presbitério de uma igreja local.',
      author: 'João, o apóstolo',
      when: '~85–95 d.C.',
      audience: 'Gaio',
    ),
    'jd': BibleBookIntro(
      title: 'Contendei pela fé',
      summary:
          'Judas, irmão de Jesus, queria escrever sobre salvação e teve de escrever um alerta. Homens ímpios transformam graça em libertinagem. A carta é um grito para guardar o depósito, sem negociar o Evangelho.',
      author: 'Judas, irmão de Jesus',
      when: '~65–80 d.C.',
      audience: 'Igrejas ameaçadas',
    ),
    'ap': BibleBookIntro(
      title: 'O Cordeiro vence',
      summary:
          'João, exilado em Patmos no fim do século I, escreve às sete igrejas da Ásia sob o culto ao imperador. Apocalipse não é mapa de medo: é esperança para quem sofre. Atrás do trono de César há outro trono — e o Cordeiro reina.',
      author: 'João, o apóstolo',
      when: '~95 d.C.',
      audience: 'Sete igrejas da Ásia',
    ),
  };
}
