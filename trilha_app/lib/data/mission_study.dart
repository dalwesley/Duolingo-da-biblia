/// Conteúdo de estudo por missão — profundidade além do quiz.
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

  static MissionStudy? forSlug(String slug) => _bySlug[slug];

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

    for (final e in _verses.entries) {
      final ek = norm(e.key);
      if (compact.contains(ek) || ek.contains(compact)) return e.value;
    }

    final m = RegExp(r'genesis\s+(\d+:\d+)').firstMatch(compact);
    if (m != null) {
      final cite = 'genesis ${m.group(1)}';
      for (final e in _verses.entries) {
        final ek = norm(e.key);
        if (ek.startsWith(cite) || cite.startsWith(ek)) return e.value;
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
  };
}
