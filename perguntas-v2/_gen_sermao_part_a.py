#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Gera perguntas-v2/_part_sermao-a.json — 10 missões × 18 = 180 (sm-01..sm-09)."""
import json
from pathlib import Path

TRAIL = "sermao-do-monte"
OUT = Path(__file__).resolve().parent / "_part_sermao-a.json"
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
    assert question == question  # noqa: identity
    assert len(fc) <= 100, (len(fc), fc)
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
            pa = {"ref": vref, "text": kw.pop("pa_text", passage[:120])}
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
P01 = "Vendo Jesus a multidão, subiu ao monte; depois de se ter sentado, aproximaram-se seus discípulos, e ele começou a ensiná-los, dizendo:"
P02 = "Bem-aventurados os humildes de espírito, porque deles é o reino dos céus."
P03 = "Bem-aventurados os que choram, porque eles serão consolados."
P04 = "Bem-aventurados os mansos, porque eles herdarão a terra."
P05 = "Bem-aventurados os que têm fome e sede de justiça, porque eles serão fartos."
PB1 = (
    "Bem-aventurados os humildes de espírito, porque deles é o reino dos céus. "
    "Bem-aventurados os que choram, porque eles serão consolados. "
    "Bem-aventurados os mansos, porque eles herdarão a terra. "
    "Bem-aventurados os que têm fome e sede de justiça, porque eles serão fartos."
)
P06 = "Bem-aventurados os misericordiosos, porque eles alcançarão misericórdia."
P07 = "Bem-aventurados os limpos de coração, porque eles verão a Deus."
P08 = "Bem-aventurados os pacificadores, porque eles serão chamados filhos de Deus."
P09 = "Bem-aventurados os que têm sido perseguidos por causa da justiça, porque deles é o reino dos céus."


def mission_01():
    sec = "sm-01-rei-no-monte"
    vr = "Mateus 5:1–2"
    ev = ["Mateus 5:1", "Mateus 5:2"]
    lo = "Reconhecer que o Rei sobe ao monte e ensina os discípulos que se aproximam."
    ins = "O Rei sobe e ensina os discípulos."
    p = P01
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
                    question="Vendo Jesus a multidão, subiu ao monte.",
                    fc="Certo: Jesus vê a multidão e sobe ao monte.",
                    fw={"false": "O texto diz que, vendo a multidão, Jesus subiu ao monte."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:1–2, toque a palavra que falta em "Vendo Jesus a ___, subiu ao monte"?',
                    fc="Exato: é a multidão que Jesus vê.",
                    fw={
                        "b": "Discípulos aproximam-se depois, no monte.",
                        "c": "Monte é o lugar, não quem Jesus vê.",
                    },
                    options=opt(("a", "multidão"), ("b", "discípulos"), ("c", "monte")),
                    correct="a",
                    template="Vendo Jesus a ___, subiu ao monte",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="O que o texto afirma que Jesus fez após ver a multidão?",
                    fc="Certo: ele subiu ao monte e começou a ensinar.",
                    fw={
                        "b": "O texto não diz que Jesus dispersou a multidão.",
                        "c": "Ele sobe ao monte; não permanece na planície.",
                        "d": "O ensino começa no monte, não no templo.",
                    },
                    options=opt(
                        ("a", "Subiu ao monte e começou a ensiná-los"),
                        ("b", "Ordenou que a multidão se dispersasse"),
                        ("c", "Permaneceu na planície sem subir"),
                        ("d", "Enviou os discípulos ao templo sozinhos"),
                    ),
                    correct="a",
                ),
            ),
            (
                "semente",
                "order",
                "04",
                dict(
                    question="Qual sequência mostra a ordem dos fatos em Mateus 5:1–2?",
                    fc="Certo: ver, subir e sentar, depois os discípulos se aproximam.",
                    fw={
                        "b": "A aproximação dos discípulos vem depois de Jesus se sentar.",
                        "c": "O ensino começa após a aproximação dos discípulos.",
                    },
                    options=opt(
                        ("a", "Vendo Jesus a multidão, subiu ao monte"),
                        ("b", "depois de se ter sentado, aproximaram-se seus discípulos"),
                        ("c", "ele começou a ensiná-los, dizendo"),
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
                    question='Complete: "depois de se ter sentado, aproximaram-se seus ___, e ele começou a ensiná-los"',
                    fc="Certo: são os discípulos que se aproximam.",
                    fw={
                        "b": "Multidão é quem Jesus vê no início, não nesta lacuna.",
                        "c": "Monte é o lugar, não quem se aproxima.",
                    },
                    options=opt(("a", "discípulos"), ("b", "multidão"), ("c", "monte")),
                    correct="a",
                    template="depois de se ter sentado, aproximaram-se seus ___, e ele começou a ensiná-los",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:1–2 comunica que se liga a este contexto?",
                    fc="Certo: o Rei sobe e ensina quem se aproxima como discípulo.",
                    fw={
                        "b": "O foco não é dispersar, e sim ensinar os discípulos.",
                        "c": "O texto mostra ensino no monte, não fuga da multidão.",
                    },
                    options=opt(
                        ("a", "O Rei sobe e ensina"),
                        ("b", "Jesus só dispersa multidões"),
                        ("c", "O monte serve só para fuga"),
                    ),
                    correct="a",
                    pa_text="Vendo Jesus a multidão, subiu ao monte; aproximaram-se seus discípulos, e ele começou a ensiná-los",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Jesus sobe ao monte apenas para afastar-se da multidão, sem intenção de ensinar.",
                    fc="Certo que é falso: ele começa a ensinar os discípulos.",
                    fw={"true": "O texto termina com Jesus ensinando, não só se afastando."},
                    options=TF,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:1–2, toque a palavra que falta em "ele começou a ___, dizendo"?',
                    fc="Exato: Jesus começa a ensiná-los.",
                    fw={
                        "a": "Sentado descreve a postura, não a ação desta lacuna.",
                        "c": "Aproximaram-se é dos discípulos, não desta lacuna.",
                    },
                    options=opt(("a", "sentado"), ("b", "ensiná-los"), ("c", "aproximaram-se")),
                    correct="b",
                    template="ele começou a ___, dizendo",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como o texto relaciona a multidão, o monte e os discípulos?",
                    fc="Certo: Jesus sobe; os discípulos se aproximam e recebem o ensino.",
                    fw={
                        "a": "O ensino é dirigido aos que se aproximam, não só à multidão.",
                        "c": "Não há disputa; há aproximação e ensino.",
                        "d": "Jesus ensina; não abandona os discípulos no vale.",
                    },
                    options=opt(
                        ("a", "A multidão sobe e Jesus ensina só a ela"),
                        ("b", "Jesus sobe; os discípulos se aproximam e são ensinados"),
                        ("c", "Os discípulos competem com a multidão pelo lugar"),
                        ("d", "Jesus deixa os discípulos no vale e sobe sozinho"),
                    ),
                    correct="b",
                ),
            ),
            (
                "caminhada",
                "order",
                "04",
                dict(
                    question="Como se encadeiam os eventos de Mateus 5:1–2?",
                    fc="Certo: visão da multidão, subida e assento, depois ensino.",
                    fw={
                        "b": "Os discípulos se aproximam depois que Jesus se senta.",
                        "c": "O ensino é o último passo da sequência.",
                    },
                    options=opt(
                        ("a", "Vendo Jesus a multidão"),
                        ("b", "subiu ao monte; depois de se ter sentado"),
                        ("c", "aproximaram-se seus discípulos, e ele começou a ensiná-los"),
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
                    question='Complete: "Vendo Jesus a multidão, ___ ao monte"',
                    fc="Certo: Jesus subiu ao monte.",
                    fw={
                        "b": "Sentado vem depois da subida.",
                        "c": "Ensiná-los é a ação final, não esta lacuna.",
                    },
                    options=opt(("a", "subiu"), ("b", "sentado"), ("c", "ensiná-los")),
                    correct="a",
                    template="Vendo Jesus a multidão, ___ ao monte",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:1–2 comunica que se liga a este contexto?",
                    fc="Certo: o ensino do Rei é para quem se aproxima como discípulo.",
                    fw={
                        "a": "O texto destaca aproximação e ensino, não só público.",
                        "c": "O monte é palco de ensino, não isolamento total.",
                    },
                    options=opt(
                        ("a", "O sermão é só para a multidão"),
                        ("b", "Discípulo se aproxima e ouve"),
                        ("c", "O Rei se isola sem ensinar"),
                    ),
                    correct="b",
                    pa_text="aproximaram-se seus discípulos, e ele começou a ensiná-los, dizendo",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="O início do sermão apresenta Jesus como Rei que sobe e ensina quem se aproxima.",
                    fc="Certo: a cena introduz o Rei-mestre no monte.",
                    fw={"false": "Subir, sentar e ensinar moldam a cena do Rei que ensina."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:1–2, toque a palavra que falta em "depois de se ter ___, aproximaram-se seus discípulos"?',
                    fc="Exato: depois de se ter sentado.",
                    fw={
                        "a": "Subiu descreve a subida, não esta lacuna.",
                        "c": "Ensiná-los vem depois da aproximação.",
                    },
                    options=opt(("a", "subiu"), ("b", "sentado"), ("c", "ensiná-los")),
                    correct="b",
                    template="depois de se ter ___, aproximaram-se seus discípulos",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="Qual leitura melhor captura o sentido da cena em Mateus 5:1–2?",
                    fc="Certo: o Rei assume o lugar de mestre diante dos discípulos.",
                    fw={
                        "a": "Não há rejeição da multidão; há foco nos que se aproximam.",
                        "b": "O monte não é só cenário turístico; é lugar de ensino.",
                        "d": "O texto não apresenta Jesus como discípulo de outro mestre.",
                    },
                    options=opt(
                        ("a", "Jesus rejeita a multidão e só fala em segredo"),
                        ("b", "O monte serve apenas como cenário geográfico neutro"),
                        ("c", "O Rei assume o lugar de mestre diante dos discípulos"),
                        ("d", "Jesus sobe para aprender com um mestre no monte"),
                    ),
                    correct="c",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Mateus 5:1–2?",
                    fc="Certo: visão, posição no monte, depois ensino aos discípulos.",
                    fw={
                        "b": "A posição no monte precede a aproximação.",
                        "c": "O ensino fecha a introdução do sermão.",
                    },
                    options=opt(
                        ("a", "Vendo Jesus a multidão"),
                        ("b", "subiu ao monte; depois de se ter sentado"),
                        ("c", "aproximaram-se seus discípulos, e ele começou a ensiná-los"),
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
                    question='Complete: "Vendo ___ a multidão, subiu ao monte"',
                    fc="Certo: é Jesus quem vê a multidão e sobe.",
                    fw={
                        "b": "Discípulos se aproximam depois.",
                        "c": "Multidão é o objeto visto, não o sujeito.",
                    },
                    options=opt(("a", "Jesus"), ("b", "discípulos"), ("c", "multidão")),
                    correct="a",
                    template="Vendo ___ a multidão, subiu ao monte",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:1–2 comunica que se liga a este contexto?",
                    fc="Certo: o sermão começa com o Rei que sobe e ensina.",
                    fw={
                        "a": "Não é só geografia; é introdução do ensino do Rei.",
                        "b": "Há ensino explícito, não silêncio no monte.",
                    },
                    options=opt(
                        ("a", "Só uma nota de viagem"),
                        ("b", "O Rei fica em silêncio"),
                        ("c", "O Rei sobe e ensina"),
                    ),
                    correct="c",
                    pa_text="subiu ao monte; aproximaram-se seus discípulos, e ele começou a ensiná-los",
                ),
            ),
        ],
    )


def mission_beatitude(
    sec,
    vr,
    evid,
    lo,
    insight,
    passage,
    *,
    sem_tf_q,
    sem_tf_ans,
    sem_tap_gap,
    sem_tap_correct,
    sem_tap_opts,
    sem_choice_q,
    sem_choice_opts,
    sem_choice_correct,
    sem_order,
    sem_complete_gap,
    sem_complete_correct,
    sem_complete_opts,
    sem_bridge,
    cam_tf_q,
    cam_tf_ans,
    cam_tap_gap,
    cam_tap_correct,
    cam_tap_opts,
    cam_choice_q,
    cam_choice_opts,
    cam_choice_correct,
    cam_order,
    cam_complete_gap,
    cam_complete_correct,
    cam_complete_opts,
    cam_bridge,
    pro_tf_q,
    pro_tf_ans,
    pro_tap_gap,
    pro_tap_correct,
    pro_tap_opts,
    pro_choice_q,
    pro_choice_opts,
    pro_choice_correct,
    pro_order,
    pro_complete_gap,
    pro_complete_correct,
    pro_complete_opts,
    pro_bridge,
    fw_notes,
):
    """Helper for short single-beatitude missions with varied gaps."""

    def fw_tap(wrong_ids, notes):
        return {i: notes[i] for i in wrong_ids}

    def fw_choice(correct, notes):
        return {i: notes[i] for i in "abcd" if i != correct}

    rows = []
    # SEMENTE
    rows.append(
        (
            "semente",
            "true_false",
            "01",
            dict(
                question=sem_tf_q,
                fc=fw_notes["sem_tf_fc"],
                fw={("false" if sem_tf_ans == "true" else "true"): fw_notes["sem_tf_fw"]},
                options=TF,
                correct=sem_tf_ans,
            ),
        )
    )
    wrong_tap = [o[0] for o in sem_tap_opts if o[0] != sem_tap_correct]
    rows.append(
        (
            "semente",
            "tap",
            "02",
            dict(
                question=f'Em {vr}, toque a palavra que falta em "{sem_tap_gap}"?',
                fc=fw_notes["sem_tap_fc"],
                fw=fw_tap(wrong_tap, fw_notes["sem_tap_fw"]),
                options=opt(*sem_tap_opts),
                correct=sem_tap_correct,
                template=sem_tap_gap,
            ),
        )
    )
    rows.append(
        (
            "semente",
            "choice",
            "03",
            dict(
                question=sem_choice_q,
                fc=fw_notes["sem_choice_fc"],
                fw=fw_choice(sem_choice_correct, fw_notes["sem_choice_fw"]),
                options=opt(*sem_choice_opts),
                correct=sem_choice_correct,
            ),
        )
    )
    rows.append(
        (
            "semente",
            "order",
            "04",
            dict(
                question=f"Qual sequência mostra a ordem dos fatos em {vr}?",
                fc=fw_notes["sem_order_fc"],
                fw={"b": fw_notes["sem_order_fw_b"], "c": fw_notes["sem_order_fw_c"]},
                options=opt(*sem_order),
                correct="a",
                correct_order=["a", "b", "c"],
            ),
        )
    )
    wrong_c = [o[0] for o in sem_complete_opts if o[0] != sem_complete_correct]
    rows.append(
        (
            "semente",
            "complete",
            "05",
            dict(
                question=f'Complete: "{sem_complete_gap}"',
                fc=fw_notes["sem_complete_fc"],
                fw=fw_tap(wrong_c, fw_notes["sem_complete_fw"]),
                options=opt(*sem_complete_opts),
                correct=sem_complete_correct,
                template=sem_complete_gap,
            ),
        )
    )
    rows.append(
        (
            "semente",
            "connect",
            "06",
            dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc=fw_notes["sem_connect_fc"],
                fw={"b": fw_notes["sem_connect_fw_b"], "c": fw_notes["sem_connect_fw_c"]},
                options=opt(*sem_bridge),
                correct="a",
                pa_text=passage,
            ),
        )
    )
    # CAMINHADA
    rows.append(
        (
            "caminhada",
            "true_false",
            "01",
            dict(
                question=cam_tf_q,
                fc=fw_notes["cam_tf_fc"],
                fw={("false" if cam_tf_ans == "true" else "true"): fw_notes["cam_tf_fw"]},
                options=TF,
                correct=cam_tf_ans,
            ),
        )
    )
    wrong_tap = [o[0] for o in cam_tap_opts if o[0] != cam_tap_correct]
    rows.append(
        (
            "caminhada",
            "tap",
            "02",
            dict(
                question=f'Em {vr}, toque a palavra que falta em "{cam_tap_gap}"?',
                fc=fw_notes["cam_tap_fc"],
                fw=fw_tap(wrong_tap, fw_notes["cam_tap_fw"]),
                options=opt(*cam_tap_opts),
                correct=cam_tap_correct,
                template=cam_tap_gap,
            ),
        )
    )
    rows.append(
        (
            "caminhada",
            "choice",
            "03",
            dict(
                question=cam_choice_q,
                fc=fw_notes["cam_choice_fc"],
                fw=fw_choice(cam_choice_correct, fw_notes["cam_choice_fw"]),
                options=opt(*cam_choice_opts),
                correct=cam_choice_correct,
            ),
        )
    )
    rows.append(
        (
            "caminhada",
            "order",
            "04",
            dict(
                question=f"Como se encadeiam os eventos de {vr}?",
                fc=fw_notes["cam_order_fc"],
                fw={"b": fw_notes["cam_order_fw_b"], "c": fw_notes["cam_order_fw_c"]},
                options=opt(*cam_order),
                correct="a",
                correct_order=["a", "b", "c"],
            ),
        )
    )
    wrong_c = [o[0] for o in cam_complete_opts if o[0] != cam_complete_correct]
    rows.append(
        (
            "caminhada",
            "complete",
            "05",
            dict(
                question=f'Complete: "{cam_complete_gap}"',
                fc=fw_notes["cam_complete_fc"],
                fw=fw_tap(wrong_c, fw_notes["cam_complete_fw"]),
                options=opt(*cam_complete_opts),
                correct=cam_complete_correct,
                template=cam_complete_gap,
            ),
        )
    )
    rows.append(
        (
            "caminhada",
            "connect",
            "06",
            dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc=fw_notes["cam_connect_fc"],
                fw={"a": fw_notes["cam_connect_fw_a"], "c": fw_notes["cam_connect_fw_c"]},
                options=opt(*cam_bridge),
                correct="b",
                pa_text=passage,
            ),
        )
    )
    # PROFUNDezas
    rows.append(
        (
            "profundezas",
            "true_false",
            "01",
            dict(
                question=pro_tf_q,
                fc=fw_notes["pro_tf_fc"],
                fw={("false" if pro_tf_ans == "true" else "true"): fw_notes["pro_tf_fw"]},
                options=TF,
                correct=pro_tf_ans,
            ),
        )
    )
    wrong_tap = [o[0] for o in pro_tap_opts if o[0] != pro_tap_correct]
    rows.append(
        (
            "profundezas",
            "tap",
            "02",
            dict(
                question=f'Em {vr}, toque a palavra que falta em "{pro_tap_gap}"?',
                fc=fw_notes["pro_tap_fc"],
                fw=fw_tap(wrong_tap, fw_notes["pro_tap_fw"]),
                options=opt(*pro_tap_opts),
                correct=pro_tap_correct,
                template=pro_tap_gap,
            ),
        )
    )
    rows.append(
        (
            "profundezas",
            "choice",
            "03",
            dict(
                question=pro_choice_q,
                fc=fw_notes["pro_choice_fc"],
                fw=fw_choice(pro_choice_correct, fw_notes["pro_choice_fw"]),
                options=opt(*pro_choice_opts),
                correct=pro_choice_correct,
            ),
        )
    )
    rows.append(
        (
            "profundezas",
            "order",
            "04",
            dict(
                question=f"Qual sequência revela o sentido de {vr}?",
                fc=fw_notes["pro_order_fc"],
                fw={"b": fw_notes["pro_order_fw_b"], "c": fw_notes["pro_order_fw_c"]},
                options=opt(*pro_order),
                correct="a",
                correct_order=["a", "b", "c"],
            ),
        )
    )
    wrong_c = [o[0] for o in pro_complete_opts if o[0] != pro_complete_correct]
    rows.append(
        (
            "profundezas",
            "complete",
            "05",
            dict(
                question=f'Complete: "{pro_complete_gap}"',
                fc=fw_notes["pro_complete_fc"],
                fw=fw_tap(wrong_c, fw_notes["pro_complete_fw"]),
                options=opt(*pro_complete_opts),
                correct=pro_complete_correct,
                template=pro_complete_gap,
            ),
        )
    )
    rows.append(
        (
            "profundezas",
            "connect",
            "06",
            dict(
                question=f"O que {vr} comunica que se liga a este contexto?",
                fc=fw_notes["pro_connect_fc"],
                fw={"a": fw_notes["pro_connect_fw_a"], "b": fw_notes["pro_connect_fw_b"]},
                options=opt(*pro_bridge),
                correct="c",
                pa_text=passage,
            ),
        )
    )
    return pack(sec, vr, evid, lo, passage, insight, rows)


