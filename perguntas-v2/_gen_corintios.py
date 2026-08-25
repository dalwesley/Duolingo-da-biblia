#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json

TF = [{"id": "true", "text": "Verdadeiro"}, {"id": "false", "text": "Falso"}]
SK = {"semente": "observe", "caminhada": "understand", "profundezas": "interpret"}
SHORT = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}


def q(**kw):
    t = kw["question"]
    kw["prompt"] = t
    kw["cue"] = t
    return kw


def opt(*pairs):
    return [{"id": i, "text": t} for i, t in pairs]


P1 = (
    "Pois a palavra da cruz é uma estultícia para os que perecem, "
    "mas para nós, que somos salvos, é o poder de Deus."
)
P2 = (
    "A caridade é longânima, é benigna; a caridade não é invejosa, não se jacta, "
    "não se ensoberbece, não se porta inconvenientemente, não busca os seus próprios "
    "interesses, não se irrita, não suspeita mal, não se regozija com a injustiça, "
    "mas regozija-se com a verdade; tudo suporta, tudo crê, tudo espera, tudo sofre."
)
P3 = (
    "Pois eu vos entreguei primeiramente o que também recebi: que Cristo morreu "
    "por nossos pecados, segundo as Escrituras, e que foi sepultado, e que foi "
    "ressuscitado ao terceiro dia, segundo as Escrituras,"
)
P4 = (
    "E disse-me: Basta-te a minha graça, pois a minha força se aperfeiçoa na fraqueza. "
    "Portanto, de boa vontade antes me gloriarei nas minhas fraquezas, para que a "
    "força de Cristo repouse sobre mim."
)
P5 = "Pois ninguém pode pôr outro fundamento, senão o que foi posto, que é Jesus Cristo."

I1 = "Unidade na cruz: o que o mundo chama estultícia é poder de Deus para os salvos."
I2 = "Dons sem caridade incham: o amor é longânimo e não busca os próprios interesses."
I3 = "O evangelho recebido: morte, sepultura e ressurreição segundo as Escrituras."
I4 = "Consolação na fraqueza: a graça basta; a força de Cristo se aperfeiçoa ali."
I5 = "Igreja edificada: um só fundamento — Jesus Cristo, não personalidades."

LO1 = "Sair sabendo que a palavra da cruz é estultícia para os que perecem e poder de Deus para os salvos."
LO2 = "Sair sabendo que a caridade é longânima e benigna e não busca os próprios interesses."
LO3 = "Sair sabendo que o evangelho recebido é morte, sepultura e ressurreição segundo as Escrituras."
LO4 = "Sair sabendo que a graça basta e a força de Cristo se aperfeiçoa na fraqueza."
LO5 = "Sair sabendo que ninguém põe outro fundamento senão o já posto: Jesus Cristo."


def base(diff, typ, nn, section, verse, lo, ev, passage):
    return {
        "difficulty": diff,
        "skill": SK[diff],
        "verseRef": verse,
        "learningObjective": lo,
        "evidence": ev,
        "type": typ,
        "trail": "corintios",
        "section": section,
        "id": f"corintios-{SHORT[diff]}-{section}-{nn}",
        "passageText": passage,
    }


def merge(b, extra):
    d = dict(b)
    d.update(extra)
    return q(**d)


Qs = []

