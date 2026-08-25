#!/usr/bin/env python3
# -*- coding: utf-8 -*-
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
        "trail": "salmos",
        "section": section,
        "id": f"salmos-{SHORT[diff]}-{section}-{nn}",
        "passageText": passage,
    }


def merge(b, extra):
    d = dict(b)
    d.update(extra)
    return q(**d)


P1 = (
    "Feliz é o homem que não anda segundo o conselho dos iníquos, "
    "nem no caminho dos pecadores se detém, nem na roda dos escarnecedores se assenta. "
    "Mas o seu prazer está na lei de Jeová, e na sua lei medita de dia e de noite."
)
P2 = (
    "Jeová é o meu pastor; nada me faltará. "
    "Faz-me repousar em pastos verdejantes; conduz-me às águas de descanso."
)
P3 = (
    "Até quando, Jeová! Esquecer-te-ás de mim para sempre? "
    "Até quando me ocultarás o teu rosto? "
    "Até quando encherei a minha alma de cuidados, tendo diariamente tristeza no meu coração? "
    "Até quando sobre mim se exaltará o meu inimigo?"
)
P4 = "Cria em mim, ó Deus, um coração limpo e renova, dentro de mim, um espírito estável."
P5 = (
    "Até quando, Jeová! Esquecer-te-ás de mim para sempre? "
    "Até quando me ocultarás o teu rosto? "
    "Cria em mim, ó Deus, um coração limpo e renova, dentro de mim, um espírito estável. "
    "Jeová é o meu pastor; nada me faltará."
)

I1 = "O feliz não se assenta com escarnecedores: o prazer está na lei de Jeová, dia e noite."
I2 = "Jeová pastoreia: nada falta a quem ele faz repousar e conduz a águas de descanso."
I3 = "O lamento é fé que grita: até quando, Jeová — o salmo não esconde a demora de Deus."
I4 = "O pedido é criação, não conserto superficial: coração limpo e espírito estável."
I5 = "Orar os Salmos é lamento, pedido de coração novo e confiança no Pastor."

LO1 = "Sair sabendo que o feliz recusa o conselho iníquo e tem prazer na lei de Jeová, dia e noite."
LO2 = "Sair sabendo que Jeová pastoreia: nada falta a quem ele faz repousar e conduz a águas de descanso."
LO3 = "Sair sabendo que o lamento pergunta até quando a Jeová e não esconde a demora de Deus."
LO4 = "Sair sabendo que o pedido é criação: coração limpo e espírito estável, não conserto superficial."
LO5 = "Sair sabendo que orar os Salmos une lamento, pedido de coração novo e confiança no Pastor."

Qs = []

