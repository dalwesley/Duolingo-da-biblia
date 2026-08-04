"""Dados das trilhas de teologia, em linguagem acessível."""


def _seeds(ref, question, answer, truth, practice):
    """Cria cinco perguntas por missão, incluindo fato, sentido e aplicação."""
    return [
        {"q_s": question, "q_c": "O que esse texto ensina sobre Deus?", "q_p": "Como essa verdade muda sua vida?", "answer": answer, "wrong": ["O esforço humano basta", "Deus não se importa", "A Bíblia não tem resposta"], "verse": ref},
        {"q_s": "Qual é a referência principal desta missão?", "q_c": "Por que ela importa para a fé?", "q_p": "Como você a lembrará nesta semana?", "answer": ref, "wrong": ["Gênesis 1:1", "Salmos 23:1", "Apocalipse 21:1"], "verse": ref},
        {"q_s": "Qual verdade resume esta missão?", "q_c": "Como ela se relaciona com Jesus?", "q_p": "Que atitude ela inspira?", "answer": truth, "wrong": ["A salvação é conquistada", "Cristo é dispensável", "A fé não transforma"], "verse": ref},
        {"q_s": "Quem é o centro da fé cristã?", "q_c": "Por que devemos confiar nele?", "q_p": "Como você pode segui-lo hoje?", "answer": "Jesus Cristo", "wrong": ["O próprio mérito", "A opinião popular", "O medo"], "verse": ref},
        {"q_s": "Qual resposta prática combina com este ensino?", "q_c": "Como a graça orienta essa resposta?", "q_p": "Qual passo você dará?", "answer": practice, "wrong": ["Confiar somente em si", "Ignorar a Palavra", "Isolar-se da igreja"], "verse": ref},
    ]


def _mission(slug, title, ref, intro, question, answer, truth, practice, boss=False):
    study = None if boss else {
        "passageRef": ref,
        "passageText": truth,
        "context": f"Esta missão apresenta {title.lower()} de modo claro, a partir da Bíblia. "
                   "O objetivo não é apenas aprender termos, mas conhecer melhor a Deus e responder a ele com fé.",
        "keyword": "fé",
        "keywordGloss": "Confiança em Deus e em sua Palavra, demonstrada em uma vida de obediência.",
        "focusQuestion": "Como esta verdade bíblica ajuda você a conhecer e seguir a Deus?",
        "reflectionPrompts": [
            "O que este texto revela sobre Deus?",
            "Que ideia ou atitude precisa ser corrigida?",
            "Que passo de fé e obediência você dará hoje?",
        ],
    }
    return {
        "slug": slug, "title": title, "subtitle": ref, "intro": intro, "boss": boss,
        "study": study, "seeds": _seeds(ref, question, answer, truth, practice),
    }


def _lesson(*args):
    return _mission(*args)


def _boss(*args):
    return _mission(*args, boss=True)


def _module(title, icon, missions):
    return {"module": {"title": title, "icon": icon, "section": "Teologia"}, "missions": missions}