def mission_02():
    return mission_beatitude(
        "sm-02-pobres-de-espirito",
        "Mateus 5:3",
        ["Mateus 5:3"],
        "Reconhecer que dos humildes de espírito é o reino dos céus.",
        "Deles é o reino dos céus.",
        P02,
        sem_tf_q="Bem-aventurados os humildes de espírito, porque deles é o reino dos céus.",
        sem_tf_ans="true",
        sem_tap_gap="Bem-aventurados os ___ de espírito, porque deles é o reino dos céus",
        sem_tap_correct="a",
        sem_tap_opts=[("a", "humildes"), ("b", "reino"), ("c", "céus")],
        sem_choice_q="O que o texto afirma sobre os humildes de espírito?",
        sem_choice_opts=[
            ("a", "Deles é o reino dos céus"),
            ("b", "Eles herdarão somente a terra"),
            ("c", "Eles serão consolados no pranto"),
            ("d", "Eles alcançarão misericórdia"),
        ],
        sem_choice_correct="a",
        sem_order=[
            ("a", "Bem-aventurados os humildes de espírito"),
            ("b", "porque deles é"),
            ("c", "o reino dos céus"),
        ],
        sem_complete_gap="Bem-aventurados os humildes de espírito, porque deles é o ___ dos céus",
        sem_complete_correct="b",
        sem_complete_opts=[("a", "humildes"), ("b", "reino"), ("c", "espírito")],
        sem_bridge=[
            ("a", "Deles é o reino"),
            ("b", "Só riqueza material"),
            ("c", "Reino negado aos humildes"),
        ],
        cam_tf_q="O texto promete o reino dos céus aos orgulhosos de espírito, não aos humildes.",
        cam_tf_ans="false",
        cam_tap_gap="Bem-aventurados os humildes de ___, porque deles é o reino dos céus",
        cam_tap_correct="c",
        cam_tap_opts=[("a", "reino"), ("b", "céus"), ("c", "espírito")],
        cam_choice_q="Como a bem-aventurança liga humildade de espírito e reino?",
        cam_choice_opts=[
            ("a", "A humildade dispensa qualquer necessidade do reino"),
            ("b", "O reino pertence a quem reconhece pobreza espiritual"),
            ("c", "O reino é prêmio só de quem acumula méritos"),
            ("d", "O texto separa humildade de qualquer promessa"),
        ],
        cam_choice_correct="b",
        cam_order=[
            ("a", "Bem-aventurados os humildes de espírito"),
            ("b", "porque deles é"),
            ("c", "o reino dos céus"),
        ],
        cam_complete_gap="Bem-aventurados os humildes de espírito, porque deles é o reino dos ___",
        cam_complete_correct="a",
        cam_complete_opts=[("a", "céus"), ("b", "humildes"), ("c", "espírito")],
        cam_bridge=[
            ("a", "Orgulho conquista o reino"),
            ("b", "Deles é o reino"),
            ("c", "Reino só para ricos"),
        ],
        pro_tf_q="A bem-aventurança apresenta o reino como pertencente aos humildes de espírito.",
        pro_tf_ans="true",
        pro_tap_gap="Bem-aventurados os humildes de espírito, porque ___ é o reino dos céus",
        pro_tap_correct="b",
        pro_tap_opts=[("a", "humildes"), ("b", "deles"), ("c", "céus")],
        pro_choice_q="Qual leitura teológica se sustenta em Mateus 5:3?",
        pro_choice_opts=[
            ("a", "O reino é mérito de quem se sente espiritualmente suficiente"),
            ("b", "Ser humilde de espírito é fraqueza que o reino rejeita"),
            ("c", "Quem se reconhece pobre diante de Deus recebe o reino"),
            ("d", "O texto elogia apenas pobreza econômica, sem dimensão espiritual"),
        ],
        pro_choice_correct="c",
        pro_order=[
            ("a", "Bem-aventurados os humildes de espírito"),
            ("b", "porque deles é"),
            ("c", "o reino dos céus"),
        ],
        pro_complete_gap="___ os humildes de espírito, porque deles é o reino dos céus",
        pro_complete_correct="c",
        pro_complete_opts=[("a", "reino"), ("b", "céus"), ("c", "Bem-aventurados")],
        pro_bridge=[
            ("a", "Autossuficiência no reino"),
            ("b", "Reino só para orgulhosos"),
            ("c", "Deles é o reino"),
        ],
        fw_notes={
            "sem_tf_fc": "Certo: é a promessa literal do versículo.",
            "sem_tf_fw": "Releia: deles é o reino dos céus.",
            "sem_tap_fc": "Exato: são os humildes de espírito.",
            "sem_tap_fw": {
                "b": "Reino é a promessa, não o sujeito.",
                "c": "Céus fecha a frase, não esta lacuna.",
            },
            "sem_choice_fc": "Certo: deles é o reino dos céus.",
            "sem_choice_fw": {
                "b": "Herdar a terra é a bem-aventurança dos mansos.",
                "c": "Consolo é a promessa aos que choram.",
                "d": "Misericórdia é a promessa aos misericordiosos.",
            },
            "sem_order_fc": "Certo: bem-aventurança, motivo e reino.",
            "sem_order_fw_b": "O motivo vem depois da declaração.",
            "sem_order_fw_c": "O reino dos céus fecha a frase.",
            "sem_complete_fc": "Certo: é o reino dos céus.",
            "sem_complete_fw": {
                "a": "Humildes é o sujeito, não esta lacuna.",
                "c": "Espírito qualifica os humildes, não o reino.",
            },
            "sem_connect_fc": "Certo: a ponte é que deles é o reino.",
            "sem_connect_fw_b": "O texto fala de reino, não de riqueza material.",
            "sem_connect_fw_c": "O reino é prometido aos humildes, não negado.",
            "cam_tf_fc": "Certo que é falso: o reino é dos humildes.",
            "cam_tf_fw": "O texto liga o reino aos humildes de espírito.",
            "cam_tap_fc": "Exato: humildes de espírito.",
            "cam_tap_fw": {
                "a": "Reino é a promessa, não esta lacuna.",
                "b": "Céus fecha a frase.",
            },
            "cam_choice_fc": "Certo: o reino pertence a quem se reconhece pobre.",
            "cam_choice_fw": {
                "a": "A humildade é caminho para o reino, não dispensa.",
                "c": "O texto não apresenta o reino como mérito acumulado.",
                "d": "Há promessa clara ligada à humildade.",
            },
            "cam_order_fc": "Certo: declaração, motivo e reino.",
            "cam_order_fw_b": "O motivo explica a bem-aventurança.",
            "cam_order_fw_c": "O reino dos céus é a promessa final.",
            "cam_complete_fc": "Certo: reino dos céus.",
            "cam_complete_fw": {
                "b": "Humildes é o sujeito inicial.",
                "c": "Espírito qualifica os humildes.",
            },
            "cam_connect_fc": "Certo: deles é o reino dos céus.",
            "cam_connect_fw_a": "O texto não exalta orgulho.",
            "cam_connect_fw_c": "O reino não é reservado aos ricos.",
            "pro_tf_fc": "Certo: o reino pertence aos humildes de espírito.",
            "pro_tf_fw": "A promessa é explícita: deles é o reino.",
            "pro_tap_fc": "Exato: deles é o reino.",
            "pro_tap_fw": {
                "a": "Humildes abre a frase, não esta lacuna.",
                "c": "Céus fecha a frase.",
            },
            "pro_choice_fc": "Certo: pobreza diante de Deus abre o reino.",
            "pro_choice_fw": {
                "a": "Autossuficiência contraria a humildade do texto.",
                "b": "O reino acolhe os humildes; não os rejeita.",
                "d": "O texto fala de espírito, não só de economia.",
            },
            "pro_order_fc": "Certo: bem-aventurança, motivo e reino.",
            "pro_order_fw_b": "O motivo liga humildade e reino.",
            "pro_order_fw_c": "O reino dos céus é a conclusão.",
            "pro_complete_fc": "Certo: Bem-aventurados abre a declaração.",
            "pro_complete_fw": {
                "a": "Reino é a promessa, não o início.",
                "b": "Céus fecha a frase.",
            },
            "pro_connect_fc": "Certo: deles é o reino dos céus.",
            "pro_connect_fw_a": "O texto não promove autossuficiência.",
            "pro_connect_fw_b": "O reino não é dos orgulhosos.",
        },
    )