# ── M1 Salmos 1:1–2 ─────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "salmos-louvor-01-bem-aventurado-o-hom",
    "Salmos 1:1-2",
    LO1,
    ["Salmos 1:1", "Salmos 1:2"],
    P1,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Feliz é o homem que não anda segundo o conselho dos iníquos.",
        "feedbackCorrect": "Certo: o salmo abre exatamente com essa afirmação.",
        "feedbackWrong": {"false": "Releia Salmos 1:1: feliz é quem não anda nesse conselho."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 1:1-2, toque a palavra que falta em \"nem na roda dos ___ se assenta\"?",
        "feedbackCorrect": "Exato: o feliz não se assenta na roda dos escarnecedores.",
        "feedbackWrong": {
            "a": "Iníquos aparece no conselho, não nesta lacuna da roda.",
            "b": "Pecadores aparece no caminho, não nesta lacuna.",
        },
        "template": "nem na roda dos ___ se assenta",
        "options": opt(("a", "iníquos"), ("b", "pecadores"), ("c", "escarnecedores")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Salmos 1:1-2 afirma diretamente sobre o homem feliz?",
        "feedbackCorrect": "Certo: ele não anda, não se detém e não se assenta com os ímpios.",
        "feedbackWrong": {
            "b": "O texto diz que ele não se detém no caminho dos pecadores.",
            "c": "O texto recusa a roda dos escarnecedores, não a recomenda.",
            "d": "O prazer está na lei de Jeová, de dia e de noite.",
        },
        "options": opt(
            ("a", "Não anda no conselho dos iníquos nem se assenta com escarnecedores."),
            ("b", "Detém-se no caminho dos pecadores para aprender com eles."),
            ("c", "Assenta-se na roda dos escarnecedores com prazer."),
            ("d", "Deixa a lei de Jeová de lado durante a noite."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Salmos 1:1-2?",
        "feedbackCorrect": "Certo: conselho, caminho e roda nesta ordem.",
        "feedbackWrong": {
            "b": "O caminho dos pecadores vem depois do conselho, não antes.",
            "c": "A roda dos escarnecedores fecha a recusa, não a abre.",
        },
        "options": opt(
            ("a", "não anda segundo o conselho dos iníquos"),
            ("b", "nem no caminho dos pecadores se detém"),
            ("c", "nem na roda dos escarnecedores se assenta"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"Mas o seu prazer está na lei de ___, e na sua lei medita de dia e de noite.\"",
        "feedbackCorrect": "Certo: o prazer está na lei de Jeová.",
        "feedbackWrong": {
            "b": "Prazer é o que ele tem, não o nome de quem dá a lei.",
            "c": "Noite é quando ele medita, não o dono da lei.",
        },
        "template": "Mas o seu prazer está na lei de ___, e na sua lei medita de dia e de noite.",
        "options": opt(("a", "Jeová"), ("b", "prazer"), ("c", "noite")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 1:1-2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o feliz não se assenta com escarnecedores.",
        "feedbackWrong": {
            "b": "O texto recusa a roda dos escarnecedores, não a recomenda.",
            "c": "O prazer está na lei, não no conselho dos iníquos.",
        },
        "passageA": {"ref": "Salmos 1:1-2", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Prazer na lei de Jeová"),
            ("b", "Assentar-se com escarnecedores"),
            ("c", "Andar no conselho iníquo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O prazer do homem feliz está na roda dos escarnecedores, não na lei de Jeová.",
        "feedbackCorrect": "Certo: o prazer está na lei, e ele não se assenta naquela roda.",
        "feedbackWrong": {"true": "O texto opõe o prazer na lei à roda dos escarnecedores."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 1:1-2, toque a palavra que falta em \"Mas o seu ___ está na lei de Jeová\"?",
        "feedbackCorrect": "Exato: o que está na lei é o prazer dele.",
        "feedbackWrong": {
            "a": "Lei é o lugar do prazer, não o que falta nesta lacuna.",
            "c": "Noite é o tempo da meditação, não esta palavra.",
        },
        "template": "Mas o seu ___ está na lei de Jeová",
        "options": opt(("a", "lei"), ("b", "prazer"), ("c", "noite")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Salmos 1:1-2 relaciona recusa dos ímpios e meditação na lei?",
        "feedbackCorrect": "Certo: recusar o conselho iníquo abre espaço ao prazer na lei.",
        "feedbackWrong": {
            "b": "O texto não manda juntar-se aos pecadores para depois meditar.",
            "c": "A felicidade não é status social; está ligada à lei de Jeová.",
            "d": "Ele medita de dia e de noite, não só de dia.",
        },
        "options": opt(
            ("a", "Recusar o conselho iníquo acompanha o prazer constante na lei."),
            ("b", "Juntar-se aos pecadores é o caminho para depois meditar."),
            ("c", "A felicidade vem do prestígio na roda, não da lei."),
            ("d", "Meditar na lei basta de dia; a noite fica livre."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Salmos 1:1-2?",
        "feedbackCorrect": "Certo: recusa, depois prazer, depois meditação contínua.",
        "feedbackWrong": {
            "b": "O prazer na lei vem depois da recusa, não antes.",
            "c": "Meditar de dia e de noite fecha o trecho.",
        },
        "options": opt(
            ("a", "Feliz é o homem que não anda segundo o conselho dos iníquos"),
            ("b", "Mas o seu prazer está na lei de Jeová"),
            ("c", "e na sua lei medita de dia e de noite"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"e na sua lei medita de dia e de ___\"",
        "feedbackCorrect": "Certo: a meditação cobre dia e noite.",
        "feedbackWrong": {
            "a": "Dia já está na frase; a lacuna pede o outro tempo.",
            "b": "Prazer descreve o gosto pela lei, não este tempo.",
        },
        "template": "e na sua lei medita de dia e de ___",
        "options": opt(("a", "dia"), ("b", "prazer"), ("c", "noite")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 1:1-2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: prazer na lei, dia e noite, não na roda.",
        "feedbackWrong": {
            "a": "O conselho dos iníquos é recusado, não celebrado.",
            "c": "A roda dos escarnecedores não é o descanso do feliz.",
        },
        "passageA": {"ref": "Salmos 1:2", "text": "Mas o seu prazer está na lei de Jeová, e na sua lei medita de dia e de noite."},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Conselho iníquo como prazer"),
            ("b", "Lei de dia e de noite"),
            ("c", "Roda como lugar de descanso"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A felicidade de Salmos 1 se mede pela recusa do conselho iníquo e pelo prazer constante na lei de Jeová.",
        "feedbackCorrect": "Certo: o salmo liga felicidade a recusa e a meditação na lei.",
        "feedbackWrong": {"false": "O texto une recusa dos ímpios e prazer na lei de Jeová."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 1:1-2, toque a palavra que falta em \"Feliz é o ___ que não anda segundo o conselho dos iníquos\"?",
        "feedbackCorrect": "Exato: o sujeito da felicidade é o homem descrito.",
        "feedbackWrong": {
            "b": "Conselho é o que ele recusa, não quem é chamado feliz.",
            "c": "Lei é o objeto do prazer, não o sujeito da frase.",
        },
        "template": "Feliz é o ___ que não anda segundo o conselho dos iníquos",
        "options": opt(("a", "homem"), ("b", "conselho"), ("c", "lei")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que leitura de Salmos 1:1-2 o texto sustenta teologicamente?",
        "feedbackCorrect": "Certo: felicidade não é a roda; é meditar na lei.",
        "feedbackWrong": {
            "b": "A roda dos escarnecedores é recusada, não o critério da felicidade.",
            "c": "A lei não é opcional para o homem chamado feliz.",
            "d": "Andar com iníquos é o que o salmo recusa, não o que fortalece.",
        },
        "options": opt(
            ("a", "Felicidade não é sentar-se com escarnecedores; é meditar na lei."),
            ("b", "Felicidade se mede pela popularidade na roda."),
            ("c", "A lei é opcional se o homem já se sente feliz."),
            ("d", "Andar com iníquos aprofunda a meditação na lei."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Salmos 1:1-2?",
        "feedbackCorrect": "Certo: o feliz, a recusa e o prazer na lei nesta ordem.",
        "feedbackWrong": {
            "b": "A identidade do feliz abre o salmo, não o prazer.",
            "c": "O prazer na lei vem depois da recusa do conselho.",
        },
        "options": opt(
            ("a", "Feliz é o homem"),
            ("b", "que não anda segundo o conselho dos iníquos"),
            ("c", "Mas o seu prazer está na lei de Jeová"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"nem no caminho dos pecadores se ___\"",
        "feedbackCorrect": "Certo: ele não se detém nesse caminho.",
        "feedbackWrong": {
            "b": "Anda descreve o conselho dos iníquos, não esta lacuna.",
            "c": "Assenta descreve a roda, não o caminho.",
        },
        "template": "nem no caminho dos pecadores se ___",
        "options": opt(("a", "detém"), ("b", "anda"), ("c", "assenta")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 1:1-2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o feliz medita na lei de dia e de noite.",
        "feedbackWrong": {
            "a": "A felicidade do salmo inclui recusar o conselho iníquo.",
            "c": "A meditação não é só quando convém; é dia e noite.",
        },
        "passageA": {"ref": "Salmos 1:1-2", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Felicidade sem recusar o conselho"),
            ("b", "Prazer na lei dia e noite"),
            ("c", "Meditação só quando convém"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ── M2 Salmos 23:1–2 ────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "salmos-louvor-02-o-senhor-e-o-meu-pas",
    "Salmos 23:1-2",
    LO2,
    ["Salmos 23:1", "Salmos 23:2"],
    P2,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Jeová é o meu pastor; nada me faltará.",
        "feedbackCorrect": "Certo: o salmo afirma o pastor e a ausência de falta.",
        "feedbackWrong": {"false": "Releia Salmos 23:1: Jeová é o pastor e nada faltará."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 23:1-2, toque a palavra que falta em \"___ é o meu pastor; nada me faltará\"?",
        "feedbackCorrect": "Exato: o pastor nomeado é Jeová.",
        "feedbackWrong": {
            "b": "Pastor é o ofício, não o nome que abre o versículo.",
            "c": "Nada pertence à falta, não a esta lacuna inicial.",
        },
        "template": "___ é o meu pastor; nada me faltará",
        "options": opt(("a", "Jeová"), ("b", "pastor"), ("c", "nada")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Salmos 23:1-2 afirma diretamente?",
        "feedbackCorrect": "Certo: Jeová pastoreia, faz repousar e conduz a águas.",
        "feedbackWrong": {
            "a": "O texto diz que nada faltará, não que tudo faltará.",
            "c": "Ele conduz às águas de descanso, não as recusa.",
            "d": "Os pastos são verdejantes; o texto não fala de deserto seco.",
        },
        "options": opt(
            ("a", "O pastor deixa faltar o necessário ao que pastoreia."),
            ("b", "Jeová faz repousar em pastos verdejantes e conduz a águas de descanso."),
            ("c", "O salmista recusa ser conduzido às águas de descanso."),
            ("d", "Os pastos descritos são secos e sem verdor."),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Salmos 23:1-2?",
        "feedbackCorrect": "Certo: pastor, ausência de falta e repouso nos pastos.",
        "feedbackWrong": {
            "b": "A declaração do pastor abre o salmo, não o repouso.",
            "c": "Nada me faltará vem logo após o pastor.",
        },
        "options": opt(
            ("a", "Jeová é o meu pastor"),
            ("b", "nada me faltará"),
            ("c", "Faz-me repousar em pastos verdejantes"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"conduz-me às águas de ___\"",
        "feedbackCorrect": "Certo: as águas a que ele conduz são de descanso.",
        "feedbackWrong": {
            "b": "Pastos descreve o lugar do repouso, não estas águas.",
            "c": "Pastor nomeia a Jeová, não o tipo de águas.",
        },
        "template": "conduz-me às águas de ___",
        "options": opt(("a", "descanso"), ("b", "pastos"), ("c", "pastor")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 23:1-2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o pastor faz repousar e nada falta.",
        "feedbackWrong": {
            "b": "O texto afirma que nada faltará, não o contrário.",
            "c": "Os pastos vêm da ação de Jeová, não sem ele.",
        },
        "passageA": {"ref": "Salmos 23:1-2", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Pastor que faz repousar"),
            ("b", "Falta sem o pastor"),
            ("c", "Pastos sem Jeová"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O salmo diz que o pastor deixa faltar o necessário a quem ele conduz.",
        "feedbackCorrect": "Certo: o texto diz que nada faltará.",
        "feedbackWrong": {"true": "Salmos 23:1 afirma o contrário: nada me faltará."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 23:1-2, toque a palavra que falta em \"Faz-me ___ em pastos verdejantes\"?",
        "feedbackCorrect": "Exato: a ação nos pastos é fazer repousar.",
        "feedbackWrong": {
            "a": "Conduz-me refere-se às águas, não a esta lacuna.",
            "c": "Faltará pertence à declaração anterior, não aos pastos.",
        },
        "template": "Faz-me ___ em pastos verdejantes",
        "options": opt(("a", "conduz-me"), ("b", "repousar"), ("c", "faltará")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Salmos 23:1-2 liga o pastor, a falta e o descanso?",
        "feedbackCorrect": "Certo: quem pastoreia também faz repousar e conduz.",
        "feedbackWrong": {
            "b": "O descanso não é independência do pastor; ele conduz.",
            "c": "A ausência de falta não dispensa o pastoreio de Jeová.",
            "d": "Pastos e águas são dons da condução, não achados ao acaso.",
        },
        "options": opt(
            ("a", "Quem Jeová pastoreia é feito repousar e conduzido a águas."),
            ("b", "O descanso acontece quando o pastor se afasta."),
            ("c", "Nada faltar torna o pastor desnecessário."),
            ("d", "Pastos e águas aparecem por acaso, sem condução."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Salmos 23:1-2?",
        "feedbackCorrect": "Certo: pastor, pastos e águas nesta ordem.",
        "feedbackWrong": {
            "b": "A identidade do pastor vem antes dos pastos.",
            "c": "As águas de descanso fecham o trecho, não o abrem.",
        },
        "options": opt(
            ("a", "Jeová é o meu pastor"),
            ("b", "Faz-me repousar em pastos verdejantes"),
            ("c", "conduz-me às águas de descanso"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"nada me ___\"",
        "feedbackCorrect": "Certo: sob este pastor, nada faltará.",
        "feedbackWrong": {
            "a": "Repousar descreve a ação nos pastos, não esta lacuna.",
            "b": "Descanso qualifica as águas, não o verbo da falta.",
        },
        "template": "nada me ___",
        "options": opt(("a", "repousar"), ("b", "descanso"), ("c", "faltará")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 23:1-2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: nada falta a quem o pastor faz repousar.",
        "feedbackWrong": {
            "a": "O pastor não promete abandono; ele conduz.",
            "c": "Águas de descanso vêm da condução, não sem ela.",
        },
        "passageA": {"ref": "Salmos 23:1-2", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Pastor que promete abandono"),
            ("b", "Nada falta sob o pastor"),
            ("c", "Águas sem nenhuma condução"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Confiar em Jeová como pastor é reconhecer que descanso e provisão vêm da condução dele.",
        "feedbackCorrect": "Certo: o salmo une pastor, ausência de falta e condução.",
        "feedbackWrong": {"false": "Repouso e águas no texto são ações do pastor, não acaso."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 23:1-2, toque a palavra que falta em \"conduz-me às ___ de descanso\"?",
        "feedbackCorrect": "Exato: ele conduz às águas de descanso.",
        "feedbackWrong": {
            "a": "Pastos é o lugar do repouso, não desta lacuna.",
            "c": "Pastor nomeia a Jeová, não o destino da condução.",
        },
        "template": "conduz-me às ___ de descanso",
        "options": opt(("a", "pastos"), ("b", "águas"), ("c", "pastor")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que sentido teológico Salmos 23:1-2 prepara o leitor a receber?",
        "feedbackCorrect": "Certo: provisão e descanso são dons do pastor, não autonomia.",
        "feedbackWrong": {
            "b": "O salmo não ensina autosuficiência; o pastor conduz.",
            "c": "Nada faltar não é mérito próprio; é pastoreio de Jeová.",
            "d": "As águas de descanso não são fuga de Deus; ele conduz até elas.",
        },
        "options": opt(
            ("a", "Provisão e descanso são dons de quem pastoreia, não autonomia."),
            ("b", "O crente descansa melhor quando dispensa o pastor."),
            ("c", "Nada faltar prova mérito próprio, não pastoreio."),
            ("d", "Águas de descanso servem para fugir de Jeová."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Salmos 23:1-2?",
        "feedbackCorrect": "Certo: pastor, ausência de falta e águas de descanso.",
        "feedbackWrong": {
            "b": "A declaração do pastor precede a ausência de falta.",
            "c": "As águas vêm da condução, no fim do trecho.",
        },
        "options": opt(
            ("a", "Jeová é o meu pastor"),
            ("b", "nada me faltará"),
            ("c", "conduz-me às águas de descanso"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"Faz-me repousar em pastos ___\"",
        "feedbackCorrect": "Certo: os pastos do repouso são verdejantes.",
        "feedbackWrong": {
            "b": "Descanso qualifica as águas, não estes pastos.",
            "c": "Pastor nomeia a Jeová, não a cor dos pastos.",
        },
        "template": "Faz-me repousar em pastos ___",
        "options": opt(("a", "verdejantes"), ("b", "descanso"), ("c", "pastor")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 23:1-2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: Jeová pastoreia até as águas de descanso.",
        "feedbackWrong": {
            "a": "O texto não descreve um rebanho sem pastor.",
            "c": "Faltar o necessário contradiz o versículo 1.",
        },
        "passageA": {"ref": "Salmos 23:1-2", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Rebanho sem nenhum pastor"),
            ("b", "Jeová pastoreia até o descanso"),
            ("c", "Falta como marca do pastoreio"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ── M3 Salmos 13:1–2 ────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "salmos-lamento-01-ate-quando-senhor",
    "Salmos 13:1-2",
    LO3,
    ["Salmos 13:1", "Salmos 13:2"],
    P3,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O salmista pergunta a Jeová até quando ocultará o rosto.",
        "feedbackCorrect": "Certo: o texto registra essa pergunta a Jeová.",
        "feedbackWrong": {"false": "Salmos 13:1 pergunta até quando ocultarás o teu rosto."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 13:1-2, toque a palavra que falta em \"Até quando me ocultarás o teu ___\"?",
        "feedbackCorrect": "Exato: o que se oculta, no lamento, é o rosto.",
        "feedbackWrong": {
            "b": "Alma é o que se enche de cuidados, não esta lacuna.",
            "c": "Inimigo aparece no fim, exaltando-se, não aqui.",
        },
        "template": "Até quando me ocultarás o teu ___",
        "options": opt(("a", "rosto"), ("b", "alma"), ("c", "inimigo")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Salmos 13:1-2 registra de forma explícita?",
        "feedbackCorrect": "Certo: o lamento pergunta até quando a Jeová.",
        "feedbackWrong": {
            "b": "O texto não afirma que o inimigo já foi silenciado.",
            "c": "Há tristeza diária no coração, não alegria contínua.",
            "d": "O salmista não cala a demora; ele pergunta até quando.",
        },
        "options": opt(
            ("a", "O salmista pergunta até quando Jeová se esquecerá dele."),
            ("b", "O inimigo já foi silenciado e não se exalta mais."),
            ("c", "O coração está cheio de alegria diária, sem tristeza."),
            ("d", "O salmista recusa falar a Jeová sobre a demora."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Salmos 13:1-2?",
        "feedbackCorrect": "Certo: esquecimento, rosto oculto e inimigo exaltado.",
        "feedbackWrong": {
            "b": "O esquecimento abre o lamento, não o inimigo.",
            "c": "O rosto oculto vem antes da exaltação do inimigo.",
        },
        "options": opt(
            ("a", "Esquecer-te-ás de mim para sempre"),
            ("b", "Até quando me ocultarás o teu rosto"),
            ("c", "Até quando sobre mim se exaltará o meu inimigo"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"tendo diariamente ___ no meu coração\"",
        "feedbackCorrect": "Certo: a tristeza é diária no coração.",
        "feedbackWrong": {
            "b": "Cuidados enche a alma, não esta lacuna do coração.",
            "c": "Inimigo se exalta sobre ele, não preenche esta lacuna.",
        },
        "template": "tendo diariamente ___ no meu coração",
        "options": opt(("a", "tristeza"), ("b", "cuidados"), ("c", "inimigo")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 13:1-2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o lamento grita até quando a Jeová.",
        "feedbackWrong": {
            "b": "O salmo não escolhe silêncio educado; pergunta.",
            "c": "O esquecimento não é aceito em paz; é questionado.",
        },
        "passageA": {"ref": "Salmos 13:1-2", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Lamento que grita até quando"),
            ("b", "Silêncio educado sem pergunta"),
            ("c", "Esquecimento já aceito em paz"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O salmo esconde a demora de Deus e evita perguntar até quando.",
        "feedbackCorrect": "Certo: o texto repete até quando e não esconde a demora.",
        "feedbackWrong": {"true": "Salmos 13 pergunta até quando quatro vezes; não esconde."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 13:1-2, toque a palavra que falta em \"Até quando encherei a minha ___ de cuidados\"?",
        "feedbackCorrect": "Exato: quem se enche de cuidados é a alma.",
        "feedbackWrong": {
            "a": "Rosto é o que se oculta, não o que se enche.",
            "c": "Coração tem tristeza diária, não esta lacuna.",
        },
        "template": "Até quando encherei a minha ___ de cuidados",
        "options": opt(("a", "rosto"), ("b", "alma"), ("c", "coração")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Salmos 13:1-2 encadeia o lamento diante de Jeová?",
        "feedbackCorrect": "Certo: demora, rosto oculto, cuidados e inimigo se somam.",
        "feedbackWrong": {
            "b": "O texto não trata a demora como assunto fechado.",
            "c": "Tristeza e inimigo fazem parte do mesmo grito, não o excluem.",
            "d": "O lamento é dirigido a Jeová, não a um silêncio vazio.",
        },
        "options": opt(
            ("a", "Esquecimento, rosto oculto, cuidados e inimigo entram no mesmo grito."),
            ("b", "A demora de Deus fica de fora porque já foi resolvida."),
            ("c", "Tristeza no coração impede falar do inimigo."),
            ("d", "O lamento se dirige a ninguém, só descreve o humor."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Salmos 13:1-2?",
        "feedbackCorrect": "Certo: esquecimento, cuidados na alma e inimigo.",
        "feedbackWrong": {
            "b": "O esquecimento vem primeiro, não os cuidados.",
            "c": "O inimigo fecha o trecho, depois da alma cheia de cuidados.",
        },
        "options": opt(
            ("a", "Esquecer-te-ás de mim para sempre"),
            ("b", "encherei a minha alma de cuidados"),
            ("c", "sobre mim se exaltará o meu inimigo"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"Até quando sobre mim se exaltará o meu ___\"",
        "feedbackCorrect": "Certo: quem se exalta sobre ele é o inimigo.",
        "feedbackWrong": {
            "a": "Rosto é o que Jeová oculta, não quem se exalta.",
            "b": "Alma é quem se enche de cuidados, não esta lacuna.",
        },
        "template": "Até quando sobre mim se exaltará o meu ___",
        "options": opt(("a", "rosto"), ("b", "alma"), ("c", "inimigo")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 13:1-2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o salmo não esconde a demora de Deus.",
        "feedbackWrong": {
            "a": "O texto não descreve uma espera muda.",
            "c": "O inimigo exaltado faz parte do lamento, não o apaga.",
        },
        "passageA": {"ref": "Salmos 13:1-2", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Espera muda sem até quando"),
            ("b", "Demora de Deus sem esconder"),
            ("c", "Inimigo que cancela o lamento"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Perguntar até quando a Jeová é fé que recusa esconder a demora de Deus.",
        "feedbackCorrect": "Certo: o lamento é grito de fé, não ausência dela.",
        "feedbackWrong": {"false": "O salmo dirige o até quando a Jeová; isso é fé que clama."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 13:1-2, toque a palavra que falta em \"Esquecer-te-ás de mim para ___\"?",
        "feedbackCorrect": "Exato: o medo nomeado é o esquecimento para sempre.",
        "feedbackWrong": {
            "a": "Rosto pertence à pergunta seguinte, não a esta lacuna.",
            "c": "Inimigo fecha o salmo, não completa para sempre.",
        },
        "template": "Esquecer-te-ás de mim para ___",
        "options": opt(("a", "rosto"), ("b", "sempre"), ("c", "inimigo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que leitura de Salmos 13:1-2 o texto sustenta sobre orar a demora?",
        "feedbackCorrect": "Certo: trazer a demora a Jeová é fé, não incredulidade educada.",
        "feedbackWrong": {
            "b": "Calar a demora não é o modelo deste salmo.",
            "c": "O inimigo exaltado não prova que Jeová deixou de ser o interlocutor.",
            "d": "O lamento não é teatro; é pergunta dirigida a Jeová.",
        },
        "options": opt(
            ("a", "Trazer a demora a Jeová é fé que grita, não falta de fé."),
            ("b", "Fé madura cala a demora e nunca pergunta até quando."),
            ("c", "O inimigo exaltado prova que Jeová não ouve lamento."),
            ("d", "O até quando é só retórica, sem endereço em Deus."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Salmos 13:1-2?",
        "feedbackCorrect": "Certo: o nome de Jeová, o rosto oculto e a tristeza diária.",
        "feedbackWrong": {
            "b": "O vocativo a Jeová abre o lamento.",
            "c": "A tristeza diária vem depois da pergunta pelo rosto.",
        },
        "options": opt(
            ("a", "Até quando, Jeová"),
            ("b", "ocultarás o teu rosto"),
            ("c", "tendo diariamente tristeza no meu coração"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"Até quando, ___! Esquecer-te-ás de mim para sempre?\"",
        "feedbackCorrect": "Certo: o lamento se dirige a Jeová.",
        "feedbackWrong": {
            "b": "Rosto é o que se oculta, não o vocativo.",
            "c": "Inimigo é quem se exalta, não a quem se clama.",
        },
        "template": "Até quando, ___! Esquecer-te-ás de mim para sempre?",
        "options": opt(("a", "Jeová"), ("b", "rosto"), ("c", "inimigo")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 13:1-2 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: fé que grita até quando, sem esconder a demora.",
        "feedbackWrong": {
            "a": "Este salmo não ensina fé muda.",
            "c": "Aceitar o inimigo exaltado não é o convite do texto.",
        },
        "passageA": {"ref": "Salmos 13:1-2", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Fé que nunca pergunta"),
            ("b", "Fé que grita até quando"),
            ("c", "Aceitar o inimigo exaltado"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ── M4 Salmos 51:10 ─────────────────────────────────────────────────
sec, vr, lo, ev, p = (
    "salmos-lamento-02-criai-em-mim-um-cora",
    "Salmos 51:10",
    LO4,
    ["Salmos 51:10"],
    P4,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O salmista pede a Deus: cria em mim um coração limpo.",
        "feedbackCorrect": "Certo: o versículo abre com esse pedido de criação.",
        "feedbackWrong": {"false": "Releia Salmos 51:10: Cria em mim, ó Deus, um coração limpo."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 51:10, toque a palavra que falta em \"___ em mim, ó Deus, um coração limpo\"?",
        "feedbackCorrect": "Exato: o verbo do pedido é Cria, não um conserto vago.",
        "feedbackWrong": {
            "b": "Renova aparece na segunda metade, não nesta abertura.",
            "c": "Espírito é o que se pede estável, não o verbo inicial.",
        },
        "template": "___ em mim, ó Deus, um coração limpo",
        "options": opt(("a", "Cria"), ("b", "renova"), ("c", "espírito")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que Salmos 51:10 pede de forma explícita?",
        "feedbackCorrect": "Certo: coração limpo e espírito estável.",
        "feedbackWrong": {
            "b": "O texto pede espírito estável, não instável.",
            "c": "O pedido é criação, não só memória de pecados alheios.",
            "d": "Há renovação interior, não recusa de um espírito novo.",
        },
        "options": opt(
            ("a", "Um coração limpo e, dentro dele, um espírito estável."),
            ("b", "Um espírito instável para acompanhar o coração."),
            ("c", "Apenas lembrar pecados antigos, sem pedido interior."),
            ("d", "Que Deus recuse renovar qualquer espírito no orante."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Salmos 51:10?",
        "feedbackCorrect": "Certo: cria, coração limpo e espírito estável.",
        "feedbackWrong": {
            "b": "O verbo Cria abre o versículo, não o espírito.",
            "c": "O coração limpo vem antes da renovação do espírito.",
        },
        "options": opt(
            ("a", "Cria em mim, ó Deus"),
            ("b", "um coração limpo"),
            ("c", "e renova, dentro de mim, um espírito estável"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"Cria em mim, ó Deus, um coração ___\"",
        "feedbackCorrect": "Certo: o coração pedido é limpo.",
        "feedbackWrong": {
            "b": "Estável qualifica o espírito, não esta lacuna.",
            "c": "Espírito vem na segunda metade do versículo.",
        },
        "template": "Cria em mim, ó Deus, um coração ___",
        "options": opt(("a", "limpo"), ("b", "estável"), ("c", "espírito")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 51:10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o pedido é criação de coração limpo.",
        "feedbackWrong": {
            "b": "O texto não descreve um conserto superficial.",
            "c": "O espírito pedido é estável, não instável.",
        },
        "passageA": {"ref": "Salmos 51:10", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Criação de coração limpo"),
            ("b", "Conserto só superficial"),
            ("c", "Espírito instável como meta"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O pedido de Salmos 51:10 é só polir o coração antigo, sem criação nem espírito estável.",
        "feedbackCorrect": "Certo: o verbo é cria, e pede-se espírito estável.",
        "feedbackWrong": {"true": "O texto pede criação e renovação, não só polimento."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 51:10, toque a palavra que falta em \"e ___, dentro de mim, um espírito estável\"?",
        "feedbackCorrect": "Exato: a segunda ação é renovar o espírito.",
        "feedbackWrong": {
            "a": "Cria abre o versículo, não esta segunda lacuna.",
            "c": "Limpo qualifica o coração, não este verbo.",
        },
        "template": "e ___, dentro de mim, um espírito estável",
        "options": opt(("a", "Cria"), ("b", "renova"), ("c", "limpo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como Salmos 51:10 relaciona criação e renovação interior?",
        "feedbackCorrect": "Certo: coração limpo e espírito estável vêm juntos.",
        "feedbackWrong": {
            "b": "O espírito estável não é opcional no pedido.",
            "c": "Cria não descreve um retoque cosmética do mesmo coração.",
            "d": "A renovação é dentro de mim, não só no discurso público.",
        },
        "options": opt(
            ("a", "Criar coração limpo e renovar espírito estável formam um só pedido."),
            ("b", "Basta o coração limpo; o espírito estável é extra."),
            ("c", "Cria significa só um retoque externo do mesmo coração."),
            ("d", "A renovação fica fora da pessoa, só na fama pública."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Salmos 51:10?",
        "feedbackCorrect": "Certo: criação, renovação interior e espírito estável.",
        "feedbackWrong": {
            "b": "Cria em mim vem primeiro, não o espírito.",
            "c": "Renovar dentro de mim precede o espírito estável nomeado.",
        },
        "options": opt(
            ("a", "Cria em mim, ó Deus, um coração limpo"),
            ("b", "e renova, dentro de mim"),
            ("c", "um espírito estável"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"e renova, dentro de mim, um espírito ___\"",
        "feedbackCorrect": "Certo: o espírito pedido é estável.",
        "feedbackWrong": {
            "a": "Limpo qualifica o coração, não o espírito nesta lacuna.",
            "b": "Deus é a quem se pede, não o adjetivo do espírito.",
        },
        "template": "e renova, dentro de mim, um espírito ___",
        "options": opt(("a", "limpo"), ("b", "Deus"), ("c", "estável")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 51:10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: criação e espírito estável, não retoque.",
        "feedbackWrong": {
            "a": "O texto não reduz o pedido a um verniz moral.",
            "c": "Não se pede coração sujo; pede-se limpo.",
        },
        "passageA": {"ref": "Salmos 51:10", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Verniz moral sem criação"),
            ("b", "Criação e espírito estável"),
            ("c", "Coração sujo como pedido"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O verbo criar no pedido mostra que o coração limpo não nasce de conserto superficial.",
        "feedbackCorrect": "Certo: cria e renova apontam para obra de Deus no interior.",
        "feedbackWrong": {"false": "Cria em mim não descreve um conserto leve; é criação."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 51:10, toque a palavra que falta em \"um ___ limpo\"?",
        "feedbackCorrect": "Exato: o que se pede limpo é o coração.",
        "feedbackWrong": {
            "b": "Espírito é o que se pede estável, não limpo nesta frase.",
            "c": "Deus é a quem se pede, não o objeto limpo.",
        },
        "template": "um ___ limpo",
        "options": opt(("a", "coração"), ("b", "espírito"), ("c", "Deus")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que sentido teológico Salmos 51:10 prepara o orante a confessar?",
        "feedbackCorrect": "Certo: só Deus cria coração limpo e espírito estável.",
        "feedbackWrong": {
            "b": "O versículo não ensina autossuficiência moral.",
            "c": "Espírito estável não é acessório; faz parte do pedido.",
            "d": "O lugar da obra é dentro de mim, não só o culto visível.",
        },
        "options": opt(
            ("a", "Só Deus cria coração limpo e renova espírito estável no interior."),
            ("b", "O orante limpa o próprio coração sem pedir criação."),
            ("c", "Espírito estável é luxo; o essencial é parecer limpo."),
            ("d", "A obra de Deus fica no culto visível, nunca dentro."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Salmos 51:10?",
        "feedbackCorrect": "Certo: criação do coração e renovação do espírito.",
        "feedbackWrong": {
            "b": "Cria em mim abre o sentido, não o espírito isolado.",
            "c": "A renovação interior liga o coração limpo ao espírito estável.",
        },
        "options": opt(
            ("a", "Cria em mim, ó Deus, um coração limpo"),
            ("b", "e renova, dentro de mim"),
            ("c", "um espírito estável"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"Cria em mim, ó ___, um coração limpo\"",
        "feedbackCorrect": "Certo: o pedido se dirige a Deus.",
        "feedbackWrong": {
            "b": "Mim é o lugar da criação, não o vocativo.",
            "c": "Espírito aparece depois, na renovação.",
        },
        "template": "Cria em mim, ó ___, um coração limpo",
        "options": opt(("a", "Deus"), ("b", "mim"), ("c", "espírito")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 51:10 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: criação, não conserto superficial.",
        "feedbackWrong": {
            "a": "O verbo cria recusa a ideia de mero polimento.",
            "c": "O espírito pedido é estável, obra de Deus.",
        },
        "passageA": {"ref": "Salmos 51:10", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Polir o coração antigo"),
            ("b", "Criação, não conserto raso"),
            ("c", "Espírito estável sem Deus"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ── M5 desafio: 13:1; 51:10; 23:1 ───────────────────────────────────
sec, vr, lo, ev, p = (
    "salmos-lamento-03-desafio-orar-os-salm",
    "Salmos 13:1; 51:10; 23:1",
    LO5,
    ["Salmos 13:1", "Salmos 51:10", "Salmos 23:1"],
    P5,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O desafio junta o grito até quando, o pedido de coração limpo e a confiança de que Jeová é o pastor.",
        "feedbackCorrect": "Certo: os três trechos entram neste palco.",
        "feedbackWrong": {"false": "O palco cita Salmos 13, 51 e 23 juntos."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 13:1; 51:10; 23:1, toque a palavra que falta em \"Cria em mim, ó Deus, um coração ___\"?",
        "feedbackCorrect": "Exato: o coração pedido é limpo.",
        "feedbackWrong": {
            "b": "Pastor pertence a Salmos 23, não a esta lacuna.",
            "c": "Rosto pertence ao lamento de Salmos 13.",
        },
        "template": "Cria em mim, ó Deus, um coração ___",
        "options": opt(("a", "limpo"), ("b", "pastor"), ("c", "rosto")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Quais três movimentos o palco desta missão coloca juntos?",
        "feedbackCorrect": "Certo: lamento, criação interior e pastor.",
        "feedbackWrong": {
            "b": "O palco inclui o lamento de Salmos 13, não o omite.",
            "c": "Há pedido de coração limpo, não só o pastor.",
            "d": "Jeová é o pastor; o texto não nega isso.",
        },
        "options": opt(
            ("a", "Lamento até quando, pedido de coração limpo e Jeová pastor."),
            ("b", "Só louvor, sem lamento e sem pedido interior."),
            ("c", "Apenas o pastor, sem Salmos 13 nem 51."),
            ("d", "A afirmação de que Jeová não é pastor."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em Salmos 13:1; 51:10; 23:1?",
        "feedbackCorrect": "Certo: lamento, criação do coração e pastor.",
        "feedbackWrong": {
            "b": "O até quando de Salmos 13 abre o palco.",
            "c": "O pastor de Salmos 23 fecha a sequência dada.",
        },
        "options": opt(
            ("a", "Até quando, Jeová! Esquecer-te-ás de mim para sempre"),
            ("b", "Cria em mim, ó Deus, um coração limpo"),
            ("c", "Jeová é o meu pastor; nada me faltará"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"Jeová é o meu ___; nada me faltará\"",
        "feedbackCorrect": "Certo: Jeová é o pastor.",
        "feedbackWrong": {
            "b": "Rosto pertence ao lamento, não a esta lacuna.",
            "c": "Coração pertence ao pedido de Salmos 51.",
        },
        "template": "Jeová é o meu ___; nada me faltará",
        "options": opt(("a", "pastor"), ("b", "rosto"), ("c", "coração")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 13:1; 51:10; 23:1 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: lamento, coração novo e confiança no Pastor.",
        "feedbackWrong": {
            "b": "O desafio não reduz a oração a só lamento.",
            "c": "O Pastor não aparece sozinho, sem os outros gestos.",
        },
        "passageA": {"ref": "Salmos 13:1; 51:10; 23:1", "text": P5},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Lamento, coração novo e Pastor"),
            ("b", "Só lamento, sem pedido"),
            ("c", "Pastor sem lamento nem criação"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Orar os Salmos nesta missão é só louvor, sem lamento nem pedido de coração novo.",
        "feedbackCorrect": "Certo: o palco une lamento, pedido e pastor.",
        "feedbackWrong": {"true": "Há Salmos 13 e 51 no palco, não só louvor."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 13:1; 51:10; 23:1, toque a palavra que falta em \"Até quando me ocultarás o teu ___\"?",
        "feedbackCorrect": "Exato: o lamento pergunta pelo rosto oculto.",
        "feedbackWrong": {
            "b": "Pastor pertence a Salmos 23, não a esta pergunta.",
            "c": "Espírito pertence ao pedido de Salmos 51.",
        },
        "template": "Até quando me ocultarás o teu ___",
        "options": opt(("a", "rosto"), ("b", "pastor"), ("c", "espírito")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como os três trechos se encadeiam na oração desta missão?",
        "feedbackCorrect": "Certo: clamar a demora, pedir criação e confiar no pastor.",
        "feedbackWrong": {
            "b": "O pastor não cancela o lamento; os três convivem.",
            "c": "O coração novo não substitui trazer a demora a Deus.",
            "d": "Nada faltará não apaga o até quando de Salmos 13.",
        },
        "options": opt(
            ("a", "Clamar a demora, pedir coração novo e confiar no pastor."),
            ("b", "O pastor dispensa lamento e pedido interior."),
            ("c", "Pedir coração limpo substitui falar da demora."),
            ("d", "Nada faltará torna o até quando desnecessário."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de Salmos 13:1; 51:10; 23:1?",
        "feedbackCorrect": "Certo: rosto oculto, espírito estável e nada faltará.",
        "feedbackWrong": {
            "b": "O rosto oculto pertence ao lamento inicial.",
            "c": "Nada faltará fecha o palco com o pastor.",
        },
        "options": opt(
            ("a", "ocultarás o teu rosto"),
            ("b", "um espírito estável"),
            ("c", "nada me faltará"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"renova, dentro de mim, um espírito ___\"",
        "feedbackCorrect": "Certo: o espírito pedido é estável.",
        "feedbackWrong": {
            "a": "Sempre pertence ao lamento de Salmos 13.",
            "b": "Pastor pertence a Salmos 23, não a esta lacuna.",
        },
        "template": "renova, dentro de mim, um espírito ___",
        "options": opt(("a", "sempre"), ("b", "pastor"), ("c", "estável")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 13:1; 51:10; 23:1 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: orar os Salmos une os três gestos.",
        "feedbackWrong": {
            "a": "Louvor isolado não descreve este palco.",
            "c": "O pedido interior não vem sozinho, sem lamento nem pastor.",
        },
        "passageA": {"ref": "Salmos 13:1; 51:10; 23:1", "text": P5},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Louvor isolado sem lamento"),
            ("b", "Lamento, pedido e confiança"),
            ("c", "Pedido interior sem Pastor"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Orar os Salmos ensina a trazer a demora, pedir criação interior e descansar no Pastor.",
        "feedbackCorrect": "Certo: os três textos formam essa escola de oração.",
        "feedbackWrong": {"false": "13, 51 e 23 juntos ensinam lamento, criação e pastor."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em Salmos 13:1; 51:10; 23:1, toque a palavra que falta em \"Esquecer-te-ás de mim para ___\"?",
        "feedbackCorrect": "Exato: o lamento teme o esquecimento para sempre.",
        "feedbackWrong": {
            "a": "Limpo qualifica o coração de Salmos 51.",
            "c": "Pastor pertence a Salmos 23.",
        },
        "template": "Esquecer-te-ás de mim para ___",
        "options": opt(("a", "limpo"), ("b", "sempre"), ("c", "pastor")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Que leitura teológica este palco sustenta sobre orar os Salmos?",
        "feedbackCorrect": "Certo: lamento, criação e pastor cabem na mesma oração.",
        "feedbackWrong": {
            "b": "Fé neste palco não cala o até quando.",
            "c": "O Pastor não torna inútil pedir coração limpo.",
            "d": "Os três textos não se anulam; se somam na oração.",
        },
        "options": opt(
            ("a", "Lamento, coração novo e confiança no Pastor cabem juntos."),
            ("b", "Fé madura abandona o até quando e só louva."),
            ("c", "Quem tem Pastor não precisa pedir coração limpo."),
            ("d", "Os três textos se anulam e não se oram juntos."),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de Salmos 13:1; 51:10; 23:1?",
        "feedbackCorrect": "Certo: até quando, cria em mim e Jeová é pastor.",
        "feedbackWrong": {
            "b": "O lamento a Jeová abre o sentido do palco.",
            "c": "O pastor fecha a tríade, depois da criação interior.",
        },
        "options": opt(
            ("a", "Até quando, Jeová"),
            ("b", "Cria em mim, ó Deus, um coração limpo"),
            ("c", "Jeová é o meu pastor"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete a frase: \"Jeová é o meu pastor; nada me ___\"",
        "feedbackCorrect": "Certo: nada faltará a quem ele pastoreia.",
        "feedbackWrong": {
            "a": "Limpo descreve o coração, não esta lacuna.",
            "b": "Rosto pertence ao lamento de Salmos 13.",
        },
        "template": "Jeová é o meu pastor; nada me ___",
        "options": opt(("a", "limpo"), ("b", "rosto"), ("c", "faltará")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que Salmos 13:1; 51:10; 23:1 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: orar os Salmos é essa tríade.",
        "feedbackWrong": {
            "a": "Trocar o Pastor por silêncio não é o convite.",
            "c": "Pedir coração novo sem Jeová corta o palco.",
        },
        "passageA": {"ref": "Salmos 13:1; 51:10; 23:1", "text": P5},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Trocar o Pastor por silêncio"),
            ("b", "Lamento, pedido e confiança"),
            ("c", "Coração novo sem Jeová"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]


def main():
    out = Path(__file__).resolve().parent / "salmos.json"
    out.write_text(json.dumps(Qs, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{out} {len(Qs)}")
    # extra checks
    bad_tb = [q["id"] for q in Qs if "Bem-aventurado" in json.dumps(q, ensure_ascii=False) or "Criai" in json.dumps(q, ensure_ascii=False)]
    m1_23 = [q["id"] for q in Qs if q["section"].endswith("bem-aventurado-o-hom") and "23" in (q.get("passageText") or "") and "pastor" in (q.get("passageText") or "")]
    print("TB Almeida leaks:", bad_tb)
    print("M1 hooked to 23:", m1_23)
    longs = [q["id"] for q in Qs if len(q.get("feedbackCorrect", "")) > 100]
    print("long feedback:", longs)
    print("sections", sorted({q["section"] for q in Qs}))


if __name__ == "__main__":
    main()
