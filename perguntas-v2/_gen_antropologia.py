#!/usr/bin/env python3
"""Gera perguntas-v2/antropologia.json (72 perguntas, 4 missões)."""
import json
from pathlib import Path

TB_GEN = (
    "Disse também Deus: Façamos o homem à nossa imagem, conforme a nossa semelhança; "
    "domine ele sobre os peixes do mar, sobre as aves do céu, sobre os animais domésticos, "
    "sobre toda a terra e sobre todo réptil que se arrasta sobre a terra. "
    "Criou, pois, Deus o homem à sua imagem, à imagem de Deus o criou; homem e mulher os criou."
)
TB_ROM = "porque todos pecaram e necessitam da glória de Deus,"
TB_EF = (
    "Pois somos feitura dele, criados em Cristo Jesus para boas obras, "
    "as quais Deus, antes, preparou para que andássemos nelas."
)
TB_BOSS = f"{TB_GEN} {TB_ROM} {TB_EF}"

TF = [{"id": "true", "text": "Verdadeiro"}, {"id": "false", "text": "Falso"}]


def q(
    trail,
    section,
    difficulty,
    n,
    typ,
    question,
    verse_ref,
    lo,
    evidence,
    fc,
    fw,
    *,
    passage=None,
    template=None,
    options=None,
    correct="a",
    correct_order=None,
    passage_a=None,
    passage_b=None,
):
    skill = {"semente": "observe", "caminhada": "understand", "profundezas": "interpret"}[difficulty]
    short = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}[difficulty]
    item = {
        "difficulty": difficulty,
        "skill": skill,
        "verseRef": verse_ref,
        "learningObjective": lo,
        "evidence": evidence,
        "type": typ,
        "question": question,
        "prompt": question,
        "cue": question,
        "feedbackCorrect": fc,
        "feedbackWrong": fw,
        "trail": trail,
        "section": section,
        "id": f"{trail}-{short}-{section}-{n}",
    }
    if passage:
        item["passageText"] = passage
    if template:
        item["template"] = template
    if options:
        item["options"] = options
    if typ == "order":
        item["correctOrder"] = correct_order or ["a", "b", "c"]
        item["correctOptionId"] = "a"
        item["correctAnswer"] = "a"
    else:
        item["correctOptionId"] = correct
        item["correctAnswer"] = correct
    if passage_a:
        item["passageA"] = passage_a
    if passage_b:
        item["passageB"] = passage_b
    assert len(fc) <= 100, (len(fc), fc)
    if typ == "choice":
        for o in options:
            assert len(o["text"]) <= 90, (len(o["text"]), o["text"])
    return item


def mission(section, verse_ref, lo, evidence, passage, items_by_diff):
    out = []
    for diff, items in items_by_diff.items():
        for it in items:
            out.append(
                q(
                    "antropologia",
                    section,
                    diff,
                    it["n"],
                    it["type"],
                    it["question"],
                    verse_ref,
                    lo,
                    evidence,
                    it["fc"],
                    it["fw"],
                    passage=it.get("passage", passage),
                    template=it.get("template"),
                    options=it.get("options"),
                    correct=it.get("correct", "a"),
                    correct_order=it.get("correctOrder"),
                    passage_a=it.get("passageA"),
                    passage_b=it.get("passageB"),
                )
            )
    return out


# ── M1 an-01-imagem ──────────────────────────────────────────────
LO1 = "Reconhecer que homem e mulher foram criados à imagem de Deus, com domínio sobre a terra."
EV1 = ["Gênesis 1:26", "Gênesis 1:27"]
VR1 = "Gênesis 1:26–27"
INS1 = "Feitos à imagem: homem e mulher criados à imagem de Deus, com domínio sobre a terra."

