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
    "O Verbo se fez carne e habitou entre nós, cheio de graça e de verdade, "
    "e vimos a sua glória, glória como do unigênito do Pai."
)
P2 = (
    "Respondeu-lhe Jesus: Eu sou o caminho, e a verdade, e a vida; "
    "ninguém vem ao Pai senão por mim."
)
P3 = (
    "Eu sou a videira; vós sois as varas. Aquele que permanece em mim "
    "e no qual eu permaneço dá muito fruto, pois sem mim nada podeis fazer."
)
P4 = (
    "Jesus, depois de ter tomado o vinagre, disse: Está consumado; "
    "e, inclinando a cabeça, rendeu o espírito."
)
P5 = (
    "estes, porém, estão escritos para que creiais que Jesus é o Cristo, "
    "o Filho de Deus, e para que, crendo, tenhais vida em seu nome."
)

I1 = "O Verbo se fez carne: os sinais mostram glória do unigênito, cheio de graça e verdade."
I2 = "Eu sou: caminho, verdade e vida — ninguém chega ao Pai por outro."
I3 = "Permaneçam: sem a videira nada; o fruto nasce da união, não da despedida vazia."
I4 = "O Crucificado conclui a obra: está consumado — a cruz não é acidente, é cumprimento."
I5 = "Creia e tenha vida: o livro inteiro aponta para o Cristo, Filho de Deus."

LO1 = "Sair sabendo que o Verbo se fez carne, habitou entre nós e revelou a glória do unigênito, cheio de graça e verdade."
LO2 = "Sair sabendo que Jesus é o caminho, a verdade e a vida, e que ninguém vem ao Pai senão por ele."
LO3 = "Sair sabendo que permanecer na videira é condição do fruto, e que sem Jesus nada se pode fazer."
LO4 = "Sair sabendo que na cruz Jesus declara Está consumado e rende o espírito: a obra se conclui, não se interrompe."
LO5 = "Sair sabendo que João escreveu para que creiamos que Jesus é o Cristo, o Filho de Deus, e tenhamos vida em seu nome."


def base(diff, typ, nn, section, verse, lo, ev, passage):
    return {
        "difficulty": diff,
        "skill": SK[diff],
        "verseRef": verse,
        "learningObjective": lo,
        "evidence": ev,
        "type": typ,
        "trail": "joao",
        "section": section,
        "id": f"joao-{SHORT[diff]}-{section}-{nn}",
        "passageText": passage,
    }


def merge(b, extra):
    d = dict(b)
    d.update(extra)
    return q(**d)


Qs = []

