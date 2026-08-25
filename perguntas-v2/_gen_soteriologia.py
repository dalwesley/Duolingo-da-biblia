#!/usr/bin/env python3
"""Gera perguntas-v2/soteriologia.json no padrão Oséias STWAY V2."""
from __future__ import annotations

import json
from copy import deepcopy
from pathlib import Path

OUT = Path(__file__).with_name("soteriologia.json")

TF_OPTS = [
    {"id": "true", "text": "Verdadeiro"},
    {"id": "false", "text": "Falso"},
]


def opts(*pairs: tuple[str, str]) -> list[dict]:
    return [{"id": i, "text": t} for i, t in pairs]


def item(
    *,
    trail: str,
    section: str,
    difficulty: str,
    skill: str,
    n: str,
    qtype: str,
    verse_ref: str,
    lo: str,
    evidence: list[str],
    question: str,
    feedback_correct: str,
    feedback_wrong: dict,
    options: list[dict],
    correct: str,
    passage: str,
    template: str | None = None,
    correct_order: list[str] | None = None,
    passage_a: dict | None = None,
    passage_b: dict | None = None,
) -> dict:
    short = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}[difficulty]
    q = {
        "difficulty": difficulty,
        "skill": skill,
        "verseRef": verse_ref,
        "learningObjective": lo,
        "evidence": evidence,
        "type": qtype,
        "question": question,
        "prompt": question,
        "cue": question,
        "feedbackCorrect": feedback_correct,
        "feedbackWrong": feedback_wrong,
        "options": options,
        "correctOptionId": correct,
        "correctAnswer": correct,
        "passageText": passage,
    }
    if template:
        q["template"] = template
    if passage_a:
        q["passageA"] = passage_a
    if passage_b:
        q["passageB"] = passage_b
    if correct_order:
        q["correctOrder"] = correct_order
    q["trail"] = trail
    q["section"] = section
    q["id"] = f"{trail}-{short}-{section}-{n}"
    return q


TRAIL = "soteriologia"

# --- textos TB ---
P1 = "Pois pela graça é que sois salvos, mediante a fé; e isso não vem de vós; é o dom de Deus; não de obras, para que ninguém se glorie."
P2 = "mas Deus prova o seu amor para conosco em que, quando éramos ainda pecadores, morreu Cristo por nós."
P3 = "Jesus respondeu-lhe: Em verdade, em verdade te digo que, se alguém não nascer de novo, não pode ver o reino de Deus."
PBOSS = f"{P1} {P2} {P3}"

LO1 = "Reconhecer que a salvação é graça de Deus, mediante a fé: dom, não obras, para que ninguém se glorie."
LO2 = "Reconhecer que Deus prova o seu amor na cruz: Cristo morreu por nós ainda pecadores."
LO3 = "Reconhecer que, sem nascer de novo, ninguém vê o reino: salvação é vida, não só reforma."
LOB = "Integrar graça como dom, cruz por pecadores e nascimento de novo na salvação."

EV1 = ["Efésios 2:8", "Efésios 2:9"]
EV2 = ["Romanos 5:8"]
EV3 = ["João 3:3"]
EVB = ["Efésios 2:8", "Efésios 2:9", "Romanos 5:8", "João 3:3"]

R1 = "Efésios 2:8–9"
R2 = "Romanos 5:8"
R3 = "João 3:3"
RB = "Efésios 2:8; Romanos 5:8; João 3:3"

INS1 = "Salvos pela graça, mediante a fé: dom de Deus, não obras, para que ninguém se glorie."
INS2 = "Cristo morreu por nós ainda pecadores: o amor de Deus se prova na cruz, não na nossa melhoria prévia."
INS3 = "Nascidos de novo: sem novo nascimento ninguém vê o reino — salvação é vida, não só reforma."
INSB = "Graça salvadora: dom, cruz por pecadores e nascimento de novo."


def pack(
    section: str,
    verse_ref: str,
    lo: str,
    evidence: list[str],
    passage: str,
    rows: list[dict],
) -> list[dict]:
    out = []
    for r in rows:
        kw = deepcopy(r)
        kw.update(
            trail=TRAIL,
            section=section,
            verse_ref=verse_ref,
            lo=lo,
            evidence=evidence,
            passage=passage,
        )
        out.append(item(**kw))
    return out


def tf(diff, skill, n, question, fc, fw, correct):
    return dict(
        difficulty=diff,
        skill=skill,
        n=n,
        qtype="true_false",
        question=question,
        feedback_correct=fc,
        feedback_wrong=fw,
        options=TF_OPTS,
        correct=correct,
    )


def tap(diff, skill, n, ref, blank, fc, fw, options, correct, template):
    q = f'Em {ref}, toque a palavra que falta em "{blank}"?'
    return dict(
        difficulty=diff,
        skill=skill,
        n=n,
        qtype="tap",
        question=q,
        feedback_correct=fc,
        feedback_wrong=fw,
        options=options,
        correct=correct,
        template=template,
    )


def choice(diff, skill, n, question, fc, fw, options, correct):
    return dict(
        difficulty=diff,
        skill=skill,
        n=n,
        qtype="choice",
        question=question,
        feedback_correct=fc,
        feedback_wrong=fw,
        options=options,
        correct=correct,
    )


