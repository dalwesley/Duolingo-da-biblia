"""Dados das trilhas das cartas de Paulo."""


def _seed_set(ref, fact_q, fact_a, concept, practice):
    """Gera cinco perguntas claras a partir do foco da missão."""
    return [
        {
            "q_s": fact_q,
            "q_c": "Qual verdade o texto enfatiza?",
            "q_p": "Como essa verdade orienta a vida cristã?",
            "answer": fact_a,
            "wrong": ["A salvação vem do mérito humano", "Deus é indiferente ao pecado", "A fé dispensa obediência"],
            "verse": ref,
        },
        {
            "q_s": "Qual é a referência principal desta missão?",
            "q_c": "Como o ensino de Paulo deve ser entendido?",
            "q_p": "Que atitude prática ele pede dos cristãos?",
            "answer": concept,
            "wrong": ["Uma opinião sem autoridade bíblica", "Uma regra para conquistar aceitação", "Um convite ao orgulho espiritual"],
            "verse": ref,
        },
        {
            "q_s": "Quem é o centro da esperança apresentada no texto?",
            "q_c": "Que resposta o evangelho produz?",
            "q_p": "Qual escolha reflete essa resposta hoje?",
            "answer": "Jesus Cristo",
            "wrong": ["O desempenho religioso", "A aprovação das pessoas", "A força de vontade isolada"],
            "verse": ref,
        },
        {
            "q_s": "O ensino desta missão pertence a qual faixa de texto?",
            "q_c": "Por que essa mensagem é importante para a igreja?",
            "q_p": "Qual é uma aplicação fiel para esta semana?",
            "answer": ref,
            "wrong": ["Gênesis 1-3", "Salmos 23-24", "Apocalipse 21-22"],
            "verse": ref,
        },
        {
            "q_s": "Segundo a missão, qual é uma resposta coerente à graça de Deus?",
            "q_c": "Qual conclusão resume o ensino estudado?",
            "q_p": "Como você pode colocá-lo em prática?",
            "answer": practice,
            "wrong": ["Confiar em si mesmo acima de tudo", "Evitar a comunhão da igreja", "Ignorar a Palavra de Deus"],
            "verse": ref,
        },
    ]


def _mission(slug, title, subtitle, intro, fact_q, fact_a, concept, practice, boss=False):
    study = None
    if not boss:
        study = {
            "passageRef": subtitle,
            "passageText": f"“{concept}”",
            "context": (
                f"Paulo instrui a igreja em {subtitle} com o evangelho no centro. "
                "O texto une a obra de Cristo à transformação concreta do discípulo. "
                "Ele chama os cristãos a responderem com fé, humildade e obediência."
            ),
            "keyword": "graça",
            "keywordGloss": "Favor imerecido de Deus que salva e transforma.",
            "focusQuestion": "Como o evangelho molda a resposta do cristão a este texto?",
            "reflectionPrompts": [
                "O que este texto revela sobre Deus?",
                "Que crença ou atitude precisa ser corrigida?",
                "Que passo de obediência você dará hoje?",
            ],
        }
    return {
        "slug": slug,
        "title": title,
        "subtitle": subtitle,
        "intro": intro,
        "boss": boss,
        "study": study,
        "seeds": _seed_set(subtitle, fact_q, fact_a, concept, practice),
    }


def _lesson(slug, title, ref, intro, fact_q, fact_a, concept, practice):
    return _mission(slug, title, ref, intro, fact_q, fact_a, concept, practice)


def _boss(slug, title, ref, intro, fact_q, fact_a, concept, practice):
    return _mission(slug, title, ref, intro, fact_q, fact_a, concept, practice, boss=True)


