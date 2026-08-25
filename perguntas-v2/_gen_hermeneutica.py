#!/usr/bin/env python3
"""Generate perguntas-v2/hermeneutica.json (72 questions)."""
import json
from copy import deepcopy

TRAIL = "hermeneutica"

NE8 = (
    "Leram no livro da lei de Deus distintamente; e deram o sentido, "
    "de modo que se entendesse a leitura."
)
PE2 = (
    "conhecendo primeiro isto, que nenhuma profecia da Escritura é de "
    "particular interpretação, porque a profecia jamais foi dada pela "
    "vontade dos homens, mas os homens da parte de Deus falavam, "
    "movidos pelo Espírito Santo."
)
LC24 = (
    "Começando por Moisés e por todos os profetas, explicou-lhes o que "
    "dele se achava dito em todas as Escrituras."
)
BOSS = f"{NE8} {LC24}"

TF = [{"id": "true", "text": "Verdadeiro"}, {"id": "false", "text": "Falso"}]


def opts(*pairs):
    return [{"id": i, "text": t} for i, t in pairs]


def q(
    section,
    short,
    nn,
    difficulty,
    skill,
    qtype,
    verse_ref,
    lo,
    evidence,
    text,
    fb_ok,
    fb_wrong,
    passage,
    *,
    template=None,
    options=None,
    correct="a",
    correct_order=None,
    passage_a=None,
    passage_b=None,
):
    item = {
        "difficulty": difficulty,
        "skill": skill,
        "verseRef": verse_ref,
        "learningObjective": lo,
        "evidence": evidence,
        "type": qtype,
        "question": text,
        "prompt": text,
        "cue": text,
        "feedbackCorrect": fb_ok,
        "feedbackWrong": fb_wrong,
        "passageText": passage,
        "trail": TRAIL,
        "section": section,
        "id": f"{TRAIL}-{short}-{section}-{nn}",
        "options": options,
        "correctOptionId": correct,
        "correctAnswer": correct,
    }
    if template:
        item["template"] = template
    if correct_order:
        item["correctOrder"] = correct_order
    if passage_a:
        item["passageA"] = passage_a
    if passage_b:
        item["passageB"] = passage_b
    return item


def mission(section, verse, lo, evidence, passage, items):
    out = []
    for it in items:
        kwargs = deepcopy(it)
        kwargs.update(
            section=section,
            verse_ref=verse,
            lo=lo,
            evidence=evidence,
            passage=passage,
        )
        out.append(q(**kwargs))
    return out


# ---------------------------------------------------------------------------
# M1 hm-01-leitura
# ---------------------------------------------------------------------------
LO1 = (
    "Reconhecer que ler a Lei inclui clareza e sentido, "
    "para que o povo entenda, não só ouça o som."
)
M1 = []
base1 = dict(
    section="hm-01-leitura",
    verse="Neemias 8:8",
    lo=LO1,
    evidence=["Neemias 8:8"],
    passage=NE8,
)

