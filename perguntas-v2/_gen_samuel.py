#!/usr/bin/env python3
"""Gera perguntas-v2/samuel.json (126 itens, 7 missões). Trail samuel."""
import json
from pathlib import Path

TF = [
    {"id": "true", "text": "Verdadeiro"},
    {"id": "false", "text": "Falso"},
]


def qtext(s):
    return {"question": s, "prompt": s, "cue": s}


def pack(trail, section, short, nn, difficulty, skill, verse_ref, lo, evidence, passage, **kw):
    q = {
        "difficulty": difficulty,
        "skill": skill,
        "verseRef": verse_ref,
        "learningObjective": lo,
        "evidence": evidence,
        "trail": trail,
        "section": section,
        "id": f"{trail}-{short}-{section}-{nn}",
        "passageText": passage,
    }
    q.update(kw)
    return q


def mission(
    trail,
    section,
    verse_ref,
    evidence,
    passage,
    lo,
    insight,
    # semente
    sem_tf,
    sem_tf_ok,
    sem_tap_blank,
    sem_tap_opts,
    sem_tap_correct,
    sem_choice_q,
    sem_choice_opts,
    sem_choice_correct,
    sem_choice_fw,
    sem_order_q,
    # caminhada
    cam_tf,
    cam_tf_ok,
    cam_tap_blank,
    cam_tap_opts,
    cam_tap_correct,
    cam_choice_q,
    cam_choice_opts,
    cam_choice_correct,
    cam_choice_fw,
    # profundezas
    pro_tf,
    pro_tf_ok,
    pro_tap_blank,
    pro_tap_opts,
    pro_tap_correct,
    pro_choice_q,
    pro_choice_opts,
    pro_choice_correct,
    pro_choice_fw,
    # complete gaps (word, distractors) per mode
    sem_complete_blank,
    sem_complete_opts,
    sem_complete_correct,
    cam_complete_blank,
    cam_complete_opts,
    cam_complete_correct,
    pro_complete_blank,
    pro_complete_opts,
    pro_complete_correct,
    # connect bridges (+ 2 distractors each)
    sem_bridge,
    sem_conn_wrong,
    cam_bridge,
    cam_conn_wrong,
    pro_bridge,
    pro_conn_wrong,
    # order pieces (same 3 fragments; stems differ by mode)
    order_a,
    order_b,
    order_c,
    # feedbacks short
    fb_sem_tf,
    fb_cam_tf,
    fb_pro_tf,
):
    out = []
    base = dict(
        trail=trail,
        section=section,
        verse_ref=verse_ref,
        lo=lo,
        evidence=evidence,
        passage=passage,
    )
    order_opts = [
        {"id": "a", "text": order_a},
        {"id": "b", "text": order_b},
        {"id": "c", "text": order_c},
    ]
    order_wrong = {
        "b": "Releia a ordem: o meio do relato não vem primeiro.",
        "c": "Releia a ordem: o fim do relato não abre a sequência.",
    }

    # ---- SEMENTE ----
    out.append(
        pack(
            **base,
            short="sem",
            nn="01",
            difficulty="semente",
            skill="observe",
            type="true_false",
            **qtext(sem_tf),
            feedbackCorrect=fb_sem_tf[0],
            feedbackWrong={("false" if sem_tf_ok == "true" else "true"): fb_sem_tf[1]},
            options=TF,
            correctOptionId=sem_tf_ok,
            correctAnswer=sem_tf_ok,
        )
    )
    out.append(
        pack(
            **base,
            short="sem",
            nn="02",
            difficulty="semente",
            skill="observe",
            type="tap",
            **qtext(f'Em {verse_ref}, toque a palavra que falta em "{sem_tap_blank}"?'),
            template=sem_tap_blank,
            feedbackCorrect="Exato: essa é a palavra do versículo.",
            feedbackWrong={
                "b": "Essa palavra não preenche esta lacuna no texto.",
                "c": "Essa palavra não preenche esta lacuna no texto.",
            },
            options=[
                {"id": "a", "text": sem_tap_opts[0]},
                {"id": "b", "text": sem_tap_opts[1]},
                {"id": "c", "text": sem_tap_opts[2]},
            ],
            correctOptionId=sem_tap_correct,
            correctAnswer=sem_tap_correct,
        )
    )
    out.append(
        pack(
            **base,
            short="sem",
            nn="03",
            difficulty="semente",
            skill="observe",
            type="choice",
            **qtext(sem_choice_q),
            feedbackCorrect="Certo: o texto afirma isso diretamente.",
            feedbackWrong=sem_choice_fw,
            options=[
                {"id": "a", "text": sem_choice_opts[0]},
                {"id": "b", "text": sem_choice_opts[1]},
                {"id": "c", "text": sem_choice_opts[2]},
                {"id": "d", "text": sem_choice_opts[3]},
            ],
            correctOptionId=sem_choice_correct,
            correctAnswer=sem_choice_correct,
        )
    )
    out.append(
        pack(
            **base,
            short="sem",
            nn="04",
            difficulty="semente",
            skill="observe",
            type="order",
            **qtext(sem_order_q),
            feedbackCorrect="Certo: essa é a sequência dos fatos no texto.",
            feedbackWrong=order_wrong,
            options=order_opts,
            correctOrder=["a", "b", "c"],
            correctOptionId="a",
            correctAnswer="a",
        )
    )
    out.append(
        pack(
            **base,
            short="sem",
            nn="05",
            difficulty="semente",
            skill="observe",
            type="complete",
            **qtext(f'Complete a frase: "{sem_complete_blank}"'),
            template=sem_complete_blank,
            feedbackCorrect="Certo: essa é a palavra que completa o versículo.",
            feedbackWrong={
                "b": "Essa opção não completa esta lacuna no texto.",
                "c": "Essa opção não completa esta lacuna no texto.",
            },
            options=[
                {"id": "a", "text": sem_complete_opts[0]},
                {"id": "b", "text": sem_complete_opts[1]},
                {"id": "c", "text": sem_complete_opts[2]},
            ],
            correctOptionId=sem_complete_correct,
            correctAnswer=sem_complete_correct,
        )
    )
    out.append(
        pack(
            **base,
            short="sem",
            nn="06",
            difficulty="semente",
            skill="observe",
            type="connect",
            **qtext(f"O que {verse_ref} comunica que se liga a este contexto?"),
            feedbackCorrect="Certo: essa é a ponte entre o texto e o insight da missão.",
            feedbackWrong={
                "b": "Essa leitura não liga o versículo ao contexto da missão.",
                "c": "Essa leitura não liga o versículo ao contexto da missão.",
            },
            passageA={"ref": verse_ref, "text": passage},
            passageB={"ref": "Contexto", "text": insight},
            options=[
                {"id": "a", "text": sem_bridge},
                {"id": "b", "text": sem_conn_wrong[0]},
                {"id": "c", "text": sem_conn_wrong[1]},
            ],
            correctOptionId="a",
            correctAnswer="a",
        )
    )

    # ---- CAMINHADA ----
    out.append(
        pack(
            **base,
            short="cam",
            nn="01",
            difficulty="caminhada",
            skill="understand",
            type="true_false",
            **qtext(cam_tf),
            feedbackCorrect=fb_cam_tf[0],
            feedbackWrong={("false" if cam_tf_ok == "true" else "true"): fb_cam_tf[1]},
            options=TF,
            correctOptionId=cam_tf_ok,
            correctAnswer=cam_tf_ok,
        )
    )
    out.append(
        pack(
            **base,
            short="cam",
            nn="02",
            difficulty="caminhada",
            skill="understand",
            type="tap",
            **qtext(f'Em {verse_ref}, toque a palavra que falta em "{cam_tap_blank}"?'),
            template=cam_tap_blank,
            feedbackCorrect="Exato: essa é a palavra-chave nesta lacuna.",
            feedbackWrong={
                "b": "Essa palavra não preenche esta lacuna no texto.",
                "c": "Essa palavra não preenche esta lacuna no texto.",
            },
            options=[
                {"id": "a", "text": cam_tap_opts[0]},
                {"id": "b", "text": cam_tap_opts[1]},
                {"id": "c", "text": cam_tap_opts[2]},
            ],
            correctOptionId=cam_tap_correct,
            correctAnswer=cam_tap_correct,
        )
    )
    out.append(
        pack(
            **base,
            short="cam",
            nn="03",
            difficulty="caminhada",
            skill="understand",
            type="choice",
            **qtext(cam_choice_q),
            feedbackCorrect="Certo: essa leitura conecta bem o texto ao contexto.",
            feedbackWrong=cam_choice_fw,
            options=[
                {"id": "a", "text": cam_choice_opts[0]},
                {"id": "b", "text": cam_choice_opts[1]},
                {"id": "c", "text": cam_choice_opts[2]},
                {"id": "d", "text": cam_choice_opts[3]},
            ],
            correctOptionId=cam_choice_correct,
            correctAnswer=cam_choice_correct,
        )
    )
    out.append(
        pack(
            **base,
            short="cam",
            nn="04",
            difficulty="caminhada",
            skill="understand",
            type="order",
            **qtext(f"Como se encadeiam os eventos de {verse_ref}?"),
            feedbackCorrect="Certo: esse é o encadeamento do relato.",
            feedbackWrong=order_wrong,
            options=order_opts,
            correctOrder=["a", "b", "c"],
            correctOptionId="a",
            correctAnswer="a",
        )
    )
    out.append(
        pack(
            **base,
            short="cam",
            nn="05",
            difficulty="caminhada",
            skill="understand",
            type="complete",
            **qtext(f'Complete a frase: "{cam_complete_blank}"'),
            template=cam_complete_blank,
            feedbackCorrect="Certo: essa palavra completa o sentido do versículo.",
            feedbackWrong={
                "b": "Essa opção não completa esta lacuna no texto.",
                "c": "Essa opção não completa esta lacuna no texto.",
            },
            options=[
                {"id": "a", "text": cam_complete_opts[0]},
                {"id": "b", "text": cam_complete_opts[1]},
                {"id": "c", "text": cam_complete_opts[2]},
            ],
            correctOptionId=cam_complete_correct,
            correctAnswer=cam_complete_correct,
        )
    )
    out.append(
        pack(
            **base,
            short="cam",
            nn="06",
            difficulty="caminhada",
            skill="understand",
            type="connect",
            **qtext(f"O que {verse_ref} comunica que se liga a este contexto?"),
            feedbackCorrect="Certo: essa ponte mostra a relação pedida pelo texto.",
            feedbackWrong={
                "b": "Essa leitura não captura a ponte com o contexto.",
                "c": "Essa leitura não captura a ponte com o contexto.",
            },
            passageA={"ref": verse_ref, "text": passage},
            passageB={"ref": "Contexto", "text": insight},
            options=[
                {"id": "a", "text": cam_bridge},
                {"id": "b", "text": cam_conn_wrong[0]},
                {"id": "c", "text": cam_conn_wrong[1]},
            ],
            correctOptionId="a",
            correctAnswer="a",
        )
    )

    # ---- PROFUNDDEZAS ----
    out.append(
        pack(
            **base,
            short="pro",
            nn="01",
            difficulty="profundezas",
            skill="interpret",
            type="true_false",
            **qtext(pro_tf),
            feedbackCorrect=fb_pro_tf[0],
            feedbackWrong={("false" if pro_tf_ok == "true" else "true"): fb_pro_tf[1]},
            options=TF,
            correctOptionId=pro_tf_ok,
            correctAnswer=pro_tf_ok,
        )
    )
    out.append(
        pack(
            **base,
            short="pro",
            nn="02",
            difficulty="profundezas",
            skill="interpret",
            type="tap",
            **qtext(f'Em {verse_ref}, toque a palavra que falta em "{pro_tap_blank}"?'),
            template=pro_tap_blank,
            feedbackCorrect="Exato: essa palavra sustenta o sentido do trecho.",
            feedbackWrong={
                "b": "Essa palavra não preenche esta lacuna no texto.",
                "c": "Essa palavra não preenche esta lacuna no texto.",
            },
            options=[
                {"id": "a", "text": pro_tap_opts[0]},
                {"id": "b", "text": pro_tap_opts[1]},
                {"id": "c", "text": pro_tap_opts[2]},
            ],
            correctOptionId=pro_tap_correct,
            correctAnswer=pro_tap_correct,
        )
    )
    out.append(
        pack(
            **base,
            short="pro",
            nn="03",
            difficulty="profundezas",
            skill="interpret",
            type="choice",
            **qtext(pro_choice_q),
            feedbackCorrect="Certo: essa interpretação respeita o sentido do texto.",
            feedbackWrong=pro_choice_fw,
            options=[
                {"id": "a", "text": pro_choice_opts[0]},
                {"id": "b", "text": pro_choice_opts[1]},
                {"id": "c", "text": pro_choice_opts[2]},
                {"id": "d", "text": pro_choice_opts[3]},
            ],
            correctOptionId=pro_choice_correct,
            correctAnswer=pro_choice_correct,
        )
    )
    out.append(
        pack(
            **base,
            short="pro",
            nn="04",
            difficulty="profundezas",
            skill="interpret",
            type="order",
            **qtext(f"Qual sequência revela o sentido de {verse_ref}?"),
            feedbackCorrect="Certo: essa sequência revela o sentido do trecho.",
            feedbackWrong=order_wrong,
            options=order_opts,
            correctOrder=["a", "b", "c"],
            correctOptionId="a",
            correctAnswer="a",
        )
    )
    out.append(
        pack(
            **base,
            short="pro",
            nn="05",
            difficulty="profundezas",
            skill="interpret",
            type="complete",
            **qtext(f'Complete a frase: "{pro_complete_blank}"'),
            template=pro_complete_blank,
            feedbackCorrect="Certo: essa lacuna aponta o foco teológico do verso.",
            feedbackWrong={
                "b": "Essa opção não completa esta lacuna no texto.",
                "c": "Essa opção não completa esta lacuna no texto.",
            },
            options=[
                {"id": "a", "text": pro_complete_opts[0]},
                {"id": "b", "text": pro_complete_opts[1]},
                {"id": "c", "text": pro_complete_opts[2]},
            ],
            correctOptionId=pro_complete_correct,
            correctAnswer=pro_complete_correct,
        )
    )
    out.append(
        pack(
            **base,
            short="pro",
            nn="06",
            difficulty="profundezas",
            skill="interpret",
            type="connect",
            **qtext(f"O que {verse_ref} comunica que se liga a este contexto?"),
            feedbackCorrect="Certo: essa ponte interpreta o sentido da missão.",
            feedbackWrong={
                "b": "Essa leitura não interpreta bem o vínculo com o contexto.",
                "c": "Essa leitura não interpreta bem o vínculo com o contexto.",
            },
            passageA={"ref": verse_ref, "text": passage},
            passageB={"ref": "Contexto", "text": insight},
            options=[
                {"id": "a", "text": pro_bridge},
                {"id": "b", "text": pro_conn_wrong[0]},
                {"id": "c", "text": pro_conn_wrong[1]},
            ],
            correctOptionId="a",
            correctAnswer="a",
        )
    )
    return out


