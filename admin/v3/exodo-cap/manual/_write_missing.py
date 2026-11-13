#!/usr/bin/env python3
"""Write missing V3 respostas with verified find_in_text options."""
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
    if not m:
        raise ValueError(verse_ref)
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


def dump(slug, data):
    vm = verses_map(slug)
    taps = []
    for q in data["questions"]:
        pt = stage_text(vm, q["verseRef"])
        if q.get("evidenceSpan") and q["evidenceSpan"] not in pt:
            raise AssertionError(
                f'{slug} span {q["evidenceSpan"]!r} missing in {q["verseRef"]}'
            )
        if q["type"] == "find_in_text":
            for o in q["options"]:
                if not has_word(pt, o["text"]):
                    raise AssertionError(
                        f'{slug} touch "{o["text"]}" not in {q["verseRef"]}: {pt[:100]}'
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
                raise AssertionError(f'{slug} complete "{right}" not in {q["verseRef"]}')
            taps.append(right.lower())
        if q["type"] == "order" and q["difficulty"] == "semente":
            cursor = -1
            for oid in q["correctOrder"]:
                t = next(o["text"] for o in q["options"] if o["id"] == oid).rstrip(".;")
                i = pt.find(t, cursor + 1)
                if i < 0:
                    raise AssertionError(f"{slug} order {t!r}")
                cursor = i
    if len(taps) != len(set(taps)):
        raise AssertionError(f"{slug} duplicate tap/complete answers: {taps}")
    vf = sum(
        1
        for q in data["questions"]
        if q["type"] == "true_false" and q["correctOptionId"] == "true"
    )
    (OUT / f"{slug}.json").write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    )
    print(f"OK {slug} q={len(data['questions'])} vfTrue={vf}")


def q_tf(diff, question, verse, cid, span, ok, bad, hint, lo, ev=None):
    return {
        "difficulty": diff,
        "type": "true_false",
        "question": question,
        "verseRef": verse,
        "correctOptionId": cid,
        "evidenceSpan": span,
        "feedbackCorrect": ok,
        "feedbackWrong": {("false" if cid == "true" else "true"): bad},
        "hint": hint,
        "learningObjective": lo,
        "evidence": ev or [verse.split("–")[0] if "–" in verse else verse],
    }


def q_touch(diff, question, verse, opts, cid, span, ok, wrong, hint, lo):
    return {
        "difficulty": diff,
        "type": "find_in_text",
        "question": question,
        "verseRef": verse,
        "options": [{"id": k, "text": v} for k, v in opts],
        "correctOptionId": cid,
        "evidenceSpan": span,
        "feedbackCorrect": ok,
        "feedbackWrong": wrong,
        "hint": hint,
        "learningObjective": lo,
        "evidence": [verse.split("–")[0] if "–" in verse else verse],
    }


def q_choice(diff, question, verse, opts, cid, span, ok, wrong, hint, lo, ev=None):
    return {
        "difficulty": diff,
        "type": "choice",
        "question": question,
        "verseRef": verse,
        "options": [{"id": k, "text": v} for k, v in opts],
        "correctOptionId": cid,
        "evidenceSpan": span,
        "feedbackCorrect": ok,
        "feedbackWrong": wrong,
        "hint": hint,
        "learningObjective": lo,
        "evidence": ev or [verse.split("–")[0] if "–" in verse else verse],
    }


def q_order(diff, question, verse, opts, order, span, ok, hint, lo, ev=None, evidence=None):
    d = {
        "difficulty": diff,
        "type": "order",
        "question": question,
        "verseRef": verse,
        "options": [{"id": k, "text": v} for k, v in opts],
        "correctOrder": order,
        "evidenceSpan": span,
        "feedbackCorrect": ok,
        "feedbackWrong": {"default": "Revise a ordem do texto."},
        "hint": hint,
        "learningObjective": lo,
        "evidence": evidence or ev or [verse.split("–")[0] if "–" in verse else verse],
    }
    return d


def q_complete(diff, question, verse, opts, cid, span, ok, wrong, hint, lo):
    return {
        "difficulty": diff,
        "type": "complete",
        "question": question,
        "verseRef": verse,
        "options": [{"id": k, "text": v} for k, v in opts],
        "correctOptionId": cid,
        "evidenceSpan": span,
        "feedbackCorrect": ok,
        "feedbackWrong": wrong,
        "hint": hint,
        "learningObjective": lo,
        "evidence": [verse.split("–")[0] if "–" in verse else verse],
    }


