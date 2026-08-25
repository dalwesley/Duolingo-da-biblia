#!/usr/bin/env python3
"""Gera perguntas-v2/eclesiologia.json (72 perguntas, 4 missões)."""
import json
from pathlib import Path

TB_M1 = (
    "Pois, assim como o corpo é um e tem muitos membros, e todos os membros do corpo, "
    "embora muitos, constituem um só corpo, assim também é Cristo. Em um só Espírito, "
    "fomos batizados todos nós em um só corpo, quer judeus, quer gregos, quer escravos, "
    "quer livres; e a todos nós foi dado beber dum só Espírito."
)
TB_M2 = (
    "e perseveravam na doutrina dos apóstolos e na comunhão, no partir do pão e nas orações."
)
TB_M3 = (
    "Ide, pois, e fazei discípulos de todas as nações, batizando-as em o nome do Pai, "
    "e do Filho, e do Espírito Santo; instruindo-as a observar todas as coisas que vos "
    "tenho mandado. Eis que eu estou convosco todos os dias até o fim do mundo."
)
TB_13 = (
    "Em um só Espírito, fomos batizados todos nós em um só corpo, quer judeus, quer gregos, "
    "quer escravos, quer livres; e a todos nós foi dado beber dum só Espírito."
)
TB_19 = (
    "Ide, pois, e fazei discípulos de todas as nações, batizando-as em o nome do Pai, "
    "e do Filho, e do Espírito Santo;"
)
TB_BOSS = f"{TB_13} {TB_M2} {TB_19}"

TF_OPTS = [
    {"id": "true", "text": "Verdadeiro"},
    {"id": "false", "text": "Falso"},
]


def base(trail, section, diff, skill, verse_ref, lo, evidence, typ, text, fb_ok, fb_wrong, **extra):
    qid_nn = {"true_false": "01", "tap": "02", "choice": "03", "order": "04", "complete": "05", "connect": "06"}[typ]
    short = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}[diff]
    obj = {
        "difficulty": diff,
        "skill": skill,
        "verseRef": verse_ref,
        "learningObjective": lo,
        "evidence": evidence,
        "type": typ,
        "question": text,
        "prompt": text,
        "cue": text,
        "feedbackCorrect": fb_ok,
        "feedbackWrong": fb_wrong,
        "trail": trail,
        "section": section,
        "id": f"{trail}-{short}-{section}-{qid_nn}",
    }
    obj.update(extra)
    return obj


def tf(text, correct, fb_ok, fb_wrong, passage, **kw):
    wrong_id = "false" if correct == "true" else "true"
    return base(
        typ="true_false",
        text=text,
        fb_ok=fb_ok,
        fb_wrong={wrong_id: fb_wrong},
        options=TF_OPTS,
        correctOptionId=correct,
        correctAnswer=correct,
        passageText=passage,
        **kw,
    )


def tap(ref, template, opts, correct, fb_ok, fb_wrong, passage, **kw):
    return base(
        typ="tap",
        text=f'Em {ref}, toque a palavra que falta em "{template}"?',
        fb_ok=fb_ok,
        fb_wrong=fb_wrong,
        passageText=passage,
        template=template,
        options=[{"id": k, "text": v} for k, v in opts],
        correctOptionId=correct,
        correctAnswer=correct,
        **kw,
    )


def choice(text, opts, correct, fb_ok, fb_wrong, passage, **kw):
    return base(
        typ="choice",
        text=text,
        fb_ok=fb_ok,
        fb_wrong=fb_wrong,
        passageText=passage,
        options=[{"id": k, "text": v} for k, v in opts],
        correctOptionId=correct,
        correctAnswer=correct,
        **kw,
    )


def order(text, pieces, fb_ok, fb_wrong, passage, **kw):
    return base(
        typ="order",
        text=text,
        fb_ok=fb_ok,
        fb_wrong=fb_wrong,
        passageText=passage,
        options=[{"id": k, "text": v} for k, v in pieces],
        correctOrder=[k for k, _ in pieces],
        correctOptionId="a",
        correctAnswer="a",
        **kw,
    )


def complete(template, opts, correct, fb_ok, fb_wrong, passage, **kw):
    return base(
        typ="complete",
        text=f'Complete a frase: "{template}"',
        fb_ok=fb_ok,
        fb_wrong=fb_wrong,
        passageText=passage,
        template=template,
        options=[{"id": k, "text": v} for k, v in opts],
        correctOptionId=correct,
        correctAnswer=correct,
        **kw,
    )


def connect(ref, qtext, pa_text, pb_text, opts, correct, fb_ok, fb_wrong, passage, **kw):
    return base(
        typ="connect",
        text=qtext,
        fb_ok=fb_ok,
        fb_wrong=fb_wrong,
        passageText=passage,
        passageA={"ref": ref, "text": pa_text},
        passageB={"ref": "Contexto", "text": pb_text},
        options=[{"id": k, "text": v} for k, v in opts],
        correctOptionId=correct,
        correctAnswer=correct,
        **kw,
    )