OUT = []
TRAIL = "samuel"

# =============================================================================
# M1 — O chamado de Samuel
# =============================================================================
P1 = "Então, veio Jeová, parou e chamou como das outras vezes: Samuel, Samuel! Respondeu ele: Fala, pois o teu servo ouve."
OUT.extend(
    mission(
        trail=TRAIL,
        section="samuel-samuel-01-o-chamado-de-samuel",
        verse_ref="1 Samuel 3:10",
        evidence=["1 Samuel 3:10"],
        passage=P1,
        lo="Reconhecer que Jeová chama Samuel e o servo responde ouvindo a sua voz.",
        insight="Jeová chama; o servo ouve.",
        sem_tf="Jeová veio, parou e chamou: Samuel, Samuel!",
        sem_tf_ok="true",
        fb_sem_tf=("Certo: o texto registra a vinda e o chamado de Jeová.", "Releia: Jeová veio, parou e chamou Samuel."),
        sem_tap_blank="Respondeu ele: Fala, pois o teu ___ ouve",
        sem_tap_opts=["servo", "Jeová", "vezes"],
        sem_tap_correct="a",
        sem_choice_q="Qual fato o texto afirma sobre a resposta de Samuel?",
        sem_choice_opts=[
            "Samuel responde: Fala, pois o teu servo ouve",
            "Samuel foge sem responder ao chamado",
            "Samuel pede que Eli fale em seu lugar",
            "Samuel silencia e não reconhece a voz",
        ],
        sem_choice_correct="a",
        sem_choice_fw={
            "b": "Samuel responde; não foge.",
            "c": "A resposta é de Samuel, não um pedido a Eli.",
            "d": "Ele fala e se declara servo que ouve.",
        },
        sem_order_q="Qual sequência mostra a ordem dos fatos em 1 Samuel 3:10?",
        order_a="Então, veio Jeová, parou e chamou como das outras vezes",
        order_b="Samuel, Samuel!",
        order_c="Respondeu ele: Fala, pois o teu servo ouve",
        sem_complete_blank="Então, veio ___, parou e chamou como das outras vezes: Samuel, Samuel!",
        sem_complete_opts=["Jeová", "servo", "Eli"],
        sem_complete_correct="a",
        sem_bridge="Jeová chama e o servo ouve",
        sem_conn_wrong=("Samuel ignora o chamado e permanece em silêncio", "Jeová chama Eli no lugar de Samuel"),
        cam_tf="No trecho, Samuel responde ao chamado declarando-se servo que ouve.",
        cam_tf_ok="true",
        fb_cam_tf=("Certo: a resposta liga chamado e escuta do servo.", "Samuel responde: Fala, pois o teu servo ouve."),
        cam_tap_blank="Então, veio Jeová, parou e ___ como das outras vezes: Samuel, Samuel!",
        cam_tap_opts=["chamou", "servo", "ouve"],
        cam_tap_correct="a",
        cam_choice_q="Como se relacionam o chamado de Jeová e a resposta de Samuel?",
        cam_choice_opts=[
            "Jeová chama; Samuel se oferece a ouvir como servo",
            "Samuel chama Jeová primeiro e depois Jeová responde",
            "O chamado serve só para confirmar o status de Eli",
            "A resposta de Samuel anula o chamado de Jeová",
        ],
        cam_choice_correct="a",
        cam_choice_fw={
            "b": "Jeová chama primeiro; Samuel responde depois.",
            "c": "O foco é o chamado a Samuel, não o status de Eli.",
            "d": "A resposta confirma o chamado; não o anula.",
        },
        cam_complete_blank="Respondeu ele: ___, pois o teu servo ouve",
        cam_complete_opts=["Fala", "Jeová", "parou"],
        cam_complete_correct="a",
        cam_bridge="Chamado de Jeová e escuta do servo",
        cam_conn_wrong=("O chamado depende só da iniciativa do menino", "A resposta de Samuel anula a voz de Jeová"),
        pro_tf="O chamado de Jeová prepara o leitor para um ministério que começa na escuta.",
        pro_tf_ok="true",
        fb_pro_tf=("Certo: o servo ouve — a vocação começa na escuta.", "O texto une chamado e disponibilidade para ouvir."),
        pro_tap_blank="Respondeu ele: Fala, pois o teu servo ___",
        pro_tap_opts=["ouve", "parou", "vezes"],
        pro_tap_correct="a",
        pro_choice_q="Qual leitura interpreta melhor o sentido de 1 Samuel 3:10?",
        pro_choice_opts=[
            "Jeová inicia o chamado; o servo verdadeiro se põe a ouvir",
            "O texto ensina que o homem decide sozinho o próprio chamado",
            "O chamado de Jeová depende de rituais sem resposta pessoal",
            "Samuel ouve apenas por curiosidade, sem compromisso de servo",
        ],
        pro_choice_correct="a",
        pro_choice_fw={
            "b": "O chamado vem de Jeová; Samuel responde, não inventa.",
            "c": "Há resposta pessoal: Fala, pois o teu servo ouve.",
            "d": "A fórmula de servo mostra compromisso, não curiosidade.",
        },
        pro_complete_blank="Então, veio Jeová, ___ e chamou como das outras vezes: Samuel, Samuel!",
        pro_complete_opts=["parou", "servo", "Eli"],
        pro_complete_correct="a",
        pro_bridge="Vocação começa quando o servo ouve",
        pro_conn_wrong=("Vocação nasce sem qualquer escuta da voz divina", "O servo ouve apenas para obter poder político"),
    )
)