def order(diff, skill, n, question, fc, fw, options):
    return dict(
        difficulty=diff,
        skill=skill,
        n=n,
        qtype="order",
        question=question,
        feedback_correct=fc,
        feedback_wrong=fw,
        options=options,
        correct="a",
        correct_order=["a", "b", "c"],
    )


def complete(diff, skill, n, blank, fc, fw, options, correct, template):
    q = f'Complete a frase: "{blank}"'
    return dict(
        difficulty=diff,
        skill=skill,
        n=n,
        qtype="complete",
        question=q,
        feedback_correct=fc,
        feedback_wrong=fw,
        options=options,
        correct=correct,
        template=template,
    )


def connect(diff, skill, n, ref, fc, fw, options, correct, pa, pb):
    return dict(
        difficulty=diff,
        skill=skill,
        n=n,
        qtype="connect",
        question=f"O que {ref} comunica que se liga a este contexto?",
        feedback_correct=fc,
        feedback_wrong=fw,
        options=options,
        correct=correct,
        passage_a={"ref": ref, "text": pa},
        passage_b={"ref": "Contexto", "text": pb},
    )


# --- M1 ---
O1 = opts(
    ("a", "Pois pela graça é que sois salvos, mediante a fé"),
    ("b", "e isso não vem de vós; é o dom de Deus"),
    ("c", "não de obras, para que ninguém se glorie"),
)

