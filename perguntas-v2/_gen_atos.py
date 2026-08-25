#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Gera perguntas-v2/atos.json — 10 missões × 18 = 180."""
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
        "trail": "atos",
        "section": section,
        "id": f"atos-{SHORT[diff]}-{section}-{nn}",
        "passageText": passage,
    }


def merge(b, extra):
    d = dict(b)
    d.update(extra)
    return q(**d)


# ── Passagens TB ────────────────────────────────────────────────────
P1 = (
    "mas recebereis poder, ao descer sobre vós o Espírito Santo, "
    "e sereis minhas testemunhas tanto em Jerusalém como em toda a Judeia "
    "e Samaria e até as extremidades da terra."
)
P2 = (
    "A esse Jesus Deus ressuscitou, do que todos nós somos testemunhas. "
    "Exaltado, pois, pela destra de Deus e, tendo recebido do Pai a promessa "
    "do Espírito Santo, derramou o que vedes e ouvis."
)
P3 = (
    "e perseveravam na doutrina dos apóstolos e na comunhão, "
    "no partir do pão e nas orações."
)
P4 = (
    "Mas Estêvão, cheio do Espírito Santo, fitou os olhos no céu, "
    "e viu a glória de Deus e Jesus em pé, à destra de Deus, e disse: "
    "Eis que vejo os céus abertos e o Filho do Homem em pé, à destra de Deus."
)
P5 = P1 + " " + P3
P6 = (
    "Mas o Senhor disse-lhe: Vai, porque este é para mim um vaso escolhido "
    "para levar o meu nome perante os gentios e os reis, bem como perante "
    "os filhos de Israel; pois eu lhe mostrarei quanto lhe é necessário "
    "padecer pelo meu nome."
)
P7 = (
    "Pedro começou a falar e disse: Na verdade, reconheço que Deus não se "
    "deixa levar de respeitos humanos, mas que em toda a nação aquele que "
    "o teme e faz o que é justo, este lhe é aceito;"
)
P8 = (
    "Enquanto eles ministravam perante o Senhor e jejuavam, disse-lhes o "
    "Espírito Santo: Separai-me a Barnabé e a Saulo para a obra a que os "
    "tenho chamado. Então, depois que jejuaram, oraram, e lhes impuseram "
    "as mãos, os despediram."
)
P9 = (
    "Durante dois anos inteiros, permaneceu no seu aposento alugado e "
    "recebia todos os que vinham ter com ele, pregando o reino de Deus e "
    "ensinando as coisas concernentes ao Senhor Jesus Cristo, com toda a "
    "liberdade e sem impedimento."
)
P10 = (
    "Mas o Senhor disse-lhe: Vai, porque este é para mim um vaso escolhido "
    "para levar o meu nome perante os gentios e os reis, bem como perante "
    "os filhos de Israel;"
)

I1 = "Ascensão envia: poder do Espírito e testemunhas até as extremidades."
I2 = "Pentecostes: Jesus exaltado derrama o Espírito — o que vedes e ouvis."
I3 = "Comunidade: doutrina, comunhão, pão e orações."
I4 = "Estêvão: sob pressão vê Jesus em pé à destra."
I5 = "Jerusalém: testemunhas e vida comum."
I6 = "Saulo: vaso escolhido — e padecer pelo nome."
I7 = "Porta aos gentios: Deus não faz acepção de pessoas."
I8 = "Antioquia: o Espírito separa e a igreja envia."
I9 = "Roma: preso, mas prega o reino sem impedimento."
I10 = "Até os confins: o vaso escolhido leva o nome."

LO1 = "Sair sabendo que, com o Espírito, os discípulos serão testemunhas de Jesus de Jerusalém até as extremidades da terra."
LO2 = "Sair sabendo que o Jesus ressuscitado e exaltado derrama o Espírito — o que se vê e se ouve em Pentecostes."
LO3 = "Sair sabendo que a igreja primitiva perseverava na doutrina dos apóstolos, na comunhão, no partir do pão e nas orações."
LO4 = "Sair sabendo que Estêvão, cheio do Espírito, vê Jesus em pé à destra de Deus sob a pressão do julgamento."
LO5 = "Sair sabendo que em Jerusalém testemunho (Atos 1:8) e vida comum (Atos 2:42) caminham juntos."
LO6 = "Sair sabendo que Saulo é vaso escolhido para levar o nome de Jesus — e que padecerá por esse nome."
LO7 = "Sair sabendo que Deus não faz acepção de pessoas: em toda nação o que o teme e pratica justiça lhe é aceito."
LO8 = "Sair sabendo que em Antioquia o Espírito separa Barnabé e Saulo, e a igreja jejua, ora e os envia."
LO9 = "Sair sabendo que em Roma Paulo, mesmo no aposento alugado, prega o reino e ensina Jesus sem impedimento."
LO10 = "Sair sabendo que o vaso escolhido leva o nome de Jesus perante gentios, reis e Israel — até os confins."

Qs = []

# ═══════════════════════════════════════════════════════════════════
# M1 ato-01-ascensao | Atos 1:8
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "ato-01-ascensao",
    "Atos 1:8",
    LO1,
    ["Atos 1:8"],
    P1,
    I1,
)