# =============================================================================
# M2 — Israel pede um rei
# =============================================================================
P2 = "Disse Jeová a Samuel: Ouve a voz do povo em tudo o que eles te dizem, pois não é a ti que eles rejeitaram, mas a mim, para eu não reinar sobre eles."
OUT.extend(
    mission(
        trail=TRAIL,
        section="samuel-samuel-02-israel-pede-um-rei",
        verse_ref="1 Samuel 8:7",
        evidence=["1 Samuel 8:7"],
        passage=P2,
        lo="Compreender que o pedido de rei rejeita o reinado de Jeová, não só a Samuel.",
        insight="Pedir rei rejeita o reinado de Jeová.",
        sem_tf="Jeová diz a Samuel que o povo rejeitou a ele, Jeová, para que não reinasse sobre eles.",
        sem_tf_ok="true",
        fb_sem_tf=("Certo: a rejeição aponta para Jeová, não só para Samuel.", "Releia: não é a ti que rejeitaram, mas a mim."),
        sem_tap_blank="pois não é a ti que eles ___, mas a mim, para eu não reinar sobre eles",
        sem_tap_opts=["rejeitaram", "Samuel", "povo"],
        sem_tap_correct="a",
        sem_choice_q="O que Jeová afirma sobre a rejeição do povo?",
        sem_choice_opts=[
            "Não é a Samuel que rejeitaram, mas a Jeová, para não reinar sobre eles",
            "O povo rejeita apenas costumes locais, sem relação com Jeová",
            "Jeová diz que Samuel é o único rejeitado pelo povo",
            "O pedido de rei é aprovado como fidelidade plena a Jeová",
        ],
        sem_choice_correct="a",
        sem_choice_fw={
            "b": "Jeová liga o pedido à rejeição do seu reinado.",
            "c": "Jeová diz que a rejeição é a ele, não só a Samuel.",
            "d": "O pedido é lido como rejeição, não como fidelidade.",
        },
        sem_order_q="Qual sequência mostra a ordem dos fatos em 1 Samuel 8:7?",
        order_a="Disse Jeová a Samuel: Ouve a voz do povo em tudo o que eles te dizem",
        order_b="pois não é a ti que eles rejeitaram, mas a mim",
        order_c="para eu não reinar sobre eles",
        sem_complete_blank="Disse ___ a Samuel: Ouve a voz do povo em tudo o que eles te dizem",
        sem_complete_opts=["Jeová", "povo", "rei"],
        sem_complete_correct="a",
        sem_bridge="Pedido de rei rejeita Jeová",
        sem_conn_wrong=("O pedido reforça o reinado direto de Jeová", "A rejeição atinge só Samuel, nunca a Jeová"),
        cam_tf="Jeová ordena que Samuel ouça a voz do povo, explicando que a rejeição é ao reinado divino.",
        cam_tf_ok="true",
        fb_cam_tf=("Certo: ouvir o povo e revelar a rejeição a Jeová vão juntos.", "Jeová une a ordem e a explicação da rejeição."),
        cam_tap_blank="para eu não ___ sobre eles",
        cam_tap_opts=["reinar", "Samuel", "povo"],
        cam_tap_correct="a",
        cam_choice_q="Qual relação o texto estabelece entre o pedido do povo e Jeová?",
        cam_choice_opts=[
            "Pedir rei é rejeitar que Jeová reine sobre o povo",
            "Pedir rei fortalece o reinado direto de Jeová sem mediação",
            "O conflito é só entre Samuel e o povo, sem tocante a Deus",
            "Jeová celebra o pedido como sinal de maturidade política",
        ],
        cam_choice_correct="a",
        cam_choice_fw={
            "b": "O texto diz o contrário: rejeitam para Jeová não reinar.",
            "c": "Jeová declara que a rejeição é a ele.",
            "d": "Não há celebração; há diagnóstico de rejeição.",
        },
        cam_complete_blank="pois não é a ti que eles rejeitaram, mas a ___, para eu não reinar sobre eles",
        cam_complete_opts=["mim", "Samuel", "povo"],
        cam_complete_correct="a",
        cam_bridge="Rejeição do reinado de Jeová",
        cam_conn_wrong=("Jeová celebra o pedido como fidelidade plena", "O povo rejeita costumes locais, não o reinado divino"),
        pro_tf="O pedido de rei revela que o povo prefere um rei humano ao reinado de Jeová.",
        pro_tf_ok="true",
        fb_pro_tf=("Certo: o sentido teológico é a troca do reinado divino.", "Jeová interpreta o pedido como rejeição a si."),
        pro_tap_blank="Ouve a ___ do povo em tudo o que eles te dizem",
        pro_tap_opts=["voz", "Jeová", "rei"],
        pro_tap_correct="a",
        pro_choice_q="Qual leitura interpreta melhor o sentido de 1 Samuel 8:7?",
        pro_choice_opts=[
            "O desejo de rei humano denuncia rejeição do reinado de Jeová",
            "Jeová perde autoridade e precisa de um rei para governar",
            "Samuel é culpado sozinho pelo pedido político de Israel",
            "O texto ensina que qualquer forma de governo anula a fé",
        ],
        pro_choice_correct="a",
        pro_choice_fw={
            "b": "Jeová não perde autoridade; o povo é quem rejeita.",
            "c": "Jeová isenta Samuel: a rejeição é a mim.",
            "d": "O problema é rejeitar o reinado de Jeová, não governo em si.",
        },
        pro_complete_blank="Ouve a voz do ___ em tudo o que eles te dizem",
        pro_complete_opts=["povo", "Jeová", "rei"],
        pro_complete_correct="a",
        pro_bridge="Troca do reinado divino por rei",
        pro_conn_wrong=("Jeová perde autoridade e precisa de rei humano", "Qualquer governo anula automaticamente a fé"),
    )
)

