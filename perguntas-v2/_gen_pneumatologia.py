#!/usr/bin/env python3
"""Gera perguntas-v2/pneumatologia.json no padrão Oséias STWAY V2."""
from __future__ import annotations

import json
from copy import deepcopy
from pathlib import Path

OUT = Path(__file__).with_name("pneumatologia.json")

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


TRAIL = "pneumatologia"

P1 = (
    "Pedro disse-lhe: Ananias, por que encheu Satanás o teu coração, para que mentisses ao Espírito Santo "
    "e retivesses parte do preço do terreno? Porventura, se não o vendesses, não seria ele teu; e, vendido, "
    "não estava o preço no teu poder? Como formaste esse desígnio no teu coração? Não mentiste aos homens, mas a Deus."
)
P2 = (
    "Vós, porém, não estais sujeitos à carne, mas ao Espírito, se realmente o Espírito de Deus habita em vós. "
    "Mas, se alguém não tem o Espírito de Cristo, esse não é dele. Se Cristo está em vós, o corpo, na verdade, "
    "está morto por causa do pecado, mas o espírito é vida por causa da justiça."
)
P3 = (
    "Mas o fruto do Espírito é a caridade, o gozo, a paz, a longanimidade, a benignidade, a bondade, a fidelidade, "
    "a mansidão, a temperança. Contra tais coisas não há lei."
)
P4 = (
    "Não mentiste aos homens, mas a Deus. Vós, porém, não estais sujeitos à carne, mas ao Espírito, se realmente "
    "o Espírito de Deus habita em vós. Mas, se alguém não tem o Espírito de Cristo, esse não é dele. "
    "Mas o fruto do Espírito é a caridade, o gozo, a paz, a longanimidade, a benignidade, a bondade, a fidelidade, "
    "a mansidão, a temperança."
)

LO1 = "Reconhecer que o Espírito Santo é Deus: mentir a ele é mentir a Deus, não a um poder impessoal."
LO2 = "Reconhecer que o Espírito habita no crente e quem não tem o Espírito de Cristo não é dele."
LO3 = "Reconhecer que o Espírito produz caráter — contra o fruto não há lei."
LOB = "Integrar vida no Espírito: ele é Deus, habita no crente e produz fruto."

EV1 = ["Atos 5:3", "Atos 5:4"]
EV2 = ["Romanos 8:9", "Romanos 8:10", "Romanos 8:11"]
EV3 = ["Gálatas 5:22", "Gálatas 5:23"]
EVB = ["Atos 5:4", "Romanos 8:9", "Gálatas 5:22"]

R1 = "Atos 5:3–4"
R2 = "Romanos 8:9–11"
R3 = "Gálatas 5:22–23"
RB = "Atos 5:4; Romanos 8:9; Gálatas 5:22"

INS1 = "O Espírito é Deus: mentir ao Espírito Santo é mentir a Deus, não a um poder impessoal."
INS2 = "Nova vida pelo Espírito: quem não tem o Espírito de Cristo não é dele; o Espírito habita e vivifica."
INS3 = "Fruto e dons: o Espírito produz caráter — contra o fruto não há lei."
INSB = "Vida no Espírito: ele é Deus, habita no crente e produz fruto."


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