m1 = pack(
    "so-01-graca",
    R1,
    LO1,
    EV1,
    P1,
    [
        tf(
            "semente",
            "observe",
            "01",
            "Pela graça é que sois salvos, mediante a fé; isso não vem de vós; é o dom de Deus.",
            "Certo: Efésios 2:8 afirma graça, fé e o dom de Deus.",
            {"false": "Releia: a salvação é pela graça, mediante a fé, e é dom."},
            "true",
        ),
        tap(
            "semente",
            "observe",
            "02",
            R1,
            "Pois pela ___ é que sois salvos, mediante a fé",
            "Exato: sois salvos pela graça, mediante a fé.",
            {"b": "Fé é o meio; a lacuna pede a origem: graça.", "c": "Obras entram depois; aqui o texto fala de graça."},
            opts(("a", "graça"), ("b", "fé"), ("c", "obras")),
            "a",
            "Pois pela ___ é que sois salvos, mediante a fé",
        ),
        choice(
            "semente",
            "observe",
            "03",
            "Qual fato Efésios 2:8–9 afirma sobre a salvação?",
            "Certo: o texto liga graça, fé, dom e a exclusão das obras.",
            {
                "b": "O texto diz que isso não vem de vós.",
                "c": "O texto nega que a salvação seja de obras.",
                "d": "O orgulho é excluído porque a salvação é dom.",
            },
            opts(
                ("a", "Sois salvos pela graça, mediante a fé; é dom, não obras"),
                ("b", "A salvação vem de vós, se o esforço for suficiente"),
                ("c", "As obras são a causa da salvação, segundo o texto"),
                ("d", "Ninguém se gloria porque as obras já bastam"),
            ),
            "a",
        ),
        order(
            "semente",
            "observe",
            "04",
            f"Qual sequência mostra a ordem dos fatos em {R1}?",
            "Certo: graça e fé, depois o dom, depois a exclusão das obras.",
            {
                "b": "O dom vem depois de ‘não vem de vós’, não no fim.",
                "c": "As obras e a glória fecham o trecho, não o abrem.",
            },
            O1,
        ),
        complete(
            "semente",
            "observe",
            "05",
            "não de ___, para que ninguém se glorie",
            "Certo: não de obras, para que ninguém se glorie.",
            {"b": "Fé é o meio no v. 8, não esta lacuna.", "c": "Graça abre o versículo, não fecha esta frase."},
            opts(("a", "obras"), ("b", "fé"), ("c", "graça")),
            "a",
            "não de ___, para que ninguém se glorie",
        ),
        connect(
            "semente",
            "observe",
            "06",
            R1,
            "Certo: o trecho liga salvação a um dom, não a obras.",
            {
                "b": "O texto exclui as obras como causa da salvação.",
                "c": "O orgulho é cortado precisamente porque é dom.",
            },
            opts(
                ("a", "Dom de Deus, não obras"),
                ("b", "Mérito humano pelas obras"),
                ("c", "Glória do salvo em si mesmo"),
            ),
            "a",
            P1,
            INS1,
        ),
        tf(
            "caminhada",
            "understand",
            "01",
            "O texto ensina que a salvação começa em vós e Deus apenas confirma o esforço.",
            "Certo: isso não vem de vós; é o dom de Deus.",
            {"true": "O texto recusa a origem humana: não vem de vós."},
            "false",
        ),
        tap(
            "caminhada",
            "understand",
            "02",
            R1,
            "Pois pela graça é que sois salvos, mediante a ___",
            "Exato: a fé é o meio; a graça é a origem.",
            {"b": "Graça já está antes; a lacuna pede o meio: fé.", "c": "Obras são excluídas, não preenchem esta lacuna."},
            opts(("a", "fé"), ("b", "graça"), ("c", "obras")),
            "a",
            "Pois pela graça é que sois salvos, mediante a ___",
        ),
        choice(
            "caminhada",
            "understand",
            "03",
            "Como Efésios 2:8–9 relaciona graça, fé e obras?",
            "Certo: a graça origina, a fé medeia, as obras não causam.",
            {
                "a": "Fé não anula o dom; é o meio pelo qual o dom chega.",
                "c": "O texto recusa obras como causa da salvação.",
                "d": "O assunto é salvação, não só ética social.",
            },
            opts(
                ("a", "Graça e fé se opõem, de modo que crer anula o dom"),
                ("b", "A fé é o meio; a graça é a origem; obras não salvam"),
                ("c", "Obras salvam, e a fé só ilustra o caráter"),
                ("d", "O texto trata só de ética, sem falar de salvação"),
            ),
            "b",
        ),
        order(
            "caminhada",
            "understand",
            "04",
            f"Como se encadeiam os eventos de {R1}?",
            "Certo: salvação pela graça, origem no dom, exclusão das obras.",
            {
                "b": "Primeiro vem a graça mediante a fé, não as obras.",
                "c": "A glória humana é o alvo recusado no fim, não o início.",
            },
            O1,
        ),
        complete(
            "caminhada",
            "understand",
            "05",
            "e isso não vem de ___; é o dom de Deus",
            "Certo: não vem de vós; é o dom de Deus.",
            {"b": "Deus é quem dá o dom, não a origem recusada.", "c": "Ninguém aparece na cláusula da glória."},
            opts(("a", "vós"), ("b", "Deus"), ("c", "ninguém")),
            "a",
            "e isso não vem de ___; é o dom de Deus",
        ),
        connect(
            "caminhada",
            "understand",
            "06",
            R1,
            "Certo: a salvação chega como presente, não como salário.",
            {
                "b": "O texto não descreve um contrato de mérito.",
                "c": "A fé não substitui a graça como origem.",
            },
            opts(
                ("a", "Salvação como presente"),
                ("b", "Salário por desempenho"),
                ("c", "Fé como mérito próprio"),
            ),
            "a",
            P1,
            INS1,
        ),
        tf(
            "profundezas",
            "interpret",
            "01",
            "O texto corta o orgulho humano: ninguém se gloria porque a salvação é dom, não conquista.",
            "Certo: ‘não de obras, para que ninguém se glorie’.",
            {"false": "A finalidade do trecho é exatamente impedir a jactância."},
            "true",
        ),
        tap(
            "profundezas",
            "interpret",
            "02",
            R1,
            "não de obras, para que ___ se glorie",
            "Exato: para que ninguém se glorie.",
            {"b": "Vós é a origem recusada, não o sujeito de ‘se glorie’.", "c": "Deus dá o dom; a lacuna pede ‘ninguém’."},
            opts(("a", "ninguém"), ("b", "vós"), ("c", "Deus")),
            "a",
            "não de obras, para que ___ se glorie",
        ),
        choice(
            "profundezas",
            "interpret",
            "03",
            "Qual leitura interpreta melhor o sentido teológico de Efésios 2:8–9?",
            "Certo: o dom deixa a glória em Deus, não no homem.",
            {
                "a": "O texto impede a glória humana, inclusive da fé como mérito.",
                "b": "Obras não merecem a graça; o texto as exclui como causa.",
                "d": "Autojustificação contradiz ‘não de obras’.",
            },
            opts(
                ("a", "Deus salva para que o salvo se glorie da própria fé"),
                ("b", "Obras merecem a graça, e a fé descreve o mérito"),
                ("c", "A salvação é dom, de modo que a glória não fica no homem"),
                ("d", "O texto ensina autojustificação pela disciplina religiosa"),
            ),
            "c",
        ),
        order(
            "profundezas",
            "interpret",
            "04",
            f"Qual sequência revela o sentido de {R1}?",
            "Certo: graça recebida, origem divina, fim do orgulho.",
            {
                "b": "O sentido começa na graça, não na exclusão das obras.",
                "c": "A jactância é o que o texto impede no fim.",
            },
            O1,
        ),
        complete(
            "profundezas",
            "interpret",
            "05",
            "é o ___ de Deus; não de obras",
            "Certo: é o dom de Deus, não de obras.",
            {"b": "Fé é o meio no início, não esta palavra.", "c": "Ninguém pertence à cláusula da glória."},
            opts(("a", "dom"), ("b", "fé"), ("c", "ninguém")),
            "a",
            "é o ___ de Deus; não de obras",
        ),
        connect(
            "profundezas",
            "interpret",
            "06",
            R1,
            "Certo: a graça impede que alguém se glorie de si.",
            {
                "b": "O trecho não funda salvação no desempenho.",
                "c": "A glória do eu é o que o texto recusa.",
            },
            opts(
                ("a", "Graça que impede a jactância"),
                ("b", "Mérito que compra o favor"),
                ("c", "Orgulho santo do salvo"),
            ),
            "a",
            P1,
            INS1,
        ),
    ],
)

# --- M2 ---
O2 = opts(
    ("a", "Deus prova o seu amor para conosco"),
    ("b", "quando éramos ainda pecadores"),
    ("c", "morreu Cristo por nós"),
)