Qs += [
    # SEMENTE
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Os discípulos receberão poder ao descer sobre eles o Espírito Santo e serão testemunhas de Jesus.",
        "feedbackCorrect": "Certo: poder do Espírito e testemunho vão juntos em Atos 1:8.",
        "feedbackWrong": {"false": "Releia Atos 1:8: poder e testemunhas até as extremidades."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 1:8, toque a palavra que falta em "mas recebereis ___, ao descer sobre vós o Espírito Santo"?',
        "feedbackCorrect": "Exato: receberão poder.",
        "feedbackWrong": {
            "b": "Testemunhas é o resultado; a lacuna é poder.",
            "c": "Jerusalém é o ponto de partida, não esta lacuna.",
        },
        "template": "mas recebereis ___, ao descer sobre vós o Espírito Santo",
        "options": opt(("a", "poder"), ("b", "testemunhas"), ("c", "Jerusalém")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Até onde Atos 1:8 estende o testemunho dos discípulos?",
        "feedbackCorrect": "Certo: de Jerusalém até as extremidades da terra.",
        "feedbackWrong": {
            "b": "O texto vai além de Jerusalém e da Judeia.",
            "c": "Samaria não é o limite final; há extremidades.",
            "d": "O alcance inclui gentios nas extremidades, não só Israel.",
        },
        "options": opt(
            ("a", "De Jerusalém até as extremidades da terra"),
            ("b", "Somente dentro dos muros de Jerusalém"),
            ("c", "Apenas até a Judeia, sem Samaria"),
            ("d", "Só entre os filhos de Israel, sem gentios"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Atos 1:8?",
        "feedbackCorrect": "Certo: poder, testemunhas, alcance geográfico.",
        "feedbackWrong": {
            "b": "As testemunhas seguem o poder do Espírito.",
            "c": "O mapa do testemunho fecha o versículo.",
        },
        "options": opt(
            ("a", "recebereis poder, ao descer sobre vós o Espírito Santo"),
            ("b", "e sereis minhas testemunhas"),
            ("c", "em Jerusalém, Judeia, Samaria e até as extremidades"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "e sereis minhas ___, tanto em Jerusalém como em toda a Judeia"',
        "feedbackCorrect": "Certo: serão minhas testemunhas.",
        "feedbackWrong": {
            "a": "Poder é o que recebem; a lacuna é testemunhas.",
            "c": "Samaria é parte do mapa, não esta palavra.",
        },
        "template": "e sereis minhas ___, tanto em Jerusalém como em toda a Judeia",
        "options": opt(("a", "poder"), ("b", "testemunhas"), ("c", "Samaria")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 1:8 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a ascensão envia com poder e testemunho.",
        "feedbackWrong": {
            "b": "Não há envio sem o Espírito.",
            "c": "O alcance não para em Jerusalém.",
        },
        "passageA": {"ref": "Atos 1:8", "text": P1},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Poder e testemunhas"),
            ("b", "Envio sem Espírito"),
            ("c", "Só Jerusalém"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # CAMINHADA
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Atos 1:8, o testemunho começa nas extremidades da terra e só depois chega a Jerusalém.",
        "feedbackCorrect": "Certo: a ordem é Jerusalém, Judeia, Samaria e extremidades.",
        "feedbackWrong": {"true": "O texto parte de Jerusalém, não das extremidades."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 1:8, toque a palavra que falta em "ao descer sobre vós o ___ Santo"?',
        "feedbackCorrect": "Exato: o Espírito Santo desce sobre eles.",
        "feedbackWrong": {
            "a": "Poder é o que recebem; quem desce é o Espírito.",
            "c": "Terra fecha o alcance; aqui é Espírito.",
        },
        "template": "ao descer sobre vós o ___ Santo",
        "options": opt(("a", "poder"), ("b", "Espírito"), ("c", "terra")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Atos 1:8 liga o poder do Espírito e a missão das testemunhas?",
        "feedbackCorrect": "Certo: o poder habilita o testemunho até as extremidades.",
        "feedbackWrong": {
            "a": "O poder não substitui o testemunho; habilita-o.",
            "c": "Não há missão sem o Espírito no texto.",
            "d": "O mapa inclui Samaria e as extremidades.",
        },
        "options": opt(
            ("a", "O poder basta; testemunhar é opcional"),
            ("b", "O poder habilita testemunhas até as extremidades"),
            ("c", "As testemunhas vão sem qualquer poder do Espírito"),
            ("d", "O alcance para na Judeia, sem Samaria"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Atos 1:8?",
        "feedbackCorrect": "Certo: descida do Espírito, poder, testemunho geográfico.",
        "feedbackWrong": {
            "b": "O poder acompanha a descida do Espírito.",
            "c": "O mapa do testemunho vem depois.",
        },
        "options": opt(
            ("a", "ao descer sobre vós o Espírito Santo"),
            ("b", "recebereis poder"),
            ("c", "sereis minhas testemunhas até as extremidades"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "e até as ___ da terra"',
        "feedbackCorrect": "Certo: até as extremidades da terra.",
        "feedbackWrong": {
            "a": "Judeia é etapa intermediária; a lacuna é extremidades.",
            "c": "Samaria também é etapa; aqui é extremidades.",
        },
        "template": "e até as ___ da terra",
        "options": opt(("a", "Judeia"), ("b", "extremidades"), ("c", "Samaria")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 1:8 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: envio com Espírito até os confins.",
        "feedbackWrong": {
            "b": "Não há testemunho só local no texto.",
            "c": "O poder não fica sem missão.",
        },
        "passageA": {"ref": "Atos 1:8", "text": P1},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Envio até os confins"),
            ("b", "Testemunho só local"),
            ("c", "Poder sem missão"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # PROFUNDEZAS
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Atos 1:8 apresenta a ascensão como envio: o Espírito dá poder para testemunhar até as extremidades.",
        "feedbackCorrect": "Certo: a ascensão envia, não encerra a missão.",
        "feedbackWrong": {"false": "O versículo une poder do Espírito e alcance mundial."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 1:8, toque a palavra que falta em "tanto em ___ como em toda a Judeia e Samaria"?',
        "feedbackCorrect": "Exato: o ponto de partida é Jerusalém.",
        "feedbackWrong": {
            "b": "Samaria vem depois; aqui é Jerusalém.",
            "c": "Terra fecha o versículo; o início é Jerusalém.",
        },
        "template": "tanto em ___ como em toda a Judeia e Samaria",
        "options": opt(("a", "Jerusalém"), ("b", "Samaria"), ("c", "terra")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de Atos 1:8?",
        "feedbackCorrect": "Certo: a missão mundial nasce do poder do Espírito.",
        "feedbackWrong": {
            "a": "Não é só memória local sem envio.",
            "c": "O Espírito não dispensa o testemunho humano.",
            "d": "Samaria e as extremidades estão no mapa.",
        },
        "options": opt(
            ("a", "A ascensão encerra a missão em Jerusalém"),
            ("b", "O Espírito capacita testemunhas até os confins"),
            ("c", "Basta o Espírito; ninguém precisa testemunhar"),
            ("d", "Samaria fica de fora do plano de Jesus"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Atos 1:8?",
        "feedbackCorrect": "Certo: promessa, identidade de testemunhas, horizonte mundial.",
        "feedbackWrong": {
            "b": "Ser testemunhas segue o poder prometido.",
            "c": "As extremidades revelam o alcance da missão.",
        },
        "options": opt(
            ("a", "promessa de poder pelo Espírito Santo"),
            ("b", "identidade: sereis minhas testemunhas"),
            ("c", "horizonte: até as extremidades da terra"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "em toda a Judeia e ___ e até as extremidades da terra"',
        "feedbackCorrect": "Certo: Judeia e Samaria estão no caminho.",
        "feedbackWrong": {
            "a": "Poder não é o nome da região.",
            "c": "Jerusalém já veio antes; aqui é Samaria.",
        },
        "template": "em toda a Judeia e ___ e até as extremidades da terra",
        "options": opt(("a", "poder"), ("b", "Samaria"), ("c", "Jerusalém")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 1:8 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: ascensão que envia até as extremidades.",
        "feedbackWrong": {
            "b": "Não é retiro sem missão.",
            "c": "O Espírito não fica sem testemunhas.",
        },
        "passageA": {"ref": "Atos 1:8", "text": P1},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Ascensão que envia"),
            ("b", "Retiro sem missão"),
            ("c", "Espírito sem testemunhas"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M2 ato-02-pentecostes | Atos 2:32–33
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "ato-02-pentecostes",
    "Atos 2:32–33",
    LO2,
    ["Atos 2:32", "Atos 2:33"],
    P2,
    I2,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Deus ressuscitou a esse Jesus, e todos os apóstolos são testemunhas disso.",
        "feedbackCorrect": "Certo: Atos 2:32 afirma a ressurreição e o testemunho.",
        "feedbackWrong": {"false": "Releia Atos 2:32: Deus ressuscitou Jesus."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 2:32–33, toque a palavra que falta em "A esse Jesus Deus ___, do que todos nós somos testemunhas"?',
        "feedbackCorrect": "Exato: Deus ressuscitou a esse Jesus.",
        "feedbackWrong": {
            "b": "Exaltado vem no v.33; aqui é ressuscitou.",
            "c": "Derramou descreve o Espírito; aqui é ressuscitou.",
        },
        "template": "A esse Jesus Deus ___, do que todos nós somos testemunhas",
        "options": opt(("a", "ressuscitou"), ("b", "Exaltado"), ("c", "derramou")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Jesus exaltado faz, segundo Atos 2:33?",
        "feedbackCorrect": "Certo: derramou o que se vê e se ouve.",
        "feedbackWrong": {
            "b": "O texto diz que ele derramou o Espírito.",
            "c": "Há o que se vê e se ouve; não é invisível só.",
            "d": "A promessa vem do Pai; Jesus a derrama.",
        },
        "options": opt(
            ("a", "Derramou o Espírito — o que vedes e ouvis"),
            ("b", "Recusou derramar qualquer promessa do Pai"),
            ("c", "Nada se vê nem se ouve no relato"),
            ("d", "Recebeu a promessa, mas não a derramou"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Atos 2:32–33?",
        "feedbackCorrect": "Certo: ressurreição, exaltação, derramamento.",
        "feedbackWrong": {
            "b": "A exaltação segue a ressurreição.",
            "c": "O derramar fecha o arco.",
        },
        "options": opt(
            ("a", "A esse Jesus Deus ressuscitou"),
            ("b", "Exaltado, pois, pela destra de Deus"),
            ("c", "derramou o que vedes e ouvis"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "derramou o que ___ e ouvis"',
        "feedbackCorrect": "Certo: o que vedes e ouvis.",
        "feedbackWrong": {
            "a": "Pai é quem dá a promessa; a lacuna é vedes.",
            "c": "Destra situa a exaltação; aqui é vedes.",
        },
        "template": "derramou o que ___ e ouvis",
        "options": opt(("a", "Pai"), ("b", "vedes"), ("c", "destra")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 2:32–33 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o exaltado derrama o Espírito visível.",
        "feedbackWrong": {
            "b": "Não há Pentecostes sem o exaltado.",
            "c": "Há o que se vê e se ouve.",
        },
        "passageA": {"ref": "Atos 2:32–33", "text": P2},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Exaltado derrama o Espírito"),
            ("b", "Pentecostes sem Jesus"),
            ("c", "Nada se vê nem ouve"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Atos 2:33, Jesus derrama o Espírito sem ter recebido do Pai a promessa do Espírito Santo.",
        "feedbackCorrect": "Certo: ele recebe a promessa do Pai e então derrama.",
        "feedbackWrong": {"true": "O texto une receber do Pai e derramar."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 2:32–33, toque a palavra que falta em "Exaltado, pois, pela ___ de Deus"?',
        "feedbackCorrect": "Exato: exaltado pela destra de Deus.",
        "feedbackWrong": {
            "a": "Promessa vem depois; aqui é destra.",
            "c": "Testemunhas está no v.32; aqui é destra.",
        },
        "template": "Exaltado, pois, pela ___ de Deus",
        "options": opt(("a", "promessa"), ("b", "destra"), ("c", "testemunhas")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Atos 2:32–33 liga a ressurreição de Jesus e o Pentecostes?",
        "feedbackCorrect": "Certo: o ressuscitado exaltado derrama o Espírito.",
        "feedbackWrong": {
            "a": "Pentecostes depende do Jesus exaltado.",
            "c": "Há testemunhas da ressurreição no texto.",
            "d": "O derramar é efeito da exaltação, não o inverso.",
        },
        "options": opt(
            ("a", "Pentecostes ocorre sem relação com Jesus"),
            ("b", "O ressuscitado exaltado derrama o Espírito"),
            ("c", "Ninguém testemunha a ressurreição"),
            ("d", "O derramar do Espírito precede a exaltação"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Atos 2:32–33?",
        "feedbackCorrect": "Certo: testemunhas, exaltação, promessa derramada.",
        "feedbackWrong": {
            "b": "A exaltação segue o testemunho da ressurreição.",
            "c": "O derramar conclui o encadeamento.",
        },
        "options": opt(
            ("a", "todos nós somos testemunhas da ressurreição"),
            ("b", "Exaltado pela destra de Deus"),
            ("c", "recebeu a promessa e derramou o Espírito"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "tendo recebido do ___ a promessa do Espírito Santo"',
        "feedbackCorrect": "Certo: recebeu do Pai a promessa.",
        "feedbackWrong": {
            "a": "Destra situa a exaltação; quem dá é o Pai.",
            "c": "Jesus é o exaltado; a promessa vem do Pai.",
        },
        "template": "tendo recebido do ___ a promessa do Espírito Santo",
        "options": opt(("a", "destra"), ("b", "Pai"), ("c", "Jesus")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 2:32–33 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o que se vê e ouve vem do exaltado.",
        "feedbackWrong": {
            "b": "Não é fenômeno sem Cristo.",
            "c": "Há testemunhas da ressurreição.",
        },
        "passageA": {"ref": "Atos 2:32–33", "text": P2},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "O que vedes e ouvis"),
            ("b", "Fenômeno sem Cristo"),
            ("c", "Ressurreição sem testemunhas"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Pentecostes, em Atos 2:32–33, é apresentado como obra do Jesus exaltado que derrama a promessa do Pai.",
        "feedbackCorrect": "Certo: o centro é o Cristo exaltado, não um evento solto.",
        "feedbackWrong": {"false": "O texto une exaltação, promessa do Pai e derramamento."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 2:32–33, toque a palavra que falta em "___ o que vedes e ouvis"?',
        "feedbackCorrect": "Exato: derramou o que vedes e ouvis.",
        "feedbackWrong": {
            "b": "Ressuscitou está no v.32; aqui é derramou.",
            "c": "Exaltado descreve Jesus; a ação é derramou.",
        },
        "template": "___ o que vedes e ouvis",
        "options": opt(("a", "derramou"), ("b", "ressuscitou"), ("c", "Exaltado")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de Atos 2:32–33?",
        "feedbackCorrect": "Certo: o exaltado cumpre e derrama a promessa do Pai.",
        "feedbackWrong": {
            "a": "Não é só emoção coletiva sem Cristo.",
            "c": "A ressurreição não fica sem testemunhas.",
            "d": "O Pai dá a promessa; Jesus a derrama.",
        },
        "options": opt(
            ("a", "Pentecostes é só emoção, sem Cristo exaltado"),
            ("b", "O exaltado derrama a promessa do Pai"),
            ("c", "A ressurreição não tem testemunhas no texto"),
            ("d", "A promessa do Pai fica sem ser derramada"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Atos 2:32–33?",
        "feedbackCorrect": "Certo: Jesus ressuscitado, exaltado, Espírito derramado.",
        "feedbackWrong": {
            "b": "A exaltação segue a ressurreição.",
            "c": "O derramar torna a promessa pública.",
        },
        "options": opt(
            ("a", "Jesus ressuscitado — testemunhado"),
            ("b", "Jesus exaltado à destra"),
            ("c", "Espírito derramado — vedes e ouvis"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "a promessa do ___ Santo"',
        "feedbackCorrect": "Certo: a promessa do Espírito Santo.",
        "feedbackWrong": {
            "a": "Pai dá a promessa; o conteúdo é o Espírito.",
            "c": "Jesus é o exaltado; a promessa é do Espírito.",
        },
        "template": "a promessa do ___ Santo",
        "options": opt(("a", "Pai"), ("b", "Espírito"), ("c", "Jesus")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 2:32–33 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Pentecostes como derramar do exaltado.",
        "feedbackWrong": {
            "b": "Não há derramar sem o Senhor exaltado.",
            "c": "Há o que se vê e se ouve.",
        },
        "passageA": {"ref": "Atos 2:32–33", "text": P2},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Derramar do exaltado"),
            ("b", "Espírito sem Senhor"),
            ("c", "Promessa invisível"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M3 ato-03-comunhao | Atos 2:42
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "ato-03-comunhao",
    "Atos 2:42",
    LO3,
    ["Atos 2:42"],
    P3,
    I3,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Os crentes perseveravam na doutrina dos apóstolos e na comunhão, no partir do pão e nas orações.",
        "feedbackCorrect": "Certo: Atos 2:42 lista esses quatro eixos.",
        "feedbackWrong": {"false": "Releia Atos 2:42: doutrina, comunhão, pão e orações."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 2:42, toque a palavra que falta em "perseveravam na ___ dos apóstolos"?',
        "feedbackCorrect": "Exato: perseveravam na doutrina dos apóstolos.",
        "feedbackWrong": {
            "b": "Comunhão vem em seguida; aqui é doutrina.",
            "c": "Orações fecha a lista; aqui é doutrina.",
        },
        "template": "perseveravam na ___ dos apóstolos",
        "options": opt(("a", "doutrina"), ("b", "comunhão"), ("c", "orações")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Quais práticas Atos 2:42 atribui à perseverança da comunidade?",
        "feedbackCorrect": "Certo: doutrina, comunhão, partir do pão e orações.",
        "feedbackWrong": {
            "b": "O texto não omite a doutrina dos apóstolos.",
            "c": "Há comunhão e orações, não isolamento.",
            "d": "O partir do pão está explícito.",
        },
        "options": opt(
            ("a", "Doutrina, comunhão, partir do pão e orações"),
            ("b", "Só orações, sem doutrina dos apóstolos"),
            ("c", "Isolamento, sem comunhão alguma"),
            ("d", "Doutrina e comunhão, sem partir do pão"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Atos 2:42?",
        "feedbackCorrect": "Certo: doutrina e comunhão, depois pão e orações.",
        "feedbackWrong": {
            "b": "O partir do pão segue doutrina e comunhão.",
            "c": "As orações fecham a lista.",
        },
        "options": opt(
            ("a", "perseveravam na doutrina dos apóstolos e na comunhão"),
            ("b", "no partir do pão"),
            ("c", "e nas orações"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "no partir do ___ e nas orações"',
        "feedbackCorrect": "Certo: no partir do pão.",
        "feedbackWrong": {
            "a": "Doutrina abre a lista; aqui é pão.",
            "c": "Comunhão já veio antes; a lacuna é pão.",
        },
        "template": "no partir do ___ e nas orações",
        "options": opt(("a", "doutrina"), ("b", "pão"), ("c", "comunhão")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 2:42 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a comunidade une ensino, partilha e oração.",
        "feedbackWrong": {
            "b": "Não é fé sem vida comum.",
            "c": "Há perseverança, não abandono.",
        },
        "passageA": {"ref": "Atos 2:42", "text": P3},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Doutrina e vida comum"),
            ("b", "Fé sem comunidade"),
            ("c", "Abandono das orações"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Atos 2:42, a perseverança se limita à doutrina e deixa de lado comunhão, pão e orações.",
        "feedbackCorrect": "Certo: os quatro eixos aparecem juntos.",
        "feedbackWrong": {"true": "O texto une doutrina, comunhão, pão e orações."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 2:42, toque a palavra que falta em "e na ___, no partir do pão"?',
        "feedbackCorrect": "Exato: e na comunhão.",
        "feedbackWrong": {
            "a": "Doutrina já veio; aqui é comunhão.",
            "c": "Orações fecha; aqui é comunhão.",
        },
        "template": "e na ___, no partir do pão",
        "options": opt(("a", "doutrina"), ("b", "comunhão"), ("c", "orações")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Atos 2:42 mostra a relação entre ensino e vida da igreja?",
        "feedbackCorrect": "Certo: doutrina e práticas de comunhão caminham juntas.",
        "feedbackWrong": {
            "a": "Não há doutrina sem as outras práticas no texto.",
            "c": "O partir do pão não exclui a doutrina.",
            "d": "As orações não substituem a comunhão.",
        },
        "options": opt(
            ("a", "Só doutrina importa; o resto é opcional"),
            ("b", "Doutrina e comunhão se sustentam juntas"),
            ("c", "Basta o pão; a doutrina dos apóstolos sobra"),
            ("d", "Orações substituem qualquer comunhão"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Atos 2:42?",
        "feedbackCorrect": "Certo: doutrina, comunhão, pão e orações nessa ordem.",
        "feedbackWrong": {
            "b": "A comunhão acompanha a doutrina.",
            "c": "Pão e orações fecham a perseverança.",
        },
        "options": opt(
            ("a", "doutrina dos apóstolos"),
            ("b", "comunhão"),
            ("c", "partir do pão e orações"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "e nas ___"',
        "feedbackCorrect": "Certo: e nas orações.",
        "feedbackWrong": {
            "a": "Doutrina abre; o fim da lista é orações.",
            "c": "Pão está no meio; a lacuna final é orações.",
        },
        "template": "e nas ___",
        "options": opt(("a", "doutrina"), ("b", "orações"), ("c", "pão")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 2:42 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: perseverança em quatro práticas unidas.",
        "feedbackWrong": {
            "b": "Não é só ensino sem mesa.",
            "c": "Não é só oração isolada.",
        },
        "passageA": {"ref": "Atos 2:42", "text": P3},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Quatro práticas unidas"),
            ("b", "Só ensino sem mesa"),
            ("c", "Oração isolada"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Atos 2:42 apresenta a igreja como comunidade que persevera junta no ensino, na partilha e na oração.",
        "feedbackCorrect": "Certo: a identidade da igreja é perseverança compartilhada.",
        "feedbackWrong": {"false": "O versículo une doutrina, comunhão, pão e orações."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 2:42, toque a palavra que falta em "___ na doutrina dos apóstolos"?',
        "feedbackCorrect": "Exato: perseveravam.",
        "feedbackWrong": {
            "b": "Comunhão é um eixo; o verbo é perseveravam.",
            "c": "Pão é prática; o verbo é perseveravam.",
        },
        "template": "___ na doutrina dos apóstolos",
        "options": opt(("a", "perseveravam"), ("b", "comunhão"), ("c", "pão")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de Atos 2:42?",
        "feedbackCorrect": "Certo: a vida cristã é perseverança compartilhada nesses eixos.",
        "feedbackWrong": {
            "a": "Não é evento único sem continuidade.",
            "c": "A doutrina dos apóstolos não é opcional.",
            "d": "Comunhão e orações não se excluem.",
        },
        "options": opt(
            ("a", "A igreja só se reúne uma vez e dispensa perseverança"),
            ("b", "A igreja persevera junta em ensino, mesa e oração"),
            ("c", "Basta a comunhão; a doutrina dos apóstolos sobra"),
            ("d", "Orações e comunhão são práticas rivais no texto"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Atos 2:42?",
        "feedbackCorrect": "Certo: ensino apostólico, comunhão, mesa e oração.",
        "feedbackWrong": {
            "b": "A comunhão acompanha o ensino.",
            "c": "Mesa e oração concretizam a perseverança.",
        },
        "options": opt(
            ("a", "ensino dos apóstolos"),
            ("b", "comunhão partilhada"),
            ("c", "mesa e orações"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "na doutrina dos ___"',
        "feedbackCorrect": "Certo: doutrina dos apóstolos.",
        "feedbackWrong": {
            "a": "Pão é outra prática; aqui é apóstolos.",
            "c": "Orações fecha a lista; a lacuna é apóstolos.",
        },
        "template": "na doutrina dos ___",
        "options": opt(("a", "pão"), ("b", "apóstolos"), ("c", "orações")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 2:42 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: comunidade formada nesses quatro eixos.",
        "feedbackWrong": {
            "b": "Não é individualismo espiritual.",
            "c": "Há perseverança, não dispersão.",
        },
        "passageA": {"ref": "Atos 2:42", "text": P3},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Comunidade em quatro eixos"),
            ("b", "Fé só individual"),
            ("c", "Dispersão sem perseverança"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M4 ato-04-estevao | Atos 7:55–56
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "ato-04-estevao",
    "Atos 7:55–56",
    LO4,
    ["Atos 7:55", "Atos 7:56"],
    P4,
    I4,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Estêvão, cheio do Espírito Santo, viu a glória de Deus e Jesus em pé, à destra de Deus.",
        "feedbackCorrect": "Certo: Atos 7:55 descreve exatamente essa visão.",
        "feedbackWrong": {"false": "Releia Atos 7:55: Jesus em pé à destra."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 7:55–56, toque a palavra que falta em "Mas ___, cheio do Espírito Santo"?',
        "feedbackCorrect": "Exato: o sujeito é Estêvão.",
        "feedbackWrong": {
            "b": "Jesus é quem ele vê; o sujeito é Estêvão.",
            "c": "Céu é o lugar do olhar; o sujeito é Estêvão.",
        },
        "template": "Mas ___, cheio do Espírito Santo",
        "options": opt(("a", "Estêvão"), ("b", "Jesus"), ("c", "céu")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Estêvão declara ver em Atos 7:56?",
        "feedbackCorrect": "Certo: os céus abertos e o Filho do Homem em pé à destra.",
        "feedbackWrong": {
            "b": "O texto diz Jesus em pé, não sentado aqui.",
            "c": "Ele vê glória e Jesus, não ausência.",
            "d": "Há céus abertos no relato.",
        },
        "options": opt(
            ("a", "Os céus abertos e o Filho do Homem em pé à destra"),
            ("b", "Jesus sentado, sem menção de estar em pé"),
            ("c", "Nada no céu; só o tribunal terreno"),
            ("d", "Céus fechados e sem Filho do Homem"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Atos 7:55–56?",
        "feedbackCorrect": "Certo: cheio do Espírito, visão, declaração.",
        "feedbackWrong": {
            "b": "A visão segue o estar cheio do Espírito.",
            "c": "A declaração verbaliza o que viu.",
        },
        "options": opt(
            ("a", "Estêvão, cheio do Espírito Santo, fitou os olhos no céu"),
            ("b", "viu a glória de Deus e Jesus em pé, à destra"),
            ("c", "disse: vejo os céus abertos e o Filho do Homem em pé"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Jesus em pé, à ___ de Deus"',
        "feedbackCorrect": "Certo: à destra de Deus.",
        "feedbackWrong": {
            "a": "Glória é o que ele vê; a posição é destra.",
            "c": "Céu é o lugar do olhar; a lacuna é destra.",
        },
        "template": "Jesus em pé, à ___ de Deus",
        "options": opt(("a", "glória"), ("b", "destra"), ("c", "céu")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 7:55–56 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: sob pressão, Estêvão vê Jesus em pé.",
        "feedbackWrong": {
            "b": "Não há visão vazia sem Cristo.",
            "c": "Ele está cheio do Espírito, não abandonado.",
        },
        "passageA": {"ref": "Atos 7:55–56", "text": P4},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Jesus em pé à destra"),
            ("b", "Visão sem Cristo"),
            ("c", "Espírito ausente"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Atos 7:55–56, Estêvão vê Jesus à destra de Deus, mas o texto não o descreve cheio do Espírito Santo.",
        "feedbackCorrect": "Certo: o texto abre dizendo que estava cheio do Espírito.",
        "feedbackWrong": {"true": "Atos 7:55 começa: cheio do Espírito Santo."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 7:55–56, toque a palavra que falta em "o Filho do ___ em pé, à destra de Deus"?',
        "feedbackCorrect": "Exato: o Filho do Homem.",
        "feedbackWrong": {
            "a": "Deus é quem está à destra; o título é Homem.",
            "c": "Espírito enche Estêvão; o título é Homem.",
        },
        "template": "o Filho do ___ em pé, à destra de Deus",
        "options": opt(("a", "Deus"), ("b", "Homem"), ("c", "Espírito")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Atos 7:55–56 liga o Espírito e a visão de Estêvão?",
        "feedbackCorrect": "Certo: cheio do Espírito, ele vê Jesus exaltado.",
        "feedbackWrong": {
            "a": "A visão não anula o Espírito; nasce nele.",
            "c": "Ele vê Jesus em pé, não vazio.",
            "d": "Há declaração explícita dos céus abertos.",
        },
        "options": opt(
            ("a", "A visão substitui qualquer ação do Espírito"),
            ("b", "Cheio do Espírito, ele vê Jesus à destra"),
            ("c", "Ele vê o céu vazio, sem Filho do Homem"),
            ("d", "Ele cala e não declara o que viu"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Atos 7:55–56?",
        "feedbackCorrect": "Certo: olhar ao céu, visão da glória, declaração do Filho.",
        "feedbackWrong": {
            "b": "A visão segue o olhar ao céu.",
            "c": "A fala confirma o que viu.",
        },
        "options": opt(
            ("a", "fitou os olhos no céu"),
            ("b", "viu a glória de Deus e Jesus em pé"),
            ("c", "declarou ver o Filho do Homem à destra"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Eis que vejo os céus ___"',
        "feedbackCorrect": "Certo: os céus abertos.",
        "feedbackWrong": {
            "a": "Destra é a posição de Jesus; aqui é abertos.",
            "c": "Glória é o que ele vê; a lacuna é abertos.",
        },
        "template": "Eis que vejo os céus ___",
        "options": opt(("a", "destra"), ("b", "abertos"), ("c", "glória")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 7:55–56 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: sob julgamento, o céu se abre para Estêvão.",
        "feedbackWrong": {
            "b": "Não é abandono sob pressão.",
            "c": "Jesus está em pé, não ausente.",
        },
        "passageA": {"ref": "Atos 7:55–56", "text": P4},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Céu aberto sob pressão"),
            ("b", "Abandono no tribunal"),
            ("c", "Jesus ausente"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A visão de Estêvão sustenta que, sob perseguição, o Filho do Homem está em pé à destra — presente e exaltado.",
        "feedbackCorrect": "Certo: a postura em pé reforça presença ativa do Senhor.",
        "feedbackWrong": {"false": "O texto insiste: em pé, à destra de Deus."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 7:55–56, toque a palavra que falta em "viu a ___ de Deus e Jesus em pé"?',
        "feedbackCorrect": "Exato: viu a glória de Deus.",
        "feedbackWrong": {
            "b": "Destra é a posição; o que ele vê primeiro é glória.",
            "c": "Homem é o título de Jesus; aqui é glória.",
        },
        "template": "viu a ___ de Deus e Jesus em pé",
        "options": opt(("a", "glória"), ("b", "destra"), ("c", "Homem")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de Atos 7:55–56?",
        "feedbackCorrect": "Certo: o mártir vê o Senhor exaltado e presente.",
        "feedbackWrong": {
            "a": "Não é ilusão vazia; o texto afirma a visão.",
            "c": "Jesus está em pé, não indiferente.",
            "d": "O Espírito enche Estêvão no relato.",
        },
        "options": opt(
            ("a", "A visão é só delírio sem Cristo real"),
            ("b", "Sob pressão, o mártir vê Jesus exaltado"),
            ("c", "Jesus está à destra, mas indiferente ao martírio"),
            ("d", "Estêvão fala sem o Espírito Santo"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Atos 7:55–56?",
        "feedbackCorrect": "Certo: Espírito, visão da glória, Cristo em pé.",
        "feedbackWrong": {
            "b": "A visão segue o estar cheio do Espírito.",
            "c": "O Filho em pé completa o sentido.",
        },
        "options": opt(
            ("a", "cheio do Espírito Santo"),
            ("b", "vê a glória de Deus"),
            ("c", "vê o Filho do Homem em pé à destra"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "cheio do ___ Santo"',
        "feedbackCorrect": "Certo: cheio do Espírito Santo.",
        "feedbackWrong": {
            "a": "Filho é quem ele vê; quem o enche é o Espírito.",
            "c": "Homem é o título; a lacuna é Espírito.",
        },
        "template": "cheio do ___ Santo",
        "options": opt(("a", "Filho"), ("b", "Espírito"), ("c", "Homem")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 7:55–56 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Senhor se levanta perante o mártir.",
        "feedbackWrong": {
            "b": "Não há céu fechado no relato.",
            "c": "Não há Cristo sentado indiferente aqui.",
        },
        "passageA": {"ref": "Atos 7:55–56", "text": P4},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Senhor em pé pelo mártir"),
            ("b", "Céu fechado"),
            ("c", "Cristo indiferente"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M5 ato-boss-01 | Atos 1:8; 2:42
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "ato-boss-01",
    "Atos 1:8; 2:42",
    LO5,
    ["Atos 1:8", "Atos 2:42"],
    P5,
    I5,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Atos 1:8 promete testemunhas até as extremidades, e Atos 2:42 mostra perseverança na doutrina, comunhão, pão e orações.",
        "feedbackCorrect": "Certo: testemunho e vida comum aparecem juntos em Jerusalém.",
        "feedbackWrong": {"false": "Releia 1:8 e 2:42: envio e perseverança comunitária."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 1:8; 2:42, toque a palavra que falta em "sereis minhas ___"?',
        "feedbackCorrect": "Exato: sereis minhas testemunhas.",
        "feedbackWrong": {
            "b": "Doutrina é de 2:42; aqui é testemunhas.",
            "c": "Orações fecha 2:42; aqui é testemunhas.",
        },
        "template": "sereis minhas ___",
        "options": opt(("a", "testemunhas"), ("b", "doutrina"), ("c", "orações")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Atos 1:8 e 2:42 afirmam juntos sobre Jerusalém?",
        "feedbackCorrect": "Certo: testemunhas enviadas e vida comum perseverante.",
        "feedbackWrong": {
            "b": "Há envio até as extremidades, não só muro interno.",
            "c": "A comunhão de 2:42 não anula o testemunho.",
            "d": "Há doutrina e orações no texto.",
        },
        "options": opt(
            ("a", "Testemunhas enviadas e vida comum perseverante"),
            ("b", "Só vida interna, sem qualquer testemunho"),
            ("c", "Só testemunho, sem doutrina nem comunhão"),
            ("d", "Nem pão nem orações na comunidade"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Atos 1:8; 2:42?",
        "feedbackCorrect": "Certo: poder e testemunhas, depois perseverança comunitária.",
        "feedbackWrong": {
            "b": "O alcance geográfico segue o poder.",
            "c": "A vida comum de 2:42 completa o quadro.",
        },
        "options": opt(
            ("a", "recebereis poder… e sereis minhas testemunhas"),
            ("b", "em Jerusalém… até as extremidades da terra"),
            ("c", "perseveravam na doutrina… comunhão, pão e orações"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "perseveravam na ___ dos apóstolos"',
        "feedbackCorrect": "Certo: doutrina dos apóstolos.",
        "feedbackWrong": {
            "a": "Poder é de 1:8; aqui é doutrina.",
            "c": "Terra fecha 1:8; a lacuna é doutrina.",
        },
        "template": "perseveravam na ___ dos apóstolos",
        "options": opt(("a", "poder"), ("b", "doutrina"), ("c", "terra")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 1:8; 2:42 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: testemunhas e vida comum em Jerusalém.",
        "feedbackWrong": {
            "b": "Não há envio sem comunidade.",
            "c": "Não há comunhão sem testemunho no arco.",
        },
        "passageA": {"ref": "Atos 1:8; 2:42", "text": "sereis minhas testemunhas… perseveravam na doutrina…"},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Testemunhas e vida comum"),
            ("b", "Envio sem comunidade"),
            ("c", "Comunhão sem testemunho"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Atos 1:8 e 2:42, o testemunho até as extremidades e a perseverança comunitária aparecem como temas sem relação em Jerusalém.",
        "feedbackCorrect": "Certo: o desafio une envio e vida comum na mesma cidade.",
        "feedbackWrong": {"true": "Jerusalém une testemunhas (1:8) e perseverança (2:42)."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 1:8; 2:42, toque a palavra que falta em "no partir do ___ e nas orações"?',
        "feedbackCorrect": "Exato: no partir do pão.",
        "feedbackWrong": {
            "a": "Poder é de 1:8; aqui é pão.",
            "c": "Samaria é do mapa; aqui é pão.",
        },
        "template": "no partir do ___ e nas orações",
        "options": opt(("a", "poder"), ("b", "pão"), ("c", "Samaria")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Atos 1:8 e 2:42 se encadeiam na formação do discípulo em Jerusalém?",
        "feedbackCorrect": "Certo: enviado a testemunhar e formado na vida comum.",
        "feedbackWrong": {
            "a": "O envio não dispensa a comunhão.",
            "c": "A doutrina não anula o alcance mundial.",
            "d": "Há poder do Espírito e perseverança juntos.",
        },
        "options": opt(
            ("a", "Basta testemunhar; a comunhão é irrelevante"),
            ("b", "Testemunhar e perseverar na vida comum"),
            ("c", "Basta a doutrina local; as extremidades sobram"),
            ("d", "Há testemunho sem qualquer poder do Espírito"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Atos 1:8; 2:42?",
        "feedbackCorrect": "Certo: promessa de testemunhas, mapa, perseverança.",
        "feedbackWrong": {
            "b": "O mapa segue a identidade de testemunhas.",
            "c": "A vida comum de 2:42 completa Jerusalém.",
        },
        "options": opt(
            ("a", "sereis minhas testemunhas"),
            ("b", "de Jerusalém até as extremidades"),
            ("c", "perseveravam na doutrina e na comunhão"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "e na ___, no partir do pão"',
        "feedbackCorrect": "Certo: e na comunhão.",
        "feedbackWrong": {
            "a": "Espírito é de 1:8; aqui é comunhão.",
            "c": "Jerusalém é o lugar; a lacuna é comunhão.",
        },
        "template": "e na ___, no partir do pão",
        "options": opt(("a", "Espírito"), ("b", "comunhão"), ("c", "Jerusalém")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 1:8; 2:42 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Jerusalém forma testemunhas em comunidade.",
        "feedbackWrong": {
            "b": "Não há missão sem mesa e oração.",
            "c": "Não há comunhão sem envio no arco.",
        },
        "passageA": {"ref": "Atos 1:8; 2:42", "text": "sereis minhas testemunhas… perseveravam…"},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Jerusalém forma testemunhas"),
            ("b", "Missão sem mesa"),
            ("c", "Comunhão sem envio"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O arco de Atos 1:8 e 2:42 mostra que a missão mundial nasce de uma igreja que também persevera junta.",
        "feedbackCorrect": "Certo: envio e vida comum não se separam em Jerusalém.",
        "feedbackWrong": {"false": "Testemunhas (1:8) e perseverança (2:42) se completam."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 1:8; 2:42, toque a palavra que falta em "recebereis ___, ao descer sobre vós o Espírito Santo"?',
        "feedbackCorrect": "Exato: recebereis poder.",
        "feedbackWrong": {
            "b": "Pão é de 2:42; aqui é poder.",
            "c": "Orações fecha 2:42; aqui é poder.",
        },
        "template": "recebereis ___, ao descer sobre vós o Espírito Santo",
        "options": opt(("a", "poder"), ("b", "pão"), ("c", "orações")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de Atos 1:8; 2:42?",
        "feedbackCorrect": "Certo: a igreja testemunha e vive em comunhão perseverante.",
        "feedbackWrong": {
            "a": "O alcance mundial não anula a vida comum.",
            "c": "A doutrina não exclui o envio.",
            "d": "Há poder do Espírito e perseverança juntos.",
        },
        "options": opt(
            ("a", "Só extremidades importam; a comunhão sobra"),
            ("b", "Testemunho mundial e vida comum perseverante"),
            ("c", "Só doutrina local; o envio é opcional"),
            ("d", "Há comunhão sem qualquer poder do Espírito"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Atos 1:8; 2:42?",
        "feedbackCorrect": "Certo: Espírito e testemunhas, mapa, vida comum.",
        "feedbackWrong": {
            "b": "O mapa segue a identidade de testemunhas.",
            "c": "A perseverança comunitária completa o sentido.",
        },
        "options": opt(
            ("a", "poder do Espírito e identidade de testemunhas"),
            ("b", "alcance de Jerusalém às extremidades"),
            ("c", "perseverança em doutrina, comunhão, pão e oração"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "até as ___ da terra"',
        "feedbackCorrect": "Certo: até as extremidades da terra.",
        "feedbackWrong": {
            "a": "Doutrina é de 2:42; aqui é extremidades.",
            "c": "Comunhão é de 2:42; aqui é extremidades.",
        },
        "template": "até as ___ da terra",
        "options": opt(("a", "doutrina"), ("b", "extremidades"), ("c", "comunhão")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 1:8; 2:42 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Jerusalém une testemunhas e vida comum.",
        "feedbackWrong": {
            "b": "Não há envio sem perseverança.",
            "c": "Não há mesa sem missão no arco.",
        },
        "passageA": {"ref": "Atos 1:8; 2:42", "text": "testemunhas… doutrina… comunhão…"},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Jerusalém: envio e comunhão"),
            ("b", "Envio sem perseverança"),
            ("c", "Mesa sem missão"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M6 ato-05-saulo | Atos 9:15–16
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "ato-05-saulo",
    "Atos 9:15–16",
    LO6,
    ["Atos 9:15", "Atos 9:16"],
    P6,
    I6,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O Senhor chama Saulo de vaso escolhido para levar o seu nome perante gentios, reis e filhos de Israel.",
        "feedbackCorrect": "Certo: Atos 9:15 define Saulo como vaso escolhido.",
        "feedbackWrong": {"false": "Releia Atos 9:15: vaso escolhido para levar o nome."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 9:15–16, toque a palavra que falta em "este é para mim um ___ escolhido"?',
        "feedbackCorrect": "Exato: um vaso escolhido.",
        "feedbackWrong": {
            "b": "Nome é o que ele leva; a lacuna é vaso.",
            "c": "Reis é um público; a lacuna é vaso.",
        },
        "template": "este é para mim um ___ escolhido",
        "options": opt(("a", "vaso"), ("b", "nome"), ("c", "reis")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Perante quem Saulo deve levar o nome do Senhor, segundo Atos 9:15?",
        "feedbackCorrect": "Certo: gentios, reis e filhos de Israel.",
        "feedbackWrong": {
            "b": "O alcance inclui gentios e reis.",
            "c": "Israel também está na lista.",
            "d": "Há três públicos, não só reis.",
        },
        "options": opt(
            ("a", "Gentios, reis e filhos de Israel"),
            ("b", "Somente judeus em Jerusalém"),
            ("c", "Só gentios, sem Israel"),
            ("d", "Apenas reis, sem gentios"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Atos 9:15–16?",
        "feedbackCorrect": "Certo: ordem de ir, vaso escolhido, padecer pelo nome.",
        "feedbackWrong": {
            "b": "A identidade de vaso segue a ordem Vai.",
            "c": "O padecer fecha a palavra do Senhor.",
        },
        "options": opt(
            ("a", "Vai, porque este é para mim um vaso escolhido"),
            ("b", "para levar o meu nome perante gentios, reis e Israel"),
            ("c", "eu lhe mostrarei quanto lhe é necessário padecer"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "quanto lhe é necessário ___ pelo meu nome"',
        "feedbackCorrect": "Certo: padecer pelo meu nome.",
        "feedbackWrong": {
            "a": "Vaso é a identidade; a lacuna é padecer.",
            "c": "Gentios é o público; a lacuna é padecer.",
        },
        "template": "quanto lhe é necessário ___ pelo meu nome",
        "options": opt(("a", "vaso"), ("b", "padecer"), ("c", "gentios")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 9:15–16 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: vaso escolhido e padecer pelo nome.",
        "feedbackWrong": {
            "b": "Não há vocação sem o nome.",
            "c": "Há padecer, não só glória fácil.",
        },
        "passageA": {"ref": "Atos 9:15–16", "text": P6},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Vaso e padecer"),
            ("b", "Vocação sem nome"),
            ("c", "Glória sem sofrimento"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Atos 9:15–16, Saulo é vaso escolhido, mas o Senhor não fala de padecer pelo nome.",
        "feedbackCorrect": "Certo: o v.16 anuncia o padecer necessário.",
        "feedbackWrong": {"true": "Atos 9:16 fala explicitamente de padecer."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 9:15–16, toque a palavra que falta em "para levar o meu ___ perante os gentios"?',
        "feedbackCorrect": "Exato: levar o meu nome.",
        "feedbackWrong": {
            "a": "Vaso é quem leva; o conteúdo é nome.",
            "c": "Israel é um público; a lacuna é nome.",
        },
        "template": "para levar o meu ___ perante os gentios",
        "options": opt(("a", "vaso"), ("b", "nome"), ("c", "Israel")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Atos 9:15–16 liga a vocação de Saulo e o sofrimento?",
        "feedbackCorrect": "Certo: escolher e padecer pelo nome caminham juntos.",
        "feedbackWrong": {
            "a": "O padecer não cancela a escolha.",
            "c": "Há gentios e reis no alcance.",
            "d": "Israel também está na lista.",
        },
        "options": opt(
            ("a", "O padecer prova que ele não é escolhido"),
            ("b", "Escolhido para o nome — e para padecer por ele"),
            ("c", "Só Israel; gentios e reis ficam de fora"),
            ("d", "Leva o nome só a reis, sem Israel"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Atos 9:15–16?",
        "feedbackCorrect": "Certo: Vai, vaso escolhido, padecer pelo nome.",
        "feedbackWrong": {
            "b": "A identidade segue a ordem de ir.",
            "c": "O padecer é anunciado em seguida.",
        },
        "options": opt(
            ("a", "Vai"),
            ("b", "vaso escolhido para levar o nome"),
            ("c", "padecer necessário pelo nome"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "perante os ___ e os reis"',
        "feedbackCorrect": "Certo: perante os gentios e os reis.",
        "feedbackWrong": {
            "a": "Vaso é a identidade; o público é gentios.",
            "c": "Nome é o que se leva; o público é gentios.",
        },
        "template": "perante os ___ e os reis",
        "options": opt(("a", "vaso"), ("b", "gentios"), ("c", "nome")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 9:15–16 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: escolha e custo pelo nome.",
        "feedbackWrong": {
            "b": "Não há vocação sem custo no texto.",
            "c": "O nome não fica sem portador.",
        },
        "passageA": {"ref": "Atos 9:15–16", "text": P6},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Escolha e custo"),
            ("b", "Vocação sem custo"),
            ("c", "Nome sem portador"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Atos 9:15–16 apresenta a vocação de Saulo como privilégio e custo: levar o nome e padecer por ele.",
        "feedbackCorrect": "Certo: vaso escolhido não é vocação sem cruz.",
        "feedbackWrong": {"false": "O texto une levar o nome e padecer pelo nome."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 9:15–16, toque a palavra que falta em "um vaso ___"?',
        "feedbackCorrect": "Exato: vaso escolhido.",
        "feedbackWrong": {
            "b": "Necessário qualifica o padecer; aqui é escolhido.",
            "c": "Padecer é o anúncio seguinte; aqui é escolhido.",
        },
        "template": "um vaso ___",
        "options": opt(("a", "escolhido"), ("b", "necessário"), ("c", "padecer")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de Atos 9:15–16?",
        "feedbackCorrect": "Certo: a missão do nome inclui sofrimento necessário.",
        "feedbackWrong": {
            "a": "O padecer não cancela a escolha divina.",
            "c": "Gentios, reis e Israel estão no alcance.",
            "d": "O Senhor mostra o padecer; não o esconde.",
        },
        "options": opt(
            ("a", "Padecer prova que Saulo não foi escolhido"),
            ("b", "Levar o nome inclui padecer por ele"),
            ("c", "O alcance exclui gentios e reis"),
            ("d", "O Senhor esconde qualquer custo da vocação"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Atos 9:15–16?",
        "feedbackCorrect": "Certo: chamado, públicos do nome, custo do nome.",
        "feedbackWrong": {
            "b": "Os públicos seguem a identidade de vaso.",
            "c": "O padecer revela o custo da vocação.",
        },
        "options": opt(
            ("a", "vaso escolhido — Vai"),
            ("b", "levar o nome a gentios, reis e Israel"),
            ("c", "padecer necessário pelo nome"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "perante os filhos de ___"',
        "feedbackCorrect": "Certo: filhos de Israel.",
        "feedbackWrong": {
            "a": "Gentios já veio; aqui é Israel.",
            "c": "Reis já veio; aqui é Israel.",
        },
        "template": "perante os filhos de ___",
        "options": opt(("a", "gentios"), ("b", "Israel"), ("c", "reis")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 9:15–16 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o vaso escolhido carrega nome e cruz.",
        "feedbackWrong": {
            "b": "Não há escolha sem missão.",
            "c": "Não há nome sem custo no texto.",
        },
        "passageA": {"ref": "Atos 9:15–16", "text": P6},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Nome e cruz"),
            ("b", "Escolha sem missão"),
            ("c", "Nome sem custo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M7 ato-06-gentios | Atos 10:34–35
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "ato-06-gentios",
    "Atos 10:34–35",
    LO7,
    ["Atos 10:34", "Atos 10:35"],
    P7,
    I7,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Pedro reconhece que Deus não se deixa levar de respeitos humanos.",
        "feedbackCorrect": "Certo: Atos 10:34 afirma isso explicitamente.",
        "feedbackWrong": {"false": "Releia Atos 10:34: Deus não faz acepção."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 10:34–35, toque a palavra que falta em "Deus não se deixa levar de ___ humanos"?',
        "feedbackCorrect": "Exato: respeitos humanos.",
        "feedbackWrong": {
            "b": "Nação aparece depois; aqui é respeitos.",
            "c": "Justo descreve a conduta; aqui é respeitos.",
        },
        "template": "Deus não se deixa levar de ___ humanos",
        "options": opt(("a", "respeitos"), ("b", "nação"), ("c", "justo")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Quem, em toda a nação, é aceito por Deus segundo Atos 10:35?",
        "feedbackCorrect": "Certo: o que o teme e faz o que é justo.",
        "feedbackWrong": {
            "b": "O critério não é só origem étnica.",
            "c": "Há temor e justiça, não só riqueza.",
            "d": "Pedro afirma aceitação, não rejeição total.",
        },
        "options": opt(
            ("a", "Aquele que o teme e faz o que é justo"),
            ("b", "Somente quem nasceu judeu, sem exceção"),
            ("c", "Quem é rico, sem temor a Deus"),
            ("d", "Ninguém de outra nação lhe é aceito"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Atos 10:34–35?",
        "feedbackCorrect": "Certo: Pedro fala, reconhece, conclui sobre a nação.",
        "feedbackWrong": {
            "b": "O reconhecimento segue o início da fala.",
            "c": "A conclusão sobre a nação fecha o trecho.",
        },
        "options": opt(
            ("a", "Pedro começou a falar e disse"),
            ("b", "Deus não se deixa levar de respeitos humanos"),
            ("c", "em toda a nação o que o teme e faz o justo lhe é aceito"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "em toda a ___ aquele que o teme"',
        "feedbackCorrect": "Certo: em toda a nação.",
        "feedbackWrong": {
            "a": "Pedro é quem fala; a lacuna é nação.",
            "c": "Justo descreve a conduta; aqui é nação.",
        },
        "template": "em toda a ___ aquele que o teme",
        "options": opt(("a", "Pedro"), ("b", "nação"), ("c", "justo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 10:34–35 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Deus não faz acepção de pessoas.",
        "feedbackWrong": {
            "b": "Não há porta fechada por etnia no texto.",
            "c": "Há temor e justiça, não só sangue.",
        },
        "passageA": {"ref": "Atos 10:34–35", "text": P7},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Sem acepção de pessoas"),
            ("b", "Porta fechada aos gentios"),
            ("c", "Só sangue importa"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Atos 10:34–35, Pedro conclui que Deus aceita apenas uma nação e rejeita o temor e a justiça nas demais.",
        "feedbackCorrect": "Certo: em toda a nação o que teme e pratica justiça é aceito.",
        "feedbackWrong": {"true": "O texto diz em toda a nação, não em uma só."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 10:34–35, toque a palavra que falta em "aquele que o ___ e faz o que é justo"?',
        "feedbackCorrect": "Exato: aquele que o teme.",
        "feedbackWrong": {
            "a": "Aceito é o resultado; a lacuna é teme.",
            "c": "Nação é o âmbito; a lacuna é teme.",
        },
        "template": "aquele que o ___ e faz o que é justo",
        "options": opt(("a", "aceito"), ("b", "teme"), ("c", "nação")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Atos 10:34–35 liga a imparcialidade de Deus e a porta aos gentios?",
        "feedbackCorrect": "Certo: sem acepção, o temor e a justiça abrem a porta.",
        "feedbackWrong": {
            "a": "Pedro reconhece a imparcialidade, não a nega.",
            "c": "Há critério de temor e justiça, não só etnia.",
            "d": "A aceitação não se limita a uma nação.",
        },
        "options": opt(
            ("a", "Deus faz acepção e fecha a porta aos gentios"),
            ("b", "Sem acepção, temor e justiça são aceitos"),
            ("c", "Só a origem étnica decide a aceitação"),
            ("d", "Nenhuma nação fora de Israel pode ser aceita"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Atos 10:34–35?",
        "feedbackCorrect": "Certo: reconhecimento, negação da acepção, critério universal.",
        "feedbackWrong": {
            "b": "A negação da acepção segue o reconhecimento.",
            "c": "O critério em toda a nação fecha o pensamento.",
        },
        "options": opt(
            ("a", "reconheço que Deus"),
            ("b", "não se deixa levar de respeitos humanos"),
            ("c", "em toda a nação o que teme e pratica justiça é aceito"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "faz o que é ___, este lhe é aceito"',
        "feedbackCorrect": "Certo: faz o que é justo.",
        "feedbackWrong": {
            "a": "Humanos qualifica respeitos; a lacuna é justo.",
            "c": "Pedro é o falante; a lacuna é justo.",
        },
        "template": "faz o que é ___, este lhe é aceito",
        "options": opt(("a", "humanos"), ("b", "justo"), ("c", "Pedro")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 10:34–35 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a porta se abre sem acepção humana.",
        "feedbackWrong": {
            "b": "Não há favoritismo étnico no texto.",
            "c": "Há temor e justiça como critério.",
        },
        "passageA": {"ref": "Atos 10:34–35", "text": P7},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Porta sem acepção"),
            ("b", "Favoritismo étnico"),
            ("c", "Critério só de sangue"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Atos 10:34–35 prepara a inclusão dos gentios: Deus não julga por acepção humana, mas por temor e justiça.",
        "feedbackCorrect": "Certo: a porta teológica aos gentios se abre aqui.",
        "feedbackWrong": {"false": "Pedro reconhece imparcialidade e critério moral-teológico."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 10:34–35, toque a palavra que falta em "este lhe é ___"?',
        "feedbackCorrect": "Exato: este lhe é aceito.",
        "feedbackWrong": {
            "b": "Teme é a conduta; o resultado é aceito.",
            "c": "Nação é o âmbito; o resultado é aceito.",
        },
        "template": "este lhe é ___",
        "options": opt(("a", "aceito"), ("b", "teme"), ("c", "nação")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de Atos 10:34–35?",
        "feedbackCorrect": "Certo: Deus não faz acepção; abre caminho a toda nação.",
        "feedbackWrong": {
            "a": "Pedro não reforça acepção; ele a nega.",
            "c": "Há temor e justiça, não relativismo vazio.",
            "d": "A aceitação não se limita a uma etnia.",
        },
        "options": opt(
            ("a", "Deus reforça acepção de pessoas"),
            ("b", "Sem acepção, toda nação pode ser aceita"),
            ("c", "Temor e justiça não importam no texto"),
            ("d", "Só uma etnia permanece aceitável a Deus"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Atos 10:34–35?",
        "feedbackCorrect": "Certo: imparcialidade, âmbito universal, critério de temor e justiça.",
        "feedbackWrong": {
            "b": "O âmbito universal segue a imparcialidade.",
            "c": "Temor e justiça concretizam a aceitação.",
        },
        "options": opt(
            ("a", "Deus não faz acepção de pessoas"),
            ("b", "em toda a nação"),
            ("c", "quem teme e faz o justo é aceito"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Na verdade, ___"',
        "feedbackCorrect": "Certo: Na verdade, reconheço.",
        "feedbackWrong": {
            "a": "Aceito é o resultado; o verbo é reconheço.",
            "c": "Teme é a conduta; o verbo é reconheço.",
        },
        "template": "Na verdade, ___",
        "options": opt(("a", "aceito"), ("b", "reconheço"), ("c", "teme")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 10:34–35 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a porta aos gentios sem acepção.",
        "feedbackWrong": {
            "b": "Não há muro étnico absoluto no texto.",
            "c": "Há temor e justiça, não favoritismo.",
        },
        "passageA": {"ref": "Atos 10:34–35", "text": P7},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Porta aos gentios"),
            ("b", "Muro étnico absoluto"),
            ("c", "Favoritismo humano"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M8 ato-07-missoes | Atos 13:2–3
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "ato-07-missoes",
    "Atos 13:2–3",
    LO8,
    ["Atos 13:2", "Atos 13:3"],
    P8,
    I8,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O Espírito Santo manda separar Barnabé e Saulo para a obra a que os tem chamado.",
        "feedbackCorrect": "Certo: Atos 13:2 registra a ordem do Espírito.",
        "feedbackWrong": {"false": "Releia Atos 13:2: Separai-me a Barnabé e a Saulo."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 13:2–3, toque a palavra que falta em "Separai-me a ___ e a Saulo"?',
        "feedbackCorrect": "Exato: Barnabé e Saulo.",
        "feedbackWrong": {
            "b": "Obra é o chamado; o nome é Barnabé.",
            "c": "Mãos vem no envio; o nome é Barnabé.",
        },
        "template": "Separai-me a ___ e a Saulo",
        "options": opt(("a", "Barnabé"), ("b", "obra"), ("c", "mãos")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que a igreja faz depois da ordem do Espírito em Atos 13:3?",
        "feedbackCorrect": "Certo: jejua, ora, impõe as mãos e os despede.",
        "feedbackWrong": {
            "b": "Há jejum e oração, não rejeição.",
            "c": "Há imposição de mãos e despedida.",
            "d": "Eles são enviados, não retidos.",
        },
        "options": opt(
            ("a", "Jejua, ora, impõe as mãos e os despede"),
            ("b", "Recusa a ordem e retém Barnabé e Saulo"),
            ("c", "Envia sem orar nem impor as mãos"),
            ("d", "Ignora o Espírito e não os separa"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Atos 13:2–3?",
        "feedbackCorrect": "Certo: culto e jejum, ordem do Espírito, envio da igreja.",
        "feedbackWrong": {
            "b": "A ordem do Espírito segue o ministério e o jejum.",
            "c": "O envio com mãos conclui o trecho.",
        },
        "options": opt(
            ("a", "ministravam perante o Senhor e jejuavam"),
            ("b", "disse-lhes o Espírito Santo: Separai-me a Barnabé e a Saulo"),
            ("c", "jejuaram, oraram, impuseram as mãos e os despediram"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "lhes impuseram as ___, os despediram"',
        "feedbackCorrect": "Certo: impuseram as mãos.",
        "feedbackWrong": {
            "a": "Obra é o chamado; a lacuna é mãos.",
            "c": "Saulo é quem se envia; a lacuna é mãos.",
        },
        "template": "lhes impuseram as ___, os despediram",
        "options": opt(("a", "obra"), ("b", "mãos"), ("c", "Saulo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 13:2–3 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Espírito separa e a igreja envia.",
        "feedbackWrong": {
            "b": "Não há envio sem o Espírito.",
            "c": "A igreja não retém os chamados.",
        },
        "passageA": {"ref": "Atos 13:2–3", "text": P8},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Espírito separa, igreja envia"),
            ("b", "Envio sem Espírito"),
            ("c", "Igreja que retém"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Atos 13:2–3, o Espírito separa Barnabé e Saulo, mas a igreja os despede sem jejuar, orar nem impor as mãos.",
        "feedbackCorrect": "Certo: depois jejuaram, oraram e impuseram as mãos.",
        "feedbackWrong": {"true": "Atos 13:3 descreve jejum, oração e imposição de mãos."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 13:2–3, toque a palavra que falta em "disse-lhes o ___ Santo"?',
        "feedbackCorrect": "Exato: o Espírito Santo.",
        "feedbackWrong": {
            "a": "Senhor é perante quem ministram; quem fala é o Espírito.",
            "c": "Barnabé é separado; quem fala é o Espírito.",
        },
        "template": "disse-lhes o ___ Santo",
        "options": opt(("a", "Senhor"), ("b", "Espírito"), ("c", "Barnabé")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Atos 13:2–3 liga a iniciativa do Espírito e a resposta da igreja?",
        "feedbackCorrect": "Certo: o Espírito chama; a igreja confirma e envia.",
        "feedbackWrong": {
            "a": "A igreja não ignora a ordem.",
            "c": "Há jejum e oração no processo.",
            "d": "Barnabé e Saulo são separados juntos.",
        },
        "options": opt(
            ("a", "A igreja ignora o Espírito e retém os dois"),
            ("b", "O Espírito chama; a igreja jejua, ora e envia"),
            ("c", "Há envio sem oração nem imposição de mãos"),
            ("d", "Só Saulo é chamado; Barnabé fica de fora"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Atos 13:2–3?",
        "feedbackCorrect": "Certo: chamada do Espírito, confirmação, despedida.",
        "feedbackWrong": {
            "b": "Jejum e oração confirmam a chamada.",
            "c": "A despedida fecha o envio.",
        },
        "options": opt(
            ("a", "Separai-me a Barnabé e a Saulo"),
            ("b", "jejuaram e oraram"),
            ("c", "impuseram as mãos e os despediram"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "para a ___ a que os tenho chamado"',
        "feedbackCorrect": "Certo: para a obra a que os tenho chamado.",
        "feedbackWrong": {
            "a": "Mãos é do envio; a lacuna é obra.",
            "c": "Senhor é perante quem ministram; aqui é obra.",
        },
        "template": "para a ___ a que os tenho chamado",
        "options": opt(("a", "mãos"), ("b", "obra"), ("c", "Senhor")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 13:2–3 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: missão nasce de culto, jejum e envio.",
        "feedbackWrong": {
            "b": "Não há missão sem o Espírito.",
            "c": "A igreja participa do envio.",
        },
        "passageA": {"ref": "Atos 13:2–3", "text": P8},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Culto que envia"),
            ("b", "Missão sem Espírito"),
            ("c", "Igreja espectadora"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Atos 13:2–3 apresenta a missão como obra do Espírito confirmada pela igreja que jejua, ora e envia.",
        "feedbackCorrect": "Certo: Antioquia une chamada divina e envio eclesial.",
        "feedbackWrong": {"false": "O texto une Separai-me e a despedida com mãos."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 13:2–3, toque a palavra que falta em "Enquanto eles ___ perante o Senhor"?',
        "feedbackCorrect": "Exato: ministravam perante o Senhor.",
        "feedbackWrong": {
            "b": "Jejuavam acompanha; o verbo inicial é ministravam.",
            "c": "Despediram fecha; aqui é ministravam.",
        },
        "template": "Enquanto eles ___ perante o Senhor",
        "options": opt(("a", "ministravam"), ("b", "jejuavam"), ("c", "despediram")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de Atos 13:2–3?",
        "feedbackCorrect": "Certo: a missão apostólica nasce do Espírito e da igreja.",
        "feedbackWrong": {
            "a": "Não é iniciativa só humana sem o Espírito.",
            "c": "A igreja não fica passiva; ela envia.",
            "d": "Barnabé e Saulo são separados juntos.",
        },
        "options": opt(
            ("a", "A missão nasce só de plano humano"),
            ("b", "O Espírito chama; a igreja confirma e envia"),
            ("c", "A igreja assiste sem participar do envio"),
            ("d", "Só um dos dois é separado para a obra"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Atos 13:2–3?",
        "feedbackCorrect": "Certo: culto, chamada, envio com mãos.",
        "feedbackWrong": {
            "b": "A chamada segue o culto e o jejum.",
            "c": "O envio com mãos concretiza a missão.",
        },
        "options": opt(
            ("a", "ministério e jejum perante o Senhor"),
            ("b", "chamada do Espírito a separar"),
            ("c", "oração, mãos e despedida"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "depois que jejuaram, ___"',
        "feedbackCorrect": "Certo: depois que jejuaram, oraram.",
        "feedbackWrong": {
            "a": "Separai é a ordem; aqui é oraram.",
            "c": "Chamado já veio; a lacuna é oraram.",
        },
        "template": "depois que jejuaram, ___",
        "options": opt(("a", "Separai"), ("b", "oraram"), ("c", "chamado")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 13:2–3 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Antioquia como igreja que envia.",
        "feedbackWrong": {
            "b": "Não há chamada sem resposta eclesial.",
            "c": "Não há retenção dos enviados.",
        },
        "passageA": {"ref": "Atos 13:2–3", "text": P8},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Igreja que envia"),
            ("b", "Chamada sem resposta"),
            ("c", "Retenção dos enviados"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M9 ato-08-roma | Atos 28:30–31
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "ato-08-roma",
    "Atos 28:30–31",
    LO9,
    ["Atos 28:30", "Atos 28:31"],
    P9,
    I9,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Durante dois anos, Paulo permaneceu no aposento alugado e pregava o reino de Deus sem impedimento.",
        "feedbackCorrect": "Certo: Atos 28:30–31 une aposento, pregação e liberdade.",
        "feedbackWrong": {"false": "Releia Atos 28:30–31: dois anos, reino, sem impedimento."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 28:30–31, toque a palavra que falta em "pregando o ___ de Deus"?',
        "feedbackCorrect": "Exato: pregando o reino de Deus.",
        "feedbackWrong": {
            "b": "Aposento é o lugar; o conteúdo é reino.",
            "c": "Liberdade descreve o modo; aqui é reino.",
        },
        "template": "pregando o ___ de Deus",
        "options": opt(("a", "reino"), ("b", "aposento"), ("c", "liberdade")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Atos 28:31 descreve o ensino de Paulo em Roma?",
        "feedbackCorrect": "Certo: com toda a liberdade e sem impedimento.",
        "feedbackWrong": {
            "b": "O texto afirma liberdade, não silêncio forçado.",
            "c": "Há ensino sobre Jesus Cristo.",
            "d": "Ele recebia os que vinham ter com ele.",
        },
        "options": opt(
            ("a", "Com toda a liberdade e sem impedimento"),
            ("b", "Calado, sem pregar o reino"),
            ("c", "Sem ensinar nada sobre Jesus Cristo"),
            ("d", "Recusando receber quem vinha ter com ele"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Atos 28:30–31?",
        "feedbackCorrect": "Certo: permanência, acolhida, pregação livre.",
        "feedbackWrong": {
            "b": "A acolhida segue a permanência no aposento.",
            "c": "A pregação livre fecha o relato.",
        },
        "options": opt(
            ("a", "permaneceu no seu aposento alugado dois anos"),
            ("b", "recebia todos os que vinham ter com ele"),
            ("c", "pregando o reino e ensinando Jesus sem impedimento"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "com toda a liberdade e sem ___"',
        "feedbackCorrect": "Certo: sem impedimento.",
        "feedbackWrong": {
            "a": "Reino é o conteúdo; a lacuna é impedimento.",
            "c": "Aposento é o lugar; a lacuna é impedimento.",
        },
        "template": "com toda a liberdade e sem ___",
        "options": opt(("a", "reino"), ("b", "impedimento"), ("c", "aposento")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 28:30–31 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: preso, mas o reino avança sem impedimento.",
        "feedbackWrong": {
            "b": "Não há silêncio total em Roma.",
            "c": "Há liberdade na pregação.",
        },
        "passageA": {"ref": "Atos 28:30–31", "text": P9},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Reino sem impedimento"),
            ("b", "Silêncio em Roma"),
            ("c", "Pregação impedida"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Atos 28:30–31, Paulo está no aposento alugado, mas o texto diz que pregava com impedimento e sem liberdade.",
        "feedbackCorrect": "Certo: o texto afirma liberdade e sem impedimento.",
        "feedbackWrong": {"true": "Atos 28:31: com toda a liberdade e sem impedimento."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 28:30–31, toque a palavra que falta em "no seu ___ alugado"?',
        "feedbackCorrect": "Exato: aposento alugado.",
        "feedbackWrong": {
            "b": "Reino é o conteúdo; o lugar é aposento.",
            "c": "Cristo é o tema do ensino; o lugar é aposento.",
        },
        "template": "no seu ___ alugado",
        "options": opt(("a", "aposento"), ("b", "reino"), ("c", "Cristo")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Atos 28:30–31 liga a situação de Paulo e a continuidade da missão?",
        "feedbackCorrect": "Certo: mesmo no aposento, o reino é pregado livremente.",
        "feedbackWrong": {
            "a": "A prisão relativa não cala a pregação.",
            "c": "Há ensino sobre Jesus Cristo.",
            "d": "Ele recebe os que vêm ter com ele.",
        },
        "options": opt(
            ("a", "O aposento impede qualquer pregação do reino"),
            ("b", "No aposento, o reino segue sem impedimento"),
            ("c", "Ele ensina tudo, menos o Senhor Jesus Cristo"),
            ("d", "Ninguém é recebido no aposento alugado"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Atos 28:30–31?",
        "feedbackCorrect": "Certo: dois anos, acolhida, pregação e ensino livres.",
        "feedbackWrong": {
            "b": "A acolhida ocorre durante a permanência.",
            "c": "Pregação e ensino fecham o quadro.",
        },
        "options": opt(
            ("a", "dois anos no aposento alugado"),
            ("b", "recebia todos os que vinham"),
            ("c", "pregava o reino e ensinava Jesus com liberdade"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "ensinando as coisas concernentes ao Senhor Jesus ___"',
        "feedbackCorrect": "Certo: Senhor Jesus Cristo.",
        "feedbackWrong": {
            "a": "Reino é o outro tema; aqui é Cristo.",
            "c": "Aposento é o lugar; aqui é Cristo.",
        },
        "template": "ensinando as coisas concernentes ao Senhor Jesus ___",
        "options": opt(("a", "reino"), ("b", "Cristo"), ("c", "aposento")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 28:30–31 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a palavra não está presa com Paulo.",
        "feedbackWrong": {
            "b": "Não há fim da missão em Roma.",
            "c": "Há liberdade, não mordaça.",
        },
        "passageA": {"ref": "Atos 28:30–31", "text": P9},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Palavra não presa"),
            ("b", "Fim da missão"),
            ("c", "Pregação amordaçada"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O final de Atos mostra que a restrição de Paulo não impede a pregação livre do reino e de Jesus Cristo.",
        "feedbackCorrect": "Certo: o livro fecha com liberdade e sem impedimento.",
        "feedbackWrong": {"false": "Atos 28:31 insiste: liberdade e sem impedimento."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 28:30–31, toque a palavra que falta em "com toda a ___"?',
        "feedbackCorrect": "Exato: com toda a liberdade.",
        "feedbackWrong": {
            "b": "Impedimento é o que falta; aqui é liberdade.",
            "c": "Reino é o conteúdo; aqui é liberdade.",
        },
        "template": "com toda a ___",
        "options": opt(("a", "liberdade"), ("b", "impedimento"), ("c", "reino")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de Atos 28:30–31?",
        "feedbackCorrect": "Certo: o evangelho avança mesmo sob restrição pessoal.",
        "feedbackWrong": {
            "a": "O aposento não cala o reino.",
            "c": "Há ensino explícito sobre Jesus Cristo.",
            "d": "Há acolhida e pregação, não isolamento total.",
        },
        "options": opt(
            ("a", "A restrição de Paulo encerra o reino em Roma"),
            ("b", "Sob restrição, o reino ainda se prega livremente"),
            ("c", "Paulo prega o reino, mas omite Jesus Cristo"),
            ("d", "Ninguém é recebido; a missão para"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Atos 28:30–31?",
        "feedbackCorrect": "Certo: restrição espacial, acolhida, pregação livre.",
        "feedbackWrong": {
            "b": "A acolhida ocorre no aposento.",
            "c": "A liberdade da palavra completa o sentido.",
        },
        "options": opt(
            ("a", "aposento alugado por dois anos"),
            ("b", "acolhida de todos os que vinham"),
            ("c", "reino e Cristo anunciados sem impedimento"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Durante dois anos ___"',
        "feedbackCorrect": "Certo: Durante dois anos inteiros.",
        "feedbackWrong": {
            "a": "Alugado qualifica o aposento; aqui é inteiros.",
            "c": "Liberdade descreve o modo; aqui é inteiros.",
        },
        "template": "Durante dois anos ___",
        "options": opt(("a", "alugado"), ("b", "inteiros"), ("c", "liberdade")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 28:30–31 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Roma ouve o reino apesar das correntes.",
        "feedbackWrong": {
            "b": "Não há derrota final da palavra.",
            "c": "Há liberdade, não silêncio.",
        },
        "passageA": {"ref": "Atos 28:30–31", "text": P9},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Roma ouve o reino"),
            ("b", "Derrota da palavra"),
            ("c", "Silêncio forçado"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M10 ato-boss-02 | Atos 9:15
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "ato-boss-02",
    "Atos 9:15",
    LO10,
    ["Atos 9:15"],
    P10,
    I10,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O Senhor diz que Saulo é vaso escolhido para levar o seu nome perante gentios, reis e filhos de Israel.",
        "feedbackCorrect": "Certo: Atos 9:15 resume a vocação até os confins.",
        "feedbackWrong": {"false": "Releia Atos 9:15: vaso escolhido para levar o nome."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 9:15, toque a palavra que falta em "um vaso ___ para levar o meu nome"?',
        "feedbackCorrect": "Exato: vaso escolhido.",
        "feedbackWrong": {
            "b": "Nome é o que se leva; a lacuna é escolhido.",
            "c": "Reis é um público; a lacuna é escolhido.",
        },
        "template": "um vaso ___ para levar o meu nome",
        "options": opt(("a", "escolhido"), ("b", "nome"), ("c", "reis")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que o vaso escolhido deve levar, segundo Atos 9:15?",
        "feedbackCorrect": "Certo: o nome do Senhor perante gentios, reis e Israel.",
        "feedbackWrong": {
            "b": "O texto fala de levar o nome, não de silêncio.",
            "c": "Gentios estão no alcance.",
            "d": "Reis e Israel também estão na lista.",
        },
        "options": opt(
            ("a", "O nome do Senhor perante gentios, reis e Israel"),
            ("b", "Nada; o vaso escolhido deve permanecer calado"),
            ("c", "O nome só a judeus, sem gentios"),
            ("d", "O nome só a gentios, sem reis nem Israel"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Atos 9:15?",
        "feedbackCorrect": "Certo: Vai, vaso escolhido, públicos do nome.",
        "feedbackWrong": {
            "b": "A identidade segue a ordem Vai.",
            "c": "Os públicos fecham o versículo.",
        },
        "options": opt(
            ("a", "Vai, porque este é para mim um vaso escolhido"),
            ("b", "para levar o meu nome"),
            ("c", "perante gentios, reis e filhos de Israel"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "para levar o meu ___ perante os gentios"',
        "feedbackCorrect": "Certo: levar o meu nome.",
        "feedbackWrong": {
            "a": "Vaso é quem leva; o conteúdo é nome.",
            "c": "Israel é um público; a lacuna é nome.",
        },
        "template": "para levar o meu ___ perante os gentios",
        "options": opt(("a", "vaso"), ("b", "nome"), ("c", "Israel")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 9:15 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o vaso escolhido leva o nome até os confins.",
        "feedbackWrong": {
            "b": "Não há vaso sem missão.",
            "c": "O nome não fica só em Israel.",
        },
        "passageA": {"ref": "Atos 9:15", "text": P10},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Vaso que leva o nome"),
            ("b", "Vaso sem missão"),
            ("c", "Nome só em Israel"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Atos 9:15, o alcance do nome que Saulo leva se limita aos filhos de Israel, sem gentios nem reis.",
        "feedbackCorrect": "Certo: gentios, reis e Israel estão juntos no versículo.",
        "feedbackWrong": {"true": "O texto lista gentios, reis e filhos de Israel."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 9:15, toque a palavra que falta em "perante os ___ e os reis"?',
        "feedbackCorrect": "Exato: perante os gentios e os reis.",
        "feedbackWrong": {
            "a": "Vaso é a identidade; o público é gentios.",
            "c": "Nome é o conteúdo; o público é gentios.",
        },
        "template": "perante os ___ e os reis",
        "options": opt(("a", "vaso"), ("b", "gentios"), ("c", "nome")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Atos 9:15 liga a identidade de Saulo e o alcance da missão?",
        "feedbackCorrect": "Certo: vaso escolhido implica levar o nome a todos esses públicos.",
        "feedbackWrong": {
            "a": "A escolha não é para silêncio.",
            "c": "Gentios e reis estão no texto.",
            "d": "Israel também está na lista.",
        },
        "options": opt(
            ("a", "Escolhido para ficar calado em casa"),
            ("b", "Escolhido para levar o nome a gentios, reis e Israel"),
            ("c", "Escolhido só para Israel, sem gentios"),
            ("d", "Escolhido só para reis, sem Israel"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Atos 9:15?",
        "feedbackCorrect": "Certo: ordem, identidade, públicos do nome.",
        "feedbackWrong": {
            "b": "A identidade segue a ordem Vai.",
            "c": "Os públicos detalham o alcance.",
        },
        "options": opt(
            ("a", "Vai"),
            ("b", "vaso escolhido"),
            ("c", "gentios, reis e filhos de Israel"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "perante os filhos de ___"',
        "feedbackCorrect": "Certo: filhos de Israel.",
        "feedbackWrong": {
            "a": "Gentios já veio; aqui é Israel.",
            "c": "Reis já veio; aqui é Israel.",
        },
        "template": "perante os filhos de ___",
        "options": opt(("a", "gentios"), ("b", "Israel"), ("c", "reis")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 9:15 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o nome vai até os confins por meio do vaso.",
        "feedbackWrong": {
            "b": "Não há confins sem o nome.",
            "c": "Não há vaso sem públicos.",
        },
        "passageA": {"ref": "Atos 9:15", "text": P10},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Nome até os confins"),
            ("b", "Confins sem nome"),
            ("c", "Vaso sem públicos"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Atos 9:15 resume o arco missionário: o vaso escolhido leva o nome de Jesus a gentios, reis e Israel.",
        "feedbackCorrect": "Certo: a vocação de Saulo aponta para os confins.",
        "feedbackWrong": {"false": "O versículo une vaso escolhido e alcance amplo do nome."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Atos 9:15, toque a palavra que falta em "este é para mim um ___"?',
        "feedbackCorrect": "Exato: um vaso.",
        "feedbackWrong": {
            "b": "Nome é o que se leva; a identidade é vaso.",
            "c": "Gentios é público; a identidade é vaso.",
        },
        "template": "este é para mim um ___",
        "options": opt(("a", "vaso"), ("b", "nome"), ("c", "gentios")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de Atos 9:15?",
        "feedbackCorrect": "Certo: a escolha divina envia o nome até os confins.",
        "feedbackWrong": {
            "a": "A escolha não é para retiro sem missão.",
            "c": "Gentios e reis estão no texto.",
            "d": "Israel também recebe o nome.",
        },
        "options": opt(
            ("a", "Vaso escolhido significa retiro sem testemunho"),
            ("b", "Vaso escolhido leva o nome até os confins"),
            ("c", "O alcance exclui gentios e reis"),
            ("d", "Israel fica de fora do nome levado"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Atos 9:15?",
        "feedbackCorrect": "Certo: chamado, identidade, alcance do nome.",
        "feedbackWrong": {
            "b": "A identidade de vaso segue o Vai.",
            "c": "O alcance revela os confins da missão.",
        },
        "options": opt(
            ("a", "chamado: Vai"),
            ("b", "identidade: vaso escolhido"),
            ("c", "alcance: gentios, reis e Israel"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Mas o Senhor disse-lhe: ___"',
        "feedbackCorrect": "Certo: Vai.",
        "feedbackWrong": {
            "b": "Nome vem depois; a ordem é Vai.",
            "c": "Escolhido qualifica o vaso; a ordem é Vai.",
        },
        "template": "Mas o Senhor disse-lhe: ___",
        "options": opt(("a", "Vai"), ("b", "nome"), ("c", "escolhido")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Atos 9:15 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: até os confins, o vaso leva o nome.",
        "feedbackWrong": {
            "b": "Não há confins sem portador do nome.",
            "c": "Não há escolha sem envio.",
        },
        "passageA": {"ref": "Atos 9:15", "text": P10},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Até os confins pelo nome"),
            ("b", "Confins sem portador"),
            ("c", "Escolha sem envio"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

assert len(Qs) == 180, len(Qs)

out = "/Users/dalwesleyduarte/dev/new/perguntas-v2/atos.json"
with open(out, "w", encoding="utf-8") as f:
    json.dump(Qs, f, ensure_ascii=False, indent=2)
    f.write("\n")
print(f"Wrote {len(Qs)} questions → {out}")