m1 = pack(
    "pn-01-pessoa",
    R1,
    LO1,
    EV1,
    P1,
    [
        tf(
            "semente",
            "observe",
            "01",
            "Ananias mentiu ao Espírito Santo e reteve parte do preço do terreno.",
            "Certo: Pedro afirma essa mentira e a retenção do preço.",
            {"false": "Releia: ele mentiu ao Espírito Santo e reteve parte do preço."},
            "true",
        ),
        tap(
            "semente",
            "observe",
            "02",
            R1,
            "para que ___ ao Espírito Santo e retivesses parte do preço do terreno",
            "Exato: Ananias mentiu ao Espírito Santo.",
            {
                "b": "Vendesses fala do terreno, não desta lacuna.",
                "c": "Formaste aparece depois, no desígnio do coração.",
            },
            opts(("a", "mentisses"), ("b", "vendesses"), ("c", "formaste")),
            "a",
            "para que ___ ao Espírito Santo e retivesses parte do preço do terreno",
        ),
        choice(
            "semente",
            "observe",
            "03",
            "Qual fato Atos 5:3–4 afirma de modo explícito?",
            "Certo: a mentira foi ao Espírito Santo, com retenção do preço.",
            {
                "b": "O texto não diz que o terreno ficou sem venda.",
                "c": "Pedro nega que a mentira tenha sido só aos homens.",
                "d": "Satanás encheu o coração; não há ordem de venda.",
            },
            opts(
                ("a", "Ananias mentiu ao Espírito Santo e reteve parte do preço."),
                ("b", "Ananias devolveu o terreno sem jamais vendê-lo."),
                ("c", "A mentira de Ananias foi somente a Pedro."),
                ("d", "Satanás ordenou que Ananias vendesse o terreno."),
            ),
            "a",
        ),
        order(
            "semente",
            "observe",
            "04",
            "Qual sequência mostra a ordem dos fatos em Atos 5:3–4?",
            "Certo: essa é a ordem que o texto apresenta.",
            {
                "b": "Esse trecho vem depois da fala inicial de Pedro.",
                "c": "A declaração a Deus fecha o trecho, não o abre.",
            },
            opts(
                ("a", "Pedro disse-lhe: Ananias, por que encheu Satanás o teu coração"),
                ("b", "para que mentisses ao Espírito Santo e retivesses parte do preço do terreno"),
                ("c", "Não mentiste aos homens, mas a Deus"),
            ),
        ),
        complete(
            "semente",
            "observe",
            "05",
            "Não mentiste aos homens, mas a ___",
            "Certo: a mentira foi a Deus, não aos homens.",
            {
                "b": "Satanás encheu o coração; a lacuna pede a quem se mentiu.",
                "c": "Ananias é o acusado, não o destinatário da mentira.",
            },
            opts(("a", "Deus"), ("b", "Satanás"), ("c", "Ananias")),
            "a",
            "Não mentiste aos homens, mas a ___",
        ),
        connect(
            "semente",
            "observe",
            "06",
            R1,
            "Certo: mentir ao Espírito Santo é mentir a Deus.",
            {
                "b": "O texto não trata o Espírito como força sem pessoa.",
                "c": "Pedro recusa reduzir a mentira a um engano só humano.",
            },
            opts(
                ("a", "Mentira ao Espírito é a Deus"),
                ("b", "Espírito como poder impessoal"),
                ("c", "Mentira só contra homens"),
            ),
            "a",
            P1,
            INS1,
        ),
        tf(
            "caminhada",
            "understand",
            "01",
            "Pedro ensina que mentir ao Espírito Santo é o mesmo que mentir somente aos homens.",
            "Certo: ele diz que a mentira não foi aos homens, mas a Deus.",
            {"true": "O texto opõe homens e Deus: a mentira foi a Deus."},
            "false",
        ),
        tap(
            "caminhada",
            "understand",
            "02",
            R1,
            "Não mentiste aos ___, mas a Deus",
            "Exato: a mentira não foi aos homens.",
            {
                "b": "Satanás encheu o coração, mas não preenche esta lacuna.",
                "c": "Terreno é o bem vendido, não o alvo da frase.",
            },
            opts(("a", "homens"), ("b", "Satanás"), ("c", "terreno")),
            "a",
            "Não mentiste aos ___, mas a Deus",
        ),
        choice(
            "caminhada",
            "understand",
            "03",
            "Qual relação Atos 5:3–4 estabelece entre o Espírito Santo e Deus?",
            "Certo: mentir ao Espírito Santo é mentir a Deus.",
            {
                "b": "O texto trata o Espírito como alguém a quem se mente.",
                "c": "Não há rivalidade: o Espírito é identificado com Deus.",
                "d": "Pedro não relativiza a gravidade diante de Deus.",
            },
            opts(
                ("a", "Mentir ao Espírito Santo é mentir a Deus."),
                ("b", "O Espírito Santo é só uma força que Deus usa de longe."),
                ("c", "Deus e o Espírito Santo aparecem como rivais no relato."),
                ("d", "Mentir a Deus seria menos grave do que mentir a Pedro."),
            ),
            "a",
        ),
        order(
            "caminhada",
            "understand",
            "04",
            "Como se encadeiam os eventos de Atos 5:3–4?",
            "Certo: propriedade, poder sobre o preço e o desígnio no coração.",
            {
                "b": "O preço no poder vem depois da posse do terreno.",
                "c": "O desígnio no coração é o desfecho desta cadeia.",
            },
            opts(
                ("a", "se não o vendesses, não seria ele teu"),
                ("b", "e, vendido, não estava o preço no teu poder"),
                ("c", "Como formaste esse desígnio no teu coração"),
            ),
        ),
        complete(
            "caminhada",
            "understand",
            "05",
            "para que mentisses ao Espírito ___ e retivesses parte do preço",
            "Certo: o texto diz Espírito Santo.",
            {
                "b": "Terreno é o bem, não o nome do Espírito.",
                "c": "Poder fala do preço vendido, não desta lacuna.",
            },
            opts(("a", "Santo"), ("b", "terreno"), ("c", "poder")),
            "a",
            "para que mentisses ao Espírito ___ e retivesses parte do preço",
        ),
        connect(
            "caminhada",
            "understand",
            "06",
            R1,
            "Certo: o Espírito é pessoa divina, não força sem juízo.",
            {
                "b": "Mentir a ele mostra pessoa, não energia sem identidade.",
                "c": "Pedro não o reduz a um mensageiro criado.",
            },
            opts(
                ("a", "Espírito como pessoa divina"),
                ("b", "Força sem identidade"),
                ("c", "Apenas um anjo criado"),
            ),
            "a",
            P1,
            INS1,
        ),
        tf(
            "profundezas",
            "interpret",
            "01",
            "Neste texto, o Espírito Santo é tratado como Deus, não como um poder impessoal.",
            "Certo: mentir a ele é mentir a Deus.",
            {"false": "Pedro identifica a mentira ao Espírito com a mentira a Deus."},
            "true",
        ),
        tap(
            "profundezas",
            "interpret",
            "02",
            R1,
            "Não mentiste aos homens, mas a ___",
            "Exato: a mentira foi a Deus.",
            {
                "a": "Pedro fala, mas não preenche esta lacuna.",
                "b": "Preço é o valor do terreno, não o alvo da mentira.",
            },
            opts(("a", "Pedro"), ("b", "preço"), ("c", "Deus")),
            "c",
            "Não mentiste aos homens, mas a ___",
        ),
        choice(
            "profundezas",
            "interpret",
            "03",
            "O que o leitor deve concluir sobre o Espírito Santo em Atos 5:3–4?",
            "Certo: ele é Deus pessoal, a quem se pode mentir.",
            {
                "b": "Energia sem vontade não recebe mentira nem juízo.",
                "c": "O texto não o rebaixa: iguala a mentira a Deus.",
                "d": "A cena é na igreja, no coração, não só no templo.",
            },
            opts(
                ("a", "Ele é Deus, a quem se mente como se mente a uma pessoa."),
                ("b", "Ele é energia divina sem vontade nem juízo."),
                ("c", "Ele é inferior ao Pai, e a mentira não o atinge."),
                ("d", "Ele só age no templo, nunca no coração da igreja."),
            ),
            "a",
        ),
        order(
            "profundezas",
            "interpret",
            "04",
            "Qual sequência revela o sentido de Atos 5:3–4?",
            "Certo: desígnio, mentira ao Espírito e identificação com Deus.",
            {
                "b": "A mentira ao Espírito vem depois do desígnio.",
                "c": "A frase a Deus é o sentido final, não o primeiro passo.",
            },
            opts(
                ("a", "Como formaste esse desígnio no teu coração"),
                ("b", "mentisses ao Espírito Santo"),
                ("c", "Não mentiste aos homens, mas a Deus"),
            ),
        ),
        complete(
            "profundezas",
            "interpret",
            "05",
            "por que encheu ___ o teu coração",
            "Certo: Satanás encheu o coração de Ananias.",
            {
                "b": "A mentira foi a Deus; quem encheu o coração foi Satanás.",
                "c": "Pedro pergunta; não é ele quem encheu o coração.",
            },
            opts(("a", "Satanás"), ("b", "Deus"), ("c", "Pedro")),
            "a",
            "por que encheu ___ o teu coração",
        ),
        connect(
            "profundezas",
            "interpret",
            "06",
            R1,
            "Certo: a mentira ao Espírito é mentira a Deus.",
            {
                "b": "Pedro não reduz o caso a falha só da instituição.",
                "c": "O Espírito aqui tem pessoa, não é força sem rosto.",
            },
            opts(
                ("a", "Mentira ao Espírito é a Deus"),
                ("b", "Mentira só institucional"),
                ("c", "Espírito sem pessoa"),
            ),
            "a",
            P1,
            INS1,
        ),
    ],
)

