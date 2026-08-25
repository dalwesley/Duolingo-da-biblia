#!/usr/bin/env python3
"""Gera perguntas-v2/escatologia.json no padrão Oséias STWAY V2."""
from __future__ import annotations

import json
from copy import deepcopy
from pathlib import Path

OUT = Path(__file__).with_name("escatologia.json")

TF_OPTS = [
    {"id": "true", "text": "Verdadeiro"},
    {"id": "false", "text": "Falso"},
]


def opts(*pairs: tuple[str, str]) -> list[dict]:
    return [{"id": i, "text": t} for i, t in pairs]


def item(
    *,
    trail: str,
    section: str,
    difficulty: str,
    skill: str,
    n: str,
    qtype: str,
    verse_ref: str,
    lo: str,
    evidence: list[str],
    question: str,
    feedback_correct: str,
    feedback_wrong: dict,
    options: list[dict],
    correct: str,
    passage: str,
    template: str | None = None,
    correct_order: list[str] | None = None,
    passage_a: dict | None = None,
    passage_b: dict | None = None,
) -> dict:
    short = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}[difficulty]
    q = {
        "difficulty": difficulty,
        "skill": skill,
        "verseRef": verse_ref,
        "learningObjective": lo,
        "evidence": evidence,
        "type": qtype,
        "question": question,
        "prompt": question,
        "cue": question,
        "feedbackCorrect": feedback_correct,
        "feedbackWrong": feedback_wrong,
        "options": options,
        "correctOptionId": correct,
        "correctAnswer": correct,
        "passageText": passage,
    }
    if template:
        q["template"] = template
    if passage_a:
        q["passageA"] = passage_a
    if passage_b:
        q["passageB"] = passage_b
    if correct_order:
        q["correctOrder"] = correct_order
    q["trail"] = trail
    q["section"] = section
    q["id"] = f"{trail}-{short}-{section}-{n}"
    return q


TRAIL = "escatologia"

P1 = (
    "e lhes perguntaram: Galileus, por que estais olhando para o céu? "
    "Esse Jesus que dentre vós foi recebido no céu assim virá do modo "
    "como o vistes ir para o céu."
)
P2 = (
    "Pois é necessário que todos sejamos descobertos perante o tribunal "
    "de Cristo, para que cada um receba o que fez por meio do corpo, "
    "conforme o que praticou, o bem ou o mal."
)
P3 = (
    "Ouvi uma grande voz, vinda do trono, dizendo: Eis o tabernáculo de Deus "
    "está com os homens, e ele habitará com eles; eles serão o seu povo, e "
    "Deus mesmo estará com eles. e enxugará toda lágrima dos olhos deles. "
    "Não haverá mais morte, nem haverá mais pranto, nem choro, nem dor, "
    "porque as primeiras coisas são passadas."
)
PBOSS = f"{P1} {P3}"

LO1 = "Reconhecer que Jesus voltará do mesmo modo como foi recebido no céu; a espera não é olhar vazio."
LO2 = "Reconhecer que todos comparecem ao tribunal de Cristo e recebem conforme o que praticaram no corpo."
LO3 = "Reconhecer que Deus habitará com os homens; morte, pranto e dor passarão."
LOB = "Integrar a volta de Jesus e a nova criação: o que subiu voltará, e Deus enxugará toda lágrima."

EV1 = ["Atos 1:11"]
EV2 = ["2 Coríntios 5:10"]
EV3 = ["Apocalipse 21:3", "Apocalipse 21:4"]
EVB = ["Atos 1:11", "Apocalipse 21:3", "Apocalipse 21:4"]

R1 = "Atos 1:11"
R2 = "2 Coríntios 5:10"
R3 = "Apocalipse 21:3–4"
RB = "Atos 1:11; Apocalipse 21:3–4"

INS1 = "Jesus voltará do mesmo modo como foi recebido no céu — a espera não é olhar vazio."
INS2 = "Justiça diante de Deus: todos comparecem ao tribunal de Cristo — o que se fez no corpo importa."
INS3 = "Novas todas as coisas: Deus habita com os homens; morte, pranto e dor passam."
INSB = "Esperança firme: o que subiu voltará, e Deus enxugará toda lágrima."


def pack(section, verse_ref, lo, evidence, passage, rows):
    out = []
    for r in rows:
        kw = deepcopy(r)
        kw.update(
            trail=TRAIL,
            section=section,
            verse_ref=verse_ref,
            lo=lo,
            evidence=evidence,
            passage=passage,
        )
        out.append(item(**kw))
    return out


def tf(diff, skill, n, question, fc, fw, correct):
    return dict(
        difficulty=diff,
        skill=skill,
        n=n,
        qtype="true_false",
        question=question,
        feedback_correct=fc,
        feedback_wrong=fw,
        options=TF_OPTS,
        correct=correct,
    )


def tap(diff, skill, n, ref, blank, fc, fw, options, correct, template):
    q = f'Em {ref}, toque a palavra que falta em "{blank}"?'
    return dict(
        difficulty=diff,
        skill=skill,
        n=n,
        qtype="tap",
        question=q,
        feedback_correct=fc,
        feedback_wrong=fw,
        options=options,
        correct=correct,
        template=template,
    )


def choice(diff, skill, n, question, fc, fw, options, correct):
    return dict(
        difficulty=diff,
        skill=skill,
        n=n,
        qtype="choice",
        question=question,
        feedback_correct=fc,
        feedback_wrong=fw,
        options=options,
        correct=correct,
    )


def order(diff, skill, n, question, fc, fw, options):
    return dict(
        difficulty=diff,
        skill=skill,
        n=n,
        qtype="order",
        question=question,
        feedback_correct=fc,
        feedback_wrong=fw,
        options=options,
        correct="a",
        correct_order=["a", "b", "c"],
    )


