#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Gera perguntas-v2/hebreus.json (90 itens, 5 missões)."""
import json
from pathlib import Path

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
        "trail": "hebreus",
        "section": section,
        "id": f"hebreus-{SHORT[diff]}-{section}-{nn}",
        "passageText": passage,
    }


def merge(b, extra):
    d = dict(b)
    d.update(extra)
    return q(**d)


P1 = (
    "Deus, tendo falado em tempos passados, ora mais, ora menos e de muitos modos, "
    "aos pais, pelos profetas, nestes últimos dias, nos falou pelo Filho, ao qual "
    "constituiu herdeiro de todas as coisas, por quem criou igualmente os mundos; "
    "o qual, sendo o resplendor da sua glória e a imagem expressa da sua substância "
    "e sustentando todas as coisas com a palavra do seu poder, depois de fazer a "
    "purificação dos pecados, sentou-se à destra da Majestade, nas alturas,"
)
P2 = (
    "Tendo, portanto, um grande sumo sacerdote que penetrou os céus, a saber, Jesus, "
    "Filho de Deus, guardemos firmes a nossa confissão. Pois não temos um sumo sacerdote "
    "que não possa compadecer-se das nossas enfermidades, mas que tem sido tentado em "
    "todas as coisas, à nossa semelhança, mas sem pecado."
)
P3 = (
    "Mas, agora, este tem conseguido tanto melhor ministério, quanto é Mediador ainda "
    "de uma melhor aliança, a qual tem sido decretada sobre melhores promessas."
)
P4 = "Ora, a fé é a substância das coisas esperadas, a prova das coisas não vistas."
P5 = (
    "Portanto, também nós, visto que temos ao redor de nós tão grande número de testemunhas, "
    "pondo de lado todo impedimento e o pecado que se nos apega, corramos, com perseverança, "
    "a carreira que nos está proposta, fitando os olhos em Jesus, Autor e Consumador da fé, "
    "o qual, pelo gozo que lhe foi proposto, suportou a cruz, desprezando a ignomínia, "
    "e está sentado à destra do trono de Deus."
)

I1 = "Maior que anjos e Moisés: nestes últimos dias Deus falou pelo Filho — resplendor, herdeiro, sentado à destra."
I2 = "Sumo sacerdote que se compadece: tentado como nós, sem pecado; aproximemo-nos."
I3 = "Aliança melhor: Cristo é Mediador de melhores promessas, não remendo da antiga."
I4 = "A fé que persevera dá substância ao que se espera e prova o que não se vê."
I5 = "Revisão: corramos fitando Jesus — Autor e Consumador, cruz e trono."

LO1 = "Sair sabendo que nestes últimos dias Deus falou pelo Filho — herdeiro, resplendor e sentado à destra."
LO2 = "Sair sabendo que Jesus, sumo sacerdote, se compadece: tentado como nós, sem pecado."
LO3 = "Sair sabendo que Cristo é Mediador de uma aliança melhor, decretada sobre melhores promessas."
LO4 = "Sair sabendo que a fé é substância das coisas esperadas e prova das não vistas."
LO5 = "Sair sabendo que corremos a carreira fitando Jesus, Autor e Consumador, cruz e trono."

Qs = []