m1 = mission(
    "an-01-imagem",
    VR1,
    LO1,
    EV1,
    TB_GEN,
    {
        "semente": [
            {
                "n": "01",
                "type": "true_false",
                "question": "Deus criou o homem à sua imagem; homem e mulher os criou.",
                "fc": "Certo: Gênesis 1:27 afirma isso de modo direto.",
                "fw": {"false": "Releia Gênesis 1:27: Deus criou o homem à sua imagem."},
                "options": TF,
                "correct": "true",
            },
            {
                "n": "02",
                "type": "tap",
                "question": 'Em Gênesis 1:26–27, toque a palavra que falta em "Façamos o homem à nossa ___, conforme a nossa semelhança"?',
                "fc": 'Exato: o texto diz "à nossa imagem".',
                "fw": {
                    "b": "Semelhança vem depois, na mesma frase.",
                    "c": "Homem é quem é feito, não a palavra desta lacuna.",
                },
                "template": "Façamos o homem à nossa ___, conforme a nossa semelhança",
                "options": [
                    {"id": "a", "text": "imagem"},
                    {"id": "b", "text": "semelhança"},
                    {"id": "c", "text": "homem"},
                ],
                "correct": "a",
            },
            {
                "n": "03",
                "type": "choice",
                "question": "Qual fato Gênesis 1:26–27 afirma sobre a criação do homem?",
                "fc": "Certo: o texto liga imagem de Deus e domínio sobre a terra.",
                "fw": {
                    "b": "O texto não restringe a imagem a um só gênero.",
                    "c": "O domínio é dado ao homem, não o contrário.",
                    "d": "O texto fala de criação, não de evolução gradual.",
                },
                "options": [
                    {"id": "a", "text": "Deus fez o homem à sua imagem e lhe deu domínio sobre a terra"},
                    {"id": "b", "text": "Só o homem, e não a mulher, foi feito à imagem de Deus"},
                    {"id": "c", "text": "Os animais receberam domínio sobre o homem e a mulher"},
                    {"id": "d", "text": "O homem surgiu sozinho, sem qualquer ato criador de Deus"},
                ],
                "correct": "a",
            },
            {
                "n": "04",
                "type": "order",
                "question": "Qual sequência mostra a ordem dos fatos em Gênesis 1:26–27?",
                "fc": "Certo: proposta, domínio e criação de homem e mulher.",
                "fw": {
                    "b": "O domínio é proposto antes do relato da criação.",
                    "c": "Homem e mulher aparecem no fim, não no começo.",
                },
                "options": [
                    {"id": "a", "text": "Façamos o homem à nossa imagem, conforme a nossa semelhança"},
                    {"id": "b", "text": "domine ele sobre os peixes do mar, sobre as aves do céu, sobre os animais domésticos"},
                    {"id": "c", "text": "Criou, pois, Deus o homem à sua imagem; homem e mulher os criou"},
                ],
            },
            {
                "n": "05",
                "type": "complete",
                "question": 'Complete: "Criou, pois, Deus o homem à sua imagem, à imagem de Deus o criou; homem e ___ os criou"',
                "fc": "Certo: o texto diz homem e mulher os criou.",
                "fw": {
                    "b": "Imagem já apareceu antes nesta frase.",
                    "c": "Deus é o criador, não o complemento desta lacuna.",
                },
                "template": "Criou, pois, Deus o homem à sua imagem, à imagem de Deus o criou; homem e ___ os criou",
                "options": [
                    {"id": "a", "text": "mulher"},
                    {"id": "b", "text": "imagem"},
                    {"id": "c", "text": "Deus"},
                ],
                "correct": "a",
            },
            {
                "n": "06",
                "type": "connect",
                "question": "O que Gênesis 1:26–27 comunica que se liga a este contexto?",
                "fc": "Certo: homem e mulher carregam a imagem e o domínio.",
                "fw": {
                    "b": "O texto inclui homem e mulher na imagem de Deus.",
                    "c": "O domínio é dado, não conquistado contra Deus.",
                },
                "passageA": {"ref": "Gênesis 1:26–27", "text": TB_GEN},
                "passageB": {"ref": "Contexto", "text": INS1},
                "options": [
                    {"id": "a", "text": "Imagem de Deus em homem e mulher"},
                    {"id": "b", "text": "Imagem restrita só ao homem"},
                    {"id": "c", "text": "Domínio conquistado contra Deus"},
                ],
                "correct": "a",
            },
        ],
        "caminhada": [
            {
                "n": "01",
                "type": "true_false",
                "question": "Em Gênesis 1:26–27, a semelhança com Deus exclui a mulher da vocação de governar a terra.",
                "fc": "Certo: homem e mulher são criados; o domínio é dado ao homem.",
                "fw": {
                    "true": "O texto cria homem e mulher à imagem e atribui domínio à humanidade."
                },
                "options": TF,
                "correct": "false",
            },
            {
                "n": "02",
                "type": "tap",
                "question": 'Em Gênesis 1:26–27, toque a palavra que falta em "Façamos o homem à nossa imagem, conforme a nossa ___"?',
                "fc": 'Exato: "semelhança" completa o par com "imagem".',
                "fw": {
                    "b": "Imagem veio antes nesta mesma frase.",
                    "c": "Terra aparece depois, no mandato de domínio.",
                },
                "template": "Façamos o homem à nossa imagem, conforme a nossa ___",
                "options": [
                    {"id": "a", "text": "semelhança"},
                    {"id": "b", "text": "imagem"},
                    {"id": "c", "text": "terra"},
                ],
                "correct": "a",
            },
            {
                "n": "03",
                "type": "choice",
                "question": "Como se relacionam imagem de Deus e domínio em Gênesis 1:26–27?",
                "fc": "Certo: o domínio flui da criação à imagem, não a substitui.",
                "fw": {
                    "a": "O texto une imagem e mandato; não os opõe.",
                    "c": "O domínio é sobre a terra, não sobre o Criador.",
                    "d": "O texto não reduz a imagem a um traço físico isolado.",
                },
                "options": [
                    {"id": "a", "text": "O domínio substitui a imagem, tornando-a dispensável"},
                    {"id": "b", "text": "Quem é feito à imagem recebe o mandato de governar a terra"},
                    {"id": "c", "text": "A imagem serve para que o homem domine o próprio Deus"},
                    {"id": "d", "text": "A imagem descreve só a aparência corporal, sem vocação"},
                ],
                "correct": "b",
            },
            {
                "n": "04",
                "type": "order",
                "question": "Como se encadeiam os eventos de Gênesis 1:26–27?",
                "fc": "Certo: proposta, semelhança e criação de homem e mulher.",
                "fw": {
                    "b": "A semelhança vem junto da proposta, não no fim.",
                    "c": "A criação de homem e mulher conclui o trecho.",
                },
                "options": [
                    {"id": "a", "text": "Façamos o homem à nossa imagem"},
                    {"id": "b", "text": "conforme a nossa semelhança"},
                    {"id": "c", "text": "homem e mulher os criou"},
                ],
            },
            {
                "n": "05",
                "type": "complete",
                "question": 'Complete: "domine ele sobre os peixes do mar, sobre as aves do céu, sobre os animais domésticos, sobre toda a terra e sobre todo ___ que se arrasta sobre a terra"',
                "fc": "Certo: o mandato inclui todo réptil que se arrasta.",
                "fw": {
                    "b": "Peixes aparecem no início da lista de domínio.",
                    "c": "Aves vêm em seguida, não nesta lacuna.",
                },
                "template": "domine ele sobre os peixes do mar, sobre as aves do céu, sobre os animais domésticos, sobre toda a terra e sobre todo ___ que se arrasta sobre a terra",
                "options": [
                    {"id": "a", "text": "réptil"},
                    {"id": "b", "text": "peixes"},
                    {"id": "c", "text": "aves"},
                ],
                "correct": "a",
            },
            {
                "n": "06",
                "type": "connect",
                "question": "O que Gênesis 1:26 comunica que se liga a este contexto?",
                "fc": "Certo: a imagem inclui o mandato de governar a terra.",
                "fw": {
                    "b": "O texto dá domínio; não reduz o homem a espectador.",
                    "c": "Homem e mulher compartilham a imagem, não a rivalizam.",
                },
                "passageA": {
                    "ref": "Gênesis 1:26",
                    "text": "Façamos o homem à nossa imagem, conforme a nossa semelhança; domine ele sobre os peixes do mar, sobre as aves do céu, sobre os animais domésticos, sobre toda a terra e sobre todo réptil que se arrasta sobre a terra.",
                },
                "passageB": {"ref": "Contexto", "text": INS1},
                "options": [
                    {"id": "a", "text": "Imagem com mandato sobre a terra"},
                    {"id": "b", "text": "Humanidade sem qualquer vocação"},
                    {"id": "c", "text": "Rivalidade entre homem e mulher"},
                ],
                "correct": "a",
            },
        ],
        "profundezas": [
            {
                "n": "01",
                "type": "true_false",
                "question": "Gênesis 1:26–27 apresenta a dignidade humana como dom da criação à imagem, compartilhada por homem e mulher.",
                "fc": "Certo: a imagem funda a dignidade de homem e mulher.",
                "fw": {
                    "false": "O texto cria ambos à imagem de Deus; a dignidade não é inventada depois."
                },
                "options": TF,
                "correct": "true",
            },
            {
                "n": "02",
                "type": "tap",
                "question": 'Em Gênesis 1:26–27, toque a palavra que falta em "Criou, pois, Deus o homem à sua imagem, à imagem de Deus o criou; homem e mulher os ___"?',
                "fc": 'Exato: "criou" fecha o ato de Deus sobre homem e mulher.',
                "fw": {
                    "b": "Domine descreve o mandato, não este verbo final.",
                    "c": "Arrasta descreve o réptil, não a criação do homem.",
                },
                "template": "Criou, pois, Deus o homem à sua imagem, à imagem de Deus o criou; homem e mulher os ___",
                "options": [
                    {"id": "a", "text": "criou"},
                    {"id": "b", "text": "domine"},
                    {"id": "c", "text": "arrasta"},
                ],
                "correct": "a",
            },
            {
                "n": "03",
                "type": "choice",
                "question": "Que leitura teológica Gênesis 1:26–27 sustenta sobre o ser humano?",
                "fc": "Certo: a imagem é dom do Criador, não conquista humana.",
                "fw": {
                    "a": "O texto não afirma que o homem se torne divino.",
                    "c": "A imagem não apaga a distinção entre Criador e criatura.",
                    "d": "O mandato não autoriza destruição da terra.",
                },
                "options": [
                    {"id": "a", "text": "O homem é divino em essência e não precisa de Deus"},
                    {"id": "b", "text": "A humanidade recebe dignidade e vocação da imagem do Criador"},
                    {"id": "c", "text": "Criador e criatura se confundem numa só natureza"},
                    {"id": "d", "text": "O domínio autoriza o homem a destruir a terra à vontade"},
                ],
                "correct": "b",
            },
            {
                "n": "04",
                "type": "order",
                "question": "Qual sequência revela o sentido de Gênesis 1:26–27?",
                "fc": "Certo: proposta, ato criador e homem e mulher.",
                "fw": {
                    "b": "O ato criador vem depois da proposta, não antes.",
                    "c": "Homem e mulher fecham o sentido do trecho.",
                },
                "options": [
                    {"id": "a", "text": "Façamos o homem à nossa imagem, conforme a nossa semelhança"},
                    {"id": "b", "text": "Criou, pois, Deus o homem à sua imagem"},
                    {"id": "c", "text": "homem e mulher os criou"},
                ],
            },
            {
                "n": "05",
                "type": "complete",
                "question": 'Complete: "Disse também Deus: Façamos o ___ à nossa imagem, conforme a nossa semelhança"',
                "fc": "Certo: o objeto da proposta é o homem.",
                "fw": {
                    "b": "Réptil é objeto de domínio, não desta lacuna.",
                    "c": "Peixes também estão na lista de domínio.",
                },
                "template": "Disse também Deus: Façamos o ___ à nossa imagem, conforme a nossa semelhança",
                "options": [
                    {"id": "a", "text": "homem"},
                    {"id": "b", "text": "réptil"},
                    {"id": "c", "text": "peixes"},
                ],
                "correct": "a",
            },
            {
                "n": "06",
                "type": "connect",
                "question": "O que Gênesis 1:27 comunica que se liga a este contexto?",
                "fc": "Certo: a imagem inclui homem e mulher, sem exclusão.",
                "fw": {
                    "b": "O texto não reduz a imagem a um gênero só.",
                    "c": "A criação à imagem não é mérito humano.",
                },
                "passageA": {
                    "ref": "Gênesis 1:27",
                    "text": "Criou, pois, Deus o homem à sua imagem, à imagem de Deus o criou; homem e mulher os criou.",
                },
                "passageB": {"ref": "Contexto", "text": INS1},
                "options": [
                    {"id": "a", "text": "Imagem compartilhada por ambos"},
                    {"id": "b", "text": "Imagem só de um gênero"},
                    {"id": "c", "text": "Dignidade conquistada pelo mérito"},
                ],
                "correct": "a",
            },
        ],
    },
)