m2 = pack(
    "pn-02-vida",
    R2,
    LO2,
    EV2,
    P2,
    [
        tf(
            "semente",
            "observe",
            "01",
            "Se alguém não tem o Espírito de Cristo, esse não é dele.",
            "Certo: Romanos 8:9 afirma isso palavra por palavra.",
            {"false": "Releia: sem o Espírito de Cristo, a pessoa não é dele."},
            "true",
        ),
        tap(
            "semente",
            "observe",
            "02",
            R2,
            "se realmente o Espírito de Deus ___ em vós",
            "Exato: o Espírito de Deus habita em vós.",
            {
                "b": "Morto descreve o corpo, não esta lacuna.",
                "c": "Justiça explica a vida do espírito, depois.",
            },
            opts(("a", "habita"), ("b", "morto"), ("c", "justiça")),
            "a",
            "se realmente o Espírito de Deus ___ em vós",
        ),
        choice(
            "semente",
            "observe",
            "03",
            "O que Romanos 8:9–11 afirma sobre quem não tem o Espírito de Cristo?",
            "Certo: esse não é dele.",
            {
                "b": "O texto não sustenta pertencer a Cristo só pela carne.",
                "c": "Sem o Espírito, a pessoa não está nele.",
                "d": "O corpo está morto por causa do pecado, não vivo.",
            },
            opts(
                ("a", "Esse não é dele."),
                ("b", "Esse ainda pertence a Cristo pela carne."),
                ("c", "Esse está sujeito ao Espírito mesmo sem tê-lo."),
                ("d", "Esse tem o corpo vivo por causa do pecado."),
            ),
            "a",
        ),
        order(
            "semente",
            "observe",
            "04",
            "Qual sequência mostra a ordem dos fatos em Romanos 8:9–11?",
            "Certo: essa é a ordem do trecho.",
            {
                "b": "A habitação vem ligada à sujeição ao Espírito.",
                "c": "Não ser dele fecha esta cadeia, não a abre.",
            },
            opts(
                ("a", "não estais sujeitos à carne, mas ao Espírito"),
                ("b", "se realmente o Espírito de Deus habita em vós"),
                ("c", "se alguém não tem o Espírito de Cristo, esse não é dele"),
            ),
        ),
        complete(
            "semente",
            "observe",
            "05",
            "o espírito é vida por causa da ___",
            "Certo: vida por causa da justiça.",
            {
                "b": "Carne é o regime do qual não estão sujeitos.",
                "c": "Pecado explica a morte do corpo, não esta lacuna.",
            },
            opts(("a", "justiça"), ("b", "carne"), ("c", "pecado")),
            "a",
            "o espírito é vida por causa da ___",
        ),
        connect(
            "semente",
            "observe",
            "06",
            R2,
            "Certo: ter o Espírito é pertencer a Cristo.",
            {
                "b": "A carne não basta para ser dele.",
                "c": "O texto torna o Espírito decisivo, não opcional.",
            },
            opts(
                ("a", "Habitar é pertencer a Cristo"),
                ("b", "Carne basta para pertencer"),
                ("c", "Espírito opcional no salvo"),
            ),
            "a",
            P2,
            INS2,
        ),
        tf(
            "caminhada",
            "understand",
            "01",
            "O texto ensina que alguém pode ser de Cristo sem ter o Espírito de Cristo.",
            "Certo: quem não tem o Espírito de Cristo não é dele.",
            {"true": "O texto recusa essa separação: sem o Espírito, não é dele."},
            "false",
        ),
        tap(
            "caminhada",
            "understand",
            "02",
            R2,
            "não estais sujeitos à ___, mas ao Espírito",
            "Exato: não sujeitos à carne, mas ao Espírito.",
            {
                "b": "Justiça explica a vida, não esta lacuna.",
                "c": "Pecado explica a morte do corpo, depois.",
            },
            opts(("a", "carne"), ("b", "justiça"), ("c", "pecado")),
            "a",
            "não estais sujeitos à ___, mas ao Espírito",
        ),
        choice(
            "caminhada",
            "understand",
            "03",
            "Qual relação o texto estabelece entre o Espírito e pertencer a Cristo?",
            "Certo: sem o Espírito de Cristo, a pessoa não é dele.",
            {
                "b": "A carne não substitui o Espírito.",
                "c": "O Espírito habita em vós, não só à parte do crente.",
                "d": "Pertencer a Cristo e ter o Espírito caminham juntos.",
            },
            opts(
                ("a", "Sem o Espírito de Cristo, a pessoa não é dele."),
                ("b", "A carne substitui o Espírito para quem já crê."),
                ("c", "O Espírito habita só no corpo, nunca no crente."),
                ("d", "Pertencer a Cristo independe de ter o Espírito."),
            ),
            "a",
        ),
        order(
            "caminhada",
            "understand",
            "04",
            "Como se encadeiam os eventos de Romanos 8:9–11?",
            "Certo: habitação, pertencimento e vida por justiça.",
            {
                "b": "Não ser dele vem depois da cláusula da habitação.",
                "c": "A vida por justiça fecha o trecho citado.",
            },
            opts(
                ("a", "o Espírito de Deus habita em vós"),
                ("b", "se alguém não tem o Espírito de Cristo, esse não é dele"),
                ("c", "o espírito é vida por causa da justiça"),
            ),
        ),
        complete(
            "caminhada",
            "understand",
            "05",
            "o corpo, na verdade, está ___ por causa do pecado",
            "Certo: o corpo está morto por causa do pecado.",
            {
                "b": "Sujeitos descreve carne e Espírito, não o corpo aqui.",
                "c": "Dele fala de pertencer a Cristo, não do estado do corpo.",
            },
            opts(("a", "morto"), ("b", "sujeitos"), ("c", "dele")),
            "a",
            "o corpo, na verdade, está ___ por causa do pecado",
        ),
        connect(
            "caminhada",
            "understand",
            "06",
            R2,
            "Certo: o Espírito marca quem é de Cristo.",
            {
                "b": "A carne não define o pertencimento neste texto.",
                "c": "A habitação é real, não um mero símbolo vazio.",
            },
            opts(
                ("a", "Espírito marca quem é de Cristo"),
                ("b", "Carne define o pertencimento"),
                ("c", "Habitação é só símbolo"),
            ),
            "a",
            P2,
            INS2,
        ),
        tf(
            "profundezas",
            "interpret",
            "01",
            "A nova vida no texto depende do Espírito que habita, não da carne.",
            "Certo: sujeitos ao Espírito; o espírito é vida por justiça.",
            {"false": "O trecho opõe carne e Espírito e liga a vida à justiça."},
            "true",
        ),
        tap(
            "profundezas",
            "interpret",
            "02",
            R2,
            "o espírito é ___ por causa da justiça",
            "Exato: o espírito é vida por causa da justiça.",
            {
                "a": "Carne é o regime recusado, não esta lacuna.",
                "b": "Corpo está morto; a lacuna pede vida.",
            },
            opts(("a", "carne"), ("b", "corpo"), ("c", "vida")),
            "c",
            "o espírito é ___ por causa da justiça",
        ),
        choice(
            "profundezas",
            "interpret",
            "03",
            "O que o texto implica sobre a identidade do crente?",
            "Certo: ser de Cristo inclui o Espírito que habita e dá vida.",
            {
                "b": "O Espírito não é um extra depois da carne.",
                "c": "A morte do corpo é por causa do pecado, não falha do Espírito.",
                "d": "Cristo em vós está ligado ao Espírito de Deus e de Cristo.",
            },
            opts(
                ("a", "Pertencer a Cristo inclui ter o Espírito que habita e dá vida."),
                ("b", "O Espírito é um extra depois da salvação pela carne."),
                ("c", "O corpo morto prova que o Espírito falhou."),
                ("d", "Cristo está em vós sem o Espírito de Deus."),
            ),
            "a",
        ),
        order(
            "profundezas",
            "interpret",
            "04",
            "Qual sequência revela o sentido de Romanos 8:9–11?",
            "Certo: sujeição ao Espírito, pertencimento e vida.",
            {
                "b": "Não ser dele vem no meio da argumentação.",
                "c": "A vida por justiça é o desfecho, não o início.",
            },
            opts(
                ("a", "não estais sujeitos à carne, mas ao Espírito"),
                ("b", "se alguém não tem o Espírito de Cristo, esse não é dele"),
                ("c", "o espírito é vida por causa da justiça"),
            ),
        ),
        complete(
            "profundezas",
            "interpret",
            "05",
            "se realmente o Espírito de ___ habita em vós",
            "Certo: o Espírito de Deus habita em vós.",
            {
                "b": "Pecado explica a morte do corpo, não quem habita.",
                "c": "Corpo é o que está morto, não o dono do Espírito.",
            },
            opts(("a", "Deus"), ("b", "pecado"), ("c", "corpo")),
            "a",
            "se realmente o Espírito de ___ habita em vós",
        ),
        connect(
            "profundezas",
            "interpret",
            "06",
            R2,
            "Certo: a nova vida vem pelo Espírito que habita.",
            {
                "b": "A carne não é a fonte desta vida.",
                "c": "O texto não separa Cristo do Espírito.",
            },
            opts(
                ("a", "Nova vida pelo Espírito"),
                ("b", "Vida só pela carne"),
                ("c", "Cristo sem o Espírito"),
            ),
            "a",
            P2,
            INS2,
        ),
    ],
)

