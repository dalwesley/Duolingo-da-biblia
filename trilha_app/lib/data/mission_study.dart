import '../services/content_catalog_service.dart';

/// Conteúdo de estudo por missão — profundidade além do quiz.
/// Prefere cache remoto (Firestore) quando disponível; senão o mapa local.
class MissionStudy {
  final String passageRef;
  final String passageText;
  final String context;
  final String keyword;
  final String keywordGloss;
  final String focusQuestion;
  final List<String> reflectionPrompts;

  const MissionStudy({
    required this.passageRef,
    required this.passageText,
    required this.context,
    required this.keyword,
    required this.keywordGloss,
    required this.focusQuestion,
    required this.reflectionPrompts,
  });

  static MissionStudy? forSlug(String slug) {
    final remote = ContentCatalogService.instance.studiesCache?[slug];
    if (remote != null) {
      return MissionStudy(
        passageRef: remote['passageRef'] as String? ?? '',
        passageText: remote['passageText'] as String? ?? '',
        context: remote['context'] as String? ?? '',
        keyword: remote['keyword'] as String? ?? '',
        keywordGloss: remote['keywordGloss'] as String? ?? '',
        focusQuestion: remote['focusQuestion'] as String? ?? '',
        reflectionPrompts: (remote['reflectionPrompts'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
    }
    return _bySlug[slug];
  }

  /// Texto do versículo para releitura no erro (por referência).
  static String? verseText(String? ref) {
    if (ref == null || ref.trim().isEmpty) return null;
    String norm(String s) => s
        .trim()
        .toLowerCase()
        .replaceAll('ê', 'e')
        .replaceAll('é', 'e')
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ô', 'o')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'\s+'), ' ');

    final compact = norm(ref);
    final sources = <Map<String, String>>[
      if (ContentCatalogService.instance.versesCache != null)
        ContentCatalogService.instance.versesCache!,
      _verses,
    ];

    for (final verses in sources) {
      for (final e in verses.entries) {
        final ek = norm(e.key);
        if (compact.contains(ek) || ek.contains(compact)) return e.value;
      }

      final m = RegExp(r'genesis\s+(\d+:\d+)').firstMatch(compact);
      if (m != null) {
        final cite = 'genesis ${m.group(1)}';
        for (final e in verses.entries) {
          final ek = norm(e.key);
          if (ek.startsWith(cite) || cite.startsWith(ek)) return e.value;
        }
      }
    }
    return null;
  }

  static const _bySlug = <String, MissionStudy>{
    'gen-01-criador': MissionStudy(
      passageRef: 'Gênesis 1:1–2',
      passageText:
          'No princípio, Deus criou os céus e a terra. A terra, porém, estava sem forma e vazia; havia trevas sobre a face do abismo, e o Espírito de Deus pairava sobre a face das águas.',
      context: 'Antes de qualquer coisa existir, Deus já era. A Bíblia não começa com o homem — começa com o Criador.',
      keyword: 'Criar (bara)',
      keywordGloss: 'No hebraico, bara aponta para Deus como origem de tudo — não remodelar o que já existia.',
      focusQuestion: 'O que muda se Deus é o princípio de tudo?',
      reflectionPrompts: [
        'Deus é o centro, não eu',
        'Tudo tem origem nEle',
        'Há propósito na criação',
      ],
    ),
    'gen-02-dias': MissionStudy(
      passageRef: 'Gênesis 1:3–25',
      passageText:
          'Disse Deus: Haja luz; e houve luz. … Deus chamou à luz Dia; e às trevas, Noite. … E disse Deus: Produza a terra seres viventes… e assim se fez.',
      context: 'Deus organiza o caos em seis dias: primeiro os ambientes, depois os habitantes. Há ordem, ritmo e bondade.',
      keyword: 'E Deus viu que era bom',
      keywordGloss: 'A criação não é acaso — é avaliada por Deus como boa, com propósito.',
      focusQuestion: 'Por que a ordem dos dias importa?',
      reflectionPrompts: [
        'Deus traz ordem ao caos',
        'Cada dia tem propósito',
        'A criação é boa',
      ],
    ),
    'gen-03-imagem': MissionStudy(
      passageRef: 'Gênesis 1:26–28',
      passageText:
          'Também disse Deus: Façamos o homem à nossa imagem, conforme a nossa semelhança; e domine… Deus criou o homem à sua imagem; à imagem de Deus o criou; homem e mulher os criou.',
      context: 'O ser humano não é um acidente. Carrega a imagem de Deus — dignidade, responsabilidade e comunhão.',
      keyword: 'Imagem de Deus',
      keywordGloss: 'Imago Dei: valor intrínseco de cada pessoa e chamado a refletir o caráter de Deus.',
      focusQuestion: 'O que significa ser feito à imagem de Deus?',
      reflectionPrompts: [
        'Tenho dignidade dada por Deus',
        'Sou chamado a cuidar',
        'Homem e mulher: juntos no propósito',
      ],
    ),
    'gen-04-descanso': MissionStudy(
      passageRef: 'Gênesis 2:1–3',
      passageText:
          'Assim, pois, foram acabados os céus e a terra… E, havendo Deus terminado… descansou no sétimo dia… E abençoou Deus o dia sétimo e o santificou.',
      context: 'O descanso de Deus não é fadiga — é completar, santificar e convidar a humanidade a um ritmo de graça.',
      keyword: 'Sábado / Descanso',
      keywordGloss: 'Santificar o tempo: viver na confiança de que Deus sustenta o mundo.',
      focusQuestion: 'O que o descanso revela sobre Deus?',
      reflectionPrompts: [
        'Deus completa o que começa',
        'Descanso é graça, não preguiça',
        'Preciso de um ritmo santo',
      ],
    ),
    'gen-boss-01': MissionStudy(
      passageRef: 'Gênesis 1:1–2:3',
      passageText:
          'No princípio, Deus criou… E viu Deus tudo quanto fizera, e eis que era muito bom. … E abençoou Deus o dia sétimo e o santificou.',
      context: 'Revise o fio da Criação: Deus fala, ordena, abençoa e descansa. Você está pronto para o desafio?',
      keyword: 'Muito bom',
      keywordGloss: 'Ao final do sexto dia, a avaliação sobe: não só “bom”, mas “muito bom”.',
      focusQuestion: 'Qual é o centro da narrativa da criação?',
      reflectionPrompts: [
        'Deus é soberano',
        'A criação tem ordem',
        'O ser humano é especial',
      ],
    ),
    'gen-05-eden': MissionStudy(
      passageRef: 'Gênesis 2:8–15',
      passageText:
          'E plantou o Senhor Deus um jardim no Éden… Tomou, pois, o Senhor Deus ao homem e o pôs no jardim do Éden para o cultivar e o guardar.',
      context: 'O Éden é lugar de comunhão, trabalho e beleza. O homem não foi feito para o ócio — foi feito para cuidar.',
      keyword: 'Cultivar e guardar',
      keywordGloss: 'Vocação humana: trabalhar com cuidado e proteger o que Deus confia.',
      focusQuestion: 'O que o jardim ensina sobre o propósito humano?',
      reflectionPrompts: [
        'Trabalho pode ser culto',
        'Deus cuida e me chama a cuidar',
        'Comunhão com Deus é o centro',
      ],
    ),
    'gen-06-queda': MissionStudy(
      passageRef: 'Gênesis 3:1–6',
      passageText:
          'A serpente era mais astuta… Disse a mulher… Então, vendo a mulher que a árvore era boa… tomou do seu fruto, comeu e deu também ao marido.',
      context: 'A tentação começa distorcendo a palavra de Deus. Desconfiar de Deus abre a porta à desobediência.',
      keyword: 'Certamente não morrereis',
      keywordGloss: 'A mentira central: negar a consequência e questionar a bondade de Deus.',
      focusQuestion: 'Onde a desconfiança começa na história?',
      reflectionPrompts: [
        'A palavra de Deus é confiável',
        'Desejo pode enganar',
        'Desobediência tem custo',
      ],
    ),
    'gen-07-consequencias': MissionStudy(
      passageRef: 'Gênesis 3:14–19',
      passageText:
          '…porei inimizade entre ti e a mulher… este te ferirá a cabeça… À mulher disse… Ao homem disse… no suor do teu rosto…',
      context: 'O pecado quebra relações: com Deus, consigo, com o outro e com a criação. Ainda assim, há promessa.',
      keyword: 'Gênesis 3:15',
      keywordGloss: 'O protoevangelho: a primeira sombra da vitória sobre o mal.',
      focusQuestion: 'O que ainda há de esperança após a queda?',
      reflectionPrompts: [
        'O pecado tem consequências reais',
        'Deus ainda busca o homem',
        'Há promessa de vitória',
      ],
    ),
    'gen-boss-02': MissionStudy(
      passageRef: 'Gênesis 2–3',
      passageText:
          'Do Éden à expulsão: comunhão, tentação, queda e promessa. “Porei inimizade… este te ferirá a cabeça.”',
      context: 'O desafio da Queda exige ver o contraste: o jardim perfeito e a necessidade de redenção.',
      keyword: 'Queda e promessa',
      keywordGloss: 'A narrativa não termina no julgamento — aponta para restauração.',
      focusQuestion: 'Como a queda prepara a história da salvação?',
      reflectionPrompts: [
        'Preciso de redenção',
        'Deus não abandona',
        'A esperança começa cedo',
      ],
    ),
    'gen-08-caim': MissionStudy(
      passageRef: 'Gênesis 4:3–10',
      passageText:
          '…olhou o Senhor para Abel e para a sua oferta… Caim irou-se… Disse o Senhor a Caim: …o sangue de teu irmão clama a mim desde a terra.',
      context: 'O pecado avança: da desobediência à violência. Deus ainda confronta e oferece caminho.',
      keyword: 'Onde está Abel, teu irmão?',
      keywordGloss: 'Deus exige responsabilidade pelo outro — o pecado não é só privado.',
      focusQuestion: 'O que a história de Caim revela sobre o coração humano?',
      reflectionPrompts: [
        'Inveja destrói',
        'Sou responsável pelo outro',
        'Deus vê a injustiça',
      ],
    ),
    'gen-09-diluvio': MissionStudy(
      passageRef: 'Gênesis 6:5–9; 9:12–13',
      passageText:
          'Viu o Senhor que a maldade do homem era grande… Porém Noé achou graça… O meu arco tenho posto nas nuvens; este será por sinal da aliança.',
      context: 'Juízo e graça caminham juntos: o dilúvio confronta a maldade; a aliança promete fidelidade de Deus.',
      keyword: 'Aliança / Arco',
      keywordGloss: 'Deus se compromete: juízo não é a última palavra; há pacto de misericórdia.',
      focusQuestion: 'Como graça e juízo aparecem juntos no dilúvio?',
      reflectionPrompts: [
        'Deus leva o pecado a sério',
        'Há graça no meio do juízo',
        'A aliança me sustenta',
      ],
    ),
    'gen-10-babel': MissionStudy(
      passageRef: 'Gênesis 11:1–9',
      passageText:
          '…digamos: Edifiquemos… uma torre cujo topo toque nos céus e façamos um nome… Então, desceu o Senhor… confundiu a linguagem…',
      context: 'Babel é orgulho coletivo: fazer um nome sem Deus. A confusão das línguas limita a arrogância humana.',
      keyword: 'Façamos um nome',
      keywordGloss: 'Autoglorificação versus a missão de Deus de espalhar e abençoar as nações.',
      focusQuestion: 'O que Babel diz sobre ambição sem Deus?',
      reflectionPrompts: [
        'Orgulho divide',
        'Deus frustra a arrogância',
        'O nome que importa é o dEle',
      ],
    ),
    'gen-11-abraao': MissionStudy(
      passageRef: 'Gênesis 12:1–3',
      passageText:
          'Ora, o Senhor disse a Abrão: Sai… para a terra que te mostrarei… Em ti serão benditas todas as famílias da terra.',
      context: 'Depois do juízo e da confusão, Deus chama um homem — e através dele promete bênção a todas as famílias.',
      keyword: 'Bênção às nações',
      keywordGloss: 'A promessa a Abraão é o fio da redenção que atravessa toda a Escritura.',
      focusQuestion: 'Por que o chamado de Abrão muda a história?',
      reflectionPrompts: [
        'Deus inicia a restauração',
        'Fé envolve sair',
        'A bênção é para as nações',
      ],
    ),
    'gen-boss-final': MissionStudy(
      passageRef: 'Gênesis 1–12',
      passageText:
          'Criação → Queda → Juízo → Promessa. Do “No princípio” ao chamado de Abrão: Deus não desiste da humanidade.',
      context: 'Este desafio une o fio de Gênesis 1–11. Você não está só testando memória — está traçando o plano de Deus.',
      keyword: 'Promessa',
      keywordGloss: 'O centro de Gênesis 1–11 não é só o pecado — é a fidelidade de Deus que abre caminho.',
      focusQuestion: 'Qual é o fio que liga Criação, Queda e Abraão?',
      reflectionPrompts: [
        'Deus cria e sustenta',
        'O pecado quebra, mas não vence',
        'A promessa aponta para Cristo',
      ],
    ),
    'exo-01-opressao': MissionStudy(
      passageRef: 'Êxodo 1:8–14',
      passageText:
          'Levantou-se novo rei sobre o Egito, que não conhecera a José. … Os egípcios… fizeram-lhes a vida amarga com dura servidão.',
      context: 'Israel cresceu sob bênção; o medo político do faraó virou opressão. O clamor do povo sobe a Deus.',
      keyword: 'Clamor',
      keywordGloss: 'Deus ouve o sofrimento — a libertação começa quando o povo clama e Deus se lembra da aliança.',
      focusQuestion: 'O que o medo do faraó revela sobre o poder humano?',
      reflectionPrompts: [
        'Deus ouve o oprimido',
        'A aliança não é esquecida',
        'O medo gera injustiça',
      ],
    ),
    'exo-02-moises': MissionStudy(
      passageRef: 'Êxodo 3:1–14',
      passageText:
          'Apareceu-lhe o Anjo do Senhor numa chama de fogo, no meio de uma sarça… Disse Deus a Moisés: EU SOU O QUE SOU.',
      context: 'No deserto, Deus chama um fugitivo. A presença santa (sarça) e o Nome revelado sustentam a missão.',
      keyword: 'EU SOU (YHWH)',
      keywordGloss: 'O Nome aponta para o Deus eterno, presente e fiel — Moisés não vai sozinho.',
      focusQuestion: 'Por que Deus revela o Nome antes de enviar Moisés?',
      reflectionPrompts: [
        'Deus chama os hesitantes',
        'A presença precede a missão',
        'O Nome sustenta a fé',
      ],
    ),
    'exo-03-pragas': MissionStudy(
      passageRef: 'Êxodo 7–12',
      passageText:
          '…para que saibas que eu sou o Senhor no meio da terra… Mas o Senhor endureceu o coração do faraó.',
      context: 'As pragas confrontam os ídolos do Egito. É juízo e revelação: YHWH é o Senhor.',
      keyword: 'Juízo e sinal',
      keywordGloss: 'Cada praga demonstra o poder de Deus sobre criação e deuses falsos.',
      focusQuestion: 'O que as pragas ensinam sobre quem é Deus?',
      reflectionPrompts: [
        'Deus confronta ídolos',
        'Libertação custa enfrentamento',
        'Sinais apontam para o Senhor',
      ],
    ),
    'exo-04-pascoa': MissionStudy(
      passageRef: 'Êxodo 12:1–13',
      passageText:
          'O sangue vos será por sinal nas casas… vendo eu sangue, passarei por cima de vós.',
      context: 'A Páscoa une sacrifício, proteção e memorial. Israel sai pela graça do cordeiro.',
      keyword: 'Cordeiro / Páscoa',
      keywordGloss: 'O sangue marca quem pertence a Deus — tipo da redenção plena em Cristo.',
      focusQuestion: 'Por que o memorial exige sangue e partilha?',
      reflectionPrompts: [
        'A libertação tem custo',
        'Memória forma identidade',
        'Graça que protege',
      ],
    ),
    'exo-05-mar': MissionStudy(
      passageRef: 'Êxodo 14:13–31',
      passageText:
          'Não temais; permanecei firmes e vede o livramento do Senhor… o Senhor pelejará por vós.',
      context: 'Entre o Egito e o mar, Israel aprende: a salvação é do Senhor, não da força própria.',
      keyword: 'Salvação',
      keywordGloss: 'Deus abre caminho onde não há saída — fé é permanecer e ver.',
      focusQuestion: 'O que significa “o Senhor pelejará por vós” hoje?',
      reflectionPrompts: [
        'Deus abre caminhos',
        'Medo não tem a última palavra',
        'Vitória vem do Senhor',
      ],
    ),
    'exo-boss-01': MissionStudy(
      passageRef: 'Êxodo 1–15',
      passageText:
          'Do clamor à canção: Deus ouve, chama, julga, protege e liberta — e o povo responde com louvor.',
      context: 'Este desafio une opressão, chamado, Páscoa e mar. O fio é a fidelidade libertadora de Deus.',
      keyword: 'Libertação',
      keywordGloss: 'Êxodo não é só fuga política — é Deus formando um povo para si.',
      focusQuestion: 'Qual é o fio que liga sarça, Páscoa e Mar Vermelho?',
      reflectionPrompts: [
        'Deus ouve e age',
        'Redenção cria povo',
        'Louvor responde à graça',
      ],
    ),
    'evg-01-encarnacao': MissionStudy(
      passageRef: 'João 1:1–14',
      passageText:
          'No princípio era o Verbo… E o Verbo se fez carne e habitou entre nós, cheio de graça e de verdade.',
      context: 'Os Evangelhos abrem com Deus entrando na história. Jesus não é apenas mestre — é o Verbo eterno.',
      keyword: 'Verbo / Logos',
      keywordGloss: 'Palavra viva de Deus: revelação plena em Pessoa.',
      focusQuestion: 'O que muda se Jesus é o Verbo feito carne?',
      reflectionPrompts: [
        'Deus se aproximou',
        'Graça e verdade juntas',
        'A história tem centro em Cristo',
      ],
    ),
    'evg-02-batismo': MissionStudy(
      passageRef: 'Mateus 3:13–17',
      passageText:
          'Este é o meu Filho amado, em quem me comprazo.',
      context: 'O batismo marca o início público: Pai, Filho e Espírito presentes na missão.',
      keyword: 'Filho amado',
      keywordGloss: 'Identidade antes da performance — Jesus serve como o Filho amado.',
      focusQuestion: 'Por que a voz do Pai importa no início do ministério?',
      reflectionPrompts: [
        'Identidade precede missão',
        'O Espírito capacita',
        'Obediência no Jordão',
      ],
    ),
    'evg-03-tentacao': MissionStudy(
      passageRef: 'Mateus 4:1–11',
      passageText:
          'Está escrito: Não só de pão viverá o homem…',
      context: 'No deserto, Jesus é fiel onde Israel falhou. A Escritura é Sua defesa.',
      keyword: 'Está escrito',
      keywordGloss: 'A resistência à tentação se apoia na Palavra interiorizada.',
      focusQuestion: 'Como a Palavra sustenta você na tentação?',
      reflectionPrompts: [
        'Fidelidade no deserto',
        'Memorizar para resistir',
        'Adorar só a Deus',
      ],
    ),
    'evg-boss-01': MissionStudy(
      passageRef: 'João 1; Mateus 3–4',
      passageText: 'Encarnado, amado e fiel — assim começa o Messias.',
      context: 'Do Berço ao deserto: identidade e obediência abrem o ministério.',
      keyword: 'Fidelidade',
      keywordGloss: 'O Filho vive a missão do Pai sem atalhos.',
      focusQuestion: 'Qual fio une encarnação, batismo e tentação?',
      reflectionPrompts: [
        'Jesus é o Filho fiel',
        'Missão com identidade',
        'Palavra na luta',
      ],
    ),
    'evg-04-sermao': MissionStudy(
      passageRef: 'Mateus 5:1–16',
      passageText:
          'Bem-aventurados os pobres de espírito, porque deles é o reino dos céus.',
      context: 'O Sermão do Monte inverte valores: o Reino começa na dependência de Deus.',
      keyword: 'Bem-aventurança',
      keywordGloss: 'Felicidade do Reino — não conforto mundano, mas vida sob Deus.',
      focusQuestion: 'O que as bem-aventuranças desafiam em você?',
      reflectionPrompts: [
        'Pobreza de espírito',
        'Ser sal e luz',
        'Reino invertido',
      ],
    ),
    'evg-05-parabolas': MissionStudy(
      passageRef: 'Mateus 13:1–23',
      passageText:
          'Outra caiu em boa terra e dava fruto…',
      context: 'Parábolas revelam e escondem: o Reino cresce pela Palavra acolhida.',
      keyword: 'Semente',
      keywordGloss: 'A mensagem do Reino precisa de solo — ouvidos que entendem.',
      focusQuestion: 'Qual solo descreve seu coração hoje?',
      reflectionPrompts: [
        'Ouvir e entender',
        'Frutificar',
        'Cuidado com espinhos',
      ],
    ),
    'evg-06-milagres': MissionStudy(
      passageRef: 'Marcos 6:30–44',
      passageText:
          'Compadeceu-se deles, porque eram como ovelhas que não têm pastor.',
      context: 'Sinais revelam o Rei compassivo: poder a serviço do cuidado.',
      keyword: 'Compaixão',
      keywordGloss: 'Os milagres nascem de misericórdia, não de espetáculo.',
      focusQuestion: 'Como o poder de Jesus se une à compaixão?',
      reflectionPrompts: [
        'Reino que cura',
        'Cuidar da multidão',
        'Autoridade amorosa',
      ],
    ),
    'evg-boss-02': MissionStudy(
      passageRef: 'Mateus 5; 13',
      passageText: 'Ensino e sinais: o Reino chega em palavras e ações.',
      context: 'Bem-aventuranças, parábolas e milagres pintam o mesmo Reino.',
      keyword: 'Reino',
      keywordGloss: 'Governo de Deus presente em Jesus, transformando coração e mundo.',
      focusQuestion: 'Como o Reino se mostra no ensino e nos sinais?',
      reflectionPrompts: [
        'Palavra que frutifica',
        'Vida invertida',
        'Misericórdia ativa',
      ],
    ),
    'evg-07-ceia': MissionStudy(
      passageRef: 'Lucas 22:14–20',
      passageText:
          'Isto é o meu corpo… Este cálice é a nova aliança no meu sangue.',
      context: 'Na ceia, Jesus interpreta Sua morte: corpo entregue, sangue da aliança.',
      keyword: 'Nova aliança',
      keywordGloss: 'Relação selada pelo sangue de Cristo — memorial e graça.',
      focusQuestion: 'O que significa participar da ceia com consciência?',
      reflectionPrompts: [
        'Entrega por mim',
        'Aliança renovada',
        'Lembrar até que venha',
      ],
    ),
    'evg-08-cruz': MissionStudy(
      passageRef: 'Marcos 15:22–39',
      passageText:
          'O Filho do Homem… veio para dar a sua vida em resgate por muitos.',
      context: 'A cruz não é acidente: é o amor que paga o resgate.',
      keyword: 'Resgate',
      keywordGloss: 'Vida dada para libertar — centro do evangelho.',
      focusQuestion: 'O que a cruz diz sobre o valor da sua vida diante de Deus?',
      reflectionPrompts: [
        'Amor que se entrega',
        'Perdão custoso',
        'Vitória pelo sacrifício',
      ],
    ),
    'evg-09-ressurreicao': MissionStudy(
      passageRef: 'Mateus 28:1–20',
      passageText:
          'Não está aqui; ressuscitou… Ide, fazei discípulos de todas as nações.',
      context: 'O túmulo vazio lança a missão: o Senhor vivo envia Seu povo.',
      keyword: 'Ressurreição',
      keywordGloss: 'Primeícias da nova criação — esperança histórica e pessoal.',
      focusQuestion: 'Como a ressurreição muda sua missão hoje?',
      reflectionPrompts: [
        'Ele vive',
        'Missão a todas as nações',
        'Presença até o fim',
      ],
    ),
    'evg-boss-final': MissionStudy(
      passageRef: 'João 1; Mateus 28',
      passageText: 'Do Verbo encarnado ao Rei ressuscitado — o evangelho completo.',
      context: 'Os quatro Evangelhos contam um arco: vinda, cruz e vitória.',
      keyword: 'Evangelho',
      keywordGloss: 'Boas novas: Jesus Cristo, Senhor que salva e envia.',
      focusQuestion: 'Qual é o arco que você carrega dos Evangelhos?',
      reflectionPrompts: [
        'Cristo no centro',
        'Cruz e vida',
        'Enviados com poder',
      ],
    ),
    'ato-01-ascensao': MissionStudy(
      passageRef: 'Atos 1:1–11',
      passageText:
          'Recebereis poder… e sereis minhas testemunhas… até aos confins da terra.',
      context: 'Jesus sobe, mas não abandona: o Espírito virá para a missão.',
      keyword: 'Testemunhas',
      keywordGloss: 'A igreja existe para apontar a Jesus em toda parte.',
      focusQuestion: 'Onde começa e até onde vai o seu testemunho?',
      reflectionPrompts: [
        'Esperar o Espírito',
        'Missão sem fronteiras',
        'Cristo reinando',
      ],
    ),
    'ato-02-pentecostes': MissionStudy(
      passageRef: 'Atos 2:1–41',
      passageText:
          'Todos ficaram cheios do Espírito Santo… Deus o fez Senhor e Cristo.',
      context: 'Pentecostes é o lançamento público: poder, pregação e arrependimento.',
      keyword: 'Espírito Santo',
      keywordGloss: 'Presença de Deus que capacita a igreja a falar e viver o evangelho.',
      focusQuestion: 'O que muda quando a igreja depende do Espírito?',
      reflectionPrompts: [
        'Ousadia no anúncio',
        'Jesus é Senhor',
        'Coração cortado e batizado',
      ],
    ),
    'ato-03-comunhao': MissionStudy(
      passageRef: 'Atos 2:42–47',
      passageText:
          'E perseveravam na doutrina dos apóstolos e na comunhão, no partir do pão e nas orações.',
      context: 'A missão flui de uma comunidade que aprende, partilha e ora.',
      keyword: 'Comunhão',
      keywordGloss: 'Vida compartilhada em Cristo — não só eventos isolados.',
      focusQuestion: 'Qual desses quatro pilares está mais fraco em você?',
      reflectionPrompts: [
        'Perserverar no ensino',
        'Partilhar a vida',
        'Orar juntos',
      ],
    ),
    'ato-boss-01': MissionStudy(
      passageRef: 'Atos 1–2',
      passageText: 'Ascensão, Espírito e comunidade — a igreja em movimento.',
      context: 'O livro de Atos começa no céu e deságua numa rua cheia de testemunho.',
      keyword: 'Missão',
      keywordGloss: 'Impulsionada pelo Espírito, centrada em Jesus, vivida em comunhão.',
      focusQuestion: 'Qual fio liga ascensão e Pentecostes?',
      reflectionPrompts: [
        'Jesus reina',
        'Espírito envia',
        'Igreja testemunha',
      ],
    ),
    'apo-01-cartas': MissionStudy(
      passageRef: 'Apocalipse 2–3',
      passageText:
          'Quem tem ouvidos, ouça o que o Espírito diz às igrejas.',
      context: 'Jesus pastoralmente corrige e anima: fidelidade sob pressão.',
      keyword: 'Vencedor',
      keywordGloss: 'Quem persevera em Cristo — não o mais forte isolado.',
      focusQuestion: 'Que palavra Jesus falaria à sua igreja hoje?',
      reflectionPrompts: [
        'Ouvir o Espírito',
        'Perseverar',
        'Primeiro amor',
      ],
    ),
    'apo-02-cordeiro': MissionStudy(
      passageRef: 'Apocalipse 5',
      passageText:
          'Digno é o Cordeiro que foi morto de receber o poder…',
      context: 'No trono está o Cordeiro imolado: vitória pelo sacrifício.',
      keyword: 'Cordeiro',
      keywordGloss: 'Cristo crucificado e exaltado — centro da história e do culto.',
      focusQuestion: 'Por que o Cordeiro morto é o mais digno?',
      reflectionPrompts: [
        'Vitória pela cruz',
        'Culto ao Cordeiro',
        'História sob Seu selo',
      ],
    ),
    'apo-03-novo': MissionStudy(
      passageRef: 'Apocalipse 21:1–5',
      passageText:
          'Eis o tabernáculo de Deus com os homens… E lhes enxugará dos olhos toda lágrima.',
      context: 'O fim é restauração: Deus conosco, criação renovada.',
      keyword: 'Nova criação',
      keywordGloss: 'Não fuga do mundo — renovação de todas as coisas em Deus.',
      focusQuestion: 'Como essa esperança muda seu sofrimento presente?',
      reflectionPrompts: [
        'Deus habitará conosco',
        'Fim da morte',
        'Ele faz novas todas as coisas',
      ],
    ),
    'apo-boss-01': MissionStudy(
      passageRef: 'Apocalipse 1–22',
      passageText: 'Das cartas ao trono e à cidade: o Cordeiro vence.',
      context: 'Apocalipse sustenta igrejas pressionadas com esperança concreta.',
      keyword: 'Esperança',
      keywordGloss: 'O futuro está nas mãos do Cordeiro — perseverem.',
      focusQuestion: 'O que o Apocalipse faz com o medo?',
      reflectionPrompts: [
        'Cordeiro no centro',
        'Igreja que vence',
        'Nova criação',
      ],
    ),
  };

  static const _verses = <String, String>{
    'gênesis 1:1': 'No princípio, Deus criou os céus e a terra.',
    'genesis 1:1': 'No princípio, Deus criou os céus e a terra.',
    'gênesis 1:2': 'A terra, porém, estava sem forma e vazia; havia trevas sobre a face do abismo, e o Espírito de Deus pairava sobre a face das águas.',
    'gênesis 1:3': 'Disse Deus: Haja luz; e houve luz.',
    'gênesis 1:26': 'Também disse Deus: Façamos o homem à nossa imagem, conforme a nossa semelhança…',
    'gênesis 1:27': 'Criou Deus, pois, o homem à sua imagem; à imagem de Deus o criou; homem e mulher os criou.',
    'gênesis 2:2': 'E, havendo Deus terminado… descansou no sétimo dia de toda a obra que fizera.',
    'gênesis 2:3': 'E abençoou Deus o dia sétimo e o santificou…',
    'gênesis 2:8': 'E plantou o Senhor Deus um jardim no Éden… e pôs ali o homem que havia formado.',
    'gênesis 2:15': 'Tomou, pois, o Senhor Deus ao homem e o pôs no jardim do Éden para o cultivar e o guardar.',
    'gênesis 3:1': 'A serpente era mais astuta que todos os animais…',
    'gênesis 3:6': 'Então, vendo a mulher que a árvore era boa… tomou do seu fruto, comeu…',
    'gênesis 3:15': 'Porei inimizade entre ti e a mulher… este te ferirá a cabeça…',
    'gênesis 4:9': 'Disse o Senhor a Caim: Onde está Abel, teu irmão?…',
    'gênesis 6:5': 'Viu o Senhor que a maldade do homem se multiplicara…',
    'gênesis 6:8': 'Porém Noé achou graça diante do Senhor.',
    'gênesis 9:13': 'O meu arco tenho posto nas nuvens; este será por sinal da aliança…',
    'gênesis 11:4': '…edifiquemos… uma torre… e façamos um nome…',
    'gênesis 11:7': '…desçamos e confundamos ali a sua linguagem…',
    'gênesis 12:1': 'Ora, o Senhor disse a Abrão: Sai da tua terra…',
    'gênesis 12:2': 'De ti farei uma grande nação…',
    'gênesis 12:3': '…em ti serão benditas todas as famílias da terra.',
    'êxodo 1:8': 'Levantou-se novo rei sobre o Egito, que não conhecera a José.',
    'exodo 1:8': 'Levantou-se novo rei sobre o Egito, que não conhecera a José.',
    'êxodo 2:23': '…os filhos de Israel gemiam sob a servidão… e o seu clamor subiu a Deus.',
    'êxodo 3:2': 'Apareceu-lhe o Anjo do Senhor numa chama de fogo, no meio de uma sarça.',
    'êxodo 3:14': 'Disse Deus a Moisés: EU SOU O QUE SOU.',
    'êxodo 12:13': 'O sangue vos será por sinal… vendo eu sangue, passarei por cima de vós.',
    'êxodo 14:13': 'Não temais; permanecei firmes e vede o livramento do Senhor…',
    'êxodo 14:14': 'O Senhor pelejará por vós, e vós vos calareis.',
    'joão 1:1': 'No princípio era o Verbo, e o Verbo estava com Deus, e o Verbo era Deus.',
    'joao 1:1': 'No princípio era o Verbo, e o Verbo estava com Deus, e o Verbo era Deus.',
    'joão 1:14': 'E o Verbo se fez carne e habitou entre nós…',
    'mateus 3:17': 'Este é o meu Filho amado, em quem me comprazo.',
    'mateus 4:4': 'Está escrito: Não só de pão viverá o homem…',
    'mateus 5:3': 'Bem-aventurados os pobres de espírito, porque deles é o reino dos céus.',
    'mateus 13:23': '…o que foi semeado em boa terra… e dá fruto…',
    'marcos 6:34': '…compadeceu-se deles, porque eram como ovelhas que não têm pastor.',
    'lucas 22:19': 'Isto é o meu corpo, que é dado por vós…',
    'lucas 22:20': 'Este cálice é a nova aliança no meu sangue…',
    'marcos 10:45': '…o Filho do Homem… veio para dar a sua vida em resgate por muitos.',
    'mateus 28:6': 'Não está aqui; ressuscitou, como havia dito.',
    'mateus 28:19': 'Ide, portanto, fazei discípulos de todas as nações…',
    'atos 1:8': '…recebereis poder… e sereis minhas testemunhas… até aos confins da terra.',
    'atos 2:4': 'Todos ficaram cheios do Espírito Santo…',
    'atos 2:36': '…Deus o fez Senhor e Cristo, a este Jesus…',
    'atos 2:42': 'E perseveravam na doutrina dos apóstolos e na comunhão…',
    'apocalipse 2:7': '…ao vencedor, dar-lhe-ei que se alimente da árvore da vida…',
    'apocalipse 5:12': 'Digno é o Cordeiro que foi morto…',
    'apocalipse 21:4': '…e lhes enxugará dos olhos toda lágrima…',
  };
}
