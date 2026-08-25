#!/usr/bin/env python3
"""Gera perguntas-v2/timoteo.json (72 itens)."""
import json
from pathlib import Path

TF = [
    {"id": "true", "text": "Verdadeiro"},
    {"id": "false", "text": "Falso"},
]


def qtext(s):
    return {"question": s, "prompt": s, "cue": s}


def item(base, **kw):
    d = dict(base)
    d.update(kw)
    return d


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
TRAIL = "timoteo"

# ---------------------------------------------------------------------------
# M1
# ---------------------------------------------------------------------------
P1 = "Vela sobre ti e sobre o teu ensino; persevera nessas coisas, porque, fazendo isso, te salvarás tanto a ti mesmo como aos que te ouvem."
R1 = "1 Timóteo 4:16"
S1 = "tm-01-sadia-doutrina"
LO1 = "Reconhecer que vigiar a si e o ensino, com perseverança, alcança tanto o ministro quanto os que o ouvem."
E1 = ["1 Timóteo 4:16"]
B1 = dict(trail=TRAIL, section=S1, verse_ref=R1, lo=LO1, evidence=E1, passage=P1)

# semente
OUT.append(pack(**B1, short="sem", nn="01", difficulty="semente", skill="observe", type="true_false",
    **qtext("Paulo manda velar sobre si e sobre o ensino e perseverar nessas coisas."),
    feedbackCorrect="Certo: 1 Tm 4:16 une vigília, ensino e perseverança.",
    feedbackWrong={"false": "Releia: vela sobre ti e sobre o teu ensino; persevera."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B1, short="sem", nn="02", difficulty="semente", skill="observe", type="tap",
    **qtext('Em 1 Timóteo 4:16, toque a palavra que falta em "___ sobre ti e sobre o teu ensino; persevera nessas coisas"?'),
    template="___ sobre ti e sobre o teu ensino; persevera nessas coisas",
    feedbackCorrect="Exato: o verbo inicial é Vela.",
    feedbackWrong={"b": "Ensino é o objeto da vigília, não o verbo.", "c": "Persevera vem depois do ponto e vírgula."},
    options=[{"id": "a", "text": "Vela"}, {"id": "b", "text": "ensino"}, {"id": "c", "text": "persevera"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B1, short="sem", nn="03", difficulty="semente", skill="observe", type="choice",
    **qtext("O que 1 Timóteo 4:16 afirma que acontece a quem vela e persevera?"),
    feedbackCorrect="Certo: salva a si mesmo e aos que o ouvem.",
    feedbackWrong={
        "a": "O texto não restringe o fruto só ao ministro.",
        "c": "Não há menção de abandono do ensino.",
        "d": "O texto fala de ouvir, não de silêncio dos ouvintes.",
    },
    options=[
        {"id": "a", "text": "Salva somente a si, sem efeito sobre os ouvintes"},
        {"id": "b", "text": "Salva a si mesmo e aos que o ouvem"},
        {"id": "c", "text": "Pode deixar o ensino, se velar só sobre si"},
        {"id": "d", "text": "Os ouvintes ficam isentos de qualquer fruto"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="sem", nn="04", difficulty="semente", skill="observe", type="order",
    **qtext("Qual sequência mostra a ordem dos fatos em 1 Timóteo 4:16?"),
    feedbackCorrect="Certo: vigiar, perseverar, então o fruto da salvação.",
    feedbackWrong={"b": "A salvação dos ouvintes não abre o versículo.", "c": "Perseverar vem depois de velar, não antes."},
    options=[
        {"id": "a", "text": "Vela sobre ti e sobre o teu ensino"},
        {"id": "b", "text": "persevera nessas coisas"},
        {"id": "c", "text": "te salvarás tanto a ti mesmo como aos que te ouvem"},
    ],
    correctOrder=["a", "b", "c"], correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B1, short="sem", nn="05", difficulty="semente", skill="observe", type="complete",
    **qtext("Complete a frase: \"Vela sobre ti e sobre o teu ___; persevera nessas coisas\""),
    template="Vela sobre ti e sobre o teu ___; persevera nessas coisas",
    feedbackCorrect="Certo: a vigília recai também sobre o ensino.",
    feedbackWrong={"a": "Ouvem fecha o versículo, não esta lacuna.", "c": "Coisas vem depois, no perseverar."},
    options=[{"id": "a", "text": "ouvem"}, {"id": "b", "text": "ensino"}, {"id": "c", "text": "coisas"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="sem", nn="06", difficulty="semente", skill="observe", type="connect",
    **qtext("O que 1 Timóteo 4:16 comunica que se liga a este contexto?"),
    passageA={"ref": R1, "text": P1},
    passageB={"ref": "Contexto", "text": "Sadia doutrina e oração passam por vigiar a si e o ensino — perseverança que alcança quem ouve."},
    feedbackCorrect="Certo: vigiar a si e o ensino alcança quem ouve.",
    feedbackWrong={"b": "O texto não separa vida e ensino.", "c": "Há fruto nos ouvintes, não só no pregador."},
    options=[
        {"id": "a", "text": "Vigiar si e ensino"},
        {"id": "b", "text": "Só vida, sem doutrina"},
        {"id": "c", "text": "Fruto só no pregador"},
    ],
    correctOptionId="a", correctAnswer="a"))

# caminhada
OUT.append(pack(**B1, short="cam", nn="01", difficulty="caminhada", skill="understand", type="true_false",
    **qtext("Velar só sobre o ensino, sem vigiar a si, basta para o fruto de 1 Timóteo 4:16."),
    feedbackCorrect="Certo: o texto une vigília sobre si e sobre o ensino.",
    feedbackWrong={"true": "Paulo manda velar sobre ti e sobre o ensino."},
    options=TF, correctOptionId="false", correctAnswer="false"))
OUT.append(pack(**B1, short="cam", nn="02", difficulty="caminhada", skill="understand", type="tap",
    **qtext('Em 1 Timóteo 4:16, toque a palavra que falta em "Vela sobre ti e sobre o teu ensino; ___ nessas coisas"?'),
    template="Vela sobre ti e sobre o teu ensino; ___ nessas coisas",
    feedbackCorrect="Exato: a vigília pede perseverança.",
    feedbackWrong={"a": "Vela já abriu o versículo.", "c": "Fazendo introduz o resultado, não esta lacuna."},
    options=[{"id": "a", "text": "Vela"}, {"id": "b", "text": "persevera"}, {"id": "c", "text": "fazendo"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="cam", nn="03", difficulty="caminhada", skill="understand", type="choice",
    **qtext("Como se relacionam vigília, perseverança e fruto em 1 Timóteo 4:16?"),
    feedbackCorrect="Certo: persistir na vigília liga o ministro aos ouvintes.",
    feedbackWrong={
        "a": "O fruto não é automático sem perseverar.",
        "c": "O texto não autoriza ensinar sem velar sobre si.",
        "d": "Os ouvintes não ficam de fora do alcance da perseverança.",
    },
    options=[
        {"id": "a", "text": "O fruto vem mesmo sem perseverar, se houver talento"},
        {"id": "b", "text": "Perseverar na vigília une a salvação de si à dos ouvintes"},
        {"id": "c", "text": "Pode-se ensinar bem sem nenhuma vigília sobre a vida"},
        {"id": "d", "text": "A perseverança do ministro não alcança quem o ouve"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="cam", nn="04", difficulty="caminhada", skill="understand", type="order",
    **qtext("Como se encadeiam os eventos de 1 Timóteo 4:16?"),
    feedbackCorrect="Certo: vigília e ensino, perseverança, então o fruto.",
    feedbackWrong={"a": "O fruto não precede a vigília.", "c": "Perseverar não é o último elo."},
    options=[
        {"id": "a", "text": "te salvarás tanto a ti mesmo como aos que te ouvem"},
        {"id": "b", "text": "Vela sobre ti e sobre o teu ensino"},
        {"id": "c", "text": "persevera nessas coisas, porque, fazendo isso"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="cam", nn="05", difficulty="caminhada", skill="understand", type="complete",
    **qtext("Complete a frase: \"fazendo isso, te ___ tanto a ti mesmo como aos que te ouvem\""),
    template="fazendo isso, te ___ tanto a ti mesmo como aos que te ouvem",
    feedbackCorrect="Certo: o fruto é te salvarás — a si e aos ouvintes.",
    feedbackWrong={"a": "Persevera já foi ordenado antes.", "b": "Vela abre o versículo, não esta lacuna."},
    options=[{"id": "a", "text": "persevera"}, {"id": "b", "text": "Vela"}, {"id": "c", "text": "salvarás"}],
    correctOptionId="c", correctAnswer="c"))
OUT.append(pack(**B1, short="cam", nn="06", difficulty="caminhada", skill="understand", type="connect",
    **qtext("O que 1 Timóteo 4:16 comunica que se liga a este contexto?"),
    passageA={"ref": R1, "text": P1},
    passageB={"ref": "Contexto", "text": "Sadia doutrina e oração passam por vigiar a si e o ensino — perseverança que alcança quem ouve."},
    feedbackCorrect="Certo: a perseverança liga o ensino a quem ouve.",
    feedbackWrong={"a": "Não há vigília sem ensino no texto.", "c": "O alcance inclui os ouvintes."},
    options=[
        {"id": "a", "text": "Vigília sem nenhum ensino"},
        {"id": "b", "text": "Perseverança que alcança ouvintes"},
        {"id": "c", "text": "Fruto restrito ao ministro"},
    ],
    correctOptionId="b", correctAnswer="b"))

# profundezas
OUT.append(pack(**B1, short="pro", nn="01", difficulty="profundezas", skill="interpret", type="true_false",
    **qtext("A sadia doutrina no ministro não se separa da vigília sobre a própria vida: o fruto alcança quem ouve."),
    feedbackCorrect="Certo: vida, ensino e ouvintes ficam atados no versículo.",
    feedbackWrong={"false": "4:16 une vigiar a si, o ensino e os ouvintes."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B1, short="pro", nn="02", difficulty="profundezas", skill="interpret", type="tap",
    **qtext('Em 1 Timóteo 4:16, toque a palavra que falta em "te salvarás tanto a ti mesmo como aos que te ___"?'),
    template="te salvarás tanto a ti mesmo como aos que te ___",
    feedbackCorrect="Exato: o alcance chega aos que te ouvem.",
    feedbackWrong={"a": "Ensino é o objeto da vigília, não esta lacuna.", "b": "Coisas refere-se ao que se persevera."},
    options=[{"id": "a", "text": "ensino"}, {"id": "b", "text": "coisas"}, {"id": "c", "text": "ouvem"}],
    correctOptionId="c", correctAnswer="c"))
OUT.append(pack(**B1, short="pro", nn="03", difficulty="profundezas", skill="interpret", type="choice",
    **qtext("Qual leitura teológica 1 Timóteo 4:16 sustenta?"),
    feedbackCorrect="Certo: doutrina sadia passa por vigiar a si e persistir.",
    feedbackWrong={
        "a": "O texto não autoriza doutrina sem vida vigiada.",
        "c": "O fruto não é só reputação do ministro.",
        "d": "Perseverar não é opcional no encadeamento.",
    },
    options=[
        {"id": "a", "text": "Basta ensinar certo; a vida do ministro é irrelevante"},
        {"id": "b", "text": "Doutrina sadia exige vigiar a si e perseverar, em bem de quem ouve"},
        {"id": "c", "text": "O alvo é só a fama do pregador, não os ouvintes"},
        {"id": "d", "text": "Velar uma vez dispensa perseverar nessas coisas"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="pro", nn="04", difficulty="profundezas", skill="interpret", type="order",
    **qtext("Qual sequência revela o sentido de 1 Timóteo 4:16?"),
    feedbackCorrect="Certo: o sentido vai da vigília ao fruto nos ouvintes.",
    feedbackWrong={"a": "O fruto não revela o sentido se vier primeiro.", "c": "O ensino vigiado não é o último passo."},
    options=[
        {"id": "a", "text": "te salvarás tanto a ti mesmo como aos que te ouvem"},
        {"id": "b", "text": "Vela sobre ti e sobre o teu ensino; persevera nessas coisas"},
        {"id": "c", "text": "porque, fazendo isso"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B1, short="pro", nn="05", difficulty="profundezas", skill="interpret", type="complete",
    **qtext("Complete a frase: \"persevera nessas coisas, porque, ___ isso, te salvarás\""),
    template="persevera nessas coisas, porque, ___ isso, te salvarás",
    feedbackCorrect="Certo: o fruto segue de fazendo isso — a prática persistente.",
    feedbackWrong={"b": "Ouvem fecha o versículo.", "c": "Vela já foi o primeiro mandato."},
    options=[{"id": "a", "text": "fazendo"}, {"id": "b", "text": "ouvem"}, {"id": "c", "text": "Vela"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B1, short="pro", nn="06", difficulty="profundezas", skill="interpret", type="connect",
    **qtext("O que 1 Timóteo 4:16 comunica que se liga a este contexto?"),
    passageA={"ref": R1, "text": P1},
    passageB={"ref": "Contexto", "text": "Sadia doutrina e oração passam por vigiar a si e o ensino — perseverança que alcança quem ouve."},
    feedbackCorrect="Certo: a doutrina sadia não se desliga da vida vigiada.",
    feedbackWrong={"a": "O texto une vida e ensino.", "b": "Há alcance nos ouvintes."},
    options=[
        {"id": "a", "text": "Doutrina sem vigiar a si"},
        {"id": "b", "text": "Ensino que ignora ouvintes"},
        {"id": "c", "text": "Vida e ensino que alcançam"},
    ],
    correctOptionId="c", correctAnswer="c"))

# ---------------------------------------------------------------------------
# M2
# ---------------------------------------------------------------------------
P2 = "Fiel é esta palavra: se alguém aspira ao episcopado, deseja uma obra boa. É necessário, pois, que o bispo seja irrepreensível, esposo de uma só mulher, discreto, sóbrio, circunspecto, hospitaleiro, capaz de ensinar,"
R2 = "1 Timóteo 3:1–2"
S2 = "tm-02-lideranca"
LO2 = "Reconhecer que o episcopado é obra boa e exige caráter irrepreensível, inclusive capacidade de ensinar."
E2 = ["1 Timóteo 3:1", "1 Timóteo 3:2"]
B2 = dict(trail=TRAIL, section=S2, verse_ref=R2, lo=LO2, evidence=E2, passage=P2)

OUT.append(pack(**B2, short="sem", nn="01", difficulty="semente", skill="observe", type="true_false",
    **qtext("Aspirar ao episcopado é desejar uma obra boa, e o bispo deve ser irrepreensível e capaz de ensinar."),
    feedbackCorrect="Certo: 1 Tm 3:1–2 une obra boa e caráter.",
    feedbackWrong={"false": "O texto chama o episcopado de obra boa e pede irrepreensível."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B2, short="sem", nn="02", difficulty="semente", skill="observe", type="tap",
    **qtext('Em 1 Timóteo 3:1–2, toque a palavra que falta em "se alguém aspira ao ___, deseja uma obra boa"?'),
    template="se alguém aspira ao ___, deseja uma obra boa",
    feedbackCorrect="Exato: o ofício nomeado é o episcopado.",
    feedbackWrong={"b": "Bispo aparece depois, no critério.", "c": "Obra é o que se deseja, não o cargo."},
    options=[{"id": "a", "text": "episcopado"}, {"id": "b", "text": "bispo"}, {"id": "c", "text": "obra"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B2, short="sem", nn="03", difficulty="semente", skill="observe", type="choice",
    **qtext("O que 1 Timóteo 3:1–2 afirma ser necessário que o bispo seja?"),
    feedbackCorrect="Certo: irrepreensível e capaz de ensinar, entre outros traços.",
    feedbackWrong={
        "a": "O texto exige caráter, não só o cargo.",
        "c": "Não há dispensa da capacidade de ensinar.",
        "d": "Hospitaleiro está na lista, não o contrário.",
    },
    options=[
        {"id": "a", "text": "Apenas titular do cargo, sem traço de caráter"},
        {"id": "b", "text": "Irrepreensível, hospitaleiro e capaz de ensinar"},
        {"id": "c", "text": "Irrepreensível, mas sem necessidade de ensinar"},
        {"id": "d", "text": "Incapaz de acolher, desde que aspire ao cargo"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="sem", nn="04", difficulty="semente", skill="observe", type="order",
    **qtext("Qual sequência mostra a ordem dos fatos em 1 Timóteo 3:1–2?"),
    feedbackCorrect="Certo: palavra fiel, aspiração, depois o caráter do bispo.",
    feedbackWrong={"a": "O caráter do bispo não abre o trecho.", "c": "Aspirar vem depois da palavra fiel."},
    options=[
        {"id": "a", "text": "É necessário, pois, que o bispo seja irrepreensível"},
        {"id": "b", "text": "Fiel é esta palavra"},
        {"id": "c", "text": "se alguém aspira ao episcopado, deseja uma obra boa"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="sem", nn="05", difficulty="semente", skill="observe", type="complete",
    **qtext("Complete a frase: \"É necessário, pois, que o bispo seja ___, esposo de uma só mulher\""),
    template="É necessário, pois, que o bispo seja ___, esposo de uma só mulher",
    feedbackCorrect="Certo: o primeiro traço listado é irrepreensível.",
    feedbackWrong={"a": "Hospitaleiro vem mais adiante na lista.", "b": "Ensinar fecha o versículo 2."},
    options=[{"id": "a", "text": "hospitaleiro"}, {"id": "b", "text": "ensinar"}, {"id": "c", "text": "irrepreensível"}],
    correctOptionId="c", correctAnswer="c"))
OUT.append(pack(**B2, short="sem", nn="06", difficulty="semente", skill="observe", type="connect",
    **qtext("O que 1 Timóteo 3:1–2 comunica que se liga a este contexto?"),
    passageA={"ref": R2, "text": P2},
    passageB={"ref": "Contexto", "text": "Liderança é obra boa e caráter: irrepreensível, capaz de ensinar — não só cargo."},
    feedbackCorrect="Certo: liderança é obra boa atada ao caráter.",
    feedbackWrong={"a": "O texto não reduz o ofício a título.", "c": "Ensinar entra na lista, não fica de fora."},
    options=[
        {"id": "a", "text": "Cargo sem caráter"},
        {"id": "b", "text": "Obra boa e caráter"},
        {"id": "c", "text": "Ofício sem ensinar"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B2, short="cam", nn="01", difficulty="caminhada", skill="understand", type="true_false",
    **qtext("Aspirar ao episcopado, por si só, dispensa o bispo de ser irrepreensível e capaz de ensinar."),
    feedbackCorrect="Certo: a obra boa exige o caráter listado.",
    feedbackWrong={"true": "3:2 diz: é necessário que o bispo seja irrepreensível."},
    options=TF, correctOptionId="false", correctAnswer="false"))
OUT.append(pack(**B2, short="cam", nn="02", difficulty="caminhada", skill="understand", type="tap",
    **qtext('Em 1 Timóteo 3:1–2, toque a palavra que falta em "hospitaleiro, capaz de ___"?'),
    template="hospitaleiro, capaz de ___",
    feedbackCorrect="Exato: o bispo deve ser capaz de ensinar.",
    feedbackWrong={"a": "Discreto está no meio da lista.", "c": "Sóbrio não fecha o versículo 2."},
    options=[{"id": "a", "text": "discreto"}, {"id": "b", "text": "ensinar"}, {"id": "c", "text": "sóbrio"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="cam", nn="03", difficulty="caminhada", skill="understand", type="choice",
    **qtext("Como 1 Timóteo 3:1–2 relaciona desejo do ofício e perfil do bispo?"),
    feedbackCorrect="Certo: o desejo é de uma obra boa que exige caráter.",
    feedbackWrong={
        "a": "Aspirar não substitui irrepreensível.",
        "c": "Ensinar não é detalhe opcional.",
        "d": "O texto chama de obra boa, não de honraria vazia.",
    },
    options=[
        {"id": "a", "text": "O desejo do cargo já prova o caráter"},
        {"id": "b", "text": "Aspirar a uma obra boa exige ser irrepreensível e ensinar"},
        {"id": "c", "text": "O ofício pode prescindir da capacidade de ensinar"},
        {"id": "d", "text": "Episcopado é só honra, sem obra a realizar"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="cam", nn="04", difficulty="caminhada", skill="understand", type="order",
    **qtext("Como se encadeiam os eventos de 1 Timóteo 3:1–2?"),
    feedbackCorrect="Certo: do desejo da obra boa à necessidade do caráter.",
    feedbackWrong={"b": "O caráter não antecede a palavra fiel.", "c": "A obra boa vem antes da lista do bispo."},
    options=[
        {"id": "a", "text": "se alguém aspira ao episcopado, deseja uma obra boa"},
        {"id": "b", "text": "que o bispo seja irrepreensível"},
        {"id": "c", "text": "capaz de ensinar"},
    ],
    correctOrder=["a", "b", "c"], correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B2, short="cam", nn="05", difficulty="caminhada", skill="understand", type="complete",
    **qtext("Complete a frase: \"se alguém ___ ao episcopado, deseja uma obra boa\""),
    template="se alguém ___ ao episcopado, deseja uma obra boa",
    feedbackCorrect="Certo: o verbo é aspira — desejo de uma obra, não de status.",
    feedbackWrong={"b": "Deseja já está na segunda cláusula.", "c": "Fiel abre o dito, não esta lacuna."},
    options=[{"id": "a", "text": "aspira"}, {"id": "b", "text": "deseja"}, {"id": "c", "text": "Fiel"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B2, short="cam", nn="06", difficulty="caminhada", skill="understand", type="connect",
    **qtext("O que 1 Timóteo 3:1–2 comunica que se liga a este contexto?"),
    passageA={"ref": R2, "text": P2},
    passageB={"ref": "Contexto", "text": "Liderança é obra boa e caráter: irrepreensível, capaz de ensinar — não só cargo."},
    feedbackCorrect="Certo: o cargo não substitui ensinar e ser irrepreensível.",
    feedbackWrong={"a": "Obra boa não é só título.", "c": "Caráter não é opcional."},
    options=[
        {"id": "a", "text": "Título sem obra"},
        {"id": "b", "text": "Cargo não basta sem caráter"},
        {"id": "c", "text": "Ensinar como adorno opcional"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B2, short="pro", nn="01", difficulty="profundezas", skill="interpret", type="true_false",
    **qtext("No texto, liderança cristã é obra boa medida por caráter irrepreensível e capacidade de ensinar, não só pelo cargo."),
    feedbackCorrect="Certo: 3:1–2 recusa reduzir o ofício a título.",
    feedbackWrong={"false": "A lista do bispo define a obra, não o cargo isolado."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B2, short="pro", nn="02", difficulty="profundezas", skill="interpret", type="tap",
    **qtext('Em 1 Timóteo 3:1–2, toque a palavra que falta em "deseja uma ___ boa"?'),
    template="deseja uma ___ boa",
    feedbackCorrect="Exato: o episcopado é obra, não mero status.",
    feedbackWrong={"a": "Palavra abre o dito fiel.", "c": "Mulher está no critério conjugal."},
    options=[{"id": "a", "text": "palavra"}, {"id": "b", "text": "obra"}, {"id": "c", "text": "mulher"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="pro", nn="03", difficulty="profundezas", skill="interpret", type="choice",
    **qtext("Qual leitura teológica 1 Timóteo 3:1–2 sustenta?"),
    feedbackCorrect="Certo: o ofício é serviço de caráter e ensino.",
    feedbackWrong={
        "a": "Aspirar não canoniza qualquer candidato.",
        "c": "Hospitalidade e ensino estão na lista.",
        "d": "Irrepreensível não é só imagem pública vazia.",
    },
    options=[
        {"id": "a", "text": "Quem deseja o cargo já está aprovado, sem exame de vida"},
        {"id": "b", "text": "O episcopado é obra boa cujo critério é caráter e ensino"},
        {"id": "c", "text": "O bispo pode ser inóspito, desde que tenha título"},
        {"id": "d", "text": "Irrepreensível vale só como reputação, sem vida examinável"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="pro", nn="04", difficulty="profundezas", skill="interpret", type="order",
    **qtext("Qual sequência revela o sentido de 1 Timóteo 3:1–2?"),
    feedbackCorrect="Certo: obra boa, necessidade, então o perfil que ensina.",
    feedbackWrong={"a": "Ensinar não abre o sentido do trecho.", "c": "A necessidade vem após chamar de obra boa."},
    options=[
        {"id": "a", "text": "capaz de ensinar"},
        {"id": "b", "text": "deseja uma obra boa"},
        {"id": "c", "text": "É necessário, pois, que o bispo seja irrepreensível"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="pro", nn="05", difficulty="profundezas", skill="interpret", type="complete",
    **qtext("Complete a frase: \"É necessário, pois, que o ___ seja irrepreensível\""),
    template="É necessário, pois, que o ___ seja irrepreensível",
    feedbackCorrect="Certo: o sujeito da exigência é o bispo.",
    feedbackWrong={"a": "Episcopado nomeia o ofício no v. 1.", "c": "Obra descreve o desejo, não esta lacuna."},
    options=[{"id": "a", "text": "episcopado"}, {"id": "b", "text": "bispo"}, {"id": "c", "text": "obra"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B2, short="pro", nn="06", difficulty="profundezas", skill="interpret", type="connect",
    **qtext("O que 1 Timóteo 3:1–2 comunica que se liga a este contexto?"),
    passageA={"ref": R2, "text": P2},
    passageB={"ref": "Contexto", "text": "Liderança é obra boa e caráter: irrepreensível, capaz de ensinar — não só cargo."},
    feedbackCorrect="Certo: liderar é servir com caráter que ensina.",
    feedbackWrong={"b": "O texto não separa cargo e vida.", "c": "Ensinar não é extra."},
    options=[
        {"id": "a", "text": "Caráter que ensina"},
        {"id": "b", "text": "Honra sem exame de vida"},
        {"id": "c", "text": "Ofício sem capacidade de ensinar"},
    ],
    correctOptionId="a", correctAnswer="a"))

# ---------------------------------------------------------------------------
# M3
# ---------------------------------------------------------------------------
P3 = "Conserva o modelo de sãs palavras que de mim ouviste na fé e no amor que há em Cristo Jesus. Guarda o bom depósito com o auxílio do Espírito Santo, que habita em nós."
R3 = "2 Timóteo 1:13–14"
S3 = "tm-03-perseveranca"
LO3 = "Reconhecer que guardar o bom depósito é conservar sãs palavras na fé e no amor, com o Espírito que habita."
E3 = ["2 Timóteo 1:13", "2 Timóteo 1:14"]
B3 = dict(trail=TRAIL, section=S3, verse_ref=R3, lo=LO3, evidence=E3, passage=P3)

OUT.append(pack(**B3, short="sem", nn="01", difficulty="semente", skill="observe", type="true_false",
    **qtext("Timóteo deve conservar o modelo de sãs palavras na fé e no amor, e guardar o bom depósito com o Espírito Santo."),
    feedbackCorrect="Certo: 2 Tm 1:13–14 une modelo, depósito e Espírito.",
    feedbackWrong={"false": "O texto manda conservar e guardar com o Espírito."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B3, short="sem", nn="02", difficulty="semente", skill="observe", type="tap",
    **qtext('Em 2 Timóteo 1:13–14, toque a palavra que falta em "___ o modelo de sãs palavras que de mim ouviste"?'),
    template="___ o modelo de sãs palavras que de mim ouviste",
    feedbackCorrect="Exato: o mandato inicial é Conserva.",
    feedbackWrong={"b": "Guarda abre o v. 14, não esta lacuna.", "c": "Ouviste descreve a origem, não o verbo."},
    options=[{"id": "a", "text": "Conserva"}, {"id": "b", "text": "Guarda"}, {"id": "c", "text": "ouviste"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B3, short="sem", nn="03", difficulty="semente", skill="observe", type="choice",
    **qtext("O que 2 Timóteo 1:13–14 afirma sobre o bom depósito?"),
    feedbackCorrect="Certo: guarda-se com o auxílio do Espírito que habita.",
    feedbackWrong={
        "a": "Não é para abandonar o modelo ouvido.",
        "c": "O auxílio nomeado é o Espírito Santo.",
        "d": "O Espírito habita em nós, não está ausente.",
    },
    options=[
        {"id": "a", "text": "Deve-se descartar o modelo ouvido de Paulo"},
        {"id": "b", "text": "Guarda-se com o auxílio do Espírito Santo, que habita em nós"},
        {"id": "c", "text": "Guarda-se só com talento humano, sem o Espírito"},
        {"id": "d", "text": "O Espírito Santo não habita em nós neste texto"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="sem", nn="04", difficulty="semente", skill="observe", type="order",
    **qtext("Qual sequência mostra a ordem dos fatos em 2 Timóteo 1:13–14?"),
    feedbackCorrect="Certo: conservar o modelo, depois guardar o depósito.",
    feedbackWrong={"a": "O Espírito fecha o trecho, não o abre.", "c": "Conservar vem antes de guardar."},
    options=[
        {"id": "a", "text": "com o auxílio do Espírito Santo, que habita em nós"},
        {"id": "b", "text": "Conserva o modelo de sãs palavras que de mim ouviste"},
        {"id": "c", "text": "Guarda o bom depósito"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="sem", nn="05", difficulty="semente", skill="observe", type="complete",
    **qtext("Complete a frase: \"Guarda o bom ___ com o auxílio do Espírito Santo\""),
    template="Guarda o bom ___ com o auxílio do Espírito Santo",
    feedbackCorrect="Certo: o objeto a guardar é o depósito.",
    feedbackWrong={"a": "Modelo está no v. 13.", "c": "Amor descreve o modo, não esta lacuna."},
    options=[{"id": "a", "text": "modelo"}, {"id": "b", "text": "depósito"}, {"id": "c", "text": "amor"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="sem", nn="06", difficulty="semente", skill="observe", type="connect",
    **qtext("O que 2 Timóteo 1:13–14 comunica que se liga a este contexto?"),
    passageA={"ref": R3, "text": P3},
    passageB={"ref": "Contexto", "text": "Guardar o bom depósito: sãs palavras na fé e no amor, com o Espírito que habita."},
    feedbackCorrect="Certo: sãs palavras se guardam na fé e no amor.",
    feedbackWrong={"b": "Não é depósito sem palavras sãs.", "c": "O Espírito não fica de fora."},
    options=[
        {"id": "a", "text": "Sãs palavras na fé e amor"},
        {"id": "b", "text": "Depósito sem palavras sãs"},
        {"id": "c", "text": "Guarda só por força própria"},
    ],
    correctOptionId="a", correctAnswer="a"))

OUT.append(pack(**B3, short="cam", nn="01", difficulty="caminhada", skill="understand", type="true_false",
    **qtext("Conservar sãs palavras, no texto, se dá fora da fé e do amor que há em Cristo Jesus."),
    feedbackCorrect="Certo: o modelo se conserva na fé e no amor.",
    feedbackWrong={"true": "1:13 situa as sãs palavras na fé e no amor."},
    options=TF, correctOptionId="false", correctAnswer="false"))
OUT.append(pack(**B3, short="cam", nn="02", difficulty="caminhada", skill="understand", type="tap",
    **qtext('Em 2 Timóteo 1:13–14, toque a palavra que falta em "na fé e no ___ que há em Cristo Jesus"?'),
    template="na fé e no ___ que há em Cristo Jesus",
    feedbackCorrect="Exato: fé e amor em Cristo sustentam o modelo.",
    feedbackWrong={"a": "Fé já está na primeira metade.", "c": "Auxílio pertence ao v. 14."},
    options=[{"id": "a", "text": "fé"}, {"id": "b", "text": "amor"}, {"id": "c", "text": "auxílio"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="cam", nn="03", difficulty="caminhada", skill="understand", type="choice",
    **qtext("Como 2 Timóteo 1:13–14 relaciona o modelo ouvido e o depósito a guardar?"),
    feedbackCorrect="Certo: o mesmo tesouro se conserva e se guarda no Espírito.",
    feedbackWrong={
        "a": "Não há substituição de um modelo por outro.",
        "c": "Fé e amor não são adornos descartáveis.",
        "d": "O Espírito habita; não é força solitária.",
    },
    options=[
        {"id": "a", "text": "O depósito substitui as palavras ouvidas de Paulo"},
        {"id": "b", "text": "O modelo de sãs palavras é o depósito a guardar no Espírito"},
        {"id": "c", "text": "Fé e amor são opcionais na conservação do modelo"},
        {"id": "d", "text": "Guarda-se o depósito sem qualquer auxílio do Espírito"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="cam", nn="04", difficulty="caminhada", skill="understand", type="order",
    **qtext("Como se encadeiam os eventos de 2 Timóteo 1:13–14?"),
    feedbackCorrect="Certo: ouvir o modelo, conservá-lo na fé e no amor, guardá-lo.",
    feedbackWrong={"b": "Guardar não precede conservar o modelo.", "c": "O ouvir fundamenta o que se conserva."},
    options=[
        {"id": "a", "text": "sãs palavras que de mim ouviste na fé e no amor"},
        {"id": "b", "text": "Guarda o bom depósito com o auxílio do Espírito Santo"},
        {"id": "c", "text": "Conserva o modelo"},
    ],
    correctOrder=["c", "a", "b"], correctOptionId="c", correctAnswer="c"))
OUT.append(pack(**B3, short="cam", nn="05", difficulty="caminhada", skill="understand", type="complete",
    **qtext("Complete a frase: \"com o auxílio do Espírito Santo, que ___ em nós\""),
    template="com o auxílio do Espírito Santo, que ___ em nós",
    feedbackCorrect="Certo: o Espírito habita em nós — auxílio interior.",
    feedbackWrong={"a": "Ouviste está no v. 13.", "c": "Conserva é o primeiro mandato."},
    options=[{"id": "a", "text": "ouviste"}, {"id": "b", "text": "habita"}, {"id": "c", "text": "Conserva"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="cam", nn="06", difficulty="caminhada", skill="understand", type="connect",
    **qtext("O que 2 Timóteo 1:13–14 comunica que se liga a este contexto?"),
    passageA={"ref": R3, "text": P3},
    passageB={"ref": "Contexto", "text": "Guardar o bom depósito: sãs palavras na fé e no amor, com o Espírito que habita."},
    feedbackCorrect="Certo: o depósito se guarda com o Espírito que habita.",
    feedbackWrong={"a": "Não é memória fria sem fé e amor.", "c": "O Espírito não está ausente."},
    options=[
        {"id": "a", "text": "Palavras sem fé nem amor"},
        {"id": "b", "text": "Depósito com o Espírito que habita"},
        {"id": "c", "text": "Guarda sem auxílio algum"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B3, short="pro", nn="01", difficulty="profundezas", skill="interpret", type="true_false",
    **qtext("Guardar o bom depósito não é inovação autônoma: é conservar sãs palavras na fé e no amor, com o Espírito que habita."),
    feedbackCorrect="Certo: o tesouro é recebido e habitado, não inventado.",
    feedbackWrong={"false": "1:13–14 une modelo recebido e Espírito habitante."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B3, short="pro", nn="02", difficulty="profundezas", skill="interpret", type="tap",
    **qtext('Em 2 Timóteo 1:13–14, toque a palavra que falta em "com o auxílio do ___ Santo, que habita em nós"?'),
    template="com o auxílio do ___ Santo, que habita em nós",
    feedbackCorrect="Exato: o auxílio é o Espírito Santo.",
    feedbackWrong={"a": "Cristo Jesus fecha o v. 13.", "c": "Depósito é o que se guarda."},
    options=[{"id": "a", "text": "Cristo"}, {"id": "b", "text": "Espírito"}, {"id": "c", "text": "depósito"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="pro", nn="03", difficulty="profundezas", skill="interpret", type="choice",
    **qtext("Qual leitura teológica 2 Timóteo 1:13–14 sustenta?"),
    feedbackCorrect="Certo: o depósito é graça habitada, não invenção solitária.",
    feedbackWrong={
        "a": "O modelo vem do que se ouviu, não de criação livre.",
        "c": "Fé e amor em Cristo não são descartáveis.",
        "d": "O Espírito habita; não é só memória humana.",
    },
    options=[
        {"id": "a", "text": "Cada geração deve inventar outro evangelho"},
        {"id": "b", "text": "O tesouro ouvido se guarda na fé e no amor, pelo Espírito"},
        {"id": "c", "text": "Sãs palavras bastam sem fé e sem amor em Cristo"},
        {"id": "d", "text": "O Espírito não participa da guarda do depósito"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="pro", nn="04", difficulty="profundezas", skill="interpret", type="order",
    **qtext("Qual sequência revela o sentido de 2 Timóteo 1:13–14?"),
    feedbackCorrect="Certo: modelo na fé e no amor, depois guarda no Espírito.",
    feedbackWrong={"a": "O Espírito não inicia o sentido isolado.", "c": "O modelo ouvido vem antes de guardar."},
    options=[
        {"id": "a", "text": "que habita em nós"},
        {"id": "b", "text": "Conserva o modelo de sãs palavras na fé e no amor"},
        {"id": "c", "text": "Guarda o bom depósito com o auxílio do Espírito Santo"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B3, short="pro", nn="05", difficulty="profundezas", skill="interpret", type="complete",
    **qtext("Complete a frase: \"Conserva o ___ de sãs palavras que de mim ouviste\""),
    template="Conserva o ___ de sãs palavras que de mim ouviste",
    feedbackCorrect="Certo: há um modelo a conservar, não um recorte livre.",
    feedbackWrong={"b": "Depósito está no v. 14.", "c": "Auxílio descreve o Espírito."},
    options=[{"id": "a", "text": "modelo"}, {"id": "b", "text": "depósito"}, {"id": "c", "text": "auxílio"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B3, short="pro", nn="06", difficulty="profundezas", skill="interpret", type="connect",
    **qtext("O que 2 Timóteo 1:13–14 comunica que se liga a este contexto?"),
    passageA={"ref": R3, "text": P3},
    passageB={"ref": "Contexto", "text": "Guardar o bom depósito: sãs palavras na fé e no amor, com o Espírito que habita."},
    feedbackCorrect="Certo: guardar é fidelidade habitada, não invenção.",
    feedbackWrong={"a": "O texto recusa um evangelho novo.", "b": "Fé e amor não são cortados."},
    options=[
        {"id": "a", "text": "Invenção de outro evangelho"},
        {"id": "b", "text": "Palavras sãs sem fé nem amor"},
        {"id": "c", "text": "Fidelidade com o Espírito habitante"},
    ],
    correctOptionId="c", correctAnswer="c"))

# ---------------------------------------------------------------------------
# M4
# ---------------------------------------------------------------------------
P4 = "prega a palavra, insta a tempo e fora de tempo, convence, repreende, exorta com toda a paciência e ensino."
R4 = "2 Timóteo 4:2"
S4 = "tm-04-desafio"
LO4 = "Reconhecer que o ministro prega a palavra a tempo e fora de tempo, com paciência e ensino, sem silêncio conveniente."
E4 = ["2 Timóteo 4:2"]
B4 = dict(trail=TRAIL, section=S4, verse_ref=R4, lo=LO4, evidence=E4, passage=P4)

OUT.append(pack(**B4, short="sem", nn="01", difficulty="semente", skill="observe", type="true_false",
    **qtext("Paulo manda pregar a palavra, instar a tempo e fora de tempo, convencer, repreender e exortar com paciência e ensino."),
    feedbackCorrect="Certo: 2 Tm 4:2 lista pregação e os verbos pastorais.",
    feedbackWrong={"false": "O versículo começa com prega a palavra e segue a lista."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B4, short="sem", nn="02", difficulty="semente", skill="observe", type="tap",
    **qtext('Em 2 Timóteo 4:2, toque a palavra que falta em "___ a palavra, insta a tempo e fora de tempo"?'),
    template="___ a palavra, insta a tempo e fora de tempo",
    feedbackCorrect="Exato: o primeiro mandato é prega.",
    feedbackWrong={"b": "Insta vem depois de pregar a palavra.", "c": "Exorta fecha a lista."},
    options=[{"id": "a", "text": "prega"}, {"id": "b", "text": "insta"}, {"id": "c", "text": "exorta"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B4, short="sem", nn="03", difficulty="semente", skill="observe", type="choice",
    **qtext("O que 2 Timóteo 4:2 afirma que se deve fazer com a palavra?"),
    feedbackCorrect="Certo: pregar e instar a tempo e fora de tempo.",
    feedbackWrong={
        "a": "O texto manda instar também fora de tempo.",
        "c": "Há repreensão e exortação, não só elogio.",
        "d": "Paciência e ensino acompanham, não o silêncio.",
    },
    options=[
        {"id": "a", "text": "Pregá-la só quando for conveniente"},
        {"id": "b", "text": "Pregá-la e instar a tempo e fora de tempo"},
        {"id": "c", "text": "Nunca repreender, só elogiar"},
        {"id": "d", "text": "Calar-se, sem paciência nem ensino"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="sem", nn="04", difficulty="semente", skill="observe", type="order",
    **qtext("Qual sequência mostra a ordem dos fatos em 2 Timóteo 4:2?"),
    feedbackCorrect="Certo: pregar, instar, depois convencer, repreender e exortar.",
    feedbackWrong={"b": "A paciência não abre o versículo.", "c": "Pregar vem antes de instar."},
    options=[
        {"id": "a", "text": "prega a palavra"},
        {"id": "b", "text": "insta a tempo e fora de tempo"},
        {"id": "c", "text": "convence, repreende, exorta com toda a paciência e ensino"},
    ],
    correctOrder=["a", "b", "c"], correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B4, short="sem", nn="05", difficulty="semente", skill="observe", type="complete",
    **qtext("Complete a frase: \"exorta com toda a ___ e ensino\""),
    template="exorta com toda a ___ e ensino",
    feedbackCorrect="Certo: a exortação vem com paciência e ensino.",
    feedbackWrong={"a": "Palavra é o objeto de prega.", "c": "Tempo descreve a ocasião, não esta lacuna."},
    options=[{"id": "a", "text": "palavra"}, {"id": "b", "text": "paciência"}, {"id": "c", "text": "tempo"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="sem", nn="06", difficulty="semente", skill="observe", type="connect",
    **qtext("O que 2 Timóteo 4:2 comunica que se liga a este contexto?"),
    passageA={"ref": R4, "text": P4},
    passageB={"ref": "Contexto", "text": "Bom ministro: prega a palavra a tempo e fora de tempo — paciência e ensino, não silêncio conveniente."},
    feedbackCorrect="Certo: pregar a tempo e fora de tempo, com ensino.",
    feedbackWrong={"a": "O texto recusa o silêncio conveniente.", "c": "Há paciência, não dureza vazia."},
    options=[
        {"id": "a", "text": "Silêncio só quando convém"},
        {"id": "b", "text": "Pregar a tempo e fora"},
        {"id": "c", "text": "Repreender sem paciência"},
    ],
    correctOptionId="b", correctAnswer="b"))

OUT.append(pack(**B4, short="cam", nn="01", difficulty="caminhada", skill="understand", type="true_false",
    **qtext("Instar a palavra só a tempo, calando fora de tempo, cumpre 2 Timóteo 4:2."),
    feedbackCorrect="Certo: o texto manda instar a tempo e fora de tempo.",
    feedbackWrong={"true": "4:2 diz: insta a tempo e fora de tempo."},
    options=TF, correctOptionId="false", correctAnswer="false"))
OUT.append(pack(**B4, short="cam", nn="02", difficulty="caminhada", skill="understand", type="tap",
    **qtext('Em 2 Timóteo 4:2, toque a palavra que falta em "exorta com toda a paciência e ___"?'),
    template="exorta com toda a paciência e ___",
    feedbackCorrect="Exato: paciência vem junto com ensino.",
    feedbackWrong={"a": "Convence é outro verbo da lista.", "c": "Repreende também, mas não esta lacuna."},
    options=[{"id": "a", "text": "convence"}, {"id": "b", "text": "ensino"}, {"id": "c", "text": "repreende"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="cam", nn="03", difficulty="caminhada", skill="understand", type="choice",
    **qtext("Como 2 Timóteo 4:2 relaciona ocasião, tom e conteúdo do ministério?"),
    feedbackCorrect="Certo: a palavra não espera conveniência; o tom é paciente e didático.",
    feedbackWrong={
        "a": "Fora de tempo também pede instância.",
        "c": "Repreender sem ensino não é o quadro do verso.",
        "d": "Convencer faz parte da lista, não some.",
    },
    options=[
        {"id": "a", "text": "A palavra só se prega quando o clima é favorável"},
        {"id": "b", "text": "Prega-se sempre, convencendo e exortando com paciência e ensino"},
        {"id": "c", "text": "Repreender dispensa qualquer ensino"},
        {"id": "d", "text": "O ministro não precisa convencer nem exortar"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="cam", nn="04", difficulty="caminhada", skill="understand", type="order",
    **qtext("Como se encadeiam os eventos de 2 Timóteo 4:2?"),
    feedbackCorrect="Certo: da pregação à instância, depois os verbos com paciência.",
    feedbackWrong={"a": "A paciência não abre o encadeamento.", "c": "Pregar a palavra vem primeiro."},
    options=[
        {"id": "a", "text": "com toda a paciência e ensino"},
        {"id": "b", "text": "prega a palavra, insta a tempo e fora de tempo"},
        {"id": "c", "text": "convence, repreende, exorta"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="cam", nn="05", difficulty="caminhada", skill="understand", type="complete",
    **qtext("Complete a frase: \"prega a palavra, ___ a tempo e fora de tempo\""),
    template="prega a palavra, ___ a tempo e fora de tempo",
    feedbackCorrect="Certo: insta — urgência que não espera a hora fácil.",
    feedbackWrong={"a": "Prega já está no início.", "c": "Exorta vem depois, na lista."},
    options=[{"id": "a", "text": "prega"}, {"id": "b", "text": "insta"}, {"id": "c", "text": "exorta"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="cam", nn="06", difficulty="caminhada", skill="understand", type="connect",
    **qtext("O que 2 Timóteo 4:2 comunica que se liga a este contexto?"),
    passageA={"ref": R4, "text": P4},
    passageB={"ref": "Contexto", "text": "Bom ministro: prega a palavra a tempo e fora de tempo — paciência e ensino, não silêncio conveniente."},
    feedbackCorrect="Certo: o silêncio conveniente não é o ministério do texto.",
    feedbackWrong={"b": "Há paciência, não só dureza.", "c": "A palavra não espera a hora fácil."},
    options=[
        {"id": "a", "text": "Paciência e ensino, não silêncio"},
        {"id": "b", "text": "Repreensão sem qualquer ensino"},
        {"id": "c", "text": "Pregação só na hora fácil"},
    ],
    correctOptionId="a", correctAnswer="a"))

OUT.append(pack(**B4, short="pro", nn="01", difficulty="profundezas", skill="interpret", type="true_false",
    **qtext("O bom ministro, segundo o texto, não se cala por conveniência: prega a palavra com paciência e ensino, a tempo e fora de tempo."),
    feedbackCorrect="Certo: 4:2 recusa o silêncio conveniente.",
    feedbackWrong={"false": "Pregar e instar fora de tempo contradiz o silêncio fácil."},
    options=TF, correctOptionId="true", correctAnswer="true"))
OUT.append(pack(**B4, short="pro", nn="02", difficulty="profundezas", skill="interpret", type="tap",
    **qtext('Em 2 Timóteo 4:2, toque a palavra que falta em "convence, repreende, ___ com toda a paciência e ensino"?'),
    template="convence, repreende, ___ com toda a paciência e ensino",
    feedbackCorrect="Exato: o fecho pastoral é exorta.",
    feedbackWrong={"a": "Prega abre o versículo.", "c": "Insta descreve a urgência da ocasião."},
    options=[{"id": "a", "text": "prega"}, {"id": "b", "text": "exorta"}, {"id": "c", "text": "insta"}],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="pro", nn="03", difficulty="profundezas", skill="interpret", type="choice",
    **qtext("Qual leitura teológica 2 Timóteo 4:2 sustenta?"),
    feedbackCorrect="Certo: fidelidade à palavra une urgência, correção e paciência.",
    feedbackWrong={
        "a": "Fora de tempo também exige pregação.",
        "c": "Repreender sem paciência distorce o verso.",
        "d": "A palavra, não a opinião, é o objeto.",
    },
    options=[
        {"id": "a", "text": "A fidelidade à palavra espera sempre a ocasião fácil"},
        {"id": "b", "text": "Pregar a palavra une urgência, correção e paciência no ensino"},
        {"id": "c", "text": "Repreender autoriza impaciência e ausência de ensino"},
        {"id": "d", "text": "O ministro prega opiniões próprias, não a palavra"},
    ],
    correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="pro", nn="04", difficulty="profundezas", skill="interpret", type="order",
    **qtext("Qual sequência revela o sentido de 2 Timóteo 4:2?"),
    feedbackCorrect="Certo: a palavra, a urgência, depois o tom paciente que ensina.",
    feedbackWrong={"a": "A paciência não é o primeiro sentido isolado.", "c": "Pregar a palavra funda o resto."},
    options=[
        {"id": "a", "text": "com toda a paciência e ensino"},
        {"id": "b", "text": "prega a palavra"},
        {"id": "c", "text": "insta a tempo e fora de tempo, convence, repreende, exorta"},
    ],
    correctOrder=["b", "c", "a"], correctOptionId="b", correctAnswer="b"))
OUT.append(pack(**B4, short="pro", nn="05", difficulty="profundezas", skill="interpret", type="complete",
    **qtext("Complete a frase: \"prega a ___, insta a tempo e fora de tempo\""),
    template="prega a ___, insta a tempo e fora de tempo",
    feedbackCorrect="Certo: o objeto da pregação é a palavra.",
    feedbackWrong={"b": "Paciência fecha o versículo.", "c": "Ensino acompanha a exortação."},
    options=[{"id": "a", "text": "palavra"}, {"id": "b", "text": "paciência"}, {"id": "c", "text": "ensino"}],
    correctOptionId="a", correctAnswer="a"))
OUT.append(pack(**B4, short="pro", nn="06", difficulty="profundezas", skill="interpret", type="connect",
    **qtext("O que 2 Timóteo 4:2 comunica que se liga a este contexto?"),
    passageA={"ref": R4, "text": P4},
    passageB={"ref": "Contexto", "text": "Bom ministro: prega a palavra a tempo e fora de tempo — paciência e ensino, não silêncio conveniente."},
    feedbackCorrect="Certo: o ministro fiel não se cala por conveniência.",
    feedbackWrong={"a": "O texto manda pregar, não calar.", "c": "Há ensino junto da correção."},
    options=[
        {"id": "a", "text": "Calar quando for mais fácil"},
        {"id": "b", "text": "Palavra com paciência e ensino"},
        {"id": "c", "text": "Correção sem nenhum ensino"},
    ],
    correctOptionId="b", correctAnswer="b"))

# checks
assert len(OUT) == 72, len(OUT)
for q in OUT:
    assert len(q["feedbackCorrect"]) <= 100, (q["id"], len(q["feedbackCorrect"]), q["feedbackCorrect"])

path = Path("/Users/dalwesleyduarte/dev/new/perguntas-v2/timoteo.json")
path.write_text(json.dumps(OUT, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(path)
print(len(OUT))
