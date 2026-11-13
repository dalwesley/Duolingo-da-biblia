#!/usr/bin/env python3
"""Write exc-boss-1 and exc-boss-2 with verified touch options."""
import json, re, unicodedata
from pathlib import Path

OUT = Path(__file__).resolve().parent / "respostas"
PKT = Path(__file__).resolve().parent / "_packets"


def verses_map(slug):
    return {
        v["ref"]: v["text"]
        for v in json.loads((PKT / f"{slug}.json").read_text())["verses"]
    }


def stage_text(vm, verse_ref):
    m = re.match(r"^(.*?)\s(\d+):(\d+)(?:[–-](\d+))?$", verse_ref)
    book, ch, a, b = m.group(1), int(m.group(2)), int(m.group(3)), m.group(4)
    b = int(b) if b else a
    return " ".join(vm[f"{book} {ch}:{v}"] for v in range(a, b + 1))


def is_letter(ch):
    return bool(ch) and unicodedata.category(ch).startswith("L")


def has_word(hay, needle):
    n = needle.strip()
    from_ = 0
    while True:
        i = hay.find(n, from_)
        if i < 0:
            return False
        before = hay[i - 1] if i > 0 else ""
        after = hay[i + len(n)] if i + len(n) < len(hay) else ""
        if not is_letter(before) and not is_letter(after):
            return True
        from_ = i + 1


def dump(slug, data, expect_vf):
    vm = verses_map(slug)
    taps = []
    order_pieces = []
    for q in data["questions"]:
        pt = stage_text(vm, q["verseRef"])
        if q.get("evidenceSpan") and q["evidenceSpan"] not in pt:
            raise AssertionError(
                f'{slug} span {q["evidenceSpan"]!r} missing in {q["verseRef"]}\n{pt[:140]}'
            )
        if q["type"] == "find_in_text":
            for o in q["options"]:
                if not has_word(pt, o["text"]):
                    raise AssertionError(
                        f'{slug} touch "{o["text"]}" not in {q["verseRef"]}'
                    )
            right = next(
                o["text"] for o in q["options"] if o["id"] == q["correctOptionId"]
            )
            taps.append(right.lower())
        if q["type"] == "complete":
            right = next(
                o["text"] for o in q["options"] if o["id"] == q["correctOptionId"]
            )
            if not has_word(pt, right):
                raise AssertionError(f'{slug} complete "{right}"')
            taps.append(right.lower())
        if q["type"] == "order":
            for o in q["options"]:
                order_pieces.append((q["difficulty"], o["text"].lower()))
            if q["difficulty"] == "semente":
                cursor = -1
                for oid in q["correctOrder"]:
                    t = next(o["text"] for o in q["options"] if o["id"] == oid).rstrip(
                        ".;"
                    )
                    i = pt.find(t, cursor + 1)
                    if i < 0:
                        raise AssertionError(f"{slug} semente order {t!r}")
                    cursor = i
    if len(taps) != len(set(taps)):
        raise AssertionError(f"duplicate tap/complete: {taps}")
    # order pieces unique across modes
    seen = {}
    for mode, p in order_pieces:
        if p in seen and seen[p] != mode:
            raise AssertionError(f"order piece across modes: {p}")
        seen[p] = mode
    vf = sum(
        1
        for q in data["questions"]
        if q["type"] == "true_false" and q["correctOptionId"] == "true"
    )
    if vf != expect_vf:
        raise AssertionError(f"vfTrue={vf} expected {expect_vf}")
    for mode in ("semente", "caminhada", "profundezas"):
        n = sum(1 for q in data["questions"] if q["difficulty"] == mode)
        if n != 8:
            raise AssertionError(f"{mode} has {n} not 8")
    (OUT / f"{slug}.json").write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    )
    print(f"OK {slug} q={len(data['questions'])} vf={vf}")


def Q(**kwargs):
    return kwargs


# ===================== BOSS 1 vf=2 =====================
boss1 = {
    "study": {
        "passageRef": "Êxodo 5:1–6",
        "passages": [
            {"ref": "Êxodo 1:15–20"},
            {"ref": "Êxodo 2:1–6"},
            {"ref": "Êxodo 3:15–20"},
            {"ref": "Êxodo 4:1–6"},
            {"ref": "Êxodo 5:1–6"},
            {"ref": "Êxodo 6:2–7"},
        ],
        "context": "Este desafio revisa a opressão e o chamado: parteiras, cesto, nome, sinais, Faraó e a promessa do Senhor.",
        "keyword": "Libertar",
        "keywordGloss": "Deus ouve o clamor e chama para tirar Israel do Egito.",
        "focusQuestion": "Onde você ainda precisa crer que o Senhor vê a opressão e chama para libertar?",
        "reflectionPrompts": [
            "Temor a Deus",
            "Sinais para crer",
            "Eu sou o Senhor",
        ],
        "facts": [
            {
                "text": "As parteiras temeram a Deus e deixaram viver os meninos.",
                "evidenceRef": "Êxodo 1:17",
                "evidenceSpan": "temeram a Deus e não agiram conforme a ordem",
            },
            {
                "text": "O menino foi posto num cesto entre os juncos.",
                "evidenceRef": "Êxodo 2:3",
                "evidenceSpan": "largou-o entre os juncos à beira do rio",
            },
            {
                "text": "O Senhor é o nome eterno de Deus.",
                "evidenceRef": "Êxodo 3:15",
                "evidenceSpan": "este é o meu nome eternamente",
            },
            {
                "text": "Os sinais são para que creiam que o Senhor apareceu.",
                "evidenceRef": "Êxodo 4:5",
                "evidenceSpan": "Para que creiam que o Senhor",
            },
            {
                "text": "Faraó diz que não conhece o Senhor.",
                "evidenceRef": "Êxodo 5:2",
                "evidenceSpan": "Não conheço o Senhor",
            },
            {
                "text": "Deus promete libertar e tomar Israel por povo.",
                "evidenceRef": "Êxodo 6:6",
                "evidenceSpan": "vos libertarei das cargas do Egito",
            },
        ],
        "keyTerms": [
            {"term": "temeram", "gloss": "Respeito a Deus que guia as parteiras."},
            {"term": "bordão", "gloss": "Sinal na mão de Moisés."},
            {"term": "aliança", "gloss": "Compromisso lembrado na promessa de libertação."},
        ],
        "structure": [
            {"label": "Parteiras temem e salvam", "evidenceRef": "Êxodo 1:15–20"},
            {"label": "Cesto e chamado pelo nome", "evidenceRef": "Êxodo 2:1–6"},
            {"label": "Sinais e confronto com Faraó", "evidenceRef": "Êxodo 4:1–5"},
            {"label": "Promessa: eu sou o Senhor", "evidenceRef": "Êxodo 6:2–7"},
        ],
        "relations": [
            {
                "kind": "contraste",
                "text": "Parteiras temem a Deus, não a ordem do rei.",
                "marker": "porém",
                "evidenceRef": "Êxodo 1:17",
            },
            {
                "kind": "propósito",
                "text": "Sinais para que creiam.",
                "marker": "Para que",
                "evidenceRef": "Êxodo 4:5",
            },
            {
                "kind": "resultado",
                "text": "Por isso libertará com braço poderoso.",
                "marker": "Portanto",
                "evidenceRef": "Êxodo 6:6",
            },
        ],
        "crossRefs": [
            {"ref": "Atos 7:34", "bridge": "Deus ouviu a opressão"},
            {"ref": "Hebreus 11:23", "bridge": "Pais de Moisés temeram"},
            {"ref": "João 20:31", "bridge": "Sinais para crer"},
        ],
        "misreadings": [
            {
                "text": "Faraó já conhecia o Senhor desde o início.",
                "why": "Ele declara: Não conheço o Senhor.",
            },
            {
                "text": "Os sinais eram só para Moisés se gabar.",
                "why": "O propósito é para que creiam.",
            },
            {
                "text": "A libertação depende só da força de Israel.",
                "why": "O Senhor promete libertar com braço poderoso.",
            },
        ],
        "centralInsight": "Deus ouve o clamor e chama para libertar",
        "anchorQuestion": "O que une as parteiras, os sinais e a promessa em Êxodo 1–6?",
    },
    "questions": [],
}

