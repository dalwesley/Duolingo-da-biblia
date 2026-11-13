#!/usr/bin/env python3
# Temporary generator for missing respostas — delete after use.
import json, re, os
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
# file is admin/v3/exodo-cap/manual/_gen_missing.py → root is admin/
ADMIN = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
OUT = os.path.join(os.path.dirname(__file__), "respostas")
PKT = os.path.join(os.path.dirname(__file__), "_packets")

def load_pkt(slug):
    return json.load(open(os.path.join(PKT, f"{slug}.json")))

def vmap(pkt):
    return {v["ref"]: v["text"] for v in pkt["verses"]}

def text_for(vmap_, ref):
    m = re.match(r"^(Êxodo) (\d+):(\d+)(?:–(\d+))?$", ref)
    if not m:
        return ""
    ch, a = int(m.group(2)), int(m.group(3))
    b = int(m.group(4)) if m.group(4) else a
    return " ".join(vmap_.get(f"Êxodo {ch}:{n}", "") for n in range(a, b + 1))

def o(*pairs):
    return [{"id": a, "text": b} for a, b in pairs]

def check(slug, obj):
    pkt = load_pkt(slug)
    vm = vmap(pkt)
    errs = []
    qs = obj["questions"]
    exp = 24 if pkt["boss"] else 18
    if len(qs) != exp:
        errs.append(f"count {len(qs)}!={exp}")
    taps, comps, orders = [], [], {}
    vf = 0
    for q in qs:
        if q["type"] == "true_false" and q["correctOptionId"] == "true":
            vf += 1
        pt = text_for(vm, q["verseRef"])
        if q["type"] == "find_in_text":
            for opt in q["options"]:
                if opt["text"] not in pt:
                    errs.append(f"touch '{opt['text']}' ∉ {q['verseRef']}")
            taps.append(next(x["text"] for x in q["options"] if x["id"] == q["correctOptionId"]).lower())
        if q["type"] == "complete":
            t = next(x["text"] for x in q["options"] if x["id"] == q["correctOptionId"])
            comps.append(t.lower())
            if t not in pt:
                errs.append(f"complete '{t}' ∉ {q['verseRef']}")
        if q["type"] == "order":
            if q["difficulty"] == "semente":
                for opt in q["options"]:
                    if opt["text"] not in pt:
                        errs.append(f"seed-order ∉ {q['verseRef']}: {opt['text'][:50]}")
            for opt in q["options"]:
                k = opt["text"].lower()
                if k in orders and orders[k] != q["difficulty"]:
                    errs.append(f"order-cross: {opt['text'][:40]}")
                orders[k] = q["difficulty"]
        if q["type"] == "connect" and q["difficulty"] == "semente":
            if q["passageB"].get("ref") != "Contexto":
                errs.append("seed connect Contexto")
        for opt in q.get("options") or []:
            if q["type"] == "connect" and len(opt["text"].split()) > 6:
                errs.append(f"connect>6: {opt['text']}")
            if q["type"] == "choice" and len(opt["text"]) > 85:
                errs.append(f"choice>85: {opt['text'][:40]}")
            if q["type"] == "order" and len(opt["text"]) > 72:
                errs.append(f"order>72: {opt['text'][:40]}")
        if len(q.get("hint", "")) > 90:
            errs.append("hint>90")
        if len(q.get("feedbackCorrect", "")) > 110:
            errs.append("fc>110")
        for v in (q.get("feedbackWrong") or {}).values():
            if len(v) > 120:
                errs.append("fw>120")
        # evidenceSpan in stage
        if q.get("evidenceSpan") and q["evidenceSpan"] not in pt and q["type"] != "order":
            # order cam/pro may paraphrase; still prefer span in stage for sem
            if q["difficulty"] == "semente" or q["type"] in ("true_false", "find_in_text", "complete", "choice", "connect"):
                if q["evidenceSpan"] not in pt:
                    errs.append(f"span ∉ {q['verseRef']}: {q['evidenceSpan'][:50]}")
    both = taps + comps
    if len(both) != len(set(both)):
        errs.append(f"tap/comp dup {both}")
    if vf != pkt["vfTrue"]:
        errs.append(f"vf {vf}!={pkt['vfTrue']}")
    return errs

def save(slug, obj):
    errs = check(slug, obj)
    path = os.path.join(OUT, f"{slug}.json")
    with open(path, "w") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(("OK" if not errs else "WARN"), slug, f"q={len(obj['questions'])}")
    for e in errs:
        print(" ", e)
    return errs

def L(study, qs):
    return {"study": study, "questions": qs}

def q(**kw):
    return kw

# =============================================================================
# LESSONS
# =============================================================================

errs_all = []

