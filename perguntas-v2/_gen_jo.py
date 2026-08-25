#!/usr/bin/env python3
"""Gera perguntas-v2/jo.json (90 itens, 5 missões). Trail jo = Jó."""
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


OUT = []
TRAIL = "jo"

# ---------------------------------------------------------------------------
# M1 — Jó íntegro
# ---------------------------------------------------------------------------
P1 = "Havia um homem, na terra de Uz, por nome Jó. Era esse homem íntegro e reto, temia a Deus, e desviava-se do mal."
R1 = "Jó 1:1"
S1 = "jo-prova-01-jo-integro"
LO1 = "Reconhecer que Jó, na terra de Uz, era íntegro e reto, temia a Deus e desviava-se do mal — o sofrimento não começa em culpa inventada."
E1 = ["Jó 1:1"]
B1 = dict(trail=TRAIL, section=S1, verse_ref=R1, lo=LO1, evidence=E1, passage=P1)
INS1 = "Jó íntegro: o sofrimento não começa em culpa inventada — ele temia a Deus e se desviava do mal."

OUT.append(pack(**B1, short="sem", nn="01", difficulty="semente", skill="observe", type="true_false",
    **qtext("Havia um homem, na terra de Uz, por nome Jó."),
    feedbackCorrect="Certo: Jó 1:1 abre com o homem de Uz chamado Jó.",
    feedbackWrong={"false": "Releia Jó 1:1: havia um homem em Uz, por nome Jó."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B1, short="sem", nn="02", difficulty="semente", skill="observe", type="tap",
    **qtext('Em Jó 1:1, toque a palavra que falta em "Havia um homem, na terra de ___, por nome Jó"?'),
    template="Havia um homem, na terra de ___, por nome Jó",
    feedbackCorrect="Exato: a terra nomeada é Uz.",
    feedbackWrong={"b": "Jó é o nome do homem, não o da terra.", "c": "Mal fecha o versículo, não esta lacuna."},
    options=[{"id": "a", "text": "Uz"}, {"id": "b", "text": "Jó"}, {"id": "c", "text": "mal"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B1, short="sem", nn="03", difficulty="semente", skill="observe", type="choice",
    **qtext("O que Jó 1:1 afirma diretamente sobre esse homem?"),
    feedbackCorrect="Certo: o texto o chama íntegro e reto, temente a Deus.",
    feedbackWrong={
        "b": "O versículo não o apresenta como ímpio.",
        "c": "Ele temia a Deus; o texto não diz que o ignorava.",
        "d": "Ele se desviava do mal, não se aproximava dele.",
    },
    options=[
        {"id": "a", "text": "Era íntegro e reto, temia a Deus e desviava-se do mal."},
        {"id": "b", "text": "Era ímpio e desonesto, conhecido por enganar vizinhos."},
        {"id": "c", "text": "Ignorava a Deus e vivia sem qualquer temor."},
        {"id": "d", "text": "Aproximava-se do mal de propósito, segundo o narrador."},
    ],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B1, short="sem", nn="04", difficulty="semente", skill="observe", type="order",
    **qtext("Qual sequência mostra a ordem dos fatos em Jó 1:1?"),
    feedbackCorrect="Certo: o homem de Uz, depois o caráter, depois o temor.",
    feedbackWrong={"b": "Desviar-se do mal fecha o retrato, não o abre.", "c": "O caráter vem depois de nomear o homem de Uz."},
    options=[
        {"id": "a", "text": "Havia um homem, na terra de Uz, por nome Jó"},
        {"id": "b", "text": "temia a Deus, e desviava-se do mal"},
        {"id": "c", "text": "Era esse homem íntegro e reto"},
    ],
    correctOrder=["a", "c", "b"], correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B1, short="sem", nn="05", difficulty="semente", skill="observe", type="complete",
    **qtext("Complete a frase: \"Era esse homem ___ e reto, temia a Deus\""),
    template="Era esse homem ___ e reto, temia a Deus",
    feedbackCorrect="Certo: o primeiro adjetivo do retrato é íntegro.",
    feedbackWrong={"a": "Uz é a terra, não o adjetivo desta lacuna.", "c": "Mal aparece no fim, ao desviar-se."},
    options=[{"id": "a", "text": "Uz"}, {"id": "b", "text": "íntegro"}, {"id": "c", "text": "mal"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="sem", nn="06", difficulty="semente", skill="observe", type="connect",
    **qtext("O que Jó 1:1 comunica que se liga a este contexto?"),
    passageA={"ref": R1, "text": P1},
    passageB={"ref": "Contexto", "text": INS1},
    feedbackCorrect="Certo: o retrato é de temor a Deus e desvio do mal.",
    feedbackWrong={"b": "O texto não abre com culpa de Jó.", "c": "Ele se desviava do mal, não o buscava."},
    options=[
        {"id": "a", "text": "Íntegro que teme a Deus"},
        {"id": "b", "text": "Culpado desde o primeiro verso"},
        {"id": "c", "text": "Homem que busca o mal"},
    ],
    correctOptionId="a", correctAnswer="a"))

OUT.append(pack(**B1, short="cam", nn="01", difficulty="caminhada", skill="understand", type="true_false",
    **qtext("O narrador apresenta Jó primeiro como culpado, e só depois como homem que temia a Deus."),
    feedbackCorrect="Certo: o retrato inicial é de integridade, não de culpa.",
    feedbackWrong={"true": "Jó 1:1 o chama íntegro e reto antes de qualquer perda."},
    options=TF, correctOptionId="false", correctAnswer="false"))
OUT.append(pack(**B1, short="cam", nn="02", difficulty="caminhada", skill="understand", type="tap",
    **qtext('Em Jó 1:1, toque a palavra que falta em "Era esse homem íntegro e ___, temia a Deus"?'),
    template="Era esse homem íntegro e ___, temia a Deus",
    feedbackCorrect="Exato: íntegro anda junto com reto.",
    feedbackWrong={"a": "Uz é a terra, não o segundo adjetivo.", "c": "Homem já aparece antes desta lacuna."},
    options=[{"id": "a", "text": "Uz"}, {"id": "b", "text": "reto"}, {"id": "c", "text": "homem"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="cam", nn="03", difficulty="caminhada", skill="understand", type="choice",
    **qtext("Como Jó 1:1 encadeia o lugar, o nome e o caráter de Jó?"),
    feedbackCorrect="Certo: o caráter temente vem depois de nomear o homem de Uz.",
    feedbackWrong={
        "a": "O texto não começa pela perda, e sim pelo retrato.",
        "c": "Não há acusação de culpa neste versículo.",
        "d": "O temor a Deus pertence ao retrato, não é omitido.",
    },
    options=[
        {"id": "a", "text": "Primeiro relata a ruína, depois inventa o caráter de Jó"},
        {"id": "b", "text": "Nomeia o homem de Uz e em seguida o descreve íntegro e temente"},
        {"id": "c", "text": "Abre o livro acusando Jó de um pecado secreto"},
        {"id": "d", "text": "Apresenta o lugar e o nome, mas cala o temor a Deus"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="cam", nn="04", difficulty="caminhada", skill="understand", type="order",
    **qtext("Como se encadeiam os eventos de Jó 1:1?"),
    feedbackCorrect="Certo: identidade, integridade e então o temor que se desvia do mal.",
    feedbackWrong={"a": "O desvio do mal não abre o versículo.", "c": "O nome em Uz vem primeiro, não no meio."},
    options=[
        {"id": "a", "text": "temia a Deus, e desviava-se do mal"},
        {"id": "b", "text": "Havia um homem, na terra de Uz, por nome Jó"},
        {"id": "c", "text": "Era esse homem íntegro e reto"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="cam", nn="05", difficulty="caminhada", skill="understand", type="complete",
    **qtext("Complete a frase: \"temia a Deus, e ___ do mal\""),
    template="temia a Deus, e ___ do mal",
    feedbackCorrect="Certo: o temor se traduz em desviava-se do mal.",
    feedbackWrong={"a": "Íntegro descreve o homem, não este verbo.", "c": "Havia abre o versículo, não esta lacuna."},
    options=[{"id": "a", "text": "íntegro"}, {"id": "b", "text": "desviava-se"}, {"id": "c", "text": "Havia"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="cam", nn="06", difficulty="caminhada", skill="understand", type="connect",
    **qtext("O que Jó 1:1 comunica que se liga a este contexto?"),
    passageA={"ref": R1, "text": P1},
    passageB={"ref": "Contexto", "text": INS1},
    feedbackWrong={"a": "O narrador não o marca como réu.", "c": "O temor a Deus está no retrato inicial."},
    feedbackCorrect="Certo: o sofrimento não parte de uma culpa já declarada.",
    options=[
        {"id": "a", "text": "Retrato de um réu confessado"},
        {"id": "b", "text": "Integridade antes da prova"},
        {"id": "c", "text": "Temor a Deus omitido"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B1, short="pro", nn="01", difficulty="profundezas", skill="interpret", type="true_false",
    **qtext("Jó 1:1 descreve Jó como íntegro e reto antes de qualquer relato de perda."),
    feedbackCorrect="Certo: o livro recusa começar o sofrimento em culpa inventada.",
    feedbackWrong={"false": "O retrato de integridade precede a prova."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B1, short="pro", nn="02", difficulty="profundezas", skill="interpret", type="tap",
    **qtext('Em Jó 1:1, toque a palavra que falta em "temia a Deus, e desviava-se do ___"?'),
    template="temia a Deus, e desviava-se do ___",
    feedbackCorrect="Exato: o temor se desvia do mal.",
    feedbackWrong={"a": "Uz é a terra, não o objeto do desvio.", "b": "Reto é adjetivo do homem, não desta lacuna."},
    options=[{"id": "a", "text": "Uz"}, {"id": "b", "text": "reto"}, {"id": "c", "text": "mal"}],
    correctOptionId="c", correctAnswer="c"))
OUT.append(pack(**B1, short="pro", nn="03", difficulty="profundezas", skill="interpret", type="choice",
    **qtext("Que leitura teológica Jó 1:1 sustenta sobre o sofrimento de Jó?"),
    feedbackCorrect="Certo: o retrato temente impede reduzir a dor a culpa inventada.",
    feedbackWrong={
        "a": "O texto não autoriza ler Jó como ímpio disfarçado.",
        "c": "O narrador não omite o temor para abrir espaço à acusação.",
        "d": "Desviar-se do mal contradiz a tese de um pacto com o mal.",
    },
    options=[
        {"id": "a", "text": "Toda dor prova que Jó já era ímpio por baixo"},
        {"id": "b", "text": "O sofrimento não começa em culpa inventada: ele temia a Deus"},
        {"id": "c", "text": "O narrador esconde o caráter para os amigos terem razão"},
        {"id": "d", "text": "Jó 1:1 mostra um homem aliado ao mal desde Uz"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="pro", nn="04", difficulty="profundezas", skill="interpret", type="order",
    **qtext("Qual sequência revela o sentido de Jó 1:1?"),
    feedbackCorrect="Certo: o sentido vai do homem nomeado ao temor que se desvia do mal.",
    feedbackWrong={"a": "O desvio do mal não é o primeiro passo do sentido.", "c": "O temor não antecede a nomeação em Uz."},
    options=[
        {"id": "a", "text": "O temor a Deus se traduz em desviar-se do mal"},
        {"id": "b", "text": "Um homem é nomeado na terra de Uz"},
        {"id": "c", "text": "Esse homem é dito íntegro e reto"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="pro", nn="05", difficulty="profundezas", skill="interpret", type="complete",
    **qtext("Complete a frase: \"temia a Deus, e desviava-se do ___\""),
    template="Havia um homem, na terra de Uz, por nome ___",
    feedbackCorrect="Certo: o nome do íntegro é Jó.",
    feedbackWrong={"a": "Uz é a terra, não o nome desta lacuna.", "c": "Íntegro é o caráter, não o nome."},
    options=[{"id": "a", "text": "Uz"}, {"id": "b", "text": "Jó"}, {"id": "c", "text": "íntegro"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="pro", nn="06", difficulty="profundezas", skill="interpret", type="connect",
    **qtext("O que Jó 1:1 comunica que se liga a este contexto?"),
    passageA={"ref": R1, "text": P1},
    passageB={"ref": "Contexto", "text": INS1},
    feedbackCorrect="Certo: temor e desvio do mal antecedem a prova.",
    feedbackWrong={"a": "O versículo não funda a teologia fácil da culpa.", "c": "Integridade aqui não é fachada."},
    options=[
        {"id": "a", "text": "Culpa como causa da dor"},
        {"id": "b", "text": "Temor antes da ruína"},
        {"id": "c", "text": "Integridade só de fachada"},
    ],
    correctOptionId="b", correctAnswer="b"))

# Fix M1 profundezas complete: question must match template
OUT[-2]["question"] = 'Complete a frase: "Havia um homem, na terra de Uz, por nome ___"'
OUT[-2]["prompt"] = OUT[-2]["question"]
OUT[-2]["cue"] = OUT[-2]["question"]

# ---------------------------------------------------------------------------
# M2 — Perda e adoração
# ---------------------------------------------------------------------------
P2 = "e disse: Nu saí do ventre de minha mãe e nu tornarei para lá. Jeová deu e Jeová tirou; bendito seja o nome de Jeová."
R2 = "Jó 1:21"
S2 = "jo-prova-02-perda-e-adoracao"
LO2 = "Perceber que, na perda, Jó confessa: Jeová deu e tirou, e o nome de Jeová permanece bendito."
E2 = ["Jó 1:21"]
B2 = dict(trail=TRAIL, section=S2, verse_ref=R2, lo=LO2, evidence=E2, passage=P2)
INS2 = "Perda e adoração: Jeová deu e tirou — o nome de Jeová é bendito no chão da ruína."

OUT.append(pack(**B2, short="sem", nn="01", difficulty="semente", skill="observe", type="true_false",
    **qtext("Jó disse que Jeová deu e Jeová tirou."),
    feedbackCorrect="Certo: essa é a fala de Jó em 1:21.",
    feedbackWrong={"false": "Releia: Jeová deu e Jeová tirou."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B2, short="sem", nn="02", difficulty="semente", skill="observe", type="tap",
    **qtext('Em Jó 1:21, toque a palavra que falta em "Jeová deu e Jeová ___; bendito seja o nome de Jeová"?'),
    template="Jeová deu e Jeová ___; bendito seja o nome de Jeová",
    feedbackCorrect="Exato: Jeová tirou, e ainda assim o nome é bendito.",
    feedbackWrong={"b": "Ventre pertence à fala sobre nascer nu.", "c": "Mãe está na primeira frase, não nesta lacuna."},
    options=[{"id": "a", "text": "tirou"}, {"id": "b", "text": "ventre"}, {"id": "c", "text": "mãe"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B2, short="sem", nn="03", difficulty="semente", skill="observe", type="choice",
    **qtext("O que Jó afirma literalmente em Jó 1:21?"),
    feedbackCorrect="Certo: deu, tirou, e o nome de Jeová é bendito.",
    feedbackWrong={
        "a": "O texto não amaldiçoa o nome de Jeová.",
        "c": "Ele não diz que saiu vestido do ventre.",
        "d": "Jeová deu e também tirou, não só deu.",
    },
    options=[
        {"id": "a", "text": "Amaldiçoou o nome de Jeová no chão da ruína"},
        {"id": "b", "text": "Jeová deu e Jeová tirou; bendito seja o nome de Jeová"},
        {"id": "c", "text": "Saiu vestido do ventre e assim voltará"},
        {"id": "d", "text": "Jeová só deu e nunca tirou coisa alguma"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="sem", nn="04", difficulty="semente", skill="observe", type="order",
    **qtext("Qual sequência mostra a ordem dos fatos em Jó 1:21?"),
    feedbackCorrect="Certo: nu ao nascer, Jeová deu e tirou, nome bendito.",
    feedbackWrong={"a": "O louvor não abre a fala.", "c": "Dar e tirar vem depois da confissão de nudez."},
    options=[
        {"id": "a", "text": "bendito seja o nome de Jeová"},
        {"id": "b", "text": "Nu saí do ventre de minha mãe e nu tornarei para lá"},
        {"id": "c", "text": "Jeová deu e Jeová tirou"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="sem", nn="05", difficulty="semente", skill="observe", type="complete",
    **qtext("Complete a frase: \"Nu saí do ___ de minha mãe e nu tornarei para lá\""),
    template="Nu saí do ___ de minha mãe e nu tornarei para lá",
    feedbackCorrect="Certo: a imagem é o ventre — nu ao sair.",
    feedbackWrong={"a": "Tirou vem na frase sobre Jeová.", "c": "Nome pertence ao louvor final."},
    options=[{"id": "a", "text": "tirou"}, {"id": "b", "text": "ventre"}, {"id": "c", "text": "nome"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="sem", nn="06", difficulty="semente", skill="observe", type="connect",
    **qtext("O que Jó 1:21 comunica que se liga a este contexto?"),
    passageA={"ref": R2, "text": P2},
    passageB={"ref": "Contexto", "text": INS2},
    feedbackCorrect="Certo: deu e tirou, e o nome permanece bendito.",
    feedbackWrong={"a": "O texto não cala o nome de Jeová.", "c": "Jó não amaldiçoa; bendiz."},
    options=[
        {"id": "a", "text": "Silêncio sobre o nome"},
        {"id": "b", "text": "Jeová deu e tirou"},
        {"id": "c", "text": "Maldição no chão da ruína"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B2, short="cam", nn="01", difficulty="caminhada", skill="understand", type="true_false",
    **qtext("Depois de confessar que Jeová deu e tirou, Jó declara bendito o nome de Jeová."),
    feedbackCorrect="Certo: o louvor segue a confissão da perda.",
    feedbackWrong={"false": "O versículo fecha com: bendito seja o nome de Jeová."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B2, short="cam", nn="02", difficulty="caminhada", skill="understand", type="tap",
    **qtext('Em Jó 1:21, toque a palavra que falta em "Nu ___ do ventre de minha mãe e nu tornarei para lá"?'),
    template="Nu ___ do ventre de minha mãe e nu tornarei para lá",
    feedbackCorrect="Exato: nu saí — a perda ecoa o nascimento.",
    feedbackWrong={"b": "Tirou é o verbo de Jeová, não desta lacuna.", "c": "Nome pertence ao louvor."},
    options=[{"id": "a", "text": "saí"}, {"id": "b", "text": "tirou"}, {"id": "c", "text": "nome"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B2, short="cam", nn="03", difficulty="caminhada", skill="understand", type="choice",
    **qtext("Como se relacionam perda e louvor em Jó 1:21?"),
    feedbackCorrect="Certo: a nudez e o tirar não cancelam o nome bendito.",
    feedbackWrong={
        "a": "O louvor não espera a restituição.",
        "c": "Jó não acusa Jeová de injustiça neste verso.",
        "d": "Dar e tirar estão na mesma boca que bendiz.",
    },
    options=[
        {"id": "a", "text": "O louvor só viria se nada tivesse sido tirado"},
        {"id": "b", "text": "Confessar que Jeová tirou convive com bendizer o nome"},
        {"id": "c", "text": "Jó usa a perda para acusar Jeová de injustiça"},
        {"id": "d", "text": "Dar e tirar são frases de outro, não da boca de Jó"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="cam", nn="04", difficulty="caminhada", skill="understand", type="order",
    **qtext("Como se encadeiam os eventos de Jó 1:21?"),
    feedbackCorrect="Certo: nudez, dar e tirar, depois o nome bendito.",
    feedbackWrong={"a": "O louvor não é o primeiro elo.", "b": "Dar e tirar não fecham a fala."},
    options=[
        {"id": "a", "text": "bendito seja o nome de Jeová"},
        {"id": "b", "text": "Jeová deu e Jeová tirou"},
        {"id": "c", "text": "Nu saí do ventre e nu tornarei"},
    ],
    correctOrder=["c", "b", "a"], correctOptionId="c", correctAnswer="c"))
OUT.append(pack(**B2, short="cam", nn="05", difficulty="caminhada", skill="understand", type="complete",
    **qtext("Complete a frase: \"bendito seja o ___ de Jeová\""),
    template="bendito seja o ___ de Jeová",
    feedbackCorrect="Certo: o que permanece bendito é o nome.",
    feedbackWrong={"a": "Ventre pertence à primeira frase.", "c": "Saí é o verbo da nudez."},
    options=[{"id": "a", "text": "ventre"}, {"id": "b", "text": "nome"}, {"id": "c", "text": "saí"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="cam", nn="06", difficulty="caminhada", skill="understand", type="connect",
    **qtext("O que Jó 1:21 comunica que se liga a este contexto?"),
    passageA={"ref": R2, "text": P2},
    passageB={"ref": "Contexto", "text": INS2},
    feedbackCorrect="Certo: o nome é bendito no chão da ruína.",
    feedbackWrong={"a": "O texto não exige restituição para louvar.", "c": "A fala é de Jó, não de um amigo."},
    options=[
        {"id": "a", "text": "Louvor só após a restituição"},
        {"id": "b", "text": "Nome bendito na ruína"},
        {"id": "c", "text": "Acusação posta na boca alheia"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B2, short="pro", nn="01", difficulty="profundezas", skill="interpret", type="true_false",
    **qtext("A ruína apaga o nome de Jeová da boca de Jó em Jó 1:21."),
    feedbackCorrect="Certo: o nome permanece bendito, mesmo depois de Jeová tirar.",
    feedbackWrong={"true": "O versículo fecha bendizendo o nome de Jeová."},
    options=TF, correctOptionId="false", correctAnswer="false"))
OUT.append(pack(**B2, short="pro", nn="02", difficulty="profundezas", skill="interpret", type="tap",
    **qtext('Em Jó 1:21, toque a palavra que falta em "bendito seja o nome de ___"?'),
    template="bendito seja o nome de ___",
    feedbackCorrect="Exato: o nome bendito é o de Jeová.",
    feedbackWrong={"b": "Ventre pertence à imagem da nudez.", "c": "Saí é o verbo do nascimento."},
    options=[{"id": "a", "text": "Jeová"}, {"id": "b", "text": "ventre"}, {"id": "c", "text": "saí"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B2, short="pro", nn="03", difficulty="profundezas", skill="interpret", type="choice",
    **qtext("Que sentido teológico Jó 1:21 sustenta na perda?"),
    feedbackCorrect="Certo: Jeová deu e tirou, e o nome é bendito na ruína.",
    feedbackWrong={
        "a": "O texto não trata a perda como prova de culpa.",
        "c": "Bendizer o nome não é negar que Jeová tirou.",
        "d": "A nudez não autoriza amaldiçoar o nome.",
    },
    options=[
        {"id": "a", "text": "Tirar prova que Jó era culpado desde o ventre"},
        {"id": "b", "text": "Jeová deu e tirou, e o nome permanece bendito na ruína"},
        {"id": "c", "text": "Bendizer o nome significa fingir que nada foi tirado"},
        {"id": "d", "text": "A nudez autoriza amaldiçoar o nome de Jeová"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="pro", nn="04", difficulty="profundezas", skill="interpret", type="order",
    **qtext("Qual sequência revela o sentido de Jó 1:21?"),
    feedbackCorrect="Certo: o sentido vai da nudez ao nome bendito.",
    feedbackWrong={"a": "O louvor não é o primeiro movimento do sentido.", "c": "Dar e tirar não fecham o sentido."},
    options=[
        {"id": "a", "text": "O nome de Jeová é declarado bendito"},
        {"id": "b", "text": "A nudez do nascer ecoa o tornar para lá"},
        {"id": "c", "text": "Jeová é confessado como quem deu e tirou"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="pro", nn="05", difficulty="profundezas", skill="interpret", type="complete",
    **qtext("Complete a frase: \"Jeová deu e Jeová tirou; ___ seja o nome de Jeová\""),
    template="Jeová deu e Jeová tirou; ___ seja o nome de Jeová",
    feedbackCorrect="Certo: o adjetivo do nome é bendito.",
    feedbackWrong={"a": "Saí pertence à frase da nudez.", "c": "Ventre não preenche este louvor."},
    options=[{"id": "a", "text": "saí"}, {"id": "b", "text": "bendito"}, {"id": "c", "text": "ventre"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="pro", nn="06", difficulty="profundezas", skill="interpret", type="connect",
    **qtext("O que Jó 1:21 comunica que se liga a este contexto?"),
    passageA={"ref": R2, "text": P2},
    passageB={"ref": "Contexto", "text": INS2},
    feedbackCorrect="Certo: adorar no chão da ruína, sem apagar o nome.",
    feedbackWrong={"a": "A perda não cancela o louvor neste verso.", "c": "Jó não troca Jeová por outro nome."},
    options=[
        {"id": "a", "text": "Ruína que silencia o louvor"},
        {"id": "b", "text": "Adoração no chão da ruína"},
        {"id": "c", "text": "Troca do nome de Jeová"},
    ],
    correctOptionId="b", correctAnswer="b"))

# ---------------------------------------------------------------------------
# M3 — Amigos e acusações (Deus interrompe o debate: Jó 38:4)
# ---------------------------------------------------------------------------
P3 = "Onde estavas tu quando eu lançava os fundamentos da terra? Dize-mo, se tens entendimento."
R3 = "Jó 38:4"
S3 = "jo-dialogo-01-amigos-e-acusacoes"
LO3 = "Perceber que, após as acusações dos amigos, Deus pergunta de outro lugar: onde estavas tu na fundação da terra."
E3 = ["Jó 38:4"]
B3 = dict(trail=TRAIL, section=S3, verse_ref=R3, lo=LO3, evidence=E3, passage=P3)
INS3 = "Os amigos acusaram; Deus pergunta de outro lugar: onde estavas tu na fundação da terra?"

OUT.append(pack(**B3, short="sem", nn="01", difficulty="semente", skill="observe", type="true_false",
    **qtext("Deus pergunta a Jó onde ele estava quando Deus lançava os fundamentos da terra."),
    feedbackCorrect="Certo: Jó 38:4 formula essa pergunta a Jó.",
    feedbackWrong={"false": "O texto pergunta: onde estavas tu na fundação da terra."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B3, short="sem", nn="02", difficulty="semente", skill="observe", type="tap",
    **qtext('Em Jó 38:4, toque a palavra que falta em "quando eu lançava os ___ da terra"?'),
    template="quando eu lançava os ___ da terra",
    feedbackCorrect="Exato: a pergunta é sobre os fundamentos da terra.",
    feedbackWrong={"b": "Entendimento fecha o versículo.", "c": "Tu é o vocativo, não esta lacuna."},
    options=[{"id": "a", "text": "fundamentos"}, {"id": "b", "text": "entendimento"}, {"id": "c", "text": "tu"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B3, short="sem", nn="03", difficulty="semente", skill="observe", type="choice",
    **qtext("O que o texto de Jó 38:4 registra como fala de Deus?"),
    feedbackCorrect="Certo: Deus pergunta pela presença de Jó na fundação.",
    feedbackWrong={
        "a": "O versículo não confirma que Jó estava lá.",
        "c": "Não é um amigo quem fala neste verso.",
        "d": "Deus não declara que Jó lançou os fundamentos.",
    },
    options=[
        {"id": "a", "text": "Jó esteve presente e ajudou a lançar a terra"},
        {"id": "b", "text": "Deus pergunta onde Jó estava ao lançar os fundamentos"},
        {"id": "c", "text": "Um amigo explica a Jó a origem da terra"},
        {"id": "d", "text": "Deus afirma que Jó lançou os fundamentos sozinho"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="sem", nn="04", difficulty="semente", skill="observe", type="order",
    **qtext("Qual sequência mostra a ordem dos fatos em Jó 38:4?"),
    feedbackCorrect="Certo: onde estavas, os fundamentos, depois o desafio ao entendimento.",
    feedbackWrong={"a": "O desafio ao entendimento não abre o verso.", "c": "Os fundamentos vêm no meio da pergunta."},
    options=[
        {"id": "a", "text": "Dize-mo, se tens entendimento"},
        {"id": "b", "text": "Onde estavas tu"},
        {"id": "c", "text": "quando eu lançava os fundamentos da terra"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="sem", nn="05", difficulty="semente", skill="observe", type="complete",
    **qtext("Complete a frase: \"Dize-mo, se tens ___\""),
    template="Dize-mo, se tens ___",
    feedbackCorrect="Certo: o desafio é se tens entendimento.",
    feedbackWrong={"a": "Fundamentos pertencem à pergunta anterior.", "c": "Terra é o objeto da fundação."},
    options=[{"id": "a", "text": "fundamentos"}, {"id": "b", "text": "entendimento"}, {"id": "c", "text": "terra"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="sem", nn="06", difficulty="semente", skill="observe", type="connect",
    **qtext("O que Jó 38:4 comunica que se liga a este contexto?"),
    passageA={"ref": R3, "text": P3},
    passageB={"ref": "Contexto", "text": INS3},
    feedbackCorrect="Certo: Deus pergunta pela fundação, não pela acusação fácil.",
    feedbackWrong={"a": "O verso não confirma a acusação dos amigos.", "c": "A pergunta é de Deus, não um silêncio."},
    options=[
        {"id": "a", "text": "Confirmação das acusações"},
        {"id": "b", "text": "Pergunta na fundação da terra"},
        {"id": "c", "text": "Silêncio de Deus no debate"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B3, short="cam", nn="01", difficulty="caminhada", skill="understand", type="true_false",
    **qtext("Jó 38:4 trata Jó como testemunha ocular que ajudou a lançar os fundamentos da terra."),
    feedbackCorrect="Certo: a pergunta expõe que Jó não estava lá.",
    feedbackWrong={"true": "Onde estavas tu implica ausência, não colaboração."},
    options=TF, correctOptionId="false", correctAnswer="false"))
OUT.append(pack(**B3, short="cam", nn="02", difficulty="caminhada", skill="understand", type="tap",
    **qtext('Em Jó 38:4, toque a palavra que falta em "Onde ___ tu quando eu lançava os fundamentos da terra"?'),
    template="Onde ___ tu quando eu lançava os fundamentos da terra",
    feedbackCorrect="Exato: a pergunta é onde estavas tu.",
    feedbackWrong={"b": "Terra é o objeto da fundação.", "c": "Entendimento fecha o versículo."},
    options=[{"id": "a", "text": "estavas"}, {"id": "b", "text": "terra"}, {"id": "c", "text": "entendimento"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B3, short="cam", nn="03", difficulty="caminhada", skill="understand", type="choice",
    **qtext("Como a pergunta de Jó 38:4 desloca o debate das acusações dos amigos?"),
    feedbackCorrect="Certo: Deus fala da criação, onde Jó não esteve.",
    feedbackWrong={
        "a": "Deus não homologa a teologia rasa dos amigos.",
        "c": "O verso não convida Jó a retomar a acusação.",
        "d": "Não há aqui um veredito de culpa de Jó.",
    },
    options=[
        {"id": "a", "text": "Deus confirma que os amigos acertaram a causa da dor"},
        {"id": "b", "text": "Deus pergunta de outro lugar: a fundação da terra"},
        {"id": "c", "text": "Deus manda Jó repetir as acusações dos amigos"},
        {"id": "d", "text": "Deus declara Jó culpado com a mesma lógica dos amigos"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="cam", nn="04", difficulty="caminhada", skill="understand", type="order",
    **qtext("Como se encadeiam os eventos de Jó 38:4?"),
    feedbackCorrect="Certo: ausência de Jó, ato criador, desafio ao entendimento.",
    feedbackWrong={"a": "O entendimento não abre o encadeamento.", "c": "Lançar os fundamentos não é o último elo."},
    options=[
        {"id": "a", "text": "Dize-mo, se tens entendimento"},
        {"id": "b", "text": "Onde estavas tu"},
        {"id": "c", "text": "quando eu lançava os fundamentos da terra"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="cam", nn="05", difficulty="caminhada", skill="understand", type="complete",
    **qtext("Complete a frase: \"quando eu ___ os fundamentos da terra\""),
    template="quando eu ___ os fundamentos da terra",
    feedbackCorrect="Certo: o verbo criador é lançava.",
    feedbackWrong={"a": "Entendimento pertence ao desafio final.", "c": "Onde abre a pergunta, não esta lacuna."},
    options=[{"id": "a", "text": "entendimento"}, {"id": "b", "text": "lançava"}, {"id": "c", "text": "Onde"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="cam", nn="06", difficulty="caminhada", skill="understand", type="connect",
    **qtext("O que Jó 38:4 comunica que se liga a este contexto?"),
    passageA={"ref": R3, "text": P3},
    passageB={"ref": "Contexto", "text": INS3},
    feedbackCorrect="Certo: o debate sai da acusação e entra na criação.",
    feedbackWrong={"a": "Deus não endossa a teologia rasa.", "c": "A pergunta não replica o tribunal dos amigos."},
    options=[
        {"id": "a", "text": "Endosso à teologia rasa"},
        {"id": "b", "text": "Debate deslocado à criação"},
        {"id": "c", "text": "Mesmo tribunal dos amigos"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B3, short="pro", nn="01", difficulty="profundezas", skill="interpret", type="true_false",
    **qtext("A pergunta de Deus em Jó 38:4 desloca o debate das acusações dos amigos para a criação, onde Jó não estava."),
    feedbackCorrect="Certo: o redemoinho responde de outro lugar, não com a lógica dos amigos.",
    feedbackWrong={"false": "Onde estavas tu na fundação muda o chão do debate."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B3, short="pro", nn="02", difficulty="profundezas", skill="interpret", type="tap",
    **qtext('Em Jó 38:4, toque a palavra que falta em "quando eu lançava os fundamentos da ___"?'),
    template="quando eu lançava os fundamentos da ___",
    feedbackCorrect="Exato: os fundamentos são da terra.",
    feedbackWrong={"a": "Entendimento é o desafio final.", "c": "Onde abre a pergunta."},
    options=[{"id": "a", "text": "entendimento"}, {"id": "b", "text": "terra"}, {"id": "c", "text": "Onde"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="pro", nn="03", difficulty="profundezas", skill="interpret", type="choice",
    **qtext("Que leitura teológica Jó 38:4 sustenta diante das acusações dos amigos?"),
    feedbackCorrect="Certo: Deus não replica a teologia fácil; pergunta pela criação.",
    feedbackWrong={
        "a": "O verso não homologa a culpa inventada.",
        "c": "Deus não se cala: pergunta de outro lugar.",
        "d": "A fundação da terra não é prova de que os amigos tinham razão.",
    },
    options=[
        {"id": "a", "text": "Deus adota a tese dos amigos: dor igual a culpa"},
        {"id": "b", "text": "Deus interrompe o debate perguntando pela fundação da terra"},
        {"id": "c", "text": "Deus se cala e deixa as acusações como última palavra"},
        {"id": "d", "text": "A criação confirma que os amigos leram Jó corretamente"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="pro", nn="04", difficulty="profundezas", skill="interpret", type="order",
    **qtext("Qual sequência revela o sentido de Jó 38:4?"),
    feedbackCorrect="Certo: o sentido vai da ausência de Jó ao limite do entendimento.",
    feedbackWrong={"a": "O entendimento não é o primeiro movimento.", "c": "A fundação não fecha o sentido."},
    options=[
        {"id": "a", "text": "O entendimento de Jó é desafiado"},
        {"id": "b", "text": "Jó é perguntado onde estava"},
        {"id": "c", "text": "Deus aponta o lançar os fundamentos da terra"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="pro", nn="05", difficulty="profundezas", skill="interpret", type="complete",
    **qtext("Complete a frase: \"Dize-mo, se ___ entendimento\""),
    template="Dize-mo, se ___ entendimento",
    feedbackCorrect="Certo: o desafio é se tens entendimento.",
    feedbackWrong={"a": "Lançava pertence à pergunta da fundação.", "c": "Fundamentos não preenche esta lacuna."},
    options=[{"id": "a", "text": "lançava"}, {"id": "b", "text": "tens"}, {"id": "c", "text": "fundamentos"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="pro", nn="06", difficulty="profundezas", skill="interpret", type="connect",
    **qtext("O que Jó 38:4 comunica que se liga a este contexto?"),
    passageA={"ref": R3, "text": P3},
    passageB={"ref": "Contexto", "text": INS3},
    feedbackCorrect="Certo: Deus fala de outro lugar, não da acusação.",
    feedbackWrong={"a": "A fala divina não copia os amigos.", "c": "Não há aqui sentença de culpa fácil."},
    options=[
        {"id": "a", "text": "Cópia da acusação dos amigos"},
        {"id": "b", "text": "Deus fala de outro lugar"},
        {"id": "c", "text": "Sentença fácil de culpa"},
    ],
    correctOptionId="b", correctAnswer="b"))

# ---------------------------------------------------------------------------
# M4 — Deus responde (visão e arrependimento)
# ---------------------------------------------------------------------------
P4 = "Eu tinha ouvido de ti com os ouvidos; mas, agora, te veem os meus olhos. Pelo que me abomino a mim mesmo e me arrependo no pó e na cinza."
R4 = "Jó 42:5–6"
S4 = "jo-dialogo-02-deus-responde"
LO4 = "Reconhecer que, após Deus responder, Jó passa de ouvir a ver, e o pó é lugar de arrependimento, não de acusação."
E4 = ["Jó 42:5", "Jó 42:6"]
B4 = dict(trail=TRAIL, section=S4, verse_ref=R4, lo=LO4, evidence=E4, passage=P4)
INS4 = "Deus responde e Jó vê: ouvir vira visão, e o pó é lugar de arrependimento, não de acusação."

OUT.append(pack(**B4, short="sem", nn="01", difficulty="semente", skill="observe", type="true_false",
    **qtext("Jó diz que tinha ouvido de Deus com os ouvidos, mas agora os olhos o veem."),
    feedbackCorrect="Certo: Jó 42:5 contrapõe ouvidos e olhos.",
    feedbackWrong={"false": "Releia: ouvido com os ouvidos; agora te veem os olhos."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B4, short="sem", nn="02", difficulty="semente", skill="observe", type="tap",
    **qtext('Em Jó 42:5–6, toque a palavra que falta em "mas, agora, te veem os meus ___"?'),
    template="mas, agora, te veem os meus ___",
    feedbackCorrect="Exato: agora te veem os meus olhos.",
    feedbackWrong={"b": "Pó pertence ao arrependimento.", "c": "Cinza fecha o versículo 6."},
    options=[{"id": "a", "text": "olhos"}, {"id": "b", "text": "pó"}, {"id": "c", "text": "cinza"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B4, short="sem", nn="03", difficulty="semente", skill="observe", type="choice",
    **qtext("O que Jó declara em Jó 42:5–6 depois de ver?"),
    feedbackCorrect="Certo: abomina-se e se arrepende no pó e na cinza.",
    feedbackWrong={
        "a": "O texto não o mostra acusando os amigos neste ponto.",
        "c": "Ele não diz que só ouviu e nunca viu.",
        "d": "O arrependimento é no pó e na cinza, não no trono.",
    },
    options=[
        {"id": "a", "text": "Acusa os amigos no pó e na cinza"},
        {"id": "b", "text": "Abomina-se a si mesmo e se arrepende no pó e na cinza"},
        {"id": "c", "text": "Afirma que ainda só ouviu, sem nenhum ver"},
        {"id": "d", "text": "Arrepende-se sentado num trono, não no pó"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="sem", nn="04", difficulty="semente", skill="observe", type="order",
    **qtext("Qual sequência mostra a ordem dos fatos em Jó 42:5–6?"),
    feedbackCorrect="Certo: ouvir, ver, então o arrependimento no pó.",
    feedbackWrong={"a": "O pó não abre a fala.", "c": "O ver vem depois do ouvir."},
    options=[
        {"id": "a", "text": "me abomino a mim mesmo e me arrependo no pó e na cinza"},
        {"id": "b", "text": "Eu tinha ouvido de ti com os ouvidos"},
        {"id": "c", "text": "mas, agora, te veem os meus olhos"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="sem", nn="05", difficulty="semente", skill="observe", type="complete",
    **qtext("Complete a frase: \"me arrependo no ___ e na cinza\""),
    template="me arrependo no ___ e na cinza",
    feedbackCorrect="Certo: o lugar nomeado é o pó.",
    feedbackWrong={"a": "Ouvidos pertencem ao ouvir anterior.", "c": "Olhos pertencem ao ver."},
    options=[{"id": "a", "text": "ouvidos"}, {"id": "b", "text": "pó"}, {"id": "c", "text": "olhos"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="sem", nn="06", difficulty="semente", skill="observe", type="connect",
    **qtext("O que Jó 42:5–6 comunica que se liga a este contexto?"),
    passageA={"ref": R4, "text": P4},
    passageB={"ref": "Contexto", "text": INS4},
    feedbackCorrect="Certo: ouvir vira visão, e o pó é arrependimento.",
    feedbackWrong={"a": "O texto não permanece só no ouvir.", "c": "O pó não é tribunal contra os amigos."},
    options=[
        {"id": "a", "text": "Ouvir sem jamais ver"},
        {"id": "b", "text": "Ouvir que vira visão"},
        {"id": "c", "text": "Pó como acusação dos amigos"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B4, short="cam", nn="01", difficulty="caminhada", skill="understand", type="true_false",
    **qtext("Jó afirma que agora os olhos veem, e por isso se abomina e se arrepende no pó e na cinza."),
    feedbackCorrect="Certo: o ver precede o arrependimento no pó.",
    feedbackWrong={"false": "42:5–6 une visão, abominação de si e pó."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B4, short="cam", nn="02", difficulty="caminhada", skill="understand", type="tap",
    **qtext('Em Jó 42:5–6, toque a palavra que falta em "Eu tinha ___ de ti com os ouvidos"?'),
    template="Eu tinha ___ de ti com os ouvidos",
    feedbackCorrect="Exato: o passado é ouvido, não ainda visão.",
    feedbackWrong={"b": "Pó pertence ao v. 6.", "c": "Cinza fecha o arrependimento."},
    options=[{"id": "a", "text": "ouvido"}, {"id": "b", "text": "pó"}, {"id": "c", "text": "cinza"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B4, short="cam", nn="03", difficulty="caminhada", skill="understand", type="choice",
    **qtext("Como se relacionam ouvir, ver e o pó em Jó 42:5–6?"),
    feedbackCorrect="Certo: a visão desloca Jó do debate para o arrependimento.",
    feedbackWrong={
        "a": "O ver não o leva a acusar os amigos neste texto.",
        "c": "O pó não cancela o ver; segue-o.",
        "d": "Ouvir e ver não são tratados como idênticos.",
    },
    options=[
        {"id": "a", "text": "Ver serve para Jó acusar os amigos com mais força"},
        {"id": "b", "text": "O ver sucede o ouvir e leva ao arrependimento no pó"},
        {"id": "c", "text": "O pó apaga a visão e devolve Jó só aos ouvidos"},
        {"id": "d", "text": "Ouvir e ver são a mesma coisa, sem nenhum agora"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="cam", nn="04", difficulty="caminhada", skill="understand", type="order",
    **qtext("Como se encadeiam os eventos de Jó 42:5–6?"),
    feedbackCorrect="Certo: ouvidos, olhos, depois o pó e a cinza.",
    feedbackWrong={"a": "O arrependimento não abre o encadeamento.", "c": "Os olhos não são o último elo."},
    options=[
        {"id": "a", "text": "me arrependo no pó e na cinza"},
        {"id": "b", "text": "tinha ouvido de ti com os ouvidos"},
        {"id": "c", "text": "agora te veem os meus olhos"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="cam", nn="05", difficulty="caminhada", skill="understand", type="complete",
    **qtext("Complete a frase: \"me abomino a mim mesmo e me ___ no pó e na cinza\""),
    template="me abomino a mim mesmo e me ___ no pó e na cinza",
    feedbackCorrect="Certo: o verbo no pó é arrependo.",
    feedbackWrong={"a": "Ouvidos pertencem ao v. 5.", "c": "Olhos pertencem ao ver."},
    options=[{"id": "a", "text": "ouvidos"}, {"id": "b", "text": "arrependo"}, {"id": "c", "text": "olhos"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="cam", nn="06", difficulty="caminhada", skill="understand", type="connect",
    **qtext("O que Jó 42:5–6 comunica que se liga a este contexto?"),
    passageA={"ref": R4, "text": P4},
    passageB={"ref": "Contexto", "text": INS4},
    feedbackCorrect="Certo: o pó é arrependimento, não acusação.",
    feedbackWrong={"a": "O texto não usa o pó para atacar os amigos.", "c": "Há um agora da visão, não só rumor."},
    options=[
        {"id": "a", "text": "Pó como arma contra amigos"},
        {"id": "b", "text": "Pó como lugar de arrependimento"},
        {"id": "c", "text": "Visão recusada, só rumor"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B4, short="pro", nn="01", difficulty="profundezas", skill="interpret", type="true_false",
    **qtext("Em Jó 42:5–6 o pó e a cinza são o lugar de Jó acusar os amigos."),
    feedbackCorrect="Certo: o pó é arrependimento de si, não acusação.",
    feedbackWrong={"true": "Ele se abomina e se arrepende, não acusa os amigos ali."},
    options=TF, correctOptionId="false", correctAnswer="false"))
OUT.append(pack(**B4, short="pro", nn="02", difficulty="profundezas", skill="interpret", type="tap",
    **qtext('Em Jó 42:5–6, toque a palavra que falta em "me arrependo no pó e na ___"?'),
    template="me arrependo no pó e na ___",
    feedbackCorrect="Exato: pó e cinza — o chão do arrependimento.",
    feedbackWrong={"a": "Ouvido pertence ao passado do v. 5.", "c": "Olhos pertencem ao ver."},
    options=[{"id": "a", "text": "ouvido"}, {"id": "b", "text": "cinza"}, {"id": "c", "text": "olhos"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="pro", nn="03", difficulty="profundezas", skill="interpret", type="choice",
    **qtext("Que leitura teológica Jó 42:5–6 sustenta depois de Deus responder?"),
    feedbackCorrect="Certo: visão de Deus leva ao pó, não à acusação.",
    feedbackWrong={
        "a": "O texto não trata o ver como triunfo sobre os amigos.",
        "c": "Ouvir não é descartado como inútil; é superado pelo ver.",
        "d": "Abominar-se não é fingimento para recuperar bens.",
    },
    options=[
        {"id": "a", "text": "Ver a Deus serve para Jó vencer o debate com os amigos"},
        {"id": "b", "text": "Ouvir vira visão, e o pó é arrependimento, não acusação"},
        {"id": "c", "text": "Ouvir de Deus era inútil e deve ser apagado da memória"},
        {"id": "d", "text": "Abominar-se é estratégia para recuperar o que foi tirado"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="pro", nn="04", difficulty="profundezas", skill="interpret", type="order",
    **qtext("Qual sequência revela o sentido de Jó 42:5–6?"),
    feedbackCorrect="Certo: o sentido vai do rumor à visão e ao pó.",
    feedbackWrong={"a": "O pó não é o primeiro movimento do sentido.", "c": "A visão não fecha a sequência."},
    options=[
        {"id": "a", "text": "O pó e a cinza recebem o arrependimento"},
        {"id": "b", "text": "O ouvir de ouvidos é confessado como passado"},
        {"id": "c", "text": "Agora os olhos veem"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="pro", nn="05", difficulty="profundezas", skill="interpret", type="complete",
    **qtext("Complete a frase: \"mas, agora, te ___ os meus olhos\""),
    template="mas, agora, te ___ os meus olhos",
    feedbackCorrect="Certo: o verbo da visão é veem.",
    feedbackWrong={"a": "Cinza pertence ao v. 6.", "c": "Pó é o lugar do arrependimento."},
    options=[{"id": "a", "text": "cinza"}, {"id": "b", "text": "veem"}, {"id": "c", "text": "pó"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="pro", nn="06", difficulty="profundezas", skill="interpret", type="connect",
    **qtext("O que Jó 42:5–6 comunica que se liga a este contexto?"),
    passageA={"ref": R4, "text": P4},
    passageB={"ref": "Contexto", "text": INS4},
    feedbackCorrect="Certo: Deus responde, e Jó vê até o pó.",
    feedbackWrong={"a": "A resposta divina não o deixa só no rumor.", "c": "O pó não é palco de acusação."},
    options=[
        {"id": "a", "text": "Resposta que deixa só o rumor"},
        {"id": "b", "text": "Visão que leva ao pó"},
        {"id": "c", "text": "Pó como palco de acusação"},
    ],
    correctOptionId="b", correctAnswer="b"))

# ---------------------------------------------------------------------------
# M5 — Desafio: sofrimento (1:21 + 42:5)
# ---------------------------------------------------------------------------
P5 = "Nu saí do ventre de minha mãe e nu tornarei para lá. Jeová deu e Jeová tirou; bendito seja o nome de Jeová. Eu tinha ouvido de ti com os ouvidos; mas, agora, te veem os meus olhos."
R5 = "Jó 1:21; 42:5"
S5 = "jo-dialogo-03-desafio-sofrimento"
LO5 = "Unir perda e visão: Jeová deu e tirou, e no fim os olhos veem — não a teologia fácil dos amigos."
E5 = ["Jó 1:21", "Jó 42:5"]
B5 = dict(trail=TRAIL, section=S5, verse_ref=R5, lo=LO5, evidence=E5, passage=P5)
INS5 = "Sofrimento: Jeová deu e tirou, e no fim os olhos veem — não a teologia fácil dos amigos."

OUT.append(pack(**B5, short="sem", nn="01", difficulty="semente", skill="observe", type="true_false",
    **qtext("Jó confessou que Jeová deu e Jeová tirou, e depois afirmou que agora os olhos veem."),
    feedbackCorrect="Certo: 1:21 e 42:5 unem o tirar e o ver.",
    feedbackWrong={"false": "Os dois textos ligam deu e tirou à visão."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B5, short="sem", nn="02", difficulty="semente", skill="observe", type="tap",
    **qtext('Em Jó 1:21; 42:5, toque a palavra que falta em "Jeová deu e Jeová ___"?'),
    template="Jeová deu e Jeová ___",
    feedbackCorrect="Exato: Jeová tirou — a perda é confessada.",
    feedbackWrong={"b": "Ouvidos pertencem a 42:5.", "c": "Olhos fecham a visão."},
    options=[{"id": "a", "text": "tirou"}, {"id": "b", "text": "ouvidos"}, {"id": "c", "text": "olhos"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B5, short="sem", nn="03", difficulty="semente", skill="observe", type="choice",
    **qtext("O que os trechos de Jó 1:21 e 42:5 afirmam juntos?"),
    feedbackCorrect="Certo: deu e tirou, e agora os olhos veem.",
    feedbackWrong={
        "a": "42:5 não diz que os olhos recusam ver.",
        "c": "1:21 não amaldiçoa o nome.",
        "d": "Há visão no fim, não só ouvir permanente.",
    },
    options=[
        {"id": "a", "text": "Jeová tirou, e os olhos recusam ver"},
        {"id": "b", "text": "Jeová deu e tirou; depois Jó diz que agora os olhos veem"},
        {"id": "c", "text": "Jó amaldiçoa o nome de Jeová após a perda"},
        {"id": "d", "text": "Jó permanece só no ouvir, sem nenhum agora da visão"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B5, short="sem", nn="04", difficulty="semente", skill="observe", type="order",
    **qtext("Qual sequência mostra a ordem dos fatos em Jó 1:21; 42:5?"),
    feedbackCorrect="Certo: nudez e tirar, nome bendito, depois os olhos.",
    feedbackWrong={"a": "Os olhos não abrem 1:21.", "c": "O nome bendito vem depois de deu e tirou."},
    options=[
        {"id": "a", "text": "agora te veem os meus olhos"},
        {"id": "b", "text": "Nu saí; Jeová deu e Jeová tirou"},
        {"id": "c", "text": "bendito seja o nome de Jeová"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B5, short="sem", nn="05", difficulty="semente", skill="observe", type="complete",
    **qtext("Complete a frase: \"mas, agora, te veem os meus ___\""),
    template="mas, agora, te veem os meus ___",
    feedbackCorrect="Certo: o fim confessado é os olhos.",
    feedbackWrong={"a": "Ventre pertence a 1:21.", "c": "Nome pertence ao louvor."},
    options=[{"id": "a", "text": "ventre"}, {"id": "b", "text": "olhos"}, {"id": "c", "text": "nome"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B5, short="sem", nn="06", difficulty="semente", skill="observe", type="connect",
    **qtext("O que Jó 1:21; 42:5 comunica que se liga a este contexto?"),
    passageA={"ref": R5, "text": "Jeová deu e Jeová tirou; bendito seja o nome de Jeová. Eu tinha ouvido de ti com os ouvidos; mas, agora, te veem os meus olhos."},
    passageB={"ref": "Contexto", "text": INS5},
    feedbackCorrect="Certo: deu e tirou, e no fim os olhos veem.",
    feedbackWrong={"a": "O arco não fica só na teologia dos amigos.", "c": "Há visão, não só rumor."},
    options=[
        {"id": "a", "text": "Teologia fácil dos amigos"},
        {"id": "b", "text": "Deu, tirou e depois vê"},
        {"id": "c", "text": "Só ouvir, nunca visão"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B5, short="cam", nn="01", difficulty="caminhada", skill="understand", type="true_false",
    **qtext("O arco de Jó 1:21 e 42:5 reduz o sofrimento à teologia fácil dos amigos, sem espaço para o ver."),
    feedbackCorrect="Certo: o fim é visão, não a acusação fácil.",
    feedbackWrong={"true": "42:5 põe os olhos; 1:21 não endossa os amigos."},
    options=TF, correctOptionId="false", correctAnswer="false"))
OUT.append(pack(**B5, short="cam", nn="02", difficulty="caminhada", skill="understand", type="tap",
    **qtext('Em Jó 1:21; 42:5, toque a palavra que falta em "Eu tinha ouvido de ti com os ___"?'),
    template="Eu tinha ouvido de ti com os ___",
    feedbackCorrect="Exato: o passado é ouvidos; o agora são os olhos.",
    feedbackWrong={"a": "Ventre pertence a 1:21.", "c": "Tirou é o verbo de Jeová."},
    options=[{"id": "a", "text": "ventre"}, {"id": "b", "text": "ouvidos"}, {"id": "c", "text": "tirou"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B5, short="cam", nn="03", difficulty="caminhada", skill="understand", type="choice",
    **qtext("Como 1:21 e 42:5 se encadeiam no sofrimento de Jó?"),
    feedbackCorrect="Certo: a perda confessada não impede o ver no fim.",
    feedbackWrong={
        "a": "O ver não cancela o deu e tirou.",
        "c": "O nome bendito em 1:21 não é teologia rasa dos amigos.",
        "d": "42:5 não devolve Jó à acusação alheia.",
    },
    options=[
        {"id": "a", "text": "O ver em 42:5 apaga que Jeová tirou em 1:21"},
        {"id": "b", "text": "Confessar o tirar convive com o agora em que os olhos veem"},
        {"id": "c", "text": "Bendizer o nome equivale a repetir as acusações dos amigos"},
        {"id": "d", "text": "A visão devolve Jó à teologia fácil da culpa"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B5, short="cam", nn="04", difficulty="caminhada", skill="understand", type="order",
    **qtext("Como se encadeiam os eventos de Jó 1:21; 42:5?"),
    feedbackCorrect="Certo: perda confessada, nome bendito, então visão.",
    feedbackWrong={"a": "A visão não abre o arco.", "b": "O nome bendito não é o último elo."},
    options=[
        {"id": "a", "text": "agora te veem os meus olhos"},
        {"id": "b", "text": "bendito seja o nome de Jeová"},
        {"id": "c", "text": "Jeová deu e Jeová tirou"},
    ],
    correctOrder=["c", "b", "a"], correctOptionId="c", correctAnswer="c"))
OUT.append(pack(**B5, short="cam", nn="05", difficulty="caminhada", skill="understand", type="complete",
    **qtext("Complete a frase: \"bendito seja o nome de ___\""),
    template="bendito seja o nome de ___",
    feedbackCorrect="Certo: o nome bendito é o de Jeová.",
    feedbackWrong={"a": "Olhos pertencem a 42:5.", "c": "Ventre pertence à nudez."},
    options=[{"id": "a", "text": "olhos"}, {"id": "b", "text": "Jeová"}, {"id": "c", "text": "ventre"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B5, short="cam", nn="06", difficulty="caminhada", skill="understand", type="connect",
    **qtext("O que Jó 1:21; 42:5 comunica que se liga a este contexto?"),
    passageA={"ref": R5, "text": "Jeová deu e Jeová tirou; bendito seja o nome de Jeová. mas, agora, te veem os meus olhos."},
    passageB={"ref": "Contexto", "text": INS5},
    feedbackCorrect="Certo: o sofrimento acaba em visão, não em teologia fácil.",
    feedbackWrong={"a": "Os amigos não fecham o arco.", "c": "O tirar não impede o ver."},
    options=[
        {"id": "a", "text": "Amigos como última palavra"},
        {"id": "b", "text": "Perda e visão no mesmo arco"},
        {"id": "c", "text": "Tirar que impede qualquer ver"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B5, short="pro", nn="01", difficulty="profundezas", skill="interpret", type="true_false",
    **qtext("Jó 1:21 e 42:5 juntos ensinam que o sofrimento se resolve na teologia fácil dos amigos, sem que os olhos vejam."),
    feedbackCorrect="Certo: o fim é visão, não a acusação fácil.",
    feedbackWrong={"true": "42:5 põe os olhos; o arco recusa a teologia rasa."},
    options=TF, correctOptionId="false", correctAnswer="false"))
OUT.append(pack(**B5, short="pro", nn="02", difficulty="profundezas", skill="interpret", type="tap",
    **qtext('Em Jó 1:21; 42:5, toque a palavra que falta em "Nu saí do ___ de minha mãe"?'),
    template="Nu saí do ___ de minha mãe",
    feedbackCorrect="Exato: a nudez do ventre abre a perda.",
    feedbackWrong={"b": "Olhos pertencem a 42:5.", "c": "Ouvidos pertencem ao ouvir."},
    options=[{"id": "a", "text": "ventre"}, {"id": "b", "text": "olhos"}, {"id": "c", "text": "ouvidos"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B5, short="pro", nn="03", difficulty="profundezas", skill="interpret", type="choice",
    **qtext("Que leitura teológica o arco de Jó 1:21 e 42:5 sustenta sobre o sofrimento?"),
    feedbackCorrect="Certo: deu e tirou, e os olhos veem — não a teologia fácil.",
    feedbackWrong={
        "a": "O ver não prova que os amigos tinham razão.",
        "c": "Bendizer o nome na perda não é teologia rasa da culpa.",
        "d": "O arco não apaga o tirar para ficar só no rumor.",
    },
    options=[
        {"id": "a", "text": "Os olhos veem para confirmar que a dor era culpa de Jó"},
        {"id": "b", "text": "Jeová deu e tirou, e no fim os olhos veem, sem a teologia fácil"},
        {"id": "c", "text": "Bendizer o nome na perda equivale a aceitar a acusação dos amigos"},
        {"id": "d", "text": "O sofrimento deve ser lido só como rumor, nunca como visão"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B5, short="pro", nn="04", difficulty="profundezas", skill="interpret", type="order",
    **qtext("Qual sequência revela o sentido de Jó 1:21; 42:5?"),
    feedbackCorrect="Certo: o sentido vai do tirar à visão, sem a teologia fácil.",
    feedbackWrong={"a": "A visão não é o primeiro movimento.", "c": "O nome bendito não fecha o sentido."},
    options=[
        {"id": "a", "text": "Os olhos veem, além do só ouvir"},
        {"id": "b", "text": "Jeová deu e tirou na perda"},
        {"id": "c", "text": "O nome de Jeová é bendito no chão da ruína"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B5, short="pro", nn="05", difficulty="profundezas", skill="interpret", type="complete",
    **qtext("Complete a frase: \"Nu saí do ventre de minha mãe e nu ___ para lá\""),
    template="Nu saí do ventre de minha mãe e nu ___ para lá",
    feedbackCorrect="Certo: nu tornarei — a perda ecoa o nascimento.",
    feedbackWrong={"a": "Olhos pertencem a 42:5.", "c": "Ouvidos pertencem ao ouvir."},
    options=[{"id": "a", "text": "olhos"}, {"id": "b", "text": "tornarei"}, {"id": "c", "text": "ouvidos"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B5, short="pro", nn="06", difficulty="profundezas", skill="interpret", type="connect",
    **qtext("O que Jó 1:21; 42:5 comunica que se liga a este contexto?"),
    passageA={"ref": R5, "text": "Jeová deu e Jeová tirou; bendito seja o nome de Jeová. mas, agora, te veem os meus olhos."},
    passageB={"ref": "Contexto", "text": INS5},
    feedbackCorrect="Certo: o sofrimento termina em visão, não em acusação fácil.",
    feedbackWrong={"a": "Os amigos não ditam o fim do arco.", "c": "O ver não restaura a tese da culpa."},
    options=[
        {"id": "a", "text": "Fim ditado pelos amigos"},
        {"id": "b", "text": "Sofrimento que acaba em visão"},
        {"id": "c", "text": "Visão que restaura a culpa"},
    ],
    correctOptionId="b", correctAnswer="b"))


def main():
    out = Path(__file__).with_name("jo.json")
    out.write_text(json.dumps(OUT, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(OUT)} questions to {out}")


if __name__ == "__main__":
    main()