# Build boss1 questions: 8 per mode
# Unique tap/complete: Sifrá, bordão, creiam, porém, Para que, Portanto, meninos, serpente, SENHOR
# Touch1 semente: Sifrá (1:15)
# Touch2 semente (07): bordão (4:2)
# Complete semente: meninos (1:17) - wait meninos in 1:17
# Actually complete words must be unique from touches

sem = [
    Q(
        difficulty="semente",
        type="true_false",
        question="As parteiras temeram a Deus e não agiram conforme a ordem do rei do Egito.",
        verseRef="Êxodo 1:17",
        correctOptionId="true",
        evidenceSpan="temeram a Deus e não agiram conforme a ordem",
        feedbackCorrect="O temor a Deus guiou a desobediência justa.",
        feedbackWrong={"false": "Releia Êxodo 1:17: elas temeram a Deus."},
        hint="A quem elas temeram?",
        learningObjective="Rever o temor das parteiras.",
        evidence=["Êxodo 1:17"],
    ),
    Q(
        difficulty="semente",
        type="find_in_text",
        question="Em Êxodo 1:15, toque o primeiro nome das parteiras.",
        verseRef="Êxodo 1:15",
        options=[
            {"id": "a", "text": "Sifrá"},
            {"id": "b", "text": "Puá"},
            {"id": "c", "text": "rei"},
        ],
        correctOptionId="a",
        evidenceSpan="se chamava Sifrá",
        feedbackCorrect="Sifrá é a primeira nomeada.",
        feedbackWrong={"b": "Puá é a segunda.", "c": "O rei falou; o nome é Sifrá."},
        hint="Dois nomes próprios no versículo.",
        learningObjective="Identificar as parteiras.",
        evidence=["Êxodo 1:15"],
    ),
    Q(
        difficulty="semente",
        type="choice",
        question="Segundo Êxodo 5:2, o que Faraó disse sobre o Senhor?",
        verseRef="Êxodo 5:2",
        options=[
            {"id": "a", "text": "Não conheço o Senhor"},
            {"id": "b", "text": "Já o sirvo de coração"},
            {"id": "c", "text": "Ele é meu aliado"},
            {"id": "d", "text": "Israel pode partir hoje"},
        ],
        correctOptionId="a",
        evidenceSpan="Não conheço o Senhor",
        feedbackCorrect="A rejeição é explícita.",
        feedbackWrong={
            "b": "Ele rejeita.",
            "c": "Não.",
            "d": "Ele não deixa ir.",
        },
        hint="A frase de recusa.",
        learningObjective="Rever a resposta de Faraó.",
        evidence=["Êxodo 5:2"],
    ),
    Q(
        difficulty="semente",
        type="order",
        question="Monte Êxodo 4:3 na ordem do texto.",
        verseRef="Êxodo 4:3",
        options=[
            {"id": "a", "text": "Disse-lhe: \"Lance-a ao chão.\""},
            {
                "id": "b",
                "text": "Ele a lançou ao chão e se transformou em uma serpente",
            },
            {"id": "c", "text": "e Moisés fugiu dela"},
        ],
        correctOrder=["a", "b", "c"],
        evidenceSpan="se transformou em uma serpente",
        feedbackCorrect="Ordem, transformação e fuga.",
        feedbackWrong={"default": "Comece pela ordem de lançar."},
        hint="A fuga vem por último.",
        learningObjective="Rever o primeiro sinal.",
        evidence=["Êxodo 4:3"],
    ),
    Q(
        difficulty="semente",
        type="complete",
        question="Em Êxodo 4:2, o que Moisés tinha na mão?",
        verseRef="Êxodo 4:2",
        options=[
            {"id": "a", "text": "bordão"},
            {"id": "b", "text": "livro"},
            {"id": "c", "text": "ouro"},
        ],
        correctOptionId="a",
        evidenceSpan="Um bordão",
        feedbackCorrect="Ele respondeu: um bordão.",
        feedbackWrong={"b": "Não é livro.", "c": "Não é ouro."},
        hint="Resposta de Moisés.",
        learningObjective="Lembrar o objeto do sinal.",
        evidence=["Êxodo 4:2"],
    ),
    Q(
        difficulty="semente",
        type="connect",
        question="O que Êxodo 6:6 comunica que se liga a este contexto?",
        verseRef="Êxodo 6:6",
        passageA={"ref": "Êxodo 6:6"},
        passageB={
            "ref": "Contexto",
            "text": "Israel geme sob as cargas do Egito.",
        },
        options=[
            {"id": "a", "text": "Senhor promete libertar"},
            {"id": "b", "text": "Israel vence sozinho"},
            {"id": "c", "text": "Faraó já se rendeu"},
        ],
        correctOptionId="a",
        evidenceSpan="vos libertarei das cargas do Egito",
        feedbackCorrect="A promessa responde à opressão.",
        feedbackWrong={"b": "Quem liberta é o Senhor.", "c": "Ainda não."},
        hint="Compare gemidos e promessa.",
        learningObjective="Ligar opressão e promessa.",
        evidence=["Êxodo 6:6"],
    ),
    Q(
        difficulty="semente",
        type="find_in_text",
        question="Em Êxodo 2:3, toque onde o cesto foi largado.",
        verseRef="Êxodo 2:3",
        options=[
            {"id": "a", "text": "entre os juncos"},
            {"id": "b", "text": "betume"},
            {"id": "c", "text": "piche"},
        ],
        correctOptionId="a",
        evidenceSpan="largou-o entre os juncos à beira do rio",
        feedbackCorrect="O cesto ficou entre os juncos à beira do rio.",
        feedbackWrong={
            "b": "Betume impermeabiliza.",
            "c": "Piche impermeabiliza.",
        },
        hint="Lugar no fim da frase.",
        learningObjective="Rever o cesto no rio.",
        evidence=["Êxodo 2:3"],
    ),
    Q(
        difficulty="semente",
        type="order",
        question="Monte Êxodo 6:6 na ordem do texto.",
        verseRef="Êxodo 6:6",
        options=[
            {
                "id": "a",
                "text": "Portanto, diga aos filhos de Israel: Eu sou o SENHOR",
            },
            {"id": "b", "text": "e vos libertarei das cargas do Egito"},
            {"id": "c", "text": "e vos resgatarei com braço poderoso"},
        ],
        correctOrder=["a", "b", "c"],
        evidenceSpan="vos libertarei das cargas do Egito",
        feedbackCorrect="Identidade, libertação e resgate.",
        feedbackWrong={"default": "Comece por Eu sou o SENHOR."},
        hint="A frase abre com Portanto.",
        learningObjective="Rever a promessa de libertação.",
        evidence=["Êxodo 6:6"],
    ),
]