errs_all += save("exc-17-jetro-aconselha", L({
    "passageRef": "Êxodo 18:13–18",
    "passages": [{"ref": "Êxodo 18:13–23"}],
    "context": "Moisés julga o povo sozinho o dia inteiro. Jetro, seu sogro, vê o peso e aconselha partilhar a carga.",
    "keyword": "Aconselhar",
    "keywordGloss": "Jetro oferece conselho sábio para Moisés não carregar tudo sozinho.",
    "focusQuestion": "Que carga você ainda insiste em carregar sozinho?",
    "reflectionPrompts": ["Julgar sozinho", "Tarefa pesada", "Homens capazes"],
    "facts": [
        {"text": "Moisés se assentou para julgar o povo o dia inteiro.", "evidenceRef": "Êxodo 18:13", "evidenceSpan": "Moisés se assentou para julgar o povo"},
        {"text": "Jetro perguntou por que Moisés se assentava sozinho.", "evidenceRef": "Êxodo 18:14", "evidenceSpan": "Por que você se assenta sozinho"},
        {"text": "Jetro disse que não era bom o que Moisés fazia.", "evidenceRef": "Êxodo 18:17", "evidenceSpan": "Não é bom o que você faz"},
        {"text": "A tarefa era demasiadamente pesada para um só.", "evidenceRef": "Êxodo 18:18", "evidenceSpan": "essa tarefa é demasiadamente pesada para você"},
        {"text": "Jetro mandou procurar homens capazes, tementes a Deus.", "evidenceRef": "Êxodo 18:21", "evidenceSpan": "homens capazes, tementes a Deus"},
    ],
    "keyTerms": [
        {"term": "aconselharei", "gloss": "Jetro oferece orientação para aliviar a carga."},
        {"term": "pesada", "gloss": "A tarefa de julgar sozinho ultrapassa um homem."},
        {"term": "juízes", "gloss": "Homens que julgam as causas simples com Moisés."},
    ],
    "structure": [
        {"label": "Moisés julga o povo sozinho", "evidenceRef": "Êxodo 18:13–16"},
        {"label": "Jetro diz que não é bom", "evidenceRef": "Êxodo 18:17–18"},
        {"label": "Conselho: ensinar e escolher líderes", "evidenceRef": "Êxodo 18:19–21"},
        {"label": "Juízes aliviam a carga em paz", "evidenceRef": "Êxodo 18:22–23"},
    ],
    "relations": [
        {"kind": "contraste", "text": "Jetro contrasta o costume: porém, não é bom.", "marker": "porém", "evidenceRef": "Êxodo 18:17"},
        {"kind": "causa", "text": "A tarefa é pesada; por isso não consegue sozinho.", "marker": "pois", "evidenceRef": "Êxodo 18:18"},
        {"kind": "resultado", "text": "Se fizer isso, poderá suportar e o povo volta em paz.", "marker": "então", "evidenceRef": "Êxodo 18:23"},
    ],
    "crossRefs": [
        {"ref": "Atos 6:3", "bridge": "Escolher homens capazes"},
        {"ref": "Deuteronômio 1:16–17", "bridge": "Juízes com justiça"},
        {"ref": "Números 11:17", "bridge": "Espírito sobre setenta"},
    ],
    "misreadings": [
        {"text": "Jetro manda Moisés abandonar o povo.", "why": "O conselho é partilhar a carga, não abandonar."},
        {"text": "Qualquer homem serve como juiz, sem caráter.", "why": "O texto pede capazes, tementes a Deus, que aborreçam a avareza."},
        {"text": "Moisés já estava bem sozinho.", "why": "Jetro diz: não é bom; a tarefa é demasiadamente pesada."},
    ],
    "centralInsight": "O peso não é para um só: Deus usa conselho sábio para cuidar do povo.",
    "anchorQuestion": "Por que Jetro disse que não era bom Moisés julgar sozinho?",
}, [
    q(difficulty="semente", type="true_false", question="Moisés se assentou para julgar o povo desde a manhã até ao pôr do sol.", verseRef="Êxodo 18:13", correctOptionId="true", evidenceSpan="desde a manhã até ao pôr do sol", feedbackCorrect="O texto marca o dia inteiro: manhã até o pôr do sol.", feedbackWrong={"false": "Releia: o povo ficou em pé desde a manhã até ao pôr do sol."}, hint="Veja até quando o povo ficou em pé.", learningObjective="Observar o ritmo exaustivo do julgamento.", evidence=["Êxodo 18:13"]),
    q(difficulty="semente", type="find_in_text", question="Em Êxodo 18:17, toque a palavra que resume o juízo de Jetro.", verseRef="Êxodo 18:17", options=o(("a", "bom"), ("b", "povo"), ("c", "sogro")), correctOptionId="a", evidenceSpan="Não é bom o que você faz", feedbackCorrect="Jetro resume: não é bom o que você faz.", feedbackWrong={"b": "\"povo\" é o cuidado; o juízo é \"bom\".", "c": "\"sogro\" quem fala; a palavra é \"bom\"."}, hint="Veja o adjetivo da frase de Jetro.", learningObjective="Identificar o veredito de Jetro.", evidence=["Êxodo 18:17"]),
    q(difficulty="semente", type="choice", question="Segundo Êxodo 18:18, por que Moisés não conseguiria sozinho?", verseRef="Êxodo 18:18", options=o(("a", "A tarefa era demasiadamente pesada"), ("b", "O povo não queria ouvir"), ("c", "Deus proibiu juízes"), ("d", "Jetro queria o trono")), correctOptionId="a", evidenceSpan="essa tarefa é demasiadamente pesada para você", feedbackCorrect="A tarefa é demasiadamente pesada para um só.", feedbackWrong={"b": "O texto fala do peso, não da recusa.", "c": "Jetro propõe juízes.", "d": "Jetro aconselha; não busca o trono."}, hint="Leia o motivo da fadiga.", learningObjective="Observar o peso da tarefa.", evidence=["Êxodo 18:18"]),
    q(difficulty="semente", type="order", question="Monte Êxodo 18:17 na ordem do texto.", verseRef="Êxodo 18:17", options=o(("a", "O sogro de Moisés, porém, lhe disse"), ("b", "Não é bom"), ("c", "o que você faz")), correctOrder=["a", "b", "c"], evidenceSpan="Não é bom o que você faz", feedbackCorrect="Primeiro quem fala; depois o juízo e a ação.", feedbackWrong={"default": "Comece pelo sogro; o juízo vem depois."}, hint="O versículo começa pelo sogro.", learningObjective="Reconhecer a ordem de 18:17.", evidence=["Êxodo 18:17"]),
    q(difficulty="semente", type="complete", question="Em Êxodo 18:18, como Jetro descreve a tarefa?", verseRef="Êxodo 18:18", options=o(("a", "pesada"), ("b", "leve"), ("c", "inútil")), correctOptionId="a", evidenceSpan="demasiadamente pesada para você", feedbackCorrect="A tarefa é demasiadamente pesada.", feedbackWrong={"b": "O texto diz pesada, não leve.", "c": "Não chama a tarefa de inútil."}, hint="Veja o adjetivo da tarefa.", learningObjective="Lembrar o peso da tarefa.", evidence=["Êxodo 18:18"]),
    q(difficulty="semente", type="connect", question="O que Êxodo 18:17 comunica que se liga a este contexto?", verseRef="Êxodo 18:17", passageA={"ref": "Êxodo 18:17"}, passageB={"ref": "Contexto", "text": "Moisés julga sozinho o dia inteiro e Jetro intervém."}, options=o(("a", "Sozinho não é bom"), ("b", "Abandone o povo"), ("c", "Ignore o sogro")), correctOptionId="a", evidenceSpan="Não é bom o que você faz", feedbackCorrect="O conselho parte do diagnóstico: sozinho não é bom.", feedbackWrong={"b": "Jetro quer partilha, não abandono.", "c": "O texto valoriza o conselho do sogro."}, hint="Compare o diagnóstico com a cena.", learningObjective="Ligar o veredito ao contexto.", evidence=["Êxodo 18:17"]),
    q(difficulty="caminhada", type="true_false", question="Em Êxodo 18:18, Jetro diz que Moisés conseguiria realizar a tarefa sozinho com facilidade.", verseRef="Êxodo 18:18", correctOptionId="false", evidenceSpan="você não conseguirá realizá-la sozinho", feedbackCorrect="O texto diz o contrário: não conseguirá sozinho.", feedbackWrong={"true": "Releia: você não conseguirá realizá-la sozinho."}, hint="Veja a conclusão de Jetro.", learningObjective="Compreender o limite de Moisés.", evidence=["Êxodo 18:18"]),
    q(difficulty="caminhada", type="find_in_text", question="Em Êxodo 18:17, toque a palavra que marca o contraste com o costume de Moisés.", verseRef="Êxodo 18:17", options=o(("a", "porém"), ("b", "Moisés"), ("c", "disse")), correctOptionId="a", evidenceSpan="O sogro de Moisés, porém, lhe disse", feedbackCorrect="\"Porém\" introduz a correção de Jetro.", feedbackWrong={"b": "Moisés é o ouvinte; o marcador é porém.", "c": "\"disse\" é o verbo; o contraste é porém."}, hint="Procure a palavra após \"Moisés\".", learningObjective="Reconhecer o marcador de contraste.", evidence=["Êxodo 18:17"]),
    q(difficulty="caminhada", type="choice", question="Como Êxodo 18:21–22 liga o caráter dos líderes ao alívio de Moisés?", verseRef="Êxodo 18:21–22", options=o(("a", "Homens capazes julgam o simples e aliviam a carga"), ("b", "Só ricos devem julgar as causas"), ("c", "Moisés deve parar de ensinar as leis"), ("d", "O povo não precisa de juízes")), correctOptionId="a", evidenceSpan="você possa aliviar sua carga", feedbackCorrect="Líderes capazes julgam o simples e aliviam Moisés.", feedbackWrong={"b": "O critério é caráter, não riqueza.", "c": "Jetro manda ensinar estatutos e leis.", "d": "O conselho é escolher juízes."}, hint="Una a escolha dos homens e o alívio.", learningObjective="Relacionar líderes e alívio.", evidence=["Êxodo 18:21", "Êxodo 18:22"]),
    q(difficulty="caminhada", type="order", question="Como avança o conselho de Jetro em Êxodo 18:13–23?", verseRef="Êxodo 18:17–18", options=o(("a", "Moisés julga o povo sozinho"), ("b", "Jetro diz que a tarefa é pesada"), ("c", "Juízes capazes aliviam a carga")), correctOrder=["a", "b", "c"], evidenceSpan="demasiadamente pesada para você", feedbackCorrect="Do esgotamento ao diagnóstico e à partilha.", feedbackWrong={"default": "Comece pelo julgamento solo; os juízes fecham."}, hint="Siga problema, diagnóstico e solução.", learningObjective="Compreender o movimento da cena.", evidence=["Êxodo 18:13", "Êxodo 18:18", "Êxodo 18:22"]),
    q(difficulty="caminhada", type="complete", question="Em Êxodo 18:22, o que os juízes ajudam Moisés a fazer com a carga?", verseRef="Êxodo 18:22", options=o(("a", "aliviar"), ("b", "aumentar"), ("c", "esconder")), correctOptionId="a", evidenceSpan="você possa aliviar sua carga", feedbackCorrect="Os juízes existem para aliviar a carga.", feedbackWrong={"b": "O alvo é aliviar, não aumentar.", "c": "O texto fala em aliviar."}, hint="Veja o verbo do propósito.", learningObjective="Lembrar o verbo do alívio.", evidence=["Êxodo 18:22"]),
    q(difficulty="caminhada", type="connect", question="O que liga Êxodo 18:21 a Atos 6:3?", verseRef="Êxodo 18:21", passageA={"ref": "Êxodo 18:21"}, passageB={"ref": "Atos 6:3"}, options=o(("a", "Escolher homens capazes"), ("b", "Rejeitar todo serviço"), ("c", "Centralizar tudo num só")), correctOptionId="a", evidenceSpan="homens capazes, tementes a Deus", feedbackCorrect="Nos dois textos, escolhem-se homens capazes para servir.", feedbackWrong={"b": "O elo é escolha para o serviço.", "c": "O ponto é partilhar, não centralizar."}, hint="Compare o critério dos escolhidos.", learningObjective="Relacionar Jetro e Atos.", evidence=["Êxodo 18:21", "Atos 6:3"]),
    q(difficulty="profundezas", type="true_false", question="Êxodo 18:17–23 sustenta que Moisés deve rejeitar qualquer conselho e julgar tudo sozinho.", verseRef="Êxodo 18:17–18", correctOptionId="false", evidenceSpan="Não é bom o que você faz", feedbackCorrect="O texto sustenta ouvir conselho e partilhar a carga.", feedbackWrong={"true": "Jetro corrige o solo: não é bom; a tarefa é pesada."}, hint="O texto apoia partilha ou isolamento?", learningObjective="Interpretar liderança que ouve conselho.", evidence=["Êxodo 18:17", "Êxodo 18:18"]),
    q(difficulty="profundezas", type="find_in_text", question="Em Êxodo 18:21, toque o trecho que sustenta o temor a Deus nos líderes.", verseRef="Êxodo 18:21", options=o(("a", "tementes"), ("b", "mil"), ("c", "avareza")), correctOptionId="a", evidenceSpan="tementes a Deus", feedbackCorrect="Os líderes devem ser tementes a Deus.", feedbackWrong={"b": "\"mil\" é escala; o caráter é tementes.", "c": "Aborrecer avareza acompanha; o trecho é tementes."}, hint="Procure quem eles devem temer.", learningObjective="Sustentar o critério do temor.", evidence=["Êxodo 18:21"]),
    q(difficulty="profundezas", type="choice", question="Que leitura Êxodo 18:17–23 sustenta sobre liderança?", verseRef="Êxodo 18:22", options=o(("a", "Ouvir conselho e partilhar a carga cuida do povo"), ("b", "Líder fiel nunca divide tarefas"), ("c", "Caráter não importa nos juízes"), ("d", "Jetro manda Moisés fugir")), correctOptionId="a", evidenceSpan="eles a suportarão com você", feedbackCorrect="Partilhar com homens capazes cuida de Moisés e do povo.", feedbackWrong={"b": "O texto corrige o isolamento.", "c": "Jetro exige caráter claro.", "d": "O conselho é permanecer com ajuda."}, hint="Una diagnóstico e solução.", learningObjective="Escolher a interpretação sustentável.", evidence=["Êxodo 18:18", "Êxodo 18:22"]),
    q(difficulty="profundezas", type="order", question="Qual sequência liga o conselho de Jetro à Escritura?", verseRef="Êxodo 18:21", options=o(("a", "Jetro pede homens capazes"), ("b", "Moisés depois nomeia juízes justos"), ("c", "A igreja escolhe sete para servir")), correctOrder=["a", "b", "c"], evidenceSpan="homens capazes, tementes a Deus", feedbackCorrect="Do conselho no deserto a Deuteronômio e Atos.", feedbackWrong={"default": "Comece por Jetro; depois juízes e Atos."}, hint="Siga a ordem da história bíblica.", learningObjective="Ver a partilha ecoar na Escritura.", evidence=["Êxodo 18:21", "Deuteronômio 1:16–17", "Atos 6:3"]),
    q(difficulty="profundezas", type="complete", question="Em Êxodo 18:19, que verbo nomeia o que Jetro fará por Moisés?", verseRef="Êxodo 18:19", options=o(("a", "aconselharei"), ("b", "abandonarei"), ("c", "condenarei")), correctOptionId="a", evidenceSpan="eu te aconselharei", feedbackCorrect="Jetro diz: eu te aconselharei.", feedbackWrong={"b": "Ele aconselha, não abandona.", "c": "O verbo é aconselhar."}, hint="Veja o que Jetro promete fazer.", learningObjective="Lembrar o termo do conselho.", evidence=["Êxodo 18:19"]),
    q(difficulty="profundezas", type="connect", question="O que liga Êxodo 18:21 a Deuteronômio 1:16–17?", verseRef="Êxodo 18:21", passageA={"ref": "Êxodo 18:21"}, passageB={"ref": "Deuteronômio 1:16–17"}, options=o(("a", "Juízes com justiça"), ("b", "Fuga do monte"), ("c", "Bezerro de ouro")), correctOptionId="a", evidenceSpan="coloca-os como líderes sobre o povo", feedbackCorrect="Os dois textos pedem juízes justos sobre o povo.", feedbackWrong={"b": "O elo é julgamento justo.", "c": "O bezerro não está neste elo."}, hint="Compare a função dos juízes.", learningObjective="Ligar Jetro a Deuteronômio.", evidence=["Êxodo 18:21", "Deuteronômio 1:16–17"]),
]))