# =============================================================================
# M3 — Saul ungido
# =============================================================================
P3 = "Tomou Samuel o vaso de óleo, e lho derramou sobre a cabeça, e o beijou, e disse: Não te ungiu Jeová para ser príncipe sobre a sua herança?"
OUT.extend(
    mission(
        trail=TRAIL,
        section="samuel-saul-01-saul-ungido",
        verse_ref="1 Samuel 10:1",
        evidence=["1 Samuel 10:1"],
        passage=P3,
        lo="Reconhecer que Jeová unge Saul como príncipe sobre a sua herança.",
        insight="Jeová unge Saul príncipe sobre a herança.",
        # V/F: TB rhetorical question → assertion
        sem_tf="Samuel derramou óleo sobre a cabeça de Saul e o beijou.",
        sem_tf_ok="true",
        fb_sem_tf=("Certo: o texto registra o óleo, a cabeça e o beijo.", "Releia: tomou o vaso, derramou e beijou."),
        sem_tap_blank="Tomou Samuel o vaso de ___, e lho derramou sobre a cabeça",
        sem_tap_opts=["óleo", "Jeová", "herança"],
        sem_tap_correct="a",
        sem_choice_q="Qual fato o texto afirma sobre a unção de Saul?",
        sem_choice_opts=[
            "Samuel ungiu Saul e declarou que Jeová o ungiu príncipe sobre a herança",
            "Saul se unge a si mesmo sem participação de Samuel",
            "A unção serve apenas para nomear um sacerdote do templo",
            "Jeová recusa a unção e manda Samuel parar o rito",
        ],
        sem_choice_correct="a",
        sem_choice_fw={
            "b": "Samuel realiza a unção; Saul não se unge sozinho.",
            "c": "O texto fala de príncipe sobre a herança, não de sacerdote.",
            "d": "Samuel afirma a unção de Jeová; não há recusa.",
        },
        sem_order_q="Qual sequência mostra a ordem dos fatos em 1 Samuel 10:1?",
        order_a="Tomou Samuel o vaso de óleo, e lho derramou sobre a cabeça",
        order_b="e o beijou",
        order_c="e disse: Não te ungiu Jeová para ser príncipe sobre a sua herança?",
        sem_complete_blank="e disse: Não te ungiu ___ para ser príncipe sobre a sua herança?",
        sem_complete_opts=["Jeová", "Samuel", "óleo"],
        sem_complete_correct="a",
        sem_bridge="Jeová unge Saul príncipe",
        sem_conn_wrong=("Saul se unge sozinho sem Samuel", "A unção nomeia apenas um sacerdote do templo"),
        cam_tf="Jeová ungiu Saul para ser príncipe sobre a sua herança.",
        cam_tf_ok="true",
        fb_cam_tf=("Certo: a pergunta retórica afirma a unção de Jeová.", "O gesto e a palavra apontam: Jeová ungiu Saul príncipe."),
        cam_tap_blank="Não te ungiu Jeová para ser ___ sobre a sua herança?",
        cam_tap_opts=["príncipe", "óleo", "Samuel"],
        cam_tap_correct="a",
        cam_choice_q="Como o rito de Samuel se liga à ação de Jeová?",
        cam_choice_opts=[
            "O óleo e a palavra mostram que Jeová constitui Saul príncipe",
            "Samuel unge por conta própria, sem referência a Jeová",
            "A unção apenas celebra amizade entre Samuel e Saul",
            "O beijo anula a autoridade do príncipe ungido",
        ],
        cam_choice_correct="a",
        cam_choice_fw={
            "b": "Samuel declara: Não te ungiu Jeová…",
            "c": "O foco é o ofício de príncipe, não só amizade.",
            "d": "O beijo acompanha a unção; não a anula.",
        },
        cam_complete_blank="Tomou Samuel o vaso de óleo, e lho derramou sobre a ___, e o beijou",
        cam_complete_opts=["cabeça", "herança", "Jeová"],
        cam_complete_correct="a",
        cam_bridge="Unção divina do príncipe",
        cam_conn_wrong=("Samuel unge sem citar a ação de Jeová", "O beijo anula a autoridade do príncipe"),
        pro_tf="A unção apresenta Saul como príncipe constituído por Jeová sobre a herança do povo.",
        pro_tf_ok="true",
        fb_pro_tf=("Certo: o sentido é autoridade dada por Jeová sobre a herança.", "O texto une óleo, beijo e declaração do príncipe."),
        pro_tap_blank="Não te ungiu Jeová para ser príncipe sobre a sua ___?",
        pro_tap_opts=["herança", "óleo", "cabeça"],
        pro_tap_correct="a",
        pro_choice_q="Qual leitura interpreta melhor o sentido de 1 Samuel 10:1?",
        pro_choice_opts=[
            "Jeová, por meio de Samuel, constitui Saul príncipe sobre a herança",
            "Saul conquista o trono só pela força militar própria",
            "A unção é um gesto vazio sem compromisso com a herança de Jeová",
            "Samuel se declara rei e usa Saul apenas como testemunha",
        ],
        pro_choice_correct="a",
        pro_choice_fw={
            "b": "A autoridade vem da unção de Jeová, não só da força.",
            "c": "A pergunta afirma unção real para o ofício de príncipe.",
            "d": "Samuel unge Saul; não se declara rei no lugar dele.",
        },
        pro_complete_blank="Tomou ___ o vaso de óleo, e lho derramou sobre a cabeça, e o beijou",
        pro_complete_opts=["Samuel", "Jeová", "príncipe"],
        pro_complete_correct="a",
        pro_bridge="Autoridade dada por Jeová",
        pro_conn_wrong=("Saul conquista o trono só pela força própria", "Samuel se declara rei e usa Saul de testemunha"),
    )
)

