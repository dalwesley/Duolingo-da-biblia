#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Gera perguntas-v2/apocalipse.json — 144 perguntas (8×18)."""
import json
from pathlib import Path

TF = [{"id": "true", "text": "Verdadeiro"}, {"id": "false", "text": "Falso"}]
SK = {"semente": "observe", "caminhada": "understand", "profundezas": "interpret"}
SHORT = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}

# ── Textos TB (verbatim do brief) ───────────────────────────────────
P1 = (
    "Quem tem ouvidos, ouça o que o Espírito diz às igrejas. "
    "Ao vencedor, darei a comer da árvore da vida, que está no Paraíso de Deus."
)
P2 = (
    "Quando o vi, caí aos seus pés como morto; e ele pôs a sua destra sobre mim, "
    "dizendo: Não temas; eu sou o primeiro, e o último, e o que vivo; fui morto, "
    "mas eis que estou vivo pelos séculos dos séculos e tenho as chaves da morte e do Hades."
)
P3 = (
    "E cantavam um novo cântico, dizendo: Digno és de receber o livro e de abrir "
    "os seus selos, porque foste morto e compraste para Deus, com o teu sangue, "
    "homens de toda tribo, e língua, e povo, e nação, e lhes fizeste, para nosso Deus, "
    "reino e sacerdotes, e reinarão sobre a terra."
)
# Boss 01: 2:7 + 5:9 (sem o fecho de 5:10)
P3_BOSS = (
    "E cantavam um novo cântico, dizendo: Digno és de receber o livro e de abrir "
    "os seus selos, porque foste morto e compraste para Deus, com o teu sangue, "
    "homens de toda tribo, e língua, e povo, e nação,"
)
P4 = f"{P1} {P3_BOSS}"

P5 = (
    "Depois dessas coisas, olhei, e eis uma grande multidão que ninguém podia contar, "
    "de toda nação e de todas as tribos, povos e línguas, que estavam em pé diante do "
    "trono e diante do Cordeiro, cobertos de vestiduras brancas com palmas nas mãos; "
    "e clamavam com uma grande voz: Salvação a nosso Deus que está sentado sobre o "
    "trono, e ao Cordeiro."
)
P6 = (
    "Ouvi outra voz do céu, dizendo: Sai dela, povo meu, para não serdes participantes "
    "dos seus pecados, nem terdes parte nas suas pragas;"
)
P7 = (
    "Ouvi uma grande voz, vinda do trono, dizendo: Eis o tabernáculo de Deus está com "
    "os homens, e ele habitará com eles; eles serão o seu povo, e Deus mesmo estará "
    "com eles. e enxugará toda lágrima dos olhos deles. Não haverá mais morte, nem "
    "haverá mais pranto, nem choro, nem dor, porque as primeiras coisas são passadas."
)
# Boss 02: 7:9 + 21:3–4 (7:9 sem o clamor de 7:10)
P5_BOSS = (
    "Depois dessas coisas, olhei, e eis uma grande multidão que ninguém podia contar, "
    "de toda nação e de todas as tribos, povos e línguas, que estavam em pé diante do "
    "trono e diante do Cordeiro, cobertos de vestiduras brancas com palmas nas mãos;"
)
P8 = f"{P5_BOSS} {P7}"

I1 = "Cartas: o Espírito fala às igrejas; o vencedor come da árvore da vida."
I2 = "Filho do Homem: morto e vivo; tem as chaves da morte e do Hades."
I3 = "Cordeiro no trono: digno porque foi morto e comprou com sangue."
I4 = "Cartas e trono: ouvir o Espírito e adorar o Cordeiro morto."
I5 = "Selos e testemunho: multidão incontável louva a salvação ao Deus e ao Cordeiro."
I6 = "Babilônia: sai dela, povo meu — separação dos pecados."
I7 = "Novo céu e terra: Deus habita com os homens; morte e dor passam."
I8 = "Esperança final: multidão salva e Deus enxuga toda lágrima."

LO1 = "Sair sabendo que o Espírito fala às igrejas e que o vencedor recebe a árvore da vida no Paraíso de Deus."
LO2 = "Sair sabendo que o Filho do Homem foi morto e está vivo, e tem as chaves da morte e do Hades."
LO3 = "Sair sabendo que o Cordeiro é digno porque foi morto e comprou para Deus, com seu sangue, gente de toda tribo."
LO4 = "Sair sabendo que Apocalipse une ouvir o Espírito nas cartas e adorar o Cordeiro morto no trono."
LO5 = "Sair sabendo que a multidão incontável louva a salvação ao Deus do trono e ao Cordeiro."
LO6 = "Sair sabendo que Deus chama seu povo a sair de Babilônia para não participar dos pecados nem das pragas."
LO7 = "Sair sabendo que Deus habitará com os homens e que morte, pranto, choro e dor passam."
LO8 = "Sair sabendo que a esperança final une a multidão salva e Deus enxugando toda lágrima."


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
        "trail": "apocalipse",
        "section": section,
        "id": f"apocalipse-{SHORT[diff]}-{section}-{nn}",
        "passageText": passage,
    }


def merge(b, extra):
    d = dict(b)
    d.update(extra)
    return q(**d)


Qs = []

# ═══════════════════════════════════════════════════════════════════
# M1 apo-01-cartas | Apocalipse 2:7
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "apo-01-cartas",
    "Apocalipse 2:7",
    LO1,
    ["Apocalipse 2:7"],
    P1,
    I1,
)