m2 = pack(
    "so-02-cruz",
    R2,
    LO2,
    EV2,
    P2,
    [
        tf(
            "semente",
            "observe",
            "01",
            "Éramos ainda pecadores, e morreu Cristo por nós.",
            "Certo: Romanos 5:8 registra exatamente isso.",
            {"false": "Releia: Cristo morreu por nós ainda pecadores."},
            "true",
        ),
        tap(
            "semente",
            "observe",
            "02",
            R2,
            "quando éramos ainda ___, morreu Cristo por nós",
            "Exato: ainda pecadores, morreu Cristo por nós.",
            {"b": "Amor é o que Deus prova, não esta lacuna.", "c": "Cristo é quem morre, não o estado descrito."},
            opts(("a", "pecadores"), ("b", "amor"), ("c", "Cristo")),
            "a",
            "quando éramos ainda ___, morreu Cristo por nós",
        ),
        choice(
            "semente",
            "observe",
            "03",
            "Qual fato Romanos 5:8 afirma sobre o amor de Deus?",
            "Certo: o amor se prova na morte de Cristo por pecadores.",
            {
                "b": "O texto situa a morte ‘quando éramos ainda pecadores’.",
                "c": "Quem morre é Cristo, e o amor é de Deus.",
                "d": "O texto fala de morte por nós, não de melhoria prévia.",
            },
            opts(
                ("a", "Deus prova o seu amor: Cristo morreu por nós pecadores"),
                ("b", "Cristo morreu depois que já deixáramos de pecar"),
                ("c", "O texto diz que nós morremos para provar o amor a Deus"),
                ("d", "O amor de Deus se prova na nossa reforma moral"),
            ),
            "a",
        ),
        order(
            "semente",
            "observe",
            "04",
            f"Qual sequência mostra a ordem dos fatos em {R2}?",
            "Certo: Deus prova o amor, ainda pecadores, Cristo morre.",
            {
                "b": "O estado de pecadores vem antes da morte de Cristo.",
                "c": "A prova do amor abre o versículo, não o fecha.",
            },
            O2,
        ),
        complete(
            "semente",
            "observe",
            "05",
            "Deus prova o seu ___ para conosco",
            "Certo: Deus prova o seu amor para conosco.",
            {"b": "Cristo é quem morre, não o que é provado aqui.", "c": "Nós recebemos o amor, não preenchemos a lacuna."},
            opts(("a", "amor"), ("b", "Cristo"), ("c", "nós")),
            "a",
            "Deus prova o seu ___ para conosco",
        ),
        connect(
            "semente",
            "observe",
            "06",
            R2,
            "Certo: o amor de Deus se mostra na cruz por pecadores.",
            {
                "b": "O texto não espera melhoria para então amar.",
                "c": "A prova não é o nosso sentimento, e sim a cruz.",
            },
            opts(
                ("a", "Amor provado na cruz"),
                ("b", "Amor após nossa melhoria"),
                ("c", "Amor como sentimento nosso"),
            ),
            "a",
            P2,
            INS2,
        ),
        tf(
            "caminhada",
            "understand",
            "01",
            "O texto diz que Cristo morreu depois que já tínhamos deixado de ser pecadores.",
            "Certo: a morte ocorre quando ainda éramos pecadores.",
            {"true": "O ‘ainda pecadores’ recusa a ideia de melhoria prévia."},
            "false",
        ),
        tap(
            "caminhada",
            "understand",
            "02",
            R2,
            "quando éramos ainda pecadores, morreu ___ por nós",
            "Exato: morreu Cristo por nós.",
            {"b": "Deus prova o amor; quem morre é Cristo.", "c": "Pecadores descreve o nosso estado, não o sujeito."},
            opts(("a", "Cristo"), ("b", "Deus"), ("c", "pecadores")),
            "a",
            "quando éramos ainda pecadores, morreu ___ por nós",
        ),
        choice(
            "caminhada",
            "understand",
            "03",
            "Como Romanos 5:8 liga o amor de Deus ao tempo da cruz?",
            "Certo: a prova do amor é a morte por quem ainda pecava.",
            {
                "a": "O texto não espera reforma para então enviar Cristo.",
                "c": "A iniciativa é de Deus, não de um pedido nosso.",
                "d": "A cruz não é ilustração vazia: é a prova do amor.",
            },
            opts(
                ("a", "Cristo morre só depois que o pecador já se reformou"),
                ("b", "A prova do amor é a morte por quem ainda pecava"),
                ("c", "O amor de Deus espera primeiro o nosso pedido"),
                ("d", "A cruz apenas ilustra um sentimento, sem ato real"),
            ),
            "b",
        ),
        order(
            "caminhada",
            "understand",
            "04",
            f"Como se encadeiam os eventos de {R2}?",
            "Certo: prova do amor, estado de pecadores, morte de Cristo.",
            {
                "b": "A morte não precede o ‘ainda pecadores’ no texto.",
                "c": "A prova do amor vem primeiro, não por último.",
            },
            O2,
        ),
        complete(
            "caminhada",
            "understand",
            "05",
            "quando éramos ___ pecadores, morreu Cristo por nós",
            "Certo: éramos ainda pecadores.",
            {"b": "Deus abre o versículo, não esta lacuna.", "c": "Nós somos os pecadores, não o advérbio."},
            opts(("a", "ainda"), ("b", "Deus"), ("c", "nós")),
            "a",
            "quando éramos ___ pecadores, morreu Cristo por nós",
        ),
        connect(
            "caminhada",
            "understand",
            "06",
            R2,
            "Certo: a cruz vem antes de qualquer melhoria nossa.",
            {
                "b": "O texto não faz da cruz um prêmio ao justo.",
                "c": "A reconciliação parte de Deus, não do pecador.",
            },
            opts(
                ("a", "Cruz antes da melhoria"),
                ("b", "Prêmio aos já justos"),
                ("c", "Iniciativa do pecador"),
            ),
            "a",
            P2,
            INS2,
        ),
        tf(
            "profundezas",
            "interpret",
            "01",
            "O amor de Deus se prova na cruz, não na nossa melhoria prévia.",
            "Certo: a prova é a morte de Cristo por pecadores.",
            {"false": "Romanos 5:8 situa o amor na cruz, não no nosso progresso."},
            "true",
        ),
        tap(
            "profundezas",
            "interpret",
            "02",
            R2,
            "quando éramos ainda pecadores, ___ Cristo por nós",
            "Exato: morreu Cristo por nós.",
            {"b": "Prova descreve o ato de Deus, não esta lacuna.", "c": "Amor é o que é provado, não o verbo da morte."},
            opts(("a", "morreu"), ("b", "prova"), ("c", "amor")),
            "a",
            "quando éramos ainda pecadores, ___ Cristo por nós",
        ),
        choice(
            "profundezas",
            "interpret",
            "03",
            "Qual leitura interpreta melhor o sentido teológico de Romanos 5:8?",
            "Certo: o amor se demonstra na morte por quem não merecia.",
            {
                "a": "O texto não exige mérito para a cruz acontecer.",
                "b": "A cruz não é só exemplo: é prova do amor de Deus.",
                "d": "O pecador não conquista o amor; o recebe na cruz.",
            },
            opts(
                ("a", "Deus ama depois que o pecador se torna digno"),
                ("b", "A cruz só inspira ética, sem provar o amor de Deus"),
                ("c", "Deus ama o pecador na morte de Cristo, sem mérito prévio"),
                ("d", "O pecador precisa primeiro amar a Deus para ser amado"),
            ),
            "c",
        ),
        order(
            "profundezas",
            "interpret",
            "04",
            f"Qual sequência revela o sentido de {R2}?",
            "Certo: amor provado, pecadores, Cristo por nós.",
            {
                "b": "O sentido começa na prova do amor, não na morte isolada.",
                "c": "A morte de Cristo conclui a prova, não a abre.",
            },
            O2,
        ),
        complete(
            "profundezas",
            "interpret",
            "05",
            "Deus prova o seu amor para ___ em que",
            "Certo: o amor é para conosco.",
            {"b": "Pecadores descreve o estado, não o ‘para’.", "c": "Cristo é quem morre, não o complemento aqui."},
            opts(("a", "conosco"), ("b", "pecadores"), ("c", "Cristo")),
            "a",
            "Deus prova o seu amor para ___ em que",
        ),
        connect(
            "profundezas",
            "interpret",
            "06",
            R2,
            "Certo: o amor de Deus alcança quem ainda era pecador.",
            {
                "b": "O texto não condiciona o amor à nossa reforma.",
                "c": "A cruz não é prêmio; é prova a favor de pecadores.",
            },
            opts(
                ("a", "Amor por pecadores"),
                ("b", "Amor só aos reformados"),
                ("c", "Cruz como prêmio moral"),
            ),
            "a",
            P2,
            INS2,
        ),
    ],
)

