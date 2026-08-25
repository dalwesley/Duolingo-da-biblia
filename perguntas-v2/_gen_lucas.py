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
    "Disse-lhes o anjo: Não temais; pois eu vos trago uma boa-nova de grande gozo "
    "que o será para todo o povo: é que hoje vos nasceu na cidade de Davi um Salvador, "
    "que é Cristo Senhor."
)
P2 = (
    "Digo-vos que assim haverá maior júbilo no céu por um pecador que se arrepende "
    "do que por noventa e nove justos que não necessitam de arrependimento."
)
P3 = (
    "Estando para se completarem os dias em que devia ser recebido no céu, "
    "manifestou a firme resolução de ir a Jerusalém e enviou mensageiros adiante de si."
)
P4 = (
    "e disse-lhes: Assim está escrito que o Cristo padecesse e ressurgisse dentre os mortos "
    "ao terceiro dia e que, em seu nome, se pregasse arrependimento para remissão de pecados "
    "a todas as nações, começando por Jerusalém."
)
P5 = "porque o Filho do Homem veio buscar e salvar o que se havia perdido."

I1 = "O Salvador dos humildes nasce na cidade de Davi: boa-nova de grande gozo para todo o povo."
I2 = "A misericórdia que busca: o céu jubila por um pecador que se arrepende."
I3 = "Rumo a Jerusalém: Jesus firma o rosto para ser recebido no céu — o caminho é escolha, não acaso."
I4 = "A vitória do Cristo: padecer, ressurgir e pregar remissão a todas as nações, começando por Jerusalém."
I5 = "O Salvador que busca: veio buscar e salvar o perdido — esse é o fio de Lucas."

LO1 = "Sair sabendo que o anjo anuncia boa-nova de grande gozo: nasceu na cidade de Davi um Salvador, Cristo Senhor."
LO2 = "Sair sabendo que o céu jubila mais por um pecador que se arrepende do que por noventa e nove justos."
LO3 = "Sair sabendo que Jesus manifesta firme resolução de ir a Jerusalém para ser recebido no céu."
LO4 = "Sair sabendo que o Cristo padece, ressurge ao terceiro dia e se prega remissão a todas as nações, começando por Jerusalém."
LO5 = "Sair sabendo que o Filho do Homem veio buscar e salvar o que se havia perdido — o fio de Lucas."


def base(diff, typ, nn, section, verse, lo, ev, passage):
    return {
        "difficulty": diff,
        "skill": SK[diff],
        "verseRef": verse,
        "learningObjective": lo,
        "evidence": ev,
        "type": typ,
        "trail": "lucas",
        "section": section,
        "id": f"lucas-{SHORT[diff]}-{section}-{nn}",
        "passageText": passage,
    }


def merge(b, extra):
    d = dict(b)
    d.update(extra)
    return q(**d)


Qs = []