def mission_03():
    return mission_beatitude(
        "sm-03-os-que-choram",
        "Mateus 5:4",
        ["Mateus 5:4"],
        "Reconhecer que os que choram serão consolados.",
        "Serão consolados.",
        P03,
        sem_tf_q="Bem-aventurados os que choram, porque eles serão consolados.",
        sem_tf_ans="true",
        sem_tap_gap="Bem-aventurados os que ___, porque eles serão consolados",
        sem_tap_correct="a",
        sem_tap_opts=[("a", "choram"), ("b", "consolados"), ("c", "eles")],
        sem_choice_q="O que o texto promete aos que choram?",
        sem_choice_opts=[
            ("a", "Eles serão consolados"),
            ("b", "Deles é o reino dos céus"),
            ("c", "Eles herdarão a terra"),
            ("d", "Eles serão fartos"),
        ],
        sem_choice_correct="a",
        sem_order=[
            ("a", "Bem-aventurados os que choram"),
            ("b", "porque eles serão"),
            ("c", "consolados"),
        ],
        sem_complete_gap="Bem-aventurados os que choram, porque eles serão ___",
        sem_complete_correct="b",
        sem_complete_opts=[("a", "choram"), ("b", "consolados"), ("c", "Bem-aventurados")],
        sem_bridge=[
            ("a", "Serão consolados"),
            ("b", "Choro sem esperança"),
            ("c", "Consolo negado"),
        ],
        cam_tf_q="O texto declara bem-aventurados os que riem, porque serão consolados.",
        cam_tf_ans="false",
        cam_tap_gap="Bem-aventurados os que choram, porque ___ serão consolados",
        cam_tap_correct="c",
        cam_tap_opts=[("a", "choram"), ("b", "consolados"), ("c", "eles")],
        cam_choice_q="Como o pranto e o consolo se relacionam no versículo?",
        cam_choice_opts=[
            ("a", "O choro é bem-aventurança sem qualquer promessa"),
            ("b", "O choro é caminho para o consolo prometido"),
            ("c", "O consolo vem só a quem nunca chora"),
            ("d", "O texto trata o choro como maldição permanente"),
        ],
        cam_choice_correct="b",
        cam_order=[
            ("a", "Bem-aventurados os que choram"),
            ("b", "porque eles serão"),
            ("c", "consolados"),
        ],
        cam_complete_gap="___ os que choram, porque eles serão consolados",
        cam_complete_correct="a",
        cam_complete_opts=[("a", "Bem-aventurados"), ("b", "choram"), ("c", "consolados")],
        cam_bridge=[
            ("a", "Choro é o fim"),
            ("b", "Serão consolados"),
            ("c", "Sem promessa alguma"),
        ],
        pro_tf_q="A bem-aventurança une o pranto presente ao consolo futuro prometido.",
        pro_tf_ans="true",
        pro_tap_gap="Bem-aventurados os que choram, porque eles ___ consolados",
        pro_tap_correct="b",
        pro_tap_opts=[("a", "choram"), ("b", "serão"), ("c", "eles")],
        pro_choice_q="Qual sentido teológico Mateus 5:4 sustenta?",
        pro_choice_opts=[
            ("a", "O pranto dos discípulos é inútil e sem resposta de Deus"),
            ("b", "Só quem nunca sofre pode ser chamado bem-aventurado"),
            ("c", "Deus promete consolo a quem chora no caminho do reino"),
            ("d", "O consolo é apenas emoção humana, sem promessa divina"),
        ],
        pro_choice_correct="c",
        pro_order=[
            ("a", "Bem-aventurados os que choram"),
            ("b", "porque eles serão"),
            ("c", "consolados"),
        ],
        pro_complete_gap="Bem-aventurados os que choram, porque eles serão ___",
        pro_complete_correct="c",
        pro_complete_opts=[("a", "choram"), ("b", "eles"), ("c", "consolados")],
        pro_bridge=[
            ("a", "Pranto sem Deus"),
            ("b", "Consolo impossível"),
            ("c", "Serão consolados"),
        ],
        fw_notes={
            "sem_tf_fc": "Certo: é a afirmação literal do versículo.",
            "sem_tf_fw": "O texto promete consolo aos que choram.",
            "sem_tap_fc": "Exato: os que choram.",
            "sem_tap_fw": {
                "b": "Consolados é a promessa, não esta lacuna.",
                "c": "Eles é o sujeito da promessa, não o verbo.",
            },
            "sem_choice_fc": "Certo: serão consolados.",
            "sem_choice_fw": {
                "b": "O reino é a promessa aos humildes (v.3).",
                "c": "Herdar a terra é dos mansos (v.5).",
                "d": "Ser fartos é dos que têm fome de justiça (v.6).",
            },
            "sem_order_fc": "Certo: declaração, motivo e consolo.",
            "sem_order_fw_b": "O motivo vem após a bem-aventurança.",
            "sem_order_fw_c": "Consolados fecha a promessa.",
            "sem_complete_fc": "Certo: serão consolados.",
            "sem_complete_fw": {
                "a": "Choram é o sujeito, não a promessa.",
                "c": "Bem-aventurados abre a frase.",
            },
            "sem_connect_fc": "Certo: a ponte é o consolo prometido.",
            "sem_connect_fw_b": "O texto não deixa o choro sem esperança.",
            "sem_connect_fw_c": "O consolo é afirmado, não negado.",
            "cam_tf_fc": "Certo que é falso: são os que choram.",
            "cam_tf_fw": "O texto fala dos que choram, não dos que riem.",
            "cam_tap_fc": "Exato: eles serão consolados.",
            "cam_tap_fw": {
                "a": "Choram abre a bem-aventurança.",
                "b": "Consolados é o predicado, não o sujeito.",
            },
            "cam_choice_fc": "Certo: o choro conduz ao consolo prometido.",
            "cam_choice_fw": {
                "a": "Há promessa explícita de consolo.",
                "c": "O consolo é aos que choram, não aos que nunca choram.",
                "d": "O texto chama bem-aventurados, não amaldiçoados.",
            },
            "cam_order_fc": "Certo: bem-aventurança, motivo e consolo.",
            "cam_order_fw_b": "O motivo explica a bem-aventurança.",
            "cam_order_fw_c": "Consolados é o fim da sequência.",
            "cam_complete_fc": "Certo: Bem-aventurados abre a frase.",
            "cam_complete_fw": {
                "b": "Choram é o sujeito.",
                "c": "Consolados é a promessa final.",
            },
            "cam_connect_fc": "Certo: serão consolados.",
            "cam_connect_fw_a": "O choro não é o fim no texto.",
            "cam_connect_fw_c": "Há promessa clara de consolo.",
            "pro_tf_fc": "Certo: pranto presente e consolo futuro se unem.",
            "pro_tf_fw": "A estrutura porque une choro e consolo.",
            "pro_tap_fc": "Exato: serão consolados.",
            "pro_tap_fw": {
                "a": "Choram é o sujeito inicial.",
                "c": "Eles é o sujeito da promessa.",
            },
            "pro_choice_fc": "Certo: Deus promete consolo no caminho do reino.",
            "pro_choice_fw": {
                "a": "O texto responde ao pranto com promessa.",
                "b": "O pranto não exclui a bem-aventurança.",
                "d": "O consolo é promessa, não só emoção.",
            },
            "pro_order_fc": "Certo: declaração, motivo e consolo.",
            "pro_order_fw_b": "O motivo liga choro e consolo.",
            "pro_order_fw_c": "Consolados fecha o sentido.",
            "pro_complete_fc": "Certo: serão consolados.",
            "pro_complete_fw": {
                "a": "Choram é o sujeito.",
                "b": "Eles é o pronome, não a promessa.",
            },
            "pro_connect_fc": "Certo: serão consolados.",
            "pro_connect_fw_a": "O texto não deixa o pranto sem Deus.",
            "pro_connect_fw_b": "O consolo é prometido, não impossível.",
        },
    )