# fix 17 profundezas choice verseRef
# (patched below after other saves by rewriting that question's verseRef in JSON if needed)

# ---------------- 18 Preparai vf=2 ----------------
errs_all += save("exc-18-preparai-o-povo", L({
    "passageRef": "Êxodo 19:10–15",
    "passages": [{"ref": "Êxodo 19:10–19"}],
    "context": "Antes de o Senhor descer no Sinai, Moisés deve preparar o povo: lavar vestes, limites e temor.",
    "keyword": "Preparai",
    "keywordGloss": "O encontro com o Senhor pede povo pronto, limpo e respeitoso dos limites.",
    "focusQuestion": "O que você precisa preparar antes de se aproximar do Senhor?",
    "reflectionPrompts": ["Lavar as vestes", "Limites no monte", "Sinai em fogo"],
    "facts": [
        {"text": "O Senhor mandou purificar o povo e lavar as vestes.", "evidenceRef": "Êxodo 19:10", "evidenceSpan": "purifique-os hoje e amanhã, e que lavem as suas vestes"},
        {"text": "No terceiro dia o Senhor desceria sobre o monte Sinai.", "evidenceRef": "Êxodo 19:11", "evidenceSpan": "no terceiro dia o Senhor, à vista de todo o povo, descerá sobre o monte Sinai"},
        {"text": "Quem tocasse o monte certamente morreria.", "evidenceRef": "Êxodo 19:12", "evidenceSpan": "todo aquele que tocar o monte certamente morrerá"},
        {"text": "O monte Sinai fumegava porque o Senhor descera em fogo.", "evidenceRef": "Êxodo 19:18", "evidenceSpan": "o Senhor tinha descido sobre ele em fogo"},
        {"text": "Moisés falava e Deus respondia com trovão.", "evidenceRef": "Êxodo 19:19", "evidenceSpan": "Moisés falava, e Deus lhe respondia com trovão"},
    ],
    "keyTerms": [
        {"term": "purifique-os", "gloss": "Preparar o povo para o encontro com o Senhor."},
        {"term": "limites", "gloss": "Marca ao redor do monte: ninguém toca sem morrer."},
        {"term": "fogo", "gloss": "Sinal da descida do Senhor sobre o Sinai."},
    ],
    "structure": [
        {"label": "Ordem de purificar e lavar", "evidenceRef": "Êxodo 19:10–11"},
        {"label": "Limites em torno do monte", "evidenceRef": "Êxodo 19:12–13"},
        {"label": "Moisés consagra o povo", "evidenceRef": "Êxodo 19:14–15"},
        {"label": "Sinai treme em fogo e trombeta", "evidenceRef": "Êxodo 19:16–19"},
    ],
    "relations": [
        {"kind": "causa", "text": "Estejam prontos porque no terceiro dia o Senhor descerá.", "marker": "pois", "evidenceRef": "Êxodo 19:11"},
        {"kind": "resultado", "text": "Quem tocar o monte certamente morrerá.", "marker": "certamente", "evidenceRef": "Êxodo 19:12"},
        {"kind": "sequência", "text": "No terceiro dia vêm trovões, nuvem e trombeta; o povo treme.", "marker": None, "evidenceRef": "Êxodo 19:16"},
    ],
    "crossRefs": [
        {"ref": "Hebreus 12:18–19", "bridge": "Monte e trombeta"},
        {"ref": "Hebreus 12:21", "bridge": "Temor no Sinai"},
        {"ref": "Salmos 68:8", "bridge": "Terra tremeu"},
    ],
    "misreadings": [
        {"text": "Qualquer um podia subir o monte à vontade.", "why": "Há limites; quem tocar o monte morrerá."},
        {"text": "O Senhor desceu sem o povo se preparar.", "why": "Antes manda purificar, lavar e estar prontos."},
        {"text": "O Sinai ficou quieto e silencioso.", "why": "Trovões, fogo, fumaça e trombeta marcam a cena."},
    ],
    "centralInsight": "Encontrar o Senhor pede preparo: o Sinai treme quando ele desce no fogo.",
    "anchorQuestion": "O que o Senhor pediu ao povo antes de descer no Sinai?",
}, [
    q(difficulty="semente", type="true_false", question="O Senhor mandou purificar o povo e que lavassem as suas vestes.", verseRef="Êxodo 19:10", correctOptionId="true", evidenceSpan="purifique-os hoje e amanhã, e que lavem as suas vestes", feedbackCorrect="A ordem une purificação e lavar as vestes.", feedbackWrong={"false": "Releia: purifique-os e que lavem as suas vestes."}, hint="Veja o que fazer hoje e amanhã.", learningObjective="Observar a ordem de preparo.", evidence=["Êxodo 19:10"]),
    q(difficulty="semente", type="find_in_text", question="Em Êxodo 19:11, toque o monte onde o Senhor desceria.", verseRef="Êxodo 19:11", options=o(("a", "Sinai"), ("b", "povo"), ("c", "Senhor")), correctOptionId="a", evidenceSpan="descerá sobre o monte Sinai", feedbackCorrect="O Senhor desceria sobre o monte Sinai.", feedbackWrong={"b": "O povo vê; o monte nomeado é Sinai.", "c": "Senhor é quem desce; o monte é Sinai."}, hint="Leia o nome do monte.", learningObjective="Identificar o Sinai.", evidence=["Êxodo 19:11"]),
    q(difficulty="semente", type="choice", question="Segundo Êxodo 19:12, o que aconteceria a quem tocasse o monte?", verseRef="Êxodo 19:12", options=o(("a", "Certamente morreria"), ("b", "Receberia ouro"), ("c", "Virou sacerdote"), ("d", "Ficaria mudo um dia")), correctOptionId="a", evidenceSpan="todo aquele que tocar o monte certamente morrerá", feedbackCorrect="Tocar o monte traz morte certa.", feedbackWrong={"b": "Não há recompensa; há morte.", "c": "O texto não fala de sacerdócio aqui.", "d": "A pena é morrer."}, hint="Leia a consequência de tocar.", learningObjective="Observar o limite sagrado.", evidence=["Êxodo 19:12"]),
    q(difficulty="semente", type="order", question="Monte Êxodo 19:10 na ordem do texto.", verseRef="Êxodo 19:10", options=o(("a", "Disse também o Senhor a Moisés"), ("b", "Vá ao povo e purifique-os hoje e amanhã"), ("c", "e que lavem as suas vestes")), correctOrder=["a", "b", "c"], evidenceSpan="purifique-os hoje e amanhã", feedbackCorrect="Ordem do Senhor, purificar, lavar vestes.", feedbackWrong={"default": "Comece pela fala do Senhor."}, hint="O versículo começa com Disse.", learningObjective="Reconhecer a ordem de 19:10.", evidence=["Êxodo 19:10"]),
    q(difficulty="semente", type="complete", question="Em Êxodo 19:18, sobre o quê o Senhor tinha descido no monte?", verseRef="Êxodo 19:18", options=o(("a", "fogo"), ("b", "água"), ("c", "areia")), correctOptionId="a", evidenceSpan="descido sobre ele em fogo", feedbackCorrect="O Senhor descera sobre o monte em fogo.", feedbackWrong={"b": "O sinal é fogo, não água.", "c": "O texto diz fogo."}, hint="Veja em que Ele descera.", learningObjective="Lembrar o fogo no Sinai.", evidence=["Êxodo 19:18"]),
    q(difficulty="semente", type="connect", question="O que Êxodo 19:10 comunica que se liga a este contexto?", verseRef="Êxodo 19:10", passageA={"ref": "Êxodo 19:10"}, passageB={"ref": "Contexto", "text": "Antes da descida no Sinai, o povo precisa se preparar."}, options=o(("a", "Preparo antes do encontro"), ("b", "Fuga imediata do monte"), ("c", "Culto a ídolos")), correctOptionId="a", evidenceSpan="purifique-os hoje e amanhã", feedbackCorrect="Purificar e lavar é o preparo para o encontro.", feedbackWrong={"b": "O texto prepara, não manda fugir.", "c": "Não há culto a ídolos aqui."}, hint="Compare a ordem com o momento.", learningObjective="Ligar preparo e encontro.", evidence=["Êxodo 19:10"]),
    q(difficulty="caminhada", type="true_false", question="Em Êxodo 19:11, o Senhor desceria no terceiro dia à vista de todo o povo.", verseRef="Êxodo 19:11", correctOptionId="true", evidenceSpan="no terceiro dia o Senhor, à vista de todo o povo, descerá", feedbackCorrect="O prazo e a visibilidade estão no texto.", feedbackWrong={"false": "Releia: no terceiro dia, à vista de todo o povo."}, hint="Veja o dia e a quem seria visível.", learningObjective="Compreender o prazo da descida.", evidence=["Êxodo 19:11"]),
    q(difficulty="caminhada", type="find_in_text", question="Em Êxodo 19:11, toque a palavra que marca o motivo de estarem prontos.", verseRef="Êxodo 19:11", options=o(("a", "pois"), ("b", "monte"), ("c", "vista")), correctOptionId="a", evidenceSpan="prontos para o terceiro dia, pois no terceiro dia", feedbackCorrect="\"Pois\" liga o preparo à descida do Senhor.", feedbackWrong={"b": "\"monte\" é o lugar; o marcador de causa é pois.", "c": "\"vista\" marca a visibilidade; a causa é pois."}, hint="Procure a palavra que explica o preparo.", learningObjective="Reconhecer o marcador de causa.", evidence=["Êxodo 19:11"]),
    q(difficulty="caminhada", type="choice", question="Como Êxodo 19:12–13 liga o limite ao temor do monte?", verseRef="Êxodo 19:12", options=o(("a", "Tocar o monte traz morte; o limite protege"), ("b", "O limite convida a subir sem medo"), ("c", "Só animais podem tocar o monte"), ("d", "O limite era só decoração")), correctOptionId="a", evidenceSpan="todo aquele que tocar o monte certamente morrerá", feedbackCorrect="O limite existe porque tocar o monte mata.", feedbackWrong={"b": "O texto proíbe subir e tocar.", "c": "Animal ou homem: não viverá.", "d": "A pena mostra seriedade."}, hint="Una limite e consequência.", learningObjective="Relacionar limite e temor.", evidence=["Êxodo 19:12"]),
    q(difficulty="caminhada", type="order", question="Como avança a cena do Sinai em Êxodo 19:10–19?", verseRef="Êxodo 19:10–11", options=o(("a", "Ordem de purificar o povo"), ("b", "Limites em torno do monte"), ("c", "O Sinai treme em fogo")), correctOrder=["a", "b", "c"], evidenceSpan="purifique-os hoje e amanhã", feedbackCorrect="Preparo, limites e teofania em fogo.", feedbackWrong={"default": "Comece pela purificação; o fogo fecha."}, hint="Siga preparo, limite e descida.", learningObjective="Compreender o movimento da cena.", evidence=["Êxodo 19:10", "Êxodo 19:12", "Êxodo 19:18"]),
    q(difficulty="caminhada", type="complete", question="Em Êxodo 19:12, que palavra resume a certeza da pena?", verseRef="Êxodo 19:12", options=o(("a", "certamente"), ("b", "talvez"), ("c", "nunca")), correctOptionId="a", evidenceSpan="certamente morrerá", feedbackCorrect="A pena é certa: certamente morrerá.", feedbackWrong={"b": "Não há talvez; há certeza.", "c": "O texto usa certamente."}, hint="Veja o advérbio antes de morrerá.", learningObjective="Lembrar o marcador de certeza.", evidence=["Êxodo 19:12"]),
    q(difficulty="caminhada", type="connect", question="O que liga Êxodo 19:16 a Hebreus 12:18–19?", verseRef="Êxodo 19:16", passageA={"ref": "Êxodo 19:16"}, passageB={"ref": "Hebreus 12:18–19"}, options=o(("a", "Trombeta e temor"), ("b", "Maná no deserto"), ("c", "Sangue na porta")), correctOptionId="a", evidenceSpan="forte som de trombeta", feedbackCorrect="Hebreus retoma o Sinai: fogo, trombeta e temor.", feedbackWrong={"b": "O elo é a teofania, não o maná.", "c": "A páscoa não é o tema aqui."}, hint="Compare trombeta e voz no monte.", learningObjective="Relacionar Sinai e Hebreus.", evidence=["Êxodo 19:16", "Hebreus 12:18–19"]),
    q(difficulty="profundezas", type="true_false", question="Êxodo 19:10–19 sustenta que encontrar o Senhor pede preparo e respeito aos limites.", verseRef="Êxodo 19:10–11", correctOptionId="true", evidenceSpan="estejam prontos para o terceiro dia", feedbackCorrect="Preparo e limites cercam a descida do Senhor.", feedbackWrong={"false": "O texto une purificação, limites e temor."}, hint="Una preparo e limite.", learningObjective="Interpretar o encontro santo.", evidence=["Êxodo 19:10", "Êxodo 19:12"]),
    q(difficulty="profundezas", type="find_in_text", question="Em Êxodo 19:18, toque o trecho que sustenta a presença do Senhor no monte.", verseRef="Êxodo 19:18", options=o(("a", "descido"), ("b", "fornalha"), ("c", "fumaça")), correctOptionId="a", evidenceSpan="o Senhor tinha descido sobre ele em fogo", feedbackCorrect="O Senhor tinha descido: presença real no fogo.", feedbackWrong={"b": "Fornalha é comparação; o eixo é descido.", "c": "Fumaça é efeito; o trecho é descido."}, hint="Veja o verbo da ação do Senhor.", learningObjective="Sustentar a leitura da presença.", evidence=["Êxodo 19:18"]),
    q(difficulty="profundezas", type="choice", question="Que leitura Êxodo 19:10–19 sustenta sobre o Sinai?", verseRef="Êxodo 19:18", options=o(("a", "A santidade de Deus exige preparo e temor"), ("b", "O povo podia tratar o monte como praça"), ("c", "O fogo nega a presença do Senhor"), ("d", "Só Moisés precisava se preparar")), correctOptionId="a", evidenceSpan="o Senhor tinha descido sobre ele em fogo", feedbackCorrect="Fogo e limites mostram santidade que pede preparo.", feedbackWrong={"b": "Há limites e pena de morte.", "c": "O fogo marca a descida do Senhor.", "d": "O povo inteiro é purificado."}, hint="Una fogo, limite e preparo.", learningObjective="Escolher a interpretação sustentável.", evidence=["Êxodo 19:18"]),
    q(difficulty="profundezas", type="order", question="Qual sequência liga o Sinai à Escritura?", verseRef="Êxodo 19:16", options=o(("a", "Israel treme ante trombeta e fogo"), ("b", "O Salmo lembra a terra que tremeu"), ("c", "Hebreus retoma o monte terrível")), correctOrder=["a", "b", "c"], evidenceSpan="todo o povo que estava no acampamento se estremeceu", feedbackCorrect="Do Êxodo ao Salmo e a Hebreus: o mesmo temor santo.", feedbackWrong={"default": "Comece pelo Sinai; depois Salmo e Hebreus."}, hint="Siga a ordem da revelação.", learningObjective="Ver o Sinai ecoar na Escritura.", evidence=["Êxodo 19:16", "Salmos 68:8", "Hebreus 12:18–19"]),
    q(difficulty="profundezas", type="complete", question="Em Êxodo 19:10, que verbo resume a ordem de preparar o povo?", verseRef="Êxodo 19:10", options=o(("a", "purifique-os"), ("b", "esqueça-os"), ("c", "espalhe-os")), correctOptionId="a", evidenceSpan="purifique-os hoje e amanhã", feedbackCorrect="A ordem-chave é purifique-os.", feedbackWrong={"b": "Não é esquecer; é purificar.", "c": "O verbo é purificar."}, hint="Veja o primeiro imperativo ao povo.", learningObjective="Lembrar o termo do preparo.", evidence=["Êxodo 19:10"]),
    q(difficulty="profundezas", type="connect", question="O que liga Êxodo 19:18 a Hebreus 12:21?", verseRef="Êxodo 19:18", passageA={"ref": "Êxodo 19:18"}, passageB={"ref": "Hebreus 12:21"}, options=o(("a", "Temor no Sinai"), ("b", "Alegria no Egito"), ("c", "Pão do céu")), correctOptionId="a", evidenceSpan="todo o monte tremia grandemente", feedbackCorrect="Hebreus lembra o temor diante do Sinai.", feedbackWrong={"b": "O elo é temor, não alegria no Egito.", "c": "O maná não é o tema deste elo."}, hint="Compare tremor e temor.", learningObjective="Ligar Sinai a Hebreus.", evidence=["Êxodo 19:18", "Hebreus 12:21"]),
]))