cam = [
    Q(
        difficulty="caminhada",
        type="true_false",
        question="Em Êxodo 4:5, os sinais servem para que o povo creia que o Senhor apareceu a Moisés.",
        verseRef="Êxodo 4:5",
        correctOptionId="true",
        evidenceSpan="Para que creiam que o Senhor",
        feedbackCorrect="O propósito declarado é a fé.",
        feedbackWrong={"false": "Releia: Para que creiam."},
        hint="Leia o \"Para que\".",
        learningObjective="Compreender o propósito dos sinais.",
        evidence=["Êxodo 4:5"],
    ),
    Q(
        difficulty="caminhada",
        type="find_in_text",
        question="Em Êxodo 1:17, toque a palavra que marca o contraste com a ordem do rei.",
        verseRef="Êxodo 1:17",
        options=[
            {"id": "a", "text": "porém"},
            {"id": "b", "text": "antes"},
            {"id": "c", "text": "meninos"},
        ],
        correctOptionId="a",
        evidenceSpan="As parteiras, porém, temeram",
        feedbackCorrect="\"Porém\" vira a cena para o temor a Deus.",
        feedbackWrong={
            "b": "Antes introduz a ação.",
            "c": "Meninos são salvos; o marcador é porém.",
        },
        hint="Palavra curta após parteiras.",
        learningObjective="Reconhecer o contraste.",
        evidence=["Êxodo 1:17"],
    ),
    Q(
        difficulty="caminhada",
        type="choice",
        question="Como Êxodo 6:7 liga ser povo e conhecer o Senhor?",
        verseRef="Êxodo 6:7",
        options=[
            {"id": "a", "text": "Tomados por povo, saberão que Ele os tira"},
            {"id": "b", "text": "Só conhecerão depois de conquistar Canaã"},
            {"id": "c", "text": "O conhecimento vem de Faraó"},
            {"id": "d", "text": "Ser povo dispensa conhecer a Deus"},
        ],
        correctOptionId="a",
        evidenceSpan="sabereis que eu sou o Senhor vosso Deus",
        feedbackCorrect="A relação povo–Deus inclui saber quem os tira.",
        feedbackWrong={
            "b": "O saber liga-se à saída.",
            "c": "Não.",
            "d": "O texto une povo e conhecimento.",
        },
        hint="Leia o \"sabereis\".",
        learningObjective="Relacionar aliança e conhecimento.",
        evidence=["Êxodo 6:7"],
    ),
    Q(
        difficulty="caminhada",
        type="order",
        question="Como avança o bloco da opressão ao chamado?",
        verseRef="Êxodo 1:17",
        options=[
            {"id": "a", "text": "Parteiras temem a Deus"},
            {"id": "b", "text": "Deus dá sinais a Moisés"},
            {"id": "c", "text": "Faraó rejeita o Senhor"},
        ],
        correctOrder=["a", "b", "c"],
        evidenceSpan="temeram a Deus",
        feedbackCorrect="Temor, sinais e rejeição de Faraó.",
        feedbackWrong={"default": "Comece pelas parteiras."},
        hint="Faraó vem depois dos sinais.",
        learningObjective="Compreender o arco do bloco.",
        evidence=["Êxodo 1:17", "Êxodo 5:2"],
    ),
    Q(
        difficulty="caminhada",
        type="complete",
        question="Em Êxodo 4:5, o que os sinais querem que o povo faça?",
        verseRef="Êxodo 4:5",
        options=[
            {"id": "a", "text": "creiam"},
            {"id": "b", "text": "fugir"},
            {"id": "c", "text": "calar"},
        ],
        correctOptionId="a",
        evidenceSpan="Para que creiam",
        feedbackCorrect="Para que creiam que o Senhor apareceu.",
        feedbackWrong={"b": "O verbo é creiam.", "c": "Não é calar."},
        hint="Verbo após \"Para que\".",
        learningObjective="Lembrar o verbo do propósito.",
        evidence=["Êxodo 4:5"],
    ),
    Q(
        difficulty="caminhada",
        type="connect",
        question="O que liga Êxodo 1:17 a Hebreus 11:23?",
        verseRef="Êxodo 1:17",
        passageA={"ref": "Êxodo 1:17"},
        passageB={"ref": "Hebreus 11:23"},
        options=[
            {"id": "a", "text": "Temor a Deus na opressão"},
            {"id": "b", "text": "Fuga imediata do Egito"},
            {"id": "c", "text": "Aliança com Faraó"},
        ],
        correctOptionId="a",
        evidenceSpan="temeram a Deus",
        feedbackCorrect="Parteiras e pais de Moisés: temor sob ameaça.",
        feedbackWrong={"b": "Ainda não é a fuga.", "c": "Não há aliança com Faraó."},
        hint="O que une os dois textos?",
        learningObjective="Relacionar temor sob opressão.",
        evidence=["Êxodo 1:17", "Hebreus 11:23"],
    ),
    Q(
        difficulty="caminhada",
        type="find_in_text",
        question="Em Êxodo 4:5, toque as palavras que marcam o propósito dos sinais.",
        verseRef="Êxodo 4:5",
        options=[
            {"id": "a", "text": "Para que"},
            {"id": "b", "text": "Abraão"},
            {"id": "c", "text": "apareceu"},
        ],
        correctOptionId="a",
        evidenceSpan="Para que creiam",
        feedbackCorrect="\"Para que\" introduz o objetivo.",
        feedbackWrong={
            "b": "Abraão nomeia o Deus.",
            "c": "É o conteúdo da fé.",
        },
        hint="Começo do versículo.",
        learningObjective="Reconhecer o marcador de propósito.",
        evidence=["Êxodo 4:5"],
    ),
    Q(
        difficulty="caminhada",
        type="order",
        question="Como avançam as promessas em Êxodo 6:6–7?",
        verseRef="Êxodo 6:6–7",
        options=[
            {"id": "a", "text": "Libertar das cargas"},
            {"id": "b", "text": "Resgatar com braço poderoso"},
            {"id": "c", "text": "Tomar Israel por povo"},
        ],
        correctOrder=["a", "b", "c"],
        evidenceSpan="Eu vos tomarei por meu povo",
        feedbackCorrect="Libertar, resgatar e relacionar.",
        feedbackWrong={"default": "Ser povo vem depois do resgate."},
        hint="A relação povo–Deus fecha.",
        learningObjective="Compreender a ordem das promessas.",
        evidence=["Êxodo 6:6", "Êxodo 6:7"],
    ),
]

