#!/usr/bin/env python3
"""Gera perguntas-v2/cronicas.json (5 missões × 18)."""
import json
from pathlib import Path

OUT = Path(__file__).with_name("cronicas.json")


def q(
    trail,
    section,
    diff,
    skill,
    typ,
    nn,
    verse_ref,
    lo,
    evidence,
    question,
    feedback_correct,
    feedback_wrong,
    options,
    correct,
    passage,
    **extra,
):
    short = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}[diff]
    item = {
        "difficulty": diff,
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
        "options": options,
        "correctOptionId": correct,
        "correctAnswer": correct,
        "passageText": passage,
        "trail": trail,
        "section": section,
        "id": f"{trail}-{short}-{section}-{nn}",
    }
    item.update(extra)
    assert len(feedback_correct) <= 100, (len(feedback_correct), feedback_correct)
    return item


def tf_opts():
    return [{"id": "true", "text": "Verdadeiro"}, {"id": "false", "text": "Falso"}]


def opts(*pairs):
    return [{"id": i, "text": t} for i, t in pairs]


def mission(section, verse, passage, lo, evidence, items):
    out = []
    for spec in items:
        extra = {}
        for k in ("template", "correctOrder", "passageA", "passageB"):
            if k in spec:
                extra[k] = spec[k]
        out.append(
            q(
                "cronicas",
                section,
                spec["diff"],
                spec["skill"],
                spec["type"],
                spec["nn"],
                verse,
                lo,
                evidence,
                spec["question"],
                spec["ok"],
                spec["wrong"],
                spec["options"],
                spec["correct"],
                passage,
                **extra,
            )
        )
    return out


bank = []