def mission_04():
    return mission_beatitude(
        "sm-04-os-mansos",
        "Mateus 5:5",
        ["Mateus 5:5"],
        "Reconhecer que os mansos herdarão a terra.",
        "Herdarão a terra.",
        P04,
        sem_tf_q="Bem-aventurados os mansos, porque eles herdarão a terra.",
        sem_tf_ans="true",
        sem_tap_gap="Bem-aventurados os ___, porque eles herdarão a terra",
        sem_tap_correct="a",
        sem_tap_opts=[("a", "mansos"), ("b", "terra"), ("c", "herdarão")],
        sem_choice_q="O que o texto afirma sobre os mansos?",
        sem_choice_opts=[
            ("a", "Eles herdarão a terra"),
            ("b", "Eles serão consolados"),
            ("c", "Deles é o reino dos céus"),
            ("d", "Eles alcançarão misericórdia"),
        ],
        sem_choice_correct="a",
        sem_order=[
            ("a", "Bem-aventurados os mansos"),
            ("b", "porque eles herdarão"),
            ("c", "a terra"),
        ],
        sem_complete_gap="Bem-aventurados os mansos, porque eles herdarão a ___",
        sem_complete_correct="b",
        sem_complete_opts=[("a", "mansos"), ("b", "terra"), ("c", "eles")],
        sem_bridge=[
            ("a", "Herdarão a terra"),
            ("b", "Mansidão sem herança"),
            ("c", "Terra só aos violentos"),
        ],
        cam_tf_q="O texto promete que os mansos serão expulsos da terra, não que a herdarão.",
        cam_tf_ans="false",
        cam_tap_gap="Bem-aventurados os mansos, porque eles ___ a terra",
        cam_tap_correct="c",
        cam_tap_opts=[("a", "mansos"), ("b", "terra"), ("c", "herdarão")],
        cam_choice_q="Como a mansidão se liga à promessa da terra?",
        cam_choice_opts=[
            ("a", "A mansidão é fraqueza que perde qualquer herança"),
            ("b", "Os mansos recebem a terra como herança prometida"),
            ("c", "Só a força bruta garante a posse da terra"),
            ("d", "O texto separa mansidão de qualquer futuro"),
        ],
        cam_choice_correct="b",
        cam_order=[
            ("a", "Bem-aventurados os mansos"),
            ("b", "porque eles herdarão"),
            ("c", "a terra"),
        ],
        cam_complete_gap="Bem-aventurados os ___, porque eles herdarão a terra",
        cam_complete_correct="a",
        cam_complete_opts=[("a", "mansos"), ("b", "terra"), ("c", "herdarão")],
        cam_bridge=[
            ("a", "Violência herda a terra"),
            ("b", "Herdarão a terra"),
            ("c", "Mansos sem futuro"),
        ],
        pro_tf_q="A bem-aventurança apresenta a terra como herança dos mansos, não dos violentos.",
        pro_tf_ans="true",
        pro_tap_gap="Bem-aventurados os mansos, porque ___ herdarão a terra",
        pro_tap_correct="b",
        pro_tap_opts=[("a", "mansos"), ("b", "eles"), ("c", "terra")],
        pro_choice_q="Qual leitura se sustenta a partir de Mateus 5:5?",
        pro_choice_opts=[
            ("a", "O reino exalta a agressão como caminho de conquista"),
            ("b", "Mansidão é irrelevante para o futuro do povo de Deus"),
            ("c", "No reino, a herança da terra cabe aos mansos"),
            ("d", "A terra é prometida só a quem domina pela força"),
        ],
        pro_choice_correct="c",
        pro_order=[
            ("a", "Bem-aventurados os mansos"),
            ("b", "porque eles herdarão"),
            ("c", "a terra"),
        ],
        pro_complete_gap="___ os mansos, porque eles herdarão a terra",
        pro_complete_correct="c",
        pro_complete_opts=[("a", "terra"), ("b", "mansos"), ("c", "Bem-aventurados")],
        pro_bridge=[
            ("a", "Força conquista tudo"),
            ("b", "Sem herança alguma"),
            ("c", "Herdarão a terra"),
        ],
        fw_notes={
            "sem_tf_fc": "Certo: é a afirmação literal do versículo.",
            "sem_tf_fw": "O texto diz que os mansos herdarão a terra.",
            "sem_tap_fc": "Exato: os mansos.",
            "sem_tap_fw": {
                "b": "Terra é a herança, não o sujeito.",
                "c": "Herdarão é o verbo da promessa.",
            },
            "sem_choice_fc": "Certo: herdarão a terra.",
            "sem_choice_fw": {
                "b": "Consolo é dos que choram.",
                "c": "O reino é dos humildes de espírito.",
                "d": "Misericórdia é dos misericordiosos.",
            },
            "sem_order_fc": "Certo: bem-aventurança, motivo e terra.",
            "sem_order_fw_b": "O motivo vem depois da declaração.",
            "sem_order_fw_c": "A terra fecha a promessa.",
            "sem_complete_fc": "Certo: herdarão a terra.",
            "sem_complete_fw": {
                "a": "Mansos é o sujeito.",
                "c": "Eles é o pronome, não a herança.",
            },
            "sem_connect_fc": "Certo: herdarão a terra.",
            "sem_connect_fw_b": "Há herança prometida aos mansos.",
            "sem_connect_fw_c": "A terra não é só dos violentos no texto.",
            "cam_tf_fc": "Certo que é falso: eles herdarão a terra.",
            "cam_tf_fw": "O texto promete herança, não expulsão.",
            "cam_tap_fc": "Exato: herdarão a terra.",
            "cam_tap_fw": {
                "a": "Mansos é o sujeito.",
                "b": "Terra é o objeto da herança.",
            },
            "cam_choice_fc": "Certo: os mansos herdam a terra.",
            "cam_choice_fw": {
                "a": "O texto chama os mansos de bem-aventurados.",
                "c": "A força bruta não é o caminho do versículo.",
                "d": "Há promessa clara de herança.",
            },
            "cam_order_fc": "Certo: declaração, motivo e terra.",
            "cam_order_fw_b": "O motivo explica a bem-aventurança.",
            "cam_order_fw_c": "A terra é o fim da sequência.",
            "cam_complete_fc": "Certo: os mansos.",
            "cam_complete_fw": {
                "b": "Terra é a herança.",
                "c": "Herdarão é o verbo.",
            },
            "cam_connect_fc": "Certo: herdarão a terra.",
            "cam_connect_fw_a": "O texto não exalta a violência.",
            "cam_connect_fw_c": "Os mansos têm futuro prometido.",
            "pro_tf_fc": "Certo: a herança é dos mansos.",
            "pro_tf_fw": "O versículo contrapõe mansidão à lógica da força.",
            "pro_tap_fc": "Exato: eles herdarão.",
            "pro_tap_fw": {
                "a": "Mansos abre a frase.",
                "c": "Terra fecha a frase.",
            },
            "pro_choice_fc": "Certo: no reino, a terra cabe aos mansos.",
            "pro_choice_fw": {
                "a": "O texto não exalta agressão.",
                "b": "Mansidão está no centro da promessa.",
                "d": "A força não é o critério do versículo.",
            },
            "pro_order_fc": "Certo: bem-aventurança, motivo e terra.",
            "pro_order_fw_b": "O motivo liga mansidão e herança.",
            "pro_order_fw_c": "A terra conclui o sentido.",
            "pro_complete_fc": "Certo: Bem-aventurados abre a declaração.",
            "pro_complete_fw": {
                "a": "Terra é a herança final.",
                "b": "Mansos é o sujeito.",
            },
            "pro_connect_fc": "Certo: herdarão a terra.",
            "pro_connect_fw_a": "A força não é o caminho do texto.",
            "pro_connect_fw_b": "Há herança prometida.",
        },
    )