pro = [
    Q(
        difficulty="profundezas",
        type="true_false",
        question="Êxodo 1–6 ensina que Faraó conhecia o Senhor e só fingia rejeitá-lo.",
        verseRef="Êxodo 5:2",
        correctOptionId="false",
        evidenceSpan="Não conheço o Senhor e não deixarei Israel ir",
        feedbackCorrect="A declaração é de não conhecer o Senhor.",
        feedbackWrong={"true": "Releia Êxodo 5:2."},
        hint="O que Faraó declara?",
        learningObjective="Corrigir leitura sobre Faraó.",
        evidence=["Êxodo 5:2"],
    ),
    Q(
        difficulty="profundezas",
        type="find_in_text",
        question="Em Êxodo 6:7, toque o trecho que mostra o que Deus toma Israel para ser.",
        verseRef="Êxodo 6:7",
        options=[
            {"id": "a", "text": "meu povo"},
            {"id": "b", "text": "cargas"},
            {"id": "c", "text": "Egito"},
        ],
        correctOptionId="a",
        evidenceSpan="Eu vos tomarei por meu povo",
        feedbackCorrect="Ele toma Israel por seu povo.",
        feedbackWrong={"b": "Cargas são o que deixam.", "c": "Egito é a origem."},
        hint="Por meu ___.",
        learningObjective="Sustentar a relação povo–Deus.",
        evidence=["Êxodo 6:7"],
    ),
    Q(
        difficulty="profundezas",
        type="choice",
        question="Que leitura o bloco Êxodo 1–6 sustenta?",
        verseRef="Êxodo 6:6",
        options=[
            {
                "id": "a",
                "text": "Deus ouve, chama e promete libertar apesar da rejeição",
            },
            {"id": "b", "text": "A libertação depende só de Moisés"},
            {"id": "c", "text": "Faraó já era aliado do Senhor"},
            {"id": "d", "text": "Sinais não têm propósito"},
        ],
        correctOptionId="a",
        evidenceSpan="vos libertarei das cargas do Egito",
        feedbackCorrect="Do temor das parteiras à promessa: Deus age.",
        feedbackWrong={
            "b": "O Senhor liberta.",
            "c": "Ele não conhece o Senhor.",
            "d": "Sinais são para crer.",
        },
        hint="Una 1:17, 4:5 e 6:6.",
        learningObjective="Escolher a leitura do bloco.",
        evidence=["Êxodo 6:6", "Êxodo 5:2"],
    ),
    Q(
        difficulty="profundezas",
        type="order",
        question="Qual sequência revela o fio da libertação?",
        verseRef="Êxodo 6:6",
        options=[
            {"id": "a", "text": "Deus promete libertar Israel"},
            {"id": "b", "text": "Estêvão lembra que Deus ouviu a opressão"},
            {"id": "c", "text": "João registra sinais para crer"},
        ],
        correctOrder=["a", "b", "c"],
        evidenceSpan="vos libertarei",
        feedbackCorrect="Da promessa à memória e aos sinais da fé.",
        feedbackWrong={"default": "Comece pela promessa em Êxodo 6."},
        hint="Ordem da história bíblica.",
        learningObjective="Ver o fio da libertação.",
        evidence=["Êxodo 6:6", "Atos 7:34", "João 20:31"],
    ),
    Q(
        difficulty="profundezas",
        type="complete",
        question="Em Êxodo 3:15, o que é o nome de Deus eternamente?",
        verseRef="Êxodo 3:15",
        options=[
            {"id": "a", "text": "nome"},
            {"id": "b", "text": "trono"},
            {"id": "c", "text": "templo"},
        ],
        correctOptionId="a",
        evidenceSpan="este é o meu nome eternamente",
        feedbackCorrect="Este é o meu nome eternamente.",
        feedbackWrong={"b": "Não é trono.", "c": "Não é templo."},
        hint="Meu ___ eternamente.",
        learningObjective="Lembrar a revelação do nome.",
        evidence=["Êxodo 3:15"],
    ),
    Q(
        difficulty="profundezas",
        type="connect",
        question="O que liga Êxodo 4:5 a João 20:31?",
        verseRef="Êxodo 4:5",
        passageA={"ref": "Êxodo 4:5"},
        passageB={"ref": "João 20:31"},
        options=[
            {"id": "a", "text": "Sinais para crer"},
            {"id": "b", "text": "Lei no Sinai"},
            {"id": "c", "text": "Queda de Jericó"},
        ],
        correctOptionId="a",
        evidenceSpan="Para que creiam",
        feedbackCorrect="Nos dois, sinais apontam para a fé.",
        feedbackWrong={"b": "Não é o tema.", "c": "Outra história."},
        hint="Objetivo comum dos sinais?",
        learningObjective="Ligar sinais em Êxodo e João.",
        evidence=["Êxodo 4:5", "João 20:31"],
    ),
    Q(
        difficulty="profundezas",
        type="find_in_text",
        question="Em Êxodo 5:2, toque o trecho da recusa de Faraó sobre conhecer a Deus.",
        verseRef="Êxodo 5:2",
        options=[
            {"id": "a", "text": "Não conheço"},
            {"id": "b", "text": "Israel"},
            {"id": "c", "text": "voz"},
        ],
        correctOptionId="a",
        evidenceSpan="Não conheço o Senhor",
        feedbackCorrect="A frase-chave é: Não conheço o Senhor.",
        feedbackWrong={"b": "Israel é quem ele não deixa ir.", "c": "Voz é o que ele não ouve."},
        hint="Começo da segunda frase.",
        learningObjective="Sustentar a rejeição no texto.",
        evidence=["Êxodo 5:2"],
    ),
    Q(
        difficulty="profundezas",
        type="order",
        question="Qual sequência une temor, sinais e promessa?",
        verseRef="Êxodo 1:17",
        options=[
            {"id": "a", "text": "Parteiras temem a Deus acima do rei"},
            {"id": "b", "text": "Sinais são dados para gerar fé"},
            {"id": "c", "text": "O Senhor promete libertar o povo"},
        ],
        correctOrder=["a", "b", "c"],
        evidenceSpan="temeram a Deus",
        feedbackCorrect="Temor, fé pelos sinais e promessa de libertação.",
        feedbackWrong={"default": "Comece pelas parteiras."},
        hint="A promessa fecha o arco.",
        learningObjective="Unir os eixos do bloco.",
        evidence=["Êxodo 1:17", "Êxodo 4:5", "Êxodo 6:6"],
    ),
]