# ── M2 an-02-queda ───────────────────────────────────────────────
LO2 = "Reconhecer que todos pecaram e necessitam da glória de Deus — a imagem não anula a queda."
EV2 = ["Romanos 3:23"]
VR2 = "Romanos 3:23"
INS2 = "O pecado entrou: todos pecaram e necessitam da glória — a imagem não anula a queda."

m2 = mission(
    "an-02-queda",
    VR2,
    LO2,
    EV2,
    TB_ROM,
    {
        "semente": [
            {
                "n": "01",
                "type": "true_false",
                "question": "Todos pecaram e necessitam da glória de Deus.",
                "fc": "Certo: é o que Romanos 3:23 afirma literalmente.",
                "fw": {"false": "Releia Romanos 3:23: todos pecaram e necessitam da glória."},
                "options": TF,
                "correct": "true",
            },
            {
                "n": "02",
                "type": "tap",
                "question": 'Em Romanos 3:23, toque a palavra que falta em "porque todos ___ e necessitam da glória de Deus"?',
                "fc": 'Exato: o texto diz que todos "pecaram".',
                "fw": {
                    "b": "Todos é o sujeito, não o verbo desta lacuna.",
                    "c": "Glória é o que falta depois, não o verbo.",
                },
                "template": "porque todos ___ e necessitam da glória de Deus",
                "options": [
                    {"id": "a", "text": "pecaram"},
                    {"id": "b", "text": "todos"},
                    {"id": "c", "text": "glória"},
                ],
                "correct": "a",
            },
            {
                "n": "03",
                "type": "choice",
                "question": "Qual afirmação Romanos 3:23 faz de modo explícito?",
                "fc": "Certo: o texto universaliza o pecado e a necessidade.",
                "fw": {
                    "b": "O texto não isenta ninguém da necessidade da glória.",
                    "c": "O versículo não afirma pecadores sem falta da glória.",
                    "d": "O texto não restringe o pecado a um grupo isolado.",
                },
                "options": [
                    {"id": "a", "text": "Todos pecaram e necessitam da glória de Deus"},
                    {"id": "b", "text": "Só alguns pecaram; os demais já possuem a glória"},
                    {"id": "c", "text": "Todos pecaram, mas ninguém necessita da glória"},
                    {"id": "d", "text": "Apenas os gentios pecaram; Israel permanece isento"},
                ],
                "correct": "a",
            },
            {
                "n": "04",
                "type": "order",
                "question": "Qual sequência mostra a ordem dos fatos em Romanos 3:23?",
                "fc": "Certo: pecado de todos, necessidade e glória de Deus.",
                "fw": {
                    "b": "A necessidade vem depois do pecado, não antes.",
                    "c": "A glória de Deus fecha a frase, não a abre.",
                },
                "options": [
                    {"id": "a", "text": "porque todos pecaram"},
                    {"id": "b", "text": "e necessitam"},
                    {"id": "c", "text": "da glória de Deus"},
                ],
            },
            {
                "n": "05",
                "type": "complete",
                "question": 'Complete: "porque todos pecaram e necessitam da ___ de Deus"',
                "fc": "Certo: o que falta é a glória de Deus.",
                "fw": {
                    "b": "Todos é o sujeito no início da frase.",
                    "c": "Pecaram é o verbo anterior, não esta lacuna.",
                },
                "template": "porque todos pecaram e necessitam da ___ de Deus",
                "options": [
                    {"id": "a", "text": "glória"},
                    {"id": "b", "text": "todos"},
                    {"id": "c", "text": "pecaram"},
                ],
                "correct": "a",
            },
            {
                "n": "06",
                "type": "connect",
                "question": "O que Romanos 3:23 comunica que se liga a este contexto?",
                "fc": "Certo: a queda alcança todos e expõe a falta da glória.",
                "fw": {
                    "b": "O texto não isenta quem foi feito à imagem.",
                    "c": "Necessitar da glória não é indiferença a Deus.",
                },
                "passageA": {"ref": "Romanos 3:23", "text": TB_ROM},
                "passageB": {"ref": "Contexto", "text": INS2},
                "options": [
                    {"id": "a", "text": "Queda universal, falta da glória"},
                    {"id": "b", "text": "Imagem que cancela o pecado"},
                    {"id": "c", "text": "Pecado sem falta da glória"},
                ],
                "correct": "a",
            },
        ],
        "caminhada": [
            {
                "n": "01",
                "type": "true_false",
                "question": "Romanos 3:23 restringe o pecado a alguns, de modo que outros já possuem a glória de Deus por si mesmos.",
                "fc": "Certo: o texto diz todos, sem exceção autojustificada.",
                "fw": {"true": "Todos pecaram e necessitam da glória; ninguém fica de fora."},
                "options": TF,
                "correct": "false",
            },
            {
                "n": "02",
                "type": "tap",
                "question": 'Em Romanos 3:23, toque a palavra que falta em "porque todos pecaram e ___ da glória de Deus"?',
                "fc": 'Exato: "necessitam" liga o pecado à falta da glória.',
                "fw": {
                    "b": "Pecaram é o verbo anterior, não esta lacuna.",
                    "c": "Glória é o objeto da necessidade, não o verbo.",
                },
                "template": "porque todos pecaram e ___ da glória de Deus",
                "options": [
                    {"id": "a", "text": "necessitam"},
                    {"id": "b", "text": "pecaram"},
                    {"id": "c", "text": "glória"},
                ],
                "correct": "a",
            },
            {
                "n": "03",
                "type": "choice",
                "question": "Como Romanos 3:23 relaciona pecado e glória de Deus?",
                "fc": "Certo: o pecado deixa a humanidade na falta da glória.",
                "fw": {
                    "a": "O texto une pecado e necessidade; não os separa.",
                    "c": "A necessidade é da glória de Deus, não de mérito próprio.",
                    "d": "O versículo não trata a glória como luxo opcional.",
                },
                "options": [
                    {"id": "a", "text": "O pecado existe, mas ninguém perde a glória de Deus"},
                    {"id": "b", "text": "O pecado universal deixa todos na falta da glória de Deus"},
                    {"id": "c", "text": "A glória de Deus se alcança pelo esforço sem necessidade"},
                    {"id": "d", "text": "A glória de Deus é um detalhe opcional após o pecado"},
                ],
                "correct": "b",
            },
            {
                "n": "04",
                "type": "order",
                "question": "Como se encadeiam os eventos de Romanos 3:23?",
                "fc": "Certo: todos, pecaram e necessitam da glória.",
                "fw": {
                    "b": "O pecado vem depois de todos, não no fim.",
                    "c": "A necessidade da glória conclui a frase.",
                },
                "options": [
                    {"id": "a", "text": "todos"},
                    {"id": "b", "text": "pecaram"},
                    {"id": "c", "text": "necessitam da glória de Deus"},
                ],
            },
            {
                "n": "05",
                "type": "complete",
                "question": 'Complete: "porque ___ pecaram e necessitam da glória de Deus"',
                "fc": 'Certo: o sujeito é "todos".',
                "fw": {
                    "b": "Deus é o dono da glória, não o sujeito desta lacuna.",
                    "c": "Glória vem no fim da frase.",
                },
                "template": "porque ___ pecaram e necessitam da glória de Deus",
                "options": [
                    {"id": "a", "text": "todos"},
                    {"id": "b", "text": "Deus"},
                    {"id": "c", "text": "glória"},
                ],
                "correct": "a",
            },
            {
                "n": "06",
                "type": "connect",
                "question": "O que Romanos 3:23 comunica que se liga a este contexto?",
                "fc": "Certo: a imagem não cancela a necessidade da glória.",
                "fw": {
                    "b": "O versículo não descreve inocência preservada.",
                    "c": "A necessidade da glória não é privilégio de poucos.",
                },
                "passageA": {"ref": "Romanos 3:23", "text": TB_ROM},
                "passageB": {"ref": "Contexto", "text": INS2},
                "options": [
                    {"id": "a", "text": "Imagem não anula a queda"},
                    {"id": "b", "text": "Humanidade ainda inocente"},
                    {"id": "c", "text": "Glória só para alguns"},
                ],
                "correct": "a",
            },
        ],
        "profundezas": [
            {
                "n": "01",
                "type": "true_false",
                "question": "Romanos 3:23 mostra que a dignidade da imagem não dispensa a humanidade da necessidade da glória de Deus.",
                "fc": "Certo: a queda expõe a falta da glória em todos.",
                "fw": {
                    "false": "Todos necessitam da glória; a imagem não cancela essa falta."
                },
                "options": TF,
                "correct": "true",
            },
            {
                "n": "02",
                "type": "tap",
                "question": 'Em Romanos 3:23, toque a palavra que falta em "porque todos pecaram e necessitam da glória de ___"?',
                "fc": 'Exato: a glória em falta é "de Deus".',
                "fw": {
                    "b": "Todos é o sujeito no início.",
                    "c": "Pecaram descreve o ato, não o dono da glória.",
                },
                "template": "porque todos pecaram e necessitam da glória de ___",
                "options": [
                    {"id": "a", "text": "Deus"},
                    {"id": "b", "text": "todos"},
                    {"id": "c", "text": "pecaram"},
                ],
                "correct": "a",
            },
            {
                "n": "03",
                "type": "choice",
                "question": "Que erro de leitura Romanos 3:23 corrige sobre o ser humano?",
                "fc": "Certo: ninguém fica de fora da falta da glória.",
                "fw": {
                    "a": "O texto não ensina pecadores autossuficientes.",
                    "c": "O versículo não reduz o pecado a um defeito leve.",
                    "d": "A necessidade da glória não é negada pelo texto.",
                },
                "options": [
                    {"id": "a", "text": "O homem peca, mas já possui em si a glória de Deus"},
                    {"id": "b", "text": "Ninguém fica de fora do pecado nem da falta da glória"},
                    {"id": "c", "text": "O pecado é só um defeito social, sem relação com Deus"},
                    {"id": "d", "text": "A glória de Deus nunca esteve em questão para o pecador"},
                ],
                "correct": "b",
            },
            {
                "n": "04",
                "type": "order",
                "question": "Qual sequência revela o sentido de Romanos 3:23?",
                "fc": "Certo: universalidade, pecado e falta da glória.",
                "fw": {
                    "b": "O pecado vem depois da universalidade, não no fim.",
                    "c": "A falta da glória é o desfecho, não o início.",
                },
                "options": [
                    {"id": "a", "text": "porque todos"},
                    {"id": "b", "text": "pecaram"},
                    {"id": "c", "text": "e necessitam da glória de Deus"},
                ],
            },
            {
                "n": "05",
                "type": "complete",
                "question": 'Complete: "porque todos pecaram e ___ da glória de Deus"',
                "fc": 'Certo: "necessitam" nomeia a condição após o pecado.',
                "fw": {
                    "b": "Porque abre a frase, não esta lacuna.",
                    "c": "Todos já apareceu como sujeito.",
                },
                "template": "porque todos pecaram e ___ da glória de Deus",
                "options": [
                    {"id": "a", "text": "necessitam"},
                    {"id": "b", "text": "porque"},
                    {"id": "c", "text": "todos"},
                ],
                "correct": "a",
            },
            {
                "n": "06",
                "type": "connect",
                "question": "O que Romanos 3:23 comunica que se liga a este contexto?",
                "fc": "Certo: a antropologia inclui queda, não só imagem.",
                "fw": {
                    "b": "O texto não descreve humanidade sem pecado.",
                    "c": "A glória em falta é de Deus, não um ornamento extra.",
                },
                "passageA": {"ref": "Romanos 3:23", "text": TB_ROM},
                "passageB": {"ref": "Contexto", "text": INS2},
                "options": [
                    {"id": "a", "text": "Antropologia com queda real"},
                    {"id": "b", "text": "Humanidade sem qualquer pecado"},
                    {"id": "c", "text": "Glória como detalhe opcional"},
                ],
                "correct": "a",
            },
        ],
    },
)