# --- M3 ---
O3 = opts(
    ("a", "Jesus respondeu-lhe: Em verdade, em verdade te digo"),
    ("b", "se alguém não nascer de novo"),
    ("c", "não pode ver o reino de Deus"),
)

m3 = pack(
    "so-03-nascimento",
    R3,
    LO3,
    EV3,
    P3,
    [
        tf(
            "semente",
            "observe",
            "01",
            "Se alguém não nascer de novo, não pode ver o reino de Deus.",
            "Certo: é a afirmação literal de João 3:3.",
            {"false": "Releia: sem nascer de novo, ninguém vê o reino."},
            "true",
        ),
        tap(
            "semente",
            "observe",
            "02",
            R3,
            "se alguém não nascer de ___, não pode ver o reino de Deus",
            "Exato: é preciso nascer de novo.",
            {"b": "Reino é o que se vê, não o modo do nascimento.", "c": "Jesus fala; a lacuna pede ‘novo’."},
            opts(("a", "novo"), ("b", "reino"), ("c", "Jesus")),
            "a",
            "se alguém não nascer de ___, não pode ver o reino de Deus",
        ),
        choice(
            "semente",
            "observe",
            "03",
            "Qual fato João 3:3 afirma sobre o reino de Deus?",
            "Certo: sem nascer de novo, ninguém pode ver o reino.",
            {
                "b": "O texto não oferece a reforma como substituto.",
                "c": "Jesus afirma a necessidade, não a recusa.",
                "d": "O requisito é nascer de novo, não só estudar.",
            },
            opts(
                ("a", "Quem não nascer de novo não pode ver o reino de Deus"),
                ("b", "Basta reformar costumes para ver o reino"),
                ("c", "Jesus diz que nascer de novo é opcional"),
                ("d", "O reino se vê só com estudo, sem novo nascimento"),
            ),
            "a",
        ),
        order(
            "semente",
            "observe",
            "04",
            f"Qual sequência mostra a ordem dos fatos em {R3}?",
            "Certo: Jesus fala, exige nascer de novo, e então ver o reino.",
            {
                "b": "A condição do nascimento vem antes de ver o reino.",
                "c": "A resposta de Jesus abre o versículo.",
            },
            O3,
        ),
        complete(
            "semente",
            "observe",
            "05",
            "não pode ver o ___ de Deus",
            "Certo: não pode ver o reino de Deus.",
            {"b": "Novo descreve o nascimento, não o que se vê.", "c": "Jesus é quem responde, não esta palavra."},
            opts(("a", "reino"), ("b", "novo"), ("c", "Jesus")),
            "a",
            "não pode ver o ___ de Deus",
        ),
        connect(
            "semente",
            "observe",
            "06",
            R3,
            "Certo: a salvação é vida nova, não só ajuste de hábitos.",
            {
                "b": "O texto exige nascimento, não só reforma.",
                "c": "Ver o reino não é só informação religiosa.",
            },
            opts(
                ("a", "Salvação é vida nova"),
                ("b", "Basta reforma de hábitos"),
                ("c", "Reino como só informação"),
            ),
            "a",
            P3,
            INS3,
        ),
        tf(
            "caminhada",
            "understand",
            "01",
            "O texto ensina que reforma moral basta para ver o reino, sem nascer de novo.",
            "Certo: sem nascer de novo, ninguém pode ver o reino.",
            {"true": "Jesus recusa o acesso ao reino sem novo nascimento."},
            "false",
        ),
        tap(
            "caminhada",
            "understand",
            "02",
            R3,
            "se alguém não ___ de novo, não pode ver o reino de Deus",
            "Exato: é preciso nascer de novo.",
            {"b": "Ver é o resultado; a lacuna pede o verbo ‘nascer’.", "c": "Digo pertence à fórmula de Jesus, não aqui."},
            opts(("a", "nascer"), ("b", "ver"), ("c", "digo")),
            "a",
            "se alguém não ___ de novo, não pode ver o reino de Deus",
        ),
        choice(
            "caminhada",
            "understand",
            "03",
            "Como João 3:3 relaciona novo nascimento e o reino?",
            "Certo: ver o reino depende de nascer de novo.",
            {
                "a": "O texto não trata o nascimento como metáfora vazia.",
                "c": "Não há exceção para os ‘quase bons’.",
                "d": "A condição é vida nova, não só ética melhor.",
            },
            opts(
                ("a", "Nascer de novo é só imagem, sem exigência real"),
                ("b", "Sem novo nascimento, ninguém pode ver o reino"),
                ("c", "Quem já é religioso dispensa nascer de novo"),
                ("d", "O reino se alcança só com esforço moral crescente"),
            ),
            "b",
        ),
        order(
            "caminhada",
            "understand",
            "04",
            f"Como se encadeiam os eventos de {R3}?",
            "Certo: palavra de Jesus, condição do nascimento, ver o reino.",
            {
                "b": "Ver o reino não precede a condição de nascer de novo.",
                "c": "A resposta de Jesus vem primeiro.",
            },
            O3,
        ),
        complete(
            "caminhada",
            "understand",
            "05",
            "se ___ não nascer de novo, não pode ver o reino de Deus",
            "Certo: se alguém não nascer de novo.",
            {"b": "Verdade abre o dito de Jesus, não esta lacuna.", "c": "Reino é o que se vê, não o sujeito da frase."},
            opts(("a", "alguém"), ("b", "verdade"), ("c", "reino")),
            "a",
            "se ___ não nascer de novo, não pode ver o reino de Deus",
        ),
        connect(
            "caminhada",
            "understand",
            "06",
            R3,
            "Certo: ver o reino exige nascimento, não só reforma.",
            {
                "b": "Reforma não substitui o nascer de novo.",
                "c": "O acesso não é automático por religião prévia.",
            },
            opts(
                ("a", "Ver o reino exige nascimento"),
                ("b", "Reforma substitui o nascimento"),
                ("c", "Acesso automático ao reino"),
            ),
            "a",
            P3,
            INS3,
        ),
        tf(
            "profundezas",
            "interpret",
            "01",
            "Sem novo nascimento ninguém vê o reino: salvação é vida, não só reforma.",
            "Certo: João 3:3 exige nascer de novo para ver o reino.",
            {"false": "O texto trata de vida nova, não de mero conserto moral."},
            "true",
        ),
        tap(
            "profundezas",
            "interpret",
            "02",
            R3,
            "Em ___, em verdade te digo que, se alguém não nascer de novo",
            "Exato: Em verdade, em verdade te digo.",
            {"b": "Novo descreve o nascimento, não esta fórmula.", "c": "Reino aparece no fim, não nesta lacuna."},
            opts(("a", "verdade"), ("b", "novo"), ("c", "reino")),
            "a",
            "Em ___, em verdade te digo que, se alguém não nascer de novo",
        ),
        choice(
            "profundezas",
            "interpret",
            "03",
            "Qual leitura interpreta melhor o sentido teológico de João 3:3?",
            "Certo: o reino se vê por vida nova, não por conserto superficial.",
            {
                "a": "Jesus não reduz o reino a progresso ético.",
                "b": "A condição é real: sem nascer de novo, não se vê.",
                "d": "Nicodemos ouve exigência de vida, não de técnica.",
            },
            opts(
                ("a", "O reino se vê por progresso ético, sem vida nova"),
                ("b", "Nascer de novo é opcional para quem já é piedoso"),
                ("c", "Salvação é vida nova: sem nascer de novo, não se vê o reino"),
                ("d", "Jesus ensina só um método de autoaperfeiçoamento"),
            ),
            "c",
        ),
        order(
            "profundezas",
            "interpret",
            "04",
            f"Qual sequência revela o sentido de {R3}?",
            "Certo: a palavra de Jesus, o nascimento, o ver o reino.",
            {
                "b": "O sentido começa na palavra de Jesus, não no reino isolado.",
                "c": "Ver o reino é o desfecho, não o início.",
            },
            O3,
        ),
        complete(
            "profundezas",
            "interpret",
            "05",
            "não pode ver o reino de ___",
            "Certo: o reino de Deus.",
            {"b": "Alguém é o sujeito da condição, não o dono do reino.", "c": "Novo descreve o nascimento."},
            opts(("a", "Deus"), ("b", "alguém"), ("c", "novo")),
            "a",
            "não pode ver o reino de ___",
        ),
        connect(
            "profundezas",
            "interpret",
            "06",
            R3,
            "Certo: o reino se encontra por nascimento, não por conserto.",
            {
                "b": "O texto não reduz a salvação a ética melhor.",
                "c": "Entrar no reino não é só mudar de grupo.",
            },
            opts(
                ("a", "Reino por nascimento novo"),
                ("b", "Reino por ética melhor"),
                ("c", "Reino por mudança de grupo"),
            ),
            "a",
            P3,
            INS3,
        ),
    ],
)

