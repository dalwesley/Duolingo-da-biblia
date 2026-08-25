#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Gera perguntas-v2/_part_sermao-c.json — 11 missões × 18 = 198
(sm-boss-04 … sm-boss-06). TB verbatim do pack."""
import json
from pathlib import Path

TRAIL = "sermao-do-monte"
OUT = Path(__file__).resolve().parent / "_part_sermao-c.json"
TF = [{"id": "true", "text": "Verdadeiro"}, {"id": "false", "text": "Falso"}]
SK = {"semente": "observe", "caminhada": "understand", "profundezas": "interpret"}
SHORT = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}


def opt(*pairs):
    return [{"id": i, "text": t} for i, t in pairs]


def make(
    section,
    vref,
    evid,
    lo,
    passage,
    difficulty,
    typ,
    nn,
    question,
    fc,
    fw,
    options,
    correct,
    *,
    template=None,
    correct_order=None,
    passage_a=None,
    passage_b=None,
):
    assert len(fc) <= 100, (len(fc), fc)
    for o in options:
        if typ == "choice":
            assert len(o["text"]) <= 90, (o["text"], len(o["text"]))
        if typ == "tap":
            assert o["text"] in passage, (o["text"], passage[:80])
    q = {
        "difficulty": difficulty,
        "skill": SK[difficulty],
        "verseRef": vref,
        "learningObjective": lo,
        "evidence": evid,
        "type": typ,
        "question": question,
        "prompt": question,
        "cue": question,
        "feedbackCorrect": fc,
        "feedbackWrong": fw,
        "options": options,
        "correctOptionId": correct,
        "correctAnswer": correct,
        "passageText": passage,
        "trail": TRAIL,
        "section": section,
        "id": f"{TRAIL}-{SHORT[difficulty]}-{section}-{nn}",
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


def pack(section, vref, evid, lo, passage, insight, rows):
    out = []
    for difficulty, typ, nn, kw in rows:
        pa = pb = None
        item_passage = kw.pop("passage", passage)
        if typ == "connect":
            pa = {"ref": vref, "text": kw.pop("pa_text", item_passage[:140])}
            pb = {"ref": "Contexto", "text": insight}
        out.append(
            make(
                section,
                vref,
                evid,
                lo,
                item_passage,
                difficulty,
                typ,
                nn,
                kw["question"],
                kw["fc"],
                kw["fw"],
                kw["options"],
                kw["correct"],
                template=kw.get("template"),
                correct_order=kw.get("correct_order"),
                passage_a=pa,
                passage_b=pb,
            )
        )
    return out


# ── TB verbatim from pack ──────────────────────────────────────────
PB4 = (
    "Eu, porém, vos digo: Amai os vossos inimigos e orai pelos que vos perseguem, "
    "para que vos torneis filhos de vosso Pai, que está nos céus, porque ele faz nascer "
    "o seu sol sobre maus e bons e vir chuvas sobre justos e injustos."
)
P18 = (
    "Tu, porém, quando dás esmola, não saiba a tua mão esquerda o que faz a tua direita, "
    "para que a tua esmola fique em secreto; e teu Pai, que vê em secreto, te retribuirá."
)
P19 = (
    "Portanto, orai vós deste modo: Pai nosso, que estás nos céus; santificado seja o teu nome; "
    "venha o teu reino; seja feita a tua vontade, assim na terra como no céu."
)
P20 = (
    "Tu, porém, quando jejuas, unge a cabeça e lava o rosto, para não mostrar aos homens "
    "que jejuas, mas somente a teu Pai, que está em secreto; e teu Pai, que vê em secreto, te retribuirá."
)
P21 = (
    "Mas buscai primeiramente o seu reino e a sua justiça, e todas essas coisas vos serão acrescentadas."
)
# boss-05: pack parcial (6:9) + 6:33 verbatim do pack sm-21
P69 = "Portanto, orai vós deste modo: Pai nosso, que estás nos céus; santificado seja o teu nome;"
PB5 = P69 + " " + P21
P22 = (
    "Não julgueis, para que não sejais julgados; porque, com o juízo com que julgais, "
    "sereis julgados; e a medida de que usais, dessa usarão convosco."
)
P23 = "Pedi, e dar-se-vos-á; buscai, e achareis; batei, e abrir-se-vos-á."
P24 = (
    "Entrai pela porta estreita (larga é a porta e espaçosa a estrada que conduz à perdição, "
    "e muitos são os que entram por ela), porque estreita é a porta, e apertada, a estrada "
    "que conduz à vida, e poucos são os que acertam com ela."
)
P25 = (
    "Todo aquele, pois, que ouve essas minhas palavras e as observa será comparado a um homem "
    "prudente, que edificou a sua casa sobre a rocha. Desceu a chuva, vieram as torrentes, "
    "sopraram os ventos e deram com ímpeto contra aquela casa, e ela não caiu; pois estava "
    "edificada sobre a rocha."
)
PB6 = P25


def mission_boss_04():
    sec = "sm-boss-04-relacoes-do-reino"
    vr = "Mateus 5:44–48"
    ev = ["Mateus 5:44", "Mateus 5:45"]
    lo = "Reconhecer que amar inimigos e orar pelos perseguidores revela filhos do Pai."
    ins = "Relações do reino: amar inimigos."
    p = PB4
    return pack(
        sec, vr, ev, lo, p, ins,
        [
            ("semente", "true_false", "01", dict(
                question="Jesus manda amar os inimigos e orar pelos que perseguem.",
                fc="Certo: é a ordem literal do texto.",
                fw={"false": "O texto diz: amai os inimigos e orai pelos perseguidores."},
                options=TF, correct="true",
            )),
            ("semente", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "Amai os vossos ___"?',
                fc="Exato: inimigos.",
                fw={"b": "Perseguem descreve a ação contra vós.", "c": "Filhos é o resultado."},
                options=opt(("a", "inimigos"), ("b", "perseguem"), ("c", "filhos")),
                correct="a", template="Amai os vossos ___",
            )),
            ("semente", "choice", "03", dict(
                question="O que o texto ordena fazer pelos que perseguem?",
                fc="Certo: orar por eles.",
                fw={
                    "b": "O texto manda orar, não amaldiçoar.",
                    "c": "Não há ordem de vingança.",
                    "d": "A resposta é oração, não silêncio.",
                },
                options=opt(
                    ("a", "Orar por eles"),
                    ("b", "Amaldiçoá-los em público"),
                    ("c", "Vingar-se com a mesma medida"),
                    ("d", "Ignorá-los completamente"),
                ),
                correct="a",
            )),
            ("semente", "order", "04", dict(
                question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                fc="Certo: amar, orar e tornar-se filhos do Pai.",
                fw={
                    "b": "A oração pelos perseguidores vem junto do amor.",
                    "c": "Ser filhos do Pai é o propósito declarado.",
                },
                options=opt(
                    ("a", "Amai os vossos inimigos"),
                    ("b", "orai pelos que vos perseguem"),
                    ("c", "para que vos torneis filhos de vosso Pai"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("semente", "complete", "05", dict(
                question='Complete: "orai pelos que vos ___"',
                fc="Certo: perseguem.",
                fw={"b": "Inimigos é o objeto do amor.", "c": "Filhos é o resultado."},
                options=opt(("a", "perseguem"), ("b", "inimigos"), ("c", "filhos")),
                correct="a", template="orai pelos que vos ___",
            )),
            ("semente", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: relações do reino passam por amar inimigos.",
                fw={"b": "Não é ódio santo.", "c": "Não é indiferença."},
                options=opt(
                    ("a", "Amar inimigos"),
                    ("b", "Ódio justificado"),
                    ("c", "Indiferença aos perseguidores"),
                ),
                correct="a",
                pa_text="Amai os vossos inimigos e orai pelos que vos perseguem",
            )),
            ("caminhada", "true_false", "01", dict(
                question="Segundo o texto, o Pai só faz nascer o sol sobre os justos e bons.",
                fc="Certo que é falso: o sol nasce sobre maus e bons.",
                fw={"true": "O texto diz sol sobre maus e bons, chuva sobre justos e injustos."},
                options=TF, correct="false",
            )),
            ("caminhada", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "para que vos torneis ___ de vosso Pai"?',
                fc="Exato: filhos.",
                fw={"b": "Inimigos é quem se deve amar.", "c": "Céus é onde o Pai está."},
                options=opt(("a", "filhos"), ("b", "inimigos"), ("c", "céus")),
                correct="a", template="para que vos torneis ___ de vosso Pai",
            )),
            ("caminhada", "choice", "03", dict(
                question="Como o texto liga amor aos inimigos e o caráter do Pai?",
                fc="Certo: o amor aos inimigos espelha a generosidade do Pai.",
                fw={
                    "a": "O Pai não restringe sol e chuva aos justos.",
                    "c": "O alvo é parecer-se com o Pai, não só evitar conflito.",
                    "d": "Há conexão explícita com o Pai nos céus.",
                },
                options=opt(
                    ("a", "O Pai só abençoa quem já é justo"),
                    ("b", "Amar inimigos reflete a generosidade do Pai"),
                    ("c", "O objetivo é só evitar brigas humanas"),
                    ("d", "Não há ligação com o caráter do Pai"),
                ),
                correct="b",
            )),
            ("caminhada", "order", "04", dict(
                question=f"Como se encadeiam os eventos de {vr}?",
                fc="Certo: ordem de amar, propósito filial e prova da generosidade do Pai.",
                fw={
                    "b": "O propósito filial vem após a ordem.",
                    "c": "Sol e chuva ilustram a generosidade do Pai.",
                },
                options=opt(
                    ("a", "Amai os vossos inimigos e orai pelos que vos perseguem"),
                    ("b", "para que vos torneis filhos de vosso Pai"),
                    ("c", "ele faz nascer o seu sol sobre maus e bons"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("caminhada", "complete", "05", dict(
                question='Complete: "ele faz nascer o seu sol sobre maus e ___"',
                fc="Certo: bons.",
                fw={"b": "Injustos acompanha as chuvas.", "c": "Justos também acompanha as chuvas."},
                options=opt(("a", "bons"), ("b", "injustos"), ("c", "justos")),
                correct="a", template="ele faz nascer o seu sol sobre maus e ___",
            )),
            ("caminhada", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: o discípulo imita a generosidade do Pai.",
                fw={"a": "Não é reciprocidade seletiva.", "c": "Não é amor só aos amigos."},
                options=opt(
                    ("a", "Reciprocidade seletiva"),
                    ("b", "Imitar a generosidade do Pai"),
                    ("c", "Amar só quem recompensa"),
                ),
                correct="b",
                pa_text="ele faz nascer o seu sol sobre maus e bons",
            )),
            ("profundezas", "true_false", "01", dict(
                question="Amar inimigos revela filiação ao Pai, cuja bondade alcança maus e bons.",
                fc="Certo: o texto une ética do reino e caráter do Pai.",
                fw={"false": "O propósito é tornar-se filhos do Pai generoso."},
                options=TF, correct="true",
            )),
            ("profundezas", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "vir chuvas sobre justos e ___"?',
                fc="Exato: injustos.",
                fw={"b": "Maus acompanha o sol.", "c": "Bons também acompanha o sol."},
                options=opt(("a", "injustos"), ("b", "maus"), ("c", "bons")),
                correct="a", template="vir chuvas sobre justos e ___",
            )),
            ("profundezas", "choice", "03", dict(
                question="Qual sentido teológico Mateus 5:44–48 sustenta?",
                fc="Certo: o reino chama a amar como o Pai ama, inclusive inimigos.",
                fw={
                    "a": "O texto não autoriza vingança piedosa.",
                    "c": "Filiação se mostra no amor generoso, não no ódio.",
                    "d": "Há comando claro de orar pelos perseguidores.",
                },
                options=opt(
                    ("a", "Vingança santa prova fidelidade ao Pai"),
                    ("b", "Filhos do Pai amam inimigos como Ele é generoso"),
                    ("c", "Ódio aos inimigos é sinal de santidade"),
                    ("d", "Oração pelos perseguidores é opcional"),
                ),
                correct="b",
            )),
            ("profundezas", "order", "04", dict(
                question=f"Qual sequência revela o sentido de {vr}?",
                fc="Certo: amar inimigos, filiação e generosidade imparcial do Pai.",
                fw={
                    "b": "A filiação explica o porquê do amor.",
                    "c": "Sol e chuva revelam o caráter do Pai.",
                },
                options=opt(
                    ("a", "Amai os vossos inimigos e orai pelos que vos perseguem"),
                    ("b", "para que vos torneis filhos de vosso Pai"),
                    ("c", "sol sobre maus e bons e chuvas sobre justos e injustos"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("profundezas", "complete", "05", dict(
                question='Complete: "que está nos ___, porque ele faz nascer o seu sol"',
                fc="Certo: céus.",
                fw={"b": "Inimigos é o objeto do amor.", "c": "Perseguem descreve a oposição."},
                options=opt(("a", "céus"), ("b", "inimigos"), ("c", "perseguem")),
                correct="a", template="que está nos ___, porque ele faz nascer o seu sol",
            )),
            ("profundezas", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: relações do reino espelham o Pai que ama sem parcialidade.",
                fw={"a": "Não é ética de clã.", "b": "Não é amor condicionado."},
                options=opt(
                    ("a", "Ética de clã"),
                    ("b", "Amor só aos aliados"),
                    ("c", "Relações do reino: amar inimigos"),
                ),
                correct="c",
                pa_text="Amai os vossos inimigos… filhos de vosso Pai",
            )),
        ],
    )


def mission_18():
    sec = "sm-18-esmola-secreta"
    vr = "Mateus 6:3–4"
    ev = ["Mateus 6:3", "Mateus 6:4"]
    lo = "Reconhecer que a esmola deve ficar em secreto, perante o Pai que retribui."
    ins = "Esmola em secreto; o Pai retribui."
    p = P18
    return pack(
        sec, vr, ev, lo, p, ins,
        [
            ("semente", "true_false", "01", dict(
                question="Quando dás esmola, não saiba a tua mão esquerda o que faz a tua direita.",
                fc="Certo: é a afirmação literal do texto.",
                fw={"false": "O texto manda esconder a esmola até da própria mão esquerda."},
                options=TF, correct="true",
            )),
            ("semente", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "para que a tua esmola fique em ___"?',
                fc="Exato: secreto.",
                fw={"b": "Direita é a mão que dá.", "c": "Pai é quem vê."},
                options=opt(("a", "secreto"), ("b", "direita"), ("c", "Pai")),
                correct="a", template="para que a tua esmola fique em ___",
            )),
            ("semente", "choice", "03", dict(
                question="Quem, segundo o texto, vê a esmola em secreto e retribui?",
                fc="Certo: teu Pai, que vê em secreto.",
                fw={
                    "b": "Não é a multidão que retribui.",
                    "c": "Não é a mão esquerda.",
                    "d": "O texto aponta o Pai.",
                },
                options=opt(
                    ("a", "Teu Pai, que vê em secreto"),
                    ("b", "A multidão que observa"),
                    ("c", "A mão esquerda que registra"),
                    ("d", "Os discípulos em público"),
                ),
                correct="a",
            )),
            ("semente", "order", "04", dict(
                question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                fc="Certo: dar esmola, manter em secreto e o Pai retribuir.",
                fw={
                    "b": "O secreto segue a ação de dar.",
                    "c": "A retribuição do Pai fecha o texto.",
                },
                options=opt(
                    ("a", "quando dás esmola, não saiba a tua mão esquerda"),
                    ("b", "para que a tua esmola fique em secreto"),
                    ("c", "teu Pai, que vê em secreto, te retribuirá"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("semente", "complete", "05", dict(
                question='Complete: "não saiba a tua mão ___ o que faz a tua direita"',
                fc="Certo: esquerda.",
                fw={"b": "Secreto é o modo.", "c": "Direita é a outra mão."},
                options=opt(("a", "esquerda"), ("b", "secreto"), ("c", "direita")),
                correct="a", template="não saiba a tua mão ___ o que faz a tua direita",
            )),
            ("semente", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: esmola em secreto; o Pai retribui.",
                fw={"b": "Não é exibição pública.", "c": "Não é busca de aplauso."},
                options=opt(
                    ("a", "Esmola em secreto"),
                    ("b", "Esmola para aplauso"),
                    ("c", "Doação para status"),
                ),
                correct="a",
                pa_text="para que a tua esmola fique em secreto; e teu Pai… te retribuirá",
            )),
            ("caminhada", "true_false", "01", dict(
                question="O texto recomenda anunciar a esmola para que todos saibam da generosidade.",
                fc="Certo que é falso: a esmola deve ficar em secreto.",
                fw={"true": "O texto esconde a esmola e aponta o Pai que vê em secreto."},
                options=TF, correct="false",
            )),
            ("caminhada", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "teu Pai, que vê em secreto, te ___"?',
                fc="Exato: retribuirá.",
                fw={"b": "Esmola é o ato.", "c": "Esquerda é a mão que não deve saber."},
                options=opt(("a", "retribuirá"), ("b", "esmola"), ("c", "esquerda")),
                correct="a", template="teu Pai, que vê em secreto, te ___",
            )),
            ("caminhada", "choice", "03", dict(
                question="Como o texto relaciona esmola e audiência?",
                fc="Certo: a esmola não deve buscar audiência humana, mas o Pai.",
                fw={
                    "a": "O texto não valoriza a exibição.",
                    "c": "A mão esquerda ilustra o máximo de discrição.",
                    "d": "Há retribuição divina, não aplauso.",
                },
                options=opt(
                    ("a", "A esmola deve ser anunciada para inspirar"),
                    ("b", "A esmola fica em secreto perante o Pai"),
                    ("c", "A mão esquerda deve publicizar o ato"),
                    ("d", "O aplauso humano substitui a retribuição"),
                ),
                correct="b",
            )),
            ("caminhada", "order", "04", dict(
                question=f"Como se encadeiam os eventos de {vr}?",
                fc="Certo: instrução ao dar, discrição das mãos e retribuição do Pai.",
                fw={
                    "b": "A discrição das mãos vem no meio.",
                    "c": "O Pai que vê fecha o encadeamento.",
                },
                options=opt(
                    ("a", "Tu, porém, quando dás esmola"),
                    ("b", "não saiba a tua mão esquerda o que faz a tua direita"),
                    ("c", "teu Pai, que vê em secreto, te retribuirá"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("caminhada", "complete", "05", dict(
                question='Complete: "e teu Pai, que vê em ___, te retribuirá"',
                fc="Certo: secreto.",
                fw={"b": "Esquerda é a mão.", "c": "Direita é a outra mão."},
                options=opt(("a", "secreto"), ("b", "esquerda"), ("c", "direita")),
                correct="a", template="e teu Pai, que vê em ___, te retribuirá",
            )),
            ("caminhada", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: generosidade diante do Pai, sem teatro.",
                fw={"a": "Não é marketing da fé.", "c": "Não é mérito público."},
                options=opt(
                    ("a", "Marketing da fé"),
                    ("b", "Generosidade sem teatro"),
                    ("c", "Mérito público"),
                ),
                correct="b",
                pa_text="não saiba a tua mão esquerda… teu Pai… te retribuirá",
            )),
            ("profundezas", "true_false", "01", dict(
                question="A esmola secreta forma discípulos que buscam o olhar do Pai, não o aplauso.",
                fc="Certo: o texto desloca a recompensa para o Pai que vê em secreto.",
                fw={"false": "O contraste com a exibição está implícito na ordem de secreto."},
                options=TF, correct="true",
            )),
            ("profundezas", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "quando dás ___, não saiba a tua mão esquerda"?',
                fc="Exato: esmola.",
                fw={"b": "Secreto é o modo.", "c": "Pai é quem vê."},
                options=opt(("a", "esmola"), ("b", "secreto"), ("c", "Pai")),
                correct="a", template="quando dás ___, não saiba a tua mão esquerda",
            )),
            ("profundezas", "choice", "03", dict(
                question="Qual sentido teológico Mateus 6:3–4 sustenta?",
                fc="Certo: a piedade verdadeira busca o Pai, não a plateia.",
                fw={
                    "a": "O secreto não anula a generosidade.",
                    "c": "A retribuição vem do Pai, não do status.",
                    "d": "Há ética clara contra a ostentação.",
                },
                options=opt(
                    ("a", "Só importa esconder; dar é irrelevante"),
                    ("b", "Piedade verdadeira busca o Pai, não a plateia"),
                    ("c", "Status religioso substitui a retribuição divina"),
                    ("d", "Ostentar esmola prova espiritualidade"),
                ),
                correct="b",
            )),
            ("profundezas", "order", "04", dict(
                question=f"Qual sequência revela o sentido de {vr}?",
                fc="Certo: dar, esconder e ser visto pelo Pai.",
                fw={
                    "b": "O secreto protege a intenção.",
                    "c": "O Pai que vê é o centro da recompensa.",
                },
                options=opt(
                    ("a", "quando dás esmola"),
                    ("b", "fique em secreto"),
                    ("c", "teu Pai, que vê em secreto, te retribuirá"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("profundezas", "complete", "05", dict(
                question='Complete: "o que faz a tua ___, para que a tua esmola fique em secreto"',
                fc="Certo: direita.",
                fw={"b": "Esquerda não deve saber.", "c": "Secreto é o destino da esmola."},
                options=opt(("a", "direita"), ("b", "esquerda"), ("c", "secreto")),
                correct="a", template="o que faz a tua ___, para que a tua esmola fique em secreto",
            )),
            ("profundezas", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: esmola em secreto; o Pai retribui.",
                fw={"a": "Não é espetáculo.", "b": "Não é barganha humana."},
                options=opt(
                    ("a", "Esmola como espetáculo"),
                    ("b", "Barganha por fama"),
                    ("c", "Esmola em secreto; o Pai retribui"),
                ),
                correct="c",
                pa_text="tua esmola fique em secreto; e teu Pai… te retribuirá",
            )),
        ],
    )


def mission_19():
    sec = "sm-19-pai-nosso"
    vr = "Mateus 6:9–10"
    ev = ["Mateus 6:9", "Mateus 6:10"]
    lo = "Reconhecer a oração modelo: Pai nosso, nome santificado, reino e vontade."
    ins = "Pai nosso: nome, reino, vontade."
    p = P19
    return pack(
        sec, vr, ev, lo, p, ins,
        [
            ("semente", "true_false", "01", dict(
                question="Jesus ensina a orar: Pai nosso, que estás nos céus.",
                fc="Certo: é o início literal da oração modelo.",
                fw={"false": "O texto abre com Pai nosso nos céus."},
                options=TF, correct="true",
            )),
            ("semente", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "santificado seja o teu ___"?',
                fc="Exato: nome.",
                fw={"b": "Reino vem em seguida.", "c": "Céus é onde o Pai está."},
                options=opt(("a", "nome"), ("b", "reino"), ("c", "céus")),
                correct="a", template="santificado seja o teu ___",
            )),
            ("semente", "choice", "03", dict(
                question="O que o texto pede logo após santificar o nome?",
                fc="Certo: venha o teu reino.",
                fw={
                    "b": "A vontade vem depois do reino.",
                    "c": "Não começa pedindo bens.",
                    "d": "O reino é pedido explícito.",
                },
                options=opt(
                    ("a", "Venha o teu reino"),
                    ("b", "Só a vontade, sem o reino"),
                    ("c", "Riquezas na terra"),
                    ("d", "Fama entre os homens"),
                ),
                correct="a",
            )),
            ("semente", "order", "04", dict(
                question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                fc="Certo: nome, reino e vontade.",
                fw={
                    "b": "O reino segue o nome santificado.",
                    "c": "A vontade fecha o pedido inicial.",
                },
                options=opt(
                    ("a", "santificado seja o teu nome"),
                    ("b", "venha o teu reino"),
                    ("c", "seja feita a tua vontade"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("semente", "complete", "05", dict(
                question='Complete: "venha o teu ___; seja feita a tua vontade"',
                fc="Certo: reino.",
                fw={"b": "Nome vem antes.", "c": "Céu fecha a comparação."},
                options=opt(("a", "reino"), ("b", "nome"), ("c", "céu")),
                correct="a", template="venha o teu ___; seja feita a tua vontade",
            )),
            ("semente", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: Pai nosso — nome, reino, vontade.",
                fw={"b": "Não é lista de pedidos egoístas.", "c": "Não é oração ao próprio eu."},
                options=opt(
                    ("a", "Nome, reino, vontade"),
                    ("b", "Pedidos só pessoais"),
                    ("c", "Oração centrada em si"),
                ),
                correct="a",
                pa_text="Pai nosso… santificado seja o teu nome; venha o teu reino",
            )),
            ("caminhada", "true_false", "01", dict(
                question="Na oração modelo, a vontade de Deus fica só no céu, nunca na terra.",
                fc="Certo que é falso: pede-se a vontade na terra como no céu.",
                fw={"true": "O texto diz: assim na terra como no céu."},
                options=TF, correct="false",
            )),
            ("caminhada", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "assim na terra como no ___"?',
                fc="Exato: céu.",
                fw={"b": "Reino é o pedido anterior.", "c": "Nome é o primeiro pedido."},
                options=opt(("a", "céu"), ("b", "reino"), ("c", "nome")),
                correct="a", template="assim na terra como no ___",
            )),
            ("caminhada", "choice", "03", dict(
                question="Como o texto ordena as prioridades da oração?",
                fc="Certo: primeiro a glória e o reinado de Deus, depois a vontade na terra.",
                fw={
                    "a": "Não começa por necessidades materiais.",
                    "c": "Há ordem clara: nome, reino, vontade.",
                    "d": "O Pai é o centro, não o eu.",
                },
                options=opt(
                    ("a", "Começa pedindo bens materiais"),
                    ("b", "Prioriza nome, reino e vontade de Deus"),
                    ("c", "A ordem dos pedidos é indiferente"),
                    ("d", "O centro da oração é o desejo humano"),
                ),
                correct="b",
            )),
            ("caminhada", "order", "04", dict(
                question=f"Como se encadeiam os eventos de {vr}?",
                fc="Certo: invocação ao Pai, santificação do nome e pedido do reino.",
                fw={
                    "b": "O nome santificado vem após a invocação.",
                    "c": "O reino segue o nome.",
                },
                options=opt(
                    ("a", "Pai nosso, que estás nos céus"),
                    ("b", "santificado seja o teu nome"),
                    ("c", "venha o teu reino"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("caminhada", "complete", "05", dict(
                question='Complete: "seja feita a tua ___, assim na terra como no céu"',
                fc="Certo: vontade.",
                fw={"b": "Nome já foi pedido.", "c": "Reino também já foi pedido."},
                options=opt(("a", "vontade"), ("b", "nome"), ("c", "reino")),
                correct="a", template="seja feita a tua ___, assim na terra como no céu",
            )),
            ("caminhada", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: orar alinhado ao Pai — nome, reino e vontade.",
                fw={"a": "Não é formulário mágico.", "c": "Não é oração egocêntrica."},
                options=opt(
                    ("a", "Fórmula mágica vazia"),
                    ("b", "Alinhar-se ao Pai"),
                    ("c", "Oração egocêntrica"),
                ),
                correct="b",
                pa_text="santificado seja o teu nome; venha o teu reino; seja feita a tua vontade",
            )),
            ("profundezas", "true_false", "01", dict(
                question="A oração modelo forma discípulos que colocam o reinado de Deus antes de si.",
                fc="Certo: nome, reino e vontade priorizam Deus sobre o eu.",
                fw={"false": "A ordem dos pedidos revela essa prioridade."},
                options=TF, correct="true",
            )),
            ("profundezas", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "Pai ___, que estás nos céus"?',
                fc="Exato: nosso.",
                fw={"b": "Nome vem depois.", "c": "Reino vem depois."},
                options=opt(("a", "nosso"), ("b", "nome"), ("c", "reino")),
                correct="a", template="Pai ___, que estás nos céus",
            )),
            ("profundezas", "choice", "03", dict(
                question="Qual sentido teológico Mateus 6:9–10 sustenta?",
                fc="Certo: orar é submeter-se ao Pai cujo nome, reino e vontade vêm primeiro.",
                fw={
                    "a": "Não é técnica de manipular Deus.",
                    "c": "Há comunhão filial e missão do reino.",
                    "d": "A terra deve refletir o céu, não o contrário.",
                },
                options=opt(
                    ("a", "Oração é técnica para controlar Deus"),
                    ("b", "Oração submete-se ao nome, reino e vontade do Pai"),
                    ("c", "O reino de Deus não interessa na oração"),
                    ("d", "A terra dita a vontade que o céu deve seguir"),
                ),
                correct="b",
            )),
            ("profundezas", "order", "04", dict(
                question=f"Qual sequência revela o sentido de {vr}?",
                fc="Certo: Pai, nome santificado e vontade na terra como no céu.",
                fw={
                    "b": "Santificar o nome orienta a oração.",
                    "c": "A vontade na terra aplica o reinado.",
                },
                options=opt(
                    ("a", "Pai nosso, que estás nos céus"),
                    ("b", "santificado seja o teu nome"),
                    ("c", "seja feita a tua vontade, assim na terra como no céu"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("profundezas", "complete", "05", dict(
                question='Complete: "orai vós deste ___: Pai nosso, que estás nos céus"',
                fc="Certo: modo.",
                fw={"b": "Nome é o pedido.", "c": "Reino é o pedido seguinte."},
                options=opt(("a", "modo"), ("b", "nome"), ("c", "reino")),
                correct="a", template="orai vós deste ___: Pai nosso, que estás nos céus",
            )),
            ("profundezas", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: Pai nosso — nome, reino, vontade.",
                fw={"a": "Não é lista de desejos.", "b": "Não é oração sem Pai."},
                options=opt(
                    ("a", "Lista de desejos"),
                    ("b", "Oração sem Pai"),
                    ("c", "Pai nosso: nome, reino, vontade"),
                ),
                correct="c",
                pa_text="Pai nosso… venha o teu reino; seja feita a tua vontade",
            )),
        ],
    )


def mission_20():
    sec = "sm-20-jejum-secreto"
    vr = "Mateus 6:17–18"
    ev = ["Mateus 6:17", "Mateus 6:18"]
    lo = "Reconhecer que o jejum se dirige ao Pai em secreto, não à plateia."
    ins = "Jejum ao Pai que vê em secreto."
    p = P20
    return pack(
        sec, vr, ev, lo, p, ins,
        [
            ("semente", "true_false", "01", dict(
                question="Quando jejuas, unge a cabeça e lava o rosto.",
                fc="Certo: é a instrução literal do texto.",
                fw={"false": "O texto manda ungir a cabeça e lavar o rosto."},
                options=TF, correct="true",
            )),
            ("semente", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "para não mostrar aos ___ que jejuas"?',
                fc="Exato: homens.",
                fw={"b": "Pai é a audiência correta.", "c": "Secreto é o modo."},
                options=opt(("a", "homens"), ("b", "Pai"), ("c", "secreto")),
                correct="a", template="para não mostrar aos ___ que jejuas",
            )),
            ("semente", "choice", "03", dict(
                question="A quem o jejum deve ser mostrado, segundo o texto?",
                fc="Certo: somente a teu Pai, que está em secreto.",
                fw={
                    "b": "Não aos homens.",
                    "c": "Não à multidão.",
                    "d": "O Pai em secreto é o alvo.",
                },
                options=opt(
                    ("a", "Somente a teu Pai, em secreto"),
                    ("b", "Aos homens na praça"),
                    ("c", "À multidão religiosa"),
                    ("d", "A ninguém, nem ao Pai"),
                ),
                correct="a",
            )),
            ("semente", "order", "04", dict(
                question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                fc="Certo: jejuar, não mostrar aos homens e o Pai retribuir.",
                fw={
                    "b": "O ocultar aos homens vem no meio.",
                    "c": "A retribuição do Pai fecha.",
                },
                options=opt(
                    ("a", "quando jejuas, unge a cabeça e lava o rosto"),
                    ("b", "para não mostrar aos homens que jejuas"),
                    ("c", "teu Pai, que vê em secreto, te retribuirá"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("semente", "complete", "05", dict(
                question='Complete: "unge a cabeça e lava o ___"',
                fc="Certo: rosto.",
                fw={"b": "Homens é quem não deve ver.", "c": "Secreto é o modo."},
                options=opt(("a", "rosto"), ("b", "homens"), ("c", "secreto")),
                correct="a", template="unge a cabeça e lava o ___",
            )),
            ("semente", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: jejum ao Pai que vê em secreto.",
                fw={"b": "Não é jejum para plateia.", "c": "Não é ostentação."},
                options=opt(
                    ("a", "Jejum ao Pai em secreto"),
                    ("b", "Jejum para plateia"),
                    ("c", "Ostentação religiosa"),
                ),
                correct="a",
                pa_text="somente a teu Pai, que está em secreto",
            )),
            ("caminhada", "true_false", "01", dict(
                question="O texto manda aparentar sofrimento no jejum para impressionar os homens.",
                fc="Certo que é falso: não se deve mostrar aos homens que se jejua.",
                fw={"true": "Unge e lava o rosto para não exibir o jejum."},
                options=TF, correct="false",
            )),
            ("caminhada", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "mas somente a teu Pai, que está em ___"?',
                fc="Exato: secreto.",
                fw={"b": "Homens é quem não deve ver.", "c": "Rosto é o que se lava."},
                options=opt(("a", "secreto"), ("b", "homens"), ("c", "rosto")),
                correct="a", template="mas somente a teu Pai, que está em ___",
            )),
            ("caminhada", "choice", "03", dict(
                question="Como o texto relaciona aparência e audiência no jejum?",
                fc="Certo: a aparência normal esconde o jejum dos homens e o dirige ao Pai.",
                fw={
                    "a": "Não há incentivo à cara triste.",
                    "c": "O Pai, não a plateia, é a audiência.",
                    "d": "Há retribuição divina, não aplauso.",
                },
                options=opt(
                    ("a", "Aparência triste prova espiritualidade"),
                    ("b", "Aparência normal dirige o jejum ao Pai"),
                    ("c", "A plateia deve notar o esforço"),
                    ("d", "O aplauso humano é a recompensa"),
                ),
                correct="b",
            )),
            ("caminhada", "order", "04", dict(
                question=f"Como se encadeiam os eventos de {vr}?",
                fc="Certo: jejum, discrição perante homens e retribuição do Pai.",
                fw={
                    "b": "A discrição vem após a ação de jejuar.",
                    "c": "O Pai que vê fecha o texto.",
                },
                options=opt(
                    ("a", "Tu, porém, quando jejuas"),
                    ("b", "para não mostrar aos homens que jejuas"),
                    ("c", "teu Pai, que vê em secreto, te retribuirá"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("caminhada", "complete", "05", dict(
                question='Complete: "teu Pai, que vê em secreto, te ___"',
                fc="Certo: retribuirá.",
                fw={"b": "Homens não retribui.", "c": "Cabeça é o que se unge."},
                options=opt(("a", "retribuirá"), ("b", "homens"), ("c", "cabeça")),
                correct="a", template="teu Pai, que vê em secreto, te ___",
            )),
            ("caminhada", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: jejum discreto perante o Pai.",
                fw={"a": "Não é teatro.", "c": "Não é mérito público."},
                options=opt(
                    ("a", "Jejum como teatro"),
                    ("b", "Jejum discreto ao Pai"),
                    ("c", "Mérito público"),
                ),
                correct="b",
                pa_text="para não mostrar aos homens… teu Pai… te retribuirá",
            )),
            ("profundezas", "true_false", "01", dict(
                question="O jejum secreto treina o discípulo a viver perante o Pai, não perante a fama.",
                fc="Certo: a audiência correta é o Pai que vê em secreto.",
                fw={"false": "O contraste com mostrar aos homens sustenta essa leitura."},
                options=TF, correct="true",
            )),
            ("profundezas", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "unge a ___ e lava o rosto"?',
                fc="Exato: cabeça.",
                fw={"b": "Rosto é o que se lava.", "c": "Homens não deve ver."},
                options=opt(("a", "cabeça"), ("b", "rosto"), ("c", "homens")),
                correct="a", template="unge a ___ e lava o rosto",
            )),
            ("profundezas", "choice", "03", dict(
                question="Qual sentido teológico Mateus 6:17–18 sustenta?",
                fc="Certo: disciplina espiritual genuína busca o Pai, não reconhecimento.",
                fw={
                    "a": "O jejum não é anulado; muda a audiência.",
                    "c": "Há rejeição clara da ostentação.",
                    "d": "A retribuição vem do Pai.",
                },
                options=opt(
                    ("a", "Jejum deve ser abandonado por completo"),
                    ("b", "Disciplina genuína busca o Pai, não reconhecimento"),
                    ("c", "Ostentar jejum é virtude espiritual"),
                    ("d", "Homens devem validar o jejum"),
                ),
                correct="b",
            )),
            ("profundezas", "order", "04", dict(
                question=f"Qual sequência revela o sentido de {vr}?",
                fc="Certo: jejuar, ocultar dos homens e ser visto pelo Pai.",
                fw={
                    "b": "Ocultar dos homens protege a intenção.",
                    "c": "O Pai que vê é o centro.",
                },
                options=opt(
                    ("a", "quando jejuas"),
                    ("b", "para não mostrar aos homens"),
                    ("c", "somente a teu Pai, que está em secreto"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("profundezas", "complete", "05", dict(
                question='Complete: "mas somente a teu ___, que está em secreto"',
                fc="Certo: Pai.",
                fw={"b": "Homens é quem não deve ver.", "c": "Rosto é o que se lava."},
                options=opt(("a", "Pai"), ("b", "homens"), ("c", "rosto")),
                correct="a", template="mas somente a teu ___, que está em secreto",
            )),
            ("profundezas", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: jejum ao Pai que vê em secreto.",
                fw={"a": "Não é performance.", "b": "Não é jejum sem Pai."},
                options=opt(
                    ("a", "Performance religiosa"),
                    ("b", "Jejum sem Pai"),
                    ("c", "Jejum ao Pai que vê em secreto"),
                ),
                correct="c",
                pa_text="somente a teu Pai… te retribuirá",
            )),
        ],
    )


def mission_21():
    sec = "sm-21-tesouros-e-ansiedade"
    vr = "Mateus 6:33"
    ev = ["Mateus 6:33"]
    lo = "Reconhecer o chamado a buscar primeiro o reino e a justiça de Deus."
    ins = "Buscai primeiro o reino e a sua justiça."
    p = P21
    return pack(
        sec, vr, ev, lo, p, ins,
        [
            ("semente", "true_false", "01", dict(
                question="Buscai primeiramente o seu reino e a sua justiça.",
                fc="Certo: é a ordem literal do versículo.",
                fw={"false": "O texto manda buscar primeiro reino e justiça."},
                options=TF, correct="true",
            )),
            ("semente", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "buscai primeiramente o seu ___"?',
                fc="Exato: reino.",
                fw={"b": "Justiça vem em seguida.", "c": "Coisas são acrescentadas depois."},
                options=opt(("a", "reino"), ("b", "justiça"), ("c", "coisas")),
                correct="a", template="buscai primeiramente o seu ___",
            )),
            ("semente", "choice", "03", dict(
                question="O que o texto promete após buscar reino e justiça?",
                fc="Certo: todas essas coisas vos serão acrescentadas.",
                fw={
                    "b": "Há promessa de acréscimo.",
                    "c": "Não diz que nada será dado.",
                    "d": "O acréscimo segue a prioridade correta.",
                },
                options=opt(
                    ("a", "Todas essas coisas serão acrescentadas"),
                    ("b", "Nenhuma necessidade será suprida"),
                    ("c", "Só fama religiosa será dada"),
                    ("d", "O reino substitui toda provisão"),
                ),
                correct="a",
            )),
            ("semente", "order", "04", dict(
                question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                fc="Certo: buscar reino, justiça e então o acréscimo.",
                fw={
                    "b": "Justiça acompanha o reino.",
                    "c": "O acréscimo fecha a promessa.",
                },
                options=opt(
                    ("a", "buscai primeiramente o seu reino"),
                    ("b", "e a sua justiça"),
                    ("c", "todas essas coisas vos serão acrescentadas"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("semente", "complete", "05", dict(
                question='Complete: "e a sua ___, e todas essas coisas vos serão acrescentadas"',
                fc="Certo: justiça.",
                fw={"b": "Reino vem primeiro.", "c": "Coisas são o acréscimo."},
                options=opt(("a", "justiça"), ("b", "reino"), ("c", "coisas")),
                correct="a", template="e a sua ___, e todas essas coisas vos serão acrescentadas",
            )),
            ("semente", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: buscar primeiro o reino e a justiça.",
                fw={"b": "Não é ansiedade primeiro.", "c": "Não é tesouro sem reino."},
                options=opt(
                    ("a", "Reino e justiça primeiro"),
                    ("b", "Ansiedade primeiro"),
                    ("c", "Tesouro sem reino"),
                ),
                correct="a",
                pa_text="buscai primeiramente o seu reino e a sua justiça",
            )),
            ("caminhada", "true_false", "01", dict(
                question="Segundo Mateus 6:33, as necessidades vêm antes do reino de Deus.",
                fc="Certo que é falso: o reino e a justiça vêm primeiramente.",
                fw={"true": "O advérbio primeiramente inverte essa ordem."},
                options=TF, correct="false",
            )),
            ("caminhada", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "todas essas coisas vos serão ___"?',
                fc="Exato: acrescentadas.",
                fw={"b": "Reino é o que se busca.", "c": "Justiça acompanha o reino."},
                options=opt(("a", "acrescentadas"), ("b", "reino"), ("c", "justiça")),
                correct="a", template="todas essas coisas vos serão ___",
            )),
            ("caminhada", "choice", "03", dict(
                question="Como o texto relaciona prioridade e provisão?",
                fc="Certo: provisão segue a busca prioritária do reino e da justiça.",
                fw={
                    "a": "Não inverte a ordem.",
                    "c": "Há promessa condicionada à prioridade.",
                    "d": "Reino e justiça não são opcionais.",
                },
                options=opt(
                    ("a", "Provisão vem antes; o reino fica para depois"),
                    ("b", "Provisão segue a busca prioritária do reino"),
                    ("c", "Não há ligação entre prioridade e provisão"),
                    ("d", "Buscar o reino é opcional se houver ansiedade"),
                ),
                correct="b",
            )),
            ("caminhada", "order", "04", dict(
                question=f"Como se encadeiam os eventos de {vr}?",
                fc="Certo: ordem de buscar, conteúdo (reino e justiça) e promessa.",
                fw={
                    "b": "Reino e justiça são o conteúdo da busca.",
                    "c": "O acréscimo é a promessa.",
                },
                options=opt(
                    ("a", "Mas buscai primeiramente"),
                    ("b", "o seu reino e a sua justiça"),
                    ("c", "todas essas coisas vos serão acrescentadas"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("caminhada", "complete", "05", dict(
                question='Complete: "Mas buscai ___ o seu reino e a sua justiça"',
                fc="Certo: primeiramente.",
                fw={"b": "Acrescentadas é a promessa.", "c": "Coisas é o objeto acrescentado."},
                options=opt(("a", "primeiramente"), ("b", "acrescentadas"), ("c", "coisas")),
                correct="a", template="Mas buscai ___ o seu reino e a sua justiça",
            )),
            ("caminhada", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: priorizar o reino libera da ansiedade desordenada.",
                fw={"a": "Não é negligência das necessidades.", "c": "Não é culto ao consumo."},
                options=opt(
                    ("a", "Negligenciar necessidades"),
                    ("b", "Priorizar o reino"),
                    ("c", "Culto ao consumo"),
                ),
                correct="b",
                pa_text="buscai primeiramente… todas essas coisas vos serão acrescentadas",
            )),
            ("profundezas", "true_false", "01", dict(
                question="Buscar primeiro o reino forma discípulos que confiam na provisão do Pai.",
                fc="Certo: a prioridade do reino sustenta confiança, não ansiedade.",
                fw={"false": "A promessa de acréscimo apoia essa leitura."},
                options=TF, correct="true",
            )),
            ("profundezas", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "todas essas ___ vos serão acrescentadas"?',
                fc="Exato: coisas.",
                fw={"b": "Reino é o que se busca.", "c": "Justiça acompanha o reino."},
                options=opt(("a", "coisas"), ("b", "reino"), ("c", "justiça")),
                correct="a", template="todas essas ___ vos serão acrescentadas",
            )),
            ("profundezas", "choice", "03", dict(
                question="Qual sentido teológico Mateus 6:33 sustenta?",
                fc="Certo: o reino e a justiça de Deus reordenam desejos e preocupações.",
                fw={
                    "a": "Não é fuga das responsabilidades cotidianas.",
                    "c": "Há prioridade clara do reino.",
                    "d": "A justiça de Deus importa junto com o reino.",
                },
                options=opt(
                    ("a", "Ignorar a vida prática é o ideal do reino"),
                    ("b", "Reino e justiça reordenam desejos e preocupações"),
                    ("c", "Ansiedade material deve governar a fé"),
                    ("d", "Justiça de Deus é secundária no discipulado"),
                ),
                correct="b",
            )),
            ("profundezas", "order", "04", dict(
                question=f"Qual sequência revela o sentido de {vr}?",
                fc="Certo: prioridade, objeto da busca e promessa de acréscimo.",
                fw={
                    "b": "Reino e justiça são o centro.",
                    "c": "O acréscimo confirma a confiança.",
                },
                options=opt(
                    ("a", "buscai primeiramente"),
                    ("b", "o seu reino e a sua justiça"),
                    ("c", "todas essas coisas vos serão acrescentadas"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("profundezas", "complete", "05", dict(
                question='Complete: "buscai primeiramente o seu reino e a sua ___"',
                fc="Certo: justiça.",
                fw={"b": "Coisas é o acréscimo.", "c": "Reino já está na frase."},
                options=opt(("a", "justiça"), ("b", "coisas"), ("c", "reino")),
                correct="a", template="buscai primeiramente o seu reino e a sua ___",
            )),
            ("profundezas", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: buscai primeiro o reino e a sua justiça.",
                fw={"a": "Não é ansiedade reinando.", "b": "Não é reino sem justiça."},
                options=opt(
                    ("a", "Ansiedade no comando"),
                    ("b", "Reino sem justiça"),
                    ("c", "Buscai primeiro o reino e a justiça"),
                ),
                correct="c",
                pa_text="buscai primeiramente o seu reino e a sua justiça",
            )),
        ],
    )


def mission_boss_05():
    sec = "sm-boss-05-vida-diante-do-pai"
    vr = "Mateus 6:9; 6:33"
    ev = ["Mateus 6:9", "Mateus 6:33"]
    lo = "Integrar oração ao Pai e busca prioritária do reino como vida diante dEle."
    ins = "Vida diante do Pai: oração e reino primeiro."
    p = PB5
    return pack(
        sec, vr, ev, lo, p, ins,
        [
            ("semente", "true_false", "01", dict(
                question="Jesus ensina a orar: Pai nosso, que estás nos céus.",
                fc="Certo: Mateus 6:9 abre a oração modelo.",
                fw={"false": "O texto começa com Pai nosso nos céus."},
                options=TF, correct="true",
                passage=P69,
            )),
            ("semente", "tap", "02", dict(
                question='Em Mateus 6:9; 6:33, toque a palavra que falta em "santificado seja o teu ___"?',
                fc="Exato: nome.",
                fw={"b": "Céus é onde o Pai está.", "c": "Modo descreve como orar."},
                options=opt(("a", "nome"), ("b", "céus"), ("c", "modo")),
                correct="a", template="santificado seja o teu ___",
                passage=P69,
            )),
            ("semente", "choice", "03", dict(
                question="O que Mateus 6:33 manda buscar primeiramente?",
                fc="Certo: o seu reino e a sua justiça.",
                fw={
                    "b": "Não são só bens materiais.",
                    "c": "Não é fama.",
                    "d": "Reino e justiça são explícitos.",
                },
                options=opt(
                    ("a", "O seu reino e a sua justiça"),
                    ("b", "Só bens materiais"),
                    ("c", "Fama religiosa"),
                    ("d", "Descanso sem prioridade"),
                ),
                correct="a",
                passage=P21,
            )),
            ("semente", "order", "04", dict(
                question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                fc="Certo: orar ao Pai, santificar o nome e buscar o reino.",
                fw={
                    "b": "O nome santificado segue a invocação.",
                    "c": "Buscar o reino integra a vida diante do Pai.",
                },
                options=opt(
                    ("a", "Pai nosso, que estás nos céus"),
                    ("b", "santificado seja o teu nome"),
                    ("c", "buscai primeiramente o seu reino"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("semente", "complete", "05", dict(
                question='Complete: "Mas buscai primeiramente o seu ___ e a sua justiça"',
                fc="Certo: reino.",
                fw={"b": "Justiça acompanha o reino.", "c": "Coisas são o acréscimo."},
                options=opt(("a", "reino"), ("b", "justiça"), ("c", "coisas")),
                correct="a", template="Mas buscai primeiramente o seu ___ e a sua justiça",
                passage=P21,
            )),
            ("semente", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: vida diante do Pai — oração e reino primeiro.",
                fw={"b": "Não é oração sem reino.", "c": "Não é reino sem Pai."},
                options=opt(
                    ("a", "Oração e reino primeiro"),
                    ("b", "Oração sem reino"),
                    ("c", "Reino sem Pai"),
                ),
                correct="a",
                pa_text="Pai nosso… buscai primeiramente o seu reino",
            )),
            ("caminhada", "true_false", "01", dict(
                question="Segundo o bloco, a vida diante do Pai se reduz a pedir bens, sem santificar o nome nem buscar o reino.",
                fc="Certo que é falso: nome santificado e reino primeiro estruturam a vida.",
                fw={"true": "6:9 e 6:33 priorizam o Pai e o reino."},
                options=TF, correct="false",
            )),
            ("caminhada", "tap", "02", dict(
                question='Em Mateus 6:9; 6:33, toque a palavra que falta em "todas essas coisas vos serão ___"?',
                fc="Exato: acrescentadas.",
                fw={"b": "Reino é o que se busca.", "c": "Justiça acompanha o reino."},
                options=opt(("a", "acrescentadas"), ("b", "reino"), ("c", "justiça")),
                correct="a", template="todas essas coisas vos serão ___",
                passage=P21,
            )),
            ("caminhada", "choice", "03", dict(
                question="Como 6:9 e 6:33 se relacionam na vida do discípulo?",
                fc="Certo: orar ao Pai e buscar o reino formam uma só prioridade.",
                fw={
                    "a": "Não são temas isolados.",
                    "c": "Há unidade entre oração e busca.",
                    "d": "O Pai e o reino caminham juntos.",
                },
                options=opt(
                    ("a", "Oração e busca do reino não se relacionam"),
                    ("b", "Orar ao Pai e buscar o reino formam uma prioridade"),
                    ("c", "Só a oração importa; o reino é opcional"),
                    ("d", "Só o reino importa; o Pai fica de fora"),
                ),
                correct="b",
            )),
            ("caminhada", "order", "04", dict(
                question=f"Como se encadeiam os eventos de {vr}?",
                fc="Certo: invocação, santificação do nome e busca do reino com justiça.",
                fw={
                    "b": "Santificar o nome orienta a oração.",
                    "c": "Buscar reino e justiça aplica a oração na vida.",
                },
                options=opt(
                    ("a", "Portanto, orai vós deste modo: Pai nosso"),
                    ("b", "santificado seja o teu nome"),
                    ("c", "buscai primeiramente o seu reino e a sua justiça"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("caminhada", "complete", "05", dict(
                question='Complete: "Pai nosso, que estás nos ___"',
                fc="Certo: céus.",
                fw={"b": "Nome é o que se santifica.", "c": "Modo descreve como orar."},
                options=opt(("a", "céus"), ("b", "nome"), ("c", "modo")),
                correct="a", template="Pai nosso, que estás nos ___",
                passage=P69,
            )),
            ("caminhada", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: viver perante o Pai priorizando o reino.",
                fw={"a": "Não é religiosidade sem direção.", "c": "Não é ansiedade sem Pai."},
                options=opt(
                    ("a", "Religiosidade sem direção"),
                    ("b", "Viver perante o Pai e o reino"),
                    ("c", "Ansiedade sem Pai"),
                ),
                correct="b",
                pa_text="Pai nosso… buscai primeiramente o seu reino",
            )),
            ("profundezas", "true_false", "01", dict(
                question="Oração ao Pai e busca do reino revelam discípulos cuja vida pública nasce da intimidade com Deus.",
                fc="Certo: 6:9 e 6:33 unem intimidade e prioridade do reino.",
                fw={"false": "Os dois textos formam um eixo: Pai e reino primeiro."},
                options=TF, correct="true",
            )),
            ("profundezas", "tap", "02", dict(
                question='Em Mateus 6:9; 6:33, toque a palavra que falta em "e a sua ___, e todas essas coisas"?',
                fc="Exato: justiça.",
                fw={"b": "Reino é o que se busca primeiro.", "c": "Coisas são o acréscimo."},
                options=opt(("a", "justiça"), ("b", "reino"), ("c", "coisas")),
                correct="a", template="e a sua ___, e todas essas coisas",
                passage=P21,
            )),
            ("profundezas", "choice", "03", dict(
                question="Qual sentido teológico Mateus 6:9 e 6:33 sustentam juntos?",
                fc="Certo: a vida do discípulo se orienta pelo Pai e pelo reino dEle.",
                fw={
                    "a": "Não é oração mágica sem reino.",
                    "c": "Há integração entre culto e prioridade.",
                    "d": "O eu não é o centro.",
                },
                options=opt(
                    ("a", "Oração mágica basta sem buscar o reino"),
                    ("b", "Vida do discípulo se orienta pelo Pai e pelo reino"),
                    ("c", "Reino e oração são esferas incompatíveis"),
                    ("d", "O eu humano é o centro da piedade"),
                ),
                correct="b",
            )),
            ("profundezas", "order", "04", dict(
                question=f"Qual sequência revela o sentido de {vr}?",
                fc="Certo: Pai, nome santificado e reino com justiça.",
                fw={
                    "b": "O nome santificado molda a oração.",
                    "c": "Reino e justiça aplicam a oração na vida.",
                },
                options=opt(
                    ("a", "Pai nosso, que estás nos céus"),
                    ("b", "santificado seja o teu nome"),
                    ("c", "o seu reino e a sua justiça"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("profundezas", "complete", "05", dict(
                question='Complete: "santificado seja o teu ___"',
                fc="Certo: nome.",
                fw={"b": "Céus é onde o Pai está.", "c": "Nosso acompanha Pai."},
                options=opt(("a", "nome"), ("b", "céus"), ("c", "nosso")),
                correct="a", template="santificado seja o teu ___",
                passage=P69,
            )),
            ("profundezas", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: vida diante do Pai — oração e reino primeiro.",
                fw={"a": "Não é piedade sem direção.", "b": "Não é reino sem oração."},
                options=opt(
                    ("a", "Piedade sem direção"),
                    ("b", "Reino sem oração"),
                    ("c", "Vida diante do Pai: oração e reino"),
                ),
                correct="c",
                pa_text="Pai nosso… buscai primeiramente o seu reino e a sua justiça",
            )),
        ],
    )


def mission_22():
    sec = "sm-22-nao-julgueis"
    vr = "Mateus 7:1–2"
    ev = ["Mateus 7:1", "Mateus 7:2"]
    lo = "Reconhecer o aviso: não julgueis, pois sereis julgados com a mesma medida."
    ins = "Não julgueis, para não serdes julgados."
    p = P22
    return pack(
        sec, vr, ev, lo, p, ins,
        [
            ("semente", "true_false", "01", dict(
                question="Não julgueis, para que não sejais julgados.",
                fc="Certo: é a afirmação literal do texto.",
                fw={"false": "O texto abre com essa proibição e aviso."},
                options=TF, correct="true",
            )),
            ("semente", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "com o juízo com que ___, sereis julgados"?',
                fc="Exato: julgais.",
                fw={"b": "Medida vem na segunda parte.", "c": "Usais acompanha a medida."},
                options=opt(("a", "julgais"), ("b", "medida"), ("c", "usais")),
                correct="a", template="com o juízo com que ___, sereis julgados",
            )),
            ("semente", "choice", "03", dict(
                question="O que o texto afirma sobre a medida usada no juízo?",
                fc="Certo: a medida de que usais, dessa usarão convosco.",
                fw={
                    "b": "Há reciprocidade da medida.",
                    "c": "Não há isenção automática.",
                    "d": "A medida importa.",
                },
                options=opt(
                    ("a", "A mesma medida será usada convosco"),
                    ("b", "A medida nunca volta sobre quem julga"),
                    ("c", "Só os outros serão medidos"),
                    ("d", "A medida é irrelevante"),
                ),
                correct="a",
            )),
            ("semente", "order", "04", dict(
                question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                fc="Certo: não julgar, ser julgado e a medida correspondente.",
                fw={
                    "b": "O aviso de ser julgado segue a proibição.",
                    "c": "A medida fecha o ensino.",
                },
                options=opt(
                    ("a", "Não julgueis, para que não sejais julgados"),
                    ("b", "com o juízo com que julgais, sereis julgados"),
                    ("c", "a medida de que usais, dessa usarão convosco"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("semente", "complete", "05", dict(
                question='Complete: "e a ___ de que usais, dessa usarão convosco"',
                fc="Certo: medida.",
                fw={"b": "Juízo aparece antes.", "c": "Julgais é o verbo."},
                options=opt(("a", "medida"), ("b", "juízo"), ("c", "julgais")),
                correct="a", template="e a ___ de que usais, dessa usarão convosco",
            )),
            ("semente", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: não julgueis, para não serdes julgados.",
                fw={"b": "Não é licença para condenar.", "c": "Não é juízo sem consequência."},
                options=opt(
                    ("a", "Não julgueis"),
                    ("b", "Condenai livremente"),
                    ("c", "Juízo sem consequência"),
                ),
                correct="a",
                pa_text="Não julgueis, para que não sejais julgados",
            )),
            ("caminhada", "true_false", "01", dict(
                question="Segundo o texto, o juízo com que julgamos nunca volta sobre nós.",
                fc="Certo que é falso: sereis julgados com o mesmo juízo.",
                fw={"true": "O texto afirma reciprocidade do juízo e da medida."},
                options=TF, correct="false",
            )),
            ("caminhada", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "a medida de que ___, dessa usarão convosco"?',
                fc="Exato: usais.",
                fw={"b": "Julgais aparece antes.", "c": "Juízo é o termo anterior."},
                options=opt(("a", "usais"), ("b", "julgais"), ("c", "juízo")),
                correct="a", template="a medida de que ___, dessa usarão convosco",
            )),
            ("caminhada", "choice", "03", dict(
                question="Como o texto relaciona o ato de julgar e suas consequências?",
                fc="Certo: o padrão usado no juízo será aplicado de volta.",
                fw={
                    "a": "Não há isenção.",
                    "c": "Há consequência clara.",
                    "d": "A medida não é simbólica demais para importar.",
                },
                options=opt(
                    ("a", "Quem julga fica isento de juízo"),
                    ("b", "O padrão usado no juízo volta sobre quem julga"),
                    ("c", "Julgar nunca traz consequência"),
                    ("d", "A medida usada é irrelevante no texto"),
                ),
                correct="b",
            )),
            ("caminhada", "order", "04", dict(
                question=f"Como se encadeiam os eventos de {vr}?",
                fc="Certo: proibição, juízo correspondente e medida recíproca.",
                fw={
                    "b": "O juízo correspondente explica o aviso.",
                    "c": "A medida concreta aplica o princípio.",
                },
                options=opt(
                    ("a", "Não julgueis"),
                    ("b", "com o juízo com que julgais, sereis julgados"),
                    ("c", "a medida de que usais, dessa usarão convosco"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("caminhada", "complete", "05", dict(
                question='Complete: "Não julgueis, para que não sejais ___"',
                fc="Certo: julgados.",
                fw={"b": "Medida vem depois.", "c": "Usais acompanha a medida."},
                options=opt(("a", "julgados"), ("b", "medida"), ("c", "usais")),
                correct="a", template="Não julgueis, para que não sejais ___",
            )),
            ("caminhada", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: misericórdia na medida, pois a medida volta.",
                fw={"a": "Não é rigor cego.", "c": "Não é juízo sem espelho."},
                options=opt(
                    ("a", "Rigor cego"),
                    ("b", "A medida volta"),
                    ("c", "Juízo sem espelho"),
                ),
                correct="b",
                pa_text="a medida de que usais, dessa usarão convosco",
            )),
            ("profundezas", "true_false", "01", dict(
                question="Mateus 7:1–2 forma discípulos que evitam juízo hipócrita, pois a medida volta.",
                fc="Certo: o aviso protege a comunidade do juízo sem misericórdia.",
                fw={"false": "A reciprocidade do juízo sustenta essa leitura."},
                options=TF, correct="true",
            )),
            ("profundezas", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "com o ___ com que julgais, sereis julgados"?',
                fc="Exato: juízo.",
                fw={"b": "Medida vem na segunda frase.", "c": "Usais acompanha a medida."},
                options=opt(("a", "juízo"), ("b", "medida"), ("c", "usais")),
                correct="a", template="com o ___ com que julgais, sereis julgados",
            )),
            ("profundezas", "choice", "03", dict(
                question="Qual sentido teológico Mateus 7:1–2 sustenta?",
                fc="Certo: o discípulo deve temer o juízo hipócrita, pois Deus espelha a medida.",
                fw={
                    "a": "Não é proibição de todo discernimento ético absoluto.",
                    "c": "Há aviso solene contra condenação sem misericórdia.",
                    "d": "A medida importa teologicamente.",
                },
                options=opt(
                    ("a", "Nunca se pode avaliar nenhuma conduta"),
                    ("b", "Juízo hipócrita é perigoso, pois a medida volta"),
                    ("c", "Condenar sem misericórdia é virtude"),
                    ("d", "A medida usada não tem peso diante de Deus"),
                ),
                correct="b",
            )),
            ("profundezas", "order", "04", dict(
                question=f"Qual sequência revela o sentido de {vr}?",
                fc="Certo: proibição, juízo espelhado e medida aplicada.",
                fw={
                    "b": "O juízo espelhado explica o risco.",
                    "c": "A medida torna o aviso concreto.",
                },
                options=opt(
                    ("a", "Não julgueis, para que não sejais julgados"),
                    ("b", "com o juízo com que julgais, sereis julgados"),
                    ("c", "a medida de que usais, dessa usarão convosco"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("profundezas", "complete", "05", dict(
                question='Complete: "dessa ___ convosco"',
                fc="Certo: usarão.",
                fw={"b": "Julgais é o verbo anterior.", "c": "Medida é o substantivo."},
                options=opt(("a", "usarão"), ("b", "julgais"), ("c", "medida")),
                correct="a", template="dessa ___ convosco",
            )),
            ("profundezas", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: não julgueis, para não serdes julgados.",
                fw={"a": "Não é licença para crueldade.", "b": "Não é juízo sem retorno."},
                options=opt(
                    ("a", "Licença para crueldade"),
                    ("b", "Juízo sem retorno"),
                    ("c", "Não julgueis, para não serdes julgados"),
                ),
                correct="c",
                pa_text="Não julgueis… a medida de que usais, dessa usarão convosco",
            )),
        ],
    )


def mission_23():
    sec = "sm-23-pedir-buscar-bater"
    vr = "Mateus 7:7"
    ev = ["Mateus 7:7"]
    lo = "Reconhecer o triplo convite: pedi, buscai e batei, com promessa correspondente."
    ins = "Pedi, buscai, batei."
    p = P23
    return pack(
        sec, vr, ev, lo, p, ins,
        [
            ("semente", "true_false", "01", dict(
                question="Pedi, e dar-se-vos-á; buscai, e achareis; batei, e abrir-se-vos-á.",
                fc="Certo: é a afirmação literal do versículo.",
                fw={"false": "O texto traz exatamente esse triplo convite."},
                options=TF, correct="true",
            )),
            ("semente", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "Pedi, e ___ "?',
                fc="Exato: dar-se-vos-á.",
                fw={"b": "Achareis responde a buscai.", "c": "Abrir-se-vos-á responde a batei."},
                options=opt(("a", "dar-se-vos-á"), ("b", "achareis"), ("c", "abrir-se-vos-á")),
                correct="a", template="Pedi, e ___",
            )),
            ("semente", "choice", "03", dict(
                question="O que o texto promete a quem bate?",
                fc="Certo: abrir-se-vos-á.",
                fw={
                    "b": "Abrir responde a bater.",
                    "c": "Não há silêncio como resposta.",
                    "d": "A promessa é abertura.",
                },
                options=opt(
                    ("a", "Abrir-se-vos-á"),
                    ("b", "Nada acontecerá"),
                    ("c", "A porta permanecerá fechada"),
                    ("d", "Só haverá repreensão"),
                ),
                correct="a",
            )),
            ("semente", "order", "04", dict(
                question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                fc="Certo: pedir, buscar e bater.",
                fw={
                    "b": "Buscar vem depois de pedir.",
                    "c": "Bater fecha o triplo convite.",
                },
                options=opt(
                    ("a", "Pedi, e dar-se-vos-á"),
                    ("b", "buscai, e achareis"),
                    ("c", "batei, e abrir-se-vos-á"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("semente", "complete", "05", dict(
                question='Complete: "buscai, e ___"',
                fc="Certo: achareis.",
                fw={"b": "Dar-se-vos-á responde a pedi.", "c": "Abrir-se-vos-á responde a batei."},
                options=opt(("a", "achareis"), ("b", "dar-se-vos-á"), ("c", "abrir-se-vos-á")),
                correct="a", template="buscai, e ___",
            )),
            ("semente", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: pedi, buscai, batei.",
                fw={"b": "Não é passividade.", "c": "Não é fechamento divino."},
                options=opt(
                    ("a", "Pedi, buscai, batei"),
                    ("b", "Passividade total"),
                    ("c", "Porta sempre fechada"),
                ),
                correct="a",
                pa_text="Pedi… buscai… batei…",
            )),
            ("caminhada", "true_false", "01", dict(
                question="Mateus 7:7 apresenta ações humanas sem qualquer resposta prometida.",
                fc="Certo que é falso: cada ação tem promessa correspondente.",
                fw={"true": "Dar, achar e abrir respondem a pedir, buscar e bater."},
                options=TF, correct="false",
            )),
            ("caminhada", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "batei, e ___"?',
                fc="Exato: abrir-se-vos-á.",
                fw={"b": "Dar-se-vos-á responde a pedi.", "c": "Achareis responde a buscai."},
                options=opt(("a", "abrir-se-vos-á"), ("b", "dar-se-vos-á"), ("c", "achareis")),
                correct="a", template="batei, e ___",
            )),
            ("caminhada", "choice", "03", dict(
                question="Como o texto encadeia perseverança e resposta?",
                fc="Certo: pedir, buscar e bater crescem em intensidade e encontram resposta.",
                fw={
                    "a": "Há progressão, não estagnação.",
                    "c": "Cada verbo tem resposta.",
                    "d": "Não é convite vazio.",
                },
                options=opt(
                    ("a", "As ações não crescem; tudo é o mesmo gesto"),
                    ("b", "Pedir, buscar e bater crescem e encontram resposta"),
                    ("c", "Só pedir importa; buscar e bater são inúteis"),
                    ("d", "O convite não promete resposta"),
                ),
                correct="b",
            )),
            ("caminhada", "order", "04", dict(
                question=f"Como se encadeiam os eventos de {vr}?",
                fc="Certo: pedir/dar, buscar/achar e bater/abrir.",
                fw={
                    "b": "Buscar/achar fica no meio.",
                    "c": "Bater/abrir fecha o movimento.",
                },
                options=opt(
                    ("a", "Pedi, e dar-se-vos-á"),
                    ("b", "buscai, e achareis"),
                    ("c", "batei, e abrir-se-vos-á"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("caminhada", "complete", "05", dict(
                question='Complete: "Pedi, e ___; buscai, e achareis"',
                fc="Certo: dar-se-vos-á.",
                fw={"b": "Achareis já está na frase.", "c": "Abrir-se-vos-á é de bater."},
                options=opt(("a", "dar-se-vos-á"), ("b", "achareis"), ("c", "abrir-se-vos-á")),
                correct="a", template="Pedi, e ___; buscai, e achareis",
            )),
            ("caminhada", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: perseverança confiante perante o Pai generoso.",
                fw={"a": "Não é magia automática sem relação.", "c": "Não é desespero mudo."},
                options=opt(
                    ("a", "Magia automática"),
                    ("b", "Perseverança confiante"),
                    ("c", "Desespero mudo"),
                ),
                correct="b",
                pa_text="Pedi… buscai… batei…",
            )),
            ("profundezas", "true_false", "01", dict(
                question="O triplo convite forma discípulos que persistem em oração confiante.",
                fc="Certo: pedir, buscar e bater moldam perseverança filial.",
                fw={"false": "A progressão dos verbos sustenta essa leitura."},
                options=TF, correct="true",
            )),
            ("profundezas", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "___, e achareis"?',
                fc="Exato: buscai.",
                fw={"b": "Pedi inicia o triplo.", "c": "Batei fecha o triplo."},
                options=opt(("a", "buscai"), ("b", "Pedi"), ("c", "batei")),
                correct="a", template="___, e achareis",
            )),
            ("profundezas", "choice", "03", dict(
                question="Qual sentido teológico Mateus 7:7 sustenta?",
                fc="Certo: o Pai convida à busca perseverante e promete resposta.",
                fw={
                    "a": "Não é indiferença divina.",
                    "c": "Há convite ativo, não passividade.",
                    "d": "A promessa acompanha a perseverança.",
                },
                options=opt(
                    ("a", "Deus é indiferente aos pedidos"),
                    ("b", "O Pai convida à busca perseverante e responde"),
                    ("c", "O discípulo deve ficar passivo e calado"),
                    ("d", "Perseverar em pedir é inútil"),
                ),
                correct="b",
            )),
            ("profundezas", "order", "04", dict(
                question=f"Qual sequência revela o sentido de {vr}?",
                fc="Certo: pedir/receber, buscar/achar e bater/abrir.",
                fw={
                    "b": "Buscar aprofunda o pedido.",
                    "c": "Bater culmina a perseverança.",
                },
                options=opt(
                    ("a", "Pedi, e dar-se-vos-á"),
                    ("b", "buscai, e achareis"),
                    ("c", "batei, e abrir-se-vos-á"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("profundezas", "complete", "05", dict(
                question='Complete: "___, e abrir-se-vos-á"',
                fc="Certo: batei.",
                fw={"b": "Pedi inicia.", "c": "Buscai fica no meio."},
                options=opt(("a", "batei"), ("b", "Pedi"), ("c", "buscai")),
                correct="a", template="___, e abrir-se-vos-á",
            )),
            ("profundezas", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: pedi, buscai, batei.",
                fw={"a": "Não é silêncio forçado.", "b": "Não é porta selada."},
                options=opt(
                    ("a", "Silêncio forçado"),
                    ("b", "Porta selada"),
                    ("c", "Pedi, buscai, batei"),
                ),
                correct="c",
                pa_text="Pedi, e dar-se-vos-á; buscai, e achareis; batei, e abrir-se-vos-á",
            )),
        ],
    )


def mission_24():
    sec = "sm-24-porta-estreita"
    vr = "Mateus 7:13–14"
    ev = ["Mateus 7:13", "Mateus 7:14"]
    lo = "Reconhecer o chamado a entrar pela porta estreita que conduz à vida."
    ins = "Porta estreita e caminho apertado."
    p = P24
    return pack(
        sec, vr, ev, lo, p, ins,
        [
            ("semente", "true_false", "01", dict(
                question="Entrai pela porta estreita.",
                fc="Certo: é o convite literal do texto.",
                fw={"false": "O texto começa mandando entrar pela porta estreita."},
                options=TF, correct="true",
            )),
            ("semente", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "larga é a porta e espaçosa a estrada que conduz à ___"?',
                fc="Exato: perdição.",
                fw={"b": "Vida é o destino da porta estreita.", "c": "Estreita descreve a porta certa."},
                options=opt(("a", "perdição"), ("b", "vida"), ("c", "estreita")),
                correct="a", template="larga é a porta e espaçosa a estrada que conduz à ___",
            )),
            ("semente", "choice", "03", dict(
                question="Para onde conduz a estrada apertada, segundo o texto?",
                fc="Certo: à vida.",
                fw={
                    "b": "Perdição é da porta larga.",
                    "c": "A vida é o destino declarado.",
                    "d": "Poucos acertam com ela.",
                },
                options=opt(
                    ("a", "À vida"),
                    ("b", "À perdição"),
                    ("c", "A nenhum destino"),
                    ("d", "Só à popularidade"),
                ),
                correct="a",
            )),
            ("semente", "order", "04", dict(
                question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                fc="Certo: porta estreita, contraste da larga e destino da vida.",
                fw={
                    "b": "O contraste da larga vem no meio.",
                    "c": "A vida fecha o ensino.",
                },
                options=opt(
                    ("a", "Entrai pela porta estreita"),
                    ("b", "larga é a porta e espaçosa a estrada que conduz à perdição"),
                    ("c", "estreita é a porta… que conduz à vida"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("semente", "complete", "05", dict(
                question='Complete: "e poucos são os que ___ com ela"',
                fc="Certo: acertam.",
                fw={"b": "Entram aparece com a porta larga.", "c": "Muitos é o contraste."},
                options=opt(("a", "acertam"), ("b", "entram"), ("c", "muitos")),
                correct="a", template="e poucos são os que ___ com ela",
            )),
            ("semente", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: porta estreita e caminho apertado.",
                fw={"b": "Não é a porta larga.", "c": "Não é caminho da perdição."},
                options=opt(
                    ("a", "Porta estreita e caminho apertado"),
                    ("b", "Porta larga como ideal"),
                    ("c", "Caminho da perdição"),
                ),
                correct="a",
                pa_text="Entrai pela porta estreita… que conduz à vida",
            )),
            ("caminhada", "true_false", "01", dict(
                question="Segundo o texto, poucos entram pela porta larga que conduz à perdição.",
                fc="Certo que é falso: muitos são os que entram por ela.",
                fw={"true": "O texto diz que muitos entram pela porta larga."},
                options=TF, correct="false",
            )),
            ("caminhada", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "porque ___ é a porta, e apertada, a estrada"?',
                fc="Exato: estreita.",
                fw={"b": "Larga é a outra porta.", "c": "Espaçosa descreve a estrada larga."},
                options=opt(("a", "estreita"), ("b", "larga"), ("c", "espaçosa")),
                correct="a", template="porque ___ é a porta, e apertada, a estrada",
            )),
            ("caminhada", "choice", "03", dict(
                question="Como o texto contrasta as duas portas?",
                fc="Certo: larga leva à perdição com muitos; estreita à vida com poucos.",
                fw={
                    "a": "Não são iguais.",
                    "c": "Há diferença de destino e de número.",
                    "d": "O convite é à estreita.",
                },
                options=opt(
                    ("a", "As duas portas levam ao mesmo destino"),
                    ("b", "Larga: perdição e muitos; estreita: vida e poucos"),
                    ("c", "A larga é preferível porque é popular"),
                    ("d", "Não há convite a escolher a estreita"),
                ),
                correct="b",
            )),
            ("caminhada", "order", "04", dict(
                question=f"Como se encadeiam os eventos de {vr}?",
                fc="Certo: convite, aviso da larga e descrição da estreita à vida.",
                fw={
                    "b": "O aviso da larga motiva a escolha.",
                    "c": "A estreita à vida é o alvo.",
                },
                options=opt(
                    ("a", "Entrai pela porta estreita"),
                    ("b", "larga é a porta… muitos são os que entram por ela"),
                    ("c", "estreita é a porta… poucos são os que acertam com ela"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("caminhada", "complete", "05", dict(
                question='Complete: "e ___ são os que entram por ela"',
                fc="Certo: muitos.",
                fw={"b": "Poucos é da porta estreita.", "c": "Vida é o destino da estreita."},
                options=opt(("a", "muitos"), ("b", "poucos"), ("c", "vida")),
                correct="a", template="e ___ são os que entram por ela",
            )),
            ("caminhada", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: escolher a vida apesar do caminho apertado.",
                fw={"a": "Não é seguir a maioria.", "c": "Não é preferir a perdição."},
                options=opt(
                    ("a", "Seguir a maioria"),
                    ("b", "Escolher a vida no caminho apertado"),
                    ("c", "Preferir a perdição"),
                ),
                correct="b",
                pa_text="estreita é a porta… que conduz à vida",
            )),
            ("profundezas", "true_false", "01", dict(
                question="A porta estreita revela que o caminho da vida exige decisão contra a facilidade popular.",
                fc="Certo: poucos acertam; a larga é espaçosa e popular.",
                fw={"false": "O contraste muitos/poucos sustenta essa leitura."},
                options=TF, correct="true",
            )),
            ("profundezas", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "a estrada que conduz à ___, e poucos são os que acertam"?',
                fc="Exato: vida.",
                fw={"b": "Perdição é da estrada espaçosa.", "c": "Larga é a outra porta."},
                options=opt(("a", "vida"), ("b", "perdição"), ("c", "larga")),
                correct="a", template="a estrada que conduz à ___, e poucos são os que acertam",
            )),
            ("profundezas", "choice", "03", dict(
                question="Qual sentido teológico Mateus 7:13–14 sustenta?",
                fc="Certo: discipulado verdadeiro escolhe a vida, mesmo quando poucos a seguem.",
                fw={
                    "a": "Popularidade não valida o caminho.",
                    "c": "Há decisão custosa, não comodismo.",
                    "d": "A vida é o destino da estreita.",
                },
                options=opt(
                    ("a", "A maioria sempre indica o caminho certo"),
                    ("b", "Discipulado escolhe a vida, mesmo com poucos"),
                    ("c", "Facilidade popular é o critério do reino"),
                    ("d", "A porta estreita não conduz à vida"),
                ),
                correct="b",
            )),
            ("profundezas", "order", "04", dict(
                question=f"Qual sequência revela o sentido de {vr}?",
                fc="Certo: convite à estreita, perigo da larga e vida com poucos.",
                fw={
                    "b": "O perigo da larga motiva a escolha.",
                    "c": "Vida com poucos é o desfecho.",
                },
                options=opt(
                    ("a", "Entrai pela porta estreita"),
                    ("b", "espaçosa a estrada que conduz à perdição"),
                    ("c", "apertada, a estrada que conduz à vida"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("profundezas", "complete", "05", dict(
                question='Complete: "e apertada, a estrada que conduz à ___"',
                fc="Certo: vida.",
                fw={"b": "Perdição é da espaçosa.", "c": "Muitos é o contraste."},
                options=opt(("a", "vida"), ("b", "perdição"), ("c", "muitos")),
                correct="a", template="e apertada, a estrada que conduz à ___",
            )),
            ("profundezas", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: porta estreita e caminho apertado.",
                fw={"a": "Não é comodismo.", "b": "Não é seguir a multidão."},
                options=opt(
                    ("a", "Comodismo espiritual"),
                    ("b", "Seguir a multidão"),
                    ("c", "Porta estreita e caminho apertado"),
                ),
                correct="c",
                pa_text="Entrai pela porta estreita… que conduz à vida",
            )),
        ],
    )


def mission_25():
    sec = "sm-25-frutos-e-casa"
    vr = "Mateus 7:24–25"
    ev = ["Mateus 7:24", "Mateus 7:25"]
    lo = "Reconhecer que ouvir e observar as palavras de Jesus é edificar sobre a rocha."
    ins = "Casa na rocha: ouvir e praticar."
    p = P25
    return pack(
        sec, vr, ev, lo, p, ins,
        [
            ("semente", "true_false", "01", dict(
                question="Quem ouve as palavras de Jesus e as observa é comparado a um homem prudente.",
                fc="Certo: é a afirmação literal do texto.",
                fw={"false": "O texto compara quem ouve e observa ao homem prudente."},
                options=TF, correct="true",
            )),
            ("semente", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "edificou a sua casa sobre a ___"?',
                fc="Exato: rocha.",
                fw={"b": "Casa é o que se edifica.", "c": "Chuva é a prova."},
                options=opt(("a", "rocha"), ("b", "casa"), ("c", "chuva")),
                correct="a", template="edificou a sua casa sobre a ___",
            )),
            ("semente", "choice", "03", dict(
                question="O que aconteceu com a casa edificada sobre a rocha?",
                fc="Certo: ela não caiu.",
                fw={
                    "b": "O texto diz que não caiu.",
                    "c": "A rocha sustentou.",
                    "d": "Houve tempestade, mas a casa ficou.",
                },
                options=opt(
                    ("a", "Ela não caiu"),
                    ("b", "Ela caiu imediatamente"),
                    ("c", "Foi abandonada sem prova"),
                    ("d", "Não enfrentou vento nem chuva"),
                ),
                correct="a",
            )),
            ("semente", "order", "04", dict(
                question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                fc="Certo: ouvir e observar, edificar na rocha e resistir à tempestade.",
                fw={
                    "b": "Edificar na rocha segue o ouvir e observar.",
                    "c": "A tempestade prova a casa.",
                },
                options=opt(
                    ("a", "que ouve essas minhas palavras e as observa"),
                    ("b", "edificou a sua casa sobre a rocha"),
                    ("c", "deram com ímpeto contra aquela casa, e ela não caiu"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("semente", "complete", "05", dict(
                question='Complete: "será comparado a um homem ___, que edificou a sua casa"',
                fc="Certo: prudente.",
                fw={"b": "Rocha é o fundamento.", "c": "Torrentes são a prova."},
                options=opt(("a", "prudente"), ("b", "rocha"), ("c", "torrentes")),
                correct="a", template="será comparado a um homem ___, que edificou a sua casa",
            )),
            ("semente", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: casa na rocha — ouvir e praticar.",
                fw={"b": "Não é só ouvir.", "c": "Não é casa sem fundamento."},
                options=opt(
                    ("a", "Ouvir e praticar"),
                    ("b", "Só ouvir"),
                    ("c", "Casa sem fundamento"),
                ),
                correct="a",
                pa_text="que ouve… e as observa… sobre a rocha",
            )),
            ("caminhada", "true_false", "01", dict(
                question="Segundo o texto, basta ouvir as palavras; observá-las é irrelevante para a casa.",
                fc="Certo que é falso: ouvir e observar juntos definem o prudente.",
                fw={"true": "O texto une ouvir e observar."},
                options=TF, correct="false",
            )),
            ("caminhada", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "Desceu a ___, vieram as torrentes"?',
                fc="Exato: chuva.",
                fw={"b": "Ventos também vêm na prova.", "c": "Rocha é o fundamento."},
                options=opt(("a", "chuva"), ("b", "ventos"), ("c", "rocha")),
                correct="a", template="Desceu a ___, vieram as torrentes",
            )),
            ("caminhada", "choice", "03", dict(
                question="Como o texto relaciona prática das palavras e resistência?",
                fc="Certo: praticar edifica na rocha, e a casa resiste à tempestade.",
                fw={
                    "a": "Não é ouvir sem prática.",
                    "c": "A tempestade prova, não anula, a rocha.",
                    "d": "Há ligação clara entre observar e não cair.",
                },
                options=opt(
                    ("a", "Ouvir sem praticar já basta para resistir"),
                    ("b", "Praticar edifica na rocha e a casa resiste"),
                    ("c", "A tempestade torna a rocha inútil"),
                    ("d", "Observar as palavras não se liga à estabilidade"),
                ),
                correct="b",
            )),
            ("caminhada", "order", "04", dict(
                question=f"Como se encadeiam os eventos de {vr}?",
                fc="Certo: edificação, tempestade e permanência da casa.",
                fw={
                    "b": "A tempestade vem após a edificação.",
                    "c": "Não cair é o desfecho.",
                },
                options=opt(
                    ("a", "edificou a sua casa sobre a rocha"),
                    ("b", "Desceu a chuva, vieram as torrentes, sopraram os ventos"),
                    ("c", "ela não caiu; pois estava edificada sobre a rocha"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("caminhada", "complete", "05", dict(
                question='Complete: "e as ___; será comparado a um homem prudente"',
                fc="Certo: observa.",
                fw={"b": "Ouve vem antes.", "c": "Edificou descreve a ação."},
                options=opt(("a", "observa"), ("b", "ouve"), ("c", "edificou")),
                correct="a", template="e as ___; será comparado a um homem prudente",
            )),
            ("caminhada", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: estabilidade nasce de praticar as palavras do Rei.",
                fw={"a": "Não é só teoria.", "c": "Não é casa na areia."},
                options=opt(
                    ("a", "Teoria sem prática"),
                    ("b", "Estabilidade pela prática"),
                    ("c", "Casa na areia"),
                ),
                correct="b",
                pa_text="ouve… e as observa… ela não caiu",
            )),
            ("profundezas", "true_false", "01", dict(
                question="A parábola da casa na rocha ensina que a fé autêntica se prova na prática sob pressão.",
                fc="Certo: a tempestade revela se a casa foi edificada na rocha.",
                fw={"false": "Chuva, torrentes e ventos testam a edificação."},
                options=TF, correct="true",
            )),
            ("profundezas", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "sopraram os ___ e deram com ímpeto"?',
                fc="Exato: ventos.",
                fw={"b": "Torrentes também vêm na prova.", "c": "Chuva inicia a tempestade."},
                options=opt(("a", "ventos"), ("b", "torrentes"), ("c", "chuva")),
                correct="a", template="sopraram os ___ e deram com ímpeto",
            )),
            ("profundezas", "choice", "03", dict(
                question="Qual sentido teológico Mateus 7:24–25 sustenta?",
                fc="Certo: discipulado verdadeiro ouve e pratica, resistindo às provas.",
                fw={
                    "a": "Ouvir sem observar não basta.",
                    "c": "A rocha é as palavras observadas.",
                    "d": "A prova não é acaso sem sentido.",
                },
                options=opt(
                    ("a", "Bastar ouvir sem praticar"),
                    ("b", "Discipulado ouve, pratica e resiste às provas"),
                    ("c", "A rocha é opinião humana, não as palavras"),
                    ("d", "Tempestades não revelam o fundamento"),
                ),
                correct="b",
            )),
            ("profundezas", "order", "04", dict(
                question=f"Qual sequência revela o sentido de {vr}?",
                fc="Certo: ouvir e observar, edificar na rocha e não cair.",
                fw={
                    "b": "Edificar na rocha aplica a escuta.",
                    "c": "Não cair confirma o fundamento.",
                },
                options=opt(
                    ("a", "ouve essas minhas palavras e as observa"),
                    ("b", "edificou a sua casa sobre a rocha"),
                    ("c", "ela não caiu; pois estava edificada sobre a rocha"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("profundezas", "complete", "05", dict(
                question='Complete: "pois estava edificada sobre a ___"',
                fc="Certo: rocha.",
                fw={"b": "Casa é o edifício.", "c": "Ímpeto descreve o ataque."},
                options=opt(("a", "rocha"), ("b", "casa"), ("c", "ímpeto")),
                correct="a", template="pois estava edificada sobre a ___",
            )),
            ("profundezas", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: casa na rocha — ouvir e praticar.",
                fw={"a": "Não é ouvir estéril.", "b": "Não é casa sem prova."},
                options=opt(
                    ("a", "Ouvir estéril"),
                    ("b", "Casa sem prova"),
                    ("c", "Casa na rocha: ouvir e praticar"),
                ),
                correct="c",
                pa_text="ouve… e as observa… sobre a rocha",
            )),
        ],
    )


def mission_boss_06():
    sec = "sm-boss-06-sermao-completo"
    vr = "Mateus 7:24–25"
    ev = ["Mateus 7:24", "Mateus 7:25"]
    lo = "Integrar o sermão: praticar as palavras do Rei é edificar a casa sobre a rocha."
    ins = "Sermão completo: praticar as palavras do Rei."
    p = PB6
    return pack(
        sec, vr, ev, lo, p, ins,
        [
            ("semente", "true_false", "01", dict(
                question="Todo aquele que ouve essas minhas palavras e as observa será comparado a um homem prudente.",
                fc="Certo: é a afirmação literal que fecha o sermão.",
                fw={"false": "O texto une ouvir e observar ao prudente."},
                options=TF, correct="true",
            )),
            ("semente", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "que ouve essas minhas ___ e as observa"?',
                fc="Exato: palavras.",
                fw={"b": "Casa é o que se edifica.", "c": "Rocha é o fundamento."},
                options=opt(("a", "palavras"), ("b", "casa"), ("c", "rocha")),
                correct="a", template="que ouve essas minhas ___ e as observa",
            )),
            ("semente", "choice", "03", dict(
                question="Sobre o que o homem prudente edificou a casa?",
                fc="Certo: sobre a rocha.",
                fw={
                    "b": "Não é areia neste versículo.",
                    "c": "A rocha é explícita.",
                    "d": "Há fundamento claro.",
                },
                options=opt(
                    ("a", "Sobre a rocha"),
                    ("b", "Sobre a areia"),
                    ("c", "Sobre a chuva"),
                    ("d", "Sem nenhum fundamento"),
                ),
                correct="a",
            )),
            ("semente", "order", "04", dict(
                question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                fc="Certo: ouvir e observar, edificar e não cair.",
                fw={
                    "b": "Edificar segue o ouvir e observar.",
                    "c": "Não cair fecha a prova.",
                },
                options=opt(
                    ("a", "que ouve essas minhas palavras e as observa"),
                    ("b", "edificou a sua casa sobre a rocha"),
                    ("c", "ela não caiu"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("semente", "complete", "05", dict(
                question='Complete: "deram com ímpeto contra aquela casa, e ela não ___"',
                fc="Certo: caiu.",
                fw={"b": "Rocha é o fundamento.", "c": "Chuva inicia a prova."},
                options=opt(("a", "caiu"), ("b", "rocha"), ("c", "chuva")),
                correct="a", template="deram com ímpeto contra aquela casa, e ela não ___",
            )),
            ("semente", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: sermão completo — praticar as palavras do Rei.",
                fw={"b": "Não é só admirar.", "c": "Não é ouvir sem obra."},
                options=opt(
                    ("a", "Praticar as palavras do Rei"),
                    ("b", "Só admirar o sermão"),
                    ("c", "Ouvir sem obra"),
                ),
                correct="a",
                pa_text="ouve essas minhas palavras e as observa… sobre a rocha",
            )),
            ("caminhada", "true_false", "01", dict(
                question="O fechamento do sermão trata a prática das palavras como opcional diante da tempestade.",
                fc="Certo que é falso: observar as palavras é o que sustenta a casa.",
                fw={"true": "Ouvir e observar são a condição do prudente."},
                options=TF, correct="false",
            )),
            ("caminhada", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "vieram as ___, sopraram os ventos"?',
                fc="Exato: torrentes.",
                fw={"b": "Ventos vem em seguida.", "c": "Chuva inicia a série."},
                options=opt(("a", "torrentes"), ("b", "ventos"), ("c", "chuva")),
                correct="a", template="vieram as ___, sopraram os ventos",
            )),
            ("caminhada", "choice", "03", dict(
                question="Como o fim do sermão resume a resposta ao ensino do Rei?",
                fc="Certo: ouvir e praticar as palavras é o fundamento que resiste.",
                fw={
                    "a": "Não é só entusiasmo.",
                    "c": "A prática é decisiva.",
                    "d": "A tempestade prova o fundamento.",
                },
                options=opt(
                    ("a", "Basta entusiasmo sem prática"),
                    ("b", "Ouvir e praticar é o fundamento que resiste"),
                    ("c", "A prática é irrelevante no fechamento"),
                    ("d", "A tempestade não testa a casa"),
                ),
                correct="b",
            )),
            ("caminhada", "order", "04", dict(
                question=f"Como se encadeiam os eventos de {vr}?",
                fc="Certo: palavras observadas, casa na rocha e resistência à prova.",
                fw={
                    "b": "A casa na rocha aplica as palavras.",
                    "c": "A resistência confirma o sermão vivido.",
                },
                options=opt(
                    ("a", "ouve essas minhas palavras e as observa"),
                    ("b", "edificou a sua casa sobre a rocha"),
                    ("c", "deram com ímpeto… e ela não caiu"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("caminhada", "complete", "05", dict(
                question='Complete: "será comparado a um homem prudente, que ___ a sua casa sobre a rocha"',
                fc="Certo: edificou.",
                fw={"b": "Observa é a condição.", "c": "Ouve inicia."},
                options=opt(("a", "edificou"), ("b", "observa"), ("c", "ouve")),
                correct="a",
                template="será comparado a um homem prudente, que ___ a sua casa sobre a rocha",
            )),
            ("caminhada", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: o sermão se completa na prática, não só na escuta.",
                fw={"a": "Não é teoria isolada.", "c": "Não é casa sem palavras."},
                options=opt(
                    ("a", "Teoria isolada"),
                    ("b", "Sermão completo na prática"),
                    ("c", "Casa sem palavras"),
                ),
                correct="b",
                pa_text="ouve… e as observa… ela não caiu",
            )),
            ("profundezas", "true_false", "01", dict(
                question="O sermão no monte culmina na obediência: praticar as palavras do Rei é viver sobre a rocha.",
                fc="Certo: o desfecho une escuta, prática e estabilidade sob prova.",
                fw={"false": "Ouvir e observar sobre a rocha fecham o discurso."},
                options=TF, correct="true",
            )),
            ("profundezas", "tap", "02", dict(
                question=f'Em {vr}, toque a palavra que falta em "Todo aquele, pois, que ___ essas minhas palavras"?',
                fc="Exato: ouve.",
                fw={"b": "Observa completa a condição.", "c": "Edificou descreve o prudente."},
                options=opt(("a", "ouve"), ("b", "observa"), ("c", "edificou")),
                correct="a", template="Todo aquele, pois, que ___ essas minhas palavras",
            )),
            ("profundezas", "choice", "03", dict(
                question="Qual sentido teológico Mateus 7:24–25 dá ao sermão completo?",
                fc="Certo: o ensino do Rei exige prática; só assim a casa permanece.",
                fw={
                    "a": "Não é discurso para aplauso.",
                    "c": "A obediência é o fundamento.",
                    "d": "A prova revela, não inventa, o fundamento.",
                },
                options=opt(
                    ("a", "O sermão basta como discurso para aplauso"),
                    ("b", "O ensino do Rei exige prática para a casa permanecer"),
                    ("c", "Obediência é opcional no discipulado"),
                    ("d", "Tempestades não revelam o fundamento da vida"),
                ),
                correct="b",
            )),
            ("profundezas", "order", "04", dict(
                question=f"Qual sequência revela o sentido de {vr}?",
                fc="Certo: palavras do Rei, prática edificante e permanência na prova.",
                fw={
                    "b": "A prática edifica sobre a rocha.",
                    "c": "A permanência confirma o sermão vivido.",
                },
                options=opt(
                    ("a", "essas minhas palavras"),
                    ("b", "as observa… edificou… sobre a rocha"),
                    ("c", "ela não caiu; pois estava edificada sobre a rocha"),
                ),
                correct="a", correct_order=["a", "b", "c"],
            )),
            ("profundezas", "complete", "05", dict(
                question='Complete: "e as ___, será comparado a um homem prudente"',
                fc="Certo: observa.",
                # template needs exact words from passage: "e as observa será comparado"
                fw={"b": "Ouve inicia a condição.", "c": "Palavras é o objeto."},
                options=opt(("a", "observa"), ("b", "ouve"), ("c", "palavras")),
                correct="a", template="e as ___, será comparado a um homem prudente",
            )),
            ("profundezas", "connect", "06", dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc="Certo: sermão completo — praticar as palavras do Rei.",
                fw={"a": "Não é sermão sem vida.", "b": "Não é casa sem rocha."},
                options=opt(
                    ("a", "Sermão sem vida"),
                    ("b", "Casa sem rocha"),
                    ("c", "Sermão completo: praticar as palavras do Rei"),
                ),
                correct="c",
                pa_text="ouve essas minhas palavras e as observa… sobre a rocha",
            )),
        ],
    )


def main():
    all_q = []
    for fn in (
        mission_boss_04,
        mission_18,
        mission_19,
        mission_20,
        mission_21,
        mission_boss_05,
        mission_22,
        mission_23,
        mission_24,
        mission_25,
        mission_boss_06,
    ):
        all_q.extend(fn())
    assert len(all_q) == 198, len(all_q)
    # validate tap options in passageText
    for q in all_q:
        if q["type"] == "tap":
            for o in q["options"]:
                assert o["text"] in q["passageText"], (q["id"], o["text"])
    OUT.write_text(json.dumps(all_q, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    secs = []
    for q in all_q:
        if q["section"] not in secs:
            secs.append(q["section"])
    print(OUT)
    print("count:", len(all_q))
    print("sections:", ", ".join(secs))


if __name__ == "__main__":
    main()
