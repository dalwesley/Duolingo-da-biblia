#!/usr/bin/env python3
"""Gera bancos próprios das trilhas de motivo (sem borrow do cânon).

- ansiedade.json (5×18=90)
- conhecer-a-deus.json (5×18=90)
- entender-a-biblia.json (7×18=126)

Recomeço continua emprestando o cânon no app — não entra aqui.
"""
from __future__ import annotations

import json
from pathlib import Path

OUT = Path(__file__).resolve().parent
TF = [{"id": "true", "text": "Verdadeiro"}, {"id": "false", "text": "Falso"}]


def opts(*pairs):
    return [{"id": i, "text": t} for i, t in pairs]


def item(
    trail,
    section,
    short,
    nn,
    difficulty,
    skill,
    qtype,
    verse_ref,
    lo,
    evidence,
    text,
    fb_ok,
    fb_wrong,
    passage,
    *,
    template=None,
    options=None,
    correct="a",
    correct_order=None,
    passage_a=None,
    passage_b=None,
):
    q = {
        "difficulty": difficulty,
        "skill": skill,
        "verseRef": verse_ref,
        "learningObjective": lo,
        "evidence": evidence,
        "type": qtype,
        "question": text,
        "prompt": text,
        "cue": text,
        "feedbackCorrect": fb_ok,
        "feedbackWrong": fb_wrong,
        "passageText": passage,
        "trail": trail,
        "section": section,
        "id": f"{trail}-{short}-{section}-{nn}",
        "options": options,
        "correctOptionId": correct,
        "correctAnswer": correct,
    }
    if template:
        q["template"] = template
    if correct_order:
        q["correctOrder"] = correct_order
    if passage_a:
        q["passageA"] = passage_a
    if passage_b:
        q["passageB"] = passage_b
    return q


def pack18(trail, section, verse_ref, evidence, passage, lo, insight, modes):
    """modes: dict difficulty -> {tf, tap, choice, order, complete, connect}."""
    skill = {"semente": "observe", "caminhada": "understand", "profundezas": "interpret"}
    short = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}
    out = []
    for diff in ("semente", "caminhada", "profundezas"):
        m = modes[diff]
        sh = short[diff]
        sk = skill[diff]
        # 01 true_false
        tf_ok, tf_stmt, tf_wrong = m["tf"]
        out.append(
            item(
                trail,
                section,
                sh,
                "01",
                diff,
                sk,
                "true_false",
                verse_ref,
                lo,
                evidence,
                tf_stmt,
                (f"Certo: {insight}." if len(f"Certo: {insight}.") <= 100 else "Certo."),
                {"true" if not tf_ok else "false": tf_wrong},
                passage,
                options=TF,
                correct="true" if tf_ok else "false",
            )
        )
        # 02 tap
        tap_word, tap_wrong_b, tap_wrong_c, tap_template, tap_q, tap_fb_ok, tap_fb = m["tap"]
        out.append(
            item(
                trail,
                section,
                sh,
                "02",
                diff,
                sk,
                "tap",
                verse_ref,
                lo,
                evidence,
                tap_q,
                tap_fb_ok,
                {"b": tap_fb[0], "c": tap_fb[1]},
                passage,
                template=tap_template,
                options=opts(("a", tap_word), ("b", tap_wrong_b), ("c", tap_wrong_c)),
                correct="a",
            )
        )
        # 03 choice
        ch_q, ch_opts, ch_correct, ch_fb_ok, ch_fb = m["choice"]
        wrong_fb = {k: v for k, v in ch_fb.items() if k != ch_correct}
        out.append(
            item(
                trail,
                section,
                sh,
                "03",
                diff,
                sk,
                "choice",
                verse_ref,
                lo,
                evidence,
                ch_q,
                ch_fb_ok,
                wrong_fb,
                passage,
                options=opts(*ch_opts),
                correct=ch_correct,
            )
        )
        # 04 order
        ord_q, ord_pieces, ord_fb = m["order"]
        out.append(
            item(
                trail,
                section,
                sh,
                "04",
                diff,
                sk,
                "order",
                verse_ref,
                lo,
                evidence,
                ord_q,
                ord_fb,
                {"b": "A ordem do texto é outra.", "c": "Releia a sequência no texto."},
                passage,
                options=opts(("a", ord_pieces[0]), ("b", ord_pieces[1]), ("c", ord_pieces[2])),
                correct="a",
                correct_order=["a", "b", "c"],
            )
        )
        # 05 complete
        comp_word, comp_b, comp_c, comp_template, comp_q, comp_ok, comp_fb = m["complete"]
        out.append(
            item(
                trail,
                section,
                sh,
                "05",
                diff,
                sk,
                "complete",
                verse_ref,
                lo,
                evidence,
                comp_q,
                comp_ok,
                {"b": comp_fb[0], "c": comp_fb[1]},
                passage,
                template=comp_template,
                options=opts(("a", comp_word), ("b", comp_b), ("c", comp_c)),
                correct="a",
            )
        )
        # 06 connect
        conn_q, conn_opts, conn_correct, conn_ok, conn_fb, pa = m["connect"]
        out.append(
            item(
                trail,
                section,
                sh,
                "06",
                diff,
                sk,
                "connect",
                verse_ref,
                lo,
                evidence,
                conn_q,
                conn_ok,
                {k: v for k, v in conn_fb.items() if k != conn_correct},
                passage,
                options=opts(*conn_opts),
                correct=conn_correct,
                passage_a=pa,
                passage_b={"ref": "Contexto", "text": insight},
            )
        )
    return out


# ─── ANSIEDADE (Paz no dia) ───────────────────────────────────────────────────