# --- Boss ---
OB = opts(
    ("a", "Pois pela graça é que sois salvos, mediante a fé"),
    ("b", "quando éramos ainda pecadores, morreu Cristo por nós"),
    ("c", "se alguém não nascer de novo, não pode ver o reino de Deus"),
)

mb = pack(
    "so-boss",
    RB,
    LOB,
    EVB,
    PBOSS,
    [
        tf(
            "semente",
            "observe",
            "01",
            "Pela graça é que sois salvos, mediante a fé; Cristo morreu por pecadores; é preciso nascer de novo.",
            "Certo: os três textos afirmam graça, cruz e novo nascimento.",
            {"false": "Os trechos combinados dizem exatamente isso."},
            "true",
        ),
        tap(
            "semente",
            "observe",
            "02",
            RB,
            "Pois pela ___ é que sois salvos, mediante a fé",
            "Exato: a salvação é pela graça.",
            {"b": "Pecadores está em Romanos 5:8, não nesta lacuna.", "c": "Reino está em João 3:3, não aqui."},
            opts(("a", "graça"), ("b", "pecadores"), ("c", "reino")),
            "a",
            "Pois pela ___ é que sois salvos, mediante a fé",
        ),
        choice(
            "semente",
            "observe",
            "03",
            "O que os três textos afirmam juntos sobre a salvação?",
            "Certo: graça como dom, cruz por pecadores e nascer de novo.",
            {
                "b": "Efésios 2 recusa obras como causa.",
                "c": "Romanos 5 situa a cruz ainda em pecadores.",
                "d": "João 3 exige nascer de novo, não só reforma.",
            },
            opts(
                ("a", "Dom da graça, cruz por pecadores e nascimento de novo"),
                ("b", "Salvação por obras, cruz só para justos e reforma"),
                ("c", "Cristo morre depois da nossa melhoria moral"),
                ("d", "O reino se vê sem nascer de novo, só com esforço"),
            ),
            "a",
        ),
        order(
            "semente",
            "observe",
            "04",
            f"Qual sequência mostra a ordem dos fatos em {RB}?",
            "Certo: graça e fé, cruz por pecadores, nascer de novo.",
            {
                "b": "A graça de Efésios 2 abre o conjunto, não o fecha.",
                "c": "O novo nascimento de João 3 vem por último.",
            },
            OB,
        ),
        complete(
            "semente",
            "observe",
            "05",
            "não de ___, para que ninguém se glorie",
            "Certo: não de obras, para que ninguém se glorie.",
            {"b": "Fé é o meio em Efésios 2:8, não esta lacuna.", "c": "Amor é o tema de Romanos 5:8."},
            opts(("a", "obras"), ("b", "fé"), ("c", "amor")),
            "a",
            "não de ___, para que ninguém se glorie",
        ),
        connect(
            "semente",
            "observe",
            "06",
            RB,
            "Certo: os três eixos da graça salvadora aparecem juntos.",
            {
                "b": "O conjunto não descreve autojustificação.",
                "c": "A cruz e o nascimento não são prêmios ao mérito.",
            },
            opts(
                ("a", "Dom, cruz e nascimento"),
                ("b", "Mérito, reforma e orgulho"),
                ("c", "Salário pela santidade prévia"),
            ),
            "a",
            PBOSS,
            INSB,
        ),
        tf(
            "caminhada",
            "understand",
            "01",
            "Os três textos ensinam que a salvação é conquista por obras, depois da nossa melhoria e sem nascer de novo.",
            "Certo: é dom, cruz por pecadores e nascimento de novo.",
            {"true": "O conjunto recusa obras, melhoria prévia e só reforma."},
            "false",
        ),
        tap(
            "caminhada",
            "understand",
            "02",
            RB,
            "quando éramos ainda ___, morreu Cristo por nós",
            "Exato: ainda pecadores, morreu Cristo por nós.",
            {"b": "Graça está em Efésios 2, não nesta lacuna.", "c": "Novo descreve o nascimento em João 3."},
            opts(("a", "pecadores"), ("b", "graça"), ("c", "novo")),
            "a",
            "quando éramos ainda ___, morreu Cristo por nós",
        ),
        choice(
            "caminhada",
            "understand",
            "03",
            "Como se encadeiam graça, cruz e novo nascimento nestes textos?",
            "Certo: o dom chega na cruz por pecadores e gera vida nova.",
            {
                "a": "A cruz não espera o mérito; Romanos 5 o recusa.",
                "c": "João 3 não trata o nascimento como adorno opcional.",
                "d": "Efésios 2 não faz das obras a causa da salvação.",
            },
            opts(
                ("a", "Primeiro o mérito, depois a cruz, enfim a graça"),
                ("b", "O dom se prova na cruz por pecadores e pede vida nova"),
                ("c", "Nascer de novo é extra, se a graça já bastou"),
                ("d", "Obras unem os três textos como causa da salvação"),
            ),
            "b",
        ),
        order(
            "caminhada",
            "understand",
            "04",
            f"Como se encadeiam os eventos de {RB}?",
            "Certo: graça recebida, cruz por pecadores, ver o reino nascendo de novo.",
            {
                "b": "A ordem pedagógica vai de Efésios a Romanos a João.",
                "c": "O nascimento de novo não abre o conjunto.",
            },
            OB,
        ),
        complete(
            "caminhada",
            "understand",
            "05",
            "Pois pela graça é que sois salvos, mediante a ___",
            "Certo: mediante a fé.",
            {"b": "Obras são excluídas no v. 9.", "c": "Reino pertence a João 3:3."},
            opts(("a", "fé"), ("b", "obras"), ("c", "reino")),
            "a",
            "Pois pela graça é que sois salvos, mediante a ___",
        ),
        connect(
            "caminhada",
            "understand",
            "06",
            RB,
            "Certo: a graça salvadora une presente, cruz e vida nova.",
            {
                "b": "Não há cadeia de mérito humano nestes textos.",
                "c": "Reforma sozinha não esgota a salvação bíblica.",
            },
            opts(
                ("a", "Graça, cruz e vida nova"),
                ("b", "Cadeia de mérito humano"),
                ("c", "Só reforma sem a cruz"),
            ),
            "a",
            PBOSS,
            INSB,
        ),
        tf(
            "profundezas",
            "interpret",
            "01",
            "Graça salvadora: dom, cruz por pecadores e nascimento de novo.",
            "Certo: os três textos formam esse eixo da salvação.",
            {"false": "Essa é a leitura teológica que o conjunto sustenta."},
            "true",
        ),
        tap(
            "profundezas",
            "interpret",
            "02",
            RB,
            "se alguém não ___ de novo, não pode ver o reino de Deus",
            "Exato: é preciso nascer de novo.",
            {"b": "Morreu descreve a cruz, não esta lacuna.", "c": "Dom está em Efésios 2, não aqui."},
            opts(("a", "nascer"), ("b", "morreu"), ("c", "dom")),
            "a",
            "se alguém não ___ de novo, não pode ver o reino de Deus",
        ),
        choice(
            "profundezas",
            "interpret",
            "03",
            "Qual leitura interpreta melhor o conjunto de Efésios 2, Romanos 5 e João 3?",
            "Certo: salvação é dom, amor na cruz e vida nova.",
            {
                "a": "Os textos recusam o mérito como causa.",
                "b": "A cruz não espera reforma prévia.",
                "d": "João 3 não reduz o reino a ética melhor.",
            },
            opts(
                ("a", "A salvação é salário de quem já se melhorou"),
                ("b", "Cristo morre só pelos que já nasceram de novo"),
                ("c", "Deus salva por graça, ama na cruz e gera vida nova"),
                ("d", "Basta reforma moral, sem dom, cruz nem nascimento"),
            ),
            "c",
        ),
        order(
            "profundezas",
            "interpret",
            "04",
            f"Qual sequência revela o sentido de {RB}?",
            "Certo: o dom, a cruz por pecadores e o nascer de novo.",
            {
                "b": "O sentido começa na graça, não no reino isolado.",
                "c": "O novo nascimento conclui o eixo, não o inicia.",
            },
            OB,
        ),
        complete(
            "profundezas",
            "interpret",
            "05",
            "quando éramos ainda pecadores, morreu ___ por nós",
            "Certo: morreu Cristo por nós.",
            {"b": "Deus prova o amor; quem morre é Cristo.", "c": "Alguém pertence a João 3:3."},
            opts(("a", "Cristo"), ("b", "Deus"), ("c", "alguém")),
            "a",
            "quando éramos ainda pecadores, morreu ___ por nós",
        ),
        connect(
            "profundezas",
            "interpret",
            "06",
            RB,
            "Certo: a graça salvadora une dom, cruz e nascimento.",
            {
                "b": "O conjunto não descreve auto-salvação.",
                "c": "O orgulho religioso é o que esses textos cortam.",
            },
            opts(
                ("a", "Graça salvadora completa"),
                ("b", "Auto-salvação por esforço"),
                ("c", "Orgulho da religião prévia"),
            ),
            "a",
            PBOSS,
            INSB,
        ),
    ],
)

bank = m1 + m2 + m3 + mb
assert len(bank) == 72, len(bank)

# checks locais
for q in bank:
    assert len(q["feedbackCorrect"]) <= 100, (q["id"], len(q["feedbackCorrect"]), q["feedbackCorrect"])
    if q["type"] == "choice":
        for o in q["options"]:
            assert len(o["text"]) <= 90, (q["id"], len(o["text"]), o["text"])
    assert q["question"] == q["prompt"] == q["cue"]

OUT.write_text(json.dumps(bank, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {OUT} ({len(bank)} questions)")
