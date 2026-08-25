#!/usr/bin/env python3
"""Gera perguntas-v2/mateus.json — 5 missões × 18 = 90."""
import json
from pathlib import Path

TRAIL = "mateus"
OUT = Path(__file__).resolve().parent / "mateus.json"

TF_OPTS = [
    {"id": "true", "text": "Verdadeiro"},
    {"id": "false", "text": "Falso"},
]
SHORT = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}
SKILL = {"semente": "observe", "caminhada": "understand", "profundezas": "interpret"}

P1 = (
    "Ela dará à luz um filho, a quem chamarás JESUS, porque ele salvará "
    "o seu povo dos pecados deles. Ora, tudo isto aconteceu, para que se "
    "cumprisse o que dissera o Senhor pelo profeta: Eis que a virgem conceberá "
    "e dará à luz um filho, e ele será chamado Emanuel, que quer dizer Deus conosco."
)
P2 = (
    "Bem-aventurados os humildes de espírito, porque deles é o reino dos céus. "
    "Bem-aventurados os que choram, porque eles serão consolados. "
    "Bem-aventurados os mansos, porque eles herdarão a terra. "
    "Bem-aventurados os que têm fome e sede de justiça, porque eles serão fartos."
)
P3 = (
    "Ele lhes disse: Por que temeis, homens de pouca fé? Então, erguendo-se, "
    "repreendeu os ventos e o mar; e fez-se grande bonança. Todos se maravilharam, "
    "dizendo: Que homem é este que até os ventos e o mar lhe obedecem?"
)
P4 = (
    "Jesus, aproximando-se, disse-lhes: Foi-me dado todo o poder no céu e na terra. "
    "Ide, pois, e fazei discípulos de todas as nações, batizando-as em o nome do Pai, "
    "e do Filho, e do Espírito Santo; instruindo-as a observar todas as coisas que vos "
    "tenho mandado. Eis que eu estou convosco todos os dias até o fim do mundo."
)
P5 = (
    "Ela dará à luz um filho, a quem chamarás JESUS, porque ele salvará "
    "o seu povo dos pecados deles. Jesus, aproximando-se, disse-lhes: "
    "Foi-me dado todo o poder no céu e na terra."
)


def opts(*pairs):
    return [{"id": i, "text": t} for i, t in pairs]


def make(
    section,
    verse_ref,
    evidence,
    lo,
    passage,
    difficulty,
    typ,
    nn,
    question,
    feedback_correct,
    feedback_wrong,
    options,
    correct,
    *,
    template=None,
    correct_order=None,
    passage_a=None,
    passage_b=None,
):
    q = {
        "difficulty": difficulty,
        "skill": SKILL[difficulty],
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
        "trail": TRAIL,
        "section": section,
        "id": f"{TRAIL}-{SHORT[difficulty]}-{section}-{nn}",
    }
    if template:
        q["template"] = template
    if correct_order:
        q["correctOrder"] = correct_order
    if passage_a:
        q["passageA"] = passage_a
    if passage_b:
        q["passageB"] = passage_b
    assert len(feedback_correct) <= 100, (len(feedback_correct), feedback_correct)
    return q


def pack(section, vref, evid, lo, passage, insight, rows):
    out = []
    for difficulty, typ, nn, kwargs in rows:
        pa = None
        pb = None
        if typ == "connect":
            pa = {"ref": vref, "text": kwargs.pop("pa_text", passage)}
            pb = {"ref": "Contexto", "text": insight}
        out.append(
            make(
                section,
                vref,
                evid,
                lo,
                passage,
                difficulty,
                typ,
                nn,
                **kwargs,
                passage_a=pa,
                passage_b=pb,
            )
        )
    return out