# ---------------- 19 Sinai words vf=1 ----------------
errs_all += save("exc-19-as-palavras-do-sinai", L({
    "passageRef": "Êxodo 20:7–12",
    "passages": [{"ref": "Êxodo 20:7–17"}],
    "context": "No Sinai, o Senhor fala palavras que guardam o seu nome, o sábado e o amor concreto ao próximo.",
    "keyword": "Palavras",
    "keywordGloss": "Mandamentos que protegem o nome de Deus, o descanso e o próximo.",
    "focusQuestion": "Qual mandamento está pedindo cuidado concreto na sua semana?",
    "reflectionPrompts": ["Nome em vão", "Sábado santo", "Amar o próximo"],
    "facts": [
        {"text": "Não se deve tomar o nome do Senhor em vão.", "evidenceRef": "Êxodo 20:7", "evidenceSpan": "Não tomarás o nome do Senhor, teu Deus, em vão"},
        {"text": "O sábado deve ser lembrado para santificá-lo.", "evidenceRef": "Êxodo 20:8", "evidenceSpan": "Lembre-se do dia de sábado, para santificá-lo"},
        {"text": "Em seis dias o Senhor fez céus, terra e mar.", "evidenceRef": "Êxodo 20:11", "evidenceSpan": "em seis dias, o Senhor fez os céus, a terra, o mar"},
        {"text": "Honrar pai e mãe prolonga os dias na terra.", "evidenceRef": "Êxodo 20:12", "evidenceSpan": "Honra teu pai e tua mãe, para que se prolonguem os teus dias"},
        {"text": "Não se deve cobiçar a casa nem a mulher do próximo.", "evidenceRef": "Êxodo 20:17", "evidenceSpan": "Não cobiçarás a casa do teu próximo, não cobiçarás a mulher do teu próximo"},
    ],
    "keyTerms": [
        {"term": "sábado", "gloss": "Dia do Senhor para santificar, não trabalhar."},
        {"term": "Honra", "gloss": "Respeito a pai e mãe com promessa de dias longos."},
        {"term": "cobiçarás", "gloss": "Desejo proibido do que é do próximo."},
    ],
    "structure": [
        {"label": "Nome do Senhor e sábado", "evidenceRef": "Êxodo 20:7–11"},
        {"label": "Honra a pai e mãe", "evidenceRef": "Êxodo 20:12"},
        {"label": "Não matar, adulterar, roubar", "evidenceRef": "Êxodo 20:13–15"},
        {"label": "Falso testemunho e cobiça", "evidenceRef": "Êxodo 20:16–17"},
    ],
    "relations": [
        {"kind": "causa", "text": "Não tomar o nome em vão, pois o Senhor não terá por inocente.", "marker": "pois", "evidenceRef": "Êxodo 20:7"},
        {"kind": "resultado", "text": "Honra pai e mãe para que se prolonguem os dias.", "marker": "para que", "evidenceRef": "Êxodo 20:12"},
        {"kind": "causa", "text": "O sábado se funda na criação: porque em seis dias o Senhor fez.", "marker": "Porque", "evidenceRef": "Êxodo 20:11"},
    ],
    "crossRefs": [
        {"ref": "Mateus 22:37–39", "bridge": "Amar Deus e próximo"},
        {"ref": "Romanos 13:9", "bridge": "Mandamentos resumidos"},
        {"ref": "Efésios 6:2–3", "bridge": "Honra e promessa"},
    ],
    "misreadings": [
        {"text": "O sábado não tem ligação com a criação.", "why": "O texto liga o sábado aos seis dias da criação."},
        {"text": "Cobiçar é só sobre objetos, nunca sobre pessoas.", "why": "O texto inclui a mulher do próximo."},
        {"text": "Tomar o nome em vão não tem consequência.", "why": "O Senhor não considerará inocente quem o fizer."},
    ],
    "centralInsight": "A lei guarda o nome de Deus, o descanso e o amor concreto ao próximo.",
    "anchorQuestion": "Por que o Senhor mandou lembrar o sábado?",
}, [
    q(difficulty="semente", type="true_false", question="O texto manda lembrar o dia de sábado para santificá-lo.", verseRef="Êxodo 20:8", correctOptionId="true", evidenceSpan="Lembre-se do dia de sábado, para santificá-lo", feedbackCorrect="Lembrar e santificar o sábado estão juntos.", feedbackWrong={"false": "Releia: lembre-se do dia de sábado, para santificá-lo."}, hint="Veja o verbo e o propósito.", learningObjective="Observar o mandamento do sábado.", evidence=["Êxodo 20:8"]),
    q(difficulty="semente", type="find_in_text", question="Em Êxodo 20:12, toque a quem se deve honrar primeiro no verso.", verseRef="Êxodo 20:12", options=o(("a", "pai"), ("b", "mãe"), ("c", "terra")), correctOptionId="a", evidenceSpan="Honra teu pai e tua mãe", feedbackCorrect="O verso começa: Honra teu pai e tua mãe.", feedbackWrong={"b": "A mãe vem junto; o primeiro citado é pai.", "c": "A terra é a promessa; quem se honra é pai."}, hint="Veja o primeiro honrado.", learningObjective="Identificar pai e mãe.", evidence=["Êxodo 20:12"]),
    q(difficulty="semente", type="choice", question="Segundo Êxodo 20:7, o que não se deve fazer com o nome do Senhor?", verseRef="Êxodo 20:7", options=o(("a", "Tomá-lo em vão"), ("b", "Cantá-lo em louvor"), ("c", "Ensiná-lo aos filhos"), ("d", "Lembrá-lo no sábado")), correctOptionId="a", evidenceSpan="Não tomarás o nome do Senhor, teu Deus, em vão", feedbackCorrect="É proibido tomar o nome do Senhor em vão.", feedbackWrong={"b": "Louvor não é o alvo da proibição.", "c": "Ensinar não é tomado como vão aqui.", "d": "O sábado é outro mandamento."}, hint="Leia a proibição sobre o nome.", learningObjective="Observar o uso do nome.", evidence=["Êxodo 20:7"]),
    q(difficulty="semente", type="order", question="Monte Êxodo 20:7 na ordem do texto.", verseRef="Êxodo 20:7", options=o(("a", "Não tomarás o nome do Senhor, teu Deus, em vão"), ("b", "pois o Senhor não considerará inocente"), ("c", "aquele que tomar o seu nome em vão")), correctOrder=["a", "b", "c"], evidenceSpan="Não tomarás o nome do Senhor, teu Deus, em vão", feedbackCorrect="Proibição, motivo e alcance na ordem do texto.", feedbackWrong={"default": "Comece pela proibição do nome."}, hint="O versículo começa com Não tomarás.", learningObjective="Reconhecer a ordem de 20:7.", evidence=["Êxodo 20:7"]),
    q(difficulty="semente", type="complete", question="Em Êxodo 20:15, qual é a proibição?", verseRef="Êxodo 20:15", options=o(("a", "roubarás"), ("b", "orarás"), ("c", "cantarás")), correctOptionId="a", evidenceSpan="Não roubarás", feedbackCorrect="A ordem é: Não roubarás.", feedbackWrong={"b": "Não é sobre orar.", "c": "O verbo proibido é roubar."}, hint="Veja o verbo do mandamento.", learningObjective="Lembrar a proibição de roubar.", evidence=["Êxodo 20:15"]),
    q(difficulty="semente", type="connect", question="O que Êxodo 20:8 comunica que se liga a este contexto?", verseRef="Êxodo 20:8", passageA={"ref": "Êxodo 20:8"}, passageB={"ref": "Contexto", "text": "No Sinai o Senhor dá palavras que moldam a vida do povo."}, options=o(("a", "Descanso santificado"), ("b", "Volta ao Egito"), ("c", "Culto a Faraó")), correctOptionId="a", evidenceSpan="Lembre-se do dia de sábado, para santificá-lo", feedbackCorrect="O sábado santificado é parte das palavras do Sinai.", feedbackWrong={"b": "O texto não manda voltar.", "c": "O Senhor, não Faraó, é o centro."}, hint="Compare a palavra com o momento.", learningObjective="Ligar sábado e aliança.", evidence=["Êxodo 20:8"]),
    q(difficulty="caminhada", type="true_false", question="Em Êxodo 20:7, o Senhor considerará inocente quem tomar o seu nome em vão.", verseRef="Êxodo 20:7", correctOptionId="false", evidenceSpan="o Senhor não considerará inocente aquele que tomar o seu nome em vão", feedbackCorrect="Ele não considerará inocente quem o fizer.", feedbackWrong={"true": "Releia: o Senhor não considerará inocente."}, hint="Veja se há inocência ou não.", learningObjective="Compreender a seriedade do nome.", evidence=["Êxodo 20:7"]),
    q(difficulty="caminhada", type="find_in_text", question="Em Êxodo 20:7, toque a palavra que marca o motivo da proibição.", verseRef="Êxodo 20:7", options=o(("a", "pois"), ("b", "nome"), ("c", "Deus")), correctOptionId="a", evidenceSpan="em vão, pois o Senhor não considerará inocente", feedbackCorrect="\"Pois\" introduz a consequência divina.", feedbackWrong={"b": "\"nome\" é o objeto; o marcador é pois.", "c": "\"Deus\" acompanha; a causa é pois."}, hint="Procure a palavra após \"em vão\".", learningObjective="Reconhecer o marcador de causa.", evidence=["Êxodo 20:7"]),
    q(difficulty="caminhada", type="choice", question="Como Êxodo 20:11 liga o sábado à criação?", verseRef="Êxodo 20:11", options=o(("a", "Porque o Senhor fez tudo em seis dias e descansou"), ("b", "Porque Israel inventou o descanso"), ("c", "Porque Faraó ordenou o sábado"), ("d", "Porque o mar Vermelho abriu no sábado")), correctOptionId="a", evidenceSpan="Porque, em seis dias, o Senhor fez os céus, a terra, o mar", feedbackCorrect="O fundamento é a criação e o descanso de Deus.", feedbackWrong={"b": "O texto aponta para o Senhor, não para Israel.", "c": "Faraó não institui o sábado aqui.", "d": "O motivo é a criação."}, hint="Veja o \"Porque\" do versículo.", learningObjective="Relacionar sábado e criação.", evidence=["Êxodo 20:11"]),
    q(difficulty="caminhada", type="order", question="Como avança o bloco das palavras em Êxodo 20:7–17?", verseRef="Êxodo 20:7–8", options=o(("a", "Guardar o nome e o sábado"), ("b", "Honrar pai e mãe"), ("c", "Não cobiçar o do próximo")), correctOrder=["a", "b", "c"], evidenceSpan="Não tomarás o nome do Senhor", feedbackCorrect="De Deus e do descanso ao lar e ao próximo.", feedbackWrong={"default": "Comece pelo nome e sábado."}, hint="Siga de Deus ao próximo.", learningObjective="Compreender o movimento da lei.", evidence=["Êxodo 20:7", "Êxodo 20:12", "Êxodo 20:17"]),
    q(difficulty="caminhada", type="complete", question="Em Êxodo 20:12, que palavra introduz o propósito de honrar pai e mãe?", verseRef="Êxodo 20:12", options=o(("a", "para"), ("b", "contra"), ("c", "sem")), correctOptionId="a", evidenceSpan="para que se prolonguem os teus dias", feedbackCorrect="\"Para que\" liga honra e dias prolongados.", feedbackWrong={"b": "Não é contra; é para que.", "c": "O marcador é para."}, hint="Veja a palavra antes de \"que se prolonguem\".", learningObjective="Lembrar o marcador de propósito.", evidence=["Êxodo 20:12"]),
    q(difficulty="caminhada", type="connect", question="O que liga Êxodo 20:12 a Efésios 6:2–3?", verseRef="Êxodo 20:12", passageA={"ref": "Êxodo 20:12"}, passageB={"ref": "Efésios 6:2–3"}, options=o(("a", "Honra e promessa"), ("b", "Jejum no deserto"), ("c", "Construção do templo")), correctOptionId="a", evidenceSpan="Honra teu pai e tua mãe, para que se prolonguem", feedbackCorrect="Paulo cita a honra com promessa de dias.", feedbackWrong={"b": "O elo é honra familiar.", "c": "Não é sobre o templo."}, hint="Compare honra e dias longos.", learningObjective="Relacionar Êxodo e Efésios.", evidence=["Êxodo 20:12", "Efésios 6:2–3"]),
    q(difficulty="profundezas", type="true_false", question="Êxodo 20:7–17 sustenta que a lei só fala de ritos e ignora o próximo.", verseRef="Êxodo 20:16–17", correctOptionId="false", evidenceSpan="Não darás falso testemunho em relação ao teu próximo", feedbackCorrect="A lei alcança nome, descanso e o próximo concreto.", feedbackWrong={"true": "Há mandamentos claros sobre o próximo."}, hint="Veja falso testemunho e cobiça.", learningObjective="Interpretar o alcance da lei.", evidence=["Êxodo 20:16", "Êxodo 20:17"]),
    q(difficulty="profundezas", type="find_in_text", question="Em Êxodo 20:17, toque o verbo que sustenta a proibição do desejo injusto.", verseRef="Êxodo 20:17", options=o(("a", "cobiçarás"), ("b", "casa"), ("c", "boi")), correctOptionId="a", evidenceSpan="Não cobiçarás a casa do teu próximo", feedbackCorrect="O verbo-chave é cobiçarás.", feedbackWrong={"b": "\"casa\" é objeto; o verbo é cobiçar.", "c": "\"boi\" é exemplo; o verbo é cobiçar."}, hint="Procure o verbo repetido.", learningObjective="Sustentar a leitura da cobiça.", evidence=["Êxodo 20:17"]),
    q(difficulty="profundezas", type="choice", question="Que leitura Êxodo 20:7–17 sustenta sobre a lei?", verseRef="Êxodo 20:7", options=o(("a", "Guarda o nome de Deus e o amor concreto ao próximo"), ("b", "Só importa o culto sem ética"), ("c", "Cobiçar o próximo é permitido"), ("d", "O sábado não tem base na criação")), correctOptionId="a", evidenceSpan="Não tomarás o nome do Senhor, teu Deus, em vão", feedbackCorrect="Nome santo e próximo protegido andam juntos.", feedbackWrong={"b": "Há mandamentos éticos claros.", "c": "Cobiçar é proibido.", "d": "20:11 liga o sábado à criação."}, hint="Una nome, sábado e próximo.", learningObjective="Escolher a interpretação sustentável.", evidence=["Êxodo 20:7", "Êxodo 20:17"]),
    q(difficulty="profundezas", type="order", question="Qual sequência liga as palavras do Sinai à Escritura?", verseRef="Êxodo 20:12", options=o(("a", "O Sinai manda honrar e não cobiçar"), ("b", "Jesus resume em amar a Deus e ao próximo"), ("c", "Paulo cita a honra com promessa")), correctOrder=["a", "b", "c"], evidenceSpan="Honra teu pai e tua mãe", feedbackCorrect="Da lei ao resumo de Jesus e à citação de Paulo.", feedbackWrong={"default": "Comece pelo Sinai; depois Jesus e Paulo."}, hint="Siga a ordem da revelação.", learningObjective="Ver a lei ecoar no NT.", evidence=["Êxodo 20:12", "Mateus 22:37–39", "Efésios 6:2–3"]),
    q(difficulty="profundezas", type="complete", question="Em Êxodo 20:8, que termo nomeia o dia a santificar?", verseRef="Êxodo 20:8", options=o(("a", "sábado"), ("b", "guerra"), ("c", "colheita")), correctOptionId="a", evidenceSpan="dia de sábado, para santificá-lo", feedbackCorrect="O dia a santificar é o sábado.", feedbackWrong={"b": "Não é guerra.", "c": "O termo é sábado."}, hint="Veja o nome do dia.", learningObjective="Lembrar o termo do descanso.", evidence=["Êxodo 20:8"]),
    q(difficulty="profundezas", type="connect", question="O que liga Êxodo 20:13–17 a Romanos 13:9?", verseRef="Êxodo 20:13–14", passageA={"ref": "Êxodo 20:13"}, passageB={"ref": "Romanos 13:9"}, options=o(("a", "Mandamentos resumidos"), ("b", "Maná no deserto"), ("c", "Coluna de fogo")), correctOptionId="a", evidenceSpan="Não matarás", feedbackCorrect="Paulo resume esses mandamentos no amor ao próximo.", feedbackWrong={"b": "O elo é a lei moral.", "c": "A coluna não é o tema."}, hint="Compare a lista de proibições.", learningObjective="Ligar Sinai a Romanos.", evidence=["Êxodo 20:13", "Romanos 13:9"]),
]))

