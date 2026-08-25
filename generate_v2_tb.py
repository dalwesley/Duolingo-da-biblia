#!/usr/bin/env python3
"""Gera banco V2 a partir da TB (bible_tb.json) + trails.json.

Não sobrescreve trilhas já reescritas (KEEP). Uso:
    python3 generate_v2_tb.py --realm antigo-testamento
    python3 generate_v2_tb.py --realm novo-testamento
    python3 generate_v2_tb.py --realm vida-crista
    python3 generate_v2_tb.py --realm teologia
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent
TRAILS_PATH = ROOT / 'trilha_app' / 'assets' / 'data' / 'trails.json'
BIBLE_PATH = ROOT / 'trilha_app' / 'assets' / 'data' / 'bible_tb.json'
OUT_DIR = ROOT / 'perguntas-v2'

KEEP = {
    'ageu', 'cantares', 'miqueias', 'amos', 'joel', 'lamentacoes',
    'obadias', 'naum', 'habacuque', 'oseias', 'sofonias',
    # reescritas no padrão Oséias (não sobrescrever com o moinho)
    'zacarias', 'malaquias', 'periodo-intertestamentario', 'tito', 'filemom',
    'judas', 'cartas-paulo', 'cartas-gerais', 'historia-igreja',
    'linguas-originais', 'hebraico', 'grego', 'rute', 'jonas', 'esdras',
    'neemias', 'proverbios', 'eclesiastes', 'jeremias', 'marcos', 'galatas',
    'efesios', 'vida-crista', 'oracao', 'filipenses', 'colossenses',
    'tiago', 'pedro', 'familia', 'missao', 'tessalonicenses', 'timoteo',
    'cartas-joao', 'jejum', 'reforma', 'igreja-primitiva',
    'hermeneutica', 'teologia-sistematica', 'doutrina-de-deus',
    'antropologia', 'soteriologia', 'cristologia', 'eclesiologia',
    'escatologia', 'teologia-biblica', 'pneumatologia',
    'ester', 'jo', 'salmos', 'daniel', 'mateus', 'lucas',
    'cronicas', 'isaias', 'ezequiel', 'joao', 'corintios', 'hebreus',
    'juizes', 'romanos', 'deuteronomio', 'samuel', 'reis',
    'levitico', 'josue', 'numeros', 'apocalipse',
    'atos', 'exodo',
    'evangelhos', 'genesis-1-11',
    'genesis-12-50', 'sermao-do-monte',
}

DIFFICULTIES = ['semente', 'caminhada', 'profundezas']
SKILLS = {'semente': 'observe', 'caminhada': 'understand', 'profundezas': 'interpret'}
TYPE_ORDER = ['true_false', 'tap', 'choice', 'order', 'complete', 'connect']
SHORT = {'semente': 'sem', 'caminhada': 'cam', 'profundezas': 'pro'}

STOP = {
    'a', 'o', 'as', 'os', 'um', 'uma', 'e', 'ou', 'mas', 'que', 'de', 'da', 'do',
    'das', 'dos', 'em', 'no', 'na', 'nos', 'nas', 'por', 'para', 'com', 'sem',
    'se', 'ao', 'lhe', 'me', 'te', 'eu', 'tu', 'ele', 'ela', 'este', 'esta',
    'isso', 'isto', 'como', 'quando', 'então', 'pois', 'porque', 'porém', 'já',
    'não', 'sim', 'mais', 'sua', 'seu', 'seus', 'suas', 'meu', 'minha',
}

SLUG_REFS = {
    'mt-01-rei-prometido': 'Mateus 1:21–23',
    'mt-02-reino-ensino': 'Mateus 5:3–6',
    'mt-03-autoridade': 'Mateus 8:26–27',
    'mt-04-cruz-vitoria': 'Mateus 28:18–20',
    'mt-boss-revisao': 'Mateus 28:18–20',
    'mc-01-servo-autoridade': 'Marcos 1:14–15',
    'mc-02-caminho-cruz': 'Marcos 8:34–35',
    'mc-03-cruz-ressurreicao': 'Marcos 16:6',
    'mc-boss': 'Marcos 10:45',
    'lc-01-salvador-humilde': 'Lucas 2:10–11',
    'lc-02-misericordia': 'Lucas 15:7',
    'lc-03-caminho-jerusalem': 'Lucas 9:51',
    'lc-04-cruz-abertura': 'Lucas 24:46–47',
    'lc-boss': 'Lucas 19:10',
    'jo-01-verbo-sinais': 'João 1:14',
    'jo-02-eu-sou': 'João 14:6',
    'jo-03-adeus-espirito': 'João 15:5',
    'jo-04-cruz-vida': 'João 20:31',
    'jo-boss': 'João 20:31',
    'rm-01-pecado': 'Romanos 3:23',
    'rm-02-justificacao': 'Romanos 5:1',
    'rm-03-vida-espirito': 'Romanos 8:1–2',
    'rm-04-israel': 'Romanos 11:33',
    'rm-05-culto': 'Romanos 12:1–2',
    'rm-06-desafio': 'Romanos 1:16',
    'co-01-cruz': '1 Coríntios 1:18',
    'co-02-amor': '1 Coríntios 13:4–7',
    'co-03-ressurreicao': '1 Coríntios 15:3–4',
    'co-04-fraqueza': '2 Coríntios 12:9',
    'co-05-desafio': '1 Coríntios 15:3–4',
    'gl-01-outro-evangelho': 'Gálatas 1:6–8',
    'gl-02-fe': 'Gálatas 3:11',
    'gl-03-espirito': 'Gálatas 5:22–23',
    'gl-04-desafio': 'Gálatas 2:16',
    'ef-01-bencaos': 'Efésios 1:3–4',
    'ef-02-graca': 'Efésios 2:8–9',
    'ef-03-igreja': 'Efésios 6:11',
    'ef-04-desafio': 'Efésios 2:8–9',
    'fp-01-alegria': 'Filipenses 1:21',
    'fp-02-humildade': 'Filipenses 2:5–8',
    'fp-03-contentamento': 'Filipenses 4:12–13',
    'fp-04-desafio': 'Filipenses 2:5–8',
    'cl-01-supremacia': 'Colossenses 1:15–17',
    'cl-02-plenitude': 'Colossenses 2:9–10',
    'cl-03-nova-vida': 'Colossenses 3:1–3',
    'cl-04-desafio': 'Colossenses 1:18',
    'ts-01-conversao': '1 Tessalonicenses 1:9–10',
    'ts-02-santidade': '1 Tessalonicenses 4:3',
    'ts-03-dia-senhor': '2 Tessalonicenses 2:1–2',
    'ts-04-desafio': '1 Tessalonicenses 4:16–17',
    'tm-01-sadia-doutrina': '1 Timóteo 4:16',
    'tm-02-lideranca': '1 Timóteo 3:1–2',
    'tm-03-perseveranca': '2 Timóteo 1:13–14',
    'tm-04-desafio': '2 Timóteo 4:2',
    'tt-01-lideres': 'Tito 1:5–9',
    'tt-02-graca': 'Tito 2:11–12',
    'tt-03-desafio': 'Tito 2:11–14',
    'fm-01-intercessao': 'Filemom 1:10–11',
    'fm-02-reconciliacao': 'Filemom 1:15–16',
    'fm-03-desafio': 'Filemom 1:17–18',
    'hb-01': 'Hebreus 1:1–3',
    'hb-02': 'Hebreus 4:14–16',
    'hb-03': 'Hebreus 8:6',
    'hb-04': 'Hebreus 11:1',
    'hb-boss': 'Hebreus 12:1–2',
    'tg-01': 'Tiago 2:17',
    'tg-02': 'Tiago 3:8–10',
    'tg-03': 'Tiago 5:16',
    'tg-boss': 'Tiago 1:22',
    'pd-01': '1 Pedro 1:3–4',
    'pd-02': '1 Pedro 2:21–24',
    'pd-03': '2 Pedro 3:9–10',
    'pd-boss': '1 Pedro 5:6–7',
    'cj-01': '1 João 1:5–7',
    'cj-02': '1 João 4:7–8',
    'cj-03': '2 João 1:6',
    'cj-boss': '1 João 5:13',
    'jd-01': 'Judas 1:3',
    'jd-02': 'Judas 1:21',
    'jd-boss': 'Judas 1:24–25',
    'cg-01': '1 Pedro 2:9',
    'cg-02': 'Tiago 1:22',
    'cg-boss': '1 Pedro 2:9',
    'cp-01-apostolo': 'Atos 9:15–16',
    'cp-02-evangelho': '1 Coríntios 15:3–4',
    'cp-03-desafio': 'Gálatas 1:11–12',
    'periodo-inte-inter-01-imperios-em-cena': 'Malaquias 3:1',
    'periodo-inte-inter-02-esperanca-messiani': 'Malaquias 4:5–6',
    'periodo-inte-inter-03-desafio-a-espera': 'Isaías 40:3',
    'sm-boss-06-sermao-completo': 'Mateus 7:24–25',
    'vd-04-desafio': 'Marcos 8:34–35',
    'fm-03-comunidade': 'Gálatas 6:2',
    'fm-04-desafio': 'Efésios 5:25',
    'ms-04-desafio': 'Mateus 28:18–20',
    'or-04-desafio': 'Mateus 6:9–10',
    'jj-04-desafio': 'Mateus 6:16–18',
    'hi-03-desafio': 'Mateus 16:18',
    'ip-03-expansao': 'Atos 8:4',
    'ip-04-desafio': 'Atos 2:42–47',
    'rf-04-desafio': 'Efésios 2:8–9',
    'hm-boss': 'Lucas 24:27',
    'lo-boss': '1 Coríntios 14:9',
    'hebraico:hb-boss': 'Deuteronômio 6:4',
    'gr-boss': 'João 1:14',
    'ts-boss': '2 Timóteo 3:16–17',
    'dd-boss': 'Gênesis 1:1',
    'an-boss': 'Gênesis 1:26–27',
    'so-boss': 'Efésios 2:8–9',
    'ec-boss': '1 Coríntios 12:12–13',
    'es-boss': 'Apocalipse 21:3–4',
    'tb-boss': 'Lucas 24:44',
    'cr-boss': 'João 1:1',
    'pn-boss': 'Gálatas 5:22–23',
}

TRAIL_BOOK = {
    'genesis-1-11': 'Gênesis', 'genesis-12-50': 'Gênesis', 'exodo': 'Êxodo',
    'levitico': 'Levítico', 'numeros': 'Números', 'deuteronomio': 'Deuteronômio',
    'josue': 'Josué', 'juizes': 'Juízes', 'rute': 'Rute', 'samuel': '1 Samuel',
    'reis': '1 Reis', 'cronicas': '1 Crônicas', 'esdras': 'Esdras',
    'neemias': 'Neemias', 'ester': 'Ester', 'jo': 'Jó', 'salmos': 'Salmos',
    'proverbios': 'Provérbios', 'eclesiastes': 'Eclesiastes', 'isaias': 'Isaías',
    'jeremias': 'Jeremias', 'ezequiel': 'Ezequiel', 'daniel': 'Daniel',
    'jonas': 'Jonas', 'zacarias': 'Zacarias', 'malaquias': 'Malaquias',
    'periodo-intertestamentario': 'Malaquias', 'evangelhos': 'João',
    'mateus': 'Mateus', 'marcos': 'Marcos', 'lucas': 'Lucas', 'joao': 'João',
    'atos': 'Atos', 'cartas-paulo': 'Romanos', 'romanos': 'Romanos',
    'corintios': '1 Coríntios', 'galatas': 'Gálatas', 'efesios': 'Efésios',
    'filipenses': 'Filipenses', 'colossenses': 'Colossenses',
    'tessalonicenses': '1 Tessalonicenses', 'timoteo': '1 Timóteo',
    'tito': 'Tito', 'filemom': 'Filemom', 'cartas-gerais': '1 Pedro',
    'hebreus': 'Hebreus', 'tiago': 'Tiago', 'pedro': '1 Pedro',
    'cartas-joao': '1 João', 'judas': 'Judas', 'apocalipse': 'Apocalipse',
    'sermao-do-monte': 'Mateus', 'vida-crista': 'Marcos', 'familia': 'Efésios',
    'missao': 'Mateus', 'oracao': 'Mateus', 'jejum': 'Mateus',
    'historia-igreja': 'Mateus', 'igreja-primitiva': 'Atos', 'reforma': 'Efésios',
    'hermeneutica': 'Lucas', 'linguas-originais': 'Lucas', 'hebraico': 'Deuteronômio',
    'grego': 'João', 'teologia-sistematica': '2 Timóteo', 'doutrina-de-deus': 'Gênesis',
    'antropologia': 'Gênesis', 'soteriologia': 'Efésios', 'eclesiologia': 'Atos',
    'escatologia': 'Apocalipse', 'teologia-biblica': 'Lucas',
    'cristologia': 'João', 'pneumatologia': 'Romanos',
}

TF = [{'id': 'true', 'text': 'Verdadeiro'}, {'id': 'false', 'text': 'Falso'}]


def fold(s: str) -> str:
    s = unicodedata.normalize('NFD', s or '')
    s = ''.join(c for c in s if unicodedata.category(c) != 'Mn')
    return re.sub(r'[^a-z0-9]+', '', s.lower())


def clip(text: str, limit: int) -> str:
    value = re.sub(r'\s+', ' ', (text or '')).strip()
    if len(value) <= limit:
        return value
    cut = value[:limit].rsplit(' ', 1)[0].rstrip(' ,;:')
    return cut or value[:limit]


def stable_rot(key: str, n: int) -> int:
    if n <= 1:
        return 0
    return int(hashlib.md5(key.encode()).hexdigest(), 16) % n


class Bible:
    def __init__(self, path: Path):
        books = json.loads(path.read_text(encoding='utf-8'))
        self.by_name = {}
        self.by_abbrev = {}
        for b in books:
            self.by_name[fold(b.get('name') or '')] = b
            self.by_abbrev[fold(b.get('abbrev') or '')] = b
        aliases = {
            'genesis': 'gênesis', 'exodo': 'êxodo', 'levitico': 'levítico',
            'numeros': 'números', 'deuteronomio': 'deuteronômio',
            'salmo': 'salmos', 'proverbios': 'provérbios', 'isaias': 'isaías',
            'joao': 'joão', 'galatas': 'gálatas', 'efesios': 'efésios',
            'corintios': '1 coríntios', 'samuel': '1 samuel', 'reis': '1 reis',
            'cronicas': '1 crônicas', 'tessalonicenses': '1 tessalonicenses',
            'timoteo': '1 timóteo', 'pedro': '1 pedro', 'filemom': 'filemom',
            'cronicas2': '2 crônicas',
            '2pedro': '2 pedro', '2corintios': '2 coríntios',
            '2timoteo': '2 timóteo', '2samuel': '2 samuel', '2reis': '2 reis',
        }
        for alias, name in aliases.items():
            book = self.by_name.get(fold(name))
            if book:
                self.by_name.setdefault(fold(alias), book)

    def find(self, book_name: str):
        f = fold(book_name)
        return self.by_name.get(f) or self.by_abbrev.get(f)

    def verses(self, book, chapter: int, v_start: int, v_end: int | None, max_verses=2) -> list[str]:
        chs = book.get('chapters') or []
        if book and len(chs) == 1 and chapter > 1 and chapter <= len(chs[0]):
            v_start, v_end, chapter = chapter, v_end or chapter, 1
        if chapter < 1 or chapter > len(chs):
            return []
        ch = chs[chapter - 1]
        start = max(0, (v_start or 1) - 1)
        if v_end is None:
            end = min(len(ch), start + max_verses)
        else:
            end = min(len(ch), v_end)
        return ch[start:end]


BIBLE: Bible | None = None


def parse_ref(raw: str) -> dict | None:
    t = re.sub(r'\s+', ' ', raw or '').strip()
    if not t:
        return None
    t = re.sub(r'^(refer[eê]ncia:\s*)', '', t, flags=re.I).strip()
    t = t.split(';')[0].strip()
    t = re.sub(r'^(\d+)([A-Za-zÀ-ú])', r'\1 \2', t)
    t = t.replace('–', '-').replace('—', '-')
    cross = re.match(r'^(.+?)\s+(\d+)\s*:\s*(\d+)\s*-\s*(\d+)\s*:\s*(\d+)\s*$', t)
    if cross:
        return {
            'book': cross.group(1).strip(), 'chapter': int(cross.group(2)),
            'v_start': int(cross.group(3)), 'v_end': None,
            'chapter_end': int(cross.group(4)),
        }
    m = re.match(
        r'^(.+?)\s+(\d+)\s*(?::\s*(\d+)\s*(?:-\s*(\d+))?|(?:-\s*(\d+)))?\s*$',
        t,
    )
    if not m:
        return None
    book, chapter = m.group(1).strip(), int(m.group(2))
    if m.group(3):
        v_start = int(m.group(3))
        v_end = int(m.group(4)) if m.group(4) else v_start
        return {'book': book, 'chapter': chapter, 'v_start': v_start, 'v_end': v_end}
    if m.group(5):
        return {'book': book, 'chapter': chapter, 'v_start': 1, 'v_end': None}
    return {'book': book, 'chapter': chapter, 'v_start': 1, 'v_end': None}


def lookup(ref: str, max_verses=2, max_chars=280) -> str:
    parsed = parse_ref(ref)
    if not parsed or not BIBLE:
        return ''
    book = BIBLE.find(parsed['book'])
    if not book:
        return ''
    verses = BIBLE.verses(book, parsed['chapter'], parsed['v_start'], parsed['v_end'], max_verses)
    text = re.sub(r'\s+', ' ', ' '.join(verses)).strip()
    if len(text) > max_chars:
        cut = text[:max_chars]
        period = cut.rfind('.')
        text = (cut[: period + 1] if period > 60 else cut.rsplit(' ', 1)[0]).strip()
    return text


def looks_like_ref(value: str) -> bool:
    v = (value or '').strip()
    if not v or len(v) > 70:
        return False
    return bool(parse_ref(v)) and bool(lookup(v))


def hook_ref_candidates(val: str) -> list[str]:
    t = re.sub(r'\s+', ' ', (val or '')).strip()
    if not t:
        return []
    t = t.replace('–', '-').replace('—', '-')
    t = re.sub(r'(\d)([A-Za-zÀ-ú])', r'\1 \2', t)
    t = re.sub(r'(:\d+)\s*,\s*\d+', r'\1', t)
    out = []
    last_book = None
    for part in [p.strip() for p in t.split(';') if p.strip()]:
        if last_book and re.match(r'^\d+', part) and not re.match(r'^\d+\s+[A-Za-zÀ-ú]', part):
            part = f'{last_book} {part}'
        parsed = parse_ref(part)
        if not parsed:
            continue
        last_book = parsed['book']
        ref = f"{parsed['book']} {parsed['chapter']}"
        if parsed.get('v_start'):
            ref += f":{parsed['v_start']}"
            v_end = parsed.get('v_end')
            if v_end and v_end != parsed['v_start']:
                ref += f'-{v_end}'
        if lookup(ref):
            out.append(ref)
    return out


def candidate_refs(trail: dict, mission: dict) -> list[str]:
    out = []
    slug = mission.get('slug') or ''
    trail_slug = trail.get('slug') or ''
    for key in (f'{trail_slug}:{slug}', slug):
        if key in SLUG_REFS:
            out.append(SLUG_REFS[key])
            break
    for field in ('hookRef', 'subtitle', 'objective', 'hookNote'):
        val = (mission.get(field) or '').strip()
        if looks_like_ref(val):
            out.append(val)
        out.extend(hook_ref_candidates(val))
    book = TRAIL_BOOK.get(trail_slug)
    if book:
        out.append(f'{book} 1:1-2')
    # unique preserve order
    seen = set()
    uniq = []
    for r in out:
        k = fold(r)
        if k not in seen:
            seen.add(k)
            uniq.append(r)
    return uniq


def passage_for(trail: dict, mission: dict) -> tuple[str, str]:
    for ref in candidate_refs(trail, mission):
        text = lookup(ref)
        if text and len(text) > 20:
            return ref, text
    title = mission.get('title') or 'esta passagem'
    return mission.get('hookRef') or 'Texto-base', (
        f'Deus fala e age com propósito nesta missão: {title}.'
    )


def first_clause(passage: str) -> str:
    parts = [p.strip() for p in re.split(r'(?<=[.;:])\s+', passage) if p.strip()]
    clause = parts[0] if parts else passage
    clause = clip(clause.rstrip(' .;:'), 120)
    if clause and clause[-1] not in '.!?':
        clause += '.'
    return clause


def as_assertion(text: str) -> str:
    value = re.sub(r'\s+', ' ', text or '').strip(' .;:!?').replace('?', '')
    if not value:
        return 'Deus age com propósito neste trecho.'
    if re.match(r'^(porque|porquanto|pois)\b', value, re.I):
        rest = value.split(None, 1)[1] if ' ' in value else value
        value = rest[0].upper() + rest[1:]
    elif re.match(r'^(o que|qual|quais|quem|como|por que|onde|quando)\b', value, re.I):
        value = f'O texto afirma que {value[0].lower() + value[1:]}'
    if not value.endswith('.'):
        value += '.'
    return value[0].upper() + value[1:]


def content_words(passage: str) -> list[str]:
    words = re.findall(r"[A-Za-zÀ-ÿ]+", passage or '')
    out, seen = [], set()
    for min_l in (4, 3, 2):
        for w in words:
            lw = w.lower()
            if len(w) < min_l or lw in STOP or lw in seen:
                continue
            seen.add(lw)
            out.append(w)
        if len(out) >= 3:
            return out
    for w in words:
        if w.lower() not in seen:
            seen.add(w.lower())
            out.append(w)
        if len(out) >= 3:
            break
    while len(out) < 3 and words:
        extra, nxt = words[len(out) % len(words)], words[(len(out) + 1) % len(words)]
        phrase = f'{extra} {nxt}'
        if phrase.lower() not in seen:
            seen.add(phrase.lower())
            out.append(phrase)
        else:
            break
    return out or ['Deus', 'fala', 'propósito']


def blank_template(passage: str, target: str) -> str:
    tmpl, n = re.compile(rf'(?i)\b{re.escape(target)}\b').subn('___', passage, count=1)
    if n == 0:
        tmpl = passage + ' ___'
    return re.sub(r'\s+', ' ', tmpl).strip()


def three_fragments(passage: str) -> list[str]:
    text = re.sub(r'\s+', ' ', passage).strip()
    parts = [p.strip(' .;:') for p in re.split(r'(?<=[.;:])\s+', text) if p.strip(' .;:')]
    if len(parts) < 3:
        parts = [p.strip() for p in re.split(r',\s*', text) if p.strip()]
    if len(parts) >= 3:
        frags = parts[:3]
    else:
        words = text.split()
        if len(words) < 6:
            words = (words * 6)[:9]
        n = len(words)
        a, b = max(2, n // 3), max(4, (2 * n) // 3)
        if a >= b:
            b = min(n - 1, a + 2)
        frags = [' '.join(words[:a]), ' '.join(words[a:b]), ' '.join(words[b:])]
    cleaned = []
    for frag in frags:
        frag = clip(frag, 80).rstrip(' ,;:')
        frag = re.sub(r'\b(e|de|do|da|o|a|que|em|no|na)\s*$', '', frag, flags=re.I).strip()
        cleaned.append(frag or 'Deus age neste trecho')
    return cleaned


def rotate_options(texts, correct, salt, fb_messages):
    items, seen = [], set()
    for t in texts:
        key = clip(t.strip(), 80)
        if not key or key.lower() in seen:
            continue
        seen.add(key.lower())
        items.append(key)
    correct = clip(correct, 80)
    if correct.lower() not in seen:
        items.insert(0, correct)
    rot = stable_rot(salt, len(items))
    items = items[rot:] + items[:rot]
    options = [{'id': chr(ord('a') + i), 'text': t} for i, t in enumerate(items)]
    correct_id = next(o['id'] for o in options if o['text'].lower() == correct.lower())
    wrong, mi = {}, 0
    msgs = list(fb_messages)
    for o in options:
        if o['id'] == correct_id:
            continue
        wrong[o['id']] = msgs[mi % len(msgs)]
        mi += 1
    return options, correct_id, wrong


def short_bridge(text: str, max_words=6) -> str:
    words = re.findall(r"[A-Za-zÀ-ÿ0-9]+", (text or '').rstrip('.'))
    return ' '.join(words[:max_words]) if words else 'Deus age com propósito'


def insight_of(mission: dict, passage: str, title: str) -> str:
    raw = (mission.get('centralInsight') or '').strip()
    if raw and not re.match(r'^(o que|qual|esta missão|este trecho revela)', raw, re.I) and '?' not in raw:
        return clip(raw, 140)
    return clip(f'{title}: {first_clause(passage)}', 140)


def learning_obj(mission: dict, title: str) -> str:
    value = (mission.get('objective') or '').strip(' .;:!?')
    if not value or looks_like_ref(value) or len(value) < 8:
        return f'Compreender o sentido central de {title} no texto.'
    if re.match(r'^(o que|qual|quais|quem|como|porque|por que|onde|quando)\b', value, re.I):
        rest = value[0].lower() + value[1:]
        return f'Compreender {rest}.'
    if not value.endswith('.'):
        value += '.'
    return value[0].upper() + value[1:]


def base(mission, diff, verse, lo):
    return {
        'difficulty': diff,
        'skill': SKILLS[diff],
        'verseRef': verse,
        'learningObjective': lo,
        'evidence': [verse],
    }


def build_mission(trail: dict, mission: dict) -> list[dict]:
    section = (mission.get('slug') or 'missao').strip()
    title = re.sub(r'\?$', '', (mission.get('title') or 'esta passagem').strip())
    verse, passage = passage_for(trail, mission)
    words = content_words(passage)
    insight = insight_of(mission, passage, title)
    lo = learning_obj(mission, title)
    literal = as_assertion(first_clause(passage))
    fact = clip(literal.rstrip('.'), 80)
    questions = []

    for d_i, diff in enumerate(DIFFICULTIES):
        tap_w = words[d_i % len(words)]
        complete_w = next((w for w in words if w.lower() != tap_w.lower()), words[0])
        if complete_w.lower() == tap_w.lower() and len(words) > 1:
            complete_w = words[(d_i + 1) % len(words)]

        # true_false
        if diff == 'semente':
            statement, ans = literal, 'true'
        elif diff == 'caminhada':
            statement = as_assertion(f'O texto nega que {literal[0].lower() + literal[1:]}')
            ans = 'false'
        else:
            statement = as_assertion(f'A passagem sustenta o chamado de {title} neste trecho')
            ans = 'true'
        statement = statement.replace('?', '')
        wrong_key = 'true' if ans == 'false' else 'false'
        tf_q = {
            **base(mission, diff, verse, lo),
            'type': 'true_false',
            'question': statement, 'prompt': statement, 'cue': statement,
            'feedbackCorrect': f'Certo: isso se verifica em {verse}.',
            'feedbackWrong': {wrong_key: 'A afirmação não corresponde ao que o texto comunica.'},
            'options': TF, 'correctOptionId': ans, 'correctAnswer': ans,
            'passageText': passage,
        }

        def gap(kind, target):
            others = [w for w in words if w.lower() != target.lower()]
            while len(others) < 2:
                others.append(words[len(others) % len(words)])
            tmpl = blank_template(passage, target)
            hook = verse
            if kind == 'tap':
                question = f'Em {hook}, toque a palavra que falta em "{tmpl}"?'
                fb_ok = f'Exato: essa palavra está em {hook}.'
                fb_bad = ['Essa palavra está no versículo, mas não nesta lacuna.', 'Releia o trecho e escolha a palavra que falta.']
            else:
                question = f'Complete a frase: "{tmpl}"'
                fb_ok = 'Certo: esta palavra completa o versículo.'
                fb_bad = ['Essa palavra não preenche esta lacuna.', 'O contexto pede outra palavra do trecho.']
            opts, cid, wrong = rotate_options(
                [target, others[0], others[1]], target,
                f'{section}-{diff}-{kind}', fb_bad,
            )
            return {
                **base(mission, diff, verse, lo),
                'type': kind, 'question': question, 'prompt': question, 'cue': question,
                'feedbackCorrect': fb_ok, 'feedbackWrong': wrong,
                'passageText': passage, 'template': tmpl, 'options': opts,
                'correctOptionId': cid, 'correctAnswer': cid,
            }

        if diff == 'semente':
            stem = f'Qual afirmação é feita diretamente pelo texto em {verse}?'
            correct = fact
            wrongs = [
                'O trecho omite qualquer ação ou palavra de Deus.',
                'O texto atribui o que acontece ao acaso.',
                f'O texto nega o tema de {clip(title, 28)}.',
            ]
        elif diff == 'caminhada':
            stem = f'Qual ideia melhor conecta {verse} ao contexto da missão?'
            correct = clip(insight.rstrip('.'), 80)
            wrongs = [
                'O texto se fecha em si e não pede resposta de fé.',
                'Deus permanece distante da vida humana neste trecho.',
                'A mensagem central é a autonomia completa do ser humano.',
            ]
        else:
            stem = f'Qual leitura interpreta melhor o sentido de {verse}?'
            correct = clip(insight.rstrip('.'), 80)
            wrongs = [
                'O trecho reduz a fé a um detalhe sem peso espiritual.',
                'A passagem ensina que a ação humana substitui a de Deus.',
                'O sentido do texto é que Deus se ausenta da história.',
            ]
        ch_opts, ch_id, ch_wrong = rotate_options(
            [correct] + wrongs, correct, f'{section}-{diff}-choice',
            [
                'Essa leitura não se sustenta no texto.',
                'O trecho aponta para outra realidade.',
                f'Compare de novo com {verse}.',
            ],
        )
        choice_q = {
            **base(mission, diff, verse, lo),
            'type': 'choice', 'question': stem, 'prompt': stem, 'cue': stem,
            'feedbackCorrect': f'Certo: o trecho em {verse} sustenta essa leitura.',
            'feedbackWrong': ch_wrong, 'passageText': passage,
            'options': ch_opts, 'correctOptionId': ch_id, 'correctAnswer': ch_id,
        }

        if diff == 'semente':
            ostem = f'Qual sequência mostra a ordem dos fatos em {verse}?'
        elif diff == 'caminhada':
            ostem = f'Como se encadeiam os eventos de {verse}?'
        else:
            ostem = f'Qual sequência revela o sentido de {verse}?'
        frags = three_fragments(passage)
        order_q = {
            **base(mission, diff, verse, lo),
            'type': 'order', 'question': ostem, 'prompt': ostem, 'cue': ostem,
            'feedbackCorrect': 'Certo: essa é a sequência que o texto mostra.',
            'feedbackWrong': {
                'b': 'A ordem está deslocada em relação ao trecho.',
                'c': 'Releia a sequência da passagem.',
            },
            'passageText': passage,
            'options': [{'id': chr(ord('a') + i), 'text': frags[i]} for i in range(3)],
            'correctOrder': ['a', 'b', 'c'], 'correctOptionId': 'a', 'correctAnswer': 'a',
        }

        if diff == 'semente':
            bridge, cwrongs = short_bridge(insight), ['Acaso sem propósito', 'Homem acima de Deus']
        elif diff == 'caminhada':
            bridge, cwrongs = short_bridge(title + ' sob Deus'), ['Nenhuma resposta de fé', 'Deus irrelevante na trama']
        else:
            bridge, cwrongs = short_bridge(insight), ['Detalhe sem aplicação', 'Deus fora do centro']
        cq = f'O que {verse} comunica que se liga a este contexto?'
        cn_opts, cn_id, cn_wrong = rotate_options(
            [bridge] + cwrongs, bridge, f'{section}-{diff}-connect',
            ['Essa opção quebra a ligação com a missão.', 'O texto aponta outra ponte.'],
        )
        connect_q = {
            **base(mission, diff, verse, lo),
            'type': 'connect', 'question': cq, 'prompt': cq, 'cue': cq,
            'feedbackCorrect': 'Certo: o texto se liga ao sentido desta missão.',
            'feedbackWrong': cn_wrong, 'passageText': clip(passage, 150),
            'passageA': {'ref': verse, 'text': clip(passage, 150)},
            'passageB': {'ref': 'Contexto', 'text': clip(insight, 120)},
            'options': cn_opts, 'correctOptionId': cn_id, 'correctAnswer': cn_id,
        }

        bundle = [tf_q, gap('tap', tap_w), choice_q, order_q, gap('complete', complete_w), connect_q]
        used = set()
        for i, item in enumerate(bundle):
            item['trail'] = trail['slug']
            item['section'] = section
            item['id'] = f"{trail['slug']}-{SHORT[diff]}-{section}-{i + 1:02d}"
            stem_k = (item.get('question') or '').lower().strip()
            if stem_k in used:
                item['question'] = f"{item['question']} ({item['type']})"
                item['prompt'] = item['cue'] = item['question']
            used.add((item.get('question') or '').lower().strip())
            item['feedbackWrong'] = dict(sorted((item.get('feedbackWrong') or {}).items()))
            questions.append(item)
    return questions


def generate(realm: str | None):
    global BIBLE
    BIBLE = Bible(BIBLE_PATH)
    trails = json.loads(TRAILS_PATH.read_text(encoding='utf-8'))
    OUT_DIR.mkdir(exist_ok=True)
    written = []
    total_q = 0
    for trail in trails:
        slug = trail.get('slug')
        if slug == 'teste' or trail.get('isActive') is False:
            continue
        if trail.get('comingSoon') and realm not in {'teologia', 'vida-crista'}:
            continue
        if slug in KEEP:
            continue
        if realm and trail.get('realm') != realm:
            continue
        if trail.get('realm') not in {'antigo-testamento', 'novo-testamento', 'vida-crista', 'teologia'}:
            continue
        if realm is None and trail.get('realm') not in {'antigo-testamento', 'novo-testamento'}:
            continue
        questions = []
        for module in trail.get('modules') or []:
            for mission in module.get('missions') or []:
                if not mission.get('slug'):
                    continue
                questions.extend(build_mission(trail, mission))
        path = OUT_DIR / f'{slug}.json'
        path.write_text(json.dumps(questions, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
        written.append((slug, len(questions)))
        total_q += len(questions)
        print(f'  {slug}: {len(questions)} perguntas')
    print(f'Trilhas: {len(written)}  Perguntas: {total_q}')
    return written


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--realm', default=None)
    args = parser.parse_args()
    generate(args.realm)


if __name__ == '__main__':
    main()
