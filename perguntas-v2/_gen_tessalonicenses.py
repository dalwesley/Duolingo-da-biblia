#!/usr/bin/env python3
# -*- coding: utf-8 -*-
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


P1 = (
    "porque eles mesmos anunciam de nós qual a entrada que tivemos entre vós "
    "e como vos convertestes dos ídolos a Deus, para servirdes ao Deus vivo e verdadeiro "
    "e para aguardardes dos céus seu Filho, a quem ele ressuscitou dentre os mortos — "
    "a saber, Jesus, que nos livra da ira vindoura."
)
P2 = "Pois esta é a vontade de Deus: a vossa santificação, que vos abstenhais da fornicação,"
P3 = (
    "Quanto à vinda de nosso Senhor Jesus Cristo e à nossa reunião com ele, "
    "nós vos rogamos, irmãos, que não vos movais facilmente do vosso modo de pensar, "
    "nem tampouco vos perturbeis, nem por espírito, nem por palavra, nem por epístola "
    "como enviada de nós, como se o Dia do Senhor estivesse já perto."
)
P4 = (
    "porque o Senhor mesmo descerá do céu com grande brado, com voz de arcanjo e com trombeta de Deus, "
    "e os mortos em Cristo ressuscitarão primeiro. Então, nós, que estivermos vivos e formos deixados, "
    "seremos arrebatados, em nuvens, juntamente com eles ao encontro do Senhor nos ares; "
    "e, assim, ficaremos sempre com o Senhor."
)

LO1 = "Sair sabendo que conversão vira dos ídolos para servir ao Deus vivo e aguardar o Filho que livra da ira."
LO2 = "Sair sabendo que a vontade de Deus é santificação concreta: abster-se da fornicação."
LO3 = "Sair sabendo que a vinda e a reunião com Cristo pedem firmeza: não se abalar por rumores de que o Dia já chegou."
LO4 = "Sair sabendo que o Senhor desce, os mortos em Cristo ressuscitam primeiro, e os vivos serão arrebatados para ficar sempre com ele."
I1 = "Conversão vira as costas aos ídolos: servir ao Deus vivo e aguardar o Filho que livra da ira."
I2 = "Santidade e amor fraternal começam na vontade de Deus: santificação concreta, não só sentimento."
I3 = "Firmeza no Dia: não se deixar abalar por rumores de que o Dia já chegou."
I4 = "Esperança vigilante: o Senhor desce, os mortos ressuscitam, e ficaremos sempre com ele."


def base(diff, typ, nn, section, verse, lo, ev, passage):
    return {
        "difficulty": diff,
        "skill": SK[diff],
        "verseRef": verse,
        "learningObjective": lo,
        "evidence": ev,
        "type": typ,
        "trail": "tessalonicenses",
        "section": section,
        "id": f"tessalonicenses-{SHORT[diff]}-{section}-{nn}",
        "passageText": passage,
    }


def merge(b, extra):
    d = dict(b)
    d.update(extra)
    return q(**d)


Qs = []