def mission_05():
    return mission_beatitude(
        "sm-05-fome-e-sede-de-justica",
        "Mateus 5:6",
        ["Mateus 5:6"],
        "Reconhecer que os que têm fome e sede de justiça serão fartos.",
        "Serão fartos.",
        P05,
        sem_tf_q="Bem-aventurados os que têm fome e sede de justiça, porque eles serão fartos.",
        sem_tf_ans="true",
        sem_tap_gap="Bem-aventurados os que têm fome e sede de ___, porque eles serão fartos",
        sem_tap_correct="a",
        sem_tap_opts=[("a", "justiça"), ("b", "fartos"), ("c", "fome")],
        sem_choice_q="O que o texto promete aos que têm fome e sede de justiça?",
        sem_choice_opts=[
            ("a", "Eles serão fartos"),
            ("b", "Eles herdarão a terra"),
            ("c", "Eles serão consolados"),
            ("d", "Eles verão a Deus"),
        ],
        sem_choice_correct="a",
        sem_order=[
            ("a", "Bem-aventurados os que têm fome e sede de justiça"),
            ("b", "porque eles serão"),
            ("c", "fartos"),
        ],
        sem_complete_gap="Bem-aventurados os que têm fome e sede de justiça, porque eles serão ___",
        sem_complete_correct="b",
        sem_complete_opts=[("a", "justiça"), ("b", "fartos"), ("c", "fome")],
        sem_bridge=[
            ("a", "Serão fartos"),
            ("b", "Fome sem resposta"),
            ("c", "Justiça sem promessa"),
        ],
        cam_tf_q="O texto declara bem-aventurados os que estão fartos de justiça, não os que têm fome dela.",
        cam_tf_ans="false",
        cam_tap_gap="Bem-aventurados os que têm ___ e sede de justiça, porque eles serão fartos",
        cam_tap_correct="c",
        cam_tap_opts=[("a", "justiça"), ("b", "fartos"), ("c", "fome")],
        cam_choice_q="Como fome de justiça e fartura se relacionam no versículo?",
        cam_choice_opts=[
            ("a", "A fome de justiça é inútil e sem preenchimento"),
            ("b", "Quem anseia por justiça será saciado"),
            ("c", "Só quem já está farto pode ser bem-aventurado"),
            ("d", "O texto elogia a indiferença à justiça"),
        ],
        cam_choice_correct="b",
        cam_order=[
            ("a", "Bem-aventurados os que têm fome e sede de justiça"),
            ("b", "porque eles serão"),
            ("c", "fartos"),
        ],
        cam_complete_gap="Bem-aventurados os que têm fome e ___ de justiça, porque eles serão fartos",
        cam_complete_correct="a",
        cam_complete_opts=[("a", "sede"), ("b", "fartos"), ("c", "eles")],
        cam_bridge=[
            ("a", "Indiferença é bem-aventurança"),
            ("b", "Serão fartos"),
            ("c", "Fome sem fim"),
        ],
        pro_tf_q="A bem-aventurança une o anseio por justiça à promessa de fartura.",
        pro_tf_ans="true",
        pro_tap_gap="Bem-aventurados os que têm fome e sede de justiça, porque eles serão ___",
        pro_tap_correct="b",
        pro_tap_opts=[("a", "justiça"), ("b", "fartos"), ("c", "sede")],
        pro_choice_q="Qual sentido teológico Mateus 5:6 sustenta?",
        pro_choice_opts=[
            ("a", "O desejo de justiça é excesso que o reino rejeita"),
            ("b", "Deus deixa a fome de justiça sem qualquer resposta"),
            ("c", "Quem anseia pela justiça de Deus será saciado"),
            ("d", "A fartura prometida é só comida física, sem justiça"),
        ],
        pro_choice_correct="c",
        pro_order=[
            ("a", "Bem-aventurados os que têm fome e sede de justiça"),
            ("b", "porque eles serão"),
            ("c", "fartos"),
        ],
        pro_complete_gap="___ os que têm fome e sede de justiça, porque eles serão fartos",
        pro_complete_correct="c",
        pro_complete_opts=[("a", "justiça"), ("b", "fartos"), ("c", "Bem-aventurados")],
        pro_bridge=[
            ("a", "Justiça sem Deus"),
            ("b", "Fome inútil"),
            ("c", "Serão fartos"),
        ],
        fw_notes={
            "sem_tf_fc": "Certo: é a afirmação literal do versículo.",
            "sem_tf_fw": "O texto promete fartura a quem tem fome de justiça.",
            "sem_tap_fc": "Exato: fome e sede de justiça.",
            "sem_tap_fw": {
                "b": "Fartos é a promessa, não o objeto da fome.",
                "c": "Fome abre o anseio, não o objeto.",
            },
            "sem_choice_fc": "Certo: serão fartos.",
            "sem_choice_fw": {
                "b": "Herdar a terra é dos mansos.",
                "c": "Consolo é dos que choram.",
                "d": "Ver a Deus é dos limpos de coração.",
            },
            "sem_order_fc": "Certo: bem-aventurança, motivo e fartura.",
            "sem_order_fw_b": "O motivo vem após a declaração.",
            "sem_order_fw_c": "Fartos fecha a promessa.",
            "sem_complete_fc": "Certo: serão fartos.",
            "sem_complete_fw": {
                "a": "Justiça é o objeto da fome.",
                "c": "Fome descreve o anseio.",
            },
            "sem_connect_fc": "Certo: serão fartos.",
            "sem_connect_fw_b": "Há resposta à fome no texto.",
            "sem_connect_fw_c": "A justiça vem com promessa de fartura.",
            "cam_tf_fc": "Certo que é falso: bem-aventurados os que têm fome.",
            "cam_tf_fw": "O texto elogia quem tem fome e sede de justiça.",
            "cam_tap_fc": "Exato: fome e sede.",
            "cam_tap_fw": {
                "a": "Justiça é o objeto.",
                "b": "Fartos é a promessa.",
            },
            "cam_choice_fc": "Certo: o anseio por justiça será saciado.",
            "cam_choice_fw": {
                "a": "Há promessa de fartura.",
                "c": "A bem-aventurança é de quem ainda tem fome.",
                "d": "O texto valoriza o anseio por justiça.",
            },
            "cam_order_fc": "Certo: declaração, motivo e fartura.",
            "cam_order_fw_b": "O motivo explica a bem-aventurança.",
            "cam_order_fw_c": "Fartos é o fim da sequência.",
            "cam_complete_fc": "Certo: fome e sede.",
            "cam_complete_fw": {
                "b": "Fartos é a promessa.",
                "c": "Eles é o sujeito da promessa.",
            },
            "cam_connect_fc": "Certo: serão fartos.",
            "cam_connect_fw_a": "Indiferença não é a bem-aventurança.",
            "cam_connect_fw_c": "A fome encontra resposta.",
            "pro_tf_fc": "Certo: anseio e fartura estão unidos.",
            "pro_tf_fw": "O porque liga fome de justiça e fartura.",
            "pro_tap_fc": "Exato: serão fartos.",
            "pro_tap_fw": {
                "a": "Justiça é o objeto da fome.",
                "c": "Sede completa o anseio.",
            },
            "pro_choice_fc": "Certo: quem anseia pela justiça será saciado.",
            "pro_choice_fw": {
                "a": "O desejo de justiça é bem-aventurança.",
                "b": "Há promessa explícita de fartura.",
                "d": "O objeto da fome é justiça, não só comida.",
            },
            "pro_order_fc": "Certo: bem-aventurança, motivo e fartura.",
            "pro_order_fw_b": "O motivo liga anseio e promessa.",
            "pro_order_fw_c": "Fartos conclui o sentido.",
            "pro_complete_fc": "Certo: Bem-aventurados abre a frase.",
            "pro_complete_fw": {
                "a": "Justiça é o objeto.",
                "b": "Fartos é a promessa.",
            },
            "pro_connect_fc": "Certo: serão fartos.",
            "pro_connect_fw_a": "A justiça no texto vem com Deus.",
            "pro_connect_fw_b": "A fome não é inútil.",
        },
    )


def mission_boss_01():
    sec = "sm-boss-01-bem-aventurancas"
    vr = "Mateus 5:3–6"
    ev = ["Mateus 5:3", "Mateus 5:4", "Mateus 5:5", "Mateus 5:6"]
    lo = "Reconhecer o conjunto das primeiras bem-aventuranças do reino."
    ins = "Bem-aventuranças do reino."
    p = PB1
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
                    question="Bem-aventurados os humildes de espírito, porque deles é o reino dos céus.",
                    fc="Certo: é a primeira bem-aventurança do bloco.",
                    fw={"false": "O texto abre com os humildes de espírito e o reino."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "semente",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:3–6, toque a palavra que falta em "Bem-aventurados os que choram, porque eles serão ___"?',
                    fc="Exato: serão consolados.",
                    fw={
                        "b": "Fartos é a promessa aos que têm fome de justiça.",
                        "c": "Terra é a herança dos mansos.",
                    },
                    options=opt(("a", "consolados"), ("b", "fartos"), ("c", "terra")),
                    correct="a",
                    template="Bem-aventurados os que choram, porque eles serão ___",
                ),
            ),
            (
                "semente",
                "choice",
                "03",
                dict(
                    question="Qual promessa o texto liga aos mansos neste bloco?",
                    fc="Certo: os mansos herdarão a terra.",
                    fw={
                        "b": "O reino é dos humildes de espírito.",
                        "c": "Consolo é dos que choram.",
                        "d": "Fartura é de quem tem fome de justiça.",
                    },
                    options=opt(
                        ("a", "Eles herdarão a terra"),
                        ("b", "Deles é o reino dos céus"),
                        ("c", "Eles serão consolados"),
                        ("d", "Eles serão fartos"),
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
                    fc="Certo: humildes, os que choram, mansos e fome de justiça.",
                    fw={
                        "b": "Os que choram vêm depois dos humildes.",
                        "c": "A fome de justiça fecha este bloco.",
                    },
                    options=opt(
                        ("a", "Bem-aventurados os humildes de espírito"),
                        ("b", "Bem-aventurados os que choram"),
                        ("c", "Bem-aventurados os mansos; os que têm fome e sede de justiça"),
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
                    question='Complete: "Bem-aventurados os que têm fome e sede de justiça, porque eles serão ___"',
                    fc="Certo: serão fartos.",
                    fw={
                        "b": "Consolados é dos que choram.",
                        "c": "Terra é dos mansos.",
                    },
                    options=opt(("a", "fartos"), ("b", "consolados"), ("c", "terra")),
                    correct="a",
                    template="Bem-aventurados os que têm fome e sede de justiça, porque eles serão ___",
                ),
            ),
            (
                "semente",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:3–6 comunica que se liga a este contexto?",
                    fc="Certo: são as bem-aventuranças do reino.",
                    fw={
                        "b": "O bloco é de bênçãos do reino, não de maldições.",
                        "c": "Há quatro bem-aventuranças, não só uma.",
                    },
                    options=opt(
                        ("a", "Bem-aventuranças do reino"),
                        ("b", "Lista de maldições"),
                        ("c", "Só uma promessa isolada"),
                    ),
                    correct="a",
                    pa_text="Bem-aventurados os humildes de espírito… serão fartos.",
                ),
            ),
            (
                "caminhada",
                "true_false",
                "01",
                dict(
                    question="Neste bloco, a única promessa é herdar a terra; as outras bem-aventuranças não trazem promessa.",
                    fc="Certo que é falso: cada bem-aventurança traz sua promessa.",
                    fw={"true": "Reino, consolo, terra e fartura aparecem no bloco."},
                    options=TF,
                    correct="false",
                ),
            ),
            (
                "caminhada",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:3–6, toque a palavra que falta em "Bem-aventurados os ___, porque eles herdarão a terra"?',
                    fc="Exato: os mansos herdarão a terra.",
                    fw={
                        "a": "Humildes recebem o reino dos céus.",
                        "c": "Choram liga-se ao consolo.",
                    },
                    options=opt(("a", "humildes"), ("b", "mansos"), ("c", "choram")),
                    correct="b",
                    template="Bem-aventurados os ___, porque eles herdarão a terra",
                ),
            ),
            (
                "caminhada",
                "choice",
                "03",
                dict(
                    question="Como as primeiras bem-aventuranças se encadeiam no bloco?",
                    fc="Certo: cada grupo recebe uma promessa distinta do reino.",
                    fw={
                        "a": "Há quatro bem-aventuranças, não uma só.",
                        "c": "As promessas diferem: reino, consolo, terra, fartura.",
                        "d": "O texto não anula as promessas.",
                    },
                    options=opt(
                        ("a", "Só os humildes importam; o resto é repetição vazia"),
                        ("b", "Cada grupo recebe uma promessa distinta do reino"),
                        ("c", "Todas as promessas são idênticas palavra por palavra"),
                        ("d", "O bloco cancela as promessas ao final"),
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
                    fc="Certo: reino, consolo, terra e fartura nessa ordem.",
                    fw={
                        "b": "Consolo vem após o reino dos humildes.",
                        "c": "Fartura fecha o bloco da fome de justiça.",
                    },
                    options=opt(
                        ("a", "deles é o reino dos céus"),
                        ("b", "eles serão consolados"),
                        ("c", "herdarão a terra; serão fartos"),
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
                    question='Complete: "Bem-aventurados os humildes de espírito, porque deles é o ___ dos céus"',
                    fc="Certo: o reino dos céus.",
                    fw={
                        "b": "Terra é dos mansos.",
                        "c": "Justiça é o objeto da fome.",
                    },
                    options=opt(("a", "reino"), ("b", "terra"), ("c", "justiça")),
                    correct="a",
                    template="Bem-aventurados os humildes de espírito, porque deles é o ___ dos céus",
                ),
            ),
            (
                "caminhada",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:3–6 comunica que se liga a este contexto?",
                    fc="Certo: o caráter inicial do povo do reino.",
                    fw={
                        "a": "Não é código civil; são bem-aventuranças do reino.",
                        "c": "Há promessas claras em cada linha.",
                    },
                    options=opt(
                        ("a", "Regras só civis sem Deus"),
                        ("b", "Caráter do povo do reino"),
                        ("c", "Promessas vazias"),
                    ),
                    correct="b",
                    pa_text="Bem-aventurados os humildes… serão fartos.",
                ),
            ),
            (
                "profundezas",
                "true_false",
                "01",
                dict(
                    question="As bem-aventuranças de Mateus 5:3–6 revelam o perfil e as promessas do reino.",
                    fc="Certo: perfil e promessas abrem o sermão do Rei.",
                    fw={"false": "O bloco define quem é bem-aventurado e o que recebe."},
                    options=TF,
                    correct="true",
                ),
            ),
            (
                "profundezas",
                "tap",
                "02",
                dict(
                    question='Em Mateus 5:3–6, toque a palavra que falta em "Bem-aventurados os que têm fome e sede de ___"?',
                    fc="Exato: fome e sede de justiça.",
                    fw={
                        "a": "Espírito qualifica os humildes no v.3.",
                        "c": "Terra é a herança dos mansos.",
                    },
                    options=opt(("a", "espírito"), ("b", "justiça"), ("c", "terra")),
                    correct="b",
                    template="Bem-aventurados os que têm fome e sede de ___",
                ),
            ),
            (
                "profundezas",
                "choice",
                "03",
                dict(
                    question="Qual leitura teológica melhor resume Mateus 5:3–6?",
                    fc="Certo: o reino abençoa humildes, sofredores, mansos e sedentos de justiça.",
                    fw={
                        "a": "O bloco não exalta autossuficiência.",
                        "b": "Há quatro bem-aventuranças com promessas.",
                        "d": "As promessas são centrais, não opcionais.",
                    },
                    options=opt(
                        ("a", "O reino exalta só os autossuficientes e poderosos"),
                        ("b", "As bem-aventuranças são meras frases sem conteúdo"),
                        ("c", "O reino abençoa humildes, sofredores, mansos e sedentos de justiça"),
                        ("d", "As promessas do bloco podem ser ignoradas sem perda"),
                    ),
                    correct="c",
                ),
            ),
            (
                "profundezas",
                "order",
                "04",
                dict(
                    question="Qual sequência revela o sentido de Mateus 5:3–6?",
                    fc="Certo: humildade, pranto, mansidão e fome de justiça.",
                    fw={
                        "b": "O pranto segue a humildade de espírito.",
                        "c": "A fome de justiça fecha o primeiro bloco.",
                    },
                    options=opt(
                        ("a", "humildes de espírito — reino dos céus"),
                        ("b", "os que choram — serão consolados"),
                        ("c", "mansos e famintos de justiça — terra e fartura"),
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
                    question='Complete: "Bem-aventurados os que choram, porque eles serão ___"',
                    fc="Certo: serão consolados.",
                    fw={
                        "b": "Fartos é da fome de justiça.",
                        "c": "Reino é dos humildes.",
                    },
                    options=opt(("a", "consolados"), ("b", "fartos"), ("c", "reino")),
                    correct="a",
                    template="Bem-aventurados os que choram, porque eles serão ___",
                ),
            ),
            (
                "profundezas",
                "connect",
                "06",
                dict(
                    question="O que Mateus 5:3–6 comunica que se liga a este contexto?",
                    fc="Certo: bem-aventuranças do reino.",
                    fw={
                        "a": "Não é lista de castigos.",
                        "b": "Não é só ética sem Deus.",
                    },
                    options=opt(
                        ("a", "Lista de castigos"),
                        ("b", "Ética sem promessa"),
                        ("c", "Bem-aventuranças do reino"),
                    ),
                    correct="c",
                    pa_text="Bem-aventurados os humildes… serão fartos.",
                ),
            ),
        ],
    )


