#!/usr/bin/env python3
"""Gera perguntas-v2/genesis-1-11.json — 14 missões × 18 = 252."""
import json
from pathlib import Path

OUT = Path(__file__).with_name("genesis-1-11.json")
TRAIL = "genesis-1-11"


def q(
    section,
    diff,
    skill,
    typ,
    nn,
    verse_ref,
    lo,
    evidence,
    question,
    feedback_correct,
    feedback_wrong,
    options,
    correct,
    passage,
    **extra,
):
    short = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}[diff]
    item = {
        "difficulty": diff,
        "skill": skill,
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
        "id": f"{TRAIL}-{short}-{section}-{nn}",
    }
    item.update(extra)
    assert len(feedback_correct) <= 100, (len(feedback_correct), feedback_correct)
    if typ == "choice":
        for o in options:
            assert len(o["text"]) <= 90, (o["text"], len(o["text"]))
    return item


def tf():
    return [{"id": "true", "text": "Verdadeiro"}, {"id": "false", "text": "Falso"}]


def opts(*pairs):
    return [{"id": i, "text": t} for i, t in pairs]


def add_mission(bank, section, verse, lo, evidence, passage, items, passage_by_diff=None):
    for spec in items:
        extra = {}
        for k in ("template", "correctOrder", "passageA", "passageB"):
            if k in spec:
                extra[k] = spec[k]
        p = passage
        if passage_by_diff:
            p = passage_by_diff.get(spec["diff"], passage)
        bank.append(
            q(
                section,
                spec["diff"],
                spec["skill"],
                spec["type"],
                spec["nn"],
                verse,
                lo,
                evidence,
                spec["question"],
                spec["ok"],
                spec["wrong"],
                spec["options"],
                spec["correct"],
                p,
                **extra,
            )
        )


bank = []