M1 += mission(
    **base1,
    items=[
        dict(
            short="sem",
            nn="01",
            difficulty="semente",
            skill="observe",
            qtype="true_false",
            text="Leram no livro da lei de Deus distintamente.",
            fb_ok="Certo: Neemias 8:8 registra a leitura distinta da Lei.",
            fb_wrong={"false": "O texto começa exatamente com essa leitura distinta."},
            options=TF,
            correct="true",
        ),
        dict(
            short="sem",
            nn="02",
            difficulty="semente",
            skill="observe",
            qtype="tap",
            text='Em Neemias 8:8, toque a palavra que falta em "Leram no livro da lei de Deus ___; e deram o sentido"?',
            fb_ok="Exato: leram distintamente, com clareza.",
            fb_wrong={
                "b": "Sentido vem depois: deram o sentido.",
                "c": "Leitura fecha o versículo, não esta lacuna.",
            },
            template="Leram no livro da lei de Deus ___; e deram o sentido",
            options=opts(("a", "distintamente"), ("b", "sentido"), ("c", "leitura")),
            correct="a",
        ),
        dict(
            short="sem",
            nn="03",
            difficulty="semente",
            skill="observe",
            qtype="choice",
            text="O que Neemias 8:8 afirma que aconteceu depois da leitura distinta?",
            fb_ok="Certo: deram o sentido para que se entendesse a leitura.",
            fb_wrong={
                "a": "O texto não fala de fechar o livro sem explicar.",
                "c": "Não há menção a traduzir para outra língua aqui.",
                "d": "O versículo não descreve um debate entre partidos.",
            },
            options=opts(
                ("a", "Guardaram o livro sem explicar o que foi lido."),
                ("b", "Deram o sentido, de modo que se entendesse a leitura."),
                ("c", "Traduziram a Lei para uma língua estrangeira nova."),
                ("d", "Dividiram o povo em grupos a favor e contra a Lei."),
            ),
            correct="b",
        ),
        dict(
            short="sem",
            nn="04",
            difficulty="semente",
            skill="observe",
            qtype="order",
            text="Qual sequência mostra a ordem dos fatos em Neemias 8:8?",
            fb_ok="Certo: ler, dar o sentido, e o povo entender.",
            fb_wrong={
                "b": "Essa peça não vem primeiro no versículo.",
                "c": "Releia: o entendimento é o resultado, não o início.",
            },
            options=opts(
                ("a", "Leram no livro da lei de Deus distintamente"),
                ("b", "e deram o sentido"),
                ("c", "de modo que se entendesse a leitura"),
            ),
            correct="a",
            correct_order=["a", "b", "c"],
        ),
        dict(
            short="sem",
            nn="05",
            difficulty="semente",
            skill="observe",
            qtype="complete",
            text='Complete: "e deram o ___, de modo que se entendesse a leitura."',
            fb_ok="Certo: deram o sentido da leitura.",
            fb_wrong={
                "b": "Livro é o suporte da Lei, não o que eles deram.",
                "c": "Deus é o autor da Lei, não esta lacuna.",
            },
            template="e deram o ___, de modo que se entendesse a leitura.",
            options=opts(("a", "sentido"), ("b", "livro"), ("c", "Deus")),
            correct="a",
        ),
        dict(
            short="sem",
            nn="06",
            difficulty="semente",
            skill="observe",
            qtype="connect",
            text="O que Neemias 8:8 comunica que se liga a este contexto?",
            fb_ok="Certo: ler com atenção é clareza e sentido.",
            fb_wrong={
                "b": "O texto não reduz a Lei a um rito sem entendimento.",
                "c": "Não se trata de volume da voz, mas de sentido dado.",
            },
            options=opts(
                ("a", "Clareza e sentido juntos"),
                ("b", "Rito sem entendimento"),
                ("c", "Som alto sem explicação"),
            ),
            correct="a",
            passage_a={"ref": "Neemias 8:8", "text": NE8},
            passage_b={
                "ref": "Contexto",
                "text": "Ler com atenção é ler distintamente e dar o sentido — a Palavra pede entendimento, não só som.",
            },
        ),
        dict(
            short="cam",
            nn="01",
            difficulty="caminhada",
            skill="understand",
            qtype="true_false",
            text="Em Neemias 8:8, a leitura distinta da Lei dispensa dar o sentido ao povo.",
            fb_ok="Certo: o texto une leitura distinta e sentido dado.",
            fb_wrong={"true": "O versículo liga as duas ações: leram e deram o sentido."},
            options=TF,
            correct="false",
        ),
        dict(
            short="cam",
            nn="02",
            difficulty="caminhada",
            skill="understand",
            qtype="tap",
            text='Em Neemias 8:8, toque a palavra que falta em "de modo que se ___ a leitura"?',
            fb_ok="Exato: o alvo é que se entendesse a leitura.",
            fb_wrong={
                "a": "Distintamente descreve como leram, não esta lacuna.",
                "c": "Deram é o verbo anterior, não o que se pede aqui.",
            },
            template="de modo que se ___ a leitura",
            options=opts(("a", "distintamente"), ("b", "entendesse"), ("c", "deram")),
            correct="b",
        ),
        dict(
            short="cam",
            nn="03",
            difficulty="caminhada",
            skill="understand",
            qtype="choice",
            text="Como se relacionam leitura distinta e sentido em Neemias 8:8?",
            fb_ok="Certo: o sentido serve para que a leitura seja entendida.",
            fb_wrong={
                "a": "O texto não opõe clareza e sentido; junta os dois.",
                "c": "Não há indício de que o sentido seja opcional.",
                "d": "O versículo não descreve um debate privado de escribas.",
            },
            options=opts(
                ("a", "A clareza da voz substitui qualquer explicação do texto."),
                ("b", "O sentido é dado para que a leitura distinta seja entendida."),
                ("c", "O sentido só vale se o povo já conhecer a Lei de cor."),
                ("d", "O sentido fica restrito aos escribas, sem o povo."),
            ),
            correct="b",
        ),
        dict(
            short="cam",
            nn="04",
            difficulty="caminhada",
            skill="understand",
            qtype="order",
            text="Como se encadeiam os eventos de Neemias 8:8?",
            fb_ok="Certo: do livro lido ao sentido, até o entendimento.",
            fb_wrong={
                "b": "Essa peça não ocupa esse lugar na cadeia.",
                "c": "Releia o encadeamento: entendimento vem no fim.",
            },
            options=opts(
                ("a", "a leitura distinta no livro da lei de Deus"),
                ("b", "o sentido dado ao que foi lido"),
                ("c", "o entendimento alcançado pelo ouvinte"),
            ),
            correct="a",
            correct_order=["a", "b", "c"],
        ),
        dict(
            short="cam",
            nn="05",
            difficulty="caminhada",
            skill="understand",
            qtype="complete",
            text='Complete: "Leram no livro da ___ de Deus distintamente."',
            fb_ok="Certo: leram no livro da lei de Deus.",
            fb_wrong={
                "b": "Leitura é o ato, não o conteúdo do livro.",
                "c": "Sentido é o que deram depois, não o livro.",
            },
            template="Leram no livro da ___ de Deus distintamente.",
            options=opts(("a", "lei"), ("b", "leitura"), ("c", "sentido")),
            correct="a",
        ),
        dict(
            short="cam",
            nn="06",
            difficulty="caminhada",
            skill="understand",
            qtype="connect",
            text="O que Neemias 8:8 comunica que se liga a este contexto?",
            fb_ok="Certo: a Palavra pede entendimento, não só som.",
            fb_wrong={
                "a": "O texto não celebra o som isolado da voz.",
                "c": "Não há aqui uma leitura só para especialistas.",
            },
            options=opts(
                ("a", "Som sem entendimento"),
                ("b", "Palavra que pede entendimento"),
                ("c", "Leitura só para especialistas"),
            ),
            correct="b",
            passage_a={"ref": "Neemias 8:8", "text": NE8},
            passage_b={
                "ref": "Contexto",
                "text": "A hermenêutica começa quando o texto é lido com clareza e o sentido é dado ao povo.",
            },
        ),
        dict(
            short="pro",
            nn="01",
            difficulty="profundezas",
            skill="interpret",
            qtype="true_false",
            text="Neemias 8:8 mostra que a Palavra pede entendimento, não apenas o som da leitura.",
            fb_ok="Certo: dar o sentido visa que se entenda a leitura.",
            fb_wrong={"false": "O versículo liga leitura distinta ao entendimento do povo."},
            options=TF,
            correct="true",
        ),
        dict(
            short="pro",
            nn="02",
            difficulty="profundezas",
            skill="interpret",
            qtype="tap",
            text='Em Neemias 8:8, toque a palavra que falta em "Leram no ___ da lei de Deus distintamente"?',
            fb_ok="Exato: leram no livro da lei.",
            fb_wrong={
                "b": "Sentido é o que deram, não o suporte da leitura.",
                "c": "Leitura é o ato; a lacuna pede o livro.",
            },
            template="Leram no ___ da lei de Deus distintamente",
            options=opts(("a", "livro"), ("b", "sentido"), ("c", "leitura")),
            correct="a",
        ),
        dict(
            short="pro",
            nn="03",
            difficulty="profundezas",
            skill="interpret",
            qtype="choice",
            text="Que implicação hermenêutica Neemias 8:8 sustenta?",
            fb_ok="Certo: fidelidade inclui clareza e sentido ao ouvinte.",
            fb_wrong={
                "a": "O texto não trata a Lei como código secreto.",
                "c": "Não se reduz a Palavra a um espetáculo vocal.",
                "d": "O versículo não autoriza ignorar o sentido do texto.",
            },
            options=opts(
                ("a", "A Lei deve ficar reservada a um círculo iniciado."),
                ("b", "Ler fielmente inclui clareza e sentido ao ouvinte."),
                ("c", "O que importa é a beleza da recitação, não o sentido."),
                ("d", "Cada um inventa o sentido depois de ouvir o som."),
            ),
            correct="b",
        ),
        dict(
            short="pro",
            nn="04",
            difficulty="profundezas",
            skill="interpret",
            qtype="order",
            text="Qual sequência revela o sentido de Neemias 8:8?",
            fb_ok="Certo: do texto lido ao sentido, até o entendimento.",
            fb_wrong={
                "b": "Essa etapa não ocupa esse lugar no sentido do texto.",
                "c": "O entendimento é o fim da sequência, não o começo.",
            },
            options=opts(
                ("a", "o texto da Lei lido com clareza"),
                ("b", "o sentido comunicado ao povo"),
                ("c", "o entendimento como meta da leitura"),
            ),
            correct="a",
            correct_order=["a", "b", "c"],
        ),
        dict(
            short="pro",
            nn="05",
            difficulty="profundezas",
            skill="interpret",
            qtype="complete",
            text='Complete: "e ___ o sentido, de modo que se entendesse a leitura."',
            fb_ok="Certo: deram o sentido.",
            fb_wrong={
                "b": "Leram descreve a primeira ação, não esta lacuna.",
                "c": "Entendesse é o resultado, não o verbo desta frase.",
            },
            template="e ___ o sentido, de modo que se entendesse a leitura.",
            options=opts(("a", "deram"), ("b", "Leram"), ("c", "entendesse")),
            correct="a",
        ),
        dict(
            short="pro",
            nn="06",
            difficulty="profundezas",
            skill="interpret",
            qtype="connect",
            text="O que Neemias 8:8 comunica que se liga a este contexto?",
            fb_ok="Certo: hermenêutica serve o entendimento do povo.",
            fb_wrong={
                "a": "O texto não privilegia o prestígio do leitor.",
                "c": "Não se trata de esconder o sentido da Lei.",
            },
            options=opts(
                ("a", "Prestígio do leitor"),
                ("b", "Entendimento do povo"),
                ("c", "Segredo da Lei"),
            ),
            correct="b",
            passage_a={"ref": "Neemias 8:8", "text": NE8},
            passage_b={
                "ref": "Contexto",
                "text": "A Palavra não pede só recitação: pede sentido dado, para que a leitura seja entendida.",
            },
        ),
    ],
)