P_MT625 = (
    "Não andeis ansiosos pela vossa vida, quanto ao que haveis de comer ou beber; "
    "nem pelo vosso corpo, quanto ao que haveis de vestir. Não é a vida mais do que o alimento, "
    "e o corpo mais do que as vestes? Olhai para as aves do céu: não semeiam, não colhem, "
    "nem ajuntam em celeiros; e vosso Pai celeste as alimenta. Não valeis vós muito mais do que elas?"
)
P_FP412 = (
    "Sei ainda viver na penúria e sei também viver na abundância; em tudo e em todas as coisas, "
    "sei o que é ter fartura e ter fome. Tudo posso naquele que me fortalece."
)
P_SL23 = (
    "O Senhor é o meu pastor; nada me faltará. Ele me faz repousar em pastos verdejantes; "
    "leva-me para junto das águas de descanso. Refrigera-me a alma."
)
P_MT69 = (
    "Pai nosso, que estás nos céus; santificado seja o teu nome; venha o teu reino; "
    "seja feita a tua vontade, assim na terra como no céu. O pão nosso de cada dia nos dá hoje."
)
P_1PE13 = (
    "Bendito o Deus e Pai de nosso Senhor Jesus Cristo, que, segundo a sua grande misericórdia, "
    "nos regenerou para uma viva esperança, pela ressurreição de Jesus Cristo dentre os mortos, "
    "para uma herança incorruptível, incontaminável e imarcescível, reservada nos céus para vós."
)


