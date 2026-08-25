#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Gera perguntas-v2/_part_sermao-b.json — 10 missões × 18 = 180
(sm-boss-02 … sm-17). TB verbatim do pack."""
import json
from pathlib import Path

TRAIL = "sermao-do-monte"
OUT = Path(__file__).resolve().parent / "_part_sermao-b.json"
TF = [{"id": "true", "text": "Verdadeiro"}, {"id": "false", "text": "Falso"}]
SK = {"semente": "observe", "caminhada": "understand", "profundezas": "interpret"}
SHORT = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}


def opt(*pairs):
    return [{"id": i, "text": t} for i, t in pairs]


def make(
    section,
    vref,
    evid,
    lo,
    passage,
    difficulty,
    typ,
    nn,
    question,
    fc,
    fw,
    options,
    correct,
    *,
    template=None,
    correct_order=None,
    passage_a=None,
    passage_b=None,
):
    assert len(fc) <= 100, (len(fc), fc)
    for o in options:
        if typ == "choice":
            assert len(o["text"]) <= 90, (o["text"], len(o["text"]))
    q = {
        "difficulty": difficulty,
        "skill": SK[difficulty],
        "verseRef": vref,
        "learningObjective": lo,
        "evidence": evid,
        "type": typ,
        "question": question,
        "prompt": question,
        "cue": question,
        "feedbackCorrect": fc,
        "feedbackWrong": fw,
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
    return q


def pack(section, vref, evid, lo, passage, insight, rows):
    out = []
    for difficulty, typ, nn, kw in rows:
        pa = pb = None
        if typ == "connect":
            pa = {"ref": vref, "text": kw.pop("pa_text", passage[:140])}
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
                kw["question"],
                kw["fc"],
                kw["fw"],
                kw["options"],
                kw["correct"],
                template=kw.get("template"),
                correct_order=kw.get("correct_order"),
                passage_a=pa,
                passage_b=pb,
            )
        )
    return out


# ── TB verbatim from pack ──────────────────────────────────────────
PB2 = (
    "Bem-aventurados os misericordiosos, porque eles alcançarão misericórdia. "
    "Bem-aventurados os limpos de coração, porque eles verão a Deus. "
    "Bem-aventurados os pacificadores, porque eles serão chamados filhos de Deus. "
    "Bem-aventurados os que têm sido perseguidos por causa da justiça, porque deles é o reino dos céus."
)
P10 = (
    "Vós sois o sal da terra; se o sal se tiver tornado insípido, como se poderá "
    "restaurar-lhe o sabor? Para nada mais presta, senão para ser lançado fora e pisado pelos homens."
)
P11 = (
    "Vós sois a luz do mundo. Não se pode esconder uma cidade situada sobre um monte; "
    "ninguém acende uma candeia e a coloca debaixo do módio, mas no velador, e assim alumia "
    "a todos os que estão na casa. De tal modo brilhe a vossa luz diante dos homens, que eles "
    "vejam as vossas boas obras e glorifiquem a vosso Pai que está nos céus."
)
P12 = "Não penseis que vim revogar a lei ou os profetas; não vim revogar, mas cumprir."
P13 = (
    "Se estiveres, pois, apresentando a tua oferta no altar e aí te lembrares que teu irmão "
    "tem contra ti alguma coisa, deixa ali a tua oferta diante do altar, vai primeiro "
    "reconciliar-te com teu irmão e, depois, vem apresentar a tua oferta."
)
PB3 = (
    "Vós sois o sal da terra; se o sal se tiver tornado insípido, como se poderá "
    "restaurar-lhe o sabor? Para nada mais presta, senão para ser lançado fora e pisado "
    "pelos homens. Vós sois a luz do mundo."
)
P14 = (
    "Eu, porém, vos digo que todo o que põe seus olhos em uma mulher, para a cobiçar, "
    "já no seu coração adulterou com ela."
)
P15 = "Mas seja o vosso falar: sim, sim; não, não; pois tudo que passa disso vem do Maligno."
P16 = (
    "Eu, porém, vos digo: Não resistais ao homem mau; mas a qualquer que te dá na face "
    "direita, volta-lhe também a outra;"
)
P17 = "Eu, porém, vos digo: Amai os vossos inimigos e orai pelos que vos perseguem,"


def mission_boss_02():
    sec = "sm-boss-02-carater-do-reino"
    vr = "Mateus 5:7–10"
    ev = ["Mateus 5:7", "Mateus 5:8", "Mateus 5:9", "Mateus 5:10"]
    lo = "Reconhecer o caráter do reino: da misericórdia à perseguição por justiça."
    ins = "Caráter do reino: misericórdia à perseguição."
    p = PB2
    return pack(
        sec,
        vr,
        ev,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Bem-aventurados os misericordiosos, porque eles alcançarão misericórdia.",
                    fc="Certo: é a afirmação literal de Mateus 5:7.",
                    fw={"false": "O texto liga misericordiosos a alcançar misericórdia."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Bem-aventurados os ___, porque eles alcançarão misericórdia"?',
                    fc="Exato: os misericordiosos.",
                    fw={
                        "b": "Pacificadores vem depois, em 5:9.",
                        "c": "Limpos aparece em 5:8, não nesta lacuna.",
                    },
                    options=opt(
                        ("a", "misericordiosos"),
                        ("b", "pacificadores"),
                        ("c", "limpos"),
                    ),
                    correct="a",
                    template="Bem-aventurados os ___, porque eles alcançarão misericórdia",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que o texto afirma sobre os limpos de coração?",
                    fc="Certo: eles verão a Deus.",
                    fw={
                        "b": "Misericórdia é dos misericordiosos.",
                        "c": "Filhos de Deus são os pacificadores.",
                        "d": "O reino em 5:10 é dos perseguidos.",
                    },
                    options=opt(
                        ("a", "Eles verão a Deus"),
                        ("b", "Eles alcançarão misericórdia"),
                        ("c", "Serão chamados filhos de Deus"),
                        ("d", "Deles é o reino dos céus"),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                    fc="Certo: misericórdia, pureza, paz e perseguição.",
                    fw={
                        "b": "Limpos de coração vêm após os misericordiosos.",
                        "c": "Perseguidos fecham o bloco em 5:10.",
                    },
                    options=opt(
                        ("a", "Bem-aventurados os misericordiosos"),
                        ("b", "Bem-aventurados os limpos de coração"),
                        ("c", "Bem-aventurados os que têm sido perseguidos"),
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
                    question='Complete: "Bem-aventurados os pacificadores, porque eles serão chamados ___ de Deus"',
                    fc="Certo: filhos de Deus.",
                    fw={
                        "b": "Misericórdia é a promessa de 5:7.",
                        "c": "Coração aparece em 5:8.",
                    },
                    options=opt(("a", "filhos"), ("b", "misericórdia"), ("c", "coração")),
                    correct="a",
                    template="Bem-aventurados os pacificadores, porque eles serão chamados ___ de Deus",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: caráter do reino da misericórdia à perseguição.",
                    fw={
                        "b": "O bloco não trata só de riqueza material.",
                        "c": "Há promessas claras, não abandono do reino.",
                    },
                    options=opt(
                        ("a", "Misericórdia à perseguição"),
                        ("b", "Só riqueza material"),
                        ("c", "Reino sem caráter"),
                    ),
                    correct="a",
                    pa_text="Bem-aventurados os misericordiosos… os limpos… os pacificadores… os perseguidos…",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="No bloco de Mateus 5:7–10, só os pacificadores recebem qualquer promessa.",
                    fc="Certo que é falso: cada bem-aventurança traz sua promessa.",
                    fw={"true": "Misericórdia, visão de Deus, filiação e reino também são prometidos."},
                    options=TF,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Bem-aventurados os limpos de ___, porque eles verão a Deus"?',
                    fc="Exato: limpos de coração.",
                    fw={
                        "a": "Deus é quem eles verão.",
                        "c": "Justiça aparece na perseguição, em 5:10.",
                    },
                    options=opt(("a", "Deus"), ("b", "coração"), ("c", "justiça")),
                    correct="b",
                    template="Bem-aventurados os limpos de ___, porque eles verão a Deus",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o texto encadeia misericórdia, pureza, paz e perseguição?",
                    fc="Certo: cada traço do caráter traz sua promessa própria.",
                    fw={
                        "a": "Não há uma só promessa genérica para todos.",
                        "c": "O bloco não anula as promessas.",
                        "d": "A ordem vai da misericórdia à perseguição.",
                    },
                    options=opt(
                        ("a", "Todas as bem-aventuranças repetem a mesma promessa"),
                        ("b", "Cada traço do caráter traz uma promessa distinta"),
                        ("c", "Só a perseguição anula as demais promessas"),
                        ("d", "O texto começa pela perseguição e termina na misericórdia"),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question=f"Como se encadeiam os eventos de {vr}?",
                    fc="Certo: misericórdia, visão de Deus e filiação.",
                    fw={
                        "b": "Ver a Deus vem após a misericórdia.",
                        "c": "Filhos de Deus segue os pacificadores.",
                    },
                    options=opt(
                        ("a", "eles alcançarão misericórdia"),
                        ("b", "eles verão a Deus"),
                        ("c", "eles serão chamados filhos de Deus"),
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
                    question='Complete: "Bem-aventurados os que têm sido perseguidos por causa da ___, porque deles é o reino dos céus"',
                    fc="Certo: por causa da justiça.",
                    fw={
                        "b": "Misericórdia é de 5:7.",
                        "c": "Coração é de 5:8.",
                    },
                    options=opt(("a", "justiça"), ("b", "misericórdia"), ("c", "coração")),
                    correct="a",
                    template="Bem-aventurados os que têm sido perseguidos por causa da ___, porque deles é o reino dos céus",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: o caráter do reino une misericórdia e fidelidade sob pressão.",
                    fw={
                        "a": "Não é só aparência externa sem coração.",
                        "c": "O bloco não esvazia as promessas.",
                    },
                    options=opt(
                        ("a", "Só aparência externa"),
                        ("b", "Caráter do reino"),
                        ("c", "Sem nenhuma promessa"),
                    ),
                    correct="b",
                    pa_text="Bem-aventurados os misericordiosos… perseguidos por causa da justiça…",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Mateus 5:7–10 apresenta o caráter do reino desde a misericórdia até a perseguição por justiça.",
                    fc="Certo: o bloco desenha o cidadão do reino sob graça e pressão.",
                    fw={"false": "O texto vai de misericordiosos a perseguidos por justiça."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "porque deles é o ___ dos céus"?',
                    fc="Exato: o reino dos céus.",
                    fw={
                        "a": "Justiça é a causa da perseguição.",
                        "c": "Filhos é a promessa aos pacificadores.",
                    },
                    options=opt(("a", "justiça"), ("b", "reino"), ("c", "filhos")),
                    correct="b",
                    template="porque deles é o ___ dos céus",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="Qual sentido teológico Mateus 5:7–10 sustenta?",
                    fc="Certo: o reino forma caráter que oferece graça e permanece sob pressão.",
                    fw={
                        "a": "O bloco não reduz o reino a conforto sem custo.",
                        "c": "Misericórdia e pureza não são opcionais.",
                        "d": "Perseguição por justiça não anula a bem-aventurança.",
                    },
                    options=opt(
                        ("a", "O reino premia só quem evita qualquer sofrimento"),
                        ("b", "O caráter do reino une misericórdia, pureza, paz e fidelidade"),
                        ("c", "Misericórdia e pureza são dispensáveis no reino"),
                        ("d", "Perseguição por justiça prova abandono do reino"),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question=f"Qual sequência revela o sentido de {vr}?",
                    fc="Certo: misericórdia recebida, visão de Deus e filiação na paz.",
                    fw={
                        "b": "Ver a Deus segue a pureza de coração.",
                        "c": "Filhos de Deus fecha o sentido da paz.",
                    },
                    options=opt(
                        ("a", "alcançarão misericórdia"),
                        ("b", "verão a Deus"),
                        ("c", "serão chamados filhos de Deus"),
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
                    question='Complete: "Bem-aventurados os limpos de coração, porque eles ___ a Deus"',
                    fc="Certo: eles verão a Deus.",
                    fw={
                        "b": "Alcançarão é da misericórdia.",
                        "c": "Chamados é dos pacificadores.",
                    },
                    options=opt(("a", "verão"), ("b", "alcançarão"), ("c", "chamados")),
                    correct="a",
                    template="Bem-aventurados os limpos de coração, porque eles ___ a Deus",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: misericórdia à perseguição marca o caráter do reino.",
                    fw={
                        "a": "Não é conforto sem custo.",
                        "b": "Não é reino sem caráter.",
                    },
                    options=opt(
                        ("a", "Conforto sem custo"),
                        ("b", "Reino sem caráter"),
                        ("c", "Misericórdia à perseguição"),
                    ),
                    correct="c",
                    pa_text="Bem-aventurados os misericordiosos… perseguidos por causa da justiça…",
                ),
            ),
        ],
    )


def mission_10():
    sec = "sm-10-sal-da-terra"
    vr = "Mateus 5:13"
    ev = ["Mateus 5:13"]
    lo = "Reconhecer que o discípulo é sal da terra e não deve tornar-se insípido."
    ins = "Sal que não se torna insípido."
    p = P10
    return pack(
        sec,
        vr,
        ev,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Vós sois o sal da terra.",
                    fc="Certo: Jesus declara que os discípulos são o sal da terra.",
                    fw={"false": "O texto começa dizendo: Vós sois o sal da terra."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Vós sois o ___ da terra"?',
                    fc="Exato: o sal da terra.",
                    fw={
                        "b": "Terra é o âmbito, não a identidade.",
                        "c": "Homens aparece no fim do versículo.",
                    },
                    options=opt(("a", "sal"), ("b", "terra"), ("c", "homens")),
                    correct="a",
                    template="Vós sois o ___ da terra",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que acontece, segundo o texto, se o sal se tornar insípido?",
                    fc="Certo: para nada mais presta, senão para ser lançado fora.",
                    fw={
                        "b": "O texto não fala em restaurar sabor com facilidade.",
                        "c": "Não há valorização do sal insípido.",
                        "d": "O destino descrito é ser lançado fora e pisado.",
                    },
                    options=opt(
                        ("a", "Para nada mais presta, senão para ser lançado fora"),
                        ("b", "Torna-se ainda mais útil na terra"),
                        ("c", "É guardado com honra pelos homens"),
                        ("d", "Recupera o sabor sem qualquer perda"),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                    fc="Certo: identidade, risco de insipidez e inutilidade.",
                    fw={
                        "b": "A pergunta sobre o sabor vem após a identidade.",
                        "c": "Ser lançado fora fecha a consequência.",
                    },
                    options=opt(
                        ("a", "Vós sois o sal da terra"),
                        ("b", "se o sal se tiver tornado insípido"),
                        ("c", "para ser lançado fora e pisado pelos homens"),
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
                    question='Complete: "se o sal se tiver tornado ___, como se poderá restaurar-lhe o sabor?"',
                    fc="Certo: tornado insípido.",
                    fw={
                        "b": "Sabor é o que se perde, não a lacuna.",
                        "c": "Terra é o âmbito da identidade.",
                    },
                    options=opt(("a", "insípido"), ("b", "sabor"), ("c", "terra")),
                    correct="a",
                    template="se o sal se tiver tornado ___, como se poderá restaurar-lhe o sabor?",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: sal que não se torna insípido.",
                    fw={
                        "b": "O texto alerta contra a perda de sabor.",
                        "c": "Há risco real de inutilidade.",
                    },
                    options=opt(
                        ("a", "Sal que não se torna insípido"),
                        ("b", "Sal sem qualquer função"),
                        ("c", "Insipidez sem consequência"),
                    ),
                    correct="a",
                    pa_text="Vós sois o sal da terra; se o sal se tiver tornado insípido…",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Segundo Mateus 5:13, o sal insípido continua prestando para muitos usos nobres.",
                    fc="Certo que é falso: para nada mais presta, senão para ser lançado fora.",
                    fw={"true": "O texto diz que o sal insípido para nada mais presta."},
                    options=TF,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "como se poderá restaurar-lhe o ___?"?',
                    fc="Exato: o sabor.",
                    fw={
                        "a": "Sal é a identidade.",
                        "c": "Homens aparece no fim.",
                    },
                    options=opt(("a", "sal"), ("b", "sabor"), ("c", "homens")),
                    correct="b",
                    template="como se poderá restaurar-lhe o ___?",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o texto relaciona identidade de sal e risco de inutilidade?",
                    fc="Certo: ser sal exige preservar o sabor; perder o sabor anula a utilidade.",
                    fw={
                        "a": "A identidade não elimina o risco de se tornar insípido.",
                        "c": "Perder o sabor não é irrelevante no texto.",
                        "d": "O destino do sal insípido é ser lançado fora.",
                    },
                    options=opt(
                        ("a", "Ser sal garante sabor permanente sem qualquer risco"),
                        ("b", "Sem sabor, o sal perde a utilidade e é lançado fora"),
                        ("c", "Perder o sabor aumenta o valor do discípulo"),
                        ("d", "O texto celebra o sal insípido como exemplo"),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question=f"Como se encadeiam os eventos de {vr}?",
                    fc="Certo: identidade, pergunta sobre o sabor e consequência.",
                    fw={
                        "b": "A pergunta sobre restaurar o sabor vem no meio.",
                        "c": "Ser lançado fora é a consequência final.",
                    },
                    options=opt(
                        ("a", "Vós sois o sal da terra"),
                        ("b", "como se poderá restaurar-lhe o sabor?"),
                        ("c", "Para nada mais presta, senão para ser lançado fora"),
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
                    question='Complete: "Para nada mais presta, senão para ser lançado fora e ___ pelos homens"',
                    fc="Certo: pisado pelos homens.",
                    fw={
                        "b": "Insípido descreve a perda do sabor.",
                        "c": "Sabor é o que se perde.",
                    },
                    options=opt(("a", "pisado"), ("b", "insípido"), ("c", "sabor")),
                    correct="a",
                    template="Para nada mais presta, senão para ser lançado fora e ___ pelos homens",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: o discípulo deve manter o sabor do sal.",
                    fw={
                        "a": "Não há celebração da insipidez.",
                        "c": "A identidade de sal traz missão, não omissão.",
                    },
                    options=opt(
                        ("a", "Insipidez sem risco"),
                        ("b", "Sal que preserva sabor"),
                        ("c", "Sal só para isolamento"),
                    ),
                    correct="b",
                    pa_text="Vós sois o sal da terra; se o sal se tiver tornado insípido…",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Mateus 5:13 ensina que a identidade de sal inclui a responsabilidade de não perder o sabor.",
                    fc="Certo: ser sal implica preservar a influência, não diluí-la.",
                    fw={"false": "O alerta contra a insipidez mostra responsabilidade real."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Para nada mais presta, senão para ser ___ fora"?',
                    fc="Exato: lançado fora.",
                    fw={
                        "a": "Insípido é a condição anterior.",
                        "c": "Sabor é o que se perde.",
                    },
                    options=opt(("a", "insípido"), ("b", "lançado"), ("c", "sabor")),
                    correct="b",
                    template="Para nada mais presta, senão para ser ___ fora",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="Qual sentido teológico Mateus 5:13 sustenta?",
                    fc="Certo: o discípulo influencia o mundo; perder o sabor anula a missão.",
                    fw={
                        "a": "O texto não autoriza dissolver-se no ambiente.",
                        "c": "Há consequência grave para a insipidez.",
                        "d": "A identidade de sal não é ornamentação vazia.",
                    },
                    options=opt(
                        ("a", "O discípulo deve dissolver-se no padrão do mundo"),
                        ("b", "Ser sal exige preservar influência; sem sabor, há inutilidade"),
                        ("c", "Perder o sabor é indiferente para a missão"),
                        ("d", "Sal é só título simbólico, sem responsabilidade"),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question=f"Qual sequência revela o sentido de {vr}?",
                    fc="Certo: identidade, risco e consequência do sal insípido.",
                    fw={
                        "b": "O risco de tornar-se insípido vem após a identidade.",
                        "c": "Ser lançado fora revela a gravidade da perda.",
                    },
                    options=opt(
                        ("a", "Vós sois o sal da terra"),
                        ("b", "se o sal se tiver tornado insípido"),
                        ("c", "para ser lançado fora e pisado pelos homens"),
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
                    question='Complete: "Vós sois o sal da ___; se o sal se tiver tornado insípido"',
                    fc="Certo: sal da terra.",
                    fw={
                        "b": "Homens aparece no fim.",
                        "c": "Sabor é o que se restaura ou se perde.",
                    },
                    options=opt(("a", "terra"), ("b", "homens"), ("c", "sabor")),
                    correct="a",
                    template="Vós sois o sal da ___; se o sal se tiver tornado insípido",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: sal que não se torna insípido.",
                    fw={
                        "a": "Não é dissolução no mundo.",
                        "b": "Não é título sem missão.",
                    },
                    options=opt(
                        ("a", "Dissolução no mundo"),
                        ("b", "Título sem missão"),
                        ("c", "Sal que não se torna insípido"),
                    ),
                    correct="c",
                    pa_text="Vós sois o sal da terra; se o sal se tiver tornado insípido…",
                ),
            ),
        ],
    )


def mission_11():
    sec = "sm-11-luz-do-mundo"
    vr = "Mateus 5:14–16"
    ev = ["Mateus 5:14", "Mateus 5:15", "Mateus 5:16"]
    lo = "Reconhecer que o discípulo é luz do mundo e deve brilhar para a glória do Pai."
    ins = "Luz que não se esconde."
    p = P11
    return pack(
        sec,
        vr,
        ev,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Vós sois a luz do mundo.",
                    fc="Certo: Jesus declara que os discípulos são a luz do mundo.",
                    fw={"false": "O texto afirma: Vós sois a luz do mundo."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Vós sois a ___ do mundo"?',
                    fc="Exato: a luz do mundo.",
                    fw={
                        "b": "Mundo é o âmbito, não a identidade.",
                        "c": "Monte aparece na imagem da cidade.",
                    },
                    options=opt(("a", "luz"), ("b", "mundo"), ("c", "monte")),
                    correct="a",
                    template="Vós sois a ___ do mundo",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="Onde, segundo o texto, se coloca a candeia acesa?",
                    fc="Certo: no velador, e assim alumia a todos na casa.",
                    fw={
                        "b": "Debaixo do módio é o que ninguém faz.",
                        "c": "O texto não fala em esconder a candeia.",
                        "d": "Não se apaga a candeia no texto.",
                    },
                    options=opt(
                        ("a", "No velador, e assim alumia a todos na casa"),
                        ("b", "Debaixo do módio, para ocultá-la"),
                        ("c", "Fora da casa, sem iluminar ninguém"),
                        ("d", "Apagada, para não chamar atenção"),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                    fc="Certo: identidade de luz, candeia no velador e boas obras.",
                    fw={
                        "b": "A candeia no velador vem após a identidade.",
                        "c": "Boas obras e glória ao Pai fecham o trecho.",
                    },
                    options=opt(
                        ("a", "Vós sois a luz do mundo"),
                        ("b", "ninguém acende uma candeia e a coloca debaixo do módio, mas no velador"),
                        ("c", "vejam as vossas boas obras e glorifiquem a vosso Pai"),
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
                    question='Complete: "Não se pode esconder uma cidade situada sobre um ___"',
                    fc="Certo: sobre um monte.",
                    fw={
                        "b": "Módio é o recipiente da candeia.",
                        "c": "Velador é onde se coloca a candeia.",
                    },
                    options=opt(("a", "monte"), ("b", "módio"), ("c", "velador")),
                    correct="a",
                    template="Não se pode esconder uma cidade situada sobre um ___",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: luz que não se esconde.",
                    fw={
                        "b": "O texto rejeita esconder a luz.",
                        "c": "Há propósito: glorificar o Pai.",
                    },
                    options=opt(
                        ("a", "Luz que não se esconde"),
                        ("b", "Luz sob o módio"),
                        ("c", "Obras sem glória ao Pai"),
                    ),
                    correct="a",
                    pa_text="Vós sois a luz do mundo… brilhe a vossa luz diante dos homens…",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Segundo Mateus 5:14–16, a candeia deve ficar debaixo do módio para não incomodar.",
                    fc="Certo que é falso: ninguém a coloca debaixo do módio, mas no velador.",
                    fw={"true": "O texto rejeita esconder a candeia debaixo do módio."},
                    options=TF,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "ninguém acende uma ___ e a coloca debaixo do módio"?',
                    fc="Exato: uma candeia.",
                    fw={
                        "b": "Módio é o lugar errado.",
                        "c": "Velador é o lugar certo.",
                    },
                    options=opt(("a", "candeia"), ("b", "módio"), ("c", "velador")),
                    correct="a",
                    template="ninguém acende uma ___ e a coloca debaixo do módio",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o texto liga o brilho da luz às boas obras?",
                    fc="Certo: a luz brilha para que vejam as boas obras e glorifiquem o Pai.",
                    fw={
                        "a": "O objetivo não é autoexaltação.",
                        "c": "Obras não são para esconder a luz.",
                        "d": "Há ligação clara entre luz, obras e glória ao Pai.",
                    },
                    options=opt(
                        ("a", "As obras servem para glorificar o próprio discípulo"),
                        ("b", "As obras fazem os homens glorificarem o Pai nos céus"),
                        ("c", "As obras devem permanecer ocultas sob o módio"),
                        ("d", "O texto separa luz de qualquer prática visível"),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question=f"Como se encadeiam os eventos de {vr}?",
                    fc="Certo: cidade no monte, candeia no velador e brilho diante dos homens.",
                    fw={
                        "b": "A candeia no velador segue a imagem da cidade.",
                        "c": "O brilho diante dos homens fecha o encadeamento.",
                    },
                    options=opt(
                        ("a", "Não se pode esconder uma cidade situada sobre um monte"),
                        ("b", "ninguém acende uma candeia e a coloca debaixo do módio, mas no velador"),
                        ("c", "brilhe a vossa luz diante dos homens"),
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
                    question='Complete: "De tal modo brilhe a vossa luz diante dos ___, que eles vejam as vossas boas obras"',
                    fc="Certo: diante dos homens.",
                    fw={
                        "b": "Céus é onde está o Pai.",
                        "c": "Módio é o que se evita.",
                    },
                    options=opt(("a", "homens"), ("b", "céus"), ("c", "módio")),
                    correct="a",
                    template="De tal modo brilhe a vossa luz diante dos ___, que eles vejam as vossas boas obras",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: luz visível que aponta para o Pai.",
                    fw={
                        "a": "Não se trata de esconder a luz.",
                        "c": "O foco final é o Pai, não o ego.",
                    },
                    options=opt(
                        ("a", "Luz escondida no módio"),
                        ("b", "Luz que glorifica o Pai"),
                        ("c", "Obras para autoexaltação"),
                    ),
                    correct="b",
                    pa_text="brilhe a vossa luz diante dos homens… glorifiquem a vosso Pai",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Mateus 5:14–16 apresenta a luz do discípulo como testemunho que leva à glória do Pai.",
                    fc="Certo: as boas obras apontam para o Pai que está nos céus.",
                    fw={"false": "O texto termina com glorificar o Pai, não o discípulo."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "glorifiquem a vosso ___ que está nos céus"?',
                    fc="Exato: vosso Pai.",
                    fw={
                        "b": "Homens são quem veem as obras.",
                        "c": "Mundo é o âmbito da luz.",
                    },
                    options=opt(("a", "Pai"), ("b", "homens"), ("c", "mundo")),
                    correct="a",
                    template="glorifiquem a vosso ___ que está nos céus",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="Qual sentido teológico Mateus 5:14–16 sustenta?",
                    fc="Certo: a luz existe para ser vista e levar à glória do Pai.",
                    fw={
                        "a": "Ocultar a luz contradiz o ensino.",
                        "c": "O alvo não é fama pessoal.",
                        "d": "Luz sem obras não é o chamado do texto.",
                    },
                    options=opt(
                        ("a", "O discípulo deve ocultar a luz para evitar conflito"),
                        ("b", "A luz visível nas obras leva os homens a glorificar o Pai"),
                        ("c", "Boas obras servem sobretudo para fama pessoal"),
                        ("d", "Ser luz é título vazio, sem prática pública"),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question=f"Qual sequência revela o sentido de {vr}?",
                    fc="Certo: luz, brilho diante dos homens e glória ao Pai.",
                    fw={
                        "b": "O brilho público vem após a identidade.",
                        "c": "Glorificar o Pai é o telos do testemunho.",
                    },
                    options=opt(
                        ("a", "Vós sois a luz do mundo"),
                        ("b", "brilhe a vossa luz diante dos homens"),
                        ("c", "glorifiquem a vosso Pai que está nos céus"),
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
                    question='Complete: "mas no ___, e assim alumia a todos os que estão na casa"',
                    fc="Certo: no velador.",
                    fw={
                        "b": "Módio é o lugar rejeitado.",
                        "c": "Monte é da imagem da cidade.",
                    },
                    options=opt(("a", "velador"), ("b", "módio"), ("c", "monte")),
                    correct="a",
                    template="mas no ___, e assim alumia a todos os que estão na casa",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: luz que não se esconde.",
                    fw={
                        "a": "Não é ocultação da missão.",
                        "b": "Não é glória própria.",
                    },
                    options=opt(
                        ("a", "Ocultação da missão"),
                        ("b", "Glória própria"),
                        ("c", "Luz que não se esconde"),
                    ),
                    correct="c",
                    pa_text="Vós sois a luz do mundo… glorifiquem a vosso Pai que está nos céus",
                ),
            ),
        ],
    )


def mission_12():
    sec = "sm-12-jesus-e-a-lei"
    vr = "Mateus 5:17"
    ev = ["Mateus 5:17"]
    lo = "Reconhecer que Jesus não veio revogar a lei ou os profetas, mas cumprir."
    ins = "Não vim destruir, mas cumprir."
    p = P12
    return pack(
        sec,
        vr,
        ev,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Não penseis que vim revogar a lei ou os profetas; não vim revogar, mas cumprir.",
                    fc="Certo: é a afirmação literal do versículo.",
                    fw={"false": "O texto diz que Jesus veio cumprir, não revogar."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "não vim revogar, mas ___"?',
                    fc="Exato: mas cumprir.",
                    fw={
                        "b": "Revogar é o que ele nega.",
                        "c": "Lei é o objeto, não esta lacuna.",
                    },
                    options=opt(("a", "cumprir"), ("b", "revogar"), ("c", "lei")),
                    correct="a",
                    template="não vim revogar, mas ___",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que Jesus afirma sobre sua vinda em relação à lei e aos profetas?",
                    fc="Certo: não veio revogar, mas cumprir.",
                    fw={
                        "b": "Ele nega explicitamente a revogação.",
                        "c": "O texto não fala em ignorar os profetas.",
                        "d": "Não há substituição da lei por costume novo aqui.",
                    },
                    options=opt(
                        ("a", "Não veio revogar, mas cumprir"),
                        ("b", "Veio revogar a lei e os profetas"),
                        ("c", "Veio ignorar os profetas"),
                        ("d", "Veio substituir a lei por costume novo"),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                    fc="Certo: advertência, negação da revogação e cumprimento.",
                    fw={
                        "b": "A negação da revogação vem no meio.",
                        "c": "Cumprir fecha o sentido.",
                    },
                    options=opt(
                        ("a", "Não penseis que vim revogar a lei ou os profetas"),
                        ("b", "não vim revogar"),
                        ("c", "mas cumprir"),
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
                    question='Complete: "Não penseis que vim revogar a ___ ou os profetas"',
                    fc="Certo: a lei.",
                    fw={
                        "b": "Cumprir é o propósito.",
                        "c": "Profetas já está na frase.",
                    },
                    options=opt(("a", "lei"), ("b", "cumprir"), ("c", "profetas")),
                    correct="a",
                    template="Não penseis que vim revogar a ___ ou os profetas",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: não veio destruir, mas cumprir.",
                    fw={
                        "b": "O texto rejeita a ideia de revogação.",
                        "c": "Há cumprimento, não indiferença.",
                    },
                    options=opt(
                        ("a", "Não vim revogar, mas cumprir"),
                        ("b", "Vim abolir a Escritura"),
                        ("c", "Lei sem qualquer sentido"),
                    ),
                    correct="a",
                    pa_text="Não penseis que vim revogar a lei ou os profetas; não vim revogar, mas cumprir.",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Em Mateus 5:17, Jesus declara que veio revogar a lei e os profetas.",
                    fc="Certo que é falso: ele diz não vim revogar, mas cumprir.",
                    fw={"true": "O texto nega a revogação e afirma o cumprimento."},
                    options=TF,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Não penseis que vim ___ a lei ou os profetas"?',
                    fc="Exato: revogar.",
                    fw={
                        "b": "Cumprir é o contraste final.",
                        "c": "Profetas é o objeto junto com a lei.",
                    },
                    options=opt(("a", "revogar"), ("b", "cumprir"), ("c", "profetas")),
                    correct="a",
                    template="Não penseis que vim ___ a lei ou os profetas",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o texto relaciona a vinda de Jesus com a lei e os profetas?",
                    fc="Certo: ele nega a revogação e afirma o cumprimento.",
                    fw={
                        "a": "Não há abolição no versículo.",
                        "c": "Cumprir não é sinônimo de ignorar.",
                        "d": "A Escritura permanece no horizonte de Jesus.",
                    },
                    options=opt(
                        ("a", "Jesus aboliu a lei para começar do zero"),
                        ("b", "Jesus veio cumprir o que a lei e os profetas apontam"),
                        ("c", "Jesus tratou a lei como irrelevante"),
                        ("d", "Jesus só confirmou costumes humanos"),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question=f"Como se encadeiam os eventos de {vr}?",
                    fc="Certo: advertência, lei e profetas, depois cumprir.",
                    fw={
                        "b": "Lei e profetas são o objeto da frase.",
                        "c": "Cumprir é o desfecho.",
                    },
                    options=opt(
                        ("a", "Não penseis que vim revogar"),
                        ("b", "a lei ou os profetas"),
                        ("c", "não vim revogar, mas cumprir"),
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
                    question='Complete: "não vim revogar, mas ___"',
                    fc="Certo: cumprir.",
                    fw={
                        "b": "Lei é o objeto.",
                        "c": "Revogar é o que ele nega.",
                    },
                    options=opt(("a", "cumprir"), ("b", "lei"), ("c", "revogar")),
                    correct="a",
                    template="não vim revogar, mas ___",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: cumprimento, não destruição da Escritura.",
                    fw={
                        "a": "Não há abolição no texto.",
                        "c": "A Escritura não é descartada.",
                    },
                    options=opt(
                        ("a", "Abolição da Escritura"),
                        ("b", "Cumprimento da Escritura"),
                        ("c", "Indiferença à lei"),
                    ),
                    correct="b",
                    pa_text="não vim revogar, mas cumprir",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Mateus 5:17 apresenta Jesus como quem realiza o sentido da lei e dos profetas, sem revogá-los.",
                    fc="Certo: cumprir aprofunda, não relativiza a Escritura.",
                    fw={"false": "O contraste revogar/cumprir sustenta essa leitura."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Não penseis que vim revogar a lei ou os ___"?',
                    fc="Exato: os profetas.",
                    fw={
                        "b": "Cumprir é o propósito.",
                        "c": "Revogar é o verbo negado.",
                    },
                    options=opt(("a", "profetas"), ("b", "cumprir"), ("c", "revogar")),
                    correct="a",
                    template="Não penseis que vim revogar a lei ou os ___",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="Qual sentido teológico Mateus 5:17 sustenta?",
                    fc="Certo: Jesus aprofunda a Escritura ao cumpri-la, sem revogá-la.",
                    fw={
                        "a": "Cumprir não é sinônimo de abolir.",
                        "c": "A lei não é tratada como erro a descartar.",
                        "d": "Há continuidade e realização, não ruptura absoluta.",
                    },
                    options=opt(
                        ("a", "Cumprir significa abolir a autoridade da Escritura"),
                        ("b", "Jesus realiza o sentido da lei e dos profetas"),
                        ("c", "A lei era um equívoco que Jesus veio corrigir apagando-a"),
                        ("d", "Os profetas perdem valor com a vinda de Jesus"),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question=f"Qual sequência revela o sentido de {vr}?",
                    fc="Certo: não revogar a Escritura, e sim cumpri-la.",
                    fw={
                        "b": "A negação da revogação reforça o contraste.",
                        "c": "Cumprir revela o propósito da vinda.",
                    },
                    options=opt(
                        ("a", "Não penseis que vim revogar a lei ou os profetas"),
                        ("b", "não vim revogar"),
                        ("c", "mas cumprir"),
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
                    question='Complete: "Não ___ que vim revogar a lei ou os profetas"',
                    fc="Certo: Não penseis.",
                    fw={
                        "b": "Cumprir fecha o versículo.",
                        "c": "Lei é o objeto.",
                    },
                    options=opt(("a", "penseis"), ("b", "cumprir"), ("c", "lei")),
                    correct="a",
                    template="Não ___ que vim revogar a lei ou os profetas",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: não vim destruir, mas cumprir.",
                    fw={
                        "a": "Não é relativização vazia.",
                        "b": "Não é abolição da Escritura.",
                    },
                    options=opt(
                        ("a", "Relativizar a Escritura"),
                        ("b", "Abolir lei e profetas"),
                        ("c", "Não vim revogar, mas cumprir"),
                    ),
                    correct="c",
                    pa_text="não vim revogar, mas cumprir",
                ),
            ),
        ],
    )


def mission_13():
    sec = "sm-13-ira-e-reconciliacao"
    vr = "Mateus 5:23–24"
    ev = ["Mateus 5:23", "Mateus 5:24"]
    lo = "Reconhecer que a reconciliação com o irmão precede a apresentação da oferta."
    ins = "Reconcilia-te antes da oferta."
    p = P13
    return pack(
        sec,
        vr,
        ev,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Se te lembrares que teu irmão tem contra ti alguma coisa, deixa a oferta e reconcilia-te primeiro.",
                    fc="Certo: o texto manda reconciliar antes de apresentar a oferta.",
                    fw={"false": "A ordem é: deixa a oferta, reconcilia-te, depois oferece."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "deixa ali a tua ___ diante do altar"?',
                    fc="Exato: a oferta.",
                    fw={
                        "b": "Altar é o lugar, não o objeto deixado.",
                        "c": "Irmão é com quem se reconcilia.",
                    },
                    options=opt(("a", "oferta"), ("b", "altar"), ("c", "irmão")),
                    correct="a",
                    template="deixa ali a tua ___ diante do altar",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que o texto manda fazer antes de apresentar a oferta?",
                    fc="Certo: vai primeiro reconciliar-te com teu irmão.",
                    fw={
                        "b": "Não se oferece primeiro e reconcilia depois.",
                        "c": "Não se ignora o conflito.",
                        "d": "O texto não manda abandonar o altar para sempre.",
                    },
                    options=opt(
                        ("a", "Reconciliar-te primeiro com teu irmão"),
                        ("b", "Apresentar a oferta e só depois pensar no irmão"),
                        ("c", "Ignorar o que o irmão tem contra ti"),
                        ("d", "Abandonar o altar sem voltar"),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                    fc="Certo: lembrar, deixar a oferta e reconciliar.",
                    fw={
                        "b": "Deixar a oferta vem após lembrar do conflito.",
                        "c": "Reconciliar precede apresentar de novo a oferta.",
                    },
                    options=opt(
                        ("a", "aí te lembrares que teu irmão tem contra ti alguma coisa"),
                        ("b", "deixa ali a tua oferta diante do altar"),
                        ("c", "vai primeiro reconciliar-te com teu irmão"),
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
                    question='Complete: "vai primeiro ___ com teu irmão e, depois, vem apresentar a tua oferta"',
                    fc="Certo: reconciliar-te.",
                    fw={
                        "b": "Oferta é o que se deixa e depois se apresenta.",
                        "c": "Altar é o lugar da oferta.",
                    },
                    options=opt(
                        ("a", "reconciliar-te"),
                        ("b", "oferta"),
                        ("c", "altar"),
                    ),
                    correct="a",
                    template="vai primeiro ___ com teu irmão e, depois, vem apresentar a tua oferta",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: reconcilia-te antes da oferta.",
                    fw={
                        "b": "O culto não anula a necessidade de paz.",
                        "c": "Há prioridade clara da reconciliação.",
                    },
                    options=opt(
                        ("a", "Reconcilia-te antes da oferta"),
                        ("b", "Oferta sem reconciliação"),
                        ("c", "Irmão sem importância"),
                    ),
                    correct="a",
                    pa_text="deixa ali a tua oferta… vai primeiro reconciliar-te com teu irmão",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Segundo Mateus 5:23–24, apresentar a oferta dispensa reconciliar-se com o irmão.",
                    fc="Certo que é falso: a reconciliação vem primeiro.",
                    fw={"true": "O texto interrompe a oferta até haver reconciliação."},
                    options=TF,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "aí te lembrares que teu ___ tem contra ti alguma coisa"?',
                    fc="Exato: teu irmão.",
                    fw={
                        "b": "Altar é o lugar da oferta.",
                        "c": "Oferta é o que se deixa.",
                    },
                    options=opt(("a", "irmão"), ("b", "altar"), ("c", "oferta")),
                    correct="a",
                    template="aí te lembrares que teu ___ tem contra ti alguma coisa",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o texto relaciona adoração e relacionamento com o irmão?",
                    fc="Certo: a reconciliação precede a oferta no altar.",
                    fw={
                        "a": "O culto não anula o conflito pendente.",
                        "c": "O texto não autoriza adiar a paz indefinidamente.",
                        "d": "Há prioridade explícita da reconciliação.",
                    },
                    options=opt(
                        ("a", "A oferta no altar resolve sozinha qualquer conflito"),
                        ("b", "A reconciliação com o irmão vem antes de apresentar a oferta"),
                        ("c", "Só depois de anos se deve pensar em reconciliar"),
                        ("d", "O relacionamento com o irmão é irrelevante no culto"),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question=f"Como se encadeiam os eventos de {vr}?",
                    fc="Certo: deixar a oferta, reconciliar e depois apresentar.",
                    fw={
                        "b": "Reconciliar vem antes de voltar à oferta.",
                        "c": "Apresentar a oferta é o passo final.",
                    },
                    options=opt(
                        ("a", "deixa ali a tua oferta diante do altar"),
                        ("b", "vai primeiro reconciliar-te com teu irmão"),
                        ("c", "depois, vem apresentar a tua oferta"),
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
                    question='Complete: "deixa ali a tua oferta diante do ___, vai primeiro reconciliar-te"',
                    fc="Certo: diante do altar.",
                    fw={
                        "b": "Irmão é com quem se reconcilia.",
                        "c": "Oferta é o que se deixa.",
                    },
                    options=opt(("a", "altar"), ("b", "irmão"), ("c", "oferta")),
                    correct="a",
                    template="deixa ali a tua oferta diante do ___, vai primeiro reconciliar-te",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: paz com o irmão antes do culto.",
                    fw={
                        "a": "Não é culto que ignora o conflito.",
                        "c": "Não há indiferença ao irmão.",
                    },
                    options=opt(
                        ("a", "Culto que ignora o conflito"),
                        ("b", "Reconciliação antes da oferta"),
                        ("c", "Irmão irrelevante"),
                    ),
                    correct="b",
                    pa_text="vai primeiro reconciliar-te com teu irmão e, depois, vem apresentar a tua oferta",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Mateus 5:23–24 ensina que a adoração verdadeira não dispensa a reconciliação pendente.",
                    fc="Certo: o altar espera a paz com o irmão.",
                    fw={"false": "A ordem do texto coloca a reconciliação antes da oferta."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "depois, vem ___ a tua oferta"?',
                    fc="Exato: apresentar a oferta.",
                    fw={
                        "b": "Deixa é o verbo do início.",
                        "c": "Lembrares inicia o conflito.",
                    },
                    options=opt(("a", "apresentar"), ("b", "deixa"), ("c", "lembrares")),
                    correct="a",
                    template="depois, vem ___ a tua oferta",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="Qual sentido teológico Mateus 5:23–24 sustenta?",
                    fc="Certo: o culto ao Deus vivo exige paz restaurada com o irmão.",
                    fw={
                        "a": "O texto não sacraliza a oferta sem reconciliação.",
                        "c": "Relacionamentos quebrados importam no altar.",
                        "d": "Há prioridade ética clara antes do rito.",
                    },
                    options=opt(
                        ("a", "A oferta cobre qualquer ruptura com o irmão"),
                        ("b", "A reconciliação é condição prioritária antes da oferta"),
                        ("c", "Rituais importam mais que relacionamentos"),
                        ("d", "O conflito com o irmão pode ficar para depois do culto"),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question=f"Qual sequência revela o sentido de {vr}?",
                    fc="Certo: lembrar o conflito, deixar a oferta e reconciliar.",
                    fw={
                        "b": "Deixar a oferta interrompe o rito.",
                        "c": "Reconciliar revela a prioridade do reino.",
                    },
                    options=opt(
                        ("a", "aí te lembrares que teu irmão tem contra ti alguma coisa"),
                        ("b", "deixa ali a tua oferta diante do altar"),
                        ("c", "vai primeiro reconciliar-te com teu irmão"),
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
                    question='Complete: "Se estiveres, pois, apresentando a tua oferta no ___"',
                    fc="Certo: no altar.",
                    fw={
                        "b": "Irmão é o outro da reconciliação.",
                        "c": "Oferta é o que se apresenta.",
                    },
                    options=opt(("a", "altar"), ("b", "irmão"), ("c", "oferta")),
                    correct="a",
                    template="Se estiveres, pois, apresentando a tua oferta no ___",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: reconcilia-te antes da oferta.",
                    fw={
                        "a": "Não é culto sem paz.",
                        "b": "Não é oferta que apaga o conflito.",
                    },
                    options=opt(
                        ("a", "Culto sem paz"),
                        ("b", "Oferta que apaga o conflito"),
                        ("c", "Reconcilia-te antes da oferta"),
                    ),
                    correct="c",
                    pa_text="vai primeiro reconciliar-te com teu irmão e, depois, vem apresentar a tua oferta",
                ),
            ),
        ],
    )


def mission_boss_03():
    sec = "sm-boss-03-identidade-e-missao"
    vr = "Mateus 5:13–16"
    ev = ["Mateus 5:13", "Mateus 5:14", "Mateus 5:15", "Mateus 5:16"]
    lo = "Reconhecer que sal e luz definem a identidade e a missão do discípulo."
    ins = "Sal e luz: identidade e missão."
    p = PB3
    return pack(
        sec,
        vr,
        ev,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Vós sois o sal da terra; Vós sois a luz do mundo.",
                    fc="Certo: o texto une as duas identidades.",
                    fw={"false": "O trecho afirma sal da terra e luz do mundo."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Vós sois o ___ da terra"?',
                    fc="Exato: o sal.",
                    fw={
                        "b": "Luz é a segunda identidade.",
                        "c": "Mundo acompanha a luz.",
                    },
                    options=opt(("a", "sal"), ("b", "luz"), ("c", "mundo")),
                    correct="a",
                    template="Vós sois o ___ da terra",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="Quais identidades o texto afirma juntos neste bloco?",
                    fc="Certo: sal da terra e luz do mundo.",
                    fw={
                        "b": "Não há só sal sem luz neste bloco.",
                        "c": "Não é só luz sem sal.",
                        "d": "O texto não fala de escuridão como identidade.",
                    },
                    options=opt(
                        ("a", "Sal da terra e luz do mundo"),
                        ("b", "Somente sal, sem luz"),
                        ("c", "Somente luz, sem sal"),
                        ("d", "Escuridão e isolamento"),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                    fc="Certo: sal, risco de insipidez e luz.",
                    fw={
                        "b": "O risco do sal insípido vem após a identidade.",
                        "c": "Luz do mundo fecha o bloco do pack.",
                    },
                    options=opt(
                        ("a", "Vós sois o sal da terra"),
                        ("b", "se o sal se tiver tornado insípido"),
                        ("c", "Vós sois a luz do mundo"),
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
                    question='Complete: "Vós sois a ___ do mundo"',
                    fc="Certo: a luz do mundo.",
                    fw={
                        "b": "Sal é a primeira identidade.",
                        "c": "Terra acompanha o sal.",
                    },
                    options=opt(("a", "luz"), ("b", "sal"), ("c", "terra")),
                    correct="a",
                    template="Vós sois a ___ do mundo",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: sal e luz como identidade e missão.",
                    fw={
                        "b": "Não é isolamento sem missão.",
                        "c": "Há identidade clara, não ausência dela.",
                    },
                    options=opt(
                        ("a", "Sal e luz: identidade e missão"),
                        ("b", "Isolamento sem missão"),
                        ("c", "Sem identidade alguma"),
                    ),
                    correct="a",
                    pa_text="Vós sois o sal da terra… Vós sois a luz do mundo.",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="No bloco de Mateus 5:13–16, ser sal e luz são identidades sem qualquer risco ou missão.",
                    fc="Certo que é falso: há alerta de insipidez e chamada a ser luz.",
                    fw={"true": "O texto alerta o sal insípido e afirma a luz do mundo."},
                    options=TF,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "se o sal se tiver tornado ___"?',
                    fc="Exato: insípido.",
                    fw={
                        "b": "Sabor é o que se restaura.",
                        "c": "Homens aparece no fim do aviso.",
                    },
                    options=opt(("a", "insípido"), ("b", "sabor"), ("c", "homens")),
                    correct="a",
                    template="se o sal se tiver tornado ___",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como sal e luz se relacionam neste bloco?",
                    fc="Certo: juntas definem identidade e missão no mundo.",
                    fw={
                        "a": "Não são títulos vazios.",
                        "c": "Sal e luz não se excluem.",
                        "d": "Há missão pública, não só privado.",
                    },
                    options=opt(
                        ("a", "São apenas títulos sem responsabilidade"),
                        ("b", "Unem preservação e testemunho visível no mundo"),
                        ("c", "O discípulo escolhe ser só sal ou só luz"),
                        ("d", "Servem apenas para vida privada isolada"),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question=f"Como se encadeiam os eventos de {vr}?",
                    fc="Certo: identidade de sal, consequência e identidade de luz.",
                    fw={
                        "b": "Ser lançado fora segue a insipidez.",
                        "c": "Luz do mundo fecha o encadeamento do pack.",
                    },
                    options=opt(
                        ("a", "Vós sois o sal da terra"),
                        ("b", "Para nada mais presta, senão para ser lançado fora"),
                        ("c", "Vós sois a luz do mundo"),
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
                    question='Complete: "Para nada mais presta, senão para ser lançado fora e ___ pelos homens"',
                    fc="Certo: pisado pelos homens.",
                    fw={
                        "b": "Luz é a outra identidade.",
                        "c": "Sal é a primeira identidade.",
                    },
                    options=opt(("a", "pisado"), ("b", "luz"), ("c", "sal")),
                    correct="a",
                    template="Para nada mais presta, senão para ser lançado fora e ___ pelos homens",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: identidade de sal e luz com missão no mundo.",
                    fw={
                        "a": "Não é fuga do mundo.",
                        "c": "Não é título sem prática.",
                    },
                    options=opt(
                        ("a", "Fuga do mundo"),
                        ("b", "Identidade e missão"),
                        ("c", "Título sem prática"),
                    ),
                    correct="b",
                    pa_text="Vós sois o sal da terra… Vós sois a luz do mundo.",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Mateus 5:13–16 une sal e luz para mostrar que o discípulo influencia o mundo, não o contrário.",
                    fc="Certo: identidade e missão apontam para influência preservadora e luminosa.",
                    fw={"false": "Sal e luz são imagens de influência no mundo."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Vós sois a luz do ___"?',
                    fc="Exato: do mundo.",
                    fw={
                        "b": "Terra acompanha o sal.",
                        "c": "Sal é a outra imagem.",
                    },
                    options=opt(("a", "mundo"), ("b", "terra"), ("c", "sal")),
                    correct="a",
                    template="Vós sois a luz do ___",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="Qual sentido teológico Mateus 5:13–16 sustenta?",
                    fc="Certo: o discípulo é chamado a preservar e iluminar, não a diluir-se.",
                    fw={
                        "a": "Isolamento contradiz sal e luz.",
                        "c": "Insipidez e ocultação são alertas, não ideais.",
                        "d": "Há missão pública clara.",
                    },
                    options=opt(
                        ("a", "O discípulo deve isolar-se para preservar a fé"),
                        ("b", "Sal e luz chamam a influenciar o mundo com fidelidade"),
                        ("c", "Perder o sabor e esconder a luz são opções neutras"),
                        ("d", "Identidade cristã é só privada, sem missão"),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question=f"Qual sequência revela o sentido de {vr}?",
                    fc="Certo: sal, risco de inutilidade e luz do mundo.",
                    fw={
                        "b": "O risco revela a seriedade da identidade.",
                        "c": "Luz completa a missão do discípulo.",
                    },
                    options=opt(
                        ("a", "Vós sois o sal da terra"),
                        ("b", "se o sal se tiver tornado insípido"),
                        ("c", "Vós sois a luz do mundo"),
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
                    question='Complete: "como se poderá restaurar-lhe o ___?"',
                    fc="Certo: o sabor.",
                    fw={
                        "b": "Mundo acompanha a luz.",
                        "c": "Terra acompanha o sal.",
                    },
                    options=opt(("a", "sabor"), ("b", "mundo"), ("c", "terra")),
                    correct="a",
                    template="como se poderá restaurar-lhe o ___?",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: sal e luz como identidade e missão.",
                    fw={
                        "a": "Não é dissolução no padrão do mundo.",
                        "b": "Não é isolamento sem testemunho.",
                    },
                    options=opt(
                        ("a", "Dissolução no mundo"),
                        ("b", "Isolamento sem testemunho"),
                        ("c", "Sal e luz: identidade e missão"),
                    ),
                    correct="c",
                    pa_text="Vós sois o sal da terra… Vós sois a luz do mundo.",
                ),
            ),
        ],
    )


def mission_14():
    sec = "sm-14-adulterio-do-coracao"
    vr = "Mateus 5:28"
    ev = ["Mateus 5:28"]
    lo = "Reconhecer que olhar com desejo já adultera no coração."
    ins = "Olhar com desejo já adultera no coração."
    p = P14
    return pack(
        sec,
        vr,
        ev,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Todo o que põe seus olhos em uma mulher, para a cobiçar, já no seu coração adulterou com ela.",
                    fc="Certo: é a afirmação literal do versículo.",
                    fw={"false": "O texto liga olhar cobiçoso a adultério no coração."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "já no seu ___ adulterou com ela"?',
                    fc="Exato: no coração.",
                    fw={
                        "b": "Olhos inicia a ação.",
                        "c": "Mulher é o objeto do olhar.",
                    },
                    options=opt(("a", "coração"), ("b", "olhos"), ("c", "mulher")),
                    correct="a",
                    template="já no seu ___ adulterou com ela",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que o texto afirma sobre quem põe os olhos para cobiçar?",
                    fc="Certo: já no coração adulterou com ela.",
                    fw={
                        "b": "O texto não exige o ato físico para haver adultério.",
                        "c": "Há julgamento claro do desejo cobiçoso.",
                        "d": "O olhar com cobiça não é tratado como neutro.",
                    },
                    options=opt(
                        ("a", "Já no seu coração adulterou com ela"),
                        ("b", "Só adultera se houver ato físico"),
                        ("c", "O desejo cobiçoso é indiferente"),
                        ("d", "O olhar nunca alcança o coração"),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                    fc="Certo: olhar, cobiçar e adultério no coração.",
                    fw={
                        "b": "Cobiçar segue o olhar.",
                        "c": "O adultério no coração fecha a frase.",
                    },
                    options=opt(
                        ("a", "todo o que põe seus olhos em uma mulher"),
                        ("b", "para a cobiçar"),
                        ("c", "já no seu coração adulterou com ela"),
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
                    question='Complete: "todo o que põe seus ___ em uma mulher, para a cobiçar"',
                    fc="Certo: seus olhos.",
                    fw={
                        "b": "Coração é onde ocorre o adultério.",
                        "c": "Mulher é o objeto do olhar.",
                    },
                    options=opt(("a", "olhos"), ("b", "coração"), ("c", "mulher")),
                    correct="a",
                    template="todo o que põe seus ___ em uma mulher, para a cobiçar",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: olhar com desejo já adultera no coração.",
                    fw={
                        "b": "O texto não limita o adultério ao ato externo.",
                        "c": "Há julgamento do desejo cobiçoso.",
                    },
                    options=opt(
                        ("a", "Adultério já no coração"),
                        ("b", "Só o ato externo importa"),
                        ("c", "Desejo sem consequência"),
                    ),
                    correct="a",
                    pa_text="todo o que põe seus olhos… para a cobiçar, já no seu coração adulterou",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Segundo Mateus 5:28, o adultério só acontece no ato físico, nunca no coração.",
                    fc="Certo que é falso: o olhar cobiçoso já adultera no coração.",
                    fw={"true": "O texto localiza o adultério no coração pelo desejo."},
                    options=TF,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "para a ___, já no seu coração adulterou com ela"?',
                    fc="Exato: cobiçar.",
                    fw={
                        "b": "Olhos é o instrumento do olhar.",
                        "c": "Coração é o lugar do adultério.",
                    },
                    options=opt(("a", "cobiçar"), ("b", "olhos"), ("c", "coração")),
                    correct="a",
                    template="para a ___, já no seu coração adulterou com ela",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o texto relaciona olhar cobiçoso e adultério?",
                    fc="Certo: o desejo no olhar já constitui adultério no coração.",
                    fw={
                        "a": "Não há espera do ato físico neste versículo.",
                        "c": "O coração não fica fora do julgamento.",
                        "d": "Olhar e desejo estão ligados no texto.",
                    },
                    options=opt(
                        ("a", "O desejo só importa depois do ato físico"),
                        ("b", "Cobiçar com o olhar já adultera no coração"),
                        ("c", "O coração permanece limpo enquanto o ato não ocorre"),
                        ("d", "Olhar e desejo nunca se relacionam no texto"),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question=f"Como se encadeiam os eventos de {vr}?",
                    fc="Certo: declaração de Jesus, olhar e adultério no coração.",
                    fw={
                        "b": "O olhar cobiçoso vem no meio.",
                        "c": "O adultério no coração é o desfecho.",
                    },
                    options=opt(
                        ("a", "Eu, porém, vos digo"),
                        ("b", "todo o que põe seus olhos em uma mulher, para a cobiçar"),
                        ("c", "já no seu coração adulterou com ela"),
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
                    question='Complete: "já no seu coração ___ com ela"',
                    fc="Certo: adulterou.",
                    fw={
                        "b": "Cobiçar é a intenção do olhar.",
                        "c": "Olhos é o instrumento.",
                    },
                    options=opt(("a", "adulterou"), ("b", "cobiçar"), ("c", "olhos")),
                    correct="a",
                    template="já no seu coração ___ com ela",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: fidelidade começa no desejo e no olhar.",
                    fw={
                        "a": "Não é ética só externa.",
                        "c": "Há julgamento do coração.",
                    },
                    options=opt(
                        ("a", "Ética só externa"),
                        ("b", "Fidelidade no coração"),
                        ("c", "Desejo sem juízo"),
                    ),
                    correct="b",
                    pa_text="já no seu coração adulterou com ela",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Mateus 5:28 aprofunda o mandamento ao localizar o adultério também no desejo do coração.",
                    fc="Certo: Jesus leva a ética sexual ao olhar e ao desejo.",
                    fw={"false": "O contraste com o ato externo está no próprio versículo."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Eu, ___, vos digo que todo o que põe seus olhos"?',
                    fc="Exato: porém.",
                    fw={
                        "b": "Olhos vem depois.",
                        "c": "Coração fecha a frase.",
                    },
                    options=opt(("a", "porém"), ("b", "olhos"), ("c", "coração")),
                    correct="a",
                    template="Eu, ___, vos digo que todo o que põe seus olhos",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="Qual sentido teológico Mateus 5:28 sustenta?",
                    fc="Certo: a fidelidade do reino protege o coração, não só o ato externo.",
                    fw={
                        "a": "O texto não reduz a ética ao ato físico.",
                        "c": "O desejo cobiçoso não é tratado como inocente.",
                        "d": "Há aprofundamento, não relaxamento.",
                    },
                    options=opt(
                        ("a", "Só o ato físico importa para a fidelidade"),
                        ("b", "O desejo cobiçoso já viola a fidelidade no coração"),
                        ("c", "Olhar com cobiça é moralmente neutro"),
                        ("d", "Jesus relaxa a ética sexual do mandamento"),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question=f"Qual sequência revela o sentido de {vr}?",
                    fc="Certo: olhar, cobiça e adultério interior.",
                    fw={
                        "b": "A cobiça revela a intenção do olhar.",
                        "c": "O coração é onde o adultério se consuma no texto.",
                    },
                    options=opt(
                        ("a", "põe seus olhos em uma mulher"),
                        ("b", "para a cobiçar"),
                        ("c", "já no seu coração adulterou com ela"),
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
                    question='Complete: "Eu, porém, vos ___ que todo o que põe seus olhos"',
                    fc="Certo: vos digo.",
                    fw={
                        "b": "Cobiçar é a intenção.",
                        "c": "Adulterou é o desfecho.",
                    },
                    options=opt(("a", "digo"), ("b", "cobiçar"), ("c", "adulterou")),
                    correct="a",
                    template="Eu, porém, vos ___ que todo o que põe seus olhos",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: olhar com desejo já adultera no coração.",
                    fw={
                        "a": "Não é ética só de aparência.",
                        "b": "Não é desejo sem juízo.",
                    },
                    options=opt(
                        ("a", "Ética só de aparência"),
                        ("b", "Desejo sem juízo"),
                        ("c", "Olhar com desejo já adultera"),
                    ),
                    correct="c",
                    pa_text="já no seu coração adulterou com ela",
                ),
            ),
        ],
    )


def mission_15():
    sec = "sm-15-sim-sim-nao-nao"
    vr = "Mateus 5:37"
    ev = ["Mateus 5:37"]
    lo = "Reconhecer que o falar do discípulo deve ser sim, sim; não, não."
    ins = "Seja o vosso sim, sim; e o vosso não, não."
    p = P15
    return pack(
        sec,
        vr,
        ev,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Mas seja o vosso falar: sim, sim; não, não.",
                    fc="Certo: é a afirmação literal do versículo.",
                    fw={"false": "O texto manda que o falar seja sim, sim; não, não."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Mas seja o vosso ___: sim, sim; não, não"?',
                    fc="Exato: o falar.",
                    fw={
                        "b": "Sim é o conteúdo do falar.",
                        "c": "Maligno aparece no fim.",
                    },
                    options=opt(("a", "falar"), ("b", "sim"), ("c", "Maligno")),
                    correct="a",
                    template="Mas seja o vosso ___: sim, sim; não, não",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="De onde, segundo o texto, vem tudo que passa de sim, sim; não, não?",
                    fc="Certo: vem do Maligno.",
                    fw={
                        "b": "Não vem do Pai no texto.",
                        "c": "Não é indiferente.",
                        "d": "Não é fruto da sabedoria humana no versículo.",
                    },
                    options=opt(
                        ("a", "Vem do Maligno"),
                        ("b", "Vem do Pai"),
                        ("c", "Não vem de lugar algum"),
                        ("d", "Vem da sabedoria humana"),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                    fc="Certo: falar simples, sim/não e origem do excesso.",
                    fw={
                        "b": "Sim e não formam o padrão do falar.",
                        "c": "O Maligno fecha a advertência.",
                    },
                    options=opt(
                        ("a", "Mas seja o vosso falar"),
                        ("b", "sim, sim; não, não"),
                        ("c", "pois tudo que passa disso vem do Maligno"),
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
                    question='Complete: "pois tudo que passa disso vem do ___"',
                    fc="Certo: do Maligno.",
                    fw={
                        "b": "Falar é o que deve ser simples.",
                        "c": "Sim é o conteúdo do falar.",
                    },
                    options=opt(("a", "Maligno"), ("b", "falar"), ("c", "sim")),
                    correct="a",
                    template="pois tudo que passa disso vem do ___",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: seja o vosso sim, sim; e o vosso não, não.",
                    fw={
                        "b": "O texto rejeita o excesso no falar.",
                        "c": "Há padrão claro de integridade.",
                    },
                    options=opt(
                        ("a", "Sim, sim; não, não"),
                        ("b", "Excesso no falar"),
                        ("c", "Palavra sem integridade"),
                    ),
                    correct="a",
                    pa_text="Mas seja o vosso falar: sim, sim; não, não",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Segundo Mateus 5:37, tudo que passa de sim, sim; não, não vem do Pai.",
                    fc="Certo que é falso: vem do Maligno.",
                    fw={"true": "O texto atribui o excesso ao Maligno, não ao Pai."},
                    options=TF,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "sim, sim; ___, não"?',
                    fc="Exato: não, não.",
                    fw={
                        "b": "Falar é o sujeito da frase.",
                        "c": "Maligno fecha o versículo.",
                    },
                    options=opt(("a", "não"), ("b", "falar"), ("c", "Maligno")),
                    correct="a",
                    template="sim, sim; ___, não",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o texto relaciona a simplicidade do falar e a origem do excesso?",
                    fc="Certo: o falar deve bastar; o que passa disso vem do Maligno.",
                    fw={
                        "a": "O excesso não é elogiado.",
                        "c": "Há padrão ético claro.",
                        "d": "O Maligno está ligado ao que passa do sim/não.",
                    },
                    options=opt(
                        ("a", "Quanto mais juramentos, maior a confiança"),
                        ("b", "A palavra simples basta; o excesso vem do Maligno"),
                        ("c", "O falar pode ser qualquer coisa sem consequência"),
                        ("d", "O Maligno não se relaciona com o falar no texto"),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question=f"Como se encadeiam os eventos de {vr}?",
                    fc="Certo: padrão do falar, conteúdo e origem do excesso.",
                    fw={
                        "b": "Sim e não são o conteúdo.",
                        "c": "O Maligno explica o que passa disso.",
                    },
                    options=opt(
                        ("a", "seja o vosso falar"),
                        ("b", "sim, sim; não, não"),
                        ("c", "tudo que passa disso vem do Maligno"),
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
                    question='Complete: "Mas seja o vosso falar: ___, sim; não, não"',
                    fc="Certo: sim, sim.",
                    fw={
                        "b": "Maligno fecha o versículo.",
                        "c": "Falar é o sujeito.",
                    },
                    options=opt(("a", "sim"), ("b", "Maligno"), ("c", "falar")),
                    correct="a",
                    template="Mas seja o vosso falar: ___, sim; não, não",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: palavra simples revela caráter íntegro.",
                    fw={
                        "a": "Não é cultura de exageros.",
                        "c": "Há padrão claro de verdade.",
                    },
                    options=opt(
                        ("a", "Exageros no falar"),
                        ("b", "Palavra simples e íntegra"),
                        ("c", "Sem padrão algum"),
                    ),
                    correct="b",
                    pa_text="sim, sim; não, não; pois tudo que passa disso vem do Maligno",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Mateus 5:37 apresenta a integridade da palavra como marca do discípulo, contra o excesso do Maligno.",
                    fc="Certo: o sim e o não bastam; o excesso denuncia outra origem.",
                    fw={"false": "O contraste com o Maligno sustenta essa leitura."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "pois tudo que ___ disso vem do Maligno"?',
                    fc="Exato: passa.",
                    fw={
                        "b": "Falar é o sujeito.",
                        "c": "Sim é o conteúdo.",
                    },
                    options=opt(("a", "passa"), ("b", "falar"), ("c", "sim")),
                    correct="a",
                    template="pois tudo que ___ disso vem do Maligno",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="Qual sentido teológico Mateus 5:37 sustenta?",
                    fc="Certo: a verdade simples revela caráter; o excesso denuncia o Maligno.",
                    fw={
                        "a": "Juramentos elaborados não são o ideal do texto.",
                        "c": "Há juízo moral sobre o falar.",
                        "d": "A palavra do discípulo deve bastar.",
                    },
                    options=opt(
                        ("a", "Juramentos elaborados provam maior santidade"),
                        ("b", "A palavra simples basta; o excesso vem do Maligno"),
                        ("c", "O falar é moralmente neutro no reino"),
                        ("d", "O discípulo precisa de fórmulas para ser crível"),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question=f"Qual sequência revela o sentido de {vr}?",
                    fc="Certo: falar íntegro, padrão sim/não e origem do excesso.",
                    fw={
                        "b": "O padrão sim/não revela o ideal.",
                        "c": "O Maligno expõe a origem do excesso.",
                    },
                    options=opt(
                        ("a", "Mas seja o vosso falar"),
                        ("b", "sim, sim; não, não"),
                        ("c", "pois tudo que passa disso vem do Maligno"),
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
                    question='Complete: "Mas ___ o vosso falar: sim, sim; não, não"',
                    fc="Certo: seja.",
                    fw={
                        "b": "Maligno fecha o versículo.",
                        "c": "Passa descreve o excesso.",
                    },
                    options=opt(("a", "seja"), ("b", "Maligno"), ("c", "passa")),
                    correct="a",
                    template="Mas ___ o vosso falar: sim, sim; não, não",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: seja o vosso sim, sim; e o vosso não, não.",
                    fw={
                        "a": "Não é falar do Maligno.",
                        "b": "Não é excesso de fórmulas.",
                    },
                    options=opt(
                        ("a", "Falar do Maligno"),
                        ("b", "Excesso de fórmulas"),
                        ("c", "Sim, sim; não, não"),
                    ),
                    correct="c",
                    pa_text="Mas seja o vosso falar: sim, sim; não, não",
                ),
            ),
        ],
    )


def mission_16():
    sec = "sm-16-outra-face"
    vr = "Mateus 5:39"
    ev = ["Mateus 5:39"]
    lo = "Reconhecer o chamado a não resistir ao homem mau e a apresentar a outra face."
    ins = "Não resistais ao malvado; apresenta a outra face."
    p = P16
    return pack(
        sec,
        vr,
        ev,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Não resistais ao homem mau; mas a qualquer que te dá na face direita, volta-lhe também a outra.",
                    fc="Certo: é a afirmação literal do versículo.",
                    fw={"false": "O texto manda não resistir e voltar a outra face."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Não ___ ao homem mau"?',
                    fc="Exato: resistais.",
                    fw={
                        "b": "Homem é o objeto da frase.",
                        "c": "Face aparece depois.",
                    },
                    options=opt(("a", "resistais"), ("b", "homem"), ("c", "face")),
                    correct="a",
                    template="Não ___ ao homem mau",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que o texto manda fazer a quem te dá na face direita?",
                    fc="Certo: volta-lhe também a outra.",
                    fw={
                        "b": "Não há ordem de revidar.",
                        "c": "Não se foge no texto desta frase.",
                        "d": "Não se ignora a agressão com indiferença cínica.",
                    },
                    options=opt(
                        ("a", "Volta-lhe também a outra"),
                        ("b", "Revida com a mesma força"),
                        ("c", "Foge sem qualquer resposta"),
                        ("d", "Ignora o ensino de Jesus"),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                    fc="Certo: declaração, não resistir e voltar a outra face.",
                    fw={
                        "b": "Não resistir vem após a declaração.",
                        "c": "Voltar a outra face fecha a ordem.",
                    },
                    options=opt(
                        ("a", "Eu, porém, vos digo"),
                        ("b", "Não resistais ao homem mau"),
                        ("c", "volta-lhe também a outra"),
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
                    question='Complete: "a qualquer que te dá na face ___, volta-lhe também a outra"',
                    fc="Certo: face direita.",
                    fw={
                        "b": "Homem é quem agride.",
                        "c": "Mau qualifica o homem.",
                    },
                    options=opt(("a", "direita"), ("b", "homem"), ("c", "mau")),
                    correct="a",
                    template="a qualquer que te dá na face ___, volta-lhe também a outra",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: não resistais; apresenta a outra face.",
                    fw={
                        "b": "O texto rejeita a retaliação.",
                        "c": "Há chamada a não resistir.",
                    },
                    options=opt(
                        ("a", "Apresenta a outra face"),
                        ("b", "Retaliação imediata"),
                        ("c", "Resistência violenta"),
                    ),
                    correct="a",
                    pa_text="Não resistais ao homem mau… volta-lhe também a outra",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Em Mateus 5:39, Jesus manda revidar na mesma medida quem te dá na face.",
                    fc="Certo que é falso: manda voltar também a outra.",
                    fw={"true": "O texto ordena apresentar a outra face, não revidar."},
                    options=TF,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "volta-lhe também a ___"?',
                    fc="Exato: a outra.",
                    fw={
                        "b": "Direita descreve a face atingida.",
                        "c": "Mau qualifica o homem.",
                    },
                    options=opt(("a", "outra"), ("b", "direita"), ("c", "mau")),
                    correct="a",
                    template="volta-lhe também a ___",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o texto relaciona não resistir e a outra face?",
                    fc="Certo: em vez de retaliar, o discípulo oferece a outra face.",
                    fw={
                        "a": "Não há autorização de vingança pessoal.",
                        "c": "A resposta não é agressão equivalente.",
                        "d": "Há comando positivo após a negativa.",
                    },
                    options=opt(
                        ("a", "Não resistir autoriza vingança posterior"),
                        ("b", "Não resistir se expressa ao oferecer a outra face"),
                        ("c", "A outra face é símbolo de retaliação dobrada"),
                        ("d", "O texto separa não resistir de qualquer ação"),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question=f"Como se encadeiam os eventos de {vr}?",
                    fc="Certo: não resistir, agressão na face e oferecer a outra.",
                    fw={
                        "b": "A agressão na face direita vem no meio.",
                        "c": "Oferecer a outra é a resposta.",
                    },
                    options=opt(
                        ("a", "Não resistais ao homem mau"),
                        ("b", "a qualquer que te dá na face direita"),
                        ("c", "volta-lhe também a outra"),
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
                    question='Complete: "Não resistais ao ___ mau"',
                    fc="Certo: ao homem mau.",
                    fw={
                        "b": "Face é o lugar da agressão.",
                        "c": "Outra é a face oferecida.",
                    },
                    options=opt(("a", "homem"), ("b", "face"), ("c", "outra")),
                    correct="a",
                    template="Não resistais ao ___ mau",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: o reino transcende a retaliação.",
                    fw={
                        "a": "Não é olho por olho pessoal.",
                        "c": "Há chamada a não resistir.",
                    },
                    options=opt(
                        ("a", "Retaliação proporcional"),
                        ("b", "Não retaliar; outra face"),
                        ("c", "Vingança sagrada"),
                    ),
                    correct="b",
                    pa_text="Não resistais ao homem mau… volta-lhe também a outra",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Mateus 5:39 chama o discípulo a romper o ciclo da retaliação ao oferecer a outra face.",
                    fc="Certo: a resposta do reino não é devolver o mal com mal.",
                    fw={"false": "Voltar a outra face quebra a lógica da vingança."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Eu, ___, vos digo: Não resistais ao homem mau"?',
                    fc="Exato: porém.",
                    fw={
                        "b": "Face vem depois.",
                        "c": "Outra fecha a ordem.",
                    },
                    options=opt(("a", "porém"), ("b", "face"), ("c", "outra")),
                    correct="a",
                    template="Eu, ___, vos digo: Não resistais ao homem mau",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="Qual sentido teológico Mateus 5:39 sustenta?",
                    fc="Certo: o discípulo transcende a retaliação e espelha o reino sob pressão.",
                    fw={
                        "a": "O texto não autoriza vingança pessoal.",
                        "c": "Oferecer a outra face não é fraqueza vazia no ensino.",
                        "d": "Há comando claro contra resistir ao homem mau.",
                    },
                    options=opt(
                        ("a", "O discípulo deve vingar-se para preservar a honra"),
                        ("b", "O reino responde ao mal sem retaliação pessoal"),
                        ("c", "Oferecer a outra face é ironia, não chamado real"),
                        ("d", "Não resistir é apenas sugestão opcional"),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question=f"Qual sequência revela o sentido de {vr}?",
                    fc="Certo: autoridade de Jesus, não resistir e oferecer a outra face.",
                    fw={
                        "b": "Não resistir define a postura.",
                        "c": "A outra face revela a prática do reino.",
                    },
                    options=opt(
                        ("a", "Eu, porém, vos digo"),
                        ("b", "Não resistais ao homem mau"),
                        ("c", "volta-lhe também a outra"),
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
                    question='Complete: "mas a qualquer que te ___ na face direita, volta-lhe também a outra"',
                    fc="Certo: dá.",
                    fw={
                        "b": "Resistais é o verbo da negativa.",
                        "c": "Outra é a face oferecida.",
                    },
                    options=opt(("a", "dá"), ("b", "resistais"), ("c", "outra")),
                    correct="a",
                    template="mas a qualquer que te ___ na face direita, volta-lhe também a outra",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: não resistais; apresenta a outra face.",
                    fw={
                        "a": "Não é vingança do reino.",
                        "b": "Não é retaliação dobrada.",
                    },
                    options=opt(
                        ("a", "Vingança do reino"),
                        ("b", "Retaliação dobrada"),
                        ("c", "Não resistais; outra face"),
                    ),
                    correct="c",
                    pa_text="Não resistais ao homem mau… volta-lhe também a outra",
                ),
            ),
        ],
    )


def mission_17():
    sec = "sm-17-amor-aos-inimigos"
    vr = "Mateus 5:44"
    ev = ["Mateus 5:44"]
    lo = "Reconhecer o chamado a amar os inimigos e orar pelos que perseguem."
    ins = "Amai os vossos inimigos e orai pelos perseguidores."
    p = P17
    return pack(
        sec,
        vr,
        ev,
        lo,
        p,
        ins,
        [
            (
                "semente",
                "true_false",
                "01",
                dict(
                    question="Amai os vossos inimigos e orai pelos que vos perseguem.",
                    fc="Certo: é a afirmação literal do versículo.",
                    fw={"false": "O texto manda amar inimigos e orar pelos perseguidores."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Amai os vossos ___"?',
                    fc="Exato: inimigos.",
                    fw={
                        "b": "Perseguem descreve a ação dos outros.",
                        "c": "Orai é o segundo verbo.",
                    },
                    options=opt(("a", "inimigos"), ("b", "perseguem"), ("c", "orai")),
                    correct="a",
                    template="Amai os vossos ___",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que o texto manda fazer pelos que vos perseguem?",
                    fc="Certo: orai pelos que vos perseguem.",
                    fw={
                        "b": "Não há ordem de odiá-los.",
                        "c": "Não se ignora a perseguição no texto.",
                        "d": "Não há retaliação ordenada aqui.",
                    },
                    options=opt(
                        ("a", "Orai pelos que vos perseguem"),
                        ("b", "Odiai os que vos perseguem"),
                        ("c", "Ignorai os perseguidores"),
                        ("d", "Retaliai na mesma medida"),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                    fc="Certo: declaração, amar inimigos e orar pelos perseguidores.",
                    fw={
                        "b": "Amar os inimigos vem após a declaração.",
                        "c": "Orar pelos perseguidores fecha a ordem.",
                    },
                    options=opt(
                        ("a", "Eu, porém, vos digo"),
                        ("b", "Amai os vossos inimigos"),
                        ("c", "orai pelos que vos perseguem"),
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
                    question='Complete: "Amai os vossos inimigos e ___ pelos que vos perseguem"',
                    fc="Certo: orai.",
                    fw={
                        "b": "Inimigos é o objeto do amor.",
                        "c": "Perseguem descreve a ação deles.",
                    },
                    options=opt(("a", "orai"), ("b", "inimigos"), ("c", "perseguem")),
                    correct="a",
                    template="Amai os vossos inimigos e ___ pelos que vos perseguem",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: amai os inimigos e orai pelos perseguidores.",
                    fw={
                        "b": "O texto rejeita o ódio aos inimigos.",
                        "c": "Há chamado a orar, não a ignorar.",
                    },
                    options=opt(
                        ("a", "Amai e orai pelos inimigos"),
                        ("b", "Odiai os inimigos"),
                        ("c", "Ignore a perseguição"),
                    ),
                    correct="a",
                    pa_text="Amai os vossos inimigos e orai pelos que vos perseguem",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Segundo Mateus 5:44, basta amar os amigos; os inimigos ficam de fora do amor.",
                    fc="Certo que é falso: o texto manda amar os inimigos.",
                    fw={"true": "Jesus ordena amar os inimigos e orar pelos perseguidores."},
                    options=TF,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "orai pelos que vos ___"?',
                    fc="Exato: perseguem.",
                    fw={
                        "b": "Inimigos é o objeto do amor.",
                        "c": "Amai é o primeiro verbo.",
                    },
                    options=opt(("a", "perseguem"), ("b", "inimigos"), ("c", "Amai")),
                    correct="a",
                    template="orai pelos que vos ___",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o texto relaciona amor aos inimigos e oração?",
                    fc="Certo: amar e orar pelos perseguidores formam um só chamado.",
                    fw={
                        "a": "O amor não exclui a oração.",
                        "c": "Não há permissão para odiar.",
                        "d": "Amor e oração andam juntos no versículo.",
                    },
                    options=opt(
                        ("a", "Amar dispensa qualquer oração pelos perseguidores"),
                        ("b", "Amar os inimigos inclui orar pelos que perseguem"),
                        ("c", "Orar pelos perseguidores autoriza odiá-los"),
                        ("d", "Amor e oração são chamados incompatíveis"),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question=f"Como se encadeiam os eventos de {vr}?",
                    fc="Certo: autoridade de Jesus, amar e orar.",
                    fw={
                        "b": "Amar os inimigos é o primeiro mandato.",
                        "c": "Orar fecha o encadeamento.",
                    },
                    options=opt(
                        ("a", "Eu, porém, vos digo"),
                        ("b", "Amai os vossos inimigos"),
                        ("c", "orai pelos que vos perseguem"),
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
                    question='Complete: "Eu, porém, vos ___: Amai os vossos inimigos"',
                    fc="Certo: vos digo.",
                    fw={
                        "b": "Orai é o segundo mandato.",
                        "c": "Inimigos é o objeto.",
                    },
                    options=opt(("a", "digo"), ("b", "orai"), ("c", "inimigos")),
                    correct="a",
                    template="Eu, porém, vos ___: Amai os vossos inimigos",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: amor radical que inclui inimigos e perseguidores.",
                    fw={
                        "a": "Não é amor só aos amigos.",
                        "c": "Há oração, não só sentimento.",
                    },
                    options=opt(
                        ("a", "Amar só os amigos"),
                        ("b", "Amar também os inimigos"),
                        ("c", "Oração sem amor"),
                    ),
                    correct="b",
                    pa_text="Amai os vossos inimigos e orai pelos que vos perseguem",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="Mateus 5:44 revela o amor do reino que alcança inimigos e perseguidores em oração.",
                    fc="Certo: amar e orar pelos adversários distingue o discípulo.",
                    fw={"false": "O duplo mandato — amar e orar — sustenta essa leitura."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question=f'Em {vr}, toque a palavra que falta em "Eu, ___, vos digo: Amai os vossos inimigos"?',
                    fc="Exato: porém.",
                    fw={
                        "b": "Inimigos é o objeto.",
                        "c": "Orai é o segundo verbo.",
                    },
                    options=opt(("a", "porém"), ("b", "inimigos"), ("c", "orai")),
                    correct="a",
                    template="Eu, ___, vos digo: Amai os vossos inimigos",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="Qual sentido teológico Mateus 5:44 sustenta?",
                    fc="Certo: amar só os amigos não distingue; o reino ama inimigos e ora.",
                    fw={
                        "a": "O texto amplia o amor além do círculo amigável.",
                        "c": "Oração pelos perseguidores é mandato, não sugestão.",
                        "d": "Há chamado positivo, não só ausência de ódio.",
                    },
                    options=opt(
                        ("a", "Amar amigos basta para cumprir o chamado do reino"),
                        ("b", "O discípulo ama inimigos e ora pelos perseguidores"),
                        ("c", "Orar pelos perseguidores é opcional e raro"),
                        ("d", "O texto só proíbe o ódio, sem mandar amar"),
                    ),
                    correct="b",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question=f"Qual sequência revela o sentido de {vr}?",
                    fc="Certo: autoridade de Jesus, amor aos inimigos e oração.",
                    fw={
                        "b": "Amar os inimigos define o caráter do reino.",
                        "c": "Orar pelos perseguidores completa o chamado.",
                    },
                    options=opt(
                        ("a", "Eu, porém, vos digo"),
                        ("b", "Amai os vossos inimigos"),
                        ("c", "orai pelos que vos perseguem"),
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
                    question='Complete: "___ os vossos inimigos e orai pelos que vos perseguem"',
                    fc="Certo: Amai.",
                    fw={
                        "b": "Orai é o segundo verbo.",
                        "c": "Perseguem descreve os outros.",
                    },
                    options=opt(("a", "Amai"), ("b", "orai"), ("c", "perseguem")),
                    correct="a",
                    template="___ os vossos inimigos e orai pelos que vos perseguem",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question=f"O que {vr} comunica que se liga a este contexto?",
                    fc="Certo: amai os inimigos e orai pelos perseguidores.",
                    fw={
                        "a": "Não é amor só aos amigos.",
                        "b": "Não é ódio santificado.",
                    },
                    options=opt(
                        ("a", "Amar só os amigos"),
                        ("b", "Ódio aos inimigos"),
                        ("c", "Amai e orai pelos inimigos"),
                    ),
                    correct="c",
                    pa_text="Amai os vossos inimigos e orai pelos que vos perseguem",
                ),
            ),
        ],
    )


def main():
    questions = []
    questions += mission_boss_02()
    questions += mission_10()
    questions += mission_11()
    questions += mission_12()
    questions += mission_13()
    questions += mission_boss_03()
    questions += mission_14()
    questions += mission_15()
    questions += mission_16()
    questions += mission_17()
    assert len(questions) == 180, len(questions)
    OUT.write_text(json.dumps(questions, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUT} — {len(questions)} questions")
    secs = []
    for q in questions:
        if q["section"] not in secs:
            secs.append(q["section"])
    print("sections:", ", ".join(secs))


if __name__ == "__main__":
    main()