boss1["questions"] = sem + cam + pro
dump("exc-boss-1", boss1, 2)

# ===================== BOSS 2 vf=1 =====================
boss2 = {
    "study": {
        "passageRef": "Êxodo 11:1–6",
        "passages": [
            {"ref": "Êxodo 8:16–24"},
            {"ref": "Êxodo 9:13–21"},
            {"ref": "Êxodo 10:21–29"},
            {"ref": "Êxodo 11:1–10"},
        ],
        "context": "Este desafio revisa as pragas: piolhos e moscas, saraiva, trevas e a última praga dos primogênitos.",
        "keyword": "Distinção",
        "keywordGloss": "O Senhor julga o Egito e guarda o seu povo.",
        "focusQuestion": "Onde você precisa confiar que Deus distingue e guarda os seus no meio do juízo?",
        "reflectionPrompts": [
            "Dedo de Deus",
            "Temer a palavra",
            "Última praga",
        ],
        "facts": [
            {
                "text": "Os magos confessaram: Isto é o dedo de Deus.",
                "evidenceRef": "Êxodo 8:19",
                "evidenceSpan": "Isto é o dedo de Deus",
            },
            {
                "text": "Quem temia a palavra do Senhor recolheu servos e gado.",
                "evidenceRef": "Êxodo 9:20",
                "evidenceSpan": "temia a palavra do Senhor",
            },
            {
                "text": "Houve trevas espessas no Egito por três dias.",
                "evidenceRef": "Êxodo 10:22",
                "evidenceSpan": "trevas espessas sobre toda a terra do Egito por três dias",
            },
            {
                "text": "Israel tinha luz em suas habitações.",
                "evidenceRef": "Êxodo 10:23",
                "evidenceSpan": "tinham luz em suas habitações",
            },
            {
                "text": "Todo primogênito no Egito morrerá.",
                "evidenceRef": "Êxodo 11:5",
                "evidenceSpan": "todo primogênito na terra do Egito morrerá",
            },
            {
                "text": "O Senhor fará distinção entre egípcios e israelitas.",
                "evidenceRef": "Êxodo 11:7",
                "evidenceSpan": "o Senhor fez distinção entre os egípcios e os israelitas",
            },
        ],
        "keyTerms": [
            {"term": "dedo", "gloss": "Confissão dos magos sobre o poder de Deus."},
            {"term": "granizo", "gloss": "Chuva intensa anunciada a quem não teme a palavra."},
            {"term": "primogênito", "gloss": "Alvo da última praga."},
        ],
        "structure": [
            {"label": "Piolhos e confissão dos magos", "evidenceRef": "Êxodo 8:16–19"},
            {"label": "Saraiva e temor da palavra", "evidenceRef": "Êxodo 9:18–21"},
            {"label": "Trevas e luz em Gósen", "evidenceRef": "Êxodo 10:21–23"},
            {"label": "Última praga e distinção", "evidenceRef": "Êxodo 11:1–7"},
        ],
        "relations": [
            {
                "kind": "contraste",
                "text": "Magos confessam; porém Faraó endurece.",
                "marker": "Porém",
                "evidenceRef": "Êxodo 8:19",
            },
            {
                "kind": "contraste",
                "text": "Quem teme recolhe; quem ignora deixa no campo.",
                "marker": "Mas",
                "evidenceRef": "Êxodo 9:21",
            },
            {
                "kind": "propósito",
                "text": "Faraó não ouvirá a fim de multiplicar maravilhas.",
                "marker": "a fim de que",
                "evidenceRef": "Êxodo 11:9",
            },
        ],
        "crossRefs": [
            {"ref": "Lucas 11:20", "bridge": "Dedo de Deus no reino"},
            {"ref": "Êxodo 12:29", "bridge": "Primogênitos morrem"},
            {"ref": "Salmos 78:51", "bridge": "Feriu os primogênitos"},
        ],
        "misreadings": [
            {
                "text": "As pragas atingem Israel e o Egito igualmente.",
                "why": "Há distinção: Gósen, luz e silêncio em Israel.",
            },
            {
                "text": "Os magos igualaram Deus até o fim.",
                "why": "Eles falharam e confessaram o dedo de Deus.",
            },
            {
                "text": "Temer a palavra do Senhor não muda nada.",
                "why": "Quem temeu recolheu e salvou servos e gado.",
            },
        ],
        "centralInsight": "O Senhor julga o Egito e guarda o seu povo",
        "anchorQuestion": "Como o Senhor distingue o seu povo nas pragas?",
    },
    "questions": [],
}