m3 = pack(
    "pn-03-fruto",
    R3,
    LO3,
    EV3,
    P3,
    [
        tf(
            "semente",
            "observe",
            "01",
            "O fruto do Espírito é a caridade, o gozo, a paz, a longanimidade, a benignidade, a bondade, a fidelidade, a mansidão, a temperança.",
            "Certo: Gálatas 5:22–23 lista exatamente esse fruto.",
            {"false": "Releia a lista: o texto nomeia esse fruto do Espírito."},
            "true",
        ),
        tap(
            "semente",
            "observe",
            "02",
            R3,
            "Mas o ___ do Espírito é a caridade",
            "Exato: o texto fala do fruto do Espírito.",
            {
                "b": "Lei aparece no fim: contra tais coisas não há lei.",
                "c": "Paz é item da lista, não esta lacuna.",
            },
            opts(("a", "fruto"), ("b", "lei"), ("c", "paz")),
            "a",
            "Mas o ___ do Espírito é a caridade",
        ),
        choice(
            "semente",
            "observe",
            "03",
            "O que Gálatas 5:22–23 lista como fruto do Espírito?",
            "Certo: caridade, gozo, paz e as demais virtudes citadas.",
            {
                "b": "A lei não é o primeiro fruto; contra o fruto não há lei.",
                "c": "Ira e discórdia não estão nesta lista.",
                "d": "O texto descreve caráter, não só dons milagrosos.",
            },
            opts(
                ("a", "Caridade, gozo, paz, longanimidade e as demais virtudes citadas."),
                ("b", "A lei mosaica como primeiro fruto do Espírito."),
                ("c", "Ira, discórdia e ciúmes como fruto do Espírito."),
                ("d", "Somente dons milagrosos, sem traço de caráter."),
            ),
            "a",
        ),
        order(
            "semente",
            "observe",
            "04",
            "Qual sequência mostra a ordem dos fatos em Gálatas 5:22–23?",
            "Certo: essa é a ordem da lista e do fecho.",
            {
                "b": "Longanimidade vem depois de caridade, gozo e paz.",
                "c": "A frase sobre a lei fecha o trecho.",
            },
            opts(
                ("a", "o fruto do Espírito é a caridade, o gozo, a paz"),
                ("b", "a longanimidade, a benignidade, a bondade"),
                ("c", "Contra tais coisas não há lei"),
            ),
        ),
        complete(
            "semente",
            "observe",
            "05",
            "Contra tais coisas não há ___",
            "Certo: contra tais coisas não há lei.",
            {
                "b": "Caridade abre a lista, não fecha esta frase.",
                "c": "Paz é um item do fruto, não esta lacuna.",
            },
            opts(("a", "lei"), ("b", "caridade"), ("c", "paz")),
            "a",
            "Contra tais coisas não há ___",
        ),
        connect(
            "semente",
            "observe",
            "06",
            R3,
            "Certo: o Espírito produz caráter.",
            {
                "b": "O fruto não se reduz a emoção passageira.",
                "c": "O texto diz que contra o fruto não há lei.",
            },
            opts(
                ("a", "Espírito produz caráter"),
                ("b", "Fruto é só emoção"),
                ("c", "Lei anula o fruto"),
            ),
            "a",
            P3,
            INS3,
        ),
        tf(
            "caminhada",
            "understand",
            "01",
            "O texto ensina que contra o fruto do Espírito há uma lei que o restringe.",
            "Certo: contra tais coisas não há lei.",
            {"true": "O texto afirma o contrário: não há lei contra esse fruto."},
            "false",
        ),
        tap(
            "caminhada",
            "understand",
            "02",
            R3,
            "Contra tais coisas não há ___",
            "Exato: não há lei contra tais coisas.",
            {
                "b": "Gozo é item do fruto, não esta lacuna.",
                "c": "Bondade também está na lista, não aqui.",
            },
            opts(("a", "lei"), ("b", "gozo"), ("c", "bondade")),
            "a",
            "Contra tais coisas não há ___",
        ),
        choice(
            "caminhada",
            "understand",
            "03",
            "O que o texto distingue ao chamar isso de fruto do Espírito?",
            "Certo: é caráter que o Espírito produz, sem lei contra ele.",
            {
                "b": "A lista é de virtudes, não de dons para exibir.",
                "c": "Obras da carne não são rebatizadas aqui.",
                "d": "O fruto não nasce da lei por esforço próprio.",
            },
            opts(
                ("a", "Caráter produzido pelo Espírito, sem lei que o condene."),
                ("b", "Uma lista de dons para exibir na assembleia."),
                ("c", "Obras da carne com nomes piedosos."),
                ("d", "Regras da lei que geram o fruto por esforço."),
            ),
            "a",
        ),
        order(
            "caminhada",
            "understand",
            "04",
            "Como se encadeiam os eventos de Gálatas 5:22–23?",
            "Certo: a lista avança nessa ordem.",
            {
                "b": "Gozo e paz vêm logo após a caridade.",
                "c": "Fidelidade, mansidão e temperança fecham a lista.",
            },
            opts(
                ("a", "Mas o fruto do Espírito é a caridade"),
                ("b", "o gozo, a paz, a longanimidade, a benignidade, a bondade"),
                ("c", "a fidelidade, a mansidão, a temperança"),
            ),
        ),
        complete(
            "caminhada",
            "understand",
            "05",
            "o fruto do Espírito é a ___",
            "Certo: o primeiro nome da lista é caridade.",
            {
                "b": "Lei aparece no fecho, não como o fruto.",
                "c": "Coisas aponta para o conjunto, não para o primeiro item.",
            },
            opts(("a", "caridade"), ("b", "lei"), ("c", "coisas")),
            "a",
            "o fruto do Espírito é a ___",
        ),
        connect(
            "caminhada",
            "understand",
            "06",
            R3,
            "Certo: há fruto, e contra ele não há lei.",
            {
                "b": "O texto recusa lei contra esse fruto.",
                "c": "Fruto aqui é caráter, não só um dom à parte.",
            },
            opts(
                ("a", "Fruto, não lei contra ele"),
                ("b", "Lei contra o fruto"),
                ("c", "Fruto é só um dom"),
            ),
            "a",
            P3,
            INS3,
        ),
        tf(
            "profundezas",
            "interpret",
            "01",
            "O Espírito, neste texto, produz caráter visível, e contra esse fruto não há lei.",
            "Certo: a lista é de caráter, e não há lei contra ele.",
            {"false": "O trecho une fruto de caráter e a ausência de lei contra ele."},
            "true",
        ),
        tap(
            "profundezas",
            "interpret",
            "02",
            R3,
            "a ___, a temperança",
            "Exato: a mansidão, a temperança.",
            {
                "b": "Lei fecha o versículo, não esta lacuna.",
                "c": "Fruto nomeia o conjunto, não o penúltimo item.",
            },
            opts(("a", "mansidão"), ("b", "lei"), ("c", "fruto")),
            "a",
            "a ___, a temperança",
        ),
        choice(
            "profundezas",
            "interpret",
            "03",
            "Qual leitura o texto sustenta sobre o fruto do Espírito?",
            "Certo: o Espírito forma caráter, e contra ele não há lei.",
            {
                "b": "O texto não diz que o fruto substitui Cristo.",
                "c": "Caráter é a prova aqui, não só o espetáculo de dons.",
                "d": "A lei não produz o fruto neste trecho.",
            },
            opts(
                ("a", "O Espírito forma caráter; contra esse fruto não há lei."),
                ("b", "O fruto substitui Cristo e torna a lei inútil para todos."),
                ("c", "Só dons espetaculares provam o Espírito, não o caráter."),
                ("d", "A lei produz o fruto e o Espírito apenas observa."),
            ),
            "a",
        ),
        order(
            "profundezas",
            "interpret",
            "04",
            "Qual sequência revela o sentido de Gálatas 5:22–23?",
            "Certo: fruto, lista de caráter e ausência de lei.",
            {
                "b": "A tríade final vem depois da caridade.",
                "c": "A frase sobre a lei é o sentido final.",
            },
            opts(
                ("a", "o fruto do Espírito é a caridade"),
                ("b", "a fidelidade, a mansidão, a temperança"),
                ("c", "Contra tais coisas não há lei"),
            ),
        ),
        complete(
            "profundezas",
            "interpret",
            "05",
            "Mas o fruto do ___ é a caridade",
            "Certo: o fruto do Espírito.",
            {
                "b": "Lei não produz o fruto neste versículo.",
                "c": "Paz é item da lista, não o sujeito da frase.",
            },
            opts(("a", "Espírito"), ("b", "lei"), ("c", "paz")),
            "a",
            "Mas o fruto do ___ é a caridade",
        ),
        connect(
            "profundezas",
            "interpret",
            "06",
            R3,
            "Certo: caráter contra o qual não há lei.",
            {
                "b": "A lei não é a fonte deste caráter.",
                "c": "O texto não trata o fruto como opcional.",
            },
            opts(
                ("a", "Caráter contra o qual não há lei"),
                ("b", "Lei gera o caráter"),
                ("c", "Fruto opcional no crente"),
            ),
            "a",
            P3,
            INS3,
        ),
    ],
)