# ---------------------------------------------------------------------------
# M2 hm-02-contexto
# ---------------------------------------------------------------------------
LO2 = (
    "Perceber que nenhuma profecia da Escritura é de particular interpretação: "
    "homens falaram da parte de Deus, movidos pelo Espírito."
)
base2 = dict(
    section="hm-02-contexto",
    verse="2 Pedro 1:20–21",
    lo=LO2,
    evidence=["2 Pedro 1:20", "2 Pedro 1:21"],
    passage=PE2,
)

M2 = mission(
    **base2,
    items=[
        dict(
            short="sem",
            nn="01",
            difficulty="semente",
            skill="observe",
            qtype="true_false",
            text="Nenhuma profecia da Escritura é de particular interpretação.",
            fb_ok="Certo: 2 Pedro 1:20 afirma exatamente isso.",
            fb_wrong={"false": "O texto diz que nenhuma profecia é de particular interpretação."},
            options=TF,
            correct="true",
        ),
        dict(
            short="sem",
            nn="02",
            difficulty="semente",
            skill="observe",
            qtype="tap",
            text='Em 2 Pedro 1:20–21, toque a palavra que falta em "nenhuma profecia da Escritura é de particular ___"?',
            fb_ok="Exato: não é de particular interpretação.",
            fb_wrong={
                "b": "Vontade aparece depois, ligada aos homens.",
                "c": "Profecia é o sujeito, não esta lacuna.",
            },
            template="nenhuma profecia da Escritura é de particular ___",
            options=opts(("a", "interpretação"), ("b", "vontade"), ("c", "profecia")),
            correct="a",
        ),
        dict(
            short="sem",
            nn="03",
            difficulty="semente",
            skill="observe",
            qtype="choice",
            text="Segundo 2 Pedro 1:20–21, de onde a profecia jamais veio?",
            fb_ok="Certo: jamais foi dada pela vontade dos homens.",
            fb_wrong={
                "a": "O texto não atribui a profecia a um concílio.",
                "c": "Não há menção a sonhos particulares aqui.",
                "d": "O versículo não fala de tradição oral isolada.",
            },
            options=opts(
                ("a", "De um concílio de anciãos em Jerusalém."),
                ("b", "Da vontade dos homens."),
                ("c", "De sonhos particulares sem Escritura."),
                ("d", "De uma tradição oral sem profetas."),
            ),
            correct="b",
        ),
        dict(
            short="sem",
            nn="04",
            difficulty="semente",
            skill="observe",
            qtype="order",
            text="Qual sequência mostra a ordem dos fatos em 2 Pedro 1:20–21?",
            fb_ok="Certo: não é particular; não vem da vontade humana; o Espírito move.",
            fb_wrong={
                "b": "Essa peça não vem nesse lugar no texto.",
                "c": "Releia: o Espírito Santo fecha o versículo.",
            },
            options=opts(
                ("a", "nenhuma profecia da Escritura é de particular interpretação"),
                ("b", "a profecia jamais foi dada pela vontade dos homens"),
                ("c", "os homens da parte de Deus falavam, movidos pelo Espírito Santo"),
            ),
            correct="a",
            correct_order=["a", "b", "c"],
        ),
        dict(
            short="sem",
            nn="05",
            difficulty="semente",
            skill="observe",
            qtype="complete",
            text='Complete: "os homens da parte de Deus falavam, movidos pelo ___ Santo."',
            fb_ok="Certo: movidos pelo Espírito Santo.",
            fb_wrong={
                "b": "Homens falam, mas o agente aqui é o Espírito.",
                "c": "Escritura é o objeto da profecia, não esta lacuna.",
            },
            template="os homens da parte de Deus falavam, movidos pelo ___ Santo.",
            options=opts(("a", "Espírito"), ("b", "homens"), ("c", "Escritura")),
            correct="a",
        ),
        dict(
            short="sem",
            nn="06",
            difficulty="semente",
            skill="observe",
            qtype="connect",
            text="O que 2 Pedro 1:20–21 comunica que se liga a este contexto?",
            fb_ok="Certo: a Escritura não é interpretação particular.",
            fb_wrong={
                "b": "O texto nega a origem na vontade humana solitária.",
                "c": "Não se trata de opinião privada sobre o texto.",
            },
            options=opts(
                ("a", "Não é interpretação particular"),
                ("b", "Origem na vontade humana"),
                ("c", "Opinião privada do leitor"),
            ),
            correct="a",
            passage_a={"ref": "2 Pedro 1:20–21", "text": PE2},
            passage_b={
                "ref": "Contexto",
                "text": "Texto e contexto: a Escritura não é interpretação particular; homens falaram movidos pelo Espírito.",
            },
        ),
        dict(
            short="cam",
            nn="01",
            difficulty="caminhada",
            skill="understand",
            qtype="true_false",
            text="Em 2 Pedro 1:20–21, a profecia da Escritura nasce da vontade isolada dos homens.",
            fb_ok="Certo: jamais foi dada pela vontade dos homens.",
            fb_wrong={"true": "O texto opõe vontade humana ao falar movido pelo Espírito."},
            options=TF,
            correct="false",
        ),
        dict(
            short="cam",
            nn="02",
            difficulty="caminhada",
            skill="understand",
            qtype="tap",
            text='Em 2 Pedro 1:20–21, toque a palavra que falta em "a profecia jamais foi dada pela ___ dos homens"?',
            fb_ok="Exato: não foi dada pela vontade dos homens.",
            fb_wrong={
                "a": "Interpretação aparece no v. 20, não nesta lacuna.",
                "c": "Escritura nomeia o escrito, não esta lacuna.",
            },
            template="a profecia jamais foi dada pela ___ dos homens",
            options=opts(("a", "interpretação"), ("b", "vontade"), ("c", "Escritura")),
            correct="b",
        ),
        dict(
            short="cam",
            nn="03",
            difficulty="caminhada",
            skill="understand",
            qtype="choice",
            text="Como 2 Pedro 1:20–21 liga origem da profecia e modo de lê-la?",
            fb_ok="Certo: origem no Espírito impede leitura particularista.",
            fb_wrong={
                "a": "O texto não autoriza cada um a inventar o sentido.",
                "c": "Não reduz a profecia a um relatório humano comum.",
                "d": "O versículo não pede ignorar o texto em favor do sentimento.",
            },
            options=opts(
                ("a", "Cada leitor pode isolar um versículo e dar-lhe sentido próprio."),
                ("b", "Como veio do Espírito, não se lê como opinião particular."),
                ("c", "A profecia vale só como memória histórica dos autores."),
                ("d", "O sentimento do leitor substitui o que os homens falaram."),
            ),
            correct="b",
        ),
        dict(
            short="cam",
            nn="04",
            difficulty="caminhada",
            skill="understand",
            qtype="order",
            text="Como se encadeiam os eventos de 2 Pedro 1:20–21?",
            fb_ok="Certo: da recusa do particular à origem no Espírito.",
            fb_wrong={
                "b": "Essa etapa não ocupa esse lugar no encadeamento.",
                "c": "O falar movido pelo Espírito é o desfecho, não o início.",
            },
            options=opts(
                ("a", "conhecer primeiro que a profecia não é particular"),
                ("b", "recusar a origem na vontade dos homens"),
                ("c", "afirmar o falar movido pelo Espírito Santo"),
            ),
            correct="a",
            correct_order=["a", "b", "c"],
        ),
        dict(
            short="cam",
            nn="05",
            difficulty="caminhada",
            skill="understand",
            qtype="complete",
            text='Complete: "nenhuma ___ da Escritura é de particular interpretação."',
            fb_ok="Certo: nenhuma profecia da Escritura.",
            fb_wrong={
                "b": "Vontade aparece no v. 21, não nesta lacuna.",
                "c": "Homens falam, mas o sujeito aqui é a profecia.",
            },
            template="nenhuma ___ da Escritura é de particular interpretação.",
            options=opts(("a", "profecia"), ("b", "vontade"), ("c", "homens")),
            correct="a",
        ),
        dict(
            short="cam",
            nn="06",
            difficulty="caminhada",
            skill="understand",
            qtype="connect",
            text="O que 2 Pedro 1:20–21 comunica que se liga a este contexto?",
            fb_ok="Certo: contexto guarda o texto da leitura particular.",
            fb_wrong={
                "a": "O texto não celebra o versículo isolado.",
                "c": "Não autoriza o leitor a ser dono do sentido.",
            },
            options=opts(
                ("a", "Versículo solto basta"),
                ("b", "Contexto contra leitura particular"),
                ("c", "Leitor dono do sentido"),
            ),
            correct="b",
            passage_a={"ref": "2 Pedro 1:20–21", "text": PE2},
            passage_b={
                "ref": "Contexto",
                "text": "Um versículo ganha sentido no conjunto da Escritura, não como interpretação particular.",
            },
        ),
        dict(
            short="pro",
            nn="01",
            difficulty="profundezas",
            skill="interpret",
            qtype="true_false",
            text="2 Pedro 1:20–21 ensina que o sentido da Escritura não pertence ao capricho particular do leitor.",
            fb_ok="Certo: a profecia não é de particular interpretação.",
            fb_wrong={"false": "O texto recusa a interpretação particular da profecia."},
            options=TF,
            correct="true",
        ),
        dict(
            short="pro",
            nn="02",
            difficulty="profundezas",
            skill="interpret",
            qtype="tap",
            text='Em 2 Pedro 1:20–21, toque a palavra que falta em "os homens da parte de Deus falavam, ___ pelo Espírito Santo"?',
            fb_ok="Exato: falavam movidos pelo Espírito Santo.",
            fb_wrong={
                "a": "Conhecendo abre o trecho, não esta lacuna.",
                "c": "Jamais nega a origem humana, não completa este verbo.",
            },
            template="os homens da parte de Deus falavam, ___ pelo Espírito Santo",
            options=opts(("a", "conhecendo"), ("b", "movidos"), ("c", "jamais")),
            correct="b",
        ),
        dict(
            short="pro",
            nn="03",
            difficulty="profundezas",
            skill="interpret",
            qtype="choice",
            text="Que erro de leitura 2 Pedro 1:20–21 corrige?",
            fb_ok="Certo: recusa tratar a profecia como opinião particular.",
            fb_wrong={
                "a": "O texto não apaga os homens; eles falaram movidos.",
                "c": "Não reduz a Escritura a um código cifrado sem sentido.",
                "d": "Não transfere a autoridade da Escritura ao humor do grupo.",
            },
            options=opts(
                ("a", "Negar que homens reais tenham falado da parte de Deus."),
                ("b", "Tratar a profecia como opinião particular do intérprete."),
                ("c", "Afirmar que a Escritura não tem sentido comunicável."),
                ("d", "Substituir o texto pelo consenso do grupo no momento."),
            ),
            correct="b",
        ),
        dict(
            short="pro",
            nn="04",
            difficulty="profundezas",
            skill="interpret",
            qtype="order",
            text="Qual sequência revela o sentido de 2 Pedro 1:20–21?",
            fb_ok="Certo: origem divina, recusa do particular, fala no Espírito.",
            fb_wrong={
                "b": "Essa etapa não revela o sentido nesta ordem.",
                "c": "O falar no Espírito é o desfecho da sequência.",
            },
            options=opts(
                ("a", "a profecia não nasce da vontade humana"),
                ("b", "por isso não se lê como interpretação particular"),
                ("c", "homens falaram da parte de Deus no Espírito"),
            ),
            correct="a",
            correct_order=["a", "b", "c"],
        ),
        dict(
            short="pro",
            nn="05",
            difficulty="profundezas",
            skill="interpret",
            qtype="complete",
            text='Complete: "nenhuma profecia da Escritura é de ___ interpretação."',
            fb_ok="Certo: não é de particular interpretação.",
            fb_wrong={
                "b": "Primeiro introduz o aviso, não esta lacuna.",
                "c": "Santo qualifica o Espírito, não a interpretação.",
            },
            template="nenhuma profecia da Escritura é de ___ interpretação.",
            options=opts(("a", "particular"), ("b", "primeiro"), ("c", "Santo")),
            correct="a",
        ),
        dict(
            short="pro",
            nn="06",
            difficulty="profundezas",
            skill="interpret",
            qtype="connect",
            text="O que 2 Pedro 1:20–21 comunica que se liga a este contexto?",
            fb_ok="Certo: o Espírito guarda a Palavra da leitura particular.",
            fb_wrong={
                "a": "O texto não faz do leitor o dono da profecia.",
                "c": "Não reduz a Escritura a um ditado mecânico sem homens.",
            },
            options=opts(
                ("a", "Leitor dono da profecia"),
                ("b", "Espírito e texto juntos"),
                ("c", "Homens mudos, só ditado"),
            ),
            correct="b",
            passage_a={"ref": "2 Pedro 1:20–21", "text": PE2},
            passage_b={
                "ref": "Contexto",
                "text": "Hermenêutica fiel ouve homens que falaram da parte de Deus, não o capricho particular.",
            },
        ),
    ],
)

