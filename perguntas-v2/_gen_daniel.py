#!/usr/bin/env python3
"""Gera perguntas-v2/daniel.json (90 perguntas, 5 missões)."""
import json
from pathlib import Path

TB_M1 = (
    "Daniel, porém, assentou no seu coração não se contaminar com as iguarias reais "
    "nem com o vinho que o rei bebia; portanto, pediu ao príncipe dos eunucos que lhe "
    "permitisse não contaminar-se."
)
TB_M2 = (
    "Se assim for, o nosso Deus, a quem nós servimos, pode livrar-nos da fornalha de "
    "fogo ardente; e ele há de nos livrar das tuas mãos, ó rei. Mas, se não, fica tu "
    "sabendo, ó rei, que não havemos de servir aos teus deuses, nem adorar a imagem de "
    "ouro que levantaste."
)
TB_M3 = (
    "O meu Deus enviou o seu Anjo e fechou as bocas aos leões; eles não me fizeram mal "
    "algum, porque foi achada em mim inocência diante dele; também diante de ti, ó rei, "
    "não tenho cometido delito algum."
)
TB_M4 = (
    "Nos dias desses reis, suscitará o Deus do céu um reino que não será jamais "
    "destruído, nem passará a soberania deste a outro povo; mas fará em pedaços e "
    "consumirá todos esses reinos, e ele mesmo subsistirá para sempre,"
)
TB_318 = (
    "Mas, se não, fica tu sabendo, ó rei, que não havemos de servir aos teus deuses, "
    "nem adorar a imagem de ouro que levantaste."
)
TB_BOSS = f"{TB_M1} {TB_M4} {TB_318}"

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


def pack(meta, diff, skill, qs):
    return [q(diff=diff, skill=skill, **meta) for q in qs]