# =============================================================================
# M4 — Desobediência de Saul
# =============================================================================
P4 = "Disse Samuel: Tem, porventura, Jeová tanto prazer em holocaustos e sacrifícios, quanto tem em que se obedeça à sua voz? Eis que o obedecer é melhor do que o sacrifício, e o atender, do que a gordura de carneiros."
OUT.extend(
    mission(
        trail=TRAIL,
        section="samuel-saul-02-desobediencia-de-sau",
        verse_ref="1 Samuel 15:22",
        evidence=["1 Samuel 15:22"],
        passage=P4,
        lo="Compreender que obedecer à voz de Jeová é melhor do que oferecer sacrifício.",
        insight="Obedecer é melhor do que o sacrifício.",
        # V/F: TB rhetorical question → assertion
        sem_tf="Samuel afirma que o obedecer é melhor do que o sacrifício.",
        sem_tf_ok="true",
        fb_sem_tf=("Certo: o texto declara isso com clareza.", "Releia: o obedecer é melhor do que o sacrifício."),
        sem_tap_blank="Eis que o ___ é melhor do que o sacrifício",
        sem_tap_opts=["obedecer", "holocaustos", "carneiros"],
        sem_tap_correct="a",
        sem_choice_q="O que Samuel declara sobre o prazer de Jeová?",
        sem_choice_opts=[
            "Obedecer à voz de Jeová vale mais do que holocaustos e sacrifícios",
            "Jeová prefere sacrifícios sem qualquer obediência",
            "Samuel exige só a gordura de carneiros, sem ouvir a voz",
            "Holocaustos substituem completamente a necessidade de obedecer",
        ],
        sem_choice_correct="a",
        sem_choice_fw={
            "b": "O texto prioriza a obediência, não o rito isolado.",
            "c": "O atender à voz supera a gordura de carneiros.",
            "d": "Sacrifício sem obediência não é o que Jeová mais preza.",
        },
        sem_order_q="Qual sequência mostra a ordem dos fatos em 1 Samuel 15:22?",
        order_a="Disse Samuel: Tem, porventura, Jeová tanto prazer em holocaustos e sacrifícios, quanto tem em que se obedeça à sua voz?",
        order_b="Eis que o obedecer é melhor do que o sacrifício",
        order_c="e o atender, do que a gordura de carneiros",
        sem_complete_blank="e o ___, do que a gordura de carneiros",
        sem_complete_opts=["atender", "holocaustos", "Samuel"],
        sem_complete_correct="a",
        sem_bridge="Obediência supera o sacrifício",
        sem_conn_wrong=("Jeová prefere ritos sem qualquer obediência", "A gordura de carneiros supera o atender à voz"),
        cam_tf="Jeová tem mais prazer em que se obedeça à sua voz do que só em holocaustos e sacrifícios.",
        cam_tf_ok="true",
        fb_cam_tf=("Certo: a pergunta retórica afirma prioridade da obediência.", "Samuel contrapõe rito e obediência à voz."),
        cam_tap_blank="quanto tem em que se ___ à sua voz?",
        cam_tap_opts=["obedeça", "sacrifício", "gordura"],
        cam_tap_correct="a",
        cam_choice_q="Como Samuel relaciona sacrifício e obediência?",
        cam_choice_opts=[
            "A obediência à voz de Jeová tem prioridade sobre o rito sacrificial",
            "O sacrifício cancela qualquer necessidade de ouvir a voz",
            "Jeová rejeita toda forma de culto e só aceita silêncio",
            "Atender a Jeová é inferior à gordura oferecida nos altares",
        ],
        cam_choice_correct="a",
        cam_choice_fw={
            "b": "O texto coloca obediência acima do sacrifício.",
            "c": "Há culto, mas subordinado à obediência.",
            "d": "O atender supera a gordura de carneiros.",
        },
        cam_complete_blank="Eis que o obedecer é melhor do que o ___",
        cam_complete_opts=["sacrifício", "atender", "Samuel"],
        cam_complete_correct="a",
        cam_bridge="Prioridade da voz de Jeová",
        cam_conn_wrong=("O sacrifício cancela a necessidade de ouvir", "Jeová rejeita toda forma de culto e escuta"),
        pro_tf="Ritos sem obediência não satisfazem o que Jeová mais preza: atender à sua voz.",
        pro_tf_ok="true",
        fb_pro_tf=("Certo: o sentido teológico privilegia a escuta obediente.", "Sacrifício sem obediência fica aquém do prazer de Jeová."),
        pro_tap_blank="Tem, porventura, Jeová tanto prazer em ___ e sacrifícios",
        pro_tap_opts=["holocaustos", "obedecer", "atender"],
        pro_tap_correct="a",
        pro_choice_q="Qual leitura interpreta melhor o sentido de 1 Samuel 15:22?",
        pro_choice_opts=[
            "Jeová valoriza mais a obediência à sua voz do que o culto sem escuta",
            "Jeová exige só quantidade de sacrifícios, sem importar a obediência",
            "Samuel inventa uma regra nova sem base no prazer de Jeová",
            "A gordura de carneiros é o centro absoluto da vontade divina",
        ],
        pro_choice_correct="a",
        pro_choice_fw={
            "b": "O texto relativiza o prazer só no rito.",
            "c": "Samuel fala do prazer de Jeová, não de regra inventada.",
            "d": "A gordura é superada pelo atender.",
        },
        pro_complete_blank="Tem, porventura, Jeová tanto prazer em holocaustos e ___, quanto tem em que se obedeça à sua voz?",
        pro_complete_opts=["sacrifícios", "obedecer", "atender"],
        pro_complete_correct="a",
        pro_bridge="Culto sem escuta não basta",
        pro_conn_wrong=("A quantidade de sacrifícios basta sem obediência", "A gordura é o centro absoluto da vontade divina"),
    )
)