# vf=1: only one true — make caminhada true, others false
sem2 = [
    Q(
        difficulty="semente",
        type="true_false",
        question="Os magos produziram piolhos com facilidade e superaram a Arão.",
        verseRef="Êxodo 8:18",
        correctOptionId="false",
        evidenceSpan="mas não conseguiram",
        feedbackCorrect="Eles tentaram e não conseguiram.",
        feedbackWrong={"true": "Releia: não conseguiram."},
        hint="O resultado da tentativa.",
        learningObjective="Rever o limite dos magos.",
        evidence=["Êxodo 8:18"],
    ),
    Q(
        difficulty="semente",
        type="find_in_text",
        question="Em Êxodo 8:19, toque o que os magos disseram ser o sinal.",
        verseRef="Êxodo 8:19",
        options=[
            {"id": "a", "text": "dedo de Deus"},
            {"id": "b", "text": "coração"},
            {"id": "c", "text": "Faraó"},
        ],
        correctOptionId="a",
        evidenceSpan="Isto é o dedo de Deus",
        feedbackCorrect="A confissão é: Isto é o dedo de Deus.",
        feedbackWrong={
            "b": "Coração é o de Faraó.",
            "c": "Faraó ouve; a confissão é sobre Deus.",
        },
        hint="Depois de \"Isto é\".",
        learningObjective="Identificar a confissão.",
        evidence=["Êxodo 8:19"],
    ),
    Q(
        difficulty="semente",
        type="choice",
        question="Segundo Êxodo 10:22, quanto tempo duraram as trevas?",
        verseRef="Êxodo 10:22",
        options=[
            {"id": "a", "text": "Três dias"},
            {"id": "b", "text": "Uma hora"},
            {"id": "c", "text": "Um mês"},
            {"id": "d", "text": "Um ano"},
        ],
        correctOptionId="a",
        evidenceSpan="por três dias",
        feedbackCorrect="Trevas espessas por três dias.",
        feedbackWrong={"b": "São três dias.", "c": "Não.", "d": "Não."},
        hint="Duração no fim do verso.",
        learningObjective="Observar as trevas.",
        evidence=["Êxodo 10:22"],
    ),
    Q(
        difficulty="semente",
        type="order",
        question="Monte Êxodo 8:19 na ordem do texto.",
        verseRef="Êxodo 8:19",
        options=[
            {
                "id": "a",
                "text": "Então, os magos disseram a Faraó: Isto é o dedo de Deus",
            },
            {"id": "b", "text": "Porém, o coração de Faraó se endureceu"},
            {"id": "c", "text": "e não os ouviu como o SENHOR havia dito"},
        ],
        correctOrder=["a", "b", "c"],
        evidenceSpan="Isto é o dedo de Deus",
        feedbackCorrect="Confissão, endurecimento e surdez.",
        feedbackWrong={"default": "Comece pela fala dos magos."},
        hint="O Porém vem depois.",
        learningObjective="Rever 8:19.",
        evidence=["Êxodo 8:19"],
    ),
    Q(
        difficulty="semente",
        type="complete",
        question="Em Êxodo 11:5, quem morrerá na terra do Egito?",
        verseRef="Êxodo 11:5",
        options=[
            {"id": "a", "text": "primogênito"},
            {"id": "b", "text": "estrangeiro"},
            {"id": "c", "text": "profeta"},
        ],
        correctOptionId="a",
        evidenceSpan="todo primogênito na terra do Egito morrerá",
        feedbackCorrect="Todo primogênito é o alvo.",
        feedbackWrong={"b": "Não.", "c": "Não."},
        hint="Todo ___ no Egito.",
        learningObjective="Lembrar a última praga.",
        evidence=["Êxodo 11:5"],
    ),
    Q(
        difficulty="semente",
        type="connect",
        question="O que Êxodo 11:7 comunica que se liga a este contexto?",
        verseRef="Êxodo 11:7",
        passageA={"ref": "Êxodo 11:7"},
        passageB={
            "ref": "Contexto",
            "text": "A última praga cairá sobre o Egito.",
        },
        options=[
            {"id": "a", "text": "Deus distingue Israel"},
            {"id": "b", "text": "Israel sofre igual"},
            {"id": "c", "text": "Faraó já libertou"},
        ],
        correctOptionId="a",
        evidenceSpan="o Senhor fez distinção",
        feedbackCorrect="Em Israel nem um cão rosnará.",
        feedbackWrong={"b": "Há distinção.", "c": "Ainda não."},
        hint="Compare Egito e Israel.",
        learningObjective="Ligar praga e distinção.",
        evidence=["Êxodo 11:7"],
    ),
    Q(
        difficulty="semente",
        type="find_in_text",
        question="Em Êxodo 9:20, toque o que os oficiais temiam.",
        verseRef="Êxodo 9:20",
        options=[
            {"id": "a", "text": "palavra do Senhor"},
            {"id": "b", "text": "oficiais"},
            {"id": "c", "text": "casas"},
        ],
        correctOptionId="a",
        evidenceSpan="temia a palavra do Senhor",
        feedbackCorrect="Quem temia a palavra recolheu servos e gado.",
        feedbackWrong={
            "b": "Oficiais são quem teme.",
            "c": "Casas são o refúgio.",
        },
        hint="Objeto de \"temia\".",
        learningObjective="Identificar o temor da palavra.",
        evidence=["Êxodo 9:20"],
    ),
    Q(
        difficulty="semente",
        type="order",
        question="Monte Êxodo 11:1 na ordem do texto.",
        verseRef="Êxodo 11:1",
        options=[
            {
                "id": "a",
                "text": "Então, o Senhor disse a Moisés: Ainda trarei mais uma praga",
            },
            {"id": "b", "text": "sobre Faraó e sobre o Egito"},
            {"id": "c", "text": "então, ele os deixará ir daqui"},
        ],
        correctOrder=["a", "b", "c"],
        evidenceSpan="Ainda trarei mais uma praga",
        feedbackCorrect="Anúncio, alvo e saída.",
        feedbackWrong={"default": "Comece pelo anúncio."},
        hint="A saída vem depois.",
        learningObjective="Rever o anúncio final.",
        evidence=["Êxodo 11:1"],
    ),
]