def complete(diff, skill, n, blank, fc, fw, options, correct, template):
    q = f'Complete a frase: "{blank}"'
    return dict(
        difficulty=diff,
        skill=skill,
        n=n,
        qtype="complete",
        question=q,
        feedback_correct=fc,
        feedback_wrong=fw,
        options=options,
        correct=correct,
        template=template,
    )


def connect(diff, skill, n, ref, fc, fw, options, correct, pa, pb):
    return dict(
        difficulty=diff,
        skill=skill,
        n=n,
        qtype="connect",
        question=f"O que {ref} comunica que se liga a este contexto?",
        feedback_correct=fc,
        feedback_wrong=fw,
        options=options,
        correct=correct,
        passage_a={"ref": ref, "text": pa},
        passage_b={"ref": "Contexto", "text": pb},
    )


# --- M1 Atos 1:11 ---
O1S = opts(
    ("a", "Esse Jesus que dentre vós foi recebido no céu"),
    ("b", "assim virá do modo como o vistes ir para o céu"),
    ("c", "Galileus, por que estais olhando para o céu"),
)
# textual order is: perguntaram / Galileus olhando / Esse Jesus virá
O1 = opts(
    ("a", "e lhes perguntaram"),
    ("b", "Galileus, por que estais olhando para o céu"),
    ("c", "Esse Jesus que dentre vós foi recebido no céu assim virá"),
)
O1C = opts(
    ("a", "foi recebido no céu"),
    ("b", "assim virá do modo como o vistes ir"),
    ("c", "para o céu"),
)
O1P = opts(
    ("a", "estais olhando para o céu"),
    ("b", "Esse Jesus que dentre vós foi recebido no céu"),
    ("c", "assim virá do modo como o vistes ir para o céu"),
)