# =============================================================================
# M5 — Davi ungido
# =============================================================================
P5 = "Tomou Samuel o chifre de óleo e o ungiu no meio de seus irmãos; e, daquele dia em diante, se apoderou de Davi o Espírito de Jeová. Então, levantando-se Samuel, foi para Ramá."
OUT.extend(
    mission(
        trail=TRAIL,
        section="samuel-davi-01-davi-ungido",
        verse_ref="1 Samuel 16:13",
        evidence=["1 Samuel 16:13"],
        passage=P5,
        lo="Reconhecer que, na unção, o Espírito de Jeová se apodera de Davi.",
        insight="Espírito se apodera de Davi na unção.",
        sem_tf="Samuel ungiu Davi com o chifre de óleo no meio de seus irmãos.",
        sem_tf_ok="true",
        fb_sem_tf=("Certo: o texto registra a unção no meio dos irmãos.", "Releia: tomou o chifre de óleo e o ungiu."),
        sem_tap_blank="Tomou Samuel o chifre de ___ e o ungiu no meio de seus irmãos",
        sem_tap_opts=["óleo", "Espírito", "Ramá"],
        sem_tap_correct="a",
        sem_choice_q="O que acontece com Davi a partir da unção?",
        sem_choice_opts=[
            "Daquele dia em diante, o Espírito de Jeová se apoderou de Davi",
            "Davi perde imediatamente o Espírito de Jeová",
            "Samuel permanece em Judá e não parte para Ramá",
            "Os irmãos de Davi são ungidos no lugar dele",
        ],
        sem_choice_correct="a",
        sem_choice_fw={
            "b": "O texto diz que o Espírito se apoderou de Davi.",
            "c": "Samuel se levanta e vai para Ramá.",
            "d": "A unção é de Davi, no meio dos irmãos.",
        },
        sem_order_q="Qual sequência mostra a ordem dos fatos em 1 Samuel 16:13?",
        order_a="Tomou Samuel o chifre de óleo e o ungiu no meio de seus irmãos",
        order_b="e, daquele dia em diante, se apoderou de Davi o Espírito de Jeová",
        order_c="Então, levantando-se Samuel, foi para Ramá",
        sem_complete_blank="Então, levantando-se Samuel, foi para ___",
        sem_complete_opts=["Ramá", "óleo", "Davi"],
        sem_complete_correct="a",
        sem_bridge="Espírito se apodera na unção",
        sem_conn_wrong=("Davi perde o Espírito no momento da unção", "Samuel unge os irmãos no lugar de Davi"),
        cam_tf="A unção de Davi e a vinda do Espírito de Jeová estão ligadas no mesmo relato.",
        cam_tf_ok="true",
        fb_cam_tf=("Certo: unção e Espírito se encadeiam no versículo.", "Daquele dia em diante o Espírito se apodera de Davi."),
        cam_tap_blank="e, daquele dia em diante, se apoderou de Davi o ___ de Jeová",
        cam_tap_opts=["Espírito", "óleo", "Ramá"],
        cam_tap_correct="a",
        cam_choice_q="Como se relacionam a unção e o Espírito no texto?",
        cam_choice_opts=[
            "Após a unção, o Espírito de Jeová se apodera de Davi",
            "O Espírito chega primeiro e depois Samuel unge Davi",
            "A unção serve só para separar Davi dos irmãos sem Espírito",
            "Samuel leva o Espírito embora ao partir para Ramá",
        ],
        cam_choice_correct="a",
        cam_choice_fw={
            "b": "Primeiro a unção; depois o Espírito se apodera.",
            "c": "O texto liga unção e Espírito explicitamente.",
            "d": "Samuel parte; o Espírito permanece sobre Davi.",
        },
        cam_complete_blank="Tomou Samuel o ___ de óleo e o ungiu no meio de seus irmãos",
        cam_complete_opts=["chifre", "Espírito", "Ramá"],
        cam_complete_correct="a",
        cam_bridge="Unção e Espírito juntos",
        cam_conn_wrong=("O Espírito chega antes e a unção vem depois", "Samuel leva o Espírito embora ao ir a Ramá"),
        pro_tf="A unção marca o início de uma nova capacitação: o Espírito de Jeová sobre Davi.",
        pro_tf_ok="true",
        fb_pro_tf=("Certo: o sentido é capacitação divina a partir daquele dia.", "O Espírito se apodera de Davi na unção."),
        pro_tap_blank="e o ungiu no meio de seus ___; e, daquele dia em diante, se apoderou de Davi o Espírito de Jeová",
        pro_tap_opts=["irmãos", "óleo", "Ramá"],
        pro_tap_correct="a",
        pro_choice_q="Qual leitura interpreta melhor o sentido de 1 Samuel 16:13?",
        pro_choice_opts=[
            "Jeová capacita Davi pelo Espírito a partir da unção",
            "Davi governa só por talento familiar, sem ação do Espírito",
            "A partida de Samuel cancela a unção de Davi",
            "O óleo substitui o Espírito e torna o rito puramente humano",
        ],
        pro_choice_correct="a",
        pro_choice_fw={
            "b": "O texto destaca o Espírito de Jeová sobre Davi.",
            "c": "Samuel parte para Ramá; a unção permanece.",
            "d": "Óleo e Espírito aparecem juntos; o óleo não substitui.",
        },
        pro_complete_blank="e, daquele dia em diante, se ___ de Davi o Espírito de Jeová",
        pro_complete_opts=["apoderou", "ungiu", "levantando"],
        pro_complete_correct="a",
        pro_bridge="Capacitação pelo Espírito",
        pro_conn_wrong=("Davi governa só por talento familiar", "O óleo substitui o Espírito no relato"),
    )
)

