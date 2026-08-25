#!/usr/bin/env python3
"""Gera perguntas-v2/evangelhos.json — 12 missões × 18 = 216."""
import json
from pathlib import Path

TRAIL = "evangelhos"
OUT = Path(__file__).resolve().parent / "evangelhos.json"

TF_OPTS = [
    {"id": "true", "text": "Verdadeiro"},
    {"id": "false", "text": "Falso"},
]
SHORT = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}
SKILL = {"semente": "observe", "caminhada": "understand", "profundezas": "interpret"}

P1 = (
    "O Verbo se fez carne e habitou entre nós, cheio de graça e de verdade, "
    "e vimos a sua glória, glória como do unigênito do Pai."
)
P2 = (
    "Batizado que foi Jesus, saiu logo da água; eis que se abriram os céus, "
    "e veio o Espírito de Deus descer como pomba e vir sobre ele; "
    "e uma voz dos céus disse: Este é o meu Filho dileto, em quem me agrado."
)
P3 = (
    "Então foi levado Jesus pelo Espírito ao deserto, para ser tentado pelo Diabo. "
    "Depois de jejuar quarenta dias e quarenta noites, teve fome. "
    "Chegando o tentador, disse-lhe: Se és Filho de Deus, manda que estas pedras se tornem em pães. "
    "Mas Jesus respondeu: Está escrito: Não só de pão viverá o homem, "
    "mas de toda palavra que sai da boca de Deus."
)
P4 = (
    "O Verbo se fez carne e habitou entre nós, cheio de graça e de verdade, "
    "e vimos a sua glória, glória como do unigênito do Pai. "
    "Este é o meu Filho dileto, em quem me agrado."
)
P5 = (
    "Bem-aventurados os humildes de espírito, porque deles é o reino dos céus. "
    "Bem-aventurados os que choram, porque eles serão consolados. "
    "Bem-aventurados os mansos, porque eles herdarão a terra. "
    "Bem-aventurados os que têm fome e sede de justiça, porque eles serão fartos."
)
P6 = (
    "O semeador saiu a semear. Quando semeava, uma parte da semente caiu à beira do caminho, "
    "e vieram as aves e comeram-na. Outra caiu em solo pedregoso, onde não havia muita terra; "
    "e logo nasceu, porque a terra não era profunda; e, tendo nascido o sol, queimou-se e, "
    "por não ter raiz, secou-se. Outra caiu entre os espinhos, e os espinhos cresceram e a sufocaram. "
    "Outra, porém, caiu em terra boa e dava fruto, uma a cem, outra a sessenta e outra a trinta."
)
P7 = (
    "Ele tomou os cinco pães e os dois peixes, e, erguendo os olhos ao céu, deu graças, "
    "e, partindo os pães, entregou-os aos discípulos para eles distribuírem; "
    "e repartiu por todos os dois peixes. Todos comeram e se fartaram;"
)
P8 = (
    "Bem-aventurados os humildes de espírito, porque deles é o reino dos céus. "
    "O semeador saiu a semear."
)
P9 = (
    "Tomando o pão e tendo dado graças, partiu-o e deu aos discípulos, dizendo: "
    "Este é o meu corpo que é dado por vós; fazei isso em memória de mim. "
    "Depois da ceia, tomou, do mesmo modo, o cálice, dizendo: "
    "Este cálice é a nova aliança em meu sangue, que é derramado por vós."
)
P10 = (
    "Jesus, dando um grande brado, expirou. O véu do santuário rasgou-se em duas partes, "
    "de alto a baixo. O centurião que estava em frente de Jesus, vendo-o assim expirar, "
    "disse: Verdadeiramente, este homem era Filho de Deus."
)
P11 = (
    "Mas o anjo disse às mulheres: Não temais vós; porque sei que procurais a Jesus, "
    "que foi crucificado. Ele não está aqui, porque ressuscitou, como disse; "
    "vinde e vede o lugar onde ele jazia."
)
P12 = (
    "O Verbo se fez carne e habitou entre nós, cheio de graça e de verdade, "
    "e vimos a sua glória, glória como do unigênito do Pai. "
    "Ele não está aqui, porque ressuscitou, como disse."
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
    for o in options:
        if typ == "choice":
            assert len(o["text"]) <= 90, (len(o["text"]), o["text"])
    return q


def pack(section, vref, evid, lo, passage, insight, rows):
    out = []
    for difficulty, typ, nn, kwargs in rows:
        pa = pb = None
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
    sec = "evg-01-encarnacao"
    vref = "João 1:14"
    evid = ["João 1:14"]
    lo = "Reconhecer que o Verbo se fez carne, habitou entre nós e revelou a glória do unigênito."
    ins = "O Verbo se fez carne — glória do unigênito entre nós."
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
                    question="O Verbo se fez carne e habitou entre nós.",
                    feedback_correct="Certo: João 1:14 afirma a encarnação do Verbo.",
                    feedback_wrong={"false": "O texto diz que o Verbo se fez carne e habitou."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em João 1:14, toque a palavra que falta em "O ___ se fez carne e habitou entre nós"?',
                    feedback_correct="Exato: o sujeito é o Verbo.",
                    feedback_wrong={
                        "b": "Carne é o que o Verbo se fez, não o sujeito.",
                        "c": "Glória aparece depois, não nesta lacuna.",
                    },
                    options=opts(("a", "Verbo"), ("b", "carne"), ("c", "glória")),
                    correct="a",
                    template="O ___ se fez carne e habitou entre nós",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que João 1:14 afirma diretamente sobre o Verbo?",
                    feedback_correct="Certo: o Verbo se fez carne e habitou entre nós.",
                    feedback_wrong={
                        "b": "O texto fala de habitação entre nós, não de distância.",
                        "c": "Ele é descrito cheio de graça e verdade, não vazio.",
                        "d": "A glória vista é como a do unigênito do Pai.",
                    },
                    options=opts(
                        ("a", "O Verbo se fez carne e habitou entre nós."),
                        ("b", "O Verbo permaneceu distante, sem habitar."),
                        ("c", "O Verbo veio vazio de graça e de verdade."),
                        ("d", "Ninguém viu glória alguma do unigênito."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em João 1:14?",
                    feedback_correct="Certo: carne, habitação e glória nessa ordem.",
                    feedback_wrong={
                        "b": "Habitar vem depois de se fazer carne.",
                        "c": "A glória vista fecha o anúncio do unigênito.",
                    },
                    options=opts(
                        ("a", "O Verbo se fez carne"),
                        ("b", "e habitou entre nós, cheio de graça e de verdade"),
                        ("c", "e vimos a sua glória, glória como do unigênito do Pai"),
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
                    question='Complete: "e habitou entre nós, cheio de ___ e de verdade"',
                    feedback_correct="Certo: ele é cheio de graça e de verdade.",
                    feedback_wrong={
                        "b": "Glória é vista depois; a lacuna é graça.",
                        "c": "Carne descreve a encarnação, não esta lacuna.",
                    },
                    options=opts(("a", "graça"), ("b", "glória"), ("c", "carne")),
                    correct="a",
                    template="e habitou entre nós, cheio de ___ e de verdade",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que João 1:14 comunica que se liga a este contexto?",
                    feedback_correct="Certo: o Verbo feito carne revela glória entre nós.",
                    feedback_wrong={
                        "b": "O texto une encarnação e glória, não ausência.",
                        "c": "Habitar entre nós é o ponto, não distância.",
                    },
                    options=opts(
                        ("a", "Verbo feito carne entre nós"),
                        ("b", "Glória sem encarnação"),
                        ("c", "Verbo distante do mundo"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Segundo João 1:14, ninguém viu a glória do unigênito do Pai.",
                    feedback_correct="Certo: o texto diz que vimos a sua glória.",
                    feedback_wrong={"true": "João 1:14 afirma: e vimos a sua glória."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em João 1:14, toque a palavra que falta em "e habitou entre nós, cheio de graça e de ___"?',
                    feedback_correct="Exato: cheio de graça e de verdade.",
                    feedback_wrong={
                        "b": "Glória vem depois; aqui é verdade.",
                        "c": "Carne descreve a encarnação, não esta lacuna.",
                    },
                    options=opts(("a", "verdade"), ("b", "glória"), ("c", "carne")),
                    correct="a",
                    template="e habitou entre nós, cheio de graça e de ___",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como João 1:14 relaciona encarnação e revelação?",
                    feedback_correct="Certo: ao habitar, o Verbo revela glória e graça.",
                    feedback_wrong={
                        "a": "O texto une carne, habitação e glória vista.",
                        "c": "A glória é como a do unigênito, não oculta.",
                        "d": "Graça e verdade acompanham a habitação.",
                    },
                    options=opts(
                        ("a", "A carne impede qualquer revelação do Pai."),
                        ("b", "Ao habitar entre nós, o Verbo revela glória e graça."),
                        ("c", "A glória do unigênito permanece totalmente oculta."),
                        ("d", "Habitar entre nós exclui graça e verdade."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de João 1:14?",
                    feedback_correct="Certo: carne, graça/verdade e glória vista.",
                    feedback_wrong={
                        "b": "Graça e verdade qualificam quem habitou.",
                        "c": "Ver a glória do unigênito fecha o encadeamento.",
                    },
                    options=opts(
                        ("a", "o Verbo se faz carne e habita entre nós"),
                        ("b", "ele é cheio de graça e de verdade"),
                        ("c", "vemos a glória como do unigênito do Pai"),
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
                    question='Complete: "glória como do ___ do Pai"',
                    feedback_correct="Certo: glória como do unigênito do Pai.",
                    feedback_wrong={
                        "b": "Verbo é o sujeito; a lacuna é unigênito.",
                        "c": "Carne descreve a encarnação, não este título.",
                    },
                    options=opts(("a", "unigênito"), ("b", "Verbo"), ("c", "carne")),
                    correct="a",
                    template="glória como do ___ do Pai",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que João 1:14 comunica que se liga a este contexto?",
                    feedback_correct="Certo: glória do unigênito vista entre nós.",
                    feedback_wrong={
                        "b": "O texto não separa carne e glória.",
                        "c": "Habitar é revelação, não esconderijo.",
                    },
                    options=opts(
                        ("a", "Glória do unigênito entre nós"),
                        ("b", "Carne sem glória alguma"),
                        ("c", "Habitar para ocultar o Pai"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="A glória vista em João 1:14 é apresentada como glória do unigênito do Pai.",
                    feedback_correct="Certo: a comparação aponta para o unigênito.",
                    feedback_wrong={"false": "O texto diz: glória como do unigênito do Pai."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em João 1:14, toque a palavra que falta em "e vimos a sua ___, glória como do unigênito do Pai"?',
                    feedback_correct="Exato: vimos a sua glória.",
                    feedback_wrong={
                        "b": "Graça qualifica quem habita, não esta lacuna.",
                        "c": "Carne descreve a encarnação, não o que se viu aqui.",
                    },
                    options=opts(("a", "glória"), ("b", "graça"), ("c", "carne")),
                    correct="a",
                    template="e vimos a sua ___, glória como do unigênito do Pai",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve entender sobre o Verbo em João 1:14?",
                    feedback_correct="Certo: Deus revelado na carne, cheio de graça.",
                    feedback_wrong={
                        "a": "O texto afirma habitação real, não aparência.",
                        "c": "A glória é vista, não negada pela carne.",
                        "d": "Graça e verdade marcam quem habitou entre nós.",
                    },
                    options=opts(
                        ("a", "O Verbo só aparenta carne, sem habitar de fato."),
                        ("b", "O unigênito revela glória habitando em graça e verdade."),
                        ("c", "A carne oculta qualquer glória do Pai."),
                        ("d", "Habitar entre nós exclui graça e verdade."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de João 1:14?",
                    feedback_correct="Certo: encarnação, habitação e glória do unigênito.",
                    feedback_wrong={
                        "b": "Habitar entre nós é o meio da revelação.",
                        "c": "A glória do unigênito interpreta quem ele é.",
                    },
                    options=opts(
                        ("a", "o Verbo se faz carne"),
                        ("b", "habita entre nós em graça e verdade"),
                        ("c", "sua glória é vista como do unigênito do Pai"),
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
                    question='Complete: "O Verbo se fez carne e ___ entre nós"',
                    feedback_correct="Certo: ele habitou entre nós.",
                    feedback_wrong={
                        "b": "Vimos refere-se à glória, não a este verbo.",
                        "c": "Fez já está no início; a lacuna é habitou.",
                    },
                    options=opts(("a", "habitou"), ("b", "vimos"), ("c", "fez")),
                    correct="a",
                    template="O Verbo se fez carne e ___ entre nós",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que João 1:14 comunica que se liga a este contexto?",
                    feedback_correct="Certo: glória do unigênito habitando entre nós.",
                    feedback_wrong={
                        "b": "O texto une carne e glória, não as opõe.",
                        "c": "O unigênito é revelado, não escondido.",
                    },
                    options=opts(
                        ("a", "Unigênito glorioso entre nós"),
                        ("b", "Carne sem glória do Pai"),
                        ("c", "Glória sem habitação real"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_2():
    sec = "evg-02-batismo"
    vref = "Mateus 3:16–17"
    evid = ["Mateus 3:16", "Mateus 3:17"]
    lo = "Identificar no batismo os céus abertos, o Espírito e a voz do Pai sobre o Filho."
    ins = "Batismo: céus abertos, Espírito e voz do Pai."
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
                    question="Batizado que foi Jesus, saiu logo da água.",
                    feedback_correct="Certo: Mateus 3:16 começa assim.",
                    feedback_wrong={"false": "O texto afirma que Jesus saiu logo da água."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 3:16–17, toque a palavra que falta em "eis que se abriram os ___"?',
                    feedback_correct="Exato: abriram-se os céus.",
                    feedback_wrong={
                        "b": "Água é de onde ele sai, não o que se abre.",
                        "c": "Pomba descreve o Espírito, não esta lacuna.",
                    },
                    options=opts(("a", "céus"), ("b", "água"), ("c", "pomba")),
                    correct="a",
                    template="eis que se abriram os ___",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que o texto afirma após Jesus sair da água?",
                    feedback_correct="Certo: os céus se abriram e o Espírito desceu.",
                    feedback_wrong={
                        "b": "O texto fala de céus abertos, não fechados.",
                        "c": "O Espírito desce como pomba, não permanece oculto.",
                        "d": "Há uma voz dos céus sobre o Filho dileto.",
                    },
                    options=opts(
                        ("a", "Abriram-se os céus e o Espírito desceu como pomba."),
                        ("b", "Os céus permaneceram fechados e mudos."),
                        ("c", "Nenhum Espírito veio sobre Jesus."),
                        ("d", "Nenhuma voz falou dos céus."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Mateus 3:16–17?",
                    feedback_correct="Certo: água, Espírito e voz nessa ordem.",
                    feedback_wrong={
                        "b": "O Espírito desce depois dos céus abertos.",
                        "c": "A voz dos céus fecha a cena.",
                    },
                    options=opts(
                        ("a", "Batizado que foi Jesus, saiu logo da água"),
                        ("b", "veio o Espírito de Deus descer como pomba e vir sobre ele"),
                        ("c", "uma voz dos céus disse: Este é o meu Filho dileto"),
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
                    question='Complete: "Este é o meu Filho ___, em quem me agrado"',
                    feedback_correct="Certo: o Filho dileto.",
                    feedback_wrong={
                        "b": "Pomba descreve o Espírito, não o Filho.",
                        "c": "Água é o lugar do batismo, não este título.",
                    },
                    options=opts(("a", "dileto"), ("b", "pomba"), ("c", "água")),
                    correct="a",
                    template="Este é o meu Filho ___, em quem me agrado",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 3:16–17 comunica que se liga a este contexto?",
                    feedback_correct="Certo: céus, Espírito e voz do Pai se unem.",
                    feedback_wrong={
                        "b": "O texto não omite o Espírito.",
                        "c": "Há voz clara dos céus sobre o Filho.",
                    },
                    options=opts(
                        ("a", "Céus, Espírito e voz do Pai"),
                        ("b", "Batismo sem Espírito"),
                        ("c", "Céus mudos sobre Jesus"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="A voz dos céus em Mateus 3:17 chama Jesus de Filho dileto.",
                    feedback_correct="Certo: Este é o meu Filho dileto.",
                    feedback_wrong={"false": "A voz diz: Este é o meu Filho dileto."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 3:16–17, toque a palavra que falta em "veio o Espírito de Deus descer como ___"?',
                    feedback_correct="Exato: como pomba.",
                    feedback_wrong={
                        "b": "Céus se abriram; a comparação é pomba.",
                        "c": "Água é o batismo, não esta imagem.",
                    },
                    options=opts(("a", "pomba"), ("b", "céus"), ("c", "água")),
                    correct="a",
                    template="veio o Espírito de Deus descer como ___",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como Mateus 3:16–17 relaciona Espírito e voz do Pai?",
                    feedback_correct="Certo: o Espírito desce e o Pai identifica o Filho.",
                    feedback_wrong={
                        "a": "O texto une descida do Espírito e voz dos céus.",
                        "c": "A voz afirma agrado no Filho, não rejeição.",
                        "d": "O Espírito vem sobre ele, não fica ausente.",
                    },
                    options=opts(
                        ("a", "O Espírito desce, mas o Pai permanece em silêncio."),
                        ("b", "O Espírito desce e o Pai declara o Filho dileto."),
                        ("c", "A voz dos céus rejeita Jesus após o batismo."),
                        ("d", "Só há água; nenhum sinal do céu acompanha."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Mateus 3:16–17?",
                    feedback_correct="Certo: saída da água, céus abertos e voz.",
                    feedback_wrong={
                        "b": "Os céus se abrem depois da saída da água.",
                        "c": "A voz interpreta quem é o Filho dileto.",
                    },
                    options=opts(
                        ("a", "Jesus sai da água após o batismo"),
                        ("b", "os céus se abrem e o Espírito desce como pomba"),
                        ("c", "a voz declara: Este é o meu Filho dileto"),
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
                    question='Complete: "em quem me ___"',
                    feedback_correct="Certo: em quem me agrado.",
                    feedback_wrong={
                        "b": "Abriram refere-se aos céus, não a esta lacuna.",
                        "c": "Descer descreve o Espírito, não o verbo da voz.",
                    },
                    options=opts(("a", "agrado"), ("b", "abriram"), ("c", "descer")),
                    correct="a",
                    template="em quem me ___",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 3:16–17 comunica que se liga a este contexto?",
                    feedback_correct="Certo: o Pai identifica o Filho dileto.",
                    feedback_wrong={
                        "b": "Há revelação clara, não silêncio.",
                        "c": "O Espírito marca a cena, não a cancela.",
                    },
                    options=opts(
                        ("a", "Pai identifica o Filho dileto"),
                        ("b", "Céus sem palavra alguma"),
                        ("c", "Espírito ausente no batismo"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="No batismo, a voz dos céus apresenta Jesus sem qualquer agrado do Pai.",
                    feedback_correct="Certo: o Pai diz em quem me agrado.",
                    feedback_wrong={"true": "A voz afirma: em quem me agrado."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 3:16–17, toque a palavra que falta em "Este é o meu ___ dileto, em quem me agrado"?',
                    feedback_correct="Exato: Filho dileto.",
                    feedback_wrong={
                        "b": "Espírito desce; a voz fala do Filho.",
                        "c": "Céus é de onde vem a voz, não o título.",
                    },
                    options=opts(("a", "Filho"), ("b", "Espírito"), ("c", "céus")),
                    correct="a",
                    template="Este é o meu ___ dileto, em quem me agrado",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve entender sobre o batismo em Mateus 3:16–17?",
                    feedback_correct="Certo: o Pai e o Espírito revelam quem é Jesus.",
                    feedback_wrong={
                        "a": "Há sinais claros: céus, Espírito e voz.",
                        "c": "A voz afirma agrado, não dúvida.",
                        "d": "O Espírito desce sobre ele de forma explícita.",
                    },
                    options=opts(
                        ("a", "O batismo é só rito humano, sem sinal do céu."),
                        ("b", "Pai e Espírito revelam Jesus como Filho dileto."),
                        ("c", "A voz dos céus deixa a identidade de Jesus em dúvida."),
                        ("d", "O Espírito permanece longe de Jesus neste texto."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Mateus 3:16–17?",
                    feedback_correct="Certo: céus abertos, Espírito e declaração do Pai.",
                    feedback_wrong={
                        "b": "O Espírito marca a presença divina sobre Jesus.",
                        "c": "A voz interpreta o sentido da cena.",
                    },
                    options=opts(
                        ("a", "os céus se abrem sobre o batizado"),
                        ("b", "o Espírito desce como pomba sobre ele"),
                        ("c", "o Pai declara o Filho dileto em quem se agrada"),
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
                    question='Complete: "veio o ___ de Deus descer como pomba"',
                    feedback_correct="Certo: o Espírito de Deus.",
                    feedback_wrong={
                        "b": "Filho é o título da voz, não quem desce aqui.",
                        "c": "Céus se abriram; quem desce é o Espírito.",
                    },
                    options=opts(("a", "Espírito"), ("b", "Filho"), ("c", "céus")),
                    correct="a",
                    template="veio o ___ de Deus descer como pomba",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 3:16–17 comunica que se liga a este contexto?",
                    feedback_correct="Certo: revelação trinitária no batismo.",
                    feedback_wrong={
                        "b": "O texto une céus, Espírito e voz.",
                        "c": "O Filho é declarado dileto, não rejeitado.",
                    },
                    options=opts(
                        ("a", "Revelação do Filho dileto"),
                        ("b", "Batismo sem céus abertos"),
                        ("c", "Pai calado sobre Jesus"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_3():
    sec = "evg-03-tentacao"
    vref = "Mateus 4:1–4"
    evid = ["Mateus 4:1", "Mateus 4:2", "Mateus 4:3", "Mateus 4:4"]
    lo = "Ver que Jesus, tentado no deserto, responde com a Palavra e não com pedras."
    ins = "Tentação: Jesus responde com a Palavra, não com pedras."
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
                    question="Jesus foi levado pelo Espírito ao deserto, para ser tentado pelo Diabo.",
                    feedback_correct="Certo: Mateus 4:1 afirma isso.",
                    feedback_wrong={"false": "O texto diz que foi levado para ser tentado."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 4:1–4, toque a palavra que falta em "Então foi levado Jesus pelo Espírito ao ___"?',
                    feedback_correct="Exato: ao deserto.",
                    feedback_wrong={
                        "b": "Diabo é o tentador, não o lugar.",
                        "c": "Pão aparece na tentação, não nesta lacuna.",
                    },
                    options=opts(("a", "deserto"), ("b", "Diabo"), ("c", "pão")),
                    correct="a",
                    template="Então foi levado Jesus pelo Espírito ao ___",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que o tentador propõe a Jesus em Mateus 4:3?",
                    feedback_correct="Certo: mandar que as pedras se tornem em pães.",
                    feedback_wrong={
                        "b": "O texto fala de pedras em pães, não de fuga.",
                        "c": "A proposta usa a condição Se és Filho de Deus.",
                        "d": "Jesus ainda não responde com milagre de pedras.",
                    },
                    options=opts(
                        ("a", "Manda que estas pedras se tornem em pães."),
                        ("b", "Foge do deserto sem responder."),
                        ("c", "Nega ser Filho de Deus diante do tentador."),
                        ("d", "Pede ao Diabo que multiplique o pão."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Mateus 4:1–4?",
                    feedback_correct="Certo: deserto, jejum e resposta da Palavra.",
                    feedback_wrong={
                        "b": "O jejum precede a chegada do tentador.",
                        "c": "A resposta com a Escritura fecha a cena.",
                    },
                    options=opts(
                        ("a", "foi levado Jesus pelo Espírito ao deserto"),
                        ("b", "depois de jejuar quarenta dias e noites, teve fome"),
                        ("c", "Jesus respondeu: Está escrito: Não só de pão viverá o homem"),
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
                    question='Complete: "Não só de ___ viverá o homem"',
                    feedback_correct="Certo: não só de pão.",
                    feedback_wrong={
                        "b": "Pedras é a proposta do tentador, não a citação.",
                        "c": "Palavra completa a frase depois; aqui é pão.",
                    },
                    options=opts(("a", "pão"), ("b", "pedras"), ("c", "palavra")),
                    correct="a",
                    template="Não só de ___ viverá o homem",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 4:1–4 comunica que se liga a este contexto?",
                    feedback_correct="Certo: Jesus responde com a Palavra.",
                    feedback_wrong={
                        "b": "Ele não cede às pedras em pães.",
                        "c": "A resposta cita o que está escrito.",
                    },
                    options=opts(
                        ("a", "Resposta com a Palavra"),
                        ("b", "Vitória pelas pedras em pães"),
                        ("c", "Silêncio diante do tentador"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Jesus responde à tentação transformando as pedras em pães.",
                    feedback_correct="Certo: ele responde com Está escrito, não com milagre.",
                    feedback_wrong={"true": "Jesus cita a Escritura; não manda nas pedras."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 4:1–4, toque a palavra que falta em "mas de toda ___ que sai da boca de Deus"?',
                    feedback_correct="Exato: toda palavra.",
                    feedback_wrong={
                        "b": "Pão é o contraste; a lacuna é palavra.",
                        "c": "Pedras é a proposta do tentador.",
                    },
                    options=opts(("a", "palavra"), ("b", "pão"), ("c", "pedras")),
                    correct="a",
                    template="mas de toda ___ que sai da boca de Deus",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como Mateus 4:1–4 encadeia fome e resposta de Jesus?",
                    feedback_correct="Certo: a fome é real, mas a Palavra sustenta.",
                    feedback_wrong={
                        "a": "Jesus não nega a fome; responde com a Escritura.",
                        "c": "Ele cita o que sai da boca de Deus.",
                        "d": "A tentação usa a condição Filho de Deus.",
                    },
                    options=opts(
                        ("a", "A fome prova que a Palavra não importa."),
                        ("b", "Mesmo com fome, Jesus vive da palavra de Deus."),
                        ("c", "Jesus aceita a proposta das pedras em pães."),
                        ("d", "O tentador cita a Escritura e Jesus cala."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Mateus 4:1–4?",
                    feedback_correct="Certo: tentação, proposta e citação da Escritura.",
                    feedback_wrong={
                        "b": "A proposta das pedras vem após a fome.",
                        "c": "A resposta escrita fecha o encadeamento.",
                    },
                    options=opts(
                        ("a", "Jesus é tentado no deserto após o jejum"),
                        ("b", "o tentador propõe pedras tornadas em pães"),
                        ("c", "Jesus responde com o que está escrito"),
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
                    question='Complete: "Depois de jejuar ___ dias e quarenta noites"',
                    feedback_correct="Certo: quarenta dias.",
                    feedback_wrong={
                        "b": "Pedras não é número de dias.",
                        "c": "Pão é a proposta, não a duração.",
                    },
                    options=opts(("a", "quarenta"), ("b", "pedras"), ("c", "pão")),
                    correct="a",
                    template="Depois de jejuar ___ dias e quarenta noites",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 4:1–4 comunica que se liga a este contexto?",
                    feedback_correct="Certo: viver da palavra, não só do pão.",
                    feedback_wrong={
                        "b": "Jesus não cede à proposta das pedras.",
                        "c": "A Escritura é a resposta, não o milagre pedido.",
                    },
                    options=opts(
                        ("a", "Viver da palavra de Deus"),
                        ("b", "Ceder às pedras em pães"),
                        ("c", "Ignorar o que está escrito"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Jesus ensina que o homem vive também de toda palavra que sai da boca de Deus.",
                    feedback_correct="Certo: essa é a citação que sustenta a resposta.",
                    feedback_wrong={"false": "Mateus 4:4 cita exatamente essa verdade."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 4:1–4, toque a palavra que falta em "Mas Jesus respondeu: Está ___"?',
                    feedback_correct="Exato: Está escrito.",
                    feedback_wrong={
                        "b": "Tentado descreve a cena, não a resposta.",
                        "c": "Fome é a condição, não a citação.",
                    },
                    options=opts(("a", "escrito"), ("b", "tentado"), ("c", "fome")),
                    correct="a",
                    template="Mas Jesus respondeu: Está ___",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve entender sobre a tentação em Mateus 4:1–4?",
                    feedback_correct="Certo: o Filho responde com a Palavra, não com atalho.",
                    feedback_wrong={
                        "a": "A fome não anula a autoridade da Escritura.",
                        "c": "Jesus não aceita a proposta das pedras.",
                        "d": "A resposta cita a boca de Deus, não o Diabo.",
                    },
                    options=opts(
                        ("a", "A fome autoriza qualquer atalho do tentador."),
                        ("b", "O Filho vive pela palavra, não pelo milagre pedido."),
                        ("c", "Transformar pedras prova fielmente a filiação."),
                        ("d", "A Escritura é irrelevante diante da fome."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Mateus 4:1–4?",
                    feedback_correct="Certo: tentação, proposta e fidelidade à Palavra.",
                    feedback_wrong={
                        "b": "A proposta testa a filiação pelo milagre.",
                        "c": "A citação revela de que vive o homem.",
                    },
                    options=opts(
                        ("a", "o Espírito leva Jesus ao deserto para a tentação"),
                        ("b", "o tentador usa a fome e a condição Filho de Deus"),
                        ("c", "Jesus afirma: o homem vive da palavra de Deus"),
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
                    question='Complete: "Se és Filho de Deus, manda que estas ___ se tornem em pães"',
                    feedback_correct="Certo: estas pedras.",
                    feedback_wrong={
                        "b": "Palavra é a resposta de Jesus, não a proposta.",
                        "c": "Pão é o resultado pedido, não o objeto.",
                    },
                    options=opts(("a", "pedras"), ("b", "palavra"), ("c", "pão")),
                    correct="a",
                    template="Se és Filho de Deus, manda que estas ___ se tornem em pães",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 4:1–4 comunica que se liga a este contexto?",
                    feedback_correct="Certo: fidelidade à Palavra sob tentação.",
                    feedback_wrong={
                        "b": "O milagre pedido não é a resposta de Jesus.",
                        "c": "A Escritura é o centro da resistência.",
                    },
                    options=opts(
                        ("a", "Fidelidade pela Palavra"),
                        ("b", "Prova por milagre de pedras"),
                        ("c", "Palavra sem peso na tentação"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_4():
    sec = "evg-boss-01"
    vref = "João 1:14; Mateus 3:17"
    evid = ["João 1:14", "Mateus 3:17"]
    lo = "Unir encarnação e batismo: o Verbo feito carne é o Filho dileto do Pai."
    ins = "O Início: Verbo feito carne e Filho dileto."
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
                    question="O Verbo se fez carne e habitou entre nós.",
                    feedback_correct="Certo: João 1:14 está no fio do início.",
                    feedback_wrong={"false": "O texto do início afirma a encarnação."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em João 1:14; Mateus 3:17, toque a palavra que falta em "O ___ se fez carne e habitou entre nós"?',
                    feedback_correct="Exato: o Verbo.",
                    feedback_wrong={
                        "b": "Filho é o título da voz; aqui é Verbo.",
                        "c": "Dileto qualifica o Filho, não esta lacuna.",
                    },
                    options=opts(("a", "Verbo"), ("b", "Filho"), ("c", "dileto")),
                    correct="a",
                    template="O ___ se fez carne e habitou entre nós",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que os textos unidos afirmam sobre Jesus no início?",
                    feedback_correct="Certo: Verbo feito carne e Filho dileto.",
                    feedback_wrong={
                        "b": "Há encarnação e declaração do Pai.",
                        "c": "A voz chama-o Filho dileto.",
                        "d": "Ele habitou entre nós, cheio de graça.",
                    },
                    options=opts(
                        ("a", "É Verbo feito carne e Filho dileto do Pai."),
                        ("b", "Permanece só palavra, sem carne."),
                        ("c", "O Pai não fala sobre ele no batismo."),
                        ("d", "Ninguém vê glória nem ouve voz alguma."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em João 1:14; Mateus 3:17?",
                    feedback_correct="Certo: carne, glória e voz do Pai.",
                    feedback_wrong={
                        "b": "A glória do unigênito segue a encarnação.",
                        "c": "A voz do batismo declara o Filho dileto.",
                    },
                    options=opts(
                        ("a", "O Verbo se fez carne e habitou entre nós"),
                        ("b", "vimos a sua glória, glória como do unigênito do Pai"),
                        ("c", "Este é o meu Filho dileto, em quem me agrado"),
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
                    question='Complete: "Este é o meu Filho ___, em quem me agrado"',
                    feedback_correct="Certo: Filho dileto.",
                    feedback_wrong={
                        "b": "Verbo é de João 1:14; aqui é dileto.",
                        "c": "Carne descreve a encarnação, não o título.",
                    },
                    options=opts(("a", "dileto"), ("b", "Verbo"), ("c", "carne")),
                    correct="a",
                    template="Este é o meu Filho ___, em quem me agrado",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que João 1:14; Mateus 3:17 comunica que se liga a este contexto?",
                    feedback_correct="Certo: Verbo feito carne e Filho dileto.",
                    feedback_wrong={
                        "b": "Os textos unem encarnação e declaração.",
                        "c": "Há identidade clara, não anonimato.",
                    },
                    options=opts(
                        ("a", "Verbo feito carne e Filho"),
                        ("b", "Carne sem voz do Pai"),
                        ("c", "Filho sem encarnação"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="A voz dos céus em Mateus 3:17 diz que o Pai não se agrada do Filho.",
                    feedback_correct="Certo: o Pai diz em quem me agrado.",
                    feedback_wrong={"true": "A voz afirma agrado no Filho dileto."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em João 1:14; Mateus 3:17, toque a palavra que falta em "e vimos a sua ___, glória como do unigênito do Pai"?',
                    feedback_correct="Exato: vimos a sua glória.",
                    feedback_wrong={
                        "b": "Graça qualifica quem habita; aqui é glória.",
                        "c": "Dileto é o título da voz do Pai.",
                    },
                    options=opts(("a", "glória"), ("b", "graça"), ("c", "dileto")),
                    correct="a",
                    template="e vimos a sua ___, glória como do unigênito do Pai",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como João 1:14 e Mateus 3:17 se relacionam no início do Evangelho?",
                    feedback_correct="Certo: encarnação e declaração do Pai se confirmam.",
                    feedback_wrong={
                        "a": "Os textos se reforçam, não se contradizem.",
                        "c": "A voz identifica o mesmo que habitou entre nós.",
                        "d": "Há revelação clara da identidade de Jesus.",
                    },
                    options=opts(
                        ("a", "A encarnação anula a voz do Pai no batismo."),
                        ("b", "O Verbo encarnado é declarado Filho dileto."),
                        ("c", "O batismo nega que o Verbo habitou entre nós."),
                        ("d", "Os textos tratam de duas pessoas diferentes."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de João 1:14; Mateus 3:17?",
                    feedback_correct="Certo: carne, habitação e declaração do Pai.",
                    feedback_wrong={
                        "b": "Habitar em graça prepara a revelação.",
                        "c": "A voz do Pai confirma o Filho dileto.",
                    },
                    options=opts(
                        ("a", "o Verbo se faz carne"),
                        ("b", "habita entre nós cheio de graça e verdade"),
                        ("c", "o Pai declara: Este é o meu Filho dileto"),
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
                    question='Complete: "O Verbo se fez carne e ___ entre nós"',
                    feedback_correct="Certo: habitou entre nós.",
                    feedback_wrong={
                        "b": "Vimos refere-se à glória, não a este verbo.",
                        "c": "Agrado é da voz do Pai, não desta lacuna.",
                    },
                    options=opts(("a", "habitou"), ("b", "vimos"), ("c", "agrado")),
                    correct="a",
                    template="O Verbo se fez carne e ___ entre nós",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que João 1:14; Mateus 3:17 comunica que se liga a este contexto?",
                    feedback_correct="Certo: o início une encarnação e Filho dileto.",
                    feedback_wrong={
                        "b": "Não há ruptura entre os textos.",
                        "c": "O Pai se agrada do mesmo que habitou.",
                    },
                    options=opts(
                        ("a", "Início: carne e Filho dileto"),
                        ("b", "Encarnação contra o batismo"),
                        ("c", "Pai sem agrado no Filho"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="O início dos Evangelhos apresenta Jesus como unigênito habitando e como Filho dileto do Pai.",
                    feedback_correct="Certo: os dois textos formam esse fio.",
                    feedback_wrong={"false": "João 1:14 e Mateus 3:17 sustentam essa leitura."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em João 1:14; Mateus 3:17, toque a palavra que falta em "glória como do ___ do Pai"?',
                    feedback_correct="Exato: unigênito do Pai.",
                    feedback_wrong={
                        "b": "Dileto é de Mateus 3:17; aqui é unigênito.",
                        "c": "Verbo é o sujeito; a lacuna é unigênito.",
                    },
                    options=opts(("a", "unigênito"), ("b", "dileto"), ("c", "Verbo")),
                    correct="a",
                    template="glória como do ___ do Pai",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve levar do início em João 1:14; Mateus 3:17?",
                    feedback_correct="Certo: o Verbo encarnado é o Filho dileto.",
                    feedback_wrong={
                        "a": "Os textos revelam, não ocultam, a identidade.",
                        "c": "Carne e voz do Pai se complementam.",
                        "d": "Há agrado do Pai, não indiferença.",
                    },
                    options=opts(
                        ("a", "A identidade de Jesus permanece totalmente oculta."),
                        ("b", "O Verbo feito carne é o Filho dileto do Pai."),
                        ("c", "A encarnação e o batismo se contradizem."),
                        ("d", "O Pai se agrada de outro, não deste Filho."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de João 1:14; Mateus 3:17?",
                    feedback_correct="Certo: encarnação, glória e declaração do Pai.",
                    feedback_wrong={
                        "b": "A glória do unigênito interpreta quem habitou.",
                        "c": "A voz confirma o Filho dileto.",
                    },
                    options=opts(
                        ("a", "o Verbo se faz carne e habita entre nós"),
                        ("b", "sua glória é vista como do unigênito"),
                        ("c", "o Pai declara o Filho dileto em quem se agrada"),
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
                    question='Complete: "em quem me ___"',
                    feedback_correct="Certo: em quem me agrado.",
                    feedback_wrong={
                        "b": "Habitou é de João 1:14; aqui é agrado.",
                        "c": "Fez descreve a encarnação, não a voz.",
                    },
                    options=opts(("a", "agrado"), ("b", "habitou"), ("c", "fez")),
                    correct="a",
                    template="em quem me ___",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que João 1:14; Mateus 3:17 comunica que se liga a este contexto?",
                    feedback_correct="Certo: o Início une Verbo e Filho dileto.",
                    feedback_wrong={
                        "b": "Não há divisão entre os textos.",
                        "c": "A revelação é positiva e clara.",
                    },
                    options=opts(
                        ("a", "Verbo e Filho dileto unidos"),
                        ("b", "Início sem revelação"),
                        ("c", "Carne contra a voz do Pai"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_5():
    sec = "evg-04-sermao"
    vref = "Mateus 5:3–6"
    evid = ["Mateus 5:3", "Mateus 5:4", "Mateus 5:5", "Mateus 5:6"]
    lo = "Reconhecer que o reino é dos humildes, mansos e famintos de justiça."
    ins = "Bem-aventuranças: o reino aos humildes, mansos e famintos de justiça."
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
                    question="Bem-aventurados os humildes de espírito, porque deles é o reino dos céus.",
                    feedback_correct="Certo: Mateus 5:3 afirma isso.",
                    feedback_wrong={"false": "O texto dá o reino aos humildes de espírito."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:3–6, toque a palavra que falta em "Bem-aventurados os ___ de espírito"?',
                    feedback_correct="Exato: humildes de espírito.",
                    feedback_wrong={
                        "b": "Mansos aparece depois; aqui é humildes.",
                        "c": "Fartos é a promessa dos que têm fome.",
                    },
                    options=opts(("a", "humildes"), ("b", "mansos"), ("c", "fartos")),
                    correct="a",
                    template="Bem-aventurados os ___ de espírito",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que Mateus 5:3 afirma sobre os humildes de espírito?",
                    feedback_correct="Certo: deles é o reino dos céus.",
                    feedback_wrong={
                        "b": "O reino lhes é dado, não negado.",
                        "c": "A bem-aventurança é explícita.",
                        "d": "O texto não os exclui do reino.",
                    },
                    options=opts(
                        ("a", "Deles é o reino dos céus."),
                        ("b", "Deles não é o reino dos céus."),
                        ("c", "São amaldiçoados, não bem-aventurados."),
                        ("d", "Herdarão só a terra, nunca o reino."),
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
                    feedback_correct="Certo: humildes, choram e mansos.",
                    feedback_wrong={
                        "b": "Os que choram vêm depois dos humildes.",
                        "c": "Os mansos seguem nessa ordem do texto.",
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
                    question='Complete: "porque eles herdarão a ___"',
                    feedback_correct="Certo: herdarão a terra.",
                    feedback_wrong={
                        "b": "Céus é dos humildes; aqui é terra.",
                        "c": "Justiça é da fome e sede, não desta lacuna.",
                    },
                    options=opts(("a", "terra"), ("b", "céus"), ("c", "justiça")),
                    correct="a",
                    template="porque eles herdarão a ___",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:3–6 comunica que se liga a este contexto?",
                    feedback_correct="Certo: reino aos humildes e famintos de justiça.",
                    feedback_wrong={
                        "b": "O texto abençoa os humildes, não os orgulhosos.",
                        "c": "Há fome de justiça, não indiferença.",
                    },
                    options=opts(
                        ("a", "Reino aos humildes e mansos"),
                        ("b", "Reino só aos orgulhosos"),
                        ("c", "Sem fome de justiça"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Os que têm fome e sede de justiça serão fartos, segundo Mateus 5:6.",
                    feedback_correct="Certo: eles serão fartos.",
                    feedback_wrong={"false": "O texto promete: serão fartos."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:3–6, toque a palavra que falta em "Bem-aventurados os que choram, porque eles serão ___"?',
                    feedback_correct="Exato: serão consolados.",
                    feedback_wrong={
                        "b": "Fartos é dos que têm fome de justiça.",
                        "c": "Mansos herdam a terra; aqui é consolados.",
                    },
                    options=opts(("a", "consolados"), ("b", "fartos"), ("c", "mansos")),
                    correct="a",
                    template="Bem-aventurados os que choram, porque eles serão ___",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como Mateus 5:3–6 relaciona humildade e reino?",
                    feedback_correct="Certo: o reino é dos humildes de espírito.",
                    feedback_wrong={
                        "a": "O texto dá o reino aos humildes.",
                        "c": "Mansidão e fome de justiça também são bem-aventuradas.",
                        "d": "Há consolação e fartura prometidas.",
                    },
                    options=opts(
                        ("a", "O reino exclui os humildes de espírito."),
                        ("b", "O reino dos céus é dos humildes de espírito."),
                        ("c", "Só os mansos recebem o reino dos céus."),
                        ("d", "Fome de justiça não recebe promessa alguma."),
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
                    feedback_correct="Certo: reino, consolação e herança da terra.",
                    feedback_wrong={
                        "b": "Os que choram serão consolados.",
                        "c": "Os mansos herdam a terra nessa ordem.",
                    },
                    options=opts(
                        ("a", "aos humildes é dado o reino dos céus"),
                        ("b", "os que choram serão consolados"),
                        ("c", "os mansos herdarão a terra"),
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
                    question='Complete: "Bem-aventurados os que têm fome e sede de ___"',
                    feedback_correct="Certo: fome e sede de justiça.",
                    feedback_wrong={
                        "b": "Terra é a herança dos mansos.",
                        "c": "Céus é o reino dos humildes.",
                    },
                    options=opts(("a", "justiça"), ("b", "terra"), ("c", "céus")),
                    correct="a",
                    template="Bem-aventurados os que têm fome e sede de ___",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:3–6 comunica que se liga a este contexto?",
                    feedback_correct="Certo: bem-aventurança no caminho do reino.",
                    feedback_wrong={
                        "b": "O texto valoriza humildade, não orgulho.",
                        "c": "Há promessas concretas, não vazio.",
                    },
                    options=opts(
                        ("a", "Bem-aventurança do reino"),
                        ("b", "Orgulho como caminho"),
                        ("c", "Sem promessa aos mansos"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Nas bem-aventuranças, o reino dos céus é apresentado como dos orgulhosos de espírito.",
                    feedback_correct="Certo: é dos humildes de espírito.",
                    feedback_wrong={"true": "Mateus 5:3 diz: humildes de espírito."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:3–6, toque a palavra que falta em "Bem-aventurados os ___, porque eles herdarão a terra"?',
                    feedback_correct="Exato: os mansos.",
                    feedback_wrong={
                        "b": "Humildes recebem o reino; aqui são mansos.",
                        "c": "Fartos é a promessa da justiça.",
                    },
                    options=opts(("a", "mansos"), ("b", "humildes"), ("c", "fartos")),
                    correct="a",
                    template="Bem-aventurados os ___, porque eles herdarão a terra",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve entender sobre o reino em Mateus 5:3–6?",
                    feedback_correct="Certo: o reino abraça humildes e famintos de justiça.",
                    feedback_wrong={
                        "a": "O texto inverte a lógica do orgulho.",
                        "c": "Há consolação e fartura prometidas.",
                        "d": "Mansidão herda a terra, não é desprezada.",
                    },
                    options=opts(
                        ("a", "O reino favorece o orgulho e a autoafirmação."),
                        ("b", "O reino é dos humildes, mansos e famintos de justiça."),
                        ("c", "Chorar e ter fome de justiça não têm promessa."),
                        ("d", "Os mansos são excluídos de qualquer herança."),
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
                    feedback_correct="Certo: humildade, mansidão e fome de justiça.",
                    feedback_wrong={
                        "b": "A mansidão herda a terra no caminho do reino.",
                        "c": "A fome de justiça recebe fartura.",
                    },
                    options=opts(
                        ("a", "humildes de espírito recebem o reino"),
                        ("b", "mansos herdam a terra"),
                        ("c", "quem tem fome de justiça será farto"),
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
                    question='Complete: "porque deles é o reino dos ___"',
                    feedback_correct="Certo: reino dos céus.",
                    feedback_wrong={
                        "b": "Terra é dos mansos; aqui é céus.",
                        "c": "Justiça é da fome e sede.",
                    },
                    options=opts(("a", "céus"), ("b", "terra"), ("c", "justiça")),
                    correct="a",
                    template="porque deles é o reino dos ___",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:3–6 comunica que se liga a este contexto?",
                    feedback_correct="Certo: o reino aos humildes e famintos de justiça.",
                    feedback_wrong={
                        "b": "O texto não exalta o orgulho.",
                        "c": "Há bem-aventurança, não maldição.",
                    },
                    options=opts(
                        ("a", "Reino aos humildes e justos"),
                        ("b", "Reino aos orgulhosos"),
                        ("c", "Bem-aventurança vazia"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_6():
    sec = "evg-05-parabolas"
    vref = "Mateus 13:3–8"
    evid = ["Mateus 13:3", "Mateus 13:4", "Mateus 13:5", "Mateus 13:7", "Mateus 13:8"]
    lo = "Ver que a semente encontra solos diferentes e o reino exige ouvidos."
    ins = "Parábolas: a semente encontra solos — o reino exige ouvidos."
    p = P6
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
                    question="O semeador saiu a semear.",
                    feedback_correct="Certo: Mateus 13:3 afirma isso.",
                    feedback_wrong={"false": "O texto começa: o semeador saiu a semear."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 13:3–8, toque a palavra que falta em "O ___ saiu a semear"?',
                    feedback_correct="Exato: o semeador.",
                    feedback_wrong={
                        "b": "Semente é o que cai; o sujeito é semeador.",
                        "c": "Espinhos é um dos solos, não o sujeito.",
                    },
                    options=opts(("a", "semeador"), ("b", "semente"), ("c", "espinhos")),
                    correct="a",
                    template="O ___ saiu a semear",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que acontece à semente à beira do caminho?",
                    feedback_correct="Certo: as aves vieram e comeram-na.",
                    feedback_wrong={
                        "b": "Não dá fruto aí; as aves a comem.",
                        "c": "Solo pedregoso é outro caso.",
                        "d": "Terra boa é o solo frutífero.",
                    },
                    options=opts(
                        ("a", "Vieram as aves e comeram-na."),
                        ("b", "Deu fruto a cem por um."),
                        ("c", "Queimou-se por falta de raiz."),
                        ("d", "Os espinhos a sufocaram."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Mateus 13:3–8?",
                    feedback_correct="Certo: caminho, pedregoso e terra boa.",
                    feedback_wrong={
                        "b": "Solo pedregoso vem depois do caminho.",
                        "c": "Terra boa e fruto fecham a parábola.",
                    },
                    options=opts(
                        ("a", "uma parte da semente caiu à beira do caminho"),
                        ("b", "outra caiu em solo pedregoso"),
                        ("c", "outra caiu em terra boa e dava fruto"),
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
                    question='Complete: "Outra, porém, caiu em terra ___ e dava fruto"',
                    feedback_correct="Certo: terra boa.",
                    feedback_wrong={
                        "b": "Pedregoso é outro solo, sem raiz profunda.",
                        "c": "Caminho é onde as aves comem.",
                    },
                    options=opts(("a", "boa"), ("b", "pedregoso"), ("c", "caminho")),
                    correct="a",
                    template="Outra, porém, caiu em terra ___ e dava fruto",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 13:3–8 comunica que se liga a este contexto?",
                    feedback_correct="Certo: a semente encontra solos diferentes.",
                    feedback_wrong={
                        "b": "Há vários solos, não um só.",
                        "c": "Terra boa dá fruto; o contraste importa.",
                    },
                    options=opts(
                        ("a", "Semente encontra vários solos"),
                        ("b", "Só existe um solo único"),
                        ("c", "Nenhum solo dá fruto"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="A semente em solo pedregoso secou-se por não ter raiz.",
                    feedback_correct="Certo: por não ter raiz, secou-se.",
                    feedback_wrong={"false": "O texto diz: por não ter raiz, secou-se."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 13:3–8, toque a palavra que falta em "Outra caiu entre os ___, e os espinhos cresceram e a sufocaram"?',
                    feedback_correct="Exato: entre os espinhos.",
                    feedback_wrong={
                        "b": "Aves comem a do caminho, não esta.",
                        "c": "Raiz falta no pedregoso.",
                    },
                    options=opts(("a", "espinhos"), ("b", "aves"), ("c", "raiz")),
                    correct="a",
                    template="Outra caiu entre os ___, e os espinhos cresceram e a sufocaram",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como Mateus 13:3–8 diferencia os solos da semente?",
                    feedback_correct="Certo: só a terra boa produz fruto duradouro.",
                    feedback_wrong={
                        "a": "Há contrastes claros entre os solos.",
                        "c": "Pedregoso nasce logo, mas seca.",
                        "d": "Espinhos sufocam; não igualam a terra boa.",
                    },
                    options=opts(
                        ("a", "Todos os solos dão o mesmo fruto."),
                        ("b", "Só a terra boa dá fruto; os outros falham."),
                        ("c", "Solo pedregoso é o único que dá fruto."),
                        ("d", "Espinhos aumentam o fruto da semente."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Mateus 13:3–8?",
                    feedback_correct="Certo: semear, solos e fruto na terra boa.",
                    feedback_wrong={
                        "b": "Os solos distintos recebem a semente.",
                        "c": "O fruto na terra boa fecha o contraste.",
                    },
                    options=opts(
                        ("a", "o semeador sai a semear"),
                        ("b", "a semente cai em solos distintos"),
                        ("c", "só a terra boa dá fruto em medida"),
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
                    question='Complete: "por não ter ___, secou-se"',
                    feedback_correct="Certo: por não ter raiz.",
                    feedback_wrong={
                        "b": "Fruto é da terra boa.",
                        "c": "Aves comem a do caminho.",
                    },
                    options=opts(("a", "raiz"), ("b", "fruto"), ("c", "aves")),
                    correct="a",
                    template="por não ter ___, secou-se",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 13:3–8 comunica que se liga a este contexto?",
                    feedback_correct="Certo: o reino exige ouvidos — solos importam.",
                    feedback_wrong={
                        "b": "A parábola destaca diferença de solos.",
                        "c": "Há fruto possível na terra boa.",
                    },
                    options=opts(
                        ("a", "Reino exige ouvidos"),
                        ("b", "Solos não fazem diferença"),
                        ("c", "Semente sem fruto possível"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Na parábola, a semente à beira do caminho deu fruto a cem por um.",
                    feedback_correct="Certo: à beira do caminho as aves a comeram.",
                    feedback_wrong={"true": "Mateus 13:4: as aves comeram a semente do caminho."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 13:3–8, toque a palavra que falta em "e dava ___, uma a cem, outra a sessenta e outra a trinta"?',
                    feedback_correct="Exato: dava fruto.",
                    feedback_wrong={
                        "b": "Semente é o que é lançado.",
                        "c": "Sol é o que queima o pedregoso.",
                    },
                    options=opts(("a", "fruto"), ("b", "semente"), ("c", "sol")),
                    correct="a",
                    template="e dava ___, uma a cem, outra a sessenta e outra a trinta",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve entender sobre o reino em Mateus 13:3–8?",
                    feedback_correct="Certo: a palavra exige solo que ouve e frutifica.",
                    feedback_wrong={
                        "a": "Há falha e fruto; o contraste ensina.",
                        "c": "Ouvir sem raiz ou sob espinhos não basta.",
                        "d": "A terra boa é o modelo do fruto.",
                    },
                    options=opts(
                        ("a", "Toda semente frutifica igual, sem solo."),
                        ("b", "O reino exige ouvidos que recebem e frutificam."),
                        ("c", "Espinhos e caminho são o ideal do discípulo."),
                        ("d", "Fruto é irrelevante na parábola do semeador."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Mateus 13:3–8?",
                    feedback_correct="Certo: semente lançada, solos e fruto na boa terra.",
                    feedback_wrong={
                        "b": "Os solos mostram respostas diferentes.",
                        "c": "O fruto na terra boa revela o sentido.",
                    },
                    options=opts(
                        ("a", "a semente é lançada pelo semeador"),
                        ("b", "solos distintos recebem ou perdem a semente"),
                        ("c", "terra boa produz fruto em medidas"),
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
                    question='Complete: "e vieram as ___ e comeram-na"',
                    feedback_correct="Certo: as aves.",
                    feedback_wrong={
                        "b": "Espinhos sufocam outro solo.",
                        "c": "Raiz falta no pedregoso.",
                    },
                    options=opts(("a", "aves"), ("b", "espinhos"), ("c", "raiz")),
                    correct="a",
                    template="e vieram as ___ e comeram-na",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 13:3–8 comunica que se liga a este contexto?",
                    feedback_correct="Certo: ouvir o reino com solo que frutifica.",
                    feedback_wrong={
                        "b": "A parábola exige atenção aos solos.",
                        "c": "Há fruto real na terra boa.",
                    },
                    options=opts(
                        ("a", "Ouvidos que frutificam"),
                        ("b", "Parábola sem exigência"),
                        ("c", "Semente sem terra boa"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_7():
    sec = "evg-06-milagres"
    vref = "Marcos 6:41–42"
    evid = ["Marcos 6:41", "Marcos 6:42"]
    lo = "Ver que Jesus parte os pães, dá graças e todos comem e se fartam."
    ins = "Sinais: pães partidos e todos fartos."
    p = P7
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
                    question="Ele tomou os cinco pães e os dois peixes.",
                    feedback_correct="Certo: Marcos 6:41 começa assim.",
                    feedback_wrong={"false": "O texto diz: cinco pães e dois peixes."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Marcos 6:41–42, toque a palavra que falta em "Ele tomou os cinco ___ e os dois peixes"?',
                    feedback_correct="Exato: cinco pães.",
                    feedback_wrong={
                        "b": "Peixes são os dois; a lacuna é pães.",
                        "c": "Céu é para onde ergue os olhos.",
                    },
                    options=opts(("a", "pães"), ("b", "peixes"), ("c", "céu")),
                    correct="a",
                    template="Ele tomou os cinco ___ e os dois peixes",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que Jesus faz antes de partir os pães?",
                    feedback_correct="Certo: ergue os olhos ao céu e dá graças.",
                    feedback_wrong={
                        "b": "Há ação de graças explícita.",
                        "c": "Ele entrega aos discípulos depois.",
                        "d": "Todos comem e se fartam no fim.",
                    },
                    options=opts(
                        ("a", "Ergue os olhos ao céu e dá graças."),
                        ("b", "Guarda os pães sem dar graças."),
                        ("c", "Manda a multidão embora sem pão."),
                        ("d", "Come sozinho os cinco pães."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Marcos 6:41–42?",
                    feedback_correct="Certo: tomar, dar graças e fartar.",
                    feedback_wrong={
                        "b": "Dar graças precede a distribuição.",
                        "c": "Todos se fartam no final.",
                    },
                    options=opts(
                        ("a", "Ele tomou os cinco pães e os dois peixes"),
                        ("b", "erguendo os olhos ao céu, deu graças"),
                        ("c", "Todos comeram e se fartaram"),
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
                    question='Complete: "Todos comeram e se ___"',
                    feedback_correct="Certo: se fartaram.",
                    feedback_wrong={
                        "b": "Distribuírem é a ação dos discípulos.",
                        "c": "Graças é o que ele deu antes.",
                    },
                    options=opts(("a", "fartaram"), ("b", "distribuírem"), ("c", "graças")),
                    correct="a",
                    template="Todos comeram e se ___",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Marcos 6:41–42 comunica que se liga a este contexto?",
                    feedback_correct="Certo: pães partidos e todos fartos.",
                    feedback_wrong={
                        "b": "Há fartura, não escassez final.",
                        "c": "Ele dá graças e parte, não retém.",
                    },
                    options=opts(
                        ("a", "Pães partidos e fartura"),
                        ("b", "Multidão ainda com fome"),
                        ("c", "Pães guardados sem partilha"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Segundo Marcos 6:42, ninguém comeu nem se fartou.",
                    feedback_correct="Certo: todos comeram e se fartaram.",
                    feedback_wrong={"true": "O texto diz: Todos comeram e se fartaram."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Marcos 6:41–42, toque a palavra que falta em "e repartiu por todos os dois ___"?',
                    feedback_correct="Exato: dois peixes.",
                    feedback_wrong={
                        "b": "Pães são cinco; aqui são peixes.",
                        "c": "Olhos ergue ao céu, não esta lacuna.",
                    },
                    options=opts(("a", "peixes"), ("b", "pães"), ("c", "olhos")),
                    correct="a",
                    template="e repartiu por todos os dois ___",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como Marcos 6:41–42 liga dar graças e fartura?",
                    feedback_correct="Certo: após graças e partilha, todos se fartam.",
                    feedback_wrong={
                        "a": "Há graças e fartura no mesmo sinal.",
                        "c": "Os discípulos distribuem o que ele parte.",
                        "d": "A fartura é de todos, não de poucos.",
                    },
                    options=opts(
                        ("a", "Dar graças impede qualquer fartura."),
                        ("b", "Após graças e partilha, todos se fartam."),
                        ("c", "Só Jesus come; os discípulos ficam de fora."),
                        ("d", "A fartura acontece sem distribuição alguma."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Marcos 6:41–42?",
                    feedback_correct="Certo: graças, distribuição e fartura.",
                    feedback_wrong={
                        "b": "A distribuição segue a ação de graças.",
                        "c": "A fartura fecha o sinal.",
                    },
                    options=opts(
                        ("a", "Jesus dá graças erguendo os olhos ao céu"),
                        ("b", "parte e entrega aos discípulos para distribuírem"),
                        ("c", "todos comem e se fartam"),
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
                    question='Complete: "erguendo os olhos ao ___, deu graças"',
                    feedback_correct="Certo: ao céu.",
                    feedback_wrong={
                        "b": "Pães são o que ele toma.",
                        "c": "Peixes também são repartidos.",
                    },
                    options=opts(("a", "céu"), ("b", "pães"), ("c", "peixes")),
                    correct="a",
                    template="erguendo os olhos ao ___, deu graças",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Marcos 6:41–42 comunica que se liga a este contexto?",
                    feedback_correct="Certo: sinal de graças e fartura para todos.",
                    feedback_wrong={
                        "b": "Há partilha, não retenção.",
                        "c": "A fartura é real no texto.",
                    },
                    options=opts(
                        ("a", "Graças e fartura para todos"),
                        ("b", "Pães sem partilha"),
                        ("c", "Sinal sem fartura"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="O sinal dos pães mostra Jesus dando graças e fartando a multidão.",
                    feedback_correct="Certo: graças, partilha e fartura se unem.",
                    feedback_wrong={"false": "Marcos 6:41–42 sustenta essa leitura."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Marcos 6:41–42, toque a palavra que falta em "e, partindo os pães, entregou-os aos ___ para eles distribuírem"?',
                    feedback_correct="Exato: aos discípulos.",
                    feedback_wrong={
                        "b": "Peixes também são repartidos; aqui são discípulos.",
                        "c": "Olhos ergue ao céu.",
                    },
                    options=opts(("a", "discípulos"), ("b", "peixes"), ("c", "olhos")),
                    correct="a",
                    template="e, partindo os pães, entregou-os aos ___ para eles distribuírem",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve entender sobre o sinal em Marcos 6:41–42?",
                    feedback_correct="Certo: Jesus multiplica com graças e fartura real.",
                    feedback_wrong={
                        "a": "Há ação concreta de partir e distribuir.",
                        "c": "Todos se fartam; não é só símbolo vazio.",
                        "d": "Os discípulos participam da distribuição.",
                    },
                    options=opts(
                        ("a", "O sinal é só metáfora, sem pães reais."),
                        ("b", "Jesus dá graças, parte e todos se fartam."),
                        ("c", "A fartura é negada no final do texto."),
                        ("d", "Os discípulos não recebem nada para distribuir."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Marcos 6:41–42?",
                    feedback_correct="Certo: tomar, agradecer, fartar.",
                    feedback_wrong={
                        "b": "A ação de graças interpreta o sinal.",
                        "c": "A fartura revela o cuidado de Jesus.",
                    },
                    options=opts(
                        ("a", "Jesus toma os pães e os peixes"),
                        ("b", "dá graças e parte para distribuir"),
                        ("c", "todos comem e se fartam"),
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
                    question='Complete: "Ele tomou os cinco pães e os dois ___"',
                    feedback_correct="Certo: dois peixes.",
                    feedback_wrong={
                        "b": "Pães já está no início da frase.",
                        "c": "Céu é para onde ergue os olhos.",
                    },
                    options=opts(("a", "peixes"), ("b", "pães"), ("c", "céu")),
                    correct="a",
                    template="Ele tomou os cinco pães e os dois ___",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Marcos 6:41–42 comunica que se liga a este contexto?",
                    feedback_correct="Certo: sinais de pães partidos e fartura.",
                    feedback_wrong={
                        "b": "Há fartura explícita.",
                        "c": "A partilha é o meio do sinal.",
                    },
                    options=opts(
                        ("a", "Sinais: pães e fartura"),
                        ("b", "Sinal sem fartura"),
                        ("c", "Pães sem partilha"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_8():
    sec = "evg-boss-02"
    vref = "Mateus 5:3; 13:3"
    evid = ["Mateus 5:3", "Mateus 13:3"]
    lo = "Unir ensino e parábola: reino aos humildes e semente lançada."
    ins = "Ensino e sinais: reino anunciado e semente lançada."
    p = P8
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
                    feedback_correct="Certo: Mateus 5:3 está no fio do ensino.",
                    feedback_wrong={"false": "O texto afirma o reino aos humildes."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:3; 13:3, toque a palavra que falta em "O ___ saiu a semear"?',
                    feedback_correct="Exato: o semeador.",
                    feedback_wrong={
                        "b": "Humildes recebem o reino; aqui é semeador.",
                        "c": "Céus é o reino dos humildes.",
                    },
                    options=opts(("a", "semeador"), ("b", "humildes"), ("c", "céus")),
                    correct="a",
                    template="O ___ saiu a semear",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que os textos unidos afirmam sobre o reino?",
                    feedback_correct="Certo: reino aos humildes e semente lançada.",
                    feedback_wrong={
                        "b": "Há anúncio claro do reino.",
                        "c": "O semeador sai a semear.",
                        "d": "Os humildes recebem o reino.",
                    },
                    options=opts(
                        ("a", "Reino aos humildes e semente lançada."),
                        ("b", "Reino sem anúncio e sem semente."),
                        ("c", "O semeador não sai a semear."),
                        ("d", "Os humildes são excluídos do reino."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Mateus 5:3; 13:3?",
                    feedback_correct="Certo: bem-aventurança, reino e semeadura.",
                    feedback_wrong={
                        "b": "O reino dos céus segue a bem-aventurança.",
                        "c": "A semeadura fecha o fio do ensino.",
                    },
                    options=opts(
                        ("a", "Bem-aventurados os humildes de espírito"),
                        ("b", "porque deles é o reino dos céus"),
                        ("c", "O semeador saiu a semear"),
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
                    question='Complete: "porque deles é o reino dos ___"',
                    feedback_correct="Certo: reino dos céus.",
                    feedback_wrong={
                        "b": "Semeador é de 13:3; aqui é céus.",
                        "c": "Espírito qualifica os humildes.",
                    },
                    options=opts(("a", "céus"), ("b", "semeador"), ("c", "espírito")),
                    correct="a",
                    template="porque deles é o reino dos ___",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:3; 13:3 comunica que se liga a este contexto?",
                    feedback_correct="Certo: reino anunciado e semente lançada.",
                    feedback_wrong={
                        "b": "Há anúncio e semeadura.",
                        "c": "Os humildes estão no centro do reino.",
                    },
                    options=opts(
                        ("a", "Reino anunciado e semente"),
                        ("b", "Ensino sem semente"),
                        ("c", "Reino sem humildes"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Mateus 13:3 diz que o semeador ficou sem sair a semear.",
                    feedback_correct="Certo: o texto diz que o semeador saiu a semear.",
                    feedback_wrong={"true": "Mateus 13:3: O semeador saiu a semear."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:3; 13:3, toque a palavra que falta em "Bem-aventurados os ___ de espírito"?',
                    feedback_correct="Exato: humildes.",
                    feedback_wrong={
                        "b": "Semeador é de 13:3.",
                        "c": "Céus é o reino prometido.",
                    },
                    options=opts(("a", "humildes"), ("b", "semeador"), ("c", "céus")),
                    correct="a",
                    template="Bem-aventurados os ___ de espírito",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como Mateus 5:3 e 13:3 se relacionam no ensino do reino?",
                    feedback_correct="Certo: o reino é anunciado e a semente é lançada.",
                    feedback_wrong={
                        "a": "Os textos se complementam no anúncio.",
                        "c": "Há semente lançada, não silêncio.",
                        "d": "Os humildes recebem o reino anunciado.",
                    },
                    options=opts(
                        ("a", "O sermão anula a parábola do semeador."),
                        ("b", "O reino aos humildes e a semente lançada se unem."),
                        ("c", "Não há semente nem anúncio do reino."),
                        ("d", "Só a parábola importa; o sermão é irrelevante."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Mateus 5:3; 13:3?",
                    feedback_correct="Certo: bem-aventurança, reino e semeadura.",
                    feedback_wrong={
                        "b": "O reino dos céus é a promessa.",
                        "c": "A semeadura continua o anúncio.",
                    },
                    options=opts(
                        ("a", "bem-aventurança aos humildes de espírito"),
                        ("b", "promessa do reino dos céus"),
                        ("c", "o semeador sai a semear"),
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
                    question='Complete: "O semeador saiu a ___"',
                    feedback_correct="Certo: saiu a semear.",
                    feedback_wrong={
                        "b": "Céus é o reino dos humildes.",
                        "c": "Espírito qualifica os humildes.",
                    },
                    options=opts(("a", "semear"), ("b", "céus"), ("c", "espírito")),
                    correct="a",
                    template="O semeador saiu a ___",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:3; 13:3 comunica que se liga a este contexto?",
                    feedback_correct="Certo: ensino e semente do reino juntos.",
                    feedback_wrong={
                        "b": "Há anúncio claro.",
                        "c": "A semente é lançada.",
                    },
                    options=opts(
                        ("a", "Ensino e semente do reino"),
                        ("b", "Reino sem anúncio"),
                        ("c", "Semente sem saída"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Ensino e parábola juntos apresentam o reino aos humildes e a semente lançada.",
                    feedback_correct="Certo: esse é o fio de Mateus 5:3 e 13:3.",
                    feedback_wrong={"false": "Os dois textos formam esse sentido."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:3; 13:3, toque a palavra que falta em "porque deles é o ___ dos céus"?',
                    feedback_correct="Exato: o reino.",
                    feedback_wrong={
                        "b": "Semeador lança a semente.",
                        "c": "Espírito qualifica os humildes.",
                    },
                    options=opts(("a", "reino"), ("b", "semeador"), ("c", "espírito")),
                    correct="a",
                    template="porque deles é o ___ dos céus",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve levar de Mateus 5:3; 13:3?",
                    feedback_correct="Certo: o reino anunciado exige ouvidos à semente.",
                    feedback_wrong={
                        "a": "Há anúncio e semeadura reais.",
                        "c": "Os humildes estão no centro.",
                        "d": "A parábola continua o ensino do reino.",
                    },
                    options=opts(
                        ("a", "O reino não é anunciado nem semeado."),
                        ("b", "O reino aos humildes e a semente pedem ouvidos."),
                        ("c", "Só os orgulhosos recebem o reino dos céus."),
                        ("d", "A parábola contradiz o sermão do monte."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Mateus 5:3; 13:3?",
                    feedback_correct="Certo: humildes, reino e semente lançada.",
                    feedback_wrong={
                        "b": "O reino é a promessa aos humildes.",
                        "c": "A semente continua o anúncio.",
                    },
                    options=opts(
                        ("a", "bem-aventurança aos humildes"),
                        ("b", "deles é o reino dos céus"),
                        ("c", "o semeador lança a semente"),
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
                    question='Complete: "Bem-aventurados os humildes de ___"',
                    feedback_correct="Certo: de espírito.",
                    feedback_wrong={
                        "b": "Céus é o reino.",
                        "c": "Semear é a ação do semeador.",
                    },
                    options=opts(("a", "espírito"), ("b", "céus"), ("c", "semear")),
                    correct="a",
                    template="Bem-aventurados os humildes de ___",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:3; 13:3 comunica que se liga a este contexto?",
                    feedback_correct="Certo: reino anunciado e semente lançada.",
                    feedback_wrong={
                        "b": "Há anúncio e ação de semear.",
                        "c": "Os textos se unem, não se anulam.",
                    },
                    options=opts(
                        ("a", "Reino e semente unidos"),
                        ("b", "Ensino sem semente"),
                        ("c", "Parábola contra o sermão"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_9():
    sec = "evg-07-ceia"
    vref = "Lucas 22:19–20"
    evid = ["Lucas 22:19", "Lucas 22:20"]
    lo = "Reconhecer a ceia: corpo dado e sangue da nova aliança."
    ins = "Ceia: corpo dado e sangue da nova aliança."
    p = P9
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
                    question="Tomando o pão e tendo dado graças, partiu-o e deu aos discípulos.",
                    feedback_correct="Certo: Lucas 22:19 começa assim.",
                    feedback_wrong={"false": "O texto afirma que tomou o pão e partiu-o."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Lucas 22:19–20, toque a palavra que falta em "Este é o meu ___ que é dado por vós"?',
                    feedback_correct="Exato: o meu corpo.",
                    feedback_wrong={
                        "b": "Sangue é do cálice; aqui é corpo.",
                        "c": "Cálice vem depois da ceia.",
                    },
                    options=opts(("a", "corpo"), ("b", "sangue"), ("c", "cálice")),
                    correct="a",
                    template="Este é o meu ___ que é dado por vós",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que Jesus diz sobre o pão na ceia?",
                    feedback_correct="Certo: Este é o meu corpo que é dado por vós.",
                    feedback_wrong={
                        "b": "O corpo é dado por vós, não negado.",
                        "c": "Há memória de mim, não esquecimento.",
                        "d": "O cálice fala da nova aliança depois.",
                    },
                    options=opts(
                        ("a", "Este é o meu corpo que é dado por vós."),
                        ("b", "Este pão não tem relação com o corpo."),
                        ("c", "Fazei isso para esquecer de mim."),
                        ("d", "O pão é a nova aliança em meu sangue."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Lucas 22:19–20?",
                    feedback_correct="Certo: pão, corpo e cálice da aliança.",
                    feedback_wrong={
                        "b": "O corpo dado vem com o pão partido.",
                        "c": "O cálice da nova aliança fecha a cena.",
                    },
                    options=opts(
                        ("a", "Tomando o pão e tendo dado graças, partiu-o"),
                        ("b", "Este é o meu corpo que é dado por vós"),
                        ("c", "Este cálice é a nova aliança em meu sangue"),
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
                    question='Complete: "Este cálice é a nova ___ em meu sangue"',
                    feedback_correct="Certo: nova aliança.",
                    feedback_wrong={
                        "b": "Memória é do pão; aqui é aliança.",
                        "c": "Corpo é do pão, não do cálice.",
                    },
                    options=opts(("a", "aliança"), ("b", "memória"), ("c", "corpo")),
                    correct="a",
                    template="Este cálice é a nova ___ em meu sangue",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Lucas 22:19–20 comunica que se liga a este contexto?",
                    feedback_correct="Certo: corpo dado e sangue da nova aliança.",
                    feedback_wrong={
                        "b": "Há memória, não esquecimento.",
                        "c": "O cálice é a nova aliança.",
                    },
                    options=opts(
                        ("a", "Corpo dado e nova aliança"),
                        ("b", "Ceia sem memória de mim"),
                        ("c", "Cálice sem sangue derramado"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="O cálice, segundo Jesus, é a nova aliança em seu sangue.",
                    feedback_correct="Certo: nova aliança em meu sangue.",
                    feedback_wrong={"false": "Lucas 22:20 afirma a nova aliança."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Lucas 22:19–20, toque a palavra que falta em "fazei isso em ___ de mim"?',
                    feedback_correct="Exato: em memória de mim.",
                    feedback_wrong={
                        "b": "Aliança é do cálice.",
                        "c": "Sangue é derramado; aqui é memória.",
                    },
                    options=opts(("a", "memória"), ("b", "aliança"), ("c", "sangue")),
                    correct="a",
                    template="fazei isso em ___ de mim",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como Lucas 22:19–20 relaciona pão e cálice?",
                    feedback_correct="Certo: corpo dado e sangue da nova aliança.",
                    feedback_wrong={
                        "a": "Os dois gestos se complementam.",
                        "c": "Há memória e derramamento por vós.",
                        "d": "A aliança é nova, em seu sangue.",
                    },
                    options=opts(
                        ("a", "O cálice cancela o sentido do pão."),
                        ("b", "Pão é corpo dado; cálice é nova aliança."),
                        ("c", "Só o pão importa; o cálice é irrelevante."),
                        ("d", "A aliança antiga permanece sem sangue."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Lucas 22:19–20?",
                    feedback_correct="Certo: pão, memória e cálice da aliança.",
                    feedback_wrong={
                        "b": "A memória acompanha o pão partido.",
                        "c": "O cálice interpreta a nova aliança.",
                    },
                    options=opts(
                        ("a", "Jesus parte o pão e o dá aos discípulos"),
                        ("b", "ordena: fazei isso em memória de mim"),
                        ("c", "toma o cálice da nova aliança em seu sangue"),
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
                    question='Complete: "que é ___ por vós"',
                    feedback_correct="Certo: derramado por vós.",
                    feedback_wrong={
                        "b": "Dado é do corpo; aqui é derramado.",
                        "c": "Partiu descreve o pão.",
                    },
                    options=opts(("a", "derramado"), ("b", "dado"), ("c", "partiu")),
                    correct="a",
                    template="que é ___ por vós",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Lucas 22:19–20 comunica que se liga a este contexto?",
                    feedback_correct="Certo: ceia de corpo e nova aliança.",
                    feedback_wrong={
                        "b": "Há memória ordenada.",
                        "c": "O sangue é da nova aliança.",
                    },
                    options=opts(
                        ("a", "Ceia: corpo e aliança"),
                        ("b", "Ceia sem memória"),
                        ("c", "Aliança sem sangue"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Na ceia, o sangue de Jesus é apresentado como da antiga aliança apenas.",
                    feedback_correct="Certo: o texto fala da nova aliança.",
                    feedback_wrong={"true": "Lucas 22:20: nova aliança em meu sangue."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Lucas 22:19–20, toque a palavra que falta em "Este cálice é a nova aliança em meu ___"?',
                    feedback_correct="Exato: em meu sangue.",
                    feedback_wrong={
                        "b": "Corpo é do pão.",
                        "c": "Memória é o mandato do pão.",
                    },
                    options=opts(("a", "sangue"), ("b", "corpo"), ("c", "memória")),
                    correct="a",
                    template="Este cálice é a nova aliança em meu ___",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve entender sobre a ceia em Lucas 22:19–20?",
                    feedback_correct="Certo: corpo dado e sangue da nova aliança por nós.",
                    feedback_wrong={
                        "a": "Há entrega real: dado e derramado por vós.",
                        "c": "A memória é ordenada, não opcional.",
                        "d": "A aliança é nova, em seu sangue.",
                    },
                    options=opts(
                        ("a", "A ceia é só refeição, sem corpo nem sangue."),
                        ("b", "Corpo dado e sangue da nova aliança por vós."),
                        ("c", "Não há mandato de fazer em memória."),
                        ("d", "O cálice restaura só a aliança antiga."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Lucas 22:19–20?",
                    feedback_correct="Certo: corpo dado, memória e nova aliança.",
                    feedback_wrong={
                        "b": "A memória prolonga o gesto do pão.",
                        "c": "A nova aliança interpreta o cálice.",
                    },
                    options=opts(
                        ("a", "o corpo é dado por vós no pão partido"),
                        ("b", "fazei isso em memória de mim"),
                        ("c", "o cálice é a nova aliança em seu sangue"),
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
                    question='Complete: "Este é o meu corpo que é ___ por vós"',
                    feedback_correct="Certo: dado por vós.",
                    feedback_wrong={
                        "b": "Derramado é do sangue.",
                        "c": "Partiu descreve a ação sobre o pão.",
                    },
                    options=opts(("a", "dado"), ("b", "derramado"), ("c", "partiu")),
                    correct="a",
                    template="Este é o meu corpo que é ___ por vós",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Lucas 22:19–20 comunica que se liga a este contexto?",
                    feedback_correct="Certo: corpo dado e sangue da nova aliança.",
                    feedback_wrong={
                        "b": "Há entrega, não retenção.",
                        "c": "A memória é parte do mandato.",
                    },
                    options=opts(
                        ("a", "Corpo e sangue da aliança"),
                        ("b", "Ceia sem entrega"),
                        ("c", "Memória sem mandato"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_10():
    sec = "evg-08-cruz"
    vref = "Marcos 15:37–39"
    evid = ["Marcos 15:37", "Marcos 15:38", "Marcos 15:39"]
    lo = "Ver na cruz o brado, o véu rasgado e a confissão do centurião."
    ins = "Cruz: brado, véu rasgado, centurião confessa Filho de Deus."
    p = P10
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
                    question="Jesus, dando um grande brado, expirou.",
                    feedback_correct="Certo: Marcos 15:37 afirma isso.",
                    feedback_wrong={"false": "O texto diz que Jesus expirou com grande brado."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Marcos 15:37–39, toque a palavra que falta em "O ___ do santuário rasgou-se em duas partes"?',
                    feedback_correct="Exato: o véu.",
                    feedback_wrong={
                        "b": "Brado é de Jesus; aqui é véu.",
                        "c": "Centurião confessa depois.",
                    },
                    options=opts(("a", "véu"), ("b", "brado"), ("c", "centurião")),
                    correct="a",
                    template="O ___ do santuário rasgou-se em duas partes",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que o centurião diz ao ver Jesus expirar?",
                    feedback_correct="Certo: Verdadeiramente, este homem era Filho de Deus.",
                    feedback_wrong={
                        "b": "Há confissão clara, não silêncio.",
                        "c": "Ele afirma Filho de Deus, não nega.",
                        "d": "O véu rasgou-se; a confissão segue.",
                    },
                    options=opts(
                        ("a", "Verdadeiramente, este homem era Filho de Deus."),
                        ("b", "Nada diz diante da cruz."),
                        ("c", "Nega que Jesus fosse Filho de Deus."),
                        ("d", "Afirma que o véu permanece intacto."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Marcos 15:37–39?",
                    feedback_correct="Certo: brado, véu e confissão.",
                    feedback_wrong={
                        "b": "O véu rasga após a expiração.",
                        "c": "A confissão do centurião fecha a cena.",
                    },
                    options=opts(
                        ("a", "Jesus, dando um grande brado, expirou"),
                        ("b", "O véu do santuário rasgou-se em duas partes"),
                        ("c", "o centurião disse: Verdadeiramente, este homem era Filho de Deus"),
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
                    question='Complete: "rasgou-se em duas partes, de alto a ___"',
                    feedback_correct="Certo: de alto a baixo.",
                    feedback_wrong={
                        "b": "Frente é onde está o centurião.",
                        "c": "Brado descreve a expiração.",
                    },
                    options=opts(("a", "baixo"), ("b", "frente"), ("c", "brado")),
                    correct="a",
                    template="rasgou-se em duas partes, de alto a ___",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Marcos 15:37–39 comunica que se liga a este contexto?",
                    feedback_correct="Certo: brado, véu rasgado e confissão.",
                    feedback_wrong={
                        "b": "Há confissão, não silêncio.",
                        "c": "O véu rasga-se de alto a baixo.",
                    },
                    options=opts(
                        ("a", "Brado, véu e confissão"),
                        ("b", "Cruz sem confissão"),
                        ("c", "Véu intacto no santuário"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="O véu do santuário rasgou-se de baixo a alto, segundo Marcos 15:38.",
                    feedback_correct="Certo: o texto diz de alto a baixo.",
                    feedback_wrong={"true": "Marcos 15:38: de alto a baixo."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Marcos 15:37–39, toque a palavra que falta em "Jesus, dando um grande ___, expirou"?',
                    feedback_correct="Exato: grande brado.",
                    feedback_wrong={
                        "b": "Véu rasga-se depois.",
                        "c": "Centurião confessa depois.",
                    },
                    options=opts(("a", "brado"), ("b", "véu"), ("c", "centurião")),
                    correct="a",
                    template="Jesus, dando um grande ___, expirou",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como Marcos 15:37–39 encadeia a morte de Jesus e a confissão?",
                    feedback_correct="Certo: ao expirar, o véu rasga e o centurião confessa.",
                    feedback_wrong={
                        "a": "Há confissão explícita após a expiração.",
                        "c": "O véu rasga-se; o sinal acompanha a morte.",
                        "d": "O centurião vê e confessa Filho de Deus.",
                    },
                    options=opts(
                        ("a", "A morte de Jesus impede qualquer confissão."),
                        ("b", "Ao expirar, o véu rasga e o centurião confessa."),
                        ("c", "O véu permanece intacto após a expiração."),
                        ("d", "O centurião nega a filiação divina."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Marcos 15:37–39?",
                    feedback_correct="Certo: expiração, véu rasgado e confissão.",
                    feedback_wrong={
                        "b": "O véu rasga após o brado.",
                        "c": "A confissão interpreta a cena.",
                    },
                    options=opts(
                        ("a", "Jesus expira com grande brado"),
                        ("b", "o véu do santuário rasga-se de alto a baixo"),
                        ("c", "o centurião confessa: Filho de Deus"),
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
                    question='Complete: "Verdadeiramente, este homem era Filho de ___"',
                    feedback_correct="Certo: Filho de Deus.",
                    feedback_wrong={
                        "b": "Santuário é onde está o véu.",
                        "c": "Homem já está na frase; a lacuna é Deus.",
                    },
                    options=opts(("a", "Deus"), ("b", "santuário"), ("c", "homem")),
                    correct="a",
                    template="Verdadeiramente, este homem era Filho de ___",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Marcos 15:37–39 comunica que se liga a este contexto?",
                    feedback_correct="Certo: a cruz revela o Filho de Deus.",
                    feedback_wrong={
                        "b": "Há confissão clara.",
                        "c": "O véu rasgado acompanha a cena.",
                    },
                    options=opts(
                        ("a", "Cruz revela o Filho de Deus"),
                        ("b", "Cruz sem confissão alguma"),
                        ("c", "Véu intacto e sem sentido"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="O centurião, vendo Jesus expirar, confessa que ele era Filho de Deus.",
                    feedback_correct="Certo: essa é a confissão do texto.",
                    feedback_wrong={"false": "Marcos 15:39 registra essa confissão."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Marcos 15:37–39, toque a palavra que falta em "O centurião que estava em frente de Jesus, vendo-o assim ___"?',
                    feedback_correct="Exato: expirar.",
                    feedback_wrong={
                        "b": "Rasgou-se refere-se ao véu.",
                        "c": "Brado acompanha a expiração, mas a lacuna é expirar.",
                    },
                    options=opts(("a", "expirar"), ("b", "rasgou-se"), ("c", "brado")),
                    correct="a",
                    template="O centurião que estava em frente de Jesus, vendo-o assim ___",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve entender sobre a cruz em Marcos 15:37–39?",
                    feedback_correct="Certo: na morte, o véu rasga e o Filho é confessado.",
                    feedback_wrong={
                        "a": "Há revelação, não silêncio total.",
                        "c": "O centurião confessa, não nega.",
                        "d": "O véu rasgado é sinal na cena.",
                    },
                    options=opts(
                        ("a", "A cruz oculta qualquer revelação de Deus."),
                        ("b", "Na morte, o véu rasga e o Filho é confessado."),
                        ("c", "O centurião impede a confissão do Filho."),
                        ("d", "O véu intacto nega o sentido da cruz."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Marcos 15:37–39?",
                    feedback_correct="Certo: brado, véu rasgado e Filho confessado.",
                    feedback_wrong={
                        "b": "O véu rasgado interpreta o acesso.",
                        "c": "A confissão nomeia quem morreu.",
                    },
                    options=opts(
                        ("a", "Jesus expira com grande brado"),
                        ("b", "o véu do santuário rasga-se"),
                        ("c", "o centurião confessa o Filho de Deus"),
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
                    question='Complete: "O véu do ___ rasgou-se em duas partes"',
                    feedback_correct="Certo: do santuário.",
                    feedback_wrong={
                        "b": "Centurião é quem confessa.",
                        "c": "Brado é de Jesus.",
                    },
                    options=opts(("a", "santuário"), ("b", "centurião"), ("c", "brado")),
                    correct="a",
                    template="O véu do ___ rasgou-se em duas partes",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Marcos 15:37–39 comunica que se liga a este contexto?",
                    feedback_correct="Certo: cruz com brado, véu e Filho confessado.",
                    feedback_wrong={
                        "b": "Há confissão, não negação.",
                        "c": "O véu rasgado marca a cena.",
                    },
                    options=opts(
                        ("a", "Cruz: véu e Filho confessado"),
                        ("b", "Cruz sem Filho de Deus"),
                        ("c", "Véu intacto sem sentido"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_11():
    sec = "evg-09-ressurreicao"
    vref = "Mateus 28:5–6"
    evid = ["Mateus 28:5", "Mateus 28:6"]
    lo = "Ouvir o anjo: ele não está aqui, porque ressuscitou, como disse."
    ins = "Ressurreição: ele não está aqui — ressuscitou como disse."
    p = P11
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
                    question="O anjo disse às mulheres: Não temais vós.",
                    feedback_correct="Certo: Mateus 28:5 começa assim.",
                    feedback_wrong={"false": "O anjo diz: Não temais vós."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 28:5–6, toque a palavra que falta em "Ele não está aqui, porque ___, como disse"?',
                    feedback_correct="Exato: ressuscitou.",
                    feedback_wrong={
                        "b": "Crucificado é quem elas procuram.",
                        "c": "Temais é o que o anjo desarma.",
                    },
                    options=opts(("a", "ressuscitou"), ("b", "crucificado"), ("c", "temais")),
                    correct="a",
                    template="Ele não está aqui, porque ___, como disse",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que o anjo afirma sobre Jesus em Mateus 28:6?",
                    feedback_correct="Certo: ele não está aqui, porque ressuscitou.",
                    feedback_wrong={
                        "b": "O túmulo não o retém; ressuscitou.",
                        "c": "Há convite a ver o lugar.",
                        "d": "Como disse: a palavra se cumpre.",
                    },
                    options=opts(
                        ("a", "Ele não está aqui, porque ressuscitou."),
                        ("b", "Ele ainda jaz no mesmo lugar."),
                        ("c", "As mulheres não devem ver o lugar."),
                        ("d", "O anjo nega qualquer ressurreição."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Mateus 28:5–6?",
                    feedback_correct="Certo: não temais, ressuscitou e vede o lugar.",
                    feedback_wrong={
                        "b": "A ressurreição explica a ausência.",
                        "c": "O convite a ver fecha a ordem.",
                    },
                    options=opts(
                        ("a", "Não temais vós; porque sei que procurais a Jesus"),
                        ("b", "Ele não está aqui, porque ressuscitou, como disse"),
                        ("c", "vinde e vede o lugar onde ele jazia"),
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
                    question='Complete: "vinde e vede o ___ onde ele jazia"',
                    feedback_correct="Certo: o lugar.",
                    feedback_wrong={
                        "b": "Anjo é quem fala.",
                        "c": "Mulheres são as ouvintes.",
                    },
                    options=opts(("a", "lugar"), ("b", "anjo"), ("c", "mulheres")),
                    correct="a",
                    template="vinde e vede o ___ onde ele jazia",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 28:5–6 comunica que se liga a este contexto?",
                    feedback_correct="Certo: ele não está aqui — ressuscitou.",
                    feedback_wrong={
                        "b": "Há ressurreição, não túmulo ocupado.",
                        "c": "O anjo convida a ver o lugar.",
                    },
                    options=opts(
                        ("a", "Túmulo vazio: ressuscitou"),
                        ("b", "Jesus ainda jazia ali"),
                        ("c", "Anjo sem palavra de vida"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Segundo o anjo, Jesus permanece no lugar onde jazia.",
                    feedback_correct="Certo: ele não está aqui, porque ressuscitou.",
                    feedback_wrong={"true": "Mateus 28:6: Ele não está aqui."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 28:5–6, toque a palavra que falta em "porque sei que procurais a Jesus, que foi ___"?',
                    feedback_correct="Exato: crucificado.",
                    feedback_wrong={
                        "b": "Ressuscitou é a notícia; aqui é crucificado.",
                        "c": "Temais é o medo a ser removido.",
                    },
                    options=opts(("a", "crucificado"), ("b", "ressuscitou"), ("c", "temais")),
                    correct="a",
                    template="porque sei que procurais a Jesus, que foi ___",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como Mateus 28:5–6 relaciona a palavra de Jesus e o túmulo?",
                    feedback_correct="Certo: ressuscitou como disse — a palavra se cumpre.",
                    feedback_wrong={
                        "a": "O texto liga ausência e cumprimento.",
                        "c": "Há convite a ver, não proibição.",
                        "d": "O anjo desarma o medo das mulheres.",
                    },
                    options=opts(
                        ("a", "A ausência no túmulo contradiz o que ele disse."),
                        ("b", "Ele ressuscitou como disse; o túmulo está vazio."),
                        ("c", "As mulheres não devem olhar o lugar."),
                        ("d", "O anjo aumenta o temor sem dar notícia."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Mateus 28:5–6?",
                    feedback_correct="Certo: sem temor, notícia e convite a ver.",
                    feedback_wrong={
                        "b": "A ressurreição explica a ausência.",
                        "c": "Ver o lugar confirma a palavra.",
                    },
                    options=opts(
                        ("a", "o anjo tira o temor das mulheres"),
                        ("b", "anuncia: ressuscitou, como disse"),
                        ("c", "convida a ver o lugar onde ele jazia"),
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
                    question='Complete: "Ele não está ___, porque ressuscitou"',
                    feedback_correct="Certo: não está aqui.",
                    feedback_wrong={
                        "b": "Lugar é o que devem ver.",
                        "c": "Anjo é quem fala.",
                    },
                    options=opts(("a", "aqui"), ("b", "lugar"), ("c", "anjo")),
                    correct="a",
                    template="Ele não está ___, porque ressuscitou",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 28:5–6 comunica que se liga a este contexto?",
                    feedback_correct="Certo: ressuscitou como disse.",
                    feedback_wrong={
                        "b": "Há cumprimento, não falha.",
                        "c": "O túmulo vazio confirma a palavra.",
                    },
                    options=opts(
                        ("a", "Ressuscitou como disse"),
                        ("b", "Palavra sem cumprimento"),
                        ("c", "Túmulo ainda ocupado"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="A ressurreição em Mateus 28:6 é apresentada como cumprimento do que Jesus disse.",
                    feedback_correct="Certo: ressuscitou, como disse.",
                    feedback_wrong={"false": "O anjo liga a ausência ao que ele disse."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 28:5–6, toque a palavra que falta em "Mas o ___ disse às mulheres: Não temais vós"?',
                    feedback_correct="Exato: o anjo.",
                    feedback_wrong={
                        "b": "Jesus é quem procuram.",
                        "c": "Lugar é o que devem ver.",
                    },
                    options=opts(("a", "anjo"), ("b", "Jesus"), ("c", "lugar")),
                    correct="a",
                    template="Mas o ___ disse às mulheres: Não temais vós",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve entender sobre a ressurreição em Mateus 28:5–6?",
                    feedback_correct="Certo: o túmulo vazio cumpre a palavra de Jesus.",
                    feedback_wrong={
                        "a": "Há ausência real: não está aqui.",
                        "c": "O anjo convida a ver o lugar.",
                        "d": "Como disse: a fé se apoia na palavra cumprida.",
                    },
                    options=opts(
                        ("a", "O corpo ainda jaz; a palavra falhou."),
                        ("b", "O túmulo vazio cumpre o que Jesus disse."),
                        ("c", "As mulheres não devem verificar o lugar."),
                        ("d", "A ressurreição é só metáfora, sem ausência."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Mateus 28:5–6?",
                    feedback_correct="Certo: procura, ausência e cumprimento da palavra.",
                    feedback_wrong={
                        "b": "A ausência anuncia a ressurreição.",
                        "c": "Como disse fecha o sentido.",
                    },
                    options=opts(
                        ("a", "as mulheres procuram o crucificado"),
                        ("b", "ele não está aqui, porque ressuscitou"),
                        ("c", "isso acontece como ele disse"),
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
                    question='Complete: "ressuscitou, como ___"',
                    feedback_correct="Certo: como disse.",
                    feedback_wrong={
                        "b": "Temais é o medo removido.",
                        "c": "Vede é o convite ao lugar.",
                    },
                    options=opts(("a", "disse"), ("b", "temais"), ("c", "vede")),
                    correct="a",
                    template="ressuscitou, como ___",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 28:5–6 comunica que se liga a este contexto?",
                    feedback_correct="Certo: túmulo vazio — ressuscitou como disse.",
                    feedback_wrong={
                        "b": "Há cumprimento da palavra.",
                        "c": "A ausência é boa notícia.",
                    },
                    options=opts(
                        ("a", "Túmulo vazio como disse"),
                        ("b", "Palavra sem cumprimento"),
                        ("c", "Ausência sem ressurreição"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def mission_12():
    sec = "evg-boss-final"
    vref = "João 1:14; Mateus 28:6"
    evid = ["João 1:14", "Mateus 28:6"]
    lo = "Fechar o arco dos Evangelhos: Verbo feito carne e túmulo vazio."
    ins = "Evangelhos: o Verbo feito carne e o túmulo vazio."
    p = P12
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
                    question="O Verbo se fez carne e habitou entre nós.",
                    feedback_correct="Certo: João 1:14 abre o arco dos Evangelhos.",
                    feedback_wrong={"false": "O texto afirma a encarnação do Verbo."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em João 1:14; Mateus 28:6, toque a palavra que falta em "Ele não está aqui, porque ___, como disse"?',
                    feedback_correct="Exato: ressuscitou.",
                    feedback_wrong={
                        "b": "Verbo é de João 1:14.",
                        "c": "Carne descreve a encarnação.",
                    },
                    options=opts(("a", "ressuscitou"), ("b", "Verbo"), ("c", "carne")),
                    correct="a",
                    template="Ele não está aqui, porque ___, como disse",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que os textos unidos afirmam sobre Jesus?",
                    feedback_correct="Certo: Verbo feito carne e ressuscitado.",
                    feedback_wrong={
                        "b": "Há encarnação e ressurreição.",
                        "c": "Ele não está no túmulo.",
                        "d": "Habitou entre nós e ressuscitou.",
                    },
                    options=opts(
                        ("a", "É Verbo feito carne e ressuscitou."),
                        ("b", "Só encarnação, sem ressurreição."),
                        ("c", "Ainda jaz no lugar onde estava."),
                        ("d", "Nunca habitou entre nós."),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em João 1:14; Mateus 28:6?",
                    feedback_correct="Certo: carne, glória e ressurreição.",
                    feedback_wrong={
                        "b": "A glória segue a encarnação.",
                        "c": "A ressurreição fecha o arco.",
                    },
                    options=opts(
                        ("a", "O Verbo se fez carne e habitou entre nós"),
                        ("b", "vimos a sua glória, glória como do unigênito do Pai"),
                        ("c", "Ele não está aqui, porque ressuscitou, como disse"),
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
                    question='Complete: "O Verbo se fez ___ e habitou entre nós"',
                    feedback_correct="Certo: se fez carne.",
                    feedback_wrong={
                        "b": "Glória é vista depois.",
                        "c": "Ressuscitou é de Mateus 28:6.",
                    },
                    options=opts(("a", "carne"), ("b", "glória"), ("c", "ressuscitou")),
                    correct="a",
                    template="O Verbo se fez ___ e habitou entre nós",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que João 1:14; Mateus 28:6 comunica que se liga a este contexto?",
                    feedback_correct="Certo: Verbo feito carne e túmulo vazio.",
                    feedback_wrong={
                        "b": "Há encarnação e ressurreição.",
                        "c": "O túmulo não o retém.",
                    },
                    options=opts(
                        ("a", "Verbo feito carne e túmulo vazio"),
                        ("b", "Carne sem ressurreição"),
                        ("c", "Túmulo ainda ocupado"),
                    ),
                    correct="a",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Mateus 28:6 afirma que ele ainda jaz no lugar onde estava.",
                    feedback_correct="Certo: ele não está aqui, porque ressuscitou.",
                    feedback_wrong={"true": "Mateus 28:6: Ele não está aqui, porque ressuscitou."},
                    options=TF_OPTS,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em João 1:14; Mateus 28:6, toque a palavra que falta em "O ___ se fez carne e habitou entre nós"?',
                    feedback_correct="Exato: o Verbo.",
                    feedback_wrong={
                        "b": "Ressuscitou fecha o arco; aqui é Verbo.",
                        "c": "Glória é vista depois.",
                    },
                    options=opts(("a", "Verbo"), ("b", "ressuscitou"), ("c", "glória")),
                    correct="a",
                    template="O ___ se fez carne e habitou entre nós",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como João 1:14 e Mateus 28:6 se unem no arco dos Evangelhos?",
                    feedback_correct="Certo: o que habitou entre nós também ressuscitou.",
                    feedback_wrong={
                        "a": "Os textos se complementam no arco.",
                        "c": "Há túmulo vazio, não ocupado.",
                        "d": "A glória do unigênito não anula a ressurreição.",
                    },
                    options=opts(
                        ("a", "A encarnação torna a ressurreição impossível."),
                        ("b", "O Verbo que habitou entre nós também ressuscitou."),
                        ("c", "O túmulo ainda guarda o corpo do Verbo."),
                        ("d", "Só a glória importa; a ressurreição não."),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de João 1:14; Mateus 28:6?",
                    feedback_correct="Certo: encarnação, habitação e ressurreição.",
                    feedback_wrong={
                        "b": "Habitar entre nós é o meio da revelação.",
                        "c": "A ressurreição fecha o arco.",
                    },
                    options=opts(
                        ("a", "o Verbo se faz carne"),
                        ("b", "habita entre nós em graça e verdade"),
                        ("c", "não está no túmulo, porque ressuscitou"),
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
                    question='Complete: "Ele não está aqui, porque ressuscitou, como ___"',
                    feedback_correct="Certo: como disse.",
                    feedback_wrong={
                        "b": "Habitou é de João 1:14.",
                        "c": "Vimos refere-se à glória.",
                    },
                    options=opts(("a", "disse"), ("b", "habitou"), ("c", "vimos")),
                    correct="a",
                    template="Ele não está aqui, porque ressuscitou, como ___",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que João 1:14; Mateus 28:6 comunica que se liga a este contexto?",
                    feedback_correct="Certo: arco do Verbo encarnado e ressuscitado.",
                    feedback_wrong={
                        "b": "Há cumprimento, não falha.",
                        "c": "O túmulo vazio fecha o arco.",
                    },
                    options=opts(
                        ("a", "Arco: carne e ressurreição"),
                        ("b", "Encarnação sem cumprimento"),
                        ("c", "Túmulo sem notícia"),
                    ),
                    correct="a",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="O arco dos Evangelhos une o Verbo feito carne e o anúncio do túmulo vazio.",
                    feedback_correct="Certo: João 1:14 e Mateus 28:6 formam esse arco.",
                    feedback_wrong={"false": "Os dois textos sustentam esse fechamento."},
                    options=TF_OPTS,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em João 1:14; Mateus 28:6, toque a palavra que falta em "e vimos a sua ___, glória como do unigênito do Pai"?',
                    feedback_correct="Exato: glória.",
                    feedback_wrong={
                        "b": "Carne descreve a encarnação.",
                        "c": "Ressuscitou fecha o arco final.",
                    },
                    options=opts(("a", "glória"), ("b", "carne"), ("c", "ressuscitou")),
                    correct="a",
                    template="e vimos a sua ___, glória como do unigênito do Pai",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="O que o leitor deve levar do arco em João 1:14; Mateus 28:6?",
                    feedback_correct="Certo: o Verbo habitou e o túmulo está vazio.",
                    feedback_wrong={
                        "a": "Há carne real e ressurreição real.",
                        "c": "A palavra se cumpre: como disse.",
                        "d": "O unigênito não fica no túmulo.",
                    },
                    options=opts(
                        ("a", "Só metáfora: sem carne e sem ressurreição."),
                        ("b", "O Verbo habitou entre nós e o túmulo está vazio."),
                        ("c", "A ressurreição contradiz o que ele disse."),
                        ("d", "O unigênito permanece no lugar onde jazia."),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de João 1:14; Mateus 28:6?",
                    feedback_correct="Certo: encarnação, glória e túmulo vazio.",
                    feedback_wrong={
                        "b": "A glória interpreta quem habitou.",
                        "c": "A ressurreição fecha o Evangelho.",
                    },
                    options=opts(
                        ("a", "o Verbo se faz carne e habita entre nós"),
                        ("b", "sua glória é vista como do unigênito"),
                        ("c", "ele não está no túmulo, porque ressuscitou"),
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
                    question='Complete: "e habitou entre nós, cheio de ___ e de verdade"',
                    feedback_correct="Certo: cheio de graça.",
                    feedback_wrong={
                        "b": "Glória é vista depois.",
                        "c": "Ressuscitou é de Mateus 28:6.",
                    },
                    options=opts(("a", "graça"), ("b", "glória"), ("c", "ressuscitou")),
                    correct="a",
                    template="e habitou entre nós, cheio de ___ e de verdade",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que João 1:14; Mateus 28:6 comunica que se liga a este contexto?",
                    feedback_correct="Certo: Evangelhos — Verbo feito carne e túmulo vazio.",
                    feedback_wrong={
                        "b": "O arco une início e fim.",
                        "c": "Há ressurreição, não túmulo ocupado.",
                    },
                    options=opts(
                        ("a", "Verbo feito carne e túmulo vazio"),
                        ("b", "Arco sem ressurreição"),
                        ("c", "Carne sem habitação"),
                    ),
                    correct="a",
                ),
            ),
        ],
    )


def fix_m9_caminhada_complete(bank):
    """Ensure caminhada complete for ceia has unambiguous template about blood."""
    for q in bank:
        if (
            q["section"] == "evg-07-ceia"
            and q["difficulty"] == "caminhada"
            and q["type"] == "complete"
        ):
            q["question"] = (
                'Complete: "Este cálice é a nova aliança em meu sangue, que é ___ por vós"'
            )
            q["prompt"] = q["question"]
            q["cue"] = q["question"]
            q["template"] = (
                "Este cálice é a nova aliança em meu sangue, que é ___ por vós"
            )
            q["options"] = opts(("a", "derramado"), ("b", "dado"), ("c", "partiu"))
            q["correctOptionId"] = "a"
            q["correctAnswer"] = "a"
            q["feedbackCorrect"] = "Certo: derramado por vós."
            q["feedbackWrong"] = {
                "b": "Dado é do corpo; aqui o sangue é derramado.",
                "c": "Partiu descreve o pão, não o sangue.",
            }
    return bank


def main():
    bank = []
    for fn in (
        mission_1,
        mission_2,
        mission_3,
        mission_4,
        mission_5,
        mission_6,
        mission_7,
        mission_8,
        mission_9,
        mission_10,
        mission_11,
        mission_12,
    ):
        bank.extend(fn())
    bank = fix_m9_caminhada_complete(bank)
    assert len(bank) == 216, len(bank)
    OUT.write_text(json.dumps(bank, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUT} ({len(bank)} questions)")


if __name__ == "__main__":
    main()