def m1():
    sec = "daniel-palacio-01-proposito-no-coracao"
    vr = "Daniel 1:8"
    lo = "Reconhecer que Daniel assentou no coração não contaminar-se com as iguarias reais nem com o vinho do rei, e pediu isso ao príncipe dos eunucos."
    ev = ["Daniel 1:8"]
    p = TB_M1
    insight = "Propósito no coração: no palácio, Daniel recusa contaminar-se — fidelidade começa na mesa."
    meta = dict(trail="daniel", section=sec, verse_ref=vr, lo=lo, evidence=ev)

    semente = pack(
        meta,
        "semente",
        "observe",
        [
            lambda **k: tf(
                "Daniel assentou no seu coração não se contaminar com as iguarias reais nem com o vinho que o rei bebia.",
                "true",
                "Certo: esse é o propósito registrado em Daniel 1:8.",
                "Releia: ele assentou no coração não contaminar-se com iguarias e vinho.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "Daniel, porém, assentou no seu ___ não se contaminar",
                [("a", "coração"), ("b", "vinho"), ("c", "príncipe")],
                "a",
                "Exato: o propósito foi assentado no coração.",
                {"b": "Vinho é o que o rei bebia, não onde Daniel assentou o propósito.", "c": "Príncipe aparece no pedido, não nesta lacuna."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual afirmação o texto faz diretamente em Daniel 1:8?",
                [
                    ("a", "Daniel pediu ao príncipe dos eunucos que lhe permitisse não contaminar-se."),
                    ("b", "Daniel aceitou as iguarias reais sem recusa."),
                    ("c", "O rei proibiu Daniel de beber o vinho da corte."),
                    ("d", "O príncipe dos eunucos recusou ouvir qualquer pedido."),
                ],
                "a",
                "Certo: o pedido é para não contaminar-se.",
                {
                    "b": "O texto diz que ele não quis contaminar-se com as iguarias.",
                    "c": "Quem recusa o vinho é Daniel, não o rei.",
                    "d": "O texto registra o pedido, não a recusa do príncipe.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos em Daniel 1:8?",
                [
                    ("a", "Daniel, porém, assentou no seu coração não se contaminar"),
                    ("b", "com as iguarias reais nem com o vinho que o rei bebia"),
                    ("c", "portanto, pediu ao príncipe dos eunucos que lhe permitisse não contaminar-se"),
                ],
                "Certo: propósito, recusa da mesa, depois o pedido.",
                {"b": "As iguarias e o vinho vêm depois do propósito no coração.", "c": "O pedido ao príncipe fecha o versículo."},
                p,
                **k,
            ),
            lambda **k: complete(
                "não se ___ com as iguarias reais nem com o vinho que o rei bebia",
                [("a", "contaminar"), ("b", "assentou"), ("c", "eunucos")],
                "a",
                "Certo: não se contaminar com iguarias nem vinho.",
                {"b": "Assentou descreve o propósito, não esta lacuna.", "c": "Eunucos qualifica o príncipe, não o verbo."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 1:8 comunica que se liga a este contexto?",
                "Daniel, porém, assentou no seu coração não se contaminar com as iguarias reais nem com o vinho que o rei bebia",
                insight,
                [
                    ("a", "Fidelidade começa na mesa"),
                    ("b", "A mesa do rei é neutra"),
                    ("c", "Propósito sem recusa"),
                ],
                "a",
                "Certo: no palácio, a fidelidade começa na mesa.",
                {"b": "Daniel recusa contaminar-se com as iguarias reais.", "c": "O propósito vira pedido concreto de não contaminar-se."},
                p,
                **k,
            ),
        ],
    )

    caminhada = pack(
        meta,
        "caminhada",
        "understand",
        [
            lambda **k: tf(
                "O propósito de Daniel ficou só no íntimo: ele não pediu nada ao príncipe dos eunucos.",
                "false",
                "Certo: o texto liga o coração ao pedido concreto.",
                "Releia: portanto, pediu ao príncipe dos eunucos.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "nem com o ___ que o rei bebia",
                [("a", "vinho"), ("b", "coração"), ("c", "príncipe")],
                "a",
                "Exato: o vinho que o rei bebia.",
                {"b": "Coração é o lugar do propósito, não o que o rei bebia.", "c": "Príncipe recebe o pedido, não preenche esta lacuna."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como Daniel 1:8 liga o propósito interior à mesa do palácio?",
                [
                    ("a", "O coração decide, mas a mesa do rei não tem peso de fidelidade."),
                    ("b", "O propósito no coração recusa contaminar-se e vira pedido à autoridade da corte."),
                    ("c", "Daniel recusa o vinho para insultar o rei, não por temor de contaminar-se."),
                    ("d", "O príncipe dos eunucos impôs a dieta; Daniel apenas obedeceu."),
                ],
                "b",
                "Certo: coração, recusa da mesa e pedido se encadeiam.",
                {
                    "a": "O texto trata iguarias e vinho como risco de contaminar-se.",
                    "c": "O motivo citado é não contaminar-se, não insulto.",
                    "d": "Quem pede permissão é Daniel, não o príncipe.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de Daniel 1:8?",
                [
                    ("a", "assentou no seu coração"),
                    ("b", "não se contaminar com as iguarias reais nem com o vinho"),
                    ("c", "pediu ao príncipe dos eunucos que lhe permitisse não contaminar-se"),
                ],
                "Certo: decisão, recusa da mesa, pedido de permissão.",
                {"b": "A recusa da mesa segue o propósito no coração.", "c": "O pedido ao príncipe é a consequência."},
                p,
                **k,
            ),
            lambda **k: complete(
                "pediu ao príncipe dos ___ que lhe permitisse não contaminar-se",
                [("a", "eunucos"), ("b", "iguarias"), ("c", "vinho")],
                "a",
                "Certo: o pedido vai ao príncipe dos eunucos.",
                {"b": "Iguarias são o que ele recusa, não o cargo.", "c": "Vinho é o que o rei bebia, não o destinatário."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 1:8 comunica que se liga a este contexto?",
                "portanto, pediu ao príncipe dos eunucos que lhe permitisse não contaminar-se",
                insight,
                [
                    ("a", "Pedido que guarda o coração"),
                    ("b", "Aceitação das iguarias"),
                    ("c", "Silêncio diante da corte"),
                ],
                "a",
                "Certo: o propósito vira pedido para não contaminar-se.",
                {"b": "Ele pede permissão para recusar, não para aceitar.", "c": "O texto registra o pedido ao príncipe."},
                p,
                **k,
            ),
        ],
    )

    profundezas = pack(
        meta,
        "profundezas",
        "interpret",
        [
            lambda **k: tf(
                "No palácio, a fidelidade de Daniel começa no coração e se mede na recusa de contaminar-se à mesa do rei.",
                "true",
                "Certo: propósito no coração e recusa da mesa andam juntos.",
                "O texto une coração, iguarias, vinho e o pedido de não contaminar-se.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "não se contaminar com as iguarias ___ nem com o vinho",
                [("a", "reais"), ("b", "eunucos"), ("c", "permitisse")],
                "a",
                "Exato: as iguarias reais.",
                {"b": "Eunucos qualifica o príncipe, não as iguarias.", "c": "Permitisse fecha o pedido, não esta lacuna."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual leitura teológica Daniel 1:8 sustenta sobre o exílio?",
                [
                    ("a", "No palácio, o alimento do rei é irrelevante para a aliança."),
                    ("b", "Basta um propósito secreto; não é preciso recusar a mesa."),
                    ("c", "A fidelidade no exílio começa no coração e se recusa a contaminar-se à mesa do império."),
                    ("d", "Contaminar-se é só risco político, sem peso diante de Deus."),
                ],
                "c",
                "Certo: coração e mesa revelam fidelidade no palácio.",
                {
                    "a": "O texto trata iguarias e vinho como risco de contaminar-se.",
                    "b": "O propósito vira pedido explícito de não contaminar-se.",
                    "d": "Daniel pede não contaminar-se diante da mesa real.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de Daniel 1:8?",
                [
                    ("a", "assentou no seu coração"),
                    ("b", "não se contaminar com as iguarias reais nem com o vinho que o rei bebia"),
                    ("c", "pediu ao príncipe dos eunucos que lhe permitisse não contaminar-se"),
                ],
                "Certo: propósito, recusa da mesa, pedido que a guarda.",
                {"b": "A mesa do rei revela o que o coração assentou.", "c": "O pedido torna pública a recusa de contaminar-se."},
                p,
                **k,
            ),
            lambda **k: complete(
                "com o vinho que o rei ___",
                [("a", "bebia"), ("b", "assentou"), ("c", "príncipe")],
                "a",
                "Certo: o vinho que o rei bebia.",
                {"b": "Assentou descreve Daniel, não o rei nesta frase.", "c": "Príncipe recebe o pedido, não o verbo."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 1:8 comunica que se liga a este contexto?",
                "Daniel, porém, assentou no seu coração não se contaminar",
                insight,
                [
                    ("a", "Coração que não se contamina"),
                    ("b", "Mesa sem aliança"),
                    ("c", "Fidelidade só no templo"),
                ],
                "a",
                "Certo: a fidelidade no palácio começa no coração.",
                {"b": "A mesa do rei é o lugar da recusa de contaminar-se.", "c": "O palácio, não só o templo, exige propósito."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def m2():
    sec = "daniel-palacio-02-a-fornalha"
    vr = "Daniel 3:17–18"
    lo = "Confessar que o Deus a quem servem pode livrar da fornalha, e que, mesmo se não, eles não servirão aos deuses do rei nem adorarão a imagem."
    ev = ["Daniel 3:17", "Daniel 3:18"]
    p = TB_M2
    insight = "A fornalha: Deus pode livrar — e mesmo se não, eles não adoram a imagem."
    meta = dict(trail="daniel", section=sec, verse_ref=vr, lo=lo, evidence=ev)

    semente = pack(
        meta,
        "semente",
        "observe",
        [
            lambda **k: tf(
                "O nosso Deus, a quem nós servimos, pode livrar-nos da fornalha de fogo ardente.",
                "true",
                "Certo: Daniel 3:17 afirma exatamente essa possibilidade.",
                "Releia: Deus pode livrar-nos da fornalha de fogo ardente.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "pode livrar-nos da ___ de fogo ardente",
                [("a", "fornalha"), ("b", "imagem"), ("c", "deuses")],
                "a",
                "Exato: a fornalha de fogo ardente.",
                {"b": "Imagem aparece na recusa de adorar, não nesta lacuna.", "c": "Deuses são os do rei, não o lugar do livramento."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual afirmação o texto faz diretamente em Daniel 3:17–18?",
                [
                    ("a", "Não havemos de servir aos teus deuses, nem adorar a imagem de ouro que levantaste."),
                    ("b", "Eles prometem adorar a imagem se o fogo for intenso."),
                    ("c", "Deus não pode livrar ninguém da fornalha."),
                    ("d", "O rei já havia derrubado a imagem de ouro."),
                ],
                "a",
                "Certo: a recusa de servir e adorar fecha o trecho.",
                {
                    "b": "O texto recusa servir aos deuses e adorar a imagem.",
                    "c": "O v. 17 diz que Deus pode livrar da fornalha.",
                    "d": "A imagem é a que o rei levantou, ainda de pé.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos em Daniel 3:17–18?",
                [
                    ("a", "o nosso Deus, a quem nós servimos, pode livrar-nos da fornalha de fogo ardente"),
                    ("b", "e ele há de nos livrar das tuas mãos, ó rei"),
                    ("c", "Mas, se não, fica tu sabendo, ó rei, que não havemos de servir aos teus deuses"),
                ],
                "Certo: pode livrar, há de livrar, e mesmo se não.",
                {"b": "O livramento das mãos do rei segue a fornalha.", "c": "O \"se não\" fecha com a recusa de adorar."},
                p,
                **k,
            ),
            lambda **k: complete(
                "nem adorar a ___ de ouro que levantaste",
                [("a", "imagem"), ("b", "fornalha"), ("c", "mãos")],
                "a",
                "Certo: a imagem de ouro que o rei levantou.",
                {"b": "Fornalha é o fogo, não o objeto da adoração.", "c": "Mãos são as do rei no livramento, não a imagem."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 3:17–18 comunica que se liga a este contexto?",
                "Mas, se não, fica tu sabendo, ó rei, que não havemos de servir aos teus deuses, nem adorar a imagem de ouro que levantaste",
                insight,
                [
                    ("a", "Livrar ou não, sem imagem"),
                    ("b", "Adorar para escapar"),
                    ("c", "Servir aos deuses do rei"),
                ],
                "a",
                "Certo: Deus pode livrar — e mesmo se não, sem imagem.",
                {"b": "O texto recusa adorar a imagem mesmo se não houver livramento.", "c": "Eles não hão de servir aos deuses do rei."},
                p,
                **k,
            ),
        ],
    )

    caminhada = pack(
        meta,
        "caminhada",
        "understand",
        [
            lambda **k: tf(
                "A recusa de servir aos deuses do rei depende de o livramento da fornalha já ter acontecido.",
                "false",
                "Certo: o \"se não\" mantém a recusa mesmo sem livramento.",
                "O v. 18 recusa servir e adorar mesmo se Deus não livrar.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "não havemos de ___ aos teus deuses",
                [("a", "servir"), ("b", "livrar"), ("c", "levantaste")],
                "a",
                "Exato: não hão de servir aos deuses do rei.",
                {"b": "Livrar é o que Deus pode fazer, não o verbo da recusa.", "c": "Levantaste descreve a imagem, não esta lacuna."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como Daniel 3:17–18 relaciona o poder de Deus e a recusa da imagem?",
                [
                    ("a", "Se Deus não livrar, a adoração da imagem se torna lícita."),
                    ("b", "Deus pode livrar; mesmo se não, eles não servem aos deuses nem adoram a imagem."),
                    ("c", "O livramento das mãos do rei dispensa servir a Deus."),
                    ("d", "A fornalha prova que o Deus a quem servem é impotente."),
                ],
                "b",
                "Certo: poder de livrar e recusa incondicional andam juntos.",
                {
                    "a": "O \"se não\" reforça a recusa, não a anula.",
                    "c": "Eles servem a Deus, não aos deuses do rei.",
                    "d": "O v. 17 afirma que Deus pode livrar da fornalha.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de Daniel 3:17–18?",
                [
                    ("a", "pode livrar-nos da fornalha de fogo ardente"),
                    ("b", "ele há de nos livrar das tuas mãos, ó rei"),
                    ("c", "não havemos de servir aos teus deuses, nem adorar a imagem de ouro"),
                ],
                "Certo: pode, há de livrar, e a recusa permanece.",
                {"b": "O livramento das mãos segue a fornalha.", "c": "A recusa da imagem fecha o encadeamento."},
                p,
                **k,
            ),
            lambda **k: complete(
                "fica tu sabendo, ó rei, que não havemos de servir aos teus ___",
                [("a", "deuses"), ("b", "fornalha"), ("c", "fogo")],
                "a",
                "Certo: não hão de servir aos deuses do rei.",
                {"b": "Fornalha é o perigo, não o objeto do serviço.", "c": "Fogo descreve a fornalha, não os deuses."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 3:17–18 comunica que se liga a este contexto?",
                "o nosso Deus, a quem nós servimos, pode livrar-nos da fornalha de fogo ardente",
                insight,
                [
                    ("a", "Serviço sem barganha"),
                    ("b", "Fogo que obriga a imagem"),
                    ("c", "Deuses do rei no centro"),
                ],
                "a",
                "Certo: servem a Deus; o livramento não compra a imagem.",
                {"b": "Mesmo se não livrar, eles não adoram a imagem.", "c": "Eles recusam os deuses do rei."},
                p,
                **k,
            ),
        ],
    )

    profundezas = pack(
        meta,
        "profundezas",
        "interpret",
        [
            lambda **k: tf(
                "A fé da fornalha confessa o poder de Deus e recusa a imagem mesmo sem garantia de livramento.",
                "true",
                "Certo: \"pode\" e \"se não\" formam a mesma confissão.",
                "O texto une o poder de livrar à recusa incondicional da imagem.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "nem adorar a imagem de ___ que levantaste",
                [("a", "ouro"), ("b", "fogo"), ("c", "mãos")],
                "a",
                "Exato: a imagem de ouro que o rei levantou.",
                {"b": "Fogo descreve a fornalha, não a imagem.", "c": "Mãos são as do rei no livramento."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual leitura de Daniel 3:17–18 descreve o sentido da fornalha?",
                [
                    ("a", "Deus só é Deus se livrar; sem milagre, a imagem merece adoração."),
                    ("b", "Servir a Deus e adorar a imagem de ouro podem coexistir no palácio."),
                    ("c", "Deus pode livrar — e a lealdade permanece mesmo se o livramento não vier."),
                    ("d", "A fornalha anula o serviço a Deus e entrega os três ao rei."),
                ],
                "c",
                "Certo: poder de livrar sem barganha com a imagem.",
                {
                    "a": "O \"se não\" recusa a imagem mesmo sem livramento.",
                    "b": "Eles não hão de servir aos deuses nem adorar a imagem.",
                    "d": "Eles continuam servindo ao Deus que pode livrar.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de Daniel 3:17–18?",
                [
                    ("a", "o nosso Deus, a quem nós servimos"),
                    ("b", "pode livrar-nos da fornalha de fogo ardente"),
                    ("c", "Mas, se não, não havemos de servir aos teus deuses, nem adorar a imagem de ouro"),
                ],
                "Certo: serviço a Deus, poder de livrar, recusa da imagem.",
                {"b": "O poder de livrar segue o Deus a quem servem.", "c": "O \"se não\" revela lealdade sem barganha."},
                p,
                **k,
            ),
            lambda **k: complete(
                "ele há de nos livrar das tuas ___, ó rei",
                [("a", "mãos"), ("b", "deuses"), ("c", "imagem")],
                "a",
                "Certo: livrar das mãos do rei.",
                {"b": "Deuses são os que eles recusam servir.", "c": "Imagem é o que não hão de adorar."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 3:17–18 comunica que se liga a este contexto?",
                "pode livrar-nos da fornalha de fogo ardente; e ele há de nos livrar das tuas mãos, ó rei. Mas, se não",
                insight,
                [
                    ("a", "Deus pode — mesmo se não"),
                    ("b", "Imagem acima de Deus"),
                    ("c", "Livramento como condição"),
                ],
                "a",
                "Certo: o poder de livrar não compra a adoração.",
                {"b": "Eles recusam a imagem de ouro.", "c": "O \"se não\" mantém a recusa sem condição."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def m3():
    sec = "daniel-palacio-03-a-cova-dos-leoes"
    vr = "Daniel 6:22"
    lo = "Reconhecer que Deus enviou o Anjo e fechou as bocas dos leões porque foi achada inocência em Daniel diante dele, e que ele não cometeu delito diante do rei."
    ev = ["Daniel 6:22"]
    p = TB_M3
    insight = "A cova: o Anjo fecha a boca dos leões — inocência diante de Deus, não sorte."
    meta = dict(trail="daniel", section=sec, verse_ref=vr, lo=lo, evidence=ev)

    semente = pack(
        meta,
        "semente",
        "observe",
        [
            lambda **k: tf(
                "O meu Deus enviou o seu Anjo e fechou as bocas aos leões.",
                "true",
                "Certo: Daniel 6:22 atribui o livramento ao Anjo de Deus.",
                "Releia: Deus enviou o Anjo e fechou as bocas aos leões.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "enviou o seu ___ e fechou as bocas aos leões",
                [("a", "Anjo"), ("b", "rei"), ("c", "delito")],
                "a",
                "Exato: Deus enviou o seu Anjo.",
                {"b": "Rei é a quem Daniel se dirige, não quem fecha as bocas.", "c": "Delito aparece no fim, na recusa de culpa."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual afirmação o texto faz diretamente em Daniel 6:22?",
                [
                    ("a", "Eles não me fizeram mal algum, porque foi achada em mim inocência diante dele."),
                    ("b", "Os leões o feriram, mas o rei o libertou depois."),
                    ("c", "Daniel confessou delito diante do rei."),
                    ("d", "Nenhum Anjo interveio na cova."),
                ],
                "a",
                "Certo: sem mal, por inocência diante de Deus.",
                {
                    "b": "O texto diz que os leões não lhe fizeram mal algum.",
                    "c": "Ele afirma não ter cometido delito algum diante do rei.",
                    "d": "Deus enviou o seu Anjo e fechou as bocas.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos em Daniel 6:22?",
                [
                    ("a", "O meu Deus enviou o seu Anjo e fechou as bocas aos leões"),
                    ("b", "eles não me fizeram mal algum, porque foi achada em mim inocência diante dele"),
                    ("c", "também diante de ti, ó rei, não tenho cometido delito algum"),
                ],
                "Certo: Anjo, bocas fechadas, inocência e ausência de delito.",
                {"b": "A inocência explica por que não houve mal.", "c": "A declaração ao rei fecha o versículo."},
                p,
                **k,
            ),
            lambda **k: complete(
                "fechou as bocas aos ___",
                [("a", "leões"), ("b", "Anjo"), ("c", "rei")],
                "a",
                "Certo: fechou as bocas aos leões.",
                {"b": "Anjo é quem Deus enviou, não quem tem as bocas.", "c": "Rei ouve a declaração, não preenche esta lacuna."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 6:22 comunica que se liga a este contexto?",
                "O meu Deus enviou o seu Anjo e fechou as bocas aos leões",
                insight,
                [
                    ("a", "Anjo fecha as bocas"),
                    ("b", "Sorte na cova"),
                    ("c", "Leões sem intervenção"),
                ],
                "a",
                "Certo: o Anjo fecha as bocas — não é sorte.",
                {"b": "O texto atribui o livramento a Deus e ao Anjo.", "c": "As bocas foram fechadas; não houve mal."},
                p,
                **k,
            ),
        ],
    )

    caminhada = pack(
        meta,
        "caminhada",
        "understand",
        [
            lambda **k: tf(
                "Os leões não fizeram mal a Daniel porque foi achada nele inocência diante de Deus.",
                "true",
                "Certo: o texto liga a ausência de mal à inocência.",
                "Releia: não me fizeram mal algum, porque foi achada inocência.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "foi achada em mim ___ diante dele",
                [("a", "inocência"), ("b", "bocas"), ("c", "leões")],
                "a",
                "Exato: inocência diante dele.",
                {"b": "Bocas são as dos leões, fechadas pelo Anjo.", "c": "Leões não preenchem a qualidade achada em Daniel."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como Daniel 6:22 relaciona o livramento da cova e a inocência?",
                [
                    ("a", "O Anjo fecha as bocas por acaso, sem relação com inocência."),
                    ("b", "Não houve mal por inocência diante de Deus; tampouco delito diante do rei."),
                    ("c", "Daniel admite delito diante do rei, mas Deus o poupa mesmo assim."),
                    ("d", "Os leões o pouparam por ordem do próprio rei, sem Anjo."),
                ],
                "b",
                "Certo: inocência diante de Deus e ausência de delito diante do rei.",
                {
                    "a": "O texto explica o livramento pela inocência achada nele.",
                    "c": "Ele afirma não ter cometido delito algum diante do rei.",
                    "d": "Quem enviou o Anjo foi o Deus de Daniel.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de Daniel 6:22?",
                [
                    ("a", "Deus enviou o seu Anjo"),
                    ("b", "fechou as bocas aos leões; eles não me fizeram mal algum"),
                    ("c", "foi achada em mim inocência diante dele"),
                ],
                "Certo: envio, bocas fechadas, inocência como razão.",
                {"b": "As bocas fechadas seguem o envio do Anjo.", "c": "A inocência explica por que não houve mal."},
                p,
                **k,
            ),
            lambda **k: complete(
                "não tenho cometido ___ algum",
                [("a", "delito"), ("b", "Anjo"), ("c", "mal")],
                "a",
                "Certo: não cometido delito algum diante do rei.",
                {"b": "Anjo é o enviado, não o que Daniel comete.", "c": "Mal descreve o que os leões não fizeram."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 6:22 comunica que se liga a este contexto?",
                "eles não me fizeram mal algum, porque foi achada em mim inocência diante dele",
                insight,
                [
                    ("a", "Inocência, não sorte"),
                    ("b", "Culpa diante de Deus"),
                    ("c", "Delito confessado ao rei"),
                ],
                "a",
                "Certo: o livramento se liga à inocência achada nele.",
                {"b": "Foi achada inocência, não culpa, diante de Deus.", "c": "Ele nega delito diante do rei."},
                p,
                **k,
            ),
        ],
    )

    profundezas = pack(
        meta,
        "profundezas",
        "interpret",
        [
            lambda **k: tf(
                "A cova dos leões revela livramento por inocência diante de Deus, não um acaso da natureza dos animais.",
                "true",
                "Certo: Anjo, bocas fechadas e inocência interpretam a cova.",
                "O texto atribui o fato a Deus, ao Anjo e à inocência achada.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "eles não me fizeram ___ algum",
                [("a", "mal"), ("b", "Anjo"), ("c", "inocência")],
                "a",
                "Exato: não me fizeram mal algum.",
                {"b": "Anjo é o enviado que fecha as bocas.", "c": "Inocência é o que foi achado em Daniel."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual leitura de Daniel 6:22 descreve o sentido da cova?",
                [
                    ("a", "Deus fecha as bocas por sorte, sem juízo sobre a vida de Daniel."),
                    ("b", "A inocência diante de Deus e a ausência de delito diante do rei interpretam o livramento."),
                    ("c", "O Anjo prova que Daniel era culpado e precisava de perdão animal."),
                    ("d", "O rei é o salvador da cova; Deus apenas observa."),
                ],
                "b",
                "Certo: inocência diante de Deus, sem delito diante do rei.",
                {
                    "a": "O texto liga o fato à inocência achada nele.",
                    "c": "Foi achada inocência, não culpa, diante dele.",
                    "d": "O meu Deus enviou o Anjo; o rei ouve a declaração.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de Daniel 6:22?",
                [
                    ("a", "O meu Deus enviou o seu Anjo e fechou as bocas aos leões"),
                    ("b", "foi achada em mim inocência diante dele"),
                    ("c", "também diante de ti, ó rei, não tenho cometido delito algum"),
                ],
                "Certo: ação de Deus, inocência diante dele, retidão diante do rei.",
                {"b": "A inocência interpreta por que não houve mal.", "c": "A declaração ao rei mostra que não houve delito."},
                p,
                **k,
            ),
            lambda **k: complete(
                "também diante de ti, ó ___, não tenho cometido delito algum",
                [("a", "rei"), ("b", "Anjo"), ("c", "leões")],
                "a",
                "Certo: diante de ti, ó rei.",
                {"b": "Anjo é o enviado de Deus, não o vocativo.", "c": "Leões têm as bocas fechadas, não ouvem a declaração."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 6:22 comunica que se liga a este contexto?",
                "foi achada em mim inocência diante dele; também diante de ti, ó rei, não tenho cometido delito algum",
                insight,
                [
                    ("a", "Inocência diante de Deus"),
                    ("b", "Sorte dos leões"),
                    ("c", "Delito diante do rei"),
                ],
                "a",
                "Certo: a cova revela inocência, não acaso.",
                {"b": "Deus enviou o Anjo e fechou as bocas.", "c": "Daniel nega delito diante do rei."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def m4():
    sec = "daniel-reinos-01-o-sonho-da-estatua"
    vr = "Daniel 2:44"
    lo = "Confessar que o Deus do céu suscita um reino que não será jamais destruído, não passa a outro povo, despedaça os reinos e subsiste para sempre."
    ev = ["Daniel 2:44"]
    p = TB_M4
    insight = "O sonho da estátua: o reino de Deus despedaça os impérios e permanece para sempre."
    meta = dict(trail="daniel", section=sec, verse_ref=vr, lo=lo, evidence=ev)

    semente = pack(
        meta,
        "semente",
        "observe",
        [
            lambda **k: tf(
                "Nos dias desses reis, suscitará o Deus do céu um reino que não será jamais destruído.",
                "true",
                "Certo: Daniel 2:44 afirma esse reino sem destruição.",
                "Releia: um reino que não será jamais destruído.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "suscitará o Deus do céu um ___ que não será jamais destruído",
                [("a", "reino"), ("b", "povo"), ("c", "pedaços")],
                "a",
                "Exato: um reino que não será jamais destruído.",
                {"b": "Povo aparece na soberania que não passa a outro.", "c": "Pedaços é o que o reino faz aos impérios."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual afirmação o texto faz diretamente em Daniel 2:44?",
                [
                    ("a", "Nem passará a soberania deste a outro povo."),
                    ("b", "Esse reino será destruído como os demais."),
                    ("c", "A soberania passará em breve a outro povo."),
                    ("d", "Os reis suscitarão o reino, não o Deus do céu."),
                ],
                "a",
                "Certo: a soberania não passa a outro povo.",
                {
                    "b": "O texto diz que não será jamais destruído.",
                    "c": "A soberania não passará a outro povo.",
                    "d": "Quem suscita o reino é o Deus do céu.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos em Daniel 2:44?",
                [
                    ("a", "Nos dias desses reis, suscitará o Deus do céu um reino que não será jamais destruído"),
                    ("b", "nem passará a soberania deste a outro povo"),
                    ("c", "mas fará em pedaços e consumirá todos esses reinos, e ele mesmo subsistirá para sempre"),
                ],
                "Certo: reino suscitado, soberania permanente, impérios despedaçados.",
                {"b": "A soberania que não passa vem depois do reino suscitado.", "c": "Despedaçar e subsistirá fecha o versículo."},
                p,
                **k,
            ),
            lambda **k: complete(
                "nem passará a ___ deste a outro povo",
                [("a", "soberania"), ("b", "céu"), ("c", "reis")],
                "a",
                "Certo: a soberania não passa a outro povo.",
                {"b": "Céu qualifica a Deus, não o que passa.", "c": "Reis marca os dias, não esta lacuna."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 2:44 comunica que se liga a este contexto?",
                "suscitará o Deus do céu um reino que não será jamais destruído",
                insight,
                [
                    ("a", "Reino que permanece"),
                    ("b", "Império que se transfere"),
                    ("c", "Reino logo destruído"),
                ],
                "a",
                "Certo: o reino de Deus permanece para sempre.",
                {"b": "A soberania não passará a outro povo.", "c": "Não será jamais destruído."},
                p,
                **k,
            ),
        ],
    )

    caminhada = pack(
        meta,
        "caminhada",
        "understand",
        [
            lambda **k: tf(
                "O reino que o Deus do céu suscita passará a soberania a outro povo, como os demais impérios.",
                "false",
                "Certo: a soberania deste não passa a outro povo.",
                "Releia: nem passará a soberania deste a outro povo.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "fará em ___ e consumirá todos esses reinos",
                [("a", "pedaços"), ("b", "céu"), ("c", "povo")],
                "a",
                "Exato: fará em pedaços e consumirá.",
                {"b": "Céu qualifica a Deus, não o ato contra os reinos.", "c": "Povo é a quem a soberania não passa."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como Daniel 2:44 relaciona o reino de Deus e os reinos dos dias desses reis?",
                [
                    ("a", "O reino de Deus coexiste em igualdade e transfere a soberania aos impérios."),
                    ("b", "Deus suscita um reino permanente que despedaça e consome esses reinos."),
                    ("c", "Os reis suscitarão o reino de Deus depois de consolidar os seus."),
                    ("d", "O reino de Deus será destruído quando esses reinos se unirem."),
                ],
                "b",
                "Certo: reino permanente que consome os demais.",
                {
                    "a": "A soberania não passa a outro povo; os reinos são consumidos.",
                    "c": "Quem suscita é o Deus do céu, nos dias desses reis.",
                    "d": "Esse reino não será jamais destruído; ele subsiste.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de Daniel 2:44?",
                [
                    ("a", "suscitará o Deus do céu um reino"),
                    ("b", "não será jamais destruído, nem passará a soberania deste a outro povo"),
                    ("c", "fará em pedaços e consumirá todos esses reinos"),
                ],
                "Certo: suscitar, permanência, depois o juízo dos impérios.",
                {"b": "A permanência segue o suscitar do reino.", "c": "Despedaçar os reinos é a ação seguinte."},
                p,
                **k,
            ),
            lambda **k: complete(
                "e ele mesmo ___ para sempre",
                [("a", "subsistirá"), ("b", "passará"), ("c", "destruído")],
                "a",
                "Certo: ele mesmo subsistirá para sempre.",
                {"b": "Passará é o que a soberania não faz.", "c": "Destruído é o que esse reino não será."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 2:44 comunica que se liga a este contexto?",
                "fará em pedaços e consumirá todos esses reinos, e ele mesmo subsistirá para sempre",
                insight,
                [
                    ("a", "Impérios em pedaços"),
                    ("b", "Soberania que migra"),
                    ("c", "Reinos que consomem a Deus"),
                ],
                "a",
                "Certo: o reino de Deus despedaça os impérios.",
                {"b": "A soberania deste não passa a outro povo.", "c": "É o reino de Deus que consome os reinos."},
                p,
                **k,
            ),
        ],
    )

    profundezas = pack(
        meta,
        "profundezas",
        "interpret",
        [
            lambda **k: tf(
                "O sonho da estátua anuncia um reino de Deus que julga os impérios e não se dilui na sucessão dos povos.",
                "true",
                "Certo: não destruído, não transferido, consome e subsiste.",
                "O texto recusa destruição e transferência; o reino subsiste.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "que não será jamais ___",
                [("a", "destruído"), ("b", "suscitará"), ("c", "consumirá")],
                "a",
                "Exato: não será jamais destruído.",
                {"b": "Suscitará é o verbo de Deus no início.", "c": "Consumirá é o que o reino faz aos outros."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual leitura de Daniel 2:44 descreve o sentido do reino de Deus?",
                [
                    ("a", "Mais um império na fila: nasce, transfere a soberania e cai."),
                    ("b", "Um reino espiritual que nunca toca os reinos da história."),
                    ("c", "O Deus do céu suscita um reino eterno que despedaça os impérios e permanece."),
                    ("d", "Os povos herdarão a soberania desse reino por turno."),
                ],
                "c",
                "Certo: reino eterno que julga e permanece.",
                {
                    "a": "Não será destruído nem passará a outro povo.",
                    "b": "Ele faz em pedaços e consome todos esses reinos.",
                    "d": "A soberania deste não passará a outro povo.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de Daniel 2:44?",
                [
                    ("a", "suscitará o Deus do céu um reino que não será jamais destruído"),
                    ("b", "nem passará a soberania deste a outro povo"),
                    ("c", "ele mesmo subsistirá para sempre"),
                ],
                "Certo: reino suscitado, sem transferência, subsistência eterna.",
                {"b": "A soberania que não passa interpreta a diferença dos impérios.", "c": "Subsistir para sempre fecha o sentido."},
                p,
                **k,
            ),
            lambda **k: complete(
                "consumirá todos esses ___, e ele mesmo subsistirá para sempre",
                [("a", "reinos"), ("b", "céu"), ("c", "dias")],
                "a",
                "Certo: consumirá todos esses reinos.",
                {"b": "Céu qualifica a Deus, não o que é consumido.", "c": "Dias marca o tempo dos reis, não esta lacuna."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 2:44 comunica que se liga a este contexto?",
                "ele mesmo subsistirá para sempre",
                insight,
                [
                    ("a", "Reino para sempre"),
                    ("b", "Estátua que permanece"),
                    ("c", "Povo que herda a soberania"),
                ],
                "a",
                "Certo: o reino de Deus subsiste para sempre.",
                {"b": "Os reinos da estátua são feitos em pedaços.", "c": "A soberania não passa a outro povo."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def m5():
    sec = "daniel-reinos-02-desafio-daniel"
    vr = "Daniel 1:8; 2:44; 3:18"
    lo = "Articular Daniel no palácio e nos reinos: coração que não se contamina, recusa da imagem mesmo sem livramento, e reino de Deus que não passa."
    ev = ["Daniel 1:8", "Daniel 2:44", "Daniel 3:18"]
    p = TB_BOSS
    insight = "Daniel: coração que não se contamina, fornalha sem imagem, e reino que não passa."
    meta = dict(trail="daniel", section=sec, verse_ref=vr, lo=lo, evidence=ev)

    semente = pack(
        meta,
        "semente",
        "observe",
        [
            lambda **k: tf(
                "Daniel assentou no coração não contaminar-se; o Deus do céu suscita um reino indestrutível; eles não hão de servir aos deuses do rei nem adorar a imagem.",
                "true",
                "Certo: os três trechos afirmam coração, reino e recusa.",
                "Os três textos sustentam mesa, reino eterno e recusa da imagem.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "assentou no seu ___ não se contaminar",
                [("a", "coração"), ("b", "soberania"), ("c", "imagem")],
                "a",
                "Exato: propósito no coração em Daniel 1:8.",
                {"b": "Soberania pertence a Daniel 2:44.", "c": "Imagem pertence à recusa de 3:18."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual conjunto os três textos afirmam diretamente?",
                [
                    ("a", "Não contaminar-se à mesa, reino que não passa, recusa de adorar a imagem de ouro."),
                    ("b", "Aceitar iguarias, transferir a soberania e adorar a imagem."),
                    ("c", "Reino logo destruído, mesa livre e serviço aos deuses do rei."),
                    ("d", "Só o sonho da estátua, sem coração e sem fornalha."),
                ],
                "a",
                "Certo: mesa, reino eterno e recusa da imagem.",
                {
                    "b": "Os textos recusam contaminar-se, transferência e a imagem.",
                    "c": "O reino não será destruído; eles não servem aos deuses do rei.",
                    "d": "1:8 e 3:18 estão no conjunto com 2:44.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos nos três textos?",
                [
                    ("a", "Daniel, porém, assentou no seu coração não se contaminar"),
                    ("b", "suscitará o Deus do céu um reino que não será jamais destruído"),
                    ("c", "não havemos de servir aos teus deuses, nem adorar a imagem de ouro que levantaste"),
                ],
                "Certo: coração, reino eterno, recusa da imagem.",
                {"b": "O reino de 2:44 segue o propósito de 1:8.", "c": "A recusa de 3:18 fecha o conjunto."},
                p,
                **k,
            ),
            lambda **k: complete(
                "nem adorar a imagem de ouro que ___",
                [("a", "levantaste"), ("b", "assentou"), ("c", "subsistirá")],
                "a",
                "Certo: a imagem de ouro que o rei levantou.",
                {"b": "Assentou descreve o coração de Daniel em 1:8.", "c": "Subsistirá descreve o reino em 2:44."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 1:8; 2:44; 3:18 comunica que se liga a este contexto?",
                p,
                insight,
                [
                    ("a", "Coração, imagem e reino"),
                    ("b", "Mesa, imagem e império eterno"),
                    ("c", "Contaminação e transferência"),
                ],
                "a",
                "Certo: coração puro, fornalha sem imagem, reino que não passa.",
                {"b": "O reino de Deus, não o império, subsiste; a imagem é recusada.", "c": "Daniel recusa contaminar-se e a soberania não passa."},
                p,
                **k,
            ),
        ],
    )

    caminhada = pack(
        meta,
        "caminhada",
        "understand",
        [
            lambda **k: tf(
                "Nos três textos, a fidelidade na mesa, a recusa da imagem e o reino que não passa se encadeiam no mesmo Daniel.",
                "true",
                "Certo: palácio, fornalha e sonho formam um só perfil.",
                "1:8, 3:18 e 2:44 se encadeiam no desafio de Daniel.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "nem passará a ___ deste a outro povo",
                [("a", "soberania"), ("b", "iguarias"), ("c", "deuses")],
                "a",
                "Exato: a soberania deste não passa a outro povo.",
                {"b": "Iguarias pertencem a Daniel 1:8.", "c": "Deuses pertencem à recusa de 3:18."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como se encadeiam mesa, imagem e reino nestes textos?",
                [
                    ("a", "O coração recusa a mesa; o reino de Deus permanece; a fornalha não compra a imagem."),
                    ("b", "A recusa da mesa anula o reino de Deus e exige adorar a imagem."),
                    ("c", "O reino eterno dispensa propósito no coração e recusa na fornalha."),
                    ("d", "Adorar a imagem garante que a soberania não passe a outro povo."),
                ],
                "a",
                "Certo: fidelidade na mesa, reino permanente, recusa da imagem.",
                {
                    "b": "O reino de Deus subsiste; a imagem é recusada.",
                    "c": "1:8 e 3:18 permanecem com 2:44.",
                    "d": "Eles não hão de adorar a imagem que o rei levantou.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de Daniel 1:8; 2:44; 3:18?",
                [
                    ("a", "não se contaminar com as iguarias reais nem com o vinho que o rei bebia"),
                    ("b", "fará em pedaços e consumirá todos esses reinos, e ele mesmo subsistirá para sempre"),
                    ("c", "Mas, se não, fica tu sabendo, ó rei, que não havemos de servir aos teus deuses"),
                ],
                "Certo: recusa da mesa, reino que consome, recusa dos deuses.",
                {"b": "O juízo dos impérios segue a mesa do palácio.", "c": "O \"se não\" da fornalha fecha o encadeamento."},
                p,
                **k,
            ),
            lambda **k: complete(
                "não se ___ com as iguarias reais",
                [("a", "contaminar"), ("b", "destruído"), ("c", "adorar")],
                "a",
                "Certo: não se contaminar com as iguarias reais.",
                {"b": "Destruído qualifica o que o reino de Deus não será.", "c": "Adorar é o que eles recusam à imagem."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 1:8; 2:44; 3:18 comunica que se liga a este contexto?",
                "pediu ao príncipe dos eunucos que lhe permitisse não contaminar-se",
                insight,
                [
                    ("a", "Mesa que guarda o exílio"),
                    ("b", "Imagem na mesa do rei"),
                    ("c", "Reino que se contamina"),
                ],
                "a",
                "Certo: o coração recusa a mesa e se liga ao reino que não passa.",
                {"b": "3:18 recusa a imagem; 1:8 recusa contaminar-se.", "c": "O reino de Deus não se dilui nem se contamina."},
                p,
                **k,
            ),
        ],
    )

    profundezas = pack(
        meta,
        "profundezas",
        "interpret",
        [
            lambda **k: tf(
                "Daniel reduz a fé a sobreviver no palácio: a mesa pode contaminar-se, a imagem pode ser adorada e os impérios permanecem.",
                "false",
                "Certo: os textos recusam contaminação, imagem e impérios eternos.",
                "Coração, fornalha e reino eterno contradizem essa redução.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "não havemos de servir aos teus ___, nem adorar a imagem",
                [("a", "deuses"), ("b", "eunucos"), ("c", "reinos")],
                "a",
                "Exato: não hão de servir aos deuses do rei.",
                {"b": "Eunucos pertence ao pedido de 1:8.", "c": "Reinos são os que o Deus do céu consome."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual leitura destes três textos descreve Daniel no exílio?",
                [
                    ("a", "Coração contaminável, fornalha com imagem e reino que passa a outro povo."),
                    ("b", "Só recusa política, sem Deus do céu e sem propósito no coração."),
                    ("c", "Fidelidade que não se contamina, lealdade sem imagem, e reino de Deus que permanece."),
                    ("d", "O sonho da estátua cancela a mesa e a fornalha como irrelevantes."),
                ],
                "c",
                "Certo: coração, fornalha e reino eterno formam Daniel.",
                {
                    "a": "Os textos recusam contaminar-se, a imagem e a transferência.",
                    "b": "Há propósito no coração e o Deus do céu suscita o reino.",
                    "d": "1:8 e 3:18 permanecem com 2:44 no mesmo desafio.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de Daniel 1:8; 2:44; 3:18?",
                [
                    ("a", "assentou no seu coração não se contaminar"),
                    ("b", "um reino que não será jamais destruído, nem passará a soberania deste a outro povo"),
                    ("c", "nem adorar a imagem de ouro que levantaste"),
                ],
                "Certo: coração puro, reino que não passa, fornalha sem imagem.",
                {"b": "O reino eterno interpreta a soberania acima do palácio.", "c": "A recusa da imagem revela lealdade sem barganha."},
                p,
                **k,
            ),
            lambda **k: complete(
                "ele mesmo ___ para sempre",
                [("a", "subsistirá"), ("b", "contaminar"), ("c", "levantaste")],
                "a",
                "Certo: o reino de Deus subsistirá para sempre.",
                {"b": "Contaminar é o que Daniel recusa em 1:8.", "c": "Levantaste descreve a imagem em 3:18."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Daniel 1:8; 2:44; 3:18 comunica que se liga a este contexto?",
                "suscitará o Deus do céu um reino que não será jamais destruído, nem passará a soberania deste a outro povo",
                insight,
                [
                    ("a", "Reino que não passa"),
                    ("b", "Império que se contamina"),
                    ("c", "Imagem que permanece"),
                ],
                "a",
                "Certo: o reino de Deus permanece; a mesa e a imagem são recusadas.",
                {"b": "Daniel recusa contaminar-se; o reino de Deus consome os impérios.", "c": "Eles não adoram a imagem que o rei levantou."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def main():
    questions = m1() + m2() + m3() + m4() + m5()
    assert len(questions) == 90, len(questions)
    ids = [q["id"] for q in questions]
    assert len(ids) == len(set(ids))
    for q in questions:
        assert len(q["feedbackCorrect"]) <= 100, (q["id"], len(q["feedbackCorrect"]), q["feedbackCorrect"])
        if q["type"] in ("tap", "complete"):
            for o in q["options"]:
                assert o["text"].lower() in q["passageText"].lower(), (q["id"], o["text"])
    out = Path(__file__).with_name("daniel.json")
    out.write_text(json.dumps(questions, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{out} {len(questions)}")


if __name__ == "__main__":
    main()