# ── M1 ──────────────────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "lc-01-salvador-humilde",
    "Lucas 2:10–11",
    LO1,
    ["Lucas 2:10", "Lucas 2:11"],
    P1,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O anjo diz que hoje nasceu na cidade de Davi um Salvador, que é Cristo Senhor.",
        "feedbackCorrect": "Certo: o anjo anuncia o Salvador nascido na cidade de Davi.",
        "feedbackWrong": {"false": "Releia Lucas 2:11: nasceu um Salvador, Cristo Senhor."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 2:10–11, toque a palavra que falta em \"hoje vos nasceu na cidade de Davi um ___, que é Cristo Senhor\"?",
        "feedbackCorrect": "Exato: o nascido é um Salvador.",
        "feedbackWrong": {"b": "Cristo identifica quem é o Salvador, não esta lacuna.", "c": "Davi nomeia a cidade, não o nascido."},
        "template": "hoje vos nasceu na cidade de Davi um ___, que é Cristo Senhor",
        "options": opt(("a", "Salvador"), ("b", "Cristo"), ("c", "Davi")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que o anjo afirma trazer ao povo em Lucas 2:10–11?",
        "feedbackCorrect": "Certo: uma boa-nova de grande gozo para todo o povo.",
        "feedbackWrong": {
            "a": "O anjo começa com Não temais, não com um aviso de juízo.",
            "c": "O anúncio é para todo o povo, não só para um rei.",
            "d": "O Salvador nasceu hoje, não é prometido para outro século.",
        },
        "options": opt(
            ("a", "Um aviso de juízo imediato sobre Belém"),
            ("b", "Uma boa-nova de grande gozo para todo o povo"),
            ("c", "Uma mensagem só para o palácio de Herodes"),
            ("d", "A promessa de um Salvador ainda por nascer"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Lucas 2:10–11?",
        "feedbackCorrect": "Certo: o anjo acalma, anuncia a boa-nova e identifica o Salvador.",
        "feedbackWrong": {"b": "A boa-nova vem depois de Não temais.", "c": "O nascimento do Salvador fecha o anúncio."},
        "options": opt(
            ("a", "Disse-lhes o anjo: Não temais"),
            ("b", "pois eu vos trago uma boa-nova de grande gozo que o será para todo o povo"),
            ("c", "é que hoje vos nasceu na cidade de Davi um Salvador, que é Cristo Senhor"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"hoje vos nasceu na cidade de ___ um Salvador\"",
        "feedbackCorrect": "Certo: o nascimento é na cidade de Davi.",
        "feedbackWrong": {"a": "Salvador é quem nasceu, não o nome da cidade.", "c": "Povo recebe a boa-nova, não nomeia a cidade."},
        "template": "hoje vos nasceu na cidade de ___ um Salvador",
        "options": opt(("a", "Salvador"), ("b", "Davi"), ("c", "povo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 2:10–11 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a boa-nova é o Salvador nascido na cidade de Davi.",
        "feedbackWrong": {"b": "O anjo traz gozo, não um silêncio sobre o nascimento.", "c": "O anúncio é para todo o povo, não um segredo de palácio."},
        "passageA": {"ref": "Lucas 2:10–11", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Boa-nova na cidade de Davi"),
            ("b", "Silêncio sobre o nascimento"),
            ("c", "Segredo só para reis"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A boa-nova do anjo restringe o gozo a um grupo pequeno, excluindo o resto do povo.",
        "feedbackCorrect": "Certo: o gozo será para todo o povo.",
        "feedbackWrong": {"true": "O texto diz que o gozo será para todo o povo."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 2:10–11, toque a palavra que falta em \"uma boa-nova de grande ___ que o será para todo o povo\"?",
        "feedbackCorrect": "Exato: a boa-nova é de grande gozo.",
        "feedbackWrong": {"a": "Povo recebe o gozo, não preenche esta lacuna.", "c": "Temais pertence ao Não temais, não a esta frase."},
        "template": "uma boa-nova de grande ___ que o será para todo o povo",
        "options": opt(("a", "povo"), ("b", "gozo"), ("c", "temais")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como o anúncio une o lugar do nascimento e a identidade do nascido?",
        "feedbackCorrect": "Certo: na cidade de Davi nasce o Salvador, Cristo Senhor.",
        "feedbackWrong": {
            "b": "O texto une cidade de Davi e Salvador; não os separa.",
            "c": "Cristo Senhor identifica o Salvador, não o apaga.",
            "d": "O anjo traz boa-nova, não um recado político local.",
        },
        "options": opt(
            ("a", "Na cidade de Davi nasce o Salvador, que é Cristo Senhor"),
            ("b", "O lugar do nascimento não tem ligação com quem ele é"),
            ("c", "Cristo Senhor substitui a ideia de Salvador no anúncio"),
            ("d", "O anjo só informa geografia, sem nomear o nascido"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Lucas 2:10–11?",
        "feedbackCorrect": "Certo: sem temor, boa-nova ao povo, Salvador em Davi.",
        "feedbackWrong": {"b": "A boa-nova ao povo vem depois de Não temais.", "c": "O Salvador na cidade de Davi fecha o anúncio."},
        "options": opt(
            ("a", "Não temais"),
            ("b", "eu vos trago uma boa-nova de grande gozo que o será para todo o povo"),
            ("c", "hoje vos nasceu na cidade de Davi um Salvador"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"que o será para todo o ___\"",
        "feedbackCorrect": "Certo: a boa-nova é para todo o povo.",
        "feedbackWrong": {"a": "Gozo descreve a boa-nova, não quem a recebe aqui.", "c": "Anjo é quem fala, não o destinatário desta frase."},
        "template": "que o será para todo o ___",
        "options": opt(("a", "gozo"), ("b", "povo"), ("c", "anjo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 2:10–11 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o gozo da boa-nova alcança todo o povo.",
        "feedbackWrong": {"a": "O anúncio não reserva o gozo a uma elite.", "c": "O Salvador já nasceu hoje, não ficou só como título vazio."},
        "passageA": {"ref": "Lucas 2:10–11", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Gozo só para os poderosos"),
            ("b", "Gozo para todo o povo"),
            ("c", "Título sem nascimento real"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O anúncio identifica o nascido como Salvador, Cristo Senhor, e não como um herói privado de um só clã.",
        "feedbackCorrect": "Certo: Salvador, Cristo Senhor, para todo o povo.",
        "feedbackWrong": {"false": "O texto une Salvador, Cristo Senhor e todo o povo."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 2:10–11, toque a palavra que falta em \"um Salvador, que é Cristo ___\"?",
        "feedbackCorrect": "Exato: o Salvador é Cristo Senhor.",
        "feedbackWrong": {"a": "Anjo é quem fala, não o título do Salvador.", "b": "Cidade localiza o nascimento, não completa este título."},
        "template": "um Salvador, que é Cristo ___",
        "options": opt(("a", "anjo"), ("b", "cidade"), ("c", "Senhor")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que o leitor deve perceber no título Salvador, Cristo Senhor, nascido hoje?",
        "feedbackCorrect": "Certo: Deus cumpre a esperança davídica num Salvador presente.",
        "feedbackWrong": {
            "a": "O anúncio não reduz Cristo a um símbolo sem nascimento.",
            "c": "Não temais abre gozo, não pânico de abandono.",
            "d": "O Salvador é para todo o povo, não um ídolo local.",
        },
        "options": opt(
            ("a", "O título é só poesia, sem alguém realmente nascido"),
            ("b", "A esperança de Davi se cumpre num Salvador já presente"),
            ("c", "Não temais significa que Deus abandonou o povo"),
            ("d", "Cristo Senhor é um ídolo da cidade, não o Salvador"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Lucas 2:10–11?",
        "feedbackCorrect": "Certo: sem temor, gozo ao povo, Salvador que é Cristo Senhor.",
        "feedbackWrong": {"b": "O gozo ao povo vem depois de Não temais.", "c": "Cristo Senhor identifica o Salvador no fim."},
        "options": opt(
            ("a", "Não temais"),
            ("b", "uma boa-nova de grande gozo que o será para todo o povo"),
            ("c", "um Salvador, que é Cristo Senhor"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"pois eu vos trago uma ___ de grande gozo\"",
        "feedbackCorrect": "Certo: o anjo traz uma boa-nova.",
        "feedbackWrong": {"b": "Gozo descreve a boa-nova, não substitui a palavra.", "c": "Nasceu descreve o fato, não o que o anjo traz aqui."},
        "template": "pois eu vos trago uma ___ de grande gozo",
        "options": opt(("a", "boa-nova"), ("b", "gozo"), ("c", "nasceu")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 2:10–11 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Salvador dos humildes nasce na cidade de Davi.",
        "feedbackWrong": {"b": "O anúncio não trata o nascimento como acidente.", "c": "Cristo Senhor não é um título vazio sem Salvador."},
        "passageA": {"ref": "Lucas 2:10–11", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Salvador nasce na cidade de Davi"),
            ("b", "Nascimento como acaso histórico"),
            ("c", "Título vazio sem Salvador"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M2 ──────────────────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "lc-02-misericordia",
    "Lucas 15:7",
    LO2,
    ["Lucas 15:7"],
    P2,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Haverá maior júbilo no céu por um pecador que se arrepende do que por noventa e nove justos que não necessitam de arrependimento.",
        "feedbackCorrect": "Certo: o texto compara o júbilo exatamente assim.",
        "feedbackWrong": {"false": "Releia Lucas 15:7: maior júbilo por um pecador que se arrepende."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 15:7, toque a palavra que falta em \"maior júbilo no céu por um ___ que se arrepende\"?",
        "feedbackCorrect": "Exato: o júbilo é por um pecador que se arrepende.",
        "feedbackWrong": {"b": "Justos entram na comparação, não nesta lacuna.", "c": "Céu é o lugar do júbilo, não quem se arrepende."},
        "template": "maior júbilo no céu por um ___ que se arrepende",
        "options": opt(("a", "pecador"), ("b", "justos"), ("c", "céu")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Segundo Lucas 15:7, onde haverá maior júbilo por um pecador que se arrepende?",
        "feedbackCorrect": "Certo: o maior júbilo é no céu.",
        "feedbackWrong": {
            "a": "O texto situa o júbilo no céu, não num tribunal.",
            "c": "Não se fala de silêncio no deserto.",
            "d": "A comparação não localiza o júbilo num palácio.",
        },
        "options": opt(
            ("a", "Num tribunal de justos na terra"),
            ("b", "No céu"),
            ("c", "Num deserto de silêncio"),
            ("d", "Num palácio de Herodes"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Lucas 15:7?",
        "feedbackCorrect": "Certo: maior júbilo, pecador que se arrepende, justos sem necessidade.",
        "feedbackWrong": {"b": "O pecador que se arrepende vem antes da comparação com os justos.", "c": "Os justos fecham a comparação."},
        "options": opt(
            ("a", "assim haverá maior júbilo no céu"),
            ("b", "por um pecador que se arrepende"),
            ("c", "do que por noventa e nove justos que não necessitam de arrependimento"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"maior ___ no céu por um pecador que se arrepende\"",
        "feedbackCorrect": "Certo: o texto fala de maior júbilo no céu.",
        "feedbackWrong": {"b": "Pecador é quem se arrepende, não o que há no céu aqui.", "c": "Justos entram depois, nesta comparação."},
        "template": "maior ___ no céu por um pecador que se arrepende",
        "options": opt(("a", "júbilo"), ("b", "pecador"), ("c", "justos")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 15:7 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o céu jubila por um pecador que se arrepende.",
        "feedbackWrong": {"b": "O texto não descreve indiferença celestial.", "c": "O júbilo maior não é pela recusa de arrepender-se."},
        "passageA": {"ref": "Lucas 15:7", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Céu jubila pelo que se arrepende"),
            ("b", "Céu indiferente ao pecador"),
            ("c", "Júbilo pela recusa de voltar"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O júbilo do céu é maior pelos noventa e nove justos do que pelo pecador que se arrepende.",
        "feedbackCorrect": "Certo: o maior júbilo é pelo pecador que se arrepende.",
        "feedbackWrong": {"true": "Lucas 15:7 inverte isso: maior júbilo pelo que se arrepende."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 15:7, toque a palavra que falta em \"por um pecador que se ___\"?",
        "feedbackCorrect": "Exato: o pecador se arrepende.",
        "feedbackWrong": {"a": "Necessitam refere-se aos justos, não a esta lacuna.", "c": "Júbilo é o que há no céu, não o verbo do pecador."},
        "template": "por um pecador que se ___",
        "options": opt(("a", "necessitam"), ("b", "arrepende"), ("c", "júbilo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que a comparação de Lucas 15:7 mostra sobre o valor do arrependimento?",
        "feedbackCorrect": "Certo: um arrependido pesa mais no júbilo do céu que noventa e nove justos.",
        "feedbackWrong": {
            "a": "O texto não trata o arrependimento como irrelevante.",
            "c": "Os justos não anulam o júbilo pelo que volta.",
            "d": "O céu não fica mudo diante do pecador que se arrepende.",
        },
        "options": opt(
            ("a", "O arrependimento de um não altera o júbilo do céu"),
            ("b", "Um que se arrepende gera maior júbilo que noventa e nove justos"),
            ("c", "Os justos tornam inútil o retorno do pecador"),
            ("d", "O céu só se alegra quando ninguém precisa voltar"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Lucas 15:7?",
        "feedbackCorrect": "Certo: o dito, o pecador que se arrepende, os justos sem necessidade.",
        "feedbackWrong": {"b": "O pecador que se arrepende vem no meio da comparação.", "c": "Os justos fecham o contraste."},
        "options": opt(
            ("a", "Digo-vos que assim haverá maior júbilo no céu"),
            ("b", "por um pecador que se arrepende"),
            ("c", "noventa e nove justos que não necessitam de arrependimento"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"justos que não necessitam de ___\"",
        "feedbackCorrect": "Certo: os justos não necessitam de arrependimento.",
        "feedbackWrong": {"a": "Júbilo descreve o céu, não o que os justos não necessitam.", "b": "Pecador é quem se arrepende, não esta lacuna."},
        "template": "justos que não necessitam de ___",
        "options": opt(("a", "júbilo"), ("b", "pecador"), ("c", "arrependimento")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 15:7 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a misericórdia busca e o céu jubila no retorno.",
        "feedbackWrong": {"a": "O texto não iguala o pecador arrependido a um justo que não volta.", "c": "O júbilo não é maior pela recusa de arrepender-se."},
        "passageA": {"ref": "Lucas 15:7", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Pecador e justo valem igual no céu"),
            ("b", "Misericórdia jubila no retorno"),
            ("c", "Maior júbilo pela recusa"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O texto prepara o leitor para ver o arrependimento de um só como motivo de júbilo celestial, não como perda insignificante.",
        "feedbackCorrect": "Certo: um que se arrepende pesa no júbilo do céu.",
        "feedbackWrong": {"false": "Lucas 15:7 faz do um arrependido o centro do júbilo."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 15:7, toque a palavra que falta em \"noventa e nove ___ que não necessitam de arrependimento\"?",
        "feedbackCorrect": "Exato: a comparação é com noventa e nove justos.",
        "feedbackWrong": {"a": "Pecador é o um que se arrepende, não este grupo.", "c": "Céu é o lugar do júbilo, não o grupo comparado."},
        "template": "noventa e nove ___ que não necessitam de arrependimento",
        "options": opt(("a", "pecador"), ("b", "justos"), ("c", "céu")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que erro de leitura Lucas 15:7 corrige sobre a misericórdia de Deus?",
        "feedbackCorrect": "Certo: o céu não prefere o que não precisa voltar ao que se arrepende.",
        "feedbackWrong": {
            "a": "O texto não trata o arrependimento como ameaça ao céu.",
            "c": "O um não é estatística irrelevante.",
            "d": "Os justos não são o único objeto do júbilo divino.",
        },
        "options": opt(
            ("a", "O céu se ofende quando um pecador se arrepende"),
            ("b", "Deus não reserva o maior júbilo só aos que não precisam voltar"),
            ("c", "Um arrependido não conta diante da maioria"),
            ("d", "Só os justos despertam o júbilo do céu"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Lucas 15:7?",
        "feedbackCorrect": "Certo: júbilo no céu, um que se arrepende, contraste com os justos.",
        "feedbackWrong": {"b": "O pecador que se arrepende está no centro, não no fim.", "c": "Os justos fecham o contraste."},
        "options": opt(
            ("a", "maior júbilo no céu"),
            ("b", "um pecador que se arrepende"),
            ("c", "noventa e nove justos que não necessitam de arrependimento"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"maior júbilo no ___ por um pecador que se arrepende\"",
        "feedbackCorrect": "Certo: o júbilo é no céu.",
        "feedbackWrong": {"b": "Pecador é quem se arrepende, não o lugar do júbilo.", "c": "Arrepende é o verbo, não o lugar."},
        "template": "maior júbilo no ___ por um pecador que se arrepende",
        "options": opt(("a", "céu"), ("b", "pecador"), ("c", "arrepende")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 15:7 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a misericórdia que busca faz o céu jubilar no retorno.",
        "feedbackWrong": {"b": "O texto não apresenta um céu fechado ao pecador.", "c": "O júbilo não é pela recusa de arrependimento."},
        "passageA": {"ref": "Lucas 15:7", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Misericórdia que busca e jubila"),
            ("b", "Céu fechado ao pecador"),
            ("c", "Júbilo pela recusa"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M3 ──────────────────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "lc-03-caminho-jerusalem",
    "Lucas 9:51",
    LO3,
    ["Lucas 9:51"],
    P3,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Estando para se completarem os dias em que devia ser recebido no céu, Jesus manifestou a firme resolução de ir a Jerusalém.",
        "feedbackCorrect": "Certo: o texto une o prazo do céu e a resolução de ir.",
        "feedbackWrong": {"false": "Releia Lucas 9:51: firme resolução de ir a Jerusalém."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 9:51, toque a palavra que falta em \"manifestou a firme resolução de ir a ___\"?",
        "feedbackCorrect": "Exato: a resolução é ir a Jerusalém.",
        "feedbackWrong": {"b": "Céu é o destino de ser recebido, não esta lacuna.", "c": "Mensageiros são enviados, não o destino desta frase."},
        "template": "manifestou a firme resolução de ir a ___",
        "options": opt(("a", "Jerusalém"), ("b", "céu"), ("c", "mensageiros")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Jesus fez depois de manifestar a firme resolução de ir a Jerusalém?",
        "feedbackCorrect": "Certo: enviou mensageiros adiante de si.",
        "feedbackWrong": {
            "b": "O texto não diz que ele recuou.",
            "c": "Ele enviou mensageiros, não ficou parado.",
            "d": "Não se fala de esconder o caminho.",
        },
        "options": opt(
            ("a", "Enviou mensageiros adiante de si"),
            ("b", "Desistiu da viagem e voltou"),
            ("c", "Ficou em silêncio sem enviar ninguém"),
            ("d", "Escondeu o destino da viagem"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Lucas 9:51?",
        "feedbackCorrect": "Certo: dias a completar, resolução de ir, mensageiros adiante.",
        "feedbackWrong": {"b": "A resolução de ir vem depois dos dias a completar.", "c": "Os mensageiros são enviados por último."},
        "options": opt(
            ("a", "Estando para se completarem os dias em que devia ser recebido no céu"),
            ("b", "manifestou a firme resolução de ir a Jerusalém"),
            ("c", "e enviou mensageiros adiante de si"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"manifestou a firme ___ de ir a Jerusalém\"",
        "feedbackCorrect": "Certo: ele manifestou firme resolução.",
        "feedbackWrong": {"b": "Mensageiros são enviados depois, não esta palavra.", "c": "Dias se completam, não preenchem esta lacuna."},
        "template": "manifestou a firme ___ de ir a Jerusalém",
        "options": opt(("a", "resolução"), ("b", "mensageiros"), ("c", "dias")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 9:51 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Jesus firma o caminho para Jerusalém.",
        "feedbackWrong": {"b": "O texto não descreve um desvio casual.", "c": "Há resolução explícita, não recuo."},
        "passageA": {"ref": "Lucas 9:51", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Firme rumo a Jerusalém"),
            ("b", "Caminho como acaso"),
            ("c", "Recuo diante da cidade"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A ida a Jerusalém aparece no texto como um acaso, sem ligação com ser recebido no céu.",
        "feedbackCorrect": "Certo: os dias de ser recebido no céu enquadram a resolução.",
        "feedbackWrong": {"true": "Lucas 9:51 liga o prazo do céu à resolução de ir."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 9:51, toque a palavra que falta em \"enviou ___ adiante de si\"?",
        "feedbackCorrect": "Exato: enviou mensageiros adiante de si.",
        "feedbackWrong": {"a": "Dias se completam, não são enviados.", "c": "Resolução é o que ele manifesta, não o que envia."},
        "template": "enviou ___ adiante de si",
        "options": opt(("a", "dias"), ("b", "mensageiros"), ("c", "resolução")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Lucas 9:51 liga o prazo de ser recebido no céu e o caminho terreno?",
        "feedbackCorrect": "Certo: o prazo do céu move a resolução de ir a Jerusalém.",
        "feedbackWrong": {
            "b": "O texto não separa o céu da ida a Jerusalém.",
            "c": "Há firme resolução, não hesitação permanente.",
            "d": "Mensageiros adiante confirmam o caminho, não o cancelam.",
        },
        "options": opt(
            ("a", "Os dias de ser recebido no céu movem a ida a Jerusalém"),
            ("b", "Ser recebido no céu dispensa passar por Jerusalém"),
            ("c", "Jesus hesita e deixa o destino indefinido"),
            ("d", "Enviar mensageiros anula a resolução de ir"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Lucas 9:51?",
        "feedbackCorrect": "Certo: ser recebido no céu, ir a Jerusalém, mensageiros adiante.",
        "feedbackWrong": {"b": "Ir a Jerusalém vem depois do prazo do céu.", "c": "Os mensageiros fecham o movimento."},
        "options": opt(
            ("a", "devia ser recebido no céu"),
            ("b", "firme resolução de ir a Jerusalém"),
            ("c", "enviou mensageiros adiante de si"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"dias em que devia ser ___ no céu\"",
        "feedbackCorrect": "Certo: ele devia ser recebido no céu.",
        "feedbackWrong": {"b": "Completarem refere-se aos dias, não a esta lacuna.", "c": "Adiante descreve os mensageiros, não o verbo aqui."},
        "template": "dias em que devia ser ___ no céu",
        "options": opt(("a", "recebido"), ("b", "completarem"), ("c", "adiante")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 9:51 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o caminho é escolha firme, não acaso.",
        "feedbackWrong": {"a": "Há resolução manifesta, não deriva sem destino.", "c": "Ele avança a Jerusalém, não foge do prazo."},
        "passageA": {"ref": "Lucas 9:51", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Deriva sem destino"),
            ("b", "Caminho como escolha firme"),
            ("c", "Fuga do prazo do céu"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O leitor é preparado para ver Jerusalém como destino assumido rumo a ser recebido no céu, não como desvio involuntário.",
        "feedbackCorrect": "Certo: a resolução manifesta o sentido do caminho.",
        "feedbackWrong": {"false": "Lucas 9:51 apresenta Jerusalém como resolução, não acaso."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 9:51, toque a palavra que falta em \"devia ser recebido no ___\"?",
        "feedbackCorrect": "Exato: ele devia ser recebido no céu.",
        "feedbackWrong": {"b": "Jerusalém é o destino da viagem, não esta lacuna.", "c": "Firme qualifica a resolução, não o lugar da recepção."},
        "template": "devia ser recebido no ___",
        "options": opt(("a", "céu"), ("b", "Jerusalém"), ("c", "firme")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que leitura teológica Lucas 9:51 impede sobre o caminho de Jesus?",
        "feedbackCorrect": "Certo: a paixão rumo a Jerusalém não é acidente nem recuo.",
        "feedbackWrong": {
            "a": "O texto mostra resolução, não surpresa involuntária.",
            "c": "Mensageiros adiante confirmam o envio, não o cancelam.",
            "d": "O prazo do céu não apaga a ida a Jerusalém.",
        },
        "options": opt(
            ("a", "Jesus foi arrastado a Jerusalém sem querer"),
            ("b", "Ele assume o caminho até ser recebido no céu"),
            ("c", "Enviar mensageiros prova que ele desistiu de ir"),
            ("d", "Ser recebido no céu torna Jerusalém desnecessária"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Lucas 9:51?",
        "feedbackCorrect": "Certo: prazo do céu, resolução, envio adiante.",
        "feedbackWrong": {"b": "A resolução vem depois dos dias a completar.", "c": "Os mensageiros selam o movimento iniciado."},
        "options": opt(
            ("a", "completarem os dias em que devia ser recebido no céu"),
            ("b", "manifestou a firme resolução de ir a Jerusalém"),
            ("c", "enviou mensageiros adiante de si"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"Estando para se ___ os dias\"",
        "feedbackCorrect": "Certo: os dias estavam para se completarem.",
        "feedbackWrong": {"b": "Recebido refere-se a ele no céu, não aos dias aqui.", "c": "Manifestou é o verbo seguinte, não esta lacuna."},
        "template": "Estando para se ___ os dias",
        "options": opt(("a", "completarem"), ("b", "recebido"), ("c", "manifestou")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 9:51 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: firmar o rosto a Jerusalém é ser recebido no céu.",
        "feedbackWrong": {"b": "O texto não trata o caminho como acaso.", "c": "Há avanço, não recuo da resolução."},
        "passageA": {"ref": "Lucas 9:51", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Rosto firme rumo ao céu"),
            ("b", "Caminho como acaso"),
            ("c", "Recuo da resolução"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M4 ──────────────────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "lc-04-vitoria-ressurreicao",
    "Lucas 24:46–47",
    LO4,
    ["Lucas 24:46", "Lucas 24:47"],
    P4,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Está escrito que o Cristo padecesse e ressurgisse dentre os mortos ao terceiro dia.",
        "feedbackCorrect": "Certo: padecer e ressurgir ao terceiro dia estão escritos.",
        "feedbackWrong": {"false": "Releia Lucas 24:46: padecesse e ressurgisse ao terceiro dia."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 24:46–47, toque a palavra que falta em \"o Cristo padecesse e ___ dentre os mortos ao terceiro dia\"?",
        "feedbackCorrect": "Exato: o Cristo ressurgisse dentre os mortos.",
        "feedbackWrong": {"b": "Padecesse vem antes, não preenche esta lacuna.", "c": "Pregasse refere-se ao anúncio, não a esta frase."},
        "template": "o Cristo padecesse e ___ dentre os mortos ao terceiro dia",
        "options": opt(("a", "ressurgisse"), ("b", "padecesse"), ("c", "pregasse")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que, em nome do Cristo, deve ser pregado segundo Lucas 24:46–47?",
        "feedbackCorrect": "Certo: arrependimento para a remissão de pecados.",
        "feedbackWrong": {
            "a": "O texto fala de remissão, não de vingança.",
            "c": "O anúncio começa por Jerusalém, não a exclui.",
            "d": "Prega-se arrependimento, não a negação da ressurreição.",
        },
        "options": opt(
            ("a", "Vingança contra todas as nações"),
            ("b", "Arrependimento para remissão de pecados"),
            ("c", "Silêncio sobre Jerusalém"),
            ("d", "Que o Cristo não ressurgiu"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Lucas 24:46–47?",
        "feedbackCorrect": "Certo: padecer, ressurgir, pregar remissão às nações.",
        "feedbackWrong": {"b": "Ressurgir vem depois de padecer.", "c": "A pregação às nações fecha o trecho."},
        "options": opt(
            ("a", "o Cristo padecesse"),
            ("b", "e ressurgisse dentre os mortos ao terceiro dia"),
            ("c", "se pregasse arrependimento para remissão de pecados a todas as nações"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"começando por ___\"",
        "feedbackCorrect": "Certo: a pregação começa por Jerusalém.",
        "feedbackWrong": {"b": "Nações recebem o anúncio, mas o começo é Jerusalém.", "c": "Mortos liga-se à ressurreição, não a este começo."},
        "template": "começando por ___",
        "options": opt(("a", "Jerusalém"), ("b", "nações"), ("c", "mortos")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 24:46–47 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: padecer, ressurgir e pregar remissão.",
        "feedbackWrong": {"b": "O texto une paixão e ressurreição, não as separa.", "c": "Há pregação às nações, não silêncio."},
        "passageA": {"ref": "Lucas 24:46–47", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Padecer, ressurgir e pregar"),
            ("b", "Paixão sem ressurreição"),
            ("c", "Silêncio às nações"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A pregação em nome do Cristo fica restrita a um só povo e nunca começa em Jerusalém.",
        "feedbackCorrect": "Certo: é a todas as nações, começando por Jerusalém.",
        "feedbackWrong": {"true": "Lucas 24:47: a todas as nações, começando por Jerusalém."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 24:46–47, toque a palavra que falta em \"arrependimento para ___ de pecados\"?",
        "feedbackCorrect": "Exato: arrependimento para remissão de pecados.",
        "feedbackWrong": {"b": "Nações recebem o anúncio, não preenchem esta lacuna.", "c": "Nome é em cujo nome se prega, não esta palavra."},
        "template": "arrependimento para ___ de pecados",
        "options": opt(("a", "remissão"), ("b", "nações"), ("c", "nome")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como o texto encadeia o sofrimento do Cristo e a missão posterior?",
        "feedbackCorrect": "Certo: o escrito une paixão, ressurreição e pregação de remissão.",
        "feedbackWrong": {
            "b": "A ressurreição não cancela a pregação; a abre.",
            "c": "O nome do Cristo é o lugar da pregação, não um detalhe.",
            "d": "Começar por Jerusalém não exclui as nações.",
        },
        "options": opt(
            ("a", "Paixão e ressurreição abrem a pregação de remissão às nações"),
            ("b", "Ressurgir dispensa pregar arrependimento"),
            ("c", "Pregar em seu nome é opcional após o terceiro dia"),
            ("d", "Começar por Jerusalém impede alcançar as nações"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Lucas 24:46–47?",
        "feedbackCorrect": "Certo: o escrito, o terceiro dia, a pregação começando por Jerusalém.",
        "feedbackWrong": {"b": "O terceiro dia segue o que está escrito sobre o Cristo.", "c": "Começar por Jerusalém fecha o movimento missionário do trecho."},
        "options": opt(
            ("a", "Assim está escrito que o Cristo padecesse"),
            ("b", "ressurgisse dentre os mortos ao terceiro dia"),
            ("c", "começando por Jerusalém"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"em seu nome, se pregasse ___ para remissão de pecados\"",
        "feedbackCorrect": "Certo: prega-se arrependimento para remissão.",
        "feedbackWrong": {"b": "Remissão é o fruto, não o que se prega nesta lacuna.", "c": "Escrito introduz o trecho, não esta palavra."},
        "template": "em seu nome, se pregasse ___ para remissão de pecados",
        "options": opt(("a", "arrependimento"), ("b", "remissão"), ("c", "escrito")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 24:46–47 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a vitória inclui pregar remissão a todas as nações.",
        "feedbackWrong": {"a": "O escrito não corta a missão nas nações.", "c": "A remissão não fica só como ideia, sem pregação."},
        "passageA": {"ref": "Lucas 24:46–47", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Vitória sem anúncio às nações"),
            ("b", "Remissão anunciada às nações"),
            ("c", "Remissão sem pregação"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O padecimento e a ressurreição do Cristo fundamentam a pregação de arrependimento para remissão, e não a substituem por um triunfo mudo.",
        "feedbackCorrect": "Certo: o escrito une paixão, ressurreição e pregação.",
        "feedbackWrong": {"false": "Lucas 24:46–47 liga o escrito à pregação em seu nome."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 24:46–47, toque a palavra que falta em \"Assim está ___ que o Cristo padecesse\"?",
        "feedbackCorrect": "Exato: assim está escrito.",
        "feedbackWrong": {"b": "Terceiro qualifica o dia, não esta lacuna.", "c": "Pecados ligam-se à remissão, não a esta frase."},
        "template": "Assim está ___ que o Cristo padecesse",
        "options": opt(("a", "escrito"), ("b", "terceiro"), ("c", "pecados")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que erro teológico o trecho impede sobre a vitória do Cristo?",
        "feedbackCorrect": "Certo: a vitória não apaga a paixão nem cala a remissão às nações.",
        "feedbackWrong": {
            "a": "O escrito inclui padecer, não só glória sem cruz.",
            "c": "Começar por Jerusalém não fecha as nações.",
            "d": "A ressurreição não torna o arrependimento obsoleto.",
        },
        "options": opt(
            ("a", "O Cristo vence sem padecer, só ressurgindo"),
            ("b", "Paixão, ressurreição e pregação de remissão formam um só escrito"),
            ("c", "Jerusalém esgota a missão, sem nações"),
            ("d", "A ressurreição dispensa arrependimento e remissão"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Lucas 24:46–47?",
        "feedbackCorrect": "Certo: o escrito, o nome do Cristo, a remissão às nações desde Jerusalém.",
        "feedbackWrong": {"b": "Pregar em seu nome segue o que está escrito.", "c": "Todas as nações desde Jerusalém fecham o sentido."},
        "options": opt(
            ("a", "Assim está escrito"),
            ("b", "em seu nome, se pregasse arrependimento para remissão de pecados"),
            ("c", "a todas as nações, começando por Jerusalém"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"ressurgisse dentre os mortos ao ___ dia\"",
        "feedbackCorrect": "Certo: a ressurreição é ao terceiro dia.",
        "feedbackWrong": {"b": "Cristo é quem ressurge, não o número do dia.", "c": "Nações recebem o anúncio, não qualificam o dia."},
        "template": "ressurgisse dentre os mortos ao ___ dia",
        "options": opt(("a", "terceiro"), ("b", "Cristo"), ("c", "nações")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 24:46–47 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a vitória do Cristo é padecer, ressurgir e pregar remissão.",
        "feedbackWrong": {"b": "O escrito não corta a paixão da vitória.", "c": "A missão não fica muda após o terceiro dia."},
        "passageA": {"ref": "Lucas 24:46–47", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Vitória: padecer e pregar remissão"),
            ("b", "Vitória sem paixão"),
            ("c", "Terceiro dia sem missão"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M5 ──────────────────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "lc-boss-revisao",
    "Lucas 19:10",
    LO5,
    ["Lucas 19:10"],
    P5,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O Filho do Homem veio buscar e salvar o que se havia perdido.",
        "feedbackCorrect": "Certo: veio buscar e salvar o perdido.",
        "feedbackWrong": {"false": "Releia Lucas 19:10: buscar e salvar o que se havia perdido."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 19:10, toque a palavra que falta em \"veio ___ e salvar o que se havia perdido\"?",
        "feedbackCorrect": "Exato: veio buscar e salvar.",
        "feedbackWrong": {"b": "Salvar completa o par, mas não esta lacuna.", "c": "Perdido é o objeto, não o primeiro verbo."},
        "template": "veio ___ e salvar o que se havia perdido",
        "options": opt(("a", "buscar"), ("b", "salvar"), ("c", "perdido")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Segundo Lucas 19:10, o que o Filho do Homem veio fazer?",
        "feedbackCorrect": "Certo: buscar e salvar o que se havia perdido.",
        "feedbackWrong": {
            "b": "O texto não diz que ele veio condenar o perdido.",
            "c": "Ele veio, não ficou distante.",
            "d": "O alvo é o perdido, não ignorá-lo.",
        },
        "options": opt(
            ("a", "Buscar e salvar o que se havia perdido"),
            ("b", "Condenar o que se havia perdido"),
            ("c", "Esperar que o perdido se ache sozinho"),
            ("d", "Ignorar o que se havia perdido"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Lucas 19:10?",
        "feedbackCorrect": "Certo: o Filho do Homem veio, busca e salva o perdido.",
        "feedbackWrong": {"b": "Buscar vem depois de veio.", "c": "O perdido é o objeto final da ação."},
        "options": opt(
            ("a", "o Filho do Homem veio"),
            ("b", "buscar e salvar"),
            ("c", "o que se havia perdido"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"veio buscar e ___ o que se havia perdido\"",
        "feedbackCorrect": "Certo: veio buscar e salvar.",
        "feedbackWrong": {"b": "Buscar é o outro verbo, não esta lacuna.", "c": "Veio introduz a vinda, não o segundo verbo."},
        "template": "veio buscar e ___ o que se havia perdido",
        "options": opt(("a", "salvar"), ("b", "buscar"), ("c", "veio")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 19:10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Salvador veio buscar e salvar o perdido.",
        "feedbackWrong": {"b": "O texto não descreve um Salvador distante.", "c": "Há busca, não abandono do perdido."},
        "passageA": {"ref": "Lucas 19:10", "text": P5},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Veio buscar e salvar"),
            ("b", "Salvador que não se aproxima"),
            ("c", "Abandono do perdido"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O Filho do Homem veio apenas observar o perdido, sem buscar nem salvar.",
        "feedbackCorrect": "Certo: o texto une buscar e salvar.",
        "feedbackWrong": {"true": "Lucas 19:10 diz veio buscar e salvar, não só observar."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 19:10, toque a palavra que falta em \"salvar o que se havia ___\"?",
        "feedbackCorrect": "Exato: salvar o que se havia perdido.",
        "feedbackWrong": {"a": "Filho nomeia quem veio, não o estado do objeto.", "c": "Homem completa o título, não esta lacuna."},
        "template": "salvar o que se havia ___",
        "options": opt(("a", "Filho"), ("b", "perdido"), ("c", "Homem")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Lucas 19:10 une a identidade de Jesus e a missão que resume o evangelho?",
        "feedbackCorrect": "Certo: o Filho do Homem veio em busca salvadora do perdido.",
        "feedbackWrong": {
            "b": "O título não anula a busca; a dispara.",
            "c": "Buscar e salvar andam juntos, não se excluem.",
            "d": "O perdido é o alvo, não um detalhe opcional.",
        },
        "options": opt(
            ("a", "O Filho do Homem veio para buscar e salvar o perdido"),
            ("b", "Ser Filho do Homem dispensa aproximar-se do perdido"),
            ("c", "Buscar o perdido torna desnecessário salvá-lo"),
            ("d", "O perdido não entra na missão do Filho do Homem"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Lucas 19:10?",
        "feedbackCorrect": "Certo: o Filho do Homem, a vinda, buscar e salvar o perdido.",
        "feedbackWrong": {"b": "Veio segue a identidade do Filho do Homem.", "c": "Buscar e salvar o perdido fecha o propósito."},
        "options": opt(
            ("a", "o Filho do Homem"),
            ("b", "veio"),
            ("c", "buscar e salvar o que se havia perdido"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"o Filho do ___ veio buscar e salvar\"",
        "feedbackCorrect": "Certo: o Filho do Homem.",
        "feedbackWrong": {"b": "Filho abre o título, não completa do ___.", "c": "Perdido é o objeto, não o título."},
        "template": "o Filho do ___ veio buscar e salvar",
        "options": opt(("a", "Homem"), ("b", "Filho"), ("c", "perdido")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 19:10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o fio de Lucas é o Salvador que busca o perdido.",
        "feedbackWrong": {"a": "O texto não apresenta um juiz que só condena.", "c": "Há movimento até o perdido, não espera passiva."},
        "passageA": {"ref": "Lucas 19:10", "text": P5},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Juiz que só condena"),
            ("b", "Salvador que busca o perdido"),
            ("c", "Espera passiva do perdido"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Lucas 19:10 resume o fio do evangelho: o Filho do Homem assume a iniciativa de buscar e salvar o perdido.",
        "feedbackCorrect": "Certo: a vinda é iniciativa salvadora, não recuo.",
        "feedbackWrong": {"false": "O versículo condensa buscar e salvar como propósito da vinda."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Lucas 19:10, toque a palavra que falta em \"o Filho do Homem ___ buscar e salvar\"?",
        "feedbackCorrect": "Exato: o Filho do Homem veio.",
        "feedbackWrong": {"b": "Salvar é o segundo verbo, não esta lacuna.", "c": "Perdido é o objeto, não o verbo da vinda."},
        "template": "o Filho do Homem ___ buscar e salvar",
        "options": opt(("a", "veio"), ("b", "salvar"), ("c", "perdido")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura o versículo sustenta sobre a vinda do Filho do Homem?",
        "feedbackCorrect": "Certo: ele veio de fato buscar e salvar o perdido.",
        "feedbackWrong": {
            "b": "O texto não deixa o perdido achar-se sozinho.",
            "c": "O perdido pertence ao propósito da vinda.",
            "d": "Filho do Homem não é título vazio de missão.",
        },
        "options": opt(
            ("a", "Jesus veio de fato buscar e salvar o perdido"),
            ("b", "O perdido deve achar-se sozinho, sem ser buscado"),
            ("c", "O perdido não pertence ao propósito da vinda"),
            ("d", "Filho do Homem é só título, sem missão"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Lucas 19:10?",
        "feedbackCorrect": "Certo: identidade, vinda, salvação do perdido.",
        "feedbackWrong": {"b": "A vinda segue o título Filho do Homem.", "c": "O perdido é o alvo que revela o sentido."},
        "options": opt(
            ("a", "o Filho do Homem"),
            ("b", "veio buscar e salvar"),
            ("c", "o que se havia perdido"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"porque o ___ do Homem veio buscar e salvar\"",
        "feedbackCorrect": "Certo: o Filho do Homem veio buscar e salvar.",
        "feedbackWrong": {"b": "Homem completa o título, não abre esta lacuna.", "c": "Buscar é o verbo da missão, não o sujeito."},
        "template": "porque o ___ do Homem veio buscar e salvar",
        "options": opt(("a", "Filho"), ("b", "Homem"), ("c", "buscar")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Lucas 19:10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: esse é o fio de Lucas — o Salvador que busca.",
        "feedbackWrong": {"b": "O evangelho não termina num Cristo distante.", "c": "O perdido não fica fora do fio da narrativa."},
        "passageA": {"ref": "Lucas 19:10", "text": P5},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Fio: Salvador que busca"),
            ("b", "Cristo distante do perdido"),
            ("c", "Perdido fora do evangelho"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]


def check_fc():
    bad = []
    for item in Qs:
        fc = item.get("feedbackCorrect", "")
        if len(fc) > 100:
            bad.append((item["id"], len(fc), fc))
        if item["type"] == "choice":
            for o in item["options"]:
                if len(o["text"]) > 90:
                    bad.append((item["id"], "choice", len(o["text"]), o["text"]))
    return bad


if __name__ == "__main__":
    bad = check_fc()
    if bad:
        print("LENGTH ISSUES:")
        for b in bad:
            print(b)
    out = "/Users/dalwesleyduarte/dev/new/perguntas-v2/lucas.json"
    with open(out, "w", encoding="utf-8") as f:
        json.dump(Qs, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(out, len(Qs))