m1 = pack(
    "es-01-volta",
    R1,
    LO1,
    EV1,
    P1,
    [
        tf(
            "semente",
            "observe",
            "01",
            "Esse Jesus virá do modo como o vistes ir para o céu.",
            "Certo: Atos 1:11 afirma a volta do mesmo modo da subida.",
            {"false": "Releia: esse Jesus assim virá como o vistes ir."},
            "true",
        ),
        tap(
            "semente",
            "observe",
            "02",
            R1,
            "Galileus, por que estais olhando para o ___",
            "Exato: olhando para o céu.",
            {
                "b": "Jesus é o sujeito da volta, não esta lacuna.",
                "c": "Virá descreve a vinda, não o lugar do olhar.",
            },
            opts(("a", "céu"), ("b", "Jesus"), ("c", "virá")),
            "a",
            "Galileus, por que estais olhando para o ___",
        ),
        choice(
            "semente",
            "observe",
            "03",
            "Qual afirmação o texto de Atos 1:11 registra diretamente?",
            "Certo: o mesmo Jesus voltará como foi visto ir.",
            {
                "b": "O texto promete vinda, não ausência definitiva.",
                "c": "A subida não apaga a identidade de Jesus.",
                "d": "O olhar ao céu não substitui a promessa da volta.",
            },
            opts(
                ("a", "Esse Jesus assim virá do modo como o vistes ir para o céu."),
                ("b", "Jesus não voltará depois de ser recebido no céu."),
                ("c", "Outro messias virá no lugar daquele que subiu."),
                ("d", "Os galileus devem ficar só olhando, sem esperança de volta."),
            ),
            "a",
        ),
        order(
            "semente",
            "observe",
            "04",
            f"Qual sequência mostra a ordem dos fatos em {R1}?",
            "Certo: pergunta, olhar ao céu, promessa da volta.",
            {
                "b": "A fala aos galileus vem depois do ‘perguntaram’.",
                "c": "A promessa da volta fecha o trecho, não o abre.",
            },
            O1,
        ),
        complete(
            "semente",
            "observe",
            "05",
            "Esse Jesus que dentre vós foi recebido no céu assim ___",
            "Certo: assim virá do modo como o vistes ir.",
            {
                "b": "Céu é o lugar, não o verbo desta lacuna.",
                "c": "Vistes descreve o modo da subida, não o verbo da volta.",
            },
            opts(("a", "virá"), ("b", "céu"), ("c", "vistes")),
            "a",
            "Esse Jesus que dentre vós foi recebido no céu assim ___",
        ),
        connect(
            "semente",
            "observe",
            "06",
            R1,
            "Certo: a volta tem o mesmo modo da subida.",
            {
                "b": "O texto não descreve espera vazia sem vinda.",
                "c": "Jesus não é substituído por outro após a subida.",
            },
            opts(
                ("a", "Volta como a subida"),
                ("b", "Olhar vazio sem volta"),
                ("c", "Outro messias no lugar"),
            ),
            "a",
            P1,
            INS1,
        ),
        tf(
            "caminhada",
            "understand",
            "01",
            "O texto ensina que a espera cristã se resume a olhar vazio para o céu, sem a promessa de que Jesus voltará.",
            "Certo: o olhar é corrigido pela promessa da volta.",
            {"true": "Eles são perguntados pelo olhar; Jesus assim virá."},
            "false",
        ),
        tap(
            "caminhada",
            "understand",
            "02",
            R1,
            "Esse Jesus que dentre vós foi ___ no céu",
            "Exato: foi recebido no céu.",
            {
                "b": "Olhando descreve os galileus, não esta lacuna.",
                "c": "Vistes refere-se ao modo de ir, não ao ‘foi ___’.",
            },
            opts(("a", "recebido"), ("b", "olhando"), ("c", "vistes")),
            "a",
            "Esse Jesus que dentre vós foi ___ no céu",
        ),
        choice(
            "caminhada",
            "understand",
            "03",
            "Como Atos 1:11 relaciona o olhar para o céu e a volta de Jesus?",
            "Certo: o olhar vazio é corrigido pela mesma volta visível.",
            {
                "a": "O texto não manda permanecer só olhando.",
                "c": "A identidade de Jesus permanece na volta.",
                "d": "A subida não cancela a vinda; ela a descreve.",
            },
            opts(
                ("a", "O olhar ao céu substitui a espera da volta"),
                ("b", "A subida visível fundamenta a volta do mesmo modo"),
                ("c", "Quem subiu não é o mesmo que voltará"),
                ("d", "A recepção no céu encerra qualquer vinda futura"),
            ),
            "b",
        ),
        order(
            "caminhada",
            "understand",
            "04",
            f"Como se encadeiam os eventos de {R1}?",
            "Certo: recebido no céu, assim virá, como o vistes ir.",
            {
                "b": "Primeiro vem a recepção no céu, não o ‘para o céu’ final.",
                "c": "O ‘para o céu’ fecha o modo da subida vista.",
            },
            O1C,
        ),
        complete(
            "caminhada",
            "understand",
            "05",
            "assim virá do modo como o ___ ir para o céu",
            "Certo: como o vistes ir para o céu.",
            {
                "b": "Recebido descreve a subida, não esta lacuna.",
                "c": "Galileus é o vocativo, não o verbo ‘vistes’.",
            },
            opts(("a", "vistes"), ("b", "recebido"), ("c", "Galileus")),
            "a",
            "assim virá do modo como o ___ ir para o céu",
        ),
        connect(
            "caminhada",
            "understand",
            "06",
            R1,
            "Certo: a espera tem conteúdo — a mesma volta visível.",
            {
                "b": "O trecho não reduz a fé a curiosidade celeste.",
                "c": "Não há troca de pessoa entre subida e volta.",
            },
            opts(
                ("a", "Espera com volta visível"),
                ("b", "Curiosidade sem promessa"),
                ("c", "Troca de messias no céu"),
            ),
            "a",
            P1,
            INS1,
        ),
        tf(
            "profundezas",
            "interpret",
            "01",
            "A volta de Jesus é do mesmo modo da subida: o que foi recebido no céu assim virá.",
            "Certo: o texto liga subida vista e vinda futura.",
            {"false": "O ‘assim virá’ replica o modo da subida vista."},
            "true",
        ),
        tap(
            "profundezas",
            "interpret",
            "02",
            R1,
            "Esse ___ que dentre vós foi recebido no céu",
            "Exato: esse Jesus, o mesmo que subiu.",
            {
                "b": "Céu é o lugar, não o nome desta lacuna.",
                "c": "Modo descreve a forma da volta, não o sujeito.",
            },
            opts(("a", "Jesus"), ("b", "céu"), ("c", "modo")),
            "a",
            "Esse ___ que dentre vós foi recebido no céu",
        ),
        choice(
            "profundezas",
            "interpret",
            "03",
            "Qual leitura interpreta melhor o sentido teológico de Atos 1:11?",
            "Certo: a esperança assenta no mesmo Jesus que subiu.",
            {
                "a": "O olhar vazio é questionado, não canonizado.",
                "b": "A identidade de Jesus persiste na volta.",
                "d": "A recepção no céu descreve o modo, não o fim da história.",
            },
            opts(
                ("a", "A fé escatológica é só contemplar o céu sem vinda"),
                ("b", "Outro virá, pois o que subiu já não retorna"),
                ("c", "O mesmo Jesus voltará visivelmente, como foi visto ir"),
                ("d", "Ser recebido no céu substitui qualquer juízo e volta"),
            ),
            "c",
        ),
        order(
            "profundezas",
            "interpret",
            "04",
            f"Qual sequência revela o sentido de {R1}?",
            "Certo: olhar, o mesmo Jesus recebido, a volta no mesmo modo.",
            {
                "b": "O sentido começa no olhar questionado, não na volta.",
                "c": "A volta no mesmo modo fecha o sentido do trecho.",
            },
            O1P,
        ),
        complete(
            "profundezas",
            "interpret",
            "05",
            "___, por que estais olhando para o céu",
            "Certo: Galileus, por que estais olhando para o céu.",
            {
                "b": "Jesus é o que volta, não o vocativo desta frase.",
                "c": "Virá pertence à promessa, não a este chamado.",
            },
            opts(("a", "Galileus"), ("b", "Jesus"), ("c", "virá")),
            "a",
            "___, por que estais olhando para o céu",
        ),
        connect(
            "profundezas",
            "interpret",
            "06",
            R1,
            "Certo: a esperança não é olhar vazio, mas a volta do mesmo.",
            {
                "b": "O trecho recusa uma espera sem conteúdo.",
                "c": "Espiritualizar a volta contra o ‘assim virá’.",
            },
            opts(
                ("a", "Mesmo Jesus, mesma volta"),
                ("b", "Espera vazia sem vinda"),
                ("c", "Volta só interior e invisível"),
            ),
            "a",
            P1,
            INS1,
        ),
    ],
)

# --- M2 2 Coríntios 5:10 ---
O2 = opts(
    ("a", "é necessário que todos sejamos descobertos perante o tribunal de Cristo"),
    ("b", "para que cada um receba o que fez por meio do corpo"),
    ("c", "conforme o que praticou, o bem ou o mal"),
)
O2C = opts(
    ("a", "todos sejamos descobertos perante o tribunal de Cristo"),
    ("b", "cada um receba o que fez por meio do corpo"),
    ("c", "conforme o que praticou, o bem ou o mal"),
)
O2P = opts(
    ("a", "Pois é necessário que todos sejamos descobertos"),
    ("b", "perante o tribunal de Cristo"),
    ("c", "cada um receba o que fez por meio do corpo"),
)

