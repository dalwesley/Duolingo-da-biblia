#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Gera perguntas-v2/romanos.json — 6 missões × 18 = 108."""
import json

TF = [{"id": "true", "text": "Verdadeiro"}, {"id": "false", "text": "Falso"}]
SK = {"semente": "observe", "caminhada": "understand", "profundezas": "interpret"}
SHORT = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}


def q(**kw):
    t = kw["question"]
    kw["prompt"] = t
    kw["cue"] = t
    return kw


def opt(*pairs):
    return [{"id": i, "text": t} for i, t in pairs]


def base(diff, typ, nn, section, verse, lo, ev, passage):
    return {
        "difficulty": diff,
        "skill": SK[diff],
        "verseRef": verse,
        "learningObjective": lo,
        "evidence": ev,
        "type": typ,
        "trail": "romanos",
        "section": section,
        "id": f"romanos-{SHORT[diff]}-{section}-{nn}",
        "passageText": passage,
    }


def merge(b, extra):
    d = dict(b)
    d.update(extra)
    return q(**d)


# ── Passagens TB ────────────────────────────────────────────────────
P1 = "porque todos pecaram e necessitam da glória de Deus,"
P2 = (
    "Justificados, pois, pela fé, tenhamos paz com Deus "
    "por meio de nosso Senhor Jesus Cristo;"
)
P3 = (
    "Agora, pois, nada de condenação há para os que estão em Cristo Jesus. "
    "Pois a lei do Espírito da vida te livrou, em Cristo Jesus, "
    "da lei do pecado e da morte."
)
P4 = (
    "Ó profundidade das riquezas, da sabedoria e da ciência de Deus! "
    "Quão inescrutáveis são os seus juízos, e quão impenetráveis os seus caminhos!"
)
P5 = (
    "Rogo-vos, pois, irmãos, pela compaixão de Deus, que apresenteis os vossos corpos "
    "como um sacrifício vivo, santo e agradável a Deus, que é o vosso culto racional; "
    "e não vos conformeis com este mundo, mas transformai-vos pela renovação da vossa mente, "
    "para que proveis qual é a boa, agradável e perfeita vontade de Deus."
)
P6 = (
    "Pois não me envergonho do evangelho, porque ele é poder de Deus "
    "para a salvação de todo aquele que crê, primeiro do judeu e depois do grego."
)

I1 = "Todos pecaram e necessitam da glória — ninguém fica de fora."
I2 = "Justificados pela fé: paz com Deus por Jesus."
I3 = "Nenhuma condenação em Cristo; o Espírito livra da lei do pecado e da morte."
I4 = "Os caminhos de Deus são profundos demais para o orgulho gentio."
I5 = "Culto racional: corpo em sacrifício vivo; mente renovada."
I6 = "Evangelho: poder de Deus para judeu e grego."

LO1 = "Sair sabendo que todos pecaram e todos necessitam da glória de Deus — ninguém fica de fora."
LO2 = "Sair sabendo que justificados pela fé temos paz com Deus por meio de Jesus Cristo."
LO3 = "Sair sabendo que em Cristo Jesus não há condenação e que o Espírito livra da lei do pecado e da morte."
LO4 = "Sair sabendo que juízos e caminhos de Deus são inescrutáveis — profundidade que humilha o orgulho."
LO5 = "Sair sabendo que o culto racional é oferecer o corpo como sacrifício vivo e renovar a mente."
LO6 = "Sair sabendo que o evangelho é poder de Deus para a salvação de todo o que crê, judeu e grego."

Qs = []

# ═══════════════════════════════════════════════════════════════════
# M1 rm-01-pecado | Romanos 3:23
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, ins = (
    "rm-01-pecado",
    "Romanos 3:23",
    LO1,
    ["Romanos 3:23"],
    P1,
    I1,
)