TEOLOGIA = {
    "hermeneutica": _module("Hermenêutica", "search", [
        _lesson("hm-01-leitura", "Ler com atenção", "Neemias 8:8", "Interpretar bem começa ouvindo o que o texto realmente diz.", "Como o povo recebeu a leitura da Lei?", "Com explicação do sentido", "A Bíblia deve ser lida com atenção ao seu sentido", "Ler a Bíblia com cuidado"),
        _lesson("hm-02-contexto", "Texto e contexto", "2 Pedro 1:20-21", "Um versículo ganha sentido dentro de seu capítulo, livro e história.", "A profecia da Escritura veio de vontade humana?", "Não", "Deus falou por meio de autores humanos conduzidos pelo Espírito", "Considerar o contexto antes de aplicar"),
        _lesson("hm-03-cristo", "Cristo no centro", "Lucas 24:27", "Toda a Bíblia participa da grande história que encontra seu centro em Cristo.", "Sobre quem Jesus explicou as Escrituras?", "Sobre ele mesmo", "Jesus é o centro da história da redenção", "Ler a Bíblia apontando para Cristo"),
        _boss("hm-boss", "Desafio: Leia com sabedoria", "Neemias 8; Lucas 24", "Revise atenção ao texto, contexto e o lugar de Cristo na leitura bíblica.", "O que devemos buscar ao interpretar a Bíblia?", "O sentido que Deus comunicou", "A boa interpretação ouve a Palavra de Deus", "Praticar uma leitura fiel"),
    ]),
    "linguas-originais": _module("Línguas Originais", "languages", [
        _lesson("lo-01-biblia", "As línguas da Bíblia", "Lucas 23:38", "A Bíblia chegou até nós por meio de idiomas e culturas reais.", "Em quais línguas a inscrição da cruz foi escrita?", "Hebraico, latim e grego", "Deus comunicou sua Palavra na história", "Valorizar boas traduções bíblicas"),
        _lesson("lo-02-traducao", "Traduzir com cuidado", "1 Coríntios 14:9", "Traduções ajudam pessoas a entenderem a Palavra em sua própria língua.", "Por que as palavras devem ser compreensíveis?", "Para que a mensagem seja entendida", "A Palavra de Deus deve ser comunicada com clareza", "Comparar traduções com humildade"),
        _boss("lo-boss", "Desafio: Palavra compreensível", "Lucas 23:38; 1 Coríntios 14", "Revise as línguas bíblicas e o valor de uma comunicação clara.", "Para que serve uma boa tradução?", "Para comunicar fielmente a mensagem", "Deus quer que seu povo compreenda sua Palavra", "Ouvir a Bíblia com atenção"),
    ]),
    "hebraico": _module("Hebraico Bíblico", "book-open", [
        _lesson("hb-01-antigo", "A língua do Antigo Testamento", "Deuteronômio 6:4", "Grande parte do Antigo Testamento foi escrita em hebraico, a língua de Israel.", "Qual confissão começa com 'Ouve, Israel'?", "O Senhor é nosso Deus, o único Senhor", "O Deus da Bíblia é único e digno de amor total", "Amar a Deus de todo o coração"),
        _lesson("hb-02-nomes", "Palavras que revelam", "Êxodo 3:14", "Palavras hebraicas podem iluminar a leitura, mas o sentido vem do texto inteiro.", "Como Deus se revelou a Moisés?", "EU SOU O QUE SOU", "Deus é eterno e fiel às suas promessas", "Confiar no Deus que é fiel"),
        _boss("hb-boss", "Desafio: Ouça, Israel", "Deuteronômio 6; Êxodo 3", "Revise o hebraico como língua bíblica e a revelação do Deus único.", "Quem é o Senhor?", "O único Deus", "Deus se dá a conhecer em sua Palavra", "Adorar somente a Deus"),
    ]),
    "grego": _module("Grego do Novo Testamento", "book-open", [
        _lesson("gr-01-novo", "A língua do Novo Testamento", "João 1:14", "O Novo Testamento foi escrito em grego comum, alcançando muitas pessoas.", "O que o Verbo se tornou?", "Carne", "Jesus, o Filho eterno, veio ao nosso mundo como verdadeiro homem", "Adorar Jesus Cristo"),
        _lesson("gr-02-evangelho", "Boas-novas para todos", "Romanos 1:16", "Conhecer uma palavra grega pode ajudar, mas o evangelho é claro em qualquer boa tradução.", "O evangelho é poder de Deus para quê?", "Para a salvação de todo o que crê", "O evangelho salva pela fé em Cristo", "Não se envergonhar do evangelho"),
        _boss("gr-boss", "Desafio: Boas-novas", "João 1; Romanos 1", "Revise o grego do Novo Testamento e a mensagem do evangelho.", "Quem veio em carne?", "O Verbo, Jesus Cristo", "O evangelho é a boa notícia de Cristo", "Compartilhar a esperança em Jesus"),
    ]),
    "teologia-sistematica": _module("Teologia Sistemática", "layers", [
        _lesson("ts-01-todo", "A Bíblia como um todo", "2 Timóteo 3:16-17", "A teologia sistemática reúne o que a Bíblia ensina sobre temas importantes.", "Toda Escritura é inspirada por quem?", "Por Deus", "Toda a Bíblia é útil para formar o servo de Deus", "Aprender a Bíblia por inteiro"),
        _lesson("ts-02-verdade", "Conhecer para viver", "Tito 1:1", "Doutrina não é só teoria: a verdade de Deus conduz a uma vida piedosa.", "A verdade conduz a quê?", "À piedade", "Conhecer a verdade deve transformar a vida", "Unir conhecimento e obediência"),
        _lesson("ts-03-igreja", "Uma fé compartilhada", "Efésios 4:4-6", "A igreja confessa a fé recebida e cresce unida em torno do Deus triúno.", "Quantos corpos e Espíritos há?", "Um", "A fé cristã une a igreja em um só Senhor", "Preservar a unidade da igreja"),
        _boss("ts-boss", "Desafio: Verdade que transforma", "2 Timóteo 3; Efésios 4", "Revise a unidade da Escritura, a doutrina e a vida piedosa.", "Para que a Escritura equipa o cristão?", "Para toda boa obra", "A verdade de Deus forma uma vida fiel", "Viver o que a Bíblia ensina"),
    ]),
    "doutrina-de-deus": _module("Doutrina de Deus", "sun", [
        _lesson("dd-01-criador", "Deus, o Criador", "Gênesis 1:1", "Deus criou todas as coisas e não depende de sua criação.", "Quem criou os céus e a terra?", "Deus", "Deus é o Criador de tudo o que existe", "Adorar o Criador"),
        _lesson("dd-02-santo", "Deus é santo", "Isaías 6:3", "A santidade de Deus mostra sua pureza perfeita e sua grandeza.", "Como os serafins chamam o Senhor?", "Santo, santo, santo", "Deus é perfeitamente santo", "Responder a Deus com reverência"),
        _lesson("dd-03-trino", "Um Deus em três pessoas", "Mateus 28:19", "O único Deus existe eternamente como Pai, Filho e Espírito Santo.", "Em qual nome somos batizados?", "Do Pai, do Filho e do Espírito Santo", "Deus é um em essência e triúno em pessoas", "Adorar o Deus triúno"),
        _boss("dd-boss", "Desafio: Conheça o Criador", "Gênesis 1; Isaías 6; Mateus 28", "Revise Deus como Criador, Santo e Triúno.", "Quantos deuses há?", "Um só Deus", "O Deus único é digno de toda adoração", "Viver para a glória de Deus"),
    ]),
    "antropologia": _module("Antropologia Bíblica", "user", [
        _lesson("an-01-imagem", "Feitos à imagem de Deus", "Gênesis 1:26-27", "Todo ser humano possui dignidade porque foi criado à imagem de Deus.", "À imagem de quem a humanidade foi criada?", "De Deus", "Cada pessoa tem valor dado pelo Criador", "Tratar todos com dignidade"),
        _lesson("an-02-queda", "O pecado entrou no mundo", "Romanos 3:23", "O pecado rompeu nossa comunhão com Deus e afeta toda a humanidade.", "Quem pecou e carece da glória de Deus?", "Todos", "Todos precisam da graça salvadora de Deus", "Confessar a necessidade de perdão"),
        _lesson("an-03-nova", "Nova humanidade em Cristo", "Efésios 2:10", "Em Cristo, Deus recria seu povo para viver em boas obras.", "Para que fomos criados em Cristo?", "Para boas obras", "A graça de Deus gera uma nova vida", "Servir a Deus com gratidão"),
        _boss("an-boss", "Desafio: Criados e restaurados", "Gênesis 1; Romanos 3; Efésios 2", "Revise dignidade humana, pecado e nova vida em Cristo.", "Por que toda pessoa tem dignidade?", "Porque foi criada à imagem de Deus", "Cristo restaura pecadores pela graça", "Amar o próximo com respeito"),
    ]),
    "soteriologia": _module("Salvação", "heart", [
        _lesson("so-01-graca", "Salvos pela graça", "Efésios 2:8-9", "A salvação é presente de Deus, não conquista do nosso esforço.", "Como somos salvos?", "Pela graça, mediante a fé", "A salvação é dom de Deus em Cristo", "Descansar na graça de Deus"),
        _lesson("so-02-cruz", "Cristo morreu por nós", "Romanos 5:8", "Jesus tomou sobre si o pecado para reconciliar pecadores com Deus.", "Quando Cristo morreu por nós?", "Quando ainda éramos pecadores", "Deus demonstrou amor na morte de Cristo", "Confiar na obra de Jesus"),
        _lesson("so-03-nascimento", "Nascidos de novo", "João 3:3", "O Espírito dá nova vida a quem crê em Jesus.", "O que é necessário para ver o reino de Deus?", "Nascer de novo", "A salvação inclui nova vida dada por Deus", "Pedir a Deus um coração renovado"),
        _boss("so-boss", "Desafio: Graça salvadora", "Efésios 2; Romanos 5; João 3", "Revise graça, cruz e novo nascimento.", "Quem salva o pecador?", "Deus, por meio de Jesus Cristo", "A salvação vem da graça de Deus", "Viver agradecido pela salvação"),
    ]),
    "eclesiologia": _module("Igreja", "users", [
        _lesson("ec-01-corpo", "Um corpo em Cristo", "1 Coríntios 12:12-13", "A igreja é o povo unido a Cristo e uns aos outros pelo Espírito.", "Em quantos corpos fomos batizados?", "Em um só corpo", "A igreja é um corpo com muitos membros", "Servir com os dons recebidos"),
        _lesson("ec-02-reuniao", "Comunhão e ensino", "Atos 2:42", "A igreja persevera na Palavra, comunhão, ceia e oração.", "Em que os primeiros cristãos perseveravam?", "No ensino, comunhão, partir do pão e orações", "A vida cristã floresce na comunhão da igreja", "Participar fielmente da igreja"),
        _lesson("ec-03-missao", "Enviada ao mundo", "Mateus 28:19-20", "Jesus envia sua igreja para fazer discípulos e ensinar sua Palavra.", "O que Jesus manda seus discípulos fazerem?", "Fazer discípulos", "A igreja existe para testemunhar de Cristo", "Compartilhar o evangelho"),
        _boss("ec-boss", "Desafio: Povo de Cristo", "Atos 2; 1 Coríntios 12; Mateus 28", "Revise corpo, comunhão e missão da igreja.", "Quem é a cabeça da igreja?", "Cristo", "A igreja pertence a Cristo e serve em sua missão", "Edificar a comunidade"),
    ]),
    "escatologia": _module("Esperança Futura", "sunrise", [
        _lesson("es-01-volta", "Jesus voltará", "Atos 1:11", "A volta visível de Jesus é uma promessa que sustenta a igreja.", "Como Jesus voltará?", "Do mesmo modo como foi visto subir", "Jesus voltará conforme prometeu", "Viver com esperança e fidelidade"),
        _lesson("es-02-juizo", "Justiça diante de Deus", "2 Coríntios 5:10", "Deus julgará com justiça; essa verdade chama à responsabilidade e esperança.", "Diante de quem todos compareceremos?", "Diante do tribunal de Cristo", "Deus é justo e conhece todas as coisas", "Viver de modo responsável"),
        _lesson("es-03-novo", "Novas todas as coisas", "Apocalipse 21:3-4", "Deus promete uma nova criação sem morte, luto ou dor para seu povo.", "O que Deus enxugará?", "Toda lágrima", "Deus cumprirá sua promessa de restaurar todas as coisas", "Consolar-se na esperança futura"),
        _boss("es-boss", "Desafio: Esperança firme", "Atos 1; Apocalipse 21", "Revise a volta de Cristo, a justiça de Deus e a nova criação.", "Quem fará novas todas as coisas?", "Deus", "A esperança cristã está na vitória final de Cristo", "Esperar Cristo com alegria"),
    ]),
    "teologia-biblica": _module("Teologia Bíblica", "map", [
        _lesson("tb-01-historia", "A grande história", "Lucas 24:44", "A Bíblia conta uma história unificada: criação, queda, redenção e restauração.", "Sobre quem as Escrituras dão testemunho?", "Sobre Cristo", "A história bíblica encontra seu centro em Jesus", "Ler a Bíblia como uma história unida"),
        _lesson("tb-02-promessa", "Promessa e cumprimento", "Gálatas 3:16", "As promessas de Deus apontam para Cristo e se cumprem nele.", "A quem a promessa foi feita, em sentido final?", "A Cristo", "Jesus cumpre as promessas de Deus", "Confiar nas promessas de Deus"),
        _lesson("tb-03-reino", "O reino de Deus", "Marcos 1:15", "Em Jesus, o reino de Deus se aproximou e chama pessoas ao arrependimento e à fé.", "O que Jesus anunciou como próximo?", "O reino de Deus", "Jesus reina e chama pessoas a crer", "Arrepender-se e crer no evangelho"),
        _boss("tb-boss", "Desafio: Uma história, um Salvador", "Lucas 24; Gálatas 3; Marcos 1", "Revise a história bíblica, suas promessas e o reino de Deus.", "Quem cumpre as promessas bíblicas?", "Jesus Cristo", "Toda a Escritura aponta para a obra de Cristo", "Confiar no Rei Jesus"),
    ]),
    "cristologia": _module("Cristologia", "crown", [
        _lesson("cr-01-deus", "Jesus é plenamente Deus", "João 1:1", "O Filho eterno é Deus e merece a mesma adoração dada ao Pai.", "Quem era o Verbo?", "Deus", "Jesus é o Filho eterno e verdadeiro Deus", "Adorar Jesus Cristo"),
        _lesson("cr-02-homem", "Jesus é plenamente homem", "Hebreus 2:17", "Jesus se fez semelhante a nós, sem pecado, para nos socorrer e representar.", "Com quem Jesus se tornou semelhante?", "Com seus irmãos", "Jesus é verdadeiro homem e nosso sumo sacerdote compassivo", "Aproximar-se de Jesus com confiança"),
        _lesson("cr-03-senhor", "Morte, ressurreição e senhorio", "Filipenses 2:9-11", "O Jesus crucificado ressuscitou e foi exaltado como Senhor de todos.", "Que nome se dobra diante de Jesus?", "Todo joelho", "Jesus Cristo é Senhor para a glória de Deus Pai", "Confessar Jesus como Senhor"),
        _boss("cr-boss", "Desafio: Quem é Jesus?", "João 1; Hebreus 2; Filipenses 2", "Revise a divindade, humanidade, morte e exaltação de Cristo.", "Quem é Jesus?", "Verdadeiro Deus e verdadeiro homem", "Jesus é o Salvador e Senhor", "Seguir Jesus com fé"),
    ]),
    "pneumatologia": _module("Espírito Santo", "wind", [
        _lesson("pn-01-pessoa", "O Espírito é Deus", "Atos 5:3-4", "O Espírito Santo não é uma força impessoal; ele é Deus e age pessoalmente.", "Mentir ao Espírito Santo é mentir a quem?", "A Deus", "O Espírito Santo é plenamente Deus", "Honrar a presença do Espírito"),
        _lesson("pn-02-vida", "Nova vida pelo Espírito", "Romanos 8:9-11", "O Espírito habita em todo cristão e dá vida, esperança e poder para obedecer.", "Quem habita no cristão?", "O Espírito de Deus", "O Espírito une o cristão a Cristo", "Andar guiado pelo Espírito"),
        _lesson("pn-03-fruto", "Fruto e dons", "Gálatas 5:22-23", "O Espírito forma o caráter de Cristo e distribui dons para edificar a igreja.", "Qual fruto aparece primeiro na lista?", "Amor", "O Espírito produz fruto de santidade", "Servir a igreja em amor"),
        _boss("pn-boss", "Desafio: Vida no Espírito", "Atos 5; Romanos 8; Gálatas 5", "Revise a divindade, habitação e obra transformadora do Espírito.", "O que o Espírito produz no cristão?", "Vida e fruto santo", "O Espírito glorifica Cristo e transforma seu povo", "Depender do Espírito em oração"),
    ]),
}


def _validate():
    """Garante a estrutura solicitada antes de o arquivo ser usado no build."""
    language_modules = {"linguas-originais", "hebraico", "grego"}
    expected = {
        "hermeneutica", "linguas-originais", "hebraico", "grego",
        "teologia-sistematica", "doutrina-de-deus", "antropologia",
        "soteriologia", "eclesiologia", "escatologia", "teologia-biblica",
        "cristologia", "pneumatologia",
    }
    assert set(TEOLOGIA) == expected
    for slug, trail in TEOLOGIA.items():
        missions = trail["missions"]
        assert len(missions) == (3 if slug in language_modules else 4)
        assert missions[-1]["boss"] is True
        assert all(len(mission["seeds"]) == 5 for mission in missions)
        assert all(mission["study"] is not None for mission in missions[:-1])
        assert missions[-1]["study"] is None


_validate()