# =============================================================================
# M6 — Davi e Golias
# =============================================================================
P6 = "Então, lhe respondeu Davi: Tu vens a mim com espada, e com lança, e com escudo; eu, porém, venho a ti em nome de Jeová dos Exércitos, do Deus das tropas de Israel, as quais tens desafiado."
OUT.extend(
    mission(
        trail=TRAIL,
        section="samuel-davi-02-davi-e-golias",
        verse_ref="1 Samuel 17:45",
        evidence=["1 Samuel 17:45"],
        passage=P6,
        lo="Reconhecer que Davi enfrenta Golias no nome de Jeová dos Exércitos.",
        insight="Davi vem no nome de Jeová dos Exércitos.",
        sem_tf="Davi diz que o adversário vem com espada, lança e escudo.",
        sem_tf_ok="true",
        fb_sem_tf=("Certo: o texto lista espada, lança e escudo.", "Releia a resposta de Davi sobre as armas do outro."),
        sem_tap_blank="eu, porém, venho a ti em ___ de Jeová dos Exércitos",
        sem_tap_opts=["nome", "espada", "lança"],
        sem_tap_correct="a",
        sem_choice_q="Como Davi descreve a sua própria chegada ao combate?",
        sem_choice_opts=[
            "Vem em nome de Jeová dos Exércitos, Deus das tropas de Israel",
            "Vem apenas com espada, lança e escudo próprios",
            "Declara que Israel não tem Deus nas tropas",
            "Afirma que o adversário nunca desafiou as tropas de Israel",
        ],
        sem_choice_correct="a",
        sem_choice_fw={
            "b": "Davi contrapõe as armas ao nome de Jeová.",
            "c": "Ele fala do Deus das tropas de Israel.",
            "d": "Ele diz: as quais tens desafiado.",
        },
        sem_order_q="Qual sequência mostra a ordem dos fatos em 1 Samuel 17:45?",
        order_a="Então, lhe respondeu Davi: Tu vens a mim com espada, e com lança, e com escudo",
        order_b="eu, porém, venho a ti em nome de Jeová dos Exércitos",
        order_c="do Deus das tropas de Israel, as quais tens desafiado",
        sem_complete_blank="Tu vens a mim com ___, e com lança, e com escudo",
        sem_complete_opts=["espada", "nome", "Jeová"],
        sem_complete_correct="a",
        sem_bridge="Davi vem no nome de Jeová",
        sem_conn_wrong=("Davi confia só em espada, lança e escudo", "Israel não tem Deus nas tropas, segundo Davi"),
        cam_tf="Davi contrapõe as armas do adversário ao nome de Jeová dos Exércitos.",
        cam_tf_ok="true",
        fb_cam_tf=("Certo: armas humanas versus nome de Jeová.", "O porém marca o contraste no verso."),
        cam_tap_blank="do Deus das ___ de Israel, as quais tens desafiado",
        cam_tap_opts=["tropas", "espada", "escudo"],
        cam_tap_correct="a",
        cam_choice_q="Qual contraste o texto estabelece no confronto?",
        cam_choice_opts=[
            "Armas humanas de um lado; o nome de Jeová do outro",
            "Davi confia só na lança, como o adversário",
            "O desafio às tropas de Israel é irrelevante no discurso",
            "Jeová dos Exércitos fica de fora do combate descrito",
        ],
        cam_choice_correct="a",
        cam_choice_fw={
            "b": "Davi não vem com as mesmas armas; vem no nome de Jeová.",
            "c": "Ele cita o desafio às tropas de Israel.",
            "d": "Jeová dos Exércitos é o centro da resposta de Davi.",
        },
        cam_complete_blank="eu, porém, venho a ti em nome de ___ dos Exércitos",
        cam_complete_opts=["Jeová", "espada", "escudo"],
        cam_complete_correct="a",
        cam_bridge="Armas versus nome de Jeová",
        cam_conn_wrong=("Davi iguala as armas do adversário às suas", "Jeová dos Exércitos fica de fora do confronto"),
        pro_tf="O combate de Davi é interpretado como defesa da honra de Jeová, desafiada nas tropas de Israel.",
        pro_tf_ok="true",
        fb_pro_tf=("Certo: o desafio às tropas toca o Deus de Israel.", "Davi luta no nome de Jeová dos Exércitos."),
        pro_tap_blank="as quais tens ___.",
        pro_tap_opts=["desafiado", "espada", "nome"],
        pro_tap_correct="a",
        pro_choice_q="Qual leitura interpreta melhor o sentido de 1 Samuel 17:45?",
        pro_choice_opts=[
            "A vitória esperada depende do nome de Jeová, não das armas do gigante",
            "Davi iguala o combate a uma disputa só de força física",
            "O nome de Jeová é detalhe ornamental sem peso no confronto",
            "Desafiar as tropas de Israel não ofende o Deus delas",
        ],
        pro_choice_correct="a",
        pro_choice_fw={
            "b": "Davi rejeita a lógica só das armas.",
            "c": "O nome de Jeová é o eixo da resposta.",
            "d": "Davi liga o desafio às tropas ao Deus de Israel.",
        },
        pro_complete_blank="Tu vens a mim com espada, e com ___, e com escudo",
        pro_complete_opts=["lança", "nome", "Jeová"],
        pro_complete_correct="a",
        pro_bridge="Honra de Jeová no combate",
        pro_conn_wrong=("O combate é só disputa de força física", "Desafiar as tropas não ofende o Deus de Israel"),
    )
)

