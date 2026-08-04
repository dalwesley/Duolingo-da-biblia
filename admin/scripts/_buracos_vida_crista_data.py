"""Dados das trilhas de vida cristã, missão e história da igreja."""


def _seeds(ref, question, answer, truth, practice):
    """Cria as cinco sementes de revisão de cada missão."""
    return [
        {
            "q_s": question,
            "q_c": "Que verdade bíblica esta resposta destaca?",
            "q_p": "Como essa verdade pode orientar sua semana?",
            "answer": answer,
            "wrong": ["O mérito humano", "A aprovação das pessoas", "A força de vontade sem Deus"],
            "verse": ref,
        },
        {
            "q_s": "Qual é a referência principal desta missão?",
            "q_c": "Por que esse texto é importante?",
            "q_p": "Como você pode voltar a ele em oração?",
            "answer": ref,
            "wrong": ["Gênesis 1-3", "Salmos 23", "Apocalipse 21"],
            "verse": ref,
        },
        {
            "q_s": "Quem está no centro da vida cristã?",
            "q_c": "Como ele transforma seu povo?",
            "q_p": "Que resposta de fé você dará hoje?",
            "answer": "Jesus Cristo",
            "wrong": ["O desempenho religioso", "O sucesso pessoal", "A opinião da maioria"],
            "verse": ref,
        },
        {
            "q_s": "Qual verdade resume esta missão?",
            "q_c": "O que ela corrige em nosso coração?",
            "q_p": "Como ela aparece em uma atitude concreta?",
            "answer": truth,
            "wrong": ["Deus é indiferente", "O pecado não importa", "A igreja é desnecessária"],
            "verse": ref,
        },
        {
            "q_s": "Qual resposta é coerente com a graça de Deus?",
            "q_c": "Por que ela não compra a salvação?",
            "q_p": "Que passo você dará agora?",
            "answer": practice,
            "wrong": ["Confiar em si mesmo", "Evitar a comunhão", "Ignorar a Palavra"],
            "verse": ref,
        },
    ]


def _mission(slug, title, ref, intro, question, answer, truth, practice, boss=False):
    study = None
    if not boss:
        study = {
            "passageRef": ref,
            "passageText": f"“{truth}”",
            "context": (
                "Este texto chama a igreja a viver a fé recebida de Deus. "
                "A obra de Cristo está no centro, e sua graça forma discípulos "
                "que respondem com humildade, amor e obediência."
            ),
            "keyword": "discípulo",
            "keywordGloss": "Pessoa que segue Jesus, aprende dele e obedece à sua Palavra.",
            "focusQuestion": "Como o evangelho molda sua resposta a este ensino?",
            "reflectionPrompts": [
                "O que este texto revela sobre Deus?",
                "Que atitude precisa ser corrigida?",
                "Que passo de obediência você dará hoje?",
            ],
        }
    return {
        "slug": slug,
        "title": title,
        "subtitle": ref,
        "intro": intro,
        "boss": boss,
        "study": study,
        "seeds": _seeds(ref, question, answer, truth, practice),
    }


def _lesson(slug, title, ref, intro, question, answer, truth, practice):
    return _mission(slug, title, ref, intro, question, answer, truth, practice)


def _boss(slug, title, ref, intro, question, answer, truth, practice):
    return _mission(slug, title, ref, intro, question, answer, truth, practice, boss=True)