Qs += [
    # —— SEMENTE ——
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O Espírito diz às igrejas, e quem tem ouvidos deve ouvir.",
        "feedbackCorrect": "Certo: o chamado a ouvir o Espírito está em Apocalipse 2:7.",
        "feedbackWrong": {"false": "Releia: o texto manda ouvir o que o Espírito diz às igrejas."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 2:7, toque a palavra que falta em "Ao ___, darei a comer da árvore da vida"?',
        "feedbackCorrect": "Exato: a promessa é ao vencedor.",
        "feedbackWrong": {
            "b": "Espírito é quem fala às igrejas, não o destinatário da promessa.",
            "c": "Igrejas ouvem; o prêmio da árvore é ao vencedor.",
        },
        "template": "Ao ___, darei a comer da árvore da vida",
        "options": opt(("a", "vencedor"), ("b", "Espírito"), ("c", "igrejas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 2:7 promete dar ao vencedor?",
        "feedbackCorrect": "Certo: o vencedor comerá da árvore da vida no Paraíso de Deus.",
        "feedbackWrong": {
            "b": "O texto não promete ouro nem poder imperial.",
            "c": "A árvore da vida está no Paraíso de Deus, não sob domínio humano.",
            "d": "O prêmio é comer da árvore da vida, não silêncio do Espírito.",
        },
        "options": opt(
            ("a", "Comer da árvore da vida, no Paraíso de Deus"),
            ("b", "Ouro e domínio sobre as nações pagãs"),
            ("c", "Uma árvore plantada só na terra dos homens"),
            ("d", "Que o Espírito deixe de falar às igrejas"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Apocalipse 2:7?",
        "feedbackCorrect": "Certo: ouvir o Espírito, depois a promessa ao vencedor.",
        "feedbackWrong": {
            "b": "Ouvir o Espírito vem antes da promessa ao vencedor.",
            "c": "A árvore da vida fecha o trecho, no Paraíso de Deus.",
        },
        "options": opt(
            ("a", "Quem tem ouvidos, ouça o que o Espírito diz às igrejas"),
            ("b", "Ao vencedor, darei a comer da árvore da vida"),
            ("c", "que está no Paraíso de Deus"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "que está no ___ de Deus"',
        "feedbackCorrect": "Certo: a árvore da vida está no Paraíso de Deus.",
        "feedbackWrong": {
            "b": "Igrejas ouvem o Espírito; o lugar da árvore é o Paraíso.",
            "c": "Espírito fala; a árvore está no Paraíso de Deus.",
        },
        "template": "que está no ___ de Deus",
        "options": opt(("a", "Paraíso"), ("b", "igrejas"), ("c", "Espírito")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 2:7 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Espírito fala e o vencedor come da árvore da vida.",
        "feedbackWrong": {
            "b": "O Espírito não cala as igrejas; ele fala a elas.",
            "c": "A árvore da vida é prometida, não negada.",
        },
        "passageA": {"ref": "Apocalipse 2:7", "text": P1},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Espírito às igrejas"),
            ("b", "Espírito em silêncio"),
            ("c", "Árvore negada ao vencedor"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    # —— CAMINHADA ——
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Apocalipse 2:7, a mensagem do Espírito é dirigida às igrejas, não a um ouvinte isolado do povo de Deus.",
        "feedbackCorrect": "Certo: o Espírito diz às igrejas.",
        "feedbackWrong": {"false": "O texto diz: o que o Espírito diz às igrejas."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 2:7, toque a palavra que falta em "ouça o que o ___ diz às igrejas"?',
        "feedbackCorrect": "Exato: quem fala às igrejas é o Espírito.",
        "feedbackWrong": {
            "a": "Vencedor recebe a promessa; quem fala é o Espírito.",
            "c": "Paraíso é o lugar da árvore, não quem fala.",
        },
        "template": "ouça o que o ___ diz às igrejas",
        "options": opt(("a", "vencedor"), ("b", "Espírito"), ("c", "Paraíso")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Apocalipse 2:7 liga a escuta do Espírito e a recompensa do vencedor?",
        "feedbackCorrect": "Certo: ouvir o Espírito e vencer se unem na mesma palavra às igrejas.",
        "feedbackWrong": {
            "a": "O texto une chamada e promessa, não as separa.",
            "c": "A árvore da vida é para o vencedor que ouve, não um prêmio paralelo sem escuta.",
            "d": "As igrejas são o alvo da fala do Espírito.",
        },
        "options": opt(
            ("a", "A escuta é opcional; só importa vencer sem ouvir"),
            ("b", "Quem ouve o Espírito às igrejas também recebe a promessa ao vencedor"),
            ("c", "A árvore da vida substitui qualquer palavra do Espírito"),
            ("d", "O Espírito fala só a reis, nunca às igrejas"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Apocalipse 2:7?",
        "feedbackCorrect": "Certo: ouvidos, fala às igrejas, promessa da árvore.",
        "feedbackWrong": {
            "b": "Ter ouvidos prepara o ouvir o que o Espírito diz.",
            "c": "A promessa ao vencedor vem depois do chamado a ouvir.",
        },
        "options": opt(
            ("a", "Quem tem ouvidos"),
            ("b", "ouça o que o Espírito diz às igrejas"),
            ("c", "Ao vencedor, darei a comer da árvore da vida"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "darei a comer da ___ da vida"',
        "feedbackCorrect": "Certo: é a árvore da vida.",
        "feedbackWrong": {
            "a": "Igrejas ouvem; a lacuna pede árvore.",
            "c": "Paraíso localiza a árvore; a lacuna é árvore.",
        },
        "template": "darei a comer da ___ da vida",
        "options": opt(("a", "igrejas"), ("b", "árvore"), ("c", "Paraíso")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 2:7 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: ouvir e vencer se encontram na árvore da vida.",
        "feedbackWrong": {
            "a": "O Espírito não é silenciado; ele fala às igrejas.",
            "c": "A promessa não é poder político, e sim a árvore da vida.",
        },
        "passageA": {"ref": "Apocalipse 2:7", "text": P1},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Igrejas sem escuta"),
            ("b", "Vencedor e árvore"),
            ("c", "Poder sem Paraíso"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    # —— PROFUNDEZAS ——
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Apocalipse 2:7 apresenta a árvore da vida como prêmio do vencedor no Paraíso de Deus, sustentando esperança escatológica, não só conselho moral genérico.",
        "feedbackCorrect": "Certo: a árvore no Paraíso aponta à vida restaurada de Deus.",
        "feedbackWrong": {"false": "O texto liga vencer à árvore da vida no Paraíso de Deus."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 2:7, toque a palavra que falta em "darei a ___ da árvore da vida"?',
        "feedbackCorrect": "Exato: o vencedor receberá a comer.",
        "feedbackWrong": {
            "a": "Ouça é o imperativo inicial; a lacuna é comer.",
            "c": "Ouvidos abrem a escuta; a promessa é comer.",
        },
        "template": "darei a ___ da árvore da vida",
        "options": opt(("a", "ouça"), ("b", "comer"), ("c", "ouvidos")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura teológica Apocalipse 2:7 sustenta sobre a igreja sob pressão?",
        "feedbackCorrect": "Certo: a igreja é chamada a ouvir o Espírito e a vencer rumo à vida de Deus.",
        "feedbackWrong": {
            "a": "O Espírito não abandona as igrejas; ele fala a elas.",
            "c": "O Paraíso de Deus não é escapismo privado sem escuta eclesial.",
            "d": "Vencer não anula a escuta; ambos aparecem no mesmo versículo.",
        },
        "options": opt(
            ("a", "O Espírito deixou de falar às igrejas sob pressão"),
            ("b", "Ouvir o Espírito e vencer abrem caminho à árvore da vida"),
            ("c", "Só importa o Paraíso individual, sem palavra às igrejas"),
            ("d", "Vencer dispensa ouvir o que o Espírito diz"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Apocalipse 2:7?",
        "feedbackCorrect": "Certo: escuta eclesial, vitória e vida no Paraíso.",
        "feedbackWrong": {
            "b": "A fala às igrejas fundamenta a resposta do vencedor.",
            "c": "A árvore no Paraíso coroa o sentido da promessa.",
        },
        "options": opt(
            ("a", "O Espírito diz às igrejas"),
            ("b", "Ao vencedor é dada a árvore da vida"),
            ("c", "A árvore está no Paraíso de Deus"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "ouça o que o Espírito diz às ___"',
        "feedbackCorrect": "Certo: o Espírito diz às igrejas.",
        "feedbackWrong": {
            "a": "Árvore é o prêmio; o alvo da fala são as igrejas.",
            "c": "Paraíso localiza a árvore; a fala é às igrejas.",
        },
        "template": "ouça o que o Espírito diz às ___",
        "options": opt(("a", "árvore"), ("b", "igrejas"), ("c", "Paraíso")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 2:7 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: escuta eclesial e vida no Paraíso se encontram.",
        "feedbackWrong": {
            "a": "Não é vitória sem palavra; o Espírito fala primeiro.",
            "c": "Não é só moralismo; há promessa da árvore da vida.",
        },
        "passageA": {"ref": "Apocalipse 2:7", "text": P1},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Vitória sem escuta"),
            ("b", "Escuta e vida"),
            ("c", "Só conselho moral"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M2 apo-04-visao | Apocalipse 1:17–18
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "apo-04-visao",
    "Apocalipse 1:17–18",
    LO2,
    ["Apocalipse 1:17", "Apocalipse 1:18"],
    P2,
    I2,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "João caiu aos pés dele como morto, ao vê-lo.",
        "feedbackCorrect": "Certo: João caiu aos pés dele como morto.",
        "feedbackWrong": {"false": "Releia Apocalipse 1:17: caí aos seus pés como morto."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 1:17–18, toque a palavra que falta em "Não ___; eu sou o primeiro, e o último"?',
        "feedbackCorrect": "Exato: a ordem é Não temas.",
        "feedbackWrong": {
            "b": "Vivo descreve quem fala; a ordem é Não temas.",
            "c": "Morto descreve o passado; a ordem é Não temas.",
        },
        "template": "Não ___; eu sou o primeiro, e o último",
        "options": opt(("a", "temas"), ("b", "vivo"), ("c", "morto")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 1:17–18 afirma que ele tem?",
        "feedbackCorrect": "Certo: ele tem as chaves da morte e do Hades.",
        "feedbackWrong": {
            "b": "O texto não fala de chaves do templo de Jerusalém.",
            "c": "Ele tem as chaves da morte e do Hades, não as entrega a César.",
            "d": "As chaves são da morte e do Hades, não de um cofre humano.",
        },
        "options": opt(
            ("a", "As chaves da morte e do Hades"),
            ("b", "As chaves do templo de Jerusalém"),
            ("c", "As chaves do império de César"),
            ("d", "As chaves de um cofre de ouro"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Apocalipse 1:17–18?",
        "feedbackCorrect": "Certo: queda, destra, depois Não temas.",
        "feedbackWrong": {
            "b": "A destra sobre João vem depois da queda como morto.",
            "c": "Não temas segue o gesto da destra.",
        },
        "options": opt(
            ("a", "Quando o vi, caí aos seus pés como morto"),
            ("b", "ele pôs a sua destra sobre mim"),
            ("c", "dizendo: Não temas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "tenho as ___ da morte e do Hades"',
        "feedbackCorrect": "Certo: ele tem as chaves da morte e do Hades.",
        "feedbackWrong": {
            "b": "Destra é a mão que toca João; a lacuna é chaves.",
            "c": "Séculos descrevem a vida eterna; a lacuna é chaves.",
        },
        "template": "tenho as ___ da morte e do Hades",
        "options": opt(("a", "chaves"), ("b", "destra"), ("c", "séculos")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 1:17–18 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: morto e vivo, com as chaves da morte e do Hades.",
        "feedbackWrong": {
            "b": "Ele não permanece só morto; está vivo.",
            "c": "Ele tem as chaves; não as perde.",
        },
        "passageA": {"ref": "Apocalipse 1:17–18", "text": P2},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Morto e vivo"),
            ("b", "Só morto para sempre"),
            ("c", "Sem chaves da morte"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Apocalipse 1:17–18, o mesmo que foi morto declara estar vivo pelos séculos dos séculos.",
        "feedbackCorrect": "Certo: fui morto, mas eis que estou vivo pelos séculos dos séculos.",
        "feedbackWrong": {"false": "O texto une morte passada e vida pelos séculos."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 1:17–18, toque a palavra que falta em "eu sou o primeiro, e o ___"?',
        "feedbackCorrect": "Exato: ele é o primeiro e o último.",
        "feedbackWrong": {
            "a": "Vivo vem depois; aqui a lacuna é último.",
            "c": "Hades entra com as chaves; a lacuna é último.",
        },
        "template": "eu sou o primeiro, e o ___",
        "options": opt(("a", "vivo"), ("b", "último"), ("c", "Hades")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Apocalipse 1:17–18 encadeia o medo de João e a identidade de quem fala?",
        "feedbackCorrect": "Certo: após a queda, ele põe a destra e se revela primeiro, último e vivo.",
        "feedbackWrong": {
            "a": "O toque da destra acompanha Não temas, não o abandono.",
            "c": "Ele se identifica como vivo, não como apenas um fantasma.",
            "d": "As chaves da morte e do Hades confirmam domínio, não impotência.",
        },
        "options": opt(
            ("a", "João cai e é abandonado sem palavra de ânimo"),
            ("b", "Após cair como morto, ouve Não temas e a autoapresentação do vivo"),
            ("c", "Quem fala só admite ter sido morto, sem vida presente"),
            ("d", "As chaves da morte e do Hades ficam fora do alcance dele"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Apocalipse 1:17–18?",
        "feedbackCorrect": "Certo: identidade, morte passada, vida e chaves.",
        "feedbackWrong": {
            "b": "Fui morto segue a declaração de ser o que vivo.",
            "c": "As chaves fecham o trecho após a vida pelos séculos.",
        },
        "options": opt(
            ("a", "eu sou o primeiro, e o último, e o que vivo"),
            ("b", "fui morto, mas eis que estou vivo pelos séculos dos séculos"),
            ("c", "tenho as chaves da morte e do Hades"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "fui ___, mas eis que estou vivo pelos séculos dos séculos"',
        "feedbackCorrect": "Certo: fui morto, mas estou vivo.",
        "feedbackWrong": {
            "a": "Primeiro é título; a lacuna é morto.",
            "c": "Último é título; a lacuna é morto.",
        },
        "template": "fui ___, mas eis que estou vivo pelos séculos dos séculos",
        "options": opt(("a", "primeiro"), ("b", "morto"), ("c", "último")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 1:17–18 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: as chaves mostram domínio sobre morte e Hades.",
        "feedbackWrong": {
            "a": "Ele não fica preso à morte; está vivo.",
            "c": "Não temas acompanha a revelação, não a cancela.",
        },
        "passageA": {"ref": "Apocalipse 1:17–18", "text": P2},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Preso só à morte"),
            ("b", "Chaves da morte"),
            ("c", "Medo sem palavra"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Apocalipse 1:17–18 apresenta o Senhor vivo com autoridade sobre a morte e o Hades, de modo que o medo de João encontra resposta na identidade de Cristo, não em fuga da visão.",
        "feedbackCorrect": "Certo: Não temas se apoia em quem ele é e no que tem.",
        "feedbackWrong": {"false": "O texto une Não temas, vida e chaves da morte e do Hades."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 1:17–18, toque a palavra que falta em "tenho as chaves da morte e do ___"?',
        "feedbackCorrect": "Exato: as chaves são da morte e do Hades.",
        "feedbackWrong": {
            "a": "Destra é a mão que toca; a lacuna é Hades.",
            "c": "Séculos descrevem a duração da vida; a lacuna é Hades.",
        },
        "template": "tenho as chaves da morte e do ___",
        "options": opt(("a", "destra"), ("b", "Hades"), ("c", "séculos")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual implicação Apocalipse 1:17–18 sustenta para quem teme a morte?",
        "feedbackCorrect": "Certo: quem tem as chaves da morte e do Hades pode dizer Não temas.",
        "feedbackWrong": {
            "a": "Ele não permanece morto; está vivo pelos séculos.",
            "c": "As chaves estão com ele, não com o império.",
            "d": "A destra e a palavra confrontam o medo, não o ignoram.",
        },
        "options": opt(
            ("a", "A morte teve a última palavra sobre ele"),
            ("b", "O vivo com as chaves da morte e do Hades sustenta Não temas"),
            ("c", "Só o poder imperial controla a morte e o Hades"),
            ("d", "A visão gloriosa deixa João sem consolo possível"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Apocalipse 1:17–18?",
        "feedbackCorrect": "Certo: medo, palavra, domínio sobre a morte.",
        "feedbackWrong": {
            "b": "Não temas responde à queda como morto.",
            "c": "As chaves explicam por que o medo pode ceder.",
        },
        "options": opt(
            ("a", "João cai como morto"),
            ("b", "Não temas: eu sou o primeiro e o último"),
            ("c", "tenho as chaves da morte e do Hades"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "estou vivo pelos ___ dos séculos"',
        "feedbackCorrect": "Certo: vivo pelos séculos dos séculos.",
        "feedbackWrong": {
            "a": "Chaves são o que ele tem; a lacuna é séculos.",
            "c": "Hades entra com as chaves; a lacuna é séculos.",
        },
        "template": "estou vivo pelos ___ dos séculos",
        "options": opt(("a", "chaves"), ("b", "séculos"), ("c", "Hades")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 1:17–18 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Filho do Homem vivo governa morte e Hades.",
        "feedbackWrong": {
            "a": "Ele não é só memória; está vivo.",
            "c": "Não temas não é vazio; vem com identidade e chaves.",
        },
        "passageA": {"ref": "Apocalipse 1:17–18", "text": P2},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Morto sem vida"),
            ("b", "Vivo com chaves"),
            ("c", "Medo sem Cristo"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M3 apo-02-cordeiro | Apocalipse 5:9–10
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "apo-02-cordeiro",
    "Apocalipse 5:9–10",
    LO3,
    ["Apocalipse 5:9", "Apocalipse 5:10"],
    P3,
    I3,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "E cantavam um novo cântico, dizendo: Digno és de receber o livro e de abrir os seus selos.",
        "feedbackCorrect": "Certo: o novo cântico declara a dignidade do Cordeiro.",
        "feedbackWrong": {"false": "Releia: cantavam um novo cântico: Digno és…"},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 5:9–10, toque a palavra que falta em "porque foste ___ e compraste para Deus"?',
        "feedbackCorrect": "Exato: ele é digno porque foi morto.",
        "feedbackWrong": {
            "b": "Sangue é o meio da compra; a lacuna é morto.",
            "c": "Livro é o que ele recebe; a razão é ter sido morto.",
        },
        "template": "porque foste ___ e compraste para Deus",
        "options": opt(("a", "morto"), ("b", "sangue"), ("c", "livro")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Com o que Apocalipse 5:9 diz que o Cordeiro comprou homens para Deus?",
        "feedbackCorrect": "Certo: com o teu sangue.",
        "feedbackWrong": {
            "b": "O texto aponta ao sangue, não a ouro.",
            "c": "Não é força militar; é o sangue do Cordeiro.",
            "d": "A compra é com sangue, não com leis novas.",
        },
        "options": opt(
            ("a", "Com o teu sangue"),
            ("b", "Com ouro e prata das nações"),
            ("c", "Com exércitos de anjos em guerra"),
            ("d", "Com novas leis sem sacrifício"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Apocalipse 5:9–10?",
        "feedbackCorrect": "Certo: dignidade, morte e compra, depois reino e sacerdotes.",
        "feedbackWrong": {
            "b": "A morte e a compra fundamentam a dignidade declarada.",
            "c": "Reino e sacerdotes vêm depois da compra com sangue.",
        },
        "options": opt(
            ("a", "Digno és de receber o livro e de abrir os seus selos"),
            ("b", "porque foste morto e compraste para Deus, com o teu sangue"),
            ("c", "lhes fizeste, para nosso Deus, reino e sacerdotes"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "compraste para Deus, com o teu ___"',
        "feedbackCorrect": "Certo: a compra é com o teu sangue.",
        "feedbackWrong": {
            "b": "Selos são abertos pelo digno; a lacuna é sangue.",
            "c": "Tribo descreve os comprados; a lacuna é sangue.",
        },
        "template": "compraste para Deus, com o teu ___",
        "options": opt(("a", "sangue"), ("b", "selos"), ("c", "tribo")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 5:9–10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: digno porque foi morto e comprou com sangue.",
        "feedbackWrong": {
            "b": "A dignidade não prescinde da morte; vem por ela.",
            "c": "A compra é com sangue, não sem custo.",
        },
        "passageA": {"ref": "Apocalipse 5:9–10", "text": P3},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Digno pelo sangue"),
            ("b", "Digno sem a morte"),
            ("c", "Compra sem sangue"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Apocalipse 5:9, a compra com sangue alcança homens de toda tribo, e língua, e povo, e nação.",
        "feedbackCorrect": "Certo: o alcance é universal — tribo, língua, povo e nação.",
        "feedbackWrong": {"false": "O texto lista tribo, língua, povo e nação."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 5:9–10, toque a palavra que falta em "Digno és de receber o ___ e de abrir os seus selos"?',
        "feedbackCorrect": "Exato: ele recebe o livro.",
        "feedbackWrong": {
            "a": "Sangue compra; o objeto recebido é o livro.",
            "c": "Nação descreve os comprados; a lacuna é livro.",
        },
        "template": "Digno és de receber o ___ e de abrir os seus selos",
        "options": opt(("a", "sangue"), ("b", "livro"), ("c", "nação")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Apocalipse 5:9–10 liga a morte do Cordeiro e o destino dos comprados?",
        "feedbackCorrect": "Certo: morto e comprados, tornam-se reino e sacerdotes para Deus.",
        "feedbackWrong": {
            "a": "A morte não impede a dignidade; é a razão dela.",
            "c": "O texto não limita a compra a uma só etnia.",
            "d": "Reinar sobre a terra segue a constituição em reino e sacerdotes.",
        },
        "options": opt(
            ("a", "A morte anula qualquer direito de abrir o livro"),
            ("b", "Por ter sido morto e comprado com sangue, fez reino e sacerdotes"),
            ("c", "Só uma tribo foi comprada; as demais ficam de fora"),
            ("d", "Reino e sacerdotes substituem qualquer reinado futuro"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Apocalipse 5:9–10?",
        "feedbackCorrect": "Certo: morto, comprados de toda gente, reino e reinado.",
        "feedbackWrong": {
            "b": "A compra multiétnica segue a morte.",
            "c": "Reino, sacerdotes e reinado fecham o cântico.",
        },
        "options": opt(
            ("a", "foste morto"),
            ("b", "compraste… homens de toda tribo, e língua, e povo, e nação"),
            ("c", "lhes fizeste… reino e sacerdotes, e reinarão sobre a terra"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "lhes fizeste, para nosso Deus, ___ e sacerdotes"',
        "feedbackCorrect": "Certo: reino e sacerdotes.",
        "feedbackWrong": {
            "b": "Selos são abertos; a lacuna é reino.",
            "c": "Livro é recebido; a lacuna é reino.",
        },
        "template": "lhes fizeste, para nosso Deus, ___ e sacerdotes",
        "options": opt(("a", "reino"), ("b", "selos"), ("c", "livro")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 5:9–10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Cordeiro morto compra e constitui povo para Deus.",
        "feedbackWrong": {
            "a": "A dignidade não vem de poder sem cruz.",
            "c": "A compra não fica sem povo; há reino e sacerdotes.",
        },
        "passageA": {"ref": "Apocalipse 5:9–10", "text": P3},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Poder sem cruz"),
            ("b", "Compra e reino"),
            ("c", "Cântico sem povo"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Apocalipse 5:9–10 fundamenta a dignidade do Cordeiro na morte redentora, não em conquista militar ou prestígio celestial sem a cruz.",
        "feedbackCorrect": "Certo: digno porque foste morto e compraste com o teu sangue.",
        "feedbackWrong": {"false": "O cântico liga dignidade à morte e ao sangue."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 5:9–10, toque a palavra que falta em "e ___ sobre a terra"?',
        "feedbackCorrect": "Exato: e reinarão sobre a terra.",
        "feedbackWrong": {
            "a": "Cantavam introduz o cântico; a lacuna é reinarão.",
            "c": "Compraste descreve a redenção; a lacuna é reinarão.",
        },
        "template": "e ___ sobre a terra",
        "options": opt(("a", "cantavam"), ("b", "reinarão"), ("c", "compraste")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura teológica Apocalipse 5:9–10 sustenta sobre quem governa a história?",
        "feedbackCorrect": "Certo: o Cordeiro morto e redentor é digno de abrir o livro.",
        "feedbackWrong": {
            "a": "O poder de abrir o livro vem da cruz, não de violência.",
            "c": "O povo comprado é multiétnico, não uma elite isolada.",
            "d": "Reino e sacerdotes nascem da compra, não a substituem.",
        },
        "options": opt(
            ("a", "Só a força bruta torna alguém digno de abrir o livro"),
            ("b", "O Cordeiro morto que compra com sangue é digno de governar"),
            ("c", "A salvação fica restrita a uma só língua e nação"),
            ("d", "Sacerdócio e reino cancelam a necessidade do sangue"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Apocalipse 5:9–10?",
        "feedbackCorrect": "Certo: cruz, redenção universal, povo real-sacerdotal.",
        "feedbackWrong": {
            "b": "A compra multiétnica flui da morte.",
            "c": "Reino e sacerdotes coroam o sentido do cântico.",
        },
        "options": opt(
            ("a", "O Cordeiro foi morto"),
            ("b", "comprou com sangue gente de toda tribo e nação"),
            ("c", "fez reino e sacerdotes que reinarão"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "abrir os seus ___"',
        "feedbackCorrect": "Certo: abrir os seus selos.",
        "feedbackWrong": {
            "a": "Sangue compra; a lacuna é selos.",
            "c": "Nação descreve os comprados; a lacuna é selos.",
        },
        "template": "abrir os seus ___",
        "options": opt(("a", "sangue"), ("b", "selos"), ("c", "nação")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 5:9–10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: no trono, o Cordeiro morto é o digno.",
        "feedbackWrong": {
            "a": "Não há dignidade sem a morte redentora.",
            "c": "O trono não exclui a cruz; o Cordeiro morto está no centro.",
        },
        "passageA": {"ref": "Apocalipse 5:9–10", "text": P3},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Trono sem cruz"),
            ("b", "Cordeiro no trono"),
            ("c", "Cruz sem povo"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M4 apo-boss-01 | Apocalipse 2:7; 5:9
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "apo-boss-01",
    "Apocalipse 2:7; 5:9",
    LO4,
    ["Apocalipse 2:7", "Apocalipse 5:9"],
    P4,
    I4,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Apocalipse 2:7 manda ouvir o que o Espírito diz às igrejas, e Apocalipse 5:9 declara o Cordeiro digno porque foi morto.",
        "feedbackCorrect": "Certo: as duas passagens unem escuta e dignidade do Cordeiro morto.",
        "feedbackWrong": {"false": "Releia 2:7 e 5:9: Espírito às igrejas e Cordeiro digno."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 2:7; 5:9, toque a palavra que falta em "ouça o que o ___ diz às igrejas"?',
        "feedbackCorrect": "Exato: o Espírito fala às igrejas.",
        "feedbackWrong": {
            "b": "Livro é o que o Cordeiro recebe; quem fala às igrejas é o Espírito.",
            "c": "Sangue compra; quem fala é o Espírito.",
        },
        "template": "ouça o que o ___ diz às igrejas",
        "options": opt(("a", "Espírito"), ("b", "livro"), ("c", "sangue")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que as duas passagens afirmam juntos sobre o Cordeiro e as igrejas?",
        "feedbackCorrect": "Certo: as igrejas ouvem o Espírito e o Cordeiro morto é digno.",
        "feedbackWrong": {
            "b": "O Espírito não cala as igrejas.",
            "c": "A dignidade do Cordeiro vem da morte, não a anula.",
            "d": "Há compra com sangue, não ausência de redenção.",
        },
        "options": opt(
            ("a", "Ouvir o Espírito e reconhecer o Cordeiro morto como digno"),
            ("b", "O Espírito deixa de falar às igrejas"),
            ("c", "O Cordeiro é digno apesar de nunca ter sido morto"),
            ("d", "Ninguém foi comprado com sangue"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Apocalipse 2:7; 5:9?",
        "feedbackCorrect": "Certo: escuta às igrejas, promessa ao vencedor, dignidade do morto.",
        "feedbackWrong": {
            "b": "A promessa ao vencedor segue o chamado a ouvir.",
            "c": "O cântico do Cordeiro morto completa o arco.",
        },
        "options": opt(
            ("a", "ouça o que o Espírito diz às igrejas"),
            ("b", "Ao vencedor, darei a comer da árvore da vida"),
            ("c", "Digno és… porque foste morto e compraste… com o teu sangue"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "porque foste ___ e compraste para Deus"',
        "feedbackCorrect": "Certo: porque foste morto.",
        "feedbackWrong": {
            "b": "Igrejas ouvem; a lacuna do cântico é morto.",
            "c": "Paraíso localiza a árvore; a lacuna é morto.",
        },
        "template": "porque foste ___ e compraste para Deus",
        "options": opt(("a", "morto"), ("b", "igrejas"), ("c", "Paraíso")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 2:7; 5:9 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: ouvir o Espírito e adorar o Cordeiro morto.",
        "feedbackWrong": {
            "b": "Não há cartas sem escuta do Espírito.",
            "c": "O trono não celebra um Cordeiro sem a morte.",
        },
        "passageA": {"ref": "Apocalipse 2:7; 5:9", "text": "Quem tem ouvidos, ouça… Digno és… porque foste morto…"},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Ouvir e adorar"),
            ("b", "Cartas sem Espírito"),
            ("c", "Trono sem Cordeiro"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Apocalipse 2:7 e 5:9, a escuta do Espírito às igrejas e a dignidade do Cordeiro morto aparecem como temas separados sem relação no livro.",
        "feedbackCorrect": "Certo: o desafio une cartas e trono — ouvir e adorar o Cordeiro.",
        "feedbackWrong": {"true": "O arco pastoral e o culto ao Cordeiro se ligam no Apocalipse."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 2:7; 5:9, toque a palavra que falta em "compraste para Deus, com o teu ___"?',
        "feedbackCorrect": "Exato: a compra é com o teu sangue.",
        "feedbackWrong": {
            "a": "Árvore é a promessa em 2:7; aqui a lacuna é sangue.",
            "c": "Vencedor recebe a árvore; a compra é com sangue.",
        },
        "template": "compraste para Deus, com o teu ___",
        "options": opt(("a", "árvore"), ("b", "sangue"), ("c", "vencedor")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Apocalipse 2:7 e 5:9 se encadeiam na formação do discípulo?",
        "feedbackCorrect": "Certo: a igreja ouve o Espírito e adora o Cordeiro que comprou com sangue.",
        "feedbackWrong": {
            "a": "Ouvir não substitui a cruz; os dois temas convivem.",
            "c": "A dignidade do Cordeiro não dispensa a escuta eclesial.",
            "d": "Há compra real com sangue, não só metáfora vazia.",
        },
        "options": opt(
            ("a", "Basta ouvir; a morte do Cordeiro é irrelevante"),
            ("b", "Ouvir o Espírito e reconhecer o Cordeiro morto e redentor"),
            ("c", "Basta o culto celestial; as igrejas não precisam ouvir"),
            ("d", "A compra com sangue é só figura, sem custo real"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Apocalipse 2:7; 5:9?",
        "feedbackCorrect": "Certo: Espírito às igrejas, árvore ao vencedor, Cordeiro digno.",
        "feedbackWrong": {
            "b": "A promessa ao vencedor segue a fala do Espírito.",
            "c": "O cântico do digno fecha o arco cartas–trono.",
        },
        "options": opt(
            ("a", "O Espírito diz às igrejas"),
            ("b", "o vencedor recebe a árvore da vida"),
            ("c", "o Cordeiro morto é digno de abrir o livro"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "darei a comer da ___ da vida"',
        "feedbackCorrect": "Certo: árvore da vida.",
        "feedbackWrong": {
            "b": "Selos são abertos em 5:9; a lacuna de 2:7 é árvore.",
            "c": "Livro é recebido; a lacuna é árvore.",
        },
        "template": "darei a comer da ___ da vida",
        "options": opt(("a", "árvore"), ("b", "selos"), ("c", "livro")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 2:7; 5:9 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: cartas que ouvem e trono que adora o Cordeiro.",
        "feedbackWrong": {
            "a": "Não é só carta sem culto ao Cordeiro.",
            "c": "Não é só trono sem escuta pastoral.",
        },
        "passageA": {"ref": "Apocalipse 2:7; 5:9", "text": "ouça… o Espírito… Digno és… foste morto…"},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Só cartas sem culto"),
            ("b", "Cartas e trono"),
            ("c", "Só trono sem escuta"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Apocalipse 2:7 e 5:9 juntos mostram que a esperança da igreja une obediência à voz do Espírito e confiança no Cordeiro morto e redentor.",
        "feedbackCorrect": "Certo: escuta e adoração ao Cordeiro morto formam o eixo cartas–trono.",
        "feedbackWrong": {"false": "As duas passagens sustentam escuta e dignidade pela cruz."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 2:7; 5:9, toque a palavra que falta em "Digno és de receber o ___ e de abrir os seus selos"?',
        "feedbackCorrect": "Exato: receber o livro.",
        "feedbackWrong": {
            "a": "Igrejas ouvem em 2:7; aqui a lacuna é livro.",
            "c": "Paraíso localiza a árvore; a lacuna é livro.",
        },
        "template": "Digno és de receber o ___ e de abrir os seus selos",
        "options": opt(("a", "igrejas"), ("b", "livro"), ("c", "Paraíso")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura teológica une Apocalipse 2:7 e 5:9?",
        "feedbackCorrect": "Certo: a igreja ouve o Espírito e o Cordeiro morto governa a história.",
        "feedbackWrong": {
            "a": "O Espírito não silencia as igrejas sob pressão.",
            "c": "A dignidade não prescinde da morte redentora.",
            "d": "Árvore da vida e sangue do Cordeiro não se excluem.",
        },
        "options": opt(
            ("a", "Sob pressão, as igrejas não precisam ouvir o Espírito"),
            ("b", "Ouvir o Espírito e adorar o Cordeiro morto sustentam a igreja"),
            ("c", "O Cordeiro é digno sem ter sido morto nem comprado ninguém"),
            ("d", "A árvore da vida torna desnecessário o sangue do Cordeiro"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Apocalipse 2:7; 5:9?",
        "feedbackCorrect": "Certo: escuta, vitória promissória, culto ao Cordeiro morto.",
        "feedbackWrong": {
            "b": "Vencer sob a palavra do Espírito prepara a esperança.",
            "c": "Adorar o Cordeiro morto completa o sentido do desafio.",
        },
        "options": opt(
            ("a", "Ouvir o Espírito nas igrejas"),
            ("b", "Receber a promessa ao vencedor"),
            ("c", "Confessar o Cordeiro morto como digno"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "ouça o que o Espírito diz às ___"',
        "feedbackCorrect": "Certo: às igrejas.",
        "feedbackWrong": {
            "a": "Selos pertencem ao livro; a lacuna é igrejas.",
            "c": "Tribo descreve os comprados; a lacuna é igrejas.",
        },
        "template": "ouça o que o Espírito diz às ___",
        "options": opt(("a", "selos"), ("b", "igrejas"), ("c", "tribo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 2:7; 5:9 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: escuta pastoral e culto ao Cordeiro morto.",
        "feedbackWrong": {
            "a": "Não é culto sem escuta das cartas.",
            "c": "Não é escuta sem o Cordeiro do trono.",
        },
        "passageA": {"ref": "Apocalipse 2:7; 5:9", "text": "Espírito… igrejas… Digno és… morto… sangue"},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Culto sem escuta"),
            ("b", "Espírito e Cordeiro"),
            ("c", "Escuta sem Cordeiro"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M5 apo-06-selos | Apocalipse 7:9–10
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "apo-06-selos",
    "Apocalipse 7:9–10",
    LO5,
    ["Apocalipse 7:9", "Apocalipse 7:10"],
    P5,
    I5,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Depois dessas coisas, olhei, e eis uma grande multidão que ninguém podia contar.",
        "feedbackCorrect": "Certo: a multidão é incontável.",
        "feedbackWrong": {"false": "Releia: uma grande multidão que ninguém podia contar."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 7:9–10, toque a palavra que falta em "diante do trono e diante do ___"?',
        "feedbackCorrect": "Exato: diante do Cordeiro.",
        "feedbackWrong": {
            "b": "Nação descreve a origem; o foco é o Cordeiro.",
            "c": "Palmas estão nas mãos; a lacuna é Cordeiro.",
        },
        "template": "diante do trono e diante do ___",
        "options": opt(("a", "Cordeiro"), ("b", "nação"), ("c", "palmas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que a multidão clama com grande voz em Apocalipse 7:9–10?",
        "feedbackCorrect": "Certo: Salvação a nosso Deus… e ao Cordeiro.",
        "feedbackCorrect_note": None,
        "feedbackWrong": {
            "b": "O clamor é salvação, não maldição.",
            "c": "A salvação é a Deus e ao Cordeiro, não a César.",
            "d": "Não pedem silêncio; clamam salvação.",
        },
        "options": opt(
            ("a", "Salvação a nosso Deus… e ao Cordeiro"),
            ("b", "Maldição sobre o trono e sobre o Cordeiro"),
            ("c", "Salvação somente a César e ao império"),
            ("d", "Silêncio absoluto diante do trono"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Apocalipse 7:9–10?",
        "feedbackCorrect": "Certo: visão da multidão, posição diante do trono, clamor.",
        "feedbackWrong": {
            "b": "Estar em pé diante do trono segue a visão da multidão.",
            "c": "O clamor da salvação fecha o trecho.",
        },
        "options": opt(
            ("a", "eis uma grande multidão que ninguém podia contar"),
            ("b", "estavam em pé diante do trono e diante do Cordeiro"),
            ("c", "clamavam… Salvação a nosso Deus… e ao Cordeiro"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "cobertos de vestiduras ___ com palmas nas mãos"',
        "feedbackCorrect": "Certo: vestiduras brancas.",
        "feedbackWrong": {
            "b": "Grande descreve a multidão; a lacuna é brancas.",
            "c": "Voz descreve o clamor; a lacuna é brancas.",
        },
        "template": "cobertos de vestiduras ___ com palmas nas mãos",
        "options": opt(("a", "brancas"), ("b", "grande"), ("c", "voz")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 7:9–10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: multidão incontável louva a salvação a Deus e ao Cordeiro.",
        "feedbackWrong": {
            "b": "A multidão não é contável; ninguém podia contar.",
            "c": "O louvor inclui o Cordeiro, não o exclui.",
        },
        "passageA": {"ref": "Apocalipse 7:9–10", "text": P5},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Multidão e salvação"),
            ("b", "Multidão contável"),
            ("c", "Louvor sem Cordeiro"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Apocalipse 7:9, a multidão vem de toda nação e de todas as tribos, povos e línguas.",
        "feedbackCorrect": "Certo: a composição é multiétnica e multilíngue.",
        "feedbackWrong": {"false": "O texto lista nação, tribos, povos e línguas."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 7:9–10, toque a palavra que falta em "___ a nosso Deus que está sentado sobre o trono"?',
        "feedbackCorrect": "Exato: Salvação a nosso Deus… e ao Cordeiro.",
        "feedbackWrong": {
            "b": "Multidão é quem clama; a palavra do clamor é Salvação.",
            "c": "Trono é onde Deus está; a lacuna é Salvação.",
        },
        "template": "___ a nosso Deus que está sentado sobre o trono",
        "options": opt(("a", "Salvação"), ("b", "multidão"), ("c", "trono")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Apocalipse 7:9–10 liga a posição da multidão e o conteúdo do clamor?",
        "feedbackCorrect": "Certo: em pé diante do trono e do Cordeiro, clamam salvação a ambos.",
        "feedbackWrong": {
            "a": "Elas estão diante do Cordeiro, não longe dele.",
            "c": "O clamor inclui Deus e o Cordeiro juntos.",
            "d": "As vestiduras brancas e as palmas marcam culto, não luto vazio.",
        },
        "options": opt(
            ("a", "Estão longe do Cordeiro e clamam só contra o trono"),
            ("b", "Diante do trono e do Cordeiro, atribuem salvação a Deus e ao Cordeiro"),
            ("c", "Clamam salvação só a Deus, nunca ao Cordeiro"),
            ("d", "As palmas e as vestes brancas sinalizam apenas luto, sem louvor"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Apocalipse 7:9–10?",
        "feedbackCorrect": "Certo: origem multiétnica, vestes e palmas, clamor da salvação.",
        "feedbackWrong": {
            "b": "Vestes e palmas descrevem a multidão já reunida.",
            "c": "O clamor fecha o encadeamento.",
        },
        "options": opt(
            ("a", "de toda nação e de todas as tribos, povos e línguas"),
            ("b", "cobertos de vestiduras brancas com palmas nas mãos"),
            ("c", "Salvação a nosso Deus… e ao Cordeiro"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "com ___ nas mãos"',
        "feedbackCorrect": "Certo: com palmas nas mãos.",
        "feedbackWrong": {
            "b": "Tribos descreve a origem; a lacuna é palmas.",
            "c": "Línguas descreve a origem; a lacuna é palmas.",
        },
        "template": "com ___ nas mãos",
        "options": opt(("a", "palmas"), ("b", "tribos"), ("c", "línguas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 7:9–10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: testemunho de salvação no meio do conflito dos selos.",
        "feedbackWrong": {
            "a": "A multidão não some; ela louva.",
            "c": "Salvação é a Deus e ao Cordeiro, não ao caos.",
        },
        "passageA": {"ref": "Apocalipse 7:9–10", "text": P5},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Multidão sem louvor"),
            ("b", "Louvor da salvação"),
            ("c", "Salvação ao caos"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Apocalipse 7:9–10 apresenta a salvação como pertencente a Deus e ao Cordeiro, sustentando esperança mesmo em meio ao conflito revelado pelos selos.",
        "feedbackCorrect": "Certo: o clamor atribui salvação a Deus e ao Cordeiro.",
        "feedbackWrong": {"false": "O texto une multidão salva e louvor a Deus e ao Cordeiro."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 7:9–10, toque a palavra que falta em "que ninguém podia ___"?',
        "feedbackCorrect": "Exato: ninguém podia contar.",
        "feedbackWrong": {
            "b": "Olhei introduz a visão; a lacuna é contar.",
            "c": "Clamavam descreve a voz; a lacuna é contar.",
        },
        "template": "que ninguém podia ___",
        "options": opt(("a", "contar"), ("b", "olhei"), ("c", "clamavam")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura teológica Apocalipse 7:9–10 sustenta sobre o povo de Deus na história?",
        "feedbackCorrect": "Certo: há uma multidão salva de todas as nações diante do Cordeiro.",
        "feedbackWrong": {
            "a": "A salvação não é do império; é de Deus e do Cordeiro.",
            "c": "A multidão é incontável e multiétnica, não uma elite única.",
            "d": "O Cordeiro está no centro do culto, não à margem.",
        },
        "options": opt(
            ("a", "A salvação pertence ao império que controla as manchetes"),
            ("b", "Deus e o Cordeiro recebem o louvor da multidão salva"),
            ("c", "Só uma nação aparece diante do trono"),
            ("d", "O Cordeiro fica de fora do clamor da salvação"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Apocalipse 7:9–10?",
        "feedbackCorrect": "Certo: visão multiétnica, presença diante do Cordeiro, salvação confessada.",
        "feedbackWrong": {
            "b": "Estar diante do Cordeiro prepara o clamor.",
            "c": "Atribuir salvação a Deus e ao Cordeiro revela o sentido.",
        },
        "options": opt(
            ("a", "Multidão de todas as nações"),
            ("b", "em pé diante do trono e do Cordeiro"),
            ("c", "Salvação a Deus e ao Cordeiro"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "e ao ___"',
        "feedbackCorrect": "Certo: e ao Cordeiro.",
        "feedbackWrong": {
            "b": "Nação descreve a origem; o clamor inclui o Cordeiro.",
            "c": "Palmas estão nas mãos; a lacuna é Cordeiro.",
        },
        "template": "e ao ___",
        "options": opt(("a", "Cordeiro"), ("b", "nação"), ("c", "palmas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 7:9–10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: no conflito, a multidão testemunha salvação no Cordeiro.",
        "feedbackWrong": {
            "a": "Não é só caos sem povo salvo.",
            "c": "Não é multidão sem o Cordeiro.",
        },
        "passageA": {"ref": "Apocalipse 7:9–10", "text": P5},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Caos sem povo"),
            ("b", "Testemunho salvo"),
            ("c", "Povo sem Cordeiro"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# Fix accidental key in choice M5 semente
for item in Qs:
    item.pop("feedbackCorrect_note", None)

# ═══════════════════════════════════════════════════════════════════
# M6 apo-07-babilonia | Apocalipse 18:4
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "apo-07-babilonia",
    "Apocalipse 18:4",
    LO6,
    ["Apocalipse 18:4"],
    P6,
    I6,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Ouvi outra voz do céu, dizendo: Sai dela, povo meu.",
        "feedbackCorrect": "Certo: a voz do céu chama: Sai dela, povo meu.",
        "feedbackWrong": {"false": "Releia Apocalipse 18:4: Sai dela, povo meu."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 18:4, toque a palavra que falta em "Sai dela, ___ meu"?',
        "feedbackCorrect": "Exato: povo meu.",
        "feedbackWrong": {
            "b": "Céu é de onde vem a voz; o chamado é ao povo.",
            "c": "Pragas são o risco; o vocativo é povo.",
        },
        "template": "Sai dela, ___ meu",
        "options": opt(("a", "povo"), ("b", "céu"), ("c", "pragas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Por que Apocalipse 18:4 manda o povo sair dela?",
        "feedbackCorrect": "Certo: para não participar dos pecados nem das pragas.",
        "feedbackWrong": {
            "b": "O motivo não é turismo; é separação dos pecados.",
            "c": "O texto quer distância dos pecados, não cumplicidade.",
            "d": "Sair evita as pragas; não as atrai.",
        },
        "options": opt(
            ("a", "Para não serdes participantes dos seus pecados, nem terdes parte nas suas pragas"),
            ("b", "Para conhecer melhor os luxos de Babilônia"),
            ("c", "Para se tornarem sócios dos pecados dela"),
            ("d", "Para atraírem sobre si as pragas dela"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Apocalipse 18:4?",
        "feedbackCorrect": "Certo: voz do céu, chamado a sair, motivo dos pecados e pragas.",
        "feedbackWrong": {
            "b": "Sai dela segue a voz ouvida.",
            "c": "O motivo fecha o versículo.",
        },
        "options": opt(
            ("a", "Ouvi outra voz do céu, dizendo"),
            ("b", "Sai dela, povo meu"),
            ("c", "para não serdes participantes dos seus pecados, nem terdes parte nas suas pragas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "nem terdes parte nas suas ___"',
        "feedbackCorrect": "Certo: nas suas pragas.",
        "feedbackWrong": {
            "b": "Voz introduz o chamado; a lacuna é pragas.",
            "c": "Céu é a origem da voz; a lacuna é pragas.",
        },
        "template": "nem terdes parte nas suas ___",
        "options": opt(("a", "pragas"), ("b", "voz"), ("c", "céu")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 18:4 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: sair de Babilônia é separação dos pecados.",
        "feedbackWrong": {
            "b": "O chamado é a sair, não a ficar.",
            "c": "A saída evita participação nos pecados.",
        },
        "passageA": {"ref": "Apocalipse 18:4", "text": P6},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Sair dos pecados"),
            ("b", "Ficar em Babilônia"),
            ("c", "Partilhar os pecados"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Apocalipse 18:4, permanecer nela implica risco de participar dos pecados e das pragas.",
        "feedbackCorrect": "Certo: sair evita participação nos pecados e nas pragas.",
        "feedbackWrong": {"false": "O texto liga sair a não participar nem ter parte nas pragas."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 18:4, toque a palavra que falta em "para não serdes participantes dos seus ___"?',
        "feedbackCorrect": "Exato: dos seus pecados.",
        "feedbackWrong": {
            "b": "Povo é quem é chamado; a lacuna é pecados.",
            "c": "Céu é a origem da voz; a lacuna é pecados.",
        },
        "template": "para não serdes participantes dos seus ___",
        "options": opt(("a", "pecados"), ("b", "povo"), ("c", "céu")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Apocalipse 18:4 relaciona identidade do povo e distância de Babilônia?",
        "feedbackCorrect": "Certo: por ser povo meu, deve sair para não partilhar pecados e pragas.",
        "feedbackWrong": {
            "a": "O chamado é Sai dela, não fica nela.",
            "c": "Ser povo de Deus motiva a saída, não a cumplicidade.",
            "d": "Pecados e pragas estão ligados no aviso.",
        },
        "options": opt(
            ("a", "Povo meu deve permanecer nela para reformá-la por dentro sem sair"),
            ("b", "Porque é povo meu, deve sair para não partilhar pecados nem pragas"),
            ("c", "Ser povo de Deus autoriza participar dos pecados dela"),
            ("d", "As pragas não têm relação com os pecados no aviso"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Apocalipse 18:4?",
        "feedbackCorrect": "Certo: chamado, saída, proteção quanto a pecados e pragas.",
        "feedbackWrong": {
            "b": "Sair responde ao chamado ao povo.",
            "c": "O propósito protege de pecados e pragas.",
        },
        "options": opt(
            ("a", "Sai dela, povo meu"),
            ("b", "para não serdes participantes dos seus pecados"),
            ("c", "nem terdes parte nas suas pragas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Ouvi outra ___ do céu"',
        "feedbackCorrect": "Certo: outra voz do céu.",
        "feedbackWrong": {
            "b": "Povo é o vocativo; a lacuna é voz.",
            "c": "Pragas são o risco; a lacuna é voz.",
        },
        "template": "Ouvi outra ___ do céu",
        "options": opt(("a", "voz"), ("b", "povo"), ("c", "pragas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 18:4 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: fidelidade tem endereço — sair da cumplicidade.",
        "feedbackWrong": {
            "a": "Não é convivência sem ruptura.",
            "c": "Não é partilha das pragas.",
        },
        "passageA": {"ref": "Apocalipse 18:4", "text": P6},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Cumplicidade sem saída"),
            ("b", "Separação fiel"),
            ("c", "Parte nas pragas"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Apocalipse 18:4 trata a saída de Babilônia como ato de fidelidade ao chamado de Deus, evitando cumplicidade com pecados e juízo.",
        "feedbackCorrect": "Certo: Sai dela, povo meu, liga identidade e separação.",
        "feedbackWrong": {"false": "O texto une povo meu, saída, pecados e pragas."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 18:4, toque a palavra que falta em "___ dela, povo meu"?',
        "feedbackCorrect": "Exato: Sai dela.",
        "feedbackWrong": {
            "b": "Ouvi introduz a cena; o imperativo é Sai.",
            "c": "Parte aparece no risco; o imperativo é Sai.",
        },
        "template": "___ dela, povo meu",
        "options": opt(("a", "Sai"), ("b", "Ouvi"), ("c", "parte")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual implicação Apocalipse 18:4 sustenta para o povo de Deus diante de sistemas idólatras?",
        "feedbackCorrect": "Certo: a fidelidade exige saída da cumplicidade com pecados e juízo.",
        "feedbackWrong": {
            "a": "O texto não autoriza participar dos pecados.",
            "c": "A voz do céu define o chamado, não o conforto do sistema.",
            "d": "Pragas e pecados estão ligados no aviso.",
        },
        "options": opt(
            ("a", "Pode-se partilhar os pecados sem risco de pragas"),
            ("b", "Deve-se sair para não participar dos pecados nem das pragas"),
            ("c", "A voz do céu recomenda acomodação confortável a Babilônia"),
            ("d", "Pecados de Babilônia não trazem consequências no texto"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Apocalipse 18:4?",
        "feedbackCorrect": "Certo: identidade, ruptura, proteção do juízo.",
        "feedbackWrong": {
            "b": "Sair expressa a fidelidade do povo.",
            "c": "Evitar pecados e pragas revela o sentido do chamado.",
        },
        "options": opt(
            ("a", "Sai dela"),
            ("b", "povo meu"),
            ("c", "não participar dos pecados nem das pragas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "para não serdes ___ dos seus pecados"',
        "feedbackCorrect": "Certo: participantes dos seus pecados.",
        "feedbackWrong": {
            "b": "Pragas vem depois; a lacuna é participantes.",
            "c": "Voz introduz; a lacuna é participantes.",
        },
        "template": "para não serdes ___ dos seus pecados",
        "options": opt(("a", "participantes"), ("b", "pragas"), ("c", "voz")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 18:4 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Babilônia exige separação fiel dos pecados.",
        "feedbackWrong": {
            "a": "Não é neutralidade dentro do sistema.",
            "c": "Não é absorção dos pecados dela.",
        },
        "passageA": {"ref": "Apocalipse 18:4", "text": P6},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Neutralidade em Babilônia"),
            ("b", "Sai, povo meu"),
            ("c", "Absorver os pecados"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M7 apo-03-novo | Apocalipse 21:3–4
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "apo-03-novo",
    "Apocalipse 21:3–4",
    LO7,
    ["Apocalipse 21:3", "Apocalipse 21:4"],
    P7,
    I7,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Eis o tabernáculo de Deus está com os homens, e ele habitará com eles.",
        "feedbackCorrect": "Certo: o tabernáculo de Deus está com os homens.",
        "feedbackWrong": {"false": "Releia Apocalipse 21:3: Deus habitará com eles."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 21:3–4, toque a palavra que falta em "Eis o ___ de Deus está com os homens"?',
        "feedbackCorrect": "Exato: o tabernáculo de Deus.",
        "feedbackWrong": {
            "b": "Lágrima é o que Deus enxuga; a lacuna é tabernáculo.",
            "c": "Morte é o que passa; a lacuna é tabernáculo.",
        },
        "template": "Eis o ___ de Deus está com os homens",
        "options": opt(("a", "tabernáculo"), ("b", "lágrima"), ("c", "morte")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 21:4 diz que não haverá mais?",
        "feedbackCorrect": "Certo: não haverá mais morte, pranto, choro nem dor.",
        "feedbackWrong": {
            "b": "O texto anuncia o fim da morte, não a sua permanência.",
            "c": "Pranto, choro e dor passam, não aumentam.",
            "d": "As primeiras coisas são passadas, não eternizadas.",
        },
        "options": opt(
            ("a", "Morte, pranto, choro e dor"),
            ("b", "Apenas a alegria; a morte permanece"),
            ("c", "Mais tabernáculo de Deus com os homens"),
            ("d", "Qualquer presença de Deus com o seu povo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Apocalipse 21:3–4?",
        "feedbackCorrect": "Certo: habitação, povo de Deus, fim da dor.",
        "feedbackWrong": {
            "b": "Ser povo segue a habitação de Deus.",
            "c": "Enxugar lágrimas e fim da morte fecham o trecho.",
        },
        "options": opt(
            ("a", "Eis o tabernáculo de Deus está com os homens, e ele habitará com eles"),
            ("b", "eles serão o seu povo, e Deus mesmo estará com eles"),
            ("c", "enxugará toda lágrima… Não haverá mais morte… nem dor"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Não haverá mais ___"',
        "feedbackCorrect": "Certo: Não haverá mais morte.",
        "feedbackWrong": {
            "b": "Povo descreve a relação; a lacuna é morte.",
            "c": "Trono é a origem da voz; a lacuna é morte.",
        },
        "template": "Não haverá mais ___",
        "options": opt(("a", "morte"), ("b", "povo"), ("c", "trono")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 21:3–4 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Deus habita com os homens; morte e dor passam.",
        "feedbackWrong": {
            "b": "Deus não fica distante; habita com eles.",
            "c": "A morte não permanece; não haverá mais morte.",
        },
        "passageA": {"ref": "Apocalipse 21:3–4", "text": P7},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Deus com os homens"),
            ("b", "Deus distante"),
            ("c", "Morte permanente"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Apocalipse 21:3–4, Deus mesmo estará com eles e enxugará toda lágrima dos olhos deles.",
        "feedbackCorrect": "Certo: presença de Deus e enxugar lágrimas vão juntos.",
        "feedbackWrong": {"false": "O texto une habitação e enxugar toda lágrima."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 21:3–4, toque a palavra que falta em "e enxugará toda ___ dos olhos deles"?',
        "feedbackCorrect": "Exato: toda lágrima.",
        "feedbackWrong": {
            "b": "Morte é o que passa; a lacuna é lágrima.",
            "c": "Dor também passa; a lacuna aqui é lágrima.",
        },
        "template": "e enxugará toda ___ dos olhos deles",
        "options": opt(("a", "lágrima"), ("b", "morte"), ("c", "dor")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Apocalipse 21:3–4 liga a habitação de Deus e o fim do sofrimento?",
        "feedbackCorrect": "Certo: Deus com o povo; então lágrimas, morte e dor passam.",
        "feedbackWrong": {
            "a": "A habitação não mantém a morte; ela passa.",
            "c": "As primeiras coisas são passadas, não eternizadas.",
            "d": "Pranto e choro também cessam com a presença de Deus.",
        },
        "options": opt(
            ("a", "Deus habita com os homens, mas a morte permanece para sempre"),
            ("b", "Com Deus habitando com eles, lágrima, morte, pranto, choro e dor passam"),
            ("c", "As primeiras coisas continuam iguais na nova criação"),
            ("d", "Só a morte passa; pranto e choro ficam"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Apocalipse 21:3–4?",
        "feedbackCorrect": "Certo: voz do trono, habitação, fim das primeiras coisas.",
        "feedbackWrong": {
            "b": "A habitação segue a voz do trono.",
            "c": "O fim da dor explica que as primeiras coisas passaram.",
        },
        "options": opt(
            ("a", "Ouvi uma grande voz, vinda do trono"),
            ("b", "Eis o tabernáculo de Deus está com os homens"),
            ("c", "Não haverá mais morte… porque as primeiras coisas são passadas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "eles serão o seu ___"',
        "feedbackCorrect": "Certo: serão o seu povo.",
        "feedbackWrong": {
            "b": "Trono é a origem da voz; a lacuna é povo.",
            "c": "Choro é o que passa; a lacuna é povo.",
        },
        "template": "eles serão o seu ___",
        "options": opt(("a", "povo"), ("b", "trono"), ("c", "choro")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 21:3–4 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: nova criação com Deus presente e dor passada.",
        "feedbackWrong": {
            "a": "Não é ausência de Deus.",
            "c": "Não é permanência da dor.",
        },
        "passageA": {"ref": "Apocalipse 21:3–4", "text": P7},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Deus ausente"),
            ("b", "Habitação e consolo"),
            ("c", "Dor eterna"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Apocalipse 21:3–4 apresenta o fim da morte e da dor como consequência da presença restauradora de Deus com o seu povo, não como mera fuga da criação.",
        "feedbackCorrect": "Certo: Deus habita com os homens; as primeiras coisas passam.",
        "feedbackWrong": {"false": "O texto une tabernáculo com os homens e o fim da morte."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 21:3–4, toque a palavra que falta em "porque as primeiras coisas são ___"?',
        "feedbackCorrect": "Exato: são passadas.",
        "feedbackWrong": {
            "b": "Homens recebem a habitação; a lacuna é passadas.",
            "c": "Pranto é o que cessa; a lacuna é passadas.",
        },
        "template": "porque as primeiras coisas são ___",
        "options": opt(("a", "passadas"), ("b", "homens"), ("c", "pranto")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual esperança Apocalipse 21:3–4 sustenta para quem sofre hoje?",
        "feedbackCorrect": "Certo: Deus estará com o seu povo e enxugará toda lágrima.",
        "feedbackWrong": {
            "a": "O texto promete o fim da morte, não a sua eternização.",
            "c": "Há presença de Deus, não abandono final.",
            "d": "As primeiras coisas passam; o futuro não é só repetição da dor.",
        },
        "options": opt(
            ("a", "A morte e a dor serão eternas mesmo com Deus"),
            ("b", "Deus habitará com eles e enxugará toda lágrima; a morte passa"),
            ("c", "Deus permanecerá distante enquanto o povo chora"),
            ("d", "As primeiras coisas nunca passam na nova criação"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Apocalipse 21:3–4?",
        "feedbackCorrect": "Certo: presença, povo, consolo escatológico.",
        "feedbackWrong": {
            "b": "Ser povo flui da habitação de Deus.",
            "c": "Enxugar lágrimas e fim da morte revelam o sentido.",
        },
        "options": opt(
            ("a", "Deus habita com os homens"),
            ("b", "eles serão o seu povo"),
            ("c", "enxuga lágrimas e acaba morte e dor"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "nem haverá mais pranto, nem choro, nem ___"',
        "feedbackCorrect": "Certo: nem dor.",
        "feedbackWrong": {
            "b": "Povo é a identidade; a lacuna é dor.",
            "c": "Trono é a origem da voz; a lacuna é dor.",
        },
        "template": "nem haverá mais pranto, nem choro, nem ___",
        "options": opt(("a", "dor"), ("b", "povo"), ("c", "trono")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 21:3–4 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: novo céu e terra com Deus presente e dor vencida.",
        "feedbackWrong": {
            "a": "Não é criação sem Deus.",
            "c": "Não é esperança sem consolo das lágrimas.",
        },
        "passageA": {"ref": "Apocalipse 21:3–4", "text": P7},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Criação sem Deus"),
            ("b", "Deus enxuga lágrimas"),
            ("c", "Esperança sem consolo"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ═══════════════════════════════════════════════════════════════════
# M8 apo-boss-02 | Apocalipse 7:9; 21:3–4
# ═══════════════════════════════════════════════════════════════════
sec, vr, lo, ev, p, insight = (
    "apo-boss-02",
    "Apocalipse 7:9; 21:3–4",
    LO8,
    ["Apocalipse 7:9", "Apocalipse 21:3", "Apocalipse 21:4"],
    P8,
    I8,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Apocalipse 7:9 mostra uma grande multidão que ninguém podia contar, e Apocalipse 21:3–4 afirma que Deus enxugará toda lágrima.",
        "feedbackCorrect": "Certo: multidão salva e Deus que enxuga lágrimas formam a esperança final.",
        "feedbackWrong": {"false": "Releia 7:9 e 21:3–4: multidão e lágrimas enxugadas."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 7:9; 21:3–4, toque a palavra que falta em "eis uma grande ___ que ninguém podia contar"?',
        "feedbackCorrect": "Exato: grande multidão.",
        "feedbackWrong": {
            "b": "Lágrima é o que Deus enxuga; a lacuna é multidão.",
            "c": "Morte é o que passa; a lacuna é multidão.",
        },
        "template": "eis uma grande ___ que ninguém podia contar",
        "options": opt(("a", "multidão"), ("b", "lágrima"), ("c", "morte")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que as duas passagens afirmam juntos sobre a esperança final?",
        "feedbackCorrect": "Certo: há multidão salva diante do Cordeiro e Deus enxuga toda lágrima.",
        "feedbackWrong": {
            "b": "A multidão é incontável, não inexistente.",
            "c": "Deus enxuga lágrimas; não as ignora.",
            "d": "A morte passa; não permanece.",
        },
        "options": opt(
            ("a", "Multidão salva e Deus enxugando toda lágrima"),
            ("b", "Nenhuma multidão diante do trono"),
            ("c", "Deus deixa as lágrimas para sempre"),
            ("d", "A morte permanece nas primeiras coisas"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Apocalipse 7:9; 21:3–4?",
        "feedbackCorrect": "Certo: multidão diante do Cordeiro, habitação de Deus, fim da dor.",
        "feedbackWrong": {
            "b": "A habitação de Deus aprofunda a esperança da multidão.",
            "c": "O fim da morte e da dor fecha o arco.",
        },
        "options": opt(
            ("a", "grande multidão… diante do trono e diante do Cordeiro"),
            ("b", "Eis o tabernáculo de Deus está com os homens"),
            ("c", "enxugará toda lágrima… Não haverá mais morte… nem dor"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "e enxugará toda ___ dos olhos deles"',
        "feedbackCorrect": "Certo: toda lágrima.",
        "feedbackWrong": {
            "b": "Nação descreve a origem da multidão; a lacuna é lágrima.",
            "c": "Palmas estão nas mãos em 7:9; a lacuna é lágrima.",
        },
        "template": "e enxugará toda ___ dos olhos deles",
        "options": opt(("a", "lágrima"), ("b", "nação"), ("c", "palmas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 7:9; 21:3–4 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: esperança final — multidão salva e lágrimas enxugadas.",
        "feedbackWrong": {
            "b": "Não é multidão sem consolo.",
            "c": "Não é consolo sem povo salvo.",
        },
        "passageA": {"ref": "Apocalipse 7:9; 21:3–4", "text": "grande multidão… enxugará toda lágrima…"},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Multidão e lágrimas"),
            ("b", "Multidão sem consolo"),
            ("c", "Consolo sem povo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em Apocalipse 7:9 e 21:3–4, a multidão diante do Cordeiro e a habitação de Deus com os homens apontam para a mesma esperança de restauração.",
        "feedbackCorrect": "Certo: povo salvo e Deus conosco formam um só horizonte.",
        "feedbackWrong": {"false": "As duas cenas sustentam a esperança final unida."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 7:9; 21:3–4, toque a palavra que falta em "Eis o ___ de Deus está com os homens"?',
        "feedbackCorrect": "Exato: tabernáculo de Deus.",
        "feedbackWrong": {
            "b": "Cordeiro aparece em 7:9; aqui a lacuna é tabernáculo.",
            "c": "Multidão é a visão de 7:9; a lacuna é tabernáculo.",
        },
        "template": "Eis o ___ de Deus está com os homens",
        "options": opt(("a", "tabernáculo"), ("b", "Cordeiro"), ("c", "multidão")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Apocalipse 7:9 e 21:3–4 se encadeiam na esperança do leitor?",
        "feedbackCorrect": "Certo: a multidão salva antecipa a presença plena em que a dor passa.",
        "feedbackWrong": {
            "a": "A multidão não é abandonada; Deus habitará com eles.",
            "c": "Há fim da morte, não permanência dela.",
            "d": "As vestes brancas e a habitação apontam à restauração, não ao vazio.",
        },
        "options": opt(
            ("a", "A multidão salva fica sem a presença futura de Deus"),
            ("b", "A multidão diante do Cordeiro aponta à habitação em que lágrimas passam"),
            ("c", "Deus habita com os homens, mas a morte nunca passa"),
            ("d", "As duas cenas negam qualquer consolo escatológico"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Apocalipse 7:9; 21:3–4?",
        "feedbackCorrect": "Certo: multidão multiétnica, Deus com o povo, fim da dor.",
        "feedbackWrong": {
            "b": "A habitação aprofunda a visão da multidão.",
            "c": "O fim da dor coroa a esperança.",
        },
        "options": opt(
            ("a", "multidão de toda nação… diante do Cordeiro"),
            ("b", "Deus habitará com eles; serão o seu povo"),
            ("c", "Não haverá mais morte… nem dor"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "Não haverá mais ___"',
        "feedbackCorrect": "Certo: Não haverá mais morte.",
        "feedbackWrong": {
            "b": "Tribos descreve a multidão; a lacuna é morte.",
            "c": "Palmas estão nas mãos; a lacuna é morte.",
        },
        "template": "Não haverá mais ___",
        "options": opt(("a", "morte"), ("b", "tribos"), ("c", "palmas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 7:9; 21:3–4 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: povo salvo e Deus que consola.",
        "feedbackWrong": {
            "a": "Não é salvação sem consolo das lágrimas.",
            "c": "Não é consolo sem a multidão salva.",
        },
        "passageA": {"ref": "Apocalipse 7:9; 21:3–4", "text": "multidão… Cordeiro… enxugará toda lágrima"},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Salvos sem consolo"),
            ("b", "Salvos e consolados"),
            ("c", "Consolo sem salvos"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Apocalipse 7:9 e 21:3–4 juntos sustentam que a esperança cristã une povo multiétnico salvo no Cordeiro e a presença de Deus que enxuga toda lágrima.",
        "feedbackCorrect": "Certo: multidão salva e Deus conosco formam a esperança final.",
        "feedbackWrong": {"false": "As duas passagens unem multidão salva e lágrimas enxugadas."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": 'Em Apocalipse 7:9; 21:3–4, toque a palavra que falta em "diante do trono e diante do ___"?',
        "feedbackCorrect": "Exato: diante do Cordeiro.",
        "feedbackWrong": {
            "b": "Lágrima é enxugada em 21:4; a lacuna é Cordeiro.",
            "c": "Dor passa em 21:4; a lacuna é Cordeiro.",
        },
        "template": "diante do trono e diante do ___",
        "options": opt(("a", "Cordeiro"), ("b", "lágrima"), ("c", "dor")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura teológica une Apocalipse 7:9 e 21:3–4?",
        "feedbackCorrect": "Certo: a multidão salva encontra plenitude quando Deus habita e a dor passa.",
        "feedbackWrong": {
            "a": "A multidão não é abandonada ao sofrimento eterno.",
            "c": "Há povo multiétnico, não uma só nação.",
            "d": "A habitação de Deus traz o fim da morte, não a sua permanência.",
        },
        "options": opt(
            ("a", "A multidão salva ainda enfrenta morte e dor para sempre"),
            ("b", "Povo salvo no Cordeiro e Deus que enxuga lágrimas definem a esperança"),
            ("c", "Só uma nação aparece; as demais ficam de fora da esperança"),
            ("d", "Deus habita com os homens, mas a morte nunca passa"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Apocalipse 7:9; 21:3–4?",
        "feedbackCorrect": "Certo: visão do povo salvo, presença de Deus, consolo final.",
        "feedbackWrong": {
            "b": "A habitação aprofunda a visão da multidão.",
            "c": "Enxugar lágrimas revela o sentido da esperança.",
        },
        "options": opt(
            ("a", "Multidão salva diante do Cordeiro"),
            ("b", "Deus habita com os homens"),
            ("c", "Toda lágrima é enxugada"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": 'Complete: "eles serão o seu ___"',
        "feedbackCorrect": "Certo: o seu povo.",
        "feedbackWrong": {
            "b": "Vestiduras descrevem a multidão; a lacuna é povo.",
            "c": "Palmas estão nas mãos; a lacuna é povo.",
        },
        "template": "eles serão o seu ___",
        "options": opt(("a", "povo"), ("b", "vestiduras"), ("c", "palmas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Apocalipse 7:9; 21:3–4 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: esperança final — salvos e Deus que enxuga lágrimas.",
        "feedbackWrong": {
            "a": "Não é só visão sem consolo.",
            "c": "Não é só consolo sem a multidão do Cordeiro.",
        },
        "passageA": {"ref": "Apocalipse 7:9; 21:3–4", "text": "multidão… Cordeiro… tabernáculo… lágrima"},
        "passageB": {"ref": "Contexto", "text": insight},
        "options": opt(
            ("a", "Visão sem consolo"),
            ("b", "Esperança final"),
            ("c", "Consolo sem Cordeiro"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

assert len(Qs) == 144, len(Qs)

out = Path(__file__).resolve().parent / "apocalipse.json"
out.write_text(json.dumps(Qs, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {len(Qs)} questions → {out}")