# ---------------- 20 Servo vf=1 ----------------
errs_all += save("exc-20-servo-e-liberdade", L({
    "passageRef": "Êxodo 21:1–6",
    "passages": [{"ref": "Êxodo 21:1–11"}],
    "context": "Depois da lei, vêm estatutos: o escravo hebreu serve seis anos e no sétimo sai livre; há também regras para a escrava.",
    "keyword": "Livre",
    "keywordGloss": "No sétimo ano o escravo hebreu sai livre, sem custo.",
    "focusQuestion": "Onde você precisa tratar o outro com a dignidade que a lei de Deus exige?",
    "reflectionPrompts": ["Seis anos", "Sétimo livre", "Orelha furada"],
    "facts": [
        {"text": "O escravo hebreu serve seis anos e no sétimo sai livre.", "evidenceRef": "Êxodo 21:2", "evidenceSpan": "servirá por seis anos; mas, no sétimo ano, ele sairá livre"},
        {"text": "Se entrou solteiro, sai sozinho; se casado, a esposa sai com ele.", "evidenceRef": "Êxodo 21:3", "evidenceSpan": "Se entrou solteiro, sairá sozinho; se era casado, sua esposa sairá com ele"},
        {"text": "O escravo pode declarar que ama o senhor e não quer ficar livre.", "evidenceRef": "Êxodo 21:5", "evidenceSpan": "Eu amo o meu senhor, a minha esposa e os meus filhos; não quero ficar livre"},
        {"text": "Então o senhor fura a orelha e ele serve para sempre.", "evidenceRef": "Êxodo 21:6", "evidenceSpan": "lhe furará a orelha com uma sovela; e ele o servirá para sempre"},
        {"text": "Se não fizer as três coisas à escrava, ela sai livre.", "evidenceRef": "Êxodo 21:11", "evidenceSpan": "se não lhe fizer estas três coisas, sairá livre"},
    ],
    "keyTerms": [
        {"term": "livre", "gloss": "Saída sem custo no sétimo ano."},
        {"term": "sovela", "gloss": "Instrumento que fura a orelha do servo permanente."},
        {"term": "estatutos", "gloss": "Regras que Moisés deve propor ao povo."},
    ],
    "structure": [
        {"label": "Hebreu serve seis anos e sai livre", "evidenceRef": "Êxodo 21:1–2"},
        {"label": "Família e saída", "evidenceRef": "Êxodo 21:3–4"},
        {"label": "Servo que escolhe ficar", "evidenceRef": "Êxodo 21:5–6"},
        {"label": "Proteção da escrava", "evidenceRef": "Êxodo 21:7–11"},
    ],
    "relations": [
        {"kind": "contraste", "text": "Serve seis anos, mas no sétimo sai livre.", "marker": "mas", "evidenceRef": "Êxodo 21:2"},
        {"kind": "resultado", "text": "Se declarar amor e recusar liberdade, serve para sempre.", "marker": "Então", "evidenceRef": "Êxodo 21:6"},
        {"kind": "resultado", "text": "Se não fizer as três coisas, ela sai livre.", "marker": "Mas", "evidenceRef": "Êxodo 21:11"},
    ],
    "crossRefs": [
        {"ref": "Deuteronômio 15:12", "bridge": "Liberdade no sétimo"},
        {"ref": "Jeremias 34:14", "bridge": "Soltar o hebreu"},
        {"ref": "1 Coríntios 7:21", "bridge": "Usar a liberdade"},
    ],
    "misreadings": [
        {"text": "O escravo hebreu nunca podia sair.", "why": "No sétimo ano sai livre sem custo."},
        {"text": "A escrava não tinha nenhuma proteção.", "why": "Há regras de resgate, dignidade e saída livre."},
        {"text": "Furar a orelha era castigo aleatório.", "why": "É o sinal de quem escolhe servir para sempre."},
    ],
    "centralInsight": "Até a servidão tem limite e dignidade diante do Senhor.",
    "anchorQuestion": "Em que ano o escravo hebreu saía livre?",
}, [
    q(difficulty="semente", type="true_false", question="O escravo hebreu servirá por seis anos e no sétimo sairá livre.", verseRef="Êxodo 21:2", correctOptionId="true", evidenceSpan="servirá por seis anos; mas, no sétimo ano, ele sairá livre", feedbackCorrect="Seis anos de serviço; liberdade no sétimo.", feedbackWrong={"false": "Releia: no sétimo ano, ele sairá livre."}, hint="Veja os anos e a saída.", learningObjective="Observar o limite da servidão.", evidence=["Êxodo 21:2"]),
    q(difficulty="semente", type="find_in_text", question="Em Êxodo 21:2, toque a palavra que nomeia a saída do sétimo ano.", verseRef="Êxodo 21:2", options=o(("a", "livre"), ("b", "comprar"), ("c", "hebreu")), correctOptionId="a", evidenceSpan="ele sairá livre sem custo algum", feedbackCorrect="No sétimo ele sai livre.", feedbackWrong={"b": "\"comprar\" abre a lei; a saída é livre.", "c": "\"hebreu\" identifica; a palavra é livre."}, hint="Veja o adjetivo da saída.", learningObjective="Identificar a liberdade.", evidence=["Êxodo 21:2"]),
    q(difficulty="semente", type="choice", question="Segundo Êxodo 21:6, o que o senhor faz na orelha do escravo que fica?", verseRef="Êxodo 21:6", options=o(("a", "Fura com uma sovela"), ("b", "Cola um anel de ouro"), ("c", "Corta o cabelo"), ("d", "Lava com óleo")), correctOptionId="a", evidenceSpan="lhe furará a orelha com uma sovela", feedbackCorrect="Fura a orelha com uma sovela.", feedbackWrong={"b": "Não há anel no texto.", "c": "A ação é furar a orelha.", "d": "O instrumento é a sovela."}, hint="Leia o gesto na porta.", learningObjective="Observar o sinal do servo permanente.", evidence=["Êxodo 21:6"]),
    q(difficulty="semente", type="order", question="Monte Êxodo 21:2 na ordem do texto.", verseRef="Êxodo 21:2", options=o(("a", "Se você comprar um escravo hebreu"), ("b", "ele servirá por seis anos"), ("c", "mas, no sétimo ano, ele sairá livre sem custo algum")), correctOrder=["a", "b", "c"], evidenceSpan="ele sairá livre sem custo algum", feedbackCorrect="Compra, serviço e liberdade na ordem do texto.", feedbackWrong={"default": "Comece pela compra do escravo."}, hint="O versículo começa com Se você comprar.", learningObjective="Reconhecer a ordem de 21:2.", evidence=["Êxodo 21:2"]),
    q(difficulty="semente", type="complete", question="Em Êxodo 21:6, com que instrumento o senhor fura a orelha?", verseRef="Êxodo 21:6", options=o(("a", "sovela"), ("b", "espada"), ("c", "martelo")), correctOptionId="a", evidenceSpan="furará a orelha com uma sovela", feedbackCorrect="O instrumento é uma sovela.", feedbackWrong={"b": "Não é espada.", "c": "O texto diz sovela."}, hint="Veja o instrumento nomeado.", learningObjective="Lembrar a sovela.", evidence=["Êxodo 21:6"]),
    q(difficulty="semente", type="connect", question="O que Êxodo 21:2 comunica que se liga a este contexto?", verseRef="Êxodo 21:2", passageA={"ref": "Êxodo 21:2"}, passageB={"ref": "Contexto", "text": "Os estatutos limitam a servidão e abrem caminho à liberdade."}, options=o(("a", "Limite e liberdade"), ("b", "Escravidão eterna"), ("c", "Sem lei alguma")), correctOptionId="a", evidenceSpan="no sétimo ano, ele sairá livre", feedbackCorrect="O sétimo ano marca limite e liberdade.", feedbackWrong={"b": "O texto abre saída livre.", "c": "Há estatutos claros."}, hint="Compare anos e saída.", learningObjective="Ligar estatuto e dignidade.", evidence=["Êxodo 21:2"]),
    q(difficulty="caminhada", type="true_false", question="Em Êxodo 21:2, o escravo hebreu sai livre no sétimo ano mediante alto pagamento.", verseRef="Êxodo 21:2", correctOptionId="false", evidenceSpan="sairá livre sem custo algum", feedbackCorrect="Sai livre sem custo algum.", feedbackWrong={"true": "Releia: sem custo algum."}, hint="Há custo na saída?", learningObjective="Compreender a liberdade sem custo.", evidence=["Êxodo 21:2"]),
    q(difficulty="caminhada", type="find_in_text", question="Em Êxodo 21:2, toque a palavra que marca o contraste entre servir e sair.", verseRef="Êxodo 21:2", options=o(("a", "mas"), ("b", "anos"), ("c", "custo")), correctOptionId="a", evidenceSpan="servirá por seis anos; mas, no sétimo ano", feedbackCorrect="\"Mas\" vira a cena: do serviço à liberdade.", feedbackWrong={"b": "\"anos\" mede o tempo; o contraste é mas.", "c": "\"custo\" fecha; o marcador é mas."}, hint="Procure a palavra entre seis e sétimo.", learningObjective="Reconhecer o marcador de contraste.", evidence=["Êxodo 21:2"]),
    q(difficulty="caminhada", type="choice", question="Como Êxodo 21:5–6 liga a declaração do escravo ao serviço permanente?", verseRef="Êxodo 21:5–6", options=o(("a", "Se ama e não quer livre, fura a orelha e serve sempre"), ("b", "Se ama, sai no terceiro ano"), ("c", "Se declara, paga o dobro e foge"), ("d", "Se ama, vira juiz do povo")), correctOptionId="a", evidenceSpan="ele o servirá para sempre", feedbackCorrect="Amor declarado leva ao sinal e ao serviço para sempre.", feedbackWrong={"b": "Não há saída no terceiro ano neste caso.", "c": "Não há fuga paga aqui.", "d": "O resultado é servir para sempre."}, hint="Una a fala e o gesto na porta.", learningObjective="Relacionar escolha e sinal.", evidence=["Êxodo 21:5", "Êxodo 21:6"]),
    q(difficulty="caminhada", type="order", question="Como avançam os estatutos em Êxodo 21:1–11?", verseRef="Êxodo 21:2–3", options=o(("a", "Hebreu serve e sai livre no sétimo"), ("b", "Quem ama pode ficar para sempre"), ("c", "A escrava tem proteção e saída")), correctOrder=["a", "b", "c"], evidenceSpan="ele sairá livre sem custo algum", feedbackCorrect="Liberdade, escolha permanente e proteção da escrava.", feedbackWrong={"default": "Comece pela liberdade no sétimo."}, hint="Siga hebreu, escolha e escrava.", learningObjective="Compreender o movimento da lei.", evidence=["Êxodo 21:2", "Êxodo 21:6", "Êxodo 21:11"]),
    q(difficulty="caminhada", type="complete", question="Em Êxodo 21:6, até quando ele servirá após o sinal?", verseRef="Êxodo 21:6", options=o(("a", "sempre"), ("b", "nunca"), ("c", "hoje")), correctOptionId="a", evidenceSpan="ele o servirá para sempre", feedbackCorrect="Serve para sempre após o sinal.", feedbackWrong={"b": "O texto diz para sempre.", "c": "Não é só hoje."}, hint="Veja o fim do versículo.", learningObjective="Lembrar a duração do serviço.", evidence=["Êxodo 21:6"]),
    q(difficulty="caminhada", type="connect", question="O que liga Êxodo 21:2 a Deuteronômio 15:12?", verseRef="Êxodo 21:2", passageA={"ref": "Êxodo 21:2"}, passageB={"ref": "Deuteronômio 15:12"}, options=o(("a", "Liberdade no sétimo"), ("b", "Bezerro de ouro"), ("c", "Pragas no Egito")), correctOptionId="a", evidenceSpan="no sétimo ano, ele sairá livre", feedbackCorrect="Os dois textos mandam soltar no sétimo ano.", feedbackWrong={"b": "O elo é a liberdade.", "c": "As pragas não são o tema."}, hint="Compare o sétimo ano.", learningObjective="Relacionar Êxodo e Deuteronômio.", evidence=["Êxodo 21:2", "Deuteronômio 15:12"]),
    q(difficulty="profundezas", type="true_false", question="Êxodo 21:1–11 sustenta que a lei trata a servidão sem nenhum limite nem dignidade.", verseRef="Êxodo 21:2", correctOptionId="false", evidenceSpan="no sétimo ano, ele sairá livre sem custo algum", feedbackCorrect="Há limite de anos, saída livre e proteção da escrava.", feedbackWrong={"true": "O texto marca liberdade e salvaguardas."}, hint="Veja sétimo ano e regras da escrava.", learningObjective="Interpretar dignidade na lei.", evidence=["Êxodo 21:2", "Êxodo 21:11"]),
    q(difficulty="profundezas", type="find_in_text", question="Em Êxodo 21:11, toque o trecho que marca a ausência de pagamento na saída.", verseRef="Êxodo 21:11", options=o(("a", "retribuição"), ("b", "dinheiro"), ("c", "três")), correctOptionId="a", evidenceSpan="sem receber retribuição nem pagamento em dinheiro", feedbackCorrect="Sai livre sem receber retribuição.", feedbackWrong={"b": "\"dinheiro\" acompanha; o termo pedido é retribuição.", "c": "\"três\" são as coisas; o trecho é retribuição."}, hint="Veja o que ela não recebe.", learningObjective="Sustentar a saída sem pagamento.", evidence=["Êxodo 21:11"]),
    q(difficulty="profundezas", type="choice", question="Que leitura Êxodo 21:1–11 sustenta sobre esses estatutos?", verseRef="Êxodo 21:2", options=o(("a", "Servidão tem limite e a pessoa tem dignidade"), ("b", "Ninguém jamais sai livre"), ("c", "A escrava não tem salvaguarda"), ("d", "O sinal na orelha é sem escolha")), correctOptionId="a", evidenceSpan="sairá livre sem custo algum", feedbackCorrect="Anos limitados e proteções mostram dignidade.", feedbackWrong={"b": "O sétimo ano traz liberdade.", "c": "Há regras claras de proteção.", "d": "O sinal segue a declaração voluntária."}, hint="Una liberdade e proteção.", learningObjective="Escolher a interpretação sustentável.", evidence=["Êxodo 21:2"]),
    q(difficulty="profundezas", type="order", question="Qual sequência liga a liberdade do servo à Escritura?", verseRef="Êxodo 21:2", options=o(("a", "O estatuto solta o hebreu no sétimo"), ("b", "Deuteronômio repete a liberdade"), ("c", "Jeremias cobra soltar o hebreu")), correctOrder=["a", "b", "c"], evidenceSpan="ele sairá livre sem custo algum", feedbackCorrect="Da lei à repetição e à cobrança dos profetas.", feedbackWrong={"default": "Comece por Êxodo; depois Deuteronômio e Jeremias."}, hint="Siga a ordem da revelação.", learningObjective="Ver a liberdade ecoar na Escritura.", evidence=["Êxodo 21:2", "Deuteronômio 15:12", "Jeremias 34:14"]),
    q(difficulty="profundezas", type="complete", question="Em Êxodo 21:1, que termo nomeia o que Moisés deve propor?", verseRef="Êxodo 21:1", options=o(("a", "estatutos"), ("b", "canções"), ("c", "impostos")), correctOptionId="a", evidenceSpan="Estes são os estatutos que você lhes proporá", feedbackCorrect="O termo é estatutos.", feedbackWrong={"b": "Não são canções.", "c": "O texto fala de estatutos."}, hint="Veja o sujeito da frase de abertura.", learningObjective="Lembrar o termo da lei civil.", evidence=["Êxodo 21:1"]),
    q(difficulty="profundezas", type="connect", question="O que liga Êxodo 21:2 a Jeremias 34:14?", verseRef="Êxodo 21:2", passageA={"ref": "Êxodo 21:2"}, passageB={"ref": "Jeremias 34:14"}, options=o(("a", "Soltar o hebreu"), ("b", "Construir o templo"), ("c", "Ungir um rei")), correctOptionId="a", evidenceSpan="ele sairá livre sem custo algum", feedbackCorrect="Jeremias cobra a mesma soltura do hebreu.", feedbackWrong={"b": "O elo é a liberdade do servo.", "c": "Não é sobre unção real."}, hint="Compare a soltura no sétimo.", learningObjective="Ligar estatuto e profetas.", evidence=["Êxodo 21:2", "Jeremias 34:14"]),
]))

print("20 done — append 21-23+bosses next")