m2 = pack(
    "es-02-juizo",
    R2,
    LO2,
    EV2,
    P2,
    [
        tf(
            "semente",
            "observe",
            "01",
            "É necessário que todos sejamos descobertos perante o tribunal de Cristo.",
            "Certo: 2 Coríntios 5:10 afirma o tribunal de Cristo.",
            {"false": "Releia: todos sejamos descobertos perante o tribunal."},
            "true",
        ),
        tap(
            "semente",
            "observe",
            "02",
            R2,
            "todos sejamos descobertos perante o ___ de Cristo",
            "Exato: o tribunal de Cristo.",
            {
                "b": "Corpo entra depois, no que se fez.",
                "c": "Bem descreve o que se praticou, não esta lacuna.",
            },
            opts(("a", "tribunal"), ("b", "corpo"), ("c", "bem")),
            "a",
            "todos sejamos descobertos perante o ___ de Cristo",
        ),
        choice(
            "semente",
            "observe",
            "03",
            "Qual afirmação 2 Coríntios 5:10 registra diretamente?",
            "Certo: cada um recebe o que fez por meio do corpo.",
            {
                "b": "O texto fala de todos, não de uma elite isenta.",
                "c": "O que se fez no corpo entra no juízo.",
                "d": "Há bem ou mal, não indiferença moral.",
            },
            opts(
                ("a", "Cada um recebe o que fez por meio do corpo, o bem ou o mal."),
                ("b", "Só alguns serão descobertos perante o tribunal de Cristo."),
                ("c", "O que se fez no corpo não entra no juízo."),
                ("d", "Perante Cristo não há distinção entre bem e mal."),
            ),
            "a",
        ),
        order(
            "semente",
            "observe",
            "04",
            f"Qual sequência mostra a ordem dos fatos em {R2}?",
            "Certo: tribunal, o feito no corpo, bem ou mal.",
            {
                "b": "O comparecimento vem antes da retribuição.",
                "c": "O bem ou o mal fecha o critério, não o abre.",
            },
            O2,
        ),
        complete(
            "semente",
            "observe",
            "05",
            "cada um receba o que fez por meio do ___",
            "Certo: por meio do corpo.",
            {
                "b": "Tribunal é o lugar, não esta lacuna.",
                "c": "Mal aparece no critério final, não aqui.",
            },
            opts(("a", "corpo"), ("b", "tribunal"), ("c", "mal")),
            "a",
            "cada um receba o que fez por meio do ___",
        ),
        connect(
            "semente",
            "observe",
            "06",
            R2,
            "Certo: o que se fez no corpo importa no tribunal.",
            {
                "b": "Ninguém fica de fora do comparecimento.",
                "c": "O texto não trata o corpo como irrelevante.",
            },
            opts(
                ("a", "O corpo importa no juízo"),
                ("b", "Só os ímpios comparecem"),
                ("c", "O corpo não entra no juízo"),
            ),
            "a",
            P2,
            INS2,
        ),
        tf(
            "caminhada",
            "understand",
            "01",
            "O texto ensina que o tribunal de Cristo é só para alguns, e o que se fez no corpo não pesa.",
            "Certo: todos comparecem; o feito no corpo é recebido.",
            {"true": "Todos sejamos descobertos; cada um recebe o que fez."},
            "false",
        ),
        tap(
            "caminhada",
            "understand",
            "02",
            R2,
            "é necessário que todos sejamos ___ perante o tribunal",
            "Exato: sejamos descobertos perante o tribunal.",
            {
                "b": "Necessário qualifica o dever, não esta lacuna.",
                "c": "Praticou descreve o critério, não o comparecimento.",
            },
            opts(("a", "descobertos"), ("b", "necessário"), ("c", "praticou")),
            "a",
            "é necessário que todos sejamos ___ perante o tribunal",
        ),
        choice(
            "caminhada",
            "understand",
            "03",
            "Como 2 Coríntios 5:10 relaciona o tribunal de Cristo e o que se fez no corpo?",
            "Certo: o comparecimento público mede o praticado no corpo.",
            {
                "a": "O juízo não ignora a vida encarnada.",
                "c": "Não há isenção por status espiritual.",
                "d": "Bem e mal não se misturam num critério vazio.",
            },
            opts(
                ("a", "O tribunal ignora o corpo e julga só intenções ocultas"),
                ("b", "Todos comparecem e recebem conforme o praticado no corpo"),
                ("c", "Quem crê fica de fora do tribunal de Cristo"),
                ("d", "O bem e o mal se anulam, e ninguém recebe nada"),
            ),
            "b",
        ),
        order(
            "caminhada",
            "understand",
            "04",
            f"Como se encadeiam os eventos de {R2}?",
            "Certo: descobertos, receber o feito, bem ou mal.",
            {
                "b": "O recebimento segue o comparecimento, não o inverso.",
                "c": "O critério moral fecha a cadeia.",
            },
            O2C,
        ),
        complete(
            "caminhada",
            "understand",
            "05",
            "descobertos perante o tribunal de ___",
            "Certo: o tribunal de Cristo.",
            {
                "b": "Corpo é o meio do que se fez.",
                "c": "Todos é o sujeito, não o nome do tribunal.",
            },
            opts(("a", "Cristo"), ("b", "corpo"), ("c", "todos")),
            "a",
            "descobertos perante o tribunal de ___",
        ),
        connect(
            "caminhada",
            "understand",
            "06",
            R2,
            "Certo: justiça de Deus mede a vida no corpo.",
            {
                "b": "Não há juízo privado que ignore o comparecimento.",
                "c": "O trecho não trata o mal como indiferente.",
            },
            opts(
                ("a", "Justiça pelo feito no corpo"),
                ("b", "Juízo só interior e secreto"),
                ("c", "Mal e bem sem retribuição"),
            ),
            "a",
            P2,
            INS2,
        ),
        tf(
            "profundezas",
            "interpret",
            "01",
            "O tribunal de Cristo torna a vida no corpo responsável diante de Deus: o bem ou o mal será recebido.",
            "Certo: o texto liga comparecimento e retribuição moral.",
            {"false": "Cada um recebe conforme o que praticou no corpo."},
            "true",
        ),
        tap(
            "profundezas",
            "interpret",
            "02",
            R2,
            "Pois é ___ que todos sejamos descobertos",
            "Exato: é necessário o comparecimento.",
            {
                "b": "Descobertos é o estado, não esta lacuna.",
                "c": "Receba descreve a retribuição posterior.",
            },
            opts(("a", "necessário"), ("b", "descobertos"), ("c", "receba")),
            "a",
            "Pois é ___ que todos sejamos descobertos",
        ),
        choice(
            "profundezas",
            "interpret",
            "03",
            "Qual leitura interpreta melhor o sentido teológico de 2 Coríntios 5:10?",
            "Certo: ninguém escapa; a vida no corpo tem peso eterno.",
            {
                "a": "Graça não apaga o tribunal neste texto.",
                "b": "O corpo não é palco irrelevante da fé.",
                "d": "Bem e mal permanecem critérios reais.",
            },
            opts(
                ("a", "A graça cancela qualquer tribunal para os crentes"),
                ("b", "Só o espírito importa; o corpo fica de fora"),
                ("c", "Todos comparecem, e o praticado no corpo será recebido"),
                ("d", "O mal não será levado em conta perante Cristo"),
            ),
            "c",
        ),
        order(
            "profundezas",
            "interpret",
            "04",
            f"Qual sequência revela o sentido de {R2}?",
            "Certo: necessidade, tribunal de Cristo, retribuição no corpo.",
            {
                "b": "O sentido abre com a necessidade, não com o corpo.",
                "c": "O feito no corpo é o desfecho do juízo.",
            },
            O2P,
        ),
        complete(
            "profundezas",
            "interpret",
            "05",
            "conforme o que praticou, o bem ou o ___",
            "Certo: o bem ou o mal.",
            {
                "b": "Corpo é o meio, não o par do bem.",
                "c": "Tribunal é o lugar, não esta palavra.",
            },
            opts(("a", "mal"), ("b", "corpo"), ("c", "tribunal")),
            "a",
            "conforme o que praticou, o bem ou o ___",
        ),
        connect(
            "profundezas",
            "interpret",
            "06",
            R2,
            "Certo: a esperança não anula a responsabilidade.",
            {
                "b": "O trecho recusa impunidade espiritual.",
                "c": "O corpo não é teatro sem juízo.",
            },
            opts(
                ("a", "Responsabilidade no corpo"),
                ("b", "Impunidade dos crentes"),
                ("c", "Corpo sem peso eterno"),
            ),
            "a",
            P2,
            INS2,
        ),
    ],
)