# =============================================================================
# M1 gen-01-criador | Gênesis 1:1–2
# =============================================================================
P1 = (
    "No princípio, criou Deus o céu e a terra. A terra, porém, era sem forma e vazia; "
    "havia trevas sobre a face do abismo, mas o Espírito de Deus pairava por cima das águas."
)
LO1 = "Reconhecer que no princípio Deus cria o céu e a terra, e o Espírito paira sobre o abismo."
add_mission(
    bank,
    "gen-01-criador",
    "Gênesis 1:1–2",
    LO1,
    ["Gênesis 1:1–2"],
    P1,
    [
        # SEMENTE
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="No princípio, criou Deus o céu e a terra.",
            ok="Certo: Gênesis 1:1 afirma exatamente isso.",
            wrong={"false": "O versículo começa com a criação do céu e da terra."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 1:1–2, toque a palavra que falta em "No ___, criou Deus o céu e a terra"?',
            ok="Exato: o texto começa com \"princípio\".",
            wrong={"b": "Céu é o objeto criado, não esta lacuna.", "c": "Terra completa o par criado."},
            options=opts(("a", "princípio"), ("b", "céu"), ("c", "terra")),
            correct="a",
            template="No ___, criou Deus o céu e a terra",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 1:1–2, o que pairava por cima das águas?",
            ok="Certo: o Espírito de Deus pairava sobre as águas.",
            wrong={
                "b": "O texto fala do Espírito, não de um vento humano.",
                "c": "Não há menção de anjos neste trecho.",
                "d": "A terra estava sem forma; não pairava sobre as águas.",
            },
            options=opts(
                ("a", "O Espírito de Deus"),
                ("b", "Um vento gerado pelo homem"),
                ("c", "Um exército de anjos"),
                ("d", "A terra sem forma"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 1:1–2?",
            ok="Certo: criação, terra vazia, Espírito sobre as águas.",
            wrong={"b": "Reordene conforme o fluxo do texto.", "c": "Começa no princípio da criação."},
            options=opts(
                ("a", "criou Deus o céu e a terra"),
                ("b", "a terra era sem forma e vazia"),
                ("c", "o Espírito de Deus pairava por cima das águas"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 1:1–2: "havia ___ sobre a face do abismo".',
            ok="Certo: havia trevas sobre a face do abismo.",
            wrong={"b": "Águas vêm depois; a lacuna é trevas.", "c": "Espírito pairava, não preenche esta lacuna."},
            options=opts(("a", "trevas"), ("b", "águas"), ("c", "Espírito")),
            correct="a",
            template="havia ___ sobre a face do abismo",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 1:1–2 comunica que se liga a este contexto?",
            ok="Certo: Deus cria e o Espírito paira sobre o abismo.",
            wrong={"b": "O texto não descreve abandono.", "c": "Não há recusa de criar neste versículo."},
            options=opts(
                ("a", "Deus cria; Espírito paira"),
                ("b", "O mundo nasce abandonado"),
                ("c", "Deus recusa criar a terra"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:1–2", "text": "No princípio, criou Deus o céu e a terra"},
            passageB={"ref": "Contexto", "text": "No princípio, Deus cria — o Espírito paira sobre o abismo."},
        ),
        # CAMINHADA
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 1:1–2, a terra já aparece ordenada e cheia antes de qualquer ato de Deus.",
            ok="Certo: a terra está sem forma e vazia; Deus é quem cria.",
            wrong={"true": "O texto descreve criação e terra ainda sem forma."},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 1:1–2, toque a palavra que falta em "o Espírito de Deus ___ por cima das águas"?',
            ok="Exato: o Espírito \"pairava\" sobre as águas.",
            wrong={"a": "Trevas estão sobre o abismo, não nesta lacuna.", "c": "Águas são o lugar, não o verbo."},
            options=opts(("a", "trevas"), ("b", "pairava"), ("c", "águas")),
            correct="b",
            template="o Espírito de Deus ___ por cima das águas",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="Como Gênesis 1:1–2 encadeia criação e presença de Deus sobre o caos?",
            ok="Certo: Deus cria, a terra está vazia, e o Espírito paira.",
            wrong={
                "a": "O Espírito não se ausenta; paira sobre as águas.",
                "c": "O texto não diz que a terra cria a si mesma.",
                "d": "Não há menção de homens criando neste trecho.",
            },
            options=opts(
                ("a", "Deus cria e depois o Espírito se ausenta"),
                ("b", "Deus cria; a terra vazia; o Espírito paira"),
                ("c", "A terra ordena o caos antes de Deus agir"),
                ("d", "Homens formam o céu e a terra sozinhos"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 1:1–2?",
            ok="Certo: princípio da criação, terra vazia, Espírito sobre as águas.",
            wrong={"b": "Siga a sequência do versículo.", "c": "O Espírito vem após a descrição da terra."},
            options=opts(
                ("a", "criação no princípio"),
                ("b", "terra sem forma e vazia"),
                ("c", "Espírito pairando sobre as águas"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 1:1–2: "A terra, porém, era sem forma e ___".',
            ok="Certo: a terra era sem forma e vazia.",
            wrong={"b": "Trevas estão sobre o abismo.", "c": "Águas são o lugar do Espírito."},
            options=opts(("a", "vazia"), ("b", "trevas"), ("c", "águas")),
            correct="a",
            template="A terra, porém, era sem forma e ___",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 1:1–2 comunica que se liga a este contexto?",
            ok="Certo: o princípio aponta Deus como Criador ativo.",
            wrong={"b": "O caos não exclui a presença de Deus.", "c": "Não há criação por acaso no texto."},
            options=opts(
                ("a", "Deus inicia e paira no caos"),
                ("b", "O caos exclui qualquer presença"),
                ("c", "A criação ocorre por acaso"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:1–2", "text": "o Espírito de Deus pairava por cima das águas"},
            passageB={"ref": "Contexto", "text": "No princípio, Deus cria — o Espírito paira sobre o abismo."},
        ),
        # PROFUNDEZAS
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 1:1–2 apresenta Deus como aquele que inicia a criação, não como espectador do caos.",
            ok="Certo: Deus cria e o Espírito paira sobre o abismo.",
            wrong={"false": "O texto põe Deus no princípio da criação."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 1:1–2, toque a palavra que falta em "sobre a face do ___, mas o Espírito de Deus pairava"?',
            ok="Exato: o abismo é o cenário sobre o qual o Espírito paira.",
            wrong={"b": "Águas são o lugar do pairar, não esta lacuna.", "c": "Terra já foi nomeada antes."},
            options=opts(("a", "abismo"), ("b", "águas"), ("c", "terra")),
            correct="a",
            template="sobre a face do ___, mas o Espírito de Deus pairava",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que leitura teológica Gênesis 1:1–2 prepara sobre o início de tudo?",
            ok="Certo: Deus é o centro criador; o caos não é absoluto.",
            wrong={
                "a": "O texto não diviniza o caos; Deus cria e paira.",
                "c": "Não há rival eterno igual a Deus neste trecho.",
                "d": "O Espírito não está ausente; paira sobre as águas.",
            },
            options=opts(
                ("a", "O caos é eterno e igual a Deus"),
                ("b", "Deus inicia; o caos não é absoluto"),
                ("c", "Dois deuses disputam o princípio"),
                ("d", "Deus cria e depois se ausenta"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 1:1–2?",
            ok="Certo: Deus cria, o caos aparece, o Espírito paira.",
            wrong={"b": "Ordene pela lógica do texto.", "c": "A presença do Espírito fecha o movimento."},
            options=opts(
                ("a", "Deus cria no princípio"),
                ("b", "a terra vazia e as trevas"),
                ("c", "o Espírito paira sobre as águas"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 1:1–2: "criou ___ o céu e a terra".',
            ok="Certo: Deus é o sujeito da criação.",
            wrong={"b": "Princípio marca o tempo, não o sujeito.", "c": "Espírito paira; Deus cria."},
            options=opts(("a", "Deus"), ("b", "princípio"), ("c", "Espírito")),
            correct="a",
            template="criou ___ o céu e a terra",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 1:1–2 comunica que se liga a este contexto?",
            ok="Certo: o leitor é preparado para um Deus Criador presente.",
            wrong={"b": "Não há indiferença divina no texto.", "c": "O homem não é o criador aqui."},
            options=opts(
                ("a", "Criador presente no princípio"),
                ("b", "Indiferença divina ao caos"),
                ("c", "Homem como criador do céu"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:1–2", "text": "No princípio, criou Deus o céu e a terra"},
            passageB={"ref": "Contexto", "text": "No princípio, Deus cria — o Espírito paira sobre o abismo."},
        ),
    ],
)

# =============================================================================
# M2 gen-02-dias | Gênesis 1:3–5
# =============================================================================
P2 = (
    "Disse Deus: Haja luz; e houve luz. Viu Deus a luz que era boa e fez separação "
    "entre a luz e as trevas. Chamou Deus à luz Dia e às trevas chamou Noite. "
    "Houve tarde e houve manhã, dia primeiro."
)
LO2 = "Ver que a palavra de Deus cria a luz e separa Dia e Noite no primeiro dia."
add_mission(
    bank,
    "gen-02-dias",
    "Gênesis 1:3–5",
    LO2,
    ["Gênesis 1:3–5"],
    P2,
    [
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="Disse Deus: Haja luz; e houve luz.",
            ok="Certo: a palavra de Deus produz a luz.",
            wrong={"false": "Gênesis 1:3 afirma exatamente essa ordem e efeito."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 1:3–5, toque a palavra que falta em "Disse Deus: Haja ___; e houve luz"?',
            ok="Exato: Deus manda haver luz.",
            wrong={"b": "Trevas são separadas depois.", "c": "Noite é o nome das trevas."},
            options=opts(("a", "luz"), ("b", "trevas"), ("c", "Noite")),
            correct="a",
            template="Disse Deus: Haja ___; e houve luz",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 1:3–5, como Deus chamou a luz e as trevas?",
            ok="Certo: luz = Dia; trevas = Noite.",
            wrong={
                "b": "O texto inverte: luz é Dia, trevas são Noite.",
                "c": "Não há manhã/tarde como nomes da luz e trevas.",
                "d": "Céu e terra já foram criados antes.",
            },
            options=opts(
                ("a", "Luz Dia; trevas Noite"),
                ("b", "Luz Noite; trevas Dia"),
                ("c", "Luz Manhã; trevas Tarde"),
                ("d", "Luz Céu; trevas Terra"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 1:3–5?",
            ok="Certo: haja luz, separação, nomes Dia e Noite.",
            wrong={"b": "Siga a ordem do texto.", "c": "Os nomes vêm após a separação."},
            options=opts(
                ("a", "Haja luz; e houve luz"),
                ("b", "fez separação entre a luz e as trevas"),
                ("c", "Chamou Deus à luz Dia e às trevas Noite"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 1:3–5: "Viu Deus a luz que era ___".',
            ok="Certo: Deus viu que a luz era boa.",
            wrong={"b": "Primeiro é o nome do dia, não deste juízo.", "c": "Tarde marca o ritmo do dia."},
            options=opts(("a", "boa"), ("b", "primeiro"), ("c", "tarde")),
            correct="a",
            template="Viu Deus a luz que era ___",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 1:3–5 comunica que se liga a este contexto?",
            ok="Certo: a palavra cria luz e separa Dia e Noite.",
            wrong={"b": "A luz não nasce sozinha; Deus fala.", "c": "Não há recusa de separar."},
            options=opts(
                ("a", "Palavra cria luz e separa"),
                ("b", "A luz surge sem palavra"),
                ("c", "Deus recusa separar trevas"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:3–5", "text": "Disse Deus: Haja luz; e houve luz"},
            passageB={"ref": "Contexto", "text": "Dias: a palavra cria luz e separa Dia e Noite."},
        ),
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 1:3–5, a luz aparece sem qualquer palavra de Deus.",
            ok="Certo: a luz vem depois de \"Disse Deus: Haja luz\".",
            wrong={"true": "O texto liga a luz à palavra de Deus."},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 1:3–5, toque a palavra que falta em "fez ___ entre a luz e as trevas"?',
            ok="Exato: Deus fez separação entre luz e trevas.",
            wrong={"a": "Luz é um dos polos separados.", "c": "Noite é o nome das trevas."},
            options=opts(("a", "luz"), ("b", "separação"), ("c", "Noite")),
            correct="b",
            template="fez ___ entre a luz e as trevas",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="O que a sequência \"disse… houve… viu… chamou\" em Gênesis 1:3–5 mostra?",
            ok="Certo: a palavra produz, avalia e ordena o dia.",
            wrong={
                "a": "Não há acaso; Deus fala e age.",
                "c": "O nome vem depois da criação da luz.",
                "d": "Deus não se ausenta; avalia e nomeia.",
            },
            options=opts(
                ("a", "Que a luz surge por acaso"),
                ("b", "Que a palavra produz, avalia e ordena"),
                ("c", "Que o nome vem antes da luz"),
                ("d", "Que Deus cria e se ausenta"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 1:3–5?",
            ok="Certo: palavra, luz boa, nomes Dia e Noite.",
            wrong={"b": "Reordene pelo fluxo do dia primeiro.", "c": "Os nomes fecham o movimento."},
            options=opts(
                ("a", "Deus diz e a luz existe"),
                ("b", "Deus vê que a luz é boa"),
                ("c", "Deus nomeia Dia e Noite"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 1:3–5: "Chamou Deus à luz ___ e às trevas chamou Noite".',
            ok="Certo: a luz recebe o nome Dia.",
            wrong={"b": "Noite é o nome das trevas.", "c": "Manhã fecha o dia primeiro."},
            options=opts(("a", "Dia"), ("b", "Noite"), ("c", "manhã")),
            correct="a",
            template="Chamou Deus à luz ___ e às trevas chamou Noite",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 1:3–5 comunica que se liga a este contexto?",
            ok="Certo: o dia nasce da palavra que separa e nomeia.",
            wrong={"b": "Não há dia sem a ação de Deus.", "c": "Luz e trevas são distinguidas."},
            options=opts(
                ("a", "Dia nasce da palavra que separa"),
                ("b", "Dia existe sem ação divina"),
                ("c", "Trevas e luz ficam misturadas"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:3–5", "text": "Chamou Deus à luz Dia e às trevas chamou Noite"},
            passageB={"ref": "Contexto", "text": "Dias: a palavra cria luz e separa Dia e Noite."},
        ),
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 1:3–5 mostra que a ordem do mundo começa quando Deus fala e distingue luz e trevas.",
            ok="Certo: a palavra cria e a separação ordena o primeiro dia.",
            wrong={"false": "O texto liga palavra, luz boa e nomes Dia/Noite."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 1:3–5, toque a palavra que falta em "Houve tarde e houve manhã, dia ___"?',
            ok="Exato: é o dia primeiro.",
            wrong={"a": "Tarde marca o ritmo, não o número.", "c": "Noite é o nome das trevas."},
            options=opts(("a", "tarde"), ("b", "primeiro"), ("c", "Noite")),
            correct="b",
            template="Houve tarde e houve manhã, dia ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que sentido teológico Gênesis 1:3–5 prepara sobre a palavra de Deus?",
            ok="Certo: a palavra de Deus é eficaz e ordenadora.",
            wrong={
                "a": "O texto mostra efeito imediato da palavra.",
                "c": "Deus avalia a luz como boa; não rejeita criar.",
                "d": "A ordem não vem do caos sozinho.",
            },
            options=opts(
                ("a", "A palavra divina é ineficaz"),
                ("b", "A palavra de Deus é eficaz e ordena"),
                ("c", "Deus fala sem querer criar ordem"),
                ("d", "A ordem nasce só do caos"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 1:3–5?",
            ok="Certo: falar, separar e nomear revelam o dia.",
            wrong={"b": "Siga a lógica teológica do trecho.", "c": "Nomear fecha o sentido do dia."},
            options=opts(
                ("a", "Deus fala e a luz existe"),
                ("b", "Deus separa luz e trevas"),
                ("c", "Deus nomeia Dia e Noite"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 1:3–5: "às trevas chamou ___".',
            ok="Certo: as trevas são chamadas Noite.",
            wrong={"a": "Dia é o nome da luz.", "c": "Luz é o que Deus cria primeiro."},
            options=opts(("a", "Dia"), ("b", "Noite"), ("c", "luz")),
            correct="b",
            template="às trevas chamou ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 1:3–5 comunica que se liga a este contexto?",
            ok="Certo: o leitor vê a palavra como princípio da ordem.",
            wrong={"b": "A luz não é acidental no texto.", "c": "Deus nomeia; não deixa sem distinção."},
            options=opts(
                ("a", "Palavra como princípio da ordem"),
                ("b", "Luz como acidente cósmico"),
                ("c", "Mundo sem distinção alguma"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:3–5", "text": "Disse Deus: Haja luz; e houve luz"},
            passageB={"ref": "Contexto", "text": "Dias: a palavra cria luz e separa Dia e Noite."},
        ),
    ],
)

# =============================================================================
# M3 gen-03-imagem | Gênesis 1:26–27
# =============================================================================
P3 = (
    "Disse também Deus: Façamos o homem à nossa imagem, conforme a nossa semelhança; "
    "domine ele sobre os peixes do mar, sobre as aves do céu, sobre os animais domésticos, "
    "sobre toda a terra e sobre todo réptil que se arrasta sobre a terra. "
    "Criou, pois, Deus o homem à sua imagem, à imagem de Deus o criou; homem e mulher os criou."
)
LO3 = "Afirmar que homem e mulher foram criados à imagem de Deus, com domínio sobre a terra."
add_mission(
    bank,
    "gen-03-imagem",
    "Gênesis 1:26–27",
    LO3,
    ["Gênesis 1:26–27"],
    P3,
    [
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="Criou, pois, Deus o homem à sua imagem, à imagem de Deus o criou; homem e mulher os criou.",
            ok="Certo: o texto afirma imagem e criação de homem e mulher.",
            wrong={"false": "Gênesis 1:27 diz exatamente isso."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 1:26–27, toque a palavra que falta em "Façamos o homem à nossa ___"?',
            ok="Exato: à nossa imagem.",
            wrong={"b": "Semelhança vem em seguida no texto.", "c": "Terra é o âmbito do domínio."},
            options=opts(("a", "imagem"), ("b", "semelhança"), ("c", "terra")),
            correct="a",
            template="Façamos o homem à nossa ___",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 1:26–27, quem Deus criou à sua imagem?",
            ok="Certo: homem e mulher os criou.",
            wrong={
                "b": "O texto inclui homem e mulher.",
                "c": "Não limita a criação à imagem só aos peixes.",
                "d": "Répteis são objetos do domínio, não da imagem.",
            },
            options=opts(
                ("a", "Homem e mulher"),
                ("b", "Somente o homem, sem a mulher"),
                ("c", "Apenas os peixes do mar"),
                ("d", "Somente os répteis da terra"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 1:26–27?",
            ok="Certo: proposta da imagem, domínio, criação de homem e mulher.",
            wrong={"b": "Siga a ordem do texto.", "c": "A criação fecha o movimento."},
            options=opts(
                ("a", "Façamos o homem à nossa imagem"),
                ("b", "domine ele sobre peixes, aves e terra"),
                ("c", "homem e mulher os criou"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 1:26–27: "homem e ___ os criou".',
            ok="Certo: homem e mulher os criou.",
            wrong={"b": "Imagem é o padrão, não o par criado.", "c": "Terra é o âmbito do domínio."},
            options=opts(("a", "mulher"), ("b", "imagem"), ("c", "terra")),
            correct="a",
            template="homem e ___ os criou",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 1:26–27 comunica que se liga a este contexto?",
            ok="Certo: homem e mulher são criados à imagem de Deus.",
            wrong={"b": "O texto afirma a imagem, não a nega.", "c": "Não há criação só de animais aqui."},
            options=opts(
                ("a", "Imagem: homem e mulher"),
                ("b", "Negação da imagem divina"),
                ("c", "Criação só de animais"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:26–27", "text": "à imagem de Deus o criou; homem e mulher os criou"},
            passageB={"ref": "Contexto", "text": "Imagem: homem e mulher criados à imagem de Deus."},
        ),
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 1:26–27, a imagem de Deus se aplica só a um dos sexos, excluindo o outro.",
            ok="Certo: o texto diz homem e mulher os criou à imagem.",
            wrong={"true": "Homem e mulher são criados à imagem de Deus."},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 1:26–27, toque a palavra que falta em "conforme a nossa ___"?',
            ok="Exato: conforme a nossa semelhança.",
            wrong={"a": "Imagem aparece antes neste versículo.", "c": "Domine é a missão, não esta palavra."},
            options=opts(("a", "imagem"), ("b", "semelhança"), ("c", "domine")),
            correct="b",
            template="conforme a nossa ___",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="Como Gênesis 1:26–27 relaciona imagem de Deus e domínio sobre a criação?",
            ok="Certo: a imagem inclui a vocação de dominar com responsabilidade.",
            wrong={
                "a": "O domínio está ligado à imagem, não separado.",
                "c": "Não há exclusão da mulher da imagem.",
                "d": "O texto não reduz a imagem a peixes apenas.",
            },
            options=opts(
                ("a", "Imagem sem qualquer vocação de domínio"),
                ("b", "Imagem ligada ao domínio sobre a terra"),
                ("c", "Imagem só masculina, sem a mulher"),
                ("d", "Imagem limitada aos peixes do mar"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 1:26–27?",
            ok="Certo: proposta, vocação de domínio, criação do par.",
            wrong={"b": "Reordene conforme o texto.", "c": "A criação do par fecha o encadeamento."},
            options=opts(
                ("a", "proposta de criar à imagem"),
                ("b", "vocação de dominar a terra"),
                ("c", "criação de homem e mulher"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 1:26–27: "à imagem de ___ o criou".',
            ok="Certo: à imagem de Deus o criou.",
            wrong={"b": "Homem é o criado, não o padrão.", "c": "Mulher completa o par criado."},
            options=opts(("a", "Deus"), ("b", "homem"), ("c", "mulher")),
            correct="a",
            template="à imagem de ___ o criou",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 1:26–27 comunica que se liga a este contexto?",
            ok="Certo: a humanidade recebe imagem e vocação juntas.",
            wrong={"b": "Não há rivalidade de deuses no texto.", "c": "O domínio não exclui a imagem."},
            options=opts(
                ("a", "Humanidade: imagem e vocação"),
                ("b", "Rivalidade entre deuses iguais"),
                ("c", "Domínio sem qualquer imagem"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:26–27", "text": "Façamos o homem à nossa imagem, conforme a nossa semelhança"},
            passageB={"ref": "Contexto", "text": "Imagem: homem e mulher criados à imagem de Deus."},
        ),
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 1:26–27 sustenta que a dignidade humana vem de ser criado à imagem de Deus.",
            ok="Certo: a imagem de Deus fundamenta a dignidade do par humano.",
            wrong={"false": "O texto centra a criação humana na imagem de Deus."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 1:26–27, toque a palavra que falta em "___ ele sobre os peixes do mar"?',
            ok="Exato: \"domine\" expressa a vocação dada.",
            wrong={"a": "Criou descreve o ato, não esta lacuna.", "c": "Imagem é o padrão, não o verbo."},
            options=opts(("a", "Criou"), ("b", "domine"), ("c", "imagem")),
            correct="b",
            template="___ ele sobre os peixes do mar",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que leitura teológica Gênesis 1:26–27 prepara sobre homem e mulher?",
            ok="Certo: ambos compartilham a imagem e a vocação.",
            wrong={
                "a": "O texto não exclui a mulher da imagem.",
                "c": "Não reduz a humanidade a domínio bruto sem imagem.",
                "d": "A imagem não é de animais, mas de Deus.",
            },
            options=opts(
                ("a", "Só o homem carrega a imagem divina"),
                ("b", "Homem e mulher compartilham a imagem"),
                ("c", "A humanidade é só força sem imagem"),
                ("d", "A imagem é a dos animais domésticos"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 1:26–27?",
            ok="Certo: imagem proposta, vocação, criação do par.",
            wrong={"b": "Ordene pela lógica do texto.", "c": "O par criado fecha o sentido."},
            options=opts(
                ("a", "Deus propõe criar à sua imagem"),
                ("b", "dá vocação de domínio"),
                ("c", "cria homem e mulher"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 1:26–27: "Criou, pois, Deus o homem à sua ___".',
            ok="Certo: à sua imagem.",
            wrong={"b": "Semelhança aparece na proposta, outra palavra aqui.", "c": "Mulher completa o par."},
            options=opts(("a", "imagem"), ("b", "semelhança"), ("c", "mulher")),
            correct="a",
            template="Criou, pois, Deus o homem à sua ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 1:26–27 comunica que se liga a este contexto?",
            ok="Certo: o leitor vê a humanidade como imagem de Deus.",
            wrong={"b": "Não há negação da dignidade humana.", "c": "O texto não exclui a mulher."},
            options=opts(
                ("a", "Humanidade como imagem de Deus"),
                ("b", "Negação da dignidade humana"),
                ("c", "Exclusão da mulher da criação"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:26–27", "text": "homem e mulher os criou"},
            passageB={"ref": "Contexto", "text": "Imagem: homem e mulher criados à imagem de Deus."},
        ),
    ],
)

# =============================================================================
# M4 gen-04-descanso | Gênesis 2:2–3
# =============================================================================
P4 = (
    "No sétimo dia, acabou Deus a obra que tinha feito; e cessou, no sétimo dia, "
    "de toda a obra que fizera. Abençoou Deus o dia sétimo e o santificou; "
    "porque nele cessou de toda a obra que fizera como Criador."
)
LO4 = "Reconhecer que Deus cessa a obra, abençoa e santifica o sétimo dia."
add_mission(
    bank,
    "gen-04-descanso",
    "Gênesis 2:2–3",
    LO4,
    ["Gênesis 2:2–3"],
    P4,
    [
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="Abençoou Deus o dia sétimo e o santificou; porque nele cessou de toda a obra que fizera como Criador.",
            ok="Certo: o sétimo dia é abençoado e santificado.",
            wrong={"false": "Gênesis 2:3 afirma bênção e santificação do sétimo dia."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 2:2–3, toque a palavra que falta em "No ___ dia, acabou Deus a obra"?',
            ok="Exato: no sétimo dia.",
            wrong={"b": "Obra é o que Deus acaba.", "c": "Criador explica o cessar."},
            options=opts(("a", "sétimo"), ("b", "obra"), ("c", "Criador")),
            correct="a",
            template="No ___ dia, acabou Deus a obra",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 2:2–3, o que Deus fez ao dia sétimo?",
            ok="Certo: abençoou e santificou o dia sétimo.",
            wrong={
                "b": "O texto fala de bênção e santificação, não de maldição.",
                "c": "Ele cessa a obra; não continua criando neste dia.",
                "d": "Não há esquecimento do dia no texto.",
            },
            options=opts(
                ("a", "Abençoou e santificou"),
                ("b", "Amaldiçoou e rejeitou"),
                ("c", "Continuou criando sem cessar"),
                ("d", "Esqueceu o dia por completo"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 2:2–3?",
            ok="Certo: acaba, cessa, abençoa e santifica.",
            wrong={"b": "Siga a ordem do versículo.", "c": "A santificação vem após o cessar."},
            options=opts(
                ("a", "acabou Deus a obra que tinha feito"),
                ("b", "cessou de toda a obra que fizera"),
                ("c", "abençoou e santificou o dia sétimo"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 2:2–3: "Abençoou Deus o dia sétimo e o ___".',
            ok="Certo: Deus santificou o dia sétimo.",
            wrong={"b": "Cessou explica o motivo, não esta lacuna.", "c": "Obra é o que Ele acabou."},
            options=opts(("a", "santificou"), ("b", "cessou"), ("c", "obra")),
            correct="a",
            template="Abençoou Deus o dia sétimo e o ___",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 2:2–3 comunica que se liga a este contexto?",
            ok="Certo: Deus cessa, abençoa e santifica o sétimo dia.",
            wrong={"b": "O texto descreve cessar, não fadiga humana.", "c": "Não há rejeição do dia."},
            options=opts(
                ("a", "Cessar, abençoar e santificar"),
                ("b", "Fadiga humana no sétimo dia"),
                ("c", "Rejeição do dia sétimo"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 2:2–3", "text": "Abençoou Deus o dia sétimo e o santificou"},
            passageB={"ref": "Contexto", "text": "Descanso: Deus cessa, abençoa e santifica o sétimo dia."},
        ),
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 2:2–3, Deus continua a obra criadora sem cessar no sétimo dia.",
            ok="Certo: Ele cessa de toda a obra que fizera.",
            wrong={"true": "O texto insiste que Deus cessou no sétimo dia."},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 2:2–3, toque a palavra que falta em "e ___, no sétimo dia, de toda a obra"?',
            ok="Exato: Deus cessou no sétimo dia.",
            wrong={"a": "Acabou aparece antes; aqui é cessou.", "c": "Santificou vem depois."},
            options=opts(("a", "acabou"), ("b", "cessou"), ("c", "santificou")),
            correct="b",
            template="e ___, no sétimo dia, de toda a obra",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="Por que, segundo Gênesis 2:2–3, o dia sétimo é santificado?",
            ok="Certo: porque nele Deus cessou de toda a obra como Criador.",
            wrong={
                "a": "O motivo é o cessar da obra, não o cansaço.",
                "c": "Não há arrependimento da criação neste trecho.",
                "d": "O texto não fala de esquecimento.",
            },
            options=opts(
                ("a", "Porque Deus ficou cansado demais"),
                ("b", "Porque nele cessou de toda a obra"),
                ("c", "Porque se arrependeu de criar"),
                ("d", "Porque esqueceu a criação"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 2:2–3?",
            ok="Certo: obra acabada, cessar, bênção e santidade.",
            wrong={"b": "Reordene pelo fluxo do texto.", "c": "Bênção e santidade fecham."},
            options=opts(
                ("a", "obra acabada no sétimo dia"),
                ("b", "cessar de toda a obra"),
                ("c", "bênção e santificação do dia"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 2:2–3: "porque nele ___ de toda a obra que fizera como Criador".',
            ok="Certo: nele cessou de toda a obra.",
            wrong={"a": "Abençoou é outro ato no versículo.", "c": "Santificou acompanha a bênção."},
            options=opts(("a", "abençoou"), ("b", "cessou"), ("c", "santificou")),
            correct="b",
            template="porque nele ___ de toda a obra que fizera como Criador",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 2:2–3 comunica que se liga a este contexto?",
            ok="Certo: o descanso do Criador marca o dia santo.",
            wrong={"b": "Não há continuidade da obra neste dia.", "c": "O dia é santificado, não ignorado."},
            options=opts(
                ("a", "Descanso do Criador no dia santo"),
                ("b", "Continuação da obra no sétimo"),
                ("c", "Dia sétimo sem qualquer valor"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 2:2–3", "text": "porque nele cessou de toda a obra que fizera como Criador"},
            passageB={"ref": "Contexto", "text": "Descanso: Deus cessa, abençoa e santifica o sétimo dia."},
        ),
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 2:2–3 apresenta o sétimo dia como tempo marcado pela cessação e pela santidade do Criador.",
            ok="Certo: cessar, abençoar e santificar definem o dia.",
            wrong={"false": "O texto une cessação e santificação no sétimo dia."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 2:2–3, toque a palavra que falta em "Abençoou Deus o dia sétimo e o santificou; porque nele cessou… como ___"?',
            ok="Exato: como Criador.",
            wrong={"a": "Obra é o que Ele cessou.", "c": "Sétimo é o dia, não este título."},
            options=opts(("a", "obra"), ("b", "Criador"), ("c", "sétimo")),
            correct="b",
            template="porque nele cessou de toda a obra que fizera como ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que sentido teológico Gênesis 2:2–3 prepara sobre o descanso?",
            ok="Certo: o descanso é dom e santidade do Criador, não vazio.",
            wrong={
                "a": "O texto santifica o dia; não o trata como vazio inútil.",
                "c": "Não há abandono da criação.",
                "d": "A bênção não é humana inventada aqui.",
            },
            options=opts(
                ("a", "Descanso como vazio inútil"),
                ("b", "Descanso como dom e santidade"),
                ("c", "Descanso como abandono da criação"),
                ("d", "Descanso inventado só pelo homem"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 2:2–3?",
            ok="Certo: acabar, cessar e santificar revelam o descanso.",
            wrong={"b": "Ordene pela lógica do texto.", "c": "Santificar fecha o sentido."},
            options=opts(
                ("a", "Deus acaba a obra"),
                ("b", "Deus cessa no sétimo dia"),
                ("c", "Deus abençoa e santifica o dia"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 2:2–3: "___ Deus o dia sétimo e o santificou".',
            ok="Certo: Abençoou Deus o dia sétimo.",
            wrong={"b": "Cessou explica o motivo.", "c": "Acabou descreve o fim da obra."},
            options=opts(("a", "Abençoou"), ("b", "Cessou"), ("c", "Acabou")),
            correct="a",
            template="___ Deus o dia sétimo e o santificou",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 2:2–3 comunica que se liga a este contexto?",
            ok="Certo: o leitor vê o sétimo dia como santificado pelo Criador.",
            wrong={"b": "Não há maldição do dia no texto.", "c": "O cessar não é falha."},
            options=opts(
                ("a", "Sétimo dia santificado pelo Criador"),
                ("b", "Sétimo dia amaldiçoado por Deus"),
                ("c", "Cessar como falha da criação"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 2:2–3", "text": "Abençoou Deus o dia sétimo e o santificou"},
            passageB={"ref": "Contexto", "text": "Descanso: Deus cessa, abençoa e santifica o sétimo dia."},
        ),
    ],
)

# =============================================================================
# M5 gen-boss-01 | Gênesis 1:1; 2:3
# =============================================================================
P5 = (
    "No princípio, criou Deus o céu e a terra. "
    "Abençoou Deus o dia sétimo e o santificou; porque nele cessou de toda a obra que fizera como Criador."
)
LO5 = "Unir o princípio da criação ao sétimo dia santificado pelo Criador."
add_mission(
    bank,
    "gen-boss-01",
    "Gênesis 1:1; 2:3",
    LO5,
    ["Gênesis 1:1", "Gênesis 2:3"],
    P5,
    [
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="No princípio, criou Deus o céu e a terra.",
            ok="Certo: Gênesis 1:1 afirma a criação no princípio.",
            wrong={"false": "O versículo declara a criação do céu e da terra."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 1:1; 2:3, toque a palavra que falta em "No ___, criou Deus o céu e a terra"?',
            ok="Exato: no princípio.",
            wrong={"b": "Céu é o objeto criado.", "c": "Sétimo aparece em 2:3."},
            options=opts(("a", "princípio"), ("b", "céu"), ("c", "sétimo")),
            correct="a",
            template="No ___, criou Deus o céu e a terra",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 1:1 e 2:3, o que Deus faz no princípio e no sétimo dia?",
            ok="Certo: cria no princípio e santifica o sétimo dia.",
            wrong={
                "b": "Ele cria e depois santifica; não abandona.",
                "c": "Não há maldição do sétimo dia.",
                "d": "O texto não diz que o homem cria o céu.",
            },
            options=opts(
                ("a", "Cria e depois santifica o sétimo dia"),
                ("b", "Cria e abandona a obra"),
                ("c", "Amaldiçoa o sétimo dia"),
                ("d", "Deixa o homem criar o céu"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 1:1; 2:3?",
            ok="Certo: criação no princípio, depois bênção do sétimo dia.",
            wrong={"b": "Comece pelo princípio.", "c": "A santificação vem depois."},
            options=opts(
                ("a", "criou Deus o céu e a terra"),
                ("b", "Abençoou Deus o dia sétimo"),
                ("c", "e o santificou"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 2:3: "Abençoou Deus o dia sétimo e o ___".',
            ok="Certo: e o santificou.",
            wrong={"b": "Cessou explica o motivo.", "c": "Criou está em 1:1."},
            options=opts(("a", "santificou"), ("b", "cessou"), ("c", "criou")),
            correct="a",
            template="Abençoou Deus o dia sétimo e o ___",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 1:1; 2:3 comunica que se liga a este contexto?",
            ok="Certo: criação no princípio e sétimo dia santificado.",
            wrong={"b": "Não há criação sem Deus.", "c": "O sétimo dia é santificado."},
            options=opts(
                ("a", "Princípio e sétimo santificado"),
                ("b", "Criação sem qualquer Deus"),
                ("c", "Sétimo dia sem santidade"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:1; 2:3", "text": "No princípio, criou Deus… Abençoou Deus o dia sétimo e o santificou"},
            passageB={"ref": "Contexto", "text": "Criação: princípio e sétimo dia santificado."},
        ),
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 1:1 e 2:3, o sétimo dia permanece sem bênção após a criação.",
            ok="Certo: Deus abençoa e santifica o sétimo dia.",
            wrong={"true": "Gênesis 2:3 afirma bênção e santificação."},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 1:1; 2:3, toque a palavra que falta em "porque nele ___ de toda a obra que fizera como Criador"?',
            ok="Exato: nele cessou.",
            wrong={"a": "Santificou é outro ato.", "c": "Criou está no princípio."},
            options=opts(("a", "santificou"), ("b", "cessou"), ("c", "criou")),
            correct="b",
            template="porque nele ___ de toda a obra que fizera como Criador",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="Como Gênesis 1:1 e 2:3 encadeiam início e consumação da obra criadora?",
            ok="Certo: Deus cria no princípio e santifica o cessar no sétimo.",
            wrong={
                "a": "Não há abandono; há santificação.",
                "c": "O sétimo dia não é vazio de sentido.",
                "d": "A criação começa com Deus, não com o homem.",
            },
            options=opts(
                ("a", "Deus cria e abandona o mundo"),
                ("b", "Deus cria e santifica o cessar"),
                ("c", "O sétimo dia não tem sentido"),
                ("d", "O homem inicia a criação sozinho"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 1:1; 2:3?",
            ok="Certo: princípio da criação, cessar, santificação.",
            wrong={"b": "Reordene pelo arco da criação.", "c": "Santificar fecha o arco."},
            options=opts(
                ("a", "criação no princípio"),
                ("b", "cessar da obra no sétimo"),
                ("c", "bênção e santificação do dia"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 1:1: "criou ___ o céu e a terra".',
            ok="Certo: criou Deus.",
            wrong={"b": "Princípio marca o tempo.", "c": "Sétimo pertence a 2:3."},
            options=opts(("a", "Deus"), ("b", "princípio"), ("c", "sétimo")),
            correct="a",
            template="criou ___ o céu e a terra",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 1:1; 2:3 comunica que se liga a este contexto?",
            ok="Certo: o arco vai do criar ao santificar o descanso.",
            wrong={"b": "Não há criação sem descanso santificado.", "c": "O Criador não se ausenta."},
            options=opts(
                ("a", "Do criar ao santificar o descanso"),
                ("b", "Criação sem descanso algum"),
                ("c", "Criador ausente após o princípio"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:1; 2:3", "text": "criou Deus o céu e a terra… o santificou"},
            passageB={"ref": "Contexto", "text": "Criação: princípio e sétimo dia santificado."},
        ),
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 1:1 e 2:3 juntos apresentam a criação como obra que começa em Deus e termina em dia santificado.",
            ok="Certo: princípio e sétimo dia formam o arco da criação.",
            wrong={"false": "Os textos unem criação e santificação do sétimo dia."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 1:1; 2:3, toque a palavra que falta em "fizera como ___"?',
            ok="Exato: como Criador.",
            wrong={"a": "Obra é o que Ele cessou.", "c": "Terra é o objeto criado."},
            options=opts(("a", "obra"), ("b", "Criador"), ("c", "terra")),
            correct="b",
            template="fizera como ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que leitura teológica Gênesis 1:1; 2:3 prepara sobre a criação?",
            ok="Certo: a criação tem origem santa e ritmo de descanso santificado.",
            wrong={
                "a": "O texto não trata a criação como acidente.",
                "c": "O sétimo dia é santificado, não desprezado.",
                "d": "Deus não é rival vencido; é Criador.",
            },
            options=opts(
                ("a", "Criação como acidente sem origem"),
                ("b", "Criação com origem e descanso santo"),
                ("c", "Sétimo dia sem valor teológico"),
                ("d", "Deus como rival vencido pelo caos"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 1:1; 2:3?",
            ok="Certo: criar, cessar e santificar revelam o arco.",
            wrong={"b": "Ordene pelo sentido do arco.", "c": "Santificar fecha o sentido."},
            options=opts(
                ("a", "Deus cria no princípio"),
                ("b", "Deus cessa no sétimo dia"),
                ("c", "Deus santifica o dia"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 2:3: "___ Deus o dia sétimo e o santificou".',
            ok="Certo: Abençoou Deus o dia sétimo.",
            wrong={"b": "Cessou explica o porque.", "c": "Criou está em 1:1."},
            options=opts(("a", "Abençoou"), ("b", "Cessou"), ("c", "Criou")),
            correct="a",
            template="___ Deus o dia sétimo e o santificou",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 1:1; 2:3 comunica que se liga a este contexto?",
            ok="Certo: o leitor une princípio criador e dia santo.",
            wrong={"b": "Não há criação órfã de Deus.", "c": "O descanso não é falha."},
            options=opts(
                ("a", "Princípio criador e dia santo"),
                ("b", "Criação órfã de qualquer Deus"),
                ("c", "Descanso como falha da obra"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:1; 2:3", "text": "No princípio, criou Deus… Abençoou Deus o dia sétimo"},
            passageB={"ref": "Contexto", "text": "Criação: princípio e sétimo dia santificado."},
        ),
    ],
)

# =============================================================================
# M6 gen-05-eden | Gênesis 2:15–17
# =============================================================================
P6 = (
    "Tomou, pois, Deus Jeová ao homem e pô-lo no jardim do Éden para o cultivar e guardar. "
    "Ordenou Deus Jeová ao homem: De toda a árvore do jardim podes comer livremente; "
    "mas da árvore do conhecimento do bem e do mal, dela não comerás, "
    "porque, no dia em que dela comeres, certamente morrerás."
)
LO6 = "Ver que no Éden o homem cultiva e guarda, sob ordem de vida ou morte."
add_mission(
    bank,
    "gen-05-eden",
    "Gênesis 2:15–17",
    LO6,
    ["Gênesis 2:15–17"],
    P6,
    [
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="Tomou, pois, Deus Jeová ao homem e pô-lo no jardim do Éden para o cultivar e guardar.",
            ok="Certo: o homem é posto no Éden para cultivar e guardar.",
            wrong={"false": "Gênesis 2:15 afirma exatamente essa missão."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 2:15–17, toque a palavra que falta em "pô-lo no jardim do Éden para o cultivar e ___"?',
            ok="Exato: cultivar e guardar.",
            wrong={"a": "Comer aparece na ordem seguinte.", "c": "Morrerás é a consequência."},
            options=opts(("a", "comer"), ("b", "guardar"), ("c", "morrerás")),
            correct="b",
            template="pô-lo no jardim do Éden para o cultivar e ___",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 2:15–17, de qual árvore o homem não deveria comer?",
            ok="Certo: da árvore do conhecimento do bem e do mal.",
            wrong={
                "b": "De toda a árvore ele podia comer, salvo uma.",
                "c": "Não há proibição de cultivar o jardim.",
                "d": "A ordem não fala de beber das águas.",
            },
            options=opts(
                ("a", "Da árvore do conhecimento do bem e do mal"),
                ("b", "De toda árvore do jardim sem exceção"),
                ("c", "Da tarefa de cultivar o jardim"),
                ("d", "Das águas que regam o Éden"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 2:15–17?",
            ok="Certo: posto no Éden, permissão, proibição com morte.",
            wrong={"b": "Siga a ordem do texto.", "c": "A proibição vem depois da permissão."},
            options=opts(
                ("a", "pô-lo no jardim do Éden para cultivar e guardar"),
                ("b", "De toda a árvore podes comer livremente"),
                ("c", "da árvore do conhecimento… certamente morrerás"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 2:15–17: "no dia em que dela comeres, certamente ___".',
            ok="Certo: certamente morrerás.",
            wrong={"a": "Guardar é a missão no jardim.", "c": "Cultivar também é missão."},
            options=opts(("a", "guardar"), ("b", "morrerás"), ("c", "cultivar")),
            correct="b",
            template="no dia em que dela comeres, certamente ___",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 2:15–17 comunica que se liga a este contexto?",
            ok="Certo: cultivar, guardar e ordem de vida ou morte.",
            wrong={"b": "Há ordem clara no texto.", "c": "Não há liberdade total sem limite."},
            options=opts(
                ("a", "Cultivar, guardar e ordem vital"),
                ("b", "Éden sem qualquer ordem"),
                ("c", "Liberdade total sem limite"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 2:15–17", "text": "para o cultivar e guardar… certamente morrerás"},
            passageB={"ref": "Contexto", "text": "Éden: cultivar, guardar e uma ordem de vida ou morte."},
        ),
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 2:15–17, o homem recebe no Éden só permissão, sem qualquer proibição.",
            ok="Certo: há permissão ampla e uma proibição clara.",
            wrong={"true": "O texto inclui a proibição da árvore do conhecimento."},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 2:15–17, toque a palavra que falta em "para o ___ e guardar"?',
            ok="Exato: cultivar e guardar.",
            wrong={"b": "Guardar é o segundo verbo.", "c": "Comer é da ordem seguinte."},
            options=opts(("a", "cultivar"), ("b", "guardar"), ("c", "comer")),
            correct="a",
            template="para o ___ e guardar",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="Como Gênesis 2:15–17 relaciona missão no jardim e limite moral?",
            ok="Certo: vocação de cuidar e limite que preserva a vida.",
            wrong={
                "a": "Há limite claro no texto.",
                "c": "A morte está ligada à desobediência, não ao cultivo.",
                "d": "Não há indiferença divina à ordem.",
            },
            options=opts(
                ("a", "Missão sem qualquer limite moral"),
                ("b", "Cuidar do jardim sob limite que guarda a vida"),
                ("c", "Morte ligada ao ato de cultivar"),
                ("d", "Deus indiferente ao que o homem come"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 2:15–17?",
            ok="Certo: colocação, permissão, proibição com consequência.",
            wrong={"b": "Reordene pelo fluxo do texto.", "c": "A consequência fecha."},
            options=opts(
                ("a", "homem posto no Éden"),
                ("b", "permissão de comer das árvores"),
                ("c", "proibição com ameaça de morte"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 2:15–17: "da árvore do conhecimento do bem e do mal, dela não ___".',
            ok="Certo: dela não comerás.",
            wrong={"a": "Guardarás é a missão do jardim.", "c": "Cultivarás também é missão."},
            options=opts(("a", "guardarás"), ("b", "comerás"), ("c", "cultivarás")),
            correct="b",
            template="da árvore do conhecimento do bem e do mal, dela não ___",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 2:15–17 comunica que se liga a este contexto?",
            ok="Certo: vida no Éden inclui cuidado e obediência.",
            wrong={"b": "Não há autonomia absoluta.", "c": "Há limite claro."},
            options=opts(
                ("a", "Cuidado e obediência no Éden"),
                ("b", "Autonomia absoluta do homem"),
                ("c", "Jardim sem qualquer limite"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 2:15–17", "text": "De toda a árvore… podes comer… dela não comerás"},
            passageB={"ref": "Contexto", "text": "Éden: cultivar, guardar e uma ordem de vida ou morte."},
        ),
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 2:15–17 apresenta a vida no Éden como vocação sob a palavra de Deus, não como liberdade sem limite.",
            ok="Certo: cultivar, guardar e a ordem revelam vida sob a palavra.",
            wrong={"false": "O texto une missão e limite revelado."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 2:15–17, toque a palavra que falta em "Ordenou Deus Jeová ao ___"?',
            ok="Exato: ordenou ao homem.",
            wrong={"a": "Éden é o lugar.", "c": "Árvore é o objeto da proibição."},
            options=opts(("a", "Éden"), ("b", "homem"), ("c", "árvore")),
            correct="b",
            template="Ordenou Deus Jeová ao ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que sentido teológico Gênesis 2:15–17 prepara sobre a ordem divina?",
            ok="Certo: a ordem protege a vida; desobedecer traz morte.",
            wrong={
                "a": "A ordem não é capricho vazio; liga-se à vida.",
                "c": "A morte é consequência, não o cultivo.",
                "d": "Deus não é indiferente.",
            },
            options=opts(
                ("a", "Ordem como capricho sem sentido"),
                ("b", "Ordem que protege a vida sob Deus"),
                ("c", "Morte como prêmio do cultivo"),
                ("d", "Deus indiferente ao bem e ao mal"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 2:15–17?",
            ok="Certo: vocação, liberdade limitada e aviso de morte.",
            wrong={"b": "Ordene pela lógica do texto.", "c": "O aviso fecha o sentido."},
            options=opts(
                ("a", "vocação de cultivar e guardar"),
                ("b", "liberdade de comer com limite"),
                ("c", "aviso de morte na desobediência"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 2:15–17: "pô-lo no jardim do Éden para o ___ e guardar".',
            ok="Certo: para o cultivar e guardar.",
            wrong={"b": "Comer é da ordem seguinte.", "c": "Morrerás é a consequência."},
            options=opts(("a", "cultivar"), ("b", "comer"), ("c", "morrerás")),
            correct="a",
            template="pô-lo no jardim do Éden para o ___ e guardar",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 2:15–17 comunica que se liga a este contexto?",
            ok="Certo: o leitor vê vida como dom sob a palavra.",
            wrong={"b": "Não há Éden sem palavra.", "c": "A proibição não é inútil."},
            options=opts(
                ("a", "Vida como dom sob a palavra"),
                ("b", "Éden sem palavra de Deus"),
                ("c", "Proibição sem ligação à vida"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 2:15–17", "text": "dela não comerás, porque… certamente morrerás"},
            passageB={"ref": "Contexto", "text": "Éden: cultivar, guardar e uma ordem de vida ou morte."},
        ),
    ],
)

# =============================================================================
# M7 gen-06-queda | Gênesis 3:6
# =============================================================================
P7 = (
    "Viu, pois, a mulher que a árvore era boa para comer, que era uma delícia para os olhos "
    "e árvore desejável para dar entendimento; tomou do fruto dela e comeu; "
    "deu também a seu marido, e ele comeu."
)
LO7 = "Observar a sequência da queda: ver, desejar, tomar, dar — e os dois comem."
add_mission(
    bank,
    "gen-06-queda",
    "Gênesis 3:6",
    LO7,
    ["Gênesis 3:6"],
    P7,
    [
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="Tomou do fruto dela e comeu; deu também a seu marido, e ele comeu.",
            ok="Certo: a mulher come e dá ao marido, que também come.",
            wrong={"false": "Gênesis 3:6 afirma que os dois comem."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 3:6, toque a palavra que falta em "tomou do fruto dela e ___"?',
            ok="Exato: e comeu.",
            wrong={"a": "Viu inicia a sequência.", "c": "Deu vem depois."},
            options=opts(("a", "viu"), ("b", "comeu"), ("c", "deu")),
            correct="b",
            template="tomou do fruto dela e ___",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 3:6, o que a mulher fez após tomar do fruto?",
            ok="Certo: comeu e deu também a seu marido.",
            wrong={
                "b": "Ela deu ao marido; ele também comeu.",
                "c": "O texto não diz que ela guardou o fruto.",
                "d": "Não há rejeição do fruto neste versículo.",
            },
            options=opts(
                ("a", "Comeu e deu ao marido"),
                ("b", "Comeu e escondeu do marido"),
                ("c", "Guardou o fruto sem comer"),
                ("d", "Rejeitou o fruto da árvore"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 3:6?",
            ok="Certo: viu, tomou e comeu, deu e ele comeu.",
            wrong={"b": "Siga a ordem do versículo.", "c": "O marido come por último."},
            options=opts(
                ("a", "Viu que a árvore era boa e desejável"),
                ("b", "tomou do fruto dela e comeu"),
                ("c", "deu também a seu marido, e ele comeu"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 3:6: "deu também a seu ___, e ele comeu".',
            ok="Certo: a seu marido.",
            wrong={"a": "Fruto é o que ela tomou.", "c": "Olhos descrevem a delícia."},
            options=opts(("a", "fruto"), ("b", "marido"), ("c", "olhos")),
            correct="b",
            template="deu também a seu ___, e ele comeu",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 3:6 comunica que se liga a este contexto?",
            ok="Certo: ver, desejar, tomar e dar — os dois comem.",
            wrong={"b": "Os dois comem no texto.", "c": "Não há recusa do fruto."},
            options=opts(
                ("a", "Ver, desejar, tomar e dar"),
                ("b", "Só a mulher come o fruto"),
                ("c", "Recusa total do fruto"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 3:6", "text": "tomou do fruto dela e comeu; deu também a seu marido, e ele comeu"},
            passageB={"ref": "Contexto", "text": "Queda: ver, desejar, tomar e dar — os dois comem."},
        ),
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 3:6, o marido recusa o fruto e não come.",
            ok="Certo: o texto diz que ele comeu.",
            wrong={"true": "Gênesis 3:6 afirma que ele comeu."},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 3:6, toque a palavra que falta em "árvore ___ para dar entendimento"?',
            ok="Exato: desejável para dar entendimento.",
            wrong={"a": "Boa descreve para comer.", "c": "Delícia refere-se aos olhos."},
            options=opts(("a", "boa"), ("b", "desejável"), ("c", "delícia")),
            correct="b",
            template="árvore ___ para dar entendimento",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="Como Gênesis 3:6 encadeia desejo e ato na queda?",
            ok="Certo: ver e desejar precedem tomar, comer e compartilhar.",
            wrong={
                "a": "O desejo vem antes do ato no texto.",
                "c": "O marido também come.",
                "d": "Não há recusa final do fruto.",
            },
            options=opts(
                ("a", "O ato vem antes de qualquer desejo"),
                ("b", "Ver e desejar levam a tomar e dar"),
                ("c", "Só o desejo, sem nenhum ato"),
                ("d", "O marido impede o ato final"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 3:6?",
            ok="Certo: percepção, ato e compartilhamento.",
            wrong={"b": "Reordene pelo fluxo do versículo.", "c": "O compartilhar fecha."},
            options=opts(
                ("a", "percepção da árvore como boa e desejável"),
                ("b", "tomar e comer o fruto"),
                ("c", "dar ao marido, que também come"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 3:6: "que era uma ___ para os olhos".',
            ok="Certo: uma delícia para os olhos.",
            wrong={"a": "Boa refere-se a comer.", "c": "Desejável refere-se ao entendimento."},
            options=opts(("a", "boa"), ("b", "delícia"), ("c", "desejável")),
            correct="b",
            template="que era uma ___ para os olhos",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 3:6 comunica que se liga a este contexto?",
            ok="Certo: a queda passa pelo desejo e pelo ato compartilhado.",
            wrong={"b": "Há ato concreto no texto.", "c": "O marido participa."},
            options=opts(
                ("a", "Desejo e ato compartilhado"),
                ("b", "Queda só no desejo, sem ato"),
                ("c", "Marido ausente da desobediência"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 3:6", "text": "Viu… tomou… comeu; deu também a seu marido"},
            passageB={"ref": "Contexto", "text": "Queda: ver, desejar, tomar e dar — os dois comem."},
        ),
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 3:6 mostra a desobediência como processo que envolve desejo, ato e cumplicidade.",
            ok="Certo: ver, tomar, dar e comer juntos revelam esse processo.",
            wrong={"false": "O versículo descreve desejo, ato e compartilhar."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 3:6, toque a palavra que falta em "Viu, pois, a ___ que a árvore era boa"?',
            ok="Exato: a mulher.",
            wrong={"a": "Árvore é o objeto visto.", "c": "Marido recebe o fruto depois."},
            options=opts(("a", "árvore"), ("b", "mulher"), ("c", "marido")),
            correct="b",
            template="Viu, pois, a ___ que a árvore era boa",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que leitura teológica Gênesis 3:6 prepara sobre a queda?",
            ok="Certo: a queda une desejo distorcido e ato compartilhado.",
            wrong={
                "a": "Há ato real no texto, não só pensamento.",
                "c": "O marido também come.",
                "d": "Não há vitória sobre a tentação neste versículo.",
            },
            options=opts(
                ("a", "Queda só no pensamento, sem ato"),
                ("b", "Desejo distorcido e ato compartilhado"),
                ("c", "Culpa exclusiva sem o marido"),
                ("d", "Vitória imediata sobre a tentação"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 3:6?",
            ok="Certo: desejo, apropriação e cumplicidade revelam a queda.",
            wrong={"b": "Ordene pela lógica do texto.", "c": "A cumplicidade fecha."},
            options=opts(
                ("a", "desejo diante da árvore"),
                ("b", "apropriação do fruto"),
                ("c", "cumplicidade no comer"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 3:6: "___ do fruto dela e comeu".',
            ok="Certo: tomou do fruto.",
            wrong={"a": "Viu inicia a sequência.", "c": "Deu vem depois."},
            options=opts(("a", "Viu"), ("b", "tomou"), ("c", "deu")),
            correct="b",
            template="___ do fruto dela e comeu",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 3:6 comunica que se liga a este contexto?",
            ok="Certo: o leitor vê a queda como desejo que se torna ato.",
            wrong={"b": "Não há inocência plena no ato.", "c": "Há cumplicidade."},
            options=opts(
                ("a", "Desejo que se torna ato"),
                ("b", "Ato sem qualquer desejo"),
                ("c", "Isolamento sem cumplicidade"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 3:6", "text": "árvore desejável… tomou… deu também a seu marido"},
            passageB={"ref": "Contexto", "text": "Queda: ver, desejar, tomar e dar — os dois comem."},
        ),
    ],
)

# =============================================================================
# M8 gen-07-consequencias | Gênesis 3:15
# =============================================================================
P8 = (
    "Porei inimizade entre ti e a mulher, e entre a tua semente e a sua semente; "
    "esta te ferirá a cabeça, e tu lhe ferirás o calcanhar."
)
LO8 = "Reconhecer a promessa: a semente da mulher ferirá a cabeça da serpente."
add_mission(
    bank,
    "gen-07-consequencias",
    "Gênesis 3:15",
    LO8,
    ["Gênesis 3:15"],
    P8,
    [
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="Esta te ferirá a cabeça, e tu lhe ferirás o calcanhar.",
            ok="Certo: a semente fere a cabeça; a serpente fere o calcanhar.",
            wrong={"false": "Gênesis 3:15 afirma exatamente isso."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 3:15, toque a palavra que falta em "esta te ferirá a ___"?',
            ok="Exato: a cabeça.",
            wrong={"b": "Calcanhar é o que a serpente fere.", "c": "Semente é o sujeito."},
            options=opts(("a", "cabeça"), ("b", "calcanhar"), ("c", "semente")),
            correct="a",
            template="esta te ferirá a ___",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 3:15, o que Deus porá entre a serpente e a mulher?",
            ok="Certo: inimizade entre eles e suas sementes.",
            wrong={
                "b": "O texto fala de inimizade, não de aliança.",
                "c": "Não há paz imediata no versículo.",
                "d": "Não há esquecimento da serpente.",
            },
            options=opts(
                ("a", "Inimizade"),
                ("b", "Aliança de paz"),
                ("c", "Amizade eterna"),
                ("d", "Esquecimento total"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 3:15?",
            ok="Certo: inimizade, sementes, ferir cabeça e calcanhar.",
            wrong={"b": "Siga a ordem do versículo.", "c": "O calcanhar vem por último."},
            options=opts(
                ("a", "Porei inimizade entre ti e a mulher"),
                ("b", "entre a tua semente e a sua semente"),
                ("c", "esta te ferirá a cabeça, e tu lhe ferirás o calcanhar"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 3:15: "tu lhe ferirás o ___".',
            ok="Certo: o calcanhar.",
            wrong={"a": "Cabeça é o que a semente fere.", "c": "Semente é o sujeito."},
            options=opts(("a", "cabeça"), ("b", "calcanhar"), ("c", "semente")),
            correct="b",
            template="tu lhe ferirás o ___",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 3:15 comunica que se liga a este contexto?",
            ok="Certo: a semente ferirá a cabeça da serpente.",
            wrong={"b": "Há esperança no ferir a cabeça.", "c": "Há inimizade, não paz plena."},
            options=opts(
                ("a", "Semente ferirá a cabeça"),
                ("b", "Serpente sem qualquer oposição"),
                ("c", "Paz plena sem conflito"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 3:15", "text": "esta te ferirá a cabeça, e tu lhe ferirás o calcanhar"},
            passageB={"ref": "Contexto", "text": "Consequências e esperança: a semente ferirá a cabeça da serpente."},
        ),
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 3:15, a serpente fere a cabeça da semente, e a semente apenas o calcanhar.",
            ok="Certo: é o inverso — a semente fere a cabeça.",
            wrong={"true": "O texto diz: esta te ferirá a cabeça."},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 3:15, toque a palavra que falta em "Porei ___ entre ti e a mulher"?',
            ok="Exato: inimizade.",
            wrong={"a": "Semente aparece depois.", "c": "Cabeça é o alvo do ferir."},
            options=opts(("a", "semente"), ("b", "inimizade"), ("c", "cabeça")),
            correct="b",
            template="Porei ___ entre ti e a mulher",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="Como Gênesis 3:15 relaciona julgamento da serpente e esperança?",
            ok="Certo: há conflito, mas a semente fere a cabeça.",
            wrong={
                "a": "Há esperança no ferir a cabeça.",
                "c": "A inimizade inclui as sementes.",
                "d": "Não há anulação da oposição.",
            },
            options=opts(
                ("a", "Só juízo, sem qualquer esperança"),
                ("b", "Inimizade com promessa de vitória da semente"),
                ("c", "Paz imediata sem conflito"),
                ("d", "Anulação total da oposição"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 3:15?",
            ok="Certo: inimizade declarada, sementes envolvidas, ferimentos.",
            wrong={"b": "Reordene pelo fluxo do texto.", "c": "Os ferimentos fecham."},
            options=opts(
                ("a", "declaração de inimizade"),
                ("b", "oposição entre as sementes"),
                ("c", "ferir a cabeça e o calcanhar"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 3:15: "entre a tua semente e a sua ___".',
            ok="Certo: a sua semente.",
            wrong={"a": "Mulher é a outra parte da inimizade.", "c": "Cabeça é o alvo."},
            options=opts(("a", "mulher"), ("b", "semente"), ("c", "cabeça")),
            correct="b",
            template="entre a tua semente e a sua ___",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 3:15 comunica que se liga a este contexto?",
            ok="Certo: juízo e esperança se encontram na semente.",
            wrong={"b": "Há esperança no texto.", "c": "A vitória aponta à cabeça."},
            options=opts(
                ("a", "Juízo e esperança na semente"),
                ("b", "Juízo sem qualquer esperança"),
                ("c", "Vitória só da serpente"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 3:15", "text": "entre a tua semente e a sua semente; esta te ferirá a cabeça"},
            passageB={"ref": "Contexto", "text": "Consequências e esperança: a semente ferirá a cabeça da serpente."},
        ),
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 3:15 sustenta esperança no meio do juízo: a semente da mulher ferirá a cabeça da serpente.",
            ok="Certo: o ferir a cabeça aponta vitória promissora.",
            wrong={"false": "O texto une inimizade e promessa de ferir a cabeça."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 3:15, toque a palavra que falta em "esta te ___ a cabeça"?',
            ok="Exato: ferirá.",
            wrong={"a": "Porei inicia a sentença.", "c": "Inimizade é o que Deus põe."},
            options=opts(("a", "Porei"), ("b", "ferirá"), ("c", "inimizade")),
            correct="b",
            template="esta te ___ a cabeça",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que sentido teológico Gênesis 3:15 prepara sobre o futuro?",
            ok="Certo: Deus promete oposição decisiva à serpente pela semente.",
            wrong={
                "a": "Há promessa de ferir a cabeça.",
                "c": "O calcanhar ferido não anula a vitória anunciada.",
                "d": "Não há paz sem conflito neste versículo.",
            },
            options=opts(
                ("a", "Serpente sem oposição futura"),
                ("b", "Promessa de vitória pela semente"),
                ("c", "Derrota total sem qualquer esperança"),
                ("d", "Paz imediata sem luta"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 3:15?",
            ok="Certo: conflito, linhagens e golpe decisivo.",
            wrong={"b": "Ordene pela lógica do texto.", "c": "O golpe na cabeça fecha."},
            options=opts(
                ("a", "Deus declara inimizade"),
                ("b", "as sementes entram no conflito"),
                ("c", "a semente fere a cabeça"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 3:15: "Porei inimizade entre ti e a ___".',
            ok="Certo: a mulher.",
            wrong={"a": "Semente vem em seguida.", "c": "Cabeça é o alvo do ferir."},
            options=opts(("a", "semente"), ("b", "mulher"), ("c", "cabeça")),
            correct="b",
            template="Porei inimizade entre ti e a ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 3:15 comunica que se liga a este contexto?",
            ok="Certo: o leitor recebe esperança no juízo.",
            wrong={"b": "Há esperança no texto.", "c": "A semente não é esquecida."},
            options=opts(
                ("a", "Esperança no meio do juízo"),
                ("b", "Juízo sem palavra de esperança"),
                ("c", "Semente esquecida por Deus"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 3:15", "text": "esta te ferirá a cabeça"},
            passageB={"ref": "Contexto", "text": "Consequências e esperança: a semente ferirá a cabeça da serpente."},
        ),
    ],
)

# =============================================================================
# M9 gen-boss-02 | Gênesis 3:6; 3:15
# =============================================================================
P9 = (
    "Viu, pois, a mulher que a árvore era boa para comer, que era uma delícia para os olhos "
    "e árvore desejável para dar entendimento; tomou do fruto dela e comeu; "
    "deu também a seu marido, e ele comeu. "
    "Porei inimizade entre ti e a mulher, e entre a tua semente e a sua semente; "
    "esta te ferirá a cabeça, e tu lhe ferirás o calcanhar."
)
LO9 = "Unir a desobediência de Gênesis 3:6 à promessa da semente em 3:15."
add_mission(
    bank,
    "gen-boss-02",
    "Gênesis 3:6; 3:15",
    LO9,
    ["Gênesis 3:6", "Gênesis 3:15"],
    P9,
    [
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="Deu também a seu marido, e ele comeu.",
            ok="Certo: em 3:6 os dois comem o fruto.",
            wrong={"false": "Gênesis 3:6 afirma que ele comeu."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 3:6; 3:15, toque a palavra que falta em "esta te ferirá a ___"?',
            ok="Exato: a cabeça.",
            wrong={"b": "Calcanhar é o ferimento da serpente.", "c": "Fruto pertence a 3:6."},
            options=opts(("a", "cabeça"), ("b", "calcanhar"), ("c", "fruto")),
            correct="a",
            template="esta te ferirá a ___",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 3:6 e 3:15, o que se segue à desobediência?",
            ok="Certo: desobediência e, depois, promessa de semente.",
            wrong={
                "b": "Há promessa em 3:15, não só silêncio.",
                "c": "A serpente não é vitoriosa sem oposição.",
                "d": "Os dois comem; não há recusa do marido.",
            },
            options=opts(
                ("a", "Desobediência e promessa de semente"),
                ("b", "Desobediência e silêncio total de Deus"),
                ("c", "Vitória plena da serpente sem oposição"),
                ("d", "Recusa do marido em comer"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 3:6; 3:15?",
            ok="Certo: comer o fruto, depois inimizade e ferir a cabeça.",
            wrong={"b": "Comece pela queda.", "c": "A promessa vem depois."},
            options=opts(
                ("a", "tomou do fruto e comeu; deu ao marido"),
                ("b", "Porei inimizade entre ti e a mulher"),
                ("c", "esta te ferirá a cabeça"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 3:15: "tu lhe ferirás o ___".',
            ok="Certo: o calcanhar.",
            wrong={"a": "Cabeça é o que a semente fere.", "c": "Fruto pertence a 3:6."},
            options=opts(("a", "cabeça"), ("b", "calcanhar"), ("c", "fruto")),
            correct="b",
            template="tu lhe ferirás o ___",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 3:6; 3:15 comunica que se liga a este contexto?",
            ok="Certo: queda na desobediência e promessa de semente.",
            wrong={"b": "Há promessa após a queda.", "c": "Não há paz plena imediata."},
            options=opts(
                ("a", "Queda e promessa de semente"),
                ("b", "Queda sem qualquer promessa"),
                ("c", "Paz plena sem conflito"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 3:6; 3:15", "text": "ele comeu… esta te ferirá a cabeça"},
            passageB={"ref": "Contexto", "text": "Queda: desobediência e promessa de semente."},
        ),
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 3:6 e 3:15, após a desobediência Deus permanece sem palavra de esperança.",
            ok="Certo: em 3:15 há promessa de que a semente ferirá a cabeça.",
            wrong={"true": "Gênesis 3:15 traz a promessa da semente."},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 3:6; 3:15, toque a palavra que falta em "deu também a seu ___, e ele comeu"?',
            ok="Exato: a seu marido.",
            wrong={"a": "Mulher é quem dá.", "c": "Semente aparece em 3:15."},
            options=opts(("a", "mulher"), ("b", "marido"), ("c", "semente")),
            correct="b",
            template="deu também a seu ___, e ele comeu",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="Como Gênesis 3:6 e 3:15 encadeiam crise e esperança?",
            ok="Certo: a desobediência é seguida pela promessa da semente.",
            wrong={
                "a": "Há esperança em 3:15.",
                "c": "A serpente não fica sem oposição.",
                "d": "Os dois participam da queda.",
            },
            options=opts(
                ("a", "Crise sem qualquer esperança"),
                ("b", "Desobediência seguida de promessa"),
                ("c", "Serpente sem oposição futura"),
                ("d", "Queda só de um, sem o outro"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 3:6; 3:15?",
            ok="Certo: desobediência, inimizade e golpe na cabeça.",
            wrong={"b": "Reordene pelo arco queda–promessa.", "c": "O golpe fecha."},
            options=opts(
                ("a", "desobediência ao comer o fruto"),
                ("b", "declaração de inimizade"),
                ("c", "promessa de ferir a cabeça"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 3:15: "Porei ___ entre ti e a mulher".',
            ok="Certo: inimizade.",
            wrong={"a": "Semente vem depois.", "c": "Fruto pertence a 3:6."},
            options=opts(("a", "semente"), ("b", "inimizade"), ("c", "fruto")),
            correct="b",
            template="Porei ___ entre ti e a mulher",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 3:6; 3:15 comunica que se liga a este contexto?",
            ok="Certo: o arco vai da queda à esperança da semente.",
            wrong={"b": "Há continuação na promessa.", "c": "Não há vitória só da serpente."},
            options=opts(
                ("a", "Da queda à esperança da semente"),
                ("b", "Queda sem continuação alguma"),
                ("c", "Vitória só da serpente"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 3:6; 3:15", "text": "tomou… comeu… esta te ferirá a cabeça"},
            passageB={"ref": "Contexto", "text": "Queda: desobediência e promessa de semente."},
        ),
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 3:6 e 3:15 juntos mostram que a desobediência não tem a última palavra: há promessa de semente.",
            ok="Certo: a promessa responde à crise da queda.",
            wrong={"false": "Os textos unem queda e esperança."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 3:6; 3:15, toque a palavra que falta em "entre a tua semente e a sua ___"?',
            ok="Exato: semente.",
            wrong={"a": "Mulher é a outra parte da inimizade.", "c": "Cabeça é o alvo."},
            options=opts(("a", "mulher"), ("b", "semente"), ("c", "cabeça")),
            correct="b",
            template="entre a tua semente e a sua ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que leitura teológica Gênesis 3:6; 3:15 prepara?",
            ok="Certo: Deus responde à queda com promessa de vitória.",
            wrong={
                "a": "Há resposta divina em 3:15.",
                "c": "A semente não é esquecida.",
                "d": "Não há paz sem conflito anunciado.",
            },
            options=opts(
                ("a", "Queda sem resposta divina"),
                ("b", "Queda respondida com promessa"),
                ("c", "Semente esquecida no juízo"),
                ("d", "Paz imediata sem luta"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 3:6; 3:15?",
            ok="Certo: ato de desobediência, juízo e esperança.",
            wrong={"b": "Ordene pelo sentido do arco.", "c": "A esperança fecha."},
            options=opts(
                ("a", "ato de desobediência"),
                ("b", "juízo com inimizade"),
                ("c", "esperança na semente"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 3:6: "tomou do fruto dela e ___".',
            ok="Certo: e comeu.",
            wrong={"a": "Viu inicia a sequência.", "c": "Deu vem depois."},
            options=opts(("a", "viu"), ("b", "comeu"), ("c", "deu")),
            correct="b",
            template="tomou do fruto dela e ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 3:6; 3:15 comunica que se liga a este contexto?",
            ok="Certo: o leitor une desobediência e esperança prometida.",
            wrong={"b": "Há esperança no arco.", "c": "A semente importa."},
            options=opts(
                ("a", "Desobediência e esperança prometida"),
                ("b", "Desobediência sem esperança"),
                ("c", "Promessa sem relação com a queda"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 3:6; 3:15", "text": "ele comeu… esta te ferirá a cabeça"},
            passageB={"ref": "Contexto", "text": "Queda: desobediência e promessa de semente."},
        ),
    ],
)

# =============================================================================
# M10 gen-08-caim | Gênesis 4:8–9 — V/F assertions for Gen 4:9
# =============================================================================
P10 = (
    "Caim o contou a seu irmão Abel. Sucedeu, pois, que, estando eles no campo, "
    "se levantou Caim contra seu irmão Abel e o matou. "
    "Perguntou Jeová a Caim: Onde está Abel, teu irmão? "
    "Respondeu ele: Não sei; sou eu o guarda de meu irmão?"
)
LO10 = "Ver que Caim mata Abel e responde a Jeová fingindo não ser guarda do irmão."
add_mission(
    bank,
    "gen-08-caim",
    "Gênesis 4:8–9",
    LO10,
    ["Gênesis 4:8–9"],
    P10,
    [
        # V/F: assertions about Gen 4:9 (mix T/F)
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="Jeová perguntou a Caim onde estava Abel, seu irmão.",
            ok="Certo: Jeová pergunta a Caim pelo irmão.",
            wrong={"false": "Gênesis 4:9 registra exatamente essa pergunta."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 4:8–9, toque a palavra que falta em "se levantou Caim contra seu irmão Abel e o ___"?',
            ok="Exato: e o matou.",
            wrong={"a": "Contou inicia o trecho.", "c": "Campo é o lugar."},
            options=opts(("a", "contou"), ("b", "matou"), ("c", "campo")),
            correct="b",
            template="se levantou Caim contra seu irmão Abel e o ___",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 4:8–9, o que Caim responde quando Jeová pergunta por Abel?",
            ok="Certo: Não sei; sou eu o guarda de meu irmão?",
            wrong={
                "b": "Ele não confessa de imediato.",
                "c": "Não aponta outro culpado no texto.",
                "d": "Não celebra a morte no versículo.",
            },
            options=opts(
                ("a", "Não sei; sou eu o guarda de meu irmão?"),
                ("b", "Sim, matei Abel no campo"),
                ("c", "Abel fugiu para outra terra"),
                ("d", "Jeová não deveria perguntar"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 4:8–9?",
            ok="Certo: no campo, Caim mata; Jeová pergunta; Caim finge.",
            wrong={"b": "Siga a ordem do texto.", "c": "A resposta vem por último."},
            options=opts(
                ("a", "estando eles no campo, se levantou Caim e o matou"),
                ("b", "Perguntou Jeová a Caim: Onde está Abel"),
                ("c", "Respondeu ele: Não sei; sou eu o guarda"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 4:9: "sou eu o ___ de meu irmão?"',
            ok="Certo: o guarda de meu irmão.",
            wrong={"a": "Campo é o lugar do crime.", "c": "Matou descreve o ato."},
            options=opts(("a", "campo"), ("b", "guarda"), ("c", "matou")),
            correct="b",
            template="sou eu o ___ de meu irmão?",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 4:8–9 comunica que se liga a este contexto?",
            ok="Certo: Caim mata Abel e finge não ser guarda.",
            wrong={"b": "Há assassinato no texto.", "c": "A resposta é evasiva."},
            options=opts(
                ("a", "Caim mata e finge não ser guarda"),
                ("b", "Caim protege Abel no campo"),
                ("c", "Caim confessa de imediato"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 4:8–9", "text": "se levantou Caim… e o matou… sou eu o guarda de meu irmão?"},
            passageB={"ref": "Contexto", "text": "Caim mata Abel e finge não ser guarda."},
        ),
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 4:9, Caim responde a Jeová confessando de imediato onde está Abel.",
            ok="Certo: ele diz \"Não sei\" e se esquiva da responsabilidade.",
            wrong={"true": "A resposta é: Não sei; sou eu o guarda…?"},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 4:8–9, toque a palavra que falta em "Onde está Abel, teu ___"?',
            ok="Exato: teu irmão.",
            wrong={"a": "Guarda aparece na resposta.", "c": "Campo é o lugar."},
            options=opts(("a", "guarda"), ("b", "irmão"), ("c", "campo")),
            correct="b",
            template="Onde está Abel, teu ___",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="O que a pergunta \"sou eu o guarda de meu irmão?\" revela sobre Caim em Gênesis 4:9?",
            ok="Certo: ele tenta negar a responsabilidade pelo irmão.",
            wrong={
                "a": "Não há confissão sincera neste versículo.",
                "c": "Ele não aceita o papel de guarda.",
                "d": "A resposta é evasiva, não transparente.",
            },
            options=opts(
                ("a", "Confissão sincera e completa"),
                ("b", "Tentativa de negar responsabilidade"),
                ("c", "Aceitação do papel de guarda"),
                ("d", "Transparência total diante de Jeová"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 4:8–9?",
            ok="Certo: violência, pergunta divina e resposta evasiva.",
            wrong={"b": "Reordene pelo fluxo do texto.", "c": "A evasiva fecha."},
            options=opts(
                ("a", "violência de Caim contra Abel"),
                ("b", "pergunta de Jeová por Abel"),
                ("c", "resposta evasiva de Caim"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 4:9: "Respondeu ele: Não ___"',
            ok="Certo: Não sei.",
            wrong={"a": "Guarda vem na pergunta retórica.", "c": "Matou descreve o crime."},
            options=opts(("a", "guarda"), ("b", "sei"), ("c", "matou")),
            correct="b",
            template="Respondeu ele: Não ___",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 4:8–9 comunica que se liga a este contexto?",
            ok="Certo: o crime é seguido de fingimento diante de Jeová.",
            wrong={"b": "Há fingimento, não proteção.", "c": "Ele não assume de imediato."},
            options=opts(
                ("a", "Crime seguido de fingimento"),
                ("b", "Crime seguido de proteção"),
                ("c", "Confissão imediata e plena"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 4:8–9", "text": "e o matou… Não sei; sou eu o guarda de meu irmão?"},
            passageB={"ref": "Contexto", "text": "Caim mata Abel e finge não ser guarda."},
        ),
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 4:9 sustenta que Caim tenta se isentar de ser guarda de Abel diante de Jeová.",
            ok="Certo: a pergunta retórica busca negar a responsabilidade.",
            wrong={"false": "A resposta de Caim finge ignorância e nega o papel de guarda."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 4:8–9, toque a palavra que falta em "estando eles no ___, se levantou Caim"?',
            ok="Exato: no campo.",
            wrong={"a": "Irmão nomeia Abel.", "c": "Guarda aparece na resposta."},
            options=opts(("a", "irmão"), ("b", "campo"), ("c", "guarda")),
            correct="b",
            template="estando eles no ___, se levantou Caim",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que leitura teológica Gênesis 4:8–9 prepara sobre pecado e responsabilidade?",
            ok="Certo: o pecado gera violência e a mentira tenta encobrir.",
            wrong={
                "a": "Há mentira na resposta de Caim.",
                "c": "Jeová pergunta; não há indiferença.",
                "d": "Caim não assume o cuidado do irmão.",
            },
            options=opts(
                ("a", "Violência sem qualquer mentira"),
                ("b", "Violência coberta por mentira evasiva"),
                ("c", "Jeová indiferente ao irmão morto"),
                ("d", "Caim como guarda fiel de Abel"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 4:8–9?",
            ok="Certo: assassinato, questionamento divino e negação.",
            wrong={"b": "Ordene pela lógica do texto.", "c": "A negação fecha."},
            options=opts(
                ("a", "assassinato de Abel"),
                ("b", "questionamento de Jeová"),
                ("c", "negação da responsabilidade"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 4:9: "Perguntou Jeová a Caim: Onde está ___ , teu irmão?"',
            ok="Certo: Onde está Abel.",
            wrong={"a": "Guarda aparece na resposta.", "c": "Campo é o lugar do crime."},
            options=opts(("a", "guarda"), ("b", "Abel"), ("c", "campo")),
            correct="b",
            template="Onde está ___, teu irmão?",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 4:8–9 comunica que se liga a este contexto?",
            ok="Certo: o leitor vê o pecado negar o cuidado do irmão.",
            wrong={"b": "Há evasão, não cuidado.", "c": "Jeová não fica calado."},
            options=opts(
                ("a", "Pecado que nega o cuidado do irmão"),
                ("b", "Pecado que assume o cuidado"),
                ("c", "Silêncio total de Jeová"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 4:9", "text": "Não sei; sou eu o guarda de meu irmão?"},
            passageB={"ref": "Contexto", "text": "Caim mata Abel e finge não ser guarda."},
        ),
    ],
)

# =============================================================================
# M11 gen-09-diluvio | Gênesis 6:8; 9:12–13
# Semente lean A; caminhada/pro lean B
# =============================================================================
PA = "Porém Noé achou graça aos olhos de Jeová."
PB = (
    "Disse Deus: Este é o sinal da aliança que faço entre mim e vós e todo o animal vivente "
    "que está convosco, para perpétuas gerações: o meu arco tenho posto nas nuvens, "
    "e será ele por sinal de uma aliança entre mim e a terra."
)
P11_COMBINED = PA + " " + PB
LO11 = "Reconhecer a graça a Noé e o arco nas nuvens como sinal da aliança."


def dil_items():
    return [
        # SEMENTE — lean A (6:8)
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="Porém Noé achou graça aos olhos de Jeová.",
            ok="Certo: Noé achou graça aos olhos de Jeová.",
            wrong={"false": "Gênesis 6:8 afirma exatamente isso."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 6:8, toque a palavra que falta em "Porém Noé achou ___ aos olhos de Jeová"?',
            ok="Exato: graça.",
            wrong={"b": "Noé é quem acha graça.", "c": "Jeová é quem concede."},
            options=opts(("a", "graça"), ("b", "Noé"), ("c", "Jeová")),
            correct="a",
            template="Porém Noé achou ___ aos olhos de Jeová",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 6:8, o que Noé achou?",
            ok="Certo: graça aos olhos de Jeová.",
            wrong={
                "b": "O texto fala de graça, não de ira contra Noé.",
                "c": "Não há menção de torre neste versículo.",
                "d": "Não diz que Noé foi esquecido.",
            },
            options=opts(
                ("a", "Graça aos olhos de Jeová"),
                ("b", "Ira permanente de Jeová"),
                ("c", "Uma torre até o céu"),
                ("d", "Esquecimento total de Deus"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 6:8; 9:12–13 (foco na graça)?",
            ok="Certo: Noé, graça, aos olhos de Jeová.",
            wrong={"b": "Siga a ordem da frase.", "c": "Jeová fecha a sentença."},
            options=opts(
                ("a", "Porém Noé"),
                ("b", "achou graça"),
                ("c", "aos olhos de Jeová"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 6:8: "Porém Noé achou graça aos ___ de Jeová".',
            ok="Certo: aos olhos de Jeová.",
            wrong={"a": "Graça é o que ele achou.", "c": "Noé é o sujeito."},
            options=opts(("a", "graça"), ("b", "olhos"), ("c", "Noé")),
            correct="b",
            template="Porém Noé achou graça aos ___ de Jeová",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 6:8 comunica que se liga a este contexto?",
            ok="Certo: Dilúvio começa com graça a Noé.",
            wrong={"b": "Há graça no texto.", "c": "Noé não é rejeitado aqui."},
            options=opts(
                ("a", "Graça a Noé diante de Jeová"),
                ("b", "Ausência total de graça"),
                ("c", "Rejeição definitiva de Noé"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 6:8", "text": "Porém Noé achou graça aos olhos de Jeová"},
            passageB={"ref": "Contexto", "text": "Dilúvio: graça a Noé e arco na nuvem."},
        ),
        # CAMINHADA — lean B (9:12–13)
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 9:12–13, o arco posto nas nuvens é sinal de aliança entre Deus e a terra.",
            ok="Certo: o arco é sinal da aliança.",
            wrong={"false": "O texto chama o arco de sinal da aliança."},
            options=tf(), correct="true",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 9:12–13, toque a palavra que falta em "o meu ___ tenho posto nas nuvens"?',
            ok="Exato: o meu arco.",
            wrong={"a": "Aliança é o que o arco sinaliza.", "c": "Nuvens são o lugar."},
            options=opts(("a", "aliança"), ("b", "arco"), ("c", "nuvens")),
            correct="b",
            template="o meu ___ tenho posto nas nuvens",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="Como Gênesis 9:12–13 relaciona o arco e a aliança?",
            ok="Certo: o arco é sinal da aliança para gerações.",
            wrong={
                "a": "O arco é sinal, não ameaça de fim da aliança.",
                "c": "A aliança inclui a terra e os viventes.",
                "d": "Não é marca de graça negada a Noé.",
            },
            options=opts(
                ("a", "Arco como ameaça de fim da aliança"),
                ("b", "Arco como sinal da aliança perpétua"),
                ("c", "Arco só para Noé, sem a terra"),
                ("d", "Arco como negação da graça a Noé"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 9:12–13?",
            ok="Certo: sinal declarado, arco nas nuvens, aliança com a terra.",
            wrong={"b": "Reordene pelo fluxo do texto.", "c": "A aliança com a terra fecha."},
            options=opts(
                ("a", "Este é o sinal da aliança"),
                ("b", "o meu arco tenho posto nas nuvens"),
                ("c", "sinal de uma aliança entre mim e a terra"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 9:12–13: "será ele por sinal de uma ___ entre mim e a terra".',
            ok="Certo: aliança.",
            wrong={"a": "Arco é o sinal.", "c": "Nuvens são o lugar."},
            options=opts(("a", "arco"), ("b", "aliança"), ("c", "nuvens")),
            correct="b",
            template="será ele por sinal de uma ___ entre mim e a terra",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 9:12–13 comunica que se liga a este contexto?",
            ok="Certo: o arco nas nuvens assinala a aliança.",
            wrong={"b": "Há sinal claro no texto.", "c": "A aliança inclui a terra."},
            options=opts(
                ("a", "Arco como sinal da aliança"),
                ("b", "Arco sem qualquer significado"),
                ("c", "Aliança sem relação com a terra"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 9:12–13", "text": "o meu arco tenho posto nas nuvens"},
            passageB={"ref": "Contexto", "text": "Dilúvio: graça a Noé e arco na nuvem."},
        ),
        # PROFUNDEZAS — lean B + weave graça
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 6:8 e 9:12–13 juntos mostram graça a Noé e sinal de aliança no arco.",
            ok="Certo: graça precede; o arco assinala a aliança.",
            wrong={"false": "Os textos unem graça e sinal da aliança."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 9:12–13, toque a palavra que falta em "para ___ gerações"?',
            ok="Exato: perpétuas gerações.",
            wrong={"a": "Aliança é o pacto.", "c": "Sinal nomeia o arco."},
            options=opts(("a", "aliança"), ("b", "perpétuas"), ("c", "sinal")),
            correct="b",
            template="para ___ gerações",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que sentido teológico Gênesis 6:8; 9:12–13 prepara sobre o dilúvio?",
            ok="Certo: juízo acompanhado de graça e aliança sinalizada.",
            wrong={
                "a": "Há graça a Noé e sinal de aliança.",
                "c": "O arco não anula a graça; confirma aliança.",
                "d": "A aliança não é só humana; inclui a terra.",
            },
            options=opts(
                ("a", "Juízo sem graça nem aliança"),
                ("b", "Graça a Noé e aliança no arco"),
                ("c", "Arco como fim da graça divina"),
                ("d", "Aliança só humana, sem a terra"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 6:8; 9:12–13?",
            ok="Certo: graça, sinal e aliança com a terra.",
            wrong={"b": "Ordene pelo arco graça–aliança.", "c": "A aliança fecha."},
            options=opts(
                ("a", "Noé acha graça"),
                ("b", "Deus declara o sinal da aliança"),
                ("c", "o arco assinala a aliança com a terra"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 9:12–13: "o meu arco tenho posto nas ___".',
            ok="Certo: nas nuvens.",
            wrong={"a": "Arco é o objeto posto.", "c": "Terra recebe a aliança."},
            options=opts(("a", "arco"), ("b", "nuvens"), ("c", "terra")),
            correct="b",
            template="o meu arco tenho posto nas ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 6:8; 9:12–13 comunica que se liga a este contexto?",
            ok="Certo: o leitor une graça a Noé e arco na nuvem.",
            wrong={"b": "Há graça no arco da narrativa.", "c": "O sinal não é vazio."},
            options=opts(
                ("a", "Graça a Noé e arco na nuvem"),
                ("b", "Dilúvio sem qualquer graça"),
                ("c", "Sinal vazio sem aliança"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 6:8; 9:12–13", "text": "Noé achou graça… o meu arco tenho posto nas nuvens"},
            passageB={"ref": "Contexto", "text": "Dilúvio: graça a Noé e arco na nuvem."},
        ),
    ]


add_mission(
    bank,
    "gen-09-diluvio",
    "Gênesis 6:8; 9:12–13",
    LO11,
    ["Gênesis 6:8", "Gênesis 9:12–13"],
    P11_COMBINED,
    dil_items(),
    passage_by_diff={"semente": PA, "caminhada": PB, "profundezas": P11_COMBINED},
)

# =============================================================================
# M12 gen-10-babel | Gênesis 11:4
# =============================================================================
P12 = (
    "E disseram: Vinde, edifiquemos para nós uma cidade e uma torre cujo cume chegue até o céu "
    "e façamo-nos um nome; para que não sejamos espalhados sobre a face de toda a terra."
)
LO12 = "Ver que Babel busca nome próprio e torre, recusando o espalhar de Deus."
add_mission(
    bank,
    "gen-10-babel",
    "Gênesis 11:4",
    LO12,
    ["Gênesis 11:4"],
    P12,
    [
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="E disseram: Vinde, edifiquemos para nós uma cidade e uma torre cujo cume chegue até o céu e façamo-nos um nome.",
            ok="Certo: eles querem cidade, torre e um nome.",
            wrong={"false": "Gênesis 11:4 afirma exatamente esse projeto."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 11:4, toque a palavra que falta em "façamo-nos um ___"?',
            ok="Exato: um nome.",
            wrong={"a": "Torre é o edifício.", "c": "Céu é o alvo do cume."},
            options=opts(("a", "torre"), ("b", "nome"), ("c", "céu")),
            correct="b",
            template="façamo-nos um ___",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 11:4, para que eles querem a cidade e a torre?",
            ok="Certo: para não serem espalhados sobre toda a terra.",
            wrong={
                "b": "O motivo é evitar o espalhar.",
                "c": "Não há desejo de obedecer ao espalhar.",
                "d": "O texto não fala de graça a Noé aqui.",
            },
            options=opts(
                ("a", "Para não serem espalhados sobre a terra"),
                ("b", "Para serem espalhados mais depressa"),
                ("c", "Para obedecer ao espalhar de Deus"),
                ("d", "Para achar graça como Noé"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 11:4?",
            ok="Certo: edificar, fazer nome, evitar o espalhar.",
            wrong={"b": "Siga a ordem do versículo.", "c": "O motivo fecha."},
            options=opts(
                ("a", "edifiquemos cidade e torre até o céu"),
                ("b", "façamo-nos um nome"),
                ("c", "para que não sejamos espalhados"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 11:4: "uma torre cujo cume chegue até o ___".',
            ok="Certo: até o céu.",
            wrong={"a": "Nome é o que querem fazer.", "c": "Terra é o que temem espalhar."},
            options=opts(("a", "nome"), ("b", "céu"), ("c", "terra")),
            correct="b",
            template="uma torre cujo cume chegue até o ___",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 11:4 comunica que se liga a este contexto?",
            ok="Certo: nome próprio e torre — recusa do espalhar.",
            wrong={"b": "Há recusa do espalhar.", "c": "O nome é próprio, não dado por Deus."},
            options=opts(
                ("a", "Nome próprio e recusa do espalhar"),
                ("b", "Obediência ao espalhar de Deus"),
                ("c", "Nome dado somente por Deus"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 11:4", "text": "façamo-nos um nome; para que não sejamos espalhados"},
            passageB={"ref": "Contexto", "text": "Babel: nome próprio e torre — recusa do espalhar de Deus."},
        ),
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 11:4, o projeto da torre visa aceitar ser espalhado sobre toda a terra.",
            ok="Certo: o objetivo é não serem espalhados.",
            wrong={"true": "O texto diz: para que não sejamos espalhados."},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 11:4, toque a palavra que falta em "para que não sejamos ___"?',
            ok="Exato: espalhados.",
            wrong={"a": "Nome é o que querem fazer.", "c": "Cidade é o que edificam."},
            options=opts(("a", "nome"), ("b", "espalhados"), ("c", "cidade")),
            correct="b",
            template="para que não sejamos ___",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="Como Gênesis 11:4 relaciona fazer um nome e o espalhar?",
            ok="Certo: o nome próprio serve para resistir ao espalhar.",
            wrong={
                "a": "O nome não acompanha o espalhar; resiste a ele.",
                "c": "Há intenção clara de não se espalhar.",
                "d": "Não há pedido de graça neste versículo.",
            },
            options=opts(
                ("a", "Nome próprio a serviço do espalhar"),
                ("b", "Nome próprio para evitar o espalhar"),
                ("c", "Nome sem relação com o espalhar"),
                ("d", "Nome como pedido de graça a Jeová"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 11:4?",
            ok="Certo: convite a edificar, busca de nome, medo do espalhar.",
            wrong={"b": "Reordene pelo fluxo do texto.", "c": "O medo do espalhar fecha."},
            options=opts(
                ("a", "convite a edificar cidade e torre"),
                ("b", "busca de fazer um nome"),
                ("c", "recusa de ser espalhado"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 11:4: "edifiquemos para nós uma cidade e uma ___".',
            ok="Certo: uma torre.",
            wrong={"a": "Nome vem depois.", "c": "Céu é o alvo do cume."},
            options=opts(("a", "nome"), ("b", "torre"), ("c", "céu")),
            correct="b",
            template="edifiquemos para nós uma cidade e uma ___",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 11:4 comunica que se liga a este contexto?",
            ok="Certo: unidade humana tenta fixar-se contra o espalhar.",
            wrong={"b": "Há resistência ao espalhar.", "c": "O nome é autoatribuído."},
            options=opts(
                ("a", "Unidade que resiste ao espalhar"),
                ("b", "Unidade que abraça o espalhar"),
                ("c", "Nome recebido só de Deus"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 11:4", "text": "façamo-nos um nome; para que não sejamos espalhados"},
            passageB={"ref": "Contexto", "text": "Babel: nome próprio e torre — recusa do espalhar de Deus."},
        ),
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 11:4 apresenta Babel como projeto de nome próprio que se opõe ao espalhar ordenado por Deus.",
            ok="Certo: fazer nome e evitar o espalhar revelam essa oposição.",
            wrong={"false": "O texto une torre, nome e recusa do espalhar."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 11:4, toque a palavra que falta em "sobre a face de toda a ___"?',
            ok="Exato: toda a terra.",
            wrong={"a": "Céu é o alvo da torre.", "c": "Torre é o edifício."},
            options=opts(("a", "céu"), ("b", "terra"), ("c", "torre")),
            correct="b",
            template="sobre a face de toda a ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que leitura teológica Gênesis 11:4 prepara sobre Babel?",
            ok="Certo: autoexaltação humana contra o propósito de Deus.",
            wrong={
                "a": "Não há humildade no projeto do nome próprio.",
                "c": "O espalhar é o que eles querem evitar.",
                "d": "Não há pedido de graça neste versículo.",
            },
            options=opts(
                ("a", "Humildade que busca o nome de Deus"),
                ("b", "Autoexaltação contra o espalhar de Deus"),
                ("c", "Obediência plena ao espalhar"),
                ("d", "Busca de graça como a de Noé"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 11:4?",
            ok="Certo: edificar, nomear-se e resistir ao espalhar.",
            wrong={"b": "Ordene pela lógica do texto.", "c": "A resistência fecha."},
            options=opts(
                ("a", "projeto de cidade e torre"),
                ("b", "busca de nome próprio"),
                ("c", "resistência ao espalhar"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 11:4: "Vinde, ___ para nós uma cidade e uma torre".',
            ok="Certo: edifiquemos.",
            wrong={"a": "Façamo-nos refere-se ao nome.", "c": "Espalhados é o que temem."},
            options=opts(("a", "façamo-nos"), ("b", "edifiquemos"), ("c", "espalhados")),
            correct="b",
            template="Vinde, ___ para nós uma cidade e uma torre",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 11:4 comunica que se liga a este contexto?",
            ok="Certo: o leitor vê Babel como recusa do espalhar de Deus.",
            wrong={"b": "Há recusa, não obediência.", "c": "O nome é próprio."},
            options=opts(
                ("a", "Babel como recusa do espalhar"),
                ("b", "Babel como obediência plena"),
                ("c", "Babel como nome dado por Deus"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 11:4", "text": "façamo-nos um nome; para que não sejamos espalhados"},
            passageB={"ref": "Contexto", "text": "Babel: nome próprio e torre — recusa do espalhar de Deus."},
        ),
    ],
)

# =============================================================================
# M13 gen-11-abraao | Gênesis 12:1–2
# =============================================================================
P13 = (
    "Ora, disse Jeová a Abrão: Sai-te da tua terra, da tua parentela e da casa de teu pai "
    "para a terra que te mostrarei; farei de ti uma grande nação, e te abençoarei, "
    "e engrandecerei o teu nome. Sê tu uma bênção."
)
LO13 = "Reconhecer o chamado: Abrão deve sair e ser bênção — Jeová faz o nome."
add_mission(
    bank,
    "gen-11-abraao",
    "Gênesis 12:1–2",
    LO13,
    ["Gênesis 12:1–2"],
    P13,
    [
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="Ora, disse Jeová a Abrão: Sai-te da tua terra, da tua parentela e da casa de teu pai para a terra que te mostrarei.",
            ok="Certo: Jeová chama Abrão a sair para a terra que mostrará.",
            wrong={"false": "Gênesis 12:1 afirma exatamente esse chamado."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 12:1–2, toque a palavra que falta em "Sê tu uma ___"?',
            ok="Exato: uma bênção.",
            wrong={"a": "Nação vem na promessa.", "c": "Nome é o que Deus engrandece."},
            options=opts(("a", "nação"), ("b", "bênção"), ("c", "nome")),
            correct="b",
            template="Sê tu uma ___",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 12:1–2, o que Jeová fará com o nome de Abrão?",
            ok="Certo: engrandecerei o teu nome.",
            wrong={
                "b": "Deus engrandece o nome; não o apaga.",
                "c": "Não há ordem de Abrão fazer o próprio nome como Babel.",
                "d": "Não há maldição do nome neste trecho.",
            },
            options=opts(
                ("a", "Engrandecerei o teu nome"),
                ("b", "Apagarei o teu nome"),
                ("c", "Abrão fará sozinho o próprio nome"),
                ("d", "Amaldiçoarei o teu nome"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 12:1–2?",
            ok="Certo: sair, promessa de nação e nome, ser bênção.",
            wrong={"b": "Siga a ordem do texto.", "c": "Ser bênção fecha."},
            options=opts(
                ("a", "Sai-te da tua terra… para a terra que te mostrarei"),
                ("b", "farei de ti uma grande nação… engrandecerei o teu nome"),
                ("c", "Sê tu uma bênção"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 12:1–2: "farei de ti uma grande ___".',
            ok="Certo: uma grande nação.",
            wrong={"a": "Bênção fecha o versículo.", "c": "Nome é o que Deus engrandece."},
            options=opts(("a", "bênção"), ("b", "nação"), ("c", "nome")),
            correct="b",
            template="farei de ti uma grande ___",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 12:1–2 comunica que se liga a este contexto?",
            ok="Certo: sair e ser bênção — Jeová faz o nome.",
            wrong={"b": "O nome é feito por Jeová.", "c": "Há chamado a sair."},
            options=opts(
                ("a", "Sair e ser bênção; Deus faz o nome"),
                ("b", "Ficar e fazer o próprio nome"),
                ("c", "Recusar o chamado de Jeová"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 12:1–2", "text": "engrandecerei o teu nome. Sê tu uma bênção"},
            passageB={"ref": "Contexto", "text": "Chamado: sair e ser bênção — Jeová faz o nome."},
        ),
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 12:1–2, Abrão deve permanecer na casa do pai e fazer sozinho o próprio nome.",
            ok="Certo: ele deve sair; Jeová engrandece o nome.",
            wrong={"true": "O chamado é sair; Deus faz o nome."},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 12:1–2, toque a palavra que falta em "e ___ o teu nome"?',
            ok="Exato: engrandecerei.",
            wrong={"a": "Abençoarei é outro verbo da promessa.", "c": "Mostrarei refere-se à terra."},
            options=opts(("a", "abençoarei"), ("b", "engrandecerei"), ("c", "mostrarei")),
            correct="b",
            template="e ___ o teu nome",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="Como Gênesis 12:1–2 relaciona saída e bênção?",
            ok="Certo: sair sob a palavra leva a ser bênção, com nome dado por Deus.",
            wrong={
                "a": "A bênção acompanha o chamado a sair.",
                "c": "O nome vem de Jeová, não de Babel.",
                "d": "Não há recusa do chamado no texto.",
            },
            options=opts(
                ("a", "Saída sem qualquer promessa de bênção"),
                ("b", "Saída sob promessa de ser bênção"),
                ("c", "Nome feito à maneira de Babel"),
                ("d", "Permanência na terra do pai"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 12:1–2?",
            ok="Certo: chamado a sair, promessas, mandato de ser bênção.",
            wrong={"b": "Reordene pelo fluxo do texto.", "c": "Ser bênção fecha."},
            options=opts(
                ("a", "chamado a sair da terra e da parentela"),
                ("b", "promessa de nação, bênção e nome"),
                ("c", "mandato: sê tu uma bênção"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 12:1–2: "Sai-te da tua ___"',
            ok="Certo: da tua terra.",
            wrong={"a": "Nação é a promessa.", "c": "Bênção é o mandato final."},
            options=opts(("a", "nação"), ("b", "terra"), ("c", "bênção")),
            correct="b",
            template="Sai-te da tua ___",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 12:1–2 comunica que se liga a este contexto?",
            ok="Certo: o chamado inverte Babel — Deus faz o nome.",
            wrong={"b": "Há saída, não fixação.", "c": "O nome é de Jeová."},
            options=opts(
                ("a", "Deus faz o nome; Abrão é bênção"),
                ("b", "Abrão fixa-se e faz o próprio nome"),
                ("c", "Nome sem qualquer bênção"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 12:1–2", "text": "engrandecerei o teu nome. Sê tu uma bênção"},
            passageB={"ref": "Contexto", "text": "Chamado: sair e ser bênção — Jeová faz o nome."},
        ),
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 12:1–2 apresenta o nome de Abrão como dom de Jeová, ligado a ser bênção para outros.",
            ok="Certo: Deus engrandece o nome e manda: sê tu uma bênção.",
            wrong={"false": "O texto une nome engrandecido e mandato de bênção."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 12:1–2, toque a palavra que falta em "para a terra que te ___"?',
            ok="Exato: mostrarei.",
            wrong={"a": "Abençoarei é outra promessa.", "c": "Engrandecerei refere-se ao nome."},
            options=opts(("a", "abençoarei"), ("b", "mostrarei"), ("c", "engrandecerei")),
            correct="b",
            template="para a terra que te ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que sentido teológico Gênesis 12:1–2 prepara após Babel?",
            ok="Certo: Deus chama a sair e Ele mesmo faz o nome para bênção.",
            wrong={
                "a": "O contraste com Babel é o nome dado por Deus.",
                "c": "Há chamado a sair, não a fixar-se.",
                "d": "A bênção não é só privada.",
            },
            options=opts(
                ("a", "Nome próprio à maneira de Babel"),
                ("b", "Nome dado por Deus para ser bênção"),
                ("c", "Chamado a fixar-se sem sair"),
                ("d", "Bênção só privada, sem nação"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 12:1–2?",
            ok="Certo: saída, promessa divina e vocação de bênção.",
            wrong={"b": "Ordene pela lógica do chamado.", "c": "A bênção fecha."},
            options=opts(
                ("a", "chamado a sair"),
                ("b", "promessa de Deus sobre nação e nome"),
                ("c", "vocação de ser bênção"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 12:1–2: "e te ___, e engrandecerei o teu nome".',
            ok="Certo: te abençoarei.",
            wrong={"a": "Mostrarei refere-se à terra.", "c": "Sai-te é o chamado inicial."},
            options=opts(("a", "mostrarei"), ("b", "abençoarei"), ("c", "Sai-te")),
            correct="b",
            template="e te ___, e engrandecerei o teu nome",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 12:1–2 comunica que se liga a este contexto?",
            ok="Certo: o leitor vê o chamado como saída e bênção sob Deus.",
            wrong={"b": "Há saída no chamado.", "c": "O nome é de Jeová."},
            options=opts(
                ("a", "Chamado: saída e bênção sob Deus"),
                ("b", "Chamado a ficar sem sair"),
                ("c", "Nome autoatribuído como em Babel"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 12:1–2", "text": "Sai-te… engrandecerei o teu nome. Sê tu uma bênção"},
            passageB={"ref": "Contexto", "text": "Chamado: sair e ser bênção — Jeová faz o nome."},
        ),
    ],
)

# =============================================================================
# M14 gen-boss-final | Gênesis 1:1; 3:15; 12:2
# =============================================================================
P14 = (
    "No princípio, criou Deus o céu e a terra. "
    "Porei inimizade entre ti e a mulher, e entre a tua semente e a sua semente; "
    "esta te ferirá a cabeça, e tu lhe ferirás o calcanhar. "
    "farei de ti uma grande nação, e te abençoarei, e engrandecerei o teu nome. Sê tu uma bênção."
)
LO14 = "Unir criação, promessa da semente e bênção a Abrão em Gênesis 1–11."
add_mission(
    bank,
    "gen-boss-final",
    "Gênesis 1:1; 3:15; 12:2",
    LO14,
    ["Gênesis 1:1", "Gênesis 3:15", "Gênesis 12:2"],
    P14,
    [
        dict(
            diff="semente", skill="observe", type="true_false", nn="01",
            question="No princípio, criou Deus o céu e a terra.",
            ok="Certo: a criação abre o arco de Gênesis 1–11.",
            wrong={"false": "Gênesis 1:1 afirma a criação no princípio."},
            options=tf(), correct="true",
        ),
        dict(
            diff="semente", skill="observe", type="tap", nn="02",
            question='Em Gênesis 1:1; 3:15; 12:2, toque a palavra que falta em "esta te ferirá a ___"?',
            ok="Exato: a cabeça.",
            wrong={"b": "Calcanhar é o ferimento da serpente.", "c": "Nação pertence a 12:2."},
            options=opts(("a", "cabeça"), ("b", "calcanhar"), ("c", "nação")),
            correct="a",
            template="esta te ferirá a ___",
        ),
        dict(
            diff="semente", skill="observe", type="choice", nn="03",
            question="Segundo Gênesis 1:1; 3:15; 12:2, o que o arco une?",
            ok="Certo: criação, semente prometida e bênção a Abrão.",
            wrong={
                "b": "Há criação no princípio.",
                "c": "Há promessa da semente.",
                "d": "Há bênção e nome em 12:2.",
            },
            options=opts(
                ("a", "Criação, semente e bênção a Abrão"),
                ("b", "Só Babel, sem criação"),
                ("c", "Só dilúvio, sem promessa"),
                ("d", "Só Caim, sem bênção"),
            ),
            correct="a",
        ),
        dict(
            diff="semente", skill="observe", type="order", nn="04",
            question="Qual é a ordem dos fatos em Gênesis 1:1; 3:15; 12:2?",
            ok="Certo: criação, promessa da semente, bênção a Abrão.",
            wrong={"b": "Comece pela criação.", "c": "A bênção a Abrão fecha."},
            options=opts(
                ("a", "criou Deus o céu e a terra"),
                ("b", "esta te ferirá a cabeça"),
                ("c", "engrandecerei o teu nome; Sê tu uma bênção"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="semente", skill="observe", type="complete", nn="05",
            question='Complete Gênesis 12:2: "Sê tu uma ___".',
            ok="Certo: uma bênção.",
            wrong={"a": "Nação é a grande nação prometida.", "c": "Cabeça pertence a 3:15."},
            options=opts(("a", "nação"), ("b", "bênção"), ("c", "cabeça")),
            correct="b",
            template="Sê tu uma ___",
        ),
        dict(
            diff="semente", skill="observe", type="connect", nn="06",
            question="O que Gênesis 1:1; 3:15; 12:2 comunica que se liga a este contexto?",
            ok="Certo: criação, semente prometida e bênção a Abrão.",
            wrong={"b": "Há criação no arco.", "c": "Há bênção a Abrão."},
            options=opts(
                ("a", "Criação, semente e bênção"),
                ("b", "Arco sem criação alguma"),
                ("c", "Arco sem bênção a Abrão"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:1; 3:15; 12:2", "text": "criou Deus… ferirá a cabeça… Sê tu uma bênção"},
            passageB={"ref": "Contexto", "text": "Gênesis 1–11: criação, semente prometida e bênção a Abrão."},
        ),
        dict(
            diff="caminhada", skill="understand", type="true_false", nn="01",
            question="Em Gênesis 1:1; 3:15; 12:2, após a criação não há qualquer palavra de esperança ou bênção.",
            ok="Certo: há semente em 3:15 e bênção em 12:2.",
            wrong={"true": "Os textos trazem promessa e bênção."},
            options=tf(), correct="false",
        ),
        dict(
            diff="caminhada", skill="understand", type="tap", nn="02",
            question='Em Gênesis 1:1; 3:15; 12:2, toque a palavra que falta em "engrandecerei o teu ___"?',
            ok="Exato: o teu nome.",
            wrong={"a": "Nação é outra promessa.", "c": "Cabeça pertence a 3:15."},
            options=opts(("a", "nação"), ("b", "nome"), ("c", "cabeça")),
            correct="b",
            template="engrandecerei o teu ___",
        ),
        dict(
            diff="caminhada", skill="understand", type="choice", nn="03",
            question="Como Gênesis 1:1; 3:15; 12:2 encadeiam origem, crise e chamado?",
            ok="Certo: Deus cria; promete semente; abençoa Abrão.",
            wrong={
                "a": "Há esperança após a crise.",
                "c": "A bênção a Abrão continua o arco.",
                "d": "A criação abre, não fecha sozinha.",
            },
            options=opts(
                ("a", "Criação sem esperança depois da crise"),
                ("b", "Criação, semente prometida e bênção"),
                ("c", "Chamado a Abrão sem criação prévia"),
                ("d", "Só juízo, sem bênção alguma"),
            ),
            correct="b",
        ),
        dict(
            diff="caminhada", skill="understand", type="order", nn="04",
            question="Como se encadeiam os eventos de Gênesis 1:1; 3:15; 12:2?",
            ok="Certo: criar, prometer vitória, abençoar Abrão.",
            wrong={"b": "Reordene pelo arco da narrativa.", "c": "A bênção fecha."},
            options=opts(
                ("a", "criação no princípio"),
                ("b", "promessa de ferir a cabeça"),
                ("c", "bênção e nome a Abrão"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="caminhada", skill="understand", type="complete", nn="05",
            question='Complete Gênesis 3:15: "esta te ferirá a ___".',
            ok="Certo: a cabeça.",
            wrong={"a": "Calcanhar é o outro ferimento.", "c": "Bênção pertence a 12:2."},
            options=opts(("a", "calcanhar"), ("b", "cabeça"), ("c", "bênção")),
            correct="b",
            template="esta te ferirá a ___",
        ),
        dict(
            diff="caminhada", skill="understand", type="connect", nn="06",
            question="O que Gênesis 1:1; 3:15; 12:2 comunica que se liga a este contexto?",
            ok="Certo: o arco vai do criar à bênção pela semente.",
            wrong={"b": "Há continuidade na promessa.", "c": "Abrão recebe bênção."},
            options=opts(
                ("a", "Do criar à bênção pela semente"),
                ("b", "Criação sem continuação alguma"),
                ("c", "Bênção a Abrão sem criação"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:1; 3:15; 12:2", "text": "criou Deus… ferirá a cabeça… te abençoarei"},
            passageB={"ref": "Contexto", "text": "Gênesis 1–11: criação, semente prometida e bênção a Abrão."},
        ),
        dict(
            diff="profundezas", skill="interpret", type="true_false", nn="01",
            question="Gênesis 1:1; 3:15; 12:2 sustentam que a história começa em Deus Criador e segue com esperança e bênção.",
            ok="Certo: criação, semente e bênção a Abrão formam esse arco.",
            wrong={"false": "Os três textos unem origem, esperança e bênção."},
            options=tf(), correct="true",
        ),
        dict(
            diff="profundezas", skill="interpret", type="tap", nn="02",
            question='Em Gênesis 1:1; 3:15; 12:2, toque a palavra que falta em "No ___, criou Deus o céu e a terra"?',
            ok="Exato: princípio.",
            wrong={"a": "Semente pertence a 3:15.", "c": "Bênção pertence a 12:2."},
            options=opts(("a", "semente"), ("b", "princípio"), ("c", "bênção")),
            correct="b",
            template="No ___, criou Deus o céu e a terra",
        ),
        dict(
            diff="profundezas", skill="interpret", type="choice", nn="03",
            question="Que leitura teológica Gênesis 1:1; 3:15; 12:2 prepara sobre Gênesis 1–11?",
            ok="Certo: Deus cria, promete vitória e chama Abrão à bênção.",
            wrong={
                "a": "Há esperança e bênção no arco.",
                "c": "A semente não é esquecida.",
                "d": "Abrão recebe nome e bênção de Deus.",
            },
            options=opts(
                ("a", "História sem esperança após a queda"),
                ("b", "Criação, semente prometida e bênção"),
                ("c", "Semente esquecida no juízo"),
                ("d", "Abrão fazendo o nome como Babel"),
            ),
            correct="b",
        ),
        dict(
            diff="profundezas", skill="interpret", type="order", nn="04",
            question="Qual sequência revela o sentido de Gênesis 1:1; 3:15; 12:2?",
            ok="Certo: origem, esperança e chamado à bênção.",
            wrong={"b": "Ordene pelo sentido do arco.", "c": "O chamado fecha."},
            options=opts(
                ("a", "Deus cria no princípio"),
                ("b", "Deus promete a semente vitoriosa"),
                ("c", "Deus abençoa Abrão para ser bênção"),
            ),
            correct="a", correctOrder=["a", "b", "c"],
        ),
        dict(
            diff="profundezas", skill="interpret", type="complete", nn="05",
            question='Complete Gênesis 12:2: "farei de ti uma grande ___"',
            ok="Certo: uma grande nação.",
            wrong={"a": "Bênção fecha o versículo.", "c": "Cabeça pertence a 3:15."},
            options=opts(("a", "bênção"), ("b", "nação"), ("c", "cabeça")),
            correct="b",
            template="farei de ti uma grande ___",
        ),
        dict(
            diff="profundezas", skill="interpret", type="connect", nn="06",
            question="O que Gênesis 1:1; 3:15; 12:2 comunica que se liga a este contexto?",
            ok="Certo: o leitor une criação, semente e bênção a Abrão.",
            wrong={"b": "Há criação no arco.", "c": "Há bênção prometida."},
            options=opts(
                ("a", "Criação, semente e bênção a Abrão"),
                ("b", "Arco sem criação"),
                ("c", "Arco sem bênção prometida"),
            ),
            correct="a",
            passageA={"ref": "Gênesis 1:1; 3:15; 12:2", "text": "criou Deus… ferirá a cabeça… Sê tu uma bênção"},
            passageB={"ref": "Contexto", "text": "Gênesis 1–11: criação, semente prometida e bênção a Abrão."},
        ),
    ],
)

# Fix accidental set syntax in M13 tap wrong feedback if any — validate below
assert len(bank) == 252, len(bank)

OUT.write_text(json.dumps(bank, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {OUT} with {len(bank)} questions")