# ── M3 an-03-nova ────────────────────────────────────────────────
LO3 = "Reconhecer que somos feitura de Deus em Cristo, criados para obras que ele preparou."
EV3 = ["Efésios 2:10"]
VR3 = "Efésios 2:10"
INS3 = "Nova humanidade: feitura de Deus em Cristo, criados para obras que ele preparou."

m3 = mission(
    "an-03-nova",
    VR3,
    LO3,
    EV3,
    TB_EF,
    {
        "semente": [
            {
                "n": "01",
                "type": "true_false",
                "question": "Somos feitura dele, criados em Cristo Jesus para boas obras.",
                "fc": "Certo: Efésios 2:10 afirma isso literalmente.",
                "fw": {"false": "Releia Efésios 2:10: feitura dele, criados em Cristo."},
                "options": TF,
                "correct": "true",
            },
            {
                "n": "02",
                "type": "tap",
                "question": 'Em Efésios 2:10, toque a palavra que falta em "Pois somos ___ dele, criados em Cristo Jesus para boas obras"?',
                "fc": 'Exato: "feitura" nomeia o que somos em Deus.',
                "fw": {
                    "b": "Obras vem depois, como finalidade.",
                    "c": "Cristo é o âmbito da criação, não esta lacuna.",
                },
                "template": "Pois somos ___ dele, criados em Cristo Jesus para boas obras",
                "options": [
                    {"id": "a", "text": "feitura"},
                    {"id": "b", "text": "obras"},
                    {"id": "c", "text": "Cristo"},
                ],
                "correct": "a",
            },
            {
                "n": "03",
                "type": "choice",
                "question": "Qual fato Efésios 2:10 afirma sobre os que estão em Cristo?",
                "fc": "Certo: criados em Cristo para obras que Deus preparou.",
                "fw": {
                    "b": "O texto não diz que as obras nos criam.",
                    "c": "Deus preparou as obras de antemão, não as improvisou.",
                    "d": "O texto liga a nova criação a Cristo Jesus.",
                },
                "options": [
                    {"id": "a", "text": "Somos feitura de Deus, criados em Cristo para boas obras"},
                    {"id": "b", "text": "As boas obras nos criam e nos tornam feitura de Deus"},
                    {"id": "c", "text": "Deus não preparou obra alguma para o seu povo"},
                    {"id": "d", "text": "A criação nova acontece fora de Cristo Jesus"},
                ],
                "correct": "a",
            },
            {
                "n": "04",
                "type": "order",
                "question": "Qual sequência mostra a ordem dos fatos em Efésios 2:10?",
                "fc": "Certo: feitura, criação em Cristo e obras preparadas.",
                "fw": {
                    "b": "A criação em Cristo vem depois de feitura dele.",
                    "c": "As obras preparadas fecham o versículo.",
                },
                "options": [
                    {"id": "a", "text": "Pois somos feitura dele"},
                    {"id": "b", "text": "criados em Cristo Jesus para boas obras"},
                    {"id": "c", "text": "as quais Deus, antes, preparou para que andássemos nelas"},
                ],
            },
            {
                "n": "05",
                "type": "complete",
                "question": 'Complete: "Pois somos feitura dele, criados em Cristo Jesus para boas ___, as quais Deus, antes, preparou"',
                "fc": 'Certo: o alvo da nova criação são "boas obras".',
                "fw": {
                    "b": "Feitura já apareceu no início.",
                    "c": "Cristo nomeia o âmbito, não esta lacuna.",
                },
                "template": "Pois somos feitura dele, criados em Cristo Jesus para boas ___, as quais Deus, antes, preparou",
                "options": [
                    {"id": "a", "text": "obras"},
                    {"id": "b", "text": "feitura"},
                    {"id": "c", "text": "Cristo"},
                ],
                "correct": "a",
            },
            {
                "n": "06",
                "type": "connect",
                "question": "O que Efésios 2:10 comunica que se liga a este contexto?",
                "fc": "Certo: a nova humanidade é feitura de Deus em Cristo.",
                "fw": {
                    "b": "O texto não descreve autoformação humana.",
                    "c": "As obras são preparadas para o andar, não o contrário.",
                },
                "passageA": {"ref": "Efésios 2:10", "text": TB_EF},
                "passageB": {"ref": "Contexto", "text": INS3},
                "options": [
                    {"id": "a", "text": "Feitura de Deus em Cristo"},
                    {"id": "b", "text": "Humanidade que se recria sozinha"},
                    {"id": "c", "text": "Obras que preparam a Deus"},
                ],
                "correct": "a",
            },
        ],
        "caminhada": [
            {
                "n": "01",
                "type": "true_false",
                "question": "Em Efésios 2:10, as boas obras são a causa da criação em Cristo, não o caminho preparado por Deus.",
                "fc": "Certo: as obras foram preparadas para o andar, não para criar.",
                "fw": {
                    "true": "O texto diz criados para obras que Deus, antes, preparou."
                },
                "options": TF,
                "correct": "false",
            },
            {
                "n": "02",
                "type": "tap",
                "question": 'Em Efésios 2:10, toque a palavra que falta em "criados em Cristo Jesus para boas obras, as quais Deus, antes, ___ para que andássemos nelas"?',
                "fc": 'Exato: Deus "preparou" as obras de antemão.',
                "fw": {
                    "b": "Andássemos descreve o viver, não o ato de Deus.",
                    "c": "Obras é o objeto preparado, não o verbo.",
                },
                "template": "criados em Cristo Jesus para boas obras, as quais Deus, antes, ___ para que andássemos nelas",
                "options": [
                    {"id": "a", "text": "preparou"},
                    {"id": "b", "text": "andássemos"},
                    {"id": "c", "text": "obras"},
                ],
                "correct": "a",
            },
            {
                "n": "03",
                "type": "choice",
                "question": "Como Efésios 2:10 relaciona nova criação e boas obras?",
                "fc": "Certo: as obras são o caminho preparado, não o motor da criação.",
                "fw": {
                    "a": "O texto coloca as obras depois da criação em Cristo.",
                    "c": "Deus preparou as obras; o crente não as inventa sozinho.",
                    "d": "A nova criação não dispensa o andar nas obras.",
                },
                "options": [
                    {"id": "a", "text": "As obras produzem a nova criação em Cristo"},
                    {"id": "b", "text": "A nova criação destina o crente a obras que Deus preparou"},
                    {"id": "c", "text": "O crente inventa as obras, e Deus apenas observa"},
                    {"id": "d", "text": "Criados em Cristo, os crentes não precisam de obras"},
                ],
                "correct": "b",
            },
            {
                "n": "04",
                "type": "order",
                "question": "Como se encadeiam os eventos de Efésios 2:10?",
                "fc": "Certo: criação em Cristo, obras e o andar nelas.",
                "fw": {
                    "b": "As obras vêm como finalidade, não no início.",
                    "c": "O andar nas obras é o desfecho preparado.",
                },
                "options": [
                    {"id": "a", "text": "criados em Cristo Jesus"},
                    {"id": "b", "text": "para boas obras"},
                    {"id": "c", "text": "as quais Deus, antes, preparou para que andássemos nelas"},
                ],
            },
            {
                "n": "05",
                "type": "complete",
                "question": 'Complete: "as quais Deus, antes, preparou para que ___ nelas"',
                "fc": 'Certo: o alvo é "andássemos" nas obras preparadas.',
                "fw": {
                    "b": "Preparou é o verbo de Deus, não esta lacuna.",
                    "c": "Antes marca o tempo da preparação, não o andar.",
                },
                "template": "as quais Deus, antes, preparou para que ___ nelas",
                "options": [
                    {"id": "a", "text": "andássemos"},
                    {"id": "b", "text": "preparou"},
                    {"id": "c", "text": "antes"},
                ],
                "correct": "a",
            },
            {
                "n": "06",
                "type": "connect",
                "question": "O que Efésios 2:10 comunica que se liga a este contexto?",
                "fc": "Certo: a nova humanidade anda em obras já preparadas.",
                "fw": {
                    "b": "O texto não ensina salvação comprada por obras.",
                    "c": "A preparação é de Deus, não improvisação humana.",
                },
                "passageA": {"ref": "Efésios 2:10", "text": TB_EF},
                "passageB": {"ref": "Contexto", "text": INS3},
                "options": [
                    {"id": "a", "text": "Obras preparadas para o andar"},
                    {"id": "b", "text": "Obras que compram a salvação"},
                    {"id": "c", "text": "Caminho improvisado pelo crente"},
                ],
                "correct": "a",
            },
        ],
        "profundezas": [
            {
                "n": "01",
                "type": "true_false",
                "question": "Efésios 2:10 apresenta a nova humanidade como obra de Deus em Cristo, destinada a um caminho de obras já preparado.",
                "fc": "Certo: a restauração é feitura divina com vocação prática.",
                "fw": {
                    "false": "O texto une feitura em Cristo e obras preparadas de antemão."
                },
                "options": TF,
                "correct": "true",
            },
            {
                "n": "02",
                "type": "tap",
                "question": 'Em Efésios 2:10, toque a palavra que falta em "Pois somos feitura dele, ___ em Cristo Jesus para boas obras"?',
                "fc": 'Exato: "criados" nomeia a nova criação em Cristo.',
                "fw": {
                    "b": "Feitura já apareceu; a lacuna é o verbo seguinte.",
                    "c": "Jesus é o nome, não o verbo desta lacuna.",
                },
                "template": "Pois somos feitura dele, ___ em Cristo Jesus para boas obras",
                "options": [
                    {"id": "a", "text": "criados"},
                    {"id": "b", "text": "feitura"},
                    {"id": "c", "text": "Jesus"},
                ],
                "correct": "a",
            },
            {
                "n": "03",
                "type": "choice",
                "question": "Que leitura teológica Efésios 2:10 sustenta sobre a nova humanidade?",
                "fc": "Certo: Deus recria em Cristo e prepara o caminho das obras.",
                "fw": {
                    "a": "O texto não ensina autotransformação independente.",
                    "c": "As obras não antecedem a criação em Cristo.",
                    "d": "A nova criação não é só ideia; destina ao andar.",
                },
                "options": [
                    {"id": "a", "text": "O homem se recria sozinho e depois pede a Deus um plano"},
                    {"id": "b", "text": "Deus recria o seu povo em Cristo e prepara o seu andar"},
                    {"id": "c", "text": "As obras vêm primeiro e, então, Cristo cria o homem"},
                    {"id": "d", "text": "A nova criação é só uma ideia, sem vocação prática"},
                ],
                "correct": "b",
            },
            {
                "n": "04",
                "type": "order",
                "question": "Qual sequência revela o sentido de Efésios 2:10?",
                "fc": "Certo: identidade, destino em Cristo e obras preparadas.",
                "fw": {
                    "b": "A criação em Cristo segue a identidade de feitura.",
                    "c": "As obras preparadas são o desfecho do sentido.",
                },
                "options": [
                    {"id": "a", "text": "somos feitura dele"},
                    {"id": "b", "text": "criados em Cristo Jesus"},
                    {"id": "c", "text": "boas obras que Deus, antes, preparou"},
                ],
            },
            {
                "n": "05",
                "type": "complete",
                "question": 'Complete: "Pois somos feitura dele, criados em ___ Jesus para boas obras"',
                "fc": "Certo: a nova criação é em Cristo Jesus.",
                "fw": {
                    "b": "Deus prepara as obras, mas a lacuna é Cristo.",
                    "c": "Obras é o alvo, não o nome desta lacuna.",
                },
                "template": "Pois somos feitura dele, criados em ___ Jesus para boas obras",
                "options": [
                    {"id": "a", "text": "Cristo"},
                    {"id": "b", "text": "Deus"},
                    {"id": "c", "text": "obras"},
                ],
                "correct": "a",
            },
            {
                "n": "06",
                "type": "connect",
                "question": "O que Efésios 2:10 comunica que se liga a este contexto?",
                "fc": "Certo: restauração em Cristo com vocação de obras.",
                "fw": {
                    "b": "O texto não descreve retorno à autonomia pecaminosa.",
                    "c": "A vocação não é vazia: há obras preparadas.",
                },
                "passageA": {"ref": "Efésios 2:10", "text": TB_EF},
                "passageB": {"ref": "Contexto", "text": INS3},
                "options": [
                    {"id": "a", "text": "Restauração com vocação em Cristo"},
                    {"id": "b", "text": "Retorno à autonomia do pecado"},
                    {"id": "c", "text": "Identidade nova sem qualquer vocação"},
                ],
                "correct": "a",
            },
        ],
    },
)