cam2 = [
    Q(
        difficulty="caminhada",
        type="true_false",
        question="Em Êxodo 9:20–21, quem temia a palavra do Senhor agiu; quem não prestou atenção deixou tudo no campo.",
        verseRef="Êxodo 9:20–21",
        correctOptionId="true",
        evidenceSpan="temia a palavra do Senhor",
        feedbackCorrect="Temor produz ação; ignorância deixa no campo.",
        feedbackWrong={"false": "Compare 9:20 e 9:21."},
        hint="Compare os dois oficiais.",
        learningObjective="Compreender temor e ação.",
        evidence=["Êxodo 9:20", "Êxodo 9:21"],
    ),
    Q(
        difficulty="caminhada",
        type="find_in_text",
        question="Em Êxodo 8:19, toque a palavra que marca o contraste após a confissão.",
        verseRef="Êxodo 8:19",
        options=[
            {"id": "a", "text": "Porém"},
            {"id": "b", "text": "magos"},
            {"id": "c", "text": "dito"},
        ],
        correctOptionId="a",
        evidenceSpan="Porém, o coração de Faraó",
        feedbackCorrect="\"Porém\" introduz o endurecimento.",
        feedbackWrong={"b": "Magos confessam.", "c": "Dito fecha a frase."},
        hint="Após a confissão.",
        learningObjective="Reconhecer o contraste.",
        evidence=["Êxodo 8:19"],
    ),
    Q(
        difficulty="caminhada",
        type="choice",
        question="Como Êxodo 10:23 contraste Egito e Israel?",
        verseRef="Êxodo 10:23",
        options=[
            {"id": "a", "text": "Egito sem movimento; Israel com luz em casa"},
            {"id": "b", "text": "Ambos sem luz nenhuma"},
            {"id": "c", "text": "Só Faraó tinha luz"},
            {"id": "d", "text": "Israel pediu trevas"},
        ],
        correctOptionId="a",
        evidenceSpan="tinham luz em suas habitações",
        feedbackCorrect="Trevas no Egito; luz nas casas de Israel.",
        feedbackWrong={"b": "Israel tinha luz.", "c": "Não.", "d": "Não."},
        hint="O fim do versículo.",
        learningObjective="Relacionar trevas e luz.",
        evidence=["Êxodo 10:23"],
    ),
    Q(
        difficulty="caminhada",
        type="order",
        question="Como avançam as pragas neste bloco?",
        verseRef="Êxodo 8:19",
        options=[
            {"id": "a", "text": "Magos confessam o dedo de Deus"},
            {"id": "b", "text": "Saraiva separa quem teme a palavra"},
            {"id": "c", "text": "Última praga anuncia os primogênitos"},
        ],
        correctOrder=["a", "b", "c"],
        evidenceSpan="dedo de Deus",
        feedbackCorrect="Confissão, temor e anúncio final.",
        feedbackWrong={"default": "Comece pelos magos."},
        hint="A última praga fecha.",
        learningObjective="Compreender o arco das pragas.",
        evidence=["Êxodo 8:19", "Êxodo 11:5"],
    ),
    Q(
        difficulty="caminhada",
        type="complete",
        question="Em Êxodo 11:7, o que o Senhor fez entre egípcios e israelitas?",
        verseRef="Êxodo 11:7",
        options=[
            {"id": "a", "text": "distinção"},
            {"id": "b", "text": "aliança"},
            {"id": "c", "text": "guerra"},
        ],
        correctOptionId="a",
        evidenceSpan="o Senhor fez distinção",
        feedbackCorrect="A palavra-chave é distinção.",
        feedbackWrong={"b": "Aqui é distinção.", "c": "Não diz guerra."},
        hint="Fez ___.",
        learningObjective="Lembrar a distinção.",
        evidence=["Êxodo 11:7"],
    ),
    Q(
        difficulty="caminhada",
        type="connect",
        question="O que liga Êxodo 8:19 a Lucas 11:20?",
        verseRef="Êxodo 8:19",
        passageA={"ref": "Êxodo 8:19"},
        passageB={"ref": "Lucas 11:20"},
        options=[
            {"id": "a", "text": "Dedo de Deus age"},
            {"id": "b", "text": "Lei cerimonial"},
            {"id": "c", "text": "Lista de reis"},
        ],
        correctOptionId="a",
        evidenceSpan="dedo de Deus",
        feedbackCorrect="A mesma imagem marca a ação divina.",
        feedbackWrong={"b": "Não.", "c": "Não."},
        hint="Imagem comum.",
        learningObjective="Relacionar Êxodo e Lucas.",
        evidence=["Êxodo 8:19", "Lucas 11:20"],
    ),
    Q(
        difficulty="caminhada",
        type="find_in_text",
        question="Em Êxodo 10:23, toque o que os filhos de Israel tinham.",
        verseRef="Êxodo 10:23",
        options=[
            {"id": "a", "text": "luz"},
            {"id": "b", "text": "habitações"},
            {"id": "c", "text": "lugar"},
        ],
        correctOptionId="a",
        evidenceSpan="tinham luz em suas habitações",
        feedbackCorrect="Eles tinham luz em suas habitações.",
        feedbackWrong={"b": "Habitações são onde a luz está.", "c": "Lugar é genérico."},
        hint="O que havia nas casas?",
        learningObjective="Identificar a luz de Israel.",
        evidence=["Êxodo 10:23"],
    ),
    Q(
        difficulty="caminhada",
        type="order",
        question="Como avança o anúncio da última praga?",
        verseRef="Êxodo 11:1–2",
        options=[
            {"id": "a", "text": "Anuncia-se mais uma praga"},
            {"id": "b", "text": "Primogênitos morrerão"},
            {"id": "c", "text": "Israel será distinguido"},
        ],
        correctOrder=["a", "b", "c"],
        evidenceSpan="Ainda trarei mais uma praga",
        feedbackCorrect="Praga, juízo e distinção.",
        feedbackWrong={"default": "A distinção vem por último."},
        hint="Feche com a distinção.",
        learningObjective="Compreender o anúncio.",
        evidence=["Êxodo 11:1", "Êxodo 11:7"],
    ),
]

