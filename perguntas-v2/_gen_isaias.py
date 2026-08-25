#!/usr/bin/env python3
"""Gera perguntas-v2/isaias.json (90)."""
import json
from pathlib import Path

TF = [{"id": "true", "text": "Verdadeiro"}, {"id": "false", "text": "Falso"}]

P61 = (
    "No ano em que morreu o rei Uzias, vi Jeová sentado sobre um alto e elevado trono, "
    "e as orlas do seu vestido enchiam o templo. Serafins estavam por cima dele; cada um "
    "tinha seis asas; com duas, cobria o rosto, com duas, cobria os pés e com duas, voava. "
    "Um chamava ao outro e dizia: Santo, santo, santo é Jeová dos Exércitos; a terra toda "
    "está cheia da sua glória."
)
P68 = "Ouvi a voz de Jeová dizer: Quem enviarei eu, e quem irá por nós? Disse eu: Eis-me aqui; envia-me a mim."
P714 = (
    "Portanto, o Senhor mesmo vos dará um sinal; eis que uma donzela conceberá, "
    "e dará à luz um filho, e por-lhe-á o nome de Emanuel."
)
P53 = (
    "Mas ele foi ferido por causa das nossas transgressões, esmagado por causa das nossas "
    "iniquidades; o castigo que nos devia trazer a paz caiu sobre ele, e pelas suas pisaduras "
    "fomos nós sarados. Todos nós temos andado desgarrados como ovelhas; temo-nos desviado "
    "cada um para o seu caminho; e Jeová fez cair sobre ele a iniquidade de todos nós."
)

INS1 = "A visão do trono: Jeová santo, o templo cheio, a terra cheia de glória — o rei Uzias morre, o Rei permanece."
INS2 = "O chamado responde ao santo: eis-me aqui, envia-me — não voluntarismo sem visão."
INS3 = "O sinal não é estratégia de Acaz: o Senhor dá Emanuel — Deus conosco."
INS4 = "O Servo leva a iniquidade das ovelhas desgarradas: ferido por nós, paz e cura sobre ele."
INS5 = "Isaías: o Santo envia, Emanuel vem, o Servo é ferido por nós."


def item(
    *,
    trail,
    section,
    short,
    nn,
    difficulty,
    skill,
    typ,
    verse_ref,
    lo,
    evidence,
    question,
    feedback_correct,
    feedback_wrong,
    options,
    correct,
    passage=None,
    template=None,
    correct_order=None,
    passage_a=None,
    passage_b=None,
):
    qid = f"{trail}-{short}-{section}-{nn}"
    d = {
        "difficulty": difficulty,
        "skill": skill,
        "verseRef": verse_ref,
        "learningObjective": lo,
        "evidence": evidence,
        "type": typ,
        "question": question,
        "prompt": question,
        "cue": question,
        "feedbackCorrect": feedback_correct,
        "feedbackWrong": feedback_wrong,
    }
    if passage:
        d["passageText"] = passage
    if template:
        d["template"] = template
    d["options"] = options
    d["correctOptionId"] = correct
    d["correctAnswer"] = correct
    if correct_order:
        d["correctOrder"] = correct_order
    if passage_a:
        d["passageA"] = passage_a
        d["passageB"] = passage_b
    d["trail"] = trail
    d["section"] = section
    d["id"] = qid
    return d


def pack(section, short, difficulty, skill, nn, typ, **kw):
    return item(
        trail="isaias",
        section=section,
        short=short,
        nn=nn,
        difficulty=difficulty,
        skill=skill,
        typ=typ,
        **kw,
    )


bank = []

# ---------------------------------------------------------------------------
# M1 visão do trono
# ---------------------------------------------------------------------------
S1 = "isaias-chamado-is-01-visao-do-trono"
LO1 = "Reconhecer que, na morte de Uzias, Isaías vê Jeová no trono santo: o templo e a terra se enchem da sua glória."
VR1 = "Isaías 6:1–3"
EV1 = ["Isaías 6:1", "Isaías 6:2", "Isaías 6:3"]