# ---------------------------------------------------------------------------
# M3 hm-03-cristo
# ---------------------------------------------------------------------------
LO3 = (
    "Ver que Jesus, começando por Moisés e pelos profetas, explica o que "
    "dele se achava dito em todas as Escrituras."
)
base3 = dict(
    section="hm-03-cristo",
    verse="Lucas 24:27",
    lo=LO3,
    evidence=["Lucas 24:27"],
    passage=LC24,
)

M3 = mission(
    **base3,
    items=[
        dict(
            short="sem",
            nn="01",
            difficulty="semente",
            skill="observe",
            qtype="true_false",
            text="Começando por Moisés e por todos os profetas, explicou-lhes o que dele se achava dito em todas as Escrituras.",
            fb_ok="Certo: Lucas 24:27 registra exatamente essa explicação.",
            fb_wrong={"false": "O versículo começa por Moisés e os profetas e aponta para ele."},
            options=TF,
            correct="true",
        ),
        dict(
            short="sem",
            nn="02",
            difficulty="semente",
            skill="observe",
            qtype="tap",
            text='Em Lucas 24:27, toque a palavra que falta em "Começando por ___ e por todos os profetas"?',
            fb_ok="Exato: começando por Moisés.",
            fb_wrong={
                "b": "Profetas vêm depois de Moisés neste trecho.",
                "c": "Escrituras fecha o versículo, não esta lacuna.",
            },
            template="Começando por ___ e por todos os profetas",
            options=opts(("a", "Moisés"), ("b", "profetas"), ("c", "Escrituras")),
            correct="a",
        ),
        dict(
            short="sem",
            nn="03",
            difficulty="semente",
            skill="observe",
            qtype="choice",
            text="O que Jesus explicou a partir de Moisés e dos profetas, segundo Lucas 24:27?",
            fb_ok="Certo: o que dele se achava dito em todas as Escrituras.",
            fb_wrong={
                "a": "O texto não fala de calendário de festas.",
                "c": "Não há aqui uma lista de reis de Israel.",
                "d": "O versículo não descreve regras de jejum.",
            },
            options=opts(
                ("a", "O calendário das festas de Israel no deserto."),
                ("b", "O que dele se achava dito em todas as Escrituras."),
                ("c", "A lista dos reis de Israel até Davi."),
                ("d", "As regras de jejum dos fariseus."),
            ),
            correct="b",
        ),
        dict(
            short="sem",
            nn="04",
            difficulty="semente",
            skill="observe",
            qtype="order",
            text="Qual sequência mostra a ordem dos fatos em Lucas 24:27?",
            fb_ok="Certo: começa por Moisés e os profetas, explica o que é dele.",
            fb_wrong={
                "b": "Essa peça não vem primeiro no versículo.",
                "c": "Releia: as Escrituras fecham a frase.",
            },
            options=opts(
                ("a", "Começando por Moisés e por todos os profetas"),
                ("b", "explicou-lhes o que dele se achava dito"),
                ("c", "em todas as Escrituras"),
            ),
            correct="a",
            correct_order=["a", "b", "c"],
        ),
        dict(
            short="sem",
            nn="05",
            difficulty="semente",
            skill="observe",
            qtype="complete",
            text='Complete: "explicou-lhes o que dele se achava dito em todas as ___."',
            fb_ok="Certo: em todas as Escrituras.",
            fb_wrong={
                "b": "Moisés é o ponto de partida, não esta lacuna.",
                "c": "Profetas acompanham Moisés, não fecham a frase.",
            },
            template="explicou-lhes o que dele se achava dito em todas as ___.",
            options=opts(("a", "Escrituras"), ("b", "Moisés"), ("c", "profetas")),
            correct="a",
        ),
        dict(
            short="sem",
            nn="06",
            difficulty="semente",
            skill="observe",
            qtype="connect",
            text="O que Lucas 24:27 comunica que se liga a este contexto?",
            fb_ok="Certo: Moisés e os profetas falam dele.",
            fb_wrong={
                "b": "O texto não trata Cristo como tema opcional.",
                "c": "Não se limita a um único livro isolado.",
            },
            options=opts(
                ("a", "Moisés e profetas falam dele"),
                ("b", "Cristo como tema opcional"),
                ("c", "Um livro isolado basta"),
            ),
            correct="a",
            passage_a={"ref": "Lucas 24:27", "text": LC24},
            passage_b={
                "ref": "Contexto",
                "text": "Cristo no centro: Moisés e os profetas falam dele — hermenêutica que encontra Jesus nas Escrituras.",
            },
        ),
        dict(
            short="cam",
            nn="01",
            difficulty="caminhada",
            skill="understand",
            qtype="true_false",
            text="Em Lucas 24:27, Jesus começa a explicação pelos salmos e deixa Moisés de lado.",
            fb_ok="Certo: o texto diz que começou por Moisés e por todos os profetas.",
            fb_wrong={"true": "Lucas 24:27 começa explicitamente por Moisés e os profetas."},
            options=TF,
            correct="false",
        ),
        dict(
            short="cam",
            nn="02",
            difficulty="caminhada",
            skill="understand",
            qtype="tap",
            text='Em Lucas 24:27, toque a palavra que falta em "explicou-lhes o que ___ se achava dito"?',
            fb_ok="Exato: o que dele se achava dito.",
            fb_wrong={
                "a": "Começando abre o versículo, não esta lacuna.",
                "c": "Todos qualifica os profetas, não esta lacuna.",
            },
            template="explicou-lhes o que ___ se achava dito",
            options=opts(("a", "Começando"), ("b", "dele"), ("c", "todos")),
            correct="b",
        ),
        dict(
            short="cam",
            nn="03",
            difficulty="caminhada",
            skill="understand",
            qtype="choice",
            text="Como Lucas 24:27 relaciona Lei, profetas e Jesus?",
            fb_ok="Certo: Lei e profetas são o palco onde se acha o que é dele.",
            fb_wrong={
                "a": "O texto não trata Moisés como contrário a Jesus.",
                "c": "Não reduz a explicação a um único versículo isolado.",
                "d": "Não apresenta os profetas como testemunhas contra ele.",
            },
            options=opts(
                ("a", "Moisés corrige Jesus, e os profetas ficam de fora."),
                ("b", "Lei e profetas mostram o que se achava dito a respeito dele."),
                ("c", "Só um versículo messiânico isolado recebe explicação."),
                ("d", "Os profetas falam contra ele, e Moisés permanece neutro."),
            ),
            correct="b",
        ),
        dict(
            short="cam",
            nn="04",
            difficulty="caminhada",
            skill="understand",
            qtype="order",
            text="Como se encadeiam os eventos de Lucas 24:27?",
            fb_ok="Certo: da Lei e dos profetas à explicação do que é dele.",
            fb_wrong={
                "b": "Essa etapa não ocupa esse lugar no encadeamento.",
                "c": "O alcance em todas as Escrituras é o desfecho.",
            },
            options=opts(
                ("a", "partir de Moisés e de todos os profetas"),
                ("b", "explicar o que se achava dito a respeito dele"),
                ("c", "abranger todas as Escrituras"),
            ),
            correct="a",
            correct_order=["a", "b", "c"],
        ),
        dict(
            short="cam",
            nn="05",
            difficulty="caminhada",
            skill="understand",
            qtype="complete",
            text='Complete: "Começando por Moisés e por todos os ___, explicou-lhes."',
            fb_ok="Certo: por todos os profetas.",
            fb_wrong={
                "b": "Escrituras fecha o versículo, não esta lacuna.",
                "c": "Dele aponta para Jesus, não para este grupo.",
            },
            template="Começando por Moisés e por todos os ___, explicou-lhes.",
            options=opts(("a", "profetas"), ("b", "Escrituras"), ("c", "dele")),
            correct="a",
        ),
        dict(
            short="cam",
            nn="06",
            difficulty="caminhada",
            skill="understand",
            qtype="connect",
            text="O que Lucas 24:27 comunica que se liga a este contexto?",
            fb_ok="Certo: a Escritura inteira participa da história que aponta para ele.",
            fb_wrong={
                "a": "O texto não restringe Cristo a um único livro.",
                "c": "Não trata a Lei como palco vazio de Cristo.",
            },
            options=opts(
                ("a", "Cristo só num livro"),
                ("b", "Escrituras inteiras falam dele"),
                ("c", "Lei vazia de Cristo"),
            ),
            correct="b",
            passage_a={"ref": "Lucas 24:27", "text": LC24},
            passage_b={
                "ref": "Contexto",
                "text": "Toda a Bíblia participa da grande história que encontra seu centro em Cristo.",
            },
        ),
        dict(
            short="pro",
            nn="01",
            difficulty="profundezas",
            skill="interpret",
            qtype="true_false",
            text="Lucas 24:27 apresenta uma hermenêutica que encontra Jesus no conjunto das Escrituras, a partir de Moisés e dos profetas.",
            fb_ok="Certo: ele explica o que dele se achava dito em todas as Escrituras.",
            fb_wrong={"false": "O versículo une Moisés, profetas e todas as Escrituras a ele."},
            options=TF,
            correct="true",
        ),
        dict(
            short="pro",
            nn="02",
            difficulty="profundezas",
            skill="interpret",
            qtype="tap",
            text='Em Lucas 24:27, toque a palavra que falta em "o que dele se ___ dito em todas as Escrituras"?',
            fb_ok="Exato: o que dele se achava dito.",
            fb_wrong={
                "a": "Começando descreve o método, não esta lacuna.",
                "c": "Profetas nomeia as testemunhas, não o verbo aqui.",
            },
            template="o que dele se ___ dito em todas as Escrituras",
            options=opts(("a", "Começando"), ("b", "achava"), ("c", "profetas")),
            correct="b",
        ),
        dict(
            short="pro",
            nn="03",
            difficulty="profundezas",
            skill="interpret",
            qtype="choice",
            text="Que erro Lucas 24:27 impede na leitura da Bíblia?",
            fb_ok="Certo: impede tratar Cristo como alheio a Moisés e aos profetas.",
            fb_wrong={
                "a": "O texto não apaga Moisés; começa por ele.",
                "c": "Não reduz Jesus a um comentário moral avulso.",
                "d": "Não autoriza ignorar o Antigo Testamento.",
            },
            options=opts(
                ("a", "Apagar Moisés para ficar só com os evangelhos."),
                ("b", "Ler Moisés e os profetas como se não falassem dele."),
                ("c", "Tratar Jesus como mestre moral sem as Escrituras."),
                ("d", "Substituir a Bíblia por visões particulares."),
            ),
            correct="b",
        ),
        dict(
            short="pro",
            nn="04",
            difficulty="profundezas",
            skill="interpret",
            qtype="order",
            text="Qual sequência revela o sentido de Lucas 24:27?",
            fb_ok="Certo: da Lei e dos profetas ao Cristo em toda a Escritura.",
            fb_wrong={
                "b": "Essa etapa não revela o sentido nesta ordem.",
                "c": "O alcance em todas as Escrituras é o desfecho.",
            },
            options=opts(
                ("a", "partir da Lei e dos profetas"),
                ("b", "mostrar o que se achava dito a respeito dele"),
                ("c", "ler o conjunto das Escrituras com esse centro"),
            ),
            correct="a",
            correct_order=["a", "b", "c"],
        ),
        dict(
            short="pro",
            nn="05",
            difficulty="profundezas",
            skill="interpret",
            qtype="complete",
            text='Complete: "___, explicou-lhes o que dele se achava dito em todas as Escrituras."',
            fb_ok="Certo: Começando por Moisés e por todos os profetas.",
            fb_wrong={
                "b": "Escrituras é o alcance, não o gerúndio inicial.",
                "c": "Dele aponta para Jesus, não abre a frase.",
            },
            template="___ por Moisés e por todos os profetas, explicou-lhes o que dele se achava dito em todas as Escrituras.",
            options=opts(("a", "Começando"), ("b", "Escrituras"), ("c", "dele")),
            correct="a",
        ),
        dict(
            short="pro",
            nn="06",
            difficulty="profundezas",
            skill="interpret",
            qtype="connect",
            text="O que Lucas 24:27 comunica que se liga a este contexto?",
            fb_ok="Certo: hermenêutica cristã encontra Jesus nas Escrituras.",
            fb_wrong={
                "a": "O texto não coloca Cristo fora das Escrituras.",
                "c": "Não opõe a Lei ao Evangelho; começa por Moisés.",
            },
            options=opts(
                ("a", "Cristo fora da Escritura"),
                ("b", "Jesus no centro da leitura"),
                ("c", "Lei contra o Evangelho"),
            ),
            correct="b",
            passage_a={"ref": "Lucas 24:27", "text": LC24},
            passage_b={
                "ref": "Contexto",
                "text": "Hermenêutica que encontra Jesus nas Escrituras: Moisés e os profetas falam dele.",
            },
        ),
    ],
)