mb = pack(
    "pn-boss",
    RB,
    LOB,
    EVB,
    P4,
    [
        tf(
            "semente",
            "observe",
            "01",
            "Não mentiste aos homens, mas a Deus; o Espírito de Deus habita em vós; o fruto do Espírito é a caridade.",
            "Certo: os três trechos afirmam Deus, habitação e fruto.",
            {"false": "Os três textos combinados dizem exatamente isso."},
            "true",
        ),
        tap(
            "semente",
            "observe",
            "02",
            RB,
            "Não mentiste aos homens, mas a ___",
            "Exato: a mentira foi a Deus.",
            {
                "b": "Carne está em Romanos 8:9, não nesta lacuna.",
                "c": "Caridade abre o fruto, não esta frase.",
            },
            opts(("a", "Deus"), ("b", "carne"), ("c", "caridade")),
            "a",
            "Não mentiste aos homens, mas a ___",
        ),
        choice(
            "semente",
            "observe",
            "03",
            "O que os três textos afirmam juntos sobre o Espírito?",
            "Certo: ele é Deus, habita no crente e produz fruto.",
            {
                "b": "Os trechos recusam reduzí-lo a energia sem habitação.",
                "c": "Atos liga a mentira ao Espírito com mentira a Deus.",
                "d": "O fruto é caridade e virtudes, não a lei.",
            },
            opts(
                ("a", "O Espírito é Deus, habita no crente e produz fruto."),
                ("b", "O Espírito é só energia, sem habitação nem fruto."),
                ("c", "Mentir ao Espírito não tem relação com Deus."),
                ("d", "O fruto do Espírito é a lei mosaica."),
            ),
            "a",
        ),
        order(
            "semente",
            "observe",
            "04",
            "Qual sequência mostra a ordem dos fatos em Atos 5:4; Romanos 8:9; Gálatas 5:22?",
            "Certo: Deus, habitação e fruto nessa ordem.",
            {
                "b": "A habitação vem no segundo trecho.",
                "c": "O fruto fecha a combinação.",
            },
            opts(
                ("a", "Não mentiste aos homens, mas a Deus"),
                ("b", "se realmente o Espírito de Deus habita em vós"),
                ("c", "Mas o fruto do Espírito é a caridade"),
            ),
        ),
        complete(
            "semente",
            "observe",
            "05",
            "se realmente o Espírito de Deus ___ em vós",
            "Certo: o Espírito de Deus habita em vós.",
            {
                "b": "Homens está em Atos 5:4, não nesta lacuna.",
                "c": "Gozo é item do fruto, não o verbo da habitação.",
            },
            opts(("a", "habita"), ("b", "homens"), ("c", "gozo")),
            "a",
            "se realmente o Espírito de Deus ___ em vós",
        ),
        connect(
            "semente",
            "observe",
            "06",
            RB,
            "Certo: Deus, habitação e fruto se unem.",
            {
                "b": "Os textos não o deixam como poder impessoal.",
                "c": "O fruto vem do Espírito que habita, não sem ele.",
            },
            opts(
                ("a", "Deus, habitação e fruto"),
                ("b", "Só poder impessoal"),
                ("c", "Fruto sem o Espírito"),
            ),
            "a",
            P4,
            INSB,
        ),
        tf(
            "caminhada",
            "understand",
            "01",
            "Os três textos ensinam que o Espírito é um poder impessoal que não habita nem produz caráter.",
            "Certo: os trechos o ligam a Deus, à habitação e ao fruto.",
            {"true": "Isso contradiz a combinação: Deus, habita e produz fruto."},
            "false",
        ),
        tap(
            "caminhada",
            "understand",
            "02",
            RB,
            "Mas o fruto do Espírito é a ___",
            "Exato: o fruto do Espírito é a caridade.",
            {
                "b": "Homens está em Atos 5:4, não nesta lacuna.",
                "c": "Carne está em Romanos 8:9, não aqui.",
            },
            opts(("a", "caridade"), ("b", "homens"), ("c", "carne")),
            "a",
            "Mas o fruto do Espírito é a ___",
        ),
        choice(
            "caminhada",
            "understand",
            "03",
            "Como os três trechos se encadeiam na vida no Espírito?",
            "Certo: ele é Deus, habita em quem é de Cristo e gera fruto.",
            {
                "b": "A ordem do texto não começa pelo fruto sem ser Deus.",
                "c": "Mentir a Deus está ligado ao Espírito, não separado.",
                "d": "O fruto não nasce da carne sem o Espírito.",
            },
            opts(
                ("a", "Ele é Deus, habita no que é de Cristo e gera fruto."),
                ("b", "Primeiro vem o fruto, depois a habitação, sem ser Deus."),
                ("c", "Mentir a Deus não envolve o Espírito que habita."),
                ("d", "O crente produz fruto pela carne, sem o Espírito."),
            ),
            "a",
        ),
        order(
            "caminhada",
            "understand",
            "04",
            "Como se encadeiam os eventos de Atos 5:4; Romanos 8:9; Gálatas 5:22?",
            "Certo: mentira a Deus, pertencimento e fruto.",
            {
                "b": "Não ser dele vem no segundo trecho.",
                "c": "O fruto fecha a cadeia combinada.",
            },
            opts(
                ("a", "Não mentiste aos homens, mas a Deus"),
                ("b", "se alguém não tem o Espírito de Cristo, esse não é dele"),
                ("c", "o fruto do Espírito é a caridade, o gozo, a paz"),
            ),
        ),
        complete(
            "caminhada",
            "understand",
            "05",
            "não estais sujeitos à ___, mas ao Espírito",
            "Certo: não sujeitos à carne, mas ao Espírito.",
            {
                "b": "Caridade é o fruto, não o regime recusado.",
                "c": "Deus é o alvo da mentira em Atos, não esta lacuna.",
            },
            opts(("a", "carne"), ("b", "caridade"), ("c", "Deus")),
            "a",
            "não estais sujeitos à ___, mas ao Espírito",
        ),
        connect(
            "caminhada",
            "understand",
            "06",
            RB,
            "Certo: a vida no Espírito une os três temas.",
            {
                "b": "Os trechos não ficam soltos: Deus, habita e frutifica.",
                "c": "A carne não ocupa o lugar do Espírito.",
            },
            opts(
                ("a", "Vida no Espírito unida"),
                ("b", "Três temas desligados"),
                ("c", "Carne no lugar do Espírito"),
            ),
            "a",
            P4,
            INSB,
        ),
        tf(
            "profundezas",
            "interpret",
            "01",
            "A vida no Espírito, segundo os três textos, une divindade, habitação e fruto de caráter.",
            "Certo: Deus, habita no crente e produz fruto.",
            {"false": "Essa é a síntese que os três trechos sustentam juntos."},
            "true",
        ),
        tap(
            "profundezas",
            "interpret",
            "02",
            RB,
            "se realmente o Espírito de Deus ___ em vós",
            "Exato: o Espírito de Deus habita em vós.",
            {
                "b": "Temperança fecha a lista do fruto, não esta lacuna.",
                "c": "Homens está em Atos 5:4, não aqui.",
            },
            opts(("a", "habita"), ("b", "temperança"), ("c", "homens")),
            "a",
            "se realmente o Espírito de Deus ___ em vós",
        ),
        choice(
            "profundezas",
            "interpret",
            "03",
            "Qual síntese teológica os três textos sustentam?",
            "Certo: o Espírito é Deus pessoal, habita e produz fruto.",
            {
                "b": "Os trechos recusam um Espírito impessoal e inerte.",
                "c": "Fruto e habitação não dispensam que ele seja Deus.",
                "d": "A mentira a Deus não se reduz a ética social sem o Espírito.",
            },
            opts(
                ("a", "O Espírito é Deus pessoal, habita no crente e produz fruto."),
                ("b", "O Espírito é impessoal, visita de fora e não muda o caráter."),
                ("c", "Fruto e habitação dispensam que o Espírito seja Deus."),
                ("d", "Mentir a Deus é só ética social, sem o Espírito Santo."),
            ),
            "a",
        ),
        order(
            "profundezas",
            "interpret",
            "04",
            "Qual sequência revela o sentido de Atos 5:4; Romanos 8:9; Gálatas 5:22?",
            "Certo: Deus, habitação e fruto de caráter.",
            {
                "b": "A habitação vem no segundo trecho.",
                "c": "O fruto é o desfecho da vida no Espírito.",
            },
            opts(
                ("a", "Não mentiste aos homens, mas a Deus"),
                ("b", "o Espírito de Deus habita em vós"),
                ("c", "Mas o fruto do Espírito é a caridade, o gozo, a paz"),
            ),
        ),
        complete(
            "profundezas",
            "interpret",
            "05",
            "esse não é ___",
            "Certo: quem não tem o Espírito de Cristo não é dele.",
            {
                "b": "Deus é o alvo da mentira, não esta lacuna.",
                "c": "Paz é item do fruto, não o pertencimento.",
            },
            opts(("a", "dele"), ("b", "Deus"), ("c", "paz")),
            "a",
            "esse não é ___",
        ),
        connect(
            "profundezas",
            "interpret",
            "06",
            RB,
            "Certo: ele é Deus, habita e frutifica.",
            {
                "b": "Os textos não o deixam como poder sem pessoa.",
                "c": "Habitação e caráter caminham juntos.",
            },
            opts(
                ("a", "Deus, habita e produz fruto"),
                ("b", "Poder sem pessoa nem fruto"),
                ("c", "Habitação sem caráter"),
            ),
            "a",
            P4,
            INSB,
        ),
    ],
)

bank = m1 + m2 + m3 + mb
assert len(bank) == 72, len(bank)

for q in bank:
    assert len(q["feedbackCorrect"]) <= 100, (q["id"], len(q["feedbackCorrect"]), q["feedbackCorrect"])
    if q["type"] == "choice":
        for o in q["options"]:
            assert len(o["text"]) <= 90, (q["id"], len(o["text"]), o["text"])
        if q["difficulty"] != "semente":
            passage = q["passageText"].lower()
            for o in q["options"]:
                if o["id"] == q["correctOptionId"]:
                    continue
                # distratores não devem ser cópia literal de um trecho longo
                t = o["text"].rstrip(".")
                if len(t) > 20 and t.lower() in passage:
                    raise AssertionError(f"distrator copiado do versículo: {q['id']} {o['text']}")
    assert q["question"] == q["prompt"] == q["cue"]
    if q["type"] == "true_false":
        assert not q["question"].strip().endswith("?")

OUT.write_text(json.dumps(bank, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {OUT} ({len(bank)} questions)")