pro2 = [
    Q(
        difficulty="profundezas",
        type="true_false",
        question="As pragas de Êxodo 8–11 atingem Israel e o Egito sem qualquer distinção.",
        verseRef="Êxodo 11:7",
        correctOptionId="false",
        evidenceSpan="o Senhor fez distinção entre os egípcios e os israelitas",
        feedbackCorrect="O texto insiste na distinção do povo.",
        feedbackWrong={"true": "Releia 11:7 e também 8:22 e 10:23."},
        hint="O que o Senhor fez entre os povos?",
        learningObjective="Corrigir leitura sem distinção.",
        evidence=["Êxodo 11:7"],
    ),
    Q(
        difficulty="profundezas",
        type="find_in_text",
        question="Em Êxodo 11:7, toque quem é distinguido junto com os egípcios.",
        verseRef="Êxodo 11:7",
        options=[
            {"id": "a", "text": "israelitas"},
            {"id": "b", "text": "animais"},
            {"id": "c", "text": "rosnará"},
        ],
        correctOptionId="a",
        evidenceSpan="entre os egípcios e os israelitas",
        feedbackCorrect="A distinção é entre egípcios e israelitas.",
        feedbackWrong={
            "b": "Animais entram no silêncio de Israel.",
            "c": "Rosnará ilustra o silêncio.",
        },
        hint="O segundo povo nomeado.",
        learningObjective="Sustentar a distinção.",
        evidence=["Êxodo 11:7"],
    ),
    Q(
        difficulty="profundezas",
        type="choice",
        question="Que leitura Êxodo 8–11 sustenta sobre as pragas?",
        verseRef="Êxodo 11:7",
        options=[
            {
                "id": "a",
                "text": "Deus julga o Egito e guarda o seu povo",
            },
            {"id": "b", "text": "Magos e Deus têm o mesmo poder"},
            {"id": "c", "text": "Temer a palavra não muda nada"},
            {"id": "d", "text": "Israel sofre as trevas como o Egito"},
        ],
        correctOptionId="a",
        evidenceSpan="o Senhor fez distinção",
        feedbackCorrect="Confissão, temor, luz e distinção apontam para isso.",
        feedbackWrong={
            "b": "Os magos falharam.",
            "c": "Quem temeu agiu.",
            "d": "Israel tinha luz.",
        },
        hint="Una 8:19, 9:20, 10:23 e 11:7.",
        learningObjective="Escolher a leitura do bloco.",
        evidence=["Êxodo 11:7", "Êxodo 10:23"],
    ),
    Q(
        difficulty="profundezas",
        type="order",
        question="Qual sequência revela o fio das pragas?",
        verseRef="Êxodo 11:5",
        options=[
            {"id": "a", "text": "Anuncia-se a morte dos primogênitos"},
            {"id": "b", "text": "A noite da Páscoa cumpre o anúncio"},
            {"id": "c", "text": "O Salmo lembra o ferimento dos primogênitos"},
        ],
        correctOrder=["a", "b", "c"],
        evidenceSpan="todo primogênito",
        feedbackCorrect="Do anúncio ao cumprimento e à memória.",
        feedbackWrong={"default": "Comece por Êxodo 11."},
        hint="Ordem da história bíblica.",
        learningObjective="Ver o fio da última praga.",
        evidence=["Êxodo 11:5", "Êxodo 12:29", "Salmos 78:51"],
    ),
    Q(
        difficulty="profundezas",
        type="complete",
        question="Em Êxodo 8:19, o que é o sinal segundo os magos?",
        verseRef="Êxodo 8:19",
        options=[
            {"id": "a", "text": "dedo"},
            {"id": "b", "text": "sono"},
            {"id": "c", "text": "vento"},
        ],
        correctOptionId="a",
        evidenceSpan="Isto é o dedo de Deus",
        feedbackCorrect="O termo da confissão é dedo.",
        feedbackWrong={"b": "Não.", "c": "Não."},
        hint="Isto é o ___ de Deus.",
        learningObjective="Lembrar o termo teológico.",
        evidence=["Êxodo 8:19"],
    ),
    Q(
        difficulty="profundezas",
        type="connect",
        question="O que liga Êxodo 11:5 a Êxodo 12:29?",
        verseRef="Êxodo 11:5",
        passageA={"ref": "Êxodo 11:5"},
        passageB={"ref": "Êxodo 12:29"},
        options=[
            {"id": "a", "text": "Primogênitos morrem"},
            {"id": "b", "text": "Construção do altar"},
            {"id": "c", "text": "Censo no deserto"},
        ],
        correctOptionId="a",
        evidenceSpan="todo primogênito na terra do Egito morrerá",
        feedbackCorrect="O anúncio se cumpre na noite da Páscoa.",
        feedbackWrong={"b": "Não.", "c": "Não."},
        hint="Anúncio e cumprimento.",
        learningObjective="Relacionar anúncio e cumprimento.",
        evidence=["Êxodo 11:5", "Êxodo 12:29"],
    ),
    Q(
        difficulty="profundezas",
        type="find_in_text",
        question="Em Êxodo 9:21, toque o trecho que mostra a atitude de quem não temeu.",
        verseRef="Êxodo 9:21",
        options=[
            {"id": "a", "text": "não prestou atenção"},
            {"id": "b", "text": "Senhor"},
            {"id": "c", "text": "campo"},
        ],
        correctOptionId="a",
        evidenceSpan="não prestou atenção à palavra do Senhor",
        feedbackCorrect="Não prestar atenção deixa tudo no campo.",
        feedbackWrong={"b": "Senhor é quem fala.", "c": "Campo é onde deixam."},
        hint="Começo da frase.",
        learningObjective="Sustentar o contraste do temor.",
        evidence=["Êxodo 9:21"],
    ),
    Q(
        difficulty="profundezas",
        type="order",
        question="Qual sequência une confissão, temor e distinção?",
        verseRef="Êxodo 8:19",
        options=[
            {"id": "a", "text": "Os magos reconhecem o poder de Deus"},
            {"id": "b", "text": "Quem teme a palavra salva servos e gado"},
            {"id": "c", "text": "Na última praga Israel é separado"},
        ],
        correctOrder=["a", "b", "c"],
        evidenceSpan="dedo de Deus",
        feedbackCorrect="Confissão, temor prático e distinção final.",
        feedbackWrong={"default": "Comece pelos magos."},
        hint="A distinção fecha o bloco.",
        learningObjective="Unir os eixos das pragas.",
        evidence=["Êxodo 8:19", "Êxodo 9:20", "Êxodo 11:7"],
    ),
]

boss2["questions"] = sem2 + cam2 + pro2
dump("exc-boss-2", boss2, 1)
print("bosses done")