PAULO = {
    "cartas-paulo": {
        "module": {"title": "Cartas de Paulo", "icon": "mail", "section": "Novo Testamento"},
        "missions": [
            _lesson("cp-01-apostolo", "O apóstolo e suas cartas", "Atos 9; 13-28", "Paulo foi alcançado por Cristo e enviado para anunciar o evangelho entre os povos.", "Quem encontrou Paulo no caminho de Damasco?", "Jesus Cristo", "A missão de Paulo nasceu do encontro com Cristo ressuscitado", "Anunciar Cristo com fidelidade"),
            _lesson("cp-02-evangelho", "Um evangelho para as igrejas", "Gálatas 1:6-9; 1Co 15:1-4", "As cartas de Paulo defendem e aplicam o único evangelho de Cristo às igrejas.", "O que Paulo recebeu e também transmitiu?", "O evangelho", "O evangelho anuncia a morte e ressurreição de Cristo", "Permanecer firme no evangelho"),
            _boss("cp-03-desafio", "Desafio: Mensageiro fiel", "Atos 9; Gálatas 1; 1Coríntios 15", "Revise a conversão, a missão e a mensagem que marcaram o ministério de Paulo.", "Quem comissionou Paulo?", "Jesus Cristo", "Paulo serviu como apóstolo pela graça de Deus", "Servir à igreja com humildade"),
        ],
    },
    "romanos": {
        "module": {"title": "Romanos", "icon": "book-open", "section": "Cartas de Paulo"},
        "missions": [
            _lesson("rm-01-pecado", "Pecado e justiça de Deus", "Romanos 1:16-3:20", "Paulo mostra que judeus e gentios estão sob o pecado e precisam do evangelho.", "Quem pecou, segundo Paulo?", "Todos", "Ninguém é justificado pelas obras da lei", "Reconhecer a necessidade da graça"),
            _lesson("rm-02-justificacao", "Justificados pela fé", "Romanos 3:21-5:21", "Deus declara justo o pecador que confia em Cristo, como Abraão creu em Deus.", "Por qual meio somos justificados?", "Pela fé", "A justificação é dom de Deus fundamentado em Cristo", "Confiar em Cristo e não no mérito"),
            _lesson("rm-03-vida-espirito", "Nova vida no Espírito", "Romanos 6-8", "Unidos a Cristo, os cristãos morrem para o domínio do pecado e vivem pelo Espírito.", "Quem habita no cristão?", "O Espírito de Deus", "Não há condenação para os que estão em Cristo Jesus", "Andar segundo o Espírito"),
            _lesson("rm-04-israel", "Israel e a fidelidade de Deus", "Romanos 9-11", "Paulo contempla a soberania, a misericórdia e a fidelidade de Deus em seu plano redentor.", "O que Paulo chama de irrevogáveis?", "Os dons e a vocação de Deus", "Deus permanece fiel às suas promessas", "Responder com humildade e adoração"),
            _lesson("rm-05-culto", "O culto da vida inteira", "Romanos 12-16", "A graça recebida se torna serviço, amor, santidade e vida comunitária.", "Como Paulo chama a entrega do corpo a Deus?", "Culto racional", "A fé verdadeira se expressa em amor e serviço", "Oferecer a vida a Deus"),
            _boss("rm-06-desafio", "Desafio: O evangelho completo", "Romanos 1-16", "Revise pecado, justificação, vida no Espírito, fidelidade divina e serviço cristão.", "Qual carta explica amplamente o evangelho?", "Romanos", "O evangelho salva e transforma pela graça de Deus", "Viver para a glória de Deus"),
        ],
    },
    "corintios": {
        "module": {"title": "Coríntios", "icon": "users", "section": "Cartas de Paulo"},
        "missions": [
            _lesson("co-01-cruz", "Unidade e a cruz", "1Coríntios 1-4", "Paulo confronta divisões e chama a igreja a se gloriar somente no Senhor.", "Qual mensagem é poder de Deus?", "A palavra da cruz", "Cristo, e não líderes humanos, é o centro da igreja", "Buscar unidade em Cristo"),
            _lesson("co-02-amor", "Corpo, dons e amor", "1Coríntios 12-14", "Os dons servem ao corpo, mas o caminho excelente é o amor.", "Qual é o caminho sobremodo excelente?", "O amor", "Cada dom deve edificar a igreja em amor", "Servir para edificar os outros"),
            _lesson("co-03-ressurreicao", "A ressurreição de Cristo", "1Coríntios 15", "A ressurreição corporal de Jesus é central para a fé e para a esperança cristã.", "Quem ressuscitou dos mortos?", "Jesus Cristo", "Se Cristo não ressuscitou, a fé seria vã", "Viver com esperança na ressurreição"),
            _lesson("co-04-consolacao", "Consolação em meio à fraqueza", "2Coríntios 1-5", "Deus consola seu povo e manifesta o poder de Cristo em vasos de barro.", "Quem nos consola em toda tribulação?", "Deus", "O poder de Deus se aperfeiçoa na fraqueza", "Consolar outros com a graça recebida"),
            _boss("co-05-desafio", "Desafio: Igreja edificada", "1Coríntios 1-15; 2Coríntios 1-5", "Revise cruz, unidade, dons, amor, ressurreição e consolo.", "Qual virtude governa o uso dos dons?", "O amor", "A igreja é edificada quando Cristo é o centro", "Edificar a comunidade em amor"),
        ],
    },
    "galatas": {
        "module": {"title": "Gálatas", "icon": "shield", "section": "Cartas de Paulo"},
        "missions": [
            _lesson("gl-01-outro-evangelho", "Nenhum outro evangelho", "Gálatas 1-2", "Paulo rejeita qualquer mensagem que acrescente obras à aceitação diante de Deus.", "O que Paulo condena?", "Outro evangelho", "O evangelho recebido vem de Deus e tem Cristo no centro", "Guardar a verdade do evangelho"),
            _lesson("gl-02-fe", "Fé e promessa", "Gálatas 3-4", "A promessa dada a Abraão se cumpre em Cristo e é recebida pela fé.", "Como Abraão foi considerado justo?", "Pela fé", "Os filhos de Deus recebem adoção em Cristo", "Descansar na promessa de Deus"),
            _lesson("gl-03-espirito", "Liberdade pelo Espírito", "Gálatas 5-6", "A liberdade cristã não serve à carne, mas produz amor e fruto pelo Espírito.", "Qual fruto começa a lista de Paulo?", "Amor", "O Espírito produz caráter semelhante ao de Cristo", "Andar no Espírito"),
            _boss("gl-04-desafio", "Desafio: Livres para servir", "Gálatas 1-6", "Revise o evangelho da graça, a fé e a liberdade que serve em amor.", "Para que Cristo nos libertou?", "Para a liberdade", "A salvação é pela graça mediante a fé", "Servir uns aos outros em amor"),
        ],
    },
    "efesios": {
        "module": {"title": "Efésios", "icon": "home", "section": "Cartas de Paulo"},
        "missions": [
            _lesson("ef-01-bencaos", "Bênçãos em Cristo", "Efésios 1", "Deus nos abençoou em Cristo e nos selou com o Espírito Santo.", "Em quem estão as bênçãos espirituais?", "Em Cristo", "A salvação começa na graça e no propósito de Deus", "Louvar a Deus por sua graça"),
            _lesson("ef-02-graca", "Salvos pela graça", "Efésios 2-3", "Mortos em pecados, somos vivificados com Cristo pela graça mediante a fé.", "Como somos salvos?", "Pela graça mediante a fé", "A salvação é dom de Deus, não resultado de obras", "Viver nas boas obras preparadas por Deus"),
            _lesson("ef-03-igreja", "A nova vida e a armadura", "Efésios 4-6", "A igreja cresce em unidade e maturidade enquanto seus membros vestem a armadura de Deus.", "Contra quem é nossa luta?", "Contra forças espirituais do mal", "O cristão permanece firme na força do Senhor", "Vestir toda a armadura de Deus"),
            _boss("ef-04-desafio", "Desafio: Unidos em Cristo", "Efésios 1-6", "Revise graça, igreja, nova vida e firmeza na batalha espiritual.", "Quem é o cabeça da igreja?", "Cristo", "Deus forma um só povo em Cristo", "Preservar a unidade do Espírito"),
        ],
    },
    "filipenses": {
        "module": {"title": "Filipenses", "icon": "heart", "section": "Cartas de Paulo"},
        "missions": [
            _lesson("fp-01-alegria", "Alegria no evangelho", "Filipenses 1", "Mesmo preso, Paulo encontra alegria no avanço do evangelho e na comunhão da igreja.", "O que avançou por meio das prisões de Paulo?", "O evangelho", "A alegria cristã está ligada a Cristo e sua missão", "Alegrar-se no Senhor"),
            _lesson("fp-02-humildade", "A mente de Cristo", "Filipenses 2", "Jesus se humilhou, serviu e foi exaltado pelo Pai.", "Quem assumiu forma de servo?", "Jesus Cristo", "A humildade de Cristo orienta o relacionamento dos irmãos", "Considerar os outros superiores a si"),
            _lesson("fp-03-contentamento", "Contentamento e perseverança", "Filipenses 3-4", "Paulo prossegue para Cristo e aprende contentamento em toda situação.", "Quem fortalece Paulo?", "Cristo", "O contentamento depende de Cristo, não das circunstâncias", "Apresentar as necessidades a Deus em oração"),
            _boss("fp-04-desafio", "Desafio: Alegria que permanece", "Filipenses 1-4", "Revise alegria, humildade, perseverança e contentamento em Cristo.", "Qual atitude marcou Cristo em Filipenses 2?", "Humildade", "A vida cristã encontra sua alegria em Cristo", "Prosseguir para o alvo em Cristo"),
        ],
    },
    "colossenses": {
        "module": {"title": "Colossenses", "icon": "crown", "section": "Cartas de Paulo"},
        "missions": [
            _lesson("cl-01-supremacia", "A supremacia de Cristo", "Colossenses 1", "Cristo é a imagem do Deus invisível, criador e cabeça da igreja.", "Quem é a cabeça do corpo, a igreja?", "Cristo", "Cristo é supremo sobre toda a criação", "Adorar e seguir somente a Cristo"),
            _lesson("cl-02-plenitude", "Plenitude em Cristo", "Colossenses 2", "Em Cristo habita toda a plenitude e os crentes não precisam de falsos mediadores.", "Onde habita toda a plenitude da divindade?", "Em Cristo", "Em Cristo os cristãos estão completos", "Rejeitar ensinos que diminuem Cristo"),
            _lesson("cl-03-nova-vida", "A nova vida no lar", "Colossenses 3-4", "A nova identidade em Cristo aparece em santidade, perdão, gratidão e relacionamentos.", "O que deve habitar ricamente nos cristãos?", "A palavra de Cristo", "A vida nova substitui o velho modo de viver", "Revestir-se de amor"),
            _boss("cl-04-desafio", "Desafio: Cristo é suficiente", "Colossenses 1-4", "Revise a supremacia, a plenitude e a nova vida que estão em Cristo.", "Quem reconcilia todas as coisas?", "Jesus Cristo", "Cristo basta para a salvação e a maturidade", "Permanecer firme em Cristo"),
        ],
    },
    "tessalonicenses": {
        "module": {"title": "Tessalonicenses", "icon": "sunrise", "section": "Cartas de Paulo"},
        "missions": [
            _lesson("ts-01-conversao", "Conversão e exemplo", "1Tessalonicenses 1-2", "Os tessalonicenses se converteram dos ídolos para servir ao Deus vivo e verdadeiro.", "De que os tessalonicenses se converteram?", "Dos ídolos", "A fé verdadeira se volta para Deus e espera seu Filho", "Servir ao Deus vivo"),
            _lesson("ts-02-santidade", "Santidade e amor fraternal", "1Tessalonicenses 3-5", "Paulo chama a igreja à santidade, ao amor e à esperança na volta de Jesus.", "Qual é a vontade de Deus para os cristãos?", "A santificação", "A esperança da volta de Cristo fortalece uma vida santa", "Viver de modo santo e amoroso"),
            _lesson("ts-03-dia-senhor", "Firmeza diante do Dia do Senhor", "2Tessalonicenses 1-3", "Paulo consola os fiéis e corrige confusões sobre a vinda do Senhor.", "Quem será glorificado em seus santos?", "O Senhor Jesus", "A igreja deve permanecer firme na verdade recebida", "Perseverar e trabalhar com responsabilidade"),
            _boss("ts-04-desafio", "Desafio: Esperança vigilante", "1Tessalonicenses 1-5; 2Tessalonicenses 1-3", "Revise conversão, santidade, trabalho e esperança na volta de Cristo.", "A quem a igreja espera dos céus?", "Jesus Cristo", "A volta de Cristo inspira esperança e santidade", "Viver vigilante e fiel"),
        ],
    },
    "timoteo": {
        "module": {"title": "Timóteo", "icon": "compass", "section": "Cartas de Paulo"},
        "missions": [
            _lesson("tm-01-sadia-doutrina", "Sadia doutrina e oração", "1Timóteo 1-2", "Timóteo deve proteger a igreja de falsos ensinos e promover oração por todos.", "Quantos mediadores há entre Deus e os homens?", "Um", "Jesus Cristo é o único mediador e Salvador", "Orar por todas as pessoas"),
            _lesson("tm-02-lideranca", "Liderança e piedade", "1Timóteo 3-6", "A igreja precisa de líderes íntegros e de uma vida marcada por piedade e contentamento.", "Qual é a raiz de todos os males, segundo Paulo?", "O amor ao dinheiro", "A piedade com contentamento é grande fonte de lucro", "Buscar piedade e contentamento"),
            _lesson("tm-03-perseveranca", "Guardar o bom depósito", "2Timóteo 1-4", "Paulo encoraja Timóteo a sofrer pelo evangelho, pregar a Palavra e perseverar.", "O que Timóteo deve pregar?", "A Palavra", "A Escritura equipa o servo de Deus para toda boa obra", "Guardar e transmitir a verdade"),
            _boss("tm-04-desafio", "Desafio: Bom ministro", "1Timóteo 1-6; 2Timóteo 1-4", "Revise doutrina, oração, liderança, piedade e perseverança no ministério.", "O que Timóteo deve guardar?", "O bom depósito", "O ministro fiel permanece na Palavra de Deus", "Pregar a Palavra com fidelidade"),
        ],
    },
    "tito": {
        "module": {"title": "Tito", "icon": "anchor", "section": "Cartas de Paulo"},
        "missions": [
            _lesson("tt-01-lideres", "Líderes e sã doutrina", "Tito 1", "Tito deve estabelecer presbíteros íntegros que protejam a igreja do erro.", "Quem Tito deveria estabelecer nas cidades?", "Presbíteros", "Líderes devem apegar-se à fiel palavra", "Valorizar a sã doutrina"),
            _lesson("tt-02-graca", "A graça que educa", "Tito 2-3", "A graça salvadora nos ensina a renunciar à impiedade e a viver de modo santo.", "O que a graça de Deus nos ensina a renunciar?", "À impiedade", "A salvação é pela misericórdia de Deus, não por obras meritórias", "Zelar por boas obras"),
            _boss("tt-03-desafio", "Desafio: Povo zeloso", "Tito 1-3", "Revise liderança, sã doutrina e a graça que transforma o povo de Deus.", "Por que Cristo se deu por nós?", "Para formar um povo zeloso de boas obras", "A graça produz uma vida útil e santa", "Praticar boas obras por gratidão"),
        ],
    },
    "filemom": {
        "module": {"title": "Filemom", "icon": "handshake", "section": "Cartas de Paulo"},
        "missions": [
            _lesson("fm-01-intercessao", "Intercessão por Onésimo", "Filemom 1:1-16", "Paulo apela por Onésimo, agora irmão amado em Cristo.", "Como Paulo chama Onésimo em Cristo?", "Irmão amado", "O evangelho cria uma nova família entre os crentes", "Receber irmãos com amor"),
            _lesson("fm-02-reconciliacao", "Receber como a Paulo", "Filemom 1:17-25", "Paulo assume a causa de Onésimo e pede que Filemom o receba como receberia o próprio apóstolo.", "Como Filemom deveria receber Onésimo?", "Como a Paulo", "A reconciliação cristã reflete a graça recebida", "Buscar reconciliação e perdão"),
            _boss("fm-03-desafio", "Desafio: Graça que reconcilia", "Filemom 1", "Revise a intercessão de Paulo e a nova relação criada pelo evangelho.", "Quem intercedeu por Onésimo?", "Paulo", "Em Cristo, irmãos são recebidos com perdão e dignidade", "Tratar os irmãos como família em Cristo"),
        ],
    },
}