# ---------------------------------------------------------------------------
# M1 1 Crônicas 16:29
# ---------------------------------------------------------------------------
P1 = (
    "Tributai a Jeová a glória devida ao seu nome. Trazei uma oferta e vinde "
    "à sua presença; adorai a Jeová na beleza da santidade."
)
LO1 = (
    "Reconhecer que a arca convoca adoração: glória ao nome, oferta, "
    "presença e Jeová na beleza da santidade."
)
bank += mission(
    "cronicas-culto-01-a-arca-e-a-adoracao",
    "1 Crônicas 16:29",
    P1,
    LO1,
    ["1 Crônicas 16:29"],
    [
        dict(
            diff="semente",
            skill="observe",
            type="true_false",
            nn="01",
            question="O texto manda tributar a Jeová a glória devida ao seu nome.",
            ok="Certo: 1 Crônicas 16:29 abre com essa ordem de glória ao nome.",
            wrong={"false": "Releia: Tributai a Jeová a glória devida ao seu nome."},
            options=tf_opts(),
            correct="true",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="tap",
            nn="02",
            question='Em 1 Crônicas 16:29, toque a palavra que falta em "Tributai a Jeová a ___ devida ao seu nome"?',
            ok='Exato: tributa-se a "glória" devida ao nome de Jeová.',
            wrong={
                "b": "Oferta vem no convite seguinte, não nesta lacuna.",
                "c": "Presença é o destino da vinda, não o que se tributa aqui.",
            },
            options=opts(("a", "glória"), ("b", "oferta"), ("c", "presença")),
            correct="a",
            template="Tributai a Jeová a ___ devida ao seu nome.",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="choice",
            nn="03",
            question="O que 1 Crônicas 16:29 manda trazer e fazer diante de Jeová?",
            ok="Certo: trazer oferta, vir à presença e adorar na beleza da santidade.",
            wrong={
                "a": "O texto não fala de silêncio sem oferta.",
                "c": "Não manda ficar longe da presença de Jeová.",
                "d": "Não há ordem de esconder a glória do nome.",
            },
            options=opts(
                ("a", "Ficar em silêncio, sem oferta nem vinda."),
                ("b", "Trazer oferta, vir à presença e adorar na santidade."),
                ("c", "Afastar-se da presença e guardar a oferta."),
                ("d", "Esconder a glória devida ao nome de Jeová."),
            ),
            correct="b",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="order",
            nn="04",
            question="Qual sequência mostra a ordem dos fatos em 1 Crônicas 16:29?",
            ok="Certo: glória ao nome, depois oferta e presença, então a adoração.",
            wrong={
                "b": "A oferta não abre o versículo.",
                "c": "A adoração fecha o texto, não o inicia.",
            },
            options=opts(
                ("a", "Tributai a Jeová a glória devida ao seu nome"),
                ("b", "Trazei uma oferta e vinde à sua presença"),
                ("c", "adorai a Jeová na beleza da santidade"),
            ),
            correct="a",
            correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente",
            skill="observe",
            type="complete",
            nn="05",
            question='Complete a frase: "Trazei uma ___ e vinde à sua presença."',
            ok='Certo: o texto manda trazer uma "oferta" e vir à presença.',
            wrong={
                "a": "Glória é o que se tributa ao nome, não o que se traz aqui.",
                "c": "Santidade qualifica a beleza da adoração, não esta lacuna.",
            },
            options=opts(("a", "glória"), ("b", "oferta"), ("c", "santidade")),
            correct="b",
            template="Trazei uma ___ e vinde à sua presença.",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="connect",
            nn="06",
            question="O que 1 Crônicas 16:29 comunica que se liga a este contexto?",
            ok="Certo: a arca chama a glória, oferta e presença.",
            wrong={
                "a": "O texto não reduz o culto a um canto solto.",
                "b": "Não descreve um templo vazio sem convite.",
            },
            options=opts(
                ("a", "Canto solto sem convite"),
                ("b", "Templo vazio sem oferta"),
                ("c", "Glória, oferta e presença"),
            ),
            correct="c",
            passageA={
                "ref": "1 Crônicas 16:29",
                "text": "Tributai a Jeová a glória devida ao seu nome.",
            },
            passageB={
                "ref": "Contexto",
                "text": "A arca chama a adoração: glória ao nome, oferta e presença — Jeová na beleza da santidade.",
            },
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="true_false",
            nn="01",
            question="O versículo reduz a adoração a um sentimento interno, sem oferta nem vinda à presença.",
            ok="Certo: o texto une glória, oferta, presença e adoração visível.",
            wrong={"true": "1 Crônicas 16:29 manda trazer oferta e vir à presença."},
            options=tf_opts(),
            correct="false",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="tap",
            nn="02",
            question='Em 1 Crônicas 16:29, toque a palavra que falta em "Trazei uma oferta e vinde à sua ___"?',
            ok='Exato: o convite é vir à "presença" de Jeová.',
            wrong={
                "a": "Glória é o que se tributa ao nome, não o destino desta vinda.",
                "b": "Oferta é o que se traz, não o lugar a que se vem.",
            },
            options=opts(("a", "glória"), ("b", "oferta"), ("c", "presença")),
            correct="c",
            template="Trazei uma oferta e vinde à sua ___.",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="choice",
            nn="03",
            question="Como se relacionam glória, oferta e presença em 1 Crônicas 16:29?",
            ok="Certo: a glória ao nome se desdobra em oferta e vinda à presença.",
            wrong={
                "a": "O texto não opõe oferta à glória do nome.",
                "c": "Não apresenta a presença como prêmio por fama humana.",
                "d": "A beleza da santidade não substitui a oferta; acompanha a adoração.",
            },
            options=opts(
                ("a", "A oferta substitui a glória devida ao nome."),
                ("b", "A glória ao nome pede oferta e vinda à presença."),
                ("c", "A presença é prêmio pela fama do adorador."),
                ("d", "A beleza da santidade dispensa trazer oferta."),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="order",
            nn="04",
            question="Como se encadeiam os eventos de 1 Crônicas 16:29?",
            ok="Certo: primeiro a glória ao nome, depois oferta e presença, então adorar.",
            wrong={
                "a": "Adorar não abre o encadeamento do versículo.",
                "c": "A oferta não vem antes da glória devida ao nome.",
            },
            options=opts(
                ("a", "adorai a Jeová na beleza da santidade"),
                ("b", "Tributai a Jeová a glória devida ao seu nome"),
                ("c", "Trazei uma oferta e vinde à sua presença"),
            ),
            correct="b",
            correctOrder=["b", "c", "a"],
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="complete",
            nn="05",
            question='Complete a frase: "adorai a Jeová na ___ da santidade."',
            ok='Certo: adora-se Jeová na "beleza" da santidade.',
            wrong={
                "a": "Oferta é o que se traz, não o que qualifica a santidade aqui.",
                "c": "Presença é o destino da vinda, não esta lacuna.",
            },
            options=opts(("a", "oferta"), ("b", "beleza"), ("c", "presença")),
            correct="b",
            template="adorai a Jeová na ___ da santidade.",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="connect",
            nn="06",
            question="O que 1 Crônicas 16:29 comunica que se liga a este contexto?",
            ok="Certo: o culto une nome glorificado e corpo que se aproxima.",
            wrong={
                "b": "O texto não ensina culto só interior, sem oferta.",
                "c": "Não trata a arca como relíquia sem convite.",
            },
            options=opts(
                ("a", "Nome glorificado e aproximação"),
                ("b", "Culto só interior sem oferta"),
                ("c", "Arca como relíquia sem convite"),
            ),
            correct="a",
            passageA={
                "ref": "1 Crônicas 16:29",
                "text": "Trazei uma oferta e vinde à sua presença",
            },
            passageB={
                "ref": "Contexto",
                "text": "A arca não é peça de museu: chama o povo a glória, oferta e presença.",
            },
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="true_false",
            nn="01",
            question="Adorar Jeová na beleza da santidade é acréscimo opcional depois de tributar glória ao nome.",
            ok="Certo: o versículo une glória, oferta e adoração santa, sem torná-las opcionais.",
            wrong={"true": "O texto ordena adorar na beleza da santidade, não sugere um extra."},
            options=tf_opts(),
            correct="false",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="tap",
            nn="02",
            question='Em 1 Crônicas 16:29, toque a palavra que falta em "adorai a Jeová na beleza da ___"?',
            ok='Exato: a adoração se dá na beleza da "santidade".',
            wrong={
                "a": "Glória é o que se tributa ao nome, não esta lacuna.",
                "c": "Oferta se traz à presença, não qualifica aqui a beleza.",
            },
            options=opts(("a", "glória"), ("b", "santidade"), ("c", "oferta")),
            correct="b",
            template="adorai a Jeová na beleza da ___.",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="choice",
            nn="03",
            question="O que 1 Crônicas 16:29 ensina sobre o sentido da adoração diante da arca?",
            ok="Certo: Jeová é adorado na santidade, não como espetáculo humano.",
            wrong={
                "a": "O texto não reduz o culto a desempenho artístico.",
                "b": "Não trata a oferta como suborno da presença.",
                "c": "A glória é devida ao nome de Jeová, não à fama do povo.",
            },
            options=opts(
                ("a", "A arca pede espetáculo, não santidade."),
                ("b", "A oferta compra o direito de ignorar o nome."),
                ("c", "A glória é devida à fama de Israel, não a Jeová."),
                ("d", "A presença de Jeová pede glória, oferta e santidade."),
            ),
            correct="d",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="order",
            nn="04",
            question="Qual sequência revela o sentido de 1 Crônicas 16:29?",
            ok="Certo: o sentido vai da glória ao nome, à oferta na presença, à santidade.",
            wrong={
                "a": "Começar pela santidade esconde o tributo primeiro ao nome.",
                "b": "A oferta não é o primeiro movimento do versículo.",
            },
            options=opts(
                ("a", "adorai a Jeová na beleza da santidade"),
                ("b", "Trazei uma oferta e vinde à sua presença"),
                ("c", "Tributai a Jeová a glória devida ao seu nome"),
            ),
            correct="c",
            correctOrder=["c", "b", "a"],
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="complete",
            nn="05",
            question='Complete a frase: "Tributai a Jeová a glória devida ao seu ___."',
            ok='Certo: a glória é devida ao "nome" de Jeová.',
            wrong={
                "a": "Fogo não aparece neste versículo.",
                "b": "Oferta vem no convite seguinte, não nesta lacuna.",
            },
            options=opts(("a", "fogo"), ("b", "oferta"), ("c", "nome")),
            correct="c",
            template="Tributai a Jeová a glória devida ao seu ___.",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="connect",
            nn="06",
            question="O que 1 Crônicas 16:29 comunica que se liga a este contexto?",
            ok="Certo: Jeová se recebe na beleza da santidade, não no improviso.",
            wrong={
                "a": "O texto não ensina culto casual sem glória ao nome.",
                "c": "Não apresenta a arca como fim em si, sem adoração.",
            },
            options=opts(
                ("a", "Culto casual sem o nome"),
                ("b", "Santidade que recebe Jeová"),
                ("c", "Arca como fim em si"),
            ),
            correct="b",
            passageA={
                "ref": "1 Crônicas 16:29",
                "text": "adorai a Jeová na beleza da santidade",
            },
            passageB={
                "ref": "Contexto",
                "text": "A arca chama a adoração: glória ao nome, oferta e presença — Jeová na beleza da santidade.",
            },
        ),
    ],
)

# ---------------------------------------------------------------------------
# M2 1 Crônicas 22:5
# ---------------------------------------------------------------------------
P2 = (
    "Disse Davi consigo: Meu filho Salomão é ainda moço e tenro, e a casa que "
    "se há de edificar para Jeová deve ser magnificentíssima, digna de fama e "
    "de glória em todos os países. Começar-lhe-ei os preparos. Assim, Davi, "
    "antes da sua morte, fez grandes preparos."
)
LO2 = (
    "Perceber que Davi prepara a casa de Jeová para Salomão ainda moço: "
    "magnificência e glória, não improvisação."
)
bank += mission(
    "cronicas-culto-02-preparacao-do-templo",
    "1 Crônicas 22:5",
    P2,
    LO2,
    ["1 Crônicas 22:5"],
    [
        dict(
            diff="semente",
            skill="observe",
            type="true_false",
            nn="01",
            question="Davi disse consigo que Salomão já era velho e experiente para edificar a casa.",
            ok="Certo: o texto chama Salomão de ainda moço e tenro.",
            wrong={"true": "1 Crônicas 22:5: Salomão é ainda moço e tenro."},
            options=tf_opts(),
            correct="false",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="tap",
            nn="02",
            question='Em 1 Crônicas 22:5, toque a palavra que falta em "Meu filho Salomão é ainda ___ e tenro"?',
            ok='Exato: Salomão é ainda "moço" e tenro.',
            wrong={
                "b": "Tenro acompanha moço, mas não preenche esta lacuna.",
                "c": "Preparos é o que Davi fará, não a idade de Salomão.",
            },
            options=opts(("a", "moço"), ("b", "tenro"), ("c", "preparos")),
            correct="a",
            template="Meu filho Salomão é ainda ___ e tenro",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="choice",
            nn="03",
            question="O que Davi afirma sobre a casa que se há de edificar para Jeová?",
            ok="Certo: deve ser magnificentíssima, digna de fama e glória.",
            wrong={
                "b": "O texto pede magnificência, não uma cabana improvisada.",
                "c": "Davi começa os preparos; não recusa a obra.",
                "d": "Não diz que a casa deve ficar oculta aos países.",
            },
            options=opts(
                ("a", "Deve ser magnificentíssima, digna de fama e de glória."),
                ("b", "Deve ser uma cabana improvisada e passageira."),
                ("c", "Davi recusa qualquer preparo antes de morrer."),
                ("d", "A casa deve ficar oculta a todos os países."),
            ),
            correct="a",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="order",
            nn="04",
            question="Qual sequência mostra a ordem dos fatos em 1 Crônicas 22:5?",
            ok="Certo: Salomão moço, a casa magnificentíssima, depois os grandes preparos.",
            wrong={
                "b": "Os preparos fecham o versículo, não o abrem.",
                "c": "A magnificência vem depois da observação sobre Salomão.",
            },
            options=opts(
                ("a", "Meu filho Salomão é ainda moço e tenro"),
                ("b", "a casa que se há de edificar para Jeová deve ser magnificentíssima"),
                ("c", "Davi, antes da sua morte, fez grandes preparos"),
            ),
            correct="a",
            correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente",
            skill="observe",
            type="complete",
            nn="05",
            question='Complete a frase: "Assim, Davi, antes da sua morte, fez grandes ___."',
            ok='Certo: Davi fez grandes "preparos" antes de morrer.',
            wrong={
                "a": "Moço descreve Salomão, não o que Davi fez.",
                "c": "Fama qualifica a casa, não o ato de Davi nesta frase.",
            },
            options=opts(("a", "moço"), ("b", "preparos"), ("c", "fama")),
            correct="b",
            template="Assim, Davi, antes da sua morte, fez grandes ___.",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="connect",
            nn="06",
            question="O que 1 Crônicas 22:5 comunica que se liga a este contexto?",
            ok="Certo: Davi prepara a casa que outro edificará.",
            wrong={
                "a": "O texto não narra Davi concluindo o templo sozinho.",
                "c": "Não apresenta a casa de Jeová como obra menor.",
            },
            options=opts(
                ("a", "Davi conclui o templo sozinho"),
                ("b", "Preparos para a casa de Jeová"),
                ("c", "Casa de Jeová como obra menor"),
            ),
            correct="b",
            passageA={
                "ref": "1 Crônicas 22:5",
                "text": "Começar-lhe-ei os preparos. Assim, Davi, antes da sua morte, fez grandes preparos.",
            },
            passageB={
                "ref": "Contexto",
                "text": "Davi prepara o templo que não edificará: a casa de Jeová pede glória, não improvisação.",
            },
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="true_false",
            nn="01",
            question="Davi começa os preparos porque a casa de Jeová deve ser magnificentíssima entre os países.",
            ok="Certo: a magnificência da casa motiva os preparos de Davi.",
            wrong={"false": "Releia: a casa deve ser magnificentíssima; por isso os preparos."},
            options=tf_opts(),
            correct="true",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="tap",
            nn="02",
            question='Em 1 Crônicas 22:5, toque a palavra que falta em "Meu filho Salomão é ainda moço e ___"?',
            ok='Exato: além de moço, Salomão é "tenro".',
            wrong={
                "a": "Moço já está na frase; a lacuna pede o segundo adjetivo.",
                "c": "Morte marca o tempo de Davi, não a condição de Salomão.",
            },
            options=opts(("a", "moço"), ("b", "tenro"), ("c", "morte")),
            correct="b",
            template="Meu filho Salomão é ainda moço e ___",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="choice",
            nn="03",
            question="Por que Davi antecipa preparos em 1 Crônicas 22:5, se não edificará a casa?",
            ok="Certo: Salomão é moço e a casa pede glória; Davi não improvisa.",
            wrong={
                "a": "O texto não diz que Davi desistiu da casa de Jeová.",
                "c": "Não reduz a obra a um palácio para Salomão.",
                "d": "Os países não exigem um templo pobre; o texto pede glória.",
            },
            options=opts(
                ("a", "Porque Davi desistiu da casa de Jeová."),
                ("b", "Porque Salomão é moço e a casa pede glória, não improviso."),
                ("c", "Porque a obra seria só um palácio para Salomão."),
                ("d", "Porque os países exigiam um templo pobre e rápido."),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="order",
            nn="04",
            question="Como se encadeiam os eventos de 1 Crônicas 22:5?",
            ok="Certo: a fragilidade de Salomão, o padrão da casa, então os preparos.",
            wrong={
                "a": "Os preparos não antecedem o juízo sobre a casa.",
                "c": "A magnificência não é o primeiro elo do encadeamento.",
            },
            options=opts(
                ("a", "Davi, antes da sua morte, fez grandes preparos"),
                ("b", "Meu filho Salomão é ainda moço e tenro"),
                ("c", "a casa que se há de edificar para Jeová deve ser magnificentíssima"),
            ),
            correct="b",
            correctOrder=["b", "c", "a"],
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="complete",
            nn="05",
            question='Complete a frase: "a casa que se há de edificar para Jeová deve ser ___."',
            ok='Certo: a casa deve ser "magnificentíssima".',
            wrong={
                "a": "Tenro descreve Salomão, não a casa.",
                "c": "Preparos é o que Davi faz, não o adjetivo da casa.",
            },
            options=opts(("a", "tenro"), ("b", "magnificentíssima"), ("c", "preparos")),
            correct="b",
            template="a casa que se há de edificar para Jeová deve ser ___.",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="connect",
            nn="06",
            question="O que 1 Crônicas 22:5 comunica que se liga a este contexto?",
            ok="Certo: a casa de Jeová pede glória antecipada, não pressa barata.",
            wrong={
                "a": "O texto não elogia improvisar a casa de Jeová.",
                "c": "Não trata a juventude de Salomão como desculpa para omissão.",
            },
            options=opts(
                ("a", "Improviso como virtude do culto"),
                ("b", "Glória que pede preparo prévio"),
                ("c", "Juventude como desculpa para omitir"),
            ),
            correct="b",
            passageA={
                "ref": "1 Crônicas 22:5",
                "text": "a casa que se há de edificar para Jeová deve ser magnificentíssima",
            },
            passageB={
                "ref": "Contexto",
                "text": "Davi prepara o templo que não edificará: a casa de Jeová pede glória, não improvisação.",
            },
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="true_false",
            nn="01",
            question="O texto ensina que a casa de Jeová pode ser improvisada, pois Salomão ainda é moço.",
            ok="Certo: a juventude de Salomão motiva preparos, não improvisação.",
            wrong={"true": "Davi faz grandes preparos precisamente porque a casa pede glória."},
            options=tf_opts(),
            correct="false",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="tap",
            nn="02",
            question='Em 1 Crônicas 22:5, toque a palavra que falta em "digna de ___ e de glória em todos os países"?',
            ok='Exato: a casa deve ser digna de "fama" e de glória.',
            wrong={
                "a": "Moço descreve Salomão, não a dignidade da casa.",
                "c": "Morte marca o tempo de Davi, não esta dignidade.",
            },
            options=opts(("a", "moço"), ("b", "fama"), ("c", "morte")),
            correct="b",
            template="digna de ___ e de glória em todos os países",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="choice",
            nn="03",
            question="O que a decisão de Davi revela sobre a casa de Jeová em 1 Crônicas 22:5?",
            ok="Certo: a glória de Jeová não espera o herdeiro amadurecer sozinho.",
            wrong={
                "a": "O texto não trata o templo como monumento à fama de Davi.",
                "b": "Não apresenta a morte como fim do cuidado com a casa.",
                "d": "Não reduz os preparos a tesouro particular de Salomão.",
            },
            options=opts(
                ("a", "O templo existe para eternizar a fama pessoal de Davi."),
                ("b", "A morte de Davi encerra qualquer cuidado com a casa."),
                ("c", "A glória de Jeová pede preparo mesmo quem não edificará."),
                ("d", "Os preparos são tesouro particular para Salomão governar."),
            ),
            correct="c",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="order",
            nn="04",
            question="Qual sequência revela o sentido de 1 Crônicas 22:5?",
            ok="Certo: o sentido vai da fragilidade do filho à glória da casa e ao preparo.",
            wrong={
                "b": "Começar pelos preparos esconde o motivo da magnificência.",
                "c": "A fama da casa não é o primeiro movimento do texto.",
            },
            options=opts(
                ("a", "Meu filho Salomão é ainda moço e tenro"),
                ("b", "Davi, antes da sua morte, fez grandes preparos"),
                ("c", "a casa deve ser magnificentíssima, digna de fama e de glória"),
            ),
            correct="a",
            correctOrder=["a", "c", "b"],
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="complete",
            nn="05",
            question='Complete a frase: "Assim, Davi, antes da sua ___, fez grandes preparos."',
            ok='Certo: os preparos acontecem antes da "morte" de Davi.',
            wrong={
                "a": "Fama descreve a casa, não o limite do tempo de Davi.",
                "c": "Glória é o padrão da casa, não esta lacuna.",
            },
            options=opts(("a", "fama"), ("b", "morte"), ("c", "glória")),
            correct="b",
            template="Assim, Davi, antes da sua ___, fez grandes preparos.",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="connect",
            nn="06",
            question="O que 1 Crônicas 22:5 comunica que se liga a este contexto?",
            ok="Certo: quem não edifica ainda pode preparar glória para Jeová.",
            wrong={
                "b": "O texto não ensina esperar a morte para começar.",
                "c": "Não trata a casa de Jeová como luxo dispensável.",
            },
            options=opts(
                ("a", "Preparar o que outro edificará"),
                ("b", "Esperar a morte para começar"),
                ("c", "Casa de Jeová como luxo extra"),
            ),
            correct="a",
            passageA={
                "ref": "1 Crônicas 22:5",
                "text": "Começar-lhe-ei os preparos",
            },
            passageB={
                "ref": "Contexto",
                "text": "Davi prepara o templo que não edificará: a casa de Jeová pede glória, não improvisação.",
            },
        ),
    ],
)

# ---------------------------------------------------------------------------
# M3 2 Crônicas 7:1–2
# ---------------------------------------------------------------------------
P3 = (
    "Tendo Salomão acabado de orar, desceu do céu o fogo e consumiu o "
    "holocausto e os sacrifícios; e a glória de Jeová encheu a casa. Os "
    "sacerdotes não podiam entrar na Casa de Jeová, porque a glória de Jeová "
    "encheu a sua casa."
)
LO3 = (
    "Ver que a dedicação termina em fogo do céu e glória que enche a casa, "
    "de modo que os sacerdotes não podem entrar."
)
bank += mission(
    "cronicas-templo-01-salomao-dedica-o-tem",
    "2 Crônicas 7:1–2",
    P3,
    LO3,
    ["2 Crônicas 7:1", "2 Crônicas 7:2"],
    [
        dict(
            diff="semente",
            skill="observe",
            type="true_false",
            nn="01",
            question="Tendo Salomão acabado de orar, desceu do céu o fogo e consumiu o holocausto e os sacrifícios.",
            ok="Certo: o fogo desce do céu depois da oração de Salomão.",
            wrong={"false": "Releia 2 Crônicas 7:1: o fogo desce e consome os sacrifícios."},
            options=tf_opts(),
            correct="true",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="tap",
            nn="02",
            question='Em 2 Crônicas 7:1–2, toque a palavra que falta em "desceu do céu o ___ e consumiu o holocausto"?',
            ok='Exato: desceu do céu o "fogo" e consumiu o holocausto.',
            wrong={
                "a": "Céu é a origem, não o que desce e consome.",
                "c": "Glória enche a casa depois; não é o que consome o holocausto.",
            },
            options=opts(("a", "céu"), ("b", "fogo"), ("c", "glória")),
            correct="b",
            template="desceu do céu o ___ e consumiu o holocausto",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="choice",
            nn="03",
            question="O que acontece com a casa depois que o fogo consome os sacrifícios?",
            ok="Certo: a glória de Jeová enche a casa.",
            wrong={
                "a": "Os sacerdotes não entram; a casa não fica vazia.",
                "b": "O texto não diz que o fogo apaga a glória.",
                "d": "Não narra o desmonte da casa neste momento.",
            },
            options=opts(
                ("a", "Os sacerdotes encontram a casa vazia e silenciosa."),
                ("b", "O fogo apaga a glória de Jeová na casa."),
                ("c", "A glória de Jeová encheu a casa."),
                ("d", "Salomão manda desmontar a Casa de Jeová."),
            ),
            correct="c",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="order",
            nn="04",
            question="Qual sequência mostra a ordem dos fatos em 2 Crônicas 7:1–2?",
            ok="Certo: oração, fogo que consome, glória que impede a entrada.",
            wrong={
                "b": "A glória que impede a entrada não é o primeiro fato.",
                "c": "O fogo segue a oração, não a precede.",
            },
            options=opts(
                ("a", "Tendo Salomão acabado de orar"),
                ("b", "desceu do céu o fogo e consumiu o holocausto e os sacrifícios"),
                ("c", "Os sacerdotes não podiam entrar na Casa de Jeová"),
            ),
            correct="a",
            correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente",
            skill="observe",
            type="complete",
            nn="05",
            question='Complete a frase: "e a glória de Jeová ___ a casa."',
            ok='Certo: a glória de Jeová "encheu" a casa.',
            wrong={
                "a": "Consumiu refere-se ao holocausto, não à glória nesta frase.",
                "c": "Orar é o que Salomão acabou de fazer, não o verbo da glória.",
            },
            options=opts(("a", "consumiu"), ("b", "encheu"), ("c", "orar")),
            correct="b",
            template="e a glória de Jeová ___ a casa.",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="connect",
            nn="06",
            question="O que 2 Crônicas 7:1–2 comunica que se liga a este contexto?",
            ok="Certo: fogo do céu e glória que enche marcam a dedicação.",
            wrong={
                "a": "O texto não descreve um monumento sem presença.",
                "b": "Não narra os sacerdotes mandando na glória.",
            },
            options=opts(
                ("a", "Monumento sem presença"),
                ("b", "Sacerdotes que mandam na glória"),
                ("c", "Fogo e glória que enchem"),
            ),
            correct="c",
            passageA={
                "ref": "2 Crônicas 7:1",
                "text": "desceu do céu o fogo e consumiu o holocausto e os sacrifícios",
            },
            passageB={
                "ref": "Contexto",
                "text": "Salomão dedica: fogo do céu e glória que enche — o templo é habitação, não monumento.",
            },
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="true_false",
            nn="01",
            question="Os sacerdotes puderam entrar normalmente na Casa de Jeová logo após a oração.",
            ok="Certo: não podiam entrar, porque a glória encheu a casa.",
            wrong={"true": "2 Crônicas 7:2: os sacerdotes não podiam entrar."},
            options=tf_opts(),
            correct="false",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="tap",
            nn="02",
            question='Em 2 Crônicas 7:1–2, toque a palavra que falta em "consumiu o ___ e os sacrifícios"?',
            ok='Exato: o fogo consumiu o "holocausto" e os sacrifícios.',
            wrong={
                "b": "Sacerdotes não entram na casa; não são o que o fogo consome.",
                "c": "Casa é o que a glória enche, não o que o fogo consome aqui.",
            },
            options=opts(("a", "holocausto"), ("b", "sacerdotes"), ("c", "casa")),
            correct="a",
            template="consumiu o ___ e os sacrifícios",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="choice",
            nn="03",
            question="O que o encadeamento de 2 Crônicas 7:1–2 mostra sobre oração e glória?",
            ok="Certo: a oração de Salomão precede o fogo e a glória que enche.",
            wrong={
                "b": "O fogo não substitui a oração; vem depois que ela acaba.",
                "c": "Os sacerdotes não controlam a glória; ela os impede.",
                "d": "A casa não fica vazia; a glória a enche.",
            },
            options=opts(
                ("a", "A oração acabada precede o fogo e a glória que enche."),
                ("b", "O fogo substitui a oração, tornando-a desnecessária."),
                ("c", "Os sacerdotes controlam quando a glória pode encher."),
                ("d", "A casa permanece vazia para provar a fé de Salomão."),
            ),
            correct="a",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="order",
            nn="04",
            question="Como se encadeiam os eventos de 2 Crônicas 7:1–2?",
            ok="Certo: oração, fogo que consome, depois glória que impede a entrada.",
            wrong={
                "a": "A impossibilidade de entrar não abre o encadeamento.",
                "c": "O fogo não vem depois da recusa dos sacerdotes.",
            },
            options=opts(
                ("a", "Os sacerdotes não podiam entrar na Casa de Jeová"),
                ("b", "Tendo Salomão acabado de orar"),
                ("c", "desceu do céu o fogo e consumiu o holocausto e os sacrifícios"),
            ),
            correct="b",
            correctOrder=["b", "c", "a"],
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="complete",
            nn="05",
            question='Complete a frase: "Os ___ não podiam entrar na Casa de Jeová."',
            ok='Certo: os "sacerdotes" não podiam entrar.',
            wrong={
                "a": "Holocausto é o que o fogo consome, não quem tenta entrar.",
                "c": "Fogo desce do céu; não é o sujeito desta frase.",
            },
            options=opts(("a", "holocausto"), ("b", "sacerdotes"), ("c", "fogo")),
            correct="b",
            template="Os ___ não podiam entrar na Casa de Jeová.",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="connect",
            nn="06",
            question="O que 2 Crônicas 7:1–2 comunica que se liga a este contexto?",
            ok="Certo: a glória ocupa a casa e limita até o ministério sacerdotal.",
            wrong={
                "a": "O texto não trata o templo como palco vazio.",
                "c": "Não apresenta o fogo como acidente da cerimônia.",
            },
            options=opts(
                ("a", "Templo como palco vazio"),
                ("b", "Glória que limita o ministério"),
                ("c", "Fogo como acidente ritual"),
            ),
            correct="b",
            passageA={
                "ref": "2 Crônicas 7:2",
                "text": "Os sacerdotes não podiam entrar na Casa de Jeová, porque a glória de Jeová encheu a sua casa.",
            },
            passageB={
                "ref": "Contexto",
                "text": "O templo é habitação: a glória enche a ponto de os sacerdotes não entrarem.",
            },
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="true_false",
            nn="01",
            question="A glória que enche a casa mostra o templo como habitação de Jeová, não só como monumento de Salomão.",
            ok="Certo: o fogo e a glória afirmam presença, não pedra vazia.",
            wrong={"false": "O texto une fogo do céu e glória que impede até os sacerdotes."},
            options=tf_opts(),
            correct="true",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="tap",
            nn="02",
            question='Em 2 Crônicas 7:1–2, toque a palavra que falta em "Tendo Salomão acabado de ___, desceu do céu o fogo"?',
            ok='Exato: o fogo desce depois que Salomão acaba de "orar".',
            wrong={
                "b": "Entrar é o que os sacerdotes não podem; não é o ato de Salomão.",
                "c": "Casa é o lugar enchido, não o verbo desta cláusula.",
            },
            options=opts(("a", "orar"), ("b", "entrar"), ("c", "casa")),
            correct="a",
            template="Tendo Salomão acabado de ___, desceu do céu o fogo",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="choice",
            nn="03",
            question="O que 2 Crônicas 7:1–2 impede de concluir sobre o templo dedicado?",
            ok="Certo: o templo não é monumento humano; Jeová o habita com glória.",
            wrong={
                "a": "O texto não reduz a glória a efeito psicológico.",
                "b": "Não ensina que o fogo torna a oração inútil.",
                "c": "Não afirma que os sacerdotes superam a glória.",
            },
            options=opts(
                ("a", "A glória é só emoção coletiva da festa."),
                ("b", "O fogo prova que orar era desnecessário."),
                ("c", "Os sacerdotes superam a glória e entram à força."),
                ("d", "Jeová habita a casa; ela não é só monumento de Salomão."),
            ),
            correct="d",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="order",
            nn="04",
            question="Qual sequência revela o sentido de 2 Crônicas 7:1–2?",
            ok="Certo: o sentido vai da oração ao fogo e à glória que ocupa a casa.",
            wrong={
                "a": "Começar pela recusa dos sacerdotes esconde a oração.",
                "b": "A glória que enche não é o primeiro movimento.",
            },
            options=opts(
                ("a", "Os sacerdotes não podiam entrar na Casa de Jeová"),
                ("b", "a glória de Jeová encheu a casa"),
                ("c", "Tendo Salomão acabado de orar, desceu do céu o fogo"),
            ),
            correct="c",
            correctOrder=["c", "b", "a"],
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="complete",
            nn="05",
            question='Complete a frase: "desceu do ___ o fogo e consumiu o holocausto."',
            ok='Certo: o fogo desceu do "céu".',
            wrong={
                "b": "Casa é o que a glória enche, não a origem do fogo.",
                "c": "Holocausto é o que se consome, não de onde o fogo desce.",
            },
            options=opts(("a", "céu"), ("b", "casa"), ("c", "holocausto")),
            correct="a",
            template="desceu do ___ o fogo e consumiu o holocausto.",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="connect",
            nn="06",
            question="O que 2 Crônicas 7:1–2 comunica que se liga a este contexto?",
            ok="Certo: o templo vive de habitação, não de pedra monumental.",
            wrong={
                "a": "O texto não ensina templo como obra de arte vazia.",
                "c": "Não apresenta a glória como decoração da festa.",
            },
            options=opts(
                ("a", "Templo como arte vazia"),
                ("b", "Habitação, não monumento"),
                ("c", "Glória como decoração da festa"),
            ),
            correct="b",
            passageA={
                "ref": "2 Crônicas 7:1",
                "text": "a glória de Jeová encheu a casa",
            },
            passageB={
                "ref": "Contexto",
                "text": "Salomão dedica: fogo do céu e glória que enche — o templo é habitação, não monumento.",
            },
        ),
    ],
)

# ---------------------------------------------------------------------------
# M4 2 Crônicas 34:31
# ---------------------------------------------------------------------------
P4 = (
    "O rei, posto em pé no seu lugar, fez perante Jeová esta aliança, de andar "
    "após Jeová e guardar os seus mandamentos, os seus testemunhos e os seus "
    "estatutos de todo o seu coração e de toda a sua alma, a fim de cumprir as "
    "palavras da aliança que estavam escritas naquele livro."
)
LO4 = (
    "Compreender que a reforma de Josias é aliança perante Jeová para guardar "
    "o livro de todo o coração e de toda a alma."
)
bank += mission(
    "cronicas-templo-02-reformas-e-quedas",
    "2 Crônicas 34:31",
    P4,
    LO4,
    ["2 Crônicas 34:31"],
    [
        dict(
            diff="semente",
            skill="observe",
            type="true_false",
            nn="01",
            question="O rei fez a aliança sentado em silêncio, sem se pôr em pé no seu lugar.",
            ok="Certo: o texto diz que o rei estava posto em pé no seu lugar.",
            wrong={"true": "2 Crônicas 34:31: o rei, posto em pé no seu lugar, fez a aliança."},
            options=tf_opts(),
            correct="false",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="tap",
            nn="02",
            question='Em 2 Crônicas 34:31, toque a palavra que falta em "fez perante Jeová esta ___"?',
            ok='Exato: o rei fez perante Jeová esta "aliança".',
            wrong={
                "b": "Livro é onde as palavras estavam escritas, não o que ele fez aqui.",
                "c": "Alma descreve a medida da guarda, não o ato inicial.",
            },
            options=opts(("a", "aliança"), ("b", "livro"), ("c", "alma")),
            correct="a",
            template="fez perante Jeová esta ___,",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="choice",
            nn="03",
            question="O que o rei promete guardar na aliança de 2 Crônicas 34:31?",
            ok="Certo: mandamentos, testemunhos e estatutos de coração e alma.",
            wrong={
                "a": "O texto não limita a aliança a impostos do templo.",
                "c": "Não promete só consertar pedras, sem o livro.",
                "d": "Não recusa guardar os estatutos.",
            },
            options=opts(
                ("a", "Somente os impostos do templo, sem o livro."),
                ("b", "Mandamentos, testemunhos e estatutos de coração e alma."),
                ("c", "Apenas o conserto das pedras do edifício."),
                ("d", "Nada: o rei recusa guardar os estatutos."),
            ),
            correct="b",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="order",
            nn="04",
            question="Qual sequência mostra a ordem dos fatos em 2 Crônicas 34:31?",
            ok="Certo: o rei em pé, a aliança de andar e guardar, depois cumprir o livro.",
            wrong={
                "b": "Cumprir o livro fecha o versículo, não o abre.",
                "c": "Guardar mandamentos vem depois de se pôr em pé.",
            },
            options=opts(
                ("a", "O rei, posto em pé no seu lugar, fez perante Jeová esta aliança"),
                ("b", "andar após Jeová e guardar os seus mandamentos, testemunhos e estatutos"),
                ("c", "cumprir as palavras da aliança que estavam escritas naquele livro"),
            ),
            correct="a",
            correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente",
            skill="observe",
            type="complete",
            nn="05",
            question='Complete a frase: "cumprir as palavras da aliança que estavam escritas naquele ___."',
            ok='Certo: as palavras estavam escritas naquele "livro".',
            wrong={
                "a": "Aliança é o pacto feito, não o suporte escrito nesta lacuna.",
                "c": "Coração é a medida da guarda, não o objeto escrito.",
            },
            options=opts(("a", "aliança"), ("b", "livro"), ("c", "coração")),
            correct="b",
            template="cumprir as palavras da aliança que estavam escritas naquele ___.",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="connect",
            nn="06",
            question="O que 2 Crônicas 34:31 comunica que se liga a este contexto?",
            ok="Certo: a reforma é aliança com o livro, não só obra em pedra.",
            wrong={
                "a": "O texto não reduz a reforma a pedras sem aliança.",
                "c": "Não apresenta o rei recusando o livro.",
            },
            options=opts(
                ("a", "Reforma só de pedras"),
                ("b", "Aliança com o livro"),
                ("c", "Rei que recusa o livro"),
            ),
            correct="b",
            passageA={
                "ref": "2 Crônicas 34:31",
                "text": "fez perante Jeová esta aliança, de andar após Jeová",
            },
            passageB={
                "ref": "Contexto",
                "text": "Reforma é aliança de coração inteiro com o livro — não só conserto de pedras.",
            },
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="true_false",
            nn="01",
            question="A aliança inclui guardar mandamentos, testemunhos e estatutos de todo o coração e de toda a alma.",
            ok="Certo: o texto une guarda completa e coração inteiro.",
            wrong={"false": "Releia 2 Crônicas 34:31: coração e alma na guarda do livro."},
            options=tf_opts(),
            correct="true",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="tap",
            nn="02",
            question='Em 2 Crônicas 34:31, toque a palavra que falta em "de todo o seu ___ e de toda a sua alma"?',
            ok='Exato: a guarda é de todo o "coração" e de toda a alma.',
            wrong={
                "a": "Livro é o suporte das palavras, não esta medida interior.",
                "c": "Lugar é onde o rei está em pé, não o que se dá por inteiro aqui.",
            },
            options=opts(("a", "livro"), ("b", "coração"), ("c", "lugar")),
            correct="b",
            template="de todo o seu ___ e de toda a sua alma",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="choice",
            nn="03",
            question="Como se relacionam aliança, coração e livro em 2 Crônicas 34:31?",
            ok="Certo: a aliança visa cumprir o escrito, com o rei inteiro.",
            wrong={
                "a": "O texto não separa o livro da aliança viva.",
                "c": "Não reduz o pacto a pose pública sem guarda.",
                "d": "Testemunhos e estatutos não são opcionais no texto.",
            },
            options=opts(
                ("a", "O livro substitui a aliança, tornando-a inútil."),
                ("b", "A aliança une o rei inteiro às palavras escritas."),
                ("c", "Basta a pose em pé, sem guardar mandamentos."),
                ("d", "Testemunhos e estatutos ficam de fora da aliança."),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="order",
            nn="04",
            question="Como se encadeiam os eventos de 2 Crônicas 34:31?",
            ok="Certo: o rei em pé, a guarda de coração, então cumprir o livro.",
            wrong={
                "a": "Cumprir o escrito não abre o encadeamento.",
                "c": "A guarda não antecede o ato de se pôr em pé.",
            },
            options=opts(
                ("a", "cumprir as palavras da aliança que estavam escritas naquele livro"),
                ("b", "O rei, posto em pé no seu lugar, fez perante Jeová esta aliança"),
                ("c", "guardar os seus mandamentos de todo o seu coração e de toda a sua alma"),
            ),
            correct="b",
            correctOrder=["b", "c", "a"],
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="complete",
            nn="05",
            question='Complete a frase: "de todo o seu coração e de toda a sua ___."',
            ok='Certo: a guarda é também de toda a "alma".',
            wrong={
                "a": "Aliança é o pacto, não o segundo termo desta dupla.",
                "c": "Livro é o suporte escrito, não esta lacuna.",
            },
            options=opts(("a", "aliança"), ("b", "alma"), ("c", "livro")),
            correct="b",
            template="de todo o seu coração e de toda a sua ___.",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="connect",
            nn="06",
            question="O que 2 Crônicas 34:31 comunica que se liga a este contexto?",
            ok="Certo: reforma sem o livro e sem o coração não é a aliança do texto.",
            wrong={
                "b": "O texto não ensina reforma só estética do templo.",
                "c": "Não trata o livro como relíquia sem cumprimento.",
            },
            options=opts(
                ("a", "Coração inteiro com o escrito"),
                ("b", "Reforma só estética do templo"),
                ("c", "Livro como relíquia sem cumprimento"),
            ),
            correct="a",
            passageA={
                "ref": "2 Crônicas 34:31",
                "text": "de todo o seu coração e de toda a sua alma",
            },
            passageB={
                "ref": "Contexto",
                "text": "Reforma é aliança de coração inteiro com o livro — não só conserto de pedras.",
            },
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="true_false",
            nn="01",
            question="Cumprir as palavras escritas no livro é acessório; a reforma basta como conserto de pedras.",
            ok="Certo: o fim da aliança é cumprir o escrito, não só consertar pedras.",
            wrong={"true": "O versículo visa cumprir as palavras da aliança escritas no livro."},
            options=tf_opts(),
            correct="false",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="tap",
            nn="02",
            question='Em 2 Crônicas 34:31, toque a palavra que falta em "guardar os seus ___, os seus testemunhos e os seus estatutos"?',
            ok='Exato: guardar os "mandamentos", testemunhos e estatutos.',
            wrong={
                "a": "Livro é o suporte; a lacuna pede o primeiro objeto da guarda.",
                "c": "Pé descreve a postura do rei, não o que se guarda.",
            },
            options=opts(("a", "livro"), ("b", "mandamentos"), ("c", "pé")),
            correct="b",
            template="guardar os seus ___, os seus testemunhos e os seus estatutos",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="choice",
            nn="03",
            question="O que 2 Crônicas 34:31 ensina sobre o sentido da reforma?",
            ok="Certo: reforma é pacto vivo com a Palavra, de pessoa inteira.",
            wrong={
                "a": "O texto não reduz a aliança a cerimônia vazia.",
                "c": "Não ensina que o livro substitui andar após Jeová.",
                "d": "Não apresenta o coração como opcional diante dos estatutos.",
            },
            options=opts(
                ("a", "A aliança é só cerimônia, sem guarda posterior."),
                ("b", "Reforma é pacto com a Palavra, de pessoa inteira."),
                ("c", "O livro dispensa andar após Jeová."),
                ("d", "O coração é opcional diante dos estatutos."),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="order",
            nn="04",
            question="Qual sequência revela o sentido de 2 Crônicas 34:31?",
            ok="Certo: o sentido vai da postura pública à guarda interior e ao livro.",
            wrong={
                "a": "Começar pelo livro esconde o rei em pé fazendo aliança.",
                "c": "A guarda interior não é o primeiro movimento visível.",
            },
            options=opts(
                ("a", "cumprir as palavras da aliança que estavam escritas naquele livro"),
                ("b", "O rei, posto em pé no seu lugar, fez perante Jeová esta aliança"),
                ("c", "guardar de todo o seu coração e de toda a sua alma"),
            ),
            correct="b",
            correctOrder=["b", "c", "a"],
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="complete",
            nn="05",
            question='Complete a frase: "as palavras da aliança que estavam ___ naquele livro."',
            ok='Certo: as palavras estavam "escritas" naquele livro.',
            wrong={
                "a": "Posto descreve o rei em pé, não as palavras.",
                "c": "Andar é o compromisso, não o estado das palavras no livro.",
            },
            options=opts(("a", "posto"), ("b", "escritas"), ("c", "andar")),
            correct="b",
            template="as palavras da aliança que estavam ___ naquele livro.",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="connect",
            nn="06",
            question="O que 2 Crônicas 34:31 comunica que se liga a este contexto?",
            ok="Certo: o livro cobra o rei inteiro, não só o pedreiro do templo.",
            wrong={
                "a": "O texto não ensina reforma sem Palavra.",
                "b": "Não trata a aliança como pose sem cumprimento.",
            },
            options=opts(
                ("a", "Reforma sem Palavra"),
                ("b", "Aliança como pose vazia"),
                ("c", "Livro que cobra o rei inteiro"),
            ),
            correct="c",
            passageA={
                "ref": "2 Crônicas 34:31",
                "text": "a fim de cumprir as palavras da aliança que estavam escritas naquele livro",
            },
            passageB={
                "ref": "Contexto",
                "text": "Reforma é aliança de coração inteiro com o livro — não só conserto de pedras.",
            },
        ),
    ],
)

# ---------------------------------------------------------------------------
# M5 2 Crônicas 7:14
# ---------------------------------------------------------------------------
P5 = (
    "se o meu povo, sobre quem foi invocado o meu nome, se humilhar, e orar, "
    "e buscar a minha face, e se desviar dos seus maus caminhos, eu ouvirei do "
    "céu, e perdoarei os seus pecados, e curarei a sua terra."
)
LO5 = (
    "Aprender que Jeová ouve, perdoa e sara se o povo do seu nome se humilhar, "
    "orar, buscar a face e se desviar dos maus caminhos."
)
bank += mission(
    "cronicas-templo-03-desafio-o-templo",
    "2 Crônicas 7:14",
    P5,
    LO5,
    ["2 Crônicas 7:14"],
    [
        dict(
            diff="semente",
            skill="observe",
            type="true_false",
            nn="01",
            question="Jeová fala de um povo sobre quem foi invocado o seu nome.",
            ok="Certo: o versículo identifica o povo pelo nome invocado.",
            wrong={"false": "Releia: se o meu povo, sobre quem foi invocado o meu nome."},
            options=tf_opts(),
            correct="true",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="tap",
            nn="02",
            question='Em 2 Crônicas 7:14, toque a palavra que falta em "se o meu povo, sobre quem foi invocado o meu nome, se ___"?',
            ok='Exato: o povo deve se "humilhar".',
            wrong={
                "b": "Orar vem em seguida, mas não preenche esta primeira lacuna.",
                "c": "Terra é o que Jeová curará, não o verbo do povo aqui.",
            },
            options=opts(("a", "humilhar"), ("b", "orar"), ("c", "terra")),
            correct="a",
            template="se o meu povo, sobre quem foi invocado o meu nome, se ___,",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="choice",
            nn="03",
            question="O que Jeová promete fazer se o povo se humilhar, orar, buscar a face e se desviar?",
            ok="Certo: ouvirá do céu, perdoará os pecados e curará a terra.",
            wrong={
                "a": "O texto não promete ignorar o povo.",
                "c": "Não ameaça destruir a terra neste versículo.",
                "d": "Não recusa ouvir do céu.",
            },
            options=opts(
                ("a", "Ignorar o povo e calar o céu."),
                ("b", "Ouvir do céu, perdoar os pecados e curar a terra."),
                ("c", "Destruir a terra sem perdoar."),
                ("d", "Recusar ouvir, mesmo com humilhação."),
            ),
            correct="b",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="order",
            nn="04",
            question="Qual sequência mostra a ordem dos fatos em 2 Crônicas 7:14?",
            ok="Certo: humilhar e orar, desviar-se, então ouvir, perdoar e curar.",
            wrong={
                "b": "A cura da terra fecha a promessa, não a abre.",
                "c": "Desviar-se vem depois de humilhar e orar.",
            },
            options=opts(
                ("a", "se humilhar, e orar, e buscar a minha face"),
                ("b", "se desviar dos seus maus caminhos"),
                ("c", "eu ouvirei do céu, e perdoarei os seus pecados, e curarei a sua terra"),
            ),
            correct="a",
            correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente",
            skill="observe",
            type="complete",
            nn="05",
            question='Complete a frase: "e buscar a minha ___."',
            ok='Certo: o povo deve buscar a "face" de Jeová.',
            wrong={
                "a": "Terra é o que será curada, não o que se busca aqui.",
                "c": "Céu é de onde Jeová ouve, não o objeto da busca.",
            },
            options=opts(("a", "terra"), ("b", "face"), ("c", "céu")),
            correct="b",
            template="e buscar a minha ___,",
        ),
        dict(
            diff="semente",
            skill="observe",
            type="connect",
            nn="06",
            question="O que 2 Crônicas 7:14 comunica que se liga a este contexto?",
            ok="Certo: o templo vive da humilhação do povo, não só do edifício.",
            wrong={
                "a": "O texto não ensina templo automático sem o povo.",
                "c": "Não apresenta Jeová surdo à humilhação.",
            },
            options=opts(
                ("a", "Templo automático sem o povo"),
                ("b", "Humilhação que abre o céu"),
                ("c", "Jeová surdo à humilhação"),
            ),
            correct="b",
            passageA={
                "ref": "2 Crônicas 7:14",
                "text": "se humilhar, e orar, e buscar a minha face",
            },
            passageB={
                "ref": "Contexto",
                "text": "O templo vive da humilhação do povo: orar, buscar a face, desviar-se — Jeová ouve e sara.",
            },
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="true_false",
            nn="01",
            question="Jeová promete curar a terra mesmo se o povo persistir nos maus caminhos, sem se desviar.",
            ok="Certo: desviar-se dos maus caminhos faz parte da condição.",
            wrong={"true": "O texto exige também desviar-se dos maus caminhos."},
            options=tf_opts(),
            correct="false",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="tap",
            nn="02",
            question='Em 2 Crônicas 7:14, toque a palavra que falta em "e se ___ dos seus maus caminhos"?',
            ok='Exato: o povo deve se "desviar" dos maus caminhos.',
            wrong={
                "a": "Humilhar abre a série; esta lacuna pede o desvio dos caminhos.",
                "c": "Pecados são o que Jeová perdoa, não o verbo desta cláusula.",
            },
            options=opts(("a", "humilhar"), ("b", "desviar"), ("c", "pecados")),
            correct="b",
            template="e se ___ dos seus maus caminhos",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="choice",
            nn="03",
            question="Como se relacionam as ações do povo e as promessas de Jeová em 2 Crônicas 7:14?",
            ok="Certo: humilhar, orar, buscar e desviar-se antecedem ouvir, perdoar e curar.",
            wrong={
                "a": "O texto não inverte a ordem: a cura não vem antes da humilhação.",
                "c": "Não reduz tudo a orar sem desvio dos caminhos.",
                "d": "O nome invocado não anula a necessidade de se humilhar.",
            },
            options=opts(
                ("a", "A cura da terra vem primeiro, depois a humilhação."),
                ("b", "As ações do povo antecedem ouvir, perdoar e curar."),
                ("c", "Basta orar; desviar-se dos caminhos é opcional."),
                ("d", "O nome invocado dispensa qualquer humilhação."),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="order",
            nn="04",
            question="Como se encadeiam os eventos de 2 Crônicas 7:14?",
            ok="Certo: o povo se humilha e se desvia; então Jeová ouve e sara.",
            wrong={
                "a": "A cura não abre o encadeamento do versículo.",
                "c": "Desviar-se não vem depois da promessa de ouvir.",
            },
            options=opts(
                ("a", "eu ouvirei do céu, e perdoarei os seus pecados, e curarei a sua terra"),
                ("b", "se humilhar, e orar, e buscar a minha face"),
                ("c", "se desviar dos seus maus caminhos"),
            ),
            correct="b",
            correctOrder=["b", "c", "a"],
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="complete",
            nn="05",
            question='Complete a frase: "e perdoarei os seus ___."',
            ok='Certo: Jeová perdoará os "pecados".',
            wrong={
                "a": "Caminhos são de onde o povo se desvia, não o objeto do perdão aqui.",
                "c": "Nome identifica o povo, não o que se perdoa nesta frase.",
            },
            options=opts(("a", "caminhos"), ("b", "pecados"), ("c", "nome")),
            correct="b",
            template="e perdoarei os seus ___,",
        ),
        dict(
            diff="caminhada",
            skill="understand",
            type="connect",
            nn="06",
            question="O que 2 Crônicas 7:14 comunica que se liga a este contexto?",
            ok="Certo: o templo pede povo que se desvia, não só ritual no recinto.",
            wrong={
                "b": "O texto não ensina perdão sem desvio dos caminhos.",
                "c": "Não trata a face de Jeová como irrelevante.",
            },
            options=opts(
                ("a", "Povo que se desvia e é ouvido"),
                ("b", "Perdão sem desvio dos caminhos"),
                ("c", "Face de Jeová como irrelevante"),
            ),
            correct="a",
            passageA={
                "ref": "2 Crônicas 7:14",
                "text": "se desviar dos seus maus caminhos",
            },
            passageB={
                "ref": "Contexto",
                "text": "O templo vive da humilhação do povo: orar, buscar a face, desviar-se — Jeová ouve e sara.",
            },
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="true_false",
            nn="01",
            question="O templo permanece vivo mesmo que o povo recuse humilhar-se, orar e buscar a face de Jeová.",
            ok="Certo: a promessa condiciona a vida da terra à humilhação do povo.",
            wrong={"true": "2 Crônicas 7:14 liga ouvir, perdoar e curar às ações do povo."},
            options=tf_opts(),
            correct="false",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="tap",
            nn="02",
            question='Em 2 Crônicas 7:14, toque a palavra que falta em "e ___ a sua terra"?',
            ok='Exato: Jeová "curarei" a terra do povo.',
            wrong={
                "a": "Ouvirei é a primeira ação de Jeová, não esta lacuna final.",
                "c": "Buscar é ação do povo, não o verbo desta promessa.",
            },
            options=opts(("a", "ouvirei"), ("b", "curarei"), ("c", "buscar")),
            correct="b",
            template="e ___ a sua terra.",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="choice",
            nn="03",
            question="O que 2 Crônicas 7:14 ensina sobre o sentido do templo para o povo do nome?",
            ok="Certo: o nome invocado convoca humilhação; Jeová ouve e sara.",
            wrong={
                "a": "O texto não trata o templo como amuleto automático.",
                "c": "Não ensina que o céu está fechado à humilhação.",
                "d": "Não reduz a cura da terra a obra humana sem Jeová.",
            },
            options=opts(
                ("a", "O templo garante bênção automática, sem humilhação."),
                ("b", "O nome invocado convoca humilhar-se; Jeová ouve e sara."),
                ("c", "O céu permanece fechado mesmo à face buscada."),
                ("d", "A terra sara só por esforço, sem Jeová ouvir."),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="order",
            nn="04",
            question="Qual sequência revela o sentido de 2 Crônicas 7:14?",
            ok="Certo: o sentido vai do povo do nome à conversão e à resposta do céu.",
            wrong={
                "a": "Começar pela cura esconde a condição do povo.",
                "c": "O desvio dos caminhos não é o primeiro movimento.",
            },
            options=opts(
                ("a", "eu ouvirei do céu, e perdoarei os seus pecados, e curarei a sua terra"),
                ("b", "se o meu povo, sobre quem foi invocado o meu nome, se humilhar e orar"),
                ("c", "buscar a minha face e se desviar dos seus maus caminhos"),
            ),
            correct="b",
            correctOrder=["b", "c", "a"],
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="complete",
            nn="05",
            question='Complete a frase: "se o meu povo, sobre quem foi invocado o meu ___."',
            ok='Certo: o povo é aquele sobre quem foi invocado o "nome".',
            wrong={
                "a": "Céu é de onde Jeová ouve, não o que foi invocado sobre o povo.",
                "c": "Face é o que se busca, não esta identificação inicial.",
            },
            options=opts(("a", "céu"), ("b", "nome"), ("c", "face")),
            correct="b",
            template="se o meu povo, sobre quem foi invocado o meu ___,",
        ),
        dict(
            diff="profundezas",
            skill="interpret",
            type="connect",
            nn="06",
            question="O que 2 Crônicas 7:14 comunica que se liga a este contexto?",
            ok="Certo: Jeová sara a terra quando o povo do nome se volta.",
            wrong={
                "a": "O texto não ensina templo que vive sem conversão.",
                "b": "Não apresenta a cura como prêmio ao orgulho.",
            },
            options=opts(
                ("a", "Templo vivo sem conversão"),
                ("b", "Cura como prêmio ao orgulho"),
                ("c", "Jeová que ouve e sara"),
            ),
            correct="c",
            passageA={
                "ref": "2 Crônicas 7:14",
                "text": "eu ouvirei do céu, e perdoarei os seus pecados, e curarei a sua terra",
            },
            passageB={
                "ref": "Contexto",
                "text": "O templo vive da humilhação do povo: orar, buscar a face, desviar-se — Jeová ouve e sara.",
            },
        ),
    ],
)

# Extra checks
assert len(bank) == 90, len(bank)
for item in bank:
    if item["type"] == "choice":
        for o in item["options"]:
            assert len(o["text"]) <= 90, (item["id"], len(o["text"]), o["text"])
    if item["type"] == "tap":
        p = item["passageText"].lower()
        for o in item["options"]:
            assert o["text"].lower() in p, (item["id"], o["text"])
    if item["type"] in ("tap", "complete"):
        assert "___" in item.get("template", ""), item["id"]

# same-mode tap vs complete gaps
from collections import defaultdict

gaps = defaultdict(dict)
for item in bank:
    if item["type"] in ("tap", "complete"):
        key = (item["section"], item["difficulty"])
        gaps[key][item["type"]] = item["template"]
for key, d in gaps.items():
    assert d["tap"] != d["complete"], key

OUT.write_text(json.dumps(bank, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {OUT} ({len(bank)} questions)")
