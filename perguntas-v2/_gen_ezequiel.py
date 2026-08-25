#!/usr/bin/env python3
"""Gera perguntas-v2/ezequiel.json (90 perguntas, 5 missões). TB verbatim."""
import json
from pathlib import Path

TB_M1 = (
    "Como a aparência do arco que se vê na nuvem no dia de chuva, assim era a "
    "aparência do resplendor em roda. Esta era a aparência da semelhança da glória "
    "de Jeová. Quando a vi, caí com o rosto em terra e ouvi uma voz de quem falava."
)
TB_M2 = (
    "Filho do homem, eu te dei por atalaia à casa de Israel; ouve, pois, da minha "
    "boca a palavra e avisa-os da minha parte."
)
TB_M3 = (
    "Também vos darei um coração novo e dentro de vós porei um espírito novo; "
    "tirarei da vossa carne o coração de pedra e dar-vos-ei um coração de carne."
)
TB_M4 = (
    "Assim diz o Senhor Jeová a estes ossos: Eis que vou fazer entrar em vós o "
    "fôlego, e vivereis. Porei sobre vós nervos, e farei crescer carnes sobre vós; "
    "porei em vós o fôlego, e vivereis; sabereis que eu sou Jeová."
)
TB_M4_5 = (
    "Assim diz o Senhor Jeová a estes ossos: Eis que vou fazer entrar em vós o "
    "fôlego, e vivereis."
)
TB_M5 = f"{TB_M2} {TB_M3} {TB_M4_5}"

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
    trail = "ezequiel"
    section = "ezequiel-visoes-01-a-gloria-de-deus"
    vr = "Ezequiel 1:28"
    lo = "Reconhecer que a glória de Jeová aparece como resplendor que faz o profeta cair com o rosto em terra."
    evidence = ["Ezequiel 1:28"]
    p = TB_M1
    insight = "A glória de Jeová não é ideia: resplendor que derruba o profeta com o rosto em terra."
    meta = dict(trail=trail, section=section, verse_ref=vr, lo=lo, evidence=evidence)

    semente = pack(
        meta,
        "semente",
        "observe",
        [
            lambda **k: tf(
                "Ao ver a semelhança da glória de Jeová, Ezequiel caiu com o rosto em terra e ouviu uma voz.",
                "true",
                "Certo: o texto une visão, queda e voz.",
                "Releia: ele caiu com o rosto em terra e ouviu uma voz.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "Esta era a aparência da semelhança da ___ de Jeová",
                [("a", "glória"), ("b", "nuvem"), ("c", "chuva")],
                "a",
                "Exato: é a semelhança da glória de Jeová.",
                {"b": "Nuvem pertence ao arco no dia de chuva.", "c": "Chuva descreve o dia do arco, não a glória."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual fato o texto afirma sobre o que Ezequiel viu?",
                [
                    ("a", "Era a aparência da semelhança da glória de Jeová."),
                    ("b", "Era apenas um arco comum, sem qualquer resplendor."),
                    ("c", "Ezequiel permaneceu de pé e não ouviu voz alguma."),
                    ("d", "A visão aconteceu numa sala do templo, sem nuvem nem chuva."),
                ],
                "a",
                "Certo: o texto chama o que viu de glória de Jeová.",
                {
                    "b": "O arco ilustra o resplendor, não o reduz a clima.",
                    "c": "Ele caiu com o rosto em terra e ouviu uma voz.",
                    "d": "A comparação é com o arco na nuvem no dia de chuva.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos em Ezequiel 1:28?",
                [
                    ("a", "Como a aparência do arco que se vê na nuvem no dia de chuva"),
                    ("b", "Esta era a aparência da semelhança da glória de Jeová"),
                    ("c", "Quando a vi, caí com o rosto em terra e ouvi uma voz de quem falava"),
                ],
                "Certo: arco, glória nomeada, queda e voz.",
                {"b": "A glória é nomeada depois da comparação com o arco.", "c": "A queda e a voz fecham o versículo."},
                p,
                **k,
            ),
            lambda **k: complete(
                "Quando a vi, caí com o ___ em terra e ouvi uma voz de quem falava",
                [("a", "rosto"), ("b", "arco"), ("c", "resplendor")],
                "a",
                "Certo: caiu com o rosto em terra.",
                {"b": "Arco ilustra o resplendor, não o que toca a terra.", "c": "Resplendor é o que ele viu, não com o que caiu."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 1:28 comunica que se liga a este contexto?",
                "Esta era a aparência da semelhança da glória de Jeová. Quando a vi, caí com o rosto em terra",
                insight,
                [
                    ("a", "Glória que derruba"),
                    ("b", "Arco sem Jeová"),
                    ("c", "Voz sem visão"),
                ],
                "a",
                "Certo: a glória é resplendor que derruba o profeta.",
                {"b": "O arco ilustra o resplendor da glória de Jeová.", "c": "A voz vem depois de ele ver e cair."},
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
                "A glória de Jeová neste versículo é só uma ideia interior, sem resplendor visível nem efeito no corpo do profeta.",
                "false",
                "Certo: há resplendor, queda e voz.",
                "O texto descreve aparência, resplendor e queda com o rosto em terra.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "assim era a aparência do ___ em roda",
                [("a", "resplendor"), ("b", "rosto"), ("c", "voz")],
                "a",
                "Exato: a aparência do resplendor em roda.",
                {"b": "Rosto é com o que ele caiu, depois.", "c": "A voz é ouvida depois da visão."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como o versículo liga a comparação do arco ao que Ezequiel experimenta?",
                [
                    ("a", "O arco serve só de meteorologia, sem ligação com Jeová."),
                    ("b", "O resplendor em roda é a aparência da glória, e isso o derruba."),
                    ("c", "Ezequiel cai porque a chuva o impediu de enxergar."),
                    ("d", "A voz substitui a visão: ele ouve sem ter visto coisa alguma."),
                ],
                "b",
                "Certo: o arco ilustra o resplendor da glória que o derruba.",
                {
                    "a": "O arco ilustra a aparência da glória de Jeová.",
                    "c": "Ele cai ao ver a glória, não por causa da chuva.",
                    "d": "Ele viu, caiu e então ouviu a voz.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de Ezequiel 1:28?",
                [
                    ("a", "assim era a aparência do resplendor em roda"),
                    ("b", "Esta era a aparência da semelhança da glória de Jeová"),
                    ("c", "caí com o rosto em terra e ouvi uma voz de quem falava"),
                ],
                "Certo: resplendor, nome da glória, queda e voz.",
                {"b": "O nome da glória segue a aparência do resplendor.", "c": "Queda e voz vêm depois de ele ver."},
                p,
                **k,
            ),
            lambda **k: complete(
                "Como a aparência do arco que se vê na nuvem no dia de ___, assim era a aparência do resplendor em roda",
                [("a", "chuva"), ("b", "glória"), ("c", "terra")],
                "a",
                "Certo: o arco se vê no dia de chuva.",
                {"b": "Glória nomeia o que o resplendor significa.", "c": "Terra é o chão onde ele caiu."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 1:28 comunica que se liga a este contexto?",
                "Como a aparência do arco que se vê na nuvem no dia de chuva, assim era a aparência do resplendor em roda",
                "A visão não fica no céu: o resplendor nomeia a glória e atinge o profeta.",
                [
                    ("a", "Resplendor que atinge"),
                    ("b", "Chuva que explica Deus"),
                    ("c", "Queda sem glória"),
                ],
                "a",
                "Certo: o resplendor comunica a glória que atinge o profeta.",
                {"b": "A chuva ilustra o arco, não define Jeová.", "c": "Ele cai precisamente ao ver a glória."},
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
                "A glória de Jeová, neste texto, não é abstração: é resplendor que derruba o profeta e abre espaço para a voz.",
                "true",
                "Certo: glória visível, queda e palavra.",
                "O versículo une aparência, queda e voz de quem falava.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "caí com o rosto em terra e ouvi uma ___ de quem falava",
                [("a", "voz"), ("b", "nuvem"), ("c", "roda")],
                "a",
                "Exato: ouviu uma voz de quem falava.",
                {"b": "Nuvem pertence à comparação do arco.", "c": "Roda descreve o resplendor em volta."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual leitura teológica deste versículo o texto sustenta?",
                [
                    ("a", "Jeová se reduz a um fenômeno de luz, sem palavra ao profeta."),
                    ("b", "O profeta controla a visão e permanece de pé como igual a Jeová."),
                    ("c", "A glória se dá a ver, derruba o homem e então fala."),
                    ("d", "A queda prova que a glória de Jeová é ilusão óptica."),
                ],
                "c",
                "Certo: ver, cair e ouvir é a ordem da glória.",
                {
                    "a": "Depois da visão há voz de quem falava.",
                    "b": "Ele cai com o rosto em terra.",
                    "d": "O texto chama o que viu de glória de Jeová.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de Ezequiel 1:28?",
                [
                    ("a", "a aparência da semelhança da glória de Jeová"),
                    ("b", "Quando a vi, caí com o rosto em terra"),
                    ("c", "ouvi uma voz de quem falava"),
                ],
                "Certo: glória vista, homem prostrado, palavra ouvida.",
                {"b": "A queda segue a visão da glória.", "c": "A voz vem depois da prostração."},
                p,
                **k,
            ),
            lambda **k: complete(
                "Esta era a aparência da ___ da glória de Jeová",
                [("a", "semelhança"), ("b", "chuva"), ("c", "voz")],
                "a",
                "Certo: aparência da semelhança da glória.",
                {"b": "Chuva ilustra o arco, não nomeia a glória.", "c": "A voz é ouvida no fim, não nesta cláusula."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 1:28 comunica que se liga a este contexto?",
                "Quando a vi, caí com o rosto em terra e ouvi uma voz de quem falava",
                "A glória de Jeová não entretém: humilha o profeta para que ele ouça.",
                [
                    ("a", "Glória que faz ouvir"),
                    ("b", "Profeta que permanece ereto"),
                    ("c", "Luz sem palavra"),
                ],
                "a",
                "Certo: a glória derruba para que a voz seja ouvida.",
                {"b": "Ele cai com o rosto em terra.", "c": "Há voz de quem falava depois da visão."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def m2():
    trail = "ezequiel"
    section = "ezequiel-visoes-02-atalaia-de-israel"
    vr = "Ezequiel 3:17"
    lo = "Entender que o atalaia ouve da boca de Jeová e avisa a casa de Israel."
    evidence = ["Ezequiel 3:17"]
    p = TB_M2
    insight = "Atalaia: ouvir da boca de Jeová e avisar Israel — a visão vira responsabilidade."
    meta = dict(trail=trail, section=section, verse_ref=vr, lo=lo, evidence=evidence)

    semente = pack(
        meta,
        "semente",
        "observe",
        [
            lambda **k: tf(
                "Jeová deu o filho do homem por atalaia à casa de Israel.",
                "true",
                "Certo: o texto diz exatamente isso.",
                "Releia: eu te dei por atalaia à casa de Israel.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "Filho do homem, eu te dei por ___ à casa de Israel",
                [("a", "atalaia"), ("b", "palavra"), ("c", "boca")],
                "a",
                "Exato: deu-o por atalaia à casa de Israel.",
                {"b": "Palavra é o que ele deve ouvir e avisar.", "c": "Boca é de onde sai a palavra de Jeová."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual fato o texto afirma sobre o encargo do filho do homem?",
                [
                    ("a", "Deve ouvir da boca de Jeová a palavra e avisar Israel."),
                    ("b", "Deve guardar silêncio e não avisar a casa de Israel."),
                    ("c", "Recebeu o cargo de rei sobre as nações vizinhas."),
                    ("d", "Deve inventar a palavra, sem ouvir da boca de Jeová."),
                ],
                "a",
                "Certo: ouvir da boca e avisar da parte de Jeová.",
                {
                    "b": "O texto manda avisar, não calar.",
                    "c": "O cargo é atalaia à casa de Israel.",
                    "d": "A palavra vem da boca de Jeová.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos em Ezequiel 3:17?",
                [
                    ("a", "Filho do homem, eu te dei por atalaia à casa de Israel"),
                    ("b", "ouve, pois, da minha boca a palavra"),
                    ("c", "e avisa-os da minha parte"),
                ],
                "Certo: nomeação, ouvir, avisar.",
                {"b": "Ouvir a palavra segue a nomeação de atalaia.", "c": "Avisar fecha o encargo."},
                p,
                **k,
            ),
            lambda **k: complete(
                "ouve, pois, da minha ___ a palavra e avisa-os da minha parte",
                [("a", "boca"), ("b", "casa"), ("c", "atalaia")],
                "a",
                "Certo: da minha boca a palavra.",
                {"b": "Casa é a de Israel, não a origem da palavra.", "c": "Atalaia é o cargo, não a fonte da palavra."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 3:17 comunica que se liga a este contexto?",
                "eu te dei por atalaia à casa de Israel; ouve, pois, da minha boca a palavra e avisa-os da minha parte",
                insight,
                [
                    ("a", "Visão vira aviso"),
                    ("b", "Silêncio do atalaia"),
                    ("c", "Palavra sem Israel"),
                ],
                "a",
                "Certo: o atalaia ouve e avisa.",
                {"b": "O texto manda avisar, não calar.", "c": "O aviso é à casa de Israel."},
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
                "O atalaia só contempla a visão; não precisa ouvir da boca de Jeová nem avisar Israel.",
                "false",
                "Certo: o cargo une ouvir e avisar.",
                "O versículo manda ouvir a palavra e avisar da parte de Jeová.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "ouve, pois, da minha boca a ___ e avisa-os da minha parte",
                [("a", "palavra"), ("b", "casa"), ("c", "homem")],
                "a",
                "Exato: da minha boca a palavra.",
                {"b": "Casa é o destinatário: Israel.", "c": "Homem pertence ao vocativo Filho do homem."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como se relacionam a nomeação de atalaia e o aviso a Israel?",
                [
                    ("a", "O título de atalaia dispensa qualquer aviso ao povo."),
                    ("b", "O aviso vem de opinião pessoal, não da boca de Jeová."),
                    ("c", "Ouvir da boca de Jeová é o que habilita o aviso da parte dele."),
                    ("d", "Israel deve avisar o profeta, não o contrário."),
                ],
                "c",
                "Certo: primeiro ouve, depois avisa da parte de Jeová.",
                {
                    "a": "Atalaia existe para avisar.",
                    "b": "A palavra é da boca de Jeová.",
                    "d": "Ele avisa a casa de Israel.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de Ezequiel 3:17?",
                [
                    ("a", "eu te dei por atalaia à casa de Israel"),
                    ("b", "ouve, pois, da minha boca a palavra"),
                    ("c", "avisa-os da minha parte"),
                ],
                "Certo: cargo, escuta, aviso.",
                {"b": "A escuta segue o cargo de atalaia.", "c": "O aviso é o desfecho do encargo."},
                p,
                **k,
            ),
            lambda **k: complete(
                "eu te dei por atalaia à casa de ___; ouve, pois, da minha boca a palavra",
                [("a", "Israel"), ("b", "boca"), ("c", "parte")],
                "a",
                "Certo: atalaia à casa de Israel.",
                {"b": "Boca é de onde sai a palavra.", "c": "Parte fecha o aviso: da minha parte."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 3:17 comunica que se liga a este contexto?",
                "ouve, pois, da minha boca a palavra e avisa-os da minha parte",
                "A visão não termina no profeta: vira palavra ouvida e aviso ao povo.",
                [
                    ("a", "Ouvir para avisar"),
                    ("b", "Avisar sem ouvir"),
                    ("c", "Cargo sem povo"),
                ],
                "a",
                "Certo: da boca de Jeová ao aviso a Israel.",
                {"b": "O aviso depende de ouvir a palavra.", "c": "O cargo é à casa de Israel."},
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
                "A vocação de atalaia transforma a palavra ouvida na boca de Jeová em aviso da parte dele a Israel.",
                "true",
                "Certo: ouvir e avisar são um só cargo.",
                "O versículo une boca, palavra e aviso da parte de Jeová.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "Filho do ___, eu te dei por atalaia à casa de Israel",
                [("a", "homem"), ("b", "palavra"), ("c", "parte")],
                "a",
                "Exato: Filho do homem.",
                {"b": "Palavra é o que ele deve ouvir.", "c": "Parte fecha o aviso de Jeová."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual leitura deste versículo descreve o sentido do atalaia?",
                [
                    ("a", "O profeta é espectador da glória, sem dever para com Israel."),
                    ("b", "Responsabilidade: a palavra de Jeová deve ser ouvida e anunciada."),
                    ("c", "Israel já conhece tudo; o atalaia só confirma o silêncio."),
                    ("d", "Atalaia significa vigiar muralhas, sem qualquer palavra de Jeová."),
                ],
                "b",
                "Certo: o cargo é ouvir e avisar da parte de Jeová.",
                {
                    "a": "Há aviso à casa de Israel.",
                    "c": "Ele deve avisar, não calar.",
                    "d": "O texto fala de palavra da boca de Jeová.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de Ezequiel 3:17?",
                [
                    ("a", "dei por atalaia à casa de Israel"),
                    ("b", "da minha boca a palavra"),
                    ("c", "avisa-os da minha parte"),
                ],
                "Certo: cargo, origem da palavra, aviso.",
                {"b": "A palavra vem da boca de Jeová.", "c": "O aviso é da parte dele."},
                p,
                **k,
            ),
            lambda **k: complete(
                "e avisa-os da minha ___",
                [("a", "parte"), ("b", "casa"), ("c", "atalaia")],
                "a",
                "Certo: avisa-os da minha parte.",
                {"b": "Casa é Israel, destinatário do aviso.", "c": "Atalaia é o cargo, não a fórmula do aviso."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 3:17 comunica que se liga a este contexto?",
                "eu te dei por atalaia à casa de Israel",
                "A glória vista não basta: o profeta é posto como sentinela da palavra.",
                [
                    ("a", "Glória com dever"),
                    ("b", "Cargo sem palavra"),
                    ("c", "Israel sem aviso"),
                ],
                "a",
                "Certo: atalaia liga visão e responsabilidade.",
                {"b": "Há palavra da boca de Jeová.", "c": "Ele deve avisar a casa de Israel."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def m3():
    trail = "ezequiel"
    section = "ezequiel-restauraca-01-coracao-de-carne"
    vr = "Ezequiel 36:26"
    lo = "Perceber que Jeová tira o coração de pedra, dá coração de carne e põe espírito novo."
    evidence = ["Ezequiel 36:26"]
    p = TB_M3
    insight = "Restauração é cirurgia divina: tira pedra, dá carne, põe espírito novo."
    meta = dict(trail=trail, section=section, verse_ref=vr, lo=lo, evidence=evidence)

    semente = pack(
        meta,
        "semente",
        "observe",
        [
            lambda **k: tf(
                "Jeová promete tirar da carne o coração de pedra e dar um coração de carne.",
                "true",
                "Certo: o versículo afirma essa troca.",
                "Releia: tirarei o coração de pedra e darei coração de carne.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "tirarei da vossa carne o coração de ___ e dar-vos-ei um coração de carne",
                [("a", "pedra"), ("b", "espírito"), ("c", "novo")],
                "a",
                "Exato: coração de pedra.",
                {"b": "Espírito novo é o que Jeová põe dentro deles.", "c": "Novo qualifica o coração e o espírito dados."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual fato o texto afirma sobre o que Jeová dará?",
                [
                    ("a", "Um coração novo e um espírito novo no interior deles."),
                    ("b", "Apenas leis novas, sem tocar o coração."),
                    ("c", "Um coração de pedra mais duro do que o anterior."),
                    ("d", "Nada: o povo deve fabricar sozinho o espírito novo."),
                ],
                "a",
                "Certo: coração novo e espírito novo.",
                {
                    "b": "O texto fala de coração e espírito, não só de leis.",
                    "c": "Ele tira a pedra e dá carne.",
                    "d": "Jeová é quem dá e põe.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos em Ezequiel 36:26?",
                [
                    ("a", "Também vos darei um coração novo"),
                    ("b", "e dentro de vós porei um espírito novo"),
                    ("c", "tirarei da vossa carne o coração de pedra e dar-vos-ei um coração de carne"),
                ],
                "Certo: coração novo, espírito novo, troca da pedra.",
                {"b": "O espírito novo segue o coração novo.", "c": "A troca da pedra fecha o versículo."},
                p,
                **k,
            ),
            lambda **k: complete(
                "dentro de vós porei um ___ novo",
                [("a", "espírito"), ("b", "pedra"), ("c", "carne")],
                "a",
                "Certo: porei um espírito novo.",
                {"b": "Pedra é o que ele tira, não o que põe.", "c": "Carne descreve o coração dado, não esta lacuna."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 36:26 comunica que se liga a este contexto?",
                "tirarei da vossa carne o coração de pedra e dar-vos-ei um coração de carne",
                insight,
                [
                    ("a", "Cirurgia do coração"),
                    ("b", "Pedra que permanece"),
                    ("c", "Espírito fabricado"),
                ],
                "a",
                "Certo: tira pedra, dá carne, põe espírito.",
                {"b": "O texto tira o coração de pedra.", "c": "Jeová põe o espírito novo."},
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
                "O povo troca o coração de pedra por um de carne por esforço próprio, sem ação de Jeová.",
                "false",
                "Certo: Jeová é quem dá, põe e tira.",
                "Os verbos são de Jeová: darei, porei, tirarei.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "dar-vos-ei um coração de ___",
                [("a", "carne"), ("b", "pedra"), ("c", "espírito")],
                "a",
                "Exato: um coração de carne.",
                {"b": "Pedra é o que ele tira.", "c": "Espírito novo é posto dentro, distinto do coração."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como o versículo relaciona coração novo, espírito novo e a pedra?",
                [
                    ("a", "Só há troca de pedra; espírito e coração novo não aparecem."),
                    ("b", "Jeová dá interior novo e remove a dureza do coração."),
                    ("c", "O espírito novo substitui Jeová, que se retira do povo."),
                    ("d", "A carne aqui é fraqueza moral, não dom de Jeová."),
                ],
                "b",
                "Certo: dá, põe e tira — obra interior de Jeová.",
                {
                    "a": "Há coração novo e espírito novo no mesmo versículo.",
                    "c": "Jeová é quem põe o espírito novo.",
                    "d": "Coração de carne é o que ele dá no lugar da pedra.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de Ezequiel 36:26?",
                [
                    ("a", "vos darei um coração novo"),
                    ("b", "porei um espírito novo"),
                    ("c", "tirarei da vossa carne o coração de pedra"),
                ],
                "Certo: dar, pôr, tirar a pedra.",
                {"b": "O espírito novo é posto depois do coração novo.", "c": "Tirar a pedra vem na segunda metade."},
                p,
                **k,
            ),
            lambda **k: complete(
                "Também vos darei um coração ___ e dentro de vós porei um espírito novo",
                [("a", "novo"), ("b", "pedra"), ("c", "carne")],
                "a",
                "Certo: um coração novo.",
                {"b": "Pedra é o coração que ele tira.", "c": "Carne descreve o coração dado no fim."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 36:26 comunica que se liga a este contexto?",
                "Também vos darei um coração novo e dentro de vós porei um espírito novo",
                "A restauração não é só volta à terra: é troca do interior.",
                [
                    ("a", "Interior renovado"),
                    ("b", "Só muralha nova"),
                    ("c", "Pedra como prêmio"),
                ],
                "a",
                "Certo: coração e espírito novos no interior.",
                {"b": "O texto fala de coração e espírito, não de muro.", "c": "A pedra é removida, não premiada."},
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
                "A restauração neste versículo começa por cirurgia divina: espírito novo e coração de carne no lugar da pedra.",
                "true",
                "Certo: Jeová opera o interior do povo.",
                "Dar, pôr e tirar descrevem a cirurgia do coração.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "tirarei da vossa ___ o coração de pedra",
                [("a", "carne"), ("b", "espírito"), ("c", "novo")],
                "a",
                "Exato: da vossa carne o coração de pedra.",
                {"b": "Espírito é o que ele põe, novo.", "c": "Novo qualifica o que ele dá, não esta lacuna."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual leitura teológica de Ezequiel 36:26 o texto sustenta?",
                [
                    ("a", "O povo regenera a si mesmo e Jeová apenas observa."),
                    ("b", "Pedra e carne são metáforas vazias, sem mudança real."),
                    ("c", "Jeová recria o interior: tira dureza e dá vida obediente."),
                    ("d", "Espírito novo anula o coração; o homem deixa de ser humano."),
                ],
                "c",
                "Certo: tira pedra e dá coração de carne com espírito novo.",
                {
                    "a": "Os verbos da ação são de Jeová.",
                    "b": "Há troca concreta: pedra por carne.",
                    "d": "Ele dá coração de carne, não apaga o humano.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de Ezequiel 36:26?",
                [
                    ("a", "um coração novo"),
                    ("b", "um espírito novo"),
                    ("c", "um coração de carne no lugar da pedra"),
                ],
                "Certo: novo interior, espírito, carne no lugar da pedra.",
                {"b": "O espírito novo acompanha o coração novo.", "c": "A carne substitui a pedra no fim."},
                p,
                **k,
            ),
            lambda **k: complete(
                "tirarei da vossa carne o coração de pedra e dar-vos-ei um coração de ___",
                [("a", "carne"), ("b", "pedra"), ("c", "boca")],
                "a",
                "Certo: um coração de carne.",
                {"b": "Pedra é o que sai, não o que entra.", "c": "Boca não aparece neste versículo."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 36:26 comunica que se liga a este contexto?",
                "porei um espírito novo; tirarei da vossa carne o coração de pedra",
                "Sem essa cirurgia, a glória vista não vira povo restaurado.",
                [
                    ("a", "Povo refeito por dentro"),
                    ("b", "Glória sem coração"),
                    ("c", "Pedra como vocação"),
                ],
                "a",
                "Certo: Jeová refez o interior do povo.",
                {"b": "Há coração novo e espírito novo.", "c": "A pedra é tirada, não chamada."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def m4():
    trail = "ezequiel"
    section = "ezequiel-restauraca-02-vale-de-ossos-secos"
    vr = "Ezequiel 37:5–6"
    lo = "Ver que os ossos secos vivem quando Jeová faz entrar o fôlego e põe nervos e carnes."
    evidence = ["Ezequiel 37:5", "Ezequiel 37:6"]
    p = TB_M4
    insight = "Ossos secos vivem quando Jeová põe fôlego: o vale não é fim, é palco da vida."
    meta = dict(trail=trail, section=section, verse_ref=vr, lo=lo, evidence=evidence)

    semente = pack(
        meta,
        "semente",
        "observe",
        [
            lambda **k: tf(
                "O Senhor Jeová diz a estes ossos que vai fazer entrar neles o fôlego, e vivereis.",
                "true",
                "Certo: fôlego e vida são a promessa aos ossos.",
                "Releia: vou fazer entrar em vós o fôlego, e vivereis.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "Eis que vou fazer entrar em vós o ___, e vivereis",
                [("a", "fôlego"), ("b", "nervos"), ("c", "Senhor")],
                "a",
                "Exato: o fôlego, e vivereis.",
                {"b": "Nervos vêm no versículo 6, sobre os ossos.", "c": "Senhor nomeia quem fala, não o que entra."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual fato o texto afirma sobre o que Jeová fará aos ossos?",
                [
                    ("a", "Porá nervos, fará crescer carnes e porá o fôlego."),
                    ("b", "Deixará os ossos secos sem fôlego nem carne."),
                    ("c", "Mandará o profeta enterrar os ossos em silêncio."),
                    ("d", "Prometerá só memória, sem que os ossos vivam."),
                ],
                "a",
                "Certo: nervos, carnes, fôlego e vida.",
                {
                    "b": "O texto promete fôlego e vida.",
                    "c": "Jeová fala vida aos ossos, não sepultura.",
                    "d": "Eles vivereis e saberão que ele é Jeová.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos em Ezequiel 37:5–6?",
                [
                    ("a", "Assim diz o Senhor Jeová a estes ossos"),
                    ("b", "Eis que vou fazer entrar em vós o fôlego, e vivereis"),
                    ("c", "Porei sobre vós nervos, e farei crescer carnes sobre vós"),
                ],
                "Certo: palavra aos ossos, fôlego, nervos e carnes.",
                {"b": "O fôlego é anunciado depois do endereçamento.", "c": "Nervos e carnes vêm no versículo 6."},
                p,
                **k,
            ),
            lambda **k: complete(
                "Porei sobre vós ___, e farei crescer carnes sobre vós",
                [("a", "nervos"), ("b", "ossos"), ("c", "voz")],
                "a",
                "Certo: porei sobre vós nervos.",
                {"b": "Ossos já são os destinatários da palavra.", "c": "Voz não aparece neste trecho."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 37:5–6 comunica que se liga a este contexto?",
                "vou fazer entrar em vós o fôlego, e vivereis",
                insight,
                [
                    ("a", "Fôlego nos ossos"),
                    ("b", "Vale como túmulo final"),
                    ("c", "Vida sem Jeová"),
                ],
                "a",
                "Certo: o fôlego de Jeová faz os ossos viverem.",
                {"b": "O vale é palco da vida, não fim.", "c": "Sabereis que eu sou Jeová."},
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
                "Os ossos secos vivem por reorganização humana, sem o fôlego que Jeová faz entrar.",
                "false",
                "Certo: a vida depende do fôlego de Jeová.",
                "Duas vezes o texto liga fôlego e vivereis à ação de Jeová.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "Assim diz o Senhor Jeová a estes ___",
                [("a", "ossos"), ("b", "nervos"), ("c", "carnes")],
                "a",
                "Exato: a estes ossos.",
                {"b": "Nervos são o que ele porá sobre eles.", "c": "Carnes crescerão sobre eles depois."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como se relacionam fôlego, nervos e o saber que Jeová é Jeová?",
                [
                    ("a", "O saber vem de um livro, não da vida dos ossos."),
                    ("b", "Nervos substituem o fôlego; a vida não precisa de Jeová."),
                    ("c", "Jeová reconstitui o corpo, dá fôlego, e a vida revela quem ele é."),
                    ("d", "Os ossos vivem primeiro e só depois Jeová fala."),
                ],
                "c",
                "Certo: reconstituição, fôlego e reconhecimento de Jeová.",
                {
                    "a": "Sabereis segue o vivereis pelo fôlego.",
                    "b": "O fôlego é posto para que vivam.",
                    "d": "A palavra de Jeová abre o oráculo aos ossos.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de Ezequiel 37:5–6?",
                [
                    ("a", "vou fazer entrar em vós o fôlego, e vivereis"),
                    ("b", "Porei sobre vós nervos, e farei crescer carnes sobre vós"),
                    ("c", "porei em vós o fôlego, e vivereis; sabereis que eu sou Jeová"),
                ],
                "Certo: fôlego anunciado, corpo refeito, fôlego e conhecimento.",
                {"b": "Nervos e carnes seguem o anúncio do fôlego.", "c": "O saber que ele é Jeová fecha o trecho."},
                p,
                **k,
            ),
            lambda **k: complete(
                "farei crescer ___ sobre vós; porei em vós o fôlego, e vivereis",
                [("a", "carnes"), ("b", "ossos"), ("c", "Senhor")],
                "a",
                "Certo: farei crescer carnes sobre vós.",
                {"b": "Ossos já estão no vale como destinatários.", "c": "Senhor é quem fala, não o que cresce."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 37:5–6 comunica que se liga a este contexto?",
                "porei em vós o fôlego, e vivereis; sabereis que eu sou Jeová",
                "A reconstituição do corpo serve ao reconhecimento de Jeová.",
                [
                    ("a", "Vida que revela Jeová"),
                    ("b", "Ossos que se explicam"),
                    ("c", "Fôlego sem propósito"),
                ],
                "a",
                "Certo: vivereis e sabereis que eu sou Jeová.",
                {"b": "Os ossos não se explicam sozinhos.", "c": "O fôlego leva ao conhecimento de Jeová."},
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
                "O vale de ossos secos, neste oráculo, é palco da vida quando Jeová põe o fôlego.",
                "true",
                "Certo: morte visível, vida pela palavra de Jeová.",
                "Fôlego, nervos, carnes e vivereis desmentem o vale como fim.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "porei em vós o fôlego, e ___; sabereis que eu sou Jeová",
                [("a", "vivereis"), ("b", "nervos"), ("c", "ossos")],
                "a",
                "Exato: e vivereis.",
                {"b": "Nervos são postos sobre eles antes.", "c": "Ossos são quem recebe o fôlego."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual leitura teológica de Ezequiel 37:5–6 o texto sustenta?",
                [
                    ("a", "Jeová descreve anatomia sem prometer vida real."),
                    ("b", "A vida dos mortos é obra de Jeová, para que saibam quem ele é."),
                    ("c", "Os ossos vivem por magia do vale, independente de Jeová."),
                    ("d", "Saber que ele é Jeová cancela a necessidade de fôlego e carne."),
                ],
                "b",
                "Certo: fôlego, corpo e conhecimento de Jeová.",
                {
                    "a": "O refrão é vivereis, não só descrição.",
                    "c": "Assim diz o Senhor Jeová a estes ossos.",
                    "d": "O saber segue o fôlego e a vida.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de Ezequiel 37:5–6?",
                [
                    ("a", "palavra do Senhor Jeová a estes ossos"),
                    ("b", "fôlego, nervos e carnes sobre o que estava seco"),
                    ("c", "vida e o saber que ele é Jeová"),
                ],
                "Certo: oráculo, reconstituição, vida que conhece Jeová.",
                {"b": "O corpo refeito segue a palavra aos ossos.", "c": "Vida e conhecimento fecham o sentido."},
                p,
                **k,
            ),
            lambda **k: complete(
                "sabereis que eu sou ___",
                [("a", "Jeová"), ("b", "fôlego"), ("c", "nervos")],
                "a",
                "Certo: sabereis que eu sou Jeová.",
                {"b": "Fôlego é o que ele põe para que vivam.", "c": "Nervos fazem parte da reconstituição."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 37:5–6 comunica que se liga a este contexto?",
                "Eis que vou fazer entrar em vós o fôlego, e vivereis",
                "O vale não encerra a história de Israel: Jeová ainda fala vida.",
                [
                    ("a", "Vale palco da vida"),
                    ("b", "Secura como destino"),
                    ("c", "Silêncio sobre ossos"),
                ],
                "a",
                "Certo: o vale é palco onde Jeová dá vida.",
                {"b": "O oráculo promete vivereis.", "c": "Jeová fala a estes ossos."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def m5():
    trail = "ezequiel"
    section = "ezequiel-restauraca-03-desafio-ezequiel"
    vr = "Ezequiel 3:17; 36:26; 37:5"
    lo = "Unir atalaia, coração novo e fôlego nos ossos: glória que restaura, não só impressiona."
    evidence = ["Ezequiel 3:17", "Ezequiel 36:26", "Ezequiel 37:5"]
    p = TB_M5
    insight = "Ezequiel: atalaia, coração novo e fôlego nos ossos — glória que restaura, não só impressiona."
    meta = dict(trail=trail, section=section, verse_ref=vr, lo=lo, evidence=evidence)

    semente = pack(
        meta,
        "semente",
        "observe",
        [
            lambda **k: tf(
                "Os três textos falam de atalaia à casa de Israel, coração novo e fôlego nos ossos.",
                "true",
                "Certo: cargo, interior e vida dos ossos.",
                "Há atalaia (3:17), coração (36:26) e fôlego (37:5).",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "eu te dei por ___ à casa de Israel",
                [("a", "atalaia"), ("b", "pedra"), ("c", "fôlego")],
                "a",
                "Exato: atalaia à casa de Israel.",
                {"b": "Pedra é o coração que 36:26 tira.", "c": "Fôlego é o que 37:5 faz entrar nos ossos."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual fato estes três trechos afirmam juntos?",
                [
                    ("a", "Jeová nomeia atalaia, dá coração novo e faz entrar fôlego."),
                    ("b", "Só há visão de glória, sem cargo, coração ou ossos."),
                    ("c", "O povo fabrica o fôlego e o coração sem Jeová."),
                    ("d", "Os ossos recebem atalaia, e o coração recebe fôlego."),
                ],
                "a",
                "Certo: 3:17, 36:26 e 37:5 nessa ordem de temas.",
                {
                    "b": "Os três textos dão cargo, interior e vida.",
                    "c": "Jeová dá, põe e faz entrar.",
                    "d": "Atalaia é o profeta; fôlego vai aos ossos.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência mostra a ordem dos fatos em Ezequiel 3:17; 36:26; 37:5?",
                [
                    ("a", "eu te dei por atalaia à casa de Israel"),
                    ("b", "tirarei da vossa carne o coração de pedra"),
                    ("c", "Eis que vou fazer entrar em vós o fôlego, e vivereis"),
                ],
                "Certo: atalaia, coração, fôlego.",
                {"b": "O coração de pedra pertence a 36:26.", "c": "O fôlego nos ossos é 37:5."},
                p,
                **k,
            ),
            lambda **k: complete(
                "Também vos darei um coração ___ e dentro de vós porei um espírito novo",
                [("a", "novo"), ("b", "atalaia"), ("c", "ossos")],
                "a",
                "Certo: um coração novo.",
                {"b": "Atalaia é o cargo em 3:17.", "c": "Ossos recebem o fôlego em 37:5."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 3:17; 36:26; 37:5 comunica que se liga a este contexto?",
                "eu te dei por atalaia à casa de Israel. Também vos darei um coração novo. Eis que vou fazer entrar em vós o fôlego, e vivereis",
                insight,
                [
                    ("a", "Glória que restaura"),
                    ("b", "Glória que só impressiona"),
                    ("c", "Ossos sem palavra"),
                ],
                "a",
                "Certo: cargo, coração e vida — glória que restaura.",
                {"b": "Os textos restauram povo, não só deslumbram.", "c": "Jeová fala fôlego aos ossos."},
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
                "A glória em Ezequiel só impressiona; não há aviso a Israel, coração novo nem vida nos ossos.",
                "false",
                "Certo: os três textos restauram, não só deslumbram.",
                "Há atalaia, coração de carne e fôlego que faz viver.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "Eis que vou fazer entrar em vós o ___, e vivereis",
                [("a", "fôlego"), ("b", "atalaia"), ("c", "pedra")],
                "a",
                "Exato: o fôlego, e vivereis.",
                {"b": "Atalaia é o cargo do profeta em 3:17.", "c": "Pedra é o coração tirado em 36:26."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Como se encadeiam atalaia, coração e fôlego nestes textos?",
                [
                    ("a", "São temas soltos, sem relação com o povo de Jeová."),
                    ("b", "O profeta ouve e avisa; Jeová refaz o interior e dá vida aos mortos."),
                    ("c", "O fôlego substitui o atalaia, tornando o aviso inútil."),
                    ("d", "O coração de pedra é o prêmio de quem vigia bem."),
                ],
                "b",
                "Certo: responsabilidade, cirurgia interior e vida.",
                {
                    "a": "Os três visam Israel e sua restauração.",
                    "c": "O atalaia continua a ouvir e avisar.",
                    "d": "A pedra é tirada, não premiada.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Como se encadeiam os eventos de Ezequiel 3:17; 36:26; 37:5?",
                [
                    ("a", "ouve, pois, da minha boca a palavra e avisa-os da minha parte"),
                    ("b", "dentro de vós porei um espírito novo"),
                    ("c", "vou fazer entrar em vós o fôlego, e vivereis"),
                ],
                "Certo: aviso, espírito novo, fôlego e vida.",
                {"b": "O espírito novo é 36:26.", "c": "O fôlego e a vida são 37:5."},
                p,
                **k,
            ),
            lambda **k: complete(
                "tirarei da vossa carne o coração de ___ e dar-vos-ei um coração de carne",
                [("a", "pedra"), ("b", "fôlego"), ("c", "boca")],
                "a",
                "Certo: coração de pedra.",
                {"b": "Fôlego pertence aos ossos em 37:5.", "c": "Boca é a origem da palavra em 3:17."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 3:17; 36:26; 37:5 comunica que se liga a este contexto?",
                "ouve, pois, da minha boca a palavra e avisa-os da minha parte. dar-vos-ei um coração de carne. vou fazer entrar em vós o fôlego, e vivereis",
                "A visão vira povo: palavra anunciada, interior novo, mortos que vivem.",
                [
                    ("a", "Palavra, interior, vida"),
                    ("b", "Só espetáculo de luz"),
                    ("c", "Aviso sem restauração"),
                ],
                "a",
                "Certo: os três eixos do desafio de Ezequiel.",
                {"b": "Há cargo, coração e fôlego, não só luz.", "c": "36:26 e 37:5 restauram o povo."},
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
                "Ezequiel mostra glória que restaura: o atalaia avisa, Jeová troca o coração e põe fôlego nos ossos.",
                "true",
                "Certo: glória com dever, cirurgia e vida.",
                "3:17, 36:26 e 37:5 formam essa linha.",
                p,
                **k,
            ),
            lambda **k: tap(
                vr,
                "dar-vos-ei um coração de ___",
                [("a", "carne"), ("b", "ossos"), ("c", "atalaia")],
                "a",
                "Exato: coração de carne.",
                {"b": "Ossos recebem o fôlego em 37:5.", "c": "Atalaia é o cargo, não o coração."},
                p,
                **k,
            ),
            lambda **k: choice(
                "Qual leitura une estes três textos como desafio de Ezequiel?",
                [
                    ("a", "A glória basta como espetáculo; o povo permanece de pedra e seco."),
                    ("b", "Só o vale importa; atalaia e coração novo são enfeite."),
                    ("c", "Jeová chama à responsabilidade, recria o interior e ressuscita o que estava morto."),
                    ("d", "O profeta restaura Israel sem palavra, coração nem fôlego de Jeová."),
                ],
                "c",
                "Certo: aviso, coração novo e fôlego nos ossos.",
                {
                    "a": "36:26 tira a pedra; 37:5 dá vida.",
                    "b": "3:17 e 36:26 são centrais com 37:5.",
                    "d": "Tudo parte da boca e da ação de Jeová.",
                },
                p,
                **k,
            ),
            lambda **k: order(
                "Qual sequência revela o sentido de Ezequiel 3:17; 36:26; 37:5?",
                [
                    ("a", "atalaia que ouve e avisa Israel"),
                    ("b", "coração novo e espírito novo no lugar da pedra"),
                    ("c", "fôlego nos ossos para que vivam"),
                ],
                "Certo: responsabilidade, interior, ressurreição.",
                {"b": "A cirurgia do coração segue o cargo de atalaia.", "c": "O fôlego nos ossos fecha a restauração."},
                p,
                **k,
            ),
            lambda **k: complete(
                "Filho do homem, eu te dei por atalaia à casa de ___; ouve, pois, da minha boca a palavra",
                [("a", "Israel"), ("b", "carne"), ("c", "fôlego")],
                "a",
                "Certo: casa de Israel.",
                {"b": "Carne descreve o coração dado em 36:26.", "c": "Fôlego é 37:5, não esta lacuna."},
                p,
                **k,
            ),
            lambda **k: connect(
                vr,
                "O que Ezequiel 3:17; 36:26; 37:5 comunica que se liga a este contexto?",
                "avisa-os da minha parte. dentro de vós porei um espírito novo. vou fazer entrar em vós o fôlego, e vivereis",
                "Quem viu a glória é enviado a um povo que precisa de coração e de vida.",
                [
                    ("a", "Enviado a restaurar"),
                    ("b", "Visão sem povo"),
                    ("c", "Morte como última palavra"),
                ],
                "a",
                "Certo: o profeta serve à restauração do povo.",
                {"b": "Há casa de Israel, coração e ossos.", "c": "37:5 promete vivereis."},
                p,
                **k,
            ),
        ],
    )
    return semente + caminhada + profundezas


def main():
    questions = m1() + m2() + m3() + m4() + m5()
    assert len(questions) == 90, len(questions)
    out = Path(__file__).with_name("ezequiel.json")
    out.write_text(json.dumps(questions, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{out} {len(questions)}")


if __name__ == "__main__":
    main()