bank += [
    pack(
        S1, "sem", "semente", "observe", "01", "true_false",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question="No ano em que morreu o rei Uzias, Isaías viu Jeová sentado sobre um alto e elevado trono.",
        feedback_correct="Certo: a visão se abre com a morte de Uzias e o trono de Jeová.",
        feedback_wrong={"false": "O texto liga a visão ao ano da morte de Uzias e ao trono de Jeová."},
        options=TF, correct="true",
    ),
    pack(
        S1, "sem", "semente", "observe", "02", "tap",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question='Em Isaías 6:1–3, toque a palavra que falta em "as orlas do seu vestido enchiam o ___"?',
        feedback_correct="Exato: as orlas do vestido enchiam o templo.",
        feedback_wrong={
            "a": "Trono é onde Jeová está sentado, não o que o vestido enche.",
            "c": "Rosto é o que os serafins cobrem, não o que o vestido enche.",
        },
        template="as orlas do seu vestido enchiam o ___",
        options=[{"id": "a", "text": "trono"}, {"id": "b", "text": "templo"}, {"id": "c", "text": "rosto"}],
        correct="b",
    ),
    pack(
        S1, "sem", "semente", "observe", "03", "choice",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question="Qual fato o texto afirma sobre o que Isaías viu?",
        feedback_correct="Certo: Jeová está sentado sobre um alto e elevado trono.",
        feedback_wrong={
            "b": "Uzias morreu; o trono visto é o de Jeová, não o do rei morto.",
            "c": "Os serafins estão por cima dele; quem está no trono é Jeová.",
            "d": "O templo está cheio das orlas do vestido, não vazio.",
        },
        options=[
            {"id": "a", "text": "Jeová sentado sobre um alto e elevado trono"},
            {"id": "b", "text": "Uzias ainda vivo sobre o trono do templo"},
            {"id": "c", "text": "Serafins sentados no lugar de Jeová"},
            {"id": "d", "text": "O templo vazio, sem vestido nem glória"},
        ],
        correct="a",
    ),
    pack(
        S1, "sem", "semente", "observe", "04", "order",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question="Qual sequência mostra a ordem dos fatos em Isaías 6:1–3?",
        feedback_correct="Certo: primeiro a morte de Uzias, depois o trono, depois o canto.",
        feedback_wrong={
            "b": "A morte de Uzias abre o relato, não o fecha.",
            "c": "O cântico dos serafins vem depois da visão do trono.",
        },
        options=[
            {"id": "a", "text": "No ano em que morreu o rei Uzias"},
            {"id": "b", "text": "vi Jeová sentado sobre um alto e elevado trono"},
            {"id": "c", "text": "Santo, santo, santo é Jeová dos Exércitos"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S1, "sem", "semente", "observe", "05", "complete",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question='Complete a frase: "a terra toda está cheia da sua ___"',
        feedback_correct="Certo: a terra toda está cheia da sua glória.",
        feedback_wrong={
            "b": "Templo é o que as orlas enchiam, não esta lacuna.",
            "c": "Asas descrevem os serafins, não o que enche a terra.",
        },
        template="a terra toda está cheia da sua ___",
        options=[{"id": "a", "text": "glória"}, {"id": "b", "text": "templo"}, {"id": "c", "text": "asas"}],
        correct="a",
    ),
    pack(
        S1, "sem", "semente", "observe", "06", "connect",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question="O que Isaías 6:1–3 comunica que se liga a este contexto?",
        feedback_correct="Certo: Uzias morre, mas o Rei santo permanece.",
        feedback_wrong={
            "b": "A visão não exalta Uzias; o trono visto é o de Jeová.",
            "c": "A glória não se limita ao palácio humano.",
        },
        passage_a={"ref": "Isaías 6:1–3", "text": "vi Jeová sentado sobre um alto e elevado trono"},
        passage_b={"ref": "Contexto", "text": INS1},
        options=[
            {"id": "a", "text": "O Rei permanece"},
            {"id": "b", "text": "Uzias herda o trono"},
            {"id": "c", "text": "Glória só no palácio"},
        ],
        correct="a",
    ),
    pack(
        S1, "cam", "caminhada", "understand", "01", "true_false",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question="A visão apresenta Uzias como o rei que permanece no trono depois da morte.",
        feedback_correct="Certo em julgar falso: quem permanece no trono é Jeová.",
        feedback_wrong={"true": "Uzias morre; o trono alto e elevado é o de Jeová."},
        options=TF, correct="false",
    ),
    pack(
        S1, "cam", "caminhada", "understand", "02", "tap",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question='Em Isaías 6:1–3, toque a palavra que falta em "com duas, cobria o ___, com duas, cobria os pés"?',
        feedback_correct="Exato: com duas asas cobria o rosto.",
        feedback_wrong={
            "b": "Pés vêm na frase seguinte, não nesta lacuna.",
            "c": "Templo é o que as orlas enchiam, não o que se cobre aqui.",
        },
        template="com duas, cobria o ___, com duas, cobria os pés",
        options=[{"id": "a", "text": "rosto"}, {"id": "b", "text": "pés"}, {"id": "c", "text": "templo"}],
        correct="a",
    ),
    pack(
        S1, "cam", "caminhada", "understand", "03", "choice",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question="Como o texto encadeia a morte de Uzias e a visão do trono?",
        feedback_correct="Certo: o rei morre, mas Jeová permanece no trono.",
        feedback_wrong={
            "a": "O trono de Uzias não substitui o de Jeová.",
            "c": "Os serafins não ocupam o trono deixado pelo rei.",
            "d": "A glória enche a terra toda, não só o palácio de Uzias.",
        },
        options=[
            {"id": "a", "text": "O trono de Uzias substitui o trono de Jeová"},
            {"id": "b", "text": "Uzias morre, mas Jeová permanece no trono"},
            {"id": "c", "text": "Os serafins ocupam o trono deixado por Uzias"},
            {"id": "d", "text": "A glória de Jeová se limita ao palácio de Uzias"},
        ],
        correct="b",
    ),
    pack(
        S1, "cam", "caminhada", "understand", "04", "order",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question="Como se encadeiam os eventos de Isaías 6:1–3?",
        feedback_correct="Certo: morte do rei, visão do trono, proclamação da glória.",
        feedback_wrong={
            "b": "O cântico não precede a visão do trono.",
            "c": "A morte de Uzias abre o ano, não fecha o cântico.",
        },
        options=[
            {"id": "a", "text": "A morte do rei Uzias abre o ano da visão"},
            {"id": "b", "text": "Isaías vê Jeová no trono e o templo cheio"},
            {"id": "c", "text": "Os serafins proclamam a santidade que enche a terra"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S1, "cam", "caminhada", "understand", "05", "complete",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question='Complete a frase: "cada um tinha seis ___; com duas, cobria o rosto"',
        feedback_correct="Certo: cada serafim tinha seis asas.",
        feedback_wrong={
            "a": "Orlas pertencem ao vestido de Jeová, não aos serafins.",
            "c": "Serafins são quem tinha as asas, não a palavra da lacuna.",
        },
        template="cada um tinha seis ___; com duas, cobria o rosto",
        options=[{"id": "a", "text": "orlas"}, {"id": "b", "text": "asas"}, {"id": "c", "text": "Serafins"}],
        correct="b",
    ),
    pack(
        S1, "cam", "caminhada", "understand", "06", "connect",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question="O que Isaías 6:1–3 comunica que se liga a este contexto?",
        feedback_correct="Certo: santidade no templo e glória na terra.",
        feedback_wrong={
            "a": "A glória não fica presa ao recinto do templo.",
            "c": "A visão não é um lamento por Uzias.",
        },
        passage_a={"ref": "Isaías 6:3", "text": "Santo, santo, santo é Jeová dos Exércitos; a terra toda está cheia da sua glória."},
        passage_b={"ref": "Contexto", "text": INS1},
        options=[
            {"id": "a", "text": "Glória só no templo"},
            {"id": "b", "text": "Templo e terra cheios"},
            {"id": "c", "text": "Lamento pelo rei morto"},
        ],
        correct="b",
    ),
    pack(
        S1, "pro", "profundezas", "interpret", "01", "true_false",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question="A visão reduz Jeová a um deus local cujo domínio não ultrapassa o templo.",
        feedback_correct="Certo em julgar falso: a terra toda está cheia da sua glória.",
        feedback_wrong={"true": "O cântico diz que a terra toda está cheia da glória de Jeová."},
        options=TF, correct="false",
    ),
    pack(
        S1, "pro", "profundezas", "interpret", "02", "tap",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question='Em Isaías 6:1–3, toque a palavra que falta em "Santo, santo, santo é Jeová dos ___"?',
        feedback_correct="Exato: Jeová dos Exércitos.",
        feedback_wrong={
            "a": "Serafins proclamam, mas o título é dos Exércitos.",
            "b": "Uzias é o rei que morreu, não o título de Jeová.",
        },
        template="Santo, santo, santo é Jeová dos ___",
        options=[{"id": "a", "text": "Serafins"}, {"id": "b", "text": "Uzias"}, {"id": "c", "text": "Exércitos"}],
        correct="c",
    ),
    pack(
        S1, "pro", "profundezas", "interpret", "03", "choice",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question="Que sentido teológico a visão do trono impõe ao leitor?",
        feedback_correct="Certo: a santidade de Jeová julga reis e enche o mundo.",
        feedback_wrong={
            "b": "A morte de Uzias não prova falha da santidade de Jeová.",
            "c": "O trono alto não torna Jeová dependente do templo humano.",
            "d": "Cobrir o rosto é reverência, não ausência de reinado.",
        },
        options=[
            {"id": "a", "text": "A santidade de Jeová julga reis e enche o mundo"},
            {"id": "b", "text": "Uzias morre porque a santidade de Jeová falhou"},
            {"id": "c", "text": "O trono alto prova que Jeová depende do templo"},
            {"id": "d", "text": "Cobrir o rosto mostra que Jeová não reina"},
        ],
        correct="a",
    ),
    pack(
        S1, "pro", "profundezas", "interpret", "04", "order",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question="Qual sequência revela o sentido de Isaías 6:1–3?",
        feedback_correct="Certo: o rei humano cai; o Rei santo permanece; a terra se enche.",
        feedback_wrong={
            "b": "A glória da terra não precede a morte do rei humano.",
            "c": "O Rei santo permanece depois da morte de Uzias, não antes como desfecho.",
        },
        options=[
            {"id": "a", "text": "O rei humano morre"},
            {"id": "b", "text": "O Rei santo permanece no trono"},
            {"id": "c", "text": "A terra toda está cheia da sua glória"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S1, "pro", "profundezas", "interpret", "05", "complete",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question='Complete a frase: "Um chamava ao outro e dizia: ___, santo, santo é Jeová dos Exércitos"',
        feedback_correct="Certo: a tríplice proclamação começa com Santo.",
        feedback_wrong={
            "b": "Uzias não é o sujeito do cântico.",
            "c": "Trono descreve a visão, não a primeira palavra do cântico.",
        },
        template="Um chamava ao outro e dizia: ___, santo, santo é Jeová dos Exércitos",
        options=[{"id": "a", "text": "Santo"}, {"id": "b", "text": "Uzias"}, {"id": "c", "text": "trono"}],
        correct="a",
    ),
    pack(
        S1, "pro", "profundezas", "interpret", "06", "connect",
        verse_ref=VR1, lo=LO1, evidence=EV1, passage=P61,
        question="O que Isaías 6:1–3 comunica que se liga a este contexto?",
        feedback_correct="Certo: a santidade prepara o profeta antes do envio.",
        feedback_wrong={
            "a": "A visão não é um lamento dinástico.",
            "b": "O centro não é o templo vazio, e sim o Santo que o enche.",
        },
        passage_a={"ref": "Isaías 6:1–3", "text": "Santo, santo, santo é Jeová dos Exércitos; a terra toda está cheia da sua glória."},
        passage_b={"ref": "Contexto", "text": INS1},
        options=[
            {"id": "a", "text": "Luto pela dinastia"},
            {"id": "b", "text": "Templo abandonado"},
            {"id": "c", "text": "Santidade antes do envio"},
        ],
        correct="c",
    ),
]

# ---------------------------------------------------------------------------
# M2 aqui estou
# ---------------------------------------------------------------------------
S2 = "isaias-chamado-is-02-aqui-estou-eu-envia-"
LO2 = "Reconhecer que o chamado de Isaías responde à voz do Santo: eis-me aqui, envia-me — não voluntarismo sem visão."
VR2 = "Isaías 6:8"
EV2 = ["Isaías 6:8"]

bank += [
    pack(
        S2, "sem", "semente", "observe", "01", "true_false",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question="Isaías ouviu a voz de Jeová e respondeu: Eis-me aqui; envia-me a mim.",
        feedback_correct="Certo: o texto registra exatamente essa resposta.",
        feedback_wrong={"false": "Depois de ouvir a voz, Isaías diz: Eis-me aqui; envia-me a mim."},
        options=TF, correct="true",
    ),
    pack(
        S2, "sem", "semente", "observe", "02", "tap",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question='Em Isaías 6:8, toque a palavra que falta em "Disse eu: Eis-me aqui; ___ a mim"?',
        feedback_correct="Exato: envia-me a mim.",
        feedback_wrong={
            "b": "Voz é o que Isaías ouve, não o verbo da resposta.",
            "c": "Jeová é quem fala; a lacuna é o pedido de envio.",
        },
        template="Disse eu: Eis-me aqui; ___ a mim",
        options=[{"id": "a", "text": "envia-me"}, {"id": "b", "text": "voz"}, {"id": "c", "text": "Jeová"}],
        correct="a",
    ),
    pack(
        S2, "sem", "semente", "observe", "03", "choice",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question="O que o texto registra depois que Isaías ouve a voz de Jeová?",
        feedback_correct="Certo: Isaías se apresenta para ser enviado.",
        feedback_wrong={
            "b": "O texto não registra recusa nem pedido de outro mensageiro.",
            "c": "Uzias já morreu no capítulo; quem responde é Isaías.",
            "d": "O envio parte da voz de Jeová, não dos serafins neste versículo.",
        },
        options=[
            {"id": "a", "text": "Isaías diz: Eis-me aqui; envia-me a mim"},
            {"id": "b", "text": "Isaías recusa o envio e pede outro mensageiro"},
            {"id": "c", "text": "Uzias responde no lugar de Isaías"},
            {"id": "d", "text": "Os serafins enviam Isaías sem a voz de Jeová"},
        ],
        correct="a",
    ),
    pack(
        S2, "sem", "semente", "observe", "04", "order",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question="Qual sequência mostra a ordem dos fatos em Isaías 6:8?",
        feedback_correct="Certo: ouvir, a pergunta de Jeová, a resposta de Isaías.",
        feedback_wrong={
            "b": "A resposta não precede a voz.",
            "c": "A pergunta de Jeová vem depois de Isaías ouvir, não no fim.",
        },
        options=[
            {"id": "a", "text": "Ouvi a voz de Jeová dizer"},
            {"id": "b", "text": "Quem enviarei eu, e quem irá por nós"},
            {"id": "c", "text": "Disse eu: Eis-me aqui; envia-me a mim"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S2, "sem", "semente", "observe", "05", "complete",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question='Complete a frase: "Ouvi a voz de ___ dizer"',
        feedback_correct="Certo: a voz é de Jeová.",
        feedback_wrong={
            "b": "Nós aparece na pergunta, não como quem fala.",
            "c": "Mim é Isaías na resposta, não a voz ouvida.",
        },
        template="Ouvi a voz de ___ dizer",
        options=[{"id": "a", "text": "Jeová"}, {"id": "b", "text": "nós"}, {"id": "c", "text": "mim"}],
        correct="a",
    ),
    pack(
        S2, "sem", "semente", "observe", "06", "connect",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question="O que Isaías 6:8 comunica que se liga a este contexto?",
        feedback_correct="Certo: o chamado responde ao Santo que envia.",
        feedback_wrong={
            "b": "Não é recusa; é disponibilidade.",
            "c": "Não é iniciativa isolada antes da voz.",
        },
        passage_a={"ref": "Isaías 6:8", "text": P68},
        passage_b={"ref": "Contexto", "text": INS2},
        options=[
            {"id": "a", "text": "Resposta ao Santo"},
            {"id": "b", "text": "Recusa do envio"},
            {"id": "c", "text": "Iniciativa sem voz"},
        ],
        correct="a",
    ),
    pack(
        S2, "cam", "caminhada", "understand", "01", "true_false",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question="Isaías se oferece como voluntário antes de ouvir a voz de Jeová.",
        feedback_correct="Certo em julgar falso: primeiro ele ouve, depois responde.",
        feedback_wrong={"true": "O texto começa com Ouvi a voz; a oferta vem depois."},
        options=TF, correct="false",
    ),
    pack(
        S2, "cam", "caminhada", "understand", "02", "tap",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question='Em Isaías 6:8, toque a palavra que falta em "Quem ___ eu, e quem irá por nós"?',
        feedback_correct="Exato: Quem enviarei eu.",
        feedback_wrong={
            "a": "Ouvi é o verbo de Isaías, não o da pergunta de Jeová.",
            "c": "Voz é o que se ouve, não o verbo enviarei.",
        },
        template="Quem ___ eu, e quem irá por nós",
        options=[{"id": "a", "text": "Ouvi"}, {"id": "b", "text": "enviarei"}, {"id": "c", "text": "voz"}],
        correct="b",
    ),
    pack(
        S2, "cam", "caminhada", "understand", "03", "choice",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question="Como a resposta de Isaías se relaciona com a voz que ele ouviu?",
        feedback_correct="Certo: ele responde à pergunta de Jeová, depois de ouvir.",
        feedback_wrong={
            "b": "Ele não antecipa a voz com iniciativa puramente humana.",
            "c": "Não há plano de Uzias neste versículo.",
            "d": "Ele não recusa o por nós; aceita o envio.",
        },
        options=[
            {"id": "a", "text": "Responde à pergunta de Jeová depois de ouvir a voz"},
            {"id": "b", "text": "Antecipa a voz, como iniciativa puramente humana"},
            {"id": "c", "text": "Substitui o envio de Jeová por um plano de Uzias"},
            {"id": "d", "text": "Recusa o por nós e aceita só um envio particular"},
        ],
        correct="a",
    ),
    pack(
        S2, "cam", "caminhada", "understand", "04", "order",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question="Como se encadeiam os eventos de Isaías 6:8?",
        feedback_correct="Certo: ouvir, a pergunta, a apresentação.",
        feedback_wrong={
            "b": "Isaías não se apresenta antes de ouvir.",
            "c": "A pergunta de Jeová não é o último elo.",
        },
        options=[
            {"id": "a", "text": "Isaías ouve a voz de Jeová"},
            {"id": "b", "text": "Jeová pergunta quem enviará e quem irá"},
            {"id": "c", "text": "Isaías se apresenta: eis-me aqui, envia-me"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S2, "cam", "caminhada", "understand", "05", "complete",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question='Complete a frase: "quem irá por ___?"',
        feedback_correct="Certo: quem irá por nós.",
        feedback_wrong={
            "a": "Eu pertence a Quem enviarei eu, não a esta lacuna.",
            "c": "Mim é a resposta de Isaías, não o por nós.",
        },
        template="quem irá por ___?",
        options=[{"id": "a", "text": "eu"}, {"id": "b", "text": "nós"}, {"id": "c", "text": "mim"}],
        correct="b",
    ),
    pack(
        S2, "cam", "caminhada", "understand", "06", "connect",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question="O que Isaías 6:8 comunica que se liga a este contexto?",
        feedback_correct="Certo: não é voluntarismo sem visão do Santo.",
        feedback_wrong={
            "a": "O envio não nasce de um plano de carreira.",
            "c": "Ele não recusa por se achar indigno neste versículo.",
        },
        passage_a={"ref": "Isaías 6:8", "text": "Disse eu: Eis-me aqui; envia-me a mim."},
        passage_b={"ref": "Contexto", "text": INS2},
        options=[
            {"id": "a", "text": "Plano de carreira"},
            {"id": "b", "text": "Não voluntarismo cego"},
            {"id": "c", "text": "Recusa por indignidade"},
        ],
        correct="b",
    ),
    pack(
        S2, "pro", "profundezas", "interpret", "01", "true_false",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question="O eis-me aqui de Isaías é resposta ao Santo que envia, não um projeto iniciado pelo profeta.",
        feedback_correct="Certo: a iniciativa é de Jeová; Isaías responde.",
        feedback_wrong={"false": "A voz pergunta primeiro; o profeta não inaugura o chamado."},
        options=TF, correct="true",
    ),
    pack(
        S2, "pro", "profundezas", "interpret", "02", "tap",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question='Em Isaías 6:8, toque a palavra que falta em "Eis-me ___; envia-me a mim"?',
        feedback_correct="Exato: Eis-me aqui.",
        feedback_wrong={
            "b": "Voz é o que ele ouviu, não a palavra desta lacuna.",
            "c": "Nós pertence à pergunta de Jeová.",
        },
        template="Eis-me ___; envia-me a mim",
        options=[{"id": "a", "text": "aqui"}, {"id": "b", "text": "voz"}, {"id": "c", "text": "nós"}],
        correct="a",
    ),
    pack(
        S2, "pro", "profundezas", "interpret", "03", "choice",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question="Que leitura teológica o envio de Isaías 6:8 sustenta?",
        feedback_correct="Certo: o envio nasce da iniciativa de Jeová.",
        feedback_wrong={
            "b": "O profeta não cria o chamado para Jeová confirmar.",
            "c": "Por nós não prova que Isaías escolhe a comissão sozinho.",
            "d": "Recusar não seria mais santo; o Santo é quem envia.",
        },
        options=[
            {"id": "a", "text": "O envio nasce da iniciativa de Jeová; Isaías responde"},
            {"id": "b", "text": "O profeta cria o chamado e Jeová apenas confirma"},
            {"id": "c", "text": "O por nós prova que Isaías escolhe sozinho"},
            {"id": "d", "text": "Recusar seria mais santo, pois o envio diminui Jeová"},
        ],
        correct="a",
    ),
    pack(
        S2, "pro", "profundezas", "interpret", "04", "order",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question="Qual sequência revela o sentido de Isaías 6:8?",
        feedback_correct="Certo: a voz pergunta, o profeta se apresenta, o envio é de Jeová.",
        feedback_wrong={
            "b": "O envio de Jeová não é o primeiro elo isolado da disponibilidade.",
            "c": "A apresentação do profeta não fecha o sentido sem a pergunta anterior.",
        },
        options=[
            {"id": "a", "text": "A voz do Santo pergunta quem enviará"},
            {"id": "b", "text": "O profeta se apresenta disponível"},
            {"id": "c", "text": "O envio parte de Jeová, não do voluntarismo isolado"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S2, "pro", "profundezas", "interpret", "05", "complete",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question='Complete a frase: "Disse eu: Eis-me aqui; envia-me a ___"',
        feedback_correct="Certo: envia-me a mim.",
        feedback_wrong={
            "b": "Nós é o plural da pergunta de Jeová.",
            "c": "Voz é o que ele ouviu, não o objeto do envia-me.",
        },
        template="Disse eu: Eis-me aqui; envia-me a ___",
        options=[{"id": "a", "text": "mim"}, {"id": "b", "text": "nós"}, {"id": "c", "text": "voz"}],
        correct="a",
    ),
    pack(
        S2, "pro", "profundezas", "interpret", "06", "connect",
        verse_ref=VR2, lo=LO2, evidence=EV2, passage=P68,
        question="O que Isaías 6:8 comunica que se liga a este contexto?",
        feedback_correct="Certo: disponibilidade depois da visão do Santo.",
        feedback_wrong={
            "a": "Não é carreira sem trono.",
            "c": "Não é silêncio diante da pergunta.",
        },
        passage_a={"ref": "Isaías 6:8", "text": "Quem enviarei eu, e quem irá por nós? Disse eu: Eis-me aqui; envia-me a mim."},
        passage_b={"ref": "Contexto", "text": INS2},
        options=[
            {"id": "a", "text": "Carreira sem trono"},
            {"id": "b", "text": "Disponível após o Santo"},
            {"id": "c", "text": "Silêncio à pergunta"},
        ],
        correct="b",
    ),
]

# ---------------------------------------------------------------------------
# M3 Emanuel — Isaías 7:14 (não 53)
# ---------------------------------------------------------------------------
S3 = "isaias-esperanca--01-o-emanuel"
LO3 = "Reconhecer que o sinal não é estratégia de Acaz: o Senhor mesmo dá o filho chamado Emanuel — Deus conosco."
VR3 = "Isaías 7:14"
EV3 = ["Isaías 7:14"]

bank += [
    pack(
        S3, "sem", "semente", "observe", "01", "true_false",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question="O Senhor mesmo dará um sinal: uma donzela conceberá, dará à luz um filho, e por-lhe-á o nome de Emanuel.",
        feedback_correct="Certo: é exatamente o sinal de Isaías 7:14.",
        feedback_wrong={"false": "O versículo atribui o sinal ao Senhor e o nome Emanuel ao filho."},
        options=TF, correct="true",
    ),
    pack(
        S3, "sem", "semente", "observe", "02", "tap",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question='Em Isaías 7:14, toque a palavra que falta em "por-lhe-á o nome de ___"?',
        feedback_correct="Exato: o nome é Emanuel.",
        feedback_wrong={
            "b": "Donzela é quem concebe, não o nome dado ao filho.",
            "c": "Senhor é quem dá o sinal, não o nome nesta lacuna.",
        },
        template="por-lhe-á o nome de ___",
        options=[{"id": "a", "text": "Emanuel"}, {"id": "b", "text": "donzela"}, {"id": "c", "text": "Senhor"}],
        correct="a",
    ),
    pack(
        S3, "sem", "semente", "observe", "03", "choice",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question="Quem, segundo Isaías 7:14, dá o sinal?",
        feedback_correct="Certo: o Senhor mesmo vos dará um sinal.",
        feedback_wrong={
            "b": "O texto não diz que Acaz escolhe o sinal.",
            "c": "A donzela concebe; quem dá o sinal é o Senhor.",
            "d": "O sinal é um filho chamado Emanuel, não um exército.",
        },
        options=[
            {"id": "a", "text": "O Senhor mesmo vos dará um sinal"},
            {"id": "b", "text": "Acaz escolhe o sinal que prefere"},
            {"id": "c", "text": "A donzela escolhe o nome sem o Senhor"},
            {"id": "d", "text": "O sinal é um exército, não um filho"},
        ],
        correct="a",
    ),
    pack(
        S3, "sem", "semente", "observe", "04", "order",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question="Qual sequência mostra a ordem dos fatos em Isaías 7:14?",
        feedback_correct="Certo: o Senhor dá o sinal, a donzela gera o filho, o nome é Emanuel.",
        feedback_wrong={
            "b": "O nome não precede o anúncio do sinal.",
            "c": "A conceição vem depois da promessa do sinal, não no fim isolada.",
        },
        options=[
            {"id": "a", "text": "o Senhor mesmo vos dará um sinal"},
            {"id": "b", "text": "uma donzela conceberá, e dará à luz um filho"},
            {"id": "c", "text": "por-lhe-á o nome de Emanuel"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S3, "sem", "semente", "observe", "05", "complete",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question='Complete a frase: "eis que uma ___ conceberá"',
        feedback_correct="Certo: uma donzela conceberá.",
        feedback_wrong={
            "b": "Filho é quem nasce, não quem concebe.",
            "c": "Sinal é o que o Senhor dá, não o sujeito de conceberá.",
        },
        template="eis que uma ___ conceberá",
        options=[{"id": "a", "text": "donzela"}, {"id": "b", "text": "filho"}, {"id": "c", "text": "sinal"}],
        correct="a",
    ),
    pack(
        S3, "sem", "semente", "observe", "06", "connect",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question="O que Isaías 7:14 comunica que se liga a este contexto?",
        feedback_correct="Certo: o Senhor dá Emanuel, Deus conosco.",
        feedback_wrong={
            "b": "Não é tática de Acaz.",
            "c": "Não é o retrato do Servo ferido de Isaías 53.",
        },
        passage_a={"ref": "Isaías 7:14", "text": P714},
        passage_b={"ref": "Contexto", "text": INS3},
        options=[
            {"id": "a", "text": "O Senhor dá Emanuel"},
            {"id": "b", "text": "Tática de Acaz"},
            {"id": "c", "text": "O Servo ferido"},
        ],
        correct="a",
    ),
    pack(
        S3, "cam", "caminhada", "understand", "01", "true_false",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question="O sinal de Isaías 7:14 é um recurso político que Acaz inventa para garantir a aliança.",
        feedback_correct="Certo em julgar falso: o Senhor mesmo dá o sinal.",
        feedback_wrong={"true": "O texto atribui o sinal ao Senhor, não à estratégia de Acaz."},
        options=TF, correct="false",
    ),
    pack(
        S3, "cam", "caminhada", "understand", "02", "tap",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question='Em Isaías 7:14, toque a palavra que falta em "o Senhor mesmo vos dará um ___"?',
        feedback_correct="Exato: o Senhor dá um sinal.",
        feedback_wrong={
            "b": "Filho descreve o conteúdo do sinal, não esta palavra.",
            "c": "Nome vem no fim, ligado a Emanuel.",
        },
        template="o Senhor mesmo vos dará um ___",
        options=[{"id": "a", "text": "sinal"}, {"id": "b", "text": "filho"}, {"id": "c", "text": "nome"}],
        correct="a",
    ),
    pack(
        S3, "cam", "caminhada", "understand", "03", "choice",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question="Como o sinal de Emanuel se distingue de uma tática real?",
        feedback_correct="Certo: o Senhor dá o sinal; não é tática de Acaz.",
        feedback_wrong={
            "b": "Acaz não fabrica Emanuel para impressionar a Síria neste versículo.",
            "c": "O nome Emanuel não substitui o Senhor no texto.",
            "d": "A donzela concebe um filho; o sinal não é ela sem o filho.",
        },
        options=[
            {"id": "a", "text": "O Senhor dá o sinal; não é tática de Acaz"},
            {"id": "b", "text": "Acaz fabrica Emanuel para impressionar a Síria"},
            {"id": "c", "text": "O nome Emanuel substitui o Senhor no texto"},
            {"id": "d", "text": "A donzela é o sinal, sem filho nem nome"},
        ],
        correct="a",
    ),
    pack(
        S3, "cam", "caminhada", "understand", "04", "order",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question="Como se encadeiam os eventos de Isaías 7:14?",
        feedback_correct="Certo: promessa, nascimento, nome.",
        feedback_wrong={
            "b": "O nome não vem antes da promessa do sinal.",
            "c": "A conceição não é o último elo depois do nome.",
        },
        options=[
            {"id": "a", "text": "O Senhor promete dar o sinal"},
            {"id": "b", "text": "A donzela concebe e dá à luz um filho"},
            {"id": "c", "text": "O filho recebe o nome Emanuel"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S3, "cam", "caminhada", "understand", "05", "complete",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question='Complete a frase: "dará à luz um ___"',
        feedback_correct="Certo: dará à luz um filho.",
        feedback_wrong={
            "a": "Senhor é quem dá o sinal.",
            "c": "Nome vem depois, com Emanuel.",
        },
        template="dará à luz um ___",
        options=[{"id": "a", "text": "Senhor"}, {"id": "b", "text": "filho"}, {"id": "c", "text": "nome"}],
        correct="b",
    ),
    pack(
        S3, "cam", "caminhada", "understand", "06", "connect",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question="O que Isaías 7:14 comunica que se liga a este contexto?",
        feedback_correct="Certo: Deus conosco, contra o cálculo do rei.",
        feedback_wrong={
            "a": "Não é aliança síria.",
            "c": "Não transfere o texto para Isaías 53.",
        },
        passage_a={"ref": "Isaías 7:14", "text": "por-lhe-á o nome de Emanuel."},
        passage_b={"ref": "Contexto", "text": INS3},
        options=[
            {"id": "a", "text": "Aliança com a Síria"},
            {"id": "b", "text": "Deus conosco"},
            {"id": "c", "text": "O Servo de Isaías 53"},
        ],
        correct="b",
    ),
    pack(
        S3, "pro", "profundezas", "interpret", "01", "true_false",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question="O nome Emanuel declara a presença de Deus com o seu povo, como sinal dado pelo Senhor, não como conquista de Acaz.",
        feedback_correct="Certo: Emanuel é Deus conosco, iniciativa do Senhor.",
        feedback_wrong={"false": "O sinal e o nome vêm do Senhor, não da política de Acaz."},
        options=TF, correct="true",
    ),
    pack(
        S3, "pro", "profundezas", "interpret", "02", "tap",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question='Em Isaías 7:14, toque a palavra que falta em "eis que uma donzela ___"?',
        feedback_correct="Exato: uma donzela conceberá.",
        feedback_wrong={
            "a": "Sinal é o que o Senhor dá, não o verbo da donzela.",
            "c": "Nome pertence ao filho Emanuel.",
        },
        template="eis que uma donzela ___",
        options=[{"id": "a", "text": "sinal"}, {"id": "b", "text": "conceberá"}, {"id": "c", "text": "nome"}],
        correct="b",
    ),
    pack(
        S3, "pro", "profundezas", "interpret", "03", "choice",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question="Que implicação Isaías 7:14 impõe, sem confundir o sinal com Isaías 53?",
        feedback_correct="Certo: Deus conosco não depende do cálculo de Acaz.",
        feedback_wrong={
            "b": "Emanuel não prova ausência de Deus até o rei agir.",
            "c": "O filho não anula o Senhor.",
            "d": "Isaías 7:14 não descreve o Servo ferido; isso é 53.",
        },
        options=[
            {"id": "a", "text": "Deus conosco é o sinal, não o cálculo de Acaz"},
            {"id": "b", "text": "Emanuel prova que Deus se ausenta até o rei agir"},
            {"id": "c", "text": "O filho anula o Senhor e torna o sinal só humano"},
            {"id": "d", "text": "Isaías 7:14 descreve o Servo ferido de Isaías 53"},
        ],
        correct="a",
    ),
    pack(
        S3, "pro", "profundezas", "interpret", "04", "order",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question="Qual sequência revela o sentido de Isaías 7:14?",
        feedback_correct="Certo: iniciativa do Senhor, nascimento, Deus conosco.",
        feedback_wrong={
            "b": "Deus conosco não é o primeiro elo sem o sinal.",
            "c": "O nascimento não fecha o sentido antes da presença declarada.",
        },
        options=[
            {"id": "a", "text": "O Senhor toma a iniciativa do sinal"},
            {"id": "b", "text": "Nasce o filho chamado Emanuel"},
            {"id": "c", "text": "Deus está conosco, apesar da incredulidade do rei"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S3, "pro", "profundezas", "interpret", "05", "complete",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question='Complete a frase: "o ___ mesmo vos dará um sinal"',
        feedback_correct="Certo: o Senhor mesmo vos dará um sinal.",
        feedback_wrong={
            "b": "Filho é o conteúdo do sinal.",
            "c": "Emanuel é o nome, não o doador do sinal nesta lacuna.",
        },
        template="o ___ mesmo vos dará um sinal",
        options=[{"id": "a", "text": "Senhor"}, {"id": "b", "text": "filho"}, {"id": "c", "text": "Emanuel"}],
        correct="a",
    ),
    pack(
        S3, "pro", "profundezas", "interpret", "06", "connect",
        verse_ref=VR3, lo=LO3, evidence=EV3, passage=P714,
        question="O que Isaías 7:14 comunica que se liga a este contexto?",
        feedback_correct="Certo: presença dada, não conquista do rei.",
        feedback_wrong={
            "b": "Não é política de Acaz.",
            "c": "Não é o poema do Servo sofredor.",
        },
        passage_a={"ref": "Isaías 7:14", "text": "o Senhor mesmo vos dará um sinal; eis que uma donzela conceberá"},
        passage_b={"ref": "Contexto", "text": INS3},
        options=[
            {"id": "a", "text": "Presença dada pelo Senhor"},
            {"id": "b", "text": "Política de Acaz"},
            {"id": "c", "text": "Poema do Servo"},
        ],
        correct="a",
    ),
]

# ---------------------------------------------------------------------------
# M4 Servo sofredor
# ---------------------------------------------------------------------------
S4 = "isaias-esperanca--02-o-servo-sofredor"
LO4 = "Reconhecer que o Servo é ferido pelas transgressões do povo: leva a iniquidade das ovelhas desgarradas e, nele, há paz e cura."
VR4 = "Isaías 53:5–6"
EV4 = ["Isaías 53:5", "Isaías 53:6"]

bank += [
    pack(
        S4, "sem", "semente", "observe", "01", "true_false",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question="Ele foi ferido por causa das nossas transgressões e esmagado por causa das nossas iniquidades.",
        feedback_correct="Certo: o versículo 5 afirma exatamente isso.",
        feedback_wrong={"false": "O texto diz ferido pelas nossas transgressões e esmagado pelas iniquidades."},
        options=TF, correct="true",
    ),
    pack(
        S4, "sem", "semente", "observe", "02", "tap",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question='Em Isaías 53:5–6, toque a palavra que falta em "pelas suas pisaduras fomos nós ___"?',
        feedback_correct="Exato: fomos nós sarados.",
        feedback_wrong={
            "b": "Ovelhas descreve o povo desgarrado, não esta lacuna.",
            "c": "Caminho é para onde cada um se desviou.",
        },
        template="pelas suas pisaduras fomos nós ___",
        options=[{"id": "a", "text": "sarados"}, {"id": "b", "text": "ovelhas"}, {"id": "c", "text": "caminho"}],
        correct="a",
    ),
    pack(
        S4, "sem", "semente", "observe", "03", "choice",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question="O que o texto afirma sobre o castigo e a paz?",
        feedback_correct="Certo: o castigo que traria a paz caiu sobre ele.",
        feedback_wrong={
            "b": "O castigo caiu sobre ele, não sobre as ovelhas neste verso.",
            "c": "Ele foi ferido por causa das nossas transgressões, não só dos inimigos.",
            "d": "O texto liga pisaduras à cura.",
        },
        options=[
            {"id": "a", "text": "O castigo que nos devia trazer a paz caiu sobre ele"},
            {"id": "b", "text": "O castigo caiu sobre as ovelhas, não sobre ele"},
            {"id": "c", "text": "Ele foi ferido só pelas transgressões dos inimigos"},
            {"id": "d", "text": "Não houve paz nem cura ligadas às pisaduras"},
        ],
        correct="a",
    ),
    pack(
        S4, "sem", "semente", "observe", "04", "order",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question="Qual sequência mostra a ordem dos fatos em Isaías 53:5–6?",
        feedback_correct="Certo: ferido, o castigo da paz sobre ele, a iniquidade de todos nele.",
        feedback_wrong={
            "b": "A iniquidade de todos não abre o v. 5.",
            "c": "O castigo da paz vem depois de ferido, não no fim isolado.",
        },
        options=[
            {"id": "a", "text": "ele foi ferido por causa das nossas transgressões"},
            {"id": "b", "text": "o castigo que nos devia trazer a paz caiu sobre ele"},
            {"id": "c", "text": "Jeová fez cair sobre ele a iniquidade de todos nós"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S4, "sem", "semente", "observe", "05", "complete",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question='Complete a frase: "Todos nós temos andado desgarrados como ___"',
        feedback_correct="Certo: desgarrados como ovelhas.",
        feedback_wrong={
            "b": "Paz é o fruto do castigo sobre ele.",
            "c": "Caminho é para onde cada um se desviou, depois.",
        },
        template="Todos nós temos andado desgarrados como ___",
        options=[{"id": "a", "text": "ovelhas"}, {"id": "b", "text": "paz"}, {"id": "c", "text": "caminho"}],
        correct="a",
    ),
    pack(
        S4, "sem", "semente", "observe", "06", "connect",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question="O que Isaías 53:5–6 comunica que se liga a este contexto?",
        feedback_correct="Certo: o Servo leva a iniquidade das ovelhas.",
        feedback_wrong={
            "b": "Não é o sinal de Emanuel em 7:14.",
            "c": "Não é a visão do trono em Isaías 6.",
        },
        passage_a={"ref": "Isaías 53:5–6", "text": "Jeová fez cair sobre ele a iniquidade de todos nós."},
        passage_b={"ref": "Contexto", "text": INS4},
        options=[
            {"id": "a", "text": "Servo leva a iniquidade"},
            {"id": "b", "text": "Sinal de Emanuel"},
            {"id": "c", "text": "Visão do trono"},
        ],
        correct="a",
    ),
    pack(
        S4, "cam", "caminhada", "understand", "01", "true_false",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question="Cada um permanece no próprio caminho, e Jeová não transfere a iniquidade para o Servo.",
        feedback_correct="Certo em julgar falso: Jeová fez cair sobre ele a iniquidade de todos.",
        feedback_wrong={"true": "O texto diz que Jeová fez cair sobre ele a iniquidade de todos nós."},
        options=TF, correct="false",
    ),
    pack(
        S4, "cam", "caminhada", "understand", "02", "tap",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question='Em Isaías 53:5–6, toque a palavra que falta em "esmagado por causa das nossas ___"?',
        feedback_correct="Exato: esmagado por causa das nossas iniquidades.",
        feedback_wrong={
            "a": "Paz é o que o castigo deveria trazer, não esta lacuna.",
            "c": "Ovelhas descreve o povo desgarrado no v. 6.",
        },
        template="esmagado por causa das nossas ___",
        options=[{"id": "a", "text": "paz"}, {"id": "b", "text": "iniquidades"}, {"id": "c", "text": "ovelhas"}],
        correct="b",
    ),
    pack(
        S4, "cam", "caminhada", "understand", "03", "choice",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question="Como o sofrimento do Servo se relaciona com o povo desgarrado?",
        feedback_correct="Certo: o Servo sofre no lugar do povo desgarrado.",
        feedback_wrong={
            "b": "As ovelhas não carregam sozinhas a iniquidade neste texto.",
            "c": "A paz vem com o castigo caindo sobre ele.",
            "d": "Jeová não deixa o Servo intacto: faz cair sobre ele a iniquidade.",
        },
        options=[
            {"id": "a", "text": "O Servo sofre no lugar do povo desgarrado"},
            {"id": "b", "text": "As ovelhas carregam sozinhas a própria iniquidade"},
            {"id": "c", "text": "A paz vem sem o castigo cair sobre ninguém"},
            {"id": "d", "text": "Jeová ignora o desvio e deixa o Servo intacto"},
        ],
        correct="a",
    ),
    pack(
        S4, "cam", "caminhada", "understand", "04", "order",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question="Como se encadeiam os eventos de Isaías 53:5–6?",
        feedback_correct="Certo: desgarrados, o Servo ferido, paz e cura.",
        feedback_wrong={
            "b": "A cura não precede o desgarrar.",
            "c": "O ferimento do Servo não é o último elo isolado.",
        },
        options=[
            {"id": "a", "text": "O povo anda desgarrado, cada um no seu caminho"},
            {"id": "b", "text": "O Servo é ferido e esmagado por causa disso"},
            {"id": "c", "text": "Paz e cura recaem sobre os que ele representa"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S4, "cam", "caminhada", "understand", "05", "complete",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question='Complete a frase: "Jeová fez cair sobre ele a ___ de todos nós"',
        feedback_correct="Certo: a iniquidade de todos nós.",
        feedback_wrong={
            "b": "Paz é o fruto, não o que cai sobre ele nesta frase.",
            "c": "Ovelhas somos nós, não o que cai sobre o Servo.",
        },
        template="Jeová fez cair sobre ele a ___ de todos nós",
        options=[{"id": "a", "text": "iniquidade"}, {"id": "b", "text": "paz"}, {"id": "c", "text": "ovelhas"}],
        correct="a",
    ),
    pack(
        S4, "cam", "caminhada", "understand", "06", "connect",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question="O que Isaías 53:5–6 comunica que se liga a este contexto?",
        feedback_correct="Certo: a iniquidade nossa cai sobre ele.",
        feedback_wrong={
            "a": "Não é mérito das ovelhas.",
            "c": "Não é o chamado de Isaías 6:8.",
        },
        passage_a={"ref": "Isaías 53:6", "text": "Jeová fez cair sobre ele a iniquidade de todos nós."},
        passage_b={"ref": "Contexto", "text": INS4},
        options=[
            {"id": "a", "text": "Mérito das ovelhas"},
            {"id": "b", "text": "Iniquidade sobre o Servo"},
            {"id": "c", "text": "Chamado de Isaías 6"},
        ],
        correct="b",
    ),
    pack(
        S4, "pro", "profundezas", "interpret", "01", "true_false",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question="A paz e a cura do povo vêm porque o castigo que lhes cabia caiu sobre o Servo.",
        feedback_correct="Certo: o castigo da paz caiu sobre ele; pelas pisaduras fomos sarados.",
        feedback_wrong={"false": "O texto liga paz e cura ao que caiu sobre ele, não às ovelhas sozinhas."},
        options=TF, correct="true",
    ),
    pack(
        S4, "pro", "profundezas", "interpret", "02", "tap",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question='Em Isaías 53:5–6, toque a palavra que falta em "o castigo que nos devia trazer a ___ caiu sobre ele"?',
        feedback_correct="Exato: o castigo que nos devia trazer a paz.",
        feedback_wrong={
            "b": "Ovelhas somos nós no v. 6.",
            "c": "Caminho é o desvio de cada um.",
        },
        template="o castigo que nos devia trazer a ___ caiu sobre ele",
        options=[{"id": "a", "text": "paz"}, {"id": "b", "text": "ovelhas"}, {"id": "c", "text": "caminho"}],
        correct="a",
    ),
    pack(
        S4, "pro", "profundezas", "interpret", "03", "choice",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question="Que leitura teológica Isaías 53:5–6 sustenta sobre a cura?",
        feedback_correct="Certo: a cura não é mérito das ovelhas; o Servo leva a iniquidade.",
        feedback_wrong={
            "b": "As pisaduras não provam que Deus rejeita salvar.",
            "c": "Desgarrar-se não é o caminho da paz.",
            "d": "Jeová faz cair a iniquidade sobre ele, não sobre as ovelhas neste verso.",
        },
        options=[
            {"id": "a", "text": "O Servo leva a iniquidade; a cura não é mérito nosso"},
            {"id": "b", "text": "As pisaduras provam que Deus rejeita salvar o povo"},
            {"id": "c", "text": "Desgarrar-se é o caminho da paz, sem o Servo"},
            {"id": "d", "text": "Jeová faz cair a iniquidade sobre as ovelhas, não sobre ele"},
        ],
        correct="a",
    ),
    pack(
        S4, "pro", "profundezas", "interpret", "04", "order",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question="Qual sequência revela o sentido de Isaías 53:5–6?",
        feedback_correct="Certo: desgarrados, iniquidade no Servo, cura pelas pisaduras.",
        feedback_wrong={
            "b": "A cura não é o primeiro elo.",
            "c": "A iniquidade no Servo não fecha o sentido sem a cura.",
        },
        options=[
            {"id": "a", "text": "Estávamos desgarrados, cada um no seu caminho"},
            {"id": "b", "text": "Jeová fez cair sobre o Servo a iniquidade de todos"},
            {"id": "c", "text": "Pelas pisaduras dele fomos sarados"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S4, "pro", "profundezas", "interpret", "05", "complete",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question='Complete a frase: "ele foi ___ por causa das nossas transgressões"',
        feedback_correct="Certo: ele foi ferido por causa das nossas transgressões.",
        feedback_wrong={
            "b": "Sarados somos nós, pelas pisaduras.",
            "c": "Ovelhas descreve o povo, não o verbo desta lacuna.",
        },
        template="ele foi ___ por causa das nossas transgressões",
        options=[{"id": "a", "text": "ferido"}, {"id": "b", "text": "sarados"}, {"id": "c", "text": "ovelhas"}],
        correct="a",
    ),
    pack(
        S4, "pro", "profundezas", "interpret", "06", "connect",
        verse_ref=VR4, lo=LO4, evidence=EV4, passage=P53,
        question="O que Isaías 53:5–6 comunica que se liga a este contexto?",
        feedback_correct="Certo: ferido por nós; paz e cura sobre ele.",
        feedback_wrong={
            "b": "Não é o sinal de 7:14.",
            "c": "Não é o trono de Isaías 6.",
        },
        passage_a={"ref": "Isaías 53:5", "text": "pelas suas pisaduras fomos nós sarados."},
        passage_b={"ref": "Contexto", "text": INS4},
        options=[
            {"id": "a", "text": "Ferido por nós"},
            {"id": "b", "text": "Emanuel de 7:14"},
            {"id": "c", "text": "Trono de Isaías 6"},
        ],
        correct="a",
    ),
]

# ---------------------------------------------------------------------------
# M5 desafio — combina 6:8; 7:14; 53:5
# ---------------------------------------------------------------------------
S5 = "isaias-esperanca--03-desafio-isaias"
LO5 = "Articular o fio de Isaías: o Santo envia, Emanuel vem, o Servo é ferido por nós."
VR5 = "Isaías 6:8; 7:14; 53:5"
EV5 = ["Isaías 6:8", "Isaías 7:14", "Isaías 53:5"]

bank += [
    pack(
        S5, "sem", "semente", "observe", "01", "true_false",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P68,
        question="Isaías responde à voz de Jeová com Eis-me aqui; envia-me a mim, e o Senhor dá o sinal de Emanuel.",
        feedback_correct="Certo: 6:8 registra o envio; 7:14, o sinal Emanuel.",
        feedback_wrong={"false": "Os dois textos afirmam o envio de Isaías e o sinal Emanuel."},
        options=TF, correct="true",
    ),
    pack(
        S5, "sem", "semente", "observe", "02", "tap",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P68,
        question='Em Isaías 6:8, toque a palavra que falta em "Eis-me aqui; envia-me a ___"?',
        feedback_correct="Exato: envia-me a mim.",
        feedback_wrong={
            "b": "Nós pertence à pergunta de Jeová.",
            "c": "Voz é o que ele ouviu.",
        },
        template="Eis-me aqui; envia-me a ___",
        options=[{"id": "a", "text": "mim"}, {"id": "b", "text": "nós"}, {"id": "c", "text": "voz"}],
        correct="a",
    ),
    pack(
        S5, "sem", "semente", "observe", "03", "choice",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P714,
        question="Qual conjunto os textos de Isaías 6:8, 7:14 e 53:5 afirmam?",
        feedback_correct="Certo: Jeová envia, o sinal é Emanuel, o Servo é ferido por nós.",
        feedback_wrong={
            "b": "Acaz não envia Isaías, nem o Servo fere as ovelhas.",
            "c": "Emanuel não é o nome de Uzias.",
            "d": "O Servo não recusa o envio neste fio.",
        },
        options=[
            {"id": "a", "text": "Jeová envia, o sinal é Emanuel, o Servo é ferido por nós"},
            {"id": "b", "text": "Acaz envia Isaías, e o Servo fere as ovelhas"},
            {"id": "c", "text": "Emanuel é o nome de Uzias no trono"},
            {"id": "d", "text": "O Servo recusa o envio e o sinal não vem"},
        ],
        correct="a",
    ),
    pack(
        S5, "sem", "semente", "observe", "04", "order",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P53,
        question="Qual sequência mostra a ordem dos fatos em Isaías 6:8; 7:14; 53:5?",
        feedback_correct="Certo: envio, Emanuel, o Servo ferido.",
        feedback_wrong={
            "b": "O ferimento do Servo não abre o fio.",
            "c": "Emanuel não é o último elo depois do Servo neste encadeamento.",
        },
        options=[
            {"id": "a", "text": "Disse eu: Eis-me aqui; envia-me a mim"},
            {"id": "b", "text": "uma donzela conceberá, e dará à luz um filho"},
            {"id": "c", "text": "ele foi ferido por causa das nossas transgressões"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S5, "sem", "semente", "observe", "05", "complete",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P714,
        question='Complete a frase: "por-lhe-á o nome de ___"',
        feedback_correct="Certo: o nome é Emanuel.",
        feedback_wrong={
            "b": "Jeová fala em 6:8, não nesta lacuna de 7:14.",
            "c": "Ferido descreve o Servo em 53:5.",
        },
        template="por-lhe-á o nome de ___",
        options=[{"id": "a", "text": "Emanuel"}, {"id": "b", "text": "Jeová"}, {"id": "c", "text": "ferido"}],
        correct="a",
    ),
    pack(
        S5, "sem", "semente", "observe", "06", "connect",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P68,
        question="O que Isaías 6:8; 7:14; 53:5 comunica que se liga a este contexto?",
        feedback_correct="Certo: o Santo envia, Emanuel vem, o Servo é ferido.",
        feedback_wrong={
            "b": "Não é só a morte de Uzias.",
            "c": "Não é tática de Acaz.",
        },
        passage_a={"ref": "Isaías 6:8; 7:14; 53:5", "text": "Eis-me aqui; envia-me. Emanuel. Ferido por nossas transgressões."},
        passage_b={"ref": "Contexto", "text": INS5},
        options=[
            {"id": "a", "text": "Santo envia, Servo ferido"},
            {"id": "b", "text": "Só a morte de Uzias"},
            {"id": "c", "text": "Tática de Acaz"},
        ],
        correct="a",
    ),
    pack(
        S5, "cam", "caminhada", "understand", "01", "true_false",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P714,
        question="Em Isaías, o envio do profeta, o sinal de Emanuel e o sofrimento do Servo são linhas sem relação entre si.",
        feedback_correct="Certo em julgar falso: o fio une envio, Emanuel e Servo.",
        feedback_wrong={"true": "Os três textos se encadeiam: o Santo envia, Emanuel vem, o Servo é ferido."},
        options=TF, correct="false",
    ),
    pack(
        S5, "cam", "caminhada", "understand", "02", "tap",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P714,
        question='Em Isaías 7:14, toque a palavra que falta em "uma donzela conceberá, e dará à luz um ___"?',
        feedback_correct="Exato: dará à luz um filho.",
        feedback_wrong={
            "a": "Sinal é o que o Senhor dá, no início do verso.",
            "c": "Nome vem com Emanuel, depois.",
        },
        template="uma donzela conceberá, e dará à luz um ___",
        options=[{"id": "a", "text": "sinal"}, {"id": "b", "text": "filho"}, {"id": "c", "text": "nome"}],
        correct="b",
    ),
    pack(
        S5, "cam", "caminhada", "understand", "03", "choice",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P53,
        question="Como o Santo que envia se liga a Emanuel e ao Servo ferido?",
        feedback_correct="Certo: o mesmo Deus envia, dá Emanuel e fere o Servo por nós.",
        feedback_wrong={
            "b": "Emanuel não cancela o envio do profeta.",
            "c": "O Servo não sofre para que Jeová deixe de enviar.",
            "d": "O sinal de 7:14 não anula o trono santo de Isaías 6.",
        },
        options=[
            {"id": "a", "text": "O Santo que envia também dá Emanuel e fere o Servo por nós"},
            {"id": "b", "text": "Emanuel substitui o envio: não há mais profeta"},
            {"id": "c", "text": "O Servo sofre para que Jeová não precise enviar ninguém"},
            {"id": "d", "text": "O sinal de 7:14 anula o trono santo de Isaías 6"},
        ],
        correct="a",
    ),
    pack(
        S5, "cam", "caminhada", "understand", "04", "order",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P68,
        question="Como se encadeiam os eventos de Isaías 6:8; 7:14; 53:5?",
        feedback_correct="Certo: o Santo pergunta, Emanuel é dado, o Servo é ferido.",
        feedback_wrong={
            "b": "O Servo ferido não abre este encadeamento.",
            "c": "Emanuel não é o último elo depois do Servo aqui.",
        },
        options=[
            {"id": "a", "text": "O Santo pergunta quem enviará"},
            {"id": "b", "text": "O Senhor dá o filho chamado Emanuel"},
            {"id": "c", "text": "O Servo é ferido por nossas transgressões"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S5, "cam", "caminhada", "understand", "05", "complete",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P53,
        question='Complete a frase: "ele foi ferido por causa das nossas ___"',
        feedback_correct="Certo: ferido por causa das nossas transgressões.",
        feedback_wrong={
            "b": "Donzela pertence a 7:14.",
            "c": "Enviarei pertence a 6:8.",
        },
        template="ele foi ferido por causa das nossas ___",
        options=[{"id": "a", "text": "transgressões"}, {"id": "b", "text": "donzela"}, {"id": "c", "text": "enviarei"}],
        correct="a",
    ),
    pack(
        S5, "cam", "caminhada", "understand", "06", "connect",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P714,
        question="O que Isaías 6:8; 7:14; 53:5 comunica que se liga a este contexto?",
        feedback_correct="Certo: santidade que envia, presença e substituição.",
        feedback_wrong={
            "a": "Não são três livros distintos.",
            "c": "Não é só política de Judá.",
        },
        passage_a={"ref": "Isaías 7:14", "text": "por-lhe-á o nome de Emanuel."},
        passage_b={"ref": "Contexto", "text": INS5},
        options=[
            {"id": "a", "text": "Três livros distintos"},
            {"id": "b", "text": "Envio, presença, substituição"},
            {"id": "c", "text": "Só política de Judá"},
        ],
        correct="b",
    ),
    pack(
        S5, "pro", "profundezas", "interpret", "01", "true_false",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P53,
        question="O fio de Isaías prepara o leitor: o Santo envia, Deus está conosco em Emanuel, e o Servo carrega a iniquidade do povo.",
        feedback_correct="Certo: envio, Emanuel e Servo formam um único fio.",
        feedback_wrong={"false": "Os três textos preparam o leitor para o Santo presente e vicário."},
        options=TF, correct="true",
    ),
    pack(
        S5, "pro", "profundezas", "interpret", "02", "tap",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P53,
        question='Em Isaías 53:5, toque a palavra que falta em "pelas suas ___ fomos nós sarados"?',
        feedback_correct="Exato: pelas suas pisaduras fomos sarados.",
        feedback_wrong={
            "b": "Ovelhas descreve o povo no v. 6.",
            "c": "Paz é o que o castigo deveria trazer.",
        },
        template="pelas suas ___ fomos nós sarados",
        options=[{"id": "a", "text": "pisaduras"}, {"id": "b", "text": "ovelhas"}, {"id": "c", "text": "paz"}],
        correct="a",
    ),
    pack(
        S5, "pro", "profundezas", "interpret", "03", "choice",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P68,
        question="Que sentido teológico une visão, sinal e Servo sem fundir 7:14 com 53?",
        feedback_correct="Certo: Deus santo, presente e vicário — sem misturar os textos.",
        feedback_wrong={
            "b": "7:14 não é o mesmo retrato do Servo ferido no mesmo versículo.",
            "c": "O envio de 6:8 não torna Emanuel desnecessário.",
            "d": "O Servo não sofre porque o Santo falhou em enviar.",
        },
        options=[
            {"id": "a", "text": "Deus santo, presente e vicário, sem fundir 7:14 e 53"},
            {"id": "b", "text": "Isaías 7:14 é o mesmo retrato do Servo ferido, no mesmo verso"},
            {"id": "c", "text": "O envio de 6:8 torna desnecessário o Emanuel"},
            {"id": "d", "text": "O Servo sofre porque o Santo falhou em enviar"},
        ],
        correct="a",
    ),
    pack(
        S5, "pro", "profundezas", "interpret", "04", "order",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P53,
        question="Qual sequência revela o sentido de Isaías 6:8; 7:14; 53:5?",
        feedback_correct="Certo: o Santo chama, Emanuel declara presença, o Servo traz paz.",
        feedback_wrong={
            "b": "A paz do Servo não abre o sentido sem o chamado.",
            "c": "Emanuel não fecha o sentido depois da paz, neste fio.",
        },
        options=[
            {"id": "a", "text": "O Santo chama e envia"},
            {"id": "b", "text": "Emanuel declara Deus conosco"},
            {"id": "c", "text": "O Servo é ferido para nossa paz"},
        ],
        correct="a",
        correct_order=["a", "b", "c"],
    ),
    pack(
        S5, "pro", "profundezas", "interpret", "05", "complete",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P68,
        question='Complete a frase: "Quem enviarei eu, e quem irá por ___?"',
        feedback_correct="Certo: quem irá por nós.",
        feedback_wrong={
            "b": "Emanuel é o nome de 7:14.",
            "c": "Pisaduras pertencem a 53:5.",
        },
        template="Quem enviarei eu, e quem irá por ___?",
        options=[{"id": "a", "text": "nós"}, {"id": "b", "text": "Emanuel"}, {"id": "c", "text": "pisaduras"}],
        correct="a",
    ),
    pack(
        S5, "pro", "profundezas", "interpret", "06", "connect",
        verse_ref=VR5, lo=LO5, evidence=EV5, passage=P53,
        question="O que Isaías 6:8; 7:14; 53:5 comunica que se liga a este contexto?",
        feedback_correct="Certo: o evangelho de Isaías — Santo, Emanuel, Servo.",
        feedback_wrong={
            "b": "Não reduz tudo a 7:14 como se fosse 53.",
            "c": "Não é só juízo sem esperança.",
        },
        passage_a={"ref": "Isaías 53:5", "text": "ele foi ferido por causa das nossas transgressões"},
        passage_b={"ref": "Contexto", "text": INS5},
        options=[
            {"id": "a", "text": "Santo, Emanuel, Servo"},
            {"id": "b", "text": "7:14 igual a 53"},
            {"id": "c", "text": "Só juízo sem esperança"},
        ],
        correct="a",
    ),
]


def main():
    out = Path("/Users/dalwesleyduarte/dev/new/perguntas-v2/isaias.json")
    assert len(bank) == 90, len(bank)
    out.write_text(json.dumps(bank, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(out, len(bank))


if __name__ == "__main__":
    main()