# ── M1 ──────────────────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "ts-01-conversao",
    "1 Tessalonicenses 1:9–10",
    LO1,
    ["1 Tessalonicenses 1:9", "1 Tessalonicenses 1:10"],
    P1,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Os tessalonicenses se converteram dos ídolos a Deus para servir ao Deus vivo e verdadeiro.",
        "feedbackCorrect": "Certo: o texto liga conversão dos ídolos a servir ao Deus vivo.",
        "feedbackWrong": {"false": "Releia: convertestes dos ídolos a Deus, para servirdes ao Deus vivo."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Tessalonicenses 1:9–10, toque a palavra que falta em \"como vos convertestes dos ___ a Deus\"?",
        "feedbackCorrect": "Exato: a conversão é dos ídolos a Deus.",
        "feedbackWrong": {"b": "Céus é de onde se aguarda o Filho, não de onde se sai.", "c": "Filho é quem se aguarda, não o que se deixa."},
        "template": "como vos convertestes dos ___ a Deus",
        "options": opt(("a", "ídolos"), ("b", "céus"), ("c", "Filho")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que o texto afirma que os tessalonicenses passaram a fazer após a conversão?",
        "feedbackCorrect": "Certo: servir ao Deus vivo e aguardar dos céus o Filho.",
        "feedbackWrong": {
            "a": "O texto não diz que permaneceram nos ídolos.",
            "c": "A conversão é para Deus, não para um novo culto aos ídolos.",
            "d": "Aguardam o Filho ressuscitado, Jesus, não um líder terreno.",
        },
        "options": opt(
            ("a", "Permanecer nos ídolos e só ouvir o anúncio de Paulo"),
            ("b", "Servir ao Deus vivo e verdadeiro e aguardar seu Filho"),
            ("c", "Servir aos ídolos com zelo renovado após a entrada"),
            ("d", "Aguardar um líder terreno que ainda não ressuscitou"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em 1 Tessalonicenses 1:9–10?",
        "feedbackCorrect": "Certo: converter-se, servir, aguardar o Filho que livra.",
        "feedbackWrong": {"b": "O serviço ao Deus vivo vem depois da conversão, não antes.", "c": "Aguardar o Filho fecha o trecho, não o abre."},
        "options": opt(
            ("a", "vos convertestes dos ídolos a Deus"),
            ("b", "para servirdes ao Deus vivo e verdadeiro"),
            ("c", "e para aguardardes dos céus seu Filho"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"para servirdes ao Deus ___ e verdadeiro\"",
        "feedbackCorrect": "Certo: o Deus a quem servem é vivo e verdadeiro.",
        "feedbackWrong": {"b": "Verdadeiro completa a dupla, mas não esta lacuna.", "c": "Vindoura qualifica a ira, não a Deus."},
        "template": "para servirdes ao Deus ___ e verdadeiro",
        "options": opt(("a", "vivo"), ("b", "verdadeiro"), ("c", "vindoura")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Tessalonicenses 1:9–10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: conversão vira dos ídolos para servir e aguardar.",
        "feedbackWrong": {"b": "O texto não descreve um acréscimo de ídolos ao culto.", "c": "Aguarda-se o Filho dos céus, não um ídolo novo."},
        "passageA": {"ref": "1 Tessalonicenses 1:9–10", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Virar dos ídolos a Deus"),
            ("b", "Somar ídolos ao culto"),
            ("c", "Trocar um ídolo por outro"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A conversão dos tessalonicenses termina em abandono dos ídolos, sem novo serviço nem espera.",
        "feedbackCorrect": "Certo: o texto une servir ao Deus vivo e aguardar o Filho.",
        "feedbackWrong": {"true": "Há dois fins: servir ao Deus vivo e aguardar seu Filho."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Tessalonicenses 1:9–10, toque a palavra que falta em \"para aguardardes dos céus seu ___\"?",
        "feedbackCorrect": "Exato: dos céus se aguarda o Filho.",
        "feedbackWrong": {"a": "Ídolos é o que se deixa, não o que se aguarda.", "c": "Entrada descreve a chegada de Paulo, não o esperado."},
        "template": "para aguardardes dos céus seu ___",
        "options": opt(("a", "ídolos"), ("b", "Filho"), ("c", "entrada")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como o texto encadeia conversão, serviço e espera?",
        "feedbackCorrect": "Certo: sair dos ídolos abre serviço ao vivo e espera do Filho.",
        "feedbackWrong": {
            "b": "Aguardar o Filho não substitui servir no presente.",
            "c": "A conversão não é só opinião: muda o culto.",
            "d": "A ressurreição do Filho é o fundamento da espera, não um detalhe.",
        },
        "options": opt(
            ("a", "Sair dos ídolos abre serviço ao Deus vivo e espera do Filho"),
            ("b", "Aguardar o Filho dispensa servir a Deus agora"),
            ("c", "Converter-se é só mudar de opinião, sem novo culto"),
            ("d", "A ressurreição de Jesus é opcional para essa espera"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de 1 Tessalonicenses 1:9–10?",
        "feedbackCorrect": "Certo: anúncio da entrada, Filho ressuscitado, livramento da ira.",
        "feedbackWrong": {"b": "A entrada anunciada vem primeiro, não depois da ira.", "c": "O Filho ressuscitado precede o livramento da ira."},
        "options": opt(
            ("a", "eles mesmos anunciam qual a entrada que tivemos entre vós"),
            ("b", "a quem ele ressuscitou dentre os mortos — a saber, Jesus"),
            ("c", "que nos livra da ira vindoura"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"Jesus, que nos livra da ira ___\"",
        "feedbackCorrect": "Certo: Jesus livra da ira vindoura.",
        "feedbackWrong": {"a": "Verdadeiro descreve a Deus, não a ira.", "b": "Vivo descreve a Deus, não a ira."},
        "template": "Jesus, que nos livra da ira ___",
        "options": opt(("a", "verdadeiro"), ("b", "vivo"), ("c", "vindoura")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Tessalonicenses 1:9–10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: servir ao vivo e aguardar o Filho que livra da ira.",
        "feedbackWrong": {"a": "O trecho não propõe culto misto a ídolos e a Deus.", "c": "A espera é do Filho dos céus, não de um ídolo doméstico."},
        "passageA": {"ref": "1 Tessalonicenses 1:9–10", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Culto misto a ídolos e Deus"),
            ("b", "Servir e aguardar o Filho"),
            ("c", "Espera de um ídolo novo"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O Filho que se aguarda dos céus é Jesus, ressuscitado dentre os mortos, que livra da ira vindoura.",
        "feedbackCorrect": "Certo: o texto identifica o Filho com Jesus que livra da ira.",
        "feedbackWrong": {"false": "Releia: a saber, Jesus, que nos livra da ira vindoura."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Tessalonicenses 1:9–10, toque a palavra que falta em \"a quem ele ___ dentre os mortos\"?",
        "feedbackCorrect": "Exato: o Pai ressuscitou o Filho dentre os mortos.",
        "feedbackWrong": {"b": "Aguardar é a postura da igreja, não o verbo desta lacuna.", "c": "Servir descreve o culto presente, não este ato."},
        "template": "a quem ele ___ dentre os mortos",
        "options": opt(("a", "ressuscitou"), ("b", "aguardardes"), ("c", "servirdes")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que a conversão deste trecho revela sobre ídolos, Deus e ira?",
        "feedbackCorrect": "Certo: ídolos não livram; o Filho ressuscitado livra da ira.",
        "feedbackWrong": {
            "b": "Ídolos não protegem quem soma cultos; o texto os deixa para trás.",
            "c": "A ira vindoura é o horizonte de quem o Filho livra.",
            "d": "O livramento pende da ressurreição de Jesus, não de um herói humano.",
        },
        "options": opt(
            ("a", "Ídolos não livram; o Filho ressuscitado livra da ira"),
            ("b", "Ídolos ainda protegem se o culto a Deus for somado a eles"),
            ("c", "A ira vindoura não diz respeito a quem já se converteu de nome"),
            ("d", "Jesus livra por ser herói humano, não por ter sido ressuscitado"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de 1 Tessalonicenses 1:9–10?",
        "feedbackCorrect": "Certo: deixar ídolos, servir ao vivo, esperar o Filho que livra.",
        "feedbackWrong": {"b": "O livramento da ira não antecede o abandono dos ídolos.", "c": "Servir ao Deus vivo vem depois da conversão."},
        "options": opt(
            ("a", "convertestes dos ídolos a Deus"),
            ("b", "servirdes ao Deus vivo e verdadeiro"),
            ("c", "Jesus, que nos livra da ira vindoura"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"para servirdes ao Deus vivo e ___\"",
        "feedbackCorrect": "Certo: o Deus do serviço é vivo e verdadeiro, contra os ídolos.",
        "feedbackWrong": {"a": "Vindoura qualifica a ira, não o Deus servido.", "c": "Vivo já está na frase; a lacuna é verdadeiro."},
        "template": "para servirdes ao Deus vivo e ___",
        "options": opt(("a", "vindoura"), ("b", "verdadeiro"), ("c", "vivo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Tessalonicenses 1:9–10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Filho ressuscitado livra da ira; ídolos não.",
        "feedbackWrong": {"a": "Ídolos são deixados, não somados à espera.", "c": "A ira não é tema opcional; Jesus livra dela."},
        "passageA": {"ref": "1 Tessalonicenses 1:9–10", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Ídolos que também livram"),
            ("b", "Filho que livra da ira"),
            ("c", "Ira como tema opcional"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ── M2 ──────────────────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "ts-02-santidade",
    "1 Tessalonicenses 4:3",
    LO2,
    ["1 Tessalonicenses 4:3"],
    P2,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A vontade de Deus, neste versículo, é a santificação dos tessalonicenses.",
        "feedbackCorrect": "Certo: esta é a vontade de Deus: a vossa santificação.",
        "feedbackWrong": {"false": "Releia: esta é a vontade de Deus: a vossa santificação."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Tessalonicenses 4:3, toque a palavra que falta em \"Pois esta é a ___ de Deus\"?",
        "feedbackCorrect": "Exato: o versículo abre com a vontade de Deus.",
        "feedbackWrong": {"b": "Santificação é o conteúdo da vontade, não esta lacuna.", "c": "Fornicação é o que se deve evitar, não a palavra que falta."},
        "template": "Pois esta é a ___ de Deus",
        "options": opt(("a", "vontade"), ("b", "santificação"), ("c", "fornicação")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que o texto identifica como vontade de Deus neste versículo?",
        "feedbackCorrect": "Certo: a santificação, que inclui abster-se da fornicação.",
        "feedbackWrong": {
            "b": "O texto não reduz a vontade de Deus a um sentimento vago.",
            "c": "A vontade aqui não é tolerar a fornicação.",
            "d": "Não se trata de opinião humana sobre o corpo.",
        },
        "options": opt(
            ("a", "A vossa santificação, que vos abstenhais da fornicação"),
            ("b", "Apenas um sentimento interior, sem mudança de conduta"),
            ("c", "Que se tolere a fornicação entre irmãos"),
            ("d", "Que cada um decida sozinho o que fazer com o corpo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em 1 Tessalonicenses 4:3?",
        "feedbackCorrect": "Certo: vontade de Deus, santificação, abster-se da fornicação.",
        "feedbackWrong": {"b": "A abstinência não abre o versículo; a vontade de Deus abre.", "c": "Santificação vem antes da cláusula da fornicação."},
        "options": opt(
            ("a", "Pois esta é a vontade de Deus"),
            ("b", "a vossa santificação"),
            ("c", "que vos abstenhais da fornicação"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"que vos abstenhais da ___\"",
        "feedbackCorrect": "Certo: a santificação inclui abster-se da fornicação.",
        "feedbackWrong": {"a": "Vontade nomeia o querer de Deus, não esta lacuna.", "c": "Santificação é o nome da vontade, não o que se evita aqui."},
        "template": "que vos abstenhais da ___",
        "options": opt(("a", "vontade"), ("b", "fornicação"), ("c", "santificação")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Tessalonicenses 4:3 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: santificação concreta, não só sentimento.",
        "feedbackWrong": {"b": "O texto não trata santidade como gosto privado.", "c": "Não há permissão da fornicação neste versículo."},
        "passageA": {"ref": "1 Tessalonicenses 4:3", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Santificação concreta da vontade"),
            ("b", "Santidade como gosto privado"),
            ("c", "Permissão da fornicação"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Neste versículo, a vontade de Deus fica só no sentimento e não toca a conduta sexual.",
        "feedbackCorrect": "Certo: a santificação inclui abster-se da fornicação.",
        "feedbackWrong": {"true": "O texto concretiza a vontade: abstenhais da fornicação."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Tessalonicenses 4:3, toque a palavra que falta em \"a vossa ___\"?",
        "feedbackCorrect": "Exato: a vontade de Deus é a vossa santificação.",
        "feedbackWrong": {"a": "Fornicação é o que se evita, não o nome da vontade.", "c": "Vontade aparece no início, não nesta lacuna."},
        "template": "a vossa ___",
        "options": opt(("a", "fornicação"), ("b", "santificação"), ("c", "vontade")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que a cláusula \"que vos abstenhais da fornicação\" faz com a santificação?",
        "feedbackCorrect": "Certo: dá conteúdo concreto à vontade de Deus.",
        "feedbackWrong": {
            "a": "Não é um aparte opcional; explica a santificação.",
            "c": "Não reduz santidade a um clima interior sem corpo.",
            "d": "Não transfere a norma para o gosto da cultura.",
        },
        "options": opt(
            ("a", "É um aparte opcional, sem ligação com a vontade de Deus"),
            ("b", "Dá conteúdo concreto à santificação querida por Deus"),
            ("c", "Troca a santidade por um clima interior sem o corpo"),
            ("d", "Deixa a norma sexual a cargo do gosto da cultura"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de 1 Tessalonicenses 4:3?",
        "feedbackCorrect": "Certo: Deus quer; isso se chama santificação; isso se vê na abstinência.",
        "feedbackWrong": {"a": "A fornicação não é o ponto de partida da vontade de Deus.", "c": "A vontade de Deus abre o encadeamento, não fecha."},
        "options": opt(
            ("a", "esta é a vontade de Deus"),
            ("b", "a vossa santificação"),
            ("c", "vos abstenhais da fornicação"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"que vos ___ da fornicação\"",
        "feedbackCorrect": "Certo: a santificação pede que se abstenham da fornicação.",
        "feedbackWrong": {"b": "Santificação nomeia a vontade, não o verbo desta lacuna.", "c": "Vontade é o querer de Deus, não o verbo aqui."},
        "template": "que vos ___ da fornicação",
        "options": opt(("a", "abstenhais"), ("b", "santificação"), ("c", "vontade")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Tessalonicenses 4:3 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a vontade de Deus pede santidade no corpo, não só no sentimento.",
        "feedbackWrong": {"a": "O versículo não trata a fornicação como indiferente.", "c": "Não reduz a vontade de Deus a um clima sem ética."},
        "passageA": {"ref": "1 Tessalonicenses 4:3", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Fornicação como tema indiferente"),
            ("b", "Santidade que toca o corpo"),
            ("c", "Vontade sem ética nenhuma"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Chamar a santificação de vontade de Deus torna o abster-se da fornicação um pedido opcional da igreja.",
        "feedbackCorrect": "Certo: se é vontade de Deus, não é capricho opcional da igreja.",
        "feedbackWrong": {"true": "A santificação é vontade de Deus, não sugestão descartável."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Tessalonicenses 4:3, toque a palavra que falta em \"Pois esta é a vontade de ___\"?",
        "feedbackCorrect": "Exato: a norma não nasce do gosto humano, mas de Deus.",
        "feedbackWrong": {"b": "Vossa qualifica a santificação, não o autor da vontade.", "c": "Santificação é o conteúdo, não quem a quer."},
        "template": "Pois esta é a vontade de ___",
        "options": opt(("a", "Deus"), ("b", "vossa"), ("c", "santificação")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que significa ler a santificação como vontade de Deus neste versículo?",
        "feedbackCorrect": "Certo: Deus quer um povo santo no corpo, não só no sentimento.",
        "feedbackWrong": {
            "b": "Não é um ideal inatingível para adorno doutrinário.",
            "c": "Não privatiza o sexo fora da vontade de Deus.",
            "d": "Não troca a santidade por um sentimento sem abstinência.",
        },
        "options": opt(
            ("a", "Deus quer um povo santo no corpo, não só no sentimento"),
            ("b", "É um ideal inatingível, só para adorno da doutrina"),
            ("c", "O sexo fica fora da fé, como assunto puramente privado"),
            ("d", "Basta sentir-se santo, mesmo sem abster-se da fornicação"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de 1 Tessalonicenses 4:3?",
        "feedbackCorrect": "Certo: Deus quer; o nome disso é santificação; o gesto é abster-se.",
        "feedbackWrong": {"b": "O gesto da abstinência não precede o querer de Deus.", "c": "Santificação nomeia a vontade antes da cláusula da fornicação."},
        "options": opt(
            ("a", "a vontade de Deus"),
            ("b", "a vossa santificação"),
            ("c", "abstenhais da fornicação"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"Pois esta é a vontade de Deus: a ___ santificação\"",
        "feedbackCorrect": "Certo: a santificação é vossa — concreta na vida da igreja.",
        "feedbackWrong": {"b": "Deus é quem quer, não o adjetivo desta lacuna.", "c": "Fornicação é o que se evita, não o possessivo aqui."},
        "template": "Pois esta é a vontade de Deus: a ___ santificação",
        "options": opt(("a", "vossa"), ("b", "Deus"), ("c", "fornicação")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Tessalonicenses 4:3 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a vontade de Deus pede santidade concreta, não só sentimento.",
        "feedbackWrong": {"a": "O texto não trata a ética sexual como adorno opcional.", "c": "Não reduz santidade a um clima interior sem o corpo."},
        "passageA": {"ref": "1 Tessalonicenses 4:3", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Ética sexual como adorno"),
            ("b", "Vontade de Deus no corpo"),
            ("c", "Santidade só como clima"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ── M3 ──────────────────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "ts-03-dia-senhor",
    "2 Tessalonicenses 2:1–2",
    LO3,
    ["2 Tessalonicenses 2:1", "2 Tessalonicenses 2:2"],
    P3,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Paulo roga que os irmãos não se movam facilmente do modo de pensar, como se o Dia do Senhor já estivesse perto.",
        "feedbackCorrect": "Certo: o rogo é contra o abalo por rumores sobre o Dia.",
        "feedbackWrong": {"false": "Releia: não vos movais facilmente… como se o Dia já estivesse perto."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 2 Tessalonicenses 2:1–2, toque a palavra que falta em \"como se o Dia do Senhor estivesse já ___\"?",
        "feedbackCorrect": "Exato: o rumor é que o Dia já estaria perto.",
        "feedbackWrong": {"a": "Espírito é um meio de abalo, não o advérbio desta lacuna.", "c": "Palavra é outro meio de rumor, não esta lacuna."},
        "template": "como se o Dia do Senhor estivesse já ___",
        "options": opt(("a", "espírito"), ("b", "perto"), ("c", "palavra")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Sobre o que Paulo roga aos irmãos neste trecho?",
        "feedbackCorrect": "Certo: não se mover nem se perturbar como se o Dia já estivesse perto.",
        "feedbackWrong": {
            "b": "O texto não manda crer em qualquer carta sobre o Dia.",
            "c": "O rogo é para não se perturbarem, não para se alarmarem.",
            "d": "O tema é a vinda e a reunião, não a data de uma festa local.",
        },
        "options": opt(
            ("a", "Não se mover nem se perturbar como se o Dia já estivesse perto"),
            ("b", "Crer de imediato em qualquer carta sobre o Dia do Senhor"),
            ("c", "Perturbar-se logo que ouvir rumores sobre a vinda"),
            ("d", "Marcar a data de uma festa local em Tessalônica"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em 2 Tessalonicenses 2:1–2?",
        "feedbackCorrect": "Certo: vinda e reunião, rogo de firmeza, rumor de que o Dia já está perto.",
        "feedbackWrong": {"b": "O rumor do Dia perto fecha o trecho, não o abre.", "c": "O rogo vem depois do tema da vinda e da reunião."},
        "options": opt(
            ("a", "Quanto à vinda de nosso Senhor Jesus Cristo e à nossa reunião com ele"),
            ("b", "nós vos rogamos, irmãos, que não vos movais facilmente"),
            ("c", "como se o Dia do Senhor estivesse já perto"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"nem tampouco vos ___, nem por espírito, nem por palavra\"",
        "feedbackCorrect": "Certo: além de não se mover, não devem perturbar-se.",
        "feedbackWrong": {"a": "Rogamos é o verbo de Paulo, não o da igreja nesta lacuna.", "c": "Reunião é o tema da vinda, não o verbo aqui."},
        "template": "nem tampouco vos ___, nem por espírito, nem por palavra",
        "options": opt(("a", "rogamos"), ("b", "perturbeis"), ("c", "reunião")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 2 Tessalonicenses 2:1–2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: firmeza — não se deixar abalar por rumores do Dia.",
        "feedbackWrong": {"b": "O texto não manda crer em todo rumor escatológico.", "c": "Não se trata de antecipar o Dia por medo."},
        "passageA": {"ref": "2 Tessalonicenses 2:1–2", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Firmeza contra rumores do Dia"),
            ("b", "Crer em todo rumor"),
            ("c", "Antecipar o Dia por medo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Uma epístola como enviada de Paulo já basta para concluir que o Dia do Senhor está perto.",
        "feedbackCorrect": "Certo: nem epístola como enviada deles deve abalar o modo de pensar.",
        "feedbackWrong": {"true": "O texto lista epístola como enviada de nós entre os meios de abalo a rejeitar."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 2 Tessalonicenses 2:1–2, toque a palavra que falta em \"que não vos movais ___ do vosso modo de pensar\"?",
        "feedbackCorrect": "Exato: o perigo é mover-se facilmente.",
        "feedbackWrong": {"a": "Perto descreve o rumor do Dia, não este advérbio.", "c": "Irmãos é o vocativo, não o modo do movimento."},
        "template": "que não vos movais ___ do vosso modo de pensar",
        "options": opt(("a", "perto"), ("b", "facilmente"), ("c", "irmãos")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Por que espírito, palavra e epístola aparecem juntos neste rogo?",
        "feedbackCorrect": "Certo: são canais de rumor que não devem abalar o pensar.",
        "feedbackWrong": {
            "b": "Não são provas automáticas de que o Dia já chegou.",
            "c": "O texto não manda preferir visões a cartas.",
            "d": "Não se trata de silenciar toda pregação sobre a vinda.",
        },
        "options": opt(
            ("a", "São canais de rumor que não devem abalar o modo de pensar"),
            ("b", "São provas automáticas de que o Dia do Senhor já chegou"),
            ("c", "Paulo manda preferir visões a qualquer carta da igreja"),
            ("d", "Toda pregação sobre a vinda deve ser silenciada"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de 2 Tessalonicenses 2:1–2?",
        "feedbackCorrect": "Certo: não se mover, não se perturbar, nem por espírito, palavra ou epístola.",
        "feedbackWrong": {"a": "O espírito não abre o trecho; o rogo de não se mover vem antes.", "c": "A epístola fecha a lista de meios, não a inicia."},
        "options": opt(
            ("a", "não vos movais facilmente do vosso modo de pensar"),
            ("b", "nem tampouco vos perturbeis"),
            ("c", "nem por espírito, nem por palavra, nem por epístola"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"nem por espírito, nem por palavra, nem por ___\"",
        "feedbackCorrect": "Certo: até uma epístola como enviada deles pode ser meio de abalo.",
        "feedbackWrong": {"a": "Reunião é o tema da vinda, não este meio de rumor.", "c": "Vinda nomeia o assunto, não o terceiro canal."},
        "template": "nem por espírito, nem por palavra, nem por ___",
        "options": opt(("a", "reunião"), ("b", "epístola"), ("c", "vinda")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 2 Tessalonicenses 2:1–2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Dia não se decide por rumor, espírito, palavra ou carta falsa.",
        "feedbackWrong": {"a": "O texto não autoriza pânico escatológico.", "c": "Não se trata de crer em carta só porque parece paulina."},
        "passageA": {"ref": "2 Tessalonicenses 2:1–2", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Pânico que prova o Dia"),
            ("b", "Não se abalar por rumores"),
            ("c", "Carta falsa como autoridade"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A espera da vinda e da reunião com Cristo pede firmeza de pensamento, não abalo por rumores de que o Dia já chegou.",
        "feedbackCorrect": "Certo: o rogo une vinda, reunião e recusa do abalo.",
        "feedbackWrong": {"false": "O trecho liga a vinda à recusa de mover-se facilmente."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 2 Tessalonicenses 2:1–2, toque a palavra que falta em \"Quanto à vinda de nosso Senhor Jesus Cristo e à nossa ___ com ele\"?",
        "feedbackCorrect": "Exato: o tema é a vinda e a reunião com Cristo.",
        "feedbackWrong": {"b": "Epístola é um meio de rumor, não o tema desta lacuna.", "c": "Espírito é canal de abalo, não a reunião com ele."},
        "template": "Quanto à vinda de nosso Senhor Jesus Cristo e à nossa ___ com ele",
        "options": opt(("a", "reunião"), ("b", "epístola"), ("c", "espírito")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que este rogo ensina sobre a esperança do Dia do Senhor?",
        "feedbackCorrect": "Certo: a esperança se firma na vinda, não em rumores de que o Dia já chegou.",
        "feedbackWrong": {
            "b": "Aguardar o Dia não exige pânico a cada carta ou espírito.",
            "c": "Firmeza não é indiferença à vinda; é recusa do abalo.",
            "d": "Uma carta \"como enviada de nós\" não redefine o calendário de Deus.",
        },
        "options": opt(
            ("a", "A esperança se firma na vinda, não em rumores de que o Dia já chegou"),
            ("b", "Aguardar o Dia exige pânico a cada carta ou espírito"),
            ("c", "Firmeza significa indiferença à vinda de Cristo"),
            ("d", "Uma carta \"como enviada de nós\" redefine o calendário de Deus"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de 2 Tessalonicenses 2:1–2?",
        "feedbackCorrect": "Certo: vinda e reunião, recusa do abalo, recusa do rumor de que o Dia já está perto.",
        "feedbackWrong": {"b": "O rumor do Dia perto não é o ponto de partida da esperança.", "c": "O rogo de não se mover vem depois do tema da vinda."},
        "options": opt(
            ("a", "a vinda de nosso Senhor Jesus Cristo e à nossa reunião com ele"),
            ("b", "não vos movais facilmente do vosso modo de pensar"),
            ("c", "como se o Dia do Senhor estivesse já perto"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"nem por espírito, nem por ___, nem por epístola\"",
        "feedbackCorrect": "Certo: palavra também pode ser canal de abalo.",
        "feedbackWrong": {"b": "Reunião é o tema com Cristo, não este canal.", "c": "Perto descreve o rumor do Dia, não o meio."},
        "template": "nem por espírito, nem por ___, nem por epístola",
        "options": opt(("a", "palavra"), ("b", "reunião"), ("c", "perto")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 2 Tessalonicenses 2:1–2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a reunião com Cristo pede mente firme, não rumor.",
        "feedbackWrong": {"a": "O texto não trata o Dia como já consumado por boato.", "c": "Não se trata de mover o pensar a cada espírito."},
        "passageA": {"ref": "2 Tessalonicenses 2:1–2", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Dia já consumado por boato"),
            ("b", "Reunião com mente firme"),
            ("c", "Mover o pensar a cada espírito"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ── M4 ──────────────────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "ts-04-desafio",
    "1 Tessalonicenses 4:16–17",
    LO4,
    ["1 Tessalonicenses 4:16", "1 Tessalonicenses 4:17"],
    P4,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O Senhor mesmo descerá do céu, e os mortos em Cristo ressuscitarão primeiro.",
        "feedbackCorrect": "Certo: o texto afirma a descida do Senhor e a prioridade dos mortos em Cristo.",
        "feedbackWrong": {"false": "Releia: o Senhor descerá, e os mortos em Cristo ressuscitarão primeiro."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Tessalonicenses 4:16–17, toque a palavra que falta em \"porque o Senhor mesmo ___ do céu com grande brado\"?",
        "feedbackCorrect": "Exato: o Senhor mesmo descerá do céu.",
        "feedbackWrong": {"b": "Arrebatados descreve os vivos depois, não este verbo.", "c": "Sempre descreve a permanência com o Senhor, não a descida."},
        "template": "porque o Senhor mesmo ___ do céu com grande brado",
        "options": opt(("a", "descerá"), ("b", "arrebatados"), ("c", "sempre")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que o texto afirma sobre os mortos em Cristo e os que estiverem vivos?",
        "feedbackCorrect": "Certo: os mortos ressuscitam primeiro; depois os vivos são arrebatados com eles.",
        "feedbackWrong": {
            "b": "Os vivos não precedem os mortos em Cristo.",
            "c": "O encontro é com o Senhor nos ares, não uma ausência permanente.",
            "d": "O texto não diz que só os vivos verão o Senhor.",
        },
        "options": opt(
            ("a", "Os mortos em Cristo ressuscitam primeiro; os vivos são arrebatados com eles"),
            ("b", "Os vivos encontram o Senhor antes dos mortos em Cristo"),
            ("c", "Ninguém é arrebatado: todos permanecem na terra para sempre"),
            ("d", "Somente os vivos verão o Senhor; os mortos ficam para trás"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em 1 Tessalonicenses 4:16–17?",
        "feedbackCorrect": "Certo: o Senhor desce, os mortos ressuscitam, os vivos são arrebatados.",
        "feedbackWrong": {"b": "O arrebatamento dos vivos não precede a ressurreição dos mortos.", "c": "A descida do Senhor abre o trecho, não o fecha."},
        "options": opt(
            ("a", "o Senhor mesmo descerá do céu com grande brado"),
            ("b", "os mortos em Cristo ressuscitarão primeiro"),
            ("c", "seremos arrebatados, em nuvens, juntamente com eles"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"com voz de ___ e com trombeta de Deus\"",
        "feedbackCorrect": "Certo: a descida vem com voz de arcanjo e trombeta de Deus.",
        "feedbackWrong": {"b": "Nuvens descreve o arrebatamento, não esta voz.", "c": "Ares é o lugar do encontro, não quem clama."},
        "template": "com voz de ___ e com trombeta de Deus",
        "options": opt(("a", "arcanjo"), ("b", "nuvens"), ("c", "ares")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Tessalonicenses 4:16–17 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Senhor desce, os mortos ressuscitam, e ficaremos sempre com ele.",
        "feedbackWrong": {"b": "O texto não descreve abandono dos mortos em Cristo.", "c": "Não se trata de um encontro breve sem permanência."},
        "passageA": {"ref": "1 Tessalonicenses 4:16–17", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Descer, ressuscitar, ficar sempre"),
            ("b", "Abandono dos mortos em Cristo"),
            ("c", "Encontro breve sem permanência"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Os que estiverem vivos encontram o Senhor nos ares antes que os mortos em Cristo ressuscitem.",
        "feedbackCorrect": "Certo: os mortos em Cristo ressuscitam primeiro; depois os vivos são arrebatados com eles.",
        "feedbackWrong": {"true": "O texto diz: os mortos em Cristo ressuscitarão primeiro."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Tessalonicenses 4:16–17, toque a palavra que falta em \"os mortos em Cristo ressuscitarão ___\"?",
        "feedbackCorrect": "Exato: os mortos em Cristo ressuscitam primeiro.",
        "feedbackWrong": {"a": "Sempre descreve a permanência com o Senhor, não a ordem.", "c": "Nuvens descreve o arrebatamento, não esta ordem."},
        "template": "os mortos em Cristo ressuscitarão ___",
        "options": opt(("a", "sempre"), ("b", "primeiro"), ("c", "nuvens")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que o \"então\" de 4:17 faz com os vivos em relação aos mortos em Cristo?",
        "feedbackCorrect": "Certo: une os vivos aos já ressuscitados no encontro com o Senhor.",
        "feedbackWrong": {
            "b": "Não substitui a ressurreição dos mortos por um atalho dos vivos.",
            "c": "Não deixa os mortos para trás.",
            "d": "Não torna o encontro um evento só terrestre, sem o Senhor nos ares.",
        },
        "options": opt(
            ("a", "Une os vivos aos já ressuscitados no encontro com o Senhor"),
            ("b", "Dá aos vivos um atalho que torna inútil a ressurreição dos mortos"),
            ("c", "Deixa os mortos em Cristo para trás, sem encontro"),
            ("d", "Mantém tudo na terra, sem encontro com o Senhor nos ares"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de 1 Tessalonicenses 4:16–17?",
        "feedbackCorrect": "Certo: vivos deixados, arrebatados em nuvens, sempre com o Senhor.",
        "feedbackWrong": {"a": "Ficar sempre com o Senhor fecha o trecho, não o abre.", "c": "O arrebatamento vem depois de nomear os vivos deixados."},
        "options": opt(
            ("a", "nós, que estivermos vivos e formos deixados"),
            ("b", "seremos arrebatados, em nuvens, juntamente com eles"),
            ("c", "ficaremos sempre com o Senhor"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"seremos ___, em nuvens, juntamente com eles\"",
        "feedbackCorrect": "Certo: os vivos serão arrebatados junto com os ressuscitados.",
        "feedbackWrong": {"b": "Descerá é o verbo do Senhor, não dos vivos nesta lacuna.", "c": "Primeiro marca a ordem dos mortos, não este verbo."},
        "template": "seremos ___, em nuvens, juntamente com eles",
        "options": opt(("a", "arrebatados"), ("b", "descerá"), ("c", "primeiro")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Tessalonicenses 4:16–17 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a esperança une mortos e vivos no encontro com o Senhor.",
        "feedbackWrong": {"a": "O texto não descreve uma corrida em que os vivos ganham sozinhos.", "c": "Não se trata de despedida definitiva dos mortos."},
        "passageA": {"ref": "1 Tessalonicenses 4:16–17", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Corrida em que os vivos ganham"),
            ("b", "Mortos e vivos junto ao Senhor"),
            ("c", "Despedida definitiva dos mortos"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O fim do trecho não é o espetáculo da trombeta, mas ficar sempre com o Senhor.",
        "feedbackCorrect": "Certo: o desfecho é e, assim, ficaremos sempre com o Senhor.",
        "feedbackWrong": {"false": "O texto fecha com a permanência com o Senhor, não só com o brado."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Tessalonicenses 4:16–17, toque a palavra que falta em \"e, assim, ficaremos ___ com o Senhor\"?",
        "feedbackCorrect": "Exato: o desfecho da esperança é ficar sempre com o Senhor.",
        "feedbackWrong": {"b": "Primeiro marca a ordem da ressurreição, não a duração.", "c": "Brado descreve a descida, não a permanência."},
        "template": "e, assim, ficaremos ___ com o Senhor",
        "options": opt(("a", "sempre"), ("b", "primeiro"), ("c", "brado")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que esta esperança impede de concluir sobre a morte em Cristo?",
        "feedbackCorrect": "Certo: os mortos em Cristo não ficam de fora; ressuscitam primeiro e vão ao encontro.",
        "feedbackWrong": {
            "b": "A trombeta não é um espetáculo vazio sem encontro pessoal.",
            "c": "Os vivos não dispensam a ressurreição dos irmãos.",
            "d": "O encontro nos ares não é fuga sem o Senhor; é encontro com ele.",
        },
        "options": opt(
            ("a", "Os mortos em Cristo não ficam de fora: ressuscitam e vão ao encontro"),
            ("b", "A trombeta é só espetáculo, sem encontro pessoal com o Senhor"),
            ("c", "Os vivos dispensam a ressurreição dos irmãos que dormem"),
            ("d", "O encontro nos ares é fuga vazia, sem permanecer com Cristo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de 1 Tessalonicenses 4:16–17?",
        "feedbackCorrect": "Certo: o Senhor desce, os mortos ressuscitam, e a igreja fica sempre com ele.",
        "feedbackWrong": {"b": "Ficar sempre com o Senhor não antecede a descida.", "c": "A ressurreição dos mortos vem depois da descida, não no fim isolado."},
        "options": opt(
            ("a", "o Senhor mesmo descerá do céu"),
            ("b", "os mortos em Cristo ressuscitarão primeiro"),
            ("c", "ficaremos sempre com o Senhor"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"ao encontro do Senhor nos ___\"",
        "feedbackCorrect": "Certo: o encontro com o Senhor é nos ares.",
        "feedbackWrong": {"b": "Céu é de onde o Senhor desce, não o lugar desta lacuna.", "c": "Nuvens descreve o meio do arrebatamento, não esta palavra."},
        "template": "ao encontro do Senhor nos ___",
        "options": opt(("a", "ares"), ("b", "céu"), ("c", "nuvens")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Tessalonicenses 4:16–17 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a esperança vigilante termina em comunhão permanente com o Senhor.",
        "feedbackWrong": {"a": "O texto não reduz a esperança a um brado sem encontro.", "c": "Não se trata de um arrebatamento sem o Senhor."},
        "passageA": {"ref": "1 Tessalonicenses 4:16–17", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Brado sem encontro nenhum"),
            ("b", "Sempre com o Senhor"),
            ("c", "Arrebatamento sem o Senhor"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]


def check_len():
    errs = []
    for item in Qs:
        if item["type"] == "choice":
            for o in item["options"]:
                if len(o["text"]) > 90:
                    errs.append(f"{item['id']} choice {o['id']} len={len(o['text'])}: {o['text']}")
        fc = item.get("feedbackCorrect", "")
        if len(fc) > 100:
            errs.append(f"{item['id']} feedbackCorrect len={len(fc)}")
        if item["type"] in ("tap", "complete"):
            pt = item["passageText"].lower()
            for o in item["options"]:
                if o["text"].lower() not in pt:
                    errs.append(f"{item['id']} option '{o['text']}' not in passage")
    return errs


if __name__ == "__main__":
    errs = check_len()
    out = "/Users/dalwesleyduarte/dev/new/perguntas-v2/tessalonicenses.json"
    with open(out, "w", encoding="utf-8") as f:
        json.dump(Qs, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"wrote {len(Qs)} questions to {out}")
    for e in errs:
        print("ERR", e)
    if errs:
        raise SystemExit(1)