# =============================================================================
# M7 — Desafio / promessa ao rei (casa e trono)
# =============================================================================
P7 = "Será estável para sempre diante de mim a tua casa e o teu reino; será estabelecido para sempre o teu trono."
OUT.extend(
    mission(
        trail=TRAIL,
        section="samuel-davi-03-desafio-o-rei",
        verse_ref="2 Samuel 7:16",
        evidence=["2 Samuel 7:16"],
        passage=P7,
        lo="Reconhecer a promessa de casa e trono estáveis para sempre diante de Jeová.",
        insight="Casa e trono estáveis para sempre.",
        sem_tf="A casa e o reino de Davi serão estáveis para sempre diante de Jeová.",
        sem_tf_ok="true",
        fb_sem_tf=("Certo: o texto promete estabilidade para sempre.", "Releia: será estável para sempre a tua casa e o teu reino."),
        sem_tap_blank="será estabelecido para sempre o teu ___",
        sem_tap_opts=["trono", "casa", "reino"],
        sem_tap_correct="a",
        sem_choice_q="O que o texto promete sobre a casa e o reino?",
        sem_choice_opts=[
            "Serão estáveis para sempre diante de Jeová, e o trono estabelecido",
            "A casa e o reino duram só uma geração e depois caem",
            "O trono nunca será estabelecido diante de Jeová",
            "A promessa exclui a casa e fala só de um templo de pedra",
        ],
        sem_choice_correct="a",
        sem_choice_fw={
            "b": "O texto diz para sempre, não só uma geração.",
            "c": "O trono será estabelecido para sempre.",
            "d": "A promessa inclui casa, reino e trono.",
        },
        sem_order_q="Qual sequência mostra a ordem dos fatos em 2 Samuel 7:16?",
        order_a="Será estável para sempre diante de mim a tua casa e o teu reino",
        order_b="será estabelecido para sempre",
        order_c="o teu trono",
        sem_complete_blank="Será ___ para sempre diante de mim a tua casa e o teu reino",
        sem_complete_opts=["estável", "trono", "estabelecido"],
        sem_complete_correct="a",
        sem_bridge="Casa e trono para sempre",
        sem_conn_wrong=("A casa e o reino duram só uma geração", "O trono nunca será estabelecido diante de Jeová"),
        cam_tf="A estabilidade da casa e do reino está ligada ao estabelecimento perpétuo do trono.",
        cam_tf_ok="true",
        fb_cam_tf=("Certo: casa, reino e trono se encadeiam na promessa.", "O texto une estabilidade e estabelecimento para sempre."),
        cam_tap_blank="Será estável para sempre diante de mim a tua ___ e o teu reino",
        cam_tap_opts=["casa", "trono", "estabelecido"],
        cam_tap_correct="a",
        cam_choice_q="Como se relacionam casa, reino e trono na promessa?",
        cam_choice_opts=[
            "Casa e reino estáveis e trono estabelecido para sempre diante de Jeová",
            "Só o trono dura; a casa e o reino são temporários",
            "A promessa vale só enquanto Davi viver em pessoa",
            "Estabilidade diante de Jeová é negada ao reino de Davi",
        ],
        cam_choice_correct="a",
        cam_choice_fw={
            "b": "Casa, reino e trono estão na mesma promessa perpétua.",
            "c": "O texto diz para sempre, além da vida de Davi.",
            "d": "A estabilidade é afirmada, não negada.",
        },
        cam_complete_blank="será ___ para sempre o teu trono",
        cam_complete_opts=["estabelecido", "casa", "reino"],
        cam_complete_correct="a",
        cam_bridge="Promessa perpétua ao trono",
        cam_conn_wrong=("Só o trono dura; casa e reino são temporários", "A promessa vale só enquanto Davi viver"),
        pro_tf="A promessa aponta para um reinado duradouro diante de Jeová, além de um sucesso passageiro.",
        pro_tf_ok="true",
        fb_pro_tf=("Certo: para sempre marca o horizonte da promessa.", "Casa e trono estáveis revelam fidelidade duradoura de Jeová."),
        pro_tap_blank="Será estável para sempre diante de ___ a tua casa e o teu reino",
        pro_tap_opts=["mim", "trono", "casa"],
        pro_tap_correct="a",
        pro_choice_q="Qual leitura interpreta melhor o sentido de 2 Samuel 7:16?",
        pro_choice_opts=[
            "Jeová garante estabilidade duradoura à casa e ao trono de Davi",
            "A promessa é só política e exclui qualquer ação de Jeová",
            "O trono de Davi é declarado instável e passageiro no texto",
            "Casa e reino ficam estáveis apenas longe da presença de Jeová",
        ],
        pro_choice_correct="a",
        pro_choice_fw={
            "b": "A estabilidade é diante de mim — ação de Jeová.",
            "c": "O texto afirma estabelecimento para sempre.",
            "d": "A estabilidade é diante de Jeová, não longe dele.",
        },
        pro_complete_blank="Será estável para sempre diante de mim a tua casa e o teu ___",
        pro_complete_opts=["reino", "trono", "estabelecido"],
        pro_complete_correct="a",
        pro_bridge="Fidelidade duradoura de Jeová",
        pro_conn_wrong=("A promessa exclui qualquer ação de Jeová", "O trono de Davi é declarado instável no texto"),
    )
)

assert len(OUT) == 126, len(OUT)

path = Path(__file__).with_name("samuel.json")
path.write_text(json.dumps(OUT, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {path} ({len(OUT)} questions)")