def mission_06():
    return mission_beatitude(
        "sm-06-misericordiosos",
        "Mateus 5:7",
        ["Mateus 5:7"],
        "Reconhecer que os misericordiosos alcançarão misericórdia.",
        "Alcançarão misericórdia.",
        P06,
        sem_tf_q="Bem-aventurados os misericordiosos, porque eles alcançarão misericórdia.",
        sem_tf_ans="true",
        sem_tap_gap="Bem-aventurados os ___, porque eles alcançarão misericórdia",
        sem_tap_correct="a",
        sem_tap_opts=[("a", "misericordiosos"), ("b", "alcançarão"), ("c", "eles")],
        sem_choice_q="O que o texto promete aos misericordiosos?",
        sem_choice_opts=[
            ("a", "Eles alcançarão misericórdia"),
            ("b", "Eles verão a Deus"),
            ("c", "Eles herdarão a terra"),
            ("d", "Eles serão fartos"),
        ],
        sem_choice_correct="a",
        sem_order=[
            ("a", "Bem-aventurados os misericordiosos"),
            ("b", "porque eles alcançarão"),
            ("c", "misericórdia"),
        ],
        sem_complete_gap="Bem-aventurados os misericordiosos, porque eles alcançarão ___",
        sem_complete_correct="b",
        sem_complete_opts=[("a", "misericordiosos"), ("b", "misericórdia"), ("c", "eles")],
        sem_bridge=[
            ("a", "Alcançarão misericórdia"),
            ("b", "Misericórdia negada"),
            ("c", "Sem qualquer retorno"),
        ],
        cam_tf_q="O texto promete misericórdia aos cruéis, não aos misericordiosos.",
        cam_tf_ans="false",
        cam_tap_gap="Bem-aventurados os misericordiosos, porque eles ___ misericórdia",
        cam_tap_correct="c",
        cam_tap_opts=[("a", "misericordiosos"), ("b", "misericórdia"), ("c", "alcançarão")],
        cam_choice_q="Como misericórdia dada e recebida se relacionam no versículo?",
        cam_choice_opts=[
            ("a", "Praticar misericórdia não tem qualquer relação com recebê-la"),
            ("b", "Quem exerce misericórdia alcançará misericórdia"),
            ("c", "Só quem nunca perdoa pode ser bem-aventurado"),
            ("d", "O texto elogia a dureza como caminho do reino"),
        ],
        cam_choice_correct="b",
        cam_order=[
            ("a", "Bem-aventurados os misericordiosos"),
            ("b", "porque eles alcançarão"),
            ("c", "misericórdia"),
        ],
        cam_complete_gap="___ os misericordiosos, porque eles alcançarão misericórdia",
        cam_complete_correct="a",
        cam_complete_opts=[("a", "Bem-aventurados"), ("b", "misericórdia"), ("c", "eles")],
        cam_bridge=[
            ("a", "Crueldade é bem-aventurança"),
            ("b", "Alcançarão misericórdia"),
            ("c", "Sem misericórdia alguma"),
        ],
        pro_tf_q="A bem-aventurança une a prática da misericórdia à promessa de recebê-la.",
        pro_tf_ans="true",
        pro_tap_gap="Bem-aventurados os misericordiosos, porque ___ alcançarão misericórdia",
        pro_tap_correct="b",
        pro_tap_opts=[("a", "misericórdia"), ("b", "eles"), ("c", "Bem-aventurados")],
        pro_choice_q="Qual sentido teológico Mateus 5:7 sustenta?",
        pro_choice_opts=[
            ("a", "Misericórdia é fraqueza que o reino despreza"),
            ("b", "Deus promete misericórdia a quem a pratica"),
            ("c", "O reino premia só a vingança justa"),
            ("d", "Misericórdia humana não tem eco na promessa divina"),
        ],
        pro_choice_correct="b",
        pro_order=[
            ("a", "Bem-aventurados os misericordiosos"),
            ("b", "porque eles alcançarão"),
            ("c", "misericórdia"),
        ],
        pro_complete_gap="Bem-aventurados os misericordiosos, porque eles alcançarão ___",
        pro_complete_correct="c",
        pro_complete_opts=[("a", "eles"), ("b", "misericordiosos"), ("c", "misericórdia")],
        pro_bridge=[
            ("a", "Vingança no reino"),
            ("b", "Dureza sem fim"),
            ("c", "Alcançarão misericórdia"),
        ],
        fw_notes={
            "sem_tf_fc": "Certo: é a afirmação literal do versículo.",
            "sem_tf_fw": "O texto promete misericórdia aos misericordiosos.",
            "sem_tap_fc": "Exato: os misericordiosos.",
            "sem_tap_fw": {
                "b": "Alcançarão é o verbo da promessa.",
                "c": "Eles é o sujeito da promessa.",
            },
            "sem_choice_fc": "Certo: alcançarão misericórdia.",
            "sem_choice_fw": {
                "b": "Ver a Deus é dos limpos de coração.",
                "c": "Herdar a terra é dos mansos.",
                "d": "Ser fartos é de quem tem fome de justiça.",
            },
            "sem_order_fc": "Certo: bem-aventurança, motivo e misericórdia.",
            "sem_order_fw_b": "O motivo vem após a declaração.",
            "sem_order_fw_c": "Misericórdia fecha a promessa.",
            "sem_complete_fc": "Certo: alcançarão misericórdia.",
            "sem_complete_fw": {
                "a": "Misericordiosos é o sujeito.",
                "c": "Eles é o pronome.",
            },
            "sem_connect_fc": "Certo: alcançarão misericórdia.",
            "sem_connect_fw_b": "A misericórdia é prometida, não negada.",
            "sem_connect_fw_c": "Há retorno prometido à misericórdia.",
            "cam_tf_fc": "Certo que é falso: a promessa é aos misericordiosos.",
            "cam_tf_fw": "O texto não promete misericórdia aos cruéis.",
            "cam_tap_fc": "Exato: alcançarão misericórdia.",
            "cam_tap_fw": {
                "a": "Misericordiosos é o sujeito.",
                "b": "Misericórdia é o objeto.",
            },
            "cam_choice_fc": "Certo: quem exerce misericórdia a alcançará.",
            "cam_choice_fw": {
                "a": "O texto liga prática e promessa.",
                "c": "O perdão e a misericórdia são o caminho.",
                "d": "A dureza não é a bem-aventurança.",
            },
            "cam_order_fc": "Certo: declaração, motivo e misericórdia.",
            "cam_order_fw_b": "O motivo explica a bem-aventurança.",
            "cam_order_fw_c": "Misericórdia é o fim.",
            "cam_complete_fc": "Certo: Bem-aventurados abre a frase.",
            "cam_complete_fw": {
                "b": "Misericórdia é a promessa.",
                "c": "Eles é o sujeito da promessa.",
            },
            "cam_connect_fc": "Certo: alcançarão misericórdia.",
            "cam_connect_fw_a": "Crueldade não é bem-aventurança.",
            "cam_connect_fw_c": "Há misericórdia prometida.",
            "pro_tf_fc": "Certo: prática e promessa se unem.",
            "pro_tf_fw": "O porque liga misericordiosos e misericórdia.",
            "pro_tap_fc": "Exato: eles alcançarão.",
            "pro_tap_fw": {
                "a": "Misericórdia é o objeto.",
                "c": "Bem-aventurados abre a frase.",
            },
            "pro_choice_fc": "Certo: Deus promete misericórdia a quem a pratica.",
            "pro_choice_fw": {
                "a": "Misericórdia é bem-aventurança, não desprezo.",
                "c": "O texto não premia a vingança.",
                "d": "Há eco claro na promessa divina.",
            },
            "pro_order_fc": "Certo: bem-aventurança, motivo e misericórdia.",
            "pro_order_fw_b": "O motivo liga prática e promessa.",
            "pro_order_fw_c": "Misericórdia conclui o sentido.",
            "pro_complete_fc": "Certo: alcançarão misericórdia.",
            "pro_complete_fw": {
                "a": "Eles é o sujeito.",
                "b": "Misericordiosos é quem é bem-aventurado.",
            },
            "pro_connect_fc": "Certo: alcançarão misericórdia.",
            "pro_connect_fw_a": "O reino não exalta a vingança aqui.",
            "pro_connect_fw_b": "A dureza não é o fim do texto.",
        },
    )