def mission_1():
    sec = "mt-01-rei-prometido"
    vref = "Mateus 1:21–23"
    evid = ["Mateus 1:21", "Mateus 1:22", "Mateus 1:23"]
    lo = "Reconhecer que o filho se chama Jesus porque salva do pecado, e Emanuel — Deus conosco."
    ins = "O Rei prometido é Jesus que salva do pecado e Emanuel — Deus conosco."
    p = P1
    return pack(
        sec,
        vref,
        evid,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="O filho se chamará JESUS, porque ele salvará o seu povo dos pecados deles.",
                    feedback_correct="Certo: o nome Jesus está ligado a salvar do pecado.",
                    feedback_wrong={"false": "Releia Mateus 1:21: o nome explica a salvação."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 1:21–23, toque a palavra que falta em "a quem chamarás ___, porque ele salvará o seu povo dos pecados deles"?',
                    feedback_correct="Exato: o nome anunciado é JESUS.",
                    feedback_wrong={
                        "b": "Emanuel aparece depois, na citação do profeta.",
                        "c": "Virgem pertence à profecia, não a esta lacuna.",
                    },
                    options=opts(("a", "JESUS"), ("b", "Emanuel"), ("c", "virgem")),
                    correct="a",
                    template="a quem chamarás ___, porque ele salvará o seu povo dos pecados deles",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que o texto afirma diretamente sobre o nome JESUS?",
                    feedback_correct="Certo: o nome explica que ele salvará dos pecados.",
                    feedback_wrong={
                        "b": "O texto liga o nome à salvação dos pecados, não à fama.",
                        "c": "Emanuel é o outro nome, na citação profética.",
                        "d": "O texto não diz que o povo escolherá o nome.",
                    },
                    options=opts(
                        ("a", "Chamar-se-á assim porque salvará o povo dos pecados."),
                        ("b", "O nome serve só para tornar o menino famoso."),
                        ("c", "JESUS, no texto, quer dizer Deus conosco."),
                        ("d", "O povo é quem escolherá o nome depois do nascimento."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Mateus 1:21–23?",
                    feedback_correct="Certo: nascimento, nome Jesus e Emanuel nessa ordem.",
                    feedback_wrong={
                        "b": "O nome Jesus vem junto do anúncio do filho.",
                        "c": "Emanuel fecha a citação do profeta.",
                    },
                    options=opts(
                        ("a", "Ela dará à luz um filho, a quem chamarás JESUS"),
                        ("b", "porque ele salvará o seu povo dos pecados deles"),
                        ("c", "ele será chamado Emanuel, que quer dizer Deus conosco"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "semente",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "ele será chamado ___, que quer dizer Deus conosco"',
                    feedback_correct="Certo: o nome da profecia é Emanuel.",
                    feedback_wrong={
                        "b": "JESUS é o nome do versículo 21, não desta lacuna.",
                        "c": "Virgem descreve quem concebe, não o nome do filho.",
                    },
                    options=opts(("a", "Emanuel"), ("b", "JESUS"), ("c", "virgem")),
                    correct="a",
                    template="ele será chamado ___, que quer dizer Deus conosco",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 1:21–23 comunica que se liga a este contexto?",
                    feedback_correct="Certo: Jesus salva do pecado e é Deus conosco.",
                    feedback_wrong={
                        "b": "O texto une salvação e presença, não só o nome isolado.",
                        "c": "Emanuel quer dizer Deus conosco, não ausência divina.",
                    },
                    options=opts(
                        ("a", "Jesus salva e é Emanuel"),
                        ("b", "O nome não explica a missão"),
                        ("c", "Deus permanece longe do povo"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="O nome Emanuel, segundo o texto, quer dizer o povo sem pecados.",
                    feedback_correct="Certo: Emanuel quer dizer Deus conosco, não isso.",
                    feedback_wrong={"true": "Mateus 1:23 traduz Emanuel: Deus conosco."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 1:21–23, toque a palavra que falta em "tudo isto aconteceu, para que se ___ o que dissera o Senhor pelo profeta"?',
                    feedback_correct="Exato: tudo aconteceu para que se cumprisse.",
                    feedback_wrong={
                        "b": "Conceberá pertence à citação, não a esta lacuna.",
                        "c": "Salvará explica o nome Jesus, não este verbo.",
                    },
                    options=opts(("a", "cumprisse"), ("b", "conceberá"), ("c", "salvará")),
                    correct="a",
                    template="tudo isto aconteceu, para que se ___ o que dissera o Senhor pelo profeta",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como Mateus 1:21–23 relaciona o nome Jesus e a citação do profeta?",
                    feedback_correct="Certo: o nascimento cumpre a palavra e revela Emanuel.",
                    feedback_wrong={
                        "a": "O texto diz que tudo aconteceu para cumprir o que o Senhor dissera.",
                        "c": "Emanuel explica presença, não substitui a salvação dos pecados.",
                        "d": "Há dois nomes com sentidos distintos e unidos no mesmo menino.",
                    },
                    options=opts(
                        ("a", "O nascimento é acaso, sem ligação com o profeta."),
                        ("b", "O menino cumpre a palavra: salva do pecado e é Deus conosco."),
                        ("c", "A citação anula o sentido do nome Jesus."),
                        ("d", "Jesus e Emanuel são dois meninos diferentes no texto."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Mateus 1:21–23?",
                    feedback_correct="Certo: anúncio, cumprimento e nome Emanuel.",
                    feedback_wrong={
                        "b": "O cumprimento explica por que tudo aconteceu.",
                        "c": "A citação do profeta vem depois do anúncio do nome.",
                    },
                    options=opts(
                        ("a", "o anúncio do filho chamado JESUS que salvará dos pecados"),
                        ("b", "tudo isto aconteceu para que se cumprisse o dito do Senhor"),
                        ("c", "a virgem conceberá e o filho será chamado Emanuel"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "caminhada",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "Eis que a ___ conceberá e dará à luz um filho"',
                    feedback_correct="Certo: a citação fala da virgem.",
                    feedback_wrong={
                        "b": "Profeta é quem falou, não quem concebe.",
                        "c": "Povo é quem será salvo, não esta lacuna.",
                    },
                    options=opts(("a", "virgem"), ("b", "profeta"), ("c", "povo")),
                    correct="a",
                    template="Eis que a ___ conceberá e dará à luz um filho",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 1:21–23 comunica que se liga a este contexto?",
                    feedback_correct="Certo: salvação do pecado e presença de Deus se unem.",
                    feedback_wrong={
                        "b": "O cumprimento não é detalhe extra: explica o acontecido.",
                        "c": "O texto não reduz Jesus a um título vazio.",
                    },
                    options=opts(
                        ("a", "Salvação e Deus conosco"),
                        ("b", "Cumprimento sem propósito"),
                        ("c", "Nome sem missão anunciada"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="O cumprimento da profecia apresenta o menino como Emanuel, isto é, Deus conosco.",
                    feedback_correct="Certo: Emanuel interpreta a presença de Deus no filho.",
                    feedback_wrong={"false": "Mateus 1:23 traduz Emanuel como Deus conosco."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 1:21–23, toque a palavra que falta em "ele salvará o seu povo dos ___ deles"?',
                    feedback_correct="Exato: a salvação é dos pecados.",
                    feedback_wrong={
                        "b": "Povo é quem é salvo, não o que se tira.",
                        "c": "Filho nomeia quem nasce, não esta lacuna.",
                    },
                    options=opts(("a", "pecados"), ("b", "povo"), ("c", "filho")),
                    correct="a",
                    template="ele salvará o seu povo dos ___ deles",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve entender sobre o Rei prometido em Mateus 1:21–23?",
                    feedback_correct="Certo: ele salva do pecado e é a presença de Deus.",
                    feedback_wrong={
                        "a": "O texto une salvação e Emanuel, não um nome sem conteúdo.",
                        "c": "Emanuel afirma Deus conosco, não distância sagrada.",
                        "d": "A salvação anunciada é dos pecados, não só de inimigos políticos.",
                    },
                    options=opts(
                        ("a", "O nome é só etiqueta, sem ligação com pecados ou presença."),
                        ("b", "O Rei salva do pecado e habita como Deus conosco."),
                        ("c", "Emanuel significa que Deus permanece longe do povo."),
                        ("d", "Jesus salva apenas de ameaças políticas, não dos pecados."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Mateus 1:21–23?",
                    feedback_correct="Certo: salvar, cumprir e Deus conosco.",
                    feedback_wrong={
                        "b": "O cumprimento liga o nascimento à palavra do Senhor.",
                        "c": "Emanuel interpreta quem é o menino para o leitor.",
                    },
                    options=opts(
                        ("a", "o nome Jesus aponta para salvar o povo dos pecados"),
                        ("b", "o nascimento cumpre o que o Senhor dissera pelo profeta"),
                        ("c", "Emanuel declara que esse filho é Deus conosco"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "profundezas",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "Emanuel, que quer dizer Deus ___"',
                    feedback_correct="Certo: Emanuel quer dizer Deus conosco.",
                    feedback_wrong={
                        "b": "Pecados pertence ao sentido do nome Jesus.",
                        "c": "Senhor é quem falou pelo profeta, não esta tradução.",
                    },
                    options=opts(("a", "conosco"), ("b", "pecados"), ("c", "Senhor")),
                    correct="a",
                    template="Emanuel, que quer dizer Deus ___",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 1:21–23 comunica que se liga a este contexto?",
                    feedback_correct="Certo: o Rei prometido salva e está conosco.",
                    feedback_wrong={
                        "b": "O texto não trata o menino como rei distante do pecado.",
                        "c": "Emanuel afirma presença, não ausência.",
                    },
                    options=opts(
                        ("a", "Rei que salva e habita"),
                        ("b", "Rei alheio aos pecados"),
                        ("c", "Deus ausente da história"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_2():
    sec = "mt-02-reino-ensino"
    vref = "Mateus 5:3–6"
    evid = ["Mateus 5:3", "Mateus 5:4", "Mateus 5:5", "Mateus 5:6"]
    lo = "Perceber que o Reino declara bem-aventurados os humildes, os que choram, os mansos e os que têm fome de justiça."
    ins = "O ensino do Reino inverte valores: humildes, os que choram, mansos e os que têm fome de justiça."
    p = P2
    return pack(
        sec,
        vref,
        evid,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Bem-aventurados os humildes de espírito, porque deles é o reino dos céus.",
                    feedback_correct="Certo: essa é a primeira bem-aventurança do trecho.",
                    feedback_wrong={"false": "Releia Mateus 5:3: o reino é dos humildes de espírito."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:3–6, toque a palavra que falta em "Bem-aventurados os ___ de espírito, porque deles é o reino dos céus"?',
                    feedback_correct="Exato: os humildes de espírito.",
                    feedback_wrong={
                        "b": "Mansos herdam a terra, não esta frase.",
                        "c": "Consolados é a promessa aos que choram.",
                    },
                    options=opts(("a", "humildes"), ("b", "mansos"), ("c", "consolados")),
                    correct="a",
                    template="Bem-aventurados os ___ de espírito, porque deles é o reino dos céus",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="Segundo o texto, de quem é o reino dos céus?",
                    feedback_correct="Certo: o reino é dos humildes de espírito.",
                    feedback_wrong={
                        "b": "Os mansos herdam a terra, não esta frase.",
                        "c": "Os que choram serão consolados.",
                        "d": "Fartos é a promessa aos que têm fome de justiça.",
                    },
                    options=opts(
                        ("a", "Dos humildes de espírito."),
                        ("b", "Somente dos mansos, neste versículo."),
                        ("c", "Dos que choram, neste versículo."),
                        ("d", "Dos que já foram fartos de justiça."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Mateus 5:3–6?",
                    feedback_correct="Certo: humildes, os que choram e os mansos.",
                    feedback_wrong={
                        "b": "Os que choram vêm depois dos humildes de espírito.",
                        "c": "Os mansos vêm depois dos que choram.",
                    },
                    options=opts(
                        ("a", "Bem-aventurados os humildes de espírito"),
                        ("b", "Bem-aventurados os que choram"),
                        ("c", "Bem-aventurados os mansos"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "semente",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "Bem-aventurados os mansos, porque eles herdarão a ___"',
                    feedback_correct="Certo: os mansos herdarão a terra.",
                    feedback_wrong={
                        "b": "Céus fecha a frase dos humildes de espírito.",
                        "c": "Justiça pertence à fome e sede, não a esta lacuna.",
                    },
                    options=opts(("a", "terra"), ("b", "céus"), ("c", "justiça")),
                    correct="a",
                    template="Bem-aventurados os mansos, porque eles herdarão a ___",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:3–6 comunica que se liga a este contexto?",
                    feedback_correct="Certo: o Reino inverte o critério de felicidade.",
                    feedback_wrong={
                        "b": "O texto abençoa humildes e mansos, não os arrogantes.",
                        "c": "Há promessa de consolo e fartura, não desprezo da justiça.",
                    },
                    options=opts(
                        ("a", "O Reino inverte valores"),
                        ("b", "Só os arrogantes são felizes"),
                        ("c", "Justiça não tem lugar no Reino"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Os que choram são chamados bem-aventurados porque já foram fartos de justiça.",
                    feedback_correct="Certo: aos que choram o texto promete consolo, não essa frase.",
                    feedback_wrong={"true": "Mateus 5:4 promete consolo; a fartura é de 5:6."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:3–6, toque a palavra que falta em "os que têm fome e sede de ___, porque eles serão fartos"?',
                    feedback_correct="Exato: a fome e a sede são de justiça.",
                    feedback_wrong={
                        "b": "Espírito qualifica os humildes, não esta lacuna.",
                        "c": "Terra é a herança dos mansos.",
                    },
                    options=opts(("a", "justiça"), ("b", "espírito"), ("c", "terra")),
                    correct="a",
                    template="os que têm fome e sede de ___, porque eles serão fartos",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como as bem-aventuranças de Mateus 5:3–6 se encadeiam no ensino do Reino?",
                    feedback_correct="Certo: o Reino honra os que o mundo costuma ignorar.",
                    feedback_wrong={
                        "a": "O texto não reserva o Reino só aos já poderosos.",
                        "c": "Consolo e fartura são promessas, não negações.",
                        "d": "Mansidão herda a terra; não é tratada como fraqueza inútil.",
                    },
                    options=opts(
                        ("a", "Só quem já domina recebe o reino dos céus."),
                        ("b", "Humildes, os que choram e os mansos são chamados felizes."),
                        ("c", "Os que choram ficam sem promessa de consolo."),
                        ("d", "Os mansos são excluídos de qualquer herança."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Mateus 5:3–6?",
                    feedback_correct="Certo: reino, consolo e herança da terra.",
                    feedback_wrong={
                        "b": "O consolo vem na segunda bem-aventurança.",
                        "c": "A herança da terra segue a bem-aventurança dos mansos.",
                    },
                    options=opts(
                        ("a", "deles é o reino dos céus"),
                        ("b", "eles serão consolados"),
                        ("c", "eles herdarão a terra"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "caminhada",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "Bem-aventurados os que choram, porque eles serão ___"',
                    feedback_correct="Certo: os que choram serão consolados.",
                    feedback_wrong={
                        "b": "Fartos é a promessa de quem tem fome de justiça.",
                        "c": "Humildes descreve outro grupo, não esta lacuna.",
                    },
                    options=opts(("a", "consolados"), ("b", "fartos"), ("c", "humildes")),
                    correct="a",
                    template="Bem-aventurados os que choram, porque eles serão ___",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:3–6 comunica que se liga a este contexto?",
                    feedback_correct="Certo: o ensino abençoa os que o mundo desvaloriza.",
                    feedback_wrong={
                        "b": "O texto não exige riqueza para a bem-aventurança.",
                        "c": "Há fome de justiça, não desprezo dela.",
                    },
                    options=opts(
                        ("a", "Felizes os que o mundo esquece"),
                        ("b", "Felizes só os já ricos"),
                        ("c", "Justiça fica fora do Reino"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="A bem-aventurança dos que têm fome e sede de justiça promete que eles serão fartos.",
                    feedback_correct="Certo: a fome de justiça não fica sem resposta.",
                    feedback_wrong={"false": "Mateus 5:6 promete que eles serão fartos."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:3–6, toque a palavra que falta em "Bem-aventurados os ___, porque eles herdarão a terra"?',
                    feedback_correct="Exato: os mansos herdarão a terra.",
                    feedback_wrong={
                        "b": "Humildes recebem o reino dos céus nesta lista.",
                        "c": "Choram é o verbo da segunda bem-aventurança.",
                    },
                    options=opts(("a", "mansos"), ("b", "humildes"), ("c", "choram")),
                    correct="a",
                    template="Bem-aventurados os ___, porque eles herdarão a terra",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o ensino do Reino revela sobre justiça e felicidade em Mateus 5:3–6?",
                    feedback_correct="Certo: fome de justiça é bem-aventurança, não fraqueza.",
                    feedback_wrong={
                        "a": "O texto chama de bem-aventurados os que têm fome de justiça.",
                        "c": "O choro recebe consolo, não desprezo do Reino.",
                        "d": "Humildade de espírito recebe o reino, não o exclui.",
                    },
                    options=opts(
                        ("a", "Fome de justiça é defeito que o Reino rejeita."),
                        ("b", "Desejar justiça é bem-aventurança que será saciada."),
                        ("c", "Quem chora fica fora de qualquer promessa."),
                        ("d", "Humildes de espírito não têm parte no reino dos céus."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Mateus 5:3–6?",
                    feedback_correct="Certo: reino, consolo e fartura de justiça.",
                    feedback_wrong={
                        "b": "O consolo interpreta o choro, não o anula.",
                        "c": "A fartura responde à fome e sede de justiça.",
                    },
                    options=opts(
                        ("a", "os humildes de espírito recebem o reino dos céus"),
                        ("b", "os que choram serão consolados"),
                        ("c", "os que têm fome de justiça serão fartos"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "profundezas",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "os que têm fome e sede de justiça, porque eles serão ___"',
                    feedback_correct="Certo: eles serão fartos.",
                    feedback_wrong={
                        "b": "Consolados é a promessa aos que choram.",
                        "c": "Mansos nomeia outro grupo, não esta lacuna.",
                    },
                    options=opts(("a", "fartos"), ("b", "consolados"), ("c", "mansos")),
                    correct="a",
                    template="os que têm fome e sede de justiça, porque eles serão ___",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:3–6 comunica que se liga a este contexto?",
                    feedback_correct="Certo: o Rei ensina outro critério de felicidade.",
                    feedback_wrong={
                        "b": "O texto não copia a lógica da força bruta.",
                        "c": "Há herança e fartura prometidas, não vazio.",
                    },
                    options=opts(
                        ("a", "Outro critério de felicidade"),
                        ("b", "Felizes só os violentos"),
                        ("c", "O Reino não promete nada"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_3():
    sec = "mt-03-autoridade"
    vref = "Mateus 8:26–27"
    evid = ["Mateus 8:26", "Mateus 8:27"]
    lo = "Ver que Jesus liga o temor à pouca fé e acalma ventos e mar, que lhe obedecem."
    ins = "Autoridade do Rei: ventos e mar obedecem — fé pequena encontra Senhor grande."
    p = P3
    return pack(
        sec,
        vref,
        evid,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Erguendo-se, Jesus repreendeu os ventos e o mar, e fez-se grande bonança.",
                    feedback_correct="Certo: o texto relata a repreensão e a bonança.",
                    feedback_wrong={"false": "Mateus 8:26 registra exatamente essa ação."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 8:26–27, toque a palavra que falta em "repreendeu os ventos e o ___; e fez-se grande bonança"?',
                    feedback_correct="Exato: ele repreendeu os ventos e o mar.",
                    feedback_wrong={
                        "b": "Ventos já está na frase, antes da lacuna.",
                        "c": "Fé aparece no vocativo, não nesta lacuna.",
                    },
                    options=opts(("a", "mar"), ("b", "ventos"), ("c", "fé")),
                    correct="a",
                    template="repreendeu os ventos e o ___; e fez-se grande bonança",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que o texto afirma que aconteceu depois de Jesus se erguer?",
                    feedback_correct="Certo: houve repreensão e grande bonança.",
                    feedback_wrong={
                        "b": "O texto diz que se fez grande bonança, não tempestade maior.",
                        "c": "Ele repreendeu ventos e mar, não ficou em silêncio.",
                        "d": "A bonança vem depois da repreensão, não antes.",
                    },
                    options=opts(
                        ("a", "Repreendeu os ventos e o mar, e fez-se grande bonança."),
                        ("b", "A tempestade aumentou depois que ele se ergueu."),
                        ("c", "Permaneceu sentado, sem falar aos ventos."),
                        ("d", "A bonança já existia antes de qualquer repreensão."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Mateus 8:26–27?",
                    feedback_correct="Certo: pouca fé, repreensão e bonança.",
                    feedback_wrong={
                        "b": "A repreensão vem depois da fala sobre a fé.",
                        "c": "A bonança segue a repreensão aos ventos e ao mar.",
                    },
                    options=opts(
                        ("a", "Ele lhes disse: homens de pouca fé"),
                        ("b", "erguendo-se, repreendeu os ventos e o mar"),
                        ("c", "fez-se grande bonança"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "semente",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "e fez-se grande ___"',
                    feedback_correct="Certo: fez-se grande bonança.",
                    feedback_wrong={
                        "b": "Fé aparece no vocativo anterior, não nesta lacuna.",
                        "c": "Ventos é o que ele repreende, não o resultado.",
                    },
                    options=opts(("a", "bonança"), ("b", "fé"), ("c", "ventos")),
                    correct="a",
                    template="e fez-se grande ___",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 8:26–27 comunica que se liga a este contexto?",
                    feedback_correct="Certo: ventos e mar obedecem ao Rei.",
                    feedback_wrong={
                        "b": "O texto mostra obediência da criação, não recusa.",
                        "c": "Há bonança depois da repreensão, não caos permanente.",
                    },
                    options=opts(
                        ("a", "Ventos e mar lhe obedecem"),
                        ("b", "A criação ignora o Rei"),
                        ("c", "Não houve nenhuma bonança"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Depois da repreensão, os discípulos afirmaram que o mar não obedece a Jesus.",
                    feedback_correct="Certo: eles se maravilham porque ventos e mar obedecem.",
                    feedback_wrong={"true": "Mateus 8:27 diz que até ventos e mar lhe obedecem."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 8:26–27, toque a palavra que falta em "homens de pouca ___"?',
                    feedback_correct="Exato: ele os chama homens de pouca fé.",
                    feedback_wrong={
                        "b": "Bonança é o resultado, não esta lacuna.",
                        "c": "Mar é o que ele repreende.",
                    },
                    options=opts(("a", "fé"), ("b", "bonança"), ("c", "mar")),
                    correct="a",
                    template="homens de pouca ___",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o relato une o temor dos discípulos e a ação de Jesus?",
                    feedback_correct="Certo: o temor é tratado como pouca fé, depois vem a bonança.",
                    feedback_wrong={
                        "a": "Jesus fala da pouca fé antes de repreender ventos e mar.",
                        "c": "A maravilha reconhece obediência, não acaso.",
                        "d": "Há repreensão e bonança, não recusa de agir.",
                    },
                    options=opts(
                        ("a", "O temor não tem relação com a fé no texto."),
                        ("b", "O temor é nomeado como pouca fé, e então o mar se acalma."),
                        ("c", "A bonança é coincidência, sem ligação com Jesus."),
                        ("d", "Jesus recusa agir diante do medo dos discípulos."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Mateus 8:26–27?",
                    feedback_correct="Certo: fé pequena, repreensão e maravilha.",
                    feedback_wrong={
                        "b": "A repreensão segue a fala sobre o temor.",
                        "c": "A maravilha vem depois da bonança.",
                    },
                    options=opts(
                        ("a", "Jesus trata os discípulos como homens de pouca fé"),
                        ("b", "repreendeu os ventos e o mar"),
                        ("c", "todos se maravilharam diante da obediência da criação"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "caminhada",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "Todos se ___, dizendo"',
                    feedback_correct="Certo: todos se maravilharam.",
                    feedback_wrong={
                        "b": "Repreendeu é a ação de Jesus, não dos discípulos aqui.",
                        "c": "Temeis pertence à fala anterior de Jesus.",
                    },
                    options=opts(("a", "maravilharam"), ("b", "repreendeu"), ("c", "temeis")),
                    correct="a",
                    template="Todos se ___, dizendo",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 8:26–27 comunica que se liga a este contexto?",
                    feedback_correct="Certo: fé pequena encontra um Senhor grande.",
                    feedback_wrong={
                        "b": "O texto não elogia o medo como fé madura.",
                        "c": "A criação obedece; não ignora o Rei.",
                    },
                    options=opts(
                        ("a", "Fé pequena, Senhor grande"),
                        ("b", "Medo igual a fé madura"),
                        ("c", "O mar não reconhece o Rei"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="A maravilha dos discípulos reconhece que até os ventos e o mar obedecem a Jesus.",
                    feedback_correct="Certo: a pergunta deles confessa essa obediência.",
                    feedback_wrong={"false": "Mateus 8:27 afirma que ventos e mar lhe obedecem."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 8:26–27, toque a palavra que falta em "Que homem é este que até os ventos e o mar lhe ___?"?',
                    feedback_correct="Exato: ventos e mar lhe obedecem.",
                    feedback_wrong={
                        "b": "Repreendeu descreve a ação de Jesus, não esta lacuna.",
                        "c": "Erguendo-se descreve o gesto, não o verbo dos discípulos.",
                    },
                    options=opts(("a", "obedecem"), ("b", "repreendeu"), ("c", "Erguendo-se")),
                    correct="a",
                    template="Que homem é este que até os ventos e o mar lhe ___?",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que a cena revela sobre a autoridade do Rei em Mateus 8:26–27?",
                    feedback_correct="Certo: a criação obedece; a fé pequena encontra Senhor grande.",
                    feedback_wrong={
                        "a": "A bonança segue a palavra de Jesus, não o acaso.",
                        "c": "Ele repreende a criação; não pede licença ao mar.",
                        "d": "O texto liga temor e pouca fé, não trata o medo como fé plena.",
                    },
                    options=opts(
                        ("a", "A bonança prova que o mar se acalma sozinho, sem o Rei."),
                        ("b", "Ventos e mar obedecem; o temor dos discípulos é pouca fé."),
                        ("c", "Jesus depende do mar para obter permissão de agir."),
                        ("d", "O medo dos discípulos é apresentado como fé completa."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Mateus 8:26–27?",
                    feedback_correct="Certo: pouca fé, autoridade e confissão da criação.",
                    feedback_wrong={
                        "b": "A autoridade se mostra na repreensão que traz bonança.",
                        "c": "A pergunta final confessa quem é esse homem.",
                    },
                    options=opts(
                        ("a", "o temor dos discípulos é tratado como pouca fé"),
                        ("b", "o Rei repreende ventos e mar e faz-se bonança"),
                        ("c", "os discípulos reconhecem que a criação lhe obedece"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "profundezas",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "erguendo-se, ___ os ventos e o mar"',
                    feedback_correct="Certo: ele repreendeu os ventos e o mar.",
                    feedback_wrong={
                        "b": "Maravilharam é a reação dos discípulos.",
                        "c": "Obedecem é o verbo da criação, não desta lacuna.",
                    },
                    options=opts(("a", "repreendeu"), ("b", "maravilharam"), ("c", "obedecem")),
                    correct="a",
                    template="erguendo-se, ___ os ventos e o mar",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 8:26–27 comunica que se liga a este contexto?",
                    feedback_correct="Certo: a autoridade do Rei alcança a criação.",
                    feedback_wrong={
                        "b": "O texto não limita Jesus a conselhos sem poder.",
                        "c": "Há Senhor grande, não abandono no medo.",
                    },
                    options=opts(
                        ("a", "Autoridade sobre a criação"),
                        ("b", "Mestre sem poder algum"),
                        ("c", "Discípulos abandonados ao medo"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_4():
    sec = "mt-04-cruz-vitoria"
    vref = "Mateus 28:18–20"
    evid = ["Mateus 28:18", "Mateus 28:19", "Mateus 28:20"]
    lo = "Compreender que ao ressuscitado foi dado todo o poder, e ele envia discípulos permanecendo com eles."
    ins = "Cruz e vitória: todo poder foi dado ao ressuscitado, que envia discípulos e permanece."
    p = P4
    return pack(
        sec,
        vref,
        evid,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Foi dado a Jesus todo o poder no céu e na terra.",
                    feedback_correct="Certo: ele declara que lhe foi dado todo o poder.",
                    feedback_wrong={"false": "Mateus 28:18 afirma: foi-me dado todo o poder."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 28:18–20, toque a palavra que falta em "Foi-me dado todo o ___ no céu e na terra"?',
                    feedback_correct="Exato: foi-lhe dado todo o poder.",
                    feedback_wrong={
                        "b": "Céu é o lugar do poder, não o substantivo desta lacuna.",
                        "c": "Mundo fecha a promessa final, não esta frase.",
                    },
                    options=opts(("a", "poder"), ("b", "céu"), ("c", "mundo")),
                    correct="a",
                    template="Foi-me dado todo o ___ no céu e na terra",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que Jesus manda os discípulos fazerem em Mateus 28:18–20?",
                    feedback_correct="Certo: fazer discípulos de todas as nações.",
                    feedback_wrong={
                        "b": "O envio é a todas as nações, não a uma só.",
                        "c": "Há batismo e ensino, não só espera passiva.",
                        "d": "O poder já lhe foi dado; o texto não diz o contrário.",
                    },
                    options=opts(
                        ("a", "Fazer discípulos de todas as nações, batizando e instruindo."),
                        ("b", "Ficar numa só nação, sem batizar ninguém."),
                        ("c", "Esperar em silêncio, sem ensinar o que ele mandou."),
                        ("d", "Negar que algum poder lhe tenha sido dado."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Mateus 28:18–20?",
                    feedback_correct="Certo: poder, envio e presença até o fim.",
                    feedback_wrong={
                        "b": "O envio vem depois da declaração do poder.",
                        "c": "A presença prometida fecha o mandato.",
                    },
                    options=opts(
                        ("a", "Foi-me dado todo o poder no céu e na terra"),
                        ("b", "Ide, pois, e fazei discípulos de todas as nações"),
                        ("c", "eu estou convosco todos os dias até o fim do mundo"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "semente",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "eu estou convosco todos os dias até o fim do ___"',
                    feedback_correct="Certo: até o fim do mundo.",
                    feedback_wrong={
                        "b": "Céu pertence à declaração do poder.",
                        "c": "Pai aparece na fórmula batismal.",
                    },
                    options=opts(("a", "mundo"), ("b", "céu"), ("c", "Pai")),
                    correct="a",
                    template="eu estou convosco todos os dias até o fim do ___",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 28:18–20 comunica que se liga a este contexto?",
                    feedback_correct="Certo: o ressuscitado envia e permanece.",
                    feedback_wrong={
                        "b": "Há envio explícito, não retiro da missão.",
                        "c": "Ele promete estar convosco, não ausência.",
                    },
                    options=opts(
                        ("a", "Envia e permanece convosco"),
                        ("b", "Recusa qualquer envio"),
                        ("c", "Promete ausentar-se para sempre"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="O envio limita os discípulos a uma só nação, sem batismo nem ensino.",
                    feedback_correct="Certo: o mandato é a todas as nações, batizando e instruindo.",
                    feedback_wrong={"true": "Mateus 28:19–20 fala de todas as nações e de ensinar."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 28:18–20, toque a palavra que falta em "fazei ___ de todas as nações"?',
                    feedback_correct="Exato: o mandato é fazer discípulos.",
                    feedback_wrong={
                        "b": "Nações é o alcance, não o objeto desta lacuna.",
                        "c": "Poder já foi declarado no versículo 18.",
                    },
                    options=opts(("a", "discípulos"), ("b", "nações"), ("c", "poder")),
                    correct="a",
                    template="fazei ___ de todas as nações",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o poder declarado em Mateus 28:18 se liga ao envio?",
                    feedback_correct="Certo: o poder dado fundamenta o ide.",
                    feedback_wrong={
                        "a": "O texto une 'foi-me dado' e 'ide, pois'.",
                        "c": "Há batismo no nome triúno, não recusa de batizar.",
                        "d": "Instruir a observar o mandado faz parte da missão.",
                    },
                    options=opts(
                        ("a", "O poder declarado não tem relação com o ide."),
                        ("b", "Porque lhe foi dado todo o poder, os discípulos são enviados."),
                        ("c", "O batismo é proibido no mandato final."),
                        ("d", "Ensinar o que ele mandou fica fora da missão."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Mateus 28:18–20?",
                    feedback_correct="Certo: poder, batismo e ensino do mandado.",
                    feedback_wrong={
                        "b": "O batismo segue o fazer discípulos.",
                        "c": "A instrução acompanha o batismo.",
                    },
                    options=opts(
                        ("a", "todo o poder no céu e na terra lhe foi dado"),
                        ("b", "batizando-as em o nome do Pai, e do Filho, e do Espírito Santo"),
                        ("c", "instruindo-as a observar todas as coisas que vos tenho mandado"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "caminhada",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "batizando-as em o nome do Pai, e do Filho, e do ___ Santo"',
                    feedback_correct="Certo: o nome inclui o Espírito Santo.",
                    feedback_wrong={
                        "b": "Mundo fecha a promessa de presença, não esta fórmula.",
                        "c": "Terra pertence à declaração do poder.",
                    },
                    options=opts(("a", "Espírito"), ("b", "mundo"), ("c", "terra")),
                    correct="a",
                    template="batizando-as em o nome do Pai, e do Filho, e do ___ Santo",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 28:18–20 comunica que se liga a este contexto?",
                    feedback_correct="Certo: poder, envio e presença caminham juntos.",
                    feedback_wrong={
                        "b": "O mandato não é poder sem missão.",
                        "c": "Ele permanece; não some após enviar.",
                    },
                    options=opts(
                        ("a", "Poder, envio e presença"),
                        ("b", "Poder sem nenhum envio"),
                        ("c", "Envio sem a presença dele"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="A presença prometida por Jesus dura todos os dias até o fim do mundo.",
                    feedback_correct="Certo: ele promete estar convosco até o fim.",
                    feedback_wrong={"false": "Mateus 28:20 diz: todos os dias até o fim do mundo."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 28:18–20, toque a palavra que falta em "instruindo-as a ___ todas as coisas que vos tenho mandado"?',
                    feedback_correct="Exato: instruir a observar o que ele mandou.",
                    feedback_wrong={
                        "b": "Mandado já fecha a frase, não esta lacuna.",
                        "c": "Batizando descreve o rito anterior.",
                    },
                    options=opts(("a", "observar"), ("b", "mandado"), ("c", "batizando-as")),
                    correct="a",
                    template="instruindo-as a ___ todas as coisas que vos tenho mandado",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que a vitória do ressuscitado implica para a missão em Mateus 28:18–20?",
                    feedback_correct="Certo: autoridade universal, envio e permanência.",
                    feedback_wrong={
                        "a": "O texto afirma que lhe foi dado todo o poder.",
                        "c": "Ele promete estar convosco, não substituir-se por ausência.",
                        "d": "O alcance é todas as nações, não um recuo da missão.",
                    },
                    options=opts(
                        ("a", "O ressuscitado declara não ter poder no céu nem na terra."),
                        ("b", "Todo o poder funda o envio, e ele permanece com os discípulos."),
                        ("c", "Os discípulos substituem Jesus, que deixa de estar com eles."),
                        ("d", "A vitória cancela o envio às nações."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Mateus 28:18–20?",
                    feedback_correct="Certo: autoridade, missão e permanência.",
                    feedback_wrong={
                        "b": "A missão às nações flui do poder dado.",
                        "c": "A presença até o fim sustenta quem é enviado.",
                    },
                    options=opts(
                        ("a", "ao ressuscitado foi dado todo o poder no céu e na terra"),
                        ("b", "os discípulos são enviados a fazer discípulos das nações"),
                        ("c", "Jesus permanece convosco até o fim do mundo"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "profundezas",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "Eis que eu estou ___ todos os dias até o fim do mundo"',
                    feedback_correct="Certo: eu estou convosco.",
                    feedback_wrong={
                        "b": "Nações é o alcance da missão, não esta lacuna.",
                        "c": "Poder já foi declarado no início.",
                    },
                    options=opts(("a", "convosco"), ("b", "nações"), ("c", "poder")),
                    correct="a",
                    template="Eis que eu estou ___ todos os dias até o fim do mundo",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 28:18–20 comunica que se liga a este contexto?",
                    feedback_correct="Certo: poder dado e presença até o fim.",
                    feedback_wrong={
                        "b": "A cruz desemboca em envio, não em silêncio.",
                        "c": "Há permanência prometida, não abandono.",
                    },
                    options=opts(
                        ("a", "Poder dado e presença"),
                        ("b", "Vitória sem nenhum envio"),
                        ("c", "Ressuscitado que se ausenta"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_5():
    sec = "mt-boss-revisao"
    vref = "Mateus 1:21; 28:18"
    evid = ["Mateus 1:21", "Mateus 28:18"]
    lo = "Unir o nome Jesus que salva do pecado com o poder dado ao ressuscitado."
    ins = "O Rei e seu Reino: Jesus salva do pecado e envia com todo o poder."
    p = P5
    return pack(
        sec,
        vref,
        evid,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Jesus salvará o seu povo dos pecados deles, e lhe foi dado todo o poder no céu e na terra.",
                    feedback_correct="Certo: os dois textos unem salvação e poder.",
                    feedback_wrong={"false": "Mateus 1:21 e 28:18 afirmam salvação e poder."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 1:21; 28:18, toque a palavra que falta em "a quem chamarás ___, porque ele salvará o seu povo dos pecados deles"?',
                    feedback_correct="Exato: o nome é JESUS.",
                    feedback_wrong={
                        "b": "Poder pertence a Mateus 28:18, não a esta lacuna.",
                        "c": "Povo é quem será salvo, não o nome.",
                    },
                    options=opts(("a", "JESUS"), ("b", "poder"), ("c", "povo")),
                    correct="a",
                    template="a quem chamarás ___, porque ele salvará o seu povo dos pecados deles",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que os dois trechos afirmam juntos sobre Jesus?",
                    feedback_correct="Certo: ele salva dos pecados e recebeu todo o poder.",
                    feedback_wrong={
                        "b": "Mateus 1:21 liga o nome à salvação dos pecados.",
                        "c": "Mateus 28:18 afirma que o poder lhe foi dado.",
                        "d": "Os textos não dizem que o poder ficou com outro.",
                    },
                    options=opts(
                        ("a", "Salva o povo dos pecados e recebeu todo o poder."),
                        ("b", "O nome Jesus não se liga a pecados."),
                        ("c", "Nenhum poder lhe foi dado no céu nem na terra."),
                        ("d", "O poder no céu ficou com os discípulos, não com ele."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Mateus 1:21; 28:18?",
                    feedback_correct="Certo: nome, salvação e poder dado.",
                    feedback_wrong={
                        "b": "A salvação explica o nome Jesus.",
                        "c": "O poder dado fecha o arco do ressuscitado.",
                    },
                    options=opts(
                        ("a", "Ela dará à luz um filho, a quem chamarás JESUS"),
                        ("b", "ele salvará o seu povo dos pecados deles"),
                        ("c", "Foi-me dado todo o poder no céu e na terra"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "semente",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "Foi-me dado todo o ___ no céu e na terra"',
                    feedback_correct="Certo: todo o poder lhe foi dado.",
                    feedback_wrong={
                        "b": "JESUS é o nome de 1:21, não esta lacuna.",
                        "c": "Pecados explica a salvação, não o substantivo do poder.",
                    },
                    options=opts(("a", "poder"), ("b", "JESUS"), ("c", "pecados")),
                    correct="a",
                    template="Foi-me dado todo o ___ no céu e na terra",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 1:21; 28:18 comunica que se liga a este contexto?",
                    feedback_correct="Certo: Jesus salva do pecado e tem todo o poder.",
                    feedback_wrong={
                        "b": "O arco une salvação e autoridade, não as separa.",
                        "c": "Há poder declarado, não esvaziamento do Rei.",
                    },
                    options=opts(
                        ("a", "Salva e tem todo o poder"),
                        ("b", "Salva, mas sem autoridade"),
                        ("c", "Poder sem salvação do pecado"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Mateus 28:18 afirma que nenhum poder foi dado a Jesus no céu.",
                    feedback_correct="Certo: o texto diz que lhe foi dado todo o poder.",
                    feedback_wrong={"true": "Mateus 28:18: foi-me dado todo o poder no céu e na terra."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 1:21; 28:18, toque a palavra que falta em "ele salvará o seu povo dos ___ deles"?',
                    feedback_correct="Exato: a salvação é dos pecados.",
                    feedback_wrong={
                        "b": "Céu pertence à declaração do poder.",
                        "c": "Terra fecha o par céu e terra.",
                    },
                    options=opts(("a", "pecados"), ("b", "céu"), ("c", "terra")),
                    correct="a",
                    template="ele salvará o seu povo dos ___ deles",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o nascimento anunciado e a palavra do ressuscitado se relacionam?",
                    feedback_correct="Certo: quem salva do pecado é quem recebeu todo o poder.",
                    feedback_wrong={
                        "a": "Os dois textos falam do mesmo Jesus, não de rivais.",
                        "c": "O poder no céu e na terra lhe foi dado, não recusado.",
                        "d": "O nome Jesus explica salvação dos pecados, não a anula.",
                    },
                    options=opts(
                        ("a", "São dois cristos distintos, sem relação entre si."),
                        ("b", "O que salva dos pecados é o mesmo a quem foi dado todo o poder."),
                        ("c", "O ressuscitado recusa qualquer poder no céu."),
                        ("d", "Salvar dos pecados contradiz o nome Jesus."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Mateus 1:21; 28:18?",
                    feedback_correct="Certo: salvação anunciada, aproximação e poder dado.",
                    feedback_wrong={
                        "b": "A aproximação introduz a declaração do ressuscitado.",
                        "c": "O poder no céu e na terra fecha a declaração.",
                    },
                    options=opts(
                        ("a", "o filho chamado JESUS salvará o povo dos pecados"),
                        ("b", "Jesus, aproximando-se, disse-lhes"),
                        ("c", "foi-me dado todo o poder no céu e na terra"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "caminhada",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "todo o poder no céu e na ___"',
                    feedback_correct="Certo: no céu e na terra.",
                    feedback_wrong={
                        "b": "Pecados pertence a Mateus 1:21.",
                        "c": "Povo é quem será salvo.",
                    },
                    options=opts(("a", "terra"), ("b", "pecados"), ("c", "povo")),
                    correct="a",
                    template="todo o poder no céu e na ___",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 1:21; 28:18 comunica que se liga a este contexto?",
                    feedback_correct="Certo: o Rei que salva também governa.",
                    feedback_wrong={
                        "b": "Há poder no céu e na terra, não só no berço.",
                        "c": "A salvação dos pecados não some no envio.",
                    },
                    options=opts(
                        ("a", "O Rei que salva governa"),
                        ("b", "Rei só no nascimento"),
                        ("c", "Poder sem povo salvo"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="O mesmo Jesus que salva do pecado declara ter recebido todo o poder no céu e na terra.",
                    feedback_correct="Certo: salvação e autoridade pertencem ao mesmo Rei.",
                    feedback_wrong={"false": "Os dois versos falam do mesmo Jesus."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 1:21; 28:18, toque a palavra que falta em "Foi-me dado todo o poder no ___ e na terra"?',
                    feedback_correct="Exato: o poder é no céu e na terra.",
                    feedback_wrong={
                        "b": "Filho é quem nasce em 1:21, não esta lacuna.",
                        "c": "Pecados explica a salvação, não o par céu e terra.",
                    },
                    options=opts(("a", "céu"), ("b", "filho"), ("c", "pecados")),
                    correct="a",
                    template="Foi-me dado todo o poder no ___ e na terra",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o arco de Mateus 1:21 e 28:18 ensina sobre o Reino?",
                    feedback_correct="Certo: graça que salva e autoridade que envia se unem.",
                    feedback_wrong={
                        "a": "O poder dado não cancela a salvação dos pecados.",
                        "c": "O nome Jesus explica salvação, não a substitui por fama.",
                        "d": "O texto afirma poder no céu e na terra, não recuo do Rei.",
                    },
                    options=opts(
                        ("a", "O poder do ressuscitado torna inútil salvar dos pecados."),
                        ("b", "O Rei salva do pecado e governa com todo o poder."),
                        ("c", "Jesus é só um nome, sem salvação nem autoridade."),
                        ("d", "O Reino fica só na terra, sem poder no céu."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Mateus 1:21; 28:18?",
                    feedback_correct="Certo: salvar, receber poder e unir graça e autoridade.",
                    feedback_wrong={
                        "b": "O poder dado interpreta a vitória do mesmo Jesus.",
                        "c": "O Reino une as duas afirmações.",
                    },
                    options=opts(
                        ("a", "o nome Jesus anuncia salvação dos pecados"),
                        ("b", "ao ressuscitado foi dado todo o poder no céu e na terra"),
                        ("c", "o Reino une graça que salva e autoridade que envia"),
                    ),
                    correct="a",
                    correct_order=["a", "b", "c"],
                ),
            ),
            (
                "profundezas",
                "complete",
                "05",
                dict(
                    question='Complete a frase: "ele salvará o seu ___ dos pecados deles"',
                    feedback_correct="Certo: ele salvará o seu povo.",
                    feedback_wrong={
                        "b": "Poder pertence a 28:18.",
                        "c": "Céu pertence ao par céu e terra.",
                    },
                    options=opts(("a", "povo"), ("b", "poder"), ("c", "céu")),
                    correct="a",
                    template="ele salvará o seu ___ dos pecados deles",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 1:21; 28:18 comunica que se liga a este contexto?",
                    feedback_correct="Certo: Jesus salva e envia com todo o poder.",
                    feedback_wrong={
                        "b": "Há salvação anunciada, não só mando sem graça.",
                        "c": "Há poder para enviar, não Rei impotente.",
                    },
                    options=opts(
                        ("a", "Salva e envia com poder"),
                        ("b", "Envia sem salvar do pecado"),
                        ("c", "Salva, mas sem poder algum"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def main():
    bank = mission_1() + mission_2() + mission_3() + mission_4() + mission_5()
    assert len(bank) == 90, len(bank)
    OUT.write_text(json.dumps(bank, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUT} ({len(bank)} questions)")


if __name__ == "__main__":
    main()