def ansiedade():
    trail = "ansiedade"
    all_q = []

    # 01
    all_q += pack18(
        trail,
        "dor-ansia-01",
        "Mateus 6:25–26",
        ["Mateus 6:25", "Mateus 6:26"],
        P_MT625,
        "Ver como Jesus liga o cuidado do Pai à ansiedade do amanhã.",
        "O cuidado do Pai desarma a ansiedade",
        {
            "semente": {
                "tf": (
                    True,
                    "Jesus manda não andar ansioso pela vida, quanto ao comer, beber ou vestir.",
                    "O texto de Mateus 6:25 diz exatamente isso.",
                ),
                "tap": (
                    "ansiosos",
                    "celeiros",
                    "aves",
                    "Não andeis ___ pela vossa vida",
                    'Em Mateus 6:25, toque a palavra que falta em "Não andeis ___ pela vossa vida"?',
                    "Exato: não andeis ansiosos.",
                    ("Celeiros aparece depois, sobre as aves.", "Aves é o exemplo, não esta lacuna."),
                ),
                "choice": (
                    "Segundo Mateus 6:25–26, quem alimenta as aves do céu?",
                    (("a", "O Pai celeste"), ("b", "Os celeiros cheios"), ("c", "O próprio esforço delas"), ("d", "Os discípulos")),
                    "a",
                    "Certo: o Pai celeste as alimenta.",
                    {"b": "Elas não ajuntam em celeiros.", "c": "O texto diz que não semeiam nem colhem.", "d": "Não são os discípulos quem as alimentam."},
                ),
                "order": (
                    "Qual a ordem dos fatos em Mateus 6:25–26?",
                    [
                        "Não andeis ansiosos pela vossa vida",
                        "Olhai para as aves do céu",
                        "Vosso Pai celeste as alimenta",
                    ],
                    "Certo: do aviso ao exemplo do Pai.",
                ),
                "complete": (
                    "Pai",
                    "corpo",
                    "celeiros",
                    "e vosso ___ celeste as alimenta",
                    'Complete em Mateus 6:26: "e vosso ___ celeste as alimenta".',
                    "Certo: o Pai celeste.",
                    ("Corpo é o que não se deve vestir com ansiedade.", "Celeiros é o que as aves não têm."),
                ),
                "connect": (
                    "O que Mateus 6:25–26 comunica que se liga a este contexto?",
                    (("a", "Cuidado do Pai"), ("b", "Estoque garantido"), ("c", "Ausência de necessidade")),
                    "a",
                    "Certo: o argumento é o cuidado do Pai.",
                    {"b": "Jesus não promete estoque; aponta o Pai.", "c": "Há necessidade; o que muda é a confiança."},
                    {"ref": "Mateus 6:26", "text": "Vosso Pai celeste as alimenta. Não valeis vós muito mais do que elas?"},
                ),
            },
            "caminhada": {
                "tf": (
                    False,
                    "Jesus ensina que a ansiedade some quando deixamos de ter necessidades.",
                    "O argumento é o cuidado do Pai, não a ausência de necessidade.",
                ),
                "tap": (
                    "alimenta",
                    "semeiam",
                    "colhem",
                    "e vosso Pai celeste as ___",
                    'Em Mateus 6:26, toque a palavra que falta em "e vosso Pai celeste as ___"?',
                    "Exato: as alimenta.",
                    ("Elas não semeiam — isso descreve as aves.", "Colhem também descreve o que elas não fazem."),
                ),
                "choice": (
                    "Por que Jesus aponta as aves no meio do ensino sobre ansiedade?",
                    (
                        ("a", "Para mostrar que o Pai sustenta quem não controla o estoque"),
                        ("b", "Para mandar os discípulos pararem de trabalhar"),
                        ("c", "Para provar que comida nunca falta a ninguém"),
                        ("d", "Para comparar o valor das aves ao dos celeiros"),
                    ),
                    "a",
                    "Certo: o Pai cuida sem celeiro próprio delas.",
                    {
                        "b": "O texto não cancela o trabalho; cancela a ansiedade.",
                        "c": "Não é promessa universal de fartura automática.",
                        "d": "A comparação é com o valor dos discípulos, não dos celeiros.",
                    },
                ),
                "order": (
                    "Como se encadeiam os eventos de Mateus 6:25–26?",
                    [
                        "O aviso contra a ansiedade pela vida",
                        "O exemplo das aves que não ajuntam",
                        "A conclusão: o Pai as alimenta",
                    ],
                    "Certo: aviso → exemplo → Pai.",
                ),
                "complete": (
                    "vida",
                    "vestes",
                    "aves",
                    "Não é a ___ mais do que o alimento",
                    'Complete: "Não é a ___ mais do que o alimento"?',
                    "Certo: a vida vale mais que o alimento.",
                    ("Vestes entra na outra comparação.", "Aves é o exemplo seguinte."),
                ),
                "connect": (
                    "O que Mateus 6:25–26 comunica que se liga a este contexto?",
                    (("a", "Confiança sem estoque"), ("b", "Negação da fome"), ("c", "Culto ao amanhã")),
                    "a",
                    "Certo: confiar no Pai sem viver do celeiro.",
                    {"b": "Jesus não nega a fome; redireciona o medo.", "c": "O culto ao amanhã é o que ele corta."},
                    {"ref": "Mateus 6:25", "text": "Não andeis ansiosos pela vossa vida, quanto ao que haveis de comer ou beber."},
                ),
            },
            "profundezas": {
                "tf": (
                    True,
                    "Em Mateus 6, o antídoto da ansiedade é a confiança no Pai, não o controle total do amanhã.",
                    "O texto aponta o Pai, não o domínio absoluto do futuro.",
                ),
                "tap": (
                    "valeis",
                    "olhai",
                    "ajuntam",
                    "Não ___ vós muito mais do que elas",
                    'Em Mateus 6:26, toque a palavra que falta em "Não ___ vós muito mais do que elas"?',
                    "Exato: não valeis vós muito mais.",
                    ("Olhai inicia o exemplo das aves.", "Ajuntam descreve o que as aves não fazem."),
                ),
                "choice": (
                    "Qual leitura de Mateus 6:25–26 melhor prepara o coração ansioso?",
                    (
                        ("a", "Sou visto e sustentado por um Pai, mesmo sem controlar o estoque"),
                        ("b", "Se eu organizar melhor o celeiro, a ansiedade some sozinha"),
                        ("c", "Preciso valer menos que as aves para ser humilde"),
                        ("d", "A fé cancela qualquer necessidade concreta"),
                    ),
                    "a",
                    "Certo: o valor perante o Pai desarma o medo.",
                    {
                        "b": "O celeiro não é o argumento de Jesus.",
                        "c": "O texto diz o contrário: valeis muito mais.",
                        "d": "A fé não apaga a necessidade; muda o lugar dela.",
                    },
                ),
                "order": (
                    "Qual sequência revela o sentido de Mateus 6:25–26?",
                    [
                        "A ansiedade quer governar o amanhã",
                        "As aves vivem sob o cuidado do Pai",
                        "O discípulo vale mais e pode confiar",
                    ],
                    "Certo: medo → exemplo → valor no Pai.",
                ),
                "complete": (
                    "celeste",
                    "ansiosos",
                    "vestir",
                    "e vosso Pai ___ as alimenta",
                    'Complete: "e vosso Pai ___ as alimenta".',
                    "Certo: Pai celeste.",
                    ("Ansiosos é o verbo do aviso.", "Vestir é um dos temores listados."),
                ),
                "connect": (
                    "O que Mateus 6:25–26 comunica que se liga a este contexto?",
                    (("a", "Valor perante o Pai"), ("b", "Mérito das aves"), ("c", "Fuga da vida real")),
                    "a",
                    "Certo: o valor no Pai sustenta a paz.",
                    {"b": "As aves ilustram cuidado, não mérito.", "c": "Jesus fala dentro da vida real."},
                    {"ref": "Mateus 6:26", "text": "Não valeis vós muito mais do que elas?"},
                ),
            },
        },
    )

    # 02 contentamento
    all_q += pack18(
        trail,
        "dor-ansia-02",
        "Filipenses 4:12–13",
        ["Filipenses 4:12", "Filipenses 4:13"],
        P_FP412,
        "Trocar a ansiedade do ter pelo contentamento em Cristo.",
        "Cristo basta na fome e na fartura",
        {
            "semente": {
                "tf": (
                    True,
                    "Paulo diz que sabe viver na penúria e também na abundância.",
                    "Filipenses 4:12 afirma os dois lados.",
                ),
                "tap": (
                    "fortalece",
                    "penúria",
                    "fartura",
                    "Tudo posso naquele que me ___",
                    'Em Filipenses 4:13, toque a palavra que falta em "Tudo posso naquele que me ___"?',
                    "Exato: que me fortalece.",
                    ("Penúria é uma das situações, não o verbo.", "Fartura também descreve a situação."),
                ),
                "choice": (
                    "Em Filipenses 4:12–13, o que Paulo aprendeu?",
                    (
                        ("a", "Estar contente na penúria e na fartura"),
                        ("b", "Evitar qualquer situação de fome"),
                        ("c", "Depender só da abundância"),
                        ("d", "Negar que já passou necessidade"),
                    ),
                    "a",
                    "Certo: contentamento nos dois extremos.",
                    {"b": "Ele fala de ter fome, não de evitá-la sempre.", "c": "Ele também sabe a penúria.", "d": "Ele admite penúria e fome."},
                ),
                "order": (
                    "Qual a ordem das ideias em Filipenses 4:12–13?",
                    [
                        "Sei viver na penúria e na abundância",
                        "Sei ter fartura e ter fome",
                        "Tudo posso naquele que me fortalece",
                    ],
                    "Certo: situações → extremos → Cristo.",
                ),
                "complete": (
                    "penúria",
                    "fortalece",
                    "posso",
                    "Sei ainda viver na ___ e sei também viver na abundância",
                    'Complete: "Sei ainda viver na ___ e sei também viver na abundância".',
                    "Certo: penúria.",
                    ("Fortalece fecha o v.13.", "Posso é o verbo de 4:13."),
                ),
                "connect": (
                    "O que Filipenses 4:12–13 comunica que se liga a este contexto?",
                    (("a", "Contentamento em Cristo"), ("b", "Promessa de riqueza"), ("c", "Estoicismo sem Deus")),
                    "a",
                    "Certo: Cristo basta nos extremos.",
                    {"b": "Não há promessa de riqueza aqui.", "c": "A força vem daquele que fortalece."},
                    {"ref": "Filipenses 4:13", "text": "Tudo posso naquele que me fortalece."},
                ),
            },
            "caminhada": {
                "tf": (
                    False,
                    "\"Tudo posso\" em Filipenses 4:13 significa realizar qualquer desejo pessoal.",
                    "O contexto é contentamento na fome e na fartura, não autossuficiência.",
                ),
                "tap": (
                    "fome",
                    "abundância",
                    "posso",
                    "sei o que é ter fartura e ter ___",
                    'Em Filipenses 4:12, toque a palavra que falta em "ter fartura e ter ___"?',
                    "Exato: ter fome.",
                    ("Abundância já apareceu antes.", "Posso pertence ao v.13."),
                ),
                "choice": (
                    "Como o contentamento de Paulo se relaciona com a ansiedade do ter?",
                    (
                        ("a", "Cristo sustenta o coração quando o estoque oscila"),
                        ("b", "A paz depende de nunca passar necessidade"),
                        ("c", "A fartura prova que Deus aprova o ansioso"),
                        ("d", "A penúria é sinal de fé superior"),
                    ),
                    "a",
                    "Certo: a estabilidade está em Cristo.",
                    {"b": "Paulo conheceu necessidade.", "c": "Fartura não valida ansiedade.", "d": "Ele não romantiza a penúria."},
                ),
                "order": (
                    "Como se encadeiam os eventos de Filipenses 4:12–13?",
                    [
                        "Paulo conhece falta e fartura",
                        "Ele nomeia fome e abundância",
                        "A força vem daquele que o fortalece",
                    ],
                    "Certo: experiência → extremos → fonte.",
                ),
                "complete": (
                    "abundância",
                    "fome",
                    "misericórdia",
                    "Sei ainda viver na penúria e sei também viver na ___",
                    'Complete: "sei também viver na ___".',
                    "Certo: abundância.",
                    ("Fome entra depois na mesma frase.", "Misericórdia não está neste verso."),
                ),
                "connect": (
                    "O que Filipenses 4:12–13 comunica que se liga a este contexto?",
                    (("a", "Bastaça em Cristo"), ("b", "Fuga da pobreza"), ("c", "Culto à fartura")),
                    "a",
                    "Certo: Cristo basta nos dois polos.",
                    {"b": "Ele não foge da pobreza; aprende nela.", "c": "Fartura também precisa de contentamento."},
                    {"ref": "Filipenses 4:12", "text": "Sei ainda viver na penúria e sei também viver na abundância."},
                ),
            },
            "profundezas": {
                "tf": (
                    True,
                    "O contentamento cristão em Filipenses 4 não é indiferença estoica: é dependência de Cristo.",
                    "A força vem daquele que fortalece — não do eu impassível.",
                ),
                "tap": (
                    "penúria",
                    "fortalece",
                    "mortos",
                    "Sei ainda viver na ___",
                    'Em Filipenses 4:12, toque a palavra que falta em "Sei ainda viver na ___"?',
                    "Exato: penúria.",
                    ("Fortalece é do v.13.", "Mortos não está neste texto."),
                ),
                "choice": (
                    "Qual implicação de Filipenses 4:12–13 para quem vive ansioso com o ter?",
                    (
                        ("a", "A paz não exige cenário estável; exige união com Cristo"),
                        ("b", "Só há paz quando a fartura chega"),
                        ("c", "A fome prova que Cristo falhou"),
                        ("d", "Contentamento é negar a dor da falta"),
                    ),
                    "a",
                    "Certo: o cenário muda; Cristo permanece.",
                    {"b": "Paulo fala também da penúria.", "c": "A fome está dentro do aprendizado.", "d": "Ele nomeia a fome; não a nega."},
                ),
                "order": (
                    "Qual sequência revela o sentido de Filipenses 4:12–13?",
                    [
                        "As circunstâncias oscilam",
                        "O coração aprende contentamento",
                        "A força é recebida de Cristo",
                    ],
                    "Certo: oscilação → aprendizado → fonte.",
                ),
                "complete": (
                    "fortalece",
                    "abundância",
                    "pastor",
                    "Tudo posso naquele que me ___",
                    'Complete: "Tudo posso naquele que me ___".',
                    "Certo: fortalece.",
                    ("Abundância é circunstância, não o verbo.", "Pastor não está neste verso."),
                ),
                "connect": (
                    "O que Filipenses 4:12–13 comunica que se liga a este contexto?",
                    (("a", "Força recebida"), ("b", "Autossuficiência"), ("c", "Negação da fome")),
                    "a",
                    "Certo: a força é recebida daquele que fortalece.",
                    {"b": "Não é eu posso sozinho.", "c": "A fome é confessada."},
                    {"ref": "Filipenses 4:13", "text": "Tudo posso naquele que me fortalece."},
                ),
            },
        },
    )

    # 03 salmo 23
    all_q += pack18(
        trail,
        "dor-ansia-03",
        "Salmo 23:1–3",
        ["Salmo 23:1", "Salmo 23:2", "Salmo 23:3"],
        P_SL23,
        "Ler o Salmo 23 como cuidado do pastor, não como amuleto contra o medo.",
        "Há pastor no vale",
        {
            "semente": {
                "tf": (
                    True,
                    "O salmista diz que o Senhor é o seu pastor e que nada lhe faltará.",
                    "Salmo 23:1 afirma exatamente isso.",
                ),
                "tap": (
                    "pastor",
                    "pastos",
                    "alma",
                    "O Senhor é o meu ___",
                    'Em Salmo 23:1, toque a palavra que falta em "O Senhor é o meu ___"?',
                    "Exato: pastor.",
                    ("Pastos vem no verso seguinte.", "Alma aparece no v.3."),
                ),
                "choice": (
                    "Segundo Salmo 23:1–3, para onde o pastor leva o salmista?",
                    (
                        ("a", "Para pastos verdejantes e águas de descanso"),
                        ("b", "Para um celeiro cheio"),
                        ("c", "Para longe de qualquer vale"),
                        ("d", "Para o trono dos reis"),
                    ),
                    "a",
                    "Certo: pastos e águas de descanso.",
                    {"b": "Não há celeiro no texto.", "c": "O vale virá no salmo; aqui há guia.", "d": "Não é esse o destino nomeado."},
                ),
                "order": (
                    "Qual a ordem dos fatos no Salmo 23:1–3?",
                    [
                        "O Senhor é o meu pastor",
                        "Ele me faz repousar em pastos verdejantes",
                        "Leva-me para junto das águas de descanso",
                    ],
                    "Certo: pastor → pastos → águas.",
                ),
                "complete": (
                    "faltará",
                    "refrigera",
                    "verdejantes",
                    "nada me ___",
                    'Complete: "O Senhor é o meu pastor; nada me ___".',
                    "Certo: nada me faltará.",
                    ("Refrigera é do v.3.", "Verdejantes descreve os pastos."),
                ),
                "connect": (
                    "O que Salmo 23:1–3 comunica que se liga a este contexto?",
                    (("a", "Cuidado que guia"), ("b", "Amuleto mágico"), ("c", "Ausência de luta")),
                    "a",
                    "Certo: o pastor guia e sustenta.",
                    {"b": "Não é fórmula mágica.", "c": "O cuidado não apaga toda luta."},
                    {"ref": "Salmo 23:1", "text": "O Senhor é o meu pastor; nada me faltará."},
                ),
            },
            "caminhada": {
                "tf": (
                    False,
                    "No Salmo 23, \"nada me faltará\" significa que o crente nunca enfrentará necessidade concreta.",
                    "É confiança no pastor, não garantia de cenário fácil.",
                ),
                "tap": (
                    "repousar",
                    "pastor",
                    "alma",
                    "Ele me faz ___ em pastos verdejantes",
                    'Em Salmo 23:2, toque a palavra que falta em "Ele me faz ___ em pastos verdejantes"?',
                    "Exato: repousar.",
                    ("Pastor é do v.1.", "Alma é do v.3."),
                ),
                "choice": (
                    "Como o Salmo 23 responde a um coração ansioso?",
                    (
                        ("a", "Desloca o centro do medo para a presença do pastor"),
                        ("b", "Promete que o vale nunca virá"),
                        ("c", "Ensina a controlar sozinho as águas"),
                        ("d", "Troca o pastor por técnicas de estoque"),
                    ),
                    "a",
                    "Certo: a presença do pastor reordena o medo.",
                    {"b": "O salmo conhece o vale.", "c": "Quem leva é o pastor.", "d": "O centro é o Senhor, não o estoque."},
                ),
                "order": (
                    "Como se encadeiam os eventos de Salmo 23:1–3?",
                    [
                        "Confissão: o Senhor é pastor",
                        "Repouso nos pastos",
                        "Condução às águas e refrigério da alma",
                    ],
                    "Certo: confissão → repouso → refrigério.",
                ),
                "complete": (
                    "descanso",
                    "pastor",
                    "céus",
                    "leva-me para junto das águas de ___",
                    'Complete: "águas de ___".',
                    "Certo: águas de descanso.",
                    ("Pastor é o título do Senhor.", "Céus não está neste trecho."),
                ),
                "connect": (
                    "O que Salmo 23:1–3 comunica que se liga a este contexto?",
                    (("a", "Presença que guia"), ("b", "Controle do vale"), ("c", "Fuga do corpo")),
                    "a",
                    "Certo: presença do pastor no caminho.",
                    {"b": "O salmista não controla o vale.", "c": "O cuidado é concreto, no corpo e no caminho."},
                    {"ref": "Salmo 23:2", "text": "Ele me faz repousar em pastos verdejantes."},
                ),
            },
            "profundezas": {
                "tf": (
                    True,
                    "O Salmo 23 apresenta o Senhor como pastor presente: a paz vem da condução dele, não da ausência de caminho difícil.",
                    "O pastor age no caminho — pastos, águas, alma.",
                ),
                "tap": (
                    "Refrigera",
                    "pastos",
                    "faltará",
                    "___-me a alma",
                    'Em Salmo 23:3, toque a palavra que falta em "___-me a alma"?',
                    "Exato: Refrigera-me a alma.",
                    ("Pastos é do v.2.", "Faltará é do v.1."),
                ),
                "choice": (
                    "Qual leitura teológica do Salmo 23:1–3 melhor desarma a ansiedade?",
                    (
                        ("a", "Sou conduzido por alguém; não carrego sozinho o amanhã"),
                        ("b", "Se eu memorizar o salmo, nada mau me alcança"),
                        ("c", "O pastor só age quando o estoque está cheio"),
                        ("d", "A alma se refrigera sem necessidade de guia"),
                    ),
                    "a",
                    "Certo: ser conduzido muda o peso do amanhã.",
                    {"b": "Não é amuleto.", "c": "O pastor age na falta e no caminho.", "d": "Quem refrigera é o Senhor."},
                ),
                "order": (
                    "Qual sequência revela o sentido de Salmo 23:1–3?",
                    [
                        "Reconhecer o pastor",
                        "Aceitar o repouso que ele dá",
                        "Receber o refrigério da alma",
                    ],
                    "Certo: reconhecer → repousar → ser refrigerado.",
                ),
                "complete": (
                    "verdejantes",
                    "incorruptível",
                    "ansiosos",
                    "pastos ___",
                    'Complete: "pastos ___".',
                    "Certo: pastos verdejantes.",
                    ("Incorruptível é de 1 Pedro.", "Ansiosos é de Mateus 6."),
                ),
                "connect": (
                    "O que Salmo 23:1–3 comunica que se liga a este contexto?",
                    (("a", "Guia no caminho"), ("b", "Garantia sem pastor"), ("c", "Vale sem presença")),
                    "a",
                    "Certo: há guia no caminho.",
                    {"b": "Sem pastor não há a promessa do salmo.", "c": "A presença é o centro."},
                    {"ref": "Salmo 23:3", "text": "Refrigera-me a alma."},
                ),
            },
        },
    )

    # 04 pai nosso
    all_q += pack18(
        trail,
        "dor-ansia-04",
        "Mateus 6:9–11",
        ["Mateus 6:9", "Mateus 6:10", "Mateus 6:11"],
        P_MT69,
        "Orar o pão de hoje e o Reino antes do estoque do medo.",
        "O pão é de hoje",
        {
            "semente": {
                "tf": (
                    True,
                    "Jesus ensina a pedir: o pão nosso de cada dia nos dá hoje.",
                    "Mateus 6:11 traz exatamente esse pedido.",
                ),
                "tap": (
                    "hoje",
                    "céus",
                    "reino",
                    "o pão nosso de cada dia nos dá ___",
                    'Em Mateus 6:11, toque a palavra que falta em "nos dá ___"?',
                    "Exato: hoje.",
                    ("Céus aparece no início da oração.", "Reino é o pedido anterior."),
                ),
                "choice": (
                    "Na oração de Mateus 6:9–11, o que se pede sobre o pão?",
                    (
                        ("a", "O pão de cada dia, hoje"),
                        ("b", "O estoque de todo o ano"),
                        ("c", "Pão somente no céu"),
                        ("d", "Pão em troca de mérito"),
                    ),
                    "a",
                    "Certo: pão de cada dia, hoje.",
                    {"b": "Não é pedido de estoque anual.", "c": "O pedido é para hoje.", "d": "Não há troca de mérito no texto."},
                ),
                "order": (
                    "Qual a ordem dos pedidos em Mateus 6:9–11?",
                    [
                        "Santificado seja o teu nome",
                        "Venha o teu reino",
                        "O pão nosso de cada dia nos dá hoje",
                    ],
                    "Certo: nome → reino → pão.",
                ),
                "complete": (
                    "reino",
                    "pão",
                    "medo",
                    "venha o teu ___",
                    'Complete: "venha o teu ___".',
                    "Certo: reino.",
                    ("Pão vem depois.", "Medo não está na oração."),
                ),
                "connect": (
                    "O que Mateus 6:9–11 comunica que se liga a este contexto?",
                    (("a", "Dia confiado ao Pai"), ("b", "Censo do amanhã"), ("c", "Nome esquecido")),
                    "a",
                    "Certo: o dia se pede ao Pai.",
                    {"b": "O pedido é hoje, não o censo do medo.", "c": "O nome é santificado primeiro."},
                    {"ref": "Mateus 6:11", "text": "O pão nosso de cada dia nos dá hoje."},
                ),
            },
            "caminhada": {
                "tf": (
                    False,
                    "Em Mateus 6:9–11, o pão vem antes do nome e do reino na ordem dos pedidos.",
                    "Primeiro o nome e o reino; depois o pão de hoje.",
                ),
                "tap": (
                    "santificado",
                    "terra",
                    "pão",
                    "___ seja o teu nome",
                    'Em Mateus 6:9, toque a palavra que falta em "___ seja o teu nome"?',
                    "Exato: santificado.",
                    ("Terra aparece na vontade feita.", "Pão é o pedido do v.11."),
                ),
                "choice": (
                    "Por que pedir o pão \"hoje\" desarma a ansiedade?",
                    (
                        ("a", "Treina o coração a depender do Pai no dia presente"),
                        ("b", "Proíbe qualquer planejamento futuro"),
                        ("c", "Garante que nunca haverá fome"),
                        ("d", "Substitui o Reino por necessidades"),
                    ),
                    "a",
                    "Certo: dependência no dia presente.",
                    {"b": "Não cancela planejamento responsável.", "c": "Não é garantia automática.", "d": "O Reino vem antes do pão."},
                ),
                "order": (
                    "Como se encadeiam os eventos de Mateus 6:9–11?",
                    [
                        "Invocar o Pai nos céus",
                        "Pedir que o Reino venha",
                        "Pedir o pão de hoje",
                    ],
                    "Certo: Pai → Reino → pão.",
                ),
                "complete": (
                    "vontade",
                    "ansiedade",
                    "fartura",
                    "seja feita a tua ___",
                    'Complete: "seja feita a tua ___".',
                    "Certo: vontade.",
                    ("Ansiedade não está na oração.", "Fartura não está no pedido."),
                ),
                "connect": (
                    "O que Mateus 6:9–11 comunica que se liga a este contexto?",
                    (("a", "Reino antes do pão"), ("b", "Pão antes do Pai"), ("c", "Medo como oração")),
                    "a",
                    "Certo: o Reino ordena o pedido do pão.",
                    {"b": "O Pai e o Reino vêm antes.", "c": "A oração não cultiva o medo."},
                    {"ref": "Mateus 6:10", "text": "Venha o teu reino; seja feita a tua vontade."},
                ),
            },
            "profundezas": {
                "tf": (
                    True,
                    "Pedir o pão de hoje é exercício de confiança: o discípulo entrega o dia ao Pai antes de inventariar o medo.",
                    "O pedido diário forma confiança, não censo ansioso.",
                ),
                "tap": (
                    "céus",
                    "hoje",
                    "nome",
                    "que estás nos ___",
                    'Em Mateus 6:9, toque a palavra que falta em "que estás nos ___"?',
                    "Exato: céus.",
                    ("Hoje fecha o pedido do pão.", "Nome vem na frase seguinte."),
                ),
                "choice": (
                    "Qual leitura de Mateus 6:9–11 melhor forma um dia sem domínio da ansiedade?",
                    (
                        ("a", "O Reino define a prioridade; o pão se pede como filho, não como pânico"),
                        ("b", "Só o pão importa; nome e reino são adorno"),
                        ("c", "Orar o dia elimina a necessidade de trabalhar"),
                        ("d", "O Pai só ouve quem já resolveu o amanhã"),
                    ),
                    "a",
                    "Certo: prioridade do Reino e pedido filial.",
                    {"b": "Nome e reino vêm primeiro.", "c": "Oração não cancela trabalho.", "d": "Pedimos justamente o que não controlamos."},
                ),
                "order": (
                    "Qual sequência revela o sentido de Mateus 6:9–11?",
                    [
                        "Reconhecer o Pai",
                        "Desejar o Reino e a vontade dele",
                        "Receber o dia como dom",
                    ],
                    "Certo: Pai → Reino → dia.",
                ),
                "complete": (
                    "pão",
                    "vale",
                    "pastor",
                    "O ___ nosso de cada dia nos dá hoje",
                    'Complete: "O ___ nosso de cada dia nos dá hoje".',
                    "Certo: pão.",
                    ("Vale é linguagem do Salmo 23.", "Pastor também."),
                ),
                "connect": (
                    "O que Mateus 6:9–11 comunica que se liga a este contexto?",
                    (("a", "Confiança diária"), ("b", "Estoque sagrado"), ("c", "Reino adiado")),
                    "a",
                    "Certo: confiança pedida a cada dia.",
                    {"b": "Não há estoque sagrado no pedido.", "c": "O Reino se pede agora."},
                    {"ref": "Mateus 6:11", "text": "O pão nosso de cada dia nos dá hoje."},
                ),
            },
        },
    )

    # 05 esperança
    all_q += pack18(
        trail,
        "dor-ansia-05",
        "1 Pedro 1:3–4",
        ["1 Pedro 1:3", "1 Pedro 1:4"],
        P_1PE13,
        "Ancorar a esperança na ressurreição e na herança guardada, não no controle do medo.",
        "A herança está guardada",
        {
            "semente": {
                "tf": (
                    True,
                    "Deus nos regenerou para uma viva esperança pela ressurreição de Jesus Cristo.",
                    "1 Pedro 1:3 afirma regeneração e esperança viva.",
                ),
                "tap": (
                    "esperança",
                    "herança",
                    "céus",
                    "nos regenerou para uma viva ___",
                    'Em 1 Pedro 1:3, toque a palavra que falta em "uma viva ___"?',
                    "Exato: esperança.",
                    ("Herança vem no v.4.", "Céus é onde a herança está reservada."),
                ),
                "choice": (
                    "Segundo 1 Pedro 1:3–4, onde está reservada a herança?",
                    (
                        ("a", "Nos céus"),
                        ("b", "No templo de Jerusalém"),
                        ("c", "No estoque do discípulo"),
                        ("d", "No vale do medo"),
                    ),
                    "a",
                    "Certo: reservada nos céus.",
                    {"b": "Não é o templo.", "c": "Não depende do estoque humano.", "d": "Não é no vale."},
                ),
                "order": (
                    "Qual a ordem das ideias em 1 Pedro 1:3–4?",
                    [
                        "Bendito o Deus e Pai",
                        "Regenerou-nos para uma viva esperança",
                        "Para uma herança reservada nos céus",
                    ],
                    "Certo: bênção → esperança → herança.",
                ),
                "complete": (
                    "misericórdia",
                    "ansiedade",
                    "penúria",
                    "segundo a sua grande ___",
                    'Complete: "segundo a sua grande ___".',
                    "Certo: misericórdia.",
                    ("Ansiedade não está no verso.", "Penúria é de Filipenses."),
                ),
                "connect": (
                    "O que 1 Pedro 1:3–4 comunica que se liga a este contexto?",
                    (("a", "Esperança guardada"), ("b", "Herança frágil"), ("c", "Ressurreição negada")),
                    "a",
                    "Certo: esperança viva e herança guardada.",
                    {"b": "A herança é incorruptível.", "c": "A esperança vem pela ressurreição."},
                    {"ref": "1 Pedro 1:3", "text": "nos regenerou para uma viva esperança, pela ressurreição de Jesus Cristo."},
                ),
            },
            "caminhada": {
                "tf": (
                    False,
                    "A herança de 1 Pedro 1:4 é corruptível e depende do humor do dia.",
                    "O texto a chama de incorruptível, incontaminável e imarcescível.",
                ),
                "tap": (
                    "herança",
                    "esperança",
                    "pastor",
                    "para uma ___ incorruptível",
                    'Em 1 Pedro 1:4, toque a palavra que falta em "para uma ___ incorruptível"?',
                    "Exato: herança.",
                    ("Esperança é do v.3.", "Pastor não está neste texto."),
                ),
                "choice": (
                    "Como a esperança viva de 1 Pedro enfrenta a ansiedade?",
                    (
                        ("a", "Ancora o coração numa herança que o dia não rouba"),
                        ("b", "Promete que o sofrimento nunca virá"),
                        ("c", "Substitui a ressurreição por otimismo"),
                        ("d", "Guarda a herança no celeiro humano"),
                    ),
                    "a",
                    "Certo: herança reservada fora do alcance do medo.",
                    {"b": "Pedro escreve a quem sofre.", "c": "A base é a ressurreição.", "d": "A reserva é nos céus."},
                ),
                "order": (
                    "Como se encadeiam os eventos de 1 Pedro 1:3–4?",
                    [
                        "Misericórdia do Pai",
                        "Nova vida e esperança pela ressurreição",
                        "Herança guardada nos céus",
                    ],
                    "Certo: misericórdia → esperança → herança.",
                ),
                "complete": (
                    "ressurreição",
                    "penúria",
                    "reino",
                    "pela ___ de Jesus Cristo dentre os mortos",
                    'Complete: "pela ___ de Jesus Cristo".',
                    "Certo: ressurreição.",
                    ("Penúria é de Filipenses.", "Reino é de Mateus 6."),
                ),
                "connect": (
                    "O que 1 Pedro 1:3–4 comunica que se liga a este contexto?",
                    (("a", "Âncora além do dia"), ("b", "Controle do amanhã"), ("c", "Herança na terra só")),
                    "a",
                    "Certo: âncora que o dia não move.",
                    {"b": "Não é controle; é esperança.", "c": "A reserva é nos céus."},
                    {"ref": "1 Pedro 1:4", "text": "herança incorruptível… reservada nos céus para vós."},
                ),
            },
            "profundezas": {
                "tf": (
                    True,
                    "A esperança cristã em 1 Pedro 1 não nega o sofrimento: ancora o crente na ressurreição e na herança reservada.",
                    "Esperança viva nasce da ressurreição, não da negação da dor.",
                ),
                "tap": (
                    "incorruptível",
                    "ansiosos",
                    "pastos",
                    "herança ___",
                    'Em 1 Pedro 1:4, toque a palavra que falta em "herança ___"?',
                    "Exato: incorruptível.",
                    ("Ansiosos é de Mateus 6.", "Pastos é do Salmo 23."),
                ),
                "choice": (
                    "Qual implicação de 1 Pedro 1:3–4 para quem sai da trilha da ansiedade?",
                    (
                        ("a", "Posso seguir no currículo com herança já guardada, não com medo no comando"),
                        ("b", "Só continuo se o cenário estiver estável"),
                        ("c", "A esperança substitui a necessidade de Cristo"),
                        ("d", "A herança cancela a caminhada presente"),
                    ),
                    "a",
                    "Certo: herança guardada libera o próximo passo.",
                    {"b": "A esperança sustenta na instabilidade.", "c": "A esperança vem de Cristo.", "d": "A herança anima a caminhada."},
                ),
                "order": (
                    "Qual sequência revela o sentido de 1 Pedro 1:3–4?",
                    [
                        "Deus age por misericórdia",
                        "A ressurreição gera esperança viva",
                        "A herança segura o futuro do crente",
                    ],
                    "Certo: misericórdia → ressurreição → herança.",
                ),
                "complete": (
                    "céus",
                    "celeiros",
                    "penúria",
                    "reservada nos ___ para vós",
                    'Complete: "reservada nos ___ para vós".',
                    "Certo: céus.",
                    ("Celeiros é linguagem de Mateus 6.", "Penúria é de Filipenses."),
                ),
                "connect": (
                    "O que 1 Pedro 1:3–4 comunica que se liga a este contexto?",
                    (("a", "Futuro guardado"), ("b", "Medo como herança"), ("c", "Ressurreição opcional")),
                    "a",
                    "Certo: o futuro está guardado no Pai.",
                    {"b": "A herança não é o medo.", "c": "A esperança depende da ressurreição."},
                    {"ref": "1 Pedro 1:3–4", "text": "viva esperança… herança… reservada nos céus."},
                ),
            },
        },
    )

    return all_q


def write_bank(name: str, questions: list):
    path = OUT / f"{name}.json"
    path.write_text(json.dumps(questions, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    sections = {}
    for q in questions:
        sections.setdefault(q["section"], 0)
        sections[q["section"]] += 1
    print(f"{path.name}: {len(questions)} perguntas | {sections}")
    assert all(v == 18 for v in sections.values()), sections
    assert all(q["trail"] == name for q in questions)


if __name__ == "__main__":
    write_bank("ansiedade", ansiedade())
    # Demais motivos: ver _gen_conhecer_a_deus.py e _gen_entender_a_biblia.py
    print("ansiedade ok")