# --- M3 Apocalipse 21:3–4 ---
O3 = opts(
    ("a", "Eis o tabernáculo de Deus está com os homens, e ele habitará com eles"),
    ("b", "eles serão o seu povo, e Deus mesmo estará com eles"),
    ("c", "e enxugará toda lágrima dos olhos deles"),
)
O3C = opts(
    ("a", "ele habitará com eles; eles serão o seu povo"),
    ("b", "enxugará toda lágrima dos olhos deles"),
    ("c", "Não haverá mais morte, nem haverá mais pranto, nem choro, nem dor"),
)
O3P = opts(
    ("a", "Eis o tabernáculo de Deus está com os homens"),
    ("b", "e enxugará toda lágrima dos olhos deles"),
    ("c", "as primeiras coisas são passadas"),
)

m3 = pack(
    "es-03-novo",
    R3,
    LO3,
    EV3,
    P3,
    [
        tf(
            "semente",
            "observe",
            "01",
            "Eis o tabernáculo de Deus está com os homens, e ele habitará com eles.",
            "Certo: Apocalipse 21:3 afirma a habitação de Deus.",
            {"false": "Releia: o tabernáculo de Deus está com os homens."},
            "true",
        ),
        tap(
            "semente",
            "observe",
            "02",
            R3,
            "Eis o ___ de Deus está com os homens",
            "Exato: o tabernáculo de Deus está com os homens.",
            {
                "b": "Trono é de onde vem a voz, não esta lacuna.",
                "c": "Morte aparece depois, naquilo que passa.",
            },
            opts(("a", "tabernáculo"), ("b", "trono"), ("c", "morte")),
            "a",
            "Eis o ___ de Deus está com os homens",
        ),
        choice(
            "semente",
            "observe",
            "03",
            "Qual afirmação Apocalipse 21:3–4 registra diretamente?",
            "Certo: não haverá mais morte, pranto, choro nem dor.",
            {
                "b": "Deus habita com os homens, não permanece distante.",
                "c": "A morte passa, não permanece.",
                "d": "As primeiras coisas são passadas, não eternas.",
            },
            opts(
                ("a", "Não haverá mais morte, nem pranto, nem choro, nem dor."),
                ("b", "Deus permanece longe, e os homens habitam sós."),
                ("c", "A morte continua, embora o pranto diminua."),
                ("d", "As primeiras coisas permanecem para sempre."),
            ),
            "a",
        ),
        order(
            "semente",
            "observe",
            "04",
            f"Qual sequência mostra a ordem dos fatos em {R3}?",
            "Certo: tabernáculo, povo de Deus, lágrimas enxugadas.",
            {
                "b": "A habitação vem antes de enxugar a lágrima.",
                "c": "A lágrima é enxugada depois da habitação.",
            },
            O3,
        ),
        complete(
            "semente",
            "observe",
            "05",
            "Não haverá mais ___, nem haverá mais pranto",
            "Certo: não haverá mais morte.",
            {
                "b": "Povo descreve a relação, não esta lacuna.",
                "c": "Trono é a origem da voz.",
            },
            opts(("a", "morte"), ("b", "povo"), ("c", "trono")),
            "a",
            "Não haverá mais ___, nem haverá mais pranto",
        ),
        connect(
            "semente",
            "observe",
            "06",
            R3,
            "Certo: Deus habita, e a dor passa.",
            {
                "b": "O texto anuncia o fim da morte, não a sua permanência.",
                "c": "Deus não fica distante neste trecho.",
            },
            opts(
                ("a", "Deus habita; a dor passa"),
                ("b", "A morte permanece eterna"),
                ("c", "Deus permanece distante"),
            ),
            "a",
            P3,
            INS3,
        ),
        tf(
            "caminhada",
            "understand",
            "01",
            "O texto ensina que Deus permanece longe dos homens, e a morte, o pranto e a dor continuam.",
            "Certo: ele habitará com eles; morte e dor passam.",
            {"true": "Deus estará com eles e enxugará toda lágrima."},
            "false",
        ),
        tap(
            "caminhada",
            "understand",
            "02",
            R3,
            "e enxugará toda ___ dos olhos deles",
            "Exato: toda lágrima dos olhos deles.",
            {
                "b": "Morte vem na lista do que não haverá mais.",
                "c": "Povo descreve a aliança, não esta lacuna.",
            },
            opts(("a", "lágrima"), ("b", "morte"), ("c", "povo")),
            "a",
            "e enxugará toda ___ dos olhos deles",
        ),
        choice(
            "caminhada",
            "understand",
            "03",
            "Como Apocalipse 21:3–4 relaciona a habitação de Deus e o fim da dor?",
            "Certo: a presença de Deus enxuga a lágrima e acaba a morte.",
            {
                "a": "A nova ordem não convive com a morte.",
                "c": "A voz do trono une habitação e consolo.",
                "d": "As primeiras coisas passam, não se eternizam.",
            },
            opts(
                ("a", "Deus habita, mas a morte permanece como lei"),
                ("b", "Porque Deus está com eles, lágrima, morte e dor passam"),
                ("c", "O consolo vem sem que Deus habite com os homens"),
                ("d", "As primeiras coisas continuam junto do tabernáculo"),
            ),
            "b",
        ),
        order(
            "caminhada",
            "understand",
            "04",
            f"Como se encadeiam os eventos de {R3}?",
            "Certo: habitação e povo, lágrima enxugada, morte e dor cessam.",
            {
                "b": "A habitação precede o enxugar da lágrima.",
                "c": "O fim da morte fecha o encadeamento.",
            },
            O3C,
        ),
        complete(
            "caminhada",
            "understand",
            "05",
            "eles serão o seu ___, e Deus mesmo estará com eles",
            "Certo: eles serão o seu povo.",
            {
                "b": "Trono é a origem da voz.",
                "c": "Dor pertence ao que passa, não a esta lacuna.",
            },
            opts(("a", "povo"), ("b", "trono"), ("c", "dor")),
            "a",
            "eles serão o seu ___, e Deus mesmo estará com eles",
        ),
        connect(
            "caminhada",
            "understand",
            "06",
            R3,
            "Certo: presença de Deus e fim das primeiras coisas.",
            {
                "b": "O trecho não descreve aliança sem presença.",
                "c": "Pranto e morte não sobrevivem à nova ordem.",
            },
            opts(
                ("a", "Presença que acaba a dor"),
                ("b", "Aliança sem habitação"),
                ("c", "Pranto eterno no trono"),
            ),
            "a",
            P3,
            INS3,
        ),
        tf(
            "profundezas",
            "interpret",
            "01",
            "A nova criação é a presença de Deus com o seu povo: as primeiras coisas — morte, pranto e dor — são passadas.",
            "Certo: habitação divina e fim das primeiras coisas.",
            {"false": "Deus estará com eles; as primeiras coisas são passadas."},
            "true",
        ),
        tap(
            "profundezas",
            "interpret",
            "02",
            R3,
            "porque as primeiras coisas são ___",
            "Exato: as primeiras coisas são passadas.",
            {
                "b": "Homens recebem o tabernáculo, não esta lacuna.",
                "c": "Choro está na lista do que não haverá mais.",
            },
            opts(("a", "passadas"), ("b", "homens"), ("c", "choro")),
            "a",
            "porque as primeiras coisas são ___",
        ),
        choice(
            "profundezas",
            "interpret",
            "03",
            "Qual leitura interpreta melhor o sentido teológico de Apocalipse 21:3–4?",
            "Certo: o fim da dor flui de Deus habitando com os homens.",
            {
                "a": "O consolo não é só psicológico; a morte acaba.",
                "b": "Deus não permanece distante neste quadro.",
                "d": "As primeiras coisas passam, não se reformam só.",
            },
            opts(
                ("a", "Só o sentimento muda; a morte continua"),
                ("b", "Deus visita de longe, sem habitar com o povo"),
                ("c", "Deus com os homens torna passadas morte, pranto e dor"),
                ("d", "As primeiras coisas se eternizam no tabernáculo"),
            ),
            "c",
        ),
        order(
            "profundezas",
            "interpret",
            "04",
            f"Qual sequência revela o sentido de {R3}?",
            "Certo: tabernáculo com os homens, lágrima enxugada, primeiras coisas passadas.",
            {
                "b": "O sentido começa na habitação, não no fim das coisas.",
                "c": "As primeiras coisas passadas fecham o sentido.",
            },
            O3P,
        ),
        complete(
            "profundezas",
            "interpret",
            "05",
            "Ouvi uma grande voz, vinda do ___",
            "Certo: voz vinda do trono.",
            {
                "b": "Povo descreve a aliança, não a origem da voz.",
                "c": "Lágrima é o que Deus enxuga depois.",
            },
            opts(("a", "trono"), ("b", "povo"), ("c", "lágrima")),
            "a",
            "Ouvi uma grande voz, vinda do ___",
        ),
        connect(
            "profundezas",
            "interpret",
            "06",
            R3,
            "Certo: novas todas as coisas pela presença de Deus.",
            {
                "b": "O trecho não eterniza a morte.",
                "c": "Não há povo sem Deus no meio.",
            },
            opts(
                ("a", "Novas: Deus no meio"),
                ("b", "Morte como lei eterna"),
                ("c", "Povo sem a presença"),
            ),
            "a",
            P3,
            INS3,
        ),
    ],
)