# ---------------------------------------------------------------------------
# M4 hm-boss
# ---------------------------------------------------------------------------
LO4 = (
    "Unir o sentido dado na leitura (Neemias 8:8) e Cristo em todas as "
    "Escrituras (Lucas 24:27) numa hermenêutica sábia."
)
base4 = dict(
    section="hm-boss",
    verse="Neemias 8:8; Lucas 24:27",
    lo=LO4,
    evidence=["Neemias 8:8", "Lucas 24:27"],
    passage=BOSS,
)

M4 = mission(
    **base4,
    items=[
        dict(
            short="sem",
            nn="01",
            difficulty="semente",
            skill="observe",
            qtype="true_false",
            text="Leram no livro da lei de Deus distintamente; e, começando por Moisés e por todos os profetas, explicou-lhes o que dele se achava dito em todas as Escrituras.",
            fb_ok="Certo: os dois trechos afirmam leitura com sentido e Cristo nas Escrituras.",
            fb_wrong={"false": "Neemias 8:8 e Lucas 24:27 sustentam essa leitura combinada."},
            options=TF,
            correct="true",
        ),
        dict(
            short="sem",
            nn="02",
            difficulty="semente",
            skill="observe",
            qtype="tap",
            text='Em Neemias 8:8; Lucas 24:27, toque a palavra que falta em "e deram o ___, de modo que se entendesse a leitura"?',
            fb_ok="Exato: deram o sentido.",
            fb_wrong={
                "b": "Moisés abre Lucas 24:27, não esta lacuna de Neemias.",
                "c": "Escrituras fecha Lucas 24:27, não esta lacuna.",
            },
            template="e deram o ___, de modo que se entendesse a leitura",
            options=opts(("a", "sentido"), ("b", "Moisés"), ("c", "Escrituras")),
            correct="a",
        ),
        dict(
            short="sem",
            nn="03",
            difficulty="semente",
            skill="observe",
            qtype="choice",
            text="O que os dois trechos afirmam juntos sobre a leitura da Escritura?",
            fb_ok="Certo: dão o sentido e mostram o que se achava dito dele.",
            fb_wrong={
                "a": "Os textos não descrevem uma leitura muda.",
                "c": "Não há aqui uma leitura só de genealogias.",
                "d": "O palco não é um debate sobre calendário.",
            },
            options=opts(
                ("a", "Leram em silêncio e guardaram o livro fechado."),
                ("b", "Deram o sentido e explicaram o que dele se achava dito."),
                ("c", "Leram apenas as genealogias, sem explicar nada."),
                ("d", "Discutiram o calendário das festas, sem a Lei."),
            ),
            correct="b",
        ),
        dict(
            short="sem",
            nn="04",
            difficulty="semente",
            skill="observe",
            qtype="order",
            text="Qual sequência mostra a ordem dos fatos em Neemias 8:8; Lucas 24:27?",
            fb_ok="Certo: ler com sentido e, então, ver Cristo nas Escrituras.",
            fb_wrong={
                "b": "Essa peça não vem nesse lugar na combinação dos textos.",
                "c": "Lucas 24:27 fecha o palco, não o abre.",
            },
            options=opts(
                ("a", "Leram no livro da lei de Deus distintamente"),
                ("b", "e deram o sentido, de modo que se entendesse a leitura"),
                ("c", "Começando por Moisés e por todos os profetas, explicou-lhes o que dele se achava dito em todas as Escrituras"),
            ),
            correct="a",
            correct_order=["a", "b", "c"],
        ),
        dict(
            short="sem",
            nn="05",
            difficulty="semente",
            skill="observe",
            qtype="complete",
            text='Complete: "Começando por Moisés e por todos os profetas, ___ o que dele se achava dito."',
            fb_ok="Certo: explicou-lhes o que dele se achava dito.",
            fb_wrong={
                "b": "Leram é o verbo de Neemias 8:8, não esta lacuna.",
                "c": "Deram o sentido está em Neemias, não neste verbo.",
            },
            template="Começando por Moisés e por todos os profetas, ___ o que dele se achava dito.",
            options=opts(("a", "explicou-lhes"), ("b", "Leram"), ("c", "deram")),
            correct="a",
        ),
        dict(
            short="sem",
            nn="06",
            difficulty="semente",
            skill="observe",
            qtype="connect",
            text="O que Neemias 8:8; Lucas 24:27 comunica que se liga a este contexto?",
            fb_ok="Certo: sentido da leitura e Cristo nas Escrituras.",
            fb_wrong={
                "b": "Os textos não celebram o som sem entendimento.",
                "c": "Não se trata de Cristo fora da Escritura.",
            },
            options=opts(
                ("a", "Sentido e Cristo juntos"),
                ("b", "Som sem entendimento"),
                ("c", "Cristo fora da Escritura"),
            ),
            correct="a",
            passage_a={"ref": "Neemias 8:8; Lucas 24:27", "text": BOSS},
            passage_b={
                "ref": "Contexto",
                "text": "Leia com sabedoria: entender o sentido e ver Cristo em toda a Escritura.",
            },
        ),
        dict(
            short="cam",
            nn="01",
            difficulty="caminhada",
            skill="understand",
            qtype="true_false",
            text="Os dois trechos ensinam que basta ouvir o som da Lei, sem sentido e sem Cristo nas Escrituras.",
            fb_ok="Certo: Neemias pede sentido e Lucas mostra Cristo nas Escrituras.",
            fb_wrong={"true": "Os textos unem entendimento do sentido e leitura cristológica."},
            options=TF,
            correct="false",
        ),
        dict(
            short="cam",
            nn="02",
            difficulty="caminhada",
            skill="understand",
            qtype="tap",
            text='Em Neemias 8:8; Lucas 24:27, toque a palavra que falta em "de modo que se ___ a leitura"?',
            fb_ok="Exato: para que se entendesse a leitura.",
            fb_wrong={
                "a": "Distintamente descreve como leram, não esta lacuna.",
                "c": "Começando abre Lucas 24:27, não esta lacuna.",
            },
            template="de modo que se ___ a leitura",
            options=opts(("a", "distintamente"), ("b", "entendesse"), ("c", "Começando")),
            correct="b",
        ),
        dict(
            short="cam",
            nn="03",
            difficulty="caminhada",
            skill="understand",
            qtype="choice",
            text="Como Neemias 8:8 e Lucas 24:27 se encadeiam na leitura sábia?",
            fb_ok="Certo: entender o sentido e ver o que as Escrituras dizem dele.",
            fb_wrong={
                "a": "Lucas não anula Neemias; os dois se somam.",
                "c": "Não se trata de escolher um e descartar o outro.",
                "d": "O sentido dado não dispensa encontrar Cristo no texto.",
            },
            options=opts(
                ("a", "Lucas substitui Neemias: o sentido da Lei já não importa."),
                ("b", "Entender o sentido e ver o que dele se achava dito nas Escrituras."),
                ("c", "Neemias basta, e Moisés não precisa ser lido em Cristo."),
                ("d", "Dar o sentido dispensa explicar o que as Escrituras dizem dele."),
            ),
            correct="b",
        ),
        dict(
            short="cam",
            nn="04",
            difficulty="caminhada",
            skill="understand",
            qtype="order",
            text="Como se encadeiam os eventos de Neemias 8:8; Lucas 24:27?",
            fb_ok="Certo: clareza, sentido e Cristo no conjunto das Escrituras.",
            fb_wrong={
                "b": "Essa etapa não ocupa esse lugar no encadeamento.",
                "c": "A explicação cristológica é o desfecho, não o início.",
            },
            options=opts(
                ("a", "ler a Lei distintamente"),
                ("b", "dar o sentido para que se entenda"),
                ("c", "explicar o que dele se achava dito em todas as Escrituras"),
            ),
            correct="a",
            correct_order=["a", "b", "c"],
        ),
        dict(
            short="cam",
            nn="05",
            difficulty="caminhada",
            skill="understand",
            qtype="complete",
            text='Complete: "Leram no livro da lei de Deus ___."',
            fb_ok="Certo: leram distintamente.",
            fb_wrong={
                "b": "Explicou-lhes é o verbo de Lucas 24:27.",
                "c": "Profetas pertence a Lucas 24:27, não a esta lacuna.",
            },
            template="Leram no livro da lei de Deus ___.",
            options=opts(("a", "distintamente"), ("b", "explicou-lhes"), ("c", "profetas")),
            correct="a",
        ),
        dict(
            short="cam",
            nn="06",
            difficulty="caminhada",
            skill="understand",
            qtype="connect",
            text="O que Neemias 8:8; Lucas 24:27 comunica que se liga a este contexto?",
            fb_ok="Certo: sabedoria une entendimento e Cristo no texto.",
            fb_wrong={
                "a": "Os textos não separam clareza e Cristo.",
                "c": "Não autorizam leitura particular sem o texto.",
            },
            options=opts(
                ("a", "Clareza ou Cristo, nunca ambos"),
                ("b", "Entender e ver Cristo"),
                ("c", "Leitura particular sem texto"),
            ),
            correct="b",
            passage_a={"ref": "Neemias 8:8; Lucas 24:27", "text": BOSS},
            passage_b={
                "ref": "Contexto",
                "text": "Leitura sábia: o sentido é dado ao povo e Cristo é visto em toda a Escritura.",
            },
        ),
        dict(
            short="pro",
            nn="01",
            difficulty="profundezas",
            skill="interpret",
            qtype="true_false",
            text="Ler com sabedoria, segundo Neemias 8:8 e Lucas 24:27, é entender o sentido e ver Cristo em toda a Escritura.",
            fb_ok="Certo: os dois textos formam essa hermenêutica.",
            fb_wrong={"false": "Neemias pede entendimento; Lucas mostra Cristo nas Escrituras."},
            options=TF,
            correct="true",
        ),
        dict(
            short="pro",
            nn="02",
            difficulty="profundezas",
            skill="interpret",
            qtype="tap",
            text='Em Neemias 8:8; Lucas 24:27, toque a palavra que falta em "explicou-lhes o que ___ se achava dito em todas as Escrituras"?',
            fb_ok="Exato: o que dele se achava dito.",
            fb_wrong={
                "a": "Sentido pertence a Neemias 8:8, não a esta lacuna.",
                "c": "Leitura fecha Neemias 8:8, não esta lacuna.",
            },
            template="explicou-lhes o que ___ se achava dito em todas as Escrituras",
            options=opts(("a", "sentido"), ("b", "dele"), ("c", "leitura")),
            correct="b",
        ),
        dict(
            short="pro",
            nn="03",
            difficulty="profundezas",
            skill="interpret",
            qtype="choice",
            text="Que hermenêutica os dois textos sustentam juntos?",
            fb_ok="Certo: entendimento do sentido e Cristo no conjunto da Escritura.",
            fb_wrong={
                "a": "Lucas não autoriza ignorar o sentido da Lei.",
                "c": "Neemias não reduz a Bíblia a um rito sem Cristo.",
                "d": "Os textos não entregam o sentido ao capricho do leitor.",
            },
            options=opts(
                ("a", "Cristo no centro dispensa entender o sentido da Lei."),
                ("b", "Entender o sentido e ler toda a Escritura em Cristo."),
                ("c", "A Lei basta como rito, sem busca de Cristo no texto."),
                ("d", "Cada um inventa o sentido e depois procura Jesus nele."),
            ),
            correct="b",
        ),
        dict(
            short="pro",
            nn="04",
            difficulty="profundezas",
            skill="interpret",
            qtype="order",
            text="Qual sequência revela o sentido de Neemias 8:8; Lucas 24:27?",
            fb_ok="Certo: do texto entendido ao Cristo em toda a Escritura.",
            fb_wrong={
                "b": "Essa etapa não revela o sentido nesta ordem.",
                "c": "Ver Cristo no conjunto é o desfecho da sequência.",
            },
            options=opts(
                ("a", "receber a Lei lida com clareza"),
                ("b", "receber o sentido para entender a leitura"),
                ("c", "ver o que dele se achava dito em todas as Escrituras"),
            ),
            correct="a",
            correct_order=["a", "b", "c"],
        ),
        dict(
            short="pro",
            nn="05",
            difficulty="profundezas",
            skill="interpret",
            qtype="complete",
            text='Complete: "explicou-lhes o que dele se achava dito em todas as ___."',
            fb_ok="Certo: em todas as Escrituras.",
            fb_wrong={
                "b": "Lei nomeia o livro em Neemias, não esta lacuna.",
                "c": "Sentido é o que deram em Neemias 8:8.",
            },
            template="explicou-lhes o que dele se achava dito em todas as ___.",
            options=opts(("a", "Escrituras"), ("b", "lei"), ("c", "sentido")),
            correct="a",
        ),
        dict(
            short="pro",
            nn="06",
            difficulty="profundezas",
            skill="interpret",
            qtype="connect",
            text="O que Neemias 8:8; Lucas 24:27 comunica que se liga a este contexto?",
            fb_ok="Certo: sabedoria lê com sentido e com Cristo no centro.",
            fb_wrong={
                "a": "Os textos não separam entendimento e Cristo.",
                "c": "Não celebram o prestígio do intérprete.",
            },
            options=opts(
                ("a", "Sentido sem Cristo"),
                ("b", "Sabedoria: sentido e Cristo"),
                ("c", "Prestígio do intérprete"),
            ),
            correct="b",
            passage_a={"ref": "Neemias 8:8; Lucas 24:27", "text": BOSS},
            passage_b={
                "ref": "Contexto",
                "text": "Leia com sabedoria: entender o sentido e ver Cristo em toda a Escritura.",
            },
        ),
    ],
)

bank = M1 + M2 + M3 + M4
assert len(bank) == 72, len(bank)

out = "/Users/dalwesleyduarte/dev/new/perguntas-v2/hermeneutica.json"
with open(out, "w", encoding="utf-8") as fh:
    json.dump(bank, fh, ensure_ascii=False, indent=2)
    fh.write("\n")
print(out, len(bank))