def mission(section, verse_ref, lo, evidence, insight, passage, modes):
    meta = dict(trail="eclesiologia", section=section, verse_ref=verse_ref, lo=lo, evidence=evidence)
    out = []
    for diff, skill, items in modes:
        for builder in items:
            out.append(builder(diff=diff, skill=skill, **meta))
    return out, insight, passage


def m1():
    sec = "ec-01-corpo"
    vr = "1 Coríntios 12:12–13"
    lo = "Reconhecer a igreja como um só corpo em Cristo: muitos membros, um Espírito, judeus e gregos no mesmo batismo."
    ev = ["1 Coríntios 12:12", "1 Coríntios 12:13"]
    p = TB_M1
    insight = "Um corpo em Cristo: muitos membros, um Espírito, judeus e gregos no mesmo batismo."
    meta = dict(trail="eclesiologia", section=sec, verse_ref=vr, lo=lo, evidence=ev)

    def pack(diff, skill, qs):
        return [q(diff=diff, skill=skill, **meta) for q in qs]

    semente = pack(
        "semente",
        "observe",
        [
            lambda **k: tf(
                "O corpo é um e tem muitos membros; todos, embora muitos, constituem um só corpo, assim também é Cristo.",
                "true",
                "Certo: 1 Coríntios 12:12 afirma o corpo um e Cristo.",
                "Releia: muitos membros constituem um só corpo, assim também é Cristo.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "assim também é ___",
                [("a", "membros"), ("b", "Cristo"), ("c", "judeus")],
                "b",
                "Exato: assim também é Cristo.",
                {"a": "Membros são muitos; a comparação fecha em Cristo.", "c": "Judeus aparece no v. 13, não nesta lacuna."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual afirmação o texto faz diretamente em 1 Coríntios 12:12–13?",
                [
                    ("a", "Em um só Espírito fomos batizados todos nós em um só corpo."),
                    ("b", "Só os judeus foram batizados no corpo de Cristo."),
                    ("c", "Escravos ficam fora do único corpo."),
                    ("d", "Cada membro forma um Cristo separado."),
                ],
                "a",
                "Certo: um Espírito, um corpo, todos batizados.",
                {
                    "b": "O texto inclui judeus e gregos no mesmo corpo.",
                    "c": "Escravos e livres bebem dum só Espírito.",
                    "d": "Muitos membros constituem um só corpo, assim também é Cristo.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos em 1 Coríntios 12:12–13?",
                [
                    ("a", "o corpo é um e tem muitos membros"),
                    ("b", "constituem um só corpo, assim também é Cristo"),
                    ("c", "Em um só Espírito, fomos batizados todos nós em um só corpo"),
                ],
                "Certo: analogia do corpo, Cristo, depois o batismo no Espírito.",
                {"b": "A comparação com Cristo vem depois dos muitos membros.", "c": "O batismo no Espírito fecha o trecho."},
                p,
                **k,
            ),
            lambda **k: complete(
                "Em um só ___, fomos batizados todos nós em um só corpo",
                [("a", "Espírito"), ("b", "Cristo"), ("c", "gregos")],
                "a",
                "Certo: em um só Espírito fomos batizados.",
                {"b": "Cristo fecha o v. 12, não esta lacuna.", "c": "Gregos é um dos grupos incluídos, não o meio do batismo."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que 1 Coríntios 12:12–13 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Um corpo, um Espírito"),
                    ("b", "Dois corpos étnicos"),
                    ("c", "Espírito só para livres"),
                ],
                "a",
                "Certo: muitos membros, um corpo, um Espírito.",
                {"b": "Judeus e gregos entram no mesmo corpo.", "c": "Escravos e livres bebem dum só Espírito."},
                p,
                **k,
            ),
        ],
    )

    caminhada = pack(
        "caminhada",
        "understand",
        [
            lambda **k: tf(
                "Fomos batizados todos nós em um só corpo, quer judeus, quer gregos, quer escravos, quer livres.",
                "true",
                "Certo: o v. 13 lista esses grupos no mesmo corpo.",
                "O texto inclui judeus, gregos, escravos e livres no único corpo.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "fomos ___ todos nós em um só corpo",
                [("a", "batizados"), ("b", "livres"), ("c", "membros")],
                "a",
                "Exato: fomos batizados todos nós em um só corpo.",
                {"b": "Livres é um dos grupos, não o verbo desta lacuna.", "c": "Membros descreve as partes do corpo no v. 12."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como 1 Coríntios 12:12–13 relaciona diversidade e unidade?",
                [
                    ("a", "A unidade apaga judeus e gregos até não haver diferença alguma."),
                    ("b", "Muitos membros e grupos distintos entram no mesmo corpo e Espírito."),
                    ("c", "Cada origem étnica recebe um Espírito próprio."),
                    ("d", "Só os livres bebem do Espírito; os escravos observam de fora."),
                ],
                "b",
                "Certo: muitos membros, um corpo, um Espírito para todos.",
                {
                    "a": "O texto nomeia judeus e gregos; não os apaga.",
                    "c": "Há um só Espírito, não um por etnia.",
                    "d": "Escravos e livres bebem dum só Espírito.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de 1 Coríntios 12:12–13?",
                [
                    ("a", "todos os membros do corpo, embora muitos, constituem um só corpo"),
                    ("b", "Em um só Espírito, fomos batizados todos nós em um só corpo"),
                    ("c", "a todos nós foi dado beber dum só Espírito"),
                ],
                "Certo: um corpo, batismo no Espírito, beber do mesmo Espírito.",
                {"b": "O batismo vem depois da analogia do corpo.", "c": "Beber dum só Espírito fecha o versículo."},
                p,
                **k,
            ),
            lambda **k: complete(
                "quer judeus, quer ___, quer escravos, quer livres",
                [("a", "Cristo"), ("b", "gregos"), ("c", "batizados")],
                "b",
                "Certo: quer judeus, quer gregos.",
                {"a": "Cristo é o analogado do corpo, não um par étnico.", "c": "Batizados é o verbo anterior, não este par."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que 1 Coríntios 12:12–13 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Batismo que separa etnias"),
                    ("b", "Espírito só para judeus"),
                    ("c", "Judeus e gregos no mesmo batismo"),
                ],
                "c",
                "Certo: o mesmo batismo une judeus e gregos.",
                {"a": "O batismo é em um só corpo, não em dois.", "b": "Gregos, escravos e livres também bebem do Espírito."},
                p,
                **k,
            ),
        ],
    )

    profundezas = pack(
        "profundezas",
        "interpret",
        [
            lambda **k: tf(
                "O único Espírito forma dois corpos distintos: um judeu e outro grego.",
                "false",
                "Certo: o texto fala de um só corpo e um só Espírito.",
                "Não há dois corpos: judeus e gregos entram no mesmo.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "embora muitos, constituem um só ___",
                [("a", "corpo"), ("b", "escravos"), ("c", "Espírito")],
                "a",
                "Exato: constituem um só corpo.",
                {"b": "Escravos entra na lista do v. 13.", "c": "Espírito nomeia o meio do batismo, não esta analogia."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual leitura teológica 1 Coríntios 12:12–13 sustenta?",
                [
                    ("a", "A analogia do corpo autoriza igrejas étnicas sem comunhão mútua."),
                    ("b", "O Espírito é dado só depois que cada um escolhe seu grupo."),
                    ("c", "Cristo é o um em quem muitos membros já compartilham o mesmo Espírito."),
                    ("d", "Beber do Espírito substitui o batismo no único corpo."),
                ],
                "c",
                "Certo: assim também é Cristo — um corpo, um Espírito.",
                {
                    "a": "Judeus e gregos estão no mesmo corpo.",
                    "b": "O texto diz que a todos foi dado beber dum só Espírito.",
                    "d": "Batismo no corpo e beber do Espírito vêm juntos.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de 1 Coríntios 12:12–13?",
                [
                    ("a", "assim também é Cristo"),
                    ("b", "quer judeus, quer gregos, quer escravos, quer livres"),
                    ("c", "a todos nós foi dado beber dum só Espírito"),
                ],
                "Certo: Cristo, inclusão dos grupos, um só Espírito para todos.",
                {"b": "A lista de grupos vem no batismo do v. 13.", "c": "Beber dum só Espírito conclui o sentido."},
                p,
                **k,
            ),
            lambda **k: complete(
                "quer escravos, quer ___; e a todos nós foi dado beber dum só Espírito",
                [("a", "membros"), ("b", "livres"), ("c", "Cristo")],
                "b",
                "Certo: quer escravos, quer livres.",
                {"a": "Membros é do v. 12, não deste par social.", "c": "Cristo não entra nesta lista de condições."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que 1 Coríntios 12:12–13 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Muitos membros, um Espírito"),
                    ("b", "Cristo fora do corpo"),
                    ("c", "Batismo só de livres"),
                ],
                "a",
                "Certo: a unidade do corpo é no único Espírito.",
                {"b": "Assim também é Cristo: ele é o um do corpo.", "c": "Escravos e livres bebem dum só Espírito."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def m2():
    sec = "ec-02-reuniao"
    vr = "Atos 2:42"
    lo = "Perceber que a igreja persevera na doutrina dos apóstolos, na comunhão, no partir do pão e nas orações."
    ev = ["Atos 2:42"]
    p = TB_M2
    insight = "Comunhão e ensino: a igreja persevera em doutrina, comunhão, pão e orações."
    meta = dict(trail="eclesiologia", section=sec, verse_ref=vr, lo=lo, evidence=ev)

    def pack(diff, skill, qs):
        return [q(diff=diff, skill=skill, **meta) for q in qs]

    semente = pack(
        "semente",
        "observe",
        [
            lambda **k: tf(
                "Eles perseveravam na doutrina dos apóstolos e na comunhão, no partir do pão e nas orações.",
                "true",
                "Certo: Atos 2:42 lista essas quatro persistências.",
                "Releia Atos 2:42: doutrina, comunhão, pão e orações.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "perseveravam na ___ dos apóstolos e na comunhão",
                [("a", "doutrina"), ("b", "orações"), ("c", "pão")],
                "a",
                "Exato: perseveravam na doutrina dos apóstolos.",
                {"b": "Orações fecha o versículo.", "c": "Pão está no partir do pão, depois."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Em que o texto diz que perseveravam?",
                [
                    ("a", "Na doutrina dos apóstolos, na comunhão, no partir do pão e nas orações."),
                    ("b", "Somente em milagres públicos, sem ensino."),
                    ("c", "Apenas no partir do pão, sem orações."),
                    ("d", "Só na doutrina, recusando a comunhão."),
                ],
                "a",
                "Certo: as quatro práticas aparecem juntas.",
                {
                    "b": "O texto fala de doutrina, comunhão, pão e orações.",
                    "c": "As orações também estão no versículo.",
                    "d": "A comunhão vem logo após a doutrina.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos em Atos 2:42?",
                [
                    ("a", "perseveravam na doutrina dos apóstolos"),
                    ("b", "e na comunhão"),
                    ("c", "no partir do pão e nas orações"),
                ],
                "Certo: doutrina, comunhão, depois pão e orações.",
                {"b": "A comunhão vem depois da doutrina.", "c": "Pão e orações fecham o versículo."},
                p,
                **k,
            ),
            lambda **k: complete(
                "no partir do ___ e nas orações",
                [("a", "doutrina"), ("b", "pão"), ("c", "apóstolos")],
                "b",
                "Certo: no partir do pão e nas orações.",
                {"a": "Doutrina vem no início do versículo.", "c": "Apóstolos liga à doutrina, não ao partir."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Atos 2:42 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Doutrina, comunhão, pão e orações"),
                    ("b", "Ensino sem comunhão"),
                    ("c", "Orações no lugar da doutrina"),
                ],
                "a",
                "Certo: a persistência cobre as quatro práticas.",
                {"b": "A comunhão está no mesmo versículo.", "c": "Doutrina e orações convivem, não se excluem."},
                p,
                **k,
            ),
        ],
    )

    caminhada = pack(
        "caminhada",
        "understand",
        [
            lambda **k: tf(
                "A igreja de Atos 2:42 perseverava só na doutrina, sem comunhão, partir do pão ou orações.",
                "false",
                "Certo: o texto une as quatro práticas, não só a doutrina.",
                "Há também comunhão, partir do pão e orações.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "na doutrina dos apóstolos e na ___, no partir do pão",
                [("a", "comunhão"), ("b", "doutrina"), ("c", "orações")],
                "a",
                "Exato: e na comunhão, no partir do pão.",
                {"b": "Doutrina já apareceu antes desta lacuna.", "c": "Orações vem no fim, depois do pão."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como Atos 2:42 articula ensino e vida comum?",
                [
                    ("a", "A doutrina dos apóstolos dispensa comunhão, pão e orações."),
                    ("b", "O partir do pão substitui o ensino apostólico."),
                    ("c", "Perseverar une ensino, comunhão, pão e orações no mesmo ritmo."),
                    ("d", "As orações ficam para depois que a doutrina acabar."),
                ],
                "c",
                "Certo: um só perseverar cobre as quatro.",
                {
                    "a": "Comunhão, pão e orações estão no mesmo verso.",
                    "b": "A doutrina dos apóstolos abre a lista.",
                    "d": "Orações está na mesma persistência, não depois.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de Atos 2:42?",
                [
                    ("a", "na doutrina dos apóstolos"),
                    ("b", "e na comunhão, no partir do pão"),
                    ("c", "e nas orações"),
                ],
                "Certo: ensino, comunhão com o pão, orações.",
                {"b": "Comunhão e pão vêm após a doutrina.", "c": "As orações fecham a cadeia."},
                p,
                **k,
            ),
            lambda **k: complete(
                "no partir do pão e nas ___",
                [("a", "comunhão"), ("b", "orações"), ("c", "apóstolos")],
                "b",
                "Certo: e nas orações.",
                {"a": "Comunhão já veio antes do partir do pão.", "c": "Apóstolos qualifica a doutrina, não esta lacuna."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Atos 2:42 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Igreja só de ensino isolado"),
                    ("b", "Perseverança em quatro práticas"),
                    ("c", "Pão sem doutrina apostólica"),
                ],
                "b",
                "Certo: a igreja persevera nesse conjunto.",
                {"a": "A comunhão está ao lado da doutrina.", "c": "O partir do pão vem depois da doutrina."},
                p,
                **k,
            ),
        ],
    )

    profundezas = pack(
        "profundezas",
        "interpret",
        [
            lambda **k: tf(
                "A vida comum da igreja, segundo Atos 2:42, une ensino apostólico, comunhão, pão e orações.",
                "true",
                "Certo: o versículo descreve essa vida persistente.",
                "Atos 2:42 coloca as quatro no mesmo perseverar.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "na doutrina dos ___ e na comunhão",
                [("a", "apóstolos"), ("b", "pão"), ("c", "orações")],
                "a",
                "Exato: doutrina dos apóstolos.",
                {"b": "Pão está no partir do pão.", "c": "Orações fecha o versículo."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual sentido de igreja Atos 2:42 prepara o leitor a reconhecer?",
                [
                    ("a", "A igreja é assembleia ocasional, sem persistência comum."),
                    ("b", "O povo persevera junto em ensino, comunhão, mesa e oração."),
                    ("c", "Só o partir do pão define a igreja, sem doutrina."),
                    ("d", "Orações privadas dispensam a comunhão e o ensino."),
                ],
                "b",
                "Certo: perseverar descreve o povo nessas quatro vias.",
                {
                    "a": "O verbo é perseveravam, não um encontro solto.",
                    "c": "A doutrina dos apóstolos abre o versículo.",
                    "d": "Comunhão e doutrina estão no mesmo texto.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de Atos 2:42?",
                [
                    ("a", "perseveravam na doutrina dos apóstolos e na comunhão"),
                    ("b", "no partir do pão"),
                    ("c", "e nas orações"),
                ],
                "Certo: persistência no ensino e na comunhão, mesa e oração.",
                {"b": "O pão vem depois da comunhão.", "c": "As orações selam a vida comum."},
                p,
                **k,
            ),
            lambda **k: complete(
                "e perseveravam na doutrina dos apóstolos e na comunhão, no ___ do pão e nas orações",
                [("a", "partir"), ("b", "orações"), ("c", "doutrina")],
                "a",
                "Certo: no partir do pão.",
                {"b": "Orações já está no fim da frase.", "c": "Doutrina já apareceu no começo."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Atos 2:42 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Vida comum perseverante"),
                    ("b", "Doutrina contra a mesa"),
                    ("c", "Orações sem o povo"),
                ],
                "a",
                "Certo: a igreja se forma nessa persistência comum.",
                {"b": "Pão e doutrina estão no mesmo verso.", "c": "As orações são do mesmo perseverar comunitário."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def m3():
    sec = "ec-03-missao"
    vr = "Mateus 28:19–20"
    lo = "Compreender que a igreja é enviada a fazer discípulos das nações, batizando e ensinando, com Jesus presente até o fim."
    ev = ["Mateus 28:19", "Mateus 28:20"]
    p = TB_M3
    insight = "Igreja enviada: discípulos das nações, batismo e ensino — Jesus permanece até o fim."
    meta = dict(trail="eclesiologia", section=sec, verse_ref=vr, lo=lo, evidence=ev)

    def pack(diff, skill, qs):
        return [q(diff=diff, skill=skill, **meta) for q in qs]

    semente = pack(
        "semente",
        "observe",
        [
            lambda **k: tf(
                "Jesus manda ir e fazer discípulos de todas as nações, batizando-as no nome do Pai, do Filho e do Espírito Santo.",
                "true",
                "Certo: Mateus 28:19 afirma esse envio e batismo.",
                "Releia: discípulos de todas as nações e batismo trinitário.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "fazei ___ de todas as nações",
                [("a", "discípulos"), ("b", "mundo"), ("c", "Pai")],
                "a",
                "Exato: fazei discípulos de todas as nações.",
                {"b": "Mundo aparece no fim, com o fim do mundo.", "c": "Pai está no nome do batismo."},
                p,
                **k,
            ),
            lambda **k: choice(
                "O que Mateus 28:19–20 manda fazer às nações?",
                [
                    ("a", "Fazer discípulos, batizando-as e instruindo-as a observar o mandado."),
                    ("b", "Batizar sem ensinar coisa alguma."),
                    ("c", "Fazer discípulos de uma só nação."),
                    ("d", "Partir sem a promessa da presença de Jesus."),
                ],
                "a",
                "Certo: discípulos, batismo, ensino e presença até o fim.",
                {
                    "b": "Há também instruir a observar todas as coisas.",
                    "c": "O texto diz todas as nações.",
                    "d": "Ele está convosco todos os dias até o fim do mundo.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos em Mateus 28:19–20?",
                [
                    ("a", "Ide, pois, e fazei discípulos de todas as nações"),
                    ("b", "batizando-as em o nome do Pai, e do Filho, e do Espírito Santo"),
                    ("c", "instruindo-as a observar todas as coisas que vos tenho mandado"),
                ],
                "Certo: ir, discípulos, batismo, depois o ensino.",
                {"b": "O batismo segue o fazer discípulos.", "c": "A instrução vem após o batismo."},
                p,
                **k,
            ),
            lambda **k: complete(
                "Eis que eu estou convosco todos os dias até o fim do ___",
                [("a", "nações"), ("b", "mundo"), ("c", "Filho")],
                "b",
                "Certo: até o fim do mundo.",
                {"a": "Nações é o alvo dos discípulos, não esta lacuna.", "c": "Filho está no nome do batismo."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Mateus 28:19–20 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Discípulos das nações"),
                    ("b", "Missão sem batismo"),
                    ("c", "Jesus ausente até o fim"),
                ],
                "a",
                "Certo: a igreja é enviada a discipular as nações.",
                {"b": "O batismo está no mesmo mandato.", "c": "Ele está convosco todos os dias."},
                p,
                **k,
            ),
        ],
    )

    caminhada = pack(
        "caminhada",
        "understand",
        [
            lambda **k: tf(
                "Além de batizar, o envio inclui instruir as nações a observar todas as coisas que Jesus mandou.",
                "true",
                "Certo: o v. 20 liga batismo e instrução.",
                "Releia: instruindo-as a observar todas as coisas mandadas.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "batizando-as em o nome do ___, e do Filho, e do Espírito Santo",
                [("a", "Pai"), ("b", "mundo"), ("c", "discípulos")],
                "a",
                "Exato: em o nome do Pai, e do Filho, e do Espírito Santo.",
                {"b": "Mundo pertence à promessa final.", "c": "Discípulos é o que se faz das nações."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como se relacionam batismo, ensino e presença em Mateus 28:19–20?",
                [
                    ("a", "O batismo encerra a missão; o ensino é opcional."),
                    ("b", "Fazer discípulos une batismo e instrução, com Jesus presente até o fim."),
                    ("c", "A presença de Jesus substitui o ir às nações."),
                    ("d", "Observar o mandado cabe só ao Filho, não aos discípulos."),
                ],
                "b",
                "Certo: envio, batismo, ensino e companhia até o fim.",
                {
                    "a": "Instruir a observar vem logo após o batismo.",
                    "c": "Ide e fazei discípulos permanece o mandato.",
                    "d": "Eles devem observar o que Jesus mandou.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de Mateus 28:19–20?",
                [
                    ("a", "fazei discípulos de todas as nações"),
                    ("b", "instruindo-as a observar todas as coisas que vos tenho mandado"),
                    ("c", "Eis que eu estou convosco todos os dias até o fim do mundo"),
                ],
                "Certo: discípulos, instrução, depois a presença até o fim.",
                {"b": "A instrução segue o fazer discípulos.", "c": "A promessa fecha o mandato."},
                p,
                **k,
            ),
            lambda **k: complete(
                "instruindo-as a ___ todas as coisas que vos tenho mandado",
                [("a", "batizando-as"), ("b", "observar"), ("c", "convosco")],
                "b",
                "Certo: instruindo-as a observar.",
                {"a": "Batizando-as vem antes, no v. 19.", "c": "Convosco pertence à promessa final."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Mateus 28:19–20 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Batismo e ensino juntos"),
                    ("b", "Nações sem discípulos"),
                    ("c", "Mandato sem presença"),
                ],
                "a",
                "Certo: discipular inclui batizar e ensinar a observar.",
                {"b": "O alvo é discípulos de todas as nações.", "c": "Ele está convosco todos os dias."},
                p,
                **k,
            ),
        ],
    )

    profundezas = pack(
        "profundezas",
        "interpret",
        [
            lambda **k: tf(
                "A missão às nações permanece até o fim do mundo porque Jesus promete estar convosco todos os dias.",
                "true",
                "Certo: o envio e a presença fecham juntos o mandato.",
                "O v. 20 une o ensino ao 'estou convosco até o fim'.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "Eis que eu estou ___ todos os dias até o fim do mundo",
                [("a", "convosco"), ("b", "nações"), ("c", "Santo")],
                "a",
                "Exato: eu estou convosco todos os dias.",
                {"b": "Nações é o alvo do discipulado.", "c": "Santo qualifica o Espírito no batismo."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual implicação Mateus 28:19–20 impõe à igreja?",
                [
                    ("a", "A igreja pode limitar discípulos a um povo e omitir o ensino."),
                    ("b", "O batismo no nome triúno é extra, se já houver ida geográfica."),
                    ("c", "A igreja enviada discipula as nações sob a permanência de Jesus até o fim."),
                    ("d", "Quando o ensino começa, a presença de Jesus cessa."),
                ],
                "c",
                "Certo: envio universal com a presença até o fim.",
                {
                    "a": "O texto diz todas as nações e observar tudo o mandado.",
                    "b": "O batismo está no centro do mandato.",
                    "d": "A presença dura todos os dias até o fim do mundo.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de Mateus 28:19–20?",
                [
                    ("a", "batizando-as em o nome do Pai, e do Filho, e do Espírito Santo"),
                    ("b", "instruindo-as a observar todas as coisas que vos tenho mandado"),
                    ("c", "eu estou convosco todos os dias até o fim do mundo"),
                ],
                "Certo: batismo, ensino do mandado, presença até o fim.",
                {"b": "A instrução segue o batismo.", "c": "A presença sela o sentido da missão."},
                p,
                **k,
            ),
            lambda **k: complete(
                "e do Filho, e do Espírito ___; instruindo-as a observar",
                [("a", "Santo"), ("b", "mundo"), ("c", "nações")],
                "a",
                "Certo: e do Espírito Santo.",
                {"b": "Mundo fecha a promessa, não o nome do batismo.", "c": "Nações é o alvo dos discípulos."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Mateus 28:19–20 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Jesus permanece até o fim"),
                    ("b", "Missão só até o batismo"),
                    ("c", "Presença sem as nações"),
                ],
                "a",
                "Certo: o enviado permanece com a igreja na missão.",
                {"b": "Há instrução a observar tudo o mandado.", "c": "O alvo continua sendo todas as nações."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def m4():
    sec = "ec-boss"
    vr = "1 Coríntios 12:13; Atos 2:42; Mateus 28:19"
    lo = "Articular o povo de Cristo: um corpo no Espírito, vida comum e missão até as nações."
    ev = ["1 Coríntios 12:13", "Atos 2:42", "Mateus 28:19"]
    p = TB_BOSS
    insight = "Povo de Cristo: um corpo, vida comum e missão até as nações."
    meta = dict(trail="eclesiologia", section=sec, verse_ref=vr, lo=lo, evidence=ev)

    def pack(diff, skill, qs):
        return [q(diff=diff, skill=skill, **meta) for q in qs]

    semente = pack(
        "semente",
        "observe",
        [
            lambda **k: tf(
                "Fomos batizados em um só corpo; perseveravam na doutrina, comunhão, pão e orações; fazei discípulos de todas as nações.",
                "true",
                "Certo: os três textos afirmam corpo, vida comum e envio.",
                "Os três trechos sustentam corpo, persistência e nações.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "Em um só ___, fomos batizados todos nós em um só corpo",
                [("a", "Espírito"), ("b", "comunhão"), ("c", "nações")],
                "a",
                "Exato: em um só Espírito, um só corpo.",
                {"b": "Comunhão pertence a Atos 2:42.", "c": "Nações pertence a Mateus 28:19."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual conjunto o texto combinado afirma diretamente?",
                [
                    ("a", "Um corpo no Espírito, persistência comum e discípulos das nações."),
                    ("b", "Dois corpos, sem comunhão e sem envio."),
                    ("c", "Só orações, sem doutrina apostólica nem batismo."),
                    ("d", "Discípulos de nenhuma nação e corpo só de judeus."),
                ],
                "a",
                "Certo: corpo, vida comum e missão aparecem juntos.",
                {
                    "b": "Há um só corpo, comunhão e o ide às nações.",
                    "c": "Doutrina e batismo estão nos textos.",
                    "d": "Gregos entram no corpo e o envio é a todas as nações.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos nos três textos?",
                [
                    ("a", "Em um só Espírito, fomos batizados todos nós em um só corpo"),
                    ("b", "perseveravam na doutrina dos apóstolos e na comunhão, no partir do pão e nas orações"),
                    ("c", "Ide, pois, e fazei discípulos de todas as nações"),
                ],
                "Certo: um corpo, vida comum, depois o envio.",
                {"b": "Atos 2:42 vem depois do corpo no Espírito.", "c": "Mateus 28:19 fecha com as nações."},
                p,
                **k,
            ),
            lambda **k: complete(
                "fazei discípulos de todas as ___",
                [("a", "nações"), ("b", "orações"), ("c", "escravos")],
                "a",
                "Certo: discípulos de todas as nações.",
                {"b": "Orações está em Atos 2:42.", "c": "Escravos está na lista de 1 Coríntios 12:13."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que 1 Coríntios 12:13; Atos 2:42; Mateus 28:19 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Um corpo e missão"),
                    ("b", "Corpo sem as nações"),
                    ("c", "Comunhão contra o envio"),
                ],
                "a",
                "Certo: povo unido no Espírito e enviado.",
                {"b": "Mateus 28:19 manda discípulos de todas as nações.", "c": "Vida comum e missão convivem nos textos."},
                p,
                **k,
            ),
        ],
    )

    caminhada = pack(
        "caminhada",
        "understand",
        [
            lambda **k: tf(
                "Judeus, gregos, escravos e livres no mesmo corpo convivem, nestes textos, com a persistência comum e o envio às nações.",
                "true",
                "Certo: identidade, vida comum e missão se encadeiam.",
                "Os três trechos ligam inclusão no corpo, Atos 2:42 e o ide.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "perseveravam na ___ dos apóstolos e na comunhão",
                [("a", "doutrina"), ("b", "escravos"), ("c", "Pai")],
                "a",
                "Exato: doutrina dos apóstolos.",
                {"b": "Escravos está em 1 Coríntios 12:13.", "c": "Pai está no batismo de Mateus 28:19."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como se encadeiam corpo, vida comum e envio nestes textos?",
                [
                    ("a", "O corpo no Espírito dispensa comunhão e nações."),
                    ("b", "A igreja unida no Espírito persevera junta e é enviada às nações."),
                    ("c", "O ide às nações cancela a doutrina dos apóstolos."),
                    ("d", "Só judeus formam o corpo; gregos ficam na missão à parte."),
                ],
                "b",
                "Certo: unidade, persistência e envio pertencem ao mesmo povo.",
                {
                    "a": "Atos 2:42 e Mateus 28:19 permanecem.",
                    "c": "A doutrina dos apóstolos é a persistência da igreja.",
                    "d": "Gregos estão no mesmo corpo do v. 13.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de 1 Coríntios 12:13; Atos 2:42; Mateus 28:19?",
                [
                    ("a", "quer judeus, quer gregos, quer escravos, quer livres"),
                    ("b", "no partir do pão e nas orações"),
                    ("c", "batizando-as em o nome do Pai, e do Filho, e do Espírito Santo"),
                ],
                "Certo: inclusão no corpo, mesa e oração, batismo das nações.",
                {"b": "O pão está na vida comum de Atos.", "c": "O batismo das nações fecha Mateus 28:19."},
                p,
                **k,
            ),
            lambda **k: complete(
                "fomos batizados todos nós em um só ___",
                [("a", "corpo"), ("b", "orações"), ("c", "Pai")],
                "a",
                "Certo: em um só corpo.",
                {"b": "Orações está em Atos 2:42.", "c": "Pai está no nome do batismo em Mateus."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que 1 Coríntios 12:13; Atos 2:42; Mateus 28:19 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Identidade sem envio"),
                    ("b", "Vida comum e nações"),
                    ("c", "Espírito só para um povo"),
                ],
                "b",
                "Certo: persistência comum e discípulos das nações.",
                {"a": "Mateus 28:19 envia às nações.", "c": "Judeus e gregos bebem dum só Espírito."},
                p,
                **k,
            ),
        ],
    )

    profundezas = pack(
        "profundezas",
        "interpret",
        [
            lambda **k: tf(
                "A igreja é só um corpo fechado, sem perseverança comum e sem envio às nações.",
                "false",
                "Certo: os textos unem corpo, vida comum e missão.",
                "Atos 2:42 e Mateus 28:19 impedem essa redução.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "no partir do ___ e nas orações",
                [("a", "pão"), ("b", "livres"), ("c", "Filho")],
                "a",
                "Exato: no partir do pão e nas orações.",
                {"b": "Livres está em 1 Coríntios 12:13.", "c": "Filho está no nome do batismo."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual leitura destes três textos descreve o povo de Cristo?",
                [
                    ("a", "Clube privado, sem Espírito comum nem nações."),
                    ("b", "Missão geográfica sem corpo e sem doutrina."),
                    ("c", "Povo um no Espírito, que vive junto e discipula as nações."),
                    ("d", "Batismo trinitário no lugar da comunhão e do único corpo."),
                ],
                "c",
                "Certo: um corpo, vida comum e missão até as nações.",
                {
                    "a": "Há um Espírito, comunhão e o ide.",
                    "b": "O corpo e a doutrina dos apóstolos estão no conjunto.",
                    "d": "Os três eixos permanecem juntos, sem se anular.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de 1 Coríntios 12:13; Atos 2:42; Mateus 28:19?",
                [
                    ("a", "a todos nós foi dado beber dum só Espírito"),
                    ("b", "perseveravam na doutrina dos apóstolos e na comunhão"),
                    ("c", "fazei discípulos de todas as nações"),
                ],
                "Certo: um Espírito, vida comum, discípulos das nações.",
                {"b": "A persistência de Atos segue o único Espírito.", "c": "O envio às nações revela o alcance do povo."},
                p,
                **k,
            ),
            lambda **k: complete(
                "batizando-as em o nome do Pai, e do Filho, e do Espírito ___",
                [("a", "Santo"), ("b", "apóstolos"), ("c", "gregos")],
                "a",
                "Certo: e do Espírito Santo.",
                {"b": "Apóstolos qualifica a doutrina em Atos.", "c": "Gregos está na lista do único corpo."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que 1 Coríntios 12:13; Atos 2:42; Mateus 28:19 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Povo de Cristo enviado"),
                    ("b", "Corpo contra as nações"),
                    ("c", "Vida comum sem o Espírito"),
                ],
                "a",
                "Certo: um corpo, vida comum e missão até as nações.",
                {"b": "O ide é de todas as nações.", "c": "O corpo bebe dum só Espírito."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def main():
    questions = m1() + m2() + m3() + m4()
    assert len(questions) == 72, len(questions)
    ids = [q["id"] for q in questions]
    assert len(ids) == len(set(ids))
    out = Path(__file__).with_name("eclesiologia.json")
    out.write_text(json.dumps(questions, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{out} {len(questions)}")


if __name__ == "__main__":
    main()