Qs += [
    # SEMENTE
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Todos pecaram e necessitam da glória de Deus.",
        "feedbackCorrect": "Certo: o texto afirma pecaram e necessitam — sem exceção.",
        "feedbackWrong": {"false": "Releia 3:23: todos pecaram e necessitam da glória."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 3:23, toque a palavra que falta em "porque ___ pecaram e necessitam da glória de Deus,"?',
        "feedbackCorrect": "Exato: o sujeito universal é \"todos\".",
        "feedbackWrong": {
            "b": "\"pecaram\" é o verbo; a lacuna pede quem pecou.",
            "c": "\"glória\" fecha o versículo, não esta lacuna.",
        },
        "template": "porque ___ pecaram e necessitam da glória de Deus,",
        "options": opt(("a", "todos"), ("b", "pecaram"), ("c", "glória")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Segundo Romanos 3:23, o que o texto afirma de todos?",
        "feedbackCorrect": "Certo: pecaram e necessitam da glória de Deus.",
        "feedbackWrong": {
            "b": "O verso não restringe o pecado a gentios.",
            "c": "Não há menção a mérito próprio aqui.",
            "d": "O texto diz necessitam, não que já possuem a glória.",
        },
        "options": opt(
            ("a", "Todos pecaram e necessitam da glória de Deus."),
            ("b", "Só os gentios pecaram e ficaram sem glória."),
            ("c", "Alguns alcançaram a glória por esforço próprio."),
            ("d", "Todos já possuem a glória sem precisar de nada."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Romanos 3:23?",
        "feedbackCorrect": "Certo: pecaram → necessitam → da glória de Deus.",
        "feedbackWrong": {
            "b": "A necessidade vem depois do pecado, não antes.",
            "c": "\"glória de Deus\" fecha; não abre o verso.",
        },
        "options": opt(
            ("a", "todos pecaram"),
            ("b", "necessitam da glória"),
            ("c", "de Deus"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "porque todos pecaram e ___ da glória de Deus,"',
        "feedbackCorrect": "Exato: todos necessitam da glória de Deus.",
        "feedbackWrong": {
            "b": "\"pecaram\" já está antes da lacuna.",
            "c": "\"todos\" é o sujeito, não o verbo desta lacuna.",
        },
        "template": "porque todos pecaram e ___ da glória de Deus,",
        "options": opt(("a", "necessitam"), ("b", "pecaram"), ("c", "todos")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 3:23 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: ninguém fica de fora da necessidade da glória.",
        "feedbackWrong": {
            "b": "O verso não isenta ninguém do pecado.",
            "c": "Não fala de mérito parcial; fala de todos.",
        },
        "passageA": {"ref": "Romanos 3:23", "text": "porque todos pecaram e necessitam da glória de Deus,"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Ninguém fica de fora"),
            ("b", "Só alguns pecaram"),
            ("c", "Mérito parcial basta"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # CAMINHADA
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Romanos 3:23 deixa espaço para uma elite que não pecou e já possui a glória de Deus.",
        "feedbackCorrect": "Certo: \"todos\" fecha a porta a qualquer exceção.",
        "feedbackWrong": {"true": "O texto diz todos pecaram e necessitam — sem elite."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 3:23, toque a palavra que falta em "necessitam da ___ de Deus,"?',
        "feedbackCorrect": "Exato: necessitam da glória de Deus.",
        "feedbackWrong": {
            "b": "\"todos\" é o sujeito; a lacuna pede o objeto.",
            "c": "\"pecaram\" é o verbo anterior, não esta lacuna.",
        },
        "template": "necessitam da ___ de Deus,",
        "options": opt(("a", "glória"), ("b", "todos"), ("c", "pecaram")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que \"necessitam da glória de Deus\" implica em relação a todos?",
        "feedbackCorrect": "Certo: há carência universal — ninguém se basta.",
        "feedbackWrong": {
            "b": "Não é desejo opcional; é necessidade afirmada.",
            "c": "O verso não aponta só um povo; diz todos.",
            "d": "Não há mérito residual; a necessidade é plena.",
        },
        "options": opt(
            ("a", "Há carência universal: ninguém se basta perante Deus."),
            ("b", "É só um desejo opcional de quem busca religião."),
            ("c", "Aplica-se só a um povo, não à humanidade."),
            ("d", "Quem já tem mérito próprio não precisa da glória."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Romanos 3:23?",
        "feedbackCorrect": "Certo: universalidade → pecado → necessidade da glória.",
        "feedbackWrong": {
            "b": "A glória não antecede o diagnóstico do pecado.",
            "c": "\"necessitam\" não é o primeiro elo do verso.",
        },
        "options": opt(
            ("a", "o alcance universal: todos"),
            ("b", "o diagnóstico: pecaram"),
            ("c", "a consequência: necessitam da glória de Deus"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "porque todos ___ e necessitam da glória de Deus,"',
        "feedbackCorrect": "Exato: o diagnóstico é \"pecaram\".",
        "feedbackWrong": {
            "b": "\"necessitam\" vem depois do \"e\".",
            "c": "\"glória\" é o objeto da necessidade, não o verbo.",
        },
        "template": "porque todos ___ e necessitam da glória de Deus,",
        "options": opt(("a", "pecaram"), ("b", "necessitam"), ("c", "glória")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 3:23 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a ponte é a necessidade comum da glória.",
        "feedbackWrong": {
            "b": "O verso não cria classes espirituais.",
            "c": "Não sugere autojustificação; aponta carência.",
        },
        "passageA": {"ref": "Romanos 3:23", "text": "todos pecaram e necessitam da glória de Deus"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Necessidade comum da glória"),
            ("b", "Classes espirituais distintas"),
            ("c", "Autojustificação possível"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # PROFUNDEZAS
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Romanos 3:23 prepara o leitor para ver a justificação pela graça: sem exceção, todos carecem da glória de Deus.",
        "feedbackCorrect": "Certo: o \"todos\" nivela o terreno para a graça.",
        "feedbackWrong": {"false": "O verso nivela todos na necessidade — base da graça."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 3:23, toque a palavra que falta em "necessitam da glória de ___,"?',
        "feedbackCorrect": "Exato: a glória é de Deus, não humana.",
        "feedbackWrong": {
            "b": "\"todos\" é o sujeito; a lacuna pede de quem é a glória.",
            "c": "\"pecaram\" descreve o ato, não o dono da glória.",
        },
        "template": "necessitam da glória de ___,",
        "options": opt(("a", "Deus"), ("b", "todos"), ("c", "pecaram")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura teológica Romanos 3:23 sustenta?",
        "feedbackCorrect": "Certo: universalidade do pecado e carência da glória.",
        "feedbackWrong": {
            "b": "O verso não afirma inocência natural.",
            "c": "Não restringe o problema a um grupo étnico.",
            "d": "Não trata a glória como conquista humana.",
        },
        "options": opt(
            ("a", "Pecado e carência da glória alcançam a todos."),
            ("b", "O ser humano nasce já pleno da glória de Deus."),
            ("c", "Só um povo específico pecou e ficou sem glória."),
            ("d", "A glória de Deus se conquista por esforço moral."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Romanos 3:23?",
        "feedbackCorrect": "Certo: diagnóstico → carência → glória de Deus.",
        "feedbackWrong": {
            "b": "A glória não é o primeiro passo do argumento.",
            "c": "A carência segue o pecado, não o precede no verso.",
        },
        "options": opt(
            ("a", "diagnóstico universal do pecado"),
            ("b", "carência declarada: necessitam"),
            ("c", "referência: a glória de Deus"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "porque ___ pecaram e necessitam da glória de Deus,"',
        "feedbackCorrect": "Exato: \"todos\" carrega o peso teológico do verso.",
        "feedbackWrong": {
            "b": "\"glória\" é o objeto da necessidade.",
            "c": "\"necessitam\" é o segundo verbo, não o sujeito.",
        },
        "template": "porque ___ pecaram e necessitam da glória de Deus,",
        "options": opt(("a", "todos"), ("b", "glória"), ("c", "necessitam")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 3:23 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o nivelamento universal aponta para a graça.",
        "feedbackWrong": {
            "b": "Não sugere superioridade moral de ninguém.",
            "c": "Não abre exceção para \"quase justos\".",
        },
        "passageA": {"ref": "Romanos 3:23", "text": "todos pecaram e necessitam da glória de Deus"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Nivelamento para a graça"),
            ("b", "Superioridade de alguns"),
            ("c", "Exceção aos quase justos"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M2 rm-02-justificacao | Romanos 5:1
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, ins = (
    "rm-02-justificacao",
    "Romanos 5:1",
    LO2,
    ["Romanos 5:1"],
    P2,
    I2,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Justificados pela fé, tenhamos paz com Deus por meio de nosso Senhor Jesus Cristo.",
        "feedbackCorrect": "Certo: justificação pela fé e paz por Jesus.",
        "feedbackWrong": {"false": "Releia 5:1: justificados pela fé, paz por Jesus."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 5:1, toque a palavra que falta em "Justificados, pois, pela ___, tenhamos paz com Deus"?',
        "feedbackCorrect": "Exato: a justificação é pela fé.",
        "feedbackWrong": {
            "b": "\"paz\" é o resultado, não o meio da justificação.",
            "c": "\"Senhor\" aparece no fim, não nesta lacuna.",
        },
        "template": "Justificados, pois, pela ___, tenhamos paz com Deus",
        "options": opt(("a", "fé"), ("b", "paz"), ("c", "Senhor")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Segundo Romanos 5:1, como temos paz com Deus?",
        "feedbackCorrect": "Certo: justificados pela fé, por meio de Jesus Cristo.",
        "feedbackWrong": {
            "b": "O texto aponta fé e Jesus, não obras da lei.",
            "c": "Não menciona ritual como meio da paz.",
            "d": "A paz é com Deus por Jesus, não por esforço próprio.",
        },
        "options": opt(
            ("a", "Justificados pela fé, por meio de Jesus Cristo."),
            ("b", "Cumprindo todas as obras da lei sem falha."),
            ("c", "Oferecendo sacrifícios no templo de Jerusalém."),
            ("d", "Conquistando a paz por mérito pessoal."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Romanos 5:1?",
        "feedbackCorrect": "Certo: justificados → paz com Deus → por Jesus.",
        "feedbackWrong": {
            "b": "A paz segue a justificação, não a precede.",
            "c": "Jesus é o meio; não abre o verso sozinho.",
        },
        "options": opt(
            ("a", "Justificados, pois, pela fé"),
            ("b", "tenhamos paz com Deus"),
            ("c", "por meio de nosso Senhor Jesus Cristo"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Justificados, pois, pela fé, tenhamos ___ com Deus por meio de nosso Senhor Jesus Cristo;"',
        "feedbackCorrect": "Exato: o fruto é paz com Deus.",
        "feedbackWrong": {
            "b": "\"fé\" é o meio da justificação, não o fruto.",
            "c": "\"Justificados\" abre o verso; a lacuna pede o fruto.",
        },
        "template": "Justificados, pois, pela fé, tenhamos ___ com Deus por meio de nosso Senhor Jesus Cristo;",
        "options": opt(("a", "paz"), ("b", "fé"), ("c", "Justificados")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 5:1 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: fé justifica e Jesus traz paz com Deus.",
        "feedbackWrong": {
            "b": "O verso não liga paz a obras da lei.",
            "c": "Não aponta mérito humano como meio.",
        },
        "passageA": {"ref": "Romanos 5:1", "text": "Justificados, pois, pela fé, tenhamos paz com Deus por meio de nosso Senhor Jesus Cristo;"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Paz pela fé em Jesus"),
            ("b", "Paz pelas obras da lei"),
            ("c", "Paz por mérito humano"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # CAMINHADA
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Romanos 5:1, a paz com Deus vem primeiro pelas obras, e a fé só confirma o que já se mereceu.",
        "feedbackCorrect": "Certo: o texto diz justificados pela fé, não pelas obras.",
        "feedbackWrong": {"true": "A ordem é fé → justificação → paz por Jesus."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 5:1, toque a palavra que falta em "tenhamos paz com ___ por meio de nosso Senhor Jesus Cristo"?',
        "feedbackCorrect": "Exato: a paz é com Deus.",
        "feedbackWrong": {
            "b": "\"fé\" é o meio da justificação, não o parceiro da paz.",
            "c": "\"Jesus\" é o meio; a lacuna pede com quem é a paz.",
        },
        "template": "tenhamos paz com ___ por meio de nosso Senhor Jesus Cristo",
        "options": opt(("a", "Deus"), ("b", "fé"), ("c", "Jesus")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual relação Romanos 5:1 estabelece entre fé, justificação e paz?",
        "feedbackCorrect": "Certo: a fé justifica; Jesus é o meio da paz.",
        "feedbackWrong": {
            "b": "A paz não antecede a justificação no verso.",
            "c": "Não é sentimento solto; é paz com Deus por Jesus.",
            "d": "O meio não é a lei; é nosso Senhor Jesus Cristo.",
        },
        "options": opt(
            ("a", "A fé justifica; por Jesus temos paz com Deus."),
            ("b", "A paz vem antes; a fé só a reconhece depois."),
            ("c", "É só emoção interior, sem relação com Deus."),
            ("d", "A lei é o meio; Jesus só ilustra o princípio."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Romanos 5:1?",
        "feedbackCorrect": "Certo: justificação pela fé → paz → meio em Cristo.",
        "feedbackWrong": {
            "b": "Cristo como meio não abre o encadeamento sozinho.",
            "c": "A paz é fruto, não o primeiro elo.",
        },
        "options": opt(
            ("a", "status: justificados pela fé"),
            ("b", "fruto: paz com Deus"),
            ("c", "meio: nosso Senhor Jesus Cristo"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "tenhamos paz com Deus por meio de nosso Senhor ___ Cristo;"',
        "feedbackCorrect": "Exato: o Senhor é Jesus Cristo.",
        "feedbackWrong": {
            "b": "\"fé\" é o meio da justificação, não o nome aqui.",
            "c": "\"paz\" é o fruto; a lacuna pede o nome.",
        },
        "template": "tenhamos paz com Deus por meio de nosso Senhor ___ Cristo;",
        "options": opt(("a", "Jesus"), ("b", "fé"), ("c", "paz")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 5:1 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: justificação pela fé produz paz por Jesus.",
        "feedbackWrong": {
            "b": "Não é trégua temporária; é paz com Deus.",
            "c": "Não depende de mérito acumulado.",
        },
        "passageA": {"ref": "Romanos 5:1", "text": "Justificados, pois, pela fé, tenhamos paz com Deus"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Justificação gera paz"),
            ("b", "Trégua só temporária"),
            ("c", "Mérito acumula a paz"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # PROFUNDEZAS
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Romanos 5:1 ensina que a paz com Deus é conquista gradual do crente até merecer a justificação.",
        "feedbackCorrect": "Certo: justificados pela fé — a paz segue, não precede o mérito.",
        "feedbackWrong": {"true": "A paz flui da justificação pela fé, não de conquista."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 5:1, toque a palavra que falta em "Justificados, pois, pela fé, tenhamos paz com Deus por ___ de nosso Senhor Jesus Cristo"?',
        "feedbackCorrect": "Exato: a paz vem \"por meio\" de Jesus.",
        "feedbackWrong": {
            "b": "\"fé\" já aparece antes; a lacuna pede o meio.",
            "c": "\"paz\" é o fruto, não a preposição pedida.",
        },
        "template": "Justificados, pois, pela fé, tenhamos paz com Deus por ___ de nosso Senhor Jesus Cristo",
        "options": opt(("a", "meio"), ("b", "fé"), ("c", "paz")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual implicação teológica Romanos 5:1 sustenta?",
        "feedbackCorrect": "Certo: relação restaurada com Deus por Cristo, pela fé.",
        "feedbackWrong": {
            "b": "Não é paz psicológica sem Deus.",
            "c": "Não deixa Jesus de fora do meio.",
            "d": "Não exige obras como condição da paz.",
        },
        "options": opt(
            ("a", "Relação com Deus restaurada por Cristo, pela fé."),
            ("b", "Só alívio emocional, sem paz com Deus."),
            ("c", "Paz possível à parte de Jesus Cristo."),
            ("d", "Paz condicionada a um histórico de obras."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Romanos 5:1?",
        "feedbackCorrect": "Certo: meio (fé) → status → fruto (paz em Cristo).",
        "feedbackWrong": {
            "b": "O fruto não vem antes do status justificado.",
            "c": "Cristo como meio fecha, não abre sozinho.",
        },
        "options": opt(
            ("a", "meio declarado: pela fé"),
            ("b", "status: justificados"),
            ("c", "fruto: paz com Deus por Jesus Cristo"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "___, pois, pela fé, tenhamos paz com Deus por meio de nosso Senhor Jesus Cristo;"',
        "feedbackCorrect": "Exato: o status é \"Justificados\".",
        "feedbackWrong": {
            "b": "\"paz\" é o fruto, não o status inicial.",
            "c": "\"Senhor\" aparece no meio, não nesta abertura.",
        },
        "template": "___, pois, pela fé, tenhamos paz com Deus por meio de nosso Senhor Jesus Cristo;",
        "options": opt(("a", "Justificados"), ("b", "paz"), ("c", "Senhor")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 5:1 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a ponte é paz com Deus mediante Cristo.",
        "feedbackWrong": {
            "b": "Não é justificação por desempenho.",
            "c": "Não reduz a paz a sentimento sem Deus.",
        },
        "passageA": {"ref": "Romanos 5:1", "text": "paz com Deus por meio de nosso Senhor Jesus Cristo"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Paz mediante Cristo"),
            ("b", "Justificação por desempenho"),
            ("c", "Paz só como sentimento"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M3 rm-03-vida-espirito | Romanos 8:1–2
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, ins = (
    "rm-03-vida-espirito",
    "Romanos 8:1–2",
    LO3,
    ["Romanos 8:1", "Romanos 8:2"],
    P3,
    I3,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Nada de condenação há para os que estão em Cristo Jesus.",
        "feedbackCorrect": "Certo: 8:1 afirma nenhuma condenação em Cristo.",
        "feedbackWrong": {"false": "Releia 8:1: nada de condenação em Cristo Jesus."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 8:1–2, toque a palavra que falta em "nada de ___ há para os que estão em Cristo Jesus"?',
        "feedbackCorrect": "Exato: nada de condenação para os que estão em Cristo.",
        "feedbackWrong": {
            "b": "\"Espírito\" aparece no v. 2, não nesta lacuna.",
            "c": "\"pecado\" liga-se à lei do pecado, não a esta frase.",
        },
        "template": "nada de ___ há para os que estão em Cristo Jesus",
        "options": opt(("a", "condenação"), ("b", "Espírito"), ("c", "pecado")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Segundo Romanos 8:1–2, o que livrou da lei do pecado e da morte?",
        "feedbackCorrect": "Certo: a lei do Espírito da vida, em Cristo Jesus.",
        "feedbackWrong": {
            "b": "Não é a lei do pecado que livra; ela é o problema.",
            "c": "O texto aponta o Espírito, não esforço moral.",
            "d": "A condenação é removida em Cristo, não reforçada.",
        },
        "options": opt(
            ("a", "A lei do Espírito da vida, em Cristo Jesus."),
            ("b", "A própria lei do pecado e da morte."),
            ("c", "O esforço moral sem Cristo."),
            ("d", "Uma nova condenação mais rigorosa."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Romanos 8:1–2?",
        "feedbackCorrect": "Certo: sem condenação → lei do Espírito → livramento.",
        "feedbackWrong": {
            "b": "O livramento explica o \"nada de condenação\".",
            "c": "A lei do pecado é o que se deixa, não o primeiro passo.",
        },
        "options": opt(
            ("a", "nada de condenação há para os que estão em Cristo Jesus"),
            ("b", "a lei do Espírito da vida te livrou, em Cristo Jesus"),
            ("c", "da lei do pecado e da morte"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Pois a lei do ___ da vida te livrou, em Cristo Jesus, da lei do pecado e da morte."',
        "feedbackCorrect": "Exato: é a lei do Espírito da vida.",
        "feedbackWrong": {
            "b": "\"pecado\" é da lei da qual se é livrado.",
            "c": "\"morte\" fecha o contraste, não esta lacuna.",
        },
        "template": "Pois a lei do ___ da vida te livrou, em Cristo Jesus, da lei do pecado e da morte.",
        "options": opt(("a", "Espírito"), ("b", "pecado"), ("c", "morte")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 8:1–2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: em Cristo não há condenação; o Espírito livra.",
        "feedbackWrong": {
            "b": "O texto nega condenação para os que estão em Cristo.",
            "c": "Não deixa o crente sob a lei do pecado.",
        },
        "passageA": {"ref": "Romanos 8:1–2", "text": "nada de condenação há para os que estão em Cristo Jesus"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Nenhuma condenação em Cristo"),
            ("b", "Condenação permanente"),
            ("c", "Ainda sob a lei do pecado"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # CAMINHADA
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Romanos 8:1–2 aplica a ausência de condenação a qualquer pessoa, esteja ou não em Cristo Jesus.",
        "feedbackCorrect": "Certo: a promessa é para os que estão em Cristo Jesus.",
        "feedbackWrong": {"true": "O texto limita: \"para os que estão em Cristo Jesus\"."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 8:1–2, toque a palavra que falta em "a lei do Espírito da vida te ___, em Cristo Jesus"?',
        "feedbackCorrect": "Exato: o Espírito te livrou.",
        "feedbackWrong": {
            "b": "\"condenação\" é o que não há; a lacuna pede o verbo.",
            "c": "\"morte\" é o destino da lei antiga, não o verbo.",
        },
        "template": "a lei do Espírito da vida te ___, em Cristo Jesus",
        "options": opt(("a", "livrou"), ("b", "condenação"), ("c", "morte")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Romanos 8:1–2 relaciona condenação e o Espírito?",
        "feedbackCorrect": "Certo: em Cristo não há condenação; o Espírito livra.",
        "feedbackWrong": {
            "b": "O Espírito não reforça a condenação.",
            "c": "A lei do pecado não é o agente do livramento.",
            "d": "Não se trata de ignorar o pecado; há livramento real.",
        },
        "options": opt(
            ("a", "Em Cristo: sem condenação; o Espírito livra da lei do pecado."),
            ("b", "O Espírito aumenta a condenação para educar."),
            ("c", "A lei do pecado é quem livra o crente."),
            ("d", "Condenação some porque o pecado deixa de importar."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Romanos 8:1–2?",
        "feedbackCorrect": "Certo: em Cristo → sem condenação → livramento pelo Espírito.",
        "feedbackWrong": {
            "b": "O livramento explica a ausência de condenação.",
            "c": "A lei do pecado não é o primeiro elo positivo.",
        },
        "options": opt(
            ("a", "estar em Cristo Jesus"),
            ("b", "nada de condenação"),
            ("c", "livramento pela lei do Espírito da vida"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "da lei do ___ e da morte."',
        "feedbackCorrect": "Exato: livrou da lei do pecado e da morte.",
        "feedbackWrong": {
            "b": "\"Espírito\" é da lei que livra, não da que aprisiona.",
            "c": "\"vida\" qualifica o Espírito, não esta lei.",
        },
        "template": "da lei do ___ e da morte.",
        "options": opt(("a", "pecado"), ("b", "Espírito"), ("c", "vida")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 8:1–2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Espírito liberta da lei do pecado e da morte.",
        "feedbackWrong": {
            "b": "Não há condenação residual para os que estão em Cristo.",
            "c": "Não é libertação pela lei do pecado.",
        },
        "passageA": {"ref": "Romanos 8:2", "text": "a lei do Espírito da vida te livrou, em Cristo Jesus, da lei do pecado e da morte"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Espírito livra da morte"),
            ("b", "Condenação ainda vale"),
            ("c", "Lei do pecado liberta"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # PROFUNDEZAS
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Romanos 8:1–2 anuncia que, em Cristo, o crente passa da esfera da condenação para a esfera do Espírito que dá vida.",
        "feedbackCorrect": "Certo: mudança de esfera — condenação fora; Espírito livra.",
        "feedbackWrong": {"false": "O texto opõe condenação e lei do Espírito da vida."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 8:1–2, toque a palavra que falta em "para os que estão em Cristo ___"?',
        "feedbackCorrect": "Exato: em Cristo Jesus.",
        "feedbackWrong": {
            "b": "\"Espírito\" aparece no v. 2; a lacuna pede Jesus.",
            "c": "\"condenação\" é o que não há, não o nome.",
        },
        "template": "para os que estão em Cristo ___",
        "options": opt(("a", "Jesus"), ("b", "Espírito"), ("c", "condenação")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual sentido teológico Romanos 8:1–2 sustenta?",
        "feedbackCorrect": "Certo: união a Cristo e ação do Espírito vencem condenação.",
        "feedbackWrong": {
            "b": "Não é anulação do pecado por indiferença divina.",
            "c": "Não deixa o crente sob a lei da morte.",
            "d": "Não é autolibertação sem Cristo e Espírito.",
        },
        "options": opt(
            ("a", "Em Cristo, o Espírito liberta da condenação e da morte."),
            ("b", "Deus ignora o pecado e por isso não condena."),
            ("c", "O crente permanece sob a lei do pecado e da morte."),
            ("d", "Cada um se livra sozinho, sem Cristo."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Romanos 8:1–2?",
        "feedbackCorrect": "Certo: união a Cristo → fim da condenação → vida do Espírito.",
        "feedbackWrong": {
            "b": "A vida do Espírito explica, não antecede a união.",
            "c": "A condenação não é o primeiro passo positivo.",
        },
        "options": opt(
            ("a", "união: em Cristo Jesus"),
            ("b", "resultado: nada de condenação"),
            ("c", "agente: lei do Espírito da vida que livra"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Agora, pois, nada de condenação há para os que estão em ___ Jesus."',
        "feedbackCorrect": "Exato: a esfera é \"em Cristo Jesus\".",
        "feedbackWrong": {
            "b": "\"Espírito\" atua no livramento do v. 2.",
            "c": "\"pecado\" nomeia a lei da qual se é livrado.",
        },
        "template": "Agora, pois, nada de condenação há para os que estão em ___ Jesus.",
        "options": opt(("a", "Cristo"), ("b", "Espírito"), ("c", "pecado")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 8:1–2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: mudança de domínio — do pecado/morte para o Espírito.",
        "feedbackWrong": {
            "b": "Não reforça condenação; a remove em Cristo.",
            "c": "Não mantém o crente sob a lei da morte.",
        },
        "passageA": {"ref": "Romanos 8:1–2", "text": "nada de condenação… a lei do Espírito da vida te livrou"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Mudança de domínio"),
            ("b", "Condenação reforçada"),
            ("c", "Permanência sob a morte"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M4 rm-04-israel | Romanos 11:33
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, ins = (
    "rm-04-israel",
    "Romanos 11:33",
    LO4,
    ["Romanos 11:33"],
    P4,
    I4,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Os juízos de Deus são inescrutáveis e os seus caminhos, impenetráveis.",
        "feedbackCorrect": "Certo: 11:33 celebra juízos inescrutáveis e caminhos impenetráveis.",
        "feedbackWrong": {"false": "Releia: inescrutáveis são os juízos; impenetráveis os caminhos."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 11:33, toque a palavra que falta em "Ó ___ das riquezas, da sabedoria e da ciência de Deus!"?',
        "feedbackCorrect": "Exato: o texto exclama \"profundidade\".",
        "feedbackWrong": {
            "b": "\"juízos\" vem depois; a lacuna pede profundidade.",
            "c": "\"caminhos\" fecha o verso, não esta abertura.",
        },
        "template": "Ó ___ das riquezas, da sabedoria e da ciência de Deus!",
        "options": opt(("a", "profundidade"), ("b", "juízos"), ("c", "caminhos")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Segundo Romanos 11:33, o que se diz dos juízos e caminhos de Deus?",
        "feedbackCorrect": "Certo: juízos inescrutáveis; caminhos impenetráveis.",
        "feedbackWrong": {
            "b": "O texto não diz que são fáceis de mapear.",
            "c": "Não afirma que são rasos ou óbvios.",
            "d": "Não reduz a sabedoria divina a cálculo humano.",
        },
        "options": opt(
            ("a", "Juízos inescrutáveis; caminhos impenetráveis."),
            ("b", "Juízos simples; caminhos fáceis de prever."),
            ("c", "Riquezas rasas e ciência limitada de Deus."),
            ("d", "Sabedoria divina igual à do orgulho gentio."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Romanos 11:33?",
        "feedbackCorrect": "Certo: profundidade → juízos → caminhos.",
        "feedbackWrong": {
            "b": "Os caminhos fecham; não abrem a exclamação.",
            "c": "Os juízos vêm depois da profundidade celebrada.",
        },
        "options": opt(
            ("a", "Ó profundidade das riquezas, da sabedoria e da ciência de Deus"),
            ("b", "Quão inescrutáveis são os seus juízos"),
            ("c", "quão impenetráveis os seus caminhos"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Quão ___ são os seus juízos, e quão impenetráveis os seus caminhos!"',
        "feedbackCorrect": "Exato: os juízos são inescrutáveis.",
        "feedbackWrong": {
            "b": "\"impenetráveis\" qualifica os caminhos.",
            "c": "\"riquezas\" abre a exclamação, não esta lacuna.",
        },
        "template": "Quão ___ são os seus juízos, e quão impenetráveis os seus caminhos!",
        "options": opt(("a", "inescrutáveis"), ("b", "impenetráveis"), ("c", "riquezas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 11:33 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a profundidade de Deus humilha o orgulho.",
        "feedbackWrong": {
            "b": "O verso não convida a mapear Deus com soberba.",
            "c": "Não trata os caminhos como rasos.",
        },
        "passageA": {"ref": "Romanos 11:33", "text": "Quão inescrutáveis são os seus juízos, e quão impenetráveis os seus caminhos!"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Profundidade humilha o orgulho"),
            ("b", "Deus é fácil de mapear"),
            ("c", "Caminhos rasos e óbvios"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # CAMINHADA
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Romanos 11:33 sugere que o gentio pode esgotar, com orgulho, a sabedoria e os juízos de Deus.",
        "feedbackCorrect": "Certo: inescrutáveis e impenetráveis — o orgulho não esgota Deus.",
        "feedbackWrong": {"true": "O verso celebra o que o orgulho não alcança."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 11:33, toque a palavra que falta em "quão ___ os seus caminhos!"?',
        "feedbackCorrect": "Exato: os caminhos são impenetráveis.",
        "feedbackWrong": {
            "b": "\"inescrutáveis\" qualifica os juízos.",
            "c": "\"sabedoria\" está na abertura, não nesta lacuna.",
        },
        "template": "quão ___ os seus caminhos!",
        "options": opt(("a", "impenetráveis"), ("b", "inescrutáveis"), ("c", "sabedoria")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que a exclamação de Romanos 11:33 implica sobre a postura humana?",
        "feedbackCorrect": "Certo: chama à humildade diante do que não se esgota.",
        "feedbackWrong": {
            "b": "Não autoriza arrogância intelectual.",
            "c": "Não reduz Deus a um sistema previsível.",
            "d": "Não celebra o orgulho gentio; o confronta.",
        },
        "options": opt(
            ("a", "Humildade: juízos e caminhos de Deus não se esgotam."),
            ("b", "Orgulho: o gentio já compreendeu tudo de Deus."),
            ("c", "Deus cabe num esquema humano previsível."),
            ("d", "A ciência humana supera a sabedoria divina."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Romanos 11:33?",
        "feedbackCorrect": "Certo: celebração → juízos → caminhos.",
        "feedbackWrong": {
            "b": "Os caminhos não abrem a doxologia.",
            "c": "Os juízos vêm após a profundidade celebrada.",
        },
        "options": opt(
            ("a", "celebração da profundidade de Deus"),
            ("b", "juízos declarados inescrutáveis"),
            ("c", "caminhos declarados impenetráveis"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Ó profundidade das ___, da sabedoria e da ciência de Deus!"',
        "feedbackCorrect": "Exato: profundidade das riquezas.",
        "feedbackWrong": {
            "b": "\"juízos\" vem na segunda frase.",
            "c": "\"caminhos\" fecha o verso.",
        },
        "template": "Ó profundidade das ___, da sabedoria e da ciência de Deus!",
        "options": opt(("a", "riquezas"), ("b", "juízos"), ("c", "caminhos")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 11:33 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: caminhos profundos demais para o orgulho.",
        "feedbackWrong": {
            "b": "Não há mapa completo para a soberba.",
            "c": "Não iguala gentio e Deus em sabedoria.",
        },
        "passageA": {"ref": "Romanos 11:33", "text": "Ó profundidade das riquezas, da sabedoria e da ciência de Deus!"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Caminhos além do orgulho"),
            ("b", "Mapa completo para a soberba"),
            ("c", "Gentio igual a Deus"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # PROFUNDEZAS
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Romanos 11:33 serve de doxologia que corta o orgulho gentio: a economia de Deus com Israel ultrapassa o cálculo humano.",
        "feedbackCorrect": "Certo: a profundidade doxológica humilha a soberba.",
        "feedbackWrong": {"false": "O verso encerra o argumento com humildade, não com orgulho."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 11:33, toque a palavra que falta em "da sabedoria e da ___ de Deus!"?',
        "feedbackCorrect": "Exato: sabedoria e ciência de Deus.",
        "feedbackWrong": {
            "b": "\"juízos\" vem depois; a lacuna pede ciência.",
            "c": "\"profundidade\" abre; não completa este par.",
        },
        "template": "da sabedoria e da ___ de Deus!",
        "options": opt(("a", "ciência"), ("b", "juízos"), ("c", "profundidade")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura teológica Romanos 11:33 sustenta no fluxo da carta?",
        "feedbackCorrect": "Certo: doxologia que humilha o orgulho diante do mistério.",
        "feedbackWrong": {
            "b": "Não autoriza desprezo a Israel por superioridade gentia.",
            "c": "Não achata os juízos de Deus a previsões humanas.",
            "d": "Não celebra autonomia do orgulho gentio.",
        },
        "options": opt(
            ("a", "Doxologia: o mistério de Deus humilha o orgulho."),
            ("b", "Licença para o gentio desprezar Israel."),
            ("c", "Prova de que os juízos de Deus são previsíveis."),
            ("d", "Celebração da autonomia e soberba gentia."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Romanos 11:33?",
        "feedbackCorrect": "Certo: riqueza divina → mistério dos juízos → caminhos fechados ao orgulho.",
        "feedbackWrong": {
            "b": "O orgulho não abre a doxologia.",
            "c": "Os juízos vêm após a celebração da profundidade.",
        },
        "options": opt(
            ("a", "celebração das riquezas, sabedoria e ciência"),
            ("b", "mistério: juízos inescrutáveis"),
            ("c", "limites: caminhos impenetráveis ao orgulho"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Quão inescrutáveis são os seus ___, e quão impenetráveis os seus caminhos!"',
        "feedbackCorrect": "Exato: inescrutáveis são os juízos.",
        "feedbackWrong": {
            "b": "\"caminhos\" já aparece no fim da frase.",
            "c": "\"riquezas\" está na primeira exclamação.",
        },
        "template": "Quão inescrutáveis são os seus ___, e quão impenetráveis os seus caminhos!",
        "options": opt(("a", "juízos"), ("b", "caminhos"), ("c", "riquezas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 11:33 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: mistério divino confronta orgulho gentio.",
        "feedbackWrong": {
            "b": "Não convida a domar Deus com soberba.",
            "c": "Não afirma transparência total dos caminhos.",
        },
        "passageA": {"ref": "Romanos 11:33", "text": "inescrutáveis são os seus juízos… impenetráveis os seus caminhos"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Mistério contra o orgulho"),
            ("b", "Orgulho doma a Deus"),
            ("c", "Caminhos totalmente claros"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M5 rm-05-culto | Romanos 12:1–2
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, ins = (
    "rm-05-culto",
    "Romanos 12:1–2",
    LO5,
    ["Romanos 12:1", "Romanos 12:2"],
    P5,
    I5,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Paulo roga que apresentemos os corpos como sacrifício vivo, santo e agradável a Deus — o culto racional.",
        "feedbackCorrect": "Certo: 12:1 define o culto racional como sacrifício vivo.",
        "feedbackWrong": {"false": "Releia 12:1: corpos como sacrifício vivo — culto racional."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 12:1–2, toque a palavra que falta em "que é o vosso culto ___"?',
        "feedbackCorrect": "Exato: o culto é racional.",
        "feedbackWrong": {
            "b": "\"vivo\" qualifica o sacrifício, não o culto aqui.",
            "c": "\"mundo\" aparece no v. 2, não nesta lacuna.",
        },
        "template": "que é o vosso culto ___",
        "options": opt(("a", "racional"), ("b", "vivo"), ("c", "mundo")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Segundo Romanos 12:1–2, o que Paulo pede em lugar de se conformar ao mundo?",
        "feedbackCorrect": "Certo: transformar-se pela renovação da mente.",
        "feedbackWrong": {
            "b": "O texto diz: não vos conformeis com este mundo.",
            "c": "Não pede abandono do corpo; pede oferecê-lo.",
            "d": "A renovação é da mente, não a rejeição dela.",
        },
        "options": opt(
            ("a", "Transformar-se pela renovação da mente."),
            ("b", "Conformar-se plenamente a este mundo."),
            ("c", "Abandonar o corpo como algo irrelevante."),
            ("d", "Rejeitar qualquer renovação da mente."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Romanos 12:1–2?",
        "feedbackCorrect": "Certo: oferecer corpos → não conformar → renovar a mente.",
        "feedbackWrong": {
            "b": "A renovação vem após o apelo ao corpo e à não conformidade.",
            "c": "Não conformar-se não é o primeiro rogo do trecho.",
        },
        "options": opt(
            ("a", "apresenteis os vossos corpos como um sacrifício vivo"),
            ("b", "não vos conformeis com este mundo"),
            ("c", "transformai-vos pela renovação da vossa mente"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "apresenteis os vossos corpos como um sacrifício ___, santo e agradável a Deus"',
        "feedbackCorrect": "Exato: sacrifício vivo.",
        "feedbackWrong": {
            "b": "\"racional\" qualifica o culto, não o adjetivo aqui.",
            "c": "\"mente\" aparece no v. 2.",
        },
        "template": "apresenteis os vossos corpos como um sacrifício ___, santo e agradável a Deus",
        "options": opt(("a", "vivo"), ("b", "racional"), ("c", "mente")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 12:1–2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: culto racional une corpo oferecido e mente renovada.",
        "feedbackWrong": {
            "b": "Não é só rito externo sem vida.",
            "c": "Não pede conformidade ao mundo.",
        },
        "passageA": {"ref": "Romanos 12:1–2", "text": "sacrifício vivo… culto racional… renovação da vossa mente"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Corpo e mente no culto"),
            ("b", "Só rito externo vazio"),
            ("c", "Conformidade ao mundo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # CAMINHADA
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Romanos 12:1–2, o culto racional exclui o corpo e se limita a ideias abstratas, sem transformação da mente.",
        "feedbackCorrect": "Certo: o culto envolve corpo (sacrifício vivo) e mente renovada.",
        "feedbackWrong": {"true": "Corpo e mente estão no centro do culto racional."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 12:1–2, toque a palavra que falta em "transformai-vos pela ___ da vossa mente"?',
        "feedbackCorrect": "Exato: pela renovação da mente.",
        "feedbackWrong": {
            "b": "\"mundo\" é o que não se deve seguir.",
            "c": "\"corpos\" liga-se ao v. 1, não a esta lacuna.",
        },
        "template": "transformai-vos pela ___ da vossa mente",
        "options": opt(("a", "renovação"), ("b", "mundo"), ("c", "corpos")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual relação Romanos 12:1–2 faz entre corpo, mente e vontade de Deus?",
        "feedbackCorrect": "Certo: oferecer o corpo e renovar a mente prova a vontade de Deus.",
        "feedbackWrong": {
            "b": "Não é conformidade ao mundo que revela a vontade.",
            "c": "O corpo não é descartado; é oferecido.",
            "d": "A mente não fica intocada; é renovada.",
        },
        "options": opt(
            ("a", "Corpo oferecido e mente renovada: prova-se a vontade de Deus."),
            ("b", "Conformidade ao mundo revela a vontade de Deus."),
            ("c", "O corpo deve ser ignorado; só a mente importa."),
            ("d", "A mente permanece igual; só o rito muda."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Romanos 12:1–2?",
        "feedbackCorrect": "Certo: rogo pela compaixão → culto do corpo → renovação e prova.",
        "feedbackWrong": {
            "b": "A prova da vontade vem após a renovação.",
            "c": "Não conformar-se não abre o trecho sozinho.",
        },
        "options": opt(
            ("a", "rogo pela compaixão de Deus"),
            ("b", "apresentar o corpo como sacrifício vivo"),
            ("c", "renovar a mente e provar a vontade de Deus"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "e não vos ___ com este mundo, mas transformai-vos pela renovação da vossa mente"',
        "feedbackCorrect": "Exato: não vos conformeis com este mundo.",
        "feedbackWrong": {
            "b": "\"transformai-vos\" é o contraste positivo.",
            "c": "\"proveis\" vem no fim, após a renovação.",
        },
        "template": "e não vos ___ com este mundo, mas transformai-vos pela renovação da vossa mente",
        "options": opt(("a", "conformeis"), ("b", "transformai-vos"), ("c", "proveis")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 12:1–2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: culto racional = sacrifício vivo + mente renovada.",
        "feedbackWrong": {
            "b": "Não é só conformidade cultural.",
            "c": "Não é culto sem corpo nem mente.",
        },
        "passageA": {"ref": "Romanos 12:1–2", "text": "culto racional… renovação da vossa mente"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Sacrifício e renovação"),
            ("b", "Só conformidade cultural"),
            ("c", "Culto sem corpo nem mente"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # PROFUNDEZAS
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Romanos 12:1–2 ensina que a misericórdia de Deus leva a um culto que envolve a vida toda — corpo e mente — e não só um rito pontual.",
        "feedbackCorrect": "Certo: o culto racional é existência oferecida e mente renovada.",
        "feedbackWrong": {"false": "O trecho une corpo, mente e vontade de Deus."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 12:1–2, toque a palavra que falta em "para que proveis qual é a boa, agradável e perfeita ___ de Deus"?',
        "feedbackCorrect": "Exato: a vontade de Deus.",
        "feedbackWrong": {
            "b": "\"mente\" é o que se renova; a lacuna pede vontade.",
            "c": "\"mundo\" é o padrão a rejeitar.",
        },
        "template": "para que proveis qual é a boa, agradável e perfeita ___ de Deus",
        "options": opt(("a", "vontade"), ("b", "mente"), ("c", "mundo")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual implicação teológica Romanos 12:1–2 sustenta?",
        "feedbackCorrect": "Certo: misericórdia gera culto existencial e discernimento da vontade.",
        "feedbackWrong": {
            "b": "Não reduz o culto a sentimento sem corpo.",
            "c": "Não sanciona moldar-se ao mundo.",
            "d": "Não separa ética da renovação da mente.",
        },
        "options": opt(
            ("a", "Misericórdia gera culto vivo e mente que prova a vontade."),
            ("b", "Culto é só emoção; o corpo não importa."),
            ("c", "A vontade de Deus se prova conformando-se ao mundo."),
            ("d", "Ética cristã dispensa renovação da mente."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Romanos 12:1–2?",
        "feedbackCorrect": "Certo: compaixão → oferta do corpo → mente renovada prova a vontade.",
        "feedbackWrong": {
            "b": "A vontade não se prova antes da renovação.",
            "c": "A oferta do corpo segue o rogo pela compaixão.",
        },
        "options": opt(
            ("a", "fundamento: compaixão de Deus"),
            ("b", "oferta: corpo como sacrifício vivo"),
            ("c", "resultado: mente renovada prova a vontade"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Rogo-vos, pois, irmãos, pela ___ de Deus, que apresenteis os vossos corpos"',
        "feedbackCorrect": "Exato: o rogo é pela compaixão de Deus.",
        "feedbackWrong": {
            "b": "\"renovação\" pertence ao v. 2.",
            "c": "\"vontade\" é o que se prova no fim.",
        },
        "template": "Rogo-vos, pois, irmãos, pela ___ de Deus, que apresenteis os vossos corpos",
        "options": opt(("a", "compaixão"), ("b", "renovação"), ("c", "vontade")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 12:1–2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: vida oferecida e mente renovada como culto.",
        "feedbackWrong": {
            "b": "Não é culto só teórico.",
            "c": "Não é moldar-se ao século.",
        },
        "passageA": {"ref": "Romanos 12:1–2", "text": "sacrifício vivo… culto racional… renovação da vossa mente"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Vida toda como culto"),
            ("b", "Culto só teórico"),
            ("c", "Moldar-se ao século"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M6 rm-06-desafio | Romanos 1:16
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, ins = (
    "rm-06-desafio",
    "Romanos 1:16",
    LO6,
    ["Romanos 1:16"],
    P6,
    I6,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Paulo não se envergonha do evangelho, porque ele é poder de Deus para a salvação de todo o que crê.",
        "feedbackCorrect": "Certo: evangelho = poder de Deus para quem crê.",
        "feedbackWrong": {"false": "Releia 1:16: não se envergonha; é poder para quem crê."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 1:16, toque a palavra que falta em "Pois não me ___ do evangelho"?',
        "feedbackCorrect": "Exato: não me envergonho do evangelho.",
        "feedbackWrong": {
            "b": "\"poder\" descreve o que o evangelho é.",
            "c": "\"salvação\" é o fim do poder, não esta lacuna.",
        },
        "template": "Pois não me ___ do evangelho",
        "options": opt(("a", "envergonho"), ("b", "poder"), ("c", "salvação")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Segundo Romanos 1:16, para quem o evangelho é poder de Deus para a salvação?",
        "feedbackCorrect": "Certo: para todo aquele que crê — judeu e grego.",
        "feedbackWrong": {
            "b": "O texto inclui o grego, não só o judeu.",
            "c": "Não restringe ao grego excluindo o judeu.",
            "d": "A condição é crer, não descrer.",
        },
        "options": opt(
            ("a", "Todo o que crê: primeiro o judeu, depois o grego."),
            ("b", "Somente o judeu, nunca o grego."),
            ("c", "Somente o grego, nunca o judeu."),
            ("d", "Todo o que se recusa a crer."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Romanos 1:16?",
        "feedbackCorrect": "Certo: sem vergonha → poder → judeu e grego.",
        "feedbackWrong": {
            "b": "Judeu e grego fecham o alcance, não abrem.",
            "c": "O poder explica por que não há vergonha.",
        },
        "options": opt(
            ("a", "não me envergonho do evangelho"),
            ("b", "ele é poder de Deus para a salvação de todo aquele que crê"),
            ("c", "primeiro do judeu e depois do grego"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "porque ele é ___ de Deus para a salvação de todo aquele que crê"',
        "feedbackCorrect": "Exato: o evangelho é poder de Deus.",
        "feedbackWrong": {
            "b": "\"vergonha\" é o que Paulo rejeita.",
            "c": "\"grego\" fecha o alcance, não esta lacuna.",
        },
        "template": "porque ele é ___ de Deus para a salvação de todo aquele que crê",
        "options": opt(("a", "poder"), ("b", "vergonha"), ("c", "grego")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 1:16 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: evangelho como poder para judeu e grego.",
        "feedbackWrong": {
            "b": "Paulo não se envergonha; afirma o poder.",
            "c": "Não restringe o evangelho a um só povo.",
        },
        "passageA": {"ref": "Romanos 1:16", "text": "ele é poder de Deus para a salvação de todo aquele que crê, primeiro do judeu e depois do grego"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Poder para judeu e grego"),
            ("b", "Vergonha do evangelho"),
            ("c", "Só um povo salvo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # CAMINHADA
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Romanos 1:16, o evangelho é poder de Deus só para o judeu; o grego fica de fora da salvação pela fé.",
        "feedbackCorrect": "Certo: o texto inclui judeu e grego — todo o que crê.",
        "feedbackWrong": {"true": "Primeiro o judeu e depois o grego — ambos no alcance."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 1:16, toque a palavra que falta em "para a ___ de todo aquele que crê"?',
        "feedbackCorrect": "Exato: poder para a salvação.",
        "feedbackWrong": {
            "b": "\"judeu\" aparece na ordem do alcance.",
            "c": "\"envergonho\" é o verbo que Paulo nega.",
        },
        "template": "para a ___ de todo aquele que crê",
        "options": opt(("a", "salvação"), ("b", "judeu"), ("c", "envergonho")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual relação Romanos 1:16 faz entre evangelho, poder e fé?",
        "feedbackCorrect": "Certo: o evangelho é poder de Deus para quem crê.",
        "feedbackWrong": {
            "b": "Paulo não se envergonha; afirma o poder.",
            "c": "A condição é crer, não merecer por obras.",
            "d": "O alcance não exclui o grego.",
        },
        "options": opt(
            ("a", "Evangelho = poder de Deus para a salvação de quem crê."),
            ("b", "Evangelho é motivo de vergonha, sem poder."),
            ("c", "O poder vale só para quem mereceu por obras."),
            ("d", "O poder alcança o judeu e exclui o grego."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Romanos 1:16?",
        "feedbackCorrect": "Certo: postura → natureza do evangelho → alcance universal.",
        "feedbackWrong": {
            "b": "O alcance fecha; não abre o verso.",
            "c": "A natureza (poder) explica a postura sem vergonha.",
        },
        "options": opt(
            ("a", "postura: não me envergonho"),
            ("b", "natureza: poder de Deus para a salvação"),
            ("c", "alcance: todo o que crê — judeu e grego"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "primeiro do ___ e depois do grego."',
        "feedbackCorrect": "Exato: primeiro do judeu e depois do grego.",
        "feedbackWrong": {
            "b": "\"grego\" vem depois do \"e\".",
            "c": "\"poder\" descreve o evangelho, não esta ordem.",
        },
        "template": "primeiro do ___ e depois do grego.",
        "options": opt(("a", "judeu"), ("b", "grego"), ("c", "poder")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 1:16 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: salvação pela fé sem vergonha do evangelho.",
        "feedbackWrong": {
            "b": "Não há exclusão do gentio que crê.",
            "c": "Não há vergonha; há poder declarado.",
        },
        "passageA": {"ref": "Romanos 1:16", "text": "não me envergonho do evangelho… poder de Deus… todo aquele que crê"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Fé sem vergonha do evangelho"),
            ("b", "Exclusão do gentio que crê"),
            ("c", "Vergonha como virtude"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # PROFUNDEZAS
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Romanos 1:16 apresenta o evangelho como força meramente humana de persuasão, sem ser poder de Deus.",
        "feedbackCorrect": "Certo: o texto diz poder de Deus, não só persuasão humana.",
        "feedbackWrong": {"true": "É poder de Deus para a salvação — não só retórica."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Romanos 1:16, toque a palavra que falta em "de todo aquele que ___, primeiro do judeu e depois do grego"?',
        "feedbackCorrect": "Exato: a condição é crer.",
        "feedbackWrong": {
            "b": "\"poder\" nomeia o que o evangelho é.",
            "c": "\"envergonho\" é o que Paulo nega no início.",
        },
        "template": "de todo aquele que ___, primeiro do judeu e depois do grego",
        "options": opt(("a", "crê"), ("b", "poder"), ("c", "envergonho")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual sentido teológico Romanos 1:16 sustenta?",
        "feedbackCorrect": "Certo: evangelho como poder divino salvando judeu e grego pela fé.",
        "feedbackWrong": {
            "b": "Não há vergonha apostólica do evangelho.",
            "c": "Não restringe a salvação a um só povo.",
            "d": "Não reduz o evangelho a opinião sem poder.",
        },
        "options": opt(
            ("a", "Poder divino salva judeu e grego pela fé."),
            ("b", "Paulo se envergonha e silencia o evangelho."),
            ("c", "Só um povo entra; o outro fica fora para sempre."),
            ("d", "O evangelho é opinião humana sem poder."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Romanos 1:16?",
        "feedbackCorrect": "Certo: coragem → poder divino → salvação pela fé a todos.",
        "feedbackWrong": {
            "b": "O alcance não antecede a declaração do poder.",
            "c": "A coragem sem vergonha abre o verso.",
        },
        "options": opt(
            ("a", "coragem: não me envergonho"),
            ("b", "identidade: evangelho = poder de Deus"),
            ("c", "alcance: salvação pela fé — judeu e grego"),
        ),
        "correctOrder": ["a", "b", "c"],
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "primeiro do judeu e depois do ___."',
        "feedbackCorrect": "Exato: depois do grego.",
        "feedbackWrong": {
            "b": "\"judeu\" já aparece antes do \"e\".",
            "c": "\"salvação\" é o fim do poder, não esta ordem.",
        },
        "template": "primeiro do judeu e depois do ___.",
        "options": opt(("a", "grego"), ("b", "judeu"), ("c", "salvação")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Romanos 1:16 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: poder de Deus sem fronteira étnica para quem crê.",
        "feedbackWrong": {
            "b": "Não há vergonha do evangelho.",
            "c": "Não há salvação só por etnia sem fé.",
        },
        "passageA": {"ref": "Romanos 1:16", "text": "poder de Deus para a salvação… judeu e… grego"},
        "passageB": {"ref": "Contexto", "text": ins},
        "options": opt(
            ("a", "Poder sem fronteira étnica"),
            ("b", "Vergonha do evangelho"),
            ("c", "Salvação só por etnia"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

assert len(Qs) == 108, len(Qs)

out = "/Users/dalwesleyduarte/dev/new/perguntas-v2/romanos.json"
with open(out, "w", encoding="utf-8") as f:
    json.dump(Qs, f, ensure_ascii=False, indent=2)
    f.write("\n")
print(f"Wrote {len(Qs)} → {out}")