VIDA_CRISTA = {
    "vida-crista": {
        "module": {"title": "Vida Cristã", "icon": "heart", "section": "Formação Cristã"},
        "missions": [
            _lesson("vd-01-seguir", "Seguir Jesus", "Marcos 8:34-35", "Jesus chama seus discípulos a segui-lo acima da autopreservação e dos próprios interesses.", "O que Jesus manda fazer para segui-lo?", "Negar-se a si mesmo", "Seguir Jesus significa entregar a vida ao seu senhorio", "Tomar a cruz e seguir Cristo"),
            _lesson("vd-02-negacao", "Negar a si mesmo", "Lucas 9:23", "A negação de si não é desprezo pela vida, mas rendição diária do ego à vontade de Cristo.", "Com que frequência o discípulo toma sua cruz?", "Diariamente", "O discipulado é uma resposta diária à graça de Jesus", "Submeter escolhas a Cristo"),
            _lesson("vd-03-frutos", "Frutos que permanecem", "João 15:4-8", "Quem permanece em Cristo recebe vida dele e produz fruto para a glória do Pai.", "Quem produz muito fruto?", "Quem permanece em Cristo", "Fruto verdadeiro nasce da união com Cristo", "Permanecer na Palavra e em oração"),
            _boss("vd-04-desafio", "Desafio: Discípulo fiel", "Marcos 8; Lucas 9; João 15", "Revise o chamado para seguir Jesus, render o ego e frutificar nele.", "Quem é o centro do discipulado?", "Jesus Cristo", "O discípulo permanece em Cristo e o segue", "Viver para a glória de Deus"),
        ],
    },
    "familia": {
        "module": {"title": "Família", "icon": "home", "section": "Formação Cristã"},
        "missions": [
            _lesson("fm-01-alianca", "Casamento e aliança", "Efésios 5:21-33", "O casamento cristão aponta para Cristo e a igreja, sendo marcado por amor sacrificial e respeito.", "Como Cristo amou a igreja?", "Entregando-se por ela", "O amor conjugal aprende com o amor sacrificial de Cristo", "Servir o cônjuge com amor"),
            _lesson("fm-02-pais-filhos", "Pais e filhos", "Efésios 6:1-4", "Filhos são chamados a honrar seus pais, e pais a criar os filhos na disciplina e instrução do Senhor.", "Como os pais devem criar os filhos?", "Na disciplina e instrução do Senhor", "A autoridade no lar deve refletir o cuidado de Deus", "Praticar honra e paciência no lar"),
            _lesson("fm-03-comunidade", "Uma família em Cristo", "Gálatas 6:2,10", "A igreja é uma comunidade que leva os fardos uns dos outros e faz o bem, especialmente aos da fé.", "O que devemos levar uns dos outros?", "Os fardos", "Em Cristo, a família da fé cuida uns dos outros", "Servir alguém em necessidade"),
            _boss("fm-04-desafio", "Desafio: Lar que serve", "Efésios 5-6; Gálatas 6", "Revise aliança, honra, cuidado e serviço na família e na igreja.", "Que modelo orienta o amor cristão?", "O amor de Cristo pela igreja", "A graça de Cristo transforma os relacionamentos", "Promover paz e cuidado no lar"),
        ],
    },
    "missao": {
        "module": {"title": "Missão", "icon": "compass", "section": "Formação Cristã"},
        "missions": [
            _lesson("ms-01-comissao", "A grande comissão", "Mateus 28:18-20", "Jesus, que tem toda autoridade, envia sua igreja para fazer discípulos de todas as nações.", "Que missão Jesus deu à igreja?", "Fazer discípulos de todas as nações", "A missão nasce da autoridade e presença de Jesus", "Compartilhar o evangelho com fidelidade"),
            _lesson("ms-02-testemunho", "Testemunhas de Cristo", "Atos 1:8", "O Espírito Santo capacita o povo de Deus a testemunhar de Jesus onde está e até os confins da terra.", "Quem capacita as testemunhas de Jesus?", "O Espírito Santo", "O testemunho cristão depende do poder do Espírito", "Orar por coragem para testemunhar"),
            _lesson("ms-03-discipular", "Discipular as nações", "2 Timóteo 2:2", "O evangelho é transmitido a pessoas fiéis que também poderão ensinar outros.", "A quem Timóteo deveria confiar o ensino?", "A pessoas fiéis e aptas para ensinar", "Discípulos fazem outros discípulos pela Palavra", "Investir no crescimento de outra pessoa"),
            _boss("ms-04-desafio", "Desafio: Enviados por Jesus", "Mateus 28; Atos 1; 2Timóteo 2", "Revise a comissão, o poder do Espírito e a multiplicação de discípulos.", "Quem enviou a igreja em missão?", "Jesus Cristo", "A igreja anuncia e ensina o evangelho de Cristo", "Participar da missão com oração e serviço"),
        ],
    },
    "oracao": {
        "module": {"title": "Oração", "icon": "message-circle", "section": "Formação Cristã"},
        "missions": [
            _lesson("or-01-pai-nosso", "A prática do Pai Nosso", "Mateus 6:9-13", "Jesus ensina seus discípulos a orar com reverência, dependência, perdão e confiança no Pai.", "Como Jesus nos ensina a chamar Deus na oração?", "Pai nosso", "A oração começa com Deus, seu nome e seu reino", "Orar buscando a vontade do Pai"),
            _lesson("or-02-persistencia", "Persistir em oração", "Lucas 18:1-8", "Jesus encoraja seus discípulos a orar sempre e não desanimar, confiando na justiça de Deus.", "Por que Jesus contou a parábola da viúva?", "Para que orassem sempre e não desanimassem", "A persistência em oração expressa confiança em Deus", "Levar uma necessidade a Deus com perseverança"),
            _lesson("or-03-espirito", "O Espírito nos ajuda", "Romanos 8:26-27", "Em nossa fraqueza, o Espírito Santo nos ajuda e intercede segundo a vontade de Deus.", "Quem nos ajuda em nossa fraqueza?", "O Espírito Santo", "Deus acolhe a oração de seus filhos em sua fraqueza", "Orar com dependência do Espírito"),
            _boss("or-04-desafio", "Desafio: Vida de oração", "Mateus 6; Lucas 18; Romanos 8", "Revise a oração ensinada por Jesus, a perseverança e o auxílio do Espírito.", "A quem o cristão ora?", "Ao Pai, por meio de Jesus", "A oração depende da graça de Deus", "Cultivar uma rotina de oração"),
        ],
    },
    "jejum": {
        "module": {"title": "Jejum", "icon": "utensils", "section": "Formação Cristã"},
        "missions": [
            _lesson("jj-01-desejo", "Disciplinar o desejo", "Mateus 4:1-4", "Jesus enfrenta a tentação confiando na Palavra de Deus; o pão não é a fonte final de vida.", "De que vive o ser humano, além do pão?", "De toda palavra que procede de Deus", "A Palavra de Deus orienta e sustenta o discípulo", "Buscar a Deus acima de desejos imediatos"),
            _lesson("jj-02-secreto", "Jejuar diante do Pai", "Mateus 6:16-18", "Jesus alerta contra o jejum para ser visto e chama seus discípulos a buscar o Pai em secreto.", "Quem vê o que é feito em secreto?", "O Pai", "O jejum é devoção a Deus, não exibição religiosa", "Jejuar com humildade diante de Deus"),
            _lesson("jj-03-oracao", "Jejum com oração", "Atos 13:2-3", "A igreja em Antioquia servia ao Senhor e jejuava quando o Espírito separou Barnabé e Saulo para a obra.", "O que a igreja fazia antes de enviar missionários?", "Jejuava e orava", "Jejum e oração podem acompanhar a busca da direção de Deus", "Orar pela missão da igreja"),
            _boss("jj-04-desafio", "Desafio: Desejo rendido", "Mateus 4; Mateus 6; Atos 13", "Revise o jejum como disciplina de dependência, sinceridade e oração.", "Para quem o jejum deve ser feito?", "Para Deus, que vê em secreto", "Jejuar não compra o favor de Deus", "Buscar a Deus com humildade"),
        ],
    },
    "historia-igreja": {
        "module": {"title": "História da Igreja", "icon": "landmark", "section": "História Cristã"},
        "missions": [
            _lesson("hi-01-eras", "Panorama das eras", "Mateus 16:18", "A história da igreja testemunha a fidelidade de Cristo, que promete edificar sua igreja através das eras.", "Quem prometeu edificar a igreja?", "Jesus Cristo", "Cristo sustenta sua igreja ao longo da história", "Valorizar a igreja de Cristo"),
            _lesson("hi-02-credos", "Concílios e credos", "Judas 1:3", "Credos históricos procuraram resumir a fé bíblica diante de erros, confessando o Deus triúno e Jesus Cristo verdadeiro Deus e verdadeiro homem.", "Pelo que Judas manda batalhar?", "Pela fé entregue aos santos", "A igreja deve guardar a verdade apostólica", "Estudar a fé cristã com discernimento"),
            _boss("hi-03-desafio", "Desafio: Memória fiel", "Mateus 16; Judas 1", "Revise a continuidade da igreja, a defesa da fé e o testemunho de gerações cristãs.", "Quem guarda sua igreja?", "Jesus Cristo", "A fé cristã está enraizada no evangelho apostólico", "Aprender com testemunhas fiéis"),
        ],
    },
    "igreja-primitiva": {
        "module": {"title": "Igreja Primitiva", "icon": "users", "section": "História Cristã"},
        "missions": [
            _lesson("ip-01-vida-comum", "Vida comum em Atos", "Atos 2:42-47", "A primeira igreja perseverava na doutrina dos apóstolos, na comunhão, no partir do pão e nas orações.", "Em que a igreja primitiva perseverava?", "Na doutrina dos apóstolos, comunhão, pão e orações", "A igreja cresce ao redor da Palavra e da comunhão", "Participar fielmente da vida da igreja"),
            _lesson("ip-02-perseguicao", "Fé em meio à perseguição", "Atos 4:29-31", "Diante das ameaças, a igreja orou por ousadia para anunciar a Palavra, e Deus a fortaleceu.", "O que a igreja pediu diante das ameaças?", "Ousadia para anunciar a Palavra", "A perseguição não impede o testemunho sustentado por Deus", "Orar por coragem e fidelidade"),
            _lesson("ip-03-expansao", "O evangelho se espalha", "Atos 8:4; 11:19-21", "Os cristãos dispersos pela perseguição anunciaram a Palavra, e o evangelho alcançou novos povos.", "O que os dispersos faziam por onde passavam?", "Anunciavam a Palavra", "Deus usa sua igreja para levar o evangelho adiante", "Levar Cristo a alguém próximo"),
            _boss("ip-04-desafio", "Desafio: Igreja em movimento", "Atos 2; 4; 8; 11", "Revise comunhão, coragem e expansão missionária da igreja primitiva.", "Qual livro registra essa expansão?", "Atos dos Apóstolos", "A igreja é chamada a testemunhar de Cristo", "Servir e anunciar com a igreja"),
        ],
    },
    "reforma": {
        "module": {"title": "Reforma", "icon": "book-open", "section": "História Cristã"},
        "missions": [
            _lesson("rf-01-escritura", "Sola Scriptura", "2 Timóteo 3:16-17", "A Reforma reafirmou que a Escritura é inspirada por Deus e suficiente para ensinar, corrigir e equipar o servo de Deus.", "De onde vem toda a Escritura?", "De Deus", "A Bíblia é a autoridade final para a fé e a prática", "Ler e obedecer à Escritura"),
            _lesson("rf-02-fe-graca", "Sola fide, sola gratia", "Efésios 2:8-10", "Somos salvos pela graça, mediante a fé; a salvação é dom de Deus e produz boas obras como fruto.", "Como somos salvos?", "Pela graça, mediante a fé", "A salvação não é conquistada por obras meritórias", "Descansar em Cristo e servir por gratidão"),
            _lesson("rf-03-legado", "Volta ao evangelho", "Romanos 1:16-17", "O legado da Reforma aponta para o evangelho como poder de Deus para a salvação de todo aquele que crê.", "O que é poder de Deus para salvação?", "O evangelho", "O justo vive pela fé em Cristo", "Permanecer firme no evangelho"),
            _boss("rf-04-desafio", "Desafio: Graça que permanece", "2Timóteo 3; Efésios 2; Romanos 1", "Revise a autoridade da Escritura, a salvação pela graça e a centralidade do evangelho.", "Em que o cristão deve confiar para ser salvo?", "Em Cristo, pela graça mediante a fé", "Toda a glória pertence a Deus", "Viver para a glória de Deus"),
        ],
    },
}