# ── M1 cruz ─────────────────────────────────────────────────────────
sec, vr, lo, ev, p, ins = (
    "co-01-cruz",
    "1 Coríntios 1:18",
    LO1,
    ["1 Coríntios 1:18"],
    P1,
    I1,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A palavra da cruz é uma estultícia para os que perecem, mas para os salvos é o poder de Deus.",
        "feedbackCorrect": "Certo: o versículo opõe estultícia e poder segundo o ouvinte.",
        "feedbackWrong": {"false": "Releia: estultícia para os que perecem; poder para os salvos."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Coríntios 1:18, toque a palavra que falta em \"Pois a palavra da cruz é uma ___ para os que perecem\"?",
        "feedbackCorrect": "Exato: para os que perecem, a cruz é estultícia.",
        "feedbackWrong": {"b": "Salvos descreve o outro grupo, não esta lacuna.", "c": "Poder é o que a cruz é para os salvos."},
        "template": "Pois a palavra da cruz é uma ___ para os que perecem",
        "options": opt(("a", "estultícia"), ("b", "salvos"), ("c", "poder")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que o texto afirma que a palavra da cruz é para os que perecem?",
        "feedbackCorrect": "Certo: para os que perecem, a palavra da cruz é estultícia.",
        "feedbackWrong": {
            "b": "Poder de Deus é o que ela é para os salvos, não para os que perecem.",
            "c": "O texto não chama a cruz de silêncio para esse grupo.",
            "d": "Não é descrita como acordo humano neste versículo.",
        },
        "options": opt(
            ("a", "Uma estultícia"),
            ("b", "O poder de Deus"),
            ("c", "Um silêncio de Deus"),
            ("d", "Um acordo entre sábios"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em 1 Coríntios 1:18?",
        "feedbackCorrect": "Certo: cruz, juízo dos que perecem, então o poder para os salvos.",
        "feedbackWrong": {"b": "A estultícia dos que perecem vem antes do poder aos salvos.", "c": "A palavra da cruz abre o versículo."},
        "options": opt(
            ("a", "Pois a palavra da cruz é uma estultícia"),
            ("b", "para os que perecem"),
            ("c", "mas para nós, que somos salvos, é o poder de Deus"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"Pois a palavra da ___ é uma estultícia para os que perecem\"",
        "feedbackCorrect": "Certo: o tema do versículo é a palavra da cruz.",
        "feedbackWrong": {"b": "Salvos vem depois, no segundo membro.", "c": "Deus fecha o versículo, não esta lacuna."},
        "template": "Pois a palavra da ___ é uma estultícia para os que perecem",
        "options": opt(("a", "cruz"), ("b", "salvos"), ("c", "Deus")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Coríntios 1:18 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a cruz une os salvos no poder de Deus, não na fama.",
        "feedbackWrong": {"b": "O texto não trata a cruz como enfeite de partido.", "c": "Há dois vereditos, não um só aplauso universal."},
        "passageA": {"ref": "1 Coríntios 1:18", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Cruz como poder de Deus"),
            ("b", "Cruz como marca de clã"),
            ("c", "Cruz aplaudida por todos"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Para os que perecem e para os salvos, a palavra da cruz tem o mesmo sentido.",
        "feedbackCorrect": "Certo: o texto divide os ouvintes em dois vereditos opostos.",
        "feedbackWrong": {"true": "Há contraste: estultícia para uns, poder de Deus para outros."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Coríntios 1:18, toque a palavra que falta em \"mas para nós, que somos salvos, é o ___ de Deus\"?",
        "feedbackCorrect": "Exato: para os salvos, a cruz é o poder de Deus.",
        "feedbackWrong": {"a": "Estultícia é o juízo dos que perecem.", "c": "Palavra abre o versículo, não esta lacuna."},
        "template": "mas para nós, que somos salvos, é o ___ de Deus",
        "options": opt(("a", "estultícia"), ("b", "poder"), ("c", "palavra")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como o versículo relaciona os dois grupos diante da cruz?",
        "feedbackCorrect": "Certo: o mesmo anúncio divide perecimento e salvação.",
        "feedbackWrong": {
            "b": "O texto não iguala os dois grupos no mesmo juízo.",
            "c": "A cruz não é tratada como tema neutro de debate.",
            "d": "Salvação aqui se liga ao poder de Deus, não à fama do pregador.",
        },
        "options": opt(
            ("a", "O mesmo anúncio é estultícia para uns e poder para os salvos"),
            ("b", "Os dois grupos ouvem a cruz com o mesmo veredito"),
            ("c", "A cruz é um tema neutro, sem efeito sobre ninguém"),
            ("d", "A salvação depende do prestígio de quem prega"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de 1 Coríntios 1:18?",
        "feedbackCorrect": "Certo: anúncio da cruz, juízo dos que perecem, poder aos salvos.",
        "feedbackWrong": {"b": "O poder aos salvos fecha o contraste, não o abre.", "c": "A palavra da cruz vem primeiro."},
        "options": opt(
            ("a", "a palavra da cruz"),
            ("b", "é uma estultícia para os que perecem"),
            ("c", "para nós, que somos salvos, é o poder de Deus"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"é uma estultícia para os que ___, mas para nós, que somos salvos\"",
        "feedbackCorrect": "Certo: o primeiro grupo é o dos que perecem.",
        "feedbackWrong": {"a": "Salvos é o segundo grupo, não esta lacuna.", "c": "Cruz nomeia o anúncio, não o grupo."},
        "template": "é uma estultícia para os que ___, mas para nós, que somos salvos",
        "options": opt(("a", "salvos"), ("b", "perecem"), ("c", "cruz")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Coríntios 1:18 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a unidade da igreja se firma na cruz, não na sabedoria do mundo.",
        "feedbackWrong": {"a": "O texto não pede união em torno da estultícia humana.", "c": "O poder é de Deus, não de um líder carismático."},
        "passageA": {"ref": "1 Coríntios 1:18", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "União na sabedoria humana"),
            ("b", "Unidade no poder da cruz"),
            ("c", "Unidade em torno de um líder"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Aquilo que o mundo chama estultícia é, para os salvos, o próprio poder de Deus.",
        "feedbackCorrect": "Certo: o versículo inverte o juízo do mundo sobre a cruz.",
        "feedbackWrong": {"false": "Para os salvos, a palavra da cruz é o poder de Deus."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Coríntios 1:18, toque a palavra que falta em \"mas para nós, que somos ___, é o poder de Deus\"?",
        "feedbackCorrect": "Exato: o poder de Deus se dirige aos que são salvos.",
        "feedbackWrong": {"a": "Perecem é o outro grupo do contraste.", "c": "Estultícia é o juízo deles, não o nosso nome."},
        "template": "mas para nós, que somos ___, é o poder de Deus",
        "options": opt(("a", "perecem"), ("b", "salvos"), ("c", "estultícia")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de 1 Coríntios 1:18?",
        "feedbackCorrect": "Certo: a cruz julga a sabedoria do mundo e salva pelo poder de Deus.",
        "feedbackWrong": {
            "a": "O texto não trata a cruz como falha a ser escondida.",
            "c": "Não é um enigma reservado a elites intelectuais.",
            "d": "Perecer e ser salvo não são o mesmo destino neste versículo.",
        },
        "options": opt(
            ("a", "A cruz é um mal-entendido que a igreja deve suavizar"),
            ("b", "A cruz divide: loucura para o mundo, poder de Deus para os salvos"),
            ("c", "Só os sábios do mundo entendem o verdadeiro sentido da cruz"),
            ("d", "Perecer e ser salvo são apenas dois nomes para o mesmo grupo"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de 1 Coríntios 1:18?",
        "feedbackCorrect": "Certo: o anúncio, o juízo do mundo e o poder aos salvos.",
        "feedbackWrong": {"b": "O poder aos salvos não precede o juízo dos que perecem.", "c": "A palavra da cruz inaugura o contraste."},
        "options": opt(
            ("a", "a palavra da cruz é uma estultícia"),
            ("b", "para os que perecem"),
            ("c", "para nós, que somos salvos, é o poder de Deus"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"mas para nós, que somos salvos, é o poder de ___\"",
        "feedbackCorrect": "Certo: o poder anunciado é o poder de Deus.",
        "feedbackWrong": {"a": "Cruz nomeia o anúncio, não o dono do poder aqui.", "b": "Estultícia é o juízo contrário."},
        "template": "mas para nós, que somos salvos, é o poder de ___",
        "options": opt(("a", "cruz"), ("b", "estultícia"), ("c", "Deus")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Coríntios 1:18 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o que o mundo despreza é o poder que salva e une.",
        "feedbackWrong": {"b": "O texto não recomenda esconder a cruz para agradar.", "c": "A unidade não nasce de apagar o escândalo da cruz."},
        "passageA": {"ref": "1 Coríntios 1:18", "text": P1},
        "passageB": {"ref": "Contexto", "text": I1},
        "options": opt(
            ("a", "Estultícia que salva"),
            ("b", "Cruz escondida da cidade"),
            ("c", "Unidade sem a cruz"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M2 amor ─────────────────────────────────────────────────────────
sec, vr, lo, ev, p, ins = (
    "co-02-amor",
    "1 Coríntios 13:4–7",
    LO2,
    ["1 Coríntios 13:4", "1 Coríntios 13:5", "1 Coríntios 13:6", "1 Coríntios 13:7"],
    P2,
    I2,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A caridade é longânima e benigna, e não busca os seus próprios interesses.",
        "feedbackCorrect": "Certo: o texto abre com longanimidade e nega o egoísmo.",
        "feedbackWrong": {"false": "Releia: é longânima, é benigna; não busca os próprios interesses."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Coríntios 13:4–7, toque a palavra que falta em \"A caridade é ___, é benigna\"?",
        "feedbackCorrect": "Exato: a caridade é longânima e benigna.",
        "feedbackWrong": {"b": "Benigna vem em seguida, não nesta lacuna.", "c": "Invejosa é o que a caridade não é."},
        "template": "A caridade é ___, é benigna",
        "options": opt(("a", "longânima"), ("b", "benigna"), ("c", "invejosa")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que o texto afirma que a caridade não busca?",
        "feedbackCorrect": "Certo: ela não busca os seus próprios interesses.",
        "feedbackWrong": {
            "a": "O texto diz que ela se regozija com a verdade, não que a evita.",
            "c": "Ela não se regozija com a injustiça; isso não é o que ela busca positivamente aqui.",
            "d": "Longanimidade é o que ela é, não o que recusa buscar.",
        },
        "options": opt(
            ("a", "A verdade"),
            ("b", "Os seus próprios interesses"),
            ("c", "A injustiça alheia como meta"),
            ("d", "Ser longânima"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em 1 Coríntios 13:4–7?",
        "feedbackCorrect": "Certo: caráter, recusa do egoísmo, então o \"tudo\" final.",
        "feedbackWrong": {"b": "Os próprios interesses vêm no meio do retrato, não no fim.", "c": "Longânima e benigna abrem o retrato."},
        "options": opt(
            ("a", "A caridade é longânima, é benigna"),
            ("b", "não busca os seus próprios interesses"),
            ("c", "tudo suporta, tudo crê, tudo espera, tudo sofre"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"A ___ é longânima, é benigna\"",
        "feedbackCorrect": "Certo: o sujeito do retrato é a caridade.",
        "feedbackWrong": {"b": "Verdade fecha o contraste com a injustiça.", "c": "Injustiça é o com que ela não se regozija."},
        "template": "A ___ é longânima, é benigna",
        "options": opt(("a", "caridade"), ("b", "verdade"), ("c", "injustiça")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Coríntios 13:4–7 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o amor longânimo recusa inflar o eu.",
        "feedbackWrong": {"b": "O texto descreve o contrário do amor que se exibe.", "c": "Caridade não se define por buscar vantagem."},
        "passageA": {"ref": "1 Coríntios 13:4–7", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Amor longânimo, não egoísta"),
            ("b", "Amor que se jacta"),
            ("c", "Amor que busca vantagem"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A caridade se regozija com a injustiça e recusa a verdade.",
        "feedbackCorrect": "Certo: ela não se regozija com a injustiça, mas com a verdade.",
        "feedbackWrong": {"true": "O texto inverte isso: regozija-se com a verdade."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Coríntios 13:4–7, toque a palavra que falta em \"não busca os seus próprios ___\"?",
        "feedbackCorrect": "Exato: a caridade não busca os próprios interesses.",
        "feedbackWrong": {"a": "Injustiça entra no contraste do regozijo, não nesta lacuna.", "c": "Verdade é com o que ela se alegra."},
        "template": "não busca os seus próprios ___",
        "options": opt(("a", "injustiça"), ("b", "interesses"), ("c", "verdade")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como o retrato da caridade encadeia o que ela é e o que ela recusa?",
        "feedbackCorrect": "Certo: longanimidade e recusa do eu caminham juntas.",
        "feedbackWrong": {
            "b": "O texto não autoriza jactância como forma de amor.",
            "c": "Buscar os próprios interesses é o que ela não faz.",
            "d": "Irritar-se e suspeitar mal estão na lista do que ela não faz.",
        },
        "options": opt(
            ("a", "É longânima e recusa inveja, jactância e busca de si"),
            ("b", "Pode jactar-se, desde que continue longânima"),
            ("c", "Primeiro busca os próprios interesses, depois é benigna"),
            ("d", "Irrita-se com razão e suspeita mal para proteger o grupo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de 1 Coríntios 13:4–7?",
        "feedbackCorrect": "Certo: recusas do eu, recusa da injustiça, gozo na verdade.",
        "feedbackWrong": {"b": "A verdade fecha o contraste com a injustiça.", "c": "Inveja e jactância vêm antes do regozijo."},
        "options": opt(
            ("a", "a caridade não é invejosa, não se jacta, não se ensoberbece"),
            ("b", "não se porta inconvenientemente, não busca os seus próprios interesses"),
            ("c", "não se regozija com a injustiça, mas regozija-se com a verdade"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"não se ___, não suspeita mal\"",
        "feedbackCorrect": "Certo: a caridade não se irrita nem suspeita mal.",
        "feedbackWrong": {"a": "Jacta aparece mais acima na lista.", "c": "Ensoberbece também vem antes."},
        "template": "não se ___, não suspeita mal",
        "options": opt(("a", "jacta"), ("b", "irrita"), ("c", "ensoberbece")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Coríntios 13:4–7 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: dons sem essa caridade incham o eu.",
        "feedbackWrong": {"a": "O retrato não define amor como busca de vantagem.", "c": "Caridade não se mede por palco ou jactância."},
        "passageA": {"ref": "1 Coríntios 13:4–7", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Dons que buscam o eu"),
            ("b", "Dons sem caridade incham"),
            ("c", "Amor medido pelo palco"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A caridade, no retrato paulino, é paciente no tempo e recusa fazer do eu o centro.",
        "feedbackCorrect": "Certo: longânima e sem busca dos próprios interesses.",
        "feedbackWrong": {"false": "Longanimidade e recusa do eu estão no centro do retrato."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Coríntios 13:4–7, toque a palavra que falta em \"tudo suporta, tudo crê, tudo espera, tudo ___\"?",
        "feedbackCorrect": "Exato: o retrato fecha com \"tudo sofre\".",
        "feedbackWrong": {"a": "Suporta abre a série dos \"tudo\", não a fecha.", "b": "Espera vem antes de sofre."},
        "template": "tudo suporta, tudo crê, tudo espera, tudo ___",
        "options": opt(("a", "suporta"), ("b", "espera"), ("c", "sofre")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de 1 Coríntios 13:4–7?",
        "feedbackCorrect": "Certo: o amor é o critério que desinfla dons e partidos.",
        "feedbackWrong": {
            "b": "O texto não reduz a caridade a sentimento sem recusas.",
            "c": "Regozijar-se com a injustiça é o contrário do retrato.",
            "d": "Não é um manual para vencer debates na assembleia.",
        },
        "options": opt(
            ("a", "Sem essa caridade, dons e discurso incham o eu na igreja"),
            ("b", "Caridade é só emoção, sem recusar inveja ou jactância"),
            ("c", "O amor cristão se alegra quando a injustiça vence"),
            ("d", "O retrato ensina a ganhar discussões com paciência tática"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de 1 Coríntios 13:4–7?",
        "feedbackCorrect": "Certo: recusa da suspeita, gozo na verdade, então o sofrer que sustenta.",
        "feedbackWrong": {"b": "O \"tudo sofre\" fecha o retrato, não o abre.", "c": "A verdade vem antes da série dos \"tudo\"."},
        "options": opt(
            ("a", "não se irrita, não suspeita mal"),
            ("b", "não se regozija com a injustiça, mas regozija-se com a verdade"),
            ("c", "tudo suporta, tudo crê, tudo espera, tudo sofre"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"não se regozija com a injustiça, mas regozija-se com a ___\"",
        "feedbackCorrect": "Certo: o gozo da caridade está na verdade.",
        "feedbackWrong": {"a": "Injustiça é o com que ela não se alegra.", "c": "Mal qualifica a suspeita, não esta lacuna."},
        "template": "não se regozija com a injustiça, mas regozija-se com a ___",
        "options": opt(("a", "injustiça"), ("b", "verdade"), ("c", "mal")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Coríntios 13:4–7 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o amor sofre e espera sem fazer do eu a medida.",
        "feedbackWrong": {"a": "O retrato não exalta o eu espiritualizado.", "c": "Caridade não se define por vantagem ministerial."},
        "passageA": {"ref": "1 Coríntios 13:4–7", "text": P2},
        "passageB": {"ref": "Contexto", "text": I2},
        "options": opt(
            ("a", "Eu espiritual no centro"),
            ("b", "Amor que não busca si"),
            ("c", "Dons como moeda de status"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
]

# ── M3 ressurreição ─────────────────────────────────────────────────
sec, vr, lo, ev, p, ins = (
    "co-03-ressurreicao",
    "1 Coríntios 15:3–4",
    LO3,
    ["1 Coríntios 15:3", "1 Coríntios 15:4"],
    P3,
    I3,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Paulo entregou o que também recebeu: Cristo morreu por nossos pecados, foi sepultado e ressuscitado.",
        "feedbackCorrect": "Certo: entrega, recepção e os três fatos do evangelho.",
        "feedbackWrong": {"false": "Releia: entreguei o que recebi: morreu, sepultado, ressuscitado."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Coríntios 15:3–4, toque a palavra que falta em \"que Cristo morreu por nossos ___, segundo as Escrituras\"?",
        "feedbackCorrect": "Exato: a morte de Cristo é por nossos pecados.",
        "feedbackWrong": {"b": "Escrituras fundamentam o fato, não preenchem esta lacuna.", "c": "Sepultado vem no versículo seguinte."},
        "template": "que Cristo morreu por nossos ___, segundo as Escrituras",
        "options": opt(("a", "pecados"), ("b", "Escrituras"), ("c", "sepultado")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "O que o texto afirma que Paulo entregou primeiramente?",
        "feedbackCorrect": "Certo: o que ele também recebeu — o evangelho dos fatos.",
        "feedbackWrong": {
            "b": "Ele não diz ter inventado o conteúdo.",
            "c": "O texto não aponta uma lista de líderes de Corinto.",
            "d": "Não é um recado particular sem os fatos de Cristo.",
        },
        "options": opt(
            ("a", "O que também recebeu acerca de Cristo"),
            ("b", "Uma doutrina que ele mesmo inventou"),
            ("c", "Uma lista de partidos da igreja em Corinto"),
            ("d", "Um recado particular sem morte nem ressurreição"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em 1 Coríntios 15:3–4?",
        "feedbackCorrect": "Certo: morte, sepultura e ressurreição ao terceiro dia.",
        "feedbackWrong": {"b": "A sepultura vem entre a morte e a ressurreição.", "c": "Cristo morreu primeiro, segundo o texto."},
        "options": opt(
            ("a", "que Cristo morreu por nossos pecados, segundo as Escrituras"),
            ("b", "e que foi sepultado"),
            ("c", "e que foi ressuscitado ao terceiro dia, segundo as Escrituras"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"que ___ morreu por nossos pecados, segundo as Escrituras\"",
        "feedbackCorrect": "Certo: o sujeito da morte é Cristo.",
        "feedbackWrong": {"b": "Pecados é o motivo da morte, não o sujeito.", "c": "Escrituras fundamentam, não ocupam esta lacuna."},
        "template": "que ___ morreu por nossos pecados, segundo as Escrituras",
        "options": opt(("a", "Cristo"), ("b", "pecados"), ("c", "Escrituras")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Coríntios 15:3–4 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o evangelho é recebido e entregue nesses fatos.",
        "feedbackWrong": {"b": "O texto não trata o evangelho como invenção paulina.", "c": "Há morte, sepultura e ressurreição, não só um slogan."},
        "passageA": {"ref": "1 Coríntios 15:3–4", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Evangelho recebido e entregue"),
            ("b", "Doutrina inventada por Paulo"),
            ("c", "Slogan sem morte nem tumba"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A morte e a ressurreição de Cristo são apresentadas sem qualquer apelo às Escrituras.",
        "feedbackCorrect": "Certo: o texto repete \"segundo as Escrituras\" nos dois polos.",
        "feedbackWrong": {"true": "Tanto a morte quanto a ressurreição vêm segundo as Escrituras."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Coríntios 15:3–4, toque a palavra que falta em \"e que foi ___, e que foi ressuscitado ao terceiro dia\"?",
        "feedbackCorrect": "Exato: entre a morte e a ressurreição está o sepultamento.",
        "feedbackWrong": {"a": "Morreu vem antes, no v. 3.", "c": "Ressuscitado fecha a tríade, não esta lacuna."},
        "template": "e que foi ___, e que foi ressuscitado ao terceiro dia",
        "options": opt(("a", "morreu"), ("b", "sepultado"), ("c", "ressuscitado")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como o texto encadeia recepção, morte e ressurreição?",
        "feedbackCorrect": "Certo: o recebido inclui morte, tumba e ressurreição escriturísticas.",
        "feedbackWrong": {
            "b": "A sepultura não é omitida: \"foi sepultado\".",
            "c": "Paulo entrega o que recebeu, não uma criação livre.",
            "d": "A ressurreição também é segundo as Escrituras.",
        },
        "options": opt(
            ("a", "O recebido inclui morte, sepultura e ressurreição segundo as Escrituras"),
            ("b", "Basta a morte; a sepultura não faz parte do anúncio"),
            ("c", "Paulo cria o conteúdo e depois o entrega à igreja"),
            ("d", "A ressurreição fica fora do critério das Escrituras"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de 1 Coríntios 15:3–4?",
        "feedbackCorrect": "Certo: entrega do recebido, morte e ressurreição segundo as Escrituras.",
        "feedbackWrong": {"b": "A entrega do recebido abre o trecho.", "c": "A morte segundo as Escrituras precede a ressurreição."},
        "options": opt(
            ("a", "eu vos entreguei primeiramente o que também recebi"),
            ("b", "que Cristo morreu por nossos pecados, segundo as Escrituras"),
            ("c", "e que foi ressuscitado ao terceiro dia, segundo as Escrituras"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"que Cristo morreu por nossos pecados, segundo as ___\"",
        "feedbackCorrect": "Certo: a morte é segundo as Escrituras.",
        "feedbackWrong": {"a": "Pecados explica o porquê, não o critério citado aqui.", "c": "Cristo é o sujeito, não esta lacuna."},
        "template": "que Cristo morreu por nossos pecados, segundo as ___",
        "options": opt(("a", "pecados"), ("b", "Escrituras"), ("c", "Cristo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Coríntios 15:3–4 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: o evangelho tem conteúdo histórico e escriturístico.",
        "feedbackWrong": {"a": "Não é um mito sem tumba nem terceiro dia.", "c": "A tríade não se reduz a sentimento de fé."},
        "passageA": {"ref": "1 Coríntios 15:3–4", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Mito sem tumba nem dia"),
            ("b", "Fatos segundo as Escrituras"),
            ("c", "Fé sem conteúdo histórico"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O evangelho que a igreja recebe não começa em Corinto: vem de Cristo morto, sepultado e ressuscitado segundo as Escrituras.",
        "feedbackCorrect": "Certo: recebido e entregue, ancorado nas Escrituras.",
        "feedbackWrong": {"false": "Paulo insiste no que recebeu, não no que a cidade inventou."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Coríntios 15:3–4, toque a palavra que falta em \"e que foi ___ ao terceiro dia, segundo as Escrituras\"?",
        "feedbackCorrect": "Exato: foi ressuscitado ao terceiro dia.",
        "feedbackWrong": {"a": "Sepultado vem antes da ressurreição.", "c": "Pecados pertence à cláusula da morte."},
        "template": "e que foi ___ ao terceiro dia, segundo as Escrituras",
        "options": opt(("a", "sepultado"), ("b", "ressuscitado"), ("c", "pecados")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de 1 Coríntios 15:3–4?",
        "feedbackCorrect": "Certo: o evangelho é tradição recebida, não invenção local.",
        "feedbackWrong": {
            "b": "A sepultura impede reduzir tudo a metáfora sem corpo.",
            "c": "\"Segundo as Escrituras\" não é enfeite opcional.",
            "d": "Paulo não se apresenta como origem do conteúdo.",
        },
        "options": opt(
            ("a", "A igreja vive de um evangelho recebido, não inventado na assembleia"),
            ("b", "A sepultura é detalhe poético, sem peso no anúncio"),
            ("c", "As Escrituras são só pano de fundo, sem governar os fatos"),
            ("d", "Paulo é a fonte original do evangelho, não um transmissor"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de 1 Coríntios 15:3–4?",
        "feedbackCorrect": "Certo: recebido, morte escriturística, ressurreição no terceiro dia.",
        "feedbackWrong": {"b": "O recebido abre a cadeia.", "c": "A morte segundo as Escrituras precede o terceiro dia."},
        "options": opt(
            ("a", "o que também recebi"),
            ("b", "Cristo morreu por nossos pecados, segundo as Escrituras"),
            ("c", "foi ressuscitado ao terceiro dia, segundo as Escrituras"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"e que foi ressuscitado ao ___ dia, segundo as Escrituras\"",
        "feedbackCorrect": "Certo: a ressurreição é ao terceiro dia.",
        "feedbackWrong": {"a": "Sepultado nomeia o fato anterior.", "c": "Primeiramente qualifica a entrega, não o dia."},
        "template": "e que foi ressuscitado ao ___ dia, segundo as Escrituras",
        "options": opt(("a", "sepultado"), ("b", "terceiro"), ("c", "primeiramente")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Coríntios 15:3–4 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a igreja se sustenta nesse evangelho tríplice.",
        "feedbackWrong": {"b": "O centro não é o prestígio do apóstolo.", "c": "Não é um anexo opcional à fé coríntia."},
        "passageA": {"ref": "1 Coríntios 15:3–4", "text": P3},
        "passageB": {"ref": "Contexto", "text": I3},
        "options": opt(
            ("a", "Tríade do evangelho recebido"),
            ("b", "Prestígio do apóstolo"),
            ("c", "Anexo opcional à fé"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M4 consolação ───────────────────────────────────────────────────
sec, vr, lo, ev, p, ins = (
    "co-04-consolacao",
    "2 Coríntios 12:9",
    LO4,
    ["2 Coríntios 12:9"],
    P4,
    I4,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "O Senhor diz a Paulo que lhe basta a graça, pois a força se aperfeiçoa na fraqueza.",
        "feedbackCorrect": "Certo: graça suficiente e força aperfeiçoada na fraqueza.",
        "feedbackWrong": {"false": "Releia: Basta-te a minha graça; a força se aperfeiçoa na fraqueza."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 2 Coríntios 12:9, toque a palavra que falta em \"Basta-te a minha ___, pois a minha força se aperfeiçoa na fraqueza\"?",
        "feedbackCorrect": "Exato: o que basta é a graça do Senhor.",
        "feedbackWrong": {"b": "Força é o que se aperfeiçoa, não o que \"basta\" nesta frase.", "c": "Fraqueza é o lugar, não o que basta."},
        "template": "Basta-te a minha ___, pois a minha força se aperfeiçoa na fraqueza",
        "options": opt(("a", "graça"), ("b", "força"), ("c", "fraqueza")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Onde o texto afirma que a força do Senhor se aperfeiçoa?",
        "feedbackCorrect": "Certo: a força se aperfeiçoa na fraqueza.",
        "feedbackWrong": {
            "a": "Não é na fama que o versículo localiza o aperfeiçoamento.",
            "c": "O texto não aponta a ausência de graça como o lugar.",
            "d": "Não é na força humana autossuficiente.",
        },
        "options": opt(
            ("a", "Na fama do apóstolo"),
            ("b", "Na fraqueza"),
            ("c", "Na ausência de graça"),
            ("d", "Na força humana sem Cristo"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em 2 Coríntios 12:9?",
        "feedbackCorrect": "Certo: a palavra da graça, o aperfeiçoar na fraqueza, então o gloriar-se.",
        "feedbackWrong": {"b": "O gloriar-se vem depois da sentença sobre a graça.", "c": "Basta-te a minha graça abre a fala."},
        "options": opt(
            ("a", "Basta-te a minha graça"),
            ("b", "pois a minha força se aperfeiçoa na fraqueza"),
            ("c", "de boa vontade antes me gloriarei nas minhas fraquezas"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"pois a minha força se ___ na fraqueza\"",
        "feedbackCorrect": "Certo: a força se aperfeiçoa na fraqueza.",
        "feedbackWrong": {"b": "Gloriarei vem na resposta de Paulo.", "c": "Repouse descreve a força de Cristo no fim."},
        "template": "pois a minha força se ___ na fraqueza",
        "options": opt(("a", "aperfeiçoa"), ("b", "gloriarei"), ("c", "repouse")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 2 Coríntios 12:9 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a graça basta onde a força humana falha.",
        "feedbackWrong": {"b": "O texto não promete a remoção da fraqueza como condição.", "c": "Não é autonomia sem Cristo."},
        "passageA": {"ref": "2 Coríntios 12:9", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Graça que basta na fraqueza"),
            ("b", "Fraqueza banida pela fama"),
            ("c", "Força sem precisar de Cristo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Paulo se recusa a gloriar-se nas fraquezas, para que a força de Cristo não o alcance.",
        "feedbackCorrect": "Certo: ele se gloria nas fraquezas para que a força de Cristo repouse.",
        "feedbackWrong": {"true": "O texto diz o contrário: gloriar-se para que Cristo repouse."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 2 Coríntios 12:9, toque a palavra que falta em \"a minha força se aperfeiçoa na ___\"?",
        "feedbackCorrect": "Exato: o lugar do aperfeiçoamento é a fraqueza.",
        "feedbackWrong": {"a": "Graça é o que basta, não o lugar citado aqui.", "c": "Cristo nomeia de quem é a força que repousa."},
        "template": "a minha força se aperfeiçoa na ___",
        "options": opt(("a", "graça"), ("b", "fraqueza"), ("c", "Cristo")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como se relacionam graça, fraqueza e o gloriar-se de Paulo?",
        "feedbackCorrect": "Certo: a graça basta, e ele se gloria para que Cristo repouse.",
        "feedbackWrong": {
            "b": "A fraqueza não é tratada como prova de abandono.",
            "c": "O gloriar-se não é nas próprias forças.",
            "d": "A graça não é chamada de insuficiente.",
        },
        "options": opt(
            ("a", "A graça basta; ele se gloria nas fraquezas para que Cristo repouse"),
            ("b", "A fraqueza prova que a graça falhou"),
            ("c", "Ele se gloria nas próprias forças para dispensar a Cristo"),
            ("d", "A graça só basta quando a fraqueza já acabou"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de 2 Coríntios 12:9?",
        "feedbackCorrect": "Certo: a fala do Senhor, o aperfeiçoar, então Cristo que repousa.",
        "feedbackWrong": {"b": "Cristo que repousa fecha o versículo.", "c": "A sentença sobre a graça vem primeiro."},
        "options": opt(
            ("a", "E disse-me: Basta-te a minha graça"),
            ("b", "pois a minha força se aperfeiçoa na fraqueza"),
            ("c", "para que a força de Cristo repouse sobre mim"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"de boa vontade antes me ___ nas minhas fraquezas\"",
        "feedbackCorrect": "Certo: Paulo se gloria nas fraquezas.",
        "feedbackWrong": {"a": "Aperfeiçoa descreve a força do Senhor.", "c": "Repouse descreve a força de Cristo no fim."},
        "template": "de boa vontade antes me ___ nas minhas fraquezas",
        "options": opt(("a", "aperfeiçoa"), ("b", "gloriarei"), ("c", "repouse")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 2 Coríntios 12:9 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: consolo não é a saída da fraqueza, e sim Cristo nela.",
        "feedbackWrong": {"a": "O texto não define consolo como fim da fraqueza.", "c": "Não é trocar graça por prestígio."},
        "passageA": {"ref": "2 Coríntios 12:9", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Consolo como fim da fraqueza"),
            ("b", "Cristo forte na fraqueza"),
            ("c", "Graça trocada por prestígio"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "A fraqueza, neste versículo, torna-se o lugar onde a força de Cristo pode repousar.",
        "feedbackCorrect": "Certo: o gloriar-se nas fraquezas visa esse repouso.",
        "feedbackWrong": {"false": "Paulo se gloria para que a força de Cristo repouse sobre ele."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 2 Coríntios 12:9, toque a palavra que falta em \"para que a força de ___ repouse sobre mim\"?",
        "feedbackCorrect": "Exato: é a força de Cristo que repousa.",
        "feedbackWrong": {"a": "Graça é o que basta no início da fala.", "c": "Vontade qualifica o gloriar-se de Paulo."},
        "template": "para que a força de ___ repouse sobre mim",
        "options": opt(("a", "graça"), ("b", "Cristo"), ("c", "vontade")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de 2 Coríntios 12:9?",
        "feedbackCorrect": "Certo: a graça não elimina a fraqueza; nela Cristo se mostra forte.",
        "feedbackWrong": {
            "b": "O versículo não trata a fraqueza como prova de abandono.",
            "c": "Paulo não busca glória apostólica contra a graça.",
            "d": "A força de Cristo não é um adorno opcional.",
        },
        "options": opt(
            ("a", "A graça basta: Cristo se aperfeiçoa onde o eu é fraco"),
            ("b", "A fraqueza prova que o Senhor se afastou de Paulo"),
            ("c", "O apóstolo deve esconder a fraqueza para guardar o ministério"),
            ("d", "A força de Cristo é extra, se a graça já bastou no começo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de 2 Coríntios 12:9?",
        "feedbackCorrect": "Certo: graça que basta, gloriar-se na fraqueza, Cristo que repousa.",
        "feedbackWrong": {"b": "Cristo que repousa é o fim visado.", "c": "A graça suficiente inaugura a lógica."},
        "options": opt(
            ("a", "Basta-te a minha graça"),
            ("b", "de boa vontade antes me gloriarei nas minhas fraquezas"),
            ("c", "para que a força de Cristo repouse sobre mim"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"para que a força de Cristo ___ sobre mim\"",
        "feedbackCorrect": "Certo: a força de Cristo deve repousar sobre ele.",
        "feedbackWrong": {"a": "Aperfeiçoa descreve a força na fraqueza, no início.", "b": "Gloriarei é o verbo de Paulo, não de Cristo aqui."},
        "template": "para que a força de Cristo ___ sobre mim",
        "options": opt(("a", "aperfeiçoa"), ("b", "gloriarei"), ("c", "repouse")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 2 Coríntios 12:9 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: consolo cristão é graça suficiente na fraqueza.",
        "feedbackWrong": {"b": "O texto não ensina a negar a fraqueza.", "c": "Não é trocar Cristo por autonomia."},
        "passageA": {"ref": "2 Coríntios 12:9", "text": P4},
        "passageB": {"ref": "Contexto", "text": I4},
        "options": opt(
            ("a", "Graça suficiente na fraqueza"),
            ("b", "Negar a fraqueza como fé"),
            ("c", "Autonomia sem o Senhor"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]

# ── M5 desafio ──────────────────────────────────────────────────────
sec, vr, lo, ev, p, ins = (
    "co-05-desafio",
    "1 Coríntios 3:11",
    LO5,
    ["1 Coríntios 3:11"],
    P5,
    I5,
)

Qs += [
    merge(base("semente", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Ninguém pode pôr outro fundamento senão o que foi posto, que é Jesus Cristo.",
        "feedbackCorrect": "Certo: o fundamento único já foi posto: Jesus Cristo.",
        "feedbackWrong": {"false": "Releia: ninguém pode pôr outro; o posto é Jesus Cristo."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("semente", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Coríntios 3:11, toque a palavra que falta em \"Pois ninguém pode pôr outro ___, senão o que foi posto\"?",
        "feedbackCorrect": "Exato: o que não se substitui é o fundamento.",
        "feedbackWrong": {"b": "Ninguém é o sujeito da proibição, não esta lacuna.", "c": "Jesus nomeia quem é o fundamento, no fim."},
        "template": "Pois ninguém pode pôr outro ___, senão o que foi posto",
        "options": opt(("a", "fundamento"), ("b", "ninguém"), ("c", "Jesus")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Quem o texto identifica como o fundamento que foi posto?",
        "feedbackCorrect": "Certo: o fundamento posto é Jesus Cristo.",
        "feedbackWrong": {
            "b": "O texto não nomeia Paulo como fundamento.",
            "c": "Não é um fundamento ainda indefinido.",
            "d": "Não aponta a assembleia de Corinto como base.",
        },
        "options": opt(
            ("a", "Jesus Cristo"),
            ("b", "O apóstolo Paulo"),
            ("c", "Um fundamento ainda sem nome"),
            ("d", "A assembleia de Corinto"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência mostra a ordem dos fatos em 1 Coríntios 3:11?",
        "feedbackCorrect": "Certo: proibição, fundamento já posto, nome de Jesus Cristo.",
        "feedbackWrong": {"b": "Jesus Cristo fecha a identificação.", "c": "A proibição de outro fundamento abre o versículo."},
        "options": opt(
            ("a", "Pois ninguém pode pôr outro fundamento"),
            ("b", "senão o que foi posto"),
            ("c", "que é Jesus Cristo"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"senão o que foi ___, que é Jesus Cristo\"",
        "feedbackCorrect": "Certo: o fundamento já foi posto.",
        "feedbackWrong": {"b": "Outro qualifica o fundamento indevido.", "c": "Ninguém é o sujeito da frase inicial."},
        "template": "senão o que foi ___, que é Jesus Cristo",
        "options": opt(("a", "posto"), ("b", "outro"), ("c", "ninguém")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("semente", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Coríntios 3:11 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: a igreja se edifica sobre Cristo, não sobre nomes.",
        "feedbackWrong": {"b": "O texto não autoriza fundamento em personalidades.", "c": "Não há vários fundamentos cristãos paralelos aqui."},
        "passageA": {"ref": "1 Coríntios 3:11", "text": P5},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Um só fundamento: Cristo"),
            ("b", "Fundamento em personalidades"),
            ("c", "Vários fundamentos da fé"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "É lícito pôr, ao lado de Cristo, outro fundamento escolhido pela igreja.",
        "feedbackCorrect": "Certo: ninguém pode pôr outro fundamento senão o já posto.",
        "feedbackWrong": {"true": "O versículo fecha essa porta: senão o que foi posto."},
        "options": TF, "correctOptionId": "false", "correctAnswer": "false",
    }),
    merge(base("caminhada", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Coríntios 3:11, toque a palavra que falta em \"Pois ___ pode pôr outro fundamento\"?",
        "feedbackCorrect": "Exato: ninguém pode pôr outro fundamento.",
        "feedbackWrong": {"b": "Posto descreve o fundamento já lançado.", "c": "Cristo identifica quem ele é, no fim."},
        "template": "Pois ___ pode pôr outro fundamento",
        "options": opt(("a", "ninguém"), ("b", "posto"), ("c", "Cristo")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Como o versículo relaciona o fundamento já posto e qualquer outro?",
        "feedbackCorrect": "Certo: o posto exclui substitutos; o nome é Jesus Cristo.",
        "feedbackWrong": {
            "b": "Não se trata de completar Cristo com outro alicerce.",
            "c": "O fundamento não fica em aberto para a assembleia decidir.",
            "d": "Personalidades não substituem o que foi posto.",
        },
        "options": opt(
            ("a", "O que foi posto exclui qualquer outro; esse posto é Jesus Cristo"),
            ("b", "Cristo é a base, mas a igreja pode acrescentar outro alicerce"),
            ("c", "O fundamento ainda será escolhido por voto da assembleia"),
            ("d", "Um líder amado pode ocupar o lugar de fundamento"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "order", "04", sec, vr, lo, ev, p), {
        "question": "Como se encadeiam os eventos de 1 Coríntios 3:11?",
        "feedbackCorrect": "Certo: ninguém põe outro, o posto já está, e esse é Cristo.",
        "feedbackWrong": {"b": "A identificação com Jesus Cristo fecha o versículo.", "c": "A impossibilidade de outro fundamento vem primeiro."},
        "options": opt(
            ("a", "ninguém pode pôr outro fundamento"),
            ("b", "senão o que foi posto"),
            ("c", "que é Jesus Cristo"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("caminhada", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"Pois ninguém pode pôr ___ fundamento, senão o que foi posto\"",
        "feedbackCorrect": "Certo: não se põe outro fundamento.",
        "feedbackWrong": {"a": "Posto descreve o que já existe.", "c": "Jesus identifica o fundamento no fim."},
        "template": "Pois ninguém pode pôr ___ fundamento, senão o que foi posto",
        "options": opt(("a", "posto"), ("b", "outro"), ("c", "Jesus")),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("caminhada", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Coríntios 3:11 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: edificar a igreja não é trocar o alicerce por nomes.",
        "feedbackWrong": {"a": "O texto não autoriza partido como fundamento.", "c": "Não se trata de alicerce em disputa de líderes."},
        "passageA": {"ref": "1 Coríntios 3:11", "text": P5},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Partido como alicerce"),
            ("b", "Igreja sobre Cristo só"),
            ("c", "Líderes como fundamento"),
        ),
        "correctOptionId": "b", "correctAnswer": "b",
    }),
    merge(base("profundezas", "true_false", "01", sec, vr, lo, ev, p), {
        "question": "Edificar a igreja sobre personalidades é pôr outro fundamento além do que já foi posto em Jesus Cristo.",
        "feedbackCorrect": "Certo: o versículo fecha a porta a qualquer outro alicerce.",
        "feedbackWrong": {"false": "Qualquer outro fundamento compete com o que é Jesus Cristo."},
        "options": TF, "correctOptionId": "true", "correctAnswer": "true",
    }),
    merge(base("profundezas", "tap", "02", sec, vr, lo, ev, p), {
        "question": "Em 1 Coríntios 3:11, toque a palavra que falta em \"que é ___ Cristo\"?",
        "feedbackCorrect": "Exato: o fundamento posto é Jesus Cristo.",
        "feedbackWrong": {"b": "Fundamento é o que foi posto, não o nome próprio aqui.", "c": "Outro qualifica o fundamento indevido."},
        "template": "que é ___ Cristo",
        "options": opt(("a", "Jesus"), ("b", "fundamento"), ("c", "outro")),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "choice", "03", sec, vr, lo, ev, p), {
        "question": "Qual leitura interpreta melhor o sentido de 1 Coríntios 3:11?",
        "feedbackCorrect": "Certo: Cristo já é o alicerce; partidos não o substituem.",
        "feedbackWrong": {
            "b": "O versículo não trata o fundamento como obra futura da igreja.",
            "c": "Paulo, Apolo ou Cefas não ocupam esse lugar neste texto.",
            "d": "Não é um chamado a vários cristos concorrentes.",
        },
        "options": opt(
            ("a", "A igreja não se funda em nomes: o alicerce já é Jesus Cristo"),
            ("b", "Cada geração deve lançar de novo o fundamento da fé"),
            ("c", "O fundamento verdadeiro é o pregador mais eloquente"),
            ("d", "Pode haver vários fundamentos, desde que todos sejam cristãos"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "order", "04", sec, vr, lo, ev, p), {
        "question": "Qual sequência revela o sentido de 1 Coríntios 3:11?",
        "feedbackCorrect": "Certo: impossível outro, o já posto, o nome de Jesus Cristo.",
        "feedbackWrong": {"b": "Jesus Cristo é a identificação final.", "c": "A exclusão de outro fundamento vem primeiro."},
        "options": opt(
            ("a", "ninguém pode pôr outro fundamento"),
            ("b", "o que foi posto"),
            ("c", "que é Jesus Cristo"),
        ),
        "correctOrder": ["a", "b", "c"], "correctOptionId": "a", "correctAnswer": "a",
    }),
    merge(base("profundezas", "complete", "05", sec, vr, lo, ev, p), {
        "question": "Complete: \"senão o que foi posto, que é Jesus ___\"",
        "feedbackCorrect": "Certo: o fundamento é Jesus Cristo.",
        "feedbackWrong": {"a": "Fundamento já foi dito no início.", "b": "Posto descreve o ato, não o nome."},
        "template": "senão o que foi posto, que é Jesus ___",
        "options": opt(("a", "fundamento"), ("b", "posto"), ("c", "Cristo")),
        "correctOptionId": "c", "correctAnswer": "c",
    }),
    merge(base("profundezas", "connect", "06", sec, vr, lo, ev, p), {
        "question": "O que 1 Coríntios 3:11 comunica que se liga a este contexto?",
        "feedbackCorrect": "Certo: edificação cristã recusa alicerce em personalidades.",
        "feedbackWrong": {"b": "O texto não faz do carisma o fundamento.", "c": "Não há segundo alicerce legítimo ao lado de Cristo."},
        "passageA": {"ref": "1 Coríntios 3:11", "text": P5},
        "passageB": {"ref": "Contexto", "text": I5},
        "options": opt(
            ("a", "Edificar só sobre Cristo"),
            ("b", "Edificar sobre o carisma"),
            ("c", "Segundo alicerce legítimo"),
        ),
        "correctOptionId": "a", "correctAnswer": "a",
    }),
]


def check_fb():
    for item in Qs:
        fc = item.get("feedbackCorrect", "")
        if len(fc) > 100:
            print("FB>100", item["id"], len(fc), fc)


if __name__ == "__main__":
    check_fb()
    assert len(Qs) == 90, len(Qs)
    out = "/Users/dalwesleyduarte/dev/new/perguntas-v2/corintios.json"
    with open(out, "w", encoding="utf-8") as f:
        json.dump(Qs, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(out, len(Qs))