# ── M1 hb-01 Hebreus 1:1–3 ──────────────────────────────────────────
sec, vr, lo, ev, p = "hb-01", "Hebreus 1:1–3", LO1, ["Hebreus 1:1", "Hebreus 1:2", "Hebreus 1:3"], P1

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Nestes últimos dias Deus nos falou pelo Filho.",
        "feedbackCorrect": "Certo: o texto opõe a fala pelos profetas à fala pelo Filho.",
        "feedbackWrong": {"false": "Releia: nestes últimos dias, nos falou pelo Filho."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 1:1–3, toque a palavra que falta em \"nestes últimos dias, nos falou pelo ___\"?",
        "feedbackCorrect": "Exato: nestes últimos dias Deus falou pelo Filho.",
        "feedbackWrong": {
            "b": "Profetas é o meio dos tempos passados, não desta lacuna.",
            "c": "Mundos é o que o Filho criou, não quem fala agora.",
        },
        "template": "nestes últimos dias, nos falou pelo ___",
        "options": opt(("a", "Filho"), ("b", "profetas"), ("c", "mundos")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 1:1–3 afirma que Deus constituiu o Filho?",
        "feedbackCorrect": "Certo: constituiu-o herdeiro de todas as coisas.",
        "feedbackWrong": {
            "b": "O texto não o reduz a um profeta a mais.",
            "c": "Ele criou os mundos; não é criado como os mundos.",
            "d": "O texto não o descreve como anjo mensageiro.",
        },
        "options": opt(
            ("a", "Herdeiro de todas as coisas"),
            ("b", "Apenas mais um profeta entre os pais"),
            ("c", "Uma criatura entre os mundos que ele fez"),
            ("d", "Um anjo enviado para falar em nome de Deus"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Hebreus 1:1–3?",
        "feedbackCorrect": "Certo: profetas, depois o Filho, depois o trono.",
        "feedbackWrong": {
            "b": "A fala pelo Filho vem depois da fala pelos profetas.",
            "c": "O sentar-se à destra fecha o trecho, não o abre.",
        },
        "options": opt(
            ("a", "Deus falou em tempos passados aos pais pelos profetas"),
            ("b", "nestes últimos dias nos falou pelo Filho"),
            ("c", "depois de fazer a purificação dos pecados, sentou-se à destra"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"ao qual constituiu ___ de todas as coisas\"",
        "feedbackCorrect": "Certo: o Filho foi constituído herdeiro de todas as coisas.",
        "feedbackWrong": {
            "b": "Resplendor descreve a glória, não este título.",
            "c": "Profetas é o meio antigo, não o título do Filho.",
        },
        "template": "ao qual constituiu ___ de todas as coisas",
        "options": opt(("a", "herdeiro"), ("b", "resplendor"), ("c", "profetas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 1:1–3 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: nestes últimos dias Deus falou pelo Filho.",
        "feedbackWrong": {
            "b": "O texto não iguala o Filho a um profeta a mais.",
            "c": "A fala final não é pelos anjos, mas pelo Filho.",
        },
        "passageA": {"ref": "Hebreus 1:1–2", "text": "nestes últimos dias, nos falou pelo Filho, ao qual constituiu herdeiro de todas as coisas"},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Deus falou pelo Filho"),
            ("b", "Filho igual aos profetas"),
            ("c", "Fala final pelos anjos"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A fala pelos profetas e a fala pelo Filho são apresentadas como o mesmo meio, sem diferença de tempo.",
        "feedbackCorrect": "Certo: tempos passados pelos profetas; últimos dias pelo Filho.",
        "feedbackWrong": {"true": "O texto distingue tempos passados e estes últimos dias."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 1:1–3, toque a palavra que falta em \"sendo o ___ da sua glória e a imagem expressa da sua substância\"?",
        "feedbackCorrect": "Exato: o Filho é o resplendor da glória de Deus.",
        "feedbackWrong": {
            "a": "Herdeiro é o título da constituição, não esta lacuna.",
            "c": "Poder sustenta todas as coisas, não descreve a glória aqui.",
        },
        "template": "sendo o ___ da sua glória e a imagem expressa da sua substância",
        "options": opt(("a", "herdeiro"), ("b", "resplendor"), ("c", "poder")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Hebreus 1:1–3 relaciona a fala antiga e a fala nestes últimos dias?",
        "feedbackCorrect": "Certo: a fala antiga pelos profetas culmina na fala pelo Filho.",
        "feedbackWrong": {
            "b": "O texto não trata a fala pelo Filho como recuo.",
            "c": "Os profetas não são apagados; o Filho é o cumprimento.",
            "d": "O Filho cria os mundos; não é só um recado humano.",
        },
        "options": opt(
            ("a", "A fala pelos profetas prepara a fala definitiva pelo Filho."),
            ("b", "A fala pelo Filho é um recuo em relação aos profetas."),
            ("c", "Os profetas substituem o Filho nestes últimos dias."),
            ("d", "O Filho apenas repete, sem criar nem herdar os mundos."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Hebreus 1:1–3?",
        "feedbackCorrect": "Certo: herdeiro e criador, depois resplendor, depois o trono.",
        "feedbackWrong": {
            "b": "O resplendor descreve quem já foi constituído herdeiro.",
            "c": "O sentar-se vem depois da purificação, não antes.",
        },
        "options": opt(
            ("a", "constituiu herdeiro de todas as coisas, por quem criou os mundos"),
            ("b", "sendo o resplendor da sua glória e a imagem expressa"),
            ("c", "depois de fazer a purificação dos pecados, sentou-se à destra"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"e a imagem expressa da sua ___ e sustentando todas as coisas\"",
        "feedbackCorrect": "Certo: o Filho é a imagem expressa da substância de Deus.",
        "feedbackWrong": {
            "a": "Glória já veio no resplendor, não nesta lacuna.",
            "c": "Poder vem com a palavra que sustenta, não aqui.",
        },
        "template": "e a imagem expressa da sua ___ e sustentando todas as coisas",
        "options": opt(("a", "glória"), ("b", "substância"), ("c", "poder")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 1:1–3 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Filho é resplendor, herdeiro e está à destra.",
        "feedbackWrong": {
            "a": "O texto não o deixa no mesmo patamar dos profetas.",
            "c": "Ele se sentou à destra; não ficou só como mensageiro.",
        },
        "passageA": {"ref": "Hebreus 1:3", "text": "sendo o resplendor da sua glória e a imagem expressa da sua substância"},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Filho igual a Moisés"),
            ("b", "Resplendor e herdeiro"),
            ("c", "Só mensageiro, sem trono"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O Filho, resplendor da glória e imagem da substância, revela quem Deus é e reina após purificar pecados.",
        "feedbackCorrect": "Certo: identidade divina e trono após a purificação.",
        "feedbackWrong": {"false": "O texto une resplendor, purificação e destra da Majestade."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 1:1–3, toque a palavra que falta em \"depois de fazer a purificação dos pecados, sentou-se à destra da ___\"?",
        "feedbackCorrect": "Exato: sentou-se à destra da Majestade, nas alturas.",
        "feedbackWrong": {
            "a": "Glória descreve o resplendor, não este título do trono.",
            "b": "Substância descreve a imagem expressa, não o trono.",
        },
        "template": "depois de fazer a purificação dos pecados, sentou-se à destra da ___",
        "options": opt(("a", "glória"), ("b", "substância"), ("c", "Majestade")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 1:1–3 implica ao sentar o Filho à destra após a purificação?",
        "feedbackCorrect": "Certo: a obra está feita e o Filho reina nas alturas.",
        "feedbackWrong": {
            "a": "Sentar-se à destra não é espera ansiosa, mas trono.",
            "c": "A purificação já foi feita; não fica pendente no céu.",
            "d": "O texto não o reduz a um anjo de serviço.",
        },
        "options": opt(
            ("a", "O Filho ainda espera permissão para reinar."),
            ("b", "A obra de purificação está feita e ele reina nas alturas."),
            ("c", "A purificação dos pecados ainda precisa ser completada."),
            ("d", "O Filho permanece anjo de serviço, sem trono próprio."),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Hebreus 1:1–3?",
        "feedbackCorrect": "Certo: revelação, purificação e trono nesta ordem.",
        "feedbackWrong": {
            "b": "A purificação vem depois da revelação do Filho, não antes.",
            "c": "O trono fecha o sentido: obra feita, Filho entronizado.",
        },
        "options": opt(
            ("a", "Deus falou pelo Filho, resplendor e imagem da substância"),
            ("b", "depois de fazer a purificação dos pecados"),
            ("c", "sentou-se à destra da Majestade, nas alturas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"depois de fazer a ___ dos pecados, sentou-se à destra da Majestade\"",
        "feedbackCorrect": "Certo: a purificação precede o sentar-se à destra.",
        "feedbackWrong": {
            "b": "Glória descreve o resplendor, não esta obra.",
            "c": "Criação dos mundos já veio antes, não nesta lacuna.",
        },
        "template": "depois de fazer a ___ dos pecados, sentou-se à destra da Majestade",
        "options": opt(("a", "purificação"), ("b", "glória"), ("c", "criação")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 1:1–3 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Filho supera anjos e Moisés e está à destra.",
        "feedbackWrong": {
            "b": "O texto o entroniza; não o deixa abaixo dos anjos.",
            "c": "A fala pelo Filho não é remendo da fala mosaica.",
        },
        "passageA": {"ref": "Hebreus 1:3", "text": "depois de fazer a purificação dos pecados, sentou-se à destra da Majestade, nas alturas"},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Filho no trono, não anjo"),
            ("b", "Filho abaixo dos anjos"),
            ("c", "Remendo da lei mosaica"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M2 hb-02 Hebreus 4:14–16 ────────────────────────────────────────
sec, vr, lo, ev, p = "hb-02", "Hebreus 4:14–16", LO2, ["Hebreus 4:14", "Hebreus 4:15", "Hebreus 4:16"], P2

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Temos um grande sumo sacerdote que penetrou os céus, a saber, Jesus, Filho de Deus.",
        "feedbackCorrect": "Certo: o texto nomeia Jesus, Filho de Deus, como esse sacerdote.",
        "feedbackWrong": {"false": "Releia: grande sumo sacerdote que penetrou os céus: Jesus."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 4:14–16, toque a palavra que falta em \"Tendo, portanto, um grande sumo sacerdote que penetrou os céus, a saber, ___\"?",
        "feedbackCorrect": "Exato: o sumo sacerdote é Jesus.",
        "feedbackWrong": {
            "b": "Céus é o lugar que ele penetrou, não o nome.",
            "c": "Confissão é o que devemos guardar, não o nome dele.",
        },
        "template": "Tendo, portanto, um grande sumo sacerdote que penetrou os céus, a saber, ___",
        "options": opt(("a", "Jesus"), ("b", "céus"), ("c", "confissão")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 4:14–16 afirma que devemos fazer diante desse sumo sacerdote?",
        "feedbackCorrect": "Certo: guardemos firmes a nossa confissão.",
        "feedbackWrong": {
            "b": "O texto manda guardar a confissão, não abandoná-la.",
            "c": "Ele penetrou os céus; não ficou só na terra.",
            "d": "O texto não o descreve como incapaz de se compadecer.",
        },
        "options": opt(
            ("a", "Guardar firmes a nossa confissão"),
            ("b", "Abandonar a confissão, pois já temos sacerdote"),
            ("c", "Esperar um sacerdote que ainda não penetrou os céus"),
            ("d", "Buscar um sacerdote que não se compadeça de nós"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Hebreus 4:14–16?",
        "feedbackCorrect": "Certo: sacerdote nos céus, confissão firme, depois a compaixão.",
        "feedbackWrong": {
            "b": "A confissão vem depois de nomear o sacerdote, não antes.",
            "c": "A tentação sem pecado explica a compaixão, no fim.",
        },
        "options": opt(
            ("a", "um grande sumo sacerdote que penetrou os céus, a saber, Jesus"),
            ("b", "guardemos firmes a nossa confissão"),
            ("c", "tentado em todas as coisas, à nossa semelhança, mas sem pecado"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"guardemos firmes a nossa ___\"",
        "feedbackCorrect": "Certo: o chamado é guardar firmes a confissão.",
        "feedbackWrong": {
            "b": "Enfermidades são o objeto da compaixão, não o que guardamos.",
            "c": "Céus é o lugar que ele penetrou, não o que guardamos.",
        },
        "template": "guardemos firmes a nossa ___",
        "options": opt(("a", "confissão"), ("b", "enfermidades"), ("c", "céus")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 4:14–16 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Jesus é o sumo sacerdote que se compadece.",
        "feedbackWrong": {
            "b": "O texto afirma que ele pode se compadecer.",
            "c": "Ele foi tentado à nossa semelhança, não distante de nós.",
        },
        "passageA": {"ref": "Hebreus 4:14–15", "text": "Tendo, portanto, um grande sumo sacerdote que penetrou os céus, a saber, Jesus, Filho de Deus"},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Sacerdote que se compadece"),
            ("b", "Sacerdote incapaz de doer-se"),
            ("c", "Sacerdote alheio à tentação"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Temos um sumo sacerdote que não pode compadecer-se das nossas enfermidades.",
        "feedbackCorrect": "Certo: o texto nega exatamente essa ideia.",
        "feedbackWrong": {"true": "Ele pode se compadecer: foi tentado à nossa semelhança."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 4:14–16, toque a palavra que falta em \"não temos um sumo sacerdote que não possa ___-se das nossas enfermidades\"?",
        "feedbackCorrect": "Exato: ele pode compadecer-se das nossas enfermidades.",
        "feedbackWrong": {
            "a": "Tentado descreve a experiência dele, não este verbo.",
            "c": "Penetrou descreve a entrada nos céus, não a compaixão.",
        },
        "template": "não temos um sumo sacerdote que não possa ___-se das nossas enfermidades",
        "options": opt(("a", "tentado"), ("b", "compadecer"), ("c", "penetrou")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Hebreus 4:14–16 liga a tentação de Jesus à nossa confissão?",
        "feedbackCorrect": "Certo: tentado como nós, sem pecado, ele sustenta a confissão firme.",
        "feedbackWrong": {
            "b": "A semelhança na tentação não inclui o pecado.",
            "c": "A compaixão não cancela a chamada a guardar a confissão.",
            "d": "Ele penetrou os céus; não ficou só na fraqueza humana.",
        },
        "options": opt(
            ("a", "Tentado como nós, sem pecado, ele nos permite guardar a confissão."),
            ("b", "Tentado como nós, ele também pecou para nos entender."),
            ("c", "A compaixão dele dispensa qualquer confissão firme."),
            ("d", "Por ter sido tentado, ele não pôde penetrar os céus."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Hebreus 4:14–16?",
        "feedbackCorrect": "Certo: céus, depois a negação da insensibilidade, depois a tentação.",
        "feedbackWrong": {
            "b": "A negação da insensibilidade vem depois de nomear o sacerdote.",
            "c": "A tentação sem pecado explica por que ele se compadece.",
        },
        "options": opt(
            ("a", "grande sumo sacerdote que penetrou os céus"),
            ("b", "não temos um sumo sacerdote que não possa compadecer-se"),
            ("c", "tentado em todas as coisas, à nossa semelhança, mas sem pecado"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"tentado em todas as coisas, à nossa semelhança, mas sem ___\"",
        "feedbackCorrect": "Certo: a semelhança na tentação não inclui o pecado.",
        "feedbackWrong": {
            "a": "Céus é o lugar que ele penetrou, não esta lacuna.",
            "c": "Enfermidades são nossas, não o que falta nesta frase.",
        },
        "template": "tentado em todas as coisas, à nossa semelhança, mas sem ___",
        "options": opt(("a", "céus"), ("b", "pecado"), ("c", "enfermidades")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 4:14–16 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: tentado como nós, porém sem pecado.",
        "feedbackWrong": {
            "a": "A semelhança não inclui o pecado.",
            "c": "A tentação não o impede de ser Filho de Deus.",
        },
        "passageA": {"ref": "Hebreus 4:15", "text": "tentado em todas as coisas, à nossa semelhança, mas sem pecado"},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Tentado e também pecador"),
            ("b", "Tentado, porém sem pecado"),
            ("c", "Tentado, logo não é Filho"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A compaixão de Jesus não o torna cúmplice do pecado: ele foi tentado à nossa semelhança, mas sem pecado.",
        "feedbackCorrect": "Certo: proximidade sem contaminação; base para a confissão.",
        "feedbackWrong": {"false": "O texto une semelhança na tentação e ausência de pecado."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 4:14–16, toque a palavra que falta em \"um grande sumo sacerdote que penetrou os ___, a saber, Jesus, Filho de Deus\"?",
        "feedbackCorrect": "Exato: ele penetrou os céus.",
        "feedbackWrong": {
            "b": "Pecado fecha o trecho, não o lugar que ele penetrou.",
            "c": "Enfermidades são nossas, não o destino da entrada.",
        },
        "template": "um grande sumo sacerdote que penetrou os ___, a saber, Jesus, Filho de Deus",
        "options": opt(("a", "céus"), ("b", "pecado"), ("c", "enfermidades")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 4:14–16 implica para quem se aproxima de Deus?",
        "feedbackCorrect": "Certo: o sacerdote no céu se compadece; podemos guardar a confissão.",
        "feedbackWrong": {
            "a": "A tentação dele não autoriza o pecado nosso.",
            "c": "Ele penetrou os céus; não ficou só como exemplo terreno.",
            "d": "A firmeza da confissão é o chamado, não o abandono.",
        },
        "options": opt(
            ("a", "Podemos pecar sem medo, pois ele também pecou."),
            ("b", "Há sacerdote no céu que se compadece; guardemos a confissão."),
            ("c", "Jesus ficou só na terra e não penetrou os céus."),
            ("d", "A compaixão dele torna inútil qualquer confissão."),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Hebreus 4:14–16?",
        "feedbackCorrect": "Certo: Filho no céu, depois proximidade, depois santidade na tentação.",
        "feedbackWrong": {
            "b": "A compaixão explica por que o Filho no céu não está distante.",
            "c": "Sem pecado fecha o sentido: próximo, porém santo.",
        },
        "options": opt(
            ("a", "Jesus, Filho de Deus, penetrou os céus como sumo sacerdote"),
            ("b", "pode compadecer-se das nossas enfermidades"),
            ("c", "tentado à nossa semelhança, mas sem pecado"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"a saber, Jesus, ___ de Deus, guardemos firmes a nossa confissão\"",
        "feedbackCorrect": "Certo: o sumo sacerdote é o Filho de Deus.",
        "feedbackWrong": {
            "b": "Pecado é o que ele não tem, não o título dele.",
            "c": "Confissão é o que guardamos, não o título de Jesus.",
        },
        "template": "a saber, Jesus, ___ de Deus, guardemos firmes a nossa confissão",
        "options": opt(("a", "Filho"), ("b", "pecado"), ("c", "confissão")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 4:14–16 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: há sacerdote que se compadece; aproximemo-nos.",
        "feedbackWrong": {
            "b": "O texto convida a guardar a confissão, não a fugir.",
            "c": "A distância do céu não apaga a compaixão dele.",
        },
        "passageA": {"ref": "Hebreus 4:14–15", "text": "guardemos firmes a nossa confissão. Pois não temos um sumo sacerdote que não possa compadecer-se"},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Aproximar-se com confiança"),
            ("b", "Fugir do trono da graça"),
            ("c", "Céu distante, sem compaixão"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M3 hb-03 Hebreus 8:6 ────────────────────────────────────────────
sec, vr, lo, ev, p = "hb-03", "Hebreus 8:6", LO3, ["Hebreus 8:6"], P3

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Este tem conseguido tanto melhor ministério, quanto é Mediador ainda de uma melhor aliança.",
        "feedbackCorrect": "Certo: ministério melhor e aliança melhor no mesmo versículo.",
        "feedbackWrong": {"false": "Releia Hebreus 8:6: melhor ministério e melhor aliança."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 8:6, toque a palavra que falta em \"quanto é ___ ainda de uma melhor aliança\"?",
        "feedbackCorrect": "Exato: ele é Mediador de uma melhor aliança.",
        "feedbackWrong": {
            "b": "Ministério é o que ele conseguiu, não este título.",
            "c": "Promessas sustentam a aliança, não o título dele.",
        },
        "template": "quanto é ___ ainda de uma melhor aliança",
        "options": opt(("a", "Mediador"), ("b", "ministério"), ("c", "promessas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Sobre o que, segundo Hebreus 8:6, a melhor aliança tem sido decretada?",
        "feedbackCorrect": "Certo: decretada sobre melhores promessas.",
        "feedbackWrong": {
            "b": "O texto fala de melhores promessas, não de piores.",
            "c": "Não é remendo da aliança antiga, mas aliança melhor.",
            "d": "O decreto recai sobre promessas, não sobre rituais vazios.",
        },
        "options": opt(
            ("a", "Sobre melhores promessas"),
            ("b", "Sobre piores promessas que as antigas"),
            ("c", "Sobre o mesmo ministério da aliança antiga"),
            ("d", "Sobre rituais sem qualquer promessa"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Hebreus 8:6?",
        "feedbackCorrect": "Certo: ministério, mediador da aliança, depois as promessas.",
        "feedbackWrong": {
            "b": "O mediador vem depois do ministério melhor.",
            "c": "As promessas fecham o versículo, não o abrem.",
        },
        "options": opt(
            ("a", "este tem conseguido tanto melhor ministério"),
            ("b", "quanto é Mediador ainda de uma melhor aliança"),
            ("c", "a qual tem sido decretada sobre melhores promessas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"Mediador ainda de uma melhor ___\"",
        "feedbackCorrect": "Certo: ele é Mediador de uma melhor aliança.",
        "feedbackWrong": {
            "b": "Promessas sustentam a aliança, não esta lacuna.",
            "c": "Ministério já veio antes, não aqui.",
        },
        "template": "Mediador ainda de uma melhor ___",
        "options": opt(("a", "aliança"), ("b", "promessas"), ("c", "ministério")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 8:6 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Cristo é Mediador de uma aliança melhor.",
        "feedbackWrong": {
            "b": "O texto fala de aliança melhor, não de remendo.",
            "c": "As promessas são melhores, não iguais às antigas.",
        },
        "passageA": {"ref": "Hebreus 8:6", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Mediador de aliança melhor"),
            ("b", "Remendo da aliança antiga"),
            ("c", "Promessas iguais às antigas"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O ministério de Cristo é apresentado como igual ao da aliança antiga, sem qualquer melhoria.",
        "feedbackCorrect": "Certo: o texto insiste em melhor ministério e melhor aliança.",
        "feedbackWrong": {"true": "Hebreus 8:6 repete 'melhor' no ministério, na aliança e nas promessas."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 8:6, toque a palavra que falta em \"este tem conseguido tanto melhor ___\"?",
        "feedbackCorrect": "Exato: ele conseguiu melhor ministério.",
        "feedbackWrong": {
            "b": "Aliança vem depois, com o Mediador.",
            "c": "Promessas fecham o versículo, não esta lacuna.",
        },
        "template": "este tem conseguido tanto melhor ___",
        "options": opt(("a", "ministério"), ("b", "aliança"), ("c", "promessas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Hebreus 8:6 relaciona ministério, aliança e promessas?",
        "feedbackCorrect": "Certo: ministério melhor porque é Mediador de aliança com melhores promessas.",
        "feedbackWrong": {
            "b": "O texto não trata a aliança nova como recuo.",
            "c": "Não é o mesmo ministério com outro nome.",
            "d": "As promessas são melhores, não piores.",
        },
        "options": opt(
            ("a", "Ministério melhor, pois media aliança decretada sobre melhores promessas."),
            ("b", "Ministério melhor, mas aliança pior que a de Moisés."),
            ("c", "O mesmo ministério antigo, só com outro nome."),
            ("d", "Aliança nova fundada em promessas inferiores."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Hebreus 8:6?",
        "feedbackCorrect": "Certo: agora, ministério melhor, depois aliança e promessas.",
        "feedbackWrong": {
            "b": "O ministério melhor vem depois do 'agora'.",
            "c": "As promessas sustentam a aliança no fim do versículo.",
        },
        "options": opt(
            ("a", "Mas, agora, este tem conseguido tanto melhor ministério"),
            ("b", "quanto é Mediador ainda de uma melhor aliança"),
            ("c", "decretada sobre melhores promessas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"a qual tem sido decretada sobre melhores ___\"",
        "feedbackCorrect": "Certo: a aliança foi decretada sobre melhores promessas.",
        "feedbackWrong": {
            "a": "Aliança é o que foi decretada, não o fundamento desta lacuna.",
            "c": "Ministério já abriu o versículo.",
        },
        "template": "a qual tem sido decretada sobre melhores ___",
        "options": opt(("a", "aliança"), ("b", "promessas"), ("c", "ministério")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 8:6 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: melhores promessas, não remendo da antiga.",
        "feedbackWrong": {
            "a": "O texto não apresenta Cristo como conserto da lei.",
            "c": "Há melhores promessas, não a mesma base antiga.",
        },
        "passageA": {"ref": "Hebreus 8:6", "text": "Mediador ainda de uma melhor aliança, a qual tem sido decretada sobre melhores promessas"},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Conserto da lei mosaica"),
            ("b", "Melhores promessas, não remendo"),
            ("c", "Mesma base da aliança antiga"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A aliança em Cristo não é conserto da antiga: é ministério, mediação e promessas em grau melhor.",
        "feedbackCorrect": "Certo: o 'melhor' atravessa ministério, aliança e promessas.",
        "feedbackWrong": {"false": "Hebreus 8:6 não descreve remendo, mas aliança melhor."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 8:6, toque a palavra que falta em \"a qual tem sido ___ sobre melhores promessas\"?",
        "feedbackCorrect": "Exato: a aliança tem sido decretada sobre melhores promessas.",
        "feedbackWrong": {
            "a": "Conseguido descreve o ministério, não esta lacuna.",
            "c": "Mediador é o título de Cristo, não o verbo da aliança.",
        },
        "template": "a qual tem sido ___ sobre melhores promessas",
        "options": opt(("a", "conseguido"), ("b", "decretada"), ("c", "Mediador")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 8:6 implica ao chamar Cristo de Mediador de uma melhor aliança?",
        "feedbackCorrect": "Certo: a nova aliança não é remendo; tem base em melhores promessas.",
        "feedbackWrong": {
            "b": "O texto não o reduz a um sacerdote da aliança antiga.",
            "c": "A mediação nova não é inferior à de Moisés.",
            "d": "Há decreto sobre promessas melhores, não abandono de Deus.",
        },
        "options": opt(
            ("a", "A nova aliança tem fundamento próprio: melhores promessas."),
            ("b", "Cristo só administra a aliança de Moisés, sem nada novo."),
            ("c", "A mediação de Cristo é inferior à mediação mosaica."),
            ("d", "Deus revogou toda promessa e deixou o povo sem aliança."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Hebreus 8:6?",
        "feedbackCorrect": "Certo: agora, mediação melhor, depois decreto de promessas.",
        "feedbackWrong": {
            "b": "A mediação explica por que o ministério é melhor.",
            "c": "O decreto sobre promessas fecha o sentido da aliança.",
        },
        "options": opt(
            ("a", "agora este conseguiu melhor ministério"),
            ("b", "é Mediador de uma melhor aliança"),
            ("c", "aliança decretada sobre melhores promessas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"Mas, ___, este tem conseguido tanto melhor ministério\"",
        "feedbackCorrect": "Certo: o contraste abre com 'agora'.",
        "feedbackWrong": {
            "b": "Aliança vem depois, com o Mediador.",
            "c": "Promessas fecham o versículo.",
        },
        "template": "Mas, ___, este tem conseguido tanto melhor ministério",
        "options": opt(("a", "agora"), ("b", "aliança"), ("c", "promessas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 8:6 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Cristo media a aliança melhor, não a antiga.",
        "feedbackWrong": {
            "b": "O texto não o deixa como sacerdote levítico residual.",
            "c": "Há melhores promessas; não é só troca de nome.",
        },
        "passageA": {"ref": "Hebreus 8:6", "text": "quanto é Mediador ainda de uma melhor aliança"},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Cristo media a aliança melhor"),
            ("b", "Cristo restaura o levitismo"),
            ("c", "Só troca o nome da aliança"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M4 hb-04 Hebreus 11:1 ───────────────────────────────────────────
sec, vr, lo, ev, p = "hb-04", "Hebreus 11:1", LO4, ["Hebreus 11:1"], P4

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A fé é a substância das coisas esperadas, a prova das coisas não vistas.",
        "feedbackCorrect": "Certo: é a definição literal de Hebreus 11:1.",
        "feedbackWrong": {"false": "Releia: substância das esperadas, prova das não vistas."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 11:1, toque a palavra que falta em \"Ora, a ___ é a substância das coisas esperadas\"?",
        "feedbackCorrect": "Exato: o sujeito da frase é a fé.",
        "feedbackWrong": {
            "b": "Substância descreve o que a fé é, não o sujeito.",
            "c": "Prova descreve as coisas não vistas, não o sujeito.",
        },
        "template": "Ora, a ___ é a substância das coisas esperadas",
        "options": opt(("a", "fé"), ("b", "substância"), ("c", "prova")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 11:1 afirma que a fé é em relação às coisas esperadas?",
        "feedbackCorrect": "Certo: a fé é a substância das coisas esperadas.",
        "feedbackWrong": {
            "b": "O texto fala de substância, não de recusa da esperança.",
            "c": "A fé prova o não visto; não o substitui por visão.",
            "d": "Não é dúvida, e sim substância e prova.",
        },
        "options": opt(
            ("a", "A substância das coisas esperadas"),
            ("b", "A recusa de qualquer coisa esperada"),
            ("c", "A substituição das coisas não vistas por visão plena"),
            ("d", "A prova de que nada se deve esperar"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Hebreus 11:1?",
        "feedbackCorrect": "Certo: fé, substância do esperado, prova do não visto.",
        "feedbackWrong": {
            "b": "A substância descreve a fé em relação ao esperado.",
            "c": "A prova das não vistas fecha o versículo.",
        },
        "options": opt(
            ("a", "Ora, a fé"),
            ("b", "é a substância das coisas esperadas"),
            ("c", "a prova das coisas não vistas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"Ora, a fé é a ___ das coisas esperadas\"",
        "feedbackCorrect": "Certo: a fé é a substância das coisas esperadas.",
        "feedbackWrong": {
            "b": "Prova descreve as coisas não vistas, não esta lacuna.",
            "c": "Vistas fecha o versículo, não esta palavra.",
        },
        "template": "Ora, a fé é a ___ das coisas esperadas",
        "options": opt(("a", "substância"), ("b", "prova"), ("c", "vistas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 11:1 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a fé dá substância ao que se espera.",
        "feedbackWrong": {
            "b": "A fé não espera visão plena para crer.",
            "c": "Há substância, não vazio, no que se espera.",
        },
        "passageA": {"ref": "Hebreus 11:1", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Substância do que se espera"),
            ("b", "Fé só depois de ver"),
            ("c", "Esperança sem substância"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A fé, em Hebreus 11:1, só vale para o que já se vê, nunca para o que se espera.",
        "feedbackCorrect": "Certo: a fé trata do esperado e do não visto.",
        "feedbackWrong": {"true": "O texto liga fé a coisas esperadas e não vistas."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 11:1, toque a palavra que falta em \"a ___ das coisas não vistas\"?",
        "feedbackCorrect": "Exato: a fé é a prova das coisas não vistas.",
        "feedbackWrong": {
            "a": "Substância descreve as coisas esperadas, não esta lacuna.",
            "c": "Esperadas descreve o primeiro membro, não o segundo.",
        },
        "template": "a ___ das coisas não vistas",
        "options": opt(("a", "substância"), ("b", "prova"), ("c", "esperadas")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Hebreus 11:1 relaciona o esperado e o não visto?",
        "feedbackCorrect": "Certo: a mesma fé dá substância ao esperado e prova o não visto.",
        "feedbackWrong": {
            "b": "O texto não exige ver antes de crer.",
            "c": "Esperado e não visto não se excluem; a fé os une.",
            "d": "A fé não é só sentimento; é substância e prova.",
        },
        "options": opt(
            ("a", "A fé dá substância ao esperado e prova o que não se vê."),
            ("b", "Só se crê no que já está visível e comprovado."),
            ("c", "O esperado e o não visto não têm relação com a fé."),
            ("d", "A fé é só emoção, sem substância nem prova."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Hebreus 11:1?",
        "feedbackCorrect": "Certo: definição da fé, depois esperado, depois não visto.",
        "feedbackWrong": {
            "b": "As coisas esperadas vêm no primeiro membro.",
            "c": "As não vistas fecham a definição.",
        },
        "options": opt(
            ("a", "a fé é a substância"),
            ("b", "das coisas esperadas"),
            ("c", "a prova das coisas não vistas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"a substância das coisas ___\"",
        "feedbackCorrect": "Certo: substância das coisas esperadas.",
        "feedbackWrong": {
            "a": "Vistas fecha o segundo membro, não este.",
            "c": "Prova introduz o segundo membro, não esta lacuna.",
        },
        "template": "a substância das coisas ___",
        "options": opt(("a", "vistas"), ("b", "esperadas"), ("c", "prova")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 11:1 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a fé prova o que ainda não se vê.",
        "feedbackWrong": {
            "a": "A fé não espera a visão para ser prova.",
            "c": "Há prova, não ausência de fundamento.",
        },
        "passageA": {"ref": "Hebreus 11:1", "text": "a prova das coisas não vistas"},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Fé só com evidência visível"),
            ("b", "Prova do que não se vê"),
            ("c", "Fé sem qualquer prova"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A fé que persevera não é palpite: dá substância ao esperado e prova o invisível.",
        "feedbackCorrect": "Certo: substância e prova descrevem fé que sustenta a peregrinação.",
        "feedbackWrong": {"false": "Hebreus 11:1 recusa tratar a fé como vazio ou chute."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 11:1, toque a palavra que falta em \"a prova das coisas não ___\"?",
        "feedbackCorrect": "Exato: prova das coisas não vistas.",
        "feedbackWrong": {
            "a": "Esperadas descreve o primeiro membro.",
            "b": "Fé é o sujeito, não esta lacuna.",
        },
        "template": "a prova das coisas não ___",
        "options": opt(("a", "esperadas"), ("b", "fé"), ("c", "vistas")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 11:1 implica para quem ainda não vê o cumprimento da promessa?",
        "feedbackCorrect": "Certo: a fé já dá substância e prova, antes da visão.",
        "feedbackWrong": {
            "a": "Adiar a fé até ver contradiz o versículo.",
            "c": "A fé não é palpite; tem substância e prova.",
            "d": "O não visto é objeto da fé, não sua negação.",
        },
        "options": opt(
            ("a", "Deve adiar a fé até que tudo se torne visível."),
            ("b", "A fé já dá substância e prova, antes de ver o cumprimento."),
            ("c", "Pode tratar a fé como palpite sem compromisso."),
            ("d", "Deve negar o que não se vê, pois só o visível vale."),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Hebreus 11:1?",
        "feedbackCorrect": "Certo: fé, depois substância da esperança, depois prova do invisível.",
        "feedbackWrong": {
            "b": "A substância interpreta a fé diante do esperado.",
            "c": "A prova do invisível fecha o sentido da perseverança.",
        },
        "options": opt(
            ("a", "a fé"),
            ("b", "substância das coisas esperadas"),
            ("c", "prova das coisas não vistas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"Ora, a fé é a substância das ___ esperadas\"",
        "feedbackCorrect": "Certo: substância das coisas esperadas.",
        "feedbackWrong": {
            "b": "Prova introduz o segundo membro.",
            "c": "Vistas fecha o versículo.",
        },
        "template": "Ora, a fé é a substância das ___ esperadas",
        "options": opt(("a", "coisas"), ("b", "prova"), ("c", "vistas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 11:1 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: fé que persevera dá substância e prova.",
        "feedbackWrong": {
            "b": "A fé não é pausa até a visão.",
            "c": "Há substância; não é vazio piedoso.",
        },
        "passageA": {"ref": "Hebreus 11:1", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Fé que persevera e prova"),
            ("b", "Fé que espera só a visão"),
            ("c", "Esperança vazia, sem substância"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M5 hb-boss Hebreus 12:1–2 ───────────────────────────────────────
sec, vr, lo, ev, p = "hb-boss", "Hebreus 12:1–2", LO5, ["Hebreus 12:1", "Hebreus 12:2"], P5

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Visto que temos ao redor de nós tão grande número de testemunhas, corramos, com perseverança, a carreira que nos está proposta.",
        "feedbackCorrect": "Certo: testemunhas ao redor e carreira com perseverança.",
        "feedbackWrong": {"false": "Releia Hebreus 12:1: corramos com perseverança a carreira."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 12:1–2, toque a palavra que falta em \"fitando os olhos em ___, Autor e Consumador da fé\"?",
        "feedbackCorrect": "Exato: os olhos devem fitar Jesus.",
        "feedbackWrong": {
            "b": "Testemunhas nos cercam, mas o foco é Jesus.",
            "c": "Cruz é o que ele suportou, não o nome desta lacuna.",
        },
        "template": "fitando os olhos em ___, Autor e Consumador da fé",
        "options": opt(("a", "Jesus"), ("b", "testemunhas"), ("c", "cruz")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 12:1–2 afirma que devemos pôr de lado para correr?",
        "feedbackCorrect": "Certo: todo impedimento e o pecado que se nos apega.",
        "feedbackWrong": {
            "b": "O texto manda pôr de lado o pecado, não a perseverança.",
            "c": "Não se largam os olhos em Jesus; fita-se nele.",
            "d": "As testemunhas nos cercam; não as abandonamos para correr.",
        },
        "options": opt(
            ("a", "Todo impedimento e o pecado que se nos apega"),
            ("b", "A perseverança, para correr mais leve"),
            ("c", "Os olhos fitos em Jesus"),
            ("d", "O grande número de testemunhas ao redor"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Hebreus 12:1–2?",
        "feedbackCorrect": "Certo: testemunhas, depois o despojar, depois o correr fitando Jesus.",
        "feedbackWrong": {
            "b": "Pôr de lado o impedimento vem antes de correr.",
            "c": "Fitar Jesus acompanha a carreira, no fim da abertura.",
        },
        "options": opt(
            ("a", "temos ao redor de nós tão grande número de testemunhas"),
            ("b", "pondo de lado todo impedimento e o pecado que se nos apega"),
            ("c", "corramos, com perseverança, a carreira, fitando os olhos em Jesus"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"corramos, com ___, a carreira que nos está proposta\"",
        "feedbackCorrect": "Certo: a carreira se corre com perseverança.",
        "feedbackWrong": {
            "b": "Ignomínia é o que Jesus desprezou, não o modo de correr.",
            "c": "Cruz é o que ele suportou, não esta lacuna.",
        },
        "template": "corramos, com ___, a carreira que nos está proposta",
        "options": opt(("a", "perseverança"), ("b", "ignomínia"), ("c", "cruz")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 12:1–2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: corramos fitando Jesus, Autor e Consumador.",
        "feedbackWrong": {
            "b": "O foco não são as testemunhas, e sim Jesus.",
            "c": "A carreira pede perseverança, não abandono.",
        },
        "passageA": {"ref": "Hebreus 12:1–2", "text": "corramos, com perseverança, a carreira que nos está proposta, fitando os olhos em Jesus, Autor e Consumador da fé"},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Correr fitando Jesus"),
            ("b", "Correr fitando as testemunhas"),
            ("c", "Abandonar a carreira proposta"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A carreira se corre olhando para o impedimento e o pecado, não para Jesus.",
        "feedbackCorrect": "Certo: põe-se de lado o pecado e fita-se Jesus.",
        "feedbackWrong": {"true": "O texto manda pôr de lado o pecado e fitar Jesus."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 12:1–2, toque a palavra que falta em \"Jesus, Autor e ___ da fé\"?",
        "feedbackCorrect": "Exato: Jesus é Autor e Consumador da fé.",
        "feedbackWrong": {
            "a": "Testemunhas nos cercam, não este título.",
            "c": "Impedimento é o que se põe de lado, não o título de Jesus.",
        },
        "template": "Jesus, Autor e ___ da fé",
        "options": opt(("a", "testemunhas"), ("b", "Consumador"), ("c", "impedimento")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Hebreus 12:1–2 relaciona as testemunhas e o olhar para Jesus?",
        "feedbackCorrect": "Certo: as testemunhas cercam, mas os olhos fitam Jesus.",
        "feedbackWrong": {
            "b": "As testemunhas não substituem Jesus como foco.",
            "c": "A cruz de Jesus não é motivo para largar a carreira.",
            "d": "O pecado se põe de lado; não se leva junto na corrida.",
        },
        "options": opt(
            ("a", "As testemunhas cercam; o foco da carreira é Jesus."),
            ("b", "Devemos fitar as testemunhas e esquecer Jesus."),
            ("c", "A cruz de Jesus torna inútil correr a carreira."),
            ("d", "O pecado que se apega deve ser levado na corrida."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Hebreus 12:1–2?",
        "feedbackCorrect": "Certo: fitar Jesus, depois a cruz, depois o trono.",
        "feedbackWrong": {
            "b": "A cruz vem depois de nomear o Autor e Consumador.",
            "c": "O trono fecha o percurso de Jesus, não o abre.",
        },
        "options": opt(
            ("a", "fitando os olhos em Jesus, Autor e Consumador da fé"),
            ("b", "pelo gozo que lhe foi proposto, suportou a cruz"),
            ("c", "está sentado à destra do trono de Deus"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"pondo de lado todo impedimento e o ___ que se nos apega\"",
        "feedbackCorrect": "Certo: além do impedimento, o pecado que se apega.",
        "feedbackWrong": {
            "a": "Gozo é o que foi proposto a Jesus, não o que se apega a nós.",
            "c": "Trono é o destino de Jesus, não o que se apega.",
        },
        "template": "pondo de lado todo impedimento e o ___ que se nos apega",
        "options": opt(("a", "gozo"), ("b", "pecado"), ("c", "trono")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 12:1–2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Jesus é Autor e Consumador da fé.",
        "feedbackWrong": {
            "a": "O texto não deixa a fé sem Autor nem Consumador.",
            "c": "As testemunhas cercam; quem consome a fé é Jesus.",
        },
        "passageA": {"ref": "Hebreus 12:2", "text": "fitando os olhos em Jesus, Autor e Consumador da fé"},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Fé sem Autor nem Consumador"),
            ("b", "Jesus Autor e Consumador"),
            ("c", "Testemunhas como Consumador"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Jesus suportou a cruz pelo gozo que lhe foi proposto e agora está sentado à destra do trono de Deus.",
        "feedbackCorrect": "Certo: cruz e trono no mesmo percurso do Autor da fé.",
        "feedbackWrong": {"false": "Hebreus 12:2 une gozo proposto, cruz e destra do trono."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Hebreus 12:1–2, toque a palavra que falta em \"suportou a ___, desprezando a ignomínia\"?",
        "feedbackCorrect": "Exato: ele suportou a cruz, desprezando a ignomínia.",
        "feedbackWrong": {
            "b": "Ignomínia é o que ele desprezou, não o que suportou.",
            "c": "Trono é o destino depois da cruz.",
        },
        "template": "suportou a ___, desprezando a ignomínia",
        "options": opt(("a", "cruz"), ("b", "ignomínia"), ("c", "trono")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 12:1–2 implica ao unir a cruz de Jesus e o trono de Deus?",
        "feedbackCorrect": "Certo: a carreira fita quem foi da cruz ao trono.",
        "feedbackWrong": {
            "a": "A cruz não é o fim; ele está à destra.",
            "c": "O gozo proposto não apaga a cruz; ele a suportou.",
            "d": "A ignomínia foi desprezada, não evitada por recusar a cruz.",
        },
        "options": opt(
            ("a", "A cruz foi o fim da história; não há trono depois."),
            ("b", "A carreira fita quem suportou a cruz e está no trono."),
            ("c", "O gozo proposto dispensou Jesus de sofrer a cruz."),
            ("d", "A ignomínia o impediu de sentar-se à destra."),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Hebreus 12:1–2?",
        "feedbackCorrect": "Certo: carreira, cruz de Jesus, depois o trono.",
        "feedbackWrong": {
            "b": "A cruz interpreta o Autor que fitamos na carreira.",
            "c": "O trono consome o percurso: cruz não é a última palavra.",
        },
        "options": opt(
            ("a", "corramos a carreira proposta, fitando Jesus"),
            ("b", "suportou a cruz, desprezando a ignomínia"),
            ("c", "está sentado à destra do trono de Deus"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"e está sentado à destra do ___ de Deus\"",
        "feedbackCorrect": "Certo: sentado à destra do trono de Deus.",
        "feedbackWrong": {
            "a": "Cruz é o que ele suportou, não este assento.",
            "c": "Gozo foi o que lhe foi proposto, não o lugar do trono.",
        },
        "template": "e está sentado à destra do ___ de Deus",
        "options": opt(("a", "cruz"), ("b", "trono"), ("c", "gozo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Hebreus 12:1–2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: revisão da trilha — cruz e trono, fitar Jesus.",
        "feedbackWrong": {
            "b": "A cruz não cancela o trono; os dois se unem.",
            "c": "A carreira continua; não se abandona o percurso.",
        },
        "passageA": {"ref": "Hebreus 12:2", "text": "suportou a cruz, desprezando a ignomínia, e está sentado à destra do trono de Deus"},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Cruz e trono, fitar Jesus"),
            ("b", "Cruz sem trono, história fechada"),
            ("c", "Trono sem carreira a correr"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]


def main():
    out = Path(__file__).with_name("hebreus.json")
    out.write_text(json.dumps(Qs, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{out} {len(Qs)}")


if __name__ == "__main__":
    main()