def mission_07():
    return mission_beatitude(
        "sm-07-limpos-de-coracao",
        "Mateus 5:8",
        ["Mateus 5:8"],
        "Reconhecer que os limpos de coração verão a Deus.",
        "Verão a Deus.",
        P07,
        sem_tf_q="Bem-aventurados os limpos de coração, porque eles verão a Deus.",
        sem_tf_ans="true",
        sem_tap_gap="Bem-aventurados os limpos de ___, porque eles verão a Deus",
        sem_tap_correct="a",
        sem_tap_opts=[("a", "coração"), ("b", "Deus"), ("c", "verão")],
        sem_choice_q="O que o texto promete aos limpos de coração?",
        sem_choice_opts=[
            ("a", "Eles verão a Deus"),
            ("b", "Eles alcançarão misericórdia"),
            ("c", "Eles serão chamados filhos de Deus"),
            ("d", "Deles é o reino dos céus"),
        ],
        sem_choice_correct="a",
        sem_order=[
            ("a", "Bem-aventurados os limpos de coração"),
            ("b", "porque eles verão"),
            ("c", "a Deus"),
        ],
        sem_complete_gap="Bem-aventurados os limpos de coração, porque eles verão a ___",
        sem_complete_correct="b",
        sem_complete_opts=[("a", "coração"), ("b", "Deus"), ("c", "limpos")],
        sem_bridge=[
            ("a", "Verão a Deus"),
            ("b", "Coração limpo sem Deus"),
            ("c", "Visão negada"),
        ],
        cam_tf_q="O texto promete que os limpos de coração jamais verão a Deus.",
        cam_tf_ans="false",
        cam_tap_gap="Bem-aventurados os ___ de coração, porque eles verão a Deus",
        cam_tap_correct="c",
        cam_tap_opts=[("a", "coração"), ("b", "Deus"), ("c", "limpos")],
        cam_choice_q="Como pureza de coração e visão de Deus se relacionam?",
        cam_choice_opts=[
            ("a", "A pureza de coração é irrelevante para ver a Deus"),
            ("b", "Quem tem coração limpo verá a Deus"),
            ("c", "Só aparência externa garante a visão de Deus"),
            ("d", "O texto separa coração e qualquer promessa"),
        ],
        cam_choice_correct="b",
        cam_order=[
            ("a", "Bem-aventurados os limpos de coração"),
            ("b", "porque eles verão"),
            ("c", "a Deus"),
        ],
        cam_complete_gap="Bem-aventurados os limpos de coração, porque eles ___ a Deus",
        cam_complete_correct="a",
        cam_complete_opts=[("a", "verão"), ("b", "coração"), ("c", "limpos")],
        cam_bridge=[
            ("a", "Impureza vê a Deus"),
            ("b", "Verão a Deus"),
            ("c", "Sem visão alguma"),
        ],
        pro_tf_q="A bem-aventurança une pureza de coração à promessa de ver a Deus.",
        pro_tf_ans="true",
        pro_tap_gap="Bem-aventurados os limpos de coração, porque ___ verão a Deus",
        pro_tap_correct="b",
        pro_tap_opts=[("a", "Deus"), ("b", "eles"), ("c", "coração")],
        pro_choice_q="Qual sentido teológico Mateus 5:8 sustenta?",
        pro_choice_opts=[
            ("a", "Ver a Deus depende só de títulos religiosos externos"),
            ("b", "O coração pode permanecer impuro sem prejuízo algum"),
            ("c", "A pureza interior prepara o discípulo para ver a Deus"),
            ("d", "Deus permanece invisível mesmo aos limpos de coração"),
        ],
        pro_choice_correct="c",
        pro_order=[
            ("a", "Bem-aventurados os limpos de coração"),
            ("b", "porque eles verão"),
            ("c", "a Deus"),
        ],
        pro_complete_gap="___ os limpos de coração, porque eles verão a Deus",
        pro_complete_correct="c",
        pro_complete_opts=[("a", "Deus"), ("b", "coração"), ("c", "Bem-aventurados")],
        pro_bridge=[
            ("a", "Só ritual externo"),
            ("b", "Deus inacessível"),
            ("c", "Verão a Deus"),
        ],
        fw_notes={
            "sem_tf_fc": "Certo: é a afirmação literal do versículo.",
            "sem_tf_fw": "O texto promete que verão a Deus.",
            "sem_tap_fc": "Exato: limpos de coração.",
            "sem_tap_fw": {
                "b": "Deus é quem será visto.",
                "c": "Verão é o verbo da promessa.",
            },
            "sem_choice_fc": "Certo: verão a Deus.",
            "sem_choice_fw": {
                "b": "Misericórdia é dos misericordiosos.",
                "c": "Filhos de Deus é dos pacificadores.",
                "d": "O reino é dos humildes / perseguidos.",
            },
            "sem_order_fc": "Certo: bem-aventurança, motivo e Deus.",
            "sem_order_fw_b": "O motivo vem após a declaração.",
            "sem_order_fw_c": "A Deus fecha a promessa.",
            "sem_complete_fc": "Certo: verão a Deus.",
            "sem_complete_fw": {
                "a": "Coração qualifica os limpos.",
                "c": "Limpos é o sujeito.",
            },
            "sem_connect_fc": "Certo: verão a Deus.",
            "sem_connect_fw_b": "O texto une coração limpo e Deus.",
            "sem_connect_fw_c": "A visão é prometida, não negada.",
            "cam_tf_fc": "Certo que é falso: eles verão a Deus.",
            "cam_tf_fw": "O texto afirma a visão de Deus.",
            "cam_tap_fc": "Exato: os limpos.",
            "cam_tap_fw": {
                "a": "Coração qualifica os limpos.",
                "b": "Deus é o objeto da visão.",
            },
            "cam_choice_fc": "Certo: coração limpo verá a Deus.",
            "cam_choice_fw": {
                "a": "A pureza é central na promessa.",
                "c": "O texto fala de coração, não só aparência.",
                "d": "Há promessa clara.",
            },
            "cam_order_fc": "Certo: declaração, motivo e visão.",
            "cam_order_fw_b": "O motivo explica a bem-aventurança.",
            "cam_order_fw_c": "A Deus é o fim.",
            "cam_complete_fc": "Certo: verão a Deus.",
            "cam_complete_fw": {
                "b": "Coração qualifica os limpos.",
                "c": "Limpos é o sujeito.",
            },
            "cam_connect_fc": "Certo: verão a Deus.",
            "cam_connect_fw_a": "Impureza não é o caminho do texto.",
            "cam_connect_fw_c": "Há visão prometida.",
            "pro_tf_fc": "Certo: pureza e visão se unem.",
            "pro_tf_fw": "O porque liga coração limpo e ver a Deus.",
            "pro_tap_fc": "Exato: eles verão.",
            "pro_tap_fw": {
                "a": "Deus é o objeto.",
                "c": "Coração qualifica os limpos.",
            },
            "pro_choice_fc": "Certo: pureza interior prepara para ver a Deus.",
            "pro_choice_fw": {
                "a": "O texto fala de coração, não só de títulos.",
                "b": "O coração limpo é essencial.",
                "d": "A promessa é ver a Deus.",
            },
            "pro_order_fc": "Certo: bem-aventurança, motivo e Deus.",
            "pro_order_fw_b": "O motivo liga pureza e visão.",
            "pro_order_fw_c": "A Deus conclui o sentido.",
            "pro_complete_fc": "Certo: Bem-aventurados abre a frase.",
            "pro_complete_fw": {
                "a": "Deus é o objeto da visão.",
                "b": "Coração qualifica os limpos.",
            },
            "pro_connect_fc": "Certo: verão a Deus.",
            "pro_connect_fw_a": "Não é só ritual externo.",
            "pro_connect_fw_b": "Deus não fica inacessível aos limpos.",
        },
    )


def mission_08():
    return mission_beatitude(
        "sm-08-pacificadores",
        "Mateus 5:9",
        ["Mateus 5:9"],
        "Reconhecer que os pacificadores serão chamados filhos de Deus.",
        "Serão chamados filhos de Deus.",
        P08,
        sem_tf_q="Bem-aventurados os pacificadores, porque eles serão chamados filhos de Deus.",
        sem_tf_ans="true",
        sem_tap_gap="Bem-aventurados os ___, porque eles serão chamados filhos de Deus",
        sem_tap_correct="a",
        sem_tap_opts=[("a", "pacificadores"), ("b", "filhos"), ("c", "Deus")],
        sem_choice_q="O que o texto promete aos pacificadores?",
        sem_choice_opts=[
            ("a", "Eles serão chamados filhos de Deus"),
            ("b", "Eles verão a Deus"),
            ("c", "Eles alcançarão misericórdia"),
            ("d", "Eles serão consolados"),
        ],
        sem_choice_correct="a",
        sem_order=[
            ("a", "Bem-aventurados os pacificadores"),
            ("b", "porque eles serão chamados"),
            ("c", "filhos de Deus"),
        ],
        sem_complete_gap="Bem-aventurados os pacificadores, porque eles serão chamados ___ de Deus",
        sem_complete_correct="b",
        sem_complete_opts=[("a", "pacificadores"), ("b", "filhos"), ("c", "chamados")],
        sem_bridge=[
            ("a", "Filhos de Deus"),
            ("b", "Paz sem identidade"),
            ("c", "Filiação negada"),
        ],
        cam_tf_q="O texto chama bem-aventurados os fomentadores de discórdia, não os pacificadores.",
        cam_tf_ans="false",
        cam_tap_gap="Bem-aventurados os pacificadores, porque eles serão chamados filhos de ___",
        cam_tap_correct="c",
        cam_tap_opts=[("a", "pacificadores"), ("b", "filhos"), ("c", "Deus")],
        cam_choice_q="Como a paz e a filiação divina se relacionam no versículo?",
        cam_choice_opts=[
            ("a", "Fazer a paz não tem ligação com ser chamado filho de Deus"),
            ("b", "Os pacificadores serão chamados filhos de Deus"),
            ("c", "Só quem promove brigas recebe o título de filho"),
            ("d", "O texto separa paz de qualquer identidade no reino"),
        ],
        cam_choice_correct="b",
        cam_order=[
            ("a", "Bem-aventurados os pacificadores"),
            ("b", "porque eles serão chamados"),
            ("c", "filhos de Deus"),
        ],
        cam_complete_gap="Bem-aventurados os pacificadores, porque eles serão ___ filhos de Deus",
        cam_complete_correct="a",
        cam_complete_opts=[("a", "chamados"), ("b", "pacificadores"), ("c", "Deus")],
        cam_bridge=[
            ("a", "Discórdia é bem-aventurança"),
            ("b", "Filhos de Deus"),
            ("c", "Sem filiação"),
        ],
        pro_tf_q="A bem-aventurança une a obra de paz à identidade de filhos de Deus.",
        pro_tf_ans="true",
        pro_tap_gap="Bem-aventurados os pacificadores, porque ___ serão chamados filhos de Deus",
        pro_tap_correct="b",
        pro_tap_opts=[("a", "filhos"), ("b", "eles"), ("c", "Deus")],
        pro_choice_q="Qual sentido teológico Mateus 5:9 sustenta?",
        pro_choice_opts=[
            ("a", "O reino valoriza a discórdia como sinal de fidelidade"),
            ("b", "Pacificadores revelam o caráter do Pai e são chamados filhos"),
            ("c", "Filiação divina independe de qualquer prática de paz"),
            ("d", "Fazer a paz é opcional e sem peso no reino"),
        ],
        pro_choice_correct="b",
        pro_order=[
            ("a", "Bem-aventurados os pacificadores"),
            ("b", "porque eles serão chamados"),
            ("c", "filhos de Deus"),
        ],
        pro_complete_gap="___ os pacificadores, porque eles serão chamados filhos de Deus",
        pro_complete_correct="c",
        pro_complete_opts=[("a", "filhos"), ("b", "Deus"), ("c", "Bem-aventurados")],
        pro_bridge=[
            ("a", "Guerra como ideal"),
            ("b", "Sem filiação"),
            ("c", "Filhos de Deus"),
        ],
        fw_notes={
            "sem_tf_fc": "Certo: é a afirmação literal do versículo.",
            "sem_tf_fw": "O texto promete o título de filhos de Deus.",
            "sem_tap_fc": "Exato: os pacificadores.",
            "sem_tap_fw": {
                "b": "Filhos é o título prometido.",
                "c": "Deus fecha a filiação.",
            },
            "sem_choice_fc": "Certo: serão chamados filhos de Deus.",
            "sem_choice_fw": {
                "b": "Ver a Deus é dos limpos de coração.",
                "c": "Misericórdia é dos misericordiosos.",
                "d": "Consolo é dos que choram.",
            },
            "sem_order_fc": "Certo: bem-aventurança, motivo e filiação.",
            "sem_order_fw_b": "O motivo vem após a declaração.",
            "sem_order_fw_c": "Filhos de Deus fecha a promessa.",
            "sem_complete_fc": "Certo: filhos de Deus.",
            "sem_complete_fw": {
                "a": "Pacificadores é o sujeito.",
                "c": "Chamados é o verbo.",
            },
            "sem_connect_fc": "Certo: serão chamados filhos de Deus.",
            "sem_connect_fw_b": "A paz traz identidade no texto.",
            "sem_connect_fw_c": "A filiação é prometida, não negada.",
            "cam_tf_fc": "Certo que é falso: são os pacificadores.",
            "cam_tf_fw": "O texto elogia pacificadores, não discórdia.",
            "cam_tap_fc": "Exato: filhos de Deus.",
            "cam_tap_fw": {
                "a": "Pacificadores é o sujeito.",
                "b": "Filhos é o título.",
            },
            "cam_choice_fc": "Certo: pacificadores serão chamados filhos.",
            "cam_choice_fw": {
                "a": "O texto liga paz e filiação.",
                "c": "Brigar não é o caminho do versículo.",
                "d": "Há identidade clara no reino.",
            },
            "cam_order_fc": "Certo: declaração, motivo e filiação.",
            "cam_order_fw_b": "O motivo explica a bem-aventurança.",
            "cam_order_fw_c": "Filhos de Deus é o fim.",
            "cam_complete_fc": "Certo: serão chamados.",
            "cam_complete_fw": {
                "b": "Pacificadores é o sujeito.",
                "c": "Deus fecha a filiação.",
            },
            "cam_connect_fc": "Certo: filhos de Deus.",
            "cam_connect_fw_a": "Discórdia não é bem-aventurança.",
            "cam_connect_fw_c": "Há filiação prometida.",
            "pro_tf_fc": "Certo: paz e filiação se unem.",
            "pro_tf_fw": "O porque liga pacificadores e filhos de Deus.",
            "pro_tap_fc": "Exato: eles serão chamados.",
            "pro_tap_fw": {
                "a": "Filhos é o título.",
                "c": "Deus fecha a frase.",
            },
            "pro_choice_fc": "Certo: pacificadores revelam o Pai e são filhos.",
            "pro_choice_fw": {
                "a": "O reino não valoriza a discórdia aqui.",
                "c": "A prática de paz está ligada à filiação.",
                "d": "Fazer a paz tem peso no texto.",
            },
            "pro_order_fc": "Certo: bem-aventurança, motivo e filiação.",
            "pro_order_fw_b": "O motivo liga paz e filiação.",
            "pro_order_fw_c": "Filhos de Deus conclui o sentido.",
            "pro_complete_fc": "Certo: Bem-aventurados abre a frase.",
            "pro_complete_fw": {
                "a": "Filhos é o título.",
                "b": "Deus fecha a filiação.",
            },
            "pro_connect_fc": "Certo: filhos de Deus.",
            "pro_connect_fw_a": "Guerra não é o ideal do versículo.",
            "pro_connect_fw_b": "Há filiação prometida.",
        },
    )