def q_connect(diff, question, verse, a, b, opts, cid, span, ok, wrong, hint, lo, ev=None):
    return {
        "difficulty": diff,
        "type": "connect",
        "question": question,
        "verseRef": verse,
        "passageA": a,
        "passageB": b,
        "options": [{"id": k, "text": v} for k, v in opts],
        "correctOptionId": cid,
        "evidenceSpan": span,
        "feedbackCorrect": ok,
        "feedbackWrong": wrong,
        "hint": hint,
        "learningObjective": lo,
        "evidence": ev or [verse],
    }


# --------------- exc-12 vf=1 ---------------
exc12 = {
    "study": {
        "passageRef": "Êxodo 13:17–22",
        "passages": [{"ref": "Êxodo 13:17–22"}],
        "context": "Deus não leva Israel pelo caminho curto dos filisteus. Vai adiante em coluna de nuvem e de fogo.",
        "keyword": "Coluna",
        "keywordGloss": "Presença do Senhor que guia de dia e ilumina de noite.",
        "focusQuestion": "Quando o caminho de Deus parece mais longo, como você responde?",
        "reflectionPrompts": ["Caminho mais longo", "Nuvem e fogo", "Nunca se afasta"],
        "facts": [
            {
                "text": "Deus não conduziu o povo pelo caminho dos filisteus.",
                "evidenceRef": "Êxodo 13:17",
                "evidenceSpan": "não os conduziu pelo caminho da terra dos filisteus",
            },
            {
                "text": "Temeu que o povo desanimasse ao ver a guerra.",
                "evidenceRef": "Êxodo 13:17",
                "evidenceSpan": "Para que o povo não desanime ao ver a guerra",
            },
            {
                "text": "Deus fez o povo rodear pelo deserto rumo ao mar Vermelho.",
                "evidenceRef": "Êxodo 13:18",
                "evidenceSpan": "rodeasse o caminho pelo deserto",
            },
            {
                "text": "O Senhor ia à frente em coluna de nuvem e de fogo.",
                "evidenceRef": "Êxodo 13:21",
                "evidenceSpan": "o Senhor ia à frente deles",
            },
            {
                "text": "A nuvem e o fogo nunca se afastaram do povo.",
                "evidenceRef": "Êxodo 13:22",
                "evidenceSpan": "Nunca se afastou do povo",
            },
        ],
        "keyTerms": [
            {"term": "coluna", "gloss": "Forma visível da presença que guia e ilumina."},
            {"term": "nuvem", "gloss": "Guia diurna no caminho."},
            {"term": "fogo", "gloss": "Ilumina a noite para caminhar."},
        ],
        "structure": [
            {"label": "Recusa do caminho curto", "evidenceRef": "Êxodo 13:17"},
            {"label": "Rota pelo deserto e ossos de José", "evidenceRef": "Êxodo 13:18–19"},
            {"label": "Acampamento em Etã", "evidenceRef": "Êxodo 13:20"},
            {"label": "Coluna de nuvem e de fogo", "evidenceRef": "Êxodo 13:21–22"},
        ],
        "relations": [
            {
                "kind": "propósito",
                "text": "Evitar o caminho curto para o povo não desanimar na guerra.",
                "marker": "Para que",
                "evidenceRef": "Êxodo 13:17",
            },
            {
                "kind": "contraste",
                "text": "Não pelo caminho próximo, mas pelo deserto.",
                "marker": "Mas",
                "evidenceRef": "Êxodo 13:18",
            },
            {
                "kind": "resultado",
                "text": "Assim caminhavam de dia e de noite sob a coluna.",
                "marker": "a fim de que",
                "evidenceRef": "Êxodo 13:21",
            },
        ],
        "crossRefs": [
            {"ref": "Neemias 9:12", "bridge": "Coluna guia o caminho"},
            {"ref": "Salmos 78:14", "bridge": "Nuvem e fogo"},
            {"ref": "1 Coríntios 10:1", "bridge": "Sob a nuvem"},
        ],
        "misreadings": [
            {
                "text": "Deus escolheu o caminho mais curto.",
                "why": "Ele evitiu o caminho próximo dos filisteus.",
            },
            {
                "text": "A coluna aparecia só de dia.",
                "why": "Há nuvem de dia e fogo de noite.",
            },
            {
                "text": "A presença às vezes abandonava o povo.",
                "why": "Nunca se afastou.",
            },
        ],
        "centralInsight": "O Senhor guia o caminho e não se afasta: nuvem de dia, fogo de noite.",
        "anchorQuestion": "Como o Senhor ia à frente do povo no deserto?",
    },
    "questions": [
        q_tf(
            "semente",
            "Deus conduziu Israel pelo caminho mais próximo, a terra dos filisteus.",
            "Êxodo 13:17",
            "false",
            "não os conduziu pelo caminho da terra dos filisteus",
            "Ele evitou o caminho próximo.",
            "Releia: não os conduziu por esse caminho.",
            "O texto diz \"não os conduziu\".",
            "Observar a escolha da rota.",
        ),
        q_touch(
            "semente",
            "Em Êxodo 13:21, toque o que guiava o povo de dia.",
            "Êxodo 13:21",
            [("a", "coluna de nuvem"), ("b", "coluna de fogo"), ("c", "caminho")],
            "a",
            "em uma coluna de nuvem, para guiá-los",
            "De dia, coluna de nuvem para guiar.",
            {
                "b": "Fogo é à noite; de dia é nuvem.",
                "c": "Caminho é o que se guia; a forma é nuvem.",
            },
            "Forma da presença de dia.",
            "Identificar a coluna diurna.",
        ),
        q_choice(
            "semente",
            "Segundo Êxodo 13:17, por que Deus evitou o caminho dos filisteus?",
            "Êxodo 13:17",
            [
                ("a", "Para que o povo não desanime ao ver a guerra"),
                ("b", "Porque faltava comida"),
                ("c", "Porque Moisés pediu"),
                ("d", "Porque o mar estava fechado"),
            ],
            "a",
            "Para que o povo não desanime ao ver a guerra",
            "O motivo é evitar o desânimo diante da guerra.",
            {
                "b": "Não é sobre comida aqui.",
                "c": "A decisão é de Deus.",
                "d": "Não é o motivo dado.",
            },
            "Leia o \"Para que\".",
            "Observar o motivo da rota.",
        ),
        q_order(
            "semente",
            "Monte Êxodo 13:21 na ordem do texto.",
            "Êxodo 13:21",
            [
                (
                    "a",
                    "E o Senhor ia à frente deles, durante o dia, em uma coluna de nuvem",
                ),
                ("b", "para guiá-los pelo caminho"),
                ("c", "e à noite, em uma coluna de fogo, para iluminá-los"),
            ],
            ["a", "b", "c"],
            "coluna de nuvem",
            "Presença, guia e luz noturna.",
            "A noite vem depois do dia.",
            "Reconhecer a sequência.",
        ),
        q_complete(
            "semente",
            "Em Êxodo 13:22, o que nunca se afastou do povo de dia?",
            "Êxodo 13:22",
            [("a", "nuvem"), ("b", "exército"), ("c", "templo")],
            "a",
            "Nunca se afastou do povo a nuvem durante o dia",
            "A nuvem permanece de dia; o fogo, de noite.",
            {"b": "Não é exército.", "c": "Não é templo."},
            "O que fica de dia?",
            "Lembrar a constância da presença.",
        ),
        q_connect(
            "semente",
            "O que Êxodo 13:21 comunica que se liga a este contexto?",
            "Êxodo 13:21",
            {"ref": "Êxodo 13:21"},
            {"ref": "Contexto", "text": "Deus escolheu uma rota mais longa pelo deserto."},
            [
                ("a", "Senhor guia na frente"),
                ("b", "Povo segue sozinho"),
                ("c", "Coluna some à noite"),
            ],
            "a",
            "o Senhor ia à frente deles",
            "Na rota longa, o Senhor mesmo guia.",
            {"b": "Ele vai à frente.", "c": "Há coluna de fogo à noite."},
            "Quem vai à frente?",
            "Ligar rota e presença.",
        ),
        q_tf(
            "caminhada",
            "Em Êxodo 13:17, Deus evita o caminho curto para que o povo não desanime ao ver a guerra.",
            "Êxodo 13:17",
            "true",
            "Para que o povo não desanime ao ver a guerra",
            "O propósito é proteger a fé frágil do povo.",
            "Releia o \"Para que\" no versículo.",
            "Motivo declarado por Deus.",
            "Compreender o propósito da rota.",
        ),
        q_touch(
            "caminhada",
            "Em Êxodo 13:17, toque as palavras que marcam o propósito de Deus.",
            "Êxodo 13:17",
            [("a", "Para que"), ("b", "filisteus"), ("c", "Egito")],
            "a",
            "Para que o povo não desanime",
            "\"Para que\" introduz o motivo.",
            {"b": "Filisteus nomeiam o caminho.", "c": "Egito é a origem."},
            "Começo da fala de Deus.",
            "Reconhecer o marcador de propósito.",
        ),
        q_choice(
            "caminhada",
            "Como Êxodo 13:18 se relaciona com 13:17?",
            "Êxodo 13:17–18",
            [
                ("a", "Em vez do caminho próximo, Deus leva pelo deserto"),
                ("b", "Deus desiste de guiar o povo"),
                ("c", "O povo volta ao Egito na hora"),
                ("d", "Os filisteus guiam Israel"),
            ],
            "a",
            "Mas Deus fez com que o povo rodeasse o caminho pelo deserto",
            "O \"Mas\" introduz a rota alternativa.",
            {
                "b": "Ele continua guiando.",
                "c": "Ainda não.",
                "d": "Deus guia, não os filisteus.",
            },
            "Leia o \"Mas\" de 13:18.",
            "Relacionar recusa e nova rota.",
            ev=["Êxodo 13:17", "Êxodo 13:18"],
        ),
        q_order(
            "caminhada",
            "Como avança a cena em Êxodo 13:17–22?",
            "Êxodo 13:17–18",
            [
                ("a", "Deus evita o caminho da guerra"),
                ("b", "Leva o povo pelo deserto"),
                ("c", "A coluna guia dia e noite"),
            ],
            ["a", "b", "c"],
            "não os conduziu pelo caminho",
            "Proteção, rota e presença contínua.",
            "A presença fecha a cena.",
            "Compreender o movimento.",
            evidence=["Êxodo 13:17", "Êxodo 13:21"],
        ),
        q_complete(
            "caminhada",
            "Em Êxodo 13:21, o que iluminava o povo à noite?",
            "Êxodo 13:21",
            [("a", "fogo"), ("b", "lua"), ("c", "tochas")],
            "a",
            "coluna de fogo, para iluminá-los",
            "À noite, coluna de fogo.",
            {"b": "O texto diz fogo.", "c": "Não são tochas humanas."},
            "Coluna de ___.",
            "Lembrar a luz noturna.",
        ),
        q_connect(
            "caminhada",
            "O que liga Êxodo 13:21 a Neemias 9:12?",
            "Êxodo 13:21",
            {"ref": "Êxodo 13:21"},
            {"ref": "Neemias 9:12"},
            [
                ("a", "Coluna guia o caminho"),
                ("b", "Construção do muro"),
                ("c", "Lista de inimigos"),
            ],
            "a",
            "para guiá-los pelo caminho",
            "Neemias lembra a mesma guia.",
            {"b": "Não é o tema deste elo.", "c": "Não."},
            "Como Deus guiava?",
            "Relacionar Êxodo e Neemias.",
            ev=["Êxodo 13:21", "Neemias 9:12"],
        ),
        q_tf(
            "profundezas",
            "Êxodo 13:17–22 ensina que o Senhor abandona o povo quando a rota fica longa.",
            "Êxodo 13:22",
            "false",
            "Nunca se afastou do povo",
            "A rota longa vem com presença constante.",
            "Releia: nunca se afastou do povo.",
            "Leia 13:22.",
            "Interpretar guia e presença.",
        ),
        q_touch(
            "profundezas",
            "Em Êxodo 13:22, toque o trecho que mostra a constância da presença.",
            "Êxodo 13:22",
            [("a", "Nunca se afastou"), ("b", "durante a noite"), ("c", "coluna de fogo")],
            "a",
            "Nunca se afastou do povo",
            "A frase-chave é: nunca se afastou.",
            {
                "b": "Indica o tempo; a constância é nunca se afastou.",
                "c": "Nomeia a forma; a constância é a frase.",
            },
            "Começo do versículo.",
            "Sustentar a presença contínua.",
        ),
        q_choice(
            "profundezas",
            "Que leitura Êxodo 13:17–22 sustenta sobre a guia de Deus?",
            "Êxodo 13:21–22",
            [
                ("a", "Deus protege, guia e não abandona no caminho"),
                ("b", "A coluna só aparece em dias de festa"),
                ("c", "O povo escolhe sozinho a rota"),
                ("d", "Deus prefere sempre o caminho curto"),
            ],
            "a",
            "Nunca se afastou do povo",
            "Evita a guerra, guia e permanece.",
            {
                "b": "É contínua dia e noite.",
                "c": "Deus conduz.",
                "d": "Ele evita o caminho próximo.",
            },
            "Una 13:17 e 13:22.",
            "Escolher a leitura sustentável.",
            ev=["Êxodo 13:17", "Êxodo 13:22"],
        ),
        q_order(
            "profundezas",
            "Qual sequência revela o fio da coluna?",
            "Êxodo 13:21",
            [
                ("a", "O Senhor guia com nuvem e fogo"),
                ("b", "O Salmo lembra a mesma guia"),
                ("c", "Paulo diz que os pais estiveram sob a nuvem"),
            ],
            ["a", "b", "c"],
            "coluna de nuvem",
            "Do Êxodo ao Salmo e a Paulo.",
            "Ordem da história bíblica.",
            "Ver a coluna na Escritura.",
            evidence=["Êxodo 13:21", "Salmos 78:14", "1 Coríntios 10:1"],
        ),
        q_complete(
            "profundezas",
            "Em Êxodo 13:21, em que o Senhor ia à frente de dia?",
            "Êxodo 13:21",
            [("a", "coluna"), ("b", "carro"), ("c", "barco")],
            "a",
            "em uma coluna de nuvem",
            "O termo da presença é coluna.",
            {"b": "Não é carro.", "c": "Não é barco."},
            "Forma da presença.",
            "Lembrar o termo teológico.",
        ),
        q_connect(
            "profundezas",
            "O que liga Êxodo 13:21 a 1 Coríntios 10:1?",
            "Êxodo 13:21",
            {"ref": "Êxodo 13:21"},
            {"ref": "1 Coríntios 10:1"},
            [
                ("a", "Sob a nuvem"),
                ("b", "Lista de reis"),
                ("c", "Construção do altar"),
            ],
            "a",
            "coluna de nuvem",
            "Paulo lembra os pais sob a nuvem.",
            {"b": "Não.", "c": "Não."},
            "Imagem comum.",
            "Ligar Êxodo e Paulo.",
            ev=["Êxodo 13:21", "1 Coríntios 10:1"],
        ),
    ],
}
dump("exc-12-coluna-de-nuvem-e", exc12)