# ── M4 an-boss ───────────────────────────────────────────────────
LO4 = "Relacionar imagem, queda e nova criação em Cristo como o arco da antropologia bíblica."
EV4 = ["Gênesis 1:27", "Romanos 3:23", "Efésios 2:10"]
VR4 = "Gênesis 1:27; Romanos 3:23; Efésios 2:10"
INS4 = "Criados e restaurados: imagem, queda e nova criação em Cristo."
TB_GEN27 = "Criou, pois, Deus o homem à sua imagem, à imagem de Deus o criou; homem e mulher os criou."

m4 = mission(
    "an-boss",
    VR4,
    LO4,
    EV4,
    TB_BOSS,
    {
        "semente": [
            {
                "n": "01",
                "type": "true_false",
                "question": "Deus criou o homem à sua imagem; todos pecaram e necessitam da glória; somos feitura dele em Cristo.",
                "fc": "Certo: os três textos formam esse arco.",
                "fw": {
                    "false": "Gênesis, Romanos e Efésios afirmam imagem, queda e nova criação."
                },
                "options": TF,
                "correct": "true",
            },
            {
                "n": "02",
                "type": "tap",
                "question": 'Em Gênesis 1:27, toque a palavra que falta em "Criou, pois, Deus o homem à sua ___, à imagem de Deus o criou"?',
                "fc": "Exato: a primeira afirmação do arco é a imagem.",
                "fw": {
                    "b": "Homem é quem é criado, não esta lacuna.",
                    "c": "Mulher aparece no fim do versículo.",
                },
                "template": "Criou, pois, Deus o homem à sua ___, à imagem de Deus o criou",
                "options": [
                    {"id": "a", "text": "imagem"},
                    {"id": "b", "text": "homem"},
                    {"id": "c", "text": "mulher"},
                ],
                "correct": "a",
            },
            {
                "n": "03",
                "type": "choice",
                "question": "Qual conjunto de fatos os três textos afirmam juntos?",
                "fc": "Certo: imagem, pecado universal e feitura em Cristo.",
                "fw": {
                    "b": "Romanos 3:23 não isenta ninguém do pecado.",
                    "c": "Efésios 2:10 situa a nova criação em Cristo.",
                    "d": "Gênesis 1:27 inclui homem e mulher na imagem.",
                },
                "options": [
                    {"id": "a", "text": "Imagem de Deus, pecado de todos e criação nova em Cristo"},
                    {"id": "b", "text": "Imagem de Deus e inocência preservada em todos"},
                    {"id": "c", "text": "Queda sem restauração e humanidade sem Cristo"},
                    {"id": "d", "text": "Só o homem, não a mulher, foi feito à imagem de Deus"},
                ],
                "correct": "a",
            },
            {
                "n": "04",
                "type": "order",
                "question": "Qual sequência mostra a ordem dos fatos em Gênesis 1:27; Romanos 3:23; Efésios 2:10?",
                "fc": "Certo: imagem, queda e nova criação em Cristo.",
                "fw": {
                    "b": "O pecado vem depois da criação à imagem.",
                    "c": "A feitura em Cristo é o desfecho, não o início.",
                },
                "options": [
                    {"id": "a", "text": "Criou, pois, Deus o homem à sua imagem"},
                    {"id": "b", "text": "todos pecaram e necessitam da glória de Deus"},
                    {"id": "c", "text": "somos feitura dele, criados em Cristo Jesus"},
                ],
            },
            {
                "n": "05",
                "type": "complete",
                "question": 'Complete: "porque todos pecaram e necessitam da ___ de Deus"',
                "fc": "Certo: a queda se mede pela falta da glória.",
                "fw": {
                    "b": "Imagem pertence a Gênesis, não a esta lacuna.",
                    "c": "Feitura pertence a Efésios, não a Romanos 3:23.",
                },
                "template": "porque todos pecaram e necessitam da ___ de Deus",
                "options": [
                    {"id": "a", "text": "glória"},
                    {"id": "b", "text": "imagem"},
                    {"id": "c", "text": "feitura"},
                ],
                "correct": "a",
            },
            {
                "n": "06",
                "type": "connect",
                "question": "O que Gênesis 1:27; Romanos 3:23; Efésios 2:10 comunicam que se liga a este contexto?",
                "fc": "Certo: o arco une imagem, queda e restauração.",
                "fw": {
                    "b": "Os textos não param na imagem sem a queda.",
                    "c": "A restauração em Cristo não é omitida.",
                },
                "passageA": {"ref": "Gênesis 1:27; Romanos 3:23; Efésios 2:10", "text": f"{TB_GEN27} {TB_ROM} {TB_EF}"},
                "passageB": {"ref": "Contexto", "text": INS4},
                "options": [
                    {"id": "a", "text": "Imagem, queda e nova criação"},
                    {"id": "b", "text": "Só imagem, sem qualquer queda"},
                    {"id": "c", "text": "Queda sem restauração em Cristo"},
                ],
                "correct": "a",
            },
        ],
        "caminhada": [
            {
                "n": "01",
                "type": "true_false",
                "question": "A criação à imagem, em Gênesis 1:27, cancela Romanos 3:23 e torna desnecessária a nova criação de Efésios 2:10.",
                "fc": "Certo: imagem, queda e restauração se encadeiam, não se anulam.",
                "fw": {
                    "true": "A imagem não anula a queda; Efésios mostra a restauração em Cristo."
                },
                "options": TF,
                "correct": "false",
            },
            {
                "n": "02",
                "type": "tap",
                "question": 'Em Romanos 3:23, toque a palavra que falta em "porque ___ pecaram e necessitam da glória de Deus"?',
                "fc": 'Exato: "todos" liga a queda a toda a humanidade.',
                "fw": {
                    "b": "Pecaram é o verbo, não o sujeito desta lacuna.",
                    "c": "Glória é o que falta depois.",
                },
                "template": "porque ___ pecaram e necessitam da glória de Deus",
                "options": [
                    {"id": "a", "text": "todos"},
                    {"id": "b", "text": "pecaram"},
                    {"id": "c", "text": "glória"},
                ],
                "correct": "a",
            },
            {
                "n": "03",
                "type": "choice",
                "question": "Como se encadeiam imagem, pecado e nova criação nestes textos?",
                "fc": "Certo: a queda não apaga a imagem; Cristo restaura para obras.",
                "fw": {
                    "a": "Romanos não apaga Gênesis; os une à necessidade da glória.",
                    "c": "Efésios não ignora a queda; recria em Cristo.",
                    "d": "A nova criação não dispensa a vocação das obras.",
                },
                "options": [
                    {"id": "a", "text": "O pecado apaga de vez a imagem, sem resto de dignidade"},
                    {"id": "b", "text": "A imagem é real, a queda é universal e Cristo recria para obras"},
                    {"id": "c", "text": "A nova criação ignora o pecado e volta ao Éden sem cruz"},
                    {"id": "d", "text": "Em Cristo a humanidade se recria para não fazer obra alguma"},
                ],
                "correct": "b",
            },
            {
                "n": "04",
                "type": "order",
                "question": "Como se encadeiam os eventos de Gênesis 1:27; Romanos 3:23; Efésios 2:10?",
                "fc": "Certo: homem e mulher, pecado de todos e obras em Cristo.",
                "fw": {
                    "b": "A queda vem depois da criação de homem e mulher.",
                    "c": "As obras em Cristo fecham o arco.",
                },
                "options": [
                    {"id": "a", "text": "homem e mulher os criou"},
                    {"id": "b", "text": "todos pecaram"},
                    {"id": "c", "text": "criados em Cristo Jesus para boas obras"},
                ],
            },
            {
                "n": "05",
                "type": "complete",
                "question": 'Complete: "Pois somos feitura dele, criados em Cristo Jesus para boas obras, as quais Deus, antes, ___"',
                "fc": "Certo: Deus preparou as obras da nova humanidade.",
                "fw": {
                    "b": "Pecaram pertence a Romanos, não a esta lacuna.",
                    "c": "Criou pertence a Gênesis, não a Efésios 2:10.",
                },
                "template": "Pois somos feitura dele, criados em Cristo Jesus para boas obras, as quais Deus, antes, ___",
                "options": [
                    {"id": "a", "text": "preparou"},
                    {"id": "b", "text": "pecaram"},
                    {"id": "c", "text": "Criou"},
                ],
                "correct": "a",
            },
            {
                "n": "06",
                "type": "connect",
                "question": "O que estes três textos comunicam que se liga a este contexto?",
                "fc": "Certo: dignidade, pecado e restauração formam um só arco.",
                "fw": {
                    "b": "A queda não descarta a dignidade da imagem.",
                    "c": "A restauração em Cristo não é um anexo opcional.",
                },
                "passageA": {"ref": "Gênesis 1:27; Romanos 3:23; Efésios 2:10", "text": f"{TB_GEN27} {TB_ROM} {TB_EF}"},
                "passageB": {"ref": "Contexto", "text": INS4},
                "options": [
                    {"id": "a", "text": "Dignidade, pecado e restauração"},
                    {"id": "b", "text": "Dignidade apagada pela queda"},
                    {"id": "c", "text": "Restauração como detalhe opcional"},
                ],
                "correct": "a",
            },
        ],
        "profundezas": [
            {
                "n": "01",
                "type": "true_false",
                "question": "A antropologia destes textos une dignidade da imagem, universalidade da queda e restauração como feitura de Deus em Cristo.",
                "fc": "Certo: nenhum dos três eixos pode ser isolado.",
                "fw": {
                    "false": "Os três textos juntos sustentam imagem, queda e nova criação."
                },
                "options": TF,
                "correct": "true",
            },
            {
                "n": "02",
                "type": "tap",
                "question": 'Em Efésios 2:10, toque a palavra que falta em "Pois somos ___ dele, criados em Cristo Jesus para boas obras"?',
                "fc": 'Exato: "feitura" nomeia a restauração como obra de Deus.',
                "fw": {
                    "b": "Cristo é o âmbito, não esta lacuna.",
                    "c": "Obras é o alvo, não o que somos.",
                },
                "template": "Pois somos ___ dele, criados em Cristo Jesus para boas obras",
                "options": [
                    {"id": "a", "text": "feitura"},
                    {"id": "b", "text": "Cristo"},
                    {"id": "c", "text": "obras"},
                ],
                "correct": "a",
            },
            {
                "n": "03",
                "type": "choice",
                "question": "Que erro teológico estes três textos, juntos, impedem?",
                "fc": "Certo: não se separa imagem, queda e restauração em Cristo.",
                "fw": {
                    "a": "Gênesis não ensina dignidade sem criatura sob Deus.",
                    "c": "Efésios não ensina auto-redenção por obras.",
                    "d": "Romanos não permite otimismo que ignore o pecado.",
                },
                "options": [
                    {"id": "a", "text": "O homem é divino e não precisa de restauração"},
                    {"id": "b", "text": "Criados à imagem, caídos e refeitos em Cristo para obras"},
                    {"id": "c", "text": "As obras humanas recriam o homem sem Cristo"},
                    {"id": "d", "text": "A queda é ilusão; a humanidade nunca necessitou da glória"},
                ],
                "correct": "b",
            },
            {
                "n": "04",
                "type": "order",
                "question": "Qual sequência revela o sentido de Gênesis 1:27; Romanos 3:23; Efésios 2:10?",
                "fc": "Certo: imagem, falta da glória e andar nas obras.",
                "fw": {
                    "b": "A falta da glória vem depois da imagem.",
                    "c": "O andar nas obras é o sentido da nova criação.",
                },
                "options": [
                    {"id": "a", "text": "à imagem de Deus o criou"},
                    {"id": "b", "text": "necessitam da glória de Deus"},
                    {"id": "c", "text": "andássemos nelas"},
                ],
            },
            {
                "n": "05",
                "type": "complete",
                "question": 'Complete: "Criou, pois, Deus o homem à sua imagem, à imagem de Deus o criou; homem e ___ os criou"',
                "fc": "Certo: a imagem inclui homem e mulher.",
                "fw": {
                    "b": "Glória pertence a Romanos 3:23.",
                    "c": "Obras pertence a Efésios 2:10.",
                },
                "template": "Criou, pois, Deus o homem à sua imagem, à imagem de Deus o criou; homem e ___ os criou",
                "options": [
                    {"id": "a", "text": "mulher"},
                    {"id": "b", "text": "glória"},
                    {"id": "c", "text": "obras"},
                ],
                "correct": "a",
            },
            {
                "n": "06",
                "type": "connect",
                "question": "O que estes textos comunicam que se liga a este contexto?",
                "fc": "Certo: o ser humano é criado, caído e restaurado em Cristo.",
                "fw": {
                    "b": "O arco não termina na autonomia do pecador.",
                    "c": "A restauração não apaga a vocação das obras.",
                },
                "passageA": {"ref": "Gênesis 1:27; Romanos 3:23; Efésios 2:10", "text": f"{TB_GEN27} {TB_ROM} {TB_EF}"},
                "passageB": {"ref": "Contexto", "text": INS4},
                "options": [
                    {"id": "a", "text": "Criados, caídos e restaurados"},
                    {"id": "b", "text": "Autonomia final do pecador"},
                    {"id": "c", "text": "Restauração sem vocação alguma"},
                ],
                "correct": "a",
            },
        ],
    },
)

# Boss tap/complete: distractors must exist in passageText (TB_BOSS).
# "feitura" is in Eph; "imagem" in Gen; "glória" in Rom — good.
# Boss cam complete option "Criou" — word_in_passage is case-insensitive, "Criou" is in Gen. Good.
# Boss semente complete: imagem and feitura are in TB_BOSS. Good.
# Boss pro complete: mulher, glória, obras all in TB_BOSS.

bank = m1 + m2 + m3 + m4
assert len(bank) == 72, len(bank)

out = Path("/Users/dalwesleyduarte/dev/new/perguntas-v2/antropologia.json")
out.write_text(json.dumps(bank, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {out} ({len(bank)} questions)")