# ── M1 João 1:14 ────────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "jo-01-verbo-sinais",
    "João 1:14",
    LO1,
    ["João 1:14"],
    P1,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O Verbo se fez carne e habitou entre nós, cheio de graça e de verdade.",
        "feedbackCorrect": "Certo: João 1:14 afirma a encarnação do Verbo.",
        "feedbackWrong": {"false": "Releia João 1:14: o Verbo se fez carne e habitou entre nós."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 1:14, toque a palavra que falta em \"O ___ se fez carne e habitou entre nós\"?",
        "feedbackCorrect": "Exato: o sujeito é o Verbo.",
        "feedbackWrong": {"b": "Carne é o que o Verbo se fez, não o sujeito.", "c": "Glória é o que se viu, não quem se fez carne."},
        "template": "O ___ se fez carne e habitou entre nós",
        "options": opt(("a", "Verbo"), ("b", "carne"), ("c", "glória")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que João 1:14 afirma que o Verbo fez?",
        "feedbackCorrect": "Certo: o Verbo se fez carne e habitou entre nós.",
        "feedbackWrong": {
            "b": "O texto não diz que o Verbo permaneceu só no céu.",
            "c": "O texto fala de habitação entre nós, não de recusa da carne.",
            "d": "A glória é vista no encarnado, não em vez da encarnação.",
        },
        "options": opt(
            ("a", "Se fez carne e habitou entre nós"),
            ("b", "Permaneceu distante, sem se fazer carne"),
            ("c", "Recusou habitar entre os homens"),
            ("d", "Mostrou glória sem assumir a carne"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em João 1:14?",
        "feedbackCorrect": "Certo: carne, graça e verdade, depois a glória vista.",
        "feedbackWrong": {"b": "A graça e a verdade descrevem o que habitou entre nós.", "c": "A glória vista vem depois da encarnação."},
        "options": opt(
            ("a", "O Verbo se fez carne e habitou entre nós"),
            ("b", "cheio de graça e de verdade"),
            ("c", "e vimos a sua glória, glória como do unigênito do Pai"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"O Verbo se fez ___ e habitou entre nós\"",
        "feedbackCorrect": "Certo: o Verbo se fez carne.",
        "feedbackWrong": {"a": "Verbo é quem se fez carne, não o que ele se tornou.", "c": "Pai nomeia a origem da glória, não esta lacuna."},
        "template": "O Verbo se fez ___ e habitou entre nós",
        "options": opt(("a", "Verbo"), ("b", "carne"), ("c", "Pai")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 1:14 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a carne revela a glória do unigênito.",
        "feedbackWrong": {"b": "O Verbo não ficou só como ideia, sem carne.", "c": "O texto vê glória, não a nega na encarnação."},
        "passageA": {"ref": "João 1:14", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Carne que revela glória"),
            ("b", "Verbo sem encarnação"),
            ("c", "Glória escondida da carne"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A glória vista em João 1:14 é descrita como glória de um enviado qualquer, sem ligação com o Pai.",
        "feedbackCorrect": "Certo: a glória é como do unigênito do Pai.",
        "feedbackWrong": {"true": "O texto liga a glória ao unigênito do Pai."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 1:14, toque a palavra que falta em \"cheio de graça e de ___\"?",
        "feedbackCorrect": "Exato: o Verbo está cheio de graça e de verdade.",
        "feedbackWrong": {"a": "Graça acompanha a verdade, não preenche esta lacuna.", "c": "Carne nomeia a encarnação, não este par."},
        "template": "cheio de graça e de ___",
        "options": opt(("a", "graça"), ("b", "verdade"), ("c", "carne")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como João 1:14 liga a habitação do Verbo e o que os testemunhas viram?",
        "feedbackCorrect": "Certo: habitou entre nós e vimos a sua glória.",
        "feedbackWrong": {
            "a": "A glória é vista precisamente porque ele habitou entre nós.",
            "c": "O texto une graça e verdade ao encarnado, não as opõe à glória.",
            "d": "Unigênito do Pai identifica a glória, não a apaga.",
        },
        "options": opt(
            ("a", "A habitação esconde a glória de qualquer testemunha"),
            ("b", "Ele habitou entre nós, e vimos a sua glória"),
            ("c", "Graça e verdade substituem a glória no relato"),
            ("d", "A glória vista não tem relação com o Pai"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de João 1:14?",
        "feedbackCorrect": "Certo: encarnação, plenitude, visão da glória.",
        "feedbackWrong": {"b": "A plenitude descreve o que habitou entre nós.", "c": "Ver a glória segue a encarnação."},
        "options": opt(
            ("a", "O Verbo se fez carne e habitou entre nós"),
            ("b", "cheio de graça e de verdade"),
            ("c", "vimos a sua glória"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"glória como do ___ do Pai\"",
        "feedbackCorrect": "Certo: a glória é como do unigênito do Pai.",
        "feedbackWrong": {"a": "Verbo é o sujeito da encarnação, não este título.", "c": "Graça descreve a plenitude, não esta lacuna."},
        "template": "glória como do ___ do Pai",
        "options": opt(("a", "Verbo"), ("b", "unigênito"), ("c", "graça")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 1:14 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: graça e verdade enchem o encarnado.",
        "feedbackWrong": {"a": "O texto não esvazia o Verbo de graça.", "c": "A verdade acompanha a graça, não some."},
        "passageA": {"ref": "João 1:14", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Verbo vazio de graça"),
            ("b", "Cheio de graça e verdade"),
            ("c", "Verdade sem a graça"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "João 1:14 apresenta a encarnação como o lugar em que a glória do unigênito se deixa ver, não como um véu que a apaga.",
        "feedbackCorrect": "Certo: na carne se vê a glória do unigênito.",
        "feedbackWrong": {"false": "O texto une carne, habitação e glória vista."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 1:14, toque a palavra que falta em \"glória como do unigênito do ___\"?",
        "feedbackCorrect": "Exato: a glória é do unigênito do Pai.",
        "feedbackWrong": {"a": "Nós somos as testemunhas, não esta origem.", "c": "Verbo é o encarnado, não o termo desta frase."},
        "template": "glória como do unigênito do ___",
        "options": opt(("a", "nós"), ("b", "Pai"), ("c", "Verbo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que leitura de João 1:14 distorce o sentido da glória do unigênito?",
        "feedbackCorrect": "Certo: a carne não cancela a glória do unigênito.",
        "feedbackWrong": {
            "a": "Essa é a afirmação do texto, não uma distorção.",
            "b": "Graça e verdade descrevem o encarnado, conforme o versículo.",
            "d": "A glória vista é a do unigênito do Pai, como o texto diz.",
        },
        "options": opt(
            ("a", "A carne é o lugar em que se vê a glória do unigênito"),
            ("b", "O Verbo habita entre nós cheio de graça e de verdade"),
            ("c", "Fazer-se carne apaga a glória, restando só um mestre humano"),
            ("d", "A glória vista é como a do unigênito do Pai"),
        ),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de João 1:14?",
        "feedbackCorrect": "Certo: encarnação, plenitude e glória do unigênito.",
        "feedbackWrong": {"b": "A plenitude qualifica o que habitou entre nós.", "c": "A glória do unigênito fecha o sentido."},
        "options": opt(
            ("a", "O Verbo se fez carne e habitou entre nós"),
            ("b", "cheio de graça e de verdade"),
            ("c", "glória como do unigênito do Pai"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"e vimos a sua ___, glória como do unigênito do Pai\"",
        "feedbackCorrect": "Certo: viram a sua glória.",
        "feedbackWrong": {"a": "Carne é o que o Verbo se fez, não o que se viu aqui.", "c": "Verdade completa o par com graça, não esta lacuna."},
        "template": "e vimos a sua ___, glória como do unigênito do Pai",
        "options": opt(("a", "carne"), ("b", "glória"), ("c", "verdade")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 1:14 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: os sinais apontam à glória do unigênito.",
        "feedbackWrong": {"b": "O texto não reduz o Verbo a um mito sem carne.", "c": "A glória do unigênito é vista, não negada."},
        "passageA": {"ref": "João 1:14", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Glória do unigênito"),
            ("b", "Mito sem encarnação"),
            ("c", "Glória negada na carne"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M2 João 14:6 ────────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "jo-02-eu-sou",
    "João 14:6",
    LO2,
    ["João 14:6"],
    P2,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Jesus responde: Eu sou o caminho, e a verdade, e a vida.",
        "feedbackCorrect": "Certo: Jesus se identifica assim em João 14:6.",
        "feedbackWrong": {"false": "Releia João 14:6: Eu sou o caminho, a verdade e a vida."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 14:6, toque a palavra que falta em \"Eu sou o ___, e a verdade, e a vida\"?",
        "feedbackCorrect": "Exato: Jesus é o caminho.",
        "feedbackWrong": {"b": "Verdade vem depois do caminho nesta frase.", "c": "Vida fecha a tríade, não esta lacuna."},
        "template": "Eu sou o ___, e a verdade, e a vida",
        "options": opt(("a", "caminho"), ("b", "verdade"), ("c", "vida")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Jesus afirma sobre ir ao Pai em João 14:6?",
        "feedbackCorrect": "Certo: ninguém vem ao Pai senão por mim.",
        "feedbackWrong": {
            "a": "O texto exclui outros caminhos, não os autoriza.",
            "c": "Jesus não diz que o Pai se alcança sem ele.",
            "d": "Ele se apresenta como caminho, não só como conselho.",
        },
        "options": opt(
            ("a", "Qualquer caminho leva igualmente ao Pai"),
            ("b", "Ninguém vem ao Pai senão por mim"),
            ("c", "O Pai se alcança sem passar por Jesus"),
            ("d", "Ele só descreve a vida, sem falar do Pai"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em João 14:6?",
        "feedbackCorrect": "Certo: Jesus responde, declara quem é e o acesso ao Pai.",
        "feedbackWrong": {"b": "A tríade segue a resposta de Jesus.", "c": "O acesso ao Pai fecha a declaração."},
        "options": opt(
            ("a", "Respondeu-lhe Jesus"),
            ("b", "Eu sou o caminho, e a verdade, e a vida"),
            ("c", "ninguém vem ao Pai senão por mim"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"ninguém vem ao ___ senão por mim\"",
        "feedbackCorrect": "Certo: o destino é o Pai.",
        "feedbackWrong": {"a": "Caminho é quem Jesus é, não o destino desta frase.", "c": "Jesus fala, mas a lacuna é o Pai."},
        "template": "ninguém vem ao ___ senão por mim",
        "options": opt(("a", "caminho"), ("b", "Pai"), ("c", "Jesus")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 14:6 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Jesus é caminho, verdade e vida.",
        "feedbackWrong": {"b": "Ele não se apresenta só como um dos muitos caminhos.", "c": "O texto une as três, não corta a vida."},
        "passageA": {"ref": "João 14:6", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Caminho, verdade e vida"),
            ("b", "Um caminho entre muitos"),
            ("c", "Verdade sem a vida"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em João 14:6, Jesus admite que se chega ao Pai por vários mediadores igualmente válidos.",
        "feedbackCorrect": "Certo: ninguém vem ao Pai senão por ele.",
        "feedbackWrong": {"true": "O texto diz: ninguém vem ao Pai senão por mim."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 14:6, toque a palavra que falta em \"Eu sou o caminho, e a ___, e a vida\"?",
        "feedbackCorrect": "Exato: Jesus é também a verdade.",
        "feedbackWrong": {"a": "Caminho já foi dito antes desta lacuna.", "c": "Vida vem depois da verdade."},
        "template": "Eu sou o caminho, e a ___, e a vida",
        "options": opt(("a", "caminho"), ("b", "verdade"), ("c", "vida")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como a tríade de João 14:6 se relaciona com o acesso ao Pai?",
        "feedbackCorrect": "Certo: ser caminho, verdade e vida explica o senão por mim.",
        "feedbackWrong": {
            "b": "O texto não trata as três como títulos soltos do Pai.",
            "c": "A vida não substitui o caminho; as três se unem.",
            "d": "A exclusão senão por mim depende de quem Jesus é.",
        },
        "options": opt(
            ("a", "Quem ele é (caminho, verdade e vida) é o único acesso ao Pai"),
            ("b", "As três palavras são títulos sem ligação com o Pai"),
            ("c", "Só a vida importa; o caminho é opcional"),
            ("d", "O senão por mim vale mesmo se ele não for o caminho"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de João 14:6?",
        "feedbackCorrect": "Certo: identidade, depois o acesso exclusivo ao Pai.",
        "feedbackWrong": {"b": "A verdade segue o caminho na tríade.", "c": "O Pai fecha a declaração."},
        "options": opt(
            ("a", "Eu sou o caminho"),
            ("b", "e a verdade, e a vida"),
            ("c", "ninguém vem ao Pai senão por mim"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"Eu sou o caminho, e a verdade, e a ___\"",
        "feedbackCorrect": "Certo: a tríade fecha com a vida.",
        "feedbackWrong": {"a": "Pai é o destino, não o terceiro termo.", "c": "Caminho já abriu a tríade."},
        "template": "Eu sou o caminho, e a verdade, e a ___",
        "options": opt(("a", "Pai"), ("b", "vida"), ("c", "caminho")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 14:6 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: ninguém chega ao Pai por outro.",
        "feedbackWrong": {"a": "O texto não abre atalhos paralelos.", "c": "O acesso não é um talvez; é senão por mim."},
        "passageA": {"ref": "João 14:6", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Atalhos iguais ao Pai"),
            ("b", "Ninguém chega por outro"),
            ("c", "Acesso talvez sem Jesus"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "João 14:6 apresenta Jesus não como um conselho sobre o Pai, mas como o único por quem se vem ao Pai.",
        "feedbackCorrect": "Certo: ninguém vem ao Pai senão por mim.",
        "feedbackWrong": {"false": "O texto une identidade e acesso exclusivo."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 14:6, toque a palavra que falta em \"ninguém vem ao Pai senão por ___\"?",
        "feedbackCorrect": "Exato: o acesso é por mim.",
        "feedbackWrong": {"a": "Pai é o destino, não o mediador desta frase.", "c": "Ninguém é o sujeito, não o meio."},
        "template": "ninguém vem ao Pai senão por ___",
        "options": opt(("a", "Pai"), ("b", "mim"), ("c", "ninguém")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que leitura de João 14:6 esvazia o Eu sou de Jesus?",
        "feedbackCorrect": "Certo: reduzir Jesus a um mapa genérico nega o senão por mim.",
        "feedbackWrong": {
            "a": "Essa leitura segue o texto, não o esvazia.",
            "b": "A tríade é a autoidentificação de Jesus.",
            "d": "O senão por mim é a cláusula do versículo.",
        },
        "options": opt(
            ("a", "Jesus é o caminho pelo qual se vem ao Pai"),
            ("b", "Ele se declara caminho, verdade e vida"),
            ("c", "Eu sou é só metáfora; qualquer sinceridade basta"),
            ("d", "Ninguém vem ao Pai senão por ele"),
        ),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de João 14:6?",
        "feedbackCorrect": "Certo: quem ele é, o que isso cobre, e o único acesso.",
        "feedbackWrong": {"b": "Verdade e vida completam o Eu sou.", "c": "O senão por mim revela o sentido."},
        "options": opt(
            ("a", "Eu sou o caminho"),
            ("b", "e a verdade, e a vida"),
            ("c", "ninguém vem ao Pai senão por mim"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"___ vem ao Pai senão por mim\"",
        "feedbackCorrect": "Certo: ninguém vem ao Pai senão por ele.",
        "feedbackWrong": {"a": "Jesus é quem fala, não o sujeito desta cláusula.", "c": "Vida fecha a tríade, não esta lacuna."},
        "template": "___ vem ao Pai senão por mim",
        "options": opt(("a", "Jesus"), ("b", "ninguém"), ("c", "vida")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 14:6 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Eu sou é o único caminho ao Pai.",
        "feedbackWrong": {"b": "O texto não iguala Jesus a um guia opcional.", "c": "Não há outro mediador no versículo."},
        "passageA": {"ref": "João 14:6", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Único caminho ao Pai"),
            ("b", "Guia opcional entre outros"),
            ("c", "Outro mediador paralelo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M3 João 15:5 ────────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "jo-03-adeus-espirito",
    "João 15:5",
    LO3,
    ["João 15:5"],
    P3,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Jesus diz: Eu sou a videira; vós sois as varas.",
        "feedbackCorrect": "Certo: João 15:5 identifica videira e varas.",
        "feedbackWrong": {"false": "Releia João 15:5: Eu sou a videira; vós sois as varas."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 15:5, toque a palavra que falta em \"Eu sou a ___; vós sois as varas\"?",
        "feedbackCorrect": "Exato: Jesus é a videira.",
        "feedbackWrong": {"b": "Varas são os discípulos, não Jesus nesta frase.", "c": "Fruto é o resultado, não a identidade."},
        "template": "Eu sou a ___; vós sois as varas",
        "options": opt(("a", "videira"), ("b", "varas"), ("c", "fruto")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que João 15:5 afirma sobre quem permanece em Jesus?",
        "feedbackCorrect": "Certo: aquele que permanece dá muito fruto.",
        "feedbackWrong": {
            "b": "O texto liga permanência e fruto, não os separa.",
            "c": "Sem mim nada podeis fazer contradiz a autonomia.",
            "d": "O fruto vem da união, não da despedida.",
        },
        "options": opt(
            ("a", "Dá muito fruto"),
            ("b", "Fica sem fruto por permanecer"),
            ("c", "Pode fazer tudo sem ele"),
            ("d", "O fruto nasce da despedida, não da união"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em João 15:5?",
        "feedbackCorrect": "Certo: identidade, permanência com fruto, depois a incapacidade sem ele.",
        "feedbackWrong": {"b": "A permanência vem depois da identificação.", "c": "Sem mim nada podeis fazer fecha o dito."},
        "options": opt(
            ("a", "Eu sou a videira; vós sois as varas"),
            ("b", "Aquele que permanece em mim e no qual eu permaneço dá muito fruto"),
            ("c", "pois sem mim nada podeis fazer"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"vós sois as ___\"",
        "feedbackCorrect": "Certo: os discípulos são as varas.",
        "feedbackWrong": {"a": "Videira é Jesus, não os discípulos aqui.", "c": "Fruto é o resultado, não quem eles são."},
        "template": "vós sois as ___",
        "options": opt(("a", "videira"), ("b", "varas"), ("c", "fruto")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 15:5 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: sem a videira nada se faz.",
        "feedbackWrong": {"b": "O texto não ensina autonomia das varas.", "c": "O fruto não nasce da despedida."},
        "passageA": {"ref": "João 15:5", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Sem a videira nada"),
            ("b", "Varas autônomas"),
            ("c", "Fruto da despedida"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Segundo João 15:5, as varas produzem fruto mesmo quando cortadas da videira.",
        "feedbackCorrect": "Certo: sem mim nada podeis fazer.",
        "feedbackWrong": {"true": "O texto liga fruto à permanência mútua."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 15:5, toque a palavra que falta em \"Aquele que ___ em mim e no qual eu permaneço dá muito fruto\"?",
        "feedbackCorrect": "Exato: o que permanece dá fruto.",
        "feedbackWrong": {"b": "Podeis pertence à cláusula final, não a esta.", "c": "Varas nomeia os discípulos, não o verbo."},
        "template": "Aquele que ___ em mim e no qual eu permaneço dá muito fruto",
        "options": opt(("a", "permanece"), ("b", "podeis"), ("c", "varas")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como João 15:5 une a permanência de Jesus e a dos discípulos?",
        "feedbackCorrect": "Certo: permanece em mim e no qual eu permaneço.",
        "feedbackWrong": {
            "b": "O texto fala de permanência mútua, não só de um lado.",
            "c": "O fruto depende dessa união, não a ignora.",
            "d": "Sem mim nada podeis fazer impede a autonomia.",
        },
        "options": opt(
            ("a", "Há permanência mútua: nele e ele no discípulo"),
            ("b", "Só o discípulo permanece; Jesus se ausenta"),
            ("c", "O fruto independe de Jesus permanecer no discípulo"),
            ("d", "As varas fazem tudo sem a videira"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de João 15:5?",
        "feedbackCorrect": "Certo: união, fruto, incapacidade sem ele.",
        "feedbackWrong": {"b": "O fruto segue a permanência.", "c": "A incapacidade fecha o encadeamento."},
        "options": opt(
            ("a", "permanece em mim e no qual eu permaneço"),
            ("b", "dá muito fruto"),
            ("c", "sem mim nada podeis fazer"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"dá muito ___\"",
        "feedbackCorrect": "Certo: a permanência dá muito fruto.",
        "feedbackWrong": {"a": "Varas são quem permanece, não o resultado.", "c": "Videira é Jesus, não o produto."},
        "template": "dá muito ___",
        "options": opt(("a", "varas"), ("b", "fruto"), ("c", "videira")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 15:5 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o fruto nasce da união.",
        "feedbackWrong": {"a": "O texto não elogia a despedida vazia.", "c": "Sem a videira não há fruto."},
        "passageA": {"ref": "João 15:5", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Fruto da despedida vazia"),
            ("b", "Fruto da união"),
            ("c", "Fruto sem a videira"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "João 15:5 ensina que o fruto cristão nasce da união com Jesus, não de uma despedida que deixa as varas por conta própria.",
        "feedbackCorrect": "Certo: sem mim nada podeis fazer.",
        "feedbackWrong": {"false": "O texto liga fruto à permanência, não à ausência."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 15:5, toque a palavra que falta em \"pois sem mim ___ podeis fazer\"?",
        "feedbackCorrect": "Exato: sem ele nada podem fazer.",
        "feedbackWrong": {"b": "Muito qualifica o fruto, não esta lacuna.", "c": "Fruto é o que a união produz, não o nada."},
        "template": "pois sem mim ___ podeis fazer",
        "options": opt(("a", "nada"), ("b", "muito"), ("c", "fruto")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que leitura de João 15:5 trata a despedida como se as varas bastassem sozinhas?",
        "feedbackCorrect": "Certo: autonomia das varas contradiz sem mim nada podeis fazer.",
        "feedbackWrong": {
            "a": "Essa é a lógica do versículo, não o erro.",
            "b": "A permanência mútua é o que o texto afirma.",
            "d": "O muito fruto depende da união, conforme o dito.",
        },
        "options": opt(
            ("a", "Sem Jesus nada se pode fazer"),
            ("b", "Permanecer nele e ele no discípulo dá fruto"),
            ("c", "Depois da despedida, as varas produzem sozinhas"),
            ("d", "O fruto nasce de permanecer na videira"),
        ),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de João 15:5?",
        "feedbackCorrect": "Certo: identidade, união fecunda, limite sem ele.",
        "feedbackWrong": {"b": "A união fecunda segue a identidade.", "c": "O limite sem ele revela o sentido."},
        "options": opt(
            ("a", "Eu sou a videira; vós sois as varas"),
            ("b", "permanece em mim e no qual eu permaneço dá muito fruto"),
            ("c", "sem mim nada podeis fazer"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"no qual eu ___ dá muito fruto\"",
        "feedbackCorrect": "Certo: ele permanece no discípulo.",
        "feedbackWrong": {"a": "Podeis pertence à cláusula final.", "c": "Varas nomeia os discípulos, não o verbo."},
        "template": "no qual eu ___ dá muito fruto",
        "options": opt(("a", "podeis"), ("b", "permaneço"), ("c", "varas")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 15:5 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: permaneçam — o fruto não é despedida vazia.",
        "feedbackWrong": {"b": "O texto não celebra a ausência de Jesus.", "c": "As varas não se bastam sozinhas."},
        "passageA": {"ref": "João 15:5", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Permaneçam na videira"),
            ("b", "Despedida que basta"),
            ("c", "Varas que se bastam"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M4 João 19:30 ───────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "jo-04-cruz-tome",
    "João 19:30",
    LO4,
    ["João 19:30"],
    P4,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Jesus, depois de ter tomado o vinagre, disse: Está consumado.",
        "feedbackCorrect": "Certo: João 19:30 registra essa declaração.",
        "feedbackWrong": {"false": "Releia João 19:30: depois do vinagre, Está consumado."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 19:30, toque a palavra que falta em \"depois de ter tomado o ___, disse: Está consumado\"?",
        "feedbackCorrect": "Exato: ele toma o vinagre antes de falar.",
        "feedbackWrong": {"b": "Cabeça é o que ele inclina depois.", "c": "Espírito é o que ele rende no fim."},
        "template": "depois de ter tomado o ___, disse: Está consumado",
        "options": opt(("a", "vinagre"), ("b", "cabeça"), ("c", "espírito")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Jesus faz depois de dizer Está consumado, segundo João 19:30?",
        "feedbackCorrect": "Certo: inclina a cabeça e rende o espírito.",
        "feedbackWrong": {
            "b": "O texto não diz que ele recusa o vinagre neste versículo.",
            "c": "Ele rende o espírito, não o retém depois da frase.",
            "d": "A declaração vem após tomar o vinagre, não no lugar disso.",
        },
        "options": opt(
            ("a", "Inclina a cabeça e rende o espírito"),
            ("b", "Recusa o vinagre e desce da cruz"),
            ("c", "Retém o espírito e permanece em silêncio"),
            ("d", "Toma o vinagre só depois de render o espírito"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em João 19:30?",
        "feedbackCorrect": "Certo: vinagre, declaração, entrega do espírito.",
        "feedbackWrong": {"b": "Está consumado vem depois do vinagre.", "c": "Render o espírito fecha a cena."},
        "options": opt(
            ("a", "depois de ter tomado o vinagre"),
            ("b", "disse: Está consumado"),
            ("c", "inclinando a cabeça, rendeu o espírito"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"disse: Está ___\"",
        "feedbackCorrect": "Certo: a palavra é consumado.",
        "feedbackWrong": {"a": "Vinagre é o que ele tomou, não o que disse.", "c": "Espírito é o que ele rendeu."},
        "template": "disse: Está ___",
        "options": opt(("a", "vinagre"), ("b", "consumado"), ("c", "espírito")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 19:30 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a obra se declara consumada.",
        "feedbackWrong": {"b": "O texto não trata a cruz como acidente.", "c": "A frase conclui, não interrompe sem sentido."},
        "passageA": {"ref": "João 19:30", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Obra consumada"),
            ("b", "Cruz por acidente"),
            ("c", "Frase sem conclusão"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Em João 19:30, Jesus rende o espírito antes de dizer Está consumado.",
        "feedbackCorrect": "Certo: primeiro a declaração, depois a entrega.",
        "feedbackWrong": {"true": "A ordem é: Está consumado, então rendeu o espírito."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 19:30, toque a palavra que falta em \"inclinando a ___, rendeu o espírito\"?",
        "feedbackCorrect": "Exato: ele inclina a cabeça.",
        "feedbackWrong": {"b": "Espírito é o que ele rende, não o que inclina.", "c": "Vinagre já foi tomado antes."},
        "template": "inclinando a ___, rendeu o espírito",
        "options": opt(("a", "cabeça"), ("b", "espírito"), ("c", "vinagre")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como João 19:30 ordena a palavra de Jesus e a entrega da vida?",
        "feedbackCorrect": "Certo: a declaração precede o render o espírito.",
        "feedbackWrong": {
            "b": "O texto não inverte declaração e morte.",
            "c": "O vinagre antecede a frase, não a substitui.",
            "d": "Inclinar a cabeça acompanha a entrega, depois da frase.",
        },
        "options": opt(
            ("a", "Primeiro Está consumado; depois inclina a cabeça e rende o espírito"),
            ("b", "Primeiro rende o espírito; só então fala"),
            ("c", "O vinagre substitui a declaração da obra"),
            ("d", "A cabeça se inclina sem qualquer palavra"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de João 19:30?",
        "feedbackCorrect": "Certo: vinagre, palavra, entrega.",
        "feedbackWrong": {"b": "A palavra segue o vinagre.", "c": "A entrega fecha a cena."},
        "options": opt(
            ("a", "tomado o vinagre"),
            ("b", "Está consumado"),
            ("c", "rendeu o espírito"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"rendeu o ___\"",
        "feedbackCorrect": "Certo: ele rendeu o espírito.",
        "feedbackWrong": {"a": "Vinagre é o que tomou, não o que rendeu.", "c": "Cabeça é o que inclinou."},
        "template": "rendeu o ___",
        "options": opt(("a", "vinagre"), ("b", "espírito"), ("c", "cabeça")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 19:30 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o Crucificado conclui a obra.",
        "feedbackWrong": {"a": "O texto não apresenta interrupção vazia.", "c": "Não é morte sem palavra de cumprimento."},
        "passageA": {"ref": "João 19:30", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Obra interrompida"),
            ("b", "Crucificado conclui a obra"),
            ("c", "Morte sem cumprimento"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Está consumado em João 19:30 apresenta a cruz como cumprimento da obra, não como um acidente que corta o plano no meio.",
        "feedbackCorrect": "Certo: a declaração conclui, não improvisa.",
        "feedbackWrong": {"false": "O texto une a palavra de conclusão e a entrega."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 19:30, toque a palavra que falta em \"disse: Está ___\"?",
        "feedbackCorrect": "Exato: a obra se declara consumada.",
        "feedbackWrong": {"a": "Jesus é quem fala, não o predicado.", "c": "Vinagre antecede a frase, não a preenche."},
        "template": "disse: Está ___",
        "options": opt(("a", "Jesus"), ("b", "consumado"), ("c", "vinagre")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que leitura de João 19:30 reduz a cruz a um acaso sem cumprimento?",
        "feedbackCorrect": "Certo: acaso contradiz Está consumado.",
        "feedbackWrong": {
            "a": "Essa leitura segue a declaração do versículo.",
            "b": "A ordem do texto une palavra e entrega.",
            "d": "Render o espírito fecha a cena de cumprimento.",
        },
        "options": opt(
            ("a", "A cruz conclui a obra anunciada"),
            ("b", "Jesus fala e então rende o espírito"),
            ("c", "A morte é acidente; nada se consuma de propósito"),
            ("d", "Inclinar a cabeça acompanha a entrega do espírito"),
        ),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de João 19:30?",
        "feedbackCorrect": "Certo: o ato, a conclusão e a entrega.",
        "feedbackWrong": {"b": "A conclusão segue o vinagre.", "c": "A entrega sela o cumprimento."},
        "options": opt(
            ("a", "depois de ter tomado o vinagre"),
            ("b", "Está consumado"),
            ("c", "rendeu o espírito"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"___, depois de ter tomado o vinagre, disse\"",
        "feedbackCorrect": "Certo: o sujeito é Jesus.",
        "feedbackWrong": {"a": "Espírito é o que ele rende no fim.", "c": "Cabeça é o que ele inclina."},
        "template": "___, depois de ter tomado o vinagre, disse",
        "options": opt(("a", "espírito"), ("b", "Jesus"), ("c", "cabeça")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 19:30 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a cruz é cumprimento, não acidente.",
        "feedbackWrong": {"b": "O texto não trata a morte como acaso.", "c": "Não há obra pela metade na declaração."},
        "passageA": {"ref": "João 19:30", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Cruz como cumprimento"),
            ("b", "Morte como acaso"),
            ("c", "Obra pela metade"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M5 João 20:31 ───────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "jo-boss-revisao",
    "João 20:31",
    LO5,
    ["João 20:31"],
    P5,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Estes estão escritos para que creiais que Jesus é o Cristo, o Filho de Deus.",
        "feedbackCorrect": "Certo: João 20:31 declara o propósito do livro.",
        "feedbackWrong": {"false": "Releia João 20:31: escritos para que creiais."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 20:31, toque a palavra que falta em \"estão escritos para que ___ que Jesus é o Cristo\"?",
        "feedbackCorrect": "Exato: o propósito é que creiais.",
        "feedbackWrong": {"b": "Crendo vem na segunda finalidade.", "c": "Vida é o fruto de crer, não este verbo."},
        "template": "estão escritos para que ___ que Jesus é o Cristo",
        "options": opt(("a", "creiais"), ("b", "crendo"), ("c", "vida")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que João 20:31 afirma que o leitor deve crer acerca de Jesus?",
        "feedbackCorrect": "Certo: que Jesus é o Cristo, o Filho de Deus.",
        "feedbackWrong": {
            "b": "O texto não reduz Jesus a um profeta qualquer.",
            "c": "Ele é o Filho de Deus, não só um mestre.",
            "d": "O Cristo e o Filho de Deus são a confissão pedida.",
        },
        "options": opt(
            ("a", "Que Jesus é o Cristo, o Filho de Deus"),
            ("b", "Que Jesus é apenas mais um profeta"),
            ("c", "Que Jesus é só um mestre entre outros"),
            ("d", "Que o título Cristo não se aplica a Jesus"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em João 20:31?",
        "feedbackCorrect": "Certo: escritos, fé na identidade, vida no nome.",
        "feedbackWrong": {"b": "A fé na identidade segue o propósito de escrever.", "c": "A vida no nome fecha o propósito."},
        "options": opt(
            ("a", "estes, porém, estão escritos para que creiais"),
            ("b", "que Jesus é o Cristo, o Filho de Deus"),
            ("c", "e para que, crendo, tenhais vida em seu nome"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"que Jesus é o ___, o Filho de Deus\"",
        "feedbackCorrect": "Certo: Jesus é o Cristo.",
        "feedbackWrong": {"a": "Nome fecha a frase da vida, não este título.", "c": "Vida é o fruto de crer."},
        "template": "que Jesus é o ___, o Filho de Deus",
        "options": opt(("a", "nome"), ("b", "Cristo"), ("c", "vida")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 20:31 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o livro aponta para o Cristo, Filho de Deus.",
        "feedbackWrong": {"b": "O texto não trata os escritos como curiosidade.", "c": "A identidade de Jesus é o alvo da fé."},
        "passageA": {"ref": "João 20:31", "text": P5},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Livro aponta ao Cristo"),
            ("b", "Escritos só por curiosidade"),
            ("c", "Fé sem identidade de Jesus"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "João 20:31 separa o crer da vida: crer basta como informação, sem ter vida em seu nome.",
        "feedbackCorrect": "Certo: crendo, tenhais vida em seu nome.",
        "feedbackWrong": {"true": "O texto une crer e ter vida no nome de Jesus."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 20:31, toque a palavra que falta em \"o Filho de ___\"?",
        "feedbackCorrect": "Exato: Filho de Deus.",
        "feedbackWrong": {"a": "Cristo é o outro título, não esta lacuna.", "c": "Jesus é o sujeito da confissão."},
        "template": "o Filho de ___",
        "options": opt(("a", "Cristo"), ("b", "Deus"), ("c", "Jesus")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como João 20:31 liga o ato de escrever, a fé e a vida?",
        "feedbackCorrect": "Certo: escritos para crer, e crendo ter vida.",
        "feedbackWrong": {
            "b": "A fé não é um anexo opcional aos escritos.",
            "c": "A vida vem de crer, não substitui a fé.",
            "d": "O nome de Jesus é o lugar da vida, não um detalhe.",
        },
        "options": opt(
            ("a", "Estão escritos para que creiais e, crendo, tenhais vida"),
            ("b", "Os escritos dispensam a fé no Cristo"),
            ("c", "A vida no nome substitui o crer"),
            ("d", "O nome de Jesus não entra no propósito do livro"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de João 20:31?",
        "feedbackCorrect": "Certo: escritos, crer, vida.",
        "feedbackWrong": {"b": "O crer segue o propósito de escrever.", "c": "A vida fecha o encadeamento."},
        "options": opt(
            ("a", "estão escritos"),
            ("b", "para que creiais que Jesus é o Cristo"),
            ("c", "crendo, tenhais vida em seu nome"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"tenhais ___ em seu nome\"",
        "feedbackCorrect": "Certo: o fruto de crer é vida.",
        "feedbackWrong": {"a": "Cristo é o título da fé, não esta lacuna.", "c": "Nome já fecha a frase."},
        "template": "tenhais ___ em seu nome",
        "options": opt(("a", "Cristo"), ("b", "vida"), ("c", "nome")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 20:31 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: creia e tenha vida.",
        "feedbackWrong": {"a": "O texto não oferece fé sem vida.", "c": "A vida não vem sem crer."},
        "passageA": {"ref": "João 20:31", "text": P5},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Fé sem vida"),
            ("b", "Creia e tenha vida"),
            ("c", "Vida sem crer"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "João 20:31 apresenta o evangelho inteiro como escrito para a fé que confessa Jesus como Cristo e Filho de Deus, e assim recebe vida.",
        "feedbackCorrect": "Certo: o livro aponta à fé que dá vida.",
        "feedbackWrong": {"false": "O texto une escritos, Cristo, Filho e vida."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em João 20:31, toque a palavra que falta em \"tenhais vida em seu ___\"?",
        "feedbackCorrect": "Exato: a vida é em seu nome.",
        "feedbackWrong": {"a": "Cristo é o título confessado, não esta lacuna.", "c": "Deus completa Filho de Deus."},
        "template": "tenhais vida em seu ___",
        "options": opt(("a", "Cristo"), ("b", "nome"), ("c", "Deus")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que leitura de João 20:31 trata o livro como arquivo sem convite à fé?",
        "feedbackCorrect": "Certo: o propósito é crer, não só arquivar.",
        "feedbackWrong": {
            "a": "Essa é a finalidade declarada do versículo.",
            "b": "A confissão Cristo e Filho de Deus é o conteúdo da fé.",
            "d": "A vida no nome segue o crer, conforme o texto.",
        },
        "options": opt(
            ("a", "Os sinais estão escritos para que creiais"),
            ("b", "A fé confessa Jesus como Cristo e Filho de Deus"),
            ("c", "O livro só registra fatos, sem chamar a crer"),
            ("d", "Crendo, há vida em seu nome"),
        ),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de João 20:31?",
        "feedbackCorrect": "Certo: escrito, confissão e vida no nome.",
        "feedbackWrong": {"b": "A confissão segue o propósito de escrever.", "c": "A vida no nome revela o fim."},
        "options": opt(
            ("a", "estão escritos para que creiais"),
            ("b", "Jesus é o Cristo, o Filho de Deus"),
            ("c", "tenhais vida em seu nome"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"para que, ___, tenhais vida em seu nome\"",
        "feedbackCorrect": "Certo: crendo, há vida no nome.",
        "feedbackWrong": {"a": "Escritos é o meio, não este gerúndio.", "c": "Cristo é o título da fé."},
        "template": "para que, ___, tenhais vida em seu nome",
        "options": opt(("a", "escritos"), ("b", "crendo"), ("c", "Cristo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que João 20:31 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o livro inteiro aponta ao Cristo, Filho de Deus.",
        "feedbackWrong": {"b": "Não é um arquivo sem convite à fé.", "c": "A vida no nome não se corta da confissão."},
        "passageA": {"ref": "João 20:31", "text": P5},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Livro inteiro aponta ao Cristo"),
            ("b", "Arquivo sem convite à fé"),
            ("c", "Vida cortada da confissão"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]


def main():
    assert len(Qs) == 90, len(Qs)
    out = "/Users/dalwesleyduarte/dev/new/perguntas-v2/joao.json"
    with open(out, "w", encoding="utf-8") as f:
        json.dump(Qs, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(out, len(Qs))


if __name__ == "__main__":
    main()