# --- M4 boss: Atos 1:11 + Apocalipse 21:3–4 ---
OB = opts(
    ("a", "Esse Jesus que dentre vós foi recebido no céu assim virá"),
    ("b", "Eis o tabernáculo de Deus está com os homens"),
    ("c", "e enxugará toda lágrima dos olhos deles"),
)
OBC = opts(
    ("a", "assim virá do modo como o vistes ir para o céu"),
    ("b", "ele habitará com eles; eles serão o seu povo"),
    ("c", "Não haverá mais morte, nem haverá mais pranto, nem choro, nem dor"),
)
OBP = opts(
    ("a", "Esse Jesus que dentre vós foi recebido no céu"),
    ("b", "Deus mesmo estará com eles"),
    ("c", "as primeiras coisas são passadas"),
)

m4 = pack(
    "es-boss",
    RB,
    LOB,
    EVB,
    PBOSS,
    [
        tf(
            "semente",
            "observe",
            "01",
            "Esse Jesus virá do modo como o vistes ir para o céu, e Deus enxugará toda lágrima.",
            "Certo: os dois textos unem volta e consolo final.",
            {"false": "Atos promete a volta; Apocalipse, o enxugar da lágrima."},
            "true",
        ),
        tap(
            "semente",
            "observe",
            "02",
            RB,
            "assim virá do modo como o vistes ir para o ___",
            "Exato: ir para o céu, e assim virá.",
            {
                "b": "Lágrima pertence a Apocalipse 21:4.",
                "c": "Morte é o que não haverá mais.",
            },
            opts(("a", "céu"), ("b", "lágrima"), ("c", "morte")),
            "a",
            "assim virá do modo como o vistes ir para o ___",
        ),
        choice(
            "semente",
            "observe",
            "03",
            "O que Atos 1:11 e Apocalipse 21:3–4 afirmam juntos?",
            "Certo: o que subiu voltará, e Deus habitará com os homens.",
            {
                "b": "A volta não é negada em Atos 1:11.",
                "c": "Apocalipse 21 anuncia o fim da morte.",
                "d": "Deus não permanece distante no quadro final.",
            },
            opts(
                ("a", "Jesus voltará como subiu, e Deus habitará com os homens."),
                ("b", "Jesus não volta, e a morte permanece para sempre."),
                ("c", "O tabernáculo chega, mas a lágrima nunca cessa."),
                ("d", "Deus fica longe, e o olhar ao céu substitui a esperança."),
            ),
            "a",
        ),
        order(
            "semente",
            "observe",
            "04",
            f"Qual sequência mostra a ordem dos fatos em {RB}?",
            "Certo: volta de Jesus, tabernáculo, lágrima enxugada.",
            {
                "b": "A volta em Atos abre o conjunto.",
                "c": "A lágrima enxugada vem no quadro final.",
            },
            OB,
        ),
        complete(
            "semente",
            "observe",
            "05",
            "e enxugará toda ___ dos olhos deles",
            "Certo: toda lágrima dos olhos deles.",
            {
                "b": "Céu pertence à subida e à volta.",
                "c": "Jesus é o que virá, não esta lacuna.",
            },
            opts(("a", "lágrima"), ("b", "céu"), ("c", "Jesus")),
            "a",
            "e enxugará toda ___ dos olhos deles",
        ),
        connect(
            "semente",
            "observe",
            "06",
            RB,
            "Certo: o que subiu voltará, e a lágrima será enxugada.",
            {
                "b": "O conjunto não descreve espera vazia.",
                "c": "As lágrimas não são eternas neste quadro.",
            },
            opts(
                ("a", "Volta e lágrima enxugada"),
                ("b", "Espera vazia sem volta"),
                ("c", "Lágrimas que nunca cessam"),
            ),
            "a",
            PBOSS,
            INSB,
        ),
        tf(
            "caminhada",
            "understand",
            "01",
            "Os dois textos ensinam que Jesus não voltará e que a morte e o pranto permanecem.",
            "Certo: ele virá, e não haverá mais morte nem pranto.",
            {"true": "Atos promete a volta; Apocalipse, o fim da morte."},
            "false",
        ),
        tap(
            "caminhada",
            "understand",
            "02",
            RB,
            "Esse Jesus que dentre vós foi recebido no céu assim ___",
            "Exato: assim virá do modo como o vistes ir.",
            {
                "b": "Habitará descreve Deus com os homens.",
                "c": "Passadas qualifica as primeiras coisas.",
            },
            opts(("a", "virá"), ("b", "habitará"), ("c", "passadas")),
            "a",
            "Esse Jesus que dentre vós foi recebido no céu assim ___",
        ),
        choice(
            "caminhada",
            "understand",
            "03",
            "Como a volta de Jesus e a nova criação se encadeiam nestes textos?",
            "Certo: quem subiu volta, e Deus enxuga a lágrima na nova ordem.",
            {
                "a": "A espera não é olhar vazio sem vinda.",
                "c": "A habitação de Deus acaba a dor, não a ignora.",
                "d": "Subida e volta são do mesmo Jesus.",
            },
            opts(
                ("a", "O olhar ao céu substitui a volta e a nova criação"),
                ("b", "O mesmo que subiu volta, e Deus enxugará toda lágrima"),
                ("c", "Deus habita, mas a dor e a morte continuam"),
                ("d", "Outro virá, e as primeiras coisas permanecem"),
            ),
            "b",
        ),
        order(
            "caminhada",
            "understand",
            "04",
            f"Como se encadeiam os eventos de {RB}?",
            "Certo: volta no mesmo modo, habitação, fim da morte e do pranto.",
            {
                "b": "A volta visível abre o encadeamento.",
                "c": "O fim da morte fecha a esperança.",
            },
            OBC,
        ),
        complete(
            "caminhada",
            "understand",
            "05",
            "Não haverá mais ___, nem haverá mais pranto",
            "Certo: não haverá mais morte.",
            {
                "b": "Céu descreve a subida e a volta.",
                "c": "Recebido descreve Jesus no céu.",
            },
            opts(("a", "morte"), ("b", "céu"), ("c", "recebido")),
            "a",
            "Não haverá mais ___, nem haverá mais pranto",
        ),
        connect(
            "caminhada",
            "understand",
            "06",
            RB,
            "Certo: esperança com volta e consolo final.",
            {
                "b": "O conjunto recusa um céu sem vinda.",
                "c": "Não há tabernáculo que eternize o pranto.",
            },
            opts(
                ("a", "Esperança de volta e consolo"),
                ("b", "Céu sem vinda de Jesus"),
                ("c", "Tabernáculo com pranto eterno"),
            ),
            "a",
            PBOSS,
            INSB,
        ),
        tf(
            "profundezas",
            "interpret",
            "01",
            "A esperança cristã une duas afirmações: o que foi recebido no céu assim virá, e Deus habitará com os homens até passar a lágrima.",
            "Certo: volta visível e nova criação se sustentam juntas.",
            {"false": "Os textos combinam o ‘assim virá’ e o tabernáculo."},
            "true",
        ),
        tap(
            "profundezas",
            "interpret",
            "02",
            RB,
            "Eis o ___ de Deus está com os homens",
            "Exato: o tabernáculo de Deus está com os homens.",
            {
                "b": "Galileus é o vocativo de Atos 1:11.",
                "c": "Vistes descreve o modo da subida.",
            },
            opts(("a", "tabernáculo"), ("b", "Galileus"), ("c", "vistes")),
            "a",
            "Eis o ___ de Deus está com os homens",
        ),
        choice(
            "profundezas",
            "interpret",
            "03",
            "Qual leitura interpreta melhor o sentido teológico de Atos 1:11 e Apocalipse 21:3–4 juntos?",
            "Certo: esperança firme — o mesmo Jesus volta, e Deus enxuga a lágrima.",
            {
                "a": "O olhar vazio é corrigido, não canonizado.",
                "b": "A morte passa na nova criação.",
                "d": "A identidade de Jesus persiste da subida à volta.",
            },
            opts(
                ("a", "A fé escatológica é só olhar o céu, sem vinda nem consolo"),
                ("b", "Jesus volta, mas a morte e o pranto permanecem"),
                ("c", "Quem subiu voltará, e Deus estará com eles sem mais lágrima"),
                ("d", "Outro messias vem, e as primeiras coisas se eternizam"),
            ),
            "c",
        ),
        order(
            "profundezas",
            "interpret",
            "04",
            f"Qual sequência revela o sentido de {RB}?",
            "Certo: o mesmo Jesus recebido, Deus com eles, primeiras coisas passadas.",
            {
                "b": "O sentido começa em Jesus recebido no céu.",
                "c": "As primeiras coisas passadas fecham a esperança.",
            },
            OBP,
        ),
        complete(
            "profundezas",
            "interpret",
            "05",
            "Esse Jesus que dentre vós foi ___ no céu",
            "Certo: foi recebido no céu, e assim virá.",
            {
                "b": "Passadas qualifica as primeiras coisas.",
                "c": "Povo descreve a aliança em Apocalipse 21.",
            },
            opts(("a", "recebido"), ("b", "passadas"), ("c", "povo")),
            "a",
            "Esse Jesus que dentre vós foi ___ no céu",
        ),
        connect(
            "profundezas",
            "interpret",
            "06",
            RB,
            "Certo: esperança firme — volta e lágrima enxugada.",
            {
                "b": "O conjunto recusa uma história sem volta.",
                "c": "Não há nova criação com a morte intacta.",
            },
            opts(
                ("a", "O que subiu voltará"),
                ("b", "História sem volta de Jesus"),
                ("c", "Nova criação com a morte"),
            ),
            "a",
            PBOSS,
            INSB,
        ),
    ],
)


def main():
    bank = m1 + m2 + m3 + m4
    assert len(bank) == 72, len(bank)
    for q in bank:
        assert len(q["feedbackCorrect"]) <= 100, (q["id"], len(q["feedbackCorrect"]), q["feedbackCorrect"])
    OUT.write_text(json.dumps(bank, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{OUT} {len(bank)}")


if __name__ == "__main__":
    main()