# --------------- exc-13 vf=2 ---------------
exc13 = {
    "study": {
        "passageRef": "Êxodo 14:1–6",
        "passages": [{"ref": "Êxodo 14:1–12"}],
        "context": "O Senhor manda acampar junto ao mar. Faraó persegue; o povo teme e pergunta se não havia sepulcros no Egito.",
        "keyword": "Temeram",
        "keywordGloss": "O medo diante dos egípcios antes de ver a salvação no mar.",
        "focusQuestion": "Quando o medo pergunta se não havia sepulcros, o que a fé ainda precisa ouvir?",
        "reflectionPrompts": ["Presos entre o mar", "Perseguição de Faraó", "Clamor e queixa"],
        "facts": [
            {
                "text": "Deus manda Israel acampar junto ao mar.",
                "evidenceRef": "Êxodo 14:2",
                "evidenceSpan": "acampareis junto ao mar",
            },
            {
                "text": "Faraó pensará que o deserto os encerrou.",
                "evidenceRef": "Êxodo 14:3",
                "evidenceSpan": "o deserto os encerrou",
            },
            {
                "text": "O Senhor endureceu o coração de Faraó para perseguir.",
                "evidenceRef": "Êxodo 14:4",
                "evidenceSpan": "Endurecerei o coração de Faraó",
            },
            {
                "text": "Os egípcios alcançaram Israel junto ao mar.",
                "evidenceRef": "Êxodo 14:9",
                "evidenceSpan": "os alcançaram acampados junto ao mar",
            },
            {
                "text": "Israel temeu muito e clamou ao Senhor.",
                "evidenceRef": "Êxodo 14:10",
                "evidenceSpan": "temeram muito e os filhos de Israel clamaram ao Senhor",
            },
        ],
        "keyTerms": [
            {"term": "temeram", "gloss": "Reação de Israel ao ver o exército egípcio."},
            {
                "term": "deserto",
                "gloss": "Lugar que, na leitura de Faraó, encerrou o povo.",
            },
            {
                "term": "sepulcros",
                "gloss": "Palavra amarga da queixa: preferiam sepultura no Egito.",
            },
        ],
        "structure": [
            {"label": "Ordem de acampar junto ao mar", "evidenceRef": "Êxodo 14:1–2"},
            {"label": "Plano de Deus sobre Faraó", "evidenceRef": "Êxodo 14:3–4"},
            {"label": "Perseguição com carros", "evidenceRef": "Êxodo 14:5–9"},
            {"label": "Medo e queixa do povo", "evidenceRef": "Êxodo 14:10–12"},
        ],
        "relations": [
            {
                "kind": "propósito",
                "text": "Endurecer Faraó para Deus ser glorificado.",
                "marker": "para que",
                "evidenceRef": "Êxodo 14:4",
            },
            {
                "kind": "contraste",
                "text": "Faraó persegue; porém Israel saíra destemido.",
                "marker": "porém",
                "evidenceRef": "Êxodo 14:8",
            },
            {
                "kind": "resultado",
                "text": "Ao ver os egípcios, temeram e clamaram.",
                "marker": None,
                "evidenceRef": "Êxodo 14:10",
            },
        ],
        "crossRefs": [
            {"ref": "Êxodo 14:13", "bridge": "Não temais, vede a salvação"},
            {"ref": "Salmos 106:7", "bridge": "Rebeldes no mar"},
            {"ref": "Hebreus 11:29", "bridge": "Pela fé passaram o mar"},
        ],
        "misreadings": [
            {
                "text": "O povo já via a saída com fé plena.",
                "why": "Eles temeram e preferiam servir no Egito.",
            },
            {
                "text": "Faraó perseguiu contra a vontade de Deus.",
                "why": "O Senhor endureceu o coração para ser glorificado.",
            },
            {
                "text": "Israel estava perdido por acaso.",
                "why": "Deus mandou acampar ali de propósito.",
            },
        ],
        "centralInsight": "O medo pergunta se não havia sepulturas no Egito; a fé ainda não vê a saída.",
        "anchorQuestion": "O que o povo disse a Moisés quando viu os egípcios?",
    },
    "questions": [
        q_tf(
            "semente",
            "Os filhos de Israel temeram muito e clamaram ao Senhor ao verem os egípcios.",
            "Êxodo 14:10",
            "true",
            "temeram muito e os filhos de Israel clamaram ao Senhor",
            "Medo e clamor abrem a crise junto ao mar.",
            "Releia Êxodo 14:10.",
            "Reação ao aproximar-se Faraó.",
            "Observar o medo de Israel.",
        ),
        q_touch(
            "semente",
            "Em Êxodo 14:2, toque onde Israel deve acampar.",
            "Êxodo 14:2",
            [("a", "junto ao mar"), ("b", "Pi-Hairote"), ("c", "Migdol")],
            "a",
            "acampareis junto ao mar",
            "A ordem é acampar junto ao mar.",
            {
                "b": "Pi-Hairote é referência de lugar; o acampamento é junto ao mar.",
                "c": "Migdol é referência; o acampamento é junto ao mar.",
            },
            "Fim da ordem.",
            "Identificar o lugar do acampamento.",
        ),
        q_choice(
            "semente",
            "Segundo Êxodo 14:7, quantos carros escolhidos Faraó tomou?",
            "Êxodo 14:7",
            [
                ("a", "Seiscentos carros de guerra escolhidos"),
                ("b", "Dez carros apenas"),
                ("c", "Nenhum carro"),
                ("d", "Dois mil navios"),
            ],
            "a",
            "tomou seiscentos carros de guerra escolhidos",
            "Seiscentos escolhidos, além de todos os do Egito.",
            {"b": "São seiscentos.", "c": "Há muitos carros.", "d": "Não são navios."},
            "Número no versículo.",
            "Observar a força da perseguição.",
        ),
        q_order(
            "semente",
            "Monte Êxodo 14:10 na ordem do texto.",
            "Êxodo 14:10",
            [
                (
                    "a",
                    "E, ao se aproximar o faraó, os filhos de Israel levantaram os olhos",
                ),
                ("b", "e eis que os egípcios vinham atrás deles"),
                ("c", "temeram muito e os filhos de Israel clamaram ao Senhor"),
            ],
            ["a", "b", "c"],
            "temeram muito",
            "Ver, perceber e temer com clamor.",
            "O clamor vem por último.",
            "Reconhecer a sequência do medo.",
        ),
        q_complete(
            "semente",
            "Em Êxodo 14:11, o povo pergunta se não havia o quê no Egito?",
            "Êxodo 14:11",
            [("a", "sepulcros"), ("b", "palácios"), ("c", "jardins")],
            "a",
            "não havia sepulcros no Egito",
            "A queixa amarga fala de sepulcros no Egito.",
            {"b": "Não é palácios.", "c": "Não é jardins."},
            "Palavra da queixa.",
            "Lembrar a frase do medo.",
        ),
        q_connect(
            "semente",
            "O que Êxodo 14:10 comunica que se liga a este contexto?",
            "Êxodo 14:10",
            {"ref": "Êxodo 14:10"},
            {
                "ref": "Contexto",
                "text": "Israel está acampado entre o mar e o exército de Faraó.",
            },
            [
                ("a", "Medo gera clamor"),
                ("b", "Povo celebra vitória"),
                ("c", "Faraó já desistiu"),
            ],
            "a",
            "temeram muito e os filhos de Israel clamaram",
            "Presos, eles temem e clamam.",
            {"b": "Ainda não há vitória.", "c": "Ele está atrás deles."},
            "Reação ao ver os egípcios.",
            "Ligar cerco e medo.",
        ),
        q_tf(
            "caminhada",
            "Em Êxodo 14:4, o endurecimento de Faraó serve para que os egípcios saibam que o Senhor é Deus.",
            "Êxodo 14:4",
            "true",
            "os egípcios saberão que eu sou o Senhor",
            "O propósito é a glória do Senhor conhecida.",
            "Releia o fim de 14:4.",
            "O que os egípcios saberão?",
            "Compreender o propósito do endurecimento.",
        ),
        q_touch(
            "caminhada",
            "Em Êxodo 14:8, toque a palavra que marca o contraste com a perseguição.",
            "Êxodo 14:8",
            [("a", "porém"), ("b", "Faraó"), ("c", "Egito")],
            "a",
            "porém os filhos de Israel saíram de forma destemida",
            "\"Porém\" contrapõe perseguição e saída destemida.",
            {"b": "Faraó persegue.", "c": "Egito é a origem."},
            "Marcador antes de \"os filhos\".",
            "Reconhecer o contraste.",
        ),
        q_choice(
            "caminhada",
            "Como Êxodo 14:12 expressa o desejo do povo sob medo?",
            "Êxodo 14:12",
            [
                ("a", "Preferiam servir aos egípcios a morrer no deserto"),
                ("b", "Queriam atacar Faraó na hora"),
                ("c", "Pediam voltar para construir o templo"),
                ("d", "Celebravam a coluna de fogo"),
            ],
            "a",
            "melhor nos seria servir aos egípcios do que morrer no deserto",
            "O medo prefere a escravidão à morte aparente.",
            {"b": "Não pedem ataque.", "c": "Não.", "d": "Não celebram aqui."},
            "Compare servir e morrer.",
            "Relacionar medo e queixa.",
        ),
        q_order(
            "caminhada",
            "Como avança a cena em Êxodo 14:2–10?",
            "Êxodo 14:2–4",
            [
                ("a", "Deus manda acampar junto ao mar"),
                ("b", "Faraó persegue com carros"),
                ("c", "Israel teme e clama"),
            ],
            ["a", "b", "c"],
            "acampareis junto ao mar",
            "Ordem, perseguição e medo.",
            "O clamor fecha o movimento.",
            "Compreender o movimento.",
            evidence=["Êxodo 14:2", "Êxodo 14:10"],
        ),
        q_complete(
            "caminhada",
            "Em Êxodo 14:3, o que Faraó dirá que encerrou Israel?",
            "Êxodo 14:3",
            [("a", "deserto"), ("b", "templo"), ("c", "rio")],
            "a",
            "o deserto os encerrou",
            "Na leitura de Faraó, o deserto os encerrou.",
            {"b": "Não é templo.", "c": "Não é rio."},
            "Quem os encerrou segundo Faraó?",
            "Lembrar a leitura de Faraó.",
        ),
        q_connect(
            "caminhada",
            "O que liga Êxodo 14:10 a Êxodo 14:13?",
            "Êxodo 14:10",
            {"ref": "Êxodo 14:10"},
            {"ref": "Êxodo 14:13"},
            [
                ("a", "Do medo à salvação"),
                ("b", "Lista de pragas"),
                ("c", "Construção do altar"),
            ],
            "a",
            "temeram muito",
            "O clamor do medo encontra o \"não temais\".",
            {"b": "Não.", "c": "Não."},
            "Medo e resposta.",
            "Relacionar medo e promessa.",
            ev=["Êxodo 14:10", "Êxodo 14:13"],
        ),
        q_tf(
            "profundezas",
            "Êxodo 14:1–12 mostra um povo já confiante, sem medo nem queixa diante do mar.",
            "Êxodo 14:10",
            "false",
            "temeram muito e os filhos de Israel clamaram ao Senhor",
            "O texto registra medo e queixa, não confiança plena.",
            "Releia 14:10–12: temeram e preferiam o Egito.",
            "Como o povo reagiu?",
            "Corrigir leitura triunfalista.",
        ),
        q_touch(
            "profundezas",
            "Em Êxodo 14:11, toque o trecho que resume a queixa do povo.",
            "Êxodo 14:11",
            [("a", "sepulcros no Egito"), ("b", "Moisés"), ("c", "deserto")],
            "a",
            "não havia sepulcros no Egito",
            "A pergunta amarga fala de sepulcros no Egito.",
            {
                "b": "Moisés é o destinatário.",
                "c": "Deserto é o lugar; a queixa é sepulcros.",
            },
            "O que faltava no Egito segundo eles?",
            "Sustentar a queixa no texto.",
        ),
        q_choice(
            "profundezas",
            "Que leitura Êxodo 14:1–12 sustenta sobre o aperto junto ao mar?",
            "Êxodo 14:4",
            [
                ("a", "Deus ordena o acampamento e será glorificado na perseguição"),
                ("b", "Israel chegou ali por acidente"),
                ("c", "Faraó age fora de qualquer plano divino"),
                ("d", "O povo já via a vitória sem medo"),
            ],
            "a",
            "serei glorificado em Faraó",
            "Ordem divina, endurecimento e glória anunciada.",
            {
                "b": "Deus mandou acampar.",
                "c": "O Senhor endurece o coração.",
                "d": "Eles temeram.",
            },
            "Una 14:2 e 14:4.",
            "Escolher a leitura sustentável.",
            ev=["Êxodo 14:2", "Êxodo 14:4"],
        ),
        q_order(
            "profundezas",
            "Qual sequência revela o fio do medo à fé?",
            "Êxodo 14:10",
            [
                ("a", "Israel teme entre o mar e Faraó"),
                ("b", "O Salmo lembra a rebelião junto ao mar"),
                ("c", "Hebreus celebra a passagem pela fé"),
            ],
            ["a", "b", "c"],
            "temeram muito",
            "Do medo ao memorial e à fé.",
            "Ordem da história bíblica.",
            "Ver o fio do mar.",
            evidence=["Êxodo 14:10", "Salmos 106:7", "Hebreus 11:29"],
        ),
        q_complete(
            "profundezas",
            "Em Êxodo 14:10, o que Israel fez além de temer?",
            "Êxodo 14:10",
            [("a", "clamaram"), ("b", "fugiram"), ("c", "calaram")],
            "a",
            "clamaram ao Senhor",
            "Temeram e clamaram ao Senhor.",
            {"b": "O verbo é clamaram.", "c": "Eles clamaram."},
            "Verbo final do versículo.",
            "Lembrar a reação de fé inicial.",
        ),
        q_connect(
            "profundezas",
            "O que liga Êxodo 14:10 a Hebreus 11:29?",
            "Êxodo 14:10",
            {"ref": "Êxodo 14:10"},
            {"ref": "Hebreus 11:29"},
            [
                ("a", "Do medo à fé no mar"),
                ("b", "Lista de reis"),
                ("c", "Construção do templo"),
            ],
            "a",
            "temeram muito",
            "Hebreus olha o outro lado: passaram pela fé.",
            {"b": "Não.", "c": "Não."},
            "Medo aqui, fé ali.",
            "Ligar crise e testemunho.",
            ev=["Êxodo 14:10", "Hebreus 11:29"],
        ),
    ],
}
dump("exc-13-presos-entre-o-mar", exc13)

print("lessons 12-13 written")