def mission_09():
    return mission_beatitude(
        "sm-09-perseguidos",
        "Mateus 5:10",
        ["Mateus 5:10"],
        "Reconhecer que dos perseguidos por causa da justiça é o reino dos céus.",
        "Deles é o reino dos céus.",
        P09,
        sem_tf_q="Bem-aventurados os que têm sido perseguidos por causa da justiça, porque deles é o reino dos céus.",
        sem_tf_ans="true",
        sem_tap_gap="Bem-aventurados os que têm sido perseguidos por causa da ___, porque deles é o reino dos céus",
        sem_tap_correct="a",
        sem_tap_opts=[("a", "justiça"), ("b", "reino"), ("c", "céus")],
        sem_choice_q="O que o texto afirma sobre os perseguidos por causa da justiça?",
        sem_choice_opts=[
            ("a", "Deles é o reino dos céus"),
            ("b", "Eles herdarão a terra"),
            ("c", "Eles serão consolados"),
            ("d", "Eles verão a Deus"),
        ],
        sem_choice_correct="a",
        sem_order=[
            ("a", "Bem-aventurados os que têm sido perseguidos por causa da justiça"),
            ("b", "porque deles é"),
            ("c", "o reino dos céus"),
        ],
        sem_complete_gap="Bem-aventurados os que têm sido perseguidos por causa da justiça, porque deles é o ___ dos céus",
        sem_complete_correct="b",
        sem_complete_opts=[("a", "justiça"), ("b", "reino"), ("c", "perseguidos")],
        sem_bridge=[
            ("a", "Deles é o reino"),
            ("b", "Perseguição sem sentido"),
            ("c", "Reino negado"),
        ],
        cam_tf_q="O texto promete o reino aos perseguidos por injustiça, não por causa da justiça.",
        cam_tf_ans="false",
        cam_tap_gap="Bem-aventurados os que têm sido ___, por causa da justiça, porque deles é o reino dos céus",
        cam_tap_correct="c",
        cam_tap_opts=[("a", "justiça"), ("b", "reino"), ("c", "perseguidos")],
        cam_choice_q="Como perseguição por justiça e reino se relacionam?",
        cam_choice_opts=[
            ("a", "A perseguição anula qualquer participação no reino"),
            ("b", "Quem sofre por causa da justiça recebe o reino"),
            ("c", "Só quem evita a justiça permanece no reino"),
            ("d", "O texto trata a perseguição como prova de abandono divino"),
        ],
        cam_choice_correct="b",
        cam_order=[
            ("a", "Bem-aventurados os que têm sido perseguidos por causa da justiça"),
            ("b", "porque deles é"),
            ("c", "o reino dos céus"),
        ],
        cam_complete_gap="Bem-aventurados os que têm sido perseguidos por causa da justiça, porque deles é o reino dos ___",
        cam_complete_correct="a",
        cam_complete_opts=[("a", "céus"), ("b", "justiça"), ("c", "perseguidos")],
        cam_bridge=[
            ("a", "Perseguição prova abandono"),
            ("b", "Deles é o reino"),
            ("c", "Sem reino algum"),
        ],
        pro_tf_q="A bem-aventurança une sofrer por justiça à posse do reino dos céus.",
        pro_tf_ans="true",
        pro_tap_gap="Bem-aventurados os que têm sido perseguidos por causa da justiça, porque ___ é o reino dos céus",
        pro_tap_correct="b",
        pro_tap_opts=[("a", "justiça"), ("b", "deles"), ("c", "céus")],
        pro_choice_q="Qual sentido teológico Mateus 5:10 sustenta?",
        pro_choice_opts=[
            ("a", "Perseguição por justiça prova que o reino foi perdido"),
            ("b", "O reino pertence a quem sofre por causa da justiça"),
            ("c", "Evitar a justiça é o caminho mais seguro do reino"),
            ("d", "O texto separa perseguição de qualquer esperança"),
        ],
        pro_choice_correct="b",
        pro_order=[
            ("a", "Bem-aventurados os que têm sido perseguidos por causa da justiça"),
            ("b", "porque deles é"),
            ("c", "o reino dos céus"),
        ],
        pro_complete_gap="___ os que têm sido perseguidos por causa da justiça, porque deles é o reino dos céus",
        pro_complete_correct="c",
        pro_complete_opts=[("a", "reino"), ("b", "justiça"), ("c", "Bem-aventurados")],
        pro_bridge=[
            ("a", "Abandono divino"),
            ("b", "Justiça sem reino"),
            ("c", "Deles é o reino"),
        ],
        fw_notes={
            "sem_tf_fc": "Certo: é a afirmação literal do versículo.",
            "sem_tf_fw": "O texto liga perseguição por justiça ao reino.",
            "sem_tap_fc": "Exato: por causa da justiça.",
            "sem_tap_fw": {
                "b": "Reino é a promessa.",
                "c": "Céus fecha a frase.",
            },
            "sem_choice_fc": "Certo: deles é o reino dos céus.",
            "sem_choice_fw": {
                "b": "Herdar a terra é dos mansos.",
                "c": "Consolo é dos que choram.",
                "d": "Ver a Deus é dos limpos de coração.",
            },
            "sem_order_fc": "Certo: bem-aventurança, motivo e reino.",
            "sem_order_fw_b": "O motivo vem após a declaração.",
            "sem_order_fw_c": "O reino dos céus fecha a promessa.",
            "sem_complete_fc": "Certo: o reino dos céus.",
            "sem_complete_fw": {
                "a": "Justiça é a causa da perseguição.",
                "c": "Perseguidos é o sujeito.",
            },
            "sem_connect_fc": "Certo: deles é o reino.",
            "sem_connect_fw_b": "A perseguição tem sentido no reino.",
            "sem_connect_fw_c": "O reino é prometido, não negado.",
            "cam_tf_fc": "Certo que é falso: é por causa da justiça.",
            "cam_tf_fw": "O texto especifica perseguição por causa da justiça.",
            "cam_tap_fc": "Exato: perseguidos.",
            "cam_tap_fw": {
                "a": "Justiça é a causa.",
                "b": "Reino é a promessa.",
            },
            "cam_choice_fc": "Certo: sofrer por justiça recebe o reino.",
            "cam_choice_fw": {
                "a": "A perseguição não anula o reino; o confirma.",
                "c": "Evitar a justiça não é o caminho do texto.",
                "d": "Há esperança: o reino dos céus.",
            },
            "cam_order_fc": "Certo: declaração, motivo e reino.",
            "cam_order_fw_b": "O motivo explica a bem-aventurança.",
            "cam_order_fw_c": "O reino é o fim.",
            "cam_complete_fc": "Certo: reino dos céus.",
            "cam_complete_fw": {
                "b": "Justiça é a causa.",
                "c": "Perseguidos é o sujeito.",
            },
            "cam_connect_fc": "Certo: deles é o reino.",
            "cam_connect_fw_a": "A perseguição não prova abandono.",
            "cam_connect_fw_c": "Há reino prometido.",
            "pro_tf_fc": "Certo: sofrer por justiça e reino se unem.",
            "pro_tf_fw": "O porque liga perseguição e reino.",
            "pro_tap_fc": "Exato: deles é o reino.",
            "pro_tap_fw": {
                "a": "Justiça é a causa.",
                "c": "Céus fecha a frase.",
            },
            "pro_choice_fc": "Certo: o reino pertence a quem sofre por justiça.",
            "pro_choice_fw": {
                "a": "A perseguição não prova perda do reino.",
                "c": "Evitar a justiça não é o ideal do texto.",
                "d": "Há esperança clara: o reino.",
            },
            "pro_order_fc": "Certo: bem-aventurança, motivo e reino.",
            "pro_order_fw_b": "O motivo liga perseguição e reino.",
            "pro_order_fw_c": "O reino conclui o sentido.",
            "pro_complete_fc": "Certo: Bem-aventurados abre a frase.",
            "pro_complete_fw": {
                "a": "Reino é a promessa.",
                "b": "Justiça é a causa.",
            },
            "pro_connect_fc": "Certo: deles é o reino.",
            "pro_connect_fw_a": "Não é abandono divino.",
            "pro_connect_fw_b": "Justiça e reino andam juntos.",
        },
    )


def main():
    # First 10 pack missions: sm-01..sm-09 (through sm-09; boss-02 = part B).
    # User label "through sm-boss-02" marks the beatitudes block end; count is 10×18.
    questions = []
    questions += mission_01()
    questions += mission_02()
    questions += mission_03()
    questions += mission_04()
    questions += mission_05()
    questions += mission_boss_01()
    questions += mission_06()
    questions += mission_07()
    questions += mission_08()
    questions += mission_09()
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
